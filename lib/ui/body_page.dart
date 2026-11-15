// Body tab: an astronaut drawn in 3D that turns with the finger. Three zones (head,
// heart, whole body) carry the four indicators and take the color of their status.
// The figure is computed and drawn by this file: no 3D model, no image, no network.
 
import 'dart:math' as math;
 
import 'package:flutter/material.dart';
 
import '../app/app_state.dart';
import '../domain/catalog.dart';
import '../domain/models.dart';
import '../models/vitals.dart';
import 'indicator_page.dart';
import 'theme.dart';
import 'widgets.dart';
import 'widgets/rotating_digital_twin.dart';
 
// Parts of the figure. Each part has its own color.
const int _suit = 0;
const int _head = 1;
const int _chest = 2;
const int _visor = 3;
const int _gear = 4;
 
/// One shaded sphere of the figure. The body measures 2 units, from y = -1 to y = 1.
/// The figure faces the viewer along +z.
class _Ball {
  final double x;
  final double y;
  final double z;
  final double r;
  final int part;
 
  const _Ball(this.x, this.y, this.z, this.r, this.part);
}
 
void _limb(List<_Ball> out, List<double> a, List<double> b, double ra, double rb, int n, int part) {
  for (var i = 0; i < n; i++) {
    final k = n == 1 ? 0.0 : i / (n - 1);
    out.add(
      _Ball(
        a[0] + (b[0] - a[0]) * k,
        a[1] + (b[1] - a[1]) * k,
        a[2] + (b[2] - a[2]) * k,
        ra + (rb - ra) * k,
        part,
      ),
    );
  }
}
 
List<_Ball> _buildFigure() {
  final f = <_Ball>[];
  // Helmet, visor (it shows where the front is) and neck.
  f.add(const _Ball(0, 0.82, 0, 0.175, _head));
  f.add(const _Ball(0, 0.82, 0.09, 0.115, _visor));
  _limb(f, [0, 0.68, 0], [0, 0.63, 0], 0.07, 0.08, 2, _suit);
  // Torso: three spheres side by side on each level, wider than deep.
  const levels = <List<double>>[
    [0.56, 0.135, 0.125, 1],
    [0.48, 0.140, 0.130, 1],
    [0.40, 0.130, 0.128, 1],
    [0.32, 0.115, 0.120, 0],
    [0.24, 0.105, 0.115, 0],
    [0.16, 0.110, 0.118, 0],
    [0.08, 0.120, 0.122, 0],
  ];
  for (final l in levels) {
    final part = l[3] == 1 ? _chest : _suit;
    f.add(_Ball(-l[1], l[0], 0, l[2], part));
    f.add(_Ball(0, l[0], 0, l[2], part));
    f.add(_Ball(l[1], l[0], 0, l[2], part));
  }
  // Life-support backpack, on the back.
  f.add(const _Ball(0, 0.50, -0.15, 0.13, _gear));
  f.add(const _Ball(0, 0.34, -0.15, 0.13, _gear));
  for (final s in [-1.0, 1.0]) {
    // Shoulder, upper arm, forearm, glove.
    f.add(_Ball(s * 0.28, 0.565, 0, 0.095, _suit));
    _limb(f, [s * 0.31, 0.52, 0], [s * 0.36, 0.26, 0], 0.078, 0.066, 6, _suit);

    _limb(f, [s * 0.36, 0.26, 0], [s * 0.39, 0.01, 0.07], 0.066, 0.056, 6, _suit);
    f.add(_Ball(s * 0.395, -0.06, 0.085, 0.066, _gear));
    // Thigh, shin, boot.
    _limb(f, [s * 0.115, 0.0, 0], [s * 0.125, -0.42, 0], 0.118, 0.09, 9, _suit);
    _limb(f, [s * 0.125, -0.42, 0], [s * 0.125, -0.84, 0], 0.09, 0.07, 9, _suit);
    _limb(f, [s * 0.125, -0.92, 0], [s * 0.125, -0.93, 0.13], 0.075, 0.068, 3, _gear);
  }
  return f;
}
 
final List<_Ball> _figure = _buildFigure();
 
/// Point of the body each zone is attached to (x, y, z).
const Map<String, List<double>> _anchors = {
  'head': [0, 0.82, 0],
  'heart': [0.07, 0.47, 0.11],
  'body': [0, 0.20, 0.11],
};
 
