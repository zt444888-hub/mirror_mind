import 'dart:io';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/emotion_provider.dart';
import '../models/emotion_record.dart';
import '../constants/colors.dart';
import '../constants/emotions.dart';
import '../services/purchase_service.dart';

/// 蹇冩儏鍗＄墖鐢熸垚鍣細灏嗘儏缁褰曠敓鎴愮簿缇庡崱鐗?
class MoodCardScreen extends StatefulWidget {
  const MoodCardScreen({super.key});

  @override
  State<MoodCardScreen> createState() => _MoodCardScreenState();
}

class _MoodCardScreenState extends State<MoodCardScreen> {
  final GlobalKey _cardKey = GlobalKey();
  final TextEditingController _textController = TextEditingController();

  EmotionRecord? _selectedRecord;
  int _templateIndex = 0;
  bool _showAllTemplates = false; // 0=绠€绾?1=鏂囪壓 2=娓╂殩
  bool _useCustomText = false;

  static const List<String> _templateNames = ['绠€绾?, '鏂囪壓', '娓╂殩', '娓愬彉', '鏋佺畝', '鎵嬪啓', '鑳剁墖', '绯栨灉', '妫灄', '鏆楀'];

  // 妯℃澘閰嶈壊锛堟笎鍙樸€佹枃瀛楄壊锛?
  // 鏍煎紡锛歔鑳屾櫙鑹?, 鑳屾櫙鑹?, 鏂囧瓧鑹? 杈规鑹?鍙€?]
  static const List<List<Color>> _templateColors = [
    [Color(0xFFF5F0EB), Color(0xFFE8DDD0), Color(0xFF3C3C3C), Color(0x00000000)], // 绠€绾?
    [Color(0xFFE8DFF5), Color(0xFFD4C8EB), Color(0xFF3C3C3C), Color(0x00000000)], // 鏂囪壓
    [Color(0xFFFDF2E3), Color(0xFFF5D6B8), Color(0xFF3C3C3C), Color(0x00000000)], // 娓╂殩
    [Color(0xFF1A1A2E), Color(0xFF0F3460), Color(0xFFFFFFFF), Color(0x00000000)], // 娓愬彉
    [Color(0xFFFFFFFF), Color(0xFFFFFFFF), Color(0xFF2D3436), Color(0xFFDFE6E9)], // 鏋佺畝
    [Color(0xFFFAF0E6), Color(0xFFFAF0E6), Color(0xFF2C1810), Color(0x00000000)], // 鎵嬪啓
    [Color(0xFF000000), Color(0xFF000000), Color(0xFFFFFFFF), Color(0xFFE17055)], // 鑳剁墖
  [Color(0xFFFFF0F5), Color(0xFFFFD6E0), Color(0xFF6B4E71), Color(0x00000000)], // 绯栨灉
  [Color(0xFFE8F5E9), Color(0xFFC8E6C9), Color(0xFF1B5E20), Color(0xFF81C784)], // 妫灄
  [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFFE8E8E8), Color(0xFF0F3460)], // 鏆楀
  ];

  // 鑷畾涔夐厤鑹诧紙Pro 鐢ㄦ埛鍙慨鏀癸級
  Color? _customBgColor;
  Color? _customTextColor;

