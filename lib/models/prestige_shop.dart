class PrestigeNode {
  const PrestigeNode({
    required this.id,
    required this.name,
    required this.description,
    required this.soulCost,
    this.prerequisiteId,
  });

  final String id;
  final String name;
  final String description;
  final int soulCost;
  final String? prerequisiteId;
}

const kPrestigeNodes = <PrestigeNode>[
  PrestigeNode(
    id: 'start_gold',
    name: 'Blood Tithe',
    soulCost: 2,
    description: 'Begin each run with +500 gold.',
  ),
  PrestigeNode(
    id: 'start_gold_2',
    name: 'War Spoils',
    soulCost: 5,
    prerequisiteId: 'start_gold',
    description: 'Begin each run with +1500 more gold (stacks with Blood Tithe).',
  ),
  PrestigeNode(
    id: 'head_start',
    name: "Veteran's Path",
    soulCost: 3,
    description: 'After rebirth, campaign begins at Stage 6.',
  ),
  PrestigeNode(
    id: 'head_start_2',
    name: 'Battle-Hardened',
    soulCost: 7,
    prerequisiteId: 'head_start',
    description: "After rebirth, campaign begins at Stage 11 (replaces Veteran's Path).",
  ),
  PrestigeNode(
    id: 'idle_bonus',
    name: 'Eternal Flame',
    soulCost: 3,
    description: '+5 to idle rate permanently.',
  ),
  PrestigeNode(
    id: 'shard_bonus',
    name: 'Carrion Picker',
    soulCost: 4,
    description: '+30% shard drops from all kills.',
  ),
  PrestigeNode(
    id: 'essence_bonus',
    name: 'Soul Harvest',
    soulCost: 5,
    description: '+30% essence from all kills.',
  ),
  PrestigeNode(
    id: 'ability_disc',
    name: 'Arcane Economy',
    soulCost: 4,
    description: 'Ability upgrades cost 25% fewer shards.',
  ),
  PrestigeNode(
    id: 'forge_bonus',
    name: 'Master Forger',
    soulCost: 4,
    description: 'Forge common→rare requires only 2 items instead of 3.',
  ),
];

class PrestigeShop {
  PrestigeShop();

  final Set<String> _unlocked = {};

  bool isUnlocked(String id) => _unlocked.contains(id);

  bool canUnlock(PrestigeNode node, int souls) {
    if (_unlocked.contains(node.id)) return false;
    if (souls < node.soulCost) return false;
    if (node.prerequisiteId != null && !_unlocked.contains(node.prerequisiteId!)) return false;
    return true;
  }

  bool unlock(PrestigeNode node, int souls) {
    if (!canUnlock(node, souls)) return false;
    _unlocked.add(node.id);
    return true;
  }

  void forceUnlock(String id) => _unlocked.add(id);

  void reset() => _unlocked.clear();

  Map<String, dynamic> toJson() => {'unlocked': _unlocked.toList()};

  void loadFromJson(Map<String, dynamic> json) {
    _unlocked.clear();
    if (json['unlocked'] != null) {
      _unlocked.addAll((json['unlocked'] as List<dynamic>).cast<String>());
    }
  }
}
