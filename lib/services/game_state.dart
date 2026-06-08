import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/widgets.dart';
import '../data/ability_data.dart';
import '../data/campaign_data.dart';
import '../data/world_zone_data.dart';
import '../models/world_zone.dart';
import '../models/dnd_class.dart';
import '../models/campaign_stage.dart';
import '../data/enemy_data.dart';
import '../data/game_data.dart';
import '../models/equipment.dart';
import '../models/hero_ability.dart';
import '../models/passive_tree.dart';
import '../models/daily_challenge.dart';
import '../data/daily_challenge_generator.dart';
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
import '../models/gem.dart';
import '../models/expedition.dart';
import '../models/class_mastery.dart';
import '../data/class_mastery_data.dart';
import '../models/class_quest.dart';
import '../data/class_quest_data.dart';
import '../models/hero_race.dart';
import '../models/hero_trait.dart';
import '../models/challenge_modifier.dart';
import '../data/bestiary_data.dart';
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
import '../services/audio_service.dart';
import '../services/auth_service.dart';
import '../services/steam_service.dart';
import '../services/iap_service.dart';
import '../services/cloud_save_service.dart';
import '../services/save_service.dart';

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
    _iapService = IapService(grantCrystals);
    _iapService.init();
    steamService.init();
    _autoSaveTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) { if (_slotLoaded) saveToLocal(); },
    );
    // Idle income — ticks every 5 s, collects every 12th tick (60 s cycle).
    _idleTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) {
        if (!_slotLoaded) return;
        generateIdleProgress();
        _idleTickCount++;
        if (_idleTickCount >= 12) {
          _idleTickCount = 0;
          collectIdleRewards();
        }
      },
    );
  }

  int _currentSlot = 0;
  bool _slotLoaded = false;
  bool _endlessMode = false;

  // Per-battle perk state — reset at the start of every fight
  // _hasMomentum is NOT reset by _resetBattlePerks: it's set on kill and
  // consumed on the next attack roll, so it must survive the battle boundary.
  bool _hasMomentum         = false; // STR: Savage Momentum
  bool _unbrokenUsed        = false; // CON: Unbroken
  bool _battleAwarenessUsed = false; // WIS: Battle Awareness

  // Affix system
  List<ZoneAffix> _activeAffixes = [];
  int _attackRoundCounter = 0; // Time Fracture: tracks hero attack count
  int _deathSpiralRounds  = 0; // Death Spiral: rounds of drain elapsed

  // Equipment
  final EquipmentInventory inventory = EquipmentInventory();
  EquipmentItem? lastItemDrop;

  void equipItem(EquipmentItem item) {
    inventory.equip(item);
    _dailyItemEquipped = true;
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
      final candidates = inventory.bag.where((i) => i.slot == slot).toList();
      if (candidates.isEmpty) continue;
      final current = inventory.equipped[slot];
      final best = candidates.reduce((a, b) =>
          _itemScore(a) >= _itemScore(b) ? a : b);
      if (current == null || _itemScore(best) > _itemScore(current)) {
        inventory.equip(best);
        _dailyItemEquipped = true;
      }
    }
    notifyListeners();
    saveToLocal();
  }

  int _itemScore(EquipmentItem item) =>
      item.bonuses.fold(0, (sum, b) => sum + b.value);

  bool reforgeItem(EquipmentItem item) {
    if (!ItemLootTable.canReforge(item.rarity)) return false;
    final cost = ItemLootTable.reforgeCost(item.rarity);
    if (gold < cost.gold || shards < cost.shards) return false;
    gold   -= cost.gold;
    shards -= cost.shards;
    ItemLootTable.rerollBonuses(item, hero.level, _rng);
    notifyListeners();
    saveToLocal();
    return true;
  }

  void discardBagItem(int index) {
    inventory.discardFromBag(index);
    notifyListeners();
    saveToLocal();
  }

  // ── Premium cosmetics ──────────────────────────────────────────────────────
  int crystals = 0;
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
    crystals += amount;
    notifyListeners();
    saveToLocal();
  }

  bool purchaseAura(String auraId) {
    final aura = kAuraCatalog.where((a) => a.id == auraId).firstOrNull;
    if (aura == null) return false;
    if (ownedAuraIds.contains(auraId)) return false;
    if (!kDebugMode && crystals < aura.crystalCost) return false;
    if (!kDebugMode) crystals -= aura.crystalCost;
    ownedAuraIds.add(auraId);
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
    if (!kDebugMode && crystals < skin.crystalCost) return false;
    if (!kDebugMode) crystals -= skin.crystalCost;
    ownedSkinIds.add(skinId);
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

  int get _skinBonus => equippedSkin?.bonusValue ?? 0;
  bool _hasSkinBonus(PetBonusType t) => equippedSkin?.bonusType == t;

  int get skinGoldPct     => _hasSkinBonus(PetBonusType.goldPct)     ? _skinBonus : 0;
  int get skinXpPct       => _hasSkinBonus(PetBonusType.xpPct)       ? _skinBonus : 0;
  int get skinHpRegen     => _hasSkinBonus(PetBonusType.hpRegen)     ? _skinBonus : 0;
  int get skinAttackBonus => _hasSkinBonus(PetBonusType.attackBonus) ? _skinBonus : 0;
  int get skinArmor       => _hasSkinBonus(PetBonusType.armor)       ? _skinBonus : 0;
  int get skinDamage      => _hasSkinBonus(PetBonusType.damage)      ? _skinBonus : 0;

  // ── Aura bonuses ───────────────────────────────────────────────────────────

  HeroAura? get _equippedAura {
    if (equippedAuraId == null) return null;
    try { return kAuraCatalog.firstWhere((a) => a.id == equippedAuraId); }
    catch (_) { return null; }
  }

  bool _hasAuraBonus(PetBonusType t) => _equippedAura?.bonusType == t;
  int  get _auraBonus                => _equippedAura?.bonusValue ?? 0;

  int get auraGoldPct     => _hasAuraBonus(PetBonusType.goldPct)     ? _auraBonus : 0;
  int get auraXpPct       => _hasAuraBonus(PetBonusType.xpPct)       ? _auraBonus : 0;
  int get auraHpRegen     => _hasAuraBonus(PetBonusType.hpRegen)     ? _auraBonus : 0;
  int get auraAttackBonus => _hasAuraBonus(PetBonusType.attackBonus) ? _auraBonus : 0;
  int get auraArmor       => _hasAuraBonus(PetBonusType.armor)       ? _auraBonus : 0;
  int get auraDamage      => _hasAuraBonus(PetBonusType.damage)      ? _auraBonus : 0;
  int get auraShards      => _hasAuraBonus(PetBonusType.shardBonus)  ? _auraBonus : 0;
  int get auraDodgeChance => _hasAuraBonus(PetBonusType.dodgeChance) ? _auraBonus : 0;
  int get auraEssenceGain => _hasAuraBonus(PetBonusType.essenceGain) ? _auraBonus : 0;

  // ── Active set bonuses ─────────────────────────────────────────────────────
  int inventorySetTotal(ItemStat stat) => _setTotal(stat);
  int inventoryGemTotal(ItemStat stat) => _gemTotal(stat);

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

  int get _petBonus => _evolvedPetBonus(equippedPet?.bonusValue ?? 0, equippedPet?.id);
  bool _hasPetBonus(PetBonusType t) => equippedPet?.bonusType == t;

  int get petGoldPct     => _hasPetBonus(PetBonusType.goldPct)     ? _petBonus : 0;
  int get petXpPct       => _hasPetBonus(PetBonusType.xpPct)       ? _petBonus : 0;
  int get petHpRegen     => _hasPetBonus(PetBonusType.hpRegen)     ? _petBonus : 0;
  int get petIdleRate    => _hasPetBonus(PetBonusType.idleRate)     ? _petBonus : 0;
  int get petAttackBonus => _hasPetBonus(PetBonusType.attackBonus) ? _petBonus : 0;
  int get petArmor       => _hasPetBonus(PetBonusType.armor)       ? _petBonus : 0;
  int get petDamage      => _hasPetBonus(PetBonusType.damage)      ? _petBonus : 0;
  int get petShards      => _hasPetBonus(PetBonusType.shardBonus)  ? _petBonus : 0;

  bool purchasePet(String petId) {
    final pet = kPetCatalog.where((p) => p.id == petId).firstOrNull;
    if (pet == null) return false;
    if (ownedPetIds.contains(petId)) return false;
    if (!kDebugMode && crystals < pet.crystalCost) return false;
    if (!kDebugMode) crystals -= pet.crystalCost;
    ownedPetIds.add(petId);
    _setLastAction('${pet.emoji} ${pet.name} joined your party!');
    notifyListeners();
    saveToLocal();
    return true;
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

  void recordPvpResult(bool won) {
    if (won) {
      pvpWins++;
    } else {
      pvpLosses++;
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
        + inventory.totalOf(ItemStat.dexterity)
        + petArmor + skinArmor
        + _setTotal(ItemStat.armorClass) + _setTotal(ItemStat.dexterity),
    rating:  pvpRating,
    wins:    pvpWins,
    losses:  pvpLosses,
  );

  // ── Gem system ─────────────────────────────────────────────────────────────
  int gemShards = 0;
  final List<Gem> gemBag = []; // crafted but unsocketed gems
  static const int gemBagMax = 30;

  int _gemTotal(ItemStat stat) {
    return inventory.equipped.values
        .where((item) => item.gem?.stat == stat)
        .fold(0, (sum, item) => sum + (item.gem?.value ?? 0));
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
    item.gem = null; // gem is destroyed
    notifyListeners();
    saveToLocal();
  }

  // ── Stash tabs ─────────────────────────────────────────────────────────────
  int bagTabsPurchased = 0;
  static const List<int> stashTabCosts = [50, 100, 200, 400]; // crystals per tab (4 extra tabs max)
  int get stashTabCount    => 1 + bagTabsPurchased;
  int get totalBagCapacity => 20 * stashTabCount;
  bool get canBuyStashTab  => bagTabsPurchased < stashTabCosts.length;
  int? get nextStashTabCost => canBuyStashTab ? stashTabCosts[bagTabsPurchased] : null;

  bool purchaseStashTab() {
    if (!canBuyStashTab) return false;
    final cost = stashTabCosts[bagTabsPurchased];
    if (!kDebugMode && crystals < cost) return false;
    if (!kDebugMode) crystals -= cost;
    bagTabsPurchased++;
    inventory.bagCapacity = totalBagCapacity;
    notifyListeners();
    saveToLocal();
    return true;
  }

  // ── Expeditions ────────────────────────────────────────────────────────────
  Expedition? activeExpedition;

  bool startExpedition(ExpeditionType type, ExpeditionDuration duration) {
    if (activeExpedition != null) return false;
    activeExpedition = Expedition(
      type: type,
      duration: duration,
      startEpochMs: DateTime.now().millisecondsSinceEpoch,
    );
    notifyListeners();
    saveToLocal();
    return true;
  }

  Map<String, int> collectExpedition() {
    final e = activeExpedition;
    if (e == null || !e.isComplete) return {};
    final rewards = _expeditionRewards(e);
    gold    += rewards['gold']    ?? 0;
    shards  += rewards['shards']  ?? 0;
    essence += rewards['essence'] ?? 0;
    activeExpedition = null;
    notifyListeners();
    saveToLocal();
    return rewards;
  }

  Map<String, int> _expeditionRewards(Expedition e) {
    final lvl  = hero.level;
    final mult = e.duration.mult;
    return switch (e.type) {
      ExpeditionType.goldRun      => {'gold': (100 + lvl * 50) * mult},
      ExpeditionType.shardHunt    => {'shards': (5 + lvl ~/ 2) * mult},
      ExpeditionType.essenceDelve => {'essence': (3 + lvl ~/ 3) * mult},
      ExpeditionType.relicSearch  => {
        'gold':   (50  + lvl * 25) * mult,
        'shards': (2   + lvl ~/ 4) * mult,
      },
    };
  }

  Map<String, int> previewExpeditionRewards(ExpeditionType type, ExpeditionDuration duration) =>
      _expeditionRewards(Expedition(type: type, duration: duration, startEpochMs: 0));

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

  static String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  void _checkDailyReset() {
    final today = _dateKey(DateTime.now());
    if (_lastDailyDate == today) return;
    _lastDailyDate    = today;
    _dailyKills       = 0;
    _dailyBattleWins  = 0;
    _dailyIdleCollects = 0;
    _dailyAbilityUses = 0;
    _dailyDamageDealt = 0;
    _dailyBossKills   = 0;
    _dailyItemEquipped = false;
    dailyChestClaimed  = false;
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
      case DailyChallengeType.equipItem:   return _dailyItemEquipped ? 1 : 0;
      case DailyChallengeType.reachGold:   return gold;
    }
  }

  void claimDailyChallenge(int index) {
    if (index < 0 || index >= dailyChallenges.length) return;
    final c = dailyChallenges[index];
    if (c.claimed) return;
    if (getDailyProgress(c.type) < c.target) return;
    c.claimed = true;
    gold    += c.rewardGold;
    shards  += c.rewardShards;
    essence += c.rewardEssence;
    _setLastAction('Claimed: ${c.title}! +${c.rewardGold}g +${c.rewardShards}◆ +${c.rewardEssence} essence');
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

  // Weakness attack bonus: +10% ATK if this enemy has a bestiary entry and has been discovered
  double bestiaryWeaknessBonus(String enemyId) =>
      bestiaryDiscovered(enemyId) && bestiaryFor(enemyId) != null ? 1.10 : 1.0;

  // Chapter completion: all 5 enemies in a category killed ≥1 time
  bool isBestiaryChapterComplete(String category) {
    final entries = kBestiaryEntries.where((e) => e.category == category);
    return entries.every((e) => bestiaryDiscovered(e.enemyId));
  }

  // Permanent ATK bonus from completed bestiary chapters (+1 per chapter)
  int get bestiaryChapterBonus {
    final categories = kBestiaryEntries.map((e) => e.category).toSet();
    return categories.where(isBestiaryChapterComplete).length;
  }

  // Boss Rush best score — persisted across sessions
  int bossRushBestScore = 0;

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
    if (!kDebugMode && crystals < cost) return false;
    if (!kDebugMode) crystals -= cost;
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
  int extraCharacterSlots = 0; // 0–2, stored globally in SharedPrefs

  bool buyExtraCharacterSlot() {
    if (extraCharacterSlots >= 2) return false;
    if (!kDebugMode && crystals < 100) return false;
    if (!kDebugMode) crystals -= 100;
    extraCharacterSlots++;
    SaveService.setExtraSlots(extraCharacterSlots);
    notifyListeners();
    saveToLocal();
    return true;
  }

  // ── Pet Evolution ───────────────────────────────────────────────────────────
  final Map<String, int> petEvolutionLevels = {}; // petId -> 0,1,2

  int petEvolutionLevel(String petId) => petEvolutionLevels[petId] ?? 0;

  int evolutionCost(String petId) {
    final level = petEvolutionLevel(petId);
    if (level == 0) return 150;
    if (level == 1) return 300;
    return 0; // maxed
  }

  bool evolvePet(String petId) {
    final level = petEvolutionLevel(petId);
    if (level >= 2) return false;
    final cost = evolutionCost(petId);
    if (!kDebugMode && crystals < cost) return false;
    if (!kDebugMode) crystals -= cost;
    petEvolutionLevels[petId] = level + 1;
    notifyListeners();
    saveToLocal();
    return true;
  }

  int _evolvedPetBonus(int base, String? petId) {
    if (petId == null) return base;
    final evo = petEvolutionLevel(petId);
    if (evo == 0) return base;
    if (evo == 1) return (base * 1.5).round();
    return base * 2;
  }

  // ── Cosmetic attack effects ─────────────────────────────────────────────────
  final Set<String> ownedAttackEffects = {};
  String? equippedAttackEffectId;

  bool buyAttackEffect(String effectId) {
    if (ownedAttackEffects.contains(effectId)) return false;
    if (!kDebugMode && crystals < 30) return false;
    if (!kDebugMode) crystals -= 30;
    ownedAttackEffects.add(effectId);
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

  // ── Artifacts & Mythril ─────────────────────────────────────────────────────
  int mythril = 0;

  // Owned artifact ids (can equip one per slot)
  final Set<String> ownedArtifacts = {};
  // slot -> equipped artifact id
  final Map<ArtifactSlot, String?> equippedArtifacts = {
    ArtifactSlot.ring:    null,
    ArtifactSlot.amulet:  null,
    ArtifactSlot.trinket: null,
  };

  Artifact? equippedArtifact(ArtifactSlot slot) =>
      Artifact.byId(equippedArtifacts[slot]);

  bool buyArtifact(Artifact artifact) {
    if (ownedArtifacts.contains(artifact.id)) return false;
    if (!kDebugMode && mythril < artifact.mythrilCost) return false;
    if (!kDebugMode) mythril -= artifact.mythrilCost;
    ownedArtifacts.add(artifact.id);
    notifyListeners();
    saveToLocal();
    return true;
  }

  void equipArtifact(Artifact artifact) {
    if (!ownedArtifacts.contains(artifact.id)) return;
    equippedArtifacts[artifact.slot] = artifact.id;
    _syncHeroHpPct();
    notifyListeners();
    saveToLocal();
  }

  void unequipArtifact(ArtifactSlot slot) {
    equippedArtifacts[slot] = null;
    _syncHeroHpPct();
    notifyListeners();
    saveToLocal();
  }

  // Aggregate artifact stat bonuses
  int get artifactAttackBonus  => _sumArtifacts((a) => a.attackBonus);
  int get artifactDamageBonus  => _sumArtifacts((a) => a.damageBonus);
  int get artifactAcBonus      => _sumArtifacts((a) => a.acBonus);
  int get artifactHpPct        => _sumArtifacts((a) => a.hpPct);
  int get artifactShardPct     => _sumArtifacts((a) => a.shardPct);
  int get artifactGoldPct      => _sumArtifacts((a) => a.goldPct);
  int get artifactXpPct        => _sumArtifacts((a) => a.xpPct);

  int _sumArtifacts(int Function(Artifact) f) =>
      equippedArtifacts.values
          .map((id) => Artifact.byId(id))
          .whereType<Artifact>()
          .fold(0, (sum, a) => sum + f(a));

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
      final defs = BountyPool.pickDaily(today);
      _dailyBounties = defs.map((d) => Bounty(def: d)).toList();
    }
  }

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
    if (b.def.reward.crystals > 0) crystals += b.def.reward.crystals;
    if (b.def.reward.shards > 0) shards += b.def.reward.shards;
    if (b.def.reward.xp > 0) hero.gainExperience(b.def.reward.xp);
    saveToLocal();
    notifyListeners();
  }

  void recordBossRushComplete() {
    _bossRushClears++;
    _trackBountyProgress(BountyType.winBossRush, 1);
    checkAllyMilestones();
    saveToLocal();
  }

  // ── Login Streak ──────────────────────────────────────────────────────────
  int loginStreak = 0;
  bool loginTodayClaimed = false;
  String _lastLoginDate = '';

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

  void claimLoginReward() {
    if (loginTodayClaimed) return;
    final dayInCycle = ((loginStreak - 1) % 7) + 1;
    final reward = LoginReward.forDay(dayInCycle);
    if (reward.gold > 0)     gold += reward.gold;
    if (reward.crystals > 0) crystals += reward.crystals;
    if (reward.shards > 0)   shards += reward.shards;
    if (reward.mythril > 0)  mythril += reward.mythril;
    if (reward.essence > 0)  essence += reward.essence;
    loginTodayClaimed = true;
    notifyListeners();
    saveToLocal();
  }



  // ── Runes ─────────────────────────────────────────────────────────────────
  int runeDust = 0;
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
    final event = WorldEventDef.forWeek();
    final reward = event.rewards.where((r) => r.id == rewardId).firstOrNull;
    if (reward == null || eventTokens < reward.tokenCost) return false;
    eventTokens -= reward.tokenCost;
    _eventRewardsClaimed.add(rewardId);
    if (reward.crystals > 0) crystals += reward.crystals;
    notifyListeners();
    saveToLocal();
    return true;
  }

  // ── Challenge Gauntlet ────────────────────────────────────────────────────
  int gauntletHighScore = 0;

  void recordGauntletResult(GauntletResult result) {
    if (result.score > gauntletHighScore) gauntletHighScore = result.score;
    if (result.shardsEarned > 0) shards += result.shardsEarned;
    if (result.crystalsEarned > 0) crystals += result.crystalsEarned;
    checkAllyMilestones();
    notifyListeners();
    saveToLocal();
  }

  // ── NPC Allies ────────────────────────────────────────────────────────────
  final Map<String, int> _allyLevels = {};   // id → 1..5 (0 / absent = locked)

  bool allyUnlocked(String id) => (_allyLevels[id] ?? 0) >= 1;
  int  allyLevel(String id)    => _allyLevels[id] ?? 0;

  List<NpcAllyDef> get unlockedAllies =>
      NpcAllyDef.all.where((a) => allyUnlocked(a.id)).toList();

  // ── Level-scaled bonuses ──────────────────────────────────────────────────
  int  get allyAtkBonus  => unlockedAllies.fold(0,   (s, a) => s + a.atkBonus  * allyLevel(a.id))
                          + activeSynergies.fold(0,   (s, y) => s + y.atkBonus);
  int  get allyDmgBonus  => unlockedAllies.fold(0,   (s, a) => s + a.dmgBonus  * allyLevel(a.id))
                          + activeSynergies.fold(0,   (s, y) => s + y.dmgBonus);
  int  get allyAcBonus   => unlockedAllies.fold(0,   (s, a) => s + a.acBonus   * allyLevel(a.id))
                          + activeSynergies.fold(0,   (s, y) => s + y.acBonus);
  double get allyGoldMult  => 1.0
      + unlockedAllies.fold(0.0, (s, a) => s + a.goldPctBonus  * allyLevel(a.id))
      + activeSynergies.fold(0.0, (s, y) => s + y.goldPctBonus);
  double get allyXpMult    => 1.0
      + unlockedAllies.fold(0.0, (s, a) => s + a.xpPctBonus    * allyLevel(a.id))
      + activeSynergies.fold(0.0, (s, y) => s + y.xpPctBonus);
  double get allyShardMult => 1.0
      + unlockedAllies.fold(0.0, (s, a) => s + a.shardPctBonus * allyLevel(a.id))
      + activeSynergies.fold(0.0, (s, y) => s + y.shardPctBonus);
  double get allyIdleMult  => 1.0
      + unlockedAllies.fold(0.0, (s, a) => s + a.idlePctBonus  * allyLevel(a.id))
      + activeSynergies.fold(0.0, (s, y) => s + y.idlePctBonus);
  int    get allyHpPct     => (
      (unlockedAllies.fold(0.0, (s, a) => s + a.hpPctBonus * allyLevel(a.id))
      + activeSynergies.fold(0.0, (s, y) => s + y.hpPctBonus)) * 100).round();

  // ── Synergies ─────────────────────────────────────────────────────────────
  List<SynergyDef> get activeSynergies => SynergyDef.all
      .where((s) => allyLevel(s.ally1Id) >= s.minLevel
                 && allyLevel(s.ally2Id) >= s.minLevel)
      .toList();

  // ── Level-up ──────────────────────────────────────────────────────────────
  bool upgradeAlly(String id) {
    final cur = allyLevel(id);
    if (cur == 0 || cur >= NpcAllyDef.maxLevel) return false;
    final (costShards, costCrystals) = NpcAllyDef.levelUpCost(cur + 1);
    if (shards < costShards || crystals < costCrystals) return false;
    shards   -= costShards;
    crystals -= costCrystals;
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
    AllyMilestone.prestigeLevel        => prestigeLevel,
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
  bool get survivedAt1HP    => _survivedAt1HP;

  // ── Achievements ───────────────────────────────────────────────────────────
  final List<Achievement> achievements = buildAchievements();

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
    AchievementCondition.prestigeLevel      => prestigeLevel,
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
    a.claimed = true;
    switch (a.rewardType) {
      case AchievementRewardType.shards:   shards  += a.rewardAmount;
      case AchievementRewardType.essence:  essence += a.rewardAmount;
      case AchievementRewardType.crystals: crystals += a.rewardAmount;
    }
    _setLastAction('Achievement claimed: ${a.name}! +${a.rewardLabel}');
    notifyListeners();
    saveToLocal();
  }

  void claimAllAchievements() {
    for (final a in achievements.where((a) => a.unlocked && !a.claimed)) {
      a.claimed = true;
      switch (a.rewardType) {
        case AchievementRewardType.shards:   shards  += a.rewardAmount;
        case AchievementRewardType.essence:  essence += a.rewardAmount;
        case AchievementRewardType.crystals: crystals += a.rewardAmount;
      }
    }
    notifyListeners();
    saveToLocal();
  }

  // ── Item shop ──────────────────────────────────────────────────────────────
  final List<EquipmentItem> _shopStock = [];
  String _shopDate   = '';
  int    _shopRerolls = 0;

  List<EquipmentItem> shopItemsForSlot(ItemSlot slot) {
    _ensureShopStock();
    return _shopStock.where((i) => i.slot == slot).toList();
  }

  int shopPriceFor(EquipmentItem item) {
    final lvScaling = item.levelRequired * 18;
    final base = switch (item.rarity) {
      ItemRarity.common    => 180 + lvScaling,
      ItemRarity.rare      => 600 + lvScaling * 2,
      ItemRarity.epic      => 2000 + lvScaling * 4,
      ItemRarity.legendary => 8000 + lvScaling * 8,
      ItemRarity.set       => 6000 + lvScaling * 6,
    };
    return base + hero.level * 40;
  }

  static const int shopRerollCost = 15;

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

  bool rerollShop() {
    if (shards < shopRerollCost) return false;
    shards -= shopRerollCost;
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
      _regenerateShop();
    } else if (_shopStock.isEmpty) {
      _regenerateShop();
    }
  }

  void _regenerateShop() {
    _shopStock.clear();
    final now     = DateTime.now();
    final dateInt = now.year * 10000 + now.month * 100 + now.day;
    for (var si = 0; si < ItemSlot.values.length; si++) {
      final slot = ItemSlot.values[si];
      final rng  = Random(dateInt + si * 1000 + _shopRerolls * 7777);
      for (var i = 0; i < 3; i++) {
        final roll = rng.nextInt(100);
        final rarity = roll < 10 ? ItemRarity.epic
                     : roll < 40 ? ItemRarity.rare
                     : ItemRarity.common;
        _shopStock.add(ItemLootTable.craftAt(slot, rarity, max(1, hero.level), rng));
      }
    }
  }

  // Passive skill tree
  int essence = 0;
  final PassiveTree passiveTree = PassiveTree();

  bool upgradePassive(String id) {
    if (!passiveTree.canUpgrade(id)) return false;
    final cost = passiveTree.costForNextRank(id);
    if (essence < cost) return false;
    essence -= cost;
    passiveTree.upgrade(id);
    _checkAchievements();
    notifyListeners();
    saveToLocal();
    return true;
  }

  // Legacy alias kept for any call sites not yet updated
  bool unlockPassive(String id) => upgradePassive(id);

  // Prestige
  int prestigeLevel = 0;
  int prestigeSouls = 0;
  final PrestigeShop prestigeShop = PrestigeShop();

  bool get canPrestige => campaignStageIndex >= 25;

  double get prestigeGoldMult    => (1.0 + prestigeLevel * 0.10) * ascGoldMult * ascPrestigeMult;
  double get prestigeXpMult      => (1.0 + prestigeLevel * 0.05) * ascXpMult * ascPrestigeMult;
  double get prestigeIdleMult    => (1.0 + prestigeLevel * 0.05) * ascIdleMult * ascPrestigeMult;
  double get prestigeShardMult   => (prestigeShop.isUnlocked('shard_bonus') ? 1.30 : 1.0) * ascShardMult;
  double get prestigeEssenceMult => (prestigeShop.isUnlocked('essence_bonus') ? 1.30 : 1.0) * ascEssenceMult;
  int    get prestigeIdleBonus => prestigeShop.isUnlocked('idle_bonus')    ? 5 : 0;
  int    get prestigeStartGold {
    var g = 0;
    if (prestigeShop.isUnlocked('start_gold'))   g += 500;
    if (prestigeShop.isUnlocked('start_gold_2')) g += 1500;
    return g;
  }
  int get prestigeHeadStart {
    if (prestigeShop.isUnlocked('head_start_2')) return 10;
    if (prestigeShop.isUnlocked('head_start'))   return 5;
    return 0;
  }
  double get prestigeAbilityDiscount =>
      prestigeShop.isUnlocked('ability_disc') ? 0.75 : 1.0;
  int get forgeCommonToRareCount =>
      prestigeShop.isUnlocked('forge_bonus') ? 2 : 3;

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

  void prestige() {
    if (!canPrestige) return;
    final savedName         = hero.name;
    final savedClass        = hero.heroClass;
    final savedShards       = shards;
    final savedRanks        = Map<String, int>.from(_abilityRanks);
    final savedBranches     = Map<String, String>.from(abilityBranches);
    final savedEssence      = essence;
    final savedTree         = Map<String, dynamic>.from(passiveTree.toJson());
    final savedQuests       = Map<String, bool>.from(questsClaimed);
    final savedTitle        = heroTitle;
    final savedAbilityUses  = _totalAbilityUses;
    final soulsEarned  = (campaignStageIndex / 5).floor().clamp(1, 50);
    mythril += 10; // prestige reward
    prestigeLevel++;
    prestigeSouls += soulsEarned;
    _resetToDefaults(savedName, savedClass);
    shards = savedShards;
    essence = savedEssence;
    _abilityRanks
      ..clear()
      ..addAll(savedRanks);
    abilityBranches
      ..clear()
      ..addAll(savedBranches);
    passiveTree.loadFromJson(savedTree);
    questsClaimed
      ..clear()
      ..addAll(savedQuests);
    heroTitle = savedTitle;
    _totalAbilityUses = savedAbilityUses;
    battleLog = [
      '✦ REBIRTH Lv$prestigeLevel ✦ $savedName returns, forged anew.',
      '+$soulsEarned soul${soulsEarned == 1 ? '' : 's'}  •  '
      'Gold income +${(prestigeGoldMult * 100 - 100).round()}%  •  '
      'XP +${(prestigeXpMult * 100 - 100).round()}%  •  '
      'Idle +${(prestigeIdleMult * 100 - 100).round()}%',
    ];
    checkAllyMilestones();
    notifyListeners();
    saveToLocal();
  }

  // ── Ascension ─────────────────────────────────────────────────────────────
  int ascensionLevel  = 0;
  int ascensionPoints = 0;
  final Map<String, int> _ascensionNodes = {};

  bool get canAscend => prestigeLevel >= 5;
  int  get ascensionPointsForNextAscension => 3;

  int ascensionNodeLevel(String id) => _ascensionNodes[id] ?? 0;

  double get ascXpMult   => 1.0 + ascensionNodeLevel('xp_gain') * 0.10;
  double get ascGoldMult => 1.0 + ascensionNodeLevel('gold_gain') * 0.10;
  double get ascShardMult => 1.0 + ascensionNodeLevel('shard_gain') * 0.10;
  int    get ascAtkBonus  => ascensionNodeLevel('atk_bonus');
  int    get ascDmgBonus  => ascensionNodeLevel('dmg_bonus') * 2;
  double get ascIdleMult  => 1.0 + ascensionNodeLevel('idle_bonus') * 0.15;
  double get ascPrestigeMult => 1.0 + ascensionNodeLevel('prestige_bonus') * 0.10;
  double get ascEssenceMult  => 1.0 + ascensionNodeLevel('essence_bonus') * 0.15;

  void ascend() {
    if (!canAscend) return;
    final ap = ascensionPointsForNextAscension;
    // Save everything that survives ascension
    final savedName          = hero.name;
    final savedClass         = hero.heroClass;
    final savedAscLevel      = ascensionLevel + 1;
    final savedAscPoints     = ascensionPoints + ap;
    final savedNodes         = Map<String, int>.from(_ascensionNodes);
    final savedMythril       = mythril;
    final savedArtifacts     = Set<String>.from(ownedArtifacts);
    final savedEquip         = Map<ArtifactSlot, String?>.from(equippedArtifacts);
    // Full reset (includes zeroing prestige + ascension)
    _resetToDefaults(savedName, savedClass);
    // Restore ascension-permanent data
    ascensionLevel  = savedAscLevel;
    ascensionPoints = savedAscPoints;
    _ascensionNodes.addAll(savedNodes);
    mythril = savedMythril;
    ownedArtifacts.addAll(savedArtifacts);
    for (final e in savedEquip.entries) {
      equippedArtifacts[e.key] = e.value;
    }
    battleLog = [
      '✦ ASCENSION Lv$ascensionLevel ✦ $savedName transcends the mortal coil.',
      '+$ap Ascension Points granted.',
    ];
    checkAllyMilestones();
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

  // ── Subclass ───────────────────────────────────────────────────────────────
  String? subclassId;

  bool get subclassAvailable => hero.level >= 10 && subclassId == null;

  SubclassEffect get subclassEffect {
    if (subclassId == null) return SubclassEffect.none;
    return subclassById(subclassId!)?.effect ?? SubclassEffect.none;
  }

  bool pickSubclass(String id) {
    final sub = subclassById(id);
    if (sub == null) return false;
    if (subclassId != null) return false;
    subclassId = id;
    // Apply stat bonuses immediately
    if (sub.strBonus != 0) hero.addStrength(sub.strBonus);
    if (sub.dexBonus != 0) hero.addDexterity(sub.dexBonus);
    if (sub.conBonus != 0) hero.addConstitution(sub.conBonus);
    if (sub.intBonus != 0) hero.addIntelligence(sub.intBonus);
    if (sub.wisBonus != 0) hero.addWisdom(sub.wisBonus);
    if (sub.chaBonus != 0) hero.addCharisma(sub.chaBonus);
    _setLastAction('Subclass chosen: ${sub.name}!');
    _checkAchievements();
    notifyListeners();
    saveToLocal();
    return true;
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
    final result = ItemLootTable.craftAt(slot, target, hero.level, _rng);
    inventory.addToBag(result);
    _totalForges++;
    _setLastAction('Forged: ${result.name}!');
    _checkAchievements();
    notifyListeners();
    saveToLocal();
    return result;
  }

  int disenchantItems(List<EquipmentItem> items) {
    var total = 0;
    var dustGained = 0;
    for (final item in items) {
      inventory.bag.remove(item);
      total += switch (item.rarity) {
        ItemRarity.common    => 3,
        ItemRarity.rare      => 8,
        ItemRarity.epic      => 20,
        ItemRarity.legendary => 60,
        ItemRarity.set       => 100,
      };
      // Common items also yield Rune Dust
      if (item.rarity == ItemRarity.common) dustGained += 2;
      else if (item.rarity == ItemRarity.rare) dustGained += 1;
    }
    if (total > 0) {
      shards += total;
      if (dustGained > 0) runeDust += dustGained;
      _totalDisenchants += items.length;
      _setLastAction('Disenchanted ${items.length} item(s): +$total ◆${dustGained > 0 ? '  +$dustGained Rune Dust' : ''}');
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
      (campaignStageIndex % 5 == 4 && campaignStageIndex < 25) ||
      (_endlessMode && endlessStageIndex % 5 == 4);

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
  int _enemyStunRounds = 0;
  bool _dodgeNextHit = false;

  // Public read — used by battle UI to show active affixes
  List<ZoneAffix> get activeAffixes => List.unmodifiable(_activeAffixes);

  void _resetBattlePerks() {
    _comboStacks         = 0;
    _unbrokenUsed        = false;
    _battleAwarenessUsed = false;
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
    _enemyStunRounds      = 0;
    _dodgeNextHit         = false;
  }

  // ── Active ability helpers ──────────────────────────────────────────────────

  List<HeroAbility> get unlockedAbilities =>
      AbilityData.unlockedFor(hero.heroClass, hero.level);

  int cooldownRemaining(String abilityId) =>
      max(0, (_cooldownUntil[abilityId] ?? 0) - _abilityRound);

  // ── Ability rank upgrades ──────────────────────────────────────────────────

  final Map<String, int> _abilityRanks = {};
  final Map<String, String> abilityBranches = {};

  int abilityRank(String id) => _abilityRanks[id] ?? 0;

  String? abilityBranchChoice(String id) => abilityBranches[id];

  bool chooseBranch(String abilityId, String branchId) {
    if (abilityRank(abilityId) < 3) return false;
    if (abilityBranches.containsKey(abilityId)) return false;
    abilityBranches[abilityId] = branchId;
    notifyListeners();
    saveToLocal();
    return true;
  }

  AbilityBranch? _activeBranch(HeroAbility ability) {
    final choice = abilityBranches[ability.id];
    if (choice == null) return null;
    return choice == 'a' ? ability.branchA : ability.branchB;
  }

  // ── Class questlines ──────────────────────────────────────────────────────

  int _questCounter(QuestCondition cond) => switch (cond) {
    QuestCondition.killEnemies  => _totalKills,
    QuestCondition.winBattles   => _totalBattleWins,
    QuestCondition.reachStage   => campaignStageIndex + 1,
    QuestCondition.bossKills    => _totalBossKills,
    QuestCondition.useAbilities => _totalAbilityUses,
  };

  int questProgress(ClassQuest q) =>
      _questCounter(q.condition).clamp(0, q.target);

  bool isQuestConditionMet(ClassQuest q) =>
      _questCounter(q.condition) >= q.target;

  bool isQuestUnlocked(ClassQuest q) {
    if (q.questIndex == 0) return true;
    final all = ClassQuestData.questsForClass(q.classRequired);
    return questsClaimed[all[q.questIndex - 1].id] == true;
  }

  bool isQuestClaimable(ClassQuest q) =>
      isQuestUnlocked(q) &&
      isQuestConditionMet(q) &&
      questsClaimed[q.id] != true;

  int get questsClaimable => ClassQuestData.questsForClass(hero.heroClass)
      .where(isQuestClaimable).length;

  bool claimQuest(ClassQuest q) {
    if (!isQuestClaimable(q)) return false;
    questsClaimed[q.id] = true;
    gold += q.reward.gold;
    shards += q.reward.shards;
    if (q.reward.title != null) heroTitle = q.reward.title;
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

  static const _abilityUpgradeCosts = [15, 35, 75]; // rank 0→1, 1→2, 2→3

  int abilityUpgradeCost(String id) {
    final rank = abilityRank(id);
    if (rank >= 3) return 0;
    return (_abilityUpgradeCosts[rank] * prestigeAbilityDiscount).round().clamp(1, 99999);
  }

  bool upgradeAbility(String id) {
    final cost = abilityUpgradeCost(id);
    if (cost == 0 || shards < cost) return false;
    shards -= cost;
    _abilityRanks[id] = abilityRank(id) + 1;
    notifyListeners();
    saveToLocal();
    return true;
  }

  int scaledAbilityValue(HeroAbility ability) {
    final rank = abilityRank(ability.id);
    if (rank == 0 || ability.value == 0) return ability.value;
    return ability.value + rank * max(1, ability.value ~/ 4);
  }

  int scaledAbilityCooldown(HeroAbility ability) {
    final subclassDiscount = subclassEffect == SubclassEffect.arcaneTrickster ? 1 : 0;
    return max(1, ability.cooldownRounds - abilityRank(ability.id)
        - passiveTree.totalOf(PassiveEffect.cooldownReduce) - subclassDiscount
        - traitCooldownReduction);
  }

  // Buff/debuff state exposed for the HUD
  int get buffAttackBonus  => _tempAttackBonus;
  int get buffAttackRounds => _tempAttackBonusRounds;
  int get buffAcBonus      => _tempAcBonus;
  int get buffAcRounds     => _tempAcBonusRounds;
  int get dotDmg           => _dotDmg;
  int get dotRoundsLeft    => _dotRoundsLeft;
  int get enemyStunRounds  => _enemyStunRounds;
  bool get dodgeNextHit    => _dodgeNextHit;

  void _fireAbility(HeroAbility ability) {
    final enemy = currentEnemy;
    if (enemy == null) return;
    _dailyAbilityUses++;
    _totalAbilityUses++;
    audioService.playAbility();
    final branch = _activeBranch(ability);
    final sv = scaledAbilityValue(ability) + (branch?.valueDelta ?? 0);
    final effectiveDuration = ability.duration + (branch?.durationDelta ?? 0);
    final subclassAbilityBonus = switch (subclassEffect) {
      SubclassEffect.loreKeeper  => 0.20,
      SubclassEffect.greatOldOne => 0.25,
      SubclassEffect.evoker      => 0.35,
      _ => 0.0,
    };
    final subclassHealBonus = switch (subclassEffect) {
      SubclassEffect.lifeCleric => 0.30,
      SubclassEffect.abjurer    => 0.15,
      SubclassEffect.devotion   => 0.0,
      _ => 0.0,
    };
    final abilityDmgMult = 1.0 + passiveTree.totalOf(PassiveEffect.abilityDamage) / 100.0
        + subclassAbilityBonus;
    final healBoostMult  = 1.0 + passiveTree.totalOf(PassiveEffect.healBoost) / 100.0
        + subclassHealBonus;
    if (subclassEffect == SubclassEffect.valorSurge) _valorSurgeReady = true;
    switch (ability.effect) {
      case AbilityEffect.bonusDamage:
        final dmg = ((_rng.nextInt(sv) + 1 + hero.damageMod) * abilityDmgMult).round().clamp(1, 9999);
        enemy.takeDamage(dmg);
        battleLog.add('${ability.name}! +$dmg bonus damage.');
      case AbilityEffect.heal:
        var hp = (hero.maxHealth * sv / 100 * healBoostMult).round().clamp(1, 9999);
        if (_activeAffixes.contains(ZoneAffix.voidCurse)) hp = (hp / 2).round().clamp(1, 9999);
        hero.currentHealth = (hero.currentHealth + hp).clamp(0, hero.maxHealth);
        battleLog.add('${ability.name}! +$hp HP restored.');
      case AbilityEffect.attackBonus:
        _tempAttackBonus = max(_tempAttackBonus, sv);
        _tempAttackBonusRounds = max(_tempAttackBonusRounds, effectiveDuration);
        battleLog.add('${ability.name}! +$sv to attack for $effectiveDuration rounds.');
      case AbilityEffect.acBonus:
        _tempAcBonus = max(_tempAcBonus, sv);
        _tempAcBonusRounds = max(_tempAcBonusRounds, effectiveDuration);
        battleLog.add('${ability.name}! +$sv AC for $effectiveDuration rounds.');
      case AbilityEffect.stun:
        final stunDur = effectiveDuration + (subclassEffect == SubclassEffect.battleMaster ? 1 : 0);
        _enemyStunRounds = stunDur;
        battleLog.add('${ability.name}! ${enemy.name} is stunned for $stunDur turn(s)!');
      case AbilityEffect.dot:
        final dotMult = subclassEffect == SubclassEffect.sporeCircle ? abilityDmgMult * 1.5 : abilityDmgMult;
        _dotDmg = (sv * dotMult).round().clamp(1, 9999);
        _dotRoundsLeft = effectiveDuration;
        battleLog.add('${ability.name}! ${enemy.name} takes $_dotDmg dmg/round for $effectiveDuration rounds.');
      case AbilityEffect.dodge:
        _dodgeNextHit = true;
        battleLog.add('${ability.name}! ${hero.name} will dodge the next attack.');
    }
    if (branch?.secondaryEffect != null) {
      _applyBranchSecondary(branch!, ability.name, abilityDmgMult, healBoostMult, enemy);
    }
  }

  void _applyBranchSecondary(AbilityBranch branch, String abilityName,
      double dmgMult, double healMult, Enemy enemy) {
    final se = branch.secondaryEffect!;
    final sv = branch.secondaryValue;
    final sd = branch.secondaryDuration;
    switch (se) {
      case AbilityEffect.bonusDamage:
        if (sv <= 0) return;
        final dmg = ((_rng.nextInt(sv) + 1 + hero.damageMod) * dmgMult).round().clamp(1, 9999);
        enemy.takeDamage(dmg);
        battleLog.add('  ↳ $abilityName: +$dmg secondary damage.');
      case AbilityEffect.heal:
        var hp = (hero.maxHealth * sv / 100 * healMult).round().clamp(1, 9999);
        if (_activeAffixes.contains(ZoneAffix.voidCurse)) hp = (hp / 2).round().clamp(1, 9999);
        hero.currentHealth = (hero.currentHealth + hp).clamp(0, hero.maxHealth);
        battleLog.add('  ↳ $abilityName: +$hp HP.');
      case AbilityEffect.attackBonus:
        _tempAttackBonus = max(_tempAttackBonus, sv);
        _tempAttackBonusRounds = max(_tempAttackBonusRounds, sd);
        battleLog.add('  ↳ $abilityName: +$sv ATK for ${sd}r.');
      case AbilityEffect.acBonus:
        _tempAcBonus = max(_tempAcBonus, sv);
        _tempAcBonusRounds = max(_tempAcBonusRounds, sd);
        battleLog.add('  ↳ $abilityName: +$sv AC for ${sd}r.');
      case AbilityEffect.stun:
        _enemyStunRounds = max(_enemyStunRounds, sd);
        battleLog.add('  ↳ $abilityName: ${enemy.name} stunned ${sd}r!');
      case AbilityEffect.dot:
        _dotDmg = max(_dotDmg, (sv * dmgMult).round().clamp(1, 9999));
        _dotRoundsLeft = max(_dotRoundsLeft, sd);
        battleLog.add('  ↳ $abilityName: DoT $sv/r for ${sd}r.');
      case AbilityEffect.dodge:
        _dodgeNextHit = true;
        battleLog.add('  ↳ $abilityName: next attack dodged.');
    }
  }

  // ── Endless mode ───────────────────────────────────────────────
  bool get hasEndlessEnemy => campaignStageIndex > 0;

  int get endlessStageIndex =>
      (campaignStageIndex - 1).clamp(0, EnemyData.enemies.length - 1);

  void startEndlessBattle() {
    if (campaignStageIndex == 0) return;
    _endlessMode = true;
    heroDefeated = false;
    lastBattleWasFinalVictory = false;
    _resetBattlePerks();
    _activeAffixes = AffixEngine.affixesFor(endlessStageIndex, _rng);
    currentEnemy = EnemyData.enemyForStage(endlessStageIndex, affixes: _activeAffixes);
    hero.healToFull();
    battleLog = ['${hero.name} faces ${currentEnemy!.name} in the endless arena!'];
    if (_activeAffixes.isNotEmpty) {
      battleLog.add('Corruption: ${_activeAffixes.map((a) => a.displayName).join(', ')}');
    }
    _setLastAction('Endless battle started against ${currentEnemy!.name}.');
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

  void startDungeon() {
    activeDungeon = DungeonRun(heroMaxHp: hero.maxHealth, heroHp: hero.maxHealth);
    activeDungeon!.generateRoomChoices(_rng);
    _setLastAction('Entered the dungeon — Floor 1.');
  }

  void chooseDungeonRoom(int index) {
    final run = activeDungeon;
    if (run == null || run.isOver) return;
    if (index < 0 || index >= run.roomChoices.length) return;
    run.currentRoom = run.roomChoices[index];
    notifyListeners();
  }

  // Exposed so DungeonScreen can display the item that dropped
  EquipmentItem? dungeonLastDrop;

  /// Auto-resolves the current combat/boss room. Returns gold earned.
  int resolveDungeonCombat() {
    final run = activeDungeon;
    final room = run?.currentRoom;
    if (run == null || room == null) return 0;
    if (room.type != DungeonRoomType.combat && room.type != DungeonRoomType.boss) return 0;

    final earnedGold = run.resolveCombat(
      room,
      hero.attackBonus,
      hero.armorClass,
      hero.strMod,
      _rng,
    );
    room.resolved = true;
    dungeonLastDrop = null;
    if (earnedGold > 0) {
      gold += earnedGold;
      _totalGoldEarned += earnedGold;
    }
    // Boss rooms always drop an item (rare or epic)
    if (!run.isDead && room.type == DungeonRoomType.boss) {
      final rarity = _rng.nextInt(100) < 30 ? ItemRarity.epic : ItemRarity.rare;
      final drop = ItemLootTable.craftAt(
        ItemSlot.values[_rng.nextInt(ItemSlot.values.length)],
        rarity,
        hero.level,
        _rng,
      );
      dungeonLastDrop = drop;
      room.hasItemDrop = true;
      inventory.addToBag(drop);
    }
    if (run.isDead) {
      _finishDungeon(run);
    }
    notifyListeners();
    return earnedGold;
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
    final rarity = _rng.nextInt(100) < 15 ? ItemRarity.epic : ItemRarity.rare;
    final drop = ItemLootTable.craftAt(
      ItemSlot.values[_rng.nextInt(ItemSlot.values.length)],
      rarity,
      hero.level,
      _rng,
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

  bool useDungeonConsumable(DungeonConsumableType type) {
    final run = activeDungeon;
    if (run == null) return false;
    final ok = run.useConsumable(type);
    if (ok) notifyListeners();
    return ok;
  }

  void advanceDungeonFloor() {
    final run = activeDungeon;
    if (run == null || run.isOver) return;
    run.floor++;
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
    if (run.floor > _deepestDungeonFloor) {
      _deepestDungeonFloor = run.floor;
    }
    // Mythril: 1 per 2 floors completed
    final mythrilEarned = (run.floor / 2).floor().clamp(0, 10);
    if (mythrilEarned > 0) mythril += mythrilEarned;
    if (run.floor > 0 && !run.isAbandoned) {
      _dungeonClears++;
      _trackBountyProgress(BountyType.completeDungeon, 1);
      checkAllyMilestones();
    }
    saveToLocal();
  }

  Future<void> loadSlot(int slot,
      {String? newName, DndClass? heroClass, HeroRace? heroRace, HeroTrait? trait}) async {
    _currentSlot = slot;
    extraCharacterSlots = await SaveService.getExtraSlots();
    final raw = await saveService.loadRaw(slot: slot);
    if (raw != null) {
      loadFromJson(raw);
    } else {
      _resetToDefaults(newName ?? 'The Warden', heroClass ?? DndClass.fighter);
      if (heroRace != null) this.heroRace = heroRace;
      if (trait != null) _applyTrait(trait);
    }
    // If Google-signed-in, check if cloud save is newer and load it automatically.
    // Wrapped in try-catch so any Firebase error (e.g. SDK not configured yet)
    // never blocks character creation from completing.
    try {
      if (authService.isGoogleSignedIn) {
        final uid = authService.currentUser!.uid;
        final cloudTs = await cloudSaveService.fetchLastSyncTime(uid);
        if (cloudTs != null) {
          final localTs = raw == null ? null : _parseLocalTimestamp(raw);
          if (localTs == null || cloudTs.isAfter(localTs)) {
            final cloudRaw = await cloudSaveService.fetchSave(uid);
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
    _slotLoaded = true;
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
    hero.extraHpPct = traitHpPct + artifactHpPct + runeHpPct + allyHpPct;
    hero.currentHealth = hero.currentHealth.clamp(1, hero.maxHealth);
  }

  void _resetToDefaults(String name, DndClass heroClass) {
    final info = heroClass.info;
    final conMod = (info.con - 10) ~/ 2;
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
      'currentHealth': (10 + conMod).clamp(1, 99),
    });
    gold = 250 + prestigeStartGold;
    shards = 0;
    idleProgress = 0;
    campaignStageIndex = prestigeHeadStart;
    currentEnemy = null;
    battleLog = ['$name the ${heroClass.displayName} awakens in the cursed realm.'];
    lastAction = 'Ready to battle';
    upgrades
      ..clear()
      ..addAll(List<Upgrade>.from(GameData.upgrades));
    dailyChallenges
      ..clear()
      ..addAll(DailyChallengeGenerator.generateForDate(DateTime.now()));
    _lastDailyDate     = _dateKey(DateTime.now());
    _dailyKills        = 0;
    _dailyBattleWins   = 0;
    _dailyIdleCollects = 0;
    _dailyAbilityUses  = 0;
    _dailyDamageDealt  = 0;
    _dailyBossKills    = 0;
    _dailyItemEquipped = false;
    dailyChestClaimed  = false;
    endlessUpgrades.reset();
    subclassId = null;
    // Reset tutorial so new character gets the welcome flow
    tutorialWelcomeSeen  = false;
    tutorialBattleSeen   = false;
    tutorialIdleSeen     = false;
    tutorialUpgradeSeen  = false;
    tutorialCampaignSeen = false;
    tutorialDungeonSeen  = false;
    _deepestDungeonFloor = 0;
    activeDungeon        = null;
    // Reset prestige on full wipe
    prestigeLevel = 0;
    prestigeSouls = 0;
    prestigeShop.reset();
    passiveTree.reset();
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
    crystals           = 0;
    equippedAuraId     = null;
    equippedSkinId     = null;
    equippedPetId      = null;
    ownedAuraIds.clear();
    ownedSkinIds.clear();
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
    activeExpedition = null;
    masteryLevels.clear();
    abilityBranches.clear();
    questsClaimed.clear();
    heroTitle = null;
    _totalAbilityUses = 0;
    heroRace  = null;
    heroTrait = null;
    hero.extraHpPct = 0;
    activeModifierId = null;
    bestiaryKills.clear();
    bossRushBestScore = 0;
    basicWaystoneCount = 0;
    grandWaystoneCount = 0;
    waystoneExpiresAtMs = 0;
    _activeWaystoneMult = 1.0;
    petEvolutionLevels.clear();
    ownedAttackEffects.clear();
    equippedAttackEffectId = null;
    mythril = 0;
    ownedArtifacts.clear();
    equippedArtifacts[ArtifactSlot.ring]    = null;
    equippedArtifacts[ArtifactSlot.amulet]  = null;
    equippedArtifacts[ArtifactSlot.trinket] = null;
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
    _dungeonClears   = 0;
    _bossRushClears  = 0;
    // Runes
    runeDust = 0;
    _runeStockpile.clear();
    _activeRunes[RuneSlot.weapon]   = null;
    _activeRunes[RuneSlot.armor]    = null;
    _activeRunes[RuneSlot.talisman] = null;
    // Login streak resets on full new-character wipe
    loginStreak = 0;
    loginTodayClaimed = false;
    _lastLoginDate = '';
    // Ascension resets on full new-character wipe
    ascensionLevel  = 0;
    ascensionPoints = 0;
    _ascensionNodes.clear();
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
  Enemy? currentEnemy;
  List<String> battleLog;
  String lastAction;
  final List<Upgrade> upgrades;
  final List<DailyChallenge> dailyChallenges;
  bool dailyChestClaimed = false;

  bool get dailyChestAvailable =>
      dailyChallenges.length == 7 &&
      dailyChallenges.every((c) => c.claimed) &&
      !dailyChestClaimed;

  void claimDailyChest() {
    if (!dailyChestAvailable) return;
    dailyChestClaimed = true;
    gold     += 1000;
    shards   += 75;
    essence  += 50;
    crystals += 50;
    _setLastAction('Daily Chest claimed! +1000g +75◆ +50 essence +50 crystals');
    notifyListeners();
    saveToLocal();
  }

  int lastRewardGold = 0;
  int lastRewardExp  = 0;
  int lastShardDrop  = 0;
  int lastIdleGold   = 0;

  int lastHeroDamage  = 0;
  bool lastHeroCrit   = false;
  int lastEnemyDamage = 0;

  // Combo streak — consecutive hits without missing or taking damage
  int _comboStacks = 0;
  int get comboStacks => _comboStacks;
  static const int maxComboStacks = 10;

  // Offline progress — set in loadFromJson, consumed by MainShell dialog
  int offlineGoldEarned  = 0;
  int offlineSecondsAway = 0;
  void clearOfflineReport() { offlineGoldEarned = 0; offlineSecondsAway = 0; }

  // Tutorial flags — one-time tips, persisted so they don't repeat
  bool tutorialWelcomeSeen  = false;
  bool tutorialBattleSeen   = false;
  bool tutorialIdleSeen     = false;
  bool tutorialUpgradeSeen  = false;
  bool tutorialCampaignSeen = false;
  bool tutorialDungeonSeen  = false;

  void markTutorialSeen(String key) {
    switch (key) {
      case 'welcome':  tutorialWelcomeSeen  = true;
      case 'battle':   tutorialBattleSeen   = true;
      case 'idle':     tutorialIdleSeen     = true;
      case 'upgrade':  tutorialUpgradeSeen  = true;
      case 'campaign': tutorialCampaignSeen = true;
      case 'dungeon':  tutorialDungeonSeen  = true;
    }
    saveToLocal();
  }

  // Dungeon
  int get deepestDungeonFloor => _deepestDungeonFloor;
  int _deepestDungeonFloor = 0;
  bool heroDefeated = false;
  bool lastBattleWasFinalVictory = false;

  int shards = 0;
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
    heroDefeated = false;
    lastBattleWasFinalVictory = false;
    _resetBattlePerks();
    _activeAffixes = AffixEngine.affixesFor(campaignStageIndex, _rng);
    var enemy = EnemyData.enemyForStage(campaignStageIndex, affixes: _activeAffixes);
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
      enemy = Enemy(
        id: enemy.id,
        name: '☠ ${enemy.name} (Boss)',
        description: enemy.description,
        maxHealth: enemy.maxHealth * 2,
        attack: (enemy.attack * 1.25).round(),
        level: enemy.level + 2,
        armorClass: enemy.armorClass + 2,
      );
      battleLog.add('⚠ BOSS BATTLE! ${enemy.name} — 2× HP, +25% ATK, Enrages at 30% HP!');
    }
    // Apply challenge modifier to enemy and hero
    final mod = activeModifier;
    if (mod != null) {
      enemy = Enemy(
        id: enemy.id,
        name: enemy.name,
        description: enemy.description,
        maxHealth: (enemy.maxHealth * mod.enemyHpMult).round().clamp(1, 9999999),
        attack: (enemy.attack * mod.enemyAtkMult).round().clamp(1, 9999),
        level: enemy.level,
        armorClass: enemy.armorClass,
      );
    }
    currentEnemy = enemy;
    hero.healToFull();
    // Apply modifier HP penalty to hero after heal
    if (mod != null && mod.heroHpMult < 1.0) {
      hero.currentHealth = (hero.maxHealth * mod.heroHpMult).round().clamp(1, hero.maxHealth);
    }
    if (_activeAffixes.isNotEmpty) {
      battleLog.add('Corruption: ${_activeAffixes.map((a) => a.displayName).join(', ')}');
    }
    if (mod != null) {
      battleLog.add('Challenge: ${mod.name} active (+${mod.rewardShardBonus} shards/kill).');
    }
    _setLastAction('Battle started against ${enemy.name}.');
  }

  final _rng = Random();

  bool _hasKeyword(ItemKeyword keyword) =>
      inventory.equipped.values.any((item) => item.keyword == keyword);

  void heroAttack() {
    final enemy = currentEnemy;
    if (enemy == null) return;

    // Fire ready abilities
    _abilityRound++;
    for (final ability in unlockedAbilities) {
      final readyAt = _cooldownUntil[ability.id] ?? 0;
      if (_abilityRound >= readyAt) {
        _fireAbility(ability);
        _cooldownUntil[ability.id] = _abilityRound + scaledAbilityCooldown(ability);
        if (enemy.isDefeated) {
          _battleVictory(enemy);
          return;
        }
      }
    }

    // STR Lv25 — Savage Momentum: advantage (roll twice, take higher) after a kill
    _attackRoundCounter++;
    int roll;
    if (_hasMomentum) {
      final r1 = _rng.nextInt(20) + 1;
      final r2 = _rng.nextInt(20) + 1;
      roll = max(r1, r2);
      _hasMomentum = false;
      battleLog.add('Savage Momentum!');
    } else {
      roll = _rng.nextInt(20) + 1;
    }

    // Time Fracture affix: every 4th hero attack re-rolls (take lower)
    if (_activeAffixes.contains(ZoneAffix.timeFracture) &&
        _attackRoundCounter % 4 == 0) {
      final fracRoll = _rng.nextInt(20) + 1;
      if (fracRoll < roll) {
        battleLog.add('Time Fracture! Attack deflected.');
        roll = fracRoll;
      }
    }

    // STR Lv5 — Iron Grip: +3 to all attack rolls; passive tree + equipment bonuses
    final valorBonus = (_valorSurgeReady && subclassEffect == SubclassEffect.valorSurge) ? 4 : 0;
    if (_valorSurgeReady) _valorSurgeReady = false;
    final legendaryVengeanceBonus = (_hasKeyword(ItemKeyword.vengeance) && hero.currentHealth * 2 < hero.maxHealth) ? 2 : 0;
    final totalBonus = hero.attackBonus + endlessUpgrades.attackRollBonus
        + (endlessUpgrades.ironGrip ? 3 : 0) + _tempAttackBonus
        + passiveTree.totalOf(PassiveEffect.attackFlat)
        + inventory.totalOf(ItemStat.attackBonus)
        + inventory.totalOf(ItemStat.strength)
        + legendaryVengeanceBonus
        + valorBonus
        + petAttackBonus
        + skinAttackBonus
        + auraAttackBonus
        + _setTotal(ItemStat.attackBonus)
        + _setTotal(ItemStat.dexterity)
        + _setTotal(ItemStat.strength)
        + _gemTotal(ItemStat.attackBonus)
        + _gemTotal(ItemStat.strength)
        + _masteryTotal(MasteryEffect.permanentAttack)
        + questAttackBonus
        + bestiaryChapterBonus
        + artifactAttackBonus
        + ascAtkBonus
        + runeAtkBonus
        + allyAtkBonus;
    final total = roll + totalBonus;

    // STR Lv10 — Keen Edge: crit on 19 or 20; passive pierce reduces effective enemy AC
    final subclassPierce = subclassEffect == SubclassEffect.vengeance ? 3 : 0;
    final pierce = passiveTree.totalOf(PassiveEffect.pierce) + subclassPierce
        + _masteryTotal(MasteryEffect.piercePerHit);
    final effectiveEnemyAC = max(1, enemy.armorClass - pierce);
    final critChancePct = passiveTree.totalOf(PassiveEffect.critChance);
    final crit = roll == 20
        || (endlessUpgrades.keenEdge && roll == 19)
        || (subclassEffect == SubclassEffect.champion && roll >= 18)
        || (critChancePct > 0 && _rng.nextInt(100) < critChancePct);
    final hit  = crit || total >= effectiveEnemyAC;

    if (hit) {
      // Shadow Cloak affix: 20% chance to negate the hit
      if (_activeAffixes.contains(ZoneAffix.shadowCloak) &&
          _rng.nextInt(100) < 20) {
        battleLog.add('Hit! (Shadow Cloak negates)');
        notifyListeners();
        return;
      }

      final dmgDie = subclassEffect == SubclassEffect.openHand
          ? _rng.nextInt(10) + 1
          : _rng.nextInt(8) + 1;
      final critMult = (subclassEffect == SubclassEffect.assassin || _hasKeyword(ItemKeyword.criticalFury)) ? 3 : 2;
      var baseDmg = ((crit ? dmgDie * critMult : dmgDie) + hero.damageMod
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
          + artifactDamageBonus
          + ascDmgBonus
          + runeDmgBonus
          + allyDmgBonus).clamp(1, 9999);

      // Blood Pact keyword: bonus damage equal to 20% of missing HP
      if (_hasKeyword(ItemKeyword.bloodPact)) {
        baseDmg = (baseDmg + ((hero.maxHealth - hero.currentHealth) * 0.20).round()).clamp(1, 9999);
      }

      // Trait: Glass Cannon +30% dmg
      if (traitDmgPct != 0) {
        baseDmg = (baseDmg * (100 + traitDmgPct) / 100).round().clamp(1, 9999);
      }

      // Bestiary weakness: +10% dmg vs discovered enemy types
      final weakMult = bestiaryWeaknessBonus(enemy.id);
      if (weakMult > 1.0) {
        baseDmg = (baseDmg * weakMult).round().clamp(1, 9999);
      }

      // Iron Skin affix: reduce hero damage by 2 (min 1)
      if (_activeAffixes.contains(ZoneAffix.ironSkin)) {
        baseDmg = (baseDmg - 2).clamp(1, 9999);
      }
      // Diamond Hide affix (T2 Iron Skin mutation): scales with enemy HP ratio
      if (_activeAffixes.contains(ZoneAffix.diamondHide)) {
        final ratio = enemy.currentHealth / enemy.maxHealth;
        final reduction = (2 + (ratio * 6).floor()).clamp(2, 8);
        baseDmg = (baseDmg - reduction).clamp(1, 9999);
      }

      // Berserk: +25% damage below 50% HP
      if (subclassEffect == SubclassEffect.berserk && hero.currentHealth * 2 < hero.maxHealth) {
        baseDmg = (baseDmg * 1.25).round().clamp(1, 9999);
      }

      // INT Lv10 — Exploit Weakness: +15% damage vs AC ≤ 14
      final exploitMult = (endlessUpgrades.exploitWeakness && enemy.armorClass <= 14)
          ? 1.15 : 1.0;
      final subclassDmgMult = switch (subclassEffect) {
        SubclassEffect.hunter   => 1.20,
        SubclassEffect.vengeance => 1.10,
        _ => 1.0,
      };
      final comboMult    = 1.0 + _comboStacks * 0.05;
      final allDmgMult   = 1.0 + passiveTree.totalOf(PassiveEffect.allDamage) / 100.0;
      var damage = (baseDmg * endlessUpgrades.damageMultiplier * exploitMult * subclassDmgMult * comboMult * allDmgMult)
          .round()
          .clamp(1, 9999);

      // Wild Magic: 15% chance triple damage
      if (subclassEffect == SubclassEffect.wildMagic && _rng.nextInt(100) < 15) {
        damage = (damage * 3).clamp(1, 9999);
        battleLog.add('Wild Magic surge!  $damage damage!');
      }

      // Soul Rip keyword: 8% chance to instakill enemy below 25% HP
      if (_hasKeyword(ItemKeyword.soulRip) &&
          enemy.currentHealth / enemy.maxHealth < 0.25 &&
          _rng.nextInt(100) < 8) {
        damage = enemy.currentHealth;
        battleLog.add('Soul Rip! ${enemy.name}\'s soul is torn free!');
      }

      enemy.takeDamage(damage);
      lastHeroDamage = damage;
      lastHeroCrit   = crit;
      _comboStacks = (_comboStacks + 1).clamp(0, maxComboStacks);
      _dailyDamageDealt += damage;
      _totalDamageDealt  += damage;
      _trackBountyProgress(BountyType.dealDamage, damage);
      audioService.playHit();
      // Life Steal keyword: heal 10% of damage dealt
      if (_hasKeyword(ItemKeyword.lifeSteal)) {
        final steal = (damage * 0.10).round().clamp(0, hero.maxHealth - hero.currentHealth);
        if (steal > 0) hero.currentHealth += steal;
      }

      // Fiend Pact lifesteal: recover 20% of damage dealt
      if (subclassEffect == SubclassEffect.fiendPact) {
        final steal = (damage * 0.20).round().clamp(0, hero.maxHealth - hero.currentHealth);
        if (steal > 0) hero.currentHealth += steal;
      }
      // Class mastery lifesteal
      final masteryLifestealPct = _masteryTotal(MasteryEffect.lifestealPct);
      if (masteryLifestealPct > 0) {
        final steal = (damage * masteryLifestealPct / 100).round()
            .clamp(0, hero.maxHealth - hero.currentHealth);
        if (steal > 0) hero.currentHealth += steal;
      }
      final effect  = AttackEffect.byId(equippedAttackEffectId);
      final hitWord = crit ? 'CRITICAL HIT' : (effect?.hitText ?? 'Hit');
      battleLog.add('$hitWord! $damage dmg.');
      if (enemy.isDefeated) {
        _battleVictory(enemy);
        return;
      }

      // Boss enrage at 30% HP
      if (!_bossEnraged && isBossStage &&
          enemy.currentHealth / enemy.maxHealth < 0.3) {
        _bossEnraged = true;
        battleLog.add('⚠ ${enemy.name} ENRAGES! +50% damage!');
      }

      // DEX Lv10 — Blade Flicker: 12% chance to strike a second time
      if (endlessUpgrades.bladeFlicker && _rng.nextInt(100) < 12) {
        final r2 = _rng.nextInt(20) + 1;
        final t2 = r2 + totalBonus;
        final c2 = r2 == 20 || (endlessUpgrades.keenEdge && r2 == 19);
        final h2 = c2 || t2 >= enemy.armorClass;
        if (h2) {
          var bd2 = ((c2 ? (_rng.nextInt(8) + 1) * 2 : _rng.nextInt(8) + 1) + hero.damageMod)
              .clamp(1, 9999);
          if (_activeAffixes.contains(ZoneAffix.ironSkin))     bd2 = (bd2 - 2).clamp(1, 9999);
          if (_activeAffixes.contains(ZoneAffix.diamondHide)) {
            final ratio = enemy.currentHealth / enemy.maxHealth;
            bd2 = (bd2 - (2 + (ratio * 6).floor()).clamp(2, 8)).clamp(1, 9999);
          }
          final dmg2 = (bd2 * endlessUpgrades.damageMultiplier * exploitMult)
              .round().clamp(1, 9999);
          enemy.takeDamage(dmg2);
          battleLog.add(
              'Blade Flicker! ${c2 ? "CRITICAL HIT" : "Hit"} for $dmg2 dmg.');
          if (enemy.isDefeated) {
            _battleVictory(enemy);
            return;
          }
        } else {
          battleLog.add('Blade Flicker — Miss.');
        }
      }
      // Swift Strike keyword: 15% chance for an extra hit
      if (!enemy.isDefeated && _hasKeyword(ItemKeyword.swiftStrike) && _rng.nextInt(100) < 15) {
        final rs = _rng.nextInt(20) + 1;
        if (rs + totalBonus >= effectiveEnemyAC || rs == 20) {
          final ds = max(1, _rng.nextInt(8) + 1 + hero.damageMod + inventory.totalOf(ItemStat.strength));
          enemy.takeDamage(ds);
          battleLog.add('Swift Strike! Hit for $ds dmg.');
          if (enemy.isDefeated) { _battleVictory(enemy); return; }
        }
      }
      // Class mastery multi-strike
      final masteryMultiPct = _masteryTotal(MasteryEffect.multiStrikePct);
      if (!enemy.isDefeated && masteryMultiPct > 0 && _rng.nextInt(100) < masteryMultiPct) {
        final rm = _rng.nextInt(20) + 1;
        final tm = rm + totalBonus;
        final cm = rm == 20 || (endlessUpgrades.keenEdge && rm == 19)
            || (subclassEffect == SubclassEffect.champion && rm >= 18);
        if (cm || tm >= effectiveEnemyAC) {
          var dm = ((cm ? (_rng.nextInt(8) + 1) * critMult : _rng.nextInt(8) + 1)
              + hero.damageMod
              + _masteryTotal(MasteryEffect.flatDamagePerHit)
              + _masteryTotal(MasteryEffect.permanentDamage)).clamp(1, 9999);
          final dm2 = (dm * endlessUpgrades.damageMultiplier).round().clamp(1, 9999);
          enemy.takeDamage(dm2);
          battleLog.add('${cm ? "CRITICAL " : ""}Mastery strike! $dm2 dmg.');
          if (enemy.isDefeated) { _battleVictory(enemy); return; }
        }
      }
    } else {
      _comboStacks = 0;
      battleLog.add('Miss!');
    }
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
      final drain = (hero.maxHealth * (0.05 + extraPct)).round().clamp(1, 9999);
      hero.takeDamage(drain);
      battleLog.add('Cursed Ground${_activeAffixes.contains(ZoneAffix.deathSpiral) ? " (Death Spiral)" : ""}: '
          '${hero.name} bleeds $drain HP.');
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

    // Lifeleech Aura affix (T2): enemy passively heals 5% max HP at turn start
    if (_activeAffixes.contains(ZoneAffix.lifeleechAura)) {
      final leech = (enemy.maxHealth * 0.05).round().clamp(1, 9999);
      enemy.currentHealth = (enemy.currentHealth + leech).clamp(0, enemy.maxHealth);
    }

    // Ability DoT tick
    if (_dotRoundsLeft > 0) {
      _dotRoundsLeft--;
      enemy.takeDamage(_dotDmg);
      battleLog.add('Ongoing damage: ${enemy.name} takes $_dotDmg dmg ($_dotRoundsLeft rounds left).');
      if (enemy.isDefeated) {
        _battleVictory(enemy);
        return;
      }
    }

    // Ability stun — enemy skips its attack
    if (_enemyStunRounds > 0) {
      _enemyStunRounds--;
      battleLog.add('${enemy.name} is stunned and cannot act!');
      _decrementBuffs();
      return;
    }

    // Ability dodge — hero negates the next incoming hit
    if (_dodgeNextHit) {
      _dodgeNextHit = false;
      battleLog.add('${hero.name} dodges the attack!');
      _decrementBuffs();
      return;
    }

    // Devotion: regen 1 HP per enemy turn
    if (subclassEffect == SubclassEffect.devotion) {
      hero.currentHealth = (hero.currentHealth + 1).clamp(0, hero.maxHealth);
    }

    // Passive dodge chance (includes shadowMonk +10%)
    final subclassDodge = subclassEffect == SubclassEffect.shadowMonk ? 10 : 0;
    final passiveDodge = passiveTree.totalOf(PassiveEffect.dodgeChance) + subclassDodge + runeDodgeBonus + auraDodgeChance;
    if (passiveDodge > 0 && _rng.nextInt(100) < passiveDodge) {
      battleLog.add('${hero.name} evades the blow! (Passive dodge)');
      _decrementBuffs();
      return;
    }

    // DEX Lv25 — Shadow Step: 15% chance to dodge the attack entirely
    if (endlessUpgrades.shadowStep && _rng.nextInt(100) < 15) {
      battleLog.add('${hero.name} sidesteps the blow! (Shadow Step)');
      return;
    }

    // Void Step keyword: 15% chance to phase through an attack entirely
    if (_hasKeyword(ItemKeyword.voidStep) && _rng.nextInt(100) < 15) {
      battleLog.add('Void Step — attack phased through!');
      _decrementBuffs();
      return;
    }

    // WIS Lv10 — Battle Awareness: enemy's first attack rolls at disadvantage
    final int roll;
    // Abyssal Roar affix: +3 to enemy attack rolls
    final int affixBonus = _activeAffixes.contains(ZoneAffix.abyssalRoar) ? 3 : 0;
    final int enemyBonus = enemy.level ~/ 2 + affixBonus;
    if (!_battleAwarenessUsed && endlessUpgrades.battleAwareness) {
      final r1 = _rng.nextInt(20) + 1;
      final r2 = _rng.nextInt(20) + 1;
      roll = min(r1, r2);
      _battleAwarenessUsed = true;
      battleLog.add('Battle Awareness! ${enemy.name} attacks at disadvantage.');
    } else {
      roll = _rng.nextInt(20) + 1;
    }

    // DEX Lv5 — Light Footed: +1 effective AC; ability acBonus; passive + equipment armor
    final effectiveAC = hero.armorClass + (endlessUpgrades.lightFooted ? 1 : 0) + _tempAcBonus
        + passiveTree.totalOf(PassiveEffect.armorFlat)
        + _masteryTotal(MasteryEffect.permanentAC)
        + questACBonus
        + inventory.totalOf(ItemStat.armorClass)
        + inventory.totalOf(ItemStat.dexterity)
        + petArmor
        + skinArmor
        + auraArmor
        + _setTotal(ItemStat.armorClass)
        + _setTotal(ItemStat.dexterity)
        + _gemTotal(ItemStat.armorClass)
        + _gemTotal(ItemStat.dexterity)
        + artifactAcBonus
        + runeAcBonus
        + allyAcBonus;
    final total = roll + enemyBonus;

    if (total >= effectiveAC) {
      var rawDamage = (_rng.nextInt(enemy.attack) + 1).clamp(1, 9999);
      // Boss enrage: +50% damage
      if (_bossEnraged) rawDamage = (rawDamage * 1.5).round().clamp(1, 9999);
      // Iron Will trait: crits (natural 20) deal normal damage, not double
      if (traitCritImmune && roll == 20) rawDamage = rawDamage ~/ 2;
      // CON Lv5 — Thick Hide + Iron Will keyword: reduce incoming damage
      final ironWillReduction = _hasKeyword(ItemKeyword.ironWill) ? 1 : 0;
      final damage = endlessUpgrades.thickHide
          ? (rawDamage - 1 - ironWillReduction).clamp(0, 9999)
          : (rawDamage - ironWillReduction).clamp(0, 9999);

      if (damage > 0) {
        hero.takeDamage(damage);
        lastEnemyDamage = damage;
        _comboStacks = 0; // taking damage breaks combo
        audioService.playPlayerHit();
        battleLog.add('${enemy.name} hits! $damage dmg.');

        // Thorn Wall keyword: return 30% of incoming damage to attacker
        if (_hasKeyword(ItemKeyword.thornWall)) {
          final thorn = (damage * 0.30).round().clamp(1, 9999);
          enemy.takeDamage(thorn);
          battleLog.add('Thorn Wall reflects $thorn dmg!');
          if (enemy.isDefeated) { _battleVictory(enemy); return; }
        }

        // Soul Siphon affix: enemy heals 15% of damage dealt
        if (_activeAffixes.contains(ZoneAffix.soulSiphon)) {
          final siphon = (damage * 0.15).round().clamp(1, 9999);
          enemy.currentHealth = (enemy.currentHealth + siphon).clamp(0, enemy.maxHealth);
        }

        // CON Lv25 — Unbroken: survive one killing blow per battle at 1 HP
        if (hero.currentHealth <= 0 && endlessUpgrades.unbroken && !_unbrokenUsed) {
          hero.currentHealth = 1;
          _unbrokenUsed = true;
          battleLog.add('Unbroken! ${hero.name} clings to life at 1 HP!');
        }

        if (hero.currentHealth <= 0) {
          _battleDefeat();
          return;
        }

        // CON Lv10 — Battle Scarred: regen 2% max HP after each hit taken
        if (endlessUpgrades.battleScarred) {
          var regen = (hero.maxHealth * 0.02).round().clamp(1, 9999);
          // Void Curse affix: halve all hero HP recovery
          if (_activeAffixes.contains(ZoneAffix.voidCurse)) regen = (regen / 2).round().clamp(1, 9999);
          hero.currentHealth = (hero.currentHealth + regen).clamp(0, hero.maxHealth);
        }
      } else {
        battleLog.add('${enemy.name} attacks — Thick Hide absorbs all!');
      }
    } else {
      battleLog.add('${enemy.name} misses!');
      // Riposte keyword: deal 3 damage when enemy misses
      if (_hasKeyword(ItemKeyword.riposte)) {
        enemy.takeDamage(3);
        battleLog.add('Riposte! 3 damage returned.');
        if (enemy.isDefeated) { _battleVictory(enemy); return; }
      }
    }
    _decrementBuffs();
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
  }

  void enemyAttack() {
    final enemy = currentEnemy;
    if (enemy == null) return;
    _enemyTurn(enemy);
    notifyListeners();
  }

  void _battleVictory(Enemy enemy) {
    // INT Lv25 — Arcane Efficiency: +15% bonus gold on every kill; passive gold bonus
    final arcaneBonus = endlessUpgrades.arcaneEfficiency ? 1.15 : 1.0;
    final passiveGoldMult = 1.0 + (passiveTree.totalOf(PassiveEffect.goldFlat)
        + inventory.totalOf(ItemStat.goldPct)
        + _setTotal(ItemStat.goldPct)
        + _gemTotal(ItemStat.goldPct)
        + _masteryTotal(MasteryEffect.permanentGoldPct)) / 100.0;
    final itemIntMult = 1.0 + inventory.totalOf(ItemStat.intelligence) * 0.02;
    final goldSenseMult = _hasKeyword(ItemKeyword.goldSense) ? 1.15 : 1.0;
    final petGoldMult = 1.0 + (petGoldPct + skinGoldPct + auraGoldPct + artifactGoldPct + runeGoldPct + traitGoldPct) / 100.0;
    final rewardGold =
        ((enemy.level * 50 + 100) * endlessUpgrades.goldMultiplier * arcaneBonus * prestigeGoldMult * passiveGoldMult * itemIntMult * goldSenseMult * petGoldMult * allyGoldMult)
            .round();

    // CHA Lv10 — Rally Cry: +20% XP from every kill; passive XP bonus
    final rallyCryBonus = endlessUpgrades.rallyCry ? 1.2 : 1.0;
    final passiveXpMult = 1.0 + (passiveTree.totalOf(PassiveEffect.xpFlat)
        + inventory.totalOf(ItemStat.xpPct)
        + _setTotal(ItemStat.xpPct)
        + _gemTotal(ItemStat.xpPct)
        + _masteryTotal(MasteryEffect.permanentXpPct)) / 100.0;
    final itemChaMult = 1.0 + inventory.totalOf(ItemStat.charisma) * 0.02;
    final petXpMult = 1.0 + (petXpPct + skinXpPct + auraXpPct + artifactXpPct + runeXpPct + traitXpPct) / 100.0;
    final rewardExp =
        (((enemy.level * 35 + 90) *
                hero.xpMultiplier *
                endlessUpgrades.xpMultiplier *
                rallyCryBonus *
                prestigeXpMult *
                passiveXpMult *
                itemChaMult *
                petXpMult *
                allyXpMult)
            .round())
        .clamp(1, 999999);

    gold += rewardGold;
    _totalGoldEarned += rewardGold;
    final prevLevel = hero.level;
    hero.gainExperience(rewardExp);
    if (hero.level > prevLevel) audioService.playLevelUp();
    lastRewardGold = rewardGold;
    lastRewardExp  = rewardExp;

    // Bestiary: record kill for this enemy type
    bestiaryKills[enemy.id] = (bestiaryKills[enemy.id] ?? 0) + 1;

    // World Event: 15% chance to award tokens on any kill
    _refreshEventIfNeeded();
    if (_rng.nextInt(100) < 15) {
      final tokens = 1 + _rng.nextInt(3);
      eventTokens += tokens;
      battleLog.add('${WorldEventDef.forWeek().enemyEmoji} Event enemy slain! +$tokens token${tokens == 1 ? '' : 's'}');
    }

    // Shards: base drop + passive bonus + prestige shop bonus
    var shardDrop = _calcShardDrop(enemy);
    // WIS Lv5 — Farsight: +2 shards per kill
    if (endlessUpgrades.farsight) shardDrop += 2;
    shardDrop += passiveTree.totalOf(PassiveEffect.shardFlat);
    if (_hasKeyword(ItemKeyword.soulHunger)) shardDrop += 1;
    shardDrop += petShards + auraShards;
    // CHA Lv25 — Fortune's Favour: 10% chance to double shard drops
    if (endlessUpgrades.fortunesFavour && _rng.nextInt(100) < 10) shardDrop *= 2;
    shardDrop += activeModifier?.rewardShardBonus ?? 0;
    shardDrop = (shardDrop * prestigeShardMult * allyShardMult * (1 + (traitShardPct + artifactShardPct + runeShardPct) / 100)).round();
    shards += shardDrop;
    lastShardDrop = shardDrop;

    // Gem shard drops: 25% chance on normal kill (1-2 shards), boss guaranteed 3-8
    if (isBossStage) {
      gemShards += 3 + _rng.nextInt(6);
    } else if (_rng.nextInt(100) < 25) {
      gemShards += 1 + _rng.nextInt(2);
    }

    // Equipment drop
    final drop = ItemLootTable.tryDrop(enemy.level, _rng);
    if (drop != null) {
      lastItemDrop = drop;
      inventory.addToBag(drop);
      battleLog.add('Item dropped: ${drop.name} (${drop.rarityLabel})!');
    }
    // Legendary drop: 1% chance on boss kills
    if (isBossStage) {
      final legDrop = ItemLootTable.tryDropLegendary(hero.level, _rng);
      if (legDrop != null) {
        lastItemDrop = legDrop;
        inventory.addToBag(legDrop);
        battleLog.add('✦ LEGENDARY DROP: ${legDrop.name}!');
      }
      // Set item drop: 0.3% chance on boss kills — extremely rare
      final setDrop = ItemLootTable.tryDropSet(hero.level, _rng);
      if (setDrop != null) {
        lastItemDrop = setDrop;
        inventory.addToBag(setDrop);
        battleLog.add('◈ SET ITEM DROP: ${setDrop.name}!');
      }
    }

    // Essence drop (1 per kill + passive bonus; bosses drop 5)
    final essenceMult = (1.0 + (passiveTree.totalOf(PassiveEffect.essenceGain) + auraEssenceGain) / 100.0) * prestigeEssenceMult;
    final baseEssence = isBossStage ? 5 : 1;
    essence += (baseEssence * essenceMult).round();
    if (isBossStage) {
      final bossGold = (rewardGold * 2).round();
      gold += bossGold;
      battleLog.add('BOSS DEFEATED! Bonus: +$bossGold gold  +${(baseEssence * essenceMult).round()} essence!');
    }

    battleLog.add(
        '${enemy.name} was defeated! +$rewardGold gold  +$rewardExp XP  +$shardDrop ◆');

    // Volatile Death affix: enemy explodes on death — ATK÷4 unavoidable damage
    if (_activeAffixes.contains(ZoneAffix.volatileDeath)) {
      final blast = (enemy.attack ~/ 4).clamp(1, 9999);
      hero.takeDamage(blast);
      battleLog.add('Volatile Death! Explosion deals $blast unavoidable damage.');
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

    // Post-battle HP recovery: CON-based partial heal instead of full restore.
    // Base = (10 + conMod * 5)% of max HP, so CON 10 → 10%, CON 16 → 25%, CON 20 → 35%.
    final conHealPct = (10 + hero.conMod * 5).clamp(5, 100);
    var conRegen = (hero.maxHealth * conHealPct / 100).round();
    // Endless upgrade: bonus fraction on top of CON base
    conRegen += (hero.maxHealth * endlessUpgrades.hpRecoveryFraction).round();
    // Equipment / gem / set CON bonuses: +3 HP per point
    conRegen += inventory.totalOf(ItemStat.constitution) * 3;
    conRegen += _setTotal(ItemStat.constitution) * 3;
    conRegen += _gemTotal(ItemStat.constitution) * 3;
    conRegen += petHpRegen + skinHpRegen + auraHpRegen;
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

    // Bounty tracking
    _trackBountyProgress(BountyType.killEnemies, 1);
    if (_endlessMode) {
      _trackBountyProgress(BountyType.reachEndlessFloor, 1);
    }

    audioService.playVictory();
    _checkAchievements();
    checkAllyMilestones();

    // Victory resets mercy / loss streak
    _consecutiveLosses = 0;
    _mercyTokenActive  = false;

    if (_endlessMode) {
      battleLog.add('The enemy stirs again in the endless dark...');
      lastBattleWasFinalVictory = false;
      _setLastAction('Victory! $rewardGold gold, $rewardExp XP, $shardDrop ◆.');
      saveToLocal();
      return;
    }

    // Campaign is infinite — always advance
    final wasFinalBoss = campaignStageIndex == CampaignData.stages.length - 1;
    campaignStageIndex += 1;
    lastBattleWasFinalVictory = false;

    if (wasFinalBoss) {
      battleLog.add('The Dark Lord falls... but the abyss yawns deeper.');
    } else {
      battleLog.add('${hero.name} advances to stage ${campaignStageIndex + 1}.');
    }
    _setLastAction('Victory! $rewardGold gold, $rewardExp XP, $shardDrop ◆.');
    saveToLocal();
  }

  void _battleDefeat() {
    heroDefeated = true;
    audioService.playDefeat();
    battleLog.add('${hero.name} was overwhelmed and must retreat.');
    currentEnemy = null;
    hero.healToFull();
    _consecutiveLosses++;
    if (_consecutiveLosses >= 3 && !_mercyTokenActive) {
      _mercyTokenActive = true;
      battleLog.add('Mercy Token granted — next fight will be easier.');
    }
    _setLastAction('Defeat! Upgrade your hero before venturing forth again.');
    notifyListeners();
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
      hero.idleRate + passiveTree.totalOf(PassiveEffect.idleFlat) + prestigeIdleBonus + inventory.totalOf(ItemStat.wisdom) + petIdleRate;

  void generateIdleProgress() {
    idleProgress += _effectiveIdleRate;
    notifyListeners();
  }

  /// Called automatically every 60 s (12 ticks × 5 s).  Converts accumulated
  /// progress into gold using the INT-derived goldRate multiplier.
  void collectIdleRewards() {
    if (idleProgress == 0) return;
    final earned = (idleProgress * hero.goldRate * prestigeIdleMult * waystoneMult * allyIdleMult).round();
    gold      += earned;
    lastIdleGold = earned;
    idleProgress  = 0;
    _dailyIdleCollects++;
    _totalIdleCollects++;
    _totalGoldEarned += earned;
    audioService.playCoin();
    _checkAchievements();
    _setLastAction('⚡ Idle income: +$earned gold');
  }

  /// 0.0 → 1.0 fill of the current 60-second idle cycle.
  double get idleFillRatio {
    final rate = _effectiveIdleRate;
    return rate > 0 ? (idleProgress / (rate * 12)).clamp(0.0, 1.0) : 0.0;
  }

  /// Gold that will be awarded when the cycle completes.
  int get pendingIdleGold =>
      idleProgress * (hero.goldRate + inventory.totalOf(ItemStat.intelligence));

  /// Sustained gold earned per minute at current WIS + INT.
  int get idleGoldPerMinute =>
      _effectiveIdleRate * 12 * (hero.goldRate + inventory.totalOf(ItemStat.intelligence));

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

  int _calcShardDrop(Enemy enemy) {
    final base = (enemy.level * 5 + enemy.maxHealth ~/ 8 + 2);
    return (base * endlessUpgrades.shardMultiplier).round().clamp(1, 999999);
  }

  bool purchaseEndlessUpgrade(EndlessNode node) {
    final cost = endlessUpgrades.costFor(node);
    if (shards < cost) return false;
    // WIS Lv25 — Frugal Mind: 15% chance the upgrade costs 0 shards
    // Silver Tongue (CHA Lv5) 5% discount is already baked into costFor().
    if (!endlessUpgrades.frugalMind || _rng.nextInt(100) >= 15) {
      shards -= cost;
    }
    endlessUpgrades.upgrade(node);
    notifyListeners();
    saveToLocal();
    return true;
  }


  Map<String, dynamic> toJson() {
    return {
      '_savedAt': DateTime.now().toIso8601String(),
      'hero': hero.toJson(),
      'gold': gold,
      'shards': shards,
      'idleProgress': idleProgress,
      'campaignStageIndex': campaignStageIndex,
      'lastAction': lastAction,
      'upgrades': upgrades.map((u) => u.toJson()).toList(),
      'dailyChallenges': dailyChallenges.map((c) => c.toJson()).toList(),
      'lastDailyDate':   _lastDailyDate,
      'dailyKills':      _dailyKills,
      'dailyBattleWins': _dailyBattleWins,
      'dailyIdleCollects': _dailyIdleCollects,
      'dailyAbilityUses': _dailyAbilityUses,
      'dailyDamageDealt': _dailyDamageDealt,
      'dailyBossKills':  _dailyBossKills,
      'dailyItemEquipped': _dailyItemEquipped,
      'currentEnemy': currentEnemy?.toJson(),
      'battleLog': battleLog,
      'endlessUpgrades': endlessUpgrades.toJson(),
      'abilityRanks': Map<String, int>.from(_abilityRanks),
      'abilityBranches': Map<String, String>.from(abilityBranches),
      'prestigeLevel': prestigeLevel,
      'prestigeSouls': prestigeSouls,
      'prestigeShop': prestigeShop.toJson(),
      'subclassId': subclassId,
      'essence': essence,
      'passiveTree': passiveTree.toJson(),
      'inventory': inventory.toJson(),
      'crystals': crystals,
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
      'dailyChestClaimed': dailyChestClaimed,
      'equippedAuraId': equippedAuraId,
      'ownedAuraIds': ownedAuraIds.toList(),
      'equippedSkinId': equippedSkinId,
      'ownedSkinIds': ownedSkinIds.toList(),
      'equippedPetId': equippedPetId,
      'ownedPetIds': ownedPetIds.toList(),
      // PVP
      'pvpStamina':        pvpStamina,
      'pvpRefillEpochMs':  _pvpRefillEpochMs,
      'pvpRating':         pvpRating,
      'pvpWins':           pvpWins,
      'pvpLosses':         pvpLosses,
      // Dungeon
      'deepestDungeonFloor': _deepestDungeonFloor,
      // Tutorial flags
      'tutorialWelcomeSeen':  tutorialWelcomeSeen,
      'tutorialBattleSeen':   tutorialBattleSeen,
      'tutorialIdleSeen':     tutorialIdleSeen,
      'tutorialUpgradeSeen':  tutorialUpgradeSeen,
      'tutorialCampaignSeen': tutorialCampaignSeen,
      'tutorialDungeonSeen':  tutorialDungeonSeen,
      // Expeditions
      'activeExpedition': activeExpedition?.toJson(),
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
      // Boss Rush
      'bossRushBestScore': bossRushBestScore,
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
      'ownedArtifacts': ownedArtifacts.toList(),
      'equippedArtifacts': equippedArtifacts.map((k, v) => MapEntry(k.name, v)),
      // World Event
      'eventTokens':         eventTokens,
      'eventWeekSeed':       _eventWeekSeed,
      'eventRewardsClaimed': _eventRewardsClaimed.toList(),
      // Gauntlet
      'gauntletHighScore': gauntletHighScore,
      // NPC Allies
      'allyLevels':    Map<String, int>.from(_allyLevels),
      'dungeonClears': _dungeonClears,
      'bossRushClears': _bossRushClears,
      // Runes
      'runeDust': runeDust,
      'runeStockpile': Map<String, int>.from(_runeStockpile),
      'activeRunes': _activeRunes.map((k, v) => MapEntry(k.name, v?.toJson())),
      // Login streak
      'loginStreak':       loginStreak,
      'loginTodayClaimed': loginTodayClaimed,
      'lastLoginDate':     _lastLoginDate,
      // Ascension
      'ascensionLevel':  ascensionLevel,
      'ascensionPoints': ascensionPoints,
      'ascensionNodes':  Map<String, int>.from(_ascensionNodes),
      // Daily bounties
      'bountyDaySeed': _bountyDaySeed,
      'bounties': _dailyBounties.map((b) => b.toJson()).toList(),
      // Timestamp — used for offline progress calculation on next load
      'savedAt': DateTime.now().toIso8601String(),
    };
  }

  void loadFromJson(Map<String, dynamic> json) {
    hero.loadFromJson(json['hero'] as Map<String, dynamic>);
    gold = json['gold'] as int;
    shards = (json['shards'] as int?) ?? 0;
    idleProgress = json['idleProgress'] as int;
    campaignStageIndex = json['campaignStageIndex'] as int;
    lastAction = json['lastAction'] as String;

    upgrades
      ..clear()
      ..addAll((json['upgrades'] as List<dynamic>)
          .map((data) => Upgrade.fromJson(data as Map<String, dynamic>)));

    _lastDailyDate     = (json['lastDailyDate']   as String?) ?? '';
    _dailyKills        = (json['dailyKills']       as int?) ?? 0;
    _dailyBattleWins   = (json['dailyBattleWins']  as int?) ?? 0;
    _dailyIdleCollects = (json['dailyIdleCollects'] as int?) ?? 0;
    _dailyAbilityUses  = (json['dailyAbilityUses'] as int?) ?? 0;
    _dailyDamageDealt  = (json['dailyDamageDealt'] as int?) ?? 0;
    _dailyBossKills    = (json['dailyBossKills']   as int?) ?? 0;
    _dailyItemEquipped = (json['dailyItemEquipped'] as bool?) ?? false;

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
    battleLog = List<String>.from(json['battleLog'] as List<dynamic>);
    if (json['endlessUpgrades'] != null) {
      endlessUpgrades.loadFromJson(
          json['endlessUpgrades'] as Map<String, dynamic>);
    }
    _abilityRanks.clear();
    if (json['abilityRanks'] != null) {
      (json['abilityRanks'] as Map<String, dynamic>).forEach((k, v) {
        _abilityRanks[k] = v as int;
      });
    }
    abilityBranches.clear();
    if (json['abilityBranches'] != null) {
      (json['abilityBranches'] as Map<String, dynamic>).forEach((k, v) {
        abilityBranches[k] = v as String;
      });
    }
    prestigeLevel = (json['prestigeLevel'] as int?) ?? 0;
    prestigeSouls = (json['prestigeSouls'] as int?) ?? 0;
    if (json['prestigeShop'] != null) {
      prestigeShop.loadFromJson(json['prestigeShop'] as Map<String, dynamic>);
    }
    subclassId = json['subclassId'] as String?;
    essence = (json['essence'] as int?) ?? 0;
    if (json['passiveTree'] != null) {
      passiveTree.loadFromJson(json['passiveTree'] as Map<String, dynamic>);
    }
    if (json['inventory'] != null) {
      inventory.loadFromJson(json['inventory'] as Map<String, dynamic>);
    }
    crystals = (json['crystals'] as int?) ?? 0;
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
    dailyChestClaimed = (json['dailyChestClaimed'] as bool?) ?? false;
    equippedAuraId = json['equippedAuraId'] as String?;
    ownedAuraIds
      ..clear()
      ..addAll(((json['ownedAuraIds'] as List<dynamic>?) ?? []).cast<String>());
    equippedSkinId = json['equippedSkinId'] as String?;
    ownedSkinIds
      ..clear()
      ..addAll(((json['ownedSkinIds'] as List<dynamic>?) ?? []).cast<String>());
    equippedPetId = json['equippedPetId'] as String?;
    ownedPetIds
      ..clear()
      ..addAll(((json['ownedPetIds'] as List<dynamic>?) ?? []).cast<String>());
    activeExpedition = json['activeExpedition'] != null
        ? Expedition.fromJson(json['activeExpedition'] as Map<String, dynamic>)
        : null;
    bagTabsPurchased = (json['bagTabsPurchased'] as int?) ?? 0;
    inventory.bagCapacity = totalBagCapacity;
    gemShards = (json['gemShards'] as int?) ?? 0;
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
    bossRushBestScore = (json['bossRushBestScore'] as int?) ?? 0;
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
      ownedArtifacts.addAll(
          (json['ownedArtifacts'] as List<dynamic>).map((e) => e as String));
    }
    if (json['equippedArtifacts'] != null) {
      final raw = json['equippedArtifacts'] as Map<String, dynamic>;
      for (final slot in ArtifactSlot.values) {
        equippedArtifacts[slot] = raw[slot.name] as String?;
      }
    }
    final raceIdStr = json['heroRaceId'] as String?;
    if (raceIdStr != null) {
      heroRace = HeroRace.values.where((r) => r.name == raceIdStr).firstOrNull;
    }
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
    _dungeonClears  = (json['dungeonClears']  as int?) ?? 0;
    _bossRushClears = (json['bossRushClears'] as int?) ?? 0;
    // Runes
    runeDust = (json['runeDust'] as int?) ?? 0;
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
    _pvpRefillEpochMs = (json['pvpRefillEpochMs'] as int?) ?? 0;
    pvpRating        = (json['pvpRating']         as int?) ?? 1000;
    pvpWins          = (json['pvpWins']           as int?) ?? 0;
    pvpLosses        = (json['pvpLosses']         as int?) ?? 0;
    tickPvpStamina();
    _deepestDungeonFloor    = (json['deepestDungeonFloor']  as int?)  ?? 0;
    tutorialWelcomeSeen   = (json['tutorialWelcomeSeen']  as bool?) ?? false;
    tutorialBattleSeen    = (json['tutorialBattleSeen']   as bool?) ?? false;
    tutorialIdleSeen      = (json['tutorialIdleSeen']     as bool?) ?? false;
    tutorialUpgradeSeen   = (json['tutorialUpgradeSeen']  as bool?) ?? false;
    tutorialCampaignSeen  = (json['tutorialCampaignSeen'] as bool?) ?? false;
    tutorialDungeonSeen   = (json['tutorialDungeonSeen']  as bool?) ?? false;
    // Offline progress — compute idle earnings since last save
    offlineGoldEarned  = 0;
    offlineSecondsAway = 0;
    final savedAtStr = json['savedAt'] as String?;
    if (savedAtStr != null) {
      final savedAt = DateTime.tryParse(savedAtStr);
      if (savedAt != null) {
        final elapsed = DateTime.now().difference(savedAt);
        if (elapsed.inSeconds >= 120 && idleGoldPerMinute > 0) {
          final cappedSecs  = elapsed.inSeconds.clamp(0, 8 * 3600);
          final mins        = cappedSecs / 60.0;
          final offlineMult = waystoneActive ? _activeWaystoneMult : 1.0;
          final earned      = (mins * idleGoldPerMinute * offlineMult).round();
          if (earned > 0) {
            gold               += earned;
            _totalGoldEarned   += earned;
            offlineGoldEarned   = earned;
            offlineSecondsAway  = cappedSecs;
          }
        }
      }
    }
    notifyListeners();
  }

  Future<void> saveToLocal() async {
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
      cloudSaveService.syncSave(uid, data);
    } catch (_) {}
  }

  Future<bool> loadFromLocal() async {
    final raw = await saveService.loadRaw(slot: _currentSlot);
    if (raw == null) {
      _setLastAction('No save found.');
      return false;
    }
    loadFromJson(raw);
    _setLastAction('Loaded progress.');
    return true;
  }

  DateTime? get lastCloudSyncAt => _lastCloudSyncAt;

  Future<bool> googleSignIn() async {
    final user = await authService.signInWithGoogle();
    if (user == null) return false;
    // Immediately check for a newer cloud save.
    final cloudTs = await cloudSaveService.fetchLastSyncTime(user.uid);
    if (cloudTs != null) {
      final localTs = _parseLocalTimestamp(toJson());
      if (localTs == null || cloudTs.isAfter(localTs)) {
        final cloudRaw = await cloudSaveService.fetchSave(user.uid);
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
    await cloudSaveService.syncSave(user.uid, toJson());
    _setLastAction('Signed in. Cloud save synced.');
    notifyListeners();
    return true;
  }

  Future<void> googleSignOut() async {
    await authService.signOut();
    _setLastAction('Signed out.');
    notifyListeners();
  }

  Future<void> forceSyncToCloud() async {
    if (!authService.isGoogleSignedIn) return;
    final uid = authService.currentUser!.uid;
    _lastCloudSyncAt = DateTime.now();
    await cloudSaveService.syncSave(uid, toJson());
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
    await cloudSaveService.syncSave(user.uid, toJson());
    _setLastAction('Cloud save complete.');
  }

  Future<void> loadFromCloud() async {
    final user =
        authService.currentUser ?? await authService.signInAnonymously();
    if (user == null) {
      _setLastAction('Could not sign into cloud save.');
      return;
    }
    final raw = await cloudSaveService.fetchSave(user.uid);
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
}
