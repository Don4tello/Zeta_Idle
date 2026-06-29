import 'package:flutter/material.dart';

/// Returns a stage-themed background painter.
/// [stageIndex] is 0-based (stage 1 = index 0).
/// Cycles every 25 stages (one prestige cycle).
CustomPainter battleBackgroundFor(int stageIndex) {
  switch (stageIndex % 25) {
    case 0:  return const _CryptPainter();           // Graveyard Gate
    case 1:  return const _CryptPainter();           // Forsaken Keep
    case 2:  return const _AbyssCavePainter();       // Abyssal Crypt
    case 3:  return const _DarkThronePainter();      // Dark Throne
    case 4:  return const _MossyRuinsPainter();      // Mossy Ruins
    case 5:  return const _DarkwoodPainter();        // Darkwood Hollow
    case 6:  return const _FrostedPeaksPainter();    // Frosted Peaks
    case 7:  return const _BloodmarshPainter();      // Bloodmarsh
    case 8:  return const _CryptPainter();           // Tower of Bones
    case 9:  return const _SpiderCitadelPainter();   // Spider Citadel
    case 10: return const _HellFirePainter();        // Hellfire Fortress
    case 11: return const _HellFirePainter();        // Dragon's Lair
    case 12: return const _LichThronePainter();      // Throne of the Ancient Lich
    case 13: return const _HellFirePainter();        // Magma Keep
    case 14: return const _HellFirePainter();        // The Forge Tyrant
    case 15: return const _VoidExpansePainter();     // The Null Chamber
    case 16: return const _VoidExpansePainter();     // Phase Labyrinth
    case 17: return const _ShadowRealmPainter();     // The Shattered Cathedral
    case 18: return const _VoidExpansePainter();     // Starfall Ruins
    case 19: return const _VoidExpansePainter();     // The Void Gate
    case 20: return const _DarkCitadelPainter();     // The Dark Citadel
    case 21: return const _DarkCitadelPainter();     // Hall of Fallen Kings
    case 22: return const _AbyssCavePainter();       // The Necropolis Core
    case 23: return const _LichThronePainter();      // The Lich's Sanctum
    case 24: return const _DarkCitadelPainter();     // The Dark Lord
    default: return const _ShadowRealmPainter();
  }
}

// ─────────────────────────────────────────────────────────────────
// Shared helper
// ─────────────────────────────────────────────────────────────────

abstract class _BgPainter extends CustomPainter {
  const _BgPainter();

  @override
  bool shouldRepaint(_BgPainter old) => false;

  void drawBg(Canvas c, Size sz);

  @override
  void paint(Canvas c, Size sz) => drawBg(c, sz);

  void b(Canvas c, Size sz, double x, double y, double w, double h, int rgba) {
    c.drawRect(
      Rect.fromLTWH(
          x * sz.width, y * sz.height, w * sz.width, h * sz.height),
      Paint()..color = Color(rgba),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// CRYPT   (Stages 1, 2, 9 — dungeon stone)
// Dark stone dungeon with torches, brick walls, skull
// ─────────────────────────────────────────────────────────────────

class _CryptPainter extends _BgPainter {
  const _CryptPainter();

  @override
  void drawBg(Canvas c, Size sz) {
    b(c, sz, 0, 0, 1, 0.12, 0xFF04040c);

    b(c, sz, 0, 0.08, 1, 0.12, 0xFF18182a);
    for (int i = 0; i < 8; i++) {
      b(c, sz, i * 0.125, 0.08, 0.11, 0.05, 0xFF222238);
      b(c, sz, i * 0.125 + 0.0625, 0.12, 0.11, 0.04, 0xFF1c1c30);
    }

    b(c, sz, 0.07, 0.16, 0.86, 0.62, 0xFF1c1c2a);

    for (int row = 0; row < 7; row++) {
      final offset = row.isOdd ? 0.05 : 0.0;
      for (int col = 0; col < 11; col++) {
        final bx = 0.08 + col * 0.088 + offset;
        final by = 0.19 + row * 0.083;
        if (bx + 0.078 < 0.93) {
          b(c, sz, bx, by, 0.078, 0.072, 0xFF242438);
        }
      }
    }

    b(c, sz, 0, 0.08, 0.07, 0.7, 0xFF10101e);
    b(c, sz, 0.93, 0.08, 0.07, 0.7, 0xFF10101e);
    b(c, sz, 0.055, 0.1, 0.018, 0.65, 0xFF1e1e30);
    b(c, sz, 0.927, 0.1, 0.018, 0.65, 0xFF1e1e30);

    b(c, sz, 0.115, 0.26, 0.04, 0.09, 0xFF3a2010);
    b(c, sz, 0.11, 0.17, 0.05, 0.10, 0xBBff6600);
    b(c, sz, 0.12, 0.15, 0.03, 0.08, 0xDDffaa00);
    b(c, sz, 0.128, 0.13, 0.016, 0.05, 0xFFffee80);
    b(c, sz, 0.07, 0.12, 0.18, 0.42, 0x10ff8800);

    b(c, sz, 0.845, 0.26, 0.04, 0.09, 0xFF3a2010);
    b(c, sz, 0.84, 0.17, 0.05, 0.10, 0xBBff6600);
    b(c, sz, 0.85, 0.15, 0.03, 0.08, 0xDDffaa00);
    b(c, sz, 0.856, 0.13, 0.016, 0.05, 0xFFffee80);
    b(c, sz, 0.75, 0.12, 0.18, 0.42, 0x10ff8800);

    b(c, sz, 0.44, 0.27, 0.12, 0.10, 0xFF8a7860);
    b(c, sz, 0.45, 0.28, 0.03, 0.04, 0xFF2a1810);
    b(c, sz, 0.52, 0.28, 0.03, 0.04, 0xFF2a1810);
    b(c, sz, 0.46, 0.35, 0.08, 0.015, 0xFF6a5040);

    b(c, sz, 0, 0.78, 1, 0.22, 0xFF0c0c18);
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 3; j++) {
        b(c, sz, i * 0.2 + 0.01, 0.80 + j * 0.065, 0.18, 0.055, 0xFF181828);
      }
    }
    b(c, sz, 0, 0.92, 1, 0.08, 0xFF080810);
  }
}

// ─────────────────────────────────────────────────────────────────
// SHADOW REALM   (Stage 18 — Shattered Cathedral)
// Dark purple sky, twisted trees, misty ground, glowing eyes
// ─────────────────────────────────────────────────────────────────

class _ShadowRealmPainter extends _BgPainter {
  const _ShadowRealmPainter();

