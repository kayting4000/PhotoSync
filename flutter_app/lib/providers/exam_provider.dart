import 'package:flutter/material.dart';
import '../models/exam.dart';
import '../services/api_service.dart';

/// Provider for managing exams with optimistic local updates.
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

      _exams = data
          .map((item) => Exam.fromJson(item as Map<String, dynamic>))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addExam(Exam exam) async {
    final optimisticExam = Exam(
      id: '__new__',
      subjectId: exam.subjectId,
      name: exam.name,
      componentType: exam.componentType,
      totalItems: exam.totalItems,
      pointsPerItem: exam.pointsPerItem,
      passingScore: exam.passingScore,
      termId: exam.termId,
    );

    _exams.insert(0, optimisticExam);
    notifyListeners();

    try {
      final result = await api.post('/exams/', exam.toJson());
      final realExam = Exam.fromJson(result);
      final index = _exams.indexOf(optimisticExam);
      if (index >= 0) {
        _exams[index] = realExam;
      } else {
        _exams.insert(0, realExam);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _exams.remove(optimisticExam);
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateExam(String id, Exam exam) async {
    final oldIndex = _exams.indexWhere((e) => e.id == id);
    if (oldIndex < 0) return false;

    final oldExam = _exams[oldIndex];
    final updatedExam = Exam(
      id: id,
      subjectId: exam.subjectId,
      name: exam.name,
      componentType: exam.componentType,
      totalItems: exam.totalItems,
      pointsPerItem: exam.pointsPerItem,
      passingScore: exam.passingScore,
      termId: exam.termId,
    );

    _exams[oldIndex] = updatedExam;
    notifyListeners();

    try {
      final result = await api.put('/exams/$id', exam.toJson());
      _exams[oldIndex] = Exam.fromJson(result);
      notifyListeners();
      return true;
    } catch (e) {
      _exams[oldIndex] = oldExam;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteExam(String id) async {
    final oldIndex = _exams.indexWhere((e) => e.id == id);
    if (oldIndex < 0) return false;

    final removedItem = _exams.removeAt(oldIndex);
    notifyListeners();

    try {
      await api.delete('/exams/$id');
      return true;
    } catch (e) {
      _exams.insert(oldIndex, removedItem);
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}