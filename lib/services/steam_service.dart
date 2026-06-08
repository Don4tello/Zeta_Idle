// Steam integration layer.
//
// HOW TO ACTIVATE:
//  1. Register on partner.steamgames.com and get your App ID.
//  2. Download the Steamworks SDK and add steam_api64.dll next to ZetaIdle.exe.
//  3. Create steam_appid.txt (one line: your App ID) in the exe directory for dev.
//  4. Add `steamworks: ^0.3.0` to pubspec.yaml.
//  5. Replace every "// STEAM SDK:" comment below with the real call.
//  6. Set _kSteamAppId to your actual App ID.
//
// Until then this class is a safe no-op stub — nothing will crash without the SDK.

class SteamService {
  static const int _kSteamAppId = 0; // TODO: replace with your Steam App ID

  bool _initialised = false;

  // ── Achievement ID mapping ────────────────────────────────────────────────
  // Matches the in-game Achievement.id to the API name you define in Steamworks
  // (Steamworks Developer → App Admin → Stats & Achievements).
  // Convention: uppercase snake_case.
  static const Map<String, String> _achievementIds = {
    'first_blood':     'FIRST_BLOOD',
    'battle_veteran':  'BATTLE_VETERAN',
    'war_machine':     'WAR_MACHINE',
    'executioner':     'EXECUTIONER',
    'slaughterer':     'SLAUGHTERER',
    'boss_slayer':     'BOSS_SLAYER',
    'dragon_slayer':   'DRAGON_SLAYER',
    'thread_needle':   'THREAD_NEEDLE',
    'devastator':      'DEVASTATOR',
    'force_nature':    'FORCE_OF_NATURE',
    'rising_star':     'RISING_STAR',
    'champion_lv':     'CHAMPION',
    'legend_lv':       'LEGEND',
    'world_conqueror': 'WORLD_CONQUEROR',
    'veteran_road':    'VETERAN_ROAD',
    'first_prestige':  'FIRST_PRESTIGE',
    'prestige_ii':     'PRESTIGE_II',
    'class_found':     'CLASS_FOUND',
    'gold_rush':       'GOLD_RUSH',
    'tycoon':          'TYCOON',
    'idle_life':       'IDLE_LIFE',
    'first_passive':   'FIRST_PASSIVE',
    'passive_master':  'PASSIVE_MASTER',
    'blacksmith':      'BLACKSMITH',
    'disenchanter':    'DISENCHANTER',
  };

  // ── Init ──────────────────────────────────────────────────────────────────

  void init() {
    if (_kSteamAppId == 0) return; // no-op until App ID is set
    try {
      // STEAM SDK: SteamClient.init(appId: _kSteamAppId);
      _initialised = true;
    } catch (_) {
      // SDK not present — run without Steam features.
    }
  }

  void dispose() {
    if (!_initialised) return;
    // STEAM SDK: SteamClient.dispose();
    _initialised = false;
  }

  // ── Achievements ──────────────────────────────────────────────────────────

  void unlockAchievement(String inGameId) {
    if (!_initialised) return;
    final steamId = _achievementIds[inGameId];
    if (steamId == null) return;
    try {
      // STEAM SDK:
      // SteamUserStats.instance.setAchievement(steamId);
      // SteamUserStats.instance.storeStats();
    } catch (_) {}
  }

  // ── Stats ─────────────────────────────────────────────────────────────────

  void reportStat(String name, int value) {
    if (!_initialised) return;
    try {
      // STEAM SDK: SteamUserStats.instance.setStatInt(name, value);
    } catch (_) {}
  }

  // ── Overlay ───────────────────────────────────────────────────────────────

  void openAchievementsOverlay() {
    if (!_initialised) return;
    try {
      // STEAM SDK: SteamFriends.instance.activateGameOverlay('Achievements');
    } catch (_) {}
  }

  // ── Cloud save path ───────────────────────────────────────────────────────
  //
  // Steam Cloud uses ISteamRemoteStorage and works at the file level.
  // Your Firebase cloud save already handles cross-device sync — you don't
  // need Steam Cloud too. If you want Steam Cloud as a fallback:
  //
  // STEAM SDK:
  //   SteamRemoteStorage.instance.fileWrite('save_slot_0.json', jsonBytes);
  //   final bytes = SteamRemoteStorage.instance.fileRead('save_slot_0.json');
}
