/// Zeta Idle — All-Modes Balance Simulator
/// Run with: dart run tools/simulate_all_modes.dart
library;

import 'dart:math';

// ═══════════════════════════════════════════════════════════════
// SHARED: Hero model
// ═══════════════════════════════════════════════════════════════

class Hero {
  Hero({
    required this.level,
    required this.str,
    required this.dex,
    required this.con,
    this.extraAtk = 0,
    this.extraDmg = 0,
    this.extraAc  = 0,
    this.maxHpOverride,
  });

  final int level, str, dex, con;
  final int extraAtk, extraDmg, extraAc;
  final int? maxHpOverride;

  int get strMod     => (str - 10) ~/ 2;
  int get dexMod     => (dex - 10) ~/ 2;
  int get conMod     => (con - 10) ~/ 2;
  int get proficiency => 2 + (level - 1) ~/ 4;
  int get attackBonus => strMod + proficiency + extraAtk;
  int get damageMod   => strMod + extraDmg;
  int get maxHP       => maxHpOverride ??
      (10 + conMod) + (level - 1) * (5 + conMod).clamp(1, 99);
  int get ac          => 10 + dexMod + extraAc;
}

// Three progression snapshots used across all modes
Hero earlyHero()  => Hero(level:  8, str: 14, dex: 12, con: 14, extraAtk: 2, extraDmg: 1, extraAc:  3);
Hero midHero()    => Hero(level: 12, str: 16, dex: 14, con: 16, extraAtk: 4, extraDmg: 3, extraAc:  5);
Hero lateHero()   => Hero(level: 16, str: 18, dex: 16, con: 18, extraAtk: 8, extraDmg: 5, extraAc:  8);

// ═══════════════════════════════════════════════════════════════
// CAMPAIGN enemies (used as base for Dungeon and Endless)
// ═══════════════════════════════════════════════════════════════

class EnemySpec {
  const EnemySpec(this.stage, this.name, this.hp, this.atk, this.ac, this.level);
  final int stage, hp, atk, ac, level;
  final String name;
}

const campaign = [
  EnemySpec(0,  'Skeleton',     18,  4, 10, 1),
  EnemySpec(1,  'Goblin',       22,  5, 10, 1),
  EnemySpec(2,  'Imp',          20,  7, 11, 2),
  EnemySpec(3,  'Kobold',       28,  7, 11, 2),
  EnemySpec(4,  'Pixie',        22,  9, 14, 3),
  EnemySpec(5,  'Ghoul',        38, 10, 11, 3),
  EnemySpec(6,  'Gnoll',        45, 12, 12, 4),
  EnemySpec(7,  'Harpy',        38, 14, 11, 4),
  EnemySpec(8,  'Cultist',      32, 16, 11, 5),
  EnemySpec(9,  'Hobgoblin',    55, 14, 14, 5),
  EnemySpec(10, 'Orc',          68, 17, 13, 6),
  EnemySpec(11, 'Banshee',      48, 21, 12, 6),
  EnemySpec(12, 'Gargoyle',     75, 18, 17, 7),
  EnemySpec(13, 'Basilisk',     88, 20, 15, 7),
  EnemySpec(14, 'Mummy',       100, 18, 16, 8),
  EnemySpec(15, 'Wyvern',      105, 22, 15, 8),
  EnemySpec(16, 'Golem',       125, 20, 19, 9),
  EnemySpec(17, 'Succubus',     85, 28, 13, 9),
  EnemySpec(18, 'Minotaur',    135, 27, 14, 10),
  EnemySpec(19, 'EyeWatcher',   95, 32, 13, 10),
  EnemySpec(20, 'Mind-Flayer', 115, 35, 15, 11),
  EnemySpec(21, 'Chimera',     145, 36, 15, 11),
  EnemySpec(22, 'Lich',        155, 42, 14, 12),
  EnemySpec(23, 'Hydra',       210, 38, 16, 12),
  EnemySpec(24, 'Phoenix',     195, 42, 15, 13),
];

