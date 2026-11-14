import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/astrocare_provider.dart';
import '../theme.dart';

class OfflineStatusBadge extends StatelessWidget {
  const OfflineStatusBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AstroCareProvider>();
    final queuedCount = provider.queuedOfflinePacketsCount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AstroTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AstroTheme.borderCard,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AstroTheme.nominalEmerald,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            '100% OFFLINE LEDGER',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
              letterSpacing: 0.6,
              color: AstroTheme.spaceCyan,
            ),
          ),
          if (queuedCount > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: AstroTheme.bgDark,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: AstroTheme.cautionAmber, width: 0.8),
              ),
              child: Text(
                '$queuedCount QUEUED',
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'monospace',
                  color: AstroTheme.cautionAmber,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
