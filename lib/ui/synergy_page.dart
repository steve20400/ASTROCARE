// Synergies: how indicators and spaceflight hazards combine to raise the risk.
 
import 'package:flutter/material.dart';
 
import '../app/app_state.dart';
import '../domain/catalog.dart';
import '../domain/models.dart';
import 'theme.dart';
import 'widgets.dart';
 
class SynergyPage extends StatelessWidget {
  const SynergyPage({super.key});
 
  @override
  Widget build(BuildContext context) {
    final memberId = appState.currentMemberId;
    final active = appState.activeSynergies(memberId);
    final activeIds = {for (final r in active) r.id};
    final hazards = appState.activeHazards;
    final scheme = Theme.of(context).colorScheme;
 
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        Text(
          '${appState.currentMember.name} · ${t('env.${appState.environment.name}')}',
          style: TextStyle(color: scheme.primary),
        ),
        SectionTitle(t('synergy.rules')),
        if (active.isEmpty)
          Card(
            child: ListTile(
              leading: Icon(Icons.check_circle, color: levelColor(context, AlertLevel.nominal)),
              title: Text(t('synergy.none')),
            ),
          ),
        for (final rule in kSynergyRules)
          _RuleCard(rule: rule, memberId: memberId, active: activeIds.contains(rule.id)),
        SectionTitle(t('synergy.heatmap')),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t('synergy.heatmap.hint'), style: const TextStyle(fontSize: 12.5)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Expanded(child: SizedBox()),
                    for (final h in Hazard.values)
                      SizedBox(
                        width: 34,
                        child: Center(
                          child: Tooltip(
                            message: t('haz.${h.name}.name'),
                            child: Text(
                              hazardLetter(h),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: hazards.contains(h) ? scheme.primary : scheme.outline,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                for (final i in kIndicators)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            t('ind.${i.code}.name'),
                            style: const TextStyle(fontSize: 12.5),

                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        for (final h in Hazard.values)
                          _HeatCell(
                            linked: i.hazards.contains(h),
                            hazardActive: hazards.contains(h),
                            level: appState.levelOf(memberId, i.code),
                          ),
                      ],
                    ),
                  ),
                const Divider(height: 22),
                for (final h in Hazard.values)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 22,
                          child: Text(
                            hazardLetter(h),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${t('haz.${h.name}.name')}: ${t('haz.${h.name}.desc')}',
                            style: const TextStyle(fontSize: 12.5, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
 
class _HeatCell extends StatelessWidget {
  final bool linked;
  final bool hazardActive;
  final AlertLevel? level;
 
  const _HeatCell({required this.linked, required this.hazardActive, required this.level});
 
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color fill;
    Widget? mark;
    if (!linked) {
      fill = scheme.outline.withAlpha(24);
    } else {
      final c = levelColor(context, level);
      fill = hazardActive ? c : c.withAlpha(70);
      mark = Icon(levelIcon(level), size: 14, color: Colors.white);
    }
    return SizedBox(
      width: 34,
      height: 26,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: DecoratedBox(
          decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(5)),
          child: mark == null ? null : Center(child: mark),
        ),
      ),
    );
  }
}
 
class _RuleCard extends StatelessWidget {
  final SynergyRule rule;
  final String memberId;
  final bool active;
  const _RuleCard({required this.rule, required this.memberId, required this.active});
 
  @override

  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = active ? levelColor(context, rule.level) : levelColor(context, null);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 8, color: color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            t('syn.${rule.id}.name'),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              active ? levelIcon(rule.level) : Icons.remove_circle_outline,
                              size: 16,
                              color: color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              active ? t('synergy.active') : t('synergy.inactive'),
                              style: TextStyle(color: color, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(t('synergy.conditions'), style: const TextStyle(fontSize: 12.5)),
                    const SizedBox(height: 4),
                    for (final code in rule.conditions)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Expanded(child: Text(t('ind.$code.name'))),
                            LevelChip(appState.levelOf(memberId, code)),
                          ],
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      t('synergy.under', [t('haz.${rule.hazard.name}.name')]),
                      style: TextStyle(fontSize: 12.5, color: scheme.primary),
                    ),
                    if (active) ...[
                      const Divider(height: 20),
                      Text(
                        t('synergy.risk'),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(t('syn.${rule.id}.risk'), style: const TextStyle(height: 1.35)),
                      const SizedBox(height: 8),
                      Text(
                        t('synergy.advice'),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(t('syn.${rule.id}.advice'), style: const TextStyle(height: 1.35)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
