// Application state and use cases. The UI listens to [appState] and calls its methods.
// Rule: every action first writes to the local database, then tries the online one.
 
import 'dart:async';
import 'dart:convert';
import 'dart:math';
 
import 'package:flutter/foundation.dart';
 
import '../data/local_store.dart';
import '../data/remote_api.dart';
import '../data/simple_pdf.dart';
import '../domain/analysis.dart';
import '../domain/catalog.dart';
import '../domain/ccsds.dart';
import '../domain/crypto.dart';
import '../domain/models.dart';
import '../l10n/strings.dart';
 
final AppState appState = AppState();
 
/// Translates [key] in the current language. "{0}", "{1}"... are replaced by [args].
String t(String key, [List<Object> args = const []]) => translate(appState.lang, key, args);
 
class AppState extends ChangeNotifier {
  final LocalStore _local = LocalStore();
  final RemoteApi _remote = RemoteApi();
  final AnalysisEngine _engine = const AnalysisEngine(kSynergyRules);
 
  bool loaded = false;
  String lang = 'en';
  bool darkMode = false;
  Session? session;
 
  MissionEnvironment environment = MissionEnvironment.spacecraft;
  List<Measurement> measurements = [];
  List<HealthAlert> alerts = [];
 
  bool syncing = false;
  /// True when the last attempt to reach the online database failed.
  bool lastSyncFailed = false;
  DateTime? lastSyncAt;
  int _seq = 0;
 
  // Reports for the ground. They are created on board, kept in [reports], and sent
  // through the simulated link when it is up.
  List<Report> reports = [];
 
  /// Waiting time after the last measurement before a report is created, in seconds.
  int reportDelay = 600;
 
  /// When the next automatic report is due. Null when no new measurement is waiting.
  DateTime? reportDueAt;
  DateTime? lastReportAt;
 
  /// State of the simulated link with the ground.
  bool linkUp = false;
 
  /// Key shared with the ground before the mission, in hexadecimal.
  String missionKey = '';
 
  /// The transfer in progress, with the moment it started.
  TransferPlan? transfer;
  DateTime? transferStart;
  String? transferReportId;
 
  /// The last finished transfer, kept for the protocol log.
  TransferPlan? lastTransfer;
  Timer? _reportTimer;
  Timer? _transferTimer;
 
  bool get signedIn => session != null;
 
  // ------------------------------------------------------------- local database
 
  Future<void> load() async {
    final device = await _local.readDevice();
    if (device != null) {

      lang = device['lang'] == 'fr' ? 'fr' : 'en';
      darkMode = device['darkMode'] == true;
      final s = device['session'];
      if (s is Map) {
        try {
          session = Session.fromJson(Map<String, dynamic>.from(s));
        } catch (_) {
          session = null;
        }
      }
    }
    if (session != null) await _loadUser(session!.uid);
    loaded = true;
    notifyListeners();
    unawaited(sync());
    checkReportDue();
    _pumpLink();
  }
 
  Future<void> _loadUser(String uid) async {
    measurements = [];
    alerts = [];
    environment = MissionEnvironment.spacecraft;
    lastSyncAt = null;
    _stopTimers();
    reports = [];
    reportDelay = 600;
    reportDueAt = null;
    lastReportAt = null;
    linkUp = false;
    missionKey = '';
    lastTransfer = null;
    final data = await _local.readUser(uid);
    if (data == null) return;
    try {
      environment = enumByName(
        MissionEnvironment.values,
        data['environment'],
        MissionEnvironment.spacecraft,
      );
      measurements = [
        for (final e in (data['measurements'] as List? ?? const []))
          Measurement.fromJson(Map<String, dynamic>.from(e as Map)),
      ];
      alerts = [
        for (final e in (data['alerts'] as List? ?? const []))
          HealthAlert.fromJson(Map<String, dynamic>.from(e as Map)),
      ];
      lastSyncAt = DateTime.tryParse('${data['lastSyncAt']}');
      reports = [
        for (final e in (data['reports'] as List? ?? const []))
          Report.fromJson(Map<String, dynamic>.from(e as Map)),
      ];
      reportDelay = (data['reportDelay'] as num?)?.toInt() ?? 600;
      reportDueAt = DateTime.tryParse('${data['reportDueAt']}');
      lastReportAt = DateTime.tryParse('${data['lastReportAt']}');
      linkUp = data['linkUp'] == true;
      missionKey = '${data['missionKey'] ?? ''}';
    } catch (_) {
      measurements = [];
      alerts = [];
    }
  }
 
