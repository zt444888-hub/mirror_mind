import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/emotion_record.dart';

class DatabaseService {
  static Database? _database;
  static const String _tableName = 'emotion_records';
  static const String _dbName = 'mirror_mind.db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    // Check for old hash-named DBs and migrate to the fixed name.
    await _migrateFromOldDb(dbPath, path);
    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  /// 浠庢棫鍝堝笇鍛藉悕鐨勬暟鎹簱杩佺Щ鏁版嵁鍒板浐瀹氭枃浠跺悕鏁版嵁搴?  /// 閬垮厤 String.hashCode 璺ㄧ増鏈笉绋冲畾瀵艰嚧鏁版嵁涓㈠け
  Future<void> _migrateFromOldDb(String dbPath, String newPath) async {
    final newExists = await databaseExists(newPath);
    if (newExists) return; // New DB already exists, skip migration.
    // Old naming pattern: mm_<hash>.db
    final dir = Directory(dbPath);
    if (!await dir.exists()) return;
    final files = await dir.list().toList();
    final oldFile = files.cast<FileSystemEntity>().firstWhere(
      (f) => f.path.endsWith('.db') && f.path.contains('/mm_'),
      orElse: () => File(''),
    );
    if (oldFile.path.isEmpty) return;
    try {
      final oldName = basename(oldFile.path);
      final oldPath = join(dbPath, oldName);
      final oldDb = await openDatabase(oldPath, version: 2);
      final maps = await oldDb.query(_tableName);
      if (maps.isNotEmpty) {
        final newDb = await openDatabase(
          newPath,
          version: 4,
          onCreate: _onCreate,
        );
        for (final map in maps) {
          await newDb.insert(_tableName, map);
        }
        await newDb.close();
      }
      await oldDb.close();
      await deleteDatabase(oldPath);
    } catch (e) {
      debugPrint('数据库迁移异常: \$e');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        emotion TEXT NOT NULL,
        input_text TEXT,
        ai_response TEXT,
        confidence REAL DEFAULT 0.0,
        score INTEGER DEFAULT 5,
        tag TEXT,
        created_at TEXT NOT NULL,
        gratitude_items TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $_tableName ADD COLUMN gratitude_items TEXT');
    }
    if (oldVersion < 4) {
      await db.execute('CREATE INDEX IF NOT EXISTS idx_${_tableName}_date ON $_tableName(date)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_${_tableName}_created_at ON $_tableName(created_at)');
    }
  }


  /// Insert a new emotion record.
  Future<int> insertRecord(EmotionRecord record) async {
    final db = await database;
    return await db.insert(_tableName, record.toMap());
  }

  /// Update an existing record.
  Future<int> updateRecord(EmotionRecord record) async {
    final db = await database;
    return await db.update(
      _tableName,
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  /// Get all records for a given date.
  Future<List<EmotionRecord>> getRecordsByDate(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    final maps = await db.query(
      _tableName,
      where: 'date = ?',
      whereArgs: [dateStr],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => EmotionRecord.fromMap(m)).toList();
  }

  /// Get records for a given month (used for calendar markers).
  Future<List<EmotionRecord>> getRecordsByMonth(int year, int month) async {
    final db = await database;
    final startDate = '$year-${month.toString().padLeft(2, '0')}-01';
    final endDate = month < 12
        ? '$year-${(month + 1).toString().padLeft(2, '0')}-01'
        : '${year + 1}-01-01';
    final maps = await db.query(
      _tableName,
      where: 'date >= ? AND date < ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date DESC',
    );
    return maps.map((m) => EmotionRecord.fromMap(m)).toList();
  }

  /// Get records for the current week (Monday to Sunday).
  Future<List<EmotionRecord>> getRecordsThisWeek() async {
    final now = DateTime.now();
    final weekday = now.weekday;
    final monday = now.subtract(Duration(days: weekday - 1));
    final sunday = monday.add(const Duration(days: 6));

    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        monday.toIso8601String().split('T')[0],
        sunday.toIso8601String().split('T')[0],
      ],
      orderBy: 'date ASC',
    );
    return maps.map((m) => EmotionRecord.fromMap(m)).toList();
  }

