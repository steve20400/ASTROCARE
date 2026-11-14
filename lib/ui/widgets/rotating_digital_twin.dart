import 'package:flutter/material.dart';

import '../../models/twin_projection.dart';
import '../../models/vitals.dart';
import '../responsive.dart';
import '../theme.dart';
import 'rotating_twin_painter.dart';

/// Interactive 360 degrees anatomical twin.
///
/// Rotation is the point of view; the scan pass is the information: during a
/// full turn each of the six regions lights up in turn and drives the organ
/// inspector. Horizontal drag rotates, vertical scrolling stays with the
/// parent ListView (Flutter's gesture arena), so there is no gesture conflict
/// on mobile.
class RotatingDigitalTwin extends StatefulWidget {
  final VitalsRecord vitals;
  final String selectedOrgan;
  final ValueChanged<String> onSelectOrgan;

  const RotatingDigitalTwin({
    super.key,
    required this.vitals,
    required this.selectedOrgan,
    required this.onSelectOrgan,
  });

  @override
  State<RotatingDigitalTwin> createState() => _RotatingDigitalTwinState();
}

class _RotatingDigitalTwinState extends State<RotatingDigitalTwin>
    with SingleTickerProviderStateMixin {
  double _angle = 0;
  double _scanStartAngle = 0;
  bool _scanning = false;
  String? _scanHighlight;
  String? _lastScanRegion;
  late final AnimationController _controller;

  static const Duration _scanDuration = Duration(seconds: 8);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _scanDuration)
      ..addListener(_onScanTick)
      ..addStatusListener(_onScanStatus);
  }

  void _onScanTick() {
    final progress = _controller.value;
    final region = TwinProjection.scanRegion(progress);
    if (region != _lastScanRegion) {
      _lastScanRegion = region;
      // The detailed inspector card follows the sweep, exactly like the
      // web prototype's "Balisage 3/6" behaviour.
      widget.onSelectOrgan(region);
    }
    if (!mounted) return;
    setState(() {
      _angle = TwinProjection.normalizeAngle(_scanStartAngle + progress * 360);
      _scanHighlight = region;
    });
  }

  void _onScanStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      if (!mounted) return;
      setState(() {
        _scanning = false;
        _scanHighlight = null;
        _lastScanRegion = null;
      });
    }
  }

  void _toggleScan() {
    if (_scanning) {
      _controller.stop();
      setState(() {
        _scanning = false;
        _scanHighlight = null;
        _lastScanRegion = null;
      });
      return;
    }
    _scanStartAngle = _angle;
    _lastScanRegion = null;
    setState(() => _scanning = true);
    _controller.forward(from: 0);
  }

  void _rotate(double deltaDegrees) {
    if (_scanning) return;
    if (!mounted) return;
    setState(
      () => _angle = TwinProjection.normalizeAngle(_angle + deltaDegrees),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final compact = AstroLayout.isCompact(size.width);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildRegionRibbon(),
        _buildCanvas(
          AstroLayout.twinCanvasHeight(size.width, size.height),
          compact,
        ),
        _buildControls(compact),
        _buildLegend(compact),
      ],
    );
  }

  Widget _buildRegionRibbon() {
    const icons = <String, IconData>{
      'brain': Icons.psychology,
      'eyes': Icons.remove_red_eye,
      'cardio': Icons.favorite,
      'lungs': Icons.air,
      'immune': Icons.shield,
      'musculo': Icons.accessibility,
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          for (final region in kTwinRegions) ...[
            _regionChip(region, kTwinRegionLabels[region]!, icons[region]!),
            const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }

  Widget _regionChip(String id, String label, IconData icon) {
    final selected = widget.selectedOrgan == id;
    return InkWell(
      onTap: () => widget.onSelectOrgan(id),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AstroTheme.spaceCyan : AstroTheme.cardDark,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? AstroTheme.spaceCyan : AstroTheme.borderCard,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 13,
              color: selected ? Colors.black : AstroTheme.spaceCyan,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: 0.6,
                color: selected ? Colors.black : AstroTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvas(double canvasHeight, bool compact) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: compact ? 12 : 20, vertical: 6),
      height: canvasHeight,
      decoration: BoxDecoration(
        color: AstroTheme.bgDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AstroTheme.borderCard),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = AstroLayout.twinScale(
            constraints.maxWidth,
            constraints.maxHeight,
          );
          final top = AstroLayout.twinTop(constraints.maxHeight, scale);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            // Only horizontal gestures are claimed: vertical ones belong to
            // the enclosing ListView. This is the Flutter equivalent of
            // touch-action: pan-y on the web prototype.
            onHorizontalDragUpdate: (details) =>
                _rotate(details.delta.dx * 0.7),
            onTapUp: (details) {
              final region = TwinProjection.regionAt(
                tapX: details.localPosition.dx,
                tapY: details.localPosition.dy,
                angleDegrees: _angle,
                scale: scale,
                centerX: constraints.maxWidth / 2.0,
                top: top,
              );
              if (region != null) widget.onSelectOrgan(region);
            },
            child: CustomPaint(
              painter: RotatingTwinPainter(
                angleDegrees: _angle,
                selectedOrgan: widget.selectedOrgan,
                scanHighlight: _scanHighlight,
                vitals: widget.vitals,
              ),
              child: const SizedBox.expand(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildControls(bool compact) {
    final displayAngle = _angle.round() % 360;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 20, vertical: 4),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AstroTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AstroTheme.borderCard),
            ),
            child: Text(
              '${displayAngle.toString().padLeft(3, '0')}°',
              style: const TextStyle(
                fontSize: 10,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
                color: AstroTheme.spaceCyan,
              ),
            ),
          ),
          IconButton(
            tooltip: '-15°',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.rotate_left, size: 18),
            color: AstroTheme.textSecondary,
            onPressed: () => _rotate(-15),
          ),
          SizedBox(
            width: compact ? 130 : 220,
            child: Slider(
              value: _angle.clamp(0.0, 359.0).toDouble(),
              min: 0,
              max: 359,
              activeColor: AstroTheme.spaceCyan,
              onChanged: _scanning ? null : (value) => _rotate(value - _angle),
            ),
          ),
          IconButton(
            tooltip: '+15°',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.rotate_right, size: 18),
            color: AstroTheme.textSecondary,
            onPressed: () => _rotate(15),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _scanning
                  ? AstroTheme.cardDark
                  : AstroTheme.nasaBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
            onPressed: _toggleScan,
            icon: Icon(_scanning ? Icons.stop : Icons.radar, size: 15),
            label: Text(_scanning ? 'ARRÊTER' : 'PASSE DE SCAN 360°'),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(bool compact) {
    final index = kTwinRegions.indexOf(widget.selectedOrgan);
    final step = index >= 0 ? index + 1 : 1;
    final label = kTwinRegionLabels[widget.selectedOrgan] ?? 'SYSTEME';
    final message = _scanning
        ? 'BALISAGE $step/${kTwinRegions.length} — $label'
        : 'VUE 360° • glissez horizontalement pour tourner, touchez une région';
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 20, vertical: 4),
      child: Row(
        children: [
          Icon(
            _scanning ? Icons.radar : Icons.touch_app,
            size: 12,
            color: AstroTheme.spaceCyan,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 9,
                fontFamily: 'monospace',
                color: AstroTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
