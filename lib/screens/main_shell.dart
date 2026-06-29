import 'package:flutter/material.dart';
import '../screens/aura_shop_screen.dart';
import '../screens/premium_shop_screen.dart';
import '../utils/format_number.dart';
import '../screens/hero_hub_screen.dart';
import '../screens/inventory_hub_screen.dart';
import '../screens/guild_screen.dart';
import '../screens/modes_screen.dart';
import '../widgets/resource_bar.dart';
import '../services/game_state.dart';
import '../services/save_service.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MainShell
//
// Persistent tab shell.  All five destinations live in an IndexedStack so
// each tab preserves its own state (the EndlessScreen battle loop, scroll
// positions, etc.) when the user switches away.
//
// Battle screens (/battle, /endless-arena) are pushed on the root Navigator
// via named routes, so they slide in on top of the entire shell — the bottom
// bar naturally disappears during a fight and reappears on Back.
// ─────────────────────────────────────────────────────────────────────────────

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.onBackToSelect});

  final VoidCallback onBackToSelect;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _checkOnStart();
  }

  Future<void> _checkOnStart() async {
    final seen = await SaveService.isWelcomeSeen();
    if (!mounted) return;
    final game = GameStateProvider.of(context);
    if (!seen) {
      await SaveService.markWelcomeSeen();
      game.markTutorialSeen('welcome');
      if (mounted) _showWelcomeTutorial(game);
    } else if (game.offlineGoldEarned > 0) {
      _showOfflineDialog(game);
      game.clearOfflineReport();
    }
  }

  void _showWelcomeTutorial(GameState game) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _WelcomeDialog(
        onDismiss: () {
          Navigator.pop(context);
          // Show offline dialog after tutorial if applicable
          if (game.offlineGoldEarned > 0) {
            _showOfflineDialog(game);
            game.clearOfflineReport();
          }
        },
      ),
    );
  }

  void _showLootLog(BuildContext ctx, GameState game) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: const Color(0xFF1a1a2e),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('LOOT LOG', style: AppTheme.pixelHeading(fontSize: 12, letterSpacing: 2, color: AppTheme.accentGold)),
              const SizedBox(height: 10),
              if (game.lootHistory.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('No loot yet — go fight something!',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12))),
                )
              else
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: game.lootHistory.length,
                    itemBuilder: (_, i) {
                      final e = game.lootHistory[i];
                      final ago = DateTime.now().difference(e.time);
                      final timeLabel = ago.inMinutes < 1 ? 'just now'
                          : ago.inMinutes < 60 ? '${ago.inMinutes}m ago'
                          : '${ago.inHours}h ago';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(children: [
                          Text(e.icon, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 8),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.text, style: const TextStyle(fontSize: 11, color: Colors.white70)),
                              if (e.detail != null)
                                Text(e.detail!, style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
                            ],
                          )),
                          Text(timeLabel, style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
                        ]),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOfflineDialog(GameState game) {
    final secs = game.offlineSecondsAway;
    final String timeLabel;
    if (secs >= 3600) {
      final h = secs ~/ 3600;
      final m = (secs % 3600) ~/ 60;
      timeLabel = m > 0 ? '${h}h ${m}m' : '${h}h';
    } else {
      timeLabel = '${secs ~/ 60}m';
    }
    final gold = game.offlineGoldEarned;
    final goldLabel = fmtNum(gold);

    final xp   = game.offlineXpEarned;
    final ess  = game.offlineEssenceEarned;
    final exps = game.offlineExpeditionsReady;

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2623),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: Text('Welcome back!',
            style: AppTheme.pixelHeading(fontSize: 14, color: AppTheme.accentGold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('You were away for $timeLabel.',
                style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
            const SizedBox(height: 12),
            _offlineRow('💰', '+$goldLabel gold', AppTheme.accentGold),
            if (xp > 0) ...[
              const SizedBox(height: 6),
              _offlineRow('✨', '+${fmtNum(xp)} XP', const Color(0xFF88aaff)),
            ],
            if (ess > 0) ...[
              const SizedBox(height: 6),
              _offlineRow('✦', '+$ess essence', const Color(0xFF44dd88)),
            ],
            if (exps > 0) ...[
              const SizedBox(height: 6),
              _offlineRow('🗺️', '$exps expedition${exps > 1 ? "s" : ""} ready!', const Color(0xFF55cc88)),
            ],
            const SizedBox(height: 8),
            const Text('Idle income collected while you rested.',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted,
                    fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CLAIM', style: AppTheme.pixelHeading(fontSize: 12, color: AppTheme.accentGold)),
          ),
        ],
      ),
    );
  }

  Widget _offlineRow(String emoji, String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(text, style: AppTheme.pixelHeading(fontSize: 14, color: color)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    if (game.pendingMilestone != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final id = game.pendingMilestone!;
        game.claimMilestoneRewards(id);
        game.dismissMilestone();
        final rewards = GameState.milestoneRewards(id);
        final rewardStr = rewards.entries.map((e) => '+${e.value} ${e.key}').join('  •  ');
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1a1a2e),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xFFFFD700), width: 2),
            ),
            title: Text('✦ MILESTONE ✦',
                textAlign: TextAlign.center,
                style: AppTheme.pixelHeading(fontSize: 16, letterSpacing: 3, color: const Color(0xFFFFD700))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset('assets/images/milestone_event.png',
                      height: 120, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                ),
                const SizedBox(height: 12),
                Text(GameState.milestoneLabel(id),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF112211),
                    border: Border.all(color: const Color(0xFF44cc88).withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(rewardStr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF44cc88))),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('CLAIM', style: AppTheme.pixelHeading(fontSize: 12, color: const Color(0xFFFFD700))),
              ),
            ],
          ),
        );
      });
    }
    if (game.pendingComebackRewards != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final rewards = game.pendingComebackRewards!;
        final rewardStr = rewards.entries.map((e) => '+${e.value} ${e.key}').join('\n');
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1a1a2e),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xFF44aaff), width: 2),
            ),
            title: Text('WELCOME BACK!',
                textAlign: TextAlign.center,
                style: AppTheme.pixelHeading(fontSize: 16, letterSpacing: 3, color: const Color(0xFF44aaff))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('We missed you! Here\'s a bonus\nfor your time away:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF112222),
                    border: Border.all(color: const Color(0xFF44aaff).withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(rewardStr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF44aaff), height: 1.5)),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () { game.claimComebackBonus(); Navigator.pop(ctx); },
                child: Text('CLAIM', style: AppTheme.pixelHeading(fontSize: 12, color: const Color(0xFF44aaff))),
              ),
            ],
          ),
        );
      });
    }
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Column(children: [
        Row(children: [
          const Expanded(child: ResourceBar()),
          GestureDetector(
            onTap: () => _showLootLog(context, game),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              color: const Color(0xFF1a1916),
              child: Stack(children: [
                const Icon(Icons.notifications_outlined, size: 16, color: AppTheme.textMuted),
                if (game.lootHistory.isNotEmpty)
                  Positioned(top: 0, right: 0,
                    child: Container(width: 6, height: 6,
                      decoration: const BoxDecoration(color: Color(0xFFffcc44), shape: BoxShape.circle))),
              ]),
            ),
          ),
        ]),
        // Flash event banner
        if (game.activeFlashEvent != null && game.activeFlashEvent!.isActive)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            color: const Color(0xFF2a1a00),
            child: Row(children: [
              Text(game.activeFlashEvent!.event.icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Expanded(child: Text(
                '${game.activeFlashEvent!.event.name} — ${game.activeFlashEvent!.event.description}',
                style: const TextStyle(fontSize: 10, color: Color(0xFFffaa33), fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              )),
              Text('${game.activeFlashEvent!.minutesRemaining}m left',
                  style: const TextStyle(fontSize: 9, color: Color(0xFFffaa33))),
            ]),
          ),
        Expanded(child: IndexedStack(
          index: _tab,
          children: [
            HeroHubScreen(onBackToSelect: widget.onBackToSelect),
            const ModesScreen(),
            const InventoryHubScreen(),
            const PremiumShopScreen(),
            if (game.campaignStageIndex >= 15) const GuildScreen(),
          ],
        )),
      ]),
      bottomNavigationBar: SafeArea(
        top: false,
        child: _CustomBottomNav(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        badges: [
          game.hasAffordableAbilityUpgrade || game.hasAffordablePassiveNode,
          game.hasClaimableDaily,
          game.inventory.bag.isNotEmpty,
          false,
          game.guildId != null,
        ],
        showGuild: game.campaignStageIndex >= 15,
      )),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom bottom navigation
