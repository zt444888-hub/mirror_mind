import 'package:flutter/foundation.dart';
import '../models/emotion_record.dart';
import '../services/database_service.dart';
import '../services/ai_service.dart' show AiService, EmotionAnalysisResult, WeeklyReportResult, YearReportResult, AiConfigException;

class EmotionProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final AiService _ai = AiService();

  List<EmotionRecord> _records = [];
  List<EmotionRecord> _monthRecords = [];
  List<EmotionRecord> _weekRecords = [];
  List<EmotionRecord> _yearRecords = [];
  List<EmotionRecord> _thirtyDayRecords = [];
  List<EmotionRecord> _tagFilteredMonthRecords = [];
  EmotionRecord? _latestRecord;
  bool _isAnalyzing = false;
  String? _aiError;
  String? _activeTagFilter;

  // 成就系统字段
  int _consecutiveDays = 0;
  int _totalRecordDays = 0;

  List<EmotionRecord> get records => _records;
  List<EmotionRecord> get monthRecords => _monthRecords;
  List<EmotionRecord> get weekRecords => _weekRecords;
  List<EmotionRecord> get yearRecords => _yearRecords;
  List<EmotionRecord> get thirtyDayRecords => _thirtyDayRecords;
  List<EmotionRecord> get tagFilteredMonthRecords => _tagFilteredMonthRecords;
  EmotionRecord? get latestRecord => _latestRecord;
  bool get isAnalyzing => _isAnalyzing;
  String? get aiError => _aiError;
  int get consecutiveDays => _consecutiveDays;
  int get totalRecordDays => _totalRecordDays;
  String? get activeTagFilter => _activeTagFilter;

  /// 更新 AI 配置
  void updateAiConfig({String? baseUrl, String? apiKey, String? model}) {
    _ai.updateConfig(baseUrl: baseUrl, apiKey: apiKey, model: model);
  }

  /// 加载最新记录
  Future<void> loadLatestRecord() async {
    _latestRecord = await _db.getLatestRecord();
    notifyListeners();
  }

  /// 加载某月记录
  Future<void> loadMonthRecords(int year, int month) async {
    _monthRecords = await _db.getRecordsByMonth(year, month);
    notifyListeners();
  }

  /// 加载某月记录（带标签筛选）
  Future<void> loadMonthRecordsByTag(int year, int month, {String tag = '全部'}) async {
    if (tag == '全部') {
      _tagFilteredMonthRecords = await _db.getRecordsByMonth(year, month);
    } else {
      _tagFilteredMonthRecords = await _db.getRecordsByTagAndMonth(tag, year, month);
    }
    _monthRecords = _tagFilteredMonthRecords;
    _activeTagFilter = tag;
    notifyListeners();
  }

  /// 加载近30天记录
  Future<void> load30DayRecords() async {
    _thirtyDayRecords = await _db.getRecordsForLast30Days();
    notifyListeners();
  }

  /// 加载本周记录
  Future<void> loadWeekRecords() async {
    _weekRecords = await _db.getRecordsThisWeek();
    notifyListeners();
  }

  /// 加载全年记录
  Future<void> loadYearRecords() async {
    _yearRecords = await _db.getRecordsThisYear();
    notifyListeners();
  }

  /// 加载某天记录
  Future<List<EmotionRecord>> loadDayRecords(DateTime date) async {
    return await _db.getRecordsByDate(date);
  }

  /// AI 分析文本并返回结果
  Future<EmotionAnalysisResult?> analyzeText(String text) async {
    _isAnalyzing = true;
    _aiError = null;
    notifyListeners();

    try {
      return await _ai.analyzeEmotion(text);
    } on AiConfigException catch (e) {
      _aiError = e.message;
      return null;
    } catch (e) {
      _aiError = '分析失败：${e.toString()}';
      return null;
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  /// 加载连续记录天数与总记录天数
  Future<void> loadStreak() async {
    _consecutiveDays = await _db.getConsecutiveDays();
    _totalRecordDays = await _db.getTotalRecordDays();
    notifyListeners();
  }

  /// 保存情绪记录
  Future<int> saveRecord(EmotionRecord record) async {
    final id = await _db.insertRecord(record);
    await loadLatestRecord();
    // 保存后自动刷新成就数据
    await loadStreak();
    await loadWeekRecords();
    return id;
  }

  /// 更新记录
  Future<int> updateRecord(EmotionRecord record) async {
    final result = await _db.updateRecord(record);
    await loadLatestRecord();
    return result;
  }

  /// 删除记录
  Future<void> deleteRecord(int id) async {
    await _db.deleteRecord(id);
    await loadLatestRecord();
  }

  /// 生成周报
  Future<WeeklyReportResult?> generateWeeklyReport() async {
    _isAnalyzing = true;
    _aiError = null;
    notifyListeners();

    try {
      final weekData = _weekRecords.map((r) => {
        'date': r.date.toIso8601String().split('T')[0],
        'emotion': r.emotion,
        'score': r.score,
        'tag': r.tag,
        'text': r.inputText,
      }).toList();

      return await _ai.generateWeeklyReport(weekData);
    } on AiConfigException catch (e) {
      _aiError = e.message;
      return null;
    } catch (e) {
      _aiError = '生成失败：${e.toString()}';
      return null;
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  /// 生成年度报告
  Future<YearReportResult?> generateYearReport() async {
    _isAnalyzing = true;
    _aiError = null;
    notifyListeners();

    try {
      final yearData = _yearRecords.map((r) => {
        'date': r.date.toIso8601String().split('T')[0],
        'emotion': r.emotion,
        'score': r.score,
        'tag': r.tag,
      }).toList();

      return await _ai.generateYearReport(yearData);
    } on AiConfigException catch (e) {
      _aiError = e.message;
      return null;
    } catch (e) {
      _aiError = '生成失败：${e.toString()}';
      return null;
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  /// 导出数据
  Future<String> exportData() async {
    return await _db.exportToJson();
  }

  /// 清空所有数据
  Future<void> deleteAllData() async {
    await _db.deleteAllRecords();
    _records = [];
    _monthRecords = [];
    _weekRecords = [];
    _latestRecord = null;
    notifyListeners();
  }

  /// 加载所有记录
  Future<List<EmotionRecord>> loadAllRecords() async {
    _records = await _db.getAllRecords();
    notifyListeners();
    return _records;
  }

  void clearAiError() {
    _aiError = null;
    notifyListeners();
  }
}
