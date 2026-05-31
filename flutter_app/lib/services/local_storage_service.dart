import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

/// Local storage service for offline mode
/// Uses Hive for fast, local data persistence
class LocalStorageService {
  static const String _gradesBox = 'grades';
  static const String _studentsBox = 'students';
  static const String _subjectsBox = 'subjects';
  static const String _syncStatusBox = 'sync_status';

  static final LocalStorageService _instance = LocalStorageService._internal();

  factory LocalStorageService() {
    return _instance;
  }

  LocalStorageService._internal();

  /// Initialize Hive boxes
  Future<void> init() async {
    try {
      if (!Hive.isBoxOpen(_gradesBox)) {
        await Hive.openBox(_gradesBox);
      }
      if (!Hive.isBoxOpen(_studentsBox)) {
        await Hive.openBox(_studentsBox);
      }
      if (!Hive.isBoxOpen(_subjectsBox)) {
        await Hive.openBox(_subjectsBox);
      }
      if (!Hive.isBoxOpen(_syncStatusBox)) {
        await Hive.openBox(_syncStatusBox);
      }
    } catch (e) {
      debugPrint('Error initializing Hive: $e');
    }
  }

  /// Save grades locally
  Future<void> saveGrades(List<Map<String, dynamic>> grades) async {
    try {
      final box = Hive.box(_gradesBox);
      await box.clear();
      for (int i = 0; i < grades.length; i++) {
        await box.put('grade_$i', grades[i]);
      }
      await box.put('last_sync', DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Error saving grades: $e');
    }
  }

  /// Get cached grades
  List<Map<String, dynamic>> getCachedGrades() {
    try {
      final box = Hive.box(_gradesBox);
      final grades = <Map<String, dynamic>>[];
      for (var key in box.keys) {
        if (key.toString().startsWith('grade_')) {
          grades.add(Map<String, dynamic>.from(box.get(key) ?? {}));
        }
      }
      return grades;
    } catch (e) {
      debugPrint('Error getting cached grades: $e');
      return [];
    }
  }

  /// Save students locally
  Future<void> saveStudents(List<Map<String, dynamic>> students) async {
    try {
      final box = Hive.box(_studentsBox);
      await box.clear();
      for (int i = 0; i < students.length; i++) {
        await box.put('student_$i', students[i]);
      }
    } catch (e) {
      debugPrint('Error saving students: $e');
    }
  }

  /// Get cached students
  List<Map<String, dynamic>> getCachedStudents() {
    try {
      final box = Hive.box(_studentsBox);
      final students = <Map<String, dynamic>>[];
      for (var key in box.keys) {
        if (key.toString().startsWith('student_')) {
          students.add(Map<String, dynamic>.from(box.get(key) ?? {}));
        }
      }
      return students;
    } catch (e) {
      debugPrint('Error getting cached students: $e');
      return [];
    }
  }

  /// Save subjects locally
  Future<void> saveSubjects(List<Map<String, dynamic>> subjects) async {
    try {
      final box = Hive.box(_subjectsBox);
      await box.clear();
      for (int i = 0; i < subjects.length; i++) {
        await box.put('subject_$i', subjects[i]);
      }
    } catch (e) {
      debugPrint('Error saving subjects: $e');
    }
  }

  /// Get cached subjects
  List<Map<String, dynamic>> getCachedSubjects() {
    try {
      final box = Hive.box(_subjectsBox);
      final subjects = <Map<String, dynamic>>[];
      for (var key in box.keys) {
        if (key.toString().startsWith('subject_')) {
          subjects.add(Map<String, dynamic>.from(box.get(key) ?? {}));
        }
      }
      return subjects;
    } catch (e) {
      debugPrint('Error getting cached subjects: $e');
      return [];
    }
  }

  /// Get last sync time
  DateTime? getLastSyncTime() {
    try {
      final box = Hive.box(_gradesBox);
      final lastSync = box.get('last_sync');
      if (lastSync != null) {
        return DateTime.parse(lastSync);
      }
    } catch (e) {
      debugPrint('Error getting last sync time: $e');
    }
    return null;
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    try {
      await Hive.box(_gradesBox).clear();
      await Hive.box(_studentsBox).clear();
      await Hive.box(_subjectsBox).clear();
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }
}
