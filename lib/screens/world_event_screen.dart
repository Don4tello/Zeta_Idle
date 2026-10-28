import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/routing/app_router.dart';
import '../models/world_event.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/battle_sprites.dart';

class WorldEventScreen extends StatelessWidget {
  const WorldEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game  = GameStateProvider.of(context);
    final event = WorldEventDef.forWeek();

    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('WORLD EVENT',
            style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: _TokenBadge(tokens: game.eventTokens, color: event.color),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _EventBanner(event: event),
          const SizedBox(height: 16),
          _WeekTimer(),
          const SizedBox(height: 16),
          _HowToEarn(event: event),
          const SizedBox(height: 16),
          _EventBossCard(event: event, game: game),
          const SizedBox(height: 16),
          Text('OMEGA SHOP',
              style: AppTheme.pixelHeading(
                  fontSize: 11, letterSpacing: 2, color: event.color)),
          const SizedBox(height: 10),
          ...WorldEventReward.eventShop(game.hero.level).map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RewardCard(
                  reward: r,
                  color: event.color,
                  tokens: game.eventTokens,
                  claimed: game.eventRewardClaimed(r.id),
                  onBuy: () {
                    final ok = game.buyEventReward(r.id);
                    if (ok && context.mounted) {
                      final msg = r.type == EventRewardType.gear
                          ? '${r.name} forged at Lv${game.hero.level}! Check your bag.'
                          : '${r.name} claimed!';
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(msg),
                        duration: const Duration(seconds: 3),
                      ));
                    }
                  },
                ),
              )),
        ],
      ),
    );
  }
}

class _TokenBadge extends StatelessWidget {
  const _TokenBadge({required this.tokens, required this.color});
  final int tokens;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Image.asset('assets/event_token.png', width: 16, height: 16,
            filterQuality: FilterQuality.medium),
        const SizedBox(width: 4),
        Text('$tokens',
            style: AppTheme.pixelHeading(fontSize: 12, color: color)),
      ]),
    );
  }
}

class _EventBanner extends StatelessWidget {
  const _EventBanner({required this.event});
  final WorldEventDef event;

  static Color _dmgColor(String t) => switch (t) {
    'fire'      => const Color(0xFFff6633),
    'cold'      => const Color(0xFF44bbff),
    'lightning' => const Color(0xFFffcc00),
    'poison'    => const Color(0xFF44cc44),
    'void'      => const Color(0xFFaa44ff),
    _           => const Color(0xFFaaaaaa),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: event.color.withValues(alpha: 0.06),
        border: Border.all(color: event.color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(event.icon, style: const TextStyle(fontSize: 29)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(event.name,
                  style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: event.color)),
            ),
          ]),
          const SizedBox(height: 12),
          // The hunted creature — real battle sprite so the name matches what
          // you actually fight.
          Row(children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                border: Border.all(color: event.color.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: StaticEnemySprite(spriteId: event.spriteId, size: 64),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('NOW HUNTING',
                      style: AppTheme.pixelHeading(
                          fontSize: 9,
                          letterSpacing: 1.5,
                          color: event.color.withValues(alpha: 0.7))),
                  const SizedBox(height: 3),
                  Text('${event.enemyEmoji} ${event.enemyName}',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Text(event.description,
              style: const TextStyle(
                  fontSize: 12, color: Colors.white60, height: 1.5)),
          const SizedBox(height: 8),
          Row(children: [
            const Text('Damage: ', style: TextStyle(fontSize: 10, color: Colors.white38)),
            ...event.damageTypes.map((t) => Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _dmgColor(t).withValues(alpha: 0.15),
                border: Border.all(color: _dmgColor(t).withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(t.toUpperCase(),
                  style: TextStyle(fontSize: 9, color: _dmgColor(t), fontWeight: FontWeight.bold)),
            )),
          ]),
        ],
      ),
    );
  }
}

class _WeekTimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now    = DateTime.now();
    final weekMs = 7 * 24 * 3600 * 1000;
    final elapsed = now.millisecondsSinceEpoch % weekMs;
    final remaining = Duration(milliseconds: weekMs - elapsed);
    final d = remaining.inDays;
    final h = remaining.inHours % 24;
    final m = remaining.inMinutes % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        border: Border.all(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(children: [
        const Icon(Icons.timer_outlined, size: 14, color: AppTheme.textMuted),
        const SizedBox(width: 8),
        Text('Event ends in  ${d}d ${h}h ${m}m',
            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
      ]),
    );
  }
}

class _HowToEarn extends StatelessWidget {
  const _HowToEarn({required this.event});
  final WorldEventDef event;

