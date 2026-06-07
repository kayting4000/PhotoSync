import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

/// JWT Token validator using native Dart libraries
bool _isTokenValid(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return false;
    
    String payload = parts[1];
    while (payload.length % 4 != 0) {
      payload += '=';
    }
    final decoded = utf8.decode(base64Url.decode(payload));
    final Map<String, dynamic> claims = jsonDecode(decoded);
    
    final exp = claims['exp'] as int?;
    if (exp != null) {
      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isBefore(expiry);
    }
    return false;
  } catch (e) {
    return false;
  }
}

class AuthProvider extends ChangeNotifier {
  final api = ApiService();
  String? _userId;
  String? _userEmail;
  String? _errorMessage;
  bool _isLoading = false;
  bool _initialized = false;

  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _userId != null;
  bool get initialized => _initialized;

  AuthProvider() {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userId = prefs.getString('auth_user_id');
    final email = prefs.getString('auth_email');
    
    if (token != null && userId != null && email != null) {
      // Validate token before restoring session
      if (_isTokenValid(token)) {
        api.setAuth(token, userId, email);
        _userId = userId;
        _userEmail = email;
      } else {
        // Token expired - clear stored auth data
        await prefs.remove('auth_token');
        await prefs.remove('auth_user_id');
        await prefs.remove('auth_email');
      }
    }
    _initialized = true;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final data = await api.login(email, password);
      final user = data['user'] as Map<String, dynamic>;
      final token = data['access_token'] as String;

      api.setAuth(token, user['id'], user['email']);
      _userId = user['id'];
      _userEmail = user['email'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('auth_user_id', user['id']);
      await prefs.setString('auth_email', user['email']);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(String email, String password, {String? name}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final data = await api.signup(email, password);
      final user = data['user'] as Map<String, dynamic>;
      final token = data['access_token'] as String;

      api.setAuth(token, user['id'], user['email']);
      _userId = user['id'];
      _userEmail = user['email'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('auth_user_id', user['id']);
      await prefs.setString('auth_email', user['email']);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    api.clearAuth();
    _userId = null;
    _userEmail = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user_id');
    await prefs.remove('auth_email');
    notifyListeners();
  }
}
