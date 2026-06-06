import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local storage service for offline caching using SharedPreferences
class LocalStorageService {
  static const String _gradesKey = 'cached_grades';
  static const String _studentsKey = 'cached_students';
  static const String _subjectsKey = 'cached_subjects';
  static const String _lastSyncKey = 'last_sync';

  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  Future<void> init() async {}

  Future<void> saveGrades(List<Map<String, dynamic>> grades) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_gradesKey, jsonEncode(grades));
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Error saving grades: $e');
    }
  }

  List<Map<String, dynamic>> getCachedGrades() {
    return [];
  }

  Future<List<Map<String, dynamic>>> getCachedGradesAsync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_gradesKey);
      if (raw == null) return [];
      return List<Map<String, dynamic>>.from(jsonDecode(raw));
    } catch (e) {
      debugPrint('Error getting cached grades: $e');
      return [];
    }
  }

  Future<void> saveStudents(List<Map<String, dynamic>> students) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_studentsKey, jsonEncode(students));
    } catch (e) {
      debugPrint('Error saving students: $e');
    }
  }

  List<Map<String, dynamic>> getCachedStudents() => [];

  Future<List<Map<String, dynamic>>> getCachedStudentsAsync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_studentsKey);
      if (raw == null) return [];
      return List<Map<String, dynamic>>.from(jsonDecode(raw));
    } catch (e) {
      debugPrint('Error getting cached students: $e');
      return [];
    }
  }

  Future<void> saveSubjects(List<Map<String, dynamic>> subjects) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_subjectsKey, jsonEncode(subjects));
    } catch (e) {
      debugPrint('Error saving subjects: $e');
    }
  }

  List<Map<String, dynamic>> getCachedSubjects() => [];

  Future<List<Map<String, dynamic>>> getCachedSubjectsAsync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_subjectsKey);
      if (raw == null) return [];
      return List<Map<String, dynamic>>.from(jsonDecode(raw));
    } catch (e) {
      debugPrint('Error getting cached subjects: $e');
      return [];
    }
  }

  DateTime? getLastSyncTime() => null;

  Future<DateTime?> getLastSyncTimeAsync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_lastSyncKey);
      if (raw != null) return DateTime.parse(raw);
    } catch (e) {
      debugPrint('Error getting last sync time: $e');
    }
    return null;
  }

  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_gradesKey);
      await prefs.remove(_studentsKey);
      await prefs.remove(_subjectsKey);
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }
}
