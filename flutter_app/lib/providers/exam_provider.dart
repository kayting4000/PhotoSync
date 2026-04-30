import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exam.dart';

class ExamProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;
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

      var query = supabase.from('exams').select();
      if (subjectId != null) {
        query = query.eq('subject_id', subjectId);
      }

      final data = await query;

      _exams = (data as List<dynamic>)
          .map((item) => Exam.fromJson(item))
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
    try {
      await supabase.from('exams').insert(exam.toJson());
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
      await supabase
          .from('exams')
          .update(exam.toJson())
          .eq('id', id);
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
      await supabase.from('exams').delete().eq('id', id);
      await fetchExams();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
