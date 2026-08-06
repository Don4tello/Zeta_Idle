import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Thin wrapper over Firebase Remote Config for **live balance tuning** — the
/// mechanism that lets us adjust difficulty/economy in small increments from a
/// dashboard WITHOUT shipping a new build.
///
/// Every knob's default equals the current in-code constant, so the game plays
/// identically until an override is published. It's a safe no-op when Firebase
/// is unavailable (Windows/desktop), offline, or a key is unset, and fetch is
/// best-effort — it can never throw into gameplay.
///
/// Keys (publish these in the Firebase console → Remote Config):
///   enemy_hp_mult            (default 1.0)  global enemy HP dial, all modes
///   enemy_atk_mult           (default 1.0)  global enemy attack dial, all modes
///   campaign_ramp_step       (default 0.15) within-cycle difficulty ramp/step
///   campaign_ramp_phasein    (default 20)   stage by which the ramp is full
///   gold_mult                (default 1.0)  global gold reward dial
///   xp_mult                  (default 1.0)  global XP reward dial
class RemoteConfigService {
  RemoteConfigService._();
  static final RemoteConfigService instance = RemoteConfigService._();

  FirebaseRemoteConfig? _rc;

  // Defaults mirror the hardcoded constants — identity behavior when unset.
  static const Map<String, Object> _defaults = <String, Object>{
    'enemy_hp_mult': 1.0,
    'enemy_atk_mult': 1.0,
    'campaign_ramp_step': 0.15,
    'campaign_ramp_phasein': 20.0,
    'gold_mult': 1.0,
    'xp_mult': 1.0,
  };

  Future<void> init(FirebaseRemoteConfig rc) async {
    _rc = rc;
    try {
      await rc.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 8),
        // Poll at most hourly — plenty for balance tuning, and keeps clients
        // from hammering the service. (Console "Publish" still lands within
        // this window on the next fetch.)
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await rc.setDefaults(_defaults);
      await rc.fetchAndActivate();
    } catch (_) {
      // Keep in-code defaults; never block startup on config.
    }
  }

  double _d(String key, double fallback) {
    final rc = _rc;
    if (rc == null) return fallback;
    try {
      return rc.getDouble(key);
    } catch (_) {
      return fallback;
    }
  }

  // ── Difficulty (applied in EnemyData.enemyForStage → all battle modes) ──────
  double get enemyHpMult         => _d('enemy_hp_mult', 1.0);
  double get enemyAtkMult        => _d('enemy_atk_mult', 1.0);
  double get campaignRampStep    => _d('campaign_ramp_step', 0.15);
  double get campaignRampPhaseIn => _d('campaign_ramp_phasein', 20.0);

  // ── Economy (applied in the battle reward path) ─────────────────────────────
  double get goldMult => _d('gold_mult', 1.0);
  double get xpMult   => _d('xp_mult', 1.0);
}
