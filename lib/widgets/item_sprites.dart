import 'package:flutter/material.dart';
import '../models/equipment.dart';

// ── Shared colour palette (file-private) ─────────────────────────────────────
const _K  = 0xFF111117; // outline black
const _SL = 0xFFe8eef4; // silver light
const _S  = 0xFFb0bcc8; // silver mid
const _SD = 0xFF687080; // silver dark
const _G  = 0xFFd4af37; // gold
const _GL = 0xFFf0cc55; // gold light
const _GD = 0xFF9a7c1c; // gold dark
const _BR = 0xFF7a4820; // brown dark
const _BM = 0xFF9a5e2c; // brown mid
const _BL = 0xFFba7a40; // brown light
// ignore: unused_element
const _LT = 0xFFc8a464; // leather tan
// ignore: unused_element
const _LD = 0xFF8a6030; // leather dark
const _RD = 0xFFdd3333; // ruby red
const _BU = 0xFF3366dd; // sapphire blue
// ignore: unused_element
const _GE = 0xFF22aa55; // emerald green
const _PU = 0xFF8833cc; // amethyst purple
// ignore: unused_element
const _CY = 0xFF33ccaa; // cyan accent

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
    b(c,  6, 1, 1, 6, _SD); // left bevel
    b(c,  9, 1, 1, 6, _SD); // right bevel
    // Blade faces
    b(c,  7, 0, 1, 7, _SL); // bright face
    b(c,  8, 0, 1, 7, _S);  // shadow face
    // Tip taper
    b(c,  7, 0, 2, 1, _SL);

    // Crossguard — gold, wider
    b(c,  3, 7, 10, 2, _GD); // dark fill
    b(c,  3, 7, 10, 1, _G);  // top face
    b(c,  4, 7,  8, 1, _GL); // centre highlight
    b(c,  3, 7,  1, 2, _GD); // left cap dark
    b(c, 12, 7,  1, 2, _GD); // right cap dark

    // Grip — wrapped brown
    b(c,  7,  9, 2, 4, _BR);
    b(c,  7,  9, 1, 4, _BM); // lighter face
    b(c,  7, 10, 2, 1, _GL); // gold wrap band
    b(c,  7, 12, 2, 1, _GL); // gold wrap band

    // Pommel — rounded gold
    b(c,  6, 13, 4, 1, _G);
    b(c,  5, 14, 6, 1, _G);
    b(c,  6, 14, 4, 1, _GL); // highlight
    b(c,  5, 15, 6, 1, _GD); // base shadow
    b(c,  6, 13, 4, 1, _GL); // top strip
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OFF-HAND — kite shield, front-facing, with cross boss
// ─────────────────────────────────────────────────────────────────────────────
class _OffHandPainter extends _P {
  @override
  void draw(Canvas c, Size sz) {
    // Dark outline shape
    b(c,  4,  0,  8,  1, _SD);
    b(c,  3,  1, 10,  9, _SD);
    b(c,  4, 10,  8,  1, _SD);
    b(c,  5, 11,  6,  1, _SD);
    b(c,  6, 12,  4,  1, _SD);
    b(c,  7, 13,  2,  2, _SD);
    b(c,  7, 15,  2,  1, _K);  // very tip

    // Silver face (1px inset)
    b(c,  4,  0,  8,  1, _S);
    b(c,  4,  1,  8,  8, _S);
    b(c,  4, 10,  8,  1, _S);
    b(c,  5, 11,  6,  1, _S);
    b(c,  6, 12,  4,  1, _S);
    b(c,  7, 13,  2,  2, _S);
    b(c,  8, 15,  1,  1, _SD); // tip

    // Left-edge & top highlight
    b(c,  4,  0,  4,  1, _SL);
    b(c,  4,  1,  2,  8, _SL);
    b(c,  4,  1,  4,  3, _SL);

    // Cross boss (gold)
    b(c,  7,  2,  2,  9, _G);  // vertical bar
    b(c,  5,  5,  6,  3, _G);  // horizontal bar
    b(c,  7,  5,  2,  3, _GL); // inner highlight
    b(c,  7,  2,  2,  1, _GL); // top of vertical
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELMET — visored great helm, front-facing
// ─────────────────────────────────────────────────────────────────────────────
class _HelmetPainter extends _P {
  @override
  void draw(Canvas c, Size sz) {
    // Dome outline
    b(c,  5,  0,  6,  1, _SD);
    b(c,  4,  1,  8,  2, _SD);
    b(c,  3,  3, 10,  2, _SD);

    // Dome face
    b(c,  5,  0,  6,  1, _S);
    b(c,  4,  1,  8,  2, _S);
    b(c,  3,  3, 10,  2, _S);

    // Dome highlight (upper-left)
    b(c,  5,  0,  4,  1, _SL);
    b(c,  4,  1,  5,  1, _SL);
    b(c,  3,  2,  4,  2, _SL);

    // Plume (red)
    b(c,  7,  0,  2,  3, _RD);
    b(c,  7,  0,  1,  2, 0xFFff5555); // lighter left

    // Cheekguards
    b(c,  2,  5,  3,  5, _SD);
    b(c,  2,  5,  2,  5, _S);
    b(c, 11,  5,  3,  5, _SD);
    b(c, 12,  5,  2,  5, _S);

    // Visor opening (dark)
    b(c,  4,  5,  8,  3, _K);
    b(c,  5,  5,  6,  1, 0xFF222244); // tinted top
    b(c,  5,  6,  6,  2, _K);

    // Nasal guard (gold vertical strip)
    b(c,  7,  5,  2,  3, _G);
    b(c,  7,  5,  1,  3, _GL);

    // Gorget (neck guard rows 10-12)
    b(c,  3, 10, 10,  1, _SD);
    b(c,  4, 10,  8,  1, _S);
    b(c,  4, 11,  8,  1, _SD);
    b(c,  5, 11,  6,  1, _S);
    b(c,  5, 12,  6,  1, _SD);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ARMOR — full chest plate, front-facing
// ─────────────────────────────────────────────────────────────────────────────
class _ArmorPainter extends _P {
  @override
  void draw(Canvas c, Size sz) {
    // Left pauldron
    b(c,  1,  2,  4,  4, _SD);
    b(c,  1,  2,  4,  3, _S);
    b(c,  1,  2,  3,  1, _SL);

    // Right pauldron
    b(c, 11,  2,  4,  4, _SD);
    b(c, 11,  2,  4,  3, _S);
    b(c, 12,  2,  3,  1, _SL);

    // Chest body outline
    b(c,  4,  2,  8, 12, _SD);

    // Chest face
    b(c,  5,  3,  6, 10, _S);
    b(c,  5,  3,  3,  6, _SL); // upper-left highlight

    // Gold trim bands
    b(c,  4,  4,  8,  1, _G);  // upper chest band
    b(c,  4, 11,  8,  1, _G);  // lower chest band

    // Centre plate emblem
    b(c,  6,  5,  4,  6, _GD); // dark
    b(c,  7,  5,  2,  6, _G);  // gold vertical
    b(c,  6,  7,  4,  2, _G);  // gold horizontal
    b(c,  7,  7,  2,  2, _GL); // bright centre

    // Waist guard
    b(c,  4, 12,  8,  2, _GD);
    b(c,  5, 12,  6,  1, _G);
    b(c,  5, 13,  6,  1, _SD);

    // Neck opening (dark)
    b(c,  6,  2,  4,  2, _K);
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
      b(c, fx,     0, 2, height, _SD);
      b(c, fx,     0, 2, height, _S);
      b(c, fx,     0, 1, height - 1, _SL);
    }

    // Knuckle plate (gold, row 5-6, covers all fingers)
    b(c,  2,  5, 12,  2, _GD);
    b(c,  2,  5, 12,  1, _G);
    b(c,  3,  5, 10,  1, _GL);

    // Palm / back of hand (rows 7-11)
    b(c,  2,  7, 12,  5, _SD);
    b(c,  3,  7, 10,  4, _S);
    b(c,  3,  7,  5,  3, _SL); // highlight

    // Gold knuckle detail row
    b(c,  3,  9,  3,  1, _G);
    b(c,  7,  9,  3,  1, _G);
    b(c, 11,  9,  2,  1, _G);

    // Wrist cuff (rows 12-15)
    b(c,  2, 12, 12,  1, _GD);
    b(c,  2, 13, 12,  2, _G);
    b(c,  2, 13, 12,  1, _GL);
    b(c,  2, 15, 12,  1, _GD);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PANTS — armoured greaves, front view (two legs side by side)
// ─────────────────────────────────────────────────────────────────────────────
class _PantsPainter extends _P {
  @override
  void draw(Canvas c, Size sz) {
    // Left leg
    b(c,  2,  0,  5, 14, _SD);
    b(c,  2,  0,  5, 13, _S);
    b(c,  2,  0,  3,  6, _SL); // highlight
    // Left knee cap (gold)
    b(c,  2,  7,  5,  2, _G);
    b(c,  3,  7,  3,  1, _GL);

    // Right leg
    b(c,  9,  0,  5, 14, _SD);
    b(c,  9,  0,  5, 13, _S);
    b(c, 10,  0,  2,  6, _SL); // highlight
    // Right knee cap (gold)
    b(c,  9,  7,  5,  2, _G);
    b(c, 10,  7,  3,  1, _GL);

    // Hip plate connecting the two legs (top band)
    b(c,  1,  0, 14,  3, _GD);
    b(c,  2,  0, 12,  2, _G);
    b(c,  2,  0, 12,  1, _GL);

    // Belt / gap between legs (small dark gap at centre)
    b(c,  7,  3,  2, 10, _K);

    // Ankle guards (gold trim at bottom)
    b(c,  2, 13,  5,  2, _G);
    b(c,  2, 13,  5,  1, _GL);
    b(c,  9, 13,  5,  2, _G);
    b(c,  9, 13,  5,  1, _GL);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOOTS — armoured boot, side view
// ─────────────────────────────────────────────────────────────────────────────
class _BootsPainter extends _P {
  @override
  void draw(Canvas c, Size sz) {
    // Shin guard (upper boot, rows 0-8)
    b(c,  5,  0,  7,  9, _SD); // dark outline
    b(c,  5,  0,  7,  8, _S);  // face
    b(c,  5,  0,  4,  5, _SL); // highlight

    // Gold shin trim
    b(c,  5,  8,  7,  1, _G);
    b(c,  5,  8,  7,  1, _GL);

    // Foot (rows 9-13, extends right)
    b(c,  4,  9, 10,  5, _SD); // dark outline
    b(c,  5,  9,  9,  4, _S);  // face
    b(c,  5,  9,  5,  2, _SL); // highlight

    // Sole (bottom, row 14-15, slightly wider)
    b(c,  3, 14, 12,  1, _SD);
    b(c,  4, 14, 10,  1, _K);
    b(c,  3, 15, 12,  1, _K);  // thick sole

    // Gold ankle band
    b(c,  4, 13, 10,  1, _G);
    b(c,  5, 13,  8,  1, _GL);

    // Toe cap
    b(c, 11,  9,  3,  5, _GD);
    b(c, 11,  9,  3,  4, _G);
    b(c, 11,  9,  2,  2, _GL);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RING — band with large gemstone, top-down / face-on view
// ─────────────────────────────────────────────────────────────────────────────
class _RingPainter extends _P {
  @override
  void draw(Canvas c, Size sz) {
    // Outer ring band (circle approximation)
    b(c,  5,  1,  6,  1, _G);  // top arc
    b(c,  3,  2,  2,  1, _G);  b(c, 11,  2,  2,  1, _G);
    b(c,  2,  3,  2,  4, _G);  b(c, 12,  3,  2,  4, _G);
    b(c,  3,  7,  2,  1, _G);  b(c, 11,  7,  2,  1, _G);
    b(c,  5,  8,  6,  1, _G);  // bottom arc

    // Inner band highlight (lighter)
    b(c,  5,  1,  4,  1, _GL);
    b(c,  3,  2,  1,  1, _GL); b(c,  2,  3,  1,  2, _GL);

    // Inner dark (hole of ring)
    b(c,  5,  2,  6,  1, _GD);
    b(c,  4,  3,  1,  3, _GD); b(c, 11,  3,  1,  3, _GD);
    b(c,  5,  6,  6,  1, _GD);
    // Very inside (background)
    b(c,  5,  3,  6,  3, _K);

    // Setting / bezel (top)
    b(c,  6,  0,  4,  2, _GD);
    b(c,  6,  0,  4,  1, _G);

    // Gemstone (ruby red, rows -2 to 0 — use 0..1 since we have room)
    // Let's put a big gem at top rows 0-4 centred
    b(c,  5, -1,  6,  4, _RD); // won't render (negative), shift down
    // Center gem on top of ring
    b(c,  5,  0,  6,  3, _RD);         // gem body
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
    b(c,  6,  0,  1,  1, _G);  b(c,  9,  0,  1,  1, _G);
    b(c,  5,  1,  1,  1, _G);  b(c, 10,  1,  1,  1, _G);
    b(c,  4,  2,  1,  1, _G);  b(c, 11,  2,  1,  1, _G);
    b(c,  4,  3,  1,  1, _G);  b(c, 11,  3,  1,  1, _G);
    b(c,  5,  4,  1,  1, _G);  b(c, 10,  4,  1,  1, _G);
    b(c,  6,  5,  4,  1, _G);  // chain meets pendant top

    // Chain links (tiny highlight dots)
    b(c,  6,  0,  1,  1, _GL); b(c,  9,  0,  1,  1, _GL);

    // Pendant setting (gold bezel rows 5-7)
    b(c,  5,  5,  6,  3, _GD);
    b(c,  6,  5,  4,  2, _G);
    b(c,  6,  5,  3,  1, _GL);

    // Teardrop gem (blue sapphire, rows 6-14)
    b(c,  6,  6,  4,  6, _BU);          // gem body
    b(c,  5,  8,  6,  4, _BU);          // wider mid
    b(c,  6, 12,  4,  2, _BU);          // taper
    b(c,  7, 14,  2,  1, _BU);          // tip
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
    b(c,  5,  0,  6,  1, _SD);
    b(c,  4,  1,  8,  1, _SD);
    b(c,  3,  2, 10,  8, _SD);
    b(c,  4, 10,  8,  1, _SD);
    b(c,  5, 11,  6,  1, _SD);

    // Orb face (purple magic orb)
    b(c,  5,  0,  6,  1, _PU);
    b(c,  4,  1,  8,  1, _PU);
    b(c,  3,  2, 10,  8, _PU);
    b(c,  4, 10,  8,  1, _PU);
    b(c,  5, 11,  6,  1, _PU);

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
    b(c,  6, 12,  4,  1, _G);   // neck
    b(c,  4, 13,  8,  1, _GD);  // base top
    b(c,  3, 14, 10,  1, _G);   // base middle
    b(c,  3, 14, 10,  1, _GL);  // highlight
    b(c,  3, 15, 10,  1, _GD);  // base shadow

    // Magic runes on pedestal (tiny gold dots)
    b(c,  5, 14,  1,  1, _GL);
    b(c,  8, 14,  1,  1, _GL);
    b(c, 11, 14,  1,  1, _GL);
  }
}
