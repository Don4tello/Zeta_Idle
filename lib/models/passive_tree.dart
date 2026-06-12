// ─────────────────────────────────────────────────────────────────────────────
// Passive Skill Tree — 5 branches × 6 multi-rank nodes.
// Each node supports up to 5 ranks. Upgrade cost scales per rank.
// Prerequisite: previous node in branch must be rank ≥ 1.
// Ascendant branch unlocks when 4+ nodes are unlocked in other branches.
// ─────────────────────────────────────────────────────────────────────────────

enum PassiveBranch {
  slayer,    // ⚔  combat offense
  guardian,  // 🛡  combat defense
  merchant,  // 💰  economy
  mystic,    // ✨  abilities & essence
  ascendant, // ⭐  cross-branch mastery (unlocks late)
}

enum PassiveEffect {
  attackFlat,    // +N to attack rolls
  damageFlat,    // +N to damage rolls
  critChance,    // +N% crit chance
  pierce,        // ignore N enemy AC
  allDamage,     // +N% to ALL damage dealt
  maxHp,         // +N% max HP
  regenFlat,     // regen N HP per round
  armorFlat,     // +N flat AC
  dodgeChance,   // +N% chance to dodge hits
  goldFlat,      // +N% gold from kills
  shardFlat,     // +N shard per kill
  xpFlat,        // +N% XP from kills
  idleFlat,      // +N to idle rate
  cooldownReduce,// -N rounds to all ability cooldowns
  abilityDamage, // +N% to ability damage
  healBoost,     // +N% to heal abilities
  essenceGain,   // +N% essence from kills
  allPenetration,// +N% elemental resistance penetration
}

class PassiveNode {
  const PassiveNode({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.branch,
    required this.tier,
    required this.essenceCost,
    required this.effect,
    required this.value,
    this.maxRank = 5,
    this.unlockRequires = 0,
  });

  final String id;
  final String name;
  final String emoji;
  final String description; // should include "per rank"
  final PassiveBranch branch;
  final int tier;           // 0 = first in branch, 5 = last
  final int essenceCost;    // base cost for rank 1; rank N costs baseCost × N × 1.5
  final PassiveEffect effect;
  final int value;          // magnitude per rank
  final int maxRank;
  final int unlockRequires; // min total unlocks in other branches (Ascendant only)

  String get fullDescription => '${_sign}${value * maxRank}${_suffix} at max rank';

  String get _sign => switch (effect) {
    PassiveEffect.cooldownReduce => '−',
    _ => '+',
  };

