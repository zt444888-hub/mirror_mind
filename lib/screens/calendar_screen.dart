import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emotion_provider.dart';
import '../models/emotion_record.dart';
import '../constants/colors.dart';
import '../constants/emotions.dart';
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
          const SizedBox(height: 16),
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
                                    style: TextStyle(fontSize: 12, color: MirrorColors.textSecondary),
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

  Widget _buildMonthView(bool isDark) {
    final weekRecords = context.watch<EmotionProvider>().weekRecords;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 月份导航 + 导出按钮
          _buildMonthNav(isDark),
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
        ],
      ),
    );
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
                    ? MirrorColors.primaryLight.withValues(alpha: 0.3)
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
