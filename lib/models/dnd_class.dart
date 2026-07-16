import 'package:flutter/material.dart';
import 'damage_type.dart';

enum DndComplexity { low, average, high }

class DndClassInfo {
  const DndClassInfo({
    required this.displayName,
    required this.likes,
    required this.primaryAbility,
    required this.complexity,
    required this.flavor,
    required this.str,
    required this.dex,
    required this.con,
    required this.intelligence,
    required this.wis,
    required this.cha,
    required this.icon,
    required this.classElement,
    required this.secondaryElement,
  });

  final String displayName;
  final String likes;
  final String primaryAbility;
  final DndComplexity complexity;
  final String flavor;
  final int str;
  final int dex;
  final int con;
  final int intelligence;
  final int wis;
  final int cha;
  final IconData icon;
  // Two elemental damage types this class can unlock beyond Physical.
  // classElement unlocks automatically at hero level 5.
  // secondaryElement requires purchasing the Dual Mastery upgrade.
  final DamageType classElement;
  final DamageType secondaryElement;

  // The two stat abbreviations (STR/DEX/CON/INT/WIS/CHA) that most benefit
  // this class, derived from its damage-type pair.
  // Physical+X classes → STR + X's stat. Dual-element → each element's stat.
  Set<String> get keyStats {
    final ce = classElement;
    final se = secondaryElement;
    final pair = ce == se
        ? [DamageType.physical, ce]
        : [ce, se];
    return {pair[0].resistanceStat, pair[1].resistanceStat};
  }

  String get complexityLabel {
    switch (complexity) {
      case DndComplexity.low:     return 'Low';
      case DndComplexity.average: return 'Average';
      case DndComplexity.high:    return 'High';
    }
  }

  String get complexityDots {
    switch (complexity) {
      case DndComplexity.low:     return '●○○';
      case DndComplexity.average: return '●●○';
      case DndComplexity.high:    return '●●●';
    }
  }
}

enum DndClass {
  barbarian,
  bard,
  cleric,
  druid,
  fighter,
  monk,
  paladin,
  ranger,
  rogue,
  sorcerer,
  warlock,
  wizard;

  DndClassInfo get info => _infos[this]!;
  String get displayName => info.displayName;

  String get spriteId {
    switch (this) {
      case DndClass.paladin:   return 'hero_paladin';
      case DndClass.barbarian: return 'hero_barbarian';
      case DndClass.bard:      return 'hero_bard';
      case DndClass.cleric:    return 'hero_cleric';
      case DndClass.druid:     return 'hero_druid';
      case DndClass.fighter:   return 'hero_fighter';
      case DndClass.monk:      return 'hero_monk';
      case DndClass.ranger:    return 'hero_ranger';
      case DndClass.rogue:     return 'hero_rogue';
      case DndClass.sorcerer:  return 'hero_sorcerer';
      case DndClass.warlock:   return 'hero_warlock';
      case DndClass.wizard:    return 'hero_wizard';
    }
  }

  static DndClass? tryParse(String? s) {
    if (s == null) return null;
    try {
      return DndClass.values.firstWhere((c) => c.name == s);
    } catch (_) {
      return null;
    }
  }
}

