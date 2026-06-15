import 'package:flutter/material.dart';
import '../constants/colors.dart';

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
                    height: 40,
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
                        if (color != null) ...[
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
