import 'dart:math';
import 'package:flutter/material.dart';
import 'gem.dart';

enum ItemSlot { weapon, offHand, helmet, armor, gloves, pants, boots, ring, ring2, amulet, relic }
enum ItemRarity { common, rare, epic, legendary, set }
enum ItemStat {
  strength, dexterity, constitution, intelligence, wisdom, charisma,
  attackBonus, damageBonus, armorClass, maxHpPct, goldPct, xpPct,
}

extension ItemStatInfo on ItemStat {
  String get shortLabel => switch (this) {
    ItemStat.attackBonus  => 'ATK',
    ItemStat.damageBonus  => 'DMG',
    ItemStat.armorClass   => 'AC',
    ItemStat.strength     => 'PWR',
    ItemStat.dexterity    => 'AGI',
    ItemStat.constitution => 'VIT',
    ItemStat.intelligence => 'ARC',
    ItemStat.wisdom       => 'FOC',
    ItemStat.charisma     => 'FOR',
    ItemStat.maxHpPct     => '%HP',
    ItemStat.goldPct      => '%G',
    ItemStat.xpPct        => '%XP',
  };
}

extension ItemSlotInfo on ItemSlot {
  String get label => switch (this) {
    ItemSlot.weapon  => 'Weapon',
    ItemSlot.offHand => 'Off-Hand',
    ItemSlot.helmet  => 'Helmet',
    ItemSlot.armor   => 'Armor',
    ItemSlot.gloves  => 'Gloves',
    ItemSlot.pants   => 'Pants',
    ItemSlot.boots   => 'Boots',
    ItemSlot.ring    => 'Ring',
    ItemSlot.ring2   => 'Ring 2',
    ItemSlot.amulet  => 'Amulet',
    ItemSlot.relic   => 'Relic',
  };
  String get icon => switch (this) {
    ItemSlot.weapon  => '⚔',
    ItemSlot.offHand => '🛡',
    ItemSlot.helmet  => '⛑',
    ItemSlot.armor   => '🧥',
    ItemSlot.gloves  => '🧤',
    ItemSlot.pants   => '👖',
    ItemSlot.boots   => '👢',
    ItemSlot.ring    => '💍',
    ItemSlot.ring2   => '💍',
    ItemSlot.amulet  => '📿',
    ItemSlot.relic   => '🔮',
  };
}

// ── Legendary keyword effects ─────────────────────────────────────────────────
enum ItemKeyword {
  lifeSteal,    // 10% lifesteal on hits
  riposte,      // 3 dmg returned when enemy misses
  soulHunger,   // +1 shard per kill
  vengeance,    // +2 ATK when below 50% HP
  goldSense,    // +15% gold from kills
  swiftStrike,  // 15% chance to strike twice
  criticalFury, // crits deal 3× instead of 2×
  ironWill,     // reduce incoming damage by 1
  // ── Legendary-exclusive keywords ──────────────────────────────────────────
  voidStep,     // 15% chance to dodge incoming attack entirely
  bloodPact,    // deal bonus damage = 20% of missing HP
  soulRip,      // 8% chance to instakill enemy below 25% HP
  thornWall,    // return 30% of incoming damage to attacker
}

