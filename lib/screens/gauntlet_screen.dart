import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import '../data/bestiary_data.dart';
import '../data/enemy_data.dart';
import '../models/challenge_modifier.dart';
import '../models/damage_type.dart';
import '../models/enemy.dart';
import '../models/equipment.dart';
import '../models/gauntlet.dart';
import '../services/remote_config_service.dart';
import '../models/hero_ability.dart';
import 'main_shell.dart' show TutorialTip;
import '../models/passive_tree.dart';
import '../screens/leaderboard_screen.dart';
import '../widgets/fight_summary_sheet.dart';
import '../services/game_state.dart';
import '../services/leaderboard_service.dart';
import '../theme/app_theme.dart';
import '../widgets/arena_ability_effect.dart';
import '../widgets/battle_arena.dart';
import '../widgets/tier_selector.dart';
import '../widgets/battle_split_panel.dart';
import '../widgets/pet_battle_sprite.dart';
import '../widgets/zcoin_icon.dart';

const _kGauntletEnemies = 10;
const _kMaxModifiers = 3;

// Gauntlet uses a spread of stages: 3, 7, 10, 13, 16, 18, 20, 22, 23, 24
const _kGauntletStages = [3, 7, 10, 13, 16, 18, 20, 22, 23, 24];

enum _Phase { pick, battle, results }

class GauntletScreen extends StatefulWidget {
  const GauntletScreen({super.key});

  @override
  State<GauntletScreen> createState() => _GauntletScreenState();
}

class _GauntletScreenState extends State<GauntletScreen> {
  _Phase _phase = _Phase.pick;

  final _arenaKey  = GlobalKey<BattleArenaState>();
  final _effectKey = GlobalKey<ArenaAbilityEffectState>();

  // -- Modifier selection ---------------------------------------------------
  final Set<String> _selectedIds = {};
  int _selectedTier = 1;
  bool _autoRepeat = false;
  Timer? _autoRestartTimer;

  // -- Battle state ---------------------------------------------------------
  int _waveIndex  = 0;
  int _heroHp     = 0;
  int _heroMaxHp  = 0;
  int _enemyHp    = 0;
  int _enemyMaxHp = 0;
  int _kills      = 0;
  // Per-run fight-summary tracking (across all gauntlet waves).
  int _totalDealt = 0;
  int _maxHit = 0;
  int _hitCount = 0;
  final Map<String, int> _fightAbilities = {};

  final List<String> _log = [];
  Enemy? _currentEnemy;
  Timer? _autoTimer;
  bool _busyRound = false;

  // Cached hero stats (computed at run start)
  late int _heroDmgMod;
  late int _heroAc;
  late int _heroWeaponBase;
  late DamageType _heroDmgType;
  double _heroDmgAllPct    = 0;
  double _heroPrestigeMult = 1.0;
  int _rebirthLvl = 0;
  int _heroCritChancePct = 0;
  int _heroCritDmgMult   = 2;

  // Combined modifier values
  double _enemyHpMult   = 1.0;
  double _enemyAtkMult  = 1.0;
  double _heroHpMult    = 1.0;
  int    _essenceBonusPerKill = 0;

  // -- Local ability state ---------------------------------------------------
  final _rng = Random();
  int _gAbilityRound = 0;
  final Map<String, int> _gCooldownUntil = {};
  int _tempAtkBonus   = 0;
  int _tempAtkRounds  = 0;
  int _tempAcBonus    = 0;
  int _tempAcRounds   = 0;
  bool _enemyStunned  = false;
  int _enemyWeakenRem = 0;
  int _enemyVulnRem   = 0;

  // -- Result ---------------------------------------------------------------
  GauntletResult? _result;
  GameState? _game;

  @override
  void dispose() {
    _autoTimer?.cancel();
    _autoRestartTimer?.cancel();
    _game?.audioService.endBattleMusic();
    super.dispose();
  }

  void _startTimer() {
    _autoTimer?.cancel();
    // 1200ms base matches the Dungeon so every arena mode paces the same.
    final ms = _game?.scaledInterval(1200) ?? 1200;
    _autoTimer = Timer.periodic(Duration(milliseconds: ms), (_) {
      if (_phase != _Phase.battle || _busyRound) return;
      _busyRound = true;
      _doRound().then((_) => _busyRound = false);
    });
  }

  void _cycleSpeed() {
    final game = _game;
    if (game == null) return;
    final maxTier = kDebugMode ? 4 : ((game.hasSpeedSub || game.hasPremium) ? 4 : (game.speedBoostActive ? 3 : 2));
    game.setSpeedTier((game.speedTier % maxTier) + 1);
    _startTimer();
  }

  void _pickRandomModifiers() {
    final all = ChallengeModifier.all.map((m) => m.id).toList()..shuffle();
    _selectedIds
      ..clear()
      ..addAll(all.take(_kMaxModifiers));
  }

  // -- Modifier pick ---------------------------------------------------------

