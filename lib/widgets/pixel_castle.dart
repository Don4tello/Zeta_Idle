import 'dart:math';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PixelCastle — one CustomPainter that renders any tier 1..10 of the SAME
// castle, so upgrading reads as growth of one structure. Pure Dart, no assets.
//
// Drawn on a 64×64 logical pixel grid, scaled to the widget size. Shapes are
// axis-aligned Rect fills on grid coordinates (no strokes/curves) so pixels
// stay square. Composable _draw* functions are gated by tier, not copy-pasted.
// ─────────────────────────────────────────────────────────────────────────────

const int _grid = 64;

class _Pal {
  static const grass      = Color(0xFF3E5A3C);
  static const grassDark  = Color(0xFF2E4630);
  static const dirt       = Color(0xFF4A3929);
  static const stoneDark  = Color(0xFF4A4640);
  static const stoneMid   = Color(0xFF6B6560);
  static const stoneLight = Color(0xFF8A837A);
  static const wood       = Color(0xFF6B4A2E);
  static const woodDark   = Color(0xFF43301E);
  static const roof       = Color(0xFF7A2E2E);
  static const roofDark   = Color(0xFF551F1F);
  static const gold       = Color(0xFFC9A35A);
  static const goldBright = Color(0xFFE6C97A);
  static const torch      = Color(0xFFFFAA33);
  static const windowDark = Color(0xFF20242E);
  static const windowLit  = Color(0xFFFFD98A);
  static const moat       = Color(0xFF3A5F73);
  static const tent       = Color(0xFFB7AE9F);
}

class PixelCastle extends StatefulWidget {
  const PixelCastle({
    super.key,
    required this.tier,
    required this.guildTint,
    this.size = 96,
    this.animate = false,
  });

  final int tier;        // 1..10
  final Color guildTint; // banner/pennant colour (derive deterministically per guild)
  final double size;
  final bool animate;    // tier-10 flag wave + lit-window flicker

  /// Deterministic banner tint from a guild id, so two tier-6 castles differ.
  static Color tintForGuildId(String guildId) {
    var h = 0;
    for (final c in guildId.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    const palette = [
      Color(0xFFcc4444), Color(0xFF4477cc), Color(0xFF44aa66), Color(0xFFcc8844),
      Color(0xFF9955cc), Color(0xFF44aaaa), Color(0xFFcc5599), Color(0xFFbbbb44),
    ];
    return palette[h % palette.length];
  }

  @override
  State<PixelCastle> createState() => _PixelCastleState();
}

class _PixelCastleState extends State<PixelCastle> with SingleTickerProviderStateMixin {
  AnimationController? _ctrl;

  @override
  void initState() {
    super.initState();
    if (widget.animate && widget.tier >= 10) {
      _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
        ..repeat();
    }
  }

  @override
  void didUpdateWidget(PixelCastle old) {
    super.didUpdateWidget(old);
    final wantAnim = widget.animate && widget.tier >= 10;
    if (wantAnim && _ctrl == null) {
      _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
        ..repeat();
    } else if (!wantAnim && _ctrl != null) {
      _ctrl!.dispose();
      _ctrl = null;
    }
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: _ctrl == null
            ? CustomPaint(
                painter: _CastlePainter(widget.tier, widget.guildTint, 0),
                size: Size.square(widget.size))
            : AnimatedBuilder(
                animation: _ctrl!,
                builder: (_, __) => CustomPaint(
                  painter: _CastlePainter(widget.tier, widget.guildTint, _ctrl!.value),
                  size: Size.square(widget.size),
                ),
              ),
      ),
    );
  }
}

class _CastlePainter extends CustomPainter {
  _CastlePainter(this.tier, this.tint, this.wave);
  final int tier;
  final Color tint;
  final double wave; // 0..1 animation phase (tier 10 only)

  late double _cell;
  final Paint _p = Paint()..isAntiAlias = false;

  // Fill a grid rect (x,y,w,h in 0..64 grid units).
  void _fill(Canvas c, double x, double y, double w, double h, Color col) {
    _p.color = col;
    // +0.6 overlap avoids seams between cells at fractional scale.
    c.drawRect(Rect.fromLTWH(x * _cell, y * _cell, w * _cell + 0.6, h * _cell + 0.6), _p);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _cell = size.width / _grid;
    _drawGround(canvas);
    _drawMoat(canvas);      // tier >= 7
    _drawWall(canvas);      // palisade (1-3) → stone wall (4+)
    _drawTowers(canvas);    // tier >= 4
    _drawKeep(canvas);      // tier >= 2 (tent at tier 1)
    _drawGatehouse(canvas); // tier >= 5
    _drawDecor(canvas);     // courtyard tier >= 8, great hall tier >= 9
    _drawBanners(canvas);   // tier >= 5 (tinted)
  }

