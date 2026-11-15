import '../models/vitals.dart';

/// Where a measurement comes from. Mirrors the `src` taxonomy of the
/// specification (earth / inflight / demo / env), so that a jury can always
/// tell a real ingress point from a simulated one.
enum TelemetryOrigin { demo, earth, inflight, env }

/// Boundary between the clinical engine and the outside world.
///
/// The rest of the app only ever sees a [VitalsRecord]; it never knows whether
/// the value came from a manual entry, a jury scenario, an onboard instrument
/// or a NASA open-data feed. Swapping the source therefore cannot break the
/// engine, the persistence layer or the UI.
abstract class TelemetrySource {
  const TelemetrySource();

  TelemetryOrigin get origin;
  String get label;
  bool get isLive;

  Future<VitalsRecord> readLatest();
}

/// Default source for the hackathon demo: deterministic local telemetry.
/// No network call, works in airplane mode.
class LocalDemoTelemetrySource implements TelemetrySource {
  const LocalDemoTelemetrySource();

  @override
  TelemetryOrigin get origin => TelemetryOrigin.demo;

  @override
  String get label => 'Local demo / jury scenarios';

  @override
  bool get isLive => false;

  @override
  Future<VitalsRecord> readLatest() async {
    final now = DateTime.now();
    return VitalsRecord(
      id: 'DEMO-${now.millisecondsSinceEpoch}',
      timestamp: now,
      heartRate: 72,
      bpSystolic: 120,
      bpDiastolic: 80,
      spo2: 98.2,
      bodyTemp: 36.8,
      sleepHours: 7.2,
      sleepQuality: 88,
      radiationRate: 0.9,
      accumulatedRadiation: 42.5,
      intracranialPressure: 12.0,
      fatigueScore: 2,
      ambientCo2: 2.2,
    );
  }
}

/// Adapter boundary for a real NASA open-data feed (OSDR / HRP / life
/// sciences data). Intentionally dependency-free: adding HTTP here is a
/// single-file change plus one dependency in pubspec.yaml, and it does not
/// touch the engine. A demo build must never call this.
///
/// Suggested datasets: NASA Open Source Data Repository (OSDR) payload
/// telemetry, NASA HRP evidence books for the clinical thresholds, and the
/// Space Radiation / OLTARIS environment for `radiationRate` and `ambientCo2`.
class NasaOpenDataTelemetrySource implements TelemetrySource {
  const NasaOpenDataTelemetrySource({required this.endpoint});

  final Uri endpoint;

  @override
  TelemetryOrigin get origin => TelemetryOrigin.earth;

  @override
  String get label => 'NASA open data (adapter to implement)';

  @override
  bool get isLive => false;

  @override
  Future<VitalsRecord> readLatest() async {
    throw UnimplementedError(
      'Implement the HTTP fetch + field mapping for $endpoint, then set '
      'isLive to true. The rest of the app needs no change.',
    );
  }
}
