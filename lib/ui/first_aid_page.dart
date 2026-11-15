// Built-in first-aid guide: every situation the app can detect, readable at any time
// and without any connection.
 
import 'package:flutter/material.dart';
 
import '../app/app_state.dart';
import '../domain/catalog.dart';
import 'theme.dart';
import 'widgets.dart';
 
class FirstAidPage extends StatelessWidget {
  const FirstAidPage({super.key});
 
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final scheme = Theme.of(context).colorScheme;
        return Scaffold(
          appBar: AppBar(title: Text(t('aid.guide'))),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
                  child: Text(t('aid.intro'), style: const TextStyle(height: 1.4)),
                ),
                for (final c in kAidCases) _caseCard(context, c[0], c[1]),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 14, 4, 0),
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
 
  Widget _caseCard(BuildContext context, String code, String side) {
    final scheme = Theme.of(context).colorScheme;
    final key = 'aid.$code.$side';
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(indicatorIcon(code), color: scheme.primary),
        title: Text(t('$key.title'), style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(t('ind.$code.name')),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepList(steps: t('$key.steps').split('|'), color: scheme.primary),
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
          const SizedBox(height: 10),
          Text(
            '${t('aid.ref')}: ${kNasaRisk[code] ?? ''}',
            style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
          ),
        ],

      ),
    );
  }
}
