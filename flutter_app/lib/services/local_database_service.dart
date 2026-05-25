import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Local database for offline-first caching.
/// Caches GET responses and queues mutations for later sync.
class LocalDatabaseService {
  static Database? _database;
  static final LocalDatabaseService _instance = LocalDatabaseService._();

  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'photosync_cache.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Cache table for GET responses
        await db.execute('''
          CREATE TABLE cache (
            key TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            timestamp INTEGER NOT NULL
          )
        ''');

        // Sync queue for mutations made offline
        await db.execute('''
          CREATE TABLE sync_queue (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            method TEXT NOT NULL,
            endpoint TEXT NOT NULL,
            body TEXT,
            created_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  // ─── Cache Operations ─────────────────────────────────────────────────

  Future<void> cachePut(String key, dynamic data) async {
    final db = await database;
    await db.insert(
      'cache',
      {
        'key': key,
        'data': jsonEncode(data),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<dynamic> cacheGet(String key, {Duration maxAge = const Duration(hours: 1)}) async {
    final db = await database;
    final results = await db.query(
      'cache',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (results.isEmpty) return null;

    final row = results.first;
    final timestamp = row['timestamp'] as int;
    final age = DateTime.now().millisecondsSinceEpoch - timestamp;

    if (age > maxAge.inMilliseconds) {
      await db.delete('cache', where: 'key = ?', whereArgs: [key]);
      return null;
    }

    return jsonDecode(row['data'] as String);
  }

  Future<void> cacheClear() async {
    final db = await database;
    await db.delete('cache');
  }

  // ─── Sync Queue Operations ────────────────────────────────────────────

  Future<void> enqueueMutation(String method, String endpoint, dynamic body) async {
    final db = await database;
    await db.insert('sync_queue', {
      'method': method,
      'endpoint': endpoint,
      'body': body != null ? jsonEncode(body) : null,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingMutations() async {
    final db = await database;
    return db.query('sync_queue', orderBy: 'created_at ASC');
  }

  Future<void> removeMutation(int id) async {
    final db = await database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> pendingMutationCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM sync_queue');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> clearSyncQueue() async {
    final db = await database;
    await db.delete('sync_queue');
  }

  // ─── Utility ──────────────────────────────────────────────────────────

  Future<void> clearAll() async {
    await cacheClear();
    await clearSyncQueue();
  }
}