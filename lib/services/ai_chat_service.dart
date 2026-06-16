import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


/// 心镜云后端地址
/// 部署 Zeabur 后替换为你的域名
/// 例如: https://xxx.zeabur.app
const String kCloudBaseUrl = 'https://mirror-mind-api.zt444888.workers.dev

class AiChatService extends ChangeNotifier {
  String? _baseUrl;
  String? _apiKey;
  String? _model;
  bool _isAiCloud = false;
  bool _isThinking = false;
  String? _lastError;
  final List<Map<String, String>> _messages = [];

  static const String _keyHistory = 'ai_chat_history';

  List<Map<String, String>> get messages => _messages;
  bool get isThinking => _isThinking;
  String? get lastError => _lastError;
  bool get isConfigured => _isAiCloud || (_apiKey != null && _apiKey!.isNotEmpty);

  void syncConfig({String? baseUrl, String? apiKey, String? model, bool isPro = false}) {
    _baseUrl = baseUrl; _apiKey = apiKey; _model = model; _isAiCloud = isPro;
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (!isConfigured) { _lastError = '请配置 API Key 或升级心镜 Pro'; notifyListeners(); return; }
    _messages.add({'role': 'user', 'content': text});
    _isThinking = true; _lastError = null; notifyListeners();
    try {
      String response;
      // 优先走云后端
      try {
        response = await _callCloudApi(text);
      } catch (e) {
        if (_apiKey != null && _apiKey!.isNotEmpty) {
          try { response = await _callApi(text); }
          catch (_) { response = _offlineReply(text); }
        } else {
          await Future.delayed(const Duration(milliseconds: 600));
          response = _offlineReply(text);
        }
      }
      _messages.add({'role': 'assistant', 'content': response});
      if (_messages.length > 40) _messages.removeRange(0, _messages.length - 40);
      await _saveHistory();
    } catch (e) { _lastError = e.toString(); }
    finally { _isThinking = false; notifyListeners(); }
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyHistory);
    if (json != null && json.isNotEmpty) {
      try { final d = jsonDecode(json) as List; _messages.clear(); for (final item in d) { _messages.add({'role': item['role'], 'content': item['content']}); } } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _messages.clear(); final prefs = await SharedPreferences.getInstance(); await prefs.remove(_keyHistory); notifyListeners();
  }

  /// 调用云后端（走你的服务器，用户零配置）
  Future<String> _callCloudApi(String text) async {
    final url = '$kCloudBaseUrl/api/chat';
    final msgs = _messages.take(20).map((m) => ({
      'role': m['role'],
      'content': m['content'],
    })).toList();

    final resp = await http
        .post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'messages': msgs}),
        )
        .timeout(const Duration(seconds: 15));

    if (resp.statusCode == 429) {
      return '今天的免费额度用完啦，明天再来吧~ 🌸';
    }
    if (resp.statusCode != 200) {
      throw Exception('后端错误: ${resp.statusCode}');
    }

    final body = jsonDecode(resp.body);
    return body['reply'] as String? ?? '小镜暂时无法回应~';
  }

  Future<String> _callApi(String text) async {
    final url = '${(_baseUrl ?? '').replaceAll(RegExp(r'/+$'), '')}/chat/completions';
    final msgs = [
      {'role': 'system', 'content': '你是"小镜"，温暖共情的AI陪伴者。用中文回答，每次不超过80字。先共情再引导。'},
      {'role': 'user', 'content': text},
    ];
    final resp = await http.post(Uri.parse(url), headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_apiKey'},
      body: jsonEncode({'model': _model ?? 'gpt-4o-mini', 'messages': msgs, 'temperature': 0.8, 'max_tokens': 300})).timeout(const Duration(seconds: 20));
    if (resp.statusCode == 401) throw Exception('API Key 无效');
    if (resp.statusCode != 200) throw Exception('请求失败 (\${resp.statusCode})');
    final body = jsonDecode(resp.body);
    return (body['choices']?[0]?['message']?['content'] as String?)?.trim() ?? '小镜暂时无法回应~';
  }

  String _offlineReply(String text) {
    final r = Random(text.length + DateTime.now().millisecondsSinceEpoch ~/ 10000);
    final pool = {'开心': ['听你这么说真开心！😊', '能感受到你的快乐 ✨'], '难过': ['抱抱你，我在这里 🫂', '谢谢你愿意分享 🤍'],
      '焦虑': ['先做三次深呼吸好吗？🌿', '慢慢来，我陪着你 🫶']};
    String cat = '一般';
    for (final e in pool.entries) { if (text.contains(e.key)) { cat = e.key; break; } }
    if (cat == '一般') return ['想聊聊今天发生了什么吗？🌸', '我在这儿听着呢 🍃', '今天有什么想说的吗？☕'][r.nextInt(3)];
    return pool[cat]![r.nextInt(pool[cat]!.length)];
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHistory, jsonEncode(_messages.map((m) => {'role': m['role'], 'content': m['content']}).toList()));
  }
}
