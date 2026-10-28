import 'dart:math';
import 'package:flutter/material.dart';
import 'gem.dart';
import 'dnd_class.dart';
import 'hero_ability.dart';

enum ItemSlot { weapon, offHand, helmet, armor, gloves, pants, boots, ring, ring2, amulet, relic }
enum ItemRarity { common, uncommon, rare, epic, legendary, mythic, set, unique, ascended, primordial, eternal, transcendent }
enum ItemStat {
  strength, dexterity, constitution, intelligence, wisdom, charisma,
  attackBonus, damageBonus, armorClass, maxHpPct, goldPct, xpPct,
  elemPenetration, damagePercent,
  healRating, // flat Heal Rating — all healing scales off this (see game_state)
}

extension ItemStatInfo on ItemStat {
  String get shortLabel => switch (this) {
    ItemStat.attackBonus  => 'CRIT',
    ItemStat.damageBonus  => 'DMG',
    ItemStat.armorClass   => 'AC',
    ItemStat.strength     => 'STR',
    ItemStat.dexterity    => 'DEX',
    ItemStat.constitution => 'CON',
    ItemStat.intelligence => 'INT',
    ItemStat.wisdom       => 'WIS',
    ItemStat.charisma     => 'CHA',
    ItemStat.maxHpPct        => '%HP',
    ItemStat.goldPct         => '%G',
    ItemStat.xpPct           => '%XP',
    ItemStat.elemPenetration => 'PEN',
    ItemStat.damagePercent   => '%DMG',
    ItemStat.healRating      => 'HEAL',
  };

  /// Full readable name, e.g. 'Focus (Wisdom)'. Used in tooltips so the cryptic
  /// short codes (FOC, ARC, PEN…) are explained.
  String get fullLabel => switch (this) {
    ItemStat.attackBonus     => 'Crit Chance',
    ItemStat.damageBonus     => 'Flat Damage',
    ItemStat.armorClass      => 'Armor',
    ItemStat.strength        => 'Strength',
    ItemStat.dexterity       => 'Dexterity',
    ItemStat.constitution    => 'Constitution',
    ItemStat.intelligence    => 'Intelligence',
    ItemStat.wisdom          => 'Wisdom',
    ItemStat.charisma        => 'Charisma',
    ItemStat.maxHpPct        => 'Max HP %',
    ItemStat.goldPct         => 'Gold Find %',
    ItemStat.xpPct           => 'XP Gain %',
    ItemStat.elemPenetration => 'Elemental Penetration',
    ItemStat.damagePercent   => 'All Damage %',
    ItemStat.healRating      => 'Heal Rating',
  };

