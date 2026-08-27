import 'package:flutter/material.dart';
import '../models/damage_type.dart';
import '../models/passive_tree.dart';
import 'element_icon.dart';
import 'stat_icon.dart';

// Element colours (match the game's damage-type palette).
const _fire      = Color(0xFFff6633);
const _cold      = Color(0xFF44bbff);
const _lightning = Color(0xFFffcc00);
const _poison    = Color(0xFF66cc44);
const _void      = Color(0xFFaa55ff);

/// Colour used to tint a passive node's icon, by effect.
Color passiveEffectColor(PassiveEffect e) => switch (e) {
  PassiveEffect.attackFlat     => const Color(0xFFff8844),
  PassiveEffect.damageFlat     => const Color(0xFFff6644),
  PassiveEffect.allDamage      => const Color(0xFFff5555),
  PassiveEffect.critChance     => const Color(0xFFffee44),
  PassiveEffect.pierce         => const Color(0xFFffaa44),
  PassiveEffect.allPenetration => const Color(0xFFffbb55),
  PassiveEffect.maxHp          => const Color(0xFFff6666),
  PassiveEffect.regenFlat      => const Color(0xFF44cc88),
  PassiveEffect.healBoost      => const Color(0xFF55dd99),
  PassiveEffect.armorFlat      => const Color(0xFF66aaff),
  PassiveEffect.dodgeChance    => const Color(0xFF88ffcc),
  PassiveEffect.goldFlat       => const Color(0xFFe8a832),
  PassiveEffect.shardFlat      => const Color(0xFF80d0ff),
  PassiveEffect.essenceGain    => const Color(0xFF66ccee),
  PassiveEffect.xpFlat         => const Color(0xFF88ddff),
  PassiveEffect.idleFlat       => const Color(0xFFaa99dd),
  PassiveEffect.cooldownReduce => const Color(0xFFbbaaee),
  PassiveEffect.abilityDamage  => const Color(0xFFcc88ff),
  PassiveEffect.fireDamage     || PassiveEffect.fireRes      => _fire,
  PassiveEffect.coldDamage     || PassiveEffect.coldRes      => _cold,
  PassiveEffect.lightningDamage|| PassiveEffect.lightningRes => _lightning,
  PassiveEffect.poisonDamage   || PassiveEffect.poisonRes    => _poison,
  PassiveEffect.voidDamage     || PassiveEffect.voidRes      => _void,
  PassiveEffect.allRes         => const Color(0xFF88ccff),
};

/// Icon for a passive-tree node. Stat/economy effects reuse [StatIcon];
/// elemental damage and idle/cooldown effects use dedicated glyphs. Elemental
/// resistances render as a shield tinted to the element.
class PassiveIcon extends StatelessWidget {
  const PassiveIcon({super.key, required this.effect, this.size = 22});
  final PassiveEffect effect;
  final double size;

  @override
  Widget build(BuildContext context) {
    final col = passiveEffectColor(effect);
    final stat = _statType(effect);
    if (stat != null) return StatIcon(type: stat, color: col, size: size);
    final elem = _elementType(effect);
    if (elem != null) return ElementIcon(type: elem, size: size, color: col);
    // Remaining: idle rate / cooldown reduction → a clock.
    return SizedBox(
      width: size, height: size,
      child: CustomPaint(painter: _ClockPainter(col)),
    );
  }

  static DamageType? _elementType(PassiveEffect e) => switch (e) {
    PassiveEffect.fireDamage      => DamageType.fire,
    PassiveEffect.coldDamage      => DamageType.cold,
    PassiveEffect.lightningDamage => DamageType.lightning,
    PassiveEffect.poisonDamage    => DamageType.poison,
    PassiveEffect.voidDamage      => DamageType.void_,
    _ => null,
  };

  static StatIconType? _statType(PassiveEffect e) => switch (e) {
    PassiveEffect.attackFlat     => StatIconType.critDamage,
    PassiveEffect.damageFlat     => StatIconType.damage,
    PassiveEffect.allDamage      => StatIconType.damage,
    PassiveEffect.critChance     => StatIconType.crit,
    PassiveEffect.pierce         => StatIconType.pierce,
    PassiveEffect.allPenetration => StatIconType.pierce,
    PassiveEffect.maxHp          => StatIconType.hp,
    PassiveEffect.regenFlat      => StatIconType.hpRegen,
    PassiveEffect.healBoost      => StatIconType.hpRegen,
    PassiveEffect.armorFlat      => StatIconType.armor,
    PassiveEffect.dodgeChance    => StatIconType.dodge,
    PassiveEffect.goldFlat       => StatIconType.gold,
    PassiveEffect.shardFlat      => StatIconType.shards,
    PassiveEffect.essenceGain    => StatIconType.shards,
    PassiveEffect.xpFlat         => StatIconType.xp,
    PassiveEffect.abilityDamage  => StatIconType.critDamage,
    // Elemental resistances → shield tinted to the element.
    PassiveEffect.fireRes || PassiveEffect.coldRes || PassiveEffect.lightningRes ||
    PassiveEffect.poisonRes || PassiveEffect.voidRes || PassiveEffect.allRes
        => StatIconType.armor,
    _ => null, // elemental damage + idle/cooldown → custom painter below
  };
}

/// Clock glyph for idle-rate / cooldown-reduction passive nodes.
class _ClockPainter extends CustomPainter {
  const _ClockPainter(this.color);
  final Color color;

  @override
  void paint(Canvas cv, Size s) {
    final cx = s.width / 2, cy = s.height / 2;
    final ring = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    cv.drawCircle(Offset(cx, cy), s.width * 0.28, ring);
    cv.drawCircle(Offset(cx, cy), s.width * 0.04, Paint()..color = color..isAntiAlias = true);
    cv.drawLine(Offset(cx, cy), Offset(cx, cy - s.height * 0.18), ring);
    cv.drawLine(Offset(cx, cy), Offset(cx + s.width * 0.14, cy + s.height * 0.04), ring);
  }

  @override
  bool shouldRepaint(covariant _ClockPainter old) => old.color != color;
}
