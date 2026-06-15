import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart' as ph;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  bool get isListening => _isListening;
  bool get isAvailable => _isInitialized;

  /// 初始化语音识别
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    final micStatus = await ph.Permission.microphone.request();
    if (!micStatus.isGranted) {
      // 权限被拒绝，检查是否需要引导到设置
      if (micStatus.isPermanentlyDenied) {
        // 用户已永久拒绝，记录状态以便后续引导
      }
      return false;
    }

    _isInitialized = await _speech.initialize(
      onError: (error) {
        _isListening = false;
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
        }
      },
    );
    return _isInitialized;
  }

  /// 检查麦克风权限状态
  Future<ph.PermissionStatus> checkMicPermission() async {
    return await ph.Permission.microphone.status;
  }

  /// 打开应用系统设置页面（用于引导用户开启权限）
  Future<bool> openAppSettings() async {
    try {
      return await ph.openAppSettings();
    } catch (e) {
      debugPrint('语音服务异常: \$e');
      return false;
    }
  }

  /// 开始监听，实时返回识别结果
  Future<void> startListening({
    required Function(String) onResult,
    Function(String)? onError,
  }) async {
    if (!_isInitialized) {
      final ok = await initialize();
      if (!ok) {
        onError?.call('麦克风权限未授权，请在系统设置中开启');
        return;
      }
    }

    _isListening = true;
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
          _isListening = false;
        }
      },
      localeId: 'zh_CN',
    );
  }

  /// 停止监听
  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }

  /// 取消监听
  Future<void> cancelListening() async {
    if (_isListening) {
      await _speech.cancel();
      _isListening = false;
    }
  }

  /// 释放底层语音识别资源
  Future<void> dispose() async {
    await cancelListening();
    // speech_to_text 插件没有显式的 dispose 方法，
    // 但 cancel/stop 会释放音频会话资源
  }
}
