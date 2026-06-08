import 'dart:math';
import '../models/daily_challenge.dart';

class _Template {
  const _Template({
    required this.type,
    required this.title,
    required this.makeDesc,
    required this.target,
    required this.gold,
    required this.shards,
    required this.essence,
  });
  final DailyChallengeType type;
  final String title;
  final String Function(int) makeDesc;
  final int target;
  final int gold;
  final int shards;
  final int essence;
}

// ─────────────────────────────────────────────────────────────────────────────
// Each day 7 challenges are generated — one per challenge type (from the 8
// available, one type is rotated out each day).  Two variants exist per type
// so the chosen one alternates with the date seed.
// ─────────────────────────────────────────────────────────────────────────────

class DailyChallengeGenerator {
  static final _pool = <DailyChallengeType, List<_Template>>{
    DailyChallengeType.killEnemies: [
      _Template(
        type: DailyChallengeType.killEnemies,
        title: 'Slayer',
        makeDesc: _killDesc, target: 10,
        gold: 120, shards: 5, essence: 3,
      ),
      _Template(
        type: DailyChallengeType.killEnemies,
        title: 'Pest Control',
        makeDesc: _killDesc, target: 15,
        gold: 150, shards: 6, essence: 4,
      ),
    ],
    DailyChallengeType.winBattles: [
      _Template(
        type: DailyChallengeType.winBattles,
        title: 'Skirmisher',
        makeDesc: _winsDesc, target: 5,
        gold: 120, shards: 5, essence: 3,
      ),
      _Template(
        type: DailyChallengeType.winBattles,
        title: 'Brawler',
        makeDesc: _winsDesc, target: 8,
        gold: 150, shards: 6, essence: 4,
      ),
    ],
    DailyChallengeType.collectIdle: [
      _Template(
        type: DailyChallengeType.collectIdle,
        title: 'Patient Collector',
        makeDesc: _idleDesc, target: 3,
        gold: 80, shards: 4, essence: 3,
      ),
      _Template(
        type: DailyChallengeType.collectIdle,
        title: 'Idle Harvester',
        makeDesc: _idleDesc, target: 5,
        gold: 100, shards: 5, essence: 4,
      ),
    ],
    DailyChallengeType.useAbilities: [
      _Template(
        type: DailyChallengeType.useAbilities,
        title: 'Apprentice',
        makeDesc: _abilityDesc, target: 5,
        gold: 100, shards: 5, essence: 3,
      ),
      _Template(
        type: DailyChallengeType.useAbilities,
        title: 'Channeler',
        makeDesc: _abilityDesc, target: 8,
        gold: 120, shards: 5, essence: 4,
      ),
    ],
    DailyChallengeType.dealDamage: [
      _Template(
        type: DailyChallengeType.dealDamage,
        title: 'Striker',
        makeDesc: _dmgDesc, target: 200,
        gold: 100, shards: 5, essence: 3,
      ),
      _Template(
        type: DailyChallengeType.dealDamage,
        title: 'Bruiser',
        makeDesc: _dmgDesc, target: 350,
        gold: 130, shards: 6, essence: 4,
      ),
    ],
    DailyChallengeType.reachGold: [
      _Template(
        type: DailyChallengeType.reachGold,
        title: 'Coin Seeker',
        makeDesc: _goldDesc, target: 500,
        gold: 90, shards: 5, essence: 3,
      ),
      _Template(
        type: DailyChallengeType.reachGold,
        title: 'Treasure Hoarder',
        makeDesc: _goldDesc, target: 750,
        gold: 110, shards: 5, essence: 4,
      ),
    ],
    DailyChallengeType.equipItem: [
      _Template(
        type: DailyChallengeType.equipItem,
        title: 'Gearhead',
        makeDesc: _equipDesc, target: 1,
        gold: 100, shards: 5, essence: 3,
      ),
    ],
    DailyChallengeType.defeatBoss: [
      _Template(
        type: DailyChallengeType.defeatBoss,
        title: 'Boss Slayer',
        makeDesc: _bossDesc, target: 1,
        gold: 150, shards: 8, essence: 5,
      ),
    ],
  };

  static List<DailyChallenge> generateForDate(DateTime date) {
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final rng  = Random(seed);

    // Shuffle all 8 types and take 7 — one type is rotated out each day
    final types = DailyChallengeType.values.toList()..shuffle(rng);
    final chosen = types.take(7).toList();

    return List.generate(7, (i) {
      final type     = chosen[i];
      final variants = _pool[type]!;
      final t        = variants[rng.nextInt(variants.length)];
      return _build(t, 'daily_$i');
    });
  }

  static DailyChallenge _build(_Template t, String id) => DailyChallenge(
    id:            id,
    type:          t.type,
    title:         t.title,
    description:   t.makeDesc(t.target),
    target:        t.target,
    rewardGold:    t.gold,
    rewardShards:  t.shards,
    rewardEssence: t.essence,
  );

  static String _killDesc(int t)    => 'Kill $t enemies today.';
  static String _winsDesc(int t)    => 'Win $t battles today.';
  static String _idleDesc(int t)    => 'Collect idle rewards $t time${t == 1 ? '' : 's'}.';
  static String _abilityDesc(int t) => 'Use active abilities $t times.';
  static String _dmgDesc(int t)     => 'Deal $t total damage today.';
  static String _goldDesc(int t)    => 'Accumulate $t gold.';
  static String _bossDesc(int _)    => 'Defeat a boss stage.';
  static String _equipDesc(int _)   => 'Equip any dropped item.';
}
