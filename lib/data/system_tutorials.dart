/// Onboarding tutorials shown the first time each progression system unlocks
/// through the tier-0 campaign. When a system unlocks the auto-fight pauses, the
/// app navigates to that system's tab/sub-tab, and a coach overlay explains it.
///
/// [stage] mirrors GameState._unlockStageNames keys.
/// [navTab] is the bottom-nav index: 0 = Hero, 1 = Play, 2 = Inventory.
/// [subTab] is the sub-tab LABEL to select inside that hub (must match the hub's
/// tab label exactly), or null to just land on the tab.
class SystemTutorial {
  const SystemTutorial({
    required this.stage,
    required this.navTab,
    required this.subTab,
    required this.icon,
    required this.title,
    required this.howTo,
  });

  final int stage;
  final int navTab;
  final String? subTab;
  final String icon;
  final String title;
  final String howTo;

  static SystemTutorial? forStage(int stage) {
    for (final t in all) {
      if (t.stage == stage) return t;
    }
    return null;
  }

  // Sentinel "stage" for the event-triggered first-item (Gear) tutorial.
  static const int gearStage = -1;

  static const all = <SystemTutorial>[
    SystemTutorial(
      stage: 3, navTab: 0, subTab: 'SCORES', icon: '🔥',
      title: 'Damage Types',
      howTo: 'Your attacks deal a damage TYPE — Physical, Fire, Cold, Lightning, '
          'Poison or Void. Enemies resist some types and are weak to others: a '
          'resisted hit lands for less, a weakness lands for more. Penetration '
          '(from gear and passives) cuts through enemy resistance. Match your '
          'build\'s type to what you fight, and check the Bestiary for each '
          'enemy\'s weakness.',
    ),
    SystemTutorial(
      stage: 14, navTab: 0, subTab: 'ABILITIES', icon: '❄️',
      title: 'Status Ailments',
      howTo: 'Some abilities inflict a status tied to their element. Frozen (Cold) '
          'and Shocked (Lightning) make the enemy skip its turn — Shocked also '
          'makes it take +25% damage. Burning (Fire) and Envenomed (Poison, which '
          'stacks) deal damage over time. Withered (Void) saps enemy attack. '
          'Turn-skipping controls (Stun, Silence, Disarm, Frozen, Shocked) share '
          'diminishing returns — chaining them makes each weaker, so nothing can '
          'be locked down forever.',
    ),
    SystemTutorial(
      stage: 33, navTab: 0, subTab: null, icon: '🏰',
      title: 'Guilds',
      howTo: 'Tap the GUILD button to join or create a Guild and team up with other '
          'players. Guilds gain levels from member activity, unlock shared perks, '
          'and fight a weekly Guild Boss together — contribute your damage to the '
          'boss to earn a share of the group rewards.',
    ),
    SystemTutorial(
      stage: gearStage, navTab: 2, subTab: 'GEAR', icon: '🎒',
      title: 'Your First Gear',
      howTo: 'Gear dropped! This is your Inventory. Tap an item to equip it into '
          'its slot manually, or hit AUTO EQUIP to instantly wear your best piece '
          'in every slot. Stronger gear raises your damage, HP and armor — keep '
          'your best equipped as new drops come in.',
    ),
    SystemTutorial(
      // Staggered a couple stages after Abilities (@2) so they don't fire
      // back-to-back on a brand-new character.
      stage: 4, navTab: 0, subTab: 'SCORES', icon: '📊',
      title: 'Ability Scores',
      howTo: 'These are your core attributes (STR, DEX, CON, INT, WIS, CHA). '
          'You earn points as you level up — spend them here to boost your '
          'damage, HP, and each of your damage types.',
    ),
    SystemTutorial(
      stage: 2, navTab: 0, subTab: 'ABILITIES', icon: '⚔️',
      title: 'Abilities',
      howTo: 'Abilities are active skills that fire automatically in battle. '
          'Spend Shards here to rank them up — each rank boosts their power and '
          'unlocks new milestone effects you choose between.',
    ),
    SystemTutorial(
      stage: 5, navTab: 1, subTab: 'CHALLENGES', icon: '🎯',
      title: 'Challenges & Achievements',
      howTo: 'Daily and weekly Challenges give bonus rewards for playing. '
          'Complete them for Shards, Gold and Z-Coins — they refresh on a timer, '
          'so check back often.',
    ),
    SystemTutorial(
      stage: 8, navTab: 0, subTab: 'PASSIVES', icon: '🌿',
      title: 'Passive Tree',
      howTo: 'Spend Shards on passive nodes for permanent stat boosts. Follow a '
          'path toward the keystone that fits your build — nodes stay forever.',
    ),
    SystemTutorial(
      stage: 10, navTab: 0, subTab: 'BONUSES', icon: '📊',
      title: 'Stat Bonuses',
      howTo: 'This screen breaks down every bonus feeding your hero — damage, HP, '
          'armor and more. Check here to see exactly what is making you stronger.',
    ),
    SystemTutorial(
      stage: 12, navTab: 0, subTab: 'BESTIARY', icon: '📖',
      title: 'Bestiary',
      howTo: 'Every enemy you kill is logged here. Hit kill milestones (10, 50, '
          '100…) for permanent rewards and bonus damage against that enemy type.',
    ),
    SystemTutorial(
      stage: 15, navTab: 1, subTab: 'DUNGEON', icon: '🏰',
      title: 'Dungeon',
      howTo: 'Dungeons are branching runs: pick a door each floor, grab relics '
          'and merchant buys, and descend as far as you can for Shards and gear. '
          'Loot is yours even if your hero falls.',
    ),
    SystemTutorial(
      stage: 18, navTab: 0, subTab: 'PETS', icon: '🐾',
      title: 'Pet Companions',
      howTo: 'Pets grant passive bonuses and fight alongside you. Collect them '
          'and level them up here to stack their effects.',
    ),
    SystemTutorial(
      stage: 20, navTab: 1, subTab: 'CHALLENGES', icon: '🏹',
      title: 'Boss Bounties',
      howTo: 'Every campaign boss carries a bounty. Slay it to claim gold, '
          'shards, essence and more. Reach a new difficulty tier for a fresh '
          'set with bigger rewards. Find them under Challenges → Bounties.',
    ),
    SystemTutorial(
      stage: 22, navTab: 0, subTab: 'MERCS', icon: '🛡️',
      title: 'Mercenaries',
      howTo: 'Mercenaries are allies that grant powerful passive bonuses and '
          'battle abilities. Recruit and level them, pick talent branches, and '
          'pair them to unlock synergies.',
    ),
    SystemTutorial(
      stage: 25, navTab: 1, subTab: 'BOSS RUSH', icon: '💀',
      title: 'Boss Rush',
      howTo: 'Boss Rush throws a run of bosses at you back-to-back. Clear tiers '
          'for large one-off rewards — a great power check.',
    ),
    SystemTutorial(
      stage: 28, navTab: 2, subTab: 'ARMORY', icon: '🗂️',
      title: 'Armory',
      howTo: 'The Armory catalogs every Legendary and gear Set in the game. Use '
          'it to plan which set bonuses to chase as you hunt for drops.',
    ),
    SystemTutorial(
      stage: 30, navTab: 1, subTab: 'EVENTS', icon: '🌐',
      title: 'World Events',
      howTo: 'Limited-time world events offer special modifiers and rewards. '
          'Jump in while they are active.',
    ),
    SystemTutorial(
      stage: 35, navTab: 1, subTab: 'TOWER ASCENSION', icon: '🗼',
      title: 'Tower Ascension',
      howTo: 'Climb the endless Tower for Tower Shards. Spend them on Elemental '
          'Mastery (Hero tab) to permanently boost your damage types.',
    ),
    SystemTutorial(
      stage: 40, navTab: 1, subTab: 'EXPEDITION', icon: '🗺️',
      title: 'Expedition',
      howTo: 'Send your hero on timed expeditions to collect loot passively '
          'while you keep playing. Start one, then check back when it finishes.',
    ),
    SystemTutorial(
      stage: 45, navTab: 1, subTab: 'GAUNTLET', icon: '🛡️',
      title: 'Gauntlet',
      howTo: 'The Gauntlet is a modifier-stacked combat challenge. Pick modifiers '
          'to raise the difficulty and your Essence and Echo rewards.',
    ),
    SystemTutorial(
      stage: 50, navTab: 1, subTab: 'PVP', icon: '⚔️',
      title: 'PvP Arena',
      howTo: 'Battle other players\' heroes for ranking and rewards. Your best '
          'build is auto-matched against theirs.',
    ),
    SystemTutorial(
      stage: 55, navTab: 0, subTab: 'BESTIARY', icon: '📕',
      title: 'Bestiary Mastery',
      howTo: 'With the Bestiary filled out, type-level mastery bonuses kick in — '
          'keep hunting each family for stacking permanent damage.',
    ),
    SystemTutorial(
      stage: 100, navTab: 1, subTab: 'CAMPAIGN', icon: '🔺',
      title: 'Difficulty Tiers',
      howTo: 'You cleared the campaign! Unlocking the next Tier restarts it with '
          'much harder enemies and better loot. Your level, gear and progress all '
          'carry over.',
    ),
  ];
}
