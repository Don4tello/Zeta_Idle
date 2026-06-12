import 'dart:math';
import 'package:flutter/material.dart' show Color;

// ─────────────────────────────────────────────────────────────
// Milestone perk data — used by the upgrade screen UI
// ─────────────────────────────────────────────────────────────

class MilestonePerk {
  const MilestonePerk({
    required this.levelRequired,
    required this.name,
    required this.description,
  });
  final int    levelRequired;
  final String name;
  final String description;
}

// ─────────────────────────────────────────────────────────────
// Node enum
// ─────────────────────────────────────────────────────────────

enum EndlessNode {
  str,
  dex,
  con,
  intelligence,
  wis,
  cha;

  String get displayName {
    switch (this) {
      case EndlessNode.str:          return 'Power';
      case EndlessNode.dex:          return 'Agility';
      case EndlessNode.con:          return 'Vitality';
      case EndlessNode.intelligence: return 'Arcane';
      case EndlessNode.wis:          return 'Focus';
      case EndlessNode.cha:          return 'Fortune';
    }
  }

  String get statLabel {
    switch (this) {
      case EndlessNode.str:          return 'PWR';
      case EndlessNode.dex:          return 'AGI';
      case EndlessNode.con:          return 'VIT';
      case EndlessNode.intelligence: return 'ARC';
      case EndlessNode.wis:          return 'FOC';
      case EndlessNode.cha:          return 'FOR';
    }
  }

  String get effectLabel {
    switch (this) {
      case EndlessNode.str:          return '+0.8% attack damage per level';
      case EndlessNode.dex:          return '+1 attack roll per 2 levels';
      case EndlessNode.con:          return '+1% HP recovery per victory per level';
      case EndlessNode.intelligence: return '+1.2% gold earned per level';
      case EndlessNode.wis:          return '+0.8% Shards of Fate per level';
      case EndlessNode.cha:          return '+0.9% XP earned per level';
    }
  }

  int get baseCost {
    switch (this) {
      case EndlessNode.str:          return 80;
      case EndlessNode.dex:          return 100;
      case EndlessNode.con:          return 70;
      case EndlessNode.intelligence: return 130;
      case EndlessNode.wis:          return 110;
      case EndlessNode.cha:          return 90;
    }
  }

  Color get color {
    switch (this) {
      case EndlessNode.str:          return const Color(0xFFe05030);
      case EndlessNode.dex:          return const Color(0xFF40b060);
      case EndlessNode.con:          return const Color(0xFF4488cc);
      case EndlessNode.intelligence: return const Color(0xFFC9A35A);
      case EndlessNode.wis:          return const Color(0xFF9060c0);
      case EndlessNode.cha:          return const Color(0xFFc06080);
    }
  }

  List<MilestonePerk> get milestones {
    switch (this) {
      case EndlessNode.str: return const [
        MilestonePerk(levelRequired: 5,  name: 'Iron Grip',       description: '+3 to all attack rolls'),
        MilestonePerk(levelRequired: 10, name: 'Keen Edge',       description: 'Critical hits on roll 19 or 20'),
        MilestonePerk(levelRequired: 25, name: 'Savage Momentum', description: 'Advantage on attack after each kill'),
      ];
      case EndlessNode.dex: return const [
        MilestonePerk(levelRequired: 5,  name: 'Light Footed',  description: '+1 effective Armour Class'),
        MilestonePerk(levelRequired: 10, name: 'Blade Flicker', description: '12% chance to strike twice per turn'),
        MilestonePerk(levelRequired: 25, name: 'Shadow Step',   description: '15% chance to dodge enemy attacks'),
      ];
      case EndlessNode.con: return const [
        MilestonePerk(levelRequired: 5,  name: 'Thick Hide',    description: 'Reduce all incoming damage by 1'),
        MilestonePerk(levelRequired: 10, name: 'Battle Scarred',description: 'Regen 2% HP after each hit taken'),
        MilestonePerk(levelRequired: 25, name: 'Unbroken',      description: 'Survive one killing blow per battle at 1 HP'),
      ];
      case EndlessNode.intelligence: return const [
        MilestonePerk(levelRequired: 5,  name: 'Studied Foe',       description: 'Enemy stats revealed before battle'),
        MilestonePerk(levelRequired: 10, name: 'Exploit Weakness',  description: '+15% damage against enemies with AC ≤ 14'),
        MilestonePerk(levelRequired: 25, name: 'Arcane Efficiency', description: '+15% bonus gold on every kill'),
      ];
      case EndlessNode.wis: return const [
        MilestonePerk(levelRequired: 5,  name: 'Farsight',        description: '+2 Shards of Fate per kill'),
        MilestonePerk(levelRequired: 10, name: 'Battle Awareness', description: "Enemy's first attack rolls at disadvantage"),
        MilestonePerk(levelRequired: 25, name: 'Frugal Mind',     description: '15% chance any upgrade costs 0 Shards'),
      ];
      case EndlessNode.cha: return const [
        MilestonePerk(levelRequired: 5,  name: "Silver Tongue",  description: 'All upgrade costs reduced by 5%'),
        MilestonePerk(levelRequired: 10, name: 'Rally Cry',      description: '+20% XP from every kill'),
        MilestonePerk(levelRequired: 25, name: "Fortune's Favour", description: '10% chance to double Shard drops'),
      ];
    }
  }
}

