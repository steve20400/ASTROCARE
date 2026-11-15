// Alerts: the list, and for each alert the first aid to give, the cause and the follow-up.
 
import 'package:flutter/material.dart';
 
import '../app/app_state.dart';
import '../domain/catalog.dart';
import '../domain/models.dart';
import 'add_measurement_sheet.dart';
import 'theme.dart';
import 'widgets.dart';
 
Widget buildAlertsPage(BuildContext context) {
  final all = appState.sortedAlerts();
  final open = all.where((a) => a.isOpen).toList();
  final past = all.where((a) => !a.isOpen).take(15).toList();
 
  return ListView(
    padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
    children: [
      if (open.isEmpty)
        Card(
          child: ListTile(
            leading: Icon(Icons.check_circle, color: levelColor(context, AlertLevel.nominal)),
            title: Text(t('alerts.none')),
          ),
        )
      else ...[
        SectionTitle('${t('alerts.open')} (${open.length})'),
        for (final a in open) _AlertTile(alert: a),
      ],
      if (past.isNotEmpty) ...[
        SectionTitle(t('alerts.past')),
        for (final a in past) _AlertTile(alert: a),
      ],
    ],
  );
}
 
class _AlertTile extends StatelessWidget {
  final HealthAlert alert;
  const _AlertTile({required this.alert});
 
  @override
  Widget build(BuildContext context) {
    final indicator = indicatorByCode(alert.indicator);
    final color = alert.isOpen ? levelColor(context, alert.level) : levelColor(context, null);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => AlertDetailPage(alertId: alert.id))),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 8, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(levelIcon(alert.level), color: color, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${t('ind.${alert.indicator}.name')}: '
                              '${indicator.format(alert.value)} ${indicator.unit}',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${t('level.${alert.level.name}')} - '
                              '${t('status.${alert.status.name}')}',
                              style: const TextStyle(fontSize: 13),

                            ),
                            Text(
                              appState.formatDate(alert.createdAt),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
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
 
class AlertDetailPage extends StatelessWidget {
  final String alertId;
 
  const AlertDetailPage({super.key, required this.alertId});
 
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final alert = appState.alertById(alertId);
        if (alert == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(t('alerts.none'))),
          );
        }
        final code = alert.indicator;
        final indicator = indicatorByCode(code);
        final color = levelColor(context, alert.level);
        final rule = alert.ruleId.isEmpty ? null : synergyById(alert.ruleId);
        final critical = alert.level == AlertLevel.critical;
        final aid = 'aid.$code.${aidSide(indicator, alert.value)}';
        final hasAid = t('$aid.steps') != '$aid.steps';
        final steps = (hasAid ? t('$aid.steps') : t('aid.generic.steps')).split('|');
 
        var causeText = t('cause.${alert.cause.name}');
        if (rule != null) {
          causeText = '$causeText\n${t('syn.${rule.id}.name')}: ${t('syn.${rule.id}.risk')}';
        }
        causeText = '$causeText\n${t('ind.$code.space')}';
        var recoText = t('alert.ground');
        if (rule != null) recoText = '${t('syn.${rule.id}.advice')}\n$recoText';
 
        return Scaffold(
          appBar: AppBar(title: Text(t('ind.$code.name'))),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withAlpha(36),
                    border: Border.all(color: color, width: 1.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(levelIcon(alert.level), color: color, size: 40),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${t('level.${alert.level.name}')} - '
                              '${t('status.${alert.status.name}')}',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                              ),

                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${t('alert.value')}: ${indicator.format(alert.value)} '
                              '${indicator.unit}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            Text(appState.formatDate(alert.createdAt)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.medical_services_outlined, color: color),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                hasAid ? '${t('aid.title')}: ${t('$aid.title')}' : t('aid.title'),
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (critical)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              t('aid.critical'),
                              style: TextStyle(color: color, fontWeight: FontWeight.w700),
                            ),
                          ),
                        StepList(steps: steps, color: color),
                      ],
                    ),
                  ),
                ),
                if (hasAid)
                  InfoBlock(
                    icon: Icons.emergency_outlined,
                    title: t('aid.urgent'),
                    body: t('$aid.urgent'),
                  ),
                InfoBlock(icon: Icons.task_alt, title: t('alert.reco'), body: recoText),
                InfoBlock(icon: Icons.help_outline, title: t('alert.cause'), body: causeText),
                const SizedBox(height: 12),
                if (alert.status == AlertStatus.active)
                  FilledButton.icon(
                    onPressed: () {
                      appState.acknowledge(alert.id);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(t('alert.acked'))));
                    },
                    icon: const Icon(Icons.check),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(t('alert.ack')),
                    ),
                  ),
                if (alert.isOpen) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => showAddMeasurement(context, code: code),
                    icon: const Icon(Icons.replay),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(t('alert.control')),
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
