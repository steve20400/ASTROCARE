// Visual identity: NASA blue, status colors, light and dark themes.
 
import 'package:flutter/material.dart';
 
import '../domain/models.dart';
 
const Color kNasaBlue = Color(0xFF0B3D91);
const Color kLightBlue = Color(0xFF64B5F6);
 
ThemeData buildTheme(bool dark) {
  return ThemeData(
    useMaterial3: true,
    brightness: dark ? Brightness.dark : Brightness.light,
    colorSchemeSeed: dark ? kLightBlue : kNasaBlue,
  );
}
 
bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;
 
/// Status color. Null level means "no data" and gives a neutral grey.
Color levelColor(BuildContext context, AlertLevel? level) {
  final dark = isDark(context);
  switch (level) {
    case AlertLevel.nominal:
      return dark ? const Color(0xFF81C784) : const Color(0xFF1E8E3E);
    case AlertLevel.attention:
      return dark ? const Color(0xFFFFD54F) : const Color(0xFFB26A00);
    case AlertLevel.critical:
      return dark ? const Color(0xFFE57373) : const Color(0xFFC62828);
    case null:
      return dark ? const Color(0xFFB0B0B0) : const Color(0xFF6B7280);
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
 
IconData zoneIcon(BodyZone zone) {
  switch (zone) {
    case BodyZone.head:
      return Icons.psychology;
    case BodyZone.heart:
      return Icons.favorite;
    case BodyZone.lungs:
      return Icons.air;
    case BodyZone.abdomen:
      return Icons.restaurant;
    case BodyZone.core:
      return Icons.thermostat;
    case BodyZone.legs:
      return Icons.accessibility_new;
  }
}
 
String hazardLetter(Hazard h) {
  switch (h) {
    case Hazard.radiation:
      return 'R';
    case Hazard.isolation:
      return 'I';
    case Hazard.distance:
      return 'D';
    case Hazard.gravity:
      return 'G';
    case Hazard.environment:

      return 'E';
  }
}
