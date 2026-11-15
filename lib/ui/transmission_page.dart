// Transmission to the ground: the automatic report, the queue of reports kept on
// board, and the simulated link that carries them with the CCSDS file protocol.
// The page shows the packets crossing the link, the protocol log and what is really
// done for security.
 
import 'dart:io';
 
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
 
import '../app/app_state.dart';
import '../domain/ccsds.dart';
import '../domain/models.dart';
import 'theme.dart';
import 'widgets.dart';
 
const List<int> _delays = [30, 600, 3600];
 
/// Short label written on a packet in the drawing.
String _short(LinkEvent e) {
  switch (e.kind) {
    case 'md':
      return 'MD';
    case 'fd':
    case 'refd':
      return 'FD ${e.index}';
    case 'eof':
      return 'EOF';
    case 'nak':
      return 'NAK';
    case 'fin':
      return 'FIN';
    default:
      return 'ACK';
  }
}
 
/// Full sentence of the protocol log for one message.
String _sentence(LinkEvent e, String fileName) {
  switch (e.kind) {
    case 'md':
      return t('tx.ev.md', [fileName, e.to]);
    case 'fd':
      final text = t('tx.ev.fd', [e.index, e.total, e.from, e.to - 1]);
      return e.lost ? '$text - ${t('tx.ev.lost')}' : text;
    case 'refd':
      return t('tx.ev.refd', [e.index, e.total]);
    case 'eof':
      return t('tx.ev.eof');
    case 'ackeof':
      return t('tx.ev.ackeof');
    case 'nak':
      return t('tx.ev.nak', [e.from, e.to - 1]);
    case 'fin':
      return t(e.lost ? 'tx.ev.finbad' : 'tx.ev.fin');
    default:
      return t('tx.ev.ackfin');
  }
}
 
String _clock(Duration d) {
  final s = d.isNegative ? 0 : d.inSeconds;
  String two(int n) => n < 10 ? '0$n' : '$n';
  return '${two(s ~/ 60)}:${two(s % 60)}';
}
 
Future<void> _share(BuildContext context, Report report) async {
  final messenger = ScaffoldMessenger.of(context);
  final failed = t('report.failed');
  try {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${report.fileName}');
    await file.writeAsBytes(appState.reportBytes(report), flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'AstroCare - ${t('report.title')}',

      ),
    );
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(failed)));
  }
}
 
class TransmissionPage extends StatefulWidget {
  const TransmissionPage({super.key});
 
  @override
  State<TransmissionPage> createState() => _TransmissionPageState();
}
 