  /// One-line explanation of what the stat does in combat. Used in tooltips.
  String get description => switch (this) {
    ItemStat.attackBonus  => '+2% critical hit chance per point.',
    ItemStat.damageBonus  => 'Flat damage added to every hit.',
    ItemStat.armorClass   => 'Reduces incoming physical damage.',
    ItemStat.strength     => 'Adds flat hit damage and armor.',
    ItemStat.dexterity    => 'Adds crit chance and dodge chance.',
    ItemStat.constitution => 'Adds HP regen and poison damage.',
    ItemStat.intelligence => 'Boosts damage-over-time and void damage.',
    ItemStat.wisdom       => 'Strengthens healing and cold damage.',
    ItemStat.charisma     => 'Adds gold, fire damage, and ability-reset chance.',
    ItemStat.maxHpPct     => 'Increases your maximum health.',
    ItemStat.goldPct      => 'Increases gold earned from kills.',
    ItemStat.xpPct        => 'Increases experience earned.',
    ItemStat.elemPenetration => 'Ignores a % of enemy elemental resistance.',
    ItemStat.damagePercent   => 'Multiplies your final damage output.',
    ItemStat.healRating      => 'Increases all healing you receive.',
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

  // ── Shadowstalker: Assassination & Critical Precision ───────────────────────
  // Theme: every strike counts — crit-focused, massive burst damage on full set
  ItemSet(
    id: 'shadowstalker', name: 'Shadowstalker',
    color: Color(0xFF00ee88),
    slots: [ItemSlot.weapon, ItemSlot.gloves, ItemSlot.boots, ItemSlot.armor, ItemSlot.helmet, ItemSlot.pants],
    tiers: [
      SetBonus(piecesRequired: 2, bonuses: [
        StatBonus(ItemStat.attackBonus, 4),    // +8% crit chance
        StatBonus(ItemStat.dexterity, 5),
      ]),
      SetBonus(piecesRequired: 4, bonuses: [
        StatBonus(ItemStat.attackBonus, 18),   // +36% crit (was 10 CRIT + 8 HIT)
        StatBonus(ItemStat.dexterity, 10),
        StatBonus(ItemStat.damageBonus, 20),
      ]),
      SetBonus(piecesRequired: 6, bonuses: [
        StatBonus(ItemStat.attackBonus, 33),   // +66% crit (was 18 CRIT + 15 HIT)
        StatBonus(ItemStat.dexterity, 18),
        StatBonus(ItemStat.damageBonus, 45),
        StatBonus(ItemStat.damagePercent, 40), // +40% all damage
      ]),
    ],
  ),

  // ── Ironclad: Unbreakable Fortress ─────────────────────────────────────────
  // Theme: survive anything — massive armor, HP, and regen; enemies barely dent you
  ItemSet(
    id: 'ironclad', name: 'Ironclad',
    color: Color(0xFF88bbee),
    slots: [ItemSlot.helmet, ItemSlot.armor, ItemSlot.pants, ItemSlot.offHand, ItemSlot.boots, ItemSlot.gloves],
    tiers: [
      SetBonus(piecesRequired: 2, bonuses: [
        StatBonus(ItemStat.armorClass, 10),
        StatBonus(ItemStat.constitution, 8),
        StatBonus(ItemStat.maxHpPct, 10),
      ]),
      SetBonus(piecesRequired: 4, bonuses: [
        StatBonus(ItemStat.armorClass, 22),
        StatBonus(ItemStat.constitution, 15),
        StatBonus(ItemStat.maxHpPct, 25),
        StatBonus(ItemStat.damagePercent, 15), // "strength through endurance"
      ]),
      SetBonus(piecesRequired: 6, bonuses: [
        StatBonus(ItemStat.armorClass, 40),    // 40 flat DR — nearly immune to normals
        StatBonus(ItemStat.constitution, 25),
        StatBonus(ItemStat.maxHpPct, 50),      // +50% max HP
        StatBonus(ItemStat.damagePercent, 30),
        StatBonus(ItemStat.damageBonus, 20),   // "wall of iron strikes back"
      ]),
    ],
  ),

  // ── Goldweaver: Fortune's Favorite ──────────────────────────────────────────
  // Theme: obscene wealth generation — gold, XP, shards all massively boosted
  ItemSet(
    id: 'goldweaver', name: 'Goldweaver',
    color: Color(0xFFffcc00),
    slots: [ItemSlot.ring, ItemSlot.ring2, ItemSlot.amulet, ItemSlot.relic, ItemSlot.helmet, ItemSlot.boots],
    tiers: [
      SetBonus(piecesRequired: 2, bonuses: [
        StatBonus(ItemStat.goldPct, 40),
        StatBonus(ItemStat.xpPct, 25),
        StatBonus(ItemStat.charisma, 5),
      ]),
      SetBonus(piecesRequired: 4, bonuses: [
        StatBonus(ItemStat.goldPct, 90),
        StatBonus(ItemStat.xpPct, 60),
        StatBonus(ItemStat.charisma, 12),
        StatBonus(ItemStat.attackBonus, 5),    // "fortune fuels power" +10% crit
      ]),
      SetBonus(piecesRequired: 6, bonuses: [
        StatBonus(ItemStat.goldPct, 175),      // +175% gold (nearly triple)
        StatBonus(ItemStat.xpPct, 120),        // +120% XP (more than double)
        StatBonus(ItemStat.charisma, 20),
        StatBonus(ItemStat.attackBonus, 12),   // +24% crit — "lucky strikes"
        StatBonus(ItemStat.damagePercent, 25), // "wealth empowers"
        StatBonus(ItemStat.maxHpPct, 20),
      ]),
    ],
  ),

  // ── Stormcaller: Elemental Devastation ──────────────────────────────────────
  // Theme: pure elemental destruction — bypasses armor, massive damage multipliers
  ItemSet(
    id: 'stormcaller', name: 'Stormcaller',
    color: Color(0xFFeecc00),
    slots: [ItemSlot.weapon, ItemSlot.offHand, ItemSlot.helmet, ItemSlot.armor, ItemSlot.amulet, ItemSlot.ring],
    tiers: [
      SetBonus(piecesRequired: 2, bonuses: [
        StatBonus(ItemStat.damageBonus, 15),
        StatBonus(ItemStat.strength, 8),
        StatBonus(ItemStat.elemPenetration, 10),
      ]),
      SetBonus(piecesRequired: 4, bonuses: [
        StatBonus(ItemStat.damageBonus, 35),
        StatBonus(ItemStat.strength, 15),
        StatBonus(ItemStat.elemPenetration, 20),
        StatBonus(ItemStat.damagePercent, 25),
      ]),
      SetBonus(piecesRequired: 6, bonuses: [
        StatBonus(ItemStat.damageBonus, 70),   // massive flat damage
        StatBonus(ItemStat.strength, 25),
        StatBonus(ItemStat.elemPenetration, 35), // 35 armor pen — ignores most DR
        StatBonus(ItemStat.damagePercent, 55),  // +55% all damage
        StatBonus(ItemStat.attackBonus, 8),     // +16% crit
        StatBonus(ItemStat.maxHpPct, 15),
      ]),
    ],
  ),

  // ── Wraithbound: Void Ascendant ──────────────────────────────────────────────
  // Theme: mystical void power — elemental mastery, arcane penetration, wisdom
  ItemSet(
    id: 'wraithbound', name: 'Wraithbound',
    color: Color(0xFFaa44ff),
    slots: [ItemSlot.weapon, ItemSlot.pants, ItemSlot.boots, ItemSlot.ring2, ItemSlot.relic, ItemSlot.gloves],
    tiers: [
      SetBonus(piecesRequired: 2, bonuses: [
        StatBonus(ItemStat.attackBonus, 5),    // +10% crit
        StatBonus(ItemStat.wisdom, 8),
        StatBonus(ItemStat.elemPenetration, 8),
      ]),
      SetBonus(piecesRequired: 4, bonuses: [
        StatBonus(ItemStat.attackBonus, 12),   // +24% crit
        StatBonus(ItemStat.wisdom, 15),
        StatBonus(ItemStat.elemPenetration, 18),
        StatBonus(ItemStat.damagePercent, 20),
        StatBonus(ItemStat.intelligence, 10),
      ]),
      SetBonus(piecesRequired: 6, bonuses: [
        StatBonus(ItemStat.attackBonus, 22),   // +44% crit — "void sight"
        StatBonus(ItemStat.wisdom, 25),
        StatBonus(ItemStat.elemPenetration, 30), // 30 armor pen — void bypasses everything
        StatBonus(ItemStat.damagePercent, 45),
        StatBonus(ItemStat.intelligence, 18),
        StatBonus(ItemStat.damageBonus, 35),
        StatBonus(ItemStat.maxHpPct, 20),
      ]),
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
    this.baseDamage = 0,
    this.rebirthRequired = 0,
    this.keyword,
    this.setId,
    this.gem,
    this.socketedRuneId,
    this.requiredClass,
    this.uniqueAbilityId,
    this.abilityValueMult = 1.0,
    this.abilityCooldownFlat = 0,
    this.abilityExtraEffect,
    this.abilityExtraValue = 0,
    this.abilityExtraDuration = 0,
    this.abilityDurationAdd = 0,
  });

  final String id;
  String name;
  final ItemSlot slot;
  final ItemRarity rarity;
  List<StatBonus> bonuses;
  final int levelRequired;
  int baseDamage;
  final int rebirthRequired;
  int upgradeTier = 0; // 0-10
  final ItemKeyword? keyword;
  final String? setId;
  Gem? gem; // mutable socket — 1 gem per item
  String? socketedRuneId; // ability rune — only for rings/amulets
  bool locked = false; // locked items can't be disenchanted

  // ── Unique legendary class-restricted fields ───────────────────────────────
  final DndClass? requiredClass;    // null = equippable by all classes
  final String? uniqueAbilityId;   // ability ID this item modifies
  final double abilityValueMult;   // multiplier for ability's main value
  final int abilityCooldownFlat;   // flat cooldown reduction
  final AbilityEffect? abilityExtraEffect; // bonus effect applied on cast
  final int abilityExtraValue;     // value for the bonus effect
  final int abilityExtraDuration;  // duration for the bonus effect
  final int abilityDurationAdd;    // added to ability's effectiveDuration

  ItemSet? get itemSet => setId == null
      ? null
      : kSetCatalog.where((s) => s.id == setId).firstOrNull;

  String get rarityLabel => switch (rarity) {
    ItemRarity.common    => 'Common',
    ItemRarity.uncommon  => 'Uncommon',
    ItemRarity.rare      => 'Rare',
    ItemRarity.epic      => 'Epic',
    ItemRarity.legendary => 'Legendary',
    ItemRarity.mythic    => 'Mythic',
    ItemRarity.set       => 'Set',
    ItemRarity.unique    => 'Unique',
    ItemRarity.ascended     => 'Ascended',
    ItemRarity.primordial   => 'Primordial',
    ItemRarity.eternal      => 'Eternal',
    ItemRarity.transcendent => 'Transcendent',
  };

  /// Canonical art type inferred from the item name, used to pick a pixel-art
  /// sprite (bow, staff, orb, robe, …) instead of one generic icon per slot.
  /// Works for both freshly-rolled class items and legacy saved gear.
  String get itemTypeKey {
    final n = name.toLowerCase();
    bool has(String s) => n.contains(s);
    switch (slot) {
      case ItemSlot.weapon:
        if (has('crossbow')) return 'crossbow';
        if (has('bow')) return 'bow';
        if (has('axe') || has('cleaver')) return 'axe';
        if (has('maul') || has('hammer') || has('mace') || has('morningstar') ||
            has('flail') || has('cudgel') || has('club')) return 'mace';
        if (has('dagger') || has('dirk') || has('stiletto') || has('kris') ||
            has('shadowblade')) return 'dagger';
        if (has('staff') || has('nunchaku') || has('tonfa') || has('fist')) return 'staff';
        if (has('wand') || has('rod') || has('scepter')) return 'wand';
        if (has('halberd') || has('glaive') || has('spear') || has('pike') ||
            has('sickle') || has('scythe')) return 'spear';
        return 'sword'; // longsword, broadsword, rapier, saber, scimitar, blade
      case ItemSlot.offHand:
        if (has('quiver') || has('arrow') || has('bolt')) return 'quiver';
        if (has('orb') || has('crystal') || has('sigil') || has('font')) return 'orb';
        if (has('tome') || has('grimoire') || has('book')) return 'tome';
        if (has('lute') || has('lyre')) return 'lute';
        if (has('shield') || has('buckler') || has('aegis') || has('bulwark') ||
            has('kite') || has('tower') || has('heater') || has('targe')) return 'shield';
        if (has('knives') || has('knife') || has('parry')) return 'dagger';
        return 'totem'; // holy symbol, idol, charm, beads, chalice, lantern, ward…
      case ItemSlot.armor:
        if (has('robe') || has('vestment') || has('mantle') || has('raiment') ||
            has('silk') || has('gi') || has('wrapping')) return 'robe';
        if (has('scale')) return 'scale';
        if (has('leather') || has('garb') || has('doublet') || has('hide') ||
            has('weave') || has('leathers')) return 'leather';
        return 'plate'; // plate, mail, chain, breastplate, harness, faithguard
      default:
        return slot.name;
    }
  }

  /// Rough total stat budget for quick shop upgrade comparisons (not a precise
  /// DPS model — just base damage + summed stat values + a keyword bonus).
  int get statBudget =>
      baseDamage +
      bonuses.fold<int>(0, (s, b) => s + b.value) +
      (keyword != null ? 8 : 0);

  // ── Upgrade system (tier 0-10) ──────────────────────────────────────────────
  static const maxUpgradeTier = 10;

  int get upgradeGoldCost => (200 + levelRequired * 30) * (upgradeTier + 1);
  int get upgradeShardCost => (5 + levelRequired ~/ 2) * (upgradeTier + 1);

  bool get canUpgrade => upgradeTier < maxUpgradeTier;

  static const _prefixes = {
    5:  ['Refined', 'Honed', 'Tempered', 'Polished', 'Hardened'],
    10: ['Masterwork', 'Exalted', 'Perfected', 'Ascendant', 'Mythforged'],
  };

  void applyUpgrade() {
    if (!canUpgrade) return;
    upgradeTier++;

    // Each tier: +8% to all stat bonuses + weapon base damage
    for (int i = 0; i < bonuses.length; i++) {
      final b = bonuses[i];
      bonuses[i] = StatBonus(b.stat, b.value + (b.value * 0.08).ceil().clamp(1, 999));
    }
    if (baseDamage > 0) {
      baseDamage = (baseDamage * 1.08).round();
    }

    // Milestone prefixes at tier 5 and 10
    if (_prefixes.containsKey(upgradeTier)) {
      final options = _prefixes[upgradeTier]!;
      final prefix = options[name.hashCode.abs() % options.length];
      if (!name.startsWith(prefix)) {
        name = '$prefix $name';
      }
    }
  }

  String get upgradeTierLabel => upgradeTier > 0 ? '+$upgradeTier' : '';

  bool get canSocketRune =>
      socketedRuneId == null &&
      (slot == ItemSlot.ring || slot == ItemSlot.ring2 || slot == ItemSlot.amulet);

  String get requirementLabel {
    if (rebirthRequired > 0) return 'Lv$levelRequired  ✦RB$rebirthRequired';
    return 'Lv$levelRequired';
  }

  Color get rarityColor => switch (rarity) {
    ItemRarity.common    => const Color(0xFFaaaaaa),
    ItemRarity.uncommon  => const Color(0xFF55cc55),
    ItemRarity.rare      => const Color(0xFF6699ff),
    ItemRarity.epic      => const Color(0xFFcc44ff),
    ItemRarity.legendary => const Color(0xFFFFD700),
    ItemRarity.mythic    => const Color(0xFFDD1111),
    ItemRarity.set       => itemSet?.color ?? const Color(0xFF00cc88),
    ItemRarity.unique    => const Color(0xFFE8A0FF),
    ItemRarity.ascended     => const Color(0xFFFF8A1E), // molten amber
    ItemRarity.primordial   => const Color(0xFF17E0A8), // emerald teal
    ItemRarity.eternal      => const Color(0xFF36C6FF), // radiant cyan
    ItemRarity.transcendent => const Color(0xFFFFF4D6), // prismatic white-gold
  };

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slot': slot.name,
    'rarity': rarity.name,
    'bonuses': bonuses.map((b) => {'stat': b.stat.name, 'value': b.value}).toList(),
    'levelRequired': levelRequired,
    if (baseDamage > 0) 'baseDamage': baseDamage,
    if (upgradeTier > 0) 'upgradeTier': upgradeTier,
    if (socketedRuneId != null) 'socketedRuneId': socketedRuneId,
    if (rebirthRequired > 0) 'rebirthRequired': rebirthRequired,
    if (locked) 'locked': true,
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
      bonuses: (json['bonuses'] as List).map((b) {
        final m = Map<String, dynamic>.from(b as Map);
        // Legacy migration: 'hitChance' (HIT) was a redundant crit source,
        // identical to attackBonus (CRIT). Fold old items into attackBonus so
        // saved gear keeps the exact same crit value.
        var statName = m['stat'] as String;
        if (statName == 'hitChance') statName = 'attackBonus';
        return StatBonus(
          ItemStat.values.firstWhere((s) => s.name == statName,
              orElse: () => ItemStat.attackBonus),
          m['value'] as int,
        );
      }).toList(),
      levelRequired: json['levelRequired'] as int,
      baseDamage: (json['baseDamage'] as int?) ?? 0,
      rebirthRequired: (json['rebirthRequired'] as int?) ?? 0,
      keyword: kwStr != null
          ? ItemKeyword.values.firstWhere((k) => k.name == kwStr,
              orElse: () => ItemKeyword.lifeSteal)
          : null,
      setId: setStr,
      gem: json['gem'] != null
          ? Gem.fromJson(Map<String, dynamic>.from(json['gem'] as Map))
          : null,
    )..locked = (json['locked'] as bool?) ?? false
     ..upgradeTier = (json['upgradeTier'] as int?) ?? 0
     ..socketedRuneId = json['socketedRuneId'] as String?;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ItemLootTable
// ─────────────────────────────────────────────────────────────────────────────

class ItemLootTable {
  /// Magic Find: each difficulty tier shifts a combat drop's rarity roll up by
  /// this many points (i.e. +this% chance to land in a higher rarity band).
  /// Surfaced in the tier picker so players see the payoff of climbing.
  static const int kMagicFindPerTier = 3;

