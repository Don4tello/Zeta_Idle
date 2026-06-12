enum DailyChallengeType {
  killEnemies,
  winBattles,
  collectIdle,
  useAbilities,
  dealDamage,
  defeatBoss,
  equipItem,
  reachGold,
}

class DailyChallenge {
  DailyChallenge({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.target,
    required this.rewardGold,
    required this.rewardShards,
    required this.rewardEssence,
    required this.rewardCrystals,
    this.claimed = false,
  });

  final String id;
  final DailyChallengeType type;
  final String title;
  final String description;
  final int target;
  final int rewardGold;
  final int rewardShards;
  final int rewardEssence;
  final int rewardCrystals;
  bool claimed;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'description': description,
    'target': target,
    'rewardGold': rewardGold,
    'rewardShards': rewardShards,
    'rewardEssence': rewardEssence,
    'rewardCrystals': rewardCrystals,
    'claimed': claimed,
  };

  static DailyChallenge fromJson(Map<String, dynamic> json) => DailyChallenge(
    id: json['id'] as String,
    type: DailyChallengeType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => DailyChallengeType.killEnemies),
    title: json['title'] as String,
    description: json['description'] as String,
    target: json['target'] as int,
    rewardGold: json['rewardGold'] as int,
    rewardShards: (json['rewardShards'] as int?) ?? 0,
    rewardEssence: (json['rewardEssence'] as int?) ?? 0,
    rewardCrystals: (json['rewardCrystals'] as int?) ?? 0,
    claimed: (json['claimed'] as bool?) ?? false,
  );
}
