import 'package:flutter/material.dart';

class AstroTheme {
  // Official NASA Color Standards (NASA Insignia Blue & Pure White Identity)
  // NASA Blue (Pantone 286): #0B3D91
  // NASA Red (Pantone 185): #FC3D21
  // NASA White: #FFFFFF
  
  // NASA Aerospace Deep Navy & Midnight Cockpit Backgrounds
  static const Color bgDark = Color(0xFF040814); // Deepest NASA Midnight Navy
  static const Color surfaceElevated = Color(0xFF091326); // NASA Cockpit Console
  static const Color cardDark = Color(0xFF0D1B36); // NASA Mission Card
  static const Color cardHover = Color(0xFF142850);

  // Hairline Precision Borders (Crisp NASA White & Blue)
  static const Color borderSubtle = Color(0x26FFFFFF); // 15% Pure White
  static const Color borderCard = Color(0xFF1A3360); // Crisp NASA Structural Blue
  static const Color borderActive = Color(0xFF2563EB); // Vibrant NASA Blue
  static const Color borderWhite = Color(0x4DFFFFFF); // 30% Pure White

  // NASA Primary Blue & Signal Accents
  static const Color nasaBlue = Color(0xFF0B3D91); // Official NASA Insignia Blue
  static const Color nasaBlueElectric = Color(0xFF2563EB); // NASA Digital UI Blue
  static const Color spaceCyan = Color(0xFF38BDF8); // NASA High-Visibility Cockpit Blue
  static const Color deepSpaceBlue = Color(0xFF0A2558); // NASA Navy Deep
  static const Color nasaRed = Color(0xFFFC3D21); // Official NASA Meatball Red
  static const Color laserViolet = Color(0xFF818CF8); // NASA Deep Space Indigo
  static const Color hudAmber = Color(0xFFF59E0B);

  // Strict Tri-State Physiological Standard (NASA Bio-Safety Standard)
  static const Color nominalEmerald = Color(0xFF00E599); // Bio-Nominal Green
  static const Color cautionAmber = Color(0xFFF59E0B); // Bio-Caution Amber
  static const Color criticalCoral = Color(0xFFFC3D21); // NASA Red (Alert)

  // NASA White Monochromatic Hierarchy (Crisp, High-Contrast)
  static const Color textPrimary = Color(0xFFFFFFFF); // Pure NASA White
  static const Color textSecondary = Color(0xFFCBD5E1); // Clean Silver Slate
  static const Color textTertiary = Color(0xFF94A3B8); // Muted Blue Gray
  static const Color textMuted = Color(0xFF64748B); // Low-Priority Slate

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      primaryColor: spaceCyan,
      colorScheme: const ColorScheme.dark(
        primary: spaceCyan,
        secondary: nasaBlue,
        surface: surfaceElevated,
        error: criticalCoral,
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderCard, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceElevated,
        selectedItemColor: spaceCyan,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
