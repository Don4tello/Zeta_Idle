import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeta_idle/data/enemy_data.dart';

// Boss-rush difficulty sim. Uses the REAL EnemyData.enemyForStage + the exact
// boss-rush scaling and combat loops copied from boss_rush_screen.dart, with a
// modelled hero, to eyeball the difficulty curve across all 10 tiers.
//
// Run: flutter test test/boss_rush_sim_test.dart

List<int> bossStagesForTier(int tier) {
  final base = 4 + (tier - 1) * 5;
  return [base, base + 2, base + 5, base + 7, base + 10]
      .map((s) => s.clamp(0, 99))
      .toList();
}

class Boss {
  Boss(this.name, this.hp, this.attack, this.res);
  final String name;
  final int hp;
  final int attack;
  final Map<dynamic, int> res;
}

Boss spawnBoss(int stage, int tier, int prestige) {
  final base = EnemyData.enemyForStage(stage, prestigeLevel: prestige);
  final t = tier - 1;
  final tierHpMult = 1.0 + t * 0.85;
  final tierAtkMult = 1.0 + t * 0.35;
  final hp = (base.maxHealth * tierHpMult).round();
  final atk = (base.attack * tierAtkMult).round();
  return Boss(base.name, hp, atk, base.resistances);
}

class Hero {
  Hero({required this.maxHp, required this.dmgMod, required this.dmgAllPct,
    required this.prestigeMult, required this.critPct, required this.critMult,
    required this.ac, required this.healPctPerTurn});
  final int maxHp, dmgMod, critPct, critMult, ac;
  final double dmgAllPct, prestigeMult, healPctPerTurn;
}

// A rough progression model: what a player attempting tier T plausibly has.
Hero heroForLevel(int level, int prestige) {
  final baseHp = 100 + (level - 1) * 20;
  final maxHp = (baseHp * 1.8).round(); // HP% upgrades / vitality
  return Hero(
    maxHp: maxHp,
    dmgMod: (6 + level * 1.6).round(),          // baseDmg + gear/passives
    dmgAllPct: level * 4.0,                       // stat/passive/mastery %
    prestigeMult: 1.0 + prestige * 0.05,
    critPct: 15,
    critMult: 2,
    ac: (4 + level * 0.45).round(),
    healPctPerTurn: 0.0,                          // abilities/auras NOT modelled (upside)
  );
}

/// One fight; returns true if the hero wins. Mirrors boss_rush _doRound basics
/// (no abilities → conservative). rng seeded per call.
bool simFight(Hero h, Boss b, Random rng) {
  var heroHp = h.maxHp;
  var enemyHp = b.hp;
  final resPhys = b.res.values.isEmpty ? 0 : 0; // physical hero assumed; ignore res
  for (var round = 0; round < 2000; round++) {
    // Hero attack
    final die = rng.nextInt(8) + 1;
    final crit = rng.nextInt(100) < h.critPct;
    var dmg = (crit ? die * h.critMult : die) + h.dmgMod;
    dmg = (dmg * (1 + h.dmgAllPct / 100.0)).round();
    if (resPhys != 0) dmg = (dmg * (1 - resPhys / 100.0)).round();
    dmg = (dmg * h.prestigeMult).round();
    dmg = dmg.clamp(1, 9999);
    enemyHp -= dmg;
    if (enemyHp <= 0) return true;
    // Enemy attack: rng(1..attack) - AC, min 1
    final raw = b.attack > 0 ? rng.nextInt(b.attack) + 1 : 1;
    final taken = (raw - h.ac).clamp(1, 9999);
    heroHp -= taken;
    // Optional heal
    if (h.healPctPerTurn > 0 && heroHp > 0) {
      heroHp = min(h.maxHp, heroHp + (h.maxHp * h.healPctPerTurn).round());
    }
    if (heroHp <= 0) return false;
  }
  return enemyHp <= 0;
}

/// Win rate over the full 5-boss gauntlet (must beat all 5 consecutively,
/// HP does NOT reset between bosses — matches Boss Rush).
double clearRate(Hero h, List<Boss> bosses, {int trials = 400}) {
  final rng = Random(42);
  var wins = 0;
  for (var t = 0; t < trials; t++) {
    var heroHp = h.maxHp;
    var ok = true;
    for (final b in bosses) {
      var enemyHp = b.hp;
      var alive = false;
      for (var round = 0; round < 3000; round++) {
        final die = rng.nextInt(8) + 1;
        final crit = rng.nextInt(100) < h.critPct;
        var dmg = (crit ? die * h.critMult : die) + h.dmgMod;
        dmg = (dmg * (1 + h.dmgAllPct / 100.0)).round();
        dmg = (dmg * h.prestigeMult).round();
        dmg = dmg.clamp(1, 9999);
        enemyHp -= dmg;
        if (enemyHp <= 0) { alive = true; break; }
        final raw = b.attack > 0 ? rng.nextInt(b.attack) + 1 : 1;
        heroHp -= (raw - h.ac).clamp(1, 9999);
        if (heroHp <= 0) { alive = false; break; }
      }
      if (!alive) { ok = false; break; }
    }
    if (ok) wins++;
  }
  return wins / trials;
}

