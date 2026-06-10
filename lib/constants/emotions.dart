/// 情绪类型枚举
enum EmotionType {
  happy('开心', '😊'),
  calm('平静', '😌'),
  excited('兴奋', '🤩'),
  grateful('感恩', '🥰'),
  anxious('焦虑', '😰'),
  sad('难过', '😢'),
  angry('生气', '😤'),
  tired('疲惫', '😴'),
  neutral('一般', '😐');

  final String label;
  final String emoji;
  const EmotionType(this.label, this.emoji);

  static EmotionType fromLabel(String label) {
    return EmotionType.values.firstWhere(
      (e) => e.label == label,
      orElse: () => EmotionType.neutral,
    );
  }
}

/// 标签枚举
enum TagType {
  work('工作', '💼'),
  family('家庭', '👨‍👩‍👧‍👦'),
  social('社交', '👥'),
  health('健康', '💪'),
  finance('财务', '💰'),
  love('情感', '💕'),
  growth('成长', '🌱'),
  other('其他', '📌');

  final String label;
  final String icon;
  const TagType(this.label, this.icon);
}

/// 情绪急救包建议
class EmergencyAdvice {
  final String emotion;
  final List<String> advices;

  const EmergencyAdvice({required this.emotion, required this.advices});
}

const List<EmergencyAdvice> emergencyAdvices = [
  EmergencyAdvice(
    emotion: '焦虑',
    advices: [
      '尝试 4-7-8 呼吸法：吸气4秒，屏息7秒，呼气8秒，重复3次可以让心率逐渐平缓。',
      '写下你此刻最担心的三件事，然后问自己："一周后这件事还重要吗？"',
      '双手交叉放在肩膀上，轻轻交替拍打（蝴蝶拍），给自己一个温柔的拥抱。闭上眼睛，告诉自己"此刻我是安全的"。',
    ],
  ),
  EmergencyAdvice(
    emotion: '难过',
    advices: [
      '允许自己难过。情绪就像天气，乌云来了也一定会走。给自己泡一杯热茶，安静地坐一会儿。',
      '听一首你最喜欢的歌，或者看一段让你微笑的回忆。悲伤需要被看见，不需要被赶走。',
      '试着写下"虽然我很难过，但我依然值得被爱"。重复读三遍，感受文字的力量。',
    ],
  ),
  EmergencyAdvice(
    emotion: '生气',
    advices: [
      '把双手放在冷水下冲30秒，或者握住一块冰块。生理降温可以帮助情绪降温。',
      '在手机上打一段"气话"，但不要发送。允许自己把所有愤怒写出来，然后删除它。',
      '问自己三个问题："是什么触发了我的愤怒？""我的需求是什么？""我能做什么来满足这个需求？"',
    ],
  ),
  EmergencyAdvice(
    emotion: '疲惫',
    advices: [
      '闭上眼睛，做一次"身体扫描"：从头顶到脚尖，依次感受每个部位的紧张程度，有意识地放松它们。',
      '给自己15分钟"什么都不做"的时间。不刷手机、不工作、不思考——只是安静地存在。',
      '去窗边或阳台站一会儿，看看远处的天空或树木。让视线放远，呼吸放慢。',
    ],
  ),
  EmergencyAdvice(
    emotion: '开心',
    advices: [
      '记录下此刻让你开心的人和事。把这份快乐存进"感恩日记"，以后翻看会成为温暖的能量来源。',
      '分享这份快乐！给好朋友发一条消息，或者对你身边的人笑一笑，快乐会加倍。',
      '想一件你可以为别人做的小事——一杯咖啡、一句赞美。给予也能带来持久的幸福感。',
    ],
  ),
  EmergencyAdvice(
    emotion: '平静',
    advices: [
      '珍惜这份宁静。花5分钟冥想，或者只是静静地感受自己的呼吸。平静是最珍贵的状态。',
      '用这份平静做一件一直想做但没静下心来做的事——读几页书、画一幅画、写一封信。',
      '回顾一下最近的生活：是什么让你保持了平静？记录下来，这是你的"情绪调节密码"。',
    ],
  ),
  EmergencyAdvice(
    emotion: '兴奋',
    advices: [
      '趁着这股兴奋劲儿，给自己设定一个小目标并迈出第一步。高涨的情绪是最佳的行动燃料！',
      '用手机记录下这个兴奋的瞬间——拍张照、写句话、录一段语音。这是你人生能量的证据。',
      '做几次深呼吸，把兴奋的能量引导到当下你最想推进的事情上，让这股力量帮你完成它。',
    ],
  ),
  EmergencyAdvice(
    emotion: '感恩',
    advices: [
      '这种温暖的感觉值得被记录。写下此刻你最想感谢的三个人或三件事，越具体越好。',
      '给一位你想感谢的人发一条消息，不需要长篇大论，一句"谢谢你"就够了。感恩说出声才有力量。',
      '回顾一下：是什么让你产生了感恩的心情？把这种觉察带入日常生活，你会越来越容易感受到美好。',
    ],
  ),
];

/// 情绪到颜色 Hex 的映射（与 MirrorColors 保持一致）
const Map<String, String> emotionColorMap = {
  '开心': '#F5D5CB',
  '平静': '#C5D5CB',
  '兴奋': '#E8C9B0',
  '感恩': '#E8D5B0',
  '焦虑': '#D4C5E2',
  '难过': '#B8C5D0',
  '生气': '#D4A5A5',
  '疲惫': '#C5C5C5',
  '一般': '#D5CFC0',
};

/// 获取指定情绪的急救建议
List<String> getEmergencyAdvices(String emotion) {
  for (final advice in emergencyAdvices) {
    if (advice.emotion == emotion) {
      return advice.advices;
    }
  }
  return [
    '做几次深呼吸，感受当下的自己。',
    '去窗边看看外面的景色，让视线放远。',
    '给自己倒杯水，慢慢喝完，感受水的温度。',
  ];
}
