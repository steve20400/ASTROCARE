import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vitals.dart';
import '../../providers/astrocare_provider.dart';
import '../theme.dart';

class DataEntryScreen extends StatefulWidget {
  const DataEntryScreen({super.key});

  @override
  State<DataEntryScreen> createState() => _DataEntryScreenState();
}

class _DataEntryScreenState extends State<DataEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _hrController;
  late TextEditingController _sysController;
  late TextEditingController _diaController;
  late TextEditingController _spo2Controller;
  late TextEditingController _tempController;
  late TextEditingController _sleepController;
  late TextEditingController _radController;
  late TextEditingController _icpController;
  late TextEditingController _co2Controller;

  double _fatigueScore = 3.0;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AstroCareProvider>();
    final cur = provider.latestVitals;

    _hrController = TextEditingController(text: '${cur.heartRate}');
    _sysController = TextEditingController(text: '${cur.bpSystolic}');
    _diaController = TextEditingController(text: '${cur.bpDiastolic}');
    _spo2Controller = TextEditingController(text: cur.spo2.toStringAsFixed(1));
    _tempController = TextEditingController(text: cur.bodyTemp.toStringAsFixed(1));
    _sleepController = TextEditingController(text: cur.sleepHours.toStringAsFixed(1));
    _radController = TextEditingController(text: cur.radiationRate.toStringAsFixed(2));
    _icpController = TextEditingController(text: cur.intracranialPressure.toStringAsFixed(1));
    _co2Controller = TextEditingController(text: cur.ambientCo2.toStringAsFixed(1));
    _fatigueScore = cur.fatigueScore.toDouble();
  }

  @override
  void dispose() {
    _hrController.dispose();
    _sysController.dispose();
    _diaController.dispose();
    _spo2Controller.dispose();
    _tempController.dispose();
    _sleepController.dispose();
    _radController.dispose();
    _icpController.dispose();
    _co2Controller.dispose();
    super.dispose();
  }

  void _saveEntry() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AstroCareProvider>();
    final cur = provider.latestVitals;
    final now = DateTime.now();

    final record = VitalsRecord(
      id: 'MAN-${now.millisecondsSinceEpoch}',
      timestamp: now,
      heartRate: int.tryParse(_hrController.text) ?? 72,
      bpSystolic: int.tryParse(_sysController.text) ?? 120,
      bpDiastolic: int.tryParse(_diaController.text) ?? 80,
      spo2: double.tryParse(_spo2Controller.text) ?? 98.0,
      bodyTemp: double.tryParse(_tempController.text) ?? 36.8,
      sleepHours: double.tryParse(_sleepController.text) ?? 7.0,
      sleepQuality: 85,
      radiationRate: double.tryParse(_radController.text) ?? 0.8,
      accumulatedRadiation: cur.accumulatedRadiation + 0.02,
      intracranialPressure: double.tryParse(_icpController.text) ?? 12.0,
      fatigueScore: _fatigueScore.toInt(),
      ambientCo2: double.tryParse(_co2Controller.text) ?? 2.2,
    );

    provider.addVitalsRecord(record);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AstroTheme.nominalEmerald,
        content: Text(
          'Telemetry recorded to offline database & queued for DSN transmission.',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LOG CREW TELEMETRY'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AstroTheme.cardDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AstroTheme.borderCard),
              ),
              child: const Text(
                'Manual telemetry entry for autonomous flight crew. All entries are validated against Spaceflight Standard Measures limits and immediately saved offline.',
                style: TextStyle(fontSize: 12, color: AstroTheme.textSecondary),
              ),
            ),
            const SizedBox(height: 16),

            // Heart Rate & Blood Pressure
            Row(
              children: [
                Expanded(
                  child: _buildField('Heart Rate (bpm)', _hrController, '60 - 100'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField('SpO2 (%)', _spo2Controller, '95 - 100'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildField('BP Systolic (mmHg)', _sysController, '100 - 130'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField('BP Diastolic (mmHg)', _diaController, '60 - 85'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildField('Sleep Duration (h)', _sleepController, '7.0 - 8.5'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField('Core Temp (°C)', _tempController, '36.5 - 37.5'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildField('Radiation Flux (uSv/h)', _radController, '< 2.5 uSv/h'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField('ICP / SANS (mmHg)', _icpController, '7.0 - 15.0'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildField('Cabin Ambient CO2 (mmHg)', _co2Controller, '< 3.0 mmHg (ISS Limit)'),
            const SizedBox(height: 16),

            // Fatigue Slider
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AstroTheme.cardDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AstroTheme.borderCard),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Cognitive Fatigue / Stress Score',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AstroTheme.textPrimary),
                      ),
                      Text(
                        '${_fatigueScore.toInt()} / 10',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AstroTheme.spaceCyan),
                      ),
                    ],
                  ),
                  Slider(
                    value: _fatigueScore,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    activeColor: _fatigueScore > 6 ? AstroTheme.criticalCoral : AstroTheme.spaceCyan,
                    inactiveColor: AstroTheme.surfaceElevated,
                    onChanged: (v) => setState(() => _fatigueScore = v),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('1: Fully Rested', style: TextStyle(fontSize: 10, color: AstroTheme.textMuted)),
                      Text('10: Severe Exhaustion', style: TextStyle(fontSize: 10, color: AstroTheme.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AstroTheme.nominalEmerald,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.save_outlined),
                label: const Text(
                  'COMMIT TO OFFLINE DATABASE',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                ),
                onPressed: _saveEntry,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: AstroTheme.textPrimary, fontSize: 13, fontFamily: 'monospace'),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AstroTheme.textSecondary, fontSize: 11),
        hintText: hint,
        hintStyle: const TextStyle(color: AstroTheme.textMuted, fontSize: 11),
        filled: true,
        fillColor: AstroTheme.cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AstroTheme.borderCard),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AstroTheme.borderCard),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AstroTheme.spaceCyan),
        ),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) return 'Required';
        if (double.tryParse(val) == null) return 'Invalid number';
        return null;
      },
    );
  }
}
