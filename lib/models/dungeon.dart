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
  restSite,    // Recover 20% max HP
  boss,        // Every 5th floor — boss encounter
}

enum DungeonConsumableType { healthPotion, damageBoost, ironShield }

enum DungeonBlessingType { attackUp, defenseUp, goldSense, swiftness, toughSkin, bloodthirst }

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

// ── Consumable ────────────────────────────────────────────────────────────────

class DungeonConsumable {
  DungeonConsumable(this.type);
  final DungeonConsumableType type;
  bool used = false;

  String get label => switch (type) {
    DungeonConsumableType.healthPotion => '🧪 Heal Potion',
    DungeonConsumableType.damageBoost  => '⚔ Power Brew',
    DungeonConsumableType.ironShield   => '🛡 Iron Ward',
  };
  String get desc => switch (type) {
    DungeonConsumableType.healthPotion => 'Restore 40% max HP',
    DungeonConsumableType.damageBoost  => 'Triple your next hit',
    DungeonConsumableType.ironShield   => 'Block one enemy attack',
  };
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
  });

  final int floor;
  final DungeonRoomType type;
  bool resolved = false;

  // Combat / boss / elite / ambush
  String? enemyName;
  int? enemyMaxHp;
  int? enemyAtk;
  int? enemyAc;
  bool isAmbush; // enemy gets free strike before round 1

  // Trap
  String? trapName;
  int? trapDamage;

  // Treasure
  int? treasureGold;
  int? treasureShards;

  // Shrine / altar
  List<DungeonBlessingType>? blessingChoices;

  // Locked chest
  int? chestShardCost;
  bool chestOpened = false;

  // Rest site
  int? restoreHp;

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
  DungeonRun({required this.heroMaxHp, required this.heroHp, this.tier = 1});

  int tier;
  int floor = 1;
  final int heroMaxHp;
  int heroHp;

  final List<DungeonConsumable> consumables = [
    DungeonConsumable(DungeonConsumableType.healthPotion),
    DungeonConsumable(DungeonConsumableType.damageBoost),
    DungeonConsumable(DungeonConsumableType.ironShield),
  ];

  final List<DungeonBlessingType> blessings = [];
  final List<ShrineEffect> shrineEffects = [];

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

  bool damageBoostActive = false;
  bool shieldActive      = false;

  DungeonRoom? currentRoom;
  List<DungeonRoom> roomChoices = [];

  bool isDead      = false;
  bool isAbandoned = false;
  bool get isOver  => isDead || isAbandoned;

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

  double get _floorMult => 1.0 + (floor - 1) * 0.08;
  double get _tierMult  => 1.0 + (tier  - 1) * 0.30;

  // Weighted room type selection — auto-picks one room and sets currentRoom.
  void generateRoomChoices(Random rng) {
    roomChoices = [];
    currentRoom = null;

    final room = floor % 5 == 0 ? _makeBossRoom(rng) : _pickWeightedRoom(rng);
    roomChoices = [room];
    currentRoom = room; // auto-select — no player path choice
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
    final e = EnemyData.enemyForStage(stageIdx);
    return DungeonRoom(
      floor: floor, type: DungeonRoomType.combat,
      enemyName: e.name,
      enemyMaxHp: (e.maxHealth * _floorMult * _tierMult).round(),
      enemyAtk: (e.attack * _floorMult * _tierMult).round(),
      enemyAc: e.armorClass + (floor ~/ 5).clamp(0, 6),
    );
  }

  DungeonRoom _makeEliteRoom(Random rng) {
    final stageIdx = (floor - 1).clamp(0, 50);
    final e = EnemyData.enemyForStage(stageIdx);
    return DungeonRoom(
      floor: floor, type: DungeonRoomType.elite,
      enemyName: '★ ${e.name}',
      enemyMaxHp: (e.maxHealth * 1.5 * _floorMult * _tierMult).round(),
      enemyAtk: (e.attack * 1.4 * _floorMult * _tierMult).round(),
      enemyAc: e.armorClass + 1 + (floor ~/ 5).clamp(0, 6),
    );
  }

  DungeonRoom _makeAmbushRoom(Random rng) {
    final stageIdx = (floor - 1).clamp(0, 50);
    final e = EnemyData.enemyForStage(stageIdx);
    return DungeonRoom(
      floor: floor, type: DungeonRoomType.ambush,
      enemyName: e.name,
      enemyMaxHp: (e.maxHealth * _floorMult * _tierMult).round(),
      enemyAtk: (e.attack * _floorMult * _tierMult).round(),
      enemyAc: e.armorClass + (floor ~/ 5).clamp(0, 6),
      isAmbush: true,
    );
  }

  DungeonRoom _makeRestSiteRoom(Random rng) {
    final heal = (heroMaxHp * 0.20).round().clamp(1, heroMaxHp);
    return DungeonRoom(
      floor: floor, type: DungeonRoomType.restSite,
      restoreHp: heal,
    );
  }

  DungeonRoom _makeBossRoom(Random rng) {
    final stageIdx = ((floor - 1) * 2).clamp(0, 60);
    final e = EnemyData.enemyForStage(stageIdx);
    return DungeonRoom(
      floor: floor, type: DungeonRoomType.boss,
      enemyName: '☠ ${e.name}',
      enemyMaxHp: (e.maxHealth * 2.5 * _floorMult * _tierMult).round(),
      enemyAtk: (e.attack * 1.6 * _floorMult * _tierMult).round(),
      enemyAc: e.armorClass + 2 + (floor ~/ 5).clamp(0, 8),
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
    return DungeonRoom(floor: floor, type: DungeonRoomType.shrine, blessingChoices: all.take(3).toList());
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

  // ── Consumable use ────────────────────────────────────────────────────────

  bool useConsumable(DungeonConsumableType type) {
    final c = consumables.where((c) => c.type == type && !c.used).firstOrNull;
    if (c == null) return false;
    c.used = true;
    switch (type) {
      case DungeonConsumableType.healthPotion:
        final heal = (heroMaxHp * 0.40).round();
        heroHp = (heroHp + heal).clamp(0, heroMaxHp);
      case DungeonConsumableType.damageBoost:
        damageBoostActive = true;
      case DungeonConsumableType.ironShield:
        shieldActive = true;
    }
    return true;
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
  }) {
    int heroHpLocal  = heroHp;
    int enemyHpLocal = room.enemyMaxHp ?? 10;
    final baseAtk = heroAtkBonus + blessingAtk;
    final baseAc  = heroAc + blessingAc;
    final eAtk    = room.enemyAtk ?? 5;
    final eAc     = room.enemyAc  ?? 10;

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
      if (shieldActive) {
        shieldActive = false;
      } else {
        heroHpLocal -= pre;
        enemyDmg    += pre;
        ambushPreHit = pre;
        if (heroHpLocal <= 0) { heroHp = 0; isDead = true; lastDamageDealt = 0; lastDamageTaken = enemyDmg; lastCombatSummary = 'Slain in the ambush before the fight began.'; return 0; }
      }
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
            final h = sv.clamp(1, 9999);
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
            final h = (sv * 0.5).round().clamp(1, 9999);
            heroHpLocal = (heroHpLocal + h).clamp(0, heroMaxHp);
            lastAbilityLog.add('✦ ${ability.name}: aura healed $h HP.');

          case AbilityEffect.debuffWeaken:
            enemyWeakenRounds = 3;
            lastAbilityLog.add('✦ ${ability.name}: enemy weakened for 3 rounds!');

          case AbilityEffect.debuffVulnerable:
            enemyVulnRounds = 3;
            lastAbilityLog.add('✦ ${ability.name}: enemy vulnerable for 3 rounds!');
        }
        if (enemyHpLocal <= 0) break;
      }
      if (enemyHpLocal <= 0) break;

      // ── Hero attacks ────────────────────────────────────────────────────────
      final effAtk = baseAtk + tempAtkBonus;
      final strikes = (rounds == 1 && hasSwiftness) ? 2 : 1;
      for (var s = 0; s < strikes; s++) {
        final roll = rng.nextInt(20) + 1;
        if (roll + effAtk >= eAc || roll == 20) {
          var dmg = rng.nextInt(8) + 1 + heroStrMod.clamp(0, 20) + blessingDmg;
          if (damageBoostActive) { dmg *= 3; damageBoostActive = false; }
          if (enemyVulnRounds > 0) dmg = (dmg * 1.25).round();
          dmg = dmg.clamp(1, 9999);
          enemyHpLocal -= dmg;
          heroDmg      += dmg;
          if (enemyHpLocal <= 0) break;
        }
      }
      if (enemyHpLocal <= 0) break;

      // ── Enemy attacks ───────────────────────────────────────────────────────
      if (enemyStunned) {
        enemyStunned = false;
      } else if (shieldActive) {
        shieldActive = false;
      } else {
        final effAc     = baseAc + tempAcBonus;
        final effEAtk   = enemyWeakenRounds > 0 ? (eAtk * 0.7).round() : eAtk;
        final eRoll     = rng.nextInt(20) + 1;
        if (eRoll + (effEAtk ~/ 8).clamp(0, 12) >= effAc || eRoll == 20) {
          final dmg = (rng.nextInt(effEAtk ~/ 3 + 1) + 1).clamp(1, 9999);
          heroHpLocal -= dmg;
          enemyDmg    += dmg;
        }
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
    final gold = (baseGold * goldBonusMult).round();
    final baseShards = isBoss ? 20 + floor * 4 : 8 + floor;

    lastCombatSummary = isDead
        ? 'Fallen after $rounds rounds. Dealt $heroDmg dmg, took $enemyDmg.'
        : 'Victory in $rounds rounds! Dealt $heroDmg dmg, took $enemyDmg.';

    if (!isDead) {
      goldEarned   += gold;
      shardsEarned += baseShards;
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
    final heal = room.restoreHp ?? (heroMaxHp ~/ 5);
    heroHp = (heroHp + heal).clamp(0, heroMaxHp);
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
