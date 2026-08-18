import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/pixel_castle.dart';

/// Debug screen: all 10 castle tiers side by side at two sizes, so the
/// progression can be eyeballed in one glance (incl. a 48px thumbnail row).
class CastleGalleryScreen extends StatelessWidget {
  const CastleGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const tint = Color(0xFF9955cc);
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.bgSecondary,
        title: Text('CASTLE GALLERY',
            style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('48px thumbnails (list view)',
              style: AppTheme.pixelHeading(fontSize: 11, color: AppTheme.textMuted)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var t = 1; t <= 10; t++)
                Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    color: const Color(0xFF231F1B),
                    child: PixelCastle(tier: t, guildTint: tint, size: 48),
                  ),
                  Text('T$t', style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
                ]),
            ],
          ),
          const SizedBox(height: 24),
          Text('Large (animated tier 10)',
              style: AppTheme.pixelHeading(fontSize: 11, color: AppTheme.textMuted)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              for (var t = 1; t <= 10; t++)
                Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF231F1B),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: PixelCastle(tier: t, guildTint: tint, size: 128, animate: t == 10),
                  ),
                  const SizedBox(height: 2),
                  Text('Tier $t', style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
                ]),
            ],
          ),
          const SizedBox(height: 24),
          Text('Per-guild tint variation (tier 6)',
              style: AppTheme.pixelHeading(fontSize: 11, color: AppTheme.textMuted)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final id in ['alpha', 'bravo', 'charlie', 'delta', 'echo', 'foxtrot'])
                Container(
                  color: const Color(0xFF231F1B),
                  child: PixelCastle(
                      tier: 6, guildTint: PixelCastle.tintForGuildId(id), size: 72),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
