import 'package:flutter/material.dart';
import '../constants/colors.dart';

class ToolboxScreen extends StatelessWidget {
  const ToolboxScreen({super.key});

  static const _tools = [
    _ToolItem(Icons.air, '呼吸练习', '用呼吸找回平静，每次只需1分钟', MirrorColors.secondary, '/breathing'),
    _ToolItem(Icons.auto_stories, '认知重构卡片', '20张心理学卡片，换个角度看问题', MirrorColors.primary, '/cards'),
    _ToolItem(Icons.favorite_border, '感恩三件事', '每天记录三件值得感恩的事', MirrorColors.accent, '/gratitude'),
    _ToolItem(Icons.healing, '情绪急救包', '根据当前心情，即时获取应对建议', MirrorColors.warm, '/emergency'),
    _ToolItem(Icons.self_improvement, '冥想引导', '文字引导 + 计时器，放空心灵', Color(0xFF7B8BA6), '/meditation'),
    _ToolItem(Icons.auto_awesome, '星座运势', '每日星座运势', Color(0xFF9C27B0), '/horoscope'),
    _ToolItem(Icons.dashboard_customize, '心情卡片', '把今天的心情做成一张精美卡片', MirrorColors.primaryDark, '/mood-card'),
    _ToolItem(Icons.menu_book, '情绪词库', '60+精准词汇，提升情绪粒度', Color(0xFF8D6E63), '/emotion-vocabulary'),
    _ToolItem(Icons.bedtime_rounded, '助眠', '放松身心，安然入眠', Color(0xFF5C6BC0), '/sleep'),
    _ToolItem(Icons.track_changes, '7天情绪挑战', '连续7天打卡，培养积极情绪习惯', Color(0xFFD4A017), '/emotion-challenge'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '选择一种方式照顾自己',
              style: TextStyle(fontSize: 15, color: MirrorColors.textSecondary),
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.92,
            ),
            itemCount: _tools.length,
            itemBuilder: (context, index) => _buildGridCard(context, _tools[index]),
          ),
        ),
        _buildDonateCard(context),
        const SizedBox(height: 8),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildGridCard(BuildContext context, _ToolItem tool) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, tool.route),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: tool.color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(tool.icon, color: tool.color, size: 26),
              ),
              const SizedBox(height: 12),
              Text(
                tool.title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                tool.subtitle,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.3,
                  color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuote() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MirrorColors.primaryLight.withValues(alpha: 0.3),
            MirrorColors.accentLight.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Text(
            '"照顾好自己，不是自私，是智慧。"',
            style: TextStyle(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: MirrorColors.primaryDark,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            '—— 心镜',
            style: TextStyle(fontSize: 12, color: MirrorColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

  Widget _buildDonateCard(BuildContext context) {
    return FutureBuilder<bool>(
      future: PurchaseService.hasDonated(),
      builder: (context, snapshot) {
        final donated = snapshot.data ?? false;
        if (donated) return _buildThankYouCard();
        return _buildDonatePrompt(context);
      },
    );
  }

  Widget _buildThankYouCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [MirrorColors.primaryLight, MirrorColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.favorite, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              '"Dreams are the seedlings of realities.\n\u68a6\u60f3\u662f\u73b0\u5b9e\u7684\u8404\u82bd"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                fontStyle: FontStyle.italic,
                color: MirrorColors.primaryDark.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: MirrorColors.warm.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text("\u611f\u8c22\u60a8\u7684\u652f\u6301", style: TextStyle(fontSize: 12, color: MirrorColors.accentDark)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonatePrompt(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/pro'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(width: 48, height: 48,
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [MirrorColors.primaryLight, MirrorColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.favorite, color: Colors.white, size: 24)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("打赏 \u00a568", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: MirrorColors.primaryDark)),
                const SizedBox(height: 2),
                const Text("成为终身免费会员 \u00b7 支持心镜发展", style: TextStyle(fontSize: 12, color: MirrorColors.textSecondary)),
              ])),
              Container(width: 28, height: 28,
                decoration: BoxDecoration(color: MirrorColors.primaryLight.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.chevron_right, color: MirrorColors.primary, size: 18)),
            ],
          ),
        ),
      ),
    );
  }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, "/pro"),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(width: 48, height: 48,
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [MirrorColors.primaryLight, MirrorColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.favorite, color: Colors.white, size: 24)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("打赏 ¥68", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: MirrorColors.primaryDark)),
                const SizedBox(height: 2),
                const Text("成为终身免费会员 · 支持心镜发展", style: TextStyle(fontSize: 12, color: MirrorColors.textSecondary)),
              ])),
              Container(width: 28, height: 28,
                decoration: BoxDecoration(color: MirrorColors.primaryLight.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.chevron_right, color: MirrorColors.primary, size: 18)),
            ],
          ),
        ),
      ),
    );
  }

class _ToolItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String route;

  const _ToolItem(this.icon, this.title, this.subtitle, this.color, this.route);
}