  @override
  void drawBg(Canvas c, Size sz) {
    b(c, sz, 0, 0, 1, 0.25, 0xFF060614);
    b(c, sz, 0, 0.20, 1, 0.20, 0xFF0e0828);
    b(c, sz, 0, 0.35, 1, 0.20, 0xFF160a3a);
    b(c, sz, 0, 0.50, 1, 0.25, 0xFF1a0c3e);
    b(c, sz, 0, 0.70, 1, 0.30, 0xFF0e0820);

    b(c, sz, 0.44, 0.04, 0.12, 0.12, 0x20e8e8ff);
    b(c, sz, 0.46, 0.05, 0.08, 0.09, 0x40e8e8ff);
    b(c, sz, 0.475, 0.06, 0.05, 0.06, 0xAAc8c8ff);

    b(c, sz, 0.02, 0.25, 0.04, 0.5, 0xFF100820);
    b(c, sz, 0.015, 0.28, 0.055, 0.04, 0xFF100820);
    b(c, sz, 0.0, 0.22, 0.08, 0.03, 0xFF0e0618);
    b(c, sz, 0.025, 0.34, 0.07, 0.03, 0xFF100820);
    b(c, sz, 0.0, 0.42, 0.06, 0.025, 0xFF0e0618);
    b(c, sz, 0, 0.1, 0.18, 0.18, 0xFF0a0618);
    b(c, sz, 0, 0.22, 0.12, 0.12, 0xFF0c0820);

    b(c, sz, 0.94, 0.25, 0.04, 0.5, 0xFF100820);
    b(c, sz, 0.925, 0.30, 0.06, 0.035, 0xFF100820);
    b(c, sz, 0.92, 0.24, 0.08, 0.03, 0xFF0e0618);
    b(c, sz, 0.93, 0.38, 0.07, 0.025, 0xFF100820);
    b(c, sz, 0.82, 0.1, 0.18, 0.18, 0xFF0a0618);
    b(c, sz, 0.88, 0.22, 0.12, 0.12, 0xFF0c0820);

    b(c, sz, 0.035, 0.32, 0.018, 0.014, 0xCCffd040);
    b(c, sz, 0.065, 0.32, 0.018, 0.014, 0xCCffd040);
    b(c, sz, 0.915, 0.35, 0.018, 0.014, 0xCCffd040);
    b(c, sz, 0.947, 0.35, 0.018, 0.014, 0xCCffd040);

    b(c, sz, 0, 0.68, 1, 0.06, 0x228080c0);
    b(c, sz, 0, 0.72, 1, 0.08, 0x304060a0);
    b(c, sz, 0, 0.76, 1, 0.06, 0x20c0c0ff);

    b(c, sz, 0, 0.78, 1, 0.22, 0xFF0a0818);
    b(c, sz, 0, 0.90, 1, 0.10, 0xFF06060e);

    b(c, sz, 0.1, 0.77, 0.2, 0.04, 0x18c0c0ff);
    b(c, sz, 0.5, 0.76, 0.3, 0.035, 0x18c0c0ff);
    b(c, sz, 0.7, 0.79, 0.15, 0.03, 0x14c0c0ff);
  }
}

// ─────────────────────────────────────────────────────────────────
// ABYSSAL CAVE   (Stages 3, 23 — deep crypt)
// Dark cave, stalactites, glowing green pools, rocky floor
// ─────────────────────────────────────────────────────────────────

class _AbyssCavePainter extends _BgPainter {
  const _AbyssCavePainter();

  @override
  void drawBg(Canvas c, Size sz) {
    b(c, sz, 0, 0, 1, 1, 0xFF040808);

    b(c, sz, 0, 0, 1, 0.22, 0xFF0c1210);

    final stalList = [
      [0.05, 0.08], [0.15, 0.12], [0.25, 0.09], [0.35, 0.14],
      [0.45, 0.07], [0.55, 0.11], [0.65, 0.13], [0.75, 0.08],
      [0.85, 0.10], [0.92, 0.06],
    ];
    for (final s in stalList) {
      final sx = s[0];
      final sh = s[1];
      b(c, sz, sx - 0.015, 0, 0.03, sh, 0xFF162018);
      b(c, sz, sx - 0.008, sh - 0.01, 0.016, 0.015, 0xFF1c2820);
    }

    b(c, sz, 0, 0.20, 1, 0.55, 0xFF0a1210);
    b(c, sz, 0, 0.30, 1, 0.08, 0xFF0e1814);
    b(c, sz, 0, 0.45, 1, 0.10, 0xFF0c1612);

    b(c, sz, 0, 0.6, 1, 0.4, 0xFF060e0a);
    b(c, sz, 0.05, 0.72, 0.25, 0.15, 0xFF081408);
    b(c, sz, 0.07, 0.74, 0.21, 0.12, 0xFF0c200c);
    b(c, sz, 0.10, 0.76, 0.15, 0.09, 0xFF103010);
    b(c, sz, 0.12, 0.78, 0.10, 0.06, 0xFF1a4a1a);
    b(c, sz, 0.14, 0.80, 0.06, 0.03, 0xFF286028);

    b(c, sz, 0.70, 0.72, 0.25, 0.15, 0xFF081408);
    b(c, sz, 0.72, 0.74, 0.21, 0.12, 0xFF0c200c);
    b(c, sz, 0.75, 0.76, 0.15, 0.09, 0xFF103010);
    b(c, sz, 0.77, 0.78, 0.10, 0.06, 0xFF1a4a1a);
    b(c, sz, 0.80, 0.80, 0.06, 0.03, 0xFF286028);

    b(c, sz, 0, 0.55, 0.35, 0.3, 0x0E10a010);
    b(c, sz, 0.65, 0.55, 0.35, 0.3, 0x0E10a010);

    b(c, sz, 0, 0.75, 1, 0.25, 0xFF080e08);
    b(c, sz, 0.3, 0.70, 0.12, 0.10, 0xFF0e1810);
    b(c, sz, 0.55, 0.72, 0.09, 0.08, 0xFF0c1610);
    b(c, sz, 0, 0.78, 0.08, 0.22, 0xFF0a1208);
    b(c, sz, 0.92, 0.78, 0.08, 0.22, 0xFF0a1208);

    b(c, sz, 0, 0.90, 1, 0.10, 0xFF040808);
  }
}

// ─────────────────────────────────────────────────────────────────
// DARK THRONE   (Stage 4 — Dark Throne)
// Castle throne room, red light, pillars, throne silhouette
// ─────────────────────────────────────────────────────────────────

class _DarkThronePainter extends _BgPainter {
  const _DarkThronePainter();

