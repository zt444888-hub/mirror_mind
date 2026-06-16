import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/// 心镜云后端地址
const String kCloudBaseUrl = 'https://mirror-mind.onrender.com';

class AiChatService extends ChangeNotifier {
  final List<Map<String, String>> _messages = [];
  bool _isThinking = false;
  String? _lastError;

  static const String _keyHistory = 'ai_chat_history';

  List<Map<String, String>> get messages => _messages;
  bool get isThinking => _isThinking;
  String? get lastError => _lastError;

  /// 唤醒 Render 后端（防止冷启动延迟）
  static Future<void> warmUp() async {
    try {
      await http.get(Uri.parse('$kCloudBaseUrl')).timeout(const Duration(seconds: 8));
    } catch (_) {}
  }

  Future<void> sendMessage(String text) async {
    _messages.add({'role': 'user', 'content': text});
    _isThinking = true;
    _lastError = null;
    notifyListeners();

    try {
      print('[心镜] 正在调用云后端: $kCloudBaseUrl/api/chat');
      final resp = await http
          .post(
            Uri.parse('$kCloudBaseUrl/api/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'messages': _messages.map((m) => {
                'role': m['role'],
                'content': m['content'],
              }).toList(),
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final reply = data['reply'] as String? ?? '小镜暂时无法回应~';
        _messages.add({'role': 'assistant', 'content': reply});
      } else {
        _messages.add({'role': 'assistant', 'content': '小镜暂时有点卡，稍后再试吧 🙏'});
      }
    } catch (e) {
      print('[心镜] 云后端调用失败: \$e');
      _lastError = e.toString();
      if (e is http.ClientException || e.toString().contains('SocketException')) {
        _messages.add({'role': 'assistant', 'content': '网络连接失败，请检查网络后重试 📶'});
      } else if (e.toString().contains('TimeoutException')) {
        _messages.add({'role': 'assistant', 'content': '连接超时，服务器暂时繁忙，请稍后再试 ⏳'});
      } else {
        _messages.add({'role': 'assistant', 'content': '小镜暂时有点卡，稍后再来吧 🙏'});
      }
    }

    while (_messages.length > 40) _messages.removeAt(0);
    _isThinking = false;
    notifyListeners();
    _saveHistory();
  }

  Future<void> loadHistory() async {
    try {
      print('[心镜] 正在调用云后端: $kCloudBaseUrl/api/chat');
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_keyHistory);
      if (json != null && json.isNotEmpty) {
        final d = jsonDecode(json) as List;
        _messages.clear();
        for (final item in d) {
          _messages.add({'role': item['role'], 'content': item['content']});
        }
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _messages.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHistory);
    notifyListeners();
  }

  Future<void> _saveHistory() async {
    try {
      print('[心镜] 正在调用云后端: $kCloudBaseUrl/api/chat');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyHistory, jsonEncode(_messages));
    } catch (_) {}
  }
}
