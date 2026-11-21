import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/game_icons.dart';
import '../widgets/whats_new_sheet.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../core/routing/app_router.dart';
import 'main_shell.dart' show showLootLog;
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/ambient_particles.dart';
import '../widgets/currency_icon.dart';
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
import 'armory_screen.dart';
import 'quest_screen.dart';
import 'pet_screen.dart';
import 'elemental_mastery_screen.dart';
import '../l10n/app_localizations.dart';

// ── Tab definitions (all tabs, with unlock stage requirement) ─────────────────

class _TabResource {
  const _TabResource({required this.icon, required this.color,
      required this.name, required this.sources, this.currencyId});
  final GameIconType icon;
  final Color        color;
  final String       name;
  final String       sources;
  // When set, the banner shows the custom currency art instead of [icon].
  final String?      currencyId;
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
    icon: GameIconType.coin, color: Color(0xFFdaa520), name: 'Gold', currencyId: 'gold',
    sources: 'Every enemy kill & idle income · Expeditions · Dungeons · Events',
  )),
  _TabDef('ABILITIES',    GameIconType.swords,      2, resource: _TabResource(
    icon: GameIconType.diamond, color: Color(0xFF6699ff), name: 'Shards', currencyId: 'shards',
    sources: 'Enemy kills · Dungeons · Expeditions · Gauntlet',
  )),
  _TabDef('ACHIEVEMENTS', GameIconType.medal,       5),
  _TabDef('PASSIVES',     GameIconType.leaf,        8, resource: _TabResource(
    icon: GameIconType.diamond, color: Color(0xFF6699ff), name: 'Shards', currencyId: 'shards',
    sources: 'Enemy kills · Dungeons · Expeditions · Gauntlet',
  )),
  _TabDef('BONUSES',      GameIconType.barChart,   10),
  _TabDef('BESTIARY',     GameIconType.eyeMonster, 12),
  _TabDef('CODEX',        GameIconType.book,       15),
  _TabDef('PETS',         GameIconType.paw,        18, resource: _TabResource(
    icon: GameIconType.coin, color: Color(0xFF66aaff), name: 'ZCoins', currencyId: 'zcoins',
    sources: 'Premium shop · Login rewards · Season pass',
  )),
  _TabDef('MERCS',        GameIconType.warriors,   22, resource: _TabResource(
    icon: GameIconType.diamond, color: Color(0xFF6699ff), name: 'Shards + ZCoins', currencyId: 'shards',
    sources: 'Shards from kills/Dungeons; ZCoins from purchases, Bounties & streaks',
  )),
  // Unlocks at stage 100 (when Prestige first becomes available) and stays
  // unlocked forever after — effectiveUnlockStage latches to >=100 once you've
  // prestiged, so a post-rebirth stage reset can't hide it.
  _TabDef('PARAGON',      GameIconType.flame,       2, resource: _TabResource(
    icon: GameIconType.crown, color: Color(0xFFCBA05E), name: 'Paragon Points', currencyId: 'paragonPoints',
    sources: 'Earned by levelling up — 1 per level',
  )),
  _TabDef('UPGRADES',     GameIconType.gear,       45, resource: _TabResource(
    icon: GameIconType.bolt, color: Color(0xFFC6A6F2), name: 'Echoes', currencyId: 'echoes',
    sources: 'Challenge Gauntlet runs',
  )),
  _TabDef('ASCEND',       GameIconType.mountain,   50, resource: _TabResource(
    icon: GameIconType.star, color: Color(0xFFaa88ff), name: 'Asc. Points',
    sources: 'Earned by Ascending your hero',
  )),
  _TabDef('MASTERY',      GameIconType.crown,      38, resource: _TabResource(
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
  // Legendary/Set item catalogue. Appended last (index 16) to keep the
  // index-based _buildScreen mapping stable; lives in the COLLECTION group
  // alongside the other reference databases (Bestiary/Codex). Unlocks at
  // stage 28 (same gate as the Inventory-hub Armory tab).
  _TabDef('ARMORY',       GameIconType.shield,     28),
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
  16 => const ArmoryScreen(embedded: true),                // ARMORY (legendary/set catalogue)
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
      Color(0xFF66cc88), ['PETS', 'MERCS', 'BESTIARY', 'CODEX', 'ARMORY']),
  _HubGroup('RECORDS', 'Goals & breakdowns', GameIconType.medal,
      Color(0xFF66aaff), ['ACHIEVEMENTS', 'QUESTS', 'BONUSES']),
];

