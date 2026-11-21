import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show appFlavor;

/// True in the `--flavor dev` build (applicationId `com.zetaidle.app.dev`).
///
/// Dev builds are driven by Play license-tester accounts whose "purchases" are
/// free test transactions — but the billing client still reports the real store
/// price, so logging them as GA4 revenue inflates Firebase with phantom income.
/// Use this flag to keep DEV spend out of the real-revenue reports.
const bool kIsDevBuild = appFlavor == 'dev';

/// Demo / web-distribution build configuration.
///
/// Enabled with `--dart-define=DEMO=true` (implicit on the web build, which is
/// the pixelpicked.com / browser target). A demo build:
///  • plays the FULL Tier 0 campaign but cannot prestige into Tier 1+ (the
///    difficulty-tier ladder is the full-game hook) — see [kDemoMaxTier];
///  • shows the alternate battle modes (Dungeon, Boss Rush, Tower, Gauntlet,
///    PvP, Events, Expedition) as locked "full game" teasers rather than hiding
///    them, so players see the breadth — see [kDemoModeAllowed];
///  • hides real-money purchases (`in_app_purchase` has no web support anyway).
///
/// Native store builds leave all of this off, so nothing changes for the app.
const bool kDemoBuild = bool.fromEnvironment('DEMO', defaultValue: false) || kIsWeb;

/// Highest prestige tier a demo build may reach. 0 = full first campaign, no
/// tier ladder. Prestige is blocked past this in a demo (with an upsell).
const int kDemoMaxTier = 0;

/// True when real-money IAP should be hidden (no web billing; demo = no sales).
const bool kIapHidden = kDemoBuild;

/// Where demo "get the full game" upsells point (the Play Store listing).
const String kFullGameUrl =
    'https://play.google.com/store/apps/details?id=com.zetaidle.app';

/// Mode-tab ids that stay PLAYABLE in a demo. Everything else in the PLAY tab is
/// shown but locked behind a "full game" teaser. Keyed by the stable ids in
/// `ModesScreen._tabData`.
const Set<String> _kDemoPlayableModes = {'CAMPAIGN', 'CHALLENGES'};

/// Whether [modeId] (a `ModesScreen._tabData` id) is playable in this build.
/// Always true outside a demo.
bool kDemoModeAllowed(String modeId) =>
    !kDemoBuild || _kDemoPlayableModes.contains(modeId);
