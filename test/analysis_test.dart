import 'package:astrocare/domain/analysis.dart';
import 'package:astrocare/domain/catalog.dart';
import 'package:astrocare/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';
 
void main() {
  const engine = AnalysisEngine(kSynergyRules);
  final allHazards = Hazard.values.toList();
 
  test('thresholds give nominal, attention and critical', () {
    final spo2 = indicatorByCode('spo2');
    expect(engine.thresholdLevel(spo2, 98, 0), AlertLevel.nominal);
    expect(engine.thresholdLevel(spo2, 92, 0), AlertLevel.attention);
    expect(engine.thresholdLevel(spo2, 85, 0), AlertLevel.critical);
  });
 
  test('weight is compared with the personal baseline', () {
    final weight = indicatorByCode('weight');
    expect(engine.thresholdLevel(weight, 70, 70), AlertLevel.nominal);
    expect(engine.thresholdLevel(weight, 65, 70), AlertLevel.attention);
    expect(engine.thresholdLevel(weight, 60, 70), AlertLevel.critical);
  });
 
  test('trend needs enough history and detects a strong deviation', () {
    const detector = TrendDetector();
    expect(detector.zScore(70, [68, 69, 70]), isNull);
    final history = <double>[68, 70, 69, 71, 68, 70, 69, 71, 70, 69];
    expect(detector.isAbnormal(detector.zScore(70, history)), isFalse);
    expect(detector.isAbnormal(detector.zScore(95, history)), isTrue);
  });
 
  test('a synergy raises the level when its hazard is active', () {
    final result = engine.analyze(
      indicator: indicatorByCode('heartRate'),
      value: 112,
      history: const [],
      latest: {'spo2': AlertLevel.attention},
      activeHazards: allHazards,
    );
    expect(result.thresholdLevel, AlertLevel.attention);
    expect(result.level, AlertLevel.critical);
    expect(result.cause, AlertCause.synergy);
  });
 
  test('no synergy when the hazard is not active', () {
    final result = engine.analyze(
      indicator: indicatorByCode('heartRate'),
      value: 112,
      history: const [],
      latest: {'spo2': AlertLevel.attention},
      activeHazards: const [Hazard.radiation],
    );
    expect(result.level, AlertLevel.attention);
    expect(result.cause, AlertCause.threshold);
  });
}
