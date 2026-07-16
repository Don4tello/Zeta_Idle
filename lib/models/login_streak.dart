class LoginReward {
  const LoginReward({
    required this.day,
    this.gold = 0,
    this.zcoins = 0,
    this.shards = 0,
    this.echoes = 0,
    this.mythril = 0,
    this.essence = 0,
    this.isEpicItem = false,
    this.isClassLegendary = false,
    required this.label,
    required this.icon,
  });
  final int day;
  final int gold;
  final int zcoins;
  final int shards;
  final int echoes;
  final int mythril;
  final int essence;
  final String label;
  final String icon;

  static const cycle = [
    // Week 1
    LoginReward(day: 1,  gold: 1000,  label: '1000 Gold',       icon: '💰'),
    LoginReward(day: 2,  zcoins: 10, label: '10 ZCoins',    icon: '🪙'),
    LoginReward(day: 3,  shards: 30, echoes: 30, label: '30 Shards + 30 Echoes', icon: '◆'),
    LoginReward(day: 4,  mythril: 6,  label: '6 Mythril',       icon: '⬡'),
    LoginReward(day: 5,  zcoins: 30, gold: 2000, label: '2000 Gold + 30 🪙', icon: '🎁'),
    LoginReward(day: 6,  shards: 100, essence: 200, label: '100 Shards + 200 Essence', icon: '✨'),
    LoginReward(day: 7,  zcoins: 100, echoes: 100, label: '100 ZCoins + 100 Echoes', icon: '👑'),
    // Week 2
    LoginReward(day: 8,  gold: 1500,  label: '1500 Gold',       icon: '💰'),
    LoginReward(day: 9,  essence: 100, label: '100 Essence',    icon: '✦'),
    LoginReward(day: 10, shards: 50, echoes: 50, label: '50 Shards + 50 Echoes', icon: '◆'),
    LoginReward(day: 11, mythril: 10, label: '10 Mythril',      icon: '⬡'),
    LoginReward(day: 12, zcoins: 20, gold: 2500, label: '2500 Gold + 20 🪙', icon: '🎁'),
    LoginReward(day: 13, shards: 75, essence: 150, label: '75 Shards + 150 Essence', icon: '✨'),
    LoginReward(day: 14, zcoins: 50, echoes: 75, isEpicItem: true, label: '50🪙 + 75🔊 + Epic Item!', icon: '👑'),
    // Week 3
    LoginReward(day: 15, gold: 2000,  label: '2000 Gold',       icon: '💰'),
    LoginReward(day: 16, zcoins: 25, label: '25 ZCoins',    icon: '🪙'),
    LoginReward(day: 17, echoes: 100, label: '100 Echoes',      icon: '🔊'),
    LoginReward(day: 18, mythril: 15, label: '15 Mythril',      icon: '⬡'),
    LoginReward(day: 19, zcoins: 40, gold: 3000, label: '3000 Gold + 40 🪙', icon: '🎁'),
    LoginReward(day: 20, shards: 150, essence: 300, label: '150 Shards + 300 Essence', icon: '✨'),
    LoginReward(day: 21, zcoins: 75, echoes: 100, label: '75 ZCoins + 100 Echoes', icon: '👑'),
    // Week 4 — grand finale
    LoginReward(day: 22, gold: 3000,  label: '3000 Gold',       icon: '💰'),
    LoginReward(day: 23, essence: 250, label: '250 Essence',    icon: '✦'),
    LoginReward(day: 24, shards: 100, echoes: 100, label: '100 Shards + 100 Echoes', icon: '◆'),
    LoginReward(day: 25, mythril: 20, label: '20 Mythril',      icon: '⬡'),
    LoginReward(day: 26, zcoins: 50, gold: 5000, label: '5000 Gold + 50 🪙', icon: '🎁'),
    LoginReward(day: 27, shards: 200, essence: 400, echoes: 150, label: '200◆ + 400✦ + 150🔊', icon: '✨'),
    LoginReward(day: 28, zcoins: 100, label: '100 ZCoins',  icon: '🪙'),
    LoginReward(day: 29, gold: 10000, zcoins: 50, echoes: 200, label: '10K Gold + 50🪙 + 200🔊', icon: '🎁'),
    LoginReward(day: 30, isClassLegendary: true, label: 'Class Legendary Item!', icon: '⚔'),
  ];

  final bool isEpicItem;
  final bool isClassLegendary;

  static LoginReward forDay(int day) => cycle[(day - 1) % cycle.length];
}
