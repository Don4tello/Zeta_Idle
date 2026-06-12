import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/enemy_data.dart';
import '../models/boss_rush.dart';
import '../models/enemy.dart';
import '../models/equipment.dart';
import '../models/hero_ability.dart';
import '../models/passive_tree.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/battle_arena.dart';
import '../widgets/pet_battle_sprite.dart';

// The 5 campaign boss stages (0-indexed: every 5th stage starting at 4)
const _bossStages = [4, 9, 14, 19, 24];

class BossRushScreen extends StatefulWidget {
  const BossRushScreen({super.key});

  @override
  State<BossRushScreen> createState() => _BossRushScreenState();
}

class _BossRushScreenState extends State<BossRushScreen> {
  final _arenaKey = GlobalKey<BattleArenaState>();

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

  final List<String> _log = [];
  Enemy? _currentBoss;
  BossRushResult? _result;

  Timer? _timer;
  Timer? _autoAttackTimer;

  // Keep a copy of game-state bonuses cached for the run
  late int _heroAtk;
  late int _heroDmgMod;
  late int _heroAc;
  late int _heroMaxHpBase;

  // Local ability state
  int _gAbilityRound = 0;
  final Map<String, int> _gCooldownUntil = {};
  int _tempAtkBonus   = 0;
  int _tempAtkRounds  = 0;
  int _tempAcBonus    = 0;
  int _tempAcRounds   = 0;
  bool _enemyStunned  = false;

  @override
  void dispose() {
    _timer?.cancel();
    _autoAttackTimer?.cancel();
    super.dispose();
  }

