import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/astrocare_provider.dart';
import '../theme.dart';

class ScenarioSelectorModal extends StatelessWidget {
  const ScenarioSelectorModal({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AstroCareProvider>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AstroTheme.bgDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          top: BorderSide(color: AstroTheme.borderCard, width: 1.5),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 14,
                      color: AstroTheme.spaceCyan,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'JURY DEMO SCENARIO SELECTOR',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: AstroTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AstroTheme.textMuted, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Inject simulated multi-stressor flight events to demonstrate AstroCare\'s autonomous triage and non-linear synergy modeling for NASA judges.',
              style: TextStyle(
                fontSize: 11.5,
                color: AstroTheme.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),
            _buildScenarioItem(
              context,
              title: '1. Nominal Artemis Lunar Base',
              subtitle: 'Optimal biometrics, standard radiation background (0.8 uSv/h), nominal circadian rhythm.',
              color: AstroTheme.nominalEmerald,
              isSelected: provider.activeScenario == MissionScenario.nominalArtemis,
              onTap: () {
                provider.loadScenario(MissionScenario.nominalArtemis);
                Navigator.pop(context);
              },
            ),
            _buildScenarioItem(
              context,
              title: '2. EVA Solar Particle Event (SPE Spike)',
              subtitle: 'High proton flux (28.6 uSv/h), tachycardia, shelter protocol MED-SPE-04 immediately triggered.',
              color: AstroTheme.criticalCoral,
              isSelected: provider.activeScenario == MissionScenario.solarFlareEva,
              onTap: () {
                provider.loadScenario(MissionScenario.solarFlareEva);
                Navigator.pop(context);
              },
            ),
            _buildScenarioItem(
              context,
              title: '3. SANS Cephalad Fluid Shift & Insomnia',
              subtitle: '3.5h sleep, intracranial pressure elevated (21.8 mmHg), compound neuro-ocular synergy alert.',
              color: AstroTheme.cautionAmber,
              isSelected: provider.activeScenario == MissionScenario.sansCrisis,
              onTap: () {
                provider.loadScenario(MissionScenario.sansCrisis);
                Navigator.pop(context);
              },
            ),
            _buildScenarioItem(
              context,
              title: '4. Airlock Hypercapnia & Hypoxia',
              subtitle: 'SpO2 drops to 88.5%, cabin CO2 spikes to 5.2 mmHg, emergency breathing checklist pops up.',
              color: AstroTheme.criticalCoral,
              isSelected: provider.activeScenario == MissionScenario.airlockHypoxia,
              onTap: () {
                provider.loadScenario(MissionScenario.airlockHypoxia);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.1) : AstroTheme.cardDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? color : AstroTheme.borderCard,
          width: isSelected ? 1.4 : 1.0,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        leading: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isSelected ? Icons.check : Icons.play_arrow,
            size: 14,
            color: color,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? color : AstroTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 10.5,
            color: AstroTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
