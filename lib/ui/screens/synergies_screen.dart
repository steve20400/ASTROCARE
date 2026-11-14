import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/astrocare_provider.dart';
import '../theme.dart';
import '../widgets/synergy_card.dart';

class SynergiesScreen extends StatelessWidget {
  const SynergiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AstroCareProvider>();
    final synergies = provider.activeSynergies;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AstroTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AstroTheme.borderCard),
              ),
              child: const Icon(Icons.hub, color: AstroTheme.spaceCyan, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              'NASA HRP SYNERGY MATRIX',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Mathematical Formulation Card (NASA SpaceGenes+ Level Modeling)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AstroTheme.cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AstroTheme.borderCard),
            ),
            child: Column(
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
                          'NON-LINEAR RISK FORMULATION',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: AstroTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AstroTheme.bgDark,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: AstroTheme.borderCard),
                      ),
                      child: const Text(
                        'CALIBRATION: OSD-288',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontFamily: 'monospace',
                          color: AstroTheme.spaceCyan,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Mathematical equation display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: AstroTheme.bgDark,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AstroTheme.borderCard),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'S_compound = 1 - ∏(1 - r_i) · [ 1 + ∑ γ_ij · r_i · r_j ]',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w700,
                          color: AstroTheme.spaceCyan,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Where γ_ij represents the biological cross-coupling coefficient between stressors i and j.',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: AstroTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                const Text(
                  'Isolated bio-markers fail to capture spaceflight pathophysiology. AstroCare models compound synergies where microgravity, cosmic radiation, and sleep debt produce multiplicative damage rather than additive strain.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AstroTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),

                // 5 Hazard Tags
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: const [
                    _HazardBadge(tag: 'R', title: 'Radiation', code: 'SPE/GCR'),
                    _HazardBadge(tag: 'I', title: 'Isolation', code: 'Circadian'),
                    _HazardBadge(tag: 'D', title: 'Distance', code: '22m Latency'),
                    _HazardBadge(tag: 'G', title: 'Gravity', code: 'Fluid Shift'),
                    _HazardBadge(tag: 'E', title: 'Environment', code: 'ECLSS/CO2'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'EVALUATED SYNERGY VECTORS (${synergies.length})',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  fontFamily: 'monospace',
                  color: AstroTheme.textSecondary,
                ),
              ),
              const Text(
                'CYCLE: CONTINUOUS',
                style: TextStyle(
                  fontSize: 8.5,
                  fontFamily: 'monospace',
                  color: AstroTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...synergies.map((s) => SynergyRiskCard(factor: s)),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _HazardBadge extends StatelessWidget {
  final String tag;
  final String title;
  final String code;

  const _HazardBadge({
    required this.tag,
    required this.title,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AstroTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AstroTheme.borderCard),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '[$tag]',
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              fontFamily: 'monospace',
              color: AstroTheme.spaceCyan,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$title ($code)',
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: AstroTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
