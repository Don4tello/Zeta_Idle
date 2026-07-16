import 'package:flutter/material.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/hold_repeat_button.dart';

class AbilityScoresScreen extends StatelessWidget {
  const AbilityScoresScreen({super.key, this.embedded = false});

  final bool embedded;

  static const _accent = Color(0xFF66ccff);

  static const _stats = [
    _StatDef('pwr',  'PWR', '⚔', Color(0xFFff6644), 'Power',
        '+2 flat attack damage per rank'),
    _StatDef('agi',  'AGI', '💨', Color(0xFFffee44), 'Agility',
        '+2% critical hit damage per rank'),
    _StatDef('vit',  'VIT', '❤', Color(0xFF44ee66), 'Vitality',
        '+30 max HP per rank'),
    _StatDef('prc',  'PRC', '🎯', Color(0xFFffaa22), 'Precision',
        '+1% critical hit chance per rank'),
    _StatDef('for_', 'FOR', '🛡', Color(0xFF66aaff), 'Fortitude',
        '+1 armor class per 2 ranks'),
    _StatDef('lck',  'LCK', '🍀', Color(0xFF88ff88), 'Luck',
        '+1% gold income per rank'),
  ];

  Widget _body(GameState game) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (embedded) ...[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('ABILITY SCORES',
                  style: AppTheme.pixelHeading(
                      fontSize: 11, letterSpacing: 2, color: _accent)),
              _GoldBadge(gold: game.gold),
            ]),
            const SizedBox(height: 8),
          ],
          _InfoBanner(),
          const SizedBox(height: 14),
          ..._stats.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _StatCard(game: game, stat: s),
              )),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    if (embedded) {
      return ColoredBox(color: const Color(0xFF1B1A17), child: _body(game));
    }
    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1030),
        title: Text('ABILITY SCORES',
            style:
                AppTheme.pixelHeading(fontSize: 13, letterSpacing: 2, color: _accent)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: _GoldBadge(gold: GameStateProvider.of(context).gold),
          ),
        ],
      ),
      body: _body(game),
    );
  }
}

class _StatDef {
  const _StatDef(this.key, this.abbrev, this.emoji, this.color, this.name, this.desc);
  final String key;
  final String abbrev;
  final String emoji;
  final Color color;
  final String name;
  final String desc;
}

class _GoldBadge extends StatelessWidget {
  const _GoldBadge({required this.gold});
  final int gold;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF221100).withValues(alpha: 0.5),
        border: Border.all(color: const Color(0xFFffcc44).withValues(alpha: 0.7)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Text('💰', style: TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text('$gold',
            style: AppTheme.pixelHeading(fontSize: 11, color: const Color(0xFFffcc44))),
      ]),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF001122).withValues(alpha: 0.6),
        border: Border.all(color: const Color(0xFF66ccff).withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'Ability Scores are permanent upgrades purchased with gold.\n'
        'They directly enhance your hero\'s combat statistics.',
        style: TextStyle(color: Color(0xFFbbccdd), fontSize: 13, height: 1.5),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.game, required this.stat});
  final GameState game;
  final _StatDef stat;

  String _currentValue(GameState g) {
    final rank = g.abilityScoreRank(stat.key);
    return switch (stat.key) {
      'pwr'  => '+${rank * 2} dmg',
      'agi'  => '+${rank * 2}% crit dmg',
      'vit'  => '+${rank * 30} HP',
      'prc'  => '+$rank% crit',
      'for_' => '+${rank ~/ 2} AC',
      'lck'  => '+$rank% gold',
      _      => 'Rank $rank',
    };
  }

  @override
  Widget build(BuildContext context) {
    final rank = game.abilityScoreRank(stat.key);
    final cost = game.abilityScoreUpgradeCost(stat.key);
    final canAfford = game.gold >= cost;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: stat.color.withValues(alpha: 0.04),
        border: Border.all(color: stat.color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(children: [
        Text(stat.emoji, style: const TextStyle(fontSize: 26)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(stat.abbrev,
                  style: AppTheme.pixelHeading(
                      fontSize: 13, letterSpacing: 1, color: stat.color)),
              const SizedBox(width: 6),
              Text(stat.name,
                  style: TextStyle(
                      color: stat.color.withValues(alpha: 0.7), fontSize: 12)),
              const Spacer(),
              Text('Rank $rank',
                  style: TextStyle(
                      color: stat.color.withValues(alpha: 0.6), fontSize: 11)),
            ]),
            const SizedBox(height: 3),
            Text(stat.desc,
                style: const TextStyle(color: Color(0xFFbbaa99), fontSize: 12)),
            const SizedBox(height: 3),
            Row(children: [
              Text(_currentValue(game),
                  style: TextStyle(
                      color: stat.color, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text('Next: $cost 💰',
                  style: TextStyle(
                      color: canAfford
                          ? const Color(0xFFffcc88)
                          : const Color(0xFF886655),
                      fontSize: 11)),
            ]),
          ]),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 64,
          height: 48,
          child: HoldRepeatButton(
            onPressed: canAfford ? () { game.upgradeAbilityScore(stat.key); game.audioService.playUiConfirm(); } : null,
            child: Container(
              decoration: BoxDecoration(
                color: canAfford ? stat.color.withValues(alpha: 0.2) : const Color(0xFF1a1a1a),
                border: Border.all(
                    color: canAfford ? stat.color.withValues(alpha: 0.6) : const Color(0xFF332211)),
                borderRadius: BorderRadius.circular(3),
              ),
              alignment: Alignment.center,
              child: Text('UP',
                  style: AppTheme.pixelHeading(
                      fontSize: 11,
                      color: canAfford ? stat.color : const Color(0xFF554433))),
            ),
          ),
        ),
      ]),
    );
  }
}
