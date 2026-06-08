class BossRushResult {
  BossRushResult({
    required this.bossesDefeated,
    required this.totalBosses,
    required this.elapsedSeconds,
    required this.finalHpPct,
    required this.cleared,
  });

  final int bossesDefeated;
  final int totalBosses;
  final int elapsedSeconds;
  final double finalHpPct; // hero HP% when run ended (0 = died)
  final bool cleared;      // all bosses defeated

  int get score {
    if (bossesDefeated == 0) return 0;
    final base = bossesDefeated * 1000;
    // Speed bonus: under 3 min = full, scales down to 0 at 10 min
    final timeSec = elapsedSeconds.clamp(0, 600);
    final speedBonus = ((600 - timeSec) / 600 * 2000).round();
    // Survival bonus: hp remaining * 500
    final hpBonus = (finalHpPct * 500).round();
    return base + speedBonus + hpBonus;
  }

  String get rank {
    final s = score;
    if (s >= 4500) return 'S';
    if (s >= 3500) return 'A';
    if (s >= 2500) return 'B';
    if (s >= 1500) return 'C';
    return 'D';
  }
}
