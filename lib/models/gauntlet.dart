class GauntletResult {
  const GauntletResult({
    required this.kills,
    required this.totalEnemies,
    required this.cleared,
    required this.score,
    required this.essenceEarned,
    required this.crystalsEarned,
    required this.echoesEarned,
    required this.modifierIds,
  });

  final int kills;
  final int totalEnemies;
  final bool cleared;
  final int score;
  final int essenceEarned;
  final int crystalsEarned;
  final int echoesEarned;
  final List<String> modifierIds;
}