/// Localized display label for a hub tab ID. The English label stays the logic
/// key (used for nav requests, _buildScreen mapping, etc.) — we translate only
/// at the render point. Falls back to the raw id for any unmapped label.
String _hubTabLabel(AppLocalizations l, String id) => switch (id) {
      'SHEET' => l.hubSheet,
      'SCORES' => l.hubScores,
      'ABILITIES' => l.hubAbilities,
      'PASSIVES' => l.hubPassives,
      'SPECIALIZE' => l.hubSpecialize,
      'PARAGON' => l.hubParagon,
      'UPGRADES' => l.hubUpgrades,
      'ASCEND' => l.hubAscend,
      'MASTERY' => l.hubMastery,
      'PETS' => l.hubPets,
      'MERCS' => l.hubMercs,
      'BESTIARY' => l.hubBestiary,
      'CODEX' => l.hubCodex,
      'ARMORY' => l.hubArmory,
      'ACHIEVEMENTS' => l.hubAchievements,
      'BONUSES' => l.hubBonuses,
      'QUESTS' => l.modeQuests,
      _ => id,
    };

/// Localized group heading + blurb, keyed on the English group label.
String _hubGroupLabel(AppLocalizations l, String id) => switch (id) {
      'CHARACTER' => l.hubGroupCharacter,
      'PROGRESSION' => l.hubGroupProgression,
      'COLLECTION' => l.hubGroupCollection,
      'RECORDS' => l.hubGroupRecords,
      _ => id,
    };

int _allIndexOfLabel(String label) =>
    _kAllTabs.indexWhere((t) => t.label == label);

// ── Widget ────────────────────────────────────────────────────────────────────

class HeroHubScreen extends StatefulWidget {
  const HeroHubScreen({super.key, this.onBackToSelect});
  final VoidCallback? onBackToSelect;

  @override
  State<HeroHubScreen> createState() => _HeroHubScreenState();
}

