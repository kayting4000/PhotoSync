import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/subject.dart';

class SubjectProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  List<Subject> _subjects = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Subject> get subjects => _subjects;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchSubjects() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final data = await supabase.from('subjects').select();

      _subjects = (data as List<dynamic>)
          .map((item) => Subject.fromJson(item))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addSubject(Subject subject) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;
      await supabase.from('subjects').insert(subject.toJson(userId: userId));
      await fetchSubjects();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSubject(String id, Subject subject) async {
    try {
      await supabase
          .from('subjects')
          .update(subject.toJson())
          .eq('id', id);
      await fetchSubjects();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSubject(String id) async {
    try {
      await supabase.from('subjects').delete().eq('id', id);
      await fetchSubjects();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