  /// Active hero's class — kept in sync by game_state (see loadCharacter). Drops
  /// use it to pick class-appropriate base types: a Ranger finds bows & quivers,
  /// a Wizard finds staffs & orbs, each class its own armour (robes/plate/…).
  static DndClass lootClass = DndClass.fighter;

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

  // ── Class-specific base types ───────────────────────────────────────────────
  // The weapon, off-hand and body-armour a hero finds reflect their class, so a
  // Ranger pulls bows + quivers + leather, a Wizard pulls staffs + orbs + robes,
  // and so on. A material adjective ([_materials]) is prefixed at roll time to
  // keep the existing dark-fantasy name variety ("Void Longbow", "Runic Robes").
  static const _materials = ['Iron', 'Bone', 'Shadow', 'Cursed', 'Runic', 'Void', 'Hex', 'Grim'];

  static const _classWeaponTypes = <DndClass, List<String>>{
    DndClass.barbarian: ['Greataxe', 'Warmaul', 'Cleaver', 'Greatsword', 'Berserker Axe'],
    DndClass.fighter:   ['Longsword', 'Battleaxe', 'Broadsword', 'War Flail', 'Halberd'],
    DndClass.paladin:   ['Longsword', 'Warhammer', 'Blessed Mace', 'Flail', 'Greatblade'],
    DndClass.ranger:    ['Longbow', 'Shortbow', 'Crossbow', 'Hunting Bow', 'Recurve Bow'],
    DndClass.rogue:     ['Dagger', 'Dirk', 'Stiletto', 'Kris', 'Shadowblade'],
    DndClass.monk:      ['Bo Staff', 'Nunchaku', 'Tonfa', 'Fist Wraps', 'Spirit Staff'],
    DndClass.bard:      ['Rapier', 'Shortsword', 'Saber', 'Court Blade', 'Dueling Dagger'],
    DndClass.druid:     ['Quarterstaff', 'Scimitar', 'Thornstaff', 'War Sickle', 'Oaken Club'],
    DndClass.cleric:    ['Warhammer', 'Mace', 'Morningstar', 'Flail', 'Cudgel'],
    DndClass.wizard:    ['Staff', 'Wand', 'Runestaff', 'Spellstaff', 'Arcane Rod'],
    DndClass.sorcerer:  ['Wand', 'Scepter', 'Chaos Rod', 'Focus Staff', 'Dragon Wand'],
    DndClass.warlock:   ['Eldritch Staff', 'Pact Rod', 'Grimscepter', 'Soul Wand', 'Doomstaff'],
  };

