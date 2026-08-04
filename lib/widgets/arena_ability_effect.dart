import 'dart:math';
import 'package:flutter/material.dart';

// ── Public API ────────────────────────────────────────────────────────────────

class ArenaAbilityEffect extends StatefulWidget {
  const ArenaAbilityEffect({super.key});

  @override
  State<ArenaAbilityEffect> createState() => ArenaAbilityEffectState();
}

class ArenaAbilityEffectState extends State<ArenaAbilityEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

  _EffectDef? _current;

  void playEffect(String abilityId) {
    final def = _kEffects[abilityId];
    if (def == null || !mounted) return;
    _ctrl.duration = Duration(milliseconds: def.durationMs);
    setState(() => _current = def);
    _ctrl.forward(from: 0).then((_) {
      if (mounted) setState(() => _current = null);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final def = _current;
    if (def == null) return const SizedBox.shrink();
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _EffectPainter(def, _ctrl.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

// ── Effect types ──────────────────────────────────────────────────────────────

enum _FxType {
  slashArc,      // physical diagonal sweep
  fireball,      // fire orb L→R
  iceShards,     // cold shards L→R
  lightningBolt, // zigzag arc
  poisonCloud,   // expanding green cloud
  voidOrb,       // dark pulsing orb L→R
  healBurst,     // radiance expanding from hero side
  buffGlow,      // golden aura pulse on hero
  debuffArrows,  // downward arrows over enemy
  stunStars,     // stars orbiting enemy
  dotDrops,      // crimson drops raining
  shieldFlash,   // blue flash from hero
  soundWave,     // expanding rings (bard)
  smokeCloud,    // grey smoke puff
  ultimateBurst, // full-arena dramatic burst
}

class _EffectDef {
  const _EffectDef(this.type, this.primary, this.secondary,
      {this.durationMs = 700});
  final _FxType type;
  final Color primary, secondary;
  final int durationMs;
}

// ── Painter ───────────────────────────────────────────────────────────────────

class _EffectPainter extends CustomPainter {
  const _EffectPainter(this.def, this.t);
  final _EffectDef def;
  final double t; // 0→1

  double get fade => t < 0.15 ? t / 0.15 : t > 0.75 ? (1 - t) / 0.25 : 1.0;

  @override
  void paint(Canvas c, Size s) {
    final w = s.width, h = s.height;
    c.saveLayer(Offset.zero & s, Paint());
    switch (def.type) {
      case _FxType.slashArc:     _slashArc(c, w, h);
      case _FxType.fireball:     _fireball(c, w, h);
      case _FxType.iceShards:    _iceShards(c, w, h);
      case _FxType.lightningBolt: _lightning(c, w, h);
      case _FxType.poisonCloud:  _poisonCloud(c, w, h);
      case _FxType.voidOrb:      _voidOrb(c, w, h);
      case _FxType.healBurst:    _healBurst(c, w, h);
      case _FxType.buffGlow:     _buffGlow(c, w, h);
      case _FxType.debuffArrows: _debuffArrows(c, w, h);
      case _FxType.stunStars:    _stunStars(c, w, h);
      case _FxType.dotDrops:     _dotDrops(c, w, h);
      case _FxType.shieldFlash:  _shieldFlash(c, w, h);
      case _FxType.soundWave:    _soundWave(c, w, h);
      case _FxType.smokeCloud:   _smokeCloud(c, w, h);
      case _FxType.ultimateBurst: _ultimateBurst(c, w, h);
    }
    c.restore();
  }

  Paint _sp(Color col, double width) => Paint()
    ..color = col.withValues(alpha: col.a * fade)
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.stroke;

  Paint _fp(Color col) => Paint()
    ..color = col.withValues(alpha: col.a * fade)
    ..style = PaintingStyle.fill;

  // Sprite anchors — sprites sit at the very bottom of the arena panel
  static const _hx = 0.28; // hero x
  static const _hy = 0.84; // hero y (body/chest)
  static const _ex = 0.72; // enemy x
  static const _ey = 0.84; // enemy y (body/chest)

  void _slashArc(Canvas c, double w, double h) {
    // Slash sweeps from hero to enemy
    final x = w * (_hx + t * (_ex - _hx));
    final arc = Path()
      ..moveTo(x - w*.12, h*(_hy - 0.18))
      ..cubicTo(x - w*.04, h*(_hy - 0.10), x + w*.04, h*(_hy - 0.02), x + w*.12, h*_hy);
    c.drawPath(arc, _sp(def.primary, w * .018 * (1 + t)));
    c.drawPath(arc, _sp(def.secondary.withValues(alpha: .4), w * .030));
  }

  void _fireball(Canvas c, double w, double h) {
    final x = w * (_hx + t * (_ex - _hx));
    final y = h * _hy;
    for (int i = 0; i < 5; i++) {
      final tx = x - w * .06 * (i + 1);
      c.drawCircle(Offset(tx, y + i * h * .008),
          w * (.028 - i * .004),
          _fp(def.primary.withValues(alpha: (.6 - i * .1) * fade)));
    }
    c.drawCircle(Offset(x, y), w * .038, _fp(def.secondary));
    c.drawCircle(Offset(x, y), w * .026, _fp(const Color(0xFFFFFFCC)));
    if (t > 0.72) {
      final bt = (t - 0.72) / 0.28;
      _rays(c, w * _ex, y, w * .04, w * (.04 + bt * .12), 8, bt * pi,
          _sp(def.primary, w * .012 * (1 - bt)));
    }
  }

  void _iceShards(Canvas c, double w, double h) {
    for (int i = 0; i < 3; i++) {
      final delay = i * 0.12;
      final pt = (t - delay).clamp(0.0, 1.0);
      final x = w * (_hx + pt * (_ex - _hx));
      final y = h * (_hy - 0.04 + i * 0.04);
      final sp = Path()
        ..moveTo(x - w*.04, y + h*.03)
        ..lineTo(x, y - h*.05)
        ..lineTo(x + w*.04, y + h*.03)
        ..close();
      c.drawPath(sp, _fp(def.primary.withValues(alpha: (.8 - i * .15) * fade)));
      c.drawPath(sp, _sp(def.secondary, w * .008));
      if (pt > 0.1) {
        for (int j = 0; j < 3; j++) {
          final a = j * pi * 2 / 3 + pt * pi;
          c.drawCircle(Offset(x + cos(a) * w * .06, y + sin(a) * h * .06),
              w * .008, _fp(const Color(0xFFCCEEFF).withValues(alpha: .6 * fade)));
        }
      }
    }
  }

  void _lightning(Canvas c, double w, double h) {
    // Zigzag bolt from hero to enemy, points remapped to [_hx, _ex]
    final revealX = w * (_hx + t * (_ex - _hx));
    final pts = [
      Offset(w * _hx,  h * (_hy - 0.07)),
      Offset(w * 0.39, h * (_hy - 0.10)),
      Offset(w * 0.44, h * (_hy - 0.02)),
      Offset(w * 0.54, h * (_hy - 0.07)),
      Offset(w * 0.60, h * (_hy + 0.01)),
      Offset(w * 0.69, h * (_hy - 0.05)),
      Offset(w * _ex,  h * (_hy - 0.04)),
    ];
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (final p in pts.skip(1)) {
      if (p.dx <= revealX) path.lineTo(p.dx, p.dy);
    }
    c.drawPath(path, _sp(def.primary, w * .016));
    c.drawPath(path, _sp(def.secondary.withValues(alpha: .5), w * .008));
    if (t > 0.3) {
      c.drawPath(path, _sp(const Color(0xFFFFFFFF).withValues(alpha: (sin(t * 40) * .3 + .3) * fade), w * .004));
    }
  }

  void _poisonCloud(Canvas c, double w, double h) {
    // Cloud materialises at enemy
    final cx = w * _ex;
    final r  = w * (.08 + t * .16);
    c.drawCircle(Offset(cx, h * _ey), r,
        _fp(def.primary.withValues(alpha: .3 * fade)));
    c.drawCircle(Offset(cx, h * _ey), r,
        _sp(def.primary, w * .012));
    for (int i = 0; i < 5; i++) {
      final a = i * pi * 2 / 5 + t * 2;
      c.drawCircle(Offset(cx + cos(a) * r * .8, h * _ey + sin(a) * r * .8),
          w * .022, _fp(def.secondary.withValues(alpha: .5 * fade)));
    }
  }

  void _voidOrb(Canvas c, double w, double h) {
    final x = w * (_hx + t * (_ex - _hx));
    final y = h * _hy;
    for (int i = 0; i < 3; i++) {
      final rx = x - w * .10 * (i + 1);
      c.drawCircle(Offset(rx, y), w * (.02 + i * .008),
          _sp(def.secondary.withValues(alpha: (.4 - i * .1) * fade), w * .008));
    }
    c.drawCircle(Offset(x, y), w * .032,
        _fp(def.primary.withValues(alpha: .9 * fade)));
    c.drawCircle(Offset(x, y), w * .016,
        _fp(const Color(0xFF220033).withValues(alpha: fade)));
  }

  void _healBurst(Canvas c, double w, double h) {
    final r = w * (.05 + t * .28);
    final cx = w * _hx, cy = h * _hy;
    c.drawCircle(Offset(cx, cy), r,
        _fp(def.primary.withValues(alpha: (.3 - t * .25).clamp(0, 1) * fade)));
    _rays(c, cx, cy, r * .6, r, 8, t * pi,
        _sp(def.secondary, w * .010 * (1 - t)));
    for (int i = 0; i < 6; i++) {
      final a = i * pi / 3 + t * pi * .5;
      final pr = r * (.4 + i * .15);
      c.drawCircle(Offset(cx + cos(a) * pr, cy + sin(a) * pr * .7),
          w * .010, _fp(def.primary.withValues(alpha: .7 * fade)));
    }
  }

  void _buffGlow(Canvas c, double w, double h) {
    final cx = w * _hx, cy = h * _hy;
    final r  = w * (.12 + t * .10);
    for (int i = 0; i < 3; i++) {
      c.drawCircle(Offset(cx, cy), r + w * .04 * i,
          _sp(def.primary.withValues(alpha: (.8 - i * .25) * fade), w * .010));
    }
    _rays(c, cx, cy, r * .4, r * .9, 8, -t * pi * 2,
        _sp(def.secondary, w * .008 * fade));
  }

  void _debuffArrows(Canvas c, double w, double h) {
    // Arrows fall onto enemy from above
    final ex = w * _ex;
    final topY = h * (_ey - 0.14);
    for (int i = 0; i < 3; i++) {
      final y = topY + h * .12 * t + i * h * .05;
      final x = ex + (i - 1) * w * .07;
      c.drawLine(Offset(x, y - h * .05), Offset(x, y),
          _sp(def.primary, w * .014));
      final ap = Path()
        ..moveTo(x, y + h * .024)
        ..lineTo(x - w*.020, y)
        ..lineTo(x + w*.020, y)
        ..close();
      c.drawPath(ap, _fp(def.primary.withValues(alpha: fade)));
    }
  }

  void _stunStars(Canvas c, double w, double h) {
    // Stars orbit enemy head area
    final ex = w * _ex, ey = h * (_ey - 0.10);
    for (int i = 0; i < 5; i++) {
      final a = i * 2 * pi / 5 + t * pi * 3;
      final r = w * .10;
      final sx = ex + cos(a) * r, sy = ey + sin(a) * r * .6;
      _rays(c, sx, sy, w * .006, w * .024, 4, a,
          _sp(def.primary, w * .010));
      c.drawCircle(Offset(sx, sy), w * .010,
          _fp(def.secondary.withValues(alpha: .9 * fade)));
    }
  }

  void _dotDrops(Canvas c, double w, double h) {
    // Drops fall onto enemy
    final ex = w * _ex;
    final startY = h * (_ey - 0.15);
    for (int i = 0; i < 4; i++) {
      final delay = i * 0.14;
      final pt = (t - delay).clamp(0.0, 1.0);
      final x = ex + (i - 1.5) * w * .055;
      final y = startY + pt * h * .15;
      c.drawCircle(Offset(x, y), w * (.014 + i * .004),
          _fp(def.primary.withValues(alpha: (.8 - pt * .3) * fade)));
      if (pt > 0) {
        c.drawLine(Offset(x, y - w * .03), Offset(x, y),
            _sp(def.secondary, w * .010 * (1 - pt)));
      }
    }
  }

  void _shieldFlash(Canvas c, double w, double h) {
    final cx = w * _hx, cy = h * _hy;
    final r  = w * (.06 + t * .20);
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final a = -pi / 2 + i * 2 * pi / 5;
      final x = cx + cos(a) * r, y = cy + sin(a) * r;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    c.drawPath(path, _fp(def.primary.withValues(alpha: (.25 - t * .2).clamp(0, 1) * fade)));
    c.drawPath(path, _sp(def.secondary, w * .012 * (1 - t)));
    if (t < 0.4) {
      _rays(c, cx, cy, r, r * 1.4, 6, t * pi,
          _sp(def.primary, w * .008 * (1 - t / 0.4)));
    }
  }

  void _soundWave(Canvas c, double w, double h) {
    // Rings expand from center between hero and enemy
    final cx = w * 0.50, cy = h * _hy;
    for (int i = 0; i < 3; i++) {
      final delay = i * 0.18;
      final pt = (t - delay).clamp(0.0, 1.0);
      final r = w * (.06 + pt * .32);
      c.drawCircle(Offset(cx, cy), r,
          _sp(def.primary.withValues(alpha: (.7 - pt * .6) * fade), w * .012));
      c.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r),
          pi * .4 + i * .3, pi * .3, false,
          _sp(const Color(0xFF000000).withValues(alpha: .6), w * .016));
    }
  }

  void _smokeCloud(Canvas c, double w, double h) {
    final cx = w * _ex, cy = h * _ey;
    final r  = w * (.06 + t * .18);
    for (int i = 0; i < 4; i++) {
      final ox = cos(i * pi / 2 + t) * r * .5;
      final oy = sin(i * pi / 2 + t) * r * .3;
      c.drawCircle(Offset(cx + ox, cy + oy), r * .7,
          _fp(def.primary.withValues(alpha: (.35 - t * .25).clamp(0, 1) * fade)));
    }
    for (int i = 0; i < 3; i++) {
      final x = cx + (i - 1) * w * .06;
      final y = cy - h * (.06 + t * .20 + i * .04);
      c.drawCircle(Offset(x, y), w * .020,
          _fp(def.secondary.withValues(alpha: .3 * fade)));
    }
  }

  void _ultimateBurst(Canvas c, double w, double h) {
    final cx = w * 0.50, cy = h * _hy;
    final r = w * (.10 + t * .70);
    c.drawCircle(Offset(cx, cy), r,
        _fp(def.primary.withValues(alpha: (.4 - t * .35).clamp(0, 1))));
    _rays(c, cx, cy, r * .3, r * .9, 12, t * pi,
        _sp(def.secondary.withValues(alpha: (.6 - t * .5).clamp(0, 1)), w * .014));
    if (t < 0.2) {
      c.drawRect(Rect.fromLTWH(0, cy - r, w, r * 2),
          _fp(def.primary.withValues(alpha: (.5 - t * 2.5).clamp(0, 1))));
    }
    for (int i = 0; i < 16; i++) {
      final a = i * pi / 8 + t * pi;
      final pr = w * (.15 + t * .50);
      c.drawCircle(
        Offset(cx + cos(a) * pr, cy + sin(a) * pr * .7),
        w * (.012 - t * .008).clamp(0.002, 0.02),
        _fp(def.primary.withValues(alpha: (.8 - t) * fade)),
      );
    }
  }

  void _rays(Canvas c, double cx, double cy, double r1, double r2,
      int n, double a0, Paint p) {
    for (int i = 0; i < n; i++) {
      final a = a0 + i * 2 * pi / n;
      c.drawLine(Offset(cx + cos(a) * r1, cy + sin(a) * r1),
                 Offset(cx + cos(a) * r2, cy + sin(a) * r2), p);
    }
  }

  @override
  bool shouldRepaint(_EffectPainter o) => o.t != t || o.def != def;
}

// ── Effect registry (ability ID → effect definition) ─────────────────────────

const _physCol   = Color(0xFFE88830);
const _fireCol   = Color(0xFFFF5022);
const _coldCol   = Color(0xFF44BBFF);
const _lightCol  = Color(0xFFFFE040);
const _poisCol   = Color(0xFF55EE77);
const _voidCol   = Color(0xFFAA44FF);
const _healCol   = Color(0xFF44FF99);
const _buffCol   = Color(0xFFFFD700);
const _debufCol  = Color(0xFFFF8800);
const _ultCol    = Color(0xFFFFFFFF);

final _kEffects = <String, _EffectDef>{
  // ── BARBARIAN ──────────────────────────────────────────────────────────────
  'barbarian_1': _EffectDef(_FxType.stunStars,    const Color(0xFFCC2200), const Color(0xFFFF6644)),
  'barbarian_2': _EffectDef(_FxType.buffGlow,      _buffCol,  const Color(0xFFFFAA44)),
  'barbarian_3': _EffectDef(_FxType.dotDrops,      _poisCol,  const Color(0xFF88DD00)),
  'barbarian_4': _EffectDef(_FxType.buffGlow,      _fireCol,  const Color(0xFFFF8833)),
  'barbarian_5': _EffectDef(_FxType.debuffArrows,  _debufCol, const Color(0xFFFF6600)),
  'barbarian_6': _EffectDef(_FxType.slashArc,      _physCol,  const Color(0xFFFF5511)),
  'barb_ult':    _EffectDef(_FxType.ultimateBurst, _fireCol,  _ultCol, durationMs: 900),
  // ── BARD ──────────────────────────────────────────────────────────────────
  'bard_1': _EffectDef(_FxType.voidOrb,      _voidCol,  const Color(0xFFCC88FF)),
  'bard_2': _EffectDef(_FxType.soundWave,    _voidCol,  const Color(0xFF9966CC)),
  'bard_3': _EffectDef(_FxType.lightningBolt,_lightCol, const Color(0xFFAA66FF)),
  'bard_4': _EffectDef(_FxType.buffGlow,     _buffCol,  const Color(0xFFCC88FF)),
  'bard_5': _EffectDef(_FxType.debuffArrows, _debufCol, const Color(0xFFAA44FF)),
  'bard_6': _EffectDef(_FxType.soundWave,    _voidCol,  const Color(0xFFBB77FF)),
  'brd_ult': _EffectDef(_FxType.ultimateBurst, _voidCol, _ultCol, durationMs: 900),
  // ── CLERIC ────────────────────────────────────────────────────────────────
  'cleric_1': _EffectDef(_FxType.fireball,     _fireCol,  const Color(0xFFFF8844)),
  'cleric_2': _EffectDef(_FxType.healBurst,    _healCol,  _ultCol),
  'cleric_3': _EffectDef(_FxType.voidOrb,      _voidCol,  const Color(0xFF6688FF)),
  'cleric_4': _EffectDef(_FxType.healBurst,    _healCol,  const Color(0xFF6688FF)),
  'cleric_5': _EffectDef(_FxType.debuffArrows, _debufCol, const Color(0xFF88AAFF)),
  'cleric_6': _EffectDef(_FxType.shieldFlash,  const Color(0xFF6688FF), _coldCol),
  'clr_ult':  _EffectDef(_FxType.ultimateBurst, _healCol,  _ultCol, durationMs: 900),
  // ── DRUID ─────────────────────────────────────────────────────────────────
  'druid_1': _EffectDef(_FxType.stunStars,     const Color(0xFFAA7722), const Color(0xFF66EE33)),
  'druid_2': _EffectDef(_FxType.healBurst,     _healCol,  _poisCol),
  'druid_3': _EffectDef(_FxType.iceShards,     _coldCol,  const Color(0xFF88DDFF)),
  'druid_4': _EffectDef(_FxType.poisonCloud,   _poisCol,  const Color(0xFF88EE44)),
  'druid_5': _EffectDef(_FxType.stunStars,     _poisCol,  const Color(0xFF55EE77)),
  'druid_6': _EffectDef(_FxType.stunStars,     _poisCol,  const Color(0xFF44BB55)),
  'drd_ult': _EffectDef(_FxType.ultimateBurst, _poisCol,  const Color(0xFFAAFF66), durationMs: 900),
  // ── FIGHTER ───────────────────────────────────────────────────────────────
  'fighter_1': _EffectDef(_FxType.shieldFlash,    _physCol,  _lightCol),
  'fighter_2': _EffectDef(_FxType.buffGlow,       _buffCol,  _lightCol),
  'fighter_3': _EffectDef(_FxType.lightningBolt,  _lightCol, const Color(0xFFFFFF88)),
  'fighter_4': _EffectDef(_FxType.healBurst,      _healCol,  _coldCol),
  'fighter_5': _EffectDef(_FxType.debuffArrows,   _debufCol, _lightCol),
  'fighter_6': _EffectDef(_FxType.debuffArrows,   _physCol,  _lightCol),
  'ftr_ult':  _EffectDef(_FxType.ultimateBurst,   _lightCol, _ultCol, durationMs: 900),
  // ── MONK ──────────────────────────────────────────────────────────────────
  'monk_1': _EffectDef(_FxType.iceShards,      const Color(0xFFCCEEFF), _coldCol),
  'monk_2': _EffectDef(_FxType.shieldFlash,   _coldCol,  const Color(0xFF44BBFF)),
  'monk_3': _EffectDef(_FxType.voidOrb,       _voidCol,  _coldCol),
  'monk_4': _EffectDef(_FxType.buffGlow,      _coldCol,  const Color(0xFF44DDFF)),
  'monk_5': _EffectDef(_FxType.stunStars,     _coldCol,  const Color(0xFF88EEFF)),
  'monk_6': _EffectDef(_FxType.stunStars,     _voidCol,  _coldCol),
  'mnk_ult': _EffectDef(_FxType.ultimateBurst, _coldCol, const Color(0xFF88FFFF), durationMs: 900),
  // ── PALADIN ───────────────────────────────────────────────────────────────
  'paladin_1': _EffectDef(_FxType.shieldFlash,   _buffCol,  const Color(0xFFFFFFBB)),
  'paladin_2': _EffectDef(_FxType.healBurst,    _healCol,  _buffCol),
  'paladin_3': _EffectDef(_FxType.fireball,     _buffCol,  _ultCol),
  'paladin_4': _EffectDef(_FxType.buffGlow,     _buffCol,  const Color(0xFFFFEE88)),
  'paladin_5': _EffectDef(_FxType.debuffArrows, _debufCol, _buffCol),
  'paladin_6': _EffectDef(_FxType.fireball,     _fireCol,  _buffCol),
  'pal_ult':  _EffectDef(_FxType.ultimateBurst, _buffCol,  _ultCol, durationMs: 900),
  // ── RANGER ────────────────────────────────────────────────────────────────
  'ranger_1': _EffectDef(_FxType.poisonCloud,   _poisCol,  const Color(0xFF44CC66)),
  'ranger_2': _EffectDef(_FxType.debuffArrows,  _debufCol, _poisCol),
  'ranger_3': _EffectDef(_FxType.iceShards,     _coldCol,  _poisCol),
  'ranger_4': _EffectDef(_FxType.buffGlow,      _poisCol,  const Color(0xFF44CC66)),
  'ranger_5': _EffectDef(_FxType.slashArc,      _poisCol,  const Color(0xFFFF6644)),
  'ranger_6': _EffectDef(_FxType.stunStars,     _poisCol,  const Color(0xFF55CC77)),
  'rng_ult':  _EffectDef(_FxType.ultimateBurst, _poisCol,  const Color(0xFF88FF99), durationMs: 900),
  // ── ROGUE ─────────────────────────────────────────────────────────────────
  'rogue_1': _EffectDef(_FxType.debuffArrows,   const Color(0xFF223322), const Color(0xFF88EE66)),
  'rogue_2': _EffectDef(_FxType.shieldFlash,   _voidCol,  _poisCol),
  'rogue_3': _EffectDef(_FxType.voidOrb,       _voidCol,  _poisCol),
  'rogue_4': _EffectDef(_FxType.smokeCloud,    const Color(0xFF88BBAA), const Color(0xFF444444)),
  'rogue_5': _EffectDef(_FxType.slashArc,      _poisCol,  const Color(0xFFAAFF88)),
  'rogue_6': _EffectDef(_FxType.dotDrops,      const Color(0xFFCC3333), const Color(0xFFFF6666)),
  'rog_ult':  _EffectDef(_FxType.ultimateBurst, const Color(0xFFCC4444), _ultCol, durationMs: 900),
  // ── SORCERER ──────────────────────────────────────────────────────────────
  'sorcerer_1': _EffectDef(_FxType.lightningBolt, _fireCol,  const Color(0xFFFFCC22)),
  'sorcerer_2': _EffectDef(_FxType.buffGlow,     _fireCol,  const Color(0xFFFF6633)),
  'sorcerer_3': _EffectDef(_FxType.iceShards,    _coldCol,  const Color(0xFF88DDFF)),
  'sorcerer_4': _EffectDef(_FxType.buffGlow,     _fireCol,  const Color(0xFFFF9966)),
  'sorcerer_5': _EffectDef(_FxType.debuffArrows, _voidCol,  _fireCol),
  'sorcerer_6': _EffectDef(_FxType.debuffArrows, _debufCol, _fireCol),
  'sor_ult':    _EffectDef(_FxType.ultimateBurst, _voidCol,  _fireCol, durationMs: 900),
  // ── WARLOCK ───────────────────────────────────────────────────────────────
  'warlock_1': _EffectDef(_FxType.lightningBolt, const Color(0xFF9900CC), const Color(0xFFDD88FF)),
  'warlock_2': _EffectDef(_FxType.buffGlow,     _voidCol,  const Color(0xFF8833CC)),
  'warlock_3': _EffectDef(_FxType.voidOrb,      _voidCol,  const Color(0xFF330055)),
  'warlock_4': _EffectDef(_FxType.shieldFlash,  _coldCol,  _voidCol),
  'warlock_5': _EffectDef(_FxType.debuffArrows, _voidCol,  const Color(0xFFCC66FF)),
  'warlock_6': _EffectDef(_FxType.voidOrb,      _voidCol,  const Color(0xFFAA44FF)),
  'wlk_ult':   _EffectDef(_FxType.ultimateBurst, _voidCol,  const Color(0xFFDDAEFF), durationMs: 900),
  // ── WIZARD ────────────────────────────────────────────────────────────────
  'wizard_1': _EffectDef(_FxType.voidOrb,       const Color(0xFF4477FF), const Color(0xFFCCEEFF)),
  'wizard_2': _EffectDef(_FxType.shieldFlash,  _coldCol,  const Color(0xFF33AAEE)),
  'wizard_3': _EffectDef(_FxType.iceShards,    _coldCol,  const Color(0xFF88DDFF)),
  'wizard_4': _EffectDef(_FxType.healBurst,    _coldCol,  const Color(0xFF4488FF)),
  'wizard_5': _EffectDef(_FxType.stunStars,    _coldCol,  const Color(0xFFCCEEFF)),
  'wizard_6': _EffectDef(_FxType.shieldFlash,  _coldCol,  const Color(0xFF5599FF)),
  'wiz_ult':  _EffectDef(_FxType.ultimateBurst, _fireCol,  const Color(0xFFFF8844), durationMs: 900),
  // ── AUTO-ATTACK (basic strike, per class) ─────────────────────────────────
  'auto_barbarian': _EffectDef(_FxType.slashArc,   _physCol,               const Color(0xFFFF9966),   durationMs: 380),
  'auto_fighter':   _EffectDef(_FxType.slashArc,   _physCol,               _lightCol,                 durationMs: 380),
  'auto_monk':      _EffectDef(_FxType.slashArc,   _coldCol,               const Color(0xFF88EEFF),   durationMs: 380),
  'auto_rogue':     _EffectDef(_FxType.slashArc,   const Color(0xFF446644), const Color(0xFF88CC88), durationMs: 380),
  'auto_druid':     _EffectDef(_FxType.slashArc,   _poisCol,               const Color(0xFF44CC66),   durationMs: 380),
  'auto_ranger':    _EffectDef(_FxType.slashArc,   _poisCol,               const Color(0xFF88EE44),   durationMs: 380),
  'auto_wizard':    _EffectDef(_FxType.fireball,   _coldCol,               const Color(0xFFAAEEFF),   durationMs: 380),
  'auto_sorcerer':  _EffectDef(_FxType.fireball,   _fireCol,               const Color(0xFFFFAA44),   durationMs: 380),
  'auto_warlock':   _EffectDef(_FxType.voidOrb,    _voidCol,               const Color(0xFFCC88FF),   durationMs: 380),
  'auto_bard':      _EffectDef(_FxType.soundWave,  _voidCol,               const Color(0xFF9966CC),   durationMs: 380),
  'auto_cleric':    _EffectDef(_FxType.buffGlow,   _buffCol,               const Color(0xFFFFFFCC),   durationMs: 380),
  'auto_paladin':   _EffectDef(_FxType.fireball,   _buffCol,               const Color(0xFFFFFFCC),   durationMs: 380),
  // ── COSMETIC ATTACK EFFECTS (equipped skin overrides the auto-attack visual;
  //    e.g. a monk can throw fireballs). Keyed 'fx_<attackEffectId>'. ──────────
  'fx_fire':      _EffectDef(_FxType.fireball,      _fireCol,  const Color(0xFFFFAA44), durationMs: 420),
  'fx_frost':     _EffectDef(_FxType.iceShards,     _coldCol,  const Color(0xFFBBEEFF), durationMs: 420),
  'fx_lightning': _EffectDef(_FxType.lightningBolt, _lightCol, const Color(0xFFFFF7AA), durationMs: 420),
  'fx_holy':      _EffectDef(_FxType.fireball,      _buffCol,  _ultCol,                 durationMs: 420),
  'fx_shadow':    _EffectDef(_FxType.voidOrb,       _voidCol,  const Color(0xFFCC88FF), durationMs: 420),
  'fx_venom':     _EffectDef(_FxType.poisonCloud,   _poisCol,  const Color(0xFF88DD00), durationMs: 420),
};
