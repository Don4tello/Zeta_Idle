import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/format_number.dart';
import '../models/achievement.dart';
import '../models/expedition.dart';
import '../models/npc_ally.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/currency_info.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/hero_tab_controller.dart';
import '../widgets/stats_grid_panel.dart';
import '../models/login_streak.dart';
import 'package:go_router/go_router.dart';
import '../core/routing/app_router.dart';
import 'main_shell.dart' show TutorialTip, MainShell;

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    this.onBackToSelect,
    this.embedded = false,
  });

  final VoidCallback? onBackToSelect;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final body = const _SheetLayout();
    if (embedded) return body;
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: const Text('CHARACTER SHEET'),
        actions: [
          if (onBackToSelect != null)
            TextButton(
              onPressed: onBackToSelect,
              child: Text(
                'CHANGE CHARACTER',
                style: AppTheme.pixelHeading(
                    fontSize: 10,
                    color: AppTheme.textMuted,
                    letterSpacing: 1),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: body,
    );
  }
}

class _SheetLayout extends StatelessWidget {
  const _SheetLayout();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _LoginRewardBanner(),
          Builder(builder: (ctx) {
            final game = GameStateProvider.of(ctx);
            if (game.tutorialFirstKillSeen || game.campaignStageIndex == 0) {
              return const SizedBox.shrink();
            }
            return TutorialTip(
              tutorialKey: 'firstKill',
              game: game,
              text: 'First victory! ⚔ Spend your Gold in the Shop to upgrade stats. '
                  'Check HERO → ABILITIES to power up your attacks. '
                  'Your next goal: reach Stage 5 and defeat the first Boss!',
            );
          }),
          const DashboardHeader()
              .animate()
              .fadeIn(duration: 280.ms)
              .slideY(begin: -0.05, duration: 280.ms, curve: Curves.easeOut),
          const SizedBox(height: 12),
          const _SmartNextActionPanel()
              .animate(delay: 40.ms)
              .fadeIn(duration: 280.ms)
              .slideY(begin: 0.04, duration: 280.ms, curve: Curves.easeOut),
          const SizedBox(height: 12),
          const CombatStatsPanel()
              .animate(delay: 120.ms)
              .fadeIn(duration: 280.ms)
              .slideY(begin: 0.05, duration: 280.ms, curve: Curves.easeOut),
          const SizedBox(height: 12),
          const _IncomePanel()
              .animate(delay: 160.ms)
              .fadeIn(duration: 280.ms)
              .slideY(begin: 0.05, duration: 280.ms, curve: Curves.easeOut),
          const SizedBox(height: 12),
          const _AchievementProximityPanel()
              .animate(delay: 200.ms)
              .fadeIn(duration: 280.ms)
              .slideY(begin: 0.05, duration: 280.ms, curve: Curves.easeOut),
        ],
      ),
    );
  }
}

// ── Smart Next Action ─────────────────────────────────────────────────────────

class _SmartNextActionPanel extends StatelessWidget {
  const _SmartNextActionPanel();