  static const _classOffHandTypes = <DndClass, List<String>>{
    DndClass.barbarian: ['War Shield', 'Bone Totem', 'Skull Ward', 'Hide Guard'],
    DndClass.fighter:   ['Kite Shield', 'Tower Shield', 'Buckler', 'Heater Shield'],
    DndClass.paladin:   ['Holy Shield', 'Aegis', 'Blessed Bulwark', 'Faith Ward'],
    DndClass.ranger:    ['Quiver', 'Arrow Case', 'Bolt Pouch', 'Beast Trophy'],
    DndClass.rogue:     ['Parry Dagger', 'Throwing Knives', 'Smoke Pouch', 'Shadow Wrap'],
    DndClass.monk:      ['Prayer Beads', 'Ki Focus', 'Meditation Charm', 'Spirit Band'],
    DndClass.bard:      ['Lute', 'Lyre', 'Songbook', 'Harmony Charm'],
    DndClass.druid:     ['Oaken Totem', 'Wild Idol', 'Spirit Charm', 'Barkward'],
    DndClass.cleric:    ['Holy Symbol', 'Prayer Book', 'Sacred Chalice', 'Divine Ward'],
    DndClass.wizard:    ['Spell Tome', 'Arcane Orb', 'Grimoire', 'Focus Crystal'],
    DndClass.sorcerer:  ['Arcane Orb', 'Chaos Crystal', 'Power Font', 'Dragon Sigil'],
    DndClass.warlock:   ['Grimoire', 'Eldritch Orb', 'Pact Sigil', 'Soul Lantern'],
  };

