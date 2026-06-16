import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// 蹇冮暅浜戝悗绔湴鍧€
const String kCloudBaseUrl = 'https://mirror-mind.onrender.com';

class AiChatService extends ChangeNotifier {
  final _secureStorage = const FlutterSecureStorage();
  final List<Map<String, String>> _messages = [];
  bool _isThinking = false;
  String? _lastError;

  static const String _keyHistory = 'ai_chat_history';

  List<Map<String, String>> get messages => _messages;
  bool get isThinking => _isThinking;
  String? get lastError => _lastError;

  /// 鍞ら啋 Render 鍚庣锛堥槻姝㈠喎鍚姩寤惰繜锛?
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
      debugPrint('[蹇冮暅] 姝ｅ湪璋冪敤浜戝悗绔? $kCloudBaseUrl/api/chat');
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
        final reply = data['reply'] as String? ?? '灏忛暅鏆傛椂鏃犳硶鍥炲簲~';
        _messages.add({'role': 'assistant', 'content': reply});
      } else {
        _messages.add({'role': 'assistant', 'content': '灏忛暅鏆傛椂鏈夌偣鍗★紝绋嶅悗鍐嶈瘯鍚?馃檹'});
      }
    } catch (e) {
      debugPrint('[蹇冮暅] 浜戝悗绔皟鐢ㄥけ璐? \$e');
      _lastError = e.toString();
      if (e is http.ClientException || e.toString().contains('SocketException')) {
        _messages.add({'role': 'assistant', 'content': '缃戠粶杩炴帴澶辫触锛岃妫€鏌ョ綉缁滃悗閲嶈瘯 馃摱'});
      } else if (e.toString().contains('TimeoutException')) {
        _messages.add({'role': 'assistant', 'content': '杩炴帴瓒呮椂锛屾湇鍔″櫒鏆傛椂绻佸繖锛岃绋嶅悗鍐嶈瘯 鈴?});
      } else {
        _messages.add({'role': 'assistant', 'content': '灏忛暅鏆傛椂鏈夌偣鍗★紝绋嶅悗鍐嶆潵鍚?馃檹'});
      }
    }

    while (_messages.length > 40) _messages.removeAt(0);
    _isThinking = false;
    notifyListeners();
    _saveHistory();
  }

  Future<void> loadHistory() async {
    try {
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyHistory, jsonEncode(_messages));
    } catch (_) {}
  }
}


