class ChallengeModifier {
  const ChallengeModifier({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.enemyHpMult,
    required this.enemyAtkMult,
    required this.heroHpMult,
    required this.rewardShardBonus,
  });

  final String id;
  final String name;
  final String description;
  final String icon;

  // Applied multiplicatively to enemy/hero stats
  final double enemyHpMult;
  final double enemyAtkMult;
  final double heroHpMult;

  // Flat shard bonus per kill (stacks additively)
  final int rewardShardBonus;

  static const all = [
    ChallengeModifier(
      id: 'veteran_enemies',
      name: 'Veteran Enemies',
      description: 'Enemies have +25% HP.',
      icon: '💀',
      enemyHpMult: 1.25,
      enemyAtkMult: 1.0,
      heroHpMult: 1.0,
      rewardShardBonus: 2,
    ),
    ChallengeModifier(
      id: 'berserker_enemies',
      name: 'Berserker Enemies',
      description: 'Enemies deal +30% damage.',
      icon: '⚔️',
      enemyHpMult: 1.0,
      enemyAtkMult: 1.3,
      heroHpMult: 1.0,
      rewardShardBonus: 3,
    ),
    ChallengeModifier(
      id: 'glass_hero',
      name: 'Glass Hero',
      description: 'Your hero\'s max HP is halved.',
      icon: '🩸',
      enemyHpMult: 1.0,
      enemyAtkMult: 1.0,
      heroHpMult: 0.5,
      rewardShardBonus: 4,
    ),
    ChallengeModifier(
      id: 'ironclad',
      name: 'Ironclad',
      description: 'Enemies have +25% HP and +20% damage. More shards.',
      icon: '🛡',
      enemyHpMult: 1.25,
      enemyAtkMult: 1.2,
      heroHpMult: 1.0,
      rewardShardBonus: 5,
    ),
    ChallengeModifier(
      id: 'nightmare',
      name: 'Nightmare',
      description: 'All enemy stats +40%. Your HP halved. Max shards.',
      icon: '💀',
      enemyHpMult: 1.4,
      enemyAtkMult: 1.4,
      heroHpMult: 0.5,
      rewardShardBonus: 8,
    ),
  ];
}
