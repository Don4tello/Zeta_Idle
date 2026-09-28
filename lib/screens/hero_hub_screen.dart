import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/game_icons.dart';
import '../widgets/whats_new_sheet.dart';
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
import 'subclass_screen.dart';
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
import 'quest_screen.dart';
import 'pet_screen.dart';
import 'elemental_mastery_screen.dart';

// ── Tab definitions (all tabs, with unlock stage requirement) ─────────────────

class _TabResource {
  const _TabResource({required this.icon, required this.color,
      required this.name, required this.sources});
  final GameIconType icon;
  final Color        color;
  final String       name;
  final String       sources;
}

class _TabDef {
  const _TabDef(this.label, this.icon, this.unlock, {this.resource});
  final String        label;
  final GameIconType  icon;
  final int           unlock; // campaignStageIndex required to show this tab
  final _TabResource? resource;
}

// Master list: order = display order, unlock = stage required.
const _kAllTabs = <_TabDef>[
  _TabDef('SHEET',        GameIconType.armor,      0),
  _TabDef('SCORES',       GameIconType.star,        4, resource: _TabResource(
    icon: GameIconType.coin, color: Color(0xFFdaa520), name: 'Gold',
    sources: 'Every enemy kill & idle income · Expeditions · Dungeons · Events',
  )),
  _TabDef('ABILITIES',    GameIconType.swords,      2, resource: _TabResource(
    icon: GameIconType.diamond, color: Color(0xFF44ccff), name: 'Shards',
    sources: 'Enemy kills · Dungeons · Expeditions · Gauntlet',
  )),
  _TabDef('ACHIEVEMENTS', GameIconType.medal,       5),
  _TabDef('PASSIVES',     GameIconType.leaf,        8, resource: _TabResource(
    icon: GameIconType.diamond, color: Color(0xFF6699ff), name: 'Shards',
    sources: 'Enemy kills · Dungeons · Expeditions · Gauntlet',
  )),
  _TabDef('BONUSES',      GameIconType.barChart,   10),
  _TabDef('BESTIARY',     GameIconType.eyeMonster, 12),
  _TabDef('CODEX',        GameIconType.book,       15),
  _TabDef('PETS',         GameIconType.paw,        18, resource: _TabResource(
    icon: GameIconType.coin, color: Color(0xFF66aaff), name: 'ZCoins',
    sources: 'Premium shop · Login rewards · Season pass',
  )),
  _TabDef('MERCS',        GameIconType.warriors,   22, resource: _TabResource(
    icon: GameIconType.diamond, color: Color(0xFF6699ff), name: 'Shards + ZCoins',
    sources: 'Shards from kills/Dungeons; ZCoins from purchases, Bounties & streaks',
  )),
  // Unlocks at stage 100 (when Prestige first becomes available) and stays
  // unlocked forever after — effectiveUnlockStage latches to >=100 once you've
  // prestiged, so a post-rebirth stage reset can't hide it.
  _TabDef('PARAGON',      GameIconType.flame,       2, resource: _TabResource(
    icon: GameIconType.crown, color: Color(0xFFcc8844), name: 'Paragon Points',
    sources: 'Earned by levelling up — 1 per level',
  )),
  _TabDef('UPGRADES',     GameIconType.gear,       45, resource: _TabResource(
    icon: GameIconType.bolt, color: Color(0xFFcc88ff), name: 'Echoes',
    sources: 'Challenge Gauntlet runs',
  )),
  _TabDef('ASCEND',       GameIconType.mountain,   50, resource: _TabResource(
    icon: GameIconType.star, color: Color(0xFFaa88ff), name: 'Asc. Points',
    sources: 'Earned by Ascending your hero',
  )),
  _TabDef('MASTERY',      GameIconType.crown,      35, resource: _TabResource(
    icon: GameIconType.flask, color: Color(0xFFff8844), name: 'Tower Shards',
    sources: 'Tower Ascension runs',
  )),
  // Level-50 specialization (gated by hero level, not campaign stage — see
  // the special case in _unlockedIndices). Appended last so the index-based
  // _buildScreen mapping below stays stable.
  _TabDef('SPECIALIZE',   GameIconType.medal,     999),
  // Moved here from the PLAY tab. Appended last to keep the index-based
  // _buildScreen mapping stable; unlocks at campaign stage 10 as before.
  _TabDef('QUESTS',       GameIconType.book,       10),
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
  14 => const SubclassScreen(embedded: true),              // SPECIALIZE
  15 => const QuestScreen(),                               // QUESTS (moved from PLAY)
  _  => const SizedBox.shrink(),
};