  void _toggleModifier(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else if (_selectedIds.length < _kMaxModifiers) {
        _selectedIds.add(id);
      }
    });
  }

  void _startBattle() {
    final game = GameStateProvider.of(context);
    if (!game.consumeGauntletAttempt()) return;

    // Aggregate modifier effects
    _enemyHpMult  = 1.0;
    _enemyAtkMult = 1.0;
    _heroHpMult   = 1.0;
    _essenceBonusPerKill = 0;

    for (final id in _selectedIds) {
      final mod = ChallengeModifier.all.firstWhere((m) => m.id == id);
      _enemyHpMult  *= mod.enemyHpMult;
      _enemyAtkMult *= mod.enemyAtkMult;
      _heroHpMult   *= mod.heroHpMult;
      _essenceBonusPerKill += mod.rewardShardBonus;
    }

    // Cache hero stats

    _heroDmgMod = game.hero.baseDmg
        + game.passiveTree.totalOf(PassiveEffect.damageFlat)
        + game.inventory.totalOf(ItemStat.damageBonus)
        + game.questDamageBonus
        + game.runeDmgBonus
        + game.ascDmgBonus;

    _heroAc = game.hero.armorClass
        + game.passiveTree.totalOf(PassiveEffect.armorFlat)
        + game.inventory.totalOf(ItemStat.armorClass)
        + game.petArmor
        + game.skinArmor
        + game.questACBonus
        + game.runeAcBonus;

    _heroWeaponBase   = game.inventory.equippedWeaponDamage;
    _heroDmgType      = game.hero.activeDamageType;
    _heroDmgAllPct    = game.heroAllDamagePctFor(_heroDmgType);
    _heroPrestigeMult = game.prestigeLevel > 0 ? game.prestigeDamageMult : 1.0;
    _rebirthLvl        = game.prestigeLevel;
    _heroCritChancePct = game.totalCritChancePct;
    _heroCritDmgMult   = game.totalCritDamageMult.round();

    final baseMaxHp = (game.hero.maxHealth * _heroHpMult).round().clamp(1, 999999);

    _gAbilityRound  = 0;
    _gCooldownUntil.clear();
    _tempAtkBonus   = 0;
    _tempAtkRounds  = 0;
    _tempAcBonus    = 0;
    _tempAcRounds   = 0;
    _enemyStunned   = false;
    _enemyWeakenRem = 0;
    _enemyVulnRem   = 0;

    setState(() {
      _phase      = _Phase.battle;
      _waveIndex  = 0;
      _kills      = 0;
      _totalDealt = 0;
      _maxHit     = 0;
      _hitCount   = 0;
      _fightAbilities.clear();
      _heroMaxHp  = baseMaxHp;
      _heroHp     = baseMaxHp;
      _log.clear();
    });
    _log.add('⚔ GAUNTLET STARTS — ${_kGauntletEnemies} enemies await!');
    _spawnEnemy();

    _game = game;
    game.audioService.startBattleMusic();
    _startTimer();
  }

  void _spawnEnemy() {
    final tierOffset = (_selectedTier - 1) * 10;
    final stage = _kGauntletStages[_waveIndex] + tierOffset;
    final base  = EnemyData.enemyForStage(stage, prestigeLevel: _rebirthLvl);
    final scaled = Enemy(
      id:          base.id,
      name:        '${base.name}  [${_waveIndex + 1}/$_kGauntletEnemies]',
      description: base.description,
      maxHealth:   (base.maxHealth * _enemyHpMult * RemoteConfigService.instance.gauntletHpMult).round().clamp(1, 999999),
      attack:      (base.attack * _enemyAtkMult * RemoteConfigService.instance.gauntletAtkMult).round().clamp(1, 9999),
      level:       base.level,
      armorClass:  base.armorClass,
    );
    _enemyWeakenRem = 0;
    _enemyVulnRem   = 0;
    setState(() {
      _currentEnemy = scaled;
      _enemyMaxHp   = scaled.maxHealth;
      _enemyHp      = scaled.maxHealth;
    });
    _log.add('');
    _log.add('Wave ${_waveIndex + 1}: ${base.name}  (${scaled.maxHealth} HP)');
  }

  Future<void> _doRound() async {
    final enemy = _currentEnemy;
    if (enemy == null) return;
    final game = GameStateProvider.of(context);

    // -- Tick abilities ----------------------------------------------------
    _gAbilityRound++;
    if (_gAbilityRound > 1) _log.add('— Round $_gAbilityRound —');
    // Aura HP regen — heal a % of max HP each turn (sustain).
    if (game.auraHpRegen > 0 && _heroHp > 0 && _heroHp < _heroMaxHp) {
      final r = (_heroMaxHp * game.auraHpRegen / 100).round().clamp(1, 999999);
      _heroHp = (_heroHp + r).clamp(0, _heroMaxHp);
      _log.add('✚ Aura regen: +$r HP.');
    }
    for (final ability in game.unlockedAbilities) {
      final readyAt = _gCooldownUntil[ability.id] ?? 0;
      if (_gAbilityRound >= readyAt) {
        _fightAbilities[ability.name] = (_fightAbilities[ability.name] ?? 0) + 1;
        _applyAbilityEffect(game, ability);
        _gCooldownUntil[ability.id] =
            _gAbilityRound + game.scaledAbilityCooldown(ability);
        if (_enemyHp <= 0) {
          _enemyHp = 0;
          _kills++;
          _log.add('${enemy.name.split('[').first.trim()} defeated!');
          GameStateProvider.of(context).recordExternalKill(enemyName: enemy.name);
          _arenaKey.currentState?.playEnemyDeath();
          await Future.delayed(const Duration(milliseconds: 900));
          _waveIndex++;
          if (_waveIndex >= _kGauntletEnemies) {
            _endRun(heroWon: true);
            return;
          }
          final heal = (_heroMaxHp * 0.10).round();
          _heroHp = (_heroHp + heal).clamp(0, _heroMaxHp);
          _log.add('⚕ Recovered $heal HP.');
          if (mounted) setState(() {});
          _spawnEnemy();
          return;
        }
      }
    }

    // -- Tick temp buffs ---------------------------------------------------
    if (_tempAtkRounds > 0) {
      _tempAtkRounds--;
      if (_tempAtkRounds == 0) _tempAtkBonus = 0;
    }
    if (_tempAcRounds > 0) {
      _tempAcRounds--;
      if (_tempAcRounds == 0) _tempAcBonus = 0;
    }

    // -- Hero attacks (always lands, same formula as campaign; crit is
    //    chance-based; ability ATK buff converts to crit chance) -----------
    final critPct = _heroCritChancePct + _tempAtkBonus * 2;
    final crit    = _rng.nextInt(100) < critPct;
    {
      final die = _heroWeaponBase > 0
          ? _heroWeaponBase + _rng.nextInt((_heroWeaponBase ~/ 3).clamp(1, 50))
          : _rng.nextInt(8) + 1;
      var dmg = ((crit ? die * _heroCritDmgMult : die) + _heroDmgMod).clamp(1, 9999);
      dmg = (dmg * (1 + _heroDmgAllPct / 100.0) * _heroPrestigeMult).round();
      final res = (enemy.resistances[_heroDmgType] ?? 0).clamp(-200, 75);
      if (res != 0) dmg = (dmg * (1 - res / 100.0)).round();
      if (_enemyVulnRem > 0) dmg = (dmg * 1.25).round();
      dmg = dmg.clamp(1, 9999);
      setState(() => _enemyHp -= dmg);
      _totalDealt += dmg; _hitCount++; if (dmg > _maxHit) _maxHit = dmg;
      _log.add('${crit ? 'CRIT! ' : 'Hit! '}$dmg dmg${_enemyVulnRem > 0 ? ' (vuln)' : ''}.');
      game.audioService.playHitWithType(_heroDmgType);
      _arenaKey.currentState?.playHeroAttack(dmg,
          isCrit: crit, heroClass: game.hero.heroClass,
          damageType: _heroDmgType);
    }

    if (_enemyHp <= 0) {
      _enemyHp = 0;
      _kills++;
      _log.add('${enemy.name.split('[').first.trim()} defeated!');
      GameStateProvider.of(context).recordExternalKill(enemyName: enemy.name);
      _arenaKey.currentState?.playEnemyDeath();
      await Future.delayed(const Duration(milliseconds: 900));
      _waveIndex++;
      if (_waveIndex >= _kGauntletEnemies) {
        _endRun(heroWon: true);
        return;
      }
      final heal = (_heroMaxHp * 0.10).round();
      _heroHp = (_heroHp + heal).clamp(0, _heroMaxHp);
      _log.add('⚕ Recovered $heal HP.');
      if (mounted) setState(() {});
      _spawnEnemy();
      return;
    }

    // -- Enemy attacks back ------------------------------------------------
    if (_enemyStunned) {
      _enemyStunned = false;
      _log.add('Enemy is stunned — skips attack!');
      setState(() {});
      return;
    }

    // Enemy always lands (same as campaign); armor is flat damage reduction.
    {
      final armor  = _heroAc + _tempAcBonus;
      final atkMax = _enemyWeakenRem > 0 ? max(1, (enemy.attack * 0.7).round()) : enemy.attack;
      final rawDmg = atkMax > 0 ? _rng.nextInt(atkMax) + 1 : 1;
      final dmg    = (rawDmg - armor).clamp(1, 9999);
      setState(() => _heroHp -= dmg);
      _log.add('Enemy hits! $dmg to you${_enemyWeakenRem > 0 ? ' (weakened)' : ''}.');
      game.audioService.playEnemyAttack(weaknessForEnemyId(enemy.id));
      _arenaKey.currentState?.playEnemyAttack(dmg);
      if (_heroHp <= 0) {
        _heroHp = 0;
        if (mounted) setState(() {});
        await (_arenaKey.currentState?.playHeroDeath() ?? Future.value());
        await Future.delayed(const Duration(seconds: 3));
        _endRun(heroWon: false);
        return;
      }
    }
    if (_enemyWeakenRem > 0) _enemyWeakenRem--;
    if (_enemyVulnRem   > 0) _enemyVulnRem--;
    if (mounted) setState(() {});
  }

  void _applyAbilityEffect(GameState game, HeroAbility ability) {
    _arenaKey.currentState?.playAbilityBanner(ability.name, ability.effect, id: ability.id);
    _effectKey.currentState?.playEffect(ability.id);
    game.audioService.playAbilityFull(ability.effect, _heroDmgType);
    final sv = game.scaledAbilityValue(ability);
    switch (ability.effect) {
      case AbilityEffect.bonusDamage:
        final dmg = (sv * 0.5).round().clamp(1, 9999);
        _enemyHp -= dmg;
        _totalDealt += dmg; _hitCount++; if (dmg > _maxHit) _maxHit = dmg;
        _log.add('✦ ${ability.name}: $dmg ability damage!');
        _arenaKey.currentState?.addExtraFloat(dmg);

      case AbilityEffect.heal:
        final h = sv.clamp(1, 9999);
        setState(() => _heroHp = (_heroHp + h).clamp(0, _heroMaxHp));
        _log.add('⊕ ${ability.name}: healed $h HP.');
        _arenaKey.currentState?.addExtraFloat(h, isHeal: true);

      case AbilityEffect.attackBonus:
        _tempAtkBonus  = sv;
        _tempAtkRounds = ability.duration > 0 ? ability.duration : 3;
        _log.add('⚡ ${ability.name}: +$sv DMG for $_tempAtkRounds rounds.');

      case AbilityEffect.acBonus:
        _tempAcBonus  = sv;
        _tempAcRounds = ability.duration > 0 ? ability.duration : 3;
        _log.add('◆ ${ability.name}: +$sv AC for $_tempAcRounds rounds.');

      case AbilityEffect.stun:
        _enemyStunned = true;
        _log.add('◉ ${ability.name}: enemy stunned!');

      case AbilityEffect.dot:
        final dmg = (sv * 0.6).round().clamp(1, 9999);
        _enemyHp -= dmg;
        _totalDealt += dmg; _hitCount++; if (dmg > _maxHit) _maxHit = dmg;
        _log.add('✸ ${ability.name}: $dmg DoT damage!');
        _arenaKey.currentState?.addExtraFloat(dmg);

      case AbilityEffect.dodge:
        _tempAcBonus  = 6;
        _tempAcRounds = 1;
        _log.add('◆ ${ability.name}: dodge — +6 AC this round.');

      case AbilityEffect.aura:
        final h = (sv * 0.5).round().clamp(1, 9999);
        setState(() => _heroHp = (_heroHp + h).clamp(0, _heroMaxHp));
        _log.add('⊕ ${ability.name}: aura healed $h HP.');
        _arenaKey.currentState?.addExtraFloat(h, isHeal: true);

      case AbilityEffect.debuffWeaken:
        _enemyWeakenRem = 3;
        _log.add('✸ ${ability.name}: enemy weakened for 3 rounds!');

      case AbilityEffect.debuffVulnerable:
        _enemyVulnRem = 3;
        _log.add('⚡ ${ability.name}: enemy vulnerable for 3 rounds!');

      case AbilityEffect.silence:
        _enemyStunned = true;
        _log.add('◉ ${ability.name}: enemy silenced!');

      case AbilityEffect.absorbShield:
        setState(() => _heroHp = (_heroHp + sv).clamp(0, _heroMaxHp));
        _log.add('+ ${ability.name}: +$sv HP barrier!');

      case AbilityEffect.missChance:
        _enemyWeakenRem = ability.duration > 0 ? ability.duration : 2;
        _log.add('✸ ${ability.name}: enemy miss chance applied!');
    }
  }

  void _endRun({required bool heroWon}) {
    _autoTimer?.cancel();
    final game = GameStateProvider.of(context);
    game.lastFightSummary = FightSummary(
      enemyName: 'Gauntlet · Tier $_selectedTier',
      victory: heroWon,
      totalDamage: _totalDealt,
      maxHit: _maxHit,
      hitCount: _hitCount,
      rounds: _gAbilityRound,
      abilitiesUsed: Map<String, int>.from(_fightAbilities),
      log: List<String>.from(_log),
    );
    game.audioService.endBattleMusic();

    // Score: kills × (1 + modifier count) × 100 × tier, +2000 for a clear
    final modCount = _selectedIds.length;
    final tierMult = 1.0 + (_selectedTier - 1) * 0.3;
    final baseScore = (_kills * (1 + modCount) * 100 * tierMult).round();
    final clearBonus = heroWon ? (2000 * tierMult).round() : 0;
    final score = baseScore + clearBonus;

    // Rewards: scale with tier and rebirth (essence tracks the +prestige difficulty)
    final rebirthMult = 1.0 + game.prestigeLevel * 0.15;
    final essence = (_kills * (5 + _essenceBonusPerKill) * tierMult * rebirthMult).round();
    final zcoins = heroWon ? (10 + modCount * 5) * _selectedTier : 0;
    final echoMult = (1.0 + modCount * 0.25) * tierMult;
    final echoReward = ((_kills * 8 + (heroWon ? 40 + modCount * 20 : 0)) * echoMult).round();

    final result = GauntletResult(
      kills:           _kills,
      totalEnemies:    _kGauntletEnemies,
      cleared:         heroWon,
      score:           score,
      essenceEarned:   essence,
      zcoinsEarned:  zcoins,
      echoesEarned:    echoReward,
      modifierIds:     _selectedIds.toList(),
    );

    game.recordGauntletResult(result, tier: _selectedTier);
    // Update the Gauntlet leaderboard (fire-and-forget, personal-best only).
    LeaderboardService.submitScore(
      board:     LeaderboardBoard.gauntlet,
      heroName:  game.hero.name,
      heroClass: game.hero.heroClass.displayName,
      subclass:  game.subclassName,
      spriteId:  game.heroBattleSpriteId,
      rebirths:  game.prestigeLevel,
      stage:     game.gauntletHighScore,
      title:       game.activeTitle,
      nameColorId: game.activeNameColor,
      frameId:     game.activeFrame,
      level:       game.hero.level,
      ascensionAp: game.totalAscensionAp,
    );

    setState(() {
      _result = result;
      _phase  = _Phase.results;
    });

    if (_autoRepeat) {
      _autoRestartTimer = Timer(const Duration(seconds: 2), () {
        if (!mounted || !_autoRepeat) return;
        _pickRandomModifiers();
        _startBattle();
      });
    }
  }

  // -- Build -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('CHALLENGE GAUNTLET',
            style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 2)),
        actions: [
          IconButton(
            icon: Icon(Icons.assessment_outlined, size: 20,
                color: GameStateProvider.of(context).lastFightSummary != null
                    ? AppTheme.accentGold : AppTheme.textMuted),
            tooltip: 'Last fight summary',
            onPressed: () {
              final s = GameStateProvider.of(context).lastFightSummary;
              if (s == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('No fight finished yet.'),
                    behavior: SnackBarBehavior.floating));
                return;
              }
              showFightSummary(context, s);
            },
          ),
          if (_phase != _Phase.battle)
            IconButton(
              icon: const Icon(Icons.leaderboard, color: AppTheme.accentGold, size: 20),
              tooltip: 'Gauntlet Leaderboard',
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const LeaderboardScreen(board: LeaderboardBoard.gauntlet),
              )),
            ),
          if (_phase == _Phase.battle && _game != null)
            _InlineSpeedButton(
              speedTier: _game!.speedTier,
              isDebug: kDebugMode,
              onCycle: _cycleSpeed,
            ),
        ],
      ),
      body: switch (_phase) {
        _Phase.pick    => _buildPickPhase(),
        _Phase.battle  => _buildBattlePhase(),
        _Phase.results => _buildResultsPhase(),
      },
    );
  }

  // -- Phase 1: Modifier Pick ------------------------------------------------

  Widget _buildPickPhase() {
    final game = GameStateProvider.of(context);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Hero image
        Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: 220,
              child: Image.asset('assets/images/gauntlet_bg.png',
                  fit: BoxFit.cover, alignment: Alignment.center),
            ),
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0xDD0a0a0a)],
                    stops: [0.3, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16, right: 16, bottom: 12,
              child: Text(
                'Pick modifiers to increase difficulty and earn more Echoes.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Color(0xFFccbbaa)),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
        TutorialTip(
          tutorialKey: 'gauntlet',
          game: game,
          text: 'The Gauntlet is a combat challenge — pick modifiers to increase difficulty '
              'and earn more Echoes. Echoes are used to purchase permanent Upgrades.',
        ),
        const SizedBox(height: 12),
        TierSelector(
          selectedTier: _selectedTier,
          maxUnlocked: (game.gauntletHighestTier + 1).clamp(1, 10),
          highestCleared: game.gauntletHighestTier,
          onTierChange: (t) => setState(() => _selectedTier = t),
        ),
        const SizedBox(height: 12),
        _GauntletStartSection(onStart: _startBattle),
        const SizedBox(height: 16),
        Text(
          'CHOOSE MODIFIERS  (${_selectedIds.length}/$_kMaxModifiers selected)',
          style: AppTheme.pixelHeading(
              fontSize: 11, letterSpacing: 2, color: AppTheme.accentGold),
        ),
        if (_selectedIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '?? Echo bonus: +${(_selectedIds.length * 25)}%',
              style: AppTheme.pixelHeading(
                  fontSize: 9, letterSpacing: 1, color: const Color(0xFFcc88ff)),
            ),
          ),
        const SizedBox(height: 10),
        ...ChallengeModifier.all.map((mod) {
          final selected = _selectedIds.contains(mod.id);
          final canSelect = selected || _selectedIds.length < _kMaxModifiers;
          return _ModifierPickCard(
            mod: mod,
            selected: selected,
            enabled: canSelect,
            onTap: () => _toggleModifier(mod.id),
          );
        }),
        const SizedBox(height: 24),
        _buildRewardPreview(),
      ])),
      ],
    );
  }

  Widget _buildRewardPreview() {
    final modCount   = _selectedIds.length;
    final essenceBonus = _selectedIds.isEmpty
        ? 0
        : _selectedIds
            .map((id) => ChallengeModifier.all
                .firstWhere((m) => m.id == id)
                .rewardShardBonus)
            .reduce((a, b) => a + b);
    final essence   = _kGauntletEnemies * (5 + essenceBonus);
    final zcoins = 10 + modCount * 5;
    final scoreMult = 1 + modCount;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF231F1B),
        border: Border.all(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('REWARD PREVIEW (on clear)',
              style: AppTheme.pixelHeading(
                  fontSize: 10, letterSpacing: 1, color: AppTheme.textMuted)),
          const SizedBox(height: 10),
          Row(children: [
            _RewardChip('✦ $essence essence', const Color(0xFF44dd88)),
            const SizedBox(width: 8),
            _RewardChip('$zcoins ZCoins', const Color(0xFF44ccaa), prefix: const ZCoinIcon(size: 11, animate: false)),
            const SizedBox(width: 8),
            _RewardChip('Score ×$scoreMult', AppTheme.accentGold),
          ]),
        ],
      ),
    );
  }

  // -- Phase 2: Battle -------------------------------------------------------

  Widget _buildBattlePhase() {
    final enemy = _currentEnemy;
    if (enemy == null) return const SizedBox.shrink();
    final game = GameStateProvider.of(context);
    return Column(
      children: [
        _WaveProgressHeader(
          waveIndex:   _waveIndex,
          totalWaves:  _kGauntletEnemies,
          kills:       _kills,
          selectedIds: _selectedIds,
        ),
        // Full battle arena
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              BattleArena(
                key: _arenaKey,
                stageIndex:       _waveIndex,
                heroName:         game.hero.name,
                heroLevel:        game.hero.level,
                heroCurrentHp:    _heroHp,
                heroMaxHp:        _heroMaxHp,
                heroAttack:       game.avgHeroHit,
                heroSpriteId:     game.heroBattleSpriteId,
                heroGender:       game.hero.gender,
                heroRace:         game.heroRace,
                heroAuraColor:    game.heroAuraColor,
                heroAuraIntensity: game.heroAuraIntensity,
                heroColorFilter:  game.heroSpriteFilter,
                heroPet: game.equippedPet != null
                    ? PetBattleSprite(pet: game.equippedPet!)
                    : null,
                enemyName:     enemy.name,
                enemyLevel:    enemy.level,
                enemyCurrentHp: _enemyHp,
                enemyMaxHp:    _enemyMaxHp,
                enemyAttack:   enemy.attack,
                enemyId:       enemy.id,
                headerLabel:   '⚔  GAUNTLET  ⚔',
                heroBuffGlows: [
                  if (_tempAtkBonus > 0) const Color(0xFFffcc00),
                  if (_tempAcBonus  > 0) const Color(0xFF66aaff),
                ],
                enemyDebuffGlows: [
                  if (_enemyStunned)       const Color(0xFFcc44ff),
                  if (_enemyWeakenRem > 0) const Color(0xFFff4488),
                  if (_enemyVulnRem   > 0) const Color(0xFFff8800),
                ],
                heroDamageType: game.hero.activeDamageType,
                heroCritPct:   game.totalCritChancePct,
                heroArmor:     game.heroArmorValue,
              ),
              ArenaAbilityEffect(key: _effectKey),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: BattleIconBar(
            localCooldownResolver: (id) {
              final totalCd = game.scaledAbilityCooldown(
                  game.unlockedAbilities.firstWhere((a) => a.id == id));
              final readyAt = _gCooldownUntil[id] ?? 0;
              return (readyAt - _gAbilityRound).clamp(0, totalCd);
            },
          ),
        ),
      ],
    );
  }

  // -- Phase 3: Results ------------------------------------------------------

  Widget _buildResultsPhase() {
    final r    = _result!;
    final game = GameStateProvider.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            r.cleared ? '?  GAUNTLET CLEARED  ?' : '?  RUN OVER  ?',
            style: AppTheme.pixelHeading(
              fontSize: 17,
              letterSpacing: 2,
              color: r.cleared ? AppTheme.accentGold : AppTheme.accentRed,
            ),
          ),
          const SizedBox(height: 20),
          _ResultRow('Enemies Defeated', '${r.kills} / ${r.totalEnemies}'),
          _ResultRow('Modifiers Used',   '${r.modifierIds.length} / $_kMaxModifiers'),
          _ResultRow('Score',            '${r.score}'),
          _ResultRow('High Score',       '${game.gauntletHighScore}'),
          const Divider(color: AppTheme.cardBorder, height: 24),
          if (r.essenceEarned > 0)
            _ResultRow('Shards Earned',  '◆ ${r.essenceEarned}',
                color: const Color(0xFF6699ff)),
          if (r.zcoinsEarned > 0)
            _ResultRow('ZCoins Earned', '${r.zcoinsEarned}',
                color: const Color(0xFF44ccaa),
                valuePrefix: const ZCoinIcon(size: 14, animate: false)),
          if (r.echoesEarned > 0)
            _ResultRow('Echoes Earned', '◈ ${r.echoesEarned}',
                color: const Color(0xFFcc88ff)),
          const Spacer(),
          // AUTO toggle
          if (_autoRepeat)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF44dd88).withValues(alpha: 0.10),
                border: Border.all(color: const Color(0xFF44dd88).withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text('AUTO — restarting with random modifiers—',
                    style: AppTheme.pixelHeading(
                        fontSize: 10, color: const Color(0xFF44dd88), letterSpacing: 1)),
              ),
            ),
          Row(children: [
            if (game.gauntletAttemptsRemaining > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _autoRepeat = !_autoRepeat;
                    if (_autoRepeat) {
                      _autoRestartTimer?.cancel();
                      _pickRandomModifiers();
                      _startBattle();
                    } else {
                      _autoRestartTimer?.cancel();
                    }
                  }),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _autoRepeat
                        ? const Color(0xFFff4444)
                        : const Color(0xFF44dd88),
                    side: BorderSide(
                        color: _autoRepeat
                            ? const Color(0xFFff4444)
                            : const Color(0xFF44dd88)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  child: Text(_autoRepeat ? 'STOP AUTO' : 'AUTO',
                      style: AppTheme.pixelHeading(
                          fontSize: 12,
                          color: _autoRepeat
                              ? const Color(0xFFff4444)
                              : const Color(0xFF44dd88))),
                ),
              ),
            if (game.gauntletAttemptsRemaining > 0) const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() {
                  _autoRepeat = false;
                  _autoRestartTimer?.cancel();
                  _phase = _Phase.pick;
                  _selectedIds.clear();
                  _result = null;
                }),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.accentGold,
                  side: const BorderSide(color: AppTheme.accentGold),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                child: Text('BACK TO GAUNTLET',
                    style: AppTheme.pixelHeading(
                        fontSize: 12, color: AppTheme.accentGold)),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

