import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/emotion_provider.dart';
import '../constants/colors.dart';
import '../constants/emotions.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  String? _currentEmotion;
  List<String> _advices = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadLatestEmotion();
  }

  Future<void> _loadLatestEmotion() async {
    final provider = context.read<EmotionProvider>();
    await provider.loadLatestRecord();
    if (mounted) {
      final latest = provider.latestRecord;
      if (latest != null) {
        setState(() {
          _currentEmotion = latest.emotion;
          _advices = getEmergencyAdvices(latest.emotion);
          _loaded = true;
        });
      } else {
        // 使用默认建议
        setState(() {
          _advices = getEmergencyAdvices('焦虑');
          _loaded = true;
        });
      }
    }
  }

  void _selectEmotion(String emotion) {
    setState(() {
      _currentEmotion = emotion;
      _advices = getEmergencyAdvices(emotion);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? MirrorColors.darkBackground : MirrorColors.background,
      appBar: AppBar(title: const Text('情绪急救包')),
      body: _loaded
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 心情选择
                  if (_currentEmotion != null) ...[
                    Text(
                      '你最近的记录显示你感到「$_currentEmotion」',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const Text(
                    '也可以选择你此刻的心情：',
                    style: TextStyle(fontSize: 14, color: MirrorColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  _buildEmotionSelector(isDark),
                  const SizedBox(height: 28),

                  // 建议卡片
                  if (_advices.isNotEmpty) _buildAdviceCards(isDark),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildEmotionSelector(bool isDark) {
    final emotions = ['焦虑', '难过', '生气', '疲惫', '开心', '平静', '兴奋', '感恩'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: emotions.map((emotion) {
        final isSelected = _currentEmotion == emotion;
        final color = MirrorColors.emotionColor(emotion);
        return GestureDetector(
          onTap: () => _selectEmotion(emotion),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.3) : (isDark ? MirrorColors.darkSurface : MirrorColors.cardBackground),
              borderRadius: BorderRadius.circular(20),
              border: isSelected ? Border.all(color: color, width: 1.5) : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(EmotionType.fromLabel(emotion).emoji),
                const SizedBox(width: 4),
                Text(
                  emotion,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? color : (isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAdviceCards(bool isDark) {
    final icons = [Icons.looks_one, Icons.looks_two, Icons.looks_3];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.healing, color: MirrorColors.accentDark, size: 20),
            SizedBox(width: 6),
            Text(
              '试试这些方法',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(_advices.length, (index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: MirrorColors.accent.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icons[index], size: 18, color: MirrorColors.accentDark),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      _advices[index],
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),

        // 深呼吸快捷入口
        Card(
          color: MirrorColors.secondaryLight.withValues(alpha: 0.2),
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, '/breathing'),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: MirrorColors.secondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.air, color: MirrorColors.secondaryDark),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '需要冷静一下？',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '试试 4-7-8 呼吸练习',
                          style: TextStyle(fontSize: 13, color: MirrorColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: MirrorColors.textSecondary),
                ],
              ),
            ),
          ),
        ),
        // 专业援助热线
        const SizedBox(height: 24),
        _buildHotlineSection(isDark),
      ],
    );
  }

  Widget _buildHotlineSection(bool isDark) {
    final hotlines = [
      const _Hotline('全国心理援助热线', '12320-5'),
      const _Hotline('希望24热线', '400-161-9995'),
      const _Hotline('北京心理危机研究与干预中心', '010-82951332'),
      const _Hotline('生命热线', '400-821-1215'),
      const _Hotline('青少年心理援助热线', '12355'),
    ];

    Future<void> dial(String number) async {
      final uri = Uri(scheme: 'tel', path: number);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.support, color: MirrorColors.warning, size: 20),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '如果你正在经历困难时刻，请知道——求助是勇敢的表现',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: MirrorColors.warning),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...hotlines.map((h) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      h.name,
                      style: TextStyle(fontSize: 14, color: isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary),
                    ),
                  ),
                  Text(
                    h.number,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: MirrorColors.primaryDark),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.phone, size: 18, color: MirrorColors.primary),
                    onPressed: () => dial(h.number),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 12),
            Text(
              '以上热线均为免费、保密的专业服务',
              style: TextStyle(fontSize: 11, color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Hotline {
  final String name;
  final String number;
  const _Hotline(this.name, this.number);
}
