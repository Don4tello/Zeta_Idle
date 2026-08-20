import 'package:firebase_analytics/firebase_analytics.dart';

/// Thin wrapper over Firebase Analytics for game-specific events.
///
/// Safe no-op until [init] is called with a real instance (e.g. it stays a
/// no-op on Windows/web where Firebase is skipped, or if analytics init fails),
/// and every log is fire-and-forget so it can never affect gameplay.
///
/// Event/param names follow GA4 rules: names start with a letter, <=40 chars;
/// string values <=100 chars; <=25 params per event. Reserved names (purchase,
/// screen_view, session_start, first_open, …) are avoided.
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  FirebaseAnalytics? _fa;
  void init(FirebaseAnalytics fa) => _fa = fa;

  void _log(String name, [Map<String, Object?>? params]) {
    final fa = _fa;
    if (fa == null) return;
    Map<String, Object>? clean;
    if (params != null && params.isNotEmpty) {
      clean = {};
      params.forEach((k, v) {
        if (v == null) return;
        // GA4 only accepts String/num values.
        if (v is bool) {
          clean![k] = v ? 1 : 0;
        } else if (v is String) {
          clean![k] = v.length > 100 ? v.substring(0, 100) : v;
        } else if (v is num) {
          clean![k] = v;
        } else {
          clean![k] = v.toString();
        }
      });
    }
    // Fire-and-forget; never let analytics throw into gameplay.
    fa.logEvent(name: name, parameters: clean).catchError((_) {});
  }

  // ── Progression ─────────────────────────────────────────────────────────────
  void levelUp(int level, String heroClass) =>
      _log('level_up', {'level': level, 'hero_class': heroClass});

  void stageReached(int stage) => _log('stage_reached', {'stage': stage});

  void bossDefeated(int stage) => _log('boss_defeated', {'stage': stage});

  void featureUnlocked(String feature, int stage) =>
      _log('feature_unlocked', {'feature': feature, 'stage': stage});

  void prestige(int newLevel, int soulsEarned, int stageReached) => _log(
      'prestige',
      {'level': newLevel, 'souls': soulsEarned, 'stage': stageReached});

  void ascend(int ascensionLevel) =>
      _log('ascend', {'level': ascensionLevel});

  void subclassChosen(String subclassId, String heroClass) =>
      _log('subclass_chosen', {'subclass': subclassId, 'hero_class': heroClass});

  // ── Economy ─────────────────────────────────────────────────────────────────
  /// A spend at a sink, so sources vs sinks can be compared per currency.
  /// NB: the parameter is `currency_type`, not `currency` — GA4 reserves
  /// `currency` (ISO-4217) so it can't be a custom dimension.
  void currencySpent(String currency, int amount, String sink) => _log(
      'currency_spent', {'currency_type': currency, 'amount': amount, 'sink': sink});

  /// Currency gained from a source (kill/boss/idle/…), the faucet side of the
  /// economy — pair with [currencySpent] to balance sources vs sinks.
  /// NB: `earn_source` not `source` — GA4 reserves `source` (traffic).
  void currencyEarned(String currency, int amount, String source) => _log(
      'currency_earned', {'currency_type': currency, 'amount': amount, 'earn_source': source});

  /// A lost battle — the #1 difficulty signal. Pair with [stageReached] /
  /// [bossDefeated] to compute per-stage clear rates and spot walls.
  void battleDefeat({
    required int stage,
    required String enemyId,
    required bool isBoss,
    required int heroLevel,
  }) =>
      _log('battle_defeat', {
        'stage': stage,
        'enemy': enemyId,
        'is_boss': isBoss,
        'hero_level': heroLevel,
      });

  /// Periodic snapshot of balances + progression, for balance/pacing curves.
  void economySnapshot({
    required int stage,
    required int level,
    required int prestige,
    required int gold,
    required int shards,
    required int echoes,
    required int zcoins,
    required int mythril,
  }) =>
      _log('economy_snapshot', {
        'stage': stage,
        'level': level,
        'prestige': prestige,
        'gold': gold,
        'shards': shards,
        'echoes': echoes,
        'zcoins': zcoins,
        'mythril': mythril,
      });

  // ── Monetization / cosmetics ────────────────────────────────────────────────
  void iapPurchase(String productId) =>
      _log('iap_purchase', {'product': productId});

  /// GA4's reserved `purchase` event — feeds Firebase revenue reports.
  /// [value] is the localized price (rawPrice), [currency] an ISO-4217 code.
  void purchase({
    required double value,
    required String currency,
    String? productId,
  }) {
    final fa = _fa;
    if (fa == null || value <= 0 || currency.isEmpty) return;
    fa.logPurchase(
      value: value,
      currency: currency,
      parameters: productId == null ? null : {'product': productId},
    ).catchError((_) {});
  }

  void cosmeticUnlocked(String type, String id) =>
      _log('cosmetic_unlocked', {'type': type, 'id': id});

  void adWatched(String placement) =>
      _log('ad_watched', {'placement': placement});
}
