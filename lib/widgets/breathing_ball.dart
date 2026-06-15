import 'package:flutter/material.dart';

class BreathingBall extends StatelessWidget {
  final double scale;
  final Color color;

  const BreathingBall({
    super.key,
    required this.scale,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        size: Size(180 * scale, 180 * scale),
        painter: _BreathingBallPainter(color: color),
      ),
    );
  }
}

class _BreathingBallPainter extends CustomPainter {
  final Color color;

  _BreathingBallPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // 外圈光晕
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.3),
          color.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius + 12, glowPaint);

    // 主体球
    final ballPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.6),
          color.withValues(alpha: 0.9),
        ],
        stops: const [0.3, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, ballPaint);

    // 高光
    final highlightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.4),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.4],
      ).createShader(Rect.fromCircle(center: Offset(center.dx - radius * 0.25, center.dy - radius * 0.25), radius: radius * 0.5));

    canvas.drawCircle(
      Offset(center.dx - radius * 0.25, center.dy - radius * 0.25),
      radius * 0.5,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BreathingBallPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
