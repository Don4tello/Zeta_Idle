enum AllyMilestone {
  killCount,
  campaignStage,
  prestigeLevel,
  ascensionLevel,
  dungeonClears,
  bossRushClears,
  gauntletScore,
  achievementsUnlocked,
}

class NpcAllyDef {
  const NpcAllyDef({
    required this.id,
    required this.name,
    required this.title,
    required this.icon,
    required this.lore,
    required this.milestone,
    required this.milestoneTarget,
    required this.milestoneLabel,
    required this.bonusDescription,
    this.atkBonus       = 0,
    this.dmgBonus       = 0,
    this.acBonus        = 0,
    this.goldPctBonus   = 0.0,
    this.xpPctBonus     = 0.0,
    this.shardPctBonus  = 0.0,
    this.idlePctBonus   = 0.0,
    this.hpPctBonus     = 0.0,
  });

  final String id;
  final String name;
  final String title;
  final String icon;
  final String lore;
  final AllyMilestone milestone;
  final int milestoneTarget;
  final String milestoneLabel;
  final String bonusDescription;

  // Per-level base values — multiply by ally level to get effective bonus
  final int    atkBonus;
  final int    dmgBonus;
  final int    acBonus;
  final double goldPctBonus;
  final double xpPctBonus;
  final double shardPctBonus;
  final double idlePctBonus;
  final double hpPctBonus;

  static const int maxLevel = 5;

  // Shard + crystal cost to reach the given level (from level - 1)
  static (int shards, int crystals) levelUpCost(int toLevel) => switch (toLevel) {
    2 => (20,  0),
    3 => (50,  5),
    4 => (120, 15),
    5 => (250, 35),
    _ => (999999, 999999),
  };

  static const all = <NpcAllyDef>[
    NpcAllyDef(
      id:              'greybeard',
      name:            'Greybeard',
      title:           'Veteran Sellsword',
      icon:            '⚔️',
      lore:            'A weathered mercenary who fought in a dozen wars. He sharpens your blade and your resolve.',
      milestone:       AllyMilestone.killCount,
      milestoneTarget: 100,
      milestoneLabel:  '100 total kills',
      bonusDescription: '+3 ATK / level',
      atkBonus:        3,
    ),
    NpcAllyDef(
      id:              'mira',
      name:            'Mira',
      title:           'Battle Medic',
      icon:            '🩹',
      lore:            'A field surgeon who has patched up heroes across three campaigns. Your max HP grows under her care.',
      milestone:       AllyMilestone.campaignStage,
      milestoneTarget: 10,
      milestoneLabel:  'Reach campaign stage 10',
      bonusDescription: '+15% HP / level',
      hpPctBonus:      0.15,
    ),
    NpcAllyDef(
      id:              'coin_felix',
      name:            'Felix',
      title:           'Merchant Prince',
      icon:            '💰',
      lore:            'A shrewd trader who finds opportunity in every monster corpse. Gold flows more freely with him around.',
      milestone:       AllyMilestone.campaignStage,
      milestoneTarget: 15,
      milestoneLabel:  'Reach campaign stage 15',
      bonusDescription: '+20% Gold / level',
      goldPctBonus:    0.20,
    ),
    NpcAllyDef(
      id:              'elder_voss',
      name:            'Elder Voss',
      title:           'Arcane Scholar',
      icon:            '📚',
      lore:            'Ancient knowledge pours from this tower-dwelling sage. His presence accelerates all learning.',
      milestone:       AllyMilestone.prestigeLevel,
      milestoneTarget: 1,
      milestoneLabel:  'Reach Prestige 1',
      bonusDescription: '+20% XP / level',
      xpPctBonus:      0.20,
    ),
    NpcAllyDef(
      id:              'ironhide',
      name:            'Ironhide',
      title:           'Dwarven Armorsmith',
      icon:            '🛡️',
      lore:            'He hammers steel like he breathes — constantly. Your armor grows heavier and more reliable.',
      milestone:       AllyMilestone.dungeonClears,
      milestoneTarget: 5,
      milestoneLabel:  'Clear 5 dungeons',
      bonusDescription: '+3 AC / level',
      acBonus:         3,
    ),
    NpcAllyDef(
      id:              'shadow_lena',
      name:            'Lena',
      title:           'Shadow Rogue',
      icon:            '🗡️',
      lore:            'She moves in silence and strikes with precision. Your shard sense sharpens near her.',
      milestone:       AllyMilestone.bossRushClears,
      milestoneTarget: 1,
      milestoneLabel:  'Complete a Boss Rush',
      bonusDescription: '+15% Shards / level',
      shardPctBonus:   0.15,
    ),
    NpcAllyDef(
      id:              'golem_ruk',
      name:            'Ruk',
      title:           'Stone Golem',
      icon:            '🗿',
      lore:            'Carved from the bones of a mountain, Ruk stands silent guard. His presence bolsters idle gains.',
      milestone:       AllyMilestone.ascensionLevel,
      milestoneTarget: 1,
      milestoneLabel:  'Ascend once',
      bonusDescription: '+25% Idle / level',
      idlePctBonus:    0.25,
    ),
    NpcAllyDef(
      id:              'warmaster_cael',
      name:            'Cael',
      title:           'Warmaster',
      icon:            '🏆',
      lore:            'A legendary champion who has bested every gauntlet ever devised. His fury sharpens your strikes.',
      milestone:       AllyMilestone.gauntletScore,
      milestoneTarget: 1000,
      milestoneLabel:  'Score 1000 in a Gauntlet run',
      bonusDescription: '+5 DMG / level',
      dmgBonus:        5,
    ),
  ];
}