class _TransmissionPageState extends State<TransmissionPage>
    with SingleTickerProviderStateMixin {
  // Runs while the page is open: it moves the packets and the countdown.
  late final AnimationController _tick;
 
  @override
  void initState() {
    super.initState();
    _tick = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
  }
 
  @override
  void dispose() {
    _tick.dispose();
    super.dispose();
  }
 
  int _elapsed() {
    final start = appState.transferStart;
    return start == null ? 0 : DateTime.now().difference(start).inMilliseconds;
  }
 
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: Text(t('tx.title'))),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            children: [
              _linkCard(context),
              const SizedBox(height: 8),
              _autoCard(context),
              SectionTitle(t('tx.reports')),
              _reportsCard(context),
              SectionTitle(t('tx.log')),
              _logCard(context),
              SectionTitle(t('tx.sec.title')),
              _securityCard(context),
            ],
          ),
        ),
      ),
    );
  }
 
  Widget _linkCard(BuildContext context) {
    const chips = ['CCSDS CFDP class 2', 'Space Packet', 'CRC-16', 'ChaCha20', 'HMAC-SHA-256'];
    final received = appState.reports.where((r) => r.sent).length;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
      decoration: BoxDecoration(gradient: kBrandGradient, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.satellite_alt, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('tx.link'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,

                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      t('tx.simulated'),
                      style: const TextStyle(color: Colors.white, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              Switch(
                value: appState.linkUp,
                onChanged: (v) => appState.setLink(v),
                activeThumbColor: kDeepBlue,
                activeTrackColor: kNeonYellow,
              ),
            ],
          ),
          SizedBox(
            height: 150,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _tick,
              builder: (context, _) => CustomPaint(
                painter: _LinkPainter(
                  plan: appState.transfer,
                  elapsed: _elapsed(),
                  linkUp: appState.linkUp,
                  space: t('tx.space'),
                  ground: t('tx.ground'),
                  waiting: t('tx.waiting', [appState.queuedReports]),
                  received: t('tx.received', [received]),
                  down: t('tx.linkdown'),
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _tick,
            builder: (context, _) => Text(
              _status(),
              style: const TextStyle(
                color: Colors.white,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final c in chips)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: kDeepBlue.withAlpha(170),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBlueYonder),
                  ),
                  child: Text(c, style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
            ],
          ),
        ],
      ),
    );
  }
 
  String _status() {
    final plan = appState.transfer;
    if (!appState.linkUp) return t('tx.status.down', [appState.queuedReports]);
    if (plan == null) return t('tx.status.idle');
    final elapsed = _elapsed();
    LinkEvent current = plan.events.first;
    for (final e in plan.events) {
      if (e.startMs <= elapsed) current = e;
    }
    var number = 0;
    for (final r in appState.reports) {
      if (r.id == appState.transferReportId) number = r.number;
    }
    return t('tx.status.sending', [number, _sentence(current, plan.fileName)]);

  }
 
  Widget _autoCard(BuildContext context) {
    final fresh = appState.newMeasurements().length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.schedule_send_outlined, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t('tx.auto.title'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(t('tx.auto.text'), style: const TextStyle(height: 1.35)),
            const SizedBox(height: 10),
            Text(t('tx.auto.delay'), style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            SegmentedButton<int>(
              showSelectedIcon: false,
              segments: [
                for (final d in _delays)
                  ButtonSegment<int>(value: d, label: Text(t('tx.delay.$d'))),
              ],
              selected: {_delays.contains(appState.reportDelay) ? appState.reportDelay : 600},
              onSelectionChanged: (s) => appState.setReportDelay(s.first),
            ),
            const SizedBox(height: 10),
            AnimatedBuilder(
              animation: _tick,
              builder: (context, _) {
                final due = appState.reportDueAt;
                return Text(
                  due == null
                      ? t('tx.auto.none')
                      : t('tx.auto.next', [_clock(due.difference(DateTime.now())), fresh]),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                );
              },
            ),
            const SizedBox(height: 4),
            Text(t('tx.auto.closed'), style: const TextStyle(fontSize: 12.5, height: 1.3)),
            const SizedBox(height: 10),
            FilledButton.tonalIcon(
              onPressed: () => appState.createReport(auto: false),
              icon: const Icon(Icons.note_add_outlined),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(t('tx.now')),
              ),
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _reportsCard(BuildContext context) {
    final list = appState.sortedReports();
    if (list.isEmpty) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.description_outlined),
          title: Text(t('tx.reports.none')),
        ),
      );
    }
    return Card(
      child: Column(
        children: [
          for (final r in list.take(8)) _reportTile(context, r),
        ],
      ),
    );
  }

  Widget _reportTile(BuildContext context, Report r) {
    final sending = r.id == appState.transferReportId;
    final size = t('tx.kb', [((r.pdf.length * 3 / 4) / 1024).toStringAsFixed(1)]);
    final IconData icon;
    final Color color;
    final String state;
    if (r.sent) {
      icon = Icons.check_circle;
      color = levelColor(context, AlertLevel.nominal);
      final at = r.sentAt == null ? '' : appState.formatDate(r.sentAt!);
      state = t('tx.r.sent', [at, r.packets, r.resent]);
    } else if (sending) {
      icon = Icons.sync;
      color = Theme.of(context).colorScheme.primary;
      state = t('tx.r.sending');
    } else {
      icon = Icons.inventory_2_outlined;
      color = levelColor(context, AlertLevel.attention);
      state = t('tx.r.wait');
    }
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        '${t('report.title')} ${t('tx.number', [r.number])} - '
        '${t(r.auto ? 'tx.r.auto' : 'tx.r.manual')}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${t('tx.r.line', [appState.formatDate(r.createdAt), r.newCount, size])}\n$state',
        style: const TextStyle(height: 1.3),
      ),
      isThreeLine: true,
      trailing: IconButton(
        tooltip: t('tx.share'),
        icon: const Icon(Icons.ios_share),
        onPressed: () => _share(context, r),
      ),
    );
  }
 
  Widget _logCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: AnimatedBuilder(
          animation: _tick,
          builder: (context, _) {
            final live = appState.transfer;
            final plan = live ?? appState.lastTransfer;
            if (plan == null) return Text(t('tx.log.none'));
            final elapsed = live == null ? plan.durationMs : _elapsed();
            final scheme = Theme.of(context).colorScheme;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final e in plan.events)
                  if (e.startMs <= elapsed)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            e.lost
                                ? Icons.close
                                : (e.down ? Icons.arrow_forward : Icons.arrow_back),
                            size: 16,
                            color: e.lost ? scheme.error : scheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _sentence(e, plan.fileName),
                              style: const TextStyle(fontSize: 13, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                if (live == null && plan.ok)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Icon(
                          Icons.verified_outlined,
                          size: 18,
                          color: levelColor(context, AlertLevel.nominal),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t('tx.log.ok', [plan.digest]),
                            style: const TextStyle(fontWeight: FontWeight.w600, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
 
  Widget _securityCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget line(IconData icon, String key) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(t(key), style: const TextStyle(height: 1.35))),
        ],
      ),
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            line(Icons.swap_horiz, 'tx.sec.cfdp'),
            line(Icons.inventory_outlined, 'tx.sec.packet'),
            line(Icons.lock_outline, 'tx.sec.cipher'),
            line(Icons.verified_user_outlined, 'tx.sec.sign'),
            const Divider(height: 20),
            line(Icons.info_outline, 'tx.sec.limit'),
          ],
        ),
      ),
    );
  }
}
 
