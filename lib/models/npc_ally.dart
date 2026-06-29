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

class AllyAbility {
  const AllyAbility({
    required this.name,
    required this.icon,
    required this.description,
  });
  final String name;
  final String icon;
  final String description;
}

// ── Talent branches ───────────────────────────────────────────────────────────

class AllyTalentOption {
  const AllyTalentOption({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    this.atkBonus      = 0,
    this.dmgBonus      = 0,
    this.acBonus       = 0,
    this.goldPctBonus  = 0.0,
    this.xpPctBonus    = 0.0,
    this.shardPctBonus = 0.0,
    this.idlePctBonus  = 0.0,
    this.hpPctBonus    = 0.0,
  });
  final String id;         // 'a' or 'b'
  final String name;
  final String icon;
  final String description;
  final int    atkBonus;
  final int    dmgBonus;
  final int    acBonus;
  final double goldPctBonus;
  final double xpPctBonus;
  final double shardPctBonus;
  final double idlePctBonus;
  final double hpPctBonus;

  String get statSummary {
    final parts = <String>[];
    if (atkBonus      > 0) parts.add('+$atkBonus ATK');
    if (dmgBonus      > 0) parts.add('+$dmgBonus DMG');
    if (acBonus       > 0) parts.add('+$acBonus AC');
    if (goldPctBonus  > 0) parts.add('+${(goldPctBonus  * 100).round()}% Gold');
    if (xpPctBonus    > 0) parts.add('+${(xpPctBonus    * 100).round()}% XP');
    if (shardPctBonus > 0) parts.add('+${(shardPctBonus * 100).round()}% Shards');
    if (idlePctBonus  > 0) parts.add('+${(idlePctBonus  * 100).round()}% Idle');
    if (hpPctBonus    > 0) parts.add('+${(hpPctBonus    * 100).round()}% HP');
    return parts.join('  •  ');
  }
}

class AllyTalentDef {
  const AllyTalentDef({
    required this.unlocksAtLevel,
    required this.optionA,
    required this.optionB,
  });
  final int unlocksAtLevel;
  final AllyTalentOption optionA;
  final AllyTalentOption optionB;
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
    this.activeAbility,
    this.talent3,
    this.talent5,
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
  final AllyAbility? activeAbility;

