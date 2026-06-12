import '../models/damage_type.dart';

// ── Skill tags ────────────────────────────────────────────────────────────────

enum SkillTag {
  physical, fire, cold, lightning, poison, voidDmg,
  spell, melee, ranged, area, dot, projectile,
  ability, weapon,
}

// ── Primitives ────────────────────────────────────────────────────────────────

typedef DmgMap = Map<DamageType, double>;

class DamageComponent {
  const DamageComponent(this.type, this.amount);
  final DamageType type;
  final double     amount;
}

// ── Modifier types ────────────────────────────────────────────────────────────

class AddedDamage {
  const AddedDamage(this.components, {this.condition});
  final List<DamageComponent>          components;
  final bool Function(DamageContext)?  condition;
}

class IncreasedModifier {
  const IncreasedModifier(this.value, this.requiredTags, {this.condition});
  final double                         value;        // e.g. 0.20 = 20%
  final List<SkillTag>                 requiredTags;
  final bool Function(DamageContext)?  condition;
}

class MoreModifier {
  const MoreModifier(this.value, this.requiredTags, {this.condition});
  final double                         value;        // e.g. 1.30 = ×1.30
  final List<SkillTag>                 requiredTags;
  final bool Function(DamageContext)?  condition;
}

// ── Crit stats ────────────────────────────────────────────────────────────────

class CritStats {
  const CritStats({required this.chance, required this.multiplier, this.canCrit = true});
  final double chance;
  final double multiplier;
  final bool   canCrit;
}

// ── Enemy profile ─────────────────────────────────────────────────────────────

class EnemyProfile {
  const EnemyProfile({required this.resistances, this.penetration = const {}});
  final Map<DamageType, double> resistances;
  final Map<DamageType, double> penetration;
}

// ── Skill profile ─────────────────────────────────────────────────────────────

class SkillProfile {
  const SkillProfile({
    required this.id,
    required this.tags,
    required this.baseDamage,
    required this.crit,
    this.isDot = false,
  });
  final String               id;
  final List<SkillTag>       tags;
  final List<DamageComponent> baseDamage;
  final CritStats             crit;
  final bool                  isDot;
}

// ── Full context (assembled per hit/tick) ─────────────────────────────────────

class DamageContext {
  const DamageContext({
    required this.skill,
    required this.added,
    required this.increased,
    required this.more,
    required this.enemy,
  });
  final SkillProfile          skill;
  final List<AddedDamage>     added;
  final List<IncreasedModifier> increased;
  final List<MoreModifier>    more;
  final EnemyProfile          enemy;
}

// ── Result ────────────────────────────────────────────────────────────────────

class DamageResult {
  const DamageResult({required this.byType, required this.total, required this.wasCrit});
  final Map<DamageType, double> byType;
  final double                  total;
  final bool                    wasCrit;
}
