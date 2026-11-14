// Application state and use cases. The UI listens to [appState] and calls its methods.
 
import 'dart:math' as math;
 
import 'package:flutter/foundation.dart';
 
import '../data/store.dart';
import '../domain/analysis.dart';
import '../domain/catalog.dart';
import '../domain/models.dart';
import '../l10n/strings.dart';
 
final AppState appState = AppState();
 
/// Translates [key] in the current language. "{0}", "{1}"... are replaced by [args].
String t(String key, [List<Object> args = const []]) => translate(appState.lang, key, args);
 
class AppState extends ChangeNotifier {
  final LocalStore _store = LocalStore();
  final AnalysisEngine _engine = const AnalysisEngine(kSynergyRules);
 
  bool loaded = false;
  String lang = 'en';
  bool darkMode = false;
  MissionEnvironment environment = MissionEnvironment.spacecraft;
  List<CrewMember> members = [];
  List<Measurement> measurements = [];
  List<HealthAlert> alerts = [];
 
  /// Reminder period in hours per indicator code. 0 means off.
  Map<String, int> reminders = {};
  String currentMemberId = '';
  int _seq = 0;
 
  // ------------------------------------------------------------------ loading
 
  Future<void> load() async {
    final data = await _store.read();
    if (data == null) {
      _seed();
    } else {
      try {
        _fromJson(data);
      } catch (_) {
        _seed();
      }
    }
    if (members.isEmpty) _seed();
    if (!members.any((m) => m.id == currentMemberId)) currentMemberId = members.first.id;
    loaded = true;
    notifyListeners();
  }
 
  void _seed() {
    members = const [
      CrewMember(
        id: 'c1',
        name: 'A. Ngono',
        role: 'Commander',
        isCommander: true,
        baselineWeight: 72,
      ),
      CrewMember(id: 'c2', name: 'M. Laurent', role: 'Pilot', baselineWeight: 80),
      CrewMember(id: 'c3', name: 'S. Okafor', role: 'Flight engineer', baselineWeight: 65),
      CrewMember(id: 'c4', name: 'L. Tremblay', role: 'Medical officer', baselineWeight: 58),
    ];
    measurements = [];
    alerts = [];
    reminders = {for (final i in kIndicators) i.code: 24};
    currentMemberId = 'c1';
  }
 
  Map<String, dynamic> _toJson() => {
    'lang': lang,
    'darkMode': darkMode,
    'environment': environment.name,
    'currentMemberId': currentMemberId,
    'members': members.map((m) => m.toJson()).toList(),

    'measurements': measurements.map((m) => m.toJson()).toList(),
    'alerts': alerts.map((a) => a.toJson()).toList(),
    'reminders': reminders,
  };
 
  void _fromJson(Map<String, dynamic> j) {
    lang = j['lang'] == 'fr' ? 'fr' : 'en';
    darkMode = j['darkMode'] == true;
    environment = enumByName(
      MissionEnvironment.values,
      j['environment'],
      MissionEnvironment.spacecraft,
    );
    currentMemberId = '${j['currentMemberId'] ?? ''}';
    members = [
      for (final e in (j['members'] as List? ?? const []))
        CrewMember.fromJson(Map<String, dynamic>.from(e as Map)),
    ];
    measurements = [
      for (final e in (j['measurements'] as List? ?? const []))
        Measurement.fromJson(Map<String, dynamic>.from(e as Map)),
    ];
    alerts = [
      for (final e in (j['alerts'] as List? ?? const []))
        HealthAlert.fromJson(Map<String, dynamic>.from(e as Map)),
    ];
    reminders = {for (final i in kIndicators) i.code: 24};
    final r = j['reminders'];
    if (r is Map) {
      r.forEach((k, v) {
        if (v is num) reminders['$k'] = v.toInt();
      });
    }
  }
 
  void _persist() {
    _store.write(_toJson());
  }
 
  void _changed() {
    _persist();
    notifyListeners();
  }
 
  String _newId(String prefix) {
    _seq++;
    return '$prefix${DateTime.now().microsecondsSinceEpoch}_$_seq';
  }
 
  // ------------------------------------------------------------------ queries
 
  CrewMember get currentMember => memberById(currentMemberId);
 
  CrewMember memberById(String id) {
    for (final m in members) {
      if (m.id == id) return m;
    }
    return members.first;
  }
 
  List<Hazard> get activeHazards => activeHazardsOf(environment);
 
  /// Measurements of one indicator for one member, oldest first.
  List<Measurement> history(String memberId, String code) {
    final list = measurements
        .where((m) => m.memberId == memberId && m.indicator == code)
        .toList();
    list.sort((a, b) => a.at.compareTo(b.at));
    return list;
  }
 
  Measurement? latest(String memberId, String code) {
    Measurement? best;
    for (final m in measurements) {
      if (m.memberId != memberId || m.indicator != code) continue;
      if (best == null || m.at.isAfter(best.at)) best = m;
    }
    return best;
  }
 
