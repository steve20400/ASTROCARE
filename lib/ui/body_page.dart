// Body tab: a human figure in real 3D. One finger turns it in every direction, two
// fingers zoom and move it, and touching a part of the body opens its information:
// health and illness thresholds, the NASA risk it relates to, and the astronaut's own
// last values with their color code.
// The figure is a mesh of triangles built and lit by this file: no 3D model file, no
// image, no extra package, no network.
 
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
 
import 'package:flutter/material.dart';
 
import '../app/app_state.dart';
import '../domain/catalog.dart';
import '../domain/models.dart';
import 'add_measurement_sheet.dart';
import 'indicator_page.dart';
import 'theme.dart';
import 'widgets.dart';
 
const List<String> _zones = ['head', 'chest', 'abdomen', 'arms', 'legs'];
 
const Map<String, IconData> _zoneIcons = {
  'head': Icons.psychology_outlined,
  'chest': Icons.favorite_border,
  'abdomen': Icons.thermostat,
  'arms': Icons.fitness_center,
  'legs': Icons.directions_walk,
};
 
/// Point of the body surface where the marker of each zone sits (x, y, z).
const Map<String, List<double>> _anchors = {
  'head': [0, 0.86, 0.125],
  'chest': [0.07, 0.52, 0.118],
  'abdomen': [0, 0.20, 0.105],
  'arms': [0.31, 0.30, 0.05],
  'legs': [0.105, -0.45, 0.075],
};
/// Zoom used when the view moves to a zone.
const Map<String, double> _zoneZoom = {
  'head': 2.3,
  'chest': 1.9,
  'abdomen': 1.9,
  'arms': 1.6,
  'legs': 1.35,
};
 
// ---------------------------------------------------------------------------
// The mesh. The body measures 2 units, from y = -1 (feet) to y = 1 (top of the
// head), and faces the viewer along +z.
// ---------------------------------------------------------------------------
 
class _Mesh {
  final List<double> vx = [];
  final List<double> vy = [];
  final List<double> vz = [];
  final List<double> nx = [];
  final List<double> ny = [];
  final List<double> nz = [];
  final List<int> vZone = [];
  final List<int> tris = [];
 
  /// Part of the body (one tube) each vertex belongs to, and the center of each part.
  final List<int> vPart = [];
  final List<List<double>> centers = [];
 
  /// Pairs [part, cover]: the part is always drawn before its cover, so that the
  /// neck comes out of the chest and the thighs come out of the hips.
  final List<List<int>> covered = [];
}
 
const int _around = 20;
 
