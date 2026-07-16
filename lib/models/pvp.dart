import 'dart:math';
import 'dnd_class.dart';
import 'hero_ability.dart';
import 'hero_trait.dart';

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

const _botFirst = [
  'Shadow', 'Iron', 'Frost', 'Storm', 'Ember', 'Ash',
  'Dusk', 'Tide', 'Gale', 'Cinder', 'Vale', 'Thorn',
  'Blaze', 'Stone', 'Void', 'Dark', 'Grim', 'Rune',
  'Silver', 'Wild',
];
const _botLast = [
  'hunter', 'ward', 'blade', 'born', 'seeker', 'lord',
  'walker', 'rider', 'fist', 'mage', 'guard', 'caller',
  'fury', 'strike', 'warden', 'claw', 'eye', 'reaver',
  'bane', 'forge',
];

String _randomBotPlayerName(Random rng) =>
    '${_botFirst[rng.nextInt(_botFirst.length)]}'
    '${_botLast[rng.nextInt(_botLast.length)]}';

PvpSnapshot generateBotOpponent(int myRating) {
  final rng    = Random();
  final level  = max(1, myRating ~/ 80);
  final rating = (myRating + rng.nextInt(201) - 100).clamp(100, 9999);

  // Flat variance on each stat: 0–4 for ATK/AC, 0–3 for DMG, proportional for HP.
  // Creates a spread where ~20% of bots match or exceed the player's item advantage,
  // keeping PvP win rates in the target 60–75% range instead of 91–99%.
  final atkVar = rng.nextInt(5);
  final acVar  = rng.nextInt(5);
  final dmgVar = rng.nextInt(4);
  final hpVar  = rng.nextInt(max(1, level * 2 + 5));

  return PvpSnapshot(
    userId:      'bot_${rng.nextInt(99999)}',
    displayName: 'Wanderer',
    heroName:    kBotNames[rng.nextInt(kBotNames.length)],
    heroClass:   'fighter',
    level:       level,
    maxHp:       (10 + level * 5 + hpVar).clamp(10, 999),
    attackBonus: (2 + level ~/ 3 + atkVar).clamp(1, 22),
    damageMod:   (level ~/ 4 + dmgVar).clamp(0, 12),
    armorClass:  (10 + level ~/ 4 + acVar).clamp(10, 23),
    rating:      rating,
    wins:        rng.nextInt(25),
    losses:      rng.nextInt(20),
  );
}

// ── Dev opponents ─────────────────────────────────────────────────────────────

// One snapshot per DndClass with a random trait, stats scaled to playerLevel.
List<PvpSnapshot> generateDevOpponents(int playerLevel, int playerRating) {
  final rng    = Random();
  final traits = HeroTrait.all;
  return DndClass.values.map((cls) {
    final trait = traits[rng.nextInt(traits.length)];
    return _classSnapshot(cls, trait, playerLevel, playerRating, rng);
  }).toList();
}

PvpSnapshot _classSnapshot(
    DndClass cls, HeroTrait trait, int level, int rating, Random rng) {
  final info = cls.info;
  int mod(int s) => (s - 10) ~/ 2;

  final strMod  = mod(info.str);
  final dexMod  = mod(info.dex);
  final conMod  = mod(info.con);
  final prof    = 2 + (level - 1) ~/ 4;

  // DEX-primary classes use DEX for attack & damage, others use STR.
  const dexPrimary = {DndClass.monk, DndClass.ranger, DndClass.rogue};
  final atkMod  = dexPrimary.contains(cls) ? dexMod : strMod;

  final baseHp  = 30 + info.con * 8 + (level - 1) * (5 + conMod);
  final scaledHp  = (baseHp  * (1.0 + trait.hpPct  / 100.0)).round();
  final scaledDmg = (atkMod  + (trait.dmgPct / 5.0)).round();

  return PvpSnapshot(
    userId:      'bot_${cls.name}',
    displayName: _randomBotPlayerName(rng),
    heroName:    '${cls.displayName} · ${trait.icon} ${trait.name}',
    heroClass:   cls.name,
    level:       level,
    maxHp:       scaledHp.clamp(10, 9999),
    attackBonus: (atkMod + prof).clamp(0, 20),
    damageMod:   scaledDmg.clamp(0, 20),
    armorClass:  (10 + dexMod + (dexPrimary.contains(cls) ? 1 : 0)).clamp(10, 25),
    rating:      rating,
    wins:        0,
    losses:      0,
  );
}

