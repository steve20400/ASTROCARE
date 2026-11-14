import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/vitals.dart';
import '../models/synergy.dart';
import '../models/protocol.dart';
import '../services/storage_service.dart';
import '../services/synergy_engine.dart';

enum MissionScenario {
  nominalArtemis,
  solarFlareEva,
  sansCrisis,
  airlockHypoxia,
}

class AstroCareProvider with ChangeNotifier {
  final OfflineStorageService _storage = OfflineStorageService();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  String _currentLanguage = 'en';
  String get currentLanguage => _currentLanguage;

  Astronaut? _astronaut;
  Astronaut get astronaut =>
      _astronaut ??
      const Astronaut(
        id: 'ASTRO-084',
        name: 'Dr. Sarah Lin',
        callsign: 'PHOENIX-1',
        role: 'Flight Surgeon & Science Officer',
        mission: 'Artemis IV / Mars Transit',
        missionDay: 142,
        bloodType: 'O Rh+',
        bodyMassKg: 64.2,
      );

  List<VitalsRecord> _vitalsHistory = [];
  List<VitalsRecord> get vitalsHistory => _vitalsHistory;

  VitalsRecord get latestVitals => _vitalsHistory.isNotEmpty
      ? _vitalsHistory.first
      : VitalsRecord(
          id: 'FALLBACK-01',
          timestamp: DateTime.now(),
          heartRate: 72,
          bpSystolic: 120,
          bpDiastolic: 80,
          spo2: 98.2,
          bodyTemp: 36.8,
          sleepHours: 7.2,
          sleepQuality: 88,
          radiationRate: 0.9,
          accumulatedRadiation: 42.5,
          intracranialPressure: 12.0,
          fatigueScore: 2,
          ambientCo2: 2.2,
        );

  List<SynergyRiskFactor> _activeSynergies = [];
  List<SynergyRiskFactor> get activeSynergies => _activeSynergies;

  List<EmergencyProtocol> _protocols = [];
  List<EmergencyProtocol> get protocols => _protocols;

  List<SyncPacket> _syncPackets = [];
  List<SyncPacket> get syncPackets => _syncPackets;

  MissionScenario _activeScenario = MissionScenario.nominalArtemis;
  MissionScenario get activeScenario => _activeScenario;

  bool _isTransmittingSync = false;
  bool get isTransmittingSync => _isTransmittingSync;

  int get queuedOfflinePacketsCount =>
      _syncPackets.where((p) => p.syncStatus == 'OFFLINE_QUEUED').length;

  // Selected organ on Digital Twin
  String _selectedOrgan = 'brain';
  String get selectedOrgan => _selectedOrgan;

  Future<void> initialize() async {
    await _storage.init();
    _currentLanguage = _storage.getLanguage();
    _astronaut = _storage.getAstronaut();
    _vitalsHistory = _storage.getVitalsHistory();
    _protocols = _storage.getProtocols();
    _syncPackets = _storage.getSyncPackets();
    _reevaluateSynergies();
    _isInitialized = true;
    notifyListeners();
  }

  void setSelectedOrgan(String organ) {
    _selectedOrgan = organ;
    notifyListeners();
  }

  void toggleLanguage() async {
    _currentLanguage = _currentLanguage == 'en' ? 'fr' : 'en';
    await _storage.setLanguage(_currentLanguage);
    notifyListeners();
  }

  void _reevaluateSynergies() {
    _activeSynergies = HrpSynergyEngine.evaluateSynergies(latestVitals);
  }

  Future<void> addVitalsRecord(VitalsRecord record) async {
    _vitalsHistory.insert(0, record);
    await _storage.saveVitalsRecord(record);
    _syncPackets = _storage.getSyncPackets();
    _reevaluateSynergies();
    notifyListeners();
  }

  Future<void> toggleProtocolStep(String protocolId, int stepNumber) async {
    final protocolIndex = _protocols.indexWhere((p) => p.id == protocolId);
    if (protocolIndex != -1) {
      final stepIndex = _protocols[protocolIndex]
          .steps
          .indexWhere((s) => s.stepNumber == stepNumber);
      if (stepIndex != -1) {
        final current = _protocols[protocolIndex].steps[stepIndex].isCompleted;
        _protocols[protocolIndex].steps[stepIndex].isCompleted = !current;
        await _storage.saveProtocols(_protocols);
        notifyListeners();
      }
    }
  }

