import 'package:flutter/material.dart';

/// Returns a background painter for the given enemy id.
CustomPainter battleBackgroundFor(String enemyId) {
  switch (enemyId) {
    case 'crypt_skeleton':
    case 'stone_golem':
      return const _CryptPainter();
    case 'shade_warrior':
    case 'lich_apprentice':
      return const _ShadowRealmPainter();
    case 'abyssal_beast':
    case 'blood_ogre':
    case 'spider_queen':
      return const _AbyssCavePainter();
    case 'forest_wraith':
      return const _DarkwoodPainter();
    case 'frost_drake':
      return const _FrostedPeaksPainter();
    case 'infernal_knight':
    case 'dragon_whelp':
      return const _HellFirePainter();
    case 'ancient_lich':
      return const _LichThronePainter();
    default:
      return const _DarkThronePainter();
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

  // Draw a rectangle at fractional coordinates [0–1].
  void b(Canvas c, Size sz, double x, double y, double w, double h, int rgba) {
    c.drawRect(
      Rect.fromLTWH(
          x * sz.width, y * sz.height, w * sz.width, h * sz.height),
      Paint()..color = Color(rgba),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// CRYPT   (Crypt Skeleton)
// Dark stone dungeon with torches, brick walls, skull
// ─────────────────────────────────────────────────────────────────

class _CryptPainter extends _BgPainter {
  const _CryptPainter();

  @override
  void drawBg(Canvas c, Size sz) {
    // Sky/void above arch
    b(c, sz, 0, 0, 1, 0.12, 0xFF04040c);

    // Ceiling stone
    b(c, sz, 0, 0.08, 1, 0.12, 0xFF18182a);
    for (int i = 0; i < 8; i++) {
      b(c, sz, i * 0.125, 0.08, 0.11, 0.05, 0xFF222238);
      b(c, sz, i * 0.125 + 0.0625, 0.12, 0.11, 0.04, 0xFF1c1c30);
    }

    // Back wall (dark stone)
    b(c, sz, 0.07, 0.16, 0.86, 0.62, 0xFF1c1c2a);

    // Brick rows on back wall
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

    // Side pillars
    b(c, sz, 0, 0.08, 0.07, 0.7, 0xFF10101e);
    b(c, sz, 0.93, 0.08, 0.07, 0.7, 0xFF10101e);
    b(c, sz, 0.055, 0.1, 0.018, 0.65, 0xFF1e1e30); // pillar edge L
    b(c, sz, 0.927, 0.1, 0.018, 0.65, 0xFF1e1e30); // pillar edge R

    // TORCH LEFT — mount + flame
    b(c, sz, 0.115, 0.26, 0.04, 0.09, 0xFF3a2010); // bracket
    b(c, sz, 0.11, 0.17, 0.05, 0.10, 0xBBff6600); // outer flame
    b(c, sz, 0.12, 0.15, 0.03, 0.08, 0xDDffaa00); // mid flame
    b(c, sz, 0.128, 0.13, 0.016, 0.05, 0xFFffee80); // tip
    b(c, sz, 0.07, 0.12, 0.18, 0.42, 0x10ff8800); // glow on wall

    // TORCH RIGHT — mount + flame
    b(c, sz, 0.845, 0.26, 0.04, 0.09, 0xFF3a2010);
    b(c, sz, 0.84, 0.17, 0.05, 0.10, 0xBBff6600);
    b(c, sz, 0.85, 0.15, 0.03, 0.08, 0xDDffaa00);
    b(c, sz, 0.856, 0.13, 0.016, 0.05, 0xFFffee80);
    b(c, sz, 0.75, 0.12, 0.18, 0.42, 0x10ff8800); // glow on wall

    // Skull on back wall (center decoration)
    b(c, sz, 0.44, 0.27, 0.12, 0.10, 0xFF8a7860); // skull head
    b(c, sz, 0.45, 0.28, 0.03, 0.04, 0xFF2a1810); // eye L
    b(c, sz, 0.52, 0.28, 0.03, 0.04, 0xFF2a1810); // eye R
    b(c, sz, 0.46, 0.35, 0.08, 0.015, 0xFF6a5040); // teeth

    // Floor
    b(c, sz, 0, 0.78, 1, 0.22, 0xFF0c0c18);
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 3; j++) {
        b(c, sz, i * 0.2 + 0.01, 0.80 + j * 0.065,
            0.18, 0.055, 0xFF181828);
      }
    }
    b(c, sz, 0, 0.92, 1, 0.08, 0xFF080810); // floor shadow
  }
}

// ─────────────────────────────────────────────────────────────────
// SHADOW REALM   (Shade Warrior)
// Dark purple sky, twisted trees, misty ground, glowing eyes
// ─────────────────────────────────────────────────────────────────

class _ShadowRealmPainter extends _BgPainter {
  const _ShadowRealmPainter();

  @override
  void drawBg(Canvas c, Size sz) {
    // Sky gradient bands
    b(c, sz, 0, 0, 1, 0.25, 0xFF060614);
    b(c, sz, 0, 0.20, 1, 0.20, 0xFF0e0828);
    b(c, sz, 0, 0.35, 1, 0.20, 0xFF160a3a);
    b(c, sz, 0, 0.50, 1, 0.25, 0xFF1a0c3e);
    b(c, sz, 0, 0.70, 1, 0.30, 0xFF0e0820);

    // Moon glow
    b(c, sz, 0.44, 0.04, 0.12, 0.12, 0x20e8e8ff);
    b(c, sz, 0.46, 0.05, 0.08, 0.09, 0x40e8e8ff);
    b(c, sz, 0.475, 0.06, 0.05, 0.06, 0xAAc8c8ff); // moon

    // Left tree trunk + branches
    b(c, sz, 0.02, 0.25, 0.04, 0.5, 0xFF100820); // trunk
    b(c, sz, 0.015, 0.28, 0.055, 0.04, 0xFF100820); // branch 1
    b(c, sz, 0.0, 0.22, 0.08, 0.03, 0xFF0e0618); // branch 2
    b(c, sz, 0.025, 0.34, 0.07, 0.03, 0xFF100820); // branch 3
    b(c, sz, 0.0, 0.42, 0.06, 0.025, 0xFF0e0618); // branch 4
    // Tree canopy silhouette
    b(c, sz, 0, 0.1, 0.18, 0.18, 0xFF0a0618);
    b(c, sz, 0, 0.22, 0.12, 0.12, 0xFF0c0820);

    // Right tree
    b(c, sz, 0.94, 0.25, 0.04, 0.5, 0xFF100820);
    b(c, sz, 0.925, 0.30, 0.06, 0.035, 0xFF100820);
    b(c, sz, 0.92, 0.24, 0.08, 0.03, 0xFF0e0618);
    b(c, sz, 0.93, 0.38, 0.07, 0.025, 0xFF100820);
    b(c, sz, 0.82, 0.1, 0.18, 0.18, 0xFF0a0618);
    b(c, sz, 0.88, 0.22, 0.12, 0.12, 0xFF0c0820);

    // Glowing eyes in left tree (pair)
    b(c, sz, 0.035, 0.32, 0.018, 0.014, 0xCCffd040);
    b(c, sz, 0.065, 0.32, 0.018, 0.014, 0xCCffd040);

    // Glowing eyes in right tree
    b(c, sz, 0.915, 0.35, 0.018, 0.014, 0xCCffd040);
    b(c, sz, 0.947, 0.35, 0.018, 0.014, 0xCCffd040);

    // Ground mist layers
    b(c, sz, 0, 0.68, 1, 0.06, 0x228080c0); // mist band 1
    b(c, sz, 0, 0.72, 1, 0.08, 0x304060a0); // mist band 2
    b(c, sz, 0, 0.76, 1, 0.06, 0x20c0c0ff); // mist band 3

    // Ground
    b(c, sz, 0, 0.78, 1, 0.22, 0xFF0a0818);
    b(c, sz, 0, 0.90, 1, 0.10, 0xFF06060e);

    // Wispy ground mist details
    b(c, sz, 0.1, 0.77, 0.2, 0.04, 0x18c0c0ff);
    b(c, sz, 0.5, 0.76, 0.3, 0.035, 0x18c0c0ff);
    b(c, sz, 0.7, 0.79, 0.15, 0.03, 0x14c0c0ff);
  }
}

// ─────────────────────────────────────────────────────────────────
// ABYSSAL CAVE   (Abyssal Beast)
// Dark cave, stalactites, glowing green pools, rocky floor
// ─────────────────────────────────────────────────────────────────

class _AbyssCavePainter extends _BgPainter {
  const _AbyssCavePainter();

  @override
  void drawBg(Canvas c, Size sz) {
    // Cave void
    b(c, sz, 0, 0, 1, 1, 0xFF040808);

    // Cave ceiling
    b(c, sz, 0, 0, 1, 0.22, 0xFF0c1210);

    // Stalactites (hanging from ceiling)
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

    // Back cave wall
    b(c, sz, 0, 0.20, 1, 0.55, 0xFF0a1210);

    // Rock layers
    b(c, sz, 0, 0.30, 1, 0.08, 0xFF0e1814);
    b(c, sz, 0, 0.45, 1, 0.10, 0xFF0c1612);

    // Green glow from below
    b(c, sz, 0, 0.6, 1, 0.4, 0xFF060e0a);
    b(c, sz, 0.05, 0.72, 0.25, 0.15, 0xFF081408); // pool L base
    b(c, sz, 0.07, 0.74, 0.21, 0.12, 0xFF0c200c); // pool L
    b(c, sz, 0.10, 0.76, 0.15, 0.09, 0xFF103010); // pool L bright
    b(c, sz, 0.12, 0.78, 0.10, 0.06, 0xFF1a4a1a); // pool L glow
    b(c, sz, 0.14, 0.80, 0.06, 0.03, 0xFF286028); // pool L center

    b(c, sz, 0.70, 0.72, 0.25, 0.15, 0xFF081408); // pool R base
    b(c, sz, 0.72, 0.74, 0.21, 0.12, 0xFF0c200c);
    b(c, sz, 0.75, 0.76, 0.15, 0.09, 0xFF103010);
    b(c, sz, 0.77, 0.78, 0.10, 0.06, 0xFF1a4a1a);
    b(c, sz, 0.80, 0.80, 0.06, 0.03, 0xFF286028);

    // Pool green glow on ceiling/walls (ambient)
    b(c, sz, 0, 0.55, 0.35, 0.3, 0x0E10a010);
    b(c, sz, 0.65, 0.55, 0.35, 0.3, 0x0E10a010);

    // Rocky floor
    b(c, sz, 0, 0.75, 1, 0.25, 0xFF080e08);
    // Rock formations
    b(c, sz, 0.3, 0.70, 0.12, 0.10, 0xFF0e1810);
    b(c, sz, 0.55, 0.72, 0.09, 0.08, 0xFF0c1610);
    b(c, sz, 0, 0.78, 0.08, 0.22, 0xFF0a1208); // left rock wall
    b(c, sz, 0.92, 0.78, 0.08, 0.22, 0xFF0a1208); // right rock wall

    // Floor shadow
    b(c, sz, 0, 0.90, 1, 0.10, 0xFF040808);
  }
}

// ─────────────────────────────────────────────────────────────────
// DARK THRONE   (Dark Lord)
// Castle throne room, red light, pillars, throne silhouette
// ─────────────────────────────────────────────────────────────────

class _DarkThronePainter extends _BgPainter {
  const _DarkThronePainter();

  @override
  void drawBg(Canvas c, Size sz) {
    // Base void
    b(c, sz, 0, 0, 1, 1, 0xFF060408);

    // High arched ceiling
    b(c, sz, 0, 0, 1, 0.18, 0xFF0c080e);

    // Ceiling stone blocks
    for (int i = 0; i < 6; i++) {
      b(c, sz, i * 0.167, 0, 0.155, 0.10, 0xFF100c12);
      b(c, sz, i * 0.167 + 0.083, 0.08, 0.155, 0.10, 0xFF0e0a10);
    }

    // Back wall (dark stone)
    b(c, sz, 0.05, 0.15, 0.90, 0.62, 0xFF0e0a10);

    // Stone blocks on back wall
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

    // Red stained glass windows (LEFT)
    b(c, sz, 0.10, 0.18, 0.12, 0.22, 0xFF300810); // window frame
    b(c, sz, 0.115, 0.20, 0.09, 0.17, 0xFF601020); // glass
    b(c, sz, 0.115, 0.20, 0.09, 0.17, 0xAA8b0000); // tint
    b(c, sz, 0.07, 0.18, 0.2, 0.28, 0x18cc0000); // red glow spill L

    // Red stained glass windows (RIGHT)
    b(c, sz, 0.78, 0.18, 0.12, 0.22, 0xFF300810);
    b(c, sz, 0.795, 0.20, 0.09, 0.17, 0xFF601020);
    b(c, sz, 0.795, 0.20, 0.09, 0.17, 0xAA8b0000);
    b(c, sz, 0.73, 0.18, 0.2, 0.28, 0x18cc0000); // red glow spill R

    // Stone pillars (LEFT)
    b(c, sz, 0.00, 0.12, 0.07, 0.66, 0xFF0a080c);
    b(c, sz, 0.005, 0.14, 0.02, 0.62, 0xFF14101a);
    b(c, sz, 0.055, 0.14, 0.02, 0.62, 0xFF100c16);

    // Stone pillars (RIGHT)
    b(c, sz, 0.93, 0.12, 0.07, 0.66, 0xFF0a080c);
    b(c, sz, 0.925, 0.14, 0.02, 0.62, 0xFF14101a);
    b(c, sz, 0.975, 0.14, 0.02, 0.62, 0xFF100c16);

    // Throne silhouette (back-center)
    b(c, sz, 0.38, 0.28, 0.24, 0.40, 0xFF08060a); // throne body
    b(c, sz, 0.36, 0.24, 0.28, 0.06, 0xFF0a080c); // throne back top
    b(c, sz, 0.35, 0.20, 0.08, 0.10, 0xFF0a080c); // throne spike L
    b(c, sz, 0.57, 0.20, 0.08, 0.10, 0xFF0a080c); // throne spike R
    b(c, sz, 0.44, 0.18, 0.12, 0.12, 0xFF0e0c10); // throne center spike
    b(c, sz, 0.47, 0.17, 0.06, 0.04, 0xFF1a0010); // crown tip
    // Glowing sigil on throne
    b(c, sz, 0.46, 0.35, 0.08, 0.06, 0xFF3a0010);
    b(c, sz, 0.47, 0.36, 0.06, 0.04, 0xFF660020);
    b(c, sz, 0.485, 0.37, 0.03, 0.02, 0xAA8b0000);

    // Red carpet
    b(c, sz, 0.40, 0.68, 0.20, 0.32, 0xFF1a0008);
    b(c, sz, 0.43, 0.68, 0.14, 0.32, 0xFF250010);
    b(c, sz, 0.46, 0.68, 0.08, 0.32, 0xFF320018);

    // Floor
    b(c, sz, 0, 0.77, 1, 0.23, 0xFF080608);
    // Floor tiles
    for (int i = 0; i < 5; i++) {
      b(c, sz, i * 0.2 + 0.01, 0.79, 0.18, 0.065, 0xFF0c0a0e);
      b(c, sz, i * 0.2 + 0.01, 0.86, 0.18, 0.065, 0xFF0a0810);
    }
    b(c, sz, 0, 0.91, 1, 0.09, 0xFF040308); // floor shadow

    // Ambient red glow on floor near carpet
    b(c, sz, 0.35, 0.78, 0.30, 0.15, 0x0Acc0020);
  }
}

// ─────────────────────────────────────────────────────────────────
// DARKWOOD   (Forest Wraith)
// Night forest, twisted trees, pale moon, green mist ground
// ─────────────────────────────────────────────────────────────────

class _DarkwoodPainter extends _BgPainter {
  const _DarkwoodPainter();

  @override
  void drawBg(Canvas c, Size sz) {
    b(c, sz, 0, 0, 1, 1, 0xFF020808);

    // Night sky bands
    b(c, sz, 0, 0, 1, 0.45, 0xFF040c04);
    b(c, sz, 0, 0.40, 1, 0.20, 0xFF060e06);

    // Moon glow (pale green-white)
    b(c, sz, 0.43, 0.04, 0.14, 0.14, 0x1880ff80);
    b(c, sz, 0.45, 0.05, 0.10, 0.10, 0x3060e060);
    b(c, sz, 0.47, 0.06, 0.06, 0.07, 0xFF90c890); // moon

    // Far tree line (silhouettes)
    b(c, sz, 0, 0.30, 0.20, 0.40, 0xFF040c04);
    b(c, sz, 0.15, 0.25, 0.18, 0.45, 0xFF050d05);
    b(c, sz, 0.65, 0.28, 0.20, 0.42, 0xFF040c04);
    b(c, sz, 0.80, 0.22, 0.20, 0.48, 0xFF050d05);

    // Left foreground tree trunk
    b(c, sz, 0.03, 0.20, 0.05, 0.60, 0xFF080e08);
    b(c, sz, 0.025, 0.22, 0.06, 0.04, 0xFF080e08);
    b(c, sz, 0.01, 0.28, 0.08, 0.03, 0xFF060c06);
    b(c, sz, 0.03, 0.38, 0.08, 0.03, 0xFF080e08);
    b(c, sz, 0.00, 0.48, 0.06, 0.025, 0xFF060c06);
    b(c, sz, 0.00, 0.10, 0.20, 0.15, 0xFF060c06); // canopy L
    b(c, sz, 0.00, 0.18, 0.15, 0.12, 0xFF080e08);

    // Right foreground tree
    b(c, sz, 0.92, 0.22, 0.05, 0.58, 0xFF080e08);
    b(c, sz, 0.915, 0.24, 0.06, 0.04, 0xFF080e08);
    b(c, sz, 0.91, 0.32, 0.07, 0.03, 0xFF060c06);
    b(c, sz, 0.93, 0.44, 0.07, 0.025, 0xFF080e08);
    b(c, sz, 0.80, 0.10, 0.20, 0.15, 0xFF060c06); // canopy R
    b(c, sz, 0.85, 0.18, 0.15, 0.12, 0xFF080e08);

    // Glowing eyes in trees
    b(c, sz, 0.06, 0.36, 0.02, 0.015, 0xCCa0ff80);
    b(c, sz, 0.10, 0.36, 0.02, 0.015, 0xCCa0ff80);
    b(c, sz, 0.88, 0.40, 0.02, 0.015, 0xCCa0ff80);
    b(c, sz, 0.92, 0.40, 0.02, 0.015, 0xCCa0ff80);

    // Green ground mist
    b(c, sz, 0, 0.66, 1, 0.06, 0x2040c040);
    b(c, sz, 0, 0.70, 1, 0.08, 0x3030a830);
    b(c, sz, 0, 0.74, 1, 0.06, 0x2060d060);

    // Dark ground
    b(c, sz, 0, 0.76, 1, 0.24, 0xFF040804);
    b(c, sz, 0, 0.88, 1, 0.12, 0xFF020502);

    // Ground mist wisps
    b(c, sz, 0.05, 0.75, 0.25, 0.04, 0x1470d070);
    b(c, sz, 0.55, 0.74, 0.30, 0.035, 0x1470d070);
  }
}

// ─────────────────────────────────────────────────────────────────
// FROSTED PEAKS   (Frost Drake)
// Icy mountain pass, blue sky, snow, ice crystals
// ─────────────────────────────────────────────────────────────────

class _FrostedPeaksPainter extends _BgPainter {
  const _FrostedPeaksPainter();

  @override
  void drawBg(Canvas c, Size sz) {
    // Sky
    b(c, sz, 0, 0, 1, 0.55, 0xFF060c18);
    b(c, sz, 0, 0, 1, 0.30, 0xFF081020);
    b(c, sz, 0, 0, 1, 0.15, 0xFF0a1428);

    // Stars
    for (int i = 0; i < 12; i++) {
      final x = (i * 0.087 + 0.03) % 1.0;
      final y = (i * 0.062 + 0.02) % 0.30;
      b(c, sz, x, y, 0.008, 0.010, 0xFFc8d8f0);
    }

    // Distant mountain silhouettes
    b(c, sz, 0, 0.25, 0.35, 0.45, 0xFF0c1830);
    b(c, sz, 0.25, 0.18, 0.30, 0.52, 0xFF0e1c36);
    b(c, sz, 0.50, 0.22, 0.35, 0.48, 0xFF0c1830);
    b(c, sz, 0.75, 0.15, 0.25, 0.55, 0xFF0e1c36);
    // Snow caps on far mountains
    b(c, sz, 0.26, 0.18, 0.12, 0.06, 0xFF8090a8);
    b(c, sz, 0.51, 0.22, 0.12, 0.06, 0xFF8090a8);
    b(c, sz, 0.76, 0.15, 0.10, 0.05, 0xFF8090a8);
    b(c, sz, 0.05, 0.25, 0.10, 0.05, 0xFF8090a8);

    // Icy back wall / cliff face
    b(c, sz, 0, 0.45, 1, 0.32, 0xFF101828);
    b(c, sz, 0.05, 0.47, 0.90, 0.28, 0xFF141e30);
    // Ice vein patterns
    b(c, sz, 0.15, 0.48, 0.02, 0.20, 0xFF202c44);
    b(c, sz, 0.35, 0.50, 0.02, 0.18, 0xFF1e2a40);
    b(c, sz, 0.60, 0.47, 0.015, 0.22, 0xFF202c44);
    b(c, sz, 0.80, 0.52, 0.02, 0.16, 0xFF1e2a40);

    // Ice crystals (foreground)
    b(c, sz, 0.02, 0.60, 0.04, 0.18, 0xFF1c2840);
    b(c, sz, 0.04, 0.56, 0.025, 0.10, 0xFF243050);
    b(c, sz, 0.94, 0.58, 0.04, 0.20, 0xFF1c2840);
    b(c, sz, 0.92, 0.54, 0.025, 0.10, 0xFF243050);
    // Crystal highlights
    b(c, sz, 0.03, 0.58, 0.008, 0.06, 0xFF6080a8);
    b(c, sz, 0.95, 0.56, 0.008, 0.06, 0xFF6080a8);

    // Snow on ground
    b(c, sz, 0, 0.76, 1, 0.24, 0xFF141e30);
    b(c, sz, 0, 0.76, 1, 0.04, 0xFF405870); // snow surface
    b(c, sz, 0, 0.78, 1, 0.02, 0xFF506880); // bright snow edge

    // Snow drifts
    b(c, sz, 0.10, 0.76, 0.15, 0.06, 0xFF3a5068);
    b(c, sz, 0.55, 0.76, 0.20, 0.05, 0xFF3a5068);

    // Ice glow (ambient blue)
    b(c, sz, 0.30, 0.55, 0.40, 0.30, 0x0A2050c0);
    b(c, sz, 0, 0.88, 1, 0.12, 0xFF0c1424);
  }
}

// ─────────────────────────────────────────────────────────────────
// HELLFIRE   (Infernal Knight / Dragon Whelp)
// Volcanic cavern, lava rivers, fire pillars, scorched rock
// ─────────────────────────────────────────────────────────────────

class _HellFirePainter extends _BgPainter {
  const _HellFirePainter();

  @override
  void drawBg(Canvas c, Size sz) {
    // Cave void / smoke-filled sky
    b(c, sz, 0, 0, 1, 1, 0xFF0a0402);

    // Smoke / heat haze ceiling
    b(c, sz, 0, 0, 1, 0.20, 0xFF120804);
    b(c, sz, 0.05, 0.02, 0.90, 0.10, 0xFF1a0c06);
    b(c, sz, 0.10, 0.05, 0.80, 0.06, 0xFF220e08);

    // Back rock wall
    b(c, sz, 0, 0.18, 1, 0.55, 0xFF140806);

    // Rock wall texture
    b(c, sz, 0.05, 0.20, 0.22, 0.30, 0xFF1a0c08);
    b(c, sz, 0.30, 0.22, 0.20, 0.28, 0xFF180a06);
    b(c, sz, 0.55, 0.18, 0.25, 0.32, 0xFF1c0e0a);
    b(c, sz, 0.80, 0.24, 0.20, 0.26, 0xFF180a06);

    // Glowing cracks in rock (lava seeping through)
    b(c, sz, 0.15, 0.28, 0.02, 0.20, 0xAAff4000);
    b(c, sz, 0.15, 0.28, 0.008, 0.20, 0xCCff8020);
    b(c, sz, 0.45, 0.22, 0.015, 0.25, 0xAAff4000);
    b(c, sz, 0.45, 0.22, 0.006, 0.25, 0xCCff8020);
    b(c, sz, 0.75, 0.30, 0.02, 0.18, 0xAAff4000);
    b(c, sz, 0.75, 0.30, 0.008, 0.18, 0xCCff8020);

    // Fire pillars (left & right)
    b(c, sz, 0.08, 0.10, 0.06, 0.55, 0xFF240c04); // pillar base
    b(c, sz, 0.085, 0.0, 0.05, 0.35, 0xBBff4000); // flame outer
    b(c, sz, 0.092, 0.0, 0.035, 0.28, 0xCCff8020); // flame mid
    b(c, sz, 0.098, 0.0, 0.022, 0.18, 0xDDffcc40); // flame core

    b(c, sz, 0.86, 0.10, 0.06, 0.55, 0xFF240c04);
    b(c, sz, 0.865, 0.0, 0.05, 0.35, 0xBBff4000);
    b(c, sz, 0.872, 0.0, 0.035, 0.28, 0xCCff8020);
    b(c, sz, 0.878, 0.0, 0.022, 0.18, 0xDDffcc40);

    // Lava river (foreground)
    b(c, sz, 0, 0.72, 1, 0.08, 0xFF1a0800); // lava base
    b(c, sz, 0, 0.73, 1, 0.05, 0xFF3a1000); // lava hot
    b(c, sz, 0.05, 0.74, 0.20, 0.03, 0xCCff4000); // lava glow L
    b(c, sz, 0.40, 0.73, 0.25, 0.04, 0xCCff6010); // lava glow C
    b(c, sz, 0.75, 0.74, 0.20, 0.03, 0xCCff4000); // lava glow R
    b(c, sz, 0.20, 0.74, 0.10, 0.02, 0xFFff8030); // bright river strand

    // Scorched floor
    b(c, sz, 0, 0.78, 1, 0.22, 0xFF100602);
    b(c, sz, 0, 0.90, 1, 0.10, 0xFF0a0402); // floor shadow

    // Lava ambient glow on floor
    b(c, sz, 0, 0.68, 1, 0.18, 0x18ff4000);
    b(c, sz, 0.25, 0.60, 0.50, 0.20, 0x10ff6010);
  }
}

// ─────────────────────────────────────────────────────────────────
// LICH THRONE   (Ancient Lich)
// Vast ice-stone throne room, blue crystal pillars, frost runes
// ─────────────────────────────────────────────────────────────────

class _LichThronePainter extends _BgPainter {
  const _LichThronePainter();

  @override
  void drawBg(Canvas c, Size sz) {
    // Void background
    b(c, sz, 0, 0, 1, 1, 0xFF020408);

    // Ceiling
    b(c, sz, 0, 0, 1, 0.18, 0xFF080c14);
    for (int i = 0; i < 6; i++) {
      b(c, sz, i * 0.167, 0, 0.155, 0.08, 0xFF0c1020);
      b(c, sz, i * 0.167 + 0.083, 0.06, 0.155, 0.06, 0xFF0a0e1c);
    }

    // Back wall (ancient stone with ice veins)
    b(c, sz, 0.04, 0.15, 0.92, 0.62, 0xFF0a0e18);
    // Ice vein grid
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 7; col++) {
        final bx = 0.05 + col * 0.13;
        final by = 0.17 + row * 0.12;
        b(c, sz, bx, by, 0.115, 0.10, 0xFF0e1220);
      }
    }
    // Blue glow veins
    b(c, sz, 0.18, 0.18, 0.008, 0.40, 0x6020a8e0);
    b(c, sz, 0.44, 0.15, 0.008, 0.45, 0x6020a8e0);
    b(c, sz, 0.70, 0.18, 0.008, 0.40, 0x6020a8e0);

    // Ice crystal pillars (LEFT)
    b(c, sz, 0.00, 0.12, 0.08, 0.65, 0xFF0c1020);
    b(c, sz, 0.008, 0.14, 0.025, 0.60, 0xFF182840);
    b(c, sz, 0.052, 0.14, 0.022, 0.60, 0xFF182840);
    b(c, sz, 0.015, 0.10, 0.012, 0.08, 0xFF3060a0); // crystal tip
    b(c, sz, 0.060, 0.08, 0.010, 0.08, 0xFF3060a0);

    // Ice crystal pillars (RIGHT)
    b(c, sz, 0.92, 0.12, 0.08, 0.65, 0xFF0c1020);
    b(c, sz, 0.922, 0.14, 0.025, 0.60, 0xFF182840);
    b(c, sz, 0.968, 0.14, 0.022, 0.60, 0xFF182840);
    b(c, sz, 0.928, 0.10, 0.012, 0.08, 0xFF3060a0);
    b(c, sz, 0.970, 0.08, 0.010, 0.08, 0xFF3060a0);

    // Frost rune windows (left)
    b(c, sz, 0.10, 0.18, 0.14, 0.24, 0xFF0c1828); // window frame
    b(c, sz, 0.115, 0.20, 0.11, 0.18, 0xFF102030); // glass
    b(c, sz, 0.115, 0.20, 0.11, 0.18, 0x881050d0); // blue tint
    b(c, sz, 0.07, 0.18, 0.22, 0.30, 0x141060c0); // glow spill L

    // Frost rune windows (right)
    b(c, sz, 0.76, 0.18, 0.14, 0.24, 0xFF0c1828);
    b(c, sz, 0.775, 0.20, 0.11, 0.18, 0xFF102030);
    b(c, sz, 0.775, 0.20, 0.11, 0.18, 0x881050d0);
    b(c, sz, 0.71, 0.18, 0.22, 0.30, 0x141060c0); // glow spill R

    // Lich throne silhouette (back-center)
    b(c, sz, 0.38, 0.28, 0.24, 0.42, 0xFF060a12); // throne body
    b(c, sz, 0.36, 0.22, 0.28, 0.08, 0xFF080c18); // throne back top
    b(c, sz, 0.34, 0.16, 0.10, 0.12, 0xFF0a0e1c); // throne spike L
    b(c, sz, 0.56, 0.16, 0.10, 0.12, 0xFF0a0e1c); // throne spike R
    b(c, sz, 0.44, 0.12, 0.12, 0.14, 0xFF0e1224); // throne center spike
    b(c, sz, 0.47, 0.10, 0.06, 0.04, 0xFF182840); // crown-spike tip
    // Throne ice rune glow
    b(c, sz, 0.46, 0.36, 0.08, 0.08, 0xFF0c1830);
    b(c, sz, 0.47, 0.37, 0.06, 0.06, 0xFF142040);
    b(c, sz, 0.48, 0.38, 0.04, 0.04, 0x881060d0);

    // Floor (ancient stone with frost)
    b(c, sz, 0, 0.77, 1, 0.23, 0xFF080c14);
    for (int i = 0; i < 5; i++) {
      b(c, sz, i * 0.2 + 0.01, 0.79, 0.18, 0.065, 0xFF0c1020);
      b(c, sz, i * 0.2 + 0.01, 0.86, 0.18, 0.065, 0xFF0a0e1c);
    }
    b(c, sz, 0, 0.91, 1, 0.09, 0xFF040608);

    // Blue ambient glow on floor
    b(c, sz, 0.30, 0.78, 0.40, 0.12, 0x0C1060c0);

    // Frost mist on floor
    b(c, sz, 0, 0.76, 1, 0.04, 0x1440a8e0);
    b(c, sz, 0.1, 0.77, 0.3, 0.03, 0x0C60c0f0);
    b(c, sz, 0.6, 0.77, 0.3, 0.03, 0x0C60c0f0);
  }
}