  @override
  void drawBg(Canvas c, Size sz) {
    b(c, sz, 0, 0, 1, 1, 0xFF060408);
    b(c, sz, 0, 0, 1, 0.18, 0xFF0c080e);

    for (int i = 0; i < 6; i++) {
      b(c, sz, i * 0.167, 0, 0.155, 0.10, 0xFF100c12);
      b(c, sz, i * 0.167 + 0.083, 0.08, 0.155, 0.10, 0xFF0e0a10);
    }

    b(c, sz, 0.05, 0.15, 0.90, 0.62, 0xFF0e0a10);

    for (int row = 0; row < 6; row++) {
      for (int col = 0; col < 8; col++) {
        final offset = row.isOdd ? 0.055 : 0.0;
        final bx = 0.06 + col * 0.11 + offset;
        final by = 0.18 + row * 0.093;
        if (bx + 0.10 < 0.95) {
          b(c, sz, bx, by, 0.095, 0.082, 0xFF130f16);
        }
      }
    }

    b(c, sz, 0.10, 0.18, 0.12, 0.22, 0xFF300810);
    b(c, sz, 0.115, 0.20, 0.09, 0.17, 0xFF601020);
    b(c, sz, 0.115, 0.20, 0.09, 0.17, 0xAA8b0000);
    b(c, sz, 0.07, 0.18, 0.2, 0.28, 0x18cc0000);

    b(c, sz, 0.78, 0.18, 0.12, 0.22, 0xFF300810);
    b(c, sz, 0.795, 0.20, 0.09, 0.17, 0xFF601020);
    b(c, sz, 0.795, 0.20, 0.09, 0.17, 0xAA8b0000);
    b(c, sz, 0.73, 0.18, 0.2, 0.28, 0x18cc0000);

    b(c, sz, 0.00, 0.12, 0.07, 0.66, 0xFF0a080c);
    b(c, sz, 0.005, 0.14, 0.02, 0.62, 0xFF14101a);
    b(c, sz, 0.055, 0.14, 0.02, 0.62, 0xFF100c16);

    b(c, sz, 0.93, 0.12, 0.07, 0.66, 0xFF0a080c);
    b(c, sz, 0.925, 0.14, 0.02, 0.62, 0xFF14101a);
    b(c, sz, 0.975, 0.14, 0.02, 0.62, 0xFF100c16);

    b(c, sz, 0.38, 0.28, 0.24, 0.40, 0xFF08060a);
    b(c, sz, 0.36, 0.24, 0.28, 0.06, 0xFF0a080c);
    b(c, sz, 0.35, 0.20, 0.08, 0.10, 0xFF0a080c);
    b(c, sz, 0.57, 0.20, 0.08, 0.10, 0xFF0a080c);
    b(c, sz, 0.44, 0.18, 0.12, 0.12, 0xFF0e0c10);
    b(c, sz, 0.47, 0.17, 0.06, 0.04, 0xFF1a0010);
    b(c, sz, 0.46, 0.35, 0.08, 0.06, 0xFF3a0010);
    b(c, sz, 0.47, 0.36, 0.06, 0.04, 0xFF660020);
    b(c, sz, 0.485, 0.37, 0.03, 0.02, 0xAA8b0000);

    b(c, sz, 0.40, 0.68, 0.20, 0.32, 0xFF1a0008);
    b(c, sz, 0.43, 0.68, 0.14, 0.32, 0xFF250010);
    b(c, sz, 0.46, 0.68, 0.08, 0.32, 0xFF320018);

    b(c, sz, 0, 0.77, 1, 0.23, 0xFF080608);
    for (int i = 0; i < 5; i++) {
      b(c, sz, i * 0.2 + 0.01, 0.79, 0.18, 0.065, 0xFF0c0a0e);
      b(c, sz, i * 0.2 + 0.01, 0.86, 0.18, 0.065, 0xFF0a0810);
    }
    b(c, sz, 0, 0.91, 1, 0.09, 0xFF040308);
    b(c, sz, 0.35, 0.78, 0.30, 0.15, 0x0Acc0020);
  }
}

// ─────────────────────────────────────────────────────────────────
// MOSSY RUINS   (Stage 5 — Mossy Ruins)
// Overcast sky, crumbling stone walls with green moss, vines
// ─────────────────────────────────────────────────────────────────

class _MossyRuinsPainter extends _BgPainter {
  const _MossyRuinsPainter();

  @override
  void drawBg(Canvas c, Size sz) {
    // Overcast grey-green sky
    b(c, sz, 0, 0, 1, 1, 0xFF0a100a);
    b(c, sz, 0, 0, 1, 0.35, 0xFF0e1510);
    b(c, sz, 0, 0.25, 1, 0.20, 0xFF101812);
    b(c, sz, 0, 0.40, 1, 0.20, 0xFF0c1210);

    // Dim cloudy glow above
    b(c, sz, 0.30, 0.02, 0.40, 0.10, 0x10a0c0a0);
    b(c, sz, 0.35, 0.04, 0.30, 0.07, 0x18b0d0b0);

    // Back ruined wall (crumbling stone)
    b(c, sz, 0.04, 0.18, 0.92, 0.58, 0xFF141e14);
    // Stone blocks
    for (int row = 0; row < 6; row++) {
      final offset = row.isOdd ? 0.055 : 0.0;
      for (int col = 0; col < 9; col++) {
        final bx = 0.05 + col * 0.10 + offset;
        final by = 0.20 + row * 0.093;
        if (bx + 0.09 < 0.96) {
          b(c, sz, bx, by, 0.085, 0.082, 0xFF1a2618);
        }
      }
    }

    // Moss patches on wall (dark green splotches)
    b(c, sz, 0.10, 0.22, 0.08, 0.06, 0xFF1e3018);
    b(c, sz, 0.30, 0.26, 0.10, 0.05, 0xFF203218);
    b(c, sz, 0.55, 0.20, 0.07, 0.07, 0xFF1c2e14);
    b(c, sz, 0.72, 0.32, 0.09, 0.05, 0xFF1e3018);
    b(c, sz, 0.45, 0.38, 0.08, 0.06, 0xFF202e14);
    b(c, sz, 0.20, 0.42, 0.07, 0.04, 0xFF1e3018);
    b(c, sz, 0.80, 0.24, 0.08, 0.05, 0xFF203218);

    // Crumbling gaps / rubble patches on wall top
    b(c, sz, 0.12, 0.18, 0.08, 0.04, 0xFF0a100a);
    b(c, sz, 0.42, 0.16, 0.06, 0.05, 0xFF0a100a);
    b(c, sz, 0.70, 0.19, 0.07, 0.03, 0xFF0a100a);

    // Left ruin pillar (half collapsed)
    b(c, sz, 0.00, 0.10, 0.07, 0.66, 0xFF101810);
    b(c, sz, 0.005, 0.12, 0.02, 0.62, 0xFF182618);
    b(c, sz, 0.055, 0.12, 0.018, 0.60, 0xFF162414);
    b(c, sz, 0.02, 0.08, 0.04, 0.06, 0xFF1a2a18); // crumble top

    // Right ruin pillar
    b(c, sz, 0.93, 0.10, 0.07, 0.66, 0xFF101810);
    b(c, sz, 0.925, 0.12, 0.02, 0.62, 0xFF182618);
    b(c, sz, 0.975, 0.12, 0.018, 0.60, 0xFF162414);
    b(c, sz, 0.94, 0.09, 0.04, 0.05, 0xFF1a2a18);

    // Hanging vines (left pillar)
    for (int i = 0; i < 4; i++) {
      final vx = 0.01 + i * 0.012;
      b(c, sz, vx, 0.10, 0.008, 0.30 + i * 0.04, 0xFF1a3214);
    }
    // Hanging vines (right pillar)
    for (int i = 0; i < 4; i++) {
      final vx = 0.96 - i * 0.012;
      b(c, sz, vx, 0.10, 0.008, 0.28 + i * 0.05, 0xFF1a3214);
    }
    // Vines on wall center
    b(c, sz, 0.48, 0.18, 0.006, 0.38, 0xFF183010);
    b(c, sz, 0.60, 0.20, 0.005, 0.28, 0xFF183010);
    b(c, sz, 0.35, 0.22, 0.005, 0.22, 0xFF1a3214);

    // Mossy ground mist
    b(c, sz, 0, 0.66, 1, 0.05, 0x2830a830);
    b(c, sz, 0, 0.70, 1, 0.07, 0x2040c040);

    // Muddy green floor
    b(c, sz, 0, 0.74, 1, 0.26, 0xFF0c1408);
    b(c, sz, 0, 0.86, 1, 0.14, 0xFF080e06);
    // Moss tufts on ground
    b(c, sz, 0.10, 0.74, 0.12, 0.03, 0xFF183014);
    b(c, sz, 0.40, 0.75, 0.15, 0.025, 0xFF1a3016);
    b(c, sz, 0.70, 0.74, 0.10, 0.03, 0xFF183014);
    b(c, sz, 0, 0.92, 1, 0.08, 0xFF040a04);
  }
}

// ─────────────────────────────────────────────────────────────────
// DARKWOOD   (Stage 6 — Darkwood Hollow)
// Night forest, twisted trees, pale moon, green mist ground
// ─────────────────────────────────────────────────────────────────

class _DarkwoodPainter extends _BgPainter {
  const _DarkwoodPainter();

