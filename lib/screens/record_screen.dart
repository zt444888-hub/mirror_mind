import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emotion_provider.dart';
import '../providers/settings_provider.dart';
import '../models/emotion_record.dart';
import '../services/speech_service.dart';
import '../constants/colors.dart';
import '../constants/emotions.dart';
import '../widgets/emotion_picker.dart';
import '../widgets/mood_slider.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _diaryTitleController = TextEditingController();
  final TextEditingController _diaryContentController = TextEditingController();
  final SpeechService _speechService = SpeechService();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  String _selectedEmotion = '一般';
  int _selectedScore = 5;
  String? _selectedTag;
  String? _aiResponse;
  double _aiConfidence = 0.0;
  bool _isAnalyzed = false;
  bool _isSaving = false;
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initSpeech();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_textFocus);
    });
  }

  late final FocusNode _textFocus = FocusNode();

  Future<void> _initSpeech() async {
    final available = await _speechService.initialize();
    if (mounted) {
      setState(() => _speechAvailable = available);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _diaryTitleController.dispose();
    _diaryContentController.dispose();
    _speechService.dispose();
    _textFocus.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _analyzeText() async {
    final text = _tabController.index == 0
        ? _textController.text.trim()
        : _diaryContentController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先输入今天的心情'), backgroundColor: MirrorColors.warm),
      );
      return;
    }

    final settings = context.read<SettingsProvider>();
    if (!settings.isApiConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请先在设置页配置 API Key'),
          backgroundColor: MirrorColors.warning,
          action: SnackBarAction(label: '去设置', textColor: Colors.white, onPressed: _navigateToSettings),
        ),
      );
      return;
    }

    final provider = context.read<EmotionProvider>();
    provider.updateAiConfig(
      baseUrl: settings.baseUrl,
      apiKey: settings.apiKey,
      model: settings.model,
    );

    final result = await provider.analyzeText(text);

    if (!mounted) return;

    if (provider.aiError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.aiError!), backgroundColor: MirrorColors.error),
      );
      provider.clearAiError();
      return;
    }

    if (result != null) {
      setState(() {
        _selectedEmotion = result.emotion;
        _aiConfidence = result.confidence;
        _aiResponse = result.response;
        _isAnalyzed = true;
      });
    }
  }

  void _navigateToSettings() {
    Navigator.pushNamed(context, '/settings');
  }

  Future<void> _startListening() async {
    if (_isListening) {
      await _speechService.stopListening();
      if (!mounted) return;
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await _speechService.startListening(
        onResult: (text) {
          if (mounted) {
            setState(() {
              _textController.text = (_textController.text + text).trim();
              _isListening = false;
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() => _isListening = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error), backgroundColor: MirrorColors.error),
            );
          }
        },
      );
    }
  }

  Future<void> _saveRecord() async {
    final isDiaryMode = _tabController.index == 1;
    final diaryTitle = _diaryTitleController.text.trim();
    final diaryContent = _diaryContentController.text.trim();
    final text = isDiaryMode
        ? (diaryTitle.isNotEmpty
            ? '标题：$diaryTitle\n内容：$diaryContent'
            : '内容：$diaryContent')
        : _textController.text.trim();

    if (text.isEmpty || (isDiaryMode && diaryContent.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先记录今天的心情'), backgroundColor: MirrorColors.warm),
      );
      return;
    }

    setState(() => _isSaving = true);

    final record = EmotionRecord(
      date: DateTime.now(),
      emotion: _selectedEmotion,
      inputText: text,
      aiResponse: _aiResponse,
      confidence: _aiConfidence,
      score: _selectedScore,
      tag: isDiaryMode ? '深度日记' : _selectedTag,
    );

    final provider = context.read<EmotionProvider>();
    await provider.saveRecord(record);

    if (!mounted) return;
    setState(() => _isSaving = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _buildSavedDialog(ctx),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.of(context).pop();
      _resetForm();
    });
  }

  Widget _buildSavedDialog(BuildContext ctx) {
    final emoji = EmotionType.fromLabel(_selectedEmotion).emoji;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: MirrorColors.emotionColor(_selectedEmotion).withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('记录已保存', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              '今天的情绪被温柔地收藏了',
              style: TextStyle(color: Theme.of(ctx).brightness == Brightness.dark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _textController.clear();
      _diaryTitleController.clear();
      _diaryContentController.clear();
      _selectedEmotion = '一般';
      _selectedScore = 5;
      _selectedTag = null;
      _aiResponse = null;
      _aiConfidence = 0.0;
      _isAnalyzed = false;
    });
    FocusScope.of(context).requestFocus(_textFocus);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAnalyzing = context.select<EmotionProvider, bool>((p) => p.isAnalyzing);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          // Tab 切换栏
          Container(
            margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            decoration: BoxDecoration(
              color: isDark ? MirrorColors.darkSurface : MirrorColors.cardBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: MirrorColors.primaryLight.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: MirrorColors.primaryDark,
              unselectedLabelColor: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
              labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: '快速记录'),
                Tab(text: '深度日记'),
              ],
              onTap: (_) => setState(() {}),
            ),
          ),
          // 主内容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildQuickRecord(isDark, isAnalyzing),
                _buildDeepDiary(isDark, isAnalyzing),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 快速记录模式
  Widget _buildQuickRecord(bool isDark, bool isAnalyzing) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildScoreSection(isDark),
          const SizedBox(height: 24),
          _buildQuickInputSection(isDark, isAnalyzing),
          const SizedBox(height: 16),
          if (_isAnalyzed && _aiResponse != null) _buildAiResult(isDark),
          if (_isAnalyzed && _aiResponse != null) const SizedBox(height: 20),
          _buildEmotionSection(isDark),
          const SizedBox(height: 20),
          _buildTagSection(isDark),
          const SizedBox(height: 32),
          _buildSaveButton(isAnalyzing),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// 深度日记模式
  Widget _buildDeepDiary(bool isDark, bool isAnalyzing) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 温暖提示
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  MirrorColors.warm.withOpacity(0.15),
                  MirrorColors.accentLight.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              '写给自己的信\n今天发生了什么事？有什么想对自己说的？不必完美，真实就好。',
              style: TextStyle(fontSize: 14, height: 1.6, color: MirrorColors.textSecondary),
            ),
          ),

          // 标题输入
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _diaryTitleController,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: '给今天的日记起个标题（可选）',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 长文输入
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _diaryContentController,
                maxLines: 8,
                minLines: 5,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.7,
                  color: isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: '今天发生了什么事？有什么想对自己说的？',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // AI 分析结果
          if (_isAnalyzed && _aiResponse != null) _buildAiResult(isDark),
          if (_isAnalyzed && _aiResponse != null) const SizedBox(height: 16),

          // 情绪选择
          _buildEmotionSection(isDark),
          const SizedBox(height: 20),

          // 操作按钮行
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: TextButton.icon(
                    onPressed: isAnalyzing ? null : _analyzeText,
                    icon: isAnalyzing
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.auto_awesome, size: 18),
                    label: Text(isAnalyzing ? '分析中...' : 'AI 分析'),
                    style: TextButton.styleFrom(
                      backgroundColor: MirrorColors.primaryLight.withOpacity(0.3),
                      foregroundColor: MirrorColors.primaryDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSaveButton(isAnalyzing),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 日记列表入口
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/diary-list'),
              icon: const Icon(Icons.menu_book, size: 18),
              label: const Text('我的日记'),
              style: OutlinedButton.styleFrom(
                foregroundColor: MirrorColors.warm,
                side: BorderSide(color: MirrorColors.warm.withOpacity(0.4)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildScoreSection(bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('情绪评分', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: MirrorColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$_selectedScore / 10',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MirrorColors.primaryDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            MoodSlider(
              value: _selectedScore,
              onChanged: (val) => setState(() => _selectedScore = val),
            ),
          ],
        ),
      ),
    );
  }

  /// 快速记录输入区域
  Widget _buildQuickInputSection(bool isDark, bool isAnalyzing) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              focusNode: _textFocus,
              maxLines: 3,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: '今天心情怎么样？一句话就好...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _speechAvailable
                    ? GestureDetector(
                        onTap: _startListening,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _isListening ? MirrorColors.primary : MirrorColors.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _isListening ? Icons.mic : Icons.mic_none_outlined,
                            color: _isListening ? Colors.white : MirrorColors.textSecondary,
                            size: 22,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                SizedBox(
                  height: 40,
                  child: TextButton.icon(
                    onPressed: isAnalyzing ? null : _analyzeText,
                    icon: isAnalyzing
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.auto_awesome, size: 18),
                    label: Text(isAnalyzing ? '分析中...' : 'AI 分析'),
                    style: TextButton.styleFrom(
                      backgroundColor: MirrorColors.primaryLight.withOpacity(0.3),
                      foregroundColor: MirrorColors.primaryDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiResult(bool isDark) {
    return Card(
      color: MirrorColors.primaryLight.withOpacity(0.15),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, size: 16, color: MirrorColors.primaryDark),
                const SizedBox(width: 6),
                const Text('AI 分析', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: MirrorColors.primaryDark)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: MirrorColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(_aiConfidence * 100).toInt()}%',
                    style: const TextStyle(fontSize: 11, color: MirrorColors.primaryDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _aiResponse ?? '',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text('选择情绪', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
        EmotionPicker(
          selected: _selectedEmotion,
          onSelected: (emotion) => setState(() => _selectedEmotion = emotion),
        ),
      ],
    );
  }

  Widget _buildTagSection(bool isDark) {
    final tags = TagType.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text('标签（可选）', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tags.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final tag = tags[index];
              final isSelected = _selectedTag == tag.label;
              return GestureDetector(
                onTap: () => setState(() => _selectedTag = isSelected ? null : tag.label),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? MirrorColors.primaryLight : (isDark ? MirrorColors.darkSurface : MirrorColors.cardBackground),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(tag.icon, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(tag.label, style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? MirrorColors.primaryDark : (isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary),
                      )),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(bool isAnalyzing) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveRecord,
        child: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text('保存记录'),
      ),
    );
  }
}
