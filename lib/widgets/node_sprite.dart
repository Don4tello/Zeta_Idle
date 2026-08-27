import 'dart:math';
import 'package:flutter/material.dart';
import '../models/endless_upgrades.dart';

/// Hand-drawn emblem for each Echoes-Upgrade node (Brutality, Precision, …),
/// replacing the old "BRT / PRC / …" text badges. Each emblem is themed to the
/// node's role and tinted with the node's colour.
class NodeSprite extends StatelessWidget {
  const NodeSprite({super.key, required this.node, this.size = 40});
  final EndlessNode node;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: NodeSpritePainter(node)),
      );
}

class NodeSpritePainter extends CustomPainter {
  const NodeSpritePainter(this.node);
  final EndlessNode node;

  @override
  void paint(Canvas cv, Size s) {
    final cx = s.width / 2;
    final cy = s.height / 2;
    final col = node.color;
    switch (node) {
      case EndlessNode.str:          _sword(cv, cx, cy, s, col);   // Brutality
      case EndlessNode.dex:          _target(cv, cx, cy, s, col);  // Precision
      case EndlessNode.con:          _shield(cv, cx, cy, s, col);  // Toughness
      case EndlessNode.intelligence: _coin(cv, cx, cy, s, col);    // Prosperity
      case EndlessNode.wis:          _eye(cv, cx, cy, s, col);     // Insight
      case EndlessNode.cha:          _star(cv, cx, cy, s, col);    // Focus
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

  // ── Brutality — an upward sword ────────────────────────────────────────────
  void _sword(Canvas cv, double cx, double cy, Size s, Color col) {
    final blade = Path()
      ..moveTo(cx, cy - s.height * 0.34)
      ..lineTo(cx + s.width * 0.09, cy - s.height * 0.18)
      ..lineTo(cx + s.width * 0.06, cy + s.height * 0.14)
      ..lineTo(cx - s.width * 0.06, cy + s.height * 0.14)
      ..lineTo(cx - s.width * 0.09, cy - s.height * 0.18)
      ..close();
    cv.drawPath(blade, _fill(Color.lerp(col, Colors.white, 0.25)!));
    // centre fuller highlight
    cv.drawPath(
      Path()
        ..moveTo(cx, cy - s.height * 0.32)
        ..lineTo(cx + s.width * 0.02, cy + s.height * 0.12)
        ..lineTo(cx - s.width * 0.02, cy + s.height * 0.12)
        ..close(),
      _fill(Colors.white.withValues(alpha: 0.5)),
    );
    // crossguard + grip + pommel
    final dark = Color.lerp(col, Colors.black, 0.15)!;
    cv.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(cx, cy + s.height * 0.16), width: s.width * 0.36, height: s.height * 0.06),
            const Radius.circular(2)),
        _fill(dark));
    cv.drawRect(
        Rect.fromCenter(center: Offset(cx, cy + s.height * 0.26), width: s.width * 0.06, height: s.height * 0.14),
        _fill(dark));
    cv.drawCircle(Offset(cx, cy + s.height * 0.34), s.width * 0.05, _fill(col));
  }

  // ── Precision — a crosshair / target ───────────────────────────────────────
  void _target(Canvas cv, double cx, double cy, Size s, Color col) {
    final r = s.width * 0.3;
    cv.drawCircle(Offset(cx, cy), r, _stroke(col, 2.4));
    cv.drawCircle(Offset(cx, cy), r * 0.55, _stroke(col.withValues(alpha: 0.8), 2));
    cv.drawCircle(Offset(cx, cy), r * 0.14, _fill(col));
    // tick marks
    final tick = _stroke(Color.lerp(col, Colors.white, 0.2)!, 2);
    for (int i = 0; i < 4; i++) {
      final a = i * pi / 2;
      cv.drawLine(
        Offset(cx + r * 0.86 * cos(a), cy + r * 0.86 * sin(a)),
        Offset(cx + r * 1.3 * cos(a), cy + r * 1.3 * sin(a)),
        tick,
      );
    }
  }

  // ── Toughness — a heater shield ────────────────────────────────────────────
  void _shield(Canvas cv, double cx, double cy, Size s, Color col) {
    final path = Path()
      ..moveTo(cx, cy - s.height * 0.32)
      ..lineTo(cx + s.width * 0.28, cy - s.height * 0.2)
      ..lineTo(cx + s.width * 0.28, cy + s.height * 0.06)
      ..quadraticBezierTo(cx + s.width * 0.28, cy + s.height * 0.28, cx, cy + s.height * 0.34)
      ..quadraticBezierTo(cx - s.width * 0.28, cy + s.height * 0.28, cx - s.width * 0.28, cy + s.height * 0.06)
      ..lineTo(cx - s.width * 0.28, cy - s.height * 0.2)
      ..close();
    cv.drawPath(path, _fill(Color.lerp(col, Colors.black, 0.12)!));
    // bright left half
    cv.save();
    cv.clipPath(path);
    cv.drawRect(Rect.fromLTWH(0, 0, cx, s.height), _fill(Color.lerp(col, Colors.white, 0.18)!));
    cv.restore();
    // heraldic cross
    final cross = _fill(Colors.white.withValues(alpha: 0.55));
    cv.drawRect(Rect.fromCenter(center: Offset(cx, cy), width: s.width * 0.08, height: s.height * 0.46), cross);
    cv.drawRect(Rect.fromCenter(center: Offset(cx, cy - s.height * 0.02), width: s.width * 0.36, height: s.height * 0.08), cross);
    cv.drawPath(path, _stroke(Color.lerp(col, Colors.white, 0.2)!, 1.4));
  }

  // ── Prosperity — a coin ────────────────────────────────────────────────────
  void _coin(Canvas cv, double cx, double cy, Size s, Color col) {
    final r = s.width * 0.3;
    cv.drawCircle(Offset(cx, cy), r, _fill(Color.lerp(col, Colors.black, 0.12)!));
    cv.drawCircle(Offset(cx, cy), r * 0.82, _fill(Color.lerp(col, Colors.white, 0.2)!));
    cv.drawCircle(Offset(cx, cy), r * 0.82, _stroke(Color.lerp(col, Colors.black, 0.25)!, 1.4));
    // embossed star
    _starPath(cv, cx, cy, r * 0.5, _fill(Color.lerp(col, Colors.black, 0.2)!));
    // shine
    cv.drawCircle(Offset(cx - r * 0.4, cy - r * 0.4), r * 0.12, _fill(Colors.white.withValues(alpha: 0.6)));
  }

  // ── Insight — an eye ───────────────────────────────────────────────────────
  void _eye(Canvas cv, double cx, double cy, Size s, Color col) {
    final w = s.width * 0.34;
    final outer = Path()
      ..moveTo(cx - w, cy)
      ..quadraticBezierTo(cx, cy - s.height * 0.26, cx + w, cy)
      ..quadraticBezierTo(cx, cy + s.height * 0.26, cx - w, cy);
    cv.drawPath(outer, _fill(Color.lerp(col, Colors.white, 0.2)!));
    cv.drawPath(outer, _stroke(Color.lerp(col, Colors.black, 0.2)!, 1.6));
    cv.drawCircle(Offset(cx, cy), s.width * 0.12, _fill(Color.lerp(col, Colors.black, 0.35)!));
    cv.drawCircle(Offset(cx, cy), s.width * 0.055, _fill(col));
    cv.drawCircle(Offset(cx - s.width * 0.04, cy - s.height * 0.04), s.width * 0.03, _fill(Colors.white.withValues(alpha: 0.8)));
    // eyelash rays
    final ray = _stroke(col, 1.6);
    for (int i = -1; i <= 1; i++) {
      final a = -pi / 2 + i * 0.5;
      cv.drawLine(
        Offset(cx + w * 0.7 * cos(a), cy + s.height * 0.22 * sin(a)),
        Offset(cx + w * 1.05 * cos(a), cy + s.height * 0.34 * sin(a)),
        ray,
      );
    }
  }

  // ── Focus — a five-point star ──────────────────────────────────────────────
  void _star(Canvas cv, double cx, double cy, Size s, Color col) {
    // soft glow
    cv.drawCircle(Offset(cx, cy), s.width * 0.32, _fill(col.withValues(alpha: 0.15)));
    _starPath(cv, cx, cy, s.width * 0.32, _fill(col));
    _starPath(cv, cx, cy, s.width * 0.18, _fill(Colors.white.withValues(alpha: 0.55)));
  }

  void _starPath(Canvas cv, double cx, double cy, double r, Paint p) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final oa = -pi / 2 + i * 2 * pi / 5;
      final ia = oa + pi / 5;
      final ox = cx + r * cos(oa), oy = cy + r * sin(oa);
      final ix = cx + r * 0.42 * cos(ia), iy = cy + r * 0.42 * sin(ia);
      if (i == 0) { path.moveTo(ox, oy); } else { path.lineTo(ox, oy); }
      path.lineTo(ix, iy);
    }
    path.close();
    cv.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant NodeSpritePainter old) => old.node != node;
}
