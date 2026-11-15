// Built-in first-aid guide, readable at any time and without any connection.
// When some indicators are in attention or critical, the guide shows only the first
// aid that concerns them. When everything is fine, it shows every situation.
 
import 'package:flutter/material.dart';
 
import '../app/app_state.dart';
import '../domain/catalog.dart';
import '../domain/models.dart';
import 'theme.dart';
import 'widgets.dart';
 
/// Situations that concern the astronaut now: one per indicator whose latest value is
/// outside its healthy range, or that has an open alert. Each entry is
/// [indicator code, side, level name].
List<List<String>> currentAidCases() {
  final cases = <List<String>>[];
  for (final i in kIndicators) {
    final last = appState.latest(i.code);
    if (last == null) continue;
    var level = i.levelFor(last.value);
    for (final a in appState.alerts) {
      if (a.indicator == i.code && a.isOpen) level = maxLevel(level, a.level);
    }
    if (level == AlertLevel.nominal) continue;
    final side = aidSide(i, last.value);
    final known = kAidCases.any((c) => c[0] == i.code && c[1] == side);
    if (known) cases.add([i.code, side, level.name]);
  }
  return cases;
}
 
class FirstAidPage extends StatefulWidget {
  const FirstAidPage({super.key});
 
  @override
  State<FirstAidPage> createState() => _FirstAidPageState();
}
 
class _FirstAidPageState extends State<FirstAidPage> {
  bool _showAll = false;
 
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final scheme = Theme.of(context).colorScheme;
        final current = currentAidCases();
        final filtered = current.isNotEmpty && !_showAll;
        return Scaffold(
          appBar: AppBar(title: Text(t('aid.guide'))),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
                  child: Text(
                    t(filtered ? 'aid.intro.current' : 'aid.intro'),
                    style: const TextStyle(height: 1.4),
                  ),
                ),
                if (filtered)
                  for (final c in current)
                    _caseCard(
                      context,
                      c[0],
                      c[1],
                      level: enumByName(AlertLevel.values, c[2], AlertLevel.attention),
                    )
                else
                  for (final c in kAidCases) _caseCard(context, c[0], c[1]),
                if (current.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: TextButton.icon(
                      onPressed: () => setState(() => _showAll = !_showAll),

                      icon: Icon(_showAll ? Icons.filter_alt_outlined : Icons.menu_book_outlined),
                      label: Text(t(_showAll ? 'aid.show.current' : 'aid.show.all')),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
                  child: Text(
                    t('aid.source'),
                    style: TextStyle(fontSize: 12.5, height: 1.4, color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
 
  /// One situation. With a [level], the card belongs to the astronaut's current state:
  /// it is open and shows the status.
  Widget _caseCard(BuildContext context, String code, String side, {AlertLevel? level}) {
    final scheme = Theme.of(context).colorScheme;
    final key = 'aid.$code.$side';
    final color = level == null ? scheme.primary : levelColor(context, level);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        key: ValueKey('$key-${level?.name}'),
        initiallyExpanded: level != null,
        leading: Icon(indicatorIcon(code), color: color),
        title: Text(t('$key.title'), style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          level == null
              ? t('ind.$code.name')
              : '${t('ind.$code.name')} - ${t('level.${level.name}')}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepList(steps: t('$key.steps').split('|'), color: color),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.emergency_outlined, size: 20, color: scheme.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${t('aid.urgent')}: ${t('$key.urgent')}',
                  style: const TextStyle(height: 1.35, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
