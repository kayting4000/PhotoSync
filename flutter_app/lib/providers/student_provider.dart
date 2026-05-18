import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/api_service.dart';

class StudentProvider extends ChangeNotifier {
  final api = ApiService();
  List<Student> _students = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchStudents() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final data = await api.get('/students/');
      _students = data.map((item) => Student.fromJson(item)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addStudent(Student student) async {
    try {
      await api.post('/students/', {
        'student_id': student.studentId,
        'first_name': student.firstName,
        'last_name': student.lastName,
        'email': student.email,
        'course': student.course,
        'year_level': student.yearLevel,
      });
      await fetchStudents();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStudent(String id, Student student) async {
    try {
      final body = <String, dynamic>{
        'student_id': student.studentId,
        'first_name': student.firstName,
        'last_name': student.lastName,
        'email': student.email,
        'course': student.course,
        'year_level': student.yearLevel,
      };
      await api.put('/students/$id', body);
      await fetchStudents();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteStudent(String id) async {
    try {
      await api.delete('/students/$id');
      await fetchStudents();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}