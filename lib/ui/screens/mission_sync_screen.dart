import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/protocol.dart';
import '../../providers/astrocare_provider.dart';
import '../theme.dart';

class MissionSyncScreen extends StatelessWidget {
  const MissionSyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AstroCareProvider>();
    final packets = provider.syncPackets;
    final queuedCount = provider.queuedOfflinePacketsCount;
    final isTransmitting = provider.isTransmittingSync;

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
              child: const Icon(Icons.sync_alt, color: AstroTheme.spaceCyan, size: 18),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
              'DSN STORE-AND-FORWARD LINK',
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
          // Deep Space Network Terminal Card
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
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 3,
                            height: 14,
                            color: AstroTheme.spaceCyan,
                          ),
                          const SizedBox(width: 8),
                          const Flexible(
                            child: Text(
                              'DEEP SPACE NETWORK 34M ARRAY',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: AstroTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AstroTheme.bgDark,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: AstroTheme.borderCard),
                      ),
                      child: const Text(
                        'FREQUENCY: 8.4 GHz (X-BAND)',
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
                const Text(
                  'During interplanetary transits, real-time TCP sockets are physically unviable due to planetary rotation occultations and round-trip light time (RTLT up to 44 minutes). AstroCare stores biometrics in a local append-only ledger and synchronizes opportunistically during Deep Space Network line-of-sight passes.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AstroTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),

                // Ground Station telemetry stat chips
                Row(
                  children: [
                    _buildStatPill('PENDING QUEUE', '$queuedCount PKTS', AstroTheme.cautionAmber),
                    const SizedBox(width: 8),
                    _buildStatPill('CONFIRMED SOL', '${packets.length - queuedCount} PKTS', AstroTheme.nominalEmerald),
                    const SizedBox(width: 8),
                    _buildStatPill('ONE-WAY DELAY', '18.4 MIN', AstroTheme.spaceCyan),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Ground Pass Synchronization Trigger
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AstroTheme.nasaBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                side: const BorderSide(color: AstroTheme.spaceCyan, width: 1.0),
                elevation: 0,
              ),
              icon: isTransmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AstroTheme.spaceCyan,
                      ),
                    )
                  : const Icon(Icons.send_rounded, color: AstroTheme.spaceCyan, size: 16),
              label: Text(
                isTransmitting
                    ? 'TRANSMITTING DOWNLINK VIA DSN ARRAY...'
                    : (queuedCount > 0
                        ? 'TRANSMIT $queuedCount ENCRYPTED PACKETS'
                        : 'TRANSMIT BATCH TELEMETRY TO HOUSTON'),
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  fontFamily: 'monospace',
                ),
              ),
              onPressed: isTransmitting ? null : () => provider.triggerOfflineSync(),
            ),
          ),
          const SizedBox(height: 18),

          // Packets Ledger
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 2,
            children: const [
              Text(
                'LOCAL STORE-AND-FORWARD TELEMETRY LEDGER',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  fontFamily: 'monospace',
                  color: AstroTheme.textSecondary,
                ),
              ),
              Text(
                'CCSDS CRC-32',
                style: TextStyle(
                  fontSize: 8.5,
                  fontFamily: 'monospace',
                  color: AstroTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...packets.map((pkt) => _buildPacketCard(pkt)),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatPill(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: AstroTheme.bgDark,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AstroTheme.borderCard),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                fontFamily: 'monospace',
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                fontSize: 8,
                letterSpacing: 0.6,
                fontFamily: 'monospace',
                color: AstroTheme.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPacketCard(SyncPacket packet) {
    Color statusColor = packet.syncStatus == 'CONFIRMED_EARTH'
        ? AstroTheme.nominalEmerald
        : (packet.syncStatus == 'TRANSMITTING'
            ? AstroTheme.spaceCyan
            : AstroTheme.cautionAmber);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AstroTheme.cardDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AstroTheme.borderCard),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              packet.syncStatus == 'CONFIRMED_EARTH'
                  ? Icons.check_circle_outline
                  : (packet.syncStatus == 'TRANSMITTING'
                      ? Icons.sync
                      : Icons.archive_outlined),
              size: 15,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      packet.id,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'monospace',
                        color: AstroTheme.spaceCyan,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: statusColor, width: 0.8),
                      ),
                      child: Text(
                        packet.syncStatus.replaceAll('_', ' '),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'monospace',
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  packet.payloadSummary,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AstroTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${packet.byteSize} BYTES',
                      style: const TextStyle(
                        fontSize: 8.5,
                        color: AstroTheme.textMuted,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '// ${packet.createdAt.toIso8601String().substring(11, 19)} UTC',
                      style: const TextStyle(
                        fontSize: 8.5,
                        color: AstroTheme.textMuted,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
