// Settings, crew overview, reminders, report for the ground, demo data and about.
 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
 
import '../app/app_state.dart';
import '../domain/catalog.dart';
import '../domain/models.dart';
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
    'https://www.asc-csa.gc.ca/eng/iss/science/why-do-we-conduct-science-experiments-in-space.asp',
  ],
];
 
class MorePage extends StatelessWidget {
  const MorePage({super.key});
 
  void _showReport(BuildContext context) {
    final report = appState.buildReport();
    final messenger = ScaffoldMessenger.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t('report.title')),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(report, style: const TextStyle(fontSize: 12.5, height: 1.35)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(t('report.close')),
          ),
          FilledButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: report));
              Navigator.of(dialogContext).pop();
              messenger.showSnackBar(SnackBar(content: Text(t('report.copied'))));
            },
            icon: const Icon(Icons.copy),
            label: Text(t('report.copy')),
          ),
        ],
      ),
    );
  }
 
  void _confirmReset(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t('demo.reset')),
        content: Text(t('demo.confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(t('add.cancel')),
          ),
          FilledButton(
            onPressed: () {
              appState.resetAll();
              Navigator.of(dialogContext).pop();
            },
            child: Text(t('demo.yes')),
          ),

        ],
      ),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      children: [
        SectionTitle(t('settings.section')),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('settings.language'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
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
                  onChanged: appState.setDarkMode,
                  title: Text(t('settings.theme')),
                ),
              ],
            ),
          ),
        ),
        SectionTitle(t('crew.title')),
        Card(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(t('crew.hint'), style: const TextStyle(fontSize: 12.5)),
                ),
              ),
              for (final m in appState.members)
                ListTile(
                  leading: Icon(
                    m.id == appState.currentMemberId
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: scheme.primary,
                  ),
                  title: Text(m.name),
                  subtitle: Text(m.role),
                  trailing: LevelChip(appState.memberLevel(m.id)),
                  onTap: () => appState.selectMember(m.id),
                ),

            ],
          ),
        ),
        SectionTitle(t('report.title')),
        Card(
          child: ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(t('report.button')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showReport(context),
          ),
        ),
        SectionTitle(t('rem.title')),
        Card(
          child: Column(
            children: [
              for (final i in kIndicators)
                ListTile(
                  dense: true,
                  title: Text(t('ind.${i.code}.name')),
                  trailing: DropdownButton<int>(
                    value: const [0, 8, 12, 24].contains(appState.reminders[i.code])
                        ? appState.reminders[i.code]
                        : 24,
                    underline: const SizedBox(),
                    items: [
                      DropdownMenuItem<int>(value: 0, child: Text(t('rem.off'))),
                      for (final h in const [8, 12, 24])
                        DropdownMenuItem<int>(value: h, child: Text(t('rem.every', [h]))),
                    ],
                    onChanged: (v) {
                      if (v != null) appState.setReminder(i.code, v);
                    },
                  ),
                ),
            ],
          ),
        ),
        SectionTitle(t('demo.title')),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.science_outlined),
                title: Text(t('demo.load')),
                onTap: () {
                  appState.loadDemo();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(t('demo.loaded'))));
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: scheme.error),
                title: Text(t('demo.reset')),
                onTap: () => _confirmReset(context),
              ),
            ],
          ),
        ),
        SectionTitle(t('about.title')),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t('about.team'), style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(t('about.disclaimer'), style: const TextStyle(height: 1.35)),
                const SizedBox(height: 8),
                Text(t('about.ai'), style: const TextStyle(height: 1.35)),
                const Divider(height: 24),
                Text(t('about.resources'), style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                for (final r in _resources)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r[0], style: const TextStyle(fontSize: 13)),
                        SelectableText(
                          r[1],

                          style: TextStyle(fontSize: 12, color: scheme.primary),
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
