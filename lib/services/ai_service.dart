
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String kCloudBaseUrl = 'https://mirror-mind.onrender.com';

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

  String? _checkConfig() {
    if (!isConfigured) return null; // 没 key 也能走云后端
    if (_baseUrl == null || _baseUrl!.isEmpty) return '请配置 API Base URL';
    return null;
  }

  String _sanitizeInput(String text) {
    var sanitized = text;
    sanitized = sanitized.replaceAll(RegExp(r'1[3-9]\d{9}'), '[已隐藏]');
    sanitized = sanitized.replaceAll(RegExp(r'\d{17}[\dXx]'), '[已隐藏]');
    sanitized = sanitized.replaceAll(RegExp(r'\S+@\S+\.\S+'), '[已隐藏]');
    return sanitized;
  }

  // === 情绪分析 ===

  Future<EmotionAnalysisResult?> analyzeEmotion(String text) async {
    // 有 API Key 走 OpenAI 兼容接口
    if (isConfigured && _baseUrl != null && _baseUrl!.isNotEmpty) {
      try {
        final sanitized = _sanitizeInput(text);
        final prompt = _buildAnalysisPrompt(sanitized);
        final responseMap = await _callApi(prompt);
        return EmotionAnalysisResult.fromJson(responseMap);
      } catch (_) {}
    }
    // 走云后端
    return _cloudAnalyze(text);
  }

  Future<EmotionAnalysisResult> _cloudAnalyze(String text) async {
    try {
      final sanitized = _sanitizeInput(text);
      final prompt = '分析以下情绪记录，只返回如下JSON（不要markdown）：\n'
          '{"emotion":"开心/平静/兴奋/感恩/焦虑/难过/生气/疲惫/一般","confidence":0.0-1.0,"response":"共情回应"}';
      final resp = await http.post(
        Uri.parse('$kCloudBaseUrl/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'messages': [
            {'role': 'user', 'content': prompt + '\n\n用户说：' + sanitized},
          ],
        }),
      ).timeout(const Duration(seconds: 20));
      if (resp.statusCode == 200) {
        final j = jsonDecode(resp.body) as Map<String, dynamic>;
        final reply = j['reply'] as String? ?? '';
        if (reply.isNotEmpty) {
          try {
            var jsonStr = reply.trim();
            if (jsonStr.startsWith('```')) {
              jsonStr = jsonStr.split('\n').where((l) => !l.startsWith('```')).join('\n');
            }
            final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
            return EmotionAnalysisResult(
              emotion: parsed['emotion'] as String? ?? '一般',
              confidence: (parsed['confidence'] as num?)?.toDouble() ?? 0.5,
              response: parsed['response'] as String? ?? reply,
            );
          } catch (_) {
            return EmotionAnalysisResult(emotion: '一般', confidence: 0.5, response: reply);
          }
        }
      }
    } catch (e) {
      print('[心镜] 云后端分析失败: $e');
    }
    return _offlineAnalyze(text);
  }

  // === 离线分析（后备） ===

  EmotionAnalysisResult _offlineAnalyze(String text) {
    final sanitized = _sanitizeInput(text);
    final lower = sanitized.toLowerCase();
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
    var bestEmotion = '一般';
    var bestScore = 0;
    for (final entry in emotionKeywords.entries) {
      var score = 0;
      for (final kw in entry.value) {
        if (lower.contains(kw)) score++;
      }
      if (score > bestScore) {
        bestScore = score;
        bestEmotion = entry.key;
      }
    }
    final confidence = bestScore > 0 ? (0.3 + bestScore * 0.1).clamp(0.3, 0.95) : 0.3;
    return EmotionAnalysisResult(
      emotion: bestEmotion,
      confidence: confidence,
      response: _buildResponse(bestEmotion, sanitized),
    );
  }

  String _buildResponse(String emotion, String text) {
    final responses = {
      '开心': '感受到你的喜悦！这种快乐值得被好好珍惜和记录。',
      '难过': '我理解你现在的心情，允许自己感受这份难过，它也会慢慢过去的。',
      '焦虑': '焦虑是大脑在关心你，试着做几次深呼吸，把注意力带回当下。',
      '愤怒': '愤怒是正常的情绪，试着先让自己冷静下来，问题会变得清晰。',
      '平静': '平静是一种宝贵的内在力量，享受这份宁静吧。',
      '疲惫': '你辛苦了，给自己一些时间和空间好好休息。',
      '孤独': '孤独感有时候会悄悄来访，但你并不孤单，我一直在这里。',
      '期待': '期待让生活充满希望，为你的目标加油！',
      '一般': '谢谢你的分享，每一天都是独一无二的。',
    };
    return responses[emotion] ?? '谢谢你的分享，我会一直在这里倾听。';
  }

  // === OpenAI 兼容 API 调用 ===

  Future<Map<String, dynamic>> _callApi(String userMessage) async {
    int retryCount = 0;
    Duration retryDelay = const Duration(seconds: 1);
    const maxRetries = 3;
    const backoffMultiplier = 2.0;

    while (true) {
      try {
        return await _executeApiCall(userMessage);
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) rethrow;
        final shouldRetry = e is http.ClientException || e.toString().contains('TimeoutException') || (e is Map && e['retry'] == true);
        if (!shouldRetry) rethrow;
        await Future.delayed(retryDelay);
        retryDelay = Duration(milliseconds: (retryDelay.inMilliseconds * backoffMultiplier).toInt());
      }
    }
  }

  Future<Map<String, dynamic>> _executeApiCall(String userMessage) async {
    final baseUrl = _baseUrl ?? '';
    if (baseUrl.isEmpty) throw Exception('API Base URL 未配置');
    final url = '${baseUrl.replaceAll(RegExp(r'/+$'), '')}/chat/completions';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_apiKey'},
      body: jsonEncode({
        'model': _model ?? 'gpt-4o-mini',
        'messages': [
          {'role': 'system', 'content': _systemPrompt},
          {'role': 'user', 'content': userMessage},
        ],
        'temperature': 0.7, 'max_tokens': 500,
      }),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 401) throw Exception('API Key 无效');
    if (response.statusCode != 200) throw Exception('请求失败 (${response.statusCode})');
    final body = jsonDecode(response.body);
    final content = body['choices']?[0]?['message']?['content'] as String?;
    if (content == null) throw Exception('API 返回为空');
    return _parseJsonResponse(content);
  }

  Map<String, dynamic> _parseJsonResponse(String content) {
    var jsonStr = content.trim();
    if (jsonStr.startsWith('```')) {
      jsonStr = jsonStr.split('\n').where((l) => !l.startsWith('```')).join('\n');
    }
    if (jsonStr.startsWith('{') && jsonStr.endsWith('}')) {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    }
    return {'emotion': '一般', 'confidence': 0.5, 'response': content};
  }

  String _buildAnalysisPrompt(String text) {
    final sanitized = _sanitizeInput(text);
    return '用户说："$sanitized"\n\n'
        '请分析这份情绪记录，返回如下 JSON 格式（不要包含 markdown 代码块）：\n'
        '{\n'
        '  "emotion": "情绪类型（从以下选择：开心/平静/兴奋/感恩/焦虑/难过/生气/疲惫/一般）",\n'
        '  "confidence": 0.0到1.0之间的置信度数值,\n'
        '  "response": "一段温暖、共情的回应（100字以内）"\n'
        '}\n'
        '只返回 JSON，不要其他文字。';
  }

  final String _systemPrompt =
      '你是一个温暖、专业的心理健康助手"小镜"。用户会向你倾诉他们的心情，'
      '你需要判断用户的情绪类型，给出情绪分析的 JSON。'
      '请始终保持温暖、共情、不评判的态度。';

  // === 周报和年报（使用 OpenAI 兼容 API） ===

  Future<WeeklyReportResult?> generateWeeklyReport(List<Map<String, dynamic>> weekData, {String? apiKey, String? baseUrl, String? model}) async {
    
    if (isConfigured && _baseUrl != null && _baseUrl!.isNotEmpty) {
      try {
        final prompt = _buildWeeklyReportPrompt(weekData);
        final responseMap = await _callApi(prompt);
        return WeeklyReportResult.fromJson(responseMap);
      } catch (_) {}
    }
    try {
      final p = _buildWeeklyReportPrompt(weekData);
      var resp = await http.post(Uri.parse("https://mirror-mind.onrender.com/api/chat"), headers: {"Content-Type": "application/json"}, body: jsonEncode({"messages": [{"role": "user", "content": p}]})).timeout(const Duration(seconds: 30));
      if (resp.statusCode == 200) {
        var j = jsonDecode(resp.body) as Map<String, dynamic>;
        var reply = j["reply"] as String? ?? "";
        if (reply.isNotEmpty) {
          try { return WeeklyReportResult.fromJson(jsonDecode(reply.trim()) as Map<String, dynamic>); } catch (_) {}
          return WeeklyReportResult(summary: reply, dominantEmotion: "", suggestion: "", quote: "");
        }
      }
    } catch (_) {}
    return null;
  }

  Future<YearReportResult?> generateYearReport(List<Map<String, dynamic>> yearData, {String? apiKey, String? baseUrl, String? model}) async {
    
    try {
      final prompt = _buildYearReportPrompt(yearData);
      final responseMap = await _callApi(prompt);
      return YearReportResult.fromJson(responseMap);
    } catch (_) { return null; }
  }

  String _buildWeeklyReportPrompt(List<Map<String, dynamic>> data) {
    return '请根据以下一周的情绪记录生成周报，返回 JSON 格式：\n'
        '${jsonEncode(data)}\n\n'
        '返回格式：{"summary":"一周总结","dominant_emotion":"主要情绪","suggestion":"建议","quote":"一句鼓励的话"}';
  }

  String _buildYearReportPrompt(List<Map<String, dynamic>> data) {
    return '请根据以下一年的情绪记录生成年度报告，返回 JSON 格式：\n'
        '${jsonEncode(data)}\n\n'
        '返回格式：{"keywords":["关键词1","关键词2"],"trend":"全年趋势","insight":"核心洞察","suggestion":"新年建议","avgScore":平均分}';
  }
}

