import 'dart:async';
import 'dart:convert' show jsonEncode;
import 'dart:math';
import 'debug_logger.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter/widgets.dart';
import '../data/ability_data.dart';
import '../data/boss_hunt_data.dart';
import '../data/campaign_data.dart';
import '../data/patch_notes.dart';
import '../data/campaign_lore.dart';
import '../data/world_zone_data.dart';
import '../models/world_zone.dart';
import '../models/guild_castle.dart';
import '../models/dnd_class.dart';
import '../models/campaign_stage.dart';
import '../data/enemy_data.dart';
import '../data/game_data.dart';
import '../data/unique_items_data.dart';
import '../models/ability_rune.dart';
import '../models/shop_catalog.dart';
import '../models/equipment.dart';
import '../models/flash_event.dart';
import '../models/season_pass.dart';
import '../models/weekly_challenge.dart';
import '../models/hero_ability.dart';
import '../models/passive_tree.dart';
import '../models/daily_challenge.dart';
import '../data/daily_challenge_generator.dart';
import '../models/damage_type.dart';
import '../models/enemy.dart';
import '../models/endless_upgrades.dart';
import '../models/hero_model.dart';
import '../models/upgrade.dart';
import '../models/zone_affix.dart';
import '../models/hero_aura.dart';
import '../models/palette_skin.dart';
import '../models/pet.dart';
import '../models/achievement.dart';
import '../models/dungeon.dart';
import '../models/prestige_shop.dart';
import '../models/rebirth_boon.dart';
import '../models/gem.dart';
import '../damage/damage_pipeline.dart';
import '../damage/hero_damage_builder.dart';
import '../models/expedition.dart';
import '../models/class_mastery.dart';
import '../data/class_mastery_data.dart';
import '../models/class_quest.dart';
import '../data/class_quest_data.dart';
import '../models/hero_race.dart';
import '../models/hero_trait.dart';
import '../models/challenge_modifier.dart';
import '../models/bestiary_entry.dart';
import '../data/bestiary_data.dart';
import '../data/system_tutorials.dart';
import '../models/attack_effect.dart';
import '../models/artifact.dart';
import '../models/bounty.dart';
import '../models/ascension.dart';
import '../models/login_streak.dart';
import '../models/rune.dart';
import '../models/world_event.dart';
import '../models/gauntlet.dart';
import '../models/npc_ally.dart';
import '../models/pvp.dart';
import '../models/subclass.dart';
import '../services/analytics_service.dart';
import '../services/audio_service.dart';
import '../services/remote_config_service.dart';
import '../services/auth_service.dart';
import '../services/steam_service.dart';
import '../services/iap_service.dart';
import '../services/cloud_save_service.dart';
import '../services/save_service.dart';
import '../services/pvp_service.dart';
import '../services/leaderboard_service.dart';

// Snapshot of a level-up that just occurred — shown in the victory overlay.
class SimBattleResult {
  const SimBattleResult({
    required this.count,
    required this.goldEarned,
    required this.xpEarned,
    required this.itemsDropped,
  });
  final int count;
  final int goldEarned;
  final int xpEarned;
  final List<EquipmentItem> itemsDropped;
}

class LevelUpEvent {
  const LevelUpEvent({
    required this.fromLevel,
    required this.toLevel,
    required this.hpBefore,
    required this.hpAfter,
    required this.statGains,
  });
  final int          fromLevel;
  final int          toLevel;
  final int          hpBefore;
  final int          hpAfter;
  final List<String> statGains; // e.g. ['STR', 'CON']
}

/// Snapshot of a single completed fight — powers the post-fight summary sheet.
/// Built when a battle ends; reusable across every mode that runs a fight.
class FightSummary {
  const FightSummary({
    required this.enemyName,
    required this.victory,
    required this.totalDamage,
    required this.maxHit,
    required this.hitCount,
    required this.rounds,
    required this.abilitiesUsed,
    required this.log,
  });

  final String enemyName;
  final bool victory;
  final int totalDamage; // hero attack damage this fight
  final int maxHit;
  final int hitCount;
  final int rounds;
  final Map<String, int> abilitiesUsed; // ability name -> times cast
  final List<String> log;

  int get avgHit => hitCount == 0 ? 0 : (totalDamage / hitCount).round();
}

class GameState extends ChangeNotifier {
  GameState({
    SaveService? saveService,
    CloudSaveService? cloudSaveService,
    AuthService? authService,
    AudioService? audioService,
  })  : saveService = saveService ?? SaveService(),
        cloudSaveService = cloudSaveService ?? CloudSaveService(),
        authService = authService ?? AuthService(),
        audioService = audioService ?? AudioService(),
        hero = HeroModel(name: 'The Warden'),
        gold = 250,
        idleProgress = 0,
        campaignStageIndex = 0,
        currentEnemy = null,
        battleLog = ['The Warden awakens in the cursed realm.'],
        lastAction = 'Ready to battle',
        upgrades = List<Upgrade>.from(GameData.upgrades),
        dailyChallenges =
            DailyChallengeGenerator.generateForDate(DateTime.now()) {
    _iapService = IapService(
      grantCrystals,
      onPackPurchased: (productId) {
        final packId = switch (productId) {
          'pack_starter' => 'starter_pack',
          'pack_hero'    => 'hero_pack',
          'pack_legend'  => 'legend_pack',
          _ => null,
        };
        if (packId != null) purchaseStarterPack(packId);
      },
      onSubscriptionActivated: (productId, days) {
        if (productId == 'sub_speed_monthly') {
          activateSpeedSub(days);
        } else {
          activatePremium(days);
        }
      },
      onPremiumSkinPurchased: (skinId) => unlockPremiumSkin(skinId),
      onCosmeticPurchased: (productId) => unlockCosmeticByProduct(productId),
      onPetPurchased: (productId) => unlockPremiumPet(productId),
    );
    _iapService.init();
    steamService.init();
    _autoSaveTimer = Timer.periodic(
      const Duration(seconds: 60),
      // Only autosave while foregrounded — otherwise 'savedAt' keeps refreshing
      // in the background and "time away" is under-counted on return.
      (_) { if (_slotLoaded && appActive) saveToLocal(); },
    );
    // Idle income — ticks every 5 s, collects every 12th tick (60 s cycle).
    _idleTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) {
        if (!_slotLoaded || !appActive) return; // paused apps accrue via offline calc
        tickEnergy(); // refill campaign energy in real time (and catch-up)
        generateIdleProgress();
        _idleTickCount++;
        if (_idleTickCount >= 12) {
          _idleTickCount = 0;
          collectIdleRewards();
        }
        // Auto-campaign runs VISIBLY on the Battle screen only. We intentionally
        // do NOT resolve battles silently in the background — that made the
        // campaign look like it was "playing itself" with no fights. Just clear
        // the flag if the subscription lapsed.
        if (autoCampaign && !canAutoCampaign) {
          autoCampaign = false;
        }
      },
    );
  }

  int _currentSlot = 0;
  bool _slotLoaded = false;
  // Whether the app is in the foreground. The idle/autosave timers only run when
  // true, so a backgrounded app stops ticking (no double income) and stops
  // refreshing the save timestamp (so "time away" is measured correctly).
  bool appActive = true;
  // Epoch ms of the last local save — the baseline for offline-progress on a
  // warm resume (a cold start uses the persisted 'savedAt' instead).
  int _lastSaveMs = DateTime.now().millisecondsSinceEpoch;
  // Set true when an existing save fails to parse: we then REFUSE to auto-save,
  // so a parse bug can never overwrite (and permanently destroy) the player's
  // real save on disk — a future app version can still recover it.
  bool _saveBlocked = false;
  // Set true for one session when loadSlot auto-restored a wiped save from the
  // high-water-mark backup, so the UI can surface a "character recovered" notice.
  bool characterRecoveredFromBackup = false;
  bool _endlessMode = false;
  int _confirmedPrestigeLevel = 0;

  int get currentSlot => _currentSlot;
  bool get isSlotLoaded => _slotLoaded;
  int get confirmedPrestigeLevel => _confirmedPrestigeLevel;

  // When true, notifyListeners() is a no-op. Used to batch the ~50 notifies a
  // background auto-campaign tick would otherwise fire (each a UI rebuild → the
  // lag introduced with background fights) into a single rebuild at the end.
  bool _suppressNotify = false;
  @override
  void notifyListeners() {
    if (_suppressNotify) return;
    super.notifyListeners();
  }

  // Per-battle perk state — reset at the start of every fight
  // ── Ally active ability state (reset each battle) ─────────────────────────
  final Set<String> _allyAbilitiesUsed = {};
  Set<String> get allyAbilitiesUsed => Set.unmodifiable(_allyAbilitiesUsed);
  bool _lenaBackstabReady      = false;
  bool _felixBribeActive       = false;
  int  _rukStoneSkinRoundsLeft = 0;
  // Temporary dodge-chance buff granted by economy mercs' combat ability.
  int  _mercDodgePct           = 0;
  int  _mercDodgeRounds        = 0;

  // _hasMomentum/_bloodlustReady are NOT reset by _resetBattlePerks: set on kill
  // and consumed on the next attack roll, so they must survive the battle boundary.
  bool _hasMomentum         = false; // STR: Savage Momentum
  bool _bloodlustReady      = false; // Slayer keystone: Bloodlust
  bool _unbrokenUsed        = false; // CON: Unbroken
  bool _unbreakableUsed     = false; // Guardian keystone: Unbreakable
  bool _battleAwarenessUsed = false; // WIS: Battle Awareness
  // Heal fatigue: each heal within one battle is 15% weaker than the last,
  // so heal-loops can't make long boss fights risk-free. Resets per battle.
  int _healsThisBattle = 0;

  // Affix system
  List<ZoneAffix> _activeAffixes = [];
  int _attackRoundCounter = 0; // Time Fracture: tracks hero attack count
  int _deathSpiralRounds  = 0; // Death Spiral: rounds of drain elapsed
  int _battleTurnCount = 0;

  // Equipment
  final EquipmentInventory inventory = EquipmentInventory();
  EquipmentItem? lastItemDrop;

  // Loot history (last 20 events)
  final List<({String icon, String text, String? detail, DateTime time})> lootHistory = [];

  void logLoot(String icon, String text, {String? detail}) {
    lootHistory.insert(0, (icon: icon, text: text, detail: detail, time: DateTime.now()));
    if (lootHistory.length > 20) lootHistory.removeLast();
  }

  void setActiveDamageType(int index) {
    hero.activeDamageTypeIndex = index;
    notifyListeners();
    saveToLocal();
  }

  bool canEquip(EquipmentItem item) {
    if (item.requiredClass != null && item.requiredClass != hero.heroClass) return false;
    if (hero.level < item.levelRequired) return false;
    // rebirthRequired is now the difficulty tier the item rolled at; gate on the
    // tier you've unlocked (prestige is retired).
    if (highestUnlockedTier < item.rebirthRequired) return false;
    return true;
  }

  void equipItem(EquipmentItem item) {
    if (!canEquip(item)) return;
    inventory.equip(item);
    _dailyItemEquipped = true;
    trackEquipItem();
    notifyListeners();
    saveToLocal();
  }

  void unequipSlot(ItemSlot slot) {
    inventory.unequip(slot);
    notifyListeners();
    saveToLocal();
  }

  void autoEquipBestItems() {
    for (final slot in ItemSlot.values) {
      final candidates = inventory.bag
          .where((i) => i.slot == slot &&
              (i.requiredClass == null || i.requiredClass == hero.heroClass))
          .toList();
      if (candidates.isEmpty) continue;
      final current = inventory.equipped[slot];
      final best = candidates.reduce((a, b) =>
          _itemScore(a) >= _itemScore(b) ? a : b);
      if (current == null || _itemScore(best) > _itemScore(current)) {
        inventory.equip(best);
        _dailyItemEquipped = true;
        trackEquipItem(); // count toward the "Gearing Up" quest like manual equips
      }
    }
    notifyListeners();
    saveToLocal();
  }

  // Weighted so auto-equip prefers power/survival over economy. Summing raw
  // values made a +32% gold roll beat a +29% damage roll — which no player
  // would pick. Gold/XP are weighted low; offense stats are boosted.
  int _itemScore(EquipmentItem item) {
    var score = 0.0;
    for (final b in item.bonuses) {
      final weight = switch (b.stat) {
        ItemStat.goldPct || ItemStat.xpPct => 0.25,
        ItemStat.damageBonus || ItemStat.damagePercent ||
        ItemStat.attackBonus || ItemStat.strength ||
        ItemStat.elemPenetration => 1.5,
        _ => 1.0,
      };
      score += b.value * weight;
    }
    score += item.baseDamage * 2; // weapons contribute their base hit
    return score.round();
  }

  bool reforgeItem(EquipmentItem item) {
    if (!ItemLootTable.canReforge(item.rarity)) return false;
    final cost = ItemLootTable.reforgeCost(item.rarity);
    if (gold < cost.gold || shards < cost.shards) return false;
    gold   -= cost.gold;
    shards -= cost.shards;
    ItemLootTable.rerollBonuses(item, hero.level, _rng);
    advanceWeekly('w_craft', 1);
    notifyListeners();
    saveToLocal();
    return true;
  }

  void discardBagItem(int index) {
    inventory.discardFromBag(index);
    notifyListeners();
    saveToLocal();
  }

  // ── Elemental Mastery & Ability Scores ────────────────────────────────────
  int towerShards    = 0; // Earned from Tower Ascension runs; used in Elemental Mastery
  final Map<String, int> _elementalMasteryRanks = {};
  // Elemental Mastery — each rank adds +3% damage and +2% resistance
  int elementalMasteryRank(String key) => _elementalMasteryRanks[key] ?? 0;
  // Gold cost: 500 → 1000 → 2000 → …
  int elementalMasteryGoldCost(String key) {
    final rank = elementalMasteryRank(key);
    return 500 * (1 << rank).clamp(1, 1024);
  }
  // Tower Shard cost: 3 → 6 → 12 → …
  int elementalMasteryShardCost(String key) {
    final rank = elementalMasteryRank(key);
    return 3 * (1 << rank).clamp(1, 256);
  }
  // Keep elementalMasteryUpgradeCost as gold for backward-compat callers
  int elementalMasteryUpgradeCost(String key) => elementalMasteryGoldCost(key);
  int elementalMasteryDamagePct(DamageType type) =>
      elementalMasteryRank(type.name) * 3;
  int elementalMasteryResistancePct(DamageType type) =>
      elementalMasteryRank(type.name) * 2;

  bool upgradeElementalMastery(String key) {
    if (hero.level < 15) return false;
    final goldCost  = elementalMasteryGoldCost(key);
    final shardCost = elementalMasteryShardCost(key);
    if (gold < goldCost || towerShards < shardCost) return false;
    gold        -= goldCost;
    towerShards -= shardCost;
    _elementalMasteryRanks[key] = (_elementalMasteryRanks[key] ?? 0) + 1;
    notifyListeners();
    saveToLocal();
    return true;
  }


  // ── Premium cosmetics ──────────────────────────────────────────────────────
  int zcoins = 0;
  String? equippedAuraId;
  final Set<String> ownedAuraIds = {};

  Color? get heroAuraColor {
    if (equippedAuraId == null) return null;
    try {
      return kAuraCatalog.firstWhere((a) => a.id == equippedAuraId).color;
    } catch (_) { return null; }
  }

  double get heroAuraIntensity {
    if (equippedAuraId == null) return 1.0;
    try {
      return kAuraCatalog.firstWhere((a) => a.id == equippedAuraId).intensity;
    } catch (_) { return 1.0; }
  }

  void grantCrystals(int amount) {
    zcoins += amount;
    notifyListeners();
    saveToLocal();
  }

  // ── Shop & Monetization ────────────────────────────────────────────────────
  final Set<String> purchasedPacks = {};
  final Set<String> ownedCosmetics = {};
  String? activeTitle;
  String? activeNameColor;
  String? activeFrame;
  bool isPremiumSubscriber = false;
  int premiumExpiryMs = 0;
  bool isSpeedSubscriber = false;
  int speedSubExpiryMs = 0;
  int lastSubZcoinGrantMonth = 0; // year*12+month of the last monthly sub grant

  /// Monthly bonus Z-Coins for active subscribers — Premium 300, Speed 100.
  /// Idempotent per calendar month; runs whenever a sub is confirmed active.
  void _grantMonthlySubZcoins() {
    if (!hasPremium && !hasSpeedSub) return;
    final now = DateTime.now();
    final monthKey = now.year * 12 + now.month;
    if (monthKey <= lastSubZcoinGrantMonth) return;
    final amount = hasPremium ? 300 : 100;
    zcoins += amount;
    lastSubZcoinGrantMonth = monthKey;
    logLoot('🪙', 'Subscriber bonus: +$amount Z-Coins');
    notifyListeners();
    saveToLocal();
  }

  bool get hasPremium =>
      isPremiumSubscriber && premiumExpiryMs > DateTime.now().millisecondsSinceEpoch;

  bool get hasSpeedSub =>
      isSpeedSubscriber && speedSubExpiryMs > DateTime.now().millisecondsSinceEpoch;

  /// Subscription idle-income bonus — Premium Pass +50%, Speed Boost +25%.
  double get subIdleMult => hasPremium ? 1.5 : (hasSpeedSub ? 1.25 : 1.0);

  bool purchaseStarterPack(String packId) {
    if (purchasedPacks.contains(packId)) return false;
    final pack = StarterPack.all.where((p) => p.id == packId).firstOrNull;
    if (pack == null) return false;
    purchasedPacks.add(packId);
    for (final e in pack.contents.entries) {
      switch (e.key) {
        case 'zcoins':  zcoins += e.value;
        case 'gold':      gold += e.value;
        case 'shards':    shards += e.value;
        case 'essence':   essence += e.value;
        case 'mythril':   mythril += e.value;
        case 'echoes':    echoes += e.value;
        case 'gemShards': gemShards += e.value;
        case 'epicHelmet':
          inventory.addToBag(ItemLootTable.craftAt(ItemSlot.helmet, ItemRarity.epic, hero.level, _rng));
        case 'legendaryWeapon':
          inventory.addToBag(ItemLootTable.craftAt(ItemSlot.weapon, ItemRarity.legendary, hero.level, _rng));
        case 'setPiece':
          final setDrop = ItemLootTable.tryDropSet(hero.level, _rng, tier: activeTier);
          if (setDrop != null) inventory.addToBag(setDrop);
      }
    }
    logLoot('🎁', 'Purchased ${pack.name}');
    notifyListeners();
    saveToLocal();
    persistEntitlements();
    return true;
  }

  bool purchaseCosmetic(String cosmeticId) {
    if (ownedCosmetics.contains(cosmeticId)) return false;
    final item = CosmeticItem.all.where((c) => c.id == cosmeticId).firstOrNull;
    if (item == null) return false;
    if (item.isRealMoney) return false; // real-money cosmetics are IAP-only
    if (zcoins < item.zcoinCost) return false;
    zcoins -= item.zcoinCost;
    ownedCosmetics.add(cosmeticId);
    AnalyticsService.instance.currencySpent('zcoins', item.zcoinCost, 'cosmetic');
    AnalyticsService.instance.cosmeticUnlocked('cosmetic', cosmeticId);
    notifyListeners();
    saveToLocal();
    return true;
  }

  /// Buy a resource bundle with ZCoins. Returns false if unaffordable.
  bool buyResourceBundle(String bundleId) {
    final b = ResourceBundle.all.where((r) => r.id == bundleId).firstOrNull;
    if (b == null || zcoins < b.zcoinCost) return false;
    zcoins -= b.zcoinCost;
    switch (b.resource) {
      case 'gold':    gold += b.amount;
      case 'shards':  shards += b.amount;
      case 'echoes':  echoes += b.amount;
      case 'essence': essence += b.amount;
      case 'mythril': mythril += b.amount;
    }
    AnalyticsService.instance.currencySpent('zcoins', b.zcoinCost, 'resource_bundle');
    notifyListeners();
    saveToLocal();
    return true;
  }

  /// Grant a real-money cosmetic after its IAP completes (id resolved from the
  /// purchased product). Auto-equips it so the player immediately sees it.
  void unlockCosmeticByProduct(String productId) {
    final item = CosmeticItem.forProductId(productId);
    if (item == null) return;
    ownedCosmetics.add(item.id);
    AnalyticsService.instance.cosmeticUnlocked('cosmetic_rm', item.id);
    equipCosmetic(item.id);
    notifyListeners();
    saveToLocal();
  }

  void equipCosmetic(String cosmeticId) {
    final item = CosmeticItem.all.where((c) => c.id == cosmeticId).firstOrNull;
    if (item == null || !ownedCosmetics.contains(cosmeticId)) return;
    switch (item.type) {
      case CosmeticType.title:     activeTitle = item.name;
      case CosmeticType.nameColor: activeNameColor = cosmeticId;
      case CosmeticType.frame:     activeFrame = cosmeticId;
    }
    notifyListeners();
    saveToLocal();
  }

  Color? get nameColor {
    if (activeNameColor == null) return null;
    return CosmeticItem.all.where((c) => c.id == activeNameColor).firstOrNull?.color;
  }

  // Subscriptions SET the expiry to now + period (not accumulate) so the
  // restore-on-launch re-delivery refreshes the active window instead of
  // stacking 30 days every launch. When the sub lapses Google stops delivering
  // it on restore, and the window naturally elapses.
  void activatePremium(int durationDays) {
    isPremiumSubscriber = true;
    premiumExpiryMs = DateTime.now().millisecondsSinceEpoch
        + durationDays * 24 * 60 * 60 * 1000;
    if (activeTitle == null) activeTitle = 'Premium';
    notifyListeners();
    saveToLocal();
    persistEntitlements();
    _grantMonthlySubZcoins();
  }

  void activateSpeedSub(int durationDays) {
    isSpeedSubscriber = true;
    speedSubExpiryMs = DateTime.now().millisecondsSinceEpoch
        + durationDays * 24 * 60 * 60 * 1000;
    notifyListeners();
    saveToLocal();
    persistEntitlements();
    _grantMonthlySubZcoins();
  }

  // ── Account-wide entitlements ───────────────────────────────────────────────
  // Subscriptions and real-money cosmetics/pets belong to the ACCOUNT, not the
  // character. They're mirrored into a slot-independent store so every character
  // shares them and they survive rebirth / switching slots.

  Map<String, dynamic> _entitlementsJson() {
    final premiumPetIds = ownedPetIds
        .where((id) => kPetCatalog.any((p) => p.id == id && p.productId != null))
        .toList();
    return {
      'isPremiumSubscriber': isPremiumSubscriber,
      'premiumExpiryMs':     premiumExpiryMs,
      'isSpeedSubscriber':   isSpeedSubscriber,
      'speedSubExpiryMs':    speedSubExpiryMs,
      'premiumSkins':        ownedPremiumSkinIds.toList(),
      'premiumPets':         premiumPetIds,
      'purchasedPacks':      purchasedPacks.toList(),
    };
  }

  /// Write the current entitlements to the shared account store. Call after any
  /// real-money purchase or subscription change.
  void persistEntitlements() {
    saveService.saveEntitlements(_entitlementsJson());
  }

  /// Merge the account-wide entitlements into this character (union of owned
  /// content; latest subscription window). Applied on every slot load and after
  /// rebirth so paid content is never lost by switching or resetting characters.
  Future<void> applyAccountEntitlements() async {
    final e = await saveService.loadEntitlements();
    if (e == null) return;
    if ((e['isPremiumSubscriber'] as bool?) ?? false) isPremiumSubscriber = true;
    final pExp = (e['premiumExpiryMs'] as int?) ?? 0;
    if (pExp > premiumExpiryMs) premiumExpiryMs = pExp;
    if ((e['isSpeedSubscriber'] as bool?) ?? false) isSpeedSubscriber = true;
    final sExp = (e['speedSubExpiryMs'] as int?) ?? 0;
    if (sExp > speedSubExpiryMs) speedSubExpiryMs = sExp;
    ownedPremiumSkinIds.addAll(((e['premiumSkins'] as List?)?.cast<String>()) ?? const []);
    ownedPetIds.addAll(((e['premiumPets'] as List?)?.cast<String>()) ?? const []);
    purchasedPacks.addAll(((e['purchasedPacks'] as List?)?.cast<String>()) ?? const []);
    notifyListeners();
  }

  // ── Campaign Energy ────────────────────────────────────────────────────────
  // Max energy scales with hero level: a base of 20 at level 1, +1 per level,
  // capped at 60 (reached at level 41). Energy becomes a progression reward
  // instead of handing a level-1 character the full pool. It's a getter because
  // it depends on hero.level.
  static const int kEnergyCap  = 60;
  static const int kBaseEnergy = 20;
  int get maxEnergy => (kBaseEnergy + hero.level - 1).clamp(kBaseEnergy, kEnergyCap);
  static const int energyRechargeSeconds = 300; // 1 energy per 5 min
  int energy = kBaseEnergy;
  int _energyRefillEpochMs = 0;
  int dailyEnergyRefillsUsed = 0;
  static const int maxDailyRefills = 3;
  static const int refillAmount = 10;
  static const int energyPurchaseAmount = 20; // ZCoin buy grants a full bar's worth

  void tickEnergy() {
    if (energy >= maxEnergy) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_energyRefillEpochMs == 0) {
      _energyRefillEpochMs = now + energyRechargeSeconds * 1000;
      return;
    }
    while (_energyRefillEpochMs > 0 && now >= _energyRefillEpochMs && energy < maxEnergy) {
      energy++;
      _energyRefillEpochMs += energyRechargeSeconds * 1000;
    }
    if (energy >= maxEnergy) _energyRefillEpochMs = 0;
  }

  bool spendEnergy({int cost = 1}) {
    tickEnergy();
    if (energy < cost) return false;
    if (energy == maxEnergy) {
      _energyRefillEpochMs = DateTime.now().millisecondsSinceEpoch + energyRechargeSeconds * 1000;
    }
    energy -= cost;
    notifyListeners();
    saveToLocal();
    return true;
  }

  bool useEnergyRefill() {
    if (dailyEnergyRefillsUsed >= maxDailyRefills) return false;
    dailyEnergyRefillsUsed++;
    energy = (energy + refillAmount).clamp(0, maxEnergy);
    if (energy >= maxEnergy) _energyRefillEpochMs = 0;
    notifyListeners();
    saveToLocal();
    return true;
  }

  bool buyEnergy() {
    if (zcoins < 50) return false;
    zcoins -= 50;
    // Purchased energy is ADDED (a full bar's worth) and may overflow the cap —
    // buying at 5/20 gives 25/20. Only natural regen and the free daily refill
    // stop at maxEnergy; a purchase always grants the full amount so it's never
    // partially wasted. Over-cap energy simply doesn't regen (tickEnergy guards
    // on energy >= maxEnergy) but is spent normally.
    energy += energyPurchaseAmount;
    _energyRefillEpochMs = 0; // energy is now >= max; regen restarts once spent below
    notifyListeners();
    saveToLocal();
    return true;
  }

  Duration get energyRechargeRemaining {
    if (energy >= maxEnergy || _energyRefillEpochMs == 0) return Duration.zero;
    final ms = _energyRefillEpochMs - DateTime.now().millisecondsSinceEpoch;
    return Duration(milliseconds: ms.clamp(0, energyRechargeSeconds * 1000));
  }

  // ── Battle speed ───────────────────────────────────────────────────────────
  int speedTier = 1;           // 1=1x, 2=1.5x, 3=prod:2x / debug:5x, 4=10x (debug)
  bool autoCampaign = false;
  // True while the Battle screen is mounted. It drives auto-campaign VISIBLY
  // (animated fights + auto-advance), so the silent background sim must stand
  // down to avoid both loops fighting the same stage.
  bool battleScreenActive = false;

  // Unlock notification — set when auto-campaign crosses a content-unlock threshold.
  // Auto-campaign pauses so the player sees what unlocked. Cleared on Continue.
  String? pendingUnlockNotice;

  // ── System tutorial (guided onboarding) ────────────────────────────────────
  // When a progression system unlocks we pause the auto-fight, navigate to it,
  // and show a coach overlay. The shell reads pendingTutorialStage; the target
  // hub reads navRequestSubTab to select the exact sub-tab.
  SystemTutorial? pendingTutorial;   // the coach currently showing (null = none)
  bool _autoWasOnForTutorial = false;
  String? navRequestSubTab;
  int _lastAbilityTutorialLevel = 0; // highest level whose new-ability coach fired
  bool _paragonTutorialSeen = false; // the level-10 Paragon reveal coach fired

  /// Starts a coach (pauses the auto-fight). One at a time — ignored if another
  /// is already showing (the caller keeps its "seen" guard so it can retry).
  void _triggerTutorial(SystemTutorial? t) {
    if (t == null || pendingTutorial != null) return;
    pendingTutorial = t;
    if (autoCampaign) { _autoWasOnForTutorial = true; autoCampaign = false; }
  }

  void dismissSystemTutorial() {
    pendingTutorial = null;
    if (_autoWasOnForTutorial) { _autoWasOnForTutorial = false; autoCampaign = true; }
    notifyListeners();
    saveToLocal();
  }

  /// Dev tool: clear every "seen" tutorial flag so the guided coaches re-trigger
  /// as you play (unlock-stage coaches, ability coaches, gear, Paragon).
  /// Dev tool: jump the hero's level by [n] (for measuring high-level leveling
  /// pace / XP-curve calibration). Grants the matching Paragon points, refreshes
  /// derived stats, and tops up HP.
  void debugAddLevels(int n) {
    hero.level += n;
    hero.experience = 0;
    hero.experienceToNextLevel = HeroModel.expToNextForLevel(hero.level);
    _syncParagonLevels();
    _syncHeroHpPct();
    hero.currentHealth = hero.maxHealth;
    notifyListeners();
    saveToLocal();
  }

  void debugResetTutorials() {
    _seenUnlockStages.clear();
    _lastAbilityTutorialLevel = 0;
    _paragonTutorialSeen = false;
    pendingTutorial = null;
    notifyListeners();
    saveToLocal();
  }

  /// Dev tool: fully max the loaded character for top-down balance testing — a
  /// maxed hero should be the anchor for "beats the Tier 10 final boss". Maxes
  /// tier, level, currencies, ability scores, passives, paragon, gear (mythic in
  /// every slot), pets and mercenaries. (Artifacts/runes/ascension/mastery are
  /// not yet auto-maxed — the ZPWR power-breakdown log will show them at 0.)
  void debugMaxCharacter() {
    // Difficulty tier 10 (highest).
    prestigeLevel = 10;
    _confirmedPrestigeLevel = 10;
    highestUnlockedTier = 10;
    activeTier = 10;

    // Level (drives base HP/damage + Paragon points).
    hero.level = 1000;
    hero.experienceToNextLevel = HeroModel.expToNextForLevel(1000);

    // Currencies — plenty of everything so nothing gates the build.
    gold = 1000000000;
    shards = 1000000000;
    essence = 1000000000;
    zcoins = 1000000;
    mythril = 1000000;
    echoes = 1000000;
    prestigeSouls = 1000000;

    // Ability scores maxed.
    for (final k in _abilityScoreKeys) {
      _abilityScoreRanks[k] = 100;
    }

    // Passive tree fully maxed.
    passiveTree.debugMaxAll();

    // Paragon board — deep ranks in every stat + all one-time prestige nodes.
    for (final s in kParagonStats) {
      for (int i = 0; i < 200; i++) {
        prestigeShop.rankUpParagon(s.id);
      }
    }
    for (final n in kPrestigeNodes) {
      prestigeShop.forceUnlock(n.id);
    }

    // Best-in-slot mythic gear in every equipment slot.
    for (final slot in ItemSlot.values) {
      final item = ItemLootTable.craftAt(slot, ItemRarity.mythic, hero.level, _rng, rebirthLevel: 10);
      inventory.addToBag(item);
      equipItem(item);
    }

    // Own every pet; equip the first.
    ownedPetIds.addAll(kPetCatalog.map((p) => p.id));
    if (kPetCatalog.isNotEmpty) equipPet(kPetCatalog.first.id);

    // Every mercenary at max level (1..5).
    for (final def in NpcAllyDef.all) {
      _allyLevels[def.id] = 5;
    }

    // Ascension nodes maxed.
    for (final n in AscensionNode.all) {
      _ascensionNodes[n.id] = n.maxLevel;
    }

    // Class mastery maxed.
    for (final m in kMasteryCatalog) {
      masteryLevels[m.id] = m.maxLevel;
    }

    // Elemental mastery maxed (deep ranks in every element).
    for (final dt in DamageType.values) {
      _elementalMasteryRanks[dt.name] = 50;
    }

    // Endless / Tower upgrades maxed (all nodes + synergies + milestone perks).
    endlessUpgrades.debugMaxAll();

    // Abilities maxed (deep ranks in every class ability).
    for (final a in AbilityData.forClass(hero.heroClass)) {
      _abilityRanks[a.id] = 60;
    }

    // Artifacts: unlock every grid cell, roll a full grid of top-tier artifacts,
    // then auto-equip the best.
    _unlockedArtifactCells = 81;
    for (int i = 0; i < 90; i++) {
      ownedArtifacts.add(ArtifactGenerator.roll(dropLevel: hero.level, rng: _rng, tier: 10));
    }
    autoEquipArtifacts();

    // Jump to the Tier 10 final boss (stage 100 = Omega Absolute) so the anchor
    // fight is one tap away. campaignStageIndex is 0-based; 99 = the last stage.
    campaignStageIndex = 99;
    if (campaignAllTimeHigh < 99) campaignAllTimeHigh = 99;

    // Recompute cached stats, top up HP, persist.
    _syncHeroHpPct();
    _syncParagonLevels();
    hero.currentHealth = hero.maxHealth;
    _setLastAction('DEV: character maxed (Tier 10, Lv 1000, all systems).');
    notifyListeners();
    saveToLocal();
  }

  /// A hub consumes the pending sub-tab navigation request if it matches one of
  /// its own tab labels; returns the label to select (and clears it), else null.
  String? consumeNavRequestFor(List<String> hubTabLabels) {
    final req = navRequestSubTab;
    if (req != null && hubTabLabels.contains(req)) {
      navRequestSubTab = null;
      return req;
    }
    return null;
  }

  /// Fires the Gear coach the first time the player has any item (event-based,
  /// not stage-based). Defers if another tutorial is already showing.
  void _maybeTriggerGearTutorial() {
    if (_seenUnlockStages.contains(SystemTutorial.gearStage)) return;
    if (inventory.bag.isEmpty && inventory.equipped.isEmpty) return;
    if (pendingTutorial != null) return; // let the current one finish first
    final t = SystemTutorial.forStage(SystemTutorial.gearStage);
    if (t == null) return;
    _seenUnlockStages.add(SystemTutorial.gearStage);
    _triggerTutorial(t);
  }

  /// Fires a coach when a new active ability unlocks on level-up (levels 5, 10,
  /// 15, 20, 25). Navigates to the Abilities tab.
  static const _abilityTutorialLevels = [5, 10, 15, 20, 25];
  void _maybeTriggerAbilityTutorial() {
    if (pendingTutorial != null) return;
    int? fire;
    for (final lvl in _abilityTutorialLevels) {
      if (hero.level >= lvl && _lastAbilityTutorialLevel < lvl) fire = lvl;
    }
    if (fire == null) return;
    _lastAbilityTutorialLevel = fire;
    _triggerTutorial(SystemTutorial(
      stage: -2, navTab: 0, subTab: 'ABILITIES', icon: '✨',
      title: 'New Ability Unlocked',
      howTo: 'Reaching level $fire unlocked a new active ability! Abilities fire '
          'automatically in battle — spend Shards here to rank it up and choose '
          'its milestone upgrades.',
    ));
  }

  // Set to true the first time the hero hits level 30 (class questline unlocks).
  bool pendingClassQuestlineUnlock = false;
  bool _classQuestlineNoticeSeen   = false;
  // Coached once, when the class questline is completed and the Ultimate unlocks.
  bool _ultimateUnlockedTutorialSeen = false;
  // Artifacts have no stage gate — the table unlocks the first time one drops.
  bool artifactsUnlocked = false;
  final Set<int> _seenUnlockStages = {};

  static const Map<int, String> _unlockStageNames = {
    2:  'Abilities',
    5:  'Daily Quests & Achievements',
    8:  'Passive Tree',
    10: 'Stat Bonuses & Quests',
    12: 'Bestiary',
    15: 'Dungeon & Codex',
    18: 'Pet Companions',
    20: 'Bounties',
    22: 'Mercenaries',
    25: 'Boss Rush',
    28: 'Armory',
    30: 'World Events',
    35: 'Tower Ascension & Elemental Mastery',
    40: 'Expedition',
    45: 'Gauntlet',
    50: 'PvP',
    55: 'Bestiary Mode',
    100: 'Difficulty Tiers',
  };

  // Auto-Campaign is a paid perk (Speed Boost / Premium Pass). Returns false if
  // a non-subscriber tries to enable it (the UI shows an upsell in that case).
  bool get canAutoCampaign => hasPremium || hasSpeedSub;

  bool toggleAutoCampaign() {
    if (!autoCampaign && !canAutoCampaign) return false; // gated to subscribers
    autoCampaign = !autoCampaign;
    notifyListeners();
    saveToLocal();
    return true;
  }

  // Auto-loot settings
  ItemRarity? autoSalvageThreshold; // null = off; salvages items at or below this rarity
  bool autoEquipUpgrades = false;
  bool hapticsEnabled = true;
  bool showDamageNumbers = true;
  bool reducedParticles = false;
  bool notificationsEnabled = true; // local reminder notifications opt-out

  void toggleHaptics()         { hapticsEnabled     = !hapticsEnabled;     notifyListeners(); saveToLocal(); }
  void toggleDamageNumbers()   { showDamageNumbers  = !showDamageNumbers;  notifyListeners(); saveToLocal(); }
  void toggleReducedParticles(){ reducedParticles   = !reducedParticles;   notifyListeners(); saveToLocal(); }
  void toggleNotifications()   { notificationsEnabled = !notificationsEnabled; notifyListeners(); saveToLocal(); }

  // Central haptic helper — respects the user's haptic preference
  void haptic(void Function() feedback) { if (hapticsEnabled) feedback(); }

  void cycleAutoSalvageThreshold() {
    const tiers = [null, ItemRarity.common, ItemRarity.uncommon, ItemRarity.rare, ItemRarity.epic];
    final idx = tiers.indexOf(autoSalvageThreshold);
    autoSalvageThreshold = tiers[(idx + 1) % tiers.length];
    notifyListeners();
    saveToLocal();
  }

  void toggleAutoEquipUpgrades() {
    autoEquipUpgrades = !autoEquipUpgrades;
    notifyListeners();
    saveToLocal();
  }

  void applyAutoLoot(EquipmentItem item) {
    if (autoSalvageThreshold != null && item.rarity.index <= autoSalvageThreshold!.index) {
      disenchantItems([item]);
      return;
    }
    if (autoEquipUpgrades && canEquip(item)) {
      final current = inventory.equipped[item.slot];
      if (current == null || _itemPower(item) > _itemPower(current)) {
        equipItem(item);
        return;
      }
    }
  }

  int _itemPower(EquipmentItem item) =>
      item.baseDamage + item.bonuses.fold(0, (s, b) => s + b.value);
  int speedBoostExpiryMs = 0;  // epoch ms when purchased 2x boost expires

  bool get speedBoostActive =>
      DateTime.now().millisecondsSinceEpoch < speedBoostExpiryMs;

  static const int kSpeedBoostCrystalCost = 150;

  bool purchaseSpeedBoost() {
    if (zcoins < kSpeedBoostCrystalCost) return false;
    zcoins -= kSpeedBoostCrystalCost;
    const sevenDays = 7 * 24 * 60 * 60 * 1000;
    final base = speedBoostActive
        ? speedBoostExpiryMs
        : DateTime.now().millisecondsSinceEpoch;
    speedBoostExpiryMs = base + sevenDays;
    notifyListeners();
    saveToLocal();
    return true;
  }

  void debugGrantZCoins(int amount) {
    zcoins += amount;
    notifyListeners();
  }

  void debugSkipToFinalBoss() {
    // Set stage to 100 so canPrestige is immediately true (no boss fight needed)
    campaignStageIndex = CampaignData.stages.length;
    while (hero.level < 100) {
      hero.gainExperience(hero.experienceToNextLevel - hero.experience);
    }
    _checkAchievements();
    notifyListeners();
    saveToLocal();
  }

  void debugGrantLevels(int count) {
    for (var i = 0; i < count; i++) {
      if (hero.level >= 100) break;
      hero.gainExperience(hero.experienceToNextLevel - hero.experience);
    }
    _checkAchievements();
    notifyListeners();
    saveToLocal();
  }

  void debugGrantGold(int amount) {
    gold += amount;
    notifyListeners();
  }

  void debugGrantShards(int amount) {
    shards += amount;
    notifyListeners();
  }

  void debugGrantEchoes(int amount) {
    echoes += amount;
    notifyListeners();
  }

  void debugGrantMythril(int amount) {
    mythril += amount;
    notifyListeners();
  }

  void debugGrantEssence(int amount) {
    essence += amount;
    notifyListeners();
  }

  void debugGrantPrestigeSouls(int amount) {
    prestigeSouls += amount;
    notifyListeners();
  }

  // Highest battle-speed tier the player can reach in the campaign. Everyone
  // gets up to 2× (tier 3); the Speed Pass subscription unlocks a permanent
  // 3× (tier 4). Debug builds always allow the fastest tier for testing.
  // Free players cap at 1.5× (tier 2). 2× (tier 3) requires the purchased 2×
  // boost or the Speed Pass subscription; the subscription also unlocks 3×.
  int get maxCampaignSpeedTier {
    if (kDebugMode) return 4;
    if (hasSpeedSub || hasPremium) return 4; // Speed Pass / Premium Pass → up to 3×
    if (speedBoostActive) return 3;          // purchased 2× boost → 2×
    return 2;                                // free → up to 1.5×
  }

  void cycleBattleSpeed() {
    final maxTier = maxCampaignSpeedTier;
    speedTier = speedTier >= maxTier ? 1 : speedTier + 1;
    notifyListeners();
    saveToLocal();
  }

  String get battleSpeedLabel => switch (speedTier) {
    2 => '1.5×',
    3 => kDebugMode ? '5×' : '2×',
    4 => kDebugMode ? '10×' : '3×',
    _ => '1×',
  };

  void setSpeedTier(int tier) {
    speedTier = tier.clamp(1, maxCampaignSpeedTier);
    notifyListeners();
    saveToLocal();
  }

  double get _speedFactor {
    // Clamp to the allowed tier so a saved 2×/3× reverts to free speed once the
    // boost or subscription expires.
    final tier = speedTier.clamp(1, maxCampaignSpeedTier);
    switch (tier) {
      case 2: return 1.5;
      case 3: return kDebugMode ? 5.0 : 2.0;
      case 4: return kDebugMode ? 10.0 : 3.0;
      default: return 1.0;
    }
  }

  int scaledInterval(int baseMs) =>
      (baseMs / _speedFactor).round().clamp(60, baseMs);

  bool purchaseAura(String auraId) {
    final aura = kAuraCatalog.where((a) => a.id == auraId).firstOrNull;
    if (aura == null) return false;
    if (ownedAuraIds.contains(auraId)) return false;
    if (zcoins < aura.zcoinCost) return false;
    zcoins -= aura.zcoinCost;
    ownedAuraIds.add(auraId);
    AnalyticsService.instance.currencySpent('zcoins', aura.zcoinCost, 'aura');
    AnalyticsService.instance.cosmeticUnlocked('aura', auraId);
    _setLastAction('Unlocked ${aura.name} aura!');
    notifyListeners();
    saveToLocal();
    return true;
  }

  void equipAura(String? auraId) {
    equippedAuraId = auraId;
    notifyListeners();
    saveToLocal();
  }

  // ── Palette skins ──────────────────────────────────────────────────────────
  String? equippedSkinId;
  final Set<String> ownedSkinIds = {};

  ColorFilter? get heroSkinFilter {
    if (equippedSkinId == null) return null;
    try {
      return kSkinCatalog.firstWhere((s) => s.id == equippedSkinId).toColorFilter();
    } catch (_) { return null; }
  }

  bool purchaseSkin(String skinId) {
    final skin = kSkinCatalog.where((s) => s.id == skinId).firstOrNull;
    if (skin == null) return false;
    if (ownedSkinIds.contains(skinId)) return false;
    if (zcoins < skin.zcoinCost) return false;
    zcoins -= skin.zcoinCost;
    ownedSkinIds.add(skinId);
    AnalyticsService.instance.currencySpent('zcoins', skin.zcoinCost, 'skin');
    AnalyticsService.instance.cosmeticUnlocked('skin', skinId);
    _setLastAction('Unlocked ${skin.name} skin!');
    notifyListeners();
    saveToLocal();
    return true;
  }

  void equipSkin(String? skinId) {
    equippedSkinId = skinId;
    notifyListeners();
    saveToLocal();
  }

  PaletteSkin? get equippedSkin {
    if (equippedSkinId == null) return null;
    return kSkinCatalog.where((s) => s.id == equippedSkinId).firstOrNull;
  }

  // Bonuses from ALL owned skins stack. The equipped skin only controls the look.
  int _sumOwnedSkinBonus(PetBonusType t) {
    var sum = 0;
    for (final s in kSkinCatalog) {
      if (ownedSkinIds.contains(s.id) && s.bonusType == t) sum += s.bonusValue;
    }
    return sum;
  }

  // ── Premium class skins (real-money, painter-override) ──────────────────────
  final Set<String> ownedPremiumSkinIds = {};
  String? equippedPremiumSkinId;

  /// The premium skin currently shown — only if it matches the hero's class
  /// (owning a premium skin for another class shouldn't render it).
  PremiumSkinDef? get activePremiumSkin {
    final s = premiumSkinById(equippedPremiumSkinId);
    if (s == null) return null;
    if (s.heroClass != hero.heroClass) return null;
    return s;
  }

  bool premiumSkinOwned(String id) => ownedPremiumSkinIds.contains(id);

  /// Grant a premium skin (called on successful real-money purchase).
  void unlockPremiumSkin(String id) {
    if (premiumSkinById(id) == null) return;
    if (ownedPremiumSkinIds.add(id)) {
      // Auto-equip on first unlock if it matches the current class.
      final def = premiumSkinById(id);
      if (def != null && def.heroClass == hero.heroClass) {
        equippedPremiumSkinId = id;
      }
      _setLastAction('Unlocked ${premiumSkinById(id)?.name} premium skin!');
      notifyListeners();
      saveToLocal();
      persistEntitlements();
    }
  }

  void equipPremiumSkin(String? id) {
    equippedPremiumSkinId = id;
    notifyListeners();
    saveToLocal();
  }

  // Premium (real-money) skins grant the COMBINED bonuses of every ZCoin skin
  // in the shop — computed from kSkinCatalog so it always stays in sync.
  int _premiumSkinBonus(PetBonusType t) {
    if (activePremiumSkin == null) return 0;
    var sum = 0;
    for (final s in kSkinCatalog) {
      if (s.bonusType == t) sum += s.bonusValue;
    }
    return sum;
  }

  int get skinGoldPct     => _sumOwnedSkinBonus(PetBonusType.goldPct)     + _premiumSkinBonus(PetBonusType.goldPct);
  int get skinXpPct       => _sumOwnedSkinBonus(PetBonusType.xpPct)       + _premiumSkinBonus(PetBonusType.xpPct);
  int get skinHpRegen     => _sumOwnedSkinBonus(PetBonusType.hpRegen)     + _premiumSkinBonus(PetBonusType.hpRegen);
  int get skinAttackBonus => _sumOwnedSkinBonus(PetBonusType.attackBonus) + _premiumSkinBonus(PetBonusType.attackBonus);
  int get skinArmor       => _sumOwnedSkinBonus(PetBonusType.armor)       + _premiumSkinBonus(PetBonusType.armor);
  int get skinDamage      => _sumOwnedSkinBonus(PetBonusType.damage)      + _premiumSkinBonus(PetBonusType.damage);

  // ── Aura bonuses ───────────────────────────────────────────────────────────

  // Bonuses from ALL owned auras stack. The equipped aura only controls the glow.
  int _sumOwnedAuraBonus(PetBonusType t) {
    var sum = 0;
    for (final a in kAuraCatalog) {
      if (ownedAuraIds.contains(a.id) && a.bonusType == t) sum += a.bonusValue;
    }
    return sum;
  }

  int get auraGoldPct     => _sumOwnedAuraBonus(PetBonusType.goldPct);
  int get auraXpPct       => _sumOwnedAuraBonus(PetBonusType.xpPct);
  int get auraHpRegen     => _sumOwnedAuraBonus(PetBonusType.hpRegen);
  int get auraAttackBonus => _sumOwnedAuraBonus(PetBonusType.attackBonus);
  int get auraArmor       => _sumOwnedAuraBonus(PetBonusType.armor);
  int get auraDamage      => _sumOwnedAuraBonus(PetBonusType.damage);
  int get auraShards      => _sumOwnedAuraBonus(PetBonusType.shardBonus);
  int get auraDodgeChance => _sumOwnedAuraBonus(PetBonusType.dodgeChance);
  int get auraEssenceGain => _sumOwnedAuraBonus(PetBonusType.essenceGain);

  // ── Active set bonuses ─────────────────────────────────────────────────────
  int inventorySetTotal(ItemStat stat) => _setTotal(stat);
  int inventoryGemTotal(ItemStat stat) => _gemTotal(stat);

  /// Total "increased damage %" for [type], mirroring the allDamagePct used in
  /// heroAttack(). External combat modes (Boss Rush, Dungeon) should multiply
  /// their raw damage by (1 + heroAllDamagePctFor(type) / 100).
  /// The EFFECTIVE value of an attribute for combat: its base score plus every
  /// equipped source (gear + set bonuses + gems). Combat already scales
  /// resistance, dodge, DoT, HoT and CD-skip off this total, so an item's +STR
  /// fully raises the stat. Exposed so the Hero sheet can show the same number.
  int effectiveAttr(int base, ItemStat stat) =>
      base + inventory.totalOf(stat) + _setTotal(stat) + _gemTotal(stat);

  /// The base score + matching gear ItemStat for a damage type's attribute.
  (int, ItemStat) _attrFor(DamageType type) => switch (type) {
    DamageType.physical  => (hero.strength,     ItemStat.strength),
    DamageType.lightning => (hero.dexterity,    ItemStat.dexterity),
    DamageType.poison    => (hero.constitution,  ItemStat.constitution),
    DamageType.void_     => (hero.intelligence,  ItemStat.intelligence),
    DamageType.cold      => (hero.wisdom,        ItemStat.wisdom),
    DamageType.fire      => (hero.charisma,      ItemStat.charisma),
  };

  /// Attribute-driven damage % for [type] — counts the EFFECTIVE attribute
  /// (base + gear + sets + gems), matching resistance/dodge/DoT/HoT/CD-skip so
  /// an item's +STR/+DEX fully raises the damage bonus. Replaces the base-only
  /// [HeroModel.damagePctFor] in the damage aggregators.
  int attrDamagePctFor(DamageType type) {
    final (base, stat) = _attrFor(type);
    return effectiveAttr(base, stat) * 25 ~/ 100;
  }

  double heroAllDamagePctFor(DamageType type) =>
      passiveTree.totalOf(PassiveEffect.allDamage).toDouble()
      + passiveElemDamagePct(type)
      + gemElemDamagePct(type)
      + inventory.totalOf(ItemStat.damagePercent)
      + _setTotal(ItemStat.damagePercent)
      + hero.levelBonusDamagePct
      + allyDmgPctBonus
      + attrDamagePctFor(type)
      + elementalMasteryDamagePct(type);

  /// Total flat damage added per hit, mirroring baseDmg in heroAttack().
  /// Does not include the weapon die roll or crit multiplier.
  int get heroFlatDmgBonus =>
      hero.baseDmg
      + passiveTree.totalOf(PassiveEffect.damageFlat)
      + inventory.totalOf(ItemStat.damageBonus)
      + inventory.totalOf(ItemStat.strength)
      + petDamage + skinDamage + auraDamage
      + _setTotal(ItemStat.damageBonus)
      + _setTotal(ItemStat.strength)
      + _gemTotal(ItemStat.damageBonus)
      + _gemTotal(ItemStat.strength)
      + _masteryTotal(MasteryEffect.flatDamagePerHit)
      + _masteryTotal(MasteryEffect.permanentDamage)
      + questDamageBonus + artifactPowerBonus + ascDmgBonus
      + runeDmgBonus;

  int _setTotal(ItemStat stat) {
    var total = 0;
    for (final set in kSetCatalog) {
      final count = inventory.setCount(set.id);
      if (count < 2) continue;
      // Find the highest tier that is currently active
      SetBonus? activeTier;
      for (final tier in set.tiers) {
        if (count >= tier.piecesRequired) activeTier = tier;
      }
      if (activeTier == null) continue;
      for (final bonus in activeTier.bonuses) {
        if (bonus.stat == stat) total += bonus.value;
      }
    }
    return total;
  }

  List<(ItemSet, SetBonus)> get activeSets {
    final result = <(ItemSet, SetBonus)>[];
    for (final set in kSetCatalog) {
      final count = inventory.setCount(set.id);
      if (count < 2) continue;
      SetBonus? activeTier;
      for (final tier in set.tiers) {
        if (count >= tier.piecesRequired) activeTier = tier;
      }
      if (activeTier != null) result.add((set, activeTier));
    }
    return result;
  }

  // ── Pets ───────────────────────────────────────────────────────────────────
  String? equippedPetId;
  final Set<String> ownedPetIds = {};

  PetDefinition? get equippedPet {
    if (equippedPetId == null) return null;
    return kPetCatalog.where((p) => p.id == equippedPetId).firstOrNull;
  }

  // Sums the bonus of a given type across every owned pet (passive on all, not just equipped).
  int _sumOwnedPetBonus(PetBonusType type) {
    var total = 0;
    for (final id in ownedPetIds) {
      final p = kPetCatalog.where((p) => p.id == id).firstOrNull;
      if (p == null) continue;
      // Omni pets (e.g. the premium dragon) grant every listed bonus type.
      if (p.omniBonuses != null) {
        final v = p.omniBonuses![type];
        if (v != null) total += _evolvedPetBonus(v, p.id);
      } else if (p.bonusType == type) {
        total += _evolvedPetBonus(p.bonusValue, p.id);
      }
    }
    return total;
  }

  int get petGoldPct     => _sumOwnedPetBonus(PetBonusType.goldPct);
  int get petXpPct       => _sumOwnedPetBonus(PetBonusType.xpPct);
  int get petHpRegen     => _sumOwnedPetBonus(PetBonusType.hpRegen);
  int get petIdleRate    => _sumOwnedPetBonus(PetBonusType.idleRate);
  int get petAttackBonus => _sumOwnedPetBonus(PetBonusType.attackBonus);
  int get petArmor       => _sumOwnedPetBonus(PetBonusType.armor);
  int get petDamage      => _sumOwnedPetBonus(PetBonusType.damage);
  int get petShards      => _sumOwnedPetBonus(PetBonusType.shardBonus);
  int get petDodgeChance => _sumOwnedPetBonus(PetBonusType.dodgeChance);
  int get petEssenceGain => _sumOwnedPetBonus(PetBonusType.essenceGain);

  bool purchasePet(String petId) {
    final pet = kPetCatalog.where((p) => p.id == petId).firstOrNull;
    if (pet == null) return false;
    if (pet.isPremium) return false; // premium pets are real-money only (IAP)
    if (ownedPetIds.contains(petId)) return false;
    if (zcoins < pet.zcoinCost) return false;
    zcoins -= pet.zcoinCost;
    ownedPetIds.add(petId);
    _setLastAction('${pet.emoji} ${pet.name} joined your party!');
    notifyListeners();
    saveToLocal();
    return true;
  }

  /// Grant a premium (real-money) pet after its IAP completes. Auto-equips it.
  void unlockPremiumPet(String productId) {
    final pet = kPetCatalog.where((p) => p.productId == productId).firstOrNull;
    if (pet == null) return;
    if (ownedPetIds.add(pet.id)) {
      AnalyticsService.instance.cosmeticUnlocked('pet_rm', pet.id);
    }
    equippedPetId = pet.id;
    _setLastAction('${pet.emoji} ${pet.name} joined your party!');
    notifyListeners();
    saveToLocal();
    persistEntitlements();
  }

  void equipPet(String? petId) {
    equippedPetId = petId;
    notifyListeners();
    saveToLocal();
  }

  // ── PVP ────────────────────────────────────────────────────────────────────
  static const int pvpMaxStamina          = 5;
  static const Duration pvpRechargeInterval = Duration(minutes: 45);

  int pvpStamina        = pvpMaxStamina;
  int pvpRating         = 1000;

  // ── Ability Proficiency (scale with use) ─────────────────────────────────────
  Map<String, int> abilityUseCounts = {};

  void trackAbilityUse(String abilityId) {
    abilityUseCounts[abilityId] = (abilityUseCounts[abilityId] ?? 0) + 1;
  }

  int abilityProficiency(String abilityId) {
    final uses = abilityUseCounts[abilityId] ?? 0;
    if (uses >= 200) return 3;
    if (uses >= 100) return 2;
    if (uses >= 50) return 1;
    return 0;
  }

  double abilityProfMult(String abilityId) => 1.0 + abilityProficiency(abilityId) * 0.10;

  String abilityProfLabel(String abilityId) => switch (abilityProficiency(abilityId)) {
    1 => 'I',
    2 => 'II',
    3 => 'III',
    _ => '',
  };

  // ── Combo System ───────────────────────────────────────────────────────────
  List<String> _recentAbilities = [];
  String? activeCombo;
  int comboBonus = 0;

  static const _combos = <String, (List<String>, int, String)>{
    'shatter':  (['stun', 'dot', 'bonusDamage'],    50, 'Shatter Combo — +50% damage'),
    'fortress': (['acBonus', 'heal', 'aura'],        30, 'Fortress Combo — +30% armor'),
    'execute':  (['debuffWeaken', 'debuffVulnerable', 'bonusDamage'], 75, 'Execute Combo — +75% damage'),
    'drain':    (['dot', 'heal', 'bonusDamage'],     40, 'Drain Combo — +40% lifesteal'),
    'blitz':    (['attackBonus', 'bonusDamage', 'bonusDamage'], 60, 'Blitz Combo — +60% damage'),
  };

  void checkCombo(String effectName) {
    _recentAbilities.add(effectName);
    if (_recentAbilities.length > 3) _recentAbilities.removeAt(0);
    activeCombo = null;
    comboBonus = 0;
    for (final entry in _combos.entries) {
      final pattern = entry.value.$1;
      if (_recentAbilities.length >= pattern.length) {
        final tail = _recentAbilities.sublist(_recentAbilities.length - pattern.length);
        if (_listEquals(tail, pattern)) {
          activeCombo = entry.value.$3;
          comboBonus = entry.value.$2;
          _recentAbilities.clear();
          return;
        }
      }
    }
  }

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void resetCombo() {
    _recentAbilities.clear();
    activeCombo = null;
    comboBonus = 0;
  }

  // ── Passive Triggers (auto-cast at HP thresholds) ──────────────────────────
  Map<String, double> abilityAutoTriggers = {};

  void setAutoTrigger(String abilityId, double hpThreshold) {
    if (hpThreshold <= 0) {
      abilityAutoTriggers.remove(abilityId);
    } else {
      abilityAutoTriggers[abilityId] = hpThreshold.clamp(0.1, 0.5);
    }
    notifyListeners();
    saveToLocal();
  }

  String? checkAutoTrigger() {
    if (hero.maxHealth <= 0) return null;
    final hpRatio = hero.currentHealth / hero.maxHealth;
    for (final entry in abilityAutoTriggers.entries) {
      if (hpRatio <= entry.value && cooldownRemaining(entry.key) == 0) {
        return entry.key;
      }
    }
    return null;
  }

  // ── Element Mastery Bonuses (milestone element combos) ──────────────────────
  Map<String, double> get elementMasteryBonuses {
    final typeCounts = <String, int>{};
    for (final choice in _milestoneChoices.values) {
      final key = choice.contains('fire') ? 'fire'
          : choice.contains('cold') ? 'cold'
          : choice.contains('lightning') ? 'lightning'
          : choice.contains('poison') ? 'poison'
          : choice.contains('void') ? 'void'
          : 'physical';
      typeCounts[key] = (typeCounts[key] ?? 0) + 1;
    }
    final bonuses = <String, double>{};
    for (final entry in typeCounts.entries) {
      if (entry.value >= 3) {
        bonuses['${entry.key}Mastery'] = 0.15;
      }
      if (entry.value >= 5) {
        bonuses['${entry.key}Mastery'] = 0.30;
      }
    }
    return bonuses;
  }

  String get elementMasteryLabel {
    final s = elementMasteryBonuses;
    if (s.isEmpty) return '';
    return s.entries.map((e) {
      final name = e.key.replaceAll('Mastery', '').toUpperCase();
      return '$name Mastery +${(e.value * 100).round()}%';
    }).join('  •  ');
  }

  // ── Difficulty Tiers ──────────────────────────────────────────────────────
  // The core meta-progression. [highestUnlockedTier] is raised by CLEARING the
  // campaign (defeating the final boss) at your current tier — no rebirth/reset.
  // [activeTier] is freely switchable up to your highest unlocked; switching
  // DOWN keeps all permanent power but scales enemies AND loot down. Higher
  // tiers = tougher PvE + better loot. PvP / Guild ignore tier.
  static const int kMaxTier = 10;

  // Defensive ratings — dodge and armor use diminishing-returns curves that
  // asymptote toward [kDefenseCapPct], so stacked sources can never reach
  // immunity. Each additional point of rating is worth progressively less.
  // %-benefit = kDefenseCapPct * rating / (rating + K).
  static const double kDefenseCapPct = 37.5;
  static const double kDodgeRatingK  = 50;   // dodge rating that yields half the cap
  static const double kArmorRatingK  = 100;  // armor rating that yields half the cap
  // Elemental resistance is its own rating: same diminishing-returns curve but a
  // higher cap (75%). Reaching the cap is deliberately expensive — at the K
  // below you get half the cap (37.5%) and each further point is worth less, so
  // late-game 75% is asymptotic. Flat sources (stats, passives) add rating;
  // mastery + gems boost the rating by a %.
  static const double kResistCapPct  = 90.0; // aligns with the 90% max-damage-reduction floor
  static const double kResistRatingK = 50.0; // resist rating that yields half the cap
  // Total lifesteal healing per round is capped at this % of max HP. Without it,
  // endgame damage (billions) dwarfs the HP pool, so even ~1% lifesteal
  // full-heals every hit — the real "hero never drops below full" sustain hole.
  static const double kLifestealMaxPctPerRound = 4.0;
  // Global HP-recovery scalar. Multiplies ALL healing (ability heals, HoT auras,
  // merc triage). Combined with the lower lifesteal cap and bigger HP pool, this
  // makes HP a resource that's slowly ground down rather than instantly topped
  // off — so incoming damage actually sticks and the endgame stays threatening.
  static const double kRecoveryMult = 0.4;
  // Heal Rating system: ALL healing is now a multiple of Heal Rating, decoupled
  // from max HP (which caused endless out-healing). A heal's design value (its
  // old "% of HP" number, e.g. Healing Ward 28) becomes a Heal-Rating multiplier
  // of value / kHealValuePerMult — so 28 ≈ 3× Heal Rating, matching the example.
  // Lower this to make every heal stronger; raise to weaken. Kept above the
  // damage curve's growth so healing stays "always partial" at the endgame.
  static const double kHealValuePerMult = 30.0;
  // Hard ceiling on a SINGLE heal's multiplier: no heal exceeds this × Heal
  // Rating (× its factor). Heal values span 8→100; without this a value-100 aura
  // healed ~3× a normal heal. 0.4 keeps even the biggest heal a partial top-up.
  static const double kHealMaxMult = 0.25;
  // Total chance to FULLY avoid an incoming hit (dodge + Shadow Step + Void Step
  // + enemy miss-chance combined), capped so the enemy always lands a meaningful
  // share. These were independent rolls that multiplied to near-total avoidance —
  // telemetry showed a hero taking 0 damage over a 14-round boss fight.
  static const double kMaxAvoidChance = 0.60;
  // Cooldown reduction is a rare, premium bonus — the total rounds any build can
  // shave off an ability's cooldown is hard-capped, so abilities are never spammed.
  static const int kMaxCooldownReduction = 2;
  int activeTier = 0;

  /// The highest difficulty tier the player has unlocked. Persisted; raised by
  /// clearing the campaign at your current highest tier (see the final-boss
  /// handler). Seeded from legacy prestigeLevel on first migration.
  int highestUnlockedTier = 0;

  /// Switch the active difficulty tier. Clamped to [0, highestUnlockedTier].
  /// Recalculates immediately (enemies/loot for the next encounter use it).
  void setActiveTier(int tier) {
    final clamped = tier.clamp(0, highestUnlockedTier);
    if (clamped == activeTier) return;
    // Each tier keeps its own campaign progress: stash the tier we're leaving,
    // then resume the target tier (or start it fresh if never played).
    _campaignStageByTier[activeTier] = campaignStageIndex;
    activeTier = clamped;
    campaignStageIndex = (_campaignStageByTier[clamped] ?? prestigeHeadStart)
        .clamp(0, CampaignData.stages.length - 1);
    notifyListeners();
    saveToLocal();
  }

  /// Unified difficulty-tier reward multiplier — ONE curve for every mode, so
  /// rewards scale with the tier you actually play (rebirths are retired; there
  /// is no separate max-tier bonus). Accelerating, so higher tiers are
  /// disproportionately more rewarding and pushing pays off:
  ///   tier 0 = 1.0×  ·  tier 5 ≈ 6×  ·  tier 10 = 16×.
  /// [tier] is 0-based (the global activeTier); defaults to the active tier.
  double tierRewardMult([int? tier]) {
    final t = (tier ?? activeTier).clamp(0, kMaxTier);
    return 1.0 + t * 0.5 + t * t * 0.10;
  }

  /// Set when the final boss is cleared and a new tier unlocks — the UI reads
  /// this to show the "Tier N Unlocked" celebration, then clears it.
  int lastTierUnlocked = 0;

  // Paragon-per-level: every hero level grants 1 Paragon Point (a prestige Soul,
  // the currency the Paragon board already spends). We track the highest level
  // already rewarded so only the delta is granted, and never retroactively dump
  // points on existing saves (seeded to current level on migration).
  int _paragonLevelsGranted = 0;
  void _syncParagonLevels() {
    if (hero.level > _paragonLevelsGranted) {
      prestigeSouls += hero.level - _paragonLevelsGranted;
      _paragonLevelsGranted = hero.level;
    }
  }

  Set<int> stageStars = {}; // stores "stage_star" encoded as stage*10+star(1-3)

  int starsForStage(int stage) {
    int count = 0;
    for (int s = 1; s <= 3; s++) {
      if (stageStars.contains(stage * 10 + s)) count++;
    }
    return count;
  }

  // Tracks stages where the 3-star completion bonus has already been auto-granted
  final Set<int> _claimedStageStarRewards = {};
  // Tracks which total-3-star-count milestones have been granted
  final Set<int> _claimedStarMilestones = {};

  int get totalThreeStarStages =>
      stageStars.map((k) => k ~/ 10).toSet()
          .where((s) => starsForStage(s) == 3)
          .length;

  void awardStar(int stage, int star) {
    final key = stage * 10 + star;
    if (!stageStars.contains(key)) {
      stageStars.add(key);
      addSeasonXp(15);
      // Auto-grant 3-star bonus the first time all 3 stars are earned
      if (star == 3 && !_claimedStageStarRewards.contains(stage)) {
        _claimedStageStarRewards.add(stage);
        mythril += 1;
        gold    += 200;
        shards  += 5;
        battleLog.add('★★★ Perfect clear! +1 mythril  +200 gold  +5 shards');
        _checkStarMilestones();
      }
    }
  }

  void _checkStarMilestones() {
    const milestones = {
      10:  (mythril: 5,  zcoins: 30,  title: null as String?),
      25:  (mythril: 10, zcoins: 75,  title: null as String?),
      50:  (mythril: 20, zcoins: 150, title: 'Perfect Campaigner'),
      100: (mythril: 40, zcoins: 400, title: 'Flawless Warden'),
    };
    final total = totalThreeStarStages;
    for (final entry in milestones.entries) {
      if (total >= entry.key && !_claimedStarMilestones.contains(entry.key)) {
        _claimedStarMilestones.add(entry.key);
        mythril += entry.value.mythril;
        zcoins  += entry.value.zcoins;
        if (entry.value.title != null) heroTitle = entry.value.title;
        battleLog.add('★ Star Milestone: ${entry.key} perfect stages! '
            '+${entry.value.mythril} mythril  +${entry.value.zcoins} Z-Coins'
            '${entry.value.title != null ? "  ✦ Title: ${entry.value.title}" : ""}');
      }
    }
  }

  // Star 1: Win the battle (auto)
  // Star 2: Win with >50% HP remaining
  // Star 3: Win in under 10 turns
  void checkBattleStars(int stage, int turnsUsed) {
    awardStar(stage, 1);
    if (hero.currentHealth > hero.maxHealth ~/ 2) awardStar(stage, 2);
    if (turnsUsed <= 10) awardStar(stage, 3);
  }

  // Endless milestones + personal best
  int endlessPersonalBest = 0;

  Map<String, int>? checkEndlessMilestone(int stage) {
    if (stage > endlessPersonalBest) endlessPersonalBest = stage;
    // Rune drop every 10 endless stages
    if (stage > 0 && stage % 10 == 0) rollRuneDrop(guaranteed: true);
    if (stage > 0 && stage % 10 == 0) {
      final tier = stage ~/ 10;
      return {
        'gold': 2000 * tier,
        'echoes': 20 * tier,
        'shards': 15 * tier,
        if (tier >= 3) 'zcoins': 5 * tier,
        if (tier >= 5) 'mythril': 2 * tier,
      };
    }
    return null;
  }

  // Dungeon affixes
  static const dungeonAffixes = ['burning', 'frozen', 'cursed', 'toxic', 'arcane'];
  String? activeDungeonAffix;
  bool dungeonMiniBossDefeated = false;

  String rollDungeonAffix() {
    activeDungeonAffix = dungeonAffixes[_rng.nextInt(dungeonAffixes.length)];
    dungeonMiniBossDefeated = false;
    return activeDungeonAffix!;
  }

  static const affixRerollCost = 5;
  static const shrineBlissCost = 3;

  bool get canRerollDungeonAffix => mythril >= affixRerollCost && activeDungeon == null;

  void rerollDungeonAffix() {
    if (!canRerollDungeonAffix) return;
    mythril -= affixRerollCost;
    rollDungeonAffix();
    notifyListeners();
  }

  ShrineEffect? spendMythrilForShrineBless(DungeonRun run) {
    if (mythril < shrineBlissCost) return null;
    mythril -= shrineBlissCost;
    final blessings = ShrineEffect.pool.where((e) => !e.isCurse).toList();
    if (blessings.isEmpty) return null;
    final effect = blessings[_rng.nextInt(blessings.length)];
    run.shrineEffects.add(effect);
    if (effect.hpPctMod != 0) {
      final hpChange = (run.heroMaxHp * effect.hpPctMod).round();
      run.heroHp = (run.heroHp + hpChange).clamp(1, run.heroMaxHp);
    }
    notifyListeners();
    return effect;
  }

  /// Returns the purchased item on success, null on failure (insufficient gold / no active run).
  DungeonMerchantItem? buyDungeonMerchantItem(String itemId) {
    final run = activeDungeon;
    if (run == null) return null;
    final stock = DungeonMerchantItem.stockForTier(run.tier, run.floor);
    DungeonMerchantItem? item;
    for (final m in stock) {
      if (m.id == itemId) { item = m; break; }
    }
    if (item == null || run.bones < item.boneCost) return null;

    run.bones -= item.boneCost;
    if (item.effect != null) run.shrineEffects.add(item.effect!);
    if (item.instantHealPct > 0) {
      final heal = (run.heroMaxHp * item.instantHealPct).round();
      run.heroHp = (run.heroHp + heal).clamp(0, run.heroMaxHp);
    }
    notifyListeners();
    return item;
  }

  String get dungeonAffixLabel => switch (activeDungeonAffix) {
    'burning'  => '🔥 Burning — enemies deal fire DoT',
    'frozen'   => '❄ Frozen — enemies have +20% HP',
    'cursed'   => '💀 Cursed — healing reduced by 50%',
    'toxic'    => '☠ Toxic — poison ticks each floor',
    'arcane'   => '✦ Arcane — enemies resist first 50 damage',
    _          => 'Normal',
  };

  double get dungeonAffixHpMult => activeDungeonAffix == 'frozen' ? 1.2 : 1.0;
  double get dungeonAffixHealMult => activeDungeonAffix == 'cursed' ? 0.5 : 1.0;

  /// Burning: fire DoT the hero takes at the end of every combat round.
  int dungeonAffixBurnTick(int heroMaxHp) =>
      activeDungeonAffix == 'burning' ? max(1, (heroMaxHp * 0.015).round()) : 0;

  /// Arcane: enemies absorb the first N damage dealt to them each fight.
  int get dungeonAffixEnemyShield => activeDungeonAffix == 'arcane' ? 50 : 0;

  /// Toxic: poison tick when descending to a new floor (can't kill).
  void applyDungeonToxicTick(DungeonRun run) {
    if (activeDungeonAffix != 'toxic') return;
    final tick = max(1, (run.heroMaxHp * 0.02).round());
    run.heroHp = (run.heroHp - tick).clamp(1, run.heroMaxHp);
  }

  // Gauntlet modifier tiers
  Map<String, int> gauntletModTiers = {};

  void tierUpGauntletMod(String modId) {
    gauntletModTiers[modId] = (gauntletModTiers[modId] ?? 0) + 1;
  }

  int gauntletModTier(String modId) => gauntletModTiers[modId] ?? 0;
  double gauntletModDifficulty(String modId) => 1.0 + gauntletModTier(modId) * 0.25;
  double gauntletModRewardMult(String modId) => 1.0 + gauntletModTier(modId) * 0.15;

  bool gauntletEndlessUnlocked = false;

  void unlockEndlessGauntlet() {
    if (_gauntletAttemptsUsed >= 3 && !gauntletEndlessUnlocked) {
      gauntletEndlessUnlocked = true;
      notifyListeners();
    }
  }

  // Boss Rush phases + timed challenge
  int bossRushTimerStart = 0;
  bool bossRushTimedMode = false;

  void startBossRushTimer() {
    bossRushTimerStart = DateTime.now().millisecondsSinceEpoch;
    bossRushTimedMode = true;
  }

  int get bossRushElapsedSeconds => bossRushTimedMode
      ? ((DateTime.now().millisecondsSinceEpoch - bossRushTimerStart) / 1000).round()
      : 0;

  Map<String, int> bossRushTimedBonus() {
    final secs = bossRushElapsedSeconds;
    if (!bossRushTimedMode || secs <= 0) return {};
    // Under 60s = 3x, under 120s = 2x, under 180s = 1.5x
    final mult = secs < 60 ? 3.0 : secs < 120 ? 2.0 : secs < 180 ? 1.5 : 1.0;
    if (mult <= 1.0) return {};
    final bonus = ((mult - 1.0) * 10).round();
    return {'mythril': bonus, 'zcoins': bonus * 2};
  }

  // Expedition critical success + rare events
  static const _rareExpeditions = [
    'Ancient Vault — 3× rewards',
    'Dragon Hoard — massive gold bonus',
    'Forgotten Shrine — rare essence cache',
    'Crystal Cavern — bonus zcoins',
  ];

  bool rollCriticalSuccess() => _rng.nextInt(5) == 0; // 20% chance
  String? rollRareExpedition() => _rng.nextInt(8) == 0 // 12.5% chance
      ? _rareExpeditions[_rng.nextInt(_rareExpeditions.length)]
      : null;

  // Guild
  String? guildId;
  int guildCoins = 0;
  // Resolved guild-castle buffs — populated when the guild is loaded (guild
  // screen). Gameplay reads this, never CastleState.tier. Default = no bonus.
  GuildBuffs guildBuffs = const GuildBuffs();
  void setGuildBuffs(GuildBuffs b) {
    guildBuffs = b;
    notifyListeners();
  }
  /// Castle gold multiplier (1.0 = none). Includes the +5% all-resource bonus.
  double get guildCastleGoldMult => 1.0 + guildBuffs.effectiveGoldPct / 100.0;

  // Season Pass
  int seasonPassXp = 0;
  int seasonPassTier = 0;
  Set<int> seasonFreeClaimed = {};
  Set<int> seasonPremiumClaimed = {};
  int seasonMonth = 0; // tracks which month this data belongs to

  // XP required to reach the next tier (0 once every tier is maxed).
  int get seasonNextTierXp => seasonPassTier < SeasonPassTier.tiers.length
      ? SeasonPassTier.tiers[seasonPassTier].xpRequired
      : 0;
  // Progress into the current tier, 0..1.
  double get seasonTierProgress =>
      seasonNextTierXp > 0 ? (seasonPassXp / seasonNextTierXp).clamp(0.0, 1.0) : 1.0;
  // Number of reward tiers ready to claim on either track.
  int get seasonUnclaimedCount {
    var n = 0;
    for (var t = 1; t <= seasonPassTier; t++) {
      if (!seasonFreeClaimed.contains(t)) n++;
      if (hasPremium && !seasonPremiumClaimed.contains(t)) n++;
    }
    return n;
  }

  void addSeasonXp(int xp) {
    if (hasPremium) xp *= 2; // Premium Pass perk: 2× Season Pass XP
    seasonPassXp += xp;
    while (seasonPassTier < SeasonPassTier.tiers.length &&
        seasonPassXp >= SeasonPassTier.tiers[seasonPassTier].xpRequired) {
      seasonPassXp -= SeasonPassTier.tiers[seasonPassTier].xpRequired;
      seasonPassTier++;
    }
    notifyListeners();
  }

  bool claimSeasonFree(int tier) {
    if (tier > seasonPassTier || seasonFreeClaimed.contains(tier)) return false;
    final t = SeasonPassTier.tiers[tier - 1];
    _applyRewards(t.freeRewards);
    seasonFreeClaimed.add(tier);
    notifyListeners();
    saveToLocal();
    return true;
  }

  bool claimSeasonPremium(int tier) {
    // Premium track is a Premium Pass perk — requires an active subscription.
    if (!hasPremium) return false;
    if (tier > seasonPassTier || seasonPremiumClaimed.contains(tier)) return false;
    final t = SeasonPassTier.tiers[tier - 1];
    _applyRewards(t.premiumRewards);
    seasonPremiumClaimed.add(tier);
    notifyListeners();
    saveToLocal();
    return true;
  }

  // Claim every reward currently available on both tracks. Returns the count claimed.
  int claimAllSeason() {
    var n = 0;
    for (var t = 1; t <= seasonPassTier; t++) {
      if (claimSeasonFree(t)) n++;
      if (claimSeasonPremium(t)) n++;
    }
    return n;
  }

  void _checkSeasonReset() {
    final now = DateTime.now();
    final month = now.year * 12 + now.month;
    if (seasonMonth != 0 && seasonMonth != month) {
      seasonPassXp = 0;
      seasonPassTier = 0;
      seasonFreeClaimed.clear();
      seasonPremiumClaimed.clear();
    }
    seasonMonth = month;
  }

  // Weekly Challenges
  List<WeeklyChallenge> weeklyChallenges = [];
  int _weeklyWeekSeed = 0;

  void _checkWeeklyReset() {
    final now = DateTime.now();
    final seed = now.year * 100 + (now.day ~/ 7);
    if (seed != _weeklyWeekSeed) {
      _weeklyWeekSeed = seed;
      weeklyChallenges = WeeklyChallenge.generateForWeek(seed);
    }
  }

  void advanceWeekly(String id, int amount) {
    for (final c in weeklyChallenges) {
      if (c.id == id && !c.claimed) {
        c.progress = (c.progress + amount).clamp(0, c.target);
      }
    }
  }

  void claimWeekly(String id) {
    for (final c in weeklyChallenges) {
      if (c.id == id && getWeeklyProgress(c) >= c.target && !c.claimed) {
        _applyRewards(c.rewards);
        c.claimed = true;
        addSeasonXp(50);
        notifyListeners();
        saveToLocal();
        return;
      }
    }
  }

  int getWeeklyProgress(WeeklyChallenge c) => switch (c.id) {
    'w_gold' => gold,
    _ => c.progress,
  };

  bool get hasClaimableWeekly => weeklyChallenges.any(
      (c) => !c.claimed && getWeeklyProgress(c) >= c.target);

  void claimAllWeeklies() {
    for (final c in weeklyChallenges) {
      if (!c.claimed && getWeeklyProgress(c) >= c.target) {
        _applyRewards(c.rewards);
        c.claimed = true;
        addSeasonXp(50);
      }
    }
    notifyListeners();
    saveToLocal();
  }

  // Comeback Bonus
  int _lastLoginEpochMs = 0;
  Map<String, int>? pendingComebackRewards;

  void _checkComebackBonus() {
    if (_lastLoginEpochMs == 0) {
      _lastLoginEpochMs = DateTime.now().millisecondsSinceEpoch;
      return;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    final daysMissed = ((now - _lastLoginEpochMs) / (24 * 60 * 60 * 1000)).floor();
    _lastLoginEpochMs = now;
    if (daysMissed >= 3) {
      final scale = daysMissed.clamp(3, 14);
      pendingComebackRewards = {
        'gold': 1000 * scale,
        'shards': 10 * scale,
        'echoes': 5 * scale,
        'zcoins': 3 * scale,
        'essence': 20 * scale,
      };
    }
  }

  void claimComebackBonus() {
    if (pendingComebackRewards == null) return;
    _applyRewards(pendingComebackRewards!);
    pendingComebackRewards = null;
    notifyListeners();
    saveToLocal();
  }

  // Flash Events
  ActiveFlashEvent? activeFlashEvent;

  void _checkFlashEvent() {
    if (activeFlashEvent != null && activeFlashEvent!.isActive) return;
    activeFlashEvent = null;
    final now = DateTime.now();
    final event = FlashEvent.checkForEvent(now.hour, now.weekday);
    if (event != null) {
      activeFlashEvent = ActiveFlashEvent(
        event: event,
        startEpoch: now.millisecondsSinceEpoch,
      );
    }
  }

  double flashMultiplier(String bonusType) {
    if (activeFlashEvent == null || !activeFlashEvent!.isActive) return 1.0;
    if (activeFlashEvent!.event.bonusType == bonusType) return activeFlashEvent!.event.bonus;
    return 1.0;
  }

  // Collection Log
  Set<String> collectedItemNames = {};
  Set<String> defeatedEnemyIds = {};

  void logItem(String name) => collectedItemNames.add(name);
  void logEnemy(String id) => defeatedEnemyIds.add(id);

  int get collectionTotalItems => collectedItemNames.length;
  int get collectionTotalEnemies => defeatedEnemyIds.length;

  // Shared reward applicator
  void _applyRewards(Map<String, int> rewards) {
    for (final e in rewards.entries) {
      switch (e.key) {
        case 'gold':      gold += e.value;
        case 'shards':    shards += e.value;
        case 'zcoins':  zcoins += e.value;
        case 'echoes':    echoes += e.value;
        case 'essence':   essence += e.value;
        case 'mythril':   mythril += e.value;
        case 'gemShards': gemShards += e.value;
        case 'guildCoins': guildCoins += e.value;
      }
    }
  }

  // Milestones
  Set<String> claimedMilestones = {};
  String? pendingMilestone;

  void checkMilestones() {
    final checks = <String, bool>{
      'level_10': hero.level >= 10,
      'level_25': hero.level >= 25,
      'level_50': hero.level >= 50,
      'level_100': hero.level >= 100,
      'first_rebirth': highestUnlockedTier >= 1,
      'kills_100': _totalKills >= 100,
      'kills_1000': _totalKills >= 1000,
      'pvp_10_wins': pvpWins >= 10,
      'pvp_50_wins': pvpWins >= 50,
      'stage_25': campaignStageIndex >= 25,
      'stage_50': campaignStageIndex >= 50,
      'stage_100': campaignStageIndex >= 100,
      'dungeon_10': _deepestDungeonFloor >= 10,
      'guild_joined': guildId != null,
    };
    for (final e in checks.entries) {
      if (e.value && !claimedMilestones.contains(e.key)) {
        pendingMilestone = e.key;
        return;
      }
    }
  }

  void dismissMilestone() {
    if (pendingMilestone != null) {
      claimedMilestones.add(pendingMilestone!);
      pendingMilestone = null;
      saveToLocal();
    }
  }

  static String milestoneLabel(String id) => switch (id) {
    'level_10' => '🎉 LEVEL 10 — The journey begins!',
    'level_25' => '⚔ LEVEL 25 — Seasoned adventurer!',
    'level_50' => '🔥 LEVEL 50 — True warrior!',
    'level_100' => '👑 LEVEL 100 — Legendary hero!',
    'first_rebirth' => '✦ FIRST REBIRTH — Transcended!',
    'kills_100' => '💀 100 KILLS — Monster slayer!',
    'kills_1000' => '☠ 1000 KILLS — Death incarnate!',
    'pvp_10_wins' => '⚔ 10 PVP WINS — Arena contender!',
    'pvp_50_wins' => '🏆 50 PVP WINS — Arena champion!',
    'stage_25' => '🗺 STAGE 25 — Explorer!',
    'stage_50' => '🗺 STAGE 50 — Pathfinder!',
    'stage_100' => '🗺 STAGE 100 — World conqueror!',
    'dungeon_10' => '🏰 DUNGEON FLOOR 10 — Delver!',
    'guild_joined' => '🏰 GUILD MEMBER — Strength in unity!',
    _ => '🎉 MILESTONE REACHED!',
  };

  static Map<String, int> milestoneRewards(String id) => switch (id) {
    'level_10' => {'gold': 500, 'shards': 20},
    'level_25' => {'gold': 2000, 'shards': 50, 'zcoins': 10},
    'level_50' => {'gold': 5000, 'echoes': 100, 'zcoins': 25},
    'level_100' => {'gold': 10000, 'echoes': 200, 'zcoins': 50, 'mythril': 10},
    'first_rebirth' => {'zcoins': 100, 'mythril': 20, 'echoes': 300},
    'kills_100' => {'gold': 1000, 'shards': 30},
    'kills_1000' => {'gold': 5000, 'echoes': 50, 'zcoins': 15},
    'pvp_10_wins' => {'gemShards': 50, 'echoes': 50},
    'pvp_50_wins' => {'gemShards': 150, 'zcoins': 30, 'echoes': 100},
    'stage_25' => {'gold': 3000, 'shards': 50},
    'stage_50' => {'gold': 8000, 'echoes': 75, 'zcoins': 20},
    'stage_100' => {'gold': 20000, 'echoes': 200, 'zcoins': 50},
    'dungeon_10' => {'essence': 200, 'shards': 80},
    'guild_joined' => {'guildCoins': 50, 'gold': 2000},
    _ => {'gold': 500},
  };

  void claimMilestoneRewards(String id) {
    final rewards = milestoneRewards(id);
    if (rewards.containsKey('gold')) gold += rewards['gold']!;
    if (rewards.containsKey('shards')) shards += rewards['shards']!;
    if (rewards.containsKey('zcoins')) zcoins += rewards['zcoins']!;
    if (rewards.containsKey('echoes')) echoes += rewards['echoes']!;
    if (rewards.containsKey('mythril')) mythril += rewards['mythril']!;
    if (rewards.containsKey('essence')) essence += rewards['essence']!;
    if (rewards.containsKey('gemShards')) gemShards += rewards['gemShards']!;
    if (rewards.containsKey('guildCoins')) guildCoins += rewards['guildCoins']!;
  }

  // Playtime tracking (seconds)
  int totalPlaytimeSeconds = 0;
  DateTime? _sessionStart;

  void startPlaytimeTracking() { _sessionStart = DateTime.now(); }

  void updatePlaytime() {
    if (_sessionStart != null) {
      totalPlaytimeSeconds += DateTime.now().difference(_sessionStart!).inSeconds;
      _sessionStart = DateTime.now();
    }
  }

  String get playtimeLabel {
    final h = totalPlaytimeSeconds ~/ 3600;
    final m = (totalPlaytimeSeconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
  int pvpWins           = 0;
  int pvpLosses         = 0;
  int _pvpRefillEpochMs = 0; // epoch ms when next stamina point refills

  Duration get pvpRechargeRemaining {
    if (pvpStamina >= pvpMaxStamina || _pvpRefillEpochMs == 0) {
      return Duration.zero;
    }
    final ms = _pvpRefillEpochMs - DateTime.now().millisecondsSinceEpoch;
    return ms > 0 ? Duration(milliseconds: ms) : Duration.zero;
  }

  void tickPvpStamina() {
    if (pvpStamina >= pvpMaxStamina) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    bool changed = false;
    while (_pvpRefillEpochMs > 0 &&
        now >= _pvpRefillEpochMs &&
        pvpStamina < pvpMaxStamina) {
      pvpStamina++;
      _pvpRefillEpochMs += pvpRechargeInterval.inMilliseconds;
      changed = true;
    }
    if (pvpStamina >= pvpMaxStamina) _pvpRefillEpochMs = 0;
    if (changed) { notifyListeners(); saveToLocal(); }
  }

  int _pvpRefillsBought = 0;
  static const _pvpRefillCosts = [50, 100, 200, 400];

  int? get pvpRefillCost => _pvpRefillsBought < _pvpRefillCosts.length
      ? _pvpRefillCosts[_pvpRefillsBought]
      : null;

  bool buyPvpStamina() {
    final cost = pvpRefillCost;
    if (cost == null || zcoins < cost) return false;
    zcoins -= cost;
    pvpStamina += 5;
    _pvpRefillsBought++;
    notifyListeners();
    saveToLocal();
    return true;
  }

  bool spendPvpStamina() {
    tickPvpStamina();
    if (pvpStamina <= 0) return false;
    if (pvpStamina == pvpMaxStamina) {
      _pvpRefillEpochMs = DateTime.now().millisecondsSinceEpoch +
          pvpRechargeInterval.inMilliseconds;
    }
    pvpStamina--;
    notifyListeners();
    saveToLocal();
    return true;
  }

  // PvP daily leaderboard
  int pvpDailyWins = 0;
  int pvpDailyDamage = 0;
  bool pvpDailyRewardClaimed = false;

  int get pvpDailyRank {
    if (pvpDailyWins <= 0) return 0;
    if (pvpDailyWins >= 10) return 1;
    if (pvpDailyWins >= 7) return 2;
    if (pvpDailyWins >= 5) return 3;
    if (pvpDailyWins >= 3) return 4;
    return 5;
  }

  String get pvpDailyRankLabel => switch (pvpDailyRank) {
    1 => '🏆 Champion',
    2 => '🥈 Gladiator',
    3 => '🥉 Duelist',
    4 => '⚔ Challenger',
    5 => '🗡 Contender',
    _ => 'Unranked',
  };

  Map<String, int> get pvpDailyRewards => switch (pvpDailyRank) {
    1 => {'gemShards': 30, 'echoes': 100, 'zcoins': 20, 'guildCoins': 50},
    2 => {'gemShards': 20, 'echoes': 70, 'zcoins': 15, 'guildCoins': 35},
    3 => {'gemShards': 15, 'echoes': 50, 'zcoins': 10, 'guildCoins': 25},
    4 => {'gemShards': 10, 'echoes': 30, 'zcoins': 5, 'guildCoins': 15},
    5 => {'gemShards': 5, 'echoes': 15, 'guildCoins': 10},
    _ => {},
  };

  void claimPvpDailyReward() {
    if (pvpDailyRewardClaimed || pvpDailyRank == 0) return;
    final rewards = pvpDailyRewards;
    if (rewards.containsKey('gemShards')) gemShards += rewards['gemShards']!;
    if (rewards.containsKey('echoes'))    echoes += rewards['echoes']!;
    if (rewards.containsKey('zcoins'))  zcoins += rewards['zcoins']!;
    if (rewards.containsKey('guildCoins')) guildCoins += rewards['guildCoins']!;
    pvpDailyRewardClaimed = true;
    notifyListeners();
    saveToLocal();
  }

  void recordExternalKill({bool isBoss = false, String? enemyName, String? enemyId}) {
    _dailyKills++;
    _totalKills++;
    _dailyBattleWins++;
    _totalBattleWins++;
    if (isBoss) { _dailyBossKills++; _totalBossKills++; }
    addSeasonXp(isBoss ? 10 : 3);
    advanceWeekly('w_kills', 1);
    if (isBoss) advanceWeekly('w_boss', 1);
    if (enemyName != null) logEnemy(enemyName);
    if (enemyId != null) {
      bestiaryKills[enemyId] = (bestiaryKills[enemyId] ?? 0) + 1;
      final w = _weaknessForEnemy(enemyId);
      if (w != null) _trackBountyProgress(_weaknessBountyType(w), 1);
    }
    // Rune drop: 10% on boss kills from external modes
    if (isBoss) rollRuneDrop();
  }

  /// Scale a hero-outgoing hit down while in a PvP match so the attacker can't
  /// burst a rival in 1–2 rounds. No-op outside PvP. Tuned via Remote Config
  /// (`pvp_hero_dmg_mult`, default 0.10 = −90%) so it can change without a build.
  int _pvpDamageScaled(int dmg) {
    if (!_pvpMode) return dmg;
    var d = (dmg * RemoteConfigService.instance.pvpHeroDmgMult).round();
    // Hard cap a single hit to a fraction of the foe's HP so no build can
    // one-shot a rival — guarantees a multi-round fight whatever the DPS/HP
    // ratio (the % mult alone can't, since a glass-cannon hit still exceeds a
    // same-scale HP pool). Tunable via Remote Config.
    final foeHp = currentEnemy?.maxHealth ?? 0;
    if (foeHp > 0) {
      final cap = (foeHp * RemoteConfigService.instance.pvpMaxHitFraction).round();
      if (cap > 0 && d > cap) d = cap;
    }
    return d.clamp(1, 1000000000000000);
  }

  void recordPvpResult(bool won) {
    _logPvpTelemetry(won); // capture the fight BEFORE pvpRating is updated below
    pvpDailyDamage += (hero.baseDmg + hero.level) * 10;
    const baseGems = 3;
    if (won) {
      pvpWins++;
      pvpDailyWins++;
      gemShards += baseGems * 3;
      addSeasonXp(8);
      advanceWeekly('w_pvp', 1);
    } else {
      pvpLosses++;
      gemShards += baseGems;
    }
    pvpRating = (pvpRating + (won ? 25 : -15)).clamp(100, 9999);
    notifyListeners();
    saveToLocal();
  }

  PvpSnapshot buildPvpSnapshot(String userId) => PvpSnapshot(
    userId:      userId,
    displayName: hero.name,
    heroName:    hero.name,
    heroClass:   hero.heroClass.name,
    level:       hero.level,
    maxHp:       hero.maxHealth,
    attackBonus: hero.attackBonus
        + passiveTree.totalOf(PassiveEffect.attackFlat)
        + inventory.totalOf(ItemStat.attackBonus)
        + inventory.totalOf(ItemStat.strength)
        + petAttackBonus + skinAttackBonus
        + _setTotal(ItemStat.attackBonus) + _setTotal(ItemStat.strength),
    damageMod:   hero.damageMod
        + passiveTree.totalOf(PassiveEffect.damageFlat)
        + inventory.totalOf(ItemStat.damageBonus)
        + inventory.totalOf(ItemStat.strength)
        + petDamage + skinDamage
        + _setTotal(ItemStat.damageBonus) + _setTotal(ItemStat.strength),
    armorClass:  hero.armorClass
        + passiveTree.totalOf(PassiveEffect.armorFlat)
        + inventory.totalOf(ItemStat.armorClass)
        + inventory.totalOf(ItemStat.strength)
        + petArmor + skinArmor
        + _setTotal(ItemStat.armorClass) + _setTotal(ItemStat.strength),
    subclassId: activeSubclass?.id,
    rating:  pvpRating,
    wins:    pvpWins,
    losses:  pvpLosses,
    title:       activeTitle,
    nameColorId: activeNameColor,
    frameId:     activeFrame,
    spriteId:    heroBattleSpriteId,
  );

  // ── Medieval Power Score ────────────────────────────────────────────────────
  int get medievalPower {
    var score = 0;

    // Base stats
    score += hero.level * 10;
    score += hero.maxHealth ~/ 2;
    score += hero.baseDmg * 5;
    score += hero.armorClass * 3;

    // Equipment: base damage + stat bonuses
    score += inventory.equippedWeaponDamage * 2;
    for (final item in inventory.equipped.values) {
      for (final b in item.bonuses) {
        score += b.value * 3;
      }
      if (item.gem != null) score += 10 + item.gem!.tier.index * 8;
      score += switch (item.rarity) {
        ItemRarity.common    => 5,
        ItemRarity.uncommon  => 10,
        ItemRarity.rare      => 15,
        ItemRarity.epic      => 30,
        ItemRarity.legendary => 60,
        ItemRarity.mythic    => 100,
        ItemRarity.set       => 40,
        ItemRarity.unique    => 70,
      };
    }

    // Passives
    score += passiveTree.unlockedCount * 12;
    for (final node in kPassiveNodes) {
      score += passiveTree.rankOf(node.id) * node.value;
    }

    // Abilities
    for (final entry in _abilityRanks.entries) {
      score += (entry.value + 1) * 8;
    }

    // Prestige & difficulty clearance — rankings reflect highest tier + progress
    score += prestigeLevel * 100;
    score += highestUnlockedTier * 150; // each unlocked tier is a major rank signal
    score += campaignStageIndex * 4;    // deepest campaign clearance
    score += prestigeSouls * 5;

    // Artifacts
    score += ownedArtifacts.length * 25;

    // Mastery
    score += _masteryTotal(MasteryEffect.flatDamagePerHit) * 5;
    score += _masteryTotal(MasteryEffect.permanentDamage) * 5;

    // Pets, skins, auras
    score += petAttackBonus * 4 + petDamage * 4 + petArmor * 3;
    score += skinAttackBonus * 4 + skinDamage * 4 + skinArmor * 3;

    // Allies
    score += unlockedAllies.length * 20;

    // PvP rating contribution
    score += (pvpRating - 1000).clamp(0, 5000) ~/ 5;

    // Runes
    score += runeDmgBonus * 4;

    // Ascension
    score += ascDmgBonus * 4;

    return score.clamp(0, 9999999);
  }

  String get medievalPowerLabel {
    final p = medievalPower;
    if (p >= 50000) return 'Mythic';
    if (p >= 25000) return 'Legendary';
    if (p >= 10000) return 'Epic';
    if (p >= 5000) return 'Veteran';
    if (p >= 2000) return 'Seasoned';
    if (p >= 500) return 'Apprentice';
    return 'Novice';
  }

  Color get medievalPowerColor {
    final p = medievalPower;
    if (p >= 50000) return const Color(0xFFff44ff);
    if (p >= 25000) return const Color(0xFFFFD700);
    if (p >= 10000) return const Color(0xFFcc44ff);
    if (p >= 5000) return const Color(0xFF6699ff);
    if (p >= 2000) return const Color(0xFF44cc88);
    if (p >= 500) return const Color(0xFFcccccc);
    return const Color(0xFF888888);
  }

  // ── Gem system ─────────────────────────────────────────────────────────────
  int gemShards = 0;
  final List<Gem> gemBag = []; // crafted but unsocketed gems
  static const int gemBagMax = 30;

  int _gemTotal(ItemStat stat) {
    return inventory.equipped.values
        .where((item) => item.gem?.stat == stat)
        .fold(0, (sum, item) => sum + (item.gem?.value ?? 0));
  }

  int gemElemDamagePct(DamageType type) {
    int total = 0;
    for (final entry in inventory.equipped.entries) {
      final slot = entry.key;
      final item = entry.value;
      if (item.gem == null) continue;
      if (item.gem!.damageType != type) continue;
      if (slot == ItemSlot.weapon || slot == ItemSlot.offHand) {
        total += item.gem!.value;
      }
    }
    return total;
  }

  int gemElemResPct(DamageType type) {
    int total = 0;
    for (final entry in inventory.equipped.entries) {
      final slot = entry.key;
      final item = entry.value;
      if (item.gem == null) continue;
      if (item.gem!.damageType != type) continue;
      if (slot != ItemSlot.weapon && slot != ItemSlot.offHand) {
        total += item.gem!.value;
      }
    }
    return total;
  }

  bool craftGem(GemType type, GemTier tier) {
    if (gemShards < tier.shardCost) return false;
    if (gemBag.length >= gemBagMax) return false;
    gemShards -= tier.shardCost;
    gemBag.add(Gem(type: type, tier: tier));
    notifyListeners();
    saveToLocal();
    return true;
  }

  void socketGem(EquipmentItem item, Gem gem) {
    // gem must be in gemBag
    if (!gemBag.remove(gem)) return;
    item.gem = gem; // replaces/destroys any existing gem
    notifyListeners();
    saveToLocal();
  }

  void unsocketGem(EquipmentItem item) {
    if (item.gem == null) return;
    gemBag.add(item.gem!);
    item.gem = null;
    notifyListeners();
    saveToLocal();
  }

  // ── Stash tabs ─────────────────────────────────────────────────────────────
  int bagTabsPurchased = 0;
  static const List<int> stashTabCosts = [50, 100, 200, 400]; // zcoins per tab (4 extra tabs max)
  int get stashTabCount    => 1 + bagTabsPurchased;
  int get totalBagCapacity => 20 * stashTabCount;
  bool get canBuyStashTab  => bagTabsPurchased < stashTabCosts.length;
  int? get nextStashTabCost => canBuyStashTab ? stashTabCosts[bagTabsPurchased] : null;

  bool purchaseStashTab() {
    if (!canBuyStashTab) return false;
    final cost = stashTabCosts[bagTabsPurchased];
    if (zcoins < cost) return false;
    zcoins -= cost;
    bagTabsPurchased++;
    inventory.bagCapacity = totalBagCapacity;
    notifyListeners();
    saveToLocal();
    return true;
  }

  // ── Expeditions ────────────────────────────────────────────────────────────
  final List<Expedition> _activeExpeditions = [];

  List<Expedition> get activeExpeditions => List.unmodifiable(_activeExpeditions);

  Expedition? expeditionForMerc(String mercId) =>
      _activeExpeditions.where((e) => e.mercId == mercId).firstOrNull;

  bool startExpedition(String mercId, ExpeditionLocation location, ExpeditionDuration duration) {
    if (!allyUnlocked(mercId)) return false;
    if (expeditionForMerc(mercId) != null) return false;
    _activeExpeditions.add(Expedition(
      mercId:       mercId,
      location:     location,
      duration:     duration,
      startEpochMs: DateTime.now().millisecondsSinceEpoch,
    ));
    notifyListeners();
    saveToLocal();
    return true;
  }

  ({Map<String, int> rewards, String? discovery}) collectExpedition(String mercId) {
    final e = expeditionForMerc(mercId);
    if (e == null || !e.isComplete) return (rewards: {}, discovery: null);
    final rewards = _expeditionRewards(e);
    gold     += rewards['gold']     ?? 0;
    shards   += rewards['shards']   ?? 0;
    essence  += rewards['essence']  ?? 0;
    mythril  += rewards['mythril']  ?? 0;
    zcoins += rewards['zcoins'] ?? 0;
    final discovery = _rollDiscovery(e);
    // Long expeditions have a chance to find a rune
    if (e.duration == ExpeditionDuration.long) rollRuneDrop();
    trackExpeditionComplete();
    _activeExpeditions.removeWhere((x) => x.mercId == mercId);
    notifyListeners();
    saveToLocal();
    return (rewards: rewards, discovery: discovery);
  }

  static const _discoveries = <LocationBiome, List<String>>{
    LocationBiome.graveyard: [
      'A tarnished locket bearing the portrait of a forgotten king.',
      'An obsidian shard that hums with residual soul energy.',
      'Crumbling parchment: a partial map of the catacombs below.',
      'A gravedigger\'s journal — the last entry speaks of something waking.',
    ],
    LocationBiome.cave: [
      'A cluster of luminous zcoins still pulsing with geomantic power.',
      'Cave paintings depicting a battle between giants and serpents.',
      'A vein of raw mythril ore, barely accessible behind a collapsed wall.',
      'The skeleton of a spelunker, clutching a waterproof field notebook.',
    ],
    LocationBiome.temple: [
      'A golden idol of an unnamed deity — its eyes are missing.',
      'An enchanted brazier that lights itself when touched.',
      'Stone tablets engraved with a ritual to bind shadow elementals.',
      'A vial of sacred oil that glows faintly in darkness.',
    ],
    LocationBiome.fortress: [
      'A war banner bearing the crest of a fallen empire.',
      'Blueprints for a siege engine of terrifying design.',
      'A knight\'s logbook recording every battle fought within these walls.',
      'A locked iron chest — the key is nowhere to be found.',
    ],
    LocationBiome.ruin: [
      'A mosaic floor tile depicting the city as it once stood, magnificent.',
      'A bronze astrolabe of extraordinary precision.',
      'A sealed amphora of aged wine — still drinkable, impossibly.',
      'Fragments of a celestial star map etched into the floor.',
    ],
    LocationBiome.dungeon: [
      'A prisoner\'s tally scratched into the wall — 847 marks.',
      'A torturer\'s tome listing methods not yet forgotten by history.',
      'A ring of keys that opens nothing you can find.',
      'A contraband cache hidden under a loose flagstone — dust and bones.',
    ],
    LocationBiome.catacombs: [
      'A row of skulls arranged to spell a warning in an unknown tongue.',
      'A bone flute that produces no audible sound, yet sets teeth on edge.',
      'Dozens of identical iron rings, each engraved with a single name.',
      'A hollowed-out femur containing a rolled vellum prophecy.',
    ],
    LocationBiome.sanctum: [
      'A floating geometric shape that vanishes when you reach for it.',
      'A resonance crystal that echoes the last words spoken in this chamber.',
      'A book of theorems whose proofs reference dimensions beyond the third.',
      'An orrery of unknown solar systems, still spinning after centuries.',
    ],
    LocationBiome.barrows: [
      'A burial mound unsealed by time — within, a chieftain\'s corroded crown.',
      'Peat-stained rune stones arranged in a spiral that predates written history.',
      'A hollow beneath the earth containing the fossilized roots of a world-tree.',
      'Bones wrapped in woven copper wire — a funerary tradition lost to ages.',
    ],
    LocationBiome.highPass: [
      'A frozen knight encased in glacial ice, sword still raised mid-swing.',
      'Prayer flags strung between peaks, each bearing a different sigil.',
      'A carved waystone marking an ancient trade route through the mountains.',
      'An eagle\'s nest containing a gem-encrusted compass of dwarven make.',
    ],
  };

  String? _rollDiscovery(Expedition e) {
    final chancePct = switch (e.duration) {
      ExpeditionDuration.short  => 15,
      ExpeditionDuration.medium => 28,
      ExpeditionDuration.long   => 45,
    };
    if (_rng.nextInt(100) >= chancePct) return null;
    final pool = _discoveries[e.location.biome] ?? [];
    if (pool.isEmpty) return null;
    return pool[_rng.nextInt(pool.length)];
  }

  Map<String, int> _expeditionRewards(Expedition e) {
    final lvl      = hero.level;
    final mult     = e.duration.mult;
    final mercLv   = allyLevel(e.mercId).clamp(1, 10);
    final base     = (mult * (1.0 + mercLv * 0.1) * (lvl / 10.0).clamp(1.0, 5.0)).round();
    return switch (e.location.biome) {
      LocationBiome.graveyard  => {'gold': base * 600, 'shards': base * 5},
      LocationBiome.cave       => {'gold': base * 250, 'shards': base * 14},
      LocationBiome.temple     => {'gold': base * 280, 'shards': base * 6,  'essence': base * 2},
      LocationBiome.fortress   => {'gold': base * 420, 'shards': base * 8,  'mythril': base},
      LocationBiome.ruin       => {'gold': base * 350, 'shards': base * 8,  'essence': base},
      LocationBiome.dungeon    => {'gold': base * 180, 'shards': base * 16, 'zcoins': (base / 2).ceil()},
      LocationBiome.catacombs  => {'gold': base * 300, 'shards': base * 10, 'essence': base * 2},
      LocationBiome.sanctum    => {'gold': base * 200, 'shards': base * 4,  'essence': base * 4, 'zcoins': (base / 2).ceil()},
      LocationBiome.barrows   => {'gold': base * 450, 'shards': base * 6,  'essence': base * 3},
      LocationBiome.highPass  => {'gold': base * 300, 'shards': base * 8,  'mythril': (base * 1.5).ceil(), 'echoes': base * 4},
    };
  }

  Map<String, int> previewExpeditionRewards(
      String mercId, ExpeditionLocation location, ExpeditionDuration duration) =>
      _expeditionRewards(Expedition(
        mercId:       mercId,
        location:     location,
        duration:     duration,
        startEpochMs: 0,
      ));

  // ── Class masteries ────────────────────────────────────────────────────────
  final Map<String, int> masteryLevels = {}; // id → level (0=locked, 1-5=active)

  int masteryLevel(String id) => masteryLevels[id] ?? 0;

  bool canUnlockMastery(ClassMastery m) =>
      !masteryLevels.containsKey(m.id) && hero.level >= m.levelRequired;

  bool unlockMastery(ClassMastery m) {
    if (!canUnlockMastery(m)) return false;
    masteryLevels[m.id] = 1;
    notifyListeners();
    saveToLocal();
    return true;
  }

  bool upgradeMastery(ClassMastery m) {
    final current = masteryLevels[m.id] ?? 0;
    if (current == 0 || current >= m.maxLevel) return false;
    final cost = ClassMastery.upgradeCostAt(current);
    if (gold < cost) return false;
    gold -= cost;
    masteryLevels[m.id] = current + 1;
    notifyListeners();
    saveToLocal();
    return true;
  }

  int _masteryTotal(MasteryEffect effect) {
    int total = 0;
    for (final m in kMasteryCatalog) {
      if (m.classRequired != hero.heroClass) continue;
      final lvl = masteryLevels[m.id] ?? 0;
      if (lvl >= 1 && m.effect == effect) total += m.valueAtLevel(lvl);
    }
    return total;
  }

  // ── Daily challenge tracking ───────────────────────────────────────────────
  String _lastDailyDate = '';
  int _dailyKills       = 0;
  int _dailyBattleWins  = 0;
  int _dailyIdleCollects = 0;
  int _dailyAbilityUses = 0;
  int _dailyDamageDealt = 0;
  int _dailyBossKills   = 0;
  bool _dailyItemEquipped = false;

  // ── Daily mode attempt limits ─────────────────────────────────────────────
  static const int kDungeonMaxAttempts   = 3;
  static const int kGauntletMaxAttempts  = 5;
  static const int kBossRushMaxAttempts  = 2;
  static const int kDungeonExtraCost     = 40;
  static const int kGauntletExtraCost    = 30;
  static const int kBossRushExtraCost    = 50;

  int _dungeonAttemptsUsed   = 0;
  int _gauntletAttemptsUsed  = 0;
  int _bossRushAttemptsUsed  = 0;

  int get dungeonAttemptsRemaining  => (kDungeonMaxAttempts  - _dungeonAttemptsUsed).clamp(0, 99);
  int get gauntletAttemptsRemaining => (kGauntletMaxAttempts - _gauntletAttemptsUsed).clamp(0, 99);
  int get bossRushAttemptsRemaining => (kBossRushMaxAttempts - _bossRushAttemptsUsed).clamp(0, 99);

  bool consumeDungeonAttempt()  { if (dungeonAttemptsRemaining  <= 0) return false; _dungeonAttemptsUsed++;  saveToLocal(); return true; }
  bool consumeGauntletAttempt() { if (gauntletAttemptsRemaining <= 0) return false; _gauntletAttemptsUsed++; saveToLocal(); return true; }
  bool consumeBossRushAttempt() { if (bossRushAttemptsRemaining <= 0) return false; _bossRushAttemptsUsed++; saveToLocal(); return true; }

  bool buyExtraDungeonAttempt()  { if (zcoins < kDungeonExtraCost)  return false; zcoins -= kDungeonExtraCost;  _dungeonAttemptsUsed  = (_dungeonAttemptsUsed  - 1).clamp(0, 99); notifyListeners(); saveToLocal(); return true; }
  bool buyExtraGauntletAttempt() { if (zcoins < kGauntletExtraCost) return false; zcoins -= kGauntletExtraCost; _gauntletAttemptsUsed = (_gauntletAttemptsUsed - 1).clamp(0, 99); notifyListeners(); saveToLocal(); return true; }
  bool buyExtraBossRushAttempt() { if (zcoins < kBossRushExtraCost) return false; zcoins -= kBossRushExtraCost; _bossRushAttemptsUsed = (_bossRushAttemptsUsed - 1).clamp(0, 99); notifyListeners(); saveToLocal(); return true; }

  static String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  // Respects the player's chosen reset hour (default 0 = midnight).
  // Before resetHour, we're still on "yesterday" for reset purposes.
  String _effectiveDateKey() {
    final now = DateTime.now();
    final effective = now.hour < resetHour ? now.subtract(const Duration(days: 1)) : now;
    return _dateKey(effective);
  }

  // Daily reset hour preference (0–23, default 0 = midnight local time).
  int resetHour = 0;
  String _resetHourChangedYear = '';

  bool get canChangeResetHour =>
      _resetHourChangedYear.isEmpty ||
      _resetHourChangedYear != DateTime.now().year.toString();

  void setResetHour(int hour) {
    if (!canChangeResetHour) return;
    resetHour = hour.clamp(0, 23);
    _resetHourChangedYear = DateTime.now().year.toString();
    notifyListeners();
    saveToLocal();
  }

  // Tower Ascension boss daily defeat tracking
  final Set<String> _towerBossesDefeatedToday = {};

  bool isTowerBossDefeatedToday(int stage, int tier) =>
      _towerBossesDefeatedToday.contains('${stage}_$tier');

  int lastTowerShardDrop = 0;

  void recordTowerBossDefeated(int stage, int tier) {
    _towerBossesDefeatedToday.add('${stage}_$tier');
    final shardGrant = 2 + stage + tier * 3;
    towerShards += shardGrant;
    lastTowerShardDrop = shardGrant;
    notifyListeners();
    saveToLocal();
  }

  void debugGrantTowerShards(int amount) {
    towerShards += amount;
    notifyListeners();
  }

  void refreshDaily() { _checkDailyReset(); notifyListeners(); }
  void _checkDailyReset() {
    final today = _effectiveDateKey();
    if (_lastDailyDate == today) return;
    _lastDailyDate    = today;
    _towerBossesDefeatedToday.clear();
    _dailyKills       = 0;
    _dailyBattleWins  = 0;
    _dailyIdleCollects = 0;
    _dailyAbilityUses = 0;
    _dailyDamageDealt = 0;
    _dailyBossKills   = 0;
    _dailyItemEquipped = false;
    dailyChestClaimed  = false;
    _dungeonAttemptsUsed  = 0;
    _gauntletAttemptsUsed = 0;
    _bossRushAttemptsUsed = 0;
    _pvpRefillsBought     = 0;
    pvpDailyWins          = 0;
    pvpDailyDamage        = 0;
    pvpDailyRewardClaimed = false;
    dungeonMiniBossDefeated = false;
    activeDungeonAffix = null;
    dailyEnergyRefillsUsed = 0;
    dailyChallenges
      ..clear()
      ..addAll(DailyChallengeGenerator.generateForDate(DateTime.now()));
  }

  int getDailyProgress(DailyChallengeType type) {
    switch (type) {
      case DailyChallengeType.killEnemies: return _dailyKills;
      case DailyChallengeType.winBattles:  return _dailyBattleWins;
      case DailyChallengeType.collectIdle: return _dailyIdleCollects;
      case DailyChallengeType.useAbilities: return _dailyAbilityUses;
      case DailyChallengeType.dealDamage:  return _dailyDamageDealt;
      case DailyChallengeType.defeatBoss:  return _dailyBossKills;
      case DailyChallengeType.equipItem:   return _totalDisenchants > 0 ? 1 : 0;
      case DailyChallengeType.reachGold:   return gold;
    }
  }

  bool get hasClaimableDaily => dailyChallenges.any(
      (c) => !c.claimed && getDailyProgress(c.type) >= c.target);

  void claimDailyChallenge(int index) {
    if (index < 0 || index >= dailyChallenges.length) return;
    final c = dailyChallenges[index];
    if (c.claimed) return;
    if (getDailyProgress(c.type) < c.target) return;
    c.claimed = true;
    gold     += c.rewardGold;
    shards   += c.rewardShards;
    essence  += c.rewardEssence;
    zcoins += c.rewardCrystals;
    _setLastAction('Claimed: ${c.title}! +${c.rewardGold}g +${c.rewardShards}◆ +${c.rewardEssence} essence +${c.rewardCrystals}🪙');
    notifyListeners();
    saveToLocal();
  }

  // ── Lifetime counters (never reset) ───────────────────────────────────────
  int _totalKills        = 0;
  int _totalBattleWins   = 0;
  int _totalBossKills    = 0;
  int _totalDamageDealt  = 0;
  int _totalAbilityUses  = 0;
  int _dungeonClears     = 0;
  int _bossRushClears    = 0;


  // Bestiary — kill counts per enemy id, discovered when first killed
  final Map<String, int> bestiaryKills = {};

  int bestiaryKillCount(String enemyId) => bestiaryKills[enemyId] ?? 0;
  bool bestiaryDiscovered(String enemyId) => (bestiaryKills[enemyId] ?? 0) > 0;

  /// The next uncleared bestiary kill-milestone for [enemyId], or null if the
  /// enemy has already hit the final milestone. Used by the combat beacon.
  int? nextBestiaryMilestone(String enemyId) {
    final kills = bestiaryKillCount(enemyId);
    for (final m in bestiaryMilestones) {
      if (kills < m) return m;
    }
    return null;
  }

  static const bestiaryMilestones = [10, 50, 100, 250, 500];
  static const _milestoneRewards = <int, ({int gold, int shards, int essence, int atk})>{
    10:  (gold: 100,  shards: 0,  essence: 0,  atk: 0),
    50:  (gold: 300,  shards: 5,  essence: 0,  atk: 0),
    100: (gold: 800,  shards: 10, essence: 5,  atk: 0),
    250: (gold: 1500, shards: 20, essence: 10, atk: 1),
    500: (gold: 3000, shards: 30, essence: 20, atk: 2),
  };
  final Set<String> _claimedBestiaryMilestones = {};
  // Permanent flat ATK from 250/500-kill mastery milestones (persists through prestige)
  int _bestiaryMasteryAtk = 0;

  bool hasBestiaryMilestoneToClaim(String enemyId) {
    final kills = bestiaryKillCount(enemyId);
    return bestiaryMilestones.any((m) =>
        kills >= m && !_claimedBestiaryMilestones.contains('${enemyId}_$m'));
  }

  int get totalClaimableBestiaryMilestones => bestiaryKills.keys
      .where((id) => hasBestiaryMilestoneToClaim(id)).length;

  void claimBestiaryMilestone(String enemyId, int milestone) {
    final key = '${enemyId}_$milestone';
    if (_claimedBestiaryMilestones.contains(key)) return;
    if (bestiaryKillCount(enemyId) < milestone) return;
    _claimedBestiaryMilestones.add(key);
    final r = _milestoneRewards[milestone];
    if (r == null) return;
    gold    += r.gold;
    shards  += r.shards;
    essence += r.essence;
    if (r.atk > 0) _bestiaryMasteryAtk += r.atk;
    notifyListeners();
    saveToLocal();
  }

  bool isBestiaryMilestoneClaimed(String enemyId, int milestone) =>
      _claimedBestiaryMilestones.contains('${enemyId}_$milestone');

  // Gold bonus from repeated kills: +2% at 50, +5% at 100, +10% at 250, +15% at 500
  double bestiaryGoldBonus(String enemyId) {
    final kills = bestiaryKillCount(enemyId);
    if (kills >= 500) return 1.15;
    if (kills >= 250) return 1.10;
    if (kills >= 100) return 1.05;
    if (kills >= 50)  return 1.02;
    return 1.0;
  }

  // Weakness attack bonus: 0% at 0 kills → +10% at 100 kills (+1% per 10 kills)
  double bestiaryWeaknessBonus(String enemyId) {
    if (bestiaryFor(enemyId) == null) return 1.0;
    return weaknessBonusMult(enemyId, bestiaryKillCount(enemyId));
  }

  // Type-level aggregate bonuses — computed from bestiaryKills, no extra save state needed.
  int typeKillCount(BestiaryWeakness type) => kBestiaryEntries
      .where((e) => e.weakness == type)
      .fold(0, (sum, e) => sum + (bestiaryKills[e.enemyId] ?? 0));

  // +1% per 100 total type kills, capped at +25%
  int bestiaryTypeDamagePct(BestiaryWeakness type) =>
      (typeKillCount(type) ~/ 100).clamp(0, 25);

  // ── Defensive ratings (diminishing returns → % cap at kDefenseCapPct) ───────
  /// Hero dodge rating from all persistent sources (the transient merc-buff is
  /// added on top in combat only).
  double get heroDodgeRating {
    final dexTotal = hero.dexterity + inventory.totalOf(ItemStat.dexterity)
        + _setTotal(ItemStat.dexterity) + _gemTotal(ItemStat.dexterity);
    final dexDodge = max(0.0, (dexTotal - 10) * 0.5).clamp(0.0, 30.0);
    final subclassDodge = (subclassEffect == SubclassEffect.shadowMonk ? 10 : 0) + subclassDodgePct;
    return passiveTree.totalOf(PassiveEffect.dodgeChance) + subclassDodge
        + runeDodgeBonus + auraDodgeChance + petDodgeChance + dexDodge;
  }
  /// Effective dodge chance % (diminishing returns, capped at kDefenseCapPct).
  double get effectiveDodgePct =>
      kDefenseCapPct * heroDodgeRating / (heroDodgeRating + kDodgeRatingK);
  /// Effective physical damage-reduction % for a given armor rating.
  double armorDrPctFor(num armorRating) =>
      kDefenseCapPct * armorRating / (armorRating + kArmorRatingK);

  /// Canonical physical mitigation shared by EVERY combat mode (main campaign,
  /// Boss Rush, Dungeon, Gauntlet, Guild). Armor is a RATING that runs through
  /// the diminishing-returns curve (asymptotes to [kDefenseCapPct]); the
  /// acBonus ability buff and mercenary AC are % boosts to that rating, applied
  /// via [tempAcPct]. Physical only — elemental attacks should bypass this
  /// (resistances handle them). No flat subtraction and no damage cap, so it
  /// scales cleanly at any tier. Static + pure so the Dungeon model (which has
  /// no GameState instance) can share the exact same formula.
  static int physicalAfterArmor(int rawDamage, int armorRating, {int tempAcPct = 0}) {
    final rating = tempAcPct > 0
        ? (armorRating * (1 + tempAcPct / 100.0)).round()
        : armorRating;
    final drPct = kDefenseCapPct * rating / (rating + kArmorRatingK);
    return max(0, (rawDamage * (1 - drPct / 100)).round());
  }

  /// Full incoming-hit mitigation shared by every mode, matching the campaign:
  /// PHYSICAL runs through armor DR ([physicalAfterArmor]); ELEMENTAL bypasses
  /// armor and is reduced by the hero's resistance to that type (capped ±90%,
  /// negative = extra damage taken). Dodge is a separate full-negation roll the
  /// caller makes first (see [effectiveDodgePct]).
  int mitigateIncoming(int rawDamage, DamageType attackType, int armorRating, {int tempAcPct = 0}) {
    if (attackType == DamageType.physical) {
      return physicalAfterArmor(rawDamage, armorRating, tempAcPct: tempAcPct);
    }
    final resPct = heroResistancePct(attackType);
    return max(0, (rawDamage * (1 - resPct / 100.0)).round());
  }

  double bestiaryTypeDamageMult(String enemyId) {
    final entry = bestiaryFor(enemyId);
    if (entry == null) return 1.0;
    return 1.0 + bestiaryTypeDamagePct(entry.weakness) / 100.0;
  }

  // Hero elemental resistance derived from core stats (includes equipment bonuses).
  // STR→Physical, DEX→Lightning, CON→Poison, INT→Void, WIS→Cold, CHA→Fire.
  // Scales linearly: 0% at stat 0, 25% at stat 100 (kStatCap) from base stats alone.
  // Items/passives/rebirth bonuses add to tot() and can push the total up to ±75%.
  /// Resistance % from a resistance rating (diminishing returns, caps at
  /// kResistCapPct = 75%). Same shape as [armorDrPctFor].
  double resistPctForRating(num rating) =>
      kResistCapPct * rating / (rating + kResistRatingK);

  /// FLAT resistance rating for [type] — the stat-based contribution plus the
  /// per-element and all-element resistance passives. (Mastery + gems are a %
  /// boost on top, see [heroResistRatingBoostPct].)
  int heroResistFlatRating(DamageType type) {
    int tot(int base, ItemStat stat) =>
        base + inventory.totalOf(stat) + _setTotal(stat) + _gemTotal(stat);
    final statBased = switch (type) {
      DamageType.physical  => tot(hero.strength,      ItemStat.strength)     * 25 ~/ 100,
      DamageType.lightning => tot(hero.dexterity,     ItemStat.dexterity)    * 25 ~/ 100,
      DamageType.poison    => tot(hero.constitution,  ItemStat.constitution) * 25 ~/ 100,
      DamageType.void_     => tot(hero.intelligence,  ItemStat.intelligence) * 25 ~/ 100,
      DamageType.cold      => tot(hero.wisdom,        ItemStat.wisdom)       * 25 ~/ 100,
      DamageType.fire      => tot(hero.charisma,      ItemStat.charisma)     * 25 ~/ 100,
    };
    final passivePerElem = switch (type) {
      DamageType.physical  => 0,
      DamageType.fire      => passiveTree.totalOf(PassiveEffect.fireRes),
      DamageType.cold      => passiveTree.totalOf(PassiveEffect.coldRes),
      DamageType.lightning => passiveTree.totalOf(PassiveEffect.lightningRes),
      DamageType.poison    => passiveTree.totalOf(PassiveEffect.poisonRes),
      DamageType.void_     => passiveTree.totalOf(PassiveEffect.voidRes),
    };
    return statBased + passivePerElem + passiveTree.totalOf(PassiveEffect.allRes);
  }

  /// % boost to the resistance RATING from elemental mastery + gems.
  int heroResistRatingBoostPct(DamageType type) =>
      elementalMasteryResistancePct(type) + gemElemResPct(type);

  int heroResistancePct(DamageType type) {
    // Physical is NOT a resistance — Armor is the sole physical mitigation (no
    // more armor + physical-resist double-dip). Only the 5 elements resist.
    if (type == DamageType.physical) return 0;
    // Flat rating (stats + passives) boosted by a % (mastery + gems), then run
    // through the diminishing-returns curve — so approaching the 90% cap is
    // expensive late-game. Negative net = vulnerability (kept flat, floor −75).
    final rating = heroResistFlatRating(type) *
        (1 + heroResistRatingBoostPct(type) / 100.0);
    if (rating <= 0) return rating.round().clamp(-75, 0);
    return resistPctForRating(rating).round().clamp(0, 90);
  }

  double passiveElemDamagePct(DamageType type) {
    final passive = switch (type) {
      DamageType.physical  => 0.0,
      DamageType.fire      => passiveTree.totalOf(PassiveEffect.fireDamage).toDouble(),
      DamageType.cold      => passiveTree.totalOf(PassiveEffect.coldDamage).toDouble(),
      DamageType.lightning => passiveTree.totalOf(PassiveEffect.lightningDamage).toDouble(),
      DamageType.poison    => passiveTree.totalOf(PassiveEffect.poisonDamage).toDouble(),
      DamageType.void_     => passiveTree.totalOf(PassiveEffect.voidDamage).toDouble(),
    };
    // Artifact-set + subclass damage % are folded in here so they flow through
    // every combat path (campaign hits + abilities, and external arena modes via
    // heroAllDamagePctFor) that already sums this term.
    return passive + artifactSetDamagePct(type) + subclassDamagePct(type);
  }

  /// Increased damage % from active artifact sets for [type]: all-damage set
  /// bonuses plus any elemental set bonus that matches this damage type.
  /// A set at 2 pieces grants its 2-piece bonus; at 3 it also grants the
  /// full-set bonus (cumulative).
  double artifactSetDamagePct(DamageType type) {
    var total = 0;
    equippedSetPieceCounts.forEach((setId, count) {
      final set = ArtifactSet.byId(setId);
      if (set == null) return;
      void apply(ArtifactSetBonus b) {
        total += b.dmgPct;
        if (b.elemType == type) total += b.elemDmgPct;
      }
      if (count >= 2) apply(set.twoPieceBonus);
      if (count >= 3) apply(set.threePieceBonus);
    });
    return total.toDouble();
  }

  // Chapter completion: all 5 enemies in a category killed ≥1 time
  bool isBestiaryChapterComplete(String category) {
    final entries = kBestiaryEntries.where((e) => e.category == category);
    return entries.every((e) => bestiaryDiscovered(e.enemyId));
  }

  int get bestiaryMasteryAtkBonus => _bestiaryMasteryAtk;

  // Permanent ATK bonus: +1 per unique enemy discovered + mastery ATK from 250/500-kill tiers
  int get bestiaryChapterBonus {
    return kBestiaryEntries.where((e) => bestiaryDiscovered(e.enemyId)).length
        + _bestiaryMasteryAtk;
  }

  final Set<String> _claimedBestiaryChapters = {};
  bool isChapterRewardClaimed(String category) => _claimedBestiaryChapters.contains(category);
  bool canClaimChapterReward(String category) =>
      isBestiaryChapterComplete(category) && !isChapterRewardClaimed(category);

  int get claimableBestiaryChapters {
    final cats = kBestiaryEntries.map((e) => e.category).toSet();
    return cats.where((c) => canClaimChapterReward(c)).length;
  }

  void claimBestiaryChapterReward(String category) {
    if (!canClaimChapterReward(category)) return;
    _claimedBestiaryChapters.add(category);
    gold     += 500;
    essence  += 15;
    zcoins += 5;
    _setLastAction('Bestiary chapter "$category" completed! +500g +15✦ +5🪙');
    notifyListeners();
    saveToLocal();
  }

  // Boss Rush best score and highest tier cleared — persisted across sessions
  int bossRushBestScore   = 0;
  int bossRushHighestTier = 0;

  // ── Waystones — consumable offline income boosters ─────────────────────────
  int basicWaystoneCount = 0;
  int grandWaystoneCount = 0;
  int waystoneExpiresAtMs = 0;
  double _activeWaystoneMult = 1.0;

  bool get waystoneActive =>
      waystoneExpiresAtMs > DateTime.now().millisecondsSinceEpoch;
  double get waystoneMult => waystoneActive ? _activeWaystoneMult : 1.0;

  bool buyWaystone({required bool grand}) {
    final cost = grand ? 50 : 20;
    if (zcoins < cost) return false;
    zcoins -= cost;
    if (grand) grandWaystoneCount++; else basicWaystoneCount++;
    notifyListeners();
    saveToLocal();
    return true;
  }

  bool activateWaystone({required bool grand}) {
    final count = grand ? grandWaystoneCount : basicWaystoneCount;
    if (count <= 0) return false;
    if (waystoneActive) return false; // one at a time
    if (grand) grandWaystoneCount--; else basicWaystoneCount--;
    _activeWaystoneMult = grand ? 3.0 : 2.0;
    final durationMs = (grand ? 12 : 4) * 3600 * 1000;
    waystoneExpiresAtMs = DateTime.now().millisecondsSinceEpoch + durationMs;
    notifyListeners();
    saveToLocal();
    return true;
  }

  // ── Extra character slots ───────────────────────────────────────────────────
  int extraCharacterSlots = 0; // 0–9 (3 default → up to 12 total), in SharedPrefs

  /// Total character slots (3 free + purchased).
  int get totalCharacterSlots => SaveService.defaultSlots + extraCharacterSlots;

  /// ZCoin cost of the NEXT slot: 250, 500, 750, … (+250 per slot).
  int get characterSlotCost => 250 * (extraCharacterSlots + 1);

  /// Whether another slot can still be purchased (max 12 total).
  bool get canBuyCharacterSlot => extraCharacterSlots < SaveService.maxExtraSlots;

  bool buyExtraCharacterSlot() {
    if (!canBuyCharacterSlot) return false;
    final cost = characterSlotCost;
    if (zcoins < cost) return false;
    zcoins -= cost;
    extraCharacterSlots++;
    SaveService.setExtraSlots(extraCharacterSlots);
    notifyListeners();
    saveToLocal();
    return true;
  }

  // ── Pet Evolution ───────────────────────────────────────────────────────────
  final Map<String, int> petEvolutionLevels = {}; // petId -> 0..10

  int petEvolutionLevel(String petId) => petEvolutionLevels[petId] ?? 0;

  static const _evoCosts = [150, 300, 500, 800, 1200, 1800, 2500, 3500, 5000, 7500];

  int evolutionCost(String petId) {
    final level = petEvolutionLevel(petId);
    if (level >= 10) return 0; // maxed
    final pet = kPetCatalog.where((p) => p.id == petId).firstOrNull;
    // Premium pets use a linear step curve (e.g. 500, 1000, 1500, …).
    if (pet?.evoCostStep != null) return pet!.evoCostStep! * (level + 1);
    return _evoCosts[level];
  }

  bool evolvePet(String petId) {
    final level = petEvolutionLevel(petId);
    if (level >= 10) return false;
    final cost = evolutionCost(petId);
    if (zcoins < cost) return false;
    zcoins -= cost;
    petEvolutionLevels[petId] = level + 1;
    notifyListeners();
    saveToLocal();
    return true;
  }

  int _evolvedPetBonus(int base, String? petId) {
    if (petId == null) return base;
    final evo = petEvolutionLevel(petId);
    return (base * (1.0 + evo * 0.3)).round();
  }

  // ── Cosmetic attack effects ─────────────────────────────────────────────────
  final Set<String> ownedAttackEffects = {};
  String? equippedAttackEffectId;

  bool buyAttackEffect(String effectId) {
    if (ownedAttackEffects.contains(effectId)) return false;
    final fx = AttackEffect.byId(effectId);
    if (fx == null) return false;
    if (zcoins < fx.zcoinCost) return false;
    zcoins -= fx.zcoinCost;
    ownedAttackEffects.add(effectId);
    AnalyticsService.instance.currencySpent('zcoins', fx.zcoinCost, 'attack_effect');
    AnalyticsService.instance.cosmeticUnlocked('attack_effect', effectId);
    equippedAttackEffectId ??= effectId;
    notifyListeners();
    saveToLocal();
    return true;
  }

  void equipAttackEffect(String? effectId) {
    equippedAttackEffectId = effectId;
    notifyListeners();
    saveToLocal();
  }

  /// The auto-attack visual to play. An equipped cosmetic attack effect overrides
  /// the class default — so e.g. a monk can throw fireballs instead of a slash.
  String get autoAttackEffectId => equippedAttackEffectId != null
      ? 'fx_$equippedAttackEffectId'
      : 'auto_${hero.heroClass.name}';

  // ── Artifacts & Mythril ─────────────────────────────────────────────────────
  int mythril = 0;

  // Owned artifact instances (generated, not static)
  final List<Artifact> ownedArtifacts = [];
  // 9×9 artifact grid: cell index (0–80) → artifact uid (only filled cells stored)
  final Map<int, String> artifactGrid = {};
  int _unlockedArtifactCells = 9;
  int get unlockedArtifactCells => _unlockedArtifactCells;

  bool isArtifactEquipped(String uid) => artifactGrid.containsValue(uid);

  Artifact? artifactByUid(String? uid) {
    if (uid == null) return null;
    return ownedArtifacts.where((a) => a.uid == uid).firstOrNull;
  }

  int get forgeCost => 10 + (campaignStageIndex ~/ 5).clamp(1, 50) * 2;

  // Last artifact that dropped (captured by UI on the next build, then cleared)
  Artifact? lastArtifactDrop;

  // The active difficulty tier that drives PvE enemy scaling, rewards and loot
  // rarity — now the freely-switchable [activeTier], decoupled from prestige.
  int get difficultyTier => activeTier;

  void gainArtifact(int dropLevel) {
    final art = ArtifactGenerator.roll(dropLevel: dropLevel, rng: _rng, tier: difficultyTier);
    ownedArtifacts.add(art);
    lastArtifactDrop = art;
    trackArtifactCollected();
    // First artifact ever → unlock the Artifacts table and coach the player on it.
    if (!artifactsUnlocked) {
      artifactsUnlocked = true;
      _triggerTutorial(const SystemTutorial(
        stage: -5, navTab: 2, subTab: 'ARTIFACTS', icon: '💎',
        title: 'Artifacts',
        howTo: 'You found your first Artifact! Artifacts are powerful relics you '
            'equip in the Inventory → Artifacts tab. Each grants permanent bonuses '
            '(damage, HP, gold and more), and you can forge/upgrade them with '
            'Mythril. Equip your best to boost every fight.',
      ));
    }
  }

  bool forgeArtifact() {
    final cost = forgeCost;
    if (mythril < cost) return false;
    mythril -= cost;
    final dropLv = (campaignStageIndex ~/ 5).clamp(1, 50);
    ownedArtifacts.add(ArtifactGenerator.roll(dropLevel: dropLv, rng: _rng, tier: difficultyTier));
    notifyListeners();
    saveToLocal();
    return true;
  }

  int get _artifactSalvageValue => (forgeCost * 0.33).round().clamp(1, 999);

  void disenchantArtifact(String uid) {
    final art = ownedArtifacts.where((a) => a.uid == uid).firstOrNull;
    if (art == null) return;
    artifactGrid.removeWhere((_, v) => v == uid);
    ownedArtifacts.removeWhere((a) => a.uid == uid);
    mythril += _artifactSalvageValue;
    notifyListeners();
    saveToLocal();
  }

  /// Number of owned artifacts not currently placed on the grid.
  int get unequippedArtifactCount =>
      ownedArtifacts.where((a) => !isArtifactEquipped(a.uid)).length;

  /// Mythril the player would gain by salvaging all unequipped artifacts.
  int get salvageAllMythrilValue =>
      unequippedArtifactCount * _artifactSalvageValue;

  /// Salvages every owned artifact that isn't equipped, awarding mythril for
  /// each (same rate as [disenchantArtifact]). Returns (count, mythril gained).
  (int count, int mythril) salvageUnequippedArtifacts() {
    final unequipped =
        ownedArtifacts.where((a) => !isArtifactEquipped(a.uid)).toList();
    if (unequipped.isEmpty) return (0, 0);
    for (final a in unequipped) {
      ownedArtifacts.removeWhere((x) => x.uid == a.uid);
    }
    final gained = _artifactSalvageValue * unequipped.length;
    mythril += gained;
    notifyListeners();
    saveToLocal();
    return (unequipped.length, gained);
  }

  void placeArtifact(int cell, String artifactId) {
    if (cell < 0 || cell >= _unlockedArtifactCells) return;
    if (!ownedArtifacts.any((a) => a.uid == artifactId)) return;
    // Remove the artifact from any existing cell first
    artifactGrid.removeWhere((_, v) => v == artifactId);
    artifactGrid[cell] = artifactId;
    _syncHeroHpPct();
    notifyListeners();
    saveToLocal();
  }

  void removeArtifactFromGrid(int cell) {
    artifactGrid.remove(cell);
    _syncHeroHpPct();
    notifyListeners();
    saveToLocal();
  }

  /// Ranking score for an artifact: rarity first, then total stat value, then
  /// drop level. Higher = better / more worth upgrading.
  int artifactRankScore(Artifact a) =>
      a.rarity.index * 1000000 +
      (a.powerBonus + a.acBonus + a.hpPct + a.shardPct + a.goldPct + a.xpPct) * 100 +
      a.dropLevel;

  /// Owned artifacts sorted best-first (same ranking auto-equip uses), for the
  /// Collection display so the strongest / most upgrade-worthy show at the top.
  List<Artifact> get artifactsRankedBest =>
      List<Artifact>.from(ownedArtifacts)
        ..sort((x, y) => artifactRankScore(y).compareTo(artifactRankScore(x)));

  /// Auto-equip the best artifacts into every unlocked cell, ranked by rarity
  /// first, then total stat value, then drop level. Clears the grid first.
  /// Returns the number of cells filled.
  int autoEquipArtifacts() {
    if (ownedArtifacts.isEmpty) return 0;
    final sorted = List<Artifact>.from(ownedArtifacts)
      ..sort((x, y) => artifactRankScore(y).compareTo(artifactRankScore(x)));
    artifactGrid.clear();
    final n = _unlockedArtifactCells.clamp(0, sorted.length);
    for (var i = 0; i < n; i++) {
      artifactGrid[i] = sorted[i].uid;
    }
    _syncHeroHpPct();
    notifyListeners();
    saveToLocal();
    return n;
  }

  void buyUnlockArtifactCell() {
    if (_unlockedArtifactCells >= 81) return;
    final cost = 5 + (_unlockedArtifactCells ~/ 3) * 3;
    if (mythril < cost) return;
    mythril -= cost;
    _unlockedArtifactCells++;
    notifyListeners();
    saveToLocal();
  }

  int get artifactCellUnlockCost {
    if (_unlockedArtifactCells >= 81) return -1;
    return 5 + (_unlockedArtifactCells ~/ 3) * 3;
  }

  int artifactUpgradeCost(Artifact art) => 5 + art.dropLevel * 2;

  bool upgradeArtifact(String uid) {
    final idx = ownedArtifacts.indexWhere((a) => a.uid == uid);
    if (idx < 0) return false;
    final art = ownedArtifacts[idx];
    if (art.dropLevel >= 50) return false;
    final cost = artifactUpgradeCost(art);
    if (mythril < cost) return false;
    mythril -= cost;
    ownedArtifacts[idx] = Artifact(
      uid: art.uid,
      base: art.base,
      prefix: art.prefix,
      suffix: art.suffix,
      dropLevel: (art.dropLevel + 5).clamp(1, 50),
      // Preserve rarity + set membership — omitting these reset the artifact to
      // a common, non-set piece on every upgrade (silent downgrade / lost set).
      rarity: art.rarity,
      setId: art.setId,
      setPieceIndex: art.setPieceIndex,
    );
    notifyListeners();
    saveToLocal();
    return true;
  }

  // Aggregate artifact stat bonuses (individual pieces + active set bonuses).
  // Set bonuses give % damage (see artifactSetDamagePct), not flat power, so
  // the power getter only sums the individual pieces.
  int get artifactPowerBonus   => _sumArtifacts((a) => a.powerBonus);
  int get artifactAcBonus      => _sumArtifacts((a) => a.acBonus)    + _setBonusTotal((b) => b.acBonus);
  int get artifactHpPct        => _sumArtifacts((a) => a.hpPct)      + _setBonusTotal((b) => b.hpPct);
  int get artifactShardPct     => _sumArtifacts((a) => a.shardPct)   + _setBonusTotal((b) => b.shardPct);
  int get artifactGoldPct      => _sumArtifacts((a) => a.goldPct)    + _setBonusTotal((b) => b.goldPct);
  int get artifactXpPct        => _sumArtifacts((a) => a.xpPct)      + _setBonusTotal((b) => b.xpPct);

  int _sumArtifacts(int Function(Artifact) f) =>
      artifactGrid.values
          .map(artifactByUid)
          .whereType<Artifact>()
          .fold(0, (sum, a) => sum + f(a));

  /// Number of DISTINCT set pieces currently equipped for each set id.
  /// (Duplicate copies of the same piece only count once.)
  Map<String, int> get equippedSetPieceCounts {
    final bySet = <String, Set<int>>{};
    for (final uid in artifactGrid.values) {
      final a = artifactByUid(uid);
      if (a == null || !a.isSetPiece) continue;
      bySet.putIfAbsent(a.setId!, () => <int>{}).add(a.setPieceIndex);
    }
    return bySet.map((k, v) => MapEntry(k, v.length));
  }

  /// Sum of one stat across every active set bonus. A set at 2 pieces grants
  /// its 2-piece bonus; at 3 pieces it grants the 2-piece bonus PLUS the
  /// full-set (3-piece) bonus.
  int _setBonusTotal(int Function(ArtifactSetBonus) f) {
    var total = 0;
    equippedSetPieceCounts.forEach((setId, count) {
      final set = ArtifactSet.byId(setId);
      if (set == null) return;
      if (count >= 2) total += f(set.twoPieceBonus);
      if (count >= 3) total += f(set.threePieceBonus);
    });
    return total;
  }

  // Challenge modifier — one active at a time, toggled via ChallengeModifiersScreen
  String? activeModifierId;

  ChallengeModifier? get activeModifier =>
      activeModifierId == null
          ? null
          : ChallengeModifier.all
              .where((m) => m.id == activeModifierId)
              .firstOrNull;

  void setActiveModifier(String? id) {
    activeModifierId = id;
    notifyListeners();
    saveToLocal();
  }

  // Hero race + trait (chosen at character creation, permanent until full wipe)
  HeroRace? heroRace;
  HeroTrait? heroTrait;

  int get traitDmgPct   => heroTrait?.dmgPct   ?? 0;
  int get traitHpPct    => heroTrait?.hpPct     ?? 0;
  int get traitShardPct => heroTrait?.shardPct  ?? 0;
  int get traitXpPct    => heroTrait?.xpPct     ?? 0;
  int get traitGoldPct  => heroTrait?.goldPct   ?? 0;
  int get traitCooldownReduction => heroTrait?.cooldownReduction ?? 0;
  bool get traitCritImmune => heroTrait?.critImmune ?? false;

  // ── Daily Bounties ────────────────────────────────────────────────────────
  List<Bounty> _dailyBounties = [];
  int _bountyDaySeed = 0;
  List<Bounty> get dailyBounties => List.unmodifiable(_dailyBounties);

  void _refreshBountiesIfNeeded() {
    final today = DateTime.now().millisecondsSinceEpoch ~/ (1000 * 60 * 60 * 24);
    if (today != _bountyDaySeed) {
      _bountyDaySeed = today;
      final defs = BountyPool.pickDaily(today, zone: currentZone.name);
      _dailyBounties = defs.map((d) => Bounty(def: d)).toList();
    }
  }

  BestiaryWeakness? _weaknessForEnemy(String enemyId) {
    try {
      return kBestiaryEntries.firstWhere((e) => e.enemyId == enemyId).weakness;
    } catch (_) {
      return null;
    }
  }

  BountyType _weaknessBountyType(BestiaryWeakness w) => switch (w) {
    BestiaryWeakness.undead    => BountyType.killUndead,
    BestiaryWeakness.beast     => BountyType.killBeast,
    BestiaryWeakness.arcane    => BountyType.killArcane,
    BestiaryWeakness.demonic   => BountyType.killDemonic,
    BestiaryWeakness.construct => BountyType.killConstruct,
  };

  void _trackBountyProgress(BountyType type, int amount) {
    bool changed = false;
    for (final b in _dailyBounties) {
      if (b.claimed || b.def.type != type) continue;
      b.progress = (b.progress + amount).clamp(0, b.def.target);
      changed = true;
    }
    if (changed) notifyListeners();
  }

  void claimBounty(String defId) {
    final idx = _dailyBounties.indexWhere((b) => b.def.id == defId);
    if (idx < 0) return;
    final b = _dailyBounties[idx];
    if (!b.isComplete || b.claimed) return;
    b.claimed = true;
    if (b.def.reward.gold > 0) gold += b.def.reward.gold;
    if (b.def.reward.zcoins > 0) zcoins += b.def.reward.zcoins;
    if (b.def.reward.shards > 0) shards += b.def.reward.shards;
    if (b.def.reward.xp > 0) hero.gainExperience(b.def.reward.xp);
    _syncParagonLevels();
    saveToLocal();
    notifyListeners();
  }

  void recordBossRushComplete({int tier = 1}) {
    _bossRushClears++;
    if (tier > bossRushHighestTier) bossRushHighestTier = tier;
    _trackBountyProgress(BountyType.winBossRush, 1);
    rollRuneDrop(guaranteed: true);
    checkAllyMilestones();
    saveToLocal();
  }

  // ── Login Streak ──────────────────────────────────────────────────────────
  int loginStreak = 0;
  bool loginTodayClaimed = false;
  String _lastLoginDate = '';

  /// The login-reward day currently claimable — the single source of truth for
  /// both the claim and the preview (they used to compute it differently, so the
  /// preview showed Day 2 while claiming granted Day 1).
  int get loginRewardDay =>
      loginStreak <= 0 ? 1 : ((loginStreak - 1) % LoginReward.cycle.length) + 1;

  void checkLoginStreak() {
    final today = _dateKey(DateTime.now());
    if (_lastLoginDate == today) return; // already processed today
    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));
    if (_lastLoginDate == yesterday) {
      loginStreak++;
    } else if (_lastLoginDate.isEmpty) {
      loginStreak = 1;
    } else {
      loginStreak = 1; // streak broken
    }
    loginTodayClaimed = false;
    _lastLoginDate = today;
    notifyListeners();
    saveToLocal();
  }

  EquipmentItem? lastLoginLegendary;

  void claimLoginReward() {
    if (loginTodayClaimed) return;
    HapticFeedback.mediumImpact();
    final dayInCycle = loginRewardDay;
    final reward = LoginReward.forDay(dayInCycle);
    if (reward.gold > 0)     gold += reward.gold;
    if (reward.zcoins > 0) zcoins += reward.zcoins;
    if (reward.shards > 0)   shards += reward.shards;
    if (reward.echoes > 0)   echoes += reward.echoes;
    if (reward.mythril > 0)  mythril += reward.mythril;
    if (reward.essence > 0)  essence += reward.essence;
    if (reward.isEpicItem) {
      final slot = ItemSlot.values[_rng.nextInt(ItemSlot.values.length)];
      final item = ItemLootTable.craftAt(slot, ItemRarity.epic, hero.level, _rng, rebirthLevel: highestUnlockedTier);
      inventory.addToBag(item);
      lastLoginLegendary = item;
    }
    if (reward.isClassLegendary) {
      final slot = ItemSlot.values[_rng.nextInt(ItemSlot.values.length)];
      final base = ItemLootTable.craftAt(slot, ItemRarity.legendary, hero.level, _rng, rebirthLevel: highestUnlockedTier);
      final item = EquipmentItem(
        id: base.id,
        name: '${hero.heroClass.displayName}\'s ${base.name}',
        slot: base.slot,
        rarity: base.rarity,
        bonuses: base.bonuses,
        levelRequired: base.levelRequired,
        keyword: base.keyword,
        requiredClass: hero.heroClass,
      );
      inventory.addToBag(item);
      lastLoginLegendary = item;
    }
    loginTodayClaimed = true;
    notifyListeners();
    saveToLocal();
  }



  // ── Runes ─────────────────────────────────────────────────────────────────
  // Rune Dust was merged into Gem Shards (shown as "Arcane Dust") — alias so the
  // earn/spend sites keep working against one combined crafting pool.
  int get runeDust => gemShards;
  set runeDust(int v) => gemShards = v;
  final Map<String, int> _runeStockpile = {}; // defId -> count
  final Map<RuneSlot, ActiveRune?> _activeRunes = {
    RuneSlot.weapon:   null,
    RuneSlot.armor:    null,
    RuneSlot.talisman: null,
  };

  int runeStockpile(String defId) => _runeStockpile[defId] ?? 0;

  ActiveRune? activeRune(RuneSlot slot) {
    final r = _activeRunes[slot];
    if (r != null && r.isExpired) {
      _activeRunes[slot] = null;
      return null;
    }
    return r;
  }

  int get runeAtkBonus  => RuneSlot.values.fold(0, (s, sl) => s + (activeRune(sl)?.def?.atkBonus ?? 0));
  int get runeDmgBonus  => RuneSlot.values.fold(0, (s, sl) => s + (activeRune(sl)?.def?.dmgBonus ?? 0));
  int get runeAcBonus   => RuneSlot.values.fold(0, (s, sl) => s + (activeRune(sl)?.def?.acBonus  ?? 0));
  int get runeGoldPct   => RuneSlot.values.fold(0, (s, sl) => s + (activeRune(sl)?.def?.goldPct  ?? 0));
  int get runeXpPct     => RuneSlot.values.fold(0, (s, sl) => s + (activeRune(sl)?.def?.xpPct    ?? 0));
  int get runeShardPct  => RuneSlot.values.fold(0, (s, sl) => s + (activeRune(sl)?.def?.shardPct ?? 0));
  int get runeHpPct     => RuneSlot.values.fold(0, (s, sl) => s + (activeRune(sl)?.def?.hpPct    ?? 0));
  int get runeDodgeBonus => RuneSlot.values.fold(0, (s, sl) => s + (activeRune(sl)?.def?.dodgeBonus ?? 0));

  bool craftRune(String defId) {
    final def = RuneDef.byId(defId);
    if (def == null || runeDust < def.dustCost) return false;
    runeDust -= def.dustCost;
    _runeStockpile[defId] = (_runeStockpile[defId] ?? 0) + 1;
    notifyListeners();
    saveToLocal();
    return true;
  }

  bool activateRune(String defId) {
    final def = RuneDef.byId(defId);
    if (def == null) return false;
    if ((_runeStockpile[defId] ?? 0) <= 0) return false;
    _runeStockpile[defId] = (_runeStockpile[defId]! - 1);
    final expiresAt = DateTime.now().millisecondsSinceEpoch
        + def.durationMinutes * 60 * 1000;
    _activeRunes[def.slot] = ActiveRune(defId: defId, expiresAtMs: expiresAt);
    if (def.hpPct != 0) _syncHeroHpPct();
    notifyListeners();
    saveToLocal();
    return true;
  }

  // ── World Event ───────────────────────────────────────────────────────────
  int eventTokens = 0;
  int _eventWeekSeed = 0;
  final Set<String> _eventRewardsClaimed = {};

  bool eventRewardClaimed(String rewardId) => _eventRewardsClaimed.contains(rewardId);

  void _refreshEventIfNeeded() {
    final week = DateTime.now().millisecondsSinceEpoch ~/ (7 * 24 * 3600 * 1000);
    if (week != _eventWeekSeed) {
      _eventWeekSeed = week;
      eventTokens = 0;
      _eventRewardsClaimed.clear();
    }
  }

  void awardEventTokens(int amount) {
    _refreshEventIfNeeded();
    eventTokens += amount;
    notifyListeners();
    saveToLocal();
  }

  bool buyEventReward(String rewardId) {
    _refreshEventIfNeeded();
    if (_eventRewardsClaimed.contains(rewardId)) return false;
    final shop = WorldEventReward.eventShop(hero.level);
    final reward = shop.where((r) => r.id == rewardId).firstOrNull;
    if (reward == null || eventTokens < reward.tokenCost) return false;
    eventTokens -= reward.tokenCost;
    _eventRewardsClaimed.add(rewardId);
    if (reward.zcoins > 0) zcoins += reward.zcoins;
    if (reward.gold > 0) gold += reward.gold;
    if (reward.shards > 0) shards += reward.shards;
    if (reward.essence > 0) essence += reward.essence;
    if (reward.mythril > 0) mythril += reward.mythril;
    if (reward.echoes > 0) echoes += reward.echoes;
    if (reward.type == EventRewardType.gear && reward.gearSlot != null && reward.gearRarity != null) {
      final item = ItemLootTable.craftAt(
        reward.gearSlot!, reward.gearRarity!, hero.level, _rng,
        rebirthLevel: highestUnlockedTier,
      );
      inventory.addToBag(item);
    }
    notifyListeners();
    saveToLocal();
    return true;
  }

  // ── Challenge Gauntlet ────────────────────────────────────────────────────
  int gauntletHighScore = 0;
  int gauntletHighestTier = 0;

  // Last modifier set the player ran, so the Gauntlet pre-selects it by default.
  List<String> lastGauntletModifierIds = [];
  void setLastGauntletModifiers(List<String> ids) {
    lastGauntletModifierIds = List<String>.from(ids);
    saveToLocal();
  }

  void recordGauntletResult(GauntletResult result, {int tier = 1}) {
    if (result.score > gauntletHighScore) gauntletHighScore = result.score;
    if (result.cleared && tier >= gauntletHighestTier) gauntletHighestTier = tier;
    if (result.essenceEarned > 0) essence += result.essenceEarned;
    if (result.zcoinsEarned > 0) zcoins += result.zcoinsEarned;
    if (result.echoesEarned > 0) echoes += result.echoesEarned;
    if (result.cleared) {
      rollRuneDrop(guaranteed: true);
      advanceWeekly('w_gauntlet', 1);
    }
    checkAllyMilestones();
    notifyListeners();
    saveToLocal();
  }

  // ── NPC Allies ────────────────────────────────────────────────────────────
  final Map<String, int> _allyLevels = {};   // id → 1..5 (0 / absent = locked)
  // talent choices: key = '${mercId}_${talentLevel}', value = 'a' | 'b'
  final Map<String, String> _allyTalents = {};

  bool allyUnlocked(String id) => (_allyLevels[id] ?? 0) >= 1;
  int  allyLevel(String id)    => _allyLevels[id] ?? 0;

  /// Returns the chosen talent option for [mercId] at [talentLevel] (3 or 5), or null if not chosen yet.
  AllyTalentOption? allyChosenTalent(String mercId, int talentLevel) {
    final choiceId = _allyTalents['${mercId}_$talentLevel'];
    if (choiceId == null) return null;
    final def = NpcAllyDef.all.firstWhere((d) => d.id == mercId,
        orElse: () => throw StateError(mercId));
    final talentDef = talentLevel == 3 ? def.talent3 : def.talent5;
    if (talentDef == null) return null;
    return choiceId == 'a' ? talentDef.optionA : talentDef.optionB;
  }

  /// Choose (or re-choose) a talent branch for [mercId] at [talentLevel].
  void chooseAllyTalent(String mercId, int talentLevel, String optionId) {
    if (allyLevel(mercId) < talentLevel) return;
    _allyTalents['${mercId}_$talentLevel'] = optionId;
    _syncHeroHpPct();
    notifyListeners();
    saveToLocal();
  }

  List<NpcAllyDef> get unlockedAllies =>
      NpcAllyDef.all.where((a) => allyUnlocked(a.id)).toList();

  /// Sum a stat across all unlocked allies' base bonuses + chosen talents.
  int _allyIntStat(int Function(NpcAllyDef) base, int Function(AllyTalentOption) talent) {
    var total = 0;
    for (final a in unlockedAllies) {
      total += base(a) * allyLevel(a.id);
      for (final lvl in [3, 5]) {
        final t = allyChosenTalent(a.id, lvl);
        if (t != null) total += talent(t);
      }
    }
    return total;
  }

  double _allyDblStat(double Function(NpcAllyDef) base, double Function(AllyTalentOption) talent) {
    var total = 0.0;
    for (final a in unlockedAllies) {
      total += base(a) * allyLevel(a.id);
      for (final lvl in [3, 5]) {
        final t = allyChosenTalent(a.id, lvl);
        if (t != null) total += talent(t);
      }
    }
    return total;
  }

  // ── Level-scaled bonuses (base × level + chosen talents) ─────────────────
  // Allies' single unified damage stat: % increased damage (feeds allDamagePct,
  // not flat power — flat was worthless once heroes hit for thousands).
  int  get allyDmgPctBonus => _allyIntStat((a) => a.dmgPctBonus, (t) => t.dmgPctBonus)
                          + activeSynergies.fold(0, (s, y) => s + y.dmgPctBonus);
  int  get allyAcBonus   => _allyIntStat((a) => a.acBonus,   (t) => t.acBonus)
                          + activeSynergies.fold(0, (s, y) => s + y.acBonus);
  double get allyGoldMult  => 1.0
      + _allyDblStat((a) => a.goldPctBonus,  (t) => t.goldPctBonus)
      + activeSynergies.fold(0.0, (s, y) => s + y.goldPctBonus);
  double get allyXpMult    => 1.0
      + _allyDblStat((a) => a.xpPctBonus,    (t) => t.xpPctBonus)
      + activeSynergies.fold(0.0, (s, y) => s + y.xpPctBonus);
  double get allyShardMult => 1.0
      + _allyDblStat((a) => a.shardPctBonus, (t) => t.shardPctBonus)
      + activeSynergies.fold(0.0, (s, y) => s + y.shardPctBonus);
  double get allyIdleMult  => 1.0
      + _allyDblStat((a) => a.idlePctBonus,  (t) => t.idlePctBonus)
      + activeSynergies.fold(0.0, (s, y) => s + y.idlePctBonus);
  int    get allyHpPct     => (
      (_allyDblStat((a) => a.hpPctBonus, (t) => t.hpPctBonus)
      + activeSynergies.fold(0.0, (s, y) => s + y.hpPctBonus)) * 100).round();

  // ── Synergies ─────────────────────────────────────────────────────────────
  List<SynergyDef> get activeSynergies => SynergyDef.all
      .where((s) => allyLevel(s.ally1Id) >= s.minLevel
                 && allyLevel(s.ally2Id) >= s.minLevel)
      .toList();

  // ── Level-up ──────────────────────────────────────────────────────────────
  /// True if any unlocked mercenary has an affordable level-up available —
  /// drives the "upgrade ready" indicator on the MERCS panel.
  bool get hasAffordableAllyUpgrade {
    for (final def in unlockedAllies) {
      final cur = allyLevel(def.id);
      if (cur == 0 || cur >= NpcAllyDef.maxLevel) continue;
      final (costShards, costCrystals) = NpcAllyDef.levelUpCost(cur + 1);
      if (shards >= costShards && zcoins >= costCrystals) return true;
    }
    return false;
  }

  bool upgradeAlly(String id) {
    final cur = allyLevel(id);
    if (cur == 0 || cur >= NpcAllyDef.maxLevel) return false;
    final (costShards, costCrystals) = NpcAllyDef.levelUpCost(cur + 1);
    if (shards < costShards || zcoins < costCrystals) return false;
    shards   -= costShards;
    zcoins -= costCrystals;
    _allyLevels[id] = cur + 1;
    _syncHeroHpPct();
    notifyListeners();
    saveToLocal();
    return true;
  }

  // ── Milestone check ───────────────────────────────────────────────────────
  void checkAllyMilestones() {
    var any = false;
    for (final def in NpcAllyDef.all) {
      if (allyUnlocked(def.id)) continue;
      final progress = allyMilestoneProgress(def);
      if (progress >= def.milestoneTarget) {
        _allyLevels[def.id] = 1;
        any = true;
        _syncHeroHpPct();
      }
    }
    if (any) {
      notifyListeners();
      saveToLocal();
    }
  }

  int allyMilestoneProgress(NpcAllyDef def) => switch (def.milestone) {
    AllyMilestone.killCount            => _totalKills,
    AllyMilestone.campaignStage        => campaignStageIndex + 1,
    AllyMilestone.prestigeLevel        => highestUnlockedTier, // now tracks tier unlocks
    AllyMilestone.ascensionLevel       => ascensionLevel,
    AllyMilestone.dungeonClears        => _dungeonClears,
    AllyMilestone.bossRushClears       => _bossRushClears,
    AllyMilestone.gauntletScore        => gauntletHighScore,
    AllyMilestone.achievementsUnlocked => achievementsUnlocked,
  };

  // Class questlines
  final Map<String, bool> questsClaimed = {};
  String? heroTitle;
  int _totalGoldEarned   = 0;
  int _totalIdleCollects = 0;
  int _totalForges       = 0;
  int _totalDisenchants  = 0;
  bool _survivedAt1HP    = false;

  // Public reads for UI
  int  get totalKills       => _totalKills;
  int  get totalBattleWins  => _totalBattleWins;
  int  get totalBossKills   => _totalBossKills;
  int  get totalDamageDealt => _totalDamageDealt;
  int  get totalGoldEarned  => _totalGoldEarned;
  int  get dungeonClears    => _dungeonClears;
  bool get survivedAt1HP    => _survivedAt1HP;

  // ── Achievements ───────────────────────────────────────────────────────────
  final List<Achievement> achievements = buildAchievements();

  // Re-apply saved achievement state onto the (freshly rebuilt) list — used to
  // persist achievements through rebirth/ascension, which reset everything else.
  void _restoreAchievements(List<Map<String, dynamic>> saved) {
    final byId = {for (final e in saved) e['id'] as String: e};
    for (final a in achievements) {
      if (byId.containsKey(a.id)) a.loadFromJson(byId[a.id]!);
    }
  }

  int get achievementsUnlocked  => achievements.where((a) => a.unlocked).length;
  int get achievementsClaimable => achievements.where((a) => a.unlocked && !a.claimed).length;

  int getAchievementProgress(Achievement a) => switch (a.condition) {
    AchievementCondition.totalBattleWins    => _totalBattleWins,
    AchievementCondition.totalKills         => _totalKills,
    AchievementCondition.totalBossKills     => _totalBossKills,
    AchievementCondition.totalDamageDealt   => _totalDamageDealt,
    AchievementCondition.totalGoldEarned    => _totalGoldEarned,
    AchievementCondition.totalIdleCollects  => _totalIdleCollects,
    AchievementCondition.totalForges        => _totalForges,
    AchievementCondition.totalDisenchants   => _totalDisenchants,
    AchievementCondition.heroLevel          => hero.level,
    AchievementCondition.campaignStage      => campaignStageIndex + 1,
    AchievementCondition.prestigeLevel      => highestUnlockedTier, // now tracks tier unlocks
    AchievementCondition.passiveNodesUnlocked => passiveTree.unlockedCount,
    AchievementCondition.survivedAt1HP      => _survivedAt1HP ? 1 : 0,
    AchievementCondition.subclassChosen     => subclassId != null ? 1 : 0,
  };

  void _checkAchievements() {
    var any = false;
    for (final a in achievements) {
      if (a.unlocked) continue;
      if (getAchievementProgress(a) >= a.target) {
        a.unlocked = true;
        any = true;
        steamService.unlockAchievement(a.id);
      }
    }
    if (any) notifyListeners();
  }

  void claimAchievement(String id) {
    final a = achievements.firstWhere((a) => a.id == id, orElse: () => throw StateError(id));
    if (!a.unlocked || a.claimed) return;
    HapticFeedback.lightImpact();
    a.claimed = true;
    switch (a.rewardType) {
      case AchievementRewardType.shards:   shards  += a.rewardAmount;
      case AchievementRewardType.essence:  essence += a.rewardAmount;
      case AchievementRewardType.zcoins: zcoins += a.rewardAmount;
    }
    _setLastAction('Achievement claimed: ${a.name}! +${a.rewardLabel}');
    notifyListeners();
    saveToLocal();
  }

  /// Claims every unlocked-but-unclaimed achievement and returns a summary of
  /// what was granted, so the UI can show the player exactly what they received.
  ({int count, int shards, int essence, int zcoins}) claimAllAchievements() {
    var count = 0, gainedShards = 0, gainedEssence = 0, gainedZcoins = 0;
    for (final a in achievements.where((a) => a.unlocked && !a.claimed)) {
      a.claimed = true;
      count++;
      switch (a.rewardType) {
        case AchievementRewardType.shards:   gainedShards  += a.rewardAmount;
        case AchievementRewardType.essence:  gainedEssence += a.rewardAmount;
        case AchievementRewardType.zcoins:   gainedZcoins  += a.rewardAmount;
      }
    }
    shards  += gainedShards;
    essence += gainedEssence;
    zcoins  += gainedZcoins;
    notifyListeners();
    saveToLocal();
    return (count: count, shards: gainedShards, essence: gainedEssence, zcoins: gainedZcoins);
  }

  // ── Item shop ──────────────────────────────────────────────────────────────
  final List<EquipmentItem> _shopStock = [];
  String _shopDate   = '';
  int    _shopRerolls = 0;

  // Daily Featured Deal — one guaranteed high-rarity item at a discount,
  // regenerated once per day and NOT affected by rerolls.
  EquipmentItem? _featuredDeal;
  bool _featuredPurchased = false;
  static const double featuredDiscount = 0.30; // 30% off

  EquipmentItem? get featuredDeal { _ensureShopStock(); return _featuredDeal; }
  bool get featuredPurchased => _featuredPurchased;
  int featuredDealPrice() =>
      _featuredDeal == null ? 0 : (shopPriceFor(_featuredDeal!) * (1 - featuredDiscount)).round();

  List<EquipmentItem> shopItemsForSlot(ItemSlot slot) {
    _ensureShopStock();
    return _shopStock.where((i) => i.slot == slot).toList();
  }

  int shopPriceFor(EquipmentItem item) {
    final lvScaling = item.levelRequired * 18;
    final base = switch (item.rarity) {
      ItemRarity.common    => 180  + lvScaling,
      ItemRarity.uncommon  => 350  + lvScaling,
      ItemRarity.rare      => 600  + lvScaling * 2,
      ItemRarity.epic      => 2000 + lvScaling * 4,
      ItemRarity.legendary => 8000 + lvScaling * 8,
      ItemRarity.mythic    => 25000 + lvScaling * 15,
      ItemRarity.set       => 6000 + lvScaling * 6,
      ItemRarity.unique    => 12000 + lvScaling * 10,
    };
    return base + hero.level * 40;
  }

  // Reroll cost climbs each time within a day, resetting at the daily refresh,
  // so rerolling is a real choice rather than a spammable slot machine.
  static const int shopRerollBaseCost = 15;
  int get shopRerollCost => shopRerollBaseCost + _shopRerolls * 10;

  bool buyShopItem(EquipmentItem item) {
    final price = shopPriceFor(item);
    if (gold < price) return false;
    gold -= price;
    _shopStock.remove(item);
    inventory.addToBag(item);
    notifyListeners();
    saveToLocal();
    return true;
  }

  /// Buys the discounted Featured Deal (once per day).
  bool buyFeaturedDeal() {
    _ensureShopStock();
    final item = _featuredDeal;
    if (item == null || _featuredPurchased) return false;
    final price = featuredDealPrice();
    if (gold < price) return false;
    gold -= price;
    _featuredPurchased = true;
    inventory.addToBag(item);
    notifyListeners();
    saveToLocal();
    return true;
  }

  bool rerollShop() {
    final cost = shopRerollCost;
    if (shards < cost) return false;
    shards -= cost;
    _shopRerolls++;
    _regenerateShop();
    notifyListeners();
    saveToLocal();
    return true;
  }

  void _ensureShopStock() {
    final today = _dateKey(DateTime.now());
    if (_shopDate != today) {
      _shopDate    = today;
      _shopRerolls = 0;
      _featuredPurchased = false;
      _regenerateFeatured();
      _regenerateShop();
    } else {
      if (_shopStock.isEmpty) _regenerateShop();
      if (_featuredDeal == null) _regenerateFeatured();
    }
  }

  /// Rarity odds improve with hero level and prestige so the shop stays
  /// relevant late-game (commons phase out as you grow).
  ItemRarity _shopRarityRoll(Random rng) {
    final tierBoost = (hero.level ~/ 10) + highestUnlockedTier * 2;
    final epicPct = (10 + tierBoost * 2).clamp(10, 45);
    final rarePct = (30 + tierBoost).clamp(30, 45);
    final roll = rng.nextInt(100);
    if (roll < epicPct) return ItemRarity.epic;
    if (roll < epicPct + rarePct) return ItemRarity.rare;
    return ItemRarity.common;
  }

  void _regenerateFeatured() {
    final now     = DateTime.now();
    final dateInt = now.year * 10000 + now.month * 100 + now.day;
    final rng     = Random(dateInt * 31 + 9973);
    final slot    = ItemSlot.values[rng.nextInt(ItemSlot.values.length)];
    // Featured is always high rarity: mostly epic, sometimes legendary.
    final rarity  = rng.nextInt(100) < 30 ? ItemRarity.legendary : ItemRarity.epic;
    _featuredDeal = ItemLootTable.craftAt(slot, rarity, max(1, hero.level), rng,
        rebirthLevel: highestUnlockedTier);
  }

  void _regenerateShop() {
    _shopStock.clear();
    final now     = DateTime.now();
    final dateInt = now.year * 10000 + now.month * 100 + now.day;
    for (var si = 0; si < ItemSlot.values.length; si++) {
      final slot = ItemSlot.values[si];
      final rng  = Random(dateInt + si * 1000 + _shopRerolls * 7777);
      for (var i = 0; i < 3; i++) {
        final rarity = _shopRarityRoll(rng);
        _shopStock.add(ItemLootTable.craftAt(slot, rarity, max(1, hero.level), rng,
            rebirthLevel: highestUnlockedTier));
      }
    }
  }

  // Passive skill tree
  // Essence was merged into Shards — it's now an alias so the many essence
  // earn/spend sites keep working while there is a single combined pool.
  int get essence => shards;
  set essence(int v) => shards = v;
  final PassiveTree passiveTree = PassiveTree();

  bool upgradePassive(String id) {
    if (!passiveTree.canUpgrade(id)) return false;
    final cost = passiveTree.costForNextRank(id);
    if (essence < cost) return false;
    essence -= cost;
    passiveTree.upgrade(id);
    // maxHp passives (e.g. Iron Skin) are cached into hero.extraHpPct rather than
    // read live like every other passive effect, so recompute it now — otherwise
    // ranking an HP node wouldn't change max HP until some other resync fired.
    _syncHeroHpPct();
    _checkAchievements();
    notifyListeners();
    saveToLocal();
    return true;
  }

  // Legacy alias kept for any call sites not yet updated
  bool unlockPassive(String id) => upgradePassive(id);

  bool respecBranch(PassiveBranch branch) {
    final refund = passiveTree.respecBranchRefund(branch);
    if (passiveTree.branchPointsSpent(branch) == 0) return false;
    passiveTree.respecBranch(branch);
    essence += refund;
    _syncHeroHpPct(); // maxHp nodes are cached — refresh after removing ranks
    notifyListeners();
    saveToLocal();
    return true;
  }

  bool fullRespec() {
    if (zcoins < 50) return false;
    final refund = passiveTree.fullRespecRefund;
    zcoins -= 50;
    passiveTree.fullRespec();
    essence += refund;
    _syncHeroHpPct(); // maxHp nodes are cached — refresh after removing ranks
    notifyListeners();
    saveToLocal();
    return true;
  }

  // Prestige
  int prestigeLevel = 0;
  int prestigeSouls = 0;
  final PrestigeShop prestigeShop = PrestigeShop();

  // Rebirth challenge & boon state (resets each prestige)
  RebirthChallenge activeRebirthChallenge = RebirthChallenge.none;
  double _boonXpMult     = 1.0;  // 1.6 if ancestral_wisdom boon active
  double _challengeGoldMult = 1.0;  // 0.7 if ascetic challenge active
  int _challengeHpPenalty   = 0;    // -25 if ruthless challenge active

  // Tracks which prestige milestone levels have already granted their reward
  final Set<int> _earnedPrestigeMilestones = {};

  // Rebirth unlocks when the player completes the full campaign (beats stage 100 — Omega Absolute).
  bool get canPrestige => campaignStageIndex >= 100;

  /// True once the player has reached any endgame milestone — a Rebirth or any
  /// Ascension. From here on, everything that was ever unlocked stays unlocked
  /// even though a Rebirth/Ascension resets campaign progress to 0.
  bool get endgameUnlocked =>
      highestUnlockedTier > 0 || // unlocking a tier is the modern endgame trigger
      prestigeLevel > 0 ||
      _confirmedPrestigeLevel > 0 ||
      totalAscensionAp > 0 ||
      ascensionLevel > 0;

  /// Effective stage for unlock checks — at least 100 once in the endgame so
  /// previously unlocked content stays accessible even though campaignStageIndex
  /// resets to 0. (Ascension zeroes prestigeLevel, so we key off endgameUnlocked
  /// rather than prestige alone.)
  int get effectiveUnlockStage =>
      endgameUnlocked ? max(campaignStageIndex, 100) : campaignStageIndex;

  /// Boss Bounties unlock at campaign stage 20 (matches _unlockStageNames + the
  /// tutorial). The BOUNTIES tab lives inside the Challenges screen (unlocked at
  /// stage 5), so it must gate on this — not just on Challenges being open.
  bool get bossBountiesUnlocked => effectiveUnlockStage >= 20;

  /// Named title earned at each prestige milestone (highest earned is shown).
  static const _prestigeTitles = <int, (String title, String emoji)>{
    1:  ('Reborn',        '🔥'),
    2:  ('Twice-Forged',  '⚒'),
    3:  ('Veteran',       '🛡'),
    5:  ('Champion',      '⚔'),
    7:  ('Warlord',       '🗡'),
    10: ('Legend',        '💀'),
    15: ('Mythic',        '✦'),
    20: ('Arcane Lord',   '🔮'),
    25: ('Eternal',       '♾'),
    50: ('Transcendent',  '🌟'),
  };

  /// Returns the highest earned (title, emoji), or null if never prestiged.
  (String, String)? get prestigeTitle {
    if (prestigeLevel == 0) return null;
    final keys = _prestigeTitles.keys.where((k) => k <= prestigeLevel).toList()
      ..sort();
    if (keys.isEmpty) return null;
    return _prestigeTitles[keys.last];
  }

  // Permanent buffs now scale with your highest unlocked difficulty Tier (they
  // used to scale per rebirth). They're kept when you switch tiers DOWN, and
  // stack with the Paragon board. Existing rebirthed saves keep the value since
  // highestUnlockedTier was seeded from prestigeLevel.
  double get prestigeGoldMult    => (1.0 + highestUnlockedTier * 0.15) * _challengeGoldMult * ascGoldMult * ascPrestigeMult
      * (1.0 + prestigeShop.paragonTotal(ParagonEffect.gold) / 100);
  double get prestigeXpMult      => (1.0 + highestUnlockedTier * 0.10)
      * (prestigeShop.isUnlocked('swift_learner') ? 1.30 : 1.0)
      * (1.0 + prestigeShop.paragonTotal(ParagonEffect.xp) / 100)
      * _boonXpMult * ascXpMult * ascPrestigeMult;
  double get prestigeIdleMult    => (1.0 + highestUnlockedTier * 0.10) * ascIdleMult * ascPrestigeMult
      * (1.0 + prestigeShop.paragonTotal(ParagonEffect.idle) / 100);
  /// Flat % damage bonus — +3.5% per unlocked Tier, plus Destroyer node & Paragon.
  // Diminishing-returns soft cap for runaway additive %s: values ≤ [soft] pass
  // through unchanged; above [soft] each extra point is worth progressively less,
  // asymptoting to [soft] + [k]. Keeps early/mid progression intact while stopping
  // endgame multipliers (paragon dmg, endless str) from scaling to infinity and
  // trivialising every boss. Tunable per call.
  static double softCapPct(double raw, double soft, double k) =>
      raw <= soft ? raw : soft + (raw - soft) * k / (k + (raw - soft));

  double get prestigeDamageMult  => (1.0 + highestUnlockedTier * 0.035)
      * (prestigeShop.isUnlocked('destroyer') ? 1.05 : 1.0)
      // Paragon damage % soft-capped: linear ≤ +1500%, then diminishes toward a
      // +1500%+3000% = +4500% (×46) asymptote (was uncapped, e.g. +6493% = ×66).
      * (1.0 + softCapPct(prestigeShop.paragonTotal(ParagonEffect.damage), 1500, 3000) / 100)
      * (prestigeShop.isUnlocked('paragon_dominance') ? (1.0 + highestUnlockedTier * 0.01) : 1.0);
  double get prestigeShardMult   => (prestigeShop.isUnlocked('carrion_picker') ? 1.50 : 1.0) * ascShardMult;
  double get prestigeEssenceMult => (prestigeShop.isUnlocked('essence_bonus')  ? 1.50 : 1.0) * ascEssenceMult;
  int    get prestigeIdleBonus   => prestigeShop.isUnlocked('idle_bonus') ? 30 : 0;
  /// Paragon gold income multiplier — from Blood Tithe and War Spoils nodes (% bonus).
  double get paragonGoldIncomeMult {
    if (activeRebirthChallenge == RebirthChallenge.pauper) return 1.0;
    var mult = 1.0;
    if (prestigeShop.isUnlocked('start_gold')) mult += 0.20;
    if (prestigeShop.isUnlocked('war_spoils')) mult += 0.35;
    return mult;
  }
  int    get prestigeStartGold {
    if (activeRebirthChallenge == RebirthChallenge.pauper) return 0;
    return prestigeShop.isUnlocked('instant_recall') ? 1500 : 0;
  }
  int get prestigeHeadStart {
    if (prestigeShop.isUnlocked('soul_overdrive')) return 40; // Stage 41
    return 0;
  }
  double get prestigeAbilityDiscount =>
      prestigeShop.isUnlocked('ability_disc') ? 0.65 : 1.0;
  int get forgeCommonToRareCount =>
      prestigeShop.isUnlocked('forge_bonus') ? 2 : 3;

  // ── New prestige effect getters ────────────────────────────────────────────
  int    get prestigeHpPct          => (prestigeShop.isUnlocked('iron_resolve') ? 30 : 0) + prestigeShop.paragonTotal(ParagonEffect.hp).round() + _challengeHpPenalty;

  // ── Rebirth boon / challenge helpers ──────────────────────────────────────
  /// Preview soul total for the current run, given an optional boon/challenge.
  int soulsEarnedPreview({RebirthChallenge challenge = RebirthChallenge.none, RebirthBoon? boon}) {
    final base      = (campaignStageIndex / 5).floor().clamp(1, 200);
    final dungeon   = _dungeonClears.clamp(0, 20);
    final bossRush  = bossRushHighestTier.clamp(0, 5);
    final gauntlet  = (gauntletHighScore / 10).floor().clamp(0, 10);
    final conduit   = prestigeSoulConduit;
    final boonBonus = boon?.effect == RebirthBoonEffect.bonusSouls ? boon!.value.toInt() : 0;
    return (base + dungeon + bossRush + gauntlet + conduit + challenge.bonusSouls + boonBonus).clamp(1, 9999);
  }
  // Blood Drinker — reworked from a fixed 5% heal-on-kill (didn't scale, and was
  // an uncapped sustain source) into LIFESTEAL: heal a % of damage dealt, which
  // scales with your power and rides the shared per-round lifesteal cap.
  int    get prestigeLifestealPct   => prestigeShop.isUnlocked('blood_drinker') ? 6 : 0;
  int    get prestigeCritBonus      => (prestigeShop.isUnlocked('killing_blow')  ? 8  : 0) + prestigeShop.paragonTotal(ParagonEffect.crit).round();
  double get prestigeCritDamageMult => (prestigeShop.isUnlocked('deaths_edge')   ? 1.05: 1.0) * (1.0 + prestigeShop.paragonTotal(ParagonEffect.critDmg) / 100);

  // ── Central crit chance aggregator ───────────────────────────────────────
  // All former "attack bonus" sources are repurposed as +1% crit per point.
  // Public getter for hero's total flat armor value (shown in battle UI)
  int get heroArmorValue {
    final flat = hero.armorClass
        + passiveTree.totalOf(PassiveEffect.armorFlat)
        + _masteryTotal(MasteryEffect.permanentAC)
        + questACBonus
        + inventory.totalOf(ItemStat.armorClass)
        + inventory.totalOf(ItemStat.strength)
        + petArmor + skinArmor + auraArmor
        + _setTotal(ItemStat.armorClass) + _setTotal(ItemStat.strength)
        + _gemTotal(ItemStat.armorClass) + _gemTotal(ItemStat.strength)
        + artifactAcBonus + runeAcBonus
        // Endless-upgrade (CON) armour sources — previously only the campaign's
        // inline sum had these, so modes + the Bonuses sheet under-counted armour.
        + (endlessUpgrades.lightFooted ? 5 : 0)
        + (_hasKeyword(ItemKeyword.ironWill) ? 1 : 0)
        + (endlessUpgrades.synergyJuggernaut ? 1 : 0)
        + endlessUpgrades.flatDamageReduction
        + (endlessUpgrades.thickHide ? 3 : 0)
        + _scoreFor;
    // Subclass armor, mercenary AC, and the Ward (WRD) score are all %
    // increases to total armor rating.
    return (flat * (1 + (subclassArmorPct + allyAcBonus + _scoreDurPct) / 100.0)).round();
  }

  // Raw crit chance summed from every source, BEFORE the 100% cap. Anything
  // above 100% is "overflow" that is recycled into bonus crit damage (see
  // [critOverflowPct] / [totalCritDamageMult]) so heavily-invested crit builds
  // never waste a point.
  int get rawCritChancePct {
    // Crit chance now comes ONLY from gear — attack-bonus and dexterity affixes
    // on equipped items and set bonuses. Every other source was removed to make
    // crit a deliberate gear specialization; they grant % All Damage instead
    // (see [critReplacementDamagePct]).
    final fromItems = inventory.totalOf(ItemStat.attackBonus) * 2
                    + inventory.totalOf(ItemStat.dexterity);
    final fromSets  = _setTotal(ItemStat.attackBonus) * 2
                    + _setTotal(ItemStat.dexterity);
    return (fromItems + fromSets).clamp(0, 999999999);
  }

  // Effective crit chance used in combat — now capped at 100% (was 75%).
  int get totalCritChancePct => rawCritChancePct.clamp(0, 100);

  // Crit chance beyond 100%, recycled into crit damage at 1% dmg per 1% overflow.
  int get critOverflowPct => (rawCritChancePct - 100).clamp(0, 9999);

  // Crit damage multiplier (combined from all sources). Overflow crit chance is
  // folded in here: every 1% of overflow adds +1% crit damage (+0.01 multiplier).
  double get totalCritDamageMult {
    // Crit damage is gear-only: base 2×, upgraded to 3× by the Critical Fury item
    // keyword, plus the overflow recycled from >100% gear crit chance. Score /
    // subclass / prestige crit-damage was removed and folded into % All Damage.
    final base = _hasKeyword(ItemKeyword.criticalFury) ? 3.0 : 2.0;
    final overflowBonus = critOverflowPct / 100.0;
    return (base + overflowBonus).clamp(1.5, 10.0);
  }

  /// % All Damage granted in place of the crit chance / crit damage that used to
  /// come from non-gear sources (ability scores, subclass, echo upgrades). Keeps
  /// those investments meaningful now that crit is a gear-only specialization.
  double get critReplacementDamagePct {
    var pct = 0.0;
    pct += _scorePrc * 0.5;                  // Might score (% damage)
    // (Vigor 'agi' now grants % max HP, not damage — see _syncHeroHpPct.)
    pct += subclassCritChancePct * 0.5;      // subclass crit-chance → damage
    pct += subclassCritDmgPct * 0.25;        // subclass crit-damage → damage
    if (subclassEffect == SubclassEffect.champion) pct += 8;
    if (subclassEffect == SubclassEffect.assassin) pct += 10;
    if (endlessUpgrades.ironGrip) pct += 10;  // Iron Grip echo (was +12 crit)
    if (endlessUpgrades.keenEdge) pct += 12;  // Keen Edge echo (was +20 crit)
    pct += endlessUpgrades.attackRollBonus.toDouble(); // DEX/Precision echo (was crit)
    // Capped small to scale down damage (was reaching 200%+ from stacked scores
    // /echoes). Tunable.
    return pct.clamp(0, 10);
  }
  double get prestigeGoldBattleMult => prestigeShop.isUnlocked('treasure_sense') ? 1.35 : 1.0;
  int    get prestigeSoulConduit    => prestigeShop.isUnlocked('soul_conduit')   ? 5  : 0;

  bool purchasePrestigeNode(String nodeId) {
    final node = kPrestigeNodes.firstWhere((n) => n.id == nodeId,
        orElse: () => throw StateError('Unknown prestige node: $nodeId'));
    if (!prestigeShop.canUnlock(node, prestigeSouls)) return false;
    prestigeSouls -= node.soulCost;
    prestigeShop.forceUnlock(nodeId);
    notifyListeners();
    saveToLocal();
    return true;
  }

  /// Invest a Paragon Point into a rankable board stat (infinite sink).
  bool rankUpParagon(String id) {
    final stat = paragonStatById(id);
    if (stat == null) return false;
    final cost = prestigeShop.paragonCost(stat);
    if (prestigeSouls < cost) return false;
    prestigeSouls -= cost;
    prestigeShop.rankUpParagon(id);
    notifyListeners();
    saveToLocal();
    return true;
  }

  Future<void> prestige({RebirthBoon? boon, RebirthChallenge challenge = RebirthChallenge.none}) async {
    if (!canPrestige) return;
    final savedName         = hero.name;
    final savedClass        = hero.heroClass;
    final savedShards       = shards;
    final savedEchoes       = echoes;
    final savedRanks        = Map<String, int>.from(_abilityRanks);
    final savedAbilityAsc   = Map<String, int>.from(_abilityAscension);
    final savedBranches     = Map<String, String>.from(abilityBranches);
    final savedMilestones   = Map<String, String>.from(_milestoneChoices);
    final savedEssence      = essence;
    final savedTree         = Map<String, dynamic>.from(passiveTree.toJson());
    final savedQuests       = Map<String, bool>.from(questsClaimed);
    // Achievements are lifetime — persist their unlocked/claimed state through
    // a rebirth (_resetToDefaults rebuilds them fresh).
    final savedAchievements = achievements.map((a) => a.toJson()).toList();
    final savedTitle        = heroTitle;
    final savedAbilityUses  = _totalAbilityUses;

    // Multi-source soul formula
    final baseSouls     = (campaignStageIndex / 5).floor().clamp(1, 200);
    final dungeonBonus  = _dungeonClears.clamp(0, 20);
    final bossBonus     = bossRushHighestTier.clamp(0, 5);
    final gauntletBonus = (gauntletHighScore / 10).floor().clamp(0, 10);
    final boonSouls     = boon?.effect == RebirthBoonEffect.bonusSouls ? boon!.value.toInt() : 0;
    final soulsEarned   = (baseSouls + dungeonBonus + bossBonus + gauntletBonus
                          + prestigeSoulConduit + challenge.bonusSouls + boonSouls)
                          .clamp(1, 9999);

    final savedPrestigeLvl = prestigeLevel + 1;
    AnalyticsService.instance.prestige(savedPrestigeLvl, soulsEarned, campaignStageIndex);
    // Snapshot balances at this natural checkpoint (pre-reset) for pacing curves.
    AnalyticsService.instance.economySnapshot(
      stage: campaignStageIndex, level: hero.level, prestige: prestigeLevel,
      gold: gold, shards: shards, echoes: echoes, zcoins: zcoins, mythril: mythril);
    final savedSouls       = prestigeSouls + soulsEarned;
    final savedShopOwned   = Map<String, bool>.from(prestigeShop.ownedNodes);

    // Artifact vault — preserve artifacts if node owned
    List<Artifact>? savedArtifacts;
    Map<int, String>? savedArtifactGrid;
    int? savedArtifactCells;
    if (prestigeShop.isUnlocked('artifact_vault')) {
      savedArtifacts     = List<Artifact>.from(ownedArtifacts);
      savedArtifactGrid  = Map<int, String>.from(artifactGrid);
      savedArtifactCells = _unlockedArtifactCells;
    }

    // Mythril memory — keep 30% of current mythril
    final mythrilMemoryKeep = prestigeShop.isUnlocked('mythril_memory')
        ? (mythril * 0.30).floor() : 0;

    // Elemental Mastery — always persists through rebirth
    final savedTowerShards    = towerShards;
    final savedMasteryRanks   = Map<String, int>.from(_elementalMasteryRanks);
    // Ascension is a HIGHER tier than Rebirth — it must survive a rebirth.
    // (_resetToDefaults zeroes these; without this save/restore a rebirth would
    // wipe all ascension progress.)
    final savedAscLevel       = ascensionLevel;
    final savedAscPoints      = ascensionPoints;
    final savedAscNodes       = Map<String, int>.from(_ascensionNodes);
    final savedTotalAscAp     = totalAscensionAp;

    // Permanent progression — always persists through rebirth
    final savedOwnedPets      = Set<String>.from(ownedPetIds);
    final savedEquippedPet    = equippedPetId;
    final savedPetEvolution   = Map<String, int>.from(petEvolutionLevels);
    final savedAllyLevels     = Map<String, int>.from(_allyLevels);
    final savedAllyTalents    = Map<String, String>.from(_allyTalents);
    final savedOwnedAuras     = Set<String>.from(ownedAuraIds);
    final savedOwnedSkins     = Set<String>.from(ownedSkinIds);
    final savedOwnedPremium   = Set<String>.from(ownedPremiumSkinIds);
    final savedOwnedAttacks   = Set<String>.from(ownedAttackEffects);
    final savedEquippedAura   = equippedAuraId;
    final savedEquippedSkin   = equippedSkinId;
    final savedEquippedPremium = equippedPremiumSkinId;
    final savedEquippedAttack = equippedAttackEffectId;
    final savedSubclass       = subclassId; // level-50 specialization is permanent

    // Set confirmed level BEFORE the reset so it survives even if reset throws.
    _confirmedPrestigeLevel = savedPrestigeLvl;
    // Write dedicated prefs key SYNCHRONOUSLY before anything else can go wrong.
    await saveService.savePrestigeLevel(_currentSlot, savedPrestigeLvl);
    DebugLogger.log('prestige', 'pre-reset confirmedPL=$_confirmedPrestigeLevel pl=$prestigeLevel saved=$savedPrestigeLvl');

    try {
      _resetToDefaults(savedName, savedClass, keepTutorials: true);
    } catch (e, st) {
      DebugLogger.log('prestige', 'resetToDefaults error: $e\n$st');
      // Partial reset is acceptable — continue so restore lines always run.
    }

    // Always restore these unconditionally — even if _resetToDefaults threw.
    prestigeLevel  = savedPrestigeLvl;
    _confirmedPrestigeLevel = savedPrestigeLvl;
    // Rebirth unlocks the next difficulty tier — auto-advance to it.
    activeTier = highestUnlockedTier;
    // Re-write dedicated key after restore so it survives even if the main JSON save fails.
    unawaited(saveService.savePrestigeLevel(_currentSlot, savedPrestigeLvl));
    DebugLogger.log('prestige', 'post-restore pl=$prestigeLevel confirmedPL=$_confirmedPrestigeLevel');
    prestigeSouls  = savedSouls;
    prestigeShop.restoreOwned(savedShopOwned);

    // Elemental Mastery — restore through rebirth
    towerShards = savedTowerShards;
    _elementalMasteryRanks
      ..clear()
      ..addAll(savedMasteryRanks);

    // Ascension — restore through rebirth (higher prestige tier persists).
    ascensionLevel  = savedAscLevel;
    ascensionPoints = savedAscPoints;
    _ascensionNodes
      ..clear()
      ..addAll(savedAscNodes);
    totalAscensionAp = savedTotalAscAp;

    // Permanent progression — always persist through rebirth
    ownedPetIds..clear()..addAll(savedOwnedPets);
    equippedPetId = savedEquippedPet;
    petEvolutionLevels..clear()..addAll(savedPetEvolution);
    _allyLevels..clear()..addAll(savedAllyLevels);
    _allyTalents..clear()..addAll(savedAllyTalents);
    ownedAuraIds..clear()..addAll(savedOwnedAuras);
    ownedSkinIds..clear()..addAll(savedOwnedSkins);
    ownedPremiumSkinIds..clear()..addAll(savedOwnedPremium);
    ownedAttackEffects..clear()..addAll(savedOwnedAttacks);
    equippedAuraId          = savedEquippedAura;
    equippedSkinId          = savedEquippedSkin;
    equippedPremiumSkinId   = savedEquippedPremium;
    equippedAttackEffectId  = savedEquippedAttack;
    subclassId              = savedSubclass;
    shards = savedShards;
    echoes = savedEchoes;
    essence = savedEssence;
    _abilityRanks
      ..clear()
      ..addAll(savedRanks);
    _abilityAscension
      ..clear()
      ..addAll(savedAbilityAsc);
    abilityBranches
      ..clear()
      ..addAll(savedBranches);
    _milestoneChoices
      ..clear()
      ..addAll(savedMilestones);
    passiveTree.loadFromJson(savedTree);
    questsClaimed
      ..clear()
      ..addAll(savedQuests);
    _restoreAchievements(savedAchievements);
    heroTitle = savedTitle;
    _totalAbilityUses = savedAbilityUses;

    // Mythril: base reward + memory keep
    mythril = 10 + mythrilMemoryKeep;

    // Artifact vault restore
    if (savedArtifacts != null) {
      ownedArtifacts
        ..clear()
        ..addAll(savedArtifacts);
      artifactGrid
        ..clear()
        ..addAll(savedArtifactGrid!);
      _unlockedArtifactCells = savedArtifactCells!;
    }

    // Boon effects
    if (boon != null) {
      final v = boon.value;
      switch (boon.effect) {
        case RebirthBoonEffect.startingGold:
          gold = (gold * v).round();
        case RebirthBoonEffect.bonusShards:
          shards += v.toInt();
        case RebirthBoonEffect.bonusSouls:
          break; // already counted in soulsEarned
        case RebirthBoonEffect.bonusEchoes:
          echoes += v.toInt();
        case RebirthBoonEffect.bonusEssence:
          essence += v.toInt();
        case RebirthBoonEffect.bonusZcoins:
          zcoins += v.toInt();
        case RebirthBoonEffect.startWeapon:
          final r = ItemRarity.values[v.toInt().clamp(1, ItemRarity.values.length - 1)];
          inventory.addToBag(ItemLootTable.craftAt(ItemSlot.weapon, r, 1, _rng));
        case RebirthBoonEffect.xpThisRun:
          _boonXpMult = v.toDouble();
      }
    }

    // Challenge modifier
    activeRebirthChallenge = challenge;
    _challengeGoldMult  = challenge == RebirthChallenge.ascetic  ? 0.70 : 1.0;
    _challengeHpPenalty = challenge == RebirthChallenge.ruthless ? -25  : 0;
    _syncHeroHpPct();

    // Prestige milestone rewards (levels 5 / 10 / 15 / 20)
    _checkPrestigeMilestones(prestigeLevel);

    // Update the Campaign leaderboard at the rebirth moment (fire-and-forget,
    // personal-best only) so boards fill even for players who never open them.
    LeaderboardService.submitScore(
      board:     LeaderboardBoard.campaign,
      heroName:  hero.name,
      heroClass: hero.heroClass.displayName,
      subclass:  subclassName,
      spriteId:  heroBattleSpriteId,
      rebirths:  leaderboardRebirths,
      stage:     campaignStageIndex,
      title:       activeTitle,
      nameColorId: activeNameColor,
      frameId:     activeFrame,
      level:       hero.level,
      ascensionAp: totalAscensionAp,
    );

    battleLog = [
      '✦ REBIRTH Lv$prestigeLevel ✦ $savedName returns, forged anew.',
      '+$soulsEarned Paragon Point${soulsEarned == 1 ? '' : 's'}  •  '
      'Gold income +${(prestigeGoldMult * 100 - 100).round()}%  •  '
      'XP +${(prestigeXpMult * 100 - 100).round()}%  •  '
      'Idle +${(prestigeIdleMult * 100 - 100).round()}%',
    ];
    checkAllyMilestones();
    DebugLogger.log('prestige',
        'level=$prestigeLevel souls_total=$prestigeSouls souls_earned=$soulsEarned hero=${hero.name}');
    // Belt-and-suspenders: re-merge account-wide entitlements so a rebirth can
    // never drop a subscription or paid cosmetic/pet.
    await applyAccountEntitlements();
    notifyListeners();
    try {
      await saveToLocal();
    } catch (e) {
      // Retry once on failure — ensures prestigeLevel persists to disk
      DebugLogger.log('prestige', 'save failed: $e — retrying');
      try {
        await saveToLocal();
      } catch (_) {}
    }
  }

  void _checkPrestigeMilestones(int level) {
    const milestones = {
      5:  (title: 'Seasoned Veteran',       mythril: 5,  zcoins: 50,  souls: 0),
      10: (title: 'Battle-Scarred Champion', mythril: 15, zcoins: 100, souls: 0),
      15: (title: 'Legend of the Warden',    mythril: 25, zcoins: 200, souls: 0),
      20: (title: 'Eternal Reborn',          mythril: 50, zcoins: 500, souls: 50),
    };
    final reward = milestones[level];
    if (reward == null) return;
    if (_earnedPrestigeMilestones.contains(level)) return;
    _earnedPrestigeMilestones.add(level);
    mythril  += reward.mythril;
    zcoins   += reward.zcoins;
    prestigeSouls += reward.souls;
    heroTitle = reward.title;
    battleLog.add('★ Milestone Lv$level — ${reward.title} achieved!'
        ' +${reward.mythril} mythril, +${reward.zcoins} Z-Coins'
        '${reward.souls > 0 ? ", +${reward.souls} souls" : ""}');
  }

  // ── Ascension ─────────────────────────────────────────────────────────────
  int ascensionLevel  = 0;
  int ascensionPoints = 0;
  final Map<String, int> _ascensionNodes = {};
  // Cumulative Ascension Points ever earned (= total Rebirths ever sacrificed to
  // ascension). Used so leaderboards can rank by lifetime progress: ascending
  // resets your Rebirth count but the AP gained is folded back in, so it never
  // drops you. Survives every reset except a brand-new character.
  int totalAscensionAp = 0;
  // Effective Rebirths for leaderboard ranking: current + all sacrificed.
  int get leaderboardRebirths => highestUnlockedTier + totalAscensionAp;

  bool get canAscend => prestigeLevel >= 5;
  // 1 Ascension Point per Rebirth sacrificed — so banking more Rebirths before
  // ascending pays out proportionally (5 rebirths → 5 AP, 8 → 8 AP, …), instead
  // of the old flat 3 that ignored how much you gave up.
  int  get ascensionPointsForNextAscension => prestigeLevel;

  // ── Game-loop connection signals ─────────────────────────────────────────
  int get consecutiveLosses => _consecutiveLosses;

  bool get hasAffordableAbilityUpgrade {
    final abilities = AbilityData.forClass(hero.heroClass);
    return abilities.any((a) {
      if (hero.level < a.levelRequired) return false;
      final rank = abilityRank(a.id);
      if (rank >= kAbilityMaxRank) return false;
      if (abilityTierLocked(a.id)) return false;
      return shards >= abilityUpgradeCost(a.id);
    });
  }

  bool get hasAffordablePassiveNode =>
      kPassiveNodes.any((n) =>
          // Skip other classes' class-only nodes — they aren't shown on this
          // hero's passive screen, so counting them left a stuck badge with
          // nothing to actually buy.
          (n.classOnly == null || n.classOnly == hero.heroClass.name) &&
          passiveTree.canUpgrade(n.id) &&
          essence >= passiveTree.costForNextRank(n.id));

  static const _abilityScoreKeys = ['pwr', 'agi', 'vit', 'prc', 'for_', 'lck'];
  bool get hasAffordableAbilityScore => _abilityScoreKeys.any((k) {
    final rank = abilityScoreRank(k);
    if (rank >= kAbilityScoreMaxRank) return false;
    if (!abilityScoreGateMet(k)) return false;
    return gold >= abilityScoreUpgradeCost(k);
  });

  bool get hasAffordableEndlessUpgrade =>
      EndlessNode.values.any((n) => endlessUpgrades.canAfford(n, echoes));

  bool get hasAffordablePet =>
      kPetCatalog.any((p) => !ownedPetIds.contains(p.id) && zcoins >= p.zcoinCost) ||
      ownedPetIds.any((id) {
        final lv = petEvolutionLevel(id);
        return lv < 10 && zcoins >= evolutionCost(id);
      });

  bool get hasReadyExpedition =>
      _activeExpeditions.any((e) => e.isComplete);

  bool get hasAffordableElementalMastery =>
      DamageType.values.any((t) =>
          gold >= elementalMasteryGoldCost(t.name) &&
          towerShards >= elementalMasteryShardCost(t.name));

  // Feature tabs that stay hidden until you can first use them, then latch open
  // permanently (they don't re-hide when you spend the resource).
  bool _upgradesTabSeen = false;
  bool _masteryTabSeen  = false;

  bool get upgradesTabUnlocked {
    if (!_upgradesTabSeen && hasAffordableEndlessUpgrade) _upgradesTabSeen = true;
    return _upgradesTabSeen;
  }

  bool get masteryTabUnlocked {
    if (!_masteryTabSeen && hasAffordableElementalMastery) _masteryTabSeen = true;
    return _masteryTabSeen;
  }

  /// Priority-ordered hint for "what should I do next?" indicator.
  String? get nextActionHint {
    if (canPrestige)                  return '✨ Prestige available — reset for power!';
    if (canAscend)                    return '⬆️ Ascension available!';
    if (hasClaimableDaily)            return '🎯 Daily challenge ready to claim!';
    if (achievementsClaimable > 0)    return '🏆 Achievement reward ready!';
    if (hasReadyExpedition)           return '🗺️ Expedition complete — collect rewards!';
    if (hasAffordableAbilityUpgrade)  return '⚔ Ability upgrade affordable';
    if (hasAffordableAbilityScore)    return '⭐ Ability score upgrade ready';
    if (hasAffordablePassiveNode)     return '🌿 Passive upgrade affordable';
    if (hasAffordableEndlessUpgrade)  return '🔮 Endless upgrade affordable';
    if (hasAffordableElementalMastery) return '🔥 Elemental mastery upgrade ready';
    if (hasAffordablePet)             return '🐾 Pet ready to adopt!';
    if (consecutiveLosses >= 3)       return '💀 Stuck? Consider Prestige!';
    if (campaignStageIndex >= 20 && campaignStageIndex % 25 >= 18) {
      final remaining = 25 - (campaignStageIndex % 25);
      return '🏆 $remaining stages until next Prestige!';
    }
    return null;
  }

  // Endless kill tracking for milestone rewards
  int _totalEndlessKills = 0;
  int get totalEndlessKills => _totalEndlessKills;
  static const _endlessMilestones = [5, 10, 25, 50, 100, 200, 500];
  int? lastEndlessMilestone;

  int ascensionNodeLevel(String id) => _ascensionNodes[id] ?? 0;

  double get ascXpMult   => 1.0 + ascensionNodeLevel('xp_gain') * 0.25;
  double get ascGoldMult => 1.0 + ascensionNodeLevel('gold_gain') * 0.25;
  double get ascShardMult => 1.0 + ascensionNodeLevel('shard_gain') * 0.25;
  int    get ascAtkBonus  => ascensionNodeLevel('atk_bonus');
  // Titan Strength is now a % all-damage multiplier (scales forever) instead of
  // the old flat +damage, which was negligible at high levels. The flat getter
  // stays at 0 for backward-compatible call sites; the % feeds the damage pipeline.
  int    get ascDmgBonus  => 0;
  double get ascAllDamagePct => ascensionNodeLevel('dmg_bonus') * 5.0; // was 12/level
  double get ascIdleMult  => 1.0 + ascensionNodeLevel('idle_bonus') * 0.30;
  double get ascPrestigeMult => 1.0 + ascensionNodeLevel('prestige_bonus') * 0.30;
  double get ascEssenceMult  => 1.0 + ascensionNodeLevel('essence_bonus') * 0.30;

  void ascend() {
    if (!canAscend) return;
    AnalyticsService.instance.ascend(ascensionLevel + 1);
    final ap = ascensionPointsForNextAscension;
    // Save everything that survives ascension
    final savedName          = hero.name;
    final savedClass         = hero.heroClass;
    final savedAscLevel      = ascensionLevel + 1;
    final savedAscPoints     = ascensionPoints + ap;
    final savedNodes         = Map<String, int>.from(_ascensionNodes);
    final savedMythril       = mythril;
    final savedArtifacts     = List<Artifact>.from(ownedArtifacts);
    final savedArtifactGrid  = Map<int, String>.from(artifactGrid);
    final savedUnlocked      = _unlockedArtifactCells;
    final shardsGained       = 10 + ascensionLevel * 5; // scales: 10, 15, 20, …
    final savedTowerShards   = towerShards + shardsGained;
    final savedMasteryRanks  = Map<String, int>.from(_elementalMasteryRanks);
    final savedAbilityAsc    = Map<String, int>.from(_abilityAscension);
    final savedTotalAscAp    = totalAscensionAp + ap; // cumulative AP ever earned
    final savedAchievements  = achievements.map((a) => a.toJson()).toList();
    final savedSubclass      = subclassId; // level-50 specialization is permanent
    // Pets are permanent companions — survive ascension too (prestige already keeps them).
    final savedOwnedPets     = Set<String>.from(ownedPetIds);
    final savedEquippedPet   = equippedPetId;
    final savedPetEvolution  = Map<String, int>.from(petEvolutionLevels);
    // Full reset (includes zeroing prestige + ascension)
    _resetToDefaults(savedName, savedClass, keepTutorials: true);
    // Restore ascension-permanent data
    ascensionLevel  = savedAscLevel;
    ascensionPoints = savedAscPoints;
    _ascensionNodes.addAll(savedNodes);
    mythril = savedMythril;
    ownedArtifacts.addAll(savedArtifacts);
    artifactGrid.addAll(savedArtifactGrid);
    _unlockedArtifactCells = savedUnlocked;
    towerShards = savedTowerShards;
    _elementalMasteryRanks.addAll(savedMasteryRanks);
    _abilityAscension.addAll(savedAbilityAsc);
    totalAscensionAp = savedTotalAscAp;
    _restoreAchievements(savedAchievements);
    subclassId = savedSubclass;
    ownedPetIds..clear()..addAll(savedOwnedPets);
    equippedPetId = savedEquippedPet;
    petEvolutionLevels..clear()..addAll(savedPetEvolution);
    // Ascension zeroes prestige — keep the dedicated confirmed-prestige key in
    // sync too, or loadSlot would restore prestigeLevel from it (leaving the
    // player able to re-ascend / stuck). prestige() does the same.
    _confirmedPrestigeLevel = 0;
    unawaited(saveService.savePrestigeLevel(_currentSlot, 0));
    DebugLogger.log('ascend',
        'granted ap=$ap ascLevel=$ascensionLevel points=$ascensionPoints shards=$shardsGained');
    battleLog = [
      '✦ ASCENSION Lv$ascensionLevel ✦ $savedName transcends the mortal coil.',
      '+$ap Ascension Points granted.  +$shardsGained Tower Shards 🔮',
    ];
    checkAllyMilestones();
    // Re-merge account-wide entitlements (subscriptions + paid cosmetics/pets)
    // so ascension never drops them.
    applyAccountEntitlements();
    notifyListeners();
    saveToLocal();
  }

  bool spendAscensionPoint(String nodeId) {
    final node = AscensionNode.byId(nodeId);
    if (node == null) return false;
    final cur = _ascensionNodes[nodeId] ?? 0;
    if (cur >= node.maxLevel) return false;
    if (ascensionPoints < node.costPerLevel) return false;
    ascensionPoints -= node.costPerLevel;
    _ascensionNodes[nodeId] = cur + 1;
    notifyListeners();
    saveToLocal();
    return true;
  }

  // ── Subclass (level-50 specialization) ───────────────────────────────────
  String? subclassId;
  static const int kSubclassUnlockLevel = 50;
  static const int kSubclassRespecCost  = 100; // ZCoins

  // Latches once chosen: a rebirth resets hero.level but the specialization is
  // permanent, so the tab/choice must stay unlocked afterwards.
  bool get subclassUnlocked  => hero.level >= kSubclassUnlockLevel || subclassId != null;
  bool get subclassAvailable => subclassUnlocked && subclassId == null;

  Subclass? get activeSubclass =>
      subclassId == null ? null : subclassById(subclassId!);

  SubclassEffect get subclassEffect => activeSubclass?.effect ?? SubclassEffect.none;

  String? get subclassName => activeSubclass?.name;
  ColorFilter? get subclassColorFilter => activeSubclass?.spriteColorFilter;

  // Hero rename: costs Z-Coins, escalating +50 each time (50, 100, 150, …).
  static const int kRenameHeroBaseCost = 50;
  int heroRenameCount = 0;
  int get renameHeroCost => kRenameHeroBaseCost * (heroRenameCount + 1);

  // What's New / patch notes — track the newest build the player has opened so
  // we can badge the button when there's an unread update.
  int lastSeenPatchBuild = 0;
  bool get hasUnseenPatchNotes => kLatestPatchBuild > lastSeenPatchBuild;
  void markPatchNotesSeen() {
    if (lastSeenPatchBuild < kLatestPatchBuild) {
      lastSeenPatchBuild = kLatestPatchBuild;
      notifyListeners();
      saveToLocal();
    }
  }

  /// Rename the hero for [renameHeroCost] Z-Coins. Returns false if the name is
  /// empty or the player can't afford it. Each successful rename raises the next
  /// cost by 50. Leaderboard rows refresh their identity when boards are opened.
  bool renameHero(String newName) {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return false;
    if (zcoins < renameHeroCost) return false;
    zcoins -= renameHeroCost;
    heroRenameCount++;
    hero.name = trimmed;
    notifyListeners();
    saveToLocal();
    return true;
  }
  /// The sprite colour filter to render the hero with: an equipped shop skin
  /// takes priority; otherwise the chosen subclass's cosmetic tint applies.
  /// A premium skin is fully self-coloured, so no filter is applied over it.
  ColorFilter? get heroSpriteFilter =>
      activePremiumSkin != null ? null : (heroSkinFilter ?? subclassColorFilter);

  /// The sprite id to paint the hero with. A premium skin swaps the base class
  /// painter for its bespoke 'premium_<class>' variant; otherwise the normal
  /// class sprite is used.
  String get heroBattleSpriteId => activePremiumSkin?.id ?? hero.spriteId;

  // ── Data-driven capstone bonus getters (0 when no subclass chosen) ──────────
  int get subclassCritChancePct => activeSubclass?.critChancePct ?? 0;
  int get subclassCritDmgPct     => activeSubclass?.critDmgPct ?? 0;
  int get subclassDodgePct       => activeSubclass?.dodgePct ?? 0;
  int get subclassHpPct          => activeSubclass?.hpPct ?? 0;
  int get subclassArmorPct       => activeSubclass?.armorPct ?? 0;
  int get subclassLifestealPct   => activeSubclass?.lifestealPct ?? 0;
  int get subclassPierce         => activeSubclass?.pierce ?? 0;
  int get subclassGoldPct        => activeSubclass?.goldPct ?? 0;
  int get subclassXpPct          => activeSubclass?.xpPct ?? 0;
  int get subclassShardPct       => activeSubclass?.shardPct ?? 0;
  double get subclassAbilityPowerPct => (activeSubclass?.abilityPowerPct ?? 0) / 100.0;
  double get subclassDotPct      => (activeSubclass?.dotPct ?? 0) / 100.0;
  double get subclassHealPct     => (activeSubclass?.healPct ?? 0) / 100.0;
  int get subclassCooldownReduce => activeSubclass?.cooldownReduce ?? 0;

  /// Total "+% healing" that feeds the heal RATING (passives + subclass). Every
  /// healing bonus raises this rating; the actual heal % of max HP is then
  /// [armorDrPctFor] of it, capping at kDefenseCapPct (37.5%). Shared by combat
  /// ([_fireAbility]) and the ability display so they always agree.
  double get healBoostRatingPct {
    final sub = subclassHealPct + switch (subclassEffect) {
      SubclassEffect.lifeCleric => 0.30,
      SubclassEffect.abjurer    => 0.15,
      _ => 0.0,
    };
    return passiveTree.totalOf(PassiveEffect.healBoost).toDouble() + sub * 100.0;
  }

  /// Heal % of max HP for a heal ability of scaled [value] (its % base), via the
  /// shared diminishing-returns rating curve. Bursts use factor 1.0, per-round
  /// HoT auras 0.5. Caps at kDefenseCapPct.
  double abilityHealPct(num value, {double factor = 1.0}) =>
      armorDrPctFor(value + healBoostRatingPct) * factor;

  /// Flat Heal Rating before % bonuses: items + set + gems + passive-tree flat.
  /// This is the "Base Heal Rating" the Vitalist keystone / Paragon can double.
  int get healRatingFlat =>
      inventory.totalOf(ItemStat.healRating)
      + _setTotal(ItemStat.healRating)
      + _gemTotal(ItemStat.healRating)
      + passiveTree.totalOf(PassiveEffect.healRatingFlat);

  /// Paragon Heal-Rating multiplier (e.g. +% per rank; "double" = +100%).
  double get paragonHealMult => 1.0 + prestigeShop.paragonTotal(ParagonEffect.healRating) / 100.0;

  /// Total Heal Rating. Base (flat) doubled by the Vitalist keystone, then scaled
  /// by all % heal bonuses ([healBoostRatingPct]: Vitalist %, subclass) and the
  /// heal Paragon. EVERY heal in the game is a multiple of this (see [healFor]).
  int get healRating {
    var flat = healRatingFlat.toDouble();
    if (passiveTree.hasKeystone(PassiveBranch.vitalist)) flat *= 2; // "Doubles Base Heal Rating"
    final pctMult = 1.0 + healBoostRatingPct / 100.0;
    return (flat * pctMult * paragonHealMult).round().clamp(0, 1000000000000000);
  }

  /// HP restored by a heal of design-[value] (its legacy "% of HP" number).
  /// Decoupled from max HP — heals are value/[kHealValuePerMult] × Heal Rating.
  /// [value] is clamped to kHealValuePerMult so NO single heal exceeds 1× Heal
  /// Rating (× factor): heal values range 8→100, and un-clamped a value-100
  /// aura healed ~3× a normal heal, out-pacing the boss on its own. factor:
  /// bursts 1.0, per-round HoT auras 0.5.
  int healFor(num value, {double factor = 1.0}) {
    final mult = (value / kHealValuePerMult).clamp(0.0, kHealMaxMult);
    return (healRating * mult * factor).round().clamp(0, 1000000000000000);
  }

  /// Total lifesteal % from every source (keyword, subclass, mastery, paragon,
  /// draining aura). Public so every combat mode leeches the same as the campaign.
  int get heroLifestealPct =>
      (_hasKeyword(ItemKeyword.lifeSteal) ? 4 : 0)
      + (subclassEffect == SubclassEffect.fiendPact ? 8 : 0) + subclassLifestealPct
      + _masteryTotal(MasteryEffect.lifestealPct)
      + prestigeLifestealPct
      + (auraLifestealActive ? auraLifestealPct : 0);

  /// HP restored per hero hit from lifesteal — Heal-Rating based, mirrors the
  /// campaign formula in heroAttack(). Caller clamps to its own HP pool.
  int lifestealHealPerHit() {
    final pct = heroLifestealPct;
    if (pct <= 0 || healRating <= 0) return 0;
    return (healRating * pct / 100 / kHealValuePerMult)
        .round().clamp(0, 1000000000000000).toInt();
  }

  /// Thorns reflect % — Thorn Wall keyword returns 30% of a landed hit to the
  /// attacker. Public so every combat mode reflects the same as the campaign.
  int get heroThornsPct => _hasKeyword(ItemKeyword.thornWall) ? 30 : 0;

  /// Increased damage % from the subclass for [type] (all-damage + matching elem).
  double subclassDamagePct(DamageType type) {
    final s = activeSubclass;
    if (s == null) return 0;
    var v = s.dmgPct.toDouble();
    if (s.elemType == type) v += s.elemDmgPct;
    return v;
  }

  bool pickSubclass(String id) {
    final sub = subclassById(id);
    if (sub == null || subclassId != null || !subclassUnlocked) return false;
    subclassId = id;
    AnalyticsService.instance.subclassChosen(id, hero.heroClass.name);
    _applySubclassStats(sub, 1);
    _setLastAction('Specialization chosen: ${sub.name}!');
    _checkAchievements();
    _syncHeroHpPct();
    notifyListeners();
    saveToLocal();
    return true;
  }

  /// Respec the subclass for [kSubclassRespecCost] ZCoins: refund the old
  /// subclass's stat bonuses and clear the choice so a new one can be picked.
  bool respecSubclass() {
    if (subclassId == null || zcoins < kSubclassRespecCost) return false;
    final old = subclassById(subclassId!);
    zcoins -= kSubclassRespecCost;
    if (old != null) _applySubclassStats(old, -1);
    subclassId = null;
    _setLastAction('Specialization respec — choose a new one.');
    _syncHeroHpPct();
    notifyListeners();
    saveToLocal();
    return true;
  }

  void _applySubclassStats(Subclass sub, int sign) {
    if (sub.strBonus != 0) hero.addStrength(sign * sub.strBonus);
    if (sub.dexBonus != 0) hero.addDexterity(sign * sub.dexBonus);
    if (sub.conBonus != 0) hero.addConstitution(sign * sub.conBonus);
    if (sub.intBonus != 0) hero.addIntelligence(sign * sub.intBonus);
    if (sub.wisBonus != 0) hero.addWisdom(sign * sub.wisBonus);
    if (sub.chaBonus != 0) hero.addCharisma(sign * sub.chaBonus);
  }

  // Used by valorSurge: set after ability fires, consumed on next attack
  bool _valorSurgeReady = false;

  // ── Forge ──────────────────────────────────────────────────────────────────
  EquipmentItem? forgeItems(List<EquipmentItem> items) {
    if (items.isEmpty) return null;
    final slot   = items.first.slot;
    final rarity = items.first.rarity;
    final target = rarity == ItemRarity.common ? ItemRarity.rare : ItemRarity.epic;
    final needed = rarity == ItemRarity.common ? forgeCommonToRareCount : 2;
    if (items.length != needed) return null;
    if (items.any((i) => i.slot != slot || i.rarity != rarity)) return null;
    if (rarity == ItemRarity.epic) return null; // can't forge beyond epic
    for (final item in items) {
      inventory.bag.remove(item);
      inventory.equipped.remove(slot); // don't silently remove equipped
    }
    final result = ItemLootTable.craftAt(slot, target, hero.level, _rng, rebirthLevel: highestUnlockedTier);
    inventory.addToBag(result);
    _totalForges++;
    _setLastAction('Forged: ${result.name}!');
    _checkAchievements();
    notifyListeners();
    saveToLocal();
    return result;
  }

  // ── Ability Runes (permanent ability modifiers socketed into rings/amulets) ──

  final Set<String> ownedRunes = {};
  String? lastRuneDrop;

  bool ownsRune(String runeId) => ownedRunes.contains(runeId);

  bool isRuneSocketed(String runeId) =>
      inventory.equipped.values.any((i) => i.socketedRuneId == runeId);

  String? rollRuneDrop({bool guaranteed = false}) {
    if (!guaranteed && _rng.nextInt(10) != 0) return null; // 10% chance unless guaranteed
    final classRunes = AbilityRune.forClass(hero.heroClass);
    if (classRunes.isEmpty) return null;
    final rune = classRunes[_rng.nextInt(classRunes.length)];
    if (ownedRunes.contains(rune.id)) {
      // Duplicate → convert to Rune Dust
      final dust = 3 + rune.dustCost ~/ 3;
      runeDust += dust;
      lastRuneDrop = null;
      battleLog.add('🌀 Duplicate rune "${rune.name}" → +$dust Arcane Dust');
      return null;
    }
    ownedRunes.add(rune.id);
    lastRuneDrop = rune.id;
    battleLog.add('✦ NEW RUNE: ${rune.icon} ${rune.name}!');
    return rune.id;
  }

  bool socketAbilityRune(String runeId, EquipmentItem item) {
    if (!item.canSocketRune) return false;
    if (!ownedRunes.contains(runeId)) return false;
    final rune = AbilityRune.all.where((r) => r.id == runeId).firstOrNull;
    if (rune == null) return false;
    if (rune.classRequired != hero.heroClass) return false;
    item.socketedRuneId = runeId;
    trackSocketGem();
    notifyListeners();
    saveToLocal();
    return true;
  }

  Set<String> get _activeRuneIds => inventory.equipped.values
      .where((i) => i.socketedRuneId != null)
      .map((i) => i.socketedRuneId!)
      .toSet();

  double abilityRuneValueMult(String abilityId) {
    var mult = 1.0;
    final active = _activeRuneIds;
    for (final rune in AbilityRune.all) {
      if (rune.abilityId == abilityId && active.contains(rune.id)) {
        mult *= rune.valueMult;
      }
    }
    return mult;
  }

  int abilityRuneDurationAdd(String abilityId) {
    var total = 0;
    final active = _activeRuneIds;
    for (final rune in AbilityRune.all) {
      if (rune.abilityId == abilityId && active.contains(rune.id)) {
        total += rune.durationAdd;
      }
    }
    return total;
  }

  int abilityRuneCooldownReduce(String abilityId) {
    var total = 0;
    final active = _activeRuneIds;
    for (final rune in AbilityRune.all) {
      if (rune.abilityId == abilityId && active.contains(rune.id)) {
        total += rune.cooldownReduce;
      }
    }
    return total;
  }

  bool upgradeItem(EquipmentItem item) {
    if (!item.canUpgrade) return false;
    if (gold < item.upgradeGoldCost) return false;
    if (shards < item.upgradeShardCost) return false;
    gold -= item.upgradeGoldCost;
    shards -= item.upgradeShardCost;
    item.applyUpgrade();
    trackForgeItem();
    notifyListeners();
    saveToLocal();
    return true;
  }

  int disenchantValue(EquipmentItem item) => switch (item.rarity) {
    ItemRarity.common    => 3,
    ItemRarity.uncommon  => 5,
    ItemRarity.rare      => 8,
    ItemRarity.epic      => 20,
    ItemRarity.legendary => 60,
    ItemRarity.mythic    => 150,
    ItemRarity.set       => 100,
    ItemRarity.unique    => 80,
  };

  int disenchantItems(List<EquipmentItem> items) {
    var total = 0;
    var dustGained = 0;
    for (final item in items) {
      // Never salvage a locked item — this is the central guard so "select all"
      // / auto-salvage can't destroy something the player deliberately locked.
      if (item.locked) continue;
      inventory.bag.remove(item);
      total += switch (item.rarity) {
        ItemRarity.common    => 3,
        ItemRarity.uncommon  => 5,
        ItemRarity.rare      => 8,
        ItemRarity.epic      => 20,
        ItemRarity.legendary => 60,
        ItemRarity.mythic    => 150,
        ItemRarity.set       => 100,
        ItemRarity.unique    => 80,
      };
      // Every item yields Arcane Dust, scaling with rarity (was previously only
      // common/rare, so salvaging most gear gave none).
      dustGained += switch (item.rarity) {
        ItemRarity.common    => 1,
        ItemRarity.uncommon  => 2,
        ItemRarity.rare      => 4,
        ItemRarity.epic      => 8,
        ItemRarity.legendary => 16,
        ItemRarity.mythic    => 32,
        ItemRarity.set       => 20,
        ItemRarity.unique    => 16,
      };
      // Return gem shards if item had a socketed gem
      if (item.gem != null) {
        final gemRefund = item.gem!.tier.shardCost;
        gemShards += gemRefund;
      }
      // Refund 33% of upgrade costs for upgraded items
      if (item.upgradeTier > 0) {
        var goldRefund = 0;
        var shardRefund = 0;
        for (int t = 0; t < item.upgradeTier; t++) {
          goldRefund += ((200 + item.levelRequired * 30) * (t + 1) * 0.33).round();
          shardRefund += ((5 + item.levelRequired ~/ 2) * (t + 1) * 0.33).round();
        }
        gold += goldRefund;
        total += shardRefund;
      }
    }
    if (total > 0) {
      shards += total;
      if (dustGained > 0) runeDust += dustGained;
      _totalDisenchants += items.length;
      _setLastAction('Disenchanted ${items.length} item(s): +$total ◆${dustGained > 0 ? '  +$dustGained Arcane Dust' : ''}');
      _checkAchievements();
      notifyListeners();
      saveToLocal();
    }
    return total;
  }

  // Boss battle state
  bool _bossEnraged = false;
  bool get isBossEnraged => _bossEnraged;
  bool get isBossStage =>
      (campaignStageIndex % 5 == 4 && campaignStageIndex < CampaignData.stages.length) ||
      (_endlessMode && endlessStageIndex % 5 == 4) ||
      (isCampaignReplay && _replayStageIndex % 5 == 4);

  // Mercy Token — activates after 3 consecutive losses
  int  _consecutiveLosses = 0;
  bool _mercyTokenActive  = false;

  // Active ability state — reset at start of every fight
  int _abilityRound = 0;
  final Map<String, int> _cooldownUntil = {};
  int _tempAttackBonus = 0;
  int _tempAttackBonusRounds = 0;
  int _tempAcBonus = 0;
  int _tempAcBonusRounds = 0;
  int _dotDmg = 0;
  int _dotRoundsLeft = 0;
  DamageType _dotDamageType = DamageType.physical;

  // Floating number events to display this turn (cleared by battle_screen)
  final List<({int value, bool isHeal, DamageType type})> pendingFloats = [];
  ({String id, String name, AbilityEffect effect})? lastAbilityFired;
  void clearPendingFloats() {
    pendingFloats.clear();
    lastAbilityFired = null;
  }
  int _enemyStunRounds = 0;
  int _stunApplicationCount = 0;  // DR: 0=full, 1=half, 2+=immune
  int _roundsSinceLastStun = 0;   // DR resets after 5 rounds without a stun
  static const _stunDrMult = [1.0, 0.5, 0.0];
  bool _dodgeNextHit = false;
  int _auraHealPerRound = 0;
  int _auraRoundsLeft = 0;
  int _enemyWeakenPct = 0;
  int _enemyWeakenRounds = 0;
  int _enemyVulnerablePct = 0;
  int _enemyVulnerableRounds = 0;
  int _enemySilenceRounds = 0;
  int _enemyMissChancePct = 0;
  int _enemyMissChanceRounds = 0;
  int _heroAbsorbShield = 0;
  // Consecutive enemy attacks fully skipped/avoided — after 2 in a row a boss
  // attack becomes UNSTOPPABLE so it can't be perma-locked by stun/dodge/avoid.
  int _bossAttacksSkipped = 0;

  // Boss ability state — reset each battle
  final Map<String, int> _bossAbilityCooldowns = {};
  int _heroDotRoundsLeft = 0;
  int _heroDotDmgPerRound = 0;
  DamageType _heroDotType = DamageType.physical;
  int _heroStunRounds = 0;

  // Public read — used by battle UI to show active affixes
  List<ZoneAffix> get activeAffixes => List.unmodifiable(_activeAffixes);

  void _resetBattlePerks() {
    _resetFightStats(); // every game_state-driven fight-start resets the summary
    _comboStacks         = 0;
    _unbrokenUsed        = false;
    _unbreakableUsed     = false;
    _battleAwarenessUsed = false;
    _healsThisBattle     = 0;
    _attackRoundCounter  = 0;
    _deathSpiralRounds   = 0;
    _abilityRound        = 0;
    _bossEnraged          = false;
    _cooldownUntil.clear();
    _tempAttackBonus      = 0;
    _tempAttackBonusRounds = 0;
    _tempAcBonus          = 0;
    _tempAcBonusRounds    = 0;
    _dotDmg               = 0;
    _dotRoundsLeft        = 0;
    _dotDamageType        = DamageType.physical;
    _enemyStunRounds      = 0;
    _stunApplicationCount = 0;
    _roundsSinceLastStun  = 0;
    _bossAttacksSkipped   = 0;
    _dodgeNextHit         = false;
    _auraHealPerRound     = 0;
    _auraRoundsLeft       = 0;
    _enemyWeakenPct       = 0;
    _enemyWeakenRounds    = 0;
    _enemyVulnerablePct    = 0;
    _enemyVulnerableRounds = 0;
    _enemySilenceRounds    = 0;
    _enemyMissChancePct    = 0;
    _enemyMissChanceRounds = 0;
    _heroAbsorbShield      = 0;
    _bossAbilityCooldowns.clear();
    _heroDotRoundsLeft     = 0;
    _heroDotDmgPerRound    = 0;
    _heroDotType           = DamageType.physical;
    _heroStunRounds        = 0;
    _allyAbilitiesUsed.clear();
    _lenaBackstabReady      = false;
    _felixBribeActive       = false;
    _rukStoneSkinRoundsLeft  = 0;
    _mercDodgePct           = 0;
    _mercDodgeRounds        = 0;
    _treasureGoblinActive    = false;
  }

  // ── Ally active ability helpers ─────────────────────────────────────────────

  /// Merc-ability visual events queued for the battle UI to animate. Each entry
  /// is drained by the active battle screen and shown as a call-out card.
  final List<({String name, String icon, Color color})> pendingMercFx = [];

  void _queueMercFx(String name, String icon, Color color) =>
      pendingMercFx.add((name: name, icon: icon, color: color));

  /// Pops all queued merc FX (the UI plays them, staggered).
  List<({String name, String icon, Color color})> drainMercFx() {
    if (pendingMercFx.isEmpty) return const [];
    final out = List<({String name, String icon, Color color})>.of(pendingMercFx);
    pendingMercFx.clear();
    return out;
  }

  // Returns true if we should early-return from heroAttack (enemy killed by Arcane Surge).
  bool _fireAllyBattleStartAbilities(Enemy enemy) {
    if (allyUnlocked('greybeard') && !_allyAbilitiesUsed.contains('greybeard')) {
      _allyAbilitiesUsed.add('greybeard');
      // War Cry now MARKS the foe (Vulnerable) so every hit lands harder —
      // a real, scaling combat effect instead of a hidden +crit-chance.
      _enemyVulnerablePct    = max(_enemyVulnerablePct, 25);
      _enemyVulnerableRounds = max(_enemyVulnerableRounds, 4);
      battleLog.add('📣 Greybeard: War Cry! ${enemy.name} takes +25% damage for 4 rounds.');
      _queueMercFx('Greybeard', '📣', const Color(0xFFffaa44));
    }
    if (allyUnlocked('elder_voss') && !_allyAbilitiesUsed.contains('elder_voss')) {
      _allyAbilitiesUsed.add('elder_voss');
      final burst = (enemy.maxHealth * 0.12).round().clamp(1, 1000000000000000);
      enemy.takeDamage(burst);
      _recordFightDamage(burst);
      battleLog.add('🔮 Voss: Arcane Surge! ${enemy.name} takes $burst arcane damage!');
      _queueMercFx('Voss', '🔮', const Color(0xFF66aaff));
      if (enemy.isDefeated) { _battleVictory(enemy); return true; }
    }
    if (allyUnlocked('coin_felix') && !_allyAbilitiesUsed.contains('coin_felix')) {
      _allyAbilitiesUsed.add('coin_felix');
      // Smoke Screen — a merchant's escape trick: +30% dodge for 4 rounds.
      _mercDodgePct    = max(_mercDodgePct, 30);
      _mercDodgeRounds = max(_mercDodgeRounds, 4);
      battleLog.add('🪙 Felix: Smoke Screen! +30% dodge for 4 rounds.');
      _queueMercFx('Felix', '💨', const Color(0xFFffd700));
    }
    if (allyUnlocked('shadow_lena') && !_allyAbilitiesUsed.contains('shadow_lena')) {
      _allyAbilitiesUsed.add('shadow_lena');
      _lenaBackstabReady = true;
      battleLog.add("🌑 Lena: Backstab primed! First hit is a guaranteed critical!");
      _queueMercFx('Lena', '🌑', const Color(0xFF44cc88));
    }
    if (allyUnlocked('golem_ruk') && !_allyAbilitiesUsed.contains('golem_ruk')) {
      _allyAbilitiesUsed.add('golem_ruk');
      _rukStoneSkinRoundsLeft = 5;
      battleLog.add('🪨 Ruk: Stone Skin! Incoming damage −4 for 5 rounds.');
      _queueMercFx('Ruk', '🪨', const Color(0xFF99aabb));
    }
    return false;
  }

  void _checkAllyHpAbilities() {
    // No triage for the fallen: _battleDefeat() heals to full while
    // heroDefeated is still true, so the HP guard alone isn't enough.
    if (heroDefeated || hero.currentHealth <= 0) return;
    // Mira: Field Triage — heal 25% max HP when hero drops below 30%
    if (allyUnlocked('mira') && !_allyAbilitiesUsed.contains('mira') &&
        hero.currentHealth < hero.maxHealth * 0.30) {
      _allyAbilitiesUsed.add('mira');
      // Field Triage now scales off Heal Rating (like all healing), value ≈ 25.
      final heal = healFor(25).clamp(1, hero.maxHealth);
      hero.currentHealth = (hero.currentHealth + heal).clamp(0, hero.maxHealth);
      battleLog.add('💉 Mira: Field Triage! ${hero.name} is healed for $heal HP!');
      _queueMercFx('Mira', '💉', const Color(0xFFff88aa));
    }
    // Ironhide: Shield Wall — block next hit when hero drops below 50%
    if (allyUnlocked('ironhide') && !_allyAbilitiesUsed.contains('ironhide') &&
        hero.currentHealth < hero.maxHealth * 0.50) {
      _allyAbilitiesUsed.add('ironhide');
      _dodgeNextHit = true;
      battleLog.add('🪨 Ironhide: Shield Wall! Next incoming attack is blocked!');
      _queueMercFx('Ironhide', '🛡', const Color(0xFF8899bb));
    }
  }

  // ── Active ability helpers ──────────────────────────────────────────────────

  List<HeroAbility> get unlockedAbilities =>
      AbilityData.unlockedFor(hero.heroClass, hero.level, ultUnlocked: classUltimateUnlocked);

  int cooldownRemaining(String abilityId) =>
      max(0, (_cooldownUntil[abilityId] ?? 0) - _abilityRound);

  // ── Ability Score upgrades (gold sink, available from level 1) ────────────

  static const int kAbilityScoreMaxRank = 250;
  final Map<String, int> _abilityScoreRanks = {};

  // Clamped to the max so any legacy ranks bought above the cap (was 1000) are
  // effectively limited to 100 — the scores are potent per rank, so this keeps
  // them balanced.
  int abilityScoreRank(String id) =>
      (_abilityScoreRanks[id] ?? 0).clamp(0, kAbilityScoreMaxRank);

  // Rebirth requirement removed — Ability Scores upgrade freely, gold permitting.
  int abilityScoreRebirthRequired(String id) => 0;

  bool abilityScoreGateMet(String id) => true;

  // Gold cost to buy the NEXT rank. Quadratic so the 0→250 climb is a genuine
  // long-haul gold sink (target: roughly maxed around hero level ~500) instead
  // of the old linear curve that trivially topped out at 100. cost(r) =
  // (r+1)² × 100 → rank 1 = 100g, rank 100 ≈ 1.0M, rank 250 ≈ 6.25M; the full
  // 0→250 climb is ~524M per score (~3.1B for all six). The 100 coefficient is
  // THE tuning knob — dial it from telemetry against real gold income.
  static const int kAbilityScoreCostCoeff = 100;
  int abilityScoreUpgradeCost(String id) {
    final rank = abilityScoreRank(id);
    if (rank >= kAbilityScoreMaxRank) return 0;
    final next = rank + 1;
    return next * next * kAbilityScoreCostCoeff;
  }

  void upgradeAbilityScore(String id) {
    final rank = abilityScoreRank(id);
    if (rank >= kAbilityScoreMaxRank) return;
    if (!abilityScoreGateMet(id)) return;
    final cost = abilityScoreUpgradeCost(id);
    if (gold < cost) return;
    gold -= cost;
    _abilityScoreRanks[id] = rank + 1;
    _syncHeroHpPct();
    notifyListeners();
    saveToLocal();
  }

  int    get _scorePwr => abilityScoreRank('pwr') * 2;
  int    get _scorePrc => abilityScoreRank('prc');
  // FOR (Fortitude): flat AC Rating, +1 per rank.
  int    get _scoreFor => abilityScoreRank('for_');
  // DUR (Durability, formerly LCK): +0.5% Armor Class Rating per rank. Stored
  // under the legacy 'lck' key so existing invested ranks carry over.
  double get _scoreDurPct => abilityScoreRank('lck') * 0.5;

  // ── Ability rank upgrades ──────────────────────────────────────────────────

  final Map<String, int> _abilityRanks = {};
  final Map<String, String> abilityBranches = {};

  int abilityRank(String id) => _abilityRanks[id] ?? 0;

  // ── Ability Ascension (spent with Ascension Points) ──────────────────────────
  // A second, permanent upgrade track on top of the shard-based ranks. Each of a
  // class's 6 abilities can be ascended 0..10 tiers for 1 AP per tier (60 AP to
  // fully ascend a character). Each tier adds +10% to that ability's power, and
  // it survives every reset (rebirth and ascension) like the ascension tree.
  final Map<String, int> _abilityAscension = {};
  static const int kAbilityAscendMaxTier = 10;
  static const double kAbilityAscendPerTier = 0.10; // +10% ability power per tier

  int abilityAscensionTier(String id) => _abilityAscension[id] ?? 0;
  double abilityAscensionMult(String id) =>
      1.0 + abilityAscensionTier(id) * kAbilityAscendPerTier;

  /// Ability ascension is unlocked by the difficulty tiers you've unlocked
  /// (one per rebirth), not by spending Ascension Points. You can ascend each
  /// ability up to your [highestUnlockedTier] (capped at [kAbilityAscendMaxTier]).
  bool canAscendAbility(String id) {
    final tier = abilityAscensionTier(id);
    return tier < kAbilityAscendMaxTier && tier < highestUnlockedTier;
  }

  bool ascendAbility(String id) {
    final tier = abilityAscensionTier(id);
    if (tier >= kAbilityAscendMaxTier) return false;
    if (tier >= highestUnlockedTier) return false; // gated by unlocked difficulty tier
    _abilityAscension[id] = tier + 1;
    notifyListeners();
    saveToLocal();
    return true;
  }

  // Tier 0 = ranks 1-15, Tier 1 = ranks 16-30, ..., Tier 10 = ranks 151-165
  static const int kAbilityMaxRank = 165;
  static int _abilityTierFromRank(int r) => r == 0 ? 0 : (r - 1) ~/ 15;
  static int _abilityRankInTierFrom(int r) => r == 0 ? 0 : (r - 1) % 15 + 1;

  int abilityTier(String id)       => _abilityTierFromRank(abilityRank(id));
  int abilityRankInTier(String id) => _abilityRankInTierFrom(abilityRank(id));

  // True if the next upgrade would cross into a new tier the player hasn't unlocked.
  // Ability rank-tiers unlock with your difficulty tier (raised by clearing the
  // campaign), matching the rest of the tier-based progression.
  bool abilityTierLocked(String id) {
    final r        = abilityRank(id);
    final nextTier = _abilityTierFromRank(r + 1);
    final curTier  = _abilityTierFromRank(r);
    return nextTier > curTier && highestUnlockedTier < nextTier;
  }

  // Rebirth count needed to unlock the next tier for this ability.
  int abilityNextTierPrestige(String id) => _abilityTierFromRank(abilityRank(id) + 1);

  static const abilityRespecCost = 150;

  bool respecAbilities() {
    if (zcoins < abilityRespecCost) return false;
    // Calculate shard refund
    var refund = 0;
    for (final entry in _abilityRanks.entries) {
      for (int r = 0; r < entry.value; r++) {
        if (r < _abilityUpgradeCosts.length) refund += _abilityUpgradeCosts[r];
      }
    }
    zcoins -= abilityRespecCost;
    shards += refund;
    _abilityRanks.clear();
    abilityBranches.clear();
    _milestoneChoices.clear();
    notifyListeners();
    saveToLocal();
    return true;
  }

  String? abilityBranchChoice(String id) => abilityBranches[id];

  bool chooseBranch(String abilityId, String branchId) {
    if (abilityRank(abilityId) < 3) return false;
    if (abilityBranches.containsKey(abilityId)) return false;
    abilityBranches[abilityId] = branchId;
    notifyListeners();
    saveToLocal();
    return true;
  }

  // ── Class questlines ──────────────────────────────────────────────────────

  // Tracking counters for tutorial quests
  int _itemsEquipped = 0;
  int _abilitiesUpgraded = 0;
  int _passivesUnlocked = 0;
  int _gemsSocketed = 0;
  int _itemsForged = 0;
  int _expeditionsCompleted = 0;
  int _totalEssenceEarned = 0;
  int _artifactsCollected = 0;

  void trackEquipItem() { _itemsEquipped++; }
  void trackUpgradeAbility() { _abilitiesUpgraded++; }
  void trackUnlockPassive() { _passivesUnlocked++; }
  void trackSocketGem() { _gemsSocketed++; }
  void trackForgeItem() { _itemsForged++; }
  void trackExpeditionComplete() { _expeditionsCompleted++; }
  void trackEssenceEarned(int amount) { _totalEssenceEarned += amount; }
  void trackArtifactCollected() { _artifactsCollected++; }

  int _questCounter(QuestCondition cond) => switch (cond) {
    QuestCondition.killEnemies       => _totalKills,
    QuestCondition.winBattles        => _totalBattleWins,
    QuestCondition.reachStage        => campaignStageIndex + 1,
    QuestCondition.bossKills         => _totalBossKills,
    QuestCondition.useAbilities      => _totalAbilityUses,
    QuestCondition.dungeonClears     => _dungeonClears,
    QuestCondition.gauntletScore     => gauntletHighScore,
    QuestCondition.bossRushClears    => _bossRushClears,
    QuestCondition.prestigeReach     => highestUnlockedTier, // "prestige" quests now track tier unlocks
    QuestCondition.ascensionReach    => ascensionLevel,
    QuestCondition.equipItem         => _itemsEquipped,
    QuestCondition.upgradeAbility    => _abilitiesUpgraded,
    QuestCondition.unlockPassive     => _passivesUnlocked,
    QuestCondition.socketGem         => _gemsSocketed,
    QuestCondition.forgeItem         => _itemsForged,
    QuestCondition.completeExpedition => _expeditionsCompleted,
    QuestCondition.pvpWins           => pvpWins,
    QuestCondition.reachLevel        => hero.level,
    QuestCondition.earnGold          => _totalGoldEarned,
    QuestCondition.earnEssence       => _totalEssenceEarned,
    QuestCondition.collectArtifact   => _artifactsCollected,
    QuestCondition.endlessStage      => endlessPersonalBest,
  };

  // Adventure quest progress (universal questline)
  int adventureQuestProgress(AdventureQuest q) =>
      _questCounter(q.condition).clamp(0, q.target);

  /// The quest to show in the in-combat beacon: the first unlocked quest that is
  /// still IN PROGRESS (not yet claimed AND not yet met). A completed-but-unclaimed
  /// quest (e.g. "First Kill" at 1/1) is skipped so it stops popping up mid-battle;
  /// since quests unlock sequentially, this returns null until you claim it.
  AdventureQuest? get currentAdventureQuest {
    for (final q in AdventureQuest.allQuests) {
      if (questsClaimed[q.id] == true) continue;
      if (!isAdventureQuestUnlocked(q)) continue;
      if (isAdventureQuestMet(q)) continue; // done but unclaimed — don't show
      return q;
    }
    return null;
  }

  bool isAdventureQuestMet(AdventureQuest q) =>
      _questCounter(q.condition) >= q.target;

  bool isAdventureQuestUnlocked(AdventureQuest q) {
    if (q.questIndex == 0) return true;
    final prev = AdventureQuest.allQuests[q.questIndex - 1];
    return questsClaimed[prev.id] == true;
  }

  bool isAdventureQuestClaimable(AdventureQuest q) =>
      isAdventureQuestUnlocked(q) &&
      isAdventureQuestMet(q) &&
      questsClaimed[q.id] != true;

  bool claimAdventureQuest(AdventureQuest q) {
    if (!isAdventureQuestClaimable(q)) return false;
    questsClaimed[q.id] = true;
    final r = q.reward;
    gold += r.gold;
    shards += r.shards;
    zcoins += r.zcoins;
    echoes += r.echoes;
    essence += r.essence;
    mythril += r.mythril;
    if (r.title != null) heroTitle = r.title;
    notifyListeners();
    saveToLocal();
    return true;
  }

  int get adventureQuestsClaimable => AdventureQuest.allQuests
      .where(isAdventureQuestClaimable).length;

  // ── Boss Bounties (defeat specific campaign bosses) ─────────────────────────
  // The boss bounties for the tier you're currently playing. Reaching a new tier
  // hands you a fresh set (campaign progress resets, so they re-lock) with
  // rewards scaled up for the harder fights.
  List<BossHunt> get bossBounties => bossBountiesForTier(activeTier);

  // A boss is "slain" once you've advanced past its stage in the current tier,
  // or if the bounty belongs to a tier you've already cleared past.
  bool isBossHuntMet(BossHunt h) =>
      h.tier < activeTier ||
      (h.tier == activeTier && campaignStageIndex >= h.stage + 1);
  int  bossHuntProgress(BossHunt h) => isBossHuntMet(h) ? 1 : 0;
  bool isBossHuntClaimed(BossHunt h) => questsClaimed[h.id] == true;
  bool isBossHuntClaimable(BossHunt h) =>
      isBossHuntMet(h) && questsClaimed[h.id] != true;

  /// The guaranteed loot rarity for a boss bounty. Ramps with the boss ordinal
  /// (early bosses → uncommon/rare, later → epic/legendary, final → mythic) and
  /// each difficulty tier raises the floor by one step, so higher tiers reliably
  /// drop better gear.
  ItemRarity bossBountyLootRarity(BossHunt h) {
    final n = h.ordinal; // 1..20
    // final boss → mythic; then legendary / epic / rare / uncommon by ordinal.
    final base = n >= 20 ? 5 : n >= 15 ? 4 : n >= 10 ? 3 : n >= 5 ? 2 : 1;
    final step = (base + h.tier).clamp(1, 5);
    return switch (step) {
      5 => ItemRarity.mythic,
      4 => ItemRarity.legendary,
      3 => ItemRarity.epic,
      2 => ItemRarity.rare,
      _ => ItemRarity.uncommon,
    };
  }

  /// The last piece of gear dropped by a boss bounty claim — read by the UI to
  /// announce what dropped.
  EquipmentItem? lastBossBountyLoot;

  bool claimBossHunt(BossHunt h) {
    if (!isBossHuntClaimable(h)) return false;
    questsClaimed[h.id] = true;
    final r = h.reward;
    gold += r.gold;
    shards += r.shards;
    zcoins += r.zcoins;
    echoes += r.echoes;
    essence += r.essence;
    mythril += r.mythril;
    if (r.title != null) heroTitle = r.title;
    // Guaranteed gear drop — rarity/power scale with boss ordinal and tier.
    final rarity = bossBountyLootRarity(h);
    final slot = ItemSlot.values[_rng.nextInt(ItemSlot.values.length)];
    final loot = ItemLootTable.craftAt(
        slot, rarity, max(1, hero.level), _rng, rebirthLevel: h.tier);
    inventory.addToBag(loot);
    lastBossBountyLoot = loot;
    _syncParagonLevels();
    _setLastAction('Boss Bounty: ${h.name} slain! Looted ${loot.name}.');
    notifyListeners();
    saveToLocal();
    return true;
  }

  int get bossHuntsClaimable => bossBounties.where(isBossHuntClaimable).length;

  int questProgress(ClassQuest q) =>
      _questCounter(q.condition).clamp(0, q.target);

  bool isQuestConditionMet(ClassQuest q) =>
      _questCounter(q.condition) >= q.target;

  // True once all 5 main class quests (indices 0–4) are claimed.
  bool get classUltimateUnlocked {
    final quests = ClassQuestData.questsForClass(hero.heroClass);
    return quests.length >= 5 && quests.take(5).every((q) => questsClaimed[q.id] == true);
  }

  bool isQuestUnlocked(ClassQuest q) {
    if (q.questIndex == 0) return hero.level >= 30; // questline gate: level 30
    final all = ClassQuestData.questsForClass(q.classRequired);
    return questsClaimed[all[q.questIndex - 1].id] == true;
  }

  bool isQuestClaimable(ClassQuest q) =>
      isQuestUnlocked(q) &&
      isQuestConditionMet(q) &&
      questsClaimed[q.id] != true;

  int get questsClaimable => ClassQuestData.questsForClass(hero.heroClass)
      .where(isQuestClaimable).length;

  bool get hasClaimableQuest =>
      adventureQuestsClaimable > 0 || questsClaimable > 0;

  void claimAllQuests() {
    for (final q in AdventureQuest.allQuests) {
      claimAdventureQuest(q);
    }
    for (final q in ClassQuestData.questsForClass(hero.heroClass)) {
      claimQuest(q);
    }
  }

  bool claimQuest(ClassQuest q) {
    if (!isQuestClaimable(q)) return false;
    questsClaimed[q.id] = true;
    gold    += q.reward.gold;
    shards  += q.reward.shards;
    zcoins  += q.reward.zcoins;
    echoes  += q.reward.echoes;
    essence += q.reward.essence;
    mythril += q.reward.mythril;
    if (q.reward.title != null) heroTitle = q.reward.title;
    // Completing the class questline unlocks the Ultimate ability — coach it once
    // (so the player knows their most powerful skill is now live and how it works).
    if (classUltimateUnlocked && !_ultimateUnlockedTutorialSeen && pendingTutorial == null) {
      _ultimateUnlockedTutorialSeen = true;
      _triggerTutorial(const SystemTutorial(
        stage: -5, navTab: 0, subTab: 'ABILITIES', icon: '🌟',
        title: 'Ultimate Unlocked!',
        howTo: 'You completed your class questline — your Ultimate ability is now '
            'unlocked! It\'s your most powerful skill, on a long cooldown, and it '
            'fires automatically in battle like your other abilities. Spend Shards '
            'here to rank it up and pick its milestone upgrades.',
      ));
    }
    notifyListeners();
    saveToLocal();
    return true;
  }

  int _questStatBonus(int Function(QuestReward) getter) {
    int total = 0;
    for (final q in ClassQuestData.questsForClass(hero.heroClass)) {
      if (questsClaimed[q.id] == true) total += getter(q.reward);
    }
    return total;
  }

  int get questAttackBonus   => _questStatBonus((r) => r.permanentAttackBonus);
  int get questACBonus       => _questStatBonus((r) => r.permanentACBonus);
  int get questDamageBonus   => _questStatBonus((r) => r.permanentDamageBonus);

  // ── Milestone choices ─────────────────────────────────────────────────────

  final Map<String, String> _milestoneChoices = {};

  String? milestoneChoice(String abilityId, int rank) =>
      _milestoneChoices['${abilityId}_m$rank'];

  /// The active milestone RIDER (secondary bonusEffect) the player chose for
  /// [ability], if any. Alt-modes use this so milestone choices actually fire
  /// outside the campaign. Last chosen rider wins — matches _fireAbility.
  ({AbilityEffect? effect, int value, int duration}) activeMilestoneRider(HeroAbility ability) {
    AbilityEffect? eff;
    int val = 0, dur = 0;
    for (final milestone in ability.milestones) {
      final choiceId = _milestoneChoices['${ability.id}_m${milestone.rank}'];
      if (choiceId == null) continue;
      final ch = choiceId == 'a' ? milestone.a : milestone.b;
      if (ch.bonusEffect != null) {
        eff = ch.bonusEffect;
        val = ch.bonusValue;
        dur = ch.bonusDuration;
      }
    }
    return (effect: eff, value: val, duration: dur);
  }

  void setMilestoneChoice(String abilityId, int rank, String choice) {
    _milestoneChoices['${abilityId}_m$rank'] = choice;
    notifyListeners();
    saveToLocal();
  }

  /// Returns the effective DamageType for the ability, considering any
  /// milestone choice that overrides the elemental type.
  DamageType abilityEffectiveDamageType(HeroAbility ability) {
    DamageType result = hero.activeDamageType;
    for (final milestone in ability.milestones) {
      final choiceId = _milestoneChoices['${ability.id}_m${milestone.rank}'];
      if (choiceId == null) continue;
      final choice = choiceId == 'a' ? milestone.a : milestone.b;
      if (choice.overrideDamageType != null) result = choice.overrideDamageType!;
    }
    return result;
  }

  // ── Rank / cost ───────────────────────────────────────────────────────────

  // Costs for ranks 1–100 (index = current rank, cost to reach next rank)
  // Ranks  1–10: early/mid-game accessible.
  // Ranks 11–15: steep late-game investment.
  // Ranks 16–50: prestige-era grind.
  // Ranks 51–100: endgame, plateaus at 20 000 shards/rank.
  static const _abilityUpgradeCosts = [
    5,    10,   15,    25,    40,     // ranks  1– 5  (subtotal 95)
    55,   75,   95,    120,   150,    // ranks  6–10  (subtotal 495)
    180,  220,  270,   330,   400,    // ranks 11–15  (subtotal 1400)
    450,  500,  560,   630,   700,    // ranks 16–20
    780,  860,  950,   1050,  1150,   // ranks 21–25
    1250, 1350, 1450,  1550,  1650,   // ranks 26–30
    1750, 1850, 1950,  2050,  2150,   // ranks 31–35
    2250, 2350, 2450,  2550,  2650,   // ranks 36–40
    2750, 2850, 2950,  3050,  3150,   // ranks 41–45
    3250, 3350, 3450,  3550,  3650,   // ranks 46–50
    3750, 3850, 3950,  4050,  4100,   // ranks 51–55
    4150, 4200, 4250,  4300,  4350,   // ranks 56–60
    4400, 4450, 4500,  4550,  4600,   // ranks 61–65
    4650, 4700, 4750,  4800,  4850,   // ranks 66–70
    4900, 4950, 5000,  5000,  5000,   // ranks 71–75
    5000, 5000, 5000,  5000,  5000,   // ranks 76–80
    5000, 5000, 5000,  5000,  5000,   // ranks 81–85
    5000, 5000, 5000,  5000,  5000,   // ranks 86–90
    5000, 5000, 5000,  5000,  5000,   // ranks 91–95
    5000, 5000, 5000,  5000,  5000,   // ranks 96–100
    5000, 5000, 5000,  5000,  5000,   // ranks 101–105  (tier 7)
    5000, 5000, 5000,  5000,  5000,   // ranks 106–110
    5000, 5000, 5000,  5000,  5000,   // ranks 111–115
    5000, 5000, 5000,  5000,  5000,   // ranks 116–120  (tier 8)
    5000, 5000, 5000,  5000,  5000,   // ranks 121–125
    5000, 5000, 5000,  5000,  5000,   // ranks 126–130
    5000, 5000, 5000,  5000,  5000,   // ranks 131–135  (tier 9)
    5000, 5000, 5000,  5000,  5000,   // ranks 136–140
    5000, 5000, 5000,  5000,  5000,   // ranks 141–145
    5000, 5000, 5000,  5000,  5000,   // ranks 146–150  (tier 10)
    5000, 5000, 5000,  5000,  5000,   // ranks 151–155
    5000, 5000, 5000,  5000,  5000,   // ranks 156–160
    5000, 5000, 5000,  5000,  5000,   // ranks 161–165  (max)
  ];

  int abilityUpgradeCost(String id) {
    final rank = abilityRank(id);
    if (rank >= kAbilityMaxRank) return 0;
    return (_abilityUpgradeCosts[rank] * prestigeAbilityDiscount).round().clamp(1, 99999);
  }

  bool upgradeAbility(String id) {
    if (abilityTierLocked(id)) return false;
    final cost = abilityUpgradeCost(id);
    if (cost == 0 || shards < cost) return false;
    shards -= cost;
    _abilityRanks[id] = abilityRank(id) + 1;
    trackUpgradeAbility(); // drives the "Power Up" quest (was never called)
    notifyListeners();
    saveToLocal();
    return true;
  }

  // Damage/impact multiplier keyed on an ability's ROLE, so power tracks the
  // cooldown + level-requirement the player already sees:
  //   • Ultimates (5-round cd) hit far harder than everything else.
  //   • The level-1 opener is a fast 1-round poke → baseline ×1.0.
  //   • Higher-level unlocks share the 3-round cooldown, so they scale up with
  //     their unlock level to stay "worth" the longer wait.
  // Applied only to damage-dealing effects (bonusDamage / dot); heals, buffs
  // and debuffs keep their designed values.
  double abilityPowerMult(HeroAbility ability) {
    if (ability.category == AbilityCategory.ultimate) return 3.5;
    return switch (ability.levelRequired) {
      <= 1  => 1.0,
      <= 5  => 1.35,
      <= 10 => 1.7,
      <= 15 => 2.1,
      <= 20 => 2.6,
      _     => 3.0,
    };
  }

  bool _isDamageAbilityEffect(AbilityEffect e) =>
      e == AbilityEffect.bonusDamage || e == AbilityEffect.dot;

  // Core rank/tier scaling — the SINGLE source of truth shared by the display,
  // the campaign combat, and the alternate modes. Callers layer on the
  // situational mults (ascension / unique-item / role power). Damage abilities
  // (bonusDamage / dot) scale off TOTAL rank so growth is smooth and monotonic
  // — a new tier never drops the value back down — with a tier multiplier on
  // top (×1 at T0 … ×4.5 at T10). Utility abilities (heals/buffs/debuffs are
  // percentages/rounds) get a gentle monotonic curve so we don't get a 3000%
  // heal.
  double _abilityScaledBase(int baseValue, int rank, bool isDamage) {
    if (rank == 0 || baseValue == 0) return baseValue.toDouble();
    final tier = _abilityTierFromRank(rank);
    if (isDamage) {
      final perRank = baseValue / 6.0;
      // Tier scaling smoothed 0.35 → 0.20 per tier (T10 spike ×4.5 → ×3.0) so
      // tiering up abilities is a gentler curve, not a burst.
      return (baseValue + rank * perRank) * (1.0 + tier * 0.20);
    }
    return (baseValue + rank * max<int>(1, baseValue ~/ 8)).toDouble();
  }

  // Full effective ability value used by the display AND the alternate modes:
  // core scaling × ability ascension (+10% per ascended tier) × role power
  // (damage only). The campaign combat path applies the role-power mult itself
  // (see [_fireAbility]) so it calls [_abilityScaledBase] directly instead.
  int scaledAbilityValueAtRank(HeroAbility ability, int rank) {
    if (ability.value == 0) return 0;
    final isDamage = _isDamageAbilityEffect(ability.effect);
    var v = _abilityScaledBase(ability.value, rank, isDamage);
    v *= abilityAscensionMult(ability.id);         // tier ascension (+10%/tier)
    if (isDamage) v *= abilityPowerMult(ability);  // role weighting
    return v.round();
  }

  int scaledAbilityValue(HeroAbility ability) =>
      scaledAbilityValueAtRank(ability, abilityRank(ability.id));

  /// Scaled value the ability would have if its base were [baseValue], at the
  /// current rank — used to preview a milestone choice's exact number change.
  int scaledAbilityValueForBase(HeroAbility ability, int baseValue) {
    if (baseValue <= 0) return 0;
    final rank = abilityRank(ability.id);
    final isDamage = _isDamageAbilityEffect(ability.effect);
    var v = _abilityScaledBase(baseValue, rank, isDamage);
    v *= abilityAscensionMult(ability.id);
    if (isDamage) v *= abilityPowerMult(ability);
    return v.round();
  }

  int scaledAbilityCooldown(HeroAbility ability) {
    // Cooldown is role-based, not tier-based, so upgrading or unlocking a
    // higher ability never makes it slower. The first ability (unlocked at
    // level 1) is a fast 1-round attack; ultimates are slow but powerful (5);
    // every other ability sits at 3. Ranking up boosts an ability's power
    // (its value/damage), never its cooldown.
    final baseCd = ability.levelRequired <= 1
        ? 1
        : ability.category == AbilityCategory.ultimate
            ? 5
            : 3;
    // Heal abilities carry a +2 cooldown surcharge on top of their role cooldown
    // — even after the burst/aura nerfs, healing too often let heroes out-sustain
    // incoming damage. Build cooldown-reductions below still apply.
    final healSurcharge = ability.effect == AbilityEffect.heal ? 2 : 0;
    // Timed effects (auras, self-buffs, lasting debuffs) get a +2 surcharge too.
    // At base cooldown 3 a duration-3/4 buff sits at ~100% uptime, so its
    // duration-extending milestones were dead picks. +2 gives base duration a
    // downtime gap, so extending duration meaningfully raises uptime and is
    // finally worth choosing.
    final e = ability.effect;
    final isTimedEffect = e == AbilityEffect.aura
        || e == AbilityEffect.attackBonus
        || e == AbilityEffect.acBonus
        || e == AbilityEffect.debuffWeaken
        || e == AbilityEffect.debuffVulnerable
        || e == AbilityEffect.missChance;
    final auraSurcharge = isTimedEffect ? 2 : 0;
    // Cooldown reduction is meant to feel SPECIAL and rare, so the total shaved
    // from build investments (cooldown passive, subclass, trait, unique gear) is
    // hard-capped — abilities can never be spammed. Abilities also no longer
    // auto-speed-up as you rank them (that made low cooldowns too easy). Ranking
    // boosts an ability's power, not its cadence.
    final subclassDiscount = (subclassEffect == SubclassEffect.arcaneTrickster ? 1 : 0)
        + subclassCooldownReduce;
    final uniqueItem = inventory.equipped.values
        .where((i) => i.uniqueAbilityId == ability.id)
        .firstOrNull;
    final uniqueCdReduce = uniqueItem?.abilityCooldownFlat ?? 0;
    final cdReduce = (passiveTree.totalOf(PassiveEffect.cooldownReduce)
        + subclassDiscount + traitCooldownReduction + uniqueCdReduce)
        .clamp(0, kMaxCooldownReduction);
    return max(1, baseCd + healSurcharge + auraSurcharge - cdReduce);
  }

  // Buff/debuff state exposed for the HUD
  int get buffAttackBonus  => _tempAttackBonus;
  int get buffAttackRounds => _tempAttackBonusRounds;
  int get buffAcBonus      => _tempAcBonus;
  int get buffAcRounds     => _tempAcBonusRounds;
  int get dotDmg           => _dotDmg;
  int get dotRoundsLeft    => _dotRoundsLeft;
  int get enemyStunRounds      => _enemyStunRounds;
  int get stunApplicationCount => _stunApplicationCount;
  bool get dodgeNextHit        => _dodgeNextHit;
  int get auraHealPerRound     => _auraHealPerRound;
  int get auraRoundsLeft       => _auraRoundsLeft;

  // Classes with no reliable base heal. Their aura ability doubles as lifesteal
  // (heal a share of damage dealt) while active — the sustain window that lets
  // pure-damage builds survive sustained-damage bosses like Necromancer Vael.
  static const _noHealClasses = {
    DndClass.barbarian, DndClass.fighter, DndClass.rogue, DndClass.ranger,
    DndClass.monk, DndClass.sorcerer, DndClass.warlock, DndClass.wizard,
  };
  static const auraLifestealPct = 25;
  bool get auraLifestealActive =>
      _auraRoundsLeft > 0 && _noHealClasses.contains(hero.heroClass);
  int get enemyWeakenPct       => _enemyWeakenPct;
  int get enemyWeakenRounds    => _enemyWeakenRounds;
  int get enemyVulnerablePct    => _enemyVulnerablePct;
  int get enemyVulnerableRounds => _enemyVulnerableRounds;
  int get enemySilenceRounds    => _enemySilenceRounds;
  int get enemyMissChancePct    => _enemyMissChancePct;
  int get enemyMissChanceRounds => _enemyMissChanceRounds;
  int get heroAbsorbShield      => _heroAbsorbShield;
  // Hero-afflicted status (from boss abilities)
  int get heroStunRounds       => _heroStunRounds;
  int get heroDotRoundsLeft    => _heroDotRoundsLeft;
  int get heroDotDmgPerRound   => _heroDotDmgPerRound;
  DamageType get heroDotType   => _heroDotType;

  void _fireAbility(HeroAbility ability) {
    final enemy = currentEnemy;
    if (enemy == null) return;
    _dailyAbilityUses++;
    _totalAbilityUses++;
    audioService.playAbilityFull(ability.effect, abilityEffectiveDamageType(ability));
    // Resolve all active milestone choices: collect value/duration deltas + bonus effect
    int valueDeltaSum    = 0;
    int durationDeltaSum = 0;
    AbilityEffect? effectOverride;
    AbilityEffect? bonusEff;
    int bonusVal = 0;
    int bonusDur = 0;
    for (final milestone in ability.milestones) {
      final choiceId = _milestoneChoices['${ability.id}_m${milestone.rank}'];
      if (choiceId == null) continue;
      final ch = choiceId == 'a' ? milestone.a : milestone.b;
      valueDeltaSum    += ch.valueDelta;
      durationDeltaSum += ch.durationDelta;
      if (ch.effectOverride != null) effectOverride = ch.effectOverride;
      if (ch.bonusEffect != null) {
        bonusEff = ch.bonusEffect;
        bonusVal = ch.bonusValue;
        bonusDur = ch.bonusDuration;
      }
    }
    final rank      = abilityRank(ability.id);
    final baseValue = ability.value + valueDeltaSum;
    // Unique legendary item mods
    final uniqueModItem = inventory.equipped.values
        .where((i) => i.uniqueAbilityId == ability.id)
        .firstOrNull;
    final uniqueMult      = uniqueModItem?.abilityValueMult ?? 1.0;
    final uniqueDurAdd    = uniqueModItem?.abilityDurationAdd ?? 0;
    // Ability Ascension: each ascended tier adds +10% to this ability's power.
    final ascMult   = abilityAscensionMult(ability.id);
    // Same core rank/tier scaling as the display/modes; the role-power mult is
    // applied later (at the damage step), so it is NOT included here.
    final int sv    = (_abilityScaledBase(baseValue, rank, _isDamageAbilityEffect(ability.effect))
        * uniqueMult * ascMult).round();
    // Ascension only buffs ability magnitude (damage / heal via [ascMult]) — it no
    // longer extends duration. Duration/cooldown are meant to feel special, so
    // value-less utility abilities (pure stun/silence/dodge) gain nothing here.
    var effectiveDuration = ability.duration + durationDeltaSum + uniqueDurAdd;
    // Downtime rule: a timed effect can never reach its cooldown (that would mean
    // ≥100% uptime), so cap duration below the cooldown. Instant effects (0) stay 0.
    if (effectiveDuration > 0) {
      final cd = scaledAbilityCooldown(ability);
      if (cd > 1 && effectiveDuration >= cd) effectiveDuration = cd - 1;
    }
    final primaryEffect     = effectOverride ?? ability.effect;
    lastAbilityFired = (id: ability.id, name: ability.name, effect: primaryEffect);
    _fightAbilities[ability.name] = (_fightAbilities[ability.name] ?? 0) + 1;

    final subclassAbilityBonus = subclassAbilityPowerPct + switch (subclassEffect) {
      SubclassEffect.loreKeeper  => 0.20,
      SubclassEffect.greatOldOne => 0.25,
      SubclassEffect.evoker      => 0.35,
      _ => 0.0,
    };
    // Healing is a RATING with diminishing returns (same curve as armor): a
    // single ability heals AT MOST kDefenseCapPct (37.5%) of max HP. Heal HP for
    // a heal [value] (its % base, e.g. 30) = maxHP × [abilityHealPct]. [factor]
    // scales it — bursts 1.0, per-round HoT auras 0.5. [fatigueMult] applies
    // repeated-heal fatigue to bursts.
    // Heals are now a multiple of Heal Rating (decoupled from max HP), so a hero
    // who doesn't invest in Heal Rating gets little/no healing.
    int healHp(num value, double factor, [double fatigueMult = 1.0]) =>
        (healFor(value, factor: factor) * fatigueMult).round().clamp(0, 1000000000000000).toInt();
    if (subclassEffect == SubclassEffect.valorSurge) _valorSurgeReady = true;

    // Shared context params for damage abilities
    final exploitAcThreshold = endlessUpgrades.synergyMindweave ? 16 : 14;
    final _abilityExploitMult = (endlessUpgrades.exploitWeakness && enemy.armorClass <= exploitAcThreshold) ? 1.30 : 1.0;
    final _abilityWeakMult    = bestiaryWeaknessBonus(enemy.id) * bestiaryTypeDamageMult(enemy.id);
    final _basePenPct = passiveTree.totalOf(PassiveEffect.allPenetration)
        + inventory.totalOf(ItemStat.elemPenetration);
    Map<DamageType, double> _abilityPenMap(int extra) {
      final total = _basePenPct + extra;
      return total > 0
          ? <DamageType, double>{hero.activeDamageType: total / 100.0}
          : const <DamageType, double>{};
    }

    // Hit damage tracked so bonus DoTs can scale as % of it
    int? primaryHitDmg;

    switch (primaryEffect) {
      case AbilityEffect.bonusDamage:
        final psv = (sv * abilityPowerMult(ability)).round().clamp(1, 1000000000000000);
        // nextDouble (not nextInt) so the roll works past nextInt's 2^32 limit.
        final baseDmg = (_rng.nextDouble() * psv).floor() + 1 + hero.baseDmg;
        final ctx = buildAbilityAttackContext(
          baseDmg:              baseDmg,
          heroType:             hero.activeDamageType,
          allDamagePct:         passiveTree.totalOf(PassiveEffect.allDamage).toDouble() + ascAllDamagePct + critReplacementDamagePct + allyDmgPctBonus
                                + passiveElemDamagePct(hero.activeDamageType)
                                + gemElemDamagePct(hero.activeDamageType)
                                + inventory.totalOf(ItemStat.damagePercent)
                                + hero.levelBonusDamagePct + guildBuffs.allDamagePct,
          abilityDamagePct:     passiveTree.totalOf(PassiveEffect.abilityDamage).toDouble(),
          subclassAbilityBonus: subclassAbilityBonus,
          endlessDmgMult:       endlessUpgrades.damageMultiplier,
          exploitMult:          _abilityExploitMult,
          comboStacks:          _comboStacks,
          bestiaryWeakMult:     _abilityWeakMult,
          isDot:                false,
          enemyResistances:     enemy.resistances,
          penetration:          _abilityPenMap(ability.penetration),
        );
        final dmg = calculateDamage(ctx, rng: _rng).total.round().clamp(1, 1000000000000000);
        enemy.takeDamage(dmg);
        _recordFightDamage(dmg);
        pendingFloats.add((value: dmg, isHeal: false, type: hero.activeDamageType));
        battleLog.add('${ability.name}! +$dmg bonus damage.');
        primaryHitDmg = dmg;
      case AbilityEffect.heal:
        final fatigue = pow(0.85, _healsThisBattle).toDouble();
        _healsThisBattle++;
        var hp = healHp(sv, 1.0, fatigue);
        if (_activeAffixes.contains(ZoneAffix.voidCurse)) hp = (hp / 2).round().clamp(1, 1000000000000000);
        hero.currentHealth = (hero.currentHealth + hp).clamp(0, hero.maxHealth);
        pendingFloats.add((value: hp, isHeal: true, type: DamageType.physical));
        battleLog.add(_healsThisBattle > 1
            ? '${ability.name}! +$hp HP restored. (heal fatigue)'
            : '${ability.name}! +$hp HP restored.');
      case AbilityEffect.attackBonus:
        _tempAttackBonus = max(_tempAttackBonus, sv);
        _tempAttackBonusRounds = max(_tempAttackBonusRounds, effectiveDuration);
        battleLog.add('${ability.name}! +$sv% damage for $effectiveDuration rounds.');
      case AbilityEffect.acBonus:
        _tempAcBonus = max(_tempAcBonus, sv);
        _tempAcBonusRounds = max(_tempAcBonusRounds, effectiveDuration);
        battleLog.add('${ability.name}! +$sv% Armor Class for $effectiveDuration rounds.');
      case AbilityEffect.stun:
        final stunDur = effectiveDuration + (subclassEffect == SubclassEffect.battleMaster ? 1 : 0);
        _applyStun(stunDur, '${ability.name}! ${enemy.name}');
      case AbilityEffect.dot:
        final sporeBonus = (subclassEffect == SubclassEffect.sporeCircle ? 0.50 : 0.0)
            + subclassDotPct;
        final dotCtx = buildAbilityAttackContext(
          baseDmg:              (sv * abilityPowerMult(ability)).round().clamp(1, 1000000000000000),
          heroType:             hero.activeDamageType,
          allDamagePct:         passiveTree.totalOf(PassiveEffect.allDamage).toDouble() + ascAllDamagePct + critReplacementDamagePct + allyDmgPctBonus
                                + passiveElemDamagePct(hero.activeDamageType)
                                + gemElemDamagePct(hero.activeDamageType)
                                + inventory.totalOf(ItemStat.damagePercent)
                                + hero.levelBonusDamagePct + guildBuffs.allDamagePct,
          abilityDamagePct:     passiveTree.totalOf(PassiveEffect.abilityDamage).toDouble() + sporeBonus * 100,
          subclassAbilityBonus: subclassAbilityBonus,
          endlessDmgMult:       endlessUpgrades.damageMultiplier,
          exploitMult:          _abilityExploitMult,
          comboStacks:          _comboStacks,
          bestiaryWeakMult:     _abilityWeakMult,
          isDot:                true,
          enemyResistances:     enemy.resistances,
          penetration:          _abilityPenMap(ability.penetration),
        );
        _dotDmg = calculateDamage(dotCtx, rng: _rng).total.round().clamp(1, 1000000000000000);
        _dotRoundsLeft = effectiveDuration;
        _dotDamageType = hero.activeDamageType;
        battleLog.add('${ability.name}! ${enemy.name} takes $_dotDmg dmg/round for $effectiveDuration rounds.');
        primaryHitDmg = _dotDmg;
      case AbilityEffect.dodge:
        _dodgeNextHit = true;
        battleLog.add('${ability.name}! ${hero.name} will dodge the next attack.');
      case AbilityEffect.aura:
        // HoT: per-round heal is half the burst cap (max ~18.75% of max HP/round)
        _auraHealPerRound = healHp(sv, 0.5);
        _auraRoundsLeft   = effectiveDuration;
        battleLog.add('${ability.name}! ${hero.name} regenerates $_auraHealPerRound HP/round for $effectiveDuration rounds.');
      case AbilityEffect.debuffWeaken:
        // ATK reduction caps at 100% (a full disarm — hard CC, shares stun DR via
        // _applyEnemyWeaken). Anything above that — e.g. from ranking up Disarm —
        // spills over into Vulnerability (not CC), so every upgrade still helps.
        _applyEnemyWeaken(sv, effectiveDuration, '${ability.name}! ${enemy.name}');
        final weakenOverflow = sv - 100;
        if (weakenOverflow > 0) {
          _enemyVulnerablePct    = max(_enemyVulnerablePct, weakenOverflow);
          _enemyVulnerableRounds = max(_enemyVulnerableRounds, effectiveDuration);
          battleLog.add('${enemy.name} exposed (+$weakenOverflow% damage taken) for $effectiveDuration rounds.');
        }
      case AbilityEffect.debuffVulnerable:
        _enemyVulnerablePct    = sv;
        _enemyVulnerableRounds = effectiveDuration;
        battleLog.add('${ability.name}! ${enemy.name} takes $sv% more damage for $effectiveDuration rounds.');
      case AbilityEffect.silence:
        _applyEnemySilence(effectiveDuration, '${ability.name}! ${enemy.name}');
      case AbilityEffect.absorbShield:
        _heroAbsorbShield = sv;
        battleLog.add('${ability.name}! ${hero.name} gains a $sv HP barrier!');
      case AbilityEffect.missChance:
        _enemyMissChancePct    = sv.clamp(0, 66).toInt(); // caps at ~2/3 — never a full lockout
        _enemyMissChanceRounds = effectiveDuration;
        battleLog.add('${ability.name}! ${enemy.name} has $sv% chance to miss for $effectiveDuration rounds.');
      case AbilityEffect.frozen:
        // Cold hard-CC: enemy skips its turn (like stun), shares the stun DR pool.
        final dur = _hardCcDuration(effectiveDuration);
        if (dur <= 0) {
          battleLog.add('${ability.name}! ${enemy.name} resists being frozen! (DR)');
        } else {
          _enemyStunRounds = dur;
          battleLog.add('❄ ${ability.name}! ${enemy.name} is frozen solid for $dur round(s)!');
        }
      case AbilityEffect.shocked:
        // Lightning hard-CC: enemy skips its turn AND is conductive (+25% damage
        // taken while shocked). Shares the stun DR pool.
        final dur = _hardCcDuration(effectiveDuration);
        if (dur <= 0) {
          battleLog.add('${ability.name}! ${enemy.name} resists the shock! (DR)');
        } else {
          _enemyStunRounds = dur;
          _enemyVulnerablePct    = max(_enemyVulnerablePct, 25);
          _enemyVulnerableRounds = max(_enemyVulnerableRounds, dur);
          battleLog.add('⚡ ${ability.name}! ${enemy.name} is shocked for $dur round(s) (+25% damage taken)!');
        }
      case AbilityEffect.burning:
        // Fire DoT — torches the enemy each round (no CC, no DR).
        final burnCtx = buildAbilityAttackContext(
          baseDmg:              (sv * abilityPowerMult(ability)).round().clamp(1, 1000000000000000),
          heroType:             hero.activeDamageType,
          allDamagePct:         passiveTree.totalOf(PassiveEffect.allDamage).toDouble() + ascAllDamagePct + critReplacementDamagePct + allyDmgPctBonus
                                + passiveElemDamagePct(hero.activeDamageType)
                                + gemElemDamagePct(hero.activeDamageType)
                                + inventory.totalOf(ItemStat.damagePercent)
                                + hero.levelBonusDamagePct + guildBuffs.allDamagePct,
          abilityDamagePct:     passiveTree.totalOf(PassiveEffect.abilityDamage).toDouble(),
          subclassAbilityBonus: subclassAbilityBonus,
          endlessDmgMult:       endlessUpgrades.damageMultiplier,
          exploitMult:          _abilityExploitMult,
          comboStacks:          _comboStacks,
          bestiaryWeakMult:     _abilityWeakMult,
          isDot:                true,
          enemyResistances:     enemy.resistances,
          penetration:          _abilityPenMap(ability.penetration),
        );
        final burnTick = calculateDamage(burnCtx, rng: _rng).total.round().clamp(1, 1000000000000000);
        _dotDmg = max(_dotDmg, burnTick);
        _dotRoundsLeft = max(_dotRoundsLeft, effectiveDuration);
        _dotDamageType = hero.activeDamageType;
        battleLog.add('🔥 ${ability.name}! ${enemy.name} is burning — $_dotDmg dmg/round for $effectiveDuration rounds.');
        primaryHitDmg = burnTick;
      case AbilityEffect.envenomed:
        // Poison DoT — STACKS additively each application, capped at ~5 stacks so
        // it ramps the longer poison is kept up but can't run away.
        final venomCtx = buildAbilityAttackContext(
          baseDmg:              (sv * abilityPowerMult(ability)).round().clamp(1, 1000000000000000),
          heroType:             hero.activeDamageType,
          allDamagePct:         passiveTree.totalOf(PassiveEffect.allDamage).toDouble() + ascAllDamagePct + critReplacementDamagePct + allyDmgPctBonus
                                + passiveElemDamagePct(hero.activeDamageType)
                                + gemElemDamagePct(hero.activeDamageType)
                                + inventory.totalOf(ItemStat.damagePercent)
                                + hero.levelBonusDamagePct + guildBuffs.allDamagePct,
          abilityDamagePct:     passiveTree.totalOf(PassiveEffect.abilityDamage).toDouble(),
          subclassAbilityBonus: subclassAbilityBonus,
          endlessDmgMult:       endlessUpgrades.damageMultiplier,
          exploitMult:          _abilityExploitMult,
          comboStacks:          _comboStacks,
          bestiaryWeakMult:     _abilityWeakMult,
          isDot:                true,
          enemyResistances:     enemy.resistances,
          penetration:          _abilityPenMap(ability.penetration),
        );
        final venomTick = calculateDamage(venomCtx, rng: _rng).total.round().clamp(1, 1000000000000000);
        _dotDmg = (_dotDmg + venomTick).clamp(1, venomTick * 5);
        _dotRoundsLeft = max(_dotRoundsLeft, effectiveDuration);
        _dotDamageType = hero.activeDamageType;
        battleLog.add('☠ ${ability.name}! ${enemy.name} is envenomed — $_dotDmg dmg/round for $effectiveDuration rounds.');
        primaryHitDmg = venomTick;
      case AbilityEffect.withered:
        // Void soft −ATK: saps the enemy's attack (not CC, no DR). Caps at 60%.
        final wpct = sv.clamp(0, 60);
        _enemyWeakenPct    = max(_enemyWeakenPct, wpct);
        _enemyWeakenRounds = max(_enemyWeakenRounds, effectiveDuration);
        battleLog.add('🟣 ${ability.name}! ${enemy.name} is withered — ATK −$wpct% for $effectiveDuration rounds.');
    }

    // ── Bonus effect from active milestone choice ─────────────────────────
    if (bonusEff != null) {
      // Use the ability's actual damage output as the scaling reference;
      // fall back to sv for non-damage primaries (debuffs, buffs, etc.)
      final ref = primaryHitDmg ?? sv;
      switch (bonusEff) {
        case AbilityEffect.dot:
          // bonusVal is % of the ability's damage output per tick
          final dotBase = (ref * bonusVal / 100).round().clamp(1, 1000000000000000);
          final bonusDotCtx = buildAbilityAttackContext(
            baseDmg:              dotBase,
            heroType:             hero.activeDamageType,
            allDamagePct:         passiveTree.totalOf(PassiveEffect.allDamage).toDouble() + ascAllDamagePct + critReplacementDamagePct + allyDmgPctBonus
                                  + passiveElemDamagePct(hero.activeDamageType)
                                + gemElemDamagePct(hero.activeDamageType)
                                  + inventory.totalOf(ItemStat.damagePercent)
                                  + hero.levelBonusDamagePct + guildBuffs.allDamagePct,
            abilityDamagePct:     passiveTree.totalOf(PassiveEffect.abilityDamage).toDouble(),
            subclassAbilityBonus: subclassAbilityBonus,
            endlessDmgMult:       endlessUpgrades.damageMultiplier,
            exploitMult:          _abilityExploitMult,
            comboStacks:          _comboStacks,
            bestiaryWeakMult:     _abilityWeakMult,
            isDot:                true,
            enemyResistances:     enemy.resistances,
            penetration:          _abilityPenMap(ability.penetration),
          );
          _dotDmg       = calculateDamage(bonusDotCtx, rng: _rng).total.round().clamp(1, 1000000000000000);
          _dotRoundsLeft = bonusDur;
          _dotDamageType = hero.activeDamageType;
          battleLog.add('Wound! ${enemy.name} takes $_dotDmg dmg/round for $bonusDur rounds.');
        case AbilityEffect.aura:
          _auraHealPerRound = healHp(bonusVal, 0.5);
          _auraRoundsLeft   = bonusDur;
          battleLog.add('Healing aura! ${hero.name} regenerates $_auraHealPerRound HP/round for $bonusDur rounds.');
        case AbilityEffect.stun:
          _applyStun(bonusDur, enemy.name);
        case AbilityEffect.attackBonus:
          _tempAttackBonus = max(_tempAttackBonus, bonusVal);
          _tempAttackBonusRounds = max(_tempAttackBonusRounds, bonusDur);
          battleLog.add('+$bonusVal% DMG for $bonusDur rounds.');
        case AbilityEffect.acBonus:
          _tempAcBonus = max(_tempAcBonus, bonusVal);
          _tempAcBonusRounds = max(_tempAcBonusRounds, bonusDur);
          battleLog.add('+$bonusVal% AC for $bonusDur rounds.');
        case AbilityEffect.heal:
          final bonusFatigue = pow(0.85, _healsThisBattle).toDouble();
          _healsThisBattle++;
          final hp = healHp(bonusVal, 1.0, bonusFatigue);
          hero.currentHealth = (hero.currentHealth + hp).clamp(0, hero.maxHealth);
          battleLog.add('+$hp HP restored.');
        case AbilityEffect.debuffWeaken:
          _applyEnemyWeaken(bonusVal, bonusDur, enemy.name);
        case AbilityEffect.debuffVulnerable:
          _enemyVulnerablePct    = bonusVal;
          _enemyVulnerableRounds = bonusDur;
          battleLog.add('Exposed! ${enemy.name} takes $bonusVal% more damage for $bonusDur round(s).');
        case AbilityEffect.silence:
          _applyEnemySilence(bonusDur, enemy.name);
        case AbilityEffect.absorbShield:
          _heroAbsorbShield = bonusVal;
          battleLog.add('${hero.name} gains a $bonusVal HP barrier!');
        case AbilityEffect.missChance:
          _enemyMissChancePct    = bonusVal.clamp(0, 66).toInt();
          _enemyMissChanceRounds = bonusDur;
          battleLog.add('${enemy.name} has $bonusVal% chance to miss for $bonusDur rounds.');
        case AbilityEffect.dodge:
          _dodgeNextHit = true;
          battleLog.add('${hero.name} will dodge the next attack.');
        case AbilityEffect.frozen:
          final d = _hardCcDuration(bonusDur);
          if (d <= 0) { battleLog.add('${enemy.name} resists being frozen! (DR)'); }
          else { _enemyStunRounds = d; battleLog.add('❄ ${enemy.name} is frozen for $d round(s)!'); }
        case AbilityEffect.shocked:
          final d = _hardCcDuration(bonusDur);
          if (d <= 0) { battleLog.add('${enemy.name} resists the shock! (DR)'); }
          else {
            _enemyStunRounds = d;
            _enemyVulnerablePct    = max(_enemyVulnerablePct, 25);
            _enemyVulnerableRounds = max(_enemyVulnerableRounds, d);
            battleLog.add('⚡ ${enemy.name} is shocked for $d round(s) (+25% damage taken)!');
          }
        case AbilityEffect.burning:
          final burnBase = (ref * bonusVal / 100).round().clamp(1, 1000000000000000);
          final bBurnCtx = buildAbilityAttackContext(
            baseDmg: burnBase, heroType: hero.activeDamageType,
            allDamagePct: passiveTree.totalOf(PassiveEffect.allDamage).toDouble() + ascAllDamagePct + critReplacementDamagePct + allyDmgPctBonus
                          + passiveElemDamagePct(hero.activeDamageType)
                          + gemElemDamagePct(hero.activeDamageType)
                          + inventory.totalOf(ItemStat.damagePercent)
                          + hero.levelBonusDamagePct + guildBuffs.allDamagePct,
            abilityDamagePct: passiveTree.totalOf(PassiveEffect.abilityDamage).toDouble(),
            subclassAbilityBonus: subclassAbilityBonus,
            endlessDmgMult: endlessUpgrades.damageMultiplier,
            exploitMult: _abilityExploitMult, comboStacks: _comboStacks,
            bestiaryWeakMult: _abilityWeakMult, isDot: true,
            enemyResistances: enemy.resistances,
            penetration: _abilityPenMap(ability.penetration),
          );
          final bBurnTick = calculateDamage(bBurnCtx, rng: _rng).total.round().clamp(1, 1000000000000000);
          _dotDmg = max(_dotDmg, bBurnTick);
          _dotRoundsLeft = max(_dotRoundsLeft, bonusDur);
          _dotDamageType = hero.activeDamageType;
          battleLog.add('🔥 ${enemy.name} is burning — $_dotDmg dmg/round for $bonusDur rounds.');
        case AbilityEffect.envenomed:
          final venomBase = (ref * bonusVal / 100).round().clamp(1, 1000000000000000);
          final bVenomCtx = buildAbilityAttackContext(
            baseDmg: venomBase, heroType: hero.activeDamageType,
            allDamagePct: passiveTree.totalOf(PassiveEffect.allDamage).toDouble() + ascAllDamagePct + critReplacementDamagePct + allyDmgPctBonus
                          + passiveElemDamagePct(hero.activeDamageType)
                          + gemElemDamagePct(hero.activeDamageType)
                          + inventory.totalOf(ItemStat.damagePercent)
                          + hero.levelBonusDamagePct + guildBuffs.allDamagePct,
            abilityDamagePct: passiveTree.totalOf(PassiveEffect.abilityDamage).toDouble(),
            subclassAbilityBonus: subclassAbilityBonus,
            endlessDmgMult: endlessUpgrades.damageMultiplier,
            exploitMult: _abilityExploitMult, comboStacks: _comboStacks,
            bestiaryWeakMult: _abilityWeakMult, isDot: true,
            enemyResistances: enemy.resistances,
            penetration: _abilityPenMap(ability.penetration),
          );
          final bVenomTick = calculateDamage(bVenomCtx, rng: _rng).total.round().clamp(1, 1000000000000000);
          _dotDmg = (_dotDmg + bVenomTick).clamp(1, bVenomTick * 5);
          _dotRoundsLeft = max(_dotRoundsLeft, bonusDur);
          _dotDamageType = hero.activeDamageType;
          battleLog.add('☠ ${enemy.name} is envenomed — $_dotDmg dmg/round for $bonusDur rounds.');
        case AbilityEffect.withered:
          final wp = bonusVal.clamp(0, 60);
          _enemyWeakenPct    = max(_enemyWeakenPct, wp);
          _enemyWeakenRounds = max(_enemyWeakenRounds, bonusDur);
          battleLog.add('🟣 ${enemy.name} is withered — ATK −$wp% for $bonusDur rounds.');
        default:
          break;
      }
    }

    // ── Base bonus effect (fires every cast, not gated behind milestones) ───
    if (ability.baseBonus != null) {
      final bb = ability.baseBonus!;
      final bv = ability.baseBonusValue;
      final bd = ability.baseBonusDuration;
      switch (bb) {
        case AbilityEffect.debuffVulnerable:
          _enemyVulnerablePct    = bv;
          _enemyVulnerableRounds = bd;
          battleLog.add('Exposed! ${enemy.name} takes $bv% more damage for $bd round(s).');
        case AbilityEffect.attackBonus:
          _tempAttackBonus = max(_tempAttackBonus, bv);
          _tempAttackBonusRounds = max(_tempAttackBonusRounds, bd);
          battleLog.add('+$bv% DMG for $bd rounds.');
        case AbilityEffect.stun:
          _applyStun(bd, enemy.name);
        case AbilityEffect.debuffWeaken:
          _applyEnemyWeaken(bv, bd, enemy.name);
        case AbilityEffect.acBonus:
          _tempAcBonus = max(_tempAcBonus, bv);
          _tempAcBonusRounds = max(_tempAcBonusRounds, bd);
          battleLog.add('+$bv% AC for $bd rounds.');
        case AbilityEffect.silence:
          _applyEnemySilence(bd, enemy.name);
        case AbilityEffect.absorbShield:
          _heroAbsorbShield = bv;
          battleLog.add('${hero.name} gains a $bv HP barrier!');
        case AbilityEffect.missChance:
          _enemyMissChancePct    = bv.clamp(0, 66).toInt();
          _enemyMissChanceRounds = bd;
          battleLog.add('${enemy.name} has $bv% chance to miss for $bd rounds.');
        default: break;
      }
    }

    // ── Unique legendary item extra effect ─────────────────────────────────
    if (uniqueModItem != null && uniqueModItem.abilityExtraEffect != null) {
      final xe  = uniqueModItem.abilityExtraEffect!;
      final xv  = uniqueModItem.abilityExtraValue;
      final xd  = uniqueModItem.abilityExtraDuration;
      final ref = primaryHitDmg ?? sv;
      final tag = '[${uniqueModItem.name}]';
      switch (xe) {
        case AbilityEffect.stun:
          _applyStun(xd, '$tag ${enemy.name}');
        case AbilityEffect.dot:
          final dotBase = (ref * xv / 100).round().clamp(1, 1000000000000000);
          final xDotCtx = buildAbilityAttackContext(
            baseDmg: dotBase, heroType: hero.activeDamageType,
            allDamagePct: passiveTree.totalOf(PassiveEffect.allDamage).toDouble() + ascAllDamagePct + critReplacementDamagePct + allyDmgPctBonus
                          + passiveElemDamagePct(hero.activeDamageType)
                                + gemElemDamagePct(hero.activeDamageType)
                          + inventory.totalOf(ItemStat.damagePercent)
                          + hero.levelBonusDamagePct + guildBuffs.allDamagePct,
            abilityDamagePct: passiveTree.totalOf(PassiveEffect.abilityDamage).toDouble(),
            subclassAbilityBonus: subclassAbilityBonus,
            endlessDmgMult: endlessUpgrades.damageMultiplier,
            exploitMult: _abilityExploitMult, comboStacks: _comboStacks,
            bestiaryWeakMult: _abilityWeakMult, isDot: true,
            enemyResistances: enemy.resistances,
            penetration: _abilityPenMap(ability.penetration),
          );
          _dotDmg        = calculateDamage(xDotCtx, rng: _rng).total.round().clamp(1, 1000000000000000);
          _dotRoundsLeft = xd;
          _dotDamageType = hero.activeDamageType;
          battleLog.add('$tag ${enemy.name} takes $_dotDmg dmg/round for $xd rounds.');
        case AbilityEffect.attackBonus:
          _tempAttackBonus       = max(_tempAttackBonus, xv);
          _tempAttackBonusRounds = max(_tempAttackBonusRounds, xd);
          battleLog.add('$tag +$xv% DMG for $xd rounds.');
        case AbilityEffect.acBonus:
          _tempAcBonus       = max(_tempAcBonus, xv);
          _tempAcBonusRounds = max(_tempAcBonusRounds, xd);
          battleLog.add('$tag +$xv% AC for $xd rounds.');
        case AbilityEffect.aura:
          _auraHealPerRound = healHp(xv, 0.5);
          _auraRoundsLeft   = xd;
          battleLog.add('$tag ${hero.name} regenerates $_auraHealPerRound HP/round for $xd rounds.');
        case AbilityEffect.debuffWeaken:
          _applyEnemyWeaken(xv, xd, '$tag ${enemy.name}');
        case AbilityEffect.debuffVulnerable:
          _enemyVulnerablePct    = xv;
          _enemyVulnerableRounds = xd;
          battleLog.add('$tag ${enemy.name} takes $xv% more damage for $xd rounds.');
        case AbilityEffect.dodge:
          _dodgeNextHit = true;
          battleLog.add('$tag ${hero.name} will dodge the next attack.');
        case AbilityEffect.heal:
          final xFatigue = pow(0.85, _healsThisBattle).toDouble();
          _healsThisBattle++;
          final hp = healHp(xv, 1.0, xFatigue);
          hero.currentHealth = (hero.currentHealth + hp).clamp(0, hero.maxHealth);
          battleLog.add('$tag +$hp HP restored.');
        case AbilityEffect.silence:
          _applyEnemySilence(xd, '$tag ${enemy.name}');
        case AbilityEffect.absorbShield:
          _heroAbsorbShield = xv;
          battleLog.add('$tag ${hero.name} gains a $xv HP barrier!');
        case AbilityEffect.missChance:
          _enemyMissChancePct    = xv.clamp(0, 66).toInt();
          _enemyMissChanceRounds = xd;
          battleLog.add('$tag ${enemy.name} has $xv% chance to miss for $xd rounds.');
        default:
          break;
      }
    }
  }

  // ── Endless mode ───────────────────────────────────────────────
  bool get hasEndlessEnemy => campaignStageIndex > 0;

  int get endlessStageIndex =>
      campaignStageIndex.clamp(0, EnemyData.enemies.length - 1);

  bool _isCampaignBattle      = false;
  bool _treasureGoblinActive  = false;
  bool isCampaignReplay       = false;
  int  _replayStageIndex  = -1;
  int  get replayStageIndex => _replayStageIndex;
  bool _epicStarterAwarded = false; // one-time epic drop on first run's 4th enemy

  ZoneModifier? get activeZoneModifier =>
      _isCampaignBattle ? zoneForStageIndex(campaignStageIndex).modifier : null;

  void startEndlessBattle() {
    if (campaignStageIndex == 0) return;
    _isCampaignBattle = false;
    _endlessMode = true;
    heroDefeated = false;
    lastBattleWasFinalVictory = false;
    _resetBattlePerks();
    _activeAffixes = AffixEngine.affixesFor(endlessStageIndex, _rng);
    currentEnemy = EnemyData.enemyForStage(endlessStageIndex, affixes: _activeAffixes, prestigeLevel: activeTier, heroLevel: hero.level);
    hero.healToFull();
    battleLog = ['${hero.name} faces ${currentEnemy!.name} in the endless arena!'];
    if (_activeAffixes.isNotEmpty) {
      battleLog.add('Corruption: ${_activeAffixes.map((a) => a.displayName).join(', ')}');
    }
    _setLastAction('Endless battle started against ${currentEnemy!.name}.');
  }

  bool _pvpMode = false;
  PvpSnapshot? _pvpOpponent; // captured at PvP start for the fight telemetry record

  int collectAllExpeditions() {
    int collected = 0;
    final ready = activeExpeditions.where((e) {
      final elapsed = DateTime.now().millisecondsSinceEpoch - e.startEpochMs;
      return elapsed >= e.duration.ms;
    }).toList();
    for (final e in ready) {
      collectExpedition(e.mercId);
      collected++;
    }
    return collected;
  }

  void claimAllDailies() {
    for (int i = 0; i < dailyChallenges.length; i++) {
      claimDailyChallenge(i);
    }
  }

  void startPvpBattle(PvpSnapshot opponent) {
    _isCampaignBattle = false;
    _endlessMode = false;
    _pvpMode = true;
    _pvpOpponent = opponent;   // for the fight telemetry record
    _battleTurnCount = 0;      // _resetBattlePerks doesn't clear the round counter
    heroDefeated = false;
    lastBattleWasFinalVictory = false;
    _resetBattlePerks();
    _activeAffixes = [];
    // The opponent's flat stat sum (damageMod + attackBonus) is D&D-scale and
    // can't pierce a built hero's game-scale armor — which made every PvP an
    // automatic win once the visible fight became authoritative. Give the rival
    // a game-scale hit derived from their HP budget (a proxy for build power) so
    // fights are actually contested. First-pass factor; tune from playtest data.
    final flatAtk   = opponent.damageMod + opponent.attackBonus;
    final scaledAtk = (opponent.maxHp * 0.045).round();
    currentEnemy = Enemy(
      id: 'hero_${opponent.heroClass}',
      name: opponent.heroName,
      description: 'A rival hero.',
      maxHealth: opponent.maxHp,
      attack: max(flatAtk, scaledAtk),
      level: opponent.level,
      armorClass: opponent.armorClass,
    );
    hero.healToFull();
    battleLog = ['${hero.name} faces ${opponent.heroName} in the arena!'];
    _setLastAction('PvP battle started against ${opponent.heroName}.');
  }

  void startEndlessBattleAtStage(int stage) {
    _isCampaignBattle = false;
    _endlessMode = true;
    heroDefeated = false;
    lastBattleWasFinalVictory = false;
    _resetBattlePerks();
    _activeAffixes = AffixEngine.affixesFor(stage, _rng);
    var enemy = EnemyData.enemyForStage(stage, affixes: _activeAffixes);
    // Scale like campaign bosses: 2× HP, 1.25× ATK, plus quadratic tier scaling.
    // NB: HP scaling stays on the tier mults here (NOT prestigeLevel) so it never
    // re-enters the campaign curve / frontier ramp (the double-scale that broke
    // Boss Rush). Only the LEVEL borrows the campaign per-tier step so the boss's
    // to-hit keeps pace — without it (old code = enemy.level + 2) tower bosses
    // stayed level 6-30 and literally couldn't land a hit on a high-level hero,
    // so every climb ended at 100% HP (a time-sink, not a threat).
    final hpMult = 2.0 * EnemyData.tierHpMult(activeTier);
    final atkMult = 1.25 * EnemyData.tierAtkMult(activeTier);
    final acBonus = 2 + activeTier ~/ 2;
    final bossLevel = enemy.level + 2 + activeTier * EnemyData.kTierLevelStep;
    enemy = Enemy(
      id: enemy.id,
      name: '☠ ${enemy.name}',
      description: enemy.description,
      maxHealth: (enemy.maxHealth * hpMult).round().clamp(100, 1000000000000000),
      attack: (enemy.attack * atkMult).round().clamp(10, 1000000000),
      level: bossLevel,
      armorClass: enemy.armorClass + acBonus,
      attackType: enemy.attackType,
      resistances: enemy.resistances,
    );
    currentEnemy = enemy;
    hero.healToFull();
    battleLog = ['${hero.name} challenges ${currentEnemy!.name}!'];
    _setLastAction('Boss challenge started against ${currentEnemy!.name}.');
  }

  void startCampaignReplayBattle(int stage) {
    if (!spendEnergy()) return;
    _isCampaignBattle = false;
    isCampaignReplay  = true;
    _replayStageIndex = stage;
    _endlessMode      = false;
    heroDefeated      = false;
    lastBattleWasFinalVictory = false;
    _battleTurnCount  = 0;
    _resetBattlePerks();
    _activeAffixes = AffixEngine.affixesFor(stage, _rng);
    final enemy = EnemyData.enemyForStage(stage, affixes: _activeAffixes, prestigeLevel: activeTier);
    currentEnemy = enemy;
    hero.healToFull();
    battleLog = ['${hero.name} revisits Stage ${stage + 1} — ${enemy.name}!'];
    _setLastAction('Replay battle at stage ${stage + 1}.');
  }

  SimBattleResult simulateCampaignBattles(int stageIdx, int maxCount) {
    int totalGold = 0;
    int totalXp   = 0;
    final List<EquipmentItem> drops = [];
    int simCount = 0;
    final isBoss = stageIdx % 5 == 4;
    final enemy  = EnemyData.enemyForStage(stageIdx, prestigeLevel: activeTier);

    // Pre-compute multipliers (mirrors _battleVictory)
    final arcaneBonus          = endlessUpgrades.arcaneEfficiency ? 1.40 : 1.0;
    final merchantScholarBonus = endlessUpgrades.synergyMerchantScholar ? 1.15 : 1.0;
    final passiveGoldMult      = 1.0 + (passiveTree.totalOf(PassiveEffect.goldFlat)
        + inventory.totalOf(ItemStat.goldPct)
        + _setTotal(ItemStat.goldPct)
        + _gemTotal(ItemStat.goldPct)
        + _masteryTotal(MasteryEffect.permanentGoldPct)) / 100.0;
    final goldSenseMult = _hasKeyword(ItemKeyword.goldSense) ? 1.15 : 1.0;
    final petGoldMult   = 1.0 + (petGoldPct + skinGoldPct + auraGoldPct + artifactGoldPct + runeGoldPct + traitGoldPct) / 100.0;

    final rallyCryBonus   = endlessUpgrades.rallyCry ? 1.4 : 1.0;
    final passiveXpMult   = 1.0 + (passiveTree.totalOf(PassiveEffect.xpFlat)
        + inventory.totalOf(ItemStat.xpPct)
        + _setTotal(ItemStat.xpPct)
        + _gemTotal(ItemStat.xpPct)
        + _masteryTotal(MasteryEffect.permanentXpPct)) / 100.0;
    final itemChaMult = 1.0 + inventory.totalOf(ItemStat.charisma) * 0.02;
    final petXpMult   = 1.0 + (petXpPct + skinXpPct + auraXpPct + artifactXpPct + runeXpPct + traitXpPct) / 100.0;

    for (int i = 0; i < maxCount; i++) {
      if (!spendEnergy()) break;
      simCount++;

      // Gold
      final baseGold    = ((((enemy.level - activeTier * EnemyData.kTierLevelStep).clamp(1, 9999999) * 50 + 100) * (1.0 + activeTier * 0.15)) * endlessUpgrades.goldMultiplier * arcaneBonus * merchantScholarBonus * prestigeGoldMult * paragonGoldIncomeMult * prestigeGoldBattleMult * passiveGoldMult * goldSenseMult * petGoldMult * allyGoldMult * RemoteConfigService.instance.goldMult).round();
      final bossGold    = isBoss ? (baseGold * 2).round() : 0;
      final battleGold  = baseGold + bossGold;
      totalGold += battleGold;
      gold      += battleGold;
      _totalGoldEarned += battleGold;

      // XP
      final battleXp = (((enemy.level * 20 + 40) * hero.xpMultiplier * endlessUpgrades.xpMultiplier * rallyCryBonus * prestigeXpMult * passiveXpMult * itemChaMult * petXpMult * allyXpMult * RemoteConfigService.instance.xpMult).round()).clamp(1, 1000000000000000);
      totalXp += battleXp;
      hero.gainExperience(battleXp);
      _syncParagonLevels();

      // Bestiary
      bestiaryKills[enemy.id] = (bestiaryKills[enemy.id] ?? 0) + 1;

      // Equipment drop
      final drop = ItemLootTable.tryDrop(enemy.level, _rng, tier: activeTier);
      if (drop != null) {
        drops.add(drop);
        if (autoSalvageThreshold != null && drop.rarity.index <= autoSalvageThreshold!.index) {
          disenchantItems([drop]);
        } else {
          inventory.addToBag(drop);
        }
      }
      if (isBoss) {
        final legDrop = ItemLootTable.tryDropLegendary(hero.level, _rng, tier: activeTier);
        if (legDrop != null) { drops.add(legDrop); inventory.addToBag(legDrop); }
        final setDrop = ItemLootTable.tryDropSet(hero.level, _rng, tier: activeTier);
        if (setDrop != null) { drops.add(setDrop); inventory.addToBag(setDrop); }
        final uniqueDrop = UniqueItemsData.tryDropUnique(hero.level, _rng);
        if (uniqueDrop != null) { drops.add(uniqueDrop); inventory.addToBag(uniqueDrop); }
      }
    }

    _setLastAction('Simulated $simCount × Stage ${stageIdx + 1}.');
    saveToLocal();
    return SimBattleResult(count: simCount, goldEarned: totalGold, xpEarned: totalXp, itemsDropped: drops);
  }

  void stopEndlessMode() {
    _endlessMode = false;
    if (currentEnemy != null) {
      currentEnemy = null;
      hero.healToFull();
    }
    battleLog.add('${hero.name} withdraws from the endless arena.');
    _setLastAction('Endless mode stopped.');
  }

  // ── Dungeon ────────────────────────────────────────────────────────────────

  DungeonRun? activeDungeon;

  void startDungeon({int tier = 1}) {
    // Never discard an in-progress run to start another — that silently wastes
    // the attempt already spent on it (double-tap / Auto-Run race). Only start
    // when there's no run, or the current one is finished.
    if (activeDungeon != null && !activeDungeon!.isOver) return;
    if (!consumeDungeonAttempt()) return;
    // Dungeon affixes removed — leave activeDungeonAffix null so all affix
    // effects (HP/heal mults, burn, shield, toxic) resolve to their neutral
    // defaults and no affix banner shows.
    activeDungeonAffix = null;
    activeDungeon = DungeonRun(heroMaxHp: hero.maxHealth, heroHp: hero.maxHealth, tier: tier, prestigeLevel: activeTier);
    activeDungeon!.generateRoomChoices(_rng);
    notifyListeners();
    _setLastAction('Entered the dungeon — Tier $tier, Floor 1.');
  }


  // Exposed so DungeonScreen can display the item that dropped
  EquipmentItem? dungeonLastDrop;

  /// Auto-resolves the current combat / elite / ambush / boss room. Returns gold earned.
  int resolveDungeonCombat() {
    final run = activeDungeon;
    final room = run?.currentRoom;
    if (run == null || room == null) return 0;
    final combatTypes = {
      DungeonRoomType.combat,
      DungeonRoomType.elite,
      DungeonRoomType.ambush,
      DungeonRoomType.boss,
    };
    if (!combatTypes.contains(room.type)) return 0;

    // Full hero stats — same sources as the animated fight and campaign.
    final fullAtk = hero.attackBonus
        + passiveTree.totalOf(PassiveEffect.attackFlat)
        + inventory.totalOf(ItemStat.attackBonus)
        + inventory.totalOf(ItemStat.strength)
        + petAttackBonus + skinAttackBonus
        + questAttackBonus + bestiaryChapterBonus;
    // Full hero armor RATING (incl. STR/sets/gems/artifacts/auras/mastery and
    // the merc + subclass % boosts). resolveCombat runs it through the shared
    // diminishing-returns curve, matching the campaign.
    final fullAc = heroArmorValue;
    final dmgType = hero.activeDamageType;
    final dmgMult = (1 + heroAllDamagePctFor(dmgType) / 100)
        * prestigeDamageMult; // tier + Paragon damage (1.0 when none)
    // Full combat parity: the hero's dodge rating, damage type (for enemy
    // resistance) and resistances (for incoming elemental hits).
    final heroRes = {for (final t in DamageType.values) t: heroResistancePct(t)};
    final earnedGold = run.resolveCombat(
      room,
      fullAtk,
      fullAc,
      heroFlatDmgBonus,
      _rng,
      abilities:   unlockedAbilities,
      getCooldown: scaledAbilityCooldown,
      getValue:    scaledAbilityValue,
      weaponBase:  inventory.equippedWeaponDamage,
      dmgMult:     dmgMult,
      enemyHpMult: dungeonAffixHpMult,
      extHealMult: dungeonAffixHealMult,
      burnPerRound: dungeonAffixBurnTick(run.heroMaxHp),
      enemyShield: dungeonAffixEnemyShield,
      heroDodgePct: effectiveDodgePct,
      heroDamageType: dmgType,
      heroResistances: heroRes,
    );
    room.resolved = true;
    dungeonLastDrop = null;
    if (earnedGold > 0) {
      gold += earnedGold;
      _totalGoldEarned += earnedGold;
    }
    // Shard + essence rewards from dungeon combat
    if (!run.isDead) {
      final fl = run.floor;
      final tier = run.tier;
      final shardDrop = 2 + fl + tier * 2;
      final essenceDrop = 1 + fl ~/ 2 + tier;
      shards += shardDrop;
      essence += essenceDrop;
    }
    // Boss rooms: always drop rare/epic item; elite rooms: 60% chance
    if (!run.isDead) {
      final isBoss  = room.type == DungeonRoomType.boss;
      final isElite = room.type == DungeonRoomType.elite;
      if (isBoss || (isElite && _rng.nextInt(100) < 60)) {
        final rarity = _dungeonDropRarity(run.floor, isBoss);
        final drop = ItemLootTable.craftAt(
          ItemSlot.values[_rng.nextInt(ItemSlot.values.length)],
          rarity,
          _dungeonDropLevel(run.floor),
          _rng,
          rebirthLevel: activeTier,
        );
        dungeonLastDrop = drop;
        room.hasItemDrop = true;
        inventory.addToBag(drop);
      }
      // Final boss down — dungeon cleared! Otherwise bosses offer a relic.
      if (room.type == DungeonRoomType.boss && run.floor >= DungeonRun.clearFloor) {
        run.isCleared = true;
        _grantDungeonClearBonus(run);
      } else if (room.type == DungeonRoomType.boss) {
        run.relicChoices = (DungeonRelic.pool.toList()..shuffle(_rng)).take(3).toList();
      }
    }
    if (run.isDead || run.isCleared) {
      _finishDungeon(run);
    }
    notifyListeners();
    return earnedGold;
  }

  /// Applies the outcome of the animated (watched) dungeon fight as the real
  /// result — no re-simulation. The animated combat in DungeonScreen is
  /// authoritative; this only handles rewards, drops, and death bookkeeping.
  int applyDungeonCombatOutcome({
    required bool victory,
    required int heroHpAfter,
    required int damageDealt,
    required int damageTaken,
    required int rounds,
    int ambushPreHit = 0,
    double goldMult = 1.0,
  }) {
    final run = activeDungeon;
    final room = run?.currentRoom;
    if (run == null || room == null) return 0;
    final combatTypes = {
      DungeonRoomType.combat,
      DungeonRoomType.elite,
      DungeonRoomType.ambush,
      DungeonRoomType.boss,
    };
    if (!combatTypes.contains(room.type)) return 0;

    run.heroHp = heroHpAfter.clamp(0, run.heroMaxHp);
    run.isDead = !victory;
    run.lastDamageDealt = damageDealt;
    run.lastDamageTaken = damageTaken;
    run.ambushPreHit = ambushPreHit;
    run.lastCombatSummary = victory
        ? 'Victory in $rounds rounds! Dealt $damageDealt dmg, took $damageTaken.'
        : 'Fallen after $rounds rounds. Dealt $damageDealt dmg, took $damageTaken.';
    room.resolved = true;
    dungeonLastDrop = null;

    int earnedGold = 0;
    if (victory) {
      final fl      = run.floor;
      final isBoss  = room.type == DungeonRoomType.boss;
      final isElite = room.type == DungeonRoomType.elite;
      final isAmbushRoom = room.type == DungeonRoomType.ambush;
      final baseGold = isBoss   ? 200 + fl * 80
                     : isElite  ? 100 + fl * 40
                     : isAmbushRoom ? 140 + fl * 50
                     : 80 + fl * 30;
      // Rewards scale with rebirth to match the +prestige enemy difficulty, so
      // the dungeon stays worth running at high rebirth (soft currency only).
      final rebirthMult = 1.0 + run.prestigeLevel * 0.15;
      final goblinMult = room.isGoblin ? 6.0 : 1.0;
      earnedGold = (baseGold * goblinMult * run.goldBonusMult * goldMult * rebirthMult).round();
      run.goldEarned += earnedGold;
      gold += earnedGold;
      _totalGoldEarned += earnedGold;
      run.shardsEarned += ((isBoss ? 20 + fl * 4 : 8 + fl) * rebirthMult).round();
      run.bones += isBoss ? 3 : isElite ? 2 : 1; // slain enemy drops Bones
      run.roomsCleared++;
      if (isBoss) run.bossesDefeated++;

      final shardDrop   = ((2 + fl + run.tier * 2) * rebirthMult).round();
      final essenceDrop = ((1 + fl ~/ 2 + run.tier) * rebirthMult).round();
      shards  += shardDrop;
      essence += essenceDrop;

      // Boss rooms: always drop rare/epic item; elite rooms: 60% chance
      if (isBoss || (isElite && _rng.nextInt(100) < 60)) {
        final rarity = _dungeonDropRarity(run.floor, isBoss);
        final drop = ItemLootTable.craftAt(
          ItemSlot.values[_rng.nextInt(ItemSlot.values.length)],
          rarity,
          _dungeonDropLevel(run.floor),
          _rng,
          rebirthLevel: activeTier,
        );
        dungeonLastDrop = drop;
        room.hasItemDrop = true;
        inventory.addToBag(drop);
      }

      // Final boss down — dungeon cleared! Otherwise bosses offer a relic.
      if (isBoss && run.floor >= DungeonRun.clearFloor) {
        run.isCleared = true;
        _grantDungeonClearBonus(run);
        _finishDungeon(run);
      } else if (isBoss) {
        run.relicChoices = (DungeonRelic.pool.toList()..shuffle(_rng)).take(3).toList();
      }
    } else {
      _finishDungeon(run);
    }
    notifyListeners();
    return earnedGold;
  }

  /// The treasure goblin escaped — room resolves with no reward.
  void applyDungeonGoblinEscape() {
    final run = activeDungeon;
    final room = run?.currentRoom;
    if (run == null || room == null || !room.isGoblin) return;
    room.goblinEscaped = true;
    room.resolved = true;
    run.roomsCleared++;
    run.lastCombatSummary = 'The goblin vanished with its hoard!';
    notifyListeners();
  }

  /// Claims one of the relics offered after a boss kill.
  void chooseDungeonRelic(DungeonRelic relic) {
    final run = activeDungeon;
    if (run == null || !run.relicChoices.contains(relic)) return;
    run.relicChoices = [];
    run.relicsTaken.add(relic);
    if (relic.effect != null) run.shrineEffects.add(relic.effect!);
    if (relic.instantGoldBase > 0) {
      final g = relic.instantGoldBase + run.floor * 40;
      gold += g;
      _totalGoldEarned += g;
      run.goldEarned += g;
    }
    if (relic.instantHealPct > 0) {
      final heal = (run.heroMaxHp * relic.instantHealPct).round();
      run.heroHp = (run.heroHp + heal).clamp(0, run.heroMaxHp);
    }
    if (relic.grantsItem) {
      final drop = ItemLootTable.craftAt(
        ItemSlot.values[_rng.nextInt(ItemSlot.values.length)],
        _dungeonDropRarity(run.floor, false),
        _dungeonDropLevel(run.floor),
        _rng,
        rebirthLevel: activeTier,
      );
      dungeonLastDrop = drop;
      inventory.addToBag(drop);
    }
    if (relic.bonesGranted > 0) run.bones += relic.bonesGranted;
    _setLastAction('Relic claimed: ${relic.name}');
    notifyListeners();
    saveToLocal();
  }

  /// Skip the relic reward and continue the run (fail-safe so a boss reward can
  /// never leave the player stuck).
  void skipDungeonRelic() {
    final run = activeDungeon;
    if (run == null) return;
    run.relicChoices = [];
    notifyListeners();
    saveToLocal();
  }

  /// Floor-scaled rarity: deeper floors roll better loot. Legendary opens up
  /// past floor 15; epic chance climbs ~1%/floor.
  ItemRarity _dungeonDropRarity(int floor, bool isBoss) {
    final legendaryPct = floor >= 15 ? (floor - 14) * 2 + (isBoss ? 5 : 0) : 0;
    if (legendaryPct > 0 && _rng.nextInt(100) < legendaryPct) return ItemRarity.legendary;
    final epicPct = ((isBoss ? 30 : 15) + floor).clamp(0, 65);
    return _rng.nextInt(100) < epicPct ? ItemRarity.epic : ItemRarity.rare;
  }

  /// Item level scales with dungeon depth (+1 per 5 floors).
  int _dungeonDropLevel(int floor) => hero.level + floor ~/ 5;

  /// Clear bonus for beating the floor-20 Dungeon Lord.
  void _grantDungeonClearBonus(DungeonRun run) {
    final t = run.tier;
    mythril += 5;
    zcoins  += 2 * t;
    final bonusGold = (500 * t * (1.0 + run.prestigeLevel * 0.15)).round();
    gold += bonusGold;
    _totalGoldEarned += bonusGold;
    run.goldEarned += bonusGold;
    final rarity = t >= 3 ? ItemRarity.legendary : ItemRarity.epic;
    final drop = ItemLootTable.craftAt(
      ItemSlot.values[_rng.nextInt(ItemSlot.values.length)],
      rarity,
      hero.level,
      _rng,
      rebirthLevel: activeTier,
    );
    dungeonLastDrop = drop;
    inventory.addToBag(drop);
    _setLastAction('DUNGEON CLEARED! +5 mythril  +${2 * t} Z-Coins  +$bonusGold gold  +${drop.name}');
  }

  /// Opens a locked-chest room; deducts shards. Returns the item dropped or null.
  EquipmentItem? openDungeonChest() {
    final run = activeDungeon;
    final room = run?.currentRoom;
    if (run == null || room == null || room.type != DungeonRoomType.lockedChest) return null;
    final cost = room.chestShardCost ?? 30;
    if (shards < cost) return null;
    final opened = run.openChest(room, shards);
    if (!opened) return null;
    shards -= cost;
    final rarity = _dungeonDropRarity(run.floor, false);
    final drop = ItemLootTable.craftAt(
      ItemSlot.values[_rng.nextInt(ItemSlot.values.length)],
      rarity,
      _dungeonDropLevel(run.floor),
      _rng,
      rebirthLevel: activeTier,
    );
    dungeonLastDrop = drop;
    inventory.addToBag(drop);
    room.resolved = true;
    notifyListeners();
    return drop;
  }

  static const int chestCrystalCost = 10;

  EquipmentItem? openDungeonChestWithCrystals() {
    final run = activeDungeon;
    final room = run?.currentRoom;
    if (run == null || room == null || room.type != DungeonRoomType.lockedChest) return null;
    if (zcoins < chestCrystalCost) return null;
    final opened = run.openChest(room, 9999);
    if (!opened) return null;
    zcoins -= chestCrystalCost;
    final rarity = _dungeonDropRarity(run.floor, false);
    final drop = ItemLootTable.craftAt(
      ItemSlot.values[_rng.nextInt(ItemSlot.values.length)],
      rarity,
      _dungeonDropLevel(run.floor),
      _rng,
      rebirthLevel: activeTier,
    );
    dungeonLastDrop = drop;
    inventory.addToBag(drop);
    room.resolved = true;
    notifyListeners();
    return drop;
  }

  void resolveDungeonTrap() {
    final run = activeDungeon;
    final room = run?.currentRoom;
    if (run == null || room == null || room.type != DungeonRoomType.trap) return;
    run.resolveTrap(room);
    room.resolved = true;
    if (run.isDead) _finishDungeon(run);
    notifyListeners();
  }

  void resolveDungeonRestSite() {
    final run = activeDungeon;
    final room = run?.currentRoom;
    if (run == null || room == null || room.type != DungeonRoomType.restSite) return;
    run.resolveRestSite(room);
    room.resolved = true;
    notifyListeners();
  }

  void collectDungeonTreasure() {
    final run = activeDungeon;
    final room = run?.currentRoom;
    if (run == null || room == null || room.type != DungeonRoomType.treasure) return;
    run.collectTreasure(room);
    room.resolved = true;
    gold   += room.treasureGold   ?? 0;
    shards += room.treasureShards ?? 0;
    if (room.treasureGold != null)   _totalGoldEarned += room.treasureGold!;
    notifyListeners();
  }

  void chooseDungeonBlessing(DungeonBlessingType blessing) {
    final run = activeDungeon;
    final room = run?.currentRoom;
    if (run == null || room == null || room.type != DungeonRoomType.shrine) return;
    run.chooseBlessing(blessing);
    room.resolved = true;
    notifyListeners();
  }


  void chooseDungeonRoom(DungeonRoom room) {
    final run = activeDungeon;
    if (run == null || run.currentRoom != null) return;
    run.chooseRoom(room);
    notifyListeners();
  }

  void advanceDungeonFloor() {
    final run = activeDungeon;
    if (run == null || run.isOver) return;
    run.floor++;
    applyDungeonToxicTick(run);
    run.generateRoomChoices(_rng);
    _setLastAction('Dungeon — Floor ${run.floor}.');
  }

  void abandonDungeon() {
    final run = activeDungeon;
    if (run == null) return;
    run.isAbandoned = true;
    _finishDungeon(run);
    notifyListeners();
  }

  void _finishDungeon(DungeonRun run) {
    // Balance telemetry (adb logcat -d | grep ZBAL) — run-level, since the
    // dungeon resolves per-room in the animated screen.
    try {
      DebugLogger.balance(jsonEncode({
        'mode': 'dungeon', 'tier': run.tier,
        'win': run.isCleared, 'dead': run.isDead, 'abandoned': run.isAbandoned,
        'floor': run.floor, 'rooms': run.roomsCleared, 'bosses': run.bossesDefeated,
        'h_lvl': hero.level, 'h_hp': run.heroMaxHp, 'h_hp_end': run.heroHp,
        'h_hp_pct': run.heroMaxHp > 0 ? (run.heroHp * 100 / run.heroMaxHp).round() : 0,
        'gold': run.goldEarned,
      }));
    } catch (_) {/* telemetry must never break a run */}

    if (run.floor > _deepestDungeonFloor) {
      _deepestDungeonFloor = run.floor;
    }
    // Tier clear: only a FULL run-through — beating the floor-20 Dungeon Lord
    // (run.isCleared) — counts. Dying partway, even after killing earlier
    // bosses, does NOT mark the tier cleared or unlock the next one.
    if (run.isCleared && run.tier > _dungeonHighestTier) {
      _dungeonHighestTier = run.tier;
      // Update the Dungeon leaderboard (fire-and-forget, personal-best only).
      LeaderboardService.submitScore(
        board:     LeaderboardBoard.dungeon,
        heroName:  hero.name,
        heroClass: hero.heroClass.displayName,
        subclass:  subclassName,
        spriteId:  heroBattleSpriteId,
        rebirths:  leaderboardRebirths,
        stage:     _dungeonHighestTier,
        title:       activeTitle,
        nameColorId: activeNameColor,
        frameId:     activeFrame,
        level:       hero.level,
        ascensionAp: totalAscensionAp,
      );
    }
    // Mythril: 1 per 2 floors completed
    final mythrilEarned = (run.floor / 2).floor().clamp(0, 10);
    if (mythrilEarned > 0) mythril += mythrilEarned;
    if (run.floor > 0 && !run.isAbandoned) {
      _dungeonClears++;
      advanceWeekly('w_dungeon', 1);
      _trackBountyProgress(BountyType.completeDungeon, 1);
      checkAllyMilestones();
      // Artifact drop: 1 per boss defeated (up to 2)
      if (run.bossesDefeated >= 1) {
        final artLv = (run.tier * 10).clamp(1, 50);
        for (var i = 0; i < run.bossesDefeated.clamp(1, 2); i++) {
          gainArtifact(artLv);
        }
      }
    }
    saveToLocal();
  }

  Future<void> loadSlot(int slot,
      {String? newName, DndClass? heroClass, HeroRace? heroRace, HeroTrait? trait, HeroGender? gender}) async {
    _currentSlot = slot;
    _saveBlocked = false; // cleared unless this load hits a parse failure
    extraCharacterSlots = await SaveService.getExtraSlots();
    final raw = await saveService.loadRaw(slot: slot);
    final isNewCharacter = newName != null;
    if (isNewCharacter) {
      // Always reset to defaults for new characters — ignore any stale slot data.
      // Drop the high-water-mark too, so a deliberately fresh low-level hero is
      // never mistaken for a wiped one and "recovered" back to the old character.
      await saveService.clearHighWaterMark(slot: slot);
      _resetToDefaults(newName, heroClass ?? DndClass.fighter);
      if (heroRace != null) this.heroRace = heroRace;
      if (gender != null) hero.gender = gender;
      if (trait != null) _applyTrait(trait);
    } else if (raw != null) {
      try {
        loadFromJson(raw);
      } catch (e, st) {
        // Save exists but failed to parse (e.g. a field format changed across
        // versions). Show defaults for this session, but BLOCK auto-save so we
        // never overwrite the real save on disk — otherwise a load bug becomes
        // permanent character loss. A future/fixed version can still load it.
        // Emit to logcat (release-visible, like ZBAL) so the exact failing field
        // is diagnosable off-device via `adb logcat -d | grep ZLOADFAIL`.
        // ignore: avoid_print
        print('ZLOADFAIL|slot=$slot|$e|$st');
        debugPrint('⚠ loadFromJson failed (slot $slot): $e — save preserved, auto-save blocked');
        DebugLogger.log('save_parse_fail', 'slot=$slot err=$e');
        _resetToDefaults('The Warden', DndClass.fighter);
        _saveBlocked = true;
      }
    } else {
      _resetToDefaults('The Warden', DndClass.fighter);
    }
    // If Google-signed-in, check if cloud save is newer and load it automatically.
    // Wrapped in try-catch so any Firebase error (e.g. SDK not configured yet)
    // never blocks character creation from completing.
    // Skip cloud load when creating a brand-new character.
    try {
      if (!isNewCharacter && authService.isGoogleSignedIn) {
        final uid = authService.currentUser!.uid;
        final cloudTs = await cloudSaveService.fetchLastSyncTime(uid, slot);
        if (cloudTs != null) {
          final localTs = raw == null ? null : _parseLocalTimestamp(raw);
          if (localTs == null || cloudTs.isAfter(localTs)) {
            final cloudRaw = await cloudSaveService.fetchSave(uid, slot);
            if (cloudRaw != null) {
              loadFromJson(cloudRaw);
              _setLastAction('Loaded from cloud save.');
            }
          }
        }
      }
    } catch (_) {
      // Cloud sync is non-critical — local save always wins if cloud fails.
    }
    // Wipe guard: hero level only ever rises in normal play, so if a much
    // higher-level save is banked for this slot than what we just loaded
    // (local OR cloud), a reset/parse-glitch must have clobbered the real
    // character — restore the banked maxed copy. Skipped for brand-new
    // characters (their HWM was just cleared) and when the load was blocked.
    if (!isNewCharacter && !_saveBlocked) {
      try {
        final hwm = await saveService.loadHighWaterMark(slot: slot);
        if (hwm.data != null && hwm.level > hero.level + 10) {
          final lostLvl = hero.level;
          loadFromJson(hwm.data!); // hwm was written by a successful toJson
          await saveService.saveRaw(toJson(), slot: slot); // re-establish primary
          characterRecoveredFromBackup = true;
          _setLastAction('Recovered your Lv${hero.level} character from backup.');
          DebugLogger.log('save_recover',
              'slot=$slot restored Lv${hero.level} over Lv$lostLvl');
        }
      } catch (e) {
        // HWM itself won't parse — leave the already-loaded save intact.
        DebugLogger.log('save_recover_fail', 'slot=$slot err=$e');
        if (raw != null) {
          try { loadFromJson(raw); } catch (_) {}
        }
      }
    }
    _checkSeasonReset();
    _checkWeeklyReset();
    _checkComebackBonus();
    _checkFlashEvent();
    // Sync confirmed level from the dedicated key in case a prior prestige
    // wrote a higher value than what ended up in the JSON save.
    final directPl = await saveService.loadPrestigeLevel(slot);
    _confirmedPrestigeLevel = prestigeLevel > directPl ? prestigeLevel : directPl;
    if (_confirmedPrestigeLevel > prestigeLevel) {
      prestigeLevel = _confirmedPrestigeLevel;
    }
    _slotLoaded = true;
    // Account-wide entitlements: merge the shared store into this character so
    // subscriptions and paid cosmetics/pets are present regardless of which slot
    // bought them, then write back so this slot's own purchases migrate in.
    await applyAccountEntitlements();
    persistEntitlements();
    // Re-apply active subscriptions / non-consumables now that the slot is
    // loaded, so a purchase whose live event was missed (or a reinstall) still
    // activates. Runs after load so it can't be overwritten by the loaded save.
    _iapService.restorePurchases();
    startPlaytimeTracking(); // begin the play-session clock (loadSlot never did)
    checkLoginStreak();
    notifyListeners();
  }

  DateTime? _parseLocalTimestamp(Map<String, dynamic> raw) {
    final v = raw['_savedAt'];
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  void _applyTrait(HeroTrait trait) {
    heroTrait = trait;
    _syncHeroHpPct();
    hero.currentHealth = hero.maxHealth;
  }

  void _syncHeroHpPct() {
    // Item maxHpPct stat (unique items, armor prefixes)
    final itemHpPct = inventory.totalOf(ItemStat.maxHpPct)
        + _setTotal(ItemStat.maxHpPct)
        + _gemTotal(ItemStat.maxHpPct);
    // Passive tree maxHp nodes
    final passiveHpPct = passiveTree.totalOf(PassiveEffect.maxHp);
    hero.extraHpPct = subclassHpPct + traitHpPct + artifactHpPct + runeHpPct + allyHpPct
        + prestigeHpPct + itemHpPct + passiveHpPct
        + abilityScoreRank('agi') * 2; // Endurance ability score: +2% max HP / rank
    hero.flatHpBonus = abilityScoreRank('vit') * 30;
    hero.currentHealth = hero.currentHealth.clamp(1, hero.maxHealth);
  }

  void _resetToDefaults(String name, DndClass heroClass, {bool keepTutorials = false}) {
    final info = heroClass.info;
    hero.loadFromJson({
      'name': name,
      'heroClass': heroClass.name,
      'level': 1,
      'experience': 0,
      'experienceToNextLevel': 100,
      'strength': info.str,
      'dexterity': info.dex,
      'constitution': info.con,
      'intelligence': info.intelligence,
      'wisdom': info.wis,
      'charisma': info.cha,
    });
    hero.currentHealth = hero.maxHealth;
    gold = 250 + prestigeStartGold;
    shards = 0;
    echoes = 0;
    idleProgress = 0;
    // A genuinely-new character ALWAYS starts at Stage 1 (index 0). Only rebirth/
    // ascension (keepTutorials) may apply a head-start — and note prestigeHeadStart
    // here reads the still-current prestigeShop (reset happens further below), so
    // for a new character it would otherwise inherit the PREVIOUS character's
    // soul_overdrive node and wrongly start at Stage 41.
    campaignStageIndex = keepTutorials ? prestigeHeadStart : 0;
    _campaignStageByTier.clear(); // per-tier progress starts fresh
    currentEnemy = null;
    battleLog = ['$name the ${heroClass.displayName} awakens in the cursed realm.'];
    lastAction = 'Ready to battle';
    upgrades
      ..clear()
      ..addAll(List<Upgrade>.from(GameData.upgrades));
    // Daily rewards, streaks and attempt limits are calendar-day scoped — reset
    // them only for a genuinely new character, NEVER on rebirth/ascension
    // (keepTutorials == true), which previously wiped the player's dailies.
    if (!keepTutorials) {
    dailyChallenges
      ..clear()
      ..addAll(DailyChallengeGenerator.generateForDate(DateTime.now()));
    _lastDailyDate     = _effectiveDateKey();
    _towerBossesDefeatedToday.clear();
    _dailyKills        = 0;
    _dailyBattleWins   = 0;
    _dailyIdleCollects = 0;
    _dailyAbilityUses  = 0;
    _dailyDamageDealt  = 0;
    _dailyBossKills    = 0;
    _dailyItemEquipped = false;
    dailyChestClaimed  = false;
    _dungeonAttemptsUsed  = 0;
    _gauntletAttemptsUsed = 0;
    _bossRushAttemptsUsed = 0;
    _pvpRefillsBought     = 0;
    pvpDailyWins          = 0;
    pvpDailyDamage        = 0;
    pvpDailyRewardClaimed = false;
    }
    // Echoes Upgrades are permanent per character (bought with Gauntlet Echoes),
    // so they survive rebirth/ascension — only a brand-new character wipes them.
    if (!keepTutorials) endlessUpgrades.reset();
    subclassId = null;
    // Reset tutorials only for a genuinely new character. On rebirth/ascension
    // the player has already done the tutorial playthrough, so keep them off.
    if (!keepTutorials) {
      tutorialWelcomeSeen   = false;
      tutorialBattleSeen    = false;
      tutorialIdleSeen      = false;
      tutorialUpgradeSeen   = false;
      tutorialCampaignSeen  = false;
      tutorialDungeonSeen   = false;
      tutorialGearSeen      = false;
      tutorialForgeSeen     = false;
      tutorialRunesSeen     = false;
      tutorialArtifactsSeen = false;
    }
    _deepestDungeonFloor = 0;
    _dungeonHighestTier  = 0;
    activeDungeon        = null;
    // Reset prestige on full wipe
    prestigeLevel = 0;
    activeTier = 0;
    highestUnlockedTier = 0;
    _paragonLevelsGranted = 0;
    prestigeSouls = 0;
    prestigeShop.reset();
    passiveTree.reset();
    passiveTree.setElementalistNodes(heroClass.info.classElement, heroClass.info.secondaryElement);
    achievements.clear();
    achievements.addAll(buildAchievements());
    _totalKills        = 0;
    _totalBattleWins   = 0;
    _totalBossKills    = 0;
    _totalDamageDealt  = 0;
    _totalGoldEarned   = 0;
    _totalIdleCollects = 0;
    _totalForges       = 0;
    _totalDisenchants  = 0;
    _survivedAt1HP     = false;
    zcoins           = 0;
    equippedAuraId     = null;
    equippedSkinId     = null;
    equippedPremiumSkinId = null;
    equippedPetId      = null;
    ownedAuraIds.clear();
    ownedSkinIds.clear();
    ownedPremiumSkinIds.clear();
    ownedPetIds.clear();
    pvpStamina        = pvpMaxStamina;
    _pvpRefillEpochMs = 0;
    pvpRating         = 1000;
    pvpWins           = 0;
    pvpLosses         = 0;
    inventory.loadFromJson({'equipped': {}, 'bag': []});
    essence          = 0;
    gemShards        = 0;
    bagTabsPurchased = 0;
    inventory.bagCapacity = totalBagCapacity;
    gemBag.clear();
    _activeExpeditions.clear();
    masteryLevels.clear();
    abilityBranches.clear();
    _milestoneChoices.clear();
    questsClaimed.clear();
    // These collections are cleared by loadFromJson but were previously missed
    // here, so a NEW character inherited them from the prior in-memory hero
    // (e.g. ability-score "power" ranks, seen-unlock notices). Keep this list in
    // sync with loadFromJson's clears.
    _abilityScoreRanks.clear();
    _abilityRanks.clear();
    _abilityAscension.clear(); // prestige()/ascend() save+restore this permanent track
    _seenUnlockStages.clear();
    ownedRunes.clear();
    purchasedPacks.clear();
    ownedCosmetics.clear();
    _claimedBestiaryChapters.clear();
    _claimedBestiaryMilestones.clear();
    heroTitle = null;
    _totalAbilityUses = 0;
    heroRace  = null;
    heroTrait = null;
    hero.extraHpPct = 0;
    activeModifierId = null;
    bestiaryKills.clear();
    bossRushBestScore   = 0;
    bossRushHighestTier = 0;
    basicWaystoneCount  = 0;
    grandWaystoneCount = 0;
    waystoneExpiresAtMs = 0;
    _activeWaystoneMult = 1.0;
    petEvolutionLevels.clear();
    ownedAttackEffects.clear();
    equippedAttackEffectId = null;
    mythril = 0;
    ownedArtifacts.clear();
    artifactGrid.clear();
    _unlockedArtifactCells = 9;
    _dailyBounties = [];
    _bountyDaySeed = 0;
    _refreshBountiesIfNeeded();
    // World Event
    eventTokens = 0;
    _eventWeekSeed = 0;
    _eventRewardsClaimed.clear();
    // Gauntlet
    gauntletHighScore = 0;
    // NPC Allies
    _allyLevels.clear();
    _allyTalents.clear();
    _dungeonClears      = 0;
    _bossRushClears     = 0;
    _dungeonHighestTier = 0;
    // Runes — dust merged into Gem Shards (Arcane Dust), which survives rebirth.
    _runeStockpile.clear();
    _activeRunes[RuneSlot.weapon]   = null;
    _activeRunes[RuneSlot.armor]    = null;
    _activeRunes[RuneSlot.talisman] = null;
    // Login streak is calendar-based — it persists through rebirth/ascension.
    // Only a genuinely new character resets it.
    if (!keepTutorials) {
      loginStreak = 0;
      loginTodayClaimed = false;
      _lastLoginDate = '';
    }
    // Ascension resets on full new-character wipe (prestige()/ascend() save +
    // restore these so a rebirth/ascension keeps them).
    ascensionLevel  = 0;
    ascensionPoints = 0;
    _ascensionNodes.clear();
    totalAscensionAp = 0;
    // Rebirth challenge/boon — reset each run
    activeRebirthChallenge = RebirthChallenge.none;
    _boonXpMult        = 1.0;
    _challengeGoldMult = 1.0;
    _challengeHpPenalty = 0;
  }

  Timer? _autoSaveTimer;
  Timer? _idleTimer;
  int    _idleTickCount = 0;

  DateTime? _lastCloudSyncAt;

  final SaveService saveService;
  final CloudSaveService cloudSaveService;
  final AuthService authService;
  final AudioService audioService;
  final SteamService steamService = SteamService();
  late final IapService _iapService;
  IapService get iapService => _iapService;
  final HeroModel hero;
  int gold;
  int idleProgress;
  int campaignStageIndex;
  // Per-tier campaign progress. Each difficulty tier remembers its own stage,
  // so switching tiers resumes where you left off and unlocking a new tier only
  // resets THAT tier — never the one you just cleared. Keyed by 0-based tier;
  // the active tier's live value is [campaignStageIndex].
  Map<int, int> _campaignStageByTier = {};
  int campaignAllTimeHigh = 0; // never reset by prestige — used for mode unlocks
  Enemy? currentEnemy;
  List<String> battleLog;
  String lastAction;
  final List<Upgrade> upgrades;
  final List<DailyChallenge> dailyChallenges;
  bool dailyChestClaimed = false;

  // True from the moment the first campaign enemy is defeated until the
  // player acknowledges the tutorial popup. Persisted so it survives restarts.
  bool endlessTutorialPending = false;
  Set<String> visitedModeTabs = {'CAMPAIGN'};

  // ── Campaign story tracking ────────────────────────────────────────────────
  Set<int>    seenZoneIntros  = {};  // zone indices (0-based) whose entry card was shown
  Set<String> seenBossIntros  = {};  // boss IDs whose pre-fight intro was shown
  Set<String> seenBossDefeats = {};  // boss IDs whose defeat message was shown
  String?     pendingBossDefeatMessage; // set after first boss kill, cleared by UI

  void markZoneIntroSeen(int zoneIndex)  { seenZoneIntros.add(zoneIndex);  saveToLocal(); }
  void markBossIntroSeen(String bossId)  { seenBossIntros.add(bossId);     saveToLocal(); }
  void markBossDefeatSeen(String bossId) {
    seenBossDefeats.add(bossId);
    pendingBossDefeatMessage = null;
    saveToLocal();
  }

  void dismissEndlessTutorial() {
    endlessTutorialPending = false;
    notifyListeners();
    saveToLocal();
  }

  bool get dailyChestAvailable =>
      dailyChallenges.length == 7 &&
      dailyChallenges.every((c) => c.claimed) &&
      !dailyChestClaimed;

  void claimDailyChest() {
    if (!dailyChestAvailable) return;
    HapticFeedback.heavyImpact();
    dailyChestClaimed = true;
    gold     += 1000;
    shards   += 75;
    essence  += 50;
    zcoins += 50;
    _setLastAction('Daily Chest claimed! +1000g +75◆ +50 essence +50 zcoins');
    notifyListeners();
    saveToLocal();
  }

  int            lastRewardGold    = 0;
  int            lastRewardExp     = 0;
  int            lastShardDrop     = 0;
  int            lastRewardEssence = 0;
  LevelUpEvent?  lastLevelUp;
  int lastIdleGold    = 0;
  int lastIdleEssence = 0;
  int lastIdleXp      = 0;

  int lastHeroDamage  = 0;
  bool lastHeroCrit   = false;
  int lastEnemyDamage = 0;
  DamageType lastHeroDamageType  = DamageType.physical;

  // Rolling window of the hero's recent actual hits — powers the "avg hit"
  // stat shown on the battle HUD. Faithful by construction (real damage rolls),
  // and stays current as gear/build changes because we only keep the last 12.
  final List<int> _recentHeroHits = [];
  void _recordHeroHit(int dmg) {
    _recentHeroHits.add(dmg);
    if (_recentHeroHits.length > 12) _recentHeroHits.removeAt(0);
    _recordFightDamage(dmg);
  }

  /// Records any hero-dealt damage instance (auto-attack, ability, DoT, thorns,
  /// ally burst) toward the post-fight summary total/max/avg.
  void _recordFightDamage(int dmg) {
    if (dmg <= 0) return;
    _fightDamage += dmg;
    _fightHits++;
    if (dmg > _fightMaxHit) _fightMaxHit = dmg;
  }

  // ── Per-fight stats → FightSummary (post-fight breakdown) ────────────────────
  int _fightDamage = 0;
  int _fightMaxHit = 0;
  int _fightHits   = 0;
  // Diagnostics: lowest HP the hero reached, and total damage they took, this
  // fight — disambiguates "never got hit" (min≈100%, taken≈0) from "healed it
  // all back" (min low, taken high, end 100%).
  int _fightLowestHp = 1 << 62;
  int _fightDmgTaken = 0;
  final Map<String, int> _fightAbilities = {};
  FightSummary? lastFightSummary;

  /// Call after any enemy damage lands on the hero — tracks lowest HP + total taken.
  void _noteHeroDamageTaken(int dmg) {
    if (dmg > 0) _fightDmgTaken += dmg;
    if (hero.currentHealth < _fightLowestHp) _fightLowestHp = hero.currentHealth;
  }

  void _resetFightStats() {
    _fightDamage = 0;
    _fightMaxHit = 0;
    _fightHits   = 0;
    _fightLowestHp = 1 << 62;
    _fightDmgTaken = 0;
    _fightAbilities.clear();
  }

  void _snapshotFight({required String enemyName, required bool victory, Enemy? enemy}) {
    lastFightSummary = FightSummary(
      enemyName: enemyName,
      victory: victory,
      totalDamage: _fightDamage,
      maxHit: _fightMaxHit,
      hitCount: _fightHits,
      rounds: _battleTurnCount,
      abilitiesUsed: Map<String, int>.from(_fightAbilities),
      log: List<String>.from(battleLog),
    );
    _logBalanceTelemetry(enemy, victory);
    _logPowerBreakdown();
  }

  /// Emits a per-fight power-source breakdown (ZPWR) itemising how much each
  /// progression system contributes to the hero's HP%, damage% , flat damage and
  /// armor. This is the tool for "are all my systems actually adding to the
  /// total?" — any source reading 0 is either not built up yet or not wired in.
  void _logPowerBreakdown() {
    try {
      final t = hero.activeDamageType;
      num r2(num v) => (v is double) ? (v * 100).round() / 100 : v;
      final rec = <String, dynamic>{
        'h_lvl': hero.level,
        'h_hp':  hero.maxHealth,
        'type':  t.name,
        // Max-HP: % multipliers by system (all stack additively into extraHpPct),
        // plus CON (1%/pt) and flat HP.
        'hp_pct': {
          'con':       hero.constitution,
          'items':     inventory.totalOf(ItemStat.maxHpPct) + _setTotal(ItemStat.maxHpPct) + _gemTotal(ItemStat.maxHpPct),
          'passives':  passiveTree.totalOf(PassiveEffect.maxHp),
          'subclass':  subclassHpPct,
          'trait':     traitHpPct,
          'artifact':  artifactHpPct,
          'rune':      runeHpPct,
          'mercs':     allyHpPct,
          'prestige':  prestigeHpPct,
          'endurance': abilityScoreRank('agi') * 2,
        },
        'hp_flat': {'vit': abilityScoreRank('vit') * 30},
        // Damage%: additive % into the pipeline, plus the Paragon/tier multiplier.
        'dmg_pct': {
          'passives':    r2(passiveTree.totalOf(PassiveEffect.allDamage)),
          'gear':        inventory.totalOf(ItemStat.damagePercent),
          'sets':        _setTotal(ItemStat.damagePercent),
          'stat':        attrDamagePctFor(t),
          'elemPassive': r2(passiveElemDamagePct(t)),
          'elemGem':     r2(gemElemDamagePct(t)),
          'elemMastery': r2(elementalMasteryDamagePct(t)),
          'ascension':   r2(ascAllDamagePct),
          'mercs':       allyDmgPctBonus,
          'critReplace': r2(critReplacementDamagePct),
          'paragonMult': r2(prestigeDamageMult),
          'upgradeMult': r2(endlessUpgrades.damageMultiplier),
        },
        // Flat damage added to every base hit.
        'dmg_flat': {
          'gear':    inventory.totalOf(ItemStat.damageBonus) + _setTotal(ItemStat.damageBonus) + _gemTotal(ItemStat.damageBonus),
          'str':     inventory.totalOf(ItemStat.strength) + _setTotal(ItemStat.strength) + _gemTotal(ItemStat.strength),
          'mastery': _masteryTotal(MasteryEffect.flatDamagePerHit) + _masteryTotal(MasteryEffect.permanentDamage),
          'quest':   questDamageBonus,
          'artifact':artifactPowerBonus,
          'rune':    runeDmgBonus,
          'score':   _scorePwr,
          'pets':    petDamage,
        },
        // Armor (physical damage reduction rating).
        'armor': {
          'base':     hero.armorClass,
          'passives': passiveTree.totalOf(PassiveEffect.armorFlat),
          'gear':     inventory.totalOf(ItemStat.armorClass) + inventory.totalOf(ItemStat.strength) + _setTotal(ItemStat.armorClass) + _gemTotal(ItemStat.armorClass),
          'pets':     petArmor,
          'skin':     skinArmor,
          'aura':     auraArmor,
          'artifact': artifactAcBonus,
          'rune':     runeAcBonus,
          'mercs':    allyAcBonus,
          'mastery':  _masteryTotal(MasteryEffect.permanentAC),
          'quest':    questACBonus,
        },
        // Heal Rating (all healing = value/9 × this). 'flat' is pre-% base.
        'heal': {
          'rating':   healRating,
          'flat':     healRatingFlat,
          'gear':     inventory.totalOf(ItemStat.healRating) + _setTotal(ItemStat.healRating) + _gemTotal(ItemStat.healRating),
          'passives': passiveTree.totalOf(PassiveEffect.healRatingFlat),
          'pct':      healBoostRatingPct.round(),
          'paragon':  r2(paragonHealMult),
        },
      };
      DebugLogger.power(jsonEncode(rec));
    } catch (_) {/* telemetry must never break a battle */}
  }

  /// Emits one compact JSON line per resolved fight for off-device balance
  /// analysis (see DebugLogger.balance). Everything needed to judge a fight's
  /// difficulty: who fought whom, enemy vs hero stats, how long it took, and how
  /// close it was (hero HP % remaining — the key "was this dangerous" signal).
  void _logBalanceTelemetry(Enemy? enemy, bool victory) {
    try {
      final maxHp = hero.maxHealth;
      final rec = <String, dynamic>{
        'mode':    _isCampaignBattle ? 'campaign' : 'endless',
        'tier':    activeTier,
        'stage':   (_isCampaignBattle ? campaignStageIndex : endlessStageIndex) + 1,
        'boss':    isBossStage,
        'win':     victory,
        'rounds':  _battleTurnCount,
        // Hero
        'h_lvl':     hero.level,
        'h_hp':      maxHp,
        'h_hp_end':  hero.currentHealth,
        'h_hp_pct':  maxHp > 0 ? (hero.currentHealth * 100 / maxHp).round() : 0,
        // Diagnostics: lowest HP% reached, and total damage the hero took, over
        // the fight. min≈100 + taken≈0 → hero isn't being hit (dodge/control);
        // min low + taken high + end 100 → out-healing.
        'h_hp_min_pct': (maxHp > 0 && _fightLowestHp != (1 << 62))
            ? (_fightLowestHp * 100 / maxHp).round() : 100,
        'h_dmg_taken':  _fightDmgTaken,
        'h_dps':     avgHeroHit,
        // Enemy
        'e_name':  enemy?.name,
        'e_lvl':   enemy?.level,
        'e_hp':    enemy?.maxHealth,
        'e_atk':   enemy?.attack,
        // Fight totals
        'dmg':     _fightDamage,
        'maxhit':  _fightMaxHit,
        'hits':    _fightHits,
      };
      DebugLogger.balance(jsonEncode(rec));
    } catch (_) {/* telemetry must never break a battle */}
  }

  /// PvP fight telemetry — one ZBAL record per arena match (mode "pvp"). Mirrors
  /// [_logBalanceTelemetry] but keyed to the opponent snapshot + PvP rating so we
  /// can judge match fairness (rating gap vs win), fight length, and how close it
  /// was. The PvP opponent's attack is a first-pass HP-derived proxy (see
  /// startPvpBattle) — this is the data to tune it from.
  void _logPvpTelemetry(bool won) {
    try {
      final opp = _pvpOpponent;
      final maxHp = hero.maxHealth;
      final rec = <String, dynamic>{
        'mode':    'pvp',
        'win':     won,
        'rounds':  _battleTurnCount,
        'rating':  pvpRating, // pre-update (called before recordPvpResult adjusts it)
        // Hero
        'h_lvl':     hero.level,
        'h_hp':      maxHp,
        'h_hp_end':  hero.currentHealth,
        'h_hp_pct':  maxHp > 0 ? (hero.currentHealth * 100 / maxHp).round() : 0,
        'h_hp_min_pct': (maxHp > 0 && _fightLowestHp != (1 << 62))
            ? (_fightLowestHp * 100 / maxHp).round() : 100,
        'h_dmg_taken': _fightDmgTaken,
        'h_dps':     avgHeroHit,
        // Opponent
        'e_name':  opp?.heroName,
        'e_lvl':   opp?.level,
        'e_hp':    opp?.maxHp,
        'e_class': opp?.heroClass,
        // Fight totals
        'dmg':     _fightDamage,
        'maxhit':  _fightMaxHit,
        'hits':    _fightHits,
      };
      DebugLogger.balance(jsonEncode(rec));
    } catch (_) {/* telemetry must never break a battle */}
  }

  /// Average damage per swing. Uses recent real hits once the hero has fought;
  /// before that, a gear-based estimate (avg weapon die + flat damage, scaled
  /// by damage% and rebirth) so the HUD always shows a sensible number.
  int get avgHeroHit {
    if (_recentHeroHits.isNotEmpty) {
      return (_recentHeroHits.reduce((a, b) => a + b) / _recentHeroHits.length)
          .round();
    }
    final w = inventory.equippedWeaponDamage;
    final avgDie = w > 0 ? w + (w ~/ 3).clamp(1, 50) / 2.0 : 4.5;
    final flat = hero.baseDmg
        + passiveTree.totalOf(PassiveEffect.damageFlat)
        + inventory.totalOf(ItemStat.damageBonus)
        + inventory.totalOf(ItemStat.strength)
        + petDamage + skinDamage + auraDamage
        + questDamageBonus + artifactPowerBonus + ascDmgBonus
        + runeDmgBonus;
    final dmgPct = passiveTree.totalOf(PassiveEffect.allDamage)
        + inventory.totalOf(ItemStat.damagePercent)
        + hero.levelBonusDamagePct
        + allyDmgPctBonus
        + attrDamagePctFor(hero.activeDamageType);
    var est = (avgDie + flat) * (1.0 + dmgPct / 100.0);
    est *= prestigeDamageMult; // tier + Paragon damage (1.0 when none)
    return est.round().clamp(1, 9999999);
  }
  DamageType lastEnemyDamageType = DamageType.physical;

  // Combo streak — consecutive hits without missing or taking damage
  int _comboStacks = 0;
  int get comboStacks => _comboStacks;
  static const int maxComboStacks = 10;


  // Offline progress — set in loadFromJson, consumed by MainShell dialog
  int offlineGoldEarned     = 0;
  int offlineXpEarned       = 0;
  int offlineEssenceEarned  = 0;
  int offlineSecondsAway    = 0;
  int offlineExpeditionsReady = 0;
  // True when real time away exceeded the 8h idle cap — the dialog then shows
  // "more than 8 hours" rather than a misleading exact figure.
  bool offlineWasCapped     = false;
  void clearOfflineReport() {
    offlineGoldEarned = 0; offlineXpEarned = 0;
    offlineEssenceEarned = 0; offlineSecondsAway = 0;
    offlineExpeditionsReady = 0; offlineWasCapped = false;
  }

  // Tutorial flags — one-time tips, persisted so they don't repeat
  bool tutorialWelcomeSeen    = false;
  bool tutorialBattleSeen     = false;
  bool tutorialIdleSeen       = false;
  bool tutorialUpgradeSeen    = false;
  bool tutorialCampaignSeen   = false;
  bool tutorialDungeonSeen    = false;
  bool tutorialGearSeen       = false;
  bool tutorialForgeSeen      = false;
  bool tutorialRunesSeen      = false;
  bool tutorialArtifactsSeen  = false;
  bool tutorialEndlessSeen    = false;
  bool tutorialGauntletSeen   = false;
  bool tutorialBossRushSeen   = false;
  bool tutorialDailySeen           = false;
  bool tutorialAbilitiesSeen       = false;
  bool tutorialPassivesSeen        = false;
  bool tutorialBestiarySeen        = false;
  bool tutorialPrestigeSeen        = false;
  bool tutorialMercsSeen           = false;
  bool tutorialAchievementsSeen    = false;
  bool tutorialBonusSeen      = false;
  bool tutorialCodexSeen      = false;
  bool tutorialItemDropSeen   = false;
  bool tutorialEnergyEmptySeen = false;
  bool tutorialFirstKillSeen  = false;
  bool tutorialAbilityUnlockSeen = false;

  void markModeTabVisited(String label) {
    if (visitedModeTabs.add(label)) saveToLocal();
  }

  void markTutorialSeen(String key) {
    switch (key) {
      case 'welcome':    tutorialWelcomeSeen    = true;
      case 'battle':     tutorialBattleSeen     = true;
      case 'idle':       tutorialIdleSeen       = true;
      case 'upgrade':    tutorialUpgradeSeen    = true;
      case 'campaign':   tutorialCampaignSeen   = true;
      case 'dungeon':    tutorialDungeonSeen    = true;
      case 'gear':       tutorialGearSeen       = true;
      case 'forge':      tutorialForgeSeen      = true;
      case 'runes':      tutorialRunesSeen      = true;
      case 'artifacts':  tutorialArtifactsSeen  = true;
      case 'endless':    tutorialEndlessSeen    = true;
      case 'gauntlet':   tutorialGauntletSeen   = true;
      case 'bossRush':   tutorialBossRushSeen   = true;
      case 'daily':      tutorialDailySeen      = true;
      case 'abilities':  tutorialAbilitiesSeen  = true;
      case 'passives':   tutorialPassivesSeen   = true;
      case 'bestiary':   tutorialBestiarySeen   = true;
      case 'prestige':      tutorialPrestigeSeen      = true;
      case 'mercs':         tutorialMercsSeen         = true;
      case 'bonus':         tutorialBonusSeen         = true;
      case 'codex':         tutorialCodexSeen         = true;
      case 'achievements':  tutorialAchievementsSeen  = true;
      case 'itemDrop':      tutorialItemDropSeen      = true;
      case 'energyEmpty':   tutorialEnergyEmptySeen   = true;
      case 'firstKill':     tutorialFirstKillSeen     = true;
      case 'abilityUnlock': tutorialAbilityUnlockSeen = true;
    }
    notifyListeners();
    saveToLocal();
  }

  /// Re-enable every contextual tutorial banner so the player can replay the
  /// in-game guidance (the tips reappear as they revisit each screen). Does not
  /// re-show the first-launch welcome dialog — that's gated by SaveService.
  void resetTutorials() {
    tutorialBattleSeen = tutorialIdleSeen = tutorialUpgradeSeen =
      tutorialCampaignSeen = tutorialDungeonSeen = tutorialGearSeen =
      tutorialForgeSeen = tutorialRunesSeen = tutorialArtifactsSeen =
      tutorialEndlessSeen = tutorialGauntletSeen = tutorialBossRushSeen =
      tutorialDailySeen = tutorialAbilitiesSeen = tutorialPassivesSeen =
      tutorialBestiarySeen = tutorialPrestigeSeen = tutorialMercsSeen =
      tutorialBonusSeen = tutorialCodexSeen = tutorialAchievementsSeen =
      tutorialItemDropSeen = tutorialEnergyEmptySeen = tutorialFirstKillSeen =
      tutorialAbilityUnlockSeen = false;
    notifyListeners();
    saveToLocal();
  }

  // Dungeon
  int get deepestDungeonFloor  => _deepestDungeonFloor;
  int _deepestDungeonFloor = 0;

  int get dungeonHighestTier  => _dungeonHighestTier;
  int _dungeonHighestTier = 0;
  bool heroDefeated = false;
  bool lastBattleWasFinalVictory = false;

  int shards = 0;
  int echoes = 0;
  final EndlessUpgrades endlessUpgrades = EndlessUpgrades();

  bool get hasActiveBattle => currentEnemy != null;

  // Campaign is infinite — there is always a next stage
  bool get hasNextStage => true;

  WorldZone get currentZone => zoneForStageIndex(campaignStageIndex);

  CampaignStage get currentCampaignStage {
    if (campaignStageIndex < CampaignData.stages.length) {
      return CampaignData.stages[campaignStageIndex];
    }
    // Beyond the original campaign — generate an abyssal stage
    final depth = campaignStageIndex - CampaignData.stages.length + 1;
    return CampaignStage(
      id: 'abyss_$depth',
      title: 'The Abyss — Depth $depth',
      description: 'The darkness deepens. Ancient evils return stronger than before.',
      difficulty: CampaignData.stages.length + depth,
      goldReward: 0,
      experienceReward: 0,
    );
  }

  /// True once the player has cleared the final campaign stage (Omega). The
  /// campaign caps here — Rebirth is the way forward.
  bool get campaignComplete => campaignStageIndex >= CampaignData.stages.length;

  /// Header label for the current campaign position — "STAGE 42" within the
  /// campaign, "CAMPAIGN COMPLETE" once the 100-stage run is finished.
  String get campaignStageLabel =>
      campaignComplete ? 'CAMPAIGN COMPLETE' : 'STAGE ${campaignStageIndex + 1}';

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _idleTimer?.cancel();
    _iapService.dispose();
    steamService.dispose();
    super.dispose();
  }

  void _setLastAction(String action) {
    lastAction = action;
    notifyListeners();
  }

  void startBattle() {
    if (currentEnemy != null) return;
    // The campaign loops per tier — clearing the final boss unlocks the next
    // tier and restarts at stage 0. If we ever find the index past the end
    // (e.g. a legacy save that stalled in the old Abyss), wrap back to the start
    // so the fight button always works instead of dead-ending.
    if (campaignStageIndex >= CampaignData.stages.length) {
      campaignStageIndex = 0;
    }
    if (!spendEnergy()) return;
    _isCampaignBattle = true;
    heroDefeated = false;
    lastBattleWasFinalVictory = false;
    _battleTurnCount = 0;
    _resetFightStats();
    _resetBattlePerks();
    _activeAffixes = AffixEngine.affixesFor(campaignStageIndex, _rng);
    var enemy = EnemyData.enemyForStage(campaignStageIndex, affixes: _activeAffixes, prestigeLevel: activeTier, heroLevel: hero.level);

    // 5% chance: swap in a Treasure Goblin (skip on boss stages)
    if (!isBossStage && _rng.nextDouble() < 0.05) {
      _treasureGoblinActive = true;
      enemy = Enemy(
        id: 'treasure_goblin',
        name: '💰 Treasure Goblin',
        description: 'A greedy little creature stuffed with rare loot!',
        maxHealth: (enemy.maxHealth * 0.25).round().clamp(1, 999999),
        attack:    (enemy.attack    * 0.20).round().clamp(1, 999),
        level:     enemy.level,
        armorClass: 0,
      );
      _activeAffixes = [];
      battleLog = ['💰 A Treasure Goblin appears! Kill it for rare loot!'];
    }

    if (_mercyTokenActive) {
      // Mercy Token: spawn with −20% HP, one fewer affix
      enemy = Enemy(
        id: enemy.id,
        name: enemy.name,
        description: enemy.description,
        maxHealth: (enemy.maxHealth * 0.8).round().clamp(1, 9999999),
        attack: enemy.attack,
        level: enemy.level,
        armorClass: enemy.armorClass,
      );
      if (_activeAffixes.isNotEmpty) _activeAffixes.removeLast();
      battleLog = ['Mercy Token: ${enemy.name} appears weakened.'];
    } else {
      battleLog = ['A new foe appears: ${enemy.name}.'];
    }
    if (isBossStage) {
      if (enemy.namedBoss) {
        // Unique hand-crafted boss — use stats as designed, just prefix the name.
        enemy = Enemy(
          id: enemy.id,
          name: '☠ ${enemy.name}',
          description: enemy.description,
          maxHealth: enemy.maxHealth,
          attack: enemy.attack,
          level: enemy.level,
          armorClass: enemy.armorClass,
          attackType: enemy.attackType,
          resistances: enemy.resistances,
          namedBoss: true,
        );
        battleLog.add('☠ NAMED BOSS: ${enemy.name} — Unique encounter! Enrages at 30% HP!');
      } else {
        enemy = Enemy(
          id: enemy.id,
          name: '☠ ${enemy.name} (Boss)',
          description: enemy.description,
          maxHealth: (enemy.maxHealth * 1.5).round(),
          attack: (enemy.attack * 1.15).round(),
          level: enemy.level + 1,
          armorClass: enemy.armorClass + 1,
        );
        battleLog.add('⚠ BOSS BATTLE! ${enemy.name} — 2× HP, +25% ATK, Enrages at 30% HP!');
      }
    }
    // Tier: extra armor class + a visual mark at high tiers. HP/ATK scaling is
    // handled by EnemyData.enemyForStage's quadratic tier multipliers (which
    // match the hero's per-tier power growth), so it's not re-applied here.
    if (activeTier > 0) {
      enemy = Enemy(
        id: enemy.id,
        name: activeTier >= 5 ? '⚔ ${enemy.name}' : enemy.name,
        description: enemy.description,
        maxHealth: enemy.maxHealth,
        attack: enemy.attack,
        level: enemy.level,
        armorClass: enemy.armorClass + activeTier ~/ 2,
        attackType: enemy.attackType,
        resistances: enemy.resistances,
      );
    }
    // Apply challenge modifier to enemy and hero
    final mod = activeModifier;
    if (mod != null) {
      enemy = Enemy(
        id: enemy.id,
        name: enemy.name,
        description: enemy.description,
        maxHealth: (enemy.maxHealth * mod.enemyHpMult).round().clamp(1, 9999999),
        attack: (enemy.attack * mod.enemyAtkMult).round().clamp(1, 1000000000000000),
        level: enemy.level,
        armorClass: enemy.armorClass,
      );
    }
    currentEnemy = enemy;
    audioService.startBattleMusic();
    hero.healToFull();
    // Apply modifier HP penalty to hero after heal
    if (mod != null && mod.heroHpMult < 1.0) {
      hero.currentHealth = (hero.maxHealth * mod.heroHpMult).round().clamp(1, hero.maxHealth);
    }
    if (_activeAffixes.isNotEmpty) {
      battleLog.add('Corruption: ${_activeAffixes.map((a) => a.displayName).join(', ')}');
    }
    if (mod != null) {
      battleLog.add('Challenge: ${mod.name} active.');
    }
    _setLastAction('Battle started against ${enemy.name}.');
  }

  final _rng = Random();

  bool _hasKeyword(ItemKeyword keyword) =>
      inventory.equipped.values.any((item) => item.keyword == keyword);

  void heroAttack() {
    final enemy = currentEnemy;
    if (enemy == null) return;
    _battleTurnCount++;
    if (_battleTurnCount > 1) battleLog.add('— Round $_battleTurnCount —');

    // Aura HP regen — a FLAT heal every turn (not a % of max HP). Because it's
    // flat, it becomes a smaller fraction as you build max HP (via Endurance),
    // so it sustains without trivialising: you can still be worn down and nearly
    // die in a long fight. Applied even when stunned.
    if (auraHpRegen > 0 && hero.currentHealth > 0 && hero.currentHealth < hero.maxHealth) {
      final regen = (auraHpRegen * 3 * kRecoveryMult).round().clamp(1, 999999);
      final before = hero.currentHealth;
      hero.currentHealth = (hero.currentHealth + regen).clamp(0, hero.maxHealth);
      final healed = hero.currentHealth - before;
      if (healed > 0) battleLog.add('✚ Aura regen: +$healed HP.');
    }

    // Boss ability stun: hero skips this turn
    if (_heroStunRounds > 0) {
      _heroStunRounds--;
      battleLog.add('${hero.name} is stunned and cannot act! ($_heroStunRounds rounds left)');
      notifyListeners();
      return;
    }

    // Zone modifier: hero drain (campaign only)
    final zoneMod = activeZoneModifier;
    if (zoneMod?.effect == ZoneEffect.heroDrain) {
      final drain = zoneMod!.value;
      hero.takeDamage(drain);
      _noteHeroDamageTaken(drain);
      battleLog.add('${zoneMod.icon} ${zoneMod.label}: you lose $drain HP.');
      _checkAllyHpAbilities();
      if (hero.currentHealth <= 0) {
        _battleDefeat();
        return;
      }
    }

    // Fire ready abilities
    _abilityRound++;
    // Ally battle-start abilities fire on round 1
    if (_abilityRound == 1) {
      if (_fireAllyBattleStartAbilities(enemy)) return;
    }
    // CHA cooldown bypass: (CHA total / 5)% chance, max 20% at CHA 100
    final chaTotal = hero.charisma + inventory.totalOf(ItemStat.charisma)
        + _setTotal(ItemStat.charisma) + _gemTotal(ItemStat.charisma);
    final chaBypassPct = (chaTotal / 5.0).clamp(0.0, 20.0);
    for (final ability in unlockedAbilities) {
      final readyAt = _cooldownUntil[ability.id] ?? 0;
      bool onCooldown = _abilityRound < readyAt;
      if (onCooldown && chaBypassPct > 0 && _rng.nextDouble() * 100 < chaBypassPct) {
        onCooldown = false;
        battleLog.add('✨ ${ability.name} reset by Charisma!');
      }
      if (!onCooldown) {
        _fireAbility(ability);
        // Arcane Overflow keystone: 15% chance to fire ability twice
        if (!enemy.isDefeated && passiveTree.hasKeystone(PassiveBranch.mystic) && _rng.nextInt(100) < 15) {
          battleLog.add('🌀 Arcane Overflow! ${ability.name} echoes!');
          _fireAbility(ability);
        }
        _cooldownUntil[ability.id] = _abilityRound + scaledAbilityCooldown(ability);
        if (enemy.isDefeated) {
          _battleVictory(enemy);
          return;
        }
      }
    }

    // ── New combat: attacks always land. No hit/miss roll vs AC. ─────────────
    // Crits are purely chance-based; enemy armorClass = flat physical DR.
    _attackRoundCounter++;

    // Time Fracture affix: every 4th attack is reduced-damage (glancing blow)
    bool timeFractureGlance = false;
    if (_activeAffixes.contains(ZoneAffix.timeFracture) &&
        _attackRoundCounter % 4 == 0) {
      timeFractureGlance = true;
      battleLog.add('Time Fracture! Glancing blow.');
    }

    // Crit determination — purely chance-based
    // Valor Surge: guaranteed crit on next attack after ability fires
    final valorSurgeCrit = _valorSurgeReady;
    if (_valorSurgeReady) _valorSurgeReady = false;
    bool backstab = false;
    if (_lenaBackstabReady) { _lenaBackstabReady = false; backstab = true; }
    final bloodlustCrit = _bloodlustReady;
    if (_bloodlustReady) _bloodlustReady = false;
    // Keen Edge upgrade adds +10% crit on top of the central getter
    final critChancePct = totalCritChancePct; // crit is gear-only; Keen Edge now grants % damage
    final crit = backstab
        || valorSurgeCrit  // Valor Surge guarantees a crit on next hit
        || bloodlustCrit   // Bloodlust keystone: kill → guaranteed crit on next attack
        || (!timeFractureGlance && _rng.nextInt(100) < critChancePct);

    // Armor penetration: reduces enemy flat DR (pierce passive + subclass)
    final subPierce = (subclassEffect == SubclassEffect.vengeance ? 5 : 0) + subclassPierce;
    final pierce = passiveTree.totalOf(PassiveEffect.pierce) + subPierce
        + _masteryTotal(MasteryEffect.piercePerHit);

    {
      // Shadow Cloak affix: 20% chance to negate the hit
      if (_activeAffixes.contains(ZoneAffix.shadowCloak) &&
          _rng.nextInt(100) < 20) {
        battleLog.add('Hit! (Shadow Cloak negates)');
        notifyListeners();
        return;
      }

      final weaponBaseDmg = inventory.equippedWeaponDamage;
      final dieCap = subclassEffect == SubclassEffect.openHand ? 10 : 8;
      final dmgDie = weaponBaseDmg > 0
          ? weaponBaseDmg + _rng.nextInt((weaponBaseDmg ~/ 3).clamp(1, 50))
          : _rng.nextInt(dieCap) + 1;
      final critMult = totalCritDamageMult.round();
      var baseDmg = ((crit ? dmgDie * critMult : dmgDie) + hero.baseDmg
          + passiveTree.totalOf(PassiveEffect.damageFlat)
          + inventory.totalOf(ItemStat.damageBonus)
          + inventory.totalOf(ItemStat.strength)
          + (subclassEffect == SubclassEffect.warCleric ? 2 : 0)
          + petDamage
          + skinDamage
          + auraDamage
          + _setTotal(ItemStat.damageBonus)
          + _setTotal(ItemStat.strength)
          + _gemTotal(ItemStat.damageBonus)
          + _gemTotal(ItemStat.strength)
          + _masteryTotal(MasteryEffect.flatDamagePerHit)
          + _masteryTotal(MasteryEffect.permanentDamage)
          + questDamageBonus
          + artifactPowerBonus
          + ascDmgBonus
          + runeDmgBonus
          + _scorePwr).clamp(1, 1000000000000000);

      // Blood Pact keyword: bonus damage equal to 20% of missing HP
      if (_hasKeyword(ItemKeyword.bloodPact)) {
        baseDmg = (baseDmg + ((hero.maxHealth - hero.currentHealth) * 0.20).round()).clamp(1, 1000000000000000).toInt();
      }

      // Flat affix reductions applied before pipeline (not % — keep inline)
      if (_activeAffixes.contains(ZoneAffix.ironSkin)) {
        baseDmg = (baseDmg * 0.80).round().clamp(1, 1000000000000000).toInt();
      }
      if (_activeAffixes.contains(ZoneAffix.diamondHide)) {
        final ratio = enemy.currentHealth / enemy.maxHealth;
        final reduction = (2 + (ratio * 6).floor()).clamp(2, 8);
        baseDmg = (baseDmg - reduction).clamp(1, 1000000000000000).toInt();
      }

      // ── Damage pipeline ───────────────────────────────────────────────────
      final heroType      = hero.activeDamageType;
      final exploitAcCap  = endlessUpgrades.synergyMindweave ? 16 : 14;
      final exploitMult   = (endlessUpgrades.exploitWeakness && enemy.armorClass <= exploitAcCap) ? 1.30 : 1.0;
      final subclassDmgMult = switch (subclassEffect) {
        SubclassEffect.hunter    => 1.20,
        SubclassEffect.vengeance => 1.10,
        _ => 1.0,
      };
      final rawWeakMult = bestiaryWeaknessBonus(enemy.id) * bestiaryTypeDamageMult(enemy.id);
      final primordialCore = rawWeakMult > 1.0 && passiveTree.hasKeystone(PassiveBranch.elementalist);
      final weakMult = primordialCore ? 2.0 : rawWeakMult;

      final _penPct = passiveTree.totalOf(PassiveEffect.allPenetration)
          + inventory.totalOf(ItemStat.elemPenetration);
      final _penMap = _penPct > 0
          ? <DamageType, double>{heroType: _penPct / 100.0}
          : const <DamageType, double>{};

      final _dmgCtx = buildWeaponAttackContext(
        baseDmg:          baseDmg,
        heroType:         heroType,
        allDamagePct:     passiveTree.totalOf(PassiveEffect.allDamage).toDouble() + ascAllDamagePct + critReplacementDamagePct + allyDmgPctBonus
                          + passiveElemDamagePct(heroType)
                          + gemElemDamagePct(heroType)
                          + inventory.totalOf(ItemStat.damagePercent)
                          + _setTotal(ItemStat.damagePercent)  // set bonus damage%
                          + hero.levelBonusDamagePct
                          + attrDamagePctFor(heroType)
                          + elementalMasteryDamagePct(heroType)
                          + guildBuffs.allDamagePct, // guild castle (T10) all-damage buff
        endlessDmgMult:   endlessUpgrades.damageMultiplier,
        exploitMult:      exploitMult,
        subclassDmgMult:  subclassDmgMult,
        comboStacks:      _comboStacks,
        bestiaryWeakMult: weakMult,
        traitDmgMult:     traitDmgPct != 0 ? (100 + traitDmgPct) / 100.0 : 1.0,
        isBerserk:        subclassEffect == SubclassEffect.berserk &&
                              hero.currentHealth * 2 < hero.maxHealth,
        enemyResistances: enemy.resistances,
        penetration:      _penMap,
      );
      var damage = calculateDamage(_dmgCtx, rng: _rng).total.round().clamp(1, 1000000000000000);
      damage = (damage * prestigeDamageMult).round().clamp(1, 1000000000000000); // tier + Paragon dmg
      // attackBonus buff: now a % DAMAGE boost (was flat "bonus crit damage" that
      // was never actually applied). Scales with the hero instead of being a
      // meaningless flat number.
      if (_tempAttackBonus > 0) {
        damage = (damage * (1 + _tempAttackBonus / 100.0)).round().clamp(1, 1000000000000000);
      }

      // Log resistance/vulnerability (value already applied by pipeline; res capped at 75)
      final resistance = (enemy.resistances[heroType] ?? 0).clamp(-200, 90);
      if (resistance > 0) {
        battleLog.add('${enemy.name} resists ${heroType.label} (${resistance}% resist)!');
      } else if (resistance < 0) {
        battleLog.add('${enemy.name} is vulnerable to ${heroType.label}! (${-resistance}% extra)');
      }

      // Wild Magic: 15% chance triple damage (post-pipeline random event)
      if (subclassEffect == SubclassEffect.wildMagic && _rng.nextInt(100) < 15) {
        damage = (damage * 3).clamp(1, 1000000000000000);
        battleLog.add('Wild Magic surge!  $damage damage!');
      }

      // Soul Rip keyword: 8% instakill below 25% HP
      if (_hasKeyword(ItemKeyword.soulRip) &&
          enemy.currentHealth / enemy.maxHealth < 0.25 &&
          _rng.nextInt(100) < 8) {
        damage = enemy.currentHealth;
        battleLog.add('Soul Rip! ${enemy.name}\'s soul is torn free!');
      }

      // Vulnerable debuff: enemy takes extra % damage
      if (_enemyVulnerablePct > 0) {
        damage = (damage * (1.0 + _enemyVulnerablePct / 100.0)).round().clamp(1, 1000000000000000);
      }

      // Flat armor DR: physical damage is reduced by enemy armor (minus pierce).
      // Elemental damage bypasses armor entirely — casters' core advantage.
      if (heroType == DamageType.physical) {
        final armorReduction = max(0, enemy.armorClass - pierce);
        damage = max(1, damage - armorReduction);
      }

      // PvP burst compression: in the visible match the hero deals full
      // game-scale damage vs a rival's non-×5 HP, one-shotting them so the
      // attacker always wins in 1-2 rounds. Scale the hero's hit down in PvP so
      // both sides' damage matters. Tunable via Remote Config (default −90%).
      damage = _pvpDamageScaled(damage);

      enemy.takeDamage(damage);
      lastHeroDamage     = damage;
      _recordHeroHit(damage);
      lastHeroDamageType = heroType;
      lastHeroCrit       = crit;
      _comboStacks = (_comboStacks + 1).clamp(0, maxComboStacks);
      _dailyDamageDealt += damage;
      _totalDamageDealt  += damage;
      _trackBountyProgress(BountyType.dealDamage, damage);
      audioService.playHitWithType(heroType);
      // ── Lifesteal (all sources), capped per round ──────────────────────────
      // Life Steal keyword (4%) + Fiend Pact/subclass + class mastery + draining
      // aura. Heals a % of damage dealt, but the TOTAL is capped at
      // kLifestealMaxPctPerRound of max HP per round — otherwise endgame damage
      // (>> your HP) makes even a sliver of lifesteal full-heal every hit, which
      // was the main reason heroes never dropped below full HP.
      final lifestealPct = (_hasKeyword(ItemKeyword.lifeSteal) ? 4 : 0)
          + (subclassEffect == SubclassEffect.fiendPact ? 8 : 0) + subclassLifestealPct
          + _masteryTotal(MasteryEffect.lifestealPct)
          + prestigeLifestealPct // Blood Drinker paragon
          + (auraLifestealActive ? auraLifestealPct : 0);
      // Lifesteal now scales off Heal Rating, NOT damage dealt — so billions of
      // damage can no longer full-heal a hero with a sliver of lifesteal. Each
      // hit restores lifestealPct% of Heal Rating.
      if (lifestealPct > 0 && healRating > 0) {
        // Per-HIT, and a round has many hits — so scale small: lifestealPct% of
        // Heal Rating, divided by kHealValuePerMult, keeps it a minor top-up.
        final steal = (healRating * lifestealPct / 100 / kHealValuePerMult).round()
            .clamp(0, hero.maxHealth - hero.currentHealth).toInt();
        if (steal > 0) {
          hero.currentHealth += steal;
          if (auraLifestealActive) battleLog.add('🩸 Draining Aura — +$steal HP.');
        }
      }
      final effect   = AttackEffect.byId(equippedAttackEffectId);
      final hitWord  = crit ? 'CRITICAL HIT' : (effect?.hitText ?? 'Hit');
      if (backstab) battleLog.add('🌑 Lena: Backstab!');
      battleLog.add('$hitWord!${heroType.shortTag} $damage dmg.');
      if (primordialCore) battleLog.add('🌋 Primordial Core! Weakness exploited — 2× damage!');
      // Cael: Warmaster's Strike — on first crit, deal 15% enemy max HP as bonus damage
      if (crit && allyUnlocked('warmaster_cael') && !_allyAbilitiesUsed.contains('warmaster_cael')) {
        _allyAbilitiesUsed.add('warmaster_cael');
        final bonusDmg = (enemy.maxHealth * 0.15).round().clamp(1, 1000000000000000);
        enemy.takeDamage(bonusDmg);
        _recordFightDamage(bonusDmg);
        battleLog.add('⚡ Cael: Warmaster\'s Strike! +$bonusDmg bonus damage!');
        _queueMercFx('Cael', '⚡', const Color(0xFFffcc44));
      }
      if (enemy.isDefeated) {
        _battleVictory(enemy);
        return;
      }

      // Boss enrage at 30% HP
      if (!_bossEnraged && isBossStage &&
          enemy.currentHealth / enemy.maxHealth < 0.3) {
        _bossEnraged = true;
        battleLog.add('⚠ ${enemy.name} ENRAGES! Strikes twice — brace yourself!');
      }

      // DEX Lv10 — Blade Flicker: 12% chance extra strike (20% with Berserker synergy)
      final bladeFlickerChance = endlessUpgrades.synergyBerserker ? 35 : 22;
      if (endlessUpgrades.bladeFlicker && _rng.nextInt(100) < bladeFlickerChance) {
        final c2 = _rng.nextInt(100) < critChancePct;
        var bd2 = ((c2 ? (_rng.nextInt(8) + 1) * 2 : _rng.nextInt(8) + 1) + hero.baseDmg)
            .clamp(1, 1000000000000000);
        if (_activeAffixes.contains(ZoneAffix.ironSkin)) bd2 = (bd2 * 0.80).round().clamp(1, 1000000000000000);
        if (_activeAffixes.contains(ZoneAffix.diamondHide)) {
          final ratio = enemy.currentHealth / enemy.maxHealth;
          bd2 = (bd2 - (2 + (ratio * 6).floor()).clamp(2, 8)).clamp(1, 1000000000000000);
        }
        final flickerArmor = max(0, enemy.armorClass - pierce);
        final dmg2 = _pvpDamageScaled(max(1, (bd2 * endlessUpgrades.damageMultiplier).round() - flickerArmor));
        enemy.takeDamage(dmg2);
        _recordFightDamage(dmg2);
        battleLog.add('Blade Flicker!${c2 ? " CRIT" : ""}${heroType.shortTag} $dmg2 dmg.');
        if (enemy.isDefeated) { _battleVictory(enemy); return; }
      }
      // Swift Strike keyword: 15% chance for an extra hit
      if (!enemy.isDefeated && _hasKeyword(ItemKeyword.swiftStrike) && _rng.nextInt(100) < 15) {
        final ds = _pvpDamageScaled(max(1, _rng.nextInt(8) + 1 + hero.baseDmg + inventory.totalOf(ItemStat.strength)
            - max(0, enemy.armorClass - pierce)).toInt());
        enemy.takeDamage(ds);
        _recordFightDamage(ds);
        battleLog.add('Swift Strike! $ds dmg.');
        if (enemy.isDefeated) { _battleVictory(enemy); return; }
      }
      // Class mastery multi-strike
      final masteryMultiPct = _masteryTotal(MasteryEffect.multiStrikePct);
      if (!enemy.isDefeated && masteryMultiPct > 0 && _rng.nextInt(100) < masteryMultiPct) {
        final cm = _rng.nextInt(100) < critChancePct;
        var dm = ((cm ? (_rng.nextInt(8) + 1) * critMult : _rng.nextInt(8) + 1)
            + hero.baseDmg
            + _masteryTotal(MasteryEffect.flatDamagePerHit)
            + _masteryTotal(MasteryEffect.permanentDamage)).clamp(1, 1000000000000000);
        final dm2 = _pvpDamageScaled(max(1, (dm * endlessUpgrades.damageMultiplier).round()
            - max(0, enemy.armorClass - pierce)).toInt());
        enemy.takeDamage(dm2);
        _recordFightDamage(dm2);
        battleLog.add('${cm ? "CRITICAL " : ""}Mastery strike! $dm2 dmg.');
        if (enemy.isDefeated) { _battleVictory(enemy); return; }
      }
    }

    // (Enemy regen removed — enemies never heal during battle)

    notifyListeners();
  }

  void _enemyTurn(Enemy enemy) {
    // Per-round passive regen (Guardian branch node)
    final roundRegen = passiveTree.totalOf(PassiveEffect.regenFlat);
    if (roundRegen > 0) {
      final actual = (hero.maxHealth - hero.currentHealth).clamp(0, roundRegen);
      if (actual > 0) {
        hero.currentHealth += actual;
        battleLog.add('${hero.name} regenerates $actual HP.');
      }
    }
    // Cursed Ground affix: hero bleeds 5% max HP each round (ticks at start of enemy turn)
    if (_activeAffixes.contains(ZoneAffix.cursedGround) ||
        _activeAffixes.contains(ZoneAffix.deathSpiral)) {
      _deathSpiralRounds++;
      // Death Spiral: drain% grows by +1% every 3 rounds
      final extraPct = _activeAffixes.contains(ZoneAffix.deathSpiral)
          ? (_deathSpiralRounds ~/ 3) * 0.01
          : 0.0;
      final drain = (hero.maxHealth * (0.05 + extraPct)).round().clamp(1, 1000000000000000);
      hero.takeDamage(drain);
      _noteHeroDamageTaken(drain);
      battleLog.add('Cursed Ground${_activeAffixes.contains(ZoneAffix.deathSpiral) ? " (Death Spiral)" : ""}: '
          '${hero.name} bleeds $drain HP.');
      if (hero.currentHealth <= 0 && passiveTree.hasKeystone(PassiveBranch.guardian) && !_unbreakableUsed) {
        hero.currentHealth = 1;
        _unbreakableUsed = true;
        battleLog.add('💠 Unbreakable! ${hero.name} refuses to fall at 1 HP!');
      }
      if (hero.currentHealth <= 0 && endlessUpgrades.unbroken && !_unbrokenUsed) {
        hero.currentHealth = 1;
        _unbrokenUsed = true;
        battleLog.add('Unbroken! ${hero.name} clings to life at 1 HP!');
      }
      if (hero.currentHealth <= 0) {
        _battleDefeat();
        return;
      }
    }

    // (Lifeleech Aura removed — enemies never heal during battle)

    // Boss ability DoT tick — ongoing damage applied to hero each enemy turn
    if (_heroDotRoundsLeft > 0) {
      _heroDotRoundsLeft--;
      final dmg = _heroDotDmgPerRound.clamp(1, 1000000000000000);
      hero.takeDamage(dmg);
      _noteHeroDamageTaken(dmg);
      pendingFloats.add((value: dmg, isHeal: false, type: _heroDotType));
      battleLog.add('${_heroDotType.emoji} Ongoing damage: ${hero.name} takes $dmg ${_heroDotType.label} dmg ($_heroDotRoundsLeft rounds left).');
      if (hero.currentHealth <= 0 && passiveTree.hasKeystone(PassiveBranch.guardian) && !_unbreakableUsed) {
        hero.currentHealth = 1;
        _unbreakableUsed = true;
        battleLog.add('💠 Unbreakable! ${hero.name} refuses to fall at 1 HP!');
      }
      if (hero.currentHealth <= 0 && endlessUpgrades.unbroken && !_unbrokenUsed) {
        hero.currentHealth = 1;
        _unbrokenUsed = true;
        battleLog.add('Unbroken! ${hero.name} clings to life at 1 HP!');
      }
      if (hero.currentHealth <= 0) { _battleDefeat(); return; }
    }

    // Ability DoT tick — INT scales DoT damage (+1% per INT above 10)
    if (_dotRoundsLeft > 0) {
      _dotRoundsLeft--;
      final intTotal = hero.intelligence + inventory.totalOf(ItemStat.intelligence)
          + _setTotal(ItemStat.intelligence) + _gemTotal(ItemStat.intelligence);
      final intDotMult = 1.0 + max(0.0, (intTotal - 10) * 0.01);
      final scaledDot = (_dotDmg * intDotMult).round().clamp(1, 1000000000000000);
      enemy.takeDamage(scaledDot);
      _recordFightDamage(scaledDot);
      pendingFloats.add((value: scaledDot, isHeal: false, type: _dotDamageType));
      battleLog.add('Ongoing damage: ${enemy.name} takes $scaledDot dmg ($_dotRoundsLeft rounds left).');
      if (_dotRoundsLeft == 0) _dotDmg = 0; // clear so stacking Envenom restarts fresh
      if (enemy.isDefeated) {
        _battleVictory(enemy);
        return;
      }
    }

    // Bosses can't be perma-locked: after 2 attacks skipped/avoided in a row, the
    // next one is UNSTOPPABLE — it ignores stun/dodge/avoidance (still armor-
    // mitigated). Keeps control abilities useful without making bosses harmless.
    final bossUnstoppable = isBossStage && _bossAttacksSkipped >= 2;
    if (bossUnstoppable) battleLog.add('${enemy.name} breaks through — unstoppable!');

    // Ability stun — enemy skips its attack
    if (!bossUnstoppable && _enemyStunRounds > 0) {
      _enemyStunRounds--;
      _bossAttacksSkipped++;
      battleLog.add('${enemy.name} is stunned and cannot act!');
      _decrementBuffs();
      return;
    }

    // Ability dodge — hero negates the next incoming hit
    if (!bossUnstoppable && _dodgeNextHit) {
      _dodgeNextHit = false;
      _bossAttacksSkipped++;
      battleLog.add('${hero.name} dodges the attack!');
      _decrementBuffs();
      return;
    }

    // Per-turn HP regen
    if (subclassEffect == SubclassEffect.devotion) {
      hero.currentHealth = (hero.currentHealth + 1).clamp(0, hero.maxHealth);
    }
    if (petHpRegen > 0) {
      hero.currentHealth = (hero.currentHealth + petHpRegen).clamp(0, hero.maxHealth);
    }

    // Merc dodge buff (Felix Smoke Screen) — active for its first few rounds.
    final mercDodge = _mercDodgeRounds > 0 ? _mercDodgePct : 0;
    if (_mercDodgeRounds > 0) _mercDodgeRounds--;

    // WIS Lv10 — Battle Awareness: auto-dodge the enemy's FIRST attack (once, deterministic).
    if (!bossUnstoppable && !_battleAwarenessUsed && endlessUpgrades.battleAwareness) {
      _battleAwarenessUsed = true;
      _bossAttacksSkipped++;
      battleLog.add('Battle Awareness! ${hero.name} reads the strike and steps aside.');
      _decrementBuffs();
      return;
    }

    // Consolidated avoidance: dodge rating + Shadow Step + Void Step + enemy
    // miss-chance are combined into ONE roll (they used to be independent rolls
    // that multiplied to near-total avoidance — a hero took 0 damage over a
    // 14-round boss fight). Capped at kMaxAvoidChance so the enemy always lands a
    // meaningful share of its attacks.
    final dodgeRating  = heroDodgeRating + mercDodge;
    final passiveDodge = kDefenseCapPct * dodgeRating / (dodgeRating + kDodgeRatingK);
    final avoidChance  = (1.0
        - (1.0 - passiveDodge / 100.0)
        * (1.0 - (endlessUpgrades.shadowStep ? 0.25 : 0.0))
        * (1.0 - (_hasKeyword(ItemKeyword.voidStep) ? 0.15 : 0.0))
        * (1.0 - _enemyMissChancePct / 100.0))
        .clamp(0.0, kMaxAvoidChance);
    if (!bossUnstoppable && avoidChance > 0 && _rng.nextDouble() < avoidChance) {
      _bossAttacksSkipped++;
      battleLog.add('${hero.name} avoids the attack!');
      _decrementBuffs();
      return;
    }
    // Attack is landing this round — reset the perma-lock breaker.
    _bossAttacksSkipped = 0;

    // Abyssal Roar affix + zone modifier: flat damage bonus (formerly attack-roll bonus)
    final int affixDmgBonus = _activeAffixes.contains(ZoneAffix.abyssalRoar) ? 5 : 0;
    final int zoneAtkBonus  = (activeZoneModifier?.effect == ZoneEffect.enemyAtkBonus)
        ? activeZoneModifier!.value : 0;

    // Hero armor: reduces incoming physical damage (Last Epoch style).
    // STR adds to Armor Class; DEX gives Dodge Chance instead.
    final baseArmor = hero.armorClass + (endlessUpgrades.lightFooted ? 5 : 0)
        + passiveTree.totalOf(PassiveEffect.armorFlat)
        + _masteryTotal(MasteryEffect.permanentAC)
        + questACBonus
        + inventory.totalOf(ItemStat.armorClass)
        + inventory.totalOf(ItemStat.strength)
        + petArmor
        + skinArmor
        + auraArmor
        + _setTotal(ItemStat.armorClass)
        + _setTotal(ItemStat.strength)
        + _gemTotal(ItemStat.armorClass)
        + _gemTotal(ItemStat.strength)
        + artifactAcBonus
        + runeAcBonus
        + _scoreFor                                        // FOR (Fortitude) score — flat AC Rating
        // Former FLAT damage reductions, now Armor Class RATING so they run through
        // the diminishing-returns curve like every other defensive source (no more
        // flat "−N damage" that's meaningless once enemy hits are in the hundreds).
        + (_hasKeyword(ItemKeyword.ironWill) ? 1 : 0)      // Iron Will keyword
        + (endlessUpgrades.synergyJuggernaut ? 1 : 0)      // Juggernaut synergy
        + endlessUpgrades.flatDamageReduction              // Fortitude (CON node)
        + (endlessUpgrades.thickHide ? 3 : 0);             // Thick Hide (CON milestone)
    // Armor Class RATING is boosted by a % from: the acBonus ability buff (while
    // active), mercenaries' AC (allyAcBonus), subclass armour, and the DUR
    // (Durability) score — all % of your rating, through the diminishing-returns curve.
    final acPctBoost = _tempAcBonus + allyAcBonus + subclassArmorPct + _scoreDurPct;
    final heroArmor = acPctBoost > 0
        ? (baseArmor * (1 + acPctBoost / 100.0)).round()
        : baseArmor;

    // Damage roll is 70-100% of the enemy's attack (was a wild 1..attack uniform
    // roll that often whiffed for a fraction). No longer capped at 9999 — that
    // old cap made high-tier enemies unable to threaten large HP pools.
    var rawDamage = ((enemy.attack * (0.7 + _rng.nextDouble() * 0.3)).round()
        + affixDmgBonus + zoneAtkBonus).clamp(1, 1000000000000000);
    // Weaken/Disarm debuff: reduce enemy ATK. A full disarm now shares stun's
    // diminishing returns (see _applyEnemyWeaken), so it can't be chained to keep
    // an enemy permanently harmless. An unstoppable boss attack ignores it.
    if (_enemyWeakenPct > 0 && !bossUnstoppable) {
      rawDamage = (rawDamage * (1.0 - _enemyWeakenPct / 100.0)).round().clamp(1, 1000000000000000);
    }

    // Ruk Stone Skin now scales: 30% of the incoming hit is absorbed (was a
    // flat −4 that became meaningless as enemy damage grew).
    final rukActive            = _rukStoneSkinRoundsLeft > 0;
    if (_rukStoneSkinRoundsLeft > 0) _rukStoneSkinRoundsLeft--;

    // Armor is a damage-reduction RATING (diminishing returns, caps at
    // kDefenseCapPct) applied to physical damage. Elemental attacks bypass armor
    // (resistances handle those). The former flat keyword/CON reductions are now
    // folded into heroArmor (the rating), so there is no flat subtraction here.
    final armorDrPct = kDefenseCapPct * heroArmor / (heroArmor + kArmorRatingK);
    final int damage;
    {
      var d = enemy.attackType == DamageType.physical
          ? max(0, (rawDamage * (1 - armorDrPct / 100)).round())
          : rawDamage;
      if (rukActive) d = (d * 0.70).round();
      damage = d;
    }

    if (damage > 0) {
      // Apply hero's stat-based elemental resistance
      final heroRes  = heroResistancePct(enemy.attackType);
      // Dampen each hit while enraged so the (now 2) enraged strikes total only
      // ~+40% rather than a full-HP one-shot.
      final enrageMult = _bossEnraged ? 0.7 : 1.0;
      final resisted = heroRes != 0 ? damage * (1.0 - heroRes / 100.0) : damage.toDouble();
      // (acBonus now boosts the hero's Armor Class rating % above, folded into
      // heroArmor's damage-reduction curve rather than a flat % reduction here.)
      // Damage reduction is hard-capped at 90%: a landed hit always deals at
      // least 10% of the raw roll, so stacked armor + resistance + this buff can
      // never make the hero immune (a maxed hero was taking 0 damage via >100% resist).
      final minDmg = rawDamage * 0.10;
      final finalDmg = max(resisted * enrageMult, minDmg).round().clamp(0, 1000000000000000);

      int absorbed = 0;
      if (_heroAbsorbShield > 0) {
        absorbed = min(_heroAbsorbShield, finalDmg);
        _heroAbsorbShield -= absorbed;
        if (_heroAbsorbShield == 0) battleLog.add('Barrier shattered!');
      }
      final shieldedDmg = finalDmg - absorbed;
      if (shieldedDmg > 0) hero.takeDamage(shieldedDmg);
      _noteHeroDamageTaken(shieldedDmg);
      lastEnemyDamage     = shieldedDmg;
      lastEnemyDamageType = enemy.attackType;
      _comboStacks = 0; // taking damage breaks combo
      audioService.playEnemyAttack(weaknessForEnemyId(enemy.id));
      final typeTag  = enemy.attackType == DamageType.physical
          ? '' : ' (${enemy.attackType.label})';
      final armorTag = enemy.attackType == DamageType.physical && heroArmor > 0
          ? ' [-${armorDrPct.round()}% arm]'
          : '';
      final resTag = heroRes > 0 ? ' [$heroRes% res]'
          : heroRes < 0 ? ' [${-heroRes}% vuln]' : '';
      battleLog.add('${enemy.name} hits!$typeTag$armorTag$resTag $finalDmg dmg.');

      // Thorn Wall keyword: return 30% of incoming damage to attacker
      if (_hasKeyword(ItemKeyword.thornWall)) {
        final thorn = (finalDmg * 0.30).round().clamp(1, 1000000000000000);
        enemy.takeDamage(thorn);
        _recordFightDamage(thorn);
        battleLog.add('Thorn Wall reflects $thorn dmg!');
        if (enemy.isDefeated) { _battleVictory(enemy); return; }
      }

      // (Soul Siphon heal removed — enemies never heal during battle)

      // CON Lv25 — Unbroken: survive one killing blow per battle at 1 HP
      if (hero.currentHealth <= 0 && passiveTree.hasKeystone(PassiveBranch.guardian) && !_unbreakableUsed) {
        hero.currentHealth = 1;
        _unbreakableUsed = true;
        battleLog.add('💠 Unbreakable! ${hero.name} refuses to fall at 1 HP!');
      }
      if (hero.currentHealth <= 0 && endlessUpgrades.unbroken && !_unbrokenUsed) {
        hero.currentHealth = 1;
        _unbrokenUsed = true;
        battleLog.add('Unbroken! ${hero.name} clings to life at 1 HP!');
      }
      // Mira: Field Triage (heal below 30%), Ironhide: Shield Wall (block below 50%)
      _checkAllyHpAbilities();

      if (hero.currentHealth <= 0) {
        _battleDefeat();
        return;
      }

      // CON Lv10 — Battle Scarred: regen 3% HP (5% with Iron Sage synergy)
      if (endlessUpgrades.battleScarred) {
        final scarredPct = endlessUpgrades.synergyIronSage ? 0.05 : 0.03;
        var regen = (hero.maxHealth * scarredPct).round().clamp(1, 1000000000000000);
        // Void Curse affix: halve all hero HP recovery
        if (_activeAffixes.contains(ZoneAffix.voidCurse)) regen = (regen / 2).round().clamp(1, 1000000000000000);
        hero.currentHealth = (hero.currentHealth + regen).clamp(0, hero.maxHealth);
      }
    } else {
      battleLog.add('${enemy.name} attacks — fully absorbed! ($heroArmor armor)');
      // Riposte keyword: triggers when attack is completely blocked
      if (_hasKeyword(ItemKeyword.riposte)) {
        enemy.takeDamage(3);
        _recordFightDamage(3);
        battleLog.add('Riposte! 3 damage returned.');
        if (enemy.isDefeated) { _battleVictory(enemy); return; }
      }
    }
    // Boss abilities — fire each ability on its cooldown (blocked by silence)
    if (enemy.abilities.isNotEmpty) {
      if (_enemySilenceRounds > 0) {
        battleLog.add('${enemy.name} tries to use an ability but is silenced!');
      } else {
        for (final ability in enemy.abilities) {
          final cd = _bossAbilityCooldowns[ability.id] ?? ability.cooldownRounds;
          if (cd <= 0) {
            if (_fireBossAbility(ability, enemy)) return;
            _bossAbilityCooldowns[ability.id] = ability.cooldownRounds;
          } else {
            _bossAbilityCooldowns[ability.id] = cd - 1;
          }
        }
      }
    }

    _decrementBuffs();
  }

  bool _fireBossAbility(BossAbility ability, Enemy enemy) {
    switch (ability.effect) {
      case BossAbilityEffect.bonusDamage:
        final raw = (enemy.attack * ability.value / 100).round().clamp(1, 1000000000000000);
        // Physical abilities are Armor-gated; elemental abilities resist-gated.
        final dmg = mitigateIncoming(raw, ability.damageType, heroArmorValue);
        if (dmg > 0) {
          hero.takeDamage(dmg);
          _noteHeroDamageTaken(dmg);
          pendingFloats.add((value: dmg, isHeal: false, type: ability.damageType));
          battleLog.add('${ability.emoji} ${enemy.name}: ${ability.name}! ${hero.name} takes $dmg ${ability.damageType.label} dmg.');
          if (hero.currentHealth <= 0 && passiveTree.hasKeystone(PassiveBranch.guardian) && !_unbreakableUsed) {
            hero.currentHealth = 1;
            _unbreakableUsed = true;
            battleLog.add('💠 Unbreakable! ${hero.name} refuses to fall at 1 HP!');
          }
          if (hero.currentHealth <= 0 && endlessUpgrades.unbroken && !_unbrokenUsed) {
            hero.currentHealth = 1;
            _unbrokenUsed = true;
            battleLog.add('Unbroken! ${hero.name} clings to life at 1 HP!');
          }
          if (hero.currentHealth <= 0) { _battleDefeat(); return true; }
        }
      case BossAbilityEffect.dot:
        final rawPerRound = (enemy.attack * ability.value / 100).round().clamp(1, 1000000000000000);
        // Mitigate the DoT tick by type at application (Armor for physical,
        // resistance for elemental), consistent with basic hits and bursts.
        final perRound = mitigateIncoming(rawPerRound, ability.damageType, heroArmorValue).clamp(1, 1000000000000000);
        _heroDotRoundsLeft  = ability.dotRounds;
        _heroDotDmgPerRound = perRound;
        _heroDotType        = ability.damageType;
        battleLog.add('${ability.emoji} ${enemy.name}: ${ability.name}! ${hero.name} afflicted — $perRound ${ability.damageType.label} dmg/round × ${ability.dotRounds} rounds.');
      case BossAbilityEffect.stun:
        _heroStunRounds = ability.value;
        battleLog.add('${ability.emoji} ${enemy.name}: ${ability.name}! ${hero.name} stunned for ${ability.value} round${ability.value == 1 ? '' : 's'}!');
    }
    return false;
  }

  void _decrementBuffs() {
    if (_tempAttackBonusRounds > 0) {
      _tempAttackBonusRounds--;
      if (_tempAttackBonusRounds == 0) _tempAttackBonus = 0;
    }
    if (_tempAcBonusRounds > 0) {
      _tempAcBonusRounds--;
      if (_tempAcBonusRounds == 0) _tempAcBonus = 0;
    }
    if (_auraRoundsLeft > 0) {
      _auraRoundsLeft--;
      final wisTotal = hero.wisdom + inventory.totalOf(ItemStat.wisdom)
          + _setTotal(ItemStat.wisdom) + _gemTotal(ItemStat.wisdom);
      final wisHotMult = 1.0 + max(0.0, (wisTotal - 10) * 0.01);
      final scaledHeal = (_auraHealPerRound * wisHotMult).round().clamp(1, hero.maxHealth);
      hero.currentHealth = (hero.currentHealth + scaledHeal).clamp(0, hero.maxHealth);
      pendingFloats.add((value: scaledHeal, isHeal: true, type: DamageType.physical));
      battleLog.add('Aura: ${hero.name} regenerates $scaledHeal HP ($_auraRoundsLeft rounds left).');
      if (_auraRoundsLeft == 0) _auraHealPerRound = 0;
    }
    if (_enemyWeakenRounds > 0) {
      _enemyWeakenRounds--;
      if (_enemyWeakenRounds == 0) _enemyWeakenPct = 0;
    }
    if (_enemyVulnerableRounds > 0) {
      _enemyVulnerableRounds--;
      if (_enemyVulnerableRounds == 0) _enemyVulnerablePct = 0;
    }
    if (_enemySilenceRounds > 0) {
      _enemySilenceRounds--;
    }
    if (_enemyMissChanceRounds > 0) {
      _enemyMissChanceRounds--;
      if (_enemyMissChanceRounds == 0) _enemyMissChancePct = 0;
    }
    _roundsSinceLastStun++;
    if (_roundsSinceLastStun >= 5 && _stunApplicationCount > 0) {
      _stunApplicationCount = 0;
      _roundsSinceLastStun  = 0;
    }
  }

  /// Shared diminishing returns for ALL full crowd-control / 100%-negation
  /// effects (stun, freeze, disarm): full duration the 1st application, half the
  /// 2nd, immune the 3rd — resetting after 5 CC-free rounds. Returns the
  /// DR-adjusted duration (0 = resisted). Every hard-CC effect must route through
  /// this so nothing can perma-lock or perma-disarm an enemy.
  int _hardCcDuration(int baseDur) {
    if (_roundsSinceLastStun >= 5) {
      _stunApplicationCount = 0;
      _roundsSinceLastStun  = 0;
    }
    final drIdx = _stunApplicationCount.clamp(0, _stunDrMult.length - 1);
    final dur   = (baseDur * _stunDrMult[drIdx]).floor();
    if (dur > 0) {
      _stunApplicationCount++;
      _roundsSinceLastStun = 0;
    }
    return dur;
  }

  void _applyStun(int baseDur, String label) {
    final dur = _hardCcDuration(baseDur);
    if (dur <= 0) {
      battleLog.add('$label resists the stun! (DR immune)');
    } else {
      _enemyStunRounds = dur;
      battleLog.add('$label stunned for $dur turn(s)!');
    }
  }

  /// Enemy ATK reduction. A FULL disarm (≥100%) is hard CC and shares the
  /// [_hardCcDuration] diminishing returns with stun; partial weaken (<100%) is
  /// not CC and applies at full duration. Returns true if any weaken was applied.
  bool _applyEnemyWeaken(int pct, int baseDur, String label) {
    if (pct >= 100) {
      final dur = _hardCcDuration(baseDur);
      if (dur <= 0) {
        battleLog.add('$label resists the disarm! (DR immune)');
        return false;
      }
      _enemyWeakenPct    = 100;
      _enemyWeakenRounds = dur;
      battleLog.add('$label disarmed for $dur round(s)!');
      return true;
    }
    _enemyWeakenPct    = pct.clamp(0, 100);
    _enemyWeakenRounds = baseDur;
    battleLog.add('$label ATK reduced by $pct% for $baseDur rounds.');
    return true;
  }

  /// Silence fully locks out enemy ABILITIES, so it's hard CC and shares the
  /// [_hardCcDuration] diminishing returns with stun/disarm — can't be chained to
  /// keep a boss's abilities permanently disabled.
  void _applyEnemySilence(int baseDur, String label) {
    final dur = _hardCcDuration(baseDur);
    if (dur <= 0) {
      battleLog.add('$label shakes off the silence! (DR immune)');
    } else {
      _enemySilenceRounds = dur;
      battleLog.add('$label is silenced for $dur round(s)!');
    }
  }

  void enemyAttack() {
    final enemy = currentEnemy;
    if (enemy == null) return;
    // Enrage used to be 3 full attacks (≈ +200% burst) which could 1-2-shot a
    // full-HP hero from random spikes. Make it steadier: 2 attacks, each damped
    // (see _enrageDamageMult) so total ≈ +40% — a real threat, not a coin-flip.
    final attacks = _bossEnraged ? 2 : 1;
    for (int i = 0; i < attacks; i++) {
      _enemyTurn(enemy);
      if (hero.currentHealth <= 0) break;
    }
    if (_bossEnraged && attacks > 1) {
      battleLog.add('☠ ENRAGED — ${enemy.name} strikes twice!');
    }
    notifyListeners();
  }

  /// Cycle the hero's active damage type to the next available option.
  void cycleDamageType() {
    hero.cycleNextDamageType();
    notifyListeners();
    saveToLocal();
  }

  // ── Combat objective beacon ─────────────────────────────────────────────────
  // Captured on each campaign kill so the top-right beacon reveals the enemy you
  // just VANQUISHED and its new count — never the next enemy's count at the start
  // of a battle. The widget watches beaconSeq and shows this payload.
  int beaconSeq = 0;
  String beaconEnemyName = '';
  int beaconKills = 0;
  int? beaconKillTarget;
  bool beaconQuestTicked = false;
  String beaconQuestTitle = '';
  int beaconQuestProg = 0;
  int beaconQuestTarget = 0;

  void _fireObjectiveBeacon(Enemy enemy, int questBefore) {
    beaconEnemyName  = enemy.name;
    beaconKills      = bestiaryKillCount(enemy.id);
    beaconKillTarget = nextBestiaryMilestone(enemy.id);
    final q = currentAdventureQuest;
    final qNow = q != null ? adventureQuestProgress(q) : 0;
    beaconQuestTicked = q != null && qNow > questBefore;
    if (beaconQuestTicked && q != null) {
      beaconQuestTitle  = q.title;
      beaconQuestProg   = qNow;
      beaconQuestTarget = q.target;
    }
    beaconSeq++;
  }

  void _battleVictory(Enemy enemy) {
    _snapshotFight(enemyName: enemy.name, victory: true, enemy: enemy);
    // Snapshot the active quest's progress BEFORE this kill's counters update, so
    // the objective beacon can tell whether the quest ticked on this kill.
    final questProgBefore = currentAdventureQuest != null
        ? adventureQuestProgress(currentAdventureQuest!) : 0;
    // Clear ability cooldowns so the bar shows READY between battles
    _cooldownUntil.clear();
    _abilityRound = 0;
    // INT Lv25 — Arcane Efficiency: +40% gold; Merchant Scholar synergy: +15% more
    final arcaneBonus = endlessUpgrades.arcaneEfficiency ? 1.40 : 1.0;
    final merchantScholarBonus = endlessUpgrades.synergyMerchantScholar ? 1.15 : 1.0;
    final passiveGoldMult = 1.0 + (passiveTree.totalOf(PassiveEffect.goldFlat)
        + inventory.totalOf(ItemStat.goldPct)
        + _setTotal(ItemStat.goldPct)
        + _gemTotal(ItemStat.goldPct)
        + _masteryTotal(MasteryEffect.permanentGoldPct)) / 100.0;
    final goldSenseMult = _hasKeyword(ItemKeyword.goldSense) ? 1.15 : 1.0;
    final petGoldMult = 1.0 + (petGoldPct + skinGoldPct + auraGoldPct + artifactGoldPct + runeGoldPct + traitGoldPct) / 100.0;
    final bestiaryGoldMult = _isCampaignBattle ? bestiaryGoldBonus(enemy.id) : 1.0;
    final rc = RemoteConfigService.instance;
    var rewardGold =
        ((((enemy.level - activeTier * EnemyData.kTierLevelStep).clamp(1, 9999999) * 50 + 100) * (1.0 + activeTier * 0.15)) * endlessUpgrades.goldMultiplier * arcaneBonus * merchantScholarBonus * prestigeGoldMult * paragonGoldIncomeMult * prestigeGoldBattleMult * passiveGoldMult * goldSenseMult * petGoldMult * allyGoldMult * bestiaryGoldMult * rc.goldMult * guildCastleGoldMult)
            .round();
    // Felix: Bribe — double gold on the first kill of the battle
    if (_felixBribeActive) {
      _felixBribeActive = false;
      _allyAbilitiesUsed.add('coin_felix');
      rewardGold = rewardGold * 2;
      battleLog.add('🤑 Bribe pays off! Double gold earned!');
    }

    // CHA Lv10 — Rally Cry: +40% XP from every kill; passive XP bonus
    final rallyCryBonus = endlessUpgrades.rallyCry ? 1.4 : 1.0;
    final passiveXpMult = 1.0 + (passiveTree.totalOf(PassiveEffect.xpFlat)
        + inventory.totalOf(ItemStat.xpPct)
        + _setTotal(ItemStat.xpPct)
        + _gemTotal(ItemStat.xpPct)
        + _masteryTotal(MasteryEffect.permanentXpPct)) / 100.0;
    final itemChaMult = 1.0 + inventory.totalOf(ItemStat.charisma) * 0.02;
    final petXpMult = 1.0 + (petXpPct + skinXpPct + auraXpPct + artifactXpPct + runeXpPct + traitXpPct) / 100.0;
    final rewardExp =
        (((enemy.level * 20 + 40) *
                hero.xpMultiplier *
                endlessUpgrades.xpMultiplier *
                rallyCryBonus *
                prestigeXpMult *
                passiveXpMult *
                itemChaMult *
                petXpMult *
                allyXpMult *
                rc.xpMult)
            .round())
        .clamp(1, 1000000000000000);

    // Midas keystone: crit kills award double gold
    if (passiveTree.hasKeystone(PassiveBranch.merchant) && lastHeroCrit) {
      rewardGold *= 2;
      battleLog.add('✦ Midas! Crit kill — double gold!');
    }
    gold += rewardGold;
    _totalGoldEarned += rewardGold;
    AnalyticsService.instance.currencyEarned(
        'gold', rewardGold, enemy.namedBoss ? 'boss_kill' : 'kill');

    final prevLevel = hero.level;
    final prevHp    = hero.maxHealth;
    final prevStr   = hero.strength;
    final prevDex   = hero.dexterity;
    final prevCon   = hero.constitution;
    final prevInt   = hero.intelligence;
    final prevWis   = hero.wisdom;
    final prevCha   = hero.charisma;

    hero.gainExperience(rewardExp);
    _syncParagonLevels();

    if (hero.level > prevLevel) {
      audioService.playLevelUp();
      HapticFeedback.heavyImpact();
      // Each level raises the cap by 1 (up to 60) and grants that energy now —
      // fill the freshly-unlocked slot(s) immediately for every level gained.
      // Guarded so it never reduces over-cap energy from a ZCoin purchase.
      if (energy < maxEnergy) {
        energy = (energy + (hero.level - prevLevel)).clamp(0, maxEnergy);
      }
      final gains = <String>[];
      if (hero.strength     > prevStr) gains.add('STR');
      if (hero.dexterity    > prevDex) gains.add('DEX');
      if (hero.constitution > prevCon) gains.add('CON');
      if (hero.intelligence > prevInt) gains.add('INT');
      if (hero.wisdom       > prevWis) gains.add('WIS');
      if (hero.charisma     > prevCha) gains.add('CHA');
      lastLevelUp = LevelUpEvent(
        fromLevel: prevLevel,
        toLevel:   hero.level,
        hpBefore:  prevHp,
        hpAfter:   hero.maxHealth,
        statGains: gains,
      );
      AnalyticsService.instance.levelUp(hero.level, hero.heroClass.name);
      // First time reaching level 30 — class questline unlocks. Bring the player
      // to the Quests tab with a coach so they know this is how the ultimate
      // ability is earned (guided, like the Paragon reveal). Retries next level
      // if another coach is mid-show (only marks seen once it actually fires).
      if (hero.level >= 30 && !_classQuestlineNoticeSeen && pendingTutorial == null) {
        _classQuestlineNoticeSeen = true;
        _triggerTutorial(const SystemTutorial(
          stage: -4, navTab: 0, subTab: 'QUESTS', icon: '⭐',
          title: 'Ultimate Ability',
          howTo: 'Level 30 — your class questline is unlocked! Complete its '
              'challenges to earn your ULTIMATE ability, your class\'s most '
              'powerful skill. Track your progress and claim it here in Quests.',
        ));
      }
      // Paragon revealed at level 10 (points have banked since level 1). Takes
      // priority over the level-10 ability coach; the ability one retries next
      // level-up (its guard only marks "seen" when it actually fires).
      if (hero.level >= 10 && !_paragonTutorialSeen && pendingTutorial == null) {
        _paragonTutorialSeen = true;
        _triggerTutorial(const SystemTutorial(
          stage: -3, navTab: 0, subTab: 'PARAGON', icon: '🔥',
          title: 'Paragon Points',
          howTo: 'You\'ve quietly earned a Paragon Point every level since the '
              'start — now you can spend them! Paragon upgrades are permanent '
              'passive boosts to your hero. Spend your banked points here.',
        ));
      }
      // New active ability unlocked (levels 5/10/15/20/25) — coach it.
      _maybeTriggerAbilityTutorial();
    } else {
      lastLevelUp = null;
    }

    lastRewardGold = rewardGold;
    lastRewardExp  = rewardExp;
    lastItemDrop   = null;
    // Blood Drinker's old heal-on-kill was reworked into lifesteal (applied per
    // hit in heroAttack via prestigeLifestealPct), so there's nothing on-kill here.

    // Bloodlust keystone: kill → guaranteed crit on next attack
    if (passiveTree.hasKeystone(PassiveBranch.slayer)) {
      _bloodlustReady = true;
      battleLog.add('🩸 Bloodlust! Next attack will critically strike.');
    }

    // Bestiary: record kill for this enemy type
    bestiaryKills[enemy.id] = (bestiaryKills[enemy.id] ?? 0) + 1;

    // World Event: 15% chance to award tokens on any kill
    _refreshEventIfNeeded();
    if (_rng.nextInt(100) < 15) {
      final tokens = 1 + _rng.nextInt(3);
      eventTokens += tokens;
      battleLog.add('${WorldEventDef.forWeek().enemyEmoji} Event enemy slain! +$tokens token${tokens == 1 ? '' : 's'}');
    }

    // Shards: shardFlat passive gives bonus shards per kill; otherwise 0 from campaign
    final passiveShards = passiveTree.totalOf(PassiveEffect.shardFlat);
    if (passiveShards > 0 && _isCampaignBattle) {
      final boostedShards = (passiveShards
          * allyShardMult
          * (1 + traitShardPct / 100.0)).round().clamp(1, 9999);
      shards += boostedShards;
      lastShardDrop = boostedShards;
    } else {
      lastShardDrop = 0;
    }

    // Gem shard drops: 25% chance on normal kill (1-2 shards), boss guaranteed 3-8
    // CHA Lv25 — Fortune's Favour: 25% chance to double gem shard drops (40% with Shadow Merchant)
    final favourChance = endlessUpgrades.synergyShadowMerchant ? 40 : 25;
    // Gem shards: PvP only (removed from campaign drops)

    // Equipment drop
    final drop = ItemLootTable.tryDrop(enemy.level, _rng, tier: activeTier);
    if (drop != null) {
      lastItemDrop = drop;
      HapticFeedback.selectionClick();
      if (autoSalvageThreshold != null && drop.rarity.index <= autoSalvageThreshold!.index) {
        disenchantItems([drop]);
      } else if (autoEquipUpgrades && canEquip(drop)) {
        applyAutoLoot(drop);
        inventory.addToBag(drop);
      } else {
        inventory.addToBag(drop);
      }
      logLoot(drop.rarityLabel[0], '${drop.name} (${drop.rarityLabel})', detail: drop.slot.label);
      battleLog.add('Item dropped: ${drop.name} (${drop.rarityLabel})!');
      DebugLogger.log('item_drop', '${drop.rarityLabel} ${drop.name} stage=$campaignStageIndex hero_lv=${hero.level}');
      // Fire the Gear coach the instant the FIRST item lands — before the
      // stage-unlock coaches below, so it isn't perpetually deferred behind them
      // (which let several more items drop before it finally showed).
      _maybeTriggerGearTutorial();
    }
    // One-time epic starter gift: 4th enemy of the very first run (stage index 3)
    if (campaignStageIndex == 3 && _isCampaignBattle && !isCampaignReplay && !_epicStarterAwarded) {
      _epicStarterAwarded = true;
      const starterSlots = [ItemSlot.weapon, ItemSlot.helmet, ItemSlot.armor, ItemSlot.gloves, ItemSlot.boots, ItemSlot.ring, ItemSlot.amulet];
      final slot = starterSlots[_rng.nextInt(starterSlots.length)];
      final epicDrop = ItemLootTable.craftAt(slot, ItemRarity.epic, hero.level, _rng);
      lastItemDrop = epicDrop;
      inventory.addToBag(epicDrop);
      battleLog.add('✦ A gift from a past life: ${epicDrop.name} (Epic) found!');
      DebugLogger.log('item_drop', 'STARTER EPIC ${epicDrop.name} slot=${slot.name}');
    }

    // Legendary / Mythic drop on boss kills
    if (isBossStage) {
      final mythicDrop = ItemLootTable.tryDropMythic(hero.level, _rng, tier: activeTier);
      if (mythicDrop != null) {
        lastItemDrop = mythicDrop;
        inventory.addToBag(mythicDrop);
        battleLog.add('🔥 MYTHIC DROP: ${mythicDrop.name}!');
        DebugLogger.log('item_drop', 'MYTHIC ${mythicDrop.name} stage=$campaignStageIndex hero_lv=${hero.level}');
      }
      final legDrop = ItemLootTable.tryDropLegendary(hero.level, _rng, tier: activeTier);
      if (legDrop != null) {
        lastItemDrop = legDrop;
        inventory.addToBag(legDrop);
        battleLog.add('✦ LEGENDARY DROP: ${legDrop.name}!');
        DebugLogger.log('item_drop', 'LEGENDARY ${legDrop.name} stage=$campaignStageIndex hero_lv=${hero.level}');
      }
      // Set item drop: 0.3% chance on boss kills — extremely rare
      final setDrop = ItemLootTable.tryDropSet(hero.level, _rng, tier: activeTier);
      if (setDrop != null) {
        lastItemDrop = setDrop;
        inventory.addToBag(setDrop);
        battleLog.add('◈ SET ITEM DROP: ${setDrop.name}!');
        DebugLogger.log('item_drop', 'SET ${setDrop.name} stage=$campaignStageIndex hero_lv=${hero.level}');
      }
      // Unique class legendary drop: 2% chance on boss kills
      final uniqueDrop = UniqueItemsData.tryDropUnique(hero.level, _rng);
      if (uniqueDrop != null) {
        lastItemDrop = uniqueDrop;
        inventory.addToBag(uniqueDrop);
        final classTag = uniqueDrop.requiredClass != null
            ? ' [${uniqueDrop.requiredClass!.displayName} only]'
            : '';
        battleLog.add('★ UNIQUE DROP: ${uniqueDrop.name}$classTag!');
        DebugLogger.log('item_drop', 'UNIQUE ${uniqueDrop.name} stage=$campaignStageIndex hero_lv=${hero.level}');
      }
      // Artifact drop: 25% chance on campaign boss kills
      if (_isCampaignBattle && _rng.nextInt(100) < 25) {
        final artLv = (campaignStageIndex ~/ 5).clamp(1, 50);
        gainArtifact(artLv);
        battleLog.add('✦ Artifact found: ${lastArtifactDrop!.name}!');
      }
    }

    // Treasure Goblin loot: 2× legendary/set/unique drop chance (roll twice)
    if (_treasureGoblinActive) {
      _treasureGoblinActive = false;
      battleLog.add('💰 The Goblin\'s sack bursts open!');
      final legDrop = ItemLootTable.tryDropLegendary(hero.level, _rng, tier: activeTier)
          ?? ItemLootTable.tryDropLegendary(hero.level, _rng, tier: activeTier);
      if (legDrop != null) {
        lastItemDrop = legDrop;
        inventory.addToBag(legDrop);
        battleLog.add('💰 GOBLIN LOOT: ${legDrop.name} (Legendary)!');
        DebugLogger.log('item_drop', 'GOBLIN LEGENDARY ${legDrop.name} stage=$campaignStageIndex');
      }
      final setDrop = ItemLootTable.tryDropSet(hero.level, _rng, tier: activeTier)
          ?? ItemLootTable.tryDropSet(hero.level, _rng, tier: activeTier);
      if (setDrop != null) {
        lastItemDrop = setDrop;
        inventory.addToBag(setDrop);
        battleLog.add('💰 GOBLIN LOOT: ${setDrop.name} (Set)!');
        DebugLogger.log('item_drop', 'GOBLIN SET ${setDrop.name} stage=$campaignStageIndex');
      }
      final uniqueDrop = UniqueItemsData.tryDropUnique(hero.level, _rng)
          ?? UniqueItemsData.tryDropUnique(hero.level, _rng);
      if (uniqueDrop != null) {
        lastItemDrop = uniqueDrop;
        inventory.addToBag(uniqueDrop);
        final classTag = uniqueDrop.requiredClass != null
            ? ' [${uniqueDrop.requiredClass!.displayName} only]'
            : '';
        battleLog.add('💰 GOBLIN LOOT: ${uniqueDrop.name}$classTag (Unique)!');
        DebugLogger.log('item_drop', 'GOBLIN UNIQUE ${uniqueDrop.name} stage=$campaignStageIndex');
      }
    }

    // Essence: campaign kills now award essence base on stage; Gauntlet also adds its own
    if (_isCampaignBattle) {
      final baseEssence = isBossStage
          ? (3 + campaignStageIndex ~/ 5)
          : (1 + campaignStageIndex ~/ 10);
      final essencePctBonus = passiveTree.totalOf(PassiveEffect.essenceGain)
          + petEssenceGain + auraEssenceGain;
      final essenceMult = (1.0 + essencePctBonus / 100.0) * prestigeEssenceMult;
      final essenceEarned = (baseEssence * essenceMult).round().clamp(1, 9999);
      lastRewardEssence = essenceEarned;
      essence += essenceEarned;
    } else {
      lastRewardEssence = 0;
    }

    if (isBossStage) {
      final bossGold = (rewardGold * 2).round();
      gold += bossGold;
      battleLog.add('BOSS DEFEATED! Bonus: +$bossGold gold!');
    }

    battleLog.add('${enemy.name} was defeated! +$rewardGold gold  +$rewardExp XP'
        + (lastRewardEssence > 0 ? '  +$lastRewardEssence ✦' : ''));

    // Volatile Death affix: enemy explodes on death — ATK÷4 unavoidable damage
    if (_activeAffixes.contains(ZoneAffix.volatileDeath)) {
      final blast = (enemy.attack ~/ 4).clamp(1, 1000000000000000);
      hero.takeDamage(blast);
      _noteHeroDamageTaken(blast);
      battleLog.add('Volatile Death! Explosion deals $blast unavoidable damage.');
      if (hero.currentHealth <= 0 && passiveTree.hasKeystone(PassiveBranch.guardian) && !_unbreakableUsed) {
        hero.currentHealth = 1;
        _unbreakableUsed = true;
        battleLog.add('💠 Unbreakable! ${hero.name} refuses to fall at 1 HP!');
      }
      if (hero.currentHealth <= 0 && endlessUpgrades.unbroken && !_unbrokenUsed) {
        hero.currentHealth = 1;
        _unbrokenUsed = true;
        battleLog.add('Unbroken! ${hero.name} survives the blast at 1 HP!');
      }
      if (hero.currentHealth <= 0) {
        // Killed by explosion — defeat even though enemy is dead
        heroDefeated = true;
        currentEnemy = null;
        _battleDefeat();
        return;
      }
    }

    currentEnemy = null;

    // STR Lv25 — Savage Momentum: advantage on the very next attack roll
    if (endlessUpgrades.savageMomentum) _hasMomentum = true;

    // Post-battle HP recovery: flat 10% of max HP (CON no longer scales this).
    var conRegen = (hero.maxHealth * 10 / 100).round();
    // Fortitude upgrade: +1 flat regen per level as a minor secondary bonus
    conRegen += endlessUpgrades.flatDamageReduction;
    // Equipment / gem / set CON bonuses: +3 HP per point
    conRegen += inventory.totalOf(ItemStat.constitution) * 3;
    conRegen += _setTotal(ItemStat.constitution) * 3;
    conRegen += _gemTotal(ItemStat.constitution) * 3;
    conRegen += skinHpRegen; // aura HP regen is now a per-turn heal (see heroAttack)
    // Void Curse affix: halve all hero HP recovery
    if (_activeAffixes.contains(ZoneAffix.voidCurse)) {
      conRegen = (conRegen / 2).round();
    }
    final hpBefore = hero.currentHealth;
    hero.currentHealth = (hero.currentHealth + conRegen).clamp(0, hero.maxHealth);
    final hpRestored = hero.currentHealth - hpBefore;
    if (hpRestored > 0) {
      battleLog.add('${hero.name} recovers $hpRestored HP (${hero.currentHealth}/${hero.maxHealth}).');
    }

    // Daily + lifetime counters
    _dailyKills++;
    _dailyBattleWins++;
    if (isBossStage) _dailyBossKills++;
    _totalKills++;
    _totalBattleWins++;
    if (isBossStage) _totalBossKills++;
    if (hero.currentHealth == 1) _survivedAt1HP = true;
    // Objective beacon: reveal the just-slain enemy's bestiary count (and quest
    // progress if it ticked) — now that this kill's counters have updated.
    _fireObjectiveBeacon(enemy, questProgBefore);
    addSeasonXp(isBossStage ? 10 : 3);
    advanceWeekly('w_kills', 1);
    if (isBossStage) advanceWeekly('w_boss', 1);
    if (currentEnemy != null) logEnemy(currentEnemy!.name);
    // Rune drop: 10% on boss kills in campaign
    if (isBossStage) rollRuneDrop();

    // Bounty tracking
    _trackBountyProgress(BountyType.killEnemies, 1);
    if (currentEnemy != null) {
      final w = _weaknessForEnemy(currentEnemy!.id);
      if (w != null) _trackBountyProgress(_weaknessBountyType(w), 1);
    }
    if (_endlessMode) {
      _trackBountyProgress(BountyType.reachEndlessFloor, 1);
    }

    audioService.endBattleMusic();
    audioService.playVictory();
    _checkAchievements();
    checkAllyMilestones();

    // Victory resets mercy / loss streak
    _consecutiveLosses = 0;
    _mercyTokenActive  = false;
    DebugLogger.log('battle_win',
        'stage=$campaignStageIndex boss=$isBossStage gold=$rewardGold xp=$rewardExp prestige=$prestigeLevel hero_hp=${hero.currentHealth}/${hero.maxHealth}');

    if (_pvpMode) {
      currentEnemy = null;
      _pvpMode = false;
      lastBattleWasFinalVictory = false;
      _setLastAction('PvP victory! $rewardGold gold, $rewardExp XP.');
      saveToLocal();
      return;
    }

    if (_endlessMode) {
      _totalEndlessKills++;
      if (_endlessMilestones.contains(_totalEndlessKills)) {
        lastEndlessMilestone = _totalEndlessKills;
        final bonusGold = _totalEndlessKills * 75;
        gold += bonusGold;
        battleLog.add('★ MILESTONE: $_totalEndlessKills kills! +$bonusGold gold');
      } else {
        lastEndlessMilestone = null;
      }
      currentEnemy = null;
      battleLog.add('The enemy stirs again in the endless dark...');
      lastBattleWasFinalVictory = false;
      _setLastAction('Victory! $rewardGold gold, $rewardExp XP.');
      saveToLocal();
      return;
    }

    // Replay battles give rewards but must not advance the campaign stage.
    if (isCampaignReplay) {
      currentEnemy = null;
      lastBattleWasFinalVictory = false;
      _setLastAction('Victory! $rewardGold gold, $rewardExp XP.');
      saveToLocal();
      return;
    }

    // Campaign is infinite — always advance
    final wasFinalBoss = campaignStageIndex == CampaignData.stages.length - 1;
    // Only a genuinely-new player (never unlocked a tier) sees the first-kill
    // tutorial — the campaign resets to stage 0 on every tier-up, so without this
    // it would re-trigger each time you beat Tier 0.
    final wasFirstKill = campaignStageIndex == 0 && highestUnlockedTier == 0;
    checkBattleStars(campaignStageIndex, _battleTurnCount);
    final firstClearCrystals = isBossStage ? 5 : 1;
    zcoins += firstClearCrystals;
    battleLog.add('First clear bonus: +$firstClearCrystals 🪙');
    campaignStageIndex += 1;
    if (campaignStageIndex > campaignAllTimeHigh) campaignAllTimeHigh = campaignStageIndex;
    AnalyticsService.instance.stageReached(campaignStageIndex);
    if (isBossStage) AnalyticsService.instance.bossDefeated(campaignStageIndex - 1);
    addSeasonXp(5);
    advanceWeekly('w_stages', 1);
    if (wasFirstKill) endlessTutorialPending = true;
    lastBattleWasFinalVictory = false;

    // Note a new content-area unlock (first time only). Auto-campaign keeps
    // running — it only stops on death or a manual toggle; the notice is shown
    // without interrupting the run.
    // Fire the first time you reach a stage (guarded by _seenUnlockStages only —
    // not by campaignAllTimeHigh, which blocked the coaches on any character that
    // had already pushed deeper in a previous run, and broke "Replay Tutorials").
    if (_isCampaignBattle && !_seenUnlockStages.contains(campaignStageIndex)) {
      final unlockName = _unlockStageNames[campaignStageIndex];
      final tut = SystemTutorial.forStage(campaignStageIndex);
      // Fire for any stage that has a notice OR a tutorial — so early always-on
      // systems (Scores @1, Abilities @2) also get a coach, not just gated ones.
      if (unlockName != null || tut != null) {
        _seenUnlockStages.add(campaignStageIndex);
        if (unlockName != null) {
          pendingUnlockNotice = unlockName;
          AnalyticsService.instance.featureUnlocked(unlockName, campaignStageIndex);
        }
        // Guided onboarding: pause the auto-fight, navigate + coach.
        if (tut != null) _triggerTutorial(tut);
      }
    }
    // First-item (Gear) coach now fires right at the drop (above), so it lands
    // straight after your very first item instead of behind the stage coaches.

    // Set pending boss defeat message (first kill only)
    if (isBossStage && _isCampaignBattle) {
      final bossStageIdx = campaignStageIndex - 1; // just advanced past it
      final bossEnemy = EnemyData.enemyForStage(bossStageIdx);
      if (!seenBossDefeats.contains(bossEnemy.id)) {
        final lore = bossLoreFor(bossEnemy.id);
        if (lore != null) pendingBossDefeatMessage = lore.defeat;
      }
    }

    if (wasFinalBoss) {
      battleLog.add('The Omega falls. The curse is ended. A new age begins.');
      // Tier progression replaces rebirth: clearing the campaign at your highest
      // unlocked tier unlocks the next tier (harder enemies + better loot).
      // Level, Paragon, gear and currencies all persist — nothing resets.
      final finalStage = CampaignData.stages.length - 1; // the Omega stage
      if (activeTier == highestUnlockedTier && highestUnlockedTier < kMaxTier) {
        // Unlock the next tier and jump into it fresh. ONLY the new tier resets
        // to the start — the tier you just cleared keeps its progress (parked at
        // the Omega, replayable) so switching back doesn't lose your place.
        _campaignStageByTier[activeTier] = finalStage;
        highestUnlockedTier += 1;
        activeTier = highestUnlockedTier;
        lastTierUnlocked = highestUnlockedTier;
        // Head-start / instant-recall prestige nodes apply to the new tier.
        campaignStageIndex = prestigeHeadStart;
        _campaignStageByTier[activeTier] = campaignStageIndex;
      } else {
        // Replaying an already-maxed tier (or the top tier): loop THIS tier back
        // to the start to farm it again; other tiers are untouched.
        campaignStageIndex = prestigeHeadStart;
        _campaignStageByTier[activeTier] = campaignStageIndex;
      }
      gold += prestigeStartGold;
      hero.currentHealth = hero.maxHealth;
      lastBattleWasFinalVictory = true;
    } else {
      battleLog.add('${hero.name} advances to stage ${campaignStageIndex + 1}.');
    }
    _setLastAction('Victory! $rewardGold gold, $rewardExp XP.');
    saveToLocal();
  }

  void _battleDefeat() {
    // Capture the loss before currentEnemy is cleared — the #1 difficulty
    // signal for balance tuning (pair with stage_reached for clear rates).
    final lostTo = currentEnemy;
    _snapshotFight(enemyName: lostTo?.name ?? 'Enemy', victory: false, enemy: lostTo);
    if (lostTo != null) {
      final stage = _endlessMode
          ? endlessStageIndex
          : (isCampaignReplay ? _replayStageIndex : campaignStageIndex);
      AnalyticsService.instance.battleDefeat(
        stage: stage,
        enemyId: lostTo.id,
        isBoss: lostTo.namedBoss,
        heroLevel: hero.level,
      );
    }
    heroDefeated = true;
    _pvpMode = false;
    audioService.endBattleMusic();
    audioService.playDefeat();
    battleLog.add('${hero.name} was overwhelmed and must retreat.');
    currentEnemy = null;
    _cooldownUntil.clear();
    _abilityRound = 0;
    hero.healToFull();
    _consecutiveLosses++;
    if (_consecutiveLosses >= 3 && !_mercyTokenActive) {
      _mercyTokenActive = true;
      battleLog.add('Mercy Token granted — next fight will be easier.');
    }
    _setLastAction('Defeat! Upgrade your hero before venturing forth again.');
    notifyListeners();
    saveToLocal(); // persist cleared enemy so reloading never resumes a dead fight
  }

  void retreatBattle() {
    if (currentEnemy == null) return;
    battleLog.add('${hero.name} retreats from battle.');
    currentEnemy = null;
    _setLastAction('Battle retreated.');
  }

  void fightCampaign() {
    startBattle();
  }

  // ── Idle income ────────────────────────────────────────────────────────────

  /// Called every 5 s by the idle timer.  Silent — does not overwrite the
  /// battle-log lastAction so the player can still read combat messages.
  int get _effectiveIdleRate =>
      hero.idleRate + passiveTree.totalOf(PassiveEffect.idleFlat) + prestigeIdleBonus + petIdleRate;

  void generateIdleProgress() {
    idleProgress += _effectiveIdleRate;
    notifyListeners();
  }

  /// Sprite of the last defeated campaign enemy shown in the idle panel.
  String get idleEnemySpriteId {
    final defeatStage = (campaignStageIndex - 1).clamp(0, 9999);
    return EnemyData.spriteIdForStage(defeatStage);
  }

  /// Name of the last defeated campaign enemy shown in the idle panel.
  String get idleEnemyName {
    final defeatStage = (campaignStageIndex - 1).clamp(0, 9999);
    return EnemyData.enemyForStage(defeatStage).name;
  }

  /// Called automatically every 60 s (12 ticks × 5 s).  Awards gold, essence,
  /// and XP scaled to the last defeated campaign stage.
  void collectIdleRewards() {
    if (idleProgress == 0) return;

    // Gold
    final earned = (idleProgress * hero.goldRate * prestigeIdleMult * paragonGoldIncomeMult * waystoneMult * allyIdleMult * subIdleMult).round();
    gold += earned;
    if (earned > 0) AnalyticsService.instance.currencyEarned('gold', earned, 'idle');
    lastIdleGold = earned;
    _totalGoldEarned += earned;

    // Essence — 1 per 5 cleared stages, per full cycle
    final essenceBase = campaignStageIndex ~/ 5;
    if (essenceBase > 0) {
      final essencePctBonus = passiveTree.totalOf(PassiveEffect.essenceGain)
          + petEssenceGain + auraEssenceGain;
      final essenceMult = (1.0 + essencePctBonus / 100.0) * prestigeEssenceMult;
      lastIdleEssence = (essenceBase * essenceMult).round().clamp(1, 9999);
      essence += lastIdleEssence;
    } else {
      lastIdleEssence = 0;
    }

    // XP — scales with campaign progress; applies prestige and pet multipliers.
    // Preserves currentHealth so a level-up mid-battle doesn't silently full-heal the hero.
    final defeatStage = (campaignStageIndex - 1).clamp(0, 9999);
    final xpBase = (8 + defeatStage * 3).clamp(0, 9999);
    final xpMult = prestigeXpMult *
        (1.0 + (petXpPct + skinXpPct + auraXpPct + artifactXpPct + runeXpPct + traitXpPct) / 100.0);
    final xpEarned = (xpBase * xpMult).round().clamp(1, 99999);
    final hpSnapshot = hero.currentHealth;
    final inBattle = currentEnemy != null;
    hero.gainExperience(xpEarned);
    _syncParagonLevels();
    if (inBattle) hero.currentHealth = hpSnapshot;
    lastIdleXp = xpEarned;

    idleProgress = 0;
    _dailyIdleCollects++;
    _totalIdleCollects++;
    audioService.playClaim();
    _checkAchievements();
    final suffix = lastIdleEssence > 0 ? '  +$lastIdleEssence ✦  +$lastIdleXp XP' : '  +$lastIdleXp XP';
    _setLastAction('⚡ Idle: +$earned gold$suffix');
  }

  /// 0.0 → 1.0 fill of the current 60-second idle cycle.
  double get idleFillRatio {
    final rate = _effectiveIdleRate;
    return rate > 0 ? (idleProgress / (rate * 12)).clamp(0.0, 1.0) : 0.0;
  }

  /// Gold that will be awarded when the cycle completes.
  int get pendingIdleGold =>
      (idleProgress * hero.goldRate * prestigeIdleMult * paragonGoldIncomeMult * waystoneMult * allyIdleMult * subIdleMult).round();

  /// Sustained gold earned per minute at current idle rate.
  int get idleGoldPerMinute =>
      (_effectiveIdleRate * 12 * hero.goldRate * prestigeIdleMult * paragonGoldIncomeMult * waystoneMult * allyIdleMult).round();

  /// Essence that will be awarded when the current cycle completes (all multipliers applied).
  int get idleEssencePerCycle {
    final essenceBase = campaignStageIndex ~/ 5;
    if (essenceBase == 0) return 0;
    final essencePctBonus = passiveTree.totalOf(PassiveEffect.essenceGain)
        + petEssenceGain + auraEssenceGain;
    final essenceMult = (1.0 + essencePctBonus / 100.0) * prestigeEssenceMult;
    return (essenceBase * essenceMult).round().clamp(1, 9999);
  }

  /// XP that will be awarded when the current cycle completes (all XP multipliers applied).
  int get idleXpPerCycle {
    final defeatStage = (campaignStageIndex - 1).clamp(0, 9999);
    final xpBase = (10 + defeatStage * 5).clamp(0, 9999);
    if (xpBase == 0) return 0;
    final xpMult = prestigeXpMult *
        (1.0 + (petXpPct + skinXpPct + auraXpPct + artifactXpPct + runeXpPct + traitXpPct) / 100.0);
    return (xpBase * xpMult).round().clamp(1, 99999);
  }

  void purchaseUpgrade(Upgrade upgrade) {
    if (upgrade.isMaxed) {
      _setLastAction('${upgrade.name} is already maxed out');
      return;
    }
    if (gold < upgrade.cost) {
      _setLastAction('Not enough gold for ${upgrade.name}');
      return;
    }
    gold -= upgrade.cost;
    upgrade.applyTo(hero);
    _setLastAction('Purchased ${upgrade.name} level ${upgrade.level}');
    saveToLocal();
  }

  bool purchaseEndlessUpgrade(EndlessNode node) {
    final cost = endlessUpgrades.costFor(node);
    if (echoes < cost) return false;
    // WIS Lv25 — Frugal Mind: 25% chance the upgrade costs 0 echoes
    // Silver Tongue (CHA Lv5) 15% discount is already baked into costFor().
    if (!endlessUpgrades.frugalMind || _rng.nextInt(100) >= 25) {
      echoes -= cost;
    }
    endlessUpgrades.upgrade(node);
    notifyListeners();
    saveToLocal();
    return true;
  }


  // Bump when the save format changes in a way that needs migration on load.
  static const int kSaveVersion = 1;

  Map<String, dynamic> toJson() {
    return {
      '_savedAt': DateTime.now().toIso8601String(),
      '_saveVersion': kSaveVersion,
      'hero': hero.toJson(),
      'gold': gold,
      'shards': shards,
      'echoes': echoes,
      'idleProgress': idleProgress,
      'campaignStageIndex': campaignStageIndex,
      // Per-tier campaign progress (string keys for JSON), including the active
      // tier's live stage so it round-trips even if it wasn't stashed yet.
      'campaignStageByTier': (Map<int, int>.from(_campaignStageByTier)
            ..[activeTier] = campaignStageIndex)
          .map((k, v) => MapEntry(k.toString(), v)),
      'campaignAllTimeHigh': campaignAllTimeHigh,
      'lastAction': lastAction,
      'upgrades': upgrades.map((u) => u.toJson()).toList(),
      'dailyChallenges': dailyChallenges.map((c) => c.toJson()).toList(),
      'lastDailyDate':   _lastDailyDate,
      'resetHour':       resetHour,
      'resetHourChangedYear': _resetHourChangedYear,
      'towerBossesDefeated': _towerBossesDefeatedToday.toList(),
      'dailyKills':      _dailyKills,
      'dailyBattleWins': _dailyBattleWins,
      'dailyIdleCollects': _dailyIdleCollects,
      'dailyAbilityUses': _dailyAbilityUses,
      'dailyDamageDealt': _dailyDamageDealt,
      'dailyBossKills':  _dailyBossKills,
      'dailyItemEquipped': _dailyItemEquipped,
      'dungeonAttemptsUsed':  _dungeonAttemptsUsed,
      'gauntletAttemptsUsed': _gauntletAttemptsUsed,
      'bossRushAttemptsUsed': _bossRushAttemptsUsed,
      'currentEnemy': null, // never persist mid-battle state; always start fresh
      'battleLog': battleLog,
      'endlessUpgrades': endlessUpgrades.toJson(),
      'abilityScoreRanks': Map<String, int>.from(_abilityScoreRanks),
      'abilityRanks': Map<String, int>.from(_abilityRanks),
      'abilityAscension': Map<String, int>.from(_abilityAscension),
      'abilityBranches': Map<String, String>.from(abilityBranches),
      'abilityMilestoneChoices': Map<String, String>.from(_milestoneChoices),
      'prestigeLevel': prestigeLevel,
      'activeTier': activeTier,
      'highestUnlockedTier': highestUnlockedTier,
      'paragonLevelsGranted': _paragonLevelsGranted,
      'prestigeSouls': prestigeSouls,
      'prestigeShop': prestigeShop.toJson(),
      'subclassId': subclassId,
      'passiveTree': passiveTree.toJson(),
      'inventory': inventory.toJson(),
      'zcoins': zcoins,
      'speedTier': speedTier,
      'energy': energy,
      'energyRefillEpochMs': _energyRefillEpochMs,
      'dailyEnergyRefillsUsed': dailyEnergyRefillsUsed,
      'autoCampaign': autoCampaign,
      'seenUnlockStages': _seenUnlockStages.toList(),
      'lastAbilityTutorialLevel': _lastAbilityTutorialLevel,
      'paragonTutorialSeen': _paragonTutorialSeen,
      'ownedRunes': ownedRunes.toList(),
      'purchasedPacks': purchasedPacks.toList(),
      'ownedCosmetics': ownedCosmetics.toList(),
      'activeTitle': activeTitle,
      'activeNameColor': activeNameColor,
      'activeFrame': activeFrame,
      'isPremiumSubscriber': isPremiumSubscriber,
      'premiumExpiryMs': premiumExpiryMs,
      'isSpeedSubscriber': isSpeedSubscriber,
      'lastSubZcoinGrantMonth': lastSubZcoinGrantMonth,
      'speedSubExpiryMs': speedSubExpiryMs,
      'autoSalvageThreshold': autoSalvageThreshold?.name,
      'hapticsEnabled':      hapticsEnabled,
      'showDamageNumbers':   showDamageNumbers,
      'notificationsEnabled': notificationsEnabled,
      'reducedParticles':    reducedParticles,
      'autoEquipUpgrades': autoEquipUpgrades,
      'speedBoostExpiryMs': speedBoostExpiryMs,
      // Lifetime counters
      'totalKills':        _totalKills,
      'totalBattleWins':   _totalBattleWins,
      'totalBossKills':    _totalBossKills,
      'totalDamageDealt':  _totalDamageDealt,
      'totalGoldEarned':   _totalGoldEarned,
      'totalIdleCollects': _totalIdleCollects,
      'totalForges':       _totalForges,
      'totalDisenchants':  _totalDisenchants,
      'survivedAt1HP':     _survivedAt1HP,
      // Achievements
      'achievements': achievements.map((a) => a.toJson()).toList(),
      // Shop
      'shopDate':    _shopDate,
      'shopRerolls': _shopRerolls,
      'shopStock': _shopStock.map((i) => i.toJson()).toList(),
      if (_featuredDeal != null) 'featuredDeal': _featuredDeal!.toJson(),
      'featuredPurchased': _featuredPurchased,
      'dailyChestClaimed': dailyChestClaimed,
      'endlessTutorialPending': endlessTutorialPending,
      'visitedModeTabs':  visitedModeTabs.toList(),
      'seenZoneIntros':   seenZoneIntros.toList(),
      'seenBossIntros':   seenBossIntros.toList(),
      'seenBossDefeats':  seenBossDefeats.toList(),
      'equippedAuraId': equippedAuraId,
      'ownedAuraIds': ownedAuraIds.toList(),
      'equippedSkinId': equippedSkinId,
      'ownedSkinIds': ownedSkinIds.toList(),
      'equippedPremiumSkinId': equippedPremiumSkinId,
      'ownedPremiumSkinIds': ownedPremiumSkinIds.toList(),
      'equippedPetId': equippedPetId,
      'ownedPetIds': ownedPetIds.toList(),
      // PVP
      'pvpStamina':        pvpStamina,
      'pvpRefillsBought':  _pvpRefillsBought,
      'pvpDailyWins':      pvpDailyWins,
      'pvpDailyDamage':    pvpDailyDamage,
      'pvpDailyRewardClaimed': pvpDailyRewardClaimed,
      'totalPlaytimeSeconds': totalPlaytimeSeconds,
      'claimedMilestones': claimedMilestones.toList(),
      'abilityUseCounts': abilityUseCounts,
      'abilityAutoTriggers': abilityAutoTriggers,
      'stageStars': stageStars.toList(),
      'endlessPersonalBest': endlessPersonalBest,
      'gauntletModTiers': gauntletModTiers,
      'gauntletEndlessUnlocked': gauntletEndlessUnlocked,
      'seasonPassXp': seasonPassXp,
      'seasonPassTier': seasonPassTier,
      'seasonFreeClaimed': seasonFreeClaimed.toList(),
      'seasonPremiumClaimed': seasonPremiumClaimed.toList(),
      'seasonMonth': seasonMonth,
      'weeklyChallenges': weeklyChallenges.map((c) => c.toJson()).toList(),
      'weeklyWeekSeed': _weeklyWeekSeed,
      'lastLoginEpochMs': _lastLoginEpochMs,
      'collectedItemNames': collectedItemNames.toList(),
      'defeatedEnemyIds': defeatedEnemyIds.toList(),
      if (activeFlashEvent != null) 'activeFlashEvent': activeFlashEvent!.toJson(),
      'pvpRefillEpochMs':  _pvpRefillEpochMs,
      'pvpRating':         pvpRating,
      if (guildId != null) 'guildId': guildId,
      'guildCoins':        guildCoins,
      'pvpWins':           pvpWins,
      'pvpLosses':         pvpLosses,
      // Dungeon
      'deepestDungeonFloor': _deepestDungeonFloor,
      'dungeonHighestTier': _dungeonHighestTier,
      // Tutorial flags
      'tutorialWelcomeSeen':   tutorialWelcomeSeen,
      'tutorialBattleSeen':    tutorialBattleSeen,
      'tutorialIdleSeen':      tutorialIdleSeen,
      'tutorialUpgradeSeen':   tutorialUpgradeSeen,
      'tutorialCampaignSeen':  tutorialCampaignSeen,
      'tutorialDungeonSeen':   tutorialDungeonSeen,
      'tutorialGearSeen':      tutorialGearSeen,
      'tutorialForgeSeen':     tutorialForgeSeen,
      'tutorialRunesSeen':     tutorialRunesSeen,
      'tutorialArtifactsSeen': tutorialArtifactsSeen,
      'tutorialEndlessSeen':   tutorialEndlessSeen,
      'tutorialGauntletSeen':  tutorialGauntletSeen,
      'tutorialBossRushSeen':  tutorialBossRushSeen,
      'tutorialDailySeen':     tutorialDailySeen,
      'tutorialAbilitiesSeen': tutorialAbilitiesSeen,
      'tutorialPassivesSeen':  tutorialPassivesSeen,
      'tutorialBestiarySeen':  tutorialBestiarySeen,
      'tutorialPrestigeSeen':  tutorialPrestigeSeen,
      'tutorialMercsSeen':         tutorialMercsSeen,
      'tutorialBonusSeen':         tutorialBonusSeen,
      'tutorialCodexSeen':         tutorialCodexSeen,
      'tutorialAchievementsSeen':  tutorialAchievementsSeen,
      'tutorialItemDropSeen':      tutorialItemDropSeen,
      'tutorialEnergyEmptySeen':   tutorialEnergyEmptySeen,
      'tutorialFirstKillSeen':     tutorialFirstKillSeen,
      'tutorialAbilityUnlockSeen': tutorialAbilityUnlockSeen,
      // Expeditions
      'activeExpeditions': _activeExpeditions.map((e) => e.toJson()).toList(),
      // Stash tabs
      'bagTabsPurchased': bagTabsPurchased,
      // Gem system
      'gemShards': gemShards,
      // Class masteries
      'masteryLevels': Map<String, int>.from(masteryLevels),
      'gemBag': gemBag.map((g) => g.toJson()).toList(),
      'questsClaimed': Map<String, bool>.from(questsClaimed),
      'heroTitle': heroTitle,
      'totalAbilityUses': _totalAbilityUses,
      // Hero race + trait
      'heroRaceId':  heroRace?.name,
      'heroTraitId': heroTrait?.id.name,
      // Challenge modifier
      'activeModifierId': activeModifierId,
      // Bestiary
      'bestiaryKills': Map<String, int>.from(bestiaryKills),
      'claimedBestiaryChapters': _claimedBestiaryChapters.toList(),
      'claimedBestiaryMilestones': _claimedBestiaryMilestones.toList(),
      // Boss Rush
      'bossRushBestScore':   bossRushBestScore,
      'heroRenameCount':     heroRenameCount,
      'lastSeenPatchBuild':  lastSeenPatchBuild,
      'bossRushHighestTier': bossRushHighestTier,
      // Waystones
      'basicWaystoneCount': basicWaystoneCount,
      'grandWaystoneCount': grandWaystoneCount,
      'waystoneExpiresAtMs': waystoneExpiresAtMs,
      'activeWaystoneMult': _activeWaystoneMult,
      // Extra character slots (also stored globally but cache here for sync)
      'extraCharacterSlots': extraCharacterSlots,
      // Pet evolution
      'petEvolutionLevels': Map<String, int>.from(petEvolutionLevels),
      // Attack effects
      'ownedAttackEffects': ownedAttackEffects.toList(),
      'equippedAttackEffectId': equippedAttackEffectId,
      // Artifacts & mythril
      'mythril': mythril,
      'ownedArtifacts': ownedArtifacts.map((a) => a.toJson()).toList(),
      'artifactGrid': artifactGrid.map((k, v) => MapEntry(k.toString(), v)),
      'unlockedArtifactCells': _unlockedArtifactCells,
      // World Event
      'eventTokens':         eventTokens,
      'eventWeekSeed':       _eventWeekSeed,
      'eventRewardsClaimed': _eventRewardsClaimed.toList(),
      // Gauntlet
      'gauntletHighScore': gauntletHighScore,
      'lastGauntletModifierIds': lastGauntletModifierIds,
      'upgradesTabSeen': _upgradesTabSeen,
      'masteryTabSeen':  _masteryTabSeen,
      'gauntletHighestTier': gauntletHighestTier,
      'questItemsEquipped': _itemsEquipped,
      'questAbilitiesUpgraded': _abilitiesUpgraded,
      'classQuestlineNoticeSeen': _classQuestlineNoticeSeen,
      'ultimateUnlockedTutorialSeen': _ultimateUnlockedTutorialSeen,
      'artifactsUnlocked': artifactsUnlocked,
      'questPassivesUnlocked': _passivesUnlocked,
      'questGemsSocketed': _gemsSocketed,
      'questItemsForged': _itemsForged,
      'questExpeditionsCompleted': _expeditionsCompleted,
      'questTotalEssenceEarned': _totalEssenceEarned,
      'questArtifactsCollected': _artifactsCollected,
      // NPC Allies
      'allyLevels':   Map<String, int>.from(_allyLevels),
      'allyTalents':  Map<String, String>.from(_allyTalents),
      'dungeonClears': _dungeonClears,
      'bossRushClears': _bossRushClears,
      // Runes (dust merged into gemShards)
      'runeStockpile': Map<String, int>.from(_runeStockpile),
      'activeRunes': _activeRunes.map((k, v) => MapEntry(k.name, v?.toJson())),
      // Login streak
      'loginStreak':       loginStreak,
      'loginTodayClaimed': loginTodayClaimed,
      'lastLoginDate':     _lastLoginDate,
      // Ascension
      'ascensionLevel':  ascensionLevel,
      'ascensionPoints': ascensionPoints,
      'totalAscensionAp': totalAscensionAp,
      'ascensionNodes':  Map<String, int>.from(_ascensionNodes),
      // Daily bounties
      'bountyDaySeed': _bountyDaySeed,
      'bounties': _dailyBounties.map((b) => b.toJson()).toList(),
      // Timestamp — used for offline progress calculation on next load
      'savedAt': DateTime.now().toIso8601String(),
      'totalEndlessKills': _totalEndlessKills,
      // Rebirth challenge & boon
      'activeRebirthChallenge': activeRebirthChallenge.name,
      'boonXpMult':     _boonXpMult,
      'challengeGoldMult': _challengeGoldMult,
      'challengeHpPenalty': _challengeHpPenalty,
      'earnedPrestigeMilestones': _earnedPrestigeMilestones.toList(),
      'epicStarterAwarded': _epicStarterAwarded,
      'bestiaryMasteryAtk': _bestiaryMasteryAtk,
      'claimedStageStarRewards': _claimedStageStarRewards.toList(),
      'claimedStarMilestones':   _claimedStarMilestones.toList(),
      // Elemental Mastery & Ability Scores
      'towerShards':           towerShards,
      'elementalMasteryRanks': Map<String, int>.from(_elementalMasteryRanks),
    };
  }

  /// Migrate an older save map up to [kSaveVersion]. Currently a no-op (v1 is
  /// the first versioned format); add per-version transforms here as the schema
  /// evolves, e.g. `if (from < 2) { json['newKey'] = ...; }`.
  Map<String, dynamic> _migrateSave(Map<String, dynamic> json, int from) {
    // No structural migrations yet.
    return json;
  }

  void loadFromJson(Map<String, dynamic> json) {
    // Schema version: pre-versioned saves are treated as v1. Every field below
    // already loads defensively (?? defaults), so a save written by a NEWER app
    // still loads on an older client — it just ignores unknown keys. Run any
    // needed structural migrations before the field reads.
    final saveVersion = (json['_saveVersion'] as int?) ?? 1;
    if (saveVersion < kSaveVersion) {
      json = _migrateSave(json, saveVersion);
    }
    hero.loadFromJson(json['hero'] as Map<String, dynamic>);
    // Migrate the XP curve: recompute the level threshold from the new gentle
    // 1.08/level curve so saves made under the old steep 1.27 curve (which
    // plateaued heroes ~L30) adopt the corrected pacing. Idempotent for saves
    // already on the new curve.
    hero.experienceToNextLevel = HeroModel.expToNextForLevel(hero.level);
    hero.experience = hero.experience.clamp(0, hero.experienceToNextLevel - 1);
    gold = json['gold'] as int;
    // Essence merged into Shards — fold any legacy essence balance in on load.
    shards = ((json['shards'] as int?) ?? 0) + ((json['essence'] as int?) ?? 0);
    echoes = (json['echoes'] as int?) ?? 0;
    idleProgress = json['idleProgress'] as int;
    campaignStageIndex = json['campaignStageIndex'] as int;
    // Repair legacy saves that stalled past the final stage (old Abyss / pre-tier
    // rework): the campaign now loops per tier, so wrap them back to the start.
    if (campaignStageIndex >= CampaignData.stages.length) campaignStageIndex = 0;
    // Per-tier campaign progress. Older saves lack it — seed from the single
    // stage so the current tier at least resumes correctly.
    final cst = json['campaignStageByTier'] as Map<String, dynamic>?;
    _campaignStageByTier = cst == null
        ? {}
        : cst.map((k, v) => MapEntry(
            int.parse(k), (v as int).clamp(0, CampaignData.stages.length - 1)));
    campaignAllTimeHigh = (json['campaignAllTimeHigh'] as int?) ?? campaignStageIndex;
    lastAction = json['lastAction'] as String;

    upgrades
      ..clear()
      ..addAll((json['upgrades'] as List<dynamic>)
          .map((data) => Upgrade.fromJson(data as Map<String, dynamic>)));

    _lastDailyDate     = (json['lastDailyDate']   as String?) ?? '';
    resetHour = (json['resetHour'] as int?) ?? 0;
    _resetHourChangedYear = (json['resetHourChangedYear'] as String?) ?? '';
    _towerBossesDefeatedToday
      ..clear()
      ..addAll(((json['towerBossesDefeated'] as List<dynamic>?) ?? []).cast<String>());
    _dailyKills        = (json['dailyKills']       as int?) ?? 0;
    _dailyBattleWins   = (json['dailyBattleWins']  as int?) ?? 0;
    _dailyIdleCollects = (json['dailyIdleCollects'] as int?) ?? 0;
    _dailyAbilityUses  = (json['dailyAbilityUses'] as int?) ?? 0;
    _dailyDamageDealt  = (json['dailyDamageDealt'] as int?) ?? 0;
    _dailyBossKills    = (json['dailyBossKills']   as int?) ?? 0;
    _dailyItemEquipped    = (json['dailyItemEquipped']    as bool?) ?? false;
    _dungeonAttemptsUsed  = (json['dungeonAttemptsUsed']  as int?)  ?? 0;
    _gauntletAttemptsUsed = (json['gauntletAttemptsUsed'] as int?)  ?? 0;
    _bossRushAttemptsUsed = (json['bossRushAttemptsUsed'] as int?)  ?? 0;

    if (json['dailyChallenges'] != null) {
      dailyChallenges
        ..clear()
        ..addAll((json['dailyChallenges'] as List<dynamic>).map(
            (data) => DailyChallenge.fromJson(data as Map<String, dynamic>)));
    }
    _checkDailyReset();

    currentEnemy = json['currentEnemy'] != null
        ? Enemy.fromJson(json['currentEnemy'] as Map<String, dynamic>)
        : null;
    battleLog = json['battleLog'] != null
        ? List<String>.from(json['battleLog'] as List<dynamic>)
        : <String>[];
    if (json['endlessUpgrades'] != null) {
      endlessUpgrades.loadFromJson(
          json['endlessUpgrades'] as Map<String, dynamic>);
    }
    _abilityScoreRanks.clear();
    if (json['abilityScoreRanks'] != null) {
      (json['abilityScoreRanks'] as Map<String, dynamic>).forEach((k, v) {
        _abilityScoreRanks[k] = v as int;
      });
    }
    _abilityRanks.clear();
    if (json['abilityRanks'] != null) {
      (json['abilityRanks'] as Map<String, dynamic>).forEach((k, v) {
        _abilityRanks[k] = v as int;
      });
    }
    _abilityAscension.clear();
    if (json['abilityAscension'] != null) {
      (json['abilityAscension'] as Map<String, dynamic>).forEach((k, v) {
        _abilityAscension[k] = v as int;
      });
    }
    abilityBranches.clear();
    if (json['abilityBranches'] != null) {
      (json['abilityBranches'] as Map<String, dynamic>).forEach((k, v) {
        abilityBranches[k] = v as String;
      });
    }
    _milestoneChoices.clear();
    if (json['abilityMilestoneChoices'] != null) {
      (json['abilityMilestoneChoices'] as Map<String, dynamic>).forEach((k, v) {
        _milestoneChoices[k] = v as String;
      });
    }
    prestigeLevel = (json['prestigeLevel'] as int?) ?? 0;
    // Highest unlocked tier: now persisted and raised by clearing the campaign.
    // Legacy saves (no key) seed from prestigeLevel so existing rebirthed players
    // keep the tiers they already earned.
    highestUnlockedTier = ((json['highestUnlockedTier'] as int?)
            ?? (prestigeLevel > kMaxTier ? kMaxTier : prestigeLevel))
        .clamp(0, kMaxTier);
    // Active difficulty tier: default legacy saves to the highest unlocked tier.
    activeTier = ((json['activeTier'] as int?) ?? highestUnlockedTier)
        .clamp(0, highestUnlockedTier);
    prestigeSouls = (json['prestigeSouls'] as int?) ?? 0;
    // Paragon-per-level: seed to current level on first migration so existing
    // heroes don't get a retroactive point dump — they earn from here forward.
    _paragonLevelsGranted = (json['paragonLevelsGranted'] as int?) ?? hero.level;
    if (json['prestigeShop'] != null) {
      prestigeShop.loadFromJson(json['prestigeShop'] as Map<String, dynamic>);
    }
    subclassId = json['subclassId'] as String?;
    if (json['passiveTree'] != null) {
      passiveTree.loadFromJson(json['passiveTree'] as Map<String, dynamic>);
    }
    passiveTree.setElementalistNodes(hero.heroClass.info.classElement, hero.heroClass.info.secondaryElement);
    if (json['inventory'] is Map) {
      inventory.loadFromJson(Map<String, dynamic>.from(json['inventory'] as Map));
    }
    zcoins             = (json['zcoins'] as int?) ?? (json['crystals'] as int?) ?? 0;
    speedTier            = (json['speedTier']           as int?) ?? 1;
    energy               = (json['energy']              as int?) ?? kBaseEnergy;
    _energyRefillEpochMs = (json['energyRefillEpochMs'] as int?) ?? 0;
    dailyEnergyRefillsUsed = (json['dailyEnergyRefillsUsed'] as int?) ?? 0;
    tickEnergy();
    autoCampaign         = (json['autoCampaign']        as bool?) ?? false;
    _seenUnlockStages.clear();
    _seenUnlockStages.addAll(
      (json['seenUnlockStages'] as List<dynamic>?)?.cast<int>() ?? [],
    );
    _lastAbilityTutorialLevel = (json['lastAbilityTutorialLevel'] as int?) ?? 0;
    _paragonTutorialSeen = (json['paragonTutorialSeen'] as bool?) ?? false;
    ownedRunes.clear();
    ownedRunes.addAll((json['ownedRunes'] as List<dynamic>?)?.cast<String>() ?? []);
    purchasedPacks.clear();
    purchasedPacks.addAll((json['purchasedPacks'] as List<dynamic>?)?.cast<String>() ?? []);
    ownedCosmetics.clear();
    ownedCosmetics.addAll((json['ownedCosmetics'] as List<dynamic>?)?.cast<String>() ?? []);
    activeTitle = json['activeTitle'] as String?;
    activeNameColor = json['activeNameColor'] as String?;
    activeFrame = json['activeFrame'] as String?;
    isPremiumSubscriber = (json['isPremiumSubscriber'] as bool?) ?? false;
    premiumExpiryMs = (json['premiumExpiryMs'] as int?) ?? 0;
    isSpeedSubscriber = (json['isSpeedSubscriber'] as bool?) ?? false;
    speedSubExpiryMs = (json['speedSubExpiryMs'] as int?) ?? 0;
    lastSubZcoinGrantMonth = (json['lastSubZcoinGrantMonth'] as int?) ?? 0;
    final savedThreshold = json['autoSalvageThreshold'] as String?;
    autoSalvageThreshold = savedThreshold != null
        ? ItemRarity.values.firstWhere((r) => r.name == savedThreshold,
            orElse: () => ItemRarity.common)
        : ((json['autoDisenchantCommon'] as bool?) == true ? ItemRarity.common : null);
    hapticsEnabled     = (json['hapticsEnabled']      as bool?) ?? true;
    showDamageNumbers  = (json['showDamageNumbers']   as bool?) ?? true;
    notificationsEnabled = (json['notificationsEnabled'] as bool?) ?? true;
    reducedParticles   = (json['reducedParticles']    as bool?) ?? false;
    autoEquipUpgrades    = (json['autoEquipUpgrades']   as bool?) ?? false;
    speedBoostExpiryMs   = (json['speedBoostExpiryMs']  as int?) ?? 0;
    // Lifetime counters
    _totalKills        = (json['totalKills']        as int?)  ?? 0;
    _totalBattleWins   = (json['totalBattleWins']   as int?)  ?? 0;
    _totalBossKills    = (json['totalBossKills']     as int?)  ?? 0;
    _totalDamageDealt  = (json['totalDamageDealt']  as int?)  ?? 0;
    _totalGoldEarned   = (json['totalGoldEarned']   as int?)  ?? 0;
    _totalIdleCollects = (json['totalIdleCollects'] as int?)  ?? 0;
    _totalForges       = (json['totalForges']       as int?)  ?? 0;
    _totalDisenchants  = (json['totalDisenchants']  as int?)  ?? 0;
    _survivedAt1HP     = (json['survivedAt1HP']     as bool?) ?? false;
    _totalEndlessKills = (json['totalEndlessKills'] as int?)  ?? 0;
    // Achievements
    if (json['achievements'] != null) {
      final saved = {
        for (final e in (json['achievements'] as List<dynamic>))
          (e as Map<String, dynamic>)['id'] as String: e,
      };
      for (final a in achievements) {
        if (saved.containsKey(a.id)) a.loadFromJson(saved[a.id]!);
      }
    }
    _checkAchievements();
    // Shop
    _shopDate    = (json['shopDate']    as String?) ?? '';
    _shopRerolls = (json['shopRerolls'] as int?)    ?? 0;
    _shopStock.clear();
    if (json['shopStock'] != null) {
      _shopStock.addAll((json['shopStock'] as List<dynamic>)
          .map((e) => EquipmentItem.fromJson(e as Map<String, dynamic>)));
    }
    _featuredDeal = json['featuredDeal'] != null
        ? EquipmentItem.fromJson(json['featuredDeal'] as Map<String, dynamic>)
        : null;
    _featuredPurchased = (json['featuredPurchased'] as bool?) ?? false;
    dailyChestClaimed = (json['dailyChestClaimed'] as bool?) ?? false;
    endlessTutorialPending = (json['endlessTutorialPending'] as bool?) ?? false;
    visitedModeTabs
      ..clear()
      ..addAll(((json['visitedModeTabs'] as List<dynamic>?) ?? ['CAMPAIGN']).cast<String>());
    seenZoneIntros
      ..clear()
      ..addAll(((json['seenZoneIntros']  as List<dynamic>?) ?? []).cast<int>());
    seenBossIntros
      ..clear()
      ..addAll(((json['seenBossIntros']  as List<dynamic>?) ?? []).cast<String>());
    seenBossDefeats
      ..clear()
      ..addAll(((json['seenBossDefeats'] as List<dynamic>?) ?? []).cast<String>());
    equippedAuraId = json['equippedAuraId'] as String?;
    ownedAuraIds
      ..clear()
      ..addAll(((json['ownedAuraIds'] as List<dynamic>?) ?? []).cast<String>());
    equippedSkinId = json['equippedSkinId'] as String?;
    ownedSkinIds
      ..clear()
      ..addAll(((json['ownedSkinIds'] as List<dynamic>?) ?? []).cast<String>());
    equippedPremiumSkinId = json['equippedPremiumSkinId'] as String?;
    ownedPremiumSkinIds
      ..clear()
      ..addAll(((json['ownedPremiumSkinIds'] as List<dynamic>?) ?? []).cast<String>());
    equippedPetId = json['equippedPetId'] as String?;
    ownedPetIds
      ..clear()
      ..addAll(((json['ownedPetIds'] as List<dynamic>?) ?? []).cast<String>());
    _activeExpeditions.clear();
    final expList = json['activeExpeditions'] as List<dynamic>?;
    if (expList != null) {
      _activeExpeditions.addAll(
        expList.map((e) => Expedition.fromJson(e as Map<String, dynamic>)),
      );
    }
    bagTabsPurchased = (json['bagTabsPurchased'] as int?) ?? 0;
    inventory.bagCapacity = totalBagCapacity;
    // Rune Dust merged into Gem Shards — fold any legacy dust balance in on load.
    gemShards = ((json['gemShards'] as int?) ?? 0) + ((json['runeDust'] as int?) ?? 0);
    masteryLevels.clear();
    if (json['masteryLevels'] != null) {
      (json['masteryLevels'] as Map<String, dynamic>).forEach((k, v) {
        masteryLevels[k] = v as int;
      });
    }
    gemBag.clear();
    if (json['gemBag'] != null) {
      gemBag.addAll((json['gemBag'] as List<dynamic>)
          .map((e) => Gem.fromJson(e as Map<String, dynamic>)));
    }
    questsClaimed.clear();
    if (json['questsClaimed'] != null) {
      (json['questsClaimed'] as Map<String, dynamic>).forEach((k, v) {
        questsClaimed[k] = v as bool;
      });
    }
    heroTitle = json['heroTitle'] as String?;
    _totalAbilityUses = (json['totalAbilityUses'] as int?) ?? 0;
    activeModifierId = json['activeModifierId'] as String?;
    bestiaryKills.clear();
    if (json['bestiaryKills'] != null) {
      (json['bestiaryKills'] as Map<String, dynamic>).forEach((k, v) {
        bestiaryKills[k] = v as int;
      });
    }
    _claimedBestiaryChapters.clear();
    if (json['claimedBestiaryChapters'] is List) {
      for (final c in json['claimedBestiaryChapters'] as List) {
        _claimedBestiaryChapters.add(c as String);
      }
    }
    _claimedBestiaryMilestones.clear();
    if (json['claimedBestiaryMilestones'] is List) {
      for (final c in json['claimedBestiaryMilestones'] as List) {
        _claimedBestiaryMilestones.add(c as String);
      }
    }
    bossRushBestScore   = (json['bossRushBestScore']   as int?) ?? 0;
    heroRenameCount     = (json['heroRenameCount']     as int?) ?? 0;
    lastSeenPatchBuild  = (json['lastSeenPatchBuild']  as int?) ?? 0;
    bossRushHighestTier = (json['bossRushHighestTier'] as int?) ?? 0;
    basicWaystoneCount  = (json['basicWaystoneCount'] as int?) ?? 0;
    grandWaystoneCount  = (json['grandWaystoneCount'] as int?) ?? 0;
    waystoneExpiresAtMs = (json['waystoneExpiresAtMs'] as int?) ?? 0;
    _activeWaystoneMult = (json['activeWaystoneMult'] as num?)?.toDouble() ?? 1.0;
    extraCharacterSlots = (json['extraCharacterSlots'] as int?) ?? 0;
    petEvolutionLevels.clear();
    if (json['petEvolutionLevels'] != null) {
      (json['petEvolutionLevels'] as Map<String, dynamic>).forEach((k, v) {
        petEvolutionLevels[k] = v as int;
      });
    }
    ownedAttackEffects.clear();
    if (json['ownedAttackEffects'] != null) {
      ownedAttackEffects.addAll(
          (json['ownedAttackEffects'] as List<dynamic>).map((e) => e as String));
    }
    equippedAttackEffectId = json['equippedAttackEffectId'] as String?;
    mythril = (json['mythril'] as int?) ?? 0;
    ownedArtifacts.clear();
    if (json['ownedArtifacts'] != null) {
      for (final item in (json['ownedArtifacts'] as List<dynamic>)) {
        if (item is Map<String, dynamic>) {
          try { ownedArtifacts.add(Artifact.fromJson(item)); } catch (_) {}
        }
        // Legacy string-id entries are silently dropped (old save format)
      }
    }
    artifactGrid.clear();
    if (json['artifactGrid'] != null) {
      final raw = json['artifactGrid'] as Map<String, dynamic>;
      for (final e in raw.entries) {
        if (e.value != null) artifactGrid[int.parse(e.key)] = e.value as String;
      }
    }
    _unlockedArtifactCells = (json['unlockedArtifactCells'] as int?) ?? 9;
    final raceIdStr = json['heroRaceId'] as String?;
    heroRace = (raceIdStr != null
        ? HeroRace.values.where((r) => r.name == raceIdStr).firstOrNull
        : null) ?? HeroRace.human;
    final traitIdStr = json['heroTraitId'] as String?;
    if (traitIdStr != null) {
      heroTrait = HeroTrait.all.where(
          (t) => t.id.name == traitIdStr).firstOrNull;
    }
    _syncHeroHpPct(); // applies traitHpPct + artifactHpPct
    // World Event
    eventTokens    = (json['eventTokens']    as int?) ?? 0;
    _eventWeekSeed = (json['eventWeekSeed']  as int?) ?? 0;
    _eventRewardsClaimed.clear();
    if (json['eventRewardsClaimed'] != null) {
      _eventRewardsClaimed.addAll(
          (json['eventRewardsClaimed'] as List<dynamic>).cast<String>());
    }
    _refreshEventIfNeeded();
    // Gauntlet
    gauntletHighScore = (json['gauntletHighScore'] as int?) ?? 0;
    lastGauntletModifierIds = (json['lastGauntletModifierIds'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    _upgradesTabSeen = (json['upgradesTabSeen'] as bool?) ?? false;
    _masteryTabSeen  = (json['masteryTabSeen']  as bool?) ?? false;
    gauntletHighestTier = (json['gauntletHighestTier'] as int?) ?? 0;
    _itemsEquipped = (json['questItemsEquipped'] as int?) ?? 0;
    _abilitiesUpgraded = (json['questAbilitiesUpgraded'] as int?) ?? 0;
    _classQuestlineNoticeSeen = (json['classQuestlineNoticeSeen'] as bool?) ?? (hero.level >= 30);
    // Default true for existing saves that already have the Ultimate, so it
    // doesn't retroactively fire on a character that's long past the questline.
    _ultimateUnlockedTutorialSeen = (json['ultimateUnlockedTutorialSeen'] as bool?) ?? classUltimateUnlocked;
    artifactsUnlocked = (json['artifactsUnlocked'] as bool?) ?? ownedArtifacts.isNotEmpty;
    _passivesUnlocked = (json['questPassivesUnlocked'] as int?) ?? 0;
    _gemsSocketed = (json['questGemsSocketed'] as int?) ?? 0;
    _itemsForged = (json['questItemsForged'] as int?) ?? 0;
    _expeditionsCompleted = (json['questExpeditionsCompleted'] as int?) ?? 0;
    _totalEssenceEarned = (json['questTotalEssenceEarned'] as int?) ?? 0;
    _artifactsCollected = (json['questArtifactsCollected'] as int?) ?? 0;
    // NPC Allies — support both old format (unlockedAllies list) and new (allyLevels map)
    _allyLevels.clear();
    if (json['allyLevels'] != null) {
      final raw = json['allyLevels'] as Map<String, dynamic>;
      raw.forEach((k, v) => _allyLevels[k] = v as int);
    } else if (json['unlockedAllies'] != null) {
      // migrate from old save format
      for (final id in (json['unlockedAllies'] as List<dynamic>).cast<String>()) {
        _allyLevels[id] = 1;
      }
    }
    _allyTalents.clear();
    if (json['allyTalents'] != null) {
      final raw = json['allyTalents'] as Map<String, dynamic>;
      raw.forEach((k, v) => _allyTalents[k] = v as String);
    }
    _dungeonClears  = (json['dungeonClears']  as int?) ?? 0;
    _bossRushClears = (json['bossRushClears'] as int?) ?? 0;
    // Runes (dust merged into gemShards above)
    _runeStockpile.clear();
    if (json['runeStockpile'] != null) {
      final raw = json['runeStockpile'] as Map<String, dynamic>;
      raw.forEach((k, v) => _runeStockpile[k] = v as int);
    }
    if (json['activeRunes'] != null) {
      final raw = json['activeRunes'] as Map<String, dynamic>;
      for (final slot in RuneSlot.values) {
        final entry = raw[slot.name];
        if (entry != null) {
          final ar = ActiveRune.fromJson(entry as Map<String, dynamic>);
          _activeRunes[slot] = ar.isExpired ? null : ar;
        }
      }
    }
    // Login streak
    loginStreak       = (json['loginStreak']       as int?)    ?? 0;
    loginTodayClaimed = (json['loginTodayClaimed'] as bool?)   ?? false;
    _lastLoginDate    = (json['lastLoginDate']      as String?) ?? '';
    // Ascension
    ascensionLevel  = (json['ascensionLevel']  as int?) ?? 0;
    ascensionPoints = (json['ascensionPoints'] as int?) ?? 0;
    totalAscensionAp = (json['totalAscensionAp'] as int?) ?? 0;
    _ascensionNodes.clear();
    if (json['ascensionNodes'] != null) {
      final raw = json['ascensionNodes'] as Map<String, dynamic>;
      for (final e in raw.entries) {
        _ascensionNodes[e.key] = e.value as int;
      }
    }
    // Daily bounties
    _bountyDaySeed = (json['bountyDaySeed'] as int?) ?? 0;
    _dailyBounties = [];
    final bountyList = (json['bounties'] as List<dynamic>?) ?? [];
    for (final raw in bountyList) {
      final def = BountyPool.byId(raw['id'] as String?);
      if (def != null) {
        _dailyBounties.add(Bounty(
          def: def,
          progress: (raw['progress'] as int?) ?? 0,
          claimed: (raw['claimed'] as bool?) ?? false,
        ));
      }
    }
    _refreshBountiesIfNeeded();
    pvpStamina       = (json['pvpStamina']       as int?) ?? pvpMaxStamina;
    _pvpRefillsBought = (json['pvpRefillsBought'] as int?) ?? 0;
    pvpDailyWins      = (json['pvpDailyWins']     as int?) ?? 0;
    pvpDailyDamage    = (json['pvpDailyDamage']   as int?) ?? 0;
    pvpDailyRewardClaimed = (json['pvpDailyRewardClaimed'] as bool?) ?? false;
    _pvpRefillEpochMs = (json['pvpRefillEpochMs'] as int?) ?? 0;
    pvpRating        = (json['pvpRating']         as int?) ?? 1000;
    guildId          = json['guildId'] as String?;
    guildCoins       = (json['guildCoins']       as int?) ?? 0;
    totalPlaytimeSeconds = (json['totalPlaytimeSeconds'] as int?) ?? 0;
    claimedMilestones = (json['claimedMilestones'] as List<dynamic>?)
        ?.cast<String>().toSet() ?? {};
    abilityUseCounts = (json['abilityUseCounts'] as Map<String, dynamic>?)
        ?.map((k, v) => MapEntry(k, v as int)) ?? {};
    abilityAutoTriggers = (json['abilityAutoTriggers'] as Map<String, dynamic>?)
        ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ?? {};
    stageStars = (json['stageStars'] as List<dynamic>?)?.cast<int>().toSet() ?? {};
    endlessPersonalBest = (json['endlessPersonalBest'] as int?) ?? 0;
    gauntletModTiers = (json['gauntletModTiers'] as Map<String, dynamic>?)
        ?.map((k, v) => MapEntry(k, v as int)) ?? {};
    gauntletEndlessUnlocked = (json['gauntletEndlessUnlocked'] as bool?) ?? false;
    seasonPassXp = (json['seasonPassXp'] as int?) ?? 0;
    seasonPassTier = (json['seasonPassTier'] as int?) ?? 0;
    seasonFreeClaimed = (json['seasonFreeClaimed'] as List<dynamic>?)
        ?.cast<int>().toSet() ?? {};
    seasonPremiumClaimed = (json['seasonPremiumClaimed'] as List<dynamic>?)
        ?.cast<int>().toSet() ?? {};
    seasonMonth = (json['seasonMonth'] as int?) ?? 0;
    _weeklyWeekSeed = (json['weeklyWeekSeed'] as int?) ?? 0;
    weeklyChallenges = (json['weeklyChallenges'] as List<dynamic>?)
        ?.map((e) => WeeklyChallenge.fromJson(e as Map<String, dynamic>)).toList() ?? [];
    _lastLoginEpochMs = (json['lastLoginEpochMs'] as int?) ?? 0;
    collectedItemNames = (json['collectedItemNames'] as List<dynamic>?)
        ?.cast<String>().toSet() ?? {};
    defeatedEnemyIds = (json['defeatedEnemyIds'] as List<dynamic>?)
        ?.cast<String>().toSet() ?? {};
    activeFlashEvent = json['activeFlashEvent'] != null
        ? ActiveFlashEvent.fromJson(json['activeFlashEvent'] as Map<String, dynamic>)
        : null;
    pvpWins          = (json['pvpWins']           as int?) ?? 0;
    pvpLosses        = (json['pvpLosses']         as int?) ?? 0;
    tickPvpStamina();
    _deepestDungeonFloor    = (json['deepestDungeonFloor']  as int?)  ?? 0;
    _dungeonHighestTier     = (json['dungeonHighestTier']   as int?)  ?? 0;
    tutorialWelcomeSeen    = (json['tutorialWelcomeSeen']   as bool?) ?? false;
    tutorialBattleSeen     = (json['tutorialBattleSeen']    as bool?) ?? false;
    tutorialIdleSeen       = (json['tutorialIdleSeen']      as bool?) ?? false;
    tutorialUpgradeSeen    = (json['tutorialUpgradeSeen']   as bool?) ?? false;
    tutorialCampaignSeen   = (json['tutorialCampaignSeen']  as bool?) ?? false;
    tutorialDungeonSeen    = (json['tutorialDungeonSeen']   as bool?) ?? false;
    tutorialGearSeen       = (json['tutorialGearSeen']      as bool?) ?? false;
    tutorialForgeSeen      = (json['tutorialForgeSeen']     as bool?) ?? false;
    tutorialRunesSeen      = (json['tutorialRunesSeen']     as bool?) ?? false;
    tutorialArtifactsSeen  = (json['tutorialArtifactsSeen'] as bool?) ?? false;
    tutorialEndlessSeen    = (json['tutorialEndlessSeen']   as bool?) ?? false;
    tutorialGauntletSeen   = (json['tutorialGauntletSeen']  as bool?) ?? false;
    tutorialBossRushSeen   = (json['tutorialBossRushSeen']  as bool?) ?? false;
    tutorialDailySeen      = (json['tutorialDailySeen']     as bool?) ?? false;
    tutorialAbilitiesSeen  = (json['tutorialAbilitiesSeen'] as bool?) ?? false;
    tutorialPassivesSeen   = (json['tutorialPassivesSeen']  as bool?) ?? false;
    tutorialBestiarySeen   = (json['tutorialBestiarySeen']  as bool?) ?? false;
    tutorialPrestigeSeen   = (json['tutorialPrestigeSeen']  as bool?) ?? false;
    tutorialMercsSeen          = (json['tutorialMercsSeen']         as bool?) ?? false;
    tutorialBonusSeen          = (json['tutorialBonusSeen']         as bool?) ?? false;
    tutorialCodexSeen          = (json['tutorialCodexSeen']         as bool?) ?? false;
    tutorialAchievementsSeen   = (json['tutorialAchievementsSeen']  as bool?) ?? false;
    tutorialItemDropSeen       = (json['tutorialItemDropSeen']      as bool?) ?? false;
    tutorialEnergyEmptySeen    = (json['tutorialEnergyEmptySeen']   as bool?) ?? false;
    tutorialFirstKillSeen      = (json['tutorialFirstKillSeen']     as bool?) ?? false;
    tutorialAbilityUnlockSeen  = (json['tutorialAbilityUnlockSeen'] as bool?) ?? false;
    // Rebirth challenge & boon
    activeRebirthChallenge = RebirthChallenge.values.firstWhere(
      (e) => e.name == (json['activeRebirthChallenge'] as String? ?? 'none'),
      orElse: () => RebirthChallenge.none,
    );
    _boonXpMult        = (json['boonXpMult']        as num?)?.toDouble() ?? 1.0;
    _challengeGoldMult = (json['challengeGoldMult'] as num?)?.toDouble() ?? 1.0;
    _challengeHpPenalty = (json['challengeHpPenalty'] as int?) ?? 0;
    _earnedPrestigeMilestones
      ..clear()
      ..addAll((json['earnedPrestigeMilestones'] as List<dynamic>?)?.cast<int>() ?? []);
    _epicStarterAwarded  = (json['epicStarterAwarded']  as bool?) ?? false;
    _bestiaryMasteryAtk  = (json['bestiaryMasteryAtk']  as int?)  ?? 0;
    _claimedStageStarRewards
      ..clear()
      ..addAll((json['claimedStageStarRewards'] as List<dynamic>?)?.cast<int>() ?? []);
    _claimedStarMilestones
      ..clear()
      ..addAll((json['claimedStarMilestones'] as List<dynamic>?)?.cast<int>() ?? []);
    // Elemental Mastery & Ability Scores
    towerShards    = (json['towerShards']    as int?) ?? 0;
    _elementalMasteryRanks.clear();
    if (json['elementalMasteryRanks'] != null) {
      final raw = json['elementalMasteryRanks'] as Map<String, dynamic>;
      raw.forEach((k, v) => _elementalMasteryRanks[k] = v as int);
    }
    // Offline progress — compute idle earnings since last save
    offlineGoldEarned  = 0;
    offlineXpEarned    = 0;
    offlineEssenceEarned = 0;
    offlineSecondsAway = 0;
    offlineExpeditionsReady = 0;
    final savedAtStr = json['savedAt'] as String?;
    final savedAt = savedAtStr != null ? DateTime.tryParse(savedAtStr) : null;
    if (savedAt != null) {
      _applyOfflineProgress(savedAt.millisecondsSinceEpoch);
    }
    // Reset the warm-resume baseline to now so a 'resumed' event immediately
    // after a cold load can't re-apply the same offline period.
    _lastSaveMs = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
  }

  /// Offline idle-accumulation window, in hours. Base 24h; each unlocked
  /// "Deep Reserves" Paragon node adds +6h, up to +24h (a 48h maximum).
  int get idleCapHours {
    var h = 24;
    for (final id in const ['idle_reserve_1', 'idle_reserve_2', 'idle_reserve_3', 'idle_reserve_4']) {
      if (prestigeShop.isUnlocked(id)) h += 6;
    }
    return h;
  }

  /// Computes idle earnings for the time since [sinceMs] and stashes them in the
  /// offline* fields for the welcome-back dialog (gold/essence are awarded). Used
  /// on cold load (persisted savedAt) and warm resume ([computeOfflineOnResume]).
  void _applyOfflineProgress(int sinceMs) {
    offlineGoldEarned = 0; offlineXpEarned = 0; offlineEssenceEarned = 0;
    offlineSecondsAway = 0; offlineWasCapped = false;
    final capSecs = idleCapHours * 3600;
    final elapsedSecs = ((DateTime.now().millisecondsSinceEpoch - sinceMs) / 1000).floor();
    if (elapsedSecs >= 120 && idleGoldPerMinute > 0) {
      offlineWasCapped = elapsedSecs > capSecs;
      final cappedSecs = elapsedSecs.clamp(0, capSecs);
      final mins       = cappedSecs / 60.0;
      final earned     = (mins * idleGoldPerMinute).round();
      if (earned > 0) {
        gold             += earned;
        _totalGoldEarned += earned;
        offlineGoldEarned = earned;
        offlineSecondsAway = cappedSecs;
      }
      final xpEarned = (mins * idleXpPerCycle / 5.0).round();
      if (xpEarned > 0) offlineXpEarned = xpEarned;
      final essEarned = (mins * idleEssencePerCycle / 5.0).round();
      if (essEarned > 0) { essence += essEarned; offlineEssenceEarned = essEarned; }
    }
    offlineExpeditionsReady = activeExpeditions.where((e) {
      final el = DateTime.now().millisecondsSinceEpoch - e.startEpochMs;
      return el >= e.duration.ms;
    }).length;
  }

  /// Called when the app returns to the foreground (warm resume). Computes idle
  /// earnings accrued while backgrounded so the welcome-back dialog can show
  /// them, then resets the baseline so it isn't counted twice.
  void computeOfflineOnResume() {
    _applyOfflineProgress(_lastSaveMs);
    _lastSaveMs = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
  }

  Future<void> saveToLocal() async {
    // Never overwrite a save we failed to parse — that would turn a recoverable
    // load bug into permanent character loss.
    if (_saveBlocked) return;
    _lastSaveMs = DateTime.now().millisecondsSinceEpoch;
    updatePlaytime();
    checkMilestones();
    final data = toJson();
    await saveService.saveRaw(data, slot: _currentSlot);
    _maybeCloudSync(data);
  }

  void _maybeCloudSync(Map<String, dynamic> data) {
    try {
      if (!authService.isGoogleSignedIn) return;
      final now = DateTime.now();
      if (_lastCloudSyncAt != null &&
          now.difference(_lastCloudSyncAt!) < const Duration(minutes: 5)) return;
      _lastCloudSyncAt = now;
      final uid = authService.currentUser!.uid;
      cloudSaveService.syncSave(uid, _currentSlot, data);
    } catch (_) {}
  }

  /// Saves locally and forces an immediate cloud sync regardless of the
  /// 5-minute rate limit. Call this when the app is backgrounded.
  Future<void> saveAndSyncNow() async {
    _lastCloudSyncAt = null;
    await saveToLocal();
  }

  /// Delete a character slot everywhere: local save + backup + prestige key,
  /// AND the cloud save when signed in. The cloud save is a single document per
  /// account, so without this a deleted character would resurrect from the
  /// cloud on the next load.
  Future<void> deleteCharacterSlot(int slot) async {
    if (slot == _currentSlot) {
      // Stop the auto-save/idle timers from re-persisting the deleted hero, and
      // WIPE the in-memory state now so nothing (ability scores, unlocks, …) can
      // linger into the next character or get re-saved. Belt-and-suspenders on
      // top of the new-character reset.
      _slotLoaded = false;
      _resetToDefaults('The Warden', DndClass.fighter);
      _confirmedPrestigeLevel = 0;
      unawaited(saveService.savePrestigeLevel(slot, 0));
    }
    await saveService.deleteSlot(slot);
    try {
      if (authService.isGoogleSignedIn) {
        final uid = authService.currentUser?.uid;
        if (uid != null) await cloudSaveService.deleteSave(uid);
      }
    } catch (_) {
      // best-effort — the local delete already succeeded.
    }
  }

  Future<bool> loadFromLocal() async {
    final raw = await saveService.loadRaw(slot: _currentSlot);
    if (raw == null) {
      _setLastAction('No save found.');
      return false;
    }
    loadFromJson(raw);
    startPlaytimeTracking();
    _checkSeasonReset();
    _checkWeeklyReset();
    _checkComebackBonus();
    _checkFlashEvent();
    _setLastAction('Loaded progress.');
    return true;
  }

  DateTime? get lastCloudSyncAt => _lastCloudSyncAt;

  Future<bool> googleSignIn() async {
    final user = await authService.signInWithGoogle();
    if (user == null) return false;
    // Immediately check for a newer cloud save.
    final cloudTs = await cloudSaveService.fetchLastSyncTime(user.uid, _currentSlot);
    if (cloudTs != null) {
      final localTs = _parseLocalTimestamp(toJson());
      if (localTs == null || cloudTs.isAfter(localTs)) {
        final cloudRaw = await cloudSaveService.fetchSave(user.uid, _currentSlot);
        if (cloudRaw != null) {
          loadFromJson(cloudRaw);
          _setLastAction('Loaded cloud save.');
          notifyListeners();
          return true;
        }
      }
    }
    // No newer cloud save — push local up.
    _lastCloudSyncAt = DateTime.now();
    await cloudSaveService.syncSave(user.uid, _currentSlot, toJson());
    _setLastAction('Signed in. Cloud save synced.');
    notifyListeners();
    return true;
  }

  Future<void> googleSignOut() async {
    await authService.signOut();
    _setLastAction('Signed out.');
    notifyListeners();
  }

  /// Permanently delete the player's account and ALL their data — cloud save,
  /// PvP snapshot, leaderboard entry, every local save, and the Firebase auth
  /// user. Required for Google Play's account-deletion policy. Best-effort:
  /// each step is guarded so a failure in one still lets the others proceed.
  /// Returns true if the auth account itself was deleted.
  Future<bool> deleteAccount() async {
    final uid = authService.currentUser?.uid;
    if (uid != null) {
      await cloudSaveService.deleteSave(uid);
      await PvpService().deleteSnapshot(uid);
      await LeaderboardService.deleteEntry(uid);
    }
    await saveService.wipeAllLocal();
    final deleted = await authService.deleteAccount();
    return deleted;
  }

  Future<void> forceSyncToCloud() async {
    if (!authService.isGoogleSignedIn) return;
    final uid = authService.currentUser!.uid;
    _lastCloudSyncAt = DateTime.now();
    await cloudSaveService.syncSave(uid, _currentSlot, toJson());
    _setLastAction('Cloud save synced.');
    notifyListeners();
  }

  Future<void> saveToCloud() async {
    final user =
        authService.currentUser ?? await authService.signInAnonymously();
    if (user == null) {
      _setLastAction('Could not sign into cloud save.');
      return;
    }
    await cloudSaveService.syncSave(user.uid, _currentSlot, toJson());
    _setLastAction('Cloud save complete.');
  }

  Future<void> loadFromCloud() async {
    final user =
        authService.currentUser ?? await authService.signInAnonymously();
    if (user == null) {
      _setLastAction('Could not sign into cloud save.');
      return;
    }
    final raw = await cloudSaveService.fetchSave(user.uid, _currentSlot);
    if (raw == null) {
      _setLastAction('No cloud save available.');
      return;
    }
    loadFromJson(raw);
    _setLastAction('Loaded progress from cloud save.');
  }
}

class GameStateProvider extends InheritedNotifier<GameState> {
  const GameStateProvider({
    super.key,
    required GameState gameState,
    required super.child,
  }) : super(notifier: gameState);

  static GameState of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<GameStateProvider>();
    assert(provider != null, 'GameStateProvider not found in widget tree');
    return provider!.notifier!;
  }

  /// Null-safe lookup — for widgets that may render outside a provider
  /// (e.g. the PvP sim / dev preview screens).
  static GameState? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GameStateProvider>()?.notifier;
}