// ─────────────────────────────────────────────────────────────
// EndlessUpgrades — stores node levels, computes bonuses
// ─────────────────────────────────────────────────────────────

class EndlessUpgrades {
  final Map<EndlessNode, int> _levels = {
    for (final n in EndlessNode.values) n: 0,
  };

  // ── Queries ────────────────────────────────────────────────

  int levelOf(EndlessNode node) => _levels[node]!;

  /// Cost to upgrade node from its current level to the next.
  /// Silver Tongue (CHA Lv5) applies a 5% discount.
  int costFor(EndlessNode node) {
    final lvl = _levels[node]!;
    final raw = (node.baseCost * pow(1.45, lvl)).round().clamp(node.baseCost, 999999999);
    return silverTongue ? (raw * 0.95).round().clamp(1, 999999999) : raw;
  }

  bool canAfford(EndlessNode node, int shards) => shards >= costFor(node);

  // ── Per-level bonus multipliers ────────────────────────────

  double get damageMultiplier =>
      pow(1.008, levelOf(EndlessNode.str)).toDouble();

  int get attackRollBonus => levelOf(EndlessNode.dex) ~/ 2;

  double get hpRecoveryFraction =>
      (pow(1.010, levelOf(EndlessNode.con)) - 1).toDouble();

  double get goldMultiplier =>
      pow(1.012, levelOf(EndlessNode.intelligence)).toDouble();

  double get shardMultiplier =>
      pow(1.008, levelOf(EndlessNode.wis)).toDouble();

  double get xpMultiplier =>
      pow(1.009, levelOf(EndlessNode.cha)).toDouble();

  // ── Milestone perk flags ───────────────────────────────────

  // STR
  bool get ironGrip       => levelOf(EndlessNode.str) >= 5;
  bool get keenEdge       => levelOf(EndlessNode.str) >= 10;
  bool get savageMomentum => levelOf(EndlessNode.str) >= 25;

  // DEX
  bool get lightFooted  => levelOf(EndlessNode.dex) >= 5;
  bool get bladeFlicker => levelOf(EndlessNode.dex) >= 10;
  bool get shadowStep   => levelOf(EndlessNode.dex) >= 25;

  // CON
  bool get thickHide    => levelOf(EndlessNode.con) >= 5;
  bool get battleScarred => levelOf(EndlessNode.con) >= 10;
  bool get unbroken     => levelOf(EndlessNode.con) >= 25;

  // INT
  bool get studiedFoe       => levelOf(EndlessNode.intelligence) >= 5;
  bool get exploitWeakness  => levelOf(EndlessNode.intelligence) >= 10;
  bool get arcaneEfficiency => levelOf(EndlessNode.intelligence) >= 25;

  // WIS
  bool get farsight        => levelOf(EndlessNode.wis) >= 5;
  bool get battleAwareness => levelOf(EndlessNode.wis) >= 10;
  bool get frugalMind      => levelOf(EndlessNode.wis) >= 25;

  // CHA
  bool get silverTongue   => levelOf(EndlessNode.cha) >= 5;
  bool get rallyCry       => levelOf(EndlessNode.cha) >= 10;
  bool get fortunesFavour => levelOf(EndlessNode.cha) >= 25;

  // ── Mutation ───────────────────────────────────────────────

  int upgrade(EndlessNode node) {
    final cost = costFor(node);
    _levels[node] = _levels[node]! + 1;
    return cost;
  }

  void reset() {
    for (final n in EndlessNode.values) {
      _levels[n] = 0;
    }
  }

  // ── Serialisation ──────────────────────────────────────────

  Map<String, dynamic> toJson() => {
    for (final n in EndlessNode.values) n.name: _levels[n],
  };

  void loadFromJson(Map<String, dynamic> json) {
    for (final n in EndlessNode.values) {
      _levels[n] = (json[n.name] as int?) ?? 0;
    }
  }
}
