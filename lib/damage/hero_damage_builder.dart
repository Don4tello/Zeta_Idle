import '../models/damage_type.dart';
import 'damage_context.dart';

// Maps DamageType → SkillTag so modifiers can filter by element
SkillTag damageTypeToTag(DamageType dt) => switch (dt) {
  DamageType.physical  => SkillTag.physical,
  DamageType.fire      => SkillTag.fire,
  DamageType.cold      => SkillTag.cold,
  DamageType.lightning => SkillTag.lightning,
  DamageType.poison    => SkillTag.poison,
  DamageType.void_     => SkillTag.voidDmg,
};

// Diminishing-returns soft cap: values ≤ [soft] pass through unchanged; above
// [soft] each extra point is worth progressively less, asymptoting to soft+k.
// Applied to the two runaway damage stacks (the additive "increased" bucket and
// the endless multiplier) so damage across EVERY class's skills/passives/upgrades
// stays reasonable instead of scaling to billions. Tunable.
double _softCapPct(double raw, double soft, double k) =>
    raw <= soft ? raw : soft + (raw - soft) * k / (k + (raw - soft));
double _softCapMore(double mult, double soft, double k) =>
    mult <= 1.0 ? mult : 1.0 + _softCapPct((mult - 1) * 100, soft, k) / 100;

// Tuning knobs for the global damage tame (see helpers above).
const double _kIncSoft = 800, _kIncK = 1600;   // additive damage% soft cap
const double _kMoreSoft = 300, _kMoreK = 600;   // endless multiplier soft cap
const double _kAbilSoft = 200, _kAbilK = 400;   // ability-damage / subclass bucket soft cap

// ── Weapon attack context ─────────────────────────────────────────────────────
//
// baseDmg is passed in already crit-adjusted (die×critMult + flat bonuses).
// Crit is therefore disabled in the pipeline to avoid double-applying.

DamageContext buildWeaponAttackContext({
  required int      baseDmg,
  required DamageType heroType,
  // Increased bucket
  required double   allDamagePct,
  // More buckets (each applied as a separate multiplier)
  required double   endlessDmgMult,
  required double   exploitMult,
  required double   subclassDmgMult,
  required int      comboStacks,
  required double   bestiaryWeakMult,
  required double   traitDmgMult,    // (100 + traitDmgPct) / 100
  required bool     isBerserk,
  // Resistance
  required Map<DamageType, int>    enemyResistances,
  required Map<DamageType, double> penetration,
}) {
  final tag = damageTypeToTag(heroType);

  return DamageContext(
    skill: SkillProfile(
      id: 'weapon_attack',
      tags: [SkillTag.weapon, tag],
      baseDamage: [DamageComponent(heroType, baseDmg.toDouble())],
      // Crit already baked into baseDmg at call site — do not re-apply
      crit: const CritStats(canCrit: false, chance: 0, multiplier: 1),
    ),
    added: const [],
    increased: [
      if (allDamagePct != 0)
        IncreasedModifier(_softCapPct(allDamagePct, _kIncSoft, _kIncK) / 100, const []),
    ],
    more: [
      if (endlessDmgMult != 1.0)  MoreModifier(_softCapMore(endlessDmgMult, _kMoreSoft, _kMoreK), const []),
      if (exploitMult    != 1.0)  MoreModifier(exploitMult,       const []),
      if (subclassDmgMult!= 1.0)  MoreModifier(_softCapMore(subclassDmgMult, _kMoreSoft, _kMoreK),  const []),
      if (traitDmgMult   != 1.0)  MoreModifier(traitDmgMult,     const []),
      if (comboStacks > 0)         MoreModifier(1.0 + comboStacks * 0.05, const []),
      if (bestiaryWeakMult > 1.0)  MoreModifier(bestiaryWeakMult, const []),
      if (isBerserk)               MoreModifier(1.25,             const []),
    ],
    enemy: EnemyProfile(
      resistances: enemyResistances.map((k, v) => MapEntry(k, v / 100.0)),
      penetration: penetration,
    ),
  );
}

// ── Ability attack context ────────────────────────────────────────────────────
//
// baseDmg here is the raw pre-scaled value (die roll + damageMod).
// The abilityDamage passive and subclass bonus are Increased modifiers;
// the same More modifiers as weapon attacks apply globally.

DamageContext buildAbilityAttackContext({
  required int      baseDmg,
  required DamageType heroType,
  // Increased bucket
  required double   allDamagePct,
  required double   abilityDamagePct,
  required double   subclassAbilityBonus,
  // More buckets
  required double   endlessDmgMult,
  required double   exploitMult,
  required int      comboStacks,
  required double   bestiaryWeakMult,
  required bool     isDot,
  // Resistance
  required Map<DamageType, int>    enemyResistances,
  required Map<DamageType, double> penetration,
}) {
  final tag = damageTypeToTag(heroType);

  return DamageContext(
    skill: SkillProfile(
      id: isDot ? 'ability_dot' : 'ability_hit',
      tags: [SkillTag.ability, tag, if (isDot) SkillTag.dot],
      baseDamage: [DamageComponent(heroType, baseDmg.toDouble())],
      crit: const CritStats(canCrit: false, chance: 0, multiplier: 1),
      isDot: isDot,
    ),
    added: const [],
    increased: [
      if (allDamagePct        != 0) IncreasedModifier(_softCapPct(allDamagePct, _kIncSoft, _kIncK) / 100, const []),
      if (abilityDamagePct    != 0) IncreasedModifier(_softCapPct(abilityDamagePct, _kAbilSoft, _kAbilK) / 100, [SkillTag.ability]),
      if (subclassAbilityBonus!= 0) IncreasedModifier(_softCapPct(subclassAbilityBonus * 100, _kAbilSoft, _kAbilK) / 100, [SkillTag.ability]),
    ],
    more: [
      if (endlessDmgMult   != 1.0) MoreModifier(_softCapMore(endlessDmgMult, _kMoreSoft, _kMoreK), const []),
      if (exploitMult      != 1.0) MoreModifier(exploitMult,             const []),
      if (comboStacks > 0)          MoreModifier(1.0 + comboStacks * 0.05, const []),
      if (bestiaryWeakMult > 1.0)   MoreModifier(bestiaryWeakMult,        const []),
    ],
    enemy: EnemyProfile(
      resistances: enemyResistances.map((k, v) => MapEntry(k, v / 100.0)),
      penetration: penetration,
    ),
  );
}
