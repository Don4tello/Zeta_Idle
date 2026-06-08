import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

class AchievementScreen extends StatelessWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game      = GameStateProvider.of(context);
    final claimable = game.achievementsClaimable;

    return Scaffold(
      backgroundColor: const Color(0xFF0a0e27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1f3a),
        title: Text('ACHIEVEMENTS', style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 2)),
        actions: [
          if (claimable > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: () { game.claimAllAchievements(); },
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.accentGold,
                  side: const BorderSide(color: AppTheme.accentGold),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: Text('CLAIM ALL ($claimable)',
                    style: AppTheme.pixelHeading(fontSize: 9, letterSpacing: 1,
                        color: AppTheme.accentGold)),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary bar
            _SummaryBar(game: game),
            const SizedBox(height: 16),

            // Group by category
            _CategorySection(
              title: 'COMBAT',
              achievements: game.achievements
                  .where((a) => _isCombat(a.condition))
                  .toList(),
              game: game,
            ),
            const SizedBox(height: 14),
            _CategorySection(
              title: 'PROGRESSION',
              achievements: game.achievements
                  .where((a) => _isProgression(a.condition))
                  .toList(),
              game: game,
            ),
            const SizedBox(height: 14),
            _CategorySection(
              title: 'ECONOMY & SYSTEMS',
              achievements: game.achievements
                  .where((a) => _isEconomy(a.condition))
                  .toList(),
              game: game,
            ),
          ],
        ),
      ),
    );
  }

  static bool _isCombat(AchievementCondition c) => const {
    AchievementCondition.totalBattleWins,
    AchievementCondition.totalKills,
    AchievementCondition.totalBossKills,
    AchievementCondition.totalDamageDealt,
    AchievementCondition.survivedAt1HP,
  }.contains(c);

  static bool _isProgression(AchievementCondition c) => const {
    AchievementCondition.heroLevel,
    AchievementCondition.campaignStage,
    AchievementCondition.prestigeLevel,
    AchievementCondition.subclassChosen,
  }.contains(c);

  static bool _isEconomy(AchievementCondition c) => !_isCombat(c) && !_isProgression(c);
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final total    = game.achievements.length;
    final unlocked = game.achievementsUnlocked;
    final claimed  = game.achievements.where((a) => a.claimed).length;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0e1225),
        border: Border.all(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('PROGRESS', style: AppTheme.pixelHeading(fontSize: 9, letterSpacing: 2, color: AppTheme.textMuted)),
            Text('$claimed / $total claimed',
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ]),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: total > 0 ? claimed / total : 0,
              minHeight: 6,
              backgroundColor: AppTheme.cardBorder,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
            ),
          ),
          if (unlocked > claimed) ...[
            const SizedBox(height: 8),
            Row(children: [
              Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFaacc44)),
              ),
              const SizedBox(width: 6),
              Text('${unlocked - claimed} achievement${unlocked - claimed == 1 ? '' : 's'} ready to claim!',
                  style: const TextStyle(fontSize: 11, color: Color(0xFFaacc44))),
            ]),
          ],
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.title,
    required this.achievements,
    required this.game,
  });
  final String title;
  final List<Achievement> achievements;
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final done = achievements.where((a) => a.claimed).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(title, style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2)),
          const SizedBox(width: 10),
          Text('$done/${achievements.length}',
              style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
        ]),
        const SizedBox(height: 8),
        ...achievements.map((a) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: _AchievementTile(a: a, game: game),
        )),
      ],
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.a, required this.game});
  final Achievement a;
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final progress = game.getAchievementProgress(a);
    final pct      = (progress / a.target).clamp(0.0, 1.0);
    final isReady  = a.unlocked && !a.claimed;

    Color borderColor;
    if (a.claimed) {
      borderColor = AppTheme.accentGold.withValues(alpha: 0.4);
    } else if (isReady) {
      borderColor = const Color(0xFFaacc44);
    } else {
      borderColor = AppTheme.cardBorder;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: a.claimed
            ? AppTheme.accentGold.withValues(alpha: 0.04)
            : const Color(0xFF0e1225),
        border: Border.all(color: borderColor, width: isReady ? 1.5 : 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // Emoji + claimed overlay
          SizedBox(
            width: 36,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: a.claimed ? 0.4 : 1.0,
                  child: Text(a.emoji, style: const TextStyle(fontSize: 22)),
                ),
                if (a.claimed)
                  const Icon(Icons.check_circle, color: AppTheme.accentGold, size: 18),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.name,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: a.claimed ? AppTheme.textMuted : AppTheme.textLight)),
                const SizedBox(height: 2),
                Text(a.description,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                if (!a.claimed) ...[
                  const SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 4,
                          backgroundColor: AppTheme.cardBorder,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              isReady ? const Color(0xFFaacc44) : const Color(0xFF4466cc)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_fmt(progress)} / ${_fmt(a.target)}',
                      style: TextStyle(
                          fontSize: 9,
                          color: isReady ? const Color(0xFFaacc44) : AppTheme.textMuted),
                    ),
                  ]),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Reward chip or claim button
          if (isReady)
            TextButton(
              onPressed: () => game.claimAchievement(a.id),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFaacc44),
                side: const BorderSide(color: Color(0xFFaacc44)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('CLAIM', style: AppTheme.pixelHeading(fontSize: 9, color: const Color(0xFFaacc44))),
                  Text(a.rewardLabel,
                      style: const TextStyle(fontSize: 10, color: Color(0xFFaacc44), fontWeight: FontWeight.bold)),
                ],
              ),
            )
          else
            _RewardBadge(a: a),
        ],
      ),
    );
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

class _RewardBadge extends StatelessWidget {
  const _RewardBadge({required this.a});
  final Achievement a;

  @override
  Widget build(BuildContext context) {
    final color = a.claimed ? AppTheme.textMuted : AppTheme.accentGold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        border: Border.all(color: color.withValues(alpha: a.claimed ? 0.3 : 0.6)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(a.rewardLabel,
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
    );
  }
}
