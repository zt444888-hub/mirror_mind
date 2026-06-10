import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/emotion_provider.dart';
import 'providers/settings_provider.dart';
import 'services/notification_service.dart';
import 'services/purchase_service.dart';
import 'l10n/app_localizations.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化通知服务（含 navigatorKey 回调支持）
  await NotificationService.instance.initialize();
  await NotificationService.instance.restoreScheduledNotifications();

  // 初始化购买服务
  final purchaseService = PurchaseService();
  await purchaseService.initialize();

  // 初始化设置持久化
  final settings = SettingsProvider();
  await settings.init();

  // 添加应用生命周期监听，确保退出时释放资源
  WidgetsBinding.instance.addObserver(_AppLifecycleObserver(purchaseService));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => settings),
        ChangeNotifierProvider(create: (_) => EmotionProvider()),
      ],
      child: const LocalizedMirrorMindApp(),
    ),
  );
}

/// 应用生命周期观察者，确保资源正确释放
class _AppLifecycleObserver extends WidgetsBindingObserver {
  final PurchaseService _purchaseService;

  _AppLifecycleObserver(this._purchaseService);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached) {
      // 应用完全退出时释放资源
      _purchaseService.dispose();
    }
  }
}

class LocalizedMirrorMindApp extends StatelessWidget {
  const LocalizedMirrorMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localeListResolutionCallback: (locales, supportedLocales) {
        for (final locale in locales ?? <Locale>[]) {
          if (AppLocalizations.supportedLocales
              .any((l) => l.languageCode == locale.languageCode)) {
            return locale;
          }
        }
        return const Locale('zh');
      },
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const _RootApp(),
    );
  }
}

class _RootApp extends StatefulWidget {
  const _RootApp();

  @override
  State<_RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<_RootApp> {
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('onboarding_completed') ?? false;
    if (mounted) {
      setState(() => _showOnboarding = !completed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MirrorMindApp(
      navigatorKey: navigatorKey,
      showOnboarding: _showOnboarding,
    );
  }
}
