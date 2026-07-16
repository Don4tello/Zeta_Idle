import 'package:flutter/material.dart';

enum BountyType {
  killEnemies,
  completeDungeon,
  reachEndlessFloor,
  winBossRush,
  dealDamage,
  killUndead,
  killBeast,
  killArcane,
  killDemonic,
  killConstruct,
}

class BountyReward {
  const BountyReward({this.gold = 0, this.zcoins = 0, this.shards = 0, this.xp = 0});
  final int gold;
  final int zcoins;
  final int shards;
  final int xp;
}

class BountyDef {
  const BountyDef({
    required this.id,
    required this.type,
    required this.label,
    required this.target,
    required this.reward,
    required this.icon,
    required this.color,
  });
  final String id;
  final BountyType type;
  final String label;
  final int target;
  final BountyReward reward;
  final String icon;
  final Color color;
}

class Bounty {
  Bounty({required this.def, this.progress = 0, this.claimed = false});
  final BountyDef def;
  int progress;
  bool claimed;

  bool get isComplete => progress >= def.target;

  Map<String, dynamic> toJson() => {
        'id': def.id,
        'progress': progress,
        'claimed': claimed,
      };
}

class BountyPool {
  static const List<BountyDef> all = [
    // ── Generic ───────────────────────────────────────────────────────────────
    BountyDef(
      id: 'kill_20',
      type: BountyType.killEnemies,
      label: 'Slay 20 enemies',
      target: 20,
      reward: BountyReward(gold: 200, xp: 150),
      icon: '⚔',
      color: Color(0xFFff6644),
    ),
    BountyDef(
      id: 'kill_50',
      type: BountyType.killEnemies,
      label: 'Slay 50 enemies',
      target: 50,
      reward: BountyReward(gold: 500, zcoins: 5, xp: 300),
      icon: '⚔',
      color: Color(0xFFff4422),
    ),
    BountyDef(
      id: 'dungeon_1',
      type: BountyType.completeDungeon,
      label: 'Complete 1 Dungeon run',
      target: 1,
      reward: BountyReward(gold: 300, shards: 3),
      icon: '🏰',
      color: Color(0xFF66aaff),
    ),
    BountyDef(
      id: 'dungeon_3',
      type: BountyType.completeDungeon,
      label: 'Complete 3 Dungeon runs',
      target: 3,
      reward: BountyReward(gold: 800, zcoins: 8, shards: 8),
      icon: '🏰',
      color: Color(0xFF4488ff),
    ),
    BountyDef(
      id: 'endless_10',
      type: BountyType.reachEndlessFloor,
      label: 'Reach Endless floor 10',
      target: 10,
      reward: BountyReward(gold: 400, zcoins: 6),
      icon: '♾',
      color: Color(0xFF88cc44),
    ),
    BountyDef(
      id: 'endless_25',
      type: BountyType.reachEndlessFloor,
      label: 'Reach Endless floor 25',
      target: 25,
      reward: BountyReward(zcoins: 15, shards: 5),
      icon: '♾',
      color: Color(0xFF66aa22),
    ),
    BountyDef(
      id: 'boss_rush_1',
      type: BountyType.winBossRush,
      label: 'Complete a Boss Rush run',
      target: 1,
      reward: BountyReward(zcoins: 10, shards: 5),
      icon: '👑',
      color: Color(0xFFffcc44),
    ),
    BountyDef(
      id: 'damage_1000',
      type: BountyType.dealDamage,
      label: 'Deal 1,000 total damage',
      target: 1000,
      reward: BountyReward(gold: 600, xp: 400),
      icon: '💥',
      color: Color(0xFFff88cc),
    ),
    BountyDef(
      id: 'damage_5000',
      type: BountyType.dealDamage,
      label: 'Deal 5,000 total damage',
      target: 5000,
      reward: BountyReward(gold: 2000, zcoins: 12, xp: 1000),
      icon: '💥',
      color: Color(0xFFff44aa),
    ),
    // ── Themed — Undead ───────────────────────────────────────────────────────
    BountyDef(
      id: 'kill_undead_10',
      type: BountyType.killUndead,
      label: 'Slay 10 undead enemies',
      target: 10,
      reward: BountyReward(gold: 250, shards: 2),
      icon: '☩',
      color: Color(0xFF8888ff),
    ),
    BountyDef(
      id: 'kill_undead_25',
      type: BountyType.killUndead,
      label: 'Slay 25 undead enemies',
      target: 25,
      reward: BountyReward(gold: 600, zcoins: 6, xp: 250),
      icon: '☩',
      color: Color(0xFF6666dd),
    ),
    // ── Themed — Beast ────────────────────────────────────────────────────────
    BountyDef(
      id: 'kill_beast_10',
      type: BountyType.killBeast,
      label: 'Slay 10 beast enemies',
      target: 10,
      reward: BountyReward(gold: 250, shards: 2),
      icon: '🐺',
      color: Color(0xFF88cc44),
    ),
    BountyDef(
      id: 'kill_beast_25',
      type: BountyType.killBeast,
      label: 'Slay 25 beast enemies',
      target: 25,
      reward: BountyReward(gold: 600, zcoins: 6, xp: 250),
      icon: '🐺',
      color: Color(0xFF66aa22),
    ),
    // ── Themed — Arcane ───────────────────────────────────────────────────────
    BountyDef(
      id: 'kill_arcane_10',
      type: BountyType.killArcane,
      label: 'Destroy 10 arcane creatures',
      target: 10,
      reward: BountyReward(gold: 300, shards: 3),
      icon: '✦',
      color: Color(0xFFcc44ff),
    ),
    BountyDef(
      id: 'kill_arcane_25',
      type: BountyType.killArcane,
      label: 'Destroy 25 arcane creatures',
      target: 25,
      reward: BountyReward(gold: 700, zcoins: 7, xp: 300),
      icon: '✦',
      color: Color(0xFFaa22dd),
    ),
    // ── Themed — Demonic ──────────────────────────────────────────────────────
    BountyDef(
      id: 'kill_demonic_10',
      type: BountyType.killDemonic,
      label: 'Banish 10 demonic fiends',
      target: 10,
      reward: BountyReward(gold: 300, shards: 3),
      icon: '🔥',
      color: Color(0xFFff6644),
    ),
    BountyDef(
      id: 'kill_demonic_25',
      type: BountyType.killDemonic,
      label: 'Banish 25 demonic fiends',
      target: 25,
      reward: BountyReward(gold: 700, zcoins: 7, xp: 300),
      icon: '🔥',
      color: Color(0xFFdd4422),
    ),
    // ── Themed — Construct ────────────────────────────────────────────────────
    BountyDef(
      id: 'kill_construct_10',
      type: BountyType.killConstruct,
      label: 'Dismantle 10 constructs',
      target: 10,
      reward: BountyReward(gold: 350, shards: 3),
      icon: '⚙',
      color: Color(0xFFff9922),
    ),
    BountyDef(
      id: 'kill_construct_25',
      type: BountyType.killConstruct,
      label: 'Dismantle 25 constructs',
      target: 25,
      reward: BountyReward(gold: 800, zcoins: 8, xp: 350),
      icon: '⚙',
      color: Color(0xFFdd7711),
    ),
  ];

