// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get ccForgeYourLegend => 'SCHMIEDE DEINE LEGENDE';

  @override
  String get ccNameYourWarrior => '— BENENNE DEINEN KRIEGER —';

  @override
  String get ccDefaultHeroName => 'Der Wächter';

  @override
  String get ccQuickStart => 'SCHNELLSTART';

  @override
  String get ccQuickStartHint =>
      'Steig sofort mit einem empfohlenen Helden ein';

  @override
  String get ccChooseClassAndRace => 'KLASSE & VOLK WÄHLEN';

  @override
  String get ccChooseYourClass => 'WÄHLE DEINE KLASSE';

  @override
  String get ccSelectYourPath => '— WÄHLE DEINEN PFAD —';

  @override
  String get ccChooseRace => 'VOLK WÄHLEN';

  @override
  String get ccSelectAClass => 'KLASSE WÄHLEN';

  @override
  String get ccRecommendedForBeginners => '★ EMPFOHLEN FÜR EINSTEIGER';

  @override
  String get ccComplexity => 'KOMPLEXITÄT';

  @override
  String get ccChooseYourRace => 'WÄHLE DEIN VOLK';

  @override
  String get ccHeritageDefinesYou => '— DEINE HERKUNFT PRÄGT DICH —';

  @override
  String get ccBeginYourJourney => 'BEGINNE DEINE REISE';

  @override
  String get ccSelectARace => 'VOLK WÄHLEN';

  @override
  String get ccNameNotAllowed =>
      'Bitte wähle einen anderen Namen — dieser ist nicht erlaubt.';

  @override
  String get csSelectCharacter => '— CHARAKTER WÄHLEN —';

  @override
  String get csNewCharacter => 'NEUER CHARAKTER';

  @override
  String get csSwipeToDelete => 'Wische einen Charakter nach links zum Löschen';

  @override
  String csDeleteTitle(String name) {
    return '\"$name\" löschen?';
  }

  @override
  String get csDeleteBody =>
      'Bist du sicher? Einmal weg, kann er nicht wiederhergestellt werden.';

  @override
  String get csCancel => 'ABBRECHEN';

  @override
  String get csDelete => 'LÖSCHEN';

  @override
  String get csLockedSlot => 'GESPERRTER PLATZ';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsLanguageSystem => 'Systemstandard';
}
