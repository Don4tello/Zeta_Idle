import 'package:flutter/material.dart';
import '../models/daily_challenge.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/section_card.dart';

class DailyScreen extends StatelessWidget {
  const DailyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final now  = DateTime.now();
    final resetHour = 24 - now.hour;
    final claimed   = game.dailyChallenges.where((c) => c.claimed).length;
    final total     = game.dailyChallenges.length;

    return Scaffold(
      backgroundColor: const Color(0xFF0a0e27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1f3a),
        title: Text('DAILY CHALLENGES',
            style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 2)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 13, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Text('~$resetHour h',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _OverallProgress(claimed: claimed, total: total),
            const SizedBox(height: 14),
            _DailyChestCard(game: game, claimed: claimed, total: total),
            const SizedBox(height: 14),
            ...game.dailyChallenges.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ChallengeCard(
                challenge: e.value,
                progress:  game.getDailyProgress(e.value.type),
                taskNumber: e.key + 1,
                onClaim:   () => game.claimDailyChallenge(e.key),
              ),
            )),
            const SizedBox(height: 8),
            SectionCard(
              title: 'How It Works',
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HintRow('Kill enemies',  'Fight in Campaign or Endless mode'),
                  _HintRow('Win battles',   'Defeating an enemy counts as a win'),
                  _HintRow('Defeat boss',   'Stage 5, 10, 15, 20, 25 or Endless every 5th'),
                  _HintRow('Use abilities', 'Active abilities fire automatically in battle'),
                  _HintRow('Equip item',    'Tap a bag item → Equip in Inventory'),
                  _HintRow('Reach gold',    'Just have that much gold in your stash'),
                  _HintRow('Deal damage',   'Cumulative damage dealt in any mode'),
                  _HintRow('Collect idle',  'Tap the idle reward on the home screen'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Overall progress bar ─────────────────────────────────────────────────────

class _OverallProgress extends StatelessWidget {
  const _OverallProgress({required this.claimed, required this.total});
  final int claimed, total;

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? claimed / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('TODAY\'S PROGRESS',
                style: AppTheme.pixelHeading(
                    fontSize: 9, color: AppTheme.textMuted, letterSpacing: 2)),
            Text('$claimed / $total',
                style: AppTheme.pixelHeading(
                    fontSize: 11,
                    color: claimed == total
                        ? AppTheme.accentGold
                        : AppTheme.textMuted)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 7,
            backgroundColor: AppTheme.cardBorder,
            valueColor: AlwaysStoppedAnimation<Color>(
              claimed == total
                  ? AppTheme.accentGold
                  : const Color(0xFF4488ff),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Daily chest card ─────────────────────────────────────────────────────────

class _DailyChestCard extends StatelessWidget {
  const _DailyChestCard({
    required this.game,
    required this.claimed,
    required this.total,
  });
  final GameState game;
  final int claimed, total;

  @override
  Widget build(BuildContext context) {
    final ready    = game.dailyChestAvailable;
    final allDone  = claimed == total;
    final gotChest = game.dailyChestClaimed;

    final borderColor = gotChest
        ? AppTheme.cardBorder
        : ready
            ? AppTheme.accentGold
            : AppTheme.cardBorder.withValues(alpha: 0.6);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0e1225),
        border: Border.all(color: borderColor, width: ready ? 1.5 : 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Text(
            gotChest ? '📦' : allDone ? '🎁' : '🔒',
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DAILY CHEST',
                  style: AppTheme.pixelHeading(
                      fontSize: 12,
                      color: gotChest
                          ? AppTheme.textMuted
                          : ready
                              ? AppTheme.accentGold
                              : Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  gotChest
                      ? 'Claimed! Come back tomorrow.'
                      : 'Complete all 7 tasks to unlock.',
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: const [
                    _RewardChip('💰 1000',  Color(0xFFccaa22)),
                    _RewardChip('◆ 75',     Color(0xFF88aaff)),
                    _RewardChip('✦ 50',     Color(0xFF88cc44)),
                    _RewardChip('💎 50',    Color(0xFF44ddcc)),
                  ],
                ),
              ],
            ),
          ),
          if (ready)
            GestureDetector(
              onTap: () => game.claimDailyChest(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.15),
                  border: Border.all(color: AppTheme.accentGold),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text('CLAIM',
                    style: AppTheme.pixelHeading(
                        fontSize: 11, color: AppTheme.accentGold)),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Individual challenge card ────────────────────────────────────────────────

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({
    required this.challenge,
    required this.progress,
    required this.taskNumber,
    required this.onClaim,
  });

  final DailyChallenge challenge;
  final int progress;
  final int taskNumber;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final isComplete = progress >= challenge.target;
    final pct        = (progress / challenge.target).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0e1225),
        border: Border.all(
          color: challenge.claimed
              ? AppTheme.cardBorder
              : isComplete
                  ? AppTheme.accentGold
                  : AppTheme.cardBorder,
          width: isComplete && !challenge.claimed ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: challenge.claimed
                      ? AppTheme.cardBorder.withValues(alpha: 0.3)
                      : isComplete
                          ? AppTheme.accentGold.withValues(alpha: 0.2)
                          : const Color(0xFF1a1f3a),
                  border: Border.all(
                    color: challenge.claimed
                        ? AppTheme.cardBorder
                        : isComplete
                            ? AppTheme.accentGold
                            : AppTheme.textMuted.withValues(alpha: 0.4),
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: challenge.claimed
                    ? const Icon(Icons.check, size: 14,
                        color: Color(0xFF55cc55))
                    : Text('$taskNumber',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isComplete
                                ? AppTheme.accentGold
                                : AppTheme.textMuted)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  challenge.title,
                  style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 0.5),
                ),
              ),
              if (isComplete && !challenge.claimed)
                Text('READY',
                    style: AppTheme.pixelHeading(
                        fontSize: 9,
                        color: AppTheme.accentGold,
                        letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 8),
          Text(challenge.description,
              style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${progress.clamp(0, challenge.target)} / ${challenge.target}',
                      style: TextStyle(
                          fontSize: 11,
                          color: isComplete
                              ? AppTheme.accentGold
                              : AppTheme.textMuted),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        backgroundColor: AppTheme.cardBorder,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          challenge.claimed
                              ? AppTheme.cardBorder
                              : isComplete
                                  ? AppTheme.accentGold
                                  : const Color(0xFF4488ff),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _RewardChip('💰 ${challenge.rewardGold}',   const Color(0xFFccaa22)),
              const SizedBox(width: 6),
              _RewardChip('◆ ${challenge.rewardShards}',  const Color(0xFF88aaff)),
              const SizedBox(width: 6),
              _RewardChip('✦ ${challenge.rewardEssence}', const Color(0xFF88cc44)),
              const Spacer(),
              if (!challenge.claimed)
                TextButton(
                  onPressed: isComplete ? onClaim : null,
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.accentGold,
                    disabledForegroundColor: AppTheme.cardBorder,
                    side: BorderSide(
                        color: isComplete
                            ? AppTheme.accentGold
                            : AppTheme.cardBorder),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('CLAIM',
                      style: AppTheme.pixelHeading(
                          fontSize: 10,
                          color: isComplete
                              ? AppTheme.accentGold
                              : AppTheme.cardBorder,
                          letterSpacing: 1)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  const _RewardChip(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, color: color)),
    );
  }
}

class _HintRow extends StatelessWidget {
  const _HintRow(this.label, this.text);
  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: AppTheme.pixelHeading(
                    fontSize: 10,
                    color: AppTheme.accentGold,
                    letterSpacing: 0)),
          ),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 10, color: AppTheme.textMuted))),
        ],
      ),
    );
  }
}
