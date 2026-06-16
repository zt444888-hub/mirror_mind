import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  String? _baseUrl;
  String? _apiKey;
  String? _model;

  void updateConfig({String? baseUrl, String? apiKey, String? model}) {
    _baseUrl = baseUrl ?? _baseUrl;
    _apiKey = apiKey ?? _apiKey;
    _model = model ?? _model;
  }

  bool get isConfigured => _apiKey != null && _apiKey!.isNotEmpty;

  /// 检查配置状态，返回错误信息（null 表示配置正常）
  String? _checkConfig() {
    if (!isConfigured) return '请先在设置页配置 API Key';
    if (_baseUrl == null || _baseUrl!.isEmpty) return '请先在设置页配置 API Base URL';
    return null;
  }

  /// 输入脱敏：过滤手机号、身份证号、邮箱，替换为 [已隐藏]
  String _sanitizeInput(String text) {
    var sanitized = text;
    // 手机号（中国大陆 1[3-9]\d{9}）
    sanitized =
        sanitized.replaceAll(RegExp(r'1[3-9]\d{9}'), '[已隐藏]');
    // 身份证号（18 位，末位可为 X/x）
    sanitized =
        sanitized.replaceAll(RegExp(r'\d{17}[\dXx]'), '[已隐藏]');
    // 邮箱
    sanitized =
        sanitized.replaceAll(RegExp(r'\S+@\S+\.\S+'), '[已隐藏]');
    return sanitized;
  }

  /// AI 情绪分析：输入文本 → 返回情绪类型、置信度、共情回应
  Future<EmotionAnalysisResult?> analyzeEmotion(String text) async {
    final configError = _checkConfig();
    if (configError != null) {
      // 未配置 API Key 时使用内置离线分析
      return _offlineAnalyze(text);
    }

    final sanitized = _sanitizeInput(text);
    final prompt = _buildAnalysisPrompt(sanitized);
    final responseMap = await _callApi(prompt);

    return EmotionAnalysisResult.fromJson(responseMap);
  }

  /// 离线关键词情绪分析（无需 API Key）
  EmotionAnalysisResult _offlineAnalyze(String text) {
    final sanitized = _sanitizeInput(text);
    final lower = sanitized.toLowerCase();

    // 情绪关键词映射
    final emotionKeywords = <String, List<String>>{
      '开心': ['开心', '高兴', '快乐', '愉快', '喜悦', '欣喜', '欢笑', '哈哈', '嘻嘻', '棒', '好开心', '太开心了', '庆祝', '满足', '幸福', '感恩', '感动'],
      '难过': ['难过', '伤心', '悲伤', '痛苦', '心碎', '哭了', '流泪', '失落', '沮丧', '绝望', '悲哀', '忧郁', '伤感', '想哭', '不开心'],
      '焦虑': ['焦虑', '紧张', '不安', '担心', '害怕', '恐惧', '恐慌', '心慌', '烦躁', '着急', '压力', '忐忑', '不知所措', '失眠', '担忧'],
      '愤怒': ['愤怒', '生气', '恼火', '怒', '气死', '烦', '讨厌', '恶心', '厌恶', '受不了', '爆炸', '火大', '不爽', '可恶'],
      '平静': ['平静', '放松', '安宁', '平和', '淡定', '从容', '安稳', '舒心', '舒适', '惬意', '悠闲', '宁静', '心如止水'],
      '疲惫': ['疲惫', '累', '困', '疲倦', '疲劳', '筋疲力尽', '没力气', '乏了', '虚脱', '无力', '透支', '扛不住', '想睡'],
      '孤独': ['孤独', '孤单', '寂寞', '一个人', '没人陪', '独处', '孤零零', '被遗忘', '被忽视', '没人理解', '孤立'],
      '期待': ['期待', '希望', '盼望', '向往', '渴望', '憧憬', '期盼', '许愿', '想要', '梦想', '目标'],
    };

    // 分析每个情绪类别的匹配度
    var bestEmotion = '一般';
    var bestScore = 0;
    for (final entry in emotionKeywords.entries) {
      var score = 0;
      for (final keyword in entry.value) {
        if (lower.contains(keyword)) {
          score += 2;
        }
      }
      // 给长文本更多权重
      if (score > bestScore) {
        bestScore = score;
        bestEmotion = entry.key;
      }
    }

    // 构建共情回应
    final responses = <String, String>{
      '开心': '感受到你的快乐了！保持这份好心情，生活中的美好时刻值得被记住和珍惜。',
      '难过': '听到你难过我也很心疼。允许自己感受这份情绪，慢慢来，一切都会好起来的。',
      '焦虑': '焦虑是很正常的感受。试试深呼吸，把注意力放在当下，一切都还在你的掌控中。',
      '愤怒': '愤怒是合理的情绪。先深呼吸冷静一下，给自己一点空间和时间。',
      '平静': '这种平静的状态非常珍贵。享受当下的宁静，这就是内心力量的源泉。',
      '疲惫': '你辛苦了。好好休息是对自己最好的照顾，给自己充充电吧。',
      '孤独': '即使独处，你也不孤单。你的感受值得被看见，也许可以联系一个信任的人。',
      '期待': '有期待的感觉真好！向着目标前进的每一步都值得庆祝。',
      '一般': '谢谢你的分享。每一天都是新的开始，希望你能找到属于自己的小确幸。',
    };

    return EmotionAnalysisResult(
      emotion: bestEmotion,
      confidence: bestScore > 0 ? (bestScore / 10.0).clamp(0.3, 0.95) : 0.5,
      response: responses[bestEmotion] ?? responses['一般']!,
    );
  }

  /// 生成周报
  Future<WeeklyReportResult?> generateWeeklyReport(
    List<Map<String, dynamic>> weekRecords,
  ) async {
    final configError = _checkConfig();
    if (configError != null) throw AiConfigException(configError);

    final recordText = weekRecords.map((r) {
      return '日期: ${r['date']}, 情绪: ${r['emotion']}, 评分: ${r['score']}/10, 标签: ${r['tag'] ?? "无"}, 内容: ${r['text'] ?? ""}';
    }).join('\n');

    final prompt = _buildWeeklyPrompt(recordText);
    final responseMap = await _callApi(prompt);

    return WeeklyReportResult.fromJson(responseMap);
  }

  /// 重试配置常量
  static const int _maxRetries = 3;
  static const Duration _initialRetryDelay = Duration(seconds: 1);
  static const double _retryBackoffMultiplier = 2.0;

  /// 通用 API 调用（带指数退避重试）
  Future<Map<String, dynamic>> _callApi(String userMessage) async {
    int retryCount = 0;
    Duration retryDelay = _initialRetryDelay;
    
    while (true) {
      try {
        return await _executeApiCall(userMessage);
      } catch (e) {
        retryCount++;
        if (retryCount >= _maxRetries) {
          // 超过最大重试次数，抛出最后一次异常
          rethrow;
        }
        
        // 仅对可重试的错误进行重试
        if (_shouldRetry(e)) {
          // 指数退避等待
          await Future.delayed(retryDelay);
          retryDelay = Duration(
            milliseconds: (retryDelay.inMilliseconds * _retryBackoffMultiplier).toInt(),
          );
          continue;
        }
        
        // 不可重试的错误，直接抛出
        rethrow;
      }
    }
  }

  /// 执行单次 API 调用
  Future<Map<String, dynamic>> _executeApiCall(String userMessage) async {
    final baseUrl = _baseUrl ?? '';
    if (baseUrl.isEmpty) {
      throw const AiConfigException('API Base URL 未配置，请检查设置');
    }
    final url = '${baseUrl.replaceAll(RegExp(r'/+$'), '')}/chat/completions';
    final response = await http
        .post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
          body: jsonEncode({
            'model': _model ?? 'gpt-4o-mini',
            'messages': [
              {'role': 'system', 'content': _systemPrompt},
              {'role': 'user', 'content': userMessage},
            ],
            'temperature': 0.7,
            'max_tokens': 500,
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 401) {
      throw const AiConfigException('API Key 无效，请检查设置');
    }
    if (response.statusCode == 429) {
      // 限流错误，可重试
      throw const AiRetryException('请求过于频繁，正在重试...');
    }
    if (response.statusCode >= 500) {
      // 服务器错误，可重试
      throw const AiRetryException('服务器暂时不可用，正在重试...');
    }
    if (response.statusCode != 200) {
      throw AiConfigException('API 请求失败 (${response.statusCode})');
    }

    final body = jsonDecode(response.body);
    final content = body['choices']?[0]?['message']?['content'] as String?;
    if (content == null) throw const FormatException('API 返回为空');

    return _parseJsonResponse(content);
  }

  /// 判断是否应该重试
  bool _shouldRetry(dynamic e) {
    return e is AiRetryException || 
           e is http.ClientException || 
           e is TimeoutException;
  }

  /// 解析 AI 返回的 JSON（支持代码块包裹的情况）
  Map<String, dynamic> _parseJsonResponse(String raw) {
    String jsonStr = raw.trim();
    // 移除可能的 markdown 代码块标记
    if (jsonStr.startsWith('```json')) {
      jsonStr = jsonStr.substring(7);
    } else if (jsonStr.startsWith('```')) {
      jsonStr = jsonStr.substring(3);
    }
    if (jsonStr.endsWith('```')) {
      jsonStr = jsonStr.substring(0, jsonStr.length - 3);
    }
    jsonStr = jsonStr.trim();

    try {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      // 尝试从原始文本中提取 JSON
      final startIdx = jsonStr.indexOf('{');
      final endIdx = jsonStr.lastIndexOf('}');
      if (startIdx != -1 && endIdx != -1 && endIdx > startIdx) {
        return jsonDecode(jsonStr.substring(startIdx, endIdx + 1))
            as Map<String, dynamic>;
      }
      rethrow;
    }
  }

  String get _systemPrompt =>
      '你是一个温暖、专业的心理健康助手"小镜"。用户会向你倾诉他们的心情，'
      '请用温暖、共情的语气回应。你的回复必须是严格的 JSON 格式，不要包含其他内容。';

  String _buildAnalysisPrompt(String text) {
    final sanitized = _sanitizeInput(text);
    return '用户说："$sanitized"\n\n'
        '请分析这份情绪记录，返回如下 JSON 格式（不要包含 markdown 代码块）：\n'
        '{\n'
        '  "emotion": "情绪类型（从以下选择：开心/平静/兴奋/感恩/焦虑/难过/生气/疲惫/一般）",\n'
        '  "confidence": 0.0到1.0之间的置信度数值,\n'
        '  "response": "一句温暖共情的回应（30字以内，中文）"\n'
        '}';
  }

  String _buildWeeklyPrompt(String records) {
    return '以下是一位用户本周的情绪记录：\n\n'
        '$records\n\n'
        '请以温暖、专业的口吻，生成本周情绪分析报告。返回如下 JSON 格式：\n'
        '{\n'
        '  "summary": "本周情绪总体概述（50字以内）",\n'
        '  "dominant_emotion": "本周主要情绪",\n'
        '  "suggestion": "1-2条温暖的自我关怀建议（80字以内）",\n'
        '  "quote": "一句适合用户的温暖的金句"\n'
        '}';
  }

  /// 生成年度报告
  Future<YearReportResult?> generateYearReport(
    List<Map<String, dynamic>> yearRecords,
  ) async {
    final configError = _checkConfig();
    if (configError != null) throw AiConfigException(configError);

    final recordText = yearRecords.map((r) {
      return '日期: ${r['date']}, 情绪: ${r['emotion']}, 评分: ${r['score']}/10, 标签: ${r['tag'] ?? "无"}';
    }).join('\n');

    final prompt = _buildYearPrompt(recordText);
    final responseMap = await _callApi(prompt);

    return YearReportResult.fromJson(responseMap);
  }

  String _buildYearPrompt(String records) {
    return '以下是一位用户全年（或近一年）的情绪记录摘要：\n\n'
        '$records\n\n'
        '请以温暖、专业的口吻，生成年度情绪回顾报告。返回如下 JSON 格式：\n'
        '{\n'
        '  "keywords": ["关键词1", "关键词2", "关键词3"],\n'
        '  "trend": "年度情绪趋势描述（60字以内）",\n'
        '  "insight": "深度的情绪洞察与成长发现（100字以内）",\n'
        '  "suggestion": "新年自我关怀建议（80字以内）",\n'
        '  "avgScore": 平均评分数值（1-10的浮点数）\n'
        '}';
  }
}

