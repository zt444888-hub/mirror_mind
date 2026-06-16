import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emotion_provider.dart';
import '../constants/colors.dart';
import 'record_screen.dart';
import 'calendar_screen.dart';
import 'toolbox_screen.dart';
import 'ai_chat_screen.dart';
import '../services/ai_chat_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    RecordScreen(),
    CalendarScreen(),
    AiChatScreen(),
    ToolboxScreen(),
  ];

  final List<String> _titles = const ['蹇冮暅', '鎯呯华鏃ュ巻', '涓庡皬闀滃璇?, '鑷剤宸ュ叿绠?];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<EmotionProvider>();
      provider.loadLatestRecord();
      provider.loadStreak();
      provider.loadWeekRecords();
      // 棰勭儹 AI 鍚庣
      AiChatService.warmUp();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_currentIndex == 0) _buildAchievementBar(context),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index.clamp(0, _pages.length - 1)),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_outlined),
              activeIcon: Icon(Icons.auto_awesome),
              label: '璁板綍',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: '鏃ュ巻',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.self_improvement_outlined),
              activeIcon: Icon(Icons.self_improvement),
              label: '灏忛暅',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.self_improvement_outlined),
              activeIcon: Icon(Icons.self_improvement),
              label: '宸ュ叿绠?,
            ),
          ],
          selectedItemColor: MirrorColors.primaryDark,
          unselectedItemColor: MirrorColors.textSecondary,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }

  /// 椤堕儴鎴愬氨鏉★細杩炵画澶╂暟 + 寰界珷杩涘害 + 鍛ㄦ墦鍗?
  Widget _buildAchievementBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Selector<EmotionProvider, ({int consecutiveDays, int totalRecordDays})>(
      selector: (context, p) => (consecutiveDays: p.consecutiveDays, totalRecordDays: p.totalRecordDays),
      builder: (context, data, _) {
        final consecutive = data.consecutiveDays;
        final total = data.totalRecordDays;
        final badge = _getBadge(consecutive, total);
        final nextBadge = _getNextBadge(consecutive, total);
        final progress = _getProgress(consecutive, total);

        return GestureDetector(
          onTap: () => _showAchievementDialog(context, consecutive, total),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [MirrorColors.darkCardBackground, MirrorColors.darkCardBackground.withValues(alpha: 0.8)]
                    : [MirrorColors.surface, Color(0x80D4C5E2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // 绗竴琛岋細鐏劙 + 澶╂暟 + 褰撳墠寰界珷
                Row(
                  children: [
                    // 鐏劙鍔ㄧ敾鍥炬爣 (鏍规嵁澶╂暟鍙樺寲)
                    Text(
                      consecutive >= 100 ? '馃敟馃敟馃敟' :
                      consecutive >= 30 ? '馃敟馃敟' :
                      consecutive >= 7 ? '馃敟' : '鉁?,
                      style: const TextStyle(fontSize: 22),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          consecutive > 0 ? '杩炵画 $consecutive 澶? : '浠婂ぉ杩樻病鏈夎褰?,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary,
                          ),
                        ),
                        Text(
                          total > 0 ? '鍏辫褰?$total 澶?路 鐐瑰嚮鏌ョ湅鍏ㄩ儴鎴愬氨' : '寮€濮嬭褰曚綘鐨勭涓€澶╁惂',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // 褰撳墠寰界珷
                    if (badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: badge.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(badge.emoji, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 4),
                            Text(
                              badge.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: badge.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                // 绗簩琛岋細杩涘害鏉★紙鍒颁笅涓€涓窘绔狅級
                if (nextBadge != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '涓嬩竴涓細${nextBadge.emoji} ${nextBadge.label}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: nextBadge.color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: isDark ? MirrorColors.darkSurface : MirrorColors.cardBackground,
                            valueColor: AlwaysStoppedAnimation<Color>(nextBadge.color),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 鏄剧ず鎴愬氨瀵硅瘽妗?
  void _showAchievementDialog(BuildContext context, int consecutive, int total) {
    final allBadges = _allBadges();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Color(0x4DBEBEBE),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('鎴愬氨寰界珷', style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700,
                color: isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary,
              )),
              const SizedBox(height: 16),
              const Text('鍧氭寔璁板綍鎯呯华锛岃В閿佹洿澶氬窘绔狅紒', style: TextStyle(fontSize: 13, color: MirrorColors.textSecondary)),
              const SizedBox(height: 16),
              ...allBadges.map((b) {
                final unlocked = b.check(consecutive, total);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? MirrorColors.darkSurface : Color(0x14BEBEBE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(unlocked ? b.emoji : '馃敀', style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.label, style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600,
                              color: unlocked
                                  ? (isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary)
                                  : MirrorColors.textHint,
                            )),
                            Text(b.description, style: const TextStyle(
                              fontSize: 12, color: MirrorColors.textSecondary,
                            )),
                          ],
                        ),
                      ),
                      if (unlocked) const Icon(Icons.check_circle, color: MirrorColors.primary, size: 22),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],
          ),
                ),
        );
      },
    );
  }

  /// 鎵€鏈夋垚灏卞窘绔犲畾涔?
  List<_BadgeInfo> _allBadges() {
    return [
      _BadgeInfo('馃尡', '鏂拌娊', '璁板綍绗?1 澶?, Color(0xFF8DB580), (c, t) => c >= 1 || t >= 1),
      _BadgeInfo('馃尶', '鎴愰暱', '杩炵画 7 澶?, MirrorColors.primary, (c, t) => c >= 7),
      _BadgeInfo('馃尦', '绋冲浐', '杩炵画 21 澶?, MirrorColors.secondary, (c, t) => c >= 21),
      _BadgeInfo('馃尭', '缁芥斁', '杩炵画 60 澶?, const Color(0xFFE891A0), (c, t) => c >= 60),
      _BadgeInfo('馃専', '闂€€', '杩炵画 100 澶?, const Color(0xFFE8A838), (c, t) => c >= 100),
      _BadgeInfo('馃弳', '鍧氭寔', '绱 30 澶?, const Color(0xFFD4A017), (c, t) => t >= 30),
      _BadgeInfo('馃拵', '閽荤煶', '绱 100 澶?, const Color(0xFF6C5CE7), (c, t) => t >= 100),
      _BadgeInfo('馃憫', '鐜嬭€?, '绱 365 澶?, const Color(0xFFD4A017), (c, t) => t >= 365),
    ];
  }

  /// 鑾峰彇涓嬩竴涓湭瑙ｉ攣鐨勫窘绔?
  _BadgeInfo? _getNextBadge(int consecutive, int total) {
    for (final b in _allBadges()) {
      if (!b.check(consecutive, total)) return b;
    }
    return null;
  }

  /// 璁＄畻鍒颁笅涓€涓窘绔犵殑杩涘害 (0.0 ~ 1.0)
  double _getProgress(int consecutive, int total) {
    final thresholds = [
      (th: 1, useConsecutive: true),
      (th: 7, useConsecutive: true),
      (th: 21, useConsecutive: true),
      (th: 60, useConsecutive: true),
      (th: 100, useConsecutive: true),
      (th: 30, useConsecutive: false),
      (th: 100, useConsecutive: false),
      (th: 365, useConsecutive: false),
    ];
    for (final t in thresholds) {
      final current = t.useConsecutive ? consecutive : total;
      if (current < t.th) {
        // 鐪嬩笂涓€涓槇鍊?
        final prevThresholds = thresholds.where((x) =>
          (x.useConsecutive == t.useConsecutive) && 
          (t.useConsecutive ? x.th < t.th : x.th < t.th)
        ).toList();
        final prev = prevThresholds.isEmpty ? 0 : prevThresholds.last.th;
        return (current - prev) / (t.th - prev).toDouble();
      }
    }
    return 1.0;
  }

  /// 鏍规嵁杩炵画澶╂暟 / 鎬诲ぉ鏁拌繑鍥炲綋鍓嶆垚灏卞窘绔?
  _BadgeInfo? _getBadge(int consecutiveDays, int totalDays) {
    for (final b in _allBadges()) {
      if (b.check(consecutiveDays, totalDays)) {
        return b;
      }
    }
    return null;
  }
}

/// 鎴愬氨寰界珷鏁版嵁绫?
class _BadgeInfo {
  final String emoji;
  final String label;
  final String description;
  final Color color;
  final bool Function(int consecutive, int total) check;

  const _BadgeInfo(this.emoji, this.label, this.description, this.color, this.check);
}

