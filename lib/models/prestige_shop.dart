enum PrestigeCategory { combat, economy, progression, mastery }

extension PrestigeCategoryLabel on PrestigeCategory {
  String get label => switch (this) {
        PrestigeCategory.combat      => 'COMBAT',
        PrestigeCategory.economy     => 'ECONOMY',
        PrestigeCategory.progression => 'PROGRESSION',
        PrestigeCategory.mastery     => 'MASTERY',
      };
  String get icon => switch (this) {
        PrestigeCategory.combat      => '⚔',
        PrestigeCategory.economy     => '💰',
        PrestigeCategory.progression => '⬆',
        PrestigeCategory.mastery     => '🔧',
      };
}

class PrestigeNode {
  const PrestigeNode({
    required this.id,
    required this.name,
    required this.description,
    required this.soulCost,
    required this.category,
    this.prerequisiteId,
    this.paragonGate = 0,
  });

  final String id;
  final String name;
  final String description;
  final int soulCost;
  final PrestigeCategory category;
  final String? prerequisiteId;
  // Total paragon points that must be SPENT on the paragon board before this
  // perk can be unlocked (0 = no gate). Encourages board investment first.
  final int paragonGate;
}

const kPrestigeNodes = <PrestigeNode>[
  // ── COMBAT ──────────────────────────────────────────────────────────────────
  PrestigeNode(
    id: 'iron_resolve',
    name: 'Iron Resolve',
    description: '+30% maximum HP. Survive longer every run.',
    soulCost: 3,
    category: PrestigeCategory.combat,
    paragonGate: 50,
  ),
  PrestigeNode(
    id: 'blood_drinker',
    name: 'Blood Drinker',
    description: 'Lifesteal: heal 6% of the damage you deal (up to 12% max HP per round).',
    soulCost: 5,
    category: PrestigeCategory.combat,
    prerequisiteId: 'iron_resolve',
    paragonGate: 200,
  ),
  PrestigeNode(
    id: 'killing_blow',
    name: 'Killing Blow',
    description: '+8% critical hit chance on all attacks.',
    soulCost: 4,
    category: PrestigeCategory.combat,
    paragonGate: 100,
  ),
  PrestigeNode(
    id: 'deaths_edge',
    name: "Death's Edge",
    description: 'Critical hits deal +5% bonus damage.',
    soulCost: 8,
    category: PrestigeCategory.combat,
    prerequisiteId: 'killing_blow',
    paragonGate: 350,
  ),
  PrestigeNode(
    id: 'destroyer',
    name: 'Destroyer',
    description: '+5% damage on all attacks permanently.',
    soulCost: 10,
    category: PrestigeCategory.combat,
    prerequisiteId: 'deaths_edge',
    paragonGate: 500,
  ),
  // ── ECONOMY ─────────────────────────────────────────────────────────────────
  PrestigeNode(
    id: 'start_gold',
    name: 'Blood Tithe',
    description: '+20% gold income from all sources in every run.',
    soulCost: 3,
    category: PrestigeCategory.economy,
    paragonGate: 50,
  ),
  PrestigeNode(
    id: 'war_spoils',
    name: 'War Spoils',
    description: '+35% more gold income (stacks with Blood Tithe for +55% total).',
    soulCost: 5,
    category: PrestigeCategory.economy,
    prerequisiteId: 'start_gold',
    paragonGate: 500,
  ),
  PrestigeNode(
    id: 'carrion_picker',
    name: 'Carrion Picker',
    description: '+50% shard drops from all kills.',
    soulCost: 3,
    category: PrestigeCategory.economy,
    paragonGate: 100,
  ),
  PrestigeNode(
    id: 'essence_bonus',
    name: 'Soul Harvest',
    description: '+50% essence from all kills.',
    soulCost: 3,
    category: PrestigeCategory.economy,
    paragonGate: 200,
  ),
  PrestigeNode(
    id: 'treasure_sense',
    name: 'Treasure Sense',
    description: '+35% gold earned from all battles.',
    soulCost: 4,
    category: PrestigeCategory.economy,
    paragonGate: 350,
  ),
  // (Mythril Memory removed — Mythril is never lost now, so it was redundant.)
  // ── PROGRESSION ─────────────────────────────────────────────────────────────
  PrestigeNode(
    id: 'swift_learner',
    name: 'Swift Learner',
    description: '+30% XP from all sources.',
    soulCost: 3,
    category: PrestigeCategory.progression,
    paragonGate: 50,
  ),
  // ("Veteran's Path" / "Battle-Hardened" head-start nodes removed — they were
  // worded around the deprecated Rebirth mechanic.)
  PrestigeNode(
    id: 'ability_disc',
    name: 'Arcane Economy',
    description: 'Ability upgrades cost 35% fewer shards.',
    soulCost: 3,
    category: PrestigeCategory.progression,
    paragonGate: 100,
  ),
  PrestigeNode(
    id: 'instant_recall',
    name: 'Instant Recall',
    description: 'Begin each run with 1,500 gold (stacks with other bonuses).',
    soulCost: 4,
    category: PrestigeCategory.progression,
    paragonGate: 200,
  ),
  // ── MASTERY ─────────────────────────────────────────────────────────────────
  PrestigeNode(
    id: 'idle_bonus',
    name: 'Eternal Flame',
    description: '+30 idle income rate permanently.',
    soulCost: 3,
    category: PrestigeCategory.mastery,
    paragonGate: 50,
  ),
  // Idle-cap extenders — base offline accumulation is 24h; each of these adds
  // +6h (up to +24h → a 48h maximum). Chained so you invest in order.
  PrestigeNode(
    id: 'idle_reserve_1',
    name: 'Deep Reserves I',
    description: 'Idle rewards keep building for +6h while you\'re away (30h total).',
    soulCost: 5,
    category: PrestigeCategory.mastery,
    paragonGate: 100,
  ),
  PrestigeNode(
    id: 'idle_reserve_2',
    name: 'Deep Reserves II',
    description: '+6h more idle accumulation while away (36h total).',
    soulCost: 8,
    category: PrestigeCategory.mastery,
    prerequisiteId: 'idle_reserve_1',
    paragonGate: 200,
  ),
  PrestigeNode(
    id: 'idle_reserve_3',
    name: 'Deep Reserves III',
    description: '+6h more idle accumulation while away (42h total).',
    soulCost: 12,
    category: PrestigeCategory.mastery,
    prerequisiteId: 'idle_reserve_2',
    paragonGate: 350,
  ),
  PrestigeNode(
    id: 'idle_reserve_4',
    name: 'Deep Reserves IV',
    description: '+6h more idle accumulation while away (48h total — the max).',
    soulCost: 16,
    category: PrestigeCategory.mastery,
    prerequisiteId: 'idle_reserve_3',
    paragonGate: 500,
  ),
  PrestigeNode(
    id: 'forge_bonus',
    name: 'Master Forger',
    description: 'Forge common→rare requires only 2 items instead of 3.',
    soulCost: 3,
    category: PrestigeCategory.mastery,
    paragonGate: 100,
  ),
  PrestigeNode(
    id: 'soul_conduit',
    name: 'Soul Conduit',
    description: 'Earn +5 bonus Paragon Points.',
    soulCost: 6,
    category: PrestigeCategory.mastery,
    paragonGate: 200,
  ),
  // (Artifact Vault removed — artifacts are always kept now, so it was redundant.)
  PrestigeNode(
    id: 'soul_overdrive',
    name: 'Soul Overdrive',
    description: 'The campaign begins at Stage 41.',
    soulCost: 7,
    category: PrestigeCategory.progression,
    paragonGate: 350,
  ),
  PrestigeNode(
    id: 'paragon_dominance',
    name: 'Paragon Dominance',
    description: 'Grants +1% to all stats for each Tier you\'ve unlocked (stacks with level scaling).',
    soulCost: 15,
    category: PrestigeCategory.mastery,
    prerequisiteId: 'soul_conduit',
    paragonGate: 500,
  ),
];

