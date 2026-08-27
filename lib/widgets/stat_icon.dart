import 'dart:math';
import 'package:flutter/material.dart';

/// Kinds of content stat icons drawn by [StatIcon].
enum StatIconType {
  power, damage, armor, hp, hpRegen,
  crit, critDamage, pierce, dodge,
  gold, xp, shards,
}

/// Hand-drawn combat / economy stat icons, tinted with a caller-supplied colour.
/// Replaces the Material icons on the Artifacts, Hero Stats and combat panels.
class StatIcon extends StatelessWidget {
  const StatIcon({super.key, required this.type, required this.color, this.size = 22});
  final StatIconType type;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _StatIconPainter(type, color)),
      );
}

class _StatIconPainter extends CustomPainter {
  const _StatIconPainter(this.type, this.color);
  final StatIconType type;
  final Color color;

  @override
  void paint(Canvas cv, Size s) {
    final cx = s.width / 2, cy = s.height / 2;
    switch (type) {
      case StatIconType.power:      _fist(cv, cx, cy, s);
      case StatIconType.damage:     _sword(cv, cx, cy, s);
      case StatIconType.armor:      _shield(cv, cx, cy, s);
      case StatIconType.hp:         _heart(cv, cx, cy, s, plus: false);
      case StatIconType.hpRegen:    _heart(cv, cx, cy, s, plus: true);
      case StatIconType.crit:       _crosshair(cv, cx, cy, s);
      case StatIconType.critDamage: _burst(cv, cx, cy, s);
      case StatIconType.pierce:     _arrow(cv, cx, cy, s);
      case StatIconType.dodge:      _swoosh(cv, cx, cy, s);
      case StatIconType.gold:       _coin(cv, cx, cy, s);
      case StatIconType.xp:         _chevrons(cv, cx, cy, s);
      case StatIconType.shards:     _gem(cv, cx, cy, s);
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

  void _fist(Canvas cv, double cx, double cy, Size s) {
    final base = Color.lerp(color, Colors.black, 0.12)!;
    cv.drawRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + s.height * 0.04), width: s.width * 0.44, height: s.height * 0.4),
        Radius.circular(s.width * 0.08)), _fill(base));
    final ridge = _stroke(Color.lerp(color, Colors.black, 0.3)!, 1.4);
    for (int i = -1; i <= 2; i++) {
      final x = cx - s.width * 0.12 + i * s.width * 0.11;
      cv.drawLine(Offset(x, cy - s.height * 0.16), Offset(x, cy - s.height * 0.05), ridge);
    }
    cv.drawRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - s.width * 0.26, cy + s.height * 0.06), width: s.width * 0.12, height: s.height * 0.18),
        Radius.circular(s.width * 0.05)), _fill(base));
    cv.drawRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - s.width * 0.02, cy - s.height * 0.02), width: s.width * 0.3, height: s.height * 0.07),
        const Radius.circular(2)), _fill(Colors.white.withValues(alpha: 0.3)));
  }

  void _sword(Canvas cv, double cx, double cy, Size s) {
    final blade = Path()
      ..moveTo(cx, cy - s.height * 0.32)
      ..lineTo(cx + s.width * 0.08, cy - s.height * 0.16)
      ..lineTo(cx + s.width * 0.05, cy + s.height * 0.14)
      ..lineTo(cx - s.width * 0.05, cy + s.height * 0.14)
      ..lineTo(cx - s.width * 0.08, cy - s.height * 0.16)
      ..close();
    cv.drawPath(blade, _fill(Color.lerp(color, Colors.white, 0.22)!));
    final dark = Color.lerp(color, Colors.black, 0.15)!;
    cv.drawRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + s.height * 0.16), width: s.width * 0.34, height: s.height * 0.06),
        const Radius.circular(2)), _fill(dark));
    cv.drawRect(Rect.fromCenter(center: Offset(cx, cy + s.height * 0.26), width: s.width * 0.06, height: s.height * 0.14), _fill(dark));
  }

  void _shield(Canvas cv, double cx, double cy, Size s) {
    final path = Path()
      ..moveTo(cx, cy - s.height * 0.3)
      ..lineTo(cx + s.width * 0.26, cy - s.height * 0.18)
      ..lineTo(cx + s.width * 0.26, cy + s.height * 0.06)
      ..quadraticBezierTo(cx + s.width * 0.26, cy + s.height * 0.26, cx, cy + s.height * 0.32)
      ..quadraticBezierTo(cx - s.width * 0.26, cy + s.height * 0.26, cx - s.width * 0.26, cy + s.height * 0.06)
      ..lineTo(cx - s.width * 0.26, cy - s.height * 0.18)
      ..close();
    cv.drawPath(path, _fill(Color.lerp(color, Colors.black, 0.12)!));
    cv.save();
    cv.clipPath(path);
    cv.drawRect(Rect.fromLTWH(0, 0, cx, s.height), _fill(Color.lerp(color, Colors.white, 0.16)!));
    cv.restore();
    cv.drawPath(path, _stroke(Color.lerp(color, Colors.white, 0.2)!, 1.3));
  }

  void _heart(Canvas cv, double cx, double cy, Size s, {required bool plus}) {
    final path = Path()
      ..moveTo(cx, cy + s.height * 0.24)
      ..cubicTo(cx - s.width * 0.32, cy, cx - s.width * 0.18, cy - s.height * 0.26, cx, cy - s.height * 0.06)
      ..cubicTo(cx + s.width * 0.18, cy - s.height * 0.26, cx + s.width * 0.32, cy, cx, cy + s.height * 0.24);
    cv.drawPath(path, _fill(color));
    if (plus) {
      final p = _stroke(Colors.white.withValues(alpha: 0.85), 2);
      cv.drawLine(Offset(cx, cy - s.height * 0.06), Offset(cx, cy + s.height * 0.08), p);
      cv.drawLine(Offset(cx - s.width * 0.07, cy + s.height * 0.01), Offset(cx + s.width * 0.07, cy + s.height * 0.01), p);
    } else {
      cv.drawCircle(Offset(cx - s.width * 0.08, cy - s.height * 0.04), s.width * 0.045, _fill(Colors.white.withValues(alpha: 0.5)));
    }
  }

  void _crosshair(Canvas cv, double cx, double cy, Size s) {
    final r = s.width * 0.28;
    cv.drawCircle(Offset(cx, cy), r, _stroke(color, 2.2));
    cv.drawCircle(Offset(cx, cy), r * 0.13, _fill(color));
    final tick = _stroke(color, 1.8);
    for (int i = 0; i < 4; i++) {
      final a = i * pi / 2;
      cv.drawLine(Offset(cx + r * 0.5 * cos(a), cy + r * 0.5 * sin(a)),
          Offset(cx + r * 1.3 * cos(a), cy + r * 1.3 * sin(a)), tick);
    }
  }

  void _burst(Canvas cv, double cx, double cy, Size s) {
    cv.drawCircle(Offset(cx, cy), s.width * 0.3, _fill(color.withValues(alpha: 0.15)));
    final path = Path();
    final r = s.width * 0.3;
    for (int i = 0; i < 12; i++) {
      final a = -pi / 2 + i * pi / 6;
      final rr = i.isEven ? r : r * 0.42;
      final x = cx + rr * cos(a), y = cy + rr * sin(a);
      if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
    }
    path.close();
    cv.drawPath(path, _fill(color));
    cv.drawCircle(Offset(cx, cy), s.width * 0.06, _fill(Colors.white.withValues(alpha: 0.6)));
  }

  void _arrow(Canvas cv, double cx, double cy, Size s) {
    final shaft = _stroke(color, 2.4);
    cv.drawLine(Offset(cx - s.width * 0.26, cy + s.height * 0.26), Offset(cx + s.width * 0.2, cy - s.height * 0.2), shaft);
    cv.drawPath(Path()
      ..moveTo(cx + s.width * 0.3, cy - s.height * 0.3)
      ..lineTo(cx + s.width * 0.1, cy - s.height * 0.24)
      ..lineTo(cx + s.width * 0.24, cy - s.height * 0.1)
      ..close(), _fill(color));
    // fletching
    cv.drawLine(Offset(cx - s.width * 0.26, cy + s.height * 0.26), Offset(cx - s.width * 0.14, cy + s.height * 0.3), _stroke(Color.lerp(color, Colors.white, 0.3)!, 2));
    cv.drawLine(Offset(cx - s.width * 0.26, cy + s.height * 0.26), Offset(cx - s.width * 0.3, cy + s.height * 0.14), _stroke(Color.lerp(color, Colors.white, 0.3)!, 2));
  }

  void _swoosh(Canvas cv, double cx, double cy, Size s) {
    final w = _stroke(color, 2.4);
    for (int i = -1; i <= 1; i++) {
      final y = cy + i * s.height * 0.14;
      final len = s.width * (0.42 - i.abs() * 0.08);
      cv.drawPath(Path()
        ..moveTo(cx - len / 2, y)
        ..quadraticBezierTo(cx, y - s.height * 0.06, cx + len / 2, y), w);
    }
  }

  void _coin(Canvas cv, double cx, double cy, Size s) {
    final r = s.width * 0.28;
    cv.drawCircle(Offset(cx, cy), r, _fill(Color.lerp(color, Colors.black, 0.12)!));
    cv.drawCircle(Offset(cx, cy), r * 0.82, _fill(Color.lerp(color, Colors.white, 0.2)!));
    cv.drawCircle(Offset(cx, cy), r * 0.82, _stroke(Color.lerp(color, Colors.black, 0.25)!, 1.3));
    cv.drawCircle(Offset(cx - r * 0.4, cy - r * 0.4), r * 0.12, _fill(Colors.white.withValues(alpha: 0.6)));
  }

  void _chevrons(Canvas cv, double cx, double cy, Size s) {
    final p = _stroke(color, 2.6);
    for (int i = 0; i < 2; i++) {
      final oy = cy + s.height * 0.12 - i * s.height * 0.2;
      cv.drawPath(Path()
        ..moveTo(cx - s.width * 0.22, oy + s.height * 0.06)
        ..lineTo(cx, oy - s.height * 0.08)
        ..lineTo(cx + s.width * 0.22, oy + s.height * 0.06), p);
    }
  }

  void _gem(Canvas cv, double cx, double cy, Size s) {
    final crown = Path()
      ..moveTo(cx, cy - s.height * 0.28)
      ..lineTo(cx + s.width * 0.26, cy - s.height * 0.04)
      ..lineTo(cx - s.width * 0.26, cy - s.height * 0.04)
      ..close();
    cv.drawPath(crown, _fill(Color.lerp(color, Colors.white, 0.18)!));
    final pav = Path()
      ..moveTo(cx - s.width * 0.26, cy - s.height * 0.04)
      ..lineTo(cx + s.width * 0.26, cy - s.height * 0.04)
      ..lineTo(cx, cy + s.height * 0.3)
      ..close();
    cv.drawPath(pav, _fill(Color.lerp(color, Colors.black, 0.14)!));
    cv.drawPath(Path()
      ..moveTo(cx, cy - s.height * 0.28)
      ..lineTo(cx + s.width * 0.05, cy - s.height * 0.04)
      ..lineTo(cx - s.width * 0.05, cy - s.height * 0.04)
      ..close(), _fill(Colors.white.withValues(alpha: 0.4)));
  }

  @override
  bool shouldRepaint(covariant _StatIconPainter old) => old.type != type || old.color != color;
}
