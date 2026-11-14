import 'package:flutter/material.dart';
import '../../models/vitals.dart';
import '../../models/synergy.dart';
import '../theme.dart';

class SynergyRiskCard extends StatelessWidget {
  final SynergyRiskFactor factor;
  final VoidCallback? onOpenProtocol;

  const SynergyRiskCard({
    super.key,
    required this.factor,
    this.onOpenProtocol,
  });

  Color _getSeverityColor() {
    switch (factor.severity) {
      case HealthStatus.nominal:
        return AstroTheme.nominalEmerald;
      case HealthStatus.caution:
        return AstroTheme.cautionAmber;
      case HealthStatus.critical:
        return AstroTheme.criticalCoral;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getSeverityColor();
    final riskPercent = (factor.compoundRiskScore * 100).toInt();
    final isCritical = factor.severity == HealthStatus.critical;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AstroTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCritical ? statusColor : AstroTheme.borderCard,
          width: isCritical ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Badge & Category Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AstroTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AstroTheme.borderCard),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        factor.hazardCategory.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          fontFamily: 'monospace',
                          color: AstroTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: statusColor, width: 0.8),
                  ),
                  child: Text(
                    'RISK INDEX: $riskPercent%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace',
                      color: statusColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Clinical Synergy Title
            Text(
              factor.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AstroTheme.textPrimary,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 10),

            // Contributing Cross-Stressors
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AstroTheme.bgDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AstroTheme.borderCard),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CONTRIBUTING HRP R.I.D.G.E. STRESSORS',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      fontFamily: 'monospace',
                      color: AstroTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...factor.contributingStressors.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(
                              fontSize: 11,
                              color: AstroTheme.spaceCyan,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              s,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AstroTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Physiological Impact
            const Text(
              'CLINICAL MANIFESTATION & PATHOLOGY',
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                fontFamily: 'monospace',
                color: AstroTheme.textMuted,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              factor.clinicalImpact,
              style: const TextStyle(
                fontSize: 12,
                color: AstroTheme.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),

            // Genomic & Multi-Omics Mechanism (NASA GeneLab tribute)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1424),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF1E3A5F)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.biotech, size: 16, color: AstroTheme.spaceCyan),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NASA GENELAB OMICS CORRELATION',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            fontFamily: 'monospace',
                            color: AstroTheme.spaceCyan,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          factor.cellularMechanism,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Immediate Autonomous Countermeasure
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_outlined, size: 16, color: statusColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MANDATORY AUTONOMOUS COUNTERMEASURE',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            fontFamily: 'monospace',
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          factor.countermeasure,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AstroTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // NASA Evidence Benchmark Footnote
            Row(
              children: [
                const Icon(Icons.science_outlined, size: 12, color: AstroTheme.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    factor.nasaCitation,
                    style: const TextStyle(
                      fontSize: 9,
                      color: AstroTheme.textMuted,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
