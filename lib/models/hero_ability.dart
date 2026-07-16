import 'damage_type.dart';

enum AbilityCategory { damage, buff, debuff, ultimate }

enum AbilityEffect {
  bonusDamage, heal, attackBonus, acBonus, stun, dot, dodge,
  aura,             // hero heals X HP/round for duration rounds
  debuffWeaken,     // enemy ATK reduced by X% for duration rounds
  debuffVulnerable, // enemy takes X% more damage for duration rounds
  silence,          // enemy cannot use abilities for duration rounds
  absorbShield,     // hero gains a barrier that absorbs X flat damage
  missChance,       // enemy has X% chance to miss per round for duration rounds
}

// ── Milestone choice (replaces AbilityBranch) ─────────────────────────────────

class AbilityChoice {
  const AbilityChoice({
    required this.id,
    required this.name,
    required this.description,
    this.overrideDamageType,
    this.effectOverride,
    this.valueDelta = 0,
    this.durationDelta = 0,
    this.bonusEffect,
    this.bonusValue = 0,
    this.bonusDuration = 0,
  });
  final String id;                   // 'a' or 'b'
  final String name;
  final String description;
  final DamageType? overrideDamageType; // changes ability's elemental type
  final AbilityEffect? effectOverride;  // swaps primary effect (e.g. aura → dot)
  final int valueDelta;
  final int durationDelta;
  final AbilityEffect? bonusEffect;
  final int bonusValue;
  final int bonusDuration;
}

class AbilityMilestone {
  const AbilityMilestone({required this.rank, required this.a, required this.b});
  final int rank; // 5, 10, or 15
  final AbilityChoice a;
  final AbilityChoice b;
}

// ── HeroAbility ───────────────────────────────────────────────────────────────

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
    this.penetration = 0,
    this.category = AbilityCategory.damage,
    this.milestones = const [],
    this.baseBonus,
    this.baseBonusValue = 0,
    this.baseBonusDuration = 0,
  });

  final String id;
  final String name;
  final String description;
  final int cooldownRounds;
  final int levelRequired;
  final AbilityEffect effect;
  final int value;
  final int duration;
  final int penetration;
  final AbilityCategory category;
  final List<AbilityMilestone> milestones;
  // Fires alongside the primary effect on every cast (not gated behind milestones)
  final AbilityEffect? baseBonus;
  final int baseBonusValue;
  final int baseBonusDuration;
}
