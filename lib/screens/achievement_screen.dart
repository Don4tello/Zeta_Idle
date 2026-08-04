import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart' show TutorialTip;

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

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

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  final ScrollController _scrollCtrl       = ScrollController();
  final GlobalKey        _firstClaimableKey = GlobalKey();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToFirstClaimable() {
    final ctx = _firstClaimableKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      alignment: 0.1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final game      = GameStateProvider.of(context);
    final claimable = game.achievementsClaimable;

    final combatClaimable      = game.achievements.any((a) =>  AchievementScreen._isCombat(a.condition)      && a.unlocked && !a.claimed);
    final progressionClaimable = game.achievements.any((a) =>  AchievementScreen._isProgression(a.condition) && a.unlocked && !a.claimed);

    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('ACHIEVEMENTS', style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
        actions: [
          if (claimable > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: () { game.claimAllAchievements(); game.audioService.playClaimAll(); },
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.accentGold,
                  side: const BorderSide(color: AppTheme.accentGold),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: Text('CLAIM ALL ($claimable)',
                    style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 1,
                        color: AppTheme.accentGold)),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollCtrl,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TutorialTip(
              tutorialKey: 'achievements',
              game: game,
              text: 'You defeated your first boss! 🏆 Achievements track milestones '
                  'and reward ZCoins and Shards — claim them here and check back often.',
            ),
            _SummaryBar(
              game: game,
              onScrollToClaimable: claimable > 0 ? _scrollToFirstClaimable : null,
            ),
            const SizedBox(height: 16),
            _CategorySection(
              title: 'COMBAT',
              achievements: game.achievements
                  .where((a) => AchievementScreen._isCombat(a.condition))
                  .toList(),
              game: game,
              firstClaimableKey: combatClaimable ? _firstClaimableKey : null,
            ),
            const SizedBox(height: 14),
            _CategorySection(
              title: 'PROGRESSION',
              achievements: game.achievements
                  .where((a) => AchievementScreen._isProgression(a.condition))
                  .toList(),
              game: game,
              firstClaimableKey: !combatClaimable && progressionClaimable ? _firstClaimableKey : null,
            ),
            const SizedBox(height: 14),
            _CategorySection(
              title: 'ECONOMY & SYSTEMS',
              achievements: game.achievements
                  .where((a) => !AchievementScreen._isCombat(a.condition) && !AchievementScreen._isProgression(a.condition))
                  .toList(),
              game: game,
              firstClaimableKey: !combatClaimable && !progressionClaimable ? _firstClaimableKey : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.game, this.onScrollToClaimable});
  final GameState game;
  final VoidCallback? onScrollToClaimable;

  @override
  Widget build(BuildContext context) {
    final total    = game.achievements.length;
    final unlocked = game.achievementsUnlocked;
    final claimed  = game.achievements.where((a) => a.claimed).length;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF231F1B),
        border: Border.all(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('PROGRESS', style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2, color: AppTheme.textMuted)),
            Text('$claimed / $total claimed',
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
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
            GestureDetector(
              onTap: onScrollToClaimable,
              behavior: HitTestBehavior.opaque,
              child: Row(children: [
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFaacc44)),
                ),
                const SizedBox(width: 6),
                Text('${unlocked - claimed} achievement${unlocked - claimed == 1 ? '' : 's'} ready to claim!',
                    style: const TextStyle(fontSize: 12, color: Color(0xFFaacc44))),
                if (onScrollToClaimable != null) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_downward_rounded, size: 12, color: Color(0xFFaacc44)),
                ],
              ]),
            ),
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
    this.firstClaimableKey,
  });
  final String title;
  final List<Achievement> achievements;
  final GameState game;
  final GlobalKey? firstClaimableKey;

  static int _sortKey(Achievement a) {
    if (a.unlocked && !a.claimed) return 0;
    if (!a.claimed) return 1;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...achievements]..sort((a, b) => _sortKey(a).compareTo(_sortKey(b)));
    final done = achievements.where((a) => a.claimed).length;
    bool keyAssigned = false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(title, style: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 2)),
          const SizedBox(width: 10),
          Text('$done/${achievements.length}',
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
        ]),
        const SizedBox(height: 8),
        ...sorted.map((a) {
          final attachKey = !keyAssigned && firstClaimableKey != null && a.unlocked && !a.claimed;
          if (attachKey) keyAssigned = true;
          return Padding(
            key: attachKey ? firstClaimableKey : null,
            padding: const EdgeInsets.only(bottom: 6),
            child: _AchievementTile(a: a, game: game),
          );
        }),
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
            : const Color(0xFF231F1B),
        border: Border.all(color: borderColor, width: isReady ? 1.5 : 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: a.claimed ? 0.4 : 1.0,
                  child: Text(a.emoji, style: const TextStyle(fontSize: 23)),
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
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: a.claimed ? AppTheme.textMuted : AppTheme.textLight)),
                const SizedBox(height: 2),
                Text(a.description,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
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
                      '${AppTheme.fmtNumber(progress)} / ${AppTheme.fmtNumber(a.target)}',
                      style: TextStyle(
                          fontSize: 10,
                          color: isReady ? const Color(0xFFaacc44) : AppTheme.textMuted),
                    ),
                  ]),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isReady)
            TextButton(
              onPressed: () { game.claimAchievement(a.id); game.audioService.playClaim(); },
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
                  Text('CLAIM', style: AppTheme.pixelHeading(fontSize: 10, color: const Color(0xFFaacc44))),
                  Text(a.rewardLabel,
                      style: const TextStyle(fontSize: 11, color: Color(0xFFaacc44), fontWeight: FontWeight.bold)),
                ],
              ),
            )
          else
            _RewardBadge(a: a),
        ],
      ),
    );
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
          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
    );
  }
}