  AlertLevel levelOfValue(String memberId, Indicator indicator, double value) =>
      _engine.thresholdLevel(indicator, value, memberById(memberId).baselineWeight);
  /// Level of the latest value of an indicator, or null when never measured.
  AlertLevel? levelOf(String memberId, String code) {

    final m = latest(memberId, code);
    if (m == null) return null;
    return levelOfValue(memberId, indicatorByCode(code), m.value);
  }
 
  Map<String, AlertLevel> latestLevels(String memberId) {
    final map = <String, AlertLevel>{};
    for (final i in kIndicators) {
      final l = levelOf(memberId, i.code);
      if (l != null) map[i.code] = l;
    }
    return map;
  }
 
  List<SynergyRule> activeSynergies(String memberId) =>
      _engine.activeSynergies(latestLevels(memberId), activeHazards);
 
  /// Overall level of a member: worst indicator, raised by active synergies.
  /// Null when the member has no measurement yet.
  AlertLevel? memberLevel(String memberId) {
    final levels = latestLevels(memberId);
    if (levels.isEmpty) return null;
    var worst = AlertLevel.nominal;
    for (final l in levels.values) {
      worst = maxLevel(worst, l);
    }
    for (final r in activeSynergies(memberId)) {
      worst = maxLevel(worst, r.level);
    }
    return worst;
  }
 
  AlertLevel? zoneLevel(String memberId, BodyZone zone) {
    AlertLevel? worst;
    for (final i in indicatorsOfZone(zone)) {
      final l = levelOf(memberId, i.code);
      if (l == null) continue;
      worst = worst == null ? l : maxLevel(worst, l);
    }
    return worst;
  }
 
  /// Open alerts, newest first. With [memberId] null, alerts of the whole crew.
  List<HealthAlert> openAlerts([String? memberId]) {
    final list = alerts
        .where((a) => a.isOpen && (memberId == null || a.memberId == memberId))
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }
 
