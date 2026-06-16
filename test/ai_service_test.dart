import 'package:flutter_test/flutter_test.dart';
import 'package:mirror_mind/services/ai_service.dart';

void main() {
  group("AiService - 离线情绪分析", () {
    late AiService service;

    setUp(() {
      service = AiService();
    });

    test("开心关键词返回开心", () async {
      final result = await service.analyzeEmotion("今天真的好开心！");
      expect(result!.emotion, "开心");
      expect(result.confidence, greaterThan(0.0));
      expect(result.response, isNotEmpty);
    });

    test("难过关键词返回难过", () async {
      final result = await service.analyzeEmotion("最近失恋了，好伤心");
      expect(result!.emotion, "难过");
    });

    test("焦虑关键词返回焦虑", () async {
      final result = await service.analyzeEmotion("马上要考试了，非常紧张焦虑");
      expect(result!.emotion, "焦虑");
    });

    test("疲惫关键词返回疲惫", () async {
      final result = await service.analyzeEmotion("好累啊，困得要死");
      expect(result!.emotion, "疲惫");
    });

    test("平静关键词返回平静", () async {
      final result = await service.analyzeEmotion("今天心情很平静放松");
      expect(result!.emotion, "平静");
    });

    test("一般文本返回结果", () async {
      final result = await service.analyzeEmotion("今天天气不错");
      expect(result, isNotNull);
      expect(result!.emotion, isNotEmpty);
      expect(result.confidence, greaterThan(0.0));
    });

    test("置信度在 0-1 之间", () async {
      final result1 = await service.analyzeEmotion("今天很开心");
      final result2 = await service.analyzeEmotion("今天天气不错");
      expect(result1!.confidence, greaterThanOrEqualTo(0.0));
      expect(result1.confidence, lessThanOrEqualTo(1.0));
      expect(result2!.confidence, greaterThanOrEqualTo(0.0));
      expect(result2.confidence, lessThanOrEqualTo(1.0));
    });

    test("回应内容不为空且有意义", () async {
      final result = await service.analyzeEmotion("心情不太好");
      expect(result!.response, isNotEmpty);
      expect(result.response.length, greaterThan(5));
    });

    test("不配 Key 也能离线分析", () async {
      final service = AiService();
      expect(service.isConfigured, false);
      final result = await service.analyzeEmotion("今天很开心");
      expect(result, isNotNull);
      expect(result!.emotion, isNotEmpty);
    });

    test("长文本分析正常", () async {
      final text = "今天早上起来感觉还不错，" * 10;
      final result = await service.analyzeEmotion(text);
      expect(result, isNotNull);
      expect(result!.emotion, isNotEmpty);
      expect(result.response, isNotEmpty);
    });
  });
}