/// Adds a closed tube made of rings. Each ring is [cx, cy, cz, ux, uy, uz, vx, vy, vz]:
/// its center and its two radius vectors.
void _addTube(_Mesh m, int zone, List<List<double>> rings) {
  final first = m.vx.length;

  final firstTri = m.tris.length;
  final part = m.centers.length;
  final center = [0.0, 0.0, 0.0];
  for (final r in rings) {
    for (var j = 0; j < 3; j++) {
      center[j] += r[j] / rings.length;
    }
  }
  m.centers.add(center);
  for (final r in rings) {
    for (var k = 0; k < _around; k++) {
      final a = 2 * math.pi * k / _around;
      final c = math.cos(a);
      final s = math.sin(a);
      m.vx.add(r[0] + r[3] * c + r[6] * s);
      m.vy.add(r[1] + r[4] * c + r[7] * s);
      m.vz.add(r[2] + r[5] * c + r[8] * s);
      m.nx.add(0);
      m.ny.add(0);
      m.nz.add(0);
      m.vZone.add(zone);
      m.vPart.add(part);
    }
  }
  for (var i = 0; i < rings.length - 1; i++) {
    for (var k = 0; k < _around; k++) {
      final k2 = (k + 1) % _around;
      final a = first + i * _around + k;
      final b = first + i * _around + k2;
      final c = first + (i + 1) * _around + k2;
      final d = first + (i + 1) * _around + k;
      m.tris.addAll([a, b, c, a, c, d]);
    }
  }
  // Smooth normals: each vertex takes the sum of the normals of its triangles.
  for (var t = firstTri; t < m.tris.length; t += 3) {
    final a = m.tris[t];
    final b = m.tris[t + 1];
    final c = m.tris[t + 2];
    final e1x = m.vx[b] - m.vx[a];
    final e1y = m.vy[b] - m.vy[a];
    final e1z = m.vz[b] - m.vz[a];
    final e2x = m.vx[c] - m.vx[a];
    final e2y = m.vy[c] - m.vy[a];
    final e2z = m.vz[c] - m.vz[a];
    final fx = e1y * e2z - e1z * e2y;
    final fy = e1z * e2x - e1x * e2z;
    final fz = e1x * e2y - e1y * e2x;
    for (final v in [a, b, c]) {
      m.nx[v] += fx;
      m.ny[v] += fy;
      m.nz[v] += fz;
    }
  }
  // The normals must point outward. One vertex of the middle ring tells the side.
  final mid = rings.length ~/ 2;
  final probe = first + mid * _around;
  final outward =
      m.nx[probe] * (m.vx[probe] - rings[mid][0]) +
      m.ny[probe] * (m.vy[probe] - rings[mid][1]) +
      m.nz[probe] * (m.vz[probe] - rings[mid][2]);
  final flip = outward < 0;
  if (flip) {
    for (var t = firstTri; t < m.tris.length; t += 3) {
      final keep = m.tris[t + 1];
      m.tris[t + 1] = m.tris[t + 2];
      m.tris[t + 2] = keep;
    }
  }
  for (var v = first; v < m.vx.length; v++) {
    final sign = flip ? -1.0 : 1.0;
    final len = math.sqrt(m.nx[v] * m.nx[v] + m.ny[v] * m.ny[v] + m.nz[v] * m.nz[v]);
    final k = len < 1e-12 ? 0.0 : sign / len;
    m.nx[v] *= k;
    m.ny[v] *= k;
    m.nz[v] *= k;
  }
}
 
/// A shape turned around the vertical axis. Each row of [profile] is
/// [y, radius on x, radius on z], and [dz] moves the whole shape forward.
void _addLathe(_Mesh m, int zone, List<List<double>> profile, {double dz = 0}) {
  _addTube(m, zone, [
    for (final p in profile) [0, p[0], dz, p[1], 0, 0, 0, 0, p[2]],

  ]);
}
 
/// A limb: a rounded tube from [a] to [b], with a radius going from [ra] to [rb].
void _addLimb(_Mesh m, int zone, List<double> a, List<double> b, double ra, double rb) {
  var wx = b[0] - a[0];
  var wy = b[1] - a[1];
  var wz = b[2] - a[2];
  final len = math.sqrt(wx * wx + wy * wy + wz * wz);
  wx /= len;
  wy /= len;
  wz /= len;
  // Two directions at right angles to the limb.
  final helper = wz.abs() > 0.9 ? [0.0, 1.0, 0.0] : [0.0, 0.0, 1.0];
  var ux = wy * helper[2] - wz * helper[1];
  var uy = wz * helper[0] - wx * helper[2];
  var uz = wx * helper[1] - wy * helper[0];
  final ul = math.sqrt(ux * ux + uy * uy + uz * uz);
  ux /= ul;
  uy /= ul;
  uz /= ul;
  final px = wy * uz - wz * uy;
  final py = wz * ux - wx * uz;
  final pz = wx * uy - wy * ux;
 
  List<double> ring(List<double> c, double shift, double radius) => [
    c[0] + wx * shift,
    c[1] + wy * shift,
    c[2] + wz * shift,
    ux * radius,
    uy * radius,
    uz * radius,
    px * radius,
    py * radius,
    pz * radius,
  ];
  final rings = <List<double>>[];
  for (final deg in [-88, -60, -30, 0]) {
    final f = deg * math.pi / 180;
    rings.add(ring(a, ra * math.sin(f), ra * math.cos(f)));
  }
  for (final k in [0.33, 0.66]) {
    final c = [a[0] + (b[0] - a[0]) * k, a[1] + (b[1] - a[1]) * k, a[2] + (b[2] - a[2]) * k];
    rings.add(ring(c, 0, ra + (rb - ra) * k));
  }
  for (final deg in [0, 30, 60, 88]) {
    final f = deg * math.pi / 180;
    rings.add(ring(b, rb * math.sin(f), rb * math.cos(f)));
  }
  _addTube(m, zone, rings);
}
 