  /// 鑾峰彇鏈勾搴﹁褰曪紙1鏈?鏃ヨ嚦浠婏級
  Future<List<EmotionRecord>> getRecordsThisYear() async {
    final now = DateTime.now();
    final yearStart = DateTime(now.year, 1, 1);
    final yearEnd = DateTime(now.year + 1, 1, 1);

    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'date >= ? AND date < ?',
      whereArgs: [
        yearStart.toIso8601String().split('T')[0],
        yearEnd.toIso8601String().split('T')[0],
      ],
      orderBy: 'date ASC',
    );
    return maps.map((m) => EmotionRecord.fromMap(m)).toList();
  }

  /// Get the most recent record.
  Future<EmotionRecord?> getLatestRecord() async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return EmotionRecord.fromMap(maps.first);
  }

  /// Get all records (for export).
  Future<List<EmotionRecord>> getAllRecords() async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => EmotionRecord.fromMap(m)).toList();
  }

  /// Export all data as a JSON string.
  Future<String> exportToJson() async {
    final records = await getAllRecords();
    final list = records.map((r) => r.toMap()).toList();
    return const JsonEncoder.withIndent('  ').convert(list);
  }

  /// Delete a record by id.
  Future<int> deleteRecord(int id) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete all records.
  Future<void> deleteAllRecords() async {
    final db = await database;
    await db.delete(_tableName);
  }

  /// Count consecutive record days (from today backward, stops on break).
  Future<int> getConsecutiveDays() async {
    final db = await database;
    final maps = await db.rawQuery(
      'SELECT DISTINCT date FROM $_tableName ORDER BY date DESC',
    );
    if (maps.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Put all date strings into a Set for fast lookup.
    final dateSet = <String>{};
    for (final m in maps) {
      dateSet.add(m['date'] as String);
    }

    // If no record for today, consecutive days = 0.
    final todayStr = today.toIso8601String().split('T')[0];
    if (!dateSet.contains(todayStr)) return 0;

    // Scan backward until a day without a record is found.
    int consecutive = 0;
    for (int i = 0; ; i++) {
      final checkDate = today.subtract(Duration(days: i));
      final checkStr = checkDate.toIso8601String().split('T')[0];
      if (dateSet.contains(checkStr)) {
        consecutive++;
      } else {
        break;
      }
    }

    return consecutive;
  }

  /// Get records by tag.
  Future<List<EmotionRecord>> getRecordsByTag(String tag) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'tag = ?',
      whereArgs: [tag],
      orderBy: 'date DESC',
    );
    return maps.map((m) => EmotionRecord.fromMap(m)).toList();
  }

  /// 鎸夋爣绛?鏈堜唤鏌ヨ璁板綍
  Future<List<EmotionRecord>> getRecordsByTagAndMonth(String tag, int year, int month) async {
    final db = await database;
    final startDate = '$year-${month.toString().padLeft(2, '0')}-01';
    final endDate = month < 12
        ? '$year-${(month + 1).toString().padLeft(2, '0')}-01'
        : '${year + 1}-01-01';
    final maps = await db.query(
      _tableName,
      where: 'tag = ? AND date >= ? AND date < ?',
      whereArgs: [tag, startDate, endDate],
      orderBy: 'date DESC',
    );
    return maps.map((m) => EmotionRecord.fromMap(m)).toList();
  }

  /// 鑾峰彇鏈€杩?0澶╄褰?
  Future<List<EmotionRecord>> getRecordsForLast30Days() async {
    final db = await database;
    final endDate = DateTime.now().add(const Duration(days: 1));
    final startDate = endDate.subtract(const Duration(days: 31));
    final maps = await db.query(
      _tableName,
      where: 'date >= ? AND date < ?',
      whereArgs: [
        startDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0],
      ],
      orderBy: 'date ASC',
    );
    return maps.map((m) => EmotionRecord.fromMap(m)).toList();
  }

  /// Count total distinct record days.
  Future<int> getTotalRecordDays() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(DISTINCT date) as count FROM $_tableName',
    );
    return result.first['count'] as int;
  }

  /// Close the database connection.
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
