import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/api_service.dart';

/// Provider for managing students with optimistic local updates.
class StudentProvider extends ChangeNotifier {
  final api = ApiService();
  List<Student> _students = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchStudents({String? sectionId}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      var endpoint = '/students/';
      if (sectionId != null) {
        endpoint += '?section_id=$sectionId';
      }
      final data = await api.get(endpoint);
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
    final optimisticStudent = Student(
      id: '__new__',
      studentId: student.studentId,
      firstName: student.firstName,
      lastName: student.lastName,
      email: student.email,
      course: student.course,
      yearLevel: student.yearLevel,
      sectionId: student.sectionId,
    );

    _students.insert(0, optimisticStudent);
    notifyListeners();

    try {
      final result = await api.post('/students/', {
        'student_id': student.studentId,
        'first_name': student.firstName,
        'last_name': student.lastName,
        'email': student.email,
        'course': student.course,
        'year_level': student.yearLevel,
        if (student.sectionId != null) 'section_id': student.sectionId,
      });

      final realStudent = Student.fromJson(result);
      final index = _students.indexOf(optimisticStudent);
      if (index >= 0) {
        _students[index] = realStudent;
      } else {
        _students.insert(0, realStudent);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _students.remove(optimisticStudent);
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStudent(String id, Student student) async {
    final oldIndex = _students.indexWhere((s) => s.id == id);
    if (oldIndex < 0) return false;

    final oldStudent = _students[oldIndex];
    final updatedStudent = Student(
      id: id,
      studentId: student.studentId,
      firstName: student.firstName,
      lastName: student.lastName,
      email: student.email,
      course: student.course,
      yearLevel: student.yearLevel,
      sectionId: student.sectionId,
    );

    _students[oldIndex] = updatedStudent;
    notifyListeners();

    try {
      final result = await api.put('/students/$id', {
        'student_id': student.studentId,
        'first_name': student.firstName,
        'last_name': student.lastName,
        'email': student.email,
        'course': student.course,
        'year_level': student.yearLevel,
        if (student.sectionId != null) 'section_id': student.sectionId,
      });

      _students[oldIndex] = Student.fromJson(result);
      notifyListeners();
      return true;
    } catch (e) {
      _students[oldIndex] = oldStudent;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteStudent(String id) async {
    final oldIndex = _students.indexWhere((s) => s.id == id);
    if (oldIndex < 0) return false;

    final removedItem = _students.removeAt(oldIndex);
    notifyListeners();

    try {
      await api.delete('/students/$id');
      return true;
    } catch (e) {
      _students.insert(oldIndex, removedItem);
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}