  // Returns (emoji, text, color, heroHubIdx, shellIdx).
  //   heroHubIdx — all-tab index in HeroHubScreen (_kAllTabs) to jump to, via
  //     HeroTabController. Order: 0=SHEET 1=SCORES 2=ABILITIES 3=ACHIEVEMENTS
  //     4=PASSIVES 5=BONUSES 6=BESTIARY 7=CODEX 8=PETS 9=MERCS 10=REBIRTH
  //     11=UPGRADES 12=ASCEND 13=MASTERY.
  //   shellIdx — main shell tab (0=HERO 1=PLAY 2=INVENTORY 3=SHOP).
  // Both null → informational, not tappable.
  //   route — a go_router path to push (for screens that aren't a shell/hub tab,
  //     e.g. the Daily challenges screen). Takes priority when set.
  static (String, String, Color, int?, int?, String?)? _getAction(GameState game) {
    if (game.hasClaimableDaily && game.effectiveUnlockStage >= 5) {
      // Go straight to the Daily challenges screen, not the PLAY mode sheet.
      return ('🎯', 'Daily challenge ready to claim!',
          const Color(0xFFffaa44), null, null, Routes.daily);
    }
    if (game.achievementsClaimable > 0 && game.campaignStageIndex >= 5) {
      return ('🏆',
          '${game.achievementsClaimable} achievement${game.achievementsClaimable > 1 ? 's' : ''} ready to claim!',
          const Color(0xFFffcc44), 3, null, null);
    }
    final ready = game.activeExpeditions.where((e) {
      final elapsed = DateTime.now().millisecondsSinceEpoch - e.startEpochMs;
      return elapsed >= e.duration.ms;
    }).toList();
    if (ready.isNotEmpty) {
      return ('🗺️',
          '${ready.length} expedition${ready.length > 1 ? 's' : ''} ready to collect!',
          const Color(0xFF55cc88), 9, null, null);
    }
    if (game.canPrestige) {
      return ('✨', 'Prestige available — reset for power!',
          const Color(0xFFcc88ff), 10, null, null);
    }
    if (game.hasAffordableAbilityUpgrade) {
      return ('⚔', 'Ability upgrade affordable — visit ABILITIES',
          const Color(0xFF66aaff), 2, null, null);
    }
    if (game.hasAffordablePassiveNode) {
      return ('🌿', 'Passive upgrade affordable — visit PASSIVES',
          const Color(0xFF55ee88), 4, null, null);
    }
    if (game.hasAffordableEndlessUpgrade) {
      return ('🔮', 'Endless upgrade affordable — visit UPGRADES',
          const Color(0xFF8866ff), 11, null, null);
    }
    final idleMercs = NpcAllyDef.all
        .where((d) => game.allyUnlocked(d.id) && game.expeditionForMerc(d.id) == null)
        .toList();
    if (idleMercs.isNotEmpty) {
      return ('🧙',
          '${idleMercs.length} merc${idleMercs.length > 1 ? 's' : ''} idle — dispatch on an expedition',
          const Color(0xFFffaa44), 9, null, null);
    }
    if (game.campaignStageIndex >= 18 && game.campaignStageIndex % 25 >= 18) {
      final remaining = 25 - (game.campaignStageIndex % 25);
      return ('🏆',
          '$remaining campaign stage${remaining > 1 ? 's' : ''} until Prestige gate',
          const Color(0xFFaaddff), null, null, null);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final action = _getAction(game);
    if (action == null) return const SizedBox.shrink();
    final (emoji, text, color, heroHubIdx, shellIdx, route) = action;
    final htc = HeroTabController.maybeOf(context);
    final tappable = route != null || shellIdx != null || (heroHubIdx != null && htc != null);

    Widget card = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('NEXT ACTION',
                    style: AppTheme.pixelHeading(
                        fontSize: 8, letterSpacing: 2,
                        color: color.withValues(alpha: 0.7))),
                const SizedBox(height: 2),
                Text(text,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color.withValues(alpha: 0.95))),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 12, color: color.withValues(alpha: tappable ? 0.9 : 0.35)),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(duration: 3000.ms, color: color.withValues(alpha: 0.08));

    if (tappable) {
      card = GestureDetector(
        onTap: () {
          if (route != null) {
            context.push(route);
          } else if (shellIdx != null) {
            MainShell.switchToTab(shellIdx);
          } else if (heroHubIdx != null) {
            htc?.switchTo(heroHubIdx);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: card,
      );
    }
    return card;
  }
}

// ── Income Summary ────────────────────────────────────────────────────────────

class _IncomePanel extends StatelessWidget {
  const _IncomePanel();

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final goldPerHr = game.idleGoldPerMinute * 60;
    final expRewards = game.activeExpeditions.fold<int>(0, (sum, e) {
      final rewards = game.previewExpeditionRewards(
          e.mercId, e.location, e.duration);
      return sum + (rewards['gold'] ?? 0);
    });
    final hourlyLabel = '${fmtNum(goldPerHr)}/hr';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
      decoration: BoxDecoration(
        color: const Color(0xFF13110E),
        border: Border.all(color: const Color(0xFF3a3020)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('📊', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 6),
            Text('INCOME SUMMARY',
                style: AppTheme.pixelHeading(
                    fontSize: 9, letterSpacing: 2, color: AppTheme.accentGold)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _IncomeRow('💰', 'Idle gold', hourlyLabel, const Color(0xFFffd700)),
            const SizedBox(width: 16),
            _IncomeRow('⚔', 'Battle/kill',
                '${(game.hero.level * 50 + 100).toString()}g avg',
                const Color(0xFFff8866)),
            if (expRewards > 0) ...[
              const SizedBox(width: 16),
              _IncomeRow('🗺️', 'Expeditions',
                  '${expRewards >= 1000 ? '${(expRewards / 1000).toStringAsFixed(1)}K' : expRewards}g pending',
                  const Color(0xFF55cc88)),
            ],
          ]),
          if (game.shards > 0 || game.echoes > 0) ...[
            const SizedBox(height: 8),
            const Divider(color: Color(0xFF2a2518), height: 1),
            const SizedBox(height: 8),
            Wrap(spacing: 16, runSpacing: 6, children: [
              if (game.shards > 0)
                Tooltip(message: CurrencyInfo.shards,
                    child: _IncomeRow('◆', 'Shards', '${game.shards}', const Color(0xFF44ccff))),
              if (game.echoes > 0)
                Tooltip(message: CurrencyInfo.echoes,
                    child: _IncomeRow('🔊', 'Echoes', '${game.echoes}', const Color(0xFFcc88ff))),
            ]),
          ],
        ],
      ),
    );
  }
}

