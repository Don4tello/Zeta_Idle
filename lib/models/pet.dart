import 'package:flutter/material.dart';
import 'dnd_class.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Pet system — 12 paid companions, one per DnD class.
// Each pet grants its bonus passively just by being owned (stacks with others).
// The "equipped" pet is the one that appears as a battle companion.
// ─────────────────────────────────────────────────────────────────────────────

enum PetBonusType {
  goldPct,     // +N% gold per kill
  xpPct,       // +N% XP per kill
  hpRegen,     // +N HP restored after each victory
  idleRate,    // +N idle-rate ticks per cycle
  attackBonus, // +N to attack rolls
  armor,       // +N AC
  damage,      // +N to damage
  shardBonus,  // +N shards per kill
  dodgeChance, // +N% chance to evade enemy attacks
  essenceGain, // +N% essence from kills
}

class PetDefinition {
  const PetDefinition({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.flavorLine,
    required this.bonusType,
    required this.bonusValue,
    required this.color,
    required this.crystalCost,
    required this.themeClass,
    required this.isFlying,
  });

  final String id;
  final String name;
  final String emoji;
  final String description;
  final String flavorLine;
  final PetBonusType bonusType;
  final int bonusValue;
  final Color color;
  final int crystalCost;
  final DndClass themeClass;
  final bool isFlying;   // true → hovers/bobs in battle; false → stands on ground

  String get bonusLabel {
    final v = bonusValue;
    return switch (bonusType) {
      PetBonusType.goldPct     => '+$v% gold per kill',
      PetBonusType.xpPct       => '+$v% XP per kill',
      PetBonusType.hpRegen     => '+$v HP after each victory',
      PetBonusType.idleRate    => '+$v idle rate',
      PetBonusType.attackBonus => '+$v to attack rolls',
      PetBonusType.armor       => '+$v AC',
      PetBonusType.damage      => '+$v damage',
      PetBonusType.shardBonus  => '+$v shard per kill',
      PetBonusType.dodgeChance => '+$v% dodge chance',
      PetBonusType.essenceGain => '+$v% essence from kills',
    };
  }
}

