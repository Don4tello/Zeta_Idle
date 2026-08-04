import 'package:flutter/material.dart';

import 'equipment.dart';

enum EventRewardType { currency, gear }

class WorldEventReward {
  const WorldEventReward({
    required this.id,
    required this.name,
    required this.description,
    required this.tokenCost,
    required this.icon,
    this.zcoins = 0,
    this.gold = 0,
    this.shards = 0,
    this.essence = 0,
    this.mythril = 0,
    this.echoes = 0,
    this.auraId,
    this.gearSlot,
    this.gearRarity,
    this.type = EventRewardType.currency,
  });
  final String id;
  final String name;
  final String description;
  final int tokenCost;
  final String icon;
  final int zcoins, gold, shards, essence, mythril, echoes;
  final String? auraId;
  final ItemSlot? gearSlot;
  final ItemRarity? gearRarity;
  final EventRewardType type;

  static List<WorldEventReward> eventShop(int heroLevel) {
    final lvl = heroLevel.clamp(1, 100);
    return [
      // Currency rewards
      WorldEventReward(id: 'omega_gold', name: 'Gold Purse', description: '💰 +${2000 + lvl * 50} Gold', tokenCost: 8, icon: '💰', gold: 2000 + lvl * 50),
      WorldEventReward(id: 'omega_crystals_10', name: 'ZCoin Cache', description: '🪙 +10 ZCoins', tokenCost: 12, icon: '🪙', zcoins: 10),
      WorldEventReward(id: 'omega_essence', name: 'Shard Cache', description: '◆ +${50 + lvl * 3} Shards', tokenCost: 10, icon: '◆', essence: 50 + lvl * 3),
      WorldEventReward(id: 'omega_crystals_25', name: 'ZCoin Hoard', description: '🪙 +25 ZCoins', tokenCost: 25, icon: '🪙', zcoins: 25),
      WorldEventReward(id: 'omega_mythril', name: 'Mythril Ingot', description: '⬡ +${5 + lvl ~/ 5} Mythril', tokenCost: 20, icon: '⬡', mythril: 5 + lvl ~/ 5),
      // Gear rewards — level-appropriate
      WorldEventReward(id: 'omega_epic_weapon', name: 'Epic Weapon', description: '⚔ Epic weapon at Lv$lvl', tokenCost: 30, icon: '⚔', type: EventRewardType.gear, gearSlot: ItemSlot.weapon, gearRarity: ItemRarity.epic),
      WorldEventReward(id: 'omega_epic_armor', name: 'Epic Armor', description: '🛡 Epic armor at Lv$lvl', tokenCost: 30, icon: '🛡', type: EventRewardType.gear, gearSlot: ItemSlot.armor, gearRarity: ItemRarity.epic),
      WorldEventReward(id: 'omega_epic_helmet', name: 'Epic Helmet', description: '⛑ Epic helmet at Lv$lvl', tokenCost: 28, icon: '⛑', type: EventRewardType.gear, gearSlot: ItemSlot.helmet, gearRarity: ItemRarity.epic),
      WorldEventReward(id: 'omega_legend_weapon', name: 'Legendary Weapon', description: '⚔ Legendary weapon at Lv$lvl', tokenCost: 60, icon: '⚔', type: EventRewardType.gear, gearSlot: ItemSlot.weapon, gearRarity: ItemRarity.legendary),
      WorldEventReward(id: 'omega_legend_armor', name: 'Legendary Armor', description: '🛡 Legendary armor at Lv$lvl', tokenCost: 60, icon: '🛡', type: EventRewardType.gear, gearSlot: ItemSlot.armor, gearRarity: ItemRarity.legendary),
      WorldEventReward(id: 'omega_legend_amulet', name: 'Legendary Amulet', description: '📿 Legendary amulet at Lv$lvl', tokenCost: 55, icon: '📿', type: EventRewardType.gear, gearSlot: ItemSlot.amulet, gearRarity: ItemRarity.legendary),
    ];
  }
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
    required this.damageTypes,
  });
  final String id;
  final String name;
  final String description;
  final String enemyName;
  final String enemyEmoji;
  final Color color;
  final String icon;
  final List<WorldEventReward> rewards;
  final List<String> damageTypes;

  static const _rewards10 = 10;
  static const _rewards25 = 22;

  static List<WorldEventReward> _shopFor(String prefix, String name10, String name25) => [
    WorldEventReward(id: '${prefix}_10', name: name10, description: '🪙 +10 ZCoins', tokenCost: _rewards10, icon: '🪙', zcoins: 10),
    WorldEventReward(id: '${prefix}_25', name: name25, description: '💎 +25 ZCoins', tokenCost: _rewards25, icon: '💎', zcoins: 25),
  ];

  static final all = <WorldEventDef>[
    // Week 1 — Physical + Fire
    WorldEventDef(
      id: 'goblin_uprising', name: 'Goblin Uprising',
      description: 'Warchief Kragnuk rallies goblin clans. Pyromancer goblins hurl firebombs while warriors charge.',
      enemyName: 'Goblin Raider', enemyEmoji: '👺',
      color: Color(0xFF88cc44), icon: '⚔',
      damageTypes: ['physical', 'fire'],
      rewards: _shopFor('goblin', 'Looted Chest', "Warchief's Vault"),
    ),
    // Week 2 — Fire + Lightning
    WorldEventDef(
      id: 'dragon_raid', name: 'Dragon Raid',
      description: 'Elder drake Malgrathos descends with storm and flame. Scale fragments fall with every blow.',
      enemyName: 'Drake Spawn', enemyEmoji: '🐉',
      color: Color(0xFFff6644), icon: '🔥',
      damageTypes: ['fire', 'lightning'],
      rewards: _shopFor('dragon', 'Dragon Hoard', 'Elder Cache'),
    ),
    // Week 3 — Cold + Void
    WorldEventDef(
      id: 'undead_siege', name: 'Undead Siege',
      description: 'Skeletal legions march from the Bone Wastes. A Lich Lord channels frost and shadow.',
      enemyName: 'Lich Shard', enemyEmoji: '💀',
      color: Color(0xFF88aacc), icon: '☠',
      damageTypes: ['cold', 'void'],
      rewards: _shopFor('undead', 'Soulstone Cache', "Necromancer's Hoard"),
    ),
    // Week 4 — Void + Fire
    WorldEventDef(
      id: 'demon_incursion', name: 'Demon Incursion',
      description: 'A rift tears open above the Ashfields. Demons pour through wreathed in hellfire and void.',
      enemyName: 'Demon Thrall', enemyEmoji: '👿',
      color: Color(0xFFcc4488), icon: '🔮',
      damageTypes: ['void', 'fire'],
      rewards: _shopFor('demon', 'Infernal Gem', 'Void Shard'),
    ),
    // Week 5 — Poison + Physical
    WorldEventDef(
      id: 'spider_plague', name: 'Spider Plague',
      description: 'Giant arachnids swarm from the Darkwood. Venomous fangs and crushing mandibles.',
      enemyName: 'Brood Mother', enemyEmoji: '🕷',
      color: Color(0xFF66aa44), icon: '☠',
      damageTypes: ['poison', 'physical'],
      rewards: _shopFor('spider', 'Venom Sac', 'Silk-Wrapped Cache'),
    ),
    // Week 6 — Lightning + Cold
    WorldEventDef(
      id: 'storm_titan', name: 'Storm Titan Awakening',
      description: 'An ancient titan stirs beneath the mountains. Thunder and ice shatter the peaks.',
      enemyName: 'Storm Fragment', enemyEmoji: '⚡',
      color: Color(0xFF4488ff), icon: '⛈',
      damageTypes: ['lightning', 'cold'],
      rewards: _shopFor('storm', 'Thunder Core', 'Titan Shard'),
    ),
    // Week 7 — Void + Poison
    WorldEventDef(
      id: 'plague_of_shadows', name: 'Plague of Shadows',
      description: 'Void Wraiths seep from the dark between stars. Their touch corrodes both body and soul.',
      enemyName: 'Shadow Wisp', enemyEmoji: '👻',
      color: Color(0xFF9966ff), icon: '🌑',
      damageTypes: ['void', 'poison'],
      rewards: _shopFor('shadow', 'Voidstone', 'Wraith Essence'),
    ),
    // Week 8 — Fire + Cold
    WorldEventDef(
      id: 'elemental_convergence', name: 'Elemental Convergence',
      description: 'The planes of fire and ice collide. Elemental chaos tears through the borderlands.',
      enemyName: 'Chaos Elemental', enemyEmoji: '🌋',
      color: Color(0xFFff8844), icon: '🜂',
      damageTypes: ['fire', 'cold'],
      rewards: _shopFor('elemental', 'Primal Core', 'Convergence Crystal'),
    ),
    // Week 9 — Physical + Lightning
    WorldEventDef(
      id: 'iron_legion', name: 'Iron Legion March',
      description: 'Enchanted war golems march from a forgotten forge. Steel fists crackle with arcane lightning.',
      enemyName: 'War Golem', enemyEmoji: '🤖',
      color: Color(0xFF888888), icon: '⚙',
      damageTypes: ['physical', 'lightning'],
      rewards: _shopFor('iron', 'Golem Core', 'Arcane Dynamo'),
    ),
    // Week 10 — Poison + Fire
    WorldEventDef(
      id: 'wyrm_awakening', name: 'Wyrm Awakening',
      description: 'A venomous wyrm bursts from volcanic vents. Toxic fumes and magma consume the valley.',
      enemyName: 'Magma Wyrm', enemyEmoji: '🐍',
      color: Color(0xFFcc6622), icon: '🌋',
      damageTypes: ['poison', 'fire'],
      rewards: _shopFor('wyrm', 'Molten Fang', 'Wyrm Heart'),
    ),
    // Week 11 — Cold + Physical
    WorldEventDef(
      id: 'frost_giant_siege', name: 'Frost Giant Siege',
      description: 'Jotnar descend from the frozen peaks. Their massive clubs shatter walls, their breath freezes rivers.',
      enemyName: 'Frost Jotnar', enemyEmoji: '❄',
      color: Color(0xFF66bbee), icon: '🏔',
      damageTypes: ['cold', 'physical'],
      rewards: _shopFor('frost', 'Frozen Heart', 'Glacial Rune'),
    ),
    // Week 12 — Lightning + Poison
    WorldEventDef(
      id: 'swamp_terror', name: 'Swamp Terror',
      description: 'Electric eels and toxic hydras boil from the Blightmarsh. The swamp itself fights back.',
      enemyName: 'Blight Hydra', enemyEmoji: '🐊',
      color: Color(0xFF44aa88), icon: '☢',
      damageTypes: ['lightning', 'poison'],
      rewards: _shopFor('swamp', 'Blight Gland', 'Hydra Crown'),
    ),
    // Week 13 — Void + Cold
    WorldEventDef(
      id: 'astral_breach', name: 'Astral Breach',
      description: 'The barrier between realms cracks. Astral horrors drift through, trailing frozen void.',
      enemyName: 'Astral Horror', enemyEmoji: '🌌',
      color: Color(0xFFaa44cc), icon: '✦',
      damageTypes: ['void', 'cold'],
      rewards: _shopFor('astral', 'Astral Fragment', 'Rift Crystal'),
    ),
  ];

  static WorldEventDef forWeek() {
    final week = DateTime.now().millisecondsSinceEpoch ~/ (7 * 24 * 3600 * 1000);
    return all[week % all.length];
  }
}
