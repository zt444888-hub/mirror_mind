import 'package:flutter/material.dart';

/// 心镜 App 莫兰迪色系主题色
class MirrorColors {
  MirrorColors._();

  // --- 主色调 ---
  static const primary = Color(0xFFB8A9C9);       // 薰衣草紫
  static const primaryLight = Color(0xFFD4C5E2);  // 浅紫
  static const primaryDark = Color(0xFF8E7AA6);   // 深紫

  // --- 辅助色 ---
  static const secondary = Color(0xFFC5D5CB);     // 鼠尾草绿
  static const secondaryLight = Color(0xFFDCE8E0);
  static const secondaryDark = Color(0xFFA3B8A9);

  static const accent = Color(0xFFF5D5CB);        // 杏粉色
  static const accentLight = Color(0xFFFBEAE3);
  static const accentDark = Color(0xFFE8C0B0);

  static const warm = Color(0xFFE8D5B0);          // 暖黄色
  static const warmLight = Color(0xFFF2E8D0);

  // --- 背景色 ---
  static const background = Color(0xFFFAF8F5);    // 暖白背景
  static const surface = Color(0xFFFFFFFF);
  static const cardBackground = Color(0xFFF5F2ED);

  // --- 文字色 ---
  static const textPrimary = Color(0xFF3D3D3D);
  static const textSecondary = Color(0xFF8C8C8C);
  static const textHint = Color(0xFFBFBFBF);

  // --- 深色模式 ---
  static const darkBackground = Color(0xFF1E1E2E);
  static const darkSurface = Color(0xFF2A2A3C);
  static const darkCardBackground = Color(0xFF333348);
  static const darkTextPrimary = Color(0xFFE8E8EC);
  static const darkTextSecondary = Color(0xFFA0A0B0);

  // --- 功能色 ---
  static const success = Color(0xFFA3C9A8);
  static const warning = Color(0xFFE8D5B0);
  static const error = Color(0xFFD4A5A5);

  // --- 情绪颜色映射 ---
  static const emotionHappy = Color(0xFFF5D5CB);     // 开心 - 杏粉
  static const emotionCalm = Color(0xFFC5D5CB);      // 平静 - 鼠尾草绿
  static const emotionExcited = Color(0xFFE8C9B0);   // 兴奋 - 暖橘
  static const emotionGrateful = Color(0xFFE8D5B0);  // 感恩 - 暖黄
  static const emotionAnxious = Color(0xFFD4C5E2);   // 焦虑 - 浅紫
  static const emotionSad = Color(0xFFB8C5D0);       // 难过 - 灰蓝
  static const emotionAngry = Color(0xFFD4A5A5);     // 生气 - 柔红
  static const emotionTired = Color(0xFFC5C5C5);     // 疲惫 - 浅灰
  static const emotionNeutral = Color(0xFFD5CFC0);   // 平静 - 米灰

  /// 根据情绪类型获取颜色
  static Color emotionColor(String emotion) {
    switch (emotion) {
      case '开心':
        return emotionHappy;
      case '平静':
        return emotionCalm;
      case '兴奋':
        return emotionExcited;
      case '感恩':
        return emotionGrateful;
      case '焦虑':
        return emotionAnxious;
      case '难过':
        return emotionSad;
      case '生气':
        return emotionAngry;
      case '疲惫':
        return emotionTired;
      default:
        return emotionNeutral;
    }
  }

  /// 获取情绪渐变
  static List<Color> emotionGradient(String emotion) {
    final base = emotionColor(emotion);
    return [base.withOpacity(0.7), base];
  }
}
