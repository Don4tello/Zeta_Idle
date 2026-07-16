import 'dart:math';
import 'package:flutter/material.dart';

// ── Public widget ─────────────────────────────────────────────────────────────

class AbilityIcon extends StatelessWidget {
  const AbilityIcon({super.key, required this.abilityId, this.size = 44.0});
  final String abilityId;
  final double size;

  @override
  Widget build(BuildContext context) {
    final d = _kIcons[abilityId];
    if (d == null) return SizedBox.square(dimension: size);
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _IconPainter(d)),
    );
  }
}

// ── Internals ─────────────────────────────────────────────────────────────────

typedef _Fn = void Function(Canvas c, double w, double h);

class _Def {
  const _Def(this.bg, this.border, this.fn);
  final Color bg, border;
  final _Fn fn;
}

class _IconPainter extends CustomPainter {
  const _IconPainter(this.d);
  final _Def d;
  @override
  void paint(Canvas c, Size s) {
    final w = s.width, h = s.height;
    final rr = RRect.fromRectAndRadius(Offset.zero & s, Radius.circular(w * .13));
    c.drawRRect(rr, Paint()..color = d.bg);
    c.save(); c.clipRRect(rr); d.fn(c, w, h); c.restore();
    c.drawRRect(rr, Paint()..color = d.border..style = PaintingStyle.stroke..strokeWidth = w * .046);
  }
  @override bool shouldRepaint(_IconPainter o) => false;
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Paint _s(Color c, double w) => Paint()
  ..color = c..strokeWidth = w..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round..style = PaintingStyle.stroke;
Paint _f(Color c) => Paint()..color = c..style = PaintingStyle.fill;

void _ln(Canvas c, double x1, double y1, double x2, double y2, Paint p) =>
    c.drawLine(Offset(x1, y1), Offset(x2, y2), p);

void _rays(Canvas c, double cx, double cy, double r1, double r2, int n, double a0, Paint p) {
  for (int i = 0; i < n; i++) {
    final a = a0 + i * 2 * pi / n;
    _ln(c, cx + cos(a) * r1, cy + sin(a) * r1, cx + cos(a) * r2, cy + sin(a) * r2, p);
  }
}

void _poly(Canvas c, double cx, double cy, double r, int sides, double a0, Paint p) {
  final path = Path();
  for (int i = 0; i < sides; i++) {
    final a = a0 + i * 2 * pi / sides;
    final x = cx + cos(a) * r, y = cy + sin(a) * r;
    i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
  }
  c.drawPath(path..close(), p);
}

void _arc(Canvas c, double cx, double cy, double r, double a0, double sweep, Paint p) =>
    c.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), a0, sweep, false, p);

// zigzag line: alternate up/down through points
void _zz(Canvas c, List<double> xy, Paint p) {
  if (xy.length < 4) return;
  final path = Path()..moveTo(xy[0], xy[1]);
  for (int i = 2; i < xy.length; i += 2) path.lineTo(xy[i], xy[i + 1]);
  c.drawPath(path, p);
}

// drop shape (teardrop)
void _drop(Canvas c, double cx, double cy, double r, Color col) {
  final p = Path()..moveTo(cx, cy);
  p.cubicTo(cx + r, cy - r, cx + r, cy - r * 2.5, cx, cy - r * 3);
  p.cubicTo(cx - r, cy - r * 2.5, cx - r, cy - r, cx, cy);
  c.drawPath(p, _f(col));
}

// ── BARBARIAN ─────────────────────────────────────────────────────────────────

void _barb1(Canvas c, double w, double h) {
  _ln(c, w*.72, h*.10, w*.12, h*.90, _s(const Color(0xFFFF6633), w*.072));
  _ln(c, w*.84, h*.30, w*.40, h*.70, _s(const Color(0xFFFF9966), w*.050));
  _ln(c, w*.92, h*.50, w*.62, h*.78, _s(const Color(0xFFFFBB99), w*.030));
  c.drawCircle(Offset(w*.14, h*.90), w*.04, _f(const Color(0xFFFF4422)));
}

void _barb2(Canvas c, double w, double h) {
  for (int i = 0; i < 3; i++) {
    _arc(c, w*.5, h*.65, w*(.13+i*.12), -pi*.75, pi*1.5,
        _s(const Color(0xFFFFAA44).withValues(alpha:1.0-i*.28), w*(.058-i*.012)));
  }
  _rays(c, w*.5, h*.28, w*.03, w*.11, 8, 0, _s(const Color(0xFFFFDD88), w*.038));
  c.drawCircle(Offset(w*.5, h*.28), w*.05, _f(const Color(0xFFFF8833)));
}

void _barb3(Canvas c, double w, double h) {
  _zz(c, [w*.68,h*.12, w*.40,h*.48, w*.55,h*.40, w*.22,h*.78],
      _s(const Color(0xFF88DD00), w*.058));
  for (int i = 0; i < 3; i++) _drop(c, w*(.32+i*.16), h*.90, w*.04, const Color(0xFF55EE44));
}

void _barb4(Canvas c, double w, double h) {
  final arm = _s(const Color(0xFFFF8833), w*.10);
  _ln(c, w*.20, h*.55, w*.80, h*.82, arm);
  _ln(c, w*.80, h*.55, w*.20, h*.82, arm);
  for (int i = 0; i < 7; i++) {
    final a = -pi*.75 + i*pi*.25;
    _ln(c, w*.5+cos(a)*w*.06, h*.28+sin(a)*h*.06,
        w*.5+cos(a)*w*(.15+(i==3 ? 0.06 : 0.0)), h*.28+sin(a)*h*.14,
        _s(i==3 ? const Color(0xFFFFEE44) : const Color(0xFFFF6622), w*.05));
  }
}

void _barb5(Canvas c, double w, double h) {
  _poly(c, w*.5, h*.52, w*.36, 5, -pi/2, _s(const Color(0xFFE88830), w*.056));
  final fc = _s(const Color(0xFFFF6600), w*.038);
  _ln(c, w*.50, h*.16, w*.35, h*.62, fc);
  _ln(c, w*.35, h*.62, w*.65, h*.80, fc);
  _ln(c, w*.65, h*.38, w*.82, h*.66, fc);
}

void _barb6(Canvas c, double w, double h) {
  for (int i = 0; i < 4; i++) {
    final path = Path()..moveTo(w*(.24+i*.13), h*.12);
    path.cubicTo(w*(.34+i*.13), h*.40, w*(.20+i*.13), h*.65, w*(.16+i*.13), h*.88);
    c.drawPath(path, _s(const Color(0xFFFF5511), w*(.072-i*.008)));
  }
}

void _barbUlt(Canvas c, double w, double h) {
  c.drawCircle(Offset(w*.5, h*.48), w*.28, _s(const Color(0xFFFFCC88), w*.054));
  c.drawCircle(Offset(w*.37, h*.48), w*.07, _f(const Color(0xFF180800)));
  c.drawCircle(Offset(w*.63, h*.48), w*.07, _f(const Color(0xFF180800)));
  for (int i = 0; i < 4; i++) _ln(c, w*(.36+i*.09), h*.72, w*(.36+i*.09), h*.82,
      _s(const Color(0xFFFFCC88), w*.04));
  for (int i = 0; i < 7; i++) {
    final a = -pi*.82 + i*pi*.27;
    _ln(c, w*.5+cos(a)*w*.28, h*.20+sin(a)*w*.28,
        w*.5+cos(a)*w*(.38+(i==3 ? 0.08 : 0.0)), h*.20+sin(a)*w*(.4+(i==3 ? 0.06 : 0.0)),
        _s(i==3?const Color(0xFFFFEE44):const Color(0xFFFF5500), w*.054));
  }
}

// ── BARD ──────────────────────────────────────────────────────────────────────

void _bard1(Canvas c, double w, double h) {
  // Vexing Verse: void-swirl note
  _ln(c, w*.55, h*.22, w*.55, h*.72, _s(const Color(0xFFCC88FF), w*.055));
  _ln(c, w*.55, h*.22, w*.80, h*.30, _s(const Color(0xFFCC88FF), w*.045));
  c.drawCircle(Offset(w*.42, h*.72), w*.12, _s(const Color(0xFF8844CC), w*.048));
  _arc(c, w*.42, h*.72, w*.07, 0, pi*1.7, _s(const Color(0xFFDD99FF), w*.032));
  c.drawCircle(Offset(w*.42, h*.72), w*.03, _f(const Color(0xFF220033)));
}

void _bard2(Canvas c, double w, double h) {
  // Dissonant Chord: broken staff + jagged crack
  for (int i = 0; i < 3; i++) {
    _ln(c, w*.16, h*(.32+i*.16), w*.84, h*(.32+i*.16), _s(const Color(0xFF9966CC), w*.034));
  }
  _zz(c, [w*.50,h*.18, w*.44,h*.40, w*.56,h*.55, w*.46,h*.75, w*.50,h*.88],
      _s(const Color(0xFFFFEE44), w*.046));
}

void _bard3(Canvas c, double w, double h) {
  // Discordant Blast: distorted arcs
  for (int i = 0; i < 3; i++) {
    final r = w*(.16+i*.14);
    c.drawArc(Rect.fromCircle(center: Offset(w*.5, h*.5), radius: r),
        -pi*.6+i*.08, pi*1.2, false,
        _s(const Color(0xFFAA66FF).withValues(alpha: 1.0-i*.25), w*(.05-i*.01)));
    // gap in arc (distortion)
    c.drawArc(Rect.fromCircle(center: Offset(w*.5, h*.5), radius: r),
        pi*.7, pi*.2, false, _s(const Color(0xFF220033), w*(.06-i*.01)));
  }
  _rays(c, w*.5, h*.5, w*.02, w*.05, 6, pi/6, _s(const Color(0xFFFFEE44), w*.03));
}