  @override
  Widget build(BuildContext context) {
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
          Text('HOW TO EARN TOKENS',
              style: AppTheme.pixelHeading(
                  fontSize: 10, letterSpacing: 1, color: AppTheme.textMuted)),
          const SizedBox(height: 8),
          Row(children: [
            Text(event.enemyEmoji, style: const TextStyle(fontSize: 17)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${event.enemyName}s have a 15% chance to appear during any '
                'battle. Defeat them for 1–3 Event Tokens each.',
                style: const TextStyle(
                    fontSize: 12, color: Colors.white60, height: 1.4),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _EventBossCard extends StatelessWidget {
  const _EventBossCard({required this.event, required this.game});
  final WorldEventDef event;
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final progress = game.eventBossProgress;
    final needed   = GameState.kEventBossKills;
    final ready    = game.eventBossReady;
    final frac     = (progress / needed).clamp(0.0, 1.0);
    final accent   = event.color;
    const gold     = Color(0xFFffcc44);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withValues(alpha: 0.18), const Color(0xFF17140F)],
        ),
        border: Border.all(
            color: (ready ? gold : accent).withValues(alpha: 0.6), width: 1.5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: ready
            ? [BoxShadow(color: gold.withValues(alpha: 0.25), blurRadius: 12)]
            : null,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [accent.withValues(alpha: 0.30), Colors.transparent]),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
          ),
          child: Row(children: [
            Text('⚔ EVENT BOSS',
                style: AppTheme.pixelHeading(
                    fontSize: 11, letterSpacing: 2, color: accent)),
            const Spacer(),
            Text('🏆 ${game.eventBossTokens}',
                style: AppTheme.pixelHeading(fontSize: 12, color: gold)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  border: Border.all(color: accent.withValues(alpha: 0.45)),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: StaticEnemySprite(spriteId: event.spriteId, size: 60),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('${event.enemyEmoji} ${event.enemyName} Alpha',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: frac,
                        minHeight: 8,
                        backgroundColor: Colors.white12,
                        valueColor:
                            AlwaysStoppedAnimation(ready ? gold : accent),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                        ready
                            ? 'The boss is vulnerable — strike it down!'
                            : '$progress / $needed event enemies slain',
                        style: TextStyle(
                            fontSize: 11,
                            color: ready ? gold : Colors.white54)),
                  ])),
            ]),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: ready
                    ? () {
                        game.startEventBossBattle();
                        if (game.eventBossMode && context.mounted) {
                          context.push(Routes.battle);
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      ready ? gold.withValues(alpha: 0.18) : Colors.white10,
                  foregroundColor: gold,
                  side: BorderSide(
                      color: ready ? gold : AppTheme.cardBorder),
                ),
                child: Text(ready ? '⚔ FIGHT THE BOSS' : 'BOSS WEAKENING…',
                    style: AppTheme.pixelHeading(
                        fontSize: 11,
                        color: ready ? gold : AppTheme.textMuted)),
              ),
            ),
            // Boss-token reward — ALWAYS shown (disabled until you own a token)
            // so it's clear what the 🏆 Boss Token is spent on. It's claimed
            // here, NOT in the event shop below (which uses event tokens).
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: game.eventBossTokens > 0
                    ? () {
                        final item = game.spendEventBossToken();
                        if (item != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                '🏆 Legendary ${item.name} claimed — check your bag!'),
                            duration: const Duration(seconds: 3),
                          ));
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFcc8844)
                      .withValues(alpha: game.eventBossTokens > 0 ? 0.15 : 0.05),
                  foregroundColor: const Color(0xFFffaa44),
                  disabledForegroundColor: AppTheme.textMuted,
                  side: BorderSide(
                      color: game.eventBossTokens > 0
                          ? const Color(0xFFcc8844)
                          : AppTheme.cardBorder),
                ),
                child: Text('CLAIM LEGENDARY GEAR  (1 🏆 Boss Token)',
                    style: AppTheme.pixelHeading(
                        fontSize: 11,
                        color: game.eventBossTokens > 0
                            ? const Color(0xFFffaa44)
                            : AppTheme.textMuted)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              game.eventBossTokens > 0
                  ? 'You have ${game.eventBossTokens} Boss Token${game.eventBossTokens == 1 ? '' : 's'} 🏆 — redeem above for guaranteed Legendary gear.'
                  : 'Beat the Event Boss to earn a 🏆 Boss Token, then redeem it here for guaranteed Legendary gear. (The shop below uses event tokens — a separate currency.)',
              style: const TextStyle(fontSize: 10, color: Color(0xFF9a8f7a), height: 1.3),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.reward,
    required this.color,
    required this.tokens,
    required this.claimed,
    required this.onBuy,
  });
  final WorldEventReward reward;
  final Color color;
  final int tokens;
  final bool claimed;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final canAfford = tokens >= reward.tokenCost && !claimed;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: claimed
            ? const Color(0xFF0e1f0e)
            : const Color(0xFF231F1B),
        border: Border.all(
          color: claimed
              ? const Color(0xFF44aa44).withValues(alpha: 0.4)
              : canAfford
                  ? color.withValues(alpha: 0.6)
                  : AppTheme.cardBorder,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(children: [
        Text(reward.icon, style: const TextStyle(fontSize: 23)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(reward.name,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
              Text(reward.description,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textMuted)),
            ],
          ),
        ),
        if (claimed)
          const Icon(Icons.check_circle, color: Color(0xFF44aa44), size: 20)
        else ...[
          Image.asset('assets/event_token.png', width: 15, height: 15,
              filterQuality: FilterQuality.medium),
          const SizedBox(width: 3),
          Text('${reward.tokenCost}',
              style: TextStyle(
                  fontSize: 13,
                  color: canAfford ? color : AppTheme.textMuted,
                  fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          TextButton(
            onPressed: canAfford ? onBuy : null,
            style: TextButton.styleFrom(
              foregroundColor: color,
              disabledForegroundColor: AppTheme.cardBorder,
              side: BorderSide(
                  color: canAfford ? color : AppTheme.cardBorder),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text('BUY',
                style: AppTheme.pixelHeading(
                    fontSize: 11,
                    color: canAfford ? color : AppTheme.cardBorder)),
          ),
        ],
      ]),
    );
  }
}
