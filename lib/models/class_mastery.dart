import 'dnd_class.dart';

enum MasteryCategory { autoAttack, autoBuff }

enum MasteryEffect {
  flatDamagePerHit,   // +N flat damage on every auto-attack
  piercePerHit,       // ignore N enemy AC on every attack roll
  lifestealPct,       // heal N% of damage dealt on each hit
  multiStrikePct,     // N% chance to strike again after a hit
  permanentAttack,    // permanent +N to all attack rolls
  permanentDamage,    // permanent +N to all damage rolls
  permanentAC,        // permanent +N to hero AC
  permanentGoldPct,   // permanent +N% gold from kills
  permanentXpPct,     // permanent +N% XP from kills
}

class ClassMastery {
  const ClassMastery({
    required this.id,
    required this.name,
    required this.description,
    required this.classRequired,
    required this.category,
    required this.effect,
    required this.levelRequired,
    required this.baseValue,
    required this.valuePerLevel,
    this.maxLevel = 5,
  });

  final String id;
  final String name;
  final String description;
  final DndClass classRequired;
  final MasteryCategory category;
  final MasteryEffect effect;
  final int levelRequired;   // hero level needed to unlock (free)
  final int baseValue;       // value at mastery level 1
  final int valuePerLevel;   // added per upgrade beyond level 1
  final int maxLevel;

  static int upgradeCostAt(int currentLevel) => switch (currentLevel) {
    1 => 300,
    2 => 800,
    3 => 2000,
    _ => 5000,
  };

  int valueAtLevel(int masteryLevel) {
    if (masteryLevel <= 0) return 0;
    return baseValue + (masteryLevel - 1) * valuePerLevel;
  }

  String effectLabel(int masteryLevel) {
    final v = valueAtLevel(masteryLevel.clamp(1, maxLevel));
    return switch (effect) {
      MasteryEffect.flatDamagePerHit  => '+$v flat damage per hit',
      MasteryEffect.piercePerHit      => 'ignore $v enemy AC',
      MasteryEffect.lifestealPct      => 'heal $v% of damage dealt',
      MasteryEffect.multiStrikePct    => '$v% chance to strike again',
      MasteryEffect.permanentAttack   => '+$v to attack rolls',
      MasteryEffect.permanentDamage   => '+$v to damage',
      MasteryEffect.permanentAC       => '+$v AC',
      MasteryEffect.permanentGoldPct  => '+$v% gold',
      MasteryEffect.permanentXpPct    => '+$v% XP',
    };
  }
}
