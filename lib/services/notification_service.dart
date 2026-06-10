import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// 全局 NavigatorKey，用于通知点击后导航到指定页面
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// 本地通知服务：负责每日情绪记录提醒与呼吸练习提醒
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  /// 显式单例引用（推荐在业务代码中使用以表明单例意图）
  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  // 通知 ID 常量
  static const int dailyReminderId = 1001;
  static const int breathingReminderId = 1002;
  static const int challengeReminderId = 1003;
  static const String dailyReminderChannelId = 'daily_reminder';
  static const String breathingReminderChannelId = 'breathing_reminder';
  static const String challengeReminderChannelId = 'challenge_reminder';

  // SharedPreferences 键
  static const String _keyDailyEnabled = 'notification_daily_enabled';
  static const String _keyDailyHour = 'notification_daily_hour';
  static const String _keyDailyMinute = 'notification_daily_minute';
  static const String _keyBreathingEnabled = 'notification_breathing_enabled';
  static const String _keyBreathingHour = 'notification_breathing_hour';
  static const String _keyBreathingMinute = 'notification_breathing_minute';
  static const String _keyChallengeEnabled = 'notification_challenge_enabled';
  static const String _keyChallengeHour = 'notification_challenge_hour';
  static const String _keyChallengeMinute = 'notification_challenge_minute';

  // 默认时间
  static const int defaultDailyHour = 21;
  static const int defaultDailyMinute = 0;
  static const int defaultBreathingHour = 12;
  static const int defaultBreathingMinute = 0;

  // 应用当前状态
  AppLifecycleState _appState = AppLifecycleState.resumed;

  /// 初始化通知插件（含时区数据）
  Future<void> initialize() async {
    tz.initializeTimeZones();

    // 监听应用生命周期状态变化
    WidgetsBinding.instance.addObserver(_AppLifecycleListener(this));

    // Android 通知渠道配置
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 通知权限配置
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // 创建 Android 通知渠道
    await _createAndroidChannels();
  }

  /// 更新应用状态（供外部生命周期监听器调用）
  void updateAppState(AppLifecycleState state) {
    _appState = state;
  }

  /// 检查应用是否在前台运行
  bool _isAppInForeground() {
    return _appState == AppLifecycleState.resumed;
  }

  /// 通知点击回调：导航到首页记录页
  void _onNotificationResponse(NotificationResponse response) {
    // 只有在应用处于前台时才执行导航
    if (!_isAppInForeground()) {
      // 应用在后台，不执行导航，系统会自动打开应用到当前页面
      return;
    }

    final nav = navigatorKey.currentState;
    if (nav == null) return;

    // 所有通知点击统一导航到首页（记录页）
    nav.pushNamedAndRemoveUntil('/', (route) => false);
  }

  /// 创建 Android 通知渠道
  Future<void> _createAndroidChannels() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // 每日记录提醒渠道
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          dailyReminderChannelId,
          '每日记录提醒',
          description: '每天定时提醒你记录情绪',
          importance: Importance.defaultImportance,
          enableVibration: true,
        ),
      );

      // 呼吸练习提醒渠道
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          breathingReminderChannelId,
          '呼吸练习提醒',
          description: '定时提醒你做呼吸练习',
          importance: Importance.defaultImportance,
          enableVibration: true,
        ),
      );

      // 7天挑战提醒渠道
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          challengeReminderChannelId,
          '7天挑战提醒',
          description: '每日挑战任务提醒',
          importance: Importance.defaultImportance,
          enableVibration: true,
        ),
      );
    }
  }

  // ==================== 每日记录提醒 ====================

  /// 安排每日情绪记录提醒
  Future<void> scheduleDailyReminder({required int hour, required int minute}) async {
    // 先取消已有提醒
    await _plugin.cancel(dailyReminderId);

    final now = DateTime.now();
    var scheduledDate = tz.TZDateTime.local(now.year, now.month, now.day, hour, minute);

    // 如果今天的时间已过，安排到明天
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      dailyReminderId,
      '心镜',
      '今天心情怎么样？花一分钟记录一下吧~',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          dailyReminderChannelId,
          '每日记录提醒',
          channelDescription: '每天定时提醒你记录情绪',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // 保存设置
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDailyEnabled, true);
    await prefs.setInt(_keyDailyHour, hour);
    await prefs.setInt(_keyDailyMinute, minute);
  }

  /// 取消每日记录提醒
  Future<void> cancelDailyReminder() async {
    await _plugin.cancel(dailyReminderId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDailyEnabled, false);
  }

  // ==================== 呼吸练习提醒 ====================

  /// 安排每日呼吸练习提醒
  Future<void> scheduleBreathingReminder({required int hour, required int minute}) async {
    await _plugin.cancel(breathingReminderId);

    final now = DateTime.now();
    var scheduledDate = tz.TZDateTime.local(now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      breathingReminderId,
      '心镜',
      '该做个呼吸练习放松一下了',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          breathingReminderChannelId,
          '呼吸练习提醒',
          channelDescription: '定时提醒你做呼吸练习',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBreathingEnabled, true);
    await prefs.setInt(_keyBreathingHour, hour);
    await prefs.setInt(_keyBreathingMinute, minute);
  }

  /// 取消呼吸练习提醒
  Future<void> cancelBreathingReminder() async {
    await _plugin.cancel(breathingReminderId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBreathingEnabled, false);
  }

  // ==================== 批量操作 ====================

  /// 取消所有通知
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDailyEnabled, false);
    await prefs.setBool(_keyBreathingEnabled, false);
    await prefs.setBool(_keyChallengeEnabled, false);
  }

  // ==================== 设置读取 ====================

  /// 从 SharedPreferences 读取并恢复所有通知设置
  /// 应用启动时调用
  Future<void> restoreScheduledNotifications() async {
    final prefs = await SharedPreferences.getInstance();

    // 恢复每日记录提醒
    final dailyEnabled = prefs.getBool(_keyDailyEnabled) ?? false;
    if (dailyEnabled) {
      final hour = prefs.getInt(_keyDailyHour) ?? defaultDailyHour;
      final minute = prefs.getInt(_keyDailyMinute) ?? defaultDailyMinute;
      await scheduleDailyReminder(hour: hour, minute: minute);
    }

    // 恢复呼吸练习提醒
    final breathingEnabled = prefs.getBool(_keyBreathingEnabled) ?? false;
    if (breathingEnabled) {
      final hour = prefs.getInt(_keyBreathingHour) ?? defaultBreathingHour;
      final minute = prefs.getInt(_keyBreathingMinute) ?? defaultBreathingMinute;
      await scheduleBreathingReminder(hour: hour, minute: minute);
    }

    // 恢复挑战提醒
    final challengeEnabled = prefs.getBool(_keyChallengeEnabled) ?? false;
    if (challengeEnabled) {
      final hour = prefs.getInt(_keyChallengeHour) ?? defaultDailyHour;
      final minute = prefs.getInt(_keyChallengeMinute) ?? defaultDailyMinute;
      await scheduleChallengeReminder(hour: hour, minute: minute);
    }
  }

  /// 获取每日记录提醒是否开启
  static Future<bool> isDailyEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDailyEnabled) ?? false;
  }

  /// 获取每日记录提醒时间
  static Future<Map<String, int>> getDailyTime() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'hour': prefs.getInt(_keyDailyHour) ?? defaultDailyHour,
      'minute': prefs.getInt(_keyDailyMinute) ?? defaultDailyMinute,
    };
  }

  /// 获取呼吸练习提醒是否开启
  static Future<bool> isBreathingEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyBreathingEnabled) ?? false;
  }

  /// 获取呼吸练习提醒时间
  static Future<Map<String, int>> getBreathingTime() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'hour': prefs.getInt(_keyBreathingHour) ?? defaultBreathingHour,
      'minute': prefs.getInt(_keyBreathingMinute) ?? defaultBreathingMinute,
    };
  }

  // ==================== 7天挑战提醒 ====================

  /// 安排每日挑战任务提醒
  Future<void> scheduleChallengeReminder({required int hour, required int minute}) async {
    await _plugin.cancel(challengeReminderId);

    final now = DateTime.now();
    var scheduledDate = tz.TZDateTime.local(now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      challengeReminderId,
      '心镜 · 7天挑战',
      '今天有挑战任务等你完成哦，加油！',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          challengeReminderChannelId,
          '7天挑战提醒',
          channelDescription: '每日挑战任务提醒',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyChallengeEnabled, true);
    await prefs.setInt(_keyChallengeHour, hour);
    await prefs.setInt(_keyChallengeMinute, minute);
  }

  /// 取消挑战提醒
  Future<void> cancelChallengeReminder() async {
    await _plugin.cancel(challengeReminderId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyChallengeEnabled, false);
  }

  /// 获取挑战提醒是否开启
  static Future<bool> isChallengeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyChallengeEnabled) ?? false;
  }

  /// 获取挑战提醒时间
  static Future<Map<String, int>> getChallengeTime() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'hour': prefs.getInt(_keyChallengeHour) ?? defaultDailyHour,
      'minute': prefs.getInt(_keyChallengeMinute) ?? defaultDailyMinute,
    };
  }
}

/// 应用生命周期监听器（顶层类）
class _AppLifecycleListener extends WidgetsBindingObserver {
  final NotificationService _service;

  _AppLifecycleListener(this._service);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _service.updateAppState(state);
  }
}
