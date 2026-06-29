class SeasonPassTier {
  const SeasonPassTier({
    required this.tier,
    required this.xpRequired,
    required this.freeReward,
    required this.freeIcon,
    this.premiumReward,
    this.premiumIcon,
  });

  final int tier, xpRequired;
  final String freeReward, freeIcon;
  final String? premiumReward, premiumIcon;

  Map<String, int> get freeRewards => _parse(freeReward);
  Map<String, int> get premiumRewards => premiumReward != null ? _parse(premiumReward!) : {};

  static Map<String, int> _parse(String s) {
    final map = <String, int>{};
    for (final part in s.split(',')) {
      final trimmed = part.trim();
      final match = RegExp(r'(\d+)\s+(\w+)').firstMatch(trimmed);
      if (match != null) map[match.group(2)!] = int.parse(match.group(1)!);
    }
    return map;
  }

  static const tiers = [
    SeasonPassTier(tier: 1,  xpRequired: 100,  freeReward: '500 gold',           freeIcon: '💰', premiumReward: '10 crystals',        premiumIcon: '💎'),
    SeasonPassTier(tier: 2,  xpRequired: 200,  freeReward: '20 shards',          freeIcon: '◆',  premiumReward: '30 shards',           premiumIcon: '◆'),
    SeasonPassTier(tier: 3,  xpRequired: 350,  freeReward: '15 echoes',          freeIcon: '🔊', premiumReward: '30 echoes',           premiumIcon: '🔊'),
    SeasonPassTier(tier: 4,  xpRequired: 500,  freeReward: '1000 gold',          freeIcon: '💰', premiumReward: '20 crystals',         premiumIcon: '💎'),
    SeasonPassTier(tier: 5,  xpRequired: 700,  freeReward: '50 essence',         freeIcon: '✦',  premiumReward: '100 essence, 5 mythril', premiumIcon: '⬡'),
    SeasonPassTier(tier: 6,  xpRequired: 900,  freeReward: '30 shards',          freeIcon: '◆',  premiumReward: '15 crystals',         premiumIcon: '💎'),
    SeasonPassTier(tier: 7,  xpRequired: 1150, freeReward: '2000 gold',          freeIcon: '💰', premiumReward: '50 echoes',           premiumIcon: '🔊'),
    SeasonPassTier(tier: 8,  xpRequired: 1400, freeReward: '25 echoes',          freeIcon: '🔊', premiumReward: '30 crystals',         premiumIcon: '💎'),
    SeasonPassTier(tier: 9,  xpRequired: 1700, freeReward: '50 shards',          freeIcon: '◆',  premiumReward: '100 essence',         premiumIcon: '✦'),
    SeasonPassTier(tier: 10, xpRequired: 2000, freeReward: '3000 gold, 20 crystals', freeIcon: '🎁', premiumReward: '50 crystals, 10 mythril', premiumIcon: '👑'),
    SeasonPassTier(tier: 11, xpRequired: 2400, freeReward: '40 shards',          freeIcon: '◆',  premiumReward: '40 echoes',           premiumIcon: '🔊'),
    SeasonPassTier(tier: 12, xpRequired: 2800, freeReward: '3000 gold',          freeIcon: '💰', premiumReward: '25 crystals',         premiumIcon: '💎'),
    SeasonPassTier(tier: 13, xpRequired: 3300, freeReward: '75 essence',         freeIcon: '✦',  premiumReward: '150 essence',         premiumIcon: '✦'),
    SeasonPassTier(tier: 14, xpRequired: 3800, freeReward: '40 echoes',          freeIcon: '🔊', premiumReward: '35 crystals',         premiumIcon: '💎'),
    SeasonPassTier(tier: 15, xpRequired: 4400, freeReward: '5000 gold, 30 crystals', freeIcon: '🎁', premiumReward: '75 crystals, 15 mythril', premiumIcon: '👑'),
    SeasonPassTier(tier: 16, xpRequired: 5000, freeReward: '60 shards',          freeIcon: '◆',  premiumReward: '50 echoes',           premiumIcon: '🔊'),
    SeasonPassTier(tier: 17, xpRequired: 5700, freeReward: '5000 gold',          freeIcon: '💰', premiumReward: '40 crystals',         premiumIcon: '💎'),
    SeasonPassTier(tier: 18, xpRequired: 6400, freeReward: '100 essence',        freeIcon: '✦',  premiumReward: '200 essence',         premiumIcon: '✦'),
    SeasonPassTier(tier: 19, xpRequired: 7200, freeReward: '60 echoes',          freeIcon: '🔊', premiumReward: '50 crystals',         premiumIcon: '💎'),
    SeasonPassTier(tier: 20, xpRequired: 8000, freeReward: '8000 gold, 50 crystals', freeIcon: '🎁', premiumReward: '100 crystals, 20 mythril', premiumIcon: '👑'),
    SeasonPassTier(tier: 21, xpRequired: 9000, freeReward: '80 shards',          freeIcon: '◆',  premiumReward: '75 echoes',           premiumIcon: '🔊'),
    SeasonPassTier(tier: 22, xpRequired: 10000, freeReward: '8000 gold',         freeIcon: '💰', premiumReward: '60 crystals',         premiumIcon: '💎'),
    SeasonPassTier(tier: 23, xpRequired: 11200, freeReward: '150 essence',       freeIcon: '✦',  premiumReward: '300 essence, 10 mythril', premiumIcon: '⬡'),
    SeasonPassTier(tier: 24, xpRequired: 12500, freeReward: '80 echoes',         freeIcon: '🔊', premiumReward: '70 crystals',         premiumIcon: '💎'),
    SeasonPassTier(tier: 25, xpRequired: 14000, freeReward: '10000 gold, 75 crystals', freeIcon: '🎁', premiumReward: '150 crystals, 25 mythril', premiumIcon: '👑'),
    SeasonPassTier(tier: 26, xpRequired: 15500, freeReward: '100 shards',        freeIcon: '◆',  premiumReward: '100 echoes',          premiumIcon: '🔊'),
    SeasonPassTier(tier: 27, xpRequired: 17500, freeReward: '12000 gold',        freeIcon: '💰', premiumReward: '80 crystals',         premiumIcon: '💎'),
    SeasonPassTier(tier: 28, xpRequired: 19500, freeReward: '200 essence',       freeIcon: '✦',  premiumReward: '400 essence, 15 mythril', premiumIcon: '⬡'),
    SeasonPassTier(tier: 29, xpRequired: 22000, freeReward: '100 echoes',        freeIcon: '🔊', premiumReward: '100 crystals',        premiumIcon: '💎'),
    SeasonPassTier(tier: 30, xpRequired: 25000, freeReward: '20000 gold, 100 crystals', freeIcon: '👑', premiumReward: '200 crystals, 50 mythril', premiumIcon: '⚔'),
  ];
}
