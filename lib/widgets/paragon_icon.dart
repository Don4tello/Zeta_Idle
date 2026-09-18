import 'dart:math';
import 'package:flutter/material.dart';

/// Per-stat accent colour for the paragon board symbols.
Color paragonColor(String id) => switch (id) {
  'p_might'     => const Color(0xFFff6644),
  'p_vitality'  => const Color(0xFFff5566),
  'p_precision' => const Color(0xFFffcc44),
  'p_ferocity'  => const Color(0xFFff8833),
  'p_fortune'   => const Color(0xFFe8a832),
  'p_wisdom'    => const Color(0xFF88ddff),
  'p_eternal'   => const Color(0xFFb59bff),
  _             => const Color(0xFFb59bff),
};

/// Hand-drawn CustomPainter symbol for each paragon board stat — a distinct
/// little glyph per stat (crossed swords, heart, target, flame, coin, book,
/// star), styled to match the game's [StatIcon] set.
class ParagonIcon extends StatelessWidget {
  const ParagonIcon({super.key, required this.id, this.size = 20, this.color});
  final String id;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _ParagonIconPainter(id, color ?? paragonColor(id))),
      );
}

class _ParagonIconPainter extends CustomPainter {
  const _ParagonIconPainter(this.id, this.color);
  final String id;
  final Color color;

