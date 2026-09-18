// Standalone campaign difficulty simulation (no Flutter deps) using the NEW
// model (build 166+): no auto stat growth on level-up, HP/damage from the level
// formula + starting stats only, no gear/upgrades. Enemy stats use the real
// tier-0 campaign curve. Approximates hero DPS as basic attack + ability-1
// (cooldown 1 → every round). Higher abilities (L5/10/15/20/25), gear, Paragon
// and passives are NOT modelled, so this is a LOWER bound on hero power: if a
// class clears here, it's comfortably easy; a wall here is a hard floor.
//
// Run: dart run tool/class_sim.dart
import 'dart:math';

// ── Enemy curve (tier 0), mirrors EnemyData.enemyForStage ────────────────────
const _unlock = [2, 5, 8, 10, 12, 15, 18, 20, 22, 25, 28, 30, 35, 40, 45, 50, 55];
int _systems(int stage) => _unlock.where((s) => stage >= s).length;
double _steep(int stage) => 1 + 0.10 * _systems(stage);
bool _boss(int stage) => stage % 5 == 4;
double _intra(int stage) {
  if (_boss(stage)) return 1.0;
  final rampStep = (stage / 20).clamp(0.0, 1.0) * 0.15;
  return 1 + (stage % 5) * rampStep;
}
double _bossPhase(int stage) => _boss(stage) ? ((stage - 4) / 21.0).clamp(0.0, 1.0) : 0.0;
double _bossHp(int stage) => _boss(stage) ? 1.4 + 1.1 * _bossPhase(stage) : 1.0;
double _bossAtk(int stage) => _boss(stage) ? 1.6 + 1.9 * _bossPhase(stage) : 1.0;
double enemyHp(int stage) =>
    160 * pow(3.4, stage / 100) * _intra(stage) * _bossHp(stage);
double enemyAtk(int stage) =>
    7 * pow(6.0, stage / 100) * _intra(stage) * _bossAtk(stage) * _steep(stage);
int enemyLevel(int stage) => (1 + 42 * stage / 99).round();

// ── Hero (new model) ─────────────────────────────────────────────────────────
class Hero {
  final String name;
  final int str, dex, con, elemStat;
  int level = 1;
  int xp = 0;
  Hero(this.name, this.str, this.dex, this.con, this.elemStat);

  int get maxHp => ((100 + (level - 1) * 20) * (100 + con) / 100).round();
  int get baseDmg => (2 + (level - 1) ~/ 4) + (level ~/ 2); // proficiency + level/2
  double get dmgPct => (level >= 5 ? elemStat : str) * 25 / 100; // element at L5+, else physical
  double get dodgePct {
    final r = max(0.0, (dex - 10) * 0.5).clamp(0.0, 30.0);
    return 37.5 * r / (r + 50);
  }
  int expToNext() => 50 + 45 * level;
  void gainXp(int amount) {
    xp += amount;
    while (xp >= expToNext()) { xp -= expToNext(); level++; }
  }

  // Per-round hero damage: basic (die 4.5 unarmed) + ability-1 (d10 avg 5.5, cd 1).
  double dmgPerRound() {
    final mult = 1 + dmgPct / 100;
    final basic = (4.5 + baseDmg) * mult;
    final ability1 = (5.5 + baseDmg) * mult;
    return basic + ability1;
  }
}

// Fight hero vs stage; returns true if the hero wins. Armor DR ~0.7% (rating 2).
bool fight(Hero h, int stage) {
  var ehp = enemyHp(stage);
  final eatk = enemyAtk(stage);
  var hp = h.maxHp.toDouble();
  final rng = Random(stage * 7 + 1);
  final armorMul = 1 - (37.5 * 2 / (2 + 100)) / 100;
  for (var round = 0; round < 800; round++) {
    ehp -= h.dmgPerRound();
    if (ehp <= 0) return true;
    if (rng.nextDouble() * 100 >= h.dodgePct) {
      hp -= eatk * (0.7 + rng.nextDouble() * 0.3) * armorMul;
      if (hp <= 0) return false;
    }
  }
  return false;
}

void main() {
  // [name, STR, DEX, CON, element-stat]
  final classes = <List<dynamic>>[
    ['Barbarian', 15, 13, 14, 14], // poison→CON
    ['Bard',       8, 14, 13, 10], // void→INT
    ['Cleric',    13,  8, 14, 12], // fire→CHA
    ['Druid',      8, 12, 14, 14], // poison→CON
    ['Fighter',   15, 13, 14, 13], // lightning→DEX
    ['Monk',      12, 15, 13, 15], // lightning→DEX
    ['Paladin',   15, 10, 13, 14], // fire→CHA
    ['Ranger',    12, 15, 13, 13], // poison→CON
    ['Rogue',      8, 15, 13, 13], // poison→CON
    ['Sorcerer',   8, 13, 14, 15], // fire→CHA
    ['Warlock',    8, 13, 14, 12], // void→INT
    ['Wizard',     8, 12, 13, 14], // cold→WIS
  ];

  print('Class       Result');
  print('─────────────────────────────────────────────────────────────');
  for (final c in classes) {
    final h = Hero(c[0], c[1], c[2], c[3], c[4]);
    var wall = -1;
    for (var stage = 0; stage < 100; stage++) {
      if (!fight(h, stage)) { wall = stage; break; }
      h.gainXp(enemyLevel(stage) * 20 + 40);
    }
    if (wall < 0) {
      print('${(c[0] as String).padRight(11)} cleared ALL 100  (ended L${h.level})  → likely TOO EASY');
    } else {
      // How many levels of grinding on earlier stages to beat this wall?
      final g = Hero(c[0], c[1], c[2], c[3], c[4]);
      var need = -1;
      for (var lvl = h.level; lvl <= 120; lvl++) {
        g.level = lvl;
        if (fight(g, wall)) { need = lvl; break; }
      }
      final b = _boss(wall);
      print('${(c[0] as String).padRight(11)} WALL @ stage $wall${b ? " (BOSS)" : ""}  '
          'arrive L${h.level} (hp:${h.maxHp} dps:${h.dmgPerRound().toStringAsFixed(1)})  '
          'vs eHP:${enemyHp(wall).round()} eATK:${enemyAtk(wall).round()}  '
          '→ need L$need to clear');
    }
  }
}