  // Zone name → featured enemy weakness types for that zone
  static const _zoneThemes = <String, List<BountyType>>{
    'The Cursed Realm':       [BountyType.killUndead,    BountyType.killBeast,    BountyType.killDemonic],
    'The Blighted Wilds':     [BountyType.killBeast,     BountyType.killDemonic,  BountyType.killUndead],
    'The Infernal Depths':    [BountyType.killUndead,    BountyType.killConstruct],
    'The Void Expanse':       [BountyType.killBeast,     BountyType.killArcane,   BountyType.killConstruct],
    'Throne of Ruin':         [BountyType.killArcane,    BountyType.killBeast,    BountyType.killUndead],
    'The Crystal Sanctum':    [BountyType.killArcane,    BountyType.killConstruct],
    'The Shadow Realm':       [BountyType.killUndead],
    'The Frozen Wastes':      [BountyType.killUndead,    BountyType.killBeast,    BountyType.killArcane],
    'The Storm Heights':      [BountyType.killBeast,     BountyType.killConstruct],
    'The Abyssal Ocean':      [BountyType.killBeast,     BountyType.killArcane],
    'The Twilight Labyrinth': [BountyType.killArcane,    BountyType.killUndead],
    'The Forgotten Empire':   [BountyType.killConstruct],
    'The Plaguelands':        [BountyType.killUndead,    BountyType.killBeast],
    'The Celestial Ruins':    [BountyType.killArcane,    BountyType.killUndead],
    'The Dark Matter':        [BountyType.killConstruct, BountyType.killArcane],
    'The Eternal Prison':     [BountyType.killDemonic,   BountyType.killConstruct],
    'The Abyss Gate':         [BountyType.killDemonic,   BountyType.killArcane],
    'The Shattered Realm':    [BountyType.killUndead,    BountyType.killDemonic],
    'The Final Frontier':     [BountyType.killArcane,    BountyType.killConstruct],
    'The Omega Throne':       [BountyType.killDemonic,   BountyType.killUndead],
  };

