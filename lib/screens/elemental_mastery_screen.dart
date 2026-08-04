import 'package:flutter/material.dart';
import '../models/damage_type.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/currency_info.dart';
import '../widgets/hold_repeat_button.dart';

class ElementalMasteryScreen extends StatelessWidget {
  const ElementalMasteryScreen({super.key, this.embedded = false});

  final bool embedded;

  static const _accent = Color(0xFFff8844);

  Widget _body(BuildContext context, GameState game) {
    final locked = game.hero.level < 15;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (embedded) ...[
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('ELEMENTAL MASTERY',
                style: AppTheme.pixelHeading(
                    fontSize: 11, letterSpacing: 2, color: _accent)),
            _ShardBadge(shards: game.towerShards),
          ]),
          const SizedBox(height: 8),
        ],
        _InfoBanner(locked: locked, level: game.hero.level),
        const SizedBox(height: 14),
        ...DamageType.values.map((type) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ElementCard(game: game, type: type, locked: locked),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    if (embedded) {
      return ColoredBox(color: const Color(0xFF1B1A17), child: _body(context, game));
    }
    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1030),
        title: Text('ELEMENTAL MASTERY',
            style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 2, color: _accent)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            child: _ShardBadge(shards: game.towerShards),
          ),
        ],
      ),
      body: _body(context, game),
    );
  }
}

class _ShardBadge extends StatelessWidget {
  const _ShardBadge({required this.shards});
  final int shards;

  @override
  Widget build(BuildContext context) {
    return InfoTip(
      message: CurrencyInfo.towerShards,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF001133).withValues(alpha: 0.5),
          border: Border.all(color: const Color(0xFF66aaff).withValues(alpha: 0.7)),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Text('🔮', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text('$shards Shards',
              style: AppTheme.pixelHeading(fontSize: 11, color: const Color(0xFF88ccff))),
        ]),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.locked, required this.level});
  final bool locked;
  final int level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF221100).withValues(alpha: 0.6),
        border: Border.all(color: const Color(0xFFff8844).withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: locked
          ? Text(
              'Elemental Mastery unlocks at hero level 15.  (Current: $level)',
              style: const TextStyle(color: Color(0xFF886644), fontSize: 13),
            )
          : const Text(
              'Each rank adds +3% elemental damage and +2% resistance for that element.\n'
              'Cost: Gold + Tower Shards 🔮 (earned by completing Tower Ascension runs).',
              style: TextStyle(color: Color(0xFFbbaa99), fontSize: 13, height: 1.5),
            ),
    );
  }
}

class _ElementCard extends StatelessWidget {
  const _ElementCard({required this.game, required this.type, required this.locked});
  final GameState game;
  final DamageType type;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final rank       = game.elementalMasteryRank(type.name);
    final goldCost   = game.elementalMasteryGoldCost(type.name);
    final shardCost  = game.elementalMasteryShardCost(type.name);
    final canAfford  = game.gold >= goldCost && game.towerShards >= shardCost && !locked;
    final dmgPct     = game.elementalMasteryDamagePct(type);
    final resPct     = game.elementalMasteryResistancePct(type);

    final costColor = locked
        ? const Color(0xFF664433)
        : canAfford
            ? const Color(0xFFffcc88)
            : const Color(0xFF886655);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: type.color.withValues(alpha: 0.05),
        border: Border.all(color: type.color.withValues(alpha: locked ? 0.2 : 0.45)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(children: [
        Text(type.emoji, style: const TextStyle(fontSize: 26)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(type.label.toUpperCase(),
                  style: AppTheme.pixelHeading(
                      fontSize: 12, letterSpacing: 1, color: type.color)),
              const SizedBox(width: 8),
              Text('Rank $rank',
                  style: TextStyle(
                      color: type.color.withValues(alpha: 0.7), fontSize: 12)),
            ]),
            const SizedBox(height: 4),
            Text(
              '+$dmgPct% ${type.label} damage  •  +$resPct% resistance',
              style: const TextStyle(color: Color(0xFFbbaa99), fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              'Next: +${dmgPct + 3}% dmg / +${resPct + 2}% res  •  💰 ${_fmtGold(goldCost)}  🔮 $shardCost',
              style: TextStyle(color: costColor, fontSize: 11),
            ),
          ]),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 64,
          height: 48,
          child: HoldRepeatButton(
            onPressed: locked || !canAfford
                ? null
                : () { game.upgradeElementalMastery(type.name); game.audioService.playClaim(); },
            child: Container(
              decoration: BoxDecoration(
                color: canAfford ? type.color.withValues(alpha: 0.25) : const Color(0xFF2a2016),
                border: Border.all(
                    color: canAfford ? type.color.withValues(alpha: 0.6) : const Color(0xFF443322)),
                borderRadius: BorderRadius.circular(3),
              ),
              alignment: Alignment.center,
              child: Text('UP',
                  style: AppTheme.pixelHeading(
                      fontSize: 11,
                      color: canAfford ? type.color : const Color(0xFF665544))),
            ),
          ),
        ),
      ]),
    );
  }

  String _fmtGold(int g) {
    if (g >= 1000000) return '${(g / 1000000).toStringAsFixed(1)}M';
    if (g >= 1000)    return '${(g / 1000).toStringAsFixed(1)}K';
    return '$g';
  }
}