  @override
  void drawBg(Canvas c, Size sz) {
    b(c, sz, 0, 0, 1, 1, 0xFF020808);
    b(c, sz, 0, 0, 1, 0.45, 0xFF040c04);
    b(c, sz, 0, 0.40, 1, 0.20, 0xFF060e06);

    b(c, sz, 0.43, 0.04, 0.14, 0.14, 0x1880ff80);
    b(c, sz, 0.45, 0.05, 0.10, 0.10, 0x3060e060);
    b(c, sz, 0.47, 0.06, 0.06, 0.07, 0xFF90c890);

    b(c, sz, 0, 0.30, 0.20, 0.40, 0xFF040c04);
    b(c, sz, 0.15, 0.25, 0.18, 0.45, 0xFF050d05);
    b(c, sz, 0.65, 0.28, 0.20, 0.42, 0xFF040c04);
    b(c, sz, 0.80, 0.22, 0.20, 0.48, 0xFF050d05);

    b(c, sz, 0.03, 0.20, 0.05, 0.60, 0xFF080e08);
    b(c, sz, 0.025, 0.22, 0.06, 0.04, 0xFF080e08);
    b(c, sz, 0.01, 0.28, 0.08, 0.03, 0xFF060c06);
    b(c, sz, 0.03, 0.38, 0.08, 0.03, 0xFF080e08);
    b(c, sz, 0.00, 0.48, 0.06, 0.025, 0xFF060c06);
    b(c, sz, 0.00, 0.10, 0.20, 0.15, 0xFF060c06);
    b(c, sz, 0.00, 0.18, 0.15, 0.12, 0xFF080e08);

    b(c, sz, 0.92, 0.22, 0.05, 0.58, 0xFF080e08);
    b(c, sz, 0.915, 0.24, 0.06, 0.04, 0xFF080e08);
    b(c, sz, 0.91, 0.32, 0.07, 0.03, 0xFF060c06);
    b(c, sz, 0.93, 0.44, 0.07, 0.025, 0xFF080e08);
    b(c, sz, 0.80, 0.10, 0.20, 0.15, 0xFF060c06);
    b(c, sz, 0.85, 0.18, 0.15, 0.12, 0xFF080e08);

    b(c, sz, 0.06, 0.36, 0.02, 0.015, 0xCCa0ff80);
    b(c, sz, 0.10, 0.36, 0.02, 0.015, 0xCCa0ff80);
    b(c, sz, 0.88, 0.40, 0.02, 0.015, 0xCCa0ff80);
    b(c, sz, 0.92, 0.40, 0.02, 0.015, 0xCCa0ff80);

    b(c, sz, 0, 0.66, 1, 0.06, 0x2040c040);
    b(c, sz, 0, 0.70, 1, 0.08, 0x3030a830);
    b(c, sz, 0, 0.74, 1, 0.06, 0x2060d060);

    b(c, sz, 0, 0.76, 1, 0.24, 0xFF040804);
    b(c, sz, 0, 0.88, 1, 0.12, 0xFF020502);

    b(c, sz, 0.05, 0.75, 0.25, 0.04, 0x1470d070);
    b(c, sz, 0.55, 0.74, 0.30, 0.035, 0x1470d070);
  }
}

// ─────────────────────────────────────────────────────────────────
// FROSTED PEAKS   (Stage 7 — Frosted Peaks)
// Icy mountain pass, blue sky, snow, ice crystals
// ─────────────────────────────────────────────────────────────────

class _FrostedPeaksPainter extends _BgPainter {
  const _FrostedPeaksPainter();

  @override
  void drawBg(Canvas c, Size sz) {
    b(c, sz, 0, 0, 1, 0.55, 0xFF060c18);
    b(c, sz, 0, 0, 1, 0.30, 0xFF081020);
    b(c, sz, 0, 0, 1, 0.15, 0xFF0a1428);

    for (int i = 0; i < 12; i++) {
      final x = (i * 0.087 + 0.03) % 1.0;
      final y = (i * 0.062 + 0.02) % 0.30;
      b(c, sz, x, y, 0.008, 0.010, 0xFFc8d8f0);
    }

    b(c, sz, 0, 0.25, 0.35, 0.45, 0xFF0c1830);
    b(c, sz, 0.25, 0.18, 0.30, 0.52, 0xFF0e1c36);
    b(c, sz, 0.50, 0.22, 0.35, 0.48, 0xFF0c1830);
    b(c, sz, 0.75, 0.15, 0.25, 0.55, 0xFF0e1c36);
    b(c, sz, 0.26, 0.18, 0.12, 0.06, 0xFF8090a8);
    b(c, sz, 0.51, 0.22, 0.12, 0.06, 0xFF8090a8);
    b(c, sz, 0.76, 0.15, 0.10, 0.05, 0xFF8090a8);
    b(c, sz, 0.05, 0.25, 0.10, 0.05, 0xFF8090a8);

    b(c, sz, 0, 0.45, 1, 0.32, 0xFF101828);
    b(c, sz, 0.05, 0.47, 0.90, 0.28, 0xFF141e30);
    b(c, sz, 0.15, 0.48, 0.02, 0.20, 0xFF202c44);
    b(c, sz, 0.35, 0.50, 0.02, 0.18, 0xFF1e2a40);
    b(c, sz, 0.60, 0.47, 0.015, 0.22, 0xFF202c44);
    b(c, sz, 0.80, 0.52, 0.02, 0.16, 0xFF1e2a40);

    b(c, sz, 0.02, 0.60, 0.04, 0.18, 0xFF1c2840);
    b(c, sz, 0.04, 0.56, 0.025, 0.10, 0xFF243050);
    b(c, sz, 0.94, 0.58, 0.04, 0.20, 0xFF1c2840);
    b(c, sz, 0.92, 0.54, 0.025, 0.10, 0xFF243050);
    b(c, sz, 0.03, 0.58, 0.008, 0.06, 0xFF6080a8);
    b(c, sz, 0.95, 0.56, 0.008, 0.06, 0xFF6080a8);

    b(c, sz, 0, 0.76, 1, 0.24, 0xFF141e30);
    b(c, sz, 0, 0.76, 1, 0.04, 0xFF405870);
    b(c, sz, 0, 0.78, 1, 0.02, 0xFF506880);

    b(c, sz, 0.10, 0.76, 0.15, 0.06, 0xFF3a5068);
    b(c, sz, 0.55, 0.76, 0.20, 0.05, 0xFF3a5068);

    b(c, sz, 0.30, 0.55, 0.40, 0.30, 0x0A2050c0);
    b(c, sz, 0, 0.88, 1, 0.12, 0xFF0c1424);
  }
}

// ─────────────────────────────────────────────────────────────────
// BLOODMARSH   (Stage 8 — Bloodmarsh)
// Crimson foggy swamp, dead trees, blood pools, dark mire
// ─────────────────────────────────────────────────────────────────

class _BloodmarshPainter extends _BgPainter {
  const _BloodmarshPainter();

