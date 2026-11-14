import 'package:flutter/material.dart';

class AstroTheme {
  // Pure Aerospace Deep Slate (Clean, No-Gradient, Elite Ergonomics)
  static const Color bgDark = Color(0xFF070A11);
  static const Color surfaceElevated = Color(0xFF0D131F);
  static const Color cardDark = Color(0xFF111A2B);
  static const Color cardHover = Color(0xFF172338);
  
  // Hairline Precision Borders (Crisp 1px borders)
  static const Color borderSubtle = Color(0x1AFFFFFF); // 10% white
  static const Color borderActive = Color(0x3300E5FF); // 20% cyan
  static const Color borderCard = Color(0xFF1E2B45);

  // Aerospace Signal Accents
  static const Color spaceCyan = Color(0xFF00E5FF);
  static const Color nasaBlue = Color(0xFF0A58CA);
  static const Color deepSpaceBlue = Color(0xFF003882);
  static const Color hudAmber = Color(0xFFF59E0B);
  static const Color laserViolet = Color(0xFFA855F7);

  // Strict Tri-State Physiological Standard (NASA Bio-Safety Standard)
  static const Color nominalEmerald = Color(0xFF00E599);
  static const Color cautionAmber = Color(0xFFF59E0B);
  static const Color criticalCoral = Color(0xFFFF453A);

  // Monochromatic Hierarchy for Readability
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF475569);

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