void _bard4(Canvas c, double w, double h) {
  // Virtuoso's Tempo: staff + lightning bolt
  for (int i = 0; i < 3; i++) {
    _ln(c, w*.18, h*(.30+i*.18), w*.82, h*(.30+i*.18), _s(const Color(0xFF9966CC), w*.032));
  }
  _zz(c, [w*.60,h*.14, w*.44,h*.46, w*.56,h*.46, w*.36,h*.86],
      _s(const Color(0xFFFFEE44), w*.060));
}

void _bard5(Canvas c, double w, double h) {
  // Taunt: pointing finger + emphasis marks
  _poly(c, w*.50, h*.50, w*.22, 4, pi/4, _s(const Color(0xFFBB77FF), w*.038));
  // pointing finger
  _ln(c, w*.50, h*.24, w*.50, h*.62, _s(const Color(0xFFDD99FF), w*.075));
  c.drawCircle(Offset(w*.50, h*.20), w*.07, _f(const Color(0xFFDD99FF)));
  for (int i = 0; i < 4; i++) {
    final a = -pi*.3 + i*pi*.2;
    _ln(c, w*.50+cos(a)*w*.10, h*.42+sin(a)*h*.10,
        w*.50+cos(a)*w*.18, h*.42+sin(a)*h*.18,
        _s(const Color(0xFFFFBBFF), w*.03));
  }
}

void _bard6(Canvas c, double w, double h) {
  // Cacophony: 5 overlapping wave arcs at different angles
  final cols = [const Color(0xFFAA66FF), const Color(0xFF8844CC),
    const Color(0xFFCC88FF), const Color(0xFF7733BB), const Color(0xFFBB99FF)];
  for (int i = 0; i < 5; i++) {
    _arc(c, w*.5, h*.5, w*(.18+i*.06), -pi*.5+i*.3, pi*1.0,
        _s(cols[i], w*(.048-i*.006)));
  }
}

void _brdUlt(Canvas c, double w, double h) {
  // Crescendo: rising wave peaks left→right
  final path = Path()..moveTo(w*.10, h*.70);
  path.cubicTo(w*.22, h*.60, w*.22, h*.52, w*.30, h*.55);
  path.cubicTo(w*.38, h*.58, w*.38, h*.38, w*.50, h*.42);
  path.cubicTo(w*.62, h*.46, w*.62, h*.22, w*.70, h*.28);
  path.cubicTo(w*.78, h*.34, w*.82, h*.18, w*.88, h*.22);
  c.drawPath(path, _s(const Color(0xFFCC88FF), w*.055));
  _rays(c, w*.88, h*.22, w*.04, w*.12, 6, -pi*.4, _s(const Color(0xFFFFBBFF), w*.036));
}

// ── CLERIC ────────────────────────────────────────────────────────────────────

void _cleric1(Canvas c, double w, double h) {
  // Sacred Flame: chalice + flame
  _zz(c, [w*.34,h*.38, w*.26,h*.72, w*.74,h*.72, w*.66,h*.38],
      _s(const Color(0xFF88AAFF), w*.052));
  _ln(c, w*.26, h*.72, w*.74, h*.72, _s(const Color(0xFF88AAFF), w*.052));
  _ln(c, w*.50, h*.38, w*.50, h*.28, _s(const Color(0xFF88AAFF), w*.040));
  _ln(c, w*.38, h*.28, w*.62, h*.28, _s(const Color(0xFF88AAFF), w*.040));
  // flame
  final fp = Path()..moveTo(w*.50, h*.10);
  fp.cubicTo(w*.62, h*.20, w*.60, h*.30, w*.50, h*.28);
  fp.cubicTo(w*.40, h*.30, w*.38, h*.20, w*.50, h*.10);
  c.drawPath(fp, _f(const Color(0xFFFF8844)));
}

void _cleric2(Canvas c, double w, double h) {
  // Cure Wounds: bold cross + 4 sparkles
  final cp = _s(const Color(0xFF88CCFF), w*.092);
  _ln(c, w*.50, h*.14, w*.50, h*.86, cp);
  _ln(c, w*.14, h*.50, w*.86, h*.50, cp);
  for (final o in [Offset(w*.2,h*.22),Offset(w*.8,h*.22),Offset(w*.2,h*.78),Offset(w*.8,h*.78)]) {
    _rays(c, o.dx, o.dy, w*.01, w*.05, 4, pi/4, _s(const Color(0xFFAADDFF), w*.028));
  }
}

void _cleric3(Canvas c, double w, double h) {
  // Void Judgment: eye + beam
  final ep = Path()..moveTo(w*.50, h*.32);
  ep.cubicTo(w*.75, h*.32, w*.82, h*.44, w*.50, h*.50);
  ep.cubicTo(w*.18, h*.44, w*.25, h*.32, w*.50, h*.32);
  c.drawPath(ep, _s(const Color(0xFFAA66FF), w*.048));
  c.drawCircle(Offset(w*.50, h*.42), w*.07, _f(const Color(0xFF7722CC)));
  _ln(c, w*.50, h*.50, w*.50, h*.90, _s(const Color(0xFFCC88FF), w*.056));
  _rays(c, w*.50, h*.90, w*.02, w*.09, 4, pi/4, _s(const Color(0xFFBB77FF), w*.034));
}

void _cleric4(Canvas c, double w, double h) {
  // Consecrated Ground: oval + upright cross + rings
  c.drawOval(Rect.fromCenter(center: Offset(w*.5,h*.78), width: w*.62, height: h*.20),
      _s(const Color(0xFF6688FF), w*.040));
  _ln(c, w*.50, h*.18, w*.50, h*.78, _s(const Color(0xFF88AAFF), w*.060));
  _ln(c, w*.28, h*.48, w*.72, h*.48, _s(const Color(0xFF88AAFF), w*.060));
  _arc(c, w*.5, h*.78, w*.18, 0, pi*2, _s(const Color(0xFF6688FF).withValues(alpha:.5), w*.03));
}

void _cleric5(Canvas c, double w, double h) {
  // Condemn: downward gavel
  _ln(c, w*.50, h*.32, w*.50, h*.88, _s(const Color(0xFF88AAFF), w*.055));
  // gavel head (horizontal rectangle)
  final hp = Path()..addRect(Rect.fromCenter(
      center: Offset(w*.50, h*.26), width: w*.52, height: h*.16));
  c.drawPath(hp, _f(const Color(0xFF4466CC)));
  c.drawPath(hp, _s(const Color(0xFFAABBFF), w*.04));
  _rays(c, w*.50, h*.88, w*.02, w*.10, 6, pi/6, _s(const Color(0xFF88AAFF), w*.034));
}

void _cleric6(Canvas c, double w, double h) {
  // Divine Ward: dome/barrier
  c.drawArc(Rect.fromCenter(center: Offset(w*.5,h*.62), width: w*.68, height: h*.62),
      -pi, pi, false, _s(const Color(0xFF88AAFF), w*.058));
  _ln(c, w*.16, h*.62, w*.84, h*.62, _s(const Color(0xFF88AAFF), w*.048));
  for (int i = 0; i < 4; i++) {
    _ln(c, w*(.30+i*.12), h*.62, w*(.30+i*.12), h*(.46+i%2*.08),
        _s(const Color(0xFFAABBFF), w*.034));
  }
}

void _clrUlt(Canvas c, double w, double h) {
  // Miracle: full radiance burst — 8 long + 8 short
  _rays(c, w*.5, h*.5, w*.08, w*.40, 8, 0, _s(const Color(0xFFFFFFFF), w*.060));
  _rays(c, w*.5, h*.5, w*.08, w*.28, 8, pi/8, _s(const Color(0xFFCCDDFF), w*.034));
  c.drawCircle(Offset(w*.5, h*.5), w*.09, _f(const Color(0xFFFFFFFF)));
  c.drawCircle(Offset(w*.5, h*.5), w*.05, _f(const Color(0xFF4466CC)));
}

// ── DRUID ─────────────────────────────────────────────────────────────────────

void _druid1(Canvas c, double w, double h) {
  // Thorn Lash: curved vine + thorns
  final vp = Path()..moveTo(w*.14, h*.80);
  vp.cubicTo(w*.30, h*.40, w*.70, h*.60, w*.86, h*.20);
  c.drawPath(vp, _s(const Color(0xFF44CC66), w*.056));
  for (final t in [Offset(w*.32,h*.65), Offset(w*.54,h*.50), Offset(w*.74,h*.34)]) {
    _ln(c, t.dx, t.dy, t.dx+w*.08, t.dy-h*.10, _s(const Color(0xFF88EE44), w*.036));
    _ln(c, t.dx, t.dy, t.dx-w*.06, t.dy-h*.08, _s(const Color(0xFF88EE44), w*.028));
  }
}

void _druid2(Canvas c, double w, double h) {
  // Healing Word: leaf outline + heart inside
  final lp = Path()..moveTo(w*.50, h*.14);
  lp.cubicTo(w*.84, h*.28, w*.84, h*.72, w*.50, h*.86);
  lp.cubicTo(w*.16, h*.72, w*.16, h*.28, w*.50, h*.14);
  c.drawPath(lp, _s(const Color(0xFF44CC66), w*.052));
  // heart
  final hp = Path()..moveTo(w*.50, h*.58);
  hp.cubicTo(w*.50, h*.48, w*.36, h*.44, w*.36, h*.54);
  hp.cubicTo(w*.36, h*.60, w*.50, h*.68, w*.50, h*.68);
  hp.cubicTo(w*.50, h*.68, w*.64, h*.60, w*.64, h*.54);
  hp.cubicTo(w*.64, h*.44, w*.50, h*.48, w*.50, h*.58);
  c.drawPath(hp, _f(const Color(0xFF44FF88)));
}

