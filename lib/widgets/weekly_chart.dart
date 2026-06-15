import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/emotions.dart';
import '../models/emotion_record.dart';

class WeeklyChart extends StatelessWidget {
  final List<EmotionRecord> records;

  const WeeklyChart({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(child: Text('暂无数据', style: TextStyle(color: MirrorColors.textSecondary)));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 按情绪聚合
    final emotionCount = <String, int>{};
    for (final r in records) {
      emotionCount[r.emotion] = (emotionCount[r.emotion] ?? 0) + 1;
    }

    final entries = emotionCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = entries.fold<int>(0, (sum, e) => sum + e.value);
    final maxCount = entries.isNotEmpty ? entries.first.value.toDouble() : 1.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // 横向柱状图
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: entries.map((entry) {
              final heightFactor = entry.value / maxCount;
              final color = MirrorColors.emotionColor(entry.key);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${entry.value}',
                        style: TextStyle(fontSize: 11, color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        height: 80 * heightFactor,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [color, color.withValues(alpha: 0.3)],
                          ),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        EmotionType.fromLabel(entry.key).emoji,
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        entry.key,
                        style: const TextStyle(fontSize: 10, color: MirrorColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '本周共记录 $total 次',
          style: TextStyle(fontSize: 12, color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary),
        ),
      ],
    );
  }
}
