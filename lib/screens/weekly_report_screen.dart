import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emotion_provider.dart';
import '../providers/settings_provider.dart';
import '../services/ai_service.dart';
import '../services/pdf_service.dart';
import '../models/emotion_record.dart';
import '../constants/colors.dart';

class WeeklyReportScreen extends StatefulWidget {
  const WeeklyReportScreen({super.key});

  @override
  State<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends State<WeeklyReportScreen> {
  WeeklyReportResult? _report;
  bool _isLoading = false;
  bool _isExporting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmotionProvider>().loadWeekRecords();
    });
  }

  Future<void> _generateReport() async {
    final settings = context.read<SettingsProvider>();
    final provider = context.read<EmotionProvider>();

    if (!settings.isApiConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('璇峰厛鍦ㄨ缃〉閰嶇疆 API Key'),
          backgroundColor: MirrorColors.warning,
          action: SnackBarAction(label: '鍘昏缃?, textColor: Colors.white, onPressed: _navigateToSettings),
        ),
      );
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

    await provider.loadWeekRecords();
    final result = await provider.generateWeeklyReport();

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

  void _navigateToSettings() {
    Navigator.pushNamed(context, '/settings');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weekRecords = context.watch<EmotionProvider>().weekRecords;

    return Scaffold(
      backgroundColor: isDark ? MirrorColors.darkBackground : MirrorColors.background,
      appBar: AppBar(title: const Text('鎯呯华鍛ㄦ姤')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 鏈懆缁熻
            if (weekRecords.isNotEmpty) _buildWeekStats(weekRecords, isDark),
            if (weekRecords.isNotEmpty) const SizedBox(height: 24),

            // 鐢熸垚鎸夐挳
            if (_report == null && !_isLoading) ...[
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: weekRecords.isEmpty ? null : _generateReport,
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: Text(weekRecords.isEmpty ? '鏈懆鏆傛棤鎯呯华璁板綍' : '鐢熸垚鏈懆鎯呯华浣撴鎶ュ憡'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MirrorColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],

            if (_isLoading) ...[
              const SizedBox(height: 40),
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: MirrorColors.primary),
                    SizedBox(height: 16),
                    Text('AI 姝ｅ湪鍒嗘瀽鏈懆鎯呯华...', style: TextStyle(color: MirrorColors.textSecondary)),
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
                child: Text(_error!, style: const TextStyle(color: MirrorColors.error)),
              ),
            ],

            // 鍛ㄦ姤鍗＄墖
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

  Widget _buildWeekStats(List<dynamic> records, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('鏈懆缁熻', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('璁板綍澶╂暟', '${records.length}', MirrorColors.primary),
                _buildStatItem('骞冲潎璇勫垎', _avgScore(records), MirrorColors.secondary),
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
            child: Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 13, color: MirrorColors.textSecondary)),
      ],
    );
  }

  String _avgScore(List<dynamic> records) {
    if (records.isEmpty) return '-';
    final sum = records.fold<int>(0, (acc, r) {
      if (r is Map) return acc + ((r['score'] as num?)?.toInt() ?? 5);
      if (r is EmotionRecord) return acc + r.score;
      return acc + 5;
    });
    return (sum / records.length).toStringAsFixed(1);
  }

  Widget _buildReportCard(bool isDark) {
    final report = _report!;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MirrorColors.primaryLight.withValues(alpha: 0.5),
            Color(0x80FBEAE3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: MirrorColors.primary.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 鏍囬琛?
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '鏈懆鎯呯华浣撴鎶ュ憡',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: MirrorColors.primaryDark),
                ),
              ),
              const Spacer(),
              const Icon(Icons.auto_awesome, size: 18, color: MirrorColors.primaryDark),
            ],
          ),
          const SizedBox(height: 20),

          // 涓诲鎯呯华
          if (report.dominantEmotion.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: MirrorColors.emotionColor(report.dominantEmotion).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _emojiFor(report.dominantEmotion),
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('鏈懆涓昏鎯呯华', style: TextStyle(fontSize: 12, color: MirrorColors.textSecondary)),
                        const SizedBox(height: 2),
                        Text(
                          report.dominantEmotion,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // 鎬荤粨
          if (report.summary.isNotEmpty) ...[
            Text(report.summary, style: const TextStyle(fontSize: 15, height: 1.6)),
            const SizedBox(height: 16),
          ],

          // 寤鸿
          if (report.suggestion.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('馃挕', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      report.suggestion,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 閲戝彞
          if (report.quote.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 12),
            Center(
              child: Text(
                '"${report.quote}"',
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: MirrorColors.primaryDark,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _emojiFor(String emotion) {
    switch (emotion) {
      case '寮€蹇?: return '馃槉';
      case '骞抽潤': return '馃槍';
      case '鍏村': return '馃ぉ';
      case '鎰熸仼': return '馃グ';
      case '鐒﹁檻': return '馃槹';
      case '闅捐繃': return '馃槩';
      case '鐢熸皵': return '馃槫';
      case '鐤叉儷': return '馃槾';
      default: return '馃槓';
    }
  }

  Widget _buildExportButton(bool isDark) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: _isExporting ? null : _exportPdf,
        icon: _isExporting
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.picture_as_pdf, size: 18),
        label: Text(_isExporting ? '瀵煎嚭涓?..' : '瀵煎嚭 PDF'),
        style: OutlinedButton.styleFrom(
          foregroundColor: MirrorColors.primaryDark,
          side: const BorderSide(color: MirrorColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Future<void> _exportPdf() async {
    setState(() => _isExporting = true);

    try {
      final provider = context.read<EmotionProvider>();
      final pdfService = PdfService();
      final weekRecords = provider.weekRecords;

      final reportData = <String, dynamic>{
        'dominantEmotion': _report?.dominantEmotion ?? '',
        'summary': _report?.summary ?? '',
        'suggestion': _report?.suggestion ?? '',
        'quote': _report?.quote ?? '',
      };

      final path = await pdfService.generateWeeklyReportPdf(
        records: weekRecords,
        weeklyReport: reportData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF 宸蹭繚瀛樿嚦锛?path'),
            backgroundColor: MirrorColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('瀵煎嚭澶辫触锛?{e.toString()}'),
            backgroundColor: MirrorColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
}

