class AscensionNode {
  const AscensionNode({
    required this.id,
    required this.label,
    required this.description,
    required this.maxLevel,
    required this.costPerLevel,
    required this.icon,
  });
  final String id;
  final String label;
  final String description;
  final int maxLevel;
  final int costPerLevel;
  final String icon;

  static const all = [
    AscensionNode(
      id: 'xp_gain',
      label: 'Eternal Wisdom',
      description: '+10% XP per level',
      maxLevel: 5,
      costPerLevel: 1,
      icon: '✦',
    ),
    AscensionNode(
      id: 'gold_gain',
      label: 'Gilded Path',
      description: '+10% gold per level',
      maxLevel: 5,
      costPerLevel: 1,
      icon: '⚜',
    ),
    AscensionNode(
      id: 'shard_gain',
      label: 'Crystal Veins',
      description: '+10% shard drops per level',
      maxLevel: 5,
      costPerLevel: 1,
      icon: '◆',
    ),
    AscensionNode(
      id: 'atk_bonus',
      label: 'Veteran Arms',
      description: '+1 attack roll per level',
      maxLevel: 3,
      costPerLevel: 2,
      icon: '⚔',
    ),
    AscensionNode(
      id: 'dmg_bonus',
      label: 'Titan Strength',
      description: '+2 flat damage per level',
      maxLevel: 3,
      costPerLevel: 2,
      icon: '💪',
    ),
    AscensionNode(
      id: 'idle_bonus',
      label: 'Ancient Flow',
      description: '+15% idle gold per level',
      maxLevel: 5,
      costPerLevel: 1,
      icon: '⏳',
    ),
    AscensionNode(
      id: 'prestige_bonus',
      label: 'Legacy Power',
      description: '+10% to all prestige bonuses per level',
      maxLevel: 3,
      costPerLevel: 3,
      icon: '👑',
    ),
    AscensionNode(
      id: 'essence_bonus',
      label: 'Soul Harvest',
      description: '+15% essence per level',
      maxLevel: 5,
      costPerLevel: 1,
      icon: '🔮',
    ),
  ];

  static AscensionNode? byId(String id) {
    try {
      return all.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }
}