const kSims     = 10000;
const kMaxRounds = 300;

// ═══════════════════════════════════════════════════════════════
// MODE 1: ENDLESS
// ═══════════════════════════════════════════════════════════════

class EndlessEnemy {
  EndlessEnemy(this.depth) {
    final a    = depth;
    final base = a <= 100
        ? pow(1.06, a).toDouble()
        : pow(1.06, 100).toDouble() * (1 + (a - 100) * 0.02);
    hp  = (195 * base).round().clamp(195, 99999999);
    atk = (42 * sqrt(base)).round().clamp(42, 9999);
    ac  = 15 + min((log(a + 1) / log(2) * 1.5).round(), 12);
  }
  final int depth;
  late final int hp, atk, ac;
  bool get isBoss => depth % 5 == 4;
}

enum AffixMode { none, cursedGround, ironSkin, abyssalRoar, soulSiphon }

bool simulateEndlessFight(Hero hero, EndlessEnemy e, AffixMode affix, Random rng) {
  var eHp = e.isBoss ? (e.hp * 2.0).round() : e.hp;
  final eAtk = e.isBoss ? (e.atk * 1.25).round() : e.atk;
  final eAc  = e.isBoss ? e.ac + 2 : e.ac;
  var hHp = hero.maxHP;

  for (int r = 0; r < kMaxRounds; r++) {
    // Cursed Ground: hero loses 5% max HP at start of round
    if (affix == AffixMode.cursedGround) {
      hHp -= (hero.maxHP * 0.05).round().clamp(1, 9999);
      if (hHp <= 0) return false;
    }

    // Hero attacks
    final hRoll  = rng.nextInt(20) + 1;
    final hTotal = hRoll + hero.attackBonus;
    final hCrit  = hRoll == 20;
    if (hCrit || hTotal >= eAc) {
      var dmg = (hCrit ? (rng.nextInt(8) + 1) * 2 : rng.nextInt(8) + 1) + hero.damageMod;
      if (affix == AffixMode.ironSkin) dmg = (dmg - 2).clamp(1, 9999);
      if (affix == AffixMode.soulSiphon) eHp += (dmg * 0.15).round(); // siphon heals enemy
      eHp -= dmg;
    }
    if (eHp <= 0) return true;

    // Enemy attacks
    final eRoll  = rng.nextInt(20) + 1;
    final eBon   = (e.depth / 10).floor().clamp(0, 8);
    final eTotal = eRoll + eBon + (affix == AffixMode.abyssalRoar ? 3 : 0);
    final eCrit  = eRoll == 20;
    if (eCrit || eTotal >= hero.ac) {
      var rawDmg = rng.nextInt(eAtk > 0 ? eAtk : 1) + 1;
      if (eCrit) rawDmg = (rawDmg * 2);
      hHp -= rawDmg;
    }
    if (hHp <= 0) return false;
  }
  return false;
}

double endlessWinRate(Hero hero, int depth, AffixMode affix, Random rng) {
  final e = EndlessEnemy(depth);
  int wins = 0;
  for (int i = 0; i < kSims; i++) {
    if (simulateEndlessFight(hero, e, affix, Random(rng.nextInt(1 << 32)))) wins++;
  }
  return wins / kSims * 100;
}

void runEndlessSim() {
  print('\n' + '═' * 90);
  print('MODE 1: ENDLESS  (depths 1–150, $kSims sims each, new boss 2x HP / 1.25x ATK)');
  print('═' * 90);

  final depths = [1, 5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150];

  print('\nAFFIX: None');
  _endlessTable(depths, AffixMode.none);

  print('\nAFFIX: Cursed Ground (5% HP drain/round — active from depth 8)');
  _endlessTable(depths, AffixMode.cursedGround);

  print('\nAFFIX: Iron Skin (–2 to all damage output)');
  _endlessTable(depths, AffixMode.ironSkin);

  print('\nAFFIX: Abyssal Roar (+3 to enemy attack rolls — active from depth 33)');
  _endlessTable(depths, AffixMode.abyssalRoar);
}

