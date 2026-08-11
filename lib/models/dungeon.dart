import 'dart:math';
import '../data/enemy_data.dart';
import '../models/hero_ability.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Dungeon (roguelite run)
//
// Rooms are now auto-selected — no player path choice. generateRoomChoices
// picks one room from a weighted pool and sets currentRoom immediately.
// ─────────────────────────────────────────────────────────────────────────────

enum DungeonRoomType {
  combat,      // Standard fight
  elite,       // Tougher enemy — 1.5× stats, guaranteed item drop
  ambush,      // Enemy strikes first, then normal combat; +70% gold bonus
  treasure,    // Loot room — gold & shards
  shrine,      // Choose a run-long blessing (early floors)
  lockedChest, // Spend shards for a rare/epic item
  trap,        // Unavoidable damage
  restSite,    // Recover HP — event type determines outcome
  boss,        // Every 5th floor — boss encounter
}


enum DungeonBlessingType { attackUp, defenseUp, goldSense, swiftness, toughSkin, bloodthirst }

/// Random event variant for rest sites
enum RestEventType { peaceful, ambush, badWeather, haunted, wanderer, supplies, merchant }

/// Shrine alignment — determines blessing/curse draw
enum ShrineVariant { normal, corrupted, benevolent, twin }

// ── Dungeon merchant item pool ────────────────────────────────────────────────

class DungeonMerchantItem {
  DungeonMerchantItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.desc,
    required this.boneCost,
    this.effect,
    this.instantHealPct = 0.0,
  });
  final String id;
  final String name;
  final String icon;
  final String desc;
  final int boneCost;         // paid in Bones, not gold
  final ShrineEffect? effect; // run-long buff added to shrineEffects
  final double instantHealPct; // instant heal on purchase

  /// The merchant's tiered trades: better trinkets cost more Bones, and every
  /// effect scales with the dungeon [tier]. Higher bone cost = strictly stronger.
  /// [floor] seeds a little variety between visits.
  static List<DungeonMerchantItem> stockForTier(int tier, int floor) {
    final t = tier; // 1..10

    final oneBone = <DungeonMerchantItem>[
      DungeonMerchantItem(id: 'bone_charm', name: 'Bone Charm', icon: '🦴', boneCost: 1,
        desc: '+${2 + t} ATK for this run.',
        effect: ShrineEffect(id: 'm_atk1', name: 'Bone Charm', icon: '🦴',
            description: '+${2 + t} ATK', isCurse: false, atkMod: 2 + t)),
      DungeonMerchantItem(id: 'marrow', name: 'Marrow Draught', icon: '🧪', boneCost: 1,
        desc: 'Restore 25% max HP now.', instantHealPct: 0.25),
    ];
    final twoBone = <DungeonMerchantItem>[
      DungeonMerchantItem(id: 'ribcage', name: 'Ribcage Ward', icon: '🛡', boneCost: 2,
        desc: '+${1 + t} AC and −10% damage taken.',
        effect: ShrineEffect(id: 'm_def2', name: 'Ribcage Ward', icon: '🛡',
            description: '+${1 + t} AC, −10% damage taken', isCurse: false,
            acMod: 1 + t, damageTakenMult: 0.9)),
      DungeonMerchantItem(id: 'warfemur', name: "Warrior's Femur", icon: '⚔', boneCost: 2,
        desc: '+${4 + t * 2} ATK for this run.',
        effect: ShrineEffect(id: 'm_atk2', name: "Warrior's Femur", icon: '⚔',
            description: '+${4 + t * 2} ATK', isCurse: false, atkMod: 4 + t * 2)),
    ];
    final threeBone = <DungeonMerchantItem>[
      DungeonMerchantItem(id: 'skull_fury', name: 'Skull of Fury', icon: '💀', boneCost: 3,
        desc: '+${20 + t * 5}% damage dealt for this run.',
        effect: ShrineEffect(id: 'm_dmg3', name: 'Skull of Fury', icon: '💀',
            description: '+${20 + t * 5}% damage dealt', isCurse: false,
            damageDealtMult: 1.0 + (20 + t * 5) / 100.0)),
      DungeonMerchantItem(id: 'reaper_pact', name: "Reaper's Pact", icon: '☠', boneCost: 3,
        desc: '+${6 + t * 2} ATK and heal 40% HP.',
        effect: ShrineEffect(id: 'm_atk3', name: "Reaper's Pact", icon: '☠',
            description: '+${6 + t * 2} ATK', isCurse: false, atkMod: 6 + t * 2),
        instantHealPct: 0.40),
    ];

    int pick(int len, int salt) => (floor * 31 + salt).abs() % len;
    return [
      oneBone[pick(oneBone.length, 1)],
      twoBone[pick(twoBone.length, 2)],
      threeBone[pick(threeBone.length, 3)],
    ];
  }
}

// ── Shrine Curse/Blessing system ─────────────────────────────────────────────

class ShrineEffect {
  const ShrineEffect({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.isCurse,
    this.atkMod = 0,
    this.acMod = 0,
    this.dmgMod = 0,
    this.hpPctMod = 0.0,
    this.goldMult = 1.0,
    this.damageTakenMult = 1.0,
    this.damageDealtMult = 1.0,
    this.healMult = 1.0,
    this.trapDmgMult = 1.0,
    this.extraLootChance = 0.0,
  });

  final String id, name, icon, description;
  final bool isCurse;
  final int atkMod, acMod, dmgMod;
  final double hpPctMod, goldMult, damageTakenMult, damageDealtMult;
  final double healMult, trapDmgMult, extraLootChance;

