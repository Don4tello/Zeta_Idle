import 'dart:math';
import 'package:flutter/material.dart';

class SnakeLoader extends StatefulWidget {
  const SnakeLoader({super.key, this.size = 48, this.color = const Color(0xFF44cc88)});
  final double size;
  final Color color;

  @override
  State<SnakeLoader> createState() => _SnakeLoaderState();
}

class _SnakeLoaderState extends State<SnakeLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
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
          painter: _SnakePainter(_ctrl.value, widget.color),
        ),
      ),
    );
  }
}

class _SnakePainter extends CustomPainter {
  _SnakePainter(this.t, this.color);
  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.38;

    // Snake body: 8 segments trailing behind the head
    const segments = 8;
    const segmentArc = 0.12;
    final headAngle = t * 2 * pi;

    for (int i = 0; i < segments; i++) {
      final angle = headAngle - i * segmentArc;
      final x = cx + r * cos(angle);
      final y = cy + r * sin(angle);
      final segSize = (segments - i) / segments;
      final alpha = segSize.clamp(0.2, 1.0);

      final paint = Paint()
        ..color = color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 2.5 * segSize + 1, paint);
    }

    // Head: slightly larger with eyes
    final hx = cx + r * cos(headAngle);
    final hy = cy + r * sin(headAngle);
    canvas.drawCircle(Offset(hx, hy), 4.5, Paint()..color = color);

    // Eyes
    final eyeAngle = headAngle + 0.3;
    final eyeAngle2 = headAngle - 0.3;
    final eyeR = r * 0.85;
    canvas.drawCircle(
      Offset(cx + eyeR * cos(eyeAngle), cy + eyeR * sin(eyeAngle)),
      1.2, Paint()..color = Colors.black);
    canvas.drawCircle(
      Offset(cx + eyeR * cos(eyeAngle2), cy + eyeR * sin(eyeAngle2)),
      1.2, Paint()..color = Colors.black);

    // Tongue flick
    final tonguePhase = (t * 4) % 1.0;
    if (tonguePhase < 0.3) {
      final tongueLen = 4 + tonguePhase * 10;
      final tx = hx + tongueLen * cos(headAngle);
      final ty = hy + tongueLen * sin(headAngle);
      canvas.drawLine(
        Offset(hx, hy), Offset(tx, ty),
        Paint()..color = const Color(0xFFcc2222)..strokeWidth = 1,
      );
      // Forked tip
      canvas.drawLine(
        Offset(tx, ty), Offset(tx + 3 * cos(headAngle + 0.4), ty + 3 * sin(headAngle + 0.4)),
        Paint()..color = const Color(0xFFcc2222)..strokeWidth = 0.8,
      );
      canvas.drawLine(
        Offset(tx, ty), Offset(tx + 3 * cos(headAngle - 0.4), ty + 3 * sin(headAngle - 0.4)),
        Paint()..color = const Color(0xFFcc2222)..strokeWidth = 0.8,
      );
    }
  }

  @override
  bool shouldRepaint(_SnakePainter old) => true;
}
