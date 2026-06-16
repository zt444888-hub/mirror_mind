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
    '浠婂ぉ涔熸槸缇庡ソ鐨勪竴澶?馃尭',
    '浣犳瘮浣犳兂璞＄殑鏇村潥寮?馃挭',
    '鏀炬參鑴氭锛屾劅鍙楀綋涓?馃崈',
    '姣忎竴涓灛闂撮兘鍊煎緱琚湅瑙?鉁?,
    '浣犵殑鎰熷彈寰堥噸瑕?馃挋',
    '娓╂煍鍦板寰呰嚜宸?馃尶',
    '姝ゅ埢锛屽氨鏄渶濂界殑绀肩墿 馃巵',
    '涓栫晫鍦ㄦ倓鎮勭埍浣?馃挍',
    '涓€鍒囬兘浼氬ソ璧锋潵鐨?馃寛',
    '浣犲€煎緱琚俯鏌斾互寰?馃晩锔?,
    '娣卞懠鍚革紝鐢熸椿杩樺湪缁х画 馃寠',
    '浠婂ぉ涔熻濂藉ソ鐖辫嚜宸?鉂わ笍',
    '璁╁績瀹変綇鍦ㄦ鍒?鈽侊笍',
    '浣犲仛鐨勫凡缁忚冻澶熷ソ浜?馃専',
    '缁欒嚜宸辩殑蹇冧竴涓姳鎶?馃',
  ];

  late String _todayQuote;

  @override
  void initState() {
    super.initState();

    // 姣忓ぉ涓嶅悓锛屼絾鍚屼竴澶╃浉鍚?
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
                  // Logo 鍥炬爣
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
                    '蹇冮暅',
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
                        color: Color(0xE6FFFFFF),
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