void _endlessTable(List<int> depths, AffixMode affix) {
  final rng = Random(99);
  print('${"Dep".padRight(5)} ${"HP/ATK/AC".padRight(18)} ${"B?".padRight(4)} '
      '${"Early".padRight(9)} ${"Mid".padRight(9)} ${"Late".padRight(9)}');
  print('-' * 62);

  final wallDepths = <String, int?>{'Early': null, 'Mid': null, 'Late': null};

  for (final d in depths) {
    final e    = EndlessEnemy(d);
    final boss = e.isBoss ? '★' : ' ';
    final hp   = e.isBoss ? (e.hp * 2.0).round() : e.hp;
    final atk  = e.isBoss ? (e.atk * 1.25).round() : e.atk;
    final stats = '${hp}hp/${atk}atk/${e.ac}ac';

    final wr = [earlyHero(), midHero(), lateHero()]
        .map((h) => endlessWinRate(h, d, affix, Random(rng.nextInt(1 << 32))))
        .toList();

    final names = ['Early', 'Mid', 'Late'];
    for (var i = 0; i < 3; i++) {
      if (wallDepths[names[i]] == null && wr[i] < 50) wallDepths[names[i]] = d;
    }

    String fmt(double v) => '${v.toStringAsFixed(1).padLeft(5)}%';
    print('d${d.toString().padLeft(3)}  ${stats.padRight(18)} $boss    '
        '${fmt(wr[0])}   ${fmt(wr[1])}   ${fmt(wr[2])}');
  }

  print('  Wall (<50% win): Early≈d${wallDepths["Early"] ?? ">150"}  '
      'Mid≈d${wallDepths["Mid"] ?? ">150"}  Late≈d${wallDepths["Late"] ?? ">150"}');
}

// ═══════════════════════════════════════════════════════════════
// MODE 2: DUNGEON
// ═══════════════════════════════════════════════════════════════

class DungeonEnemy {
  DungeonEnemy(int floor, {bool isBoss = false}) {
    final stageIdx = (floor - 1).clamp(0, 24);
    final e        = campaign[stageIdx];
    final mult     = 1.0 + (floor - 1) * 0.08;
    final acBonus  = (floor / 5).clamp(0, 6).round();
    if (isBoss) {
      final bossStageIdx = ((floor - 1) * 2).clamp(0, 24);
      final be    = campaign[bossStageIdx];
      hp  = (be.hp * 2.5 * mult).round();
      atk = (be.atk * 1.6 * mult).round();
      ac  = be.ac + 2 + (floor / 5).clamp(0, 8).round();
    } else {
      hp  = (e.hp * mult).round();
      atk = (e.atk * mult).round();
      ac  = e.ac + acBonus;
    }
  }
  late final int hp, atk, ac;
}

bool simulateDungeonFight(
    Hero hero, DungeonEnemy e, Random rng,
    {int blessAtk = 0, int blessAc = 0, bool swiftness = false}) {
  var eHp = e.hp;
  var hHp = hero.maxHP;
  final hAtk = hero.attackBonus + blessAtk;
  final hAc  = hero.ac + blessAc;

  for (int r = 0; r < 60; r++) {
    // Hero attacks (double strike on round 0 if swiftness)
    final strikes = (r == 0 && swiftness) ? 2 : 1;
    for (int s = 0; s < strikes; s++) {
      final roll  = rng.nextInt(20) + 1;
      final total = roll + hAtk;
      final crit  = roll == 20;
      if (crit || total >= e.ac) {
        final dmg = max(1, (crit ? (rng.nextInt(8) + 1) * 2 : rng.nextInt(8) + 1) + hero.damageMod);
        eHp -= dmg;
      }
      if (eHp <= 0) return true;
    }

    final eRoll  = rng.nextInt(20) + 1;
    final eBonus = (e.atk / 8).round().clamp(0, 12);
    if (eRoll == 20 || eRoll + eBonus >= hAc) {
      var rawDmg = rng.nextInt(max(1, e.atk ~/ 3 + 1)) + 1;
      if (eRoll == 20) rawDmg *= 2;
      hHp -= rawDmg;
    }
    if (hHp <= 0) return false;
  }
  return false;
}

