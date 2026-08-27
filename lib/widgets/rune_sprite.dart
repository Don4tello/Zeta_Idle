import 'dart:math';
import 'package:flutter/material.dart';
import '../models/ability_rune.dart';

/// Carved-stone rune tablet with a per-rune engraved glyph, drawn in the same
/// stylized-sprite style as the crafted gems (base / mid / highlight layering
/// plus a 1px bevel). Replaces the old emoji icons on the Runes screen.
///
/// Glyphs are rolled out class-by-class. A rune whose glyph isn't drawn yet
/// falls back to a generic angular rune mark, so every rune always renders.
class RuneGlyph extends StatelessWidget {
  const RuneGlyph({super.key, required this.rune, this.size = 40});
  final AbilityRune rune;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: RuneSpritePainter(rune: rune)),
      );
}

/// Semantic glyph keys. One key can be shared by runes across classes (many
/// classes have a shield / flame / skull rune), which keeps the art cohesive.
enum RuneGlyphKey {
  // Barbarian
  blood, skull, anger, flame, bolt, storm, dagger, mountain,
  // Fighter / Rogue / Ranger / Paladin / Cleric (martial & holy)
  shield, swords, target, crown, trophy, medal, gear,
  darkmoon, smoke, poison, card, ghost, moon,
  bow, leaf, bird, trap, wolf, rain, eye,
  star4, heart, sparkle, sun, cross, star5, castle, angel,
  // Wizard / Sorcerer / Warlock / Bard / Monk / Druid (casters & nature)
  frost, crystal, burst, hourglass, comet, orb, swirl, virus, fear, mask,
  chain, scroll, note, horn, violin, yinyang, lotus, fist, dragon, scales,
  gi, sprout, tree, bear, lion, globe,
  // fallback
  rune,
}

RuneGlyphKey _glyphForRune(AbilityRune r) {
  // Mapped by the rune's existing symbol so the art carries the same meaning.
  switch (r.icon) {
    // Barbarian
    case '🩸': return RuneGlyphKey.blood;
    case '💀': return RuneGlyphKey.skull;
    case '💢': return RuneGlyphKey.anger;
    case '🔥': return RuneGlyphKey.flame;
    case '⚡': return RuneGlyphKey.bolt;
    case '⛈': return RuneGlyphKey.storm;
    case '🗡': return RuneGlyphKey.dagger;
    case '🏔': return RuneGlyphKey.mountain;
    // Fighter
    case '🎯': return RuneGlyphKey.target;
    case '🛡': return RuneGlyphKey.shield;
    case '⚔': return RuneGlyphKey.swords;
    case '👑': return RuneGlyphKey.crown;
    case '🏆': return RuneGlyphKey.trophy;
    case '🎖': return RuneGlyphKey.medal;
    case '⚙': return RuneGlyphKey.gear;
    // Rogue
    case '🌑': return RuneGlyphKey.darkmoon;
    case '💨': return RuneGlyphKey.smoke;
    case '☠': return RuneGlyphKey.poison;
    case '🃏': return RuneGlyphKey.card;
    case '👻': return RuneGlyphKey.ghost;
    case '🌙': return RuneGlyphKey.moon;
    // Ranger
    case '🏹': return RuneGlyphKey.bow;
    case '🌿': return RuneGlyphKey.leaf;
    case '🦅': return RuneGlyphKey.bird;
    case '🪤': return RuneGlyphKey.trap;
    case '🐺': return RuneGlyphKey.wolf;
    case '🌧': return RuneGlyphKey.rain;
    case '👁': return RuneGlyphKey.eye;
    // Paladin / Cleric (holy)
    case '✦': return RuneGlyphKey.star4;
    case '💛': return RuneGlyphKey.heart;
    case '❤': return RuneGlyphKey.heart;
    case '✨': return RuneGlyphKey.sparkle;
    case '☀': return RuneGlyphKey.sun;
    case '✝': return RuneGlyphKey.cross;
    case '🌟': return RuneGlyphKey.star5;
    case '🕊': return RuneGlyphKey.bird;
    case '🏰': return RuneGlyphKey.castle;
    case '👼': return RuneGlyphKey.angel;
    // Wizard
    case '❄': return RuneGlyphKey.frost;
    case '🔷': return RuneGlyphKey.crystal;
    case '🧊': return RuneGlyphKey.crystal;
    case '💥': return RuneGlyphKey.burst;
    case '⏳': return RuneGlyphKey.hourglass;
    case '☄': return RuneGlyphKey.comet;
    case '🔮': return RuneGlyphKey.orb;
    // Sorcerer
    case '💫': return RuneGlyphKey.swirl;
    case '🌀': return RuneGlyphKey.swirl;
    case '🕳': return RuneGlyphKey.orb;
    case '🎆': return RuneGlyphKey.burst;
    // Warlock
    case '🦠': return RuneGlyphKey.virus;
    case '😱': return RuneGlyphKey.fear;
    case '⛓': return RuneGlyphKey.chain;
    case '📜': return RuneGlyphKey.scroll;
    // Bard
    case '🎵': return RuneGlyphKey.note;
    case '🎶': return RuneGlyphKey.note;
    case '🎼': return RuneGlyphKey.note;
    case '🔊': return RuneGlyphKey.horn;
    case '📯': return RuneGlyphKey.horn;
    case '💝': return RuneGlyphKey.heart;
    case '🎭': return RuneGlyphKey.mask;
    case '😏': return RuneGlyphKey.mask;
    case '🎻': return RuneGlyphKey.violin;
    // Monk
    case '☯': return RuneGlyphKey.yinyang;
    case '🧘': return RuneGlyphKey.lotus;
    case '🔵': return RuneGlyphKey.orb;
    case '🌪': return RuneGlyphKey.swirl;
    case '✊': return RuneGlyphKey.fist;
    case '🐉': return RuneGlyphKey.dragon;
    case '⚖': return RuneGlyphKey.scales;
    case '🥋': return RuneGlyphKey.gi;
    // Druid
    case '🌱': return RuneGlyphKey.sprout;
    case '🌳': return RuneGlyphKey.tree;
    case '🐻': return RuneGlyphKey.bear;
    case '🦁': return RuneGlyphKey.lion;
    case '💚': return RuneGlyphKey.heart;
    case '🌍': return RuneGlyphKey.globe;
    default:   return RuneGlyphKey.rune;
  }
}

class RuneSpritePainter extends CustomPainter {
  const RuneSpritePainter({required this.rune});
  final AbilityRune rune;

