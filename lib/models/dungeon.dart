import 'dart:math';
import '../data/enemy_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Dungeon (roguelite run)
//
// Each run is in-memory only — loot is applied to GameState immediately after
// each room, so closing the app mid-run abandons the run without losing earned
// rewards. Only the deepest-floor record is persisted.
// ─────────────────────────────────────────────────────────────────────────────

enum DungeonRoomType { combat, treasure, shrine, trap, boss, lockedChest }

enum DungeonConsumableType { healthPotion, damageBoost, ironShield }

enum DungeonBlessingType { attackUp, defenseUp, goldSense, swiftness }

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
    DungeonBlessingType.attackUp  => '⚔ Battle Fury',
    DungeonBlessingType.defenseUp => '🛡 Stone Skin',
    DungeonBlessingType.goldSense => '💰 Gold Sense',
    DungeonBlessingType.swiftness => '💨 Swiftness',
  };
  String get desc => switch (this) {
    DungeonBlessingType.attackUp  => '+2 to all attack rolls this run',
    DungeonBlessingType.defenseUp => '+2 AC for the rest of the run',
    DungeonBlessingType.goldSense => '+50% gold from combat rooms',
    DungeonBlessingType.swiftness => 'Hero strikes twice in first round',
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
  });

  final int floor;
  final DungeonRoomType type;
  bool resolved = false;

  // Combat / boss
  String? enemyName;
  int? enemyMaxHp;
  int? enemyAtk;
  int? enemyAc;

  // Trap
  String? trapName;
  int? trapDamage;

  // Treasure
  int? treasureGold;
  int? treasureShards;

  // Shrine
  List<DungeonBlessingType>? blessingChoices;

  // Locked chest — costs shards to open
  int? chestShardCost;
  bool chestOpened = false;

  // Whether this boss room drops an item (set externally by GameState)
  bool hasItemDrop = false;

  String get typeIcon => switch (type) {
    DungeonRoomType.combat      => '⚔',
    DungeonRoomType.treasure    => '💎',
    DungeonRoomType.shrine      => '🕯',
    DungeonRoomType.trap        => '⚠',
    DungeonRoomType.boss        => '☠',
    DungeonRoomType.lockedChest => '🔒',
  };

  String get typeName => switch (type) {
    DungeonRoomType.combat      => 'Combat',
    DungeonRoomType.treasure    => 'Treasure',
    DungeonRoomType.shrine      => 'Shrine',
    DungeonRoomType.trap        => 'Trap',
    DungeonRoomType.boss        => 'BOSS',
    DungeonRoomType.lockedChest => 'Locked Chest',
  };

  String get typeHint => switch (type) {
    DungeonRoomType.combat      => 'Fight and earn gold',
    DungeonRoomType.treasure    => 'Collect gold & shards',
    DungeonRoomType.shrine      => 'Choose a blessing',
    DungeonRoomType.trap        => 'Unavoidable damage',
    DungeonRoomType.boss        => 'Greater risk, greater reward',
    DungeonRoomType.lockedChest => 'Spend shards for a rare item',
  };
}

// ── Run ───────────────────────────────────────────────────────────────────────

class DungeonRun {
  DungeonRun({required this.heroMaxHp, required this.heroHp});

  int floor = 1;
  final int heroMaxHp;
  int heroHp;

  // One-shot consumables
  final List<DungeonConsumable> consumables = [
    DungeonConsumable(DungeonConsumableType.healthPotion),
    DungeonConsumable(DungeonConsumableType.damageBoost),
    DungeonConsumable(DungeonConsumableType.ironShield),
  ];

  // Per-run bonuses from shrines
  final List<DungeonBlessingType> blessings = [];

  int get blessingAtk     => blessings.where((b) => b == DungeonBlessingType.attackUp).length * 2;
  int get blessingAc      => blessings.where((b) => b == DungeonBlessingType.defenseUp).length * 2;
  double get goldBonusMult => 1.0 + blessings.where((b) => b == DungeonBlessingType.goldSense).length * 0.5;
  bool get hasSwiftness   => blessings.contains(DungeonBlessingType.swiftness);

  // Consumable effect flags
  bool damageBoostActive = false;
  bool shieldActive      = false;

  // Room selection
  DungeonRoom? currentRoom;
  List<DungeonRoom> roomChoices = [];

  // State
  bool isDead      = false;
  bool isAbandoned = false;
  bool get isOver  => isDead || isAbandoned;

  // Loot accumulated this run
  int goldEarned   = 0;
  int shardsEarned = 0;

  // Post-run stats
  int roomsCleared   = 0;
  int bossesDefeated = 0;

  // Last fight summary for UI
  String lastCombatSummary = '';
  int lastDamageDealt = 0;
  int lastDamageTaken = 0;

  // ── Room generation ──────────────────────────────────────────────────────

  // Floor scaling: 8% stat increase per floor beyond floor 1
  double get _floorMult => 1.0 + (floor - 1) * 0.08;