// -- Wave Progress Header ------------------------------------------------------

class _WaveProgressHeader extends StatefulWidget {
  const _WaveProgressHeader({
    required this.waveIndex,
    required this.totalWaves,
    required this.kills,
    required this.selectedIds,
  });
  final int waveIndex;
  final int totalWaves;
  final int kills;
  final Set<String> selectedIds;

  @override
  State<_WaveProgressHeader> createState() => _WaveProgressHeaderState();
}

class _WaveProgressHeaderState extends State<_WaveProgressHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  )..repeat(reverse: true);

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1C19),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -- Top row: label + kill count ---------------------------------
          Row(children: [
            Text('WAVE ${widget.waveIndex + 1} / ${widget.totalWaves}',
                style: AppTheme.pixelHeading(
                    fontSize: 11, color: AppTheme.accentGold, letterSpacing: 2)),
            const Spacer(),
            Text('${widget.kills} KILLS',
                style: AppTheme.pixelHeading(
                    fontSize: 11, color: AppTheme.textMuted)),
          ]),
          const SizedBox(height: 8),
          // -- Pip row -----------------------------------------------------
          Row(
            children: List.generate(widget.totalWaves, (i) {
              final defeated = i < widget.waveIndex;
              final active   = i == widget.waveIndex;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < widget.totalWaves - 1 ? 3 : 0),
                  child: AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, __) {
                      final Color bg;
                      final Color border;
                      if (defeated) {
                        bg     = const Color(0xFF44cc66).withValues(alpha: 0.25);
                        border = const Color(0xFF44cc66);
                      } else if (active) {
                        bg     = AppTheme.accentGold.withValues(alpha: 0.10 + _pulse.value * 0.12);
                        border = AppTheme.accentGold;
                      } else {
                        bg     = Colors.transparent;
                        border = AppTheme.cardBorder;
                      }
                      return Container(
                        height: 28,
                        decoration: BoxDecoration(
                          color: bg,
                          border: Border.all(color: border, width: active ? 1.5 : 1),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: active
                              ? [BoxShadow(
                                  color: AppTheme.accentGold.withValues(alpha: _pulse.value * 0.4),
                                  blurRadius: 6,
                                )]
                              : [],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          defeated ? '✓' : '${i + 1}',
                          style: TextStyle(
                            fontSize: defeated ? 13 : active ? 14 : 10,
                            color: defeated
                                ? const Color(0xFF44cc66)
                                : active
                                    ? AppTheme.accentGold
                                    : AppTheme.textMuted.withValues(alpha: 0.45),
                            fontWeight: active ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
          // -- Modifier chips -----------------------------------------------
          if (widget.selectedIds.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(children: [
              for (final id in widget.selectedIds) ...[
                Builder(builder: (_) {
                  final mod = ChallengeModifier.all.firstWhere((m) => m.id == id);
                  return Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withValues(alpha: 0.07),
                      border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.35)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('${mod.icon} ${mod.name}',
                        style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
                  );
                }),
              ],
            ]),
          ],
        ],
      ),
    );
  }
}