  @override
  void drawBg(Canvas c, Size sz) {
    // Blood-red foggy sky
    b(c, sz, 0, 0, 1, 1, 0xFF080204);
    b(c, sz, 0, 0, 1, 0.40, 0xFF100408);
    b(c, sz, 0, 0.30, 1, 0.25, 0xFF160608);
    b(c, sz, 0, 0.50, 1, 0.20, 0xFF120406);

    // Blood moon
    b(c, sz, 0.44, 0.03, 0.12, 0.12, 0x20cc1010);
    b(c, sz, 0.46, 0.04, 0.08, 0.09, 0x40cc1010);
    b(c, sz, 0.475, 0.05, 0.05, 0.06, 0xCCaa1010); // moon

    // Dead tree silhouettes — LEFT
    b(c, sz, 0.02, 0.20, 0.035, 0.58, 0xFF100406); // trunk
    b(c, sz, 0.01, 0.23, 0.055, 0.025, 0xFF100406); // branch
    b(c, sz, 0.00, 0.30, 0.07, 0.020, 0xFF0e0404);
    b(c, sz, 0.02, 0.40, 0.07, 0.018, 0xFF100406);
    b(c, sz, 0.00, 0.50, 0.05, 0.015, 0xFF0e0404);
    b(c, sz, 0, 0.08, 0.16, 0.16, 0xFF0c0204); // canopy silhouette L
    b(c, sz, 0, 0.18, 0.10, 0.10, 0xFF100406);

    // Dead tree — RIGHT
    b(c, sz, 0.945, 0.22, 0.035, 0.56, 0xFF100406);
    b(c, sz, 0.925, 0.26, 0.06, 0.020, 0xFF0e0404);
    b(c, sz, 0.93, 0.35, 0.07, 0.018, 0xFF100406);
    b(c, sz, 0.93, 0.46, 0.06, 0.015, 0xFF0e0404);
    b(c, sz, 0.84, 0.08, 0.16, 0.16, 0xFF0c0204);
    b(c, sz, 0.90, 0.18, 0.10, 0.10, 0xFF100406);

    // Blood-red fog / mist bands
    b(c, sz, 0, 0.58, 1, 0.06, 0x28881010);
    b(c, sz, 0, 0.62, 1, 0.08, 0x30660808);
    b(c, sz, 0, 0.68, 1, 0.05, 0x20aa1818);

    // Swamp ground
    b(c, sz, 0, 0.72, 1, 0.28, 0xFF0c0204);
    b(c, sz, 0, 0.85, 1, 0.15, 0xFF080104);

    // Blood pools (foreground)
    b(c, sz, 0.05, 0.74, 0.22, 0.10, 0xFF180408); // pool L base
    b(c, sz, 0.07, 0.76, 0.18, 0.07, 0xFF280810); // pool L
    b(c, sz, 0.09, 0.78, 0.12, 0.04, 0xFF400c12); // pool L bright
    b(c, sz, 0.11, 0.80, 0.07, 0.02, 0xCC8b0018); // pool L glow

    b(c, sz, 0.72, 0.74, 0.22, 0.10, 0xFF180408); // pool R base
    b(c, sz, 0.74, 0.76, 0.18, 0.07, 0xFF280810);
    b(c, sz, 0.76, 0.78, 0.12, 0.04, 0xFF400c12);
    b(c, sz, 0.78, 0.80, 0.07, 0.02, 0xCC8b0018);

    // Small centre puddle
    b(c, sz, 0.42, 0.73, 0.16, 0.06, 0xFF200608);
    b(c, sz, 0.44, 0.75, 0.12, 0.04, 0xFF380a10);
    b(c, sz, 0.46, 0.77, 0.08, 0.02, 0xCC660010);

    // Blood ambient glow on ground
    b(c, sz, 0, 0.65, 1, 0.18, 0x14aa0808);
    b(c, sz, 0, 0.90, 1, 0.10, 0xFF050102);
  }
}

// ─────────────────────────────────────────────────────────────────
// SPIDER CITADEL   (Stage 10 — Spider Citadel)
// Dark fortress walls, giant webs, purple venomous glow
// ─────────────────────────────────────────────────────────────────

class _SpiderCitadelPainter extends _BgPainter {
  const _SpiderCitadelPainter();

