/// Local SQLite database for offline-first support.
/// Mirrors the API data models for local CRUD operations.
/// Synced with the backend when connectivity is restored.
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  factory LocalDatabase() => _instance;
  LocalDatabase._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'photosync_offline.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Students table
    await db.execute('''
      CREATE TABLE students (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        student_id TEXT NOT NULL,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        email TEXT,
        course TEXT NOT NULL,
        year_level INTEGER NOT NULL DEFAULT 1,
        section_id TEXT,
        created_at TEXT,
        updated_at TEXT,
        synced_at TEXT
      )
    ''');

    // Subjects table
    await db.execute('''
      CREATE TABLE subjects (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        code TEXT,
        name TEXT NOT NULL,
        units INTEGER NOT NULL DEFAULT 3,
        created_at TEXT,
        synced_at TEXT
      )
    ''');

    // Exams table
    await db.execute('''
      CREATE TABLE exams (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        subject_id TEXT NOT NULL,
        term_id TEXT,
        name TEXT NOT NULL,
        component_type TEXT,
        total_items INTEGER NOT NULL DEFAULT 0,
        points_per_item REAL NOT NULL DEFAULT 1.0,
        passing_score REAL,
        created_at TEXT,
        synced_at TEXT
      )
    ''');

    // Exam Results table
    await db.execute('''
      CREATE TABLE exam_results (
        id TEXT PRIMARY KEY,
        exam_id TEXT NOT NULL,
        student_id TEXT NOT NULL,
        score REAL NOT NULL DEFAULT 0,
        raw_count INTEGER,
        remarks TEXT,
        created_at TEXT,
        synced_at TEXT
      )
    ''');

    // Attendance table
    await db.execute('''
      CREATE TABLE attendance (
        id TEXT PRIMARY KEY,
        student_id TEXT NOT NULL,
        subject_id TEXT NOT NULL,
        year INTEGER NOT NULL,
        month INTEGER NOT NULL,
        day INTEGER NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT,
        synced_at TEXT
      )
    ''');

    // Sections table
    await db.execute('''
      CREATE TABLE sections (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        subject_id TEXT NOT NULL,
        section_label TEXT NOT NULL,
        room_number TEXT,
        created_at TEXT,
        synced_at TEXT
      )
    ''');

    // Pending sync operations queue
    await db.execute('''
      CREATE TABLE pending_sync (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation TEXT NOT NULL,
        endpoint TEXT NOT NULL,
        payload TEXT,
        created_at TEXT NOT NULL,
        retry_count INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // ─── Pending Sync Operations ────────────────────────────────────────────

  Future<void> addPendingSync({
    required String operation,
    required String endpoint,
    Map<String, dynamic>? payload,
  }) async {
    final db = await database;
    await db.insert('pending_sync', {
      'operation': operation,
      'endpoint': endpoint,
      'payload': payload != null ? _encode(payload) : null,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getPendingSyncs() async {
    final db = await database;
    return await db.query('pending_sync', orderBy: 'id ASC');
  }

  Future<void> removePendingSync(int id) async {
    final db = await database;
    await db.delete('pending_sync', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> incrementRetry(int id) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE pending_sync SET retry_count = retry_count + 1 WHERE id = ?',
      [id],
    );
  }

  Future<int> pendingSyncCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM pending_sync');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ─── Generic CRUD ───────────────────────────────────────────────────────

  Future<void> upsert(String table, Map<String, dynamic> data) async {
    final db = await database;
    data['synced_at'] = DateTime.now().toIso8601String();
    await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> getWhere(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  Future<void> deleteWhere(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<void> clearTable(String table) async {
    final db = await database;
    await db.delete(table);
  }

  // ─── Helpers ────────────────────────────────────────────────────────────

  String _encode(Map<String, dynamic> data) {
    return jsonEncode(data);
  }
}