  /// Talent branches unlocked at LV3 and LV5.
  final AllyTalentDef? talent3;
  final AllyTalentDef? talent5;

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
      activeAbility: AllyAbility(
        name: 'War Cry',
        icon: '📣',
        description: 'Start of battle: shouts a war cry that grants +5 ATK for 4 rounds.',
      ),
      talent3: AllyTalentDef(
        unlocksAtLevel: 3,
        optionA: AllyTalentOption(id: 'a', name: 'Iron Resolve', icon: '🗡', description: 'Pure offensive discipline.', atkBonus: 6),
        optionB: AllyTalentOption(id: 'b', name: 'Tactical Mind', icon: '🛡', description: 'Balance of offence and defence.', atkBonus: 3, acBonus: 3),
      ),
      talent5: AllyTalentDef(
        unlocksAtLevel: 5,
        optionA: AllyTalentOption(id: 'a', name: "Warlord's Edge", icon: '⚔', description: 'Mastery of raw attack power.', atkBonus: 12),
        optionB: AllyTalentOption(id: 'b', name: 'Battle Master', icon: '🏆', description: 'Combined strikes and damage.', atkBonus: 6, dmgBonus: 6),
      ),
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
      activeAbility: AllyAbility(
        name: 'Field Triage',
        icon: '💉',
        description: 'Once per battle: when HP drops below 30%, instantly heals 25% of max HP.',
      ),
      talent3: AllyTalentDef(
        unlocksAtLevel: 3,
        optionA: AllyTalentOption(id: 'a', name: 'Regenerative Herbs', icon: '🌿', description: 'Focus on maximising vitality.', hpPctBonus: 0.20),
        optionB: AllyTalentOption(id: 'b', name: 'Trauma Medicine', icon: '💊', description: 'Bolster both survival and defence.', hpPctBonus: 0.10, acBonus: 2),
      ),
      talent5: AllyTalentDef(
        unlocksAtLevel: 5,
        optionA: AllyTalentOption(id: 'a', name: 'Master Healer', icon: '❤', description: 'Exceptional regenerative mastery.', hpPctBonus: 0.35),
        optionB: AllyTalentOption(id: 'b', name: 'Life Weaver', icon: '✨', description: 'Sustained vitality and gold.', hpPctBonus: 0.20, goldPctBonus: 0.10),
      ),
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
      activeAbility: AllyAbility(
        name: 'Bribe',
        icon: '🤑',
        description: 'Once per battle: bribes the enemy — first kill grants double gold.',
      ),
      talent3: AllyTalentDef(
        unlocksAtLevel: 3,
        optionA: AllyTalentOption(id: 'a', name: 'Merchant Network', icon: '📦', description: 'Expand trading routes for pure gold.', goldPctBonus: 0.20),
        optionB: AllyTalentOption(id: 'b', name: "Thief's Fence", icon: '🕵', description: 'Diversify into shard smuggling.', goldPctBonus: 0.10, shardPctBonus: 0.10),
      ),
      talent5: AllyTalentDef(
        unlocksAtLevel: 5,
        optionA: AllyTalentOption(id: 'a', name: 'Golden Touch', icon: '✨', description: 'Everything becomes gold.', goldPctBonus: 0.40),
        optionB: AllyTalentOption(id: 'b', name: 'Black Market', icon: '🖤', description: 'Gold and shards in equal measure.', goldPctBonus: 0.20, shardPctBonus: 0.15),
      ),
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
      activeAbility: AllyAbility(
        name: 'Arcane Surge',
        icon: '🔮',
        description: 'Start of battle: blasts the enemy with arcane energy for 10% of their max HP.',
      ),
      talent3: AllyTalentDef(
        unlocksAtLevel: 3,
        optionA: AllyTalentOption(id: 'a', name: "Sage's Knowledge", icon: '📖', description: 'Accelerated learning above all.', xpPctBonus: 0.20),
        optionB: AllyTalentOption(id: 'b', name: 'Arcane Studies', icon: '🔮', description: 'XP and shard insight combined.', xpPctBonus: 0.10, shardPctBonus: 0.08),
      ),
      talent5: AllyTalentDef(
        unlocksAtLevel: 5,
        optionA: AllyTalentOption(id: 'a', name: 'Grand Master', icon: '🎓', description: 'Unrivalled scholarly output.', xpPctBonus: 0.40),
        optionB: AllyTalentOption(id: 'b', name: 'Forbidden Lore', icon: '☠', description: 'Knowledge stolen from the void.', xpPctBonus: 0.25, shardPctBonus: 0.10),
      ),
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
      activeAbility: AllyAbility(
        name: 'Shield Wall',
        icon: '🪨',
        description: 'Once per battle: when HP drops below 50%, raises a shield to block the next incoming hit.',
      ),
      talent3: AllyTalentDef(
        unlocksAtLevel: 3,
        optionA: AllyTalentOption(id: 'a', name: 'Tempered Steel', icon: '🔩', description: 'Pure defensive craftsmanship.', acBonus: 5),
        optionB: AllyTalentOption(id: 'b', name: 'Living Fortress', icon: '🏰', description: 'Armour and raw vitality.', acBonus: 3, hpPctBonus: 0.10),
      ),
      talent5: AllyTalentDef(
        unlocksAtLevel: 5,
        optionA: AllyTalentOption(id: 'a', name: 'Bulwark', icon: '🛡', description: 'An impenetrable wall of steel.', acBonus: 8),
        optionB: AllyTalentOption(id: 'b', name: 'Diamond Plating', icon: '💎', description: 'Defensive mastery plus offence.', acBonus: 5, dmgBonus: 4),
      ),
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
      activeAbility: AllyAbility(
        name: 'Backstab',
        icon: '🌑',
        description: 'Start of battle: primes a backstab — first attack this battle is a guaranteed critical hit.',
      ),
      talent3: AllyTalentDef(
        unlocksAtLevel: 3,
        optionA: AllyTalentOption(id: 'a', name: 'Shadow Step', icon: '👤', description: 'Vanish deeper into shadows for shards.', shardPctBonus: 0.15),
        optionB: AllyTalentOption(id: 'b', name: 'Knife Collector', icon: '🗡', description: 'Shards and precision strikes.', shardPctBonus: 0.08, atkBonus: 3),
      ),
      talent5: AllyTalentDef(
        unlocksAtLevel: 5,
        optionA: AllyTalentOption(id: 'a', name: 'Master Thief', icon: '🎭', description: 'The ultimate shard harvester.', shardPctBonus: 0.25),
        optionB: AllyTalentOption(id: 'b', name: 'Shadow Arts', icon: '🌑', description: 'Shards and lethal strikes.', shardPctBonus: 0.15, dmgBonus: 4),
      ),
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
      activeAbility: AllyAbility(
        name: 'Stone Skin',
        icon: '🪨',
        description: 'Start of battle: hardens your skin — reduces all incoming damage by 4 for the first 5 enemy attacks.',
      ),
      talent3: AllyTalentDef(
        unlocksAtLevel: 3,
        optionA: AllyTalentOption(id: 'a', name: 'Stone Sentinel', icon: '🗿', description: 'Amplify idle generation further.', idlePctBonus: 0.25),
        optionB: AllyTalentOption(id: 'b', name: 'Ancient Power', icon: '⚡', description: 'Idle income and resilience.', idlePctBonus: 0.15, acBonus: 3),
      ),
      talent5: AllyTalentDef(
        unlocksAtLevel: 5,
        optionA: AllyTalentOption(id: 'a', name: 'Mountain King', icon: '⛰', description: 'Legendary idle mastery.', idlePctBonus: 0.50),
        optionB: AllyTalentOption(id: 'b', name: 'Primordial Might', icon: '🌋', description: 'Idle and raw attack power.', idlePctBonus: 0.30, atkBonus: 4),
      ),
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
      activeAbility: AllyAbility(
        name: "Warmaster's Strike",
        icon: '⚡',
        description: "Once per battle: on your first critical hit, Cael follows up with a strike dealing 15% of the enemy's max HP as bonus damage.",
      ),
      talent3: AllyTalentDef(
        unlocksAtLevel: 3,
        optionA: AllyTalentOption(id: 'a', name: 'Brutal Strikes', icon: '💥', description: 'Raw damage above all else.', dmgBonus: 6),
        optionB: AllyTalentOption(id: 'b', name: 'War Veteran', icon: '🎖', description: 'Combined damage and attack skill.', dmgBonus: 3, atkBonus: 4),
      ),
      talent5: AllyTalentDef(
        unlocksAtLevel: 5,
        optionA: AllyTalentOption(id: 'a', name: 'Conqueror', icon: '⚔', description: 'Overwhelming destructive power.', dmgBonus: 12),
        optionB: AllyTalentOption(id: 'b', name: "Champion's Aura", icon: '🌟', description: 'Damage plus defensive presence.', dmgBonus: 7, acBonus: 4),
      ),
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