  String get _suffix => switch (effect) {
    PassiveEffect.attackFlat || PassiveEffect.damageFlat ||
    PassiveEffect.armorFlat  || PassiveEffect.shardFlat  ||
    PassiveEffect.idleFlat   || PassiveEffect.pierce     ||
    PassiveEffect.regenFlat  || PassiveEffect.cooldownReduce => '',
    _ => '%',
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Node catalog
// ─────────────────────────────────────────────────────────────────────────────

const kPassiveNodes = <PassiveNode>[

  // ── ⚔ SLAYER — Offense ───────────────────────────────────────────────────
  PassiveNode(id: 'slayer_0', name: 'Keen Edge',      emoji: '🎯',
    branch: PassiveBranch.slayer,   tier: 0, essenceCost: 8,
    effect: PassiveEffect.critChance,    value: 2,
    description: '+2% crit chance per rank'),
  PassiveNode(id: 'slayer_1', name: 'Brute Force',    emoji: '⚡',
    branch: PassiveBranch.slayer,   tier: 1, essenceCost: 18,
    effect: PassiveEffect.damageFlat,    value: 2,
    description: '+2 flat damage per rank'),
  PassiveNode(id: 'slayer_2', name: 'Sure Strike',    emoji: '🗡',
    branch: PassiveBranch.slayer,   tier: 2, essenceCost: 35,
    effect: PassiveEffect.attackFlat,    value: 2,
    description: '+2 attack bonus per rank'),
  PassiveNode(id: 'slayer_3', name: 'Executioner',    emoji: '💀',
    branch: PassiveBranch.slayer,   tier: 3, essenceCost: 70,
    effect: PassiveEffect.abilityDamage, value: 12,
    description: '+12% ability damage per rank'),
  PassiveNode(id: 'slayer_4', name: 'Piercing Veil',  emoji: '🔱',
    branch: PassiveBranch.slayer,   tier: 4, essenceCost: 130,
    effect: PassiveEffect.pierce,        value: 2,
    description: 'Ignore 2 enemy AC per rank'),
  PassiveNode(id: 'slayer_5', name: "Death's Touch",  emoji: '☠',
    branch: PassiveBranch.slayer,   tier: 5, essenceCost: 250,
    effect: PassiveEffect.damageFlat,    value: 6,
    description: '+6 flat damage per rank'),
  PassiveNode(id: 'slayer_6', name: 'Veil Ripper',   emoji: '🔥',
    branch: PassiveBranch.slayer,   tier: 6, essenceCost: 400,
    effect: PassiveEffect.allPenetration, value: 4,
    description: '+4% elemental penetration per rank'),

  // ── 🛡 GUARDIAN — Defense ─────────────────────────────────────────────────
  PassiveNode(id: 'guardian_0', name: 'Iron Skin',       emoji: '🛡',
    branch: PassiveBranch.guardian, tier: 0, essenceCost: 8,
    effect: PassiveEffect.maxHp,         value: 10,
    description: '+10% max HP per rank'),
  PassiveNode(id: 'guardian_1', name: 'Stone Guard',     emoji: '🪨',
    branch: PassiveBranch.guardian, tier: 1, essenceCost: 18,
    effect: PassiveEffect.armorFlat,     value: 2,
    description: '+2 flat armor per rank'),
  PassiveNode(id: 'guardian_2', name: 'Nimble Footing',  emoji: '💨',
    branch: PassiveBranch.guardian, tier: 2, essenceCost: 35,
    effect: PassiveEffect.dodgeChance,   value: 3,
    description: '+3% dodge chance per rank'),
  PassiveNode(id: 'guardian_3', name: 'Regenerator',     emoji: '❤',
    branch: PassiveBranch.guardian, tier: 3, essenceCost: 70,
    effect: PassiveEffect.regenFlat,     value: 3,
    description: '+3 HP regen per round, per rank'),
  PassiveNode(id: 'guardian_4', name: 'Iron Fortress',   emoji: '🏰',
    branch: PassiveBranch.guardian, tier: 4, essenceCost: 130,
    effect: PassiveEffect.maxHp,         value: 15,
    description: '+15% max HP per rank'),
  PassiveNode(id: 'guardian_5', name: 'Impenetrable',    emoji: '⚙',
    branch: PassiveBranch.guardian, tier: 5, essenceCost: 250,
    effect: PassiveEffect.armorFlat,     value: 4,
    description: '+4 flat armor per rank'),

  // ── 💰 MERCHANT — Economy ─────────────────────────────────────────────────
  PassiveNode(id: 'merchant_0', name: 'Scavenger',    emoji: '💰',
    branch: PassiveBranch.merchant, tier: 0, essenceCost: 8,
    effect: PassiveEffect.goldFlat,      value: 12,
    description: '+12% gold per rank'),
  PassiveNode(id: 'merchant_1', name: 'Shard Seeker', emoji: '💎',
    branch: PassiveBranch.merchant, tier: 1, essenceCost: 18,
    effect: PassiveEffect.shardFlat,     value: 1,
    description: '+1 shard per kill, per rank'),
  PassiveNode(id: 'merchant_2', name: 'Scholar',      emoji: '📖',
    branch: PassiveBranch.merchant, tier: 2, essenceCost: 35,
    effect: PassiveEffect.xpFlat,        value: 15,
    description: '+15% XP per rank'),
  PassiveNode(id: 'merchant_3', name: 'Surveyor',     emoji: '⏳',
    branch: PassiveBranch.merchant, tier: 3, essenceCost: 70,
    effect: PassiveEffect.idleFlat,      value: 2,
    description: '+2 idle rate per rank'),
  PassiveNode(id: 'merchant_4', name: 'Plunderer',    emoji: '🏆',
    branch: PassiveBranch.merchant, tier: 4, essenceCost: 130,
    effect: PassiveEffect.goldFlat,      value: 20,
    description: '+20% gold per rank'),
  PassiveNode(id: 'merchant_5', name: 'Opulence',     emoji: '👑',
    branch: PassiveBranch.merchant, tier: 5, essenceCost: 250,
    effect: PassiveEffect.xpFlat,        value: 25,
    description: '+25% XP per rank'),

  // ── ✨ MYSTIC — Abilities & Essence ───────────────────────────────────────
  PassiveNode(id: 'mystic_0', name: 'Quick Hands',   emoji: '🌀',
    branch: PassiveBranch.mystic,   tier: 0, essenceCost: 8,
    effect: PassiveEffect.cooldownReduce, value: 1,
    description: '−1 ability cooldown per rank'),
  PassiveNode(id: 'mystic_1', name: 'Arcane Touch',  emoji: '✨',
    branch: PassiveBranch.mystic,   tier: 1, essenceCost: 18,
    effect: PassiveEffect.abilityDamage, value: 15,
    description: '+15% ability damage per rank'),
  PassiveNode(id: 'mystic_2', name: 'Life Weave',    emoji: '🌿',
    branch: PassiveBranch.mystic,   tier: 2, essenceCost: 35,
    effect: PassiveEffect.healBoost,     value: 20,
    description: '+20% heal effectiveness per rank'),
  PassiveNode(id: 'mystic_3', name: 'Essence Draw',  emoji: '🔮',
    branch: PassiveBranch.mystic,   tier: 3, essenceCost: 70,
    effect: PassiveEffect.essenceGain,   value: 20,
    description: '+20% essence from kills, per rank'),
  PassiveNode(id: 'mystic_4', name: 'Chain Cast',    emoji: '⚗',
    branch: PassiveBranch.mystic,   tier: 4, essenceCost: 130,
    effect: PassiveEffect.abilityDamage, value: 25,
    description: '+25% ability damage per rank'),
  PassiveNode(id: 'mystic_5', name: 'Transcendence', emoji: '🌟',
    branch: PassiveBranch.mystic,   tier: 5, essenceCost: 250,
    effect: PassiveEffect.abilityDamage, value: 40,
    description: '+40% ability damage per rank'),

  // ── ⭐ ASCENDANT — Cross-branch mastery (requires 4 unlocks elsewhere) ────
  PassiveNode(id: 'ascendant_0', name: "Warrior's Soul", emoji: '⚔',
    branch: PassiveBranch.ascendant, tier: 0, essenceCost: 100,
    effect: PassiveEffect.allDamage,     value: 5,
    unlockRequires: 4,
    description: '+5% all damage per rank'),
  PassiveNode(id: 'ascendant_1', name: "Fortune's Favor", emoji: '🌙',
    branch: PassiveBranch.ascendant, tier: 1, essenceCost: 200,
    effect: PassiveEffect.goldFlat,      value: 20,
    description: '+20% gold per rank'),
  PassiveNode(id: 'ascendant_2', name: 'Life Force',      emoji: '💖',
    branch: PassiveBranch.ascendant, tier: 2, essenceCost: 350,
    effect: PassiveEffect.maxHp,         value: 15,
    description: '+15% max HP per rank'),
  PassiveNode(id: 'ascendant_3', name: 'Power Surge',     emoji: '⭐',
    branch: PassiveBranch.ascendant, tier: 3, essenceCost: 550,
    effect: PassiveEffect.abilityDamage, value: 20,
    description: '+20% ability damage per rank'),
  PassiveNode(id: 'ascendant_4', name: 'Soul Harvest',    emoji: '🌌',
    branch: PassiveBranch.ascendant, tier: 4, essenceCost: 800,
    effect: PassiveEffect.essenceGain,   value: 25,
    description: '+25% essence per rank'),
  PassiveNode(id: 'ascendant_5', name: 'Convergence',     emoji: '🔆',
    branch: PassiveBranch.ascendant, tier: 5, essenceCost: 1200,
    effect: PassiveEffect.allDamage,     value: 8,
    description: '+8% all damage per rank'),
];

// ─────────────────────────────────────────────────────────────────────────────
// PassiveTree — multi-rank state tracker
// ─────────────────────────────────────────────────────────────────────────────

class PassiveTree {
  PassiveTree();

  final Map<String, int> _ranks = {}; // nodeId → current rank (absent = 0)

  int rankOf(String id) => _ranks[id] ?? 0;

  bool isUnlocked(String id) => rankOf(id) >= 1;

  bool isMaxRank(String id) {
    final node = _nodeById(id);
    return rankOf(id) >= node.maxRank;
  }

  bool canUpgrade(String id) {
    final node = _nodeById(id);
    if (isMaxRank(id)) return false;
    if (node.tier == 0) {
      if (node.branch != PassiveBranch.ascendant) return true;
      return _otherBranchUnlocks >= node.unlockRequires;
    }
    // Require previous node in same branch to be rank ≥ 1
    final branchStr = id.split('_')[0];
    return isUnlocked('${branchStr}_${node.tier - 1}');
  }

  int costForNextRank(String id) {
    final node = _nodeById(id);
    final nextRank = rankOf(id) + 1;
    return (node.essenceCost * nextRank * 1.5).round().clamp(node.essenceCost, 9999999);
  }

  void upgrade(String id) {
    _ranks[id] = rankOf(id) + 1;
  }

  // Legacy alias kept for achievement checks
  bool canUnlock(String id) => canUpgrade(id);
  void unlock(String id) => upgrade(id);

  int get unlockedCount => _ranks.entries.where((e) => e.value >= 1).length;

  int totalOf(PassiveEffect effect) {
    var total = 0;
    for (final node in kPassiveNodes) {
      final r = rankOf(node.id);
      if (r >= 1 && node.effect == effect) total += node.value * r;
    }
    return total;
  }

  int get _otherBranchUnlocks => kPassiveNodes
      .where((n) => n.branch != PassiveBranch.ascendant && isUnlocked(n.id))
      .length;

  bool get ascendantBranchAvailable => _otherBranchUnlocks >= 4;

  // ── Persistence ────────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
    'ranks': Map<String, int>.from(_ranks),
  };

  void loadFromJson(Map<String, dynamic> json) {
    _ranks.clear();
    if (json['ranks'] is Map) {
      (json['ranks'] as Map).forEach((k, v) {
        if (k is String && v is int) _ranks[k] = v;
      });
      return;
    }
    // Legacy save: {unlocked: ['off_0', ...]} → treat each as rank 1, map old IDs
    if (json['unlocked'] is List) {
      for (final id in (json['unlocked'] as List).cast<String>()) {
        final mapped = _legacyIdMap[id];
        if (mapped != null) _ranks[mapped] = 1;
      }
    }
  }

  static const _legacyIdMap = <String, String>{
    'off_0': 'slayer_0',   'off_1': 'slayer_1',   'off_2': 'slayer_2',
    'off_3': 'slayer_3',   'off_4': 'slayer_4',   'off_5': 'slayer_5',
    'def_0': 'guardian_0', 'def_1': 'guardian_1', 'def_2': 'guardian_2',
    'def_3': 'guardian_3', 'def_4': 'guardian_4', 'def_5': 'guardian_5',
    'eco_0': 'merchant_0', 'eco_1': 'merchant_1', 'eco_2': 'merchant_2',
    'eco_3': 'merchant_3', 'eco_4': 'merchant_4', 'eco_5': 'merchant_5',
    'mas_0': 'mystic_0',   'mas_1': 'mystic_1',   'mas_2': 'mystic_2',
    'mas_3': 'mystic_3',   'mas_4': 'mystic_4',   'mas_5': 'mystic_5',
  };

  void reset() => _ranks.clear();

  // ── Helpers ─────────────────────────────────────────────────────────────────

  static PassiveNode _nodeById(String id) =>
      kPassiveNodes.firstWhere((n) => n.id == id,
          orElse: () => throw StateError('Unknown passive node: $id'));
}
