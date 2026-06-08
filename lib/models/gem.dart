import 'package:flutter/material.dart';
import 'equipment.dart';

enum GemType { ruby, sapphire, emerald, topaz, amethyst, diamond, onyx, citrine }
enum GemTier { flawed, standard, polished, radiant }

bool _isPctStat(ItemStat s) =>
    s == ItemStat.goldPct || s == ItemStat.xpPct || s == ItemStat.maxHpPct;

extension GemTypeInfo on GemType {
  String get label => switch (this) {
    GemType.ruby     => 'Ruby',
    GemType.sapphire => 'Sapphire',
    GemType.emerald  => 'Emerald',
    GemType.topaz    => 'Topaz',
    GemType.amethyst => 'Amethyst',
    GemType.diamond  => 'Diamond',
    GemType.onyx     => 'Onyx',
    GemType.citrine  => 'Citrine',
  };
  String get emoji => switch (this) {
    GemType.ruby     => '🔴',
    GemType.sapphire => '🔵',
    GemType.emerald  => '🟢',
    GemType.topaz    => '🟡',
    GemType.amethyst => '🟣',
    GemType.diamond  => '💎',
    GemType.onyx     => '⬛',
    GemType.citrine  => '🟠',
  };
  Color get color => switch (this) {
    GemType.ruby     => const Color(0xFFdd3344),
    GemType.sapphire => const Color(0xFF3366dd),
    GemType.emerald  => const Color(0xFF33aa55),
    GemType.topaz    => const Color(0xFFddaa22),
    GemType.amethyst => const Color(0xFFaa44dd),
    GemType.diamond  => const Color(0xFF88ddee),
    GemType.onyx     => const Color(0xFF6688aa),
    GemType.citrine  => const Color(0xFFdd7722),
  };
  ItemStat get stat => switch (this) {
    GemType.ruby     => ItemStat.damageBonus,
    GemType.sapphire => ItemStat.armorClass,
    GemType.emerald  => ItemStat.attackBonus,
    GemType.topaz    => ItemStat.goldPct,
    GemType.amethyst => ItemStat.xpPct,
    GemType.diamond  => ItemStat.constitution,
    GemType.onyx     => ItemStat.strength,
    GemType.citrine  => ItemStat.dexterity,
  };
  String get statDescription => switch (this) {
    GemType.ruby     => '+Damage',
    GemType.sapphire => '+Armor',
    GemType.emerald  => '+Attack',
    GemType.topaz    => '+Gold %',
    GemType.amethyst => '+XP %',
    GemType.diamond  => '+CON (HP regen)',
    GemType.onyx     => '+STR (ATK & DMG)',
    GemType.citrine  => '+DEX (AC)',
  };
}

extension GemTierInfo on GemTier {
  String get label => switch (this) {
    GemTier.flawed   => 'Flawed',
    GemTier.standard => 'Standard',
    GemTier.polished => 'Polished',
    GemTier.radiant  => 'Radiant',
  };
  Color get color => switch (this) {
    GemTier.flawed   => const Color(0xFFaaaaaa),
    GemTier.standard => const Color(0xFF6699ff),
    GemTier.polished => const Color(0xFFcc44ff),
    GemTier.radiant  => const Color(0xFFFFD700),
  };
  int get shardCost => switch (this) {
    GemTier.flawed   => 15,
    GemTier.standard => 50,
    GemTier.polished => 150,
    GemTier.radiant  => 400,
  };
  int _flatBonus() => switch (this) {
    GemTier.flawed   => 1,
    GemTier.standard => 2,
    GemTier.polished => 4,
    GemTier.radiant  => 7,
  };
  int _pctBonus() => switch (this) {
    GemTier.flawed   => 5,
    GemTier.standard => 10,
    GemTier.polished => 20,
    GemTier.radiant  => 35,
  };
  int valueFor(ItemStat stat) => _isPctStat(stat) ? _pctBonus() : _flatBonus();
}

class Gem {
  const Gem({required this.type, required this.tier});
  final GemType type;
  final GemTier tier;

  String get name    => '${tier.label} ${type.label}';
  Color  get color   => type.color;
  ItemStat get stat  => type.stat;
  int    get value   => tier.valueFor(stat);

  String get bonusLabel {
    final isPct = _isPctStat(stat);
    return '+$value${isPct ? '%' : ''} ${type.statDescription.replaceFirst('+', '').trim().split(' ').first}';
  }

  Map<String, dynamic> toJson() => {'type': type.name, 'tier': tier.name};

  static Gem fromJson(Map<String, dynamic> json) => Gem(
    type: GemType.values.firstWhere((t) => t.name == json['type']),
    tier: GemTier.values.firstWhere((t) => t.name == json['tier']),
  );
}