// ── Hub landing groups (Option C: a category grid that opens sub-menus) ────────
// Each group bundles a set of the tabs above by their label. The 16-tab flat
// scroller is replaced by a 2×2 landing grid → tap a category → that group's
// (much shorter) tab strip. Deep links / tutorials still work: we find the tab's
// group and open it there.

class _HubGroup {
  const _HubGroup(this.label, this.blurb, this.icon, this.color, this.tabLabels);
  final String        label;
  final String        blurb;
  final GameIconType  icon;
  final Color         color;
  final List<String>  tabLabels; // labels from _kAllTabs, in display order
}

const _kGroups = <_HubGroup>[
  _HubGroup('CHARACTER', 'Your build & power', GameIconType.armor,
      Color(0xFFdaa520), ['SHEET', 'SCORES', 'ABILITIES', 'PASSIVES', 'SPECIALIZE']),
  _HubGroup('PROGRESSION', 'Endgame systems', GameIconType.mountain,
      Color(0xFFaa88ff), ['PARAGON', 'UPGRADES', 'ASCEND', 'MASTERY']),
  _HubGroup('COLLECTION', 'Allies & compendium', GameIconType.paw,
      Color(0xFF66cc88), ['PETS', 'MERCS', 'BESTIARY', 'CODEX']),
  _HubGroup('RECORDS', 'Goals & breakdowns', GameIconType.medal,
      Color(0xFF66aaff), ['ACHIEVEMENTS', 'QUESTS', 'BONUSES']),
];

int _allIndexOfLabel(String label) =>
    _kAllTabs.indexWhere((t) => t.label == label);

/// The group index that owns a given all-tab index (-1 if none).
int _groupOfAllIndex(int allIdx) {
  if (allIdx < 0) return -1;
  final label = _kAllTabs[allIdx].label;
  for (int g = 0; g < _kGroups.length; g++) {
    if (_kGroups[g].tabLabels.contains(label)) return g;
  }
  return -1;
}

// ── Widget ────────────────────────────────────────────────────────────────────

class HeroHubScreen extends StatefulWidget {
  const HeroHubScreen({super.key, this.onBackToSelect});
  final VoidCallback? onBackToSelect;

  @override
  State<HeroHubScreen> createState() => _HeroHubScreenState();
}