  // ── Ground ────────────────────────────────────────────────────────────────
  void _drawGround(Canvas c) {
    _fill(c, 0, 50, 64, 3, _Pal.grass);
    _fill(c, 0, 53, 64, 11, _Pal.grassDark);
    // Cleared dirt building plot.
    _fill(c, 12, 49, 40, 2, _Pal.dirt);
    if (tier == 1) {
      // Palisade stumps, a tent and a bare flagpole.
      for (var x = 14; x <= 48; x += 6) {
        _fill(c, x.toDouble(), 45, 2, 5, _Pal.woodDark);
      }
      // Tent (stepped triangle).
      _fill(c, 26, 44, 12, 6, _Pal.tent);
      _fill(c, 28, 41, 8, 3, _Pal.tent);
      _fill(c, 31, 39, 2, 2, _Pal.tent);
      _fill(c, 31, 44, 2, 6, _Pal.woodDark); // tent seam
      // Bare flagpole.
      _fill(c, 44, 33, 1, 17, _Pal.stoneLight);
    }
  }

  // ── Moat & drawbridge (tier >= 7) ───────────────────────────────────────────
  void _drawMoat(Canvas c) {
    if (tier < 7) return;
    _fill(c, 6, 50, 52, 2, _Pal.moat);
    _fill(c, 6, 52, 52, 1, const Color(0xFF2C4A5A));
    // Drawbridge down at the gate.
    _fill(c, 28, 50, 8, 3, _Pal.wood);
    _fill(c, 28, 50, 8, 1, _Pal.woodDark);
  }

  // ── Wall: palisade (1-3) → stone curtain wall (4+) ──────────────────────────
  void _drawWall(Canvas c) {
    if (tier < 2) return;
    if (tier < 4) {
      // Timber palisade with a gate from tier 3.
      _fill(c, 14, 43, 36, 7, _Pal.wood);
      for (var x = 14; x < 50; x += 4) {
        _fill(c, x.toDouble(), 42, 1, 1, _Pal.woodDark);
      }
      if (tier >= 3) _fill(c, 29, 45, 6, 5, _Pal.woodDark); // timber gate
      return;
    }
    // Stone curtain wall.
    final topY = tier >= 8 ? 41.0 : 43.0; // outer curtain sits a touch higher
    _fill(c, 10, topY, 44, 50 - topY, _Pal.stoneMid);
    _fill(c, 10, topY, 44, 1, _Pal.stoneLight);
    _fill(c, 10, 49, 44, 1, _Pal.stoneDark);
    // Crenellations (tier >= 5).
    if (tier >= 5) {
      for (var x = 10; x <= 52; x += 4) {
        _fill(c, x.toDouble(), topY - 2, 2, 2, _Pal.stoneMid);
      }
    }
    // Wall-walk torches (tier >= 6).
    if (tier >= 6) {
      _fill(c, 18, topY - 4, 1, 2, _Pal.torch);
      _fill(c, 45, topY - 4, 1, 2, _Pal.torch);
    }
    // Outer bailey second wall ring (tier >= 8).
    if (tier >= 8) {
      _fill(c, 7, 46, 50, 1, _Pal.stoneDark);
    }
  }

  // ── Corner towers (tier >= 4; four towers + conical roofs at 7+) ────────────
  void _drawTowers(Canvas c) {
    if (tier < 4) return;
    final coords = <double>[8, 50]; // two towers
    final four = tier >= 7;
    final list = four ? <double>[6, 20, 44, 58] : coords;
    final towerTop = tier >= 6 ? 34.0 : 38.0;
    for (final x in list) {
      _fill(c, x, towerTop, 6, 50 - towerTop, _Pal.stoneMid);
      _fill(c, x, towerTop, 1, 50 - towerTop, _Pal.stoneLight);
      _fill(c, x + 5, towerTop, 1, 50 - towerTop, _Pal.stoneDark);
      // Crenellation cap or conical roof.
      if (four) {
        _fill(c, x, towerTop - 3, 6, 3, _Pal.roof);
        _fill(c, x + 1, towerTop - 5, 4, 2, _Pal.roof);
        _fill(c, x + 2, towerTop - 6, 2, 1, _Pal.roofDark);
      } else {
        _fill(c, x, towerTop - 2, 2, 2, _Pal.stoneMid);
        _fill(c, x + 4, towerTop - 2, 2, 2, _Pal.stoneMid);
      }
      // Arrow-slit window.
      _fill(c, x + 2, towerTop + 4, 1, 3, _Pal.windowDark);
    }
  }

