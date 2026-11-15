// Reference data embedded in the app: four indicators, hazards per environment, two
// combined risks. Ranges are indicative values for healthy adults on Earth.
 
import 'models.dart';
 
const List<Indicator> kIndicators = [
  Indicator(
    code: 'heartRate',
    unit: 'bpm',
    hazards: [Hazard.gravity, Hazard.environment],
    min: 20,
    max: 250,
    nominalLow: 50,
    nominalHigh: 100,
    attentionLow: 40,
    attentionHigh: 120,
  ),
  Indicator(
    code: 'temperature',
    unit: '°C',
    hazards: [Hazard.environment, Hazard.radiation],
    min: 30,
    max: 43,
    nominalLow: 36.0,
    nominalHigh: 37.5,
    attentionLow: 35.0,
    attentionHigh: 38.5,
    decimals: 1,
  ),
  Indicator(
    code: 'sleepDuration',
    unit: 'h',
    hazards: [Hazard.isolation, Hazard.distance],
    min: 0,
    max: 16,
    nominalLow: 7,
    nominalHigh: 10,
    attentionLow: 5,
    attentionHigh: 12,
    decimals: 1,
  ),
  Indicator(
    code: 'mood',
    unit: '/5',
    hazards: [Hazard.isolation, Hazard.distance],
    min: 1,
    max: 5,
    nominalLow: 3,
    nominalHigh: 5,
    attentionLow: 2,
    attentionHigh: 5,
    isScore: true,
  ),
];
 
Indicator indicatorByCode(String code) {
  for (final i in kIndicators) {
    if (i.code == code) return i;
  }
  return kIndicators.first;
}
 
/// Hazards that dominate in each mission environment (NASA HRP "RIDGE" hazards).
const Map<MissionEnvironment, List<Hazard>> kActiveHazards = {
  MissionEnvironment.spacecraft: [
    Hazard.radiation,
    Hazard.isolation,
    Hazard.distance,
    Hazard.gravity,
    Hazard.environment,
  ],
  MissionEnvironment.station: [Hazard.isolation, Hazard.gravity, Hazard.environment],
  MissionEnvironment.rover: [Hazard.radiation, Hazard.gravity, Hazard.environment],
  MissionEnvironment.lunarBase: [
    Hazard.radiation,
    Hazard.isolation,
    Hazard.gravity,
    Hazard.environment,

  ],
  MissionEnvironment.marsBase: [
    Hazard.radiation,
    Hazard.isolation,
    Hazard.distance,
    Hazard.gravity,
    Hazard.environment,
  ],
};
 
List<Hazard> activeHazardsOf(MissionEnvironment env) => kActiveHazards[env] ?? const [];
 
const List<SynergyRule> kSynergyRules = [
  SynergyRule(
    id: 'behavior',
    conditions: ['mood', 'sleepDuration'],
    hazard: Hazard.isolation,
    level: AlertLevel.attention,
  ),
  SynergyRule(
    id: 'infection',
    conditions: ['temperature', 'heartRate'],
    hazard: Hazard.environment,
    level: AlertLevel.critical,
  ),
];
 
/// NASA Human Research Program risk each indicator relates to.
/// Official names, from https://www.nasa.gov/hrp/risks/
const Map<String, String> kNasaRisk = {
  'heartRate': 'Risk of Cardiovascular Adaptations',
  'temperature': 'Risk of Altered Immune System Responses',
  'sleepDuration': 'Risk of Inadequate Sleep and Irregular Schedules',
  'mood': 'Risk of Behavioral Changes and Psychiatric Disorders',
};
 
/// First-aid situations of the built-in guide: indicator code, then side.
const List<List<String>> kAidCases = [
  ['heartRate', 'high'],
  ['heartRate', 'low'],
  ['temperature', 'high'],
  ['temperature', 'low'],
  ['sleepDuration', 'low'],
  ['sleepDuration', 'high'],
  ['mood', 'low'],
];
 
/// Side of the nominal range the value falls on: "low" or "high".
/// A value inside the range (trend alert) is compared with the middle of the range.
String aidSide(Indicator i, double value) {
  if (value < i.nominalLow) return 'low';
  if (value > i.nominalHigh) return 'high';
  return value < (i.nominalLow + i.nominalHigh) / 2 ? 'low' : 'high';
}
 
SynergyRule? synergyById(String id) {
  for (final r in kSynergyRules) {
    if (r.id == id) return r;
  }
  return null;
}
