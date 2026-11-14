// Reference data embedded in the app: indicators, hazards per environment, synergy rules.
// Ranges are indicative values for healthy adults on Earth, not validated flight rules.
 
import 'models.dart';
 
const List<Indicator> kIndicators = [
  Indicator(
    code: 'heartRate',
    unit: 'bpm',
    zone: BodyZone.heart,
    hazards: [Hazard.gravity, Hazard.environment],
    min: 20,
    max: 250,
    nominalLow: 50,
    nominalHigh: 100,
    attentionLow: 40,
    attentionHigh: 120,
  ),
  Indicator(
    code: 'bpSystolic',
    unit: 'mmHg',
    zone: BodyZone.heart,
    hazards: [Hazard.gravity],
    min: 50,
    max: 260,
    nominalLow: 90,
    nominalHigh: 130,
    attentionLow: 80,
    attentionHigh: 160,
  ),
  Indicator(
    code: 'bpDiastolic',
    unit: 'mmHg',
    zone: BodyZone.heart,
    hazards: [Hazard.gravity],
    min: 30,
    max: 160,
    nominalLow: 60,
    nominalHigh: 85,
    attentionLow: 50,
    attentionHigh: 100,
  ),
  Indicator(
    code: 'spo2',
    unit: '%',
    zone: BodyZone.lungs,
    hazards: [Hazard.environment],
    min: 50,
    max: 100,
    nominalLow: 95,
    nominalHigh: 100,
    attentionLow: 90,
    attentionHigh: 100,
  ),
  Indicator(
    code: 'glucose',
    unit: 'mg/dL',
    zone: BodyZone.abdomen,
    hazards: [Hazard.gravity, Hazard.distance],
    min: 20,
    max: 600,
    nominalLow: 70,
    nominalHigh: 110,
    attentionLow: 55,
    attentionHigh: 180,
  ),
  Indicator(
    code: 'temperature',
    unit: '°C',
    zone: BodyZone.core,
    hazards: [Hazard.environment, Hazard.isolation],
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
    zone: BodyZone.head,
    hazards: [Hazard.isolation, Hazard.distance, Hazard.radiation],
    min: 0,
    max: 16,
    nominalLow: 7,
    nominalHigh: 10,
    attentionLow: 5,
    attentionHigh: 12,
    decimals: 1,
  ),
  Indicator(
    code: 'sleepQuality',
    unit: '/5',
    zone: BodyZone.head,
    hazards: [Hazard.isolation, Hazard.environment],
    min: 1,
    max: 5,
    nominalLow: 3,
    nominalHigh: 5,
    attentionLow: 2,
    attentionHigh: 5,
    isScore: true,
  ),
  Indicator(
    code: 'mood',
    unit: '/5',
    zone: BodyZone.head,
    hazards: [Hazard.isolation, Hazard.distance],
    min: 1,
    max: 5,
    nominalLow: 3,
    nominalHigh: 5,
    attentionLow: 2,
    attentionHigh: 5,
    isScore: true,
  ),
  Indicator(
    code: 'fatigue',
    unit: '/5',
    zone: BodyZone.head,
    hazards: [Hazard.isolation, Hazard.radiation],
    min: 1,
    max: 5,
    nominalLow: 1,
    nominalHigh: 3,
    attentionLow: 1,
    attentionHigh: 4,
    isScore: true,
  ),
  Indicator(
    code: 'weight',
    unit: 'kg',
    zone: BodyZone.legs,
    hazards: [Hazard.gravity],
    min: 30,
    max: 200,
    nominalLow: -5,
    nominalHigh: 5,
    attentionLow: -10,
    attentionHigh: 10,
    decimals: 1,
    relativeToBaseline: true,
  ),
];
 
Indicator indicatorByCode(String code) {
  for (final i in kIndicators) {
    if (i.code == code) return i;
  }
  return kIndicators.first;
}
 
List<Indicator> indicatorsOfZone(BodyZone zone) =>
    kIndicators.where((i) => i.zone == zone).toList();
 
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
    id: 'immune',
    conditions: ['sleepDuration', 'fatigue'],
    hazard: Hazard.radiation,
    level: AlertLevel.attention,
  ),
  SynergyRule(
    id: 'cardio',
    conditions: ['heartRate', 'bpSystolic'],
    hazard: Hazard.gravity,
    level: AlertLevel.attention,
  ),
  SynergyRule(
    id: 'behavior',
    conditions: ['mood', 'sleepQuality'],
    hazard: Hazard.isolation,
    level: AlertLevel.attention,
  ),
  SynergyRule(
    id: 'nutrition',
    conditions: ['weight', 'glucose'],
    hazard: Hazard.gravity,
    level: AlertLevel.attention,
  ),
  SynergyRule(
    id: 'hypoxia',
    conditions: ['spo2', 'heartRate'],
    hazard: Hazard.environment,
    level: AlertLevel.critical,
  ),
];
 
SynergyRule? synergyById(String id) {
  for (final r in kSynergyRules) {
    if (r.id == id) return r;
  }
  return null;
}
