import 'package:flutter/material.dart';
import '../models/challenge_modifier.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

class ChallengeModifiersScreen extends StatelessWidget {
  const ChallengeModifiersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('CHALLENGE MODIFIERS',
            style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 2)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF231F1B),
              border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('OPTIONAL HANDICAPS',
                  style: AppTheme.pixelHeading(
                      fontSize: 12, color: AppTheme.accentGold, letterSpacing: 2)),
              const SizedBox(height: 6),
              Text(
                'Enable up to one modifier before entering Campaign or Dungeon. '
                'Modifiers make battles harder but increase shard rewards per kill.',
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.4),
              ),
              const SizedBox(height: 8),
              if (game.activeModifierId != null) ...[
                const Divider(color: AppTheme.cardBorder, height: 1),
                const SizedBox(height: 8),
                Row(children: [
                  const Text('Active: ',
                      style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                  Text(
                    ChallengeModifier.all
                        .firstWhere((m) => m.id == game.activeModifierId).name,
                    style: AppTheme.pixelHeading(
                        fontSize: 11, color: AppTheme.accentGold),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => game.setActiveModifier(null),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.accentRed.withValues(alpha: 0.6)),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text('CLEAR',
                          style: AppTheme.pixelHeading(
                              fontSize: 10, color: AppTheme.accentRed)),
                    ),
                  ),
                ]),
              ],
            ]),
          ),
          ...ChallengeModifier.all.map((mod) => _ModifierCard(mod: mod, game: game)),
        ],
      ),
    );
  }
}

class _ModifierCard extends StatelessWidget {
  const _ModifierCard({required this.mod, required this.game});
  final ChallengeModifier mod;
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final active = game.activeModifierId == mod.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => game.setActiveModifier(active ? null : mod.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: active
                ? AppTheme.accentGold.withValues(alpha: 0.06)
                : const Color(0xFF231F1B),
            border: Border.all(
              color: active ? AppTheme.accentGold : AppTheme.cardBorder,
              width: active ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(children: [
            Text(mod.icon, style: const TextStyle(fontSize: 27)),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mod.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: active ? AppTheme.accentGold : Colors.white,
                    )),
                const SizedBox(height: 4),
                Text(mod.description,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textMuted, height: 1.3)),
                const SizedBox(height: 8),
                Row(children: [
                  _StatBadge('+${mod.rewardShardBonus} shards/kill',
                      const Color(0xFF66aaff)),
                  if (mod.enemyHpMult > 1)
                    _StatBadge(
                        'Enemy HP ×${mod.enemyHpMult.toStringAsFixed(2)}',
                        const Color(0xFFff6644)),
                  if (mod.enemyAtkMult > 1)
                    _StatBadge(
                        'Enemy ATK ×${mod.enemyAtkMult.toStringAsFixed(2)}',
                        const Color(0xFFff4444)),
                  if (mod.heroHpMult < 1)
                    _StatBadge(
                        'Hero HP ×${mod.heroHpMult.toStringAsFixed(1)}',
                        const Color(0xFFff9900)),
                ]),
              ],
            )),
            if (active)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.check_circle, color: AppTheme.accentGold, size: 22),
              ),
          ]),
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
    );
  }
}