// ── Paragon board: rankable, infinitely-scaling stat nodes ───────────────────
// The one-time nodes above dry up after a few rebirths. These are repeatable:
// each rank adds a bonus and costs more, so points always have a direction to
// pour into (Diablo-style paragon investment by category).
enum ParagonEffect { damage, hp, gold, xp, crit, critDmg, idle, healRating }

class ParagonStat {
  const ParagonStat({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    required this.effect,
    required this.perRank,
    required this.costBase,
    this.suffix = '%',
  });
  final String id, name, icon;
  final PrestigeCategory category;
  final ParagonEffect effect;
  final double perRank;   // bonus added per rank
  final int costBase;     // next-rank cost = costBase * (currentRank + 1)
  final String suffix;
}

const kParagonStats = <ParagonStat>[
  ParagonStat(id: 'p_might',    name: 'Might',        icon: '⚔',  category: PrestigeCategory.combat,      effect: ParagonEffect.damage,  perRank: 1.0, costBase: 2),
  ParagonStat(id: 'p_vitality', name: 'Vitality',     icon: '❤', category: PrestigeCategory.combat,      effect: ParagonEffect.hp,      perRank: 1.0, costBase: 2),
  ParagonStat(id: 'p_fortune',  name: 'Fortune',      icon: '💰', category: PrestigeCategory.economy,     effect: ParagonEffect.gold,    perRank: 1.5, costBase: 2),
  ParagonStat(id: 'p_wisdom',   name: 'Wisdom',       icon: '📖', category: PrestigeCategory.progression, effect: ParagonEffect.xp,      perRank: 1.5, costBase: 2),
  ParagonStat(id: 'p_eternal',  name: 'Eternal Flame',icon: '✦',  category: PrestigeCategory.mastery,     effect: ParagonEffect.idle,    perRank: 3.0, costBase: 2),
  ParagonStat(id: 'p_vitalist', name: 'Vitalist',     icon: '✚',  category: PrestigeCategory.combat,      effect: ParagonEffect.healRating, perRank: 0.25, costBase: 3),
];

