/// 情绪类型枚举
enum EmotionType {
  happy('开心', '😊', 8, 'positive'),
  calm('平静', '😌', 7, 'positive'),
  excited('兴奋', '🤩', 9, 'positive'),
  grateful('感恩', '🥰', 8, 'positive'),
  content('满足', '😊', 7, 'positive'),
  hopeful('期待', '🤗', 7, 'positive'),
  neutral('一般', '😐', 5, 'neutral'),
  confused('迷茫', '🤔', 4, 'neutral'),
  bored('无聊', '😑', 3, 'neutral'),
  pingdan('平淡', '😐', 4, 'neutral'),
  anxious('焦虑', '😰', 3, 'negative'),
  sad('难过', '😢', 2, 'negative'),
  angry('生气', '😤', 2, 'negative'),
  tired('疲惫', '😴', 3, 'negative'),
  lonely('孤独', '😔', 2, 'negative'),
  stressed('压力', '😣', 2, 'negative'),
  ;
  final String label; final String emoji; final int score; final String category;
  const EmotionType(this.label, this.emoji, this.score, this.category);
  bool get isPositive => category == 'positive';
  bool get isNegative => category == 'negative';
  bool get isNeutral => category == 'neutral';
  static EmotionType fromLabel(String label) => values.firstWhere((e) => e.label == label, orElse: () => EmotionType.neutral);
  static List<EmotionType> get positive => values.where((e) => e.isPositive).toList();
  static List<EmotionType> get neutral_ => values.where((e) => e.isNeutral).toList();
  static List<EmotionType> get negative => values.where((e) => e.isNegative).toList();
}

enum TagType {
  work('工作', '💼'), family('家庭', '👨‍👩‍👧‍👦'), social('社交', '👥'),
  health('健康', '💪'), finance('财务', '💰'), love('情感', '💕'),
  growth('成长', '🌱'), other('其他', '📌');
  final String label; final String icon;
  const TagType(this.label, this.icon);
}

class EmergencyAdvice {
  final String emotion; final List<String> advices;
  const EmergencyAdvice({required this.emotion, required this.advices});
}

const List<EmergencyAdvice> emergencyAdvices = [
  EmergencyAdvice(emotion: '焦虑', advices: ['尝试 4-7-8 呼吸法...', '写下你此刻最担心的三件事...', '蝴蝶拍安抚法...']),
  EmergencyAdvice(emotion: '难过', advices: ['允许自己难过...', '听一首你最喜欢的歌...', '写下肯定语句...']),
  EmergencyAdvice(emotion: '生气', advices: ['冷水降温法...', '写气话但不发送...', '问自己三个问题...']),
  EmergencyAdvice(emotion: '疲惫', advices: ['身体扫描放松法...', '15分钟放空时间...', '看看远处的天空...']),
  EmergencyAdvice(emotion: '开心', advices: ['记录开心时刻...', '分享快乐...', '为别人做件小事...']),
  EmergencyAdvice(emotion: '平静', advices: ['珍惜这份宁静...', '做一件一直想做的事...', '回顾是什么让你平静...']),
  EmergencyAdvice(emotion: '兴奋', advices: ['设定小目标并行动...', '记录兴奋瞬间...', '把能量引导到正事上...']),
  EmergencyAdvice(emotion: '感恩', advices: ['写下想感谢的人和事...', '发一条感谢消息...', '觉察感恩的来源...']),
];

const Map<String, String> emotionColorMap = {
  '开心': '#F5D5CB', '平静': '#C5D5CB', '兴奋': '#E8C9B0', '感恩': '#E8D5B0',
  '焦虑': '#D4C5E2', '难过': '#B8C5D0', '生气': '#D4A5A5', '疲惫': '#C5C5C5', '一般': '#D5CFC0',
};

List<String> getEmergencyAdvices(String emotion) {
  for (final a in emergencyAdvices) { if (a.emotion == emotion) return a.advices; }
  return ['做几次深呼吸，感受当下的自己。', '去窗边看看外面的景色。', '给自己倒杯水，慢慢喝完。'];
}
