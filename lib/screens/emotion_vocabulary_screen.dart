
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/emotions.dart';
import '../services/purchase_service.dart';

class _EmotionWord {
  final String name; final String definition; final String example; final String bodyFeeling;
  const _EmotionWord(this.name, this.definition, this.example, this.bodyFeeling);
}

class EmotionVocabularyScreen extends StatefulWidget {
  const EmotionVocabularyScreen({super.key});
  @override State<EmotionVocabularyScreen> createState() => _EmotionVocabularyScreenState();
}

class _EmotionVocabularyScreenState extends State<EmotionVocabularyScreen> {
  static final Map<String, List<_EmotionWord>> _vocabulary = {
    '开心': [
      const _EmotionWord('欢乐', '发自内心的喜悦与快乐', '和朋友在一起的时光总是充满欢乐。', '笑容灿烂，身体轻盈'),
      const _EmotionWord('愉悦', '温和而持久的舒服感受', '午后阳光洒在身上，心情格外愉悦。', '嘴角微扬，周身放松'),
      const _EmotionWord('欣喜', '因好事发生而产生的雀跃心情', '收到录取通知的那一刻，欣喜若狂。', '心跳加速，想跳起来'),
      const _EmotionWord('畅快', '尽情尽兴的快乐释放', '在大雨中奔跑，感到无比畅快。', '张开双臂，放声大笑'),
      const _EmotionWord('喜悦', '内心深处涌出的纯然快乐', '看到孩子的笑脸，心中充满喜悦。', '眉眼弯弯，心里暖暖的'),
      const _EmotionWord('舒心', '放下烦恼后的轻松愉快', '泡个热水澡，什么都不想，特别舒心。', '身体放松，长长舒一口气'),
      const _EmotionWord('甜蜜', '被爱意包围的幸福滋味', '收到惊喜礼物，心里甜甜的。', '忍不住笑，脸微微发红'),
      const _EmotionWord('痛快', '尽情尽兴的畅快感', '大汗淋漓之后，说不出的痛快。', '浑身舒畅，笑着喘气'),
    ],
    '平静': [
      const _EmotionWord('安宁', '内心无扰的平静状态', '清晨的公园里，享受片刻安宁。', '呼吸均匀，心如止水'),
      const _EmotionWord('从容', '面对一切时的不慌不忙', '无论发生什么，她总是从容不迫。', '动作舒缓，表情安详'),
      const _EmotionWord('淡然', '看淡一切的豁达心态', '经历了风浪，对得失变得淡然。', '目光平和，不喜不悲'),
      const _EmotionWord('平和', '不争不抢的内心安稳', '与自己和解，与世界平和相处。', '呼吸稳定，面容舒展'),
      const _EmotionWord('静谧', '四周安静带来的内心宁静', '深夜的图书馆，只有翻书的静谧。', '动作轻柔，怕打破宁静'),
      const _EmotionWord('笃定', '心中有数的确定感', '做出决定后内心格外笃定。', '步伐稳健，眼神坚定'),
      const _EmotionWord('松弛', '不紧绷的自在状态', '假期醒来，整个人松弛了下来。', '肌肉松软，眉头舒展'),
    ],
    '兴奋': [
      const _EmotionWord('激动', '因期待或好消息而心潮澎湃', '演唱会开场，激动得尖叫。', '心跳如鼓，手心出汗'),
      const _EmotionWord('雀跃', '像小鸟一样轻盈的快乐', '听到周末去旅行，雀跃不已。', '蹦蹦跳跳，满脸放光'),
      const _EmotionWord('狂热', '极度投入的激情状态', '球迷为进球陷入了狂热。', '全身沸腾，忘情呐喊'),
      const _EmotionWord('振奋', '受到鼓舞后的昂扬斗志', '听完激励演讲，感觉特别振奋。', '挺直腰板，眼里有光'),
      const _EmotionWord('澎湃', '内心激荡的汹涌能量', '看到国旗升起的瞬间，心潮澎湃。', '热血上涌，眼眶发热'),
      const _EmotionWord('激昂', '充满干劲的亢奋状态', '战鼓声中，士气激昂。', '声音洪亮，步伐有力'),
      const _EmotionWord('亢奋', '过度兴奋的不能自已', '通宵赶完项目，亢奋得睡不着。', '大脑停不下来，毫无睡意'),
    ],
    '感恩': [
      const _EmotionWord('感激', '对他人善意的深切感谢', '感谢你在困难的时候伸出援手。', '眼眶微热，心头一暖'),
      const _EmotionWord('珍惜', '意识到美好而想紧紧握住', '离别后才懂得珍惜相聚。', '轻轻颔首，语气温柔'),
      const _EmotionWord('感动', '被真诚或美好所触动', '看到陌生人的善意，莫名感动。', '鼻头一酸，心里发热'),
      const _EmotionWord('温暖', '被爱与被善待的暖暖暖意', '回家时一碗热汤，心里无比温暖。', '全身暖洋洋，想要微笑'),
      const _EmotionWord('庆幸', '为躲过不幸而感谢命运', '幸好那天没有放弃，真庆幸。', '长舒一口气，拍拍胸口'),
      const _EmotionWord('敬畏', '面对伟大事物时的肃然起敬', '面对浩瀚星空，心中涌起敬畏。', '呼吸放缓，心境开阔'),
    ],
    '满足': [
      const _EmotionWord('知足', '对已有的一切感到足够', '粗茶淡饭，也心满意足。', '面带微笑，内心充盈'),
      const _EmotionWord('充实', '生活饱满而有意义的踏实感', '完成一天工作，感到格外充实。', '身体微倦但精神饱满'),
      const _EmotionWord('惬意', '悠闲自在的舒适享受', '周末下午，一杯茶一本书，十分惬意。', '窝在沙发里，不想动弹'),
      const _EmotionWord('欣慰', '看到付出有结果时的宽慰', '孩子终于懂事了，心里很欣慰。', '嘴角含笑，眼角微湿'),
      const _EmotionWord('丰盈', '内心富足而饱满的状态', '被善意包围着，内心丰盈。', '深呼吸，感觉被充满'),
      const _EmotionWord('圆满', '一切都刚刚好的完美感受', '一家人围坐在一起，感觉很圆满。', '心中暖暖的，别无他求'),
    ],
    '期待': [
      const _EmotionWord('憧憬', '对美好未来的向往', '憧憬着毕业后的自由生活。', '眼神发亮，嘴角上扬'),
      const _EmotionWord('盼望', '急切地等待好事发生', '数着日子盼望假期的到来。', '时不时看时间，坐不住'),
      const _EmotionWord('渴望', '对某件事强烈的向往', '渴望得到父亲的认可。', '心里痒痒的，暗暗使劲'),
      const _EmotionWord('期盼', '带着温柔的盼望等待', '期盼与远方的人重逢。', '看着远方，默默微笑'),
      const _EmotionWord('希冀', '对未来抱持的希望', '无论多难，心中始终有希冀。', '眼神坚定，暗自鼓劲'),
    ],
    '一般': [
      const _EmotionWord('平淡', '没有大起大落的日常状态', '日子就这样平淡地过着。', '表情平静，动作如常'),
      const _EmotionWord('如常', '和平时一样的普通一天', '今天没什么特别的，一切如常。', '状态平稳，不起波澜'),
      const _EmotionWord('寻常', '日常的平凡时刻', '寻常的日子里也有细微的温暖。', '不紧不慢，按部就班'),
      const _EmotionWord('平常', '不好不坏的真实状态', '今天就是很平常的一天。', '内心无波，安于此刻'),
    ],
    '迷茫': [
      const _EmotionWord('困惑', '对事物无法理解的疑惑', '为什么努力了却没有结果？', '眉头微蹙，陷入沉思'),
      const _EmotionWord('彷徨', '不知该往哪走的游移不定', '站在十字路口，内心彷徨。', '来回踱步，心神不定'),
      const _EmotionWord('迷失', '找不到方向和意义的失落', '在都市繁华中渐渐迷失了自己。', '目光涣散，脚步迟疑'),
      const _EmotionWord('茫然', '面对未知时的不知所措', '突然不知道下一步该怎么走。', '站着发呆，脑子空白'),
      const _EmotionWord('纠结', '在选项中反复拉扯的心累', '选A还是选B？越想越纠结。', '抓头发，来回踱步'),
      const _EmotionWord('无措', '面对变化时的慌乱', '计划突然被打乱，一时有些无措。', '手不知道该放在哪里'),
    ],
    '无聊': [
      const _EmotionWord('乏味', '对当前事物提不起兴趣', '会议冗长乏味，让人昏昏欲睡。', '哈欠连连，眼神放空'),
      const _EmotionWord('厌倦', '重复带来的疲惫感', '日复一日的重复让人厌倦。', '无精打采，叹气连连'),
      const _EmotionWord('空虚', '心里空荡荡的没着落', '刷了一下午手机，反而觉得空虚。', '瘫在沙发上，眼神空洞'),
      const _EmotionWord('沉闷', '毫无生气的压抑感', '阴雨天的午后，空气都变得沉闷。', '提不起劲，想睡又睡不着'),
      const _EmotionWord('无趣', '什么都不好玩的感觉', '这片子太无趣了，看半小时就想走。', '不停看时间，坐不住'),
    ],
    '焦虑': [
      const _EmotionWord('紧张', '面对压力时的紧绷状态', '上台前手心出汗，紧张得说不出话。', '手心冒汗，心跳加快'),
      const _EmotionWord('不安', '隐隐约约的不踏实感', '总觉得有什么不好的事要发生。', '坐立不安，辗转反侧'),
      const _EmotionWord('惶恐', '面对未知的深深不安', '黑暗中独自一人，心中惶恐不已。', '身体发抖，想抓住什么'),
      const _EmotionWord('忧心', '为某件事持续担忧', '体检报告还没出来，忧心忡忡。', '吃不下饭，心里挂着'),
      const _EmotionWord('焦灼', '等待结果时的煎熬', '面试后等通知的每一天都焦灼难耐。', '坐立不安，反复检查手机'),
      const _EmotionWord('恐慌', '突如其来的强烈恐惧', '看到检查结果时，一阵恐慌袭来。', '大脑空白，手脚发凉'),
      const _EmotionWord('忐忑', '七上八下的不放心', '考试前的夜晚，心里忐忑不安。', '胃不舒服，睡不安稳'),
    ],
    '难过': [
      const _EmotionWord('失落', '期待落空后的空虚感', '错过重要机会，心里空落落的。', '胸口发闷，肩膀下垂'),
      const _EmotionWord('悲伤', '因失去而产生的深沉哀伤', '告别那一刻，悲伤涌上心头。', '眼眶湿润，喉头发紧'),
      const _EmotionWord('心酸', '为某事感到难过与心疼', '看到流浪的小动物，心酸不已。', '鼻头一酸，眼眶泛红'),
      const _EmotionWord('委屈', '不被理解的隐忍难过', '明明很努力却被误解，说不出的委屈。', '喉咙发紧，想哭但忍住'),
      const _EmotionWord('苦涩', '难以言说的辛酸与无奈', '想起那段艰难的岁月，心中满是苦涩。', '口中发苦，眉头紧皱'),
      const _EmotionWord('哀伤', '深沉的忧伤与无力', '听着那首老歌，一阵哀伤涌过心头。', '默默流泪，不想说话'),
      const _EmotionWord('落寞', '繁华过后的冷清', '聚会的热闹散去，独自感到落寞。', '脚步变沉，不想说话'),
    ],
    '生气': [
      const _EmotionWord('烦躁', '被反复干扰后的不耐烦', '手机不停响，越来越烦躁。', '眉头紧锁，想摔东西'),
      const _EmotionWord('恼怒', '被冒犯后的明显生气', '对方的无理态度着实让人恼怒。', '脸红，呼吸急促'),
      const _EmotionWord('愤懑', '不公对待后的压抑怒火', '功劳被抢走，愤懑难平。', '胸口堵，拳头握紧'),
      const _EmotionWord('不满', '对现状的抱怨与不甘', '付出与回报不成正比，内心不满。', '腹中隐隐作痛'),
      const _EmotionWord('憋屈', '有气发不出的压抑', '明明没错却被指责，实在憋屈。', '喉咙像被什么堵住'),
      const _EmotionWord('激愤', '因不公而爆发的强烈情绪', '看到真相被掩盖，群众激愤不已。', '声音发抖，肾上腺素飙升'),
    ],
    '疲惫': [
      const _EmotionWord('劳累', '身体被过度使用', '连续加班后，身体极度劳累。', '浑身酸痛，只想躺下'),
      const _EmotionWord('倦怠', '身心俱疲的无力感', '对什么都提不起劲，深深的倦怠。', '眼皮沉重，行动迟缓'),
      const _EmotionWord('虚脱', '能量耗尽后的极度虚弱', '高强度运动后几乎虚脱。', '四肢无力，头晕眼花'),
      const _EmotionWord('困倦', '昏昏欲睡的疲乏感', '午后阳光暖暖的，一阵困倦袭来。', '眼皮打架，想趴下'),
      const _EmotionWord('耗竭', '身心资源被掏空', '连续高压工作，感觉被彻底耗竭。', '大脑迟钝，什么都不想'),
      const _EmotionWord('无力', '一点力气都没有', '哭过之后，全身酸软无力。', '软软地靠着，不想动'),
    ],
    '孤独': [
      const _EmotionWord('孤单', '独自一人的寂寥感', '一个人吃饭回家，有些孤单。', '下意识抱紧自己'),
      const _EmotionWord('思念', '对不在身边的人深深牵挂', '翻看旧照片，心里满是思念。', '嘴角带笑但眼眶湿润'),
      const _EmotionWord('隔绝', '与世界失去连接的感觉', '明明在人群中，却感到彻底隔绝。', '退到角落，低头沉默'),
      const _EmotionWord('疏离', '与环境格格不入的陌生感', '在热闹中感到深深的疏离。', '下意识拉开距离'),
      const _EmotionWord('寂寥', '深夜独自一人的清冷感', '深夜醒来，四周一片寂寥。', '蜷缩起来，听自己的心跳'),
    ],
    '压力': [
      const _EmotionWord('压迫', '被重担压得喘不过气', 'deadline临近，压迫感很强。', '胸闷气短，肩膀僵硬'),
      const _EmotionWord('负重', '承担太多时的沉重感', '所有人都依赖你，不能倒下。', '步伐沉重，叹长气'),
      const _EmotionWord('紧绷', '一直无法放松的紧张状态', '持续高压，神经一直紧绷。', '肌肉僵硬，容易发火'),
      const _EmotionWord('急躁', '烦躁不安的急切状态', '时间越来越紧，人也越来越急躁。', '坐不住，说话变快'),
      const _EmotionWord('透不过气', '被压力淹没的窒息感', '事情一件接一件，快透不过气了。', '胸闷，深呼吸也缓解不了'),
    ],
  };