  // 鎯呯华瑁呴グ Emoji 鏄犲皠
  static final Map<String, List<String>> _emotionDecor = {
    '寮€蹇?: ['鈽€锔?, '馃尰', '馃帀', '鉁?, '馃挍'],
    '骞抽潤': ['馃寵', '馃崈', '馃', '馃寠', '馃挋'],
    '鎮蹭激': ['馃導锔?, '鈽侊笍', '馃挧', '馃暞锔?, '馃'],
    '鎰ゆ€?: ['馃寢', '鈿?, '馃敟', '馃挗', '馃А'],
    '鐒﹁檻': ['馃', '馃挩', '馃寑', '鈴?, '馃挏'],
    '鎰熸仼': ['馃寛', '馃挐', '馃晩锔?, '馃専', '馃挌'],
    '鏈熷緟': ['馃殌', '馃寘', '馃幆', '馃挮', '鉂わ笍'],
    '鐤叉儷': ['馃泴', '馃寫', '馃暞锔?, '馃', '馃'],
    '涓€鑸?: ['馃尭', '馃崁', '鈽?, '馃摑', '馃挱'],
  };

  @override
  void initState() {
    super.initState();
    _showAllTemplates = PurchaseService().isPro;
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
    return '浠婂ぉ鐨勫績鎯?..';
  }

  String get _displayEmotion {
    if (_selectedRecord != null) return _selectedRecord!.emotion;
    return '涓€鑸?;
  }

  List<String> _getDecorEmojis() {
    return _emotionDecor[_displayEmotion] ?? _emotionDecor['涓€鑸?]!;
  }

  /// 鎴浘骞跺垎浜?
  Future<void> _captureAndShare() async {
    try {
      final boundary = _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();

      // 閫氳繃 share_plus 鍒嗕韩
      await Share.shareXFiles(
        [XFile.fromData(pngBytes, mimeType: 'image/png', name: '蹇冮暅_蹇冩儏鍗＄墖.png')],
        text: '蹇冮暅 路 蹇冩儏鍗＄墖',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('鎴浘澶辫触锛岃绋嶅悗閲嶈瘯'), backgroundColor: MirrorColors.error),
        );
      }
    }
  }

