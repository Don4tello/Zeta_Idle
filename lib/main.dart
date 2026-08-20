import 'dart:async';
import 'dart:ui' show PlatformDispatcher;
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/analytics_service.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/remote_config_service.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart' show SystemChrome, DeviceOrientation;
import 'services/ad_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'models/dnd_class.dart';
import 'models/hero_model.dart' show HeroGender;
import 'models/hero_race.dart';
import 'models/hero_trait.dart';
import 'screens/loading_screen.dart';
import 'services/game_state.dart';
import 'services/debug_logger.dart';
import 'core/routing/app_router.dart';
import 'tools/debug_capture_surface.dart';

/// True once Firebase.initializeApp() has succeeded.
bool _firebaseReady = false;

/// App-wide analytics handle (null until Firebase initialises).
FirebaseAnalytics? analytics;

/// Navigator observers for the router — automatic screen tracking (analytics)
/// plus a Crashlytics breadcrumb of the current screen (for crash context).
List<NavigatorObserver> get _routerObservers => [
      if (analytics != null) FirebaseAnalyticsObserver(analytics: analytics!),
      if (_firebaseReady) _CrashlyticsRouteObserver(),
    ];

/// Records the current route as a Crashlytics custom key + breadcrumb, so a
/// crash report shows which screen the player was on.
class _CrashlyticsRouteObserver extends NavigatorObserver {
  void _set(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name == null) return;
    try {
      FirebaseCrashlytics.instance.setCustomKey('screen', name);
      FirebaseCrashlytics.instance.log('screen: $name');
    } catch (_) {}
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _set(route);
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _set(previousRoute);
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) => _set(newRoute);
}

/// One-time crash-pipeline self-test: records a single labelled non-fatal on the
/// first launch after this update so we can confirm reports reach the console.
Future<void> _crashPipelineSelfTest() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    const key = 'crash_pipeline_verified_v21';
    if (prefs.getBool(key) ?? false) return;
    FirebaseCrashlytics.instance.log('crash-reporting self-test');
    await FirebaseCrashlytics.instance.recordError(
        'crash-reporting self-test (non-fatal, one-time)', StackTrace.current,
        fatal: false);
    await prefs.setBool(key, true);
  } catch (_) {}
}

Future<void> main() async {
  runZonedGuarded(_appMain, (error, stack) {
    // Catch any uncaught async exception so Android doesn't kill the process.
    // ignore: avoid_print
    print('Uncaught zone error: $error\n$stack');
    DebugLogger.log('crash', '$error\n$stack');
    if (_firebaseReady) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
  });
}

