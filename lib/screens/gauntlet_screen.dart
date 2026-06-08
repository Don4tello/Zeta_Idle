import 'dart:async';
import 'package:flutter/material.dart';
import '../data/enemy_data.dart';
import '../models/challenge_modifier.dart';
import '../models/enemy.dart';
import '../models/equipment.dart';
import '../models/gauntlet.dart';
import '../models/passive_tree.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

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

  // ── Modifier selection ───────────────────────────────────────────────────
  final Set<String> _selectedIds = {};

  // ── Battle state ─────────────────────────────────────────────────────────
  int _waveIndex  = 0;
  int _heroHp     = 0;
  int _heroMaxHp  = 0;
  int _enemyHp    = 0;
  int _enemyMaxHp = 0;
  int _kills      = 0;

  final List<String> _log = [];
  Enemy? _currentEnemy;
  Timer? _autoTimer;

  // Cached hero stats (computed at run start)
  late int _heroAtk;
  late int _heroDmgMod;
  late int _heroAc;

  // Combined modifier values
  double _enemyHpMult   = 1.0;
  double _enemyAtkMult  = 1.0;
  double _heroHpMult    = 1.0;
  int    _shardBonusPerKill = 0;

  // ── Result ───────────────────────────────────────────────────────────────
  GauntletResult? _result;

  @override
  void dispose() {
    _autoTimer?.cancel();
    super.dispose();
  }

  // ── Modifier pick ─────────────────────────────────────────────────────────

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

    // Aggregate modifier effects
    _enemyHpMult  = 1.0;
    _enemyAtkMult = 1.0;
    _heroHpMult   = 1.0;
    _shardBonusPerKill = 0;

    for (final id in _selectedIds) {
      final mod = ChallengeModifier.all.firstWhere((m) => m.id == id);
      _enemyHpMult  *= mod.enemyHpMult;
      _enemyAtkMult *= mod.enemyAtkMult;
      _heroHpMult   *= mod.heroHpMult;
      _shardBonusPerKill += mod.rewardShardBonus;
    }

    // Cache hero stats
    _heroAtk = game.hero.attackBonus
        + game.passiveTree.totalOf(PassiveEffect.attackFlat)
        + game.inventory.totalOf(ItemStat.attackBonus)
        + game.inventory.totalOf(ItemStat.strength)
        + game.petAttackBonus
        + game.skinAttackBonus
        + game.questAttackBonus
        + game.bestiaryChapterBonus
        + game.runeAtkBonus
        + game.ascAtkBonus;

    _heroDmgMod = game.hero.damageMod
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

    final baseMaxHp = (game.hero.maxHealth * _heroHpMult).round().clamp(1, 999999);

    setState(() {
      _phase      = _Phase.battle;
      _waveIndex  = 0;
      _kills      = 0;
      _heroMaxHp  = baseMaxHp;
      _heroHp     = baseMaxHp;
      _log.clear();
    });
    _log.add('⚔ GAUNTLET STARTS — ${_kGauntletEnemies} enemies await!');
    _spawnEnemy();

    _autoTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (_phase != _Phase.battle) return;
      _doRound();
    });
  }

  void _spawnEnemy() {
    final stage = _kGauntletStages[_waveIndex];
    final base  = EnemyData.enemyForStage(stage);
    final scaled = Enemy(
      id:          base.id,
      name:        '${base.name}  [${_waveIndex + 1}/$_kGauntletEnemies]',
      description: base.description,
      maxHealth:   (base.maxHealth * _enemyHpMult).round().clamp(1, 999999),
      attack:      (base.attack * _enemyAtkMult).round().clamp(1, 9999),
      level:       base.level,
      armorClass:  base.armorClass,
    );
    setState(() {
      _currentEnemy = scaled;
      _enemyMaxHp   = scaled.maxHealth;
      _enemyHp      = scaled.maxHealth;
    });
    _log.add('');
    _log.add('Wave ${_waveIndex + 1}: ${base.name}  (${scaled.maxHealth} HP)');
  }

  void _doRound() {
    final enemy = _currentEnemy;
    if (enemy == null) return;
    final rng = DateTime.now().microsecondsSinceEpoch;
    final heroRoll = rng % 20 + 1;
    final crit     = heroRoll == 20;
    final heroHit  = crit || (heroRoll + _heroAtk) >= enemy.armorClass;

    if (heroHit) {
      final die = rng % 8 + 1;
      var dmg = (crit ? die * 2 : die) + _heroDmgMod;
      dmg = dmg.clamp(1, 9999);
      setState(() => _enemyHp -= dmg);
      _log.add('Roll ${heroRoll + _heroAtk} — Hit! $dmg dmg${crit ? ' (CRIT!)' : ''}.');
    } else {
      _log.add('Roll ${heroRoll + _heroAtk} vs AC ${enemy.armorClass} — Miss.');
    }

    if (_enemyHp <= 0) {
      _enemyHp = 0;
      _kills++;
      _log.add('${enemy.name.split('[').first.trim()} defeated!');
      _waveIndex++;
      if (_waveIndex >= _kGauntletEnemies) {
        _endRun(heroWon: true);
        return;
      }
      setState(() {});
      _spawnEnemy();
      return;
    }

    // Enemy attacks back
    final eRoll  = rng ~/ 100 % 20 + 1;
    final eBonus = enemy.level ~/ 2;
    final eHit   = eRoll == 20 || (eRoll + eBonus) >= _heroAc;
    if (eHit) {
      final rawDmg = enemy.attack > 0 ? rng ~/ 1000 % enemy.attack + 1 : 1;
      final dmg    = (eRoll == 20 ? rawDmg * 2 : rawDmg).clamp(1, 9999);
      setState(() => _heroHp -= dmg);
      _log.add('Enemy rolls ${eRoll + eBonus} — Hit! $dmg to you.');
      if (_heroHp <= 0) {
        _heroHp = 0;
        setState(() {});
        _endRun(heroWon: false);
        return;
      }
    } else {
      _log.add('Enemy rolls ${eRoll + eBonus} vs AC $_heroAc — Miss.');
    }
    setState(() {});
  }

  void _endRun({required bool heroWon}) {
    _autoTimer?.cancel();
    final game = GameStateProvider.of(context);

    // Score: kills × (1 + modifier count) × 100, +2000 for a clear
    final modCount = _selectedIds.length;
    final baseScore = _kills * (1 + modCount) * 100;
    final clearBonus = heroWon ? 2000 : 0;
    final score = baseScore + clearBonus;

    // Rewards: shards per kill + flat crystals for clear
    final shards = _kills * (5 + _shardBonusPerKill);
    final crystals = heroWon ? 10 + modCount * 5 : 0;

    final result = GauntletResult(
      kills:           _kills,
      totalEnemies:    _kGauntletEnemies,
      cleared:         heroWon,
      score:           score,
      shardsEarned:    shards,
      crystalsEarned:  crystals,
      modifierIds:     _selectedIds.toList(),
    );

    game.recordGauntletResult(result);

    setState(() {
      _result = result;
      _phase  = _Phase.results;
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1f3a),
        title: Text('CHALLENGE GAUNTLET',
            style: AppTheme.pixelHeading(fontSize: 12, letterSpacing: 2)),
      ),
      body: switch (_phase) {
        _Phase.pick    => _buildPickPhase(),
        _Phase.battle  => _buildBattlePhase(),
        _Phase.results => _buildResultsPhase(),
      },
    );
  }

  // ── Phase 1: Modifier Pick ────────────────────────────────────────────────

  Widget _buildPickPhase() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoBox(
          'Select up to $_kMaxModifiers modifiers. More modifiers = higher score '
          'multiplier and more rewards. Then face $_kGauntletEnemies enemies with no '
          'save points — if you die, the run ends.',
        ),
        const SizedBox(height: 16),
        Text(
          'CHOOSE MODIFIERS  (${_selectedIds.length}/$_kMaxModifiers selected)',
          style: AppTheme.pixelHeading(
              fontSize: 10, letterSpacing: 2, color: AppTheme.accentGold),
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
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _startBattle,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGold,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
            child: Text(
              'START GAUNTLET',
              style: AppTheme.pixelHeading(
                  fontSize: 12, letterSpacing: 2, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRewardPreview() {
    final modCount   = _selectedIds.length;
    final shardBonus = _selectedIds.isEmpty
        ? 0
        : _selectedIds
            .map((id) => ChallengeModifier.all
                .firstWhere((m) => m.id == id)
                .rewardShardBonus)
            .reduce((a, b) => a + b);
    final shards   = _kGauntletEnemies * (5 + shardBonus);
    final crystals = 10 + modCount * 5;
    final scoreMult = 1 + modCount;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0e1225),
        border: Border.all(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('REWARD PREVIEW (on clear)',
              style: AppTheme.pixelHeading(
                  fontSize: 9, letterSpacing: 1, color: AppTheme.textMuted)),
          const SizedBox(height: 10),
          Row(children: [
            _RewardChip('🔷 $shards shards', const Color(0xFF66aaff)),
            const SizedBox(width: 8),
            _RewardChip('💎 $crystals crystals', const Color(0xFF44ccaa)),
            const SizedBox(width: 8),
            _RewardChip('Score ×$scoreMult', AppTheme.accentGold),
          ]),
        ],
      ),
    );
  }

  // ── Phase 2: Battle ───────────────────────────────────────────────────────

  Widget _buildBattlePhase() {
    final enemy = _currentEnemy;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Progress
          Row(children: [
            Text('Wave ${_waveIndex + 1}/$_kGauntletEnemies',
                style: AppTheme.pixelHeading(fontSize: 11, color: AppTheme.accentGold)),
            const Spacer(),
            Text('Kills: $_kills',
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ]),
          const SizedBox(height: 12),
          // Hero HP
          _HpBar(
            label: 'HERO',
            current: _heroHp,
            max: _heroMaxHp,
            color: const Color(0xFF44aa66),
          ),
          const SizedBox(height: 8),
          // Enemy HP
          if (enemy != null) ...[
            _HpBar(
              label: enemy.name.split('[').first.trim().toUpperCase(),
              current: _enemyHp,
              max: _enemyMaxHp,
              color: const Color(0xFFcc4444),
            ),
          ],
          const SizedBox(height: 16),
          // Log
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF060910),
                border: Border.all(color: AppTheme.cardBorder),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListView.builder(
                reverse: true,
                itemCount: _log.length,
                itemBuilder: (context, i) {
                  final line = _log[_log.length - 1 - i];
                  return Text(
                    line,
                    style: TextStyle(
                      fontSize: 10,
                      color: line.contains('CRIT')
                          ? const Color(0xFFffdd44)
                          : line.contains('Hit!')
                              ? Colors.white70
                              : AppTheme.textMuted,
                      height: 1.5,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Phase 3: Results ──────────────────────────────────────────────────────

  Widget _buildResultsPhase() {
    final r    = _result!;
    final game = GameStateProvider.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            r.cleared ? '✦  GAUNTLET CLEARED  ✦' : '✦  RUN OVER  ✦',
            style: AppTheme.pixelHeading(
              fontSize: 16,
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
          if (r.shardsEarned > 0)
            _ResultRow('Shards Earned',   '🔷 ${r.shardsEarned}',
                color: const Color(0xFF66aaff)),
          if (r.crystalsEarned > 0)
            _ResultRow('Crystals Earned', '💎 ${r.crystalsEarned}',
                color: const Color(0xFF44ccaa)),
          const Spacer(),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() {
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
                child: Text('RUN AGAIN',
                    style: AppTheme.pixelHeading(
                        fontSize: 11, color: AppTheme.accentGold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1a1f3a),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                child: Text('DONE',
                    style: AppTheme.pixelHeading(fontSize: 11)),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

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
              fontSize: 10, color: Colors.white60, height: 1.5)),
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
                    ? const Color(0xFF0e1225)
                    : const Color(0xFF080b1a),
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
                    fontSize: 22,
                    color: enabled ? null : Colors.white24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mod.name,
                      style: TextStyle(
                        fontSize: 13,
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
                          fontSize: 10,
                          color: enabled
                              ? AppTheme.textMuted
                              : AppTheme.textMuted.withValues(alpha: 0.5),
                          height: 1.3)),
                  const SizedBox(height: 6),
                  Text('+${mod.rewardShardBonus} shards/kill',
                      style: TextStyle(
                          fontSize: 9,
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

class _HpBar extends StatelessWidget {
  const _HpBar(
      {required this.label,
      required this.current,
      required this.max,
      required this.color});
  final String label;
  final int current;
  final int max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppTheme.textMuted, letterSpacing: 1)),
        const Spacer(),
        Text('$current / $max',
            style: const TextStyle(fontSize: 10, color: Colors.white70)),
      ]),
      const SizedBox(height: 4),
      ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: pct,
          minHeight: 8,
          backgroundColor: color.withValues(alpha: 0.15),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    ]);
  }
}

class _RewardChip extends StatelessWidget {
  const _RewardChip(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.bold)),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow(this.label, this.value, {this.color});
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
        const Spacer(),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color ?? Colors.white)),
      ]),
    );
  }
}
