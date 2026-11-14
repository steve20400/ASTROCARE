import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:astrocare/models/twin_projection.dart';
import 'package:astrocare/ui/responsive.dart';

/// Trigonometric projections are never bit-exact at 90/180 degrees.
bool near(double actual, double expected) => (actual - expected).abs() < 1e-9;

void main() {
  const torso = TwinVolume(
    region: 'frame',
    x: 0,
    y: 82,
    z: 0,
    width: 42,
    depth: 26,
    height: 52,
    isFrame: true,
  );

  group('volumetric projection', () {
    test('face and back show the frontal width', () {
      expect(near(TwinProjection.apparentWidth(torso, 0), 42.0), true);
      expect(near(TwinProjection.apparentWidth(torso, 180), 42.0), true);
      expect(near(TwinProjection.apparentWidth(torso, 360), 42.0), true);
    });

    test('profile shows the sagittal depth, not a collapsed plank', () {
      expect(near(TwinProjection.apparentWidth(torso, 90), 26.0), true);
      expect(near(TwinProjection.apparentWidth(torso, 270), 26.0), true);
    });

    test('45 degrees mixes width and depth', () {
      final expected = (42 + 26) / math.sqrt(2);
      expect(near(TwinProjection.apparentWidth(torso, 45), expected), true);
    });

    test('screen offset and camera depth follow the rotation', () {
      const front = TwinVolume(
        region: 'cardio',
        x: -7,
        y: 76,
        z: 9,
        width: 16,
        depth: 14,
        height: 18,
      );
      expect(near(TwinProjection.screenX(front, 0), -7.0), true);
      expect(near(TwinProjection.screenX(front, 90), front.z), true);
      expect(near(TwinProjection.cameraDepth(front, 0), 9.0), true);
      expect(near(TwinProjection.cameraDepth(front, 90), -front.x), true);
    });

    test('angles wrap into [0, 360)', () {
      expect(TwinProjection.normalizeAngle(-15), 345.0);
      expect(TwinProjection.normalizeAngle(375), 15.0);
      expect(TwinProjection.normalizeAngle(0), 0.0);
    });

    test('a full scan lights all six regions in order', () {
      final seen = <String>{};
      for (var i = 0; i <= 60; i++) {
        seen.add(TwinProjection.scanRegion(i / 60));
      }
      expect(seen.length, kTwinRegions.length);
      expect(TwinProjection.scanRegion(0), 'brain');
      expect(TwinProjection.scanRegion(0.99), 'musculo');
    });

    test('tap hit-testing uses the same geometry as the painter', () {
      const scale = 1.0;
      final hit = TwinProjection.regionAt(
        tapX: 0,
        tapY: 20,
        angleDegrees: 0,
        scale: scale,
        centerX: 0,
        top: 0,
      );
      expect(hit, 'brain');
      expect(
        TwinProjection.regionAt(
          tapX: 0,
          tapY: 20,
          angleDegrees: 90,
          scale: scale,
          centerX: 0,
          top: 0,
        ),
        'brain',
      );
      expect(
        TwinProjection.regionAt(
          tapX: 0,
          tapY: 310,
          angleDegrees: 0,
          scale: scale,
          centerX: 0,
          top: 0,
        ),
        null,
      );
    });
  });

  group('mobile-first layout', () {
    test('telemetry grid widens with the viewport', () {
      expect(AstroLayout.telemetryColumns(320), 1);
      expect(AstroLayout.telemetryColumns(390), 2);
      expect(AstroLayout.telemetryColumns(800), 3);
      expect(AstroLayout.telemetryColumns(1200), 4);
    });

    test('the twin never eats two phone screens', () {
      expect(near(AstroLayout.twinCanvasHeight(390, 844), 844 * 0.34), true);
      expect(near(AstroLayout.twinCanvasHeight(390, 300), 220.0), true);
      expect(near(AstroLayout.twinCanvasHeight(1200, 2000), 360.0), true);
    });

    test('scale fits the 320-unit body into the canvas', () {
      expect(AstroLayout.twinScale(300, 320), 1.0);
      expect(AstroLayout.twinScale(300, 640), 1.5);
      expect(AstroLayout.twinTop(320, 1.0), 0.0);
    });

    test('breakpoints are consistent', () {
      expect(AstroLayout.isCompact(390), true);
      expect(AstroLayout.isMedium(800), true);
      expect(AstroLayout.isExpanded(1200), true);
    });
  });
}