  Paint _fill(Color c) => Paint()..color = c..isAntiAlias = true;
  Paint _stroke(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..isAntiAlias = true;

  @override
  void paint(Canvas cv, Size s) {
    final cx = s.width / 2, cy = s.height / 2;
    switch (id) {
      case 'p_might':     _crossedSwords(cv, cx, cy, s);
      case 'p_vitality':  _heart(cv, cx, cy, s);
      case 'p_precision': _target(cv, cx, cy, s);
      case 'p_ferocity':  _flame(cv, cx, cy, s);
      case 'p_fortune':   _coin(cv, cx, cy, s);
      case 'p_wisdom':    _book(cv, cx, cy, s);
      case 'p_eternal':   _star(cv, cx, cy, s);
      default:            _star(cv, cx, cy, s);
    }
  }

  // ⚔ Might — two blades crossing.
  void _crossedSwords(Canvas cv, double cx, double cy, Size s) {
    final w = s.width, h = s.height;
    final blade = _stroke(Color.lerp(color, Colors.white, 0.28)!, w * 0.11);
    cv.drawLine(Offset(cx - w * 0.24, cy + h * 0.26), Offset(cx + w * 0.24, cy - h * 0.26), blade);
    cv.drawLine(Offset(cx + w * 0.24, cy + h * 0.26), Offset(cx - w * 0.24, cy - h * 0.26), blade);
    // darker hilts at the bottom ends
    final hilt = _stroke(Color.lerp(color, Colors.black, 0.25)!, w * 0.12);
    cv.drawLine(Offset(cx - w * 0.24, cy + h * 0.26), Offset(cx - w * 0.15, cy + h * 0.17), hilt);
    cv.drawLine(Offset(cx + w * 0.24, cy + h * 0.26), Offset(cx + w * 0.15, cy + h * 0.17), hilt);
  }

  // ❤ Vitality — heart.
  void _heart(Canvas cv, double cx, double cy, Size s) {
    final path = Path()
      ..moveTo(cx, cy + s.height * 0.24)
      ..cubicTo(cx - s.width * 0.32, cy, cx - s.width * 0.18, cy - s.height * 0.26, cx, cy - s.height * 0.06)
      ..cubicTo(cx + s.width * 0.18, cy - s.height * 0.26, cx + s.width * 0.32, cy, cx, cy + s.height * 0.24);
    cv.drawPath(path, _fill(color));
    cv.drawCircle(Offset(cx - s.width * 0.08, cy - s.height * 0.04), s.width * 0.045,
        _fill(Colors.white.withValues(alpha: 0.5)));
  }

  // 🎯 Precision — concentric target.
  void _target(Canvas cv, double cx, double cy, Size s) {
    final r = s.width * 0.30;
    cv.drawCircle(Offset(cx, cy), r, _stroke(color, 2.0));
    cv.drawCircle(Offset(cx, cy), r * 0.55, _stroke(color.withValues(alpha: 0.7), 1.6));
    cv.drawCircle(Offset(cx, cy), r * 0.16, _fill(color));
  }

  // 🔥 Ferocity — flame.
  void _flame(Canvas cv, double cx, double cy, Size s) {
    final w = s.width, h = s.height;
    final outer = Path()
      ..moveTo(cx, cy - h * 0.34)
      ..cubicTo(cx + w * 0.30, cy - h * 0.06, cx + w * 0.22, cy + h * 0.30, cx, cy + h * 0.32)
      ..cubicTo(cx - w * 0.22, cy + h * 0.30, cx - w * 0.30, cy - h * 0.02, cx, cy - h * 0.34)
      ..close();
    cv.drawPath(outer, _fill(color));
    final inner = Path()
      ..moveTo(cx, cy - h * 0.06)
      ..cubicTo(cx + w * 0.14, cy + h * 0.08, cx + w * 0.09, cy + h * 0.26, cx, cy + h * 0.28)
      ..cubicTo(cx - w * 0.09, cy + h * 0.26, cx - w * 0.14, cy + h * 0.08, cx, cy - h * 0.06)
      ..close();
    cv.drawPath(inner, _fill(Color.lerp(color, Colors.white, 0.55)!));
  }

  // 💰 Fortune — coin.
  void _coin(Canvas cv, double cx, double cy, Size s) {
    final r = s.width * 0.30;
    cv.drawCircle(Offset(cx, cy), r, _fill(Color.lerp(color, Colors.black, 0.12)!));
    cv.drawCircle(Offset(cx, cy), r * 0.80, _fill(Color.lerp(color, Colors.white, 0.22)!));
    cv.drawCircle(Offset(cx, cy), r * 0.80, _stroke(Color.lerp(color, Colors.black, 0.25)!, 1.3));
    cv.drawCircle(Offset(cx - r * 0.4, cy - r * 0.4), r * 0.12, _fill(Colors.white.withValues(alpha: 0.6)));
  }

  // 📖 Wisdom — open book.
  void _book(Canvas cv, double cx, double cy, Size s) {
    final w = s.width, h = s.height;
    final light = Color.lerp(color, Colors.white, 0.22)!;
    final dark = Color.lerp(color, Colors.black, 0.15)!;
    final lp = Path()
      ..moveTo(cx, cy - h * 0.20)
      ..lineTo(cx - w * 0.30, cy - h * 0.12)
      ..lineTo(cx - w * 0.30, cy + h * 0.22)
      ..lineTo(cx, cy + h * 0.16)
      ..close();
    final rp = Path()
      ..moveTo(cx, cy - h * 0.20)
      ..lineTo(cx + w * 0.30, cy - h * 0.12)
      ..lineTo(cx + w * 0.30, cy + h * 0.22)
      ..lineTo(cx, cy + h * 0.16)
      ..close();
    cv.drawPath(lp, _fill(light));
    cv.drawPath(rp, _fill(dark));
    cv.drawLine(Offset(cx, cy - h * 0.20), Offset(cx, cy + h * 0.16),
        _stroke(Color.lerp(color, Colors.black, 0.3)!, 1.4));
    final line = _stroke(Colors.white.withValues(alpha: 0.5), 1.0);
    cv.drawLine(Offset(cx - w * 0.22, cy - h * 0.02), Offset(cx - w * 0.06, cy - h * 0.05), line);
    cv.drawLine(Offset(cx + w * 0.06, cy - h * 0.05), Offset(cx + w * 0.22, cy - h * 0.02), line);
  }

  // ✦ Eternal — four-point star / sparkle.
  void _star(Canvas cv, double cx, double cy, Size s) {
    final r = s.width * 0.36, ir = r * 0.34;
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final a = -pi / 2 + i * pi / 4;
      final rr = i.isEven ? r : ir;
      final x = cx + rr * cos(a), y = cy + rr * sin(a);
      if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
    }
    path.close();
    cv.drawPath(path, _fill(color));
    cv.drawCircle(Offset(cx, cy), s.width * 0.07, _fill(Color.lerp(color, Colors.white, 0.6)!));
  }

  @override
  bool shouldRepaint(covariant _ParagonIconPainter old) => old.id != id || old.color != color;
}
