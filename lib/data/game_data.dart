import '../models/upgrade.dart';

class GameData {
  // ── Stat Upgrades ──────────────────────────────────────────────────────────
  //
  // Each upgrade grants a flat bonus to one D&D attribute.
  // Modifiers are calculated as (stat − 10) ÷ 2 (integer division).
  //
  // STR/DEX/CON give +4 per level → +2 to mod per level (clean step).
  // INT/WIS/CHA give +3 per level → +1 or +2 to mod per level (alternating).
  //
  // Cost scaling is exponential (×1.75 per level — see Upgrade.cost).
  // This makes early upgrades accessible and late upgrades a real commitment.
  // ──────────────────────────────────────────────────────────────────────────

  static final upgrades = [
    Upgrade(
      id: 'str_1',
      name: 'Might Training',
      description: '+4 STR per level. Every +2 STR above 10 adds +1 to attack rolls and damage dealt.',
      baseCost: 200,
      type: UpgradeType.strength,
      effectAmount: 4,
      maxLevel: 8,
    ),
    Upgrade(
      id: 'dex_1',
      name: 'Swift Reflexes',
      description: '+4 DEX per level. Every +2 DEX above 10 raises Armor Class by 1.',
      baseCost: 200,
      type: UpgradeType.dexterity,
      effectAmount: 4,
      maxLevel: 8,
    ),
    Upgrade(
      id: 'con_1',
      name: 'Endurance Drill',
      description: '+4 CON per level. Expands max HP and the HP recovered between battles.',
      baseCost: 220,
      type: UpgradeType.constitution,
      effectAmount: 4,
      maxLevel: 8,
    ),
    Upgrade(
      id: 'int_1',
      name: "Scholar's Study",
      description: '+3 INT per level. Every +2 INT above 10 multiplies gold earned from victories.',
      baseCost: 190,
      type: UpgradeType.intelligence,
      effectAmount: 3,
      maxLevel: 6,
    ),
    Upgrade(
      id: 'wis_1',
      name: 'Meditative Focus',
      description: '+3 WIS per level. Raises idle income — higher WIS means gold flows even while resting.',
      baseCost: 210,
      type: UpgradeType.wisdom,
      effectAmount: 3,
      maxLevel: 6,
    ),
    Upgrade(
      id: 'cha_1',
      name: 'Silver Presence',
      description: '+3 CHA per level. Every +2 CHA above 10 boosts XP gained and crit chance.',
      baseCost: 175,
      type: UpgradeType.charisma,
      effectAmount: 3,
      maxLevel: 6,
    ),
    Upgrade(
      id: 'dual_mastery',
      name: 'Dual Mastery',
      description:
          'Unlock your class secondary element. Toggle freely between Physical, '
          'your class element (lv5), and this new element in battle.',
      baseCost: 800,
      type: UpgradeType.dualMastery,
      effectAmount: 1,
      maxLevel: 1,
    ),
  ];
}
