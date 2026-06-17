import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';

class BlessingCard {
  BlessingCard._();
  static const String _kD = 'blessing_last_date';
  static const String _kI = 'blessing_last_index';

  static final List<String> _blessings = [
    '今天也是被宇宙偏爱的一天 ✨',
    '你的存在就是这世界最美好的事 🌸',
    '慢慢来，一切都会准时到达 🍃',
    '你比自己想象的更加勇敢 💪',
    '每一个今天都是崭新的礼物 🎁',
    '温柔地对待自己，世界也会温柔待你 🌙',
    '你值得被爱，值得拥有所有的美好 💖',
    '深呼吸，你此刻就已经足够好了 🧘',
    '活得简单一些，快乐就会多一些 ☀️',
    '你内心有光，不必借光也能照亮前方 🕯️',
    '允许自己放慢脚步，休息也是前进 🛌',
    '保持善良，好运自会与你相遇 🍀',
    '你的微笑，是世界上最美的风景 😊',
  ];

  static Future<void> checkAndShow(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    // if (prefs.getString(_kD) == today) return;  // 每次打开都弹
    final lastIdx = prefs.getInt(_kI) ?? -1;
    var idx = Random().nextInt(_blessings.length);
    while (idx == lastIdx && _blessings.length > 1) {
      idx = Random().nextInt(_blessings.length);
    }
    await prefs.setString(_kD, today);
    await prefs.setInt(_kI, idx);
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => _BlessingCardContent(blessing: _blessings[idx]),
    );
  }
}

class _BlessingCardContent extends StatelessWidget {
  final String blessing;
  const _BlessingCardContent({required this.blessing});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.shortestSide * 0.78;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all((MediaQuery.of(context).size.shortestSide - size) / 2),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        builder: (ctx, val, _) {
          return Opacity(
            opacity: val,
            child: Transform.scale(
              scale: 0.8 + val * 0.2,
              child: _buildCard(context, size),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, double size) {
    final emojis = ['✨', '🌟', '🌸', '🍀', '💫', '🌙', '☀️', '🌈', '🦋', '💖'];
    final emoji = emojis[DateTime.now().millisecondsSinceEpoch ~/ 1000 % emojis.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4C5E2), Color(0xFFFBEAE3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0x60D4C5E2), blurRadius: 30, offset: const Offset(0, 10)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 24),
            Text(
              blessing,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF3D2C3D), height: 1.6),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('开启心镜', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF6B4E71))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