  Future<void> _saveDevice() =>
      _local.writeDevice({'lang': lang, 'darkMode': darkMode, 'session': session?.toJson()});
 
  Future<void> _saveUser() async {
    final s = session;
    if (s == null) return;
    await _local.writeUser(s.uid, {
      'environment': environment.name,
      'measurements': measurements.map((m) => m.toJson()).toList(),
      'alerts': alerts.map((a) => a.toJson()).toList(),
      'lastSyncAt': lastSyncAt?.toIso8601String(),
      'reports': reports.map((r) => r.toJson()).toList(),
      'reportDelay': reportDelay,
      'reportDueAt': reportDueAt?.toIso8601String(),
      'lastReportAt': lastReportAt?.toIso8601String(),
      'linkUp': linkUp,
      'missionKey': missionKey,
    });
  }
  void _changed() {

    unawaited(_saveUser());
    notifyListeners();
  }
 
  String _newId(String prefix) {
    _seq++;
    return '$prefix${DateTime.now().microsecondsSinceEpoch}$_seq';
  }
 
  // ------------------------------------------------------------------- account
 
  /// Signs in with the online account. Needs the internet: do it before the mission.
  Future<void> signIn(String email, String password) async {
    final auth = await _remote.signIn(email.trim(), password);
    final rows = await _remote.select('profiles', 'id', auth.uid, auth.accessToken);
    final profile = rows.isEmpty ? const <String, dynamic>{} : rows.first;
    await _open(
      Session(
        uid: auth.uid,
        email: email.trim(),
        name: '${profile['name'] ?? ''}',
        role: '${profile['role'] ?? ''}',
        refreshToken: auth.refreshToken,
        idToken: auth.accessToken,
        idTokenExpiry: auth.expiry,
      ),
    );
    await _pull();
  }
 
  /// Creates the online account and the astronaut profile.
  Future<void> signUp(String name, String role, String email, String password) async {
    final auth = await _remote.signUp(email.trim(), password);
    await _remote.upsert('profiles', {
      'id': auth.uid,
      'name': name.trim(),
      'role': role.trim(),
      'email': email.trim(),
    }, auth.accessToken);
    await _open(
      Session(
        uid: auth.uid,
        email: email.trim(),
        name: name.trim(),
        role: role.trim(),
        refreshToken: auth.refreshToken,
        idToken: auth.accessToken,
        idTokenExpiry: auth.expiry,
      ),
    );
  }
 
  Future<void> _open(Session s) async {
    session = s;
    await _loadUser(s.uid);
    lastSyncFailed = false;
    await _saveDevice();
    notifyListeners();
  }
 
  /// Leaves the account. Local data stays on the device, but signing in again
  /// needs the internet.
  Future<void> signOut() async {
    session = null;
    measurements = [];
    alerts = [];
    _stopTimers();
    reports = [];
    reportDueAt = null;
    await _saveDevice();
    notifyListeners();
  }
 
  Future<String> _idToken() async {
    final s = session;
    if (s == null) throw RemoteException('SIGNED_OUT');
    if (s.idToken.isNotEmpty &&
        s.idTokenExpiry.isAfter(DateTime.now().add(const Duration(minutes: 2)))) {
      return s.idToken;
    }
    final auth = await _remote.refresh(s.refreshToken);
    s.idToken = auth.accessToken;
    s.refreshToken = auth.refreshToken;
    s.idTokenExpiry = auth.expiry;

    await _saveDevice();
    return s.idToken;
  }
 
