// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get ccForgeYourLegend => 'FORGE YOUR LEGEND';

  @override
  String get ccNameYourWarrior => '— NAME YOUR WARRIOR —';

  @override
  String get ccDefaultHeroName => 'The Warden';

  @override
  String get ccQuickStart => 'QUICK START';

  @override
  String get ccQuickStartHint => 'Jump straight in with a recommended hero';

  @override
  String get ccChooseClassAndRace => 'CHOOSE CLASS & RACE';

  @override
  String get ccChooseYourClass => 'CHOOSE YOUR CLASS';

  @override
  String get ccSelectYourPath => '— SELECT YOUR PATH —';

  @override
  String get ccChooseRace => 'CHOOSE RACE';

  @override
  String get ccSelectAClass => 'SELECT A CLASS';

  @override
  String get ccRecommendedForBeginners => '★ RECOMMENDED FOR BEGINNERS';

  @override
  String get ccComplexity => 'COMPLEXITY';

  @override
  String get ccChooseYourRace => 'CHOOSE YOUR RACE';

  @override
  String get ccHeritageDefinesYou => '— YOUR HERITAGE DEFINES YOU —';

  @override
  String get ccBeginYourJourney => 'BEGIN YOUR JOURNEY';

  @override
  String get ccSelectARace => 'SELECT A RACE';

  @override
  String get ccNameNotAllowed =>
      'Please choose a different name — that one isn\'t allowed.';

  @override
  String get csSelectCharacter => '— SELECT CHARACTER —';

  @override
  String get csNewCharacter => 'NEW CHARACTER';

  @override
  String get csSwipeToDelete => 'Swipe a character left to delete';

  @override
  String csDeleteTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get csDeleteBody => 'Are you sure? Once gone it cannot be stored.';

  @override
  String get csCancel => 'CANCEL';

  @override
  String get csDelete => 'DELETE';

  @override
  String get csLockedSlot => 'LOCKED SLOT';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System default';
}
