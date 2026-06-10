/// 情绪记录数据模型
class EmotionRecord {
  final int? id;
  final DateTime date;
  final String emotion;       // 情绪类型：开心/焦虑/难过...
  final String? inputText;    // 用户输入原文
  final String? aiResponse;   // AI 共情回应
  final double confidence;    // AI 置信度 0.0-1.0
  final int score;            // 自评分数 1-10
  final String? tag;          // 标签：工作/家庭/社交...
  final DateTime createdAt;
  final String? gratitudeItems; // 感恩三件事（JSON 字符串，用于感恩模块）

  EmotionRecord({
    this.id,
    required this.date,
    required this.emotion,
    this.inputText,
    this.aiResponse,
    this.confidence = 0.0,
    this.score = 5,
    this.tag,
    DateTime? createdAt,
    this.gratitudeItems,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'date': date.toIso8601String().split('T')[0],
      'emotion': emotion,
      'input_text': inputText,
      'ai_response': aiResponse,
      'confidence': confidence,
      'score': score,
      'tag': tag,
      'created_at': createdAt.toIso8601String(),
      'gratitude_items': gratitudeItems,
    };
  }

  factory EmotionRecord.fromMap(Map<String, dynamic> map) {
    return EmotionRecord(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      emotion: map['emotion'] as String,
      inputText: map['input_text'] as String?,
      aiResponse: map['ai_response'] as String?,
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      score: (map['score'] as num?)?.toInt() ?? 5,
      tag: map['tag'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      gratitudeItems: map['gratitude_items'] as String?,
    );
  }

  String? get note => inputText;

  EmotionRecord copyWith({
    int? id,
    DateTime? date,
    String? emotion,
    String? inputText,
    String? aiResponse,
    double? confidence,
    int? score,
    String? tag,
    DateTime? createdAt,
    String? gratitudeItems,
  }) {
    return EmotionRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      emotion: emotion ?? this.emotion,
      inputText: inputText ?? this.inputText,
      aiResponse: aiResponse ?? this.aiResponse,
      confidence: confidence ?? this.confidence,
      score: score ?? this.score,
      tag: tag ?? this.tag,
      createdAt: createdAt ?? this.createdAt,
      gratitudeItems: gratitudeItems ?? this.gratitudeItems,
    );
  }
}
