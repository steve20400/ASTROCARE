import 'dart:math' as math;

/// The six physiological regions covered by a full 360 degrees scan pass.
/// Keep this order in sync with the organ inspector in body_twin_screen.dart.
const List<String> kTwinRegions = <String>[
  'brain',
  'eyes',
  'cardio',
  'lungs',
  'immune',
  'musculo',
];

/// Human-readable labels used by the twin ribbon and the scan legend.
const Map<String, String> kTwinRegionLabels = <String, String>{
  'brain': 'NEURO-CNS',
  'eyes': 'OPTIC SANS',
  'cardio': 'CARDIO-HEMO',
  'lungs': 'PULMONARY',
  'immune': 'IMMUNE-GENOME',
  'musculo': 'OSTEOMUSCULAR',
};

/// One anatomical volume expressed in "body units" (0..320, top to bottom).
///
/// [width] is the frontal (X) extent and [depth] the sagittal (Z) extent.
/// A volume whose [region] is 'frame' is silhouette scaffolding: it is drawn
/// but is neither clickable nor highlighted.
class TwinVolume {
  final String region;
  final double x;
  final double y;
  final double z;
  final double width;
  final double depth;
  final double height;
  final bool isFrame;

  const TwinVolume({
    required this.region,
    required this.x,
    required this.y,
    required this.z,
    required this.width,
    required this.depth,
    required this.height,
    this.isFrame = false,
  });

  bool get isRegion => !isFrame && region != 'frame';
}

/// Body geometry. Depths are deliberately realistic (torso 42 x 26 rather
/// than 42 x 12) so a 90 degrees profile still reads as a human body instead
/// of a plank. This is the "volumetric, not flat" decision of the design review.
const List<TwinVolume> kTwinVolumes = <TwinVolume>[
  // ---- Silhouette scaffolding -------------------------------------------
  TwinVolume(
    region: 'frame',
    x: 0,
    y: 24,
    z: 0,
    width: 30,
    depth: 32,
    height: 40,
    isFrame: true,
  ),
  TwinVolume(
    region: 'frame',
    x: 0,
    y: 49,
    z: 0,
    width: 13,
    depth: 13,
    height: 12,
    isFrame: true,
  ),
  TwinVolume(
    region: 'frame',
    x: 0,
    y: 82,
    z: 0,
    width: 42,
    depth: 26,
    height: 52,
    isFrame: true,
  ),
  TwinVolume(
    region: 'frame',
    x: 0,
    y: 124,
    z: 0,
    width: 34,
    depth: 24,
    height: 34,
    isFrame: true,
  ),
  TwinVolume(
    region: 'frame',
    x: 0,
    y: 152,
    z: 0,
    width: 36,
    depth: 24,
    height: 24,
    isFrame: true,
  ),
  TwinVolume(
    region: 'frame',
    x: -32,
    y: 96,
    z: 0,
    width: 11,
    depth: 12,
    height: 88,
    isFrame: true,
  ),
  TwinVolume(
    region: 'frame',
    x: 32,
    y: 96,
    z: 0,
    width: 11,
    depth: 12,
    height: 88,
    isFrame: true,
  ),
  TwinVolume(
    region: 'frame',
    x: -11,
    y: 197,
    z: 0,
    width: 15,
    depth: 17,
    height: 70,
    isFrame: true,
  ),
  TwinVolume(
    region: 'frame',
    x: 11,
    y: 197,
    z: 0,
    width: 15,
    depth: 17,
    height: 70,
    isFrame: true,
  ),
  TwinVolume(
    region: 'frame',
    x: -11,
    y: 258,
    z: 0,
    width: 12,
    depth: 14,
    height: 56,
    isFrame: true,
  ),
  TwinVolume(
    region: 'frame',
    x: 11,
    y: 258,
    z: 0,
    width: 12,
    depth: 14,
    height: 56,
    isFrame: true,
  ),
  TwinVolume(
    region: 'frame',
    x: -11,
    y: 291,
    z: 6,
    width: 14,
    depth: 26,
    height: 12,
    isFrame: true,
  ),
  TwinVolume(
    region: 'frame',
    x: 11,
    y: 291,
    z: 6,
    width: 14,
    depth: 26,
    height: 12,
    isFrame: true,
  ),

  // ---- Six clinical regions (front offset z > 0 = anterior) -------------
  TwinVolume(
    region: 'brain',
    x: 0,
    y: 20,
    z: 7,
    width: 22,
    depth: 20,
    height: 20,
  ),
  TwinVolume(
    region: 'eyes',
    x: 0,
    y: 28,
    z: 16,
    width: 16,
    depth: 6,
    height: 6,
  ),
  TwinVolume(
    region: 'cardio',
    x: -7,
    y: 76,
    z: 9,
    width: 16,
    depth: 14,
    height: 18,
  ),
  TwinVolume(
    region: 'lungs',
    x: 8,
    y: 74,
    z: 5,
    width: 16,
    depth: 16,
    height: 24,
  ),
  TwinVolume(
    region: 'immune',
    x: 0,
    y: 120,
    z: 5,
    width: 26,
    depth: 20,
    height: 22,
  ),
  TwinVolume(
    region: 'musculo',
    x: 0,
    y: 210,
    z: 3,
    width: 32,
    depth: 22,
    height: 120,
  ),
];

