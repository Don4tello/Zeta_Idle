import 'package:flutter/material.dart';

/// Blocky pixel-art emblems for the Hero-hub category cards, drawn in the same
/// hard-edged grid style as the battle sprites (anti-aliasing OFF). One emblem
/// per hub group, tinted from the group's accent [color] so it stays on-theme
/// with each card.
///
/// [kind]: 0 = Character (helm) · 1 = Progression (rising bars) ·
///         2 = Collection (paw) · 3 = Records (medal).
class HubEmblem extends StatelessWidget {
  const HubEmblem({super.key, required this.kind, required this.color, this.size = 72});

  final int kind;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: HubEmblemPainter(kind, color),
          isComplex: true,
          willChange: false,
        ),
      );
}

class HubEmblemPainter extends CustomPainter {
  const HubEmblemPainter(this.kind, this.color);

  final int kind;
  final Color color;

  static const List<List<String>> _maps = [
    _character,
    _progression,
    _collection,
    _records,
  ];

  @override
  void paint(Canvas c, Size s) {
    final map = _maps[kind.clamp(0, _maps.length - 1)];
    final rows = map.length;
    final cols = map[0].length;
    // Square pixel unit; centre the grid inside the canvas.
    final u = s.shortestSide / cols;
    final ox = (s.width - u * cols) / 2;
    final oy = (s.height - u * rows) / 2;

    final base = color;
    final light = Color.lerp(color, Colors.white, 0.42)!;
    final dark = Color.lerp(color, Colors.black, 0.35)!;
    final line = Color.lerp(color, Colors.black, 0.62)!;
    const star = Color(0xFFFFD54A);
    const ribbon = Color(0xFFCC4444);

    Color? colorFor(String ch) => switch (ch) {
          'B' => base,
          'L' => light,
          'D' => dark,
          'K' => line,
          'W' => Colors.white,
          'Y' => star,
          'R' => ribbon,
          _ => null,
        };

    final paint = Paint()
      ..isAntiAlias = false
      ..style = PaintingStyle.fill;

    for (int y = 0; y < rows; y++) {
      final row = map[y];
      for (int x = 0; x < cols; x++) {
        final col = colorFor(row[x]);
        if (col == null) continue;
        paint.color = col;
        // +0.5 overdraw so neighbouring cells don't leave hairline seams.
        c.drawRect(Rect.fromLTWH(ox + x * u, oy + y * u, u + 0.5, u + 0.5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant HubEmblemPainter old) =>
      old.kind != kind || old.color != color;

  // ── Pixel maps (16×16) ──────────────────────────────────────────────────────
  // '.' transparent · B base · L light · D dark · K outline · Y star · R ribbon.

  static const List<String> _character = [
    '................',
    '................',
    '....KKKKKKKK....',
    '...KLLLLLLLLK...',
    '..KLBBBBBBBBLK..',
    '..KBBBBBBBBBBK..',
    '..KBKKKKKKKKBK..',
    '..KBBBBBBBBBBK..',
    '..KBKKKKKKKKBK..',
    '..KBBBBBBBBBBK..',
    '..KDBBBBBBBBDK..',
    '...KDBBBBBBDK...',
    '....KDBBBBDK....',
    '.....KDBBDK.....',
    '......KDDK......',
    '.......KK.......',
  ];

  static const List<String> _progression = [
    '................',
    '................',
    '...........LL...',
    '...........BB...',
    '...........BB...',
    '........LL.BB...',
    '........BB.BB...',
    '........BB.BB...',
    '.....LL.BB.BB...',
    '.....BB.BB.BB...',
    '..LL.BB.BB.BB...',
    '..BB.BB.BB.BB...',
    '..BB.BB.BB.BB...',
    '..DD.DD.DD.DD...',
    '................',
    '................',
  ];

  static const List<String> _collection = [
    '................',
    '....B......B....',
    '...BLB....BLB...',
    '...BLB....BLB...',
    '....B......B....',
    '..B..........B..',
    '.BLB........BLB.',
    '.BLB........BLB.',
    '..B..........B..',
    '.....BBBBBB.....',
    '...BBLLLLLLBB...',
    '..BLLLLLLLLLLB..',
    '..BLLLLLLLLLLB..',
    '...BLLLLLLLLB...',
    '....BBLLLLBB....',
    '......BBBB......',
  ];

  static const List<String> _records = [
    '...RR......RR...',
    '...RR......RR...',
    '....RR....RR....',
    '....RR....RR....',
    '.....RR..RR.....',
    '......RRRR......',
    '.....KBBBBK.....',
    '....KBLLLLBK....',
    '....BLLYYLLB....',
    '....BLYYYYLB....',
    '....BLLYYLLB....',
    '....KBLLLLBK....',
    '.....KBBBBK.....',
    '......KKKK......',
    '................',
    '................',
  ];
}
