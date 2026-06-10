import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/emotion_provider.dart';
import '../models/emotion_record.dart';
import '../constants/colors.dart';
import '../constants/emotions.dart';
import '../services/purchase_service.dart';

/// 心情卡片生成器：将情绪记录生成精美卡片
class MoodCardScreen extends StatefulWidget {
  const MoodCardScreen({super.key});

  @override
  State<MoodCardScreen> createState() => _MoodCardScreenState();
}

class _MoodCardScreenState extends State<MoodCardScreen> {
  final GlobalKey _cardKey = GlobalKey();
  final TextEditingController _textController = TextEditingController();

  EmotionRecord? _selectedRecord;
  int _templateIndex = 0; // 0=简约 1=文艺 2=温暖
  bool _useCustomText = false;

  static const List<String> _templateNames = ['简约', '文艺', '温暖', '渐变', '极简', '手写', '胶片'];

  // 模板配色（渐变、文字色）
  // 格式：[背景色1, 背景色2, 文字色, 边框色(可选)]
  static const List<List<Color>> _templateColors = [
    [Color(0xFFF5F0EB), Color(0xFFE8DDD0), Color(0xFF3C3C3C), Color(0x00000000)], // 简约
    [Color(0xFFE8DFF5), Color(0xFFD4C8EB), Color(0xFF3C3C3C), Color(0x00000000)], // 文艺
    [Color(0xFFFDF2E3), Color(0xFFF5D6B8), Color(0xFF3C3C3C), Color(0x00000000)], // 温暖
    [Color(0xFF1A1A2E), Color(0xFF0F3460), Color(0xFFFFFFFF), Color(0x00000000)], // 渐变
    [Color(0xFFFFFFFF), Color(0xFFFFFFFF), Color(0xFF2D3436), Color(0xFFDFE6E9)], // 极简
    [Color(0xFFFAF0E6), Color(0xFFFAF0E6), Color(0xFF2C1810), Color(0x00000000)], // 手写
    [Color(0xFF000000), Color(0xFF000000), Color(0xFFFFFFFF), Color(0xFFE17055)], // 胶片
  ];

  // 自定义配色（Pro 用户可修改）
  Color? _customBgColor;
  Color? _customTextColor;

  // 情绪装饰 Emoji 映射
  static final Map<String, List<String>> _emotionDecor = {
    '开心': ['☀️', '🌻', '🎉', '✨', '💛'],
    '平静': ['🌙', '🍃', '🧘', '🌊', '💙'],
    '悲伤': ['🌧️', '☁️', '💧', '🕯️', '🤍'],
    '愤怒': ['🌋', '⚡', '🔥', '💢', '🧡'],
    '焦虑': ['🦋', '💨', '🌀', '⏳', '💜'],
    '感恩': ['🌈', '💝', '🕊️', '🌟', '💚'],
    '期待': ['🚀', '🌅', '🎯', '💫', '❤️'],
    '疲惫': ['🛌', '🌑', '🕯️', '🫧', '🤎'],
    '一般': ['🌸', '🍀', '☕', '📝', '💭'],
  };

