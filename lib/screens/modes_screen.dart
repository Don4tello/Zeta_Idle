import 'dart:math' show max;
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import 'campaign_screen.dart';
import 'endless_screen.dart';
import 'daily_screen.dart';
import 'pvp_screen.dart';
import 'dungeon_screen.dart';
import 'gauntlet_screen.dart';
import 'boss_rush_screen.dart';
import 'world_event_screen.dart';
import 'expedition_screen.dart';
import 'quest_screen.dart';

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
    ('CHALLENGES',        '🎯',  5),   // boss 1 — daily / weekly / bounties
    ('QUESTS',            '📜', 10),   // boss 2
    ('EVENTS',            '🌐', 30),   // boss 6
    ('EXPEDITION',        '🗺️', 40),  // boss 8
    ('PVP',               '⚔️', 50),  // boss 10
  ];

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

  Widget _screenFor(int i) => switch (i) {
    // Primary — indices must match _tabData order exactly
    0  => const CampaignScreen(),
    1  => const DungeonScreen(),
    2  => const BossRushScreen(),        // BOSS RUSH
    3  => const EndlessScreen(),         // TOWER ASCENSION
    4  => const GauntletScreen(),        // GAUNTLET
    // Secondary
    5  => const DailyScreen(),           // CHALLENGES (daily / weekly / bounties)
    6  => const QuestScreen(),           // QUESTS
    7  => const WorldEventScreen(),      // EVENTS
    8  => const ExpeditionScreen(),      // EXPEDITION
    9  => const PvpScreen(),             // PVP
    _  => const SizedBox.shrink(),
  };

  @override
  Widget build(BuildContext context) {
    final game    = GameStateProvider.of(context);
    final cleared = max(game.campaignStageIndex, game.campaignAllTimeHigh);
    final indices = _unlockedIndices(cleared);

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
                final (label, emoji, _) = _tabData[i];
                final isActive = _index == vi;
                final isNew = !game.visitedModeTabs.contains(label);
                final hasClaimable = switch (label) {
                  'DAILY'      => game.hasClaimableDaily,
                  'EXPEDITION' => game.activeExpeditions.any((e) => e.isComplete),
                  'BOUNTIES'   => false,
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
                          Text(emoji,
                              style: TextStyle(fontSize: isActive ? 17 : 14)),
                          const SizedBox(height: 3),
                          Text(label,
                              style: GoogleFonts.rajdhani(
                                fontSize: 9,
                                fontWeight: isActive
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                letterSpacing: 1,
                                color: isActive
                                    ? AppTheme.accentGold
                                    : AppTheme.textMuted,
                              )),
                        ],
                      ),
                      // Separator line between primary and secondary groups
                      if (showGroupSeparator)
                        Positioned(
                          left: -14,
                          top: 8, bottom: 8,
                          child: Container(
                            width: 1,
                            color: const Color(0xFF5a4830),
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
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                fontSize: 6,
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

