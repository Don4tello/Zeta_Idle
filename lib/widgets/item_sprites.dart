import 'package:flutter/material.dart';
import '../models/equipment.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ItemSprite — 16×16 pixel-art sprite for each equipment slot.
// Wrap with rarity to add a glow; legendary items pulse.
// ─────────────────────────────────────────────────────────────────────────────

class ItemSprite extends StatelessWidget {
  const ItemSprite({
    super.key,
    required this.slot,
    this.rarity,
    this.size = 40,
    this.setColor,
  });

  final ItemSlot  slot;
  final ItemRarity? rarity;
  final double  size;
  final Color?  setColor;

  static Color? glowColorFor(ItemRarity? rarity, {Color? setColor}) =>
      switch (rarity) {
        null                 => null,
        ItemRarity.common    => null,
        ItemRarity.rare      => const Color(0xFF6699ff),
        ItemRarity.epic      => const Color(0xFFcc44ff),
        ItemRarity.legendary => const Color(0xFFFFD700),
        ItemRarity.set       => setColor ?? const Color(0xFF44ff88),
      };

  @override
  Widget build(BuildContext context) {
    final glow   = glowColorFor(rarity, setColor: setColor);
    final sprite = CustomPaint(
      size: Size(size, size),
      painter: _painterFor(slot),
    );

    if (glow == null) return SizedBox(width: size, height: size, child: sprite);

    if (rarity == ItemRarity.legendary) {
      return _LegendaryGlow(size: size, color: glow, child: sprite);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        boxShadow: [
          if (rarity == ItemRarity.epic)
            BoxShadow(
                color: glow.withValues(alpha: 0.45),
                blurRadius: 4,
                spreadRadius: 0.5),
          BoxShadow(
              color: glow.withValues(alpha: 0.7),
              blurRadius: rarity == ItemRarity.epic ? 10 : 7,
              spreadRadius: rarity == ItemRarity.epic ? 1.5 : 0.5),
        ],
      ),
      child: sprite,
    );
  }
}

// ── Legendary pulse ───────────────────────────────────────────────────────────

class _LegendaryGlow extends StatefulWidget {
  const _LegendaryGlow(
      {required this.size, required this.color, required this.child});
  final double size;
  final Color  color;
  final Widget child;

  @override
  State<_LegendaryGlow> createState() => _LegendaryGlowState();
}

