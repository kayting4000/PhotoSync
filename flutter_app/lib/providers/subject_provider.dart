import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../services/api_service.dart';

/// Provider for managing subjects with optimistic local updates.
/// After add/update/delete, the local list is updated immediately
/// rather than re-fetching the entire list from the server.
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

      final items = await api.get('/subjects/');
      _subjects = items
          .map((item) => Subject.fromJson(item as Map<String, dynamic>))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a subject optimistically — appends locally, then confirms with server.
  /// Falls back to a full re-fetch on error.
  Future<bool> addSubject(Subject subject) async {
    final optimisticSubject = Subject(
      id: '__new__', // temporary ID, replaced on success
      code: subject.code,
      name: subject.name,
      units: subject.units,
    );

    // Optimistic add
    _subjects.insert(0, optimisticSubject);
    notifyListeners();

    try {
      final result = await api.post('/subjects/', {
        'code': subject.code,
        'name': subject.name,
        'units': subject.units,
      });

      // Replace optimistic entry with real data from server
      final realSubject = Subject.fromJson(result);
      final index = _subjects.indexOf(optimisticSubject);
      if (index >= 0) {
        _subjects[index] = realSubject;
      } else {
        _subjects.insert(0, realSubject);
      }
      notifyListeners();
      return true;
    } catch (e) {
      // Rollback: remove the optimistic entry
      _subjects.remove(optimisticSubject);
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSubject(String id, Subject subject) async {
    // Find and preserve the current item for rollback
    final oldIndex = _subjects.indexWhere((s) => s.id == id);
    if (oldIndex < 0) return false;

    final oldSubject = _subjects[oldIndex];
    final updatedSubject = Subject(
      id: id,
      code: subject.code,
      name: subject.name,
      units: subject.units,
    );

    // Optimistic update
    _subjects[oldIndex] = updatedSubject;
    notifyListeners();

    try {
      final result = await api.put('/subjects/$id', {
        'code': subject.code,
        'name': subject.name,
        'units': subject.units,
      });

      // Replace with server response
      _subjects[oldIndex] = Subject.fromJson(result);
      notifyListeners();
      return true;
    } catch (e) {
      // Rollback
      _subjects[oldIndex] = oldSubject;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSubject(String id) async {
    final oldIndex = _subjects.indexWhere((s) => s.id == id);
    if (oldIndex < 0) return false;

    final removedItem = _subjects.removeAt(oldIndex);
    notifyListeners();

    try {
      await api.delete('/subjects/$id');
      return true;
    } catch (e) {
      // Rollback: re-insert at original position
      _subjects.insert(oldIndex, removedItem);
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}