  // ----------------------------------------------------------- online database
 
  int get pendingCount =>
      measurements.where((m) => !m.synced).length + alerts.where((a) => !a.synced).length;
 
  /// Downloads the measurements and alerts already saved online (new device, reinstall).
  Future<void> _pull() async {
    final s = session;
    if (s == null) return;
    try {
      final token = await _idToken();
      final known = {for (final m in measurements) m.id};
      for (final row in await _remote.select('measurements', 'user_id', s.uid, token)) {
        if (!known.contains('${row['id']}')) measurements.add(Measurement.fromRemote(row));
      }
      final knownAlerts = {for (final a in alerts) a.id};
      for (final row in await _remote.select('alerts', 'user_id', s.uid, token)) {
        if (!knownAlerts.contains('${row['id']}')) alerts.add(HealthAlert.fromRemote(row));
      }
      lastSyncFailed = false;
      lastSyncAt = DateTime.now();
    } on RemoteException {
      lastSyncFailed = true;
    }
    _changed();
  }
 
  /// Sends to the online database everything that is not saved there yet.
  /// Safe to call at any time: without a network it simply keeps the data for later.
  Future<void> sync() async {
    final s = session;
    if (s == null || syncing) return;
    if (pendingCount == 0) return;
    syncing = true;
    notifyListeners();
    try {
      final token = await _idToken();
      for (final m in measurements.where((m) => !m.synced).toList()) {
        await _remote.upsert('measurements', m.toRemote(s.uid), token);
        m.synced = true;
      }
      for (final a in alerts.where((a) => !a.synced).toList()) {
        await _remote.upsert('alerts', a.toRemote(s.uid), token);
        a.synced = true;
      }
      lastSyncFailed = false;
      lastSyncAt = DateTime.now();
    } on RemoteException {
      lastSyncFailed = true;
    } catch (_) {
      lastSyncFailed = true;
    }
    syncing = false;
    _changed();
  }
 
  // ------------------------------------------------------------------- queries
 
  List<Hazard> get activeHazards => activeHazardsOf(environment);
 
  /// Measurements of one indicator, oldest first.
  List<Measurement> history(String code) {
    final list = measurements.where((m) => m.indicator == code).toList();
    list.sort((a, b) => a.at.compareTo(b.at));
    return list;
  }
 
  Measurement? latest(String code) {
    Measurement? best;
    for (final m in measurements) {
      if (m.indicator != code) continue;
      if (best == null || m.at.isAfter(best.at)) best = m;
    }
    return best;
  }
 
  /// Level of the latest value of an indicator, or null when never measured.
  AlertLevel? levelOf(String code) {
    final m = latest(code);
    return m == null ? null : indicatorByCode(code).levelFor(m.value);

  }
 
  Map<String, AlertLevel> latestLevels() {
    final map = <String, AlertLevel>{};
    for (final i in kIndicators) {
      final l = levelOf(i.code);
      if (l != null) map[i.code] = l;
    }
    return map;
  }
 
  List<SynergyRule> activeSynergies() => _engine.activeSynergies(latestLevels(), activeHazards);
 
  /// Overall level: worst indicator, raised by an active combined risk.
  /// Null when nothing has been measured yet.
  AlertLevel? overallLevel() {
    final levels = latestLevels();
    if (levels.isEmpty) return null;
    var worst = AlertLevel.nominal;
    for (final l in levels.values) {
      worst = maxLevel(worst, l);
    }
    for (final r in activeSynergies()) {
      worst = maxLevel(worst, r.level);
    }
    return worst;
  }
  List<HealthAlert> sortedAlerts() {
    final list = alerts.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }
 
  int get openAlertCount => alerts.where((a) => a.isOpen).length;
 
  HealthAlert? alertById(String id) {
    for (final a in alerts) {
      if (a.id == id) return a;
    }
    return null;
  }
 
  // ------------------------------------------------------------------ commands
 
