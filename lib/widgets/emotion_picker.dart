import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/emotions.dart';

class EmotionPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const EmotionPicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    const emotions = EmotionType.values;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: emotions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final emotion = emotions[index];
          final isSelected = emotion.label == selected;
          return GestureDetector(
            onTap: () => onSelected(emotion.label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? MirrorColors.emotionColor(emotion.label).withValues(alpha: 0.3)
                    : Theme.of(context).brightness == Brightness.dark
                        ? MirrorColors.darkSurface
                        : MirrorColors.cardBackground,
                borderRadius: BorderRadius.circular(22),
                border: isSelected
                    ? Border.all(color: MirrorColors.emotionColor(emotion.label), width: 1.5)
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emotion.emoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text(
                    emotion.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? MirrorColors.emotionColor(emotion.label)
                          : Theme.of(context).brightness == Brightness.dark
                              ? MirrorColors.darkTextSecondary
                              : MirrorColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
