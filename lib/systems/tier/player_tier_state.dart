import 'rebirth_buffs.dart';
import 'tier_config.dart';

/// Immutable snapshot of the player's tier progression.
///
/// [highestUnlockedTier] only ever increases (via rebirth). [activeTier] is
/// freely chosen by the player and is always clamped to the unlocked range, so
/// the two concerns stay strictly separated.
class TierState {
  const TierState({
    this.highestUnlockedTier = 0,
    this.activeTier = 0,
    this.buffs = const RebirthBuffs(),
  });

  final int highestUnlockedTier;
  final int activeTier;
  final RebirthBuffs buffs;

  bool canSelect(int tier) =>
      tier >= TierConfig.minTier && tier <= highestUnlockedTier;

  bool get canRebirth => highestUnlockedTier < TierConfig.maxTier;

  /// New snapshot with a different active tier (caller validates via [canSelect]).
  TierState withActiveTier(int tier) => TierState(
        highestUnlockedTier: highestUnlockedTier,
        activeTier: tier.clamp(TierConfig.minTier, highestUnlockedTier),
        buffs: buffs,
      );

  /// New snapshot after a rebirth: unlocks the next tier, grants permanent
  /// buffs, and moves the player onto the freshly unlocked tier.
  TierState afterRebirth() {
    if (!canRebirth) return this;
    final next = highestUnlockedTier + 1;
    return TierState(
      highestUnlockedTier: next,
      activeTier: next,
      buffs: buffs.afterRebirth(next),
    );
  }

  TierState copyWith({int? highestUnlockedTier, int? activeTier, RebirthBuffs? buffs}) =>
      TierState(
        highestUnlockedTier: highestUnlockedTier ?? this.highestUnlockedTier,
        activeTier: activeTier ?? this.activeTier,
        buffs: buffs ?? this.buffs,
      );

  Map<String, dynamic> toJson() => {
        'highestUnlockedTier': highestUnlockedTier,
        'activeTier': activeTier,
        'buffs': buffs.toJson(),
      };

  factory TierState.fromJson(Map<String, dynamic> j) {
    final highest = (j['highestUnlockedTier'] as int?) ?? 0;
    return TierState(
      highestUnlockedTier: highest,
      activeTier: ((j['activeTier'] as int?) ?? 0).clamp(0, highest),
      buffs: j['buffs'] is Map<String, dynamic>
          ? RebirthBuffs.fromJson(j['buffs'] as Map<String, dynamic>)
          : const RebirthBuffs(),
    );
  }
}

/// Separates a stat's immutable base value from the permanent rebirth
/// multiplier applied on top of it. Keeping them apart means recalculating a
/// tier/rebirth change never corrupts the base numbers.
class PlayerStats {
  const PlayerStats({
    required this.baseDamage,
    required this.baseHealth,
    this.buffs = const RebirthBuffs(),
  });

  final double baseDamage;
  final double baseHealth;
  final RebirthBuffs buffs;

  double get effectiveDamage => baseDamage * buffs.damageMult;
  double get effectiveHealth => baseHealth * buffs.healthMult;

  PlayerStats withBuffs(RebirthBuffs b) =>
      PlayerStats(baseDamage: baseDamage, baseHealth: baseHealth, buffs: b);
}
