
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Horoscope {
  final String sign;
  final int overallScore;
  final String overall;
  final String love;
  final String career;
  final String wealth;
  final String health;
  final int luckyNumber;
  final String luckyColor;
  final String luckyTime;
  final String luckyDirection;
  final String mood;

  Horoscope({
    required this.sign, required this.overallScore, required this.overall,
    required this.love, required this.career, required this.wealth,
    required this.health, required this.luckyNumber, required this.luckyColor,
    required this.luckyTime, required this.luckyDirection, required this.mood,
  });
}

class HoroscopeService {
  static const _signs = ['白羊座','金牛座','双子座','巨蟹座','狮子座','处女座','天秤座','天蝎座','射手座','摩羯座','水瓶座','双鱼座'];
  static const _engSigns = ['aries','taurus','gemini','cancer','leo','virgo','libra','scorpio','sagittarius','capricorn','aquarius','pisces'];
  final Map<String, Horoscope> _cache = {};
  String _cacheDate = '';

  List<String> get signs => _signs;

  String _signToEn(String cn) {
    final i = _signs.indexOf(cn);
    return i >= 0 ? _engSigns[i] : 'aries';
  }

  Horoscope _generateFallback(String sign) {
    final seed = DateTime.now().millisecondsSinceEpoch + _signs.indexOf(sign);
    final r = Random(seed);
    final total = _overallDescs.length;

    return Horoscope(
      sign: sign, overallScore: r.nextInt(6) + 3,
      overall: _overallDescs[r.nextInt(total)],
      love: _loveDescs[r.nextInt(total)],
      career: _careerDescs[r.nextInt(total)],
      wealth: _wealthDescs[r.nextInt(total)],
      health: _healthDescs[r.nextInt(total)],
      luckyNumber: r.nextInt(99) + 1,
      luckyColor: _luckyColors[r.nextInt(_luckyColors.length)],
      luckyTime: '${r.nextInt(12)+1}:${r.nextInt(6)*10}',
      luckyDirection: _directions[r.nextInt(_directions.length)],
      mood: _moodDescs[r.nextInt(_moodDescs.length)],
    );
  }

  Future<Horoscope> getHoroscope(String sign) async {
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month}-${today.day}';

    // 命中当日缓存
    if (_cacheDate == dateKey && _cache.containsKey(sign)) return _cache[sign]!;
    if (_cacheDate != dateKey) { _cache.clear(); _cacheDate = dateKey; }

    try {
      final en = _signToEn(sign);
      final resp = await http.get(
        Uri.parse('https://horoscope-app-api.vercel.app/api/today/' + en),
      ).timeout(const Duration(seconds: 8));

      if (resp.statusCode == 200) {
        final j = jsonDecode(resp.body) as Map<String, dynamic>;
        final data = j['data'] as Map<String, dynamic>? ?? j;
        final h = Horoscope(
          sign: sign, overallScore: _parseScore(data['horoscope'] as String? ?? ''),
          overall: data['horoscope'] as String? ?? '',
          love: data['love'] as String? ?? '',
          career: data['career'] as String? ?? '',
          wealth: data['money'] as String? ?? '',
          health: data['health'] as String? ?? '',
          luckyNumber: int.tryParse(data['lucky_number']?.toString() ?? '') ?? 7,
          luckyColor: data['lucky_color'] as String? ?? '',
          luckyTime: data['lucky_time'] as String? ?? '',
          luckyDirection: data['lucky_direction'] as String? ?? '',
          mood: data['mood'] as String? ?? '',
        );
        _cache[sign] = h;
        return h;
      }
    } catch (_) {}

    final fb = _generateFallback(sign);
    _cache[sign] = fb;
    return fb;
  }

  int _parseScore(String text) {
    // 从运势描述中提取评级：极好(9-10) 很好(7-8) 不错(6) 一般(5) 稍差(3-4)
    if (text.contains('极好') || text.contains('完美')) return 8 + (DateTime.now().millisecondsSinceEpoch % 3);
    if (text.contains('很好') || text.contains('非常')) return 7;
    if (text.contains('不错') || text.contains('良好')) return 6;
    return 5 + (DateTime.now().millisecondsSinceEpoch % 3);
  }

  static final _luckyColors = ['红色','黄色','蓝色','绿色','粉色','紫色','白色','金色','橙色','银色','青色','棕色','米色','珊瑚色'];
  static final _directions = ['正东','正西','正南','正北','东南','西南','东北','西北'];
  static final _moodDescs = ['精力充沛', '心情愉快', '平静安稳', '略带紧张', '期待满满', '温和舒适', '灵感涌现', '自信满满'];
  static final _overallDescs = [
    '今天的整体运势不错，适合主动出击迎接新机会。', '各方面平稳发展，适合静心思考和规划。',
    '有惊喜在等着你，保持开放和积极的心态。', '和谐的一天，适合与人合作和交流。',
    '内心充满力量，适合推进重要计划。', '运势上升，会有好事不期而至。',
    '注意细节，今天不宜冲动做决定。', '灵感充沛，适合创意性工作。',
    '人际关系和谐，适合社交和聚会。', '今天需要多一些耐心，好事多磨。',
  ];
  static final _loveDescs = [
    '主动表达心意的好时机，勇敢说出你的感受。', '适合和伴侣深入沟通，分享内心的想法。',
    '单身的朋友今天桃花运不错，多出门走走。', '感情需要一点耐心和包容。',
    '浪漫指数上升，适合安排一次约会。', '平淡也是幸福，享受当下的陪伴。',
    '今天你很有魅力，吸引他人的注意。', '多关注对方的感受，倾听比说话更重要。',
  ];
  static final _careerDescs = [
    '工作效率高，适合处理重要和紧急的任务。', '团队合作顺利，沟通效率很高。',
    '有新的想法和灵感涌现，大胆记录下来。', '适合整理和规划未来的工作方向。',
    '可能会获得关键的信息或机会。', '注意截止日期，提前安排好时间。',
    '和同事沟通需要多些耐心。', '执行力强，适合推进正在进行的项目。',
  ];
  static final _wealthDescs = [
    '收支平衡，没有大的财务压力。', '可能会有小惊喜的收入进账。', '适合做财务规划和预算安排。',
    '花钱的地方有点多，注意节制。', '投资理财需要谨慎，不要盲目跟风。', '节约是今天的关键词，减少不必要的开支。',
    '可能会有意外支出，留些备用金。', '财运平稳，不适合做大的财务决策。', '适合整理账单，了解自己的财务状况。',
  ];
  static final _healthDescs = [
    '身体状况不错，适合运动锻炼。', '注意休息，不要熬夜太晚。', '饮食均衡，多吃水果蔬菜。',
    '眼睛容易疲劳，适当休息远眺。', '适合做拉伸和放松运动。', '喝水充足，保持身体水分。',
    '肩颈容易紧张，多活动一下。', '精神状态不错，保持下去。', '注意天气变化，适当增减衣物。',
  ];
}
