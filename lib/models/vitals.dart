enum HealthStatus { nominal, caution, critical }

class Astronaut {
  final String id;
  final String name;
  final String callsign;
  final String role;
  final String mission;
  final int missionDay;
  final String bloodType;
  final double bodyMassKg;

  const Astronaut({
    required this.id,
    required this.name,
    required this.callsign,
    required this.role,
    required this.mission,
    required this.missionDay,
    required this.bloodType,
    required this.bodyMassKg,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'callsign': callsign,
        'role': role,
        'mission': mission,
        'missionDay': missionDay,
        'bloodType': bloodType,
        'bodyMassKg': bodyMassKg,
      };

  factory Astronaut.fromJson(Map<String, dynamic> json) => Astronaut(
        id: json['id'] as String,
        name: json['name'] as String,
        callsign: json['callsign'] as String,
        role: json['role'] as String,
        mission: json['mission'] as String,
        missionDay: json['missionDay'] as int,
        bloodType: json['bloodType'] as String,
        bodyMassKg: (json['bodyMassKg'] as num).toDouble(),
      );
}

class VitalsRecord {
  final String id;
  final DateTime timestamp;
  final int heartRate; // bpm (60-100 nominal)
  final int bpSystolic; // mmHg (100-130 nominal)
  final int bpDiastolic; // mmHg (60-85 nominal)
  final double spo2; // % (95-100 nominal)
  final double bodyTemp; // °C (36.5-37.5 nominal)
  final double sleepHours; // hours (7-8 nominal)
  final int sleepQuality; // 0-100%
  final double radiationRate; // uSv/h (0.2-1.5 nominal deep space shielded)
  final double accumulatedRadiation; // mSv (career limit NASA: 600 mSv)
  final double intracranialPressure; // mmHg (7-15 nominal, >18 SANS risk)
  final int fatigueScore; // 1-10
  final double ambientCo2; // mmHg (nominal <3.0 mmHg on ISS)

  const VitalsRecord({
    required this.id,
    required this.timestamp,
    required this.heartRate,
    required this.bpSystolic,
    required this.bpDiastolic,
    required this.spo2,
    required this.bodyTemp,
    required this.sleepHours,
    required this.sleepQuality,
    required this.radiationRate,
    required this.accumulatedRadiation,
    required this.intracranialPressure,
    required this.fatigueScore,
    required this.ambientCo2,
  });

  HealthStatus get overallStatus {
    if (spo2 < 91 ||
        heartRate > 125 ||
        bpSystolic > 155 ||
        radiationRate > 25.0 ||
        intracranialPressure > 22.0) {
      return HealthStatus.critical;
    }
    if (spo2 < 95 ||
        heartRate > 100 ||
        heartRate < 50 ||
        bpSystolic > 135 ||
        sleepHours < 5.0 ||
        radiationRate > 5.0 ||
        intracranialPressure > 17.0 ||
        fatigueScore >= 7) {
      return HealthStatus.caution;
    }
    return HealthStatus.nominal;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'heartRate': heartRate,
        'bpSystolic': bpSystolic,
        'bpDiastolic': bpDiastolic,
        'spo2': spo2,
        'bodyTemp': bodyTemp,
        'sleepHours': sleepHours,
        'sleepQuality': sleepQuality,
        'radiationRate': radiationRate,
        'accumulatedRadiation': accumulatedRadiation,
        'intracranialPressure': intracranialPressure,
        'fatigueScore': fatigueScore,
        'ambientCo2': ambientCo2,
      };

  factory VitalsRecord.fromJson(Map<String, dynamic> json) => VitalsRecord(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        heartRate: json['heartRate'] as int,
        bpSystolic: json['bpSystolic'] as int,
        bpDiastolic: json['bpDiastolic'] as int,
        spo2: (json['spo2'] as num).toDouble(),
        bodyTemp: (json['bodyTemp'] as num).toDouble(),
        sleepHours: (json['sleepHours'] as num).toDouble(),
        sleepQuality: json['sleepQuality'] as int,
        radiationRate: (json['radiationRate'] as num).toDouble(),
        accumulatedRadiation: (json['accumulatedRadiation'] as num).toDouble(),
        intracranialPressure: (json['intracranialPressure'] as num).toDouble(),
        fatigueScore: json['fatigueScore'] as int,
        ambientCo2: (json['ambientCo2'] as num).toDouble(),
      );
}