/// Pure-Dart orthographic projection maths for the rotating anatomical twin.
///
/// No Flutter import here on purpose: the geometry is unit-testable without a
/// rendering surface, and could be reused by a web or native port later.
class TwinProjection {
  const TwinProjection._();

  /// Wrap any angle into [0, 360).
  static double normalizeAngle(double degrees) {
    final n = degrees % 360;
    return n < 0 ? n + 360 : n;
  }

  /// Apparent width of a box rotated by [angleDegrees] around the vertical
  /// axis: |cos a| * frontal width + |sin a| * sagittal depth.
  static double apparentWidth(TwinVolume v, double angleDegrees) {
    final a = _radians(angleDegrees);
    return math.cos(a).abs() * v.width + math.sin(a).abs() * v.depth;
  }

  /// Horizontal screen offset of the volume centre.
  static double screenX(TwinVolume v, double angleDegrees) {
    final a = _radians(angleDegrees);
    return v.x * math.cos(a) + v.z * math.sin(a);
  }

  /// Painter depth: larger means closer to the camera (draw order).
  static double cameraDepth(TwinVolume v, double angleDegrees) {
    final a = _radians(angleDegrees);
    return -v.x * math.sin(a) + v.z * math.cos(a);
  }

  /// Far-to-near ordering, so a simple forward loop paints correctly.
  static List<TwinVolume> farToNear(
    List<TwinVolume> volumes,
    double angleDegrees,
  ) {
    final sorted = List<TwinVolume>.of(volumes);
    sorted.sort(
      (a, b) =>
          cameraDepth(a, angleDegrees).compareTo(cameraDepth(b, angleDegrees)),
    );
    return sorted;
  }

  /// Which region is lit at [progress] (0..1) of a full rotation.
  static String scanRegion(double progress) {
    final p = progress.clamp(0.0, 1.0).toDouble();
    var i = (p * kTwinRegions.length).floor();
    if (i >= kTwinRegions.length) i = kTwinRegions.length - 1;
    if (i < 0) i = 0;
    return kTwinRegions[i];
  }

  /// Hit-test a tap in canvas pixels. Pure Dart, no Offset dependency.
  /// [scale], [centerX] and [top] must be the same values used by the painter.
  static String? regionAt({
    required double tapX,
    required double tapY,
    required double angleDegrees,
    required double scale,
    required double centerX,
    required double top,
    List<TwinVolume> volumes = kTwinVolumes,
  }) {
    final regions = volumes.where((v) => v.isRegion).toList();
    final ordered = farToNear(regions, angleDegrees);
    // Nearest first.
    for (final v in ordered.reversed) {
      final w = apparentWidth(v, angleDegrees) * scale;
      final h = v.height * scale;
      final cx = centerX + screenX(v, angleDegrees) * scale;
      final cy = top + v.y * scale;
      if (tapX >= cx - w / 2 &&
          tapX <= cx + w / 2 &&
          tapY >= cy - h / 2 &&
          tapY <= cy + h / 2) {
        return v.region;
      }
    }
    return null;
  }

  static double _radians(double degrees) => degrees * math.pi / 180.0;
}