_Mesh _buildBody() {
  final m = _Mesh();
  const head = 0;
  const chest = 1;
  const abdomen = 2;
  const arms = 3;
  const legs = 4;
 
  // Head (an egg shape) and neck.
  _addLathe(m, head, [
    for (var deg = -88; deg <= 88; deg += 16)
      [
        0.845 + 0.142 * math.sin(deg * math.pi / 180),
        0.108 * math.cos(deg * math.pi / 180) * (deg < 0 ? 0.92 : 1.0),
        0.122 * math.cos(deg * math.pi / 180),
      ],
  ], dz: 0.012);
  final neck = m.centers.length;
  _addLimb(m, head, [0, 0.66, 0], [0, 0.73, 0.005], 0.052, 0.05);
 
  // Chest, from the shoulders to the bottom of the ribs.
  m.covered.add([neck, m.centers.length]);
  _addLathe(m, chest, [
    [0.712, 0.004, 0.004],
    [0.705, 0.075, 0.055],
    [0.685, 0.165, 0.080],
    [0.650, 0.222, 0.100],
    [0.600, 0.228, 0.112],
    [0.540, 0.215, 0.118],
    [0.470, 0.198, 0.114],
    [0.400, 0.182, 0.106],
    [0.350, 0.172, 0.100],

    [0.340, 0.004, 0.004],
  ]);
  // Abdomen and hips.
  final hips = m.centers.length;
  _addLathe(m, abdomen, [
    [0.380, 0.004, 0.004],
    [0.370, 0.172, 0.100],
    [0.300, 0.160, 0.096],
    [0.230, 0.155, 0.096],
    [0.150, 0.168, 0.104],
    [0.070, 0.184, 0.112],
    [0.000, 0.186, 0.114],
    [-0.060, 0.170, 0.106],
    [-0.110, 0.120, 0.085],
    [-0.135, 0.004, 0.004],
  ]);
 
  for (final s in [-1.0, 1.0]) {
    // Shoulder, upper arm, forearm, hand.
    _addLimb(m, arms, [s * 0.235, 0.630, 0], [s * 0.292, 0.345, -0.012], 0.066, 0.050);
    _addLimb(m, arms, [s * 0.292, 0.345, -0.012], [s * 0.322, 0.085, 0.040], 0.048, 0.035);
    _addLimb(m, arms, [s * 0.326, 0.050, 0.048], [s * 0.336, -0.050, 0.066], 0.036, 0.026);
    // Thigh, lower leg, foot.
    m.covered.add([m.centers.length, hips]);
    _addLimb(m, legs, [s * 0.098, -0.060, 0], [s * 0.106, -0.455, 0.012], 0.098, 0.064);
    _addLimb(m, legs, [s * 0.106, -0.455, 0.012], [s * 0.106, -0.885, -0.008], 0.062, 0.040);
    _addLimb(m, legs, [s * 0.106, -0.950, -0.030], [s * 0.106, -0.962, 0.120], 0.046, 0.036);
  }
  return m;
}
 
final _Mesh _body = _buildBody();
// ---------------------------------------------------------------------------
// One drawn frame: the visible triangles, sorted from the farthest to the nearest.
// ---------------------------------------------------------------------------
 
class _View {
  final double yaw;
  final double pitch;
  final double zoom;
  final Offset pan;
 
  const _View(this.yaw, this.pitch, this.zoom, this.pan);
 
