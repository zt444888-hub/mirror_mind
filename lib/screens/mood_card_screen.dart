import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/emotion_provider.dart';
import '../models/emotion_record.dart';
import '../constants/colors.dart';
import '../constants/emotions.dart';
import '../widgets/emotion_picker.dart';

class MoodCardScreen extends StatefulWidget {
  const MoodCardScreen({super.key});
  @override State<MoodCardScreen> createState() => _MoodCardScreenState();
}

class _MoodCardScreenState extends State<MoodCardScreen> {
  final GlobalKey _cardKey = GlobalKey();
  final TextEditingController _textController = TextEditingController();
  EmotionRecord? _selectedRecord;
  String _selectedEmotion = '一般';
  bool _isFlipped = false;
  int _streakDays = 0;

  static const Map<String, List<String>> _quotes = {
    '开心': ['笑容会传染，把它传下去', '快乐是世界上最划算的买卖', '今天的好心情是限量款'],
    '平静': ['心静自然凉', '安静是内心的力量', '风平浪静，心安即是归处'],
    '兴奋': ['热情是生活的燃料', '今天就是最好的日子', '趁热打铁，趁兴出发'],
    '感恩': ['感恩让平凡的日子发光', '心怀感恩，所遇皆温柔', '谢谢今天的一切'],
    '焦虑': ['焦虑说明你在乎', '一步一步来，一切都来得及', '深呼吸，此刻你是安全的'],
    '难过': ['雨会停，天会晴', '允许自己难过是另一种勇敢', '一切都会好起来的'],
    '生气': ['生气是拿别人的错误惩罚自己', '先冷静，再说', '放下怒气，轻装上阵'],
    '疲惫': ['休息不是偷懒，是充电', '累了就停下来', '照顾好自己比什么都重要'],
    '一般': ['每一天都是新的开始', '平凡的日子也值得被记录', '生活就在此时此地'],
  };

  static const Map<String, List<String>> _decors = {
    '开心': ['☀️','🌻','🎉','✨','💛'], '平静': ['🌙','🍃','🧘','🌊','💙'],
    '兴奋': ['🚀','🌅','🎯','💫','❤️'], '感恩': ['🌈','💝','🕊️','🌟','💚'],
    '焦虑': ['🦋','💨','🌀','⏳','💜'], '难过': ['🌧️','☁️','💧','🕯️','🤍'],
    '生气': ['🌋','⚡','🔥','💢','🧡'], '疲惫': ['🛌','🌑','🕯️','🫧','🤎'],
    '一般': ['🌸','🍀','☕','📝','💭'],
  };

  static const Map<String, String> _selfCare = {
    '开心': '把这份快乐分享给身边的人',
    '平静': '闭上眼睛，感受三次深呼吸',
    '兴奋': '把这份能量投入你热爱的事',
    '感恩': '给想感谢的人发一条消息',
    '焦虑': '写下担心的三件事，逐条划掉',
    '难过': '给自己泡一杯热茶慢慢喝',
    '生气': '去窗边深呼吸五次',
    '疲惫': '现在就躺下休息十分钟',
    '一般': '做一件让你微笑的小事',
  };

