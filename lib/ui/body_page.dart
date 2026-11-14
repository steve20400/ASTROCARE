// Interactive human figure: each body zone shows the worst status of its indicators.
 
import 'package:flutter/material.dart';
 
import '../app/app_state.dart';
import '../domain/catalog.dart';
import '../domain/models.dart';
import 'indicator_page.dart';
import 'theme.dart';
import 'widgets.dart';
 
class _Spot {
  final BodyZone zone;
  final Offset center;
  final double radius;
 
  const _Spot(this.zone, this.center, this.radius);
}
 
// Positions in a 200 x 420 drawing area.
const List<_Spot> _spots = [
  _Spot(BodyZone.head, Offset(100, 42), 30),
  _Spot(BodyZone.lungs, Offset(76, 122), 20),
  _Spot(BodyZone.heart, Offset(124, 122), 20),
  _Spot(BodyZone.core, Offset(100, 166), 20),
  _Spot(BodyZone.abdomen, Offset(100, 210), 20),
  _Spot(BodyZone.legs, Offset(79, 330), 20),
  _Spot(BodyZone.legs, Offset(121, 330), 20),
];
 
void _openZone(BuildContext context, BodyZone zone) {
  final navigator = Navigator.of(context);
  final memberId = appState.currentMemberId;
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Text(
              t('zone.${zone.name}'),
              style: Theme.of(sheetContext).textTheme.titleMedium,
            ),
          ),
          for (final i in indicatorsOfZone(zone))
            ListTile(
              leading: Icon(zoneIcon(zone)),
              title: Text(t('ind.${i.code}.name')),
              subtitle: Text(() {
                final last = appState.latest(memberId, i.code);
                return last == null ? t('dash.nodata') : '${i.format(last.value)} ${i.unit}';
              }()),
              trailing: LevelChip(appState.levelOf(memberId, i.code)),
              onTap: () {
                Navigator.of(sheetContext).pop();
                navigator.push(
                  MaterialPageRoute<void>(builder: (_) => IndicatorPage(code: i.code)),
                );
              },
            ),
        ],
      ),
    ),
  );
}
 
class BodyPage extends StatelessWidget {
  const BodyPage({super.key});
 
  @override
  Widget build(BuildContext context) {
    final memberId = appState.currentMemberId;
    final scheme = Theme.of(context).colorScheme;
    return ListView(

      padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
      children: [
        Text(t('body.title'), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 2),
        Text('${appState.currentMember.name} · ${t('body.hint')}'),
        const SizedBox(height: 8),
        Center(
          child: GestureDetector(
            onTapUp: (details) {
              final p = details.localPosition;
              for (final s in _spots) {
                if ((p - s.center).distance <= s.radius + 10) {
                  _openZone(context, s.zone);
                  return;
                }
              }
            },
            child: SizedBox(
              width: 200,
              height: 420,
              child: CustomPaint(
                painter: _BodyPainter(
                  silhouette: scheme.onSurface.withAlpha(38),
                  border: scheme.surface,
                  colors: {
                    for (final z in BodyZone.values)
                      z: levelColor(context, appState.zoneLevel(memberId, z)),
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        for (final z in BodyZone.values)
          Card(
            child: ListTile(
              leading: Icon(
                zoneIcon(z),
                color: levelColor(context, appState.zoneLevel(memberId, z)),
              ),
              title: Text(t('zone.${z.name}')),
              trailing: LevelChip(appState.zoneLevel(memberId, z)),
              onTap: () => _openZone(context, z),
            ),
          ),
      ],
    );
  }
}
 
class _BodyPainter extends CustomPainter {
  final Color silhouette;
  final Color border;
  final Map<BodyZone, Color> colors;
 
  _BodyPainter({required this.silhouette, required this.border, required this.colors});
 
  void _icon(Canvas canvas, IconData icon, Offset center, double size) {
    final tp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          fontSize: size,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }
 
  @override
  void paint(Canvas canvas, Size size) {
    final body = Paint()..color = silhouette;
    RRect rr(double l, double t, double r, double b, double radius) =>
        RRect.fromLTRBR(l, t, r, b, Radius.circular(radius));
 
    canvas.drawRect(const Rect.fromLTRB(92, 68, 108, 88), body);
    canvas.drawRRect(rr(58, 84, 142, 244, 22), body);
    canvas.drawRRect(rr(30, 90, 52, 232, 11), body);
    canvas.drawRRect(rr(148, 90, 170, 232, 11), body);

    canvas.drawRRect(rr(62, 238, 96, 412, 15), body);
    canvas.drawRRect(rr(104, 238, 138, 412, 15), body);
 
    final edge = Paint()
      ..color = border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    for (final s in _spots) {
      final fill = Paint()..color = colors[s.zone] ?? Colors.grey;
      canvas.drawCircle(s.center, s.radius, fill);
      canvas.drawCircle(s.center, s.radius, edge);
      _icon(canvas, zoneIcon(s.zone), s.center, s.radius);
    }
  }
 
  @override
  bool shouldRepaint(covariant _BodyPainter oldDelegate) => true;
}
