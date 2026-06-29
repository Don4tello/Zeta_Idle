import 'dart:async';
import 'dart:math';
import 'debug_logger.dart';
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

// Snapshot of a level-up that just occurred — shown in the victory overlay.
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
      onSubscriptionActivated: (productId, days) => activatePremium(days),
    );
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
        // Auto-campaign: resolve a battle in the background
        if (autoCampaign && currentEnemy == null && !heroDefeated) {
          _runAutoCampaignTick();
        }
      },
    );
  }

  int _currentSlot = 0;
  bool _slotLoaded = false;
  bool _endlessMode = false;

  // Per-battle perk state — reset at the start of every fight
  // ── Ally active ability state (reset each battle) ─────────────────────────
  final Set<String> _allyAbilitiesUsed = {};
  bool _lenaBackstabReady      = false;
  bool _felixBribeActive       = false;
  int  _rukStoneSkinRoundsLeft = 0;

  // _hasMomentum is NOT reset by _resetBattlePerks: it's set on kill and
  // consumed on the next attack roll, so it must survive the battle boundary.
  bool _hasMomentum         = false; // STR: Savage Momentum
  bool _unbrokenUsed        = false; // CON: Unbroken
  bool _battleAwarenessUsed = false; // WIS: Battle Awareness

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
    if (prestigeLevel < item.rebirthRequired) return false;
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

  // ── Shop & Monetization ────────────────────────────────────────────────────
  final Set<String> purchasedPacks = {};
  final Set<String> ownedCosmetics = {};
  String? activeTitle;
  String? activeNameColor;
  String? activeFrame;
  bool isPremiumSubscriber = false;
  int premiumExpiryMs = 0;

  bool get hasPremium =>
      isPremiumSubscriber && premiumExpiryMs > DateTime.now().millisecondsSinceEpoch;

  bool purchaseStarterPack(String packId) {
    if (purchasedPacks.contains(packId)) return false;
    final pack = StarterPack.all.where((p) => p.id == packId).firstOrNull;
    if (pack == null) return false;
    purchasedPacks.add(packId);
    for (final e in pack.contents.entries) {
      switch (e.key) {
        case 'crystals':  crystals += e.value;
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
          final setDrop = ItemLootTable.tryDropSet(hero.level, _rng);
          if (setDrop != null) inventory.addToBag(setDrop);
      }
    }
    logLoot('🎁', 'Purchased ${pack.name}');
    notifyListeners();
    saveToLocal();
    return true;
  }

  bool purchaseCosmetic(String cosmeticId) {
    if (ownedCosmetics.contains(cosmeticId)) return false;
    final item = CosmeticItem.all.where((c) => c.id == cosmeticId).firstOrNull;
    if (item == null) return false;
    if (crystals < item.crystalCost) return false;
    crystals -= item.crystalCost;
    ownedCosmetics.add(cosmeticId);
    notifyListeners();
    saveToLocal();
    return true;
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

  void activatePremium(int durationDays) {
    isPremiumSubscriber = true;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (premiumExpiryMs < now) premiumExpiryMs = now;
    premiumExpiryMs += durationDays * 24 * 60 * 60 * 1000;
    if (activeTitle == null) activeTitle = 'Premium';
    notifyListeners();
    saveToLocal();
  }

  // ── Campaign Energy ────────────────────────────────────────────────────────
  static const int maxEnergy = 20;
  static const int energyRechargeSeconds = 300; // 1 energy per 5 min
  int energy = maxEnergy;
  int _energyRefillEpochMs = 0;
  int dailyEnergyRefillsUsed = 0;
  static const int maxDailyRefills = 3;
  static const int refillAmount = 10;

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
    if (crystals < 50) return false;
    crystals -= 50;
    energy = maxEnergy;
    _energyRefillEpochMs = 0;
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

  void toggleAutoCampaign() {
    autoCampaign = !autoCampaign;
    notifyListeners();
    saveToLocal();
  }

  // Auto-loot settings
  bool autoDisenchantCommon = false;
  bool autoEquipUpgrades = false;

  void toggleAutoDisenchantCommon() {
    autoDisenchantCommon = !autoDisenchantCommon;
    notifyListeners();
    saveToLocal();
  }

  void toggleAutoEquipUpgrades() {
    autoEquipUpgrades = !autoEquipUpgrades;
    notifyListeners();
    saveToLocal();
  }

  void applyAutoLoot(EquipmentItem item) {
    if (autoDisenchantCommon && item.rarity == ItemRarity.common) {
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
    if (crystals < kSpeedBoostCrystalCost) return false;
    crystals -= kSpeedBoostCrystalCost;
    const sevenDays = 7 * 24 * 60 * 60 * 1000;
    final base = speedBoostActive
        ? speedBoostExpiryMs
        : DateTime.now().millisecondsSinceEpoch;
    speedBoostExpiryMs = base + sevenDays;
    notifyListeners();
    saveToLocal();
    return true;
  }

  void cycleBattleSpeed() {
    final maxTier = kDebugMode ? 4 : 3;
    speedTier = speedTier >= maxTier ? 1 : speedTier + 1;
    notifyListeners();
    saveToLocal();
  }

  String get battleSpeedLabel => switch (speedTier) {
    2 => '1.5×',
    3 => kDebugMode ? '5×' : '2×',
    4 => '10×',
    _ => '1×',
  };

  void setSpeedTier(int tier) {
    speedTier = tier.clamp(1, kDebugMode ? 4 : 3);
    notifyListeners();
    saveToLocal();
  }

  double get _speedFactor {
    switch (speedTier) {
      case 2: return 1.5;
      case 3: return kDebugMode ? 5.0 : 2.0;
      case 4: return 10.0;
      default: return 1.0;
    }
  }

  int scaledInterval(int baseMs) =>
      (baseMs / _speedFactor).round().clamp(60, baseMs);

  bool purchaseAura(String auraId) {
    final aura = kAuraCatalog.where((a) => a.id == auraId).firstOrNull;
    if (aura == null) return false;
    if (ownedAuraIds.contains(auraId)) return false;
    if (crystals < aura.crystalCost) return false;
    crystals -= aura.crystalCost;
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
    if (crystals < skin.crystalCost) return false;
    crystals -= skin.crystalCost;
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

  // Sums the bonus of a given type across every owned pet (passive on all, not just equipped).
  int _sumOwnedPetBonus(PetBonusType type) {
    var total = 0;
    for (final id in ownedPetIds) {
      final p = kPetCatalog.where((p) => p.id == id).firstOrNull;
      if (p != null && p.bonusType == type) {
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
    if (ownedPetIds.contains(petId)) return false;
    if (crystals < pet.crystalCost) return false;
    crystals -= pet.crystalCost;
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

  // Campaign Hard Mode + Stars
  bool campaignHardMode = false;
  Set<int> stageStars = {}; // stores "stage_star" encoded as stage*10+star(1-3)

  void toggleHardMode() {
    if (campaignStageIndex < 50) return;
    campaignHardMode = !campaignHardMode;
    notifyListeners();
    saveToLocal();
  }

  double get hardModeStatMult => campaignHardMode ? 2.0 : 1.0;
  double get hardModeRewardMult => campaignHardMode ? 1.5 : 1.0;

  int starsForStage(int stage) {
    int count = 0;
    for (int s = 1; s <= 3; s++) {
      if (stageStars.contains(stage * 10 + s)) count++;
    }
    return count;
  }

  void awardStar(int stage, int star) {
    final key = stage * 10 + star;
    if (!stageStars.contains(key)) {
      stageStars.add(key);
      addSeasonXp(15);
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
        if (tier >= 3) 'crystals': 5 * tier,
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
    return {'mythril': bonus, 'crystals': bonus * 2};
  }

  // Expedition critical success + rare events
  static const _rareExpeditions = [
    'Ancient Vault — 3× rewards',
    'Dragon Hoard — massive gold bonus',
    'Forgotten Shrine — rare essence cache',
    'Crystal Cavern — bonus crystals',
  ];

  bool rollCriticalSuccess() => _rng.nextInt(5) == 0; // 20% chance
  String? rollRareExpedition() => _rng.nextInt(8) == 0 // 12.5% chance
      ? _rareExpeditions[_rng.nextInt(_rareExpeditions.length)]
      : null;

  // Guild
  String? guildId;
  int guildCoins = 0;

  // Season Pass
  int seasonPassXp = 0;
  int seasonPassTier = 0;
  Set<int> seasonFreeClaimed = {};
  Set<int> seasonPremiumClaimed = {};
  int seasonMonth = 0; // tracks which month this data belongs to

  void addSeasonXp(int xp) {
    seasonPassXp += xp;
    while (seasonPassTier < SeasonPassTier.tiers.length &&
        seasonPassXp >= SeasonPassTier.tiers[seasonPassTier].xpRequired) {
      seasonPassXp -= SeasonPassTier.tiers[seasonPassTier].xpRequired;
      seasonPassTier++;
    }
    notifyListeners();
  }

  void claimSeasonFree(int tier) {
    if (tier > seasonPassTier || seasonFreeClaimed.contains(tier)) return;
    final t = SeasonPassTier.tiers[tier - 1];
    _applyRewards(t.freeRewards);
    seasonFreeClaimed.add(tier);
    notifyListeners();
    saveToLocal();
  }

  void claimSeasonPremium(int tier) {
    if (tier > seasonPassTier || seasonPremiumClaimed.contains(tier)) return;
    final t = SeasonPassTier.tiers[tier - 1];
    _applyRewards(t.premiumRewards);
    seasonPremiumClaimed.add(tier);
    notifyListeners();
    saveToLocal();
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
      if (c.id == id && c.isComplete && !c.claimed) {
        _applyRewards(c.rewards);
        c.claimed = true;
        addSeasonXp(50);
        notifyListeners();
        saveToLocal();
        return;
      }
    }
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
        'crystals': 3 * scale,
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
        case 'crystals':  crystals += e.value;
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
      'first_rebirth': prestigeLevel >= 1,
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
    'level_25' => {'gold': 2000, 'shards': 50, 'crystals': 10},
    'level_50' => {'gold': 5000, 'echoes': 100, 'crystals': 25},
    'level_100' => {'gold': 10000, 'echoes': 200, 'crystals': 50, 'mythril': 10},
    'first_rebirth' => {'crystals': 100, 'mythril': 20, 'echoes': 300},
    'kills_100' => {'gold': 1000, 'shards': 30},
    'kills_1000' => {'gold': 5000, 'echoes': 50, 'crystals': 15},
    'pvp_10_wins' => {'gemShards': 50, 'echoes': 50},
    'pvp_50_wins' => {'gemShards': 150, 'crystals': 30, 'echoes': 100},
    'stage_25' => {'gold': 3000, 'shards': 50},
    'stage_50' => {'gold': 8000, 'echoes': 75, 'crystals': 20},
    'stage_100' => {'gold': 20000, 'echoes': 200, 'crystals': 50},
    'dungeon_10' => {'essence': 200, 'shards': 80},
    'guild_joined' => {'guildCoins': 50, 'gold': 2000},
    _ => {'gold': 500},
  };

  void claimMilestoneRewards(String id) {
    final rewards = milestoneRewards(id);
    if (rewards.containsKey('gold')) gold += rewards['gold']!;
    if (rewards.containsKey('shards')) shards += rewards['shards']!;
    if (rewards.containsKey('crystals')) crystals += rewards['crystals']!;
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
    if (cost == null || crystals < cost) return false;
    crystals -= cost;
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
    1 => {'gemShards': 30, 'echoes': 100, 'crystals': 20, 'guildCoins': 50},
    2 => {'gemShards': 20, 'echoes': 70, 'crystals': 15, 'guildCoins': 35},
    3 => {'gemShards': 15, 'echoes': 50, 'crystals': 10, 'guildCoins': 25},
    4 => {'gemShards': 10, 'echoes': 30, 'crystals': 5, 'guildCoins': 15},
    5 => {'gemShards': 5, 'echoes': 15, 'guildCoins': 10},
    _ => {},
  };

  void claimPvpDailyReward() {
    if (pvpDailyRewardClaimed || pvpDailyRank == 0) return;
    final rewards = pvpDailyRewards;
    if (rewards.containsKey('gemShards')) gemShards += rewards['gemShards']!;
    if (rewards.containsKey('echoes'))    echoes += rewards['echoes']!;
    if (rewards.containsKey('crystals'))  crystals += rewards['crystals']!;
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
    }
    // Rune drop: 10% on boss kills from external modes
    if (isBoss) rollRuneDrop();
  }

  void recordPvpResult(bool won) {
    pvpDailyDamage += (hero.damageMod + hero.attackBonus + hero.level) * 10;
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
    rating:  pvpRating,
    wins:    pvpWins,
    losses:  pvpLosses,
  );

  // ── Medieval Power Score ────────────────────────────────────────────────────
  int get medievalPower {
    var score = 0;

    // Base stats
    score += hero.level * 10;
    score += hero.maxHealth ~/ 2;
    score += (hero.attackBonus + hero.damageMod) * 5;
    score += hero.armorClass * 3;

    // Equipment: base damage + stat bonuses
    score += inventory.equippedWeaponDamage * 2;
    for (final item in inventory.equipped.values) {
      for (final b in item.bonuses) {
        score += b.value * 3;
      }
      if (item.gem != null) score += 10 + item.gem!.tier.index * 8;
      score += switch (item.rarity) {
        ItemRarity.common => 5,
        ItemRarity.rare => 15,
        ItemRarity.epic => 30,
        ItemRarity.legendary => 60,
        ItemRarity.set => 40,
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

    // Prestige
    score += prestigeLevel * 100;
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
  static const List<int> stashTabCosts = [50, 100, 200, 400]; // crystals per tab (4 extra tabs max)
  int get stashTabCount    => 1 + bagTabsPurchased;
  int get totalBagCapacity => 20 * stashTabCount;
  bool get canBuyStashTab  => bagTabsPurchased < stashTabCosts.length;
  int? get nextStashTabCost => canBuyStashTab ? stashTabCosts[bagTabsPurchased] : null;

  bool purchaseStashTab() {
    if (!canBuyStashTab) return false;
    final cost = stashTabCosts[bagTabsPurchased];
    if (crystals < cost) return false;
    crystals -= cost;
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
    crystals += rewards['crystals'] ?? 0;
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
      'A cluster of luminous crystals still pulsing with geomantic power.',
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
      LocationBiome.dungeon    => {'gold': base * 180, 'shards': base * 16, 'crystals': (base / 2).ceil()},
      LocationBiome.catacombs  => {'gold': base * 300, 'shards': base * 10, 'essence': base * 2},
      LocationBiome.sanctum    => {'gold': base * 200, 'shards': base * 4,  'essence': base * 4, 'crystals': (base / 2).ceil()},
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

  bool buyExtraDungeonAttempt()  { if (crystals < kDungeonExtraCost)  return false; crystals -= kDungeonExtraCost;  _dungeonAttemptsUsed  = (_dungeonAttemptsUsed  - 1).clamp(0, 99); notifyListeners(); saveToLocal(); return true; }
  bool buyExtraGauntletAttempt() { if (crystals < kGauntletExtraCost) return false; crystals -= kGauntletExtraCost; _gauntletAttemptsUsed = (_gauntletAttemptsUsed - 1).clamp(0, 99); notifyListeners(); saveToLocal(); return true; }
  bool buyExtraBossRushAttempt() { if (crystals < kBossRushExtraCost) return false; crystals -= kBossRushExtraCost; _bossRushAttemptsUsed = (_bossRushAttemptsUsed - 1).clamp(0, 99); notifyListeners(); saveToLocal(); return true; }

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
    crystals += c.rewardCrystals;
    _setLastAction('Claimed: ${c.title}! +${c.rewardGold}g +${c.rewardShards}◆ +${c.rewardEssence} essence +${c.rewardCrystals}💎');
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

  static const bestiaryMilestones = [10, 50, 100];
  static const _milestoneRewards = {10: 100, 50: 300, 100: 800};
  final Set<String> _claimedBestiaryMilestones = {};

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
    final reward = _milestoneRewards[milestone] ?? 100;
    gold += reward;
    notifyListeners();
    saveToLocal();
  }

  bool isBestiaryMilestoneClaimed(String enemyId, int milestone) =>
      _claimedBestiaryMilestones.contains('${enemyId}_$milestone');

  // Weakness attack bonus: 0% at 0 kills → +10% at 100 kills (+1% per 10 kills)
  double bestiaryWeaknessBonus(String enemyId) {
    if (bestiaryFor(enemyId) == null) return 1.0;
    return weaknessBonusMult(enemyId, bestiaryKillCount(enemyId));
  }

  // Hero elemental resistance derived from core stats (includes equipment bonuses).
  // STR→Physical, DEX→Lightning, CON→Poison, INT→Void, WIS→Cold, CHA→Fire.
  // Scales linearly: 0% at stat 0, 25% at stat 100 (kStatCap) from base stats alone.
  // Items/passives/rebirth bonuses add to tot() and can push the total up to ±75%.
  int heroResistancePct(DamageType type) {
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
    final passiveAll = passiveTree.totalOf(PassiveEffect.allRes);
    final gemRes = gemElemResPct(type);
    return (statBased + passivePerElem + passiveAll + gemRes).clamp(-75, 75);
  }

  double passiveElemDamagePct(DamageType type) => switch (type) {
    DamageType.physical  => 0.0,
    DamageType.fire      => passiveTree.totalOf(PassiveEffect.fireDamage).toDouble(),
    DamageType.cold      => passiveTree.totalOf(PassiveEffect.coldDamage).toDouble(),
    DamageType.lightning => passiveTree.totalOf(PassiveEffect.lightningDamage).toDouble(),
    DamageType.poison    => passiveTree.totalOf(PassiveEffect.poisonDamage).toDouble(),
    DamageType.void_     => passiveTree.totalOf(PassiveEffect.voidDamage).toDouble(),
  };

  // Chapter completion: all 5 enemies in a category killed ≥1 time
  bool isBestiaryChapterComplete(String category) {
    final entries = kBestiaryEntries.where((e) => e.category == category);
    return entries.every((e) => bestiaryDiscovered(e.enemyId));
  }

  // Permanent ATK bonus: +1 per unique enemy discovered in the bestiary
  int get bestiaryChapterBonus {
    return kBestiaryEntries.where((e) => bestiaryDiscovered(e.enemyId)).length;
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
    crystals += 5;
    _setLastAction('Bestiary chapter "$category" completed! +500g +15✦ +5💎');
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
    if (crystals < cost) return false;
    crystals -= cost;
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
    if (crystals < 100) return false;
    crystals -= 100;
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
    if (crystals < cost) return false;
    crystals -= cost;
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
    if (crystals < 30) return false;
    crystals -= 30;
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

  bool forgeArtifact() {
    final cost = forgeCost;
    if (mythril < cost) return false;
    mythril -= cost;
    final dropLv = (campaignStageIndex ~/ 5).clamp(1, 50);
    ownedArtifacts.add(ArtifactGenerator.roll(dropLevel: dropLv, rng: _rng));
    notifyListeners();
    saveToLocal();
    return true;
  }

  void disenchantArtifact(String uid) {
    final art = ownedArtifacts.where((a) => a.uid == uid).firstOrNull;
    if (art == null) return;
    artifactGrid.removeWhere((_, v) => v == uid);
    ownedArtifacts.removeWhere((a) => a.uid == uid);
    mythril += (forgeCost * 0.33).round().clamp(1, 999);
    notifyListeners();
    saveToLocal();
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

  // Aggregate artifact stat bonuses
  int get artifactAttackBonus  => _sumArtifacts((a) => a.attackBonus);
  int get artifactDamageBonus  => _sumArtifacts((a) => a.damageBonus);
  int get artifactAcBonus      => _sumArtifacts((a) => a.acBonus);
  int get artifactHpPct        => _sumArtifacts((a) => a.hpPct);
  int get artifactShardPct     => _sumArtifacts((a) => a.shardPct);
  int get artifactGoldPct      => _sumArtifacts((a) => a.goldPct);
  int get artifactXpPct        => _sumArtifacts((a) => a.xpPct);

  int _sumArtifacts(int Function(Artifact) f) =>
      artifactGrid.values
          .map(artifactByUid)
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
    final dayInCycle = ((loginStreak - 1) % LoginReward.cycle.length) + 1;
    final reward = LoginReward.forDay(dayInCycle);
    if (reward.gold > 0)     gold += reward.gold;
    if (reward.crystals > 0) crystals += reward.crystals;
    if (reward.shards > 0)   shards += reward.shards;
    if (reward.echoes > 0)   echoes += reward.echoes;
    if (reward.mythril > 0)  mythril += reward.mythril;
    if (reward.essence > 0)  essence += reward.essence;
    if (reward.isEpicItem) {
      final slot = ItemSlot.values[_rng.nextInt(ItemSlot.values.length)];
      final item = ItemLootTable.craftAt(slot, ItemRarity.epic, hero.level, _rng, rebirthLevel: prestigeLevel);
      inventory.addToBag(item);
      lastLoginLegendary = item;
    }
    if (reward.isClassLegendary) {
      final slot = ItemSlot.values[_rng.nextInt(ItemSlot.values.length)];
      final base = ItemLootTable.craftAt(slot, ItemRarity.legendary, hero.level, _rng, rebirthLevel: prestigeLevel);
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
    final shop = WorldEventReward.eventShop(hero.level);
    final reward = shop.where((r) => r.id == rewardId).firstOrNull;
    if (reward == null || eventTokens < reward.tokenCost) return false;
    eventTokens -= reward.tokenCost;
    _eventRewardsClaimed.add(rewardId);
    if (reward.crystals > 0) crystals += reward.crystals;
    if (reward.gold > 0) gold += reward.gold;
    if (reward.shards > 0) shards += reward.shards;
    if (reward.essence > 0) essence += reward.essence;
    if (reward.mythril > 0) mythril += reward.mythril;
    if (reward.echoes > 0) echoes += reward.echoes;
    if (reward.type == EventRewardType.gear && reward.gearSlot != null && reward.gearRarity != null) {
      final item = ItemLootTable.craftAt(
        reward.gearSlot!, reward.gearRarity!, hero.level, _rng,
        rebirthLevel: prestigeLevel,
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

  void recordGauntletResult(GauntletResult result, {int tier = 1}) {
    if (result.score > gauntletHighScore) gauntletHighScore = result.score;
    if (result.cleared && tier >= gauntletHighestTier) gauntletHighestTier = tier;
    if (result.essenceEarned > 0) essence += result.essenceEarned;
    if (result.crystalsEarned > 0) crystals += result.crystalsEarned;
    if (result.echoesEarned > 0) echoes += result.echoesEarned;
    if (result.cleared) rollRuneDrop(guaranteed: true);
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
  int  get allyAtkBonus  => _allyIntStat((a) => a.atkBonus,  (t) => t.atkBonus)
                          + activeSynergies.fold(0, (s, y) => s + y.atkBonus);
  int  get allyDmgBonus  => _allyIntStat((a) => a.dmgBonus,  (t) => t.dmgBonus)
                          + activeSynergies.fold(0, (s, y) => s + y.dmgBonus);
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
        _shopStock.add(ItemLootTable.craftAt(slot, rarity, max(1, hero.level), rng,
            rebirthLevel: prestigeLevel));
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

  bool respecBranch(PassiveBranch branch) {
    final refund = passiveTree.respecBranchRefund(branch);
    if (passiveTree.branchPointsSpent(branch) == 0) return false;
    passiveTree.respecBranch(branch);
    essence += refund;
    notifyListeners();
    saveToLocal();
    return true;
  }

  bool fullRespec() {
    if (crystals < 50) return false;
    final refund = passiveTree.fullRespecRefund;
    crystals -= 50;
    passiveTree.fullRespec();
    essence += refund;
    notifyListeners();
    saveToLocal();
    return true;
  }

  // Prestige
  int prestigeLevel = 0;
  int prestigeSouls = 0;
  final PrestigeShop prestigeShop = PrestigeShop();

  // Rebirth gates: every 25 stages (25, 50, 75, 100). Must be exactly AT the gate.
  bool get canPrestige => campaignStageIndex >= 100;

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

  double get prestigeGoldMult    => (1.0 + prestigeLevel * 0.10) * ascGoldMult * ascPrestigeMult;
  double get prestigeXpMult      => (1.0 + prestigeLevel * 0.05)
      * (prestigeShop.isUnlocked('swift_learner') ? 1.20 : 1.0)
      * ascXpMult * ascPrestigeMult;
  double get prestigeIdleMult    => (1.0 + prestigeLevel * 0.05) * ascIdleMult * ascPrestigeMult;
  double get prestigeShardMult   => (prestigeShop.isUnlocked('carrion_picker') ? 1.35 : 1.0) * ascShardMult;
  double get prestigeEssenceMult => (prestigeShop.isUnlocked('essence_bonus')  ? 1.35 : 1.0) * ascEssenceMult;
  int    get prestigeIdleBonus   => prestigeShop.isUnlocked('idle_bonus') ? 10 : 0;
  int    get prestigeStartGold {
    var g = 0;
    if (prestigeShop.isUnlocked('start_gold'))  g += 600;
    if (prestigeShop.isUnlocked('war_spoils'))  g += 2500;
    return g;
  }
  int get prestigeHeadStart {
    if (prestigeShop.isUnlocked('head_start_2')) return 15; // Stage 16
    if (prestigeShop.isUnlocked('head_start'))   return 5;  // Stage 6
    return 0;
  }
  double get prestigeAbilityDiscount =>
      prestigeShop.isUnlocked('ability_disc') ? 0.75 : 1.0;
  int get forgeCommonToRareCount =>
      prestigeShop.isUnlocked('forge_bonus') ? 2 : 3;

  // ── New prestige effect getters ────────────────────────────────────────────
  int    get prestigeHpPct          => prestigeShop.isUnlocked('iron_resolve')  ? 20 : 0;
  bool   get prestigeHealOnKill     => prestigeShop.isUnlocked('blood_drinker');
  int    get prestigeCritBonus      => prestigeShop.isUnlocked('killing_blow')  ? 5  : 0;
  double get prestigeCritDamageMult => prestigeShop.isUnlocked('deaths_edge')   ? 1.6: 1.0;
  double get prestigeGoldBattleMult => prestigeShop.isUnlocked('treasure_sense')? 1.25: 1.0;
  int    get prestigeSoulConduit    => prestigeShop.isUnlocked('soul_conduit')  ? 3  : 0;

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
    final savedEchoes       = echoes;
    final savedRanks        = Map<String, int>.from(_abilityRanks);
    final savedBranches     = Map<String, String>.from(abilityBranches);
    final savedMilestones   = Map<String, String>.from(_milestoneChoices);
    final savedEssence      = essence;
    final savedTree         = Map<String, dynamic>.from(passiveTree.toJson());
    final savedQuests       = Map<String, bool>.from(questsClaimed);
    final savedTitle        = heroTitle;
    final savedAbilityUses  = _totalAbilityUses;
    // Scale souls: 1 per 5 stages cleared, up to 200 for a full run; soul_conduit adds +3
    final soulsEarned = (campaignStageIndex / 5).floor().clamp(1, 200) + prestigeSoulConduit;
    final savedPrestigeLvl = prestigeLevel + 1;
    final savedSouls       = prestigeSouls + soulsEarned;
    final savedShopOwned   = Map<String, bool>.from(prestigeShop.ownedNodes);
    mythril += 10; // prestige reward
    _resetToDefaults(savedName, savedClass);
    prestigeLevel  = savedPrestigeLvl;
    prestigeSouls  = savedSouls;
    prestigeShop.restoreOwned(savedShopOwned);
    shards = savedShards;
    echoes = savedEchoes;
    essence = savedEssence;
    _abilityRanks
      ..clear()
      ..addAll(savedRanks);
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
    DebugLogger.log('prestige',
        'level=$prestigeLevel souls_total=$prestigeSouls souls_earned=${savedSouls - prestigeSouls} hero=${hero.name}');
    notifyListeners();
    saveToLocal();
  }

  // ── Ascension ─────────────────────────────────────────────────────────────
  int ascensionLevel  = 0;
  int ascensionPoints = 0;
  final Map<String, int> _ascensionNodes = {};

  bool get canAscend => prestigeLevel >= 5;
  int  get ascensionPointsForNextAscension => 3;

  // ── Game-loop connection signals ─────────────────────────────────────────
  int get consecutiveLosses => _consecutiveLosses;

  bool get hasAffordableAbilityUpgrade {
    final abilities = AbilityData.forClass(hero.heroClass);
    return abilities.any((a) {
      if (hero.level < a.levelRequired) return false;
      final rank = abilityRank(a.id);
      if (rank >= 100) return false;
      return shards >= abilityUpgradeCost(a.id);
    });
  }

  bool get hasAffordablePassiveNode =>
      kPassiveNodes.any((n) =>
          passiveTree.canUpgrade(n.id) &&
          essence >= passiveTree.costForNextRank(n.id));

  bool get hasAffordableEndlessUpgrade =>
      EndlessNode.values.any((n) => endlessUpgrades.canAfford(n, echoes));

  /// Priority-ordered hint for "what should I do next?" indicator.
  String? get nextActionHint {
    if (canPrestige) return '✨ Prestige available — reset for power!';
    if (hasAffordableAbilityUpgrade) return '⚔ Ability upgrade affordable';
    if (hasAffordablePassiveNode) return '🌿 Passive upgrade affordable';
    if (hasAffordableEndlessUpgrade) return '🔮 Endless upgrade affordable';
    if (consecutiveLosses >= 3 && canPrestige) return '💀 Stuck? Consider Prestige!';
    if (campaignStageIndex >= 20 && campaignStageIndex % 25 >= 18) {
      final remaining = 25 - (campaignStageIndex % 25);
      return '🏆 $remaining stages until Prestige gate!';
    }
    return null;
  }

  // Endless kill tracking for milestone rewards
  int _totalEndlessKills = 0;
  int get totalEndlessKills => _totalEndlessKills;
  static const _endlessMilestones = [5, 10, 25, 50, 100, 200, 500];
  int? lastEndlessMilestone;

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
    final savedArtifacts     = List<Artifact>.from(ownedArtifacts);
    final savedArtifactGrid  = Map<int, String>.from(artifactGrid);
    final savedUnlocked      = _unlockedArtifactCells;
    // Full reset (includes zeroing prestige + ascension)
    _resetToDefaults(savedName, savedClass);
    // Restore ascension-permanent data
    ascensionLevel  = savedAscLevel;
    ascensionPoints = savedAscPoints;
    _ascensionNodes.addAll(savedNodes);
    mythril = savedMythril;
    ownedArtifacts.addAll(savedArtifacts);
    artifactGrid.addAll(savedArtifactGrid);
    _unlockedArtifactCells = savedUnlocked;
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
    final result = ItemLootTable.craftAt(slot, target, hero.level, _rng, rebirthLevel: prestigeLevel);
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
      battleLog.add('🔮 Duplicate rune "${rune.name}" → +$dust Rune Dust');
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
      (campaignStageIndex % 5 == 4 && campaignStageIndex < CampaignData.stages.length) ||
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
  DamageType _dotDamageType = DamageType.physical;

  // Floating number events to display this turn (cleared by battle_screen)
  final List<({int value, bool isHeal, DamageType type})> pendingFloats = [];
  void clearPendingFloats() => pendingFloats.clear();
  int _enemyStunRounds = 0;
  bool _dodgeNextHit = false;
  int _auraHealPerRound = 0;
  int _auraRoundsLeft = 0;
  int _enemyWeakenPct = 0;
  int _enemyWeakenRounds = 0;
  int _enemyVulnerablePct = 0;
  int _enemyVulnerableRounds = 0;

  // Boss ability state — reset each battle
  final Map<String, int> _bossAbilityCooldowns = {};
  int _heroDotRoundsLeft = 0;
  int _heroDotDmgPerRound = 0;
  DamageType _heroDotType = DamageType.physical;
  int _heroStunRounds = 0;

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
    _dotDamageType        = DamageType.physical;
    _enemyStunRounds      = 0;
    _dodgeNextHit         = false;
    _auraHealPerRound     = 0;
    _auraRoundsLeft       = 0;
    _enemyWeakenPct       = 0;
    _enemyWeakenRounds    = 0;
    _enemyVulnerablePct    = 0;
    _enemyVulnerableRounds = 0;
    _bossAbilityCooldowns.clear();
    _heroDotRoundsLeft     = 0;
    _heroDotDmgPerRound    = 0;
    _heroDotType           = DamageType.physical;
    _heroStunRounds        = 0;
    _allyAbilitiesUsed.clear();
    _lenaBackstabReady      = false;
    _felixBribeActive       = false;
    _rukStoneSkinRoundsLeft = 0;
  }

  // ── Ally active ability helpers ─────────────────────────────────────────────

  // Returns true if we should early-return from heroAttack (enemy killed by Arcane Surge).
  bool _fireAllyBattleStartAbilities(Enemy enemy) {
    if (allyUnlocked('greybeard') && !_allyAbilitiesUsed.contains('greybeard')) {
      _allyAbilitiesUsed.add('greybeard');
      _tempAttackBonus += 5;
      _tempAttackBonusRounds = max(_tempAttackBonusRounds, 4);
      battleLog.add('📣 Greybeard: War Cry! +5 ATK for 4 rounds.');
    }
    if (allyUnlocked('elder_voss') && !_allyAbilitiesUsed.contains('elder_voss')) {
      _allyAbilitiesUsed.add('elder_voss');
      final burst = (enemy.maxHealth * 0.10).round().clamp(1, 9999);
      enemy.takeDamage(burst);
      battleLog.add('🔮 Voss: Arcane Surge! ${enemy.name} takes $burst arcane damage!');
      if (enemy.isDefeated) { _battleVictory(enemy); return true; }
    }
    if (allyUnlocked('coin_felix') && !_allyAbilitiesUsed.contains('coin_felix')) {
      _felixBribeActive = true;
      battleLog.add('🤑 Felix: Bribe! ${enemy.name} will drop 2× gold!');
    }
    if (allyUnlocked('shadow_lena') && !_allyAbilitiesUsed.contains('shadow_lena')) {
      _allyAbilitiesUsed.add('shadow_lena');
      _lenaBackstabReady = true;
      battleLog.add("🌑 Lena: Backstab primed! First hit is a guaranteed critical!");
    }
    if (allyUnlocked('golem_ruk') && !_allyAbilitiesUsed.contains('golem_ruk')) {
      _allyAbilitiesUsed.add('golem_ruk');
      _rukStoneSkinRoundsLeft = 5;
      battleLog.add('🪨 Ruk: Stone Skin! Incoming damage −4 for 5 rounds.');
    }
    return false;
  }

  void _checkAllyHpAbilities() {
    if (hero.currentHealth <= 0) return;
    // Mira: Field Triage — heal 25% max HP when hero drops below 30%
    if (allyUnlocked('mira') && !_allyAbilitiesUsed.contains('mira') &&
        hero.currentHealth < hero.maxHealth * 0.30) {
      _allyAbilitiesUsed.add('mira');
      final heal = (hero.maxHealth * 0.25).round().clamp(1, hero.maxHealth);
      hero.currentHealth = (hero.currentHealth + heal).clamp(0, hero.maxHealth);
      battleLog.add('💉 Mira: Field Triage! ${hero.name} is healed for $heal HP!');
    }
    // Ironhide: Shield Wall — block next hit when hero drops below 50%
    if (allyUnlocked('ironhide') && !_allyAbilitiesUsed.contains('ironhide') &&
        hero.currentHealth < hero.maxHealth * 0.50) {
      _allyAbilitiesUsed.add('ironhide');
      _dodgeNextHit = true;
      battleLog.add('🪨 Ironhide: Shield Wall! Next incoming attack is blocked!');
    }
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

  static const abilityRespecCost = 150;

  bool respecAbilities() {
    if (crystals < abilityRespecCost) return false;
    // Calculate shard refund
    var refund = 0;
    for (final entry in _abilityRanks.entries) {
      for (int r = 0; r < entry.value; r++) {
        if (r < _abilityUpgradeCosts.length) refund += _abilityUpgradeCosts[r];
      }
    }
    crystals -= abilityRespecCost;
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
    QuestCondition.prestigeReach     => prestigeLevel,
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
    crystals += r.crystals;
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

  // ── Milestone choices ─────────────────────────────────────────────────────

  final Map<String, String> _milestoneChoices = {};

  String? milestoneChoice(String abilityId, int rank) =>
      _milestoneChoices['${abilityId}_m$rank'];

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
    5000, 5000, 5000,  5000,          // ranks 96–99 (100th rank = maxed)
  ];

  int abilityUpgradeCost(String id) {
    final rank = abilityRank(id);
    if (rank >= 100) return 0;
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
    return ability.value + rank * max(1, ability.value ~/ 8);
  }

  int scaledAbilityCooldown(HeroAbility ability) {
    final subclassDiscount = subclassEffect == SubclassEffect.arcaneTrickster ? 1 : 0;
    final rankReduction    = abilityRank(ability.id) ~/ 2;
    // Floor scales with unlock level: lv1=1, lv5=2, lv10=3, lv15=4, lv20+=5
    final minCooldown = (ability.levelRequired ~/ 5 + 1).clamp(1, 5);
    final uniqueItem = inventory.equipped.values
        .where((i) => i.uniqueAbilityId == ability.id)
        .firstOrNull;
    final uniqueCdReduce = uniqueItem?.abilityCooldownFlat ?? 0;
    return max(minCooldown, ability.cooldownRounds - rankReduction
        - passiveTree.totalOf(PassiveEffect.cooldownReduce) - subclassDiscount
        - traitCooldownReduction - uniqueCdReduce);
  }

  // Buff/debuff state exposed for the HUD
  int get buffAttackBonus  => _tempAttackBonus;
  int get buffAttackRounds => _tempAttackBonusRounds;
  int get buffAcBonus      => _tempAcBonus;
  int get buffAcRounds     => _tempAcBonusRounds;
  int get dotDmg           => _dotDmg;
  int get dotRoundsLeft    => _dotRoundsLeft;
  int get enemyStunRounds      => _enemyStunRounds;
  bool get dodgeNextHit        => _dodgeNextHit;
  int get auraHealPerRound     => _auraHealPerRound;
  int get auraRoundsLeft       => _auraRoundsLeft;
  int get enemyWeakenPct       => _enemyWeakenPct;
  int get enemyWeakenRounds    => _enemyWeakenRounds;
  int get enemyVulnerablePct   => _enemyVulnerablePct;
  int get enemyVulnerableRounds => _enemyVulnerableRounds;
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
    audioService.playAbilityByCategory(ability.category);
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
    final int sv    = (rank == 0 || baseValue == 0)
        ? (baseValue * uniqueMult).round()
        : ((baseValue + rank * max<int>(1, baseValue ~/ 8)) * uniqueMult).round();
    final effectiveDuration = ability.duration + durationDeltaSum + uniqueDurAdd;
    final primaryEffect     = effectOverride ?? ability.effect;

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
    final healBoostMult  = 1.0 + passiveTree.totalOf(PassiveEffect.healBoost) / 100.0
        + subclassHealBonus;
    if (subclassEffect == SubclassEffect.valorSurge) _valorSurgeReady = true;

    // Shared context params for damage abilities
    final exploitAcThreshold = endlessUpgrades.synergyMindweave ? 16 : 14;
    final _abilityExploitMult = (endlessUpgrades.exploitWeakness && enemy.armorClass <= exploitAcThreshold) ? 1.15 : 1.0;
    final _abilityWeakMult    = bestiaryWeaknessBonus(enemy.id);
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
        final baseDmg = _rng.nextInt(sv) + 1 + hero.damageMod;
        final ctx = buildAbilityAttackContext(
          baseDmg:              baseDmg,
          heroType:             hero.activeDamageType,
          allDamagePct:         passiveTree.totalOf(PassiveEffect.allDamage).toDouble()
                                + passiveElemDamagePct(hero.activeDamageType)
                                + gemElemDamagePct(hero.activeDamageType)
                                + inventory.totalOf(ItemStat.damagePercent)
                                + hero.levelBonusDamagePct,
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
        final dmg = calculateDamage(ctx, rng: _rng).total.round().clamp(1, 9999);
        enemy.takeDamage(dmg);
        pendingFloats.add((value: dmg, isHeal: false, type: hero.activeDamageType));
        battleLog.add('${ability.name}! +$dmg bonus damage.');
        primaryHitDmg = dmg;
      case AbilityEffect.heal:
        var hp = (hero.maxHealth * sv / 100 * healBoostMult * 0.5).round().clamp(1, 9999);
        if (_activeAffixes.contains(ZoneAffix.voidCurse)) hp = (hp / 2).round().clamp(1, 9999);
        hero.currentHealth = (hero.currentHealth + hp).clamp(0, hero.maxHealth);
        pendingFloats.add((value: hp, isHeal: true, type: DamageType.physical));
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
        final sporeBonus = subclassEffect == SubclassEffect.sporeCircle ? 0.50 : 0.0;
        final dotCtx = buildAbilityAttackContext(
          baseDmg:              sv,
          heroType:             hero.activeDamageType,
          allDamagePct:         passiveTree.totalOf(PassiveEffect.allDamage).toDouble()
                                + passiveElemDamagePct(hero.activeDamageType)
                                + gemElemDamagePct(hero.activeDamageType)
                                + inventory.totalOf(ItemStat.damagePercent)
                                + hero.levelBonusDamagePct,
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
        _dotDmg = calculateDamage(dotCtx, rng: _rng).total.round().clamp(1, 9999);
        _dotRoundsLeft = effectiveDuration;
        _dotDamageType = hero.activeDamageType;
        battleLog.add('${ability.name}! ${enemy.name} takes $_dotDmg dmg/round for $effectiveDuration rounds.');
        primaryHitDmg = _dotDmg;
      case AbilityEffect.dodge:
        _dodgeNextHit = true;
        battleLog.add('${ability.name}! ${hero.name} will dodge the next attack.');
      case AbilityEffect.aura:
        // Scale with hero max HP so the HoT stays relevant through progression
        _auraHealPerRound = (hero.maxHealth * sv / 100 * healBoostMult).round().clamp(1, 9999);
        _auraRoundsLeft   = effectiveDuration;
        battleLog.add('${ability.name}! ${hero.name} regenerates $_auraHealPerRound HP/round for $effectiveDuration rounds.');
      case AbilityEffect.debuffWeaken:
        _enemyWeakenPct    = sv;
        _enemyWeakenRounds = effectiveDuration;
        battleLog.add('${ability.name}! ${enemy.name} ATK reduced by $sv% for $effectiveDuration rounds.');
      case AbilityEffect.debuffVulnerable:
        _enemyVulnerablePct    = sv;
        _enemyVulnerableRounds = effectiveDuration;
        battleLog.add('${ability.name}! ${enemy.name} takes $sv% more damage for $effectiveDuration rounds.');
    }

    // ── Bonus effect from active milestone choice ─────────────────────────
    if (bonusEff != null) {
      // Use the ability's actual damage output as the scaling reference;
      // fall back to sv for non-damage primaries (debuffs, buffs, etc.)
      final ref = primaryHitDmg ?? sv;
      switch (bonusEff) {
        case AbilityEffect.dot:
          // bonusVal is % of the ability's damage output per tick
          final dotBase = (ref * bonusVal / 100).round().clamp(1, 9999);
          final bonusDotCtx = buildAbilityAttackContext(
            baseDmg:              dotBase,
            heroType:             hero.activeDamageType,
            allDamagePct:         passiveTree.totalOf(PassiveEffect.allDamage).toDouble()
                                  + passiveElemDamagePct(hero.activeDamageType)
                                + gemElemDamagePct(hero.activeDamageType)
                                  + inventory.totalOf(ItemStat.damagePercent)
                                  + hero.levelBonusDamagePct,
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
          _dotDmg       = calculateDamage(bonusDotCtx, rng: _rng).total.round().clamp(1, 9999);
          _dotRoundsLeft = bonusDur;
          _dotDamageType = hero.activeDamageType;
          battleLog.add('Wound! ${enemy.name} takes $_dotDmg dmg/round for $bonusDur rounds.');
        case AbilityEffect.aura:
          // bonusVal is % of max HP per tick
          _auraHealPerRound = (hero.maxHealth * bonusVal / 100 * healBoostMult).round().clamp(1, 9999);
          _auraRoundsLeft   = bonusDur;
          battleLog.add('Healing aura! ${hero.name} regenerates $_auraHealPerRound HP/round for $bonusDur rounds.');
        case AbilityEffect.stun:
          _enemyStunRounds = bonusDur;
          battleLog.add('${enemy.name} is stunned for $bonusDur turn(s)!');
        case AbilityEffect.attackBonus:
          _tempAttackBonus = max(_tempAttackBonus, bonusVal);
          _tempAttackBonusRounds = max(_tempAttackBonusRounds, bonusDur);
          battleLog.add('+$bonusVal to attack for $bonusDur rounds.');
        default:
          break;
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
          _enemyStunRounds = xd;
          battleLog.add('$tag ${enemy.name} stunned for $xd turn(s)!');
        case AbilityEffect.dot:
          final dotBase = (ref * xv / 100).round().clamp(1, 9999);
          final xDotCtx = buildAbilityAttackContext(
            baseDmg: dotBase, heroType: hero.activeDamageType,
            allDamagePct: passiveTree.totalOf(PassiveEffect.allDamage).toDouble()
                          + passiveElemDamagePct(hero.activeDamageType)
                                + gemElemDamagePct(hero.activeDamageType)
                          + inventory.totalOf(ItemStat.damagePercent)
                          + hero.levelBonusDamagePct,
            abilityDamagePct: passiveTree.totalOf(PassiveEffect.abilityDamage).toDouble(),
            subclassAbilityBonus: subclassAbilityBonus,
            endlessDmgMult: endlessUpgrades.damageMultiplier,
            exploitMult: _abilityExploitMult, comboStacks: _comboStacks,
            bestiaryWeakMult: _abilityWeakMult, isDot: true,
            enemyResistances: enemy.resistances,
            penetration: _abilityPenMap(ability.penetration),
          );
          _dotDmg        = calculateDamage(xDotCtx, rng: _rng).total.round().clamp(1, 9999);
          _dotRoundsLeft = xd;
          _dotDamageType = hero.activeDamageType;
          battleLog.add('$tag ${enemy.name} takes $_dotDmg dmg/round for $xd rounds.');
        case AbilityEffect.attackBonus:
          _tempAttackBonus       = max(_tempAttackBonus, xv);
          _tempAttackBonusRounds = max(_tempAttackBonusRounds, xd);
          battleLog.add('$tag +$xv ATK for $xd rounds.');
        case AbilityEffect.acBonus:
          _tempAcBonus       = max(_tempAcBonus, xv);
          _tempAcBonusRounds = max(_tempAcBonusRounds, xd);
          battleLog.add('$tag +$xv AC for $xd rounds.');
        case AbilityEffect.aura:
          _auraHealPerRound = (hero.maxHealth * xv / 100 * healBoostMult).round().clamp(1, 9999);
          _auraRoundsLeft   = xd;
          battleLog.add('$tag ${hero.name} regenerates $_auraHealPerRound HP/round for $xd rounds.');
        case AbilityEffect.debuffWeaken:
          _enemyWeakenPct    = xv;
          _enemyWeakenRounds = xd;
          battleLog.add('$tag ${enemy.name} ATK reduced by $xv% for $xd rounds.');
        case AbilityEffect.debuffVulnerable:
          _enemyVulnerablePct    = xv;
          _enemyVulnerableRounds = xd;
          battleLog.add('$tag ${enemy.name} takes $xv% more damage for $xd rounds.');
        case AbilityEffect.dodge:
          _dodgeNextHit = true;
          battleLog.add('$tag ${hero.name} will dodge the next attack.');
        case AbilityEffect.heal:
          final hp = (hero.maxHealth * xv / 100 * healBoostMult * 0.5).round().clamp(1, 9999);
          hero.currentHealth = (hero.currentHealth + hp).clamp(0, hero.maxHealth);
          battleLog.add('$tag +$hp HP restored.');
        default:
          break;
      }
    }
  }

  // ── Endless mode ───────────────────────────────────────────────
  bool get hasEndlessEnemy => campaignStageIndex > 0;

  int get endlessStageIndex =>
      campaignStageIndex.clamp(0, EnemyData.enemies.length - 1);

  bool _isCampaignBattle = false;

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
    currentEnemy = EnemyData.enemyForStage(endlessStageIndex, affixes: _activeAffixes);
    hero.healToFull();
    battleLog = ['${hero.name} faces ${currentEnemy!.name} in the endless arena!'];
    if (_activeAffixes.isNotEmpty) {
      battleLog.add('Corruption: ${_activeAffixes.map((a) => a.displayName).join(', ')}');
    }
    _setLastAction('Endless battle started against ${currentEnemy!.name}.');
  }

  bool _pvpMode = false;

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
    heroDefeated = false;
    lastBattleWasFinalVictory = false;
    _resetBattlePerks();
    _activeAffixes = [];
    currentEnemy = Enemy(
      id: 'hero_${opponent.heroClass}',
      name: opponent.heroName,
      description: 'A rival hero.',
      maxHealth: opponent.maxHp,
      attack: opponent.damageMod + opponent.attackBonus,
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
    // Scale like campaign bosses: 2× HP, 1.25× ATK, +prestige scaling
    final hpMult = 2.0 * (1.0 + prestigeLevel * 0.15);
    final atkMult = 1.25 * (1.0 + prestigeLevel * 0.08);
    final acBonus = 2 + prestigeLevel ~/ 2;
    enemy = Enemy(
      id: enemy.id,
      name: '☠ ${enemy.name}',
      description: enemy.description,
      maxHealth: (enemy.maxHealth * hpMult).round().clamp(100, 9999999),
      attack: (enemy.attack * atkMult).round().clamp(10, 9999),
      level: enemy.level + 2,
      armorClass: enemy.armorClass + acBonus,
      attackType: enemy.attackType,
      resistances: enemy.resistances,
    );
    currentEnemy = enemy;
    hero.healToFull();
    battleLog = ['${hero.name} challenges ${currentEnemy!.name}!'];
    _setLastAction('Boss challenge started against ${currentEnemy!.name}.');
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
    if (!consumeDungeonAttempt()) return;
    activeDungeon = DungeonRun(heroMaxHp: hero.maxHealth, heroHp: hero.maxHealth, tier: tier);
    activeDungeon!.generateRoomChoices(_rng);
    notifyListeners();
    _setLastAction('Entered the dungeon — Tier $tier, Floor 1.');
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

    final earnedGold = run.resolveCombat(
      room,
      hero.attackBonus,
      hero.armorClass,
      0, // STR no longer gives flat damage (now Physical Damage %)
      _rng,
      abilities:   unlockedAbilities,
      getCooldown: scaledAbilityCooldown,
      getValue:    scaledAbilityValue,
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
        final rarity = _rng.nextInt(100) < (isBoss ? 30 : 15) ? ItemRarity.epic : ItemRarity.rare;
        final drop = ItemLootTable.craftAt(
          ItemSlot.values[_rng.nextInt(ItemSlot.values.length)],
          rarity,
          hero.level,
          _rng,
          rebirthLevel: prestigeLevel,
        );
        dungeonLastDrop = drop;
        room.hasItemDrop = true;
        inventory.addToBag(drop);
      }
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
      rebirthLevel: prestigeLevel,
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
    if (crystals < chestCrystalCost) return null;
    final opened = run.openChest(room, 9999);
    if (!opened) return null;
    crystals -= chestCrystalCost;
    final rarity = _rng.nextInt(100) < 15 ? ItemRarity.epic : ItemRarity.rare;
    final drop = ItemLootTable.craftAt(
      ItemSlot.values[_rng.nextInt(ItemSlot.values.length)],
      rarity,
      hero.level,
      _rng,
      rebirthLevel: prestigeLevel,
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
    // Tier clear: beating at least 1 boss unlocks auto-run for that tier
    if (run.bossesDefeated >= 1 && run.tier > _dungeonHighestTier) {
      _dungeonHighestTier = run.tier;
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
      {String? newName, DndClass? heroClass, HeroRace? heroRace, HeroTrait? trait, HeroGender? gender}) async {
    _currentSlot = slot;
    extraCharacterSlots = await SaveService.getExtraSlots();
    final raw = await saveService.loadRaw(slot: slot);
    if (raw != null) {
      loadFromJson(raw);
    } else {
      _resetToDefaults(newName ?? 'The Warden', heroClass ?? DndClass.fighter);
      if (heroRace != null) this.heroRace = heroRace;
      if (gender != null) hero.gender = gender;
      if (trait != null) _applyTrait(trait);
    }
    // If Google-signed-in, check if cloud save is newer and load it automatically.
    // Wrapped in try-catch so any Firebase error (e.g. SDK not configured yet)
    // never blocks character creation from completing.
    // Skip cloud load when creating a brand-new character (newName != null means
    // the caller just reset defaults — pulling the cloud save would overwrite it).
    final isNewCharacter = newName != null;
    try {
      if (!isNewCharacter && authService.isGoogleSignedIn) {
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
    hero.extraHpPct = traitHpPct + artifactHpPct + runeHpPct + allyHpPct + prestigeHpPct;
    hero.currentHealth = hero.currentHealth.clamp(1, hero.maxHealth);
  }

  void _resetToDefaults(String name, DndClass heroClass) {
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
    _dungeonAttemptsUsed  = 0;
    _gauntletAttemptsUsed = 0;
    _bossRushAttemptsUsed = 0;
    _pvpRefillsBought     = 0;
    pvpDailyWins          = 0;
    pvpDailyDamage        = 0;
    pvpDailyRewardClaimed = false;
    endlessUpgrades.reset();
    subclassId = null;
    // Reset tutorial so new character gets the welcome flow
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
    _deepestDungeonFloor = 0;
    _dungeonHighestTier  = 0;
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
    _activeExpeditions.clear();
    masteryLevels.clear();
    abilityBranches.clear();
    _milestoneChoices.clear();
    questsClaimed.clear();
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

  // True from the moment the first campaign enemy is defeated until the
  // player acknowledges the tutorial popup. Persisted so it survives restarts.
  bool endlessTutorialPending = false;
  Set<String> visitedModeTabs = {'CAMPAIGN'};

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
    dailyChestClaimed = true;
    gold     += 1000;
    shards   += 75;
    essence  += 50;
    crystals += 150;
    _setLastAction('Daily Chest claimed! +1000g +75◆ +50 essence +150 crystals');
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
  DamageType lastEnemyDamageType = DamageType.physical;

  // Combo streak — consecutive hits without missing or taking damage
  int _comboStacks = 0;
  int get comboStacks => _comboStacks;
  static const int maxComboStacks = 10;

  // Victory streak — consecutive kills without dying; +1% damage per kill, max 25%
  int victoryStreak = 0;
  double get victoryStreakDmgMult => 1.0 + (victoryStreak.clamp(0, 25) * 0.01);

  // Offline progress — set in loadFromJson, consumed by MainShell dialog
  int offlineGoldEarned     = 0;
  int offlineXpEarned       = 0;
  int offlineEssenceEarned  = 0;
  int offlineSecondsAway    = 0;
  int offlineExpeditionsReady = 0;
  void clearOfflineReport() {
    offlineGoldEarned = 0; offlineXpEarned = 0;
    offlineEssenceEarned = 0; offlineSecondsAway = 0;
    offlineExpeditionsReady = 0;
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
  bool tutorialDailySeen      = false;
  bool tutorialAbilitiesSeen  = false;
  bool tutorialPassivesSeen   = false;
  bool tutorialBestiarySeen   = false;
  bool tutorialPrestigeSeen   = false;
  bool tutorialMercsSeen      = false;

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
      case 'prestige':   tutorialPrestigeSeen   = true;
      case 'mercs':      tutorialMercsSeen      = true;
    }
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
    if (!spendEnergy()) return;
    _isCampaignBattle = true;
    heroDefeated = false;
    lastBattleWasFinalVictory = false;
    _battleTurnCount = 0;
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
    // Prestige difficulty scaling: each rebirth makes campaign enemies tougher
    if (prestigeLevel > 0) {
      final hpMult  = 1.0 + prestigeLevel * 0.15;
      final atkMult = 1.0 + prestigeLevel * 0.08;
      final acBonus = prestigeLevel ~/ 2;
      enemy = Enemy(
        id: enemy.id,
        name: enemy.name,
        description: enemy.description,
        maxHealth: (enemy.maxHealth * hpMult).round().clamp(1, 9999999),
        attack: (enemy.attack * atkMult).round().clamp(1, 9999),
        level: enemy.level,
        armorClass: enemy.armorClass + acBonus,
        attackType: enemy.attackType,
        resistances: enemy.resistances,
      );
    }
    // Hard mode: 2× enemy stats
    if (campaignHardMode) {
      enemy = Enemy(
        id: enemy.id,
        name: '⚡ ${enemy.name}',
        description: enemy.description,
        maxHealth: (enemy.maxHealth * 2).clamp(1, 9999999),
        attack: (enemy.attack * 2).clamp(1, 9999),
        level: enemy.level,
        armorClass: enemy.armorClass + 3,
        attackType: enemy.attackType,
        resistances: enemy.resistances,
      );
      battleLog.add('⚡ HARD MODE — Enemy has 2× stats!');
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
    // Zone modifier: enemy AC bonus (campaign only)
    final zoneAcBonus = (zoneMod?.effect == ZoneEffect.enemyAcBonus) ? zoneMod!.value : 0;
    final effectiveEnemyAC = max(1, enemy.armorClass + zoneAcBonus - pierce);
    final critChancePct = passiveTree.totalOf(PassiveEffect.critChance) + prestigeCritBonus;
    // Lena: Backstab — first attack of the battle is a guaranteed crit that bypasses miss chance
    bool backstab = false;
    if (_lenaBackstabReady) {
      _lenaBackstabReady = false;
      backstab = true;
    }
    final crit = backstab
        || roll == 20
        || (endlessUpgrades.keenEdge && roll == 19)
        || (subclassEffect == SubclassEffect.champion && roll >= 18)
        || (critChancePct > 0 && _rng.nextInt(100) < critChancePct);
    // Zone modifier: hero miss chance — Backstab bypasses it
    final zoneMiss = !backstab && zoneMod?.effect == ZoneEffect.heroMissChance &&
        _rng.nextInt(100) < zoneMod!.value;
    // Enemy dodge: non-boss enemies can evade. Crits and backstab bypass dodge.
    if (!crit && !backstab && enemy.dodge > 0 && !enemy.namedBoss && !isBossStage &&
        _rng.nextDouble() < enemy.dodge) {
      battleLog.add('${enemy.name} evades the attack!');
      notifyListeners();
      return;
    }
    // HIT% item stat: flat % chance to force-hit regardless of AC roll
    final hitChancePct = inventory.totalOf(ItemStat.hitChance);
    final forceHit = !zoneMiss && hitChancePct > 0 && _rng.nextInt(100) < hitChancePct;
    final hit  = !zoneMiss && (forceHit || crit || total >= effectiveEnemyAC);

    if (hit) {
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
      final baseCritMult = (subclassEffect == SubclassEffect.assassin || _hasKeyword(ItemKeyword.criticalFury)) ? 3 : 2;
      final critMult = (baseCritMult * prestigeCritDamageMult).round();
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

      // Flat affix reductions applied before pipeline (not % — keep inline)
      if (_activeAffixes.contains(ZoneAffix.ironSkin)) {
        baseDmg = (baseDmg - 2).clamp(1, 9999);
      }
      if (_activeAffixes.contains(ZoneAffix.diamondHide)) {
        final ratio = enemy.currentHealth / enemy.maxHealth;
        final reduction = (2 + (ratio * 6).floor()).clamp(2, 8);
        baseDmg = (baseDmg - reduction).clamp(1, 9999);
      }

      // ── Damage pipeline ───────────────────────────────────────────────────
      final heroType      = hero.activeDamageType;
      final exploitAcCap  = endlessUpgrades.synergyMindweave ? 16 : 14;
      final exploitMult   = (endlessUpgrades.exploitWeakness && enemy.armorClass <= exploitAcCap) ? 1.15 : 1.0;
      final subclassDmgMult = switch (subclassEffect) {
        SubclassEffect.hunter    => 1.20,
        SubclassEffect.vengeance => 1.10,
        _ => 1.0,
      };
      final weakMult = bestiaryWeaknessBonus(enemy.id);

      final _penPct = passiveTree.totalOf(PassiveEffect.allPenetration)
          + inventory.totalOf(ItemStat.elemPenetration);
      final _penMap = _penPct > 0
          ? <DamageType, double>{heroType: _penPct / 100.0}
          : const <DamageType, double>{};

      final _dmgCtx = buildWeaponAttackContext(
        baseDmg:          baseDmg,
        heroType:         heroType,
        allDamagePct:     passiveTree.totalOf(PassiveEffect.allDamage).toDouble()
                          + passiveElemDamagePct(heroType)
                          + gemElemDamagePct(heroType)
                          + inventory.totalOf(ItemStat.damagePercent)
                          + hero.levelBonusDamagePct
                          + hero.damagePctFor(heroType),
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
      var damage = calculateDamage(_dmgCtx, rng: _rng).total.round().clamp(1, 9999);

      // Log resistance/vulnerability (value already applied by pipeline; res capped at 75)
      final resistance = (enemy.resistances[heroType] ?? 0).clamp(-200, 75);
      if (resistance > 0) {
        battleLog.add('${enemy.name} resists ${heroType.label} (${resistance}% resist)!');
      } else if (resistance < 0) {
        battleLog.add('${enemy.name} is vulnerable to ${heroType.label}! (${-resistance}% extra)');
      }

      // Wild Magic: 15% chance triple damage (post-pipeline random event)
      if (subclassEffect == SubclassEffect.wildMagic && _rng.nextInt(100) < 15) {
        damage = (damage * 3).clamp(1, 9999);
        battleLog.add('Wild Magic surge!  $damage damage!');
      }

      // Soul Rip keyword: 8% instakill below 25% HP
      if (_hasKeyword(ItemKeyword.soulRip) &&
          enemy.currentHealth / enemy.maxHealth < 0.25 &&
          _rng.nextInt(100) < 8) {
        damage = enemy.currentHealth;
        battleLog.add('Soul Rip! ${enemy.name}\'s soul is torn free!');
      }

      // Victory streak bonus (+1% per kill, max +25%)
      if (victoryStreak > 0) {
        damage = (damage * victoryStreakDmgMult).round().clamp(1, 9999);
      }

      // Vulnerable debuff: enemy takes extra % damage
      if (_enemyVulnerablePct > 0) {
        damage = (damage * (1.0 + _enemyVulnerablePct / 100.0)).round().clamp(1, 9999);
      }

      enemy.takeDamage(damage);
      lastHeroDamage     = damage;
      lastHeroDamageType = heroType;
      lastHeroCrit       = crit;
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
      final effect   = AttackEffect.byId(equippedAttackEffectId);
      final hitWord  = crit ? 'CRITICAL HIT' : (effect?.hitText ?? 'Hit');
      if (backstab) battleLog.add('🌑 Lena: Backstab!');
      battleLog.add('$hitWord!${heroType.shortTag} $damage dmg.');
      // Cael: Warmaster's Strike — on first crit, deal 15% enemy max HP as bonus damage
      if (crit && allyUnlocked('warmaster_cael') && !_allyAbilitiesUsed.contains('warmaster_cael')) {
        _allyAbilitiesUsed.add('warmaster_cael');
        final bonusDmg = (enemy.maxHealth * 0.15).round().clamp(1, 9999);
        enemy.takeDamage(bonusDmg);
        battleLog.add('⚡ Cael: Warmaster\'s Strike! +$bonusDmg bonus damage!');
      }
      if (enemy.isDefeated) {
        _battleVictory(enemy);
        return;
      }

      // Boss enrage at 30% HP
      if (!_bossEnraged && isBossStage &&
          enemy.currentHealth / enemy.maxHealth < 0.3) {
        _bossEnraged = true;
        battleLog.add('⚠ ${enemy.name} ENRAGES! +200% damage!');
      }

      // DEX Lv10 — Blade Flicker: 12% chance (20% with Berserker synergy)
      final bladeFlickerChance = endlessUpgrades.synergyBerserker ? 20 : 12;
      if (endlessUpgrades.bladeFlicker && _rng.nextInt(100) < bladeFlickerChance) {
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
              'Blade Flicker! ${c2 ? "CRITICAL HIT" : "Hit"}${heroType.shortTag} for $dmg2 dmg.');
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
      if (zoneMiss) {
        battleLog.add('${zoneMod.icon} ${zoneMod.label}: attack deflected! Miss!');
      } else {
        battleLog.add('Miss!');
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

    // (Lifeleech Aura removed — enemies never heal during battle)

    // Boss ability DoT tick — ongoing damage applied to hero each enemy turn
    if (_heroDotRoundsLeft > 0) {
      _heroDotRoundsLeft--;
      final dmg = _heroDotDmgPerRound.clamp(1, 9999);
      hero.takeDamage(dmg);
      pendingFloats.add((value: dmg, isHeal: false, type: _heroDotType));
      battleLog.add('${_heroDotType.emoji} Ongoing damage: ${hero.name} takes $dmg ${_heroDotType.label} dmg ($_heroDotRoundsLeft rounds left).');
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
      final scaledDot = (_dotDmg * intDotMult).round().clamp(1, 9999);
      enemy.takeDamage(scaledDot);
      pendingFloats.add((value: scaledDot, isHeal: false, type: _dotDamageType));
      battleLog.add('Ongoing damage: ${enemy.name} takes $scaledDot dmg ($_dotRoundsLeft rounds left).');
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

    // Passive dodge chance (includes DEX +0.5%/point above 10, shadowMonk +10%, pet dodge, rune dodge)
    final dexTotal = hero.dexterity + inventory.totalOf(ItemStat.dexterity)
        + _setTotal(ItemStat.dexterity) + _gemTotal(ItemStat.dexterity);
    final dexDodge = max(0.0, (dexTotal - 10) * 0.5).clamp(0.0, 30.0);
    final subclassDodge = subclassEffect == SubclassEffect.shadowMonk ? 10 : 0;
    final passiveDodge = passiveTree.totalOf(PassiveEffect.dodgeChance) + subclassDodge
        + runeDodgeBonus + auraDodgeChance + petDodgeChance + dexDodge;
    if (passiveDodge > 0 && _rng.nextDouble() * 100 < passiveDodge) {
      battleLog.add('${hero.name} evades! (${dexDodge > 0 ? 'DEX' : 'Passive'} dodge)');
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

    // WIS Lv10 — Battle Awareness: auto-dodge the enemy's first attack of the battle
    if (!_battleAwarenessUsed && endlessUpgrades.battleAwareness) {
      _battleAwarenessUsed = true;
      battleLog.add('Battle Awareness! ${hero.name} reads the strike and steps aside.');
      _decrementBuffs();
      return;
    }

    // Abyssal Roar affix + zone modifier: flat damage bonus (formerly attack-roll bonus)
    final int affixDmgBonus = _activeAffixes.contains(ZoneAffix.abyssalRoar) ? 5 : 0;
    final int zoneAtkBonus  = (activeZoneModifier?.effect == ZoneEffect.enemyAtkBonus)
        ? activeZoneModifier!.value : 0;

    // Hero armor: reduces incoming physical damage (Last Epoch style).
    // STR adds to Armor Class; DEX gives Dodge Chance instead.
    final heroArmor = hero.armorClass + (endlessUpgrades.lightFooted ? 1 : 0) + _tempAcBonus
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
        + allyAcBonus;

    var rawDamage = (_rng.nextInt(enemy.attack) + 1 + affixDmgBonus + zoneAtkBonus).clamp(1, 9999);
    // Weaken debuff: reduce enemy ATK
    if (_enemyWeakenPct > 0) rawDamage = (rawDamage * (1.0 - _enemyWeakenPct / 100.0)).round().clamp(1, 9999);

    // Flat reductions: Thick Hide, Iron Will keyword, Juggernaut synergy, Ruk Stone Skin
    final ironWillReduction    = _hasKeyword(ItemKeyword.ironWill) ? 1 : 0;
    final juggernautReduction  = endlessUpgrades.synergyJuggernaut ? 1 : 0;
    final rukReduction         = _rukStoneSkinRoundsLeft > 0 ? 4 : 0;
    final fortitudeReduction   = endlessUpgrades.flatDamageReduction;
    if (_rukStoneSkinRoundsLeft > 0) _rukStoneSkinRoundsLeft--;

    final int damage;
    if (enemy.attackType == DamageType.physical) {
      // Armor mitigation (LE formula): armor / (armor + 50), capped at 75%.
      final armorMit  = (heroArmor / (heroArmor + 50.0)).clamp(0.0, 0.75);
      final afterArmor = (rawDamage * (1.0 - armorMit)).round();
      damage = endlessUpgrades.thickHide
          ? (afterArmor - 1 - ironWillReduction - juggernautReduction - rukReduction - fortitudeReduction).clamp(0, 9999)
          : (afterArmor - ironWillReduction - juggernautReduction - rukReduction - fortitudeReduction).clamp(0, 9999);
    } else {
      damage = endlessUpgrades.thickHide
          ? (rawDamage - 1 - ironWillReduction - juggernautReduction - rukReduction - fortitudeReduction).clamp(0, 9999)
          : (rawDamage - ironWillReduction - juggernautReduction - rukReduction - fortitudeReduction).clamp(0, 9999);
    }

    if (damage > 0) {
      // Apply hero's stat-based elemental resistance
      final heroRes  = heroResistancePct(enemy.attackType);
      final finalDmg = heroRes != 0
          ? (damage * (1.0 - heroRes / 100.0)).round().clamp(0, 9999)
          : damage;

      hero.takeDamage(finalDmg);
      lastEnemyDamage     = finalDmg;
      lastEnemyDamageType = enemy.attackType;
      _comboStacks = 0; // taking damage breaks combo
      audioService.playPlayerHit();
      final typeTag  = enemy.attackType == DamageType.physical
          ? '' : ' (${enemy.attackType.label})';
      final armorTag = enemy.attackType == DamageType.physical && heroArmor > 0
          ? ' [${((heroArmor / (heroArmor + 50.0)).clamp(0.0, 0.75) * 100).toStringAsFixed(0)}% arm]'
          : '';
      final resTag = heroRes > 0 ? ' [$heroRes% res]'
          : heroRes < 0 ? ' [${-heroRes}% vuln]' : '';
      battleLog.add('${enemy.name} hits!$typeTag$armorTag$resTag $finalDmg dmg.');

      // Thorn Wall keyword: return 30% of incoming damage to attacker
      if (_hasKeyword(ItemKeyword.thornWall)) {
        final thorn = (finalDmg * 0.30).round().clamp(1, 9999);
        enemy.takeDamage(thorn);
        battleLog.add('Thorn Wall reflects $thorn dmg!');
        if (enemy.isDefeated) { _battleVictory(enemy); return; }
      }

      // (Soul Siphon heal removed — enemies never heal during battle)

      // CON Lv25 — Unbroken: survive one killing blow per battle at 1 HP
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

      // CON Lv10 — Battle Scarred: regen 2% HP (4% with Iron Sage synergy)
      if (endlessUpgrades.battleScarred) {
        final scarredPct = endlessUpgrades.synergyIronSage ? 0.04 : 0.02;
        var regen = (hero.maxHealth * scarredPct).round().clamp(1, 9999);
        // Void Curse affix: halve all hero HP recovery
        if (_activeAffixes.contains(ZoneAffix.voidCurse)) regen = (regen / 2).round().clamp(1, 9999);
        hero.currentHealth = (hero.currentHealth + regen).clamp(0, hero.maxHealth);
      }
    } else {
      battleLog.add('${enemy.name} attacks — fully absorbed! ($heroArmor armor)');
      // Riposte keyword: triggers when attack is completely blocked
      if (_hasKeyword(ItemKeyword.riposte)) {
        enemy.takeDamage(3);
        battleLog.add('Riposte! 3 damage returned.');
        if (enemy.isDefeated) { _battleVictory(enemy); return; }
      }
    }
    // Boss abilities — fire each ability on its cooldown
    if (enemy.abilities.isNotEmpty) {
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

    _decrementBuffs();
  }

  bool _fireBossAbility(BossAbility ability, Enemy enemy) {
    switch (ability.effect) {
      case BossAbilityEffect.bonusDamage:
        final raw = (enemy.attack * ability.value / 100).round().clamp(1, 9999);
        final res = heroResistancePct(ability.damageType);
        final dmg = res != 0 ? (raw * (1.0 - res / 100.0)).round().clamp(0, 9999) : raw;
        if (dmg > 0) {
          hero.takeDamage(dmg);
          pendingFloats.add((value: dmg, isHeal: false, type: ability.damageType));
          battleLog.add('${ability.emoji} ${enemy.name}: ${ability.name}! ${hero.name} takes $dmg ${ability.damageType.label} dmg.');
          if (hero.currentHealth <= 0 && endlessUpgrades.unbroken && !_unbrokenUsed) {
            hero.currentHealth = 1;
            _unbrokenUsed = true;
            battleLog.add('Unbroken! ${hero.name} clings to life at 1 HP!');
          }
          if (hero.currentHealth <= 0) { _battleDefeat(); return true; }
        }
      case BossAbilityEffect.dot:
        final perRound = (enemy.attack * ability.value / 100).round().clamp(1, 9999);
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
  }

  void enemyAttack() {
    final enemy = currentEnemy;
    if (enemy == null) return;
    final attacks = _bossEnraged ? 3 : 1;
    for (int i = 0; i < attacks; i++) {
      _enemyTurn(enemy);
      if (hero.currentHealth <= 0) break;
    }
    if (_bossEnraged && attacks > 1) {
      battleLog.add('☠ ENRAGED — ${enemy.name} attacks $attacks times!');
    }
    notifyListeners();
  }

  /// Cycle the hero's active damage type to the next available option.
  void cycleDamageType() {
    hero.cycleNextDamageType();
    notifyListeners();
    saveToLocal();
  }

  void _battleVictory(Enemy enemy) {
    victoryStreak++;
    // INT Lv25 — Arcane Efficiency: +15% gold; Merchant Scholar synergy: +15% more
    final arcaneBonus = endlessUpgrades.arcaneEfficiency ? 1.15 : 1.0;
    final merchantScholarBonus = endlessUpgrades.synergyMerchantScholar ? 1.15 : 1.0;
    final passiveGoldMult = 1.0 + (passiveTree.totalOf(PassiveEffect.goldFlat)
        + inventory.totalOf(ItemStat.goldPct)
        + _setTotal(ItemStat.goldPct)
        + _gemTotal(ItemStat.goldPct)
        + _masteryTotal(MasteryEffect.permanentGoldPct)) / 100.0;
    final goldSenseMult = _hasKeyword(ItemKeyword.goldSense) ? 1.15 : 1.0;
    final petGoldMult = 1.0 + (petGoldPct + skinGoldPct + auraGoldPct + artifactGoldPct + runeGoldPct + traitGoldPct) / 100.0;
    var rewardGold =
        ((enemy.level * 50 + 100) * endlessUpgrades.goldMultiplier * arcaneBonus * merchantScholarBonus * prestigeGoldMult * prestigeGoldBattleMult * passiveGoldMult * goldSenseMult * petGoldMult * allyGoldMult)
            .round();
    // Felix: Bribe — double gold on the first kill of the battle
    if (_felixBribeActive) {
      _felixBribeActive = false;
      _allyAbilitiesUsed.add('coin_felix');
      rewardGold = rewardGold * 2;
      battleLog.add('🤑 Bribe pays off! Double gold earned!');
    }

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
        (((enemy.level * 40 + 60) *
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
    final prevHp    = hero.maxHealth;
    final prevStr   = hero.strength;
    final prevDex   = hero.dexterity;
    final prevCon   = hero.constitution;
    final prevInt   = hero.intelligence;
    final prevWis   = hero.wisdom;
    final prevCha   = hero.charisma;

    hero.gainExperience(rewardExp);

    if (hero.level > prevLevel) {
      audioService.playLevelUp();
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
    } else {
      lastLevelUp = null;
    }

    lastRewardGold = rewardGold;
    lastRewardExp  = rewardExp;
    lastItemDrop   = null;

    // Blood Drinker: restore 3% max HP on kill
    if (prestigeHealOnKill) {
      final healAmt = (hero.maxHealth * 0.03).round().clamp(1, 9999);
      hero.currentHealth = (hero.currentHealth + healAmt).clamp(0, hero.maxHealth);
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

    // Shards come exclusively from Dungeon runs.
    lastShardDrop = 0;

    // Gem shard drops: 25% chance on normal kill (1-2 shards), boss guaranteed 3-8
    // CHA Lv25 — Fortune's Favour: 10% chance to double gem shard drops (20% with Shadow Merchant)
    final favourChance = endlessUpgrades.synergyShadowMerchant ? 20 : 10;
    // Gem shards: PvP only (removed from campaign drops)

    // Equipment drop
    final drop = ItemLootTable.tryDrop(enemy.level, _rng);
    if (drop != null) {
      lastItemDrop = drop;
      if (autoDisenchantCommon && drop.rarity == ItemRarity.common) {
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
    }
    // Legendary drop: 1% chance on boss kills
    if (isBossStage) {
      final legDrop = ItemLootTable.tryDropLegendary(hero.level, _rng);
      if (legDrop != null) {
        lastItemDrop = legDrop;
        inventory.addToBag(legDrop);
        battleLog.add('✦ LEGENDARY DROP: ${legDrop.name}!');
        DebugLogger.log('item_drop', 'LEGENDARY ${legDrop.name} stage=$campaignStageIndex hero_lv=${hero.level}');
      }
      // Set item drop: 0.3% chance on boss kills — extremely rare
      final setDrop = ItemLootTable.tryDropSet(hero.level, _rng);
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

    // Post-battle HP recovery: flat 10% of max HP (CON no longer scales this).
    var conRegen = (hero.maxHealth * 10 / 100).round();
    // Fortitude upgrade: +1 flat regen per level as a minor secondary bonus
    conRegen += endlessUpgrades.flatDamageReduction;
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
    addSeasonXp(isBossStage ? 10 : 3);
    advanceWeekly('w_kills', 1);
    if (isBossStage) advanceWeekly('w_boss', 1);
    if (currentEnemy != null) logEnemy(currentEnemy!.name);
    // Rune drop: 10% on boss kills in campaign
    if (isBossStage) rollRuneDrop();

    // Bounty tracking
    _trackBountyProgress(BountyType.killEnemies, 1);
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

    // Campaign is infinite — always advance
    final wasFinalBoss = campaignStageIndex == CampaignData.stages.length - 1;
    final wasFirstKill = campaignStageIndex == 0;
    checkBattleStars(campaignStageIndex, _battleTurnCount);
    campaignStageIndex += 1;
    addSeasonXp(5);
    advanceWeekly('w_stages', 1);
    if (wasFirstKill) endlessTutorialPending = true;
    lastBattleWasFinalVictory = false;

    if (wasFinalBoss) {
      battleLog.add('The Omega falls. The curse is ended. A new age begins.');
    } else {
      battleLog.add('${hero.name} advances to stage ${campaignStageIndex + 1}.');
    }
    _setLastAction('Victory! $rewardGold gold, $rewardExp XP.');
    saveToLocal();
  }

  void _battleDefeat() {
    victoryStreak = 0;
    heroDefeated = true;
    _pvpMode = false;
    audioService.endBattleMusic();
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

  void _runAutoCampaignTick() {
    startBattle();
    if (currentEnemy == null) return;
    // Simulate combat rounds until someone dies
    for (int round = 0; round < 50; round++) {
      heroAttack();
      if (currentEnemy == null) break; // victory handled inside heroAttack
      if (heroDefeated) {
        heroDefeated = false;
        autoCampaign = false; // stop auto on defeat
        break;
      }
    }
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
    final earned = (idleProgress * hero.goldRate * prestigeIdleMult * waystoneMult * allyIdleMult).round();
    gold += earned;
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
    if (inBattle) hero.currentHealth = hpSnapshot;
    lastIdleXp = xpEarned;

    idleProgress = 0;
    _dailyIdleCollects++;
    _totalIdleCollects++;
    audioService.playCoin();
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
      (idleProgress * hero.goldRate * prestigeIdleMult * waystoneMult * allyIdleMult).round();

  /// Sustained gold earned per minute at current idle rate.
  int get idleGoldPerMinute =>
      (_effectiveIdleRate * 12 * hero.goldRate * prestigeIdleMult * waystoneMult * allyIdleMult).round();

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
    // WIS Lv25 — Frugal Mind: 15% chance the upgrade costs 0 echoes
    // Silver Tongue (CHA Lv5) 5% discount is already baked into costFor().
    if (!endlessUpgrades.frugalMind || _rng.nextInt(100) >= 15) {
      echoes -= cost;
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
      'echoes': echoes,
      'idleProgress': idleProgress,
      'campaignStageIndex': campaignStageIndex,
      'victoryStreak': victoryStreak,
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
      'dungeonAttemptsUsed':  _dungeonAttemptsUsed,
      'gauntletAttemptsUsed': _gauntletAttemptsUsed,
      'bossRushAttemptsUsed': _bossRushAttemptsUsed,
      'currentEnemy': null, // never persist mid-battle state; always start fresh
      'battleLog': battleLog,
      'endlessUpgrades': endlessUpgrades.toJson(),
      'abilityRanks': Map<String, int>.from(_abilityRanks),
      'abilityBranches': Map<String, String>.from(abilityBranches),
      'abilityMilestoneChoices': Map<String, String>.from(_milestoneChoices),
      'prestigeLevel': prestigeLevel,
      'prestigeSouls': prestigeSouls,
      'prestigeShop': prestigeShop.toJson(),
      'subclassId': subclassId,
      'essence': essence,
      'passiveTree': passiveTree.toJson(),
      'inventory': inventory.toJson(),
      'crystals': crystals,
      'speedTier': speedTier,
      'energy': energy,
      'energyRefillEpochMs': _energyRefillEpochMs,
      'dailyEnergyRefillsUsed': dailyEnergyRefillsUsed,
      'autoCampaign': autoCampaign,
      'ownedRunes': ownedRunes.toList(),
      'purchasedPacks': purchasedPacks.toList(),
      'ownedCosmetics': ownedCosmetics.toList(),
      'activeTitle': activeTitle,
      'activeNameColor': activeNameColor,
      'activeFrame': activeFrame,
      'isPremiumSubscriber': isPremiumSubscriber,
      'premiumExpiryMs': premiumExpiryMs,
      'autoDisenchantCommon': autoDisenchantCommon,
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
      'dailyChestClaimed': dailyChestClaimed,
      'endlessTutorialPending': endlessTutorialPending,
      'visitedModeTabs': visitedModeTabs.toList(),
      'equippedAuraId': equippedAuraId,
      'ownedAuraIds': ownedAuraIds.toList(),
      'equippedSkinId': equippedSkinId,
      'ownedSkinIds': ownedSkinIds.toList(),
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
      'campaignHardMode': campaignHardMode,
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
      'tutorialMercsSeen':     tutorialMercsSeen,
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
      'gauntletHighestTier': gauntletHighestTier,
      'questItemsEquipped': _itemsEquipped,
      'questAbilitiesUpgraded': _abilitiesUpgraded,
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
      'totalEndlessKills': _totalEndlessKills,
    };
  }

  void loadFromJson(Map<String, dynamic> json) {
    hero.loadFromJson(json['hero'] as Map<String, dynamic>);
    gold = json['gold'] as int;
    shards = (json['shards'] as int?) ?? 0;
    echoes = (json['echoes'] as int?) ?? 0;
    idleProgress = json['idleProgress'] as int;
    campaignStageIndex = json['campaignStageIndex'] as int;
    victoryStreak = (json['victoryStreak'] as int?) ?? 0;
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
    _milestoneChoices.clear();
    if (json['abilityMilestoneChoices'] != null) {
      (json['abilityMilestoneChoices'] as Map<String, dynamic>).forEach((k, v) {
        _milestoneChoices[k] = v as String;
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
    passiveTree.setElementalistNodes(hero.heroClass.info.classElement, hero.heroClass.info.secondaryElement);
    if (json['inventory'] != null) {
      inventory.loadFromJson(json['inventory'] as Map<String, dynamic>);
    }
    crystals             = (json['crystals']           as int?) ?? 0;
    speedTier            = (json['speedTier']           as int?) ?? 1;
    energy               = (json['energy']              as int?) ?? maxEnergy;
    _energyRefillEpochMs = (json['energyRefillEpochMs'] as int?) ?? 0;
    dailyEnergyRefillsUsed = (json['dailyEnergyRefillsUsed'] as int?) ?? 0;
    tickEnergy();
    autoCampaign         = (json['autoCampaign']        as bool?) ?? false;
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
    autoDisenchantCommon = (json['autoDisenchantCommon'] as bool?) ?? false;
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
    dailyChestClaimed = (json['dailyChestClaimed'] as bool?) ?? false;
    endlessTutorialPending = (json['endlessTutorialPending'] as bool?) ?? false;
    visitedModeTabs
      ..clear()
      ..addAll(((json['visitedModeTabs'] as List<dynamic>?) ?? ['CAMPAIGN']).cast<String>());
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
    _activeExpeditions.clear();
    final expList = json['activeExpeditions'] as List<dynamic>?;
    if (expList != null) {
      _activeExpeditions.addAll(
        expList.map((e) => Expedition.fromJson(e as Map<String, dynamic>)),
      );
    }
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
    gauntletHighestTier = (json['gauntletHighestTier'] as int?) ?? 0;
    _itemsEquipped = (json['questItemsEquipped'] as int?) ?? 0;
    _abilitiesUpgraded = (json['questAbilitiesUpgraded'] as int?) ?? 0;
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
    campaignHardMode = (json['campaignHardMode'] as bool?) ?? false;
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
    tutorialMercsSeen      = (json['tutorialMercsSeen']     as bool?) ?? false;
    // Offline progress — compute idle earnings since last save
    offlineGoldEarned  = 0;
    offlineXpEarned    = 0;
    offlineEssenceEarned = 0;
    offlineSecondsAway = 0;
    offlineExpeditionsReady = 0;
    final savedAtStr = json['savedAt'] as String?;
    if (savedAtStr != null) {
      final savedAt = DateTime.tryParse(savedAtStr);
      if (savedAt != null) {
        final elapsed = DateTime.now().difference(savedAt);
        if (elapsed.inSeconds >= 120 && idleGoldPerMinute > 0) {
          final cappedSecs  = elapsed.inSeconds.clamp(0, 8 * 3600);
          final mins        = cappedSecs / 60.0;
          final earned      = (mins * idleGoldPerMinute).round();
          if (earned > 0) {
            gold               += earned;
            _totalGoldEarned   += earned;
            offlineGoldEarned   = earned;
            offlineSecondsAway  = cappedSecs;
          }
          final xpEarned = (mins * idleXpPerCycle / 5.0).round();
          if (xpEarned > 0) {
            offlineXpEarned = xpEarned;
          }
          final essEarned = (mins * idleEssencePerCycle / 5.0).round();
          if (essEarned > 0) {
            essence += essEarned;
            offlineEssenceEarned = essEarned;
          }
        }
        offlineExpeditionsReady = activeExpeditions.where((e) {
          final elapsed2 = DateTime.now().millisecondsSinceEpoch - e.startEpochMs;
          return elapsed2 >= e.duration.ms;
        }).length;
      }
    }
    notifyListeners();
  }

  Future<void> saveToLocal() async {
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
