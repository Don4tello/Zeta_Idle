import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/bestiary_data.dart';
import '../data/enemy_data.dart';
import '../models/boss_rush.dart';
import '../models/damage_type.dart';
import '../models/enemy.dart';
import '../models/equipment.dart';
import '../services/remote_config_service.dart';
import '../models/hero_ability.dart';
import '../models/passive_tree.dart';
import '../screens/leaderboard_screen.dart';
import '../widgets/fight_summary_sheet.dart';
import '../services/game_state.dart';
import '../services/leaderboard_service.dart';
import '../theme/app_theme.dart';
import '../widgets/arena_ability_effect.dart';
import '../widgets/battle_arena.dart';
import '../widgets/battle_split_panel.dart';
import '../widgets/pet_battle_sprite.dart';
import '../widgets/tier_selector.dart';
import '../widgets/zcoin_icon.dart';
import 'main_shell.dart' show TutorialTip;

// The 5 campaign boss stages (0-indexed: every 5th stage starting at 4)
const _bossStages = [4, 9, 14, 19, 24];

class BossRushScreen extends StatefulWidget {
  const BossRushScreen({super.key});

  @override
  State<BossRushScreen> createState() => _BossRushScreenState();
}

class _BossRushScreenState extends State<BossRushScreen> {
  final _arenaKey  = GlobalKey<BattleArenaState>();
  final _effectKey = GlobalKey<ArenaAbilityEffectState>();

  // Run state
  bool _running = false;
  bool _done    = false;

  int _selectedTier = 1;
  int _bossIndex    = 0;
  int _heroHp     = 0;
  int _heroMaxHp  = 0;
  int _enemyHp    = 0;
  int _enemyMaxHp = 0;
  int _elapsedSec = 0;
  // Per-run fight-summary tracking (accumulates across all bosses in the run).
  int _totalDealt = 0;
  int _maxHit = 0;
  int _hitCount = 0;
  final Map<String, int> _fightAbilities = {};

  final List<String> _log = [];
  Enemy? _currentBoss;
  BossRushResult? _result;
  bool _bossEnraged = false;

  Timer? _timer;
  Timer? _autoAttackTimer;
  Timer? _autoRestartTimer;
  bool _autoRepeat = false;

  // Keep a copy of game-state bonuses cached for the run
  late int _heroDmgMod;
  late int _heroAc;
  late int _heroMaxHpBase;
  late DamageType _heroDmgType;
  double _heroDmgAllPct   = 0;
  double _heroPrestigeMult = 1.0;
  int _rebirthLvl = 0;
  int _heroCritChancePct = 0;
  int _heroCritDmgMult   = 2;
  Map<DamageType, int> _bossResistances = {};
  bool _busyRound = false;

  GameState? _game;

  // Local ability state
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

  @override
  void dispose() {
    _timer?.cancel();
    _autoAttackTimer?.cancel();
    _autoRestartTimer?.cancel();
    _game?.audioService.endBattleMusic();
    super.dispose();
  }

  void _startAttackTimer() {
    _autoAttackTimer?.cancel();
    // 1200ms base matches the Dungeon so every arena mode paces the same.
    final ms = _game?.scaledInterval(1200) ?? 1200;
    _autoAttackTimer = Timer.periodic(Duration(milliseconds: ms), (_) {
      if (!_running || _done || _busyRound) return;
      _busyRound = true;
      _doRound().then((_) => _busyRound = false);
    });
  }

  void _cycleSpeed() {
    final game = _game;
    if (game == null) return;
    final maxTier = kDebugMode ? 4 : ((game.hasSpeedSub || game.hasPremium) ? 4 : (game.speedBoostActive ? 3 : 2));
    game.setSpeedTier((game.speedTier % maxTier) + 1);
    _startAttackTimer();
  }

