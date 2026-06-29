import 'package:flutter/material.dart';

// ── Zone effect types ─────────────────────────────────────────────────────────

enum ZoneEffect {
  heroDrain,      // hero loses flat HP each round
  enemyRegen,     // enemy heals value% max HP each round
  enemyAcBonus,   // enemy has permanent +value AC
  enemyAtkBonus,  // enemy has permanent +value ATK
  heroMissChance, // value% chance hero attacks miss
}

class ZoneModifier {
  const ZoneModifier({
    required this.effect,
    required this.value,
    required this.label,
    required this.icon,
  });

  final ZoneEffect effect;
  final int value;
  final String label;
  final String icon;

  String get description => switch (effect) {
    ZoneEffect.heroDrain      => 'Lose $value HP each round',
    ZoneEffect.enemyRegen     => 'Enemies regenerate $value% HP/round',
    ZoneEffect.enemyAcBonus   => 'Enemies have +$value Armour Class',
    ZoneEffect.enemyAtkBonus  => 'Enemies have +$value Attack',
    ZoneEffect.heroMissChance => '$value% chance your attacks miss',
  };
}

// ── World zone ────────────────────────────────────────────────────────────────

class WorldZone {
  const WorldZone({
    required this.name,
    required this.flavor,
    required this.color,
    required this.icon,
    required this.firstStage,
    required this.lastStage,
    this.modifier,
  });

  final String name;
  final String flavor;
  final Color color;
  final String icon;
  final int firstStage;
  final int lastStage;
  final ZoneModifier? modifier;

  int get stageCount => lastStage - firstStage + 1;

  int progressIn(int stageIndex) =>
      (stageIndex + 1 - firstStage).clamp(0, stageCount);

  bool contains(int stageIndex) =>
      stageIndex + 1 >= firstStage && stageIndex + 1 <= lastStage;
}
