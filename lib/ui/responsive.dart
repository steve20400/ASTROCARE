/// Mobile-first layout tokens for ASTROCARE.
///
/// The design is written for a 390 px phone first and widened afterwards, not
/// the other way round. Pure Dart (no Flutter import) so the breakpoints can
/// be unit-tested and shared with any future platform port.
class AstroLayout {
  const AstroLayout._();

  /// Below this width: phone layout (single column content, compact HUD).
  static const double compactMax = 600.0;

  /// At or above this width: tablet/desktop layout (wider grid, taller twin).
  static const double expandedMin = 900.0;

  static bool isCompact(double width) => width < compactMax;
  static bool isMedium(double width) =>
      width >= compactMax && width < expandedMin;
  static bool isExpanded(double width) => width >= expandedMin;

  /// Number of telemetry gauge columns. A very narrow phone (foldable closed,
  /// 320 px) drops to one column rather than overflowing.
  static int telemetryColumns(double width) {
    if (width < 340) return 1;
    if (width < 640) return 2;
    if (width < 1000) return 3;
    return 4;
  }

  /// The twin must never eat two screens on a phone: capped at 34 % of the
  /// viewport height, with a floor of 220 px for legibility.
  static double twinCanvasHeight(double width, double screenHeight) {
    final ratio = isCompact(width) ? 0.34 : 0.44;
    return (screenHeight * ratio).clamp(220.0, 360.0).toDouble();
  }

  static double horizontalPadding(double width) =>
      isCompact(width) ? 12.0 : 20.0;

  /// Uniform scale fitting the 320-unit body into the canvas.
  static double twinScale(double canvasWidth, double canvasHeight) {
    final byHeight = canvasHeight / 320.0;
    final byWidth = canvasWidth / 200.0;
    return byHeight < byWidth ? byHeight : byWidth;
  }

  /// Vertical offset of the body's origin inside the canvas.
  static double twinTop(double canvasHeight, double scale) =>
      (canvasHeight - 320.0 * scale) / 2.0;
}
