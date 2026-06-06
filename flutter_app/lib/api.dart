import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

Future<Map<String, dynamic>> createSubject(String name) async {
  final res = await http.post(
    Uri.parse('$apiBase/subjects/'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'name': name}),
  );
  if (res.statusCode >= 200 && res.statusCode < 300) {
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
  throw Exception('Create subject failed: ${res.statusCode} ${res.body}');
}

Future<Map<String, dynamic>> createSection(int subjectId, String name) async {
  final res = await http.post(
    Uri.parse('$apiBase/subjects/$subjectId/sections'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'name': name}),
  );
  if (res.statusCode >= 200 && res.statusCode < 300) {
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
  throw Exception('Create section failed: ${res.statusCode} ${res.body}');
}

Future<Map<String, dynamic>> createStudent(int sectionId, String name, String email) async {
  final res = await http.post(
    Uri.parse('$apiBase/sections/$sectionId/students'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'name': name, 'email': email}),
  );
  if (res.statusCode >= 200 && res.statusCode < 300) {
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
  throw Exception('Create student failed: ${res.statusCode} ${res.body}');
}
