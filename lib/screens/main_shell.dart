import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_review/in_app_review.dart';
import '../widgets/currency_icon.dart';
import '../widgets/game_icons.dart';
import '../demo_config.dart';
import '../screens/premium_shop_screen.dart';
import '../utils/format_number.dart';
import '../screens/hero_hub_screen.dart';
import '../screens/inventory_hub_screen.dart';
import '../screens/guild_screen.dart';
import '../screens/modes_screen.dart';
import '../services/game_state.dart';
import '../services/save_service.dart';
import '../services/notification_service.dart';
import '../services/ad_service.dart';
import '../l10n/app_localizations.dart';
import '../data/system_tutorials.dart';
import '../l10n/content_l10n.dart';
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

/// Loot-log bottom sheet — recent drops/rewards. Shown from the Hero hub.
void showLootLog(BuildContext ctx, GameState game) {
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
            Text(AppLocalizations.of(ctx).lootLog, style: AppTheme.pixelHeading(fontSize: 12, letterSpacing: 2, color: AppTheme.accentGold)),
            const SizedBox(height: 10),
            if (game.lootHistory.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text(AppLocalizations.of(ctx).noLootYet,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12))),
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

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.onBackToSelect});

  final VoidCallback onBackToSelect;

  // Battle screens call this to request a tab switch when returning to the shell.
  static void Function(int tab)? _onTabRequest;
  static void switchToTab(int tab) => _onTabRequest?.call(tab);

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _tab = 0;
  bool _tutorialNavDone = false; // guards the one-time tutorial navigation
  bool _comebackMerged = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    MainShell._onTabRequest = (tab) {
      if (mounted) setState(() => _tab = tab);
    };
    _checkOnStart();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    MainShell._onTabRequest = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // On a warm resume (app wasn't killed), compute idle earnings accrued while
    // backgrounded and show the same welcome-back dialog as a cold start.
    if (state != AppLifecycleState.resumed || !mounted) return;
    final game = GameStateProvider.of(context);
    game.computeOfflineOnResume();
    if (game.offlineGoldEarned > 0) {
      if (game.pendingComebackRewards != null) _comebackMerged = true;
      _showOfflineDialog(game);
      game.clearOfflineReport();
    }
  }

  Future<void> _checkOnStart() async {
    final seen = await SaveService.isWelcomeSeen();
    if (!mounted) return;
    final game = GameStateProvider.of(context);
    if (!seen) {
      await SaveService.markWelcomeSeen();
      game.markTutorialSeen('welcome');
      // New character — start on Modes (Campaign) tab so they can battle immediately
      if (mounted) setState(() => _tab = 1);
      if (mounted) _showWelcomeTutorial(game);
    } else {
      if (game.offlineGoldEarned > 0) {
        if (game.pendingComebackRewards != null) _comebackMerged = true;
        _showOfflineDialog(game);
        game.clearOfflineReport();
      }
      // Returning player who's now in the game — a good moment for the one-time
      // notification-permission ask (if they weren't prompted on an earlier run).
      _maybePromptNotif();
    }
  }

  /// Ask for the OS notification permission exactly once, after the player is in
  /// the game. Keeps opt-in high (vs. a cold ask on the creation screen), which
  /// gates the whole "come back" reminder ladder that drives Day-1+ retention.
  Future<void> _maybePromptNotif() async {
    if (await SaveService.isNotifPrompted()) return;
    await SaveService.markNotifPrompted();
    try {
      await NotificationService.instance.requestPermission();
    } catch (_) {/* never block the UI on a permission prompt */}
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
          // First session is underway and the welcome is dismissed — now ask
          // for notification permission (good context = higher opt-in).
          _maybePromptNotif();
        },
      ),
    );
  }

  void _showOfflineDialog(GameState game) {
    final l = AppLocalizations.of(context);
    final secs = game.offlineSecondsAway;
    final String awayLine;
    if (game.offlineWasCapped) {
      // Real time away exceeded the idle cap (24h + Deep Reserves) — don't imply
      // an exact figure, just the capped maximum.
      awayLine = l.awayForCapped(game.idleCapHours);
    } else {
      final String timeLabel;
      if (secs >= 3600) {
        final h = secs ~/ 3600;
        final m = (secs % 3600) ~/ 60;
        timeLabel = m > 0 ? '${h}h ${m}m' : '${h}h';
      } else {
        timeLabel = '${secs ~/ 60}m';
      }
      awayLine = l.awayFor(timeLabel);
    }
    final gold = game.offlineGoldEarned;

    final xp      = game.offlineXpEarned;
    final ess     = game.offlineEssenceEarned;
    final exps    = game.offlineExpeditionsReady;
    final comeback = game.pendingComebackRewards;

    // Flipped when the player watches the rewarded ad to double gold + essence,
    // so the dialog re-renders the doubled figures in place (via setSB).
    bool doubled = false;

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2623),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(l.welcomeBack,
            style: AppTheme.pixelHeading(fontSize: 14, color: AppTheme.accentGold)),
        content: StatefulBuilder(builder: (_, setSB) {
          final goldShown = doubled ? gold * 2 : gold;
          final essShown  = doubled ? ess  * 2 : ess;
          return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(awayLine,
                style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
            const SizedBox(height: 12),
            _offlineRow(const CurrencyIcon(id: 'gold', size: 16), l.rewardGold(fmtNum(goldShown)), AppTheme.accentGold),
            if (xp > 0) ...[
              const SizedBox(height: 6),
              _offlineRow(const GameIcon(GameIconType.star, size: 16, color: Color(0xFF88aaff)),
                  l.rewardXp(fmtNum(xp)), const Color(0xFF88aaff)),
            ],
            if (ess > 0) ...[
              const SizedBox(height: 6),
              // "essence" is an alias for Shards — use the real Shards icon/label.
              _offlineRow(const CurrencyIcon(id: 'shards', size: 16),
                  l.rewardShards(fmtNum(essShown)), const Color(0xFF6699ff)),
            ],
            if (exps > 0) ...[
              const SizedBox(height: 6),
              _offlineRow(const GameIcon(GameIconType.compass, size: 16, color: Color(0xFF55cc88)),
                  l.expeditionsReady(exps), const Color(0xFF55cc88)),
            ],
            if (comeback != null) ...[
              const SizedBox(height: 10),
              const Divider(color: Colors.white12),
              const SizedBox(height: 4),
              Text(l.comebackBonus,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF44aaff), letterSpacing: 1)),
              const SizedBox(height: 6),
              ...comeback.entries.map((e) =>
                _offlineRow(const GameIcon(GameIconType.gift, size: 16, color: Color(0xFF44aaff)),
                    '+${e.value} ${e.key}', const Color(0xFF44aaff))),
            ],
            const SizedBox(height: 8),
            Text(l.idleIncomeCollected,
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted,
                    fontStyle: FontStyle.italic)),
            const SizedBox(height: 16),
            // Rewarded ad: watch to DOUBLE this idle report's gold + essence.
            // Opt-in value exchange (store-policy safe); hidden where ads aren't
            // supported (web/desktop).
            if (doubled) ...[
              Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                Icon(Icons.check_circle, size: 16, color: Color(0xFF55cc88)),
                SizedBox(width: 6),
                Text('Rewards doubled!',
                    style: TextStyle(color: Color(0xFF55cc88), fontSize: 13, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 10),
            ] else if (gold > 0 && AdService.instance.isSupported) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    AdService.instance.showRewardedAd(
                      placement: 'idle_reward_2x',
                      onRewarded: () {
                        game.grantDoubledOfflineReport();
                        game.audioService.playClaim();
                        setSB(() => doubled = true);
                      },
                      onFailed: () {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Ad not ready — try again in a moment.'),
                          behavior: SnackBarBehavior.floating,
                        ));
                      },
                    );
                  },
                  icon: const Icon(Icons.play_circle_outline, size: 18),
                  label: const Text('Double rewards — watch ad'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF55cc88),
                    side: const BorderSide(color: Color(0xFF55cc88)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            // Primary action — full-width filled button (was a small text button
            // tucked in the corner, easy to miss for the modal's only action).
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (comeback != null) game.claimComebackBonus();
                  game.audioService.playClaim();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(l.claim,
                    style: AppTheme.pixelHeading(fontSize: 14, color: Colors.black, letterSpacing: 2)),
              ),
            ),
          ],
          );
        }),
        actionsPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _offlineRow(Widget icon, String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        icon,
        const SizedBox(width: 8),
        Text(text, style: AppTheme.pixelHeading(fontSize: 14, color: color)),
      ]),
    );
  }

  /// Central tab switch — clears the Inventory "new loot" badge on open so the
  /// badge means "something new since you last looked", not "you own items".
  void _selectTab(int i) {
    if (i == 2) GameStateProvider.of(context).markLootSeen();
    setState(() => _tab = i);
  }

  /// Compliant "rate us" flow (fired after 30 min of play). A soft-ask gate:
  /// 👍 → the native in-app review dialog; 👎 → community feedback (keeps
  /// 1-stars off the store). NO reward is tied to rating — store policy forbids
  /// incentivised ratings, and the native API hides the outcome by design.
  // One-time "save your hero" sign-in nudge for new players. Keeps anonymous
  // first-sessioners recoverable (cloud save) before they can bounce for good.
  Future<void> _showSaveHeroPrompt(GameState game) async {
    final l = AppLocalizations.of(context);
    final accept = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppTheme.accentGold, width: 2),
        ),
        title: Text(l.saveHeroTitle,
            textAlign: TextAlign.center,
            style: AppTheme.pixelHeading(
                fontSize: 16, color: AppTheme.accentGold, letterSpacing: 2)),
        content: Text(
          l.saveHeroBody,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.textLight, height: 1.4),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.saveHeroLater, style: const TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGold, foregroundColor: Colors.black),
            child: Text(l.saveHeroConfirm,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    // We asked — latch so we never nag again, regardless of their choice.
    game.markSignInPrompted();
    if (!mounted || accept != true) return;
    final ok = await game.googleSignIn();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? l.saveHeroSynced : l.saveHeroFailed),
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _showRatingSoftAsk(GameState game) async {
    final l = AppLocalizations.of(context);
    final liked = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppTheme.accentGold, width: 2),
        ),
        title: Text(l.ratingTitle,
            textAlign: TextAlign.center,
            style: AppTheme.pixelHeading(
                fontSize: 16, color: AppTheme.accentGold, letterSpacing: 2)),
        content: Text(
          l.ratingBody,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.textLight, height: 1.4),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.ratingMeh, style: const TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGold, foregroundColor: Colors.black),
            child: Text(l.ratingLove, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    // We asked — latch so we don't nag again, regardless of their answer.
    game.markReviewPrompted();
    if (!mounted || liked == null) return;
    if (liked) {
      final review = InAppReview.instance;
      if (await review.isAvailable()) {
        await review.requestReview();
      } else {
        await review.openStoreListing();
      }
    } else {
      // Unhappy — route to Discord to tell us, not to a public 1-star.
      final uri = Uri.parse('https://discord.gg/F5WcvsZV9W');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    // Guided onboarding: when a system unlocks, jump to its tab and ask the hub
    // to select its sub-tab (once per unlock). The overlay is rendered below.
    if (game.pendingTutorial == null) {
      _tutorialNavDone = false;
    } else if (!_tutorialNavDone) {
      _tutorialNavDone = true;
      final t = game.pendingTutorial!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        game.navRequestSubTab = t.subTab;
        setState(() => _tab = t.navTab);
      });
    }
    // Rating soft-ask after 30 min of play — only when the shell is the topmost
    // route (not mid-battle/dialog) and no coach is showing. Retries on a later
    // shell build if the player is busy now.
    // Save-your-hero sign-in prompt (new player, first boss cleared). Takes
    // priority over the rating ask and uses the same "topmost route, no coach"
    // gating so it never stacks on a tutorial/milestone/battle.
    if (game.signInPromptPending &&
        game.pendingTutorial == null &&
        game.pendingMilestone == null &&
        (ModalRoute.of(context)?.isCurrent ?? true)) {
      game.signInPromptPending = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showSaveHeroPrompt(game);
      });
    } else if (game.reviewPromptPending &&
        game.pendingTutorial == null &&
        game.pendingMilestone == null &&
        (ModalRoute.of(context)?.isCurrent ?? true)) {
      game.reviewPromptPending = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showRatingSoftAsk(game);
      });
    }
    if (game.pendingMilestone != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final id = game.pendingMilestone!;
        game.claimMilestoneRewards(id);
        game.dismissMilestone();
        game.audioService.playClaim();
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
            title: Text(AppLocalizations.of(ctx).milestone,
                textAlign: TextAlign.center,
                style: AppTheme.pixelHeading(fontSize: 16, letterSpacing: 3, color: const Color(0xFFFFD700))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset('assets/images/milestone_event.webp',
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
                    borderRadius: BorderRadius.circular(8),
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
                child: Text(AppLocalizations.of(ctx).claim, style: AppTheme.pixelHeading(fontSize: 12, color: const Color(0xFFFFD700))),
              ),
            ],
          ),
        );
      });
    }
    // Only show the standalone comeback dialog when there is NO offline
    // "Welcome back!" dialog to merge into. When the player has offline gold,
    // _showOfflineDialog already displays + claims the comeback bonus — showing
    // this one too produced a duplicate "Welcome back" popup.
    if (game.pendingComebackRewards != null && !_comebackMerged
        && game.offlineGoldEarned == 0) {
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
            title: Text(AppLocalizations.of(ctx).welcomeBackCaps,
                textAlign: TextAlign.center,
                style: AppTheme.pixelHeading(fontSize: 16, letterSpacing: 3, color: const Color(0xFF44aaff))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppLocalizations.of(ctx).missedYou,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF112222),
                    border: Border.all(color: const Color(0xFF44aaff).withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(rewardStr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF44aaff), height: 1.5)),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () { game.claimComebackBonus(); game.audioService.playClaim(); Navigator.pop(ctx); },
                child: Text(AppLocalizations.of(ctx).claim, style: AppTheme.pixelHeading(fontSize: 12, color: const Color(0xFF44aaff))),
              ),
            ],
          ),
        );
      });
    }
    return Stack(children: [
      Scaffold(
      backgroundColor: AppTheme.darkBg,
      // Keep the top resource bar out from under the Android status bar
      // (time/battery/wifi). Bottom inset is handled by the nav bar below.
      body: SafeArea(
        bottom: false,
        child: Column(children: [
        // (Loot log moved to the Hero hub; resource totals shown contextually.)
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
        Expanded(child: _SwipeShell(
          tab: _tab,
          onTabChange: _selectTab,
          showGuild: game.effectiveUnlockStage >= 14,
          onBackToSelect: widget.onBackToSelect,
        )),
      ]),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: _CustomBottomNav(
        currentIndex: _tab,
        onTap: _selectTab,
        // Badges light ONLY for actionable states (something to claim/spend/do)
        // — a permanently-lit badge trains players to ignore all of them.
        badges: [
          game.hasAffordableAbilityUpgrade || game.hasAffordablePassiveNode,
          game.hasClaimableDaily || game.hasClaimableWeekly ||
              game.bossHuntsClaimable > 0 ||
              game.activeExpeditions.any((e) => e.isComplete),
          game.hasUnseenLoot,
          false,
          game.guildId != null && game.guildWar != null &&
              game.warAttacksRemaining > 0,
        ],
        showGuild: game.effectiveUnlockStage >= 14,
      )),
    ),
      // Non-skippable coach overlay — covers the whole screen (incl. the nav) so
      // the player must acknowledge it before continuing.
      if (game.pendingTutorial != null)
        _SystemTutorialOverlay(
          tutorial: game.pendingTutorial!,
          onDismiss: game.dismissSystemTutorial,
        ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// System tutorial coach overlay — shown when a progression system unlocks.
// A dim scrim over the (already navigated-to) system screen + a coach card.
class _SystemTutorialOverlay extends StatelessWidget {
  const _SystemTutorialOverlay({required this.tutorial, required this.onDismiss});
  final SystemTutorial tutorial;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      // Absorb all taps outside the card so the player can't skip past the coach
      // by tapping the nav or battle behind it.
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: Material(
        color: Colors.black.withValues(alpha: 0.55),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF17150E),
                    border: Border.all(color: AppTheme.accentGold, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                          color: AppTheme.accentGold.withValues(alpha: 0.25),
                          blurRadius: 16),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(children: [
                        Text(tutorial.icon, style: const TextStyle(fontSize: 26)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppLocalizations.of(context).newSystemUnlocked,
                                  style: TextStyle(
                                      fontSize: 8,
                                      letterSpacing: 2,
                                      color: AppTheme.accentGold,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(ContentL10n.of(context).tr('tut_${tutorial.stage}', 'title', tutorial.title),
                                  style: AppTheme.pixelHeading(
                                      fontSize: 16, letterSpacing: 1)),
                            ],
                          ),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      Text(ContentL10n.of(context).tr('tut_${tutorial.stage}', 'howTo', tutorial.howTo),
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textLight,
                              height: 1.5)),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onDismiss,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentGold,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(AppLocalizations.of(context).gotIt,
                              style: AppTheme.pixelHeading(
                                  fontSize: 13,
                                  letterSpacing: 2,
                                  color: Colors.black)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
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

  List<({GameIconType icon, String label})> get _navItems => [
    (icon: GameIconType.shield,   label: 'HERO'),
    (icon: GameIconType.swords,   label: 'PLAY'),
    (icon: GameIconType.chest,    label: 'INVENTORY'),
    (icon: GameIconType.coinBag,  label: 'SHOP'),
    if (showGuild) (icon: GameIconType.castle, label: 'GUILD'),
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
                  icon: _navItems[i].icon,
                  label: _navLabel(context, _navItems[i].label),
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

/// Localized label for a bottom-nav id (the ids stay English as stable keys).
String _navLabel(BuildContext context, String id) {
  final l = AppLocalizations.of(context);
  switch (id) {
    case 'HERO':      return l.navHero;
    case 'PLAY':      return l.navPlay;
    case 'INVENTORY': return l.navInventory;
    case 'SHOP':      return l.navShop;
    case 'GUILD':     return l.navGuild;
    default:          return id;
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.badge = false,
  });

  final GameIconType icon;
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
              // ≥48px total touch height on phones (padding + icon + label).
              padding: EdgeInsets.symmetric(vertical: isPhone ? 9 : 9),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GameIcon(
                    icon,
                    size: active ? (isPhone ? 20.0 : 24.0) : (isPhone ? 17.0 : 20.0),
                    color: color,
                  ),
                  SizedBox(height: isPhone ? 2 : 3),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: AppTheme.pixelHeading(
                      fontSize: active ? 9 : 8,
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

  // Icons are constant; the titles/bodies are pulled from localizations in build.
  static const _icons = [
    GameIconType.swords,
    GameIconType.coin,
    GameIconType.mountain,
    GameIconType.compass,
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final pages = [
      (icon: _icons[0], title: l.welcomeFightTitle,    body: l.welcomeFightBody),
      (icon: _icons[1], title: l.welcomeIdleTitle,     body: l.welcomeIdleBody),
      (icon: _icons[2], title: l.welcomeStrongerTitle, body: l.welcomeStrongerBody),
      (icon: _icons[3], title: l.welcomeExploreTitle,  body: l.welcomeExploreBody),
    ];
    final p = pages[_page];
    final isLast = _page == pages.length - 1;
    return AlertDialog(
      backgroundColor: const Color(0xFF2A2623),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Row(children: [
        GameIcon(p.icon, size: 23, color: AppTheme.accentGold),
        const SizedBox(width: 10),
        Text(p.title, style: AppTheme.pixelHeading(fontSize: 15, color: AppTheme.accentGold)),
        const Spacer(),
        Text('${_page + 1}/${pages.length}',
            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
      ]),
      content: Text(p.body,
          style: const TextStyle(fontSize: 14, color: AppTheme.textLight, height: 1.5)),
      actions: [
        if (_page > 0)
          TextButton(
            onPressed: () => setState(() => _page--),
            child: Text(l.navBack, style: AppTheme.pixelHeading(fontSize: 11, color: AppTheme.textMuted)),
          ),
        TextButton(
          onPressed: isLast ? widget.onDismiss : () => setState(() => _page++),
          child: Text(isLast ? l.startPlaying : l.navNext,
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
    this.onDismiss,
  });

  final String tutorialKey;
  final String text;
  final GameState game;
  final VoidCallback? onDismiss; // extra rebuild hook for screens that need it

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
    'mercs'         => game.tutorialMercsSeen,
    'bonus'         => game.tutorialBonusSeen,
    'codex'         => game.tutorialCodexSeen,
    'achievements'  => game.tutorialAchievementsSeen,
    'itemDrop'      => game.tutorialItemDropSeen,
    'energyEmpty'   => game.tutorialEnergyEmptySeen,
    'firstKill'     => game.tutorialFirstKillSeen,
    'abilityUnlock' => game.tutorialAbilityUnlockSeen,
    _               => true,
  };

  @override
  Widget build(BuildContext context) {
    // Veterans who have cleared Tier 0 (rebirthed at least once) no longer need
    // tutorial tips — hide them all once a difficulty tier is unlocked.
    if (game.highestUnlockedTier > 0 || _isSeen()) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1a2a1a),
        border: const Border(bottom: BorderSide(color: Color(0xFF44cc88))),
      ),
      child: Row(
        children: [
          const GameIcon(GameIconType.lightbulb, size: 17, color: Color(0xFF88eeaa)),
          const SizedBox(width: 10),
          Expanded(child: Text(text,
              style: const TextStyle(fontSize: 13, color: Color(0xFF88eeaa), height: 1.4))),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              game.markTutorialSeen(tutorialKey);
              onDismiss?.call();
            },
            child: Container(
              margin: const EdgeInsets.only(left: 10),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF223322),
                border: Border.all(color: const Color(0xFF44cc88), width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.close, size: 20, color: Color(0xFF44cc88)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SwipeShell — IndexedStack with horizontal swipe to change tabs
// ─────────────────────────────────────────────────────────────────────────────

class _SwipeShell extends StatefulWidget {
  const _SwipeShell({
    required this.tab,
    required this.onTabChange,
    required this.showGuild,
    required this.onBackToSelect,
  });
  final int tab;
  final ValueChanged<int> onTabChange;
  final bool showGuild;
  final VoidCallback onBackToSelect;

  @override
  State<_SwipeShell> createState() => _SwipeShellState();
}

class _SwipeShellState extends State<_SwipeShell> {
  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.tab,
      children: [
        HeroHubScreen(onBackToSelect: widget.onBackToSelect),
        const ModesScreen(),
        const InventoryHubScreen(),
        // Demo builds can't transact (no web billing) and the rewarded-ad path
        // would hand out free currency — so the shop is a full-game teaser.
        kDemoBuild ? const _DemoShopTeaser() : const PremiumShopScreen(),
        if (widget.showGuild) const GuildScreen(),
      ],
    );
  }
}

/// Full-game teaser shown in place of the shop on demo builds — the demo has no
/// working billing and the rewarded-ad path would grant free currency, so the
/// shop is disabled with an upsell to the full game.
class _DemoShopTeaser extends StatelessWidget {
  const _DemoShopTeaser();

  @override
  Widget build(BuildContext context) {
    const gold = AppTheme.accentGold;
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const GameIcon(GameIconType.coinBag, size: 56,
                  color: Color(0x80daa520)),
              const SizedBox(height: 18),
              Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.lock_outline, size: 16, color: gold),
                const SizedBox(width: 8),
                Text(l.navShop,
                    style: AppTheme.pixelHeading(
                        fontSize: 16, letterSpacing: 2, color: gold)),
              ]),
              const SizedBox(height: 14),
              Text(l.demoModeLocked,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14, color: AppTheme.textLight, height: 1.5)),
              const SizedBox(height: 16),
              Material(
                color: gold.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => launchUrl(Uri.parse(kFullGameUrl),
                      mode: LaunchMode.externalApplication),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                    decoration: BoxDecoration(
                      border: Border.all(color: gold.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.open_in_new, size: 14, color: gold),
                      const SizedBox(width: 8),
                      Text(l.demoFullGameCta,
                          style: AppTheme.pixelHeading(
                              fontSize: 11, letterSpacing: 1, color: gold)),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
