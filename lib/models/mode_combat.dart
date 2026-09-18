import 'dart:convert';
import 'dart:math';
import '../services/game_state.dart';
import '../services/debug_logger.dart';
import 'hero_ability.dart';
import 'cc_tracker.dart';

/// Per-fight combat status shared by every alternate mode (Boss Rush, Gauntlet,
/// Guild, Dungeon). Holds the enemy debuffs, hero buffs and hero barrier so all
/// modes resolve abilities through one code path ([ModeCombat]) instead of each
/// screen hand-writing the effect switch — that hand-copying is what let the
/// modes drift apart from the campaign. Mirrors the campaign's `_fireAbility`.
class ModeStatus {
  final CcTracker cc = CcTracker();

  // Enemy debuffs (remaining rounds; the screens' attack maths read these).
  bool enemyStunnedThisRound = false;
  int enemyVulnPct    = 0;
  int enemyVulnRounds = 0;
  int enemyWeakenRounds = 0; // screens apply a fixed −30% ATK while > 0

  // Hero buffs.
  int tempAtkPct   = 0;
  int tempAtkRounds = 0;
  int tempAcPct    = 0;
  int tempAcRounds = 0;
  bool dodgeNext   = false;

  // Hero barrier — absorbs incoming damage before HP (matches the campaign's
  // absorbShield, which is a barrier, NOT a flat heal).
  int heroShield = 0;

  // Damage-over-time on the enemy (Fire/Poison/generic DoT). Ticks each round
  // for its duration — matches the campaign, instead of a single instant hit.
  int dotPerRound = 0;
  int dotRounds   = 0;

  /// Absorb [incoming] with the barrier; returns the damage that gets through.
  int absorb(int incoming) {
    if (heroShield <= 0) return incoming;
    final soaked = incoming < heroShield ? incoming : heroShield;
    heroShield -= soaked;
    return incoming - soaked;
  }

  /// Tick the enemy DoT one round; returns the damage to deal (0 if none).
  int tickDot() {
    if (dotRounds <= 0) return 0;
    dotRounds--;
    final d = dotPerRound;
    if (dotRounds == 0) dotPerRound = 0;
    return d;
  }

  /// Schedule/refresh a DoT. [stack] adds to the running tick (poison), else it
  /// takes the stronger of the two (fire/generic).
  void addDot(int perRound, int rounds, {bool stack = false, int stackCap = 0}) {
    if (stack) {
      dotPerRound = stackCap > 0
          ? (dotPerRound + perRound).clamp(1, stackCap)
          : dotPerRound + perRound;
    } else {
      dotPerRound = perRound > dotPerRound ? perRound : dotPerRound;
    }
    if (rounds > dotRounds) dotRounds = rounds;
  }

  /// Advance one round: decrement buff/debuff timers and the CC DR window.
  /// [enemyStunnedThisRound] is cleared by the caller after the enemy's turn.
  void tickRound() {
    cc.tickRound();
    if (tempAtkRounds  > 0 && --tempAtkRounds  == 0) tempAtkPct = 0;
    if (tempAcRounds   > 0 && --tempAcRounds   == 0) tempAcPct  = 0;
    if (enemyVulnRounds   > 0) enemyVulnRounds--;
    if (enemyWeakenRounds > 0) enemyWeakenRounds--;
    if (enemyVulnRounds == 0) enemyVulnPct = 0;
  }

  void reset() {
    cc.reset();
    enemyStunnedThisRound = false;
    enemyVulnPct = enemyVulnRounds = enemyWeakenRounds = 0;
    tempAtkPct = tempAtkRounds = tempAcPct = tempAcRounds = 0;
    dodgeNext = false;
    heroShield = 0;
    dotPerRound = dotRounds = 0;
  }
}