// ── Synergy Definitions ───────────────────────────────────────────────────────

class SynergyDef {
  const SynergyDef({
    required this.id,
    required this.name,
    required this.description,
    required this.ally1Id,
    required this.ally2Id,
    required this.minLevel,
    this.atkBonus       = 0,
    this.dmgBonus       = 0,
    this.acBonus        = 0,
    this.goldPctBonus   = 0.0,
    this.xpPctBonus     = 0.0,
    this.shardPctBonus  = 0.0,
    this.idlePctBonus   = 0.0,
    this.hpPctBonus     = 0.0,
  });

  final String id;
  final String name;
  final String description;
  final String ally1Id;
  final String ally2Id;
  final int minLevel;

  final int    atkBonus;
  final int    dmgBonus;
  final int    acBonus;
  final double goldPctBonus;
  final double xpPctBonus;
  final double shardPctBonus;
  final double idlePctBonus;
  final double hpPctBonus;

  String get bonusSummary {
    final parts = <String>[];
    if (atkBonus > 0)      parts.add('+$atkBonus ATK');
    if (dmgBonus > 0)      parts.add('+$dmgBonus DMG');
    if (acBonus > 0)       parts.add('+$acBonus AC');
    if (goldPctBonus > 0)  parts.add('+${(goldPctBonus * 100).round()}% Gold');
    if (xpPctBonus > 0)    parts.add('+${(xpPctBonus * 100).round()}% XP');
    if (shardPctBonus > 0) parts.add('+${(shardPctBonus * 100).round()}% Shards');
    if (idlePctBonus > 0)  parts.add('+${(idlePctBonus * 100).round()}% Idle');
    if (hpPctBonus > 0)    parts.add('+${(hpPctBonus * 100).round()}% HP');
    return parts.join('  •  ');
  }

  static const all = <SynergyDef>[
    SynergyDef(
      id:          'war_veterans',
      name:        'War Veterans',
      description: 'Greybeard and Cael share hard-won battlefield wisdom.',
      ally1Id:     'greybeard',
      ally2Id:     'warmaster_cael',
      minLevel:    2,
      atkBonus:    3,
      dmgBonus:    3,
    ),
    SynergyDef(
      id:          'iron_bulwark',
      name:        'Iron Bulwark',
      description: 'Mira keeps Ironhide operational; Ironhide keeps Mira armored.',
      ally1Id:     'mira',
      ally2Id:     'ironhide',
      minLevel:    2,
      acBonus:     2,
      hpPctBonus:  0.10,
    ),
    SynergyDef(
      id:          'shadow_market',
      name:        'Shadow Market',
      description: 'Felix fences Lena\'s loot. Everyone profits.',
      ally1Id:     'coin_felix',
      ally2Id:     'shadow_lena',
      minLevel:    2,
      goldPctBonus:  0.15,
      shardPctBonus: 0.10,
    ),
    SynergyDef(
      id:          'ancient_wisdom',
      name:        'Ancient Wisdom',
      description: 'Elder Voss inscribes runes into Ruk\'s stone hide.',
      ally1Id:     'elder_voss',
      ally2Id:     'golem_ruk',
      minLevel:    2,
      xpPctBonus:   0.10,
      idlePctBonus: 0.15,
    ),
    SynergyDef(
      id:          'steel_brotherhood',
      name:        'Steel Brotherhood',
      description: 'Greybeard and Ironhide forge an unbreakable bond in battle.',
      ally1Id:     'greybeard',
      ally2Id:     'ironhide',
      minLevel:    3,
      atkBonus:    2,
      acBonus:     2,
    ),
    SynergyDef(
      id:          'learned_merchant',
      name:        'Learned Merchant',
      description: 'Felix funds Elder Voss\'s research. Knowledge becomes gold.',
      ally1Id:     'coin_felix',
      ally2Id:     'elder_voss',
      minLevel:    3,
      goldPctBonus: 0.20,
      xpPctBonus:   0.10,
    ),
    SynergyDef(
      id:          'blade_mastery',
      name:        'Blade Mastery',
      description: 'Lena and Cael spar daily. Each pushes the other to lethal precision.',
      ally1Id:     'shadow_lena',
      ally2Id:     'warmaster_cael',
      minLevel:    3,
      dmgBonus:    5,
      shardPctBonus: 0.10,
    ),
  ];
}
