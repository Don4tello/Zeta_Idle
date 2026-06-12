import 'dart:math';
import '../models/damage_type.dart';
import 'damage_context.dart';

// ── Tag matching ──────────────────────────────────────────────────────────────

bool _tagsMatch(List<SkillTag> required, List<SkillTag> skillTags) =>
    required.every(skillTags.contains);

// ── Stage 1: Base + Added ─────────────────────────────────────────────────────

DmgMap _resolveBaseAndAdded(DamageContext ctx) {
  final totals = <DamageType, double>{};

  void add(List<DamageComponent> cs) {
    for (final c in cs) totals[c.type] = (totals[c.type] ?? 0) + c.amount;
  }

  add(ctx.skill.baseDamage);
  for (final a in ctx.added) {
    if (a.condition == null || a.condition!(ctx)) add(a.components);
  }
  return totals;
}

// ── Stage 2: Increased (additive bucket) ─────────────────────────────────────

DmgMap _applyIncreased(DmgMap dmg, DamageContext ctx) {
  final total = ctx.increased
      .where((m) => _tagsMatch(m.requiredTags, ctx.skill.tags))
      .where((m) => m.condition == null || m.condition!(ctx))
      .fold(0.0, (sum, m) => sum + m.value);
  return dmg.map((t, v) => MapEntry(t, v * (1 + total)));
}

// ── Stage 3: More (separate multiplicative buckets) ──────────────────────────

DmgMap _applyMore(DmgMap dmg, DamageContext ctx) {
  final product = ctx.more
      .where((m) => _tagsMatch(m.requiredTags, ctx.skill.tags))
      .where((m) => m.condition == null || m.condition!(ctx))
      .fold(1.0, (p, m) => p * m.value);
  return dmg.map((t, v) => MapEntry(t, v * product));
}

// ── Stage 4: Crit ─────────────────────────────────────────────────────────────

bool rollCrit(CritStats crit, Random rng) {
  if (!crit.canCrit) return false;
  return rng.nextDouble() < crit.chance;
}

DmgMap _applyCrit(DmgMap dmg, CritStats crit, bool wasCrit) {
  if (!wasCrit) return dmg;
  return dmg.map((t, v) => MapEntry(t, v * crit.multiplier));
}

// ── Stage 5: Resistance / penetration ────────────────────────────────────────

double _clampRes(double v) => v.clamp(-1.0, 0.75);

DmgMap _applyResistance(DmgMap dmg, EnemyProfile enemy) {
  return dmg.map((type, amount) {
    final res = enemy.resistances[type] ?? 0.0;
    final pen = enemy.penetration[type] ?? 0.0;
    return MapEntry(type, amount * (1 - _clampRes(res - pen)));
  });
}

// ── Public entry point ────────────────────────────────────────────────────────

DamageResult calculateDamage(DamageContext ctx, {Random? rng, bool? forceCrit}) {
  final rand    = rng ?? Random();
  var   dmg     = _resolveBaseAndAdded(ctx);
  dmg           = _applyIncreased(dmg, ctx);
  dmg           = _applyMore(dmg, ctx);

  final wasCrit = ctx.skill.isDot
      ? false
      : (forceCrit ?? rollCrit(ctx.skill.crit, rand));

  dmg           = _applyCrit(dmg, ctx.skill.crit, wasCrit);
  dmg           = _applyResistance(dmg, ctx.enemy);

  final total   = dmg.values.fold(0.0, (s, v) => s + v);
  return DamageResult(byType: dmg, total: total, wasCrit: wasCrit);
}

// ── Expected damage (for tooltips / planning) ─────────────────────────────────

double expectedDamage(DamageContext ctx) {
  final base = calculateDamage(ctx, forceCrit: false).total;
  final crit = ctx.skill.crit;
  if (!crit.canCrit) return base;
  return base * (1 + crit.chance * (crit.multiplier - 1));
}
