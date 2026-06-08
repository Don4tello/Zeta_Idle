import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'models/dnd_class.dart';
import 'models/hero_race.dart';
import 'models/hero_trait.dart';
import 'screens/character_select_screen.dart';
import 'screens/ability_upgrade_screen.dart';
import 'screens/passive_tree_screen.dart';
import 'screens/mastery_screen.dart';
import 'screens/expedition_screen.dart';
import 'screens/quest_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/aura_shop_screen.dart';
import 'screens/forge_screen.dart';
import 'screens/subclass_screen.dart';
import 'screens/prestige_screen.dart';
import 'screens/achievement_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/dungeon_screen.dart';
import 'screens/battle_screen.dart';
import 'screens/campaign_screen.dart';
import 'screens/daily_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/endless_screen.dart';
import 'screens/challenge_modifiers_screen.dart';
import 'screens/bestiary_screen.dart';
import 'screens/boss_rush_screen.dart';
import 'screens/artifact_screen.dart';
import 'screens/bounty_board_screen.dart';
import 'screens/ascension_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/knowledge_base_screen.dart';
import 'screens/login_streak_screen.dart';
import 'screens/rune_screen.dart';
import 'screens/world_event_screen.dart';
import 'screens/gauntlet_screen.dart';
import 'screens/npc_ally_screen.dart';
import 'screens/account_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/main_shell.dart';
import 'services/game_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (DefaultFirebaseOptions.currentPlatform.apiKey != 'YOUR_API_KEY') {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      // ignore: avoid_print
      print('Firebase initialization warning: $e');
    }
  }
  runApp(const ZetaIdleApp());
}

class ZetaIdleApp extends StatefulWidget {
  const ZetaIdleApp({super.key});

  @override
  State<ZetaIdleApp> createState() => _ZetaIdleAppState();
}

typedef _LoadArgs = ({
  int slot,
  String? name,
  DndClass? heroClass,
  HeroRace? heroRace,
  HeroTrait? trait
});

class _ZetaIdleAppState extends State<ZetaIdleApp> {
  late final GameState _gameState = GameState();
  bool _characterSelected = false;
  _LoadArgs? _pendingLoad;

  @override
  void dispose() {
    _gameState.dispose();
    super.dispose();
  }

  Future<void> _onCharacterSelected(
      int slot, String? newName, DndClass? heroClass, HeroRace? heroRace, HeroTrait? trait) async {
    setState(() {
      _pendingLoad = (slot: slot, name: newName, heroClass: heroClass, heroRace: heroRace, trait: trait);
    });
  }

  void _onLoadComplete() {
    if (mounted) {
      setState(() {
        _pendingLoad = null;
        _characterSelected = true;
      });
    }
  }

  void _onBackToSelect() {
    setState(() => _characterSelected = false);
  }

  Widget _buildHome() {
    final pending = _pendingLoad;
    if (pending != null) {
      return LoadingScreen(
        task: () => _gameState.loadSlot(
          pending.slot,
          newName: pending.name,
          heroClass: pending.heroClass,
          heroRace: pending.heroRace,
          trait: pending.trait,
        ),
        onComplete: _onLoadComplete,
      );
    }
    if (_characterSelected) {
      return MainShell(onBackToSelect: _onBackToSelect);
    }
    return CharacterSelectScreen(onCharacterSelected: _onCharacterSelected);
  }

  @override
  Widget build(BuildContext context) {
    return GameStateProvider(
      gameState: _gameState,
      child: MaterialApp(
        title: 'Zeta Idle',
        theme: AppTheme.darkMedievalTheme(),
        home: _buildHome(),
        routes: {
          '/campaign':          (context) => const CampaignScreen(),
          '/endless':           (context) => const EndlessScreen(),
          '/daily':             (context) => const DailyScreen(),
          '/battle':            (context) => const BattleScreen(),
          '/dashboard':         (context) => const DashboardScreen(),
          '/ability-upgrades':  (context) => const AbilityUpgradeScreen(),
          '/passive-tree':      (context) => const PassiveTreeScreen(),
          '/inventory':         (context) => const InventoryScreen(),
          '/aura-shop':         (context) => const AuraShopScreen(),
          '/forge':             (context) => const ForgeScreen(),
          '/subclass':          (context) => const SubclassScreen(),
          '/prestige':          (context) => const PrestigeScreen(),
          '/achievements':      (context) => const AchievementScreen(),
          '/shop':              (context) => const ShopScreen(),
          '/settings':          (context) => const SettingsScreen(),
          '/dungeon':           (context) => const DungeonScreen(),
          '/mastery':              (context) => const MasteryScreen(),
          '/expedition':           (context) => const ExpeditionScreen(),
          '/quests':               (context) => const QuestScreen(),
          '/challenge-modifiers':  (context) => const ChallengeModifiersScreen(),
          '/bestiary':             (context) => const BestiaryScreen(),
          '/boss-rush':            (context) => const BossRushScreen(),
          '/artifacts':            (context) => const ArtifactScreen(),
          '/bounty-board':         (context) => const BountyBoardScreen(),
          '/ascension':            (context) => const AscensionScreen(),
          '/leaderboard':          (context) => const LeaderboardScreen(),
          '/knowledge-base':       (context) => const KnowledgeBaseScreen(),
          '/login-streak':         (context) => const LoginStreakScreen(),
          '/rune-forge':           (context) => const RuneScreen(),
          '/world-event':          (context) => const WorldEventScreen(),
          '/gauntlet':             (context) => const GauntletScreen(),
          '/npc-allies':           (context) => const NpcAllyScreen(),
          '/account':              (context) => const AccountScreen(),
        },
      ),
    );
  }
}
