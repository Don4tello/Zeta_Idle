import 'package:flutter/material.dart';
import 'pet.dart' show PetBonusType;

// ─────────────────────────────────────────────────────────────────────────────
// Hero Auras — cosmetic glow effects with a small thematic passive bonus.
// Bonuses are intentionally tiny: they reward purchase without defining power.
// ─────────────────────────────────────────────────────────────────────────────

class HeroAura {
  const HeroAura({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.crystalCost,
    required this.bonusType,
    required this.bonusValue,
    this.intensity = 1.0,
  });

  final String id;
  final String name;
  final String description;
  final Color color;
  final int crystalCost;
  final double intensity;
  final PetBonusType bonusType;
  final int bonusValue;

  String get bonusLabel {
    final v = bonusValue;
    return switch (bonusType) {
      PetBonusType.goldPct     => '+$v% gold per kill',
      PetBonusType.xpPct       => '+$v% XP per kill',
      PetBonusType.hpRegen     => '+$v HP after each victory',
      PetBonusType.idleRate    => '+$v idle rate',
      PetBonusType.attackBonus => '+$v critical damage',
      PetBonusType.armor       => '+$v AC',
      PetBonusType.damage      => '+$v damage',
      PetBonusType.shardBonus  => '+$v shard per kill',
      PetBonusType.dodgeChance => '+$v% dodge chance',
      PetBonusType.essenceGain => '+$v% essence from kills',
    };
  }
}

const kAuraCatalog = <HeroAura>[
  HeroAura(
    id: 'shadow',
    name: 'Shadow',
    description: 'Darkness clings to you like a second skin.',
    color: Color(0xFF8855aa),
    crystalCost: 150,
    intensity: 0.8,
    bonusType: PetBonusType.dodgeChance,
    bonusValue: 3,
  ),
  HeroAura(
    id: 'frost',
    name: 'Frost',
    description: 'Ice crystals hang in the air around you.',
    color: Color(0xFF44ddff),
    crystalCost: 200,
    intensity: 1.0,
    bonusType: PetBonusType.armor,
    bonusValue: 1,
  ),
  HeroAura(
    id: 'inferno',
    name: 'Inferno',
    description: 'Living flame dances at your fingertips.',
    color: Color(0xFFff4400),
    crystalCost: 200,
    intensity: 1.2,
    bonusType: PetBonusType.damage,
    bonusValue: 2,
  ),
  HeroAura(
    id: 'venom',
    name: 'Venom',
    description: 'Toxic miasma follows wherever you tread.',
    color: Color(0xFF44ff44),
    crystalCost: 250,
    intensity: 1.0,
    bonusType: PetBonusType.xpPct,
    bonusValue: 3,
  ),
  HeroAura(
    id: 'storm',
    name: 'Storm',
    description: 'Lightning crackles at your every step.',
    color: Color(0xFF88ccff),
    crystalCost: 250,
    intensity: 1.2,
    bonusType: PetBonusType.attackBonus,
    bonusValue: 1,
  ),
  HeroAura(
    id: 'void',
    name: 'Void',
    description: 'The abyss itself spills from within you.',
    color: Color(0xFF9900ff),
    crystalCost: 300,
    intensity: 1.3,
    bonusType: PetBonusType.essenceGain,
    bonusValue: 5,
  ),
  HeroAura(
    id: 'holy',
    name: 'Holy',
    description: 'Divine radiance marks you as chosen.',
    color: Color(0xFFffee66),
    crystalCost: 300,
    intensity: 1.1,
    bonusType: PetBonusType.hpRegen,
    bonusValue: 4,
  ),
  HeroAura(
    id: 'blood',
    name: 'Blood',
    description: 'The crimson tide answers your call.',
    color: Color(0xFFcc0033),
    crystalCost: 350,
    intensity: 1.4,
    bonusType: PetBonusType.goldPct,
    bonusValue: 3,
  ),
];