double dungeonWinRate(Hero hero, int floor, bool isBoss, Random rng,
    {int blessAtk = 0, int blessAc = 0}) {
  final e = DungeonEnemy(floor, isBoss: isBoss);
  int wins = 0;
  for (int i = 0; i < kSims; i++) {
    if (simulateDungeonFight(hero, e, Random(rng.nextInt(1 << 32)),
        blessAtk: blessAtk, blessAc: blessAc)) wins++;
  }
  return wins / kSims * 100;
}

void runDungeonSim() {
  print('\n' + '═' * 90);
  print('MODE 2: DUNGEON  (floors 1–20, $kSims sims each)');
  print('═' * 90);

  final rng   = Random(77);
  final floors = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 16, 18, 20];

  for (final profile in [
    ('Early',  earlyHero()),
    ('Mid',    midHero()),
    ('Late',   lateHero()),
  ]) {
    final (label, hero) = profile;
    print('\nHero: $label  (ATK ${hero.attackBonus} / DMG+${hero.damageMod} / AC ${hero.ac} / HP ${hero.maxHP})');
    print('${"Fl".padRight(4)} ${"Mob hp/atk/ac".padRight(16)} ${"Boss hp/atk/ac".padRight(18)} '
        '${"Mob%".padRight(8)} ${"Boss%".padRight(8)} ${"Boss+Bless%"}');
    print('-' * 72);

    int? mobWall, bossWall;
    for (final fl in floors) {
      final mob  = DungeonEnemy(fl);
      final boss = DungeonEnemy(fl, isBoss: true);
      final mobStats  = '${mob.hp}/${mob.atk}/${mob.ac}';
      final bossStats = '${boss.hp}/${boss.atk}/${boss.ac}';

      final mobWr   = dungeonWinRate(hero, fl, false, Random(rng.nextInt(1 << 32)));
      final bossWr  = dungeonWinRate(hero, fl, true,  Random(rng.nextInt(1 << 32)));
      // With blessings: +2 ATK, +2 AC (typical if player took both defense/offense blessings)
      final bossBlWr = fl % 5 == 0
          ? dungeonWinRate(hero, fl, true, Random(rng.nextInt(1 << 32)), blessAtk: 2, blessAc: 2)
          : double.nan;

      if (mobWall == null && mobWr < 50)   mobWall  = fl;
      if (bossWall == null && bossWr < 50) bossWall = fl;

      final blessStr = bossBlWr.isNaN ? '' : '${bossBlWr.toStringAsFixed(1).padLeft(5)}%';
      print('F${fl.toString().padLeft(2)}  ${mobStats.padRight(16)} ${bossStats.padRight(18)} '
          '${mobWr.toStringAsFixed(1).padLeft(5)}%   '
          '${bossWr.toStringAsFixed(1).padLeft(5)}%   $blessStr');
    }
    print('  Wall <50%:  mob floor≈${mobWall ?? ">20"}  boss floor≈${bossWall ?? ">20"}');
  }
}

// ═══════════════════════════════════════════════════════════════
// MODE 3: PvP
// ═══════════════════════════════════════════════════════════════