// Returns (heroWon, condensed battle log).
(bool, List<String>) simulatePvpBattle(
    PvpSnapshot hero, PvpSnapshot foe, Random rng) {
  int heroHp = hero.maxHp * 5;
  int foeHp  = foe.maxHp * 5;
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

// ─────────────────────────────────────────────────────────────────────────────
// Ability-aware PvP tournament simulation
// ─────────────────────────────────────────────────────────────────────────────

class PvpSimAbility {
  const PvpSimAbility({
    required this.cd,
    required this.primary,
    this.pValue = 0,
    this.pDur   = 0,
    this.bonus,
    this.bValue = 0,
    this.bDur   = 0,
  });

  final int            cd;       // cooldown in rounds
  final AbilityEffect  primary;
  final int            pValue;   // primary value
  final int            pDur;     // primary duration (rounds)
  final AbilityEffect? bonus;
  final int            bValue;
  final int            bDur;
}

// Meta-build loadouts at level 20 using the most aggressive M15 milestone paths.
// aura pValue = flat HP healed per round; heal pValue = % of maxHp.
const kClassMetaAbilities = <DndClass, List<PvpSimAbility>>{
  DndClass.barbarian: [
    // Reckless Strike CD3: 10+2+4+6=22 dmg + stun1
    PvpSimAbility(cd: 3, primary: AbilityEffect.bonusDamage, pValue: 22,
        bonus: AbilityEffect.stun, bDur: 1),
    // Battle Cry CD5: ATK+10 for 5r + heal 10%
    PvpSimAbility(cd: 5, primary: AbilityEffect.attackBonus, pValue: 10, pDur: 5,
        bonus: AbilityEffect.heal, bValue: 10),
    // Thunderclap CD5: 12+2+5+6=25 dmg + ATK+5 for 2r
    PvpSimAbility(cd: 5, primary: AbilityEffect.bonusDamage, pValue: 25,
        bonus: AbilityEffect.attackBonus, bValue: 5, bDur: 2),
    // Bloodlust CD7: aura 14 HP/r for 6r
    PvpSimAbility(cd: 7, primary: AbilityEffect.aura, pValue: 14, pDur: 6),
    // Sundering Roar CD6: weaken 45% for 3r + vuln 20% for 3r
    PvpSimAbility(cd: 6, primary: AbilityEffect.debuffWeaken, pValue: 45, pDur: 3,
        bonus: AbilityEffect.debuffVulnerable, bValue: 20, bDur: 3),
  ],
  DndClass.bard: [
    // Vexing Verse CD3: 10+2+4+6=22 dmg
    PvpSimAbility(cd: 3, primary: AbilityEffect.bonusDamage, pValue: 22),
    // Inspiring Speech CD6: heal 34% + aura 5 HP/r for 2r
    PvpSimAbility(cd: 6, primary: AbilityEffect.heal, pValue: 34,
        bonus: AbilityEffect.aura, bValue: 5, bDur: 2),
    // Discordant Blast CD5: 12+2+5+8=27 dmg + stun1
    PvpSimAbility(cd: 5, primary: AbilityEffect.bonusDamage, pValue: 27,
        bonus: AbilityEffect.stun, bDur: 1),
    // Bardic Aura CD7: aura 14 HP/r for 6r
    PvpSimAbility(cd: 7, primary: AbilityEffect.aura, pValue: 14, pDur: 6),
    // Taunt CD6: weaken 45% for 3r + vuln 20% for 3r
    PvpSimAbility(cd: 6, primary: AbilityEffect.debuffWeaken, pValue: 45, pDur: 3,
        bonus: AbilityEffect.debuffVulnerable, bValue: 20, bDur: 3),
  ],
  DndClass.cleric: [
    // Sacred Flame CD3: 22 dmg + DoT 25 for 2r
    PvpSimAbility(cd: 3, primary: AbilityEffect.bonusDamage, pValue: 22,
        bonus: AbilityEffect.dot, bValue: 25, bDur: 2),
    // Cure Wounds CD6: heal 42% + aura 6 HP/r for 3r
    PvpSimAbility(cd: 6, primary: AbilityEffect.heal, pValue: 42,
        bonus: AbilityEffect.aura, bValue: 6, bDur: 3),
    // Void Judgment CD5: 27 dmg + vuln 20% for 3r
    PvpSimAbility(cd: 5, primary: AbilityEffect.bonusDamage, pValue: 27,
        bonus: AbilityEffect.debuffVulnerable, bValue: 20, bDur: 3),
    // Healing Aura CD7: aura 16 HP/r for 6r
    PvpSimAbility(cd: 7, primary: AbilityEffect.aura, pValue: 16, pDur: 6),
    // Condemn CD6: weaken 45% for 3r + vuln 20% for 3r
    PvpSimAbility(cd: 6, primary: AbilityEffect.debuffWeaken, pValue: 45, pDur: 3,
        bonus: AbilityEffect.debuffVulnerable, bValue: 20, bDur: 3),
  ],
  DndClass.druid: [
    // Thorn Lash CD3: DoT 18 HP/r for 4r + stun1
    PvpSimAbility(cd: 3, primary: AbilityEffect.dot, pValue: 18, pDur: 4,
        bonus: AbilityEffect.stun, bDur: 1),
    // Healing Word CD6: heal 34% + aura 5 HP/r for 3r
    PvpSimAbility(cd: 6, primary: AbilityEffect.heal, pValue: 34,
        bonus: AbilityEffect.aura, bValue: 5, bDur: 3),
    // Glacier Slam CD5: 27 dmg + stun2 [will be patched to stun1]
    PvpSimAbility(cd: 5, primary: AbilityEffect.bonusDamage, pValue: 27,
        bonus: AbilityEffect.stun, bDur: 2),
    // Regrowth Aura CD7: aura 15 HP/r for 7r
    PvpSimAbility(cd: 7, primary: AbilityEffect.aura, pValue: 15, pDur: 7),
    // Entangle CD6: weaken 45% for 3r + vuln 20% for 3r
    PvpSimAbility(cd: 6, primary: AbilityEffect.debuffWeaken, pValue: 45, pDur: 3,
        bonus: AbilityEffect.debuffVulnerable, bValue: 20, bDur: 3),
  ],
  DndClass.fighter: [
    // Shield Bash CD3: 22 dmg + stun2 [will be patched to stun1]
    PvpSimAbility(cd: 3, primary: AbilityEffect.bonusDamage, pValue: 22,
        bonus: AbilityEffect.stun, bDur: 2),
    // Combat Stance CD5: ATK+10 for 4r
    PvpSimAbility(cd: 5, primary: AbilityEffect.attackBonus, pValue: 10, pDur: 4),
    // Thunder Strike CD5: 25 dmg
    PvpSimAbility(cd: 5, primary: AbilityEffect.bonusDamage, pValue: 25),
    // Battle Shout CD7: aura 14 HP/r for 6r
    PvpSimAbility(cd: 7, primary: AbilityEffect.aura, pValue: 14, pDur: 6),
    // Armor Break CD6: vuln 35% for 4r
    PvpSimAbility(cd: 6, primary: AbilityEffect.debuffVulnerable, pValue: 35, pDur: 4),
  ],
  DndClass.monk: [
    // Deflect CD3: dodge + stun1
    PvpSimAbility(cd: 3, primary: AbilityEffect.dodge, pDur: 1,
        bonus: AbilityEffect.stun, bDur: 1),
    // Iron Shell CD5: AC+8 for 6r
    PvpSimAbility(cd: 5, primary: AbilityEffect.acBonus, pValue: 8, pDur: 6),
    // Void Strike CD4: 25 dmg + stun2 [will be patched to stun1]
    PvpSimAbility(cd: 4, primary: AbilityEffect.bonusDamage, pValue: 25,
        bonus: AbilityEffect.stun, bDur: 2),
    // Aura of Vitality CD7: aura 14 HP/r for 7r
    PvpSimAbility(cd: 7, primary: AbilityEffect.aura, pValue: 14, pDur: 7),
    // Shadow Assault CD6: vuln 35% for 4r
    PvpSimAbility(cd: 6, primary: AbilityEffect.debuffVulnerable, pValue: 35, pDur: 4),
  ],
  DndClass.paladin: [
    // Divine Smite CD3: 22 dmg
    PvpSimAbility(cd: 3, primary: AbilityEffect.bonusDamage, pValue: 22),
    // Lay on Hands CD6: heal 44% + AC+5 for 4r
    PvpSimAbility(cd: 6, primary: AbilityEffect.heal, pValue: 44,
        bonus: AbilityEffect.acBonus, bValue: 5, bDur: 4),
    // Holy Bolt CD5: 25 dmg + stun2 [will be patched to stun1]
    PvpSimAbility(cd: 5, primary: AbilityEffect.bonusDamage, pValue: 25,
        bonus: AbilityEffect.stun, bDur: 2),
    // Sacred Aura CD7: aura 16 HP/r for 7r
    PvpSimAbility(cd: 7, primary: AbilityEffect.aura, pValue: 16, pDur: 7),
    // Divine Judgment CD6: weaken 45% for 4r + vuln 20% for 3r
    PvpSimAbility(cd: 6, primary: AbilityEffect.debuffWeaken, pValue: 45, pDur: 4,
        bonus: AbilityEffect.debuffVulnerable, bValue: 20, bDur: 3),
  ],
  DndClass.ranger: [
    // Poison Arrow CD3: DoT 18 HP/r for 4r + stun1
    PvpSimAbility(cd: 3, primary: AbilityEffect.dot, pValue: 18, pDur: 4,
        bonus: AbilityEffect.stun, bDur: 1),
    // Hunter's Mark CD4: ATK+13 for 5r + heal 8%
    PvpSimAbility(cd: 4, primary: AbilityEffect.attackBonus, pValue: 13, pDur: 5,
        bonus: AbilityEffect.heal, bValue: 8),
    // Blizzard Arrow CD5: 25 dmg + stun2 [will be patched to stun1]
    PvpSimAbility(cd: 5, primary: AbilityEffect.bonusDamage, pValue: 25,
        bonus: AbilityEffect.stun, bDur: 2),
    // Camouflage CD6: AC+8 for 6r + heal 8%
    PvpSimAbility(cd: 6, primary: AbilityEffect.acBonus, pValue: 8, pDur: 6,
        bonus: AbilityEffect.heal, bValue: 8),
    // Crippling Shot CD6: weaken 45% for 4r + vuln 20% for 4r
    PvpSimAbility(cd: 6, primary: AbilityEffect.debuffWeaken, pValue: 45, pDur: 4,
        bonus: AbilityEffect.debuffVulnerable, bValue: 20, bDur: 4),
  ],
  DndClass.rogue: [
    // Sneak Attack CD3: 23 dmg + stun1
    PvpSimAbility(cd: 3, primary: AbilityEffect.bonusDamage, pValue: 23,
        bonus: AbilityEffect.stun, bDur: 1),
    // Evasion CD5: dodge + stun1
    PvpSimAbility(cd: 5, primary: AbilityEffect.dodge, pDur: 1,
        bonus: AbilityEffect.stun, bDur: 1),
    // Shadow Blade CD4: 27 dmg + stun1
    PvpSimAbility(cd: 4, primary: AbilityEffect.bonusDamage, pValue: 27,
        bonus: AbilityEffect.stun, bDur: 1),
    // Smoke Bomb CD6: AC+9 for 5r + heal 8%
    PvpSimAbility(cd: 6, primary: AbilityEffect.acBonus, pValue: 9, pDur: 5,
        bonus: AbilityEffect.heal, bValue: 8),
    // Kidney Shot CD5: weaken 50% for 3r + vuln 20% for 3r
    PvpSimAbility(cd: 5, primary: AbilityEffect.debuffWeaken, pValue: 50, pDur: 3,
        bonus: AbilityEffect.debuffVulnerable, bValue: 20, bDur: 3),
  ],
  DndClass.sorcerer: [
    // Chaos Bolt CD3: 25 dmg + DoT 30 for 3r
    PvpSimAbility(cd: 3, primary: AbilityEffect.bonusDamage, pValue: 25,
        bonus: AbilityEffect.dot, bValue: 30, bDur: 3),
    // Draconic Vigor CD5: aura 26 HP/r for 2r + dodge
    PvpSimAbility(cd: 5, primary: AbilityEffect.aura, pValue: 26, pDur: 2,
        bonus: AbilityEffect.dodge, bDur: 1),
    // Glacial Spike CD4: 27 dmg + stun1
    PvpSimAbility(cd: 4, primary: AbilityEffect.bonusDamage, pValue: 27,
        bonus: AbilityEffect.stun, bDur: 1),
    // Arcane Shield CD6: AC+10 for 5r + heal 10%
    PvpSimAbility(cd: 6, primary: AbilityEffect.acBonus, pValue: 10, pDur: 5,
        bonus: AbilityEffect.heal, bValue: 10),
    // Enervating Ray CD5: weaken 50% for 4r + vuln 20% for 4r
    PvpSimAbility(cd: 5, primary: AbilityEffect.debuffWeaken, pValue: 50, pDur: 4,
        bonus: AbilityEffect.debuffVulnerable, bValue: 20, bDur: 4),
  ],
  DndClass.warlock: [
    // Eldritch Blast CD3: 25 dmg + DoT 30 for 3r
    PvpSimAbility(cd: 3, primary: AbilityEffect.bonusDamage, pValue: 25,
        bonus: AbilityEffect.dot, bValue: 30, bDur: 3),
    // Dark One's Blessing CD5: aura 23 HP/r for 2r + dodge
    PvpSimAbility(cd: 5, primary: AbilityEffect.aura, pValue: 23, pDur: 2,
        bonus: AbilityEffect.dodge, bDur: 1),
    // Hunger of Hadar CD4: 27 dmg + stun1
    PvpSimAbility(cd: 4, primary: AbilityEffect.bonusDamage, pValue: 27,
        bonus: AbilityEffect.stun, bDur: 1),
    // Armor of Agathys CD6: AC+10 for 5r + heal 10%
    PvpSimAbility(cd: 6, primary: AbilityEffect.acBonus, pValue: 10, pDur: 5,
        bonus: AbilityEffect.heal, bValue: 10),
    // Hex CD5: weaken 50% for 4r + vuln 20% for 4r
    PvpSimAbility(cd: 5, primary: AbilityEffect.debuffWeaken, pValue: 50, pDur: 4,
        bonus: AbilityEffect.debuffVulnerable, bValue: 20, bDur: 4),
  ],
  DndClass.wizard: [
    // Magic Missile CD3: 25 dmg + DoT 30 for 3r
    PvpSimAbility(cd: 3, primary: AbilityEffect.bonusDamage, pValue: 25,
        bonus: AbilityEffect.dot, bValue: 30, bDur: 3),
    // Mage Armor CD6: AC+10 for 5r + heal 10%
    PvpSimAbility(cd: 6, primary: AbilityEffect.acBonus, pValue: 10, pDur: 5,
        bonus: AbilityEffect.heal, bValue: 10),
    // Cone of Cold CD4: 27 dmg + stun1
    PvpSimAbility(cd: 4, primary: AbilityEffect.bonusDamage, pValue: 27,
        bonus: AbilityEffect.stun, bDur: 1),
    // Arcane Recovery CD5: aura 23 HP/r for 2r + dodge
    PvpSimAbility(cd: 5, primary: AbilityEffect.aura, pValue: 23, pDur: 2,
        bonus: AbilityEffect.dodge, bDur: 1),
    // Slow CD5: weaken 50% for 4r + vuln 20% for 4r
    PvpSimAbility(cd: 5, primary: AbilityEffect.debuffWeaken, pValue: 50, pDur: 4,
        bonus: AbilityEffect.debuffVulnerable, bValue: 20, bDur: 4),
  ],
};

// ── Simulation internals ──────────────────────────────────────────────────────

class _SimState {
  _SimState(PvpSnapshot s, List<PvpSimAbility> abs)
      : maxHp    = s.maxHp,
        baseAtk  = s.attackBonus,
        baseDmg  = s.damageMod,
        baseAc   = s.armorClass,
        abilities = abs,
        cds       = List.filled(abs.length, 0) {
    hp = s.maxHp;
  }

  final int maxHp, baseAtk, baseDmg, baseAc;
  final List<PvpSimAbility> abilities;
  final List<int> cds; // round each ability is next available

  int hp = 0;

  // Self buffs
  int atkBonus = 0, atkBonusRem = 0;
  int acBonus  = 0, acBonusRem  = 0;
  int auraHp   = 0, auraRem     = 0;
  bool dodgeNext = false;

  // Debuffs stored on self (applied by opponent)
  int weakenPct = 0, weakenRem = 0;
  int vulnPct   = 0, vulnRem   = 0;
  int dotDmg    = 0, dotRem    = 0;
  int stunRem   = 0;
}

void _simTakeTurn(_SimState self, _SimState foe, int round, Random rng) {
  // DoT tick
  if (self.dotRem > 0) {
    self.hp -= self.dotDmg;
    if (--self.dotRem == 0) self.dotDmg = 0;
    if (self.hp <= 0) return;
  }
  // Aura heal
  if (self.auraRem > 0) {
    self.hp = min(self.maxHp, self.hp + self.auraHp);
    if (--self.auraRem == 0) self.auraHp = 0;
  }
  // Decay buffs/debuffs
  if (self.atkBonusRem > 0 && --self.atkBonusRem == 0) self.atkBonus  = 0;
  if (self.acBonusRem  > 0 && --self.acBonusRem  == 0) self.acBonus   = 0;
  if (self.weakenRem   > 0 && --self.weakenRem   == 0) self.weakenPct = 0;
  if (self.vulnRem     > 0 && --self.vulnRem     == 0) self.vulnPct   = 0;

  // Stunned?
  if (self.stunRem > 0) { self.stunRem--; return; }

  // Ability
  _simUseAbility(self, foe, round, rng);

  // Regular attack: d20 + effective ATK vs foe AC
  final roll   = rng.nextInt(20) + 1;
  final effAtk = self.baseAtk + self.atkBonus;
  final isCrit = roll == 20;
  if (isCrit || roll + effAtk >= foe.baseAc + foe.acBonus) {
    if (foe.dodgeNext) { foe.dodgeNext = false; return; }
    final die    = rng.nextInt(8) + 1;
    final raw    = max(1, (isCrit ? die * 2 : die) + self.baseDmg);
    final wkn    = (raw * (1.0 - self.weakenPct / 100.0)).round();
    final vuln   = (max(1, wkn) * (1.0 + foe.vulnPct / 100.0)).round();
    foe.hp -= max(1, vuln);
  }
}

void _simUseAbility(_SimState self, _SimState foe, int round, Random rng) {
  int bestScore = -1, bestIdx = -1;
  for (int i = 0; i < self.abilities.length; i++) {
    if (self.cds[i] > round) continue;
    final s = _simScoreAbility(self.abilities[i], self, foe);
    if (s > bestScore) { bestScore = s; bestIdx = i; }
  }
  if (bestIdx < 0) return;

  final ab = self.abilities[bestIdx];
  self.cds[bestIdx] = round + ab.cd;
  _simApply(ab.primary, ab.pValue, ab.pDur, self, foe, rng);
  if (ab.bonus != null) _simApply(ab.bonus!, ab.bValue, ab.bDur, self, foe, rng);
}

int _simScoreAbility(PvpSimAbility ab, _SimState self, _SimState foe) {
  final critHp = self.hp < self.maxHp * 0.15;
  final lowHp  = self.hp < self.maxHp * 0.40;
  if (critHp && (ab.primary == AbilityEffect.heal || ab.primary == AbilityEffect.aura)) {
    return 99;
  }
  if (ab.bonus == AbilityEffect.stun || ab.primary == AbilityEffect.stun) return 95;
  return switch (ab.primary) {
    AbilityEffect.bonusDamage      => ab.pValue >= 25 ? 80 : 65,
    AbilityEffect.heal             => lowHp ? 85 : 30,
    AbilityEffect.aura             =>
        (lowHp && self.auraRem == 0) ? 78 : (self.auraRem == 0 ? 40 : 5),
    AbilityEffect.debuffWeaken     => foe.weakenPct == 0 ? 60 : 15,
    AbilityEffect.debuffVulnerable => foe.vulnPct   == 0 ? 55 : 10,
    AbilityEffect.attackBonus      => self.atkBonus  == 0 ? 50 : 10,
    AbilityEffect.dot              => foe.dotRem     == 0 ? 45 : 5,
    AbilityEffect.acBonus          => self.acBonus   == 0 ? 35 : 5,
    AbilityEffect.dodge            => 42,
    _                              => 0,
  };
}

void _simApply(
    AbilityEffect eff, int val, int dur, _SimState self, _SimState foe, Random rng) {
  switch (eff) {
    case AbilityEffect.bonusDamage:
      if (val <= 0) break;
      final raw  = rng.nextInt(val) + 1;
      final wkn  = (raw * (1.0 - self.weakenPct / 100.0)).round();
      final vuln = (max(1, wkn) * (1.0 + foe.vulnPct / 100.0)).round();
      foe.hp -= max(1, vuln);
    case AbilityEffect.heal:
      self.hp = min(self.maxHp, self.hp + self.maxHp * val ~/ 100);
    case AbilityEffect.attackBonus:
      self.atkBonus    = max(self.atkBonus, val);
      self.atkBonusRem = max(self.atkBonusRem, dur);
    case AbilityEffect.acBonus:
      self.acBonus   += val;
      self.acBonusRem = max(self.acBonusRem, dur);
    case AbilityEffect.stun:
      foe.stunRem += dur;
    case AbilityEffect.dot:
      if (val > foe.dotDmg) { foe.dotDmg = val; foe.dotRem = dur; }
    case AbilityEffect.aura:
      self.auraHp  = val;
      self.auraRem = dur;
    case AbilityEffect.debuffWeaken:
      if (val > foe.weakenPct) { foe.weakenPct = val; foe.weakenRem = dur; }
    case AbilityEffect.debuffVulnerable:
      if (val > foe.vulnPct) { foe.vulnPct = val; foe.vulnRem = dur; }
    case AbilityEffect.dodge:
      self.dodgeNext = true;
    case AbilityEffect.silence:
      foe.stunRem = max(foe.stunRem, 1);
    case AbilityEffect.absorbShield:
      self.hp = min(self.maxHp, self.hp + val);
    case AbilityEffect.missChance:
      if (val > foe.weakenPct) { foe.weakenPct = val ~/ 2; foe.weakenRem = dur; }
  }
}

bool _simBattleWithAbilities(
    PvpSnapshot aSn, List<PvpSimAbility> aAbs,
    PvpSnapshot bSn, List<PvpSimAbility> bAbs,
    Random rng) {
  final a = _SimState(aSn, aAbs);
  final b = _SimState(bSn, bAbs);
  for (int r = 1; r <= 200; r++) {
    _simTakeTurn(a, b, r, rng);
    if (b.hp <= 0) return true;
    _simTakeTurn(b, a, r, rng);
    if (a.hp <= 0) return false;
  }
  return a.hp >= b.hp;
}

// ── Tournament ────────────────────────────────────────────────────────────────

class PvpTournamentResult {
  PvpTournamentResult(this.classes, this.matrix);
  final List<DndClass> classes;
  final List<List<double>> matrix; // [i][j] = win rate of classes[i] vs classes[j]

  double avgWinRate(int i) {
    double sum = 0; int cnt = 0;
    for (int j = 0; j < classes.length; j++) {
      if (i != j) { sum += matrix[i][j]; cnt++; }
    }
    return cnt > 0 ? sum / cnt : 0.5;
  }
}

Future<PvpTournamentResult> runPvpTournament({int battles = 80}) async {
  return Future(() {
    final classes = DndClass.values;
    final n       = classes.length;
    final rng     = Random();
    final matrix  = List.generate(n, (_) => List<double>.filled(n, 0.5));

    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        if (i == j) continue;
        final aAbs = kClassMetaAbilities[classes[i]] ?? const [];
        final bAbs = kClassMetaAbilities[classes[j]] ?? const [];
        int wins = 0;
        for (int b = 0; b < battles; b++) {
          // Use same random trait for both fighters so trait effects cancel
          final trait = HeroTrait.all[rng.nextInt(HeroTrait.all.length)];
          final aSn   = _classSnapshot(classes[i], trait, 20, 1000, rng);
          final bSn   = _classSnapshot(classes[j], trait, 20, 1000, rng);
          if (_simBattleWithAbilities(aSn, aAbs, bSn, bAbs, rng)) wins++;
        }
        matrix[i][j] = wins / battles;
      }
    }
    return PvpTournamentResult(classes, matrix);
  });
}
