import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/purchase_service.dart';

/// 冥想引导页：文字引导 + Canvas 计时器 + 柔和动画
class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with TickerProviderStateMixin {
  // 预设时长选项（秒）
  static const List<int> _durationOptions = [300, 600, 900, 1200, 1800]; // 5, 10, 15, 20, 30分钟
  
  // 获取时长显示文字
  String _getDurationLabel(int seconds) {
    if (seconds < 60) return '$seconds 秒';
    return '${seconds ~/ 60} 分钟';
  }

  // 冥想模式定义
  static final List<_MeditationMode> _modes = [
    const _MeditationMode(
      title: '晨间唤醒',
      description: '开启美好一天',
      icon: Icons.wb_sunny_outlined,
      color: Color(0xFFD4A574),
      defaultDuration: 180,
      phrases: [
        '闭上眼睛，感受清晨的气息',
        '感恩新的一天，生命中的礼物',
        '设定今天的意图，你想要怎样的体验',
        '深呼吸三次，让能量充满全身',
        '感受阳光温暖你的肌肤',
        '慢慢睁开眼睛，带着平静开始新的一天',
      ],
    ),
    const _MeditationMode(
      title: '午间小憩',
      description: '为下午充电',
      icon: Icons.wb_cloudy_outlined,
      color: MirrorColors.primary,
      defaultDuration: 300,
      phrases: [
        '找一个舒适的姿势，闭上眼睛',
        '关注你的呼吸，自然的节奏',
        '吸气...感受空气进入身体',
        '呼气...释放上午的疲惫',
        '从头到脚做一次身体扫描',
        '放松你的肩膀，放下紧绷',
        '放松你的背部，舒展脊椎',
        '感受此刻的宁静',
        '让思绪像云朵一样飘过',
        '慢慢地回到当下，带着清醒与能量',
      ],
    ),
    const _MeditationMode(
      title: '睡前放松',
      description: '温柔入睡',
      icon: Icons.nightlight_round,
      color: Color(0xFF7B8BA6),
      defaultDuration: 300,
      phrases: [
        '放慢你的呼吸节奏',
        '释放今天所有的压力与疲惫',
        '感受身体渐渐沉入床垫',
        '让每一个细胞都放松下来',
        '回顾今天值得感恩的三个瞬间',
        '感谢今天的自己，你已经足够努力',
        '放下对明天的担忧',
        '想象温暖的光拥抱你的全身',
        '每一次呼吸都带你更深地放松',
        '安心地进入梦乡',
      ],
    ),
    // Pro 功能 ↓
    if (!PurchaseService().isPro) return const SizedBox.shrink();
    const _MeditationMode(
      title: '焦虑缓解',
      description: '平复紧张情绪',
      icon: Icons.wind_power,
      color: Color(0xFF6BB3A5),
      defaultDuration: 300,
      phrases: [
        '找一个安静的地方，坐下或躺下',
        '将手放在腹部，感受呼吸的起伏',
        '吸气数秒，感受腹部像气球一样鼓起',
        '呼气数秒，慢慢释放所有的紧张',
        '当焦虑出现时，只是观察它，不评判',
        '想象焦虑像一片乌云，慢慢飘走',
        '重复：我此刻是安全的，一切都会好起来',
        '感受双脚与地面的连接，找回稳定感',
        '继续深呼吸，让平静充满内心',
        '当准备好时，慢慢睁开眼睛',
      ],
    ),
    const _MeditationMode(
      title: '压力释放',
      description: '卸下身心负担',
      icon: Icons.anchor,
      color: Color(0xFF8FA8D0),
      defaultDuration: 600,
      phrases: [
        '以舒适的姿势坐下，闭上眼睛',
        '回忆今天或最近让你感到压力的事情',
        '承认这些压力的存在，不抗拒',
        '想象将压力写在一张纸上',
        '现在，把这张纸揉成一团',
        '想象将它扔进垃圾桶，彻底扔掉',
        '感受身体变得轻盈，压力正在离开',
        '深呼吸，吸入平静，呼出压力',
        '重复几次，直到感觉轻松一些',
        '感谢自己释放了这些负担',
      ],
    ),
    const _MeditationMode(
      title: '感恩冥想',
      description: '培养感恩之心',
      icon: Icons.favorite_outline,
      color: Color(0xFFE8A8A8),
      defaultDuration: 300,
      phrases: [
        '闭上眼睛，回忆今天发生的美好小事',
        '感恩阳光、空气和水，给予生命滋养',
        '感恩身边的人，他们的陪伴和支持',
        '感恩自己的身体，它一直在努力工作',
        '感恩遇到的挑战，它们让你成长',
        '感恩此刻的平静，这是一份礼物',
        '在心里默念：谢谢你，谢谢你，谢谢你',
        '感受感恩之情在心中升起',
        '将这份感恩传递给每一个人',
        '慢慢睁开眼睛，带着感恩的心继续一天',
      ],
    ),
    // --- Pro 模式 ---
    const _MeditationMode(
      title: '专注力训练',
      description: '深度聚焦',
      icon: Icons.center_focus_strong,
      color: Color(0xFF5B8C85),
      defaultDuration: 600,
      isPro: true,
      phrases: [
        '找到一个舒适的坐姿，轻轻闭上眼睛',
        '把注意力带到自然的呼吸上，不要控制它',
        '开始数呼吸：吸气...1...呼气...2...',
        '当思绪飘走时，不需要责备自己',
        '温柔地把注意力带回呼吸，重新开始数数',
        '感受每一次呼吸带来的安定与平静',
        '继续关注呼吸的节奏，一呼一吸',
        '如果数到10，从1重新开始',
        '感受专注力像肌肉一样在锻炼中变强',
        '慢慢睁开眼睛，带着这份清明回到当下',
      ],
    ),
    const _MeditationMode(
      title: '身体扫描',
      description: '深度放松',
      icon: Icons.accessibility_new,
      color: Color(0xFF8B6F9E),
      defaultDuration: 900,
      isPro: true,
      phrases: [
        '平躺或舒适地坐着，闭上眼睛',
        '把注意力带到双脚，感受脚底与地面的接触',
        '缓缓向上移动注意力到双腿，感受腿部的重量',
        '关注腹部，感受呼吸时腹部的起伏',
        '把注意力带到胸部，感受心跳的节奏',
        '放松肩膀，放下所有的紧绷和压力',
        '感受颈部与头部，让每一个部位都放松下来',
        '从头到脚做一次完整的扫描',
        '感受身体作为一个整体的轻松与和谐',
        '如果某个部位紧绷，深呼吸把放松带到那里',
        '再次扫描全身，感受放松的深度',
        '慢慢活动手指脚趾，带着觉察回到当下',
      ],
    ),
    const _MeditationMode(
      title: '慈悲冥想',
      description: '滋养心灵',
      icon: Icons.volunteer_activism,
      color: Color(0xFFC48793),
      defaultDuration: 600,
      isPro: true,
      phrases: [
        '找到一个舒适的姿势，闭上眼睛',
        '把手轻轻放在心口，感受心的温度',
        '默念：愿我平安，愿我健康，愿我快乐',
        '想象一个你深爱的人，默念：愿你平安，愿我健康，愿你快乐',
        '想象一个普通的朋友或熟人，同样送出祝福',
        '想象一个与你有矛盾的人，尝试送出慈悲与理解',
        '将这份慈悲扩展到所有认识的人',
        '最后，祝愿世界上的每一个人平安、健康、快乐',
        '感受慈悲从心里流淌出来，温暖你自己',
        '慢慢睁开眼睛，带着这份慈悲回到日常',
      ],
    ),
    const _MeditationMode(
      title: '自我关爱',
      description: '接纳与善待自己',
      icon: Icons.self_improvement,
      color: Color(0xFFD4A5B7),
      defaultDuration: 600,
      isPro: true,
      phrases: [
        '以温柔的方式对待自己，像对待好朋友一样',
        '找一个安静的空间，闭上眼睛',
        '把手放在心口，感受心脏的跳动',
        '默念：我值得被爱，我足够好',
        '回忆自己的优点和成就，肯定自己',
        '原谅自己的不足和错误，它们让你成长',
        '想象给自己一个温暖的拥抱',
        '感受这份自我关爱的能量',
        '承诺每天都要善待自己',
        '慢慢睁开眼睛，带着这份爱继续前行',
      ],
    ),
    const _MeditationMode(
      title: '正念呼吸',
      description: '活在当下',
      icon: Icons.air_outlined,
      color: Color(0xFF7AB893),
      defaultDuration: 600,
      isPro: true,
      phrases: [
        '以舒适的姿势坐下，挺直腰背',
        '将注意力集中在鼻尖，感受呼吸的进出',
        '不试图改变呼吸，只是观察它',
        '吸气时感受空气的清凉，呼气时感受温暖',
        '当思绪飘走时，轻轻拉回来',
        '不评判，不执着，只是觉察',
        '感受呼吸的自然节奏，一呼一吸',
        '让所有的念头像云朵一样飘过',
        '专注于此刻，专注于呼吸',
        '慢慢睁开眼睛，保持这份觉察',
      ],
    ),
    const _MeditationMode(
      title: '情绪平衡',
      description: '找回内心平静',
      icon: Icons.balance,
      color: Color(0xFF9AA5D1),
      defaultDuration: 900,
      isPro: true,
      phrases: [
        '安静地坐下，感受当下的情绪',
        '不抗拒任何情绪，只是允许它存在',
        '给情绪命名：这是愤怒，这是悲伤，这是喜悦',
        '感受情绪在身体中的位置',
        '深呼吸，让情绪随着呼吸流动',
        '想象情绪像水一样流过你的身体',
        '接纳所有的情绪，它们都是你的一部分',
        '感受情绪逐渐平静下来',
        '找回内心的平衡与宁静',
        '带着这份平静回到当下',
      ],
    ),
  ];

