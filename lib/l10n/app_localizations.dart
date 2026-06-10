import 'dart:convert';

import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('zh'),
    Locale('en'),
  ];

  late Map<String, String> _localizedStrings;

  Future<void> load() async {
    final localeCode = locale.languageCode;
    String jsonString;
    switch (localeCode) {
      case 'en':
        jsonString = _englishStrings;
        break;
      case 'zh':
      default:
        jsonString = _chineseStrings;
        break;
    }

    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    _localizedStrings =
        jsonMap.map((key, value) => MapEntry(key, value.toString()));
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // ── English strings ──
  static const String _englishStrings = '''
{
  "@@locale": "en",
  "appName": "MirrorMind",
  "appSubtitle": "AI Emotion Journal — Understand yourself in 5 minutes a day",
  "featureEmotionRecord": "Emotion Record",
  "featureAIAnalysis": "AI Analysis",
  "featureEmotionCards": "Emotion Cards",
  "featureMeditation": "Meditation",
  "featureBreathingExercise": "Breathing Exercise",
  "featureEmotionVocabulary": "Emotion Vocabulary",
  "featureDailyQuestion": "Daily Question",
  "featureGratitudeDiary": "Gratitude Diary",
  "featureEmotionChallenge": "Emotion Challenge",
  "featureEmergencySupport": "Emergency Support",
  "featureToolbox": "Toolbox",
  "featurePro": "Pro",
  "buttonSave": "Save",
  "buttonShare": "Share",
  "buttonDelete": "Delete",
  "buttonStart": "Start",
  "buttonPause": "Pause",
  "buttonContinue": "Continue",
  "buttonSettings": "Settings",
  "buttonExport": "Export",
  "hintPleaseSpeak": "Please speak...",
  "hintAnalyzing": "Analyzing...",
  "hintSaveSuccess": "Saved successfully",
  "hintShareFailed": "Share failed",
  "errorNetworkFailed": "Network connection failed",
  "errorMicPermissionDenied": "Microphone permission denied",
  "errorPurchaseFailed": "Purchase failed"
}
''';

  // ── Chinese strings ──
  static const String _chineseStrings = '''
{
  "@@locale": "zh",
  "appName": "心镜 MirrorMind",
  "appSubtitle": "AI情绪日记，每天5分钟读懂自己",
  "featureEmotionRecord": "情绪记录",
  "featureAIAnalysis": "AI分析",
  "featureEmotionCards": "情绪卡片",
  "featureMeditation": "冥想",
  "featureBreathingExercise": "呼吸练习",
  "featureEmotionVocabulary": "情绪词汇",
  "featureDailyQuestion": "每日问题",
  "featureGratitudeDiary": "感恩日记",
  "featureEmotionChallenge": "情绪挑战",
  "featureEmergencySupport": "应急支持",
  "featureToolbox": "工具箱",
  "featurePro": "专业版",
  "buttonSave": "保存",
  "buttonShare": "分享",
  "buttonDelete": "删除",
  "buttonStart": "开始",
  "buttonPause": "暂停",
  "buttonContinue": "继续",
  "buttonSettings": "设置",
  "buttonExport": "导出",
  "hintPleaseSpeak": "请说话...",
  "hintAnalyzing": "正在分析...",
  "hintSaveSuccess": "保存成功",
  "hintShareFailed": "分享失败",
  "errorNetworkFailed": "网络连接失败",
  "errorMicPermissionDenied": "麦克风权限被拒绝",
  "errorPurchaseFailed": "购买失败"
}
''';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .any((l) => l.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