  @override
  void initState() {
    super.initState();
    _loadLatestRecord();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadLatestRecord() async {
    final provider = context.read<EmotionProvider>();
    await provider.loadLatestRecord();
    if (provider.latestRecord != null && mounted) {
      setState(() => _selectedRecord = provider.latestRecord);
    }
  }

  String get _displayText {
    if (_useCustomText) return _textController.text.trim();
    if (_selectedRecord != null) return _selectedRecord!.inputText ?? '';
    return '今天的心情...';
  }

  String get _displayEmotion {
    if (_selectedRecord != null) return _selectedRecord!.emotion;
    return '一般';
  }

  List<String> _getDecorEmojis() {
    return _emotionDecor[_displayEmotion] ?? _emotionDecor['一般']!;
  }

  /// 截图并分享
  Future<void> _captureAndShare() async {
    try {
      final boundary = _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();

      // 通过 share_plus 分享
      await Share.shareXFiles(
        [XFile.fromData(pngBytes, mimeType: 'image/png', name: '心镜_心情卡片.png')],
        text: '心镜 · 心情卡片',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('截图失败，请稍后重试'), backgroundColor: MirrorColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _templateColors[_templateIndex];
    // 安全获取颜色：免费模板 [bg1,bg2,text,border]，Pro 模板同理
    final decors = _getDecorEmojis();

    return Scaffold(
      backgroundColor: isDark ? MirrorColors.darkBackground : MirrorColors.background,
      appBar: AppBar(title: const Text('心情卡片')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 模板切换
            _buildTemplateSelector(isDark),
            const SizedBox(height: 16),

            // 卡片预览
            RepaintBoundary(
              key: _cardKey,
              child: _buildCardContent(colors, decors, isDark),
            ),
            const SizedBox(height: 16),

            // 自定义配色按钮（Pro）
            _buildCustomColorButton(),
            const SizedBox(height: 12),

            // 自定义文字输入
            _buildCustomTextInput(isDark),
            const SizedBox(height: 20),

            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _captureAndShare(),
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('分享'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 模板选择器（Pro 用户显示全部 7 个，免费用户仅显示前 3 个 + 锁定提示）
  Widget _buildTemplateSelector(bool isDark) {
    final isPro = PurchaseService().isPro;
    final displayCount = isPro ? _templateNames.length : 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(displayCount, (index) {
            final isSelected = _templateIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _templateIndex = index),
                child: Container(
                  margin: EdgeInsets.only(left: index > 0 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _templateColors[index][0].withOpacity(0.5)
                        : (isDark ? MirrorColors.darkSurface : MirrorColors.cardBackground),
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: MirrorColors.primary, width: 1.5)
                        : null,
                  ),
                  child: Text(
                    _templateNames[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? MirrorColors.primaryDark
                          : (isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        if (!isPro) ...[
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: MirrorColors.primaryLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Pro',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: MirrorColors.primaryDark),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '解锁 4 种精美模板 + 自定义配色',
                style: TextStyle(fontSize: 12, color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/pro'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: MirrorColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('升级', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: MirrorColors.primaryDark)),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// 根据模板索引渲染不同的卡片内容
  Widget _buildCardContent(List<Color> colors, List<String> decors, bool isDark) {
    final isPro = PurchaseService().isPro;

    // Pro 模板未解锁时显示锁定状态
    if (_templateIndex >= 3 && !isPro) {
      return _buildLockedCard(isDark);
    }

    switch (_templateIndex) {
      case 3: return _buildGradientTemplate(decors);
      case 4: return _buildMinimalTemplate(decors);
      case 5: return _buildHandwrittenTemplate(decors);
      case 6: return _buildFilmTemplate(decors);
      default: return _buildDefaultTemplate(colors, decors);
    }
  }

  /// 默认模板（0=简约 1=文艺 2=温暖）
  Widget _buildDefaultTemplate(List<Color> colors, List<String> decors) {
    final bg = (_customBgColor != null && _templateIndex < 3) ? _customBgColor! : colors[0];
    final bg2 = (_customBgColor != null && _templateIndex < 3) ? _customBgColor! : colors[1];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bg, bg2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(decors[0], style: const TextStyle(fontSize: 28)),
              const Spacer(),
              Text(decors[1], style: const TextStyle(fontSize: 24)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _formatDate(_selectedRecord?.date ?? DateTime.now()),
            style: const TextStyle(fontSize: 13, color: MirrorColors.primaryDark, letterSpacing: 1),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              EmotionType.fromLabel(_displayEmotion).emoji + ' ' + _displayEmotion,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: MirrorColors.primaryDark),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _displayText,
            style: const TextStyle(fontSize: 17, height: 1.7, color: MirrorColors.textPrimary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(decors[2], style: const TextStyle(fontSize: 20)),
              const Spacer(),
              Text(
                'MirrorMind · 心镜',
                style: TextStyle(fontSize: 11, color: MirrorColors.textSecondary.withOpacity(0.6), letterSpacing: 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 渐变模板（Pro #3）：深色渐变背景 + 白色文字 + 圆角 16
  Widget _buildGradientTemplate(List<String> decors) {
    final bg = _customBgColor ?? const Color(0xFF1A1A2E);
    final fg = _customTextColor ?? const Color(0xFFFFFFFF);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bg, const Color(0xFF16213E), const Color(0xFF0F3460)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1A1A2E).withOpacity(0.5), blurRadius: 24, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(decors[0], style: const TextStyle(fontSize: 28)),
            const Spacer(),
            Text(decors[1], style: const TextStyle(fontSize: 24)),
          ]),
          const SizedBox(height: 20),
          Text(
            _formatDate(_selectedRecord?.date ?? DateTime.now()),
            style: TextStyle(fontSize: 12, color: fg.withOpacity(0.6), letterSpacing: 2),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: fg.withOpacity(0.3), width: 1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              EmotionType.fromLabel(_displayEmotion).emoji + ' ' + _displayEmotion,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: fg),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _displayText,
            style: TextStyle(fontSize: 18, height: 1.8, color: fg, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 24),
          Row(children: [
            Text(decors[2], style: const TextStyle(fontSize: 20)),
            const Spacer(),
            Text('MirrorMind', style: TextStyle(fontSize: 10, color: fg.withOpacity(0.4), letterSpacing: 2)),
          ]),
        ],
      ),
    );
  }

  /// 极简模板（Pro #4）：纯白底色 + 细边框 + 大量留白
  Widget _buildMinimalTemplate(List<String> decors) {
    final bg = _customBgColor ?? const Color(0xFFFFFFFF);
    final fg = _customTextColor ?? const Color(0xFF2D3436);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFDFE6E9), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            _formatDate(_selectedRecord?.date ?? DateTime.now()),
            style: TextStyle(fontSize: 11, color: fg.withOpacity(0.4), letterSpacing: 3, fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 32),
          Text(
            EmotionType.fromLabel(_displayEmotion).emoji + ' ' + _displayEmotion,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: fg.withOpacity(0.6), letterSpacing: 2),
          ),
          const SizedBox(height: 24),
          Container(width: 40, height: 2, color: fg.withOpacity(0.15)),
          const SizedBox(height: 24),
          Text(
            _displayText,
            style: TextStyle(fontSize: 17, height: 1.9, color: fg, fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 40),
          Row(children: [
            Text(decors[0], style: const TextStyle(fontSize: 16)),
            const Spacer(),
            Text('心镜', style: TextStyle(fontSize: 10, color: fg.withOpacity(0.3), letterSpacing: 4)),
          ]),
        ],
      ),
    );
  }

  /// 手写模板（Pro #5）：仿纸色 + 墨水色 + 斜体 + 装饰线
  Widget _buildHandwrittenTemplate(List<String> decors) {
    final bg = _customBgColor ?? const Color(0xFFFAF0E6);
    final fg = _customTextColor ?? const Color(0xFF2C1810);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: const Color(0xFF2C1810).withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 装饰线
          Container(height: 3, width: 60, color: fg.withOpacity(0.3)),
          const SizedBox(height: 20),
          Text(
            _formatDate(_selectedRecord?.date ?? DateTime.now()),
            style: TextStyle(fontSize: 12, color: fg.withOpacity(0.5), fontStyle: FontStyle.italic, letterSpacing: 1),
          ),
          const SizedBox(height: 12),
          Text(
            EmotionType.fromLabel(_displayEmotion).emoji + ' ' + _displayEmotion,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: fg, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 20),
          // 横线装饰
          Container(height: 1, width: double.infinity, color: fg.withOpacity(0.1)),
          const SizedBox(height: 20),
          Text(
            _displayText,
            style: TextStyle(fontSize: 18, height: 1.8, color: fg, fontStyle: FontStyle.italic, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 24),
          Container(height: 1, width: double.infinity, color: fg.withOpacity(0.1)),
          const SizedBox(height: 16),
          Row(children: [
            Text(decors[0], style: const TextStyle(fontSize: 18)),
            const Spacer(),
            Text('心镜', style: TextStyle(fontSize: 10, color: fg.withOpacity(0.3), fontStyle: FontStyle.italic)),
          ]),
        ],
      ),
    );
  }

  /// 胶片模板（Pro #6）：黑色底色 + 白色文字 + 橙色日期标签
  Widget _buildFilmTemplate(List<String> decors) {
    final bg = _customBgColor ?? const Color(0xFF000000);
    final fg = _customTextColor ?? const Color(0xFFFFFFFF);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 橙色日期标签
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE17055),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              _formatDate(_selectedRecord?.date ?? DateTime.now()),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            EmotionType.fromLabel(_displayEmotion).emoji + ' ' + _displayEmotion,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: fg.withOpacity(0.7), letterSpacing: 3),
          ),
          const SizedBox(height: 28),
          Text(
            _displayText,
            style: TextStyle(fontSize: 18, height: 1.9, color: fg, fontWeight: FontWeight.w300, letterSpacing: 0.5),
          ),
          const SizedBox(height: 40),
          Row(children: [
            Text(decors[0], style: const TextStyle(fontSize: 20)),
            const Spacer(),
            Text('心镜', style: TextStyle(fontSize: 10, color: fg.withOpacity(0.3), letterSpacing: 5)),
          ]),
        ],
      ),
    );
  }

