import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

/// The signed-in admin's session, as returned by POST /api/auth/login.
class AuthSession {
  final String token;
  final String tokenType;
  final String name;
  final String email;
  final String role;

  const AuthSession({
    required this.token,
    required this.tokenType,
    required this.name,
    required this.email,
    required this.role,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: json['token'] as String,
      tokenType: json['tokenType'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'tokenType': tokenType,
        'name': name,
        'email': email,
        'role': role,
      };
}

/// Result of a login attempt, mirroring the API's { success, message } shape.
class AuthResult {
  final bool success;
  final String message;
  final AuthSession? session;

  const AuthResult({required this.success, required this.message, this.session});
}

/// Handles login, session persistence, and logout for the admin app.
///
/// Session is cached in memory after the first read/write and persisted to
/// SharedPreferences so the user stays signed in across app restarts.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _kSessionKey = 'auth_session';

  AuthSession? _cachedSession;

  Future<AuthResult> login({required String email, required String password}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: ApiConfig.jsonHeaders,
        body: jsonEncode({'email': email, 'password': password}),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final success = body['success'] as bool? ?? false;
      final message = body['message'] as String? ?? 'Something went wrong';

      if (response.statusCode < 200 || response.statusCode >= 300 || !success) {
        return AuthResult(success: false, message: message);
      }

      final data = body['data'] as Map<String, dynamic>?;
      if (data == null) {
        return const AuthResult(success: false, message: 'Malformed response from server');
      }

      final session = AuthSession.fromJson(data);
      await _saveSession(session);

      return AuthResult(success: true, message: message, session: session);
    } catch (e) {
      return AuthResult(success: false, message: 'Could not reach server: $e');
    }
  }

  Future<void> _saveSession(AuthSession session) async {
    _cachedSession = session;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSessionKey, jsonEncode(session.toJson()));
  }

  /// Returns the current session, reading from disk on first call.
  Future<AuthSession?> getSession() async {
    if (_cachedSession != null) return _cachedSession;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSessionKey);
    if (raw == null) return null;

    _cachedSession = AuthSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    return _cachedSession;
  }

  Future<bool> isLoggedIn() async => (await getSession()) != null;

  Future<void> logout() async {
    _cachedSession = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSessionKey);
  }
}