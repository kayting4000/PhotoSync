import 'package:flutter/material.dart';
import '../models/academic_term.dart';
import '../services/api_service.dart';

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
    try {
      await api.post('/academic-terms/', {
        'name': term.name,
        'term_type': term.termType,
        'percentage_weight': term.percentageWeight,
        'start_date': term.startDate.toIso8601String().split('T')[0],
        'end_date': term.endDate.toIso8601String().split('T')[0],
        'is_current': term.isCurrent,
      });
      await fetchTerms();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTerm(String id, AcademicTerm term) async {
    try {
      final body = <String, dynamic>{
        'name': term.name,
        'term_type': term.termType,
        'percentage_weight': term.percentageWeight,
        'start_date': term.startDate.toIso8601String().split('T')[0],
        'end_date': term.endDate.toIso8601String().split('T')[0],
        'is_current': term.isCurrent,
      };
      await api.put('/academic-terms/$id', body);
      await fetchTerms();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTerm(String id) async {
    try {
      await api.delete('/academic-terms/$id');
      await fetchTerms();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}