/// AI 情绪分析结果
class EmotionAnalysisResult {
  final String emotion;
  final double confidence;
  final String response;

  EmotionAnalysisResult({
    required this.emotion,
    required this.confidence,
    required this.response,
  });

  factory EmotionAnalysisResult.fromJson(Map<String, dynamic> json) {
    return EmotionAnalysisResult(
      emotion: json['emotion'] as String? ?? '一般',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
      response: json['response'] as String? ?? '谢谢你的分享。',
    );
  }
}

/// 周报生成结果
class WeeklyReportResult {
  final String summary;
  final String dominantEmotion;
  final String suggestion;
  final String quote;

  WeeklyReportResult({
    required this.summary,
    required this.dominantEmotion,
    required this.suggestion,
    required this.quote,
  });

  factory WeeklyReportResult.fromJson(Map<String, dynamic> json) {
    return WeeklyReportResult(
      summary: json['summary'] as String? ?? '',
      dominantEmotion: json['dominant_emotion'] as String? ?? '',
      suggestion: json['suggestion'] as String? ?? '',
      quote: json['quote'] as String? ?? '',
    );
  }
}

class AiConfigException implements Exception {
  final String message;
  const AiConfigException(this.message);

  @override
  String toString() => message;
}

/// AI 重试异常：用于标识可重试的错误
class AiRetryException implements Exception {
  final String message;
  const AiRetryException(this.message);

  @override
  String toString() => message;
}

/// 年度报告生成结果
class YearReportResult {
  final List<String> keywords;
  final String trend;
  final String insight;
  final String suggestion;
  final double avgScore;

  YearReportResult({
    required this.keywords,
    required this.trend,
    required this.insight,
    required this.suggestion,
    required this.avgScore,
  });

  factory YearReportResult.fromJson(Map<String, dynamic> json) {
    return YearReportResult(
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      trend: json['trend'] as String? ?? '',
      insight: json['insight'] as String? ?? '',
      suggestion: json['suggestion'] as String? ?? '',
      avgScore: (json['avgScore'] as num?)?.toDouble() ?? 5.0,
    );
  }
}