  static const pool = <ShrineEffect>[
    // ── BLESSINGS (10) ──────────────────────────────────────────────────────
    ShrineEffect(id: 'b_warrior', name: "Warrior's Blessing", icon: '⚔',
      description: '+4 ATK for the rest of the run.',
      isCurse: false, atkMod: 4),
    ShrineEffect(id: 'b_iron', name: 'Iron Skin', icon: '🛡',
      description: '+4 Armor for the rest of the run.',
      isCurse: false, acMod: 4),
    ShrineEffect(id: 'b_fury', name: 'Blessed Fury', icon: '🔥',
      description: 'Deal 30% more damage.',
      isCurse: false, damageDealtMult: 1.3),
    ShrineEffect(id: 'b_fortune', name: "Fortune's Favor", icon: '💰',
      description: '2× gold from all rooms.',
      isCurse: false, goldMult: 2.0),
    ShrineEffect(id: 'b_vitality', name: 'Vitality Surge', icon: '❤',
      description: 'Restore 30% of max HP.',
      isCurse: false, hpPctMod: 0.3),
    ShrineEffect(id: 'b_nimble', name: 'Nimble Step', icon: '💨',
      description: 'Traps deal 50% less damage.',
      isCurse: false, trapDmgMult: 0.5),
    ShrineEffect(id: 'b_treasure', name: 'Treasure Sense', icon: '✦',
      description: '25% chance for bonus loot from combat.',
      isCurse: false, extraLootChance: 0.25),
    ShrineEffect(id: 'b_regen', name: 'Sacred Renewal', icon: '🌿',
      description: 'Healing effects are 50% stronger.',
      isCurse: false, healMult: 1.5),
    ShrineEffect(id: 'b_power', name: 'Power Surge', icon: '⚡',
      description: '+6 flat damage per hit.',
      isCurse: false, dmgMod: 6),
    ShrineEffect(id: 'b_guardian', name: "Guardian's Embrace", icon: '🛡',
      description: 'Take 20% less damage from all sources.',
      isCurse: false, damageTakenMult: 0.8),

    // ── CURSES (10) ─────────────────────────────────────────────────────────
    ShrineEffect(id: 'c_greed', name: 'Curse of Greed', icon: '💰',
      description: '3× gold... but take 25% more damage.',
      isCurse: true, goldMult: 3.0, damageTakenMult: 1.25),
    ShrineEffect(id: 'c_glass', name: 'Glass Cannon', icon: '💥',
      description: 'Deal 50% more damage but take 40% more.',
      isCurse: true, damageDealtMult: 1.5, damageTakenMult: 1.4),
    ShrineEffect(id: 'c_frailty', name: 'Curse of Frailty', icon: '💀',
      description: '-3 Armor, but +5 ATK.',
      isCurse: true, acMod: -3, atkMod: 5),
    ShrineEffect(id: 'c_blood', name: 'Blood Price', icon: '🩸',
      description: 'Lose 20% of current HP. Gain 2× gold.',
      isCurse: true, hpPctMod: -0.2, goldMult: 2.0),
    ShrineEffect(id: 'c_decay', name: 'Creeping Decay', icon: '☠',
      description: 'Healing reduced by 50%. Extra loot from combat.',
      isCurse: true, healMult: 0.5, extraLootChance: 0.3),
    ShrineEffect(id: 'c_burden', name: 'Heavy Burden', icon: '⛓',
      description: '-4 ATK, but traps deal no damage.',
      isCurse: true, atkMod: -4, trapDmgMult: 0.0),
    ShrineEffect(id: 'c_wrath', name: "Dragon's Wrath", icon: '🐉',
      description: 'Take 30% more damage. Deal 40% more.',
      isCurse: true, damageTakenMult: 1.3, damageDealtMult: 1.4),
    ShrineEffect(id: 'c_famine', name: 'Curse of Famine', icon: '🍂',
      description: 'Gold reduced by 50%. +8 flat damage.',
      isCurse: true, goldMult: 0.5, dmgMod: 8),
    ShrineEffect(id: 'c_shadow', name: 'Shadow Pact', icon: '🌑',
      description: 'Lose 15% max HP permanently. +40% damage dealt.',
      isCurse: true, hpPctMod: -0.15, damageDealtMult: 1.4),
    ShrineEffect(id: 'c_chaos', name: 'Embrace of Chaos', icon: '🌀',
      description: 'All multipliers randomized. Anything could happen.',
      isCurse: true, damageDealtMult: 1.25, damageTakenMult: 1.15, goldMult: 1.5, healMult: 0.7),
  ];
}

// ── Boss relics — pick 1 of 3 after every boss kill ──────────────────────────

class DungeonRelic {
  const DungeonRelic({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    this.effect,
    this.instantGoldBase = 0,
    this.instantHealPct = 0,
    this.grantsItem = false,
    this.bonesGranted = 0,
  });

  final String id, name, icon, description;
  final ShrineEffect? effect;    // run-long passive (applied via shrineEffects)
  final int instantGoldBase;     // gold = base + floor × 40
  final double instantHealPct;   // % of max HP restored
  final bool grantsItem;         // extra floor-scaled item drop
  final int bonesGranted;        // Bones added to the run's merchant purse

  static const pool = <DungeonRelic>[
    DungeonRelic(id: 'r_bloodfang', name: 'Bloodfang Idol', icon: '⚔',
      description: '+15% damage dealt for the rest of the run.',
      effect: ShrineEffect(id: 'relic_dmg', name: 'Bloodfang Idol', icon: '⚔',
        description: '+15% damage dealt.', isCurse: false, damageDealtMult: 1.15)),
    DungeonRelic(id: 'r_aegis', name: 'Aegis Fragment', icon: '◆',
      description: 'Take 12% less damage for the rest of the run.',
      effect: ShrineEffect(id: 'relic_def', name: 'Aegis Fragment', icon: '◆',
        description: '-12% damage taken.', isCurse: false, damageTakenMult: 0.88)),
    DungeonRelic(id: 'r_hoard', name: 'Hoard Compass', icon: '💰',
      description: 'A pile of gold, bigger on deeper floors.',
      instantGoldBase: 200),
    DungeonRelic(id: 'r_heart', name: 'Phoenix Heart', icon: '❤',
      description: 'Restore 35% of max HP now.',
      instantHealPct: 0.35),
    DungeonRelic(id: 'r_cache', name: 'War Cache', icon: '✦',
      description: 'An extra item drop, scaled to this floor.',
      grantsItem: true),
    DungeonRelic(id: 'r_ossuary', name: 'Ossuary Cache', icon: '🦴',
      description: 'Gain 5 Bones for the Traveling Merchant.',
      bonesGranted: 5),
  ];
}


