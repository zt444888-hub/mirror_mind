# Check current counts
import os

with open('lib/constants/cards.dart') as f:
    cards = f.read()
print(f"当前卡片数: {cards.count('CognitiveCard(')}")

with open('lib/screens/emotion_vocabulary_screen.dart') as f:
    vocab = f.read()
print(f"当前词汇数: {vocab.count('_EmotionWord(')}")

# Add cards
old = "        const CognitiveCard(id: 412, title: '你比你想象的强大', subtitle: '低估自己是所有人的通病', content: '人类习惯于低估自己的韧性。记住你曾经穿越过的风暴——那些经历已经证明，你比想象中强大得多。', category: '自我成长'),"
new = old + """
        const CognitiveCard(id: 500, title: '接受不确定性', subtitle: '生活本身就是不确定的', content: '不确定性是生活的常态。学会在未知中找到安全感，才是真正的成长。你不需要所有答案。', category: '焦虑应对'),
        const CognitiveCard(id: 501, title: '允许不完美', subtitle: '完美是进步的敌人', content: '允许自己做得足够好而不是完美。完成比完美更重要。', category: '焦虑应对'),
        const CognitiveCard(id: 502, title: '放下控制欲', subtitle: '你能控制的只有自己', content: '试图控制一切只会带来焦虑。对无法控制的事情学会放手。', category: '焦虑应对'),
        const CognitiveCard(id: 503, title: '停止自我批评', subtitle: '你内心不需要一个严厉的法官', content: '用对待朋友的温柔语气对待自己。自我批评不会让人进步，自我关怀才会。', category: '自我接纳'),
        const CognitiveCard(id: 504, title: '建立边界不是自私', subtitle: '健康的边界保护你的人际关系', content: '说不会让你变成坏人。清晰边界的关系才能长久健康。', category: '边界感'),
        const CognitiveCard(id: 505, title: '从错误中学习', subtitle: '错误是最好的老师', content: '每次错误都在告诉你什么行不通。这是反馈，不是失败。', category: '完美主义'),
        const CognitiveCard(id: 506, title: '接纳所有情绪', subtitle: '没有坏情绪，只有被压抑的情绪', content: '愤怒告诉你边界被侵犯，焦虑提醒你准备不足。每种情绪都有它的价值。', category: '情绪接纳'),
        const CognitiveCard(id: 507, title: '深度倾听', subtitle: '真正的倾听是最好的礼物', content: '放下评判，全然地倾听。给对方充分的空间表达。', category: '人际关系'),
        const CognitiveCard(id: 508, title: '自我关怀三步骤', subtitle: '像照顾好友一样照顾自己', content: '觉察-连接-关怀。给自己需要的温暖和支持。', category: '自我关怀'),
        const CognitiveCard(id: 509, title: '正念呼吸练习', subtitle: '一次呼吸，一次停顿', content: '注意一次呼吸的进出。当注意力跑掉时，温柔地把它带回来。', category: '正念觉察'),
        const CognitiveCard(id: 510, title: '微习惯的力量', subtitle: '小到不可能失败的习惯', content: '想读书每天读一页。微习惯小到你没有理由拒绝。', category: '自我成长'),
        const CognitiveCard(id: 511, title: '感恩日记', subtitle: '每天写下三件好事', content: '每天睡前写下今天发生的三件好事。坚持一周你会发现生活比你想象的美好。', category: '自我成长'),
"""
cards = cards.replace(old, new)
with open('lib/constants/cards.dart', 'w') as f:
    f.write(cards)
print("✅ 已添加 12 张新卡片")

# Add vocabulary words
with open('lib/screens/emotion_vocabulary_screen.dart') as f:
    vocab = f.read()

new_words = """
      const _EmotionWord('恬淡', '不追求名利的淡然', '在山间读书品茶，日子恬淡而充实。', '呼吸平缓，心如止水'),
      const _EmotionWord('从容', '面对变故镇定自若', '面试时虽然紧张，但她十分从容。', '步伐稳健，声音平稳'),
      const _EmotionWord('平和', '内心安宁与世无争', '心态越来越平和，不再为小事计较。', '眉眼舒展，面带微笑'),
      const _EmotionWord('宁静', '没有噪音的安谧', '清晨的湖边一片宁静。', '耳朵放松，思绪安静'),
      const _EmotionWord('泰然', '面对困难沉稳淡定', '无论发生什么他总是一副泰然自若的样子。', '肩膀放松，呼吸均匀'),
"""

# Add to '平静' category
old_section = "'平静': ["
new_section = "'平静': [" + new_words
vocab = vocab.replace(old_section, new_section)
with open('lib/screens/emotion_vocabulary_screen.dart', 'w') as f:
    f.write(vocab)
print("✅ 已添加 5 个平静类词汇")

# Add mood card templates
with open('lib/screens/mood_card_screen.dart') as f:
    mc = f.read()

mc = mc.replace(
    "['简约', '文艺', '温暖', '渐变', '极简', '手写', '胶片']",
    "['简约', '文艺', '温暖', '渐变', '极简', '手写', '胶片', '糖果', '森林', '暗夜']"
)

mc = mc.replace(
    "  [Color(0xFF000000), Color(0xFF000000), Color(0xFFFFFFFF), Color(0xFFE17055)], // 胶片",
    """  [Color(0xFF000000), Color(0xFF000000), Color(0xFFFFFFFF), Color(0xFFE17055)], // 胶片
  [Color(0xFFFFF0F5), Color(0xFFFFD6E0), Color(0xFF6B4E71), Color(0x00000000)], // 糖果
  [Color(0xFFE8F5E9), Color(0xFFC8E6C9), Color(0xFF1B5E20), Color(0xFF81C784)], // 森林
  [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFFE8E8E8), Color(0xFF0F3460)], // 暗夜"""
)

with open('lib/screens/mood_card_screen.dart', 'w') as f:
    f.write(mc)
print("✅ 已添加 3 个卡片模板")

# Final counts
with open('lib/constants/cards.dart') as f:
    print(f"新版卡片数: {f.read().count('CognitiveCard(')}")
with open('lib/screens/emotion_vocabulary_screen.dart') as f:
    print(f"新版词汇数: {f.read().count('_EmotionWord(')}")