  /// Records a measurement, analyses it and raises an alert when needed.
  AnalysisResult record(String code, double value) {
    final indicator = indicatorByCode(code);
    final previous = history(code).map((m) => m.value).toList();
    final others = latestLevels()..remove(code);
 
    final measurement = Measurement(
      id: _newId('m'),
      indicator: code,
      value: value,
      at: DateTime.now(),
    );
    measurements.add(measurement);
 
    final result = _engine.analyze(
      indicator: indicator,
      value: value,
      history: previous,
      latest: others,
      activeHazards: activeHazards,
    );
 
    // A new measurement supersedes the open alerts of the same indicator.
    for (final a in alerts) {
      if (a.indicator == code && a.isOpen) {
        a.status = AlertStatus.resolved;
        a.synced = false;
      }
    }
    if (result.level != AlertLevel.nominal) {
      alerts.add(
        HealthAlert(
          id: _newId('a'),
          indicator: code,
          value: value,
          level: result.level,
          cause: result.cause,
          ruleId: result.cause == AlertCause.synergy && result.synergies.isNotEmpty
              ? result.synergies.first.id
              : '',

          createdAt: measurement.at,
        ),
      );
    }
    // A report for the ground will be created once no new measurement has come
    // for [reportDelay] seconds. Every new measurement restarts the wait.
    reportDueAt = DateTime.now().add(Duration(seconds: reportDelay));
    _armReportTimer();
    _changed();
    unawaited(sync());
    return result;
  }
 
  void acknowledge(String alertId) {
    final a = alertById(alertId);
    if (a == null || a.status != AlertStatus.active) return;
    a.status = AlertStatus.acknowledged;
    a.synced = false;
    _changed();
    unawaited(sync());
  }
 
  void setLanguage(String value) {
    lang = value == 'fr' ? 'fr' : 'en';
    unawaited(_saveDevice());
    notifyListeners();
  }
 
  void setDarkMode(bool value) {
    darkMode = value;
    unawaited(_saveDevice());
    notifyListeners();
  }
 
  void setEnvironment(MissionEnvironment value) {
    environment = value;
    _changed();
  }
 
  // -------------------------------------------------------------------- report
 
  String _two(int n) => n < 10 ? '0$n' : '$n';
 
  String formatDate(DateTime d) =>
      '${_two(d.day)}/${_two(d.month)}/${d.year} ${_two(d.hour)}:${_two(d.minute)}';
 
  // ---------------------------------------------------- reports for the ground
 
  int get queuedReports => reports.where((r) => !r.sent).length;
 
  List<Report> sortedReports() {
    final list = reports.toList();
    list.sort((a, b) => b.number.compareTo(a.number));
    return list;
  }
 
  /// Measurements recorded since the last report, oldest first.
  List<Measurement> newMeasurements() {
    final since = lastReportAt;
    final list = [
      for (final m in measurements)
        if (since == null || m.at.isAfter(since)) m,
    ];
    list.sort((a, b) => a.at.compareTo(b.at));
    return list;
  }
 
  void _stopTimers() {
    _reportTimer?.cancel();
    _reportTimer = null;
    _transferTimer?.cancel();
    _transferTimer = null;
    transfer = null;
    transferStart = null;
    transferReportId = null;
  }
 
  void _armReportTimer() {
    _reportTimer?.cancel();
    _reportTimer = null;
    final due = reportDueAt;
    if (due == null) return;
    final wait = due.difference(DateTime.now());
    _reportTimer = Timer(wait.isNegative ? Duration.zero : wait, () => createReport(auto: true));

  }
 
  /// Called when the app starts and each time it comes back to the screen: a report
  /// whose time has passed while the app was closed is created at once.
  void checkReportDue() {
    if (reportDueAt == null) return;
    _armReportTimer();
  }
 
  void setReportDelay(int seconds) {
    reportDelay = seconds;
    if (reportDueAt != null) {
      reportDueAt = DateTime.now().add(Duration(seconds: seconds));
      _armReportTimer();
    }
    _changed();
  }
 