// ── Blessing ──────────────────────────────────────────────────────────────────

extension DungeonBlessingLabel on DungeonBlessingType {
  String get label => switch (this) {
    DungeonBlessingType.attackUp   => '⚔ Battle Fury',
    DungeonBlessingType.defenseUp  => '🛡 Stone Skin',
    DungeonBlessingType.goldSense  => '💰 Gold Sense',
    DungeonBlessingType.swiftness  => '💨 Swiftness',
    DungeonBlessingType.toughSkin  => '🪨 Tough Skin',
    DungeonBlessingType.bloodthirst => '🩸 Bloodthirst',
  };
  String get desc => switch (this) {
    DungeonBlessingType.attackUp   => '+2 critical damage this run',
    DungeonBlessingType.defenseUp  => '+2 AC for the rest of this run',
    DungeonBlessingType.goldSense  => '+50% gold from combat rooms',
    DungeonBlessingType.swiftness  => 'Hero strikes twice in the first round',
    DungeonBlessingType.toughSkin  => 'Reduce all trap & ambush damage by 40%',
    DungeonBlessingType.bloodthirst => '+4 flat damage for the rest of this run',
  };
}

// ── Room ──────────────────────────────────────────────────────────────────────

class DungeonRoom {
  DungeonRoom({
    required this.floor,
    required this.type,
    this.enemyId,
    this.enemyName,
    this.enemyMaxHp,
    this.enemyAtk,
    this.enemyAc,
    this.trapName,
    this.trapDamage,
    this.treasureGold,
    this.treasureShards,
    this.blessingChoices,
    this.chestShardCost,
    this.restoreHp,
    this.isAmbush = false,
    this.restEventType = RestEventType.peaceful,
    this.restEventTitle = 'Rest Site',
    this.restEventFlavor = '',
    this.restDamage = 0,
    this.restBonusGold = 0,
    this.shrineVariant = ShrineVariant.normal,
    this.eliteTrait,
    this.isGoblin = false,
  });

  final int floor;
  final DungeonRoomType type;
  bool resolved = false;

  // Combat / boss / elite / ambush
  String? enemyId;
  String? enemyName;
  int? enemyMaxHp;
  int? enemyAtk;
  int? enemyAc;
  bool isAmbush; // enemy gets free strike before round 1

  /// Elite rooms roll one random trait: frenzied | shielded | vampiric |
  /// armored | swift. Shown before the fight and applied in combat.
  final String? eliteTrait;

  /// Treasure goblin: rare combat room. Kill within 5 rounds for 6× gold —
  /// otherwise it flees with its hoard.
  final bool isGoblin;
  bool goblinEscaped = false;

  String? get eliteTraitLabel => switch (eliteTrait) {
    'frenzied' => 'Frenzied — +40% ATK below half HP',
    'shielded' => 'Shielded — blocks first 3 hits',
    'vampiric' => 'Vampiric — heals 30% of damage dealt',
    'armored'  => 'Armored — +4 AC',
    'swift'    => 'Swift — strikes twice each round',
    _ => null,
  };

  // Trap
  String? trapName;
  int? trapDamage;

  // Treasure
  int? treasureGold;
  int? treasureShards;

  // Shrine / altar
  List<DungeonBlessingType>? blessingChoices;
  final ShrineVariant shrineVariant;

  // Locked chest
  int? chestShardCost;
  bool chestOpened = false;

  // Rest site
  int? restoreHp;
  final RestEventType restEventType;
  final String restEventTitle;
  final String restEventFlavor;
  final int restDamage;     // HP taken before healing (ambush / bad weather)
  final int restBonusGold;  // extra gold reward (supplies event)

  // Whether this room drops an item (set by GameState after combat)
  bool hasItemDrop = false;

  String get typeIcon => switch (type) {
    DungeonRoomType.combat      => '⚔',
    DungeonRoomType.elite       => '💀',
    DungeonRoomType.ambush      => '🗡',
    DungeonRoomType.treasure    => '💎',
    DungeonRoomType.shrine      => '🕯',
    DungeonRoomType.lockedChest => '🔒',
    DungeonRoomType.trap        => '⚠',
    DungeonRoomType.restSite    => '🏕',
    DungeonRoomType.boss        => '☠',
  };

  String get typeName => switch (type) {
    DungeonRoomType.combat      => 'Combat',
    DungeonRoomType.elite       => 'Elite Enemy',
    DungeonRoomType.ambush      => 'Ambush!',
    DungeonRoomType.treasure    => 'Treasure',
    DungeonRoomType.shrine      => 'Shrine',
    DungeonRoomType.lockedChest => 'Locked Chest',
    DungeonRoomType.trap        => 'Trap',
    DungeonRoomType.restSite    => 'Rest Site',
    DungeonRoomType.boss        => 'BOSS',
  };

