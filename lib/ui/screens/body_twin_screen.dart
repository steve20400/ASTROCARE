import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vitals.dart';
import '../../providers/astrocare_provider.dart';
import '../theme.dart';
import '../widgets/digital_twin_painter.dart';

class BodyTwinScreen extends StatelessWidget {
  const BodyTwinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AstroCareProvider>();
    final latest = provider.latestVitals;
    final selectedOrgan = provider.selectedOrgan;

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
              child: const Icon(Icons.accessibility_new, color: AstroTheme.spaceCyan, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              'ASTRONAUT DIGITAL TWIN',
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Subheader
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ORTHOGONAL BIOMECHANICAL MODEL',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  fontFamily: 'monospace',
                  color: AstroTheme.textTertiary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AstroTheme.cardDark,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: AstroTheme.borderCard),
                ),
                child: const Text(
                  'MODEL: HRP-TWIN-v4',
                  style: TextStyle(
                    fontSize: 8,
                    fontFamily: 'monospace',
                    color: AstroTheme.spaceCyan,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Digital Twin Canvas
          DigitalTwinWidget(
            vitals: latest,
            selectedOrgan: selectedOrgan,
            onSelectOrgan: (organ) => provider.setSelectedOrgan(organ),
          ),
          const SizedBox(height: 12),

          // Organ Detailed Inspector Card
          _buildOrganInspector(context, selectedOrgan, latest),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOrganInspector(
    BuildContext context,
    String organId,
    VitalsRecord vitals,
  ) {
    late String organTitle;
    late String subsystemCode;
    late IconData organIcon;
    late List<Map<String, String>> metrics;
    late String clinicalSummary;
    late String countermeasure;
    late HealthStatus status;

    switch (organId) {
      case 'brain':
        organTitle = 'CENTRAL NERVOUS SYSTEM & COGNITION';
        subsystemCode = 'SYS-01 // NEURO-CIRCADIAN';
        organIcon = Icons.psychology;
        status = vitals.fatigueScore >= 7 ? HealthStatus.caution : HealthStatus.nominal;
        metrics = [
          {'name': 'Cognitive Fatigue Index', 'val': '${vitals.fatigueScore}/10', 'norm': '< 5'},
          {'name': 'Restorative Sleep Depth', 'val': '${vitals.sleepHours.toStringAsFixed(1)} h', 'norm': '7.0 - 8.5 h'},
          {'name': 'PVT Reaction Latency (est)', 'val': '228 ms', 'norm': '< 250 ms'},
        ];
        clinicalSummary =
            'Microgravity removes gravitational fluid pooling, increasing cerebral perfusion pressure. Sleep debt combined with 24-hour confinement degrades cognitive vigilance and spatial orientation.';
        countermeasure =
            'Implement 480nm blue-depleted lighting protocol in crew sleep quarters. Mandatory 30-minute cognitive rest cycle.';
        break;

      case 'eyes':
        organTitle = 'OCULAR SYSTEM & SANS PATHOLOGY';
        subsystemCode = 'SYS-02 // NEURO-OCULAR';
        organIcon = Icons.remove_red_eye;
        status = vitals.intracranialPressure > 16.0
            ? (vitals.intracranialPressure > 20.0 ? HealthStatus.critical : HealthStatus.caution)
            : HealthStatus.nominal;
        metrics = [
          {'name': 'Intracranial Pressure (Est)', 'val': '${vitals.intracranialPressure.toStringAsFixed(1)} mmHg', 'norm': '7.0 - 15.0'},
          {'name': 'Optic Sheath Diameter', 'val': '5.8 mm', 'norm': '< 5.0 mm'},
          {'name': 'Posterior Globe Flattening', 'val': vitals.intracranialPressure > 18 ? 'Positive' : 'None', 'norm': 'None'},
        ];
        clinicalSummary =
            'Cephalad venous engorgement increases translaminar pressure across the lamina cribrosa, causing optic disc swelling (papilledema), hyperopic refractive shifts, and choroidal folds.';
        countermeasure =
            'Execute 60-min Lower Body Negative Pressure (LBNP) chamber protocol at -35 mmHg. Boost ECLSS amine CO2 scrubbers.';
        break;

      case 'cardio':
        organTitle = 'CARDIOVASCULAR & HEMODYNAMICS';
        subsystemCode = 'SYS-03 // CARDIO-VASCULAR';
        organIcon = Icons.favorite;
        status = (vitals.heartRate > 100 || vitals.bpSystolic > 140)
            ? (vitals.heartRate > 120 ? HealthStatus.critical : HealthStatus.caution)
            : HealthStatus.nominal;
        metrics = [
          {'name': 'Resting Heart Rate', 'val': '${vitals.heartRate} BPM', 'norm': '60 - 100'},
          {'name': 'Arterial Pressure', 'val': '${vitals.bpSystolic}/${vitals.bpDiastolic} mmHg', 'norm': '120/80'},
          {'name': 'Stroke Volume Index', 'val': '84 mL/beat', 'norm': '70 - 100'},
        ];
        clinicalSummary =
            'Absence of gravitational hydrostatic gradient reduces left ventricular workload, inducing progressive myocardial deconditioning and severe post-mission orthostatic intolerance.';
        countermeasure =
            'Maintain daily 2.5h ARED resistive exercise + cycle ergometer. Perform isotonic saline loading prior to dynamic G transitions.';
        break;

      case 'lungs':
        organTitle = 'PULMONARY & GAS EXCHANGE';
        subsystemCode = 'SYS-04 // RESPIRATORY-ECLSS';
        organIcon = Icons.air;
        status = vitals.spo2 < 95.0
            ? (vitals.spo2 < 91.0 ? HealthStatus.critical : HealthStatus.caution)
            : HealthStatus.nominal;
        metrics = [
          {'name': 'Blood Oxygen Saturation', 'val': '${vitals.spo2.toStringAsFixed(1)} %', 'norm': '> 95.0 %'},
          {'name': 'Cabin Partial CO2 (PPO2)', 'val': '${vitals.ambientCo2.toStringAsFixed(1)} mmHg', 'norm': '< 2.5 mmHg'},
          {'name': 'Total Barometric Pressure', 'val': '101.3 kPa', 'norm': '101.3 kPa'},
        ];
        clinicalSummary =
            'Lack of natural air convection in zero-G causes localized CO2 accumulation bubbles. Mild hypercapnia causes vasodilation and exacerbates SANS headache symptoms.';
        countermeasure =
            'Deploy supplementary O2 mask if SpO2 < 92%. Inspect habitat ventilation duct filters and swap LiOH scrubber canister.';
        break;

      case 'immune':
        organTitle = 'IMMUNOLOGICAL & GENOMIC STABILITY';
        subsystemCode = 'SYS-05 // IMMUNO-GENOMIC';
        organIcon = Icons.shield;
        status = vitals.radiationRate > 5.0
            ? (vitals.radiationRate > 15.0 ? HealthStatus.critical : HealthStatus.caution)
            : HealthStatus.nominal;
        metrics = [
          {'name': 'Dosimeter Dose Rate', 'val': '${vitals.radiationRate.toStringAsFixed(2)} uSv/h', 'norm': '< 2.5 uSv/h'},
          {'name': 'Cumulative Mission Dose', 'val': '${vitals.accumulatedRadiation.toStringAsFixed(1)} mSv', 'norm': '< 600 mSv'},
          {'name': 'DNA Double-Strand Breaks', 'val': vitals.radiationRate > 15 ? 'ELEVATED' : 'BASELINE', 'norm': 'BASELINE'},
        ];
        clinicalSummary =
            'High-energy Galactic Cosmic Rays (HZE ions) induce complex clustered DNA double-strand breaks. Microgravity concurrently downregulates T-cell lymphocyte activation pathways.';
        countermeasure =
            'Relocate crew to water-shielded storm bunker during SPE events. Administer radioprotectant antioxidant therapy.';
        break;

      default:
        organTitle = 'OSTEOMUSCULAR SKELETAL INTEGRITY';
        subsystemCode = 'SYS-06 // MUSCULOSKELETAL';
        organIcon = Icons.accessibility;
        status = HealthStatus.nominal;
        metrics = [
          {'name': 'BMD Resorption Rate (est)', 'val': '1.1 % / mo', 'norm': '< 1.5 %'},
          {'name': 'Daily ARED Mechanical Load', 'val': '12.4 kJ', 'norm': '> 10 kJ'},
          {'name': 'Serum Calcium Homeostasis', 'val': '9.4 mg/dL', 'norm': '8.5 - 10.2'},
        ];
        clinicalSummary =
            'Mechanical skeletal unloading stimulates osteoclast resorption and inhibits osteoblast bone formation, causing trabecular bone loss and renal calculus risk.';
        countermeasure =
            'Execute prescribed daily high-load axial loading exercises (squats, deadlifts) on ARED resistive device.';
    }

    Color statusColor = status == HealthStatus.critical
        ? AstroTheme.criticalCoral
        : (status == HealthStatus.caution
            ? AstroTheme.cautionAmber
            : AstroTheme.nominalEmerald);

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
                  Icon(organIcon, size: 16, color: statusColor),
                  const SizedBox(width: 8),
                  Text(
                    organTitle,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              Text(
                subsystemCode,
                style: const TextStyle(
                  fontSize: 8.5,
                  fontFamily: 'monospace',
                  color: AstroTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Metrics table
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AstroTheme.bgDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AstroTheme.borderCard),
            ),
            child: Column(
              children: metrics.map((m) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        m['name']!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AstroTheme.textSecondary,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            m['val']!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace',
                              color: AstroTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '[${m['norm']}]',
                            style: const TextStyle(
                              fontSize: 9,
                              fontFamily: 'monospace',
                              color: AstroTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Pathology summary
          const Text(
            'NASA CLINICAL RISK & CELLULAR MECHANISM',
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
            clinicalSummary,
            style: const TextStyle(
              fontSize: 11.5,
              color: AstroTheme.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),

          // Countermeasure
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
                Icon(Icons.shield_outlined, size: 15, color: statusColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    countermeasure,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AstroTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