  /// 锁定卡片（Pro 未解锁时的预览占位）
  Widget _buildLockedCard(bool isDark) {
    final colors = _templateColors[_templateIndex];
    // 安全获取颜色：免费模板 [bg1,bg2,text,border]，Pro 模板同理
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: colors[0],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: MirrorColors.primaryLight.withOpacity(0.4), width: 2),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 40, color: colors[2].withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(
              _templateNames[_templateIndex],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: colors[2].withOpacity(0.6)),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/pro'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: colors[2].withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('解锁 Pro', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 自定义配色按钮（仅 Pro 可见）
  Widget _buildCustomColorButton() {
    final isPro = PurchaseService().isPro;
    if (!isPro) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: OutlinedButton.icon(
        onPressed: _showColorPicker,
        icon: const Icon(Icons.palette_outlined, size: 16),
        label: Text(_customBgColor != null ? '自定义配色 · 已设置' : '自定义配色'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: _customBgColor != null ? MirrorColors.primary : MirrorColors.primaryLight),
        ),
      ),
    );
  }

  /// 颜色选择器对话框
  void _showColorPicker() {
    final isPro = PurchaseService().isPro;
    if (!isPro) return;

    // 预设色块
    final presetColors = [
      const Color(0xFF1A1A2E), const Color(0xFF16213E), const Color(0xFF0F3460),
      const Color(0xFFFAF0E6), const Color(0xFFFFFFFF), const Color(0xFFF5F5F5),
      const Color(0xFF2C1810), const Color(0xFF2D3436), const Color(0xFF3C3C3C),
      const Color(0xFFE17055), const Color(0xFFB2BEC3), const Color(0xFF636E72),
    ];

    Color? selectedBg = _customBgColor;
    Color? selectedText = _customTextColor;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('自定义配色'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('背景色', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: MirrorColors.textSecondary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: presetColors.map((c) {
                    final isSelected = selectedBg == c;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedBg = c),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: MirrorColors.primary, width: 3) : null,
                          boxShadow: isSelected ? [BoxShadow(color: c.withOpacity(0.5), blurRadius: 8)] : [],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('文字色', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: MirrorColors.textSecondary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: presetColors.map((c) {
                    final isSelected = selectedText == c;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedText = c),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: MirrorColors.primary, width: 3) : null,
                          boxShadow: isSelected ? [BoxShadow(color: c.withOpacity(0.5), blurRadius: 8)] : [],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                // 预览
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selectedBg ?? const Color(0xFFF5F0EB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '预览效果',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: selectedText ?? const Color(0xFF3C3C3C)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() { _customBgColor = null; _customTextColor = null; });
                Navigator.pop(ctx);
              },
              child: const Text('重置默认'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _customBgColor = selectedBg;
                  _customTextColor = selectedText;
                });
                Navigator.pop(ctx);
              },
              child: const Text('确认'),
            ),
          ],
        ),
      ),
    );
  }

  /// 自定义文字输入
  Widget _buildCustomTextInput(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '自定义文字',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() {
                _useCustomText = !_useCustomText;
                if (!_useCustomText) _textController.clear();
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _useCustomText
                      ? MirrorColors.primaryLight.withOpacity(0.3)
                      : (isDark ? MirrorColors.darkSurface : MirrorColors.cardBackground),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _useCustomText ? '使用记录' : '自定义',
                  style: TextStyle(
                    fontSize: 12,
                    color: _useCustomText ? MirrorColors.primaryDark : MirrorColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_useCustomText) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _textController,
            maxLines: 3,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary,
            ),
            decoration: const InputDecoration(
              hintText: '写下想放在卡片上的话...',
              contentPadding: EdgeInsets.all(12),
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }


}