/// Single shared resolver for ability effects across every alternate mode.
/// The screen supplies its own HP-application callbacks (so it keeps its floats,
/// stat tracking and setState); the EFFECT LOGIC — damage scaling, Heal-Rating
/// healing, barrier, all elemental ailments and the shared CC diminishing
/// returns — lives here and only here.
class ModeCombat {
  // Damage the ability output contributes, as a fraction of its scaled value —
  // kept identical to the long-standing per-screen constants so behaviour is
  // unchanged, just centralised.
  static const double _directFactor = 0.5; // bonusDamage
  static const double _dotFactor    = 0.6; // dot / burning / envenomed

  /// Resolve [ability]'s PRIMARY effect (scaled value [sv]) against [st].
  /// - [dealDamage]: apply N damage to the enemy (screen tracks totals/floats).
  /// - [healHero]:   restore N HP to the hero (screen clamps/floats).
  /// - [log]:        append a battle-log line.
  /// - [enemyResistPct]: enemy resistance to the hero's damage type (−200..90),
  ///   applied to ability damage so it matches the auto-attack / campaign.
  static void applyAbility(
    GameState game,
    HeroAbility ability,
    int sv,
    ModeStatus st, {
    required void Function(int dmg) dealDamage,
    required void Function(int hp) healHero,
    required void Function(String msg) log,
    int enemyResistPct = 0,
  }) {
    final name = ability.name;
    switch (ability.effect) {
      case AbilityEffect.bonusDamage:
        dealDamage(_scaledDirect(sv, st, enemyResistPct));
        log('✦ $name: ability damage!');
      case AbilityEffect.dot:
        st.addDot(_scaledDot(sv, st, enemyResistPct), _dotDuration(ability));
        log('✸ $name: ${st.dotPerRound} dmg/round for ${st.dotRounds} rounds.');
      case AbilityEffect.heal:
        final h = game.healFor(sv).clamp(1, 1000000000000000);
        healHero(h);
        log('⊕ $name: healed $h HP.');
      case AbilityEffect.aura:
        final h = game.healFor(sv, factor: 0.5).clamp(1, 1000000000000000);
        healHero(h);
        log('⊕ $name: aura healed $h HP.');
      case AbilityEffect.attackBonus:
        st.tempAtkPct   = sv;
        st.tempAtkRounds = ability.duration > 0 ? ability.duration : 3;
        log('⚡ $name: +$sv% DMG for ${st.tempAtkRounds} rounds.');
      case AbilityEffect.acBonus:
        st.tempAcPct   = sv;
        st.tempAcRounds = ability.duration > 0 ? ability.duration : 3;
        log('◆ $name: +$sv% AC for ${st.tempAcRounds} rounds.');
      case AbilityEffect.dodge:
        st.tempAcPct = st.tempAcPct < 6 ? 6 : st.tempAcPct;
        st.tempAcRounds = st.tempAcRounds < 1 ? 1 : st.tempAcRounds;
        log('◆ $name: dodge — +6% AC this round.');
      case AbilityEffect.absorbShield:
        st.heroShield = sv;
        log('+ $name: $sv HP barrier!');
      case AbilityEffect.debuffVulnerable:
        st.enemyVulnPct    = sv;
        st.enemyVulnRounds = 3;
        log('⚡ $name: enemy takes more damage for 3 rounds!');
      case AbilityEffect.debuffWeaken:
        st.enemyWeakenRounds = 3;
        log('✸ $name: enemy weakened for 3 rounds!');
      case AbilityEffect.missChance:
        st.enemyWeakenRounds = ability.duration > 0 ? ability.duration : 2;
        log('✸ $name: enemy miss chance applied!');
      // ── Hard crowd control (shared DR pool via st.cc) ──────────────────────
      case AbilityEffect.stun:
        st.enemyStunnedThisRound = st.cc.applyBool();
        log(st.enemyStunnedThisRound
            ? '◉ $name: enemy stunned!'
            : '$name: enemy resists the stun! (DR)');
      case AbilityEffect.silence:
        st.enemyStunnedThisRound = st.cc.applyBool();
        log(st.enemyStunnedThisRound
            ? '◉ $name: enemy silenced!'
            : '$name: enemy resists the silence! (DR)');
      case AbilityEffect.frozen:
        st.enemyStunnedThisRound = st.cc.applyBool();
        log(st.enemyStunnedThisRound
            ? '❄ $name: enemy frozen!'
            : '$name: enemy resists the freeze! (DR)');
      case AbilityEffect.shocked:
        st.enemyStunnedThisRound = st.cc.applyBool();
        if (st.enemyStunnedThisRound) {
          st.enemyVulnPct = st.enemyVulnPct < 25 ? 25 : st.enemyVulnPct;
          st.enemyVulnRounds = st.enemyVulnRounds < 3 ? 3 : st.enemyVulnRounds;
        }
        log(st.enemyStunnedThisRound
            ? '⚡ $name: enemy shocked (+25% dmg taken)!'
            : '$name: enemy resists the shock! (DR)');
      // ── Elemental damage-over-time / debuff ailments ──────────────────────
      case AbilityEffect.burning:
        st.addDot(_scaledDot(sv, st, enemyResistPct), _dotDuration(ability));
        log('🔥 $name: burning — ${st.dotPerRound} dmg/round for ${st.dotRounds} rounds.');
      case AbilityEffect.envenomed:
        final tick = _scaledDot(sv, st, enemyResistPct);
        st.addDot(tick, _dotDuration(ability), stack: true, stackCap: tick * 5);
        log('☠ $name: envenomed — ${st.dotPerRound} dmg/round (stacks) for ${st.dotRounds} rounds.');
      case AbilityEffect.withered:
        st.enemyWeakenRounds = 3;
        log('🟣 $name: enemy withered (ATK down) for 3 rounds!');
    }

    // ── Active milestone rider (the +stun / +DoT / +vuln etc. the player chose
    //    at a rank-5/10/15 milestone). Ignored in the alt-modes before — now it
    //    fires here just like the campaign's _fireAbility. ──────────────────────
    final rider = game.activeMilestoneRider(ability);
    if (rider.effect != null) {
      _applyRider(game, rider.effect!, rider.value, rider.duration, sv, st,
          dealDamage: dealDamage, healHero: healHero, log: log);
    }
  }

