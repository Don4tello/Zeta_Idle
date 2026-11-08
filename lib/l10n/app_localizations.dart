import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// Character creation name-step heading
  ///
  /// In en, this message translates to:
  /// **'FORGE YOUR LEGEND'**
  String get ccForgeYourLegend;

  /// No description provided for @ccNameYourWarrior.
  ///
  /// In en, this message translates to:
  /// **'— NAME YOUR WARRIOR —'**
  String get ccNameYourWarrior;

  /// Default hero name prefilled in the name field
  ///
  /// In en, this message translates to:
  /// **'The Warden'**
  String get ccDefaultHeroName;

  /// One-tap onboarding button (a lightning emoji is shown before it)
  ///
  /// In en, this message translates to:
  /// **'QUICK START'**
  String get ccQuickStart;

  /// No description provided for @ccQuickStartHint.
  ///
  /// In en, this message translates to:
  /// **'Jump straight in with a recommended hero'**
  String get ccQuickStartHint;

  /// Secondary button that opens the full step-by-step creation wizard
  ///
  /// In en, this message translates to:
  /// **'CHOOSE CLASS & RACE'**
  String get ccChooseClassAndRace;

  /// No description provided for @ccChooseYourClass.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE YOUR CLASS'**
  String get ccChooseYourClass;

  /// No description provided for @ccSelectYourPath.
  ///
  /// In en, this message translates to:
  /// **'— SELECT YOUR PATH —'**
  String get ccSelectYourPath;

  /// No description provided for @ccChooseRace.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE RACE'**
  String get ccChooseRace;

  /// No description provided for @ccSelectAClass.
  ///
  /// In en, this message translates to:
  /// **'SELECT A CLASS'**
  String get ccSelectAClass;

  /// No description provided for @ccRecommendedForBeginners.
  ///
  /// In en, this message translates to:
  /// **'★ RECOMMENDED FOR BEGINNERS'**
  String get ccRecommendedForBeginners;

  /// No description provided for @ccComplexity.
  ///
  /// In en, this message translates to:
  /// **'COMPLEXITY'**
  String get ccComplexity;

  /// No description provided for @ccChooseYourRace.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE YOUR RACE'**
  String get ccChooseYourRace;

  /// No description provided for @ccHeritageDefinesYou.
  ///
  /// In en, this message translates to:
  /// **'— YOUR HERITAGE DEFINES YOU —'**
  String get ccHeritageDefinesYou;

  /// No description provided for @ccBeginYourJourney.
  ///
  /// In en, this message translates to:
  /// **'BEGIN YOUR JOURNEY'**
  String get ccBeginYourJourney;

  /// No description provided for @ccSelectARace.
  ///
  /// In en, this message translates to:
  /// **'SELECT A RACE'**
  String get ccSelectARace;

  /// No description provided for @ccNameNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Please choose a different name — that one isn\'t allowed.'**
  String get ccNameNotAllowed;

  /// No description provided for @csSelectCharacter.
  ///
  /// In en, this message translates to:
  /// **'— SELECT CHARACTER —'**
  String get csSelectCharacter;

  /// No description provided for @csNewCharacter.
  ///
  /// In en, this message translates to:
  /// **'NEW CHARACTER'**
  String get csNewCharacter;

  /// No description provided for @csSwipeToDelete.
  ///
  /// In en, this message translates to:
  /// **'Swipe a character left to delete'**
  String get csSwipeToDelete;

  /// No description provided for @csDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String csDeleteTitle(String name);

  /// No description provided for @csDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure? Once gone it cannot be stored.'**
  String get csDeleteBody;

  /// No description provided for @csCancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get csCancel;

  /// No description provided for @csDelete.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get csDelete;

  /// No description provided for @csLockedSlot.
  ///
  /// In en, this message translates to:
  /// **'LOCKED SLOT'**
  String get csLockedSlot;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystem;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
