import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// 閸忋劌鐪� NavigatorKey閿涘瞼鏁ゆ禍搴ㄢ偓姘辩叀閻愮懓鍤崥搴☆嚤閼割亜鍩岄幐鍥х暰妞ょ敻娼�
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// 閺堫剙婀撮柅姘辩叀閺堝秴濮熼敍姘崇鐠愶絾鐦￠弮銉﹀剰缂侇亣顔囪ぐ鏇熷絹闁辨帊绗岄崨鐓庢儧缂佸啩绡勯幓鎰板晪
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  /// 閺勬儳绱￠崡鏇氱伐瀵洜鏁ら敍鍫熷腹閼芥劕婀稉姘娴狅絿鐖滄稉顓濆▏閻€劋浜掔悰銊︽閸楁洑绶ラ幇蹇撴禈閿�?
  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  // 闁氨鐓� ID 鐢悂鍣�
  static const int dailyReminderId = 1001;
  static const int breathingReminderId = 1002;
  static const int challengeReminderId = 1003;
  static const String dailyReminderChannelId = 'daily_reminder';
  static const String breathingReminderChannelId = 'breathing_reminder';
  static const String challengeReminderChannelId = 'challenge_reminder';

  // SharedPreferences 闁�?
  static const String _keyDailyEnabled = 'notification_daily_enabled';
  static const String _keyDailyHour = 'notification_daily_hour';
  static const String _keyDailyMinute = 'notification_daily_minute';
  static const String _keyBreathingEnabled = 'notification_breathing_enabled';
  static const String _keyBreathingHour = 'notification_breathing_hour';
  static const String _keyBreathingMinute = 'notification_breathing_minute';
  static const String _keyChallengeEnabled = 'notification_challenge_enabled';
  static const String _keyChallengeHour = 'notification_challenge_hour';
  static const String _keyChallengeMinute = 'notification_challenge_minute';

  // 姒涙ǹ顓婚弮鍫曟？
  static const int defaultDailyHour = 21;
  static const int defaultDailyMinute = 0;
  static const int defaultBreathingHour = 12;
  static const int defaultBreathingMinute = 0;

  // 鎼存梻鏁よぐ鎾冲閻樿埖鈧�?
  AppLifecycleState _appState = AppLifecycleState.resumed;

  /// 閸掓繂顫愰崠鏍偓姘辩叀閹绘帊娆㈤敍鍫濇儓閺冭泛灏弫鐗堝祦閿�?
  Future<void> initialize() async {
    tz.initializeTimeZones();

    // 閻╂垵鎯夋惔鏃傛暏閻㈢喎鎳￠崨銊︽埂閻樿埖鈧礁褰夐崠?
    WidgetsBinding.instance.addObserver(_AppLifecycleListener(this));

    // Android 闁氨鐓″〒鐘讳壕闁板秶鐤�
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 闁氨鐓￠弶鍐闁板秶鐤�
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

    // 閸掓稑缂� Android 闁氨鐓″〒鐘讳壕
    await _createAndroidChannels();
  }

  /// 閺囧瓨鏌婃惔鏃傛暏閻樿埖鈧緤绱欐笟娑橆樆闁劎鏁撻崨钘夋噯閺堢喓娲冮崥顒€娅掔拫鍐暏閿�?
  void updateAppState(AppLifecycleState state) {
    _appState = state;
  }

  /// 濡偓閺屻儱绨查悽銊︽Ц閸氾箑婀崜宥呭酱鏉╂劘顢�
  bool _isAppInForeground() {
    return _appState == AppLifecycleState.resumed;
  }

  /// 闁氨鐓￠悙鐟板毊閸ョ偠鐨熼敍姘嚤閼割亜鍩屾＃鏍€夌拋鏉跨秿妞�?
  void _onNotificationResponse(NotificationResponse response) {
    // 閸欘亝婀侀崷銊ョ安閻€劌顦╂禍搴″閸欑増妞傞幍宥嗗⒔鐞涘苯顕遍懜?
    if (!_isAppInForeground()) {
      // 鎼存梻鏁ら崷銊ユ倵閸欏府绱濇稉宥嗗⒔鐞涘苯顕遍懜顏庣礉缁崵绮烘导姘冲殰閸斻劍澧﹀鈧惔鏃傛暏閸掓澘缍嬮崜宥夈€夐棃?
      return;
    }

    final nav = navigatorKey.currentState;
    if (nav == null) return;

    // 閹碘偓閺堝鈧氨鐓￠悙鐟板毊缂佺喍绔寸€佃壈鍩呴崚浼搭浕妞ょ绱欑拋鏉跨秿妞ょ绱�
    nav.pushNamedAndRemoveUntil('/', (route) => false);
  }

  /// 閸掓稑缂� Android 闁氨鐓″〒鐘讳壕
  Future<void> _createAndroidChannels() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // 濮ｅ繑妫╃拋鏉跨秿閹绘劙鍟嬪〒鐘讳壕
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          dailyReminderChannelId,
          '每日记录提醒',
          description: '每天定时提醒你记录情绪',
          importance: Importance.defaultImportance,
          enableVibration: true,
        ),
      );

      // 閸涚厧鎯涚紒鍐х瘎閹绘劙鍟嬪〒鐘讳壕
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          breathingReminderChannelId,
          '閸涚厧鎯涚紒鍐х瘎閹绘劙鍟�',
          description: '鐎规碍妞傞幓鎰板晪娴ｇ姴浠涢崨鐓庢儧缂佸啩绡�',
          importance: Importance.defaultImportance,
          enableVibration: true,
        ),
      );

      // 7婢垛晜瀵幋妯诲絹闁辨帗绗柆?
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

  // ==================== 濮ｅ繑妫╃拋鏉跨秿閹绘劙鍟� ====================

  /// 鐎瑰甯撳В蹇旀）閹懐鍗庣拋鏉跨秿閹绘劙鍟�
  Future<void> scheduleDailyReminder({required int hour, required int minute}) async {
    // 閸忓牆褰囧☉鍫濆嚒閺堝褰侀柋?
    await _plugin.cancel(dailyReminderId);

    final now = DateTime.now();
    var scheduledDate = tz.TZDateTime.local(now.year, now.month, now.day, hour, minute);

    // 婵″倹鐏夋禒濠傘亯閻ㄥ嫭妞傞梻鏉戝嚒鏉╁浄绱濈€瑰甯撻崚鐗堟婢�?
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      dailyReminderId,
      '心镜 · 每日记录',
      '今天过得怎么样？来记录一下你的心情吧~',
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

    // 娣囨繂鐡ㄧ拋鍓х枂
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDailyEnabled, true);
    await prefs.setInt(_keyDailyHour, hour);
    await prefs.setInt(_keyDailyMinute, minute);
  }

  /// 閸欐牗绉峰В蹇旀）鐠佹澘缍嶉幓鎰板晪
  Future<void> cancelDailyReminder() async {
    await _plugin.cancel(dailyReminderId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDailyEnabled, false);
  }

  // ==================== 閸涚厧鎯涚紒鍐х瘎閹绘劙鍟� ====================

  /// 鐎瑰甯撳В蹇旀）閸涚厧鎯涚紒鍐х瘎閹绘劙鍟�
  Future<void> scheduleBreathingReminder({required int hour, required int minute}) async {
    await _plugin.cancel(breathingReminderId);

    final now = DateTime.now();
    var scheduledDate = tz.TZDateTime.local(now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      breathingReminderId,
      '心镜 · 呼吸练习',
      '该放松一下了，来做几分钟呼吸练习吧~',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          breathingReminderChannelId,
          '閸涚厧鎯涚紒鍐х瘎閹绘劙鍟�',
          channelDescription: '鐎规碍妞傞幓鎰板晪娴ｇ姴浠涢崨鐓庢儧缂佸啩绡�',
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

  /// 閸欐牗绉烽崨鐓庢儧缂佸啩绡勯幓鎰板晪
  Future<void> cancelBreathingReminder() async {
    await _plugin.cancel(breathingReminderId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBreathingEnabled, false);
  }

  // ==================== 閹靛綊鍣洪幙宥勭稊 ====================

  /// 閸欐牗绉烽幍鈧張澶愨偓姘辩叀
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDailyEnabled, false);
    await prefs.setBool(_keyBreathingEnabled, false);
    await prefs.setBool(_keyChallengeEnabled, false);
  }

  // ==================== 鐠佸墽鐤嗙拠璇插絿 ====================

  /// 娴�?SharedPreferences 鐠囪褰囬獮鑸典划婢跺秵澧嶉張澶愨偓姘辩叀鐠佸墽鐤�
  /// 鎼存梻鏁ら崥顖氬З閺冩儼鐨熼悽?
  Future<void> restoreScheduledNotifications() async {
    final prefs = await SharedPreferences.getInstance();

    // 閹垹顦插В蹇旀）鐠佹澘缍嶉幓鎰板晪
    final dailyEnabled = prefs.getBool(_keyDailyEnabled) ?? false;
    if (dailyEnabled) {
      final hour = prefs.getInt(_keyDailyHour) ?? defaultDailyHour;
      final minute = prefs.getInt(_keyDailyMinute) ?? defaultDailyMinute;
      await scheduleDailyReminder(hour: hour, minute: minute);
    }

    // 閹垹顦查崨鐓庢儧缂佸啩绡勯幓鎰板晪
    final breathingEnabled = prefs.getBool(_keyBreathingEnabled) ?? false;
    if (breathingEnabled) {
      final hour = prefs.getInt(_keyBreathingHour) ?? defaultBreathingHour;
      final minute = prefs.getInt(_keyBreathingMinute) ?? defaultBreathingMinute;
      await scheduleBreathingReminder(hour: hour, minute: minute);
    }

    // 閹垹顦查幐鎴炲灛閹绘劙鍟�
    final challengeEnabled = prefs.getBool(_keyChallengeEnabled) ?? false;
    if (challengeEnabled) {
      final hour = prefs.getInt(_keyChallengeHour) ?? defaultDailyHour;
      final minute = prefs.getInt(_keyChallengeMinute) ?? defaultDailyMinute;
      await scheduleChallengeReminder(hour: hour, minute: minute);
    }
  }

  /// 閼惧嘲褰囧В蹇旀）鐠佹澘缍嶉幓鎰板晪閺勵垰鎯佸鈧崥?
  static Future<bool> isDailyEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDailyEnabled) ?? false;
  }

  /// 閼惧嘲褰囧В蹇旀）鐠佹澘缍嶉幓鎰板晪閺冨爼妫�
  static Future<Map<String, int>> getDailyTime() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'hour': prefs.getInt(_keyDailyHour) ?? defaultDailyHour,
      'minute': prefs.getInt(_keyDailyMinute) ?? defaultDailyMinute,
    };
  }

  /// 閼惧嘲褰囬崨鐓庢儧缂佸啩绡勯幓鎰板晪閺勵垰鎯佸鈧崥?
  static Future<bool> isBreathingEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyBreathingEnabled) ?? false;
  }

  /// 閼惧嘲褰囬崨鐓庢儧缂佸啩绡勯幓鎰板晪閺冨爼妫�
  static Future<Map<String, int>> getBreathingTime() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'hour': prefs.getInt(_keyBreathingHour) ?? defaultBreathingHour,
      'minute': prefs.getInt(_keyBreathingMinute) ?? defaultBreathingMinute,
    };
  }

  // ==================== 7婢垛晜瀵幋妯诲絹闁�?====================

  /// 鐎瑰甯撳В蹇旀）閹告垶鍨禒璇插閹绘劙鍟�
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

  /// 閸欐牗绉烽幐鎴炲灛閹绘劙鍟�
  Future<void> cancelChallengeReminder() async {
    await _plugin.cancel(challengeReminderId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyChallengeEnabled, false);
  }

  /// 閼惧嘲褰囬幐鎴炲灛閹绘劙鍟嬮弰顖氭儊瀵偓閸�?
  static Future<bool> isChallengeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyChallengeEnabled) ?? false;
  }

  /// 閼惧嘲褰囬幐鎴炲灛閹绘劙鍟嬮弮鍫曟？
  static Future<Map<String, int>> getChallengeTime() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'hour': prefs.getInt(_keyChallengeHour) ?? defaultDailyHour,
      'minute': prefs.getInt(_keyChallengeMinute) ?? defaultDailyMinute,
    };
  }
}

/// 鎼存梻鏁ら悽鐔锋嚒閸涖劍婀￠惄鎴濇儔閸ｎ煉绱欐い璺虹湴缁紮绱�
class _AppLifecycleListener extends WidgetsBindingObserver {
  final NotificationService _service;

  _AppLifecycleListener(this._service);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _service.updateAppState(state);
  }
}
