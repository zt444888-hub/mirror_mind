import 'package:flutter/material.dart';
class BreathingBall extends StatelessWidget {
  final double scale; final Color color;
  const BreathingBall({super.key, required this.scale, required this.color});
  @override Widget build(BuildContext context) {
    return Center(child: CustomPaint(size: Size(180 * scale, 180 * scale),
      painter: _BreathingBallPainter(color: color, lastScale: scale))); } }
class _BreathingBallPainter extends CustomPainter {
  final Color color; final double lastScale;
  _BreathingBallPainter({required this.color, required this.lastScale});
  @override void paint(Canvas canvas, Size size) {
    final c=Offset(size.width/2,size.height/2); final r=size.width/2-4;
    final g=Paint()..shader=RadialGradient(colors:[color.withValues(alpha:.3),color.withValues(alpha:.05)]).createShader(Rect.fromCircle(center:c,radius:r));
    canvas.drawCircle(c,r+12,g);
    final b=Paint()..shader=RadialGradient(colors:[color.withValues(alpha:.6),color.withValues(alpha:.9)],stops:[.3,1.0]).createShader(Rect.fromCircle(center:c,radius:r));
    canvas.drawCircle(c,r,b);
    final h=Paint()..shader=RadialGradient(colors:[Colors.white.withValues(alpha:.4),Colors.white.withValues(alpha:.0)],stops:[0,.4]).createShader(Rect.fromCircle(center:Offset(c.dx-r*.25,c.dy-r*.25),radius:r*.5));
    canvas.drawCircle(Offset(c.dx-r*.25,c.dy-r*.25),r*.5,h); }
  @override bool shouldRepaint(covariant _BreathingBallPainter o) => o.color!=color||o.lastScale!=lastScale; }