void _druid3(Canvas c, double w, double h) {
  // Glacier Slam: large icicle
  _poly(c, w*.50, h*.22, w*.22, 3, -pi/2, _f(const Color(0xFF2255AA)));
  _poly(c, w*.50, h*.22, w*.22, 3, -pi/2, _s(const Color(0xFF44BBFF), w*.048));
  // spike shaft
  _pts(c, [w*.38,h*.38, w*.32,h*.88, w*.50,h*.78, w*.68,h*.88, w*.62,h*.38], _f(const Color(0xFF1133AA)));
  _pts(c, [w*.38,h*.38, w*.32,h*.88, w*.50,h*.78, w*.68,h*.88, w*.62,h*.38],
      _s(const Color(0xFF44BBFF), w*.042), close: true);
  // facets
  _ln(c, w*.50, h*.22, w*.50, h*.78, _s(const Color(0xFF88DDFF), w*.025));
}

void _pts(Canvas c, List<double> xy, Paint p, {bool close = false}) {
  if (xy.length < 4) return;
  final path = Path()..moveTo(xy[0], xy[1]);
  for (int i = 2; i < xy.length; i += 2) path.lineTo(xy[i], xy[i+1]);
  if (close) path.close();
  c.drawPath(path, p);
}

void _druid4(Canvas c, double w, double h) {
  // Spore Cloud: mushroom cap + spore dots
  final mp = Path()..moveTo(w*.22, h*.56);
  mp.cubicTo(w*.18, h*.28, w*.82, h*.28, w*.78, h*.56);
  c.drawPath(mp, _f(const Color(0xFF225522)));
  c.drawPath(mp, _s(const Color(0xFF55EE77), w*.048));
  _ln(c, w*.50, h*.56, w*.50, h*.88, _s(const Color(0xFF44AA55), w*.048));
  for (final o in [Offset(w*.22,h*.32),Offset(w*.78,h*.38),Offset(w*.44,h*.20),
                    Offset(w*.60,h*.22),Offset(w*.34,h*.40)]) {
    c.drawCircle(o, w*.028, _f(const Color(0xFFAAFF88)));
  }
}

void _druid5(Canvas c, double w, double h) {
  // Nature's Grasp: 5 root-fingers from grip
  for (int i = 0; i < 5; i++) {
    final a = -pi*.4 + i*pi*.2;
    final path = Path()..moveTo(w*.50, h*.44);
    path.cubicTo(
      w*.50+cos(a)*w*.18, h*.44+sin(a)*h*.22+h*.10,
      w*.50+cos(a)*w*.28, h*.44+sin(a)*h*.32+h*.16,
      w*.50+cos(a)*w*.32, h*.44+sin(a)*h*.42+h*.20,
    );
    c.drawPath(path, _s(const Color(0xFF44CC66), w*(.06-i.abs()*.003)));
  }
  c.drawCircle(Offset(w*.50, h*.38), w*.10, _f(const Color(0xFF224422)));
  c.drawCircle(Offset(w*.50, h*.38), w*.10, _s(const Color(0xFF55EE77), w*.038));
}

void _druid6(Canvas c, double w, double h) {
  // Entangle: knotted root tangle
  final cols = [const Color(0xFF44BB55), const Color(0xFF66CC44), const Color(0xFF33AA44)];
  for (int i = 0; i < 3; i++) {
    final path = Path()..moveTo(w*(.16+i*.12), h*.18);
    path.cubicTo(w*(.70-i*.10), h*.40, w*(.30+i*.15), h*.60, w*(.80-i*.10), h*.82);
    c.drawPath(path, _s(cols[i], w*(.060-i*.006)));
  }
  c.drawCircle(Offset(w*.50, h*.50), w*.08, _s(const Color(0xFF88EE66), w*.04));
}

void _drdUlt(Canvas c, double w, double h) {
  // Primal Avatar: bear face + nature aura
  c.drawCircle(Offset(w*.5, h*.5), w*.30, _s(const Color(0xFF55EE77), w*.052));
  // ears
  _poly(c, w*.33, h*.26, w*.10, 3, -pi*.6, _f(const Color(0xFF224422)));
  _poly(c, w*.67, h*.26, w*.10, 3, -pi*.4, _f(const Color(0xFF224422)));
  _poly(c, w*.33, h*.26, w*.10, 3, -pi*.6, _s(const Color(0xFF55EE77), w*.036));
  _poly(c, w*.67, h*.26, w*.10, 3, -pi*.4, _s(const Color(0xFF55EE77), w*.036));
  // eyes
  c.drawCircle(Offset(w*.38, h*.48), w*.05, _f(const Color(0xFF88FF99)));
  c.drawCircle(Offset(w*.62, h*.48), w*.05, _f(const Color(0xFF88FF99)));
  // snout
  c.drawOval(Rect.fromCenter(center: Offset(w*.5, h*.64), width: w*.24, height: h*.14),
      _s(const Color(0xFF44CC66), w*.038));
  _rays(c, w*.5, h*.5, w*.30, w*.44, 6, pi/6, _s(const Color(0xFF44FF88), w*.032));
}

// ── FIGHTER ───────────────────────────────────────────────────────────────────

void _ftr1(Canvas c, double w, double h) {
  // Shield Bash: pentagon + impact star
  _poly(c, w*.44, h*.50, w*.32, 5, -pi/2, _s(const Color(0xFFFFE040), w*.054));
  _rays(c, w*.76, h*.38, w*.03, w*.12, 6, 0, _s(const Color(0xFFFFFF88), w*.042));
  c.drawCircle(Offset(w*.76, h*.38), w*.04, _f(const Color(0xFFFFEE44)));
}

void _ftr2(Canvas c, double w, double h) {
  // Combat Stance: two crossed swords
  for (final pts in [
    [w*.20,h*.18,w*.80,h*.82, w*.20,h*.72,w*.58,h*.34, w*.64,h*.28,w*.80,h*.20],
    [w*.80,h*.18,w*.20,h*.82, w*.80,h*.72,w*.42,h*.34, w*.36,h*.28,w*.20,h*.20],
  ]) {
    _ln(c, pts[0], pts[1], pts[2], pts[3], _s(const Color(0xFFFFE040), w*.058));
    _ln(c, pts[4], pts[5], pts[6], pts[7], _s(const Color(0xFFFFCC00), w*.038));
  }
  c.drawCircle(Offset(w*.50, h*.50), w*.04, _f(const Color(0xFFFFFF88)));
}

void _ftr3(Canvas c, double w, double h) {
  // Thunder Strike: sword + lightning overlay
  _ln(c, w*.50, h*.14, w*.50, h*.86, _s(const Color(0xFFFFE040), w*.058));
  _ln(c, w*.38, h*.14, w*.62, h*.14, _s(const Color(0xFFFFCC00), w*.046));
  _zz(c, [w*.62,h*.20, w*.44,h*.44, w*.58,h*.44, w*.34,h*.80],
      _s(const Color(0xFFFFFF44), w*.050));
}

void _ftr4(Canvas c, double w, double h) {
  // Second Wind: upward spiral + heart
  final sp = Path()..moveTo(w*.50, h*.82);
  for (int i = 0; i < 12; i++) {
    final a = -pi/2 + i*pi*.55;
    final r = w*(.04+i*.03);
    sp.lineTo(w*.50+cos(a)*r, h*.50-i*h*.034+sin(a)*r);
  }
  c.drawPath(sp, _s(const Color(0xFF88DDFF), w*.040));
  // heart at top
  final hp = Path()..moveTo(w*.50, h*.28);
  hp.cubicTo(w*.50,h*.18, w*.36,h*.14, w*.36,h*.24);
  hp.cubicTo(w*.36,h*.30, w*.50,h*.38, w*.50,h*.38);
  hp.cubicTo(w*.50,h*.38, w*.64,h*.30, w*.64,h*.24);
  hp.cubicTo(w*.64,h*.14, w*.50,h*.18, w*.50,h*.28);
  c.drawPath(hp, _f(const Color(0xFFFF6688)));
}

void _ftr5(Canvas c, double w, double h) {
  // Intimidate: large open eye + rays
  final ep = Path()..moveTo(w*.50, h*.36);
  ep.cubicTo(w*.82, h*.36, w*.86, h*.56, w*.50, h*.64);
  ep.cubicTo(w*.14, h*.56, w*.18, h*.36, w*.50, h*.36);
  c.drawPath(ep, _s(const Color(0xFFFFE040), w*.054));
  c.drawCircle(Offset(w*.50, h*.50), w*.10, _f(const Color(0xFFFFCC00)));
  c.drawCircle(Offset(w*.50, h*.50), w*.05, _f(const Color(0xFF1A1400)));
  _rays(c, w*.50, h*.50, w*.18, w*.28, 8, pi/8, _s(const Color(0xFFFFEE88), w*.030));
}

void _ftr6(Canvas c, double w, double h) {
  // Disarm: open hand
  for (int i = 0; i < 4; i++) {
    _ln(c, w*(.32+i*.11), h*.60, w*(.32+i*.11), h*.22, _s(const Color(0xFFFFCC44), w*.055));
  }
  // thumb
  _ln(c, w*.22, h*.60, w*.22, h*.42, _s(const Color(0xFFFFCC44), w*.052));
  _ln(c, w*.22, h*.60, w*.76, h*.60, _s(const Color(0xFFFFCC44), w*.060));
  // falling sword
  _ln(c, w*.70, h*.22, w*.86, h*.50, _s(const Color(0xFFFFFF88), w*.036));
  _ln(c, w*.64, h*.18, w*.80, h*.16, _s(const Color(0xFFFFFF88), w*.030));
}

void _ftrUlt(Canvas c, double w, double h) {
  // Blade Storm: 5 blades in pinwheel
  for (int i = 0; i < 5; i++) {
    final a = i * 2 * pi / 5;
    final cx = w*.50+cos(a)*w*.18, cy = h*.50+sin(a)*h*.18;
    _ln(c, cx, cy, cx+cos(a+pi*.6)*w*.20, cy+sin(a+pi*.6)*h*.20,
        _s(const Color(0xFFFFE040), w*.058));
    _ln(c, cx, cy, cx+cos(a+pi*.5)*w*.08, cy+sin(a+pi*.5)*h*.08,
        _s(const Color(0xFFFFFF88), w*.034));
  }
  c.drawCircle(Offset(w*.5, h*.5), w*.06, _f(const Color(0xFFFFEE44)));
}

