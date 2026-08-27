import 'dart:math';
import 'package:flutter/material.dart';

/// Hand-drawn emblems for the core attribute stats (Power, Agility, Vitality,
/// Precision, Fortitude, Luck) shown on the Ability Scores screen — replacing
/// the old Material icons. Tinted with the stat's colour.
class StatEmblem extends StatelessWidget {
  const StatEmblem({super.key, required this.statKey, required this.color, this.size = 28});
  final String statKey;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _StatEmblemPainter(statKey, color)),
      );
}

class _StatEmblemPainter extends CustomPainter {
  const _StatEmblemPainter(this.statKey, this.color);
  final String statKey;
  final Color color;

  @override
  void paint(Canvas cv, Size s) {
    final cx = s.width / 2, cy = s.height / 2;
    switch (statKey) {
      case 'pwr':  _fist(cv, cx, cy, s);
      case 'agi':  _feather(cv, cx, cy, s);
      case 'vit':  _heart(cv, cx, cy, s);
      case 'prc':  _target(cv, cx, cy, s);
      case 'for_': _shield(cv, cx, cy, s);
      case 'lck':  _clover(cv, cx, cy, s);
      default:     _target(cv, cx, cy, s);
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

  // ── Power — a clenched fist ────────────────────────────────────────────────
  void _fist(Canvas cv, double cx, double cy, Size s) {
    final base = Color.lerp(color, Colors.black, 0.12)!;
    // hand block
    cv.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(cx, cy + s.height * 0.04), width: s.width * 0.44, height: s.height * 0.4),
            Radius.circular(s.width * 0.08)),
        _fill(base));
    // knuckle ridges
    final ridge = _stroke(Color.lerp(color, Colors.black, 0.3)!, 1.6);
    for (int i = -1; i <= 2; i++) {
      final x = cx - s.width * 0.12 + i * s.width * 0.11;
      cv.drawLine(Offset(x, cy - s.height * 0.16), Offset(x, cy - s.height * 0.05), ridge);
    }
    // thumb
    cv.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(cx - s.width * 0.26, cy + s.height * 0.06), width: s.width * 0.12, height: s.height * 0.18),
            Radius.circular(s.width * 0.05)),
        _fill(base));
    // highlight
    cv.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(cx - s.width * 0.02, cy - s.height * 0.02), width: s.width * 0.3, height: s.height * 0.08),
            const Radius.circular(2)),
        _fill(Colors.white.withValues(alpha: 0.35)));
  }

  // ── Agility — a feather ────────────────────────────────────────────────────
  void _feather(Canvas cv, double cx, double cy, Size s) {
    final quill = Offset(cx + s.width * 0.22, cy + s.height * 0.3);
    final tip   = Offset(cx - s.width * 0.24, cy - s.height * 0.3);
    final vane = Path()
      ..moveTo(quill.dx, quill.dy)
      ..quadraticBezierTo(cx - s.width * 0.32, cy - s.height * 0.06, tip.dx, tip.dy)
      ..quadraticBezierTo(cx + s.width * 0.06, cy - s.height * 0.02, quill.dx, quill.dy);
    cv.drawPath(vane, _fill(Color.lerp(color, Colors.white, 0.15)!));
    // rachis (central shaft)
    cv.drawLine(quill, tip, _stroke(Color.lerp(color, Colors.black, 0.3)!, 1.8));
    // barbs
    final barb = _stroke(Color.lerp(color, Colors.black, 0.15)!, 1);
    for (int i = 1; i <= 5; i++) {
      final t = i / 6.0;
      final on = Offset.lerp(quill, tip, t)!;
      cv.drawLine(on, Offset(on.dx - s.width * 0.12, on.dy - s.height * 0.06), barb);
    }
  }

  // ── Vitality — a heart ─────────────────────────────────────────────────────
  void _heart(Canvas cv, double cx, double cy, Size s) {
    final path = Path()
      ..moveTo(cx, cy + s.height * 0.26)
      ..cubicTo(cx - s.width * 0.34, cy + s.height * 0.02, cx - s.width * 0.2, cy - s.height * 0.28, cx, cy - s.height * 0.08)
      ..cubicTo(cx + s.width * 0.2, cy - s.height * 0.28, cx + s.width * 0.34, cy + s.height * 0.02, cx, cy + s.height * 0.26);
    cv.drawPath(path, _fill(color));
    cv.drawCircle(Offset(cx - s.width * 0.09, cy - s.height * 0.05), s.width * 0.05, _fill(Colors.white.withValues(alpha: 0.55)));
  }

  // ── Precision — a crosshair ────────────────────────────────────────────────
  void _target(Canvas cv, double cx, double cy, Size s) {
    final r = s.width * 0.3;
    cv.drawCircle(Offset(cx, cy), r, _stroke(color, 2.4));
    cv.drawCircle(Offset(cx, cy), r * 0.5, _stroke(color.withValues(alpha: 0.8), 2));
    cv.drawCircle(Offset(cx, cy), r * 0.13, _fill(color));
    final tick = _stroke(Color.lerp(color, Colors.white, 0.2)!, 2);
    for (int i = 0; i < 4; i++) {
      final a = i * pi / 2;
      cv.drawLine(Offset(cx + r * 0.85 * cos(a), cy + r * 0.85 * sin(a)),
          Offset(cx + r * 1.32 * cos(a), cy + r * 1.32 * sin(a)), tick);
    }
  }

  // ── Fortitude — a shield ───────────────────────────────────────────────────
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
    cv.drawRect(Rect.fromLTWH(0, 0, cx, s.height), _fill(Color.lerp(color, Colors.white, 0.18)!));
    cv.restore();
    final mark = _fill(Colors.white.withValues(alpha: 0.5));
    cv.drawRect(Rect.fromCenter(center: Offset(cx, cy), width: s.width * 0.07, height: s.height * 0.42), mark);
    cv.drawRect(Rect.fromCenter(center: Offset(cx, cy - s.height * 0.03), width: s.width * 0.32, height: s.height * 0.07), mark);
    cv.drawPath(path, _stroke(Color.lerp(color, Colors.white, 0.2)!, 1.4));
  }

  // ── Luck — a four-leaf clover ──────────────────────────────────────────────
  void _clover(Canvas cv, double cx, double cy, Size s) {
    final r = s.width * 0.15;
    final leaf = _fill(color);
    final offsets = [
      Offset(0, -r), Offset(r, 0), Offset(0, r), Offset(-r, 0),
    ];
    for (final o in offsets) {
      cv.drawCircle(Offset(cx + o.dx, cy + o.dy), r * 0.95, leaf);
    }
    cv.drawCircle(Offset(cx, cy), r * 0.5, _fill(Color.lerp(color, Colors.white, 0.3)!));
    // stem
    cv.drawLine(Offset(cx + r * 0.4, cy + r * 0.8), Offset(cx + r * 1.1, cy + r * 2.0),
        _stroke(Color.lerp(color, Colors.black, 0.2)!, 1.8));
  }

  @override
  bool shouldRepaint(covariant _StatEmblemPainter old) =>
      old.statKey != statKey || old.color != color;
}
