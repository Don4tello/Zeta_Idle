import 'dart:math' as math;
import 'package:flutter/material.dart';

enum GameIconType {
  // Navigation
  shield, swords, chest, coinBag, castle,
  // Game modes
  scroll, key, gauntlet, skull,
  // Hero hub tabs
  armor, trophy, medal, leaf, barChart, eyeMonster, book, paw, warriors,
  flame, gear, mountain, crown,
  // Guild sub-tabs
  dragonSkull, bubble, shopBag,
  // Resources
  coin, diamond, starburst, bolt, flask, compass, gift,
  // Utility
  lock, star, bell, flag, lightbulb, snowflake, moon, fist,
}

class GameIcon extends StatelessWidget {
  const GameIcon(this.type, {super.key, required this.size, required this.color});
  final GameIconType type;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size(size, size),
        painter: _GameIconPainter(type, color),
      );
}

class _GameIconPainter extends CustomPainter {
  const _GameIconPainter(this.type, this.color);
  final GameIconType type;
  final Color color;

  @override
  bool shouldRepaint(_GameIconPainter old) =>
      old.color != color || old.type != type;

  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    switch (type) {
      case GameIconType.shield:      _shield(c, s, p);
      case GameIconType.swords:      _swords(c, s, p);
      case GameIconType.chest:       _chest(c, s, p);
      case GameIconType.coinBag:     _coinBag(c, s, p);
      case GameIconType.castle:      _castle(c, s, p);
      case GameIconType.scroll:      _scroll(c, s, p);
      case GameIconType.key:         _key(c, s, p);
      case GameIconType.gauntlet:    _gauntlet(c, s, p);
      case GameIconType.skull:       _skull(c, s, p);
      case GameIconType.armor:       _armor(c, s, p);
      case GameIconType.trophy:      _trophy(c, s, p);
      case GameIconType.medal:       _medal(c, s, p);
      case GameIconType.leaf:        _leaf(c, s, p);
      case GameIconType.barChart:    _barChart(c, s, p);
      case GameIconType.eyeMonster:  _eyeMonster(c, s, p);
      case GameIconType.book:        _book(c, s, p);
      case GameIconType.paw:         _paw(c, s, p);
      case GameIconType.warriors:    _warriors(c, s, p);
      case GameIconType.flame:       _flame(c, s, p);
      case GameIconType.gear:        _gear(c, s, p);
      case GameIconType.mountain:    _mountain(c, s, p);
      case GameIconType.crown:       _crown(c, s, p);
      case GameIconType.dragonSkull: _dragonSkull(c, s, p);
      case GameIconType.bubble:      _bubble(c, s, p);
      case GameIconType.shopBag:     _shopBag(c, s, p);
      case GameIconType.coin:        _coin(c, s, p);
      case GameIconType.diamond:     _diamond(c, s, p);
      case GameIconType.starburst:   _starburst(c, s, p);
      case GameIconType.bolt:        _bolt(c, s, p);
      case GameIconType.flask:       _flask(c, s, p);
      case GameIconType.compass:     _compass(c, s, p);
      case GameIconType.gift:        _gift(c, s, p);
      case GameIconType.lock:        _lock(c, s, p);
      case GameIconType.star:        _star(c, s, p);
      case GameIconType.bell:        _bell(c, s, p);
      case GameIconType.flag:        _flag(c, s, p);
      case GameIconType.lightbulb:   _lightbulb(c, s, p);
      case GameIconType.snowflake:   _snowflake(c, s, p);
      case GameIconType.moon:        _moon(c, s, p);
      case GameIconType.fist:        _fist(c, s, p);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual icon painters
// ─────────────────────────────────────────────────────────────────────────────

void _shield(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  final path = Path()..fillType = PathFillType.evenOdd;
  // Kite shield outline
  path.moveTo(w * 0.10, h * 0.06);
  path.lineTo(w * 0.90, h * 0.06);
  path.lineTo(w * 0.90, h * 0.58);
  path.lineTo(w * 0.50, h * 0.96);
  path.lineTo(w * 0.10, h * 0.58);
  path.close();
  // Central cross cutout (shows dark background = cross emblem)
  path.addRect(Rect.fromLTWH(w * 0.14, h * 0.34, w * 0.72, h * 0.10));
  path.addRect(Rect.fromLTWH(w * 0.45, h * 0.10, w * 0.10, h * 0.56));
  c.drawPath(path, p);
}

void _swords(Canvas c, Size s, Paint p) {
  final sz = math.min(s.width, s.height);
  c.save();
  c.translate(s.width / 2, s.height / 2);
  for (final angle in [-math.pi / 4, math.pi / 4]) {
    c.save();
    c.rotate(angle);
    _drawSwordShape(c, sz, p);
    c.restore();
  }
  c.restore();
}

void _drawSwordShape(Canvas c, double sz, Paint p) {
  // Blade (tip up, handle down, centered at origin)
  c.drawRect(Rect.fromCenter(center: Offset(0, -sz * 0.20), width: sz * 0.10, height: sz * 0.54), p);
  // Blade tip
  final tip = Path()
    ..moveTo(-sz * 0.05, -sz * 0.47)
    ..lineTo(sz * 0.05, -sz * 0.47)
    ..lineTo(0, -sz * 0.52)
    ..close();
  c.drawPath(tip, p);
  // Crossguard
  c.drawRect(Rect.fromCenter(center: Offset(0, sz * 0.07), width: sz * 0.46, height: sz * 0.09), p);
  // Handle
  c.drawRect(Rect.fromCenter(center: Offset(0, sz * 0.27), width: sz * 0.12, height: sz * 0.26), p);
  // Pommel
  c.drawRect(Rect.fromCenter(center: Offset(0, sz * 0.43), width: sz * 0.20, height: sz * 0.10), p);
}

void _chest(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  // Lid (arched top)
  final lid = Path()
    ..moveTo(w * 0.08, h * 0.37)
    ..lineTo(w * 0.08, h * 0.22)
    ..quadraticBezierTo(w * 0.08, h * 0.06, w * 0.50, h * 0.06)
    ..quadraticBezierTo(w * 0.92, h * 0.06, w * 0.92, h * 0.22)
    ..lineTo(w * 0.92, h * 0.37)
    ..close();
  c.drawPath(lid, p);
  // Body
  c.drawRect(Rect.fromLTWH(w * 0.08, h * 0.43, w * 0.84, h * 0.51), p);
  // Lock clasp
  c.drawRect(Rect.fromLTWH(w * 0.40, h * 0.31, w * 0.20, h * 0.18), p);
  // Iron band on lid bottom
  c.drawRect(Rect.fromLTWH(w * 0.08, h * 0.30, w * 0.84, h * 0.08), p);
  // Iron band on body
  c.drawRect(Rect.fromLTWH(w * 0.08, h * 0.60, w * 0.84, h * 0.07), p);
}

void _coinBag(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  final path = Path()..fillType = PathFillType.evenOdd;
  // Bag body oval
  path.addOval(Rect.fromLTWH(w * 0.08, h * 0.28, w * 0.84, h * 0.68));
  // Coin ring cutout on bag face
  path.addOval(Rect.fromLTWH(w * 0.33, h * 0.44, w * 0.34, h * 0.34));
  c.drawPath(path, p);
  // Neck
  c.drawRect(Rect.fromLTWH(w * 0.34, h * 0.16, w * 0.32, h * 0.16), p);
  // Tie / knot
  c.drawOval(Rect.fromLTWH(w * 0.26, h * 0.04, w * 0.48, h * 0.16), p);
}

void _castle(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  // Three merlons at top
  c.drawRect(Rect.fromLTWH(w * 0.10, h * 0.05, w * 0.22, h * 0.22), p);
  c.drawRect(Rect.fromLTWH(w * 0.39, h * 0.05, w * 0.22, h * 0.22), p);
  c.drawRect(Rect.fromLTWH(w * 0.68, h * 0.05, w * 0.22, h * 0.22), p);
  // Left pillar
  c.drawRect(Rect.fromLTWH(w * 0.10, h * 0.24, w * 0.26, h * 0.72), p);
  // Right pillar
  c.drawRect(Rect.fromLTWH(w * 0.64, h * 0.24, w * 0.26, h * 0.72), p);
  // Top wall (above gate arch)
  c.drawRect(Rect.fromLTWH(w * 0.10, h * 0.24, w * 0.80, h * 0.30), p);
  // Gate is the transparent gap between pillars below the top wall
}

void _scroll(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  final path = Path()..fillType = PathFillType.evenOdd;
  // Body
  path.addRect(Rect.fromLTWH(w * 0.16, h * 0.14, w * 0.68, h * 0.72));
  // Top roll
  path.addOval(Rect.fromLTWH(w * 0.06, h * 0.06, w * 0.88, h * 0.18));
  // Bottom roll
  path.addOval(Rect.fromLTWH(w * 0.06, h * 0.76, w * 0.88, h * 0.18));
  // Text line cutouts
  path.addRect(Rect.fromLTWH(w * 0.26, h * 0.28, w * 0.48, h * 0.07));
  path.addRect(Rect.fromLTWH(w * 0.26, h * 0.44, w * 0.48, h * 0.07));
  path.addRect(Rect.fromLTWH(w * 0.26, h * 0.60, w * 0.34, h * 0.07));
  c.drawPath(path, p);
}

void _key(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  // Key bow (ring with hole)
  final bow = Path()..fillType = PathFillType.evenOdd;
  bow.addOval(Rect.fromLTWH(w * 0.16, h * 0.04, w * 0.56, h * 0.46));
  bow.addOval(Rect.fromLTWH(w * 0.29, h * 0.14, w * 0.30, h * 0.28));
  c.drawPath(bow, p);
  // Shaft
  c.drawRect(Rect.fromLTWH(w * 0.44, h * 0.46, w * 0.14, h * 0.48), p);
  // Two teeth
  c.drawRect(Rect.fromLTWH(w * 0.58, h * 0.60, w * 0.16, h * 0.09), p);
  c.drawRect(Rect.fromLTWH(w * 0.58, h * 0.76, w * 0.12, h * 0.09), p);
}

void _gauntlet(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  // Thumb (left side)
  c.drawRect(Rect.fromLTWH(w * 0.02, h * 0.22, w * 0.14, h * 0.20), p);
  // Four fingers (compact rectangles at top)
  for (int i = 0; i < 4; i++) {
    c.drawRect(Rect.fromLTWH(w * (0.16 + i * 0.20), h * 0.04, w * 0.16, h * 0.24), p);
  }
  // Palm
  c.drawRect(Rect.fromLTWH(w * 0.10, h * 0.26, w * 0.82, h * 0.24), p);
  // Cuff (armored wrist, wider)
  final cuff = Path()..fillType = PathFillType.evenOdd;
  cuff.addRect(Rect.fromLTWH(w * 0.06, h * 0.48, w * 0.88, h * 0.46));
  // Armor segment line
  cuff.addRect(Rect.fromLTWH(w * 0.06, h * 0.64, w * 0.88, h * 0.05));
  c.drawPath(cuff, p);
}

void _skull(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  final path = Path()..fillType = PathFillType.evenOdd;
  // Cranium
  path.addOval(Rect.fromLTWH(w * 0.08, h * 0.04, w * 0.84, h * 0.64));
  // Jaw
  path.addRect(Rect.fromLTWH(w * 0.18, h * 0.46, w * 0.64, h * 0.26));
  // Eye socket holes
  path.addOval(Rect.fromLTWH(w * 0.16, h * 0.20, w * 0.28, h * 0.24));
  path.addOval(Rect.fromLTWH(w * 0.56, h * 0.20, w * 0.28, h * 0.24));
  c.drawPath(path, p);
  // Teeth
  for (int i = 0; i < 4; i++) {
    c.drawRect(Rect.fromLTWH(w * (0.20 + i * 0.16), h * 0.75, w * 0.10, h * 0.17), p);
  }
}

void _armor(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  // Helm (top oval)
  c.drawOval(Rect.fromLTWH(w * 0.30, h * 0.02, w * 0.40, h * 0.22), p);
  // Neck
  c.drawRect(Rect.fromLTWH(w * 0.41, h * 0.21, w * 0.18, h * 0.09), p);
  // Left pauldron
  c.drawOval(Rect.fromLTWH(w * 0.04, h * 0.26, w * 0.28, h * 0.20), p);
  // Right pauldron
  c.drawOval(Rect.fromLTWH(w * 0.68, h * 0.26, w * 0.28, h * 0.20), p);
  // Chest plate
  final chest = Path()..fillType = PathFillType.evenOdd
    ..moveTo(w * 0.20, h * 0.30)
    ..lineTo(w * 0.80, h * 0.30)
    ..lineTo(w * 0.88, h * 0.70)
    ..lineTo(w * 0.50, h * 0.84)
    ..lineTo(w * 0.12, h * 0.70)
    ..close();
  // Center ridge
  chest.addRect(Rect.fromLTWH(w * 0.47, h * 0.32, w * 0.06, h * 0.38));
  c.drawPath(chest, p);
  // Belt
  c.drawRect(Rect.fromLTWH(w * 0.14, h * 0.72, w * 0.72, h * 0.10), p);
}

void _trophy(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  // Cup body
  final cup = Path()
    ..moveTo(w * 0.16, h * 0.08)
    ..lineTo(w * 0.84, h * 0.08)
    ..lineTo(w * 0.72, h * 0.55)
    ..quadraticBezierTo(w * 0.65, h * 0.68, w * 0.50, h * 0.68)
    ..quadraticBezierTo(w * 0.35, h * 0.68, w * 0.28, h * 0.55)
    ..close();
  c.drawPath(cup, p);
  // Left handle
  final lh = Path()
    ..moveTo(w * 0.16, h * 0.10)
    ..quadraticBezierTo(w * 0.01, h * 0.28, w * 0.12, h * 0.44)
    ..lineTo(w * 0.26, h * 0.44)
    ..quadraticBezierTo(w * 0.18, h * 0.28, w * 0.30, h * 0.10)
    ..close();
  c.drawPath(lh, p);
  // Right handle
  final rh = Path()
    ..moveTo(w * 0.84, h * 0.10)
    ..quadraticBezierTo(w * 0.99, h * 0.28, w * 0.88, h * 0.44)
    ..lineTo(w * 0.74, h * 0.44)
    ..quadraticBezierTo(w * 0.82, h * 0.28, w * 0.70, h * 0.10)
    ..close();
  c.drawPath(rh, p);
  // Stem
  c.drawRect(Rect.fromLTWH(w * 0.44, h * 0.68, w * 0.12, h * 0.18), p);
  // Base
  c.drawRect(Rect.fromLTWH(w * 0.22, h * 0.84, w * 0.56, h * 0.10), p);
}

void _medal(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  // Ribbon V-shape (two angled strips)
  final rl = Path()
    ..moveTo(w * 0.28, h * 0.04)
    ..lineTo(w * 0.50, h * 0.04)
    ..lineTo(w * 0.43, h * 0.38)
    ..lineTo(w * 0.21, h * 0.38)
    ..close();
  final rr = Path()
    ..moveTo(w * 0.50, h * 0.04)
    ..lineTo(w * 0.72, h * 0.04)
    ..lineTo(w * 0.79, h * 0.38)
    ..lineTo(w * 0.57, h * 0.38)
    ..close();
  c.drawPath(rl, p);
  c.drawPath(rr, p);
  // Medal disk with star cutout
  final medal = Path()..fillType = PathFillType.evenOdd;
  medal.addOval(Rect.fromLTWH(w * 0.14, h * 0.40, w * 0.72, h * 0.56));
  _addStar(medal, Offset(w * 0.50, h * 0.68), w * 0.22, w * 0.10);
  c.drawPath(medal, p);
}

void _addStar(Path path, Offset center, double outerR, double innerR) {
  for (int i = 0; i < 5; i++) {
    final oa = (i * 2 * math.pi / 5) - math.pi / 2;
    final ia = oa + math.pi / 5;
    final op = Offset(center.dx + outerR * math.cos(oa), center.dy + outerR * math.sin(oa));
    final ip = Offset(center.dx + innerR * math.cos(ia), center.dy + innerR * math.sin(ia));
    if (i == 0) { path.moveTo(op.dx, op.dy); } else { path.lineTo(op.dx, op.dy); }
    path.lineTo(ip.dx, ip.dy);
  }
  path.close();
}

void _leaf(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  final leaf = Path()
    ..moveTo(w * 0.50, h * 0.04)
    ..cubicTo(w * 0.92, h * 0.14, w * 0.96, h * 0.56, w * 0.66, h * 0.74)
    ..quadraticBezierTo(w * 0.56, h * 0.80, w * 0.50, h * 0.78)
    ..quadraticBezierTo(w * 0.44, h * 0.80, w * 0.34, h * 0.74)
    ..cubicTo(w * 0.04, h * 0.56, w * 0.08, h * 0.14, w * 0.50, h * 0.04)
    ..close();
  // Leaf with midrib vein cutout
  final path = Path()..fillType = PathFillType.evenOdd;
  path.addPath(leaf, Offset.zero);
  path.addRect(Rect.fromLTWH(w * 0.47, h * 0.12, w * 0.06, h * 0.62));
  c.drawPath(path, p);
  // Stem
  c.drawRect(Rect.fromLTWH(w * 0.46, h * 0.76, w * 0.08, h * 0.20), p);
}

void _barChart(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  // Three bars (short, medium, tall)
  c.drawRect(Rect.fromLTWH(w * 0.06, h * 0.58, w * 0.22, h * 0.34), p);
  c.drawRect(Rect.fromLTWH(w * 0.39, h * 0.32, w * 0.22, h * 0.60), p);
  c.drawRect(Rect.fromLTWH(w * 0.72, h * 0.08, w * 0.22, h * 0.84), p);
  // Base line
  c.drawRect(Rect.fromLTWH(w * 0.04, h * 0.90, w * 0.92, h * 0.06), p);
}

void _eyeMonster(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  // Brow ridge
  c.drawRect(Rect.fromLTWH(w * 0.18, h * 0.04, w * 0.64, h * 0.10), p);
  // Eye with slit pupil cutout
  final path = Path()..fillType = PathFillType.evenOdd;
  path.moveTo(w * 0.50, h * 0.12);
  path.quadraticBezierTo(w * 0.96, h * 0.50, w * 0.50, h * 0.92);
  path.quadraticBezierTo(w * 0.04, h * 0.50, w * 0.50, h * 0.12);
  path.close();
  // Slit pupil
  path.addOval(Rect.fromLTWH(w * 0.38, h * 0.28, w * 0.24, h * 0.44));
  c.drawPath(path, p);
}

void _book(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  final path = Path()..fillType = PathFillType.evenOdd;
  // Left page
  path.addRect(Rect.fromLTWH(w * 0.04, h * 0.10, w * 0.43, h * 0.82));
  // Right page
  path.addRect(Rect.fromLTWH(w * 0.53, h * 0.10, w * 0.43, h * 0.82));
  // Spine
  path.addRect(Rect.fromLTWH(w * 0.44, h * 0.06, w * 0.12, h * 0.90));
  // Text lines
  for (int i = 0; i < 4; i++) {
    path.addRect(Rect.fromLTWH(w * 0.10, h * (0.24 + i * 0.16), w * 0.30, h * 0.05));
    path.addRect(Rect.fromLTWH(w * 0.58, h * (0.24 + i * 0.16), w * 0.30, h * 0.05));
  }
  c.drawPath(path, p);
}

void _paw(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  // Main pad
  c.drawOval(Rect.fromLTWH(w * 0.20, h * 0.40, w * 0.60, h * 0.54), p);
  // Four toes
  c.drawOval(Rect.fromLTWH(w * 0.04, h * 0.16, w * 0.24, h * 0.28), p);
  c.drawOval(Rect.fromLTWH(w * 0.30, h * 0.06, w * 0.18, h * 0.26), p);
  c.drawOval(Rect.fromLTWH(w * 0.52, h * 0.06, w * 0.18, h * 0.26), p);
  c.drawOval(Rect.fromLTWH(w * 0.72, h * 0.16, w * 0.24, h * 0.28), p);
}

void _warriors(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  // Center warrior
  c.drawOval(Rect.fromLTWH(w * 0.38, h * 0.04, w * 0.24, h * 0.22), p);
  c.drawRect(Rect.fromLTWH(w * 0.32, h * 0.24, w * 0.36, h * 0.34), p);
  c.drawRect(Rect.fromLTWH(w * 0.34, h * 0.56, w * 0.12, h * 0.36), p);
  c.drawRect(Rect.fromLTWH(w * 0.54, h * 0.56, w * 0.12, h * 0.36), p);
  // Left warrior (smaller)
  c.drawOval(Rect.fromLTWH(w * 0.08, h * 0.10, w * 0.18, h * 0.18), p);
  c.drawRect(Rect.fromLTWH(w * 0.04, h * 0.26, w * 0.26, h * 0.26), p);
  c.drawRect(Rect.fromLTWH(w * 0.06, h * 0.50, w * 0.08, h * 0.28), p);
  c.drawRect(Rect.fromLTWH(w * 0.18, h * 0.50, w * 0.08, h * 0.28), p);
  // Right warrior (smaller)
  c.drawOval(Rect.fromLTWH(w * 0.74, h * 0.10, w * 0.18, h * 0.18), p);
  c.drawRect(Rect.fromLTWH(w * 0.70, h * 0.26, w * 0.26, h * 0.26), p);
  c.drawRect(Rect.fromLTWH(w * 0.72, h * 0.50, w * 0.08, h * 0.28), p);
  c.drawRect(Rect.fromLTWH(w * 0.84, h * 0.50, w * 0.08, h * 0.28), p);
}

void _flame(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  final outer = Path()
    ..moveTo(w * 0.50, h * 0.04)
    ..quadraticBezierTo(w * 0.86, h * 0.22, w * 0.82, h * 0.60)
    ..quadraticBezierTo(w * 0.78, h * 0.90, w * 0.50, h * 0.96)
    ..quadraticBezierTo(w * 0.22, h * 0.90, w * 0.18, h * 0.60)
    ..quadraticBezierTo(w * 0.14, h * 0.22, w * 0.50, h * 0.04)
    ..close();
  // Inner core cutout gives glowing effect
  final path = Path()..fillType = PathFillType.evenOdd;
  path.addPath(outer, Offset.zero);
  path.moveTo(w * 0.50, h * 0.30);
  path.quadraticBezierTo(w * 0.67, h * 0.44, w * 0.64, h * 0.66);
  path.quadraticBezierTo(w * 0.60, h * 0.82, w * 0.50, h * 0.84);
  path.quadraticBezierTo(w * 0.40, h * 0.82, w * 0.36, h * 0.66);
  path.quadraticBezierTo(w * 0.33, h * 0.44, w * 0.50, h * 0.30);
  path.close();
  c.drawPath(path, p);
}

void _gear(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  final cx = w / 2, cy = h / 2;
  // 8 teeth
  for (int i = 0; i < 8; i++) {
    final angle = i * math.pi / 4;
    c.save();
    c.translate(cx, cy);
    c.rotate(angle);
    c.drawRect(Rect.fromLTWH(-w * 0.09, -w * 0.50, w * 0.18, w * 0.18), p);
    c.restore();
  }
  // Disk with center hole
  final disk = Path()..fillType = PathFillType.evenOdd;
  disk.addOval(Rect.fromCenter(center: Offset(cx, cy), width: w * 0.72, height: h * 0.72));
  disk.addOval(Rect.fromCenter(center: Offset(cx, cy), width: w * 0.24, height: h * 0.24));
  c.drawPath(disk, p);
}

void _mountain(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  // Main peak
  final peak = Path()
    ..moveTo(w * 0.50, h * 0.05)
    ..lineTo(w * 0.90, h * 0.86)
    ..lineTo(w * 0.10, h * 0.86)
    ..close();
  c.drawPath(peak, p);
  // Ground line
  c.drawRect(Rect.fromLTWH(w * 0.04, h * 0.86, w * 0.92, h * 0.08), p);
  // Snow cap highlight (small triangle cutout)
  final snow = Path()..fillType = PathFillType.evenOdd;
  snow.addPath(peak, Offset.zero);
  snow.moveTo(w * 0.36, h * 0.40);
  snow.lineTo(w * 0.64, h * 0.40);
  snow.lineTo(w * 0.50, h * 0.05);
  snow.close();
  c.drawPath(snow, p);
  // Redraw snow cap as solid
  final cap = Path()
    ..moveTo(w * 0.50, h * 0.05)
    ..lineTo(w * 0.64, h * 0.40)
    ..lineTo(w * 0.36, h * 0.40)
    ..close();
  c.drawPath(cap, p);
}

void _crown(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  // Crown body (zigzag top with solid base)
  final path = Path()
    ..moveTo(w * 0.04, h * 0.22)
    ..lineTo(w * 0.22, h * 0.60)
    ..lineTo(w * 0.32, h * 0.30)
    ..lineTo(w * 0.50, h * 0.58)
    ..lineTo(w * 0.68, h * 0.30)
    ..lineTo(w * 0.78, h * 0.60)
    ..lineTo(w * 0.96, h * 0.22)
    ..lineTo(w * 0.96, h * 0.88)
    ..lineTo(w * 0.04, h * 0.88)
    ..close();
  c.drawPath(path, p);
  // Three gem balls at tip positions
  c.drawCircle(Offset(w * 0.04, h * 0.22), w * 0.07, p);
  c.drawCircle(Offset(w * 0.50, h * 0.10), w * 0.08, p);
  c.drawCircle(Offset(w * 0.96, h * 0.22), w * 0.07, p);
}

void _dragonSkull(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  // Left horn (curved)
  final lh = Path()
    ..moveTo(w * 0.20, h * 0.22)
    ..cubicTo(w * 0.10, h * 0.08, w * 0.18, h * 0.02, w * 0.28, h * 0.12)
    ..lineTo(w * 0.26, h * 0.26)
    ..close();
  // Right horn
  final rh = Path()
    ..moveTo(w * 0.80, h * 0.22)
    ..cubicTo(w * 0.90, h * 0.08, w * 0.82, h * 0.02, w * 0.72, h * 0.12)
    ..lineTo(w * 0.74, h * 0.26)
    ..close();
  c.drawPath(lh, p);
  c.drawPath(rh, p);
  // Skull body with eye holes
  final skull = Path()..fillType = PathFillType.evenOdd;
  skull.addOval(Rect.fromLTWH(w * 0.14, h * 0.16, w * 0.72, h * 0.52));
  skull.addRect(Rect.fromLTWH(w * 0.22, h * 0.48, w * 0.56, h * 0.22));
  skull.addOval(Rect.fromLTWH(w * 0.20, h * 0.26, w * 0.24, h * 0.20));
  skull.addOval(Rect.fromLTWH(w * 0.56, h * 0.26, w * 0.24, h * 0.20));
  c.drawPath(skull, p);
  // Teeth
  for (int i = 0; i < 3; i++) {
    c.drawRect(Rect.fromLTWH(w * (0.28 + i * 0.18), h * 0.73, w * 0.11, h * 0.18), p);
  }
}

void _bubble(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  final rr = RRect.fromRectAndRadius(
    Rect.fromLTWH(w * 0.06, h * 0.06, w * 0.88, h * 0.68),
    Radius.circular(w * 0.18),
  );
  // Bubble with dot cutouts
  final path = Path()..fillType = PathFillType.evenOdd;
  path.addRRect(rr);
  path.addOval(Rect.fromCenter(center: Offset(w * 0.30, h * 0.40), width: w * 0.14, height: h * 0.14));
  path.addOval(Rect.fromCenter(center: Offset(w * 0.50, h * 0.40), width: w * 0.14, height: h * 0.14));
  path.addOval(Rect.fromCenter(center: Offset(w * 0.70, h * 0.40), width: w * 0.14, height: h * 0.14));
  c.drawPath(path, p);
  // Tail
  final tail = Path()
    ..moveTo(w * 0.14, h * 0.70)
    ..lineTo(w * 0.06, h * 0.92)
    ..lineTo(w * 0.28, h * 0.72)
    ..close();
  c.drawPath(tail, p);
}

void _shopBag(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  // Bag handle (arch)
  final handle = Path()..fillType = PathFillType.evenOdd;
  handle.addRRect(RRect.fromRectAndRadius(
    Rect.fromLTWH(w * 0.22, h * 0.04, w * 0.56, h * 0.36),
    Radius.circular(w * 0.20),
  ));
  handle.addRRect(RRect.fromRectAndRadius(
    Rect.fromLTWH(w * 0.34, h * 0.10, w * 0.32, h * 0.24),
    Radius.circular(w * 0.12),
  ));
  c.drawPath(handle, p);
  // Bag body with label cutout
  final bag = Path()..fillType = PathFillType.evenOdd
    ..moveTo(w * 0.10, h * 0.32)
    ..lineTo(w * 0.90, h * 0.32)
    ..lineTo(w * 0.96, h * 0.94)
    ..lineTo(w * 0.04, h * 0.94)
    ..close();
  bag.addRect(Rect.fromLTWH(w * 0.36, h * 0.50, w * 0.28, h * 0.22));
  c.drawPath(bag, p);
}

void _coin(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  final path = Path()..fillType = PathFillType.evenOdd;
  path.addOval(Rect.fromLTWH(w * 0.06, h * 0.06, w * 0.88, h * 0.88));
  path.addOval(Rect.fromLTWH(w * 0.28, h * 0.28, w * 0.44, h * 0.44));
  c.drawPath(path, p);
}

void _diamond(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  final path = Path()..fillType = PathFillType.evenOdd
    ..moveTo(w * 0.50, h * 0.04)
    ..lineTo(w * 0.94, h * 0.40)
    ..lineTo(w * 0.50, h * 0.96)
    ..lineTo(w * 0.06, h * 0.40)
    ..close();
  // Facet line
  path.addRect(Rect.fromLTWH(w * 0.06, h * 0.37, w * 0.88, h * 0.07));
  c.drawPath(path, p);
}

void _starburst(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  final cx = w / 2, cy = h / 2;
  final path = Path();
  for (int i = 0; i < 8; i++) {
    final a = i * math.pi / 4 - math.pi / 2;
    final a2 = a + math.pi / 8;
    final r1 = w * 0.46, r2 = w * 0.18;
    if (i == 0) { path.moveTo(cx + r1 * math.cos(a), cy + r1 * math.sin(a)); }
    else { path.lineTo(cx + r1 * math.cos(a), cy + r1 * math.sin(a)); }
    path.lineTo(cx + r2 * math.cos(a2), cy + r2 * math.sin(a2));
  }
  path.close();
  c.drawPath(path, p);
}

void _bolt(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  final path = Path()
    ..moveTo(w * 0.62, h * 0.04)
    ..lineTo(w * 0.28, h * 0.50)
    ..lineTo(w * 0.50, h * 0.50)
    ..lineTo(w * 0.38, h * 0.96)
    ..lineTo(w * 0.72, h * 0.50)
    ..lineTo(w * 0.50, h * 0.50)
    ..close();
  c.drawPath(path, p);
}

void _flask(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  // Stopper
  c.drawRect(Rect.fromLTWH(w * 0.30, h * 0.02, w * 0.40, h * 0.08), p);
  // Neck
  c.drawRect(Rect.fromLTWH(w * 0.38, h * 0.08, w * 0.24, h * 0.22), p);
  // Body with liquid level
  final body = Path()..fillType = PathFillType.evenOdd;
  body.addOval(Rect.fromLTWH(w * 0.08, h * 0.26, w * 0.84, h * 0.70));
  // Empty space at top of flask
  body.addRect(Rect.fromLTWH(w * 0.10, h * 0.26, w * 0.80, h * 0.26));
  c.drawPath(body, p);
  // Bubble inside liquid
  c.drawOval(Rect.fromLTWH(w * 0.38, h * 0.60, w * 0.16, h * 0.14), p);
}

void _compass(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  // Compass ring
  final ring = Path()..fillType = PathFillType.evenOdd;
  ring.addOval(Rect.fromLTWH(w * 0.06, h * 0.06, w * 0.88, h * 0.88));
  ring.addOval(Rect.fromLTWH(w * 0.20, h * 0.20, w * 0.60, h * 0.60));
  c.drawPath(ring, p);
  // North needle (pointing up)
  final north = Path()
    ..moveTo(w * 0.50, h * 0.12)
    ..lineTo(w * 0.43, h * 0.50)
    ..lineTo(w * 0.57, h * 0.50)
    ..close();
  c.drawPath(north, p);
  // South needle
  final south = Path()
    ..moveTo(w * 0.50, h * 0.88)
    ..lineTo(w * 0.43, h * 0.50)
    ..lineTo(w * 0.57, h * 0.50)
    ..close();
  c.drawPath(south, p);
}

void _gift(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  // Box body
  c.drawRect(Rect.fromLTWH(w * 0.08, h * 0.40, w * 0.84, h * 0.54), p);
  // Lid
  c.drawRect(Rect.fromLTWH(w * 0.04, h * 0.30, w * 0.92, h * 0.14), p);
  // Ribbon vertical
  c.drawRect(Rect.fromLTWH(w * 0.44, h * 0.30, w * 0.12, h * 0.64), p);
  // Bow loops
  final bl = Path()
    ..moveTo(w * 0.50, h * 0.30)
    ..quadraticBezierTo(w * 0.24, h * 0.18, w * 0.26, h * 0.08)
    ..quadraticBezierTo(w * 0.28, h * 0.02, w * 0.40, h * 0.10)
    ..quadraticBezierTo(w * 0.50, h * 0.16, w * 0.50, h * 0.30)
    ..close();
  final br = Path()
    ..moveTo(w * 0.50, h * 0.30)
    ..quadraticBezierTo(w * 0.76, h * 0.18, w * 0.74, h * 0.08)
    ..quadraticBezierTo(w * 0.72, h * 0.02, w * 0.60, h * 0.10)
    ..quadraticBezierTo(w * 0.50, h * 0.16, w * 0.50, h * 0.30)
    ..close();
  c.drawPath(bl, p);
  c.drawPath(br, p);
}

void _lock(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  // Shackle (arch)
  final shackle = Path()..fillType = PathFillType.evenOdd;
  shackle.addRRect(RRect.fromRectAndRadius(
    Rect.fromLTWH(w * 0.22, h * 0.04, w * 0.56, h * 0.52),
    Radius.circular(w * 0.20),
  ));
  shackle.addRRect(RRect.fromRectAndRadius(
    Rect.fromLTWH(w * 0.34, h * 0.14, w * 0.32, h * 0.36),
    Radius.circular(w * 0.12),
  ));
  c.drawPath(shackle, p);
  // Body
  c.drawRRect(RRect.fromRectAndRadius(
    Rect.fromLTWH(w * 0.10, h * 0.46, w * 0.80, h * 0.48),
    Radius.circular(w * 0.06),
  ), p);
  // Keyhole (punch through)
  final body = Path()..fillType = PathFillType.evenOdd;
  body.addRRect(RRect.fromRectAndRadius(
    Rect.fromLTWH(w * 0.10, h * 0.46, w * 0.80, h * 0.48),
    Radius.circular(w * 0.06),
  ));
  body.addOval(Rect.fromCenter(center: Offset(w * 0.50, h * 0.62), width: w * 0.16, height: h * 0.16));
  body.addRect(Rect.fromLTWH(w * 0.46, h * 0.68, w * 0.08, h * 0.14));
  c.drawPath(body, p);
}

void _star(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  final path = Path();
  _addStar(path, Offset(w * 0.50, h * 0.50), w * 0.46, w * 0.18);
  c.drawPath(path, p);
}

void _bell(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  // Bell body
  final bell = Path()
    ..moveTo(w * 0.50, h * 0.06)
    ..quadraticBezierTo(w * 0.88, h * 0.18, w * 0.92, h * 0.72)
    ..lineTo(w * 0.08, h * 0.72)
    ..quadraticBezierTo(w * 0.12, h * 0.18, w * 0.50, h * 0.06)
    ..close();
  c.drawPath(bell, p);
  // Rim band
  c.drawRect(Rect.fromLTWH(w * 0.06, h * 0.70, w * 0.88, h * 0.10), p);
  // Clapper
  c.drawOval(Rect.fromLTWH(w * 0.42, h * 0.80, w * 0.16, h * 0.14), p);
  // Hook at top
  c.drawRect(Rect.fromLTWH(w * 0.44, h * 0.02, w * 0.12, h * 0.08), p);
}

void _flag(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  // Pole
  c.drawRect(Rect.fromLTWH(w * 0.14, h * 0.06, w * 0.08, h * 0.88), p);
  // Flag body (pennant)
  final flag = Path()
    ..moveTo(w * 0.22, h * 0.08)
    ..lineTo(w * 0.92, h * 0.28)
    ..lineTo(w * 0.22, h * 0.50)
    ..close();
  c.drawPath(flag, p);
}

void _lightbulb(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  // Bulb
  final bulb = Path()
    ..moveTo(w * 0.50, h * 0.04)
    ..quadraticBezierTo(w * 0.92, h * 0.10, w * 0.90, h * 0.50)
    ..quadraticBezierTo(w * 0.88, h * 0.70, w * 0.68, h * 0.76)
    ..lineTo(w * 0.32, h * 0.76)
    ..quadraticBezierTo(w * 0.12, h * 0.70, w * 0.10, h * 0.50)
    ..quadraticBezierTo(w * 0.08, h * 0.10, w * 0.50, h * 0.04)
    ..close();
  c.drawPath(bulb, p);
  // Base (filament housing)
  c.drawRect(Rect.fromLTWH(w * 0.32, h * 0.76, w * 0.36, h * 0.10), p);
  c.drawRect(Rect.fromLTWH(w * 0.36, h * 0.84, w * 0.28, h * 0.10), p);
}

void _snowflake(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  final cx = w / 2, cy = h / 2;
  final armLen = w * 0.44;
  final armW = w * 0.09;
  for (int i = 0; i < 6; i++) {
    final angle = i * math.pi / 3;
    c.save();
    c.translate(cx, cy);
    c.rotate(angle);
    // Main arm
    c.drawRect(Rect.fromCenter(center: Offset(0, -armLen / 2), width: armW, height: armLen), p);
    // Side branches
    for (final dir in [-1.0, 1.0]) {
      c.save();
      c.translate(0, -armLen * 0.55);
      c.rotate(dir * math.pi / 4);
      c.drawRect(Rect.fromCenter(center: Offset(0, -armLen * 0.16), width: armW * 0.8, height: armLen * 0.26), p);
      c.restore();
    }
    c.restore();
  }
  c.drawCircle(Offset(cx, cy), w * 0.09, p);
}

void _moon(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  final path = Path()..fillType = PathFillType.evenOdd;
  path.addOval(Rect.fromLTWH(w * 0.10, h * 0.06, w * 0.80, h * 0.88));
  // Cutout circle offset to create crescent
  path.addOval(Rect.fromLTWH(w * 0.22, h * 0.02, w * 0.72, h * 0.80));
  c.drawPath(path, p);
}

void _fist(Canvas c, Size s, Paint p) {
  final w = s.width, h = s.height;
  // Knuckle row (four rectangles)
  for (int i = 0; i < 4; i++) {
    c.drawRect(Rect.fromLTWH(w * (0.08 + i * 0.21), h * 0.06, w * 0.18, h * 0.24), p);
  }
  // Fist body
  c.drawRect(Rect.fromLTWH(w * 0.08, h * 0.26, w * 0.76, h * 0.34), p);
  // Thumb (overlapping side)
  c.drawRect(Rect.fromLTWH(w * 0.78, h * 0.26, w * 0.16, h * 0.20), p);
  // Wrist
  c.drawRect(Rect.fromLTWH(w * 0.14, h * 0.58, w * 0.64, h * 0.34), p);
  // Knuckle dividers (punch through)
  final path = Path()..fillType = PathFillType.evenOdd;
  path.addRect(Rect.fromLTWH(w * 0.08, h * 0.26, w * 0.76, h * 0.34));
  path.addRect(Rect.fromLTWH(w * 0.08, h * 0.36, w * 0.76, h * 0.05));
  c.drawPath(path, p);
}
