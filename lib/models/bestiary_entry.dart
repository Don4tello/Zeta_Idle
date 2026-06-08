enum BestiaryWeakness {
  undead,    // +10% ATK vs Undead
  beast,     // +10% ATK vs Beasts
  arcane,    // +10% ability damage vs Arcane
  demonic,   // +10% ATK vs Demonic
  construct, // +10% ATK vs Constructs
}

extension BestiaryWeaknessExt on BestiaryWeakness {
  String get displayName => switch (this) {
    BestiaryWeakness.undead    => 'Undead',
    BestiaryWeakness.beast     => 'Beast',
    BestiaryWeakness.arcane    => 'Arcane',
    BestiaryWeakness.demonic   => 'Demonic',
    BestiaryWeakness.construct => 'Construct',
  };
  String get tagColor => switch (this) {
    BestiaryWeakness.undead    => '#8888ff',
    BestiaryWeakness.beast     => '#88cc44',
    BestiaryWeakness.arcane    => '#cc44ff',
    BestiaryWeakness.demonic   => '#ff4444',
    BestiaryWeakness.construct => '#ff9922',
  };
}

class BestiaryEntry {
  const BestiaryEntry({
    required this.enemyId,
    required this.name,
    required this.flavorText,
    required this.weakness,
    required this.category,
  });

  final String enemyId;
  final String name;
  final String flavorText;
  final BestiaryWeakness weakness;
  final String category; // used to group in the UI
}