/// Where the button of each zone sits in the drawing, as fractions of its size.
const Map<String, List<double>> _buttons = {
  'head': [0.15, 0.16],
  'heart': [0.85, 0.36],
  'body': [0.15, 0.56],
};
 
const Map<String, IconData> _zoneIcons = {
  'head': Icons.psychology_outlined,
  'heart': Icons.favorite_border,
  'body': Icons.thermostat,
};
 
/// Turns the point around the vertical axis and projects it with a light perspective.
/// Returns the screen x, the screen y, the scale and the depth.
List<double> _project(double x, double y, double z, double angle, Size size) {
  final c = math.cos(angle);
  final s = math.sin(angle);
  final xr = x * c + z * s;
  final zr = -x * s + z * c;
  final p = 6 / (6 - zr);
  final unit = size.height * 0.40 * p;
  return [size.width / 2 + xr * unit, size.height * 0.46 - y * unit, unit, zr];
}
 
/// Worst level among the indicators of a zone. Null when none was measured.
AlertLevel? _zoneLevel(String zone) {
  AlertLevel? worst;
  for (final code in kBodyZones[zone] ?? const <String>[]) {
    final last = appState.latest(code);
    if (last == null) continue;
    final level = indicatorByCode(code).levelFor(last.value);
    worst = worst == null ? level : maxLevel(worst, level);
  }
  return worst;
}
 
class BodyPage extends StatefulWidget {
  const BodyPage({super.key});
 
  @override
  State<BodyPage> createState() => _BodyPageState();
}
 
class _BodyPageState extends State<BodyPage> with SingleTickerProviderStateMixin {
  late final AnimationController _spin;
  double _base = 0.5;
  String _zone = 'heart';
 
