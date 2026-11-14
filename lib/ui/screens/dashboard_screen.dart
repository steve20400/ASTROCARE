import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vitals.dart';
import '../../providers/astrocare_provider.dart';
import '../theme.dart';
import '../widgets/vitals_gauge.dart';
import '../widgets/vitals_chart.dart';
import '../widgets/radar_chart.dart';
import '../widgets/offline_status_badge.dart';
import '../widgets/scenario_selector.dart';
import 'data_entry_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AstroCareProvider>();
    final astro = provider.astronaut;
    final latest = provider.latestVitals;
    final status = latest.overallStatus;

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
              child: const Icon(Icons.satellite_alt, color: AstroTheme.spaceCyan, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ASTROCARE // ORION-MED',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: AstroTheme.textPrimary,
                  ),
                ),
                Text(
                  '${astro.name.toUpperCase()} • SOL ${astro.missionDay} • ${astro.mission.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontFamily: 'monospace',
                    color: AstroTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Language Toggle (EN/FR)',
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AstroTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AstroTheme.borderCard),
              ),
              child: Text(
                provider.currentLanguage.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'monospace',
                  color: AstroTheme.spaceCyan,
                ),
              ),
            ),
            onPressed: () => provider.toggleLanguage(),
          ),
          IconButton(
            tooltip: 'Jury Demo Scenarios',
            icon: const Icon(Icons.science_outlined, color: AstroTheme.spaceCyan, size: 20),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const ScenarioSelectorModal(),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => provider.initialize(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Status & Latency Aerospace Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const OfflineStatusBadge(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AstroTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AstroTheme.borderCard),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.network_ping, size: 12, color: AstroTheme.spaceCyan),
                      SizedBox(width: 5),
                      Text(
                        'RTLT: 18.4 MIN [NO EARTH UPLINK]',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                          color: AstroTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Master 30-Second Triage Card
            _buildTriageCard(context, latest, status),
            const SizedBox(height: 14),

            // Scientific Homeostasis Radar
            BiometricHomeostasisRadar(vitals: latest),
            const SizedBox(height: 14),

            // Active Compound Synergy Alert Banner (if non-nominal)
            if (provider.activeSynergies.isNotEmpty &&
                provider.activeSynergies.first.severity != HealthStatus.nominal)
              _buildSynergyAlertBanner(context, provider.activeSynergies.first),

            const SizedBox(height: 14),

            // Telemetry Grid Header
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
                      'CREW BIOMETRIC CHANNELS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AstroTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DataEntryScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AstroTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AstroTheme.borderCard),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.add, size: 12, color: AstroTheme.spaceCyan),
                        SizedBox(width: 4),
                        Text(
                          'LOG VITALS',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            fontFamily: 'monospace',
                            color: AstroTheme.spaceCyan,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 6-channel Telemetry Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.45,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                VitalsGaugeCard(
                  title: 'Heart Rate',
                  value: '${latest.heartRate}',
                  unit: 'BPM',
                  icon: Icons.favorite_border,
                  status: latest.heartRate > 100 || latest.heartRate < 55
                      ? (latest.heartRate > 120 ? HealthStatus.critical : HealthStatus.caution)
                      : HealthStatus.nominal,
                  normalRange: '60 - 100',
                  delta: latest.heartRate > 100 ? '+24%' : '±0%',
                ),
                VitalsGaugeCard(
                  title: 'Oxygenation',
                  value: latest.spo2.toStringAsFixed(1),
                  unit: '% SpO2',
                  icon: Icons.air,
                  status: latest.spo2 < 95
                      ? (latest.spo2 < 91 ? HealthStatus.critical : HealthStatus.caution)
                      : HealthStatus.nominal,
                  normalRange: '95 - 100',
                  delta: latest.spo2 < 95 ? '-4.2%' : '±0%',
                ),
                VitalsGaugeCard(
                  title: 'Blood Pressure',
                  value: '${latest.bpSystolic}/${latest.bpDiastolic}',
                  unit: 'mmHg',
                  icon: Icons.speed,
                  status: latest.bpSystolic > 140
                      ? (latest.bpSystolic > 155 ? HealthStatus.critical : HealthStatus.caution)
                      : HealthStatus.nominal,
                  normalRange: '120/80',
                  delta: latest.bpSystolic > 140 ? '+18 mmHg' : '±0',
                ),
                VitalsGaugeCard(
                  title: 'Dosimeter Flux',
                  value: latest.radiationRate.toStringAsFixed(2),
                  unit: 'uSv/h',
                  icon: Icons.warning_amber_outlined,
                  status: latest.radiationRate > 5.0
                      ? (latest.radiationRate > 20.0 ? HealthStatus.critical : HealthStatus.caution)
                      : HealthStatus.nominal,
                  normalRange: '< 2.50',
                  delta: latest.radiationRate > 5.0 ? '×35 FLUX' : 'BKGND',
                ),
                VitalsGaugeCard(
                  title: 'SANS Index (ICP)',
                  value: latest.intracranialPressure.toStringAsFixed(1),
                  unit: 'mmHg',
                  icon: Icons.remove_red_eye_outlined,
                  status: latest.intracranialPressure > 16.0
                      ? (latest.intracranialPressure > 20.0 ? HealthStatus.critical : HealthStatus.caution)
                      : HealthStatus.nominal,
                  normalRange: '7.0 - 15.0',
                  delta: latest.intracranialPressure > 16.0 ? '+45% ICP' : 'NOM',
                ),
                VitalsGaugeCard(
                  title: 'Circadian Sleep',
                  value: latest.sleepHours.toStringAsFixed(1),
                  unit: 'HOURS',
                  icon: Icons.bedtime_outlined,
                  status: latest.sleepHours < 6.0
                      ? (latest.sleepHours < 4.5 ? HealthStatus.critical : HealthStatus.caution)
                      : HealthStatus.nominal,
                  normalRange: '7.0 - 8.5',
                  delta: latest.sleepHours < 6.0 ? '-3.5h DEBT' : 'RESTED',
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Time-series Telemetry Waves
            Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  color: AstroTheme.spaceCyan,
                ),
                const SizedBox(width: 8),
                const Text(
                  '24-HOUR TELEMETRY STREAMS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AstroTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            VitalsSparklineChart(
              history: provider.vitalsHistory,
              metricName: 'Cosmic Radiation Dosimeter Stream',
              unit: 'uSv/h',
              lineColor: latest.radiationRate > 10.0 ? AstroTheme.criticalCoral : AstroTheme.hudAmber,
              extractor: (r) => r.radiationRate,
              normalMin: 0.0,
              normalMax: 2.5,
            ),
            const SizedBox(height: 10),
            VitalsSparklineChart(
              history: provider.vitalsHistory,
              metricName: 'Resting Electrocardiogram (HR-ECG Lead II)',
              unit: 'bpm',
              lineColor: AstroTheme.spaceCyan,
              extractor: (r) => r.heartRate.toDouble(),
              normalMin: 60.0,
              normalMax: 100.0,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTriageCard(
    BuildContext context,
    VitalsRecord latest,
    HealthStatus status,
  ) {
    Color statusColor = status == HealthStatus.critical
        ? AstroTheme.criticalCoral
        : (status == HealthStatus.caution
            ? AstroTheme.cautionAmber
            : AstroTheme.nominalEmerald);

    String statusTitle = status == HealthStatus.critical
        ? 'CRITICAL ALERT // INTERVENTION REQUIRED'
        : (status == HealthStatus.caution
            ? 'CAUTION // COMPOUND STRAIN DETECTED'
            : 'ALL SYSTEMS NOMINAL // FLIGHT READY');

    String statusSubtitle = status == HealthStatus.critical
        ? 'Severe multi-stressor parameter breach. Execute autonomous action protocol immediately.'
        : (status == HealthStatus.caution
            ? 'Cross-stressor synergy elevating systemic fatigue. Monitor bio-channels.'
            : 'Physiological parameters within NASA Human Research Program baseline corridors.');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AstroTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: status == HealthStatus.nominal ? AstroTheme.borderCard : statusColor,
          width: status == HealthStatus.nominal ? 1.0 : 1.5,
        ),
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
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    statusTitle,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      fontFamily: 'monospace',
                      color: statusColor,
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
                  'TRIAGE: <30S',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                    color: AstroTheme.textTertiary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            statusSubtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AstroTheme.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AstroTheme.bgDark,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AstroTheme.borderCard),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'MISSION ACCUMULATED DOSE:',
                  style: TextStyle(
                    fontSize: 9,
                    fontFamily: 'monospace',
                    color: AstroTheme.textTertiary,
                  ),
                ),
                Text(
                  '${latest.accumulatedRadiation.toStringAsFixed(1)} mSv / 600 mSv MAX',
                  style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                    color: AstroTheme.spaceCyan,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSynergyAlertBanner(BuildContext context, dynamic synergy) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AstroTheme.cardDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AstroTheme.laserViolet, width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AstroTheme.laserViolet.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.hub, color: AstroTheme.laserViolet, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'COMPOUND CROSS-STRESSOR RISK DETECTED',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    fontFamily: 'monospace',
                    color: AstroTheme.laserViolet,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  synergy.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AstroTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AstroTheme.laserViolet, size: 18),
        ],
      ),
    );
  }
}
