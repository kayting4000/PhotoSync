import 'package:flutter/material.dart';
import '../models/academic_term.dart';
import '../services/api_service.dart';

/// Provider for managing academic terms with optimistic local updates.
class AcademicTermProvider extends ChangeNotifier {
  final api = ApiService();
  List<AcademicTerm> _terms = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AcademicTerm> get terms => _terms;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AcademicTerm? get currentTerm {
    try {
      return _terms.firstWhere((t) => t.isCurrent);
    } catch (_) {
      return null;
    }
  }

  Future<void> fetchTerms() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final data = await api.get('/academic-terms/');
      _terms = data.map((item) => AcademicTerm.fromJson(item)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTerm(AcademicTerm term) async {
    final optimisticTerm = AcademicTerm(
      id: '__new__',
      name: term.name,
      termType: term.termType,
      percentageWeight: term.percentageWeight,
      startDate: term.startDate,
      endDate: term.endDate,
      isCurrent: term.isCurrent,
    );

    _terms.insert(0, optimisticTerm);
    notifyListeners();

    try {
      final result = await api.post('/academic-terms/', {
        'name': term.name,
        'term_type': term.termType,
        'percentage_weight': term.percentageWeight,
        'start_date': term.startDate.toIso8601String().split('T')[0],
        'end_date': term.endDate.toIso8601String().split('T')[0],
        'is_current': term.isCurrent,
      });

      final realTerm = AcademicTerm.fromJson(result);
      final index = _terms.indexOf(optimisticTerm);
      if (index >= 0) {
        _terms[index] = realTerm;
      } else {
        _terms.insert(0, realTerm);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _terms.remove(optimisticTerm);
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTerm(String id, AcademicTerm term) async {
    final oldIndex = _terms.indexWhere((t) => t.id == id);
    if (oldIndex < 0) return false;

    final oldTerm = _terms[oldIndex];
    final updatedTerm = AcademicTerm(
      id: id,
      name: term.name,
      termType: term.termType,
      percentageWeight: term.percentageWeight,
      startDate: term.startDate,
      endDate: term.endDate,
      isCurrent: term.isCurrent,
    );

    _terms[oldIndex] = updatedTerm;
    notifyListeners();

    try {
      final result = await api.put('/academic-terms/$id', {
        'name': term.name,
        'term_type': term.termType,
        'percentage_weight': term.percentageWeight,
        'start_date': term.startDate.toIso8601String().split('T')[0],
        'end_date': term.endDate.toIso8601String().split('T')[0],
        'is_current': term.isCurrent,
      });

      _terms[oldIndex] = AcademicTerm.fromJson(result);
      notifyListeners();
      return true;
    } catch (e) {
      _terms[oldIndex] = oldTerm;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTerm(String id) async {
    final oldIndex = _terms.indexWhere((t) => t.id == id);
    if (oldIndex < 0) return false;

    final removedItem = _terms.removeAt(oldIndex);
    notifyListeners();

    try {
      await api.delete('/academic-terms/$id');
      return true;
    } catch (e) {
      _terms.insert(oldIndex, removedItem);
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}