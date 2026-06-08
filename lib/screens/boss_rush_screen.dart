import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/enemy_data.dart';
import '../models/boss_rush.dart';
import '../models/enemy.dart';
import '../models/equipment.dart';
import '../models/passive_tree.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

// The 5 campaign boss stages (0-indexed: every 5th stage starting at 4)
const _bossStages = [4, 9, 14, 19, 24];

class BossRushScreen extends StatefulWidget {
  const BossRushScreen({super.key});

  @override
  State<BossRushScreen> createState() => _BossRushScreenState();
}

class _BossRushScreenState extends State<BossRushScreen> {
  // Run state
  bool _running = false;
  bool _done    = false;

  int _bossIndex  = 0;
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
    final stageIdx = _bossStages[_bossIndex];
    final base = EnemyData.enemyForStage(stageIdx);
    final boss = Enemy(
      id:          base.id,
      name:        '☠ ${base.name} (Boss ${_bossIndex + 1})',
      description: base.description,
      maxHealth:   base.maxHealth * 2,
      attack:      (base.attack * 1.25).round(),
      level:       base.level + 2,
      armorClass:  base.armorClass + 2,
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
    final rng = DateTime.now().microsecondsSinceEpoch;
    final heroRoll = (rng % 20 + 1);
    final crit = heroRoll == 20;
    final heroHit = crit || (heroRoll + _heroAtk) >= boss.armorClass;

    if (heroHit) {
      final dmgDie = rng % 8 + 1;
      var dmg = (crit ? dmgDie * 2 : dmgDie) + _heroDmgMod;
      dmg = dmg.clamp(1, 9999);
      _enemyHp -= dmg;
      _log.add('Roll ${heroRoll + _heroAtk} — Hit! $dmg dmg'
          '${crit ? ' (CRIT!)' : ''}.');
    } else {
      _log.add('Roll ${heroRoll + _heroAtk} vs AC ${boss.armorClass} — Miss.');
    }

    if (_enemyHp <= 0) {
      _enemyHp = 0;
      _log.add('${boss.name} defeated!');
      _bossIndex++;
      if (_bossIndex >= _bossStages.length) {
        _endRun(cleared: true);
        return;
      }
      setState(() {});
      _spawnBoss();
      return;
    }

    // Enemy attacks
    final eRoll = (rng ~/ 100 % 20 + 1);
    final eBonus = boss.level ~/ 2;
    final eHit = eRoll == 20 || (eRoll + eBonus) >= _heroAc;
    if (eHit) {
      final rawDmg = rng ~/ 1000 % (boss.attack > 0 ? boss.attack : 1) + 1;
      final dmg = (eRoll == 20 ? rawDmg * 2 : rawDmg).clamp(1, 9999);
      _heroHp -= dmg;
      _log.add('${boss.name} roll ${eRoll + eBonus} — Hit! $dmg dmg.');
    }

    if (_heroHp <= 0) {
      _heroHp = 0;
      _endRun(cleared: false);
      return;
    }

    setState(() {});
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
    if (cleared) game.recordBossRushComplete();
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
      backgroundColor: const Color(0xFF0a0e27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1f3a),
        title: Text('BOSS RUSH',
            style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 2)),
        actions: [
          if (_running || _done)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(_fmt(_elapsedSec),
                    style: AppTheme.pixelHeading(
                        fontSize: 13, color: AppTheme.accentGold)),
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
              color: const Color(0xFF0e1225),
              border: Border.all(
                  color: AppTheme.accentGold.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BOSS RUSH',
                    style: AppTheme.pixelHeading(
                        fontSize: 16, color: AppTheme.accentGold, letterSpacing: 3)),
                const SizedBox(height: 8),
                const Text(
                  'Face all 5 campaign bosses back-to-back with a single HP bar. '
                  'No healing between fights. Score is based on speed and HP remaining.',
                  style: TextStyle(
                      fontSize: 11, color: AppTheme.textMuted, height: 1.5),
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
                      fontSize: 10, color: AppTheme.textMuted, letterSpacing: 1)),
              Text('${game.bossRushBestScore}',
                  style: AppTheme.pixelHeading(
                      fontSize: 13, color: AppTheme.accentGold)),
              const SizedBox(width: 8),
              Text(_rankFromScore(game.bossRushBestScore),
                  style: AppTheme.pixelHeading(
                      fontSize: 13, color: const Color(0xFF66aaff))),
            ]),
            const SizedBox(height: 16),
          ],
          const Spacer(),
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
              child: Text('BEGIN BOSS RUSH',
                  style: AppTheme.pixelHeading(
                      fontSize: 13, color: AppTheme.accentGold, letterSpacing: 2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRun() {
    final boss = _currentBoss;
    final result = _result;
    return Column(
      children: [
        // HP bars
        Container(
          padding: const EdgeInsets.all(14),
          color: const Color(0xFF0e1225),
          child: Column(children: [
            _HpBar('HERO',
                _heroHp, _heroMaxHp, const Color(0xFF88cc44)),
            const SizedBox(height: 10),
            if (boss != null)
              _HpBar(boss.name.replaceFirst('☠ ', '').replaceFirst(' (Boss ${_bossIndex})', ''),
                  _enemyHp, _enemyMaxHp, const Color(0xFFff4444)),
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
          ]),
        ),

        // Result banner
        if (_done && result != null)
          _ResultBanner(result: result),

        // Log
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            reverse: true,
            itemCount: _log.length,
            itemBuilder: (_, i) {
              final line = _log[_log.length - 1 - i];
              Color c = AppTheme.textMuted;
              if (line.contains('Hit!')) c = const Color(0xFFffcc44);
              if (line.contains('Miss')) c = Colors.white30;
              if (line.contains('CRIT')) c = const Color(0xFFff6633);
              if (line.contains('defeated!') || line.contains('CLEARED') ||
                  line.contains('BOSS')) c = AppTheme.accentGold;
              if (line.contains('ENDED') || line.contains('Hero HP')) c = const Color(0xFFff4444);
              return Text(line,
                  style: TextStyle(
                      fontSize: 11, color: c, fontFamily: 'monospace'));
            },
          ),
        ),

        // Action buttons
        if (_done)
          Padding(
            padding: const EdgeInsets.all(14),
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
                child: Text('PLAY AGAIN',
                    style: AppTheme.pixelHeading(
                        fontSize: 12, letterSpacing: 2)),
              ),
            ),
          ),
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
        Text('$stage  ', style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
        Expanded(child: Text(name, style: const TextStyle(fontSize: 11, color: Colors.white70))),
        Text(stars, style: AppTheme.pixelHeading(fontSize: 9, color: AppTheme.accentGold)),
      ]),
    );
  }
}

class _HpBar extends StatelessWidget {
  const _HpBar(this.label, this.current, this.max, this.color);
  final String label;
  final int current, max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: AppTheme.pixelHeading(fontSize: 9, letterSpacing: 1)),
        Text('$current/$max',
            style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
      ]),
      const SizedBox(height: 4),
      ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: pct,
          minHeight: 7,
          backgroundColor: Colors.white12,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    ]);
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
              fontSize: 15,
              color: cleared ? AppTheme.accentGold : const Color(0xFFff4444),
              letterSpacing: 2),
        ),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _ResultStat('BOSSES', '${result.bossesDefeated}/${result.totalBosses}'),
          const SizedBox(width: 20),
          _ResultStat('SCORE', '${result.score}'),
          const SizedBox(width: 20),
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
              fontSize: 9, color: AppTheme.textMuted, letterSpacing: 1)),
      const SizedBox(height: 2),
      Text(value,
          style: GoogleFonts.pixelifySans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.white)),
    ]);
  }
}
