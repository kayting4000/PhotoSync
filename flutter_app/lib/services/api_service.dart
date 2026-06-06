import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config.dart';

class ApiService {
  final String baseUrl;
  String? _authToken;

  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? Config.apiBase;

  void setAuthToken(String? token) => _authToken = token;

  Map<String, String> _headers([Map<String, String>? extras]) {
    final h = <String, String>{
      'Content-Type': 'application/json',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };
    if (extras != null) h.addAll(extras);
    return h;
  }

  Future<dynamic> _decodeResponse(http.Response resp) async {
    if (resp.body.isEmpty) return null;
    try {
      return jsonDecode(resp.body);
    } catch (_) {
      return resp.body;
    }
  }

  Future<dynamic> _safeRequest(Future<http.Response> Function() fn) async {
    try {
      final resp = await fn().timeout(const Duration(seconds: 15));
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return await _decodeResponse(resp);
      } else {
        final body = await _decodeResponse(resp);
        throw Exception('API error ${resp.statusCode}: ${body ?? resp.reasonPhrase}');
      }
    } on TimeoutException {
      throw TimeoutException('Request timed out (backend not responding)');
    } on SocketException {
      throw const SocketException('Network unreachable');
    }
  }

  Future<dynamic> get(String path) async {
    final url = Uri.parse('$baseUrl$path');
    return await _safeRequest(() => http.get(url, headers: _headers()));
  }

  Future<Map<String, dynamic>> getMap(String path) async {
    final res = await get(path);
    if (res == null) throw Exception('Empty response from $path');
    if (res is Map<String, dynamic>) return res;
    if (res is Map) return Map<String, dynamic>.from(res);
    throw Exception('Expected Map response from $path but got ${res.runtimeType}');
  }

  Future<dynamic> post(String path, dynamic body) async {
    final url = Uri.parse('$baseUrl$path');
    return await _safeRequest(() => http.post(url, headers: _headers(), body: jsonEncode(body)));
  }

  Future<dynamic> put(String path, dynamic body) async {
    final url = Uri.parse('$baseUrl$path');
    return await _safeRequest(() => http.put(url, headers: _headers(), body: jsonEncode(body)));
  }

  Future<void> delete(String path) async {
    final url = Uri.parse('$baseUrl$path');
    await _safeRequest(() => http.delete(url, headers: _headers()));
  }

  Future<dynamic> login(String email, String password) async {
    return await post('/auth/login', {'email': email, 'password': password});
  }

  Future<dynamic> signup(String email, String password, {String? name}) async {
    return await post('/auth/signup', {'email': email, 'password': password, 'name': name});
  }
}