import 'package:flutter/material.dart';
import '../models/daily_challenge.dart';
import '../models/weekly_challenge.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/section_card.dart';
import '../widgets/zcoin_icon.dart';
import 'main_shell.dart' show TutorialTip;
import 'bounty_board_screen.dart' show BountyBoardBody;

class DailyScreen extends StatelessWidget {
  const DailyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF1B1A17),
        appBar: AppBar(
          backgroundColor: const Color(0xFF2A2623),
          title: Text('CHALLENGES',
              style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
          bottom: const TabBar(
            indicatorColor: AppTheme.accentGold,
            labelColor: AppTheme.accentGold,
            unselectedLabelColor: AppTheme.textMuted,
            labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            tabs: [
              Tab(text: 'DAILY'),
              Tab(text: 'WEEKLY'),
              Tab(text: 'BOUNTIES'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _DailyTab(),
            _WeeklyTab(),
            BountyBoardBody(),
          ],
        ),
      ),
    );
  }
}

// ─── Daily tab ────────────────────────────────────────────────────────────────

class _DailyTab extends StatelessWidget {
  const _DailyTab();

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final now  = DateTime.now();
    final resetHour = 24 - now.hour;
    final claimed   = game.dailyChallenges.where((c) => c.claimed).length;
    final total     = game.dailyChallenges.length;

