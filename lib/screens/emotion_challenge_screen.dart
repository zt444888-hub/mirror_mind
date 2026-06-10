import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/emotion_provider.dart';
import '../models/emotion_record.dart';
import '../services/notification_service.dart';
import '../constants/colors.dart';

/// 7天情绪挑战
class EmotionChallengeScreen extends StatefulWidget {
  const EmotionChallengeScreen({super.key});

  @override
  State<EmotionChallengeScreen> createState() => _EmotionChallengeScreenState();
}

class _EmotionChallengeScreenState extends State<EmotionChallengeScreen> {
  // 挑战状态
  int? _activeChallengeIndex; // 0/1/2 表示正在进行哪个挑战
  int _challengeDay = 0; // 当前第几天 (1-7)
  List<bool> _checkins = List.filled(7, false); // 7天打卡记录
  DateTime? _startDate;

  // SharedPreferences 键
  static const String _keyChallengeIndex = 'challenge_index';
  static const String _keyChallengeDay = 'challenge_day';
  static const String _keyCheckins = 'challenge_checkins';
  static const String _keyStartDate = 'challenge_start_date';

  // 挑战主题
  static final List<_Challenge> _challenges = [
    _Challenge(
      title: '7天积极发现',
      description: '每天找一个让自己开心的小事，记录并感受它带来的快乐',
      icon: '🔍',
      color: MirrorColors.accent,
      dailyHints: [
        '今天有没有什么让你嘴角上扬的小事？',
        '找一找今天生活中的"小确幸"',
        '今天有什么让你感到感激的事？',
        '今天谁或什么让你感到温暖？',
        '今天的哪一刻让你感觉特别美好？',
        '回顾一下今天让你开心的三个瞬间',
        '这7天里你最大的收获是什么？',
      ],
      goldenQuote: '幸福不是拥有最好的一切，而是把一切过成最好的样子。',
      badge: '🏆',
      badgeName: '积极发现者',
    ),
    _Challenge(
      title: '7天情绪觉察',
      description: '每天在早、中、晚三个时间点记录情绪，提升情绪感知力',
      icon: '🧘',
      color: MirrorColors.primary,
      dailyHints: [
        '早晨：醒来时你感受到的第一种情绪是什么？',
        '上午：工作/学习过程中你内心的变化',
        '午后：吃完午饭后心情如何？',
        '下午：和他人互动时你有怎样的感受？',
        '傍晚：即将结束一天时你的心情',
        '睡前：回顾今天三重情绪的变化',
        '这7天你对自己的情绪模式有什么新发现？',
      ],
      goldenQuote: '觉察是改变的第一步，感受情绪而不评判它。',
      badge: '🧠',
      badgeName: '情绪观察家',
    ),
    _Challenge(
      title: '7天自我关怀',
      description: '每天做一件照顾自己的事，学会温柔对待自己',
      icon: '💝',
      color: MirrorColors.warm,
      dailyHints: [
        '今天给自己做一顿健康的美食',
        '今天放下手机一小时，专心做自己喜欢的事',
        '今天对自己说一句温柔的话',
        '今天给自己一个充分的休息时间',
        '今天允许自己不完美',
        '今天做一件让自己感到舒服的小事',
        '这7天你对自己的态度有什么变化？',
      ],
      goldenQuote: '爱自己，不是自私，是终生浪漫的开始。',
      badge: '🌸',
      badgeName: '自我关怀达人',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadChallengeState();
  }

  /// 从 SharedPreferences 加载挑战状态
  Future<void> _loadChallengeState() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        final idx = prefs.getInt(_keyChallengeIndex);
        _activeChallengeIndex = idx;
        _challengeDay = prefs.getInt(_keyChallengeDay) ?? 1;
        final checkinStr = prefs.getString(_keyCheckins);
        if (checkinStr != null) {
          _checkins = checkinStr.split(',').map((e) => e == '1').toList();
        }
        final startStr = prefs.getString(_keyStartDate);
        if (startStr != null) {
          _startDate = DateTime.tryParse(startStr);
        }
      });
    }
  }

  /// 保存挑战状态
  Future<void> _saveChallengeState() async {
    final prefs = await SharedPreferences.getInstance();
    if (_activeChallengeIndex != null) {
      await prefs.setInt(_keyChallengeIndex, _activeChallengeIndex!);
      await prefs.setInt(_keyChallengeDay, _challengeDay);
      await prefs.setString(_keyCheckins, _checkins.map((e) => e ? '1' : '0').join(','));
      if (_startDate != null) {
        await prefs.setString(_keyStartDate, _startDate!.toIso8601String());
      }
    } else {
      await prefs.remove(_keyChallengeIndex);
      await prefs.remove(_keyChallengeDay);
      await prefs.remove(_keyCheckins);
      await prefs.remove(_keyStartDate);
    }
  }

  /// 开始挑战
  void _startChallenge(int index) {
    setState(() {
      _activeChallengeIndex = index;
      _challengeDay = 1;
      _checkins = List.filled(7, false);
      _startDate = DateTime.now();
    });
    _saveChallengeState();
    NotificationService().scheduleChallengeReminder(hour: 20, minute: 0);
  }

  /// 完成今日打卡
  Future<void> _checkinToday() async {
    final challenge = _challenges[_activeChallengeIndex!];
    final hint = challenge.dailyHints[_challengeDay - 1];

    // 弹出记录弹窗
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => _CheckinDialog(
        day: _challengeDay,
        hint: hint,
        challengeTitle: challenge.title,
      ),
    );

    if (result != null && result.trim().isNotEmpty && mounted) {
      // 保存打卡记录
      final record = EmotionRecord(
        date: DateTime.now(),
        emotion: '一般',
        inputText: '挑战：${challenge.title}\nDay $_challengeDay: $hint\n记录：$result',
        score: 8,
        tag: '7天挑战',
      );
      await context.read<EmotionProvider>().saveRecord(record);

      if (!mounted) return;
      setState(() {
        _checkins[_challengeDay - 1] = true;
        _challengeDay++;
        if (_challengeDay > 7) {
          // 挑战完成
          _showCompletionDialog();
        }
      });
      _saveChallengeState();
    }
  }

  /// 完成弹窗
  void _showCompletionDialog() {
    final challenge = _challenges[_activeChallengeIndex!];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Text(challenge.badge, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            const Text('挑战完成！', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '恭喜获得「${challenge.badgeName}」徽章',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              challenge.goldenQuote,
              style: const TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                height: 1.5,
                color: MirrorColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              NotificationService().cancelChallengeReminder();
              setState(() {
                _activeChallengeIndex = null;
                _challengeDay = 0;
                _checkins = List.filled(7, false);
                _startDate = null;
              });
              _saveChallengeState();
            },
            child: const Text('太棒了'),
          ),
        ],
      ),
    );
  }

  /// 放弃挑战
  void _abandonChallenge() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('放弃挑战'),
        content: const Text('确定要放弃当前挑战吗？之前的打卡记录将保留。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('继续挑战')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              NotificationService().cancelChallengeReminder();
              setState(() {
                _activeChallengeIndex = null;
                _challengeDay = 0;
                _checkins = List.filled(7, false);
                _startDate = null;
              });
              _saveChallengeState();
            },
            style: ElevatedButton.styleFrom(backgroundColor: MirrorColors.error),
            child: const Text('放弃'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? MirrorColors.darkBackground : MirrorColors.background,
      appBar: AppBar(
        title: const Text('7天挑战'),
        actions: [
          if (_activeChallengeIndex != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _abandonChallenge,
              tooltip: '放弃挑战',
            ),
        ],
      ),
      body: _activeChallengeIndex == null
          ? _buildChallengeSelection(isDark)
          : _buildChallengeActive(isDark),
    );
  }

  /// 挑战选择页
  Widget _buildChallengeSelection(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          '选择一个7天挑战主题',
          style: TextStyle(fontSize: 15, color: MirrorColors.textSecondary),
        ),
        const SizedBox(height: 16),
        ...List.generate(_challenges.length, (index) {
          final c = _challenges[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: InkWell(
                onTap: () => _startChallenge(index),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: c.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(child: Text(c.icon, style: const TextStyle(fontSize: 28))),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.title,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(c.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
                              )),
                          ],
                        ),
                      ),
                      Icon(Icons.play_arrow, color: c.color, size: 28),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  /// 挑战进行中
  Widget _buildChallengeActive(bool isDark) {
    final challenge = _challenges[_activeChallengeIndex!];
    final remaining = 7 - _challengeDay + 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 进度头部
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [challenge.color.withOpacity(0.3), challenge.color.withOpacity(0.08)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(challenge.icon, style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                Text(
                  challenge.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Day $_challengeDay / 7 · 还剩 $remaining 天',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                // 进度条
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_challengeDay - 1) / 7,
                    minHeight: 8,
                    backgroundColor: challenge.color.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(challenge.color),
                  ),
                ),
                const SizedBox(height: 12),
                // 7天打卡圆点
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(7, (i) {
                    final done = _checkins[i];
                    return Container(
                      width: 30,
                      height: 30,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done ? challenge.color : (isDark ? MirrorColors.darkSurface : MirrorColors.cardBackground),
                        border: Border.all(
                          color: done ? challenge.color : MirrorColors.textSecondary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: done
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : Center(
                              child: Text('${i + 1}',
                                style: TextStyle(fontSize: 12, color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary)),
                            ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 今日任务卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('今日任务', style: TextStyle(fontSize: 14, color: MirrorColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text(
                    challenge.dailyHints[_challengeDay - 1],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                      color: isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _challengeDay <= 7 ? _checkinToday : null,
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(_challengeDay <= 7 ? '完成打卡' : '已全部完成'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: challenge.color,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),

          // 已经完成的打卡记录
          if (_checkins.any((c) => c)) ...[
            Text('打卡记录', style: TextStyle(fontSize: 14, color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary)),
            const SizedBox(height: 8),
            ...List.generate(_challengeDay - 1, (i) {
              if (!_checkins[i]) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? MirrorColors.darkSurface : MirrorColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: MirrorColors.secondary, size: 20),
                    const SizedBox(width: 10),
                    Text('Day ${i + 1} 已完成',
                      style: TextStyle(fontSize: 14, color: isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary)),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

/// 打卡弹窗
class _CheckinDialog extends StatefulWidget {
  final int day;
  final String hint;
  final String challengeTitle;

  const _CheckinDialog({
    required this.day,
    required this.hint,
    required this.challengeTitle,
  });

  @override
  State<_CheckinDialog> createState() => _CheckinDialogState();
}

class _CheckinDialogState extends State<_CheckinDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text('Day ${widget.day} · ${widget.challengeTitle}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.hint,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 3,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '写下你的感受和发现...',
              contentPadding: EdgeInsets.all(12),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('跳过'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('完成打卡'),
        ),
      ],
    );
  }
}

/// 挑战数据类
class _Challenge {
  final String title;
  final String description;
  final String icon;
  final Color color;
  final List<String> dailyHints;
  final String goldenQuote;
  final String badge;
  final String badgeName;

  const _Challenge({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.dailyHints,
    required this.goldenQuote,
    required this.badge,
    required this.badgeName,
  });
}
