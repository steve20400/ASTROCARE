import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/vitals.dart';
import '../theme.dart';

class BiometricHomeostasisRadar extends StatelessWidget {
  final VitalsRecord vitals;

  const BiometricHomeostasisRadar({
    super.key,
    required this.vitals,
  });

  @override
  Widget build(BuildContext context) {
    // Compute normalized stability indices (0.0 = failure, 1.0 = perfect equilibrium)
    final double neuroIndex = (1.0 - (vitals.fatigueScore / 10.0)).clamp(0.1, 1.0);
    final double ocularIndex = (1.0 - ((vitals.intracranialPressure - 10.0) / 15.0).clamp(0.0, 0.9));
    final double cardioIndex = (1.0 - ((vitals.heartRate - 70).abs() / 60.0).clamp(0.0, 0.9));
    final double pulmonaryIndex = ((vitals.spo2 - 85.0) / 15.0).clamp(0.1, 1.0);
    final double immuneIndex = (1.0 - (vitals.radiationRate / 30.0).clamp(0.0, 0.9));
    final double sleepIndex = (vitals.sleepHours / 8.0).clamp(0.2, 1.0);

    final List<double> values = [
      neuroIndex,
      ocularIndex,
      cardioIndex,
      pulmonaryIndex,
      immuneIndex,
      sleepIndex,
    ];

    final List<String> labels = [
      'NEURO (CNS)',
      'OCULAR (SANS)',
      'CARDIOVASC.',
      'PULMONARY',
      'IMMUNO/DNA',
      'CIRCADIAN',
    ];

    final double meanStability =
        (values.reduce((a, b) => a + b) / values.length) * 100.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AstroTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AstroTheme.borderCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 3,
                      height: 14,
                      color: AstroTheme.spaceCyan,
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        'HOMEOSTASIS RADAR VECTOR',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: AstroTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AstroTheme.bgDark,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: meanStability > 75
                        ? AstroTheme.nominalEmerald
                        : (meanStability > 50
                            ? AstroTheme.cautionAmber
                            : AstroTheme.criticalCoral),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  'EQ INDEX: ${meanStability.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                    color: meanStability > 75
                        ? AstroTheme.nominalEmerald
                        : (meanStability > 50
                            ? AstroTheme.cautionAmber
                            : AstroTheme.criticalCoral),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 220,
            width: double.infinity,
            child: CustomPaint(
              painter: _RadarChartPainter(
                values: values,
                labels: labels,
                meanScore: meanStability,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 2,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AstroTheme.spaceCyan,
                  shape: BoxShape.circle,
                ),
              ),
              const Text(
                'ACTIVE BIO-EQUILIBRIUM',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: AstroTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  border: Border.all(color: AstroTheme.textMuted, width: 1),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'NASA BASELINE CORRIDOR',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: AstroTheme.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final double meanScore;

  _RadarChartPainter({
    required this.values,
    required this.labels,
    required this.meanScore,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxRadius = math.min(cx, cy) - 28;
    final numSides = values.length;

    // Web background rings (Concentric polygons)
    final gridLinePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int ring = 1; ring <= 4; ring++) {
      final r = maxRadius * (ring / 4);
      final ringPath = Path();
      for (int i = 0; i < numSides; i++) {
        final angle = (i * 2 * math.pi / numSides) - (math.pi / 2);
        final x = cx + r * math.cos(angle);
        final y = cy + r * math.sin(angle);
        if (i == 0) {
          ringPath.moveTo(x, y);
        } else {
          ringPath.lineTo(x, y);
        }
      }
      ringPath.close();
      canvas.drawPath(ringPath, gridLinePaint);
    }

    // Radial spokes
    final spokePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.0;

    for (int i = 0; i < numSides; i++) {
      final angle = (i * 2 * math.pi / numSides) - (math.pi / 2);
      final x = cx + maxRadius * math.cos(angle);
      final y = cy + maxRadius * math.sin(angle);
      canvas.drawLine(Offset(cx, cy), Offset(x, y), spokePaint);

      // Draw Labels
      final labelAngle = angle;
      final labelX = cx + (maxRadius + 18) * math.cos(labelAngle);
      final labelY = cy + (maxRadius + 18) * math.sin(labelAngle);

      final textSpan = TextSpan(
        text: labels[i],
        style: const TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: AstroTheme.textSecondary,
        ),
      );
      final tp = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(labelX - tp.width / 2, labelY - tp.height / 2));
    }

    // Active Data Polygon
    final dataPath = Path();
    final pointOffsets = <Offset>[];

    for (int i = 0; i < numSides; i++) {
      final angle = (i * 2 * math.pi / numSides) - (math.pi / 2);
      final r = maxRadius * values[i].clamp(0.1, 1.0);
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      pointOffsets.add(Offset(x, y));

      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    dataPath.close();

    // Fill polygon with crisp solid tint (strictly no messy gradient)
    final fillPaint = Paint()
      ..color = AstroTheme.spaceCyan.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    canvas.drawPath(dataPath, fillPaint);

    // Outline polygon with neon cyan hairline
    final strokePaint = Paint()
      ..color = AstroTheme.spaceCyan
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(dataPath, strokePaint);

    // Draw vertex target nodes
    final dotFill = Paint()
      ..color = AstroTheme.bgDark
      ..style = PaintingStyle.fill;
    final dotBorder = Paint()
      ..color = AstroTheme.spaceCyan
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (var pt in pointOffsets) {
      canvas.drawCircle(pt, 4.0, dotFill);
      canvas.drawCircle(pt, 4.0, dotBorder);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) => true;
}
