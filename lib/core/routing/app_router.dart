import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/character_select_screen.dart';
import '../../screens/main_shell.dart';
import '../../screens/campaign_screen.dart';
import '../../screens/endless_screen.dart';
import '../../screens/daily_screen.dart';
import '../../screens/pvp_screen.dart';
import '../../screens/dungeon_screen.dart';
import '../../screens/gauntlet_screen.dart';
import '../../screens/boss_rush_screen.dart';
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
  static const settings     = '/game/settings';
  static const worldEvent   = '/game/world-event';
}

// ─────────────────────────────────────────────────────────────────────────────
// Router factory
//
// Takes the same callbacks that ZetaIdleApp used to pass around manually, so
// the rest of the app stays unchanged while we migrate call sites.
// ─────────────────────────────────────────────────────────────────────────────

GoRouter buildRouter({
  required bool characterSelected,
  required Future<void> Function(int, String?, DndClass?, HeroRace?, HeroTrait?)
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
          GoRoute(path: 'campaign', builder: (_, __) => const CampaignScreen()),
          GoRoute(path: 'endless',  builder: (_, __) => const EndlessScreen()),

          // Daily / events
          GoRoute(path: 'daily',    builder: (_, __) => const DailyScreen()),
          GoRoute(path: 'events',   builder: (_, __) => const WorldEventScreen()),
          GoRoute(path: 'bounties', builder: (_, __) => const BountyBoardScreen()),

          // Challenge hub
          GoRoute(
            path: 'challenges',
            builder: (_, __) => const ChallengeHubScreen(),
            routes: [
              GoRoute(path: 'dungeon',    builder: (_, __) => const DungeonScreen()),
              GoRoute(path: 'gauntlet',   builder: (_, __) => const GauntletScreen()),
              GoRoute(path: 'boss-rush',  builder: (_, __) => const BossRushScreen()),
              GoRoute(path: 'modifiers',  builder: (_, __) => const ChallengeModifiersScreen()),
            ],
          ),

          // World hub
          GoRoute(
            path: 'world',
            builder: (_, __) => const WorldHubScreen(),
            routes: [
              GoRoute(path: 'expedition', builder: (_, __) => const ExpeditionScreen()),
              GoRoute(path: 'pvp',        builder: (_, __) => const PvpScreen()),
            ],
          ),

          // Meta / collections
          GoRoute(path: 'quests',   builder: (_, __) => const QuestScreen()),
          GoRoute(path: 'bestiary', builder: (_, __) => const BestiaryScreen()),

          // Battle (pushed over shell)
          GoRoute(path: 'battle', builder: (_, __) => const BattleScreen()),

          // Hero tooling
          GoRoute(path: 'ability-upgrades', builder: (_, __) => const AbilityUpgradeScreen()),
          GoRoute(path: 'passive-tree',     builder: (_, __) => const PassiveTreeScreen()),
          GoRoute(path: 'mastery',          builder: (_, __) => const MasteryScreen()),
          GoRoute(path: 'prestige',         builder: (_, __) => const PrestigeScreen()),
          GoRoute(path: 'ascension',        builder: (_, __) => const AscensionScreen()),
          GoRoute(path: 'subclass',         builder: (_, __) => const SubclassScreen()),

          // Inventory / shop
          GoRoute(path: 'inventory',  builder: (_, __) => const InventoryScreen()),
          GoRoute(path: 'forge',      builder: (_, __) => const ForgeScreen()),
          GoRoute(path: 'artifacts',  builder: (_, __) => const ArtifactScreen()),
          GoRoute(path: 'rune-forge', builder: (_, __) => const RuneScreen()),
          GoRoute(path: 'shop',       builder: (_, __) => const ShopScreen()),
          GoRoute(path: 'aura-shop',  builder: (_, __) => const AuraShopScreen()),

          // Social / account
          GoRoute(path: 'leaderboard',   builder: (_, __) => const LeaderboardScreen()),
          GoRoute(path: 'achievements',  builder: (_, __) => const AchievementScreen()),
          GoRoute(path: 'login-streak',  builder: (_, __) => const LoginStreakScreen()),
          GoRoute(path: 'npc-allies',    builder: (_, __) => const NpcAllyScreen()),
          GoRoute(path: 'account',       builder: (_, __) => const AccountScreen()),
          GoRoute(path: 'knowledge-base',builder: (_, __) => const KnowledgeBaseScreen()),
          GoRoute(path: 'settings',      builder: (_, __) => const SettingsScreen()),
          GoRoute(path: 'world-event',   builder: (_, __) => const WorldEventScreen()),
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