class PvpBot {
  PvpBot(int myRating, Random rng) {
    final level = max(1, myRating ~/ 80);
    rating  = (myRating + rng.nextInt(200) - 100).clamp(100, 9999);
    maxHp   = (10 + level * 5).clamp(10, 999);
    atkBonus = (2 + level / 3).clamp(1.0, 20.0).round();
    dmgMod  = (level / 4).clamp(0.0, 10.0).round();
    ac      = (10 + level / 4).clamp(10.0, 20.0).round();
  }
  late final int rating, maxHp, atkBonus, dmgMod, ac;
}

class PvpHero {
  PvpHero(int rating) {
    // Hero investment scaled to rating bracket
    final level = max(1, rating ~/ 80);
    maxHp    = (10 + level * 6).clamp(10, 999); // slightly better CON
    atkBonus = (3 + level / 3).clamp(1.0, 20.0).round() + 2; // items
    dmgMod   = (level / 4).clamp(0.0, 10.0).round() + 1;
    ac       = (11 + level / 4).clamp(10.0, 20.0).round() + 2;
  }
  late final int maxHp, atkBonus, dmgMod, ac;
}

bool simulatePvpFight(PvpHero hero, PvpBot bot, Random rng) {
  var hHp = hero.maxHp;
  var bHp = bot.maxHp;

  for (int r = 0; r < 200; r++) {
    // Hero attacks
    final hRoll = rng.nextInt(20) + 1;
    final hCrit = hRoll == 20;
    if (hCrit || hRoll + hero.atkBonus >= bot.ac) {
      final dmg = max(1, (hCrit ? (rng.nextInt(8) + 1) * 2 : rng.nextInt(8) + 1) + hero.dmgMod);
      bHp -= dmg;
    }
    if (bHp <= 0) return true;

    // Bot attacks using the same d20+atkBonus / 1d8+dmgMod system as the hero
    final bRoll = rng.nextInt(20) + 1;
    final bCrit = bRoll == 20;
    if (bCrit || bRoll + bot.atkBonus >= hero.ac) {
      var dmg = max(1, (bCrit ? (rng.nextInt(8) + 1) * 2 : rng.nextInt(8) + 1) + bot.dmgMod);
      hHp -= dmg;
    }
    if (hHp <= 0) return false;
  }
  return false; // timeout
}

double pvpWinRate(int myRating, Random rng) {
  final hero = PvpHero(myRating);
  int wins = 0;
  for (int i = 0; i < kSims; i++) {
    final bot = PvpBot(myRating, rng);
    if (simulatePvpFight(hero, bot, Random(rng.nextInt(1 << 32)))) wins++;
  }
  return wins / kSims * 100;
}

void runPvpSim() {
  print('\n' + '═' * 90);
  print('MODE 3: PvP  (hero vs generated bots, $kSims sims per rating bracket)');
  print('═' * 90);
  print('Note: Hero modeled with slight item advantage (+2 ATK, +1 DMG, +2 AC) over bot.');
  print('');

  final rng     = Random(55);
  final ratings = [200, 400, 600, 800, 1000, 1200, 1400, 1600, 1800, 2000];

  print('${"Rating".padRight(9)} ${"HeroHP/ATK/AC".padRight(16)} ${"BotHP/ATK/AC(typ)".padRight(20)} WinRate');
  print('-' * 60);

  for (final r in ratings) {
    final hero    = PvpHero(r);
    final botSample = PvpBot(r, Random(42));
    final wr = pvpWinRate(r, Random(rng.nextInt(1 << 32)));

    print('${r.toString().padRight(9)} '
        '${('${hero.maxHp}/${hero.atkBonus}/${hero.ac}').padRight(16)} '
        '${('${botSample.maxHp}/${botSample.atkBonus}/${botSample.ac}').padRight(20)} '
        '${wr.toStringAsFixed(1).padLeft(5)}%');
  }

  print('');
  print('Expected: ~55-65% across brackets (player has slight item advantage over bots).');
  print('Values below 50% suggest the rating bracket produces bots that are too strong.');
  print('Values above 75% suggest the bracket is too easy — rating inflation risk.');
}