extension ItemKeywordInfo on ItemKeyword {
  String get label => switch (this) {
    ItemKeyword.lifeSteal    => 'Life Steal',
    ItemKeyword.riposte      => 'Riposte',
    ItemKeyword.soulHunger   => 'Soul Hunger',
    ItemKeyword.vengeance    => 'Vengeance',
    ItemKeyword.goldSense    => 'Gold Sense',
    ItemKeyword.swiftStrike  => 'Swift Strike',
    ItemKeyword.criticalFury => 'Critical Fury',
    ItemKeyword.ironWill     => 'Iron Will',
    ItemKeyword.voidStep     => 'Void Step',
    ItemKeyword.bloodPact    => 'Blood Pact',
    ItemKeyword.soulRip      => 'Soul Rip',
    ItemKeyword.thornWall    => 'Thorn Wall',
  };
  String get description => switch (this) {
    ItemKeyword.lifeSteal    => 'Heal 10% of damage dealt on every hit.',
    ItemKeyword.riposte      => 'Deal 3 damage when an enemy attack misses.',
    ItemKeyword.soulHunger   => '+1 Shard from every kill.',
    ItemKeyword.vengeance    => '+2 Attack when below 50% HP.',
    ItemKeyword.goldSense    => '+15% gold from all kills.',
    ItemKeyword.swiftStrike  => '15% chance to strike twice per attack.',
    ItemKeyword.criticalFury => 'Critical hits deal 3× damage instead of 2×.',
    ItemKeyword.ironWill     => 'Reduce all incoming damage by 1.',
    ItemKeyword.voidStep     => '15% chance to dodge an incoming attack entirely.',
    ItemKeyword.bloodPact    => 'Deal bonus damage equal to 20% of your missing HP.',
    ItemKeyword.soulRip      => '8% chance to instantly kill an enemy below 25% HP.',
    ItemKeyword.thornWall    => 'Return 30% of incoming damage to the attacker.',
  };

  bool get isLegendaryOnly => switch (this) {
    ItemKeyword.voidStep  => true,
    ItemKeyword.bloodPact => true,
    ItemKeyword.soulRip   => true,
    ItemKeyword.thornWall => true,
    _ => false,
  };
}

// ─────────────────────────────────────────────────────────────────────────────

class StatBonus {
  const StatBonus(this.stat, this.value);
  final ItemStat stat;
  final int value;
}

// ── Set system ────────────────────────────────────────────────────────────────

class SetBonus {
  const SetBonus({required this.piecesRequired, required this.bonuses});
  final int piecesRequired;
  final List<StatBonus> bonuses;

  String get label {
    final parts = bonuses.map((b) => '+${b.value} ${_shortStat(b.stat)}').join(', ');
    return '($piecesRequired) $parts';
  }

  static String _shortStat(ItemStat s) => s.shortLabel;
}

class ItemSet {
  const ItemSet({
    required this.id,
    required this.name,
    required this.color,
    required this.slots,
    required this.tiers,
  });
  final String id;
  final String name;
  final Color color;
  final List<ItemSlot> slots;
  final List<SetBonus> tiers; // sorted ascending by piecesRequired
}