  /// 鎴浘骞朵繚瀛樺埌鐩稿唽
  Future<void> _captureAndSave() async {
    try {
      final boundary = _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/mood_card_save.png');
      await file.writeAsBytes(pngBytes);
      await Gal.putImage(file.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('鉁?宸蹭繚瀛樺埌鐩稿唽'),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('淇濆瓨澶辫触锛?e'), backgroundColor: MirrorColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _templateColors[_templateIndex];
    // 瀹夊叏鑾峰彇棰滆壊锛氬厤璐规ā鏉?[bg1,bg2,text,border]锛孭ro 妯℃澘鍚岀悊
    final decors = _getDecorEmojis();

    return Scaffold(
      backgroundColor: isDark ? MirrorColors.darkBackground : MirrorColors.background,
      appBar: AppBar(title: const Text('蹇冩儏鍗＄墖')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 妯℃澘鍒囨崲
            _buildTemplateSelector(isDark),
            const SizedBox(height: 16),

            // 鍗＄墖棰勮
            RepaintBoundary(
              key: _cardKey,
              child: _buildCardContent(colors, decors, isDark),
            ),
            const SizedBox(height: 16),

            // 鑷畾涔夐厤鑹叉寜閽紙Pro锛?
            _buildCustomColorButton(),
            const SizedBox(height: 12),

            // 鑷畾涔夋枃瀛楄緭鍏?
            _buildCustomTextInput(isDark),
            const SizedBox(height: 20),

            // 鎿嶄綔鎸夐挳
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _captureAndShare(),
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('鍒嗕韩'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _captureAndSave(),
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('淇濆瓨'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MirrorColors.secondary,
                      foregroundColor: Colors.white,
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

  /// 妯℃澘閫夋嫨鍣紙Pro 鐢ㄦ埛鏄剧ず鍏ㄩ儴 7 涓紝鍏嶈垂鐢ㄦ埛浠呮樉绀哄墠 3 涓?+ 閿佸畾鎻愮ず锛?
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
                        ? _templateColors[index][0].withValues(alpha: 0.5)
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
                  color: Color(0x80D4C5E2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Pro',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: MirrorColors.primaryDark),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '瑙ｉ攣 4 绉嶇簿缇庢ā鏉?+ 鑷畾涔夐厤鑹?,
                style: TextStyle(fontSize: 12, color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/pro'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: MirrorColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('鍗囩骇', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: MirrorColors.primaryDark)),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// 鏍规嵁妯℃澘绱㈠紩娓叉煋涓嶅悓鐨勫崱鐗囧唴瀹?
  Widget _buildCardContent(List<Color> colors, List<String> decors, bool isDark) {
    final isPro = PurchaseService().isPro;

    // Pro 妯℃澘鏈В閿佹椂鏄剧ず閿佸畾鐘舵€?
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

  /// 榛樿妯℃澘锛?=绠€绾?1=鏂囪壓 2=娓╂殩锛?
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
            color: colors[0].withValues(alpha: 0.4),
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
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${EmotionType.fromLabel(_displayEmotion).emoji} $_displayEmotion',
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
                'MirrorMind 路 蹇冮暅',
                style: TextStyle(fontSize: 11, color: MirrorColors.textSecondary.withValues(alpha: 0.6), letterSpacing: 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 娓愬彉妯℃澘锛圥ro #3锛夛細娣辫壊娓愬彉鑳屾櫙 + 鐧借壊鏂囧瓧 + 鍦嗚 16
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
          BoxShadow(color: const Color(0xFF1A1A2E).withValues(alpha: 0.5), blurRadius: 24, offset: const Offset(0, 10)),
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
            style: TextStyle(fontSize: 12, color: fg.withValues(alpha: 0.6), letterSpacing: 2),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: fg.withValues(alpha: 0.3), width: 1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${EmotionType.fromLabel(_displayEmotion).emoji} $_displayEmotion',
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
            Text('MirrorMind', style: TextStyle(fontSize: 10, color: fg.withValues(alpha: 0.4), letterSpacing: 2)),
          ]),
        ],
      ),
    );
  }

  /// 鏋佺畝妯℃澘锛圥ro #4锛夛細绾櫧搴曡壊 + 缁嗚竟妗?+ 澶ч噺鐣欑櫧
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
            style: TextStyle(fontSize: 11, color: fg.withValues(alpha: 0.4), letterSpacing: 3, fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 32),
          Text(
            '${EmotionType.fromLabel(_displayEmotion).emoji} $_displayEmotion',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: fg.withValues(alpha: 0.6), letterSpacing: 2),
          ),
          const SizedBox(height: 24),
          Container(width: 40, height: 2, color: fg.withValues(alpha: 0.15)),
          const SizedBox(height: 24),
          Text(
            _displayText,
            style: TextStyle(fontSize: 17, height: 1.9, color: fg, fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 40),
          Row(children: [
            Text(decors[0], style: const TextStyle(fontSize: 16)),
            const Spacer(),
            Text('蹇冮暅', style: TextStyle(fontSize: 10, color: fg.withValues(alpha: 0.3), letterSpacing: 4)),
          ]),
        ],
      ),
    );
  }

  /// 鎵嬪啓妯℃澘锛圥ro #5锛夛細浠跨焊鑹?+ 澧ㄦ按鑹?+ 鏂滀綋 + 瑁呴グ绾?
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
          BoxShadow(color: const Color(0xFF2C1810).withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 瑁呴グ绾?
          Container(height: 3, width: 60, color: fg.withValues(alpha: 0.3)),
          const SizedBox(height: 20),
          Text(
            _formatDate(_selectedRecord?.date ?? DateTime.now()),
            style: TextStyle(fontSize: 12, color: fg.withValues(alpha: 0.5), fontStyle: FontStyle.italic, letterSpacing: 1),
          ),
          const SizedBox(height: 12),
          Text(
            '${EmotionType.fromLabel(_displayEmotion).emoji} $_displayEmotion',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: fg, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 20),
          // 妯嚎瑁呴グ
          Container(height: 1, width: double.infinity, color: fg.withValues(alpha: 0.1)),
          const SizedBox(height: 20),
          Text(
            _displayText,
            style: TextStyle(fontSize: 18, height: 1.8, color: fg, fontStyle: FontStyle.italic, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 24),
          Container(height: 1, width: double.infinity, color: fg.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Row(children: [
            Text(decors[0], style: const TextStyle(fontSize: 18)),
            const Spacer(),
            Text('蹇冮暅', style: TextStyle(fontSize: 10, color: fg.withValues(alpha: 0.3), fontStyle: FontStyle.italic)),
          ]),
        ],
      ),
    );
  }

