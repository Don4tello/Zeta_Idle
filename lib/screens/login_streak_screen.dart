import 'package:flutter/material.dart';
import '../models/equipment.dart';
import '../models/hero_race.dart';
import '../models/login_streak.dart';
import '../models/shop_catalog.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/battle_sprites.dart';
import '../widgets/currency_icon.dart';
import '../widgets/item_sprites.dart';

/// Pixel-art icon for a login reward — mirrors the game's new [CurrencyIcon]
/// set (and an [ItemSprite] for the epic/legendary item days), replacing the
/// old emoji glyphs so the daily screen matches the rest of the UI.
class RewardIcon extends StatelessWidget {
  const RewardIcon({super.key, required this.reward, this.size = 18});
  final LoginReward reward;
  final double size;

  @override
  Widget build(BuildContext context) {
    switch (reward.primaryIconId) {
      case 'item_legendary':
        return ItemSprite(
            slot: ItemSlot.weapon, rarity: ItemRarity.legendary, size: size);
      case 'item_epic':
        return ItemSprite(
            slot: ItemSlot.weapon, rarity: ItemRarity.epic, size: size);
      case final id:
        return CurrencyIcon(id: id, size: size);
    }
  }
}

/// Honest, live label for a login reward — reflects the scaled gold and the
/// milestone-scaled rare currencies the player will actually receive, so the
/// preview/claim text never undersells what lands in the balance.
String loginRewardLabel(GameState game, LoginReward r) {
  final eff = game.effectiveLoginReward(r);
  final parts = <String>[];
  if (eff.gold > 0)    parts.add('${AppTheme.fmtNumber(eff.gold)} Gold');
  if (eff.zcoins > 0)  parts.add('${eff.zcoins} ZCoins');
  if (eff.shards > 0)  parts.add('${AppTheme.fmtNumber(eff.shards)} Shards');
  if (eff.echoes > 0)  parts.add('${AppTheme.fmtNumber(eff.echoes)} Echoes');
  if (eff.mythril > 0) parts.add('${eff.mythril} Mythril');
  if (eff.essence > 0) parts.add('${AppTheme.fmtNumber(eff.essence)} Essence');
  if (r.isEpicItem)       parts.add('Epic Item!');
  if (r.isClassLegendary) parts.add('Class Legendary!');
  return parts.join(' + ');
}

class LoginStreakScreen extends StatelessWidget {
  const LoginStreakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final streak = game.loginStreak;
    // Source of truth = the SAME day the claim actually grants (1–30), not a
    // separate %7 calc that used to drift out of sync past the first week.
    final dayInCycle = game.loginRewardDay;
    final todayClaimed = game.loginTodayClaimed;
    // The 7-cell grid shows the current week within the 30-day cycle.
    final weekStart = ((dayInCycle - 1) ~/ 7) * 7 + 1;
    final weekDays = [
      for (var d = weekStart;
          d < weekStart + 7 && d <= LoginReward.cycle.length; d++) d
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('DAILY LOGIN',
            style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
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
          _HeroBanner(game: game),
          const SizedBox(height: 14),
          _InfoBanner(streak: streak, dayInCycle: dayInCycle, claimed: todayClaimed),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: weekDays.map((day) {
              final reward = LoginReward.forDay(day);
              // A day is "past" only if it's before today's day, OR if it IS today and was claimed.
              final isPast   = day < dayInCycle || (day == dayInCycle && todayClaimed);
              final isToday  = day == dayInCycle && !todayClaimed;
              final isFuture = day > dayInCycle;
              return _DayCell(
                reward: reward,
                isPast: isPast,
                isToday: isToday,
                isFuture: isFuture,
                claimed: todayClaimed && day == dayInCycle,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          if (!todayClaimed)
            _ClaimButton(
              game: game,
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
                        fontSize: 12, color: Color(0xFF88cc88))),
              ),
            ),
          const SizedBox(height: 24),
          _CyclePreview(game: game, dayInCycle: dayInCycle, claimed: todayClaimed),
        ],
      ),
    );
  }
}