// ── MONK ──────────────────────────────────────────────────────────────────────

void _monk1(Canvas c, double w, double h) {
  // Flurry of Blows: 4 fist impact marks in arc
  for (int i = 0; i < 4; i++) {
    final x = w*(.22+i*.18), y = h*(.28+i*.14);
    _rays(c, x, y, w*.02, w*.08, 4, i*.4, _s(const Color(0xFF44BBFF), w*.040));
    c.drawCircle(Offset(x, y), w*.035, _s(const Color(0xFF88DDFF), w*.03));
  }
}

void _monk2(Canvas c, double w, double h) {
  // Iron Skin: diamond grid (armor scales)
  for (int r = 0; r < 3; r++) {
    for (int col = 0; col < 3; col++) {
      final cx = w*(.24+col*.26), cy = h*(.24+r*.26);
      _poly(c, cx, cy, w*.10, 4, 0, _s(const Color(0xFF44BBFF), w*.030));
    }
  }
  c.drawCircle(Offset(w*.5, h*.5), w*.07, _f(const Color(0xFF0A2233)));
  c.drawCircle(Offset(w*.5, h*.5), w*.07, _s(const Color(0xFF88DDFF), w*.036));
}

void _monk3(Canvas c, double w, double h) {
  // Void Strike: fist + void tendrils
  c.drawRRect(RRect.fromRectAndRadius(
    Rect.fromCenter(center: Offset(w*.5, h*.5), width: w*.36, height: h*.34),
    Radius.circular(w*.06)), _s(const Color(0xFF44BBFF), w*.052));
  for (int i = 0; i < 5; i++) {
    final a = pi*.3 + i*pi*.3;
    final path = Path()..moveTo(w*.5+cos(a)*w*.18, h*.5+sin(a)*h*.18);
    path.cubicTo(w*.5+cos(a+.8)*w*.28, h*.5+sin(a+.8)*h*.28,
        w*.5+cos(a+.4)*w*.38, h*.5+sin(a+.4)*h*.38,
        w*.5+cos(a)*w*.40, h*.5+sin(a)*h*.40);
    c.drawPath(path, _s(const Color(0xFF9944FF), w*.034));
  }
}

void _monk4(Canvas c, double w, double h) {
  // Ki Surge: vertical energy column + spiral
  _ln(c, w*.50, h*.82, w*.50, h*.12, _s(const Color(0xFF44BBFF), w*.060));
  for (int i = 0; i < 8; i++) {
    final a = i*pi*.75;
    final y = h*.80-i*h*.085;
    _arc(c, w*.50, y, w*(.06+i*.02), a, pi*1.0,
        _s(const Color(0xFF88DDFF).withValues(alpha:.5+i*.06), w*.028));
  }
  _rays(c, w*.50, h*.12, w*.04, w*.14, 6, 0, _s(const Color(0xFF88EEFF), w*.040));
}

void _monk5(Canvas c, double w, double h) {
  // Pressure Point: body oval + glow dot
  c.drawOval(Rect.fromCenter(center: Offset(w*.5,h*.48), width: w*.30, height: h*.60),
      _s(const Color(0xFF44BBFF).withValues(alpha:.5), w*.036));
  c.drawCircle(Offset(w*.50, h*.48), w*.10, _f(const Color(0xFF002244)));
  c.drawCircle(Offset(w*.50, h*.48), w*.10, _s(const Color(0xFF44BBFF), w*.040));
  _rays(c, w*.50, h*.48, w*.10, w*.18, 6, 0, _s(const Color(0xFFAAEEFF), w*.030));
  c.drawCircle(Offset(w*.50, h*.48), w*.04, _f(const Color(0xFF44EEFF)));
}

void _monk6(Canvas c, double w, double h) {
  // Ki Disruption: broken energy circle + fragments
  c.drawArc(Rect.fromCircle(center: Offset(w*.5, h*.5), radius: w*.30),
      pi*.2, pi*1.6, false, _s(const Color(0xFF44BBFF), w*.054));
  for (int i = 0; i < 4; i++) {
    final a = i*pi*.5+pi*.1;
    c.drawCircle(Offset(w*.5+cos(a)*w*.44, h*.5+sin(a)*h*.44), w*.03,
        _f(const Color(0xFF88DDFF)));
  }
  _rays(c, w*.5, h*.5, w*.04, w*.10, 4, pi*.1, _s(const Color(0xFF88DDFF), w*.036));
}

void _mnkUlt(Canvas c, double w, double h) {
  // Thousand Fists: 8 fists in spiral
  for (int i = 0; i < 8; i++) {
    final a = i*pi/4;
    final r = w*(.12+i*.022);
    final x = w*.5+cos(a)*r, y = h*.5+sin(a)*r;
    c.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(x,y), width: w*.10, height: h*.09),
      Radius.circular(w*.02)), _s(const Color(0xFF44BBFF), w*.030));
  }
  c.drawCircle(Offset(w*.5, h*.5), w*.06, _f(const Color(0xFF003344)));
  c.drawCircle(Offset(w*.5, h*.5), w*.06, _s(const Color(0xFF44EEFF), w*.038));
}

// ── PALADIN ───────────────────────────────────────────────────────────────────

void _pal1(Canvas c, double w, double h) {
  // Divine Smite: glowing fist + halo
  c.drawRRect(RRect.fromRectAndRadius(
    Rect.fromCenter(center: Offset(w*.5, h*.58), width: w*.34, height: h*.30),
    Radius.circular(w*.06)), _f(const Color(0xFF332200)));
  c.drawRRect(RRect.fromRectAndRadius(
    Rect.fromCenter(center: Offset(w*.5, h*.58), width: w*.34, height: h*.30),
    Radius.circular(w*.06)), _s(const Color(0xFFFFD700), w*.050));
  c.drawCircle(Offset(w*.5, h*.30), w*.18, _s(const Color(0xFFFFEE88), w*.042));
  _rays(c, w*.5, h*.30, w*.18, w*.26, 8, 0, _s(const Color(0xFFFFD700).withValues(alpha:.6), w*.026));
}

void _pal2(Canvas c, double w, double h) {
  // Lay on Hands: two palms + light
  for (final dx in [-1.0, 1.0]) {
    for (int i = 0; i < 4; i++) {
      _ln(c, w*(.50+dx*.12)+i*w*.06*dx*(-1), h*.30,
          w*(.50+dx*.12)+i*w*.06*dx*(-1), h*.62,
          _s(const Color(0xFFFFD700), w*.042));
    }
    _ln(c, w*(.50+dx*.12)-w*.06*dx*(-1)*4, h*.62,
        w*(.50+dx*.12)+w*.06*dx*(-1), h*.62,
        _s(const Color(0xFFFFD700), w*.048));
  }
  _rays(c, w*.50, h*.46, w*.02, w*.20, 6, pi/6, _s(const Color(0xFFFFEE88), w*.030));
}

void _pal3(Canvas c, double w, double h) {
  // Holy Bolt: 6-pointed star
  _poly(c, w*.5, h*.5, w*.34, 3, -pi/2, _s(const Color(0xFFFFD700), w*.050));
  _poly(c, w*.5, h*.5, w*.34, 3, pi/6, _s(const Color(0xFFFFEE88), w*.040));
  c.drawCircle(Offset(w*.5, h*.5), w*.08, _f(const Color(0xFFFFFFCC)));
  _rays(c, w*.5, h*.5, w*.08, w*.14, 6, 0, _s(const Color(0xFFFFDD44), w*.028));
}

void _pal4(Canvas c, double w, double h) {
  // Sacred Aura: 3 rings with beads
  for (int i = 0; i < 3; i++) {
    final r = w*(.14+i*.12);
    _arc(c, w*.5, h*.5, r, 0, pi*2, _s(const Color(0xFFFFD700).withValues(alpha:1.0-i*.28), w*(.052-i*.010)));
    for (int j = 0; j < 4; j++) {
      final a = j*pi/2;
      c.drawCircle(Offset(w*.5+cos(a)*r, h*.5+sin(a)*r), w*.025, _f(const Color(0xFFFFEE88)));
    }
  }
  c.drawCircle(Offset(w*.5, h*.5), w*.05, _f(const Color(0xFFFFD700)));
}

void _pal5(Canvas c, double w, double h) {
  // Divine Judgment: balance scales
  _ln(c, w*.50, h*.18, w*.50, h*.70, _s(const Color(0xFFFFD700), w*.048));
  _ln(c, w*.22, h*.30, w*.78, h*.30, _s(const Color(0xFFFFD700), w*.052));
  // two pans
  for (final dx in [-1.0, 1.0]) {
    _ln(c, w*.50+dx*w*.28, h*.30, w*.50+dx*w*.28, h*.52, _s(const Color(0xFFFFCC44), w*.030));
    c.drawArc(Rect.fromCenter(center: Offset(w*.50+dx*w*.28, h*.52), width: w*.28, height: h*.10),
        0, pi, true, _s(const Color(0xFFFFD700), w*.042));
  }
  _rays(c, w*.50, h*.18, w*.02, w*.08, 4, pi/4, _s(const Color(0xFFFFEE88), w*.030));
}

void _pal6(Canvas c, double w, double h) {
  // Sacred Pyre: altar base + flame column
  final altar = Path()
    ..addRect(Rect.fromLTWH(w*.24, h*.70, w*.52, h*.16));
  c.drawPath(altar, _f(const Color(0xFF443300)));
  c.drawPath(altar, _s(const Color(0xFFFFCC44), w*.040));
  // flame column
  for (int i = 0; i < 5; i++) {
    final fp = Path()..moveTo(w*.50, h*.68-i*h*.10);
    fp.cubicTo(w*.40, h*.58-i*h*.10, w*.60, h*.52-i*h*.10, w*.50, h*.58-i*h*.10);
    c.drawPath(fp, _s(const Color(0xFFFF8822).withValues(alpha:1.0-i*.18), w*(.05-i*.006)));
  }
}

