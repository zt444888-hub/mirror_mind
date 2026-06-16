import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/cards.dart';
import '../services/purchase_service.dart';
import '../widgets/card_swiper.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  int _recommendedIndex = 0;

  @override
  void initState() {
    super.initState();
    _recommendedIndex = _getDailyIndex();
    _pageController = PageController(initialPage: _recommendedIndex);
    _currentPage = _recommendedIndex;
  }

  int _getDailyIndex() {
    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    return seed % cognitiveCards.length;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }


  /// 鏋勫缓婊戝姩绐楀彛寮忛〉鐮佹寚绀哄櫒锛堟渶澶氭樉绀?7 涓偣锛?
  Widget _buildPageIndicators(bool isDark) {
    final total = cognitiveCards.length;
    final maxVisible = 7;
    final halfWindow = maxVisible ~/ 2;

    int start;
    int end;

    if (total <= maxVisible) {
      start = 0;
      end = total;
    } else if (_currentPage <= halfWindow) {
      start = 0;
      end = maxVisible;
    } else if (_currentPage >= total - halfWindow - 1) {
      start = total - maxVisible;
      end = total;
    } else {
      start = _currentPage - halfWindow;
      end = _currentPage + halfWindow + 1;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 宸︿晶鐪佺暐鍙?
        if (start > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              '...',
              style: TextStyle(
                fontSize: 10,
                color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
              ),
            ),
          ),
        // 鍙鐐?
        ...List.generate(
          end - start,
          (i) {
            final index = start + i;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? MirrorColors.primary
                    : (isDark ? MirrorColors.darkSurface : MirrorColors.cardBackground),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          },
        ),
        // 鍙充晶鐪佺暐鍙?
        if (end < total)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              '...',
              style: TextStyle(
                fontSize: 10,
                color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? MirrorColors.darkBackground : MirrorColors.background,
      appBar: AppBar(
        title: const Text('璁ょ煡閲嶆瀯鍗＄墖'),
        actions: [
          if (_currentPage == _recommendedIndex)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: MirrorColors.warmLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '浠婃棩鎺ㄨ崘',
                  style: TextStyle(fontSize: 12, color: MirrorColors.textSecondary),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          // 鍗＄墖婊戝姩鍖哄煙
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: cognitiveCards.length,
              itemBuilder: (context, index) {
                return CardSwiper(
                  card: cognitiveCards[index],
                  isActive: index == _currentPage,
                );
              },
            ),
          ),

          // 杩涢樁涓婚鍏ュ彛锛圥ro锛?
          _buildAdvancedPacks(isDark),
          const SizedBox(height: 8),

          // 椤电爜鎸囩ず鍣紙婊戝姩绐楀彛锛屾渶澶氭樉绀?7 涓偣锛?
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: _buildPageIndicators(isDark),
          ),

          // 鎿嶄綔鎸夐挳
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () {
                  if (_currentPage > 0) {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('涓婁竴寮?),
              ),
              TextButton.icon(
                onPressed: () {
                  _pageController.animateToPage(
                    _recommendedIndex,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                icon: const Icon(Icons.auto_awesome, size: 16),
                label: const Text('浠婃棩鎺ㄨ崘'),
              ),
              TextButton.icon(
                onPressed: () {
                  if (_currentPage < cognitiveCards.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('涓嬩竴寮?),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// 杩涢樁涓婚鍖烘锛圥ro 鍔熻兘锛?
  Widget _buildAdvancedPacks(bool isDark) {
    final isPro = PurchaseService().isPro;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: [
              const Text(
                '杩涢樁涓婚',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(0x80D4C5E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Pro',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: MirrorColors.primaryDark),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _advancedPacks.length,
            itemBuilder: (context, index) {
              final pack = _advancedPacks[index];
              return GestureDetector(
                onTap: () {
                  if (!isPro) {
                    Navigator.pushNamed(context, '/pro');
                    return;
                  }
                  _showPackCards(context, pack);
                },
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? MirrorColors.darkCardBackground : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? MirrorColors.darkSurface : MirrorColors.cardBackground,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pack['icon'] as String, style: const TextStyle(fontSize: 28)),
                      const Spacer(),
                      Text(
                        pack['title'] as String, softWrap: true,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${(pack['cards'] as List).length} 寮犲崱鐗?,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
                        ),
                      ),
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

  void _showPackCards(BuildContext context, Map<String, dynamic> pack) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cards = pack['cards'] as List<CognitiveCard>;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? MirrorColors.darkBackground : MirrorColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (ctx, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Text(
                        pack['title'] as String, softWrap: true,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${index + 1}. ${card.title}',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                card.content, softWrap: true, maxLines: 10, overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static final List<Map<String, dynamic>> _advancedPacks = [
    {
      'icon': '馃懃',
      'title': '绀句氦鍦烘櫙',
      'cards': [
        const CognitiveCard(id: 101, title: '鑱氬厜鐏晥搴?, subtitle: '鍒汉娌′綘鎯宠薄涓偅涔堝叧娉ㄤ綘', content: '澶у鏁颁汉閮藉繖浜庡叧娉ㄨ嚜宸憋紝浠栦滑骞舵病鏈変綘鎯宠薄鐨勯偅涔堝湪鎰忎綘鐨勪竴涓句竴鍔ㄣ€備綘鍙槸鑷繁涓栫晫鐨勪腑蹇冿紝涓嶆槸鍒汉鐨勩€?, category: '绀句氦鍦烘櫙'),
        const CognitiveCard(id: 102, title: '灏忔鏆撮湶娉?, subtitle: '浠庡皬鍦堝瓙寮€濮嬶紝鎱㈡參鎵╁ぇ鑸掗€傚尯', content: '涓嶉渶瑕佷竴娆℃€ч潰瀵瑰ぇ鍦洪潰銆備粠鍜屼竴涓汉鑱婂ぉ寮€濮嬶紝閫愭笎澧炲姞鍒板皬鍥綋锛屾瘡涓€姝ラ兘鏄繘姝ャ€?, category: '绀句氦鍦烘櫙'),
        const CognitiveCard(id: 103, title: '绀句氦涓嶆槸琛ㄦ紨', subtitle: '鍋氱湡瀹炵殑鑷繁锛屾瘮璁ㄥソ鎵€鏈変汉鏇撮噸瑕?, content: '浣犱笉闇€瑕佹垚涓鸿仛浼氫笂鏈€鏈夎叮鐨勪汉銆傜湡璇氬湴鍊惧惉銆佽嚜鐒跺湴鍥炲簲锛岃繖绉嶈垝閫傛劅浼氭劅鏌撲粬浜恒€?, category: '绀句氦鍦烘櫙'),
        const CognitiveCard(id: 104, title: '娌夐粯骞朵笉鍙€?, subtitle: '瀹夐潤涔熸槸涓€绉嶅弬涓庢柟寮?, content: '瀵硅瘽涓殑鍋滈】鏄甯哥殑銆傛矇榛樹笉浠ｈ〃灏村艾锛屾湁鏃跺€欏畠浠ｈ〃鐫€鎬濊€冦€備笉蹇呬负姣忎竴绉掔殑瀹夐潤鎰熷埌鐒﹁檻銆?, category: '绀句氦鍦烘櫙'),
        const CognitiveCard(id: 105, title: '浣犱笉闇€瑕佽鎵€鏈変汉鍠滄', subtitle: '20%鐨勪汉鍠滄浣狅紝浣犲氨璧簡', content: '鍗充娇鏄渶鍙楁杩庣殑浜猴紝涔熸湁浜哄浠栦滑鏃犳劅銆傛妸绮惧姏鏀惧湪鎰挎剰鎺ョ撼浣犵殑浜鸿韩涓娿€?, category: '绀句氦鍦烘櫙'),
        const CognitiveCard(id: 106, title: '鍑嗗涓変釜璇濋灏卞', subtitle: '涓嶉渶瑕佸畬缇庡墽鏈?, content: '鍑嗗涓変釜寮€鏀惧紡闂锛堟渶杩戝湪蹇欎粈涔?鐪嬭繃浠€涔堝ソ鐢靛奖/鏈変粈涔堝ソ鐨勫挅鍟″簵鎺ㄨ崘锛夛紝瓒冲搴斿缁濆ぇ澶氭暟绀句氦鍦哄悎銆?, category: '绀句氦鍦烘櫙'),
        const CognitiveCard(id: 107, title: '绱у紶璇存槑浣犲湪涔?, subtitle: '绱у紶涓嶆槸缂洪櫡锛岃€屾槸鎶曞叆鐨勪俊鍙?, content: '鎵嬪績鍑烘睏銆佸績璺冲姞閫熲€斺€旇繖浜涢兘鏄綘鍦ㄨ鐪熷寰呭綋涓嬫椂鍒荤殑璇佹槑銆傛妸绱у紶閲嶆柊鐞嗚В涓?鍦ㄤ箮"銆?, category: '绀句氦鍦烘櫙'),
        const CognitiveCard(id: 108, title: '寰瑧鏄渶濂界殑寮€鍦虹櫧', subtitle: '涓€涓井绗戣儨杩囧崈瑷€涓囪', content: '涓嶉渶瑕佸畬缇庣殑寮€鍦虹櫧銆備竴涓湡璇氱殑寰瑧灏辫兘閲婃斁鍠勬剰锛屾媺杩戜汉涓庝汉涔嬮棿鐨勮窛绂汇€?, category: '绀句氦鍦烘櫙'),
        const CognitiveCard(id: 109, title: '鎺ョ撼鑷繁鐨勫唴鍚?, subtitle: '鍐呭悜涓嶆槸缂洪櫡锛岃€屾槸涓€绉嶅姏閲?, content: '鍐呭悜鐨勪汉鍠勪簬娣卞害鍊惧惉銆佽瀵熺粏鑺傘€傝繖涓笘鐣岄渶瑕佸唴鍚戣€呯殑瀹夐潤鍔涢噺銆?, category: '绀句氦鍦烘櫙'),
        const CognitiveCard(id: 110, title: '鎶婃敞鎰忓姏鏀惧湪瀵规柟韬笂', subtitle: '鍏虫敞鍒汉鏃讹紝浣犱細蹇樿鑷繁鐨勪笉鑷湪', content: '鍦ㄧぞ浜ゅ満鍚堟劅鍒扮揣寮犳椂锛屾妸娉ㄦ剰鍔涗粠"鎴戣〃鐜板緱濂戒笉濂?杞Щ鍒?瀵规柟鏄竴涓€庢牱鏈夎叮鐨勪汉"銆?, category: '绀句氦鍦烘櫙'),
        const CognitiveCard(id: 111, title: '姣忎竴娆＄ぞ浜ら兘鏄竴娆＄粌涔?, subtitle: '娌℃湁澶辫触鐨勭ぞ浜?, content: '涓嶆槸姣忔浜ゆ祦閮戒細瀹岀編锛屼絾姣忎竴娆￠兘鏄Н绱€傚嵆浣挎槸灏村艾鐨勫璇濓紝涔熷湪甯綘淇涓嬩竴娆＄殑鏂瑰紡銆?, category: '绀句氦鍦烘櫙'),
        const CognitiveCard(id: 112, title: '浠栦汉璇勪环涓嶇瓑浜庝綘', subtitle: '鍒汉鐨勭溂鍏変笉鑳藉畾涔変綘鏄皝', content: '鍒汉鎬庝箞鐪嬩綘鏄粬浠殑閫夋嫨銆備綘鏄皝涓嶇敱澶栧洿璇勪环鍐冲畾锛岃€岀敱浣犵殑琛屽姩鍜岄€夋嫨鍐冲畾銆?, category: '绀句氦鍦烘櫙'),
      ],
    },
    {
      'icon': '馃捈',
      'title': '鑱屽満鍘嬪姏',
      'cards': [
        const CognitiveCard(id: 201, title: '鍖哄垎鍙帶涓庝笉鍙帶', subtitle: '鎶婄簿鍔涙斁鍦ㄤ綘鑳芥敼鍙樼殑浜嬫儏涓?, content: '鍒椾竴寮犺〃锛氬乏杈瑰啓"鎴戣兘鎺у埗鐨勪簨"锛屽彸杈瑰啓"鎴戞棤娉曟帶鍒剁殑浜?銆傚彧鐪嬪乏杈癸紝瀵瑰彸杈硅"鏀炬墜"銆?, category: '鑱屽満鍘嬪姏'),
        const CognitiveCard(id: 202, title: '瀛︿細璇?涓?', subtitle: '姣忎竴娆¤"涓?锛岄兘鏄鑷繁璇?鏄?', content: '浣犵殑鏃堕棿鍜岀簿鍔涙槸鏈夐檺鐨勩€傚涓嶅繀瑕佺殑璇锋眰璇?涓?涓嶆槸鑷锛岃€屾槸瀵硅嚜宸辫竟鐣岀殑灏婇噸銆?, category: '鑱屽満鍘嬪姏'),
        const CognitiveCard(id: 203, title: '瀹屾垚澶т簬瀹岀編', subtitle: '80%鐨勫畬鎴愬ソ杩?00%鐨勬湭瀹屾垚', content: '杩芥眰瀹岀編浼氳浣犻櫡鍏ユ棤灏界殑淇敼寰幆銆傚厛瀹屾垚锛屽啀杩唬銆傝鍔ㄦ槸鏈€濂界殑瑙ｈ嵂銆?, category: '鑱屽満鍘嬪姏'),
        const CognitiveCard(id: 204, title: '涓嶆妸宸ヤ綔甯﹀洖瀹?, subtitle: '鐗╃悊杈圭晫鍒涢€犲績鐞嗚竟鐣?, content: '璁惧畾涓€涓?涓嬬彮浠紡"锛氬叧闂數鑴戙€佹崲涓婁究鏈嶃€佹场鏉尪銆傜敤浠紡鎰熷垏鏂伐浣滄ā寮忋€?, category: '鑱屽満鍘嬪姏'),
        const CognitiveCard(id: 205, title: '瀵绘眰甯姪鏄兘鍔涗笉鏄蒋寮?, subtitle: '鎳傛眰鍔╃殑浜鸿蛋寰楁洿杩?, content: '娌℃湁浜鸿兘鐙嚜瀹屾垚涓€鍒囥€傚悜鍚屼簨瀵绘眰甯姪璇存槑浣犳竻妤氳嚜宸辩殑杈圭晫锛岃繖鏄垚鐔熺殑琛ㄧ幇銆?, category: '鑱屽満鍘嬪姏'),
        const CognitiveCard(id: 206, title: '鍚屼簨璇勪环涓嶇瓑浜庝綘', subtitle: '浣犵殑浠峰€间笉鐢变粬浜哄畾涔?, content: '鍚屼簨瀵逛綘鐨勭湅娉曞彧鏄竴闈㈤暅瀛愶紝闀滃瓙閲岀湅鍒扮殑涓嶆槸鍏ㄩ儴鐨勭湡鐩搞€備綘鐨勪环鍊艰繙涓嶆浜庢銆?, category: '鑱屽満鍘嬪姏'),
        const CognitiveCard(id: 207, title: '璁剧疆杈圭晫', subtitle: '娌℃湁杈圭晫锛屽氨娌℃湁鑷垜淇濇姢', content: '宸ヤ綔娑堟伅鍙互绛夊埌鏄庡ぉ鍥炲锛屽懆鏈彲浠ヤ笉鎯冲伐浣滅殑浜嬨€傛竻鏅扮殑杈圭晫鏄鑷繁鐨勫皧閲嶃€?, category: '鑱屽満鍘嬪姏'),
        const CognitiveCard(id: 208, title: '搴嗙灏忚儨鍒?, subtitle: '姣忓畬鎴愪竴浠朵簨閮藉€煎緱搴嗙', content: '鍋氬畬涓€涓狿PT銆佸彂瀹屼竴灏侀偖浠躲€佸紑瀹屼竴涓細鈥斺€旀瘡涓€涓皬鑳滃埄閮藉€煎緱浣犲鑷繁璇翠竴澹?骞插緱濂?銆?, category: '鑱屽満鍘嬪姏'),
        const CognitiveCard(id: 209, title: '涓嶆瘮杈?, subtitle: '鍒汉鐨勮繘搴︿笌浣犳棤鍏?, content: '鍚屼簨鍗囪亴鍔犺柂涓嶇瓑浜庝綘钀藉悗浜嗐€傛瘡涓汉璧板湪鑷繁鐨勬椂鍖洪噷锛屼綘鐨勮妭濂忎笉绱т篃涓嶆參锛屽垰鍒氬ソ銆?, category: '鑱屽満鍘嬪姏'),
        const CognitiveCard(id: 210, title: '宸ヤ綔涓嶆槸鍏ㄩ儴', subtitle: '浣犵殑韬唤涓嶆涓€浠藉伐浣?, content: '浣犳槸涓€涓湁鐖卞ソ鐨勪汉銆佷竴涓湅鍙嬨€佷竴涓搴垚鍛樸€傚伐浣滃彧鏄綘澶氶噸韬唤涓殑涓€灏忛儴鍒嗐€?, category: '鑱屽満鍘嬪姏'),
        const CognitiveCard(id: 211, title: '浼戞伅鏄敓浜у姏', subtitle: '涓嶅厖鐢电殑鐢垫睜缁堝皢鑰楀敖', content: '鍗堜紤涓嶆槸娴垂鏃堕棿锛屾槸缁存寔涓嬪崍鏁堢巼鐨勫繀瑕佹姇璧勩€傜揣缁风殑寮﹀鏄撴柇锛岄€傚害鐨勬斁鏉捐浣犺蛋寰楁洿杩溿€?, category: '鑱屽満鍘嬪姏'),
        const CognitiveCard(id: 212, title: '姣忓ぉ鐣?0鍒嗛挓缁欒嚜宸?, subtitle: '30鍒嗛挓鏄綘鑳界粰鑷繁鏈€濂界殑绀肩墿', content: '鍦ㄥ繖纰岀殑涓€澶╀腑锛岀暀鍑?0鍒嗛挓鍙睘浜庝綘锛氳涔︺€佸惉闊充箰銆佸彂鍛嗐€傝繖娈垫椂鍏夋槸浣犵殑鍏呯數瀹濄€?, category: '鑱屽満鍘嬪姏'),
      ],
    },
    {
      'icon': '馃挄',
      'title': '浜插瘑鍏崇郴',
      'cards': [
        const CognitiveCard(id: 301, title: '鐖辨槸鍔ㄨ瘝', subtitle: '鐖变笉鏄劅瑙夛紝鏄瘡澶╃殑閫夋嫨', content: '鐖变笉鏄竴鐩村績鍔ㄧ殑鎰熻锛岃€屾槸鍦ㄥ鏂归渶瑕佹椂閫掍笂涓€鏉按銆佸湪浜夊惖鍚庝富鍔ㄥ拰瑙ｇ殑閫夋嫨銆?, category: '浜插瘑鍏崇郴'),
        const CognitiveCard(id: 302, title: '琛ㄨ揪姣旂寽娴嬫洿閲嶈', subtitle: '璇村嚭鏉ワ紝瀵规柟鎵嶅惉寰楄', content: '涓嶈鏈熷緟瀵规柟璇诲績銆備綘鐨勯渶姹傘€佷綘鐨勬劅鍙楋紝闇€瑕佷綘娓呮櫚鍦拌鍑烘潵銆傝繖鏄鑷繁鐨勫皧閲嶏紝涔熸槸瀵瑰叧绯荤殑璐熻矗銆?, category: '浜插瘑鍏崇郴'),
        const CognitiveCard(id: 303, title: '鍏佽瀵规柟涓嶅畬缇?, subtitle: '瀹岀編鏄叧绯荤殑鏁屼汉', content: '浣犵埍鐨勪汉涔熶細鐘敊銆佷細鑴炬皵涓嶅ソ銆佷細璇撮敊璇濄€傛帴绾宠繖浜涗笉瀹岀編锛屽洜涓轰綘鑷繁涔熶竴鏍枫€?, category: '浜插瘑鍏崇郴'),
        const CognitiveCard(id: 304, title: '鍐茬獊涓嶇瓑浜庝笉鐖?, subtitle: '鍚垫灦鏄彟涓€绉嶆矡閫氭柟寮?, content: '浜夊惖涓嶆剰鍛崇潃鍏崇郴鐮磋锛屽畠鏄郊姝ゅ湪鎰忕殑璇佹槑銆傚啿绐佽繃鍚庣殑鍜岃В锛屽線寰€璁╁叧绯绘洿绱у瘑銆?, category: '浜插瘑鍏崇郴'),
        const CognitiveCard(id: 305, title: '鍊惧惉姣斿缓璁洿娓╂殩', subtitle: '鏈夋椂鍊欏彧闇€瑕佽鍚', content: '褰撳鏂瑰悜浣犲€捐瘔锛屽ぇ澶氭暟鏃跺€欓渶瑕佺殑鏄悊瑙ｅ拰鍏辨儏锛岃€屼笉鏄В鍐虫柟妗堛€傚厛鎷ユ姳锛屽啀璇磋瘽銆?, category: '浜插瘑鍏崇郴'),
        const CognitiveCard(id: 306, title: '浣犵殑闇€姹傛槸姝ｅ綋鐨?, subtitle: '涓嶅帇鎶戣嚜宸辩殑闇€瑕?, content: '鍦ㄥ叧绯讳腑锛屼綘鐨勯渶姹傚拰瀵规柟鐨勫悓鏍烽噸瑕併€備笉闇€瑕佷负浜嗙淮鎸佸叧绯昏€屽灞堣嚜宸便€?, category: '浜插瘑鍏崇郴'),
        const CognitiveCard(id: 307, title: '涓嶆湡寰呭鏂硅蹇?, subtitle: '浣犳兂瑕佺殑锛岃璇村嚭鏉?, content: '娌℃湁浜鸿兘鐚滃埌浣犵殑蹇冩€濄€傜洿鎺ヨ鍑轰綘鎯宠涓€涓嫢鎶便€佷竴鍙ュ畨鎱版垨鏄竴娆＄害浼氥€?, category: '浜插瘑鍏崇郴'),
        const CognitiveCard(id: 308, title: '绌洪棿鎰熸槸鍏崇郴鐨勪竴閮ㄥ垎', subtitle: '绋冲畾鐨勫叧绯婚渶瑕佸懠鍚?, content: '鍐嶄翰瀵嗙殑鍏崇郴涔熼渶瑕佸悇鑷殑绌洪棿銆傚厑璁稿鏂规湁鑷繁鐨勬椂闂淬€佽嚜宸辩殑鏈嬪弸銆佽嚜宸辩殑鐖卞ソ銆?, category: '浜插瘑鍏崇郴'),
        const CognitiveCard(id: 309, title: '鎰熸仼灏忎簨鎯?, subtitle: '澶т簨鐢卞皬浜嬬疮绉?, content: '涓€涓棭瀹夐棶鍊欍€佷竴鏉鍒板簥杈圭殑姘淬€佷竴鍙?浣犺緵鑻︿簡"鈥斺€旇繖浜涘皬浜嬫槸鍏崇郴鏈€鍧氬浐鐨勫熀鐭炽€?, category: '浜插瘑鍏崇郴'),
        const CognitiveCard(id: 310, title: '鍏崇郴闇€瑕佺淮鎶?, subtitle: '缁忚惀鍜岃€曡€橀渶瑕佹瘡澶╃殑鍔姏', content: '鍏崇郴鍍忎竴鏍鐗╋紝涓嶈兘鍙湪鏋悗鏃舵墠娴囨按銆傛瘡澶╃殑鍏虫敞鍜屾姇鍏ワ紝鎵嶈兘璁╁畠鑼佸．鎴愰暱銆?, category: '浜插瘑鍏崇郴'),
        const CognitiveCard(id: 311, title: '鏀句笅鎺у埗娆?, subtitle: '浣犳棤娉曟帶鍒跺鏂癸紝鍙兘绠＄悊鑷繁', content: '鎯虫敼鍙樺鏂规槸璁稿鍏崇郴鍐茬獊鐨勬牴婧愩€備綘鍞竴鑳芥帶鍒剁殑鏄嚜宸辩殑鍙嶅簲鍜屾€佸害銆?, category: '浜插瘑鍏崇郴'),
        const CognitiveCard(id: 312, title: '鍏堢埍鑷繁鎵嶈兘鐖变汉', subtitle: '鐖辨弧鍒欐孩', content: '濡傛灉浣犺嚜宸辩殑鏉瓙鏄┖鐨勶紝浣犲氨鏃犳硶缁欏埆浜哄€掓按銆傚厛瀛︿細鐖辫嚜宸憋紝浣犵殑鐖辨墠浼氭湁鍔涢噺銆?, category: '浜插瘑鍏崇郴'),
      ],
    },
    {
      'icon': '馃尡',
      'title': '鑷垜鎴愰暱',
      'cards': [
        const CognitiveCard(id: 401, title: '鎴愰暱鏄灪鏃嬩笂鍗囩殑', subtitle: '杩涙涓嶆槸绾挎€х殑锛屼笉瑕佺潃鎬?, content: '姣忎竴娆?鍊掗€€"鍏跺疄閮芥槸鍦ㄧН钃勫姏閲忋€傛垚闀夸笉鏄竴鏉＄洿绾匡紝鑰屾槸铻烘棆涓婂崌鈥斺€旂湅浼煎湪缁曞湀锛屽疄闄呬笂宸茬粡鏇撮珮浜嗐€?, category: '鑷垜鎴愰暱'),
        const CognitiveCard(id: 402, title: '鍏佽鑷繁鍋滀笅鏉?, subtitle: '浼戞伅涓嶆槸鏀惧純', content: '鏈夋椂鍊欐渶濂界殑鍓嶈繘鏂瑰紡锛屾槸鍋滀笅鏉ュ枠鍙ｆ皵銆傜粰鑷繁鏆傚仠鐨勮鍙紝鎭㈠鍚庡啀鍑哄彂銆?, category: '鑷垜鎴愰暱'),
        const CognitiveCard(id: 403, title: '姣旇緝鏄伔璧板揩涔愮殑灏忓伔', subtitle: '浣犵殑瀵规墜鍙湁鏄ㄥぉ鐨勮嚜宸?, content: '鍜屼粬浜烘瘮杈冨彧浼氬甫鏉ョ劍铏戙€備綘鍞竴闇€瑕佽秴瓒婄殑浜猴紝灏辨槸鏄ㄥぉ鐨勮嚜宸便€?, category: '鑷垜鎴愰暱'),
        const CognitiveCard(id: 404, title: '姣忎竴涓綋涓嬮兘鏄捣鐐?, subtitle: '浠讳綍鏃跺€欏紑濮嬮兘涓嶆櫄', content: '涓嶉渶瑕佺瓑寰呭畬缇庣殑鏃舵満銆傚氨浠庤繖涓€鍒诲紑濮嬧€斺€旇涓€椤典功銆佸啓涓€鍙ヨ瘽銆佽蛋涓€鍗冩銆傚井灏忕殑寮€濮嬪氨鏄叏閮ㄣ€?, category: '鑷垜鎴愰暱'),
        const CognitiveCard(id: 405, title: '澶辫触鏄暟鎹笉鏄畾涔?, subtitle: '姣忎竴娆″け璐ラ兘鍦ㄥ憡璇変綘涓嬩竴姝ユ€庝箞璧?, content: '澶辫触涓嶆槸涓€涓爣绛撅紝鑰屾槸涓€鏉′俊鎭€傚畠鍛婅瘔浣犺繖鏉¤矾涓嶉€氾紝璇锋崲涓€鏉°€傛敹闆嗘暟鎹紝璋冩暣绛栫暐锛岀户缁墠杩涖€?, category: '鑷垜鎴愰暱'),
        const CognitiveCard(id: 406, title: '鑸掗€傚湀鐨勮竟缂樻槸鎴愰暱鍖?, subtitle: '涓€鐐圭偣璺ㄥ嚭鑸掗€傚湀', content: '涓嶉渶瑕佺珛鍒昏窇鍑鸿垝閫傚湀銆傛瘡澶╁線澶栬繄鍑轰竴灏忔锛氬拰鏂版湅鍙嬭涓€鍙ヨ瘽銆佸皾璇曚竴閬撴柊鑿溿€傚井灏忕殑鎸戞垬鏄渶濂界殑缁冧範銆?, category: '鑷垜鎴愰暱'),
        const CognitiveCard(id: 407, title: '涔犳儻鐨勫姏閲?, subtitle: '浣犳瘡澶╅兘鍦ㄥ閫犺嚜宸?, content: '鎴愬姛涓嶆槸涓€鏃剁垎鍙戯紝鑰屾槸姣忓ぉ寰皬涔犳儻鐨勫鍒┿€備粖澶╂瘮鏄ㄥぉ濂?%锛屼竴骞村悗浣犲皢寮哄ぇ37鍊嶃€?, category: '鑷垜鎴愰暱'),
        const CognitiveCard(id: 408, title: '鐩镐俊杩囩▼', subtitle: '鏈変簺绉嶅瓙闇€瑕佹椂闂存墠鑳藉彂鑺?, content: '浣犵幇鍦ㄧ湅涓嶅埌鐨勮繘姝ワ紝姝ｅ湪鍦颁笅鎮勬倓鐢熸牴銆傜浉淇′綘浠樺嚭鐨勬瘡涓€鍒嗛挓锛屽畠浠兘鍦ㄧН钃勫姏閲忋€?, category: '鑷垜鎴愰暱'),
        const CognitiveCard(id: 409, title: '浣犵殑鑺傚鐙竴鏃犱簩', subtitle: '涓嶅悓鑺辨湹鍦ㄤ笉鍚岀殑瀛ｈ妭鐩涘紑', content: '鏈変汉30宀佸姛鎴愬悕灏憋紝鏈変汉50宀佹墠鎵惧埌鐑埍銆備綘鐨勮妭濂忎笉闇€瑕佸拰鍒汉鍚屾锛屽湪浣犵殑鏃跺尯閲岋紝涓€鍒囬兘鍑嗘椂銆?, category: '鑷垜鎴愰暱'),
        const CognitiveCard(id: 410, title: '1%鐨勮繘姝ヤ篃鏄繘姝?, subtitle: '涓嶈杞昏寰皬鐨勬敼鍙?, content: '姣忓ぉ杩涙1%鐪嬭捣鏉ュ井涓嶈冻閬擄紝浣嗕竴涓湀鍚庡氨鏄?0%鐨勮穬鍗囥€傚井灏忕殑绉疮浼氬甫鏉ュ法澶х殑鍙樺寲銆?, category: '鑷垜鎴愰暱'),
        const CognitiveCard(id: 411, title: '鐥涜嫤鏄€佸笀鐨勪吉瑁?, subtitle: '姣忎竴娆＄棝鑻﹂兘鍦ㄦ暀浣犻噸瑕佺殑涓€璇?, content: '褰撲笅鐨勭棝鑻﹁浣犳兂閫冿紝浣嗗畠寰€寰€甯︾粰浣犳渶澶х殑鎴愰暱銆傚洖澶寸湅鏃讹紝浣犱細鎰熸縺閭ｄ簺鏈€闅剧殑鏃ュ瓙銆?, category: '鑷垜鎴愰暱'),
        const CognitiveCard(id: 412, title: '浣犳瘮浣犳兂璞＄殑寮哄ぇ', subtitle: '浣庝及鑷繁鏄墍鏈変汉鐨勯€氱梾', content: '浜虹被涔犳儻浜庝綆浼拌嚜宸辩殑闊ф€с€傝浣忎綘鏇剧粡绌胯秺杩囩殑椋庢毚鈥斺€旈偅浜涚粡鍘嗗凡缁忚瘉鏄庯紝浣犳瘮鎯宠薄涓己澶у緱澶氥€?, category: '鑷垜鎴愰暱'),
      ],
    },
  ];
}

