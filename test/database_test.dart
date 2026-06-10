import 'package:flutter_test/flutter_test.dart';
import '../lib/models/emotion_record.dart';

void main() {
  group('EmotionRecord', () {
    test('fromMap should handle valid data', () {
      final map = <String, dynamic>{
        'id': 1,
        'date': '2026-06-10',
        'emotion': '开心',
        'input_text': '今天很开心',
        'ai_response': '很开心呢，继续保持！',
        'confidence': 0.95,
        'score': 8,
        'tag': '生活',
        'created_at': '2026-06-10T10:00:00',
      };

      final record = EmotionRecord.fromMap(map);
      expect(record.id, 1);
      expect(record.emotion, '开心');
      expect(record.inputText, '今天很开心');
      expect(record.score, 8);
      expect(record.tag, '生活');
      expect(record.confidence, 0.95);
    });

    test('fromMap should handle missing optional fields', () {
      final map = <String, dynamic>{
        'date': '2026-06-10',
        'emotion': '平静',
        'score': 5,
      };

      final record = EmotionRecord.fromMap(map);
      expect(record.id, isNull);
      expect(record.emotion, '平静');
      expect(record.inputText, isNull);
      expect(record.confidence, 0.0);
      expect(record.score, 5);
    });

    test('toMap should include all required fields', () {
      final record = EmotionRecord(
        date: DateTime(2026, 6, 10),
        emotion: '平静',
        inputText: '今天很平静',
        aiResponse: '平静是很好的状态',
        score: 7,
        tag: '健康',
        confidence: 0.85,
      );

      final map = record.toMap();
      expect(map['emotion'], '平静');
      expect(map['score'], 7);
      expect(map['tag'], '健康');
      expect(map['confidence'], 0.85);
      expect(map['input_text'], '今天很平静');
      expect(map['ai_response'], '平静是很好的状态');
    });

    test('toMap / fromMap round-trip should preserve data', () {
      final original = EmotionRecord(
        date: DateTime(2026, 6, 10),
        emotion: '焦虑',
        inputText: '有点紧张',
        score: 3,
        tag: '工作',
        confidence: 0.72,
      );

      final map = original.toMap();
      final restored = EmotionRecord.fromMap(map);
      expect(restored.emotion, original.emotion);
      expect(restored.score, original.score);
      expect(restored.tag, original.tag);
      expect(restored.inputText, original.inputText);
      expect(restored.confidence, original.confidence);
    });
  });
}
