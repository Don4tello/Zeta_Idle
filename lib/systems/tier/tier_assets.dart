import 'tier_config.dart';

/// Maps a tier number to its existing UI badge asset (`assets/images/tier_N.png`,
/// which already ship for tiers 1–10). Tier 0 falls back to tier 1's art.
///
/// Usage: `Image.asset(TierAssets.badgePath(state.activeTier))`.
class TierAssets {
  const TierAssets._();

  static const String _dir = 'assets/images';

  /// Path to the badge image for [tier], clamped into the valid asset range.
  static String badgePath(int tier) {
    final t = tier.clamp(1, TierConfig.maxTier);
    return '$_dir/tier_$t.png';
  }
}

extension TierAssetX on int {
  /// `state.activeTier.tierBadgePath` → the asset path for this tier.
  String get tierBadgePath => TierAssets.badgePath(this);
}