  /// Turns a point of the body and projects it on the screen.
  /// Returns the screen x, the screen y and the depth (larger means nearer).
  List<double> project(double x, double y, double z, Size size) {
    final cy = math.cos(yaw);
    final sy = math.sin(yaw);
    final cp = math.cos(pitch);
    final sp = math.sin(pitch);
    final x1 = x * cy + z * sy;
    final z1 = -x * sy + z * cy;
    final y2 = y * cp - z1 * sp;
    final z2 = y * sp + z1 * cp;
    final unit = size.height * 0.40 * zoom * 5 / (5 - z2);
    return [size.width / 2 + pan.dx + x1 * unit, size.height * 0.46 + pan.dy - y2 * unit, z2];
  }
}
 
class _Frame {
  final Float32List positions;
  final Int32List colors;
  final List<int> zones;
 
  _Frame(this.positions, this.colors, this.zones);
 
  /// Zone of the nearest triangle under the point, or -1 when the point is off the body.
  int zoneAt(Offset p) {
    for (var t = zones.length - 1; t >= 0; t--) {
      final i = t * 6;
      final ax = positions[i];
      final ay = positions[i + 1];
      final bx = positions[i + 2];
      final by = positions[i + 3];
      final cx = positions[i + 4];
      final cy = positions[i + 5];
      final d1 = (p.dx - bx) * (ay - by) - (ax - bx) * (p.dy - by);
      final d2 = (p.dx - cx) * (by - cy) - (bx - cx) * (p.dy - cy);
      final d3 = (p.dx - ax) * (cy - ay) - (cx - ax) * (p.dy - ay);
      final neg = d1 < 0 || d2 < 0 || d3 < 0;
      final pos = d1 > 0 || d2 > 0 || d3 > 0;
      if (!(neg && pos)) return zones[t];
    }

    return -1;
  }
}
 
_Frame _render(_View view, Size size, List<Color> zoneColors) {
  final m = _body;
  final n = m.vx.length;
  final sx = Float32List(n);
  final sy = Float32List(n);
  final depth = Float32List(n);
  final color = Int32List(n);
 
  final cy = math.cos(view.yaw);
  final sny = math.sin(view.yaw);
  final cp = math.cos(view.pitch);
  final snp = math.sin(view.pitch);
  // Light fixed to the camera, coming from the upper left, plus a soft highlight.
  const lx = -0.34;
  const ly = 0.52;
  const lz = 0.78;
  const hx = -0.18;
  const hy = 0.28;
  const hz = 0.94;
 
  for (var i = 0; i < n; i++) {
    final p = view.project(m.vx[i], m.vy[i], m.vz[i], size);
    sx[i] = p[0];
    sy[i] = p[1];
    depth[i] = p[2];
 
    final nx1 = m.nx[i] * cy + m.nz[i] * sny;
    final nz1 = -m.nx[i] * sny + m.nz[i] * cy;
    final ny2 = m.ny[i] * cp - nz1 * snp;
    final nz2 = m.ny[i] * snp + nz1 * cp;
    final diffuse = math.max(0.0, nx1 * lx + ny2 * ly + nz2 * lz);
    final shine = math.pow(math.max(0.0, nx1 * hx + ny2 * hy + nz2 * hz), 28) * 0.30;
    final light = 0.34 + 0.66 * diffuse;
    final base = zoneColors[m.vZone[i]];
    int channel(double v) => (255 * (v * light + shine)).round().clamp(0, 255);
    color[i] =
        (0xFF << 24) | (channel(base.r) << 16) | (channel(base.g) << 8) | channel(base.b);
  }
 
  // The parts of the body are drawn whole, from the farthest to the nearest: this
  // keeps the joints between two parts clean. Inside a part, the triangles that face
  // the camera are sorted the same way.
  final order = [for (var i = 0; i < m.centers.length; i++) i];
  final partDepth = [
    for (final c in m.centers) view.project(c[0], c[1], c[2], size)[2],
  ];
  order.sort((a, b) => partDepth[a].compareTo(partDepth[b]));
  for (final pair in m.covered) {
    final from = order.indexOf(pair[0]);
    if (from > order.indexOf(pair[1])) {
      order.removeAt(from);
      order.insert(order.indexOf(pair[1]), pair[0]);
    }
  }
  final rank = List<int>.filled(order.length, 0);
  for (var i = 0; i < order.length; i++) {
    rank[order[i]] = i;
  }
  final visible = <int>[];
  for (var t = 0; t < m.tris.length; t += 3) {
    final a = m.tris[t];
    final b = m.tris[t + 1];
    final c = m.tris[t + 2];
    final area = (sx[b] - sx[a]) * (sy[c] - sy[a]) - (sx[c] - sx[a]) * (sy[b] - sy[a]);
    if (area < 0) visible.add(t);
  }
  double far(int t) =>
      rank[m.vPart[m.tris[t]]] * 100.0 +
      depth[m.tris[t]] +
      depth[m.tris[t + 1]] +
      depth[m.tris[t + 2]];
  visible.sort((a, b) => far(a).compareTo(far(b)));
 
  final positions = Float32List(visible.length * 6);
  final colors = Int32List(visible.length * 3);
  final zones = List<int>.filled(visible.length, 0);
  for (var k = 0; k < visible.length; k++) {
    final t = visible[k];
    for (var j = 0; j < 3; j++) {
      final v = m.tris[t + j];

      positions[k * 6 + j * 2] = sx[v];
      positions[k * 6 + j * 2 + 1] = sy[v];
      colors[k * 3 + j] = color[v];
    }
    zones[k] = m.vZone[m.tris[t]];
  }
  return _Frame(positions, colors, zones);
}
 
