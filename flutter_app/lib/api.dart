import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class ApiService {
  static const String baseUrl = Config.apiBase;

  // -------------------------
  // AUTH
  // -------------------------
  Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    }

    throw Exception('Login failed: ${res.body}');
  }

  Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    }

    throw Exception('Signup failed: ${res.body}');
  }

  // -------------------------
  // DASHBOARD / DATA
  // -------------------------
  Future<Map<String, dynamic>> getMap() async {
    final res = await http.get(
      Uri.parse('$baseUrl/map'),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    }

    throw Exception('Get map failed: ${res.body}');
  }

  // -------------------------
  // SUBJECTS
  // -------------------------
  Future<Map<String, dynamic>> createSubject(String name) async {
    final res = await http.post(
      Uri.parse('$baseUrl/subjects'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    }

    throw Exception('Create subject failed: ${res.body}');
  }

  Future<Map<String, dynamic>> createSection(
    int subjectId,
    String name,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/subjects/$subjectId/sections'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    }

    throw Exception('Create section failed: ${res.body}');
  }

  Future<Map<String, dynamic>> createStudent(
    int sectionId,
    String name,
    String email,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/sections/$sectionId/students'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
      }),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    }

    throw Exception('Create student failed: ${res.body}');
  }
}