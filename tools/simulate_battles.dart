/// Battle difficulty simulator for Zeta Idle.
/// Run with: dart run tools/simulate_battles.dart
library;

import 'dart:math';

// ─── Data ─────────────────────────────────────────────────────────────────────

class EnemySpec {
  const EnemySpec(this.stage, this.name, this.hp, this.atk, this.ac, this.level);
  final int stage, hp, atk, ac, level;
  final String name;
}

final campaign = [
  EnemySpec(0,  'Skeleton',       18,  4,  10, 1),
  EnemySpec(1,  'Goblin',         22,  5,  10, 1),
  EnemySpec(2,  'Imp',            20,  7,  11, 2),
  EnemySpec(3,  'Kobold',         28,  7,  11, 2),
  EnemySpec(4,  'Pixie',          22,  9,  14, 3),
  EnemySpec(5,  'Ghoul',          38,  10, 11, 3),
  EnemySpec(6,  'Gnoll',          45,  12, 12, 4),
  EnemySpec(7,  'Harpy',          38,  14, 11, 4),
  EnemySpec(8,  'Cultist',        32,  16, 11, 5),
  EnemySpec(9,  'Hobgoblin',      55,  14, 14, 5),
  EnemySpec(10, 'Orc',            68,  17, 13, 6),
  EnemySpec(11, 'Banshee',        48,  21, 12, 6),
  EnemySpec(12, 'Gargoyle',       75,  18, 17, 7),
  EnemySpec(13, 'Basilisk',       88,  20, 15, 7),
  EnemySpec(14, 'Mummy',         100,  18, 16, 8),
  EnemySpec(15, 'Wyvern',        105,  22, 15, 8),
  EnemySpec(16, 'Golem',         125,  20, 19, 9),
  EnemySpec(17, 'Succubus',       85,  28, 13, 9),
  EnemySpec(18, 'Minotaur',      135,  27, 14, 10),
  EnemySpec(19, 'EyeWatcher',     95,  32, 13, 10),
  EnemySpec(20, 'Mind-Flayer',   115,  35, 15, 11),
  EnemySpec(21, 'Chimera',       145,  36, 15, 11),
  EnemySpec(22, 'Lich',          155,  42, 14, 12),
  EnemySpec(23, 'Hydra',         210,  38, 16, 12),
  EnemySpec(24, 'Phoenix',       195,  42, 15, 13),
];

// ─── Hero ─────────────────────────────────────────────────────────────────────

class Hero {
  int level = 1;
  int xp    = 0;
  int xpNext = 100;

  int str = 10, dex = 10, con = 12;
  // Extra bonuses from items / upgrades (additive)
  int extraAtk = 0, extraDmg = 0, extraAc = 0;

  int get strMod => (str - 10) ~/ 2;
  int get dexMod => (dex - 10) ~/ 2;
  int get conMod => (con - 10) ~/ 2;

  int get proficiency  => 2 + (level - 1) ~/ 4;
  int get attackBonus  => strMod + proficiency + extraAtk;
  int get damageMod    => strMod + extraDmg;
  int get maxHP        => (10 + conMod) + (level - 1) * (5 + conMod).clamp(1, 99);
  int get ac           => 10 + dexMod + extraAc;

  void gainXP(int amount) {
    xp += amount;
    while (xp >= xpNext) {
      xp -= xpNext;
      level++;
      xpNext = (xpNext * 1.20).round();
    }
  }
}

// ─── Hero profiles ─────────────────────────────────────────────────────────────

/// Baseline: no upgrades, no items. Hero levels up from clearing prior stages.
Hero naturalHero(int throughStage) {
  final h = Hero();
  for (int s = 0; s < throughStage; s++) {
    final e = campaign[s];
    h.gainXP(e.level * 35 + 90);
  }
  return h;
}

