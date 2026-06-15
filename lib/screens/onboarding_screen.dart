import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      title: '记录你的每一天',
      subtitle: '文字或语音记录情绪，AI帮你读懂内心',
      icon: Icons.auto_awesome,
      color: MirrorColors.primary,
      description: '每天花5分钟，选择你的心情，用文字或语音记录当下的感受。AI会温和地回应你，帮你发现情绪背后的故事。',
    ),
    _OnboardingPage(
      title: '学会与情绪相处',
      subtitle: '呼吸练习、冥想、认知卡片、感恩日记——8种自愈工具箱',
      icon: Icons.psychology,
      color: MirrorColors.secondary,
      description: '当情绪来临时，不必逃避。从4-7-8呼吸法到正念冥想，从认知重构卡片到感恩练习，找到属于你的自愈方式。',
    ),
    _OnboardingPage(
      title: '见证自己的成长',
      subtitle: '情绪日历、周报、趋势曲线、成就徽章——可视化你的情绪旅程',
      icon: Icons.trending_up,
      color: MirrorColors.accentDark,
      description: '回头看时你会发现，每一次记录都在编织一张名为"自我认知"的网。月视图日历、AI周报、趋势曲线和连续成就，让成长看得见。',
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? MirrorColors.darkBackground : MirrorColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 跳过按钮（非末页时显示）
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, top: 8),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    _currentPage < _pages.length - 1 ? '跳过' : '',
                    style: TextStyle(color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary),
                  ),
                ),
              ),
            ),

            // 卡片区域
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) => _buildPage(index, isDark),
              ),
            ),

            // 底部指示器 + 按钮
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                children: [
                  // 圆点指示器
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? _pages[index].color
                              : (isDark ? Colors.white24 : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // 按钮
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _completeOnboarding();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentPage].color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      child: Text(
                        _currentPage < _pages.length - 1 ? '下一步' : '开始',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(int index, bool isDark) {
    final page = _pages[index];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(page.icon, size: 56, color: page.color),
          ),
          const SizedBox(height: 40),

          // 标题
          Text(
            page.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // 副标题
          Text(
            page.subtitle,
            style: TextStyle(
              fontSize: 15,
              color: page.color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // 描述
          Text(
            page.description,
            style: TextStyle(
              fontSize: 14,
              height: 1.7,
              color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String description;

  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.description,
  });
}