class _BodyPainter extends CustomPainter {
  final _Frame frame;
  final Offset shadow;
  final double shadowWidth;
 
  _BodyPainter(this.frame, this.shadow, this.shadowWidth);
 
  @override
  void paint(Canvas canvas, Size size) {
    // A few stars, at low opacity, behind the figure.
    final star = Paint()..color = Colors.white.withAlpha(60);
    final random = math.Random(7);
    for (var i = 0; i < 48; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        0.6 + random.nextDouble() * 1.1,
        star,
      );
    }
    canvas.drawOval(
      Rect.fromCenter(center: shadow, width: shadowWidth, height: shadowWidth * 0.16),
      Paint()..color = Colors.black.withAlpha(70),
    );
    if (frame.zones.isEmpty) return;
    final vertices = ui.Vertices.raw(
      ui.VertexMode.triangles,
      frame.positions,
      colors: frame.colors,
    );
    // BlendMode.dst keeps the colors computed for each vertex.
    canvas.drawVertices(vertices, BlendMode.dst, Paint());
    vertices.dispose();
  }
 
  @override
  bool shouldRepaint(covariant _BodyPainter old) => true;
}
 
// ---------------------------------------------------------------------------
// The page.
// ---------------------------------------------------------------------------
 
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
 
class _BodyPageState extends State<BodyPage> with TickerProviderStateMixin {
  late final AnimationController _spin;
  late final AnimationController _move;
  double _yaw = 0.45;
  double _pitch = 0.08;
  double _zoom = 1;
  Offset _pan = Offset.zero;
  double _zoomAtStart = 1;
  String? _zone;
  _Frame? _frame;
 
  // Start and end of the camera movement toward a zone.
  double _fromZoom = 1;
  double _toZoom = 1;
  Offset _fromPan = Offset.zero;

  Offset _toPan = Offset.zero;
 
  @override
  void initState() {
    super.initState();
    _spin = AnimationController(vsync: this, duration: const Duration(seconds: 24))..repeat();
    _move = AnimationController(vsync: this, duration: const Duration(milliseconds: 420))
      ..addListener(() {
        final k = Curves.easeInOut.transform(_move.value);
        setState(() {
          _zoom = _fromZoom + (_toZoom - _fromZoom) * k;
          _pan = Offset.lerp(_fromPan, _toPan, k)!;
        });
      });
  }
 
