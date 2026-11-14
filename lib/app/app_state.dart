// Application state and use cases. The UI listens to [appState] and calls its methods.
// Rule: every action first writes to the local database, then tries the online one.
 
import 'dart:async';
 
import 'package:flutter/foundation.dart';
 
import '../data/local_store.dart';
import '../data/remote_api.dart';
import '../data/simple_pdf.dart';
import '../domain/analysis.dart';
import '../domain/catalog.dart';
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
  }
 
  Future<void> _loadUser(String uid) async {
    measurements = [];
    alerts = [];
    environment = MissionEnvironment.spacecraft;
    lastSyncAt = null;
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
    final profile = await _remote.getDocument('users/${auth.uid}', auth.idToken);
    await _open(
      Session(
        uid: auth.uid,
        email: email.trim(),
        name: '${profile?['name'] ?? ''}',
        role: '${profile?['role'] ?? ''}',
        refreshToken: auth.refreshToken,
        idToken: auth.idToken,
        idTokenExpiry: auth.expiry,
      ),
    );
    await _pull();
  }
 
  /// Creates the online account and the astronaut profile.
  Future<void> signUp(String name, String role, String email, String password) async {
    final auth = await _remote.signUp(email.trim(), password);
    await _remote.setDocument('users/${auth.uid}', {
      'name': name.trim(),
      'role': role.trim(),
      'email': email.trim(),
      'createdAt': DateTime.now(),
    }, auth.idToken);
    await _open(
      Session(
        uid: auth.uid,
        email: email.trim(),
        name: name.trim(),
        role: role.trim(),
        refreshToken: auth.refreshToken,
        idToken: auth.idToken,
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
    s.idToken = auth.idToken;
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
      final remoteMeasurements = await _remote.listDocuments(
        'users/${s.uid}/measurements',
        token,
      );
      final known = {for (final m in measurements) m.id};
      for (final doc in remoteMeasurements) {
        if (known.contains(doc['id'])) continue;
        doc['synced'] = true;
        measurements.add(Measurement.fromJson(doc));
      }
      final remoteAlerts = await _remote.listDocuments('users/${s.uid}/alerts', token);
      final knownAlerts = {for (final a in alerts) a.id};
      for (final doc in remoteAlerts) {
        if (knownAlerts.contains(doc['id'])) continue;
        doc['synced'] = true;
        alerts.add(HealthAlert.fromJson(doc));
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
        await _remote.setDocument('users/${s.uid}/measurements/${m.id}', m.toRemote(), token);
        m.synced = true;
      }
      for (final a in alerts.where((a) => !a.synced).toList()) {
        await _remote.setDocument('users/${s.uid}/alerts/${a.id}', a.toRemote(), token);
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
 
  /// Health report as a PDF file, built on the device without any network.
  Uint8List buildReportPdf() {
    final s = session;
    final lines = <PdfLine>[
      PdfLine('AstroCare - ${t('report.title')}', size: 18, bold: true),
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