  /// Resolve an ability's chosen milestone rider ([eff]/[value]/[dur]).
  static void _applyRider(
    GameState game,
    AbilityEffect eff,
    int value,
    int dur,
    int sv,
    ModeStatus st, {
    required void Function(int dmg) dealDamage,
    required void Function(int hp) healHero,
    required void Function(String msg) log,
  }) {
    switch (eff) {
      case AbilityEffect.dot:
      case AbilityEffect.burning:
      case AbilityEffect.envenomed:
        // Rider value is a % of the ability's output per the campaign; schedule
        // it as a damage-over-time (poison stacks) matching the primary DoTs.
        var tick = (sv * value / 100).round();
        if (st.enemyVulnRounds > 0) tick = (tick * (1 + st.enemyVulnPct / 100.0)).round();
        tick = tick.clamp(1, 1000000000000000);
        st.addDot(tick, dur > 0 ? dur : 2,
            stack: eff == AbilityEffect.envenomed, stackCap: tick * 5);
        log('  ↳ rider: ${st.dotPerRound} dmg/round for ${st.dotRounds} rounds.');
      case AbilityEffect.bonusDamage:
        dealDamage((sv * value / 100).round().clamp(1, 1000000000000000));
        log('  ↳ rider: bonus damage!');
      case AbilityEffect.stun:
      case AbilityEffect.frozen:
      case AbilityEffect.silence:
        final landed = st.cc.applyBool();
        if (landed) st.enemyStunnedThisRound = true;
        log(landed ? '  ↳ rider: enemy controlled!' : '  ↳ rider: resisted (DR)');
      case AbilityEffect.shocked:
        final landed = st.cc.applyBool();
        if (landed) {
          st.enemyStunnedThisRound = true;
          st.enemyVulnPct = max(st.enemyVulnPct, 25);
          st.enemyVulnRounds = max(st.enemyVulnRounds, 3);
        }
        log(landed ? '  ↳ rider: shocked!' : '  ↳ rider: resisted (DR)');
      case AbilityEffect.debuffVulnerable:
        st.enemyVulnPct    = value;
        st.enemyVulnRounds = dur > 0 ? dur : 3;
        log('  ↳ rider: +$value% damage taken.');
      case AbilityEffect.debuffWeaken:
      case AbilityEffect.withered:
        st.enemyWeakenRounds = dur > 0 ? dur : 3;
        log('  ↳ rider: enemy ATK down.');
      case AbilityEffect.attackBonus:
        st.tempAtkPct   = max(st.tempAtkPct, value);
        st.tempAtkRounds = max(st.tempAtkRounds, dur > 0 ? dur : 3);
        log('  ↳ rider: +$value% DMG.');
      case AbilityEffect.acBonus:
        st.tempAcPct   = max(st.tempAcPct, value);
        st.tempAcRounds = max(st.tempAcRounds, dur > 0 ? dur : 3);
        log('  ↳ rider: +$value% AC.');
      case AbilityEffect.heal:
        final h = game.healFor(value).clamp(1, 1000000000000000);
        healHero(h);
        log('  ↳ rider: +$h HP.');
      case AbilityEffect.aura:
        final h = game.healFor(value, factor: 0.5).clamp(1, 1000000000000000);
        healHero(h);
        log('  ↳ rider: +$h HP.');
      case AbilityEffect.absorbShield:
        st.heroShield = value;
        log('  ↳ rider: $value HP barrier.');
      case AbilityEffect.missChance:
        st.enemyWeakenRounds = dur > 0 ? dur : 2;
        log('  ↳ rider: enemy miss chance.');
      case AbilityEffect.dodge:
        st.dodgeNext = true;
        log('  ↳ rider: dodge next hit.');
    }
  }