  /// Creates a report from the new measurements and the latest value of each
  /// indicator, and puts it in the queue for the ground.
  Report createReport({required bool auto}) {
    _reportTimer?.cancel();
    _reportTimer = null;
    final fresh = newMeasurements();
    var number = 1;
    for (final r in reports) {
      if (r.number >= number) number = r.number + 1;
    }
    final pdf = buildTransmissionPdf(number, fresh, auto);
    final report = Report(
      id: _newId('r'),
      number: number,
      createdAt: DateTime.now(),
      auto: auto,
      newCount: fresh.length,
      pdf: base64Encode(pdf),
      digest: hex(sha256(pdf)).substring(0, 16),
    );
    reports.add(report);
    // Only the 20 latest reports stay on the device.
    reports.sort((a, b) => a.number.compareTo(b.number));
    while (reports.length > 20) {
      reports.removeAt(0);
    }
    lastReportAt = report.createdAt;
    reportDueAt = null;
    _changed();
    _pumpLink();
    return report;
  }
 
  Uint8List reportBytes(Report r) => base64Decode(r.pdf);
 
  /// Opens or cuts the simulated link with the ground.
  void setLink(bool up) {
    linkUp = up;
    if (!up) {
      // A transfer cut halfway starts again from the beginning later.
      _transferTimer?.cancel();
      _transferTimer = null;
      transfer = null;
      transferStart = null;
      transferReportId = null;
    }
    _changed();
    _pumpLink();
  }
 
  List<int> _key() {
    if (missionKey.length != 64) {
      final random = Random.secure();
      missionKey = hex([for (var i = 0; i < 32; i++) random.nextInt(256)]);
    }
    return unhex(missionKey);
  }
 
  /// Starts sending the oldest waiting report when the link is up and free.
  void _pumpLink() {
    if (!linkUp || transfer != null) return;
    Report? next;
    for (final r in reports) {
      if (!r.sent && (next == null || r.number < next.number)) next = r;
    }
    if (next == null) return;

    final report = next;
    final random = Random.secure();
    final plan = runTransfer(
      report: reportBytes(report),
      missionKey: _key(),
      nonce: [for (var i = 0; i < 12; i++) random.nextInt(256)],
      transaction: report.number & 0xFFFF,
      fileName: report.fileName,
    );
    transfer = plan;
    transferStart = DateTime.now();
    transferReportId = report.id;
    _transferTimer = Timer(Duration(milliseconds: plan.durationMs), () {
      if (plan.ok) {
        report.sent = true;
        report.sentAt = DateTime.now();
        report.packets = plan.packets;
        report.resent = plan.resent;
      }
      lastTransfer = plan;
      transfer = null;
      transferStart = null;
      transferReportId = null;
      _transferTimer = null;
      _changed();
      if (plan.ok) _pumpLink();
    });
    _changed();
  }
 
  /// Report sent to the ground: the new measurements, then the latest value of
  /// every indicator and the open alerts.
  Uint8List buildTransmissionPdf(int number, List<Measurement> fresh, bool auto) {
    final lines = _reportHeader('${t('report.title')} ${t('tx.number', [number])}');
    lines.add(PdfLine(t(auto ? 'tx.pdf.auto' : 'tx.pdf.manual')));
    lines.add(const PdfLine(''));
 
    lines.add(PdfLine(t('tx.pdf.new', [fresh.length]), size: 13, bold: true));
    if (fresh.isEmpty) {
      lines.add(PdfLine(t('tx.pdf.nonew')));
    } else {
      for (final m in fresh) {
        final i = indicatorByCode(m.indicator);
        lines.add(
          PdfLine(
            '${formatDate(m.at)} | ${t('ind.${m.indicator}.name')}: '
            '${i.format(m.value)} ${i.unit} | [${t('level.${i.levelFor(m.value).name}')}]',
          ),
        );
      }
    }
    lines.add(const PdfLine(''));
 
    lines.add(PdfLine(t('tx.pdf.latest'), size: 13, bold: true));
    for (final i in kIndicators) {
      final last = latest(i.code);
      lines.add(
        PdfLine(
          last == null
              ? '${t('ind.${i.code}.name')}: ${t('home.nodata')}'
              : '${t('ind.${i.code}.name')}: ${i.format(last.value)} ${i.unit} | '
                    '[${t('level.${i.levelFor(last.value).name}')}] | ${formatDate(last.at)}',
        ),
      );
    }
    lines.add(const PdfLine(''));
 
    lines.add(PdfLine(t('alerts.open'), size: 13, bold: true));
    final open = sortedAlerts().where((a) => a.isOpen).toList();
    if (open.isEmpty) {
      lines.add(PdfLine(t('alerts.none')));
    } else {
      for (final a in open) {
        final i = indicatorByCode(a.indicator);
        lines.add(
          PdfLine(
            '${formatDate(a.createdAt)} | ${t('ind.${a.indicator}.name')}: '
            '${i.format(a.value)} ${i.unit} | ${t('level.${a.level.name}')} | '
            '(${t('status.${a.status.name}')})',
          ),
        );
      }
    }
    lines.add(const PdfLine(''));

    lines.add(PdfLine(t('about.disclaimer'), size: 9));
    return SimplePdf.build(lines);
  }
 
