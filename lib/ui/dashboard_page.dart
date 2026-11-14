// Dashboard: who I am, how I am, what is due, and every indicator at a glance.
 
import 'package:flutter/material.dart';
 
import '../app/app_state.dart';
import '../domain/catalog.dart';
import '../domain/models.dart';
import 'add_measurement_sheet.dart';
import 'indicator_page.dart';
import 'theme.dart';
import 'widgets.dart';
 
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
 
  @override
  Widget build(BuildContext context) {
    final member = appState.currentMember;
    final level = appState.memberLevel(member.id);
    final streak = appState.streak(member.id);
    final due = appState.dueReminders(member.id);
    final scheme = Theme.of(context).colorScheme;
 
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t('dash.member'), style: TextStyle(color: scheme.primary, fontSize: 12.5)),
                DropdownButton<String>(
                  value: member.id,
                  isExpanded: true,
                  items: [
                    for (final m in appState.members)
                      DropdownMenuItem<String>(
                        value: m.id,
                        child: Text('${m.name} · ${m.role}', overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: (v) {
                    if (v != null) appState.selectMember(v);
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        t('dash.overall'),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                    LevelChip(level, large: true),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.public, size: 18, color: scheme.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(t('env.${appState.environment.name}'))),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.local_fire_department, size: 18, color: scheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        streak > 0 ? t('dash.streak', [streak]) : t('dash.streak.none'),
                      ),
                    ),
                  ],

                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.cloud_off, size: 18, color: scheme.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(t('dash.autonomous'))),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (due.isNotEmpty) ...[
          SectionTitle('${t('dash.reminders')} (${due.length})'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final i in due)
                    ActionChip(
                      avatar: const Icon(Icons.alarm, size: 18),
                      label: Text(t('ind.${i.code}.name')),
                      onPressed: () => showAddMeasurement(context, code: i.code),
                    ),
                ],
              ),
            ),
          ),
        ],
        SectionTitle(t('dash.indicators')),
        for (final i in kIndicators) _IndicatorTile(indicator: i, memberId: member.id),
      ],
    );
  }
}
 
class _IndicatorTile extends StatelessWidget {
  final Indicator indicator;
  final String memberId;
 
  const _IndicatorTile({required this.indicator, required this.memberId});
 
  @override
  Widget build(BuildContext context) {
    final last = appState.latest(memberId, indicator.code);
    final AlertLevel? level = last == null
        ? null
        : appState.levelOfValue(memberId, indicator, last.value);
    final color = levelColor(context, level);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => IndicatorPage(code: indicator.code))),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 8, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Row(
                    children: [
                      Icon(zoneIcon(indicator.zone), color: color),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t('ind.${indicator.code}.name'),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              last == null
                                  ? t('dash.nodata')
                                  : '${indicator.format(last.value)} ${indicator.unit}'

                                        ' · ${appState.formatDate(last.at)}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      LevelChip(level),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
