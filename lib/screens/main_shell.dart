import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/aura_shop_screen.dart';
import '../screens/hero_hub_screen.dart';
import '../screens/inventory_hub_screen.dart';
import '../screens/modes_screen.dart';
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
    final String goldLabel = gold >= 1000000
        ? '${(gold / 1000000).toStringAsFixed(1)}M'
        : gold >= 1000
            ? '${(gold / 1000).toStringAsFixed(1)}K'
            : '$gold';

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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withValues(alpha: 0.07),
                border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('💰', style: TextStyle(fontSize: 21)),
                const SizedBox(width: 8),
                Text('+$goldLabel gold',
                    style: AppTheme.pixelHeading(fontSize: 17, color: AppTheme.accentGold)),
              ]),
            ),
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

  static const _items = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline, size: 20),
      activeIcon: Icon(Icons.person, size: 20),
      label: 'HERO',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.games_outlined, size: 20),
      activeIcon: Icon(Icons.games, size: 20),
      label: 'MODES',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.backpack_outlined, size: 20),
      activeIcon: Icon(Icons.backpack, size: 20),
      label: 'INVENTORY',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.storefront_outlined, size: 20),
      activeIcon: Icon(Icons.storefront, size: 20),
      label: 'SHOP',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: IndexedStack(
        index: _tab,
        children: [
          HeroHubScreen(onBackToSelect: widget.onBackToSelect),
          const ModesScreen(),
          const InventoryHubScreen(),
          const AuraShopScreen(),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pixel-art top border — thin gold line above the bar
          Container(
            height: 2,
            color: AppTheme.accentGold.withValues(alpha: 0.25),
          ),
          BottomNavigationBar(
            currentIndex: _tab,
            onTap: (i) => setState(() => _tab = i),
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppTheme.cardBg,
            selectedItemColor: AppTheme.accentGold,
            unselectedItemColor: AppTheme.textMuted,
            selectedFontSize: 9,
            unselectedFontSize: 9,
            selectedLabelStyle: GoogleFonts.pixelifySans(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
            unselectedLabelStyle: GoogleFonts.pixelifySans(
              fontSize: 10,
              letterSpacing: 1,
            ),
            elevation: 0,
            items: _items,
          ),
        ],
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
    'battle'   => game.tutorialBattleSeen,
    'idle'     => game.tutorialIdleSeen,
    'upgrade'  => game.tutorialUpgradeSeen,
    'campaign' => game.tutorialCampaignSeen,
    'dungeon'  => game.tutorialDungeonSeen,
    _          => true,
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