void _palUlt(Canvas c, double w, double h) {
  // Divine Judgement: wings + crown
  for (final dx in [-1.0, 1.0]) {
    final wp = Path()..moveTo(w*.50, h*.54);
    wp.cubicTo(w*.50+dx*w*.22, h*.38, w*.50+dx*w*.40, h*.28, w*.50+dx*w*.44, h*.42);
    wp.cubicTo(w*.50+dx*w*.36, h*.50, w*.50+dx*w*.18, h*.56, w*.50, h*.54);
    c.drawPath(wp, _f(const Color(0xFF332200)));
    c.drawPath(wp, _s(const Color(0xFFFFD700), w*.048));
  }
  // crown
  _ln(c, w*.28, h*.28, w*.28, h*.14, _s(const Color(0xFFFFEE88), w*.040));
  _ln(c, w*.50, h*.26, w*.50, h*.10, _s(const Color(0xFFFFEE88), w*.040));
  _ln(c, w*.72, h*.28, w*.72, h*.14, _s(const Color(0xFFFFEE88), w*.040));
  _ln(c, w*.28, h*.28, w*.72, h*.28, _s(const Color(0xFFFFD700), w*.044));
  for (final cx in [0.28, 0.50, 0.72]) {
    c.drawCircle(Offset(w*cx, h*.12), w*.028, _f(const Color(0xFFFFEE44)));
  }
}

// ── RANGER ────────────────────────────────────────────────────────────────────

void _rng1(Canvas c, double w, double h) {
  // Poison Arrow: arrow + drip drops
  _ln(c, w*.20, h*.78, w*.78, h*.20, _s(const Color(0xFF44CC66), w*.054));
  _poly(c, w*.80, h*.18, w*.10, 3, -pi*.15, _f(const Color(0xFF44CC66)));
  _drop(c, w*.72, h*.86, w*.04, const Color(0xFF55EE77));
  _drop(c, w*.80, h*.82, w*.035, const Color(0xFF44DD66));
  _drop(c, w*.64, h*.90, w*.03, const Color(0xFF33CC55));
}

void _rng2(Canvas c, double w, double h) {
  // Hunter's Mark: concentric target circles + crosshair
  for (int i = 0; i < 3; i++) {
    _arc(c, w*.5, h*.5, w*(.12+i*.12), 0, pi*2,
        _s(const Color(0xFF44CC66).withValues(alpha:1.0-i*.25), w*(.050-i*.008)));
  }
  _ln(c, w*.50, h*.08, w*.50, h*.38, _s(const Color(0xFF88EE88), w*.030));
  _ln(c, w*.50, h*.62, w*.50, h*.92, _s(const Color(0xFF88EE88), w*.030));
  _ln(c, w*.08, h*.50, w*.38, h*.50, _s(const Color(0xFF88EE88), w*.030));
  _ln(c, w*.62, h*.50, w*.92, h*.50, _s(const Color(0xFF88EE88), w*.030));
  c.drawCircle(Offset(w*.5, h*.5), w*.04, _f(const Color(0xFF44FF66)));
}

void _rng3(Canvas c, double w, double h) {
  // Blizzard Arrow: arrow + snowflake crystal
  _ln(c, w*.36, h*.78, w*.72, h*.30, _s(const Color(0xFF44BBFF), w*.054));
  _poly(c, w*.72, h*.28, w*.09, 3, -pi*.1, _f(const Color(0xFF44BBFF)));
  // snowflake behind
  _rays(c, w*.24, h*.68, w*.02, w*.13, 6, 0, _s(const Color(0xFF88DDFF), w*.032));
  _rays(c, w*.24, h*.68, w*.06, w*.10, 6, pi/6, _s(const Color(0xFFCCEEFF), w*.022));
  c.drawCircle(Offset(w*.24, h*.68), w*.03, _f(const Color(0xFFFFFFFF)));
}

void _rng4(Canvas c, double w, double h) {
  // Predator's Stance: diamond frame + eye
  _poly(c, w*.5, h*.5, w*.36, 4, 0, _s(const Color(0xFF44CC66), w*.050));
  final ep = Path()..moveTo(w*.50, h*.40);
  ep.cubicTo(w*.70, h*.40, w*.74, h*.54, w*.50, h*.60);
  ep.cubicTo(w*.26, h*.54, w*.30, h*.40, w*.50, h*.40);
  c.drawPath(ep, _s(const Color(0xFF88EE88), w*.040));
  c.drawCircle(Offset(w*.5, h*.50), w*.07, _f(const Color(0xFF44CC66)));
  c.drawCircle(Offset(w*.5, h*.50), w*.03, _f(const Color(0xFF002200)));
}

void _rng5(Canvas c, double w, double h) {
  // Crippling Shot: arrow + impact mark at endpoint
  _ln(c, w*.22, h*.80, w*.70, h*.32, _s(const Color(0xFF44CC66), w*.052));
  _poly(c, w*.72, h*.30, w*.09, 3, -pi*.1, _f(const Color(0xFF44CC66)));
  _rays(c, w*.72, h*.30, w*.04, w*.14, 6, 0, _s(const Color(0xFF88FF88), w*.038));
  _ln(c, w*.62, h*.42, w*.50, h*.68, _s(const Color(0xFFFF6644), w*.036));
  _ln(c, w*.72, h*.38, w*.60, h*.64, _s(const Color(0xFFFF6644), w*.028));
}

void _rng6(Canvas c, double w, double h) {
  // Hunter's Trap: two curved jaws + center pin
  c.drawArc(Rect.fromCenter(center: Offset(w*.5, h*.5), width: w*.56, height: h*.36),
      pi*.1, pi*.8, false, _s(const Color(0xFF44CC66), w*.056));
  c.drawArc(Rect.fromCenter(center: Offset(w*.5, h*.5), width: w*.56, height: h*.36),
      pi*1.1, pi*.8, false, _s(const Color(0xFF44CC66), w*.056));
  // teeth on top jaw
  for (int i = 0; i < 4; i++) {
    final a = pi*.2+i*pi*.2;
    _ln(c, w*.5+cos(a)*w*.24, h*.5+sin(a)*h*.16,
        w*.5+cos(a)*w*.24, h*.5+sin(a)*h*.22,
        _s(const Color(0xFF88EE88), w*.028));
  }
  c.drawCircle(Offset(w*.5, h*.5), w*.05, _f(const Color(0xFF44CC66)));
}

void _rngUlt(Canvas c, double w, double h) {
  // Arrow Rain: 5 arrows falling from above
  for (int i = 0; i < 5; i++) {
    final x = w*(.18+i*.16), ya = h*(.10+i*.06);
    _ln(c, x, ya+h*.52, x+(i.isEven?0:w*.04), ya, _s(const Color(0xFF44CC66), w*.044));
    _poly(c, x+(i.isEven?0:w*.04), ya, w*.07, 3, -pi/2+.1*i,
        _f(const Color(0xFF44CC66)));
  }
}

// ── ROGUE ─────────────────────────────────────────────────────────────────────

void _rog1(Canvas c, double w, double h) {
  // Sneak Attack: dagger + shadow offset
  _ln(c, w*.58, h*.84, w*.82, h*.20, _s(const Color(0xFF338844).withValues(alpha:.4), w*.052));
  _ln(c, w*.50, h*.80, w*.74, h*.16, _s(const Color(0xFF44EE66), w*.052));
  _ln(c, w*.50, h*.80, w*.58, h*.76, _s(const Color(0xFF55FF77), w*.050));
  _poly(c, w*.74, h*.14, w*.08, 3, -pi*.12, _f(const Color(0xFF44EE66)));
}

void _rog2(Canvas c, double w, double h) {
  // Evasion: ghostly body offset with streaks
  c.drawOval(Rect.fromCenter(center: Offset(w*.42, h*.36), width: w*.20, height: h*.24),
      _s(const Color(0xFF44EE66).withValues(alpha:.3), w*.040));
  _ln(c, w*.42, h*.48, w*.42, h*.72, _s(const Color(0xFF44EE66).withValues(alpha:.3), w*.048));
  c.drawOval(Rect.fromCenter(center: Offset(w*.60, h*.40), width: w*.20, height: h*.24),
      _s(const Color(0xFF44EE66), w*.040));
  _ln(c, w*.60, h*.52, w*.60, h*.76, _s(const Color(0xFF44EE66), w*.048));
  for (int i = 0; i < 3; i++) {
    _ln(c, w*(.30-i*.04), h*(.40+i*.08), w*(.50-i*.04), h*(.40+i*.08),
        _s(const Color(0xFF88FF99).withValues(alpha:.6-i*.15), w*.022));
  }
}

void _rog3(Canvas c, double w, double h) {
  // Shadow Blade: curved crescent blade
  c.drawArc(Rect.fromCenter(center: Offset(w*.5, h*.5), width: w*.60, height: h*.60),
      -pi*.7, pi*1.4, false, _s(const Color(0xFF44EE66), w*.058));
  c.drawArc(Rect.fromCenter(center: Offset(w*.56, h*.50), width: w*.44, height: h*.44),
      -pi*.7, pi*1.4, false, _s(const Color(0xFF002211), w*.060));
  // void glow edge
  c.drawArc(Rect.fromCenter(center: Offset(w*.5, h*.5), width: w*.68, height: h*.68),
      -pi*.8, pi*1.6, false, _s(const Color(0xFFAA44FF).withValues(alpha:.5), w*.030));
}

void _rog4(Canvas c, double w, double h) {
  // Smoke Bomb: cloud + smoke trails
  for (final o in [Offset(w*.38,h*.56),Offset(w*.52,h*.48),Offset(w*.65,h*.54)]) {
    c.drawCircle(o, w*.16, _f(const Color(0xFF334444)));
    c.drawCircle(o, w*.16, _s(const Color(0xFF88BBAA), w*.030));
  }
  for (int i = 0; i < 3; i++) {
    final path = Path()..moveTo(w*(.40+i*.10), h*.38);
    path.cubicTo(w*(.36+i*.10), h*.22, w*(.44+i*.10), h*.14, w*(.40+i*.10), h*.08);
    c.drawPath(path, _s(const Color(0xFF88BBAA).withValues(alpha:.5-i*.12), w*.030));
  }
}

