import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vitals.dart';
import '../../models/protocol.dart';
import '../../providers/astrocare_provider.dart';
import '../theme.dart';

class ProtocolsScreen extends StatelessWidget {
  const ProtocolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AstroCareProvider>();
    final protocols = provider.protocols;

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
              child: const Icon(Icons.checklist_rtl, color: AstroTheme.spaceCyan, size: 18),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'FLIGHT MEDICAL PROTOCOLS',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Subheader Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AstroTheme.cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AstroTheme.borderCard),
            ),
            child: Row(
              children: [
                const Icon(Icons.offline_bolt_outlined, color: AstroTheme.spaceCyan, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'AUTONOMOUS FLIGHT DATA FILE (FDF)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          fontFamily: 'monospace',
                          color: AstroTheme.spaceCyan,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Standardized decision trees and intervention checklists executable by crew during deep-space Earth communication loss.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AstroTheme.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          ...protocols.map((p) => _buildProtocolCard(context, provider, p)),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProtocolCard(
    BuildContext context,
    AstroCareProvider provider,
    EmergencyProtocol protocol,
  ) {
    Color priorityColor = protocol.priority == HealthStatus.critical
        ? AstroTheme.criticalCoral
        : (protocol.priority == HealthStatus.caution
            ? AstroTheme.cautionAmber
            : AstroTheme.nominalEmerald);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AstroTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: protocol.priority == HealthStatus.critical
              ? AstroTheme.criticalCoral
              : AstroTheme.borderCard,
          width: protocol.priority == HealthStatus.critical ? 1.5 : 1.0,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: protocol.priority == HealthStatus.critical,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: priorityColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              protocol.priority == HealthStatus.critical
                  ? Icons.warning_amber
                  : Icons.medical_services_outlined,
              color: priorityColor,
              size: 18,
            ),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: AstroTheme.bgDark,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: priorityColor.withValues(alpha: 0.7)),
                ),
                child: Text(
                  protocol.code,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: priorityColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  protocol.title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AstroTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  protocol.category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9,
                    letterSpacing: 0.8,
                    fontFamily: 'monospace',
                    color: AstroTheme.textTertiary,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: protocol.progress,
                    backgroundColor: AstroTheme.surfaceElevated,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      protocol.isFullyCompleted
                          ? AstroTheme.nominalEmerald
                          : AstroTheme.spaceCyan,
                    ),
                    minHeight: 3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${protocol.completedStepsCount}/${protocol.steps.length} STEPS VERIFIED',
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontFamily: 'monospace',
                    color: AstroTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trigger rationale
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AstroTheme.bgDark,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AstroTheme.borderCard),
                    ),
                    child: Text(
                      'TRIGGER THRESHOLD: ${protocol.rationale}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AstroTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Steps Checklist
                  ...protocol.steps.map((step) {
                    return InkWell(
                      onTap: () {
                        provider.toggleProtocolStep(protocol.id, step.stepNumber);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: step.isCompleted
                              ? AstroTheme.nominalEmerald.withValues(alpha: 0.08)
                              : AstroTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: step.isCompleted
                                ? AstroTheme.nominalEmerald.withValues(alpha: 0.4)
                                : AstroTheme.borderCard,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: step.isCompleted,
                              activeColor: AstroTheme.nominalEmerald,
                              checkColor: Colors.black,
                              onChanged: (_) {
                                provider.toggleProtocolStep(protocol.id, step.stepNumber);
                              },
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'STEP ${step.stepNumber} // ${step.title.toUpperCase()}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.6,
                                      color: step.isCompleted
                                          ? AstroTheme.nominalEmerald
                                          : AstroTheme.textPrimary,
                                      decoration: step.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    step.instructions,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AstroTheme.textSecondary,
                                      height: 1.3,
                                    ),
                                  ),
                                  if (step.requiredTool != 'None') ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AstroTheme.bgDark,
                                        borderRadius: BorderRadius.circular(3),
                                        border: Border.all(color: AstroTheme.borderCard),
                                      ),
                                      child: Text(
                                        'TOOL: ${step.requiredTool.toUpperCase()}',
                                        style: const TextStyle(
                                          fontSize: 8.5,
                                          fontFamily: 'monospace',
                                          color: AstroTheme.spaceCyan,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 6),
                  Text(
                    'NASA FLIGHT RULE REFERENCE: ${protocol.flightRuleReference}',
                    style: const TextStyle(
                      fontSize: 8.5,
                      color: AstroTheme.textMuted,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
