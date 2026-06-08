enum AbilityEffect { bonusDamage, heal, attackBonus, acBonus, stun, dot, dodge }

class AbilityBranch {
  const AbilityBranch({
    required this.id,
    required this.name,
    required this.description,
    this.valueDelta = 0,
    this.durationDelta = 0,
    this.secondaryEffect,
    this.secondaryValue = 0,
    this.secondaryDuration = 0,
  });
  final String id;            // 'a' or 'b'
  final String name;
  final String description;
  final int valueDelta;       // added on top of scaledAbilityValue
  final int durationDelta;    // added to ability.duration
  final AbilityEffect? secondaryEffect;
  final int secondaryValue;
  final int secondaryDuration;
}

class HeroAbility {
  const HeroAbility({
    required this.id,
    required this.name,
    required this.description,
    required this.cooldownRounds,
    required this.levelRequired,
    required this.effect,
    required this.value,
    this.duration = 0,
    this.branchA,
    this.branchB,
  });

  final String id;
  final String name;
  final String description;
  final int cooldownRounds;
  final int levelRequired;
  final AbilityEffect effect;
  final int value;
  final int duration;
  final AbilityBranch? branchA;
  final AbilityBranch? branchB;
}