void _rog5(Canvas c, double w, double h) {
  // Kidney Shot: fist + impact burst
  c.drawRRect(RRect.fromRectAndRadius(
    Rect.fromCenter(center: Offset(w*.44, h*.56), width: w*.34, height: h*.28),
    Radius.circular(w*.06)), _f(const Color(0xFF113322)));
  c.drawRRect(RRect.fromRectAndRadius(
    Rect.fromCenter(center: Offset(w*.44, h*.56), width: w*.34, height: h*.28),
    Radius.circular(w*.06)), _s(const Color(0xFF44EE66), w*.048));
  _rays(c, w*.66, h*.42, w*.02, w*.12, 6, pi/6, _s(const Color(0xFF88FF99), w*.038));
  c.drawCircle(Offset(w*.66, h*.42), w*.04, _f(const Color(0xFFAAFFBB)));
}

void _rog6(Canvas c, double w, double h) {
  // Hemorrhage: 3 descending blood drops
  final sizes = [w*.075, w*.058, w*.042];
  final xs = [w*.40, w*.54, w*.64];
  final ys = [h*.34, h*.56, h*.72];
  for (int i = 0; i < 3; i++) {
    _drop(c, xs[i], ys[i]+sizes[i]*3, sizes[i], const Color(0xFFCC2222));
    c.drawLine(Offset(xs[i], ys[i]+sizes[i]*3),
               Offset(xs[i], ys[i]+sizes[i]*4.5),
               _s(const Color(0xFFCC2222), sizes[i]*.6));
  }
}

void _rogUlt(Canvas c, double w, double h) {
  // Death Mark: target crosshair + skull
  for (int i = 0; i < 3; i++) {
    _arc(c, w*.5, h*.5, w*(.10+i*.10), 0, pi*2,
        _s(const Color(0xFFCC4444).withValues(alpha:1.0-i*.28), w*(.048-i*.008)));
  }
  _ln(c, w*.50, h*.08, w*.50, h*.34, _s(const Color(0xFFEE4444), w*.032));
  _ln(c, w*.50, h*.66, w*.50, h*.92, _s(const Color(0xFFEE4444), w*.032));
  _ln(c, w*.08, h*.50, w*.34, h*.50, _s(const Color(0xFFEE4444), w*.032));
  _ln(c, w*.66, h*.50, w*.92, h*.50, _s(const Color(0xFFEE4444), w*.032));
  // mini skull
  c.drawCircle(Offset(w*.5, h*.48), w*.10, _f(const Color(0xFF330000)));
  c.drawCircle(Offset(w*.5, h*.48), w*.10, _s(const Color(0xFFFFCC88), w*.028));
  c.drawCircle(Offset(w*.44, h*.48), w*.028, _f(const Color(0xFF330000)));
  c.drawCircle(Offset(w*.56, h*.48), w*.028, _f(const Color(0xFF330000)));
  for (int i = 0; i < 3; i++) _ln(c, w*(.43+i*.07), h*.56, w*(.43+i*.07), h*.60,
      _s(const Color(0xFFFFCC88), w*.020));
}

// ── SORCERER ─────────────────────────────────────────────────────────────────

void _sor1(Canvas c, double w, double h) {
  // Chaos Bolt: jagged irregular burst
  final angles = [0.0, 0.6, 1.1, 1.8, 2.5, 3.0, 3.7, 4.3, 5.0, 5.7];
  final radii  = [w*.34,w*.28,w*.38,w*.24,w*.36,w*.30,w*.40,w*.26,w*.34,w*.32];
  final path = Path()..moveTo(w*.5+cos(0)*radii[0], h*.5+sin(0)*radii[0]);
  for (int i = 1; i < angles.length; i++) {
    path.lineTo(w*.5+cos(angles[i])*radii[i], h*.5+sin(angles[i])*radii[i]);
  }
  path.close();
  c.drawPath(path, _f(const Color(0xFF1A0500)));
  c.drawPath(path, _s(const Color(0xFFFF5022), w*.050));
  c.drawCircle(Offset(w*.5, h*.5), w*.08, _f(const Color(0xFFFF8844)));
}

void _sor2(Canvas c, double w, double h) {
  // Draconic Vigor: dragon scale pattern
  for (int r = 0; r < 3; r++) {
    for (int col = 0; col < 3+(r%2); col++) {
      final cx = w*(.20+col*.24-(r%2)*0.12), cy = h*(.20+r*.24);
      c.drawArc(Rect.fromCenter(center: Offset(cx,cy), width: w*.22, height: h*.16),
          0, pi, false, _s(const Color(0xFFFF5022), w*.038));
    }
  }
}

void _sor3(Canvas c, double w, double h) {
  // Glacial Spike: tall icicle with facets
  _pts(c, [w*.50,h*.08, w*.32,h*.88, w*.50,h*.74, w*.68,h*.88], _f(const Color(0xFF0A1A33)));
  _pts(c, [w*.50,h*.08, w*.32,h*.88, w*.50,h*.74, w*.68,h*.88],
      _s(const Color(0xFF44BBFF), w*.048), close: true);
  _ln(c, w*.50, h*.08, w*.50, h*.74, _s(const Color(0xFF88EEFF), w*.026));
  _ln(c, w*.50, h*.08, w*.36, h*.62, _s(const Color(0xFF88CCFF).withValues(alpha:.5), w*.020));
  _rays(c, w*.50, h*.08, w*.02, w*.08, 5, -pi*.6, _s(const Color(0xFFAAEEFF), w*.028));
}

void _sor4(Canvas c, double w, double h) {
  // Mana Surge: 3 converging streaks + base orb
  c.drawCircle(Offset(w*.5, h*.78), w*.12, _f(const Color(0xFF1A0500)));
  c.drawCircle(Offset(w*.5, h*.78), w*.12, _s(const Color(0xFFFF5022), w*.044));
  for (int i = 0; i < 3; i++) {
    final a = -pi/2+i*pi*.55;
    _ln(c, w*.5, h*.78, w*.5+cos(a)*w*.38, h*.78+sin(a)*h*.56,
        _s(const Color(0xFFFF8844).withValues(alpha:1.0-i*.22), w*(.060-i*.012)));
  }
  _rays(c, w*.5, h*.22, w*.02, w*.12, 6, 0, _s(const Color(0xFFFFAA44), w*.036));
}

void _sor5(Canvas c, double w, double h) {
  // Mana Drain: inward vortex spiral
  for (int i = 0; i < 6; i++) {
    _arc(c, w*.5, h*.5, w*(.38-i*.058), pi*.2+i*.6, pi*1.2,
        _s(const Color(0xFFFF5022).withValues(alpha:.3+i*.12), w*(.052-i*.006)));
  }
  c.drawCircle(Offset(w*.5, h*.5), w*.06, _f(const Color(0xFFFF2200)));
  c.drawCircle(Offset(w*.5, h*.5), w*.06, _s(const Color(0xFFFF8844), w*.030));
}

void _sor6(Canvas c, double w, double h) {
  // Melt Defenses: crumbling block with falling pieces
  c.drawRect(Rect.fromLTWH(w*.22, h*.28, w*.54, h*.40),
      _f(const Color(0xFF1A0A00)));
  c.drawRect(Rect.fromLTWH(w*.22, h*.28, w*.54, h*.40),
      _s(const Color(0xFFFF5022), w*.048));
  // crack lines
  _zz(c, [w*.38,h*.28, w*.42,h*.48, w*.36,h*.68], _s(const Color(0xFFFF8844), w*.036));
  // falling chunks
  c.drawRect(Rect.fromCenter(center: Offset(w*.70, h*.74), width: w*.12, height: h*.10),
      _f(const Color(0xFFFF5022)));
  c.drawRect(Rect.fromCenter(center: Offset(w*.28, h*.80), width: w*.10, height: h*.08),
      _f(const Color(0xFFFF7744)));
}

void _sorUlt(Canvas c, double w, double h) {
  // Arcane Singularity: black hole
  c.drawCircle(Offset(w*.5, h*.5), w*.14, _f(const Color(0xFF050005)));
  c.drawCircle(Offset(w*.5, h*.5), w*.14, _s(const Color(0xFFFF5022), w*.042));
  for (int i = 1; i <= 5; i++) {
    _arc(c, w*.5, h*.5, w*(.14+i*.046), pi*.1*(i%2), pi*(1.2+i*.1),
        _s(const Color(0xFFFF5022).withValues(alpha:.15+i*.14), w*(.040-i*.004)));
  }
  _rays(c, w*.5, h*.5, w*.30, w*.44, 8, pi/8,
      _s(const Color(0xFFFF8844).withValues(alpha:.4), w*.022));
}

// ── WARLOCK ───────────────────────────────────────────────────────────────────

void _wlk1(Canvas c, double w, double h) {
  // Eldritch Blast: jagged dark halo + energy center
  final angles = List.generate(12, (i) => i*pi/6);
  final path = Path();
  for (int i = 0; i < angles.length; i++) {
    final r = w*(i.isEven ? .36 : .24);
    final pt = Offset(w*.5+cos(angles[i])*r, h*.5+sin(angles[i])*r);
    i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
  }
  path.close();
  c.drawPath(path, _f(const Color(0xFF0D0020)));
  c.drawPath(path, _s(const Color(0xFFAA44FF), w*.046));
  c.drawCircle(Offset(w*.5, h*.5), w*.10, _f(const Color(0xFF7722CC)));
  c.drawCircle(Offset(w*.5, h*.5), w*.05, _f(const Color(0xFFDDAEFF)));
}