ParagonStat? paragonStatById(String id) {
  for (final s in kParagonStats) {
    if (s.id == id) return s;
  }
  return null;
}

class PrestigeShop {
  PrestigeShop();

  final Set<String> _unlocked = {};
  // Paragon board ranks (infinite investment).
  final Map<String, int> _paragonRanks = {};

  int paragonRank(String id) => _paragonRanks[id] ?? 0;
  // Flat cost: every rank on the board costs exactly 1 Paragon Point.
  int paragonCost(ParagonStat s) => 1;
  bool canRankUp(ParagonStat s, int souls) => souls >= paragonCost(s);
  void rankUpParagon(String id) => _paragonRanks[id] = paragonRank(id) + 1;

  /// Total bonus (summed across ranks) for an effect — e.g. damage % to apply.
  double paragonTotal(ParagonEffect e) {
    var sum = 0.0;
    for (final s in kParagonStats) {
      if (s.effect == e) sum += paragonRank(s.id) * s.perRank;
    }
    return sum;
  }
  int get paragonPointsSpent {
    // Each rank costs 1 point, so total spent = total ranks across the board.
    var total = 0;
    for (final s in kParagonStats) {
      total += paragonRank(s.id);
    }
    return total;
  }

  bool isUnlocked(String id) => _unlocked.contains(id);

  bool canUnlock(PrestigeNode node, int souls) {
    if (_unlocked.contains(node.id)) return false;
    if (souls < node.soulCost) return false;
    if (paragonPointsSpent < node.paragonGate) return false;
    if (node.prerequisiteId != null && !_unlocked.contains(node.prerequisiteId!)) {
      return false;
    }
    return true;
  }

  void forceUnlock(String id) => _unlocked.add(id);

  Map<String, bool> get ownedNodes => {for (final id in _unlocked) id: true};

  void restoreOwned(Map<String, bool> saved) {
    _unlocked.clear();
    _unlocked.addAll(saved.keys);
  }

  void reset() {
    _unlocked.clear();
    _paragonRanks.clear();
  }

  Map<String, dynamic> toJson() => {
        'unlocked': _unlocked.toList(),
        'paragonRanks': Map<String, int>.from(_paragonRanks),
      };

  void loadFromJson(Map<String, dynamic> json) {
    _unlocked.clear();
    if (json['unlocked'] != null) {
      _unlocked.addAll((json['unlocked'] as List<dynamic>).cast<String>());
    }
    _paragonRanks.clear();
    if (json['paragonRanks'] != null) {
      (json['paragonRanks'] as Map<String, dynamic>).forEach((k, v) {
        _paragonRanks[k] = v as int;
      });
    }
  }
}
