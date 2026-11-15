import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/twin_projection.dart';
import '../../models/vitals.dart';
import '../responsive.dart';
import '../theme.dart';

/// Paints the volumetric 360 degrees anatomical twin.
///
/// Everything is vector (CustomPainter), no 3D mesh, no WebGL, no asset:
/// each segment is a box whose apparent width follows the viewing angle.
class RotatingTwinPainter extends CustomPainter {
  final double angleDegrees;
  final String selectedOrgan;

  /// Non-null while the scan pass is running; overrides [selectedOrgan].
  final String? scanHighlight;
  final VitalsRecord vitals;

  const RotatingTwinPainter({
    required this.angleDegrees,
    required this.selectedOrgan,
    required this.vitals,
    this.scanHighlight,
  });

  String get _activeRegion => scanHighlight ?? selectedOrgan;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = AstroLayout.twinScale(size.width, size.height);
    final centerX = size.width / 2.0;
    final top = AstroLayout.twinTop(size.height, scale);
    final angle = TwinProjection.normalizeAngle(angleDegrees);

    _drawGrid(canvas, size, centerX, top + 160 * scale);
    _drawOrientationDial(canvas, centerX, top, scale, angle);

    // Painter's algorithm: far volumes first, near volumes last.
    for (final volume in TwinProjection.farToNear(kTwinVolumes, angle)) {
      _drawVolume(canvas, volume, angle, scale, centerX, top);
    }

    _drawHud(canvas, size, angle);
  }

  void _drawGrid(Canvas canvas, Size size, double cx, double cy) {
    final grid = Paint()
      ..color = const Color(0xFF131C2D)
      ..strokeWidth = 0.8;
    for (double y = 18; y < size.height; y += 28) {
      canvas.drawLine(Offset(16, y), Offset(size.width - 16, y), grid);
    }
    for (double x = 24; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 16), Offset(x, size.height - 16), grid);
    }

    final ring = Paint()
      ..color = const Color(0xFF1B273F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final radius = 110 * AstroLayout.twinScale(size.width, size.height);
    canvas.drawCircle(Offset(cx, cy), radius, ring);
    canvas.drawCircle(Offset(cx, cy), radius * 1.45, ring);

    final cross = Paint()
      ..color = const Color(0xFF243452)
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(cx - radius * 1.6, cy),
      Offset(cx + radius * 1.6, cy),
      cross,
    );
    canvas.drawLine(Offset(cx, 14), Offset(cx, size.height - 14), cross);
  }

  /// A ground dial with a dot showing where "front" is. Without it, a
  /// rotating body gives no orientation cue and a 360 degrees claim is
  /// unverifiable.
  void _drawOrientationDial(
    Canvas canvas,
    double centerX,
    double top,
    double scale,
    double angle,
  ) {
    final dialY = top + 312 * scale;
    final dial = Paint()
      ..color = AstroTheme.spaceCyan.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, dialY),
        width: 170 * scale,
        height: 24 * scale,
      ),
      dial,
    );
    final a = angle * math.pi / 180.0;
    canvas.drawCircle(
      Offset(
        centerX + math.sin(a) * 85 * scale,
        dialY - math.cos(a) * 12 * scale,
      ),
      3.5,
      Paint()..color = AstroTheme.spaceCyan,
    );
  }

  void _drawVolume(
    Canvas canvas,
    TwinVolume volume,
    double angle,
    double scale,
    double centerX,
    double top,
  ) {
    final w = TwinProjection.apparentWidth(volume, angle) * scale;
    final h = volume.height * scale;
    if (w <= 0 || h <= 0) return;

    final dx = centerX + TwinProjection.screenX(volume, angle) * scale;
    final dy = top + volume.y * scale;
    final shortest = w < h ? w : h;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(dx, dy), width: w, height: h),
      Radius.circular(shortest * 0.32),
    );

    if (volume.isFrame) {
      canvas.drawRRect(rrect, Paint()..color = const Color(0xFF0E1B2E));
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = AstroTheme.spaceCyan.withValues(alpha: 0.20)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
      return;
    }

    final active = volume.region == _activeRegion;
    final color = _regionColor(volume.region);
    canvas.drawRRect(
      rrect,
      Paint()..color = color.withValues(alpha: active ? 0.38 : 0.10),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = color.withValues(alpha: active ? 0.95 : 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = active ? 2.0 : 1.0,
    );
  }

  Color _regionColor(String region) {
    HealthStatus status;
    switch (region) {
      case 'brain':
        status = vitals.fatigueScore >= 7
            ? (vitals.fatigueScore >= 9
                  ? HealthStatus.critical
                  : HealthStatus.caution)
            : HealthStatus.nominal;
        break;
      case 'eyes':
        status = vitals.intracranialPressure > 16.0
            ? (vitals.intracranialPressure > 20.0
                  ? HealthStatus.critical
                  : HealthStatus.caution)
            : HealthStatus.nominal;
        break;
      case 'cardio':
        status = (vitals.heartRate > 100 || vitals.bpSystolic > 140)
            ? (vitals.heartRate > 120
                  ? HealthStatus.critical
                  : HealthStatus.caution)
            : HealthStatus.nominal;
        break;
      case 'lungs':
        status = vitals.spo2 < 95.0
            ? (vitals.spo2 < 91.0
                  ? HealthStatus.critical
                  : HealthStatus.caution)
            : HealthStatus.nominal;
        break;
      case 'immune':
        status = vitals.radiationRate > 5.0
            ? (vitals.radiationRate > 15.0
                  ? HealthStatus.critical
                  : HealthStatus.caution)
            : HealthStatus.nominal;
        break;
      default:
        status = HealthStatus.nominal;
    }
    switch (status) {
      case HealthStatus.critical:
        return AstroTheme.criticalCoral;
      case HealthStatus.caution:
        return AstroTheme.cautionAmber;
      default:
        return AstroTheme.nominalEmerald;
    }
  }

  void _drawHud(Canvas canvas, Size size, double angle) {
    _text(
      canvas,
      'BIO-TWIN: PHOENIX-1',
      const Offset(12, 10),
      const TextStyle(
        fontSize: 9,
        fontFamily: 'monospace',
        fontWeight: FontWeight.bold,
        color: AstroTheme.spaceCyan,
        letterSpacing: 1.0,
      ),
    );
    _text(
      canvas,
      'MASS: 64.2 KG  |  H: 178 CM',
      const Offset(12, 24),
      const TextStyle(
        fontSize: 8,
        fontFamily: 'monospace',
        color: AstroTheme.textMuted,
      ),
    );
    _text(
      canvas,
      'AZIMUTH ${angle.round().toString().padLeft(3, '0')} DEG',
      Offset(size.width - 108, 10),
      const TextStyle(
        fontSize: 8,
        fontFamily: 'monospace',
        color: AstroTheme.textSecondary,
      ),
    );
    _text(
      canvas,
      'VOLUMETRIC PROJECTION / NO GPU MESH',
      Offset(size.width - 190, 24),
      const TextStyle(
        fontSize: 7.5,
        fontFamily: 'monospace',
        color: AstroTheme.textMuted,
      ),
    );
  }

  void _text(Canvas canvas, String value, Offset offset, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: value, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant RotatingTwinPainter oldDelegate) {
    return oldDelegate.angleDegrees != angleDegrees ||
        oldDelegate.selectedOrgan != selectedOrgan ||
        oldDelegate.scanHighlight != scanHighlight ||
        oldDelegate.vitals.id != vitals.id;
  }
}
