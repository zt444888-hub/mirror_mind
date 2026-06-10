import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emotion_provider.dart';
import '../models/emotion_record.dart';
import '../constants/colors.dart';
import 'dart:convert';

class GratitudeScreen extends StatefulWidget {
  const GratitudeScreen({super.key});

  @override
  State<GratitudeScreen> createState() => _GratitudeScreenState();
}

class _GratitudeScreenState extends State<GratitudeScreen> {
  final List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  bool _isSaving = false;
  List<EmotionRecord> _gratitudeRecords = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final allRecords = await context.read<EmotionProvider>().loadAllRecords();
    if (!mounted) return;
    setState(() {
      _gratitudeRecords = allRecords
          .where((r) => r.gratitudeItems != null && r.gratitudeItems!.isNotEmpty)
          .toList();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final items = _controllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('至少写一件事吧～'), backgroundColor: MirrorColors.warm),
      );
      return;
    }

    setState(() => _isSaving = true);

    final gratitudeJson = jsonEncode(items);
    final record = EmotionRecord(
      date: DateTime.now(),
      emotion: '感恩',
      gratitudeItems: gratitudeJson,
    );

    await context.read<EmotionProvider>().saveRecord(record);

    for (final c in _controllers) {
      c.clear();
    }

    await _loadHistory();
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('感恩已记录，心里暖暖的'),
          backgroundColor: MirrorColors.accent,
        ),
      );
    }
  }

  List<String> _parseItems(String jsonStr) {
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.cast<String>();
    } catch (_) {
      return [jsonStr];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? MirrorColors.darkBackground : MirrorColors.background,
      appBar: AppBar(title: const Text('感恩三件事')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 今天的记录区
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    MirrorColors.accentLight.withOpacity(0.5),
                    MirrorColors.warmLight.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('🕯️', style: TextStyle(fontSize: 24)),
                      SizedBox(width: 8),
                      Text(
                        '今天值得感恩的三件事',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...List.generate(3, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: MirrorColors.accent.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: MirrorColors.accentDark,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _controllers[index],
                              style: TextStyle(
                                fontSize: 15,
                                color: isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: '第 ${index + 1} 件感恩的事...',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.6),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _save,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.favorite, size: 18),
                      label: Text(_isSaving ? '保存中...' : '保存感恩记录'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MirrorColors.accentDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 历史记录
            if (_gratitudeRecords.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 12),
                child: Text('感恩日记', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              ..._gratitudeRecords.map((record) {
                final items = _parseItems(record.gratitudeItems ?? '');
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${record.date.month}月${record.date.day}日',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: MirrorColors.accentDark),
                        ),
                        const SizedBox(height: 10),
                        ...items.asMap().entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${entry.key + 1}. ',
                                  style: TextStyle(color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary, fontSize: 14),
                                ),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: TextStyle(fontSize: 14, color: isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
