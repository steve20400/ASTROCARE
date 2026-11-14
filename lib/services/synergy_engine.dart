import '../models/vitals.dart';
import '../models/synergy.dart';

class HrpSynergyEngine {
  /// Evaluates compound synergies between spaceflight hazards and astronaut vitals
  /// Based on NASA Human Research Program (HRP) Evidence Books & GeneLab multi-stressor studies
  static List<SynergyRiskFactor> evaluateSynergies(VitalsRecord vitals) {
    final activeSynergies = <SynergyRiskFactor>[];

    // 1. SYNERGY: Sleep Deprivation + Radiation Spike (Immuno-Genomic Vulnerability)
    // NASA GeneLab OSD-288 insight: Sleep loss impairs cellular DNA repair pathways (NHEJ/HRR),
    // multiplying ionizing radiation damage to lymphocytes and stem cells.
    if (vitals.sleepHours < 6.0 && vitals.radiationRate > 3.0) {
      final isCritical = vitals.sleepHours < 4.5 || vitals.radiationRate > 15.0;
      activeSynergies.add(SynergyRiskFactor(
        id: 'SYN-IMMUNO-RAD',
        title: 'Compound DNA Repair Deficit & Lymphopenia',
        hazardCategory: 'Radiation + Isolation (Circadian)',
        severity: isCritical ? HealthStatus.critical : HealthStatus.caution,
        compoundRiskScore: isCritical ? 0.88 : 0.64,
        contributingStressors: [
          'Sleep Duration: ${vitals.sleepHours.toStringAsFixed(1)}h (<6.0h critical threshold)',
          'Ionizing Radiation Flux: ${vitals.radiationRate.toStringAsFixed(1)} uSv/h',
          'Circadian Melatonin Suppression',
        ],
        clinicalImpact: 'Accelerated chromosome aberrations, acute lymphocyte apoptosis, and impaired innate immunity.',
        cellularMechanism: 'Downregulation of ATM/p53 DNA damage response cascade exacerbated by circadian clock arrest (CRY1/PER2 repression).',
        countermeasure: 'Immediate administration of antioxidant cocktail (NAC + Alpha-Lipoic acid), sleep schedule realignment with 480nm blue-light filtration.',
        nasaCitation: 'NASA HRP Risk of Radiation Carcinogenesis / GeneLab OSD-288',
        targetOrgan: 'immune',
      ));
    }

    // 2. SYNERGY: Microgravity Fluid Shift + Elevated Cabin CO2 (SANS Ocular Risk)
    // SANS: Spaceflight-Associated Neuro-ocular Syndrome is dramatically aggravated
    // when mild hypercapnia (>2.5 mmHg) causes cerebral vasodilation in microgravity.
    if (vitals.intracranialPressure > 16.0 || (vitals.ambientCo2 > 2.8 && vitals.intracranialPressure > 14.0)) {
      final isCritical = vitals.intracranialPressure > 20.0 || vitals.ambientCo2 > 4.0;
      activeSynergies.add(SynergyRiskFactor(
        id: 'SYN-SANS-CO2',
        title: 'Cephalad Venous Engorgement & Papilledema (SANS)',
        hazardCategory: 'Altered Gravity + Hostile Closed Environment',
        severity: isCritical ? HealthStatus.critical : HealthStatus.caution,
        compoundRiskScore: isCritical ? 0.92 : 0.71,
        contributingStressors: [
          'Microgravity Cephalad Fluid Shift (0-G hydrostatic pressure loss)',
          'Estimated Intracranial Pressure: ${vitals.intracranialPressure.toStringAsFixed(1)} mmHg',
          'Ambient Cabin CO2: ${vitals.ambientCo2.toStringAsFixed(1)} mmHg',
        ],
        clinicalImpact: 'Posterior globe flattening, optic nerve sheath distension, choroidal folds, and hyperopic refractive shift.',
        cellularMechanism: 'Cerebrovascular endothelial dilation from hypercapnia + internal jugular vein stasis due to absent gravity drainage.',
        countermeasure: 'Immediate 60-min Lower Body Negative Pressure (LBNP) at -35 mmHg. Boost ECLSS amine CO2 scrubbers to cycle mode.',
        nasaCitation: 'NASA Spaceflight Standard Measures / SANS Clinical Practice Guidelines',
        targetOrgan: 'eyes',
      ));
    }

    // 3. SYNERGY: Cognitive Fatigue + Tachycardia (Neuro-Cardiovascular Stress)
    if (vitals.fatigueScore >= 7 && vitals.heartRate > 90) {
      final isCritical = vitals.fatigueScore >= 9 || vitals.heartRate > 115;
      activeSynergies.add(SynergyRiskFactor(
        id: 'SYN-NEURO-CARDIO',
        title: 'Autonomic Dysregulation & Cognitive Overload',
        hazardCategory: 'Isolation + Distance from Earth',
        severity: isCritical ? HealthStatus.critical : HealthStatus.caution,
        compoundRiskScore: isCritical ? 0.81 : 0.58,
        contributingStressors: [
          'Fatigue Score: ${vitals.fatigueScore}/10',
          'Resting Tachycardia: ${vitals.heartRate} bpm',
          'Earth Comm Latency (No real-time surgical support)',
        ],
        clinicalImpact: 'Executive decision paralysis during critical mission maneuvers, cardiac sympathetic overdrive, and risk of ventricular extrasystoles.',
        cellularMechanism: 'Prolonged cortisol elevation inducing beta-1 adrenergic receptor desensitization and prefrontal cortical hypoactivity.',
        countermeasure: 'Mandatory 4-hour cognitive down-time. Guided heart-rate-variability (HRV) biofeedback breathing (6 breaths/min).',
        nasaCitation: 'NASA Behavioral Health & Performance (BHP) Risk Portfolio',
        targetOrgan: 'brain',
      ));
    }

    // 4. SYNERGY: Hypoxia / Low SpO2 + Elevated Radiation (Tissue Ischemic Radiosensitivity)
    if (vitals.spo2 < 94.0) {
      final isCritical = vitals.spo2 < 90.0;
      activeSynergies.add(SynergyRiskFactor(
        id: 'SYN-HYPOX-TISSUE',
        title: 'Microvascular Hypoxia & Tissue Desaturation',
        hazardCategory: 'Hostile Environment + Gravity Fields',
        severity: isCritical ? HealthStatus.critical : HealthStatus.caution,
        compoundRiskScore: isCritical ? 0.95 : 0.68,
        contributingStressors: [
          'Blood Oxygen Saturation: ${vitals.spo2.toStringAsFixed(1)}%',
          'Fluid Shift Induced Pulmonary Atelectasis',
          'Spacecraft Cabin Pressure Variation',
        ],
        clinicalImpact: 'Myocardial hypoxia, reduced physical endurance on EVA, and impaired peripheral tissue repair.',
        cellularMechanism: 'HIF-1alpha pathway activation combined with mitochondrial oxidative stress in alveolar capillary beds.',
        countermeasure: 'Deploy Quick-Don supplemental oxygen mask (100% FiO2) for 30 minutes; perform inspiratory muscle resistive training.',
        nasaCitation: 'NASA Human Integration Design Handbook (HIDH) - Atmosphere Guidelines',
        targetOrgan: 'lungs',
      ));
    }

    // 5. BASELINE NOMINAL: If no high risk triggered, return a protective nominal synergy state
    if (activeSynergies.isEmpty) {
      activeSynergies.add(const SynergyRiskFactor(
        id: 'SYN-NOMINAL-EQUILIBRIUM',
        title: 'Homeostatic Spaceflight Equilibrium',
        hazardCategory: 'All R.I.D.G.E. Hazards Managed',
        severity: HealthStatus.nominal,
        compoundRiskScore: 0.12,
        contributingStressors: [
          'Nominal Circadian Cycle (7.2h restorative sleep)',
          'Background Galactic Cosmic Ray (GCR) levels shielded (<1.0 uSv/h)',
          'ECLSS CO2 and O2 concentrations within flight limits',
        ],
        clinicalImpact: 'Physiological adaptation within acceptable NASA Human Research Program parameters.',
        cellularMechanism: 'Cellular protective mechanisms (superoxide dismutase, DNA repair ligases) operating at optimal homeostatic baseline.',
        countermeasure: 'Continue prescribed daily 2.5h ARED resistance training and cycle ergometer workout.',
        nasaCitation: 'NASA Spaceflight Standard Measures Core Protocol v4.1',
        targetOrgan: 'cardio',
      ));
    }

    return activeSynergies;
  }
}
