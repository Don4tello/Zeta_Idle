import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/hero_model.dart' show HeroGender;
import '../../screens/character_select_screen.dart';
import '../../screens/main_shell.dart';
import '../../screens/campaign_screen.dart';
import '../../screens/endless_screen.dart';
import '../../screens/daily_screen.dart';
import '../../screens/pvp_screen.dart';
import '../../screens/dungeon_screen.dart';
import '../../screens/gauntlet_screen.dart';
import '../../screens/boss_rush_screen.dart';
import '../../screens/guild_screen.dart';
import '../../screens/world_event_screen.dart';
import '../../screens/bounty_board_screen.dart';
import '../../screens/expedition_screen.dart';
import '../../screens/quest_screen.dart';
import '../../screens/bestiary_screen.dart';
import '../../screens/battle_screen.dart';
import '../../screens/ability_upgrade_screen.dart';
import '../../screens/passive_tree_screen.dart';
import '../../screens/inventory_screen.dart';
import '../../screens/aura_shop_screen.dart';
import '../../screens/forge_screen.dart';
import '../../screens/subclass_screen.dart';
import '../../screens/prestige_screen.dart';
import '../../screens/achievement_screen.dart';
import '../../screens/shop_screen.dart';
import '../../screens/settings_screen.dart';
import '../../screens/mastery_screen.dart';
import '../../screens/challenge_modifiers_screen.dart';
import '../../screens/artifact_screen.dart';
import '../../screens/ascension_screen.dart';
import '../../screens/leaderboard_screen.dart';
import '../../screens/knowledge_base_screen.dart';
import '../../screens/login_streak_screen.dart';
import '../../screens/rune_screen.dart';
import '../../screens/npc_ally_screen.dart';
import '../../screens/account_screen.dart';
import '../../screens/privacy_policy_screen.dart';
import '../../models/dnd_class.dart';
import '../../models/hero_race.dart';
import '../../models/hero_trait.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Route paths — single source of truth. Import this anywhere you need to
// navigate; never hardcode path strings at call sites.
// ─────────────────────────────────────────────────────────────────────────────

abstract final class Routes {
  // Root
  static const select   = '/';
  static const loading  = '/loading';

  // Shell tabs
  static const shell    = '/game';

  // Core progression
  static const campaign = '/game/campaign';
  static const endless  = '/game/endless';

  // Daily / events
  static const daily    = '/game/daily';
  static const events   = '/game/events';
  static const bounties = '/game/bounties';

  // Challenge hub + children
  static const challenges        = '/game/challenges';
  static const dungeon           = '/game/challenges/dungeon';
  static const gauntlet          = '/game/challenges/gauntlet';
  static const bossRush          = '/game/challenges/boss-rush';
  static const challengeMods     = '/game/challenges/modifiers';

  // World hub + children
  static const world       = '/game/world';
  static const expedition  = '/game/world/expedition';
  static const pvp         = '/game/world/pvp';

  // Meta / collections
  static const quests    = '/game/quests';
  static const bestiary  = '/game/bestiary';

  // Hero tooling (pushed over shell)
  static const battle         = '/game/battle';
  static const abilityUpgrades = '/game/ability-upgrades';
  static const passiveTree    = '/game/passive-tree';
  static const mastery        = '/game/mastery';
  static const prestige       = '/game/prestige';
  static const ascension      = '/game/ascension';
  static const subclass       = '/game/subclass';

  // Inventory / shop
  static const inventory  = '/game/inventory';
  static const forge      = '/game/forge';
  static const artifacts  = '/game/artifacts';
  static const runeForge  = '/game/rune-forge';
  static const shop       = '/game/shop';
  static const auraShop   = '/game/aura-shop';

  // Social / account
  static const leaderboard  = '/game/leaderboard';
  static const achievements = '/game/achievements';
  static const loginStreak  = '/game/login-streak';
  static const npcAllies    = '/game/npc-allies';
  static const account      = '/game/account';
  static const knowledgeBase = '/game/knowledge-base';
  static const settings      = '/game/settings';
  static const privacyPolicy = '/game/privacy-policy';
  static const worldEvent   = '/game/world-event';
  static const guild        = '/game/guild';
}

// ─────────────────────────────────────────────────────────────────────────────
// Router factory
//
// Takes the same callbacks that ZetaIdleApp used to pass around manually, so
// the rest of the app stays unchanged while we migrate call sites.
// ─────────────────────────────────────────────────────────────────────────────