  String _dailyWord = '';
  String _dailyCategory = '';
  String _selectedCategory = '';
  static const _freeCategories = ['开心', '平静', '一般', '难过'];

  @override void initState() { super.initState(); _selectedCategory = _displayCategories.first; _setRandomWord(); }

  List<String> get _displayCategories {
    if (PurchaseService().isPro) return _vocabulary.keys.toList();
    return _vocabulary.keys.where((k) => _freeCategories.contains(k)).toList();
  }

  void _setRandomWord() {
    var all = <_EmotionWord>[];
    for (var entry in _vocabulary.entries) { all.addAll(entry.value); }
    if (all.isEmpty) return;
    var idx = DateTime.now().millisecondsSinceEpoch % all.length;
    _dailyWord = all[idx].name;
    for (var entry in _vocabulary.entries) { for (var w in entry.value) { if (w.name == _dailyWord) { _dailyCategory = entry.key; return; } } }
  }

  void _setDailyWord(String word, String category) { setState(() { _dailyWord = word; _dailyCategory = category; }); }

  String _categoryEmoji(String c) {
    var et = EmotionType.values.firstWhere((e) => e.label == c, orElse: () => EmotionType.neutral);
    return et.emoji;
  }

  @override Widget build(BuildContext context) {
    var isDark = Theme.of(context).brightness == Brightness.dark;
    var cats = _displayCategories;
    return Scaffold(
      backgroundColor: isDark ? MirrorColors.darkBackground : MirrorColors.background,
      appBar: AppBar(title: const Text('情绪词库')),
      body: Column(children: [
        _buildDailyBanner(isDark),
        if (!PurchaseService().isPro) _buildFreeHint(isDark),
        _buildCategoryRow(isDark, cats),
        Expanded(child: _selectedCategory.isEmpty
            ? const SizedBox.shrink()
            : _buildWordList(isDark, _vocabulary[_selectedCategory]!, _selectedCategory)),
      ]),);
  }

