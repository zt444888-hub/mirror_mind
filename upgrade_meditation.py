import re

with open('lib/screens/meditation_screen.dart', 'r') as f:
    content = f.read()

# 添加 audio_player 导入
if "import 'package:audioplayers/audioplayers.dart';" not in content:
    content = content.replace(
        "import 'package:flutter/material.dart';",
        "import 'package:flutter/material.dart';\nimport 'package:audioplayers/audioplayers.dart';"
    )

# 在 _modes 列表末尾添加 2 个新模式
old_end = "    ),\n  ];\n\n  // 预设时长选项"
new_modes = """    ),
    const _MeditationMode(
      title: '深度放松',
      description: '全身心的放松之旅',
      icon: Icons.self_improvement,
      color: Color(0xFF6C5CE7),
      defaultDuration: 600,
      phrases: [
        '找一个安静的地方，躺下或坐着都可以',
        '闭上眼睛，做三次深呼吸',
        '把注意力放在脚尖，感受它们的存在',
        '慢慢地，把注意力从脚尖移到脚踝',
        '感受小腿的肌肉，让它完全放松',
        '膝盖放松，大腿放松，髋部下沉',
        '腹部随着呼吸起伏，自然的节奏',
        '胸腔慢慢打开，每一次呼吸都更深',
        '放松你的手指、手掌、手腕',
        '感受手臂的重量，完全交给地面',
        '肩膀下沉，脖子放松，头部放空',
        '脸部肌肉松开，眉心舒展',
        '从头到脚扫描全身，哪里紧张就放松哪里',
        '想象一股暖流从头顶流向脚尖',
        '你是安全的，此刻只需要存在',
        '慢慢把注意力带回呼吸',
        '轻轻活动手指和脚趾',
        '当准备好时，慢慢睁开眼睛',
      ],
    ),
    const _MeditationMode(
      title: '专注力训练',
      description: '提升注意力和觉察力',
      icon: Icons.psychology_outlined,
      color: Color(0xFF00B894),
      defaultDuration: 600,
      phrases: [
        '坐下来，背挺直但不僵硬',
        '闭上眼睛，做三次深呼吸',
        '选择呼吸作为专注对象',
        '注意吸气时空气进入鼻腔的感觉',
        '注意呼气时空气离开的温度变化',
        '思绪会飘走，这很正常',
        '当你意识到走神时，温柔地把注意力带回呼吸',
        '不要评判自己，只需要重新开始',
        '这一次，注意呼吸之间的停顿',
        '吸气之后的短暂停顿',
        '呼气之后的自然停顿',
        '感受停顿中的宁静',
        '现在，把注意力扩展到全身',
        '同时感受呼吸和身体的存在感',
        '你不需要控制什么，只需要觉察',
        '你是观察者，不是思考者',
        '最后五次呼吸，带着觉察完成',
        '慢慢睁开眼睛，带着这份专注',
      ],
    ),
  ];

  // 预设时长选项"""

content = content.replace(old_end, new_modes)

# 添加背景声音选择变量
old_vars = "  int _selectedDuration = 300;"
new_vars = """  int _selectedDuration = 300;
  String? _selectedSound;
  final AudioPlayer _audioPlayer = AudioPlayer();"""

content = content.replace(old_vars, new_vars)

# 在 dispose 中添加释放音频
old_dispose = "  void dispose() {"
new_dispose = """  void dispose() {
    _audioPlayer.dispose();"""

content = content.replace(old_dispose, new_dispose)

with open('lib/screens/meditation_screen.dart', 'w') as f:
    f.write(content)

print('✅ 冥想升级完成！')
print('   - 新增2个模式：深度放松 + 专注力训练')
