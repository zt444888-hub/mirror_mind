import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/emotions.dart';

class EmotionPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  const EmotionPicker({super.key, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    var isDark = Theme.of(context).brightness == Brightness.dark;
    // 每类取3个情绪，4个一排
    var categories = [
      ('\u{1f60a} 积极', [EmotionType.happy, EmotionType.calm, EmotionType.excited, EmotionType.grateful]),
      ('\u{1f914} 中性', [EmotionType.neutral, EmotionType.confused, EmotionType.bored, EmotionType.pingdan]),
      ('\u{1f630} 消极', [EmotionType.anxious, EmotionType.sad, EmotionType.angry, EmotionType.tired]),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ...categories.map((cat) {
        return Padding(padding: const EdgeInsets.only(bottom: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(cat.$1, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[400] : Colors.grey[500]))),
            SingleChildScrollView(scrollDirection: Axis.horizontal,
        child: Row(children: cat.$2.map((e) {
              var sel = e.label == selected;
              var clr = MirrorColors.emotionColor(e.label);
              return GestureDetector(onTap: () => onSelected(e.label),
                child: AnimatedContainer(duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? clr.withValues(alpha: 0.25) : (isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF0EDE8)),
                    borderRadius: BorderRadius.circular(20),
                    border: sel ? Border.all(color: clr, width: 1.5) : null),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(e.emoji, style: const TextStyle(fontSize: 16)), const SizedBox(width: 4),
                    Text(e.label, style: TextStyle(fontSize: 13,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                      color: sel ? clr : (isDark ? Colors.grey[300] : Colors.grey[600]))),
                  ])));
            }).toList(),)),
          ]));
      }),
    ]);
  }
}