    Widget _buildCategoryRow(bool isDark, List<String> cats) {
    if (cats.isEmpty) return const SizedBox.shrink();
    // 每行5个，排成3行
    var rows = <List<String>>[];
    for (var i = 0; i < cats.length; i += 5) {
      rows.add(cats.sublist(i, (i + 5 > cats.length) ? cats.length : i + 5));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((cat) {
              var sel = cat == _selectedCategory;
              var clr = MirrorColors.emotionColor(cat);
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: Container(
                  width: 62,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? clr.withValues(alpha: 0.25) : (isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF0EDE8)),
                    borderRadius: BorderRadius.circular(14),
                    border: sel ? Border.all(color: clr, width: 1.5) : null,
                  ),
                  child: Column(children: [
                    Text(_categoryEmoji(cat), style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 2),
                    Text(cat, style: TextStyle(fontSize: 11,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                      color: sel ? clr : (isDark ? Colors.grey[300] : Colors.grey[600]))),
                  ]),
                ),
              );
            }).toList(),
          ),
        );
      }).toList()),
    );
  }Widget _buildDailyBanner(bool isDark) {
    var clr = MirrorColors.emotionColor(_dailyCategory);
    return Container(
      width: double.infinity, margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [clr.withValues(alpha: 0.3), const Color(0x33D4C5E2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(14), border: Border.all(color: clr.withValues(alpha: 0.3))),
      child: Row(children: [
        Text(_categoryEmoji(_dailyCategory), style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('今日推荐 · ' + _dailyWord, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: clr)),
          const SizedBox(height: 2),
          Text('长按任意词汇可替换今日推荐', style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[500])),
        ])),
      ]),);
  }

  Widget _buildFreeHint(bool isDark) {
    return Container(
      width: double.infinity, margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0x33D4C5E2), borderRadius: BorderRadius.circular(8)),
      child: Text('免费展示 4 类 · 解锁 Pro 查看全部 ' + _vocabulary.length.toString() + ' 类',
        style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : MirrorColors.primaryDark)),);
  }

  Widget _buildWordList(bool isDark, List<_EmotionWord> words, String category) {
    var clr = MirrorColors.emotionColor(category);
    return ListView.separated(padding: const EdgeInsets.all(16),
      itemCount: words.length, separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        var w = words[i];
        var isDaily = w.name == _dailyWord;
        return Card(
          child: InkWell(borderRadius: BorderRadius.circular(12),
            onTap: () => _showWordDetail(context, w, category),
            onLongPress: () { _setDailyWord(w.name, category); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已设为今日: ' + w.name), duration: Duration(seconds: 1))); },
            child: Padding(padding: const EdgeInsets.all(14),
              child: Row(children: [
                Container(width: 40, height: 40,
                  decoration: BoxDecoration(color: clr.withValues(alpha: isDaily ? 0.4 : 0.15), borderRadius: BorderRadius.circular(10)),
                  child: Center(child: Text(isDaily ? '★' : (i+1).toString(), style: TextStyle(fontSize: isDaily ? 18 : 14, fontWeight: FontWeight.w600, color: clr)))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(w.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 2),
                  Text(w.definition, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                ])),
              ]))),);
      },);
  }

    void _showWordDetail(BuildContext context, _EmotionWord word, String category) {
    var clr = MirrorColors.emotionColor(category);
    var catEmoji = _categoryEmoji(category);

    Widget titleWidget = Center(child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(color: clr.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
      child: Text(catEmoji + ' ' + word.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: clr))));

    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        titleWidget,
        const SizedBox(height: 16),
        _detailRow('词解', word.definition, clr),
        const SizedBox(height: 10),
        _detailRow('例句', word.example, clr),
        const SizedBox(height: 10),
        _detailRow('身体感受', word.bodyFeeling, clr),
        const SizedBox(height: 16),
        Center(child: SizedBox(width: double.infinity, child: OutlinedButton.icon(
          onPressed: () { _setDailyWord(word.name, category); Navigator.pop(ctx); },
          icon: const Icon(Icons.push_pin, size: 16),
          label: const Text('设为今日推荐'),
          style: OutlinedButton.styleFrom(foregroundColor: clr, side: BorderSide(color: clr))))),
      ]),
    ));
  }Widget _detailRow(String label, String content, Color? clr) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: clr ?? Colors.grey[500])),
      const SizedBox(height: 4), Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
    ]);
  }
}