void main() {
  test('boss rush difficulty across all 10 tiers (prestige 1)', () {
    const prestige = 1;
    // ignore: avoid_print
    print('\n=== BOSS RUSH SIM — prestige $prestige, hero abilities/heals NOT modelled (real runs are easier) ===');
    for (var tier = 1; tier <= 10; tier++) {
      final stages = bossStagesForTier(tier);
      final bosses = stages.map((s) => spawnBoss(s, tier, prestige)).toList()
        ..sort((a, b) => a.hp.compareTo(b.hp)); // match game's monotonic ordering
      final hpList = bosses.map((b) => b.hp).toList();
      final atkList = bosses.map((b) => b.attack).toList();
      // Model the hero you'd plausibly have at this tier: ~level 20 for T1, +12/level per tier.
      final level = 20 + (tier - 1) * 12;
      final hero = heroForLevel(level, prestige);
      final rate = clearRate(hero, bosses);
      final dph = ((4.5 + hero.dmgMod) * (1 + hero.dmgAllPct / 100) * hero.prestigeMult).round();
      // ignore: avoid_print
      print('T$tier  stages=$stages  bossHP=$hpList  bossATK=$atkList\n'
          '     hero L$level: HP=${hero.maxHp} DPH~$dph AC=${hero.ac}  →  clear rate ${(rate * 100).toStringAsFixed(0)}%');
    }
    expect(true, isTrue);
  });

  test('gauntlet difficulty across all 10 tiers (prestige 1)', () {
    const prestige = 1;
    const gauntletStages = [2, 4, 6, 8, 10, 12, 14, 16, 18, 20];
    // ignore: avoid_print
    print('\n=== GAUNTLET SIM — 10 waves, no heal between waves, prestige $prestige ===');
    for (var tier = 1; tier <= 10; tier++) {
      final tierHp = pow(1.5, tier - 1).toDouble();
      final tierAtk = pow(1.3, tier - 1).toDouble();
      final waves = gauntletStages.map((s) {
        final e = EnemyData.enemyForStage(s, prestigeLevel: prestige);
        return [(e.maxHealth * tierHp).round(), (e.attack * tierAtk).round()];
      }).toList()
        ..sort((a, b) => a[0].compareTo(b[0]));
      final hp = waves.map((w) => w[0]).toList();
      final atk = waves.map((w) => w[1]).toList();
      // ignore: avoid_print
      print('T$tier  waveHP=$hp\n     finalWave: ${hp.last} HP / ${atk.last} ATK');
    }
    expect(true, isTrue);
  });

  test('dungeon difficulty across all 10 tiers (prestige 1)', () {
    const prestige = 1;
    // ignore: avoid_print
    print('\n=== DUNGEON SIM — 20 floors, HP carries w/ rest heals, prestige $prestige ===');
    double floorMult(int floor) => (1.0 + (floor - 1) * 0.05) * pow(1.25, (floor - 1) ~/ 5);
    for (var tier = 1; tier <= 10; tier++) {
      final tierMult = 1.0 + (tier - 1) * 0.30;
      // Floor-20 final boss (the clear encounter).
      final bossBase = EnemyData.enemyForStage((20 - 1) * 2, prestigeLevel: prestige);
      final bossHp = (bossBase.maxHealth * 1.9 * 1.5 * floorMult(20) * tierMult).round();
      final bossAtk = (bossBase.attack * 1.4 * 1.2 * floorMult(20) * tierMult).round();
      // Floor-1 first fight (the entry difficulty).
      final f1 = EnemyData.enemyForStage(0, prestigeLevel: prestige);
      final f1Hp = (f1.maxHealth * 1.3 * floorMult(1) * tierMult).round();
      // ignore: avoid_print
      print('T$tier  floor1≈$f1Hp HP  →  floor20 boss: $bossHp HP / $bossAtk ATK');
    }
    expect(true, isTrue);
  });
}