const _infos = <DndClass, DndClassInfo>{
  DndClass.barbarian: DndClassInfo(
    displayName: 'Barbarian',
    likes: 'Battle',
    primaryAbility: 'Strength',
    complexity: DndComplexity.average,
    flavor: 'Primal fury channels into devastating melee strikes.',
    str: 15, dex: 13, con: 14, intelligence: 8,  wis: 12, cha: 10,
    icon: Icons.bolt,
    classElement: DamageType.poison,      // venom-infused primal strikes
    secondaryElement: DamageType.lightning, // storm warrior path
  ),
  DndClass.bard: DndClassInfo(
    displayName: 'Bard',
    likes: 'Performing',
    primaryAbility: 'Charisma',
    complexity: DndComplexity.high,
    flavor: 'Words and melody weave powerful magic into battle.',
    str: 8,  dex: 14, con: 13, intelligence: 10, wis: 12, cha: 15,
    icon: Icons.music_note,
    classElement: DamageType.void_,        // eldritch harmonic
    secondaryElement: DamageType.lightning, // bardic shock
  ),
  DndClass.cleric: DndClassInfo(
    displayName: 'Cleric',
    likes: 'Gods',
    primaryAbility: 'Wisdom',
    complexity: DndComplexity.average,
    flavor: 'Divine power flows through a devout vessel.',
    str: 13, dex: 8,  con: 14, intelligence: 10, wis: 15, cha: 12,
    icon: Icons.brightness_high,
    classElement: DamageType.fire,        // radiant / holy flame
    secondaryElement: DamageType.void_,   // sacred void judgment
  ),
  DndClass.druid: DndClassInfo(
    displayName: 'Druid',
    likes: 'Nature',
    primaryAbility: 'Wisdom',
    complexity: DndComplexity.high,
    flavor: "Nature's ancient magic bends to your will.",
    str: 8,  dex: 12, con: 14, intelligence: 13, wis: 15, cha: 10,
    icon: Icons.eco,
    classElement: DamageType.poison,      // nature toxins
    secondaryElement: DamageType.cold,    // winter's grasp
  ),
  DndClass.fighter: DndClassInfo(
    displayName: 'Fighter',
    likes: 'Weapons',
    primaryAbility: 'Strength or Dexterity',
    complexity: DndComplexity.low,
    flavor: 'Master of arms with unmatched combat training.',
    str: 15, dex: 13, con: 14, intelligence: 8,  wis: 12, cha: 10,
    icon: Icons.shield,
    classElement: DamageType.lightning,   // battle-hardened thunder strike
    secondaryElement: DamageType.fire,    // martial fire mastery
  ),
  DndClass.monk: DndClassInfo(
    displayName: 'Monk',
    likes: 'Unarmed combat',
    primaryAbility: 'Dexterity & Wisdom',
    complexity: DndComplexity.high,
    flavor: 'Body and mind honed to lethal precision.',
    str: 12, dex: 15, con: 13, intelligence: 8,  wis: 14, cha: 10,
    icon: Icons.self_improvement,
    classElement: DamageType.lightning,   // ki energy discharge
    secondaryElement: DamageType.void_,   // inner void mastery
  ),
  DndClass.paladin: DndClassInfo(
    displayName: 'Paladin',
    likes: 'Defense',
    primaryAbility: 'Strength & Charisma',
    complexity: DndComplexity.average,
    flavor: 'Sacred oaths empower both blade and spirit.',
    str: 15, dex: 10, con: 13, intelligence: 8,  wis: 12, cha: 14,
    icon: Icons.shield_outlined,
    classElement: DamageType.fire,        // divine smite / radiant fire
    secondaryElement: DamageType.cold,    // glacial verdict
  ),
  DndClass.ranger: DndClassInfo(
    displayName: 'Ranger',
    likes: 'Survival',
    primaryAbility: 'Dexterity & Wisdom',
    complexity: DndComplexity.average,
    flavor: 'Hunter and tracker who thrives in the wild.',
    str: 12, dex: 15, con: 13, intelligence: 10, wis: 14, cha: 8,
    icon: Icons.gps_fixed,
    classElement: DamageType.poison,      // toxin-tipped arrows
    secondaryElement: DamageType.cold,    // frost arrow path
  ),
  DndClass.rogue: DndClassInfo(
    displayName: 'Rogue',
    likes: 'Stealth',
    primaryAbility: 'Dexterity',
    complexity: DndComplexity.low,
    flavor: 'Swift and cunning, striking from the shadows.',
    str: 8,  dex: 15, con: 13, intelligence: 14, wis: 12, cha: 10,
    icon: Icons.visibility_off,
    classElement: DamageType.poison,      // poisoned blade
    secondaryElement: DamageType.void_,
  ),
  DndClass.sorcerer: DndClassInfo(
    displayName: 'Sorcerer',
    likes: 'Power',
    primaryAbility: 'Charisma',
    complexity: DndComplexity.high,
    flavor: 'Raw arcane power flows through innate magic.',
    str: 8,  dex: 13, con: 14, intelligence: 10, wis: 12, cha: 15,
    icon: Icons.auto_fix_high,
    classElement: DamageType.fire,        // innate fire magic
    secondaryElement: DamageType.cold,
  ),
  DndClass.warlock: DndClassInfo(
    displayName: 'Warlock',
    likes: 'Occult lore',
    primaryAbility: 'Charisma',
    complexity: DndComplexity.high,
    flavor: 'A pact with dark powers grants eldritch might.',
    str: 8,  dex: 13, con: 14, intelligence: 12, wis: 10, cha: 15,
    icon: Icons.dark_mode,
    classElement: DamageType.void_,        // eldritch energy
    secondaryElement: DamageType.cold,
  ),
  DndClass.wizard: DndClassInfo(
    displayName: 'Wizard',
    likes: 'Spellbooks',
    primaryAbility: 'Intelligence',
    complexity: DndComplexity.average,
    flavor: 'Vast arcane knowledge unlocks limitless spells.',
    str: 8,  dex: 12, con: 13, intelligence: 15, wis: 14, cha: 10,
    icon: Icons.menu_book,
    classElement: DamageType.cold,        // arcane frost
    secondaryElement: DamageType.void_,  // void mastery
  ),
};
