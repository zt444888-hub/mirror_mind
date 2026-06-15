import 'package:flutter/material.dart';
import '../constants/colors.dart';

class MoodSlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const MoodSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTapDown: (details) => _updateValue(details.localPosition.dx, context),
          onHorizontalDragStart: (details) => _updateValue(details.localPosition.dx, context),
          onHorizontalDragUpdate: (details) => _updateValue(details.localPosition.dx, context),
          child: SizedBox(
            height: 80,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                return CustomPaint(
                  size: Size(totalWidth, 80),
                  painter: _MoodSliderPainter(value: value),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
        // 底部刻度
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('😔', style: TextStyle(fontSize: 16)),
            for (int i = 2; i <= 9; i++)
              Text(
                '$i',
                style: TextStyle(
                  fontSize: 11,
                  color: i == value ? MirrorColors.primaryDark : MirrorColors.textHint,
                  fontWeight: i == value ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            const Text('😊', style: TextStyle(fontSize: 16)),
          ],
        ),
      ],
    );
  }

  void _updateValue(double dx, BuildContext context) {
    final totalWidth = context.findRenderObject() is RenderBox
        ? (context.findRenderObject() as RenderBox).size.width
        : MediaQuery.of(context).size.width - 60;
    const startX = 30.0;
    final endX = totalWidth - 30.0;
    if (endX <= startX) return;
    final step = (endX - startX) / 9;
    final rawValue = ((dx - startX) / step).round() + 1;
    final clamped = rawValue.clamp(1, 10);
    if (clamped != value) {
      onChanged(clamped);
    }
  }
}

class _MoodSliderPainter extends CustomPainter {
  final int value;
  _MoodSliderPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final trackPaint = Paint()
      ..color = MirrorColors.cardBackground
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..shader = const LinearGradient(
        colors: [MirrorColors.secondary, MirrorColors.primary, MirrorColors.accent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final y = size.height / 2;
    const startX = 30.0;
    final endX = size.width - 30.0;

    // 轨道
    canvas.drawLine(Offset(startX, y), Offset(endX, y), trackPaint);

    // 激活轨道
    final step = (endX - startX) / 9;
    final progressX = startX + step * (value - 1);
    canvas.drawLine(Offset(startX, y), Offset(progressX, y), activePaint);

    // 刻度标记
    for (int i = 1; i <= 10; i++) {
      final x = startX + step * (i - 1);
      final isActive = i == value;
      canvas.drawCircle(
        Offset(x, y),
        isActive ? 12 : 6,
        Paint()..color = isActive ? MirrorColors.primary : MirrorColors.textHint.withValues(alpha: 0.5),
      );
      if (isActive) {
        canvas.drawCircle(
          Offset(x, y),
          12,
          Paint()
            ..color = MirrorColors.primary.withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MoodSliderPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
