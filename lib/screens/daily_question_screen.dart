import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emotion_provider.dart';
import '../models/emotion_record.dart';
import '../constants/colors.dart';

/// 姣忔棩涓€闂?鈥?鎯呯华鐩茬洅锛氭瘡澶╅殢鏈烘帹閫佹繁搴﹀弽鎬濋棶棰?
class DailyQuestionScreen extends StatefulWidget {
  const DailyQuestionScreen({super.key});

  @override
  State<DailyQuestionScreen> createState() => _DailyQuestionScreenState();
}

class _DailyQuestionScreenState extends State<DailyQuestionScreen>
    with TickerProviderStateMixin {
  final TextEditingController _answerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 鍔ㄧ敾鎺у埗鍣?
  late AnimationController _typewriterController;
  late AnimationController _flipController;
  late AnimationController _fadeController;

  // 鐘舵€?
  _QuestionItem? _todayQuestion;
  int _displayCharCount = 0;
  bool _isFlipped = false;
  bool _isSaving = false;
  String _goldenQuote = '';


  int _consecutiveDays = 0;
  // ==================== 50 涓棶棰樺簱 ====================
  static final List<_QuestionItem> _questionBank = [
    // --- 鑷垜璁ょ煡 (10) ---
    const _QuestionItem('濡傛灉浠婂ぉ鏄綘鐢熷懡涓渶閲嶈鐨勪竴澶╋紝浣犱細鎬庝箞搴﹁繃锛?, '鑷垜璁ょ煡'),
    const _QuestionItem('浣犳渶杩戝鍒扮殑鏈€閲嶈鐨勪竴璇炬槸浠€涔堬紵', '鑷垜璁ょ煡'),
    const _QuestionItem('濡傛灉鐢ㄤ笁涓瘝褰㈠鐜板湪鐨勮嚜宸憋紝浣犱細閫変粈涔堬紵', '鑷垜璁ょ煡'),
    const _QuestionItem('浣犲唴蹇冩繁澶勬渶瀹虫€曠殑鏄粈涔堬紵浣犲浣曢潰瀵瑰畠锛?, '鑷垜璁ょ煡'),
    const _QuestionItem('浠€涔堜簨鎯呰浣犺寰?杩欏氨鏄垜"锛?, '鑷垜璁ょ煡'),
    const _QuestionItem('濡傛灉鍙互鏀瑰彉鑷繁鐨勪竴浠朵簨锛屼綘浼氭敼鍙樹粈涔堬紵', '鑷垜璁ょ煡'),
    const _QuestionItem('浣犺寰楄嚜宸辨渶琚綆浼扮殑浼樼偣鏄粈涔堬紵', '鑷垜璁ょ煡'),
    const _QuestionItem('涓婁竴娆′綘涓鸿嚜宸辨劅鍒伴獎鍌叉槸浠€涔堟椂鍊欙紵', '鑷垜璁ょ煡'),
    const _QuestionItem('鏈変粈涔堜簨鎯呮槸浣犱竴鐩存兂鍋氫絾杩樻病寮€濮嬬殑锛?, '鑷垜璁ょ煡'),
    const _QuestionItem('浣犺寰楀崄骞村悗鐨勮嚜宸变細瀵圭幇鍦ㄧ殑浣犺浠€涔堬紵', '鑷垜璁ょ煡'),

    // --- 浜洪檯鍏崇郴 (10) ---
    const _QuestionItem('璋佹槸浣犵敓鍛戒腑鎰忔兂涓嶅埌鐨勮吹浜猴紵', '浜洪檯鍏崇郴'),
    const _QuestionItem('鏈€杩戜竴娆¤浣犵湡蹇冪瑧鍑哄０鐨勪簨鏄粈涔堬紵', '浜洪檯鍏崇郴'),
    const _QuestionItem('浣犳渶鎯冲璋佽涓€澹?璋㈣阿"锛熶负浠€涔堬紵', '浜洪檯鍏崇郴'),
    const _QuestionItem('鏈夋病鏈変竴涓汉锛屾敼鍙樹簡浣犵殑浜虹敓杞ㄨ抗锛?, '浜洪檯鍏崇郴'),
    const _QuestionItem('浣犺寰楄嚜宸卞湪鍒汉鐪间腑鏄粈涔堟牱鐨勪汉锛?, '浜洪檯鍏崇郴'),
    const _QuestionItem('鏈€杩戜竴娆″拰鏈嬪弸娣卞叆浜ゆ祦鏄粈涔堟椂鍊欙紵', '浜洪檯鍏崇郴'),
    const _QuestionItem('浣犲浣曞鐞嗕笌浠栦汉鐨勫啿绐佸拰璇В锛?, '浜洪檯鍏崇郴'),
    const _QuestionItem('鏈夋病鏈変竴涓汉锛屼綘鎯抽噸鏂拌仈绯讳絾涓€鐩存病鍕囨皵锛?, '浜洪檯鍏崇郴'),
    const _QuestionItem('浣犺寰楃埍鍜岃鐖憋紝鍝釜鏇撮噸瑕侊紵', '浜洪檯鍏崇郴'),
    const _QuestionItem('濡傛灉鍙互璇蜂换浣曚汉鍏辫繘鏅氶锛屼綘浼氶€夎皝锛?, '浜洪檯鍏崇郴'),

    // --- 鏈潵灞曟湜 (10) ---
    const _QuestionItem('濡傛灉鍙互瀵?0骞村墠鐨勮嚜宸辫涓€鍙ヨ瘽锛屼綘浼氳浠€涔堬紵', '鏈潵灞曟湜'),
    const _QuestionItem('浣犲鏈潵鏈€澶х殑鏈熷緟鏄粈涔堬紵', '鏈潵灞曟湜'),
    const _QuestionItem('濡傛灉鍙互鎷ユ湁涓€绉嶈秴鑳藉姏锛屼綘甯屾湜鏄粈涔堬紵', '鏈潵灞曟湜'),
    const _QuestionItem('浣犵悊鎯充腑鐨勪竴澶╂槸鎬庢牱鐨勶紵', '鏈潵灞曟湜'),
    const _QuestionItem('濡傛灉涓嶈€冭檻鐜板疄闄愬埗锛屼綘鏈€鎯冲仛浠€涔堝伐浣滐紵', '鏈潵灞曟湜'),
    const _QuestionItem('浣犳兂缁欒繖涓笘鐣岀暀涓嬩粈涔堬紵', '鏈潵灞曟湜'),
    const _QuestionItem('鏄庡勾浠婂ぉ锛屼綘甯屾湜鑷繁鏈変粈涔堜笉鍚岋紵', '鏈潵灞曟湜'),
    const _QuestionItem('浣犳渶澶х殑姊︽兂杩樺湪鍚楋紵瀹冩槸鍚︽敼鍙樹簡锛?, '鏈潵灞曟湜'),
    const _QuestionItem('濡傛灉鍙互閫夋嫨鍦ㄤ换浣曞湴鏂圭敓娲伙紝浣犱細閫夊摢閲岋紵', '鏈潵灞曟湜'),
    const _QuestionItem('浣犲笇鏈涜嚜宸辩殑澧撳織閾笂鍐欎粈涔堬紵', '鏈潵灞曟湜'),

    // --- 杩囧線鍥為【 (10) ---
    const _QuestionItem('绔ュ勾鏈€娓╂殩鐨勮蹇嗘槸浠€涔堬紵', '杩囧線鍥為【'),
    const _QuestionItem('鏈夋病鏈変竴浠朵簨璁╀綘鑷充粖鍚庢倲锛?, '杩囧線鍥為【'),
    const _QuestionItem('浣犱汉鐢熶腑鐨勮浆鎶樼偣鏄粈涔堬紵', '杩囧線鍥為【'),
    const _QuestionItem('涓婁竴娆″摥鏄洜涓轰粈涔堬紵', '杩囧線鍥為【'),
    const _QuestionItem('浣犲仛杩囨渶鍕囨暍鐨勪竴浠朵簨鏄粈涔堬紵', '杩囧線鍥為【'),
    const _QuestionItem('鏈夋病鏈変竴涓喅瀹氭敼鍙樹簡浣犵殑浜虹敓锛?, '杩囧線鍥為【'),
    const _QuestionItem('浣犳渶澶х殑澶辫触鏁欎細浜嗕綘浠€涔堬紵', '杩囧線鍥為【'),
    const _QuestionItem('濡傛灉鏈変汉缁欎綘涓€绗斿法娆撅紝浣犱細鐢ㄥ畠鍋氫粈涔堬紵', '杩囧線鍥為【'),
    const _QuestionItem('浣犱汉鐢熶腑鏈€闅惧繕鐨勪竴娆℃梾琛屾槸锛?, '杩囧線鍥為【'),
    const _QuestionItem('濡傛灉鍙互閲嶆柊娲讳竴澶╋紝浣犱細閫夊摢涓€澶╋紵', '杩囧線鍥為【'),

    // --- 鍋囪鎯宠薄 (10) ---
    const _QuestionItem('濡傛灉鏄庡ぉ鏄笘鐣屾湯鏃ワ紝浣犱細濡備綍搴﹁繃鏈€鍚庝竴澶╋紵', '鍋囪鎯宠薄'),
    const _QuestionItem('濡傛灉浣犲彲浠ラ殣韬竴澶╋紝浣犱細鍋氫粈涔堬紵', '鍋囪鎯宠薄'),
    const _QuestionItem('濡傛灉浣犺兘鍜屼换浣曞巻鍙蹭汉鐗╁璇濓紝浣犳兂鍜岃皝鑱婁粈涔堬紵', '鍋囪鎯宠薄'),
    const _QuestionItem('濡傛灉浣犵殑鐢熸椿鏄竴閮ㄧ數褰憋紝瀹冪殑鍚嶅瓧鏄粈涔堬紵', '鍋囪鎯宠薄'),
    const _QuestionItem('濡傛灉浣犲彉鎴愪簡鍔ㄧ墿锛屼綘瑙夊緱鑷繁浼氭槸浠€涔堬紵', '鍋囪鎯宠薄'),
    const _QuestionItem('濡傛灉鑳藉彂鏄庝竴鏍蜂笢瑗匡紝浣犱細鍙戞槑浠€涔堬紵', '鍋囪鎯宠薄'),
    const _QuestionItem('濡傛灉浣犳湁涓€鍙版椂鍏夋満锛屼綘浼氬洖鍒拌繃鍘昏繕鏄幓寰€鏈潵锛?, '鍋囪鎯宠薄'),
    const _QuestionItem('濡傛灉骞哥鍙互鍏呭€硷紝浣犳効鎰忕敤浠€涔堟潵浜ゆ崲锛?, '鍋囪鎯宠薄'),
    const _QuestionItem('濡傛灉浣犲彧鑳戒繚鐣欎竴涓蹇嗭紝浣犱細淇濈暀浠€涔堬紵', '鍋囪鎯宠薄'),
    const _QuestionItem('濡傛灉涓€涓檶鐢熶汉鍙互浜嗚В浣犵殑涓€浠朵簨锛屼綘甯屾湜鏄粈涔堬紵', '鍋囪鎯宠薄'),
  ];

  // 閲戝彞搴擄紙鍥炵瓟鍚庨殢鏈哄睍绀猴級
  static final List<String> _quotes = [
    '璁よ瘑鑷繁锛屾槸缁堢敓娴极鐨勫紑濮嬨€傗€斺€?鐜嬪皵寰?,
    '鐢熷懡涓渶闅剧殑涓嶆槸娌℃湁浜烘噦浣狅紝鑰屾槸浣犱笉鎳傝嚜宸便€?,
    '绛旀涓嶅湪鍒锛屽氨鍦ㄤ綘璇氬疄鍦伴潰瀵硅嚜宸辩殑閭ｄ竴鍒汇€?,
    '姣忎竴娆℃繁鍒荤殑鑷垜瀵硅瘽锛岄兘鏄竴娆＄伒榄傜殑娲楃ぜ銆?,
    '浣犳瘮浣犳兂璞＄殑鏇村媷鏁€佹洿鍧氶煣銆佹洿鍊煎緱琚埍銆?,
    '浜虹敓鐨勬剰涔変笉鏄鍙戠幇鐨勶紝鑰屾槸琚垱閫犵殑銆?,
    '鎺ョ撼涓嶅畬缇庣殑鑷繁锛屾墠鏄湡姝ｇ殑寮哄ぇ銆?,
    '浣犳墍缁忓巻鐨勪竴鍒囷紝閮藉湪濉戦€犵嫭涓€鏃犱簩鐨勪綘銆?,
    '娲荤潃鏈韩灏辨槸鏈€澶х殑濂囪抗銆?,
    '浠婂ぉ鎵€鍋氱殑涓€鍒囷紝閮芥槸瀵规槑澶╃殑鑷繁璇?鎴戝€煎緱"銆?,
    '涓嶅繀鎴愪负鏇村ソ鐨勮嚜宸憋紝鍙渶鏇村ソ鍦版垚涓鸿嚜宸便€?,
    '涓栫晫鏄竴闈㈤暅瀛愶紝浣犲瀹冨井绗戯紝瀹冨氨瀵逛綘寰瑧銆?,
    '娓╂煍鍦板寰呰嚜宸憋紝灏卞儚瀵瑰緟鏈€濂界殑鏈嬪弸銆?,
    '姣忎竴涓綋涓嬶紝閮芥槸浣犱綑鐢熶腑鏈€骞磋交鐨勪竴鍒汇€?,
    '鎵€鏈夌殑杩疯尗锛岄兘鏄洜涓轰綘鍦ㄨ鐪熷湴娲荤潃銆?,
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

  /// 鍩轰簬鏃ユ湡鐢熸垚浠婃棩闂
  void _loadTodayQuestion() {
    final now = DateTime.now();
    // 浣跨敤骞存湀鏃ョ粍鍚堜綔涓虹瀛愶紝淇濊瘉鍚屼竴澶╅棶棰樼浉鍚?
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final random = Random(seed);
    final index = random.nextInt(_questionBank.length);
    _todayQuestion = _questionBank[index];
    _goldenQuote = _quotes[random.nextInt(_quotes.length)];

    // 鍚姩鎵撳瓧鏈哄姩鐢?
    _startTypewriter();
  }

  /// 鎵撳瓧鏈哄姩鐢?
  void _startTypewriter() {
    final question = _todayQuestion!.question;
    const interval = 60; // 姣忎釜瀛?60ms
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

  /// 鍔犺浇杩炵画鍥炵瓟澶╂暟
  Future<void> _loadConsecutiveDays() async {
    // 绠€鍖栵細浠庢暟鎹簱鏌ヨ tag 涓?"姣忔棩涓€闂? 鐨勮褰?
    final provider = context.read<EmotionProvider>();
    final records = await provider.loadAllRecords();
    final questionRecords = records
        .where((r) => r.tag == '姣忔棩涓€闂?)
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

  /// 淇濆瓨鍥炵瓟
  Future<void> _saveAnswer() async {
    final answer = _answerController.text.trim();
    if (answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('鍐欎笅浣犵殑鎬濊€冨惂~'), backgroundColor: MirrorColors.warm),
      );
      return;
    }

    setState(() => _isSaving = true);

    final record = EmotionRecord(
      date: DateTime.now(),
      emotion: '涓€鑸?,
      inputText: '闂锛?{_todayQuestion!.question}\n鍥炵瓟锛?answer',
      score: 7,
      tag: '姣忔棩涓€闂?,
    );

    final provider = context.read<EmotionProvider>();
    await provider.saveRecord(record);

    if (!mounted) return;
    setState(() {

      // _isSaved logic removed
    });

    // 缈昏浆鍗＄墖鏄剧ず閲戝彞
    _flipController.forward();
    _fadeController.forward();
    setState(() => _isFlipped = true);
    _loadConsecutiveDays();
  }

  /// 鍒嗕韩浠婃棩闂
  void _shareQuestion() {
    // 閫氳繃绯荤粺鍒嗕韩
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('闀挎寜澶嶅埗闂涓庡ソ鍙嬪垎浜惂'),
        backgroundColor: MirrorColors.secondary,
      ),
    );
  }

  String _getCategoryIcon(String category) {
    switch (category) {
      case '鑷垜璁ょ煡':
        return '馃獮';
      case '浜洪檯鍏崇郴':
        return '馃挒';
      case '鏈潵灞曟湜':
        return '馃敪';
      case '杩囧線鍥為【':
        return '馃摐';
      case '鍋囪鎯宠薄':
        return '鉁?;
      default:
        return '馃挱';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '鑷垜璁ょ煡':
        return MirrorColors.primary;
      case '浜洪檯鍏崇郴':
        return MirrorColors.accent;
      case '鏈潵灞曟湜':
        return MirrorColors.secondary;
      case '杩囧線鍥為【':
        return MirrorColors.warm;
      case '鍋囪鎯宠薄':
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
        title: const Text('姣忔棩涓€闂?),
        actions: [
          if (!_isFlipped)
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: _shareQuestion,
              tooltip: '鍒嗕韩',
            ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 杩炵画澶╂暟
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
                  const Text('馃敟', style: TextStyle(fontSize: 14)),
                  Text(
                    '宸茶繛缁洖绛?$_consecutiveDays 澶?,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 闂鍗＄墖锛堝彲缈昏浆锛?
            _buildQuestionCard(isDark, question, categoryColor),

            const SizedBox(height: 24),

            // 鍥炵瓟鍖哄煙锛堝彧鍦ㄧ炕杞墠鏄剧ず锛?
            if (!_isFlipped) _buildAnswerSection(isDark),
            if (_isFlipped) _buildGoldenQuoteCard(isDark),
          ],
        ),
      ),
    );
  }

  /// 闂鍗＄墖锛堟瘺鐜荤拑鏁堟灉 + 缈昏浆鍔ㄧ敾锛?
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

  /// 鍗＄墖姝ｉ潰锛氶棶棰?
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
              '鍐欎笅浣犵殑绛旀',
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

  /// 鍗＄墖鑳岄潰锛氶噾鍙?
  Widget _buildQuestionBack(bool isDark) {
    return FadeTransition(
      opacity: _fadeController,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0x80FBEAE3),
              MirrorColors.primaryLight.withValues(alpha: 0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            const Text('馃専', style: TextStyle(fontSize: 40)),
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
              '鎰熻阿浣犵殑鐪熻瘹鍥炵瓟',
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

  /// 鍥炵瓟鍖哄煙
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
                hintText: '鍐欎笅浣犵殑鎬濊€?..\n涓嶅繀瀹岀編锛岀湡瀹炲氨濂?,
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
                    : const Text('淇濆瓨鍥炵瓟'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 閲戝彞鍗＄墖
  Widget _buildGoldenQuoteCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? MirrorColors.darkCardBackground : MirrorColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('馃帀', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            '浠婂ぉ鐨勯棶棰樺凡鍥炵瓟',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '鏄庡ぉ鍐嶆潵鎺㈢储鏂扮殑闂鍚?,
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

/// 闂鏁版嵁绫?
class _QuestionItem {
  final String question;
  final String category;

  const _QuestionItem(this.question, this.category);
}

