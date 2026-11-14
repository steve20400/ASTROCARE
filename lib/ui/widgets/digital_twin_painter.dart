import 'package:flutter/material.dart';
import '../../models/vitals.dart';
import '../theme.dart';

class DigitalTwinWidget extends StatelessWidget {
  final VitalsRecord vitals;
  final String selectedOrgan;
  final Function(String organ) onSelectOrgan;

  const DigitalTwinWidget({
    super.key,
    required this.vitals,
    required this.selectedOrgan,
    required this.onSelectOrgan,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // System Selection Ribbon
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              _buildSelectorChip('brain', 'NEURO-CNS', Icons.psychology),
              const SizedBox(width: 6),
              _buildSelectorChip('eyes', 'OPTIC SANS', Icons.remove_red_eye),
              const SizedBox(width: 6),
              _buildSelectorChip('cardio', 'CARDIO-HEMO', Icons.favorite),
              const SizedBox(width: 6),
              _buildSelectorChip('lungs', 'PULMONARY', Icons.air),
              const SizedBox(width: 6),
              _buildSelectorChip('immune', 'IMMUNE-GENOME', Icons.shield),
              const SizedBox(width: 6),
              _buildSelectorChip('musculo', 'OSTEOMUSCULAR', Icons.accessibility),
            ],
          ),
        ),

        // Holographic Biomechanical Canvas
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          height: 330,
          decoration: BoxDecoration(
            color: AstroTheme.bgDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AstroTheme.borderCard),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Vector Silhouette & Technical Grid
              Positioned.fill(
                child: CustomPaint(
                  painter: _AnatomicalHologramPainter(
                    selectedOrgan: selectedOrgan,
                    vitals: vitals,
                  ),
                ),
              ),

              // Interactive Hologram Hotspots
              // 1. Brain & Cranial Axis
              Positioned(
                top: 36,
                child: _buildInteractiveTarget(
                  id: 'brain',
                  icon: Icons.psychology,
                  label: 'NEURO',
                  status: vitals.fatigueScore >= 7
                      ? (vitals.fatigueScore >= 9 ? HealthStatus.critical : HealthStatus.caution)
                      : HealthStatus.nominal,
                ),
              ),

              // 2. Optic / SANS
              Positioned(
                top: 66,
                child: _buildInteractiveTarget(
                  id: 'eyes',
                  icon: Icons.remove_red_eye,
                  label: 'SANS',
                  status: vitals.intracranialPressure > 16.0
                      ? (vitals.intracranialPressure > 20.0 ? HealthStatus.critical : HealthStatus.caution)
                      : HealthStatus.nominal,
                ),
              ),

              // 3. Heart / Cardiovascular
              Positioned(
                top: 110,
                left: 105,
                child: _buildInteractiveTarget(
                  id: 'cardio',
                  icon: Icons.favorite,
                  label: 'CARDIO',
                  status: (vitals.heartRate > 100 || vitals.bpSystolic > 140)
                      ? (vitals.heartRate > 120 ? HealthStatus.critical : HealthStatus.caution)
                      : HealthStatus.nominal,
                ),
              ),

              // 4. Pulmonary
              Positioned(
                top: 116,
                right: 105,
                child: _buildInteractiveTarget(
                  id: 'lungs',
                  icon: Icons.air,
                  label: 'RESP',
                  status: vitals.spo2 < 95.0
                      ? (vitals.spo2 < 91.0 ? HealthStatus.critical : HealthStatus.caution)
                      : HealthStatus.nominal,
                ),
              ),

              // 5. Immune & DNA Axis
              Positioned(
                top: 168,
                child: _buildInteractiveTarget(
                  id: 'immune',
                  icon: Icons.shield,
                  label: 'DNA/IMM',
                  status: vitals.radiationRate > 5.0
                      ? (vitals.radiationRate > 15.0 ? HealthStatus.critical : HealthStatus.caution)
                      : HealthStatus.nominal,
                ),
              ),

              // 6. Musculoskeletal
              Positioned(
                top: 236,
                child: _buildInteractiveTarget(
                  id: 'musculo',
                  icon: Icons.accessibility,
                  label: 'BONE/MUSC',
                  status: HealthStatus.nominal,
                ),
              ),

              // Technical Reticle Overlays
              Positioned(
                top: 10,
                left: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BIO-TWIN: PHOENIX-1',
                      style: TextStyle(
                        fontSize: 9,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        color: AstroTheme.spaceCyan,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      'MASS: 64.2 KG • H: 178 CM',
                      style: TextStyle(
                        fontSize: 8,
                        fontFamily: 'monospace',
                        color: AstroTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                top: 10,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AstroTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AstroTheme.borderCard),
                  ),
                  child: const Text(
                    'ORTHOGONAL SCAN: 1.0G EQ',
                    style: TextStyle(
                      fontSize: 8,
                      fontFamily: 'monospace',
                      color: AstroTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectorChip(String id, String label, IconData icon) {
    final isSelected = selectedOrgan == id;
    return InkWell(
      onTap: () => onSelectOrgan(id),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AstroTheme.spaceCyan : AstroTheme.cardDark,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AstroTheme.spaceCyan : AstroTheme.borderCard,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? Colors.black : AstroTheme.spaceCyan,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: 0.6,
                color: isSelected ? Colors.black : AstroTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveTarget({
    required String id,
    required IconData icon,
    required String label,
    required HealthStatus status,
  }) {
    final isSelected = selectedOrgan == id;
    Color statusColor = status == HealthStatus.critical
        ? AstroTheme.criticalCoral
        : (status == HealthStatus.caution
            ? AstroTheme.cautionAmber
            : AstroTheme.nominalEmerald);

    return GestureDetector(
      onTap: () => onSelectOrgan(id),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: isSelected
                  ? statusColor.withValues(alpha: 0.25)
                  : AstroTheme.surfaceElevated,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? statusColor : statusColor.withValues(alpha: 0.7),
                width: isSelected ? 2.2 : 1.2,
              ),
            ),
            child: Icon(
              icon,
              size: 15,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: AstroTheme.bgDark,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: isSelected ? statusColor : AstroTheme.borderCard,
                width: 0.6,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 7.5,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: isSelected ? statusColor : AstroTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnatomicalHologramPainter extends CustomPainter {
  final String selectedOrgan;
  final VitalsRecord vitals;

  _AnatomicalHologramPainter({
    required this.selectedOrgan,
    required this.vitals,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Technical Sub-surface Grid
    final gridPaint = Paint()
      ..color = const Color(0xFF131C2D)
      ..strokeWidth = 0.8;

    for (double y = 20; y < size.height; y += 30) {
      canvas.drawLine(Offset(20, y), Offset(size.width - 20, y), gridPaint);
    }
    for (double x = 30; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 20), Offset(x, size.height - 20), gridPaint);
    }

    // Concentric Target Rings
    final ringPaint = Paint()
      ..color = const Color(0xFF1B273F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(Offset(cx, cy - 10), 90, ringPaint);
    canvas.drawCircle(Offset(cx, cy - 10), 135, ringPaint);

    // Crosshairs
    final crossHairPaint = Paint()
      ..color = const Color(0xFF243452)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(cx - 150, cy - 10), Offset(cx + 150, cy - 10), crossHairPaint);
    canvas.drawLine(Offset(cx, 15), Offset(cx, size.height - 15), crossHairPaint);

    // Precise Anatomical Vector Paths
    final wireframePaint = Paint()
      ..color = const Color(0xFF1E2F4C)
      ..style = PaintingStyle.fill;

    final contourPaint = Paint()
      ..color = AstroTheme.spaceCyan.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final bodyPath = Path();

    // Cranium
    bodyPath.addOval(Rect.fromCenter(center: Offset(cx, 48), width: 34, height: 42));

    // Neck & Torso
    bodyPath.moveTo(cx - 14, 69);
    bodyPath.lineTo(cx - 38, 86); // Left clavicle
    bodyPath.lineTo(cx - 52, 132); // Left upper arm
    bodyPath.lineTo(cx - 44, 134);
    bodyPath.lineTo(cx - 32, 98);
    bodyPath.lineTo(cx - 24, 155); // Left flank
    bodyPath.lineTo(cx - 32, 245); // Left femur/tibia
    bodyPath.lineTo(cx - 12, 245);
    bodyPath.lineTo(cx - 4, 162); // Pelvis notch
    bodyPath.lineTo(cx + 4, 162);
    bodyPath.lineTo(cx + 12, 245); // Right femur/tibia
    bodyPath.lineTo(cx + 32, 245);
    bodyPath.lineTo(cx + 24, 155); // Right flank
    bodyPath.lineTo(cx + 32, 98);
    bodyPath.lineTo(cx + 44, 134);
    bodyPath.lineTo(cx + 52, 132); // Right upper arm
    bodyPath.lineTo(cx + 38, 86); // Right clavicle
    bodyPath.lineTo(cx + 14, 69);
    bodyPath.close();

    canvas.drawPath(bodyPath, wireframePaint);
    canvas.drawPath(bodyPath, contourPaint);

    // Anatomical Internal Landmarks (Thoracic cage & Spine trace)
    final landmarkPaint = Paint()
      ..color = AstroTheme.spaceCyan.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Spine
    canvas.drawLine(Offset(cx, 70), Offset(cx, 160), landmarkPaint);

    // Rib markers
    canvas.drawLine(Offset(cx - 18, 98), Offset(cx + 18, 98), landmarkPaint);
    canvas.drawLine(Offset(cx - 20, 110), Offset(cx + 20, 110), landmarkPaint);
    canvas.drawLine(Offset(cx - 18, 122), Offset(cx + 18, 122), landmarkPaint);

    // Ocular Visor Band
    final visorPaint = Paint()
      ..color = AstroTheme.spaceCyan.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, 46), width: 22, height: 10),
        const Radius.circular(3),
      ),
      visorPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AnatomicalHologramPainter oldDelegate) {
    return oldDelegate.selectedOrgan != selectedOrgan ||
        oldDelegate.vitals.id != vitals.id;
  }
}
