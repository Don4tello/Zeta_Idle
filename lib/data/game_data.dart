import '../models/upgrade.dart';

class GameData {
  static final upgrades = [
    Upgrade(
      id: 'str_1',
      name: 'Might Training',
      description: '+2 STR. Improves attack bonus and damage.',
      baseCost: 75,
      type: UpgradeType.strength,
      effectAmount: 2,
      maxLevel: 6,
    ),
    Upgrade(
      id: 'dex_1',
      name: 'Swift Reflexes',
      description: '+2 DEX. Raises Armor Class.',
      baseCost: 80,
      type: UpgradeType.dexterity,
      effectAmount: 2,
      maxLevel: 6,
    ),
    Upgrade(
      id: 'con_1',
      name: 'Endurance Drill',
      description: '+2 CON. Increases max HP.',
      baseCost: 90,
      type: UpgradeType.constitution,
      effectAmount: 2,
      maxLevel: 6,
    ),
    Upgrade(
      id: 'int_1',
      name: "Scholar's Study",
      description: '+2 INT. Boosts gold earned from victories.',
      baseCost: 100,
      type: UpgradeType.intelligence,
      effectAmount: 2,
      maxLevel: 6,
    ),
    Upgrade(
      id: 'wis_1',
      name: 'Meditative Focus',
      description: '+2 WIS. Improves idle progress rate.',
      baseCost: 110,
      type: UpgradeType.wisdom,
      effectAmount: 2,
      maxLevel: 6,
    ),
    Upgrade(
      id: 'cha_1',
      name: 'Silver Presence',
      description: '+2 CHA. Boosts XP earned from victories.',
      baseCost: 85,
      type: UpgradeType.charisma,
      effectAmount: 2,
      maxLevel: 6,
    ),
  ];

}