// -- Shared widgets ------------------------------------------------------------

class _InfoBox extends StatelessWidget {
  const _InfoBox(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.accentGold.withValues(alpha: 0.05),
        border:
            Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text,
          style: const TextStyle(
              fontSize: 11, color: Colors.white60, height: 1.5)),
    );
  }
}

class _ModifierPickCard extends StatelessWidget {
  const _ModifierPickCard({
    required this.mod,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });
  final ChallengeModifier mod;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.accentGold.withValues(alpha: 0.08)
                : enabled
                    ? const Color(0xFF231F1B)
                    : const Color(0xFF151310),
            border: Border.all(
              color: selected
                  ? AppTheme.accentGold
                  : enabled
                      ? AppTheme.cardBorder
                      : AppTheme.cardBorder.withValues(alpha: 0.4),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(children: [
            Text(mod.icon,
                style: TextStyle(
                    fontSize: 23,
                    color: enabled ? null : Colors.white24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mod.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: selected
                            ? AppTheme.accentGold
                            : enabled
                                ? Colors.white
                                : Colors.white38,
                      )),
                  const SizedBox(height: 3),
                  Text(mod.description,
                      style: TextStyle(
                          fontSize: 11,
                          color: enabled
                              ? AppTheme.textMuted
                              : AppTheme.textMuted.withValues(alpha: 0.5),
                          height: 1.3)),
                  const SizedBox(height: 6),
                  Text('+${mod.rewardShardBonus} essence/kill',
                      style: TextStyle(
                          fontSize: 10,
                          color: enabled
                              ? const Color(0xFF66aaff)
                              : const Color(0xFF66aaff).withValues(alpha: 0.4),
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: AppTheme.accentGold, size: 20),
          ]),
        ),
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  const _RewardChip(this.label, this.color, {this.prefix});
  final String  label;
  final Color   color;
  final Widget? prefix;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (prefix != null) ...[prefix!, const SizedBox(width: 3)],
        Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow(this.label, this.value, {this.color, this.valuePrefix});
  final String  label;
  final String  value;
  final Color?  color;
  final Widget? valuePrefix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
        const Spacer(),
        if (valuePrefix != null) ...[valuePrefix!, const SizedBox(width: 4)],
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color ?? Colors.white)),
      ]),
    );
  }
}

