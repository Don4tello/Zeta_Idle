import 'package:flutter/material.dart';

class WorldEventReward {
  const WorldEventReward({
    required this.id,
    required this.name,
    required this.description,
    required this.tokenCost,
    required this.icon,
    this.crystals = 0,
    this.auraId,
  });
  final String id;
  final String name;
  final String description;
  final int tokenCost;
  final String icon;
  final int crystals;
  final String? auraId;
}

class WorldEventDef {
  const WorldEventDef({
    required this.id,
    required this.name,
    required this.description,
    required this.enemyName,
    required this.enemyEmoji,
    required this.color,
    required this.icon,
    required this.rewards,
  });
  final String id;
  final String name;
  final String description;
  final String enemyName;
  final String enemyEmoji;
  final Color color;
  final String icon;
  final List<WorldEventReward> rewards;

  static const all = <WorldEventDef>[
    WorldEventDef(
      id: 'undead_siege',
      name: 'Undead Siege',
      description: 'Skeletal legions march from the Bone Wastes. '
          'A Lich Lord directs the assault from the shadows.',
      enemyName: 'Lich Shard',
      enemyEmoji: '💀',
      color: Color(0xFF88aacc),
      icon: '☠',
      rewards: [
        WorldEventReward(id: 'undead_crystals_10', name: 'Soulstone Cache', description: '10 Crystals', tokenCost: 10, icon: '💎', crystals: 10),
        WorldEventReward(id: 'undead_crystals_25', name: 'Necromancer\'s Hoard', description: '25 Crystals', tokenCost: 22, icon: '💎', crystals: 25),
      ],
    ),
    WorldEventDef(
      id: 'dragon_raid',
      name: 'Dragon Raid',
      description: 'The elder drake Malgrathos descends on the realm. '
          'Scale fragments fall with every blow.',
      enemyName: 'Drake Spawn',
      enemyEmoji: '🐉',
      color: Color(0xFFff6644),
      icon: '🔥',
      rewards: [
        WorldEventReward(id: 'dragon_crystals_10', name: 'Dragon Hoard', description: '10 Crystals', tokenCost: 10, icon: '💎', crystals: 10),
        WorldEventReward(id: 'dragon_crystals_25', name: 'Elder Cache', description: '25 Crystals', tokenCost: 22, icon: '💎', crystals: 25),
      ],
    ),
    WorldEventDef(
      id: 'demon_incursion',
      name: 'Demon Incursion',
      description: 'A rift tears open above the Ashfields. '
          'Demons pour through, hungry for mortal souls.',
      enemyName: 'Demon Thrall',
      enemyEmoji: '👿',
      color: Color(0xFFcc4488),
      icon: '🔮',
      rewards: [
        WorldEventReward(id: 'demon_crystals_10', name: 'Infernal Gem', description: '10 Crystals', tokenCost: 10, icon: '💎', crystals: 10),
        WorldEventReward(id: 'demon_crystals_25', name: 'Void Shard', description: '25 Crystals', tokenCost: 22, icon: '💎', crystals: 25),
      ],
    ),
    WorldEventDef(
      id: 'goblin_uprising',
      name: 'Goblin Uprising',
      description: 'The Warchief Kragnuk rallies goblin clans. '
          'They raid settlements for gold and shiny trinkets.',
      enemyName: 'Goblin Scout',
      enemyEmoji: '👺',
      color: Color(0xFF88cc44),
      icon: '⚔',
      rewards: [
        WorldEventReward(id: 'goblin_crystals_10', name: 'Looted Chest', description: '10 Crystals', tokenCost: 10, icon: '💎', crystals: 10),
        WorldEventReward(id: 'goblin_crystals_25', name: 'Warchief\'s Vault', description: '25 Crystals', tokenCost: 22, icon: '💎', crystals: 25),
      ],
    ),
    WorldEventDef(
      id: 'plague_of_shadows',
      name: 'Plague of Shadows',
      description: 'Void Wraiths seep from the dark between stars. '
          'Light fades wherever they pass.',
      enemyName: 'Shadow Wisp',
      enemyEmoji: '👻',
      color: Color(0xFF9966ff),
      icon: '🌑',
      rewards: [
        WorldEventReward(id: 'shadow_crystals_10', name: 'Voidstone', description: '10 Crystals', tokenCost: 10, icon: '💎', crystals: 10),
        WorldEventReward(id: 'shadow_crystals_25', name: 'Wraith Essence', description: '25 Crystals', tokenCost: 22, icon: '💎', crystals: 25),
      ],
    ),
  ];

  static WorldEventDef forWeek() {
    final week = DateTime.now().millisecondsSinceEpoch ~/ (7 * 24 * 3600 * 1000);
    return all[week % all.length];
  }
}
