// Local database: everything the app needs in space is stored on the device.
// One entry for the device preferences and session, one entry per astronaut account.
 
import 'dart:convert';
 
import 'package:shared_preferences/shared_preferences.dart';
 
class LocalStore {
  static const String _deviceKey = 'astrocare_device_v2';
  static const String _userPrefix = 'astrocare_user_v2_';
 
  Future<Map<String, dynamic>?> _read(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }
 
  Future<void> _write(String key, Map<String, dynamic> value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(value));
    } catch (_) {
      // A storage failure must never crash the app; the state stays in memory.
    }
  }
 
  /// Language, theme and the signed-in session.
  Future<Map<String, dynamic>?> readDevice() => _read(_deviceKey);
 
  Future<void> writeDevice(Map<String, dynamic> value) => _write(_deviceKey, value);
 
  /// Measurements, alerts and mission settings of one astronaut.
  Future<Map<String, dynamic>?> readUser(String uid) => _read('$_userPrefix$uid');
  Future<void> writeUser(String uid, Map<String, dynamic> value) =>
      _write('$_userPrefix$uid', value);
}
