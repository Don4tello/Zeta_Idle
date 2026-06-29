import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'models/dnd_class.dart';
import 'models/hero_model.dart' show HeroGender;
import 'models/hero_race.dart';
import 'models/hero_trait.dart';
import 'screens/loading_screen.dart';
import 'services/game_state.dart';
import 'services/debug_logger.dart';
import 'core/routing/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DebugLogger.init();
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
  FlutterError.onError = (details) {
    if (details.toString().contains('_debugDuringDeviceUpdate')) return;
    FlutterError.presentError(details);
  };
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
  HeroTrait? trait,
  HeroGender? gender,
});

class _ZetaIdleAppState extends State<ZetaIdleApp> with WidgetsBindingObserver {
  late final GameState _gameState = GameState();
  bool _characterSelected = false;
  _LoadArgs? _pendingLoad;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Start tavern music after the first frame so assets are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gameState.audioService.startMusic();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      _gameState.audioService.pauseMusic();
    } else if (state == AppLifecycleState.resumed) {
      _gameState.audioService.resumeMusic();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _gameState.audioService.dispose();
    _gameState.dispose();
    super.dispose();
  }

  Future<void> _onCharacterSelected(
      int slot, String? newName, DndClass? heroClass, HeroRace? heroRace, HeroTrait? trait, HeroGender? gender) async {
    setState(() {
      _pendingLoad = (slot: slot, name: newName, heroClass: heroClass, heroRace: heroRace, trait: trait, gender: gender);
    });
  }

  void _onLoadComplete() {
    if (mounted) {
      setState(() {
        _pendingLoad = null;
        _characterSelected = true;
        // Rebuild router with updated characterSelected flag
        _router = buildRouter(
          characterSelected: _characterSelected,
          onCharacterSelected: _onCharacterSelected,
          onBackToSelect: _onBackToSelect,
        );
      });
    }
  }

  void _onBackToSelect() {
    setState(() {
      _characterSelected = false;
      _router = buildRouter(
        characterSelected: _characterSelected,
        onCharacterSelected: _onCharacterSelected,
        onBackToSelect: _onBackToSelect,
      );
    });
  }

  late var _router = buildRouter(
    characterSelected: _characterSelected,
    onCharacterSelected: _onCharacterSelected,
    onBackToSelect: _onBackToSelect,
  );

  @override
  Widget build(BuildContext context) {
    final pending = _pendingLoad;
    if (pending != null) {
      // Show loading screen outside of router while game data loads
      return GameStateProvider(
        gameState: _gameState,
        child: MaterialApp(
          title: 'Zeta Idle',
          theme: AppTheme.darkMedievalTheme(),
          home: LoadingScreen(
            task: () => _gameState.loadSlot(
              pending.slot,
              newName: pending.name,
              heroClass: pending.heroClass,
              heroRace: pending.heroRace,
              trait: pending.trait,
              gender: pending.gender,
            ),
            onComplete: _onLoadComplete,
          ),
        ),
      );
    }

    return GameStateProvider(
      gameState: _gameState,
      child: MaterialApp.router(
        title: 'Zeta Idle',
        theme: AppTheme.darkMedievalTheme(),
        routerConfig: _router,
      ),
    );
  }
}