  static const _classArmorTypes = <DndClass, List<String>>{
    DndClass.barbarian: ['Hide Plate', 'Chainmail', 'Battleplate', 'War Harness'],
    DndClass.fighter:   ['Plate Mail', 'Chainmail', 'Breastplate', 'Full Plate'],
    DndClass.paladin:   ['Holy Plate', 'Blessed Mail', 'Breastplate', 'Templar Plate'],
    DndClass.ranger:    ['Leather Armor', 'Studded Leather', "Ranger's Garb", 'Hide Vest'],
    DndClass.rogue:     ['Leather Armor', 'Shadowweave', 'Studded Leather', 'Silent Garb'],
    DndClass.monk:      ['Monk Robes', 'Training Gi', 'Spirit Wrappings', 'Ki Vestments'],
    DndClass.bard:      ["Performer's Leathers", 'Fine Doublet', 'Studded Leather', 'Silk Garb'],
    DndClass.druid:     ['Hide Armor', 'Bark Vestments', 'Wildweave', 'Scalecoat'],
    DndClass.cleric:    ['Scale Mail', 'Priest Plate', 'Blessed Scale', 'Faithguard'],
    DndClass.wizard:    ['Arcane Robes', 'Spellweave Robes', 'Mystic Mantle', 'Silk Raiment'],
    DndClass.sorcerer:  ['Sorcerer Robes', 'Dragon Silk', 'Chaos Vestments', 'Arcane Mantle'],
    DndClass.warlock:   ['Pact Robes', 'Eldritch Vestments', 'Shadow Mantle', 'Occult Raiment'],
  };

  // ── Stat pools per slot ────────────────────────────────────────────────────
  // The six attributes (STR/DEX/CON/INT/WIS/CHA) each map to a damage type +
  // resistance, so they're spread evenly (3–4 slots each) — every element build
  // can gear its stat. STR (universal weapon power) sits on weapon + armour/gloves;
  // INT/CHA are no longer accessory-only.
  static const _weaponStats   = [ItemStat.attackBonus, ItemStat.damageBonus, ItemStat.strength, ItemStat.elemPenetration, ItemStat.damagePercent];
  static const _offHandStats  = [ItemStat.armorClass, ItemStat.attackBonus, ItemStat.constitution, ItemStat.intelligence];
  static const _helmetStats   = [ItemStat.armorClass, ItemStat.healRating, ItemStat.wisdom, ItemStat.charisma];
  static const _armorStats    = [ItemStat.armorClass, ItemStat.maxHpPct, ItemStat.constitution, ItemStat.strength];
  static const _glovesStats   = [ItemStat.attackBonus, ItemStat.damageBonus, ItemStat.dexterity, ItemStat.strength];
  static const _pantsStats    = [ItemStat.armorClass, ItemStat.constitution, ItemStat.dexterity, ItemStat.charisma];
  static const _bootsStats    = [ItemStat.armorClass, ItemStat.dexterity, ItemStat.wisdom, ItemStat.intelligence];
  static const _accessoryStats = [ItemStat.goldPct, ItemStat.xpPct, ItemStat.wisdom, ItemStat.intelligence, ItemStat.charisma, ItemStat.dexterity, ItemStat.attackBonus, ItemStat.elemPenetration, ItemStat.damagePercent, ItemStat.healRating];
  static const _relicStats    = [ItemStat.goldPct, ItemStat.xpPct, ItemStat.wisdom, ItemStat.intelligence, ItemStat.charisma, ItemStat.strength, ItemStat.elemPenetration, ItemStat.healRating];