const kSetCatalog = <ItemSet>[
  // ── Shadowstalker: speed & precision (gloves, boots, armor, helmet) ───────
  ItemSet(
    id: 'shadowstalker', name: 'Shadowstalker',
    color: Color(0xFF00cc88),
    slots: [ItemSlot.gloves, ItemSlot.boots, ItemSlot.armor, ItemSlot.helmet],
    tiers: [
      SetBonus(piecesRequired: 2, bonuses: [StatBonus(ItemStat.attackBonus, 2), StatBonus(ItemStat.dexterity, 2)]),
      SetBonus(piecesRequired: 4, bonuses: [StatBonus(ItemStat.attackBonus, 5), StatBonus(ItemStat.dexterity, 5), StatBonus(ItemStat.damageBonus, 3)]),
    ],
  ),
  // ── Ironclad: defense & endurance (helmet, armor, pants, off-hand) ────────
  ItemSet(
    id: 'ironclad', name: 'Ironclad',
    color: Color(0xFF6699cc),
    slots: [ItemSlot.helmet, ItemSlot.armor, ItemSlot.pants, ItemSlot.offHand],
    tiers: [
      SetBonus(piecesRequired: 2, bonuses: [StatBonus(ItemStat.armorClass, 4), StatBonus(ItemStat.constitution, 2)]),
      SetBonus(piecesRequired: 4, bonuses: [StatBonus(ItemStat.armorClass, 9), StatBonus(ItemStat.constitution, 5)]),
    ],
  ),
  // ── Goldweaver: wealth & growth (ring, ring2, amulet, relic) ─────────────
  ItemSet(
    id: 'goldweaver', name: 'Goldweaver',
    color: Color(0xFFddaa00),
    slots: [ItemSlot.ring, ItemSlot.ring2, ItemSlot.amulet, ItemSlot.relic],
    tiers: [
      SetBonus(piecesRequired: 2, bonuses: [StatBonus(ItemStat.goldPct, 20), StatBonus(ItemStat.xpPct, 10)]),
      SetBonus(piecesRequired: 4, bonuses: [StatBonus(ItemStat.goldPct, 40), StatBonus(ItemStat.xpPct, 25), StatBonus(ItemStat.charisma, 3)]),
    ],
  ),
  // ── Stormcaller: raw power (weapon, gloves, helmet) ──────────────────────
  ItemSet(
    id: 'stormcaller', name: 'Stormcaller',
    color: Color(0xFFddcc00),
    slots: [ItemSlot.weapon, ItemSlot.gloves, ItemSlot.helmet],
    tiers: [
      SetBonus(piecesRequired: 2, bonuses: [StatBonus(ItemStat.damageBonus, 3), StatBonus(ItemStat.strength, 2)]),
      SetBonus(piecesRequired: 3, bonuses: [StatBonus(ItemStat.damageBonus, 7), StatBonus(ItemStat.strength, 5), StatBonus(ItemStat.attackBonus, 2)]),
    ],
  ),
  // ── Wraithbound: void mastery (weapon, off-hand, boots, pants) ───────────
  ItemSet(
    id: 'wraithbound', name: 'Wraithbound',
    color: Color(0xFF8844cc),
    slots: [ItemSlot.weapon, ItemSlot.offHand, ItemSlot.boots, ItemSlot.pants],
    tiers: [
      SetBonus(piecesRequired: 2, bonuses: [StatBonus(ItemStat.attackBonus, 2), StatBonus(ItemStat.wisdom, 2)]),
      SetBonus(piecesRequired: 4, bonuses: [StatBonus(ItemStat.attackBonus, 5), StatBonus(ItemStat.wisdom, 5), StatBonus(ItemStat.damageBonus, 3)]),
    ],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────

class EquipmentItem {
  EquipmentItem({
    required this.id,
    required this.name,
    required this.slot,
    required this.rarity,
    required this.bonuses,
    required this.levelRequired,
    this.keyword,
    this.setId,
    this.gem,
  });

  final String id;
  final String name;
  final ItemSlot slot;
  final ItemRarity rarity;
  final List<StatBonus> bonuses;
  final int levelRequired;
  final ItemKeyword? keyword;
  final String? setId;
  Gem? gem; // mutable socket — 1 gem per item

  ItemSet? get itemSet => setId == null
      ? null
      : kSetCatalog.where((s) => s.id == setId).firstOrNull;

  String get rarityLabel => switch (rarity) {
    ItemRarity.common    => 'Common',
    ItemRarity.rare      => 'Rare',
    ItemRarity.epic      => 'Epic',
    ItemRarity.legendary => 'Legendary',
    ItemRarity.set       => 'Set',
  };

  Color get rarityColor => switch (rarity) {
    ItemRarity.common    => const Color(0xFFaaaaaa),
    ItemRarity.rare      => const Color(0xFF6699ff),
    ItemRarity.epic      => const Color(0xFFcc44ff),
    ItemRarity.legendary => const Color(0xFFFFD700),
    ItemRarity.set       => itemSet?.color ?? const Color(0xFF00cc88),
  };

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slot': slot.name,
    'rarity': rarity.name,
    'bonuses': bonuses.map((b) => {'stat': b.stat.name, 'value': b.value}).toList(),
    'levelRequired': levelRequired,
    if (keyword != null) 'keyword': keyword!.name,
    if (setId  != null) 'setId': setId,
    if (gem    != null) 'gem': gem!.toJson(),
  };

  static EquipmentItem fromJson(Map<String, dynamic> json) {
    final kwStr  = json['keyword'] as String?;
    final setStr = json['setId']   as String?;
    return EquipmentItem(
      id: json['id'] as String,
      name: json['name'] as String,
      slot: ItemSlot.values.firstWhere((s) => s.name == json['slot'],
          orElse: () => ItemSlot.weapon),
      rarity: ItemRarity.values.firstWhere(
        (r) => r.name == json['rarity'],
        orElse: () => ItemRarity.common,
      ),
      bonuses: (json['bonuses'] as List<dynamic>).map((b) {
        final m = b as Map<String, dynamic>;
        return StatBonus(
          ItemStat.values.firstWhere((s) => s.name == m['stat']),
          m['value'] as int,
        );
      }).toList(),
      levelRequired: json['levelRequired'] as int,
      keyword: kwStr != null
          ? ItemKeyword.values.firstWhere((k) => k.name == kwStr,
              orElse: () => ItemKeyword.lifeSteal)
          : null,
      setId: setStr,
      gem: json['gem'] != null
          ? Gem.fromJson(json['gem'] as Map<String, dynamic>)
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ItemLootTable
// ─────────────────────────────────────────────────────────────────────────────

class ItemLootTable {
  // ── Name pools ────────────────────────────────────────────────────────────
  static const _weaponNames  = ['Iron Blade', 'Bone Axe', 'Shadow Dagger', 'Cursed Mace', 'Runic Sword', 'Void Glaive', 'Hex Wand', 'Death Scythe'];
  static const _offHandNames = ['Targe Shield', 'Bone Buckler', 'Shadow Guard', 'Cursed Barrier', 'Rune Shield', 'Void Ward', 'Iron Bulwark', 'Death Aegis'];
  static const _helmetNames  = ['Iron Helm', 'Bone Crown', 'Shadow Cowl', 'Cursed Visor', 'Rune Cap', 'Void Circlet', 'Hex Mask', 'Death Warhelm'];
  static const _armorNames   = ['Chain Hauberk', 'Bone Plate', 'Shadow Cloak', 'Cursed Mail', 'Rune Guard', 'Void Shroud', 'Hex Vestments', 'Iron Carapace'];
  static const _glovesNames  = ['Iron Gauntlets', 'Bone Grips', 'Shadow Mitts', 'Cursed Wraps', 'Rune Bracers', 'Void Gloves', 'Hex Knuckles', 'Death Grips'];
  static const _pantsNames   = ['Iron Greaves', 'Bone Leggings', 'Shadow Breeches', 'Cursed Chaps', 'Rune Legguards', 'Void Legplates', 'Hex Trousers', 'Death Legwraps'];
  static const _bootsNames   = ['Iron Boots', 'Bone Treads', 'Shadow Walkers', 'Cursed Greaves', 'Rune Sabatons', 'Void Striders', 'Hex Slippers', 'Death Stompers'];
  static const _ringNames    = ['Ring of Fury', 'Bone Band', 'Shadow Signet', 'Cursed Loop', 'Rune Circle', 'Void Ring', 'Hex Band', 'Death Seal'];
  static const _amuletNames  = ['Amulet of Might', 'Bone Talisman', 'Shadow Pendant', 'Cursed Locket', 'Rune Charm', 'Void Medallion', 'Hex Totem', 'Death Ward'];
  static const _relicNames   = ['Eye of Fate', 'Bone Fragment', 'Shadow Shard', 'Cursed Rune', 'Ancient Token', 'Void Crystal', 'Hex Ember', 'Death Spark'];

  // ── Stat pools per slot ────────────────────────────────────────────────────
  static const _weaponStats   = [ItemStat.attackBonus, ItemStat.damageBonus, ItemStat.strength];
  static const _offHandStats  = [ItemStat.armorClass, ItemStat.attackBonus, ItemStat.constitution];
  static const _helmetStats   = [ItemStat.armorClass, ItemStat.constitution, ItemStat.wisdom];
  static const _armorStats    = [ItemStat.armorClass, ItemStat.constitution, ItemStat.maxHpPct];
  static const _glovesStats   = [ItemStat.attackBonus, ItemStat.damageBonus, ItemStat.dexterity];
  static const _pantsStats    = [ItemStat.armorClass, ItemStat.constitution, ItemStat.dexterity];
  static const _bootsStats    = [ItemStat.dexterity, ItemStat.armorClass, ItemStat.wisdom];
  static const _accessoryStats = [ItemStat.goldPct, ItemStat.xpPct, ItemStat.wisdom, ItemStat.intelligence, ItemStat.charisma, ItemStat.dexterity, ItemStat.attackBonus];
  static const _relicStats    = [ItemStat.goldPct, ItemStat.xpPct, ItemStat.wisdom, ItemStat.intelligence, ItemStat.charisma];

  // ── Affix prefix/suffix tables (common, rare, epic) ───────────────────────
  static const _prefixCommon = {
    ItemStat.attackBonus: 'Keen',     ItemStat.damageBonus:  'Sharp',    ItemStat.armorClass:   'Guard',
    ItemStat.strength:    'Strong',   ItemStat.dexterity:    'Quick',    ItemStat.constitution: 'Tough',
    ItemStat.intelligence:'Arcane',   ItemStat.wisdom:       'Sage',     ItemStat.charisma:     'Bold',
    ItemStat.maxHpPct:    'Hearty',   ItemStat.goldPct:      'Lucky',    ItemStat.xpPct:        'Learned',
  };
  static const _prefixRare = {
    ItemStat.attackBonus: 'Keen',       ItemStat.damageBonus:  'Savage',    ItemStat.armorClass:   'Stalwart',
    ItemStat.strength:    'Mighty',     ItemStat.dexterity:    'Swift',     ItemStat.constitution: 'Hardy',
    ItemStat.intelligence:'Mystic',     ItemStat.wisdom:       'Ancient',   ItemStat.charisma:     'Commanding',
    ItemStat.maxHpPct:    'Vital',      ItemStat.goldPct:      'Prosperous',ItemStat.xpPct:        "Veteran's",
  };
  static const _prefixEpic = {
    ItemStat.attackBonus: 'Deadly',     ItemStat.damageBonus:  'Brutal',    ItemStat.armorClass:   'Fortified',
    ItemStat.strength:    "Titan's",    ItemStat.dexterity:    'Shadow',    ItemStat.constitution: 'Stone',
    ItemStat.intelligence:'Elder',      ItemStat.wisdom:       'Eternal',   ItemStat.charisma:     'Glorious',
    ItemStat.maxHpPct:    'Ironhide',   ItemStat.goldPct:      "Fortune's", ItemStat.xpPct:        'Enlightened',
  };
  static const _suffixRare = {
    ItemStat.attackBonus: 'Striking',   ItemStat.damageBonus:  'Ruin',      ItemStat.armorClass:   'Warding',
    ItemStat.strength:    'Might',      ItemStat.dexterity:    'Agility',   ItemStat.constitution: 'Endurance',
    ItemStat.intelligence:'Arcana',     ItemStat.wisdom:       'Foresight', ItemStat.charisma:     'Command',
    ItemStat.maxHpPct:    'Vitality',   ItemStat.goldPct:      'Fortune',   ItemStat.xpPct:        'Wisdom',
  };
  static const _suffixEpic = {
    ItemStat.attackBonus: 'Slaughter',  ItemStat.damageBonus:  'Destruction',ItemStat.armorClass:  'the Bastion',
    ItemStat.strength:    'Dominion',   ItemStat.dexterity:    'the Void',  ItemStat.constitution: 'Eternity',
    ItemStat.intelligence:'the Abyss',  ItemStat.wisdom:       'the Ages',  ItemStat.charisma:     'Legend',
    ItemStat.maxHpPct:    'the Colossus',ItemStat.goldPct:     'Avarice',   ItemStat.xpPct:        'Transcendence',
  };
  static const _keywordTitle = {
    ItemKeyword.lifeSteal:    'Blooddrinker', ItemKeyword.riposte:     'Retaliator',
    ItemKeyword.soulHunger:   'Souleater',    ItemKeyword.vengeance:   'Vindicator',
    ItemKeyword.goldSense:    'Gleamsong',    ItemKeyword.swiftStrike: 'Quicksilver',
    ItemKeyword.criticalFury: 'Doomcaller',   ItemKeyword.ironWill:    'Ironheart',
  };

  // ── Name builder ──────────────────────────────────────────────────────────
  static String _buildName(List<StatBonus> bonuses, ItemRarity rarity, String baseName, [ItemKeyword? keyword]) {
    if (rarity == ItemRarity.legendary && keyword != null) return '${_keywordTitle[keyword]!} $baseName';
    if (bonuses.isEmpty) return baseName;
    final primary = bonuses.first.stat;
    switch (rarity) {
      case ItemRarity.common:
        final pfx = _prefixCommon[primary] ?? '';
        return pfx.isEmpty ? baseName : '$pfx $baseName';
      case ItemRarity.rare:
        final pfx = _prefixRare[primary] ?? 'Rare';
        final sfx = bonuses.length > 1 ? (_suffixRare[bonuses.last.stat] ?? 'Power') : '';
        return sfx.isEmpty ? '$pfx $baseName' : '$pfx $baseName of $sfx';
      case ItemRarity.epic:
        final pfx = _prefixEpic[primary] ?? 'Epic';
        final sfx = bonuses.length > 1 ? (_suffixEpic[bonuses.last.stat] ?? 'the Abyss') : '';
        return sfx.isEmpty ? '$pfx $baseName' : '$pfx $baseName of $sfx';
      case ItemRarity.legendary:
        return 'Mythic $baseName';
      case ItemRarity.set:
        return baseName; // caller provides the set-prefixed name
    }
  }

  static List<String> _namesFor(ItemSlot slot) => switch (slot) {
    ItemSlot.weapon  => _weaponNames,
    ItemSlot.offHand => _offHandNames,
    ItemSlot.helmet  => _helmetNames,
    ItemSlot.armor   => _armorNames,
    ItemSlot.gloves  => _glovesNames,
    ItemSlot.pants   => _pantsNames,
    ItemSlot.boots   => _bootsNames,
    ItemSlot.ring    => _ringNames,
    ItemSlot.ring2   => _ringNames,
    ItemSlot.amulet  => _amuletNames,
    ItemSlot.relic   => _relicNames,
  };

  static List<ItemStat> _statsFor(ItemSlot slot) => switch (slot) {
    ItemSlot.weapon  => _weaponStats,
    ItemSlot.offHand => _offHandStats,
    ItemSlot.helmet  => _helmetStats,
    ItemSlot.armor   => _armorStats,
    ItemSlot.gloves  => _glovesStats,
    ItemSlot.pants   => _pantsStats,
    ItemSlot.boots   => _bootsStats,
    ItemSlot.ring    => _accessoryStats,
    ItemSlot.ring2   => _accessoryStats,
    ItemSlot.amulet  => _accessoryStats,
    ItemSlot.relic   => _relicStats,
  };

  // ── tryDrop: regular combat drop ──────────────────────────────────────────
  static EquipmentItem? tryDrop(int enemyLevel, Random rng) {
    final dropChance = (3 + enemyLevel * 0.5).clamp(3.0, 15.0);
    if (rng.nextInt(100) >= dropChance) return null;

    final rarityRoll = rng.nextInt(100);
    final rarity = rarityRoll < 5  ? ItemRarity.epic
                 : rarityRoll < 25 ? ItemRarity.rare
                 : ItemRarity.common;

    final slot     = ItemSlot.values[rng.nextInt(ItemSlot.values.length)];
    final pool     = _statsFor(slot);
    final baseName = _namesFor(slot)[rng.nextInt(_namesFor(slot).length)];
    final count    = rarity == ItemRarity.common ? 1 : 2;
    final bonuses  = _pickBonuses(pool, count, rarity, enemyLevel, rng);

    return EquipmentItem(
      id: '${slot.name}_${rng.nextInt(999999)}',
      name: _buildName(bonuses, rarity, baseName),
      slot: slot, rarity: rarity, bonuses: bonuses,
      levelRequired: max(1, enemyLevel - 2),
    );
  }

  // ── tryDropLegendary: 1% chance on boss kills ─────────────────────────────
  static EquipmentItem? tryDropLegendary(int heroLevel, Random rng) {
    if (rng.nextInt(100) >= 1) return null;

    final slot     = ItemSlot.values[rng.nextInt(ItemSlot.values.length)];
    final pool     = _statsFor(slot);
    final baseName = _namesFor(slot)[rng.nextInt(_namesFor(slot).length)];
    // Legendary items can roll any keyword including legendary-exclusive ones
    final keyword  = ItemKeyword.values[rng.nextInt(ItemKeyword.values.length)];
    final count    = min(3, pool.length);
    final bonuses  = _pickBonuses(pool, count, ItemRarity.legendary, heroLevel, rng);

    return EquipmentItem(
      id: '${slot.name}_legendary_${rng.nextInt(999999)}',
      name: _buildName(bonuses, ItemRarity.legendary, baseName, keyword),
      slot: slot, rarity: ItemRarity.legendary, bonuses: bonuses,
      levelRequired: max(1, heroLevel - 3), keyword: keyword,
    );
  }

  // ── tryDropSet: 0.3% chance on boss kills — very rare ────────────────────
  static EquipmentItem? tryDropSet(int heroLevel, Random rng) {
    if (rng.nextInt(1000) >= 3) return null;

    // Pick a random set, then a random slot from that set
    final set      = kSetCatalog[rng.nextInt(kSetCatalog.length)];
    final slot     = set.slots[rng.nextInt(set.slots.length)];
    final pool     = _statsFor(slot);
    final baseName = '${set.name} ${_namesFor(slot)[rng.nextInt(_namesFor(slot).length)]}';
    final count    = min(2, pool.length);
    final bonuses  = _pickBonuses(pool, count, ItemRarity.epic, heroLevel, rng);

    return EquipmentItem(
      id: '${slot.name}_set_${set.id}_${rng.nextInt(999999)}',
      name: baseName,
      slot: slot, rarity: ItemRarity.set, bonuses: bonuses,
      levelRequired: max(1, heroLevel - 2), setId: set.id,
    );
  }

  // ── craftAt: forge / shop / dungeon-chest ─────────────────────────────────
  static EquipmentItem craftAt(ItemSlot slot, ItemRarity rarity, int heroLevel, Random rng) {
    final pool     = _statsFor(slot);
    final baseName = _namesFor(slot)[rng.nextInt(_namesFor(slot).length)];
    final count = switch (rarity) {
      ItemRarity.legendary => min(3, pool.length),
      ItemRarity.epic      => 2,
      ItemRarity.rare      => 2,
      ItemRarity.common    => 1,
      ItemRarity.set       => 2,
    };
    ItemKeyword? keyword;
    if (rarity == ItemRarity.legendary) {
      keyword = ItemKeyword.values[rng.nextInt(ItemKeyword.values.length)];
    }
    final bonuses = _pickBonuses(pool, count, rarity, heroLevel, rng);
    return EquipmentItem(
      id: '${slot.name}_forged_${rng.nextInt(999999)}',
      name: _buildName(bonuses, rarity, baseName, keyword),
      slot: slot, rarity: rarity, bonuses: bonuses,
      levelRequired: max(1, heroLevel - 2), keyword: keyword,
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────
  static List<StatBonus> _pickBonuses(List<ItemStat> pool, int count, ItemRarity rarity, int level, Random rng) {
    final bonuses = <StatBonus>[];
    final used    = <ItemStat>{};
    for (var i = 0; i < count; i++) {
      ItemStat stat;
      var attempts = 0;
      do {
        stat = pool[rng.nextInt(pool.length)];
        attempts++;
      } while (used.contains(stat) && attempts < 30);
      used.add(stat);
      bonuses.add(StatBonus(stat, _baseValue(stat, rarity, level, rng)));
    }
    return bonuses;
  }

  static int _baseValue(ItemStat stat, ItemRarity rarity, int level, Random rng) {
    final m = switch (rarity) {
      ItemRarity.legendary => 3,
      ItemRarity.set       => 2,
      ItemRarity.epic      => 2,
      ItemRarity.rare      => 1,
      ItemRarity.common    => 0,
    };
    return switch (stat) {
      ItemStat.attackBonus  => 1 + m + rng.nextInt(2),
      ItemStat.damageBonus  => 1 + m + rng.nextInt(2),
      ItemStat.armorClass   => 1 + m,
      ItemStat.strength     => 1 + m,
      ItemStat.dexterity    => 1 + m,
      ItemStat.constitution => 1 + m,
      ItemStat.intelligence => 1 + m,
      ItemStat.wisdom       => 1 + m,
      ItemStat.charisma     => 1 + m,
      ItemStat.maxHpPct     => 5 + m * 5,
      ItemStat.goldPct      => 5 + m * 5,
      ItemStat.xpPct        => 5 + m * 5,
    };
  }

  // Reroll all bonus values in-place, keeping the same stats.
  static void rerollBonuses(EquipmentItem item, int level, Random rng) {
    final rerolled = item.bonuses
        .map((b) => StatBonus(b.stat, _baseValue(b.stat, item.rarity, level, rng)))
        .toList();
    item.bonuses
      ..clear()
      ..addAll(rerolled);
  }

  static ({int gold, int shards}) reforgeCost(ItemRarity rarity) =>
      switch (rarity) {
        ItemRarity.rare      => (gold: 200,  shards: 20),
        ItemRarity.epic      => (gold: 600,  shards: 50),
        ItemRarity.legendary => (gold: 1800, shards: 120),
        _                    => (gold: 0,    shards: 0),
      };

  static bool canReforge(ItemRarity rarity) =>
      rarity == ItemRarity.rare || rarity == ItemRarity.epic || rarity == ItemRarity.legendary;
}

// ─────────────────────────────────────────────────────────────────────────────
// EquipmentInventory
// ─────────────────────────────────────────────────────────────────────────────

class EquipmentInventory {
  EquipmentInventory();

  final Map<ItemSlot, EquipmentItem> equipped = {};
  final List<EquipmentItem> bag = [];
  int bagCapacity = 20; // base 20; grows with purchased stash tabs

  void addToBag(EquipmentItem item) {
    if (bag.length >= bagCapacity) bag.removeAt(0);
    bag.add(item);
  }

  void equip(EquipmentItem item) {
    final old = equipped[item.slot];
    if (old != null) addToBag(old);
    equipped[item.slot] = item;
    bag.remove(item);
  }

  void unequip(ItemSlot slot) {
    final item = equipped.remove(slot);
    if (item != null) addToBag(item);
  }

  void discardFromBag(int index) {
    if (index >= 0 && index < bag.length) bag.removeAt(index);
  }

  int totalOf(ItemStat stat) {
    return equipped.values
        .expand((item) => item.bonuses)
        .where((b) => b.stat == stat)
        .fold(0, (sum, b) => sum + b.value);
  }

  int setCount(String setId) =>
      equipped.values.where((i) => i.setId == setId).length;

  Map<String, dynamic> toJson() => {
    'equipped': equipped.map((k, v) => MapEntry(k.name, v.toJson())),
    'bag': bag.map((i) => i.toJson()).toList(),
  };

  void loadFromJson(Map<String, dynamic> json) {
    equipped.clear();
    bag.clear();
    if (json['equipped'] != null) {
      (json['equipped'] as Map<String, dynamic>).forEach((k, v) {
        final slot = ItemSlot.values.firstWhere((s) => s.name == k,
            orElse: () => ItemSlot.weapon);
        equipped[slot] = EquipmentItem.fromJson(v as Map<String, dynamic>);
      });
    }
    if (json['bag'] != null) {
      bag.addAll((json['bag'] as List<dynamic>)
          .map((i) => EquipmentItem.fromJson(i as Map<String, dynamic>)));
    }
  }

  void reset() {
    equipped.clear();
    bag.clear();
  }
}