  @override
  void dispose() {
    _spin.dispose();
    _move.dispose();
    super.dispose();
  }
 
  double get _yawNow => _yaw + _spin.value * 2 * math.pi;
 
  void _stopSpin() {
    if (!_spin.isAnimating) return;
    _yaw = _yawNow;
    _spin.stop();
    _spin.value = 0;
  }
 
  void _toggleSpin() {
    setState(() {
      if (_spin.isAnimating) {
        _stopSpin();
      } else {
        _spin.repeat();
      }
    });
  }
 
  void _glide(double zoom, Offset pan) {
    _fromZoom = _zoom;
    _fromPan = _pan;
    _toZoom = zoom;
    _toPan = pan;
    _move.forward(from: 0);
  }
 
  void _zoomBy(double factor) {
    _glide((_zoom * factor).clamp(0.7, 4.0), _pan * factor);
  }
 
  void _reset() {
    setState(() {
      _zone = null;
      _pitch = 0.08;
    });
    _glide(1, Offset.zero);
  }
 
  /// Selects a zone and moves the view so that the zone sits above the panel.
  void _select(String? zone, Size size) {
    setState(() {
      _stopSpin();
      _zone = zone;
    });
    if (zone == null) return;
    final zoom = math.max(_zoom, _zoomZone(zone));
    final a = _anchors[zone]!;
    final p = _View(_yaw, _pitch, zoom, Offset.zero).project(a[0], a[1], a[2], size);
    _glide(zoom, Offset(size.width / 2 - p[0], size.height * 0.27 - p[1]));
  }
 
  double _zoomZone(String zone) => _zoneZoom[zone] ?? 1.6;
 
  void _onScaleStart(ScaleStartDetails d) {
    _move.stop();
    _zoomAtStart = _zoom;
  }
 
  void _onScaleUpdate(ScaleUpdateDetails d) {
    setState(() {

      _stopSpin();
      if (d.pointerCount >= 2) {
        _zoom = (_zoomAtStart * d.scale).clamp(0.7, 4.0);
        _pan += d.focalPointDelta;
      } else {
        _yaw += d.focalPointDelta.dx * 0.011;
        _pitch = (_pitch + d.focalPointDelta.dy * 0.008).clamp(-1.25, 1.25);
      }
    });
  }
 
  void _onTap(TapUpDetails d, Size size) {
    final index = _frame?.zoneAt(d.localPosition) ?? -1;
    _select(index < 0 ? null : _zones[index], size);
  }
 
  @override
  Widget build(BuildContext context) {
    // Redrawn when the data, the language or the theme change, and on every frame
    // of a movement.
    return AnimatedBuilder(
      animation: Listenable.merge([appState, _spin]),
      builder: (context, _) => LayoutBuilder(
        builder: (context, box) => _scene(context, Size(box.maxWidth, box.maxHeight)),
      ),
    );
  }
 
