class WeeklyChallenge {
  WeeklyChallenge({
    required this.id,
    required this.name,
    required this.description,
    required this.target,
    required this.rewards,
    this.progress = 0,
    this.claimed = false,
  });

  final String id, name, description;
  final int target;
  final Map<String, int> rewards;
  int progress;
  bool claimed;

  double get ratio => target > 0 ? (progress / target).clamp(0.0, 1.0) : 0;
  bool get isComplete => progress >= target;

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'description': description,
    'target': target, 'rewards': rewards,
    'progress': progress, 'claimed': claimed,
  };

  static WeeklyChallenge fromJson(Map<String, dynamic> json) => WeeklyChallenge(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    target: json['target'] as int,
    rewards: (json['rewards'] as Map<String, dynamic>).map((k, v) => MapEntry(k, v as int)),
    progress: (json['progress'] as int?) ?? 0,
    claimed: (json['claimed'] as bool?) ?? false,
  );

  static List<WeeklyChallenge> generateForWeek(int weekSeed) {
    final pool = [
      () => WeeklyChallenge(id: 'w_kills', name: 'Slaughter', description: 'Kill 500 enemies', target: 500, rewards: {'echoes': 200, 'zcoins': 30}),
      () => WeeklyChallenge(id: 'w_pvp', name: 'Arena Legend', description: 'Win 20 PvP battles', target: 20, rewards: {'gemShards': 100, 'zcoins': 25}),
      () => WeeklyChallenge(id: 'w_dungeon', name: 'Depths', description: 'Clear 30 dungeon floors', target: 30, rewards: {'essence': 300, 'mythril': 15}),
      () => WeeklyChallenge(id: 'w_gold', name: 'Midas Touch', description: 'Earn 50,000 gold', target: 50000, rewards: {'zcoins': 40, 'echoes': 100}),
      () => WeeklyChallenge(id: 'w_boss', name: 'Boss Hunter', description: 'Defeat 10 bosses', target: 10, rewards: {'mythril': 20, 'echoes': 150}),
      () => WeeklyChallenge(id: 'w_gauntlet', name: 'Iron Will', description: 'Complete 3 gauntlet runs', target: 3, rewards: {'echoes': 250, 'zcoins': 20}),
      () => WeeklyChallenge(id: 'w_stages', name: 'Pathfinder', description: 'Clear 25 campaign stages', target: 25, rewards: {'shards': 150, 'zcoins': 35}),
      () => WeeklyChallenge(id: 'w_craft', name: 'Artisan', description: 'Craft or reforge 10 items', target: 10, rewards: {'essence': 200, 'mythril': 10}),
    ];
    // Pick 5 based on week seed
    final indices = <int>{};
    var s = weekSeed;
    while (indices.length < 5) {
      s = (s * 1103515245 + 12345) & 0x7fffffff;
      indices.add(s % pool.length);
    }
    return indices.map((i) => pool[i]()).toList();
  }
}
