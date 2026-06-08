import 'package:flutter/material.dart';
import '../models/login_streak.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

class LoginStreakScreen extends StatelessWidget {
  const LoginStreakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final streak = game.loginStreak;
    final dayInCycle = ((streak - 1) % 7) + 1; // 1–7
    final todayClaimed = game.loginTodayClaimed;

    return Scaffold(
      backgroundColor: const Color(0xFF0a0e27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1f3a),
        title: Text('DAILY LOGIN',
            style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 2)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _StreakBadge(streak: streak),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoBanner(streak: streak, claimed: todayClaimed),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: List.generate(7, (i) {
              final day = i + 1;
              final reward = LoginReward.forDay(day);
              final isPast   = day < dayInCycle || todayClaimed;
              final isToday  = day == dayInCycle;
              final isFuture = day > dayInCycle && !todayClaimed;
              return _DayCell(
                reward: reward,
                isPast: isPast && !(isToday && !todayClaimed),
                isToday: isToday,
                isFuture: isFuture || (isToday && todayClaimed),
                claimed: todayClaimed && isToday,
              );
            }),
          ),
          const SizedBox(height: 20),
          if (!todayClaimed)
            _ClaimButton(
              reward: LoginReward.forDay(dayInCycle),
              onClaim: () => game.claimLoginReward(),
            )
          else
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0e1f0e),
                  border: Border.all(
                      color: const Color(0xFF44aa44).withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Come back tomorrow for your next reward!',
                    style: TextStyle(
                        fontSize: 11, color: Color(0xFF88cc88))),
              ),
            ),
          const SizedBox(height: 24),
          _CyclePreview(dayInCycle: dayInCycle, claimed: todayClaimed),
        ],
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFff8800).withValues(alpha: 0.15),
        border: Border.all(
            color: const Color(0xFFff8800).withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Text('🔥', style: TextStyle(fontSize: 11)),
        const SizedBox(width: 4),
        Text('$streak day${streak == 1 ? '' : 's'}',
            style: AppTheme.pixelHeading(
                fontSize: 11, color: const Color(0xFFff8800))),
      ]),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.streak, required this.claimed});
  final int streak;
  final bool claimed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        border: Border.all(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        claimed
            ? 'Day $streak reward claimed. Keep the streak alive — log in tomorrow!'
            : 'You\'ve been here $streak day${streak == 1 ? '' : 's'} in a row. '
              'Claim today\'s reward below. Missing a day resets your streak.',
        style: const TextStyle(
            fontSize: 11, color: AppTheme.textMuted, height: 1.5),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.reward,
    required this.isPast,
    required this.isToday,
    required this.isFuture,
    required this.claimed,
  });
  final LoginReward reward;
  final bool isPast;
  final bool isToday;
  final bool isFuture;
  final bool claimed;

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color bg;
    final Color textColor;
    if (isPast || claimed) {
      border = const Color(0xFF44aa44).withValues(alpha: 0.5);
      bg     = const Color(0xFF0e1f0e);
      textColor = const Color(0xFF44aa44);
    } else if (isToday) {
      border = AppTheme.accentGold;
      bg     = AppTheme.accentGold.withValues(alpha: 0.08);
      textColor = AppTheme.accentGold;
    } else {
      border = AppTheme.cardBorder;
      bg     = const Color(0xFF0e1225);
      textColor = AppTheme.textMuted;
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: isToday ? 1.5 : 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isPast || claimed)
            const Icon(Icons.check, size: 14, color: Color(0xFF44aa44))
          else
            Text(reward.icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 2),
          Text('D${reward.day}',
              style: TextStyle(
                  fontSize: 8,
                  color: textColor,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

class _ClaimButton extends StatelessWidget {
  const _ClaimButton({required this.reward, required this.onClaim});
  final LoginReward reward;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: onClaim,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentGold,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(reward.icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Text('CLAIM  ${reward.label}',
              style: AppTheme.pixelHeading(
                  fontSize: 11, letterSpacing: 1, color: Colors.black)),
        ]),
      ),
    );
  }
}

class _CyclePreview extends StatelessWidget {
  const _CyclePreview({required this.dayInCycle, required this.claimed});
  final int dayInCycle;
  final bool claimed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('FULL 7-DAY CYCLE',
            style: AppTheme.pixelHeading(
                fontSize: 10, letterSpacing: 2, color: AppTheme.textMuted)),
        const SizedBox(height: 10),
        ...LoginReward.cycle.map((r) {
          final isToday = r.day == dayInCycle;
          final isPast  = r.day < dayInCycle || (claimed && r.day == dayInCycle);
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isToday && !claimed
                  ? AppTheme.accentGold.withValues(alpha: 0.06)
                  : isPast
                      ? const Color(0xFF0e1f0e)
                      : const Color(0xFF0e1225),
              border: Border.all(
                  color: isToday && !claimed
                      ? AppTheme.accentGold.withValues(alpha: 0.6)
                      : isPast
                          ? const Color(0xFF44aa44).withValues(alpha: 0.4)
                          : AppTheme.cardBorder),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Row(children: [
              Text(r.icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 10),
              Text('Day ${r.day}',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isToday && !claimed
                          ? AppTheme.accentGold
                          : isPast
                              ? const Color(0xFF44aa44)
                              : Colors.white54)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(r.label,
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.textMuted)),
              ),
              if (isPast)
                const Icon(Icons.check_circle,
                    size: 14, color: Color(0xFF44aa44))
              else if (isToday && !claimed)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.15),
                    border: Border.all(color: AppTheme.accentGold),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text('TODAY',
                      style: AppTheme.pixelHeading(
                          fontSize: 7, color: AppTheme.accentGold)),
                ),
            ]),
          );
        }),
      ],
    );
  }
}