  String get typeHint => switch (type) {
    DungeonRoomType.combat      => 'Fight and earn gold',
    DungeonRoomType.elite       => 'Powerful foe — greater loot and a guaranteed item',
    DungeonRoomType.ambush      => 'Enemy strikes first — high gold reward if you survive',
    DungeonRoomType.treasure    => 'Collect gold & shards',
    DungeonRoomType.shrine      => 'Choose a run-long blessing',
    DungeonRoomType.lockedChest => 'Spend shards for a rare item',
    DungeonRoomType.trap        => 'Unavoidable damage',
    DungeonRoomType.restSite    => 'Recover HP and push deeper',
    DungeonRoomType.boss        => 'Greater risk, greater reward',
  };
}

// ── Run ───────────────────────────────────────────────────────────────────────

class DungeonRun {
  DungeonRun({required this.heroMaxHp, required this.heroHp, this.tier = 1, this.prestigeLevel = 0});

  /// Beating the boss on this floor clears the dungeon (every tier).
  static const int clearFloor = 20;

  int tier;
  int floor = 1;
  /// Hero's rebirth count when the run started — scales enemy power so the
  /// dungeon tracks progression like the campaign (+20% HP / +12% ATK each).
  final int prestigeLevel;
  final int heroMaxHp;
  int heroHp;

  /// Bones — run-local currency dropped by slain enemies, spent only at the
  /// Traveling Merchant on run-buff trinkets. Resets each run (a new DungeonRun
  /// is created per attempt), so the dungeon is its own self-contained economy.
  int bones = 0;

  final List<DungeonBlessingType> blessings = [];
  final List<ShrineEffect> shrineEffects = [];

  // Boss relics: choices offered after a boss kill; taken relics for display
  List<DungeonRelic> relicChoices = [];
  final List<DungeonRelic> relicsTaken = [];

  int get blessingAtk {
    var total = blessings.where((b) => b == DungeonBlessingType.attackUp).length * 2;
    for (final e in shrineEffects) total += e.atkMod;
    return total;
  }
  int get blessingAc {
    var total = blessings.where((b) => b == DungeonBlessingType.defenseUp).length * 2;
    for (final e in shrineEffects) total += e.acMod;
    return total;
  }
  int get blessingDmg {
    var total = blessings.where((b) => b == DungeonBlessingType.bloodthirst).length * 4;
    for (final e in shrineEffects) total += e.dmgMod;
    return total;
  }
  double get goldBonusMult {
    var mult = 1.0 + blessings.where((b) => b == DungeonBlessingType.goldSense).length * 0.5;
    for (final e in shrineEffects) mult *= e.goldMult;
    return mult;
  }
  double get trapDmgMult {
    var mult = blessings.contains(DungeonBlessingType.toughSkin) ? 0.6 : 1.0;
    for (final e in shrineEffects) mult *= e.trapDmgMult;
    return mult;
  }
  bool get hasSwiftness => blessings.contains(DungeonBlessingType.swiftness);
  double get damageDealtMult {
    var mult = 1.0;
    for (final e in shrineEffects) mult *= e.damageDealtMult;
    return mult;
  }
  double get damageTakenMult {
    var mult = 1.0;
    for (final e in shrineEffects) mult *= e.damageTakenMult;
    return mult;
  }
  double get healMult {
    var mult = 1.0;
    for (final e in shrineEffects) mult *= e.healMult;
    return mult;
  }
  double get extraLootChance {
    var chance = 0.0;
    for (final e in shrineEffects) chance += e.extraLootChance;
    return chance;
  }

  DungeonRoom? currentRoom;
  List<DungeonRoom> roomChoices = [];

  bool isDead      = false;
  bool isAbandoned = false;
  bool isCleared   = false;
  bool get isOver  => isDead || isAbandoned || isCleared;

  int goldEarned   = 0;
  int shardsEarned = 0;
  int roomsCleared   = 0;
  int bossesDefeated = 0;

  String lastCombatSummary = '';
  int lastDamageDealt = 0;
  int lastDamageTaken = 0;
  int ambushPreHit = 0;

  // Ability state — persists across rooms so cooldowns carry between fights
  int abilityRound = 0;
  final Map<String, int> cooldownUntil = {};
  List<String> lastAbilityLog = [];

  // ── Room generation ──────────────────────────────────────────────────────

  // Gentle +5%/floor within a zone, with a ×1.25 step after each boss
  // (floors 6, 11, 16) — bosses are checkpoints, not speed bumps.
  double get _floorMult =>
      (1.0 + (floor - 1) * 0.05) * pow(1.25, (floor - 1) ~/ 5);
  double get _tierMult  => 1.0 + (tier  - 1) * 0.30;

  // Two-door generation: non-boss floors offer two distinct rooms and the
  // player picks one (chooseRoom). Boss floors are forced single rooms.
  void generateRoomChoices(Random rng) {
    roomChoices = [];
    currentRoom = null;

    if (floor % 5 == 0) {
      final room = _makeBossRoom(rng);
      roomChoices = [room];
      currentRoom = room; // boss floors give no choice
      return;
    }

    final first = _pickWeightedRoom(rng);
    var second  = _pickWeightedRoom(rng);
    for (var i = 0; i < 8 && second.type == first.type; i++) {
      second = _pickWeightedRoom(rng);
    }
    // Never present two "mystery" (hidden-icon) doors — that's a non-choice.
    // If both are mystery types, reroll the second into a revealed type. (Must
    // match _mysteryTypes in dungeon_screen.dart.)
    const mysteryTypes = {
      DungeonRoomType.trap, DungeonRoomType.treasure, DungeonRoomType.shrine,
      DungeonRoomType.restSite, DungeonRoomType.lockedChest,
    };
    if (mysteryTypes.contains(first.type) && mysteryTypes.contains(second.type)) {
      for (var i = 0; i < 12; i++) {
        final r = _pickWeightedRoom(rng);
        if (!mysteryTypes.contains(r.type) && r.type != first.type) {
          second = r;
          break;
        }
      }
    }
    // ~3% jackpot: a treasure goblin appears behind the second door
    if (rng.nextInt(100) < 3) second = _makeGoblinRoom(rng);
    roomChoices = [first, second];
    // currentRoom stays null until the player picks a door.
  }