  @override
  void drawBg(Canvas c, Size sz) {
    // Deep purple-black sky
    b(c, sz, 0, 0, 1, 1, 0xFF040208);
    b(c, sz, 0, 0, 1, 0.30, 0xFF080412);
    b(c, sz, 0, 0.25, 1, 0.30, 0xFF0a0616);
    b(c, sz, 0, 0.50, 1, 0.25, 0xFF0c0818);

    // Sickly moon (venomous purple)
    b(c, sz, 0.44, 0.03, 0.12, 0.12, 0x208833cc);
    b(c, sz, 0.46, 0.04, 0.08, 0.09, 0x408833cc);
    b(c, sz, 0.475, 0.05, 0.05, 0.06, 0xBB9922cc);

    // Back fortress wall (dark stone, purple-tinted)
    b(c, sz, 0.03, 0.15, 0.94, 0.62, 0xFF0e0a18);
    // Stone blocks
    for (int row = 0; row < 6; row++) {
      final offset = row.isOdd ? 0.05 : 0.0;
      for (int col = 0; col < 9; col++) {
        final bx = 0.04 + col * 0.103 + offset;
        final by = 0.17 + row * 0.093;
        if (bx + 0.09 < 0.97) {
          b(c, sz, bx, by, 0.088, 0.082, 0xFF130e1e);
        }
      }
    }

    // Fortress battlements (top of wall)
    for (int i = 0; i < 7; i++) {
      final tx = 0.06 + i * 0.133;
      b(c, sz, tx, 0.10, 0.06, 0.08, 0xFF0e0a18);
    }

    // Left tower
    b(c, sz, 0.00, 0.08, 0.08, 0.70, 0xFF0a0814);
    b(c, sz, 0.005, 0.10, 0.025, 0.65, 0xFF140e22);
    b(c, sz, 0.060, 0.10, 0.018, 0.65, 0xFF120c1e);
    // Tower window (purple glow)
    b(c, sz, 0.02, 0.22, 0.04, 0.08, 0xFF1e0e30);
    b(c, sz, 0.025, 0.23, 0.03, 0.06, 0xAA6622cc);

    // Right tower
    b(c, sz, 0.92, 0.08, 0.08, 0.70, 0xFF0a0814);
    b(c, sz, 0.915, 0.10, 0.025, 0.65, 0xFF140e22);
    b(c, sz, 0.975, 0.10, 0.018, 0.65, 0xFF120c1e);
    b(c, sz, 0.94, 0.22, 0.04, 0.08, 0xFF1e0e30);
    b(c, sz, 0.945, 0.23, 0.03, 0.06, 0xAA6622cc);

    // Giant webs — stretched across upper scene
    // Web strand: top-left to lower-right
    b(c, sz, 0.00, 0.10, 0.30, 0.004, 0x88663399);
    b(c, sz, 0.05, 0.15, 0.28, 0.003, 0x66553388);
    b(c, sz, 0.00, 0.20, 0.22, 0.003, 0x55442277);
    // Web strand: top-right to lower-left
    b(c, sz, 0.70, 0.10, 0.30, 0.004, 0x88663399);
    b(c, sz, 0.67, 0.15, 0.28, 0.003, 0x66553388);
    b(c, sz, 0.78, 0.20, 0.22, 0.003, 0x55442277);
    // Vertical web threads
    b(c, sz, 0.12, 0.08, 0.002, 0.25, 0x66553388);
    b(c, sz, 0.22, 0.10, 0.002, 0.20, 0x55442277);
    b(c, sz, 0.78, 0.08, 0.002, 0.25, 0x66553388);
    b(c, sz, 0.88, 0.12, 0.002, 0.18, 0x55442277);
    // Web hub highlights
    b(c, sz, 0.14, 0.12, 0.015, 0.015, 0xAAaa44ff);
    b(c, sz, 0.85, 0.14, 0.015, 0.015, 0xAAaa44ff);

    // Purple window glow (left)
    b(c, sz, 0.10, 0.20, 0.12, 0.20, 0xFF0e0a1c);
    b(c, sz, 0.115, 0.22, 0.09, 0.15, 0xFF160e28);
    b(c, sz, 0.115, 0.22, 0.09, 0.15, 0x668833cc);
    b(c, sz, 0.06, 0.20, 0.20, 0.26, 0x148833aa);

    // Purple window glow (right)
    b(c, sz, 0.78, 0.20, 0.12, 0.20, 0xFF0e0a1c);
    b(c, sz, 0.795, 0.22, 0.09, 0.15, 0xFF160e28);
    b(c, sz, 0.795, 0.22, 0.09, 0.15, 0x668833cc);
    b(c, sz, 0.74, 0.20, 0.20, 0.26, 0x148833aa);

    // Venom mist on ground
    b(c, sz, 0, 0.66, 1, 0.06, 0x20441166);
    b(c, sz, 0, 0.70, 1, 0.07, 0x28330e55);

    // Dark stone floor
    b(c, sz, 0, 0.76, 1, 0.24, 0xFF080610);
    for (int i = 0; i < 5; i++) {
      b(c, sz, i * 0.2 + 0.01, 0.79, 0.18, 0.065, 0xFF0c0a18);
      b(c, sz, i * 0.2 + 0.01, 0.86, 0.18, 0.065, 0xFF0a0814);
    }
    b(c, sz, 0, 0.91, 1, 0.09, 0xFF040208);
    // Purple ambient glow on floor
    b(c, sz, 0.30, 0.78, 0.40, 0.12, 0x0A661199);
  }
}

// ─────────────────────────────────────────────────────────────────
// HELLFIRE   (Stages 11, 12, 14, 15 — volcanic / infernal)
// Volcanic cavern, lava rivers, fire pillars, scorched rock
// ─────────────────────────────────────────────────────────────────

class _HellFirePainter extends _BgPainter {
  const _HellFirePainter();

  @override
  void drawBg(Canvas c, Size sz) {
    b(c, sz, 0, 0, 1, 1, 0xFF0a0402);
    b(c, sz, 0, 0, 1, 0.20, 0xFF120804);
    b(c, sz, 0.05, 0.02, 0.90, 0.10, 0xFF1a0c06);
    b(c, sz, 0.10, 0.05, 0.80, 0.06, 0xFF220e08);

    b(c, sz, 0, 0.18, 1, 0.55, 0xFF140806);
    b(c, sz, 0.05, 0.20, 0.22, 0.30, 0xFF1a0c08);
    b(c, sz, 0.30, 0.22, 0.20, 0.28, 0xFF180a06);
    b(c, sz, 0.55, 0.18, 0.25, 0.32, 0xFF1c0e0a);
    b(c, sz, 0.80, 0.24, 0.20, 0.26, 0xFF180a06);

    b(c, sz, 0.15, 0.28, 0.02, 0.20, 0xAAff4000);
    b(c, sz, 0.15, 0.28, 0.008, 0.20, 0xCCff8020);
    b(c, sz, 0.45, 0.22, 0.015, 0.25, 0xAAff4000);
    b(c, sz, 0.45, 0.22, 0.006, 0.25, 0xCCff8020);
    b(c, sz, 0.75, 0.30, 0.02, 0.18, 0xAAff4000);
    b(c, sz, 0.75, 0.30, 0.008, 0.18, 0xCCff8020);

    b(c, sz, 0.08, 0.10, 0.06, 0.55, 0xFF240c04);
    b(c, sz, 0.085, 0.0, 0.05, 0.35, 0xBBff4000);
    b(c, sz, 0.092, 0.0, 0.035, 0.28, 0xCCff8020);
    b(c, sz, 0.098, 0.0, 0.022, 0.18, 0xDDffcc40);

    b(c, sz, 0.86, 0.10, 0.06, 0.55, 0xFF240c04);
    b(c, sz, 0.865, 0.0, 0.05, 0.35, 0xBBff4000);
    b(c, sz, 0.872, 0.0, 0.035, 0.28, 0xCCff8020);
    b(c, sz, 0.878, 0.0, 0.022, 0.18, 0xDDffcc40);

    b(c, sz, 0, 0.72, 1, 0.08, 0xFF1a0800);
    b(c, sz, 0, 0.73, 1, 0.05, 0xFF3a1000);
    b(c, sz, 0.05, 0.74, 0.20, 0.03, 0xCCff4000);
    b(c, sz, 0.40, 0.73, 0.25, 0.04, 0xCCff6010);
    b(c, sz, 0.75, 0.74, 0.20, 0.03, 0xCCff4000);
    b(c, sz, 0.20, 0.74, 0.10, 0.02, 0xFFff8030);

    b(c, sz, 0, 0.78, 1, 0.22, 0xFF100602);
    b(c, sz, 0, 0.90, 1, 0.10, 0xFF0a0402);

    b(c, sz, 0, 0.68, 1, 0.18, 0x18ff4000);
    b(c, sz, 0.25, 0.60, 0.50, 0.20, 0x10ff6010);
  }
}

// ─────────────────────────────────────────────────────────────────
// LICH THRONE   (Stages 13, 24 — ancient lich)
// Ice-stone throne room, blue crystal pillars, frost runes
// ─────────────────────────────────────────────────────────────────

class _LichThronePainter extends _BgPainter {
  const _LichThronePainter();

  @override
  void drawBg(Canvas c, Size sz) {
    b(c, sz, 0, 0, 1, 1, 0xFF020408);
    b(c, sz, 0, 0, 1, 0.18, 0xFF080c14);
    for (int i = 0; i < 6; i++) {
      b(c, sz, i * 0.167, 0, 0.155, 0.08, 0xFF0c1020);
      b(c, sz, i * 0.167 + 0.083, 0.06, 0.155, 0.06, 0xFF0a0e1c);
    }

    b(c, sz, 0.04, 0.15, 0.92, 0.62, 0xFF0a0e18);
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 7; col++) {
        final bx = 0.05 + col * 0.13;
        final by = 0.17 + row * 0.12;
        b(c, sz, bx, by, 0.115, 0.10, 0xFF0e1220);
      }
    }
    b(c, sz, 0.18, 0.18, 0.008, 0.40, 0x6020a8e0);
    b(c, sz, 0.44, 0.15, 0.008, 0.45, 0x6020a8e0);
    b(c, sz, 0.70, 0.18, 0.008, 0.40, 0x6020a8e0);

