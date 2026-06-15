import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emotion_provider.dart';
import '../providers/settings_provider.dart';
import '../services/ai_service.dart';
import '../services/pdf_service.dart';
import '../services/purchase_service.dart';
import '../models/emotion_record.dart';
import '../constants/colors.dart';
import '../widgets/mood_trend_chart.dart';

class YearReportScreen extends StatefulWidget {
  const YearReportScreen({super.key});

  @override
  State<YearReportScreen> createState() => _YearReportScreenState();
}

class _YearReportScreenState extends State<YearReportScreen> {
  YearReportResult? _report;
  bool _isLoading = false;
  bool _isExporting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmotionProvider>().loadYearRecords();
    });
  }

  Future<void> _generateReport() async {
    final settings = context.read<SettingsProvider>();
    final provider = context.read<EmotionProvider>();

    if (!settings.isApiConfigured) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请先在设置页配置 API Key'),
          backgroundColor: MirrorColors.warning,
          action: SnackBarAction(
            label: '去设置',
            textColor: Colors.white,
            onPressed: _navigateToSettings,
          ),
        ),
      );
      return;
    }

    if (!PurchaseService().isPro) {
      if (!mounted) return;
      Navigator.pushNamed(context, '/pro',
          arguments: {'hint': '年度报告为 Pro 功能，升级后解锁完整分析'});
      return;
    }

    provider.updateAiConfig(
      baseUrl: settings.baseUrl,
      apiKey: settings.apiKey,
      model: settings.model,
    );

    setState(() {
      _isLoading = true;
      _error = null;
    });

    await provider.loadYearRecords();
    final result = await provider.generateYearReport();

    if (!mounted) return;

    if (provider.aiError != null) {
      setState(() {
        _isLoading = false;
        _error = provider.aiError;
      });
      provider.clearAiError();
      return;
    }

    setState(() {
      _isLoading = false;
      _report = result;
    });
  }

  Future<void> _exportPdf() async {
    if (_report == null) return;

    setState(() => _isExporting = true);

    try {
      final provider = context.read<EmotionProvider>();
      final pdfService = PdfService();
      await pdfService.generateAnnualReportPdf(
        records: provider.yearRecords,
        year: DateTime.now().year,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('年度报告已导出到下载目录'),
          backgroundColor: MirrorColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('导出失败：$e'),
          backgroundColor: MirrorColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _navigateToSettings() {
    if (mounted) {
      Navigator.pushNamed(context, '/settings');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final yearRecords = context.watch<EmotionProvider>().yearRecords;
    final isPro = PurchaseService().isPro;

    return Scaffold(
      backgroundColor:
          isDark ? MirrorColors.darkBackground : MirrorColors.background,
      appBar: AppBar(title: const Text('年度情绪回顾')),
      body: yearRecords.isEmpty && _report == null && !_isLoading
          ? _buildEmptyState(isDark)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 年度趋势图
                  if (yearRecords.isNotEmpty)
                    _buildYearOverview(yearRecords, isDark),
                  if (yearRecords.isNotEmpty) const SizedBox(height: 24),

                  // 生成按钮
                  if (_report == null && !_isLoading) ...[
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: isPro ? _generateReport : () {
                          Navigator.pushNamed(context, '/pro',
                              arguments: {'hint': '年度报告为 Pro 功能，解锁完整情绪分析'});
                        },
                        icon: Icon(
                          isPro ? Icons.auto_awesome : Icons.lock_outline,
                          size: 18,
                        ),
                        label: Text(isPro ? '生成年度情绪分析报告' : '升级 Pro 解锁年度报告'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MirrorColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],

                  if (_isLoading) ...[
                    const SizedBox(height: 40),
                    const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                              color: MirrorColors.primary),
                          SizedBox(height: 16),
                          Text('AI 正在分析全年情绪...',
                              style:
                                  TextStyle(color: MirrorColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],

                  if (_error != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: MirrorColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(_error!,
                          style: const TextStyle(color: MirrorColors.error)),
                    ),
                  ],

                  // 年报卡片
                  if (_report != null) ...[
                    const SizedBox(height: 16),
                    _buildReportCard(isDark),
                    const SizedBox(height: 16),
                    _buildExportButton(isDark),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today,
                size: 64,
                color: isDark
                    ? MirrorColors.darkTextSecondary
                    : MirrorColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              '暂无年度数据',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? MirrorColors.darkTextPrimary
                    : MirrorColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '记录更多心情后，这里将展示你的年度情绪回顾',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? MirrorColors.darkTextSecondary
                    : MirrorColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearOverview(List<dynamic> records, bool isDark) {
    final typedRecords = records
        .whereType<EmotionRecord>()
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('年度情绪趋势',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            SizedBox(
              height: 240,
              child: typedRecords.isEmpty
                  ? const Center(child: Text('暂无数据'))
                  : MoodTrendChart(
                      records: typedRecords,
                      onDataPointTap: (record) {
                        showModalBottomSheet(
                          context: context,
                          builder: (_) => _buildRecordDetail(record),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                    '记录天数', '${records.length}', MirrorColors.primary),
                _buildStatItem('平均评分', _avgScore(typedRecords),
                    MirrorColors.secondary),
                _buildStatItem('最常见情绪', _mostCommon(typedRecords),
                    MirrorColors.accent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: MirrorColors.textSecondary)),
      ],
    );
  }

  String _avgScore(List<EmotionRecord> records) {
    if (records.isEmpty) return '-';
    final sum = records.fold<int>(0, (acc, r) => acc + r.score);
    return (sum / records.length).toStringAsFixed(1);
  }

  String _mostCommon(List<EmotionRecord> records) {
    if (records.isEmpty) return '-';
    final map = <String, int>{};
    for (final r in records) {
      map[r.emotion] = (map[r.emotion] ?? 0) + 1;
    }
    return map.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  Widget _buildReportCard(bool isDark) {
    final report = _report!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome,
                    color: MirrorColors.primary, size: 20),
                const SizedBox(width: 8),
                const Text('AI 年度情绪分析',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection('年度关键词', report.keywords.join(' · ')),
            _buildSection('整体趋势', report.trend),
            _buildSection('情绪洞察', report.insight),
            _buildSection('建议', report.suggestion),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('年度评分',
                    style: TextStyle(
                        color: isDark
                            ? MirrorColors.darkTextSecondary
                            : MirrorColors.textSecondary)),
                Text('${report.avgScore.toStringAsFixed(1)} / 10',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: MirrorColors.primaryDark)),
          const SizedBox(height: 6),
          Text(content,
              style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: MirrorColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildExportButton(bool isDark) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _isExporting ? null : _exportPdf,
        icon: _isExporting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.picture_as_pdf, size: 18),
        label: Text(_isExporting ? '导出中...' : '导出 PDF 年度报告'),
        style: OutlinedButton.styleFrom(
          foregroundColor: MirrorColors.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: const BorderSide(color: MirrorColors.primary),
        ),
      ),
    );
  }

  Widget _buildRecordDetail(EmotionRecord record) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${record.date.year}年${record.date.month}月${record.date.day}日',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text('情绪：${record.emotion}',
              style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 6),
          Text('评分：${record.score} / 10',
              style: const TextStyle(fontSize: 15)),
          if (record.note != null && record.note!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('记录：${record.note}',
                style: const TextStyle(
                    fontSize: 14, color: MirrorColors.textSecondary)),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
