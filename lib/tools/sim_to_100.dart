// Standalone simulation: how long does each class take to reach level 100?
// Run: dart run lib/tools/sim_to_100.dart
//
// Assumptions:
//   - Player fights campaign battles actively ~60 per hour (1 per min)
//   - Idle gold ticks once per 60s
//   - XP per kill = enemy level * 3 + 10
//   - Gold per kill = enemy level * 8 + 30
//   - Enemy HP scales via campaign data curve
//   - Hero damage = weaponBaseDmg + damageMod + bonuses
//   - weaponBaseDmg scales: 5 + level * 1.5 (common weapon, auto-equip)
//   - Hero HP = 50 + constitution * 10 + level * 5
//   - XP curve: starts 100, ×1.08 per level

import 'dart:math';

void main() {
  final classes = [
    'Barbarian', 'Fighter', 'Paladin', 'Rogue', 'Ranger', 'Monk',
    'Cleric', 'Druid', 'Wizard', 'Sorcerer', 'Warlock', 'Bard',
  ];

  // Primary stat growth rates (affects damage/HP)
  final isMelee = {'Barbarian', 'Fighter', 'Paladin', 'Monk', 'Rogue', 'Ranger'};

  print('╔══════════════════════════════════════════════════════════════════╗');
  print('║  CLASS SIMULATION: Level 1 → 100 (active play estimate)       ║');
  print('╠══════════════╦══════════╦═══════════╦══════════╦═══════════════╣');
  print('║ Class        ║ Hours    ║ Days(4h)  ║ XP Total ║ Gold Total    ║');
  print('╠══════════════╬══════════╬═══════════╬══════════╬═══════════════╣');

  for (final cls in classes) {
    final result = _simulate(cls, isMelee.contains(cls));
    final hours = result.totalMinutes / 60;
    final days = hours / 4; // assuming 4h play/day
    print('║ ${cls.padRight(12)} ║ ${hours.toStringAsFixed(1).padLeft(8)} ║ ${days.toStringAsFixed(1).padLeft(9)} ║ ${_fmt(result.totalXp).padLeft(8)} ║ ${_fmt(result.totalGold).padLeft(13)} ║');
  }

  print('╚══════════════╩══════════╩═══════════╩══════════╩═══════════════╝');
  print('');

  // Detailed level breakdown for one class
  print('── BARBARIAN LEVEL BREAKDOWN ──');
  print('Level │ XP Needed │ XP/Kill │ Kills │ Minutes │ Cumulative Hours');
  final detail = _simulateDetailed('Barbarian', true);
  for (final row in detail) {
    if (row.level % 10 == 0 || row.level <= 5 || row.level == 25 || row.level == 50 || row.level == 75) {
      print('${row.level.toString().padLeft(5)} │ ${_fmt(row.xpNeeded).padLeft(9)} │ ${row.xpPerKill.toString().padLeft(7)} │ ${row.killsNeeded.toString().padLeft(5)} │ ${row.minutesAtLevel.toStringAsFixed(1).padLeft(7)} │ ${(row.cumulativeMinutes / 60).toStringAsFixed(1).padLeft(16)}');
    }
  }

  // Campaign stage difficulty curve
  print('');
  print('── CAMPAIGN ENEMY SCALING ──');
  print('Stage │ Enemy HP │ Enemy ATK │ Enemy AC │ Hero DMG (est) │ Turns to Kill');
  for (int stage = 0; stage < 100; stage += 5) {
    final eHp = _enemyHp(stage);
    final eAtk = _enemyAtk(stage);
    final eAc = _enemyAc(stage);
    final heroLevel = (stage / 2 + 5).round().clamp(1, 100);
    final heroDmg = _heroDamage(heroLevel);
    final turnsToKill = (eHp / heroDmg.clamp(1, 99999)).ceil();
    print('${stage.toString().padLeft(5)} │ ${eHp.toString().padLeft(8)} │ ${eAtk.toString().padLeft(9)} │ ${eAc.toString().padLeft(8)} │ ${heroDmg.toString().padLeft(14)} │ ${turnsToKill.toString().padLeft(13)}');
  }
}