  static const Map<String, List<Color>> _gradients = {
    '开心': [Color(0xFFFFD93D), Color(0xFFFF6B35)],
    '平静': [Color(0xFFD4E2ED), Color(0xFFA8C5D6)],
    '兴奋': [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    '感恩': [Color(0xFFFAD0C4), Color(0xFFFFD1FF)],
    '焦虑': [Color(0xFFD5C6E0), Color(0xFFAAA1C8)],
    '难过': [Color(0xFFB8C5D0), Color(0xFF9AA8B5)],
    '生气': [Color(0xFF8B0000), Color(0xFF5C0000)],
    '疲惫': [Color(0xFF1A2A3A), Color(0xFF0D1B2A)],
    '一般': [Color(0xFFF5F0EB), Color(0xFFE8DDD0)],
  };

  @override
  void initState() {
    super.initState();
    _textController.addListener(() { if (mounted) setState(() {}); });
    _loadLatestRecord();
    _loadStreak();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadLatestRecord() async {
    final p = context.read<EmotionProvider>();
    await p.loadLatestRecord();
    if (p.latestRecord != null && mounted) {
      setState(() {
        _selectedRecord = p.latestRecord;
        _textController.text = p.latestRecord!.inputText ?? '';
        _selectedEmotion = p.latestRecord!.emotion;
      });
    }
  }

  Future<void> _loadStreak() async {
    final p = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final last = p.getString('mood_streak_last') ?? '';
    if (last == today) {
      setState(() => _streakDays = p.getInt('mood_streak') ?? 0);
    }
  }

  String get _displayText {
    var t = _textController.text.trim();
    if (t.isNotEmpty) return t;
    if (_selectedRecord != null) return _selectedRecord!.inputText ?? '';
    return '今天的心情...';
  }

  String get _displayEmotion => _selectedEmotion;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? MirrorColors.darkBackground : MirrorColors.background,
      appBar: AppBar(title: const Text('心情卡片')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          GestureDetector(
            onTap: () => setState(() => _isFlipped = !_isFlipped),
            child: RepaintBoundary(key: _cardKey, child: _isFlipped ? _buildCardBack() : _buildMoodCard()),
          ),
          const SizedBox(height: 16),
          _buildCustomTextInput(isDark),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: _captureAndShare,
              icon: const Icon(Icons.share, size: 18),
              label: const Text('分享'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            )),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton.icon(
              onPressed: _saveToDiary,
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('保存'),
              style: ElevatedButton.styleFrom(backgroundColor: MirrorColors.secondary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            )),
          ]),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  Widget _buildMoodCard() {
    final g = _gradients[_displayEmotion] ?? _gradients['一般']!;
    final em = EmotionType.fromLabel(_displayEmotion).emoji;
    final decors = _decors[_displayEmotion] ?? _decors['一般']!;
    final d1 = decors[Random().nextInt(decors.length)];
    final d2 = decors[(Random().nextInt(decors.length) + 1) % decors.length];
    final quotes = _quotes[_displayEmotion] ?? _quotes['一般']!;
    final q = quotes[DateTime.now().millisecondsSinceEpoch ~/ 1000 % quotes.length];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: g, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        border: _streakDays >= 3 ? Border.all(color: const Color(0xFFFFD700), width: 2) : null,
        boxShadow: [BoxShadow(color: g[0].withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Text('$d1 $d2', style: const TextStyle(fontSize: 20)), const Spacer(), if (_streakDays >= 3) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)), child: Text('\u{1f525} $_streakDays', style: const TextStyle(fontSize: 11, color: Colors.white)))]),
        const SizedBox(height: 16),
        Text(em, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 12),
        Text(_displayText, style: TextStyle(fontSize: 18, height: 1.7, color: _displayEmotion == '一般' ? const Color(0xFF3C3C3C) : Colors.white)),
        const SizedBox(height: 16),
        Text(q, style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: (_displayEmotion == '一般' ? const Color(0xFF3C3C3C) : Colors.white).withValues(alpha: 0.7))),
        const SizedBox(height: 8),
        Text(_formatDate(DateTime.now()), style: TextStyle(fontSize: 10, color: (_displayEmotion == '一般' ? const Color(0xFF3C3C3C) : Colors.white).withValues(alpha: 0.5))),
      ]),
    );
  }

  Widget _buildCardBack() {
    final care = _selfCare[_displayEmotion] ?? _selfCare['一般']!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFE8E0F0), Color(0xFFD4C8E8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('\u{1f4ad}', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 24),
        Text('给今天的自己', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
        const SizedBox(height: 8),
        Text(care, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, height: 1.6, color: Color(0xFF3D2C5C), fontWeight: FontWeight.w500)),
        const SizedBox(height: 24),
        Text('\u{1f446} 点击返回', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      ]),
    );
  }

  Widget _buildCustomTextInput(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(padding: EdgeInsets.only(left: 4, bottom: 8), child: Text('卡片文字', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
        Card(child: Padding(padding: const EdgeInsets.all(12), child: TextField(
          controller: _textController, autofocus: false, maxLines: 4, minLines: 2,
          style: TextStyle(fontSize: 15, height: 1.6, color: isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary),
          decoration: const InputDecoration(hintText: '写下今天的感受...', border: InputBorder.none, contentPadding: EdgeInsets.zero),
        ))),
        const SizedBox(height: 16),
        const Padding(padding: EdgeInsets.only(left: 4, bottom: 8), child: Text('选择情绪', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
            EmotionPicker(selected: _selectedEmotion, onSelected: (e) => setState(() => _selectedEmotion = e)),
      ]),
    );
  }

  Future<void> _saveToDiary() async {
    // Save streak
    final p = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final last = p.getString('mood_streak_last') ?? '';
    final yesterday = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().split('T')[0];
    final newStreak = (last == yesterday) ? (p.getInt('mood_streak') ?? 0) + 1 : 1;
    await p.setString('mood_streak_last', today);
    await p.setInt('mood_streak', newStreak);
    if (mounted) setState(() => _streakDays = newStreak);

    // Save to diary
    if (_displayText.isNotEmpty) {
      final record = EmotionRecord(
        date: DateTime.now(), emotion: _displayEmotion, inputText: _displayText, score: 7, tag: '心情卡片',
      );
      await context.read<EmotionProvider>().saveRecord(record);
    }

    // Save image
    await _captureAndSave();
  }

  Future<void> _captureAndShare() async {
    try {
      final b = _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (b == null) return;
      final i = await b.toImage(pixelRatio: 3.0);
      final d = await i.toByteData(format: ui.ImageByteFormat.png);
      if (d == null) return;
      await Share.shareXFiles([XFile.fromData(d.buffer.asUint8List(), mimeType: 'image/png', name: '心镜_心情卡片.png')], text: '心镜 · 心情卡片');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('截图失败'), backgroundColor: MirrorColors.error));
    }
  }

  Future<void> _captureAndSave() async {
    try {
      final b = _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (b == null) return;
      final i = await b.toImage(pixelRatio: 3.0);
      final d = await i.toByteData(format: ui.ImageByteFormat.png);
      if (d == null) return;
      final bytes = d.buffer.asUint8List();
      final tmp = await getTemporaryDirectory();
      final f = File('${tmp.path}/mood_card_save.png');
      await f.writeAsBytes(bytes);
      await Gal.putImage(f.path);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已保存到相册'), backgroundColor: Color(0xFF4CAF50)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('保存失败：$e'), backgroundColor: MirrorColors.error));
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