  @override
  void paint(Canvas cv, Size size) {
    final col = rune.color;
    _drawTablet(cv, size, col);
    final cx = size.width / 2;
    final cy = size.height / 2;
    final glyph = Color.lerp(col, Colors.white, 0.25)!;
    final pt = Paint()..color = glyph..isAntiAlias = true;
    switch (_glyphForRune(rune)) {
      case RuneGlyphKey.blood:    _blood(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.skull:    _skull(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.anger:    _anger(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.flame:    _flame(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.bolt:     _bolt(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.storm:    _storm(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.dagger:   _dagger(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.mountain: _mountain(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.shield:   _shield(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.swords:   _swords(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.target:   _target(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.crown:    _crown(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.trophy:   _trophy(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.medal:    _medal(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.gear:     _gear(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.darkmoon: _darkmoon(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.smoke:    _smoke(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.poison:   _poison(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.card:     _card(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.ghost:    _ghost(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.moon:     _moon(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.bow:      _bow(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.leaf:     _leaf(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.bird:     _bird(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.trap:     _trap(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.wolf:     _wolf(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.rain:     _rain(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.eye:      _eye(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.star4:    _star4(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.heart:    _heart(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.sparkle:  _sparkle(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.sun:      _sun(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.cross:    _cross(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.star5:    _star5(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.castle:   _castle(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.angel:    _angel(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.frost:    _frost(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.crystal:  _crystal(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.burst:    _burst(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.hourglass:_hourglass(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.comet:    _comet(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.orb:      _orb(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.swirl:    _swirl(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.virus:    _virus(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.fear:     _fear(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.mask:     _mask(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.chain:    _chain(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.scroll:   _scroll(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.note:     _note(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.horn:     _horn(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.violin:   _violin(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.yinyang:  _yinyang(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.lotus:    _lotus(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.fist:     _fist(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.dragon:   _dragon(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.scales:   _scales(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.gi:       _gi(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.sprout:   _sprout(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.tree:     _tree(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.bear:     _bear(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.lion:     _lion(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.globe:    _globe(cv, pt, cx, cy, size, glyph);
      case RuneGlyphKey.rune:     _defaultRune(cv, pt, cx, cy, size, glyph);
    }
  }

  // ── Shared carved-stone tablet base ───────────────────────────────────────
  void _drawTablet(Canvas cv, Size s, Color col) {
    final pt = Paint()..isAntiAlias = true;
    final w = s.width * 0.74;
    final h = s.height * 0.9;
    final rect = Rect.fromCenter(center: Offset(s.width / 2, s.height / 2), width: w, height: h);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(s.width * 0.14));

    // Faint colour glow behind the stone.
    pt.color = col.withValues(alpha: 0.16);
    cv.drawRRect(rr.inflate(2), pt);

    // Stone body (dark, cool grey with a hint of the rune colour).
    pt.color = Color.lerp(const Color(0xFF2b2724), col, 0.10)!;
    cv.drawRRect(rr, pt);

    // Top bevel highlight / bottom shade for a carved look.
    pt.color = Colors.white.withValues(alpha: 0.10);
    cv.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rect.left, rect.top, w, h * 0.32), Radius.circular(s.width * 0.14)),
      pt,
    );
    pt.color = Colors.black.withValues(alpha: 0.28);
    cv.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rect.left, rect.top + h * 0.72, w, h * 0.28), Radius.circular(s.width * 0.14)),
      pt,
    );

    // Engraved inner recess where the glyph sits.
    pt.color = Colors.black.withValues(alpha: 0.30);
    cv.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(s.width * 0.12), Radius.circular(s.width * 0.08)), pt);

    // 1px bevel border tinted by the rune colour.
    pt
      ..color = Color.lerp(col, Colors.white, 0.15)!.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    cv.drawRRect(rr, pt);
    pt.style = PaintingStyle.fill;
  }

  // Small helper: stroke a path as an engraved glowing glyph (dark under-line
  // + coloured line) for a chiselled look.
  void _engrave(Canvas cv, Path path, Color col, double width) {
    final under = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width + 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    cv.drawPath(path.shift(const Offset(0, 0.6)), under);
    final line = Paint()
      ..color = col
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    cv.drawPath(path, line);
  }

  // ── Barbarian glyphs ──────────────────────────────────────────────────────
  void _blood(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    // Teardrop of blood.
    final top = cy - s.height * 0.22;
    final path = Path()
      ..moveTo(cx, top)
      ..quadraticBezierTo(cx + s.width * 0.22, cy + s.height * 0.04, cx, cy + s.height * 0.24)
      ..quadraticBezierTo(cx - s.width * 0.22, cy + s.height * 0.04, cx, top);
    pt.color = Color.lerp(col, Colors.black, 0.15)!;
    cv.drawPath(path, pt);
    pt.color = col;
    cv.drawCircle(Offset(cx, cy + s.height * 0.06), s.width * 0.11, pt);
    pt.color = Colors.white.withValues(alpha: 0.6);
    cv.drawCircle(Offset(cx - s.width * 0.05, cy - s.height * 0.02), s.width * 0.035, pt);
  }

  void _skull(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt.color = col;
    cv.drawCircle(Offset(cx, cy - s.height * 0.04), s.width * 0.19, pt); // cranium
    cv.drawRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + s.height * 0.14), width: s.width * 0.2, height: s.height * 0.12),
        Radius.circular(s.width * 0.03)), pt); // jaw
    final eye = Paint()..color = Colors.black.withValues(alpha: 0.75)..isAntiAlias = true;
    cv.drawCircle(Offset(cx - s.width * 0.07, cy - s.height * 0.04), s.width * 0.05, eye);
    cv.drawCircle(Offset(cx + s.width * 0.07, cy - s.height * 0.04), s.width * 0.05, eye);
    cv.drawRect(Rect.fromCenter(center: Offset(cx, cy + s.height * 0.05), width: s.width * 0.03, height: s.height * 0.05), eye);
  }

  void _anger(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    // Anime-style anger burst (four-lobed).
    final r = s.width * 0.24;
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final a = i * pi / 2;
      final ax = cx + r * cos(a), ay = cy + r * sin(a);
      final ba = a + pi / 4;
      final bx = cx + r * 0.42 * cos(ba), by = cy + r * 0.42 * sin(ba);
      if (i == 0) { path.moveTo(ax, ay); } else { path.lineTo(ax, ay); }
      path.lineTo(bx, by);
    }
    path.close();
    pt.color = col;
    cv.drawPath(path, pt);
    pt.color = Colors.black.withValues(alpha: 0.5);
    cv.drawCircle(Offset(cx, cy), s.width * 0.05, pt);
  }

  void _flame(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    final path = Path()
      ..moveTo(cx, cy - s.height * 0.26)
      ..quadraticBezierTo(cx + s.width * 0.26, cy - s.height * 0.02, cx + s.width * 0.14, cy + s.height * 0.2)
      ..quadraticBezierTo(cx + s.width * 0.02, cy + s.height * 0.28, cx, cy + s.height * 0.24)
      ..quadraticBezierTo(cx - s.width * 0.02, cy + s.height * 0.28, cx - s.width * 0.14, cy + s.height * 0.2)
      ..quadraticBezierTo(cx - s.width * 0.26, cy - s.height * 0.02, cx, cy - s.height * 0.26);
    pt.color = Color.lerp(col, Colors.black, 0.12)!;
    cv.drawPath(path, pt);
    // Inner flame highlight.
    final inner = Path()
      ..moveTo(cx, cy - s.height * 0.08)
      ..quadraticBezierTo(cx + s.width * 0.1, cy + s.height * 0.06, cx, cy + s.height * 0.18)
      ..quadraticBezierTo(cx - s.width * 0.1, cy + s.height * 0.06, cx, cy - s.height * 0.08);
    pt.color = Colors.white.withValues(alpha: 0.55);
    cv.drawPath(inner, pt);
  }

  void _bolt(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    final path = Path()
      ..moveTo(cx + s.width * 0.1, cy - s.height * 0.26)
      ..lineTo(cx - s.width * 0.14, cy + s.height * 0.02)
      ..lineTo(cx + s.width * 0.02, cy + s.height * 0.02)
      ..lineTo(cx - s.width * 0.1, cy + s.height * 0.26)
      ..lineTo(cx + s.width * 0.16, cy - s.height * 0.04)
      ..lineTo(cx, cy - s.height * 0.04)
      ..close();
    pt.color = col;
    cv.drawPath(path, pt);
    _engrave(cv, path, Color.lerp(col, Colors.white, 0.4)!, 0.8);
  }

  void _storm(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    // Cloud + bolt.
    pt.color = col;
    final cloudY = cy - s.height * 0.08;
    cv.drawCircle(Offset(cx - s.width * 0.12, cloudY), s.width * 0.1, pt);
    cv.drawCircle(Offset(cx + s.width * 0.12, cloudY), s.width * 0.1, pt);
    cv.drawCircle(Offset(cx, cloudY - s.height * 0.04), s.width * 0.12, pt);
    cv.drawRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cloudY + s.height * 0.03), width: s.width * 0.34, height: s.height * 0.08),
        Radius.circular(s.width * 0.04)), pt);
    final bolt = Path()
      ..moveTo(cx + s.width * 0.02, cy + s.height * 0.04)
      ..lineTo(cx - s.width * 0.08, cy + s.height * 0.16)
      ..lineTo(cx, cy + s.height * 0.16)
      ..lineTo(cx - s.width * 0.04, cy + s.height * 0.28);
    _engrave(cv, bolt, Color.lerp(col, Colors.white, 0.5)!, 1.4);
  }

  void _dagger(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    // Blade.
    final blade = Path()
      ..moveTo(cx, cy - s.height * 0.28)
      ..lineTo(cx + s.width * 0.07, cy + s.height * 0.06)
      ..lineTo(cx, cy + s.height * 0.12)
      ..lineTo(cx - s.width * 0.07, cy + s.height * 0.06)
      ..close();
    pt.color = col;
    cv.drawPath(blade, pt);
    pt.color = Colors.white.withValues(alpha: 0.45);
    cv.drawPath(Path()
      ..moveTo(cx, cy - s.height * 0.28)
      ..lineTo(cx + s.width * 0.02, cy + s.height * 0.04)
      ..lineTo(cx - s.width * 0.02, cy + s.height * 0.04)
      ..close(), pt);
    // Crossguard + hilt.
    pt.color = Color.lerp(col, Colors.black, 0.1)!;
    cv.drawRect(Rect.fromCenter(center: Offset(cx, cy + s.height * 0.13), width: s.width * 0.28, height: s.height * 0.045), pt);
    cv.drawRect(Rect.fromCenter(center: Offset(cx, cy + s.height * 0.22), width: s.width * 0.05, height: s.height * 0.14), pt);
  }

  void _mountain(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    final path = Path()
      ..moveTo(cx - s.width * 0.26, cy + s.height * 0.2)
      ..lineTo(cx - s.width * 0.06, cy - s.height * 0.06)
      ..lineTo(cx + s.width * 0.02, cy + s.height * 0.04)
      ..lineTo(cx + s.width * 0.12, cy - s.height * 0.22)
      ..lineTo(cx + s.width * 0.28, cy + s.height * 0.2)
      ..close();
    pt.color = col;
    cv.drawPath(path, pt);
    pt.color = Colors.white.withValues(alpha: 0.5);
    cv.drawPath(Path()
      ..moveTo(cx + s.width * 0.12, cy - s.height * 0.22)
      ..lineTo(cx + s.width * 0.05, cy - s.height * 0.08)
      ..lineTo(cx + s.width * 0.19, cy - s.height * 0.08)
      ..close(), pt);
  }

  // ── Fighter glyphs ────────────────────────────────────────────────────────
  void _shield(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    final path = Path()
      ..moveTo(cx, cy - s.height * 0.26)
      ..lineTo(cx + s.width * 0.22, cy - s.height * 0.16)
      ..lineTo(cx + s.width * 0.22, cy + s.height * 0.06)
      ..quadraticBezierTo(cx + s.width * 0.22, cy + s.height * 0.22, cx, cy + s.height * 0.28)
      ..quadraticBezierTo(cx - s.width * 0.22, cy + s.height * 0.22, cx - s.width * 0.22, cy + s.height * 0.06)
      ..lineTo(cx - s.width * 0.22, cy - s.height * 0.16)
      ..close();
    pt.color = Color.lerp(col, Colors.black, 0.12)!;
    cv.drawPath(path, pt);
    pt.color = Colors.white.withValues(alpha: 0.45);
    cv.drawPath(Path()
      ..moveTo(cx, cy - s.height * 0.26)
      ..lineTo(cx, cy + s.height * 0.28)
      ..moveTo(cx - s.width * 0.22, cy - s.height * 0.02)
      ..lineTo(cx + s.width * 0.22, cy - s.height * 0.02), pt..style = PaintingStyle.stroke..strokeWidth = 1);
    pt.style = PaintingStyle.fill;
  }

  void _swords(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    void blade(double sign) {
      final p = Path()
        ..moveTo(cx - sign * s.width * 0.24, cy - s.height * 0.24)
        ..lineTo(cx + sign * s.width * 0.2, cy + s.height * 0.22);
      _engrave(cv, p, col, 2.2);
      // hilt
      final h = Path()
        ..moveTo(cx - sign * s.width * 0.3, cy - s.height * 0.16)
        ..lineTo(cx - sign * s.width * 0.18, cy - s.height * 0.28);
      _engrave(cv, h, Color.lerp(col, Colors.black, 0.2)!, 1.6);
    }
    blade(1);
    blade(-1);
  }

  void _target(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt..style = PaintingStyle.stroke..strokeWidth = 1.6..color = col;
    cv.drawCircle(Offset(cx, cy), s.width * 0.24, pt);
    cv.drawCircle(Offset(cx, cy), s.width * 0.14, pt);
    pt.style = PaintingStyle.fill;
    cv.drawCircle(Offset(cx, cy), s.width * 0.05, pt);
  }

  void _crown(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    final path = Path()
      ..moveTo(cx - s.width * 0.24, cy + s.height * 0.16)
      ..lineTo(cx - s.width * 0.24, cy - s.height * 0.12)
      ..lineTo(cx - s.width * 0.1, cy + s.height * 0.02)
      ..lineTo(cx, cy - s.height * 0.2)
      ..lineTo(cx + s.width * 0.1, cy + s.height * 0.02)
      ..lineTo(cx + s.width * 0.24, cy - s.height * 0.12)
      ..lineTo(cx + s.width * 0.24, cy + s.height * 0.16)
      ..close();
    pt.color = col;
    cv.drawPath(path, pt);
    pt.color = Colors.white.withValues(alpha: 0.5);
    cv.drawCircle(Offset(cx, cy - s.height * 0.2), s.width * 0.03, pt);
  }

  void _trophy(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt.color = col;
    final cup = Path()
      ..moveTo(cx - s.width * 0.16, cy - s.height * 0.2)
      ..lineTo(cx + s.width * 0.16, cy - s.height * 0.2)
      ..lineTo(cx + s.width * 0.1, cy + s.height * 0.04)
      ..lineTo(cx - s.width * 0.1, cy + s.height * 0.04)
      ..close();
    cv.drawPath(cup, pt);
    // handles
    pt..style = PaintingStyle.stroke..strokeWidth = 1.4;
    cv.drawArc(Rect.fromCenter(center: Offset(cx - s.width * 0.16, cy - s.height * 0.12), width: s.width * 0.14, height: s.height * 0.16), -pi/2, -pi, false, pt);
    cv.drawArc(Rect.fromCenter(center: Offset(cx + s.width * 0.16, cy - s.height * 0.12), width: s.width * 0.14, height: s.height * 0.16), pi/2, pi, false, pt);
    pt.style = PaintingStyle.fill;
    cv.drawRect(Rect.fromCenter(center: Offset(cx, cy + s.height * 0.1), width: s.width * 0.06, height: s.height * 0.1), pt);
    cv.drawRect(Rect.fromCenter(center: Offset(cx, cy + s.height * 0.18), width: s.width * 0.22, height: s.height * 0.05), pt);
  }

  void _medal(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    // ribbon
    pt.color = Color.lerp(col, Colors.black, 0.2)!;
    cv.drawPath(Path()..moveTo(cx - s.width * 0.12, cy - s.height * 0.26)..lineTo(cx - s.width * 0.04, cy)..lineTo(cx - s.width * 0.16, cy)..close(), pt);
    cv.drawPath(Path()..moveTo(cx + s.width * 0.12, cy - s.height * 0.26)..lineTo(cx + s.width * 0.04, cy)..lineTo(cx + s.width * 0.16, cy)..close(), pt);
    pt.color = col;
    cv.drawCircle(Offset(cx, cy + s.height * 0.1), s.width * 0.16, pt);
    pt.color = Colors.white.withValues(alpha: 0.5);
    _star5(cv, pt, cx, cy + s.height * 0.1, Size(s.width * 0.5, s.height * 0.5), Colors.white.withValues(alpha: 0.7));
  }

  void _gear(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt.color = col;
    final r = s.width * 0.2;
    for (int i = 0; i < 8; i++) {
      final a = i * pi / 4;
      cv.drawRect(Rect.fromCenter(center: Offset(cx + r * cos(a), cy + r * sin(a)), width: s.width * 0.08, height: s.width * 0.08), pt);
    }
    cv.drawCircle(Offset(cx, cy), r, pt);
    pt.color = Colors.black.withValues(alpha: 0.55);
    cv.drawCircle(Offset(cx, cy), s.width * 0.08, pt);
  }

  // ── Rogue glyphs ──────────────────────────────────────────────────────────
  void _darkmoon(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt.color = Color.lerp(col, Colors.black, 0.15)!;
    cv.drawCircle(Offset(cx, cy), s.width * 0.22, pt);
    pt.color = Colors.white.withValues(alpha: 0.4);
    pt..style = PaintingStyle.stroke..strokeWidth = 1;
    cv.drawCircle(Offset(cx, cy), s.width * 0.22, pt);
    pt.style = PaintingStyle.fill;
    // crescent highlight
    pt.color = col;
    cv.drawCircle(Offset(cx + s.width * 0.06, cy - s.height * 0.05), s.width * 0.05, pt);
  }

  void _smoke(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt..style = PaintingStyle.stroke..strokeWidth = 2..strokeCap = StrokeCap.round..color = col;
    for (int i = 0; i < 3; i++) {
      final y = cy - s.height * 0.16 + i * s.height * 0.16;
      cv.drawPath(Path()
        ..moveTo(cx - s.width * 0.2, y)
        ..quadraticBezierTo(cx, y - s.height * 0.06, cx + s.width * 0.06, y)
        ..quadraticBezierTo(cx + s.width * 0.14, y + s.height * 0.05, cx + s.width * 0.22, y), pt);
    }
    pt.style = PaintingStyle.fill;
  }

  void _poison(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    // skull + crossbones
    _skull(cv, pt, cx, cy - s.height * 0.06, Size(s.width * 0.82, s.height * 0.82), col);
    pt..style = PaintingStyle.stroke..strokeWidth = 2..color = Color.lerp(col, Colors.black, 0.1)!;
    cv.drawLine(Offset(cx - s.width * 0.18, cy + s.height * 0.14), Offset(cx + s.width * 0.18, cy + s.height * 0.24), pt);
    cv.drawLine(Offset(cx + s.width * 0.18, cy + s.height * 0.14), Offset(cx - s.width * 0.18, cy + s.height * 0.24), pt);
    pt.style = PaintingStyle.fill;
  }

  void _card(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    final rr = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy), width: s.width * 0.32, height: s.height * 0.44), const Radius.circular(3));
    pt.color = col;
    cv.drawRRect(rr, pt);
    pt.color = Colors.black.withValues(alpha: 0.6);
    // diamond pip
    cv.drawPath(Path()
      ..moveTo(cx, cy - s.height * 0.1)..lineTo(cx + s.width * 0.07, cy)..lineTo(cx, cy + s.height * 0.1)..lineTo(cx - s.width * 0.07, cy)..close(), pt);
  }

  void _ghost(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt.color = col;
    final body = Path()
      ..moveTo(cx - s.width * 0.18, cy + s.height * 0.22)
      ..lineTo(cx - s.width * 0.18, cy - s.height * 0.02)
      ..arcToPoint(Offset(cx + s.width * 0.18, cy - s.height * 0.02), radius: Radius.circular(s.width * 0.18))
      ..lineTo(cx + s.width * 0.18, cy + s.height * 0.22)
      ..lineTo(cx + s.width * 0.09, cy + s.height * 0.14)
      ..lineTo(cx, cy + s.height * 0.22)
      ..lineTo(cx - s.width * 0.09, cy + s.height * 0.14)
      ..close();
    cv.drawPath(body, pt);
    final eye = Paint()..color = Colors.black.withValues(alpha: 0.7)..isAntiAlias = true;
    cv.drawCircle(Offset(cx - s.width * 0.06, cy - s.height * 0.02), s.width * 0.03, eye);
    cv.drawCircle(Offset(cx + s.width * 0.06, cy - s.height * 0.02), s.width * 0.03, eye);
  }

  void _moon(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt.color = col;
    final p = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: s.width * 0.22))
      ..addOval(Rect.fromCircle(center: Offset(cx + s.width * 0.1, cy - s.height * 0.04), radius: s.width * 0.2))
      ..fillType = PathFillType.evenOdd;
    cv.drawPath(p, pt);
  }

  // ── Ranger glyphs ─────────────────────────────────────────────────────────
  void _bow(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt..style = PaintingStyle.stroke..strokeWidth = 2..color = col;
    cv.drawArc(Rect.fromCenter(center: Offset(cx - s.width * 0.04, cy), width: s.width * 0.4, height: s.height * 0.5), -pi/2.4, pi/1.2, false, pt);
    cv.drawLine(Offset(cx - s.width * 0.1, cy - s.height * 0.24), Offset(cx - s.width * 0.1, cy + s.height * 0.24), pt);
    pt.style = PaintingStyle.fill;
    // arrow
    final arr = Path()..moveTo(cx - s.width * 0.14, cy)..lineTo(cx + s.width * 0.22, cy);
    _engrave(cv, arr, Color.lerp(col, Colors.white, 0.3)!, 1.4);
    cv.drawPath(Path()..moveTo(cx + s.width * 0.22, cy)..lineTo(cx + s.width * 0.14, cy - s.height * 0.05)..lineTo(cx + s.width * 0.14, cy + s.height * 0.05)..close(), pt..color = col);
  }

  void _leaf(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    final path = Path()
      ..moveTo(cx - s.width * 0.16, cy + s.height * 0.2)
      ..quadraticBezierTo(cx - s.width * 0.24, cy - s.height * 0.2, cx + s.width * 0.16, cy - s.height * 0.2)
      ..quadraticBezierTo(cx + s.width * 0.24, cy + s.height * 0.2, cx - s.width * 0.16, cy + s.height * 0.2);
    pt.color = col;
    cv.drawPath(path, pt);
    pt..color = Colors.black.withValues(alpha: 0.4)..style = PaintingStyle.stroke..strokeWidth = 1.2;
    cv.drawLine(Offset(cx - s.width * 0.12, cy + s.height * 0.16), Offset(cx + s.width * 0.12, cy - s.height * 0.16), pt);
    pt.style = PaintingStyle.fill;
  }

  void _bird(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    // simple gull/dove — two arcs
    pt..style = PaintingStyle.stroke..strokeWidth = 2.4..strokeCap = StrokeCap.round..color = col;
    cv.drawPath(Path()
      ..moveTo(cx - s.width * 0.24, cy + s.height * 0.02)
      ..quadraticBezierTo(cx - s.width * 0.1, cy - s.height * 0.18, cx, cy)
      ..quadraticBezierTo(cx + s.width * 0.1, cy - s.height * 0.18, cx + s.width * 0.24, cy + s.height * 0.02), pt);
    pt.style = PaintingStyle.fill;
  }

  void _trap(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt..style = PaintingStyle.stroke..strokeWidth = 1.8..color = col;
    // two jaws
    cv.drawArc(Rect.fromCenter(center: Offset(cx, cy - s.height * 0.02), width: s.width * 0.44, height: s.height * 0.3), pi, pi, false, pt);
    cv.drawArc(Rect.fromCenter(center: Offset(cx, cy + s.height * 0.02), width: s.width * 0.44, height: s.height * 0.3), 0, pi, false, pt);
    pt.style = PaintingStyle.fill;
    // teeth
    for (int i = -2; i <= 2; i++) {
      cv.drawCircle(Offset(cx + i * s.width * 0.08, cy), s.width * 0.015, pt);
    }
  }

  void _wolf(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt.color = col;
    final head = Path()
      ..moveTo(cx, cy + s.height * 0.24)
      ..lineTo(cx - s.width * 0.2, cy + s.height * 0.02)
      ..lineTo(cx - s.width * 0.24, cy - s.height * 0.24)
      ..lineTo(cx - s.width * 0.08, cy - s.height * 0.08)
      ..lineTo(cx + s.width * 0.08, cy - s.height * 0.08)
      ..lineTo(cx + s.width * 0.24, cy - s.height * 0.24)
      ..lineTo(cx + s.width * 0.2, cy + s.height * 0.02)
      ..close();
    cv.drawPath(head, pt);
    final eye = Paint()..color = Colors.black.withValues(alpha: 0.7)..isAntiAlias = true;
    cv.drawCircle(Offset(cx - s.width * 0.08, cy + s.height * 0.02), s.width * 0.025, eye);
    cv.drawCircle(Offset(cx + s.width * 0.08, cy + s.height * 0.02), s.width * 0.025, eye);
  }

  void _rain(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt.color = col;
    final cloudY = cy - s.height * 0.08;
    cv.drawCircle(Offset(cx - s.width * 0.1, cloudY), s.width * 0.09, pt);
    cv.drawCircle(Offset(cx + s.width * 0.1, cloudY), s.width * 0.09, pt);
    cv.drawCircle(Offset(cx, cloudY - s.height * 0.03), s.width * 0.11, pt);
    cv.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cloudY + s.height * 0.03), width: s.width * 0.3, height: s.height * 0.07), Radius.circular(s.width * 0.03)), pt);
    pt..style = PaintingStyle.stroke..strokeWidth = 1.6..strokeCap = StrokeCap.round;
    for (int i = -1; i <= 1; i++) {
      final x = cx + i * s.width * 0.12;
      cv.drawLine(Offset(x, cy + s.height * 0.1), Offset(x - s.width * 0.03, cy + s.height * 0.24), pt);
    }
    pt.style = PaintingStyle.fill;
  }

  void _eye(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt.color = col;
    final outer = Path()
      ..moveTo(cx - s.width * 0.24, cy)
      ..quadraticBezierTo(cx, cy - s.height * 0.2, cx + s.width * 0.24, cy)
      ..quadraticBezierTo(cx, cy + s.height * 0.2, cx - s.width * 0.24, cy);
    cv.drawPath(outer, pt);
    pt.color = Colors.black.withValues(alpha: 0.75);
    cv.drawCircle(Offset(cx, cy), s.width * 0.08, pt);
  }

  // ── Holy glyphs (Paladin / Cleric) ────────────────────────────────────────
  void _star4(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt.color = col;
    cv.drawPath(Path()
      ..moveTo(cx, cy - s.height * 0.26)
      ..lineTo(cx + s.width * 0.07, cy - s.height * 0.06)
      ..lineTo(cx + s.width * 0.26, cy)
      ..lineTo(cx + s.width * 0.07, cy + s.height * 0.06)
      ..lineTo(cx, cy + s.height * 0.26)
      ..lineTo(cx - s.width * 0.07, cy + s.height * 0.06)
      ..lineTo(cx - s.width * 0.26, cy)
      ..lineTo(cx - s.width * 0.07, cy - s.height * 0.06)
      ..close(), pt);
    pt.color = Colors.white.withValues(alpha: 0.5);
    cv.drawCircle(Offset(cx, cy), s.width * 0.04, pt);
  }

  void _heart(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    final path = Path()
      ..moveTo(cx, cy + s.height * 0.24)
      ..cubicTo(cx - s.width * 0.3, cy + s.height * 0.02, cx - s.width * 0.18, cy - s.height * 0.24, cx, cy - s.height * 0.06)
      ..cubicTo(cx + s.width * 0.18, cy - s.height * 0.24, cx + s.width * 0.3, cy + s.height * 0.02, cx, cy + s.height * 0.24);
    pt.color = col;
    cv.drawPath(path, pt);
    pt.color = Colors.white.withValues(alpha: 0.5);
    cv.drawCircle(Offset(cx - s.width * 0.08, cy - s.height * 0.04), s.width * 0.035, pt);
  }

  void _sparkle(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    _star4(cv, pt, cx, cy - s.height * 0.02, Size(s.width * 0.8, s.height * 0.8), col);
    pt.color = col;
    _star4(cv, pt, cx + s.width * 0.2, cy + s.height * 0.18, Size(s.width * 0.4, s.height * 0.4), col);
    _star4(cv, pt, cx - s.width * 0.2, cy + s.height * 0.16, Size(s.width * 0.34, s.height * 0.34), col);
  }

  void _sun(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt..style = PaintingStyle.stroke..strokeWidth = 1.8..strokeCap = StrokeCap.round..color = col;
    for (int i = 0; i < 8; i++) {
      final a = i * pi / 4;
      cv.drawLine(Offset(cx + s.width * 0.18 * cos(a), cy + s.width * 0.18 * sin(a)),
          Offset(cx + s.width * 0.26 * cos(a), cy + s.width * 0.26 * sin(a)), pt);
    }
    pt.style = PaintingStyle.fill;
    cv.drawCircle(Offset(cx, cy), s.width * 0.13, pt);
  }

  void _cross(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt.color = col;
    cv.drawRect(Rect.fromCenter(center: Offset(cx, cy), width: s.width * 0.1, height: s.height * 0.5), pt);
    cv.drawRect(Rect.fromCenter(center: Offset(cx, cy - s.height * 0.06), width: s.width * 0.3, height: s.height * 0.1), pt);
    pt.color = Colors.white.withValues(alpha: 0.4);
    cv.drawRect(Rect.fromCenter(center: Offset(cx - s.width * 0.02, cy), width: s.width * 0.03, height: s.height * 0.4), pt);
  }

  void _star5(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    final path = Path();
    final r = s.width * 0.26;
    for (int i = 0; i < 5; i++) {
      final oa = -pi / 2 + i * 2 * pi / 5;
      final ia = oa + pi / 5;
      final ox = cx + r * cos(oa), oy = cy + r * sin(oa);
      final ix = cx + r * 0.42 * cos(ia), iy = cy + r * 0.42 * sin(ia);
      if (i == 0) { path.moveTo(ox, oy); } else { path.lineTo(ox, oy); }
      path.lineTo(ix, iy);
    }
    path.close();
    pt.color = col;
    cv.drawPath(path, pt);
  }

  void _castle(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt.color = col;
    // battlement wall
    cv.drawRect(Rect.fromCenter(center: Offset(cx, cy + s.height * 0.08), width: s.width * 0.44, height: s.height * 0.28), pt);
    for (int i = -2; i <= 2; i++) {
      if (i.isEven) {
        cv.drawRect(Rect.fromCenter(center: Offset(cx + i * s.width * 0.1, cy - s.height * 0.12), width: s.width * 0.08, height: s.height * 0.1), pt);
      }
    }
    // gate
    pt.color = Colors.black.withValues(alpha: 0.6);
    cv.drawRRect(RRect.fromRectAndCorners(Rect.fromCenter(center: Offset(cx, cy + s.height * 0.14), width: s.width * 0.12, height: s.height * 0.16), topLeft: const Radius.circular(4), topRight: const Radius.circular(4)), pt);
  }

  void _angel(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    // halo
    pt..style = PaintingStyle.stroke..strokeWidth = 1.6..color = col;
    cv.drawCircle(Offset(cx, cy - s.height * 0.16), s.width * 0.09, pt);
    pt.style = PaintingStyle.fill;
    // head
    cv.drawCircle(Offset(cx, cy - s.height * 0.02), s.width * 0.08, pt);
    // wings
    cv.drawPath(Path()
      ..moveTo(cx, cy + s.height * 0.02)
      ..quadraticBezierTo(cx - s.width * 0.26, cy - s.height * 0.02, cx - s.width * 0.24, cy + s.height * 0.22)
      ..quadraticBezierTo(cx - s.width * 0.1, cy + s.height * 0.06, cx, cy + s.height * 0.1), pt);
    cv.drawPath(Path()
      ..moveTo(cx, cy + s.height * 0.02)
      ..quadraticBezierTo(cx + s.width * 0.26, cy - s.height * 0.02, cx + s.width * 0.24, cy + s.height * 0.22)
      ..quadraticBezierTo(cx + s.width * 0.1, cy + s.height * 0.06, cx, cy + s.height * 0.1), pt);
  }

  // ── Wizard glyphs ─────────────────────────────────────────────────────────
  void _frost(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt..style = PaintingStyle.stroke..strokeWidth = 1.6..strokeCap = StrokeCap.round..color = col;
    final r = s.width * 0.24;
    for (int i = 0; i < 6; i++) {
      final a = i * pi / 3;
      final ex = cx + r * cos(a), ey = cy + r * sin(a);
      cv.drawLine(Offset(cx, cy), Offset(ex, ey), pt);
      // barbs
      final bx = cx + r * 0.6 * cos(a), by = cy + r * 0.6 * sin(a);
      cv.drawLine(Offset(bx, by), Offset(bx + r * 0.22 * cos(a + 0.9), by + r * 0.22 * sin(a + 0.9)), pt);
      cv.drawLine(Offset(bx, by), Offset(bx + r * 0.22 * cos(a - 0.9), by + r * 0.22 * sin(a - 0.9)), pt);
    }
    pt.style = PaintingStyle.fill;
  }

  void _crystal(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    final path = Path()
      ..moveTo(cx, cy - s.height * 0.26)
      ..lineTo(cx + s.width * 0.16, cy - s.height * 0.08)
      ..lineTo(cx + s.width * 0.1, cy + s.height * 0.24)
      ..lineTo(cx - s.width * 0.1, cy + s.height * 0.24)
      ..lineTo(cx - s.width * 0.16, cy - s.height * 0.08)
      ..close();
    pt.color = Color.lerp(col, Colors.black, 0.12)!;
    cv.drawPath(path, pt);
    pt.color = Colors.white.withValues(alpha: 0.4);
    cv.drawPath(Path()..moveTo(cx, cy - s.height * 0.26)..lineTo(cx - s.width * 0.03, cy + s.height * 0.24)..lineTo(cx - s.width * 0.16, cy - s.height * 0.08)..close(), pt);
  }

  void _burst(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt.color = col;
    final path = Path();
    final r = s.width * 0.26;
    for (int i = 0; i < 10; i++) {
      final a = -pi / 2 + i * pi / 5;
      final rr = i.isEven ? r : r * 0.42;
      final x = cx + rr * cos(a), y = cy + rr * sin(a);
      if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
    }
    path.close();
    cv.drawPath(path, pt);
    pt.color = Colors.white.withValues(alpha: 0.5);
    cv.drawCircle(Offset(cx, cy), s.width * 0.05, pt);
  }

  void _hourglass(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt.color = col;
    cv.drawPath(Path()
      ..moveTo(cx - s.width * 0.16, cy - s.height * 0.22)
      ..lineTo(cx + s.width * 0.16, cy - s.height * 0.22)
      ..lineTo(cx, cy)
      ..close(), pt);
    cv.drawPath(Path()
      ..moveTo(cx - s.width * 0.16, cy + s.height * 0.22)
      ..lineTo(cx + s.width * 0.16, cy + s.height * 0.22)
      ..lineTo(cx, cy)
      ..close(), pt);
    pt..style = PaintingStyle.stroke..strokeWidth = 2..color = Color.lerp(col, Colors.black, 0.1)!;
    cv.drawLine(Offset(cx - s.width * 0.18, cy - s.height * 0.24), Offset(cx + s.width * 0.18, cy - s.height * 0.24), pt);
    cv.drawLine(Offset(cx - s.width * 0.18, cy + s.height * 0.24), Offset(cx + s.width * 0.18, cy + s.height * 0.24), pt);
    pt.style = PaintingStyle.fill;
  }

  void _comet(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt..style = PaintingStyle.stroke..strokeWidth = 2..strokeCap = StrokeCap.round..color = col.withValues(alpha: 0.6);
    cv.drawLine(Offset(cx - s.width * 0.24, cy - s.height * 0.24), Offset(cx + s.width * 0.06, cy + s.height * 0.06), pt);
    cv.drawLine(Offset(cx - s.width * 0.1, cy - s.height * 0.24), Offset(cx + s.width * 0.1, cy - s.height * 0.02), pt);
    pt.style = PaintingStyle.fill;
    pt.color = col;
    cv.drawCircle(Offset(cx + s.width * 0.12, cy + s.height * 0.12), s.width * 0.1, pt);
    pt.color = Colors.white.withValues(alpha: 0.6);
    cv.drawCircle(Offset(cx + s.width * 0.09, cy + s.height * 0.09), s.width * 0.03, pt);
  }

  void _orb(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt.color = Color.lerp(col, Colors.black, 0.15)!;
    cv.drawCircle(Offset(cx, cy), s.width * 0.22, pt);
    pt.color = col;
    cv.drawCircle(Offset(cx, cy), s.width * 0.17, pt);
    pt.color = Colors.white.withValues(alpha: 0.55);
    cv.drawCircle(Offset(cx - s.width * 0.06, cy - s.height * 0.06), s.width * 0.05, pt);
  }

  // ── Sorcerer glyphs ───────────────────────────────────────────────────────
  void _swirl(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt..style = PaintingStyle.stroke..strokeWidth = 2..strokeCap = StrokeCap.round..color = col;
    final path = Path();
    for (double t = 0; t < 3.2 * pi; t += 0.2) {
      final r = s.width * 0.03 + t * s.width * 0.024;
      final x = cx + r * cos(t), y = cy + r * sin(t);
      if (t == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
    }
    cv.drawPath(path, pt);
    pt.style = PaintingStyle.fill;
  }

  void _virus(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt..style = PaintingStyle.stroke..strokeWidth = 1.6..strokeCap = StrokeCap.round..color = col;
    final r = s.width * 0.15;
    for (int i = 0; i < 8; i++) {
      final a = i * pi / 4;
      cv.drawLine(Offset(cx + r * cos(a), cy + r * sin(a)), Offset(cx + (r + s.width * 0.08) * cos(a), cy + (r + s.width * 0.08) * sin(a)), pt);
      cv.drawCircle(Offset(cx + (r + s.width * 0.08) * cos(a), cy + (r + s.width * 0.08) * sin(a)), s.width * 0.02, pt..style = PaintingStyle.fill);
      pt.style = PaintingStyle.stroke;
    }
    cv.drawCircle(Offset(cx, cy), r, pt);
    pt.style = PaintingStyle.fill;
    cv.drawCircle(Offset(cx - s.width * 0.04, cy - s.height * 0.03), s.width * 0.03, pt);
  }

  void _fear(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt.color = col;
    cv.drawCircle(Offset(cx, cy), s.width * 0.22, pt);
    final dk = Paint()..color = Colors.black.withValues(alpha: 0.7)..isAntiAlias = true;
    cv.drawOval(Rect.fromCenter(center: Offset(cx - s.width * 0.08, cy - s.height * 0.04), width: s.width * 0.06, height: s.height * 0.09), dk);
    cv.drawOval(Rect.fromCenter(center: Offset(cx + s.width * 0.08, cy - s.height * 0.04), width: s.width * 0.06, height: s.height * 0.09), dk);
    cv.drawOval(Rect.fromCenter(center: Offset(cx, cy + s.height * 0.1), width: s.width * 0.08, height: s.height * 0.1), dk);
  }

  void _mask(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt.color = col;
    final face = Path()
      ..moveTo(cx - s.width * 0.2, cy - s.height * 0.18)
      ..lineTo(cx + s.width * 0.2, cy - s.height * 0.18)
      ..quadraticBezierTo(cx + s.width * 0.16, cy + s.height * 0.24, cx, cy + s.height * 0.26)
      ..quadraticBezierTo(cx - s.width * 0.16, cy + s.height * 0.24, cx - s.width * 0.2, cy - s.height * 0.18);
    cv.drawPath(face, pt);
    final dk = Paint()..color = Colors.black.withValues(alpha: 0.65)..isAntiAlias = true;
    // one eye happy (^) one sad — theatre
    dk..style = PaintingStyle.stroke..strokeWidth = 1.6..strokeCap = StrokeCap.round;
    cv.drawArc(Rect.fromCenter(center: Offset(cx - s.width * 0.08, cy - s.height * 0.02), width: s.width * 0.1, height: s.height * 0.08), pi, pi, false, dk);
    cv.drawArc(Rect.fromCenter(center: Offset(cx + s.width * 0.08, cy - s.height * 0.02), width: s.width * 0.1, height: s.height * 0.08), 0, pi, false, dk);
  }

  // ── Warlock glyphs ────────────────────────────────────────────────────────
  void _chain(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt..style = PaintingStyle.stroke..strokeWidth = 2.2..color = col;
    cv.drawOval(Rect.fromCenter(center: Offset(cx - s.width * 0.12, cy - s.height * 0.1), width: s.width * 0.18, height: s.height * 0.14), pt);
    cv.drawOval(Rect.fromCenter(center: Offset(cx + s.width * 0.02, cy + s.height * 0.02), width: s.width * 0.18, height: s.height * 0.14), pt);
    cv.drawOval(Rect.fromCenter(center: Offset(cx + s.width * 0.16, cy + s.height * 0.14), width: s.width * 0.18, height: s.height * 0.14), pt);
    pt.style = PaintingStyle.fill;
  }

  void _scroll(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt.color = col;
    cv.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy), width: s.width * 0.34, height: s.height * 0.4), const Radius.circular(2)), pt);
    pt.color = Color.lerp(col, Colors.black, 0.25)!;
    cv.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy - s.height * 0.2), width: s.width * 0.4, height: s.height * 0.08), const Radius.circular(4)), pt);
    cv.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy + s.height * 0.2), width: s.width * 0.4, height: s.height * 0.08), const Radius.circular(4)), pt);
    pt..color = Colors.black.withValues(alpha: 0.4)..style = PaintingStyle.stroke..strokeWidth = 1;
    for (int i = -1; i <= 1; i++) {
      cv.drawLine(Offset(cx - s.width * 0.1, cy + i * s.height * 0.06), Offset(cx + s.width * 0.1, cy + i * s.height * 0.06), pt);
    }
    pt.style = PaintingStyle.fill;
  }

  // ── Bard glyphs ───────────────────────────────────────────────────────────
  void _note(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt..style = PaintingStyle.stroke..strokeWidth = 2.4..color = col;
    cv.drawLine(Offset(cx + s.width * 0.1, cy - s.height * 0.22), Offset(cx + s.width * 0.1, cy + s.height * 0.14), pt);
    cv.drawLine(Offset(cx - s.width * 0.12, cy - s.height * 0.18), Offset(cx - s.width * 0.12, cy + s.height * 0.08), pt);
    cv.drawLine(Offset(cx - s.width * 0.12, cy - s.height * 0.2), Offset(cx + s.width * 0.1, cy - s.height * 0.24), pt);
    pt.style = PaintingStyle.fill;
    cv.drawOval(Rect.fromCenter(center: Offset(cx - s.width * 0.16, cy + s.height * 0.1), width: s.width * 0.12, height: s.height * 0.09), pt);
    cv.drawOval(Rect.fromCenter(center: Offset(cx + s.width * 0.06, cy + s.height * 0.16), width: s.width * 0.12, height: s.height * 0.09), pt);
  }

  void _horn(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt.color = col;
    final path = Path()
      ..moveTo(cx - s.width * 0.22, cy - s.height * 0.06)
      ..lineTo(cx + s.width * 0.06, cy - s.height * 0.16)
      ..lineTo(cx + s.width * 0.22, cy - s.height * 0.24)
      ..lineTo(cx + s.width * 0.22, cy + s.height * 0.06)
      ..lineTo(cx + s.width * 0.06, cy - s.height * 0.02)
      ..lineTo(cx - s.width * 0.22, cy + s.height * 0.06)
      ..close();
    cv.drawPath(path, pt);
    pt.color = Colors.white.withValues(alpha: 0.4);
    cv.drawCircle(Offset(cx - s.width * 0.1, cy), s.width * 0.03, pt);
  }

  void _violin(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt.color = col;
    cv.drawCircle(Offset(cx, cy - s.height * 0.06), s.width * 0.12, pt);
    cv.drawCircle(Offset(cx, cy + s.height * 0.12), s.width * 0.15, pt);
    pt.color = Color.lerp(col, Colors.black, 0.2)!;
    cv.drawRect(Rect.fromCenter(center: Offset(cx, cy + s.height * 0.02), width: s.width * 0.14, height: s.height * 0.12), pt);
    pt..color = Colors.black.withValues(alpha: 0.5)..style = PaintingStyle.stroke..strokeWidth = 1.4;
    cv.drawLine(Offset(cx, cy - s.height * 0.2), Offset(cx, cy + s.height * 0.24), pt);
    pt.style = PaintingStyle.fill;
  }

  // ── Monk glyphs ───────────────────────────────────────────────────────────
  void _yinyang(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    final r = s.width * 0.22;
    pt.color = col;
    cv.drawCircle(Offset(cx, cy), r, pt);
    pt.color = Colors.black.withValues(alpha: 0.7);
    cv.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), -pi / 2, pi, false, pt);
    cv.drawCircle(Offset(cx, cy - r / 2), r / 2, pt);
    pt.color = col;
    cv.drawCircle(Offset(cx, cy + r / 2), r / 2, pt);
    cv.drawCircle(Offset(cx, cy - r / 2), r * 0.16, pt);
    pt.color = Colors.black.withValues(alpha: 0.7);
    cv.drawCircle(Offset(cx, cy + r / 2), r * 0.16, pt);
  }

  void _lotus(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt.color = col;
    for (int i = -2; i <= 2; i++) {
      final ang = i * 0.5;
      final petal = Path()
        ..moveTo(cx, cy + s.height * 0.16)
        ..quadraticBezierTo(cx + s.width * 0.16 * sin(ang) - s.width * 0.08 * cos(ang), cy - s.height * 0.1,
            cx + s.width * 0.3 * sin(ang), cy - s.height * 0.02 - s.height * 0.06 * cos(ang))
        ..quadraticBezierTo(cx + s.width * 0.16 * sin(ang) + s.width * 0.08 * cos(ang), cy - s.height * 0.1,
            cx, cy + s.height * 0.16);
      pt.color = i == 0 ? col : Color.lerp(col, Colors.black, 0.12 + i.abs() * 0.05)!;
      cv.drawPath(petal, pt);
    }
  }

  void _fist(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt.color = col;
    cv.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy + s.height * 0.02), width: s.width * 0.34, height: s.height * 0.3), Radius.circular(s.width * 0.06)), pt);
    pt.color = Color.lerp(col, Colors.black, 0.2)!;
    for (int i = -1; i <= 2; i++) {
      cv.drawLine(Offset(cx - s.width * 0.1 + i * s.width * 0.08, cy - s.height * 0.1), Offset(cx - s.width * 0.1 + i * s.width * 0.08, cy - s.height * 0.02), pt..style = PaintingStyle.stroke..strokeWidth = 1.4);
    }
    pt.style = PaintingStyle.fill;
    // thumb
    cv.drawCircle(Offset(cx - s.width * 0.2, cy), s.width * 0.05, pt);
  }

  void _dragon(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt.color = col;
    // stylised dragon head
    final head = Path()
      ..moveTo(cx - s.width * 0.22, cy + s.height * 0.1)
      ..lineTo(cx - s.width * 0.06, cy + s.height * 0.16)
      ..lineTo(cx + s.width * 0.22, cy + s.height * 0.06)
      ..lineTo(cx + s.width * 0.1, cy - s.height * 0.02)
      ..lineTo(cx + s.width * 0.18, cy - s.height * 0.12)
      ..lineTo(cx, cy - s.height * 0.08)
      ..lineTo(cx - s.width * 0.06, cy - s.height * 0.22)
      ..lineTo(cx - s.width * 0.14, cy - s.height * 0.06)
      ..close();
    cv.drawPath(head, pt);
    final dk = Paint()..color = Colors.black.withValues(alpha: 0.7)..isAntiAlias = true;
    cv.drawCircle(Offset(cx + s.width * 0.02, cy), s.width * 0.025, dk);
  }

  void _scales(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt..style = PaintingStyle.stroke..strokeWidth = 2..color = col;
    cv.drawLine(Offset(cx, cy - s.height * 0.22), Offset(cx, cy + s.height * 0.22), pt); // post
    cv.drawLine(Offset(cx - s.width * 0.2, cy - s.height * 0.14), Offset(cx + s.width * 0.2, cy - s.height * 0.14), pt); // beam
    cv.drawLine(Offset(cx - s.width * 0.16, cy + s.height * 0.22), Offset(cx + s.width * 0.16, cy + s.height * 0.22), pt); // base
    pt.style = PaintingStyle.fill;
    // pans
    cv.drawArc(Rect.fromCenter(center: Offset(cx - s.width * 0.2, cy - s.height * 0.02), width: s.width * 0.2, height: s.height * 0.12), 0, pi, false, pt);
    cv.drawArc(Rect.fromCenter(center: Offset(cx + s.width * 0.2, cy - s.height * 0.02), width: s.width * 0.2, height: s.height * 0.12), 0, pi, false, pt);
  }

  void _gi(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt.color = col;
    // crossed robe lapels
    cv.drawPath(Path()
      ..moveTo(cx - s.width * 0.2, cy - s.height * 0.2)
      ..lineTo(cx, cy - s.height * 0.06)
      ..lineTo(cx + s.width * 0.2, cy - s.height * 0.2)
      ..lineTo(cx + s.width * 0.22, cy + s.height * 0.22)
      ..lineTo(cx - s.width * 0.22, cy + s.height * 0.22)
      ..close(), pt);
    // belt
    pt.color = Color.lerp(col, Colors.black, 0.3)!;
    cv.drawRect(Rect.fromCenter(center: Offset(cx, cy + s.height * 0.06), width: s.width * 0.46, height: s.height * 0.08), pt);
    pt.color = Colors.black.withValues(alpha: 0.5);
    cv.drawPath(Path()..moveTo(cx, cy - s.height * 0.06)..lineTo(cx, cy + s.height * 0.02), pt..style = PaintingStyle.stroke..strokeWidth = 1.4);
    pt.style = PaintingStyle.fill;
  }

  // ── Druid glyphs ──────────────────────────────────────────────────────────
  void _sprout(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt..style = PaintingStyle.stroke..strokeWidth = 2..color = col;
    cv.drawLine(Offset(cx, cy + s.height * 0.24), Offset(cx, cy - s.height * 0.02), pt);
    pt.style = PaintingStyle.fill;
    // two leaves
    cv.drawPath(Path()
      ..moveTo(cx, cy + s.height * 0.04)
      ..quadraticBezierTo(cx - s.width * 0.24, cy - s.height * 0.04, cx - s.width * 0.06, cy - s.height * 0.18)
      ..quadraticBezierTo(cx - s.width * 0.02, cy - s.height * 0.04, cx, cy + s.height * 0.04), pt);
    cv.drawPath(Path()
      ..moveTo(cx, cy + s.height * 0.02)
      ..quadraticBezierTo(cx + s.width * 0.24, cy - s.height * 0.08, cx + s.width * 0.08, cy - s.height * 0.22)
      ..quadraticBezierTo(cx + s.width * 0.02, cy - s.height * 0.06, cx, cy + s.height * 0.02), pt);
  }

  void _tree(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt.color = Color.lerp(col, Colors.black, 0.3)!;
    cv.drawRect(Rect.fromCenter(center: Offset(cx, cy + s.height * 0.16), width: s.width * 0.08, height: s.height * 0.2), pt);
    pt.color = col;
    cv.drawCircle(Offset(cx, cy - s.height * 0.08), s.width * 0.16, pt);
    cv.drawCircle(Offset(cx - s.width * 0.14, cy + s.height * 0.02), s.width * 0.11, pt);
    cv.drawCircle(Offset(cx + s.width * 0.14, cy + s.height * 0.02), s.width * 0.11, pt);
    pt.color = Colors.white.withValues(alpha: 0.35);
    cv.drawCircle(Offset(cx - s.width * 0.04, cy - s.height * 0.12), s.width * 0.04, pt);
  }

  void _bear(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt.color = col;
    cv.drawCircle(Offset(cx, cy + s.height * 0.02), s.width * 0.2, pt); // head
    cv.drawCircle(Offset(cx - s.width * 0.16, cy - s.height * 0.16), s.width * 0.08, pt); // ears
    cv.drawCircle(Offset(cx + s.width * 0.16, cy - s.height * 0.16), s.width * 0.08, pt);
    final dk = Paint()..color = Colors.black.withValues(alpha: 0.7)..isAntiAlias = true;
    cv.drawCircle(Offset(cx - s.width * 0.07, cy - s.height * 0.02), s.width * 0.025, dk);
    cv.drawCircle(Offset(cx + s.width * 0.07, cy - s.height * 0.02), s.width * 0.025, dk);
    cv.drawCircle(Offset(cx, cy + s.height * 0.08), s.width * 0.035, dk);
  }

  void _lion(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    // mane
    pt.color = Color.lerp(col, Colors.black, 0.18)!;
    for (int i = 0; i < 10; i++) {
      final a = i * pi / 5;
      cv.drawCircle(Offset(cx + s.width * 0.2 * cos(a), cy + s.width * 0.2 * sin(a)), s.width * 0.07, pt);
    }
    pt.color = col;
    cv.drawCircle(Offset(cx, cy), s.width * 0.16, pt); // face
    final dk = Paint()..color = Colors.black.withValues(alpha: 0.7)..isAntiAlias = true;
    cv.drawCircle(Offset(cx - s.width * 0.06, cy - s.height * 0.02), s.width * 0.02, dk);
    cv.drawCircle(Offset(cx + s.width * 0.06, cy - s.height * 0.02), s.width * 0.02, dk);
    cv.drawCircle(Offset(cx, cy + s.height * 0.06), s.width * 0.03, dk);
  }

  void _globe(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    pt.color = col;
    cv.drawCircle(Offset(cx, cy), s.width * 0.22, pt);
    pt..color = Colors.black.withValues(alpha: 0.4)..style = PaintingStyle.stroke..strokeWidth = 1.2;
    cv.drawCircle(Offset(cx, cy), s.width * 0.22, pt);
    cv.drawLine(Offset(cx - s.width * 0.22, cy), Offset(cx + s.width * 0.22, cy), pt);
    cv.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: s.width * 0.2, height: s.height * 0.44), pt);
    cv.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: s.width * 0.4, height: s.height * 0.44), pt);
    pt.style = PaintingStyle.fill;
  }

  // ── Default fallback glyph — an angular Elder-Futhark-style mark ───────────
  void _defaultRune(Canvas cv, Paint pt, double cx, double cy, Size s, Color col) {
    final path = Path()
      ..moveTo(cx - s.width * 0.12, cy - s.height * 0.24)
      ..lineTo(cx - s.width * 0.12, cy + s.height * 0.24)
      ..moveTo(cx - s.width * 0.12, cy - s.height * 0.24)
      ..lineTo(cx + s.width * 0.14, cy - s.height * 0.02)
      ..moveTo(cx + s.width * 0.14, cy - s.height * 0.24)
      ..lineTo(cx - s.width * 0.12, cy + s.height * 0.02);
    _engrave(cv, path, col, 1.6);
  }

  @override
  bool shouldRepaint(covariant RuneSpritePainter old) => old.rune.id != rune.id;
}
