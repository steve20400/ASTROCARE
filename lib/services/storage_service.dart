import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vitals.dart';
import '../models/protocol.dart';

class OfflineStorageService {
  static const String _keyVitals = 'astrocare_vitals_records';
  static const String _keyPackets = 'astrocare_sync_packets';
  static const String _keyProtocols = 'astrocare_emergency_protocols';
  static const String _keyAstronaut = 'astrocare_current_astronaut';
  static const String _keyLanguage = 'astrocare_language_code';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Seed initial historical data if clean start
    if (!_prefs.containsKey(_keyVitals)) {
      await _seedInitialData();
    }
  }

  // Language preference
  String getLanguage() => _prefs.getString(_keyLanguage) ?? 'en';
  Future<void> setLanguage(String code) => _prefs.setString(_keyLanguage, code);

  // Astronaut Profile
  Astronaut getAstronaut() {
    final raw = _prefs.getString(_keyAstronaut);
    if (raw != null) {
      return Astronaut.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }
    return const Astronaut(
      id: 'ASTRO-084',
      name: 'Dr. Sarah Lin',
      callsign: 'PHOENIX-1',
      role: 'Flight Surgeon & Science Officer',
      mission: 'Artemis IV / Mars Transit',
      missionDay: 142,
      bloodType: 'O Rh+',
      bodyMassKg: 64.2,
    );
  }

  Future<void> saveAstronaut(Astronaut astronaut) async {
    await _prefs.setString(_keyAstronaut, jsonEncode(astronaut.toJson()));
  }

  // Vitals Records History
  List<VitalsRecord> getVitalsHistory() {
    final rawList = _prefs.getStringList(_keyVitals) ?? [];
    return rawList
        .map((str) => VitalsRecord.fromJson(jsonDecode(str) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveVitalsRecord(VitalsRecord record) async {
    final list = _prefs.getStringList(_keyVitals) ?? [];
    list.insert(0, jsonEncode(record.toJson()));
    // Keep last 150 readings in local storage
    if (list.length > 150) {
      list.removeRange(150, list.length);
    }
    await _prefs.setStringList(_keyVitals, list);

    // Automatically enqueue offline sync packet
    await enqueueSyncPacket(SyncPacket(
      id: 'PKT-${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      packetType: 'VITALS_TELEMETRY',
      payloadSummary: 'HR: ${record.heartRate} bpm, SpO2: ${record.spo2}%, Rad: ${record.radiationRate} uSv/h',
      byteSize: 342,
      syncStatus: 'OFFLINE_QUEUED',
    ));
  }

  // Offline Sync Packets Queue
  List<SyncPacket> getSyncPackets() {
    final rawList = _prefs.getStringList(_keyPackets) ?? [];
    return rawList
        .map((str) => SyncPacket.fromJson(jsonDecode(str) as Map<String, dynamic>))
        .toList();
  }

  Future<void> enqueueSyncPacket(SyncPacket packet) async {
    final list = _prefs.getStringList(_keyPackets) ?? [];
    list.insert(0, jsonEncode(packet.toJson()));
    if (list.length > 200) {
      list.removeRange(200, list.length);
    }
    await _prefs.setStringList(_keyPackets, list);
  }

  Future<void> updateSyncPackets(List<SyncPacket> packets) async {
    final list = packets.map((p) => jsonEncode(p.toJson())).toList();
    await _prefs.setStringList(_keyPackets, list);
  }

  // Emergency Protocols
  List<EmergencyProtocol> getProtocols() {
    final rawList = _prefs.getStringList(_keyProtocols);
    if (rawList != null && rawList.isNotEmpty) {
      return rawList
          .map((str) => EmergencyProtocol.fromJson(jsonDecode(str) as Map<String, dynamic>))
          .toList();
    }
    final defaultProtocols = _getDefaultProtocols();
    saveProtocols(defaultProtocols);
    return defaultProtocols;
  }

  Future<void> saveProtocols(List<EmergencyProtocol> protocols) async {
    final list = protocols.map((p) => jsonEncode(p.toJson())).toList();
    await _prefs.setStringList(_keyProtocols, list);
  }

  Future<void> _seedInitialData() async {
    final now = DateTime.now();
    final defaultRecords = <VitalsRecord>[];

    // Seed 24 hours of simulated spaceflight telemetry
    for (int i = 0; i < 24; i++) {
      final t = now.subtract(Duration(hours: 23 - i));
      defaultRecords.add(VitalsRecord(
        id: 'REC-$i',
        timestamp: t,
        heartRate: 68 + (i % 6) * 2,
        bpSystolic: 118 + (i % 4),
        bpDiastolic: 76 + (i % 3),
        spo2: 98.4 - (i % 3) * 0.4,
        bodyTemp: 36.8 + (i % 5) * 0.1,
        sleepHours: 7.2,
        sleepQuality: 88,
        radiationRate: 0.85 + (i % 4) * 0.1,
        accumulatedRadiation: 42.1 + (i * 0.05),
        intracranialPressure: 11.5 + (i % 3) * 0.4,
        fatigueScore: 2 + (i % 3),
        ambientCo2: 2.4,
      ));
    }

    final rawVitals = defaultRecords.reversed.map((r) => jsonEncode(r.toJson())).toList();
    await _prefs.setStringList(_keyVitals, rawVitals);

    final defaultPackets = <SyncPacket>[
      SyncPacket(
        id: 'PKT-INIT-01',
        createdAt: now.subtract(const Duration(minutes: 45)),
        packetType: 'MISSION_LOG',
        payloadSummary: 'EVA ingress checklist verified - Airlock nominal',
        byteSize: 1840,
        syncStatus: 'OFFLINE_QUEUED',
      ),
      SyncPacket(
        id: 'PKT-INIT-02',
        createdAt: now.subtract(const Duration(hours: 2)),
        packetType: 'VITALS_TELEMETRY',
        payloadSummary: 'Daily circadian cycle - Baseline nominal parameters',
        byteSize: 940,
        syncStatus: 'CONFIRMED_EARTH',
        syncedAt: now.subtract(const Duration(minutes: 90)),
      ),
    ];
    await _prefs.setStringList(_keyPackets, defaultPackets.map((p) => jsonEncode(p.toJson())).toList());
    await saveProtocols(_getDefaultProtocols());
  }

  List<EmergencyProtocol> _getDefaultProtocols() {
    return [
      EmergencyProtocol(
        id: 'PROT-SPE-01',
        code: 'HRP-RAD-04',
        title: 'Solar Particle Event (SPE) Shelter Protocol',
        category: 'Radiation & Shielding',
        priority: HealthStatus.critical,
        rationale: 'Active coronal mass ejection (CME) or solar proton flux exceeding safe threshold (>15 uSv/h). High acute radiation syndrome risk.',
        flightRuleReference: 'NASA HRP Flight Rule 8.4.1 — Storm Shelter Operations',
        steps: [
          ProtocolStep(
            stepNumber: 1,
            title: 'Immediate Cabin Alert & Abort EVA',
            instructions: 'Sound interior storm warning, issue crew recall if in EVA airlock, seal secondary hatch.',
            requiredTool: 'Hatch Lock Override / Comm Intercom',
          ),
          ProtocolStep(
            stepNumber: 2,
            title: 'Deploy Water Wall & Food Ration Shielding',
            instructions: 'Reposition active polyethylene water ballast containers around crew sleeping berths to form a high-density proton shield.',
            requiredTool: 'Internal Cargo Winch / Modular Brackets',
          ),
          ProtocolStep(
            stepNumber: 3,
            title: 'Administer Radioprotectant & Antioxidant Therapy',
            instructions: 'Administer Oral Amifostine / Vitamin C+E / Glutathione cocktail as prescribed in medical kit drawer 4.',
            requiredTool: 'Medical Kit C-3 (Radioprotectants)',
          ),
          ProtocolStep(
            stepNumber: 4,
            title: 'Activate Passive & Active Dosimeters',
            instructions: 'Zero electronic pocket dosimeters (EPD) and place lithium fluoride TLD badges at head, chest, and gonadal regions.',
            requiredTool: 'EPD Mark-IV Dosimeter Kit',
          ),
        ],
      ),
      EmergencyProtocol(
        id: 'PROT-SANS-02',
        code: 'HRP-EYE-07',
        title: 'SANS Cephalad Fluid Shift Decompression',
        category: 'Neuro-Ocular (SANS)',
        priority: HealthStatus.caution,
        rationale: 'Intracranial pressure estimation >18 mmHg or optic disc edema detected via onboard ultrasound/fundoscopy.',
        flightRuleReference: 'NASA HRP Spaceflight Standard Measures 3.2 — SANS Mitigation',
        steps: [
          ProtocolStep(
            stepNumber: 1,
            title: 'Lower Body Negative Pressure (LBNP) Session',
            instructions: 'Secure crew member in Chibis/LBNP chamber at -35 mmHg for 60 minutes to pull fluids from cranium to lower extremities.',
            requiredTool: 'LBNP Vacuum Device',
          ),
          ProtocolStep(
            stepNumber: 2,
            title: 'Fundoscopy & Optic Nerve Sheath Ultrasound',
            instructions: 'Perform bilateral optic nerve sheath diameter (ONSD) ultrasound; record depth measurements for offline validation.',
            requiredTool: 'Butterfly iQ+ Space Ultrasound Probe',
          ),
          ProtocolStep(
            stepNumber: 3,
            title: 'Adjust Cabin Partial CO2 Pressure',
            instructions: 'Verify CDRA/Amine scrubbers are set to maximum cycle to keep cabin CO2 below 2.0 mmHg.',
            requiredTool: 'Life Support ECLSS Panel',
          ),
        ],
      ),
      EmergencyProtocol(
        id: 'PROT-CARDIO-03',
        code: 'HRP-CVD-02',
        title: 'Cardiovascular Orthostatic Deconditioning Mitigation',
        category: 'Cardiovascular',
        priority: HealthStatus.caution,
        rationale: 'Elevated resting tachycardia with reduced blood pressure pulse width indicating cardiovascular deconditioning.',
        flightRuleReference: 'NASA Flight Rule 11.2 — Exercise Countermeasures',
        steps: [
          ProtocolStep(
            stepNumber: 1,
            title: 'ARED High-Resistance Interval Loading',
            instructions: 'Execute 45-minute high-load squats and heel raises on Advanced Resistive Exercise Device (ARED).',
            requiredTool: 'ARED Exercise Station',
          ),
          ProtocolStep(
            stepNumber: 2,
            title: 'Saline & Electrolyte Fluid Loading',
            instructions: 'Consume 1.0 Liter of isotonic electrolyte solution (saline loading protocol) 2 hours prior to high-G maneuvering.',
            requiredTool: 'Fluid Loading Packs E-1',
          ),
          ProtocolStep(
            stepNumber: 3,
            title: 'Don Compression Garment (G-Suit)',
            instructions: 'Don gradient compression thigh and abdomen suit set at 30-40 mmHg.',
            requiredTool: 'Crew Gravity Garment',
          ),
        ],
      ),
      EmergencyProtocol(
        id: 'PROT-HYPOX-04',
        code: 'ECLSS-ENV-09',
        title: 'Elevated Hypercapnia / Airway Distress Response',
        category: 'Environmental & Pulmonary',
        priority: HealthStatus.critical,
        rationale: 'SpO2 < 92% or Cabin CO2 exceeding 4.0 mmHg causing acute hypercapnic encephalopathy and headache.',
        flightRuleReference: 'ECLSS Emergency Standard Operating Procedure 5.1',
        steps: [
          ProtocolStep(
            stepNumber: 1,
            title: 'Don Quick-Don Emergency Breathing Mask',
            instructions: 'Immediately don 100% O2 mask from secondary manifold supply.',
            requiredTool: 'Quick-Don O2 Mask Station 2',
          ),
          ProtocolStep(
            stepNumber: 2,
            title: 'Manual LiOH Canister Replacement',
            instructions: 'Swap lithium hydroxide CO2 scrubber canister in air duct slot B-4.',
            requiredTool: 'LiOH Replacement Canister (Spare Rack 7)',
          ),
          ProtocolStep(
            stepNumber: 3,
            title: 'Auscultation & Peak Flow Spirometry',
            instructions: 'Check lung sounds for atelectasis and measure peak expiratory flow.',
            requiredTool: 'Digital Stethoscope / Spirometer',
          ),
        ],
      ),
    ];
  }
}