class _SimResult {
  final int totalMinutes;
  final int totalXp;
  final int totalGold;
  _SimResult(this.totalMinutes, this.totalXp, this.totalGold);
}

class _LevelRow {
  final int level, xpNeeded, xpPerKill, killsNeeded;
  final double minutesAtLevel, cumulativeMinutes;
  _LevelRow(this.level, this.xpNeeded, this.xpPerKill, this.killsNeeded, this.minutesAtLevel, this.cumulativeMinutes);
}

_SimResult _simulate(String cls, bool melee) {
  int xpToNext = 100;
  int totalXp = 0;
  int totalGold = 0;
  double totalMinutes = 0;

  for (int level = 1; level < 100; level++) {
    final stage = (level * 1.5).round().clamp(0, 199);
    final xpPerKill = _xpForStage(stage);
    final goldPerKill = _goldForStage(stage);
    final killsNeeded = (xpToNext / xpPerKill).ceil();

    // Time per kill: based on turns needed
    final heroDmg = _heroDamage(level);
    final eHp = _enemyHp(stage);
    final turnsToKill = (eHp / heroDmg.clamp(1, 99999)).ceil().clamp(1, 50);
    final secondsPerKill = turnsToKill * 0.6 + 2; // 0.6s per turn + 2s overhead

    final minutesAtLevel = (killsNeeded * secondsPerKill) / 60;
    totalMinutes += minutesAtLevel;
    totalXp += xpToNext;
    totalGold += killsNeeded * goldPerKill;

    xpToNext = (xpToNext * 1.08).round();
  }

  return _SimResult(totalMinutes.round(), totalXp, totalGold);
}

List<_LevelRow> _simulateDetailed(String cls, bool melee) {
  final rows = <_LevelRow>[];
  int xpToNext = 100;
  double cumMinutes = 0;

  for (int level = 1; level <= 100; level++) {
    final stage = (level * 1.5).round().clamp(0, 199);
    final xpPerKill = _xpForStage(stage);
    final killsNeeded = (xpToNext / xpPerKill).ceil();

    final heroDmg = _heroDamage(level);
    final eHp = _enemyHp(stage);
    final turnsToKill = (eHp / heroDmg.clamp(1, 99999)).ceil().clamp(1, 50);
    final secondsPerKill = turnsToKill * 0.6 + 2;

    final minutesAtLevel = (killsNeeded * secondsPerKill) / 60;
    cumMinutes += minutesAtLevel;

    rows.add(_LevelRow(level, xpToNext, xpPerKill, killsNeeded, minutesAtLevel, cumMinutes));
    xpToNext = (xpToNext * 1.08).round();
  }

  return rows;
}

// Enemy scaling (mirrors EnemyData)
int _enemyHp(int stage) {
  if (stage < 100) {
    // Campaign: roughly 30 + stage * 15
    return (30 + stage * 15 + (stage * stage * 0.1)).round();
  }
  final a = stage - 99;
  return (220 * pow(1.06, a.clamp(0, 100))).round();
}

int _enemyAtk(int stage) => (8 + stage * 2 + (stage * 0.05)).round().clamp(5, 9999);
int _enemyAc(int stage) => (10 + stage ~/ 5).clamp(10, 30);

// Hero damage estimate (weapon base + level scaling)
int _heroDamage(int level) {
  final weaponBase = (5 + level * 1.5).round(); // common weapon
  final statBonus = level ~/ 2; // damageMod from level
  final passiveBonus = level ~/ 4; // passive tree flat damage
  return weaponBase + statBonus + passiveBonus + 4; // +4 base die average
}

// XP/Gold from kills
int _xpForStage(int stage) => (10 + stage * 3).clamp(10, 9999);
int _goldForStage(int stage) => (30 + stage * 8).clamp(30, 9999);

String _fmt(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return n.toString();
}
