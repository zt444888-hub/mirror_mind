import 'package:flutter/material.dart';
import '../services/horoscope_service.dart';

class HoroscopeScreen extends StatefulWidget {
  const HoroscopeScreen({super.key});
  @override
  State<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends State<HoroscopeScreen> {
  final _service = HoroscopeService();
  String _selectedSign = '白羊座';
  Horoscope? _horoscope;
  final _signEmojis = {
    '白羊座': '🐏', '金牛座': '🐂', '双子座': '👯',
    '巨蟹座': '🦀', '狮子座': '🦁', '处女座': '👸',
    '天秤座': '⚖️', '天蝎座': '🦂', '射手座': '🏹',
    '摩羯座': '🐐', '水瓶座': '🏺', '双鱼座': '🐟',
  };

  @override
  void initState() { super.initState(); _update(); }
  void _update() { setState(() { _horoscope = _service.generateForDate(_selectedSign, DateTime.now()); }); }

  Color _scoreColor(int s) => s >= 8 ? Colors.green : (s >= 5 ? Colors.orange : Colors.red);

  @override
  Widget build(BuildContext context) {
    final h = _horoscope;
    return Scaffold(
      appBar: AppBar(title: const Text('星座运势')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        SizedBox(height: 50, child: ListView.builder(
          scrollDirection: Axis.horizontal, itemCount: _service.signs.length,
          itemBuilder: (_, i) {
            final s = _service.signs[i];
            final sel = s == _selectedSign;
            return GestureDetector(
              onTap: () => setState(() { _selectedSign = s; _update(); }),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? const Color(0xFF6B8CFF) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(s, style: TextStyle(color: sel ? Colors.white : Colors.black87, fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
              ),
            );
          },
        )),
        const SizedBox(height: 24),
        if (h != null) ...[
          Center(child: Column(children: [
            Text(_signEmojis[_selectedSign] ?? '', style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 8),
            Text(h.sign, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(width: 120, height: 120, child: Stack(alignment: Alignment.center, children: [
              SizedBox(width: 120, height: 120, child: CircularProgressIndicator(
                value: h.overallScore / 10, strokeWidth: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(_scoreColor(h.overallScore)),
              )),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('${h.overallScore}', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: _scoreColor(h.overallScore))),
                const Text('分', style: TextStyle(fontSize: 14)),
              ]),
            ])),
          ])),
          const SizedBox(height: 24),
          _card(Icons.favorite, '爱情', h.love, Colors.pink),
          _card(Icons.work, '事业', h.career, Colors.blue),
          _card(Icons.attach_money, '财运', h.wealth, Colors.green),
          _card(Icons.tag_faces, '幸运数字', '${h.luckyNumber}', Colors.amber),
          _card(Icons.palette, '幸运颜色', h.luckyColor, Colors.purple),
          _card(Icons.explore, '幸运方向', h.luckyDirection, Colors.teal),
        ],
      ]),
    );
  }

  Widget _card(IconData ic, String t, String c, Color cl) {
    return Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(
      leading: CircleAvatar(backgroundColor: cl.withValues(alpha: 0.1), child: Icon(ic, color: cl)),
      title: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(c),
    ));
  }
}
