import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/colors.dart';
import '../models/emotion_record.dart';

class MoodTrendChart extends StatelessWidget {
  final List<EmotionRecord> records;
  final void Function(EmotionRecord)? onDataPointTap;

  const MoodTrendChart({
    super.key,
    required this.records,
    this.onDataPointTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final spots = _buildSpots();
    final avgScore = spots.isEmpty ? 0.0 : spots.map((s) => s.y).reduce((a, b) => a + b) / spots.length;

    if (spots.isEmpty) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Text(
            '暂无情绪数据',
            style: TextStyle(color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 2,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 5,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= spots.length) return const SizedBox.shrink();
                      final date = _spotDate(index);
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${date.month}/${date.day}',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: 2,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minY: 0,
              maxY: 10,
              lineTouchData: LineTouchData(
                touchCallback: (event, response) {
                  if (event is FlTapUpEvent && response?.lineBarSpots != null && response!.lineBarSpots!.isNotEmpty) {
                    final index = response.lineBarSpots!.first.spotIndex;
                    if (index < records.length) {
                      onDataPointTap?.call(records[index]);
                    }
                  }
                },
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) => spots.map((s) {
                    final recordIndex = s.spotIndex;
                    final record = recordIndex < records.length ? records[recordIndex] : null;
                    return LineTooltipItem(
                      '${record?.emotion ?? ''}\n${s.y.toStringAsFixed(1)}分',
                      TextStyle(
                        color: MirrorColors.emotionColor(record?.emotion ?? '平静'),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
              ),
              lineBarsData: [
                // 主曲线
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: MirrorColors.primary,
                  barWidth: 2.5,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      final record = index < records.length ? records[index] : null;
                      return FlDotCirclePainter(
                        radius: 3.5,
                        color: MirrorColors.emotionColor(record?.emotion ?? '平静'),
                        strokeWidth: 1.5,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: MirrorColors.primary.withOpacity(0.08),
                  ),
                ),
                // 平均分虚线
                LineChartBarData(
                  spots: [
                    FlSpot(0, avgScore),
                    FlSpot((spots.length - 1).toDouble(), avgScore),
                  ],
                  isCurved: false,
                  color: MirrorColors.accentDark.withOpacity(0.6),
                  barWidth: 1,
                  dashArray: [6, 4],
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            '30天平均评分：${avgScore.toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _buildSpots() {
    // 取最近30天，按日期聚合取每日最新评分
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 29));
    final dateMap = <String, EmotionRecord>{};

    for (final record in records) {
      final d = record.date;
      if (d.isBefore(start) || d.isAfter(now)) continue;
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      if (!dateMap.containsKey(key)) {
        dateMap[key] = record;
      }
    }

    // 生成近30天每一天的数据点
    final spots = <FlSpot>[];
    for (int i = 0; i < 30; i++) {
      final date = start.add(Duration(days: i));
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      if (dateMap.containsKey(key)) {
        spots.add(FlSpot(i.toDouble(), dateMap[key]!.score.toDouble()));
      }
    }

    return spots;
  }

  DateTime _spotDate(int index) {
    final start = DateTime.now().subtract(const Duration(days: 29));
    return start.add(Duration(days: index));
  }
}
