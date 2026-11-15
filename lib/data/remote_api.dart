// Online database: Supabase (accounts + PostgreSQL), through its REST APIs.
// Used only when the internet is available: sign-in before the mission, then backup.
 
import 'dart:async';
import 'dart:convert';
 
import 'package:http/http.dart' as http;
 
import '../config.dart';
 
/// [code] is a short machine code: NETWORK, NOT_CONFIGURED, INVALID_CREDENTIALS,
/// USER_ALREADY_EXISTS, WEAK_PASSWORD, EMAIL_NOT_CONFIRMED, PERMISSION_DENIED...
class RemoteException implements Exception {
  final String code;
 
  RemoteException(this.code);
 
  @override
  String toString() => 'RemoteException($code)';
}
 
class AuthResult {
  final String uid;
  final String accessToken;
  final String refreshToken;
  final DateTime expiry;
 
  AuthResult(this.uid, this.accessToken, this.refreshToken, this.expiry);
}
 
class RemoteApi {
  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 15);
 
  RemoteApi([http.Client? client]) : _client = client ?? http.Client();
 
  void _checkConfigured() {
    if (!isBackendConfigured) throw RemoteException('NOT_CONFIGURED');
  }
  /// Turns a Supabase error body into a short code.
  static String errorCode(String body, int status) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        final authCode = decoded['error_code'];
        if (authCode is String && authCode.isNotEmpty) return authCode.toUpperCase();
        final dbCode = '${decoded['code'] ?? ''}';
        if (dbCode == '42501') return 'PERMISSION_DENIED';
        if (dbCode == '42P01' || dbCode == 'PGRST205') return 'TABLE_MISSING';
        final text = '${decoded['msg'] ?? decoded['message'] ?? decoded['error'] ?? ''}'
            .toLowerCase();
        if (text.contains('invalid login')) return 'INVALID_CREDENTIALS';
        if (text.contains('already registered')) return 'USER_ALREADY_EXISTS';
        if (text.contains('not confirmed')) return 'EMAIL_NOT_CONFIRMED';
      }
    } catch (_) {}
    if (status == 401 || status == 403) return 'PERMISSION_DENIED';
    return 'HTTP_$status';
  }
 
  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(_timeout);
    } catch (_) {
      throw RemoteException('NETWORK');
    }
  }
 
  Map<String, String> _headers([String? accessToken]) => {
    'apikey': kSupabaseKey,
    'Content-Type': 'application/json',
    if (accessToken != null) 'Authorization': 'Bearer $accessToken',
  };
 
  // ---------------------------------------------------------------- accounts
 
  AuthResult _session(String body) {
    final j = jsonDecode(body) as Map<String, dynamic>;

    final token = j['access_token'];
    if (token is! String || token.isEmpty) {
      // The account exists but Supabase waits for an email confirmation.
      throw RemoteException('EMAIL_NOT_CONFIRMED');
    }
    final user = j['user'];
    final seconds = (j['expires_in'] as num?)?.toInt() ?? 3600;
    return AuthResult(
      user is Map ? '${user['id']}' : '',
      token,
      '${j['refresh_token'] ?? ''}',
      DateTime.now().add(Duration(seconds: seconds)),
    );
  }
 
  Future<AuthResult> _auth(String path, Map<String, dynamic> body) async {
    _checkConfigured();
    final response = await _send(
      () => _client.post(
        Uri.parse('$kSupabaseUrl/auth/v1/$path'),
        headers: _headers(),
        body: jsonEncode(body),
      ),
    );
    if (response.statusCode != 200) {
      throw RemoteException(errorCode(response.body, response.statusCode));
    }
    return _session(response.body);
  }
 
  Future<AuthResult> signIn(String email, String password) =>
      _auth('token?grant_type=password', {'email': email, 'password': password});
 
  Future<AuthResult> signUp(String email, String password) =>
      _auth('signup', {'email': email, 'password': password});
 
  /// Exchanges the long-lived refresh token for a fresh access token.
  Future<AuthResult> refresh(String refreshToken) =>
      _auth('token?grant_type=refresh_token', {'refresh_token': refreshToken});
 
  // ---------------------------------------------------------------- database
  /// Inserts the row, or replaces it when a row with the same "id" already exists.
  Future<void> upsert(String table, Map<String, dynamic> row, String accessToken) async {
    _checkConfigured();
    final headers = _headers(accessToken);
    headers['Prefer'] = 'resolution=merge-duplicates,return=minimal';
    final response = await _send(
      () => _client.post(
        Uri.parse('$kSupabaseUrl/rest/v1/$table?on_conflict=id'),
        headers: headers,
        body: jsonEncode(row),
      ),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw RemoteException(errorCode(response.body, response.statusCode));
    }
  }
 
  /// Rows of [table] where [column] equals [value]. The database security policies
  /// already restrict every query to the signed-in astronaut.
  Future<List<Map<String, dynamic>>> select(
    String table,
    String column,
    String value,
    String accessToken,
  ) async {
    _checkConfigured();
    final query = 'select=*&$column=eq.${Uri.encodeQueryComponent(value)}&limit=2000';
    final response = await _send(
      () => _client.get(
        Uri.parse('$kSupabaseUrl/rest/v1/$table?$query'),
        headers: _headers(accessToken),
      ),
    );
    if (response.statusCode != 200) {
      throw RemoteException(errorCode(response.body, response.statusCode));
    }
    final decoded = jsonDecode(response.body);
    return [
      if (decoded is List)
        for (final row in decoded)
          if (row is Map) Map<String, dynamic>.from(row),
    ];
  }

}