  void _startRun() {
    final game = GameStateProvider.of(context);
    _heroAtk     = game.hero.attackBonus
        + game.passiveTree.totalOf(PassiveEffect.attackFlat)
        + game.inventory.totalOf(ItemStat.attackBonus)
        + game.inventory.totalOf(ItemStat.strength)
        + game.petAttackBonus
        + game.skinAttackBonus
        + game.questAttackBonus
        + game.bestiaryChapterBonus;
    _heroDmgMod  = game.hero.damageMod
        + game.passiveTree.totalOf(PassiveEffect.damageFlat)
        + game.inventory.totalOf(ItemStat.damageBonus)
        + game.questDamageBonus;
    _heroAc      = game.hero.armorClass
        + game.passiveTree.totalOf(PassiveEffect.armorFlat)
        + game.inventory.totalOf(ItemStat.armorClass)
        + game.petArmor
        + game.skinArmor
        + game.questACBonus;
    _heroMaxHpBase = game.hero.maxHealth;

    _gAbilityRound = 0;
    _gCooldownUntil.clear();
    _tempAtkBonus  = 0;
    _tempAtkRounds = 0;
    _tempAcBonus   = 0;
    _tempAcRounds  = 0;
    _enemyStunned  = false;

    setState(() {
      _running    = true;
      _done       = false;
      _bossIndex  = 0;
      _heroMaxHp  = _heroMaxHpBase;
      _heroHp     = _heroMaxHp;
      _elapsedSec = 0;
      _log.clear();
    });
    _log.add('⚔ BOSS RUSH BEGINS — ${_bossStages.length} bosses await!');
    _spawnBoss();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_running) return;
      setState(() => _elapsedSec++);
    });

    _autoAttackTimer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      if (!_running || _done) return;
      _doRound();
    });
  }

  void _spawnBoss() {
    final stageIdx   = _bossStages[_bossIndex];
    final base       = EnemyData.enemyForStage(stageIdx);
    final tierHpMult = 1.0 + (_selectedTier - 1) * 0.15;
    final tierAtkMult= 1.0 + (_selectedTier - 1) * 0.08;
    final tierAcBonus= (_selectedTier - 1) ~/ 3;
    final boss = Enemy(
      id:          base.id,
      name:        '☠ ${base.name} (Boss ${_bossIndex + 1})',
      description: base.description,
      maxHealth:   (base.maxHealth * 2 * tierHpMult).round(),
      attack:      (base.attack * 1.25 * tierAtkMult).round(),
      level:       base.level + 2,
      armorClass:  base.armorClass + 2 + tierAcBonus,
    );
    setState(() {
      _currentBoss  = boss;
      _enemyMaxHp   = boss.maxHealth;
      _enemyHp      = boss.maxHealth;
    });
    _log.add('');
    _log.add('BOSS ${_bossIndex + 1}/5 — ${boss.name}  ${boss.maxHealth}HP');
  }

  void _doRound() {
    final boss = _currentBoss;
    if (boss == null) return;
    final game = GameStateProvider.of(context);
    final rng  = DateTime.now().microsecondsSinceEpoch;

    // ── Tick abilities ────────────────────────────────────────────────────
    _gAbilityRound++;
    for (final ability in game.unlockedAbilities) {
      final readyAt = _gCooldownUntil[ability.id] ?? 0;
      if (_gAbilityRound >= readyAt) {
        _applyAbilityEffect(game, ability);
        _gCooldownUntil[ability.id] =
            _gAbilityRound + game.scaledAbilityCooldown(ability);
        if (_enemyHp <= 0) {
          _enemyHp = 0;
          _log.add('${boss.name} defeated!');
          _arenaKey.currentState?.playEnemyDeath();
          _bossIndex++;
          if (_bossIndex >= _bossStages.length) { _endRun(cleared: true); return; }
          setState(() {});
          _spawnBoss();
          return;
        }
      }
    }

    // ── Tick temp buffs ───────────────────────────────────────────────────
    if (_tempAtkRounds > 0) { _tempAtkRounds--; if (_tempAtkRounds == 0) _tempAtkBonus = 0; }
    if (_tempAcRounds  > 0) { _tempAcRounds--;  if (_tempAcRounds  == 0) _tempAcBonus  = 0; }

    // ── Hero attacks ──────────────────────────────────────────────────────
    final effectiveAtk = _heroAtk + _tempAtkBonus;
    final heroRoll     = rng % 20 + 1;
    final crit         = heroRoll == 20;
    final heroHit      = crit || (heroRoll + effectiveAtk) >= boss.armorClass;

    if (heroHit) {
      final dmgDie = rng % 8 + 1;
      var dmg = (crit ? dmgDie * 2 : dmgDie) + _heroDmgMod;
      dmg = dmg.clamp(1, 9999);
      _enemyHp -= dmg;
      _log.add('Roll ${heroRoll + effectiveAtk} — Hit! $dmg dmg${crit ? ' (CRIT!)' : ''}.');
      _arenaKey.currentState?.playHeroAttack(dmg,
          isCrit: crit, heroClass: game.hero.heroClass);
    } else {
      _log.add('Roll ${heroRoll + effectiveAtk} vs AC ${boss.armorClass} — Miss.');
    }

    if (_enemyHp <= 0) {
      _enemyHp = 0;
      _log.add('${boss.name} defeated!');
      _arenaKey.currentState?.playEnemyDeath();
      _bossIndex++;
      if (_bossIndex >= _bossStages.length) { _endRun(cleared: true); return; }
      setState(() {});
      _spawnBoss();
      return;
    }

    // ── Enemy attacks back ────────────────────────────────────────────────
    if (_enemyStunned) {
      _enemyStunned = false;
      _log.add('${boss.name} is stunned — skips attack!');
      setState(() {});
      return;
    }

    final effectiveAc = _heroAc + _tempAcBonus;
    final eRoll       = rng ~/ 100 % 20 + 1;
    final eBonus      = boss.level ~/ 2;
    final eHit        = eRoll == 20 || (eRoll + eBonus) >= effectiveAc;
    if (eHit) {
      final rawDmg = rng ~/ 1000 % (boss.attack > 0 ? boss.attack : 1) + 1;
      final dmg    = (eRoll == 20 ? rawDmg * 2 : rawDmg).clamp(1, 9999);
      _heroHp -= dmg;
      _log.add('${boss.name} roll ${eRoll + eBonus} — Hit! $dmg dmg.');
      _arenaKey.currentState?.playEnemyAttack(dmg);
    }

    if (_heroHp <= 0) {
      _heroHp = 0;
      _endRun(cleared: false);
      return;
    }

    setState(() {});
  }

  void _applyAbilityEffect(GameState game, HeroAbility ability) {
    final sv = game.scaledAbilityValue(ability);
    switch (ability.effect) {
      case AbilityEffect.bonusDamage:
        final dmg = (sv * 0.5).round().clamp(1, 9999);
        _enemyHp -= dmg;
        _log.add('✦ ${ability.name}: $dmg ability damage!');

      case AbilityEffect.heal:
        final h = sv.clamp(1, 9999);
        setState(() => _heroHp = (_heroHp + h).clamp(0, _heroMaxHp));
        _log.add('✦ ${ability.name}: healed $h HP.');

      case AbilityEffect.attackBonus:
        _tempAtkBonus  = sv;
        _tempAtkRounds = ability.duration > 0 ? ability.duration : 3;
        _log.add('✦ ${ability.name}: +$sv ATK for $_tempAtkRounds rounds.');

      case AbilityEffect.acBonus:
        _tempAcBonus  = sv;
        _tempAcRounds = ability.duration > 0 ? ability.duration : 3;
        _log.add('✦ ${ability.name}: +$sv AC for $_tempAcRounds rounds.');

      case AbilityEffect.stun:
        _enemyStunned = true;
        _log.add('✦ ${ability.name}: boss stunned!');

      case AbilityEffect.dot:
        final dmg = (sv * 0.6).round().clamp(1, 9999);
        _enemyHp -= dmg;
        _log.add('✦ ${ability.name}: $dmg DoT damage!');

      case AbilityEffect.dodge:
        _tempAcBonus  = 6;
        _tempAcRounds = 1;
        _log.add('✦ ${ability.name}: dodge — +6 AC this round.');

      case AbilityEffect.aura:
        final h = (sv * 0.5).round().clamp(1, 9999);
        setState(() => _heroHp = (_heroHp + h).clamp(0, _heroMaxHp));
        _log.add('✦ ${ability.name}: aura healed $h HP.');

      case AbilityEffect.debuffWeaken:
        _log.add('✦ ${ability.name}: boss weakened!');

      case AbilityEffect.debuffVulnerable:
        _log.add('✦ ${ability.name}: boss vulnerable!');
    }
  }

  Widget _buildLocalAbilityBar(GameState game) {
    final abilities = game.unlockedAbilities;
    if (abilities.isEmpty) return const SizedBox.shrink();

    const effectColors = <AbilityEffect, Color>{
      AbilityEffect.bonusDamage:      Color(0xFFff6633),
      AbilityEffect.heal:             Color(0xFF44cc66),
      AbilityEffect.attackBonus:      Color(0xFFffcc00),
      AbilityEffect.acBonus:          Color(0xFF66aaff),
      AbilityEffect.stun:             Color(0xFFcc44ff),
      AbilityEffect.dot:              Color(0xFF88dd00),
      AbilityEffect.dodge:            Color(0xFF44ddcc),
      AbilityEffect.aura:             Color(0xFF55ee88),
      AbilityEffect.debuffWeaken:     Color(0xFFff4488),
      AbilityEffect.debuffVulnerable: Color(0xFFff8800),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      color: const Color(0xFF0a0e1f),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: abilities.map((a) {
          final totalCd = game.scaledAbilityCooldown(a);
          final readyAt = _gCooldownUntil[a.id] ?? 0;
          final cd      = (readyAt - _gAbilityRound).clamp(0, totalCd);
          final ready   = cd == 0;
          final color   = effectColors[a.effect] ?? Colors.grey;
          final progress = ready ? 1.0
              : ((totalCd - cd) / totalCd).clamp(0.0, 1.0);

          return SizedBox(
            width: 100,
            child: Container(
              decoration: BoxDecoration(
                color: color.withValues(alpha: ready ? 0.15 : 0.07),
                border: Border.all(
                    color: color.withValues(alpha: ready ? 0.8 : 0.4),
                    width: ready ? 1.5 : 1.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(6, 7, 6, 4),
                    child: Row(children: [
                      Expanded(
                        child: Text(a.name,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: ready ? Colors.white : Colors.white60),
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 4),
                      Text(ready ? 'RDY' : '${cd}r',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: color)),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(1),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _endRun({required bool cleared}) {
    _timer?.cancel();
    _autoAttackTimer?.cancel();
    final result = BossRushResult(
      bossesDefeated: cleared ? _bossStages.length : _bossIndex,
      totalBosses:    _bossStages.length,
      elapsedSeconds: _elapsedSec,
      finalHpPct:     cleared ? (_heroHp / _heroMaxHp) : 0.0,
      cleared:        cleared,
      tier:           _selectedTier,
    );

    final game = GameStateProvider.of(context);
    // Rewards: shards proportional to bosses defeated, extra if cleared
    final shardReward = result.bossesDefeated * 10 + (cleared ? 30 : 0);
    final crystalReward = cleared ? 15 : 0;
    final mythrilReward = switch (result.rank) {
      'S' => 15, 'A' => 10, 'B' => 6, 'C' => 3, _ => 1,
    };
    game.shards   += shardReward;
    game.crystals += crystalReward;
    game.mythril  += mythrilReward;
    if (result.score > (game.bossRushBestScore)) {
      game.bossRushBestScore = result.score;
    }
    if (cleared) game.recordBossRushComplete(tier: _selectedTier);
    game.saveToLocal();

    setState(() {
      _running = false;
      _done    = true;
      _result  = result;
    });
    _log.add('');
    _log.add(cleared ? '★ BOSS RUSH CLEARED!' : '✗ RUN ENDED');
    _log.add(
        'Defeated: ${result.bossesDefeated}/${result.totalBosses}  '
        'Score: ${result.score}  Rank: ${result.rank}');
    _log.add('Rewards: +$shardReward ◆  +$mythrilReward mythril${crystalReward > 0 ? '  +$crystalReward crystals' : ''}');
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
        actions: [
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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF231F1B),
              border: Border.all(
                  color: AppTheme.accentGold.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BOSS RUSH',
                    style: AppTheme.pixelHeading(
                        fontSize: 17, color: AppTheme.accentGold, letterSpacing: 3)),
                const SizedBox(height: 8),
                const Text(
                  'Face all 5 campaign bosses back-to-back with a single HP bar. '
                  'No healing between fights. Score is based on speed and HP remaining.',
                  style: TextStyle(
                      fontSize: 12, color: AppTheme.textMuted, height: 1.5),
                ),
                const SizedBox(height: 12),
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
          const Spacer(),
          // ── Tier Selector ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF231F1B),
              border: Border.all(color: AppTheme.cardBorder),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TIER',
                    style: AppTheme.pixelHeading(
                        fontSize: 11, color: AppTheme.textMuted, letterSpacing: 2)),
                Row(children: [
                  _TierButton(
                    icon: Icons.remove,
                    onTap: _selectedTier > 1
                        ? () => setState(() => _selectedTier--)
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      '$_selectedTier',
                      style: AppTheme.pixelHeading(
                          fontSize: 23, color: AppTheme.accentGold),
                    ),
                  ),
                  _TierButton(
                    icon: Icons.add,
                    onTap: _selectedTier < game.bossRushHighestTier + 1
                        ? () => setState(() => _selectedTier++)
                        : null,
                  ),
                ]),
                Text(
                  game.bossRushHighestTier > 0
                      ? 'Best: ${game.bossRushHighestTier}'
                      : 'First run!',
                  style: AppTheme.pixelHeading(
                      fontSize: 10, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _startRun,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGold.withValues(alpha: 0.12),
                foregroundColor: AppTheme.accentGold,
                side: const BorderSide(color: AppTheme.accentGold),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
              ),
              child: Text('BEGIN BOSS RUSH  —  TIER $_selectedTier',
                  style: AppTheme.pixelHeading(
                      fontSize: 14, color: AppTheme.accentGold, letterSpacing: 2)),
            ),
          ),
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
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                Color c;
                if (i < _bossIndex) {
                  c = const Color(0xFF44cc66);
                } else if (i == _bossIndex && _running) {
                  c = AppTheme.accentGold;
                } else {
                  c = AppTheme.cardBorder;
                }
                return Container(
                  width: 28, height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  color: c,
                );
              }),
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
            child: BattleArena(
              key: _arenaKey,
              heroName:         game.hero.name,
              heroLevel:        game.hero.level,
              heroCurrentHp:    _heroHp,
              heroMaxHp:        _heroMaxHp,
              heroAttack:       _heroAtk,
              heroSpriteId:     game.hero.spriteId,
              heroAuraColor:    game.heroAuraColor,
              heroAuraIntensity: game.heroAuraIntensity,
              heroColorFilter:  game.heroSkinFilter,
              heroPet: game.equippedPet != null
                  ? PetBattleSprite(pet: game.equippedPet!, size: 28)
                  : null,
              enemyName:     boss.name,
              enemyLevel:    boss.level,
              enemyCurrentHp: _enemyHp,
              enemyMaxHp:    _enemyMaxHp,
              enemyAttack:   boss.attack,
              enemyId:       boss.id,
              isBoss:        true,
            ),
          ),

        // Ability bar during active fight
        if (_running && !_done)
          _buildLocalAbilityBar(game),

        // Flee button during active fight
        if (_running && !_done)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: const Color(0xFF0e1228),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: () => _endRun(cleared: false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFcc4444),
                  side: const BorderSide(color: Color(0xFFcc4444)),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                child: Text('FLEE',
                    style: AppTheme.pixelHeading(
                        fontSize: 13, color: const Color(0xFFcc4444), letterSpacing: 2)),
              ),
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
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => setState(() {
                  _done = false;
                  _running = false;
                  _result = null;
                  _log.clear();
                }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGold,
                  foregroundColor: Colors.black,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                child: const Text(
                  'PLAY AGAIN',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => context.pop(),
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
        ] else
          BattleLogBox(log: _log, height: 110),
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
          cleared ? '★ BOSS RUSH CLEARED!' : '✗ DEFEATED',
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
          style: GoogleFonts.pixelifySans(
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