/// Invested player: buys STR/CON/DEX upgrades with gold accumulated
/// from stages 0..throughStage-1. Spends 40% on STR, 40% on CON, 20% on DEX.
/// Upgrade cost model: level 1=baseCost, level 2=baseCost*2, etc.
/// STR baseCost=75, CON=90, DEX=80; each level +2 to that stat.
Hero investedHero(int throughStage) {
  final h = naturalHero(throughStage);

  // Estimate gold earned from clearing stages 0..throughStage-1.
  // Boss stages (stage%5==4) triple the gold reward.
  double gold = 250.0; // starting gold
  for (int s = 0; s < throughStage; s++) {
    final e = campaign[s];
    final baseGold = (e.level * 50 + 100).toDouble();
    final isBoss   = s % 5 == 4;
    gold += isBoss ? baseGold * 3 : baseGold;
  }
  // Also add some idle gold (conservative: 60g/min × ~5 min per stage)
  gold += throughStage * 300.0;

  // Simple greedy budget: spend 40/40/20 split on STR/CON/DEX
  // Each upgrade level costs baseCost * levelIndex (1-indexed).
  const strBase = 75, conBase = 90, dexBase = 80;
  const maxLevel = 6;

  int strLvl = 0, conLvl = 0, dexLvl = 0;

  // Buy as many CON levels as 40% budget allows, then STR (40%), then DEX (20%)
  for (var budget = gold * 0.40; conLvl < maxLevel;) {
    final cost = conBase * (conLvl + 1);
    if (cost > budget) break;
    budget -= cost;
    conLvl++;
    h.con += 2;
  }
  for (var budget = gold * 0.40; strLvl < maxLevel;) {
    final cost = strBase * (strLvl + 1);
    if (cost > budget) break;
    budget -= cost;
    strLvl++;
    h.str += 2;
  }
  for (var budget = gold * 0.20; dexLvl < maxLevel;) {
    final cost = dexBase * (dexLvl + 1);
    if (cost > budget) break;
    budget -= cost;
    dexLvl++;
    h.dex += 2;
  }
  return h;
}

/// Max invested: add typical item bonuses on top of invested hero.
/// Assumes rough +2 ATK, +2 DMG, +3 AC from common/rare items by mid-campaign.
Hero itemHero(int throughStage) {
  final h = investedHero(throughStage);
  // Items scale with stage (common→rare→epic)
  final itemTier = throughStage < 8 ? 0 : throughStage < 16 ? 1 : 2;
  h.extraAtk = [1, 2, 4][itemTier];
  h.extraDmg = [1, 2, 4][itemTier];
  h.extraAc  = [1, 3, 5][itemTier];
  return h;
}

// ─── Simulation ───────────────────────────────────────────────────────────────

const kSims     = 20000;
const kMaxRounds = 200;

// Boss multipliers — run with both old and new values
const kBossHpMult_old  = 3.0;
const kBossAtkMult_old = 1.5;
const kBossHpMult_new  = 2.0;
const kBossAtkMult_new = 1.25;

(bool, int, int) simulateFight(
  Hero hero,
  int enemyHP,
  int enemyATK,
  int enemyAC,
  int enemyLevel,
  bool isBoss,
  double hpMult,
  double atkMult,
  Random rng,
) {
  int eHP  = isBoss ? (enemyHP * hpMult).round()  : enemyHP;
  final eATK = isBoss ? (enemyATK * atkMult).round() : enemyATK;
  final eAC  = isBoss ? enemyAC + 2 : enemyAC;
  final eBon = enemyLevel ~/ 2;

  int hHP = hero.maxHP;
  bool enraged = false;

  for (int r = 0; r < kMaxRounds; r++) {
    final hRoll  = rng.nextInt(20) + 1;
    final hTotal = hRoll + hero.attackBonus;
    final crit   = hRoll == 20;
    if (crit || hTotal >= eAC) {
      final die  = rng.nextInt(8) + 1;
      final dmg  = max(1, (crit ? die * 2 : die) + hero.damageMod);
      eHP -= dmg;
    }
    if (isBoss && !enraged && eHP <= enemyHP * hpMult * 0.3) enraged = true;
    if (eHP <= 0) return (true, r + 1, hHP);

    final eRoll  = rng.nextInt(20) + 1;
    final eTotal = eRoll + eBon;
    if (eTotal >= hero.ac) {
      var rawDmg = rng.nextInt(eATK) + 1;
      if (enraged) rawDmg = (rawDmg * 1.5).round();
      hHP -= rawDmg;
    }
    if (hHP <= 0) return (false, r + 1, 0);
  }
  return (false, kMaxRounds, 0);
}

double winRate(Hero Function(int) heroFn, int stage, double hpMult, double atkMult, Random rng) {
  final e      = campaign[stage];
  final hero   = heroFn(stage);
  final isBoss = stage % 5 == 4;
  int wins = 0;
  for (int i = 0; i < kSims; i++) {
    final (won, _, __) = simulateFight(
        hero, e.hp, e.atk, e.ac, e.level, isBoss, hpMult, atkMult, rng);
    if (won) wins++;
  }
  return wins / kSims * 100;
}

