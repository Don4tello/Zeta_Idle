import 'package:flutter/foundation.dart';

import 'game_mode.dart';
import 'player_tier_state.dart';
import 'tier_scaling.dart';

/// Owns the tier progression and is the single entry point for changing it.
///
/// It exposes tier-aware scaling for the active tier and fires
/// [onRecalculate] the instant the tier changes, so the host state (your
/// `GameState`) can immediately re-derive live enemy stats and loot weights —
/// no restart required. Extends [ChangeNotifier] so widgets can rebuild too.
class TierController extends ChangeNotifier {
  TierController({TierState state = const TierState(), this.onRecalculate})
      : _state = state;

  /// Called immediately after any tier/rebirth change. Wire this to whatever
  /// re-spawns the current enemy at the new difficulty and refreshes drop
  /// tables in the active game loop.
  final VoidCallback? onRecalculate;

  TierState _state;
  TierState get state => _state;

  int get activeTier => _state.activeTier;
  int get highestUnlockedTier => _state.highestUnlockedTier;

  /// Switch to any unlocked tier. Returns false (and does nothing) if the tier
  /// isn't unlocked or is already active. Triggers an immediate recalc on success.
  bool changeActiveTier(int newTier) {
    if (newTier == _state.activeTier) return false;
    if (!_state.canSelect(newTier)) return false;
    _state = _state.withActiveTier(newTier);
    _recalculate();
    return true;
  }

  /// Perform a rebirth. [campaignCompletedAtMaxLevel] is the gate the host
  /// supplies (e.g. `stage == 100 && level == 100`). Unlocks the next tier,
  /// grants permanent buffs and switches onto the new tier.
  bool rebirth({required bool campaignCompletedAtMaxLevel}) {
    if (!campaignCompletedAtMaxLevel || !_state.canRebirth) return false;
    _state = _state.afterRebirth();
    _recalculate();
    return true;
  }

  /// Replace the whole state (e.g. after loading a save).
  void restore(TierState state) {
    _state = state;
    notifyListeners();
  }

  void _recalculate() {
    onRecalculate?.call(); // immediate: re-derive live enemy stats + loot
    notifyListeners();     // then rebuild any listening UI
  }

  // ── Convenience scaling for the ACTIVE tier, mode-guarded ──────────────────
  double enemyHealthMultiplier(GameMode mode) =>
      TierScaling.enemyHealthMultiplier(mode, _state.activeTier, _state.buffs);

  double enemyDamageMultiplier(GameMode mode) =>
      TierScaling.enemyDamageMultiplier(mode, _state.activeTier, _state.buffs);

  double rewardMultiplier(GameMode mode) =>
      TierScaling.rewardMultiplier(mode, _state.activeTier, _state.buffs);

  double lootWeightMultiplier(GameMode mode, int rarityIndex) =>
      TierScaling.lootWeightMultiplier(mode, _state.activeTier, rarityIndex);
}