void _wlk2(Canvas c, double w, double h) {
  // Dark One's Blessing: dark ring + 4 rune marks
  _arc(c, w*.5, h*.5, w*.30, 0, pi*2, _s(const Color(0xFFAA44FF), w*.052));
  _arc(c, w*.5, h*.5, w*.20, 0, pi*2, _s(const Color(0xFF7722CC).withValues(alpha:.5), w*.028));
  for (int i = 0; i < 4; i++) {
    final a = i*pi/2;
    final cx = w*.5+cos(a)*w*.30, cy = h*.5+sin(a)*h*.30;
    c.drawCircle(Offset(cx, cy), w*.04, _f(const Color(0xFFCC88FF)));
    _rays(c, cx, cy, w*.04, w*.08, 4, pi/4, _s(const Color(0xFF9944CC), w*.024));
  }
}

void _wlk3(Canvas c, double w, double h) {
  // Hunger of Hadar: void maw (fanged mouth)
  c.drawArc(Rect.fromCenter(center: Offset(w*.5, h*.46), width: w*.60, height: h*.48),
      0, pi, true, _f(const Color(0xFF050010)));
  c.drawArc(Rect.fromCenter(center: Offset(w*.5, h*.46), width: w*.60, height: h*.48),
      0, pi, false, _s(const Color(0xFFAA44FF), w*.050));
  // lower jaw
  c.drawArc(Rect.fromCenter(center: Offset(w*.5, h*.62), width: w*.60, height: h*.30),
      -pi, pi, false, _s(const Color(0xFFAA44FF), w*.040));
  // teeth
  for (int i = 0; i < 5; i++) {
    final a = pi*.1+i*pi*.18;
    _ln(c, w*.5+cos(a)*w*.26, h*.46+sin(a)*h*.20,
        w*.5+cos(a)*w*.26, h*.46+sin(a)*h*.28,
        _s(const Color(0xFFDDAEFF), w*.030));
  }
}

void _wlk4(Canvas c, double w, double h) {
  // Armor of Agathys: frost crystal / spiky diamond
  final pts = <double>[];
  for (int i = 0; i < 8; i++) {
    final a = i*pi/4-pi/8;
    final r = w*(i.isEven ? .34 : .18);
    pts.addAll([w*.5+cos(a)*r, h*.5+sin(a)*r]);
  }
  _pts(c, pts, _f(const Color(0xFF001122)));
  _pts(c, pts, _s(const Color(0xFF44BBFF), w*.050), close: true);
  c.drawCircle(Offset(w*.5, h*.5), w*.06, _f(const Color(0xFF88DDFF)));
  _rays(c, w*.5, h*.5, w*.06, w*.12, 4, pi/4, _s(const Color(0xFFCCEEFF), w*.026));
}

void _wlk5(Canvas c, double w, double h) {
  // Hex: pin/needle through heart
  final hp = Path()..moveTo(w*.50, h*.64);
  hp.cubicTo(w*.50,h*.52, w*.34,h*.46, w*.34,h*.58);
  hp.cubicTo(w*.34,h*.66, w*.50,h*.76, w*.50,h*.76);
  hp.cubicTo(w*.50,h*.76, w*.66,h*.66, w*.66,h*.58);
  hp.cubicTo(w*.66,h*.46, w*.50,h*.52, w*.50,h*.64);
  c.drawPath(hp, _f(const Color(0xFF2A0011)));
  c.drawPath(hp, _s(const Color(0xFFAA44FF), w*.048));
  // pin/needle
  _ln(c, w*.50, h*.14, w*.50, h*.80, _s(const Color(0xFFCC88FF), w*.038));
  c.drawCircle(Offset(w*.50, h*.14), w*.04, _f(const Color(0xFFDDAEFF)));
}

void _wlk6(Canvas c, double w, double h) {
  // Soul Rend: wispy asymmetric form
  final path = Path()..moveTo(w*.50, h*.86);
  path.cubicTo(w*.34, h*.64, w*.26, h*.50, w*.38, h*.36);
  path.cubicTo(w*.50, h*.22, w*.44, h*.14, w*.50, h*.08);
  path.cubicTo(w*.56, h*.14, w*.72, h*.24, w*.62, h*.42);
  path.cubicTo(w*.52, h*.58, w*.64, h*.72, w*.50, h*.86);
  c.drawPath(path, _f(const Color(0xFF150025)));
  c.drawPath(path, _s(const Color(0xFFAA44FF), w*.048));
  for (int i = 0; i < 3; i++) {
    c.drawCircle(
      Offset(w*(.62+i*.08), h*(.28-i*.08)),
      w*.025, _f(const Color(0xFFCC88FF)));
  }
}

void _wlkUlt(Canvas c, double w, double h) {
  // Soul Harvest: scythe outline
  _ln(c, w*.40, h*.80, w*.36, h*.20, _s(const Color(0xFFAA44FF), w*.048));
  _ln(c, w*.36, h*.20, w*.76, h*.28, _s(const Color(0xFFAA44FF), w*.044));
  c.drawArc(Rect.fromCenter(center: Offset(w*.56, h*.44), width: w*.46, height: h*.40),
      -pi*.5, -pi*.9, false, _s(const Color(0xFFCC88FF), w*.052));
  // souls orbiting
  for (int i = 0; i < 4; i++) {
    final a = i*pi/2+pi*.2;
    c.drawCircle(Offset(w*.5+cos(a)*w*.36, h*.5+sin(a)*h*.36), w*.025,
        _f(const Color(0xFFDDAEFF)));
  }
}

// ── WIZARD ────────────────────────────────────────────────────────────────────

void _wiz1(Canvas c, double w, double h) {
  // Magic Missile: bolt + motion trail
  _ln(c, w*.20, h*.80, w*.78, h*.22, _s(const Color(0xFF44BBFF), w*.058));
  _poly(c, w*.80, h*.20, w*.09, 3, -pi*.12, _f(const Color(0xFF44BBFF)));
  _rays(c, w*.78, h*.22, w*.04, w*.11, 4, pi*.4, _s(const Color(0xFFAAEEFF).withValues(alpha:.6), w*.026));
  // trail streaks
  for (int i = 0; i < 3; i++) {
    _ln(c, w*(.40+i*.08), h*(.62-i*.08), w*(.28+i*.08), h*(.74-i*.08),
        _s(const Color(0xFF88CCFF).withValues(alpha:.5-i*.12), w*.024));
  }
}

void _wiz2(Canvas c, double w, double h) {
  // Mage Armor: hexagon + inner lines
  _poly(c, w*.5, h*.5, w*.36, 6, 0, _s(const Color(0xFF44BBFF), w*.054));
  _poly(c, w*.5, h*.5, w*.22, 6, pi/6, _s(const Color(0xFF88DDFF).withValues(alpha:.6), w*.030));
  _rays(c, w*.5, h*.5, w*.05, w*.20, 6, 0, _s(const Color(0xFF44BBFF).withValues(alpha:.4), w*.022));
  c.drawCircle(Offset(w*.5, h*.5), w*.06, _f(const Color(0xFF001122)));
  c.drawCircle(Offset(w*.5, h*.5), w*.06, _s(const Color(0xFFCCEEFF), w*.030));
}

void _wiz3(Canvas c, double w, double h) {
  // Cone of Cold: 5 spreading ice lines from left point
  for (int i = 0; i < 5; i++) {
    final a = -pi*.4 + i*pi*.2;
    _ln(c, w*.16, h*.50, w*.16+cos(a)*w*.72, h*.50+sin(a)*h*.72,
        _s(const Color(0xFF44BBFF).withValues(alpha:1.0-i.abs()*.15), w*(.054-i.abs()*.006)));
  }
  c.drawCircle(Offset(w*.16, h*.50), w*.06, _f(const Color(0xFF88DDFF)));
}

void _wiz4(Canvas c, double w, double h) {
  // Arcane Recovery: open book + upward glow
  // book pages
  for (final dx in [-1.0, 1.0]) {
    c.drawArc(Rect.fromCenter(center: Offset(w*.50+dx*w*.02, h*.56),
        width: w*.38, height: h*.38), -pi*.1, pi*1.2, false,
        _s(const Color(0xFF44BBFF), w*.044));
  }
  _ln(c, w*.50, h*.40, w*.50, h*.80, _s(const Color(0xFF88AAFF), w*.034));
  // glow rays upward
  for (int i = 0; i < 5; i++) {
    final a = -pi*.7+i*pi*.35;
    _ln(c, w*.5+cos(a)*w*.04, h*.36+sin(a)*h*.04,
        w*.5+cos(a)*w*(.10+i*.02), h*.36+sin(a)*h*.14,
        _s(const Color(0xFFAADDFF).withValues(alpha:.6), w*.032));
  }
}

void _wiz5(Canvas c, double w, double h) {
  // Slow: hourglass + freeze crack
  _pts(c, [w*.24,h*.20, w*.76,h*.20, w*.50,h*.50, w*.76,h*.80, w*.24,h*.80, w*.50,h*.50],
      _s(const Color(0xFF44BBFF), w*.052), close: true);
  _ln(c, w*.24, h*.20, w*.76, h*.20, _s(const Color(0xFF44BBFF), w*.040));
  _ln(c, w*.24, h*.80, w*.76, h*.80, _s(const Color(0xFF44BBFF), w*.040));
  // freeze crack through middle
  _zz(c, [w*.38,h*.14, w*.44,h*.34, w*.56,h*.34, w*.60,h*.52],
      _s(const Color(0xFF88EEFF), w*.034));
}

