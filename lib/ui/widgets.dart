// Small reusable widgets: status chip, section title, line chart.
 
import 'package:flutter/material.dart';
 
import '../app/app_state.dart';
import '../domain/models.dart';
import 'theme.dart';
 
class LevelChip extends StatelessWidget {
  final AlertLevel? level;
  final bool large;
 
  const LevelChip(this.level, {super.key, this.large = false});
 
  @override
  Widget build(BuildContext context) {
    final color = levelColor(context, level);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: large ? 14 : 10, vertical: large ? 8 : 4),
      decoration: BoxDecoration(
        color: color.withAlpha(36),
        border: Border.all(color: color, width: 1.2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(levelIcon(level), color: color, size: large ? 22 : 16),
          const SizedBox(width: 6),
          Text(
            t(levelKey(level)),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: large ? 16 : 12.5,
            ),
          ),
        ],
      ),
    );
  }
}
 
class SectionTitle extends StatelessWidget {
  final String text;
 
  const SectionTitle(this.text, {super.key});
 
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
 
/// A titled block of plain text, used for explanations.
class InfoBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
 
  const InfoBlock({super.key, required this.icon, required this.title, required this.body});
 
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [

                Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(body, style: const TextStyle(height: 1.4)),
          ],
        ),
      ),
    );
  }
}
 
/// Line chart of an indicator over time, with the nominal range as a band.
class LineChart extends StatelessWidget {
  final List<double> values;
  final List<AlertLevel> levels;
  final double? bandLow;
  final double? bandHigh;
 
  const LineChart({
    super.key,
    required this.values,
    required this.levels,
    this.bandLow,
    this.bandHigh,
  });
 
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 190,
      width: double.infinity,
      child: CustomPaint(
        painter: _LineChartPainter(
          values: values,
          pointColors: [for (final l in levels) levelColor(context, l)],
          bandLow: bandLow,
          bandHigh: bandHigh,
          lineColor: scheme.primary,
          bandColor: levelColor(context, AlertLevel.nominal).withAlpha(40),
          gridColor: scheme.outline.withAlpha(90),
          textColor: scheme.onSurface,
        ),
      ),
    );
  }
}
 
class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> pointColors;
  final double? bandLow;
  final double? bandHigh;
  final Color lineColor;
  final Color bandColor;
  final Color gridColor;
  final Color textColor;
 
  _LineChartPainter({
    required this.values,
    required this.pointColors,
    required this.bandLow,
    required this.bandHigh,
    required this.lineColor,
    required this.bandColor,
    required this.gridColor,
    required this.textColor,
  });
 
  void _label(Canvas canvas, String text, Offset at) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: textColor, fontSize: 10.5),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(at.dx, at.dy - tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    const left = 40.0;
    const right = 10.0;
    const top = 10.0;
    const bottom = 12.0;
    final w = size.width - left - right;
    final h = size.height - top - bottom;
 
    var lo = values.reduce((a, b) => a < b ? a : b);
    var hi = values.reduce((a, b) => a > b ? a : b);
    if (bandLow != null && bandLow! < lo) lo = bandLow!;
    if (bandHigh != null && bandHigh! > hi) hi = bandHigh!;
    if ((hi - lo).abs() < 1e-9) {
      hi += 1;
      lo -= 1;
    }
    final pad = (hi - lo) * 0.08;
    lo -= pad;
    hi += pad;
 
    double yOf(double v) => top + h - (v - lo) / (hi - lo) * h;
    double xOf(int i) => values.length == 1 ? left + w / 2 : left + w * i / (values.length - 1);
 
    if (bandLow != null && bandHigh != null) {
      canvas.drawRect(
        Rect.fromLTRB(left, yOf(bandHigh!), left + w, yOf(bandLow!)),
        Paint()..color = bandColor,
      );
    }
 
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 0.6;
    for (var g = 0; g <= 2; g++) {
      final v = lo + (hi - lo) * g / 2;
      final y = yOf(v);
      canvas.drawLine(Offset(left, y), Offset(left + w, y), grid);
      _label(canvas, v.toStringAsFixed(v.abs() < 20 ? 1 : 0), Offset(2, y));
    }
 
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final p = Offset(xOf(i), yOf(values[i]));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
    for (var i = 0; i < values.length; i++) {
      final color = i < pointColors.length ? pointColors[i] : lineColor;
      canvas.drawCircle(Offset(xOf(i), yOf(values[i])), 4, Paint()..color = color);
    }
  }
 
  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) => true;
}
