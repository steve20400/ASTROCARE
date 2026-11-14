// Alerts: the list, and for each alert the cause, the recommendations and the protocol.
 
import 'package:flutter/material.dart';
 
import '../app/app_state.dart';
import '../domain/catalog.dart';
import '../domain/models.dart';
import 'add_measurement_sheet.dart';
import 'theme.dart';
import 'widgets.dart';
 
class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});
 
  @override
  State<AlertsPage> createState() => _AlertsPageState();
}
 
class _AlertsPageState extends State<AlertsPage> {
  bool _wholeCrew = false;
 
  @override
  Widget build(BuildContext context) {
    final commander = appState.currentMember.isCommander;
    final String? scope = (commander && _wholeCrew) ? null : appState.currentMemberId;
    final all = appState.allAlerts(scope);
    final open = all.where((a) => a.isOpen).toList();
    final past = all.where((a) => !a.isOpen).take(15).toList();
 
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        if (commander)
          SwitchListTile(
            value: _wholeCrew,
            onChanged: (v) => setState(() => _wholeCrew = v),
            title: Text(t('alerts.crew')),
            secondary: const Icon(Icons.groups_outlined),
          ),
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
}
 
class _AlertTile extends StatelessWidget {
  final HealthAlert alert;
 
  const _AlertTile({required this.alert});
 
  @override
  Widget build(BuildContext context) {
    final indicator = indicatorByCode(alert.indicator);
    final color = alert.isOpen ? levelColor(context, alert.level) : levelColor(context, null);
    final member = appState.memberById(alert.memberId);
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
                              '${member.name} · ${t('level.${alert.level.name}')} · '
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
        final member = appState.memberById(alert.memberId);
        final color = levelColor(context, alert.level);
        final rule = alert.ruleId.isEmpty ? null : synergyById(alert.ruleId);
        final critical = alert.level == AlertLevel.critical;
        final steps = t('ind.$code.critical').split('|');
 
        var causeText = t('cause.${alert.cause.name}');
        if (rule != null) {
          causeText = '$causeText\n${t('syn.${rule.id}.name')}: ${t('syn.${rule.id}.risk')}';
        }
        var recoText = t('ind.$code.attention');
        if (rule != null) recoText = '$recoText\n${t('syn.${rule.id}.advice')}';
        recoText = '$recoText\n${t('alert.ground')}';
 
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
                              '${t('level.${alert.level.name}')} · '
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
                            Text('${member.name} · ${appState.formatDate(alert.createdAt)}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (critical)
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
                              Text(
                                t('alert.protocol'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          for (var i = 0; i < steps.length; i++)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 13,
                                    backgroundColor: color,
                                    child: Text(
                                      '${i + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      steps[i],
                                      style: const TextStyle(fontSize: 15, height: 1.35),
                                    ),
                                  ),
                                ],

                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                InfoBlock(icon: Icons.help_outline, title: t('alert.cause'), body: causeText),
                InfoBlock(icon: Icons.task_alt, title: t('alert.reco'), body: recoText),
                InfoBlock(
                  icon: Icons.rocket_launch_outlined,
                  title: t('alert.space'),
                  body:
                      '${t('ind.$code.space')}\n'
                      '${indicator.hazards.map((h) => t('haz.${h.name}.name')).join(' · ')}',
                ),
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
                if (alert.isOpen && alert.memberId == appState.currentMemberId) ...[
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
