import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student.dart';

class StudentProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;
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

      final data = await supabase.from('students').select();

      _students = (data as List<dynamic>)
          .map((item) => Student.fromJson(item))
          .toList();

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
      await supabase.from('students').insert(student.toJson());
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
      await supabase
          .from('students')
          .update(student.toJson())
          .eq('id', id);
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
      await supabase.from('students').delete().eq('id', id);
      await fetchStudents();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
