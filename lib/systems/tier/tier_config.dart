/// Tunables for the tier system. Kept in one place so balance changes never
/// require hunting through the scaling math.
class TierConfig {
  const TierConfig._();

  /// Tier 0 = the base game; tier 10 = the hardest unlockable difficulty.
  static const int minTier = 0;
  static const int maxTier = 10;

  // ── Enemy scaling per tier (compounding) ──────────────────────────────────
  /// Enemy HP grows ~+45%/tier, damage ~+30%/tier (compounding).
  static const double enemyHpGrowthPerTier     = 0.45;
  static const double enemyDamageGrowthPerTier = 0.30;

  /// Fraction of the player's permanent rebirth power that higher tiers "give
  /// back" to enemies, so meta-progression doesn't trivialise new tiers.
  /// 0 = ignore buffs, 1 = fully cancel them out. 0.6 keeps tiers challenging
  /// while still letting the player feel their permanent growth.
  static const double buffCompensation = 0.6;

  // ── Reward scaling per tier ───────────────────────────────────────────────
  /// Basic resource yield grows +35%/tier (compounding) — the carrot for
  /// pushing higher difficulties.
  static const double rewardGrowthPerTier = 0.35;

  // ── Loot rarity bias per tier ─────────────────────────────────────────────
  /// Per-tier exponential bias applied to loot weights. Rarities above the
  /// pivot are multiplied up, rarities below are multiplied down (see
  /// [TierScaling.lootWeightMultiplier]).
  static const double lootBiasPerTier = 0.12;
}