const kPetCatalog = <PetDefinition>[
  PetDefinition(
    id:          'iron_boar',
    name:        'Iron Boar',
    emoji:       '🐗',
    description: 'A stocky beast whose tusks are rumoured to sniff out buried coin.',
    flavorLine:  'Barbarian companion',
    bonusType:   PetBonusType.goldPct,
    bonusValue:  2,
    color:       Color(0xFFd4682a),
    crystalCost: 250,
    themeClass:  DndClass.barbarian,
    isFlying:    false,
  ),
  PetDefinition(
    id:          'lute_sparrow',
    name:        'Lute Sparrow',
    emoji:       '🐦',
    description: 'A tiny songbird that hums battle-hymns, sharpening the mind for learning.',
    flavorLine:  'Bard companion',
    bonusType:   PetBonusType.xpPct,
    bonusValue:  2,
    color:       Color(0xFFf5c842),
    crystalCost: 250,
    themeClass:  DndClass.bard,
    isFlying:    true,
  ),
  PetDefinition(
    id:          'sacred_dove',
    name:        'Sacred Dove',
    emoji:       '🕊️',
    description: 'A holy bird whose cooing carries divine healing energy.',
    flavorLine:  'Cleric companion',
    bonusType:   PetBonusType.hpRegen,
    bonusValue:  3,
    color:       Color(0xFFaaddff),
    crystalCost: 200,
    themeClass:  DndClass.cleric,
    isFlying:    true,
  ),
  PetDefinition(
    id:          'forest_wolf',
    name:        'Forest Wolf',
    emoji:       '🐺',
    description: 'A silver-furred wolf attuned to natural rhythms, hastening idle recovery.',
    flavorLine:  'Druid companion',
    bonusType:   PetBonusType.idleRate,
    bonusValue:  1,
    color:       Color(0xFF55aa55),
    crystalCost: 250,
    themeClass:  DndClass.druid,
    isFlying:    false,
  ),
  PetDefinition(
    id:          'battle_hound',
    name:        'Battle Hound',
    emoji:       '🐕',
    description: 'A seasoned war dog whose bark rattles the enemy just before your strike.',
    flavorLine:  'Fighter companion',
    bonusType:   PetBonusType.attackBonus,
    bonusValue:  1,
    color:       Color(0xFFcc3333),
    crystalCost: 300,
    themeClass:  DndClass.fighter,
    isFlying:    false,
  ),
  PetDefinition(
    id:          'stone_turtle',
    name:        'Stone Turtle',
    emoji:       '🐢',
    description: 'An ancient shell-clad sage whose calm aura hardens your resolve.',
    flavorLine:  'Monk companion',
    bonusType:   PetBonusType.armor,
    bonusValue:  1,
    color:       Color(0xFF7a9060),
    crystalCost: 300,
    themeClass:  DndClass.monk,
    isFlying:    false,
  ),
  PetDefinition(
    id:          'holy_lamb',
    name:        'Holy Lamb',
    emoji:       '🐑',
    description: 'A blessed lamb whose fleece radiates restorative warmth after battle.',
    flavorLine:  'Paladin companion',
    bonusType:   PetBonusType.hpRegen,
    bonusValue:  5,
    color:       Color(0xFFffe88a),
    crystalCost: 300,
    themeClass:  DndClass.paladin,
    isFlying:    false,
  ),
  PetDefinition(
    id:          'shadow_hawk',
    name:        'Shadow Hawk',
    emoji:       '🦅',
    description: 'A keen-eyed raptor that guides your strikes with predatory precision.',
    flavorLine:  'Ranger companion',
    bonusType:   PetBonusType.damage,
    bonusValue:  1,
    color:       Color(0xFF8b6040),
    crystalCost: 300,
    themeClass:  DndClass.ranger,
    isFlying:    true,
  ),
  PetDefinition(
    id:          'night_cat',
    name:        'Night Cat',
    emoji:       '🐈‍⬛',
    description: 'A black-furred hunter who always finds a way to pocket something shiny.',
    flavorLine:  'Rogue companion',
    bonusType:   PetBonusType.shardBonus,
    bonusValue:  1,
    color:       Color(0xFF9955cc),
    crystalCost: 300,
    themeClass:  DndClass.rogue,
    isFlying:    false,
  ),
  PetDefinition(
    id:          'arcane_ferret',
    name:        'Arcane Ferret',
    emoji:       '🦦',
    description: 'An impossibly energetic creature charged with unstable arcane static.',
    flavorLine:  'Sorcerer companion',
    bonusType:   PetBonusType.damage,
    bonusValue:  2,
    color:       Color(0xFF8866ff),
    crystalCost: 300,
    themeClass:  DndClass.sorcerer,
    isFlying:    false,
  ),
  PetDefinition(
    id:          'imp_familiar',
    name:        'Imp Familiar',
    emoji:       '🦇',
    description: 'A leathery-winged fiend bound to your will — and to collecting dark trophies.',
    flavorLine:  'Warlock companion',
    bonusType:   PetBonusType.shardBonus,
    bonusValue:  2,
    color:       Color(0xFF554488),
    crystalCost: 350,
    themeClass:  DndClass.warlock,
    isFlying:    true,
  ),
  PetDefinition(
    id:          'arcane_owl',
    name:        'Arcane Owl',
    emoji:       '🦉',
    description: 'A spectacled owl who catalogs every battle, accelerating your growth.',
    flavorLine:  'Wizard companion',
    bonusType:   PetBonusType.idleRate,
    bonusValue:  2,
    color:       Color(0xFF4488cc),
    crystalCost: 350,
    themeClass:  DndClass.wizard,
    isFlying:    true,
  ),
];