  static List<BountyType> themesForZone(String zone) =>
      _zoneThemes[zone] ?? const [];

  static bool isZoneThemed(BountyType type, String zone) =>
      (_zoneThemes[zone] ?? const []).contains(type);

  static String typeIcon(BountyType type) => switch (type) {
    BountyType.killUndead    => '☩',
    BountyType.killBeast     => '🐺',
    BountyType.killArcane    => '✦',
    BountyType.killDemonic   => '🔥',
    BountyType.killConstruct => '⚙',
    _                        => '',
  };

  static BountyDef? byId(String? id) {
    if (id == null) return null;
    try {
      return all.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<int> _shuffleIndices(int length, int seed) {
    final indices = List<int>.generate(length, (i) => i);
    for (var i = indices.length - 1; i > 0; i--) {
      final j = (seed * 6364136223846793005 + i * 1442695040888963407) % (i + 1);
      final tmp = indices[i];
      indices[i] = indices[j.abs()];
      indices[j.abs()] = tmp;
    }
    return indices;
  }

  static List<BountyDef> pickDaily(int seed, {String? zone}) {
    final themes = zone != null
        ? (_zoneThemes[zone] ?? const <BountyType>[])
        : const <BountyType>[];

    if (themes.isEmpty) {
      return _shuffleIndices(all.length, seed).take(3).map((i) => all[i]).toList();
    }

    final themed   = all.where((b) => themes.contains(b.type)).toList();
    final unthemed = all.where((b) => !themes.contains(b.type)).toList();

    final themedIdx   = _shuffleIndices(themed.length,   seed + 999983);
    final unthemedIdx = _shuffleIndices(unthemed.length, seed + 1999979);

    final picked = <BountyDef>[];

    // Always include 1 zone-themed bounty
    if (themedIdx.isNotEmpty) picked.add(themed[themedIdx.first]);

    // Fill remaining 2 from non-themed, preferring type diversity
    final unthemedOrdered = unthemedIdx.map((i) => unthemed[i]).toList();
    for (final b in unthemedOrdered) {
      if (picked.length >= 3) break;
      if (!picked.any((r) => r.type == b.type)) picked.add(b);
    }
    // Fallback: allow type duplicates if needed
    for (final b in unthemedOrdered) {
      if (picked.length >= 3) break;
      if (!picked.contains(b)) picked.add(b);
    }

    return picked;
  }
}
