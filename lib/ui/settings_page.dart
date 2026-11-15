// Settings: profile, PDF report, online backup, language, theme, environment, sign-out.
 
import 'dart:io';
 
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
 
import '../app/app_state.dart';
import '../domain/models.dart';
import 'theme.dart';
import 'transmission_page.dart';
import 'widgets.dart';
 
const List<List<String>> _resources = [
  ['NASA HRP - 5 Hazards of Human Spaceflight', 'https://www.nasa.gov/hrp/hazards/'],
  ['NASA HRP - Risks of Human Spaceflight', 'https://www.nasa.gov/hrp/risks/'],
  ['NASA - Ongoing HRP Research in Space', 'https://www.nasa.gov/hrp/ongoing-hrp-research/'],
  [
    'CSA - Monitoring Radiation for Astronaut Health',
    'https://www.asc-csa.gc.ca/eng/news/articles/2026/'
        '2026-02-26-monitoring-radiation-astronaut-health.asp',
  ],
  [
    'CSA - Why Do We Conduct Science Experiments in Space?',
    'https://www.asc-csa.gc.ca/eng/iss/science/'
        'why-do-we-conduct-science-experiments-in-space.asp',
  ],
];
 
/// Builds the PDF on the device and hands it to the system share sheet, so it can be
/// sent to the ground through whatever channel the mission uses.
Future<void> _shareReport(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  final failed = t('report.failed');
  final subject = 'AstroCare - ${t('report.title')}';
  try {
    final bytes = appState.buildReportPdf();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/astrocare_report.pdf');
    await file.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        subject: subject,
      ),
    );
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(failed)));
  }
}
 
void _confirmSignOut(BuildContext context) {
  final pending = appState.pendingCount;
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(Icons.warning_amber_rounded),
      title: Text(t('settings.logout')),
      content: Text(
        pending > 0
            ? '${t('settings.logout.warn')}\n\n${t('settings.logout.pending', [pending])}'
            : t('settings.logout.warn'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(t('add.cancel')),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            appState.signOut();
          },
          child: Text(t('settings.logout')),
        ),
      ],
    ),

  );
}
Widget buildSettingsPage(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  final session = appState.session;
  final pending = appState.pendingCount;
 
  String syncText;
  IconData syncIcon;
  if (appState.syncing) {
    syncText = t('sync.running');
    syncIcon = Icons.cloud_upload_outlined;
  } else if (pending == 0) {
    syncText = t('sync.ok');
    syncIcon = Icons.cloud_done_outlined;
  } else {
    syncText = t('sync.pending', [pending]);
    syncIcon = Icons.phone_android;
  }
  final lastSync = appState.lastSyncAt;
 
  return ListView(
    padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
    children: [
      SectionTitle(t('settings.profile')),
      Card(
        child: ListTile(
          leading: CircleAvatar(child: Icon(Icons.person, color: scheme.primary)),
          title: Text(session?.name ?? ''),
          subtitle: Text('${session?.role ?? ''}\n${session?.email ?? ''}'),
          isThreeLine: true,
        ),
      ),
      SectionTitle(t('report.title')),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.satellite_alt, color: scheme.primary),
                title: Text(
                  t('tx.title'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(t('tx.open.hint', [appState.queuedReports])),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute<void>(builder: (_) => const TransmissionPage())),
              ),
              const Divider(height: 20),
              Text(t('report.hint'), style: const TextStyle(height: 1.35)),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _shareReport(context),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(t('report.button')),
                ),
              ),
            ],
          ),
        ),
      ),
      SectionTitle(t('sync.title')),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(syncIcon, color: scheme.primary),
                  const SizedBox(width: 10),
                  Expanded(child: Text(syncText, style: const TextStyle(height: 1.35))),
                ],
              ),
              if (lastSync != null) ...[

                const SizedBox(height: 6),
                Text(
                  t('sync.last', [appState.formatDate(lastSync)]),
                  style: const TextStyle(fontSize: 12.5),
                ),
              ],
              if (pending > 0 && appState.lastSyncFailed && !appState.syncing) ...[
                const SizedBox(height: 6),
                Text(t('sync.failed'), style: const TextStyle(fontSize: 12.5)),
              ],
              if (pending > 0) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: appState.syncing ? null : () => appState.sync(),
                  icon: const Icon(Icons.sync),
                  label: Text(t('sync.now')),
                ),
              ],
            ],
          ),
        ),
      ),
      SectionTitle(t('nav.settings')),
      Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t('settings.language'), style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment<String>(value: 'en', label: Text('English')),
                  ButtonSegment<String>(value: 'fr', label: Text('Français')),
                ],
                selected: {appState.lang},
                onSelectionChanged: (s) => appState.setLanguage(s.first),
              ),
              const SizedBox(height: 14),
              Text(
                t('settings.environment'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              DropdownButton<MissionEnvironment>(
                value: appState.environment,
                isExpanded: true,
                items: [
                  for (final e in MissionEnvironment.values)
                    DropdownMenuItem<MissionEnvironment>(
                      value: e,
                      child: Text(t('env.${e.name}')),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) appState.setEnvironment(v);
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: appState.darkMode,
                onChanged: (v) => appState.setDarkMode(v),
                title: Text(t('settings.theme')),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 8),
      Card(
        child: ExpansionTile(
          leading: const Icon(Icons.info_outline),
          title: Text(t('about.title')),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: kBrandGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(child: AppLogo(height: 84)),

            ),
            const SizedBox(height: 12),
            Text(t('about.team'), style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(t('about.disclaimer'), style: const TextStyle(height: 1.35)),
            const Divider(height: 24),
            Text(t('about.resources'), style: const TextStyle(fontWeight: FontWeight.w700)),
            for (final r in _resources)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r[0], style: const TextStyle(fontSize: 13)),
                    SelectableText(r[1], style: TextStyle(fontSize: 12, color: scheme.primary)),
                  ],
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: () => _confirmSignOut(context),
        icon: Icon(Icons.logout, color: scheme.error),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(t('settings.logout'), style: TextStyle(color: scheme.error)),
        ),
      ),
    ],
  );
}
