import re

with open('lib/screens/home_screen.dart', 'r') as f:
    content = f.read()

# ========== 替换 _buildAchievementBar 和 _getBadge ==========

old = """  /// 顶部成就条：显示连续天数 + 徽章
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
      return const _BadgeInfo('👑', '王者', Color(0xFFD4A017));
    }
    if (consecutiveDays >= 100) {
      return const _BadgeInfo('🌟', '闪耀', Color(0xFFE8A838));
    }
    if (consecutiveDays >= 60) {
      return const _BadgeInfo('🌸', '绽放', Color(0xFFE891A0));
    }
    if (consecutiveDays >= 21) {
      return const _BadgeInfo('🌳', '稳固', MirrorColors.secondary);
    }
    if (consecutiveDays >= 7) {
      return const _BadgeInfo('🌿', '成长', MirrorColors.primary);
    }
    if (consecutiveDays >= 1 || totalDays >= 1) {
      return const _BadgeInfo('🌱', '新芽', Color(0xFF8DB580));
    }
    return null;
  }
}"""

new = """  /// 顶部成就条：连续天数 + 徽章进度 + 周打卡
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
                    : [MirrorColors.surface, MirrorColors.primaryLight.withValues(alpha: 0.3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // 第一行：火焰 + 天数 + 当前徽章
                Row(
                  children: [
                    // 火焰动画图标 (根据天数变化)
                    Text(
                      consecutive >= 100 ? '🔥🔥🔥' :
                      consecutive >= 30 ? '🔥🔥' :
                      consecutive >= 7 ? '🔥' : '✨',
                      style: const TextStyle(fontSize: 22),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          consecutive > 0 ? '连续 $consecutive 天' : '今天还没有记录',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary,
                          ),
                        ),
                        Text(
                          total > 0 ? '共记录 $total 天 · 点击查看全部成就' : '开始记录你的第一天吧',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // 当前徽章
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
                // 第二行：进度条（到下一个徽章）
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
                              '下一个：${nextBadge.emoji} ${nextBadge.label}',
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

  /// 显示成就对话框
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('成就徽章', style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700,
                color: isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary,
              )),
              const SizedBox(height: 16),
              const Text('坚持记录情绪，解锁更多徽章！', style: TextStyle(fontSize: 13, color: MirrorColors.textSecondary)),
              const SizedBox(height: 16),
              ...allBadges.map((b) {
                final unlocked = b.check(consecutive, total);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? MirrorColors.darkSurface : Colors.grey.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(unlocked ? b.emoji : '🔒', style: const TextStyle(fontSize: 24)),
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
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  /// 所有成就徽章定义
  List<_BadgeInfo> _allBadges() {
    return [
      _BadgeInfo('🌱', '新芽', '记录第 1 天', Color(0xFF8DB580), (c, t) => c >= 1 || t >= 1),
      _BadgeInfo('🌿', '成长', '连续 7 天', MirrorColors.primary, (c, t) => c >= 7),
      _BadgeInfo('🌳', '稳固', '连续 21 天', MirrorColors.secondary, (c, t) => c >= 21),
      _BadgeInfo('🌸', '绽放', '连续 60 天', const Color(0xFFE891A0), (c, t) => c >= 60),
      _BadgeInfo('🌟', '闪耀', '连续 100 天', const Color(0xFFE8A838), (c, t) => c >= 100),
      _BadgeInfo('🏆', '坚持', '累计 30 天', const Color(0xFFD4A017), (c, t) => t >= 30),
      _BadgeInfo('💎', '钻石', '累计 100 天', const Color(0xFF6C5CE7), (c, t) => t >= 100),
      _BadgeInfo('👑', '王者', '累计 365 天', const Color(0xFFD4A017), (c, t) => t >= 365),
    ];
  }

  /// 获取下一个未解锁的徽章
  _BadgeInfo? _getNextBadge(int consecutive, int total) {
    for (final b in _allBadges()) {
      if (!b.check(consecutive, total)) return b;
    }
    return null;
  }

  /// 计算到下一个徽章的进度 (0.0 ~ 1.0)
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
        // 看上一个阈值
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

  /// 根据连续天数 / 总天数返回当前成就徽章
  _BadgeInfo? _getBadge(int consecutiveDays, int totalDays) {
    for (final b in _allBadges()) {
      if (b.check(consecutiveDays, totalDays)) {
        return b;
      }
    }
    return null;
  }
}"""

if old in content:
    # Find where the _BadgeInfo class starts (after the last })
    # and replace the entire old section
    content = content.replace(old, new)
    
    # Now replace the _BadgeInfo class (remove old simple one, keep the new enhanced one)
    old_badge_class = """/// 成就徽章数据类
class _BadgeInfo {
  final String emoji;
  final String label;
  final Color color;

  const _BadgeInfo(this.emoji, this.label, this.color);
}"""
    
    new_badge_class = """/// 成就徽章数据类
class _BadgeInfo {
  final String emoji;
  final String label;
  final String description;
  final Color color;
  final bool Function(int consecutive, int total) check;

  const _BadgeInfo(this.emoji, this.label, this.description, this.color, this.check);
}"""
    
    if old_badge_class in content:
        content = content.replace(old_badge_class, new_badge_class)
        with open('lib/screens/home_screen.dart', 'w') as f:
            f.write(content)
        print('✅ 打卡日历 + 成就徽章系统已升级')
    else:
        print('❌ 未找到徽章类定义')
else:
    print('❌ 未找到旧代码，检查文件')
    
