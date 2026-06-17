import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emotion_provider.dart';
import '../models/emotion_record.dart';
import '../constants/colors.dart';
import '../constants/emotions.dart';
import '../constants/festivals.dart';
import '../constants/festivals.dart';
import '../widgets/calendar_grid.dart';
import '../widgets/weekly_chart.dart';
import '../widgets/mood_trend_chart.dart';
import '../services/pdf_service.dart';
import '../services/purchase_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  Map<int, Color> _dayColors = {};
  Map<int, List<EmotionRecord>> _dayRecords = {};
  String _selectedTag = '全部';
  bool _isExporting = false;

  static const List<String> _tags = [
    '全部', '工作', '家庭', '社交', '健康', '财务', '情感',
    '成长', '其他', '每日一问', '深度日记', '7天挑战',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        if (_tabController.index == 0) {
          _loadMonthData();
        } else {
          _loadTrendData();
        }
      }
    });
    _loadMonthData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMonthData() async {
    final provider = context.read<EmotionProvider>();
    await provider.loadMonthRecordsByTag(_currentMonth.year, _currentMonth.month, tag: _selectedTag);

    final records = _selectedTag == '全部' ? provider.monthRecords : provider.tagFilteredMonthRecords;
    final colorMap = <int, Color>{};
    final recordMap = <int, List<EmotionRecord>>{};

    for (final record in records) {
      final day = record.date.day;
      if (!colorMap.containsKey(day)) {
        colorMap[day] = MirrorColors.emotionColor(record.emotion);
      }
      recordMap.putIfAbsent(day, () => []).add(record);
    }

    if (mounted) {
      setState(() {
        _dayColors = colorMap;
        _dayRecords = recordMap;
      });
    }
  }

  Future<void> _loadTrendData() async {
    final provider = context.read<EmotionProvider>();
    await provider.load30DayRecords();
  }

  void _onTagSelected(String tag) {
    setState(() => _selectedTag = tag);
    _loadMonthData();
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    _loadMonthData();
  }

  void _goToToday() {
    setState(() {
      _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    });
    _loadMonthData();
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    _loadMonthData();
  }

  void _onDayTapped(int day) {
    final date = DateTime(_currentMonth.year, _currentMonth.month, day);
    final records = _dayRecords[day] ?? [];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _buildDayDetail(date, records),
    );
  }

  Future<void> _exportMonthlyPdf() async {
    if (!PurchaseService().isPro) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('月报 PDF 为 Pro 功能，升级后解锁'),
            backgroundColor: MirrorColors.warm,
          ),
        );
        Navigator.pushNamed(context, '/pro');
      }
      return;
    }
    setState(() => _isExporting = true);
    try {
      final provider = context.read<EmotionProvider>();
      final pdfService = PdfService();
      final records = _selectedTag == '全部' ? provider.monthRecords : provider.tagFilteredMonthRecords;

      final path = await pdfService.generateMonthlyReportPdf(
        records: records,
        year: _currentMonth.year,
        month: _currentMonth.month,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('月报 PDF 已保存至：$path'),
            backgroundColor: MirrorColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败：${e.toString()}'),
            backgroundColor: MirrorColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Widget _buildDayDetail(DateTime date, List<EmotionRecord> records) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const SizedBox(height: 12),
          (() {
            final fs = Festival.getByDate(date.month, date.day);
            if (fs.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Wrap(spacing: 8, runSpacing: 4, children: fs.map((f) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: f.type == "chinese" ? Color(0x80E8D5B0) : Color(0x80D4C5E2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(f.emoji != null ? "${f.emoji} ${f.name}" : f.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: f.type == "chinese" ? MirrorColors.accentDark : MirrorColors.primaryDark)),
                );
              }).toList()),
            );
          })(),
          const SizedBox(height: 4),
          Text(
            '${date.month}月${date.day}日',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (records.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  '这天还没有记录情绪',
                  style: TextStyle(color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: records.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final record = records[index];
                  final emoji = EmotionType.fromLabel(record.emotion).emoji;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: MirrorColors.emotionColor(record.emotion).withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    record.emotion,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${record.score}/10',
                                    style: const TextStyle(fontSize: 12, color: MirrorColors.textSecondary),
                                  ),
                                ],
                              ),
                              if (record.inputText != null && record.inputText!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  record.inputText!,
                                  style: TextStyle(fontSize: 13, color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              if (record.aiResponse != null && record.aiResponse!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: MirrorColors.primaryLight.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    record.aiResponse!,
                                    style: const TextStyle(fontSize: 12, color: MirrorColors.primaryDark),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // TabBar
        Container(
          color: isDark ? MirrorColors.darkBackground : MirrorColors.background,
          child: TabBar(
            controller: _tabController,
            labelColor: MirrorColors.primaryDark,
            unselectedLabelColor: MirrorColors.textSecondary,
            indicatorColor: MirrorColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(text: '月视图'),
              Tab(text: '趋势'),
            ],
          ),
        ),
        // Tab 内容
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMonthView(isDark),
              _buildTrendView(isDark),
            ],
          ),
        ),
      ],
    );
  }

  /// 根据本月主要情绪生成人格标签
  String _getMoodPersonality(List<EmotionRecord> records) {
    if (records.isEmpty) return '';
    final counts = <String, int>{};
    for (final r in records) {
      counts[r.emotion] = (counts[r.emotion] ?? 0) + 1;
    }
    final top = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    if (top.isEmpty) return '';
    final emotion = top.first.key;
    switch (emotion) {
      case '开心': return '多巴胺达人 🎉';
      case '平静': return '佛系修行者 🧘';
      case '兴奋': return '小太阳 🌞';
      case '感恩': return '治愈系 🌿';
      case '焦虑': return '敏感探索家 🦋';
      case '难过': return '温柔诗人 🌧️';
      case '生气': return '热血战士 🔥';
      case '疲惫': return '充电达人 🔋';
      default: return '情绪探险家 🌈';
    }
  }

  Widget _buildMonthView(bool isDark) {
    final weekRecords = context.watch<EmotionProvider>().weekRecords;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 月份导航 + 导出按钮
          _buildMonthNav(isDark),
          if (context.watch<EmotionProvider>().monthRecords.isNotEmpty)
            _buildMoodPersonalityBadge(isDark, context.watch<EmotionProvider>().monthRecords),
          const SizedBox(height: 12),

          // 标签筛选
          _buildTagFilter(isDark),
          const SizedBox(height: 12),

          // 日历网格
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CalendarGrid(
                year: _currentMonth.year,
                month: _currentMonth.month,
                dayColors: _dayColors,
                onDayTapped: _onDayTapped,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 本周统计
          if (weekRecords.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '本周情绪概览',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '共记录 ${weekRecords.length} 次',
                      style: TextStyle(fontSize: 13, color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: WeeklyChart(records: weekRecords),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => Navigator.pushNamed(context, '/weekly_report'),
                        icon: const Icon(Icons.auto_awesome, size: 16),
                        label: const Text('生成 AI 周报'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (context.watch<EmotionProvider>().monthRecords.isNotEmpty)
            _buildMonthSummary(isDark, context.watch<EmotionProvider>().monthRecords),
        ],
      ),
    );
  }

  /// 本月情绪人格标签
  Widget _buildMoodPersonalityBadge(bool isDark, List<EmotionRecord> records) {
    final label = _getMoodPersonality(records);
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0x80D4C5E2), Color(0x33DCE8E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text('🎭', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('本月情绪人格', style: TextStyle(fontSize: 11, color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary)),
                const SizedBox(height: 2),
                Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 月度总结
  Widget _buildMonthSummary(bool isDark, List<EmotionRecord> records) {
    final counts = <String, int>{};
    for (final r in records) {
      counts[r.emotion] = (counts[r.emotion] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topEmotion = sorted.isNotEmpty ? sorted.first.key : '一般';
    final total = records.length;
    final scores = records.map((r) => r.score).whereType<int>().toList();
    final avgScore = scores.isEmpty ? 0.0 : scores.reduce((a, b) => a + b) / scores.length;

    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('📊', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text('本月概览', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 12),
            _buildSummaryRow('📝 记录天数', '$total 天'),
            _buildSummaryRow('🎭 主要情绪', topEmotion),
            _buildSummaryRow('⭐ 平均评分', '${avgScore.toStringAsFixed(1)} / 10'),
            if (sorted.length >= 2)
              _buildSummaryRow('😊 次主要', '${sorted[1].key}'),
            const SizedBox(height: 12),
            Text(_getMonthMotto(topEmotion, total), style: TextStyle(fontSize: 13, color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: MirrorColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _getMonthMotto(String topEmotion, int total) {
    switch (topEmotion) {
      case '开心': return '🌸 这个月你有 $total 天带着阳光般的笑容，继续保持！';
      case '平静': return '🍃 这个月你保持了 $total 天的内心平静，真了不起。';
      case '兴奋': return '⚡ 这个月你充满了能量，$total 天的热度不减！';
      case '感恩': return '💝 这个月你心怀感恩度过了 $total 天，温暖了身边的人。';
      case '焦虑': return '🦋 这个月你有 $total 天的记录，每一步觉察都是成长。';
      case '难过': return '🌧️ 这个月你经历了 $total 天，允许情绪流动就是勇气。';
      case '生气': return '🔥 这个月你记录了 $total 天，每一种情绪都值得被看见。';
      case '疲惫': return '🔋 这个月你坚持记录了 $total 天，别忘了给自己充电。';
      default: return '🌈 这个月你记录了 $total 天，每一次觉察都是对自己的关心。';
    }
  }

  Widget _buildTrendView(bool isDark) {
    final provider = context.watch<EmotionProvider>();
    final records = provider.thirtyDayRecords;

    if (records.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildMonthNav(isDark),
          if (context.watch<EmotionProvider>().monthRecords.isNotEmpty)
            _buildMoodPersonalityBadge(isDark, context.watch<EmotionProvider>().monthRecords),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: MoodTrendChart(
                  records: records,
                  onDataPointTap: (record) {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (ctx) => _buildDayDetail(record.date, [record]),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMonthNav(isDark),
          if (context.watch<EmotionProvider>().monthRecords.isNotEmpty)
            _buildMoodPersonalityBadge(isDark, context.watch<EmotionProvider>().monthRecords),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '30天情绪趋势',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  MoodTrendChart(
                    records: records,
                    onDataPointTap: (record) {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (ctx) => _buildDayDetail(record.date, [record]),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthNav(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _previousMonth,
        ),
        Row(
          children: [
            Text(
              '${_currentMonth.year}年 ${_currentMonth.month}月',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: _goToToday,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0x80D4C5E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('今日', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: MirrorColors.primaryDark)),
              ),
            ),
            const SizedBox(width: 8),
            // 导出月报按钮
            IconButton(
              icon: _isExporting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.picture_as_pdf, size: 20),
              onPressed: _isExporting ? null : _exportMonthlyPdf,
              tooltip: '导出月报 PDF',
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _nextMonth,
        ),
      ],
    );
  }

  Widget _buildTagFilter(bool isDark) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _tags.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tag = _tags[index];
          final isSelected = _selectedTag == tag;
          return GestureDetector(
            onTap: () => _onTagSelected(tag),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Color(0x80D4C5E2)
                    : (isDark ? MirrorColors.darkSurface : MirrorColors.cardBackground),
                borderRadius: BorderRadius.circular(18),
                border: isSelected ? Border.all(color: MirrorColors.primary, width: 1.2) : null,
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? MirrorColors.primaryDark
                      : (isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
