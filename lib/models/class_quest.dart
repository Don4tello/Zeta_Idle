import 'dnd_class.dart';

enum QuestCondition {
  killEnemies,
  winBattles,
  reachStage,
  bossKills,
  useAbilities,
  dungeonClears,
  gauntletScore,
  bossRushClears,
  prestigeReach,
  ascensionReach,
  // Tutorial / progression conditions
  equipItem,
  upgradeAbility,
  unlockPassive,
  socketGem,
  forgeItem,
  completeExpedition,
  pvpWins,
  reachLevel,
  earnGold,
  earnEssence,
  collectArtifact,
  endlessStage,
}

class QuestReward {
  const QuestReward({
    this.gold = 0,
    this.shards = 0,
    this.crystals = 0,
    this.echoes = 0,
    this.essence = 0,
    this.mythril = 0,
    this.permanentACBonus = 0,
    this.permanentAttackBonus = 0,
    this.permanentDamageBonus = 0,
    this.title,
  });
  final int gold, shards, crystals, echoes, essence, mythril;
  final int permanentACBonus;
  final int permanentAttackBonus;
  final int permanentDamageBonus;
  final String? title;

  bool get hasPermanentBonus =>
      permanentACBonus > 0 || permanentAttackBonus > 0 || permanentDamageBonus > 0;

  String get summary {
    final parts = <String>[];
    if (gold > 0) parts.add('💰 $gold');
    if (shards > 0) parts.add('◆ $shards');
    if (crystals > 0) parts.add('💎 $crystals');
    if (echoes > 0) parts.add('🔊 $echoes');
    if (essence > 0) parts.add('✦ $essence');
    if (mythril > 0) parts.add('⬡ $mythril');
    if (permanentACBonus > 0) parts.add('+$permanentACBonus ARM');
    if (permanentAttackBonus > 0) parts.add('+$permanentAttackBonus ATK');
    if (permanentDamageBonus > 0) parts.add('+$permanentDamageBonus DMG');
    if (title != null) parts.add('"$title"');
    return parts.join('  ');
  }
}

// Universal adventure questline — teaches game systems, available to all classes
class AdventureQuest {
  const AdventureQuest({
    required this.id,
    required this.chapter,
    required this.title,
    required this.description,
    required this.hint,
    required this.condition,
    required this.target,
    required this.reward,
    required this.questIndex,
  });

  final String id;
  final String chapter;
  final String title;
  final String description;
  final String hint;
  final QuestCondition condition;
  final int target;
  final QuestReward reward;
  final int questIndex;