  Widget _scene(BuildContext context, Size size) {
    const skin = Color(0xFFDCE6F7);
    final levels = {for (final z in _zones) z: _zoneLevel(z)};
    final colors = [
      for (final z in _zones)
        () {
          final level = levels[z];
          var c = level == null ? skin : Color.lerp(skin, levelColorFor(true, level), 0.72)!;
          if (_zone != null && _zone != z) c = Color.lerp(c, kDeepBlue, 0.30)!;
          return c;
        }(),
    ];
    final view = _View(_yawNow, _pitch, _zoom, _pan);
    final frame = _render(view, size, colors);
    _frame = frame;
    final ground = view.project(0, -1.03, 0, size);
    final unit = size.height * 0.40 * _zoom;
 
    return Container(
      width: size.width,
      height: size.height,
      decoration: const BoxDecoration(gradient: kBrandGradient),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: _onScaleStart,
              onScaleUpdate: _onScaleUpdate,
              onTapUp: (d) => _onTap(d, size),
              child: CustomPaint(
                painter: _BodyPainter(frame, Offset(ground[0], ground[1]), unit * 0.62),
              ),
            ),
          ),
          ...[for (final z in _zones) _marker(z, levels[z], view, size)].whereType<Widget>(),
          Positioned(right: 8, top: 8, child: _controls()),
          if (_zone == null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: kDeepBlue.withAlpha(215),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.touch_app_outlined, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(

                        t('body.hint'),
                        style: const TextStyle(color: Colors.white, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: size.height * 0.52),
                child: _ZonePanel(
                  zone: _zone!,
                  level: levels[_zone!],
                  onClose: () => setState(() => _zone = null),
                ),
              ),
            ),
        ],
      ),
    );
  }
 
  /// Round marker fixed on the body. It is hidden when its zone is on the far side.
  Widget? _marker(String zone, AlertLevel? level, _View view, Size size) {
    final a = _anchors[zone]!;
    final p = view.project(a[0], a[1], a[2], size);
    final front = view.project(a[0] * 0.5, a[1], 0, size)[2] < p[2];
    if (!front) return null;
    final selected = zone == _zone;
    final color = levelColorFor(true, level);
    return Positioned(
      left: p[0] - 22,
      top: p[1] - 22,
      child: Semantics(
        button: true,
        selected: selected,
        label: '${t('zone.$zone.name')}: ${t(levelKey(level))}',
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _select(zone, size),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: Container(
                width: selected ? 38 : 32,
                height: selected ? 38 : 32,
                decoration: BoxDecoration(
                  color: kDeepBlue.withAlpha(225),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? Colors.white : color,
                    width: selected ? 2.6 : 1.6,
                  ),
                ),
                child: Icon(_zoneIcons[zone], color: color, size: selected ? 21 : 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
 
  Widget _controls() {
    Widget button(IconData icon, String tip, VoidCallback onPressed) => IconButton(
      tooltip: tip,
      onPressed: onPressed,
      color: Colors.white,
      icon: Icon(icon),
    );
    return Container(
      decoration: BoxDecoration(
        color: kDeepBlue.withAlpha(200),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          button(Icons.add, t('body.zoomIn'), () => _zoomBy(1.4)),
          button(Icons.remove, t('body.zoomOut'), () => _zoomBy(1 / 1.4)),
          button(Icons.center_focus_strong_outlined, t('body.reset'), _reset),
          button(
            _spin.isAnimating ? Icons.pause_circle_outline : Icons.threed_rotation,
            t('body.spin'),
            _toggleSpin,
          ),
        ],
      ),
    );
  }
}
 
/// Information of the touched zone: NASA reference, thresholds, own values.
class _ZonePanel extends StatelessWidget {
  final String zone;
  final AlertLevel? level;
  final VoidCallback onClose;
 
  const _ZonePanel({required this.zone, required this.level, required this.onClose});
 
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final codes = kBodyZones[zone] ?? const <String>[];
    final risks = kZoneRisks[zone] ?? const <String>[];
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_zoneIcons[zone], color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t('zone.$zone.name'),
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
                if (codes.isNotEmpty) LevelChip(level),
                IconButton(
                  tooltip: t('add.cancel'),
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final code in codes) _IndicatorBlock(code: code),
                  if (codes.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(t('body.none'), style: const TextStyle(height: 1.35)),
                    ),
                  Text(
                    t('body.inSpace'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(t('zone.$zone.nasa'), style: const TextStyle(height: 1.35)),
                  const SizedBox(height: 6),
                  for (final risk in risks)
                    Text(
                      '${t('aid.ref')}: $risk',
                      style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }
}
/// One indicator of the zone: own last value, range bar, thresholds, actions.
class _IndicatorBlock extends StatelessWidget {
  final String code;
 
  const _IndicatorBlock({required this.code});
 
  @override
  Widget build(BuildContext context) {
    final i = indicatorByCode(code);
    final last = appState.latest(code);
    final AlertLevel? level = last == null ? null : i.levelFor(last.value);
    final color = levelColor(context, level);
    final or = ' ${t('ref.or')} ';
 
    final watch = <String>[
      if (i.attentionLow < i.nominalLow)
        t('ref.range', [i.format(i.attentionLow), i.format(i.nominalLow)]),
      if (i.attentionHigh > i.nominalHigh)
        t('ref.range', [i.format(i.nominalHigh), i.format(i.attentionHigh)]),
    ];
    final critical = <String>[
      if (i.attentionLow > i.min) t('ref.below', [i.format(i.attentionLow)]),
      if (i.attentionHigh < i.max) t('ref.above', [i.format(i.attentionHigh)]),
    ];
 
    Widget line(AlertLevel l, String text) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(levelIcon(l), size: 17, color: levelColor(context, l)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(height: 1.3))),
        ],
      ),
    );
 
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(indicatorIcon(code), size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t('ind.$code.name'),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t('body.yours'), style: const TextStyle(fontSize: 12.5)),
                    Text(
                      last == null ? t('home.nodata') : '${i.format(last.value)} ${i.unit}',
                      style: TextStyle(
                        fontSize: last == null ? 16 : 24,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    if (last != null)
                      Text(appState.formatDate(last.at), style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              LevelChip(level),
            ],
          ),
          const SizedBox(height: 8),
          _RangeBar(indicator: i, value: last?.value),
          const SizedBox(height: 8),

          Text(t('ref.title'), style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          line(
            AlertLevel.nominal,
            t('ref.nominal', [
              t('ref.range', [i.format(i.nominalLow), i.format(i.nominalHigh)]),
              i.unit,
            ]),
          ),
          if (watch.isNotEmpty)
            line(AlertLevel.attention, t('ref.attention', [watch.join(or), i.unit])),
          if (critical.isNotEmpty)
            line(AlertLevel.critical, t('ref.critical', [critical.join(or), i.unit])),
          Text(
            t('range.note'),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: () => showAddMeasurement(context, code: code),
                icon: const Icon(Icons.add, size: 18),
                label: Text(t('ind.measure')),
              ),
              TextButton.icon(
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute<void>(builder: (_) => IndicatorPage(code: code))),
                icon: const Icon(Icons.show_chart, size: 18),
                label: Text(t('body.details')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
 
/// Horizontal bar of the ranges (critical, watch, healthy, watch, critical) with a
/// pointer on the astronaut's own value.
class _RangeBar extends StatelessWidget {
  final Indicator indicator;
  final double? value;
 
  const _RangeBar({required this.indicator, required this.value});
 
  @override
  Widget build(BuildContext context) {
    final i = indicator;
    final span = i.attentionHigh - i.attentionLow;
    final lo = math.max(i.min, i.attentionLow - span * 0.3);
    final hi = math.min(i.max, i.attentionHigh + span * 0.3);
    final bands = <List<Object>>[
      [i.attentionLow - lo, AlertLevel.critical],
      [i.nominalLow - i.attentionLow, AlertLevel.attention],
      [i.nominalHigh - i.nominalLow, AlertLevel.nominal],
      [i.attentionHigh - i.nominalHigh, AlertLevel.attention],
      [hi - i.attentionHigh, AlertLevel.critical],
    ];
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, box) {
        final width = box.maxWidth;
        final at = value == null ? null : ((value! - lo) / (hi - lo)).clamp(0.0, 1.0) * width;
        return SizedBox(
          height: 26,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 13,
                height: 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Row(
                    children: [
                      for (final b in bands)

                        if ((b[0] as double) > 0)
                          Expanded(
                            flex: ((b[0] as double) / (hi - lo) * 1000).round().clamp(1, 1000),
                            child: Container(color: levelColor(context, b[1] as AlertLevel)),
                          ),
                    ],
                  ),
                ),
              ),
              if (at != null)
                Positioned(
                  left: (at - 12).clamp(0.0, width - 24),
                  top: -5,
                  child: Icon(Icons.arrow_drop_down, size: 24, color: scheme.onSurface),
                ),
            ],
          ),
        );
      },
    );
  }
}
