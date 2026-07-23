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
  });

  final String id;
  final String name;
  final String description;
  final int soulCost;
  final PrestigeCategory category;
  final String? prerequisiteId;
}

const kPrestigeNodes = <PrestigeNode>[
  // ── COMBAT ──────────────────────────────────────────────────────────────────
  PrestigeNode(
    id: 'iron_resolve',
    name: 'Iron Resolve',
    description: '+30% maximum HP. Survive longer every run.',
    soulCost: 3,
    category: PrestigeCategory.combat,
  ),
  PrestigeNode(
    id: 'blood_drinker',
    name: 'Blood Drinker',
    description: 'Restore 5% max HP on every kill.',
    soulCost: 5,
    category: PrestigeCategory.combat,
    prerequisiteId: 'iron_resolve',
  ),
  PrestigeNode(
    id: 'killing_blow',
    name: 'Killing Blow',
    description: '+8% critical hit chance on all attacks.',
    soulCost: 4,
    category: PrestigeCategory.combat,
  ),
  PrestigeNode(
    id: 'deaths_edge',
    name: "Death's Edge",
    description: 'Critical hits deal +80% bonus damage.',
    soulCost: 8,
    category: PrestigeCategory.combat,
    prerequisiteId: 'killing_blow',
  ),
  PrestigeNode(
    id: 'destroyer',
    name: 'Destroyer',
    description: '+20% damage on all attacks permanently.',
    soulCost: 10,
    category: PrestigeCategory.combat,
    prerequisiteId: 'deaths_edge',
  ),
  // ── ECONOMY ─────────────────────────────────────────────────────────────────
  PrestigeNode(
    id: 'start_gold',
    name: 'Blood Tithe',
    description: '+20% gold income from all sources in every run.',
    soulCost: 3,
    category: PrestigeCategory.economy,
  ),
  PrestigeNode(
    id: 'war_spoils',
    name: 'War Spoils',
    description: '+35% more gold income (stacks with Blood Tithe for +55% total).',
    soulCost: 5,
    category: PrestigeCategory.economy,
    prerequisiteId: 'start_gold',
  ),
  PrestigeNode(
    id: 'carrion_picker',
    name: 'Carrion Picker',
    description: '+50% shard drops from all kills.',
    soulCost: 3,
    category: PrestigeCategory.economy,
  ),
  PrestigeNode(
    id: 'essence_bonus',
    name: 'Soul Harvest',
    description: '+50% essence from all kills.',
    soulCost: 3,
    category: PrestigeCategory.economy,
  ),
  PrestigeNode(
    id: 'treasure_sense',
    name: 'Treasure Sense',
    description: '+35% gold earned from all battles.',
    soulCost: 4,
    category: PrestigeCategory.economy,
  ),
  PrestigeNode(
    id: 'mythril_memory',
    name: 'Mythril Memory',
    description: 'Keep 50% of your Mythril after each Rebirth.',
    soulCost: 5,
    category: PrestigeCategory.economy,
    prerequisiteId: 'treasure_sense',
  ),
  // ── PROGRESSION ─────────────────────────────────────────────────────────────
  PrestigeNode(
    id: 'swift_learner',
    name: 'Swift Learner',
    description: '+30% XP from all sources.',
    soulCost: 3,
    category: PrestigeCategory.progression,
  ),
  PrestigeNode(
    id: 'head_start',
    name: "Veteran's Path",
    description: 'After rebirth, campaign begins at Stage 11.',
    soulCost: 3,
    category: PrestigeCategory.progression,
  ),
  PrestigeNode(
    id: 'head_start_2',
    name: 'Battle-Hardened',
    description: 'After rebirth, campaign begins at Stage 21.',
    soulCost: 6,
    category: PrestigeCategory.progression,
    prerequisiteId: 'head_start',
  ),
  PrestigeNode(
    id: 'ability_disc',
    name: 'Arcane Economy',
    description: 'Ability upgrades cost 35% fewer shards.',
    soulCost: 3,
    category: PrestigeCategory.progression,
  ),
  PrestigeNode(
    id: 'instant_recall',
    name: 'Instant Recall',
    description: 'Begin each run with 1,500 gold (stacks with other bonuses).',
    soulCost: 4,
    category: PrestigeCategory.progression,
    prerequisiteId: 'head_start',
  ),
  // ── MASTERY ─────────────────────────────────────────────────────────────────
  PrestigeNode(
    id: 'idle_bonus',
    name: 'Eternal Flame',
    description: '+30 idle income rate permanently.',
    soulCost: 3,
    category: PrestigeCategory.mastery,
  ),
  PrestigeNode(
    id: 'forge_bonus',
    name: 'Master Forger',
    description: 'Forge common→rare requires only 2 items instead of 3.',
    soulCost: 3,
    category: PrestigeCategory.mastery,
  ),
  PrestigeNode(
    id: 'soul_conduit',
    name: 'Soul Conduit',
    description: 'Earn +5 extra Paragon Points with every Rebirth.',
    soulCost: 6,
    category: PrestigeCategory.mastery,
  ),
  PrestigeNode(
    id: 'artifact_vault',
    name: 'Artifact Vault',
    description: 'Artifacts and their upgrades survive each Rebirth.',
    soulCost: 8,
    category: PrestigeCategory.mastery,
    prerequisiteId: 'forge_bonus',
  ),
  PrestigeNode(
    id: 'soul_overdrive',
    name: 'Soul Overdrive',
    description: 'After Rebirth, campaign begins at Stage 41.',
    soulCost: 7,
    category: PrestigeCategory.progression,
    prerequisiteId: 'head_start_2',
  ),
  PrestigeNode(
    id: 'paragon_dominance',
    name: 'Paragon Dominance',
    description: 'Each Rebirth level grants +1% to all stats permanently (stacks with level scaling).',
    soulCost: 15,
    category: PrestigeCategory.mastery,
    prerequisiteId: 'soul_conduit',
  ),
];

class PrestigeShop {
  PrestigeShop();

  final Set<String> _unlocked = {};

  bool isUnlocked(String id) => _unlocked.contains(id);

  bool canUnlock(PrestigeNode node, int souls) {
    if (_unlocked.contains(node.id)) return false;
    if (souls < node.soulCost) return false;
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

  void reset() => _unlocked.clear();

  Map<String, dynamic> toJson() => {'unlocked': _unlocked.toList()};

  void loadFromJson(Map<String, dynamic> json) {
    _unlocked.clear();
    if (json['unlocked'] != null) {
      _unlocked.addAll((json['unlocked'] as List<dynamic>).cast<String>());
    }
  }
}
