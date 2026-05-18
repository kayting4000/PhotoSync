import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final api = ApiService();
  String? _userId;
  String? _userEmail;
  String? _errorMessage;
  bool _isLoading = false;

  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _userId != null;

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

  Future<bool> signup(String email, String password) async {
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

  void logout() {
    api.clearAuth();
    _userId = null;
    _userEmail = null;
    notifyListeners();
  }
}