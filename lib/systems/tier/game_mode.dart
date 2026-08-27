/// The play modes in the game. Tier difficulty scaling applies to PvE only —
/// competitive/social modes are deliberately left unscaled so ladders stay fair.
enum GameMode {
  campaign,
  dungeon,
  bossRush,
  gauntlet,
  towerAscension,
  expedition,
  // ── Excluded from tier scaling ──
  pvp,
  guild;

  /// Whether the active-tier multiplier applies to this mode.
  ///
  /// This is the single source of truth for the "Mode Enforcer": any scaling
  /// call routes through here, so PvP/Guild can never accidentally be scaled.
  bool get scalesWithTier => switch (this) {
        GameMode.campaign ||
        GameMode.dungeon ||
        GameMode.bossRush ||
        GameMode.gauntlet ||
        GameMode.towerAscension ||
        GameMode.expedition =>
          true,
        GameMode.pvp || GameMode.guild => false,
      };
}
