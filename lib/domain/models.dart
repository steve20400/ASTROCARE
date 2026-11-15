// Domain model of AstroCare. Pure Dart: no Flutter, no storage, no network.
 
enum AlertLevel { nominal, attention, critical }
 
enum Hazard { radiation, isolation, distance, gravity, environment }
 
enum MissionEnvironment { spacecraft, station, rover, lunarBase, marsBase }
 
enum AlertCause { threshold, trend, synergy }
 
enum AlertStatus { active, acknowledged, resolved }
 
AlertLevel maxLevel(AlertLevel a, AlertLevel b) => a.index >= b.index ? a : b;
 
T enumByName<T extends Enum>(List<T> values, Object? name, T fallback) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}
 
/// A health indicator and its reference ranges.
/// Inside [nominalLow, nominalHigh] the level is nominal; inside
/// [attentionLow, attentionHigh] it is attention; outside it is critical.
class Indicator {
  final String code;
  final String unit;
  final List<Hazard> hazards;
  final double min;
  final double max;
  final double nominalLow;
  final double nominalHigh;
  final double attentionLow;
  final double attentionHigh;
  final int decimals;
 
  /// True for a 1 to 5 self-assessment score.
  final bool isScore;
 
  const Indicator({
    required this.code,
    required this.unit,
    required this.hazards,
    required this.min,
    required this.max,
    required this.nominalLow,
    required this.nominalHigh,
    required this.attentionLow,
    required this.attentionHigh,
    this.decimals = 0,
    this.isScore = false,
  });
 
  AlertLevel levelFor(double v) {
    if (v >= nominalLow && v <= nominalHigh) return AlertLevel.nominal;
    if (v >= attentionLow && v <= attentionHigh) return AlertLevel.attention;
    return AlertLevel.critical;
  }
 
  String format(double v) => v.toStringAsFixed(decimals);
}
 
class Measurement {
  final String id;
  final String indicator;
  final double value;
  final DateTime at;
 
  /// True once the measurement is saved in the online database.
  bool synced;
 
  Measurement({
    required this.id,
    required this.indicator,
    required this.value,
    required this.at,
    this.synced = false,
  });

  /// Row stored in the online table "measurements".
  Map<String, dynamic> toRemote(String userId) => {
    'id': id,
    'user_id': userId,
    'indicator': indicator,
    'value': value,
    'at': at.toUtc().toIso8601String(),
  };
 
  factory Measurement.fromRemote(Map<String, dynamic> row) => Measurement(
    id: '${row['id']}',
    indicator: '${row['indicator']}',
    value: (row['value'] as num?)?.toDouble() ?? 0,
    at: (DateTime.tryParse('${row['at']}') ?? DateTime.now()).toLocal(),
    synced: true,
  );
 
  Map<String, dynamic> toJson() => {
    'id': id,
    'indicator': indicator,
    'value': value,
    'at': at.toIso8601String(),
    'synced': synced,
  };
 
  factory Measurement.fromJson(Map<String, dynamic> j) => Measurement(
    id: '${j['id']}',
    indicator: '${j['indicator']}',
    value: (j['value'] as num?)?.toDouble() ?? 0,
    at: j['at'] is DateTime
        ? j['at'] as DateTime
        : (DateTime.tryParse('${j['at']}') ?? DateTime.now()),
    synced: j['synced'] == true,
  );
}
 
class HealthAlert {
  final String id;
  final String indicator;
  final double value;
  final AlertLevel level;
  final AlertCause cause;
 
  /// Id of the synergy rule when the cause is a synergy, otherwise empty.
  final String ruleId;
  final DateTime createdAt;
  AlertStatus status;
  bool synced;
 
  HealthAlert({
    required this.id,
    required this.indicator,
    required this.value,
    required this.level,
    required this.cause,
    required this.createdAt,
    this.ruleId = '',
    this.status = AlertStatus.active,
    this.synced = false,
  });
 
  bool get isOpen => status != AlertStatus.resolved;
 
  /// Row stored in the online table "alerts".
  Map<String, dynamic> toRemote(String userId) => {
    'id': id,
    'user_id': userId,
    'indicator': indicator,
    'value': value,
    'level': level.name,
    'cause': cause.name,
    'rule_id': ruleId,
    'status': status.name,
    'created_at': createdAt.toUtc().toIso8601String(),
  };
 
  factory HealthAlert.fromRemote(Map<String, dynamic> row) => HealthAlert(
    id: '${row['id']}',
    indicator: '${row['indicator']}',
    value: (row['value'] as num?)?.toDouble() ?? 0,
    level: enumByName(AlertLevel.values, row['level'], AlertLevel.attention),
    cause: enumByName(AlertCause.values, row['cause'], AlertCause.threshold),
    ruleId: '${row['rule_id'] ?? ''}',
    createdAt: (DateTime.tryParse('${row['created_at']}') ?? DateTime.now()).toLocal(),

    status: enumByName(AlertStatus.values, row['status'], AlertStatus.active),
    synced: true,
  );
 