/// Personal touch on the login screen — the player's hero sprite plus a small
/// race indicator chip and class/level line.
class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final race = game.heroRace?.info;
    final accent = race?.color ?? AppTheme.accentGold;
    final hero = game.hero;

    // Equipped premium cosmetics.
    final frameColor = CosmeticItem.frameColorFor(game.activeFrame);
    final nameColor  = game.nameColor;
    final title      = game.activeTitle;

    // Framed hero sprite (scaled down to fit the banner). The premium portrait
    // frame recolours the border + glow when equipped.
    Widget spriteBox = Container(
      width: 76,
      height: 84,
      decoration: BoxDecoration(
        color: const Color(0xFF17150E),
        border: Border.all(
            color: frameColor ?? AppTheme.accentGold.withValues(alpha: 0.4),
            width: frameColor != null ? 2 : 1),
        borderRadius: BorderRadius.circular(4),
        boxShadow: frameColor != null
            ? [BoxShadow(color: frameColor.withValues(alpha: 0.5), blurRadius: 8)]
            : null,
      ),
      clipBehavior: Clip.hardEdge,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: BattleSprite(
            spriteId: game.heroBattleSpriteId,
            gender: hero.gender,
            race: game.heroRace,
            auraColor: game.heroAuraColor,
            auraIntensity: game.heroAuraIntensity,
            colorFilter: game.heroSpriteFilter,
          ),
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          accent.withValues(alpha: 0.10),
          const Color(0xFF231F1B),
        ]),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(children: [
        spriteBox,
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Equipped premium title (coloured to match).
              if (title != null && title.isNotEmpty) ...[
                Text(
                  title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.pixelHeading(
                      fontSize: 9,
                      letterSpacing: 1.2,
                      color: CosmeticItem.titleColorForName(title)),
                ),
                const SizedBox(height: 3),
              ],
              Text(
                hero.name.trim().isNotEmpty ? hero.name : hero.heroClass.displayName,
                style: AppTheme.pixelHeading(fontSize: 15, letterSpacing: 1)
                    .copyWith(color: nameColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text('Lv ${hero.level}  •  ${hero.heroClass.displayName}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              const SizedBox(height: 8),
              if (race != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: race.color.withValues(alpha: 0.15),
                    border: Border.all(color: race.color.withValues(alpha: 0.6)),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(race.icon, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 5),
                    Text(race.displayName.toUpperCase(),
                        style: TextStyle(
                            fontSize: 10,
                            color: race.color,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1)),
                  ]),
                ),
            ],
          ),
        ),
      ]),
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
        const Text('🔥', style: TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text('$streak day${streak == 1 ? '' : 's'}',
            style: AppTheme.pixelHeading(
                fontSize: 12, color: const Color(0xFFff8800))),
      ]),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.streak, required this.dayInCycle, required this.claimed});
  final int streak;
  final int dayInCycle;
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
            ? 'Day $dayInCycle reward claimed. Come back tomorrow to advance — '
              'your progress is safe even if you miss a day.'
            : 'You\'ve collected $streak daily reward${streak == 1 ? '' : 's'}. '
              'Claim today\'s below — miss a day and you simply pick up right '
              'where you left off, never back at Day 1.',
        style: const TextStyle(
            fontSize: 12, color: AppTheme.textMuted, height: 1.5),
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
      bg     = const Color(0xFF231F1B);
      textColor = AppTheme.textMuted;
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(
            color: reward.isMilestone && !isPast && !claimed
                ? const Color(0xFFffb300)
                : border,
            width: isToday ? 1.5 : 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isPast || claimed)
                const Icon(Icons.check, size: 14, color: Color(0xFF44aa44))
              else
                RewardIcon(reward: reward, size: 18),
              const SizedBox(height: 2),
              Text('D${reward.day}',
                  style: TextStyle(
                      fontSize: 9,
                      color: textColor,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
          if (reward.isMilestone)
            const Positioned(
              top: 2,
              right: 2,
              child: Icon(Icons.star, size: 9, color: Color(0xFFffb300)),
            ),
        ],
      ),
    );
  }
}

class _ClaimButton extends StatelessWidget {
  const _ClaimButton({required this.game, required this.reward, required this.onClaim});
  final GameState game;
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
          RewardIcon(reward: reward, size: 22),
          const SizedBox(width: 10),
          Flexible(
            child: Text('CLAIM  ${loginRewardLabel(game, reward)}',
                textAlign: TextAlign.center,
                style: AppTheme.pixelHeading(
                    fontSize: 12, letterSpacing: 1, color: Colors.black)),
          ),
        ]),
      ),
    );
  }
}

class _CyclePreview extends StatelessWidget {
  const _CyclePreview({required this.game, required this.dayInCycle, required this.claimed});
  final GameState game;
  final int dayInCycle;
  final bool claimed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('FULL 30-DAY CYCLE',
            style: AppTheme.pixelHeading(
                fontSize: 11, letterSpacing: 2, color: AppTheme.textMuted)),
        const SizedBox(height: 4),
        Row(children: [
          const Icon(Icons.star, size: 11, color: Color(0xFFffb300)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Milestone days scale their Shards/Echoes/Mythril with your tier '
              '(currently ×${game.loginMilestoneMult.toStringAsFixed(1)}).',
              style: const TextStyle(fontSize: 10, color: Color(0xFFffb300)),
            ),
          ),
        ]),
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
                      : const Color(0xFF231F1B),
              border: Border.all(
                  color: isToday && !claimed
                      ? AppTheme.accentGold.withValues(alpha: 0.6)
                      : isPast
                          ? const Color(0xFF44aa44).withValues(alpha: 0.4)
                          : AppTheme.cardBorder),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Row(children: [
              RewardIcon(reward: r, size: 20),
              const SizedBox(width: 10),
              Text('Day ${r.day}',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isToday && !claimed
                          ? AppTheme.accentGold
                          : isPast
                              ? const Color(0xFF44aa44)
                              : Colors.white54)),
              if (r.isMilestone) ...[
                const SizedBox(width: 4),
                const Icon(Icons.star, size: 11, color: Color(0xFFffb300)),
              ],
              const SizedBox(width: 8),
              Expanded(
                child: Text(loginRewardLabel(game, r),
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textMuted)),
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
                          fontSize: 8, color: AppTheme.accentGold)),
                ),
            ]),
          );
        }),
      ],
    );
  }
}
