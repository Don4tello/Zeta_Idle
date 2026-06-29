import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/ambient_particles.dart';
import '../widgets/glow_tab_indicator.dart';
import '../widgets/hero_tab_controller.dart';
import 'dashboard_screen.dart';
import 'ability_upgrade_screen.dart';
import 'endless_upgrade_screen.dart';
import 'hero_stats_screen.dart';
import '../models/npc_ally.dart';
import 'npc_ally_screen.dart';
import 'passive_tree_screen.dart';
import 'prestige_screen.dart';
import 'ascension_screen.dart';
import 'codex_screen.dart';
import 'achievement_screen.dart';
import 'bestiary_screen.dart';

// ── Tab definitions (all tabs, with unlock stage requirement) ─────────────────

class _TabResource {
  const _TabResource({required this.icon, required this.color,
      required this.name, required this.sources});
  final String icon;
  final Color  color;
  final String name;
  final String sources;
}

class _TabDef {
  const _TabDef(this.label, this.emoji, this.unlock, {this.resource});
  final String       label;
  final String       emoji;
  final int          unlock; // campaignStageIndex required to show this tab
  final _TabResource? resource;
}

// Master list: order = display order, unlock = stage required.
const _kAllTabs = <_TabDef>[
  _TabDef('SHEET',     '🧙',  0),                                     // always
  _TabDef('BONUSES',   '📊',  3),                                     // after a few stages
  _TabDef('ABILITIES', '⚔️',  1, resource: _TabResource(              // after first battle
    icon: '◆', color: Color(0xFF44ccff), name: 'Shards',
    sources: 'Dungeon runs · Locked Chests · Treasure rooms',
  )),
  _TabDef('ACHIEVEMENTS', '🏆', 5),                                   // after bestiary
  _TabDef('PASSIVES',  '🌿',  8, resource: _TabResource(              // after dungeon
    icon: '✦', color: Color(0xFF44dd88), name: 'Essence',
    sources: 'Campaign kills · Gauntlet runs · Daily rewards',
  )),
  _TabDef('UPGRADES',  '🔮',  45, resource: _TabResource(             // after gauntlet
    icon: '🔊', color: Color(0xFFcc88ff), name: 'Echoes',
    sources: 'Challenge Gauntlet runs',
  )),
  _TabDef('BESTIARY',  '🐉',  5),                                     // after some kills
  _TabDef('CODEX',     '📖',  3),                                     // early reference
  _TabDef('MERCS',     '🤝', 18),                                     // late-early
  _TabDef('REBIRTH',   '✦',  25, resource: _TabResource(              // at first gate
    icon: '☠', color: Color(0xFFcc8844), name: 'Souls',
    sources: 'Earned by Prestiging your hero',
  )),
  _TabDef('ASCEND',    '⬆️', 45, resource: _TabResource(             // stage 45 preview
    icon: '✦', color: Color(0xFFaa88ff), name: 'Asc. Points',
    sources: 'Earned by Ascending your hero',
  )),
];

Widget _buildScreen(int allTabIndex) => switch (allTabIndex) {
  0  => const DashboardScreen(embedded: true),
  1  => const HeroStatsScreen(embedded: true),       // BONUSES
  2  => const AbilityUpgradeScreen(embedded: true),
  3  => const AchievementScreen(),
  4  => const PassiveTreeScreen(embedded: true),
  5  => const EndlessUpgradeScreen(embedded: true),
  6  => const BestiaryScreen(),
  7  => const CodexScreen(embedded: true),
  8  => const NpcAllyScreen(embedded: true),
  9  => const PrestigeScreen(embedded: true),
  10 => const AscensionScreen(embedded: true),
  _  => const SizedBox.shrink(),
};

// ── Widget ────────────────────────────────────────────────────────────────────

class HeroHubScreen extends StatefulWidget {
  const HeroHubScreen({super.key, this.onBackToSelect});
  final VoidCallback? onBackToSelect;

  @override
  State<HeroHubScreen> createState() => _HeroHubScreenState();
}

