import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emotion_provider.dart';
import '../models/emotion_record.dart';
import '../constants/colors.dart';

/// 每日一问 — 情绪盲盒：每天随机推送深度反思问题
class DailyQuestionScreen extends StatefulWidget {
  const DailyQuestionScreen({super.key});

  @override
  State<DailyQuestionScreen> createState() => _DailyQuestionScreenState();
}

class _DailyQuestionScreenState extends State<DailyQuestionScreen>
    with TickerProviderStateMixin {
  final TextEditingController _answerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 动画控制器
  late AnimationController _typewriterController;
  late AnimationController _flipController;
  late AnimationController _fadeController;

  // 状态
  _QuestionItem? _todayQuestion;
  int _displayCharCount = 0;
  bool _isFlipped = false;
  bool _isSaving = false;
  String _goldenQuote = '';


  int _consecutiveDays = 0;
  // ==================== 50 个问题库 ====================
  static final List<_QuestionItem> _questionBank = [
    // --- 自我认知 (10) ---
    const _QuestionItem('如果今天是你生命中最重要的一天，你会怎么度过？', '自我认知'),
    const _QuestionItem('你最近学到的最重要的一课是什么？', '自我认知'),
    const _QuestionItem('如果用三个词形容现在的自己，你会选什么？', '自我认知'),
    const _QuestionItem('你内心深处最害怕的是什么？你如何面对它？', '自我认知'),
    const _QuestionItem('什么事情让你觉得"这就是我"？', '自我认知'),
    const _QuestionItem('如果可以改变自己的一件事，你会改变什么？', '自我认知'),
    const _QuestionItem('你觉得自己最被低估的优点是什么？', '自我认知'),
    const _QuestionItem('上一次你为自己感到骄傲是什么时候？', '自我认知'),
    const _QuestionItem('有什么事情是你一直想做但还没开始的？', '自我认知'),
    const _QuestionItem('你觉得十年后的自己会对现在的你说什么？', '自我认知'),

    // --- 人际关系 (10) ---
    const _QuestionItem('谁是你生命中意想不到的贵人？', '人际关系'),
    const _QuestionItem('最近一次让你真心笑出声的事是什么？', '人际关系'),
    const _QuestionItem('你最想对谁说一声"谢谢"？为什么？', '人际关系'),
    const _QuestionItem('有没有一个人，改变了你的人生轨迹？', '人际关系'),
    const _QuestionItem('你觉得自己在别人眼中是什么样的人？', '人际关系'),
    const _QuestionItem('最近一次和朋友深入交流是什么时候？', '人际关系'),
    const _QuestionItem('你如何处理与他人的冲突和误解？', '人际关系'),
    const _QuestionItem('有没有一个人，你想重新联系但一直没勇气？', '人际关系'),
    const _QuestionItem('你觉得爱和被爱，哪个更重要？', '人际关系'),
    const _QuestionItem('如果可以请任何人共进晚餐，你会选谁？', '人际关系'),

    // --- 未来展望 (10) ---
    const _QuestionItem('如果可以对10年前的自己说一句话，你会说什么？', '未来展望'),
    const _QuestionItem('你对未来最大的期待是什么？', '未来展望'),
    const _QuestionItem('如果可以拥有一种超能力，你希望是什么？', '未来展望'),
    const _QuestionItem('你理想中的一天是怎样的？', '未来展望'),
    const _QuestionItem('如果不考虑现实限制，你最想做什么工作？', '未来展望'),
    const _QuestionItem('你想给这个世界留下什么？', '未来展望'),
    const _QuestionItem('明年今天，你希望自己有什么不同？', '未来展望'),
    const _QuestionItem('你最大的梦想还在吗？它是否改变了？', '未来展望'),
    const _QuestionItem('如果可以选择在任何地方生活，你会选哪里？', '未来展望'),
    const _QuestionItem('你希望自己的墓志铭上写什么？', '未来展望'),

    // --- 过往回顾 (10) ---
    const _QuestionItem('童年最温暖的记忆是什么？', '过往回顾'),
    const _QuestionItem('有没有一件事让你至今后悔？', '过往回顾'),
    const _QuestionItem('你人生中的转折点是什么？', '过往回顾'),
    const _QuestionItem('上一次哭是因为什么？', '过往回顾'),
    const _QuestionItem('你做过最勇敢的一件事是什么？', '过往回顾'),
    const _QuestionItem('有没有一个决定改变了你的人生？', '过往回顾'),
    const _QuestionItem('你最大的失败教会了你什么？', '过往回顾'),
    const _QuestionItem('如果有人给你一笔巨款，你会用它做什么？', '过往回顾'),
    const _QuestionItem('你人生中最难忘的一次旅行是？', '过往回顾'),
    const _QuestionItem('如果可以重新活一天，你会选哪一天？', '过往回顾'),

    // --- 假设想象 (10) ---
    const _QuestionItem('如果明天是世界末日，你会如何度过最后一天？', '假设想象'),
    const _QuestionItem('如果你可以隐身一天，你会做什么？', '假设想象'),
    const _QuestionItem('如果你能和任何历史人物对话，你想和谁聊什么？', '假设想象'),
    const _QuestionItem('如果你的生活是一部电影，它的名字是什么？', '假设想象'),
    const _QuestionItem('如果你变成了动物，你觉得自己会是什么？', '假设想象'),
    const _QuestionItem('如果能发明一样东西，你会发明什么？', '假设想象'),
    const _QuestionItem('如果你有一台时光机，你会回到过去还是去往未来？', '假设想象'),
    const _QuestionItem('如果幸福可以充值，你愿意用什么来交换？', '假设想象'),
    const _QuestionItem('如果你只能保留一个记忆，你会保留什么？', '假设想象'),
    const _QuestionItem('如果一个陌生人可以了解你的一件事，你希望是什么？', '假设想象'),
  ];

  // 金句库（回答后随机展示）
  static final List<String> _quotes = [
    '认识自己，是终生浪漫的开始。—— 王尔德',
    '生命中最难的不是没有人懂你，而是你不懂自己。',
    '答案不在别处，就在你诚实地面对自己的那一刻。',
    '每一次深刻的自我对话，都是一次灵魂的洗礼。',
    '你比你想象的更勇敢、更坚韧、更值得被爱。',
    '人生的意义不是被发现的，而是被创造的。',
    '接纳不完美的自己，才是真正的强大。',
    '你所经历的一切，都在塑造独一无二的你。',
    '活着本身就是最大的奇迹。',
    '今天所做的一切，都是对明天的自己说"我值得"。',
    '不必成为更好的自己，只需更好地成为自己。',
    '世界是一面镜子，你对它微笑，它就对你微笑。',
    '温柔地对待自己，就像对待最好的朋友。',
    '每一个当下，都是你余生中最年轻的一刻。',
    '所有的迷茫，都是因为你在认真地活着。',
  ];

  @override
  void initState() {
    super.initState();

    _typewriterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _loadTodayQuestion();
    _loadConsecutiveDays();
  }

  @override
  void dispose() {
    _answerController.dispose();
    _scrollController.dispose();
    _typewriterController.dispose();
    _flipController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  /// 基于日期生成今日问题
  void _loadTodayQuestion() {
    final now = DateTime.now();
    // 使用年月日组合作为种子，保证同一天问题相同
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final random = Random(seed);
    final index = random.nextInt(_questionBank.length);
    _todayQuestion = _questionBank[index];
    _goldenQuote = _quotes[random.nextInt(_quotes.length)];

    // 启动打字机动画
    _startTypewriter();
  }

  /// 打字机动画
  void _startTypewriter() {
    final question = _todayQuestion!.question;
    const interval = 60; // 每个字 60ms
    _typewriterController.duration = Duration(
      milliseconds: question.length * interval,
    );

    Timer.periodic(const Duration(milliseconds: interval), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _displayCharCount++;
        if (_displayCharCount >= question.length) {
          timer.cancel();
        }
      });
    });
  }

  /// 加载连续回答天数
  Future<void> _loadConsecutiveDays() async {
    // 简化：从数据库查询 tag 为 "每日一问" 的记录
    final provider = context.read<EmotionProvider>();
    final records = await provider.loadAllRecords();
    final questionRecords = records
        .where((r) => r.tag == '每日一问')
        .map((r) => DateTime(r.date.year, r.date.month, r.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int consecutive = 0;
    for (int i = 0; ; i++) {
      final checkDate = today.subtract(Duration(days: i));
      if (questionRecords.any((d) =>
          d.year == checkDate.year &&
          d.month == checkDate.month &&
          d.day == checkDate.day)) {
        consecutive++;
      } else {
        break;
      }
    }
    if (mounted) setState(() => _consecutiveDays = consecutive);
  }

  /// 保存回答
  Future<void> _saveAnswer() async {
    final answer = _answerController.text.trim();
    if (answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('写下你的思考吧~'), backgroundColor: MirrorColors.warm),
      );
      return;
    }

    setState(() => _isSaving = true);

    final record = EmotionRecord(
      date: DateTime.now(),
      emotion: '一般',
      inputText: '问题：${_todayQuestion!.question}\n回答：$answer',
      score: 7,
      tag: '每日一问',
    );

    final provider = context.read<EmotionProvider>();
    await provider.saveRecord(record);

    if (!mounted) return;
    setState(() {

      // _isSaved logic removed
    });

    // 翻转卡片显示金句
    _flipController.forward();
    _fadeController.forward();
    setState(() => _isFlipped = true);
    _loadConsecutiveDays();
  }

  /// 分享今日问题
  void _shareQuestion() {
    // 通过系统分享
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('长按复制问题与好友分享吧'),
        backgroundColor: MirrorColors.secondary,
      ),
    );
  }

  String _getCategoryIcon(String category) {
    switch (category) {
      case '自我认知':
        return '🪞';
      case '人际关系':
        return '💞';
      case '未来展望':
        return '🔭';
      case '过往回顾':
        return '📜';
      case '假设想象':
        return '✨';
      default:
        return '💭';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '自我认知':
        return MirrorColors.primary;
      case '人际关系':
        return MirrorColors.accent;
      case '未来展望':
        return MirrorColors.secondary;
      case '过往回顾':
        return MirrorColors.warm;
      case '假设想象':
        return const Color(0xFF9B7ED8);
      default:
        return MirrorColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final question = _todayQuestion;

    if (question == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final categoryColor = _getCategoryColor(question.category);
    final categoryIcon = _getCategoryIcon(question.category);

    return Scaffold(
      backgroundColor: isDark ? MirrorColors.darkBackground : MirrorColors.background,
      appBar: AppBar(
        title: const Text('每日一问'),
        actions: [
          if (!_isFlipped)
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: _shareQuestion,
              tooltip: '分享',
            ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 连续天数
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? MirrorColors.darkCardBackground : MirrorColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(categoryIcon, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    question.category,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: categoryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('🔥', style: TextStyle(fontSize: 14)),
                  Text(
                    '已连续回答 $_consecutiveDays 天',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 问题卡片（可翻转）
            _buildQuestionCard(isDark, question, categoryColor),

            const SizedBox(height: 24),

            // 回答区域（只在翻转前显示）
            if (!_isFlipped) _buildAnswerSection(isDark),
            if (_isFlipped) _buildGoldenQuoteCard(isDark),
          ],
        ),
      ),
    );
  }

  /// 问题卡片（毛玻璃效果 + 翻转动画）
  Widget _buildQuestionCard(bool isDark, _QuestionItem question, Color categoryColor) {
    return GestureDetector(
      onTap: _isFlipped ? () {
        _flipController.reverse();
        _fadeController.reverse();
        setState(() => _isFlipped = false);
      } : null,
      child: AnimatedBuilder(
        animation: _flipController,
        builder: (context, child) {
          final isFront = _flipController.value < 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_flipController.value * pi),
            child: isFront
                ? _buildQuestionFront(isDark, question, categoryColor)
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _buildQuestionBack(isDark),
                  ),
          );
        },
      ),
    );
  }

  /// 卡片正面：问题
  Widget _buildQuestionFront(bool isDark, _QuestionItem question, Color categoryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            categoryColor.withValues(alpha: 0.3),
            categoryColor.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _getCategoryIcon(question.category),
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            question.question.substring(
              0,
              min(_displayCharCount, question.question.length),
            ),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.6,
              color: isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          if (_displayCharCount >= question.question.length) ...[
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 2,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '写下你的答案',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 卡片背面：金句
  Widget _buildQuestionBack(bool isDark) {
    return FadeTransition(
      opacity: _fadeController,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              MirrorColors.accentLight.withValues(alpha: 0.3),
              MirrorColors.primaryLight.withValues(alpha: 0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            const Text('🌟', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 20),
            Text(
              _goldenQuote,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                height: 1.6,
                fontStyle: FontStyle.italic,
                color: isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              '感谢你的真诚回答',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 回答区域
  Widget _buildAnswerSection(bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _answerController,
              maxLines: 5,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: '写下你的思考...\n不必完美，真实就好',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveAnswer,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('保存回答'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 金句卡片
  Widget _buildGoldenQuoteCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? MirrorColors.darkCardBackground : MirrorColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            '今天的问题已回答',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '明天再来探索新的问题吧',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 问题数据类
class _QuestionItem {
  final String question;
  final String category;

  const _QuestionItem(this.question, this.category);
}