  DungeonRoom _makeGoblinRoom(Random rng) {
    final stageIdx = (floor - 1).clamp(0, 50);
    final e = EnemyData.enemyForStage(stageIdx, prestigeLevel: prestigeLevel);
    return DungeonRoom(
      floor: floor, type: DungeonRoomType.combat,
      enemyId: 'treasure_goblin',
      enemyName: 'Treasure Goblin',
      enemyMaxHp: (e.maxHealth * 1.2 * _floorMult * _tierMult).round(),
      enemyAtk: (e.attack * 0.5 * _floorMult * _tierMult).round().clamp(1, 9999),
      enemyAc: e.armorClass + 3 + (floor ~/ 5).clamp(0, 6),
      isGoblin: true,
    );
  }

  void chooseRoom(DungeonRoom room) {
    if (roomChoices.contains(room)) currentRoom = room;
  }

  DungeonRoom _pickWeightedRoom(Random rng) {
    // Weighted pool: combat-heavy with variety
    //  combat 28 | elite 14 | ambush 12 | trap 11 | treasure 12 | restSite 11 | shrine/chest 12
    const weights = [28, 14, 12, 11, 12, 11, 12];
    final types = [
      DungeonRoomType.combat,
      DungeonRoomType.elite,
      DungeonRoomType.ambush,
      DungeonRoomType.trap,
      DungeonRoomType.treasure,
      DungeonRoomType.restSite,
      floor < 3
          ? DungeonRoomType.shrine
          : floor < 8
              ? DungeonRoomType.lockedChest
              : DungeonRoomType.shrine, // cycles back to shrine at deep floors
    ];

    final total = weights.fold(0, (a, b) => a + b);
    var roll = rng.nextInt(total);
    for (var i = 0; i < weights.length; i++) {
      roll -= weights[i];
      if (roll < 0) return _makeRoom(types[i], rng);
    }
    return _makeRoom(DungeonRoomType.combat, rng);
  }

  DungeonRoom _makeRoom(DungeonRoomType t, Random rng) => switch (t) {
    DungeonRoomType.combat      => _makeCombatRoom(rng),
    DungeonRoomType.elite       => _makeEliteRoom(rng),
    DungeonRoomType.ambush      => _makeAmbushRoom(rng),
    DungeonRoomType.treasure    => _makeTreasureRoom(rng),
    DungeonRoomType.shrine      => _makeShrineRoom(rng),
    DungeonRoomType.trap        => _makeTrapRoom(rng),
    DungeonRoomType.boss        => _makeBossRoom(rng),
    DungeonRoomType.lockedChest => _makeLockedChest(rng),
    DungeonRoomType.restSite    => _makeRestSiteRoom(rng),
  };

  DungeonRoom _makeCombatRoom(Random rng) {
    final stageIdx = (floor - 1).clamp(0, 50);
    final e = EnemyData.enemyForStage(stageIdx, prestigeLevel: prestigeLevel);
    return DungeonRoom(
      floor: floor, type: DungeonRoomType.combat,
      enemyId: EnemyData.spriteIdForStage(stageIdx),
      enemyName: e.name,
      enemyMaxHp: (e.maxHealth * 1.3 * _floorMult * _tierMult).round(),
      enemyAtk: (e.attack * 1.3 * _floorMult * _tierMult).round(),
      enemyAc: e.armorClass + (floor ~/ 5).clamp(0, 6),
    );
  }

  DungeonRoom _makeEliteRoom(Random rng) {
    final stageIdx = (floor - 1).clamp(0, 50);
    final e = EnemyData.enemyForStage(stageIdx, prestigeLevel: prestigeLevel);
    const traits = ['frenzied', 'shielded', 'vampiric', 'armored', 'swift'];
    final trait = traits[rng.nextInt(traits.length)];
    return DungeonRoom(
      floor: floor, type: DungeonRoomType.elite,
      enemyId: EnemyData.spriteIdForStage(stageIdx),
      enemyName: '★ ${e.name}',
      enemyMaxHp: (e.maxHealth * 1.5 * _floorMult * _tierMult).round(),
      enemyAtk: (e.attack * 1.4 * _floorMult * _tierMult).round(),
      enemyAc: e.armorClass + 1 + (floor ~/ 5).clamp(0, 6) + (trait == 'armored' ? 4 : 0),
      eliteTrait: trait,
    );
  }

  DungeonRoom _makeAmbushRoom(Random rng) {
    final stageIdx = (floor - 1).clamp(0, 50);
    final e = EnemyData.enemyForStage(stageIdx, prestigeLevel: prestigeLevel);
    return DungeonRoom(
      floor: floor, type: DungeonRoomType.ambush,
      enemyId: EnemyData.spriteIdForStage(stageIdx),
      enemyName: e.name,
      enemyMaxHp: (e.maxHealth * 1.3 * _floorMult * _tierMult).round(),
      enemyAtk: (e.attack * 1.3 * _floorMult * _tierMult).round(),
      enemyAc: e.armorClass + (floor ~/ 5).clamp(0, 6),
      isAmbush: true,
    );
  }