  /// 鑳剁墖妯℃澘锛圥ro #6锛夛細榛戣壊搴曡壊 + 鐧借壊鏂囧瓧 + 姗欒壊鏃ユ湡鏍囩
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
          // 姗欒壊鏃ユ湡鏍囩
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
            '${EmotionType.fromLabel(_displayEmotion).emoji} $_displayEmotion',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: fg.withValues(alpha: 0.7), letterSpacing: 3),
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
            Text('蹇冮暅', style: TextStyle(fontSize: 10, color: fg.withValues(alpha: 0.3), letterSpacing: 5)),
          ]),
        ],
      ),
    );
  }

  /// 閿佸畾鍗＄墖锛圥ro 鏈В閿佹椂鐨勯瑙堝崰浣嶏級
  Widget _buildLockedCard(bool isDark) {
    final colors = _templateColors[_templateIndex];
    // 瀹夊叏鑾峰彇棰滆壊锛氬厤璐规ā鏉?[bg1,bg2,text,border]锛孭ro 妯℃澘鍚岀悊
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: colors[0],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: MirrorColors.primaryLight.withValues(alpha: 0.4), width: 2),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 40, color: colors[2].withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text(
              _templateNames[_templateIndex],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: colors[2].withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/pro'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: colors[2].withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('瑙ｉ攣 Pro', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 鑷畾涔夐厤鑹叉寜閽紙浠?Pro 鍙锛?
  Widget _buildCustomColorButton() {
    final isPro = PurchaseService().isPro;
    if (!isPro) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: OutlinedButton.icon(
        onPressed: _showColorPicker,
        icon: const Icon(Icons.palette_outlined, size: 16),
        label: Text(_customBgColor != null ? '鑷畾涔夐厤鑹?路 宸茶缃? : '鑷畾涔夐厤鑹?),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: _customBgColor != null ? MirrorColors.primary : MirrorColors.primaryLight),
        ),
      ),
    );
  }

  /// 棰滆壊閫夋嫨鍣ㄥ璇濇
  void _showColorPicker() {
    final isPro = PurchaseService().isPro;
    if (!isPro) return;

    // 棰勮鑹插潡
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
          title: const Text('鑷畾涔夐厤鑹?),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('鑳屾櫙鑹?, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: MirrorColors.textSecondary)),
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
                          boxShadow: isSelected ? [BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 8)] : [],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('鏂囧瓧鑹?, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: MirrorColors.textSecondary)),
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
                          boxShadow: isSelected ? [BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 8)] : [],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                // 棰勮
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selectedBg ?? const Color(0xFFF5F0EB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '棰勮鏁堟灉',
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
              child: const Text('閲嶇疆榛樿'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _customBgColor = selectedBg;
                  _customTextColor = selectedText;
                });
                Navigator.pop(ctx);
              },
              child: const Text('纭'),
            ),
          ],
        ),
      ),
    );
  }

  /// 鑷畾涔夋枃瀛楄緭鍏?
  Widget _buildCustomTextInput(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '鑷畾涔夋枃瀛?,
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
                      ? Color(0x80D4C5E2)
                      : (isDark ? MirrorColors.darkSurface : MirrorColors.cardBackground),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _useCustomText ? '浣跨敤璁板綍' : '鑷畾涔?,
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
              hintText: '鍐欎笅鎯虫斁鍦ㄥ崱鐗囦笂鐨勮瘽...',
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

