import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
// ModesScreen — all game modes accessible via a scrollable tab bar.
// Uses a lazy IndexedStack so each mode preserves its state once first opened.
// ─────────────────────────────────────────────────────────────────────────────

class ModesScreen extends StatefulWidget {
  const ModesScreen({super.key});

  @override
  State<ModesScreen> createState() => _ModesScreenState();
}

class _ModesScreenState extends State<ModesScreen>
    with SingleTickerProviderStateMixin {
  static const _labels = [
    'CAMPAIGN',
    'ENDLESS',
    'DAILY',
    'PVP',
    'DUNGEON',
    'GAUNTLET',
    'BOSS RUSH',
    'EVENTS',
    'BOUNTIES',
    'EXPEDITION',
    'QUESTS',
    'BESTIARY',
  ];

  late final TabController _tabs =
      TabController(length: _labels.length, vsync: this);

  int _index = 0;
  final Set<int> _loaded = {0};

  @override
  void initState() {
    super.initState();
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) {
        setState(() {
          _index = _tabs.index;
          _loaded.add(_index);
        });
      }
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Widget _screenFor(int i) => switch (i) {
        0  => const CampaignScreen(),
        1  => const EndlessScreen(),
        2  => const DailyScreen(),
        3  => const PvpScreen(),
        4  => const DungeonScreen(),
        5  => const GauntletScreen(),
        6  => const BossRushScreen(),
        7  => const WorldEventScreen(),
        8  => const BountyBoardScreen(),
        9  => const ExpeditionScreen(),
        10 => const QuestScreen(),
        11 => const BestiaryScreen(),
        _  => const SizedBox.shrink(),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Column(
        children: [
          // Scrollable mode selector
          Container(
            color: AppTheme.cardBg,
            child: TabBar(
              controller: _tabs,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelStyle: GoogleFonts.pixelifySans(
                  fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
              unselectedLabelStyle:
                  GoogleFonts.pixelifySans(fontSize: 10, letterSpacing: 1),
              labelColor: AppTheme.accentGold,
              unselectedLabelColor: AppTheme.textMuted,
              indicatorColor: AppTheme.accentGold,
              indicatorWeight: 2,
              tabs: _labels.map((l) => Tab(text: l)).toList(),
            ),
          ),
          // Lazy-loaded mode content
          Expanded(
            child: IndexedStack(
              index: _index,
              children: List.generate(
                _labels.length,
                (i) => _loaded.contains(i)
                    ? _screenFor(i)
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