// ═══════════════════════════════════════════════════════════════
// MODE 4: DAILY CHALLENGES — effort estimate (no combat needed)
// ═══════════════════════════════════════════════════════════════

void runDailySim() {
  print('\n' + '═' * 90);
  print('MODE 4: DAILY CHALLENGES — effort estimate per challenge type');
  print('═' * 90);
  print('');

  // Assumptions: ~2 rounds/battle on avg, 3 ability uses/battle, 10 idle collects/session
  const roundsPerBattle = 2.0;
  const abilitiesPerBattle = 3.0;
  const idleCollectsPerMin = 0.2; // one collect every 5 min via timer

  final challenges = [
    ('Kill Enemies (Easy)',   'Kill 10',  '~5 battles',   '5-10 min'),
    ('Kill Enemies (Hard)',   'Kill 15',  '~8 battles',   '8-15 min'),
    ('Win Battles (Easy)',    'Win 5',    '5 battles',    '5-10 min'),
    ('Win Battles (Hard)',    'Win 8',    '8 battles',    '8-15 min'),
    ('Use Abilities (Easy)',  'Use 5',    '~2 battles',   '2-5 min'),
    ('Use Abilities (Hard)',  'Use 8',    '~3 battles',   '3-7 min'),
    ('Collect Idle (Easy)',   'Collect 3','~15 min idle', '15 min'),
    ('Collect Idle (Hard)',   'Collect 5','~25 min idle', '25 min'),
    ('Deal Damage (Easy)',    '200 dmg',  '~3 battles',   '3-6 min'),
    ('Deal Damage (Hard)',    '350 dmg',  '~5 battles',   '5-10 min'),
    ('Reach Gold (Easy)',     '500 gold', '3-5 battles',  '5-10 min'),
    ('Reach Gold (Hard)',     '750 gold', '4-7 battles',  '8-15 min'),
    ('Equip Item',            '1 item',   '1 loot drop',  '1-3 min'),
    ('Defeat Boss',           '1 boss',   '1 boss fight', '5-10 min'),
  ];

  print('${"Challenge".padRight(28)} ${"Target".padRight(18)} ${"Effort".padRight(20)} Est. Time');
  print('-' * 78);
  for (final (name, target, effort, time) in challenges) {
    print('${name.padRight(28)} ${target.padRight(18)} ${effort.padRight(20)} $time');
  }

  print('');
  print('All 7 daily challenges combined: ~45-90 min for a full clear.');
  print('Idle Collect challenges are the longest without fast-forward.');
  print('Boss challenge is gated by hero power — stage 4 boss (Pixie) is the first boss.');
}

// ═══════════════════════════════════════════════════════════════
// MAIN
// ═══════════════════════════════════════════════════════════════

void main() {
  print('ZETA IDLE — All-Modes Balance Report');
  print('Simulations per data point: $kSims');
  print('');
  print('Hero profiles:');
  print('  Early : Lv8  STR14/DEX12/CON14  +2ATK +1DMG +3AC  '
      '→ ATK ${earlyHero().attackBonus} DMG+${earlyHero().damageMod} AC${earlyHero().ac} HP${earlyHero().maxHP}');
  print('  Mid   : Lv12 STR16/DEX14/CON16  +4ATK +3DMG +5AC  '
      '→ ATK ${midHero().attackBonus} DMG+${midHero().damageMod} AC${midHero().ac} HP${midHero().maxHP}');
  print('  Late  : Lv16 STR18/DEX16/CON18  +8ATK +5DMG +8AC  '
      '→ ATK ${lateHero().attackBonus} DMG+${lateHero().damageMod} AC${lateHero().ac} HP${lateHero().maxHP}');

  runEndlessSim();
  runDungeonSim();
  runPvpSim();
  runDailySim();

  print('\n' + '═' * 90);
  print('END OF REPORT');
  print('═' * 90);
}
