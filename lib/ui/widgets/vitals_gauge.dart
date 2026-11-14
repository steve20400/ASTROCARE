import 'package:flutter/material.dart';
import '../../models/vitals.dart';
import '../theme.dart';

class VitalsGaugeCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final HealthStatus status;
  final String normalRange;
  final String? delta;
  final VoidCallback? onTap;

  const VitalsGaugeCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.status,
    required this.normalRange,
    this.delta,
    this.onTap,
  });

  Color _getStatusColor() {
    switch (status) {
      case HealthStatus.nominal:
        return AstroTheme.nominalEmerald;
      case HealthStatus.caution:
        return AstroTheme.cautionAmber;
      case HealthStatus.critical:
        return AstroTheme.criticalCoral;
    }
  }

  String _getStatusText() {
    switch (status) {
      case HealthStatus.nominal:
        return 'NOMINAL';
      case HealthStatus.caution:
        return 'CAUTION';
      case HealthStatus.critical:
        return 'ALERT';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final isCritical = status == HealthStatus.critical;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AstroTheme.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCritical ? statusColor : AstroTheme.borderCard,
            width: isCritical ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header Row: Metric Title + Status Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(icon, size: 14, color: AstroTheme.spaceCyan),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          title.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AstroTheme.textSecondary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: statusColor, width: 0.8),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace',
                      color: statusColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),

            // Center: Big Bold Monospace Value
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace',
                      color: isCritical ? AstroTheme.criticalCoral : AstroTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AstroTheme.textTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Footer Row: Normal Range + Real-time Delta
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'NORM: $normalRange',
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontFamily: 'monospace',
                    color: AstroTheme.textMuted,
                  ),
                ),
                if (delta != null)
                  Text(
                    delta!,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w700,
                      color: statusColor,
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
