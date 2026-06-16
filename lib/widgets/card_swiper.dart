import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/cards.dart';

class CardSwiper extends StatelessWidget {
  final CognitiveCard card;
  final bool isActive;

  const CardSwiper({
    super.key,
    required this.card,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {


    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(isActive ? 0 : 0.05),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _gradientColors(card.category),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _gradientColors(card.category)[0].withValues(alpha: isActive ? 0.25 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 可滚动区域：分类标签 + 标题 + 副标题 + 正文
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 分类标签
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        card.category,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 标题
                    Text(
                      card.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 副标题
                    Text(
                      card.subtitle,
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xE6FFFFFF),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 正文
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        card.content,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            // 底部提示
            Center(
              child: Icon(
                Icons.swipe,
                color: Colors.white.withValues(alpha: 0.4),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _gradientColors(String category) {
    switch (category) {
      case '焦虑应对':
        return [const Color(0xFF7B9CB5), const Color(0xFF5A7D9A)];
      case '自我接纳':
        return [const Color(0xFFC49B8C), const Color(0xFFA87D6E)];
      case '边界感':
        return [const Color(0xFF8B9E8B), const Color(0xFF6D806D)];
      case '完美主义':
        return [const Color(0xFFB5A0C4), const Color(0xFF9782A6)];
      case '情绪接纳':
        return [const Color(0xFFC4A88C), const Color(0xFFA68A6E)];
      case '人际关系':
        return [const Color(0xFF9BADB5), const Color(0xFF7D8F97)];
      case '自我关怀':
        return [const Color(0xFFB59E94), const Color(0xFF978076)];
      case '正念觉察':
        return [const Color(0xFFA0B59E), const Color(0xFF829780)];
      default:
        return [MirrorColors.primary, MirrorColors.primaryDark];
    }
  }
}

