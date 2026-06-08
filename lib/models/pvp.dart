import 'dart:math';

// ─────────────────────────────────────────────────────────────────────────────
// PVP system — snapshot-based async matchmaking against other players.
// Combat uses the same D&D rules (d20 attack, 1d8 damage, AC) but is
// simulated locally from each player's exported stat snapshot.
// ─────────────────────────────────────────────────────────────────────────────

class PvpSnapshot {
  const PvpSnapshot({
    required this.userId,
    required this.displayName,
    required this.heroName,
    required this.heroClass,
    required this.level,
    required this.maxHp,
    required this.attackBonus,
    required this.damageMod,
    required this.armorClass,
    this.rating = 1000,
    this.wins   = 0,
    this.losses = 0,
  });

  final String userId;
  final String displayName;
  final String heroName;
  final String heroClass;
  final int level;
  final int maxHp;
  final int attackBonus;
  final int damageMod;
  final int armorClass;
  final int rating;
  final int wins;
  final int losses;

  Map<String, dynamic> toMap() => {
    'displayName': displayName,
    'heroName':    heroName,
    'heroClass':   heroClass,
    'level':       level,
    'maxHp':       maxHp,
    'attackBonus': attackBonus,
    'damageMod':   damageMod,
    'armorClass':  armorClass,
    'rating':      rating,
    'wins':        wins,
    'losses':      losses,
  };

  factory PvpSnapshot.fromMap(String userId, Map<String, dynamic> d) =>
      PvpSnapshot(
        userId:      userId,
        displayName: d['displayName'] as String? ?? 'Unknown',
        heroName:    d['heroName']    as String? ?? 'Hero',
        heroClass:   d['heroClass']   as String? ?? 'fighter',
        level:       d['level']       as int?    ?? 1,
        maxHp:       d['maxHp']       as int?    ?? 10,
        attackBonus: d['attackBonus'] as int?    ?? 2,
        damageMod:   d['damageMod']   as int?    ?? 0,
        armorClass:  d['armorClass']  as int?    ?? 10,
        rating:      d['rating']      as int?    ?? 1000,
        wins:        d['wins']        as int?    ?? 0,
        losses:      d['losses']      as int?    ?? 0,
      );
}

const List<String> kBotNames = [
  'Dusk', 'Iron', 'Vale', 'Thorn', 'Ash', 'Ember',
  'Frost', 'Blaze', 'Gale', 'Stone', 'Tide', 'Cinder',
];

PvpSnapshot generateBotOpponent(int myRating) {
  final rng    = Random();
  final level  = max(1, myRating ~/ 80);
  final rating = (myRating + rng.nextInt(201) - 100).clamp(100, 9999);
  return PvpSnapshot(
    userId:      'bot_${rng.nextInt(99999)}',
    displayName: 'Wanderer',
    heroName:    kBotNames[rng.nextInt(kBotNames.length)],
    heroClass:   'fighter',
    level:       level,
    maxHp:       (10 + level * 5).clamp(10, 999),
    attackBonus: (2 + level ~/ 3).clamp(1, 20),
    damageMod:   (level ~/ 4).clamp(0, 10),
    armorClass:  (10 + level ~/ 4).clamp(10, 20),
    rating:      rating,
    wins:        rng.nextInt(25),
    losses:      rng.nextInt(20),
  );
}

// Returns (heroWon, condensed battle log).
(bool, List<String>) simulatePvpBattle(
    PvpSnapshot hero, PvpSnapshot foe, Random rng) {
  int heroHp = hero.maxHp;
  int foeHp  = foe.maxHp;
  final log  = <String>[];

  for (int r = 1; r <= 200; r++) {
    final hRoll = rng.nextInt(20) + 1;
    final hCrit = hRoll == 20;
    if (hCrit || hRoll + hero.attackBonus >= foe.armorClass) {
      final die = rng.nextInt(8) + 1;
      final dmg = max(1, (hCrit ? die * 2 : die) + hero.damageMod);
      foeHp -= dmg;
      if (log.length < 5) {
        log.add('Round $r: You deal $dmg${hCrit ? ' (CRIT!)' : ''}.'
            ' ${foe.heroName} HP: ${foeHp.clamp(0, 9999)}');
      }
    } else {
      if (log.length < 5) {
        log.add('Round $r: Miss. ($hRoll+${hero.attackBonus} vs AC ${foe.armorClass})');
      }
    }
    if (foeHp <= 0) {
      log.add('⚔ Victory in round $r!');
      return (true, log);
    }

    final fRoll = rng.nextInt(20) + 1;
    final fCrit = fRoll == 20;
    if (fCrit || fRoll + foe.attackBonus >= hero.armorClass) {
      final die = rng.nextInt(8) + 1;
      final dmg = max(1, (fCrit ? die * 2 : die) + foe.damageMod);
      heroHp -= dmg;
      if (log.length < 5) {
        log.add('Round $r: ${foe.heroName} deals $dmg${fCrit ? ' (CRIT!)' : ''}.'
            ' Your HP: ${heroHp.clamp(0, 9999)}');
      }
    }
    if (heroHp <= 0) {
      log.add('💀 Defeated in round $r.');
      return (false, log);
    }
  }

  final won = heroHp > foeHp;
  log.add(won ? '⚔ Won on remaining HP!' : '💀 Lost on remaining HP.');
  return (won, log);
}