/// Drawing of the link: the spacecraft on the left, the ground on the right, and the
/// messages moving between them.
class _LinkPainter extends CustomPainter {
  final TransferPlan? plan;
  final int elapsed;
  final bool linkUp;
  final String space;
  final String ground;
  final String waiting;
  final String received;
  final String down;
 
  _LinkPainter({
    required this.plan,
    required this.elapsed,
    required this.linkUp,
    required this.space,
    required this.ground,
    required this.waiting,
    required this.received,
    required this.down,
  });
 
  void _text(
    Canvas canvas,
    String text,
    Offset center, {
    double size = 12,
    Color color = Colors.white,

    FontWeight weight = FontWeight.w600,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: size, fontWeight: weight),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }
 
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
    const edge = 44.0;
    final left = Offset(edge, 62);
    final right = Offset(size.width - edge, 62);
 
    // The two ends.
    final disc = Paint()..color = kDeepBlue.withAlpha(190);
    final ring = Paint()
      ..color = kBlueYonder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    for (final c in [left, right]) {
      canvas.drawCircle(c, 30, disc);
      canvas.drawCircle(c, 30, ring);
    }
    _icon(canvas, Icons.rocket_launch_outlined, left, 30);
    _icon(canvas, Icons.cell_tower, right, 30);
    _text(canvas, space, Offset(left.dx, 106), weight: FontWeight.w700);
    _text(canvas, ground, Offset(right.dx, 106), weight: FontWeight.w700);
    _text(canvas, waiting, Offset(left.dx, 124), size: 11.5);
    _text(canvas, received, Offset(right.dx, 124), size: 11.5);
 
    // The link itself: a full line when it is up, a broken one when it is cut.
    final from = left.dx + 36;
    final to = right.dx - 36;
    final line = Paint()
      ..color = Colors.white.withAlpha(linkUp ? 200 : 90)
      ..strokeWidth = 2;
    if (linkUp) {
      canvas.drawLine(Offset(from, 62), Offset(to, 62), line);
    } else {
      for (var x = from; x < to; x += 14) {
        canvas.drawLine(Offset(x, 62), Offset(x + 7 > to ? to : x + 7, 62), line);
      }
      final mid = Offset((from + to) / 2, 62);
      canvas.drawCircle(mid, 13, Paint()..color = kDeepBlue);
      _icon(canvas, Icons.link_off, mid, 18);
      _text(canvas, down, Offset(mid.dx, 88), size: 12);
    }
 
    final p = plan;
    if (p == null || !linkUp) return;
    for (final e in p.events) {
      var k = (elapsed - e.startMs) / kFlightMs;
      if (k < 0 || k > 1) continue;
      // A lost message stops on the way and fades.
      final lost = e.lost && e.kind == 'fd';
      var alpha = 255;
      if (lost) {
        if (k > 0.55) alpha = (255 * (1 - (k - 0.55) / 0.45)).round().clamp(0, 255);
        if (k > 0.55) k = 0.55;
      }
      final x = e.down ? from + (to - from) * k : to - (to - from) * k;
      final y = e.down ? 44.0 : 80.0;
      final label = _short(e);

      final box = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, y), width: 14.0 + label.length * 7.5, height: 22),
        const Radius.circular(6),
      );
      final fill = e.down ? kNeonYellow : kBlueYonder;
      canvas.drawRRect(box, Paint()..color = fill.withAlpha(alpha));
      _text(
        canvas,
        lost && alpha < 255 ? '$label x' : label,
        Offset(x, y),
        size: 11.5,
        color: kDeepBlue.withAlpha(alpha),
        weight: FontWeight.w800,
      );
    }
  }
  @override
  bool shouldRepaint(covariant _LinkPainter old) => true;
}