    return RefreshIndicator(
      color: AppTheme.accentGold,
      backgroundColor: const Color(0xFF2A2623),
      onRefresh: () async {
        game.refreshDaily();
        await Future.delayed(const Duration(milliseconds: 400));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TutorialTip(
              tutorialKey: 'daily',
              game: game,
              text: 'Complete daily challenges to earn gold, shards, essence, and ZCoins. '
                  'All 7 challenges reset each day. Complete them all for a bonus chest!',
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.access_time, size: 13, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Text('~$resetHour h',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                const SizedBox(width: 10),
                if (game.hasClaimableDaily)
                  GestureDetector(
                    onTap: () { game.claimAllDailies(); game.audioService.playClaimAll(); },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1a3020),
                        border: Border.all(color: const Color(0xFF55cc88)),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text('CLAIM ALL',
                          style: AppTheme.pixelHeading(fontSize: 9, color: const Color(0xFF55cc88))),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            _OverallProgress(claimed: claimed, total: total),
            const SizedBox(height: 14),
            _DailyChestCard(game: game, claimed: claimed, total: total),
            const SizedBox(height: 14),
            ...game.dailyChallenges.asMap().entries
                .where((e) => !e.value.claimed)
                .map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ChallengeCard(
                challenge: e.value,
                progress:  game.getDailyProgress(e.value.type),
                taskNumber: e.key + 1,
                onClaim:   () { game.claimDailyChallenge(e.key); game.audioService.playClaim(); },
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

// ─── Weekly tab ───────────────────────────────────────────────────────────────

class _WeeklyTab extends StatelessWidget {
  const _WeeklyTab();

  String _timeUntilWeeklyReset() {
    final now = DateTime.now();
    final nextMonday = now.add(Duration(days: (DateTime.monday - now.weekday + 7) % 7 == 0 ? 7 : (DateTime.monday - now.weekday + 7) % 7));
    final reset = DateTime(nextMonday.year, nextMonday.month, nextMonday.day);
    final rem = reset.difference(now);
    if (rem.inDays >= 2) return '${rem.inDays}d';
    if (rem.inHours >= 1) return '${rem.inHours}h ${rem.inMinutes.remainder(60)}m';
    return '${rem.inMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final challenges = game.weeklyChallenges;
    final claimed = challenges.where((c) => c.claimed).length;
    final total   = challenges.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("THIS WEEK'S CHALLENGES",
                    style: AppTheme.pixelHeading(
                        fontSize: 10, color: AppTheme.textMuted, letterSpacing: 1.5)),
                const SizedBox(height: 4),
                Text('$claimed / $total completed',
                    style: TextStyle(
                        fontSize: 12,
                        color: claimed == total ? AppTheme.accentGold : AppTheme.textMuted)),
              ]),
              Row(children: [
                if (game.hasClaimableWeekly) ...[
                  GestureDetector(
                    onTap: () { game.claimAllWeeklies(); game.audioService.playClaimAll(); },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1a2a1a),
                        border: Border.all(color: const Color(0xFFcc7722)),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text('CLAIM ALL',
                          style: AppTheme.pixelHeading(fontSize: 9, color: const Color(0xFFcc7722))),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                const Icon(Icons.access_time, size: 13, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Text(_timeUntilWeeklyReset(),
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              ]),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: total > 0 ? claimed / total : 0.0,
              minHeight: 7,
              backgroundColor: AppTheme.cardBorder,
              valueColor: AlwaysStoppedAnimation<Color>(
                claimed == total ? AppTheme.accentGold : const Color(0xFFcc7722),
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (challenges.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text('Weekly challenges loading...',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
              ),
            )
          else
            ...challenges.asMap().entries.map((e) {
              final c = e.value;
              final progress = game.getWeeklyProgress(c);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _WeeklyChallengeCard(
                  challenge: c,
                  progress: progress,
                  index: e.key + 1,
                  onClaim: () => game.claimWeekly(c.id),
                ),
              );
            }),
          const SizedBox(height: 8),
          SectionCard(
            title: 'About Weekly Challenges',
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HintRow('Resets',   'Every Monday — 5 new challenges each week'),
                _HintRow('Rewards',  'Larger than daily: essence, mythril, ZCoins'),
                _HintRow('Season XP','+50 season XP per claimed weekly challenge'),
                _HintRow('Progress', 'Counts from Monday midnight, not from claim'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Weekly challenge card ────────────────────────────────────────────────────

class _WeeklyChallengeCard extends StatelessWidget {
  const _WeeklyChallengeCard({
    required this.challenge,
    required this.progress,
    required this.index,
    required this.onClaim,
  });

  final WeeklyChallenge challenge;
  final int progress;
  final int index;
  final VoidCallback onClaim;

  static const _amber = Color(0xFFcc7722);

  static String _rewardIcon(String key) => switch (key) {
    'gold'      => '💰',
    'shards'    => '◆',
    'essence'   => '✦',
    'mythril'   => '⬡',
    'zcoins'    => '🪙',
    'echoes'    => '🔮',
    'gemShards' => '💠',
    _           => '•',
  };

  static Color _rewardColor(String key) => switch (key) {
    'gold'      => const Color(0xFFccaa22),
    'shards'    => const Color(0xFF88aaff),
    'essence'   => const Color(0xFF88cc44),
    'mythril'   => const Color(0xFF8888ff),
    'zcoins'    => const Color(0xFF44ddcc),
    'echoes'    => const Color(0xFFaa77ff),
    'gemShards' => const Color(0xFF44bbff),
    _           => Colors.white54,
  };

  @override
  Widget build(BuildContext context) {
    final isComplete = progress >= challenge.target;
    final pct = challenge.target > 0
        ? (progress / challenge.target).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF231F1B),
        border: Border.all(
          color: challenge.claimed
              ? AppTheme.cardBorder
              : isComplete
                  ? _amber
                  : AppTheme.cardBorder,
          width: isComplete && !challenge.claimed ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: challenge.claimed
                    ? AppTheme.cardBorder.withValues(alpha: 0.3)
                    : isComplete
                        ? _amber.withValues(alpha: 0.2)
                        : const Color(0xFF2A2623),
                border: Border.all(
                  color: challenge.claimed
                      ? AppTheme.cardBorder
                      : isComplete
                          ? _amber
                          : AppTheme.textMuted.withValues(alpha: 0.4),
                ),
                borderRadius: BorderRadius.circular(3),
              ),
              child: challenge.claimed
                  ? const Icon(Icons.check, size: 14, color: Color(0xFF55cc55))
                  : Text('$index',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isComplete ? _amber : AppTheme.textMuted)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(challenge.name,
                  style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 0.5)),
            ),
            if (isComplete && !challenge.claimed)
              Text('READY',
                  style: AppTheme.pixelHeading(
                      fontSize: 10, color: _amber, letterSpacing: 1)),
          ]),
          const SizedBox(height: 8),
          Text(challenge.description,
              style: const TextStyle(fontSize: 13, color: AppTheme.textLight)),
          const SizedBox(height: 10),
          Text(
            '${progress.clamp(0, challenge.target)} / ${challenge.target}',
            style: TextStyle(
                fontSize: 12,
                color: isComplete ? _amber : AppTheme.textMuted),
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
                        ? _amber
                        : const Color(0xFFcc7722).withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: challenge.rewards.entries.map((e) => _RewardChip(
                    '${_rewardIcon(e.key)} ${e.value}',
                    _rewardColor(e.key),
                  )).toList(),
            ),
            const Spacer(),
            if (!challenge.claimed)
              TextButton(
                onPressed: isComplete ? onClaim : null,
                style: TextButton.styleFrom(
                  foregroundColor: _amber,
                  disabledForegroundColor: AppTheme.cardBorder,
                  side: BorderSide(
                      color: isComplete ? _amber : AppTheme.cardBorder),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text('CLAIM',
                    style: AppTheme.pixelHeading(
                        fontSize: 11,
                        color: isComplete ? _amber : AppTheme.cardBorder,
                        letterSpacing: 1)),
              ),
          ]),
        ],
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
                    fontSize: 10, color: AppTheme.textMuted, letterSpacing: 2)),
            Text('$claimed / $total',
                style: AppTheme.pixelHeading(
                    fontSize: 12,
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

  void _showChestReward(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (dialogCtx) => Center(
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (ctx, t, child) {
              return Opacity(
                opacity: t.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.8 + 0.2 * t,
                  child: child,
                ),
              );
            },
            child: Container(
              constraints: const BoxConstraints(maxWidth: 300),
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
              decoration: BoxDecoration(
                color: const Color(0xFF241910),
                border: Border.all(color: AppTheme.accentGold, width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎁', style: TextStyle(fontSize: 38)),
                  const SizedBox(height: 8),
                  Text('DAILY CHEST',
                      style: AppTheme.pixelHeading(fontSize: 22, letterSpacing: 3, color: AppTheme.accentGold)),
                  const SizedBox(height: 20),
                  _chestRow('💰', '+1,000 GOLD', const Color(0xFFffd700)),
                  const SizedBox(height: 8),
                  _chestRow(const ZCoinIcon(size: 16), '+50 ZCOINS', const Color(0xFF44ddcc)),
                  const SizedBox(height: 8),
                  _chestRow('◆', '+75 SHARDS', const Color(0xFF80d0ff)),
                  const SizedBox(height: 8),
                  _chestRow('✦', '+50 ESSENCE', const Color(0xFF88cc44)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('COLLECT',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _chestRow(Object icon, String label, Color color) {
    final iconWidget = icon is Widget
        ? icon
        : Text(icon as String, style: const TextStyle(fontSize: 16));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconWidget,
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color, letterSpacing: 1)),
      ],
    );
  }

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
        color: const Color(0xFF231F1B),
        border: Border.all(color: borderColor, width: ready ? 1.5 : 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Text(
            gotChest ? '📦' : allDone ? '🎁' : '🔒',
            style: const TextStyle(fontSize: 29),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DAILY CHEST',
                  style: AppTheme.pixelHeading(
                      fontSize: 13,
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
                      fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: const [
                    _RewardChip('💰 1000',  Color(0xFFccaa22)),
                    _RewardChip('◆ 75',     Color(0xFF88aaff)),
                    _RewardChip('✦ 50',     Color(0xFF88cc44)),
                    _RewardChip('50',   Color(0xFF44ddcc), prefix: ZCoinIcon(size: 10, animate: false)),
                  ],
                ),
              ],
            ),
          ),
          if (ready)
            GestureDetector(
              onTap: () {
                game.claimDailyChest();
                game.audioService.playClaim();
                _showChestReward(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.15),
                  border: Border.all(color: AppTheme.accentGold),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text('CLAIM',
                    style: AppTheme.pixelHeading(
                        fontSize: 12, color: AppTheme.accentGold)),
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
        color: const Color(0xFF231F1B),
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
                          : const Color(0xFF2A2623),
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
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isComplete
                                ? AppTheme.accentGold
                                : AppTheme.textMuted)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  challenge.title,
                  style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 0.5),
                ),
              ),
              if (isComplete && !challenge.claimed)
                Text('READY',
                    style: AppTheme.pixelHeading(
                        fontSize: 10,
                        color: AppTheme.accentGold,
                        letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 8),
          Text(challenge.description,
              style: const TextStyle(fontSize: 13, color: AppTheme.textLight)),
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
                          fontSize: 12,
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
              _RewardChip('💰 ${challenge.rewardGold}',    const Color(0xFFccaa22)),
              const SizedBox(width: 6),
              _RewardChip('◆ ${challenge.rewardShards + challenge.rewardEssence}',   const Color(0xFF88aaff)),
              const SizedBox(width: 6),
              _RewardChip('${challenge.rewardCrystals}', const Color(0xFF44ddcc), prefix: ZCoinIcon(size: 10, animate: false)),
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
                          fontSize: 11,
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
  const _RewardChip(this.label, this.color, {this.prefix});
  final String  label;
  final Color   color;
  final Widget? prefix;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (prefix != null) ...[prefix!, const SizedBox(width: 3)],
        Text(label, style: TextStyle(fontSize: 11, color: color)),
      ]),
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
                    fontSize: 11,
                    color: AppTheme.accentGold,
                    letterSpacing: 0)),
          ),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textMuted))),
        ],
      ),
    );
  }
}
