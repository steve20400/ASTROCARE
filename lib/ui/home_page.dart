// Home: who I am, how I am, and my four indicators. Nothing else.
 
import 'package:flutter/material.dart';
 
import '../app/app_state.dart';
import '../domain/catalog.dart';
import '../domain/models.dart';
import 'indicator_page.dart';
import 'theme.dart';
import 'widgets.dart';
 
Widget buildHomePage(BuildContext context) {
  final session = appState.session;
  final overall = appState.overallLevel();
  final synergies = appState.activeSynergies();
  final scheme = Theme.of(context).colorScheme;
 
  return ListView(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
    children: [
      Text(
        t('home.hello', [session?.name ?? '']),
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      if ((session?.role ?? '').isNotEmpty)
        Text(session!.role, style: TextStyle(color: scheme.primary)),
      const SizedBox(height: 16),
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
                      t('home.overall'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    if (overall == null) ...[const SizedBox(height: 4), Text(t('home.start'))],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              LevelChip(overall, large: true),
            ],
          ),
        ),
      ),
      for (final rule in synergies) _CombinedRisk(rule: rule),
      const SizedBox(height: 8),
      for (var row = 0; row < kIndicators.length; row += 2)
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _IndicatorCard(indicator: kIndicators[row])),
                const SizedBox(width: 4),
                Expanded(
                  child: row + 1 < kIndicators.length
                      ? _IndicatorCard(indicator: kIndicators[row + 1])
                      : const SizedBox(),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}
 
class _CombinedRisk extends StatelessWidget {
  final SynergyRule rule;
 
  const _CombinedRisk({required this.rule});

  @override
  Widget build(BuildContext context) {
    final color = levelColor(context, rule.level);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          border: Border.all(color: color, width: 1.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(levelIcon(rule.level), color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${t('home.combined')}: ${t('syn.${rule.id}.name')}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(t('syn.${rule.id}.advice'), style: const TextStyle(height: 1.35)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 
class _IndicatorCard extends StatelessWidget {
  final Indicator indicator;
 
  const _IndicatorCard({required this.indicator});
  @override
  Widget build(BuildContext context) {
    final last = appState.latest(indicator.code);
    final AlertLevel? level = last == null ? null : indicator.levelFor(last.value);
    final color = levelColor(context, level);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => IndicatorPage(code: indicator.code))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(height: 6, color: color),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(indicatorIcon(indicator.code), color: color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t('ind.${indicator.code}.name'),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    last == null ? '--' : '${indicator.format(last.value)} ${indicator.unit}',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  LevelChip(level),
                ],
              ),
            ),
          ],

        ),
      ),
    );
  }
}
