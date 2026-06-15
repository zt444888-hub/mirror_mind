import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'constants/colors.dart';
import 'screens/home_screen.dart';
import 'screens/breathing_screen.dart';
import 'screens/cards_screen.dart';
import 'screens/gratitude_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/weekly_report_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/sleep_screen.dart';
import 'screens/horoscope_screen.dart';
import 'screens/meditation_screen.dart';
import 'screens/daily_question_screen.dart';
import 'screens/diary_list_screen.dart';
import 'screens/mood_card_screen.dart';
import 'screens/emotion_vocabulary_screen.dart';
import 'screens/emotion_challenge_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/year_report_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/pro_screen.dart';

class MirrorMindApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final bool showOnboarding;

  const MirrorMindApp({
    super.key,
    required this.navigatorKey,
    this.showOnboarding = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: '心镜 MirrorMind',
          debugShowCheckedModeBanner: false,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: showOnboarding ? const OnboardingScreen() : const SplashScreen(),
          routes: {
            '/splash': (_) => const SplashScreen(),
            '/home': (_) => const HomeScreen(),
            '/onboarding': (_) => const OnboardingScreen(),
            '/breathing': (_) => const BreathingScreen(),
            '/cards': (_) => const CardsScreen(),
            '/gratitude': (_) => const GratitudeScreen(),
            '/emergency': (_) => const EmergencyScreen(),
            '/weekly_report': (_) => const WeeklyReportScreen(),
            '/meditation': (_) => const MeditationScreen(),
            '/daily-question': (_) => const DailyQuestionScreen(),
            '/diary-list': (_) => const DiaryListScreen(),
            '/mood-card': (_) => const MoodCardScreen(),
            '/emotion-vocabulary': (_) => const EmotionVocabularyScreen(),
            '/emotion-challenge': (_) => const EmotionChallengeScreen(),
            '/calendar': (_) => const CalendarScreen(),
            '/year_report': (_) => const YearReportScreen(),
        '/sleep': (_) => const SleepScreen(),
        '/horoscope': (_) => const HoroscopeScreen(),
            '/settings': (_) => const SettingsScreen(),
            '/pro': (context) => Builder(
              builder: (context) {
                final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                return ProScreen(hint: args?['hint']);
              },
            ),
          },
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: MirrorColors.primary,
        primary: MirrorColors.primary,
        secondary: MirrorColors.secondary,
        surface: MirrorColors.surface,
      ),
      scaffoldBackgroundColor: MirrorColors.background,
      cardTheme: CardThemeData(
        color: MirrorColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: MirrorColors.background,
        elevation: 0,
        centerTitle: true,
        foregroundColor: MirrorColors.textPrimary,
        titleTextStyle: TextStyle(
          color: MirrorColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MirrorColors.surface,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: MirrorColors.primary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: MirrorColors.textHint, fontSize: 15),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MirrorColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: MirrorColors.primaryDark),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: MirrorColors.cardBackground,
        selectedColor: MirrorColors.primaryLight,
        labelStyle: const TextStyle(fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: MirrorColors.primaryDark,
        unselectedItemColor: MirrorColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: MirrorColors.primary,
        primary: MirrorColors.primaryLight,
        secondary: MirrorColors.secondaryLight,
        surface: MirrorColors.darkSurface,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: MirrorColors.darkBackground,
      cardTheme: CardThemeData(
        color: MirrorColors.darkCardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: MirrorColors.darkBackground,
        elevation: 0,
        centerTitle: true,
        foregroundColor: MirrorColors.darkTextPrimary,
        titleTextStyle: TextStyle(
          color: MirrorColors.darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MirrorColors.darkSurface,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: MirrorColors.primaryLight, width: 1.5),
        ),
        hintStyle: const TextStyle(color: MirrorColors.darkTextSecondary, fontSize: 15),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: MirrorColors.darkSurface,
        selectedColor: MirrorColors.primaryDark,
        labelStyle: const TextStyle(fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }
}
