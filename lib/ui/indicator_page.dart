// Detail of one indicator: status, curve, reference range, explanations, history.
 
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
        final recent = history.length > 30 ? history.sublist(history.length - 30) : history;
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: recent.length < 2

                        ? Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(t('ind.needTwo')),
                          )
                        : LineChart(
                            values: [for (final m in recent) m.value],
                            levels: [for (final m in recent) indicator.levelFor(m.value)],
                            bandLow: indicator.nominalLow,
                            bandHigh: indicator.nominalHigh,
                          ),
                  ),
                ),
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