// ─────────────────────────────────────────────────────────────────────────────

class _CustomBottomNav extends StatelessWidget {
  const _CustomBottomNav({required this.currentIndex, required this.onTap, this.badges = const [], this.showGuild = false});

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<bool> badges;
  final bool showGuild;

  List<({String emoji, String label})> get _navItems => [
    (emoji: '⚔️',  label: 'HERO'),
    (emoji: '🗺️',  label: 'MODES'),
    (emoji: '🎒',  label: 'INVENTORY'),
    (emoji: '🛒',  label: 'SHOP'),
    if (showGuild) (emoji: '🏰', label: 'GUILD'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Gold glow separator
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppTheme.accentGold.withValues(alpha: 0.5),
                AppTheme.accentGold.withValues(alpha: 0.5),
                Colors.transparent,
              ],
              stops: const [0.0, 0.2, 0.8, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentGold.withValues(alpha: 0.2),
                blurRadius: 6,
                offset: Offset.zero,
              ),
            ],
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A1714), Color(0xFF0E0C0A)],
            ),
          ),
          child: Row(
            children: List.generate(_navItems.length, (i) {
              return Expanded(
                child: _NavItem(
                  emoji: _navItems[i].emoji,
                  label: _navItems[i].label,
                  active: currentIndex == i,
                  badge: i < badges.length && badges[i],
                  onTap: () => onTap(i),
                ),
              );
            }),
          ),
        ),
        if (bottomPadding > 0)
          Container(height: bottomPadding, color: const Color(0xFF0E0C0A)),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.emoji,
    required this.label,
    required this.active,
    required this.onTap,
    this.badge = false,
  });

  final String emoji;
  final String label;
  final bool active;
  final bool badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppTheme.accentGold : AppTheme.textMuted;
    final isPhone = MediaQuery.of(context).size.width < 600;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: active
              ? AppTheme.accentGold.withValues(alpha: 0.07)
              : Colors.transparent,
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Gold top-line indicator with glow
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: active ? AppTheme.accentGold : Colors.transparent,
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: AppTheme.accentGold.withValues(alpha: 0.7),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: isPhone ? 6 : 9),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(fontSize: active ? (isPhone ? 18 : 22) : (isPhone ? 15 : 18)),
                    child: Text(emoji),
                  ),
                  SizedBox(height: isPhone ? 1 : 3),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: AppTheme.pixelHeading(
                      fontSize: active ? (isPhone ? 7 : 9) : (isPhone ? 6 : 8),
                      color: color,
                      letterSpacing: active ? 1.5 : 1,
                    ),
                    child: Text(label),
                  ),
                ],
              ),
            ),
            if (badge)
              Positioned(
                top: 6,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFffcc44),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Welcome tutorial dialog — shown on first launch after character creation
