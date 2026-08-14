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
      description: '+25% XP per level  (max +125%)',
      maxLevel: 5,
      costPerLevel: 1,
      icon: '✦',
    ),
    AscensionNode(
      id: 'gold_gain',
      label: 'Gilded Path',
      description: '+25% gold per level  (max +125%)',
      maxLevel: 5,
      costPerLevel: 1,
      icon: '⚜',
    ),
    AscensionNode(
      id: 'shard_gain',
      label: 'Crystal Veins',
      description: '+25% shard drops per level  (max +125%)',
      maxLevel: 5,
      costPerLevel: 1,
      icon: '◆',
    ),
    AscensionNode(
      id: 'atk_bonus',
      label: 'Veteran Arms',
      description: '+5% critical hit chance per level  (max +25%)',
      maxLevel: 5,
      costPerLevel: 2,
      icon: '⚔',
    ),
    AscensionNode(
      id: 'dmg_bonus',
      label: 'Titan Strength',
      description: '+12% ALL damage per level — scales forever  (max +60%)',
      maxLevel: 5,
      costPerLevel: 2,
      icon: '💪',
    ),
    AscensionNode(
      id: 'idle_bonus',
      label: 'Ancient Flow',
      description: '+30% idle income per level  (max +150%)',
      maxLevel: 5,
      costPerLevel: 1,
      icon: '⏳',
    ),
    AscensionNode(
      id: 'prestige_bonus',
      label: 'Legacy Power',
      description: '+30% to ALL Rebirth bonuses per level  (max +90%)',
      maxLevel: 3,
      costPerLevel: 3,
      icon: '👑',
    ),
    AscensionNode(
      id: 'essence_bonus',
      label: 'Soul Harvest',
      description: '+30% essence per level  (max +150%)',
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
