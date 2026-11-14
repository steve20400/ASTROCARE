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
        final member = appState.currentMember;
        final history = appState.history(member.id, code);
        final last = history.isEmpty ? null : history.last;
        final AlertLevel? level = last == null
            ? null
            : appState.levelOfValue(member.id, indicator, last.value);
        final recent = history.length > 30 ? history.sublist(history.length - 30) : history;
 
        String range;
        double? bandLow;
        double? bandHigh;
        if (indicator.relativeToBaseline) {
          range = t('range.relative', [
            indicator.nominalHigh.toStringAsFixed(0),
            member.baselineWeight.toStringAsFixed(1),
          ]);
          if (member.baselineWeight > 0) {
            bandLow = member.baselineWeight * (1 + indicator.nominalLow / 100);
            bandHigh = member.baselineWeight * (1 + indicator.nominalHigh / 100);
          }
        } else {
          range = t('range.nominal', [
            indicator.format(indicator.nominalLow),
            indicator.format(indicator.nominalHigh),
            indicator.unit,
          ]);
          bandLow = indicator.nominalLow;
          bandHigh = indicator.nominalHigh;
        }
 
        return Scaffold(
          appBar: AppBar(title: Text(t('ind.$code.name'))),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showAddMeasurement(context, code: code),
            icon: const Icon(Icons.add),
            label: Text(t('dash.measure')),
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
                              Text(
                                '${member.name} · ${t('ind.last')}',
                                style: const TextStyle(fontSize: 12.5),
                              ),
                              const SizedBox(height: 4),
                              Text(

                                last == null
                                    ? t('dash.nodata')
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
                            levels: [
                              for (final m in recent)
                                appState.levelOfValue(member.id, indicator, m.value),
                            ],
                            bandLow: bandLow,
                            bandHigh: bandHigh,
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.rocket_launch_outlined,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              t('ind.space'),
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(t('ind.$code.space'), style: const TextStyle(height: 1.4)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 2,
                          children: [
                            for (final h in indicator.hazards)
                              Chip(
                                avatar: CircleAvatar(child: Text(hazardLetter(h))),
                                label: Text(t('haz.${h.name}.name')),
                              ),

                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (history.isNotEmpty) ...[
                  SectionTitle(t('ind.history')),
                  Card(
                    child: Column(
                      children: [
                        for (final m in history.reversed.take(12))
                          ListTile(
                            dense: true,
                            leading: Icon(
                              levelIcon(appState.levelOfValue(member.id, indicator, m.value)),
                              color: levelColor(
                                context,
                                appState.levelOfValue(member.id, indicator, m.value),
                              ),
                            ),
                            title: Text('${indicator.format(m.value)} ${indicator.unit}'),
                            trailing: Text(appState.formatDate(m.at)),
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
