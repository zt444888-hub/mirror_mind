import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/emotion_record.dart';

class PdfService {
  static const _accentColor = PdfColor.fromInt(0xFF8B7E74);
  static const _primaryColor = PdfColor.fromInt(0xFF9C8E85);
  static const _lightBgColor = PdfColor.fromInt(0xFFF5F0EB);
  static const _textColor = PdfColor.fromInt(0xFF3C3C3C);
  static const _secondaryTextColor = PdfColor.fromInt(0xFF8C8C8C);

  /// 生成周报 PDF
  Future<String> generateWeeklyReportPdf({
    required List<EmotionRecord> records,
    required Map<String, dynamic> weeklyReport,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) {
          return [
            // 标题
            _buildHeader('情绪周报', '${_weekRange(records)} · 生成于${now.year}年${now.month}月${now.day}日'),
            pw.SizedBox(height: 20),

            // 统计概览
            _buildSectionTitle('本周统计'),
            _buildStatsRow(records),
            pw.SizedBox(height: 20),

            // 情绪分布
            _buildSectionTitle('情绪分布'),
            _buildEmotionDistribution(records),
            pw.SizedBox(height: 20),

            // 主导情绪
            if (weeklyReport['dominantEmotion'] != null && weeklyReport['dominantEmotion'].toString().isNotEmpty) ...[
              _buildSectionTitle('本周主要情绪'),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: _lightBgColor,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Text(
                  weeklyReport['dominantEmotion'].toString(),
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: _accentColor),
                ),
              ),
              pw.SizedBox(height: 16),
            ],

            // AI 总结
            if (weeklyReport['summary'] != null && weeklyReport['summary'].toString().isNotEmpty) ...[
              _buildSectionTitle('AI 总结'),
              pw.Text(
                weeklyReport['summary'].toString(),
                style: const pw.TextStyle(fontSize: 12, lineSpacing: 1.6, color: _textColor),
              ),
              pw.SizedBox(height: 16),
            ],

            // AI 建议
            if (weeklyReport['suggestion'] != null && weeklyReport['suggestion'].toString().isNotEmpty) ...[
              _buildSectionTitle('AI 建议'),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: _lightBgColor,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Text(
                  weeklyReport['suggestion'].toString(),
                  style: const pw.TextStyle(fontSize: 12, lineSpacing: 1.6, color: _textColor),
                ),
              ),
              pw.SizedBox(height: 16),
            ],

            // 每日记录
            _buildSectionTitle('每日记录'),
            ..._buildDailyRecords(records),

            pw.SizedBox(height: 30),

