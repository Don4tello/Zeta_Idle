import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Premium pixel-art emblem for the VIP subscription cards. Same hard-edged
/// grid style as the hub/battle sprites, but dressed up for a paid offer: a
/// radial glow + a ring of light rays behind a chunky pixel emblem, all tinted
/// from the tier's [color].
///
/// [kind]: 0 = Vanguard's Pact (double chevron / "fast-forward") ·
///         1 = Ascendant's Crown (jewelled crown).
class VipEmblem extends StatelessWidget {
  const VipEmblem({super.key, required this.kind, required this.color, this.size = 52});

  final int kind;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: VipEmblemPainter(kind, color),
          isComplex: true,
          willChange: false,
        ),
      );
}

class VipEmblemPainter extends CustomPainter {
  const VipEmblemPainter(this.kind, this.color);

  final int kind;
  final Color color;

  static const List<List<String>> _maps = [_vanguard, _crown];

  @override
  void paint(Canvas c, Size s) {
    final cx = s.width / 2, cy = s.height / 2;
    final short = s.shortestSide;

    // 1) Soft radial glow behind everything.
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [color.withValues(alpha: 0.45), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: short * 0.55));
    c.drawCircle(Offset(cx, cy), short * 0.55, glow);

    // 2) Ring of light rays for a "premium burst".
    final ray = Paint()
      ..color = color.withValues(alpha: 0.28)
      ..strokeWidth = short * 0.018
      ..strokeCap = StrokeCap.round;
    const n = 12;
    for (int i = 0; i < n; i++) {
      final a = i * (2 * math.pi / n);
      final r0 = short * 0.31, r1 = short * 0.48;
      c.drawLine(
        Offset(cx + math.cos(a) * r0, cy + math.sin(a) * r0),
        Offset(cx + math.cos(a) * r1, cy + math.sin(a) * r1),
        ray,
      );
    }

    // 3) Pixel emblem (~62% of the canvas), centred.
    final map = _maps[kind.clamp(0, _maps.length - 1)];
    final rows = map.length, cols = map[0].length;
    final u = (short * 0.62) / cols;
    final ox = (s.width - u * cols) / 2;
    final oy = (s.height - u * rows) / 2;

    final base = color;
    final light = Color.lerp(color, Colors.white, 0.45)!;
    final dark = Color.lerp(color, Colors.black, 0.35)!;
    final line = Color.lerp(color, Colors.black, 0.60)!;
    const gem = Color(0xFFFFF0A0);

    Color? colorFor(String ch) => switch (ch) {
          'B' => base,
          'L' => light,
          'D' => dark,
          'K' => line,
          'Y' => gem,
          _ => null,
        };

    final p = Paint()..isAntiAlias = false;
    for (int y = 0; y < rows; y++) {
      final row = map[y];
      for (int x = 0; x < cols; x++) {
        final col = colorFor(row[x]);
        if (col == null) continue;
        p.color = col;
        c.drawRect(Rect.fromLTWH(ox + x * u, oy + y * u, u + 0.5, u + 0.5), p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant VipEmblemPainter old) =>
      old.kind != kind || old.color != color;

  // ── Pixel maps (16×16) ──────────────────────────────────────────────────────
  // '.' transparent · B base · L light · D dark · K outline · Y gem highlight.

  // Vanguard's Pact — a double "fast-forward" chevron (speed / advance).
  static const List<String> _vanguard = [
    '................',
    '.......BB.......',
    '......BLLB......',
    '.....BLBBLB.....',
    '....BLB..BLB....',
    '...BLB....BLB...',
    '..DBB......BBD..',
    '................',
    '.......BB.......',
    '......BLLB......',
    '.....BLBBLB.....',
    '....BLB..BLB....',
    '...BLB....BLB...',
    '..DBB......BBD..',
    '................',
    '................',
  ];

  // Ascendant's Crown — a jewelled crown.
  static const List<String> _crown = [
    '................',
    '.......YY.......',
    '..Y....BB....Y..',
    '..B...BLLB...B..',
    '..BB.BLLLLB.BB..',
    '..BLBBLLLLBBLB..',
    '..BLLLLLLLLLLB..',
    '..BLLLLYYLLLLB..',
    '..BLLLLLLLLLLB..',
    '..BBBBBBBBBBBB..',
    '..BLLLLLLLLLLB..',
    '..KKKKKKKKKKKK..',
    '................',
    '................',
    '................',
    '................',
  ];
}