    b(c, sz, 0.00, 0.12, 0.08, 0.65, 0xFF0c1020);
    b(c, sz, 0.008, 0.14, 0.025, 0.60, 0xFF182840);
    b(c, sz, 0.052, 0.14, 0.022, 0.60, 0xFF182840);
    b(c, sz, 0.015, 0.10, 0.012, 0.08, 0xFF3060a0);
    b(c, sz, 0.060, 0.08, 0.010, 0.08, 0xFF3060a0);

    b(c, sz, 0.92, 0.12, 0.08, 0.65, 0xFF0c1020);
    b(c, sz, 0.922, 0.14, 0.025, 0.60, 0xFF182840);
    b(c, sz, 0.968, 0.14, 0.022, 0.60, 0xFF182840);
    b(c, sz, 0.928, 0.10, 0.012, 0.08, 0xFF3060a0);
    b(c, sz, 0.970, 0.08, 0.010, 0.08, 0xFF3060a0);

    b(c, sz, 0.10, 0.18, 0.14, 0.24, 0xFF0c1828);
    b(c, sz, 0.115, 0.20, 0.11, 0.18, 0xFF102030);
    b(c, sz, 0.115, 0.20, 0.11, 0.18, 0x881050d0);
    b(c, sz, 0.07, 0.18, 0.22, 0.30, 0x141060c0);

    b(c, sz, 0.76, 0.18, 0.14, 0.24, 0xFF0c1828);
    b(c, sz, 0.775, 0.20, 0.11, 0.18, 0xFF102030);
    b(c, sz, 0.775, 0.20, 0.11, 0.18, 0x881050d0);
    b(c, sz, 0.71, 0.18, 0.22, 0.30, 0x141060c0);

    b(c, sz, 0.38, 0.28, 0.24, 0.42, 0xFF060a12);
    b(c, sz, 0.36, 0.22, 0.28, 0.08, 0xFF080c18);
    b(c, sz, 0.34, 0.16, 0.10, 0.12, 0xFF0a0e1c);
    b(c, sz, 0.56, 0.16, 0.10, 0.12, 0xFF0a0e1c);
    b(c, sz, 0.44, 0.12, 0.12, 0.14, 0xFF0e1224);
    b(c, sz, 0.47, 0.10, 0.06, 0.04, 0xFF182840);
    b(c, sz, 0.46, 0.36, 0.08, 0.08, 0xFF0c1830);
    b(c, sz, 0.47, 0.37, 0.06, 0.06, 0xFF142040);
    b(c, sz, 0.48, 0.38, 0.04, 0.04, 0x881060d0);

    b(c, sz, 0, 0.77, 1, 0.23, 0xFF080c14);
    for (int i = 0; i < 5; i++) {
      b(c, sz, i * 0.2 + 0.01, 0.79, 0.18, 0.065, 0xFF0c1020);
      b(c, sz, i * 0.2 + 0.01, 0.86, 0.18, 0.065, 0xFF0a0e1c);
    }
    b(c, sz, 0, 0.91, 1, 0.09, 0xFF040608);

    b(c, sz, 0.30, 0.78, 0.40, 0.12, 0x0C1060c0);

    b(c, sz, 0, 0.76, 1, 0.04, 0x1440a8e0);
    b(c, sz, 0.1, 0.77, 0.3, 0.03, 0x0C60c0f0);
    b(c, sz, 0.6, 0.77, 0.3, 0.03, 0x0C60c0f0);
  }
}

// ─────────────────────────────────────────────────────────────────
// VOID EXPANSE   (Stages 16–17, 19–20 — null chamber / void gate)
// Pure void, purple nebula wisps, drifting shards, eerie platforms
// ─────────────────────────────────────────────────────────────────

class _VoidExpansePainter extends _BgPainter {
  const _VoidExpansePainter();

  @override
  void drawBg(Canvas c, Size sz) {
    // True void
    b(c, sz, 0, 0, 1, 1, 0xFF020004);

    // Nebula bands (purple / magenta wisps)
    b(c, sz, 0, 0.05, 1, 0.20, 0xFF08001a);
    b(c, sz, 0.10, 0.08, 0.80, 0.12, 0xFF100028);
    b(c, sz, 0.20, 0.12, 0.60, 0.08, 0xFF180034);
    b(c, sz, 0.30, 0.15, 0.40, 0.06, 0xFF200040);

    // Stars / particles
    for (int i = 0; i < 18; i++) {
      final x = (i * 0.057 + 0.02) % 1.0;
      final y = (i * 0.047 + 0.01) % 0.55;
      final bright = i.isEven ? 0xFFcc88ff : 0xFF8844cc;
      b(c, sz, x, y, 0.005, 0.007, bright);
    }

    // Bright nebula core
    b(c, sz, 0.35, 0.04, 0.30, 0.18, 0x18880088);
    b(c, sz, 0.40, 0.06, 0.20, 0.12, 0x28aa00aa);
    b(c, sz, 0.44, 0.08, 0.12, 0.08, 0x38cc00cc);

    // Drifting void shards (left)
    b(c, sz, 0.04, 0.30, 0.03, 0.12, 0xFF200040);
    b(c, sz, 0.06, 0.28, 0.02, 0.08, 0xFF300060);
    b(c, sz, 0.035, 0.30, 0.006, 0.12, 0x88cc44ff); // shard glow
    // Drifting void shards (right)
    b(c, sz, 0.93, 0.32, 0.03, 0.14, 0xFF200040);
    b(c, sz, 0.91, 0.30, 0.02, 0.10, 0xFF300060);
    b(c, sz, 0.958, 0.32, 0.006, 0.14, 0x88cc44ff);

    // Void platform (centre, floating)
    b(c, sz, 0.20, 0.52, 0.60, 0.06, 0xFF0e0020);
    b(c, sz, 0.22, 0.50, 0.56, 0.03, 0xFF160030);
    b(c, sz, 0.25, 0.49, 0.50, 0.015, 0xFF200044);
    // Platform glow edge
    b(c, sz, 0.22, 0.57, 0.56, 0.008, 0x88aa22ff);

    // Sub-platforms (left/right)
    b(c, sz, 0.00, 0.58, 0.18, 0.04, 0xFF0e0020);
    b(c, sz, 0.82, 0.60, 0.18, 0.04, 0xFF0e0020);

    // Pulsing void energy tendrils below platforms
    b(c, sz, 0.30, 0.56, 0.06, 0.18, 0x40880099);
    b(c, sz, 0.50, 0.56, 0.06, 0.15, 0x40880099);
    b(c, sz, 0.65, 0.56, 0.05, 0.12, 0x30880099);

    // Void abyss floor
    b(c, sz, 0, 0.72, 1, 0.28, 0xFF04000c);
    b(c, sz, 0, 0.85, 1, 0.15, 0xFF020008);
    b(c, sz, 0, 0.90, 1, 0.10, 0xFF010004);

    // Void ripple glow on ground
    b(c, sz, 0.15, 0.72, 0.70, 0.08, 0x20660066);
    b(c, sz, 0.25, 0.75, 0.50, 0.05, 0x18880088);
  }
}

