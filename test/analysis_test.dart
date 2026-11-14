import 'dart:convert';
 
import 'package:astrocare/data/remote_api.dart';
import 'package:astrocare/data/simple_pdf.dart';
import 'package:astrocare/domain/analysis.dart';
import 'package:astrocare/domain/catalog.dart';
import 'package:astrocare/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';
 
void main() {
  const engine = AnalysisEngine(kSynergyRules);
  final allHazards = Hazard.values.toList();
 
  test('thresholds give nominal, attention and critical', () {
    final heart = indicatorByCode('heartRate');
    expect(heart.levelFor(70), AlertLevel.nominal);
    expect(heart.levelFor(110), AlertLevel.attention);
    expect(heart.levelFor(150), AlertLevel.critical);
  });
 
  test('trend needs enough history and detects a strong deviation', () {
    const detector = TrendDetector();
    expect(detector.zScore(70, [68, 69, 70]), isNull);
    final history = <double>[68, 70, 69, 71, 68, 70, 69, 71, 70, 69];
    expect(detector.isAbnormal(detector.zScore(70, history)), isFalse);
    expect(detector.isAbnormal(detector.zScore(95, history)), isTrue);
  });
 
  test('a combined risk raises the level when its hazard is active', () {
    final result = engine.analyze(
      indicator: indicatorByCode('heartRate'),
      value: 112,
      history: const [],
      latest: {'temperature': AlertLevel.attention},
      activeHazards: allHazards,
    );
    expect(result.thresholdLevel, AlertLevel.attention);
    expect(result.level, AlertLevel.critical);
    expect(result.cause, AlertCause.synergy);
  });
  test('no combined risk when the hazard is not active', () {
    final result = engine.analyze(
      indicator: indicatorByCode('heartRate'),
      value: 112,
      history: const [],
      latest: {'temperature': AlertLevel.attention},
      activeHazards: const [Hazard.radiation],
    );
    expect(result.level, AlertLevel.attention);
    expect(result.cause, AlertCause.threshold);
  });
 
  test('online database fields survive an encode and decode round trip', () {
    final at = DateTime(2026, 11, 14, 22, 30);
    final m = Measurement(id: 'm1', indicator: 'mood', value: 4, at: at);
    final encoded = RemoteApi.encodeFields(m.toRemote());
    final decoded = RemoteApi.decodeFields(jsonDecode(jsonEncode(encoded)));
    decoded['id'] = 'm1';
    final back = Measurement.fromJson(decoded);
    expect(back.indicator, 'mood');
    expect(back.value, 4);
    expect(back.at.isAtSameMomentAs(at), isTrue);
  });
 
  test('the PDF writer produces a well-formed file', () {
    final bytes = SimplePdf.build([
      const PdfLine('AstroCare - Rapport de santé', size: 18, bold: true),
      for (var i = 0; i < 120; i++) PdfLine('Ligne $i : fréquence cardiaque (72 bpm)'),
    ]);
    final text = latin1.decode(bytes);
    expect(text.startsWith('%PDF-1.4'), isTrue);
    expect(text.trimRight().endsWith('%%EOF'), isTrue);
    expect('/Type /Page '.allMatches(text).length, greaterThan(1));
  });
}
