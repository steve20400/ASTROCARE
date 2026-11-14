// Local persistence. Everything stays on the device: no server, no remote database.
 
import 'dart:convert';
 
import 'package:shared_preferences/shared_preferences.dart';
 
class LocalStore {
  static const String _key = 'astrocare_state_v1';
 
  Future<Map<String, dynamic>?> read() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }
 
  Future<void> write(Map<String, dynamic> state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(state));
    } catch (_) {
      // Storage failure must never crash the app; the state stays in memory.
    }
  }
 
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {}
  }
}
