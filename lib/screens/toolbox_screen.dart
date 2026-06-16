import 'package:flutter/material.dart';
import '../constants/colors.dart';

class ToolboxScreen extends StatelessWidget {
  const ToolboxScreen({super.key});

  static const _tools = [
    _ToolItem(Icons.air, '鍛煎惛缁冧範', '鐢ㄥ懠鍚告壘鍥炲钩闈欙紝姣忔鍙渶1鍒嗛挓', MirrorColors.secondary, '/breathing'),
    _ToolItem(Icons.auto_stories, '璁ょ煡閲嶆瀯鍗＄墖', '20寮犲績鐞嗗鍗＄墖锛屾崲涓搴︾湅闂', MirrorColors.primary, '/cards'),
    _ToolItem(Icons.favorite_border, '鎰熸仼涓変欢浜?, '姣忓ぉ璁板綍涓変欢鍊煎緱鎰熸仼鐨勪簨', MirrorColors.accent, '/gratitude'),
    _ToolItem(Icons.healing, '鎯呯华鎬ユ晳鍖?, '鏍规嵁褰撳墠蹇冩儏锛屽嵆鏃惰幏鍙栧簲瀵瑰缓璁?, MirrorColors.warm, '/emergency'),
    _ToolItem(Icons.self_improvement, '鍐ユ兂寮曞', '鏂囧瓧寮曞 + 璁℃椂鍣紝鏀剧┖蹇冪伒', Color(0xFF7B8BA6), '/meditation'),
    _ToolItem(Icons.auto_awesome, '鏄熷骇杩愬娍', '姣忔棩鏄熷骇杩愬娍', Color(0xFF9C27B0), '/horoscope'),
    _ToolItem(Icons.dashboard_customize, '蹇冩儏鍗＄墖', '鎶婁粖澶╃殑蹇冩儏鍋氭垚涓€寮犵簿缇庡崱鐗?, MirrorColors.primaryDark, '/mood-card'),
    _ToolItem(Icons.menu_book, '鎯呯华璇嶅簱', '60+绮惧噯璇嶆眹锛屾彁鍗囨儏缁矑搴?, Color(0xFF8D6E63), '/emotion-vocabulary'),
    _ToolItem(Icons.bedtime_rounded, '鍔╃湢', '鏀炬澗韬績锛屽畨鐒跺叆鐪?, Color(0xFF5C6BC0), '/sleep'),
    _ToolItem(Icons.track_changes, '7澶╂儏缁寫鎴?, '杩炵画7澶╂墦鍗★紝鍩瑰吇绉瀬鎯呯华涔犳儻', Color(0xFFD4A017), '/emotion-challenge'),
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
              '閫夋嫨涓€绉嶆柟寮忕収椤捐嚜宸?,
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
            '"鐓ч【濂借嚜宸憋紝涓嶆槸鑷锛屾槸鏅烘収銆?',
            style: TextStyle(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: MirrorColors.primaryDark,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            '鈥斺€?蹇冮暅',
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
      builder: (_, snap) {
        if (snap.data == true) return _thankCard();
        return _donateCard(context);
      },
    );
  }

  Widget _thankCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(width: 56,height: 56,decoration: BoxDecoration(gradient: const LinearGradient(colors: [MirrorColors.primaryLight,MirrorColors.primary],begin: Alignment.topLeft,end: Alignment.bottomRight),borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.favorite,color: Colors.white,size: 28)),
            const SizedBox(height: 12),
            const Text('"Dreams are the seedlings of realities."',textAlign: TextAlign.center,style: TextStyle(fontSize: 14,fontStyle: FontStyle.italic,height: 1.5,color: MirrorColors.primaryDark)),
            const SizedBox(height: 4),
            const Text('姊︽兂鏄幇瀹炵殑钀岃娊',textAlign: TextAlign.center,style: TextStyle(fontSize: 14,height: 1.5,color: MirrorColors.primaryDark)),
            const SizedBox(height: 12),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 3),decoration: BoxDecoration(color: MirrorColors.warm.withValues(alpha: 0.2),borderRadius: BorderRadius.circular(10)),
              child: const Text('鎰熻阿鎮ㄧ殑鏀寔',style: TextStyle(fontSize: 11,color: MirrorColors.accentDark))),
          ],
        ),
      ),
    );
  }

  Widget _donateCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/pro'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(width: 48,height: 48,decoration: BoxDecoration(gradient: const LinearGradient(colors: [MirrorColors.primaryLight,MirrorColors.primary],begin: Alignment.topLeft,end: Alignment.bottomRight),borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.favorite,color: Colors.white,size: 24)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                const Text('鎵撹祻 楼68',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700,color: MirrorColors.primaryDark)),
                const SizedBox(height: 2),
                const Text('鎴愪负缁堣韩鍏嶈垂浼氬憳 路 鏀寔蹇冮暅鍙戝睍',style: TextStyle(fontSize: 12,color: MirrorColors.textSecondary)),
              ])),
              Container(width: 28,height: 28,decoration: BoxDecoration(color: Color(0x80D4C5E2),borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.chevron_right,color: MirrorColors.primary,size: 18)),
            ],
          ),
        ),
      ),
    );
  }
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
                const Text("鎵撹祻 \u00a568", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: MirrorColors.primaryDark)),
                const SizedBox(height: 2),
                const Text("鎴愪负缁堣韩鍏嶈垂浼氬憳 \u00b7 鏀寔蹇冮暅鍙戝睍", style: TextStyle(fontSize: 12, color: MirrorColors.textSecondary)),
              ])),
              Container(width: 28, height: 28,
                decoration: BoxDecoration(color: Color(0x80D4C5E2), borderRadius: BorderRadius.circular(10)),
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
                const Text("鎵撹祻 楼68", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: MirrorColors.primaryDark)),
                const SizedBox(height: 2),
                const Text("鎴愪负缁堣韩鍏嶈垂浼氬憳 路 鏀寔蹇冮暅鍙戝睍", style: TextStyle(fontSize: 12, color: MirrorColors.textSecondary)),
              ])),
              Container(width: 28, height: 28,
                decoration: BoxDecoration(color: Color(0x80D4C5E2), borderRadius: BorderRadius.circular(10)),
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

