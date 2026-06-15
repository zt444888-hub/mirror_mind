import 'dart:math';
import 'package:flutter/material.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  final _quotes = [
    '今天也是美好的一天 🌸',
    '你比你想象的更坚强 💪',
    '放慢脚步，感受当下 🍃',
    '每一个瞬间都值得被看见 ✨',
    '你的感受很重要 💙',
    '温柔地对待自己 🌿',
    '此刻，就是最好的礼物 🎁',
    '世界在悄悄爱你 💛',
    '一切都会好起来的 🌈',
    '你值得被温柔以待 🕊️',
    '深呼吸，生活还在继续 🌊',
    '今天也要好好爱自己 ❤️',
    '让心安住在此刻 ☁️',
    '你做的已经足够好了 🌟',
    '给自己的心一个抱抱 🤗',
  ];

  late String _todayQuote;

  @override
  void initState() {
    super.initState();

    // 每天不同，但同一天相同
    final seed = DateTime.now().year * 10000 +
        DateTime.now().month * 100 +
        DateTime.now().day;
    _todayQuote = _quotes[Random(seed).nextInt(_quotes.length)];

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _animController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6B8CFF),
              Color(0xFF8B6FFF),
              Color(0xFFA78BFF),
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo 图标
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.self_improvement,
                      size: 56,
                      color: Color(0xFF6B8CFF),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '心镜',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      _todayQuote,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