  DungeonRoom _makeRestSiteRoom(Random rng) {
    // Weighted event roll: peaceful 35 | ambush 15 | badWeather 14 | haunted 9 | wanderer 9 | supplies 9 | merchant 9
    const weights = [35, 15, 14, 9, 9, 9, 9];
    const types = RestEventType.values;
    final total = weights.fold(0, (a, b) => a + b);
    var roll = rng.nextInt(total);
    var eventType = RestEventType.peaceful;
    for (var i = 0; i < weights.length; i++) {
      roll -= weights[i];
      if (roll < 0) { eventType = types[i]; break; }
    }

    int heal;
    int damage = 0;
    int bonusGold = 0;
    String title;
    String flavor;

    switch (eventType) {
      case RestEventType.peaceful:
        heal   = (heroMaxHp * 0.20).round().clamp(1, heroMaxHp);
        title  = 'Rest Site';
        flavor = 'A quiet clearing. You make camp and recover your strength.';
      case RestEventType.ambush:
        damage = (heroMaxHp * 0.12).round().clamp(1, heroMaxHp - 1);
        heal   = (heroMaxHp * 0.15).round().clamp(1, heroMaxHp);
        title  = 'Camp Ambush!';
        flavor = 'Enemies raid your camp in the night. You fight them off, but not without injury.';
      case RestEventType.badWeather:
        damage = (heroMaxHp * 0.08).round().clamp(1, heroMaxHp - 1);
        heal   = (heroMaxHp * 0.12).round().clamp(1, heroMaxHp);
        title  = 'Violent Storm';
        flavor = 'A fierce storm lashes your camp. You shelter as best you can, battered but alive.';
      case RestEventType.haunted:
        heal   = (heroMaxHp * 0.08).round().clamp(1, heroMaxHp);
        title  = 'Haunted Grounds';
        flavor = 'Unsettling visions plague your sleep. You rise exhausted and shaken.';
      case RestEventType.wanderer:
        heal   = (heroMaxHp * 0.35).round().clamp(1, heroMaxHp);
        title  = 'Wandering Healer';
        flavor = 'A traveling healer stumbles upon your camp and tends your wounds generously.';
      case RestEventType.supplies:
        heal      = (heroMaxHp * 0.20).round().clamp(1, heroMaxHp);
        bonusGold = 80 + floor * 20 + rng.nextInt(60);
        title     = 'Abandoned Supplies';
        flavor    = 'You find a cache of supplies left by a previous adventurer — rations, bandages, and coin.';
      case RestEventType.merchant:
        heal   = (heroMaxHp * 0.05).round().clamp(1, heroMaxHp);
        title  = 'Traveling Merchant';
        flavor = 'A cloaked merchant spreads wares on a folding table. "Quality goods, fair prices," they say with a grin.';
    }

    return DungeonRoom(
      floor: floor, type: DungeonRoomType.restSite,
      restoreHp: heal,
      restEventType: eventType,
      restEventTitle: title,
      restEventFlavor: flavor,
      restDamage: damage,
      restBonusGold: bonusGold,
    );
  }

  DungeonRoom _makeBossRoom(Random rng) {
    final stageIdx = ((floor - 1) * 2).clamp(0, 60);
    final e = EnemyData.enemyForStage(stageIdx, prestigeLevel: prestigeLevel);
    // Floor 20 is the dungeon's final boss — beefier and clearly labelled.
    final isFinal = floor >= clearFloor;
    final finalMult = isFinal ? 1.5 : 1.0;
    return DungeonRoom(
      floor: floor, type: DungeonRoomType.boss,
      enemyId: EnemyData.spriteIdForStage(stageIdx),
      enemyName: isFinal ? '★☠ ${e.name}, Dungeon Lord' : '☠ ${e.name}',
      // Boss ATK ramps from 1.2× at floor 1 to 1.6× at floor 17+, giving a smoother
      // difficulty curve instead of the hard cliff at floors 7–9.
      enemyMaxHp: (e.maxHealth * 1.9 * finalMult * _floorMult * _tierMult).round(),
      enemyAtk: (e.attack * (1.1 + (floor - 1) * 0.02).clamp(1.1, 1.4) * (isFinal ? 1.2 : 1.0) * _floorMult * _tierMult).round(),
      enemyAc: e.armorClass + 2 + (floor ~/ 5).clamp(0, 8) + (isFinal ? 2 : 0),
    );
  }

  DungeonRoom _makeLockedChest(Random rng) {
    final cost = (20 + floor * 8).clamp(20, 200);
    return DungeonRoom(floor: floor, type: DungeonRoomType.lockedChest, chestShardCost: cost);
  }

  DungeonRoom _makeTreasureRoom(Random rng) => DungeonRoom(
    floor: floor, type: DungeonRoomType.treasure,
    treasureGold: 150 + floor * 45 + rng.nextInt(80),
    treasureShards: 8 + floor * 2 + rng.nextInt(15),
  );

  DungeonRoom _makeShrineRoom(Random rng) {
    final all = DungeonBlessingType.values.toList()..shuffle(rng);
    // Shrine variant weights: normal 60 | corrupted 20 | benevolent 15 | twin 5
    final vRoll = rng.nextInt(100);
    final variant = vRoll < 60 ? ShrineVariant.normal
        : vRoll < 80            ? ShrineVariant.corrupted
        : vRoll < 95            ? ShrineVariant.benevolent
        :                         ShrineVariant.twin;
    return DungeonRoom(
      floor: floor, type: DungeonRoomType.shrine,
      blessingChoices: all.take(3).toList(),
      shrineVariant: variant,
    );
  }

  DungeonRoom _makeTrapRoom(Random rng) {
    const names = ['Poison Spikes', 'Fire Jet', 'Boulder Trap', 'Arcane Curse', 'Acid Pool', 'Void Rift', 'Shadow Snare'];
    // % of max HP: 8% on floor 1, +1.5% per floor, capped at 40%
    final pct    = (8.0 + floor * 1.5).clamp(8.0, 40.0);
    final rawDmg = (heroMaxHp * pct / 100).round();
    final dmg = (rawDmg * trapDmgMult).round().clamp(1, heroMaxHp);
    return DungeonRoom(
      floor: floor, type: DungeonRoomType.trap,
      trapName: names[rng.nextInt(names.length)],
      trapDamage: dmg,
    );
  }

