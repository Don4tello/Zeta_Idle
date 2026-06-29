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
import 'bounty_board_screen.dart';
import 'expedition_screen.dart';
import 'quest_screen.dart';
import 'bestiary_screen.dart';

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
  static const _tabData = [
    ('CAMPAIGN',          '📜',  0),   // always
    ('DAILY',             '🎯',  5),   // boss 1
    ('QUESTS',            '📜', 10),   // boss 2
    ('DUNGEON',           '🏰', 15),   // boss 3
    ('BOUNTIES',          '📋', 20),   // boss 4
    ('BOSS RUSH',         '💀', 25),   // boss 5
    ('EVENTS',            '🌐', 30),   // boss 6
    ('TOWER ASCENSION',   '🗼', 35),   // boss 7
    ('EXPEDITION',        '🗺️', 40),  // boss 8
    ('GAUNTLET',          '🛡️', 45),  // boss 9
    ('PVP',               '⚔️', 50),  // boss 10
    ('BESTIARY',          '🐉', 55),   // boss 11
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
        final indices = _unlockedIndices(game.campaignStageIndex);
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
    final indices = _unlockedIndices(game.campaignStageIndex);
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
    0  => const CampaignScreen(),
    1  => const DailyScreen(),
    2  => const QuestScreen(),
    3  => const DungeonScreen(),
    4  => const BountyBoardScreen(),
    5  => const BossRushScreen(),
    6  => const WorldEventScreen(),
    7  => const EndlessScreen(),         // Tower Ascension
    8  => const ExpeditionScreen(),
    9  => const GauntletScreen(),
    10 => const PvpScreen(),
    11 => const BestiaryScreen(),
    _  => const SizedBox.shrink(),
  };

  @override
  Widget build(BuildContext context) {
    final game    = GameStateProvider.of(context);
    final cleared = game.campaignStageIndex;
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
                              style: GoogleFonts.pixelifySans(
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