class _HeroHubScreenState extends State<HeroHubScreen>
    with TickerProviderStateMixin {
  // Option C: null = the category landing grid; otherwise the open group index.
  int? _group;
  List<int> _groupIndices = const []; // open group's UNLOCKED all-tab indices
  TabController? _ctrl;               // only alive while a group is open

  // New indices: REBIRTH=8, UPGRADES=9(echoes gate), ASCEND=10(prestige gate)
  List<int> _unlockedIndices(GameState game) {
    final pl = game.confirmedPrestigeLevel > game.prestigeLevel
        ? game.confirmedPrestigeLevel
        : game.prestigeLevel;
    return [
      for (int i = 0; i < _kAllTabs.length; i++)
        // ASCEND (12) is hidden during the tier rework — a new ascension path is
        // coming; until then the tab is suppressed everywhere.
        if (i != 12 && (game.endgameUnlocked
            || (i == 12                          // ASCEND: needs prestige
                ? pl > 0
                : i == 11                        // UPGRADES: latches once you can spend echoes
                    ? game.upgradesTabUnlocked
                    : i == 13                    // MASTERY: latches once you can afford an upgrade
                        ? game.masteryTabUnlocked
                        : i == 14                // SPECIALIZE: hero level 50
                            ? game.subclassUnlocked
                            : i == 10            // PARAGON: revealed at hero level 10
                                ? game.hero.level >= 10
                                : game.effectiveUnlockStage >= _kAllTabs[i].unlock))) i,
    ];
  }

  /// The UNLOCKED all-tab indices inside [g], in the group's display order.
  List<int> _groupUnlockedIndices(int g, GameState game) {
    final unlocked = _unlockedIndices(game).toSet();
    return [
      for (final lbl in _kGroups[g].tabLabels)
        if (unlocked.contains(_allIndexOfLabel(lbl))) _allIndexOfLabel(lbl),
    ];
  }

  bool _groupHasBadge(int g, GameState game) =>
      _groupUnlockedIndices(g, game).any((i) => _hasBadge(i, game));

  /// Open a group's tab strip. [tabAllIdx] optionally selects a specific tab.
  void _openGroup(int g, GameState game, {int? tabAllIdx}) {
    final indices = _groupUnlockedIndices(g, game);
    if (indices.isEmpty) return;
    var start = 0;
    if (tabAllIdx != null) {
      final p = indices.indexOf(tabAllIdx);
      if (p >= 0) start = p;
    }
    _ctrl?.removeListener(_onTab);
    _ctrl?.dispose();
    _ctrl = TabController(length: indices.length, vsync: this, initialIndex: start)
      ..addListener(_onTab);
    setState(() {
      _group = g;
      _groupIndices = indices;
    });
  }

  void _backToHub() {
    _ctrl?.removeListener(_onTab);
    _ctrl?.dispose();
    _ctrl = null;
    setState(() {
      _group = null;
      _groupIndices = const [];
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // While a group is open, keep its tab strip in sync as tabs unlock — and
    // fall back to the hub if the group ever empties out.
    final g = _group;
    if (g != null) {
      final game = GameStateProvider.of(context);
      final indices = _groupUnlockedIndices(g, game);
      if (indices.isEmpty) {
        _backToHub();
      } else if (indices.length != (_ctrl?.length ?? 0)) {
        final prev = (_ctrl?.index ?? 0).clamp(0, indices.length - 1);
        _ctrl?.removeListener(_onTab);
        _ctrl?.dispose();
        _ctrl = TabController(length: indices.length, vsync: this, initialIndex: prev)
          ..addListener(_onTab);
        _groupIndices = indices;
      }
    }
  }

  void _onTab() {
    if (!(_ctrl?.indexIsChanging ?? true)) setState(() {});
  }

  @override
  void dispose() {
    _ctrl?.removeListener(_onTab);
    _ctrl?.dispose();
    super.dispose();
  }

  static Widget _tabLabel(String label, GameIconType icon,
      {bool badge = false, bool active = false}) {
    Widget content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GameIcon(icon, size: active ? 16 : 13,
            color: active ? AppTheme.accentGold : AppTheme.textMuted),
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
    9  => game.hasAffordableAllyUpgrade ||      // MERCS (upgrade ready, expedition ready, or new merc unlock)
          game.hasReadyExpedition ||
          (game.unlockedAllies.length < NpcAllyDef.all.length &&
           NpcAllyDef.all.any((a) => !game.allyUnlocked(a.id) &&
               game.allyMilestoneProgress(a) >= a.milestoneTarget)),
    10 => game.canPrestige,                    // REBIRTH
    11 => game.hasAffordableEndlessUpgrade,    // UPGRADES
    12 => game.canAscend,                      // ASCEND
    13 => game.hasAffordableElementalMastery,  // MASTERY
    _  => false,
  };

  // ── Shared app-bar pieces (used by both the hub grid and a group view) ─────
  Widget _whatsNewButton(GameState game) => Stack(
    clipBehavior: Clip.none,
    children: [
      IconButton(
        icon: const Icon(Icons.campaign_outlined, size: 20, color: AppTheme.accentGold),
        tooltip: "What's New",
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: EdgeInsets.zero,
        onPressed: () { game.markPatchNotesSeen(); showWhatsNew(context); },
      ),
      if (game.hasUnseenPatchNotes)
        Positioned(right: 4, top: 6, child: Container(width: 8, height: 8,
          decoration: const BoxDecoration(color: Color(0xFFff5544), shape: BoxShape.circle))),
    ],
  );

  List<Widget> _commonActions() => [
    IconButton(icon: const Icon(Icons.shield_outlined, size: 20), tooltip: 'Armory',
        onPressed: () => context.push(Routes.armory)),
    IconButton(icon: const Icon(Icons.settings_outlined, size: 20), tooltip: 'Settings',
        onPressed: () => context.push(Routes.settings)),
    if (widget.onBackToSelect != null)
      TextButton(onPressed: widget.onBackToSelect,
          child: Text('CHANGE', style: AppTheme.pixelHeading(
              fontSize: 10, color: AppTheme.textMuted, letterSpacing: 1))),
    const SizedBox(width: 4),
  ];

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);

    // Deep link (guided tutorials / cross-tab jumps): if a request names an
    // unlocked tab, open ITS GROUP at that tab.
    final unlocked = _unlockedIndices(game);
    final want = game.consumeNavRequestFor([for (final i in unlocked) _kAllTabs[i].label]);
    if (want != null) {
      final allIdx = _allIndexOfLabel(want);
      final g = _groupOfAllIndex(allIdx);
      if (g >= 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _openGroup(g, game, tabAllIdx: allIdx);
        });
      }
    }

    return _group == null ? _buildHub(game) : _buildGroup(game);
  }

  // ── Landing: 2×2 category grid ─────────────────────────────────────────────
  Widget _buildHub(GameState game) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('HERO', style: AppTheme.pixelHeading(fontSize: 15, letterSpacing: 3)),
          const SizedBox(width: 14),
          _whatsNewButton(game),
          const SizedBox(width: 2),
          _SocialButton(icon: Icons.discord, tooltip: 'Join our Discord',
              url: 'https://discord.gg/F5WcvsZV9W'),
          const SizedBox(width: 4),
          _SocialButton(icon: Icons.reddit, tooltip: 'Visit r/zeta_idle',
              url: 'https://www.reddit.com/r/zeta_idle/'),
        ]),
        actions: _commonActions(),
      ),
      body: Stack(children: [
        Builder(builder: (ctx) {
          final reduced = GameStateProvider.of(ctx).reducedParticles;
          return AmbientParticles(count: reduced ? 4 : 15, color: const Color(0xFFdaa520));
        }),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.02,
              children: [for (int g = 0; g < _kGroups.length; g++) _groupCard(g, game)],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _groupCard(int g, GameState game) {
    final grp = _kGroups[g];
    final indices = _groupUnlockedIndices(g, game);
    final enabled = indices.isNotEmpty;
    final badge = enabled && _groupHasBadge(g, game);
    final names = indices.map((i) => _kAllTabs[i].label.toLowerCase()).join(' · ');
    return Opacity(
      opacity: enabled ? 1.0 : 0.35,
      child: GestureDetector(
        onTap: enabled ? () => _openGroup(g, game) : null,
        child: Container(
          decoration: BoxDecoration(
            color: grp.color.withValues(alpha: 0.07),
            border: Border.all(color: grp.color.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(14),
          child: Stack(children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GameIcon(grp.icon, size: 32, color: grp.color),
                const Spacer(),
                Text(grp.label, style: AppTheme.pixelHeading(
                    fontSize: 13, color: grp.color, letterSpacing: 2)),
                const SizedBox(height: 3),
                Text(grp.blurb, style: GoogleFonts.rajdhani(
                    fontSize: 11, color: Colors.white54)),
                const SizedBox(height: 6),
                Text(enabled ? names : 'Locked',
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.rajdhani(
                        fontSize: 10, color: Colors.white30, letterSpacing: 0.5)),
              ],
            ),
            if (badge)
              Positioned(top: 0, right: 0, child: Container(width: 9, height: 9,
                decoration: const BoxDecoration(
                    color: Color(0xFFFFCC44), shape: BoxShape.circle))),
          ]),
        ),
      ),
    );
  }

  // ── Group: the (short) tab strip for one category ──────────────────────────
  Widget _buildGroup(GameState game) {
    final indices = _groupIndices;
    final ctrl = _ctrl;
    if (indices.isEmpty || ctrl == null) return _buildHub(game);
    final visIdx = ctrl.index.clamp(0, indices.length - 1);
    final allIdx = indices[visIdx];
    final resource = _kAllTabs[allIdx].resource;
    final grp = _kGroups[_group!];

    final tabs = [
      for (final i in indices)
        _tabLabel(_kAllTabs[i].label, _kAllTabs[i].icon,
            badge: _hasBadge(i, game), active: i == allIdx),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) { if (!didPop) _backToHub(); },
      child: Scaffold(
        backgroundColor: AppTheme.darkBg,
        appBar: AppBar(
          titleSpacing: 4,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            tooltip: 'Hero menu',
            onPressed: _backToHub,
          ),
          title: Row(mainAxisSize: MainAxisSize.min, children: [
            GameIcon(grp.icon, size: 15, color: grp.color),
            const SizedBox(width: 8),
            Text(grp.label, style: AppTheme.pixelHeading(
                fontSize: 14, letterSpacing: 2, color: grp.color)),
          ]),
          actions: _commonActions(),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
                PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.trackpad,
              }),
              child: TabBar(
                controller: ctrl,
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
              final tg = _groupOfAllIndex(targetAllIdx);
              if (tg >= 0) _openGroup(tg, game, tabAllIdx: targetAllIdx);
            },
            child: Column(children: [
              if (resource != null) _ResourceBanner(resource: resource),
              Expanded(
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
                    PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.trackpad,
                  }),
                  child: TabBarView(
                    controller: ctrl,
                    children: [for (final i in indices) _buildScreen(i)],
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
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
          GameIcon(resource.icon, size: 13, color: resource.color),
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

/// Small brand-gold social link button for the Hero header (Discord / Reddit).
class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.icon, required this.tooltip, required this.url});
  final IconData icon;
  final String tooltip;
  final String url;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20, color: AppTheme.accentGold),
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      padding: EdgeInsets.zero,
      onPressed: () async {
        final uri = Uri.parse(url);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not open $url')),
            );
          }
        }
      },
    );
  }
}
