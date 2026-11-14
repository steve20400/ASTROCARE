// Online database: Firebase Authentication and Cloud Firestore, through their REST APIs.
// Used only when the internet is available: sign-in before the mission, then backup.
 
import 'dart:async';
import 'dart:convert';
 
import 'package:http/http.dart' as http;
 
import '../config.dart';
 
/// [code] is a short machine code: NETWORK, NOT_CONFIGURED, EMAIL_EXISTS,
/// INVALID_LOGIN_CREDENTIALS, WEAK_PASSWORD, INVALID_EMAIL, PERMISSION_DENIED...
class RemoteException implements Exception {
  final String code;
 
  RemoteException(this.code);
 
  @override
  String toString() => 'RemoteException($code)';
}
 
class AuthResult {
  final String uid;
  final String idToken;
  final String refreshToken;
  final DateTime expiry;
 
  AuthResult(this.uid, this.idToken, this.refreshToken, this.expiry);
}
 
class RemoteApi {
  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 12);
 
  RemoteApi([http.Client? client]) : _client = client ?? http.Client();
 
  String get _docs =>
      'https://firestore.googleapis.com/v1/projects/$kFirebaseProjectId'
      '/databases/(default)/documents';
  void _checkConfigured() {
    if (!isFirebaseConfigured) throw RemoteException('NOT_CONFIGURED');
  }
 
  String _errorCode(String body, int status) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['error'] is Map) {
        final error = decoded['error'] as Map;
        final message = '${error['message'] ?? error['status'] ?? ''}'.trim();
        if (message.isNotEmpty) {
          final first = message.split(RegExp(r'[ :]')).first;
          if (RegExp(r'^[A-Z_]+$').hasMatch(first)) return first;
        }
        final status = '${error['status'] ?? ''}';
        if (status.isNotEmpty) return status;
      }
    } catch (_) {}
    return 'HTTP_$status';
  }
 
  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(_timeout);
    } on RemoteException {
      rethrow;
    } catch (_) {
      throw RemoteException('NETWORK');
    }
  }
 
  // ---------------------------------------------------------------- sign-in
 
  Future<AuthResult> _auth(String method, String email, String password) async {
    _checkConfigured();
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:$method?key=$kFirebaseApiKey',
    );
    final response = await _send(

      () => _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'returnSecureToken': true}),
      ),
    );
    if (response.statusCode != 200) {
      throw RemoteException(_errorCode(response.body, response.statusCode));
    }
    final j = jsonDecode(response.body) as Map<String, dynamic>;
    final seconds = int.tryParse('${j['expiresIn']}') ?? 3600;
    return AuthResult(
      '${j['localId']}',
      '${j['idToken']}',
      '${j['refreshToken']}',
      DateTime.now().add(Duration(seconds: seconds)),
    );
  }
 
  Future<AuthResult> signIn(String email, String password) =>
      _auth('signInWithPassword', email, password);
 
  Future<AuthResult> signUp(String email, String password) => _auth('signUp', email, password);
 
  /// Exchanges the long-lived refresh token for a fresh one-hour id token.
  Future<AuthResult> refresh(String refreshToken) async {
    _checkConfigured();
    final url = Uri.parse('https://securetoken.googleapis.com/v1/token?key=$kFirebaseApiKey');
    final response = await _send(
      () => _client.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body:
            'grant_type=refresh_token&refresh_token=${Uri.encodeQueryComponent(refreshToken)}',
      ),
    );
    if (response.statusCode != 200) {
      throw RemoteException(_errorCode(response.body, response.statusCode));
    }
    final j = jsonDecode(response.body) as Map<String, dynamic>;
    final seconds = int.tryParse('${j['expires_in']}') ?? 3600;
    return AuthResult(
      '${j['user_id']}',
      '${j['id_token']}',
      '${j['refresh_token']}',
      DateTime.now().add(Duration(seconds: seconds)),
    );
  }
 
  // -------------------------------------------------------------- Firestore
 
  static Map<String, dynamic> encodeFields(Map<String, dynamic> data) {
    final fields = <String, dynamic>{};
    data.forEach((key, value) {
      if (value is String) {
        fields[key] = {'stringValue': value};
      } else if (value is bool) {
        fields[key] = {'booleanValue': value};
      } else if (value is int) {
        fields[key] = {'integerValue': '$value'};
      } else if (value is num) {
        fields[key] = {'doubleValue': value};
      } else if (value is DateTime) {
        fields[key] = {'timestampValue': value.toUtc().toIso8601String()};
      } else if (value != null) {
        fields[key] = {'stringValue': '$value'};
      }
    });
    return fields;
  }
 
  static Map<String, dynamic> decodeFields(Object? fields) {
    final data = <String, dynamic>{};
    if (fields is! Map) return data;
    fields.forEach((key, wrapped) {
      if (wrapped is! Map) return;
      if (wrapped.containsKey('stringValue')) {
        data['$key'] = '${wrapped['stringValue']}';
      } else if (wrapped.containsKey('booleanValue')) {
        data['$key'] = wrapped['booleanValue'] == true;
      } else if (wrapped.containsKey('integerValue')) {
        data['$key'] = int.tryParse('${wrapped['integerValue']}') ?? 0;
      } else if (wrapped.containsKey('doubleValue')) {
        data['$key'] = (wrapped['doubleValue'] as num?)?.toDouble() ?? 0.0;

      } else if (wrapped.containsKey('timestampValue')) {
        final parsed = DateTime.tryParse('${wrapped['timestampValue']}');
        data['$key'] = (parsed ?? DateTime.now()).toLocal();
      }
    });
    return data;
  }
 
  Map<String, String> _headers(String idToken) => {
    'Authorization': 'Bearer $idToken',
    'Content-Type': 'application/json',
  };
 
  /// Creates or replaces the document at [path], for example "users/abc/measurements/m1".
  Future<void> setDocument(String path, Map<String, dynamic> data, String idToken) async {
    _checkConfigured();
    final response = await _send(
      () => _client.patch(
        Uri.parse('$_docs/$path'),
        headers: _headers(idToken),
        body: jsonEncode({'fields': encodeFields(data)}),
      ),
    );
    if (response.statusCode != 200) {
      throw RemoteException(_errorCode(response.body, response.statusCode));
    }
  }
 
  /// Returns the document fields, or null when the document does not exist.
  Future<Map<String, dynamic>?> getDocument(String path, String idToken) async {
    _checkConfigured();
    final response = await _send(
      () => _client.get(Uri.parse('$_docs/$path'), headers: _headers(idToken)),
    );
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw RemoteException(_errorCode(response.body, response.statusCode));
    }
    final j = jsonDecode(response.body) as Map<String, dynamic>;
    return decodeFields(j['fields']);
  }
 
  /// Lists a collection. Each returned map also holds the document id under "id".
  Future<List<Map<String, dynamic>>> listDocuments(String path, String idToken) async {
    _checkConfigured();
    final result = <Map<String, dynamic>>[];
    String? pageToken;
    for (var page = 0; page < 10; page++) {
      final query = pageToken == null
          ? 'pageSize=300'
          : 'pageSize=300&pageToken=${Uri.encodeQueryComponent(pageToken)}';
      final response = await _send(
        () => _client.get(Uri.parse('$_docs/$path?$query'), headers: _headers(idToken)),
      );
      if (response.statusCode != 200) {
        throw RemoteException(_errorCode(response.body, response.statusCode));
      }
      final j = jsonDecode(response.body) as Map<String, dynamic>;
      for (final doc in (j['documents'] as List? ?? const [])) {
        if (doc is! Map) continue;
        final data = decodeFields(doc['fields']);
        data['id'] = '${doc['name']}'.split('/').last;
        result.add(data);
      }
      final next = j['nextPageToken'];
      if (next == null || '$next'.isEmpty) break;
      pageToken = '$next';
    }
    return result;
  }
}