  // 状态变量
  _MeditationMode? _selectedMode;
  int? _selectedDuration; // 用户选择的时长（秒）
  Timer? _timer;
  Timer? _phraseTimer;
  late AnimationController _progressController;
  late AnimationController _fadeController;

  int _elapsedSeconds = 0;
  int _currentPhraseIndex = 0;
  bool _isPlaying = false;
  bool _isCompleted = false;
  bool _showDurationPicker = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phraseTimer?.cancel();
    _progressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // 选择模式并显示时长选择器
  void _selectMode(_MeditationMode mode) {
    if (mode.isPro && !PurchaseService().isPro) {
      Navigator.pushNamed(
        context,
        '/pro',
        arguments: {'hint': '解锁高级冥想，包含专注力训练、身体扫描等专业课程'},
      );
      return;
    }
    setState(() {
      _selectedMode = mode;
      _selectedDuration = mode.defaultDuration;
      _showDurationPicker = true;
    });
  }

  // 开始冥想
  void _startMeditation() {
    final mode = _selectedMode!;
    final durationSeconds = _selectedDuration ?? mode.defaultDuration;

    setState(() {
      _elapsedSeconds = 0;
      _currentPhraseIndex = 0;
      _isPlaying = true;
      _isCompleted = false;
      _showDurationPicker = false;
    });

    _progressController.duration = Duration(seconds: durationSeconds);
    _progressController.forward(from: 0);

    _fadeController.forward(from: 0);

    // 计算引导文字切换间隔
    final phraseInterval = durationSeconds ~/ mode.phrases.length;

    // 每秒更新计时器
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _elapsedSeconds++;
        final effectiveDuration = _selectedDuration ?? _selectedMode!.defaultDuration;
        if (_elapsedSeconds >= effectiveDuration) {
          _completeMeditation();
        }
      });
    });

    // 根据时长动态调整引导文字切换频率
    _phraseTimer = Timer.periodic(Duration(seconds: phraseInterval), (_) {
      if (!mounted || _isCompleted) return;
      _fadeController.reverse().then((_) {
        if (!mounted) return;
        setState(() {
          _currentPhraseIndex =
              (_currentPhraseIndex + 1) % _selectedMode!.phrases.length;
        });
        _fadeController.forward();
      });
    });
  }

  // 完成冥想
  void _completeMeditation() {
    _timer?.cancel();
    _phraseTimer?.cancel();
    _progressController.stop();
    setState(() {
      _isPlaying = false;
      _isCompleted = true;
    });
    _showCompletionDialog();
  }

  // 暂停
  void _pause() {
    _timer?.cancel();
    _phraseTimer?.cancel();
    _progressController.stop();
    setState(() => _isPlaying = false);
  }

  // 继续
  void _resume() {
    setState(() => _isPlaying = true);

    final mode = _selectedMode!;
    final effectiveDuration = _selectedDuration ?? mode.defaultDuration;
    _progressController.duration = Duration(seconds: effectiveDuration);
    _progressController.forward(
      from: _elapsedSeconds / effectiveDuration,
    );

    final phraseInterval = effectiveDuration ~/ mode.phrases.length;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _elapsedSeconds++;
        final effectiveDuration = _selectedDuration ?? _selectedMode!.defaultDuration;
        if (_elapsedSeconds >= effectiveDuration) {
          _completeMeditation();
        }
      });
    });

    _phraseTimer = Timer.periodic(Duration(seconds: phraseInterval), (_) {
      if (!mounted || _isCompleted) return;
      _fadeController.reverse().then((_) {
        if (!mounted) return;
        setState(() {
          _currentPhraseIndex =
              (_currentPhraseIndex + 1) % _selectedMode!.phrases.length;
        });
        _fadeController.forward();
      });
    });
  }

  // 返回模式选择
  void _backToModeSelection() {
    _timer?.cancel();
    _phraseTimer?.cancel();
    _progressController.reset();
    _fadeController.reset();
    setState(() {
      _selectedMode = null;
      _selectedDuration = null;
      _elapsedSeconds = 0;
      _currentPhraseIndex = 0;
      _isPlaying = false;
      _isCompleted = false;
      _showDurationPicker = false;
    });
  }

  // 完成弹窗
  void _showCompletionDialog() {
    final mode = _selectedMode!;
    final effectiveDuration = _selectedDuration ?? mode.defaultDuration;
    final minutes = effectiveDuration ~/ 60;
    final seconds = effectiveDuration % 60;
    final durationStr = minutes > 0 ? '$minutes 分钟' : '$seconds 秒';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.self_improvement, color: MirrorColors.primary, size: 28),
            SizedBox(width: 10),
            Text('冥想完成'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '你做得很棒',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '本次冥想：$durationStr',
              style: const TextStyle(fontSize: 14, color: MirrorColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              '模式：${mode.title}',
              style: const TextStyle(fontSize: 14, color: MirrorColors.textSecondary),
            ),
            const SizedBox(height: 16),
            const Text(
              '花一点时间感受此刻的平静，带着这份宁静继续你的一天。',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: MirrorColors.textSecondary, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _backToModeSelection();
            },
            child: const Text('完成'),
          ),
        ],
      ),
    );
  }

  // 格式化时间
  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? MirrorColors.darkBackground : MirrorColors.background,
      appBar: AppBar(
        title: const Text('冥想引导'),
        leading: _showDurationPicker
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _backToModeSelection,
              )
            : null,
        actions: [
          if (_selectedMode != null && !_showDurationPicker)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _backToModeSelection,
              tooltip: '重新选择',
            ),
        ],
      ),
      body: SafeArea(
        child: _showDurationPicker
            ? _buildDurationPicker(isDark)
            : _selectedMode == null
                ? _buildModeSelection(isDark)
                : _buildMeditationSession(isDark),
      ),
    );
  }

  /// 模式选择页
  Widget _buildModeSelection(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            '选择一种冥想模式',
            style: TextStyle(fontSize: 15, color: MirrorColors.textSecondary),
          ),
        ),
        ...List.generate(_modes.length, (index) {
          final mode = _modes[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: InkWell(
                onTap: () => _selectMode(mode),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: mode.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(mode.icon, color: mode.color, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    mode.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (mode.isPro)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: MirrorColors.primaryLight.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Pro',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: MirrorColors.primaryDark),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_getDurationLabel(mode.defaultDuration)} · ${mode.description}',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? MirrorColors.darkTextSecondary
                                    : MirrorColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: mode.color,
                        size: 24,
                      ),
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

  /// 时长选择页
  Widget _buildDurationPicker(bool isDark) {
    final mode = _selectedMode!;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // 模式信息卡片
        Card(
          margin: const EdgeInsets.only(bottom: 24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: mode.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(mode.icon, color: mode.color, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mode.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mode.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? MirrorColors.darkTextSecondary
                              : MirrorColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 标题
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            '选择冥想时长',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),

        // 时长选项网格
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            // 默认时长选项（放在第一个）
            _buildDurationButton(mode.defaultDuration, mode, isDark, isDefault: true),
            // 其他预设时长选项
            ..._durationOptions
                .where((d) => d != mode.defaultDuration)
                .map((duration) => _buildDurationButton(duration, mode, isDark)),
          ],
        ),

        const SizedBox(height: 32),

        // 开始按钮
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _startMeditation,
            style: ElevatedButton.styleFrom(
              backgroundColor: mode.color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
            child: const Text(
              '开始冥想',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  /// 时长选项按钮
  Widget _buildDurationButton(int duration, _MeditationMode mode, bool isDark, {bool isDefault = false}) {
    final isSelected = _selectedDuration == duration;

    return ElevatedButton(
      onPressed: () => setState(() => _selectedDuration = duration),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? mode.color
            : (isDark ? MirrorColors.darkCardBackground : MirrorColors.cardBackground),
        foregroundColor: isSelected ? Colors.white : (isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected
              ? BorderSide.none
              : BorderSide(
                  color: isDark ? MirrorColors.textSecondary : MirrorColors.textHint,
                  width: 1,
                ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isDefault)
            const Icon(Icons.check, size: 16),
          if (isDefault)
            const SizedBox(width: 6),
          Text(
            _getDurationLabel(duration),
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 冥想进行中
  Widget _buildMeditationSession(bool isDark) {
    final mode = _selectedMode!;
    final currentPhrase = mode.phrases[_currentPhraseIndex];
    final effectiveDuration = _selectedDuration ?? mode.defaultDuration;

    return Column(
      children: [
        const Spacer(flex: 2),

        // Canvas 倒计时圆环
        SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 背景圆环
              CustomPaint(
                size: const Size(220, 220),
                painter: _CirclePainter(
                  progress: 1.0,
                  color: mode.color.withValues(alpha: 0.1),
                  strokeWidth: 6,
                ),
              ),
              // 进度圆环
              if (_elapsedSeconds > 0)
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, _) {
                    final progress = _elapsedSeconds / effectiveDuration;
                    return CustomPaint(
                      size: const Size(220, 220),
                      painter: _CirclePainter(
                        progress: progress,
                        color: mode.color,
                        strokeWidth: 6,
                      ),
                    );
                  },
                ),
              // 中心文字
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(_elapsedSeconds),
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w300,
                      color: isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(effectiveDuration),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),

        // 引导文字（淡入淡出动画）
        SizedBox(
          height: 80,
          child: FadeTransition(
            opacity: _fadeController,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                currentPhrase,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          mode.title,
          style: TextStyle(
            fontSize: 13,
            color: mode.color,
            fontWeight: FontWeight.w600,
          ),
        ),

        const Spacer(),

        // 控制按钮
        Padding(
          padding: const EdgeInsets.only(bottom: 60),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 重置
              IconButton(
                onPressed: _backToModeSelection,
                icon: const Icon(Icons.replay),
                iconSize: 28,
                color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
              ),
              const SizedBox(width: 24),
              // 播放/暂停
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: mode.color,
                  boxShadow: [
                    BoxShadow(
                      color: mode.color.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _isPlaying ? _pause : _resume,
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              const SizedBox(width: 48), // 占位保持居中
            ],
          ),
        ),
      ],
    );
  }
}

/// 冥想模式数据类
class _MeditationMode {
  final String title;
  final String description;
  final int defaultDuration;
  final IconData icon;
  final Color color;
  final List<String> phrases;
  final bool isPro;

  const _MeditationMode({
    required this.title,
    required this.description,
    required this.defaultDuration,
    required this.icon,
    required this.color,
    required this.phrases,
    this.isPro = false,
  });
}

/// Canvas 绘制倒计时圆环
class _CirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CirclePainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - strokeWidth / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // 从顶部（-π/2）开始绘制弧线
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CirclePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