            // 页脚
            pw.Center(
              child: pw.Text(
                '心镜 MirrorMind — AI情绪日记与心理健康',
                style: const pw.TextStyle(fontSize: 9, color: _secondaryTextColor),
              ),
            ),
          ];
        },
      ),
    );

    return await _savePdf(pdf, '心镜周报_${now.year}年${now.month}月${now.day}日.pdf');
  }

  /// 生成月报 PDF
  Future<String> generateMonthlyReportPdf({
    required List<EmotionRecord> records,
    required int year,
    required int month,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) {
          return [
            _buildHeader('情绪月报', '$year年$month月 · 生成于${DateTime.now().year}年${DateTime.now().month}月${DateTime.now().day}日'),
            pw.SizedBox(height: 20),

            _buildSectionTitle('月度统计'),
            _buildStatsRow(records),
            pw.SizedBox(height: 20),

            _buildSectionTitle('情绪分布'),
            _buildEmotionDistribution(records),
            pw.SizedBox(height: 20),

            // 情绪变化摘要
            _buildSectionTitle('情绪变化摘要'),
            pw.Text(
              _buildMonthlySummary(records),
              style: const pw.TextStyle(fontSize: 12, lineSpacing: 1.6, color: _textColor),
            ),
            pw.SizedBox(height: 16),

            // 记录天数统计
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: _lightBgColor,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildMiniStat('记录天数', '${records.map((r) => r.date.day).toSet().length}'),
                  _buildMiniStat('总记录数', '${records.length}'),
                  _buildMiniStat('平均评分', '${_avgScore(records)}'),
                ],
              ),
            ),
            pw.SizedBox(height: 30),

            pw.Center(
              child: pw.Text(
                '心镜 MirrorMind — AI情绪日记与心理健康',
                style: const pw.TextStyle(fontSize: 9, color: _secondaryTextColor),
              ),
            ),
          ];
        },
      ),
    );

    return await _savePdf(pdf, '心镜月报_${year}年${month}月.pdf');
  }

  pw.Widget _buildHeader(String title, String subtitle) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: pw.BoxDecoration(
            color: _lightBgColor,
            borderRadius: pw.BorderRadius.circular(12),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: _accentColor)),
              pw.SizedBox(height: 4),
              pw.Text(subtitle, style: const pw.TextStyle(fontSize: 10, color: _secondaryTextColor)),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Text(
        title,
        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: _textColor),
      ),
    );
  }

  pw.Widget _buildStatsRow(List<EmotionRecord> records) {
    final avgScore = _avgScore(records);
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
      children: [
        _buildMiniStat('记录天数', '${records.map((r) => r.date.day).toSet().length}'),
        _buildMiniStat('总记录数', '${records.length}'),
        _buildMiniStat('平均评分', avgScore),
      ],
    );
  }

  pw.Widget _buildMiniStat(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: _accentColor)),
        pw.SizedBox(height: 2),
        pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: _secondaryTextColor)),
      ],
    );
  }

  pw.Widget _buildEmotionDistribution(List<EmotionRecord> records) {
    final distribution = <String, int>{};
    for (final r in records) {
      distribution[r.emotion] = (distribution[r.emotion] ?? 0) + 1;
    }

    final entries = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return pw.Column(
      children: entries.map((entry) {
        final ratio = records.isEmpty ? 0.0 : entry.value / records.length;
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 6),
          child: pw.Row(
            children: [
              pw.SizedBox(
                width: 50,
                child: pw.Text(entry.key, style: const pw.TextStyle(fontSize: 10, color: _textColor)),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: pw.Container(
                  height: 14,
                  decoration: pw.BoxDecoration(
                    color: _lightBgColor,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Align(
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Container(
                      width: 200 * ratio,
                      height: 14,
                      decoration: pw.BoxDecoration(
                        color: _primaryColor,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.SizedBox(
                width: 32,
                child: pw.Text(
                  '${entry.value}次',
                  style: const pw.TextStyle(fontSize: 9, color: _secondaryTextColor),
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<pw.Widget> _buildDailyRecords(List<EmotionRecord> records) {
    if (records.isEmpty) {
      return [
        pw.Text('暂无记录', style: const pw.TextStyle(fontSize: 10, color: _secondaryTextColor)),
      ];
    }

    // 按日期分组
    final grouped = <String, List<EmotionRecord>>{};
    for (final r in records) {
      final key = '${r.date.month}月${r.date.day}日';
      grouped.putIfAbsent(key, () => []).add(r);
    }

    return [
      pw.TableHelper.fromTextArray(
        headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: _accentColor),
        cellStyle: const pw.TextStyle(fontSize: 9, color: _textColor),
        headerDecoration: const pw.BoxDecoration(color: _lightBgColor),
        cellPadding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        headers: ['日期', '情绪', '评分', '备注'],
        data: grouped.entries.where((e) => e.key.isNotEmpty).map((entry) {
          final first = entry.value.first;
          return [
            entry.key,
            first.emotion,
            '${first.score}/10',
            first.inputText ?? '',
          ];
        }).toList(),
      ),
    ];
  }

  String _buildMonthlySummary(List<EmotionRecord> records) {
    if (records.isEmpty) return '本月暂无情绪记录。';
    final avgScore = _avgScore(records);
    final days = records.map((r) => r.date.day).toSet().length;
    return '本月在$days天中记录了${records.length}次情绪，平均评分为$avgScore分。'
        '建议持续记录，关注情绪变化趋势，培养情绪觉察能力。';
  }

  String _avgScore(List<EmotionRecord> records) {
    if (records.isEmpty) return '-';
    final sum = records.fold<int>(0, (acc, r) => acc + r.score);
    return (sum / records.length).toStringAsFixed(1);
  }

  String _weekRange(List<EmotionRecord> records) {
    if (records.isEmpty) {
      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final sunday = monday.add(const Duration(days: 6));
      return '${monday.month}月${monday.day}日 - ${sunday.month}月${sunday.day}日';
    }
    records.sort((a, b) => a.date.compareTo(b.date));
    final first = records.first.date;
    final last = records.last.date;
    return '${first.month}月${first.day}日 - ${last.month}月${last.day}日';
  }


  /// 生成年度报告 PDF
  Future<String> generateAnnualReportPdf({
    required List<EmotionRecord> records,
    required int year,
  }) async {
    final pdf = pw.Document();

    // 按月分组
    final monthlyData = <int, List<EmotionRecord>>{};
    for (int m = 1; m <= 12; m++) {
      monthlyData[m] = [];
    }
    for (final r in records) {
      if (r.date.year == year) {
        final m = r.date.month;
        monthlyData[m]?.add(r);
      }
    }

    // 年度情绪计数
    final emotionCounts = <String, int>{};
    for (final r in records) {
      emotionCounts[r.emotion] = (emotionCounts[r.emotion] ?? 0) + 1;
    }
    final topEmotions = emotionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top10 = topEmotions.take(10).toList();

    // 每月均值
    final monthlyAvg = <int, String>{};
    for (int m = 1; m <= 12; m++) {
      final monthRecords = monthlyData[m] ?? [];
      if (monthRecords.isEmpty) {
        monthlyAvg[m] = '-';
      } else {
        final sum = monthRecords.fold<int>(0, (acc, r) => acc + r.score);
        monthlyAvg[m] = (sum / monthRecords.length).toStringAsFixed(1);
      }
    }

    // 每月最佳/最差日
    final monthlyBest = <int, String>{};
    final monthlyWorst = <int, String>{};
    for (int m = 1; m <= 12; m++) {
      final monthRecords = monthlyData[m] ?? [];
      if (monthRecords.isEmpty) {
        monthlyBest[m] = '-';
        monthlyWorst[m] = '-';
      } else {
        final sorted = List<EmotionRecord>.from(monthRecords)
          ..sort((a, b) => b.score.compareTo(a.score));
        monthlyBest[m] = '${sorted.first.date.month}月${sorted.first.date.day}日 (${sorted.first.score}分)';
        monthlyWorst[m] = '${sorted.last.date.month}月${sorted.last.date.day}日 (${sorted.last.score}分)';
      }
    }

    // 年度总结文案
    final totalDays = records.map((r) => '${r.date.month}-${r.date.day}').toSet().length;
    final totalRecords = records.length;
    final yearAvgScore = totalRecords > 0
        ? (records.fold<int>(0, (acc, r) => acc + r.score) / totalRecords).toStringAsFixed(1)
        : '-';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) {
          final widgets = <pw.Widget>[];

          // 标题
          widgets.add(_buildHeader('情绪年度报告', '$year 年 · 生成于${DateTime.now().year}年${DateTime.now().month}月${DateTime.now().day}日'));
          widgets.add(pw.SizedBox(height: 20));

          // 年度统计概览
          widgets.add(_buildSectionTitle('年度统计'));
          widgets.add(pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(color: _lightBgColor, borderRadius: pw.BorderRadius.circular(8)),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat('记录天数', '$totalDays'),
                _buildMiniStat('总记录数', '$totalRecords'),
                _buildMiniStat('年度均分', yearAvgScore),
              ],
            ),
          ));
          widgets.add(pw.SizedBox(height: 20));

          // 月度情绪趋势（表格模拟折线）
          widgets.add(_buildSectionTitle('月度情绪均值趋势'));
          widgets.add(_buildMonthlyTrendTable(monthlyAvg));
          widgets.add(pw.SizedBox(height: 20));

          // 每月最佳/最差日
          widgets.add(_buildSectionTitle('每月最佳日 & 最差日'));
          widgets.add(_buildBestWorstTable(monthlyBest, monthlyWorst));
          widgets.add(pw.SizedBox(height: 20));

          // 年度情绪分布
          widgets.add(_buildSectionTitle('年度情绪分布'));
          widgets.add(_buildEmotionDistribution(records));
          widgets.add(pw.SizedBox(height: 20));

          // 高频情绪 Top 10
          widgets.add(_buildSectionTitle('年度高频情绪 Top 10'));
          for (int i = 0; i < top10.length; i++) {
            final entry = top10[i];
            widgets.add(pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Row(
                children: [
                  pw.SizedBox(
                    width: 30,
                    child: pw.Text('#${i + 1}', style: const pw.TextStyle(fontSize: 10, color: _secondaryTextColor)),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    child: pw.Text(entry.key, style: const pw.TextStyle(fontSize: 12, color: _textColor)),
                  ),
                  pw.Text('${entry.value}次', style: const pw.TextStyle(fontSize: 10, color: _secondaryTextColor)),
                ],
              ),
            ));
          }
          widgets.add(pw.SizedBox(height: 16));

          // 年度总结
          widgets.add(_buildSectionTitle('年度情绪总结'));
          widgets.add(pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(color: _lightBgColor, borderRadius: pw.BorderRadius.circular(8)),
            child: pw.Text(
              '在 $year 年的 $totalDays 个日子里，你记录了 $totalRecords 次情绪。'
              '年度平均评分为 $yearAvgScore 分。'
              '${top10.isNotEmpty ? "你最常感受到的情绪是「${top10.first.key}」，共出现 ${top10.first.value} 次。" : ""}'
              '每一次记录都是对自己内心的关照。这些情绪数据反映了你一整年的心路历程——'
              '有高光时刻的喜悦，也有低谷时的沉静。'
              '新的一年，愿你继续保持这份觉察，温柔对待自己的每一种情绪。'
              '心镜会一直陪伴你，见证你的成长与变化。',
              style: const pw.TextStyle(fontSize: 12, lineSpacing: 1.8, color: _textColor),
            ),
          ));
          widgets.add(pw.SizedBox(height: 30));

          // 页脚
          widgets.add(pw.Center(
            child: pw.Text(
              '心镜 MirrorMind — AI情绪日记与心理健康',
              style: const pw.TextStyle(fontSize: 9, color: _secondaryTextColor),
            ),
          ));

          return widgets;
        },
      ),
    );

    return await _savePdf(pdf, '心镜年报_${year}年.pdf');
  }

  /// 月度趋势表格
  pw.Widget _buildMonthlyTrendTable(Map<int, String> monthlyAvg) {
    final months = ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'];
    return pw.Table(
      border: pw.TableBorder.all(color: _lightBgColor, width: 1),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _lightBgColor),
          children: [
            ...months.map((m) => pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(m, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _textColor), textAlign: pw.TextAlign.center),
            )),
          ],
        ),
        pw.TableRow(
          children: [
            for (int m = 1; m <= 12; m++)
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(
                  monthlyAvg[m] ?? '-',
                  style: const pw.TextStyle(fontSize: 10, color: _accentColor),
                  textAlign: pw.TextAlign.center,
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// 每月最佳/最差日表格
  pw.Widget _buildBestWorstTable(Map<int, String> best, Map<int, String> worst) {
    return pw.Table(
      border: pw.TableBorder.all(color: _lightBgColor, width: 1),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _lightBgColor),
          children: [
            pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('月份', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _textColor), textAlign: pw.TextAlign.center)),
            pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('最佳日', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _textColor), textAlign: pw.TextAlign.center)),
            pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('最差日', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _textColor), textAlign: pw.TextAlign.center)),
          ],
        ),
        for (int m = 1; m <= 12; m++)
          pw.TableRow(
            children: [
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('${m}月', style: const pw.TextStyle(fontSize: 8, color: _textColor), textAlign: pw.TextAlign.center)),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(best[m] ?? '-', style: const pw.TextStyle(fontSize: 8, color: _textColor), textAlign: pw.TextAlign.center)),
              pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(worst[m] ?? '-', style: const pw.TextStyle(fontSize: 8, color: _textColor), textAlign: pw.TextAlign.center)),
            ],
          ),
      ],
    );
  }
  Future<String> _savePdf(pw.Document pdf, String fileName) async {
    final pdfBytes = await pdf.save();
    
    // 先保存到应用文档目录（备用位置）
    final appDir = await getApplicationDocumentsDirectory();
    final appFile = File('${appDir.path}/$fileName');
    
    try {
      await appFile.writeAsBytes(pdfBytes);
    } catch (e) {
      throw PdfSaveException('无法保存到应用目录: $e');
    }

    // 尝试保存到系统下载目录（优先）
    if (Platform.isWindows || Platform.isLinux) {
      final homeDir = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'];
      if (homeDir != null) {
        final downloadDir = Directory('$homeDir\\Downloads');
        if (downloadDir.existsSync()) {
          try {
            final downloadFile = File('${downloadDir.path}\\$fileName');
            await downloadFile.writeAsBytes(pdfBytes);
            return downloadFile.path;
          } catch (e) {
            // 下载目录保存失败，返回应用目录路径并提示用户
            return appFile.path;
          }
        }
      }
    } else if (Platform.isMacOS) {
      final homeDir = Platform.environment['HOME'];
      if (homeDir != null) {
        final downloadDir = Directory('$homeDir/Downloads');
        if (downloadDir.existsSync()) {
          try {
            final downloadFile = File('${downloadDir.path}/$fileName');
            await downloadFile.writeAsBytes(pdfBytes);
            return downloadFile.path;
          } catch (e) {
            return appFile.path;
          }
        }
      }
    }

    return appFile.path;
  }
}

/// PDF 保存异常
class PdfSaveException implements Exception {
  final String message;
  const PdfSaveException(this.message);

  @override
  String toString() => message;
}
