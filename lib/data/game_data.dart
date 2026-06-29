import '../models/upgrade.dart';

class GameData {
  // ── Stat Upgrades ──────────────────────────────────────────────────────────
  //
  // Each upgrade grants +1 to one D&D attribute (effectAmount: 1).
  // Damage bonus = stat * 25 / 100 → 0–25% at stat 0–100 (linear).
  // Resistance follows the same formula (capped at 75% total with items).
  // maxLevel: 92 allows any class to upgrade any stat up to the 100 cap
  // (worst-case base is 8, so 8 + 92 = 100).
  //
  // Cost scaling is exponential (×1.75 per level — see Upgrade.cost).
  // ──────────────────────────────────────────────────────────────────────────

  static final upgrades = [
    Upgrade(
      id: 'str_1',
      name: 'Might Training',
      description: '+1 Strength per level. Adds Physical Damage % (stat÷4, max 25%). Scales Physical resistance.',
      baseCost: 200,
      type: UpgradeType.strength,
      effectAmount: 1,
      maxLevel: 92,
    ),
    Upgrade(
      id: 'dex_1',
      name: 'Swift Reflexes',
      description: '+1 Dexterity per level. Adds Lightning Damage % (stat÷4, max 25%). Scales Lightning resistance.',
      baseCost: 200,
      type: UpgradeType.dexterity,
      effectAmount: 1,
      maxLevel: 92,
    ),
    Upgrade(
      id: 'con_1',
      name: 'Endurance Drill',
      description: '+1 Constitution per level. Adds Poison Damage % (stat÷4, max 25%). Scales Poison resistance.',
      baseCost: 220,
      type: UpgradeType.constitution,
      effectAmount: 1,
      maxLevel: 92,
    ),
    Upgrade(
      id: 'int_1',
      name: "Scholar's Study",
      description: '+1 Intelligence per level. Adds Void Damage % (stat÷4, max 25%). Scales Void resistance.',
      baseCost: 190,
      type: UpgradeType.intelligence,
      effectAmount: 1,
      maxLevel: 92,
    ),
    Upgrade(
      id: 'wis_1',
      name: 'Meditative Focus',
      description: '+1 Wisdom per level. Adds Cold Damage % (stat÷4, max 25%). Scales Cold resistance.',
      baseCost: 210,
      type: UpgradeType.wisdom,
      effectAmount: 1,
      maxLevel: 92,
    ),
    Upgrade(
      id: 'cha_1',
      name: 'Silver Presence',
      description: '+1 Charisma per level. Adds Fire Damage % (stat÷4, max 25%). Scales Fire resistance.',
      baseCost: 175,
      type: UpgradeType.charisma,
      effectAmount: 1,
      maxLevel: 92,
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