CustomTransitionPage<void> _fadeSlidePage(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      final slide = Tween(begin: const Offset(0.05, 0), end: Offset.zero)
          .animate(fade);
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

GoRoute _route(String path, Widget child) => GoRoute(
  path: path,
  pageBuilder: (_, state) => _fadeSlidePage(child, state),
);

GoRouter buildRouter({
  required bool characterSelected,
  required Future<void> Function(int, String?, DndClass?, HeroRace?, HeroTrait?, HeroGender?)
      onCharacterSelected,
  required VoidCallback onBackToSelect,
}) {
  return GoRouter(
    initialLocation: characterSelected ? Routes.shell : Routes.select,
    redirect: (context, state) {
      final atSelect  = state.matchedLocation == Routes.select;
      final atLoading = state.matchedLocation.startsWith(Routes.loading);
      if (!characterSelected && !atSelect && !atLoading) return Routes.select;
      if (characterSelected && atSelect) return Routes.shell;
      return null;
    },
    routes: [
      // ── Character select ──────────────────────────────────────────────────
      GoRoute(
        path: Routes.select,
        builder: (_, __) => CharacterSelectScreen(
          onCharacterSelected: onCharacterSelected,
        ),
      ),

      // ── Persistent shell (bottom nav) ─────────────────────────────────────
      GoRoute(
        path: Routes.shell,
        builder: (_, __) => MainShell(onBackToSelect: onBackToSelect),
        routes: [
          // Core progression
          _route('campaign', const CampaignScreen()),
          _route('endless',  const EndlessScreen()),

          // Daily / events
          _route('daily',    const DailyScreen()),
          _route('events',   const WorldEventScreen()),
          _route('bounties', const BountyBoardScreen()),

          // Challenge hub
          GoRoute(
            path: 'challenges',
            pageBuilder: (_, s) => _fadeSlidePage(const ChallengeHubScreen(), s),
            routes: [
              _route('dungeon',   const DungeonScreen()),
              _route('gauntlet',  const GauntletScreen()),
              _route('boss-rush', const BossRushScreen()),
              _route('modifiers', const ChallengeModifiersScreen()),
            ],
          ),

          // World hub
          GoRoute(
            path: 'world',
            pageBuilder: (_, s) => _fadeSlidePage(const WorldHubScreen(), s),
            routes: [
              _route('expedition', const ExpeditionScreen()),
              _route('pvp',        const PvpScreen()),
            ],
          ),

          // Meta / collections
          _route('quests',   const QuestScreen()),
          _route('bestiary', const BestiaryScreen()),

          // Battle (pushed over shell)
          _route('battle', const BattleScreen()),

          // Hero tooling
          _route('ability-upgrades', const AbilityUpgradeScreen()),
          _route('passive-tree',     const PassiveTreeScreen()),
          _route('mastery',          const MasteryScreen()),
          _route('prestige',         const PrestigeScreen()),
          _route('ascension',        const AscensionScreen()),
          _route('subclass',         const SubclassScreen()),

          // Inventory / shop
          _route('inventory',  const InventoryScreen()),
          _route('forge',      const ForgeScreen()),
          _route('artifacts',  const ArtifactScreen()),
          _route('rune-forge', const RuneScreen()),
          _route('shop',       const ShopScreen()),
          _route('aura-shop',  const AuraShopScreen()),

          // Social / account
          _route('leaderboard',   const LeaderboardScreen()),
          _route('achievements',  const AchievementScreen()),
          _route('login-streak',  const LoginStreakScreen()),
          _route('npc-allies',    const NpcAllyScreen()),
          _route('account',       const AccountScreen()),
          _route('knowledge-base',const KnowledgeBaseScreen()),
          _route('settings',       const SettingsScreen()),
          _route('privacy-policy', const PrivacyPolicyScreen()),
          _route('world-event',   const WorldEventScreen()),
          _route('guild',         const GuildScreen()),
        ],
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Placeholder hub screens — replaced in later steps
// ─────────────────────────────────────────────────────────────────────────────

class ChallengeHubScreen extends StatelessWidget {
  const ChallengeHubScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Challenge Hub — coming next')));
}

class WorldHubScreen extends StatelessWidget {
  const WorldHubScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('World Hub — coming next')));
}
