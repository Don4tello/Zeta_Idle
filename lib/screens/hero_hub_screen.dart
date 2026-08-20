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
  _TabDef('SCORES',       GameIconType.star,        1),
  _TabDef('ABILITIES',    GameIconType.swords,      2, resource: _TabResource(
    icon: GameIconType.diamond, color: Color(0xFF44ccff), name: 'Shards',
    sources: 'Dungeon runs · Locked Chests · Treasure rooms',
  )),
  _TabDef('ACHIEVEMENTS', GameIconType.medal,       5),
  _TabDef('PASSIVES',     GameIconType.leaf,        8, resource: _TabResource(
    icon: GameIconType.diamond, color: Color(0xFF6699ff), name: 'Shards',
    sources: 'Kills · Dungeons · Expeditions · Gauntlet',
  )),
  _TabDef('BONUSES',      GameIconType.barChart,   10),
  _TabDef('BESTIARY',     GameIconType.eyeMonster, 12),
  _TabDef('CODEX',        GameIconType.book,       15),
  _TabDef('PETS',         GameIconType.paw,        18, resource: _TabResource(
    icon: GameIconType.coin, color: Color(0xFF66aaff), name: 'ZCoins',
    sources: 'Premium shop · Login rewards · Season pass',
  )),
  _TabDef('MERCS',        GameIconType.warriors,   22),
  // Unlocks at stage 100 (when Prestige first becomes available) and stays
  // unlocked forever after — effectiveUnlockStage latches to >=100 once you've
  // prestiged, so a post-rebirth stage reset can't hide it.
  _TabDef('REBIRTH',      GameIconType.flame,     100, resource: _TabResource(
    icon: GameIconType.crown, color: Color(0xFFcc8844), name: 'Paragon Points',
    sources: 'Earned by Prestiging your hero',
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
  List<int> _unlockedIndices(GameState game) {
    final pl = game.confirmedPrestigeLevel > game.prestigeLevel
        ? game.confirmedPrestigeLevel
        : game.prestigeLevel;
    return [
      for (int i = 0; i < _kAllTabs.length; i++)
        // Endgame (any Rebirth or Ascension AP) keeps every tab unlocked.
        if (game.endgameUnlocked
            || (i == 12                          // ASCEND: needs prestige
                ? pl > 0
                : i == 11                        // UPGRADES: latches once you can spend echoes
                    ? game.upgradesTabUnlocked
                    : i == 13                    // MASTERY: latches once you can afford an upgrade
                        ? game.masteryTabUnlocked
                        : i == 14                // SPECIALIZE: hero level 50
                            ? game.subclassUnlocked
                            : game.effectiveUnlockStage >= _kAllTabs[i].unlock)) i,
    ];
  }

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
          _kAllTabs[i].icon,
          badge: _hasBadge(i, game),
          active: i == allIdx,
        ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('HERO',
                style: AppTheme.pixelHeading(fontSize: 15, letterSpacing: 3)),
            const SizedBox(width: 14),
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.campaign_outlined, size: 20,
                      color: AppTheme.accentGold),
                  tooltip: "What's New",
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    game.markPatchNotesSeen();
                    showWhatsNew(context);
                  },
                ),
                if (game.hasUnseenPatchNotes)
                  Positioned(
                    right: 4, top: 6,
                    child: Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFff5544), shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 2),
            _SocialButton(
              icon: Icons.discord,
              tooltip: 'Join our Discord',
              url: 'https://discord.gg/F5WcvsZV9W',
            ),
            const SizedBox(width: 4),
            _SocialButton(
              icon: Icons.reddit,
              tooltip: 'Visit r/zeta_idle',
              url: 'https://www.reddit.com/r/zeta_idle/',
            ),
          ],
        ),
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