  Map<String, dynamic> toJson() => {
    'id': id,
    'indicator': indicator,
    'value': value,
    'level': level.name,
    'cause': cause.name,
    'ruleId': ruleId,
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
    'synced': synced,
  };
 
  factory HealthAlert.fromJson(Map<String, dynamic> j) => HealthAlert(
    id: '${j['id']}',
    indicator: '${j['indicator']}',
    value: (j['value'] as num?)?.toDouble() ?? 0,
    level: enumByName(AlertLevel.values, j['level'], AlertLevel.attention),
    cause: enumByName(AlertCause.values, j['cause'], AlertCause.threshold),
    ruleId: '${j['ruleId'] ?? ''}',
    createdAt: j['createdAt'] is DateTime
        ? j['createdAt'] as DateTime
        : (DateTime.tryParse('${j['createdAt']}') ?? DateTime.now()),
    status: enumByName(AlertStatus.values, j['status'], AlertStatus.active),
    synced: j['synced'] == true,
  );
}
 
/// A combination of indicators that, under a spaceflight hazard, raises the risk.
/// The rule is active when every indicator in [conditions] is at attention or worse
/// and [hazard] is active in the current mission environment.
class SynergyRule {
  final String id;
  final List<String> conditions;
  final Hazard hazard;
  final AlertLevel level;
 
  const SynergyRule({
    required this.id,
    required this.conditions,
    required this.hazard,
    required this.level,
  });
}
 
class AnalysisResult {
  final AlertLevel level;
  final AlertLevel thresholdLevel;
 
  /// Z-score against the personal baseline, or null when there is too little history.
  final double? zScore;
  final List<SynergyRule> synergies;
  final AlertCause cause;
 
  const AnalysisResult({
    required this.level,
    required this.thresholdLevel,
    required this.zScore,
    required this.synergies,
    required this.cause,
  });
}
 
/// The signed-in astronaut. Kept on the device so the app opens without any network.
class Session {
  final String uid;
  final String email;
  String name;
  String role;
  String refreshToken;
  String idToken;
  DateTime idTokenExpiry;
 
  Session({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.refreshToken,
    required this.idToken,
    required this.idTokenExpiry,

  });
 
  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'name': name,
    'role': role,
    'refreshToken': refreshToken,
    'idToken': idToken,
    'idTokenExpiry': idTokenExpiry.toIso8601String(),
  };
 
  factory Session.fromJson(Map<String, dynamic> j) => Session(
    uid: '${j['uid']}',
    email: '${j['email']}',
    name: '${j['name'] ?? ''}',
    role: '${j['role'] ?? ''}',
    refreshToken: '${j['refreshToken'] ?? ''}',
    idToken: '${j['idToken'] ?? ''}',
    idTokenExpiry: DateTime.tryParse('${j['idTokenExpiry']}') ?? DateTime(2000),
  );
}
 
/// A health report kept on board until the link to the ground carries it.
class Report {
  final String id;
  final int number;
  final DateTime createdAt;
 
  /// True when the app created it by itself after the waiting time.
  final bool auto;
 
  /// Number of new measurements it contains.
  final int newCount;
 
  /// The PDF file, in base 64.
  final String pdf;
 
  bool sent;
  DateTime? sentAt;
  int packets;
  int resent;
 
  /// Start of the SHA-256 fingerprint of the PDF.
  String digest;
 
  Report({
    required this.id,
    required this.number,
    required this.createdAt,
    required this.auto,
    required this.newCount,
    required this.pdf,
    this.sent = false,
    this.sentAt,
    this.packets = 0,
    this.resent = 0,
    this.digest = '',
  });
 
  String get fileName => 'astrocare_report_${number.toString().padLeft(4, '0')}.pdf';
 
  Map<String, dynamic> toJson() => {
    'id': id,
    'number': number,
    'createdAt': createdAt.toIso8601String(),
    'auto': auto,
    'newCount': newCount,
    'pdf': pdf,
    'sent': sent,
    'sentAt': sentAt?.toIso8601String(),
    'packets': packets,
    'resent': resent,
    'digest': digest,
  };
 
  factory Report.fromJson(Map<String, dynamic> j) => Report(
    id: '${j['id']}',
    number: (j['number'] as num?)?.toInt() ?? 0,
    createdAt: DateTime.tryParse('${j['createdAt']}') ?? DateTime.now(),
    auto: j['auto'] == true,
    newCount: (j['newCount'] as num?)?.toInt() ?? 0,
    pdf: '${j['pdf'] ?? ''}',
    sent: j['sent'] == true,

    sentAt: DateTime.tryParse('${j['sentAt']}'),
    packets: (j['packets'] as num?)?.toInt() ?? 0,
    resent: (j['resent'] as num?)?.toInt() ?? 0,
    digest: '${j['digest'] ?? ''}',
  );
}
