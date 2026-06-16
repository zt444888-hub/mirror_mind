import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/purchase_service.dart';
class _ToolItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String route;
  const _ToolItem(this.icon, this.title, this.subtitle, this.color, this.route);
}
class ToolboxScreen extends StatefulWidget {
  const ToolboxScreen({super.key});
  static final _tools = [
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
    _ToolItem(Icons.favorite, '支持心镜', '打赏 \u00a568 支持开发', MirrorColors.primary, '/donate'),
    _ToolItem(Icons.feedback, "意见反馈", "联系我们", Color(0xFF9C27B0), "/feedback"),
  ];
  @override
  State<ToolboxScreen> createState() => _ToolboxScreenState();
}
class _ToolboxScreenState extends State<ToolboxScreen> {
  bool _isDonated = false;
  String _donationNumber = "";
  @override
  void initState() {
    super.initState();
    _loadDonation();
  }
  Future<void> _loadDonation() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) setState(() {
      _isDonated = p.getBool("has_donated") ?? false;
      _donationNumber = p.getString("donation_number") ?? "";
    });
  }
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
            itemCount: ToolboxScreen._tools.length,
            itemBuilder: (context, index) => _buildGridCard(context, ToolboxScreen._tools[index]),
          ),
        ),
      ],
    );
  }
  Widget _buildGridCard(BuildContext context, _ToolItem tool) {
        if (tool.route == "/feedback") {
      return Card(
        child: InkWell(
          onTap: () => _showFeedbackDialog(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.feedback, size: 28, color: Color(0xFF9C27B0)),
                const SizedBox(height: 6),
                const Text("意见反馈", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center, maxLines: 1),
                const SizedBox(height: 2),
                const Text("联系我们", style: TextStyle(fontSize: 9, color: MirrorColors.textHint), textAlign: TextAlign.center, maxLines: 1),
              ],
            ),
          ),
        ),
      );
    }
    if (tool.route == '/donate') {
      return Card(
        child: InkWell(
          onTap: _isDonated ? () => _showAppreciationDialog(context) : () => _handleDonateTap(context),
          borderRadius: BorderRadius.circular(12),
          child: _buildDonateMiniCard(),
        ),
      );
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, tool.route),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(tool.icon, size: 28, color: tool.color),
              const SizedBox(height: 6),
              Text(tool.title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(tool.subtitle, style: const TextStyle(fontSize: 9, color: MirrorColors.textHint), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildDonateMiniCard() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [MirrorColors.primaryLight, MirrorColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 6),
          const Text('支持心镜', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: MirrorColors.primaryDark), textAlign: TextAlign.center, maxLines: 1),
          const SizedBox(height: 2),
          const Text('\u00a568', style: TextStyle(fontSize: 9, color: MirrorColors.primary), textAlign: TextAlign.center),
        ],
      ),
    );
  }
  Widget _buildDonatedMiniCard() {
    final number = PurchaseService().donationNumber;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [MirrorColors.primaryLight, MirrorColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36, height: 36,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x40FFFFFF)),
            child: const Icon(Icons.favorite, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 6),
          const Text('已支持', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white), textAlign: TextAlign.center),
          Text('#$number', style: const TextStyle(fontSize: 8, color: Color(0xD9FFFFFF)), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
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
            Color(0x80D4C5E2),
            Color(0x80FBEAE3),
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
  Future<void> _handleDonateTap(BuildContext context) async {
    final paid = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [MirrorColors.primaryLight, MirrorColors.primary], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 72, height: 72, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x40FFFFFF)), child: const Icon(Icons.favorite, size: 36, color: Colors.white)),
            const SizedBox(height: 20),
            const Text('支持心镜', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 2)),
            const SizedBox(height: 8),
            const Text('支持心镜即可成为\n永久终身会员', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Color(0xE6FFFFFF), height: 1.6)),
            const SizedBox(height: 28),
            SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: MirrorColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Text('\u00a568 成为永久会员', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            )),
            const SizedBox(height: 10),
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('暂不考虑', style: TextStyle(fontSize: 13, color: Color(0xB3FFFFFF)))),
          ]),
        ),
      ),
    );
    if (paid != true || !context.mounted) return;

    // On real device: starts IAP payment sheet. On simulator: immediate success.
    final errorMsg = await PurchaseService().buyPro();

    if (errorMsg != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: MirrorColors.warm));
      return;
    }

    // Wait for payment confirmation (simulator: already done, real device: via callback)
    if (!PurchaseService().donated) {
      for (int i = 0; i < 120; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (_isDonated || PurchaseService().donated) break;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    if (!_isDonated && PurchaseService().donated) {
      _donationNumber = PurchaseService().donationNumber;
    }
    if (_donationNumber.isEmpty) {
      final counter = (prefs.getInt('donation_counter') ?? 0) + 1;
      _donationNumber = counter.toString().padLeft(6, '0');
    }
    _isDonated = true;
    await prefs.setBool('has_donated', true);
    await prefs.setString('donation_number', _donationNumber);
    if (_donationNumber.isNotEmpty) {
      await prefs.setInt('donation_counter', int.parse(_donationNumber));
    }
    if (context.mounted) {
      setState(() {});
      _showAppreciationDialog(context);
    }
  }
  void _showAppreciationDialog(BuildContext context) {
    showDialog(context: context, barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [MirrorColors.primaryLight, MirrorColors.primary], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 72, height: 72,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x40FFFFFF)),
              child: const Icon(Icons.favorite, size: 36, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text('心镜 MirrorMind', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 2)),
            const SizedBox(height: 16),
            const Text('Appreciation enriches our own mind.\n欣赏他人，丰盈自己', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Color(0xE6FFFFFF), height: 1.6)),
            const SizedBox(height: 24),
            Text('唯一 #$_donationNumber', style: const TextStyle(fontSize: 13, color: Color(0xD9FFFFFF), letterSpacing: 2)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: MirrorColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14)),
              child: const Text('感谢你的支持 \u2764\ufe0f'),
            ),
          ]),
        ),
      ),
    );
  }
  void _showDonatedDialog(BuildContext context) {
    showDialog(context: context, barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [MirrorColors.primaryLight, MirrorColors.primary], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 72, height: 72,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x40FFFFFF)),
              child: const Icon(Icons.favorite, size: 36, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text('心镜 MirrorMind', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 2)),
            const SizedBox(height: 16),
            const Text('Appreciation enriches our own mind.\n欣赏他人，丰盈自己', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Color(0xE6FFFFFF), height: 1.6)),
            const SizedBox(height: 24),
            Text('唯一 #$_donationNumber', style: const TextStyle(fontSize: 13, color: Color(0xD9FFFFFF), letterSpacing: 2)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: MirrorColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14)),
              child: const Text('\u2764\ufe0f'),
            ),
          ]),
        ),
      ),
    );
  }
}
void _showFeedbackDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 64, height: 64,
              decoration: const BoxDecoration(color: Color(0xFFF3E5F5), shape: BoxShape.circle),
              child: const Icon(Icons.feedback, size: 32, color: Color(0xFF9C27B0)),
            ),
            const SizedBox(height: 16),
            const Text("意见反馈", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            _buildContactRow(Icons.email_outlined, "邮箱", "934491877@qq.com"),
            const SizedBox(height: 12),
            _buildContactRow(Icons.chat_outlined, "微信", "Leo--44"),
            const SizedBox(height: 24),
            const Text(
              "欢迎随时联系我们，您的每一条建议都将让心镜变得更好",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: MirrorColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: MirrorColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text("知道了"),
            )),
          ],
        ),
      ),
    ),
  );
}
Widget _buildContactRow(IconData icon, String label, String value) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: MirrorColors.background, borderRadius: BorderRadius.circular(12)),
    child: Row(
      children: [
        Icon(icon, size: 22, color: MirrorColors.primary),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 14, color: MirrorColors.textSecondary)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: MirrorColors.primaryDark)),
      ],
    ),
  );
}
