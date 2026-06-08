import 'package:flutter/material.dart';

enum BountyType {
  killEnemies,
  completeDungeon,
  reachEndlessFloor,
  winBossRush,
  dealDamage,
}

class BountyReward {
  const BountyReward({this.gold = 0, this.crystals = 0, this.shards = 0, this.xp = 0});
  final int gold;
  final int crystals;
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
      reward: BountyReward(gold: 500, crystals: 5, xp: 300),
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
      reward: BountyReward(gold: 800, crystals: 8, shards: 8),
      icon: '🏰',
      color: Color(0xFF4488ff),
    ),
    BountyDef(
      id: 'endless_10',
      type: BountyType.reachEndlessFloor,
      label: 'Reach Endless floor 10',
      target: 10,
      reward: BountyReward(gold: 400, crystals: 6),
      icon: '♾',
      color: Color(0xFF88cc44),
    ),
    BountyDef(
      id: 'endless_25',
      type: BountyType.reachEndlessFloor,
      label: 'Reach Endless floor 25',
      target: 25,
      reward: BountyReward(crystals: 15, shards: 5),
      icon: '♾',
      color: Color(0xFF66aa22),
    ),
    BountyDef(
      id: 'boss_rush_1',
      type: BountyType.winBossRush,
      label: 'Complete a Boss Rush run',
      target: 1,
      reward: BountyReward(crystals: 10, shards: 5),
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
      reward: BountyReward(gold: 2000, crystals: 12, xp: 1000),
      icon: '💥',
      color: Color(0xFFff44aa),
    ),
  ];

  static BountyDef? byId(String? id) {
    if (id == null) return null;
    try {
      return all.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<BountyDef> pickDaily(int seed) {
    final indices = List.generate(all.length, (i) => i);
    // Deterministic shuffle using seed (day number)
    for (var i = indices.length - 1; i > 0; i--) {
      final j = (seed * 6364136223846793005 + i * 1442695040888963407) % (i + 1);
      final tmp = indices[i];
      indices[i] = indices[j.abs()];
      indices[j.abs()] = tmp;
    }
    return indices.take(3).map((i) => all[i]).toList();
  }
}