class _LegendaryGlowState extends State<_LegendaryGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);
  late final Animation<double> _pulse =
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) {
        final t = _pulse.value;
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.45 + 0.3 * t),
                blurRadius: 6 + 5 * t,
                spreadRadius: 0.5 + 1.5 * t,
              ),
              BoxShadow(
                color: widget.color.withValues(alpha: 0.2 + 0.15 * t),
                blurRadius: 14 + 8 * t,
                spreadRadius: 0 + 2 * t,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ── Painter factory ───────────────────────────────────────────────────────────

CustomPainter _painterFor(ItemSlot slot) => switch (slot) {
      ItemSlot.weapon  => _WeaponPainter(),
      ItemSlot.offHand => _OffHandPainter(),
      ItemSlot.helmet  => _HelmetPainter(),
      ItemSlot.armor   => _ArmorPainter(),
      ItemSlot.gloves  => _GlovesPainter(),
      ItemSlot.pants   => _PantsPainter(),
      ItemSlot.boots   => _BootsPainter(),
      ItemSlot.ring    => _RingPainter(),
      ItemSlot.ring2   => _RingPainter(),
      ItemSlot.amulet  => _AmuletPainter(),
      ItemSlot.relic   => _RelicPainter(),
    };

// ── Abstract base ─────────────────────────────────────────────────────────────

abstract class _P extends CustomPainter {
  // colour palette shared across all item sprites
  static const K  = 0xFF111117; // outline black
  static const SL = 0xFFe8eef4; // silver light
  static const S  = 0xFFb0bcc8; // silver mid
  static const SD = 0xFF687080; // silver dark
  static const G  = 0xFFd4af37; // gold
  static const GL = 0xFFf0cc55; // gold light
  static const GD = 0xFF9a7c1c; // gold dark
  static const BR = 0xFF7a4820; // brown dark
  static const BM = 0xFF9a5e2c; // brown mid
  static const BL = 0xFFba7a40; // brown light
  static const LT = 0xFFc8a464; // leather tan
  static const LD = 0xFF8a6030; // leather dark
  static const RD = 0xFFdd3333; // ruby red
  static const BU = 0xFF3366dd; // sapphire blue
  static const GE = 0xFF22aa55; // emerald green
  static const PU = 0xFF8833cc; // amethyst purple
  static const CY = 0xFF33ccaa; // cyan accent

  late double _s; // pixels per grid cell (= size / 16)

  void b(Canvas c, double x, double y, double w, double h, int rgba) =>
      c.drawRect(Rect.fromLTWH(x * _s, y * _s, w * _s, h * _s),
          Paint()..color = Color(rgba));

  @override
  void paint(Canvas canvas, Size size) {
    _s = size.width / 16.0;
    draw(canvas, size);
  }

  void draw(Canvas c, Size sz);

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// WEAPON — longsword pointing upward
//   blade: cols 7-8, rows 0-7
//   crossguard: cols 3-12, rows 7-8
//   grip: cols 7-8, rows 9-12
//   pommel: cols 6-9, rows 13-15
// ─────────────────────────────────────────────────────────────────────────────
class _WeaponPainter extends _P {
  @override
  void draw(Canvas c, Size sz) {
    // Blade edges
    b(c,  6, 1, 1, 6, SD); // left bevel
    b(c,  9, 1, 1, 6, SD); // right bevel
    // Blade faces
    b(c,  7, 0, 1, 7, SL); // bright face
    b(c,  8, 0, 1, 7, S);  // shadow face
    // Tip taper
    b(c,  7, 0, 2, 1, SL);

    // Crossguard — gold, wider
    b(c,  3, 7, 10, 2, GD); // dark fill
    b(c,  3, 7, 10, 1, G);  // top face
    b(c,  4, 7,  8, 1, GL); // centre highlight
    b(c,  3, 7,  1, 2, GD); // left cap dark
    b(c, 12, 7,  1, 2, GD); // right cap dark

    // Grip — wrapped brown
    b(c,  7,  9, 2, 4, BR);
    b(c,  7,  9, 1, 4, BM); // lighter face
    b(c,  7, 10, 2, 1, GL); // gold wrap band
    b(c,  7, 12, 2, 1, GL); // gold wrap band

    // Pommel — rounded gold
    b(c,  6, 13, 4, 1, G);
    b(c,  5, 14, 6, 1, G);
    b(c,  6, 14, 4, 1, GL); // highlight
    b(c,  5, 15, 6, 1, GD); // base shadow
    b(c,  6, 13, 4, 1, GL); // top strip
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OFF-HAND — kite shield, front-facing, with cross boss
// ─────────────────────────────────────────────────────────────────────────────
class _OffHandPainter extends _P {
  @override
  void draw(Canvas c, Size sz) {
    // Dark outline shape
    b(c,  4,  0,  8,  1, SD);
    b(c,  3,  1, 10,  9, SD);
    b(c,  4, 10,  8,  1, SD);
    b(c,  5, 11,  6,  1, SD);
    b(c,  6, 12,  4,  1, SD);
    b(c,  7, 13,  2,  2, SD);
    b(c,  7, 15,  2,  1, K);  // very tip

    // Silver face (1px inset)
    b(c,  4,  0,  8,  1, S);
    b(c,  4,  1,  8,  8, S);
    b(c,  4, 10,  8,  1, S);
    b(c,  5, 11,  6,  1, S);
    b(c,  6, 12,  4,  1, S);
    b(c,  7, 13,  2,  2, S);
    b(c,  8, 15,  1,  1, SD); // tip

    // Left-edge & top highlight
    b(c,  4,  0,  4,  1, SL);
    b(c,  4,  1,  2,  8, SL);
    b(c,  4,  1,  4,  3, SL);

    // Cross boss (gold)
    b(c,  7,  2,  2,  9, G);  // vertical bar
    b(c,  5,  5,  6,  3, G);  // horizontal bar
    b(c,  7,  5,  2,  3, GL); // inner highlight
    b(c,  7,  2,  2,  1, GL); // top of vertical
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELMET — visored great helm, front-facing
// ─────────────────────────────────────────────────────────────────────────────
class _HelmetPainter extends _P {
  @override
  void draw(Canvas c, Size sz) {
    // Dome outline
    b(c,  5,  0,  6,  1, SD);
    b(c,  4,  1,  8,  2, SD);
    b(c,  3,  3, 10,  2, SD);

    // Dome face
    b(c,  5,  0,  6,  1, S);
    b(c,  4,  1,  8,  2, S);
    b(c,  3,  3, 10,  2, S);

    // Dome highlight (upper-left)
    b(c,  5,  0,  4,  1, SL);
    b(c,  4,  1,  5,  1, SL);
    b(c,  3,  2,  4,  2, SL);

    // Plume (red)
    b(c,  7,  0,  2,  3, RD);
    b(c,  7,  0,  1,  2, 0xFFff5555); // lighter left

    // Cheekguards
    b(c,  2,  5,  3,  5, SD);
    b(c,  2,  5,  2,  5, S);
    b(c, 11,  5,  3,  5, SD);
    b(c, 12,  5,  2,  5, S);

    // Visor opening (dark)
    b(c,  4,  5,  8,  3, K);
    b(c,  5,  5,  6,  1, 0xFF222244); // tinted top
    b(c,  5,  6,  6,  2, K);

    // Nasal guard (gold vertical strip)
    b(c,  7,  5,  2,  3, G);
    b(c,  7,  5,  1,  3, GL);

    // Gorget (neck guard rows 10-12)
    b(c,  3, 10, 10,  1, SD);
    b(c,  4, 10,  8,  1, S);
    b(c,  4, 11,  8,  1, SD);
    b(c,  5, 11,  6,  1, S);
    b(c,  5, 12,  6,  1, SD);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ARMOR — full chest plate, front-facing
// ─────────────────────────────────────────────────────────────────────────────
class _ArmorPainter extends _P {
  @override
  void draw(Canvas c, Size sz) {
    // Left pauldron
    b(c,  1,  2,  4,  4, SD);
    b(c,  1,  2,  4,  3, S);
    b(c,  1,  2,  3,  1, SL);

    // Right pauldron
    b(c, 11,  2,  4,  4, SD);
    b(c, 11,  2,  4,  3, S);
    b(c, 12,  2,  3,  1, SL);

    // Chest body outline
    b(c,  4,  2,  8, 12, SD);

    // Chest face
    b(c,  5,  3,  6, 10, S);
    b(c,  5,  3,  3,  6, SL); // upper-left highlight

    // Gold trim bands
    b(c,  4,  4,  8,  1, G);  // upper chest band
    b(c,  4, 11,  8,  1, G);  // lower chest band

    // Centre plate emblem
    b(c,  6,  5,  4,  6, GD); // dark
    b(c,  7,  5,  2,  6, G);  // gold vertical
    b(c,  6,  7,  4,  2, G);  // gold horizontal
    b(c,  7,  7,  2,  2, GL); // bright centre

    // Waist guard
    b(c,  4, 12,  8,  2, GD);
    b(c,  5, 12,  6,  1, G);
    b(c,  5, 13,  6,  1, SD);

    // Neck opening (dark)
    b(c,  6,  2,  4,  2, K);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GLOVES — gauntlet fist, front view
// ─────────────────────────────────────────────────────────────────────────────
class _GlovesPainter extends _P {
  @override
  void draw(Canvas c, Size sz) {
    // Four fingers (top section, rows 0-5)
    // Finger widths: 2px each with 1px gap, x=2,5,8,11
    for (final fx in [2.0, 5.0, 8.0, 11.0]) {
      final height = fx == 5.0 ? 6.0 : 5.0; // index finger taller
      b(c, fx,     0, 2, height, SD);
      b(c, fx,     0, 2, height, S);
      b(c, fx,     0, 1, height - 1, SL);
    }

    // Knuckle plate (gold, row 5-6, covers all fingers)
    b(c,  2,  5, 12,  2, GD);
    b(c,  2,  5, 12,  1, G);
    b(c,  3,  5, 10,  1, GL);

    // Palm / back of hand (rows 7-11)
    b(c,  2,  7, 12,  5, SD);
    b(c,  3,  7, 10,  4, S);
    b(c,  3,  7,  5,  3, SL); // highlight

    // Gold knuckle detail row
    b(c,  3,  9,  3,  1, G);
    b(c,  7,  9,  3,  1, G);
    b(c, 11,  9,  2,  1, G);

    // Wrist cuff (rows 12-15)
    b(c,  2, 12, 12,  1, GD);
    b(c,  2, 13, 12,  2, G);
    b(c,  2, 13, 12,  1, GL);
    b(c,  2, 15, 12,  1, GD);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PANTS — armoured greaves, front view (two legs side by side)
// ─────────────────────────────────────────────────────────────────────────────
class _PantsPainter extends _P {
  @override
  void draw(Canvas c, Size sz) {
    // Left leg
    b(c,  2,  0,  5, 14, SD);
    b(c,  2,  0,  5, 13, S);
    b(c,  2,  0,  3,  6, SL); // highlight
    // Left knee cap (gold)
    b(c,  2,  7,  5,  2, G);
    b(c,  3,  7,  3,  1, GL);

    // Right leg
    b(c,  9,  0,  5, 14, SD);
    b(c,  9,  0,  5, 13, S);
    b(c, 10,  0,  2,  6, SL); // highlight
    // Right knee cap (gold)
    b(c,  9,  7,  5,  2, G);
    b(c, 10,  7,  3,  1, GL);

    // Hip plate connecting the two legs (top band)
    b(c,  1,  0, 14,  3, GD);
    b(c,  2,  0, 12,  2, G);
    b(c,  2,  0, 12,  1, GL);

    // Belt / gap between legs (small dark gap at centre)
    b(c,  7,  3,  2, 10, K);

    // Ankle guards (gold trim at bottom)
    b(c,  2, 13,  5,  2, G);
    b(c,  2, 13,  5,  1, GL);
    b(c,  9, 13,  5,  2, G);
    b(c,  9, 13,  5,  1, GL);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOOTS — armoured boot, side view
// ─────────────────────────────────────────────────────────────────────────────
class _BootsPainter extends _P {
  @override
  void draw(Canvas c, Size sz) {
    // Shin guard (upper boot, rows 0-8)
    b(c,  5,  0,  7,  9, SD); // dark outline
    b(c,  5,  0,  7,  8, S);  // face
    b(c,  5,  0,  4,  5, SL); // highlight

    // Gold shin trim
    b(c,  5,  8,  7,  1, G);
    b(c,  5,  8,  7,  1, GL);

    // Foot (rows 9-13, extends right)
    b(c,  4,  9, 10,  5, SD); // dark outline
    b(c,  5,  9,  9,  4, S);  // face
    b(c,  5,  9,  5,  2, SL); // highlight

    // Sole (bottom, row 14-15, slightly wider)
    b(c,  3, 14, 12,  1, SD);
    b(c,  4, 14, 10,  1, K);
    b(c,  3, 15, 12,  1, K);  // thick sole

    // Gold ankle band
    b(c,  4, 13, 10,  1, G);
    b(c,  5, 13,  8,  1, GL);

    // Toe cap
    b(c, 11,  9,  3,  5, GD);
    b(c, 11,  9,  3,  4, G);
    b(c, 11,  9,  2,  2, GL);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RING — band with large gemstone, top-down / face-on view
// ─────────────────────────────────────────────────────────────────────────────
class _RingPainter extends _P {
  @override
  void draw(Canvas c, Size sz) {
    // Outer ring band (circle approximation)
    b(c,  5,  1,  6,  1, G);  // top arc
    b(c,  3,  2,  2,  1, G);  b(c, 11,  2,  2,  1, G);
    b(c,  2,  3,  2,  4, G);  b(c, 12,  3,  2,  4, G);
    b(c,  3,  7,  2,  1, G);  b(c, 11,  7,  2,  1, G);
    b(c,  5,  8,  6,  1, G);  // bottom arc

    // Inner band highlight (lighter)
    b(c,  5,  1,  4,  1, GL);
    b(c,  3,  2,  1,  1, GL); b(c,  2,  3,  1,  2, GL);

    // Inner dark (hole of ring)
    b(c,  5,  2,  6,  1, GD);
    b(c,  4,  3,  1,  3, GD); b(c, 11,  3,  1,  3, GD);
    b(c,  5,  6,  6,  1, GD);
    // Very inside (background)
    b(c,  5,  3,  6,  3, K);

    // Setting / bezel (top)
    b(c,  6,  0,  4,  2, GD);
    b(c,  6,  0,  4,  1, G);

    // Gemstone (ruby red, rows -2 to 0 — use 0..1 since we have room)
    // Let's put a big gem at top rows 0-4 centred
    b(c,  5, -1,  6,  4, RD); // won't render (negative), shift down
    // Center gem on top of ring
    b(c,  5,  0,  6,  3, RD);         // gem body
    b(c,  5,  0,  3,  1, 0xFFff5555); // top-left highlight
    b(c,  5,  1,  2,  1, 0xFFff7777); // inner highlight
    b(c,  9,  2,  2,  1, 0xFF881111); // shadow corner
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AMULET — teardrop gem on a chain
// ─────────────────────────────────────────────────────────────────────────────
class _AmuletPainter extends _P {
  @override
  void draw(Canvas c, Size sz) {
    // Chain (rows 0-5, thin gold line each side)
    b(c,  6,  0,  1,  1, G);  b(c,  9,  0,  1,  1, G);
    b(c,  5,  1,  1,  1, G);  b(c, 10,  1,  1,  1, G);
    b(c,  4,  2,  1,  1, G);  b(c, 11,  2,  1,  1, G);
    b(c,  4,  3,  1,  1, G);  b(c, 11,  3,  1,  1, G);
    b(c,  5,  4,  1,  1, G);  b(c, 10,  4,  1,  1, G);
    b(c,  6,  5,  4,  1, G);  // chain meets pendant top

    // Chain links (tiny highlight dots)
    b(c,  6,  0,  1,  1, GL); b(c,  9,  0,  1,  1, GL);

    // Pendant setting (gold bezel rows 5-7)
    b(c,  5,  5,  6,  3, GD);
    b(c,  6,  5,  4,  2, G);
    b(c,  6,  5,  3,  1, GL);

    // Teardrop gem (blue sapphire, rows 6-14)
    b(c,  6,  6,  4,  6, BU);          // gem body
    b(c,  5,  8,  6,  4, BU);          // wider mid
    b(c,  6, 12,  4,  2, BU);          // taper
    b(c,  7, 14,  2,  1, BU);          // tip
    // Gem highlight
    b(c,  6,  6,  2,  3, 0xFF88aaff);  // left bright
    b(c,  6,  7,  1,  2, 0xFFbbddff);  // inner gleam
    // Gem shadow
    b(c,  9,  9,  2,  4, 0xFF1133aa);  // right shadow
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RELIC — arcane orb on a pedestal
// ─────────────────────────────────────────────────────────────────────────────
class _RelicPainter extends _P {
  @override
  void draw(Canvas c, Size sz) {
    // Orb outline (circle approx, rows 0-11 centred)
    b(c,  5,  0,  6,  1, SD);
    b(c,  4,  1,  8,  1, SD);
    b(c,  3,  2, 10,  8, SD);
    b(c,  4, 10,  8,  1, SD);
    b(c,  5, 11,  6,  1, SD);

    // Orb face (purple magic orb)
    b(c,  5,  0,  6,  1, PU);
    b(c,  4,  1,  8,  1, PU);
    b(c,  3,  2, 10,  8, PU);
    b(c,  4, 10,  8,  1, PU);
    b(c,  5, 11,  6,  1, PU);

    // Orb inner glow (lighter centre)
    b(c,  5,  2,  6,  3, 0xFFbb55ee);
    b(c,  4,  3,  8,  3, 0xFFbb55ee);

    // Highlight spot (top-left)
    b(c,  5,  1,  3,  3, 0xFFdd88ff);
    b(c,  5,  1,  2,  2, 0xFFf0bbff);

    // Shadow (bottom-right)
    b(c,  9,  7,  4,  4, 0xFF440066);
    b(c,  8,  9,  5,  2, 0xFF440066);

    // Pedestal
    b(c,  6, 12,  4,  1, G);   // neck
    b(c,  4, 13,  8,  1, GD);  // base top
    b(c,  3, 14, 10,  1, G);   // base middle
    b(c,  3, 14, 10,  1, GL);  // highlight
    b(c,  3, 15, 10,  1, GD);  // base shadow

    // Magic runes on pedestal (tiny gold dots)
    b(c,  5, 14,  1,  1, GL);
    b(c,  8, 14,  1,  1, GL);
    b(c, 11, 14,  1,  1, GL);
  }
}