  // ── Affix prefix/suffix tables (common, rare, epic) ───────────────────────
  static const _prefixCommon = {
    ItemStat.attackBonus:     'Keen',      ItemStat.damageBonus:  'Sharp',       ItemStat.armorClass:      'Guard',
    ItemStat.strength:        'Strong',    ItemStat.dexterity:    'Quick',       ItemStat.constitution:    'Tough',
    ItemStat.intelligence:    'Arcane',    ItemStat.wisdom:       'Sage',        ItemStat.charisma:        'Bold',
    ItemStat.maxHpPct:        'Hearty',    ItemStat.goldPct:      'Lucky',       ItemStat.xpPct:           'Learned',
    ItemStat.elemPenetration: 'Seeping',
    ItemStat.damagePercent:   'Vicious',
  };
  static const _prefixRare = {
    ItemStat.attackBonus:     'Keen',       ItemStat.damageBonus:  'Savage',     ItemStat.armorClass:      'Stalwart',
    ItemStat.strength:        'Mighty',     ItemStat.dexterity:    'Swift',      ItemStat.constitution:    'Hardy',
    ItemStat.intelligence:    'Mystic',     ItemStat.wisdom:       'Ancient',    ItemStat.charisma:        'Commanding',
    ItemStat.maxHpPct:        'Vital',      ItemStat.goldPct:      'Prosperous', ItemStat.xpPct:           "Veteran's",
    ItemStat.elemPenetration: 'Piercing',
    ItemStat.damagePercent:   'Savage',
  };
  static const _prefixEpic = {
    ItemStat.attackBonus:     'Deadly',     ItemStat.damageBonus:  'Brutal',     ItemStat.armorClass:      'Fortified',
    ItemStat.strength:        "Titan's",    ItemStat.dexterity:    'Shadow',     ItemStat.constitution:    'Stone',
    ItemStat.intelligence:    'Elder',       ItemStat.wisdom:       'Eternal',   ItemStat.charisma:        'Glorious',
    ItemStat.maxHpPct:        'Ironhide',   ItemStat.goldPct:      "Fortune's",  ItemStat.xpPct:           'Enlightened',
    ItemStat.elemPenetration: 'Veilbreaker',
    ItemStat.damagePercent:   'Ruinous',
  };
  static const _suffixRare = {
    ItemStat.attackBonus:     'Striking',   ItemStat.damageBonus:  'Ruin',       ItemStat.armorClass:      'Warding',
    ItemStat.strength:        'Might',      ItemStat.dexterity:    'Agility',    ItemStat.constitution:    'Endurance',
    ItemStat.intelligence:    'Arcana',     ItemStat.wisdom:       'Foresight',  ItemStat.charisma:        'Command',
    ItemStat.maxHpPct:        'Vitality',   ItemStat.goldPct:      'Fortune',    ItemStat.xpPct:           'Wisdom',
    ItemStat.elemPenetration: 'Penetration',
    ItemStat.damagePercent:   'Carnage',
  };
  static const _suffixEpic = {
    ItemStat.attackBonus:     'Slaughter',  ItemStat.damageBonus:  'Destruction',ItemStat.armorClass:      'the Bastion',
    ItemStat.strength:        'Dominion',   ItemStat.dexterity:    'the Void',   ItemStat.constitution:    'Eternity',
    ItemStat.intelligence:    'the Abyss',  ItemStat.wisdom:       'the Ages',   ItemStat.charisma:        'Legend',
    ItemStat.maxHpPct:        'the Colossus',ItemStat.goldPct:     'Avarice',    ItemStat.xpPct:           'Transcendence',
    ItemStat.elemPenetration: 'the Rift',
    ItemStat.damagePercent:   'Devastation',
  };
  static const _keywordTitle = {
    ItemKeyword.lifeSteal:    'Blooddrinker', ItemKeyword.riposte:     'Retaliator',
    ItemKeyword.soulHunger:   'Souleater',    ItemKeyword.vengeance:   'Vindicator',
    ItemKeyword.goldSense:    'Gleamsong',    ItemKeyword.swiftStrike: 'Quicksilver',
    ItemKeyword.criticalFury: 'Doomcaller',   ItemKeyword.ironWill:    'Ironheart',
  };

