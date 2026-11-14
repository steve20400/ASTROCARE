import 'vitals.dart';

class SynergyRiskFactor {
  final String id;
  final String title;
  final String hazardCategory; // R.I.D.G.E. : Radiation, Isolation, Distance, Gravity, Environment
  final HealthStatus severity;
  final double compoundRiskScore; // 0.0 to 1.0
  final List<String> contributingStressors;
  final String clinicalImpact;
  final String cellularMechanism;
  final String countermeasure;
  final String nasaCitation;
  final String targetOrgan; // brain, eyes, cardio, lungs, musculoskeletal, immune

  const SynergyRiskFactor({
    required this.id,
    required this.title,
    required this.hazardCategory,
    required this.severity,
    required this.compoundRiskScore,
    required this.contributingStressors,
    required this.clinicalImpact,
    required this.cellularMechanism,
    required this.countermeasure,
    required this.nasaCitation,
    required this.targetOrgan,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'hazardCategory': hazardCategory,
        'severity': severity.name,
        'compoundRiskScore': compoundRiskScore,
        'contributingStressors': contributingStressors,
        'clinicalImpact': clinicalImpact,
        'cellularMechanism': cellularMechanism,
        'countermeasure': countermeasure,
        'nasaCitation': nasaCitation,
        'targetOrgan': targetOrgan,
      };

  factory SynergyRiskFactor.fromJson(Map<String, dynamic> json) =>
      SynergyRiskFactor(
        id: json['id'] as String,
        title: json['title'] as String,
        hazardCategory: json['hazardCategory'] as String,
        severity: HealthStatus.values.byName(json['severity'] as String),
        compoundRiskScore: (json['compoundRiskScore'] as num).toDouble(),
        contributingStressors:
            List<String>.from(json['contributingStressors'] as List),
        clinicalImpact: json['clinicalImpact'] as String,
        cellularMechanism: json['cellularMechanism'] as String,
        countermeasure: json['countermeasure'] as String,
        nasaCitation: json['nasaCitation'] as String,
        targetOrgan: json['targetOrgan'] as String,
      );
}
