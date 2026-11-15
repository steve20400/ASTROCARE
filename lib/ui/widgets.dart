// Small reusable widgets: logo, status chip, section title, numbered steps, line chart.
 
import 'package:flutter/material.dart';
 
import '../app/app_state.dart';
import '../domain/models.dart';
import 'theme.dart';
 
/// The AstroCare logo (assets/images/logo.png). It is drawn for a dark blue background.
/// When the image is missing from the build, a text version is shown instead.
class AppLogo extends StatelessWidget {
  final double height;
 
  const AppLogo({super.key, this.height = 110});
 
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      height: height,
      fit: BoxFit.contain,
      semanticLabel: 'AstroCare',
      errorBuilder: (context, error, stack) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.health_and_safety_outlined, color: kBlueYonder, size: height * 0.5),
          const SizedBox(width: 10),
          Text(
            'AstroCare',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: height * 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
/// Numbered steps, one under the other. Used for first aid.
class StepList extends StatelessWidget {
  final List<String> steps;
  final Color color;
 
  const StepList({super.key, required this.steps, required this.color});
 
  @override
  Widget build(BuildContext context) {
    final onColor = isDark(context) ? kDeepBlue : Colors.white;
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: color,
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(color: onColor, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(steps[i], style: const TextStyle(fontSize: 15, height: 1.35)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
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
 
  /// Horizontal position of each point, from 0 (start of the period) to 1 (its end).
  /// Without it, the points are spread evenly.
  final List<double>? xs;
  final String? startLabel;
  final String? endLabel;
 
  const LineChart({
    super.key,
    required this.values,
    required this.levels,
    this.bandLow,
    this.bandHigh,
    this.xs,
    this.startLabel,
    this.endLabel,
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
          xs: xs,
          startLabel: startLabel,
          endLabel: endLabel,
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
  final List<double>? xs;
  final String? startLabel;
  final String? endLabel;
  final Color lineColor;
  final Color bandColor;
  final Color gridColor;
  final Color textColor;
 
  _LineChartPainter({
    required this.values,
    required this.pointColors,
    required this.bandLow,
    required this.bandHigh,
    required this.xs,
    required this.startLabel,
    required this.endLabel,
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
    final bottom = startLabel == null ? 12.0 : 26.0;
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
    double xOf(int i) {
      final x = xs;
      if (x != null && i < x.length) return left + w * x[i].clamp(0.0, 1.0);
      return values.length == 1 ? left + w / 2 : left + w * i / (values.length - 1);
    }
    // Start and end of the period, under the curve.
    if (startLabel != null) _label(canvas, startLabel!, Offset(left, size.height - 8));
    if (endLabel != null) {
      final tp = TextPainter(
        text: TextSpan(
          text: endLabel,
          style: TextStyle(color: textColor, fontSize: 10.5),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(left + w - tp.width, size.height - 8 - tp.height / 2));
    }
 
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
