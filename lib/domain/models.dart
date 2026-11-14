// Domain model of AstroCare. Pure Dart: no Flutter, no storage, no network.
 
enum AlertLevel { nominal, attention, critical }
 
enum Hazard { radiation, isolation, distance, gravity, environment }
 
enum MissionEnvironment { spacecraft, station, rover, lunarBase, marsBase }
 
enum BodyZone { head, heart, lungs, abdomen, core, legs }
 
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
  final BodyZone zone;
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
 
  /// True when the ranges are a percentage of change against a personal baseline.
  final bool relativeToBaseline;
 
  const Indicator({
    required this.code,
    required this.unit,
    required this.zone,
    required this.hazards,
    required this.min,
    required this.max,
    required this.nominalLow,
    required this.nominalHigh,
    required this.attentionLow,
    required this.attentionHigh,
    this.decimals = 0,
    this.isScore = false,
    this.relativeToBaseline = false,
  });
 
  AlertLevel levelFor(double v) {
    if (v >= nominalLow && v <= nominalHigh) return AlertLevel.nominal;
    if (v >= attentionLow && v <= attentionHigh) return AlertLevel.attention;
    return AlertLevel.critical;
  }
 
  String format(double v) => v.toStringAsFixed(decimals);
}
 
class CrewMember {
  final String id;
  final String name;
  final String role;
  final bool isCommander;
  final double baselineWeight;
 
  const CrewMember({

    required this.id,
    required this.name,
    required this.role,
    this.isCommander = false,
    this.baselineWeight = 0,
  });
 
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role,
    'isCommander': isCommander,
    'baselineWeight': baselineWeight,
  };
 
  factory CrewMember.fromJson(Map<String, dynamic> j) => CrewMember(
    id: '${j['id']}',
    name: '${j['name']}',
    role: '${j['role']}',
    isCommander: j['isCommander'] == true,
    baselineWeight: (j['baselineWeight'] as num?)?.toDouble() ?? 0,
  );
}
 
class Measurement {
  final String id;
  final String memberId;
  final String indicator;
  final double value;
  final DateTime at;
 
  const Measurement({
    required this.id,
    required this.memberId,
    required this.indicator,
    required this.value,
    required this.at,
  });
 
  Map<String, dynamic> toJson() => {
    'id': id,
    'memberId': memberId,
    'indicator': indicator,
    'value': value,
    'at': at.toIso8601String(),
  };
 
  factory Measurement.fromJson(Map<String, dynamic> j) => Measurement(
    id: '${j['id']}',
    memberId: '${j['memberId']}',
    indicator: '${j['indicator']}',
    value: (j['value'] as num?)?.toDouble() ?? 0,
    at: DateTime.tryParse('${j['at']}') ?? DateTime.now(),
  );
}
 
class HealthAlert {
  final String id;
  final String memberId;
  final String indicator;
  final double value;
  final AlertLevel level;
  final AlertCause cause;
 
  /// Id of the synergy rule when the cause is a synergy, otherwise empty.
  final String ruleId;
  final DateTime createdAt;
  AlertStatus status;
 
  HealthAlert({
    required this.id,
    required this.memberId,
    required this.indicator,
    required this.value,
    required this.level,
    required this.cause,
    required this.createdAt,
    this.ruleId = '',
    this.status = AlertStatus.active,
  });
 
  bool get isOpen => status != AlertStatus.resolved;
  Map<String, dynamic> toJson() => {
    'id': id,

    'memberId': memberId,
    'indicator': indicator,
    'value': value,
    'level': level.name,
    'cause': cause.name,
    'ruleId': ruleId,
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
  };
 
  factory HealthAlert.fromJson(Map<String, dynamic> j) => HealthAlert(
    id: '${j['id']}',
    memberId: '${j['memberId']}',
    indicator: '${j['indicator']}',
    value: (j['value'] as num?)?.toDouble() ?? 0,
    level: enumByName(AlertLevel.values, j['level'], AlertLevel.attention),
    cause: enumByName(AlertCause.values, j['cause'], AlertCause.threshold),
    ruleId: '${j['ruleId'] ?? ''}',
    createdAt: DateTime.tryParse('${j['createdAt']}') ?? DateTime.now(),
    status: enumByName(AlertStatus.values, j['status'], AlertStatus.active),
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
