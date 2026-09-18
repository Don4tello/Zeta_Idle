import 'dart:math';

import '../../models/artifact.dart' show ArtifactRarity;
import '../../models/equipment.dart' show ItemRarity;
import 'game_mode.dart';
import 'tier_scaling.dart';

/// Tier-aware weighted rarity roller, generic over ANY rarity enum (equipment
/// `ItemRarity`, `ArtifactRarity`, …). At roll time it biases the base weights
/// toward rarer entries by the active tier (via
/// [TierScaling.lootWeightMultiplier], keyed on the enum's `index`). Non-scaling
/// modes (PvP/Guild) roll on the untouched base weights.
class TierWeightedTable<R extends Enum> {
  const TierWeightedTable(this.baseWeights);

  /// Base weight per rarity (higher = more common). Omitted rarities never drop.
  final Map<R, double> baseWeights;

  /// Tier-adjusted weights (handy for showing live drop-chance % in the UI).
  Map<R, double> weightsFor(GameMode mode, int tier) => {
        for (final e in baseWeights.entries)
          e.key: e.value * TierScaling.lootWeightMultiplier(mode, tier, e.key.index),
      };

  /// Rolls a rarity using the tier-biased weights.
  R roll(Random rng, {required GameMode mode, required int tier}) {
    final weights = weightsFor(mode, tier);
    final total = weights.values.fold<double>(0, (a, b) => a + b);
    var pick = rng.nextDouble() * total;
    for (final e in weights.entries) {
      pick -= e.value;
      if (pick <= 0) return e.key;
    }
    return weights.keys.last;
  }
}

/// Ready-made tables for the game's two loot systems.
class TierLoot {
  const TierLoot._();

  /// Equipment — the 6 droppable rarities (common … mythic).
  static const TierWeightedTable<ItemRarity> equipment = TierWeightedTable({
    ItemRarity.common: 60,
    ItemRarity.uncommon: 25,
    ItemRarity.rare: 10,
    ItemRarity.epic: 4,
    ItemRarity.legendary: 1,
    ItemRarity.mythic: 0.2,
  });

  /// Artifacts — their own rarity scale (common / uncommon / rare).
  static const TierWeightedTable<ArtifactRarity> artifacts = TierWeightedTable({
    ArtifactRarity.common: 65,
    ArtifactRarity.uncommon: 28,
    ArtifactRarity.rare: 7,
  });
}
