import re

with open('lib/screens/calendar_screen.dart', 'r') as f:
    c = f.read()

# ============ 添加情绪人格标签函数 ============
old = "  Widget _buildMonthView(bool isDark) {"
new = """  /// 根据本月主要情绪生成人格标签
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

  Widget _buildMonthView(bool isDark) {"""
c = c.replace(old, new)

# ============ 在日历顶部添加人格标签和热力图说明 ============
old_mid = "          _buildMonthNav(isDark),"
new_mid = """          _buildMonthNav(isDark),
          if (provider.monthRecords.isNotEmpty)
            _buildMoodPersonalityBadge(isDark, provider.monthRecords),"""

c = c.replace(old_mid, new_mid)

# ============ 在每周统计下面添加月度总结 ============
old_bottom = """            ),
        ],
      ),
    );
  }

  Widget _buildTrendView(bool isDark) {"""
new_bottom = """            ),
          if (monthRecords.isNotEmpty)
            _buildMonthSummary(isDark, monthRecords),
        ],
      ),
    );
  }

  Widget _buildTrendView(bool isDark) {"""
c = c.replace(old_bottom, new_bottom)

# ============ 添加人格标签构建方法 ============
old_end = "  Widget _buildTrendView(bool isDark) {"
new_persona = """  /// 本月情绪人格标签
  Widget _buildMoodPersonalityBadge(bool isDark, List<EmotionRecord> records) {
    final label = _getMoodPersonality(records);
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [MirrorColors.primaryLight.withValues(alpha: 0.3), MirrorColors.secondaryLight.withValues(alpha: 0.2)],
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

  Widget _buildTrendView(bool isDark) {"""
c = c.replace(old_end, new_persona)

with open('lib/screens/calendar_screen.dart', 'w') as f:
    f.write(c)
print('Done')
