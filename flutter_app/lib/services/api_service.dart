import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Singleton API service that handles all backend HTTP calls
/// with JWT Bearer auth headers.
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// RAILWAY DEPLOYMENT: After deploying to Railway, replace the URL below
  /// with your Railway app URL (e.g., https://photosync-api.up.railway.app)
  /// Local dev: use http://192.168.1.76:8000 or http://10.0.2.2:8000 for emulator
  static const String _baseUrl = 'https://YOUR_APP.up.railway.app';

  String? _jwtToken;
  String? _userId;
  String? _userEmail;

  bool get isAuthenticated => _jwtToken != null;
  String? get userId => _userId;
  String? get userEmail => _userEmail;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_jwtToken != null) 'Authorization': 'Bearer $_jwtToken',
      };

  /// Store auth data after login/signup.
  void setAuth(String token, String id, String email) {
    _jwtToken = token;
    _userId = id;
    _userEmail = email;
  }

  void clearAuth() {
    _jwtToken = null;
    _userId = null;
    _userEmail = null;
  }

  // ─── Auth ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      final body = jsonDecode(res.body);
      throw Exception(body['detail'] ?? 'Login failed');
    } on SocketException {
      throw Exception(
          'Cannot connect to backend. Make sure the server is running.');
    } on TimeoutException {
      throw Exception(
          'Connection timed out. The backend server is not responding.');
    } on http.ClientException {
      throw Exception(
          'Cannot connect to server. Check your internet connection.');
    }
  }

  Future<Map<String, dynamic>> signup(String email, String password) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_baseUrl/auth/signup'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      final body = jsonDecode(res.body);
      throw Exception(body['detail'] ?? 'Signup failed');
    } on SocketException {
      throw Exception(
          'Cannot connect to backend. Make sure the server is running.');
    } on TimeoutException {
      throw Exception(
          'Connection timed out. The backend server is not responding.');
    } on http.ClientException {
      throw Exception(
          'Cannot connect to server. Check your internet connection.');
    }
  }

  /// GET that returns a single Map (for endpoints that return objects, not arrays).
  Future<Map<String, dynamic>> getMap(String path) async {
    final res = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('GET $path failed: ${res.statusCode} ${res.body}');
  }

  // ─── Generic CRUD helpers ────────────────────────────────────────────────

  Future<List<dynamic>> get(String path) async {
    final res = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data is List) return data;
      if (data is Map) return [data];
      return [];
    }
    throw Exception('GET $path failed: ${res.statusCode} ${res.body}');
  }

  Future<Map<String, dynamic>> post(
      String path, Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    final data = jsonDecode(res.body);
    throw Exception(data['detail'] ?? 'POST $path failed');
  }

  Future<Map<String, dynamic>> put(
      String path, Map<String, dynamic> body) async {
    final res = await http.put(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    final data = jsonDecode(res.body);
    throw Exception(data['detail'] ?? 'PUT $path failed');
  }

  Future<void> delete(String path) async {
    final res = await http.delete(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      final data = jsonDecode(res.body);
      throw Exception(data['detail'] ?? 'DELETE $path failed');
    }
  }

  // ─── Scan Upload (multipart) ────────────────────────────────────────────

  /// Upload a scanned test paper image, associate with a student + exam.
  Future<Map<String, dynamic>> uploadScan({
    required String studentId,
    required String examId,
    required File imageFile,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/scan-uploads/upload'),
    );
    request.headers['Authorization'] = 'Bearer $_jwtToken';
    request.fields['student_id'] = studentId;
    request.fields['exam_id'] = examId;
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    final data = jsonDecode(res.body);
    throw Exception(data['detail'] ?? 'Upload failed');
  }

  /// Check if a student has a scanned test paper for an exam.
  Future<Map<String, dynamic>> getScannedResult(
    String studentId,
    String examId,
  ) async {
    return getMap('/scan-uploads/results/$studentId/$examId');
  }

  // ─── Email with attachments ─────────────────────────────────────────────

  /// Send a grade report to a single student, optionally with scanned image.
  Future<Map<String, dynamic>> sendGradeReport({
    required String studentId,
    required String examName,
    required String subjectCode,
    required String subjectName,
    required double percentage,
    required String grade,
    required double gradePoint,
    required String remarks,
    String? customMessage,
    bool includeScan = false,
  }) async {
    return post('/email/send-grade-report', {
      'student_id': studentId,
      'exam_name': examName,
      'subject_code': subjectCode,
      'subject_name': subjectName,
      'percentage': percentage,
      'grade': grade,
      'grade_point': gradePoint,
      'remarks': remarks,
      'custom_message': customMessage,
      'include_scan': includeScan,
    });
  }
}