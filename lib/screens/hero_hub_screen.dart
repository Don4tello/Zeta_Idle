import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../core/routing/app_router.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/ambient_particles.dart';
import '../widgets/glow_tab_indicator.dart';
import '../widgets/hero_tab_controller.dart';
import 'dashboard_screen.dart';
import 'ability_scores_screen.dart';
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
import 'pet_screen.dart';
import 'elemental_mastery_screen.dart';

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
  _TabDef('SHEET',        '🧙',  0),   // always — character identity
  _TabDef('SCORES',       '⭐',  1),   // first progression unlock — gold upgrade
  _TabDef('ABILITIES',    '⚔️',  2, resource: _TabResource(  // after 2nd kill — have shards
    icon: '◆', color: Color(0xFF44ccff), name: 'Shards',
    sources: 'Dungeon runs · Locked Chests · Treasure rooms',
  )),
  _TabDef('ACHIEVEMENTS', '🏆',  5),   // first boss defeated
  _TabDef('PASSIVES',     '🌿',  8, resource: _TabResource(  // essence flowing
    icon: '✦', color: Color(0xFF44dd88), name: 'Essence',
    sources: 'Campaign kills · Gauntlet runs · Daily rewards',
  )),
  _TabDef('BONUSES',      '📊', 10),   // boss 2 — stats diverging
  _TabDef('BESTIARY',     '🐉', 12),   // enough entries to be useful
  _TabDef('CODEX',        '📖', 15),   // dungeon unlocked — need the reference
  _TabDef('PETS',         '🐾', 18, resource: _TabResource( // mid-game companion unlock
    icon: '🪙', color: Color(0xFF66aaff), name: 'ZCoins',
    sources: 'Premium shop · Login rewards · Season pass',
  )),
  _TabDef('MERCS',        '🤝', 20),   // boss 4 — NPC encounters begin
  _TabDef('REBIRTH',      '✦',  25, resource: _TabResource(  // rebirth gate
    icon: '☠', color: Color(0xFFcc8844), name: 'Souls',
    sources: 'Earned by Prestiging your hero',
  )),
  _TabDef('UPGRADES',     '🔮', 45, resource: _TabResource(  // gauntlet echoes
    icon: '🔊', color: Color(0xFFcc88ff), name: 'Echoes',
    sources: 'Challenge Gauntlet runs',
  )),
  _TabDef('ASCEND',       '⬆️', 50, resource: _TabResource( // post first rebirth
    icon: '✦', color: Color(0xFFaa88ff), name: 'Asc. Points',
    sources: 'Earned by Ascending your hero',
  )),
  _TabDef('MASTERY', '🔥', 15, resource: _TabResource(  // unlocks with Codex — elemental system
    icon: '🔷', color: Color(0xFFff8844), name: 'Elemental Cores',
    sources: 'Campaign first-clears (+2 normal, +5 boss)',
  )),
];

Widget _buildScreen(int allTabIndex) => switch (allTabIndex) {
  0  => const DashboardScreen(embedded: true),             // SHEET
  1  => const AbilityScoresScreen(embedded: true),         // SCORES
  2  => const AbilityUpgradeScreen(embedded: true),        // ABILITIES
  3  => const AchievementScreen(),                         // ACHIEVEMENTS
  4  => const PassiveTreeScreen(embedded: true),           // PASSIVES
  5  => const HeroStatsScreen(embedded: true),             // BONUSES
  6  => const BestiaryScreen(),                            // BESTIARY
  7  => const CodexScreen(embedded: true),                 // CODEX
  8  => const PetScreen(embedded: true),                   // PETS
  9  => const NpcAllyScreen(embedded: true),               // MERCS
  10 => const PrestigeScreen(embedded: true),              // REBIRTH
  11 => const EndlessUpgradeScreen(embedded: true),        // UPGRADES
  12 => const AscensionScreen(embedded: true),             // ASCEND
  13 => const ElementalMasteryScreen(embedded: true),      // MASTERY
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

  // New indices: REBIRTH=8, UPGRADES=9(echoes gate), ASCEND=10(prestige gate)
  List<int> _unlockedIndices(GameState game) => [
    for (int i = 0; i < _kAllTabs.length; i++)
      if (i == 12                              // ASCEND: needs prestige
          ? game.prestigeLevel > 0
          : i == 11                            // UPGRADES: echoes OR stage 45
              ? (game.echoes > 0 || game.effectiveUnlockStage >= _kAllTabs[i].unlock)
              : game.effectiveUnlockStage >= _kAllTabs[i].unlock) i,
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
            style: GoogleFonts.rajdhani(
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
    1  => game.hasAffordableAbilityScore,      // SCORES
    2  => game.hasAffordableAbilityUpgrade,    // ABILITIES
    3  => game.achievementsClaimable > 0,      // ACHIEVEMENTS
    4  => game.hasAffordablePassiveNode,        // PASSIVES
    8  => game.hasAffordablePet,               // PETS
    9  => game.hasReadyExpedition ||           // MERCS (expedition ready or new merc unlock)
          (game.unlockedAllies.length < NpcAllyDef.all.length &&
           NpcAllyDef.all.any((a) => !game.allyUnlocked(a.id) &&
               game.allyMilestoneProgress(a) >= a.milestoneTarget)),
    10 => game.canPrestige,                    // REBIRTH
    11 => game.hasAffordableEndlessUpgrade,    // UPGRADES
    12 => game.canAscend,                      // ASCEND
    13 => game.hasAffordableElementalMastery,  // MASTERY
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
          IconButton(
            icon: const Icon(Icons.shield_outlined, size: 20),
            tooltip: 'Armory',
            onPressed: () => context.push(Routes.armory),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 20),
            tooltip: 'Settings',
            onPressed: () => context.push(Routes.settings),
          ),
          if (widget.onBackToSelect != null)
            TextButton(
              onPressed: widget.onBackToSelect,
              child: Text('CHANGE',
                  style: AppTheme.pixelHeading(
                      fontSize: 10, color: AppTheme.textMuted, letterSpacing: 1)),
            ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.mouse,
                PointerDeviceKind.touch,
                PointerDeviceKind.trackpad,
              },
            ),
            child: TabBar(
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
        ),
      ),
      body: Stack(children: [
        Builder(builder: (ctx) {
          final reduced = GameStateProvider.of(ctx).reducedParticles;
          return AmbientParticles(count: reduced ? 4 : 15, color: const Color(0xFFdaa520));
        }),
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
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.touch,
                    PointerDeviceKind.trackpad,
                  },
                ),
                child: TabBarView(
                  controller: _ctrl,
                  children: [
                    for (final i in indices) _buildScreen(i),
                  ],
                ),
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
              style: GoogleFonts.rajdhani(
                  fontSize: 11, fontWeight: FontWeight.bold, color: resource.color)),
          const SizedBox(width: 6),
          Text(resource.name.toUpperCase(),
              style: GoogleFonts.rajdhani(
                  fontSize: 10, fontWeight: FontWeight.bold,
                  color: resource.color, letterSpacing: 1)),
          const SizedBox(width: 8),
          Expanded(
            child: Text('— ${resource.sources}',
                style: GoogleFonts.rajdhani(fontSize: 10, color: Colors.white38),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
