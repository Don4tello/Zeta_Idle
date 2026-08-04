import 'package:flutter/material.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/hold_repeat_button.dart';

class AbilityScoresScreen extends StatelessWidget {
  const AbilityScoresScreen({super.key, this.embedded = false});

  final bool embedded;

  static const _accent = Color(0xFF66ccff);

  static const _stats = [
    _StatDef('pwr',  'PWR', Icons.bolt,           Color(0xFFff6644), 'Power',
        '+2 flat attack damage per rank'),
    _StatDef('agi',  'AGI', Icons.speed,           Color(0xFFffee44), 'Agility',
        '+2% critical hit damage per rank'),
    _StatDef('vit',  'VIT', Icons.favorite,        Color(0xFF44ee66), 'Vitality',
        '+30 max HP per rank'),
    _StatDef('prc',  'PRC', Icons.gps_fixed,       Color(0xFFffaa22), 'Precision',
        '+1% critical hit chance per rank'),
    _StatDef('for_', 'FOR', Icons.shield,          Color(0xFF66aaff), 'Fortitude',
        '+1 armor class per 2 ranks'),
    _StatDef('lck',  'LCK', Icons.auto_awesome,    Color(0xFF88ff88), 'Luck',
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
  const _StatDef(this.key, this.abbrev, this.icon, this.color, this.name, this.desc);
  final String   key;
  final String   abbrev;
  final IconData icon;
  final Color    color;
  final String   name;
  final String   desc;
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
        const Icon(Icons.monetization_on, size: 13, color: Color(0xFFffcc44)),
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
        'Upgrade any score freely — gold is the only requirement.',
        style: TextStyle(color: Color(0xFFbbccdd), fontSize: 13, height: 1.5),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.game, required this.stat});
  final GameState game;
  final _StatDef  stat;

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
    final rank            = game.abilityScoreRank(stat.key);
    final cost            = game.abilityScoreUpgradeCost(stat.key);
    final atCap           = rank >= GameState.kAbilityScoreMaxRank;
    final rebirthNeeded   = rank ~/ 10;
    final gateMet         = rank >= 0; // Rebirth gate removed — always met.
    final canAfford       = game.gold >= cost;
    final canUpgrade      = !atCap && gateMet && canAfford;
    final tierLabel       = 'Tier ${rebirthNeeded + 1}';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: stat.color.withValues(alpha: gateMet ? 0.04 : 0.02),
        border: Border.all(
            color: stat.color.withValues(alpha: gateMet ? 0.35 : 0.15)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(children: [
        Icon(stat.icon, size: 28, color: stat.color.withValues(alpha: gateMet ? 1.0 : 0.4)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(stat.abbrev,
                  style: AppTheme.pixelHeading(
                      fontSize: 13, letterSpacing: 1,
                      color: stat.color.withValues(alpha: gateMet ? 1.0 : 0.4))),
              const SizedBox(width: 6),
              Text(stat.name,
                  style: TextStyle(
                      color: stat.color.withValues(alpha: gateMet ? 0.7 : 0.3),
                      fontSize: 12)),
              const Spacer(),
              Text(atCap ? 'MAX' : 'Rank $rank / 1000',
                  style: TextStyle(
                      color: atCap
                          ? const Color(0xFFffdd44)
                          : stat.color.withValues(alpha: 0.6),
                      fontSize: 11,
                      fontWeight: atCap ? FontWeight.bold : FontWeight.normal)),
            ]),
            const SizedBox(height: 3),
            Text(stat.desc,
                style: TextStyle(
                    color: const Color(0xFFbbaa99).withValues(alpha: gateMet ? 1.0 : 0.5),
                    fontSize: 12)),
            const SizedBox(height: 4),
            Row(children: [
              Text(_currentValue(game),
                  style: TextStyle(
                      color: stat.color.withValues(alpha: gateMet ? 1.0 : 0.4),
                      fontSize: 12, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (atCap)
                _TierChip(label: 'MAXED', color: const Color(0xFFffdd44))
              else if (!gateMet)
                _TierChip(
                  label: '$tierLabel  •  Rebirth $rebirthNeeded required',
                  color: const Color(0xFFff6644),
                  icon: Icons.lock_outline,
                )
              else
                _TierChip(label: '$tierLabel  •  ${rank % 10}/10', color: stat.color),
            ]),
            if (!atCap && gateMet) ...[
              const SizedBox(height: 4),
              Text('Next: ${cost.toString()} gold',
                  style: TextStyle(
                      color: canAfford
                          ? const Color(0xFFffcc88)
                          : const Color(0xFF886655),
                      fontSize: 11)),
            ],
          ]),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 64,
          height: 52,
          child: HoldRepeatButton(
            onPressed: canUpgrade
                ? () { game.upgradeAbilityScore(stat.key); game.audioService.playClaim(); }
                : null,
            child: Container(
              decoration: BoxDecoration(
                color: atCap
                    ? const Color(0xFF1a1a1a)
                    : !gateMet
                        ? const Color(0xFF1a1010)
                        : canAfford
                            ? stat.color.withValues(alpha: 0.2)
                            : const Color(0xFF1a1a1a),
                border: Border.all(
                    color: atCap
                        ? const Color(0xFF554400)
                        : !gateMet
                            ? const Color(0xFF553322)
                            : canAfford
                                ? stat.color.withValues(alpha: 0.6)
                                : const Color(0xFF332211)),
                borderRadius: BorderRadius.circular(3),
              ),
              alignment: Alignment.center,
              child: atCap
                  ? const Icon(Icons.check, size: 18, color: Color(0xFF554400))
                  : !gateMet
                      ? const Icon(Icons.lock, size: 18, color: Color(0xFF885544))
                      : Text('UP',
                          style: AppTheme.pixelHeading(
                              fontSize: 11,
                              color: canAfford
                                  ? stat.color
                                  : const Color(0xFF554433))),
            ),
          ),
        ),
      ]),
    );
  }
}

class _TierChip extends StatelessWidget {
  const _TierChip({required this.label, required this.color, this.icon});
  final String   label;
  final Color    color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[
          Icon(icon, size: 10, color: color.withValues(alpha: 0.8)),
          const SizedBox(width: 3),
        ],
        Text(label,
            style: TextStyle(
                color: color.withValues(alpha: 0.9),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5)),
      ]),
    );
  }
}
