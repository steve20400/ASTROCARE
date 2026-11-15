// Detail of one indicator: status, curve over a chosen period, reference range,
// explanations, history.
 
import 'package:flutter/material.dart';
 
import '../app/app_state.dart';
import '../domain/catalog.dart';
import '../domain/models.dart';
import 'add_measurement_sheet.dart';
import 'theme.dart';
import 'widgets.dart';
 
class IndicatorPage extends StatelessWidget {
  final String code;
 
  const IndicatorPage({super.key, required this.code});
 
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final indicator = indicatorByCode(code);
        final history = appState.history(code);
        final last = history.isEmpty ? null : history.last;
        final AlertLevel? level = last == null ? null : indicator.levelFor(last.value);
        final range = t('range.nominal', [
          indicator.format(indicator.nominalLow),
          indicator.format(indicator.nominalHigh),
          indicator.unit,
        ]);
        final hazards = indicator.hazards.map((h) => t('haz.${h.name}.name')).join(', ');
 
        return Scaffold(
          appBar: AppBar(title: Text(t('ind.$code.name'))),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showAddMeasurement(context, code: code),
            icon: const Icon(Icons.add),
            label: Text(t('ind.measure')),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t('ind.last'), style: const TextStyle(fontSize: 12.5)),
                              const SizedBox(height: 4),
                              Text(
                                last == null
                                    ? t('home.nodata')
                                    : '${indicator.format(last.value)} ${indicator.unit}',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (last != null) Text(appState.formatDate(last.at)),
                            ],
                          ),
                        ),
                        LevelChip(level, large: true),
                      ],
                    ),
                  ),
                ),
                SectionTitle(t('ind.trend')),
                _TrendCard(indicator: indicator, history: history),
                InfoBlock(
                  icon: Icons.straighten,
                  title: t('ind.range'),

                  body: '$range\n${t('range.note')}',
                ),
                InfoBlock(
                  icon: Icons.info_outline,
                  title: t('ind.what'),
                  body: t('ind.$code.what'),
                ),
                InfoBlock(
                  icon: Icons.school_outlined,
                  title: t('ind.how'),
                  body: t('ind.$code.how'),
                ),
                InfoBlock(
                  icon: Icons.rocket_launch_outlined,
                  title: t('ind.space'),
                  body: '${t('ind.$code.space')}\n$hazards',
                ),
                if (history.isNotEmpty) ...[
                  SectionTitle(t('ind.history')),
                  Card(
                    child: Column(
                      children: [
                        for (final m in history.reversed.take(10))
                          ListTile(
                            dense: true,
                            leading: Icon(
                              levelIcon(indicator.levelFor(m.value)),
                              color: levelColor(context, indicator.levelFor(m.value)),
                            ),
                            title: Text('${indicator.format(m.value)} ${indicator.unit}'),
                            subtitle: Text(appState.formatDate(m.at)),
                            trailing: Icon(
                              m.synced ? Icons.cloud_done_outlined : Icons.phone_android,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
 
/// Curve of the indicator over a period chosen by the astronaut: last 24 hours,
/// 7 days, 30 days, or everything. The points are placed according to their date.
class _TrendCard extends StatefulWidget {
  final Indicator indicator;
  final List<Measurement> history;
 
  const _TrendCard({required this.indicator, required this.history});
 
  @override
  State<_TrendCard> createState() => _TrendCardState();
}
 
class _TrendCardState extends State<_TrendCard> {
  // Kept for the whole session, so that every indicator opens on the same period.
  static String _period = '7d';
 
  static const Map<String, Duration?> _lengths = {
    '24h': Duration(hours: 24),
    '7d': Duration(days: 7),
    '30d': Duration(days: 30),
    'all': null,
  };
 
  @override
  Widget build(BuildContext context) {
    final i = widget.indicator;
    final now = DateTime.now();
    final length = _lengths[_period];
    final all = widget.history;
    final start = length != null
        ? now.subtract(length)
        : (all.isEmpty ? now.subtract(const Duration(days: 1)) : all.first.at);
    final shown = [
      for (final m in all)
        if (!m.at.isBefore(start)) m,

    ];
    final total = now.difference(start).inSeconds;
    double place(DateTime d) => total <= 0 ? 0.5 : d.difference(start).inSeconds / total;
 
    var low = 0.0;
    var high = 0.0;
    var sum = 0.0;
    for (final m in shown) {
      if (m == shown.first || m.value < low) low = m.value;
      if (m == shown.first || m.value > high) high = m.value;
      sum += m.value;
    }
 
    Widget stat(String label, String value) => Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ),
    );
 
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                for (final p in _lengths.keys)
                  ButtonSegment<String>(value: p, label: Text(t('period.$p'))),
              ],
              selected: {_period},
              onSelectionChanged: (s) => setState(() => _period = s.first),
            ),
            const SizedBox(height: 12),
            if (shown.isEmpty)
              Padding(padding: const EdgeInsets.all(12), child: Text(t('trend.none')))
            else ...[
              LineChart(
                values: [for (final m in shown) m.value],
                levels: [for (final m in shown) i.levelFor(m.value)],
                bandLow: i.nominalLow,
                bandHigh: i.nominalHigh,
                xs: [for (final m in shown) place(m.at)],
                startLabel: appState.formatDate(start),
                endLabel: appState.formatDate(now),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  stat(t('trend.min'), '${i.format(low)} ${i.unit}'),
                  stat(t('trend.avg'), '${i.format(sum / shown.length)} ${i.unit}'),
                  stat(t('trend.max'), '${i.format(high)} ${i.unit}'),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                t('trend.count', [shown.length]),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
