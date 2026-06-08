class LoginReward {
  const LoginReward({
    required this.day,
    this.gold = 0,
    this.crystals = 0,
    this.shards = 0,
    this.mythril = 0,
    this.essence = 0,
    required this.label,
    required this.icon,
  });
  final int day;
  final int gold;
  final int crystals;
  final int shards;
  final int mythril;
  final int essence;
  final String label;
  final String icon;

  static const cycle = [
    LoginReward(day: 1, gold: 500,  label: '500 Gold',      icon: '💰'),
    LoginReward(day: 2, crystals: 5, label: '5 Crystals',   icon: '💎'),
    LoginReward(day: 3, shards: 15,  label: '15 Shards',    icon: '◆'),
    LoginReward(day: 4, mythril: 3,  label: '3 Mythril',    icon: '⬡'),
    LoginReward(day: 5, crystals: 15, gold: 1000, label: '1000 Gold + 15 💎', icon: '🎁'),
    LoginReward(day: 6, shards: 50, essence: 100, label: '50 Shards + 100 Essence', icon: '✨'),
    LoginReward(day: 7, crystals: 50, label: '50 Crystals', icon: '👑'),
  ];

  // day is 1-indexed; cycleIndex is 0-indexed into the cycle list
  static LoginReward forDay(int day) => cycle[(day - 1) % cycle.length];
}