  // ── Name builder ──────────────────────────────────────────────────────────
  static String _buildName(List<StatBonus> bonuses, ItemRarity rarity, String baseName, [ItemKeyword? keyword]) {
    if ((rarity == ItemRarity.legendary || rarity == ItemRarity.mythic) && keyword != null) {
      // Fall back to a generic title if a keyword has no mapped title, so a
      // legendary/mythic drop can never crash on a missing map entry.
      final title = _keywordTitle[keyword] ?? 'Fabled';
      return rarity == ItemRarity.mythic
          ? '$title Mythic $baseName'
          : '$title $baseName';
    }
    if (bonuses.isEmpty) return baseName;
    final primary = bonuses.first.stat;
    switch (rarity) {
      case ItemRarity.common:
        final pfx = _prefixCommon[primary] ?? '';
        return pfx.isEmpty ? baseName : '$pfx $baseName';
      case ItemRarity.uncommon:
        final pfx = _prefixRare[primary] ?? 'Fine';
        return '$pfx $baseName';
      case ItemRarity.rare:
        final pfx = _prefixRare[primary] ?? 'Rare';
        final sfx = bonuses.length > 1 ? (_suffixRare[bonuses.last.stat] ?? 'Power') : '';
        final base = sfx.isNotEmpty ? baseName.split(' of ').first : baseName;
        return sfx.isEmpty ? '$pfx $base' : '$pfx $base of $sfx';
      case ItemRarity.epic:
        final pfx = _prefixEpic[primary] ?? 'Epic';
        final sfx = bonuses.length > 1 ? (_suffixEpic[bonuses.last.stat] ?? 'the Abyss') : '';
        final base = sfx.isNotEmpty ? baseName.split(' of ').first : baseName;
        return sfx.isEmpty ? '$pfx $base' : '$pfx $base of $sfx';
      case ItemRarity.legendary:
        return 'Ancient $baseName';
      case ItemRarity.mythic:
        return 'Mythic $baseName';
      case ItemRarity.set:
        return baseName; // caller provides the set-prefixed name
      case ItemRarity.unique:
        return baseName; // unique items have explicit names
      case ItemRarity.ascended:
        return 'Ascended $baseName';
      case ItemRarity.primordial:
        return 'Primordial $baseName';
      case ItemRarity.eternal:
        return 'Eternal $baseName';
      case ItemRarity.transcendent:
        return 'Transcendent $baseName';
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

  /// Base display name for a freshly-rolled item. Weapons, off-hands and body
  /// armour draw from the active class's type pool (bows for rangers, staffs for
  /// casters, …) prefixed with a material; all other slots use the shared pools.
  static String _baseName(ItemSlot slot, Random rng) {
    final types = switch (slot) {
      ItemSlot.weapon  => _classWeaponTypes[lootClass],
      ItemSlot.offHand => _classOffHandTypes[lootClass],
      ItemSlot.armor   => _classArmorTypes[lootClass],
      _                => null,
    };
    if (types != null && types.isNotEmpty) {
      final mat  = _materials[rng.nextInt(_materials.length)];
      final type = types[rng.nextInt(types.length)];
      return '$mat $type';
    }
    final pool = _namesFor(slot);
    return pool[rng.nextInt(pool.length)];
  }

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

  // ── tryDropTopRarity: post-Mythic tiers, gated + scaling by difficulty tier ──
  // Rolled on boss kills, highest-first. Each tier UNLOCKS at a minimum prestige
  // tier and its odds climb with tier, so Tier 10 is where they flow. Chances are
  // in percent-per-boss; [chanceMult] (from Remote Config) scales all of them live.
  static EquipmentItem? tryDropTopRarity(int heroLevel, Random rng,
      {int tier = 0, double chanceMult = 1.0}) {
    // (rarity, gateTier, %-per-tier-over-gate). Transcendent is flat at its gate.
    final rolls = <(ItemRarity, double)>[
      (ItemRarity.transcendent, tier >= 10 ? 0.2 + 0.1 * (tier - 10) : 0.0),
      (ItemRarity.eternal,      tier >= 8  ? 0.17 * (tier - 7) : 0.0),
      (ItemRarity.primordial,   tier >= 6  ? 0.20 * (tier - 5) : 0.0),
      (ItemRarity.ascended,     tier >= 4  ? 0.28 * (tier - 3) : 0.0),
    ];
    for (final (rarity, pct) in rolls) {
      if (pct <= 0) continue;
      if (rng.nextDouble() * 100 < pct * chanceMult) {
        final slot = ItemSlot.values[rng.nextInt(ItemSlot.values.length)];
        return craftAt(slot, rarity, heroLevel, rng, rebirthLevel: tier);
      }
    }
    return null;
  }

  // ── tryDrop: regular combat drop ──────────────────────────────────────────
  static EquipmentItem? tryDrop(int enemyLevel, Random rng, {int tier = 0}) {
    final dropChance = (30 + enemyLevel * 5.0).clamp(30.0, 100.0);
    if (rng.nextDouble() * 100 >= dropChance) return null;

    // Higher difficulty tiers bias the rarity roll upward (better loot).
    final rarityRoll = max(0, rng.nextInt(100) - tier * kMagicFindPerTier);
    final rarity = rarityRoll < 3  ? ItemRarity.epic
                 : rarityRoll < 12 ? ItemRarity.rare
                 : rarityRoll < 37 ? ItemRarity.uncommon
                 : ItemRarity.common;

    final slot     = ItemSlot.values[rng.nextInt(ItemSlot.values.length)];
    final pool     = _statsFor(slot);
    final baseName = _baseName(slot, rng);
    final count    = rarity == ItemRarity.common || rarity == ItemRarity.uncommon ? 1 : 2;
    final bonuses  = _pickBonuses(pool, count, rarity, enemyLevel, rng);

    return EquipmentItem(
      id: '${slot.name}_${rng.nextInt(999999)}',
      name: _buildName(bonuses, rarity, baseName),
      slot: slot, rarity: rarity, bonuses: bonuses,
      levelRequired: max(1, enemyLevel - 2),
    );
  }

  // ── tryDropLegendary: 1% chance on boss kills ─────────────────────────────
  static EquipmentItem? tryDropLegendary(int heroLevel, Random rng, {int tier = 0}) {
    if (rng.nextInt(100) >= 10 + tier) return null;

    final slot     = ItemSlot.values[rng.nextInt(ItemSlot.values.length)];
    final pool     = _statsFor(slot);
    final baseName = _baseName(slot, rng);
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
  static EquipmentItem? tryDropSet(int heroLevel, Random rng, {int tier = 0}) {
    if (rng.nextInt(1000) >= 30 + tier * 5) return null;

    // Pick a random set, then a random slot from that set
    final set      = kSetCatalog[rng.nextInt(kSetCatalog.length)];
    final slot     = set.slots[rng.nextInt(set.slots.length)];
    final pool     = _statsFor(slot);
    final baseName = '${set.name} ${_baseName(slot, rng)}';
    final count    = min(3, pool.length); // 6-piece sets get 3 stats per piece
    final bonuses  = _pickBonuses(pool, count, ItemRarity.epic, heroLevel, rng);

    return EquipmentItem(
      id: '${slot.name}_set_${set.id}_${rng.nextInt(999999)}',
      name: baseName,
      slot: slot, rarity: ItemRarity.set, bonuses: bonuses,
      levelRequired: max(1, heroLevel - 2), setId: set.id,
    );
  }

  // ── tryDropMythic: 0.5% chance on boss kills — rarest procedural tier ──────
  static EquipmentItem? tryDropMythic(int heroLevel, Random rng, {int tier = 0}) {
    if (rng.nextInt(1000) >= 5 + tier * 2) return null;

    final slot     = ItemSlot.values[rng.nextInt(ItemSlot.values.length)];
    final pool     = _statsFor(slot);
    final baseName = _baseName(slot, rng);
    final keyword  = ItemKeyword.values[rng.nextInt(ItemKeyword.values.length)];
    final count    = min(3, pool.length);
    final bonuses  = _pickBonuses(pool, count, ItemRarity.mythic, heroLevel, rng);

    return EquipmentItem(
      id: '${slot.name}_mythic_${rng.nextInt(999999)}',
      name: _buildName(bonuses, ItemRarity.mythic, baseName, keyword),
      slot: slot, rarity: ItemRarity.mythic, bonuses: bonuses,
      levelRequired: max(1, heroLevel - 2), keyword: keyword,
    );
  }

  // ── craftAt: forge / shop / dungeon-chest ─────────────────────────────────
  static EquipmentItem craftAt(ItemSlot slot, ItemRarity rarity, int heroLevel, Random rng,
      {int rebirthLevel = 0}) {
    final pool     = _statsFor(slot);
    final baseName = _baseName(slot, rng);
    // Base bonus count from rarity + extra from rebirth
    final baseCount = switch (rarity) {
      ItemRarity.transcendent => 6,
      ItemRarity.eternal      => 5,
      ItemRarity.primordial   => 5,
      ItemRarity.ascended     => 4,
      ItemRarity.mythic    => 4,
      ItemRarity.legendary => 3,
      ItemRarity.unique    => 3,
      ItemRarity.epic      => 2,
      ItemRarity.rare      => 2,
      ItemRarity.set       => 2,
      ItemRarity.uncommon  => 1,
      ItemRarity.common    => 1,
    };
    final count = min(baseCount + rebirthLevel, pool.length);
    ItemKeyword? keyword;
    if (rarity == ItemRarity.legendary || rarity == ItemRarity.mythic ||
        rarity == ItemRarity.ascended || rarity == ItemRarity.primordial ||
        rarity == ItemRarity.eternal || rarity == ItemRarity.transcendent) {
      keyword = ItemKeyword.values[rng.nextInt(ItemKeyword.values.length)];
    }
    final bonuses = _pickBonuses(pool, count, rarity, heroLevel, rng);
    final isWeapon = slot == ItemSlot.weapon || slot == ItemSlot.offHand;
    final weaponDmg = isWeapon ? _calcBaseDamage(slot, rarity, heroLevel, rebirthLevel) : 0;
    return EquipmentItem(
      id: '${slot.name}_forged_${rng.nextInt(999999)}',
      name: _buildName(bonuses, rarity, baseName, keyword),
      slot: slot, rarity: rarity, bonuses: bonuses,
      baseDamage: weaponDmg,
      levelRequired: max(1, heroLevel),
      rebirthRequired: rebirthLevel,
      keyword: keyword,
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

  static int _calcBaseDamage(ItemSlot slot, ItemRarity rarity, int level, int rebirthLevel) {
    // Base: 3-8 at level 1, scales +1.5 per level
    // Offhand = 60% of main hand
    // Rarity multiplier: common 1.0, rare 1.2, epic 1.5, legendary 2.0
    // Rebirth adds +10% per rebirth level
    final rarityMult = switch (rarity) {
      ItemRarity.common    => 1.0,
      ItemRarity.uncommon  => 1.1,
      ItemRarity.rare      => 1.2,
      ItemRarity.epic      => 1.5,
      ItemRarity.legendary => 2.0,
      ItemRarity.mythic    => 2.5,
      ItemRarity.set       => 1.6,
      ItemRarity.unique    => 2.0,
      ItemRarity.ascended     => 3.0,
      ItemRarity.primordial   => 3.6,
      ItemRarity.eternal      => 4.3,
      ItemRarity.transcendent => 5.0,
    };
    final base = 5.0 + level * 1.5;
    final slotMult = slot == ItemSlot.offHand ? 0.6 : 1.0;
    final rebirthMult = 1.0 + rebirthLevel * 0.10;
    return (base * rarityMult * slotMult * rebirthMult).round().clamp(1, 99999);
  }

  static int _baseValue(ItemStat stat, ItemRarity rarity, int level, Random rng) {
    final m = switch (rarity) {
      ItemRarity.transcendent => 8,
      ItemRarity.eternal      => 7,
      ItemRarity.primordial   => 6,
      ItemRarity.ascended     => 5,
      ItemRarity.mythic    => 4,
      ItemRarity.legendary => 3,
      ItemRarity.unique    => 3,
      ItemRarity.set       => 2,
      ItemRarity.epic      => 2,
      ItemRarity.rare      => 1,
      ItemRarity.uncommon  => 1,
      ItemRarity.common    => 0,
    };
    // Level scaling: stats grow with item level
    final lvScale = 1.0 + (level - 1) * 0.08;
    // Heal Rating is its own animal: it must scale to a meaningful fraction of
    // the (multiplier-inflated) HP pool, so it is NOT clamped to 999 like other
    // flats. Grows generously with item level; a full support build should reach
    // a rating worth a partial (not full) heal at endgame. Tunable here.
    if (stat == ItemStat.healRating) {
      final base = 25 + m * 20;
      return (base * lvScale).round().clamp(1, 1000000000);
    }
    final isPct = stat == ItemStat.maxHpPct || stat == ItemStat.goldPct ||
        stat == ItemStat.xpPct || stat == ItemStat.elemPenetration ||
        stat == ItemStat.damagePercent;
    if (isPct) {
      final base = 5 + m * 5;
      return (base * lvScale).round().clamp(1, 999);
    }
    final flat = switch (stat) {
      ItemStat.attackBonus  => 1 + m + rng.nextInt(2),
      ItemStat.damageBonus  => 1 + m + rng.nextInt(2),
      _ => 1 + m,
    };
    return (flat * lvScale).round().clamp(1, 999);
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
        ItemRarity.uncommon  => (gold: 80,   shards: 8),
        ItemRarity.rare      => (gold: 200,  shards: 20),
        ItemRarity.epic      => (gold: 600,  shards: 50),
        ItemRarity.legendary => (gold: 1800, shards: 120),
        ItemRarity.mythic    => (gold: 5000, shards: 300),
        ItemRarity.ascended     => (gold: 9000,  shards: 500),
        ItemRarity.primordial   => (gold: 15000, shards: 800),
        ItemRarity.eternal      => (gold: 24000, shards: 1200),
        ItemRarity.transcendent => (gold: 40000, shards: 2000),
        _                    => (gold: 0,    shards: 0),
      };

  static bool canReforge(ItemRarity rarity) =>
      rarity == ItemRarity.uncommon  ||
      rarity == ItemRarity.rare      ||
      rarity == ItemRarity.epic      ||
      rarity == ItemRarity.legendary ||
      rarity == ItemRarity.mythic    ||
      rarity == ItemRarity.ascended    ||
      rarity == ItemRarity.primordial  ||
      rarity == ItemRarity.eternal     ||
      rarity == ItemRarity.transcendent;
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

  int get equippedWeaponDamage {
    final main = equipped[ItemSlot.weapon]?.baseDamage ?? 0;
    final off = equipped[ItemSlot.offHand]?.baseDamage ?? 0;
    return main + off;
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
    // Nested maps from JSON (and empty {} literals from reset) come back as
    // _Map<dynamic, dynamic>, which a direct `as Map<String, dynamic>` cast
    // rejects. Convert defensively so no storage/reset source can crash us.
    final rawEquipped = json['equipped'];
    if (rawEquipped is Map) {
      Map<String, dynamic>.from(rawEquipped).forEach((k, v) {
        final slot = ItemSlot.values.firstWhere((s) => s.name == k,
            orElse: () => ItemSlot.weapon);
        equipped[slot] = EquipmentItem.fromJson(Map<String, dynamic>.from(v as Map));
      });
    }
    final rawBag = json['bag'];
    if (rawBag is List) {
      bag.addAll(rawBag
          .map((i) => EquipmentItem.fromJson(Map<String, dynamic>.from(i as Map))));
    }
  }

  void reset() {
    equipped.clear();
    bag.clear();
  }
}