class _HeroHubScreenState extends State<HeroHubScreen>
    with TickerProviderStateMixin {
  // Single grouped strip: one TabController over ALL unlocked tabs, ordered by
  // group (CHARACTER → PROGRESSION → COLLECTION → RECORDS). Group dividers +
  // captions render inline on each group's first tab, so the categories stay
  // visible without hiding their tabs behind a drill-in (the old grid's flaw).
  TabController? _ctrl;
  List<int> _ordered = const []; // unlocked all-tab indices, in grouped order

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

  /// Unlocked all-tab indices in grouped display order (group order, then each
  /// group's own tab order).
  List<int> _orderedUnlocked(GameState game) {
    final unlocked = _unlockedIndices(game).toSet();
    return [
      for (final grp in _kGroups)
        for (final lbl in grp.tabLabels)
          if (unlocked.contains(_allIndexOfLabel(lbl))) _allIndexOfLabel(lbl),
    ];
  }

  /// The group index that owns the tab at ordered-position [pos].
  int _groupOfOrdered(int pos) {
    final label = _kAllTabs[_ordered[pos]].label;
    for (int g = 0; g < _kGroups.length; g++) {
      if (_kGroups[g].tabLabels.contains(label)) return g;
    }
    return 0;
  }

  /// True when [pos] starts a new group — it gets the inline divider + caption.
  bool _firstOfGroup(int pos) =>
      pos == 0 || _groupOfOrdered(pos) != _groupOfOrdered(pos - 1);

  /// (Re)build the controller to match the current unlocked set, preserving the
  /// selected tab. [selectAllIdx] optionally jumps to a specific tab.
  void _ensureController(GameState game, {int? selectAllIdx}) {
    final ordered = _orderedUnlocked(game);
    if (ordered.isEmpty) {
      _ctrl?.removeListener(_onTab);
      _ctrl?.dispose();
      _ctrl = null;
      _ordered = const [];
      return;
    }
    int target = _ctrl?.index ?? 0;
    if (selectAllIdx != null) {
      final p = ordered.indexOf(selectAllIdx);
      if (p >= 0) target = p;
    }
    target = target.clamp(0, ordered.length - 1);
    if (_ctrl == null || _ctrl!.length != ordered.length) {
      _ctrl?.removeListener(_onTab);
      _ctrl?.dispose();
      _ctrl = TabController(
          length: ordered.length, vsync: this, initialIndex: target)
        ..addListener(_onTab);
    } else if (_ctrl!.index != target) {
      _ctrl!.index = target;
    }
    _ordered = ordered;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Keep the strip in sync as tabs unlock — the controller length tracks the
    // unlocked set and the selected tab is preserved.
    _ensureController(GameStateProvider.of(context));
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

  // Tab inner content (icon + label + optional badge dot). The Tab wrapper and
  // any group divider/caption are added by _stripTab.
  static Widget _tabInner(String label, GameIconType icon,
      {bool badge = false, bool active = false}) {
    final content = Column(
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
    if (!badge) return content;
    return Stack(
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
        tooltip: AppLocalizations.of(context).hubWhatsNew,
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

  List<Widget> _commonActions() {
    final game = GameStateProvider.of(context);
    return [
    // Loot log (moved here from the old global top bar).
    IconButton(
      tooltip: AppLocalizations.of(context).hubLootLog,
      icon: Stack(clipBehavior: Clip.none, children: [
        const Icon(Icons.inventory_2_outlined, size: 20),
        if (game.lootHistory.isNotEmpty)
          Positioned(top: -1, right: -1, child: Container(width: 7, height: 7,
            decoration: const BoxDecoration(color: Color(0xFFffcc44), shape: BoxShape.circle))),
      ]),
      onPressed: () => showLootLog(context, game),
    ),
    // Armory moved into the COLLECTION group (with Bestiary/Codex) — the old
    // redundant header shortcut was dropped to declutter the Hero header.
    IconButton(icon: const Icon(Icons.settings_outlined, size: 20), tooltip: AppLocalizations.of(context).hubSettings,
        onPressed: () => context.push(Routes.settings)),
    if (widget.onBackToSelect != null)
      TextButton(onPressed: widget.onBackToSelect,
          child: Text(AppLocalizations.of(context).hubChange, style: AppTheme.pixelHeading(
              fontSize: 10, color: AppTheme.textMuted, letterSpacing: 1))),
    const SizedBox(width: 4),
  ];
  }

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    _ensureController(game);
    final ctrl = _ctrl;
    if (ctrl == null || _ordered.isEmpty) {
      return const Scaffold(
          backgroundColor: AppTheme.darkBg, body: SizedBox.shrink());
    }
    final l = AppLocalizations.of(context);

    // Deep link (guided tutorials / cross-tab jumps): jump straight to the
    // requested tab in the single strip.
    final want =
        game.consumeNavRequestFor([for (final i in _ordered) _kAllTabs[i].label]);
    if (want != null) {
      final p = _ordered.indexOf(_allIndexOfLabel(want));
      if (p >= 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && (_ctrl?.length ?? 0) > p) {
            setState(() => _ctrl!.index = p);
          }
        });
      }
    }

    final visIdx = ctrl.index.clamp(0, _ordered.length - 1);
    final resource = _kAllTabs[_ordered[visIdx]].resource;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(l.navHero, style: AppTheme.pixelHeading(fontSize: 15, letterSpacing: 3)),
          const SizedBox(width: 14),
          _whatsNewButton(game),
          const SizedBox(width: 2),
          _SocialButton(icon: Icons.discord, tooltip: l.hubJoinDiscord,
              url: 'https://discord.gg/F5WcvsZV9W'),
          const SizedBox(width: 4),
          _SocialButton(icon: Icons.reddit, tooltip: l.hubVisitReddit,
              url: 'https://www.reddit.com/r/zeta_idle/'),
        ]),
        actions: _commonActions(),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
              PointerDeviceKind.mouse,
              PointerDeviceKind.touch,
              PointerDeviceKind.trackpad,
            }),
            child: TabBar(
              controller: ctrl,
              tabs: [for (int p = 0; p < _ordered.length; p++) _stripTab(game, p)],
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
            final p = _ordered.indexOf(targetAllIdx);
            if (p >= 0) setState(() => ctrl.index = p);
          },
          child: Column(children: [
            if (resource != null) _ResourceBanner(resource: resource),
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.touch,
                  PointerDeviceKind.trackpad,
                }),
                child: TabBarView(
                  controller: ctrl,
                  // The next-goal + Season Pass nudges render INSIDE the SHEET's
                  // own scroll (passed as topBanners) rather than pinned above the
                  // tab strip, so they scroll with the content instead of staying
                  // frozen at the top.
                  children: [
                    for (final i in _ordered)
                      i == 0
                          ? DashboardScreen(
                              embedded: true, topBanners: _sheetBanners(game))
                          : _buildScreen(i),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  /// The SHEET tab's scrollable nudges (next goal + Season Pass), rendered
  /// inside DashboardScreen's own scroll so they scroll with the sheet instead
  /// of staying pinned above the tab strip.
  List<Widget> _sheetBanners(GameState game) => [
    if (game.nextGoal != null) ...[
      _nextGoalBanner(game),
      const SizedBox(height: 12),
    ],
    if (game.effectiveUnlockStage >= 5) ...[
      _seasonPassBanner(game),
      const SizedBox(height: 12),
    ],
  ];

  /// One tab in the single strip. Each group's first tab carries an inline
  /// divider + small group caption, so the strip reads as grouped categories
  /// without hiding any tab behind a drill-in.
  Widget _stripTab(GameState game, int pos) {
    final l = AppLocalizations.of(context);
    final allIdx = _ordered[pos];
    final active = pos == (_ctrl?.index ?? 0);
    final inner = _tabInner(
        _hubTabLabel(l, _kAllTabs[allIdx].label), _kAllTabs[allIdx].icon,
        badge: _hasBadge(allIdx, game), active: active);
    if (!_firstOfGroup(pos)) return Tab(height: 52, child: inner);
    final grp = _kGroups[_groupOfOrdered(pos)];
    return Tab(
      height: 52,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (pos != 0) ...[
          Container(
              width: 1, height: 28, color: grp.color.withValues(alpha: 0.45)),
          const SizedBox(width: 10),
        ],
        Text(_hubGroupLabel(l, grp.label),
            style: AppTheme.pixelHeading(
                fontSize: 8, color: grp.color, letterSpacing: 1)),
        const SizedBox(width: 10),
        inner,
      ]),
    );
  }

  /// "Next goal" nudge — the nearest upcoming unlock milestone + progress bar,
  /// taps into battle. Gives every session a visible target.
  Widget _nextGoalBanner(GameState game) {
    final goal = game.nextGoal;
    if (goal == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    const gold = AppTheme.accentGold;

    final current = game.campaignStageIndex;
    final span = (goal.toStage - goal.fromStage).clamp(1, 1 << 30);
    final progress = ((current - goal.fromStage) / span).clamp(0.0, 1.0);
    final remaining = (goal.toStage - current).clamp(0, 1 << 30);

    return Material(
      color: gold.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => context.push(Routes.battle),
        borderRadius: BorderRadius.circular(10),
        splashColor: gold.withValues(alpha: 0.15),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: gold.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                const Text('🎯', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l.homeNextGoal(goal.reward),
                      style: AppTheme.pixelHeading(
                          fontSize: 10, letterSpacing: 1, color: gold)),
                ),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  backgroundColor: AppTheme.darkBg,
                  valueColor: const AlwaysStoppedAnimation<Color>(gold),
                ),
              ),
              const SizedBox(height: 6),
              Text(l.homeNextGoalProgress(remaining, goal.stage),
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
            ],
          ),
        ),
      ),
    );
  }

  /// Compact Season Pass banner on the hub landing — tier, progress toward the
  /// next tier, an unclaimed-rewards badge, and a Premium hint. Taps through to
  /// the full two-track ladder. Gold-accented to read as a headline feature.
  Widget _seasonPassBanner(GameState game) {
    final l = AppLocalizations.of(context);
    final unclaimed = game.seasonUnclaimedCount;
    const gold = AppTheme.accentGold;
    return Material(
      color: gold.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => context.push(Routes.seasonPass),
        borderRadius: BorderRadius.circular(10),
        splashColor: gold.withValues(alpha: 0.15),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: gold.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const GameIcon(GameIconType.crown, size: 26, color: gold),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(children: [
                      Text(l.homeNavSeasonPass,
                          style: AppTheme.pixelHeading(
                              fontSize: 13, letterSpacing: 2, color: gold)),
                      const SizedBox(width: 8),
                      Text('${l.spTier} ${game.seasonPassTier}',
                          style: GoogleFonts.rajdhani(
                              fontSize: 12, color: Colors.white70,
                              fontWeight: FontWeight.w600)),
                      if (!game.hasPremium) ...[
                        const Spacer(),
                        Text(l.spPremium,
                            style: const TextStyle(
                                fontSize: 10, color: AppTheme.textMuted)),
                      ],
                    ]),
                    const SizedBox(height: 7),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: game.seasonTierProgress,
                        minHeight: 6,
                        backgroundColor: AppTheme.darkBg,
                        valueColor: const AlwaysStoppedAnimation<Color>(gold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (unclaimed > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFCC44),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$unclaimed',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold,
                          color: Color(0xFF17150E))),
                )
              else
                const Icon(Icons.chevron_right, size: 20, color: AppTheme.textMuted),
            ],
          ),
        ),
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
          resource.currencyId != null
              ? CurrencyIcon(id: resource.currencyId!, size: 15)
              : GameIcon(resource.icon, size: 13, color: resource.color),
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
              SnackBar(content: Text(AppLocalizations.of(context).hubCouldNotOpen(url))),
            );
          }
        }
      },
    );
  }
}
