import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/purchase_service.dart';

/// 情绪词汇拓展 — 情绪粒度训练
class EmotionVocabularyScreen extends StatefulWidget {
  const EmotionVocabularyScreen({super.key});

  @override
  State<EmotionVocabularyScreen> createState() => _EmotionVocabularyScreenState();
}

class _EmotionVocabularyScreenState extends State<EmotionVocabularyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _collected = {}; // 已收藏词汇
  String _dailyWord = ''; // 今日推荐词

  // ==================== 情绪词汇库 ====================
  static final Map<String, List<_EmotionWord>> _vocabulary = {
    '开心': [
      _EmotionWord('满足', '需求得到实现后的充实感', '完成一天的工作后，躺在沙发上，感到深深的满足。', '胸口温暖，嘴角不自觉上扬'),
      _EmotionWord('欣慰', '看到努力得到回报时的安心', '看到孩子健康成长，父母脸上露出欣慰的笑容。', '心跳平稳，呼吸深长'),
      _EmotionWord('惬意', '舒适自在的愉悦状态', '午后阳光透过窗户，一杯茶一本书，无比惬意。', '浑身放松，眉头舒展'),
      _EmotionWord('充实', '时间被有意义地填满的感受', '忙碌但高效的一天结束后，感到格外充实。', '身体略疲惫但精神饱满'),
      _EmotionWord('感恩', '对所得之物心存感谢', '回首这一年，对陪伴在身边的人充满感恩。', '胸口微微发热，眼眶可能湿润'),
      _EmotionWord('雀跃', '抑制不住的兴奋与期待', '收到梦寐以求的offer，内心雀跃不已。', '心跳加速，想要跳起来'),
      _EmotionWord('自在', '无拘无束的轻松感', '一个人旅行，随心所欲，无比自在。', '呼吸自由，步伐轻快'),
      _EmotionWord('欢欣', '发自内心的喜悦', '久别重逢，满心欢欣，言语都无法表达。', '笑容藏不住，眼睛发亮'),
    
      _EmotionWord('振奋', '精神焕发、充满力量的昂扬状态', '听到这个好消息，整个人都振奋了起来。', '背脊挺直，眼睛发亮，充满干劲'),
      _EmotionWord('敬畏', '面对崇高或伟大事物时的肃然起敬', '面对浩瀚星空，心中涌起深深的敬畏。', '呼吸放缓，心境开阔'),
      _EmotionWord('陶醉', '沉浸在美好体验中的忘我状态', '音乐会上，她闭上眼睛，完全陶醉在旋律中。', '身体微微摇摆，表情沉醉'),
      _EmotionWord('痛快', '尽情尽兴的畅快感', '打完一场球，大汗淋漓，说不出的痛快。', '浑身舒畅，脸上挂着笑意'),
    ],
    '悲伤': [
      _EmotionWord('失落', '期待落空后的空虚感', '错过了一次重要的机会，心里空落落的。', '胸口发闷，肩膀下垂'),
      _EmotionWord('怅然', '若有所失的淡淡忧伤', '老歌响起，想起从前，一丝怅然浮上心头。', '目光放空，呼吸变慢'),
      _EmotionWord('孤独', '渴望连接却无法连接的状态', '人群中的狂欢，却感到无可言说的孤独。', '身体退缩，想抱紧自己'),
      _EmotionWord('怀念', '对美好过往的温柔回忆', '翻看旧照片，怀念那些回不去的时光。', '嘴角带笑但眼眶湿润'),
      _EmotionWord('遗憾', '对未做之事的惋惜', '如果当时勇敢一点，也许就不会有今天的遗憾。', '心里有块石头压着'),
      _EmotionWord('委屈', '不被理解时的隐忍难过', '明明很努力却被误解，心里说不出的委屈。', '喉咙发紧，想哭但忍住'),
      _EmotionWord('落寞', '繁华过后的冷清', '聚会的热闹散去，独自一人感到落寞。', '脚步变沉，不想说话'),
      _EmotionWord('心酸', '为他人或自己的遭遇感到难过', '看到流浪的小动物，心里一阵心酸。', '鼻头酸涩，心口刺痛'),
    
      _EmotionWord('苦涩', '难以言说的辛酸与无奈交织', '想起那段艰难的岁月，心中满是苦涩。', '口中发苦，眉头紧皱'),
      _EmotionWord('惆怅', '若有所失、茫然无依的惆怅', '告别故友，独自走在街头，怅然若失。', '步伐缓慢，目光游离'),
      _EmotionWord('颓丧', '丧失信心和斗志的低落状态', '接连失败后，他变得颓丧，什么都不想做。', '身体蜷缩，低头不语'),
      _EmotionWord('怨愤', '因受到不公正对待而产生的愤怒与委屈', '被无故裁员，心中怨愤难平。', '拳头紧握，胸闷气短'),
    ],
    '愤怒': [
      _EmotionWord('烦躁', '被反复干扰后产生的不耐烦', '手机不停弹出消息，越来越烦躁。', '眉头紧锁，想要摔东西'),
      _EmotionWord('愤懑', '内心的不平与压抑', '明明是自己的功劳却被抢走，愤懑难平。', '胸口堵得慌，拳头不自觉握紧'),
      _EmotionWord('恼怒', '被冒犯后的生气', '对方无理取闹的态度让人恼怒。', '脸发红，呼吸急促'),
      _EmotionWord('不满', '对现状的抱怨与不甘', '付出与回报不成正比，内心充满不满。', '腹中隐隐作痛'),
      _EmotionWord('憎恶', '对不公或恶行的强烈反感', '看到欺凌弱小的行为，心中涌起憎恶。', '全身紧绷，牙齿咬紧'),
      _EmotionWord('憋屈', '有气发不出的压抑', '明知道自己没错却被指责，实在憋屈。', '喉咙像是被什么堵住'),
      _EmotionWord('激愤', '因不公平而爆发的强烈情绪', '看到真相被掩盖，群众激愤不已。', '肾上腺素飙升，声音发抖'),
      _EmotionWord('怨气', '长期积累的不满', '一直默默承受，心里攒了太多怨气。', '肩膀酸痛，胸闷气短'),
    
      _EmotionWord('羞愧', '因自身行为或状态不符合期望而产生的羞耻感', '当众被指出错误，羞愧得满脸通红。', '脸烧得厉害，想找个地缝钻进去'),
      _EmotionWord('屈辱', '人格受到践踏后的极度难受', '被当众羞辱的那一刻，心中充满屈辱。', '全身僵硬，心口剧痛'),
      _EmotionWord('放下', '放下怨恨后的轻松与解脱', '终于原谅了那个人，心中一阵释然。', '长舒一口气，肩头轻松'),
      _EmotionWord('悲悯', '对他人苦难的深切同情与关怀', '看到灾区孩子的眼神，心中涌起悲悯。', '眼眶湿润，想做点什么'),
    ],
    '恐惧': [
      _EmotionWord('紧张', '面对压力时的紧绷状态', '上台前手心出汗，紧张得忘了台词。', '手心冒汗，心跳加快'),
      _EmotionWord('不安', '隐隐约约的不踏实感', '总觉得有什么不好的事要发生，心神不宁。', '胃部不适，坐立难安'),
      _EmotionWord('惶恐', '面对未知时的深深恐惧', '黑暗中独自行走，内心惶恐不已。', '身体发抖，想要逃跑'),
      _EmotionWord('焦虑', '对未来的过度担忧', '周日的晚上，对新的一周感到焦虑。', '心慌，呼吸短促'),
      _EmotionWord('胆怯', '面对挑战时的退缩', '想举手发言却因为胆怯而放弃。', '身体僵硬，说话声音变小'),
      _EmotionWord('畏惧', '对强大力量的害怕', '面对严厉的上司，心中充满畏惧。', '眼神躲闪，想要缩小自己'),
      _EmotionWord('惊惶', '突发状况下的慌乱', '突然听到巨响，一时间惊惶失措。', '本能躲闪，大脑空白'),
      _EmotionWord('忐忑', '等待结果时的七上八下', '考试前的夜晚，心里忐忑不安。', '胃里翻江倒海，睡不安稳'),
    
      _EmotionWord('疏离', '与他人或环境产生隔阂的陌生感', '在热闹的聚会上，却感到深深的疏离。', '下意识拉开距离，不愿交流'),
      _EmotionWord('依恋', '过度依赖某人而产生的分离恐惧', '每次分别都感到强烈的不安与依恋。', '想紧紧抓住对方不放'),
      _EmotionWord('愧疚', '因亏欠他人而产生的自责与不安', '错过了孩子的成长，心中满是愧疚。', '心口发沉，不敢直视对方'),
      _EmotionWord('戒备', '对环境或他人保持警惕的防御状态', '独自走夜路时，本能地保持戒备。', '肌肉紧绷，时刻注意周围'),
    ],
    '惊讶': [
      _EmotionWord('惊喜', '出乎意料的美好体验', '生日当天收到了远方寄来的礼物，满满惊喜。', '睁大眼睛，嘴角上扬'),
      _EmotionWord('诧异', '对不合常理之事的疑问', '听到这个决定，大家都感到诧异。', '眉毛扬起，停顿片刻'),
      _EmotionWord('震撼', '被巨大的事物所冲击', '面对壮丽的自然景观，内心无比震撼。', '说不出话，全身起鸡皮疙瘩'),
      _EmotionWord('新奇', '对未知事物的好奇心', '第一次来到这座城市，一切都充满新奇。', '眼睛放光，四处张望'),
      _EmotionWord('惊叹', '对优秀事物的由衷赞美', '看到精美的艺术品，不由得发出惊叹。', '嘴巴微张，想鼓掌'),
      _EmotionWord('错愕', '突如其来的意外让人愣住', '听到离职的消息，大家都错愕了。', '呆住不动，脑子转不过来'),
    
      _EmotionWord('自怜', '对自己遭遇的同情与怜惜', '一个人撑了这么久，突然有些自怜。', '想要抱住自己，眼眶发酸'),
      _EmotionWord('彷徨', '在抉择面前迷茫无措的状态', '站在人生的十字路口，内心彷徨不已。', '来回踱步，心神不宁'),
      _EmotionWord('坦然', '问心无愧的平静与安定', '该做的都做了，结果如何都能坦然面对。', '呼吸平稳，神态从容'),
      _EmotionWord('豁达', '看开世事后的开阔心境', '经历了风风雨雨，反而变得更加豁达了。', '眉宇舒展，笑声爽朗'),
      _EmotionWord('自省', '向内审视自己的反思状态', '夜深人静时，习惯性地开始自省。', '安静独处，认真思考'),
      _EmotionWord('坚毅', '内心坚定、不为外界动摇的确信感', '虽然前路未知，但内心格外笃定。', '步伐有力，眼神坚定'),
    ],
    '平静': [
      _EmotionWord('安宁', '内心无波澜的平和', '夜晚公园散步，感受久违的安宁。', '呼吸均匀，肩部放松'),
      _EmotionWord('释然', '放下负担后的轻松', '终于想通了那件事，心中释然。', '长舒一口气，肩头一松'),
      _EmotionWord('淡然', '看透世事的从容', '经历得多了，面对得失反而淡然了。', '说话语速变慢，表情平静'),
      _EmotionWord('专注', '全神贯注的心流状态', '画画的时候世界仿佛都静下来了，无比专注。', '忘记时间，沉浸其中'),
      _EmotionWord('笃定', '心中有数的确定感', '做出决定后内心格外笃定。', '步伐稳健，眼神坚定'),
      _EmotionWord('松弛', '不紧绷的自在状态', '假期第一天的早晨，整个人松弛了下来。', '肌肉松软，眉头舒展'),
    
      _EmotionWord('不甘', '对未达成的目标心存遗憾与不服', '差一分就能通过，想起来还是不甘心。', '心里像有什么东西硌着'),
      _EmotionWord('隐忍', '强忍着不说、不表现出来的克制状态', '为了大局，他选择了隐忍不发。', '咬紧牙关，拳头在袖中握紧'),
      _EmotionWord('恻隐', '对弱者或受害者产生的天然同情心', '看着乞讨的老人，恻隐之心油然而生。', '心口微微发酸，想伸手帮忙'),
      _EmotionWord('执念', '无法放下的强烈坚持与牵挂', '这么多年了，心中那份执念仍然放不下。', '反复思量，难以释怀'),
      _EmotionWord('释怀', '终于放下的轻松与释然', '多年后重逢一笑，那些过往终于释怀了。', '嘴角带笑，心中一片澄澈'),
      _EmotionWord('顿悟', '瞬间领悟真相的通透感', '读到某句话时突然顿悟，原来如此。', '猛然抬头，眼睛一亮'),
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _vocabulary.length, vsync: this);
    _setDailyWord();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 根据日期设置每日推荐词
  void _setDailyWord() {
    final allWords = _vocabulary.values.expand((list) => list).toList();
    final seed = DateTime.now().day;
    _dailyWord = allWords[seed % allWords.length].name;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = _vocabulary.keys.toList();

    return Scaffold(
      backgroundColor: isDark ? MirrorColors.darkBackground : MirrorColors.background,
      appBar: AppBar(
        title: const Text('情绪词库'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: MirrorColors.primaryDark,
          unselectedLabelColor: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
          indicatorColor: MirrorColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: categories.map((c) {
            final emoji = _categoryEmoji(c);
            return Tab(text: '$emoji $c');
          }).toList(),
        ),
      ),
      body: Column(
        children: [
          // 今日推荐词
          _buildDailyBanner(isDark),
          // Tab 内容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: categories.map((category) {
                final words = _vocabulary[category]!;
                return _buildWordList(isDark, words, category);
              }).toList(),
            ),
          ),
          // Pro 锁定区
          if (!PurchaseService().isPro) _buildProBanner(isDark),
        ],
      ),
    );
  }

  /// 今日推荐横幅
  Widget _buildDailyBanner(bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MirrorColors.primaryLight.withValues(alpha: 0.4),
            MirrorColors.accentLight.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('📖', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '今日情绪词汇',
                  style: TextStyle(fontSize: 12, color: MirrorColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  _dailyWord,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: MirrorColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          if (_collected.contains(_dailyWord))
            const Icon(Icons.bookmark, color: MirrorColors.accent),
        ],
      ),
    );
  }

  /// 词汇列表（Pro 用户显示全部，免费用户显示每类前 N 个）
  Widget _buildWordList(bool isDark, List<_EmotionWord> words, String category) {
    final isPro = PurchaseService().isPro;
    // 免费用户显示数量：惊讶/平静 6 个，其他 8 个
    final freeLimit = (category == '惊讶' || category == '平静') ? 6 : 8;
    final displayWords = isPro ? words : words.take(freeLimit).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: displayWords.length,
      itemBuilder: (context, index) {
        final word = displayWords[index];
        final isCollected = _collected.contains(word.name);
        return _buildWordCard(isDark, word, isCollected);
      },
    );
  }

  /// 词汇卡片
  Widget _buildWordCard(bool isDark, _EmotionWord word, bool isCollected) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => _showWordDetail(word),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          word.name,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          word.definition,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '例句：${word.example}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    if (isCollected) {
                      _collected.remove(word.name);
                    } else {
                      _collected.add(word.name);
                    }
                  });
                },
                icon: Icon(
                  isCollected ? Icons.bookmark : Icons.bookmark_border,
                  color: isCollected ? MirrorColors.accent : MirrorColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 词汇详情弹窗
  void _showWordDetail(_EmotionWord word) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(word.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: MirrorColors.primaryLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(word.definition,
                style: const TextStyle(fontSize: 14, color: MirrorColors.primaryDark)),
            ),
            const SizedBox(height: 16),
            const Text('例句', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: MirrorColors.textSecondary)),
            const SizedBox(height: 4),
            Text(word.example, style: TextStyle(fontSize: 14, height: 1.5, color: isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary)),
            const SizedBox(height: 16),
            const Text('身体感受', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: MirrorColors.textSecondary)),
            const SizedBox(height: 4),
            Text(word.bodyFeeling, style: TextStyle(fontSize: 14, height: 1.5, color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                if (_collected.contains(word.name)) {
                  _collected.remove(word.name);
                } else {
                  _collected.add(word.name);
                }
              });
              Navigator.pop(ctx);
            },
            child: Text(_collected.contains(word.name) ? '取消收藏' : '收藏词汇'),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('关闭')),
        ],
      ),
    );
  }

  String _categoryEmoji(String category) {
    switch (category) {
      case '开心': return '😊';
      case '悲伤': return '😢';
      case '愤怒': return '😤';
      case '恐惧': return '😨';
      case '惊讶': return '😲';
      case '平静': return '😌';
      default: return '💭';
    }
  }

  /// Pro 锁定区
  Widget _buildProBanner(bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MirrorColors.primaryLight.withValues(alpha: 0.4),
            MirrorColors.secondaryLight.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MirrorColors.primaryLight.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: MirrorColors.primaryDark.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Pro',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: MirrorColors.primaryDark),
                ),
              ),
              const SizedBox(width: 10),
              const Text('🔓', style: TextStyle(fontSize: 22)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '解锁 Pro 探索全部 72 词汇',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: MirrorColors.primaryDark),
          ),
          const SizedBox(height: 6),
          Text(
            '每个情绪类型扩展至 12 个精准词汇，附深度词解与场景例句',
            style: TextStyle(fontSize: 13, color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/pro'),
            style: ElevatedButton.styleFrom(
              backgroundColor: MirrorColors.primaryDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('立即解锁'),
          ),
        ],
      ),
    );
  }
}

/// 情绪词汇数据类
class _EmotionWord {
  final String name;
  final String definition;
  final String example;
  final String bodyFeeling;

  const _EmotionWord(this.name, this.definition, this.example, this.bodyFeeling);
}