  List<HealthAlert> allAlerts([String? memberId]) {
    final list = alerts.where((a) => memberId == null || a.memberId == memberId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }
 
  HealthAlert? alertById(String id) {
    for (final a in alerts) {
      if (a.id == id) return a;
    }
    return null;
  }
 
  /// Indicators whose reminder period has elapsed for this member.
  List<Indicator> dueReminders(String memberId) {
    final now = DateTime.now();
    final due = <Indicator>[];
    for (final i in kIndicators) {
      final hours = reminders[i.code] ?? 0;
      if (hours <= 0) continue;
      final last = latest(memberId, i.code);
      if (last == null || now.difference(last.at).inHours >= hours) due.add(i);
    }
    return due;
  }
  /// Number of consecutive days with at least one measurement, ending today or yesterday.
  int streak(String memberId) {
    final days = <String>{};
    for (final m in measurements) {
      if (m.memberId == memberId) days.add(_dayKey(m.at));
    }
    var day = DateTime.now();
    if (!days.contains(_dayKey(day))) day = day.subtract(const Duration(days: 1));

    var count = 0;
    while (days.contains(_dayKey(day))) {
      count++;
      day = day.subtract(const Duration(days: 1));
    }
    return count;
  }
 
  String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
 
  // ----------------------------------------------------------------- commands
 
  /// Records a measurement, analyses it and raises an alert when needed.
  AnalysisResult record(String code, double value, {String? memberId, DateTime? at}) {
    final member = memberById(memberId ?? currentMemberId);
    final indicator = indicatorByCode(code);
    final previous = history(member.id, code).map((m) => m.value).toList();
    final others = latestLevels(member.id)..remove(code);
 
    final measurement = Measurement(
      id: _newId('m'),
      memberId: member.id,
      indicator: code,
      value: value,
      at: at ?? DateTime.now(),
    );
    measurements.add(measurement);
 
    final result = _engine.analyze(
      indicator: indicator,
      value: value,
      history: previous,
      latest: others,
      activeHazards: activeHazards,
      baseline: member.baselineWeight,
    );
 
    // A new measurement supersedes the open alerts of the same indicator.
    for (final a in alerts) {
      if (a.memberId == member.id && a.indicator == code && a.isOpen) {
        a.status = AlertStatus.resolved;
      }
    }
    if (result.level != AlertLevel.nominal) {
      alerts.add(
        HealthAlert(
          id: _newId('a'),
          memberId: member.id,
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
    return result;
  }
 
  void acknowledge(String alertId) {
    final a = alertById(alertId);
    if (a == null || a.status != AlertStatus.active) return;
    a.status = AlertStatus.acknowledged;
    _changed();
  }
 
  void selectMember(String id) {
    currentMemberId = id;
    _changed();
  }
 
  void setLanguage(String value) {
    lang = value == 'fr' ? 'fr' : 'en';
    _changed();
  }
 
  void setDarkMode(bool value) {
    darkMode = value;
    _changed();
  }

  void setEnvironment(MissionEnvironment value) {
    environment = value;
    _changed();
  }
 
  void setReminder(String code, int hours) {
    reminders[code] = hours;
    _changed();
  }
 
  void resetAll() {
    final keepLang = lang;
    final keepDark = darkMode;
    _seed();
    lang = keepLang;
    darkMode = keepDark;
    environment = MissionEnvironment.spacecraft;
    _changed();
  }
 
  /// Fills the app with ten days of simulated data and four crew profiles.
  void loadDemo() {
    final keepLang = lang;
    final keepDark = darkMode;
    _seed();
    lang = keepLang;
    darkMode = keepDark;
    environment = MissionEnvironment.spacecraft;
 
    const base = <String, double>{
      'heartRate': 68,
      'bpSystolic': 118,
      'bpDiastolic': 76,
      'spo2': 98,
      'glucose': 92,
      'temperature': 36.7,
      'sleepDuration': 7.6,
      'sleepQuality': 4,
      'mood': 4,
      'fatigue': 2,
    };
    const spread = <String, double>{
      'heartRate': 4,
      'bpSystolic': 4,
      'bpDiastolic': 3,
      'spo2': 0.8,
      'glucose': 5,
      'temperature': 0.2,
      'sleepDuration': 0.4,
      'sleepQuality': 0.6,
      'mood': 0.6,
      'fatigue': 0.6,
    };
    final now = DateTime.now();
    var k = 0;
    for (final member in members) {
      for (var d = 9; d >= 1; d--) {
        final at = now.subtract(Duration(days: d, hours: 1));
        for (final i in kIndicators) {
          k++;
          double v;
          if (i.code == 'weight') {
            v = member.baselineWeight - (9 - d) * 0.08 + math.sin(k * 1.3) * 0.2;
          } else {
            v = (base[i.code] ?? 0) + math.sin(k * 1.7) * (spread[i.code] ?? 0);
          }
          if (i.isScore) v = v.roundToDouble().clamp(1, 5).toDouble();
          v = double.parse(v.toStringAsFixed(i.decimals));
          measurements.add(
            Measurement(
              id: _newId('m'),
              memberId: member.id,
              indicator: i.code,
              value: v,
              at: at,
            ),
          );
        }
      }
    }
 
    // Today's measurements: one healthy profile and three profiles that trigger alerts.
    const today = <String, Map<String, double>>{
      'c1': {'heartRate': 66, 'bpSystolic': 117, 'spo2': 98, 'sleepDuration': 7.8, 'mood': 4},

      'c2': {'sleepDuration': 5.2, 'sleepQuality': 2, 'mood': 2, 'fatigue': 4, 'heartRate': 74},
      'c3': {'bpSystolic': 138, 'spo2': 91, 'heartRate': 112, 'temperature': 36.9},
      'c4': {'temperature': 38.1, 'glucose': 62, 'weight': 54.2, 'mood': 3},
    };
    today.forEach((memberId, values) {
      values.forEach((code, value) {
        record(code, value, memberId: memberId);
      });
    });
    currentMemberId = 'c1';
    _changed();
  }
 
  // ------------------------------------------------------------------- report
 
  String _two(int n) => n < 10 ? '0$n' : '$n';
 
  String formatDate(DateTime d) =>
      '${_two(d.day)}/${_two(d.month)}/${d.year} ${_two(d.hour)}:${_two(d.minute)}';
 
  /// Plain-text health report for the flight surgeons, built entirely on the device.
  String buildReport() {
    final b = StringBuffer();
    b.writeln('ASTROCARE - ${t('report.title')}');
    b.writeln('${t('report.generated')}: ${formatDate(DateTime.now())}');
    b.writeln('${t('settings.environment')}: ${t('env.${environment.name}')}');
    b.writeln('');
    for (final m in members) {
      final level = memberLevel(m.id);
      b.writeln('== ${m.name} (${m.role}) ==');
      b.writeln(
        '${t('report.status')}: ${t(level == null ? 'level.nodata' : 'level.${level.name}')}',
      );
      for (final i in kIndicators) {
        final last = latest(m.id, i.code);
        if (last == null) continue;
        final l = levelOfValue(m.id, i, last.value);
        b.writeln(
          '- ${t('ind.${i.code}.name')}: ${i.format(last.value)} ${i.unit}'
          ' [${t('level.${l.name}')}] ${formatDate(last.at)}',
        );
      }
      final syn = activeSynergies(m.id);
      for (final r in syn) {
        b.writeln('* ${t('synergy.title')}: ${t('syn.${r.id}.name')}');
      }
      final open = openAlerts(m.id);
      b.writeln('${t('report.openAlerts')}: ${open.length}');
      for (final a in open) {
        b.writeln(
          '> ! ${t('ind.${a.indicator}.name')} - ${t('level.${a.level.name}')}'
          ' - ${t('status.${a.status.name}')}',
        );
      }
      b.writeln('');
    }
    b.writeln(t('about.disclaimer'));
    return b.toString();
  }
}
