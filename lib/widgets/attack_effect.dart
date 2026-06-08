import 'dart:math';
import 'package:flutter/material.dart';
import '../models/dnd_class.dart';

// ─────────────────────────────────────────────────────────────
// AttackEffect — triggered per hero attack, plays a class-
// specific animation over the battle arena.
// Usage: call trigger(heroClass) from _doAttack().
// ─────────────────────────────────────────────────────────────

class AttackEffect extends StatefulWidget {
  const AttackEffect({super.key});

  @override
  AttackEffectState createState() => AttackEffectState();
}

class AttackEffectState extends State<AttackEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
  );
  DndClass _cls = DndClass.fighter;

  Future<void> trigger(DndClass cls) async {
    _cls = cls;
    await _ctrl.forward(from: 0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        if (t <= 0 || t >= 1) return const SizedBox.shrink();
        return CustomPaint(
          painter: _AttackEffectPainter(t, _cls),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Painter — draws one frame of the attack effect.
// Hero is on the LEFT side, enemy on the RIGHT side.
// Coordinates: hero area centre ≈ 22 % width, enemy ≈ 78 % width.
// ─────────────────────────────────────────────────────────────

class _AttackEffectPainter extends CustomPainter {
  _AttackEffectPainter(this.t, this.cls);

  final double t;
  final DndClass cls;

  // Reusable paint object (re-set per draw call)
  final Paint _p = Paint();

  @override
  void paint(Canvas c, Size sz) {
    switch (cls) {
      case DndClass.wizard:
        _fireball(c, sz, t, const Color(0xFFFF3020), const Color(0xFFFF8030));
      case DndClass.warlock:
        _eldritch(c, sz, t, const Color(0xFF9020FF), const Color(0xFF30E060));
      case DndClass.sorcerer:
        _lightning(c, sz, t, const Color(0xFF30A0FF), const Color(0xFF90E0FF));
      case DndClass.cleric:
        _fireball(c, sz, t, const Color(0xFFFFD040), const Color(0xFFFFFFB0));
      case DndClass.druid:
        _fireball(c, sz, t, const Color(0xFF30D040), const Color(0xFF80FF80));
      case DndClass.bard:
        _soundWave(c, sz, t);
      case DndClass.ranger:
        _arrow(c, sz, t);
      case DndClass.barbarian:
        _axeSwing(c, sz, t);
      case DndClass.fighter:
        _swordSlash(c, sz, t, const Color(0xFFD0D8E0), false);
      case DndClass.paladin:
        _swordSlash(c, sz, t, const Color(0xFFFFD060), true);
      case DndClass.rogue:
        _daggerFlash(c, sz, t);
      case DndClass.monk:
        _kiStrike(c, sz, t);
    }
  }

  @override
  bool shouldRepaint(_AttackEffectPainter old) =>
      old.t != t || old.cls != cls;

  // ── Helpers ───────────────────────────────────────────────

  Offset _hero(Size sz)  => Offset(sz.width * 0.28, sz.height * 0.72);
  Offset _enemy(Size sz) => Offset(sz.width * 0.72, sz.height * 0.72);

  void _circle(Canvas c, Offset pos, double r, Color col,
      {bool stroke = false, double sw = 2, double blur = 0}) {
    _p
      ..style = stroke ? PaintingStyle.stroke : PaintingStyle.fill
      ..strokeWidth = sw
      ..color = col
      ..maskFilter =
          blur > 0 ? MaskFilter.blur(BlurStyle.normal, blur) : null;
    c.drawCircle(pos, r, _p);
    _p.maskFilter = null;
  }

  void _line(Canvas c, Offset a, Offset b, Color col, double sw) {
    _p
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..color = col;
    c.drawLine(a, b, _p);
  }

  void _impact(Canvas c, Offset pos, double burst, Color col) {
    // Expanding ring
    _circle(c, pos, 14 + burst * 44, col.withValues(alpha: (1 - burst) * 0.8),
        stroke: true, sw: 4 - burst * 2.5);
    // Spark lines
    for (int i = 0; i < 8; i++) {
      final a = i * pi / 4;
      final len = burst * 38;
      _line(
        c,
        pos + Offset(cos(a) * 10, sin(a) * 10),
        pos + Offset(cos(a) * (10 + len), sin(a) * (10 + len)),
        col.withValues(alpha: (1 - burst) * 0.9),
        2.5 - burst * 1.5,
      );
    }
    // White flash
    _circle(c, pos, (1 - burst) * 18,
        Colors.white.withValues(alpha: (1 - burst) * 0.55));
  }

  // ── Fireball ──────────────────────────────────────────────
  // Classes: Wizard (red), Cleric (gold), Druid (green)
  void _fireball(Canvas c, Size sz, double t, Color main, Color glow) {
    final s = _hero(sz);
    final e = _enemy(sz);
    const travelEnd = 0.6;

    if (t < travelEnd) {
      final p = t / travelEnd;
      final pos = Offset.lerp(s, e, p)!;

      // Fading trail
      for (int i = 6; i >= 1; i--) {
        final tp = (p - i * 0.06).clamp(0.0, 1.0);
        if (tp > 0) {
          final tpos = Offset.lerp(s, e, tp)!;
          _circle(c, tpos, (6 - i) * 2.2,
              glow.withValues(alpha: (6 - i) / 6 * 0.45));
        }
      }

      // Glow aura
      _circle(c, pos, 18, glow.withValues(alpha: 0.30), blur: 10);

      // Main orb
      _circle(c, pos, 12, main);

      // Bright core
      _circle(c, pos, 6, Colors.white.withValues(alpha: 0.65));
    } else {
      _impact(c, e, (t - travelEnd) / (1 - travelEnd), main);
    }
  }

  // ── Eldritch bolt (Warlock: purple with green trail) ──────
  void _eldritch(Canvas c, Size sz, double t, Color bolt, Color trail) {
    final s = _hero(sz);
    final e = _enemy(sz);
    const travelEnd = 0.58;

    if (t < travelEnd) {
      final p = t / travelEnd;
      final pos = Offset.lerp(s, e, p)!;

      // Dark void trail
      for (int i = 5; i >= 1; i--) {
        final tp = (p - i * 0.07).clamp(0.0, 1.0);
        if (tp > 0) {
          final tpos = Offset.lerp(s, e, tp)!;
          _circle(c, tpos, (5 - i) * 2.5,
              trail.withValues(alpha: (5 - i) / 5 * 0.5));
        }
      }

      // Tendrils (wavy extra lines)
      for (int k = 0; k < 3; k++) {
        final offset = sin(t * pi * 6 + k * 2.0) * 8.0;
        final tp = (p - k * 0.05).clamp(0.0, 1.0);
        if (tp > 0) {
          final tpos = Offset.lerp(s, e, tp)! + Offset(0, offset);
          _circle(c, tpos, 4, bolt.withValues(alpha: 0.4));
        }
      }

      // Core bolt
      _circle(c, pos, 11, bolt);
      _circle(c, pos, 5, trail.withValues(alpha: 0.9)); // green core
    } else {
      // Dark explosion
      final burst = (t - travelEnd) / (1 - travelEnd);
      _impact(c, e, burst, bolt);

      // Extra eldritch glow
      _circle(c, e, (1 - burst) * 22,
          trail.withValues(alpha: (1 - burst) * 0.4), blur: 8);
    }
  }

  // ── Lightning bolt (Sorcerer) ─────────────────────────────
  void _lightning(Canvas c, Size sz, double t, Color bolt, Color glow) {
    final s = _hero(sz);
    final e = _enemy(sz);
    const travelEnd = 0.50;

    if (t < travelEnd) {
      final p = t / travelEnd;
      final headX = s.dx + (e.dx - s.dx) * p;
      final headY = s.dy;

      // Jagged bolt segments from start to current head
      final rng = Random(42); // fixed seed for stable shape
      Offset cur = s;
      const segs = 7;
      for (int i = 1; i <= segs; i++) {
        final segP = i / segs;
        if (segP > p) break;
        final segX = s.dx + (e.dx - s.dx) * segP;
        final segY = s.dy + (rng.nextDouble() - 0.5) * 28;
        final next = Offset(segX, segY);
        _line(c, cur, next, glow.withValues(alpha: 0.35), 4);
        _line(c, cur, next, bolt.withValues(alpha: 0.9), 2);
        cur = next;
      }
      _line(c, cur, Offset(headX, headY),
          bolt.withValues(alpha: 0.9), 2);

      // Travelling glow
      _circle(c, Offset(headX, headY), 10,
          glow.withValues(alpha: 0.5), blur: 6);
      _circle(c, Offset(headX, headY), 6, bolt);
    } else {
      // Electric burst
      final burst = (t - travelEnd) / (1 - travelEnd);
      _impact(c, e, burst, bolt);

      // Electric arcs
      for (int i = 0; i < 5; i++) {
        final a = i * pi * 0.4 + burst * pi;
        final len = burst * 30;
        final midPt = e + Offset(cos(a) * 8, sin(a) * 8);
        final endPt = e + Offset(cos(a + 0.4) * (8 + len), sin(a + 0.4) * (8 + len));
        _line(c, midPt, endPt, glow.withValues(alpha: (1 - burst) * 0.8), 1.5);
      }
    }
  }

  // ── Sound wave (Bard) ─────────────────────────────────────
  void _soundWave(Canvas c, Size sz, double t) {
    final s = _hero(sz);
    final e = _enemy(sz);
    const travelEnd = 0.62;
    const teal = Color(0xFF30D0C0);
    const purple = Color(0xFFD040E0);

    if (t < travelEnd) {
      final p = t / travelEnd;
      final cx = s.dx + (e.dx - s.dx) * p;

      // Three arcs travelling together
      for (int i = 0; i < 3; i++) {
        final offset = i * 0.08;
        final ap = (p - offset).clamp(0.0, 1.0);
        if (ap <= 0) continue;
        final ax = s.dx + (e.dx - s.dx) * ap;
        final rect = Rect.fromCenter(
            center: Offset(ax, s.dy), width: 28 + i * 12, height: 44 + i * 16);
        final alpha = (1 - i * 0.25) * 0.75;
        _p
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5 - i * 0.5
          ..color = (i.isEven ? teal : purple).withValues(alpha: alpha);
        c.drawArc(rect, -pi / 2, pi, false, _p);
      }

      // Musical note head
      _circle(c, Offset(cx, s.dy), 8, teal);
      _circle(c, Offset(cx, s.dy), 4, Colors.white.withValues(alpha: 0.6));
    } else {
      _impact(c, e, (t - travelEnd) / (1 - travelEnd), teal);
    }
  }

  // ── Arrow (Ranger) ────────────────────────────────────────
  void _arrow(Canvas c, Size sz, double t) {
    final s = _hero(sz) + const Offset(10, -6);
    final e = _enemy(sz) + const Offset(-10, -6);
    const shaft = Color(0xFF7a5020);
    const head  = Color(0xFFb8a060);
    const travelEnd = 0.68;

    if (t < travelEnd) {
      final p = t / travelEnd;
      final tipPos = Offset.lerp(s, e, p)!;
      final tailP = (p - 0.18).clamp(0.0, 1.0);
      final tailPos = Offset.lerp(s, e, tailP)!;

      // Shaft
      _line(c, tailPos, tipPos, shaft, 3.5);

      // Fletching (remains near start while shaft moves)
      if (tailP < 0.05) {
        _line(c, tailPos, tailPos + const Offset(-6, -6), const Color(0xFF3a1808), 2);
        _line(c, tailPos, tailPos + const Offset(-6, 6), const Color(0xFF3a1808), 2);
      }

      // Arrowhead
      final dx = e.dx - s.dx;
      final dy = e.dy - s.dy;
      final len = sqrt(dx * dx + dy * dy);
      final ndx = dx / len;
      final ndy = dy / len;
      final path = Path()
        ..moveTo(tipPos.dx + ndx * 10, tipPos.dy + ndy * 10)
        ..lineTo(tipPos.dx + (-ndy) * 5, tipPos.dy + ndx * 5)
        ..lineTo(tipPos.dx - (-ndy) * 5, tipPos.dy - ndx * 5)
        ..close();
      _p..style = PaintingStyle.fill..color = head;
      c.drawPath(path, _p);
    } else {
      // Stuck arrow + dust puff
      final burst = (t - travelEnd) / (1 - travelEnd);
      _line(c, e - const Offset(38, 0), e,
          shaft.withValues(alpha: 1 - burst * 0.4), 3);
      _circle(c, e, burst * 22, const Color(0xFF8a6020).withValues(alpha: (1 - burst) * 0.4),
          stroke: true, sw: 2);
      for (int i = 0; i < 5; i++) {
        final a = pi * 0.5 + i * pi * 0.3 - pi * 0.6;
        final dist = 10 + burst * 24;
        _circle(c, e + Offset(cos(a) * dist, sin(a) * dist),
            (1 - burst) * 3, head.withValues(alpha: 1 - burst));
      }
    }
  }

  // ── Axe swing (Barbarian) ─────────────────────────────────
  void _axeSwing(Canvas c, Size sz, double t) {
    final heroX = sz.width * 0.25;
    final enemyX = sz.width * 0.75;
    final midY = sz.height * 0.72;
    const axeGrey  = Color(0xFF909098);
    const blade    = Color(0xFFD0D8E0);
    const handle   = Color(0xFF7a5020);
    const trail    = Color(0xFFc08030);

    if (t < 0.38) {
      // Wind-up: axe raised behind/above hero
      final windT = t / 0.38;
      final pos = Offset(heroX - 10 + windT * 8, midY - 70 + windT * 30);
      _drawAxeHead(c, pos, axeGrey, blade, handle, windT);
    } else if (t < 0.82) {
      // Swing arc toward enemy
      final swingT = (t - 0.38) / 0.44;

      // Motion trail arcs
      for (int i = 5; i >= 1; i--) {
        final tp = (swingT - i * 0.10).clamp(0.0, 1.0);
        final tx = heroX + (enemyX - heroX) * tp;
        final ty = midY - 40 + tp * 60;
        _circle(c, Offset(tx, ty),
            (6 - i) * 3.5, trail.withValues(alpha: (6 - i) / 6 * 0.35));
      }
      // Slash diagonal lines
      for (int i = 0; i < 3; i++) {
        final tp = (swingT - i * 0.07).clamp(0.0, 1.0);
        final tx = heroX + (enemyX - heroX) * tp;
        final ty = midY - 35 + tp * 55;
        _line(c, Offset(tx - 14, ty - 28), Offset(tx + 12, ty + 20),
            blade.withValues(alpha: (4 - i) / 4 * (1 - swingT * 0.5)),
            (4 - i) * 2.5);
      }
      // Axe head at leading edge
      final ax = heroX + (enemyX - heroX) * swingT;
      final ay = midY - 40 + swingT * 60;
      _drawAxeHead(c, Offset(ax, ay), axeGrey, blade, handle, 1.0);
    } else {
      // Impact
      _impact(c, Offset(enemyX, midY + 10),
          (t - 0.82) / 0.18, const Color(0xFFffcc40));
    }
  }

  void _drawAxeHead(Canvas c, Offset pos, Color grey, Color bl, Color hndl, double a) {
    // Handle
    _line(c, pos + const Offset(0, 8), pos + const Offset(0, 30),
        hndl.withValues(alpha: a), 5);
    // Blade oval
    _p..style = PaintingStyle.fill..color = grey.withValues(alpha: a);
    c.drawOval(Rect.fromCenter(center: pos, width: 26, height: 20), _p);
    _p.color = bl.withValues(alpha: a);
    c.drawOval(Rect.fromCenter(center: pos, width: 16, height: 11), _p);
  }

  // ── Sword slash (Fighter / Paladin) ───────────────────────
  void _swordSlash(Canvas c, Size sz, double t, Color col, bool holy) {
    final heroX = sz.width * 0.27;
    final targetX = sz.width * 0.73;
    final midY = sz.height * 0.72;
    const travelEnd = 0.72;

    if (t < travelEnd) {
      final slashT = t / travelEnd;
      // Diagonal slash trail
      for (int i = 4; i >= 0; i--) {
        final tp = (slashT - i * 0.09).clamp(0.0, 1.0);
        final x = heroX + (targetX - heroX) * tp;
        _line(c, Offset(x - 12, midY - 32 - i * 2),
            Offset(x + 10, midY + 32 + i * 2),
            col.withValues(alpha: (5 - i) / 5 * (1 - slashT * 0.4)),
            (5 - i) * 2.2);
      }
      // Holy glow pulse for Paladin
      if (holy && slashT > 0.45) {
        final gT = (slashT - 0.45) / 0.55;
        _circle(c, Offset(targetX, midY), gT * 28,
            col.withValues(alpha: (1 - gT) * 0.45), blur: 12);
      }
    } else {
      _impact(c, Offset(targetX, midY), (t - travelEnd) / (1 - travelEnd), col);
    }
  }

  // ── Dagger flash (Rogue) ──────────────────────────────────
  void _daggerFlash(Canvas c, Size sz, double t) {
    final targetX = sz.width * 0.72;
    final midY = sz.height * 0.72;
    const blade = Color(0xFF8898c8);
    const dark = Color(0xFF3c3858);
    const gold = Color(0xFFc8a020);

    if (t < 0.32) {
      // Speed-dash lines
      final p = t / 0.32;
      for (int i = 0; i < 3; i++) {
        final y = midY - 14 + i * 14.0;
        final ex = sz.width * 0.30 + (targetX - sz.width * 0.30) * p;
        _line(c, Offset(ex - 55 + i * 8, y), Offset(ex, y),
            dark.withValues(alpha: (3 - i) / 3 * p * 0.7), (3 - i) * 2.0);
      }
    } else if (t < 0.60) {
      // X slash at target
      final st = (t - 0.32) / 0.28;
      final origin = Offset(targetX, midY);
      const sz2 = 28.0;
      _line(c, origin + Offset(-sz2, -sz2) * st, origin + Offset(sz2, sz2) * st,
          blade, 4);
      _line(c, origin + Offset(sz2, -sz2) * st, origin + Offset(-sz2, sz2) * st,
          blade, 4);
      // Gold guard glints
      _circle(c, origin, (1 - st) * 9,
          gold.withValues(alpha: (1 - st) * 0.8));
      _circle(c, origin, (1 - st) * 5,
          Colors.white.withValues(alpha: (1 - st) * 0.6));
    } else {
      // Fade + impact sparks
      final ft = (t - 0.60) / 0.40;
      final origin = Offset(targetX, midY);
      const sz2 = 28.0;
      _line(c, origin + const Offset(-sz2, -sz2),
          origin + const Offset(sz2, sz2),
          blade.withValues(alpha: (1 - ft) * 0.7), 3);
      _line(c, origin + const Offset(sz2, -sz2),
          origin + const Offset(-sz2, sz2),
          blade.withValues(alpha: (1 - ft) * 0.7), 3);
      _impact(c, origin, ft, const Color(0xFF8898c8));
    }
  }

  // ── Ki strike (Monk) ─────────────────────────────────────
  void _kiStrike(Canvas c, Size sz, double t) {
    final targetX = sz.width * 0.72;
    final midY = sz.height * 0.72;
    final heroX = sz.width * 0.28;
    final pos = Offset(targetX, midY);
    const saffron = Color(0xFFE8B040);
    const chi = Color(0xFFFFE090);

    if (t < 0.28) {
      // Fist rush
      final p = t / 0.28;
      final fx = heroX + (targetX - heroX - 20) * p;
      final fpos = Offset(fx, midY);
      for (int i = 0; i < 4; i++) {
        final y = midY - 18 + i * 12.0;
        _line(c, Offset(fx - 60 + i * 10, y), Offset(fx - 4, y),
            saffron.withValues(alpha: (4 - i) / 4 * p * 0.7), (4 - i) * 1.5);
      }
      // Wrapped fist
      _circle(c, fpos, 11, const Color(0xFFe8dcc8));
      _circle(c, fpos, 7, const Color(0xFFc8785c));
    } else if (t < 0.68) {
      // Expanding ki rings
      final rt = (t - 0.28) / 0.40;
      _circle(c, pos, rt * 40,
          chi.withValues(alpha: (1 - rt) * 0.85), stroke: true, sw: 4 - rt * 2);
      if (rt > 0.25) {
        _circle(c, pos, (rt - 0.25) / 0.75 * 55,
            saffron.withValues(alpha: (1 - rt) * 0.55), stroke: true, sw: 2.5);
      }
      for (int i = 0; i < 6; i++) {
        final a = i * pi / 3;
        final len = rt * 38;
        _line(c, pos + Offset(cos(a) * 9, sin(a) * 9),
            pos + Offset(cos(a) * (9 + len), sin(a) * (9 + len)),
            chi.withValues(alpha: (1 - rt) * 0.9), 2.5 - rt * 1.5);
      }
      _circle(c, pos, (1 - rt) * 16,
          Colors.white.withValues(alpha: (1 - rt) * 0.55));
    } else {
      // Final fade ring
      final ft = (t - 0.68) / 0.32;
      _circle(c, pos, 40 + ft * 14,
          chi.withValues(alpha: (1 - ft) * 0.30), stroke: true, sw: 2);
    }
  }
}
