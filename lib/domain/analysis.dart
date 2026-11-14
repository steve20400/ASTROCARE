// Analysis engine: thresholds, personal trend and synergies. Pure functions, no I/O.
 
import 'dart:math' as math;
 
import 'models.dart';
 
/// Compares a value with the member's own recent history.
class TrendDetector {
  final int windowSize;
  final int minSamples;
  final double zLimit;
 
  const TrendDetector({this.windowSize = 20, this.minSamples = 8, this.zLimit = 3.0});
 
  /// Z-score of [value] against the last [windowSize] values of [history].
  /// Returns null when the history is too short or perfectly flat.
  double? zScore(double value, List<double> history) {
    if (history.length < minSamples) return null;
    final start = history.length > windowSize ? history.length - windowSize : 0;
    final window = history.sublist(start);
    final mean = window.reduce((a, b) => a + b) / window.length;
    double sum = 0;
    for (final v in window) {
      sum += (v - mean) * (v - mean);
    }
    final sd = math.sqrt(sum / window.length);
    if (sd < 1e-9) return null;
    return (value - mean) / sd;
  }
 
  bool isAbnormal(double? z) => z != null && z.abs() > zLimit;
}
 
class AnalysisEngine {
  final List<SynergyRule> rules;
  final TrendDetector trend;
 
  const AnalysisEngine(this.rules, {this.trend = const TrendDetector()});
 
  /// Level given by the reference ranges only.
  AlertLevel thresholdLevel(Indicator indicator, double value, double baseline) {
    if (indicator.relativeToBaseline) {
      if (baseline <= 0) return AlertLevel.nominal;
      final percent = (value - baseline) / baseline * 100;
      return indicator.levelFor(percent);
    }
    return indicator.levelFor(value);
  }
 
  /// Rules whose conditions are all at attention or worse, under an active hazard.
  List<SynergyRule> activeSynergies(Map<String, AlertLevel> latest, List<Hazard> active) {
    final hits = <SynergyRule>[];
    for (final rule in rules) {
      if (!active.contains(rule.hazard)) continue;
      var all = true;
      for (final code in rule.conditions) {
        final level = latest[code];
        if (level == null || level == AlertLevel.nominal) {
          all = false;
          break;
        }
      }
      if (all) hits.add(rule);
    }
    return hits;
  }
 
  /// Full analysis of one new measurement.
  /// [history] holds the earlier values of the same indicator, oldest first.
  /// [latest] holds the current level of the member's other indicators.
  AnalysisResult analyze({
    required Indicator indicator,
    required double value,
    required List<double> history,
    required Map<String, AlertLevel> latest,
    required List<Hazard> activeHazards,
    double baseline = 0,
  }) {

    final byThreshold = thresholdLevel(indicator, value, baseline);
    final z = trend.zScore(value, history);
    final byTrend = trend.isAbnormal(z) ? AlertLevel.attention : AlertLevel.nominal;
 
    final state = Map<String, AlertLevel>.from(latest);
    state[indicator.code] = maxLevel(byThreshold, byTrend);
    final hits = activeSynergies(
      state,
      activeHazards,
    ).where((r) => r.conditions.contains(indicator.code)).toList();
    var bySynergy = AlertLevel.nominal;
    for (final r in hits) {
      bySynergy = maxLevel(bySynergy, r.level);
    }
 
    final level = maxLevel(maxLevel(byThreshold, byTrend), bySynergy);
    AlertCause cause;
    if (bySynergy.index > byThreshold.index && bySynergy.index > byTrend.index) {
      cause = AlertCause.synergy;
    } else if (byThreshold.index >= byTrend.index) {
      cause = AlertCause.threshold;
    } else {
      cause = AlertCause.trend;
    }
 
    return AnalysisResult(
      level: level,
      thresholdLevel: byThreshold,
      zScore: z,
      synergies: hits,
      cause: cause,
    );
  }
}