// ─────────────────────────────────────────────────────────────────
// DARK CITADEL   (Stages 21–22, 25 — Throne of Ruin / Dark Lord)
// Bone-laced black fortress, blood-red sky, ultimate darkness
// ─────────────────────────────────────────────────────────────────

class _DarkCitadelPainter extends _BgPainter {
  const _DarkCitadelPainter();

  @override
  void drawBg(Canvas c, Size sz) {
    // Blood-tinged void sky
    b(c, sz, 0, 0, 1, 1, 0xFF050204);
    b(c, sz, 0, 0, 1, 0.25, 0xFF0c0408);
    b(c, sz, 0, 0.20, 1, 0.25, 0xFF100308);
    b(c, sz, 0, 0.40, 1, 0.20, 0xFF0e020a);

    // Blood moon (large, ominous)
    b(c, sz, 0.42, 0.02, 0.16, 0.16, 0x22cc1020);
    b(c, sz, 0.44, 0.03, 0.12, 0.12, 0x44cc1020);
    b(c, sz, 0.46, 0.04, 0.08, 0.09, 0x88aa0e1a); // moon
    b(c, sz, 0.47, 0.045, 0.06, 0.07, 0xCCcc1825);

    // Back citadel wall (black stone)
    b(c, sz, 0.02, 0.14, 0.96, 0.63, 0xFF0c0408);
    // Massive stone blocks
    for (int row = 0; row < 6; row++) {
      final offset = row.isOdd ? 0.06 : 0.0;
      for (int col = 0; col < 8; col++) {
        final bx = 0.03 + col * 0.117 + offset;
        final by = 0.16 + row * 0.098;
        if (bx + 0.10 < 0.98) {
          b(c, sz, bx, by, 0.105, 0.086, 0xFF10060c);
        }
      }
    }

    // Skull motifs embedded in wall (pairs)
    b(c, sz, 0.22, 0.24, 0.06, 0.05, 0xFF1e0c10); // skull L head
    b(c, sz, 0.23, 0.25, 0.015, 0.02, 0xFF080208); // skull L eye L
    b(c, sz, 0.255, 0.25, 0.015, 0.02, 0xFF080208); // skull L eye R
    b(c, sz, 0.72, 0.24, 0.06, 0.05, 0xFF1e0c10); // skull R head
    b(c, sz, 0.73, 0.25, 0.015, 0.02, 0xFF080208);
    b(c, sz, 0.755, 0.25, 0.015, 0.02, 0xFF080208);

    // Battlements on top of wall
    for (int i = 0; i < 8; i++) {
      final tx = 0.04 + i * 0.115;
      b(c, sz, tx, 0.09, 0.055, 0.07, 0xFF0c0408);
    }

    // Massive bone-carved pillars (LEFT)
    b(c, sz, 0.00, 0.08, 0.09, 0.70, 0xFF080206);
    b(c, sz, 0.005, 0.10, 0.025, 0.65, 0xFF140810);
    b(c, sz, 0.065, 0.10, 0.022, 0.65, 0xFF10060c);
    // Bone ring decorations on left pillar
    b(c, sz, 0.005, 0.28, 0.085, 0.012, 0xFF1e1010);
    b(c, sz, 0.005, 0.44, 0.085, 0.012, 0xFF1e1010);
    b(c, sz, 0.005, 0.58, 0.085, 0.012, 0xFF1e1010);

    // Massive bone-carved pillars (RIGHT)
    b(c, sz, 0.91, 0.08, 0.09, 0.70, 0xFF080206);
    b(c, sz, 0.915, 0.10, 0.025, 0.65, 0xFF140810);
    b(c, sz, 0.975, 0.10, 0.022, 0.65, 0xFF10060c);
    b(c, sz, 0.91, 0.28, 0.085, 0.012, 0xFF1e1010);
    b(c, sz, 0.91, 0.44, 0.085, 0.012, 0xFF1e1010);
    b(c, sz, 0.91, 0.58, 0.085, 0.012, 0xFF1e1010);

    // Cursed windows (blood-red glow)
    b(c, sz, 0.10, 0.18, 0.14, 0.24, 0xFF1a0408);
    b(c, sz, 0.115, 0.20, 0.11, 0.18, 0xFF300810);
    b(c, sz, 0.115, 0.20, 0.11, 0.18, 0xAAaa0000);
    b(c, sz, 0.06, 0.18, 0.22, 0.30, 0x14cc0000);

    b(c, sz, 0.76, 0.18, 0.14, 0.24, 0xFF1a0408);
    b(c, sz, 0.775, 0.20, 0.11, 0.18, 0xFF300810);
    b(c, sz, 0.775, 0.20, 0.11, 0.18, 0xAAaa0000);
    b(c, sz, 0.72, 0.18, 0.22, 0.30, 0x14cc0000);

    // Dark Lord's throne (ultimate version)
    b(c, sz, 0.37, 0.26, 0.26, 0.44, 0xFF060104); // throne body
    b(c, sz, 0.35, 0.20, 0.30, 0.08, 0xFF080206); // throne back top
    b(c, sz, 0.33, 0.14, 0.10, 0.12, 0xFF0a0308); // throne spike L
    b(c, sz, 0.57, 0.14, 0.10, 0.12, 0xFF0a0308); // throne spike R
    b(c, sz, 0.43, 0.10, 0.14, 0.16, 0xFF0e0410); // throne center spike
    b(c, sz, 0.46, 0.08, 0.08, 0.04, 0xFF200010); // crown tip
    // Cursed sigil on throne (pulsing red)
    b(c, sz, 0.45, 0.34, 0.10, 0.08, 0xFF400008);
    b(c, sz, 0.46, 0.35, 0.08, 0.06, 0xFF660010);
    b(c, sz, 0.47, 0.36, 0.06, 0.04, 0x88aa0018);
    b(c, sz, 0.485, 0.37, 0.03, 0.02, 0xCCee0020);

    // Blood carpet
    b(c, sz, 0.40, 0.68, 0.20, 0.32, 0xFF1e0004);
    b(c, sz, 0.43, 0.68, 0.14, 0.32, 0xFF2a0008);
    b(c, sz, 0.46, 0.68, 0.08, 0.32, 0xFF3a000e);

    // Black stone floor
    b(c, sz, 0, 0.77, 1, 0.23, 0xFF060104);
    for (int i = 0; i < 5; i++) {
      b(c, sz, i * 0.2 + 0.01, 0.79, 0.18, 0.065, 0xFF0a020a);
      b(c, sz, i * 0.2 + 0.01, 0.86, 0.18, 0.065, 0xFF080208);
    }
    b(c, sz, 0, 0.91, 1, 0.09, 0xFF030002);

    // Blood-red ambient glow on floor
    b(c, sz, 0.30, 0.78, 0.40, 0.14, 0x10cc0010);
    b(c, sz, 0.35, 0.80, 0.30, 0.10, 0x18ee0018);
  }
}
