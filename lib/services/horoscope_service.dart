import 'dart:math';



class Horoscope {
  final String sign;
  final int overallScore;
  final String overall;
  final String love;
  final String career;
  final String wealth;
  final int luckyNumber;
  final String luckyColor;
  final String luckyDirection;

  Horoscope({
    required this.sign, required this.overallScore, required this.overall,
    required this.love, required this.career, required this.wealth,
    required this.luckyNumber, required this.luckyColor, required this.luckyDirection,
  });
}

class HoroscopeService {
  static const _signs = ['白羊座','金牛座','双子座','巨蟹座','狮子座','处女座','天秤座','天蝎座','射手座','摩羯座','水瓶座','双鱼座'];

  static final _luckyColors = ['红色','黄色','蓝色','绿色','粉色','紫色','白色','金色','橙色','银色','青色','棕色'];
  static final _directions = ['正东','正西','正南','正北','东南','西南','东北','西北'];
  static final _overallDescs = ['今天状态不错，适合主动出击', '平稳的一天，适合思考和规划', '有惊喜等着你，保持开放心态',
    '小有波折，但结果会很好', '人际关系运走强，多和朋友交流', '适合独处，给自己一些空间',
    '工作上会有新机会', '财运不错，但别冲动消费', '感情方面有温暖的事情发生',
    '今天适合学习新东西', '注意身体健康，别太累了', '保持耐心，好事正在路上'];
  static final _loveDescs = ['主动表达心意的好时机', '适合和伴侣深入沟通', '单身的朋友今天有桃花运',
    '感情需要一点耐心', '浪漫指数上升', '适合一起做些小事',
    '给爱人一个小惊喜', '感情稳定，平淡也是幸福', '可能会收到心动消息',
    '多关注对方的感受', '今天很有魅力哦', '适合约会'];
  static final _careerDescs = ['工作效率高，适合处理重要任务', '团队合作顺利', '有新的想法和灵感',
    '适合整理和规划后续工作', '会议中可能获得关键信息', '注意截止日期',
    '和同事沟通要耐心', '今天适合独立工作', '可能有新的合作机会',
    '执行力强，适合推进项目', '注意细节检查', '保持专注，避免分心'];
  static final _wealthDescs = ['收支平衡', '有小惊喜收入', '适合做财务规划',
    '花钱的地方有点多', '投资理财需要谨慎', '节约是今天的关键词',
    '可能会有意外支出', '适合整理账单', '财运平稳',
    '朋友可能会还钱', '别冲动购物', '今天不适合大的财务决策'];

  Horoscope generateForDate(String sign, DateTime date) {
    final seed = date.year * 10000 + date.month * 100 + date.day + _signs.indexOf(sign);
    final r = Random(seed);

    return Horoscope(
      sign: sign,
      overallScore: r.nextInt(7) + 3,
      overall: _overallDescs[r.nextInt(_overallDescs.length)],
      love: _loveDescs[r.nextInt(_loveDescs.length)],
      career: _careerDescs[r.nextInt(_careerDescs.length)],
      wealth: _wealthDescs[r.nextInt(_wealthDescs.length)],
      luckyNumber: r.nextInt(99) + 1,
      luckyColor: _luckyColors[r.nextInt(_luckyColors.length)],
      luckyDirection: _directions[r.nextInt(_directions.length)],
    );
  }

  List<String> get signs => _signs;
}