class _HeroHubScreenState extends State<HeroHubScreen>
    with TickerProviderStateMixin {
  late TabController _ctrl;
  int _visibleCount = 0;

  // REBIRTH tab (index 9) only appears after the player's first prestige.
  // All other tabs unlock by campaign stage.
  List<int> _unlockedIndices(GameState game) => [
    for (int i = 0; i < _kAllTabs.length; i++)
      if (i == 9 || i == 10
          ? game.prestigeLevel > 0
          : i == 5
              ? (game.echoes > 0 || game.campaignStageIndex >= _kAllTabs[i].unlock)
              : game.campaignStageIndex >= _kAllTabs[i].unlock) i,
  ];

  void _rebuildController(int newCount) {
    final prev = _ctrl.index.clamp(0, newCount - 1);
    _ctrl.removeListener(_onTab);
    _ctrl.dispose();
    _ctrl = TabController(length: newCount, vsync: this)
      ..addListener(_onTab)
      ..index = prev;
    _visibleCount = newCount;
  }

  @override
  void initState() {
    super.initState();
    _ctrl = TabController(length: 1, vsync: this)
      ..addListener(_onTab);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final game = GameStateProvider.of(context);
    final indices = _unlockedIndices(game);
    final newCount = indices.isEmpty ? 1 : indices.length;
    if (newCount != _visibleCount) {
      _rebuildController(newCount);
    }
  }

  void _onTab() {
    if (!_ctrl.indexIsChanging) setState(() {});
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onTab);
    _ctrl.dispose();
    super.dispose();
  }

  static Widget _tabLabel(String label, String emoji,
      {bool badge = false, bool active = false}) {
    Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(emoji, style: TextStyle(fontSize: active ? 16 : 13)),
        const SizedBox(height: 2),
        Text(label,
            style: GoogleFonts.pixelifySans(
              fontSize: 9,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              letterSpacing: 1,
            )),
      ],
    );
    if (!badge) return Tab(height: 52, child: content);
    return Tab(
      height: 52,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          content,
          Positioned(
            top: 0,
            right: -6,
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: Color(0xFFFFCC44),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasBadge(int allTabIndex, GameState game) => switch (allTabIndex) {
    2 => game.hasAffordableAbilityUpgrade,
    3 => game.achievementsClaimable > 0,
    4 => game.hasAffordablePassiveNode,
    5 => game.hasAffordableEndlessUpgrade,
    8 => game.unlockedAllies.length < NpcAllyDef.all.length &&
         NpcAllyDef.all.any((a) => !game.allyUnlocked(a.id) &&
             game.allyMilestoneProgress(a) >= a.milestoneTarget),
    9  => game.canPrestige,
    10 => game.canAscend,
    _  => false,
  };

  @override
  Widget build(BuildContext context) {
    final game    = GameStateProvider.of(context);
    final indices = _unlockedIndices(game);

    if (indices.isEmpty) return const Scaffold(backgroundColor: AppTheme.darkBg, body: SizedBox.shrink());
    final visIdx = _ctrl.index.clamp(0, indices.length - 1);
    final allIdx = indices[visIdx];
    final resource = _kAllTabs[allIdx].resource;

    final tabs = [
      for (final i in indices)
        _tabLabel(
          _kAllTabs[i].label,
          _kAllTabs[i].emoji,
          badge: _hasBadge(i, game),
          active: i == allIdx,
        ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Text('HERO',
            style: AppTheme.pixelHeading(fontSize: 15, letterSpacing: 3)),
        actions: [
          if (widget.onBackToSelect != null)
            TextButton(
              onPressed: widget.onBackToSelect,
              child: Text('CHANGE',
                  style: AppTheme.pixelHeading(
                      fontSize: 10, color: AppTheme.textMuted, letterSpacing: 1)),
            ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _ctrl,
          tabs: tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppTheme.accentGold,
          unselectedLabelColor: AppTheme.textMuted,
          indicator: const GlowTabIndicator(),
          indicatorWeight: 3,
        ),
      ),
      body: Stack(children: [
        const AmbientParticles(count: 15, color: Color(0xFFdaa520)),
        HeroTabController(
        switchTo: (targetAllIdx) {
          // Accept all-tab index, map to visible index.
          final vi = indices.indexOf(targetAllIdx);
          if (vi >= 0) _ctrl.animateTo(vi);
        },
        child: Column(
          children: [
            if (resource != null) _ResourceBanner(resource: resource),
            Expanded(
              child: TabBarView(
                controller: _ctrl,
                children: [
                  for (final i in indices) _buildScreen(i),
                ],
              ),
            ),
          ],
        ),
      ),
      ]),
    );
  }
}

class _ResourceBanner extends StatelessWidget {
  const _ResourceBanner({required this.resource});
  final _TabResource resource;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: resource.color.withValues(alpha: 0.06),
        border: Border(
          bottom: BorderSide(color: resource.color.withValues(alpha: 0.18)),
        ),
      ),
      child: Row(
        children: [
          Text(resource.icon,
              style: GoogleFonts.pixelifySans(
                  fontSize: 11, fontWeight: FontWeight.bold, color: resource.color)),
          const SizedBox(width: 6),
          Text(resource.name.toUpperCase(),
              style: GoogleFonts.pixelifySans(
                  fontSize: 10, fontWeight: FontWeight.bold,
                  color: resource.color, letterSpacing: 1)),
          const SizedBox(width: 8),
          Expanded(
            child: Text('— ${resource.sources}',
                style: GoogleFonts.pixelifySans(fontSize: 10, color: Colors.white38),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