// -- Shared speed button used in AppBar during battle -------------------------

class _GauntletStartSection extends StatelessWidget {
  const _GauntletStartSection({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final game      = GameStateProvider.of(context);
    final remaining = game.gauntletAttemptsRemaining;
    final canAfford = game.zcoins >= GameState.kGauntletExtraCost;
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.refresh, size: 14, color: AppTheme.textMuted),
          const SizedBox(width: 5),
          Text(
            'Daily attempts: $remaining / ${GameState.kGauntletMaxAttempts}',
            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
        ],
      ),
      const SizedBox(height: 10),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: remaining > 0 ? onStart : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: remaining > 0 ? AppTheme.accentGold : const Color(0xFF1a1410),
            foregroundColor: remaining > 0 ? Colors.black : Colors.white24,
            disabledBackgroundColor: const Color(0xFF1a1410),
            disabledForegroundColor: Colors.white24,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          child: Text(
            remaining > 0 ? 'START GAUNTLET' : 'NO ATTEMPTS LEFT',
            style: AppTheme.pixelHeading(
              fontSize: 13, letterSpacing: 2,
              color: remaining > 0 ? Colors.black : Colors.white24,
            ),
          ),
        ),
      ),
      if (remaining == 0) ...[
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: canAfford ? () => game.buyExtraGauntletAttempt() : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF88ccff),
              side: BorderSide(
                color: canAfford
                    ? const Color(0xFF88ccff).withValues(alpha: 0.6)
                    : Colors.white24,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              ZCoinIcon(size: 13, animate: false),
              const SizedBox(width: 5),
              Text(
                '${GameState.kGauntletExtraCost} zcoins — Buy 1 extra attempt',
                style: TextStyle(fontSize: 12, color: canAfford ? const Color(0xFF88ccff) : Colors.white24),
              ),
            ]),
          ),
        ),
      ],
    ]);
  }
}

class _InlineSpeedButton extends StatelessWidget {
  const _InlineSpeedButton({
    required this.speedTier,
    required this.isDebug,
    required this.onCycle,
  });

  final int speedTier;
  final bool isDebug;
  final VoidCallback onCycle;

  static const _debugLabels = ['1×', '1.5×', '5×', '10×'];
  static const _prodLabels  = ['1×', '1.5×', '2×', '3×'];

  String get _label => isDebug
      ? _debugLabels[(speedTier - 1).clamp(0, 3)]
      : _prodLabels[(speedTier - 1).clamp(0, 3)];

  bool get _active => speedTier > 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onCycle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _active ? const Color(0xFF1a3a1a) : const Color(0xFF1a1a2a),
            border: Border.all(
              color: _active ? const Color(0xFF44cc44) : const Color(0xFF334466),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            _label,
            style: TextStyle(
              color: _active ? const Color(0xFF44cc44) : const Color(0xFF667799),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
