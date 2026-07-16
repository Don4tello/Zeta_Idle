import 'dart:math';
import '../models/equipment.dart';
import '../models/dnd_class.dart';
import '../models/hero_ability.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UniqueItemsData — 36 class-restricted legendary items, 3 per class.
//
// Each item targets one ability by uniqueAbilityId and applies dramatic mods:
//   abilityValueMult    — multiplies the ability's main value (die / % / flat)
//   abilityDurationAdd  — adds rounds to the effect's duration
//   abilityCooldownFlat — reduces the ability's cooldown by N rounds
//   abilityExtraEffect  — fires a bonus effect when the ability is cast
//   abilityExtraValue   — value for the bonus effect (% for DoT/aura/heal)
//   abilityExtraDuration— duration for the bonus effect
//
// Drop: 2% chance per boss kill, picked randomly from all 36 items.
// Equip: blocked entirely if hero's class doesn't match requiredClass.
// ─────────────────────────────────────────────────────────────────────────────

class UniqueItemsData {
  static final List<EquipmentItem> all = [

    // ── BARBARIAN ─────────────────────────────────────────────────────────────
    EquipmentItem(
      id: 'unique_barb_1', name: 'Bloodstorm Axe',
      slot: ItemSlot.weapon, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.attackBonus, 4), StatBonus(ItemStat.damageBonus, 3)],
      levelRequired: 10,
      requiredClass: DndClass.barbarian, uniqueAbilityId: 'barbarian_1',
      abilityValueMult: 2.0, abilityCooldownFlat: 1,
      abilityExtraEffect: AbilityEffect.dot, abilityExtraValue: 30, abilityExtraDuration: 3,
    ),
    EquipmentItem(
      id: 'unique_barb_2', name: "Warlord's Helm",
      slot: ItemSlot.helmet, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.armorClass, 4), StatBonus(ItemStat.strength, 3)],
      levelRequired: 10,
      requiredClass: DndClass.barbarian, uniqueAbilityId: 'barbarian_2',
      abilityValueMult: 2.0, abilityDurationAdd: 3,
      abilityExtraEffect: AbilityEffect.debuffWeaken, abilityExtraValue: 30, abilityExtraDuration: 4,
    ),
    EquipmentItem(
      id: 'unique_barb_3', name: 'Heart of Rage',
      slot: ItemSlot.amulet, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.maxHpPct, 10), StatBonus(ItemStat.constitution, 3)],
      levelRequired: 15,
      requiredClass: DndClass.barbarian, uniqueAbilityId: 'barbarian_4',
      abilityValueMult: 2.5, abilityDurationAdd: 4,
      abilityExtraEffect: AbilityEffect.attackBonus, abilityExtraValue: 8, abilityExtraDuration: 6,
    ),

    // ── BARD ─────────────────────────────────────────────────────────────────
    EquipmentItem(
      id: 'unique_bard_1', name: 'Songblade of Discord',
      slot: ItemSlot.weapon, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.attackBonus, 4), StatBonus(ItemStat.damageBonus, 3)],
      levelRequired: 10,
      requiredClass: DndClass.bard, uniqueAbilityId: 'bard_1',
      abilityValueMult: 2.0, abilityCooldownFlat: 1,
      abilityExtraEffect: AbilityEffect.stun, abilityExtraDuration: 2,
    ),
    EquipmentItem(
      id: 'unique_bard_2', name: 'Echo Chamber Lute',
      slot: ItemSlot.relic, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.maxHpPct, 8), StatBonus(ItemStat.charisma, 3)],
      levelRequired: 15,
      requiredClass: DndClass.bard, uniqueAbilityId: 'bard_4',
      abilityValueMult: 2.0, abilityDurationAdd: 4,
      abilityExtraEffect: AbilityEffect.attackBonus, abilityExtraValue: 6, abilityExtraDuration: 8,
    ),
    EquipmentItem(
      id: 'unique_bard_3', name: 'Mocking Mask',
      slot: ItemSlot.helmet, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.armorClass, 3), StatBonus(ItemStat.charisma, 4)],
      levelRequired: 20,
      requiredClass: DndClass.bard, uniqueAbilityId: 'bard_5',
      abilityValueMult: 1.6, abilityDurationAdd: 3,
      abilityExtraEffect: AbilityEffect.debuffVulnerable, abilityExtraValue: 25, abilityExtraDuration: 4,
    ),

    // ── CLERIC ───────────────────────────────────────────────────────────────
    EquipmentItem(
      id: 'unique_cleric_1', name: 'Staff of Sacred Flame',
      slot: ItemSlot.weapon, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.attackBonus, 4), StatBonus(ItemStat.damageBonus, 4)],
      levelRequired: 10,
      requiredClass: DndClass.cleric, uniqueAbilityId: 'cleric_1',
      abilityValueMult: 2.0, abilityCooldownFlat: 1,
      abilityExtraEffect: AbilityEffect.dot, abilityExtraValue: 35, abilityExtraDuration: 3,
    ),
    EquipmentItem(
      id: 'unique_cleric_2', name: 'Chalice of Eternity',
      slot: ItemSlot.relic, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.maxHpPct, 10), StatBonus(ItemStat.wisdom, 3)],
      levelRequired: 10,
      requiredClass: DndClass.cleric, uniqueAbilityId: 'cleric_2',
      abilityValueMult: 2.0, abilityCooldownFlat: 2,
      abilityExtraEffect: AbilityEffect.acBonus, abilityExtraValue: 6, abilityExtraDuration: 4,
    ),
    EquipmentItem(
      id: 'unique_cleric_3', name: 'Veil of the Void',
      slot: ItemSlot.helmet, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.armorClass, 5), StatBonus(ItemStat.wisdom, 4)],
      levelRequired: 15,
      requiredClass: DndClass.cleric, uniqueAbilityId: 'cleric_4',
      abilityValueMult: 2.5, abilityDurationAdd: 3,
      abilityExtraEffect: AbilityEffect.attackBonus, abilityExtraValue: 8, abilityExtraDuration: 6,
    ),

    // ── DRUID ────────────────────────────────────────────────────────────────
    EquipmentItem(
      id: 'unique_druid_1', name: 'Thornweave Gauntlets',
      slot: ItemSlot.gloves, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.attackBonus, 3), StatBonus(ItemStat.constitution, 3)],
      levelRequired: 10,
      requiredClass: DndClass.druid, uniqueAbilityId: 'druid_1',
      abilityValueMult: 2.0, abilityDurationAdd: 3,
      abilityExtraEffect: AbilityEffect.debuffVulnerable, abilityExtraValue: 20, abilityExtraDuration: 3,
    ),
    EquipmentItem(
      id: 'unique_druid_2', name: 'Glacier Heart',
      slot: ItemSlot.amulet, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.damageBonus, 4), StatBonus(ItemStat.intelligence, 3)],
      levelRequired: 10,
      requiredClass: DndClass.druid, uniqueAbilityId: 'druid_3',
      abilityValueMult: 2.0, abilityCooldownFlat: 2,
      abilityExtraEffect: AbilityEffect.stun, abilityExtraDuration: 2,
    ),
    EquipmentItem(
      id: 'unique_druid_3', name: 'Ancient Grove Crown',
      slot: ItemSlot.helmet, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.maxHpPct, 10), StatBonus(ItemStat.wisdom, 4)],
      levelRequired: 15,
      requiredClass: DndClass.druid, uniqueAbilityId: 'druid_4',
      abilityValueMult: 2.4, abilityDurationAdd: 3,
      abilityExtraEffect: AbilityEffect.acBonus, abilityExtraValue: 5, abilityExtraDuration: 8,
    ),

    // ── FIGHTER ──────────────────────────────────────────────────────────────
    EquipmentItem(
      id: 'unique_fighter_1', name: 'Thunderstrike Gauntlets',
      slot: ItemSlot.gloves, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.attackBonus, 5), StatBonus(ItemStat.strength, 3)],
      levelRequired: 10,
      requiredClass: DndClass.fighter, uniqueAbilityId: 'fighter_1',
      abilityValueMult: 2.0, abilityCooldownFlat: 1,
      abilityExtraEffect: AbilityEffect.stun, abilityExtraDuration: 2,
    ),
    EquipmentItem(
      id: 'unique_fighter_2', name: "Warlord's Bulwark",
      slot: ItemSlot.offHand, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.armorClass, 6), StatBonus(ItemStat.strength, 3)],
      levelRequired: 10,
      requiredClass: DndClass.fighter, uniqueAbilityId: 'fighter_2',
      abilityValueMult: 2.0, abilityDurationAdd: 4,
      abilityExtraEffect: AbilityEffect.acBonus, abilityExtraValue: 6, abilityExtraDuration: 6,
    ),
    EquipmentItem(
      id: 'unique_fighter_3', name: 'Standard of Battle',
      slot: ItemSlot.relic, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.maxHpPct, 10), StatBonus(ItemStat.constitution, 4)],
      levelRequired: 15,
      requiredClass: DndClass.fighter, uniqueAbilityId: 'fighter_4',
      abilityValueMult: 2.5, abilityDurationAdd: 4,
      abilityExtraEffect: AbilityEffect.attackBonus, abilityExtraValue: 8, abilityExtraDuration: 8,
    ),

    // ── MONK ─────────────────────────────────────────────────────────────────
    EquipmentItem(
      id: 'unique_monk_1', name: 'Fists of Heaven',
      slot: ItemSlot.gloves, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.attackBonus, 5), StatBonus(ItemStat.dexterity, 3)],
      levelRequired: 10,
      requiredClass: DndClass.monk, uniqueAbilityId: 'monk_1',
      abilityValueMult: 2.5, abilityCooldownFlat: 1,
      abilityExtraEffect: AbilityEffect.stun, abilityExtraDuration: 1,
    ),
    EquipmentItem(
      id: 'unique_monk_2', name: 'Iron Mantle of Ki',
      slot: ItemSlot.armor, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.armorClass, 6), StatBonus(ItemStat.constitution, 3)],
      levelRequired: 10,
      requiredClass: DndClass.monk, uniqueAbilityId: 'monk_2',
      abilityValueMult: 2.0, abilityDurationAdd: 4,
      abilityExtraEffect: AbilityEffect.attackBonus, abilityExtraValue: 6, abilityExtraDuration: 6,
    ),
    EquipmentItem(
      id: 'unique_monk_3', name: "Void Monk's Cincture",
      slot: ItemSlot.amulet, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.damageBonus, 5), StatBonus(ItemStat.wisdom, 3)],
      levelRequired: 10,
      requiredClass: DndClass.monk, uniqueAbilityId: 'monk_3',
      abilityValueMult: 2.0, abilityCooldownFlat: 2,
      abilityExtraEffect: AbilityEffect.debuffVulnerable, abilityExtraValue: 30, abilityExtraDuration: 3,
    ),

    // ── PALADIN ──────────────────────────────────────────────────────────────
    EquipmentItem(
      id: 'unique_paladin_1', name: 'Hammer of the Righteous',
      slot: ItemSlot.weapon, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.attackBonus, 4), StatBonus(ItemStat.damageBonus, 4)],
      levelRequired: 10,
      requiredClass: DndClass.paladin, uniqueAbilityId: 'paladin_1',
      abilityValueMult: 2.0, abilityCooldownFlat: 2,
      abilityExtraEffect: AbilityEffect.stun, abilityExtraDuration: 1,
    ),
    EquipmentItem(
      id: 'unique_paladin_2', name: 'Holy Grail',
      slot: ItemSlot.relic, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.maxHpPct, 12), StatBonus(ItemStat.wisdom, 4)],
      levelRequired: 10,
      requiredClass: DndClass.paladin, uniqueAbilityId: 'paladin_2',
      abilityValueMult: 2.0, abilityCooldownFlat: 2,
      abilityExtraEffect: AbilityEffect.aura, abilityExtraValue: 8, abilityExtraDuration: 4,
    ),
    EquipmentItem(
      id: 'unique_paladin_3', name: 'Bulwark of Light',
      slot: ItemSlot.offHand, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.armorClass, 6), StatBonus(ItemStat.maxHpPct, 8)],
      levelRequired: 15,
      requiredClass: DndClass.paladin, uniqueAbilityId: 'paladin_4',
      abilityValueMult: 2.0, abilityDurationAdd: 3,
      abilityExtraEffect: AbilityEffect.acBonus, abilityExtraValue: 8, abilityExtraDuration: 8,
    ),

    // ── RANGER ───────────────────────────────────────────────────────────────
    EquipmentItem(
      id: 'unique_ranger_1', name: 'Venom Quiver',
      slot: ItemSlot.weapon, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.attackBonus, 4), StatBonus(ItemStat.damageBonus, 3)],
      levelRequired: 10,
      requiredClass: DndClass.ranger, uniqueAbilityId: 'ranger_1',
      abilityValueMult: 2.0, abilityDurationAdd: 3,
      abilityExtraEffect: AbilityEffect.debuffWeaken, abilityExtraValue: 25, abilityExtraDuration: 3,
    ),
    EquipmentItem(
      id: 'unique_ranger_2', name: "Predator's Eye",
      slot: ItemSlot.helmet, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.attackBonus, 5), StatBonus(ItemStat.dexterity, 4)],
      levelRequired: 10,
      requiredClass: DndClass.ranger, uniqueAbilityId: 'ranger_2',
      abilityValueMult: 2.0, abilityDurationAdd: 4, abilityCooldownFlat: 2,
      abilityExtraEffect: AbilityEffect.dodge,
    ),
    EquipmentItem(
      id: 'unique_ranger_3', name: 'Cloak of the Woodland',
      slot: ItemSlot.armor, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.armorClass, 5), StatBonus(ItemStat.dexterity, 3)],
      levelRequired: 15,
      requiredClass: DndClass.ranger, uniqueAbilityId: 'ranger_4',
      abilityValueMult: 2.0, abilityDurationAdd: 4,
      abilityExtraEffect: AbilityEffect.attackBonus, abilityExtraValue: 5, abilityExtraDuration: 8,
    ),

    // ── ROGUE ────────────────────────────────────────────────────────────────
    EquipmentItem(
      id: 'unique_rogue_1', name: 'Shadowfang Daggers',
      slot: ItemSlot.weapon, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.attackBonus, 5), StatBonus(ItemStat.damageBonus, 4)],
      levelRequired: 10,
      requiredClass: DndClass.rogue, uniqueAbilityId: 'rogue_1',
      abilityValueMult: 2.0, abilityCooldownFlat: 1,
      abilityExtraEffect: AbilityEffect.dot, abilityExtraValue: 35, abilityExtraDuration: 3,
    ),
    EquipmentItem(
      id: 'unique_rogue_2', name: 'Phantom Cloak',
      slot: ItemSlot.armor, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.armorClass, 4), StatBonus(ItemStat.dexterity, 4)],
      levelRequired: 10,
      requiredClass: DndClass.rogue, uniqueAbilityId: 'rogue_2',
      abilityDurationAdd: 1, abilityCooldownFlat: 2,
      abilityExtraEffect: AbilityEffect.attackBonus, abilityExtraValue: 6, abilityExtraDuration: 3,
    ),
    EquipmentItem(
      id: 'unique_rogue_3', name: "Void Assassin's Hood",
      slot: ItemSlot.helmet, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.damageBonus, 5), StatBonus(ItemStat.dexterity, 4)],
      levelRequired: 10,
      requiredClass: DndClass.rogue, uniqueAbilityId: 'rogue_3',
      abilityValueMult: 2.0, abilityCooldownFlat: 2,
      abilityExtraEffect: AbilityEffect.debuffVulnerable, abilityExtraValue: 30, abilityExtraDuration: 3,
    ),

    // ── SORCERER ─────────────────────────────────────────────────────────────
    EquipmentItem(
      id: 'unique_sorc_1', name: 'Draconic Orb',
      slot: ItemSlot.relic, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.damageBonus, 4), StatBonus(ItemStat.intelligence, 3)],
      levelRequired: 10,
      requiredClass: DndClass.sorcerer, uniqueAbilityId: 'sorcerer_1',
      abilityValueMult: 2.0, abilityCooldownFlat: 1,
      abilityExtraEffect: AbilityEffect.dot, abilityExtraValue: 35, abilityExtraDuration: 3,
    ),
    EquipmentItem(
      id: 'unique_sorc_2', name: 'Dragonblood Mantle',
      slot: ItemSlot.armor, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.maxHpPct, 10), StatBonus(ItemStat.intelligence, 4)],
      levelRequired: 10,
      requiredClass: DndClass.sorcerer, uniqueAbilityId: 'sorcerer_2',
      abilityValueMult: 1.5, abilityDurationAdd: 4,
      abilityExtraEffect: AbilityEffect.attackBonus, abilityExtraValue: 8, abilityExtraDuration: 6,
    ),
    EquipmentItem(
      id: 'unique_sorc_3', name: 'Glacial Spire',
      slot: ItemSlot.weapon, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.damageBonus, 5), StatBonus(ItemStat.intelligence, 3)],
      levelRequired: 10,
      requiredClass: DndClass.sorcerer, uniqueAbilityId: 'sorcerer_3',
      abilityValueMult: 2.0, abilityCooldownFlat: 2,
      abilityExtraEffect: AbilityEffect.stun, abilityExtraDuration: 2,
    ),

    // ── WARLOCK ──────────────────────────────────────────────────────────────
    EquipmentItem(
      id: 'unique_warlock_1', name: "Patron's Tome",
      slot: ItemSlot.relic, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.damageBonus, 4), StatBonus(ItemStat.charisma, 3)],
      levelRequired: 10,
      requiredClass: DndClass.warlock, uniqueAbilityId: 'warlock_1',
      abilityValueMult: 2.0, abilityCooldownFlat: 1,
      abilityExtraEffect: AbilityEffect.dot, abilityExtraValue: 35, abilityExtraDuration: 3,
    ),
    EquipmentItem(
      id: 'unique_warlock_2', name: 'Dark Covenant Seal',
      slot: ItemSlot.amulet, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.maxHpPct, 10), StatBonus(ItemStat.charisma, 4)],
      levelRequired: 10,
      requiredClass: DndClass.warlock, uniqueAbilityId: 'warlock_2',
      abilityValueMult: 2.0, abilityDurationAdd: 4,
      abilityExtraEffect: AbilityEffect.acBonus, abilityExtraValue: 6, abilityExtraDuration: 6,
    ),
    EquipmentItem(
      id: 'unique_warlock_3', name: 'Void Pact Mantle',
      slot: ItemSlot.armor, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.armorClass, 4), StatBonus(ItemStat.charisma, 4)],
      levelRequired: 20,
      requiredClass: DndClass.warlock, uniqueAbilityId: 'warlock_5',
      abilityValueMult: 1.5, abilityDurationAdd: 4,
      abilityExtraEffect: AbilityEffect.debuffVulnerable, abilityExtraValue: 25, abilityExtraDuration: 5,
    ),

    // ── WIZARD ───────────────────────────────────────────────────────────────
    EquipmentItem(
      id: 'unique_wizard_1', name: "Archmage's Staff",
      slot: ItemSlot.weapon, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.attackBonus, 4), StatBonus(ItemStat.damageBonus, 4)],
      levelRequired: 10,
      requiredClass: DndClass.wizard, uniqueAbilityId: 'wizard_1',
      abilityValueMult: 2.0, abilityCooldownFlat: 1,
      abilityExtraEffect: AbilityEffect.stun, abilityExtraDuration: 1,
    ),
    EquipmentItem(
      id: 'unique_wizard_2', name: 'Spellweaver Robes',
      slot: ItemSlot.armor, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.armorClass, 5), StatBonus(ItemStat.intelligence, 4)],
      levelRequired: 10,
      requiredClass: DndClass.wizard, uniqueAbilityId: 'wizard_2',
      abilityValueMult: 2.0, abilityDurationAdd: 4,
      abilityExtraEffect: AbilityEffect.attackBonus, abilityExtraValue: 6, abilityExtraDuration: 7,
    ),
    EquipmentItem(
      id: 'unique_wizard_3', name: 'Tome of Absolute Zero',
      slot: ItemSlot.relic, rarity: ItemRarity.unique,
      bonuses: [StatBonus(ItemStat.damageBonus, 5), StatBonus(ItemStat.intelligence, 4)],
      levelRequired: 10,
      requiredClass: DndClass.wizard, uniqueAbilityId: 'wizard_3',
      abilityValueMult: 2.0, abilityCooldownFlat: 2,
      abilityExtraEffect: AbilityEffect.stun, abilityExtraDuration: 2,
    ),
  ];

  // 2% chance per boss kill — pick a random item from all 36.
  // The calling code should check hero class before allowing equip.
  static EquipmentItem? tryDropUnique(int heroLevel, Random rng) {
    if (rng.nextInt(100) >= 2) return null;
    return all[rng.nextInt(all.length)];
  }

  // Returns the unique item description string for display in UI
  static String describeItem(EquipmentItem item) {
    if (item.uniqueAbilityId == null) return '';
    final parts = <String>[];
    if (item.abilityValueMult != 1.0) {
      parts.add('${item.abilityValueMult}× ability value');
    }
    if (item.abilityDurationAdd > 0) {
      parts.add('+${item.abilityDurationAdd}r duration');
    }
    if (item.abilityCooldownFlat > 0) {
      parts.add('−${item.abilityCooldownFlat} cooldown');
    }
    if (item.abilityExtraEffect != null) {
      final xe = item.abilityExtraEffect!;
      final xv = item.abilityExtraValue;
      final xd = item.abilityExtraDuration;
      parts.add(_extraEffectLabel(xe, xv, xd));
    }
    return parts.join(' • ');
  }

  static String _extraEffectLabel(AbilityEffect xe, int xv, int xd) =>
    switch (xe) {
      AbilityEffect.stun            => 'Stun ${xd}r',
      AbilityEffect.dot             => 'DoT $xv%/r for ${xd}r',
      AbilityEffect.attackBonus     => '+$xv ATK for ${xd}r',
      AbilityEffect.acBonus         => '+$xv AC for ${xd}r',
      AbilityEffect.aura            => 'Aura $xv% HP/r for ${xd}r',
      AbilityEffect.debuffWeaken    => 'Weaken $xv% for ${xd}r',
      AbilityEffect.debuffVulnerable=> 'Vuln $xv% for ${xd}r',
      AbilityEffect.dodge           => 'Dodge next hit',
      AbilityEffect.heal            => 'Heal $xv% HP',
      AbilityEffect.bonusDamage     => '+${xv}d bonus',
      AbilityEffect.silence         => 'Silence ${xd}r',
      AbilityEffect.absorbShield    => '$xv HP barrier',
      AbilityEffect.missChance      => '$xv% miss for ${xd}r',
    };
}
