import 'package:flutter/material.dart';
import '../models/section.dart';
import '../services/api_service.dart';

/// Provider for managing sections with optimistic local updates.
class SectionProvider extends ChangeNotifier {
  final api = ApiService();
  List<Section> _sections = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Section> get sections => _sections;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchSections() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final items = await api.get('/sections/');

      _sections = items
          .map((item) => Section.fromJson(item as Map<String, dynamic>))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a section optimistically, confirming with server.
  Future<bool> addSection(Section section) async {
    final optimisticSection = Section(
      id: '__new__',
      subjectId: section.subjectId,
      sectionLabel: section.sectionLabel,
      roomNumber: section.roomNumber,
    );

    _sections.insert(0, optimisticSection);
    notifyListeners();

    try {
      final result = await api.post('/sections/', {
        'subject_id': section.subjectId,
        'section_label': section.sectionLabel,
        'room_number': section.roomNumber,
      });

      final realSection = Section.fromJson(result);
      final index = _sections.indexOf(optimisticSection);
      if (index >= 0) {
        _sections[index] = realSection;
      } else {
        _sections.insert(0, realSection);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _sections.remove(optimisticSection);
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSection(String id, Section section) async {
    final oldIndex = _sections.indexWhere((s) => s.id == id);
    if (oldIndex < 0) return false;

    final oldSection = _sections[oldIndex];
    final updatedSection = Section(
      id: id,
      subjectId: section.subjectId,
      sectionLabel: section.sectionLabel,
      roomNumber: section.roomNumber,
    );

    _sections[oldIndex] = updatedSection;
    notifyListeners();

    try {
      final result = await api.put('/sections/$id', {
        'section_label': section.sectionLabel,
        'room_number': section.roomNumber,
      });

      _sections[oldIndex] = Section.fromJson(result);
      notifyListeners();
      return true;
    } catch (e) {
      _sections[oldIndex] = oldSection;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSection(String id) async {
    final oldIndex = _sections.indexWhere((s) => s.id == id);
    if (oldIndex < 0) return false;

    final removedItem = _sections.removeAt(oldIndex);
    notifyListeners();

    try {
      await api.delete('/sections/$id');
      return true;
    } catch (e) {
      _sections.insert(oldIndex, removedItem);
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}