class _IncomeRow extends StatelessWidget {
  const _IncomeRow(this.icon, this.label, this.value, this.color);
  final String icon, label, value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          Text(icon, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppTheme.textMuted)),
        ]),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color)),
      ],
    );
  }
}

// ── Achievement Proximity Badges ──────────────────────────────────────────────

class _AchievementProximityPanel extends StatelessWidget {
  const _AchievementProximityPanel();

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);

    final cache = <Achievement, double>{};
    double ratioOf(Achievement a) => cache.putIfAbsent(
        a, () => game.getAchievementProgress(a) / a.target.clamp(1, 9999999));

    final near = game.achievements
        .where((a) => !a.unlocked && ratioOf(a) >= 0.70)
        .toList()
      ..sort((a, b) => ratioOf(b).compareTo(ratioOf(a)));

    if (near.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
      decoration: BoxDecoration(
        color: const Color(0xFF13110E),
        border: Border.all(color: const Color(0xFF3a2820)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('🏆', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 6),
            Text('ACHIEVEMENTS NEARBY',
                style: AppTheme.pixelHeading(
                    fontSize: 9, letterSpacing: 2, color: const Color(0xFFffcc44))),
          ]),
          const SizedBox(height: 10),
          ...near.take(3).map((a) => _AchievementBar(a, game)),
        ],
      ),
    );
  }
}

class _AchievementBar extends StatelessWidget {
  const _AchievementBar(this.a, this.game);
  final Achievement a;
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final progress = game.getAchievementProgress(a);
    final ratio = (progress / a.target.clamp(1, 9999999)).clamp(0.0, 1.0);
    final pct = (ratio * 100).round();
    final color = ratio >= 0.95
        ? const Color(0xFF55ee88)
        : ratio >= 0.80
            ? const Color(0xFFffcc44)
            : const Color(0xFF8877aa);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('${a.emoji} ', style: const TextStyle(fontSize: 12)),
            Expanded(
              child: Text(a.name,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textLight)),
            ),
            Text('$pct%',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color)),
          ]),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 4,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation<Color>(color.withValues(alpha: 0.8)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Login Reward Banner ──────────────────────────────────────────────────────

class _LoginRewardBanner extends StatelessWidget {
  const _LoginRewardBanner();

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    if (game.loginTodayClaimed) return const SizedBox.shrink();
    final day = ((game.loginStreak) % LoginReward.cycle.length) + 1;
    final reward = LoginReward.forDay(day);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => context.push(Routes.loginStreak),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFff8800).withValues(alpha: 0.08),
            border: Border.all(color: const Color(0xFFff8800), width: 1.5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(children: [
            Text(reward.icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DAY $day LOGIN REWARD',
                    style: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 1, color: const Color(0xFFff8800))),
                const SizedBox(height: 2),
                Text(reward.label,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
              ],
            )),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFff8800).withValues(alpha: 0.15),
                border: Border.all(color: const Color(0xFFff8800)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('CLAIM', style: AppTheme.pixelHeading(
                  fontSize: 10, color: const Color(0xFFff8800))),
            ),
          ]),
        ),
      ),
    );
  }
}
