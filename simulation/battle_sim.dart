// ignore_for_file: avoid_print
import 'dart:math';

// ─────────────────────────────────────────────────────────────────────────────
// Zeta Idle — Standalone Battle Simulation
//
// Run: dart simulation/battle_sim.dart
//
// Simulates a Barbarian hero fighting every campaign stage enemy (stages 0–99)
// plus selected Abyss depths, using BARE stats (no upgrades / items / passives).
// Outputs win rate, average TTK, and average HP% remaining per stage.
//
// Purpose: balance audit — shows where upgrades become mandatory and how steep
// the difficulty wall is relative to the natural XP progression.
// ─────────────────────────────────────────────────────────────────────────────

const int kTrials    = 500;  // Monte Carlo trials per stage
const int kMaxRounds = 800;  // safety cap to prevent infinite loops

void main() {
  final rng = Random(12345);

  // Derive hero level/stats at each stage entry using XP progression
  final heroAtStage = _computeHeroProgression();

  _printHeader('CAMPAIGN (stages 0 – 99, Barbarian, no upgrades)');
  _printColumnHeadings();

  for (var s = 0; s < kCampaign.length; s++) {
    final e = kCampaign[s];
    final h = heroAtStage[s];
    final r = _runMonteCarlo(h, e, rng);
    _printRow(s, e, h, r);
  }

  // Abyss depths
  _printHeader('ABYSS (hero frozen at stage-99 stats, no upgrades)');
  _printColumnHeadings();
  final heroAbyss = heroAtStage.last;
  for (final depth in [1, 5, 10, 20, 30, 50, 75, 100]) {
    final e = _abyssEnemy(depth);
    final r = _runMonteCarlo(heroAbyss, e, rng);
    _printRow(99 + depth, e, heroAbyss, r);
  }

  // Hero level snapshot table
  _printHeader('HERO PROGRESSION (Barbarian auto-stat growth only)');
  print('  Stg  HLv  STR  CON  atkB dmgB  maxHP  healPct%');
  print('  ─────────────────────────────────────────────────');
  for (final s in [0, 5, 10, 15, 20, 25, 30, 35, 40, 50, 60, 70, 80, 90, 99]) {
    final h = heroAtStage[s];
    print('  ${_p(s, 3)}  ${_p(h.level, 3)}  ${_p(h.str, 3)}  ${_p(h.con, 3)}'
        '  ${_p(h.attackBonus, 4)} ${_p(h.damageMod, 4)}  ${_p(h.maxHp, 5)}'
        '  ${h.healPct}%');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero stat model (mirrors hero_model.dart — Barbarian class)
// ─────────────────────────────────────────────────────────────────────────────
class _Hero {
  int level, str, con;
  _Hero(this.level, this.str, this.con);

  int get strMod      => (str - 10) ~/ 2;
  int get conMod      => (con - 10) ~/ 2;
  int get profBonus   => 2 + (level - 1) ~/ 4;
  int get attackBonus => strMod + profBonus;
  int get damageMod   => strMod;
  // maxHealth = (30 + CON×8) + (level-1) × max(5+conMod, 1)  [from hero_model.dart:79]
  int get maxHp       => (30 + con * 8) + (level - 1) * (5 + conMod).clamp(1, 99);
  // DEX starts at 5, gains +1/2 levels as secondary for some classes (not Barbarian).
  // Barbarian secondary = CON, so DEX stays at base 5 → dexMod = -2 → AC = 8.
  int get ac          => 8;
  // Post-battle heal % [from game_state.dart:3257]
  int get healPct     => (8 + conMod * 4).clamp(4, 75);
  int postBattleHeal(int currentHp) =>
      (currentHp + (maxHp * healPct / 100).round()).clamp(0, maxHp);
}

/// Walk through the XP progression and record hero stats at the start of every
/// stage.  Single kill per stage is assumed (best-case progression speed).
/// XP formula: enemy.level × 56 + 150  [from game_state.dart, ×2 boost]
/// Starting stats: STR 5, CON 6, DEX 5 (all base stats halved)
List<_Hero> _computeHeroProgression() {
  int level = 1, str = 5, con = 6, xp = 0, threshold = 100;

  final out = <_Hero>[];
  for (final e in kCampaign) {
    out.add(_Hero(level, str, con));
    final gained = e.level * 56 + 150;
    xp += gained;
    while (xp >= threshold) {
      xp -= threshold;
      level++;
      threshold = (threshold * 1.22).round();
      str++;                    // primary stat +1/level
      if (level % 2 == 0) con++; // secondary stat +1/2 levels
      if (level % 3 == 0) con++; // CON bonus +1/3 levels
    }
  }
  out.add(_Hero(level, str, con)); // snapshot for Abyss entry
  return out;
}

// ─────────────────────────────────────────────────────────────────────────────
// Monte Carlo battle engine
// ─────────────────────────────────────────────────────────────────────────────
class _SimResult {
  final int wins, totalRounds, totalHpPct;
  _SimResult(this.wins, this.totalRounds, this.totalHpPct);
  double get winRate    => wins / kTrials * 100;
  double get avgRounds  => wins > 0 ? totalRounds / wins : 0;
  double get avgHpPct   => wins > 0 ? totalHpPct  / wins : 0;
}

_SimResult _runMonteCarlo(_Hero h, _Enemy e, Random rng) {
  int wins = 0, rounds = 0, hpPct = 0;
  for (var t = 0; t < kTrials; t++) {
    final r = _fight(h, e, rng);
    if (r.$1) {
      wins++;
      rounds += r.$2;
      hpPct  += r.$3;
    }
  }
  return _SimResult(wins, rounds, hpPct);
}

/// Returns (won, rounds, hpPctRemaining).
/// Combat order: hero attacks → if enemy alive, enemy attacks [battle_screen.dart:111-135]
/// Enemy attack bonus = enemy.level ~/ 2  [game_state.dart:2957]
/// Enemy damage = rng.nextInt(enemy.atk) + 1  [game_state.dart:2988]
(bool, int, int) _fight(_Hero h, _Enemy e, Random rng) {
  int heroHp  = h.maxHp;
  int enemyHp = e.hp;
  final eBonus = e.level ~/ 2;

  for (var round = 1; round <= kMaxRounds; round++) {
    // ── Hero attacks ──────────────────────────────────────────────
    final heroRoll = rng.nextInt(20) + 1; // d20
    if (heroRoll + h.attackBonus >= e.ac) {
      final dmg = (rng.nextInt(8) + 1 + h.damageMod).clamp(1, 9999); // d8+mod
      enemyHp -= dmg;
    }
    if (enemyHp <= 0) {
      return (true, round, (heroHp * 100 / h.maxHp).round());
    }

    // ── Enemy attacks ─────────────────────────────────────────────
    final eRoll = rng.nextInt(20) + 1;
    if (eRoll + eBonus >= h.ac) {
      heroHp -= rng.nextInt(e.atk) + 1; // 1..atk uniform
    }
    if (heroHp <= 0) return (false, 0, 0);
  }
  return (false, 0, 0); // timeout — treat as loss
}

// ─────────────────────────────────────────────────────────────────────────────
// Output helpers
// ─────────────────────────────────────────────────────────────────────────────
void _printHeader(String title) {
  print('');
  print('═' * 95);
  print('  $title');
  print('═' * 95);
}

void _printColumnHeadings() {
  print('  Fl  Stg  Enemy                  ELv  EHP  EATK EAC | HLv  ATK  DMG  HAC  MHP | Win%   Rnd  HP%');
  print('  ──  ───  ──────────────────────  ──  ────  ──── ──  | ──   ───  ───  ───  ─── | ────  ────  ───');
}

void _printRow(int stage, _Enemy e, _Hero h, _SimResult r) {
  final flag = r.winRate < 20 ? '✗✗' : r.winRate < 40 ? '✗ ' : r.winRate < 60 ? '▲ ' : '  ';
  print('  $flag  ${_p(stage, 3)}  ${e.name.padRight(22).substring(0, 22)}'
      '  ${_p(e.level, 3)} ${_p(e.hp, 5)} ${_p(e.atk, 4)} ${_p(e.ac, 3)}'
      ' | ${_p(h.level, 3)} ${_p(h.attackBonus, 4)} ${_p(h.damageMod, 4)}'
      '  ${_p(h.ac, 3)} ${_p(h.maxHp, 4)}'
      ' | ${r.winRate.toStringAsFixed(1).padLeft(5)}%'
      ' ${r.avgRounds.toStringAsFixed(1).padLeft(5)}'
      ' ${r.avgHpPct.toStringAsFixed(1).padLeft(5)}%');
}

String _p(int n, int w) => n.toString().padLeft(w);

// ─────────────────────────────────────────────────────────────────────────────
// Enemy data
// ─────────────────────────────────────────────────────────────────────────────
class _Enemy {
  final String name;
  final int level, hp, atk, ac;
  const _Enemy(this.name, this.level, this.hp, this.atk, this.ac);
}

_Enemy _abyssEnemy(int depth) {
  final growth = pow(1.06, depth).toDouble();
  final hp  = (220 * growth).round().clamp(220, 9999999);
  final atk = (45 * sqrt(growth)).round().clamp(45, 9999);
  final acBonus = min((log(depth + 1) / log(2) * 1.5).floor(), 12);
  final level = 13 + depth ~/ 5;
  return _Enemy('Abyss Depth $depth', level, hp, atk, 16 + acBonus);
}

// Campaign order mirrors EnemyData._campaignOrder  [enemy_data.dart:671–786]
const kCampaign = <_Enemy>[
  // ── Stage 0–24: Classic Dungeon ──────────────────────────────────────────
  _Enemy('Skeleton',            1,    55,    4, 10),
  _Enemy('Goblin',              1,    52,    4, 10),  // HP -13, ATK -1
  _Enemy('Imp',                 2,    60,    7, 11),
  _Enemy('Kobold',              2,    85,    7, 11),
  _Enemy('Pixie',               3,    65,    9, 14),
  _Enemy('Ghoul',               3,    82,    8, 10),  // HP -28, ATK -3, AC -1
  _Enemy('Gnoll',               4,   100,   10, 11),  // HP -35, ATK -4, AC -1
  _Enemy('Harpy',               4,    88,   11, 11),  // HP -27, ATK -5
  _Enemy('Cultist',             5,    95,   18, 11),
  _Enemy('Hobgoblin',           5,   140,   14, 12),  // AC -2, HP/ATK reduced
  _Enemy('Orc',                 6,   160,   16, 12),  // HP -30, ATK -4, AC -1
  _Enemy('Banshee',             6,   145,   24, 12),
  _Enemy('Gargoyle',            7,   180,   18, 14),
  _Enemy('Basilisk',            7,   200,   19, 12),
  _Enemy('Mummy',               8,   195,   18, 13),
  _Enemy('Wyvern',              8,   220,   20, 13),
  _Enemy('Golem',               9,   240,   18, 13),
  _Enemy('Succubus',            9,   175,   24, 12),
  _Enemy('Minotaur',           10,   240,   20, 12),
  _Enemy('Eyeball Watcher',    10,   200,   25, 11),
  _Enemy('Mind-Flayer',        11,   310,   40, 16),
  _Enemy('Chimera',            11,   385,   41, 16),
  _Enemy('Lich',               12,   335,   48, 15),
  _Enemy('Hydra',              12,   550,   44, 16),
  _Enemy('Phoenix',            13,   515,   48, 16),
  // ── Stage 25–49: Crystal Sanctum → Abyssal Ocean ─────────────────────────
  _Enemy('Crystal Shard',      13,   550,   52, 14),
  _Enemy('Prism Wraith',       13,   500,   56, 13),
  _Enemy('Gem Serpent',        14,   650,   55, 15),
  _Enemy('Crystal Guardian',   14,   740,   57, 18),
  _Enemy('Arcane Colossus',    15,   870,   68, 17),
  _Enemy('Shadow Stalker',     15,   580,   70, 14),
  _Enemy('Shade Assassin',     15,   530,   76, 13),
  _Enemy('Umbral Knight',      16,   760,   73, 19),
  _Enemy('Dark Phantom',       16,   620,   80, 14),
  _Enemy('Shade Sovereign',    17,  1050,   92, 17),
  _Enemy('Frost Sprite',       17,   630,   94, 14),
  _Enemy('Ice Wraith',         17,   580,  100, 13),
  _Enemy('Glacial Troll',      18,   950,   95, 17),
  _Enemy('Winter Wolf',        18,   780,  103, 15),
  _Enemy('Frost Dragon',       19,  1300,  118, 18),
  _Enemy('Storm Hawk',         19,   750,  120, 15),
  _Enemy('Thunder Elemental',  19,   820,  125, 14),
  _Enemy('Lightning Drake',    20,  1050,  122, 16),
  _Enemy('Storm Giant',        20,  1250,  126, 17),
  _Enemy('Storm Titan',        21,  1650,  144, 18),
  _Enemy('Deep Lurker',        21,  1050,  146, 15),
  _Enemy('Tide Wraith',        21,   960,  153, 14),
  _Enemy('Abyssal Shark',      22,  1300,  150, 16),
  _Enemy('Sea Colossus',       22,  1600,  148, 19),
  _Enemy('Krakentide',         23,  2100,  170, 18),
  // ── Stage 50–74: Twilight → Null Void ────────────────────────────────────
  _Enemy('Mirror Shade',       23,  1250,  172, 15),
  _Enemy('Echo Phantom',       23,  1150,  180, 14),
  _Enemy('Dream Stalker',      24,  1450,  177, 16),
  _Enemy('Nightmare Weaver',   24,  1350,  188, 15),
  _Enemy('Labyrinth Warden',   25,  2500,  210, 19),
  _Enemy('Archive Scribe',     25,  1550,  212, 16),
  _Enemy('Assembly Drone',     25,  1700,  208, 18),
  _Enemy('Vault Guardian',     26,  2100,  215, 20),
  _Enemy('Protocol Enforcer',  26,  1900,  225, 17),
  _Enemy('Eternal Sentinel',   27,  3000,  248, 20),
  _Enemy('Plague Rat',         27,  1800,  250, 15),
  _Enemy('Infected Soldier',   27,  2100,  246, 17),
  _Enemy('Rot Priest',         28,  2000,  262, 15),
  _Enemy('Corruption Beast',   28,  2700,  258, 18),
  _Enemy('Plague Mother',      29,  3800,  285, 18),
  _Enemy('Broken Seraph',      29,  2400,  288, 17),
  _Enemy('Divine Wraith',      29,  2200,  298, 16),
  _Enemy('Fallen Cherub',      30,  2600,  294, 17),
  _Enemy('Halo Specter',       30,  2450,  308, 16),
  _Enemy('Fallen Archangel',   31,  4500,  335, 19),
  _Enemy('Null Sprite',        31,  2800,  338, 16),
  _Enemy('Void Crawler',       31,  3100,  332, 17),
  _Enemy('Anti-Matter Constr.',32,  3600,  340, 19),
  _Enemy('Entropy Fiend',      32,  3300,  355, 17),
  _Enemy('Null Emperor',       33,  5500,  385, 20),
  // ── Stage 75–99: Eternal Prison → Omega Throne ───────────────────────────
  _Enemy('Shackle Beast',      33,  4200,  388, 18),
  _Enemy('Omega Warden',       33,  4600,  382, 20),
  _Enemy('Containment Golem',  34,  5500,  390, 21),
  _Enemy('Cell Breaker',       34,  4800,  405, 18),
  _Enemy('The Unbound',        35,  7000,  435, 21),
  _Enemy('Gate Crawler',       35,  5200,  438, 18),
  _Enemy('Sentinel Wraith',    35,  4800,  448, 17),
  _Enemy('Watcher Construct',  36,  6000,  445, 20),
  _Enemy('Siege Engine',       36,  7000,  442, 21),
  _Enemy('Gate Colossus',      37,  9500,  480, 22),
  _Enemy('Carrion Crawler',    37,  6500,  483, 18),
  _Enemy('God-Shard Elemental',37,  7200,  478, 19),
  _Enemy('Necrotic Abom.',     38,  8500,  486, 19),
  _Enemy('Scar Feeder',        38,  7800,  498, 18),
  _Enemy('The Devourer',       39, 12000,  530, 21),
  _Enemy('Boundary Wraith',    39,  8500,  533, 19),
  _Enemy('No-Return Specter',  39,  9000,  528, 18),
  _Enemy('Void Membrane',      40, 11000,  540, 20),
  _Enemy('Last Light Seraph',  40, 10000,  555, 19),
  _Enemy('Frontier Guardian',  41, 15000,  590, 22),
  _Enemy('Omega Herald',       41, 11000,  593, 20),
  _Enemy('Memory Shade',       41, 10500,  605, 19),
  _Enemy('Dark Hour Titan',    42, 14000,  615, 21),
  _Enemy('Throne Sentinel',    42, 16000,  620, 22),
  _Enemy('The Omega',          43, 25000,  660, 23),
];
