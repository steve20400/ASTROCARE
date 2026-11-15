// Visual identity: NASA Space Apps color palette (brand guidelines of June 2026),
// status colors, light and dark themes.
// Rules followed: blues dominate, Neon Yellow is only an accent (the main button),
// reds are never a background, and a status is never shown by color alone.
 
import 'package:flutter/material.dart';
 
import '../domain/models.dart';
 
const Color kDeepBlue = Color(0xFF07173F);
const Color kElectricBlue = Color(0xFF0042A6);
const Color kNeonBlue = Color(0xFF0960E1);
const Color kBlueYonder = Color(0xFF2E96F5);
const Color kNeonYellow = Color(0xFFEAFE07);
const Color kMartianRed = Color(0xFF8E1100);
 
/// Official gradient: Electric Blue (top left) to Deep Blue (bottom right).
const LinearGradient kBrandGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kElectricBlue, kDeepBlue],
);
 
/// Font of the brand guidelines. It is downloaded by the build (tool/get_fonts.sh);
/// when it is missing, the system font is used instead.
const String kFont = 'FiraSans';
 
ThemeData buildTheme(bool dark) {
  final base = ColorScheme.fromSeed(
    seedColor: kElectricBlue,
    brightness: dark ? Brightness.dark : Brightness.light,
  );
  final scheme = dark
      ? base.copyWith(
          primary: kBlueYonder,
          onPrimary: kDeepBlue,
          primaryContainer: kElectricBlue,
          onPrimaryContainer: Colors.white,
          secondary: kBlueYonder,
          onSecondary: kDeepBlue,
          secondaryContainer: kElectricBlue,
          onSecondaryContainer: Colors.white,
          surface: kDeepBlue,
          onSurface: Colors.white,
          onSurfaceVariant: const Color(0xFFC5D3F0),
          surfaceContainerLowest: const Color(0xFF0A1D4D),
          surfaceContainerLow: const Color(0xFF0E2459),
          surfaceContainer: const Color(0xFF122B66),
          surfaceContainerHigh: const Color(0xFF163273),
          surfaceContainerHighest: const Color(0xFF1B3A82),
          surfaceTint: Colors.transparent,
          outline: const Color(0xFF6C84B8),
          outlineVariant: const Color(0xFF2B4380),
          error: const Color(0xFFFF8A6B),
          onError: kDeepBlue,
        )
      : base.copyWith(
          primary: kElectricBlue,
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFFD6E6FF),
          onPrimaryContainer: kDeepBlue,
          secondary: kNeonBlue,
          onSecondary: Colors.white,
          secondaryContainer: const Color(0xFFD6E6FF),
          onSecondaryContainer: kDeepBlue,
          surface: Colors.white,
          onSurface: kDeepBlue,
          onSurfaceVariant: const Color(0xFF3A4A6B),
          surfaceContainerLowest: Colors.white,
          surfaceContainerLow: const Color(0xFFF3F7FE),
          surfaceContainer: const Color(0xFFEAF1FD),
          surfaceContainerHigh: const Color(0xFFE3ECFB),
          surfaceContainerHighest: const Color(0xFFDCE7FA),
          surfaceTint: Colors.transparent,
          outline: const Color(0xFF7B8AA8),
          outlineVariant: const Color(0xFFC9D6EE),
          error: kMartianRed,
          onError: Colors.white,

        );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    fontFamily: kFont,
    appBarTheme: const AppBarTheme(
      backgroundColor: kDeepBlue,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontFamily: kFont,
        fontWeight: FontWeight.w900,
        fontSize: 20,
        letterSpacing: 1,
        color: Colors.white,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: kNeonYellow,
      foregroundColor: kDeepBlue,
    ),
  );
}
 
bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;
 
/// Status color. Null level means "no data" and gives a neutral grey.
/// Each color keeps a contrast of at least 4.5:1 with its background.
Color levelColor(BuildContext context, AlertLevel? level) {
  return levelColorFor(isDark(context), level);
}
 
/// Same colors, for a place whose background does not follow the theme.
Color levelColorFor(bool dark, AlertLevel? level) {
  switch (level) {
    case AlertLevel.nominal:
      return dark ? const Color(0xFF6FDC8C) : const Color(0xFF1B7A33);
    case AlertLevel.attention:
      return dark ? const Color(0xFFFFD166) : const Color(0xFF9A5B00);
    case AlertLevel.critical:
      return dark ? const Color(0xFFFF8A6B) : kMartianRed;
    case null:
      return dark ? const Color(0xFFC5D3F0) : const Color(0xFF5B6884);
  }
}
 
/// The status is never shown by color alone: it always has an icon and a label.
IconData levelIcon(AlertLevel? level) {
  switch (level) {
    case AlertLevel.nominal:
      return Icons.check_circle;
    case AlertLevel.attention:
      return Icons.warning_amber_rounded;
    case AlertLevel.critical:
      return Icons.error;
    case null:
      return Icons.help_outline;
  }
}
 
String levelKey(AlertLevel? level) => level == null ? 'level.nodata' : 'level.${level.name}';
 
IconData indicatorIcon(String code) {
  switch (code) {
    case 'heartRate':
      return Icons.favorite_border;
    case 'temperature':
      return Icons.thermostat;
    case 'sleepDuration':
      return Icons.bedtime_outlined;
    case 'mood':
      return Icons.mood;
    default:
      return Icons.monitor_heart_outlined;
  }
}
