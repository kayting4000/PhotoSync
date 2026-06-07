import 'package:flutter/material.dart';
import '../models/exam.dart';
import '../services/api_service.dart';

class ExamProvider extends ChangeNotifier {
  final api = ApiService();
  List<Exam> _exams = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Exam> get exams => _exams;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchExams({String? subjectId}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      var path = '/exams/';
      if (subjectId != null) path = '/exams/?subject_id=$subjectId';
      final data = await api.get(path);

      _exams = data.map((item) => Exam.fromJson(item as Map<String, dynamic>)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addExam(Exam exam) async {
    try {
      await api.post('/exams/', exam.toJson());
      await fetchExams();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateExam(String id, Exam exam) async {
    try {
      await api.put('/exams/$id', exam.toJson());
      await fetchExams();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteExam(String id) async {
    try {
      await api.delete('/exams/$id');
      await fetchExams();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}