  static const allQuests = <AdventureQuest>[
    // ── Chapter 1: First Steps (Stage 1–5) ─────────────────────────────────
    AdventureQuest(id: 'adv_01', chapter: 'First Steps', questIndex: 0,
      title: 'Your First Kill', hint: 'Fight in Campaign mode.',
      description: 'Every legend starts with a single blow. Defeat your first enemy.',
      condition: QuestCondition.killEnemies, target: 1,
      reward: QuestReward(gold: 200)),
    AdventureQuest(id: 'adv_02', chapter: 'First Steps', questIndex: 1,
      title: 'Gearing Up', hint: 'Open the Inventory tab and equip an item.',
      description: 'A naked warrior is a dead warrior. Equip your first piece of gear.',
      condition: QuestCondition.equipItem, target: 1,
      reward: QuestReward(gold: 300, shards: 10)),
    AdventureQuest(id: 'adv_03', chapter: 'First Steps', questIndex: 2,
      title: 'Learning the Ropes', hint: 'Use an ability during a battle.',
      description: 'Abilities are your edge. Use one in combat.',
      condition: QuestCondition.useAbilities, target: 3,
      reward: QuestReward(gold: 400)),
    AdventureQuest(id: 'adv_04', chapter: 'First Steps', questIndex: 3,
      title: 'Zone Clear', hint: 'Keep pushing through Campaign.',
      description: 'Clear the first 5 campaign stages.',
      condition: QuestCondition.reachStage, target: 5,
      reward: QuestReward(gold: 500, shards: 15)),

    // ── Chapter 2: Growing Stronger (Stage 5–15) ───────────────────────────
    AdventureQuest(id: 'adv_05', chapter: 'Growing Stronger', questIndex: 4,
      title: 'Power Up', hint: 'Spend shards on the Ability Upgrades tab.',
      description: 'Upgrade an ability to make it stronger.',
      condition: QuestCondition.upgradeAbility, target: 1,
      reward: QuestReward(gold: 600, shards: 20)),
    AdventureQuest(id: 'adv_06', chapter: 'Growing Stronger', questIndex: 5,
      title: 'Into the Depths', hint: 'Enter the Dungeon from the Modes tab.',
      description: 'Brave the dungeon and survive at least 3 floors.',
      condition: QuestCondition.dungeonClears, target: 1,
      reward: QuestReward(gold: 800, essence: 50)),
    AdventureQuest(id: 'adv_07', chapter: 'Growing Stronger', questIndex: 6,
      title: 'First Boss', hint: 'Bosses appear every 5th campaign stage.',
      description: 'Defeat your first boss in the campaign.',
      condition: QuestCondition.bossKills, target: 1,
      reward: QuestReward(gold: 1000, shards: 25)),
    AdventureQuest(id: 'adv_08', chapter: 'Growing Stronger', questIndex: 7,
      title: 'Endless Warrior', hint: 'Enter Endless Mode and fight.',
      description: 'Reach stage 5 in Endless Mode.',
      condition: QuestCondition.endlessStage, target: 5,
      reward: QuestReward(gold: 1000, echoes: 30)),
    AdventureQuest(id: 'adv_09', chapter: 'Growing Stronger', questIndex: 8,
      title: 'Pathfinder', hint: 'Keep progressing in Campaign.',
      description: 'Reach campaign stage 15.',
      condition: QuestCondition.reachStage, target: 15,
      reward: QuestReward(gold: 1500, shards: 30, crystals: 5)),

    // ── Chapter 3: Diversify (Stage 15–30) ─────────────────────────────────
    AdventureQuest(id: 'adv_10', chapter: 'Diversify', questIndex: 9,
      title: 'Passive Growth', hint: 'Open the Passive Tree from the Hero tab.',
      description: 'Unlock your first passive node.',
      condition: QuestCondition.unlockPassive, target: 1,
      reward: QuestReward(essence: 100, shards: 20)),
    AdventureQuest(id: 'adv_11', chapter: 'Diversify', questIndex: 10,
      title: 'The Arena Awaits', hint: 'Fight in PvP Arena.',
      description: 'Win 3 PvP matches.',
      condition: QuestCondition.pvpWins, target: 3,
      reward: QuestReward(gold: 2000, echoes: 50)),
    AdventureQuest(id: 'adv_12', chapter: 'Diversify', questIndex: 11,
      title: 'Explorer', hint: 'Send a mercenary on an Expedition.',
      description: 'Complete your first expedition.',
      condition: QuestCondition.completeExpedition, target: 1,
      reward: QuestReward(gold: 1500, essence: 75)),
    AdventureQuest(id: 'adv_13', chapter: 'Diversify', questIndex: 12,
      title: 'Gem Crafter', hint: 'Craft a gem in the Inventory > Gems tab.',
      description: 'Socket a gem into a weapon or armor piece.',
      condition: QuestCondition.socketGem, target: 1,
      reward: QuestReward(gold: 1000, shards: 40)),
    AdventureQuest(id: 'adv_14', chapter: 'Diversify', questIndex: 13,
      title: 'The Gauntlet', hint: 'Enter the Gauntlet from the Modes tab.',
      description: 'Score 1000+ in the Challenge Gauntlet.',
      condition: QuestCondition.gauntletScore, target: 1000,
      reward: QuestReward(echoes: 100, crystals: 10)),
    AdventureQuest(id: 'adv_15', chapter: 'Diversify', questIndex: 14,
      title: 'Halfway There', hint: 'Push through Campaign.',
      description: 'Reach campaign stage 30.',
      condition: QuestCondition.reachStage, target: 30,
      reward: QuestReward(gold: 3000, shards: 50, crystals: 10)),

    // ── Chapter 4: Mastery (Stage 30–50) ───────────────────────────────────
    AdventureQuest(id: 'adv_16', chapter: 'Mastery', questIndex: 15,
      title: 'Slayer', hint: 'Keep fighting across all modes.',
      description: 'Kill 500 enemies total.',
      condition: QuestCondition.killEnemies, target: 500,
      reward: QuestReward(gold: 5000, echoes: 75)),
    AdventureQuest(id: 'adv_17', chapter: 'Mastery', questIndex: 16,
      title: 'Boss Rush Champion', hint: 'Enter Boss Rush from Modes.',
      description: 'Clear a full Boss Rush run.',
      condition: QuestCondition.bossRushClears, target: 1,
      reward: QuestReward(mythril: 15, crystals: 15)),
    AdventureQuest(id: 'adv_18', chapter: 'Mastery', questIndex: 17,
      title: 'The Smith', hint: 'Use the Forge in the Inventory tab.',
      description: 'Reforge an item at the Forge.',
      condition: QuestCondition.forgeItem, target: 1,
      reward: QuestReward(gold: 3000, shards: 60)),
    AdventureQuest(id: 'adv_19', chapter: 'Mastery', questIndex: 18,
      title: 'Artifact Hunter', hint: 'Forge artifacts in the Inventory > Artifacts tab.',
      description: 'Collect your first artifact.',
      condition: QuestCondition.collectArtifact, target: 1,
      reward: QuestReward(mythril: 20, essence: 150)),
    AdventureQuest(id: 'adv_20', chapter: 'Mastery', questIndex: 19,
      title: 'Veteran', hint: 'Campaign stage 50 is the halfway mark.',
      description: 'Reach campaign stage 50.',
      condition: QuestCondition.reachStage, target: 50,
      reward: QuestReward(gold: 8000, crystals: 25, echoes: 100, title: 'Veteran')),

    // ── Chapter 5: Endgame (Stage 50–75) ───────────────────────────────────
    AdventureQuest(id: 'adv_21', chapter: 'Endgame', questIndex: 20,
      title: 'Arena Legend', hint: 'Win PvP matches consistently.',
      description: 'Win 25 PvP battles.',
      condition: QuestCondition.pvpWins, target: 25,
      reward: QuestReward(gold: 5000, crystals: 20, echoes: 150)),
    AdventureQuest(id: 'adv_22', chapter: 'Endgame', questIndex: 21,
      title: 'Dungeon Delver', hint: 'Clear dungeon runs at higher tiers.',
      description: 'Clear 10 dungeon runs.',
      condition: QuestCondition.dungeonClears, target: 10,
      reward: QuestReward(essence: 300, mythril: 15)),
    AdventureQuest(id: 'adv_23', chapter: 'Endgame', questIndex: 22,
      title: 'Wealth Hoarder', hint: 'Gold from kills, expeditions, and events.',
      description: 'Accumulate 100,000 total gold earned.',
      condition: QuestCondition.earnGold, target: 100000,
      reward: QuestReward(crystals: 30, shards: 100)),
    AdventureQuest(id: 'adv_24', chapter: 'Endgame', questIndex: 23,
      title: 'Deep Diver', hint: 'Push your Endless Mode record.',
      description: 'Reach stage 25 in Endless Mode.',
      condition: QuestCondition.endlessStage, target: 25,
      reward: QuestReward(echoes: 200, crystals: 20)),
    AdventureQuest(id: 'adv_25', chapter: 'Endgame', questIndex: 24,
      title: 'The Long Road', hint: 'Almost there — push to stage 75.',
      description: 'Reach campaign stage 75.',
      condition: QuestCondition.reachStage, target: 75,
      reward: QuestReward(gold: 15000, crystals: 40, mythril: 20, title: 'Champion')),

    // ── Chapter 6: Transcendence (Stage 75–100) ────────────────────────────
    AdventureQuest(id: 'adv_26', chapter: 'Transcendence', questIndex: 25,
      title: 'Relentless', hint: 'Kill everything in sight.',
      description: 'Kill 2000 enemies total.',
      condition: QuestCondition.killEnemies, target: 2000,
      reward: QuestReward(gold: 10000, echoes: 200, permanentDamageBonus: 2)),
    AdventureQuest(id: 'adv_27', chapter: 'Transcendence', questIndex: 26,
      title: 'Essence Master', hint: 'Earn essence from dungeons, passives, and events.',
      description: 'Earn 5000 total essence.',
      condition: QuestCondition.earnEssence, target: 5000,
      reward: QuestReward(essence: 500, mythril: 25)),
    AdventureQuest(id: 'adv_28', chapter: 'Transcendence', questIndex: 27,
      title: 'Gauntlet Legend', hint: 'Push for a high score with modifiers.',
      description: 'Score 10,000+ in the Gauntlet.',
      condition: QuestCondition.gauntletScore, target: 10000,
      reward: QuestReward(echoes: 300, crystals: 50)),
    AdventureQuest(id: 'adv_29', chapter: 'Transcendence', questIndex: 28,
      title: 'Rebirth', hint: 'Reach level 100 and stage 100 to Prestige.',
      description: 'Achieve your first Prestige (Rebirth).',
      condition: QuestCondition.prestigeReach, target: 1,
      reward: QuestReward(gold: 20000, crystals: 75, mythril: 30, permanentAttackBonus: 2, title: 'Reborn')),
    AdventureQuest(id: 'adv_30', chapter: 'Transcendence', questIndex: 29,
      title: 'Journey\'s End', hint: 'The final challenge — reach stage 100.',
      description: 'Reach campaign stage 100. The realm is saved... for now.',
      condition: QuestCondition.reachStage, target: 100,
      reward: QuestReward(gold: 50000, crystals: 100, mythril: 50, echoes: 500, permanentDamageBonus: 3, permanentAttackBonus: 3, title: 'Legend')),
  ];
}

class ClassQuest {
  const ClassQuest({
    required this.id,
    required this.classRequired,
    required this.title,
    required this.description,
    required this.condition,
    required this.target,
    required this.reward,
    required this.questIndex,
  });

  final String id;
  final DndClass classRequired;
  final String title;
  final String description;
  final QuestCondition condition;
  final int target;
  final QuestReward reward;
  final int questIndex; // 0–4, sequential unlock
}
