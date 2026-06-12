import 'package:flutter/material.dart';
import '../models/world_event.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

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
          Text('EVENT SHOP',
              style: AppTheme.pixelHeading(
                  fontSize: 11, letterSpacing: 2, color: event.color)),
          const SizedBox(height: 10),
          ...event.rewards.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RewardCard(
                  reward: r,
                  color: event.color,
                  tokens: game.eventTokens,
                  claimed: game.eventRewardClaimed(r.id),
                  onBuy: () => game.buyEventReward(r.id),
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
        const Text('🪙', style: TextStyle(fontSize: 11)),
        const SizedBox(width: 4),
        Text('$tokens tokens',
            style: AppTheme.pixelHeading(fontSize: 12, color: color)),
      ]),
    );
  }
}

class _EventBanner extends StatelessWidget {
  const _EventBanner({required this.event});
  final WorldEventDef event;

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
          const SizedBox(height: 10),
          Text(event.description,
              style: const TextStyle(
                  fontSize: 12, color: Colors.white60, height: 1.5)),
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
          Text('🪙${reward.tokenCost}',
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