  /// First lines of every report: who, where, when, overall status.
  List<PdfLine> _reportHeader(String title) {
    final s = session;
    final lines = <PdfLine>[
      PdfLine('AstroCare - $title', size: 18, bold: true),
      const PdfLine(''),
      PdfLine('${t('report.astronaut')}: ${s?.name ?? ''} (${s?.role ?? ''})'),
      PdfLine('${t('report.account')}: ${s?.email ?? ''}'),
      PdfLine('${t('settings.environment')}: ${t('env.${environment.name}')}'),
      PdfLine('${t('report.generated')}: ${formatDate(DateTime.now())}'),
      const PdfLine(''),
    ];
    final overall = overallLevel();
    lines.add(
      PdfLine(
        '${t('home.overall')}: ${t(overall == null ? 'level.nodata' : 'level.${overall.name}')}',
        size: 13,
        bold: true,
      ),
    );
    for (final r in activeSynergies()) {
      lines.add(PdfLine('${t('home.combined')}: ${t('syn.${r.id}.name')}'));
    }
    lines.add(const PdfLine(''));
    return lines;
  }
 
  /// Full health report as a PDF file, built on the device without any network.
  Uint8List buildReportPdf() {
    final lines = _reportHeader(t('report.title'));
 
    for (final i in kIndicators) {
      final list = history(i.code);
      lines.add(PdfLine(t('ind.${i.code}.name'), size: 13, bold: true));
      lines.add(
        PdfLine(
          t('range.nominal', [i.format(i.nominalLow), i.format(i.nominalHigh), i.unit]),
          size: 9.5,
        ),
      );
      if (list.isEmpty) {
        lines.add(PdfLine(t('home.nodata')));
      } else {
        final recent = list.length > 10 ? list.sublist(list.length - 10) : list;
        for (final m in recent.reversed) {
          lines.add(
            PdfLine(
              '${formatDate(m.at)} | ${i.format(m.value)} ${i.unit} | '
              '[${t('level.${i.levelFor(m.value).name}')}]',
            ),
          );
        }
      }
      lines.add(const PdfLine(''));
    }
 
    lines.add(PdfLine(t('nav.alerts'), size: 13, bold: true));
    final all = sortedAlerts();
    if (all.isEmpty) {
      lines.add(PdfLine(t('alerts.none')));
    } else {
      for (final a in all.take(20)) {
        final i = indicatorByCode(a.indicator);
        lines.add(
          PdfLine(
            '${formatDate(a.createdAt)} | ${t('ind.${a.indicator}.name')}: '
            '${i.format(a.value)} ${i.unit} | ${t('level.${a.level.name}')} | '
            '(${t('status.${a.status.name}')})',
          ),
        );
      }
    }
    lines.add(const PdfLine(''));
    lines.add(PdfLine(t('about.disclaimer'), size: 9));
    return SimplePdf.build(lines);
  }
}
