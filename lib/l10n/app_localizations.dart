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

  /// No description provided for @navHero.
  ///
  /// In en, this message translates to:
  /// **'HERO'**
  String get navHero;

  /// No description provided for @navPlay.
  ///
  /// In en, this message translates to:
  /// **'PLAY'**
  String get navPlay;

  /// No description provided for @navInventory.
  ///
  /// In en, this message translates to:
  /// **'INVENTORY'**
  String get navInventory;

  /// No description provided for @navShop.
  ///
  /// In en, this message translates to:
  /// **'SHOP'**
  String get navShop;

  /// No description provided for @navGuild.
  ///
  /// In en, this message translates to:
  /// **'GUILD'**
  String get navGuild;

  /// No description provided for @modeCampaign.
  ///
  /// In en, this message translates to:
  /// **'CAMPAIGN'**
  String get modeCampaign;

  /// No description provided for @modeDungeon.
  ///
  /// In en, this message translates to:
  /// **'DUNGEON'**
  String get modeDungeon;

  /// No description provided for @modeBossRush.
  ///
  /// In en, this message translates to:
  /// **'BOSS RUSH'**
  String get modeBossRush;

  /// No description provided for @modeTowerAscension.
  ///
  /// In en, this message translates to:
  /// **'TOWER ASCENSION'**
  String get modeTowerAscension;

  /// No description provided for @modeGauntlet.
  ///
  /// In en, this message translates to:
  /// **'GAUNTLET'**
  String get modeGauntlet;

  /// No description provided for @modePvp.
  ///
  /// In en, this message translates to:
  /// **'PVP'**
  String get modePvp;

  /// No description provided for @modeChallenges.
  ///
  /// In en, this message translates to:
  /// **'CHALLENGES'**
  String get modeChallenges;

  /// No description provided for @modeEvents.
  ///
  /// In en, this message translates to:
  /// **'EVENTS'**
  String get modeEvents;

  /// No description provided for @modeExpedition.
  ///
  /// In en, this message translates to:
  /// **'EXPEDITION'**
  String get modeExpedition;

  /// No description provided for @modeDaily.
  ///
  /// In en, this message translates to:
  /// **'DAILY'**
  String get modeDaily;

  /// No description provided for @modeBounties.
  ///
  /// In en, this message translates to:
  /// **'BOUNTIES'**
  String get modeBounties;

  /// No description provided for @modeQuests.
  ///
  /// In en, this message translates to:
  /// **'QUESTS'**
  String get modeQuests;

  /// No description provided for @badgeNew.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get badgeNew;

  /// No description provided for @lootLog.
  ///
  /// In en, this message translates to:
  /// **'LOOT LOG'**
  String get lootLog;

  /// No description provided for @noLootYet.
  ///
  /// In en, this message translates to:
  /// **'No loot yet — go fight something!'**
  String get noLootYet;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// No description provided for @awayFor.
  ///
  /// In en, this message translates to:
  /// **'You were away for {time}.'**
  String awayFor(String time);

  /// No description provided for @awayForCapped.
  ///
  /// In en, this message translates to:
  /// **'You were away for more than {hours}h — showing the maximum idle rewards.'**
  String awayForCapped(int hours);

  /// No description provided for @rewardGold.
  ///
  /// In en, this message translates to:
  /// **'+{amount} gold'**
  String rewardGold(String amount);

  /// No description provided for @rewardXp.
  ///
  /// In en, this message translates to:
  /// **'+{amount} XP'**
  String rewardXp(String amount);

  /// No description provided for @rewardShards.
  ///
  /// In en, this message translates to:
  /// **'+{amount} shards'**
  String rewardShards(String amount);

  /// No description provided for @expeditionsReady.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} expedition ready!} other{{count} expeditions ready!}}'**
  String expeditionsReady(int count);

  /// No description provided for @comebackBonus.
  ///
  /// In en, this message translates to:
  /// **'Comeback bonus:'**
  String get comebackBonus;

  /// No description provided for @idleIncomeCollected.
  ///
  /// In en, this message translates to:
  /// **'Idle income collected while you rested.'**
  String get idleIncomeCollected;

  /// No description provided for @claim.
  ///
  /// In en, this message translates to:
  /// **'CLAIM'**
  String get claim;

  /// No description provided for @milestone.
  ///
  /// In en, this message translates to:
  /// **'MILESTONE'**
  String get milestone;

  /// No description provided for @welcomeBackCaps.
  ///
  /// In en, this message translates to:
  /// **'WELCOME BACK!'**
  String get welcomeBackCaps;

  /// No description provided for @missedYou.
  ///
  /// In en, this message translates to:
  /// **'We missed you! Here\'s a bonus\nfor your time away:'**
  String get missedYou;

  /// No description provided for @newSystemUnlocked.
  ///
  /// In en, this message translates to:
  /// **'NEW SYSTEM UNLOCKED'**
  String get newSystemUnlocked;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'GOT IT'**
  String get gotIt;

  /// No description provided for @welcomeFightTitle.
  ///
  /// In en, this message translates to:
  /// **'Fight!'**
  String get welcomeFightTitle;

  /// No description provided for @welcomeFightBody.
  ///
  /// In en, this message translates to:
  /// **'Go to the PLAY tab and tap a stage card in CAMPAIGN to start your first battle. Keep attacking until the enemy falls!'**
  String get welcomeFightBody;

  /// No description provided for @welcomeIdleTitle.
  ///
  /// In en, this message translates to:
  /// **'Earn idle gold'**
  String get welcomeIdleTitle;

  /// No description provided for @welcomeIdleBody.
  ///
  /// In en, this message translates to:
  /// **'Your hero earns gold automatically every minute, even when you\'re not fighting. Watch the gold bar on the HERO tab fill up.'**
  String get welcomeIdleBody;

  /// No description provided for @welcomeStrongerTitle.
  ///
  /// In en, this message translates to:
  /// **'Get stronger'**
  String get welcomeStrongerTitle;

  /// No description provided for @welcomeStrongerBody.
  ///
  /// In en, this message translates to:
  /// **'Spend gold in UPGRADES to raise your stats. Open PASSIVES for permanent bonuses, and ABILITIES for powerful combat skills.'**
  String get welcomeStrongerBody;

  /// No description provided for @welcomeExploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get welcomeExploreTitle;

  /// No description provided for @welcomeExploreBody.
  ///
  /// In en, this message translates to:
  /// **'CAMPAIGN advances through 100 hand-crafted stages. TOWER ASCENSION lets you grind shards forever. The DUNGEON is a roguelite run with item drops and boss fights. More modes unlock as you progress.'**
  String get welcomeExploreBody;

  /// No description provided for @navBack.
  ///
  /// In en, this message translates to:
  /// **'BACK'**
  String get navBack;

  /// No description provided for @navNext.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get navNext;

  /// No description provided for @startPlaying.
  ///
  /// In en, this message translates to:
  /// **'START PLAYING'**
  String get startPlaying;

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
