class GauntletResult {
  const GauntletResult({
    required this.kills,
    required this.totalEnemies,
    required this.cleared,
    required this.score,
    required this.shardsEarned,
    required this.crystalsEarned,
    required this.modifierIds,
  });

  final int kills;
  final int totalEnemies;
  final bool cleared;
  final int score;
  final int shardsEarned;
  final int crystalsEarned;
  final List<String> modifierIds;
}