// === 数据类 ===

class EmotionAnalysisResult {
  final String emotion;
  final double confidence;
  final String response;

  EmotionAnalysisResult({required this.emotion, required this.confidence, required this.response});

  factory EmotionAnalysisResult.fromJson(Map<String, dynamic> json) {
    return EmotionAnalysisResult(
      emotion: json['emotion'] as String? ?? '一般',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
      response: json['response'] as String? ?? '谢谢你的分享。',
    );
  }
}

class WeeklyReportResult {
  final String summary;
  final String dominantEmotion;
  final String suggestion;
  final String quote;

  WeeklyReportResult({required this.summary, required this.dominantEmotion, required this.suggestion, required this.quote});

  factory WeeklyReportResult.fromJson(Map<String, dynamic> json) {
    return WeeklyReportResult(
      summary: json['summary'] as String? ?? '',
      dominantEmotion: json['dominant_emotion'] as String? ?? '',
      suggestion: json['suggestion'] as String? ?? '',
      quote: json['quote'] as String? ?? '',
    );
  }
}

class YearReportResult {
  final List<String> keywords;
  final String trend;
  final String insight;
  final String suggestion;
  final double avgScore;

  YearReportResult({required this.keywords, required this.trend, required this.insight, required this.suggestion, required this.avgScore});

  factory YearReportResult.fromJson(Map<String, dynamic> json) {
    return YearReportResult(
      keywords: (json['keywords'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      trend: json['trend'] as String? ?? '',
      insight: json['insight'] as String? ?? '',
      suggestion: json['suggestion'] as String? ?? '',
      avgScore: (json['avgScore'] as num?)?.toDouble() ?? 5.0,
    );
  }
}

class AiConfigException implements Exception {
  final String message;
  const AiConfigException(this.message);
  @override String toString() => message;
}