  // ── Combat simulation ─────────────────────────────────────────────────────

  /// Resolves a combat, elite, ambush, or boss room.
  /// Pass [abilities], [getCooldown], and [getValue] to fire hero abilities each round.
  int resolveCombat(
    DungeonRoom room,
    int heroAtkBonus,
    int heroAc,
    int heroStrMod,
    Random rng, {
    List<HeroAbility> abilities = const [],
    int Function(HeroAbility)? getCooldown,
    int Function(HeroAbility)? getValue,
    int weaponBase = 0,
    double dmgMult = 1.0,
    double enemyHpMult = 1.0,
    double extHealMult = 1.0,
    int burnPerRound = 0,
    int enemyShield = 0,
  }) {
    int heroHpLocal  = heroHp;
    int enemyHpLocal = ((room.enemyMaxHp ?? 10) * enemyHpMult).round();
    var shieldLeft   = enemyShield;
    final totalHealMult = healMult * extHealMult;
    final baseAc  = heroAc + blessingAc;
    final eAtk    = room.enemyAtk ?? 5;

    // Per-combat temp state
    int tempAtkBonus = 0, tempAtkRounds = 0;
    int tempAcBonus  = 0, tempAcRounds  = 0;
    bool enemyStunned      = false;
    int  enemyWeakenRounds = 0; // enemy ATK -30%
    int  enemyVulnRounds   = 0; // hero deals +25% damage

    lastAbilityLog = [];
    int heroDmg  = 0;
    int enemyDmg = 0;
    int rounds   = 0;
    ambushPreHit = 0;

    // Ambush: enemy gets a free attack before the fight begins
    if (room.isAmbush) {
      final pre = (rng.nextInt(eAtk ~/ 3 + 1) + 1).clamp(1, 9999);
      heroHpLocal -= pre;
      enemyDmg    += pre;
      ambushPreHit = pre;
      if (heroHpLocal <= 0) { heroHp = 0; isDead = true; lastDamageDealt = 0; lastDamageTaken = enemyDmg; lastCombatSummary = 'Slain in the ambush before the fight began.'; return 0; }
    }

    while (heroHpLocal > 0 && enemyHpLocal > 0 && rounds < 60) {
      rounds++;
      abilityRound++;

      // ── Fire ready abilities ────────────────────────────────────────────────
      for (final ability in abilities) {
        final readyAt = cooldownUntil[ability.id] ?? 0;
        if (abilityRound < readyAt) continue;

        final sv = getValue?.call(ability) ?? ability.value;
        cooldownUntil[ability.id] =
            abilityRound + (getCooldown?.call(ability) ?? ability.cooldownRounds);

        switch (ability.effect) {
          case AbilityEffect.bonusDamage:
            final dmg = ((sv * 0.5).round() * (enemyVulnRounds > 0 ? 1.25 : 1.0))
                .round().clamp(1, 9999);
            enemyHpLocal -= dmg;
            heroDmg      += dmg;
            lastAbilityLog.add('✦ ${ability.name}: $dmg bonus damage!');

          case AbilityEffect.heal:
            final h = (sv * totalHealMult).round().clamp(1, 9999);
            heroHpLocal = (heroHpLocal + h).clamp(0, heroMaxHp);
            lastAbilityLog.add('✦ ${ability.name}: healed $h HP.');

          case AbilityEffect.attackBonus:
            tempAtkBonus  = sv;
            tempAtkRounds = ability.duration > 0 ? ability.duration : 3;
            lastAbilityLog.add('✦ ${ability.name}: +$sv ATK for $tempAtkRounds rounds.');

          case AbilityEffect.acBonus:
            tempAcBonus  = sv;
            tempAcRounds = ability.duration > 0 ? ability.duration : 3;
            lastAbilityLog.add('✦ ${ability.name}: +$sv AC for $tempAcRounds rounds.');

          case AbilityEffect.stun:
            enemyStunned = true;
            lastAbilityLog.add('✦ ${ability.name}: enemy stunned!');

          case AbilityEffect.dot:
            final dmg = ((sv * 0.6).round() * (enemyVulnRounds > 0 ? 1.25 : 1.0))
                .round().clamp(1, 9999);
            enemyHpLocal -= dmg;
            heroDmg      += dmg;
            lastAbilityLog.add('✦ ${ability.name}: $dmg DoT damage!');

          case AbilityEffect.dodge:
            if (tempAcBonus < 6) { tempAcBonus = 6; tempAcRounds = 1; }
            lastAbilityLog.add('✦ ${ability.name}: dodge — +6 AC this round.');

          case AbilityEffect.aura:
            final h = (sv * 0.5 * totalHealMult).round().clamp(1, 9999);
            heroHpLocal = (heroHpLocal + h).clamp(0, heroMaxHp);
            lastAbilityLog.add('✦ ${ability.name}: aura healed $h HP.');

          case AbilityEffect.debuffWeaken:
            enemyWeakenRounds = 3;
            lastAbilityLog.add('✦ ${ability.name}: enemy weakened for 3 rounds!');

          case AbilityEffect.debuffVulnerable:
            enemyVulnRounds = 3;
            lastAbilityLog.add('✦ ${ability.name}: enemy vulnerable for 3 rounds!');
          case AbilityEffect.silence:
            enemyStunned = true;
            lastAbilityLog.add('✦ ${ability.name}: enemy silenced!');
          case AbilityEffect.absorbShield:
            heroHpLocal = (heroHpLocal + sv).clamp(0, heroMaxHp);
            lastAbilityLog.add('✦ ${ability.name}: +$sv HP barrier!');
          case AbilityEffect.missChance:
            enemyWeakenRounds = ability.duration > 0 ? ability.duration : 2;
            lastAbilityLog.add('✦ ${ability.name}: enemy miss chance applied!');
        }
        if (enemyHpLocal <= 0) break;
      }
      if (enemyHpLocal <= 0) break;

      // ── Hero attacks ────────────────────────────────────────────────────────
      // Hero always lands (same as the campaign); no to-hit roll.
      final strikes = (rounds == 1 && hasSwiftness) ? 2 : 1;
      for (var s = 0; s < strikes; s++) {
        final die = weaponBase > 0
            ? weaponBase + rng.nextInt((weaponBase ~/ 3).clamp(1, 50))
            : rng.nextInt(8) + 1;
        var dmg = die + heroStrMod + blessingDmg + tempAtkBonus;
        if (enemyVulnRounds > 0) dmg = (dmg * 1.25).round();
        dmg = (dmg * dmgMult * damageDealtMult).round().clamp(1, 9999);
        if (shieldLeft > 0) {
          final absorbed = dmg < shieldLeft ? dmg : shieldLeft;
          shieldLeft -= absorbed;
          dmg -= absorbed;
          if (dmg <= 0) continue;
        }
        enemyHpLocal -= dmg;
        heroDmg      += dmg;
        if (enemyHpLocal <= 0) break;
      }
      if (enemyHpLocal <= 0) break;

      // ── Enemy attacks ───────────────────────────────────────────────────────
      // Always lands (same as the campaign); armor is flat damage reduction
      // (min 1 so bosses always connect). Matches the animated combat formula.
      if (enemyStunned) {
        enemyStunned = false;
      } else {
        final effAc   = baseAc + tempAcBonus;
        final effEAtk = enemyWeakenRounds > 0 ? (eAtk * 0.7).round() : eAtk;
        final raw = rng.nextInt(effEAtk > 0 ? effEAtk : 1) + 1;
        final dmg = ((raw - effAc).clamp(1, 9999) * damageTakenMult).round().clamp(1, 9999);
        heroHpLocal -= dmg;
        enemyDmg    += dmg;
      }

      // Burning affix: hero DoT at the end of every round
      if (burnPerRound > 0 && heroHpLocal > 0) {
        heroHpLocal -= burnPerRound;
        enemyDmg    += burnPerRound;
      }

      // ── Tick buffs/debuffs at end of round ──────────────────────────────────
      if (tempAtkRounds > 0) { tempAtkRounds--; if (tempAtkRounds == 0) tempAtkBonus = 0; }
      if (tempAcRounds  > 0) { tempAcRounds--;  if (tempAcRounds  == 0) tempAcBonus  = 0; }
      if (enemyWeakenRounds > 0) enemyWeakenRounds--;
      if (enemyVulnRounds   > 0) enemyVulnRounds--;
    }

    lastDamageDealt = heroDmg;
    lastDamageTaken = enemyDmg;
    heroHp = heroHpLocal.clamp(0, heroMaxHp);
    if (heroHp == 0) isDead = true;

    final isBoss  = room.type == DungeonRoomType.boss;
    final isElite = room.type == DungeonRoomType.elite;
    final isAmbushRoom = room.type == DungeonRoomType.ambush;
    final baseGold = isBoss   ? 200 + floor * 80
                   : isElite  ? (100 + floor * 40).round()  // elite pays ~1.3× normal
                   : isAmbushRoom ? (140 + floor * 50).round() // ambush pays ~1.7× normal
                   : 80 + floor * 30;
    final gold = (baseGold * (room.isGoblin ? 6 : 1) * goldBonusMult).round();
    final baseShards = isBoss ? 20 + floor * 4 : 8 + floor;

    lastCombatSummary = isDead
        ? 'Fallen after $rounds rounds. Dealt $heroDmg dmg, took $enemyDmg.'
        : 'Victory in $rounds rounds! Dealt $heroDmg dmg, took $enemyDmg.';

    if (!isDead) {
      goldEarned   += gold;
      shardsEarned += baseShards;
      bones        += isBoss ? 3 : isElite ? 2 : 1; // slain enemy drops Bones
      roomsCleared++;
      if (isBoss) bossesDefeated++;
      return gold;
    }
    return 0;
  }

