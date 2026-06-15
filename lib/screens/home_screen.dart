import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emotion_provider.dart';
import '../constants/colors.dart';
import 'record_screen.dart';
import 'calendar_screen.dart';
import 'toolbox_screen.dart';

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
    ToolboxScreen(),
  ];

  final List<String> _titles = const ['心镜', '情绪日历', '自愈工具箱'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<EmotionProvider>();
      provider.loadLatestRecord();
      provider.loadStreak();
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
          // 成就条
          _buildAchievementBar(context),
          // 主内容
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
              color: Colors.black.withValues(alpha: 0.04),
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
              label: '记录',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: '日历',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.self_improvement_outlined),
              activeIcon: Icon(Icons.self_improvement),
              label: '工具箱',
            ),
          ],
        ),
      ),
    );
  }

  /// 顶部成就条：显示连续天数 + 徽章
  Widget _buildAchievementBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Selector<EmotionProvider, ({int consecutiveDays, int totalRecordDays})>(
      selector: (context, p) => (consecutiveDays: p.consecutiveDays, totalRecordDays: p.totalRecordDays),
      builder: (context, data, _) {
        final consecutive = data.consecutiveDays;
        final total = data.totalRecordDays;
        final badge = _getBadge(consecutive, total);

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? MirrorColors.darkCardBackground : MirrorColors.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // 连续天数火焰图标
              Text(
                consecutive > 0 ? '🔥' : '📝',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                consecutive > 0 ? '连续记录 $consecutive 天' : '今天还没有记录',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              // 总记录天数
              if (total > 0)
                Text(
                  '· 共 $total 天',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
                  ),
                ),
              const Spacer(),
              // 成就徽章
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badge.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(badge.emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        badge.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: badge.color,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// 根据连续天数 / 总天数返回成就徽章
  _BadgeInfo? _getBadge(int consecutiveDays, int totalDays) {
    if (totalDays >= 365) {
      return _BadgeInfo('👑', '王者', const Color(0xFFD4A017));
    }
    if (consecutiveDays >= 100) {
      return _BadgeInfo('🌟', '闪耀', const Color(0xFFE8A838));
    }
    if (consecutiveDays >= 60) {
      return _BadgeInfo('🌸', '绽放', const Color(0xFFE891A0));
    }
    if (consecutiveDays >= 21) {
      return _BadgeInfo('🌳', '稳固', MirrorColors.secondary);
    }
    if (consecutiveDays >= 7) {
      return _BadgeInfo('🌿', '成长', MirrorColors.primary);
    }
    if (consecutiveDays >= 1 || totalDays >= 1) {
      return _BadgeInfo('🌱', '新芽', const Color(0xFF8DB580));
    }
    return null;
  }
}

/// 成就徽章数据类
class _BadgeInfo {
  final String emoji;
  final String label;
  final Color color;

  const _BadgeInfo(this.emoji, this.label, this.color);
}