  void _startRun() {
    final game = GameStateProvider.of(context);
    if (!game.consumeBossRushAttempt()) return;
    _heroDmgMod  = game.hero.baseDmg
        + game.passiveTree.totalOf(PassiveEffect.damageFlat)
        + game.inventory.totalOf(ItemStat.damageBonus)
        + game.questDamageBonus;
    _heroDmgType      = game.hero.activeDamageType;
    _heroDmgAllPct    = game.heroAllDamagePctFor(_heroDmgType);
    _heroPrestigeMult = game.prestigeLevel > 0 ? game.prestigeDamageMult : 1.0;
    _rebirthLvl        = game.prestigeLevel;
    _heroCritChancePct = game.totalCritChancePct;
    _heroCritDmgMult   = game.totalCritDamageMult.round();
    _heroAc      = game.hero.armorClass
        + game.passiveTree.totalOf(PassiveEffect.armorFlat)
        + game.inventory.totalOf(ItemStat.armorClass)
        + game.petArmor
        + game.skinArmor
        + game.questACBonus;
    _heroMaxHpBase = game.hero.maxHealth;

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
      _running    = true;
      _done       = false;
      _bossIndex  = 0;
      _heroMaxHp  = _heroMaxHpBase;
      _heroHp     = _heroMaxHp;
      _elapsedSec = 0;
      _totalDealt = 0;
      _maxHit     = 0;
      _hitCount   = 0;
      _fightAbilities.clear();
      _log.clear();
    });
    _log.add('⚔ BOSS RUSH BEGINS — ${_bossStages.length} bosses await!');
    _spawnBoss();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_running) return;
      setState(() => _elapsedSec++);
    });

    _game = game;
    game.audioService.startBattleMusic();
    _startAttackTimer();
  }

  void _spawnBoss() {
    final stageIdx    = _bossStages[_bossIndex];
    final base        = EnemyData.enemyForStage(stageIdx, prestigeLevel: _rebirthLvl);
    final t           = _selectedTier - 1;
    // Steep per-tier scaling — each tier is a meaningful difficulty jump.
    final tierHpMult  = 1.0 + t * 0.40;
    final tierAtkMult = 1.0 + t * 0.25;
    final tierAcBonus = t ~/ 2;
    // Boss level scales with tier so its to-hit bonus grows meaningfully.
    final bossLevel   = base.level + 2 + t;
    final boss = Enemy(
      id:          base.id,
      name:        '★ ${base.name} (Boss ${_bossIndex + 1})',
      description: base.description,
      maxHealth:   (base.maxHealth * 2 * tierHpMult * RemoteConfigService.instance.bossRushHpMult).round(),
      attack:      (base.attack * 1.25 * tierAtkMult * RemoteConfigService.instance.bossRushAtkMult).round(),
      level:       bossLevel,
      armorClass:  base.armorClass + 2 + tierAcBonus,
    );
    _bossResistances = base.resistances;
    _bossEnraged    = false;
    _enemyWeakenRem = 0;
    _enemyVulnRem   = 0;
    setState(() {
      _currentBoss  = boss;
      _enemyMaxHp   = boss.maxHealth;
      _enemyHp      = boss.maxHealth;
    });
    _log.add('');
    _log.add('BOSS ${_bossIndex + 1}/5 — ${boss.name}  ${boss.maxHealth}HP');
  }

  Future<void> _doRound() async {
    final boss = _currentBoss;
    if (boss == null) return;
    final game = GameStateProvider.of(context);

    // -- Tick abilities ----------------------------------------------------
    _gAbilityRound++;
    if (_gAbilityRound > 1) _log.add('— Round $_gAbilityRound —');
    for (final ability in game.unlockedAbilities) {
      final readyAt = _gCooldownUntil[ability.id] ?? 0;
      if (_gAbilityRound >= readyAt) {
        _fightAbilities[ability.name] = (_fightAbilities[ability.name] ?? 0) + 1;
        _applyAbilityEffect(game, ability);
        _gCooldownUntil[ability.id] =
            _gAbilityRound + game.scaledAbilityCooldown(ability);
        if (_enemyHp <= 0) {
          _enemyHp = 0;
          _log.add('${boss.name} defeated!');
          _game?.recordExternalKill(isBoss: true, enemyName: boss.name);
          _arenaKey.currentState?.playEnemyDeath();
          await Future.delayed(const Duration(milliseconds: 900));
          _bossIndex++;
          if (_bossIndex >= _bossStages.length) { _endRun(cleared: true); return; }
          final heal = (_heroMaxHp * 0.25).round();
          _heroHp = (_heroHp + heal).clamp(0, _heroMaxHp);
          _log.add('⚕ Recovered $heal HP before next boss.');
          if (mounted) setState(() {});
          _spawnBoss();
          return;
        }
      }
    }

    // -- Tick temp buffs ---------------------------------------------------
    if (_tempAtkRounds > 0) { _tempAtkRounds--; if (_tempAtkRounds == 0) _tempAtkBonus = 0; }
    if (_tempAcRounds  > 0) { _tempAcRounds--;  if (_tempAcRounds  == 0) _tempAcBonus  = 0; }

    // -- Hero attacks (always lands, same as campaign; crit is chance-based;
    //    ability ATK buff converts to crit chance) -------------------------
    final critPct = _heroCritChancePct + _tempAtkBonus * 2;
    final crit    = _rng.nextInt(100) < critPct;
    {
      final dmgDie = _rng.nextInt(8) + 1;
      var dmg = (crit ? dmgDie * _heroCritDmgMult : dmgDie) + _heroDmgMod;
      dmg = (dmg * (1 + _heroDmgAllPct / 100.0)).round();
      final res = (_bossResistances[_heroDmgType] ?? 0).clamp(-200, 75);
      if (res != 0) dmg = (dmg * (1 - res / 100.0)).round();
      dmg = (dmg * _heroPrestigeMult).round();
      if (_enemyVulnRem > 0) dmg = (dmg * 1.25).round();
      dmg = dmg.clamp(1, 9999);
      _enemyHp -= dmg;
      _totalDealt += dmg; _hitCount++; if (dmg > _maxHit) _maxHit = dmg;
      _log.add('${crit ? 'CRIT! ' : 'Hit! '}$dmg dmg${_enemyVulnRem > 0 ? ' (vuln)' : ''}.');
      game.audioService.playHitWithType(_heroDmgType);
      _arenaKey.currentState?.playHeroAttack(dmg,
          isCrit: crit, heroClass: game.hero.heroClass,
          damageType: _heroDmgType);
    }

    if (_enemyHp <= 0) {
      _enemyHp = 0;
      _log.add('${boss.name} defeated!');
      _game?.recordExternalKill(isBoss: true, enemyName: boss.name);
      _arenaKey.currentState?.playEnemyDeath();
      await Future.delayed(const Duration(milliseconds: 900));
      _bossIndex++;
      if (_bossIndex >= _bossStages.length) { _endRun(cleared: true); return; }
      final heal = (_heroMaxHp * 0.25).round();
      _heroHp = (_heroHp + heal).clamp(0, _heroMaxHp);
      _log.add('⚕ Recovered $heal HP before next boss.');
      if (mounted) setState(() {});
      _spawnBoss();
      return;
    }

    // -- Boss enrage at 30% HP ---------------------------------------------
    if (!_bossEnraged && _enemyHp / _enemyMaxHp < 0.30) {
      _bossEnraged = true;
      _log.add('⚡ ${boss.name} ENRAGES! +100% damage!');
    }

    // -- Enemy attacks back ------------------------------------------------
    if (_enemyStunned) {
      _enemyStunned = false;
      _log.add('${boss.name} is stunned — skips attack!');
      if (mounted) setState(() {});
      return;
    }
    // Enemy always lands (same as campaign); armor is flat damage reduction
    // (min 1 so bosses always connect).
    {
      final armor  = _heroAc + _tempAcBonus;
      final atkMax = _enemyWeakenRem > 0
          ? max(1, (boss.attack * 0.7).round())
          : boss.attack;
      var rawDmg = atkMax > 0 ? _rng.nextInt(atkMax) + 1 : 1;
      if (_bossEnraged) rawDmg = (rawDmg * 2.0).round().clamp(1, 9999);
      final dmg = (rawDmg - armor).clamp(1, 9999);
      _heroHp -= dmg;
      _log.add('${boss.name} hits! $dmg dmg'
          '${_bossEnraged ? ' ⚡' : ''}${_enemyWeakenRem > 0 ? ' (weakened)' : ''}.');
      game.audioService.playEnemyAttack(weaknessForEnemyId(boss.id));
      _arenaKey.currentState?.playEnemyAttack(dmg);
    }

    if (_heroHp <= 0) {
      _heroHp = 0;
      if (mounted) setState(() {});
      await (_arenaKey.currentState?.playHeroDeath() ?? Future.value());
      await Future.delayed(const Duration(seconds: 3));
      _endRun(cleared: false);
      return;
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
        _log.add('+ ${ability.name}: healed $h HP.');
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
        _log.add('◉ ${ability.name}: boss stunned!');

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
        _log.add('+ ${ability.name}: aura healed $h HP.');
        _arenaKey.currentState?.addExtraFloat(h, isHeal: true);

      case AbilityEffect.debuffWeaken:
        _enemyWeakenRem = 3;
        _log.add('✸ ${ability.name}: boss weakened for 3 rounds!');

      case AbilityEffect.debuffVulnerable:
        _enemyVulnRem = 3;
        _log.add('⚡ ${ability.name}: boss vulnerable for 3 rounds!');

      case AbilityEffect.silence:
        _enemyStunned = true;
        _log.add('◉ ${ability.name}: boss silenced!');

      case AbilityEffect.absorbShield:
        setState(() => _heroHp = (_heroHp + sv).clamp(0, _heroMaxHp));
        _log.add('+ ${ability.name}: +$sv HP barrier!');

      case AbilityEffect.missChance:
        _enemyWeakenRem = ability.duration > 0 ? ability.duration : 2;
        _log.add('✸ ${ability.name}: boss miss chance applied!');
    }
  }

  void _endRun({required bool cleared}) {
    _timer?.cancel();
    _autoAttackTimer?.cancel();
    _game?.audioService.endBattleMusic();
    final result = BossRushResult(
      bossesDefeated: cleared ? _bossStages.length : _bossIndex,
      totalBosses:    _bossStages.length,
      elapsedSeconds: _elapsedSec,
      finalHpPct:     cleared ? (_heroHp / _heroMaxHp) : 0.0,
      cleared:        cleared,
      tier:           _selectedTier,
    );

    final game = GameStateProvider.of(context);
    game.lastFightSummary = FightSummary(
      enemyName: 'Boss Rush · Tier $_selectedTier',
      victory: cleared,
      totalDamage: _totalDealt,
      maxHit: _maxHit,
      hitCount: _hitCount,
      rounds: _gAbilityRound,
      abilitiesUsed: Map<String, int>.from(_fightAbilities),
      log: List<String>.from(_log),
    );
    // Rewards: shards proportional to bosses defeated, extra if cleared.
    // Soft rewards scale with rebirth to match the +prestige boss difficulty.
    final rebirthMult = 1.0 + game.prestigeLevel * 0.15;
    final shardReward = ((result.bossesDefeated * 10 + (cleared ? 30 : 0)) * rebirthMult).round();
    final echoReward = ((result.bossesDefeated * 6 + (cleared ? 25 : 0)) * rebirthMult).round();
    final crystalReward = cleared ? 15 : 0;
    final mythrilReward = switch (result.rank) {
      'S' => 15, 'A' => 10, 'B' => 6, 'C' => 3, _ => 1,
    };
    game.shards   += shardReward;
    game.echoes   += echoReward;
    game.zcoins += crystalReward;
    game.mythril  += mythrilReward;
    if (result.score > (game.bossRushBestScore)) {
      game.bossRushBestScore = result.score;
    }
    // Update the Boss Rush leaderboard (fire-and-forget, personal-best only).
    LeaderboardService.submitScore(
      board:     LeaderboardBoard.bossRush,
      heroName:  game.hero.name,
      heroClass: game.hero.heroClass.displayName,
      subclass:  game.subclassName,
      spriteId:  game.hero.spriteId,
      rebirths:  game.prestigeLevel,
      stage:     game.bossRushBestScore,
    );
    if (cleared) game.recordBossRushComplete(tier: _selectedTier);
    // Artifact drop: A or S rank clears reward 1 artifact
    if (cleared && (result.rank == 'S' || result.rank == 'A')) {
      final artLv = (_selectedTier * 10).clamp(1, 50);
      game.gainArtifact(artLv);
    }
    game.saveToLocal();

    setState(() {
      _running = false;
      _done    = true;
      _result  = result;
    });
    _log.add('');
    _log.add(cleared ? '? BOSS RUSH CLEARED!' : '? RUN ENDED');

    if (_autoRepeat) {
      _autoRestartTimer = Timer(const Duration(seconds: 2), () {
        if (!mounted || !_autoRepeat) return;
        _startRun();
      });
    }
    _log.add(
        'Defeated: ${result.bossesDefeated}/${result.totalBosses}  '
        'Score: ${result.score}  Rank: ${result.rank}');
    _log.add('Rewards: +$shardReward shard  +$echoReward echo  +$mythrilReward mythril${crystalReward > 0 ? '  +$crystalReward zcoins' : ''}');
  }

  String _fmt(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('BOSS RUSH',
            style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
        leading: _running && !_done
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => _endRun(cleared: false),
              )
            : null,
        automaticallyImplyLeading: !_running || _done,
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
          if (!_running && !_done)
            IconButton(
              icon: const Icon(Icons.leaderboard, color: AppTheme.accentGold, size: 20),
              tooltip: 'Boss Rush Leaderboard',
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const LeaderboardScreen(board: LeaderboardBoard.bossRush),
              )),
            ),
          if (_running && _game != null)
            _InlineSpeedButton(
              speedTier: _game!.speedTier,
              isDebug: kDebugMode,
              onCycle: _cycleSpeed,
            ),
          if (_running || _done)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(_fmt(_elapsedSec),
                    style: AppTheme.pixelHeading(
                        fontSize: 14, color: AppTheme.accentGold)),
              ),
            ),
        ],
      ),
      body: _running || _done ? _buildRun() : _buildLobby(),
    );
  }

  Widget _buildLobby() {
    final game = GameStateProvider.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero image
          Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: 220,
                child: Image.asset('assets/images/boss_rush_bg.png',
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
                  'Face all 5 bosses back-to-back. No healing between fights.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Color(0xFFccbbaa), height: 1.4),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          TutorialTip(
            tutorialKey: 'bossRush',
            game: game,
            text: 'Boss Rush pits you against a gauntlet of bosses in sequence. Each boss is stronger than the last. How far can you go?',
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1a1816),
              border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BossLine('Stage 5',  'Pixie Boss',    '★'),
                _BossLine('Stage 10', 'Hobgoblin Boss', '★★'),
                _BossLine('Stage 15', 'Wyvern Boss',   '★★★'),
                _BossLine('Stage 20', 'Eye Watcher Boss', '★★★★'),
                _BossLine('Stage 25', 'Phoenix Boss',  '★★★★★'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (game.bossRushBestScore > 0) ...[
            Row(children: [
              Text('BEST SCORE: ',
                  style: AppTheme.pixelHeading(
                      fontSize: 11, color: AppTheme.textMuted, letterSpacing: 1)),
              Text('${game.bossRushBestScore}',
                  style: AppTheme.pixelHeading(
                      fontSize: 14, color: AppTheme.accentGold)),
              const SizedBox(width: 8),
              Text(_rankFromScore(game.bossRushBestScore),
                  style: AppTheme.pixelHeading(
                      fontSize: 14, color: const Color(0xFF66aaff))),
            ]),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 16),
          TierSelector(
            selectedTier: _selectedTier,
            maxUnlocked: (game.bossRushHighestTier + 1).clamp(1, 10),
            highestCleared: game.bossRushHighestTier,
            onTierChange: (t) => setState(() => _selectedTier = t),
          ),
          const SizedBox(height: 12),
          _BossRushStartSection(
            tier: _selectedTier,
            onStart: _startRun,
          ),
        ])),
        ],
      ),
    );
  }

  Widget _buildRun() {
    final boss   = _currentBoss;
    final result = _result;
    final game   = GameStateProvider.of(context);
    return Column(
      children: [
        // Boss progress pips + result banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: const Color(0xFF2A2623),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TIER $_selectedTier',
                    style: AppTheme.pixelHeading(
                        fontSize: 12, color: AppTheme.accentGold, letterSpacing: 2)),
                Text('BOSS ${_bossIndex + 1} / ${_bossStages.length}',
                    style: AppTheme.pixelHeading(
                        fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
            const SizedBox(height: 10),
            _BossProgressTrack(
              bossIndex: _bossIndex,
              running: _running,
              done: _done,
            ),
            if (_done && result != null) ...[
              const SizedBox(height: 8),
              _ResultBanner(result: result),
            ],
          ]),
        ),

        // Full battle arena (shown only while running)
        if (boss != null && !_done)
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                BattleArena(
                  key: _arenaKey,
                  stageIndex:       _bossStages[_bossIndex.clamp(0, _bossStages.length - 1)],
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
                  enemyName:     boss.name,
                  enemyLevel:    boss.level,
                  enemyCurrentHp: _enemyHp,
                  enemyMaxHp:    _enemyMaxHp,
                  enemyAttack:   boss.attack,
                  enemyId:       boss.id,
                  headerLabel:   '⚔  BOSS RUSH  ⚔',
                  isBoss:        true,
                  isBossEnraged: _bossEnraged,
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

        // Ability bar during active fight
        if (_running && !_done)
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

        // After run: show log + play-again button
        if (_done) ...[
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              reverse: true,
              itemCount: _log.length,
              itemBuilder: (_, i) {
                final line = _log[_log.length - 1 - i];
                Color c = AppTheme.textLight;
                if (line.contains('Hit!')) c = const Color(0xFFffcc44);
                if (line.contains('Miss')) c = AppTheme.textMuted;
                if (line.contains('CRIT')) c = const Color(0xFFff6633);
                if (line.contains('defeated!') || line.contains('CLEARED') ||
                    line.contains('BOSS')) c = AppTheme.accentGold;
                if (line.contains('ENDED')) c = const Color(0xFFff4444);
                return Text(line,
                    style: TextStyle(fontSize: 13, color: c, fontFamily: 'monospace'));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
            child: Row(children: [
              // AUTO toggle
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => setState(() {
                      _autoRepeat = !_autoRepeat;
                      if (_autoRepeat) {
                        _autoRestartTimer?.cancel();
                        _startRun();
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
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    child: Text(_autoRepeat ? 'STOP AUTO' : 'AUTO',
                        style: AppTheme.pixelHeading(
                            fontSize: 13,
                            letterSpacing: 2,
                            color: _autoRepeat
                                ? const Color(0xFFff4444)
                                : const Color(0xFF44dd88))),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Play again manually
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => setState(() {
                      _autoRepeat = false;
                      _autoRestartTimer?.cancel();
                      _done    = false;
                      _running = false;
                      _result  = null;
                      _log.clear();
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGold,
                      foregroundColor: Colors.black,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    child: const Text('PLAY AGAIN',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: 2)),
                  ),
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  _autoRepeat = false;
                  _autoRestartTimer?.cancel();
                  _autoAttackTimer?.cancel();
                  setState(() {
                    _running = false;
                    _done = false;
                    _result = null;
                    _currentBoss = null;
                    _bossIndex = 0;
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textMuted,
                  side: const BorderSide(color: AppTheme.cardBorder),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                child: Text('BACK',
                    style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2, color: AppTheme.textMuted)),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

String _rankFromScore(int s) {
  if (s >= 4500) return 'S';
  if (s >= 3500) return 'A';
  if (s >= 2500) return 'B';
  if (s >= 1500) return 'C';
  return 'D';
}

// -- Boss Progress Track -------------------------------------------------------

class _BossProgressTrack extends StatefulWidget {
  const _BossProgressTrack({
    required this.bossIndex,
    required this.running,
    required this.done,
  });
  final int bossIndex;
  final bool running;
  final bool done;

  @override
  State<_BossProgressTrack> createState() => _BossProgressTrackState();
}

class _BossProgressTrackState extends State<_BossProgressTrack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  )..repeat(reverse: true);

  static const _icons  = ['✦', '⚔', '◆', '◉', '★'];
  static const _names  = ['Pixie', 'Hobgoblin', 'Wyvern', 'Eye', 'Phoenix'];
  static const _total  = 5;

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _total; i++) ...[
          _BossNode(
            icon:     _icons[i],
            name:     _names[i],
            defeated: i < widget.bossIndex,
            active:   i == widget.bossIndex && widget.running,
            pulse:    _pulse,
          ),
          if (i < _total - 1)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 18),
                child: Container(
                  height: 2,
                  color: i < widget.bossIndex
                      ? const Color(0xFF44cc66)
                      : AppTheme.cardBorder,
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _BossNode extends StatelessWidget {
  const _BossNode({
    required this.icon,
    required this.name,
    required this.defeated,
    required this.active,
    required this.pulse,
  });
  final String icon;
  final String name;
  final bool defeated;
  final bool active;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    final borderColor = defeated
        ? const Color(0xFF44cc66)
        : active ? AppTheme.accentGold : AppTheme.cardBorder;
    final bgColor = defeated
        ? const Color(0xFF44cc66).withValues(alpha: 0.10)
        : active ? AppTheme.accentGold.withValues(alpha: 0.13)
               : const Color(0xFF151210);
    final labelColor = defeated
        ? const Color(0xFF44cc66)
        : active ? AppTheme.accentGold : AppTheme.textMuted.withValues(alpha: 0.45);

    return SizedBox(
      width: 46,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: pulse,
            builder: (_, __) {
              final glow = active ? pulse.value * 0.35 : 0.0;
              return Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border.all(
                    color: borderColor,
                    width: active ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: active
                      ? [BoxShadow(
                          color: AppTheme.accentGold.withValues(alpha: glow),
                          blurRadius: 12,
                          spreadRadius: 2,
                        )]
                      : [],
                ),
                child: Text(
                  defeated ? '✓' : icon,
                  style: TextStyle(
                    fontSize: defeated ? 17 : 21,
                    color: defeated ? const Color(0xFF44cc66)
                        : active ? null
                        : Colors.white24,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            name,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 8,
              color: labelColor,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------

class _BossLine extends StatelessWidget {
  const _BossLine(this.stage, this.name, this.stars);
  final String stage, name, stars;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Text('$stage  ', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
        Expanded(child: Text(name, style: const TextStyle(fontSize: 12, color: Colors.white70))),
        Text(stars, style: AppTheme.pixelHeading(fontSize: 10, color: AppTheme.accentGold)),
      ]),
    );
  }
}


class _ResultBanner extends StatelessWidget {
  const _ResultBanner({required this.result});
  final BossRushResult result;

  @override
  Widget build(BuildContext context) {
    final cleared = result.cleared;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: cleared
          ? AppTheme.accentGold.withValues(alpha: 0.08)
          : const Color(0xFFff4444).withValues(alpha: 0.08),
      child: Column(children: [
        Text(
          cleared ? '? BOSS RUSH CLEARED!' : '? DEFEATED',
          style: AppTheme.pixelHeading(
              fontSize: 16,
              color: cleared ? AppTheme.accentGold : const Color(0xFFff4444),
              letterSpacing: 2),
        ),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _ResultStat('TIER',  '${result.tier}',
              color: AppTheme.accentGold),
          const SizedBox(width: 16),
          _ResultStat('BOSSES', '${result.bossesDefeated}/${result.totalBosses}'),
          const SizedBox(width: 16),
          _ResultStat('SCORE', '${result.score}'),
          const SizedBox(width: 16),
          _ResultStat('RANK', result.rank,
              color: const Color(0xFF66aaff)),
        ]),
      ]),
    );
  }
}

class _ResultStat extends StatelessWidget {
  const _ResultStat(this.label, this.value, {this.color});
  final String label, value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(label,
          style: AppTheme.pixelHeading(
              fontSize: 10, color: AppTheme.textMuted, letterSpacing: 1)),
      const SizedBox(height: 2),
      Text(value,
          style: GoogleFonts.rajdhani(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.white)),
    ]);
  }
}

class _TierButton extends StatelessWidget {
  const _TierButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled
              ? AppTheme.accentGold.withValues(alpha: 0.12)
              : const Color(0xFF1a1a1a),
          border: Border.all(
            color: enabled
                ? AppTheme.accentGold.withValues(alpha: 0.6)
                : AppTheme.cardBorder.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon,
            size: 18,
            color: enabled ? AppTheme.accentGold : AppTheme.textMuted),
      ),
    );
  }
}

class _BossRushStartSection extends StatelessWidget {
  const _BossRushStartSection({required this.tier, required this.onStart});
  final int tier;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final game      = GameStateProvider.of(context);
    final remaining = game.bossRushAttemptsRemaining;
    final canAfford = game.zcoins >= GameState.kBossRushExtraCost;
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.refresh, size: 14, color: AppTheme.textMuted),
          const SizedBox(width: 5),
          Text(
            'Daily attempts: $remaining / ${GameState.kBossRushMaxAttempts}',
            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
        ],
      ),
      const SizedBox(height: 10),
      // ── Rewards preview: what you can find in a Boss Rush run ──────────
      Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF14100a),
          border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.35)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('POSSIBLE REWARDS',
                style: AppTheme.pixelHeading(
                    fontSize: 11, letterSpacing: 2, color: AppTheme.accentGold)),
            const SizedBox(height: 8),
            const _RewardRow(icon: '🔷', label: 'Shards', detail: '10 per boss  ·  +30 on full clear'),
            const _RewardRow(icon: '🌀', label: 'Echoes', detail: '6 per boss  ·  +25 on full clear'),
            const _RewardRow(icon: '💎', label: 'ZCoins', detail: '15 on a full clear'),
            const _RewardRow(icon: '⛏️', label: 'Mythril', detail: 'Scaled by final rank'),
            const _RewardRow(icon: '🏺', label: 'Artifact', detail: 'Chance drop on A / S-rank clears'),
          ],
        ),
      ),
      SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: remaining > 0 ? onStart : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: remaining > 0
                ? AppTheme.accentGold.withValues(alpha: 0.12)
                : const Color(0xFF1a1410),
            foregroundColor: remaining > 0 ? AppTheme.accentGold : Colors.white24,
            disabledBackgroundColor: const Color(0xFF1a1410),
            disabledForegroundColor: Colors.white24,
            side: BorderSide(
              color: remaining > 0 ? AppTheme.accentGold : Colors.white24,
            ),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          child: Text(
            remaining > 0
                ? 'BEGIN BOSS RUSH  —  TIER $tier'
                : 'NO ATTEMPTS LEFT',
            style: AppTheme.pixelHeading(
              fontSize: 14, letterSpacing: 2,
              color: remaining > 0 ? AppTheme.accentGold : Colors.white24,
            ),
          ),
        ),
      ),
      if (remaining == 0) ...[
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: canAfford ? () => game.buyExtraBossRushAttempt() : null,
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
                '${GameState.kBossRushExtraCost} zcoins — Buy 1 extra attempt',
                style: TextStyle(fontSize: 12, color: canAfford ? const Color(0xFF88ccff) : Colors.white24),
              ),
            ]),
          ),
        ),
      ],
    ]);
  }
}

class _RewardRow extends StatelessWidget {
  const _RewardRow({required this.icon, required this.label, required this.detail});
  final String icon, label, detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        SizedBox(width: 22, child: Text(icon, style: const TextStyle(fontSize: 14))),
        SizedBox(
          width: 64,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: Text(detail,
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
        ),
      ]),
    );
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