  void generateRoomChoices(Random rng) {
    roomChoices = [];
    currentRoom = null;

    if (floor % 5 == 0) {
      // Boss floor — only one room
      roomChoices.add(_makeBossRoom(rng));
      return;
    }

    // Pool: combat always included; chest replaces shrine on floor 3+
    final pool = [
      DungeonRoomType.treasure,
      floor >= 3 ? DungeonRoomType.lockedChest : DungeonRoomType.shrine,
      DungeonRoomType.trap,
    ]..shuffle(rng);
    final types = [DungeonRoomType.combat, pool[0], pool[1]];
    types.shuffle(rng);
    for (final t in types) roomChoices.add(_makeRoom(t, rng));
  }

  DungeonRoom _makeRoom(DungeonRoomType t, Random rng) => switch (t) {
    DungeonRoomType.combat      => _makeCombatRoom(rng),
    DungeonRoomType.treasure    => _makeTreasureRoom(rng),
    DungeonRoomType.shrine      => _makeShrineRoom(rng),
    DungeonRoomType.trap        => _makeTrapRoom(rng),
    DungeonRoomType.boss        => _makeBossRoom(rng),
    DungeonRoomType.lockedChest => _makeLockedChest(rng),
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
    return DungeonRoom(
      floor: floor, type: DungeonRoomType.lockedChest,
      chestShardCost: cost,
    );
  }

  DungeonRoom _makeTreasureRoom(Random rng) => DungeonRoom(
    floor: floor, type: DungeonRoomType.treasure,
    treasureGold: 150 + floor * 45 + rng.nextInt(80),
    treasureShards: 8 + floor * 2 + rng.nextInt(15),
  );

  DungeonRoom _makeShrineRoom(Random rng) {
    final all = DungeonBlessingType.values.toList()..shuffle(rng);
    return DungeonRoom(
      floor: floor, type: DungeonRoomType.shrine,
      blessingChoices: all.take(3).toList(),
    );
  }

  DungeonRoom _makeTrapRoom(Random rng) {
    const names = ['Poison Spikes', 'Fire Jet', 'Boulder Trap', 'Arcane Curse', 'Acid Pool'];
    return DungeonRoom(
      floor: floor, type: DungeonRoomType.trap,
      trapName: names[rng.nextInt(names.length)],
      trapDamage: (6 + floor * 4).clamp(1, heroMaxHp ~/ 2),
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

  /// Resolves a combat room. Returns gold earned; sets heroHp and combat log.
  int resolveCombat(DungeonRoom room, int heroAtkBonus, int heroAc,
      int heroStrMod, Random rng) {
    int heroHpLocal   = heroHp;
    int enemyHpLocal  = room.enemyMaxHp ?? 10;
    final effAtk = heroAtkBonus + blessingAtk;
    final effAc  = heroAc + blessingAc;
    final eAtk   = room.enemyAtk ?? 5;
    final eAc    = room.enemyAc  ?? 10;

    int heroDmg  = 0;
    int enemyDmg = 0;
    int rounds   = 0;

    while (heroHpLocal > 0 && enemyHpLocal > 0 && rounds < 60) {
      rounds++;
      // Hero strikes (double on first round with Swiftness)
      final strikes = (rounds == 1 && hasSwiftness) ? 2 : 1;
      for (var s = 0; s < strikes; s++) {
        final roll = rng.nextInt(20) + 1;
        if (roll + effAtk >= eAc || roll == 20) {
          var dmg = rng.nextInt(8) + 1 + heroStrMod.clamp(0, 20);
          if (damageBoostActive) { dmg *= 3; damageBoostActive = false; }
          dmg = dmg.clamp(1, 9999);
          enemyHpLocal -= dmg;
          heroDmg      += dmg;
          if (enemyHpLocal <= 0) break;
        }
      }
      if (enemyHpLocal <= 0) break;

      // Enemy strikes
      if (shieldActive) {
        shieldActive = false; // absorbs one hit
      } else {
        final eRoll = rng.nextInt(20) + 1;
        if (eRoll + (eAtk ~/ 8).clamp(0, 12) >= effAc || eRoll == 20) {
          final dmg = (rng.nextInt(eAtk ~/ 3 + 1) + 1).clamp(1, 9999);
          heroHpLocal -= dmg;
          enemyDmg    += dmg;
        }
      }
    }

    lastDamageDealt  = heroDmg;
    lastDamageTaken  = enemyDmg;
    heroHp           = heroHpLocal.clamp(0, heroMaxHp);
    if (heroHp == 0) isDead = true;

    // Loot
    final isBoss    = room.type == DungeonRoomType.boss;
    final baseGold  = isBoss ? 200 + floor * 80 : 80 + floor * 30;
    final gold      = (baseGold * goldBonusMult).round();
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

  /// Returns true if opened (enough shards); caller must deduct shards.
  bool openChest(DungeonRoom room, int availableShards) {
    final cost = room.chestShardCost ?? 30;
    if (availableShards < cost) return false;
    room.chestOpened = true;
    roomsCleared++;
    return true;
  }
}
