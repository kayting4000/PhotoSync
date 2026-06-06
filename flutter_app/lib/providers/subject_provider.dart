import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../services/api_service.dart';

class SubjectProvider extends ChangeNotifier {
  final api = ApiService();
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

      final data = await api.get('/subjects/');
      List items;
      if (data is List) {
        items = data;
      } else if (data is Map && data['items'] is List) {
        items = data['items'] as List;
      } else {
        items = [];
      }
      _subjects = items.map((item) => Subject.fromJson(item as Map<String, dynamic>)).toList();

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
      await api.post('/subjects/', {
        'code': subject.code,
        'name': subject.name,
        'units': subject.units,
      });
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
      await api.put('/subjects/$id', {
        'code': subject.code,
        'name': subject.name,
        'units': subject.units,
      });
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
      await api.delete('/subjects/$id');
      await fetchSubjects();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}