void _wiz6(Canvas c, double w, double h) {
  // Arcane Lock: padlock + rune arc
  _arc(c, w*.5, h*.44, w*.20, -pi, pi, _s(const Color(0xFF44BBFF), w*.054));
  c.drawRect(Rect.fromCenter(center: Offset(w*.50, h*.62), width: w*.36, height: h*.28),
      _f(const Color(0xFF001122)));
  c.drawRect(Rect.fromCenter(center: Offset(w*.50, h*.62), width: w*.36, height: h*.28),
      _s(const Color(0xFF44BBFF), w*.048));
  c.drawCircle(Offset(w*.50, h*.62), w*.07, _f(const Color(0xFF44BBFF)));
  // rune dots
  for (int i = 0; i < 5; i++) {
    final a = -pi*.75+i*pi*.375;
    c.drawCircle(Offset(w*.5+cos(a)*w*.24, h*.30+sin(a)*h*.14), w*.025,
        _f(const Color(0xFF88DDFF)));
  }
}

void _wizUlt(Canvas c, double w, double h) {
  // Meteor: flaming boulder + diagonal trail
  for (int i = 0; i < 5; i++) {
    _arc(c, w*(.26-i*.03), h*(.26-i*.03), w*(.10+i*.04), pi*.6, pi*1.2,
        _s(const Color(0xFFFF6622).withValues(alpha:.8-i*.14), w*(.050-i*.006)));
  }
  c.drawCircle(Offset(w*.70, h*.70), w*.20, _f(const Color(0xFF331100)));
  c.drawCircle(Offset(w*.70, h*.70), w*.20, _s(const Color(0xFFFF5500), w*.054));
  _rays(c, w*.70, h*.70, w*.20, w*.28, 6, pi/6, _s(const Color(0xFFFF8844).withValues(alpha:.6), w*.030));
}

// ── Icon registry ─────────────────────────────────────────────────────────────

const _kOrange = Color(0xFF120800);
const _kPurple = Color(0xFF0D0520);
const _kBlue   = Color(0xFF040D1A);
const _kGreen  = Color(0xFF041408);
const _kGold   = Color(0xFF120A00);
const _kCyan   = Color(0xFF041012);
const _kRed    = Color(0xFF140200);
const _kTeal   = Color(0xFF041408);
const _kDark   = Color(0xFF060608);

final _kIcons = <String, _Def>{
  // BARBARIAN
  'barbarian_1': _Def(_kOrange, const Color(0xFFE88830), _barb1),
  'barbarian_2': _Def(_kOrange, const Color(0xFFFFAA44), _barb2),
  'barbarian_3': _Def(_kOrange, const Color(0xFF88DD00), _barb3),
  'barbarian_4': _Def(_kOrange, const Color(0xFFFF6622), _barb4),
  'barbarian_5': _Def(_kOrange, const Color(0xFFE88830), _barb5),
  'barbarian_6': _Def(_kOrange, const Color(0xFFFF5511), _barb6),
  'barb_ult':    _Def(_kOrange, const Color(0xFFFFCC44), _barbUlt),
  // BARD
  'bard_1': _Def(_kPurple, const Color(0xFFAA44FF), _bard1),
  'bard_2': _Def(_kPurple, const Color(0xFF8833CC), _bard2),
  'bard_3': _Def(_kPurple, const Color(0xFFAA66FF), _bard3),
  'bard_4': _Def(_kPurple, const Color(0xFFCC88FF), _bard4),
  'bard_5': _Def(_kPurple, const Color(0xFF9955DD), _bard5),
  'bard_6': _Def(_kPurple, const Color(0xFFBB77FF), _bard6),
  'brd_ult': _Def(_kPurple, const Color(0xFFFFCC88), _brdUlt),
  // CLERIC
  'cleric_1': _Def(_kBlue, const Color(0xFF6688FF), _cleric1),
  'cleric_2': _Def(_kBlue, const Color(0xFF88CCFF), _cleric2),
  'cleric_3': _Def(_kBlue, const Color(0xFFAA66FF), _cleric3),
  'cleric_4': _Def(_kBlue, const Color(0xFF6688FF), _cleric4),
  'cleric_5': _Def(_kBlue, const Color(0xFF88AAFF), _cleric5),
  'cleric_6': _Def(_kBlue, const Color(0xFF4466CC), _cleric6),
  'clr_ult':  _Def(_kBlue, const Color(0xFFFFFFFF), _clrUlt),
  // DRUID
  'druid_1': _Def(_kGreen, const Color(0xFF44CC66), _druid1),
  'druid_2': _Def(_kGreen, const Color(0xFF44FF88), _druid2),
  'druid_3': _Def(_kGreen, const Color(0xFF44BBFF), _druid3),
  'druid_4': _Def(_kGreen, const Color(0xFF55EE77), _druid4),
  'druid_5': _Def(_kGreen, const Color(0xFF33BB55), _druid5),
  'druid_6': _Def(_kGreen, const Color(0xFF44BB55), _druid6),
  'drd_ult': _Def(_kGreen, const Color(0xFFAAFF66), _drdUlt),
  // FIGHTER
  'fighter_1': _Def(_kGold, const Color(0xFFFFE040), _ftr1),
  'fighter_2': _Def(_kGold, const Color(0xFFFFD700), _ftr2),
  'fighter_3': _Def(_kGold, const Color(0xFFFFFF44), _ftr3),
  'fighter_4': _Def(_kGold, const Color(0xFF88DDFF), _ftr4),
  'fighter_5': _Def(_kGold, const Color(0xFFFFE040), _ftr5),
  'fighter_6': _Def(_kGold, const Color(0xFFFFCC44), _ftr6),
  'ftr_ult':  _Def(_kGold, const Color(0xFFFFFFCC), _ftrUlt),
  // MONK
  'monk_1': _Def(_kCyan, const Color(0xFF44BBFF), _monk1),
  'monk_2': _Def(_kCyan, const Color(0xFF33AAEE), _monk2),
  'monk_3': _Def(_kCyan, const Color(0xFF9944FF), _monk3),
  'monk_4': _Def(_kCyan, const Color(0xFF44BBFF), _monk4),
  'monk_5': _Def(_kCyan, const Color(0xFF44DDFF), _monk5),
  'monk_6': _Def(_kCyan, const Color(0xFF4499CC), _monk6),
  'mnk_ult': _Def(_kCyan, const Color(0xFF88FFFF), _mnkUlt),
  // PALADIN
  'paladin_1': _Def(_kGold, const Color(0xFFFFD700), _pal1),
  'paladin_2': _Def(_kGold, const Color(0xFFFFEE88), _pal2),
  'paladin_3': _Def(_kGold, const Color(0xFFFFD700), _pal3),
  'paladin_4': _Def(_kGold, const Color(0xFFFFBB44), _pal4),
  'paladin_5': _Def(_kGold, const Color(0xFFFFCC44), _pal5),
  'paladin_6': _Def(_kGold, const Color(0xFFFF8833), _pal6),
  'pal_ult':  _Def(_kGold, const Color(0xFFFFFFDD), _palUlt),
  // RANGER
  'ranger_1': _Def(_kTeal, const Color(0xFF44CC66), _rng1),
  'ranger_2': _Def(_kTeal, const Color(0xFF44FF66), _rng2),
  'ranger_3': _Def(_kTeal, const Color(0xFF44BBFF), _rng3),
  'ranger_4': _Def(_kTeal, const Color(0xFF44CC66), _rng4),
  'ranger_5': _Def(_kTeal, const Color(0xFF33BB44), _rng5),
  'ranger_6': _Def(_kTeal, const Color(0xFF55CC77), _rng6),
  'rng_ult':  _Def(_kTeal, const Color(0xFF88FF99), _rngUlt),
  // ROGUE
  'rogue_1': _Def(_kDark, const Color(0xFF44EE66), _rog1),
  'rogue_2': _Def(_kDark, const Color(0xFF33CC55), _rog2),
  'rogue_3': _Def(_kDark, const Color(0xFF55FF77), _rog3),
  'rogue_4': _Def(_kDark, const Color(0xFF88BBAA), _rog4),
  'rogue_5': _Def(_kDark, const Color(0xFF44EE66), _rog5),
  'rogue_6': _Def(_kDark, const Color(0xFFCC3333), _rog6),
  'rog_ult':  _Def(_kDark, const Color(0xFFFF4444), _rogUlt),
  // SORCERER
  'sorcerer_1': _Def(_kRed, const Color(0xFFFF5022), _sor1),
  'sorcerer_2': _Def(_kRed, const Color(0xFFFF6633), _sor2),
  'sorcerer_3': _Def(_kRed, const Color(0xFF44BBFF), _sor3),
  'sorcerer_4': _Def(_kRed, const Color(0xFFFF8844), _sor4),
  'sorcerer_5': _Def(_kRed, const Color(0xFFFF5022), _sor5),
  'sorcerer_6': _Def(_kRed, const Color(0xFFFF7733), _sor6),
  'sor_ult':    _Def(_kRed, const Color(0xFFFF3300), _sorUlt),
  // WARLOCK
  'warlock_1': _Def(_kPurple, const Color(0xFFAA44FF), _wlk1),
  'warlock_2': _Def(_kPurple, const Color(0xFF8833CC), _wlk2),
  'warlock_3': _Def(_kPurple, const Color(0xFF7722BB), _wlk3),
  'warlock_4': _Def(_kPurple, const Color(0xFF44BBFF), _wlk4),
  'warlock_5': _Def(_kPurple, const Color(0xFFCC66FF), _wlk5),
  'warlock_6': _Def(_kPurple, const Color(0xFFBB55EE), _wlk6),
  'wlk_ult':   _Def(_kPurple, const Color(0xFFDDAEFF), _wlkUlt),
  // WIZARD
  'wizard_1': _Def(_kBlue, const Color(0xFF44BBFF), _wiz1),
  'wizard_2': _Def(_kBlue, const Color(0xFF33AAEE), _wiz2),
  'wizard_3': _Def(_kBlue, const Color(0xFF88DDFF), _wiz3),
  'wizard_4': _Def(_kBlue, const Color(0xFF4488FF), _wiz4),
  'wizard_5': _Def(_kBlue, const Color(0xFF44BBFF), _wiz5),
  'wizard_6': _Def(_kBlue, const Color(0xFF5599FF), _wiz6),
  'wiz_ult':  _Def(_kBlue, const Color(0xFFFF6622), _wizUlt),
};