  // ── Trap resolution ───────────────────────────────────────────────────────

  void resolveTrap(DungeonRoom room) {
    final dmg = room.trapDamage ?? 5;
    heroHp = (heroHp - dmg).clamp(0, heroMaxHp);
    if (heroHp == 0) isDead = true;
    if (!isDead) roomsCleared++;
  }

  // ── Rest site ─────────────────────────────────────────────────────────────

  void resolveRestSite(DungeonRoom room) {
    // Apply event damage first (ambush / bad weather) — capped so it can't kill
    if (room.restDamage > 0) {
      heroHp = (heroHp - room.restDamage).clamp(1, heroMaxHp);
    }
    // Then heal
    final heal = room.restoreHp ?? (heroMaxHp ~/ 5);
    heroHp = (heroHp + heal).clamp(0, heroMaxHp);
    // Bonus gold (supplies event)
    if (room.restBonusGold > 0) goldEarned += room.restBonusGold;
    roomsCleared++;
  }

  // ── Treasure collection ───────────────────────────────────────────────────

  void collectTreasure(DungeonRoom room) {
    goldEarned   += room.treasureGold   ?? 0;
    shardsEarned += room.treasureShards ?? 0;
    roomsCleared++;
  }

  // ── Shrine choice ─────────────────────────────────────────────────────────

  void chooseBlessing(DungeonBlessingType blessing) {
    blessings.add(blessing);
    roomsCleared++;
  }

  // ── Locked chest ──────────────────────────────────────────────────────────

  bool openChest(DungeonRoom room, int availableShards) {
    final cost = room.chestShardCost ?? 30;
    if (availableShards < cost) return false;
    room.chestOpened = true;
    roomsCleared++;
    return true;
  }
}
