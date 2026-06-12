import 'dart:math';
import '../data/enemy_data.dart';

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
    DungeonBlessingType.attackUp   => '+2 to all attack rolls this run',
    DungeonBlessingType.defenseUp  => '+2 AC for the rest of this run',
    DungeonBlessingType.goldSense  => '+50% gold from combat rooms',
    DungeonBlessingType.swiftness  => 'Hero strikes twice in the first round',
    DungeonBlessingType.toughSkin  => 'Reduce all trap & ambush damage by 40%',
    DungeonBlessingType.bloodthirst => '+4 to damage rolls for the rest of this run',
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
  DungeonRun({required this.heroMaxHp, required this.heroHp});

  int floor = 1;
  final int heroMaxHp;
  int heroHp;

  final List<DungeonConsumable> consumables = [
    DungeonConsumable(DungeonConsumableType.healthPotion),
    DungeonConsumable(DungeonConsumableType.damageBoost),
    DungeonConsumable(DungeonConsumableType.ironShield),
  ];

  final List<DungeonBlessingType> blessings = [];

  int get blessingAtk      => blessings.where((b) => b == DungeonBlessingType.attackUp).length * 2;
  int get blessingAc       => blessings.where((b) => b == DungeonBlessingType.defenseUp).length * 2;
  int get blessingDmg      => blessings.where((b) => b == DungeonBlessingType.bloodthirst).length * 4;
  double get goldBonusMult => 1.0 + blessings.where((b) => b == DungeonBlessingType.goldSense).length * 0.5;
  double get trapDmgMult   => blessings.contains(DungeonBlessingType.toughSkin) ? 0.6 : 1.0;
  bool get hasSwiftness    => blessings.contains(DungeonBlessingType.swiftness);

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
  // Extra context for ambush pre-hit shown in UI
  int ambushPreHit = 0;

  // ── Room generation ──────────────────────────────────────────────────────

  double get _floorMult => 1.0 + (floor - 1) * 0.08;

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
      enemyMaxHp: (e.maxHealth * _floorMult).round(),
      enemyAtk: (e.attack * _floorMult).round(),
      enemyAc: e.armorClass + (floor ~/ 5).clamp(0, 6),
    );
  }

  DungeonRoom _makeEliteRoom(Random rng) {
    final stageIdx = (floor - 1).clamp(0, 50);
    final e = EnemyData.enemyForStage(stageIdx);
    return DungeonRoom(
      floor: floor, type: DungeonRoomType.elite,
      enemyName: '★ ${e.name}',
      enemyMaxHp: (e.maxHealth * 1.5 * _floorMult).round(),
      enemyAtk: (e.attack * 1.4 * _floorMult).round(),
      enemyAc: e.armorClass + 1 + (floor ~/ 5).clamp(0, 6),
    );
  }

  DungeonRoom _makeAmbushRoom(Random rng) {
    final stageIdx = (floor - 1).clamp(0, 50);
    final e = EnemyData.enemyForStage(stageIdx);
    return DungeonRoom(
      floor: floor, type: DungeonRoomType.ambush,
      enemyName: e.name,
      enemyMaxHp: (e.maxHealth * _floorMult).round(),
      enemyAtk: (e.attack * _floorMult).round(),
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
      enemyMaxHp: (e.maxHealth * 2.5 * _floorMult).round(),
      enemyAtk: (e.attack * 1.6 * _floorMult).round(),
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
    final rawDmg = (6 + floor * 4).clamp(1, heroMaxHp ~/ 2);
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
  int resolveCombat(DungeonRoom room, int heroAtkBonus, int heroAc,
      int heroStrMod, Random rng) {
    int heroHpLocal  = heroHp;
    int enemyHpLocal = room.enemyMaxHp ?? 10;
    final effAtk = heroAtkBonus + blessingAtk;
    final effAc  = heroAc + blessingAc;
    final eAtk   = room.enemyAtk ?? 5;
    final eAc    = room.enemyAc  ?? 10;

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
      final strikes = (rounds == 1 && hasSwiftness) ? 2 : 1;
      for (var s = 0; s < strikes; s++) {
        final roll = rng.nextInt(20) + 1;
        if (roll + effAtk >= eAc || roll == 20) {
          var dmg = rng.nextInt(8) + 1 + heroStrMod.clamp(0, 20) + blessingDmg;
          if (damageBoostActive) { dmg *= 3; damageBoostActive = false; }
          dmg = dmg.clamp(1, 9999);
          enemyHpLocal -= dmg;
          heroDmg      += dmg;
          if (enemyHpLocal <= 0) break;
        }
      }
      if (enemyHpLocal <= 0) break;

      if (shieldActive) {
        shieldActive = false;
      } else {
        final eRoll = rng.nextInt(20) + 1;
        if (eRoll + (eAtk ~/ 8).clamp(0, 12) >= effAc || eRoll == 20) {
          final dmg = (rng.nextInt(eAtk ~/ 3 + 1) + 1).clamp(1, 9999);
          heroHpLocal -= dmg;
          enemyDmg    += dmg;
        }
      }
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
