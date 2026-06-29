import 'package:flutter/material.dart';
import 'damage_type.dart';
import 'equipment.dart';

enum GemType { ruby, sapphire, diamond, emerald, amethyst, onyx }
enum GemTier { flawed, standard, polished, radiant, exalted }

extension GemTypeInfo on GemType {
  String get label => switch (this) {
    GemType.ruby     => 'Ruby',
    GemType.sapphire => 'Sapphire',
    GemType.diamond  => 'Diamond',
    GemType.emerald  => 'Emerald',
    GemType.amethyst => 'Amethyst',
    GemType.onyx     => 'Onyx',
  };
  String get emoji => switch (this) {
    GemType.ruby     => '🔴',
    GemType.sapphire => '🔵',
    GemType.diamond  => '💎',
    GemType.emerald  => '🟢',
    GemType.amethyst => '🟣',
    GemType.onyx     => '⬛',
  };
  Color get color => switch (this) {
    GemType.ruby     => const Color(0xFFdd3344),
    GemType.sapphire => const Color(0xFF3366dd),
    GemType.diamond  => const Color(0xFFddcc44),
    GemType.emerald  => const Color(0xFF33aa55),
    GemType.amethyst => const Color(0xFFaa44dd),
    GemType.onyx     => const Color(0xFF6688aa),
  };
  DamageType get damageType => switch (this) {
    GemType.ruby     => DamageType.fire,
    GemType.sapphire => DamageType.cold,
    GemType.diamond  => DamageType.lightning,
    GemType.emerald  => DamageType.poison,
    GemType.amethyst => DamageType.void_,
    GemType.onyx     => DamageType.physical,
  };
  String get elementLabel => '${damageType.emoji} ${damageType.label}';

  // Legacy compat — map to an ItemStat for old code that reads gem.stat
  ItemStat get stat => switch (this) {
    GemType.ruby     => ItemStat.charisma,
    GemType.sapphire => ItemStat.wisdom,
    GemType.diamond  => ItemStat.dexterity,
    GemType.emerald  => ItemStat.constitution,
    GemType.amethyst => ItemStat.intelligence,
    GemType.onyx     => ItemStat.strength,
  };
}

extension GemTierInfo on GemTier {
  String get label => switch (this) {
    GemTier.flawed   => 'Flawed',
    GemTier.standard => 'Standard',
    GemTier.polished => 'Polished',
    GemTier.radiant  => 'Radiant',
    GemTier.exalted  => 'Exalted',
  };
  Color get color => switch (this) {
    GemTier.flawed   => const Color(0xFFaaaaaa),
    GemTier.standard => const Color(0xFF6699ff),
    GemTier.polished => const Color(0xFFcc44ff),
    GemTier.radiant  => const Color(0xFFFFD700),
    GemTier.exalted  => const Color(0xFFff4444),
  };
  int get shardCost => switch (this) {
    GemTier.flawed   => 15,
    GemTier.standard => 50,
    GemTier.polished => 150,
    GemTier.radiant  => 400,
    GemTier.exalted  => 1500,
  };
  int get pctBonus => switch (this) {
    GemTier.flawed   => 3,
    GemTier.standard => 6,
    GemTier.polished => 10,
    GemTier.radiant  => 15,
    GemTier.exalted  => 22,
  };
}

class Gem {
  const Gem({required this.type, required this.tier});
  final GemType type;
  final GemTier tier;

  String get name    => '${tier.label} ${type.label}';
  Color  get color   => type.color;
  DamageType get damageType => type.damageType;
  int    get value   => tier.pctBonus;

  // Legacy compat
  ItemStat get stat  => type.stat;

  String bonusLabelFor(ItemSlot slot) {
    final isWeapon = slot == ItemSlot.weapon || slot == ItemSlot.offHand;
    return isWeapon
        ? '+$value% ${type.elementLabel} DMG'
        : '+$value% ${type.elementLabel} RES';
  }

  String get bonusLabel => '+$value% ${type.elementLabel}';

  Map<String, dynamic> toJson() => {'type': type.name, 'tier': tier.name};

  static Gem fromJson(Map<String, dynamic> json) => Gem(
    type: GemType.values.firstWhere((t) => t.name == json['type'],
        orElse: () => GemType.onyx),
    tier: GemTier.values.firstWhere((t) => t.name == json['tier'],
        orElse: () => GemTier.flawed),
  );
}
