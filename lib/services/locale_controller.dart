import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the user's chosen app locale. `null` = follow the device/system locale.
/// Persisted locally and listened to by the root MaterialApp, so switching
/// language in Settings applies instantly without a restart.
///
/// Adding a language is purely data: drop in lib/l10n/app_<code>.arb, run
/// `flutter gen-l10n`, and add the code to [supported] below.
class LocaleController extends ValueNotifier<Locale?> {
  LocaleController._() : super(null);
  static final LocaleController instance = LocaleController._();

  static const _key = 'zeta_idle_locale';

  /// Languages offered in the in-app picker (beyond "System default"). Keep in
  /// sync with the shipped app_<code>.arb files.
  static const List<Locale> supported = <Locale>[
    Locale('en'),
    Locale('de'),
  ];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null && code.isNotEmpty) value = Locale(code);
  }

  Future<void> setLocale(Locale? locale) async {
    value = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, locale.languageCode);
    }
  }
}
