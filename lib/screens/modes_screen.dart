import 'dart:math' show max;
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/game_state.dart';
import '../demo_config.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/game_icons.dart';
import 'campaign_screen.dart';
import 'endless_screen.dart';
import 'daily_screen.dart';
import 'pvp_screen.dart';
import 'dungeon_screen.dart';
import 'gauntlet_screen.dart';
import 'boss_rush_screen.dart';
import 'world_event_screen.dart';
import 'expedition_screen.dart';

/// Maps a stable mode-tab id (also used as a logic key) to its localized label.
String _modeLabel(BuildContext context, String id) {
  final l = AppLocalizations.of(context);
  switch (id) {
    case 'CAMPAIGN':        return l.modeCampaign;
    case 'DUNGEON':         return l.modeDungeon;
    case 'BOSS RUSH':       return l.modeBossRush;
    case 'TOWER ASCENSION': return l.modeTowerAscension;
    case 'GAUNTLET':        return l.modeGauntlet;
    case 'PVP':             return l.modePvp;
    case 'CHALLENGES':      return l.modeChallenges;
    case 'EVENTS':          return l.modeEvents;
    case 'EXPEDITION':      return l.modeExpedition;
    case 'DAILY':           return l.modeDaily;
    case 'BOUNTIES':        return l.modeBounties;
    case 'QUESTS':          return l.modeQuests;
    default:                return id;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ModesScreen
// ─────────────────────────────────────────────────────────────────────────────

class ModesScreen extends StatefulWidget {
  const ModesScreen({super.key});

  @override
  State<ModesScreen> createState() => _ModesScreenState();
}

class _ModesScreenState extends State<ModesScreen>
    with TickerProviderStateMixin {

  // (label, emoji, unlockRequirement)
  // Primary combat modes come first (left side), secondary/meta modes after.
  static const _tabData = [
    // ── Primary (battle animation modes) ─────────────────────────────────────
    ('CAMPAIGN',          '📜',  0),   // always
    ('DUNGEON',           '🏰', 15),   // boss 3
    ('BOSS RUSH',         '💀', 25),   // boss 5
    ('TOWER ASCENSION',   '🗼', 35),   // boss 7
    ('GAUNTLET',          '🛡️', 45),  // boss 9
    // ── Secondary ─────────────────────────────────────────────────────────────
    // PvP sits first among the secondary modes so it lands right after Gauntlet
    // (both are "test your build" challenge modes). Still gated to stage 50, so
    // it only appears once unlocked.
    ('PVP',               '⚔️', 50),
    ('CHALLENGES',        '🎯',  5),   // daily / weekly / bounties
    // QUESTS moved to the HERO tab.
    ('EVENTS',            '🌐', 30),   // boss 6
    ('EXPEDITION',        '🗺️', 40),  // boss 8
  ];

  // Pixel GameIcons for the mode tabs — matches the bottom nav's aesthetic
  // (the emoji above are legacy and no longer rendered). Keyed by label.
  static const _modeIcons = <String, GameIconType>{
    'CAMPAIGN':        GameIconType.scroll,
    'DUNGEON':         GameIconType.key,
    'BOSS RUSH':       GameIconType.skull,
    'TOWER ASCENSION': GameIconType.mountain,
    'GAUNTLET':        GameIconType.gauntlet,
    'PVP':             GameIconType.swords,
    'CHALLENGES':      GameIconType.flag,
    'EVENTS':          GameIconType.flame,
    'EXPEDITION':      GameIconType.compass,
  };

  late TabController _tabs;
  int _index = 0;
  int _visibleCount = 0;
  // Track which ALL-data indices have been loaded (for lazy init).
  final Set<int> _loadedAll = {0};

  List<int> _unlockedIndices(int stage) => [
    for (int i = 0; i < _tabData.length; i++)
      if (stage >= _tabData[i].$3) i,
  ];

  void _onTabChange() {
    if (!_tabs.indexIsChanging) {
      setState(() => _index = _tabs.index);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final game = GameStateProvider.of(context);
        final indices = _unlockedIndices(max(game.campaignStageIndex, game.campaignAllTimeHigh));
        if (_index < indices.length) {
          final label = _tabData[indices[_index]].$1;
          game.markModeTabVisited(label);
        }
      });
    }
  }

  void _rebuildTabs(int newCount) {
    if (newCount == 0) return;
    final prev = _index.clamp(0, newCount - 1);
    _tabs.removeListener(_onTabChange);
    _tabs.dispose();
    _tabs = TabController(length: newCount, vsync: this)
      ..addListener(_onTabChange)
      ..index = prev;
    _visibleCount = newCount;
  }

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 1, vsync: this)
      ..addListener(_onTabChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final game = GameStateProvider.of(context);
    final effective = max(game.campaignStageIndex, game.campaignAllTimeHigh);
    final indices = _unlockedIndices(effective);
    final newCount = indices.isEmpty ? 1 : indices.length;
    if (newCount != _visibleCount) {
      _rebuildTabs(newCount);
    }
  }

  @override
  void dispose() {
    _tabs.removeListener(_onTabChange);
    _tabs.dispose();
    super.dispose();
  }

  Widget _screenFor(int i) {
    // Demo builds show the alt modes as locked "full game" teasers (the id lives
    // in _tabData); Campaign + Challenges stay playable. See demo_config.dart.
    final id = _tabData[i].$1;
    if (!kDemoModeAllowed(id)) {
      return _DemoLockedMode(modeId: id, icon: _modeIcons[id] ?? GameIconType.swords);
    }
    return switch (i) {
      // Primary — indices must match _tabData order exactly
      0  => const CampaignScreen(),
      1  => const DungeonScreen(),
      2  => const BossRushScreen(),        // BOSS RUSH
      3  => const EndlessScreen(),         // TOWER ASCENSION
      4  => const GauntletScreen(),        // GAUNTLET
      // Secondary
      5  => const PvpScreen(),             // PVP (grouped next to Gauntlet)
      6  => const DailyScreen(),           // CHALLENGES (daily / weekly / bounties)
      7  => const WorldEventScreen(),      // EVENTS
      8  => const ExpeditionScreen(),      // EXPEDITION
      _  => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final game    = GameStateProvider.of(context);
    final cleared = max(game.campaignStageIndex, game.campaignAllTimeHigh);
    final indices = _unlockedIndices(cleared);

    // Guided-tutorial deep link: select the requested mode tab if it lives here.
    final want = game.consumeNavRequestFor([for (final i in indices) _tabData[i].$1]);
    if (want != null) {
      final pos = indices.indexWhere((i) => _tabData[i].$1 == want);
      if (pos >= 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && pos < _tabs.length && _tabs.index != pos) _tabs.animateTo(pos);
        });
      }
    }

    // Mark current all-data index as loaded.
    final allIdx = indices[_index.clamp(0, indices.length - 1)];
    _loadedAll.add(allIdx);

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Column(
        children: [
          // ── Tab bar (only unlocked modes shown) ───────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1C1916),
              border: Border(
                bottom: BorderSide(color: Color(0xFF3a3020), width: 1),
              ),
            ),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  ...ScrollConfiguration.of(context).dragDevices,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.touch,
                },
              ),
              child: TabBar(
              controller: _tabs,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelPadding: const EdgeInsets.symmetric(horizontal: 14),
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(color: AppTheme.accentGold, width: 2.5),
                insets: EdgeInsets.symmetric(horizontal: 8),
              ),
              dividerColor: Colors.transparent,
              tabs: List.generate(indices.length, (vi) {
                final i = indices[vi];
                final (label, _, _) = _tabData[i];
                final isActive = _index == vi;
                final isNew = !game.visitedModeTabs.contains(label);
                final hasClaimable = switch (label) {
                  'DAILY'      => game.hasClaimableDaily,
                  'CHALLENGES' => game.hasClaimableDaily || game.hasClaimableWeekly || game.bossHuntsClaimable > 0,
                  'EXPEDITION' => game.activeExpeditions.any((e) => e.isComplete),
                  'BOUNTIES'   => game.bossHuntsClaimable > 0,
                  'QUESTS'     => game.questsClaimable > 0 || game.adventureQuestsClaimable > 0,
                  _            => false,
                };
                // Show a separator before the first secondary tab (index ≥ 5)
                // when there is at least one primary tab visible before it.
                // Primary = Campaign, Dungeon, Boss Rush, Tower Ascension,
                // Gauntlet (indices 0–4); secondary = Daily onward (5+).
                final isSecondary = i >= 5;
                final prevIsPrimary = vi > 0 && indices[vi - 1] < 5;
                final showGroupSeparator = isSecondary && prevIsPrimary;
                return Tab(
                  height: 52,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GameIcon(
                              _modeIcons[label] ?? GameIconType.swords,
                              size: isActive ? 20 : 16,
                              color: isActive
                                  ? AppTheme.accentGold
                                  : AppTheme.textMuted),
                          const SizedBox(height: 3),
                          Text(_modeLabel(context, label),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.rajdhani(
                                fontSize: 10.5,
                                fontWeight: isActive
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                letterSpacing: 1,
                                color: isActive
                                    ? AppTheme.accentGold
                                    : AppTheme.textMuted,
                              )),
                        ],
                      ),
                      // Section break between the primary battle modes and the
                      // secondary "more" modes — a clearer gold divider so the
                      // grouping reads intentionally, not as a stray hairline.
                      if (showGroupSeparator)
                        Positioned(
                          left: -15,
                          top: 6, bottom: 6,
                          child: Container(
                            width: 2,
                            decoration: BoxDecoration(
                              color: const Color(0xFF8a6a2a),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                      if (isNew)
                        Positioned(
                          top: -2,
                          right: -8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFee3333),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              AppLocalizations.of(context).badgeNew,
                              style: const TextStyle(
                                fontSize: 7.5,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      if (hasClaimable && !isNew)
                        Positioned(
                          top: 0, left: -4,
                          child: Container(
                            width: 7, height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFCC44),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          )),

          // ── Content ───────────────────────────────────────────────────────
          Expanded(
            child: IndexedStack(
              index: _index.clamp(0, indices.length - 1),
              children: List.generate(indices.length, (vi) {
                final i = indices[vi];
                return _loadedAll.contains(i)
                    ? _screenFor(i)
                    : const SizedBox.shrink();
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// Teaser shown in the PLAY tab for a mode that's locked in the demo build —
/// previews the mode by name + icon and points to the full game, instead of
/// hiding it (so players see the breadth of what they'd unlock).
class _DemoLockedMode extends StatelessWidget {
  const _DemoLockedMode({required this.modeId, required this.icon});
  final String modeId;
  final GameIconType icon;

  @override
  Widget build(BuildContext context) {
    final name = _modeLabel(context, modeId);
    const gold = AppTheme.accentGold;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GameIcon(icon, size: 56, color: gold.withValues(alpha: 0.7)),
            const SizedBox(height: 18),
            Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.lock_outline, size: 16, color: gold),
              const SizedBox(width: 8),
              Text(name,
                  style: AppTheme.pixelHeading(
                      fontSize: 16, letterSpacing: 2, color: gold)),
            ]),
            const SizedBox(height: 14),
            Text(AppLocalizations.of(context).demoModeLocked,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, color: AppTheme.textLight, height: 1.5)),
            const SizedBox(height: 10),
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
                    Text(AppLocalizations.of(context).demoFullGameCta,
                        style: AppTheme.pixelHeading(
                            fontSize: 11, letterSpacing: 1, color: gold)),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

