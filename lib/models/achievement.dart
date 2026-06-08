enum AchievementCondition {
  totalBattleWins,
  totalKills,
  totalBossKills,
  totalDamageDealt,
  totalGoldEarned,
  totalIdleCollects,
  totalForges,
  totalDisenchants,
  heroLevel,
  campaignStage,
  prestigeLevel,
  passiveNodesUnlocked,
  survivedAt1HP,  // target = 1 (boolean)
  subclassChosen, // target = 1 (boolean)
}

enum AchievementRewardType { shards, essence, crystals }

class Achievement {
  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.condition,
    required this.target,
    required this.rewardType,
    required this.rewardAmount,
    required this.emoji,
    this.unlocked = false,
    this.claimed = false,
  });

  final String id;
  final String name;
  final String description;
  final AchievementCondition condition;
  final int target;
  final AchievementRewardType rewardType;
  final int rewardAmount;
  final String emoji;
  bool unlocked;
  bool claimed;

  String get rewardLabel {
    final suffix = switch (rewardType) {
      AchievementRewardType.shards   => '◆',
      AchievementRewardType.essence  => ' essence',
      AchievementRewardType.crystals => ' 💎',
    };
    return '$rewardAmount$suffix';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'unlocked': unlocked,
    'claimed': claimed,
  };

  void loadFromJson(Map<String, dynamic> json) {
    unlocked = (json['unlocked'] as bool?) ?? false;
    claimed  = (json['claimed']  as bool?) ?? false;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Full catalog — 25 achievements
// ─────────────────────────────────────────────────────────────────────────────

List<Achievement> buildAchievements() => [
  // ── Combat ────────────────────────────────────────────────────────────────
  Achievement(
    id: 'first_blood', emoji: '⚔️',
    name: 'First Blood',
    description: 'Win your first battle.',
    condition: AchievementCondition.totalBattleWins, target: 1,
    rewardType: AchievementRewardType.shards, rewardAmount: 50,
  ),
  Achievement(
    id: 'battle_veteran', emoji: '🛡️',
    name: 'Battle Veteran',
    description: 'Win 50 battles.',
    condition: AchievementCondition.totalBattleWins, target: 50,
    rewardType: AchievementRewardType.shards, rewardAmount: 150,
  ),
  Achievement(
    id: 'war_machine', emoji: '💀',
    name: 'War Machine',
    description: 'Win 500 battles.',
    condition: AchievementCondition.totalBattleWins, target: 500,
    rewardType: AchievementRewardType.shards, rewardAmount: 400,
  ),
  Achievement(
    id: 'executioner', emoji: '🗡️',
    name: 'Executioner',
    description: 'Kill 100 enemies.',
    condition: AchievementCondition.totalKills, target: 100,
    rewardType: AchievementRewardType.shards, rewardAmount: 100,
  ),
  Achievement(
    id: 'slaughterer', emoji: '🩸',
    name: 'Slaughterer',
    description: 'Kill 1,000 enemies.',
    condition: AchievementCondition.totalKills, target: 1000,
    rewardType: AchievementRewardType.shards, rewardAmount: 300,
  ),
  Achievement(
    id: 'boss_slayer', emoji: '☠️',
    name: 'Boss Slayer',
    description: 'Defeat your first boss.',
    condition: AchievementCondition.totalBossKills, target: 1,
    rewardType: AchievementRewardType.shards, rewardAmount: 100,
  ),
  Achievement(
    id: 'dragon_slayer', emoji: '🔥',
    name: 'Dragon Slayer',
    description: 'Defeat 10 bosses.',
    condition: AchievementCondition.totalBossKills, target: 10,
    rewardType: AchievementRewardType.essence, rewardAmount: 250,
  ),
  Achievement(
    id: 'thread_needle', emoji: '💉',
    name: 'Thread the Needle',
    description: 'Win a battle with exactly 1 HP remaining.',
    condition: AchievementCondition.survivedAt1HP, target: 1,
    rewardType: AchievementRewardType.shards, rewardAmount: 200,
  ),
  Achievement(
    id: 'devastator', emoji: '💥',
    name: 'Devastator',
    description: 'Deal 10,000 total damage across all battles.',
    condition: AchievementCondition.totalDamageDealt, target: 10000,
    rewardType: AchievementRewardType.shards, rewardAmount: 150,
  ),
  Achievement(
    id: 'force_nature', emoji: '🌪️',
    name: 'Force of Nature',
    description: 'Deal 100,000 total damage across all battles.',
    condition: AchievementCondition.totalDamageDealt, target: 100000,
    rewardType: AchievementRewardType.essence, rewardAmount: 300,
  ),

  // ── Progression ───────────────────────────────────────────────────────────
  Achievement(
    id: 'rising_star', emoji: '⭐',
    name: 'Rising Star',
    description: 'Reach hero level 10.',
    condition: AchievementCondition.heroLevel, target: 10,
    rewardType: AchievementRewardType.shards, rewardAmount: 100,
  ),
  Achievement(
    id: 'champion_lv', emoji: '🏆',
    name: 'Champion',
    description: 'Reach hero level 25.',
    condition: AchievementCondition.heroLevel, target: 25,
    rewardType: AchievementRewardType.shards, rewardAmount: 300,
  ),
  Achievement(
    id: 'legend_lv', emoji: '👑',
    name: 'Legend',
    description: 'Reach hero level 50.',
    condition: AchievementCondition.heroLevel, target: 50,
    rewardType: AchievementRewardType.shards, rewardAmount: 600,
  ),
  Achievement(
    id: 'pathfinder', emoji: '🗺️',
    name: 'Pathfinder',
    description: 'Reach campaign stage 10.',
    condition: AchievementCondition.campaignStage, target: 10,
    rewardType: AchievementRewardType.shards, rewardAmount: 150,
  ),
  Achievement(
    id: 'conqueror', emoji: '⚡',
    name: 'Conqueror',
    description: 'Reach campaign stage 25.',
    condition: AchievementCondition.campaignStage, target: 25,
    rewardType: AchievementRewardType.essence, rewardAmount: 500,
  ),
  Achievement(
    id: 'reborn', emoji: '✦',
    name: 'Reborn',
    description: 'Prestige for the first time.',
    condition: AchievementCondition.prestigeLevel, target: 1,
    rewardType: AchievementRewardType.crystals, rewardAmount: 3,
  ),
  Achievement(
    id: 'twice_reborn', emoji: '✦✦',
    name: 'Twice Reborn',
    description: 'Prestige twice.',
    condition: AchievementCondition.prestigeLevel, target: 2,
    rewardType: AchievementRewardType.essence, rewardAmount: 1000,
  ),
  Achievement(
    id: 'chosen_path', emoji: '🌟',
    name: 'Chosen Path',
    description: 'Choose a subclass for your hero.',
    condition: AchievementCondition.subclassChosen, target: 1,
    rewardType: AchievementRewardType.shards, rewardAmount: 200,
  ),

  // ── Economy & Systems ────────────────────────────────────────────────────
  Achievement(
    id: 'hoarder', emoji: '💰',
    name: 'Hoarder',
    description: 'Earn 10,000 gold across all runs.',
    condition: AchievementCondition.totalGoldEarned, target: 10000,
    rewardType: AchievementRewardType.shards, rewardAmount: 100,
  ),
  Achievement(
    id: 'merchant_prince', emoji: '🏦',
    name: 'Merchant Prince',
    description: 'Earn 100,000 gold across all runs.',
    condition: AchievementCondition.totalGoldEarned, target: 100000,
    rewardType: AchievementRewardType.shards, rewardAmount: 300,
  ),
  Achievement(
    id: 'idle_fortune', emoji: '⚡',
    name: 'Idle Fortune',
    description: 'Collect idle rewards 20 times.',
    condition: AchievementCondition.totalIdleCollects, target: 20,
    rewardType: AchievementRewardType.essence, rewardAmount: 100,
  ),
  Achievement(
    id: 'power_up', emoji: '🌿',
    name: 'Power Up',
    description: 'Unlock your first passive tree node.',
    condition: AchievementCondition.passiveNodesUnlocked, target: 1,
    rewardType: AchievementRewardType.shards, rewardAmount: 50,
  ),
  Achievement(
    id: 'master_tree', emoji: '🌳',
    name: 'Master of the Tree',
    description: 'Unlock all 24 passive tree nodes.',
    condition: AchievementCondition.passiveNodesUnlocked, target: 24,
    rewardType: AchievementRewardType.crystals, rewardAmount: 5,
  ),
  Achievement(
    id: 'smith', emoji: '🔨',
    name: 'Smith',
    description: 'Forge your first item.',
    condition: AchievementCondition.totalForges, target: 1,
    rewardType: AchievementRewardType.shards, rewardAmount: 150,
  ),
  Achievement(
    id: 'arcane_recycler', emoji: '♻️',
    name: 'Arcane Recycler',
    description: 'Disenchant 5 items.',
    condition: AchievementCondition.totalDisenchants, target: 5,
    rewardType: AchievementRewardType.shards, rewardAmount: 100,
  ),
];
