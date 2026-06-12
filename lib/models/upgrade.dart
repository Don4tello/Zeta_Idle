import 'dart:math';
import 'hero_model.dart';

enum UpgradeType { strength, dexterity, constitution, intelligence, wisdom, charisma, dualMastery }

extension UpgradeTypeLabel on UpgradeType {
  String get label {
    switch (this) {
      case UpgradeType.strength:    return 'STR';
      case UpgradeType.dexterity:   return 'DEX';
      case UpgradeType.constitution:return 'CON';
      case UpgradeType.intelligence:return 'INT';
      case UpgradeType.wisdom:      return 'WIS';
      case UpgradeType.charisma:    return 'CHA';
      case UpgradeType.dualMastery: return '✨';
    }
  }
}

class Upgrade {
  Upgrade({
    required this.id,
    required this.name,
    required this.description,
    required this.baseCost,
    required this.type,
    required this.effectAmount,
    this.level = 0,
    this.maxLevel = 5,
  });

  final String id;
  final String name;
  final String description;
  final int baseCost;
  final UpgradeType type;
  final int effectAmount;
  int level;
  final int maxLevel;

  bool get isMaxed => level >= maxLevel;
  // Progressive curve: ×2.0 per level, with an extra ×1.5 per level above 4.
  // Early ranks are cheap; the final ranks become significantly more expensive.
  int get cost {
    final geometric = baseCost * pow(2.0, level);
    final kicker = level > 4 ? pow(1.5, level - 4) : 1.0;
    return (geometric * kicker).round().clamp(baseCost, baseCost * 500000);
  }

  void applyTo(HeroModel hero) {
    switch (type) {
      case UpgradeType.strength:
        hero.addStrength(effectAmount);
      case UpgradeType.dexterity:
        hero.addDexterity(effectAmount);
      case UpgradeType.constitution:
        hero.addConstitution(effectAmount);
      case UpgradeType.intelligence:
        hero.addIntelligence(effectAmount);
      case UpgradeType.wisdom:
        hero.addWisdom(effectAmount);
      case UpgradeType.charisma:
        hero.addCharisma(effectAmount);
      case UpgradeType.dualMastery:
        hero.dualMasteryUnlocked = true;
    }
    level = (level + 1).clamp(0, maxLevel);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'baseCost': baseCost,
    'type': type.name,
    'effectAmount': effectAmount,
    'level': level,
    'maxLevel': maxLevel,
  };

  factory Upgrade.fromJson(Map<String, dynamic> json) {
    // Remap old save types to new D&D types gracefully
    final rawType = json['type'] as String;
    UpgradeType parsedType;
    switch (rawType) {
      case 'attack': parsedType = UpgradeType.strength; break;
      case 'health': parsedType = UpgradeType.constitution; break;
      case 'idle':   parsedType = UpgradeType.wisdom; break;
      case 'gold':   parsedType = UpgradeType.intelligence; break;
      default:
        parsedType = UpgradeType.values.firstWhere(
          (v) => v.name == rawType,
          orElse: () => UpgradeType.strength,
        );
    }
    return Upgrade(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      baseCost: json['baseCost'] as int,
      type: parsedType,
      effectAmount: json['effectAmount'] as int,
      level: json['level'] as int,
      maxLevel: json['maxLevel'] as int,
    );
  }
}
