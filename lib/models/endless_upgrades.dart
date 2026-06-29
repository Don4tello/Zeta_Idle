import 'dart:math';
import 'package:flutter/material.dart' show Color;

// ─────────────────────────────────────────────────────────────
// Synergy status — used by the upgrade screen UI
// ─────────────────────────────────────────────────────────────

class SynergyStatus {
  const SynergyStatus({
    required this.name,
    required this.nodeLabel,
    required this.effectLabel,
    required this.unlocked,
    required this.level1,
    required this.level2,
    required this.node1,
    required this.node2,
  });
  final String name;
  final String nodeLabel;
  final String effectLabel;
  final bool unlocked;
  final int level1;
  final int level2;
  final EndlessNode node1;
  final EndlessNode node2;
}

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
      case EndlessNode.str:          return 'Brutality';
      case EndlessNode.dex:          return 'Precision';
      case EndlessNode.con:          return 'Toughness';
      case EndlessNode.intelligence: return 'Prosperity';
      case EndlessNode.wis:          return 'Insight';
      case EndlessNode.cha:          return 'Focus';
    }
  }

  String get statLabel {
    switch (this) {
      case EndlessNode.str:          return 'BRT';
      case EndlessNode.dex:          return 'PRC';
      case EndlessNode.con:          return 'TGH';
      case EndlessNode.intelligence: return 'PRO';
      case EndlessNode.wis:          return 'INS';
      case EndlessNode.cha:          return 'FOC';
    }
  }

  String get effectLabel {
    switch (this) {
      case EndlessNode.str:          return '+0.8% attack damage per level';
      case EndlessNode.dex:          return '+1 critical damage per 2 levels';
      case EndlessNode.con:          return '+1 flat damage reduction per level';
      case EndlessNode.intelligence: return '+1.2% gold earned per level';
      case EndlessNode.wis:          return '+0.8% Echoes per level';
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
        MilestonePerk(levelRequired: 5,  name: 'Iron Grip',       description: '+3 critical damage on all attacks'),
        MilestonePerk(levelRequired: 10, name: 'Keen Edge',       description: 'Critical hit threshold: 19+'),
        MilestonePerk(levelRequired: 25, name: 'Savage Momentum', description: 'Double-strike chance after each kill'),
      ];
      case EndlessNode.dex: return const [
        MilestonePerk(levelRequired: 5,  name: 'Light Footed',  description: '+1 Armor'),
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
        MilestonePerk(levelRequired: 10, name: 'Exploit Weakness',  description: '+15% damage against low-armor enemies'),
        MilestonePerk(levelRequired: 25, name: 'Arcane Efficiency', description: '+15% bonus gold on every kill'),
      ];
      case EndlessNode.wis: return const [
        MilestonePerk(levelRequired: 5,  name: 'Farsight',        description: '+2 Echoes per kill'),
        MilestonePerk(levelRequired: 10, name: 'Battle Awareness', description: 'Auto-dodge the first enemy attack each battle'),
        MilestonePerk(levelRequired: 25, name: 'Frugal Mind',     description: '15% chance any upgrade costs 0 Echoes'),
      ];
      case EndlessNode.cha: return const [
        MilestonePerk(levelRequired: 5,  name: "Silver Tongue",  description: 'All upgrade costs reduced by 5%'),
        MilestonePerk(levelRequired: 10, name: 'Rally Cry',      description: '+20% XP from every kill'),
        MilestonePerk(levelRequired: 25, name: "Fortune's Favour", description: '10% chance to double Echo drops'),
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

  int get flatDamageReduction => levelOf(EndlessNode.con);

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

  // ── Cross-node synergies (both nodes ≥ 10) ────────────────────────────────

  // STR 10 + CON 10 → Juggernaut: flat damage reduction +1, +10% max HP
  bool get synergyJuggernaut =>
      levelOf(EndlessNode.str) >= 10 && levelOf(EndlessNode.con) >= 10;

  // STR 10 + DEX 10 → Berserker: blade flicker chance 20% (instead of 12%)
  bool get synergyBerserker =>
      levelOf(EndlessNode.str) >= 10 && levelOf(EndlessNode.dex) >= 10;

  // CON 10 + WIS 10 → Iron Sage: battle scarred heals 4% (instead of 2%)
  bool get synergyIronSage =>
      levelOf(EndlessNode.con) >= 10 && levelOf(EndlessNode.wis) >= 10;

  // INT 10 + WIS 10 → Mindweave: exploit weakness triggers at AC ≤ 16
  bool get synergyMindweave =>
      levelOf(EndlessNode.intelligence) >= 10 && levelOf(EndlessNode.wis) >= 10;

  // INT 10 + CHA 10 → Merchant Scholar: +15% flat gold bonus on every kill
  bool get synergyMerchantScholar =>
      levelOf(EndlessNode.intelligence) >= 10 && levelOf(EndlessNode.cha) >= 10;

  // DEX 10 + CHA 10 → Shadow Merchant: fortune's favour triggers at 20% (instead of 10%)
  bool get synergyShadowMerchant =>
      levelOf(EndlessNode.dex) >= 10 && levelOf(EndlessNode.cha) >= 10;

  List<SynergyStatus> get allSynergies => [
    SynergyStatus(name: 'Juggernaut',       nodeLabel: 'PWR×VIT', effectLabel: '−1 dmg taken, +10% HP',   unlocked: synergyJuggernaut,     level1: levelOf(EndlessNode.str),           level2: levelOf(EndlessNode.con),  node1: EndlessNode.str,           node2: EndlessNode.con),
    SynergyStatus(name: 'Berserker',        nodeLabel: 'PWR×AGI', effectLabel: 'Blade Flicker: 20%',      unlocked: synergyBerserker,      level1: levelOf(EndlessNode.str),           level2: levelOf(EndlessNode.dex),  node1: EndlessNode.str,           node2: EndlessNode.dex),
    SynergyStatus(name: 'Iron Sage',        nodeLabel: 'FOR×FOC', effectLabel: 'Battle Scarred heals 4%', unlocked: synergyIronSage,       level1: levelOf(EndlessNode.con),           level2: levelOf(EndlessNode.wis),  node1: EndlessNode.con,           node2: EndlessNode.wis),
    SynergyStatus(name: 'Mindweave',        nodeLabel: 'ARC×FOC', effectLabel: 'Exploit Weakness: AC≤16', unlocked: synergyMindweave,      level1: levelOf(EndlessNode.intelligence),  level2: levelOf(EndlessNode.wis),  node1: EndlessNode.intelligence,  node2: EndlessNode.wis),
    SynergyStatus(name: 'Merchant Scholar', nodeLabel: 'ARC×FOR', effectLabel: '+15% Gold on every kill', unlocked: synergyMerchantScholar,level1: levelOf(EndlessNode.intelligence),  level2: levelOf(EndlessNode.cha),  node1: EndlessNode.intelligence,  node2: EndlessNode.cha),
    SynergyStatus(name: 'Shadow Merchant',  nodeLabel: 'AGI×FOR', effectLabel: "Fortune's Favour: 20%",   unlocked: synergyShadowMerchant, level1: levelOf(EndlessNode.dex),           level2: levelOf(EndlessNode.cha),  node1: EndlessNode.dex,           node2: EndlessNode.cha),
  ];

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