  /// Emit one compact ZBAL telemetry line for an alternate-mode run, matching
  /// the campaign's format (adb logcat -d | grep ZBAL). [rec] should include at
  /// least: mode, tier, win, rounds, h_hp, h_hp_end, h_hp_min_pct, h_dmg_taken,
  /// dmg, maxhit, hits — plus any mode-specific extras. Never throws.
  static void logBalance(Map<String, dynamic> rec) {
    try {
      DebugLogger.balance(jsonEncode(rec));
    } catch (_) {/* telemetry must never break a run */}
  }

  /// Lifesteal to restore after a hero hit — shared by every mode.
  static int lifestealAfterHit(GameState game) => game.lifestealHealPerHit();

  /// Thorns reflect for an incoming enemy hit of [incoming]; 0 if none.
  static int thornsReflect(GameState game, int incoming) {
    final pct = game.heroThornsPct;
    if (pct <= 0 || incoming <= 0) return 0;
    return (incoming * pct / 100).round();
  }

  static int _dotDuration(HeroAbility ability) =>
      ability.duration > 0 ? ability.duration : 2;

  static int _scaledDirect(int sv, ModeStatus st, int resistPct) {
    var d = (sv * _directFactor).round();
    if (resistPct != 0) d = (d * (1 - resistPct / 100.0)).round();
    if (st.enemyVulnRounds > 0) d = (d * (1 + st.enemyVulnPct / 100.0)).round();
    return d.clamp(1, 1000000000000000);
  }

  static int _scaledDot(int sv, ModeStatus st, int resistPct) {
    var d = (sv * _dotFactor).round();
    if (resistPct != 0) d = (d * (1 - resistPct / 100.0)).round();
    if (st.enemyVulnRounds > 0) d = (d * (1 + st.enemyVulnPct / 100.0)).round();
    return d.clamp(1, 1000000000000000);
  }
}
