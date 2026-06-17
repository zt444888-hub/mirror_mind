import 'dart:math';
import 'dart:math';
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
    final random = Random(seed);
    return random.nextInt(cognitiveCards.length);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }


  /// 构建滑动窗口式页码指示器（最多显示 7 个点）
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
        // 左侧省略号
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
        // 可见点
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
        // 右侧省略号
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
        title: const Text('认知重构卡片'),
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
                  '今日推荐',
                  style: TextStyle(fontSize: 12, color: MirrorColors.textSecondary),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          // 卡片滑动区域
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

          // 进阶主题入口（Pro）
          _buildAdvancedPacks(isDark),
          const SizedBox(height: 8),

          // 页码指示器（滑动窗口，最多显示 7 个点）
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: _buildPageIndicators(isDark),
          ),

          // 操作按钮
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
                label: const Text('上一张'),
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
                label: const Text('今日推荐'),
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
                label: const Text('下一张'),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// 进阶主题区段（Pro 功能）
  Widget _buildAdvancedPacks(bool isDark) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: [
              const Text(
                '进阶主题',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
                        '${(pack['cards'] as List).length} 张卡片',
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
      'icon': '👥',
      'title': '社交场景',
      'cards': [
        const CognitiveCard(id: 101, title: '聚光灯效应', subtitle: '别人没你想象中那么关注你', content: '大多数人都忙于关注自己，他们并没有你想象的那么在意你的一举一动。你只是自己世界的中心，不是别人的。', category: '社交场景'),
        const CognitiveCard(id: 102, title: '小步暴露法', subtitle: '从小圈子开始，慢慢扩大舒适区', content: '不需要一次性面对大场面。从和一个人聊天开始，逐渐增加到小团体，每一步都是进步。', category: '社交场景'),
        const CognitiveCard(id: 103, title: '社交不是表演', subtitle: '做真实的自己，比讨好所有人更重要', content: '你不需要成为聚会上最有趣的人。真诚地倾听、自然地回应，这种舒适感会感染他人。', category: '社交场景'),
        const CognitiveCard(id: 104, title: '沉默并不可怕', subtitle: '安静也是一种参与方式', content: '对话中的停顿是正常的。沉默不代表尴尬，有时候它代表着思考。不必为每一秒的安静感到焦虑。', category: '社交场景'),
        const CognitiveCard(id: 105, title: '你不需要被所有人喜欢', subtitle: '20%的人喜欢你，你就赢了', content: '即使是最受欢迎的人，也有人对他们无感。把精力放在愿意接纳你的人身上。', category: '社交场景'),
        const CognitiveCard(id: 106, title: '准备三个话题就够', subtitle: '不需要完美剧本', content: '准备三个开放式问题（最近在忙什么/看过什么好电影/有什么好的咖啡店推荐），足够应对绝大多数社交场合。', category: '社交场景'),
        const CognitiveCard(id: 107, title: '紧张说明你在乎', subtitle: '紧张不是缺陷，而是投入的信号', content: '手心出汗、心跳加速——这些都是你在认真对待当下时刻的证明。把紧张重新理解为"在乎"。', category: '社交场景'),
        const CognitiveCard(id: 108, title: '微笑是最好的开场白', subtitle: '一个微笑胜过千言万语', content: '不需要完美的开场白。一个真诚的微笑就能释放善意，拉近人与人之间的距离。', category: '社交场景'),
        const CognitiveCard(id: 109, title: '接纳自己的内向', subtitle: '内向不是缺陷，而是一种力量', content: '内向的人善于深度倾听、观察细节。这个世界需要内向者的安静力量。', category: '社交场景'),
        const CognitiveCard(id: 110, title: '把注意力放在对方身上', subtitle: '关注别人时，你会忘记自己的不自在', content: '在社交场合感到紧张时，把注意力从"我表现得好不好"转移到"对方是一个怎样有趣的人"。', category: '社交场景'),
        const CognitiveCard(id: 111, title: '每一次社交都是一次练习', subtitle: '没有失败的社交', content: '不是每次交流都会完美，但每一次都是积累。即使是尴尬的对话，也在帮你修正下一次的方式。', category: '社交场景'),
        const CognitiveCard(id: 112, title: '他人评价不等于你', subtitle: '别人的眼光不能定义你是谁', content: '别人怎么看你是他们的选择。你是谁不由外围评价决定，而由你的行动和选择决定。', category: '社交场景'),
      ],
    },
    {
      'icon': '💼',
      'title': '职场压力',
      'cards': [
        const CognitiveCard(id: 201, title: '区分可控与不可控', subtitle: '把精力放在你能改变的事情上', content: '列一张表：左边写"我能控制的事"，右边写"我无法控制的事"。只看左边，对右边说"放手"。', category: '职场压力'),
        const CognitiveCard(id: 202, title: '学会说"不"', subtitle: '每一次说"不"，都是对自己说"是"', content: '你的时间和精力是有限的。对不必要的请求说"不"不是自私，而是对自己边界的尊重。', category: '职场压力'),
        const CognitiveCard(id: 203, title: '完成大于完美', subtitle: '80%的完成好过100%的未完成', content: '追求完美会让你陷入无尽的修改循环。先完成，再迭代。行动是最好的解药。', category: '职场压力'),
        const CognitiveCard(id: 204, title: '不把工作带回家', subtitle: '物理边界创造心理边界', content: '设定一个"下班仪式"：关闭电脑、换上便服、泡杯茶。用仪式感切断工作模式。', category: '职场压力'),
        const CognitiveCard(id: 205, title: '寻求帮助是能力不是软弱', subtitle: '懂求助的人走得更远', content: '没有人能独自完成一切。向同事寻求帮助说明你清楚自己的边界，这是成熟的表现。', category: '职场压力'),
        const CognitiveCard(id: 206, title: '同事评价不等于你', subtitle: '你的价值不由他人定义', content: '同事对你的看法只是一面镜子，镜子里看到的不是全部的真相。你的价值远不止于此。', category: '职场压力'),
        const CognitiveCard(id: 207, title: '设置边界', subtitle: '没有边界，就没有自我保护', content: '工作消息可以等到明天回复，周末可以不想工作的事。清晰的边界是对自己的尊重。', category: '职场压力'),
        const CognitiveCard(id: 208, title: '庆祝小胜利', subtitle: '每完成一件事都值得庆祝', content: '做完一个PPT、发完一封邮件、开完一个会——每一个小胜利都值得你对自己说一声"干得好"。', category: '职场压力'),
        const CognitiveCard(id: 209, title: '不比较', subtitle: '别人的进度与你无关', content: '同事升职加薪不等于你落后了。每个人走在自己的时区里，你的节奏不紧也不慢，刚刚好。', category: '职场压力'),
        const CognitiveCard(id: 210, title: '工作不是全部', subtitle: '你的身份不止一份工作', content: '你是一个有爱好的人、一个朋友、一个家庭成员。工作只是你多重身份中的一小部分。', category: '职场压力'),
        const CognitiveCard(id: 211, title: '休息是生产力', subtitle: '不充电的电池终将耗尽', content: '午休不是浪费时间，是维持下午效率的必要投资。紧绷的弦容易断，适度的放松让你走得更远。', category: '职场压力'),
        const CognitiveCard(id: 212, title: '每天留30分钟给自己', subtitle: '30分钟是你能给自己最好的礼物', content: '在忙碌的一天中，留出30分钟只属于你：读书、听音乐、发呆。这段时光是你的充电宝。', category: '职场压力'),
      ],
    },
    {
      'icon': '💕',
      'title': '亲密关系',
      'cards': [
        const CognitiveCard(id: 301, title: '爱是动词', subtitle: '爱不是感觉，是每天的选择', content: '爱不是一直心动的感觉，而是在对方需要时递上一杯水、在争吵后主动和解的选择。', category: '亲密关系'),
        const CognitiveCard(id: 302, title: '表达比猜测更重要', subtitle: '说出来，对方才听得见', content: '不要期待对方读心。你的需求、你的感受，需要你清晰地说出来。这是对自己的尊重，也是对关系的负责。', category: '亲密关系'),
        const CognitiveCard(id: 303, title: '允许对方不完美', subtitle: '完美是关系的敌人', content: '你爱的人也会犯错、会脾气不好、会说错话。接纳这些不完美，因为你自己也一样。', category: '亲密关系'),
        const CognitiveCard(id: 304, title: '冲突不等于不爱', subtitle: '吵架是另一种沟通方式', content: '争吵不意味着关系破裂，它是彼此在意的证明。冲突过后的和解，往往让关系更紧密。', category: '亲密关系'),
        const CognitiveCard(id: 305, title: '倾听比建议更温暖', subtitle: '有时候只需要被听见', content: '当对方向你倾诉，大多数时候需要的是理解和共情，而不是解决方案。先拥抱，再说话。', category: '亲密关系'),
        const CognitiveCard(id: 306, title: '你的需求是正当的', subtitle: '不压抑自己的需要', content: '在关系中，你的需求和对方的同样重要。不需要为了维持关系而委屈自己。', category: '亲密关系'),
        const CognitiveCard(id: 307, title: '不期待对方读心', subtitle: '你想要的，请说出来', content: '没有人能猜到你的心思。直接说出你想要一个拥抱、一句安慰或是一次约会。', category: '亲密关系'),
        const CognitiveCard(id: 308, title: '空间感是关系的一部分', subtitle: '稳定的关系需要呼吸', content: '再亲密的关系也需要各自的空间。允许对方有自己的时间、自己的朋友、自己的爱好。', category: '亲密关系'),
        const CognitiveCard(id: 309, title: '感恩小事情', subtitle: '大事由小事累积', content: '一个早安问候、一杯端到床边的水、一句"你辛苦了"——这些小事是关系最坚固的基石。', category: '亲密关系'),
        const CognitiveCard(id: 310, title: '关系需要维护', subtitle: '经营和耕耘需要每天的努力', content: '关系像一株植物，不能只在枯萎时才浇水。每天的关注和投入，才能让它茁壮成长。', category: '亲密关系'),
        const CognitiveCard(id: 311, title: '放下控制欲', subtitle: '你无法控制对方，只能管理自己', content: '想改变对方是许多关系冲突的根源。你唯一能控制的是自己的反应和态度。', category: '亲密关系'),
        const CognitiveCard(id: 312, title: '先爱自己才能爱人', subtitle: '爱满则溢', content: '如果你自己的杯子是空的，你就无法给别人倒水。先学会爱自己，你的爱才会有力量。', category: '亲密关系'),
      ],
    },
    {
      'icon': '🌱',
      'title': '自我成长',
      'cards': [
        const CognitiveCard(id: 401, title: '成长是螺旋上升的', subtitle: '进步不是线性的，不要着急', content: '每一次"倒退"其实都是在积蓄力量。成长不是一条直线，而是螺旋上升——看似在绕圈，实际上已经更高了。', category: '自我成长'),
        const CognitiveCard(id: 402, title: '允许自己停下来', subtitle: '休息不是放弃', content: '有时候最好的前进方式，是停下来喘口气。给自己暂停的许可，恢复后再出发。', category: '自我成长'),
        const CognitiveCard(id: 403, title: '比较是偷走快乐的小偷', subtitle: '你的对手只有昨天的自己', content: '和他人比较只会带来焦虑。你唯一需要超越的人，就是昨天的自己。', category: '自我成长'),
        const CognitiveCard(id: 404, title: '每一个当下都是起点', subtitle: '任何时候开始都不晚', content: '不需要等待完美的时机。就从这一刻开始——读一页书、写一句话、走一千步。微小的开始就是全部。', category: '自我成长'),
        const CognitiveCard(id: 405, title: '失败是数据不是定义', subtitle: '每一次失败都在告诉你下一步怎么走', content: '失败不是一个标签，而是一条信息。它告诉你这条路不通，请换一条。收集数据，调整策略，继续前进。', category: '自我成长'),
        const CognitiveCard(id: 406, title: '舒适圈的边缘是成长区', subtitle: '一点点跨出舒适圈', content: '不需要立刻跑出舒适圈。每天往外迈出一小步：和新朋友说一句话、尝试一道新菜。微小的挑战是最好的练习。', category: '自我成长'),
        const CognitiveCard(id: 407, title: '习惯的力量', subtitle: '你每天都在塑造自己', content: '成功不是一时爆发，而是每天微小习惯的复利。今天比昨天好1%，一年后你将强大37倍。', category: '自我成长'),
        const CognitiveCard(id: 408, title: '相信过程', subtitle: '有些种子需要时间才能发芽', content: '你现在看不到的进步，正在地下悄悄生根。相信你付出的每一分钟，它们都在积蓄力量。', category: '自我成长'),
        const CognitiveCard(id: 409, title: '你的节奏独一无二', subtitle: '不同花朵在不同的季节盛开', content: '有人30岁功成名就，有人50岁才找到热爱。你的节奏不需要和别人同步，在你的时区里，一切都准时。', category: '自我成长'),
        const CognitiveCard(id: 410, title: '1%的进步也是进步', subtitle: '不要轻视微小的改变', content: '每天进步1%看起来微不足道，但一个月后就是30%的跃升。微小的积累会带来巨大的变化。', category: '自我成长'),
        const CognitiveCard(id: 411, title: '痛苦是老师的伪装', subtitle: '每一次痛苦都在教你重要的一课', content: '当下的痛苦让你想逃，但它往往带给你最大的成长。回头看时，你会感激那些最难的日子。', category: '自我成长'),
        const CognitiveCard(id: 412, title: '你比你想象的强大', subtitle: '低估自己是所有人的通病', content: '人类习惯于低估自己的韧性。记住你曾经穿越过的风暴——那些经历已经证明，你比想象中强大得多。', category: '自我成长'),
      ],
    },
  ];
}
