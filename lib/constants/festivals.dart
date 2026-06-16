/// 节日数据
class Festival {
  final int month;
  final int day;
  final String name;
  final String type; // 'chinese' or 'international'
  final String? emoji;

  const Festival({
    required this.month,
    required this.day,
    required this.name,
    required this.type,
    this.emoji,
  });

  String get key => '${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  /// 获取某个月的节日列表
  static List<Festival> getByMonth(int month) {
    return all.where((f) => f.month == month).toList();
  }

  /// 获取某天的节日
  static List<Festival> getByDate(int month, int day) {
    return all.where((f) => f.month == month && f.day == day).toList();
  }

  static const List<Festival> all = [
    // ===== 一月 =====
    Festival(month: 1, day: 1, name: '元旦', type: 'chinese', emoji: '🎉'),
    Festival(month: 1, day: 1, name: 'New Year', type: 'international', emoji: '🎊'),
    Festival(month: 1, day: 6, name: '小寒', type: 'chinese', emoji: '❄️'),

    // ===== 二月 =====
    Festival(month: 2, day: 2, name: '世界湿地日', type: 'international', emoji: '🌿'),
    Festival(month: 2, day: 3, name: '立春', type: 'chinese', emoji: '🌱'),
    Festival(month: 2, day: 14, name: '情人节', type: 'international', emoji: '💕'),
    Festival(month: 2, day: 17, name: '除夕', type: 'chinese', emoji: '🧨'),
    Festival(month: 2, day: 18, name: '春节', type: 'chinese', emoji: '🧧'),
    Festival(month: 2, day: 19, name: '大年初二', type: 'chinese', emoji: '🧧'),

    // ===== 三月 =====
    Festival(month: 3, day: 3, name: '元宵节', type: 'chinese', emoji: '🏮'),
    Festival(month: 3, day: 5, name: '惊蛰', type: 'chinese', emoji: '⛈️'),
    Festival(month: 3, day: 8, name: '妇女节', type: 'international', emoji: '🌷'),
    Festival(month: 3, day: 12, name: '植树节', type: 'chinese', emoji: '🌳'),
    Festival(month: 3, day: 20, name: '春分', type: 'chinese', emoji: '🌸'),
    Festival(month: 3, day: 23, name: '世界气象日', type: 'international', emoji: '🌤️'),

    // ===== 四月 =====
    Festival(month: 4, day: 1, name: '愚人节', type: 'international', emoji: '🃏'),
    Festival(month: 4, day: 4, name: '清明节', type: 'chinese', emoji: '🌧️'),
    Festival(month: 4, day: 5, name: '清明', type: 'chinese', emoji: '🌧️'),
    Festival(month: 4, day: 22, name: '地球日', type: 'international', emoji: '🌏'),

    // ===== 五月 =====
    Festival(month: 5, day: 1, name: '劳动节', type: 'chinese', emoji: '⚒️'),
    Festival(month: 5, day: 4, name: '青年节', type: 'chinese', emoji: '💪'),
    Festival(month: 5, day: 5, name: '立夏', type: 'chinese', emoji: '☀️'),
    Festival(month: 5, day: 12, name: '护士节', type: 'international', emoji: '👩‍⚕️'),
    Festival(month: 5, day: 31, name: '端午节', type: 'chinese', emoji: '🛶'),

    // ===== 六月 =====
    Festival(month: 6, day: 1, name: '儿童节', type: 'international', emoji: '🎈'),
    Festival(month: 6, day: 5, name: '芒种', type: 'chinese', emoji: '🌾'),
    Festival(month: 6, day: 21, name: '夏至', type: 'chinese', emoji: '☀️'),
    Festival(month: 6, day: 21, name: '父亲节', type: 'international', emoji: '👨'),

    // ===== 七月 =====
    Festival(month: 7, day: 1, name: '建党节', type: 'chinese', emoji: '🚩'),
    Festival(month: 7, day: 6, name: '小暑', type: 'chinese', emoji: '🥵'),
    Festival(month: 7, day: 22, name: '大暑', type: 'chinese', emoji: '🔥'),

    // ===== 八月 =====
    Festival(month: 8, day: 1, name: '建军节', type: 'chinese', emoji: '🎖️'),
    Festival(month: 8, day: 7, name: '立秋', type: 'chinese', emoji: '🍂'),
    Festival(month: 8, day: 10, name: '七夕节', type: 'chinese', emoji: '💑'),
    Festival(month: 8, day: 22, name: '处暑', type: 'chinese', emoji: '🌬️'),

    // ===== 九月 =====
    Festival(month: 9, day: 7, name: '白露', type: 'chinese', emoji: '💧'),
    Festival(month: 9, day: 10, name: '教师节', type: 'chinese', emoji: '📚'),
    Festival(month: 9, day: 22, name: '秋分', type: 'chinese', emoji: '🍁'),
    Festival(month: 9, day: 27, name: '中秋节', type: 'chinese', emoji: '🥮'),

    // ===== 十月 =====
    Festival(month: 10, day: 1, name: '国庆节', type: 'chinese', emoji: '🇨🇳'),
    Festival(month: 10, day: 8, name: '寒露', type: 'chinese', emoji: '🌧️'),
    Festival(month: 10, day: 23, name: '霜降', type: 'chinese', emoji: '❄️'),
    Festival(month: 10, day: 25, name: '重阳节', type: 'chinese', emoji: '🧓'),
    Festival(month: 10, day: 31, name: '万圣节', type: 'international', emoji: '🎃'),

    // ===== 十一月 =====
    Festival(month: 11, day: 7, name: '立冬', type: 'chinese', emoji: '🥟'),
    Festival(month: 11, day: 22, name: '小雪', type: 'chinese', emoji: '🌨️'),
    Festival(month: 11, day: 26, name: '感恩节', type: 'international', emoji: '🦃'),

    // ===== 十二月 =====
    Festival(month: 12, day: 7, name: '大雪', type: 'chinese', emoji: '❄️'),
    Festival(month: 12, day: 21, name: '冬至', type: 'chinese', emoji: '🥟'),
    Festival(month: 12, day: 24, name: '平安夜', type: 'international', emoji: '🎄'),
    Festival(month: 12, day: 25, name: '圣诞节', type: 'international', emoji: '🎄'),
    Festival(month: 12, day: 31, name: '跨年夜', type: 'international', emoji: '🎆'),
  ];
}