Future<void> _appMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Use the fonts bundled in assets/google_fonts/ — never fetch over the
  // network (offline/failed fetches previously threw and were reported as
  // crashes). Falls back to the platform font only if a family isn't bundled.
  GoogleFonts.config.allowRuntimeFetching = false;
  await DebugLogger.init();

  // Suppress known benign Flutter framework warnings.
  FlutterError.onError = (details) {
    final msg = details.toString();
    if (msg.contains('_debugDuringDeviceUpdate') ||
        msg.contains('parentDataDirty') ||
        msg.contains('semantics')) { return; }
    FlutterError.presentError(details);
    DebugLogger.log('flutter_error', details.toString());
  };

  if (DefaultFirebaseOptions.currentPlatform.apiKey != 'YOUR_API_KEY') {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _firebaseReady = true;

      // ── App Check ──────────────────────────────────────────────────────
      // Attests requests come from the genuine app before they reach
      // Firestore. Release builds use Play Integrity; debug/dev builds use the
      // debug provider (register the printed debug token in the Firebase
      // console so your test devices keep working). Enforcement stays a
      // separate, deliberate switch in the console — activating here only
      // makes the app START sending tokens so you can watch the metrics.
      try {
        await FirebaseAppCheck.instance.activate(
          providerAndroid: kDebugMode
              ? const AndroidDebugProvider()
              : const AndroidPlayIntegrityProvider(),
        );
      } catch (e) {
        DebugLogger.log('appcheck_init', 'error: $e');
      }

      // ── Crashlytics ────────────────────────────────────────────────────
      // Don't upload crashes from debug builds (keeps the console clean).
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);
      // Route Flutter framework errors to Crashlytics (keeping the existing
      // benign-warning filter), plus any error escaping the framework.
      FlutterError.onError = (details) {
        final msg = details.toString();
        if (msg.contains('_debugDuringDeviceUpdate') ||
            msg.contains('parentDataDirty') ||
            msg.contains('semantics')) { return; }
        FlutterError.presentError(details);
        DebugLogger.log('flutter_error', details.toString());
        FirebaseCrashlytics.instance.recordFlutterError(details);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        DebugLogger.log('platform_error', '$error\n$stack');
        return true;
      };

      // Forward every DebugLogger event to Crashlytics: always a breadcrumb,
      // and error-like entries as non-fatals. This surfaces the many caught
      // exceptions that used to be swallowed silently (init failures, save
      // parse fails, sync errors, …).
      DebugLogger.sink = (category, message) {
        try {
          FirebaseCrashlytics.instance.log('[$category] $message');
          final lc = '$category $message'.toLowerCase();
          final looksLikeError = lc.contains('error') ||
              lc.contains('exception') ||
              lc.contains('fail') ||
              category == 'crash';
          if (looksLikeError) {
            FirebaseCrashlytics.instance.recordError(
                '$category: $message', StackTrace.current,
                fatal: false);
          }
        } catch (_) {}
      };

      // One-time self-test so we can confirm the pipeline reaches the console
      // (records a single labelled non-fatal on the first launch after update).
      unawaited(_crashPipelineSelfTest());

      // ── Analytics ──────────────────────────────────────────────────────
      analytics = FirebaseAnalytics.instance;
      AnalyticsService.instance.init(analytics!);
      await analytics!.logAppOpen();

      // ── Remote Config ──────────────────────────────────────────────────
      // Live balance knobs (difficulty/economy) — tunable from the console
      // without a new release. Best-effort; defaults keep current behavior.
      await RemoteConfigService.instance.init(FirebaseRemoteConfig.instance);
    } catch (e) {
      // ignore: avoid_print
      print('Firebase initialization warning: $e');
      DebugLogger.log('firebase_init', 'error: $e');
    }
  }
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  try {
    await AdService.initialize();
  } catch (e) {
    // ignore: avoid_print
    print('AdMob initialization warning: $e');
    DebugLogger.log('admob_init', 'error: $e');
  }
  try {
    // Initialise here, but ask for the OS permission after the first frame
    // (see _ZetaIdleAppState.initState). Requesting before runApp() can return
    // without ever showing the system dialog because there's no resumed
    // Activity/UI yet.
    await NotificationService.instance.initialize();
  } catch (e) {
    DebugLogger.log('notif_init', 'error: $e');
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
    // Start tavern music after the first frame so assets are ready, and ask for
    // the notification permission now that there's a resumed Activity + UI (the
    // Android 13+ dialog won't appear if requested before the first frame).
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Restore persisted mute settings BEFORE starting music, so a player who
      // turned music/SFX off doesn't get blasted on every launch.
      await _gameState.audioService.loadSettings();
      _gameState.audioService.startMusic();
      try {
        await NotificationService.instance.requestPermission();
      } catch (e) {
        DebugLogger.log('notif_perm', 'error: $e');
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Suppress SFX unless the app is in the foreground — the idle-income timer
    // keeps ticking while locked/backgrounded and would otherwise play its
    // claim/coin sound over a locked phone.
    _gameState.audioService.appActive = state == AppLifecycleState.resumed;
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      _gameState.audioService.pauseMusic();
      // Fire-and-forget save after a short delay so audio pause completes first
      Future.delayed(const Duration(milliseconds: 200), () {
        if (state == AppLifecycleState.paused) _gameState.saveAndSyncNow();
      });
      // Schedule "come back" reminders while the player is away (opt-out honored).
      if (_gameState.notificationsEnabled) {
        NotificationService.instance.scheduleRetentionReminders();
      } else {
        NotificationService.instance.cancelAll();
      }
    } else if (state == AppLifecycleState.resumed) {
      _gameState.audioService.resumeMusic();
      // Catch up campaign energy for the time spent away (offline refill).
      _gameState.tickEnergy();
      _gameState.notifyListeners();
      // Player is back — clear any pending reminders.
      NotificationService.instance.cancelAll();
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
          observers: _routerObservers,
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
        observers: _routerObservers,
      );
    });
  }

  late var _router = buildRouter(
    characterSelected: _characterSelected,
    onCharacterSelected: _onCharacterSelected,
    onBackToSelect: _onBackToSelect,
    observers: _routerObservers,
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
        builder: (_, child) =>
            DebugCaptureSurface(child: child ?? const SizedBox()),
      ),
    );
  }
}
