class ChallengeModifier {
  const ChallengeModifier({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.enemyHpMult,
    required this.enemyAtkMult,
    required this.heroHpMult,
    required this.rewardPctBonus,
  });

  final String id;
  final String name;
  final String description;
  final String icon;

  // Applied multiplicatively to enemy/hero stats
  final double enemyHpMult;
  final double enemyAtkMult;
  final double heroHpMult;

  // % increase to essence earned (stacks additively). The flat soul income comes
  // from the Gauntlet tier; modifiers scale it up by this percentage.
  final int rewardPctBonus;

  static const all = [
    ChallengeModifier(
      id: 'veteran_enemies',
      name: 'Veteran Enemies',
      description: 'Enemies have +25% HP.',
      icon: '💀',
      enemyHpMult: 1.25,
      enemyAtkMult: 1.0,
      heroHpMult: 1.0,
      rewardPctBonus: 15,
    ),
    ChallengeModifier(
      id: 'berserker_enemies',
      name: 'Berserker Enemies',
      description: 'Enemies deal +30% damage.',
      icon: '⚔️',
      enemyHpMult: 1.0,
      enemyAtkMult: 1.3,
      heroHpMult: 1.0,
      rewardPctBonus: 20,
    ),
    ChallengeModifier(
      id: 'glass_hero',
      name: 'Glass Hero',
      description: 'Your hero\'s max HP is halved.',
      icon: '🩸',
      enemyHpMult: 1.0,
      enemyAtkMult: 1.0,
      heroHpMult: 0.5,
      rewardPctBonus: 25,
    ),
    ChallengeModifier(
      id: 'ironclad',
      name: 'Ironclad',
      description: 'Enemies have +25% HP and +20% damage. +30% essence.',
      icon: '🛡',
      enemyHpMult: 1.25,
      enemyAtkMult: 1.2,
      heroHpMult: 1.0,
      rewardPctBonus: 30,
    ),
    ChallengeModifier(
      id: 'nightmare',
      name: 'Nightmare',
      description: 'All enemy stats +40%. Your HP halved. +50% essence.',
      icon: '💀',
      enemyHpMult: 1.4,
      enemyAtkMult: 1.4,
      heroHpMult: 0.5,
      rewardPctBonus: 50,
    ),
  ];
}
