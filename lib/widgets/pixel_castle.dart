import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PixelCastle — shows the illustrated castle scene for a guild-castle tier
// (1..10). Previously a CustomPainter; now backed by per-tier art in
// assets/castles/castle_1.jpg … castle_10.jpg (hamlet → citadel), so upgrading
// reads as the settlement growing. The original API (tier / guildTint / size /
// animate) is preserved so every call site is unchanged — guildTint tints the
// frame so two same-tier guilds still differ; `animate` is currently unused.
// ─────────────────────────────────────────────────────────────────────────────

class PixelCastle extends StatelessWidget {
  const PixelCastle({
    super.key,
    required this.tier,
    required this.guildTint,
    this.size = 96,
    this.animate = false,
  });

  final int tier;        // 1..10
  final Color guildTint; // frame/banner colour (derive deterministically per guild)
  final double size;
  final bool animate;    // reserved (tier-10 flourish) — no-op for now

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
  Widget build(BuildContext context) {
    final t = tier.clamp(1, 10);
    final radius = size * 0.06;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF1a1816),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: guildTint.withValues(alpha: 0.55), width: 1.5),
        image: DecorationImage(
          image: AssetImage('assets/castles/castle_$t.jpg'),
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}
