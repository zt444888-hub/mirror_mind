
import 'package:flutter/material.dart';
import '../services/horoscope_service.dart';
import '../constants/colors.dart';

/// 星座主题色
const Map<String, Color> _signColors = {
  '白羊座': Color(0xFFFF6B6B), '金牛座': Color(0xFF8BC34A), '双子座': Color(0xFFFFD93D),
  '巨蟹座': Color(0xFFB0BEC5), '狮子座': Color(0xFFFF9800), '处女座': Color(0xFFAB47BC),
  '天秤座': Color(0xFF42A5F5), '天蝎座': Color(0xFF7B1FA2), '射手座': Color(0xFFFF7043),
  '摩羯座': Color(0xFF5D4037), '水瓶座': Color(0xFF26C6DA), '双鱼座': Color(0xFF7E57C2),
};

const Map<String, String> _signEmojis = {
  '白羊座': '🐏', '金牛座': '🐂', '双子座': '👯', '巨蟹座': '🦀',
  '狮子座': '🦁', '处女座': '👸', '天秤座': '⚖️', '天蝎座': '🦂',
  '射手座': '🏹', '摩羯座': '🐐', '水瓶座': '🏺', '双鱼座': '🐟',
};

const Map<String, String> _signDates = {
  '白羊座': '3.21-4.19', '金牛座': '4.20-5.20', '双子座': '5.21-6.21',
  '巨蟹座': '6.22-7.22', '狮子座': '7.23-8.22', '处女座': '8.23-9.22',
  '天秤座': '9.23-10.23', '天蝎座': '10.24-11.22', '射手座': '11.23-12.21',
  '摩羯座': '12.22-1.19', '水瓶座': '1.20-2.18', '双鱼座': '2.19-3.20',
};

class HoroscopeScreen extends StatefulWidget {
  const HoroscopeScreen({super.key});
  @override State<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends State<HoroscopeScreen> {
  final _service = HoroscopeService();
  String _selectedSign = '白羊座';
  Horoscope? _horoscope;
  bool _loading = true;


  @override void initState() { super.initState(); _fetch(); }

  Future<void> _fetch() async {
    final h = await _service.getHoroscope(_selectedSign);
    if (mounted) setState(() { _horoscope = h; _loading = false; });
  }

  Color get _themeColor => _signColors[_selectedSign] ?? Colors.purple;

  @override Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF8F6F2);
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('星座运势'),
        backgroundColor: Colors.transparent, elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: Column(children: [
        _buildSignSelector(isDark),
        Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(isDark)),
      ]),
    );
  }

  Widget _buildSignSelector(bool isDark) {
    return Container(
      height: 56,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _service.signs.length,
        itemBuilder: (_, i) {
          final s = _service.signs[i];
          final sel = s == _selectedSign;
          final cl = _signColors[s] ?? Colors.purple;
          return GestureDetector(
            onTap: () async {
              setState(() => _selectedSign = s);
              await _fetch();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: sel ? LinearGradient(colors: [cl, cl.withValues(alpha: 0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
                color: sel ? null : (isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF0EDE8)),
                borderRadius: BorderRadius.circular(20),
                border: sel ? null : Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('${_signEmojis[s] ?? ''}', style: TextStyle(fontSize: sel ? 16 : 14)),
                const SizedBox(width: 4),
                Text(s, style: TextStyle(
                  fontSize: sel ? 14 : 12,
                  fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                  color: sel ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[600]),
                )),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(bool isDark) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.cloud_off, size: 64, color: isDark ? Colors.grey[600] : Colors.grey[300]),
        const SizedBox(height: 16),
        Text('联网获取失败，使用本地数据', style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[500])),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _fetch, child: const Text('重试')),
      ]),
    ));
  }

  Widget _buildContent(bool isDark) {
    final h = _horoscope!;
    final clr = _themeColor;
    final bgGrad = [clr.withValues(alpha: 0.08), clr.withValues(alpha: 0.02)];

    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 32), children: [
      // === 顶部星座卡片 ===
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: bgGrad, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: clr.withValues(alpha: 0.15)),
        ),
        child: Row(children: [
          Column(children: [
            Text('${_signEmojis[_selectedSign] ?? ''}', style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 4),
            Text(_selectedSign, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            Text(_signDates[_selectedSign] ?? '', style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[500])),
          ]),
          const Spacer(),
          SizedBox(width: 100, height: 100, child: Stack(alignment: Alignment.center, children: [
            SizedBox(width: 100, height: 100, child: CircularProgressIndicator(
              value: h.overallScore / 10, strokeWidth: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(clr),
            )),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text('${h.overallScore}', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: clr)),
              Text('分', style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[500])),
            ]),
          ])),
        ]),
      ),
      const SizedBox(height: 16),

      // === 心情 ===
      if (h.mood.isNotEmpty) ...[
        _detailCard('今日心情', h.mood, clr, Icons.tag_faces, isDark),
        const SizedBox(height: 10),
      ],

      // === 总运势 ===
      _detailCard('整体运势', h.overall, clr, Icons.auto_awesome, isDark),
      const SizedBox(height: 10),

      // === 分项运势 ===
      Row(children: [
        Expanded(child: _miniCard('爱情', h.love, Icons.favorite, Colors.pink, isDark)),
        const SizedBox(width: 10),
        Expanded(child: _miniCard('事业', h.career, Icons.work, Colors.blue, isDark)),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _miniCard('财运', h.wealth, Icons.attach_money, Colors.green, isDark)),
        const SizedBox(width: 10),
        Expanded(child: _miniCard('健康', h.health, Icons.favorite_border, Colors.teal, isDark)),
      ]),
      const SizedBox(height: 16),

      // === 幸运信息 ===
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [clr.withValues(alpha: 0.06), clr.withValues(alpha: 0.02)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: clr.withValues(alpha: 0.12)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.star, size: 18, color: clr),
            const SizedBox(width: 6),
            Text('今日幸运', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
          ]),
          const SizedBox(height: 12),
          Wrap(spacing: 16, runSpacing: 10, children: [
            _luckyChip('数字', '${h.luckyNumber}', '🔢', clr),
            _luckyChip('颜色', h.luckyColor, '🎨', clr),
            _luckyChip('时间', h.luckyTime, '⏰', clr),
            _luckyChip('方向', h.luckyDirection, '🧭', clr),
          ]),
        ]),
      ),
    ]);
  }

  Widget _detailCard(String title, String content, Color clr, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: clr.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: clr.withValues(alpha: 0.1)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 36, height: 36,
          decoration: BoxDecoration(color: clr.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: clr),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 4),
          Text(content, style: TextStyle(fontSize: 13, height: 1.5, color: isDark ? Colors.grey[300] : Colors.grey[600])),
        ])),
      ]),
    );
  }

  Widget _miniCard(String title, String content, IconData icon, Color clr, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A3E) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 14, color: clr),
          const SizedBox(width: 4),
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
        ]),
        const SizedBox(height: 6),
        Text(content, style: TextStyle(fontSize: 12, height: 1.4, color: isDark ? Colors.grey[300] : Colors.grey[600])),
      ]),
    );
  }

  Widget _luckyChip(String label, String value, String emoji, Color clr) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text(emoji, style: const TextStyle(fontSize: 14)),
      const SizedBox(width: 4),
      Text('$label: ', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
      Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: clr)),
    ]);
  }
}
