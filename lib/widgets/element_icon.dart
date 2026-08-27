import 'dart:math';
import 'package:flutter/material.dart';
import '../models/damage_type.dart';

/// Hand-drawn glyph for each elemental damage type, tinted with the element's
/// colour. Shared by the Elemental Mastery screen and the passive tree.
class ElementIcon extends StatelessWidget {
  const ElementIcon({super.key, required this.type, this.size = 26, this.color});
  final DamageType type;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: ElementIconPainter(type, color ?? type.color)),
      );
}

class ElementIconPainter extends CustomPainter {
  const ElementIconPainter(this.type, this.color);
  final DamageType type;
  final Color color;

  @override
  void paint(Canvas cv, Size s) {
    final cx = s.width / 2, cy = s.height / 2;
    switch (type) {
      case DamageType.physical:  _sword(cv, cx, cy, s);
      case DamageType.fire:      _flame(cv, cx, cy, s);
      case DamageType.cold:      _snowflake(cv, cx, cy, s);
      case DamageType.lightning: _bolt(cv, cx, cy, s);
      case DamageType.poison:    _droplet(cv, cx, cy, s);
      case DamageType.void_:     _voidOrb(cv, cx, cy, s);
    }
  }

  Paint _fill(Color c) => Paint()..color = c..isAntiAlias = true;
  Paint _stroke(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..isAntiAlias = true;

  void _sword(Canvas cv, double cx, double cy, Size s) {
    final blade = Path()
      ..moveTo(cx, cy - s.height * 0.32)
      ..lineTo(cx + s.width * 0.08, cy - s.height * 0.16)
      ..lineTo(cx + s.width * 0.05, cy + s.height * 0.14)
      ..lineTo(cx - s.width * 0.05, cy + s.height * 0.14)
      ..lineTo(cx - s.width * 0.08, cy - s.height * 0.16)
      ..close();
    cv.drawPath(blade, _fill(Color.lerp(color, Colors.white, 0.22)!));
    final dark = Color.lerp(color, Colors.black, 0.2)!;
    cv.drawRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + s.height * 0.16), width: s.width * 0.34, height: s.height * 0.06),
        const Radius.circular(2)), _fill(dark));
    cv.drawRect(Rect.fromCenter(center: Offset(cx, cy + s.height * 0.26), width: s.width * 0.06, height: s.height * 0.14), _fill(dark));
  }

  void _flame(Canvas cv, double cx, double cy, Size s) {
    final path = Path()
      ..moveTo(cx, cy - s.height * 0.3)
      ..quadraticBezierTo(cx + s.width * 0.28, cy - s.height * 0.02, cx + s.width * 0.15, cy + s.height * 0.22)
      ..quadraticBezierTo(cx + s.width * 0.02, cy + s.height * 0.3, cx, cy + s.height * 0.26)
      ..quadraticBezierTo(cx - s.width * 0.02, cy + s.height * 0.3, cx - s.width * 0.15, cy + s.height * 0.22)
      ..quadraticBezierTo(cx - s.width * 0.28, cy - s.height * 0.02, cx, cy - s.height * 0.3);
    cv.drawPath(path, _fill(color));
    cv.drawPath(
      Path()
        ..moveTo(cx, cy - s.height * 0.08)
        ..quadraticBezierTo(cx + s.width * 0.11, cy + s.height * 0.06, cx, cy + s.height * 0.2)
        ..quadraticBezierTo(cx - s.width * 0.11, cy + s.height * 0.06, cx, cy - s.height * 0.08),
      _fill(Colors.white.withValues(alpha: 0.55)),
    );
  }

  void _snowflake(Canvas cv, double cx, double cy, Size s) {
    final p = _stroke(color, s.width * 0.07);
    final r = s.width * 0.3;
    for (int i = 0; i < 6; i++) {
      final a = i * pi / 3;
      final ex = cx + r * cos(a), ey = cy + r * sin(a);
      cv.drawLine(Offset(cx, cy), Offset(ex, ey), p);
      final bx = cx + r * 0.6 * cos(a), by = cy + r * 0.6 * sin(a);
      cv.drawLine(Offset(bx, by), Offset(bx + r * 0.26 * cos(a + 0.9), by + r * 0.26 * sin(a + 0.9)), p);
      cv.drawLine(Offset(bx, by), Offset(bx + r * 0.26 * cos(a - 0.9), by + r * 0.26 * sin(a - 0.9)), p);
    }
  }

  void _bolt(Canvas cv, double cx, double cy, Size s) {
    final path = Path()
      ..moveTo(cx + s.width * 0.12, cy - s.height * 0.3)
      ..lineTo(cx - s.width * 0.16, cy + s.height * 0.02)
      ..lineTo(cx + s.width * 0.02, cy + s.height * 0.02)
      ..lineTo(cx - s.width * 0.12, cy + s.height * 0.3)
      ..lineTo(cx + s.width * 0.2, cy - s.height * 0.06)
      ..lineTo(cx, cy - s.height * 0.06)
      ..close();
    cv.drawPath(path, _fill(color));
  }

  void _droplet(Canvas cv, double cx, double cy, Size s) {
    final path = Path()
      ..moveTo(cx, cy - s.height * 0.3)
      ..quadraticBezierTo(cx + s.width * 0.28, cy + s.height * 0.08, cx, cy + s.height * 0.3)
      ..quadraticBezierTo(cx - s.width * 0.28, cy + s.height * 0.08, cx, cy - s.height * 0.3);
    cv.drawPath(path, _fill(color));
    cv.drawCircle(Offset(cx - s.width * 0.07, cy + s.height * 0.05), s.width * 0.05, _fill(Colors.white.withValues(alpha: 0.6)));
  }

  void _voidOrb(Canvas cv, double cx, double cy, Size s) {
    cv.drawCircle(Offset(cx, cy), s.width * 0.28, _fill(color));
    cv.drawCircle(Offset(cx, cy), s.width * 0.13, _fill(Colors.black.withValues(alpha: 0.65)));
    cv.drawCircle(Offset(cx + s.width * 0.24, cy - s.height * 0.14), s.width * 0.045, _fill(Colors.white.withValues(alpha: 0.7)));
  }

  @override
  bool shouldRepaint(covariant ElementIconPainter old) => old.type != type || old.color != color;
}