  // ── Central keep (tier >= 2; grows storey by storey) ────────────────────────
  void _drawKeep(Canvas c) {
    if (tier < 2) return;
    // Keep height grows with tier.
    final double keepTop = switch (tier) {
      2 => 40,
      3 => 34,
      4 => 34,
      5 => 32,
      6 => 24,
      7 => 24,
      8 => 22,
      9 => 20,
      _ => 18, // 10
    };
    const kx = 26.0, kw = 12.0;
    _fill(c, kx, keepTop, kw, 50 - keepTop, _Pal.stoneMid);
    _fill(c, kx, keepTop, 1, 50 - keepTop, _Pal.stoneLight);
    _fill(c, kx + kw - 1, keepTop, 1, 50 - keepTop, _Pal.stoneDark);

    // Door.
    _fill(c, kx + 4, 45, 4, 5, _Pal.woodDark);
    _fill(c, kx + 5, 44, 2, 1, _Pal.wood);

    // Windows (from tier 3), lit at tier 10.
    final winCol = (tier >= 10) ? _Pal.windowLit : _Pal.windowDark;
    if (tier >= 3) {
      _fill(c, kx + 2, keepTop + 5, 2, 2, winCol);
      _fill(c, kx + 8, keepTop + 5, 2, 2, winCol);
    }
    if (tier >= 6) {
      _fill(c, kx + 2, keepTop + 10, 2, 2, winCol);
      _fill(c, kx + 8, keepTop + 10, 2, 2, winCol);
    }

    // Peaked roof (tier >= 6).
    if (tier >= 6) {
      final roofCol = tier >= 10 ? _Pal.gold : _Pal.roof;
      final roofShd = tier >= 10 ? _Pal.goldBright : _Pal.roofDark;
      _fill(c, kx - 1, keepTop - 2, kw + 2, 2, roofCol);
      _fill(c, kx + 1, keepTop - 4, kw - 2, 2, roofCol);
      _fill(c, kx + 3, keepTop - 6, kw - 6, 2, roofShd);
      // Central spire (tallest at tier 10).
      final spireH = tier >= 10 ? 8.0 : 4.0;
      _fill(c, kx + kw / 2 - 0.5, keepTop - 6 - spireH, 1, spireH, roofShd);
    }

    // Gold trim band at tier 10.
    if (tier >= 10) {
      _fill(c, kx, keepTop, kw, 1, _Pal.goldBright);
      _fill(c, kx, 49, kw, 1, _Pal.gold);
    }
  }

  // ── Gatehouse + portcullis (tier >= 5) ──────────────────────────────────────
  void _drawGatehouse(Canvas c) {
    if (tier < 5) return;
    _fill(c, 28, 40, 8, 10, _Pal.stoneDark);
    _fill(c, 28, 40, 8, 1, _Pal.stoneLight);
    // Portcullis grid.
    _fill(c, 29, 43, 6, 6, const Color(0xFF15130F));
    for (var x = 30; x < 35; x += 2) {
      _fill(c, x.toDouble(), 43, 1, 6, _Pal.stoneMid);
    }
    _fill(c, 29, 45, 6, 1, _Pal.stoneMid);
  }

  // ── Courtyard décor (8) + great-hall wing & spires (9) ──────────────────────
  void _drawDecor(Canvas c) {
    if (tier >= 9) {
      // Great-hall wing on the left with tall arched windows.
      _fill(c, 12, 36, 10, 14, _Pal.stoneMid);
      _fill(c, 12, 36, 10, 1, _Pal.stoneLight);
      _fill(c, 12, 34, 10, 2, _Pal.roof);
      final winCol = tier >= 10 ? _Pal.windowLit : _Pal.windowDark;
      _fill(c, 14, 40, 2, 6, winCol);
      _fill(c, 18, 40, 2, 6, winCol);
      // Spires.
      _fill(c, 16, 30, 1, 4, _Pal.roofDark);
      _fill(c, 21, 31, 1, 3, _Pal.roofDark);
    }
    if (tier >= 8) {
      // Courtyard life: well, training dummy, market stall (small blips).
      _fill(c, 24, 47, 2, 2, _Pal.stoneDark);       // well
      _fill(c, 40, 46, 1, 3, _Pal.wood);            // training dummy post
      _fill(c, 39, 46, 3, 1, _Pal.woodDark);        // dummy arms
      _fill(c, 44, 46, 4, 3, tint.withValues(alpha: 0.85)); // market stall awning
      _fill(c, 44, 47, 4, 2, _Pal.wood);
    }
  }

  // ── Banners / pennants (tier >= 5, guild-tinted; animated at 10) ────────────
  void _drawBanners(Canvas c) {
    if (tier < 5) return;
    // Waving offset for tier-10 animation.
    final w = (tier >= 10) ? (sin(wave * 2 * pi) * 1).roundToDouble() : 0.0;

    // Primary banner on the keep.
    _fill(c, 31, 12, 1, 14, _Pal.stoneLight); // pole
    _fill(c, 32 + w, 13, 4, 6, tint);
    _fill(c, 32 + w, 13, 4, 1, _lighten(tint));

    // Second banner (tier >= 6).
    if (tier >= 6) {
      _fill(c, 20, 30, 1, 8, _Pal.stoneLight);
      _fill(c, 21 + w, 31, 3, 4, tint);
    }

    // Pennants on every tower (tier >= 9).
    if (tier >= 9) {
      for (final x in <double>[6, 20, 44, 58]) {
        _fill(c, x + 3, 27, 1, 5, _Pal.stoneLight);
        _fill(c, x + 4 + w, 27, 2, 2, tint);
      }
    }
  }

  Color _lighten(Color col) => Color.lerp(col, Colors.white, 0.35)!;

  @override
  bool shouldRepaint(_CastlePainter old) =>
      old.tier != tier || old.tint != tint || old.wave != wave;
}