  @override
  void initState() {
    super.initState();
    _spin = AnimationController(vsync: this, duration: const Duration(seconds: 16))..repeat();
  }
 
  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }
 
  double get _angle => _base + _spin.value * 2 * math.pi;
  void _toggleSpin() {
    setState(() {
      _base = _angle;

      if (_spin.isAnimating) {
        _spin.stop();
        _spin.value = 0;
      } else {
        _spin.repeat();
      }
    });
  }
 
  void _drag(DragUpdateDetails d) {
    setState(() {
      if (_spin.isAnimating) {
        _base = _angle;
        _spin.stop();
        _spin.value = 0;
      }
      _base += d.delta.dx * 0.012;
    });
  }
 
  @override
  Widget build(BuildContext context) {
    // Redrawn when the data, the language or the theme change, and on every frame
    // of the rotation.
    return AnimatedBuilder(
      animation: Listenable.merge([appState, _spin]),
      builder: (context, _) => ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: [_figureCard(context), const SizedBox(height: 8), _zonePanel(context)],
      ),
    );
  }
 
  Widget _figureCard(BuildContext context) {
    final levels = {for (final z in kBodyZones.keys) z: _zoneLevel(z)};
    Color tint(String zone) {
      final level = levels[zone];
      const suit = Color(0xFFEFF3FA);
      return level == null ? suit : Color.lerp(suit, levelColorFor(true, level), 0.62)!;
    }
 
    return Container(
      height: 420,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(gradient: kBrandGradient, borderRadius: BorderRadius.circular(18)),
      child: LayoutBuilder(
        builder: (context, box) {
          final size = Size(box.maxWidth, 420);
          final angle = _angle;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: _drag,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _FigurePainter(
                      angle: angle,
                      colors: {
                        _suit: tint('body'),
                        _head: tint('head'),
                        _chest: tint('heart'),
                        _visor: kDeepBlue,
                        _gear: const Color(0xFF9FB2D4),
                      },
                      selected: _zone,
                    ),
                  ),
                ),
                for (final z in kBodyZones.keys)
                  Positioned(
                    left: size.width * _buttons[z]![0] - 40,
                    top: size.height * _buttons[z]![1] - 26,
                    width: 80,
                    child: _ZoneButton(
                      zone: z,
                      level: levels[z],
                      selected: z == _zone,
                      onTap: () => setState(() => _zone = z),
                    ),
                  ),
                Positioned(
                  right: 6,
                  bottom: 6,

                  child: IconButton(
                    tooltip: t('body.spin'),
                    color: Colors.white,
                    onPressed: _toggleSpin,
                    icon: Icon(
                      _spin.isAnimating ? Icons.pause_circle_outline : Icons.threed_rotation,
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 60,
                  bottom: 14,
                  child: Text(
                    t('body.hint'),
                    style: const TextStyle(color: Colors.white, fontSize: 12.5),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
 
  Widget _zonePanel(BuildContext context) {
    final codes = kBodyZones[_zone] ?? const <String>[];
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Row(
              children: [
                Icon(_zoneIcons[_zone], color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t('zone.$_zone.name'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                LevelChip(_zoneLevel(_zone)),
              ],
            ),
          ),
          for (final code in codes) _indicatorTile(context, code),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
 
  Widget _indicatorTile(BuildContext context, String code) {
    final indicator = indicatorByCode(code);
    final last = appState.latest(code);
    final AlertLevel? level = last == null ? null : indicator.levelFor(last.value);
    return ListTile(
      leading: Icon(indicatorIcon(code), color: levelColor(context, level)),
      title: Text(t('ind.$code.name')),
      subtitle: Text(
        last == null
            ? t('home.nodata')
            : '${indicator.format(last.value)} ${indicator.unit} - ${t(levelKey(level))}',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => IndicatorPage(code: code))),
    );
  }
}
 
/// Round button of a zone, next to the figure. It never relies on color alone: it
/// shows the icon of the zone, the icon of the status and the name of the zone.
class _ZoneButton extends StatelessWidget {
  final String zone;
  final AlertLevel? level;
  final bool selected;
  final VoidCallback onTap;
  const _ZoneButton({

    required this.zone,
    required this.level,
    required this.selected,
    required this.onTap,
  });
 
  @override
  Widget build(BuildContext context) {
    final color = levelColorFor(true, level);
    return Semantics(
      button: true,
      selected: selected,
      label: '${t('zone.$zone.short')}: ${t(levelKey(level))}',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 56,
              height: 52,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: kDeepBlue,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? Colors.white : color,
                        width: selected ? 3 : 1.6,
                      ),
                    ),
                    child: Icon(_zoneIcons[zone], color: color, size: 26),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      decoration: const BoxDecoration(color: kDeepBlue, shape: BoxShape.circle),
                      child: Icon(levelIcon(level), color: color, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              t('zone.$zone.short'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 
class _FigurePainter extends CustomPainter {
  final double angle;
  final Map<int, Color> colors;
  final String selected;
 
  _FigurePainter({required this.angle, required this.colors, required this.selected});
 
  @override
  void paint(Canvas canvas, Size size) {
    // A few stars, at low opacity, behind the figure.
    final star = Paint()..color = Colors.white.withAlpha(60);
    final random = math.Random(7);
    for (var i = 0; i < 36; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        0.6 + random.nextDouble() * 1.1,
        star,

      );
    }
 
    // Soft shadow under the feet.
    final ground = _project(0, -1.02, 0, 0, size);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(ground[0], ground[1]), width: ground[2] * 0.9, height: 12),
      Paint()..color = Colors.black.withAlpha(70),
    );
 
    // Spheres, drawn from the farthest to the nearest.
    final drawn = [
      for (final b in _figure) [..._project(b.x, b.y, b.z, angle, size), b.r, b.part.toDouble()],
    ]..sort((a, b) => a[3].compareTo(b[3]));
    final paint = Paint();
    for (final d in drawn) {
      final center = Offset(d[0], d[1]);
      final radius = d[4] * d[2];
      final near = ((d[3] + 0.35) / 0.7).clamp(0.0, 1.0);
      final base = Color.lerp(Colors.black, colors[d[5].toInt()], 0.72 + 0.28 * near)!;
      paint.shader = RadialGradient(
        center: const Alignment(-0.4, -0.5),
        radius: 0.95,
        colors: [Color.lerp(base, Colors.white, 0.45)!, base, Color.lerp(base, Colors.black, 0.4)!],
        stops: const [0, 0.55, 1],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, paint);
    }
 
    // A line from each zone button to its point on the body.
    for (final zone in _anchors.keys) {
      final a = _anchors[zone]!;
      final p = _project(a[0], a[1], a[2], angle, size);
      final from = Offset(size.width * _buttons[zone]![0], size.height * _buttons[zone]![1]);
      final to = Offset(p[0], p[1]);
      final on = zone == selected;
      final line = Paint()
        ..color = Colors.white.withAlpha(on ? 230 : 120)
        ..strokeWidth = on ? 2 : 1.2;
      canvas.drawLine(from, to, line);
      canvas.drawCircle(to, on ? 5 : 3.5, Paint()..color = Colors.white.withAlpha(on ? 255 : 170));
    }
  }
 
  @override
  bool shouldRepaint(covariant _FigurePainter old) => true;
}
