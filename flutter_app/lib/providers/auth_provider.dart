import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService api;
  AuthProvider({required this.api});

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _emailKey = 'auth_email';

  bool _initialized = false;
  bool _isAuthenticated = false;
  String? _userEmail;
  String? _errorMessage;

  bool get initialized => _initialized;
  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  String? get errorMessage => _errorMessage;

  // restore token and attach to ApiService so app can auto-auth on start
  Future<void> init() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      final email = await _storage.read(key: _emailKey);

      if (token != null && token.isNotEmpty) {
        _isAuthenticated = true;
        _userEmail = email;
        api.setAuthToken(token);
      } else {
        _isAuthenticated = false;
        _userEmail = null;
      }
    } catch (e) {
      _errorMessage = 'Failed to restore session: $e';
      _isAuthenticated = false;
      _userEmail = null;
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _errorMessage = null;
    try {
      final result = await api.login(email, password).timeout(const Duration(seconds: 12));
      final tokenValue = (result is Map) ? (result['access_token'] ?? result['token']) : null;
      if (tokenValue == null) {
        _errorMessage = 'Authentication token not returned by server';
        _isAuthenticated = false;
        notifyListeners();
        return false;
      }
      final token = tokenValue.toString();
      await _storage.write(key: _tokenKey, value: token);
      await _storage.write(key: _emailKey, value: email);
      api.setAuthToken(token);
      _isAuthenticated = true;
      _userEmail = email;
      notifyListeners();
      return true;
    } on TimeoutException {
      _errorMessage = 'Login timed out - backend not responding';
      _isAuthenticated = false;
      notifyListeners();
      return false;
    } on SocketException {
      _errorMessage = 'Cannot reach backend. Check network and API base URL.';
      _isAuthenticated = false;
      notifyListeners();
      return false;
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('401') || msg.contains('unauthorized') || msg.contains('invalid')) {
        _errorMessage = 'Invalid credentials';
      } else {
        _errorMessage = 'Login failed: $e';
      }
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(String email, String password, String name) async {
    _errorMessage = null;
    try {
      final resp = await api.signup(email, password, name: name).timeout(const Duration(seconds: 12));
      final tokenValue = (resp is Map) ? (resp['access_token'] ?? resp['token']) : null;
      if (tokenValue != null) {
        final token = tokenValue.toString();
        await _storage.write(key: _tokenKey, value: token);
        await _storage.write(key: _emailKey, value: email);
        api.setAuthToken(token);
      }
      _isAuthenticated = true;
      _userEmail = email;
      notifyListeners();
      return true;
    } on TimeoutException {
      _errorMessage = 'Signup timed out - backend not responding';
      _isAuthenticated = false;
      notifyListeners();
      return false;
    } on SocketException {
      _errorMessage = 'Cannot reach backend. Check network and API base URL.';
      _isAuthenticated = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Signup failed: $e';
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _emailKey);
    api.setAuthToken(null);
    _isAuthenticated = false;
    _userEmail = null;
    notifyListeners();
  }

  Future<String?> getAuthToken() async {
    return await _storage.read(key: _tokenKey);
  }
}