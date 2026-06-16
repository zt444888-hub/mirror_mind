import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/festivals.dart';

class CalendarGrid extends StatelessWidget {
  final int year;
  final int month;
  final Map<int, Color> dayColors;
  final ValueChanged<int>? onDayTapped;

  const CalendarGrid({
    super.key,
    required this.year,
    required this.month,
    required this.dayColors,
    this.onDayTapped,
  });

  /// 获取某天的节日名称（取第一个）
  String? _festivalName(int day) {
    final festivals = Festival.getByDate(month, day);
    if (festivals.isEmpty) return null;
    // 优先显示中国传统节日
    final chinese = festivals.where((f) => f.type == 'chinese').toList();
    if (chinese.isNotEmpty) return chinese.first.emoji != null ? '${chinese.first.emoji} ${chinese.first.name}' : chinese.first.name;
    final first = festivals.first;
    return first.emoji != null ? '${first.emoji} ${first.name}' : first.name;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final daysInMonth = lastDay.day;
    final startWeekday = firstDay.weekday % 7; // 周日=0

    final today = DateTime.now();
    final isCurrentMonth = year == today.year && month == today.month;

    return Column(
      children: [
        // 星期标题
        Row(
          children: const ['日', '一', '二', '三', '四', '五', '六']
              .map((d) => Expanded(
                    child: Center(
                      child: Text(d, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: MirrorColors.textSecondary)),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),

        // 日历网格
        for (int week = 0; week < 6; week++) ...[
          Row(
            children: List.generate(7, (weekday) {
              final day = week * 7 + weekday - startWeekday + 1;
              if (day < 1 || day > daysInMonth) {
                return const Expanded(child: SizedBox(height: 40));
              }

              final isToday = isCurrentMonth && day == today.day;
              final color = dayColors[day];

              return Expanded(
                child: GestureDetector(
                  onTap: () => onDayTapped?.call(day),
                  child: Container(
                    height: 52,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isToday
                          ? MirrorColors.primary.withValues(alpha: 0.15)
                          : null,
                      borderRadius: BorderRadius.circular(10),
                      border: isToday
                          ? Border.all(color: MirrorColors.primary, width: 1.5)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                            color: isToday
                                ? MirrorColors.primaryDark
                                : isDark
                                    ? MirrorColors.darkTextPrimary
                                    : MirrorColors.textPrimary,
                          ),
                        ),
                        if (_festivalName(day) != null)
                          Text(
                            _festivalName(day)!,
                            style: const TextStyle(fontSize: 7, color: MirrorColors.accentDark, height: 1.0),
                            maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                          )
                        else if (color != null) ...[
                          const SizedBox(height: 3),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          if (week == 2) const SizedBox(height: 4), // 视觉呼吸
        ],
      ],
    );
  }
}
