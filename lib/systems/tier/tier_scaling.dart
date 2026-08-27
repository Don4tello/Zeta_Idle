import 'dart:math' as math;

import 'game_mode.dart';
import 'rebirth_buffs.dart';
import 'tier_config.dart';

/// Pure, stateless scaling math for the tier system. Every value factors the
/// [GameMode] through [GameMode.scalesWithTier], so calling any of these for a
/// non-scaling mode (PvP/Guild) deterministically returns the neutral 1.0.
class TierScaling {
  const TierScaling._();

  // ── Enemy power ───────────────────────────────────────────────────────────
  // Enemies scale with the tier AND partially with the player's permanent
  // rebirth power, so meta-progression never trivialises a freshly unlocked
  // tier. HP tracks the player's damage growth; enemy damage tracks the
  // player's health growth.

  static double enemyHealthMultiplier(GameMode mode, int tier, RebirthBuffs buffs) {
    if (!mode.scalesWithTier || tier <= 0) return 1.0;
    final tierGrowth = math.pow(1 + TierConfig.enemyHpGrowthPerTier, tier).toDouble();
    final buffComp = 1 + (buffs.damageMult - 1) * TierConfig.buffCompensation;
    return tierGrowth * buffComp;
  }

  static double enemyDamageMultiplier(GameMode mode, int tier, RebirthBuffs buffs) {
    if (!mode.scalesWithTier || tier <= 0) return 1.0;
    final tierGrowth = math.pow(1 + TierConfig.enemyDamageGrowthPerTier, tier).toDouble();
    final buffComp = 1 + (buffs.healthMult - 1) * TierConfig.buffCompensation;
    return tierGrowth * buffComp;
  }

  // ── Rewards ───────────────────────────────────────────────────────────────
  /// Basic resource yield multiplier (gold/xp/shards). Compounds per tier and
  /// stacks with the permanent rebirth gold multiplier.
  static double rewardMultiplier(GameMode mode, int tier, RebirthBuffs buffs) {
    if (!mode.scalesWithTier || tier <= 0) return buffs.goldMult;
    final tierGrowth = math.pow(1 + TierConfig.rewardGrowthPerTier, tier).toDouble();
    return tierGrowth * buffs.goldMult;
  }

  // ── Loot rarity bias ──────────────────────────────────────────────────────
  /// Multiplier applied to a rarity's base drop weight at [tier]. Rarities
  /// above [rarityPivot] scale UP, those below scale DOWN — so higher tiers
  /// progressively push drops toward the top of the table.
  ///
  /// [rarityIndex] is the enum index (0 = most common). Pass your own
  /// `ItemRarity.common.index` etc.
  static const int rarityPivot = 2; // e.g. "rare"

  static double lootWeightMultiplier(GameMode mode, int tier, int rarityIndex) {
    if (!mode.scalesWithTier || tier <= 0) return 1.0;
    final base = 1 + TierConfig.lootBiasPerTier * tier;
    return math.pow(base, rarityIndex - rarityPivot).toDouble();
  }
}
