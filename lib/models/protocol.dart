import 'vitals.dart';

class ProtocolStep {
  final int stepNumber;
  final String title;
  final String instructions;
  final String requiredTool;
  bool isCompleted;

  ProtocolStep({
    required this.stepNumber,
    required this.title,
    required this.instructions,
    this.requiredTool = 'None',
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'stepNumber': stepNumber,
        'title': title,
        'instructions': instructions,
        'requiredTool': requiredTool,
        'isCompleted': isCompleted,
      };

  factory ProtocolStep.fromJson(Map<String, dynamic> json) => ProtocolStep(
        stepNumber: json['stepNumber'] as int,
        title: json['title'] as String,
        instructions: json['instructions'] as String,
        requiredTool: json['requiredTool'] as String? ?? 'None',
        isCompleted: json['isCompleted'] as bool? ?? false,
      );
}

class EmergencyProtocol {
  final String id;
  final String code; // e.g. "MED-SPE-04"
  final String title;
  final String category;
  final HealthStatus priority;
  final String rationale;
  final String flightRuleReference;
  final List<ProtocolStep> steps;

  EmergencyProtocol({
    required this.id,
    required this.code,
    required this.title,
    required this.category,
    required this.priority,
    required this.rationale,
    required this.flightRuleReference,
    required this.steps,
  });

  int get completedStepsCount => steps.where((s) => s.isCompleted).length;
  double get progress => steps.isEmpty ? 0.0 : completedStepsCount / steps.length;
  bool get isFullyCompleted => steps.isNotEmpty && steps.every((s) => s.isCompleted);

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'title': title,
        'category': category,
        'priority': priority.name,
        'rationale': rationale,
        'flightRuleReference': flightRuleReference,
        'steps': steps.map((s) => s.toJson()).toList(),
      };

  factory EmergencyProtocol.fromJson(Map<String, dynamic> json) =>
      EmergencyProtocol(
        id: json['id'] as String,
        code: json['code'] as String,
        title: json['title'] as String,
        category: json['category'] as String,
        priority: HealthStatus.values.byName(json['priority'] as String),
        rationale: json['rationale'] as String,
        flightRuleReference: json['flightRuleReference'] as String,
        steps: (json['steps'] as List)
            .map((s) => ProtocolStep.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}

class SyncPacket {
  final String id;
  final DateTime createdAt;
  final String packetType; // 'VITALS_TELEMETRY', 'MISSION_LOG', 'ALERT_REPORT'
  final String payloadSummary;
  final int byteSize;
  String syncStatus; // 'OFFLINE_QUEUED', 'TRANSMITTING', 'CONFIRMED_EARTH'
  DateTime? syncedAt;

  SyncPacket({
    required this.id,
    required this.createdAt,
    required this.packetType,
    required this.payloadSummary,
    required this.byteSize,
    this.syncStatus = 'OFFLINE_QUEUED',
    this.syncedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'packetType': packetType,
        'payloadSummary': payloadSummary,
        'byteSize': byteSize,
        'syncStatus': syncStatus,
        'syncedAt': syncedAt?.toIso8601String(),
      };

  factory SyncPacket.fromJson(Map<String, dynamic> json) => SyncPacket(
        id: json['id'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        packetType: json['packetType'] as String,
        payloadSummary: json['payloadSummary'] as String,
        byteSize: json['byteSize'] as int,
        syncStatus: json['syncStatus'] as String? ?? 'OFFLINE_QUEUED',
        syncedAt: json['syncedAt'] != null
            ? DateTime.parse(json['syncedAt'] as String)
            : null,
      );
}
