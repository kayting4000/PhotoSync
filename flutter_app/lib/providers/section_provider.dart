import 'package:flutter/material.dart';
import '../models/section.dart';
import '../services/api_service.dart';

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

      _sections = items.map((item) => Section.fromJson(item as Map<String, dynamic>)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addSection(Section section) async {
    try {
      await api.post('/sections/', {
        'subject_id': section.subjectId,
        'section_label': section.sectionLabel,
        'room_number': section.roomNumber,
      });
      await fetchSections();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSection(String id, Section section) async {
    try {
      final body = <String, dynamic>{
        'section_label': section.sectionLabel,
        'room_number': section.roomNumber,
      };
      await api.put('/sections/$id', body);
      await fetchSections();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSection(String id) async {
    try {
      await api.delete('/sections/$id');
      await fetchSections();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}