// ─── Main ─────────────────────────────────────────────────────────────────────

void main() {
  final rng = Random(42);

  print('ZETA IDLE — Battle Difficulty Report (with upgrades modeled)');
  print('Simulations per stage: $kSims\n');

  print('HERO PROFILES AT EACH STAGE:');
  print('${"St".padRight(3)} ${"Enemy".padRight(14)} ${"Nat(atk/ac/hp)".padRight(16)} ${"Invested".padRight(16)} ${"+ Items".padRight(16)} B?');
  print('-' * 72);
  for (final e in campaign) {
    final n = naturalHero(e.stage);
    final inv = investedHero(e.stage);
    final itm = itemHero(e.stage);
    final boss = e.stage % 5 == 4 ? '★' : '';
    print(
      '${e.stage.toString().padRight(3)} '
      '${e.name.padRight(14)} '
      '${('Lv${n.level} ${n.attackBonus}/${n.ac}/${n.maxHP}').padRight(16)} '
      '${('Lv${inv.level} ${inv.attackBonus}/${inv.ac}/${inv.maxHP}').padRight(16)} '
      '${('Lv${itm.level} ${itm.attackBonus}/${itm.ac}/${itm.maxHP}').padRight(16)} '
      '$boss',
    );
  }

  print('\n\nWIN RATES (old boss 3x HP / 1.5x ATK  vs  new boss 2x HP / 1.25x ATK)');
  print('${"St".padRight(3)} ${"Enemy".padRight(12)} ${"Nat-Old".padRight(9)} ${"Nat-New".padRight(9)} ${"Inv-Old".padRight(9)} ${"Inv-New".padRight(9)} ${"Itm-Old".padRight(9)} ${"Itm-New".padRight(9)} B?');
  print('-' * 80);

  final issuesOld = <String>[];
  final issuesNew = <String>[];

  for (final e in campaign) {
    final isBoss = e.stage % 5 == 4;

    final natOld = winRate(naturalHero, e.stage, kBossHpMult_old, kBossAtkMult_old, Random(rng.nextInt(1<<32)));
    final natNew = winRate(naturalHero, e.stage, kBossHpMult_new, kBossAtkMult_new, Random(rng.nextInt(1<<32)));
    final invOld = winRate(investedHero, e.stage, kBossHpMult_old, kBossAtkMult_old, Random(rng.nextInt(1<<32)));
    final invNew = winRate(investedHero, e.stage, kBossHpMult_new, kBossAtkMult_new, Random(rng.nextInt(1<<32)));
    final itmOld = winRate(itemHero, e.stage, kBossHpMult_old, kBossAtkMult_old, Random(rng.nextInt(1<<32)));
    final itmNew = winRate(itemHero, e.stage, kBossHpMult_new, kBossAtkMult_new, Random(rng.nextInt(1<<32)));

    final boss = isBoss ? '★' : ' ';
    print(
      '${e.stage.toString().padRight(3)} '
      '${e.name.padRight(12)} '
      '${natOld.toStringAsFixed(1).padLeft(5)}%   '
      '${natNew.toStringAsFixed(1).padLeft(5)}%   '
      '${invOld.toStringAsFixed(1).padLeft(5)}%   '
      '${invNew.toStringAsFixed(1).padLeft(5)}%   '
      '${itmOld.toStringAsFixed(1).padLeft(5)}%   '
      '${itmNew.toStringAsFixed(1).padLeft(5)}%   $boss',
    );

    // Flag issues
    if (itmOld < 30) issuesOld.add('  Stage ${e.stage} ${isBoss?"(BOSS)":""} ${e.name}: item-hero win ${itmOld.toStringAsFixed(0)}%');
    if (itmNew < 30) issuesNew.add('  Stage ${e.stage} ${isBoss?"(BOSS)":""} ${e.name}: item-hero win ${itmNew.toStringAsFixed(0)}%');
  }

  print('\n--- REMAINING ISSUES (item-equipped hero <30% win rate) ---');
  print('OLD boss multipliers (3x HP / 1.5x ATK):');
  if (issuesOld.isEmpty) print('  None.'); else for (final i in issuesOld) print(i);
  print('NEW boss multipliers (2x HP / 1.25x ATK):');
  if (issuesNew.isEmpty) print('  None.'); else for (final i in issuesNew) print(i);
}