// ─────────────────────────────────────────────────────────────────────────────

class _WelcomeDialog extends StatefulWidget {
  const _WelcomeDialog({required this.onDismiss});
  final VoidCallback onDismiss;

  @override
  State<_WelcomeDialog> createState() => _WelcomeDialogState();
}

class _WelcomeDialogState extends State<_WelcomeDialog> {
  int _page = 0;

  static const _pages = [
    (
      icon: '⚔',
      title: 'Fight!',
      body: 'Tap QUICK BATTLE on the home screen to fight your first enemy. '
          'Attack costs nothing — keep pressing until the enemy falls.',
    ),
    (
      icon: '⚡',
      title: 'Earn idle gold',
      body: 'Your hero earns gold automatically every minute, even when you\'re not fighting. '
          'Watch the gold bar on the home screen fill up.',
    ),
    (
      icon: '⬆',
      title: 'Get stronger',
      body: 'Spend gold in UPGRADES to raise your stats. '
          'Open PASSIVES for permanent bonuses, and ABILITIES for powerful combat skills.',
    ),
    (
      icon: '🗺',
      title: 'Explore',
      body: 'CAMPAIGN advances through 25 hand-crafted stages. '
          'ENDLESS lets you grind shards forever. '
          'The DUNGEON is a roguelite run with item drops and boss fights.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final p = _pages[_page];
    final isLast = _page == _pages.length - 1;
    return AlertDialog(
      backgroundColor: const Color(0xFF2A2623),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      title: Row(children: [
        Text(p.icon, style: const TextStyle(fontSize: 23)),
        const SizedBox(width: 10),
        Text(p.title, style: AppTheme.pixelHeading(fontSize: 15, color: AppTheme.accentGold)),
        const Spacer(),
        Text('${_page + 1}/${_pages.length}',
            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
      ]),
      content: Text(p.body,
          style: const TextStyle(fontSize: 14, color: AppTheme.textLight, height: 1.5)),
      actions: [
        if (_page > 0)
          TextButton(
            onPressed: () => setState(() => _page--),
            child: Text('BACK', style: AppTheme.pixelHeading(fontSize: 11, color: AppTheme.textMuted)),
          ),
        TextButton(
          onPressed: isLast ? widget.onDismiss : () => setState(() => _page++),
          child: Text(isLast ? 'START PLAYING' : 'NEXT',
              style: AppTheme.pixelHeading(fontSize: 11, color: AppTheme.accentGold)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TutorialTip — contextual first-visit banner, shown at the top of screens
// Import this in any screen that needs a tip.
// ─────────────────────────────────────────────────────────────────────────────

class TutorialTip extends StatelessWidget {
  const TutorialTip({
    super.key,
    required this.tutorialKey,
    required this.text,
    required this.game,
  });

  final String tutorialKey;
  final String text;
  final GameState game;

  bool _isSeen() => switch (tutorialKey) {
    'battle'    => game.tutorialBattleSeen,
    'idle'      => game.tutorialIdleSeen,
    'upgrade'   => game.tutorialUpgradeSeen,
    'campaign'  => game.tutorialCampaignSeen,
    'dungeon'   => game.tutorialDungeonSeen,
    'gear'      => game.tutorialGearSeen,
    'forge'     => game.tutorialForgeSeen,
    'runes'     => game.tutorialRunesSeen,
    'artifacts' => game.tutorialArtifactsSeen,
    'endless'   => game.tutorialEndlessSeen,
    'gauntlet'  => game.tutorialGauntletSeen,
    'bossRush'  => game.tutorialBossRushSeen,
    'daily'     => game.tutorialDailySeen,
    'abilities' => game.tutorialAbilitiesSeen,
    'passives'  => game.tutorialPassivesSeen,
    'bestiary'  => game.tutorialBestiarySeen,
    'prestige'  => game.tutorialPrestigeSeen,
    'mercs'     => game.tutorialMercsSeen,
    _           => true,
  };

  @override
  Widget build(BuildContext context) {
    if (_isSeen()) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1a2a1a),
        border: const Border(bottom: BorderSide(color: Color(0xFF44cc88))),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 17)),
          const SizedBox(width: 10),
          Expanded(child: Text(text,
              style: const TextStyle(fontSize: 13, color: Color(0xFF88eeaa), height: 1.4))),
          GestureDetector(
            onTap: () => game.markTutorialSeen(tutorialKey),
            child: const Padding(
              padding: EdgeInsets.only(left: 10),
              child: Icon(Icons.close, size: 16, color: Color(0xFF44cc88)),
            ),
          ),
        ],
      ),
    );
  }
}
