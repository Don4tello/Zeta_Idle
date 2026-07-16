import 'dart:math';
import 'package:flutter/material.dart';

/// Animated gold coin with a "Z" embossed on it — the visual for the
/// premium currency (ZCoins, formerly "Crystals").
class ZCoinIcon extends StatefulWidget {
  const ZCoinIcon({super.key, this.size = 16, this.animate = true});
  final double size;
  final bool animate;

  @override
  State<ZCoinIcon> createState() => _ZCoinIconState();
}

class _ZCoinIconState extends State<ZCoinIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    if (widget.animate) _ctrl.repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _ZCoinPainter(t: _ctrl.value),
        ),
      ),
    );
  }
}

class _ZCoinPainter extends CustomPainter {
  _ZCoinPainter({required this.t});
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // "Coin flip" squash on the horizontal axis — simulates a spin.
    final spin = (sin(t * 2 * pi)).abs();
    final scaleX = 0.55 + spin * 0.45;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scaleX, 1.0);
    canvas.translate(-center.dx, -center.dy);

    // Base coin body
    final bodyPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFE375), Color(0xFFE8A832), Color(0xFFB8761A)],
        stops: [0.0, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawCircle(center, r, bodyPaint);

    // Rim
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.16
      ..color = const Color(0xFF8C5A12);
    canvas.drawCircle(center, r - rimPaint.strokeWidth / 2, rimPaint);

    // Inner ring
    final innerRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.06
      ..color = const Color(0xFFFFF3C4).withValues(alpha: 0.8);
    canvas.drawCircle(center, r * 0.72, innerRingPaint);

    // "Z" glyph
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Z',
        style: TextStyle(
          fontSize: r * 1.15,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF7A4A0E),
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );

    // Shimmer sweep
    final shimmerX = -r + (t * 2 * r * 2.4) % (r * 3.4);
    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.55),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(center.dx + shimmerX - r * 0.4, 0, r * 0.8, size.height));
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: r)));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), shimmerPaint);
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ZCoinPainter oldDelegate) => oldDelegate.t != t;
}
