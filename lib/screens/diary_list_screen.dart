import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emotion_provider.dart';
import '../models/emotion_record.dart';
import '../constants/colors.dart';

/// 日记列表页：展示所有长文记录（深度日记模式）
class DiaryListScreen extends StatefulWidget {
  const DiaryListScreen({super.key});

  @override
  State<DiaryListScreen> createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends State<DiaryListScreen> {
  List<EmotionRecord> _diaries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDiaries();
  }

  Future<void> _loadDiaries() async {
    setState(() => _isLoading = true);
    final provider = context.read<EmotionProvider>();
    final allRecords = await provider.loadAllRecords();
    // 筛选 tag 为"深度日记"的长文记录
    final diaries = allRecords.where((r) => r.tag == '深度日记').toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (mounted) {
      setState(() {
        _diaries = diaries;
        _isLoading = false;
      });
    }
  }

  /// 删除日记
  Future<void> _deleteDiary(EmotionRecord record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('删除日记'),
        content: const Text('删除后无法恢复，确定要删除这篇日记吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: MirrorColors.error),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await context.read<EmotionProvider>().deleteRecord(record.id!);
      _loadDiaries();
    }
  }

  /// 提取标题（从 inputText 中解析）
  String _extractTitle(EmotionRecord record) {
    final text = record.inputText ?? '';
    if (text.isEmpty) return '';
    if (text.startsWith('标题：')) {
      final titleEnd = text.indexOf('\n');
      if (titleEnd > 0) {
        return text.substring(3, titleEnd).trim();
      }
    }
    final firstLine = text.split('\n').first;
    return firstLine.length > 20 ? '${firstLine.substring(0, 20)}...' : firstLine;
  }

  /// 提取正文预览
  String _extractPreview(EmotionRecord record) {
    final text = record.inputText ?? '';
    if (text.isEmpty) return '';
    String content = text;
    if (text.startsWith('标题：')) {
      final titleEnd = text.indexOf('\n');
      if (titleEnd > 0) {
        content = text.substring(titleEnd + 1).trim();
        if (content.startsWith('内容：')) {
          content = content.substring(3).trim();
        }
      }
    }
    return content.length > 100 ? '${content.substring(0, 100)}...' : content;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return '今天';
    if (diff.inDays == 1) return '昨天';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? MirrorColors.darkBackground : MirrorColors.background,
      appBar: AppBar(title: const Text('我的日记')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _diaries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('📖', style: TextStyle(fontSize: 48, color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary)),
                      const SizedBox(height: 16),
                      Text(
                        '还没有日记',
                        style: TextStyle(fontSize: 16, color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '在"深度日记"模式下写点什么吧',
                        style: TextStyle(fontSize: 13, color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDiaries,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _diaries.length,
                    itemBuilder: (context, index) {
                      final diary = _diaries[index];
                      return _buildDiaryCard(isDark, diary);
                    },
                  ),
                ),
    );
  }

  Widget _buildDiaryCard(bool isDark, EmotionRecord diary) {
    final title = _extractTitle(diary);
    final preview = _extractPreview(diary);
    final dateStr = _formatDate(diary.date);

    return Dismissible(
      key: Key('diary_${diary.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: MirrorColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: MirrorColors.error),
      ),
      confirmDismiss: (_) async {
        await _deleteDiary(diary);
        return false; // 手动处理删除，不依赖 Dismissible 默认行为
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () => _showDiaryDetail(diary),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: MirrorColors.primaryLight.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: MirrorColors.primaryDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  preview,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 14, color: MirrorColors.accent),
                    const SizedBox(width: 4),
                    Text(
                      diary.emotion,
                      style: const TextStyle(
                        fontSize: 12,
                        color: MirrorColors.accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDiaryDetail(EmotionRecord diary) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = _extractTitle(diary);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: ListView(
                controller: scrollController,
                children: [
                  // 拖拽条
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${diary.date.year}-${diary.date.month.toString().padLeft(2, '0')}-${diary.date.day.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: MirrorColors.emotionColor(diary.emotion).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          diary.emotion,
                          style: TextStyle(
                            fontSize: 12,
                            color: MirrorColors.emotionColor(diary.emotion),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    _extractPreview(diary),
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.8,
                      color: isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