  // Simulated Deep-Space Sync Engine (Store & Forward)
  Future<void> triggerOfflineSync() async {
    if (_isTransmittingSync) return;
    _isTransmittingSync = true;
    notifyListeners();

    // Mark queued as transmitting
    for (var p in _syncPackets) {
      if (p.syncStatus == 'OFFLINE_QUEUED') {
        p.syncStatus = 'TRANSMITTING';
      }
    }
    notifyListeners();

    // Realistic deep space transmission latency delay simulation (2.5 seconds in UI)
    await Future.delayed(const Duration(milliseconds: 2500));

    final now = DateTime.now();
    for (var p in _syncPackets) {
      if (p.syncStatus == 'TRANSMITTING') {
        p.syncStatus = 'CONFIRMED_EARTH';
        p.syncedAt = now;
      }
    }
    await _storage.updateSyncPackets(_syncPackets);
    _isTransmittingSync = false;
    notifyListeners();
  }

  // Live Scenario Injector (Indispensable for NASA Space Apps Judges)
  Future<void> loadScenario(MissionScenario scenario) async {
    _activeScenario = scenario;
    final now = DateTime.now();
    late VitalsRecord scenarioRecord;

    switch (scenario) {
      case MissionScenario.nominalArtemis:
        scenarioRecord = VitalsRecord(
          id: 'SCEN-NOM-${now.millisecondsSinceEpoch}',
          timestamp: now,
          heartRate: 68,
          bpSystolic: 118,
          bpDiastolic: 76,
          spo2: 98.6,
          bodyTemp: 36.8,
          sleepHours: 7.4,
          sleepQuality: 92,
          radiationRate: 0.82,
          accumulatedRadiation: 42.1,
          intracranialPressure: 11.2,
          fatigueScore: 2,
          ambientCo2: 2.1,
        );
        _selectedOrgan = 'cardio';
        break;

      case MissionScenario.solarFlareEva:
        scenarioRecord = VitalsRecord(
          id: 'SCEN-SPE-${now.millisecondsSinceEpoch}',
          timestamp: now,
          heartRate: 118,
          bpSystolic: 142,
          bpDiastolic: 92,
          spo2: 96.2,
          bodyTemp: 37.4,
          sleepHours: 4.8,
          sleepQuality: 52,
          radiationRate: 28.6, // Spike!
          accumulatedRadiation: 68.4,
          intracranialPressure: 14.8,
          fatigueScore: 7,
          ambientCo2: 2.9,
        );
        _selectedOrgan = 'immune';
        break;

      case MissionScenario.sansCrisis:
        scenarioRecord = VitalsRecord(
          id: 'SCEN-SANS-${now.millisecondsSinceEpoch}',
          timestamp: now,
          heartRate: 84,
          bpSystolic: 136,
          bpDiastolic: 88,
          spo2: 97.0,
          bodyTemp: 36.9,
          sleepHours: 3.5, // Severe insomnia
          sleepQuality: 40,
          radiationRate: 1.4,
          accumulatedRadiation: 44.0,
          intracranialPressure: 21.8, // Critical SANS
          fatigueScore: 8,
          ambientCo2: 3.8, // High CO2 synergy
        );
        _selectedOrgan = 'eyes';
        break;

      case MissionScenario.airlockHypoxia:
        scenarioRecord = VitalsRecord(
          id: 'SCEN-HYP-${now.millisecondsSinceEpoch}',
          timestamp: now,
          heartRate: 124, // Extreme compensatory tachycardia
          bpSystolic: 154,
          bpDiastolic: 98,
          spo2: 88.5, // Severe hypoxia!
          bodyTemp: 37.1,
          sleepHours: 6.0,
          sleepQuality: 65,
          radiationRate: 1.1,
          accumulatedRadiation: 43.2,
          intracranialPressure: 15.2,
          fatigueScore: 8,
          ambientCo2: 5.2, // Critical hypercapnia
        );
        _selectedOrgan = 'lungs';
        break;
    }

    await addVitalsRecord(scenarioRecord);
  }
}
