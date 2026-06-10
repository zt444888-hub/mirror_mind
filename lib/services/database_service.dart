/// 心镜 MirrorMind — 本地数据库服务
///
/// ## 安全说明
/// 所有情绪记录数据仅存储在设备本地 SQLite 数据库中。
/// 应用沙盒机制确保其他应用无法访问心镜的数据文件。
/// 不上传任何数据至外部服务器。

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
    // 检查是否存在旧哈希命名的数据库，如有则迁移
    await _migrateFromOldDb(dbPath, path);
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  /// 从旧哈希命名的数据库迁移数据到固定文件名数据库
  /// 避免 String.hashCode 跨版本不稳定导致数据丢失
  Future<void> _migrateFromOldDb(String dbPath, String newPath) async {
    final newExists = await databaseExists(newPath);
    if (newExists) return; // 新数据库已存在，无需迁移
    // 旧命名模式：mm_<hash>.db
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
          version: 3,
          onCreate: _onCreate,
        );
        for (final map in maps) {
          await newDb.insert(_tableName, map);
        }
        await newDb.close();
      }
      await oldDb.close();
      await deleteDatabase(oldPath);
    } catch (_) {}
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
  }

  /// 插入一条情绪记录
  Future<int> insertRecord(EmotionRecord record) async {
    final db = await database;
    return await db.insert(_tableName, record.toMap());
  }

  /// 更新记录
  Future<int> updateRecord(EmotionRecord record) async {
    final db = await database;
    return await db.update(
      _tableName,
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  /// 获取某一天的所有记录
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

  /// 获取某月的所有记录（用于日历标注）
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

  /// 获取本周记录（周一开始）
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

  /// 获取本年度记录（1月1日至今）
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

  /// 获取最新一条记录
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

  /// 获取所有记录（用于导出）
  Future<List<EmotionRecord>> getAllRecords() async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => EmotionRecord.fromMap(m)).toList();
  }

  /// 导出所有数据为 JSON 字符串
  Future<String> exportToJson() async {
    final records = await getAllRecords();
    final list = records.map((r) => r.toMap()).toList();
    return const JsonEncoder.withIndent('  ').convert(list);
  }

  /// 删除某条记录
  Future<int> deleteRecord(int id) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 清空所有记录
  Future<void> deleteAllRecords() async {
    final db = await database;
    await db.delete(_tableName);
  }

  /// 计算连续记录天数（从今天往前数，中断则停）
  Future<int> getConsecutiveDays() async {
    final db = await database;
    final maps = await db.rawQuery(
      'SELECT DISTINCT date FROM $_tableName ORDER BY date DESC',
    );
    if (maps.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 将所有日期字符串放入 Set 快速查找
    final dateSet = <String>{};
    for (final m in maps) {
      dateSet.add(m['date'] as String);
    }

    // 今天无记录则连续天数为 0
    final todayStr = today.toIso8601String().split('T')[0];
    if (!dateSet.contains(todayStr)) return 0;

    // 向前累加直到间断
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

  /// 按标签查询记录
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

  /// 按标签+月份查询记录
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

  /// 获取最近30天记录
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

  /// 计算有记录的总天数（去重）
  Future<int> getTotalRecordDays() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(DISTINCT date) as count FROM $_tableName',
    );
    return result.first['count'] as int;
  }

  /// 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
