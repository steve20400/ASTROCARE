import 'package:flutter/material.dart';
import '../../models/vitals.dart';
import '../theme.dart';

class VitalsSparklineChart extends StatelessWidget {
  final List<VitalsRecord> history;
  final String metricName;
  final String unit;
  final double Function(VitalsRecord r) extractor;
  final Color lineColor;
  final double normalMin;
  final double normalMax;

  const VitalsSparklineChart({
    super.key,
    required this.history,
    required this.metricName,
    required this.unit,
    required this.extractor,
    this.lineColor = AstroTheme.spaceCyan,
    required this.normalMin,
    required this.normalMax,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const SizedBox.shrink();
    }

    final points = history.take(24).toList().reversed.map(extractor).toList();
    final latestVal = points.isNotEmpty ? points.last : 0.0;
    final minVal = points.isNotEmpty ? points.reduce((a, b) => a < b ? a : b) : 0.0;
    final maxVal = points.isNotEmpty ? points.reduce((a, b) => a > b ? a : b) : 0.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AstroTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AstroTheme.borderCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 12,
                    color: lineColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    metricName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: AstroTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'LATEST: ',
                    style: const TextStyle(
                      fontSize: 9,
                      fontFamily: 'monospace',
                      color: AstroTheme.textMuted,
                    ),
                  ),
                  Text(
                    '${latestVal.toStringAsFixed(1)} $unit',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace',
                      color: lineColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 80,
            width: double.infinity,
            child: CustomPaint(
              painter: _OscilloscopePainter(
                points: points,
                lineColor: lineColor,
                normalMin: normalMin,
                normalMax: normalMax,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'T-24H (MIN: ${minVal.toStringAsFixed(1)})',
                style: const TextStyle(
                  fontSize: 8,
                  fontFamily: 'monospace',
                  color: AstroTheme.textMuted,
                ),
              ),
              const Text(
                'NASA SSM CORRIDOR [60s SAMPLING]',
                style: TextStyle(
                  fontSize: 7.5,
                  letterSpacing: 0.8,
                  fontFamily: 'monospace',
                  color: AstroTheme.textMuted,
                ),
              ),
              Text(
                'NOW (MAX: ${maxVal.toStringAsFixed(1)})',
                style: TextStyle(
                  fontSize: 8,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                  color: lineColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OscilloscopePainter extends CustomPainter {
  final List<double> points;
  final Color lineColor;
  final double normalMin;
  final double normalMax;

  _OscilloscopePainter({
    required this.points,
    required this.lineColor,
    required this.normalMin,
    required this.normalMax,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    double minVal = points.reduce((a, b) => a < b ? a : b);
    double maxVal = points.reduce((a, b) => a > b ? a : b);

    if (normalMin < minVal) minVal = normalMin;
    if (normalMax > maxVal) maxVal = normalMax;

    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    // Subtle Grid lines (hairlines)
    final gridPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 0.8;

    for (double y = 0; y <= size.height; y += size.height / 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Normal Physiological Band Corridor (Subtle solid tint, strictly no gradient)
    final normYTop = size.height - ((normalMax - minVal) / range) * size.height;
    final normYBottom = size.height - ((normalMin - minVal) / range) * size.height;

    final corridorPaint = Paint()
      ..color = AstroTheme.nominalEmerald.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTRB(
        0,
        normYTop.clamp(0.0, size.height),
        size.width,
        normYBottom.clamp(0.0, size.height),
      ),
      corridorPaint,
    );

    // Continuous Telemetry Waveform Path
    final path = Path();
    final stepX = size.width / (points.length - 1);

    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      final y = size.height - ((points[i] - minVal) / range) * (size.height - 10) - 5;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Clean hairline stroke
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    // Latest Active Node
    final lastX = size.width;
    final lastY = size.height - ((points.last - minVal) / range) * (size.height - 10) - 5;

    final targetPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(lastX, lastY), 3.0, targetPaint);
  }

  @override
  bool shouldRepaint(covariant _OscilloscopePainter oldDelegate) => true;
}
