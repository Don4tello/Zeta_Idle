import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';

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
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pl'),
    Locale('pt')
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

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get commonContinue;

  /// No description provided for @heroFalls.
  ///
  /// In en, this message translates to:
  /// **'{name} FALLS'**
  String heroFalls(String name);

  /// No description provided for @battleGrowStronger.
  ///
  /// In en, this message translates to:
  /// **'Grow stronger before trying again.'**
  String get battleGrowStronger;

  /// No description provided for @battleBackToHero.
  ///
  /// In en, this message translates to:
  /// **'BACK TO HERO'**
  String get battleBackToHero;

  /// No description provided for @defeatEndlessTitle.
  ///
  /// In en, this message translates to:
  /// **'ENDLESS MODE'**
  String get defeatEndlessTitle;

  /// No description provided for @defeatEndlessHint.
  ///
  /// In en, this message translates to:
  /// **'Farm XP & gold at your pace'**
  String get defeatEndlessHint;

  /// No description provided for @defeatDungeonHint.
  ///
  /// In en, this message translates to:
  /// **'Earn shards & items'**
  String get defeatDungeonHint;

  /// No description provided for @defeatGauntletHint.
  ///
  /// In en, this message translates to:
  /// **'Earn echoes for upgrades'**
  String get defeatGauntletHint;

  /// No description provided for @defeatDailyTitle.
  ///
  /// In en, this message translates to:
  /// **'DAILY CHALLENGES'**
  String get defeatDailyTitle;

  /// No description provided for @defeatDailyHint.
  ///
  /// In en, this message translates to:
  /// **'Claim rewards for progress'**
  String get defeatDailyHint;

  /// No description provided for @battleTierUnlocked.
  ///
  /// In en, this message translates to:
  /// **'TIER {tier} UNLOCKED'**
  String battleTierUnlocked(int tier);

  /// No description provided for @battleCampaignCleared.
  ///
  /// In en, this message translates to:
  /// **'CAMPAIGN CLEARED'**
  String get battleCampaignCleared;

  /// No description provided for @battleTierUnlockedBody.
  ///
  /// In en, this message translates to:
  /// **'The Omega has fallen. The campaign restarts at Tier {tier} — tougher enemies and better loot.\n\nYour level, Paragon, gear and currencies all carry over. Nothing resets.'**
  String battleTierUnlockedBody(int tier);

  /// No description provided for @battleCampaignClearedBody.
  ///
  /// In en, this message translates to:
  /// **'The Omega has fallen at the highest tier. You\'ve reached the summit — keep farming for loot and Paragon Points.'**
  String get battleCampaignClearedBody;

  /// No description provided for @battleSwitchTiersHint.
  ///
  /// In en, this message translates to:
  /// **'Switch tiers anytime from the Campaign header.'**
  String get battleSwitchTiersHint;

  /// No description provided for @battleRetreat.
  ///
  /// In en, this message translates to:
  /// **'Retreat'**
  String get battleRetreat;

  /// No description provided for @battleLastFightSummary.
  ///
  /// In en, this message translates to:
  /// **'Last fight summary'**
  String get battleLastFightSummary;

  /// No description provided for @battleResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get battleResume;

  /// No description provided for @battlePause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get battlePause;

  /// No description provided for @battleAutoCampaignLocked.
  ///
  /// In en, this message translates to:
  /// **'Auto-Campaign — Speed Boost / Premium Pass'**
  String get battleAutoCampaignLocked;

  /// No description provided for @battleAutoCampaignOn.
  ///
  /// In en, this message translates to:
  /// **'Auto-Campaign: ON'**
  String get battleAutoCampaignOn;

  /// No description provided for @battleAutoCampaignOff.
  ///
  /// In en, this message translates to:
  /// **'Auto-Campaign: OFF'**
  String get battleAutoCampaignOff;

  /// No description provided for @battleNoFightYet.
  ///
  /// In en, this message translates to:
  /// **'No fight finished yet.'**
  String get battleNoFightYet;

  /// No description provided for @battleAutoCampaignPerk.
  ///
  /// In en, this message translates to:
  /// **'Auto-Campaign is a Speed Boost / Premium Pass perk.'**
  String get battleAutoCampaignPerk;

  /// No description provided for @battleNoActiveBattle.
  ///
  /// In en, this message translates to:
  /// **'NO ACTIVE BATTLE'**
  String get battleNoActiveBattle;

  /// No description provided for @battleVictory.
  ///
  /// In en, this message translates to:
  /// **'VICTORY!'**
  String get battleVictory;

  /// No description provided for @battleBossDefeated.
  ///
  /// In en, this message translates to:
  /// **'BOSS DEFEATED'**
  String get battleBossDefeated;

  /// No description provided for @battleNewContentUnlocked.
  ///
  /// In en, this message translates to:
  /// **'NEW CONTENT UNLOCKED'**
  String get battleNewContentUnlocked;

  /// No description provided for @battleClassQuestlineUnlocked.
  ///
  /// In en, this message translates to:
  /// **'CLASS QUESTLINE UNLOCKED'**
  String get battleClassQuestlineUnlocked;

  /// No description provided for @battleClassQuestlineBody.
  ///
  /// In en, this message translates to:
  /// **'The {className} path begins. Complete 5 quests to unlock your Ultimate Ability.'**
  String battleClassQuestlineBody(String className);

  /// No description provided for @battleRewardGold.
  ///
  /// In en, this message translates to:
  /// **'+{amount} GOLD'**
  String battleRewardGold(String amount);

  /// No description provided for @battleRewardXp.
  ///
  /// In en, this message translates to:
  /// **'+{amount} XP'**
  String battleRewardXp(String amount);

  /// No description provided for @battleRewardShards.
  ///
  /// In en, this message translates to:
  /// **'+{amount} SHARDS'**
  String battleRewardShards(String amount);

  /// No description provided for @battleAbilityUnlocked.
  ///
  /// In en, this message translates to:
  /// **'ABILITY UNLOCKED: {name}'**
  String battleAbilityUnlocked(String name);

  /// No description provided for @battleAddedToBag.
  ///
  /// In en, this message translates to:
  /// **'Added to Bag'**
  String get battleAddedToBag;

  /// No description provided for @battleFight.
  ///
  /// In en, this message translates to:
  /// **'FIGHT  (−1 ⚡)'**
  String get battleFight;

  /// No description provided for @battleSpeedBoostTitle.
  ///
  /// In en, this message translates to:
  /// **'2× Speed Boost'**
  String get battleSpeedBoostTitle;

  /// No description provided for @battleSpeedBoostBody.
  ///
  /// In en, this message translates to:
  /// **'Unlock 2× battle speed for 7 days?\n\nCost: {cost} ZCoins\nYour ZCoins: {have}'**
  String battleSpeedBoostBody(int cost, int have);

  /// No description provided for @battlePurchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get battlePurchase;

  /// No description provided for @battleNotEnoughZcoins.
  ///
  /// In en, this message translates to:
  /// **'Not enough zcoins!'**
  String get battleNotEnoughZcoins;

  /// No description provided for @battleArtifactFound.
  ///
  /// In en, this message translates to:
  /// **'ARTIFACT FOUND!'**
  String get battleArtifactFound;

  /// No description provided for @battleRoundsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} round remaining} other{{count} rounds remaining}}'**
  String battleRoundsRemaining(int count);

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @campaignDifficultyTier.
  ///
  /// In en, this message translates to:
  /// **'DIFFICULTY TIER'**
  String get campaignDifficultyTier;

  /// No description provided for @campaignDifficultyTierTooltip.
  ///
  /// In en, this message translates to:
  /// **'Difficulty Tier'**
  String get campaignDifficultyTierTooltip;

  /// No description provided for @campaignTierSelectorBody.
  ///
  /// In en, this message translates to:
  /// **'Higher tiers = tougher enemies AND better loot (rarity, sets, artifacts). Switching down keeps all your permanent power — it only scales what you fight and what drops.'**
  String get campaignTierSelectorBody;

  /// No description provided for @campaignTierNormal.
  ///
  /// In en, this message translates to:
  /// **'TIER 0 — Normal'**
  String get campaignTierNormal;

  /// No description provided for @campaignTierN.
  ///
  /// In en, this message translates to:
  /// **'TIER {tier}'**
  String campaignTierN(int tier);

  /// No description provided for @campaignTierBaseDesc.
  ///
  /// In en, this message translates to:
  /// **'Base enemies · base loot · no Magic Find'**
  String get campaignTierBaseDesc;

  /// No description provided for @campaignTierScaledDesc.
  ///
  /// In en, this message translates to:
  /// **'Enemies +{hp}% HP · +{atk}% ATK'**
  String campaignTierScaledDesc(int hp, int atk);

  /// No description provided for @campaignTierMagicFind.
  ///
  /// In en, this message translates to:
  /// **'✦ +{mf}% Magic Find (higher rarity, sets & artifacts)'**
  String campaignTierMagicFind(int mf);

  /// No description provided for @campaignLeaderboardTooltip.
  ///
  /// In en, this message translates to:
  /// **'Campaign Leaderboard'**
  String get campaignLeaderboardTooltip;

  /// No description provided for @campaignTutorial.
  ///
  /// In en, this message translates to:
  /// **'Campaign advances stage by stage. Defeat each boss to unlock the next. Clear the final boss to unlock the next difficulty Tier — the campaign restarts harder with better loot, and your power carries over.'**
  String get campaignTutorial;

  /// No description provided for @campaignEnergyRecharge.
  ///
  /// In en, this message translates to:
  /// **'+1 in {time}'**
  String campaignEnergyRecharge(String time);

  /// No description provided for @campaignEnergyRefill.
  ///
  /// In en, this message translates to:
  /// **'Refill +{amount}  ({left} free left)'**
  String campaignEnergyRefill(int amount, int left);

  /// No description provided for @campaignBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy '**
  String get campaignBuy;

  /// No description provided for @campaignEnergyEmptyTutorial.
  ///
  /// In en, this message translates to:
  /// **'Out of energy! ⚡ It refills 1 every 5 min. Tap the +10 button above for 3 free daily refills. Or buy +20 energy for 💎 50 ZCoins.'**
  String get campaignEnergyEmptyTutorial;

  /// No description provided for @campaignStageMap.
  ///
  /// In en, this message translates to:
  /// **'STAGE MAP  •  tap any ✓ node to replay'**
  String get campaignStageMap;

  /// No description provided for @campaignNoEnergyRefill.
  ///
  /// In en, this message translates to:
  /// **'No energy! Wait for it to refill.'**
  String get campaignNoEnergyRefill;

  /// No description provided for @campaignSimulateStage.
  ///
  /// In en, this message translates to:
  /// **'⚡ Simulate Stage {stage}'**
  String campaignSimulateStage(int stage);

  /// No description provided for @campaignEnergyAvailable.
  ///
  /// In en, this message translates to:
  /// **'Energy available: {count}'**
  String campaignEnergyAvailable(int count);

  /// No description provided for @campaignSimInfo.
  ///
  /// In en, this message translates to:
  /// **'Battles run instantly. Loot goes straight to your bag.'**
  String get campaignSimInfo;

  /// No description provided for @campaignSimAll.
  ///
  /// In en, this message translates to:
  /// **'ALL ({count})'**
  String campaignSimAll(int count);

  /// No description provided for @campaignSimResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Stage {stage} — {count}× Simulated'**
  String campaignSimResultTitle(int stage, int count);

  /// No description provided for @campaignSimGold.
  ///
  /// In en, this message translates to:
  /// **'💰 Gold'**
  String get campaignSimGold;

  /// No description provided for @campaignSimXp.
  ///
  /// In en, this message translates to:
  /// **'✦ XP'**
  String get campaignSimXp;

  /// No description provided for @campaignItemsDropped.
  ///
  /// In en, this message translates to:
  /// **'Items dropped ({count}):'**
  String campaignItemsDropped(int count);

  /// No description provided for @campaignNoItemsDropped.
  ///
  /// In en, this message translates to:
  /// **'No items dropped this run.'**
  String get campaignNoItemsDropped;

  /// No description provided for @campaignNotEnoughEnergy.
  ///
  /// In en, this message translates to:
  /// **'Not enough energy!'**
  String get campaignNotEnoughEnergy;

  /// No description provided for @campaignMapFight.
  ///
  /// In en, this message translates to:
  /// **'⚔  FIGHT (−1 ⚡)'**
  String get campaignMapFight;

  /// No description provided for @campaignSimRequiresPremium.
  ///
  /// In en, this message translates to:
  /// **'Requires Premium Pass subscription'**
  String get campaignSimRequiresPremium;

  /// No description provided for @campaignBossEncounter.
  ///
  /// In en, this message translates to:
  /// **'BOSS ENCOUNTER'**
  String get campaignBossEncounter;

  /// No description provided for @campaignDismiss.
  ///
  /// In en, this message translates to:
  /// **'[ dismiss ]'**
  String get campaignDismiss;

  /// No description provided for @campaignPerfectStages.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} perfect stage} other{{count} perfect stages}}'**
  String campaignPerfectStages(int count);

  /// No description provided for @campaignNextMilestone.
  ///
  /// In en, this message translates to:
  /// **'• next milestone at {next} (+mythril +Z-Coins)'**
  String campaignNextMilestone(int next);

  /// No description provided for @campaignAllMilestones.
  ///
  /// In en, this message translates to:
  /// **'• all milestones cleared!'**
  String get campaignAllMilestones;

  /// No description provided for @hubWhatsNew.
  ///
  /// In en, this message translates to:
  /// **'What\'s New'**
  String get hubWhatsNew;

  /// No description provided for @hubLootLog.
  ///
  /// In en, this message translates to:
  /// **'Loot Log'**
  String get hubLootLog;

  /// No description provided for @hubSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get hubSettings;

  /// No description provided for @hubChange.
  ///
  /// In en, this message translates to:
  /// **'CHANGE'**
  String get hubChange;

  /// No description provided for @hubHeroMenu.
  ///
  /// In en, this message translates to:
  /// **'Hero menu'**
  String get hubHeroMenu;

  /// No description provided for @hubJoinDiscord.
  ///
  /// In en, this message translates to:
  /// **'Join our Discord'**
  String get hubJoinDiscord;

  /// No description provided for @hubVisitReddit.
  ///
  /// In en, this message translates to:
  /// **'Visit r/zeta_idle'**
  String get hubVisitReddit;

  /// No description provided for @hubCouldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Could not open {url}'**
  String hubCouldNotOpen(String url);

  /// No description provided for @hubLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get hubLocked;

  /// No description provided for @hubGroupCharacter.
  ///
  /// In en, this message translates to:
  /// **'CHARACTER'**
  String get hubGroupCharacter;

  /// No description provided for @hubGroupProgression.
  ///
  /// In en, this message translates to:
  /// **'PROGRESSION'**
  String get hubGroupProgression;

  /// No description provided for @hubGroupCollection.
  ///
  /// In en, this message translates to:
  /// **'COLLECTION'**
  String get hubGroupCollection;

  /// No description provided for @hubGroupRecords.
  ///
  /// In en, this message translates to:
  /// **'RECORDS'**
  String get hubGroupRecords;

  /// No description provided for @hubBlurbCharacter.
  ///
  /// In en, this message translates to:
  /// **'Your build & power'**
  String get hubBlurbCharacter;

  /// No description provided for @hubBlurbProgression.
  ///
  /// In en, this message translates to:
  /// **'Endgame systems'**
  String get hubBlurbProgression;

  /// No description provided for @hubBlurbCollection.
  ///
  /// In en, this message translates to:
  /// **'Allies & compendium'**
  String get hubBlurbCollection;

  /// No description provided for @hubBlurbRecords.
  ///
  /// In en, this message translates to:
  /// **'Goals & breakdowns'**
  String get hubBlurbRecords;

  /// No description provided for @hubSheet.
  ///
  /// In en, this message translates to:
  /// **'SHEET'**
  String get hubSheet;

  /// No description provided for @hubScores.
  ///
  /// In en, this message translates to:
  /// **'SCORES'**
  String get hubScores;

  /// No description provided for @hubAbilities.
  ///
  /// In en, this message translates to:
  /// **'ABILITIES'**
  String get hubAbilities;

  /// No description provided for @hubPassives.
  ///
  /// In en, this message translates to:
  /// **'PASSIVES'**
  String get hubPassives;

  /// No description provided for @hubSpecialize.
  ///
  /// In en, this message translates to:
  /// **'SPECIALIZE'**
  String get hubSpecialize;

  /// No description provided for @hubParagon.
  ///
  /// In en, this message translates to:
  /// **'PARAGON'**
  String get hubParagon;

  /// No description provided for @hubUpgrades.
  ///
  /// In en, this message translates to:
  /// **'UPGRADES'**
  String get hubUpgrades;

  /// No description provided for @hubAscend.
  ///
  /// In en, this message translates to:
  /// **'ASCEND'**
  String get hubAscend;

  /// No description provided for @hubMastery.
  ///
  /// In en, this message translates to:
  /// **'MASTERY'**
  String get hubMastery;

  /// No description provided for @hubPets.
  ///
  /// In en, this message translates to:
  /// **'PETS'**
  String get hubPets;

  /// No description provided for @hubMercs.
  ///
  /// In en, this message translates to:
  /// **'MERCS'**
  String get hubMercs;

  /// No description provided for @hubBestiary.
  ///
  /// In en, this message translates to:
  /// **'BESTIARY'**
  String get hubBestiary;

  /// No description provided for @hubCodex.
  ///
  /// In en, this message translates to:
  /// **'CODEX'**
  String get hubCodex;

  /// No description provided for @hubArmory.
  ///
  /// In en, this message translates to:
  /// **'ARMORY'**
  String get hubArmory;

  /// No description provided for @hubAchievements.
  ///
  /// In en, this message translates to:
  /// **'ACHIEVEMENTS'**
  String get hubAchievements;

  /// No description provided for @hubBonuses.
  ///
  /// In en, this message translates to:
  /// **'BONUSES'**
  String get hubBonuses;

  /// No description provided for @auShards.
  ///
  /// In en, this message translates to:
  /// **'shards'**
  String get auShards;

  /// No description provided for @auRespecTitle.
  ///
  /// In en, this message translates to:
  /// **'Respec Abilities?'**
  String get auRespecTitle;

  /// No description provided for @auRespecBody.
  ///
  /// In en, this message translates to:
  /// **'Reset all ability ranks and milestone choices.\nAll shards spent will be refunded.\n\nCost: {cost} ZCoins'**
  String auRespecBody(int cost);

  /// No description provided for @auRespecConfirm.
  ///
  /// In en, this message translates to:
  /// **'RESPEC ({cost} ZC)'**
  String auRespecConfirm(int cost);

  /// No description provided for @auRespec.
  ///
  /// In en, this message translates to:
  /// **'RESPEC'**
  String get auRespec;

  /// No description provided for @auTutorial.
  ///
  /// In en, this message translates to:
  /// **'You earned Shards ◆ — spend them here to unlock and upgrade class abilities that fire automatically in every battle.'**
  String get auTutorial;

  /// No description provided for @auIntro.
  ///
  /// In en, this message translates to:
  /// **'Spend shards to empower your abilities. Milestones at ranks 5, 10 and 15. Tier up after rank 15 — each tier unlocks with your difficulty Tier.'**
  String get auIntro;

  /// No description provided for @auTitle.
  ///
  /// In en, this message translates to:
  /// **'ABILITY UPGRADES'**
  String get auTitle;

  /// No description provided for @auMaxTier.
  ///
  /// In en, this message translates to:
  /// **'MAX TIER  ✦'**
  String get auMaxTier;

  /// No description provided for @auTierLockedLabel.
  ///
  /// In en, this message translates to:
  /// **'TIER {tier}  —  Requires Difficulty Tier {req}'**
  String auTierLockedLabel(int tier, int req);

  /// No description provided for @auAscension.
  ///
  /// In en, this message translates to:
  /// **'ASCENSION'**
  String get auAscension;

  /// No description provided for @auTierUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Tier {cap} unlocked'**
  String auTierUnlocked(int cap);

  /// No description provided for @auAscFullyAscended.
  ///
  /// In en, this message translates to:
  /// **'Fully ascended  ·  +{pct}% ability power'**
  String auAscFullyAscended(int pct);

  /// No description provided for @auAscTierLocked.
  ///
  /// In en, this message translates to:
  /// **'+{cur}% power  ·  Unlock difficulty Tier {next} (rebirth) to ascend further'**
  String auAscTierLocked(int cur, int next);

  /// No description provided for @auAscUpgrade.
  ///
  /// In en, this message translates to:
  /// **'+{cur}%  →  +{next}% power  ·  costs {cost} ✦ Paragon'**
  String auAscUpgrade(int cur, int next, int cost);

  /// No description provided for @auAscYouHave.
  ///
  /// In en, this message translates to:
  /// **'  (you have {have})'**
  String auAscYouHave(int have);

  /// No description provided for @auMax.
  ///
  /// In en, this message translates to:
  /// **'MAX'**
  String get auMax;

  /// No description provided for @auLocked.
  ///
  /// In en, this message translates to:
  /// **'LOCKED'**
  String get auLocked;

  /// No description provided for @auAscendBtn.
  ///
  /// In en, this message translates to:
  /// **'ASCEND  {cost} ✦'**
  String auAscendBtn(int cost);

  /// No description provided for @auUltimate.
  ///
  /// In en, this message translates to:
  /// **'ULTIMATE'**
  String get auUltimate;

  /// No description provided for @auUnlocksLv.
  ///
  /// In en, this message translates to:
  /// **'UNLOCKS LV {lv}'**
  String auUnlocksLv(int lv);

  /// No description provided for @auFinishQuestline.
  ///
  /// In en, this message translates to:
  /// **'🔒 Finish your class questline to unlock'**
  String get auFinishQuestline;

  /// No description provided for @auReachLevel.
  ///
  /// In en, this message translates to:
  /// **'Reach Level {lv}  (you: Lv {cur})'**
  String auReachLevel(int lv, int cur);

  /// No description provided for @auCompleteQuests.
  ///
  /// In en, this message translates to:
  /// **'Complete all 5 {className} class quests  ({claimed} / 5)'**
  String auCompleteQuests(String className, int claimed);

  /// No description provided for @auTrackQuests.
  ///
  /// In en, this message translates to:
  /// **'Track your quests in the Quests tab.'**
  String get auTrackQuests;

  /// No description provided for @auChoose.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE'**
  String get auChoose;

  /// No description provided for @setTitle.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get setTitle;

  /// No description provided for @setSave.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get setSave;

  /// No description provided for @setLoad.
  ///
  /// In en, this message translates to:
  /// **'LOAD'**
  String get setLoad;

  /// No description provided for @setReset.
  ///
  /// In en, this message translates to:
  /// **'RESET'**
  String get setReset;

  /// No description provided for @setOpen.
  ///
  /// In en, this message translates to:
  /// **'OPEN'**
  String get setOpen;

  /// No description provided for @setView.
  ///
  /// In en, this message translates to:
  /// **'VIEW'**
  String get setView;

  /// No description provided for @setEmail.
  ///
  /// In en, this message translates to:
  /// **'EMAIL'**
  String get setEmail;

  /// No description provided for @setConfirm.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM'**
  String get setConfirm;

  /// No description provided for @setSecAccount.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get setSecAccount;

  /// No description provided for @setSecPromo.
  ///
  /// In en, this message translates to:
  /// **'PROMO CODE'**
  String get setSecPromo;

  /// No description provided for @setSecAudio.
  ///
  /// In en, this message translates to:
  /// **'AUDIO'**
  String get setSecAudio;

  /// No description provided for @setSecHaptics.
  ///
  /// In en, this message translates to:
  /// **'HAPTICS'**
  String get setSecHaptics;

  /// No description provided for @setSecNotifications.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get setSecNotifications;

  /// No description provided for @setSecDisplay.
  ///
  /// In en, this message translates to:
  /// **'DISPLAY'**
  String get setSecDisplay;

  /// No description provided for @setSecStats.
  ///
  /// In en, this message translates to:
  /// **'STATS'**
  String get setSecStats;

  /// No description provided for @setSecAutoLoot.
  ///
  /// In en, this message translates to:
  /// **'AUTO-LOOT'**
  String get setSecAutoLoot;

  /// No description provided for @setSecBattle.
  ///
  /// In en, this message translates to:
  /// **'BATTLE'**
  String get setSecBattle;

  /// No description provided for @setSecDailyReset.
  ///
  /// In en, this message translates to:
  /// **'DAILY RESET'**
  String get setSecDailyReset;

  /// No description provided for @setSecSave.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get setSecSave;

  /// No description provided for @setSecDanger.
  ///
  /// In en, this message translates to:
  /// **'DANGER ZONE'**
  String get setSecDanger;

  /// No description provided for @setSecHelp.
  ///
  /// In en, this message translates to:
  /// **'HELP'**
  String get setSecHelp;

  /// No description provided for @setSecAbout.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get setSecAbout;

  /// No description provided for @setManage.
  ///
  /// In en, this message translates to:
  /// **'MANAGE'**
  String get setManage;

  /// No description provided for @setSignIn.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN'**
  String get setSignIn;

  /// No description provided for @setHeroName.
  ///
  /// In en, this message translates to:
  /// **'Hero Name'**
  String get setHeroName;

  /// No description provided for @setRename.
  ///
  /// In en, this message translates to:
  /// **'RENAME ({cost} 🪙)'**
  String setRename(int cost);

  /// No description provided for @setPromoHint.
  ///
  /// In en, this message translates to:
  /// **'Got a code? Redeem it here for rewards.'**
  String get setPromoHint;

  /// No description provided for @setRedeem.
  ///
  /// In en, this message translates to:
  /// **'REDEEM'**
  String get setRedeem;

  /// No description provided for @setSoundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get setSoundEffects;

  /// No description provided for @setBackgroundMusic.
  ///
  /// In en, this message translates to:
  /// **'Background Music'**
  String get setBackgroundMusic;

  /// No description provided for @setVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get setVolume;

  /// No description provided for @setVibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get setVibration;

  /// No description provided for @setReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get setReminders;

  /// No description provided for @setDamageNumbers.
  ///
  /// In en, this message translates to:
  /// **'Damage Numbers'**
  String get setDamageNumbers;

  /// No description provided for @setReducedParticles.
  ///
  /// In en, this message translates to:
  /// **'Reduced Particles'**
  String get setReducedParticles;

  /// No description provided for @setTotalPlaytime.
  ///
  /// In en, this message translates to:
  /// **'Total Playtime'**
  String get setTotalPlaytime;

  /// No description provided for @setAutoSalvage.
  ///
  /// In en, this message translates to:
  /// **'Auto-Salvage'**
  String get setAutoSalvage;

  /// No description provided for @setAutoEquip.
  ///
  /// In en, this message translates to:
  /// **'Auto-Equip Upgrades'**
  String get setAutoEquip;

  /// No description provided for @setAutoEquipSub.
  ///
  /// In en, this message translates to:
  /// **'Automatically equip items better than current gear'**
  String get setAutoEquipSub;

  /// No description provided for @setBattleSpeed.
  ///
  /// In en, this message translates to:
  /// **'Battle Speed'**
  String get setBattleSpeed;

  /// No description provided for @setAutoCampaign.
  ///
  /// In en, this message translates to:
  /// **'Auto-Campaign'**
  String get setAutoCampaign;

  /// No description provided for @setResetTime.
  ///
  /// In en, this message translates to:
  /// **'Reset Time'**
  String get setResetTime;

  /// No description provided for @setCloudSave.
  ///
  /// In en, this message translates to:
  /// **'Cloud Save'**
  String get setCloudSave;

  /// No description provided for @setCloudSaveSub.
  ///
  /// In en, this message translates to:
  /// **'Sync your progress to the cloud'**
  String get setCloudSaveSub;

  /// No description provided for @setCloudSaveComplete.
  ///
  /// In en, this message translates to:
  /// **'Cloud save complete.'**
  String get setCloudSaveComplete;

  /// No description provided for @setLoadCloud.
  ///
  /// In en, this message translates to:
  /// **'Load from Cloud'**
  String get setLoadCloud;

  /// No description provided for @setLoadCloudSub.
  ///
  /// In en, this message translates to:
  /// **'Overwrite local save with cloud data'**
  String get setLoadCloudSub;

  /// No description provided for @setResetProgress.
  ///
  /// In en, this message translates to:
  /// **'Reset Progress'**
  String get setResetProgress;

  /// No description provided for @setResetProgressSub.
  ///
  /// In en, this message translates to:
  /// **'Delete all save data for this slot. Irreversible.'**
  String get setResetProgressSub;

  /// No description provided for @setKnowledgeBase.
  ///
  /// In en, this message translates to:
  /// **'Knowledge Base'**
  String get setKnowledgeBase;

  /// No description provided for @setKnowledgeBaseSub.
  ///
  /// In en, this message translates to:
  /// **'Keywords, systems, currencies explained'**
  String get setKnowledgeBaseSub;

  /// No description provided for @setTagline.
  ///
  /// In en, this message translates to:
  /// **'A dark medieval idle RPG.'**
  String get setTagline;

  /// No description provided for @setAboutHero.
  ///
  /// In en, this message translates to:
  /// **'Hero'**
  String get setAboutHero;

  /// No description provided for @setAboutClass.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get setAboutClass;

  /// No description provided for @setAboutLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get setAboutLevel;

  /// No description provided for @setAboutPrestige.
  ///
  /// In en, this message translates to:
  /// **'Prestige'**
  String get setAboutPrestige;

  /// No description provided for @setAboutAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get setAboutAchievements;

  /// No description provided for @setAboutDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get setAboutDeveloper;

  /// No description provided for @setAboutContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get setAboutContact;

  /// No description provided for @setPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get setPrivacy;

  /// No description provided for @setPrivacySub.
  ///
  /// In en, this message translates to:
  /// **'How we handle your data'**
  String get setPrivacySub;

  /// No description provided for @setReportBug.
  ///
  /// In en, this message translates to:
  /// **'Report a Bug / Feedback'**
  String get setReportBug;

  /// No description provided for @setReportBugSub.
  ///
  /// In en, this message translates to:
  /// **'Email us — device info is added automatically'**
  String get setReportBugSub;

  /// No description provided for @setReplayTips.
  ///
  /// In en, this message translates to:
  /// **'Replay Tips'**
  String get setReplayTips;

  /// No description provided for @setReplayTipsSub.
  ///
  /// In en, this message translates to:
  /// **'Show the in-game tutorial tips again'**
  String get setReplayTipsSub;

  /// No description provided for @setTipsReset.
  ///
  /// In en, this message translates to:
  /// **'Tutorial tips reset — they\'ll reappear as you explore.'**
  String get setTipsReset;

  /// No description provided for @setRenameHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'RENAME HERO'**
  String get setRenameHeroTitle;

  /// No description provided for @setHeroNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a hero name'**
  String get setHeroNameHint;

  /// No description provided for @setRenameCost.
  ///
  /// In en, this message translates to:
  /// **'Cost: {cost} 🪙   (you have {have})'**
  String setRenameCost(int cost, int have);

  /// No description provided for @setRenameNotEnough.
  ///
  /// In en, this message translates to:
  /// **'Not enough Z-Coins — rename costs {cost} 🪙.'**
  String setRenameNotEnough(int cost);

  /// No description provided for @setNoEmailApp.
  ///
  /// In en, this message translates to:
  /// **'No email app found. Reach us at razorintegrations@gmail.com'**
  String get setNoEmailApp;

  /// No description provided for @setDailyResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Reset Time'**
  String get setDailyResetTitle;

  /// No description provided for @setDailyResetHint.
  ///
  /// In en, this message translates to:
  /// **'Choose the hour when daily limits reset.'**
  String get setDailyResetHint;

  /// No description provided for @setDailyResetWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: you can only change this once per year.'**
  String get setDailyResetWarning;

  /// No description provided for @setLoadCloudTitle.
  ///
  /// In en, this message translates to:
  /// **'Load from Cloud?'**
  String get setLoadCloudTitle;

  /// No description provided for @setLoadCloudBody.
  ///
  /// In en, this message translates to:
  /// **'This will overwrite your local save with cloud data. Local progress not yet synced will be lost.'**
  String get setLoadCloudBody;

  /// No description provided for @setResetAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset all progress?'**
  String get setResetAllTitle;

  /// No description provided for @setResetAllBody.
  ///
  /// In en, this message translates to:
  /// **'All progress, gold, items, prestige levels, and achievements will be permanently deleted. This cannot be undone.'**
  String get setResetAllBody;

  /// No description provided for @setNewHeroName.
  ///
  /// In en, this message translates to:
  /// **'New hero name:'**
  String get setNewHeroName;

  /// No description provided for @setGoogleAccount.
  ///
  /// In en, this message translates to:
  /// **'Google Account'**
  String get setGoogleAccount;

  /// No description provided for @setSignInGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get setSignInGoogle;

  /// No description provided for @setSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get setSignedIn;

  /// No description provided for @setSyncSaves.
  ///
  /// In en, this message translates to:
  /// **'Sync saves across devices'**
  String get setSyncSaves;

  /// No description provided for @setEnterCode.
  ///
  /// In en, this message translates to:
  /// **'ENTER CODE'**
  String get setEnterCode;

  /// No description provided for @setOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get setOff;

  /// No description provided for @setOffCaps.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get setOffCaps;

  /// No description provided for @setHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get setHidden;

  /// No description provided for @setVibrationOn.
  ///
  /// In en, this message translates to:
  /// **'Vibrates on crits, level-ups, victories & rewards'**
  String get setVibrationOn;

  /// No description provided for @setRemindersOn.
  ///
  /// In en, this message translates to:
  /// **'Get \"come back\" reminders while you\'re away'**
  String get setRemindersOn;

  /// No description provided for @setDamageOn.
  ///
  /// In en, this message translates to:
  /// **'Floating numbers shown in battle'**
  String get setDamageOn;

  /// No description provided for @setParticlesOn.
  ///
  /// In en, this message translates to:
  /// **'Fewer background effects (better performance)'**
  String get setParticlesOn;

  /// No description provided for @setParticlesOff.
  ///
  /// In en, this message translates to:
  /// **'Full effects'**
  String get setParticlesOff;

  /// No description provided for @setSalvageOff.
  ///
  /// In en, this message translates to:
  /// **'Tap to enable auto-salvage for drops'**
  String get setSalvageOff;

  /// No description provided for @setSalvageOn.
  ///
  /// In en, this message translates to:
  /// **'Auto-salvages {tier} and below'**
  String setSalvageOn(String tier);

  /// No description provided for @setAutoCampaignOnSub.
  ///
  /// In en, this message translates to:
  /// **'Automatically fight campaign battles in the background'**
  String get setAutoCampaignOnSub;

  /// No description provided for @setAutoCampaignLockedSub.
  ///
  /// In en, this message translates to:
  /// **'🔒 Speed Boost / Premium Pass subscribers only'**
  String get setAutoCampaignLockedSub;

  /// No description provided for @setResetTimeOn.
  ///
  /// In en, this message translates to:
  /// **'Daily limits reset at {time}. Tap to change (once per year).'**
  String setResetTimeOn(String time);

  /// No description provided for @setResetTimeLocked.
  ///
  /// In en, this message translates to:
  /// **'Resets at {time} · Already changed this year.'**
  String setResetTimeLocked(String time);

  /// No description provided for @guildTitle.
  ///
  /// In en, this message translates to:
  /// **'GUILD'**
  String get guildTitle;

  /// No description provided for @guildJoinTitle.
  ///
  /// In en, this message translates to:
  /// **'JOIN A GUILD'**
  String get guildJoinTitle;

  /// No description provided for @guildJoinBlurb.
  ///
  /// In en, this message translates to:
  /// **'Guilds provide passive bonuses, a weekly boss challenge, and a guild shop with exclusive rewards.'**
  String get guildJoinBlurb;

  /// No description provided for @guildCreate.
  ///
  /// In en, this message translates to:
  /// **'CREATE GUILD'**
  String get guildCreate;

  /// No description provided for @guildPublic.
  ///
  /// In en, this message translates to:
  /// **'PUBLIC GUILDS'**
  String get guildPublic;

  /// No description provided for @guildNoGuilds.
  ///
  /// In en, this message translates to:
  /// **'No guilds found. Be the first to create one!'**
  String get guildNoGuilds;

  /// No description provided for @guildCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Guild'**
  String get guildCreateTitle;

  /// No description provided for @guildNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Guild Name'**
  String get guildNameLabel;

  /// No description provided for @guildDescLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get guildDescLabel;

  /// No description provided for @guildCreateBtn.
  ///
  /// In en, this message translates to:
  /// **'CREATE'**
  String get guildCreateBtn;

  /// No description provided for @guildTabInfo.
  ///
  /// In en, this message translates to:
  /// **'INFO'**
  String get guildTabInfo;

  /// No description provided for @guildTabCastle.
  ///
  /// In en, this message translates to:
  /// **'CASTLE'**
  String get guildTabCastle;

  /// No description provided for @guildTabBoss.
  ///
  /// In en, this message translates to:
  /// **'BOSS'**
  String get guildTabBoss;

  /// No description provided for @guildTabWar.
  ///
  /// In en, this message translates to:
  /// **'WAR'**
  String get guildTabWar;

  /// No description provided for @guildTabChat.
  ///
  /// In en, this message translates to:
  /// **'CHAT'**
  String get guildTabChat;

  /// No description provided for @guildTabShop.
  ///
  /// In en, this message translates to:
  /// **'SHOP'**
  String get guildTabShop;

  /// No description provided for @guildCastleTier.
  ///
  /// In en, this message translates to:
  /// **'CASTLE — TIER {tier} / 10'**
  String guildCastleTier(int tier);

  /// No description provided for @guildProgressTier.
  ///
  /// In en, this message translates to:
  /// **'Progress to Tier {tier}'**
  String guildProgressTier(int tier);

  /// No description provided for @guildCpProgress.
  ///
  /// In en, this message translates to:
  /// **'{cp} / {cap} CP'**
  String guildCpProgress(int cp, int cap);

  /// No description provided for @guildNext.
  ///
  /// In en, this message translates to:
  /// **'Next: {headline}'**
  String guildNext(String headline);

  /// No description provided for @guildCitadelComplete.
  ///
  /// In en, this message translates to:
  /// **'Citadel complete — the castle is fully built!'**
  String get guildCitadelComplete;

  /// No description provided for @guildContributeGold.
  ///
  /// In en, this message translates to:
  /// **'CONTRIBUTE GOLD'**
  String get guildContributeGold;

  /// No description provided for @guildContributeInfo.
  ///
  /// In en, this message translates to:
  /// **'Convert gold to Construction Points (CP). Rate: {rate} gold = 1 CP. You can add up to {cap} CP per day.'**
  String guildContributeInfo(String rate, int cap);

  /// No description provided for @guildActiveBenefits.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE CASTLE BENEFITS'**
  String get guildActiveBenefits;

  /// No description provided for @guildContributeHint.
  ///
  /// In en, this message translates to:
  /// **'Contribute to raise the castle and unlock benefits.'**
  String get guildContributeHint;

  /// No description provided for @guildCastleAdvanced.
  ///
  /// In en, this message translates to:
  /// **'🏰 Castle advanced to Tier {tier}!'**
  String guildCastleAdvanced(int tier);

  /// No description provided for @guildCapReached.
  ///
  /// In en, this message translates to:
  /// **'Daily construction cap reached — come back tomorrow!'**
  String get guildCapReached;

  /// No description provided for @guildLevelMembers.
  ///
  /// In en, this message translates to:
  /// **'Level {lvl}  •  {m}/{max} members'**
  String guildLevelMembers(int lvl, int m, int max);

  /// No description provided for @guildBonusGold.
  ///
  /// In en, this message translates to:
  /// **'+{pct}% Gold'**
  String guildBonusGold(int pct);

  /// No description provided for @guildBonusXp.
  ///
  /// In en, this message translates to:
  /// **'+{pct}% XP'**
  String guildBonusXp(int pct);

  /// No description provided for @guildBonusIdle.
  ///
  /// In en, this message translates to:
  /// **'+{pct}% Idle'**
  String guildBonusIdle(int pct);

  /// No description provided for @guildXpProgress.
  ///
  /// In en, this message translates to:
  /// **'{xp}/{max} XP'**
  String guildXpProgress(int xp, int max);

  /// No description provided for @guildDonate1000.
  ///
  /// In en, this message translates to:
  /// **'DONATE 1000 GOLD'**
  String get guildDonate1000;

  /// No description provided for @guildDonateReward.
  ///
  /// In en, this message translates to:
  /// **'→ Guild XP + 🪙'**
  String get guildDonateReward;

  /// No description provided for @guildPerks.
  ///
  /// In en, this message translates to:
  /// **'PERKS'**
  String get guildPerks;

  /// No description provided for @guildLockedPerk.
  ///
  /// In en, this message translates to:
  /// **'🔒 Lv{lvl}: {name} — {desc}'**
  String guildLockedPerk(int lvl, String name, String desc);

  /// No description provided for @guildMembers.
  ///
  /// In en, this message translates to:
  /// **'MEMBERS'**
  String get guildMembers;

  /// No description provided for @guildMemberLine.
  ///
  /// In en, this message translates to:
  /// **'Lv{lvl} {cls}  •  {role}  •  donated: {d}g'**
  String guildMemberLine(int lvl, String cls, String role, int d);

  /// No description provided for @guildLeave.
  ///
  /// In en, this message translates to:
  /// **'LEAVE GUILD'**
  String get guildLeave;

  /// No description provided for @guildNoBoss.
  ///
  /// In en, this message translates to:
  /// **'No boss this week.'**
  String get guildNoBoss;

  /// No description provided for @guildWeeklyBoss.
  ///
  /// In en, this message translates to:
  /// **'☠ WEEKLY GUILD BOSS'**
  String get guildWeeklyBoss;

  /// No description provided for @guildBossHp.
  ///
  /// In en, this message translates to:
  /// **'{hp} / {max} HP'**
  String guildBossHp(int hp, int max);

  /// No description provided for @guildDefeated.
  ///
  /// In en, this message translates to:
  /// **'✓ DEFEATED'**
  String get guildDefeated;

  /// No description provided for @guildBossRewardMsg.
  ///
  /// In en, this message translates to:
  /// **'🏆 Last week\'s boss: Rank #{rank} — +{gc} Guild Coins, +{gold} gold'**
  String guildBossRewardMsg(Object rank, Object gc, Object gold);

  /// No description provided for @guildClaimBossReward.
  ///
  /// In en, this message translates to:
  /// **'🏆 CLAIM LAST WEEK\'S BOSS REWARD'**
  String get guildClaimBossReward;

  /// No description provided for @guildAttempts.
  ///
  /// In en, this message translates to:
  /// **'Attempts: {rem} / {max}'**
  String guildAttempts(int rem, int max);

  /// No description provided for @guildNoAttempts.
  ///
  /// In en, this message translates to:
  /// **'NO ATTEMPTS LEFT'**
  String get guildNoAttempts;

  /// No description provided for @guildChallengeBoss.
  ///
  /// In en, this message translates to:
  /// **'⚔ CHALLENGE BOSS'**
  String get guildChallengeBoss;

  /// No description provided for @guildDamageRanking.
  ///
  /// In en, this message translates to:
  /// **'DAMAGE RANKING'**
  String get guildDamageRanking;

  /// No description provided for @guildDmg.
  ///
  /// In en, this message translates to:
  /// **'{dmg} dmg'**
  String guildDmg(int dmg);

  /// No description provided for @guildWarStandings.
  ///
  /// In en, this message translates to:
  /// **'WAR STANDINGS'**
  String get guildWarStandings;

  /// No description provided for @guildWarRecord.
  ///
  /// In en, this message translates to:
  /// **'Your record: {w}W–{l}L'**
  String guildWarRecord(int w, int l);

  /// No description provided for @guildWeeklyWar.
  ///
  /// In en, this message translates to:
  /// **'Weekly Guild War'**
  String get guildWeeklyWar;

  /// No description provided for @guildWarBlurb.
  ///
  /// In en, this message translates to:
  /// **'Enlist during Preparation (Mon–Tue). Wed–Fri, spend War Attacks to fight rival champions and earn points for your guild. Sat–Sun, claim rank rewards.'**
  String get guildWarBlurb;

  /// No description provided for @guildEnlistedBattle.
  ///
  /// In en, this message translates to:
  /// **'⚔ Enlisted! Spend your War Attacks now.'**
  String get guildEnlistedBattle;

  /// No description provided for @guildEnlistedPrep.
  ///
  /// In en, this message translates to:
  /// **'⚔ Enlisted! Return Wed–Fri to fight.'**
  String get guildEnlistedPrep;

  /// No description provided for @guildEnlist.
  ///
  /// In en, this message translates to:
  /// **'ENLIST YOUR GUILD'**
  String get guildEnlist;

  /// No description provided for @guildWarEndedWait.
  ///
  /// In en, this message translates to:
  /// **'WAR ENDED — WAIT FOR NEXT WEEK'**
  String get guildWarEndedWait;

  /// No description provided for @guildScoreYou.
  ///
  /// In en, this message translates to:
  /// **'{name} (you)'**
  String guildScoreYou(String name);

  /// No description provided for @guildLeads.
  ///
  /// In en, this message translates to:
  /// **'🏆 Your guild leads!'**
  String get guildLeads;

  /// No description provided for @guildBehind.
  ///
  /// In en, this message translates to:
  /// **'⚠ Your guild is behind — fight!'**
  String get guildBehind;

  /// No description provided for @guildFightForGuild.
  ///
  /// In en, this message translates to:
  /// **'⚔ FIGHT FOR THE GUILD  ({c}/{max})'**
  String guildFightForGuild(int c, int max);

  /// No description provided for @guildNoWarAttacks.
  ///
  /// In en, this message translates to:
  /// **'NO WAR ATTACKS LEFT TODAY'**
  String get guildNoWarAttacks;

  /// No description provided for @guildWarRefresh.
  ///
  /// In en, this message translates to:
  /// **'War Attacks refresh daily during the Battle phase.'**
  String get guildWarRefresh;

  /// No description provided for @guildWarVictory.
  ///
  /// In en, this message translates to:
  /// **'🏆 Victory!'**
  String get guildWarVictory;

  /// No description provided for @guildWarOver.
  ///
  /// In en, this message translates to:
  /// **'War over.'**
  String get guildWarOver;

  /// No description provided for @guildWarRewardMsg.
  ///
  /// In en, this message translates to:
  /// **'{result} +{gc} Guild Coins, +{gold} gold'**
  String guildWarRewardMsg(String result, Object gc, Object gold);

  /// No description provided for @guildRewardsClaimed.
  ///
  /// In en, this message translates to:
  /// **'REWARDS CLAIMED'**
  String get guildRewardsClaimed;

  /// No description provided for @guildClaimWarRewards.
  ///
  /// In en, this message translates to:
  /// **'CLAIM WAR REWARDS'**
  String get guildClaimWarRewards;

  /// No description provided for @guildWarBattleSoon.
  ///
  /// In en, this message translates to:
  /// **'Battle begins Wednesday — come back to fight!'**
  String get guildWarBattleSoon;

  /// No description provided for @guildCoinsLabel.
  ///
  /// In en, this message translates to:
  /// **'Guild Coins'**
  String get guildCoinsLabel;

  /// No description provided for @guildListLine.
  ///
  /// In en, this message translates to:
  /// **'Lv{lvl}  •  {m}/{max} members'**
  String guildListLine(int lvl, int m, int max);

  /// No description provided for @guildJoin.
  ///
  /// In en, this message translates to:
  /// **'JOIN'**
  String get guildJoin;

  /// No description provided for @guildFull.
  ///
  /// In en, this message translates to:
  /// **'FULL'**
  String get guildFull;

  /// No description provided for @guildBossTitle.
  ///
  /// In en, this message translates to:
  /// **'GUILD BOSS'**
  String get guildBossTitle;

  /// No description provided for @guildBossWin.
  ///
  /// In en, this message translates to:
  /// **'✦ BOSS DEFEATED!'**
  String get guildBossWin;

  /// No description provided for @guildBossLose.
  ///
  /// In en, this message translates to:
  /// **'💀 FALLEN'**
  String get guildBossLose;

  /// No description provided for @guildTotalDamage.
  ///
  /// In en, this message translates to:
  /// **'Total damage dealt: {d}'**
  String guildTotalDamage(int d);

  /// No description provided for @guildReturn.
  ///
  /// In en, this message translates to:
  /// **'RETURN TO GUILD'**
  String get guildReturn;

  /// No description provided for @guildCpAmount.
  ///
  /// In en, this message translates to:
  /// **'+{cp} CP'**
  String guildCpAmount(int cp);

  /// No description provided for @guildGoldCost.
  ///
  /// In en, this message translates to:
  /// **'{gold}g'**
  String guildGoldCost(String gold);

  /// No description provided for @forgeSalvageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Destroy items to recover Shards (◆).\n• Common → 3 ◆\n• Rare → 8 ◆\n• Epic → 20 ◆\n• Legendary → 60 ◆\n• Set → 100 ◆'**
  String get forgeSalvageTooltip;

  /// No description provided for @forgeUpgradeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Upgrade an item from +0 to +10.\nEach tier boosts all stats by 8%.\nAt +5 and +10 the item gains a title prefix.\nCosts Gold + Shards per tier.'**
  String get forgeUpgradeTooltip;

  /// No description provided for @forgeTitle.
  ///
  /// In en, this message translates to:
  /// **'FORGE'**
  String get forgeTitle;

  /// No description provided for @forgeSalvage.
  ///
  /// In en, this message translates to:
  /// **'SALVAGE'**
  String get forgeSalvage;

  /// No description provided for @forgeUpgrade.
  ///
  /// In en, this message translates to:
  /// **'UPGRADE'**
  String get forgeUpgrade;

  /// No description provided for @forgeSlot.
  ///
  /// In en, this message translates to:
  /// **'SLOT'**
  String get forgeSlot;

  /// No description provided for @forgeFrom.
  ///
  /// In en, this message translates to:
  /// **'FROM  '**
  String get forgeFrom;

  /// No description provided for @forgeForged.
  ///
  /// In en, this message translates to:
  /// **'Forged: {name} ({label})!'**
  String forgeForged(String name, String label);

  /// No description provided for @forgeSalvageRates.
  ///
  /// In en, this message translates to:
  /// **'SALVAGE RATES'**
  String get forgeSalvageRates;

  /// No description provided for @forgeSalvageBtn.
  ///
  /// In en, this message translates to:
  /// **'SALVAGE  {n}  (+{s} ◆)'**
  String forgeSalvageBtn(int n, int s);

  /// No description provided for @forgeBagEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your bag is empty.'**
  String get forgeBagEmpty;

  /// No description provided for @forgeBag.
  ///
  /// In en, this message translates to:
  /// **'BAG  ({n} items)'**
  String forgeBag(int n);

  /// No description provided for @forgeSalvaged.
  ///
  /// In en, this message translates to:
  /// **'Salvaged: +{earned} ◆'**
  String forgeSalvaged(int earned);

  /// No description provided for @forgeTimesN.
  ///
  /// In en, this message translates to:
  /// **' ×{n}'**
  String forgeTimesN(int n);

  /// No description provided for @forgeTimesRandom.
  ///
  /// In en, this message translates to:
  /// **'  ×1 (random)'**
  String get forgeTimesRandom;

  /// No description provided for @forgeMasterForger.
  ///
  /// In en, this message translates to:
  /// **'Master Forger'**
  String get forgeMasterForger;

  /// No description provided for @forgeSelected.
  ///
  /// In en, this message translates to:
  /// **'SELECTED'**
  String get forgeSelected;

  /// No description provided for @forgeSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{selected} / {needed}'**
  String forgeSelectedCount(int selected, int needed);

  /// No description provided for @forgeArcaneDust.
  ///
  /// In en, this message translates to:
  /// **'ARCANE DUST'**
  String get forgeArcaneDust;

  /// No description provided for @forgeGemType.
  ///
  /// In en, this message translates to:
  /// **'GEM TYPE'**
  String get forgeGemType;

  /// No description provided for @forgeGemWeaponDesc.
  ///
  /// In en, this message translates to:
  /// **'⚔ Weapon: +{pct}% {type} damage'**
  String forgeGemWeaponDesc(Object pct, String type);

  /// No description provided for @forgeGemArmorDesc.
  ///
  /// In en, this message translates to:
  /// **'🛡 Armor: +{pct}% {type} resistance'**
  String forgeGemArmorDesc(Object pct, String type);

  /// No description provided for @forgeTier.
  ///
  /// In en, this message translates to:
  /// **'TIER'**
  String get forgeTier;

  /// No description provided for @forgeGemBagFull.
  ///
  /// In en, this message translates to:
  /// **'GEM BAG FULL ({n}/{max})'**
  String forgeGemBagFull(int n, int max);

  /// No description provided for @forgeNeedMore.
  ///
  /// In en, this message translates to:
  /// **'NEED {n} MORE 💠'**
  String forgeNeedMore(int n);

  /// No description provided for @forgeCraft.
  ///
  /// In en, this message translates to:
  /// **'✦  CRAFT  {cost} 💠'**
  String forgeCraft(int cost);

  /// No description provided for @forgePreviewWeapon.
  ///
  /// In en, this message translates to:
  /// **'⚔ Weapon: {effect}'**
  String forgePreviewWeapon(String effect);

  /// No description provided for @forgePreviewArmor.
  ///
  /// In en, this message translates to:
  /// **'🛡 Armor: {effect}'**
  String forgePreviewArmor(String effect);

  /// No description provided for @forgeToCraft.
  ///
  /// In en, this message translates to:
  /// **'{cost} 💠 to craft'**
  String forgeToCraft(int cost);

  /// No description provided for @forgeGemBag.
  ///
  /// In en, this message translates to:
  /// **'GEM BAG  ({n}/{max})'**
  String forgeGemBag(int n, int max);

  /// No description provided for @forgeTapGem.
  ///
  /// In en, this message translates to:
  /// **'Tap a gem to socket it into an item'**
  String get forgeTapGem;

  /// No description provided for @forgeNoGems.
  ///
  /// In en, this message translates to:
  /// **'No gems crafted yet. Craft one above!'**
  String get forgeNoGems;

  /// No description provided for @forgeHowGems.
  ///
  /// In en, this message translates to:
  /// **'HOW GEMS WORK'**
  String get forgeHowGems;

  /// No description provided for @forgeGemsInfo.
  ///
  /// In en, this message translates to:
  /// **'• Each gem is dual-purpose — the SAME gem gives elemental DAMAGE in a weapon, or elemental RESISTANCE in armor / jewelry.\n• Gem shards drop from combat kills (25% chance) and bosses.\n• Each item can hold 1 gem in its socket.\n• Socket gems from this bag, or via the Inventory screen.\n• Replacing or removing a gem destroys the old one.'**
  String get forgeGemsInfo;

  /// No description provided for @forgeNoItemsSocket.
  ///
  /// In en, this message translates to:
  /// **'No items to socket into.'**
  String get forgeNoItemsSocket;

  /// No description provided for @forgeSocketGem.
  ///
  /// In en, this message translates to:
  /// **'Socket {name}'**
  String forgeSocketGem(String name);

  /// No description provided for @forgeChooseItem.
  ///
  /// In en, this message translates to:
  /// **'Choose an item to socket this gem into.'**
  String get forgeChooseItem;

  /// No description provided for @forgeReplaceGem.
  ///
  /// In en, this message translates to:
  /// **'Replace Gem?'**
  String get forgeReplaceGem;

  /// No description provided for @forgeReplaceBody.
  ///
  /// In en, this message translates to:
  /// **'{old} will be destroyed and replaced with {gnew}. This cannot be undone.'**
  String forgeReplaceBody(String old, String gnew);

  /// No description provided for @forgeReplace.
  ///
  /// In en, this message translates to:
  /// **'REPLACE'**
  String get forgeReplace;

  /// No description provided for @forgeUpgradeInfo.
  ///
  /// In en, this message translates to:
  /// **'Upgrade items from +0 to +10. Each tier boosts all stats by 8%.\nAt +5 the item earns a Refined prefix.\nAt +10 it becomes Masterwork.'**
  String get forgeUpgradeInfo;

  /// No description provided for @forgeBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance: '**
  String get forgeBalance;

  /// No description provided for @forgeNoUpgradeItems.
  ///
  /// In en, this message translates to:
  /// **'No items available for upgrade.\nAll items are at +10 or bag is empty.'**
  String get forgeNoUpgradeItems;

  /// No description provided for @forgeSelectItem.
  ///
  /// In en, this message translates to:
  /// **'SELECT ITEM'**
  String get forgeSelectItem;

  /// No description provided for @forgeAllStats.
  ///
  /// In en, this message translates to:
  /// **'All stats +8%'**
  String get forgeAllStats;

  /// No description provided for @forgeWeaponDmgSuffix.
  ///
  /// In en, this message translates to:
  /// **'  •  Weapon damage +8%'**
  String get forgeWeaponDmgSuffix;

  /// No description provided for @forgeRefinedPrefix.
  ///
  /// In en, this message translates to:
  /// **'🏷 Earns \"Refined\" prefix at +5!'**
  String get forgeRefinedPrefix;

  /// No description provided for @forgeMasterworkPrefix.
  ///
  /// In en, this message translates to:
  /// **'🏷 Earns \"Masterwork\" prefix at +10!'**
  String get forgeMasterworkPrefix;

  /// No description provided for @forgeUpgradeTo.
  ///
  /// In en, this message translates to:
  /// **'UPGRADE TO +{tier}'**
  String forgeUpgradeTo(int tier);

  /// No description provided for @dngTitle.
  ///
  /// In en, this message translates to:
  /// **'THE DUNGEON'**
  String get dngTitle;

  /// No description provided for @dngTitleRun.
  ///
  /// In en, this message translates to:
  /// **'T{tier}  FL.{floor}  —  THE DUNGEON'**
  String dngTitleRun(int tier, int floor);

  /// No description provided for @dngFlee.
  ///
  /// In en, this message translates to:
  /// **'Flee dungeon'**
  String get dngFlee;

  /// No description provided for @dngAutoOn.
  ///
  /// In en, this message translates to:
  /// **'Auto Run: ON — tap to take manual control'**
  String get dngAutoOn;

  /// No description provided for @dngAutoOff.
  ///
  /// In en, this message translates to:
  /// **'Auto Run: OFF — tap to auto-clear'**
  String get dngAutoOff;

  /// No description provided for @dngAutoPremium.
  ///
  /// In en, this message translates to:
  /// **'Auto Run (unlocks at Stage 5)'**
  String get dngAutoPremium;

  /// No description provided for @dngPushOnTip.
  ///
  /// In en, this message translates to:
  /// **'Abyssal Push: ON — beat the Dungeon Lord to descend deeper'**
  String get dngPushOnTip;

  /// No description provided for @dngPushOffTip.
  ///
  /// In en, this message translates to:
  /// **'Abyssal Push: OFF — run ends at the clear floor'**
  String get dngPushOffTip;

  /// No description provided for @dngPushOnMsg.
  ///
  /// In en, this message translates to:
  /// **'Abyssal Push ON — clear the Dungeon Lord to descend into escalating abyss floors (richer Mythril + unique odds). Flee anytime to bank the clear.'**
  String get dngPushOnMsg;

  /// No description provided for @dngPushOffMsg.
  ///
  /// In en, this message translates to:
  /// **'Abyssal Push OFF — the run ends when you clear the Dungeon Lord.'**
  String get dngPushOffMsg;

  /// No description provided for @dngLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Dungeon Leaderboard'**
  String get dngLeaderboard;

  /// No description provided for @dngAutoPremiumMsg.
  ///
  /// In en, this message translates to:
  /// **'Auto Run unlocks at campaign Stage 5.'**
  String get dngAutoPremiumMsg;

  /// No description provided for @dngTutorial.
  ///
  /// In en, this message translates to:
  /// **'Choose one of two doors each floor. Slain enemies drop Bones — spend them at the Traveling Merchant for run-long buffs. Loot is yours immediately, even if your hero falls.'**
  String get dngTutorial;

  /// No description provided for @dngWhatToExpect.
  ///
  /// In en, this message translates to:
  /// **'WHAT TO EXPECT'**
  String get dngWhatToExpect;

  /// No description provided for @dngExpCombat.
  ///
  /// In en, this message translates to:
  /// **'Combat — fight for gold'**
  String get dngExpCombat;

  /// No description provided for @dngExpElite.
  ///
  /// In en, this message translates to:
  /// **'Elite — tougher foe, guaranteed item drop'**
  String get dngExpElite;

  /// No description provided for @dngExpAmbush.
  ///
  /// In en, this message translates to:
  /// **'Ambush — enemy strikes first, high gold'**
  String get dngExpAmbush;

  /// No description provided for @dngExpRest.
  ///
  /// In en, this message translates to:
  /// **'Rest Site — recover 20% HP'**
  String get dngExpRest;

  /// No description provided for @dngExpTreasure.
  ///
  /// In en, this message translates to:
  /// **'Treasure — claim gold & shards'**
  String get dngExpTreasure;

  /// No description provided for @dngExpShrine.
  ///
  /// In en, this message translates to:
  /// **'Shrine — choose a run-long blessing'**
  String get dngExpShrine;

  /// No description provided for @dngExpChest.
  ///
  /// In en, this message translates to:
  /// **'Locked Chest — spend shards for a rare item'**
  String get dngExpChest;

  /// No description provided for @dngExpTrap.
  ///
  /// In en, this message translates to:
  /// **'Trap — unavoidable damage'**
  String get dngExpTrap;

  /// No description provided for @dngExpBoss.
  ///
  /// In en, this message translates to:
  /// **'Boss (every 5th floor) — high risk, high reward'**
  String get dngExpBoss;

  /// No description provided for @dngBonesHint.
  ///
  /// In en, this message translates to:
  /// **'Slain enemies drop Bones — spend them at the Traveling Merchant.'**
  String get dngBonesHint;

  /// No description provided for @dngExpectedLoot.
  ///
  /// In en, this message translates to:
  /// **'EXPECTED LOOT'**
  String get dngExpectedLoot;

  /// No description provided for @dngLootGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get dngLootGold;

  /// No description provided for @dngLootGoldDetail.
  ///
  /// In en, this message translates to:
  /// **'From combat, treasure rooms & rest supplies'**
  String get dngLootGoldDetail;

  /// No description provided for @dngLootShards.
  ///
  /// In en, this message translates to:
  /// **'Shards'**
  String get dngLootShards;

  /// No description provided for @dngLootShardsDetail.
  ///
  /// In en, this message translates to:
  /// **'Treasure rooms & chests along the run'**
  String get dngLootShardsDetail;

  /// No description provided for @dngLootItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get dngLootItems;

  /// No description provided for @dngLootItemsDetail.
  ///
  /// In en, this message translates to:
  /// **'Item tier at your depth: {tier}  (elites & bosses drop better)'**
  String dngLootItemsDetail(String tier);

  /// No description provided for @dngLootMythril.
  ///
  /// In en, this message translates to:
  /// **'Mythril'**
  String get dngLootMythril;

  /// No description provided for @dngLootMythrilDetail.
  ///
  /// In en, this message translates to:
  /// **'~{a} at floor 5  •  ~{b} at floor 10'**
  String dngLootMythrilDetail(int a, int b);

  /// No description provided for @dngYourBest.
  ///
  /// In en, this message translates to:
  /// **'Your best: floor {f}  •  ~{m} mythril'**
  String dngYourBest(int f, int m);

  /// No description provided for @dngNoRecord.
  ///
  /// In en, this message translates to:
  /// **'No record yet'**
  String get dngNoRecord;

  /// No description provided for @dngDeepestFloor.
  ///
  /// In en, this message translates to:
  /// **'Deepest floor: {f}'**
  String dngDeepestFloor(int f);

  /// No description provided for @dngDailyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Daily attempts: {r} / {max}'**
  String dngDailyAttempts(int r, int max);

  /// No description provided for @dngEnterTier.
  ///
  /// In en, this message translates to:
  /// **'ENTER  TIER {tier}'**
  String dngEnterTier(int tier);

  /// No description provided for @dngNoAttempts.
  ///
  /// In en, this message translates to:
  /// **'NO ATTEMPTS LEFT'**
  String get dngNoAttempts;

  /// No description provided for @dngBuyExtra.
  ///
  /// In en, this message translates to:
  /// **'{cost} ZCoins — Buy 1 extra attempt'**
  String dngBuyExtra(int cost);

  /// No description provided for @dngBossFloor.
  ///
  /// In en, this message translates to:
  /// **'☠ BOSS FLOOR'**
  String get dngBossFloor;

  /// No description provided for @dngBossIn.
  ///
  /// In en, this message translates to:
  /// **'☠ Boss in {n}'**
  String dngBossIn(int n);

  /// No description provided for @dngChoosePath.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE YOUR PATH'**
  String get dngChoosePath;

  /// No description provided for @dngNextBoss.
  ///
  /// In en, this message translates to:
  /// **'☠ NEXT FLOOR: BOSS'**
  String get dngNextBoss;

  /// No description provided for @dngMystery.
  ///
  /// In en, this message translates to:
  /// **'MYSTERY'**
  String get dngMystery;

  /// No description provided for @dngGoblin.
  ///
  /// In en, this message translates to:
  /// **'💰 TREASURE GOBLIN'**
  String get dngGoblin;

  /// No description provided for @dngEnter.
  ///
  /// In en, this message translates to:
  /// **'ENTER'**
  String get dngEnter;

  /// No description provided for @dngMystery1.
  ///
  /// In en, this message translates to:
  /// **'An unmarked door.'**
  String get dngMystery1;

  /// No description provided for @dngMystery2.
  ///
  /// In en, this message translates to:
  /// **'Fortune or peril?'**
  String get dngMystery2;

  /// No description provided for @dngGoblinHp.
  ///
  /// In en, this message translates to:
  /// **'{hp} HP  •  flees after 5 rounds'**
  String dngGoblinHp(Object hp);

  /// No description provided for @dngGoblinReward.
  ///
  /// In en, this message translates to:
  /// **'6× gold if you slay it in time!'**
  String get dngGoblinReward;

  /// No description provided for @dngGuaranteedDrop.
  ///
  /// In en, this message translates to:
  /// **'Guaranteed item drop'**
  String get dngGuaranteedDrop;

  /// No description provided for @dngStrikesFirst.
  ///
  /// In en, this message translates to:
  /// **'Strikes first — high gold'**
  String get dngStrikesFirst;

  /// No description provided for @dngDoorBlessing.
  ///
  /// In en, this message translates to:
  /// **'A blessing...'**
  String get dngDoorBlessing;

  /// No description provided for @dngDoorCurse.
  ///
  /// In en, this message translates to:
  /// **'or a curse?'**
  String get dngDoorCurse;

  /// No description provided for @dngMakeCamp.
  ///
  /// In en, this message translates to:
  /// **'Make camp'**
  String get dngMakeCamp;

  /// No description provided for @dngRecoverHp.
  ///
  /// In en, this message translates to:
  /// **'Recover HP'**
  String get dngRecoverHp;

  /// No description provided for @dngRareInside.
  ///
  /// In en, this message translates to:
  /// **'Rare item inside'**
  String get dngRareInside;

  /// No description provided for @dngShardsToOpen.
  ///
  /// In en, this message translates to:
  /// **'{n} shards to open'**
  String dngShardsToOpen(Object n);

  /// No description provided for @dngPlusGold.
  ///
  /// In en, this message translates to:
  /// **'+{g} gold'**
  String dngPlusGold(Object g);

  /// No description provided for @dngPlusShards.
  ///
  /// In en, this message translates to:
  /// **'+{s} shards'**
  String dngPlusShards(Object s);

  /// No description provided for @dngMinusHp.
  ///
  /// In en, this message translates to:
  /// **'-{d} HP'**
  String dngMinusHp(Object d);

  /// No description provided for @dngEnemyStats.
  ///
  /// In en, this message translates to:
  /// **'{hp} HP  •  {atk} ATK'**
  String dngEnemyStats(Object hp, Object atk);

  /// No description provided for @dngEnemy.
  ///
  /// In en, this message translates to:
  /// **'Enemy'**
  String get dngEnemy;

  /// No description provided for @dngSpeedNeeds.
  ///
  /// In en, this message translates to:
  /// **'Higher speed needs the Speed Boost / Premium Pass.'**
  String get dngSpeedNeeds;

  /// No description provided for @dngTreasureFound.
  ///
  /// In en, this message translates to:
  /// **'Treasure Found!'**
  String get dngTreasureFound;

  /// No description provided for @dngCursed.
  ///
  /// In en, this message translates to:
  /// **'✸ CURSED!'**
  String get dngCursed;

  /// No description provided for @dngBlessed.
  ///
  /// In en, this message translates to:
  /// **'✧ BLESSED!'**
  String get dngBlessed;

  /// No description provided for @dngDarkToll.
  ///
  /// In en, this message translates to:
  /// **'The darkness takes its toll...'**
  String get dngDarkToll;

  /// No description provided for @dngAncientPower.
  ///
  /// In en, this message translates to:
  /// **'Ancient power flows through you.'**
  String get dngAncientPower;

  /// No description provided for @dngLightShadow.
  ///
  /// In en, this message translates to:
  /// **'Light and shadow bind themselves to your fate.'**
  String get dngLightShadow;

  /// No description provided for @dngShrineCorrupted.
  ///
  /// In en, this message translates to:
  /// **'Corrupted Shrine'**
  String get dngShrineCorrupted;

  /// No description provided for @dngShrineBlessed.
  ///
  /// In en, this message translates to:
  /// **'Blessed Shrine'**
  String get dngShrineBlessed;

  /// No description provided for @dngShrineAncient.
  ///
  /// In en, this message translates to:
  /// **'Ancient Shrine'**
  String get dngShrineAncient;

  /// No description provided for @dngShrineCorruptedFlavor.
  ///
  /// In en, this message translates to:
  /// **'Dark energies pulse and writhe. A curse is certain — but power awaits.'**
  String get dngShrineCorruptedFlavor;

  /// No description provided for @dngShrineBlessedFlavor.
  ///
  /// In en, this message translates to:
  /// **'Warm divine light emanates from this place. A blessing is guaranteed.'**
  String get dngShrineBlessedFlavor;

  /// No description provided for @dngShrineTwinFlavor.
  ///
  /// In en, this message translates to:
  /// **'Two forces stir within — you will receive both a blessing and a curse.'**
  String get dngShrineTwinFlavor;

  /// No description provided for @dngShrineNormalFlavor.
  ///
  /// In en, this message translates to:
  /// **'A mysterious shrine pulses with unknown energy.\nEnter to receive a blessing... or a curse.\nYou won\'t know which until it\'s too late.'**
  String get dngShrineNormalFlavor;

  /// No description provided for @dngAcceptCurse.
  ///
  /// In en, this message translates to:
  /// **'ACCEPT THE CURSE'**
  String get dngAcceptCurse;

  /// No description provided for @dngReceiveBlessing.
  ///
  /// In en, this message translates to:
  /// **'RECEIVE BLESSING'**
  String get dngReceiveBlessing;

  /// No description provided for @dngEnterTwin.
  ///
  /// In en, this message translates to:
  /// **'ENTER  (2 EFFECTS)'**
  String get dngEnterTwin;

  /// No description provided for @dngEnterShrine.
  ///
  /// In en, this message translates to:
  /// **'ENTER SHRINE'**
  String get dngEnterShrine;

  /// No description provided for @dngActiveEffects.
  ///
  /// In en, this message translates to:
  /// **'Active effects: {n}'**
  String dngActiveEffects(int n);

  /// No description provided for @dngSkip.
  ///
  /// In en, this message translates to:
  /// **'SKIP'**
  String get dngSkip;

  /// No description provided for @dngGuaranteeBless.
  ///
  /// In en, this message translates to:
  /// **'✧  GUARANTEE BLESSING  ({c} ◆)'**
  String dngGuaranteeBless(int c);

  /// No description provided for @dngTrapDamage.
  ///
  /// In en, this message translates to:
  /// **'You will take {dmg} damage ({pct}% of max HP).'**
  String dngTrapDamage(int dmg, int pct);

  /// No description provided for @dngLockedChest.
  ///
  /// In en, this message translates to:
  /// **'Locked Chest'**
  String get dngLockedChest;

  /// No description provided for @dngChestContains.
  ///
  /// In en, this message translates to:
  /// **'Contains a rare or epic item.'**
  String get dngChestContains;

  /// No description provided for @dngCostShards.
  ///
  /// In en, this message translates to:
  /// **'{cost} shards'**
  String dngCostShards(Object cost);

  /// No description provided for @dngHave.
  ///
  /// In en, this message translates to:
  /// **'(have {n})'**
  String dngHave(int n);

  /// No description provided for @dngCostZcoins.
  ///
  /// In en, this message translates to:
  /// **'{cost} ZCoins'**
  String dngCostZcoins(int cost);

  /// No description provided for @dngMerchantQuote.
  ///
  /// In en, this message translates to:
  /// **'\"Bones for trinkets, traveller. More bones, finer wares.\"'**
  String get dngMerchantQuote;

  /// No description provided for @dngBones.
  ///
  /// In en, this message translates to:
  /// **'🦴  {n} Bones'**
  String dngBones(int n);

  /// No description provided for @dngBoneCost.
  ///
  /// In en, this message translates to:
  /// **'{c} 🦴'**
  String dngBoneCost(int c);

  /// No description provided for @dngClaimRelic.
  ///
  /// In en, this message translates to:
  /// **'☠ BOSS SLAIN — CLAIM A RELIC'**
  String get dngClaimRelic;

  /// No description provided for @dngSkipDescend.
  ///
  /// In en, this message translates to:
  /// **'SKIP — DESCEND'**
  String get dngSkipDescend;

  /// No description provided for @dngReturn.
  ///
  /// In en, this message translates to:
  /// **'RETURN'**
  String get dngReturn;

  /// No description provided for @dngDescendTo.
  ///
  /// In en, this message translates to:
  /// **'DESCEND TO FLOOR {n}'**
  String dngDescendTo(int n);

  /// No description provided for @dngFallen.
  ///
  /// In en, this message translates to:
  /// **'☠ Fallen'**
  String get dngFallen;

  /// No description provided for @dngGotAway.
  ///
  /// In en, this message translates to:
  /// **'💰 It got away!'**
  String get dngGotAway;

  /// No description provided for @dngVictory.
  ///
  /// In en, this message translates to:
  /// **'✓ Victory'**
  String get dngVictory;

  /// No description provided for @dngAmbushHit.
  ///
  /// In en, this message translates to:
  /// **'Ambush hit dealt {n} before the fight.'**
  String dngAmbushHit(int n);

  /// No description provided for @dngItemToBag.
  ///
  /// In en, this message translates to:
  /// **'✦ {name} ({label}) → Bag'**
  String dngItemToBag(String name, String label);

  /// No description provided for @dngRested.
  ///
  /// In en, this message translates to:
  /// **'⊕ Rested'**
  String get dngRested;

  /// No description provided for @dngTreasureCollected.
  ///
  /// In en, this message translates to:
  /// **'✦ Treasure collected'**
  String get dngTreasureCollected;

  /// No description provided for @dngBlessingReceived.
  ///
  /// In en, this message translates to:
  /// **'✧ Blessing received'**
  String get dngBlessingReceived;

  /// No description provided for @dngSlainTrap.
  ///
  /// In en, this message translates to:
  /// **'☠ Slain by the trap'**
  String get dngSlainTrap;

  /// No description provided for @dngTrapSurvived.
  ///
  /// In en, this message translates to:
  /// **'✸ Trap survived'**
  String get dngTrapSurvived;

  /// No description provided for @dngChestOpened.
  ///
  /// In en, this message translates to:
  /// **'◆ Chest opened'**
  String get dngChestOpened;

  /// No description provided for @dngLootAdded.
  ///
  /// In en, this message translates to:
  /// **'Your loot has already been added to your account.'**
  String get dngLootAdded;

  /// No description provided for @dngLordFallen.
  ///
  /// In en, this message translates to:
  /// **'The Dungeon Lord has fallen!\n+5 mythril  •  +{z} Z-Coins  •  +{g} gold  •  bonus item'**
  String dngLordFallen(int z, int g);

  /// No description provided for @dngTierN.
  ///
  /// In en, this message translates to:
  /// **'TIER {t}'**
  String dngTierN(int t);

  /// No description provided for @dngFloor.
  ///
  /// In en, this message translates to:
  /// **'FLOOR'**
  String get dngFloor;

  /// No description provided for @dngRooms.
  ///
  /// In en, this message translates to:
  /// **'ROOMS'**
  String get dngRooms;

  /// No description provided for @dngBosses.
  ///
  /// In en, this message translates to:
  /// **'BOSSES'**
  String get dngBosses;

  /// No description provided for @dngGold.
  ///
  /// In en, this message translates to:
  /// **'GOLD'**
  String get dngGold;

  /// No description provided for @dngShards.
  ///
  /// In en, this message translates to:
  /// **'SHARDS'**
  String get dngShards;

  /// No description provided for @dngTierCleared.
  ///
  /// In en, this message translates to:
  /// **'✓ Tier {t} cleared — AUTO unlocked!'**
  String dngTierCleared(int t);

  /// No description provided for @dngNewRecord.
  ///
  /// In en, this message translates to:
  /// **'★ New record!'**
  String get dngNewRecord;

  /// No description provided for @dngAllLootAdded.
  ///
  /// In en, this message translates to:
  /// **'All loot has been added to your account.'**
  String get dngAllLootAdded;

  /// No description provided for @dngYouFallen.
  ///
  /// In en, this message translates to:
  /// **'YOU HAVE FALLEN'**
  String get dngYouFallen;

  /// No description provided for @dngCleared.
  ///
  /// In en, this message translates to:
  /// **'DUNGEON CLEARED!'**
  String get dngCleared;

  /// No description provided for @dngRunEnded.
  ///
  /// In en, this message translates to:
  /// **'RUN ENDED'**
  String get dngRunEnded;

  /// No description provided for @dngAutoLocked.
  ///
  /// In en, this message translates to:
  /// **'🔒 AUTO'**
  String get dngAutoLocked;

  /// No description provided for @dngStop.
  ///
  /// In en, this message translates to:
  /// **'◉ STOP'**
  String get dngStop;

  /// No description provided for @dngAuto.
  ///
  /// In en, this message translates to:
  /// **'✦ AUTO'**
  String get dngAuto;

  /// No description provided for @dngRunAgain.
  ///
  /// In en, this message translates to:
  /// **'RUN AGAIN'**
  String get dngRunAgain;

  /// No description provided for @dngReturnHall.
  ///
  /// In en, this message translates to:
  /// **'RETURN TO HALL'**
  String get dngReturnHall;

  /// No description provided for @auraEquipped.
  ///
  /// In en, this message translates to:
  /// **'EQUIPPED'**
  String get auraEquipped;

  /// No description provided for @auraOn.
  ///
  /// In en, this message translates to:
  /// **'ON'**
  String get auraOn;

  /// No description provided for @auraCost.
  ///
  /// In en, this message translates to:
  /// **'Cost: {n} zcoins'**
  String auraCost(int n);

  /// No description provided for @auraUnlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock {name}?'**
  String auraUnlockTitle(String name);

  /// No description provided for @auraAllAuras.
  ///
  /// In en, this message translates to:
  /// **'ALL AURAS'**
  String get auraAllAuras;

  /// No description provided for @auraAllSkins.
  ///
  /// In en, this message translates to:
  /// **'ALL SKINS'**
  String get auraAllSkins;

  /// No description provided for @auraAllPets.
  ///
  /// In en, this message translates to:
  /// **'ALL PETS'**
  String get auraAllPets;

  /// No description provided for @auraRemoveAura.
  ///
  /// In en, this message translates to:
  /// **'Remove aura'**
  String get auraRemoveAura;

  /// No description provided for @auraRemoveSkin.
  ///
  /// In en, this message translates to:
  /// **'Remove skin'**
  String get auraRemoveSkin;

  /// No description provided for @auraDismissPet.
  ///
  /// In en, this message translates to:
  /// **'Dismiss pet'**
  String get auraDismissPet;

  /// No description provided for @auraBattleCompanion.
  ///
  /// In en, this message translates to:
  /// **'BATTLE COMPANION'**
  String get auraBattleCompanion;

  /// No description provided for @auraWaystones.
  ///
  /// In en, this message translates to:
  /// **'WAYSTONES'**
  String get auraWaystones;

  /// No description provided for @auraAttackEffects.
  ///
  /// In en, this message translates to:
  /// **'ATTACK EFFECTS'**
  String get auraAttackEffects;

  /// No description provided for @auraCharSlots.
  ///
  /// In en, this message translates to:
  /// **'CHARACTER SLOTS'**
  String get auraCharSlots;

  /// No description provided for @auraCompanionNote.
  ///
  /// In en, this message translates to:
  /// **'One companion can be active at a time. Each grants a small passive bonus.'**
  String get auraCompanionNote;

  /// No description provided for @auraBeforeAfter.
  ///
  /// In en, this message translates to:
  /// **'Before / After'**
  String get auraBeforeAfter;

  /// No description provided for @auraAllSlots.
  ///
  /// In en, this message translates to:
  /// **'All 12 slots unlocked.'**
  String get auraAllSlots;

  /// No description provided for @auraAdoptTitle.
  ///
  /// In en, this message translates to:
  /// **'Adopt {name}?'**
  String auraAdoptTitle(String name);

  /// No description provided for @auraPetBonus.
  ///
  /// In en, this message translates to:
  /// **'✦ {label}'**
  String auraPetBonus(String label);

  /// No description provided for @auraMaxEvolution.
  ///
  /// In en, this message translates to:
  /// **'★★ MAX EVOLUTION'**
  String get auraMaxEvolution;

  /// No description provided for @auraOwned.
  ///
  /// In en, this message translates to:
  /// **'Owned: {count}'**
  String auraOwned(Object count);

  /// No description provided for @auraWaystoneDesc.
  ///
  /// In en, this message translates to:
  /// **'{h}h  ·  {m}× idle income'**
  String auraWaystoneDesc(Object h, String m);

  /// No description provided for @auraHitEvery.
  ///
  /// In en, this message translates to:
  /// **'\"{text}\" on every hit'**
  String auraHitEvery(String text);

  /// No description provided for @auraSlotN.
  ///
  /// In en, this message translates to:
  /// **'Slot {n}'**
  String auraSlotN(Object n);

  /// No description provided for @auraAddSlot.
  ///
  /// In en, this message translates to:
  /// **'Add one more character save slot.'**
  String get auraAddSlot;

  /// No description provided for @auraUnlock.
  ///
  /// In en, this message translates to:
  /// **'UNLOCK'**
  String get auraUnlock;

  /// No description provided for @auraAdopt.
  ///
  /// In en, this message translates to:
  /// **'ADOPT'**
  String get auraAdopt;

  /// No description provided for @auraBuy.
  ///
  /// In en, this message translates to:
  /// **'BUY'**
  String get auraBuy;

  /// No description provided for @auraEvolve.
  ///
  /// In en, this message translates to:
  /// **'EVOLVE'**
  String get auraEvolve;

  /// No description provided for @auraEquip.
  ///
  /// In en, this message translates to:
  /// **'EQUIP'**
  String get auraEquip;

  /// No description provided for @auraActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get auraActive;

  /// No description provided for @auraSendOut.
  ///
  /// In en, this message translates to:
  /// **'SEND OUT'**
  String get auraSendOut;

  /// No description provided for @auraStackAuras.
  ///
  /// In en, this message translates to:
  /// **'Bonuses from every aura you OWN stack automatically — you keep them all. Equip one just to choose which glow you show.'**
  String get auraStackAuras;

  /// No description provided for @auraStackSkins.
  ///
  /// In en, this message translates to:
  /// **'Bonuses from every skin you OWN stack automatically — you keep them all. Equip one just to choose which look you wear.'**
  String get auraStackSkins;

  /// No description provided for @armTabUniques.
  ///
  /// In en, this message translates to:
  /// **'UNIQUES'**
  String get armTabUniques;

  /// No description provided for @armTabMythic.
  ///
  /// In en, this message translates to:
  /// **'MYTHIC'**
  String get armTabMythic;

  /// No description provided for @armTabSets.
  ///
  /// In en, this message translates to:
  /// **'SET ITEMS'**
  String get armTabSets;

  /// No description provided for @armTabArtifacts.
  ///
  /// In en, this message translates to:
  /// **'ARTIFACTS'**
  String get armTabArtifacts;

  /// No description provided for @armNoLegendaries.
  ///
  /// In en, this message translates to:
  /// **'No legendaries for this class.'**
  String get armNoLegendaries;

  /// No description provided for @armClassUniques.
  ///
  /// In en, this message translates to:
  /// **'{count} Class Uniques'**
  String armClassUniques(int count);

  /// No description provided for @armOwned.
  ///
  /// In en, this message translates to:
  /// **'OWNED'**
  String get armOwned;

  /// No description provided for @armSlotReqLevel.
  ///
  /// In en, this message translates to:
  /// **'{slot}  •  Req. Level {lvl}'**
  String armSlotReqLevel(String slot, int lvl);

  /// No description provided for @armStats.
  ///
  /// In en, this message translates to:
  /// **'STATS'**
  String get armStats;

  /// No description provided for @armAbilityEnh.
  ///
  /// In en, this message translates to:
  /// **'ABILITY ENHANCEMENT'**
  String get armAbilityEnh;

  /// No description provided for @armAbilityDamage.
  ///
  /// In en, this message translates to:
  /// **'• Ability damage ×{x}'**
  String armAbilityDamage(String x);

  /// No description provided for @armAbilityDuration.
  ///
  /// In en, this message translates to:
  /// **'• +{n} rounds duration'**
  String armAbilityDuration(Object n);

  /// No description provided for @armAbilityCooldown.
  ///
  /// In en, this message translates to:
  /// **'• {v} rounds cooldown'**
  String armAbilityCooldown(String v);

  /// No description provided for @armOnCast.
  ///
  /// In en, this message translates to:
  /// **'• On cast: {desc}'**
  String armOnCast(String desc);

  /// No description provided for @armHowToFind.
  ///
  /// In en, this message translates to:
  /// **'HOW TO FIND'**
  String get armHowToFind;

  /// No description provided for @armDropCampaign.
  ///
  /// In en, this message translates to:
  /// **'Campaign bosses'**
  String get armDropCampaign;

  /// No description provided for @armDropTower.
  ///
  /// In en, this message translates to:
  /// **'Tower Ascension bosses'**
  String get armDropTower;

  /// No description provided for @armDropBossRush.
  ///
  /// In en, this message translates to:
  /// **'Boss Rush runs'**
  String get armDropBossRush;

  /// No description provided for @armDropGauntlet.
  ///
  /// In en, this message translates to:
  /// **'Gauntlet clear'**
  String get armDropGauntlet;

  /// No description provided for @armRate2.
  ///
  /// In en, this message translates to:
  /// **'2% per boss kill'**
  String get armRate2;

  /// No description provided for @armRate03.
  ///
  /// In en, this message translates to:
  /// **'0.3% per boss kill'**
  String get armRate03;

  /// No description provided for @armRateRare.
  ///
  /// In en, this message translates to:
  /// **'Rare bonus drop'**
  String get armRateRare;

  /// No description provided for @armDropsClassSpecific.
  ///
  /// In en, this message translates to:
  /// **'Drops are class-specific — only items for your class can drop.'**
  String get armDropsClassSpecific;

  /// No description provided for @armNoMythic.
  ///
  /// In en, this message translates to:
  /// **'No Mythic items yet'**
  String get armNoMythic;

  /// No description provided for @armMythicHint.
  ///
  /// In en, this message translates to:
  /// **'Defeat campaign bosses for a 0.5% chance per kill.'**
  String get armMythicHint;

  /// No description provided for @armMythicItems.
  ///
  /// In en, this message translates to:
  /// **'Mythic Items'**
  String get armMythicItems;

  /// No description provided for @armSlotLv.
  ///
  /// In en, this message translates to:
  /// **'{slot}  •  Lv{lvl}'**
  String armSlotLv(String slot, int lvl);

  /// No description provided for @armKeyword.
  ///
  /// In en, this message translates to:
  /// **'{name} keyword'**
  String armKeyword(String name);

  /// No description provided for @armSetItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Items'**
  String get armSetItemsTitle;

  /// No description provided for @armFraction.
  ///
  /// In en, this message translates to:
  /// **'{a} / {b}'**
  String armFraction(int a, int b);

  /// No description provided for @armEquippedLower.
  ///
  /// In en, this message translates to:
  /// **'equipped'**
  String get armEquippedLower;

  /// No description provided for @armSetBonuses.
  ///
  /// In en, this message translates to:
  /// **'SET BONUSES'**
  String get armSetBonuses;

  /// No description provided for @armPc.
  ///
  /// In en, this message translates to:
  /// **'{n}pc'**
  String armPc(Object n);

  /// No description provided for @armUniqueBlurb.
  ///
  /// In en, this message translates to:
  /// **'Unique items are class-bound and dramatically enhance your abilities. Each amplifies a specific class ability. Drop rate: 2% per boss kill.'**
  String get armUniqueBlurb;

  /// No description provided for @armMythicBlurb.
  ///
  /// In en, this message translates to:
  /// **'The rarest procedurally-generated tier. Mythic items have 3 stats with the highest possible values and a powerful keyword effect. Drop rate: 0.5% per boss kill.'**
  String get armMythicBlurb;

  /// No description provided for @armSetBlurb.
  ///
  /// In en, this message translates to:
  /// **'Collect multiple pieces of the same set to unlock powerful bonuses. Sets now require 6 pieces for the full bonus. Drop rate: 0.3% per boss kill.'**
  String get armSetBlurb;

  /// No description provided for @armArtifactBlurb.
  ///
  /// In en, this message translates to:
  /// **'{count} three-piece artifact sets. Equip 2 matching green pieces on the artifact grid for a partial bonus, all 3 for the full bonus. Set pieces drop from Dungeons, Boss Rush, and Campaign bosses.'**
  String armArtifactBlurb(int count);

  /// No description provided for @armSetPieces.
  ///
  /// In en, this message translates to:
  /// **'SET PIECES'**
  String get armSetPieces;

  /// No description provided for @armArtifactSets.
  ///
  /// In en, this message translates to:
  /// **'Artifact Sets'**
  String get armArtifactSets;

  /// No description provided for @armCollected.
  ///
  /// In en, this message translates to:
  /// **'COLLECTED  {a} / {b} distinct pieces owned'**
  String armCollected(int a, int b);

  /// No description provided for @endlessStage.
  ///
  /// In en, this message translates to:
  /// **'Stage {n}'**
  String endlessStage(int n);

  /// No description provided for @endlessNextReward.
  ///
  /// In en, this message translates to:
  /// **'Next reward: Floor {n}'**
  String endlessNextReward(int n);

  /// No description provided for @endlessChallengeBoss.
  ///
  /// In en, this message translates to:
  /// **'CHALLENGE A BOSS'**
  String get endlessChallengeBoss;

  /// No description provided for @endlessPremiumAutoClear.
  ///
  /// In en, this message translates to:
  /// **'🔒  Reach campaign Stage 5 to auto-clear bosses'**
  String get endlessPremiumAutoClear;

  /// No description provided for @endlessRewards.
  ///
  /// In en, this message translates to:
  /// **'REWARDS: '**
  String get endlessRewards;

  /// No description provided for @endlessDrop.
  ///
  /// In en, this message translates to:
  /// **'DROP: '**
  String get endlessDrop;

  /// No description provided for @endlessGold.
  ///
  /// In en, this message translates to:
  /// **'GOLD'**
  String get endlessGold;

  /// No description provided for @endlessXp.
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get endlessXp;

  /// No description provided for @endlessRespawns.
  ///
  /// In en, this message translates to:
  /// **'RESPAWNS'**
  String get endlessRespawns;

  /// No description provided for @endlessTowerShards.
  ///
  /// In en, this message translates to:
  /// **'+{n} TOWER SHARDS'**
  String endlessTowerShards(String n);

  /// No description provided for @endlessMilestone.
  ///
  /// In en, this message translates to:
  /// **'★ MILESTONE: {n} KILLS ★'**
  String endlessMilestone(Object n);

  /// No description provided for @endlessMilestoneReward.
  ///
  /// In en, this message translates to:
  /// **'+{gold} GOLD  +{s} ◆'**
  String endlessMilestoneReward(String gold, Object s);

  /// No description provided for @endlessEnemyStirs.
  ///
  /// In en, this message translates to:
  /// **'The enemy stirs again...'**
  String get endlessEnemyStirs;

  /// No description provided for @endlessDefeatBody.
  ///
  /// In en, this message translates to:
  /// **'Your hero was overwhelmed.\nUpgrade your stats and try again.'**
  String get endlessDefeatBody;

  /// No description provided for @pvpNoStamina.
  ///
  /// In en, this message translates to:
  /// **'No stamina! Recharges 1 every 45 minutes.'**
  String get pvpNoStamina;

  /// No description provided for @pvpTitle.
  ///
  /// In en, this message translates to:
  /// **'PVP ARENA'**
  String get pvpTitle;

  /// No description provided for @pvpSimLab.
  ///
  /// In en, this message translates to:
  /// **'Sim Lab'**
  String get pvpSimLab;

  /// No description provided for @pvpRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh leaderboard'**
  String get pvpRefresh;

  /// No description provided for @pvpLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'LEADERBOARD'**
  String get pvpLeaderboard;

  /// No description provided for @pvpToday.
  ///
  /// In en, this message translates to:
  /// **'TODAY: {label}'**
  String pvpToday(String label);

  /// No description provided for @pvpWinsToday.
  ///
  /// In en, this message translates to:
  /// **'{wins} wins today  •  {dmg} total dmg'**
  String pvpWinsToday(Object wins, Object dmg);

  /// No description provided for @pvpClaimed.
  ///
  /// In en, this message translates to:
  /// **'✓ CLAIMED'**
  String get pvpClaimed;

  /// No description provided for @pvpNoChallengers.
  ///
  /// In en, this message translates to:
  /// **'NO CHALLENGERS YET'**
  String get pvpNoChallengers;

  /// No description provided for @pvpNoChallengersSub.
  ///
  /// In en, this message translates to:
  /// **'Fight a match to join the leaderboard\nand see how you stack up.'**
  String get pvpNoChallengersSub;

  /// No description provided for @pvpHpAc.
  ///
  /// In en, this message translates to:
  /// **'HP:{hp}  AC:{ac}'**
  String pvpHpAc(Object hp, Object ac);

  /// No description provided for @pvpStamina.
  ///
  /// In en, this message translates to:
  /// **'STAMINA  '**
  String get pvpStamina;

  /// No description provided for @pvpStaminaTip.
  ///
  /// In en, this message translates to:
  /// **'Stamina recovers 1 heart every 45 minutes.'**
  String get pvpStaminaTip;

  /// No description provided for @pvpRating.
  ///
  /// In en, this message translates to:
  /// **'RATING'**
  String get pvpRating;

  /// No description provided for @pvpWins.
  ///
  /// In en, this message translates to:
  /// **'WINS'**
  String get pvpWins;

  /// No description provided for @pvpLosses.
  ///
  /// In en, this message translates to:
  /// **'LOSSES'**
  String get pvpLosses;

  /// No description provided for @pvpWL.
  ///
  /// In en, this message translates to:
  /// **'W/L'**
  String get pvpWL;

  /// No description provided for @pvpLeague.
  ///
  /// In en, this message translates to:
  /// **'{name} LEAGUE'**
  String pvpLeague(String name);

  /// No description provided for @pvpNearRank.
  ///
  /// In en, this message translates to:
  /// **'NEAR YOUR RANK'**
  String get pvpNearRank;

  /// No description provided for @pvpPlayersAbove.
  ///
  /// In en, this message translates to:
  /// **'— players just above you'**
  String get pvpPlayersAbove;

  /// No description provided for @pvpClassLv.
  ///
  /// In en, this message translates to:
  /// **'{cls}  Lv{lvl}'**
  String pvpClassLv(String cls, Object lvl);

  /// No description provided for @pvpChallenge.
  ///
  /// In en, this message translates to:
  /// **'CHALLENGE'**
  String get pvpChallenge;

  /// No description provided for @pvpBattleLog.
  ///
  /// In en, this message translates to:
  /// **'BATTLE LOG'**
  String get pvpBattleLog;

  /// No description provided for @pvpBattleLogTip.
  ///
  /// In en, this message translates to:
  /// **'Battle log'**
  String get pvpBattleLogTip;

  /// No description provided for @pvpNoCombat.
  ///
  /// In en, this message translates to:
  /// **'No combat yet.'**
  String get pvpNoCombat;

  /// No description provided for @pvpClose.
  ///
  /// In en, this message translates to:
  /// **'CLOSE'**
  String get pvpClose;

  /// No description provided for @pvpVs.
  ///
  /// In en, this message translates to:
  /// **'PVP  —  {hero} vs {opp}'**
  String pvpVs(String hero, String opp);

  /// No description provided for @pvpReturnArena.
  ///
  /// In en, this message translates to:
  /// **'RETURN TO ARENA'**
  String get pvpReturnArena;

  /// No description provided for @pvpFighting.
  ///
  /// In en, this message translates to:
  /// **'Fighting...'**
  String get pvpFighting;

  /// No description provided for @invBagCount.
  ///
  /// In en, this message translates to:
  /// **'({n}/{cap})'**
  String invBagCount(Object n, Object cap);

  /// No description provided for @invBuyTab.
  ///
  /// In en, this message translates to:
  /// **'+ TAB  {cost}'**
  String invBuyTab(Object cost);

  /// No description provided for @invAutoEquip.
  ///
  /// In en, this message translates to:
  /// **'AUTO EQUIP'**
  String get invAutoEquip;

  /// No description provided for @invTabN.
  ///
  /// In en, this message translates to:
  /// **'TAB {n}  ({count})'**
  String invTabN(Object n, Object count);

  /// No description provided for @invEquipment.
  ///
  /// In en, this message translates to:
  /// **'EQUIPMENT'**
  String get invEquipment;

  /// No description provided for @invBag.
  ///
  /// In en, this message translates to:
  /// **'BAG  ({n}/{cap})'**
  String invBag(Object n, Object cap);

  /// No description provided for @invUnequip.
  ///
  /// In en, this message translates to:
  /// **'Unequip'**
  String get invUnequip;

  /// No description provided for @invNoItems.
  ///
  /// In en, this message translates to:
  /// **'No items in this tab.'**
  String get invNoItems;

  /// No description provided for @invReqClass.
  ///
  /// In en, this message translates to:
  /// **'Requires {cls}'**
  String invReqClass(String cls);

  /// No description provided for @invReqLevel.
  ///
  /// In en, this message translates to:
  /// **'Requires Level {lvl}'**
  String invReqLevel(Object lvl);

  /// No description provided for @invReqTier.
  ///
  /// In en, this message translates to:
  /// **'Requires Tier {t}'**
  String invReqTier(Object t);

  /// No description provided for @invCannotEquip.
  ///
  /// In en, this message translates to:
  /// **'Cannot Equip'**
  String get invCannotEquip;

  /// No description provided for @invEquip.
  ///
  /// In en, this message translates to:
  /// **'Equip'**
  String get invEquip;

  /// No description provided for @invUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock 🔓'**
  String get invUnlock;

  /// No description provided for @invLock.
  ///
  /// In en, this message translates to:
  /// **'Lock 🔒'**
  String get invLock;

  /// No description provided for @invDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get invDiscard;

  /// No description provided for @invAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get invAny;

  /// No description provided for @invUniqueOnly.
  ///
  /// In en, this message translates to:
  /// **'★ Unique — {cls} only'**
  String invUniqueOnly(String cls);

  /// No description provided for @invWrongClass.
  ///
  /// In en, this message translates to:
  /// **'(wrong class)'**
  String get invWrongClass;

  /// No description provided for @invColStat.
  ///
  /// In en, this message translates to:
  /// **'STAT'**
  String get invColStat;

  /// No description provided for @invColThis.
  ///
  /// In en, this message translates to:
  /// **'THIS'**
  String get invColThis;

  /// No description provided for @invColEqpd.
  ///
  /// In en, this message translates to:
  /// **'EQPD'**
  String get invColEqpd;

  /// No description provided for @invColDiff.
  ///
  /// In en, this message translates to:
  /// **'DIFF'**
  String get invColDiff;

  /// No description provided for @invEmptySocket.
  ///
  /// In en, this message translates to:
  /// **'Empty Socket'**
  String get invEmptySocket;

  /// No description provided for @invCraftGems.
  ///
  /// In en, this message translates to:
  /// **'Craft gems in Forge → Gems tab'**
  String get invCraftGems;

  /// No description provided for @invRemove.
  ///
  /// In en, this message translates to:
  /// **'REMOVE'**
  String get invRemove;

  /// No description provided for @invSocket.
  ///
  /// In en, this message translates to:
  /// **'SOCKET'**
  String get invSocket;

  /// No description provided for @invChooseGem.
  ///
  /// In en, this message translates to:
  /// **'Choose a gem to socket into {name}'**
  String invChooseGem(String name);

  /// No description provided for @invOnThis.
  ///
  /// In en, this message translates to:
  /// **'On this {slot}: {bonus}'**
  String invOnThis(String slot, String bonus);

  /// No description provided for @invRemoveGem.
  ///
  /// In en, this message translates to:
  /// **'Remove Gem?'**
  String get invRemoveGem;

  /// No description provided for @invDestroy.
  ///
  /// In en, this message translates to:
  /// **'DESTROY'**
  String get invDestroy;

  /// No description provided for @invSort.
  ///
  /// In en, this message translates to:
  /// **'Sort:'**
  String get invSort;

  /// No description provided for @invFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter:'**
  String get invFilter;

  /// No description provided for @invGemsAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} gem(s) available to socket'**
  String invGemsAvailable(Object count);

  /// No description provided for @invRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'{name} will be destroyed. Gems cannot be recovered once removed.'**
  String invRemoveBody(String name);

  /// No description provided for @invReplaceBody.
  ///
  /// In en, this message translates to:
  /// **'{old} will be destroyed and replaced with {gnew}.'**
  String invReplaceBody(String old, String gnew);

  /// No description provided for @npcRoster.
  ///
  /// In en, this message translates to:
  /// **'ROSTER'**
  String get npcRoster;

  /// No description provided for @npcSynergies.
  ///
  /// In en, this message translates to:
  /// **'SYNERGIES'**
  String get npcSynergies;

  /// No description provided for @npcTitle.
  ///
  /// In en, this message translates to:
  /// **'MERCENARIES'**
  String get npcTitle;

  /// No description provided for @npcTotalBonuses.
  ///
  /// In en, this message translates to:
  /// **'TOTAL ACTIVE BONUSES'**
  String get npcTotalBonuses;

  /// No description provided for @npcBattleParty.
  ///
  /// In en, this message translates to:
  /// **'BATTLE PARTY'**
  String get npcBattleParty;

  /// No description provided for @npcFielded.
  ///
  /// In en, this message translates to:
  /// **'{count} / {max} fielded'**
  String npcFielded(Object count, Object max);

  /// No description provided for @npcUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown Mercenary'**
  String get npcUnknown;

  /// No description provided for @npcBattleAbility.
  ///
  /// In en, this message translates to:
  /// **'BATTLE ABILITY: {name}'**
  String npcBattleAbility(String name);

  /// No description provided for @npcUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock: {label}'**
  String npcUnlock(String label);

  /// No description provided for @npcProgress.
  ///
  /// In en, this message translates to:
  /// **'{a} / {b}'**
  String npcProgress(Object a, Object b);

  /// No description provided for @npcLvTalent.
  ///
  /// In en, this message translates to:
  /// **'LV {n} TALENT'**
  String npcLvTalent(Object n);

  /// No description provided for @npcChosen.
  ///
  /// In en, this message translates to:
  /// **'CHOSEN: {name}'**
  String npcChosen(String name);

  /// No description provided for @npcMilestoneComplete.
  ///
  /// In en, this message translates to:
  /// **'MILESTONE COMPLETE — RECRUITING...'**
  String get npcMilestoneComplete;

  /// No description provided for @npcMax.
  ///
  /// In en, this message translates to:
  /// **'★ MAX'**
  String get npcMax;

  /// No description provided for @npcStarRank.
  ///
  /// In en, this message translates to:
  /// **'STAR RANK'**
  String get npcStarRank;

  /// No description provided for @npcStars.
  ///
  /// In en, this message translates to:
  /// **'{a} / {b}'**
  String npcStars(Object a, Object b);

  /// No description provided for @npcFullyAscended.
  ///
  /// In en, this message translates to:
  /// **'★ FULLY ASCENDED — each star adds +1 effective level.'**
  String get npcFullyAscended;

  /// No description provided for @npcAscendStar.
  ///
  /// In en, this message translates to:
  /// **'ASCEND ★{n}'**
  String npcAscendStar(Object n);

  /// No description provided for @npcYouHave.
  ///
  /// In en, this message translates to:
  /// **'You have: {n} Mythril'**
  String npcYouHave(Object n);

  /// No description provided for @npcStarInfo.
  ///
  /// In en, this message translates to:
  /// **'Each star = +1 effective level of this merc\'s bonus.'**
  String get npcStarInfo;

  /// No description provided for @npcPassiveOnly.
  ///
  /// In en, this message translates to:
  /// **'Passive bonuses only — always active.'**
  String get npcPassiveOnly;

  /// No description provided for @npcCostShards.
  ///
  /// In en, this message translates to:
  /// **'Cost: ◆ {n} Shards'**
  String npcCostShards(Object n);

  /// No description provided for @npcTutorial.
  ///
  /// In en, this message translates to:
  /// **'Mercenaries are companions who join permanently when you hit certain milestones. 🤝 Each one provides passive combat bonuses in every battle and can synergise with others for extra power.'**
  String get npcTutorial;

  /// No description provided for @npcRecruited.
  ///
  /// In en, this message translates to:
  /// **'{a} / {b}  recruited'**
  String npcRecruited(Object a, Object b);

  /// No description provided for @npcNoMercs.
  ///
  /// In en, this message translates to:
  /// **'No mercenaries recruited yet. Fulfill milestones to unlock them.'**
  String get npcNoMercs;

  /// No description provided for @npcChipDamage.
  ///
  /// In en, this message translates to:
  /// **'+{n}% Damage'**
  String npcChipDamage(Object n);

  /// No description provided for @npcChipAc.
  ///
  /// In en, this message translates to:
  /// **'+{n}% AC'**
  String npcChipAc(Object n);

  /// No description provided for @npcChipShards.
  ///
  /// In en, this message translates to:
  /// **'+{n}% Shards'**
  String npcChipShards(Object n);

  /// No description provided for @npcChipHp.
  ///
  /// In en, this message translates to:
  /// **'+{n}% HP'**
  String npcChipHp(Object n);

  /// No description provided for @shopTabBundles.
  ///
  /// In en, this message translates to:
  /// **'BUNDLES'**
  String get shopTabBundles;

  /// No description provided for @shopTabVip.
  ///
  /// In en, this message translates to:
  /// **'VIP'**
  String get shopTabVip;

  /// No description provided for @shopTabStarter.
  ///
  /// In en, this message translates to:
  /// **'STARTER'**
  String get shopTabStarter;

  /// No description provided for @shopTabResources.
  ///
  /// In en, this message translates to:
  /// **'RESOURCES'**
  String get shopTabResources;

  /// No description provided for @shopTabCosmetics.
  ///
  /// In en, this message translates to:
  /// **'COSMETICS'**
  String get shopTabCosmetics;

  /// No description provided for @shopSecBundles.
  ///
  /// In en, this message translates to:
  /// **'ZCOIN BUNDLES'**
  String get shopSecBundles;

  /// No description provided for @shopSecBundlesSub.
  ///
  /// In en, this message translates to:
  /// **'Premium currency for the Shop'**
  String get shopSecBundlesSub;

  /// No description provided for @shopSecVip.
  ///
  /// In en, this message translates to:
  /// **'VIP SUBSCRIPTIONS'**
  String get shopSecVip;

  /// No description provided for @shopSecVipSub.
  ///
  /// In en, this message translates to:
  /// **'Recurring perks and benefits'**
  String get shopSecVipSub;

  /// No description provided for @shopSecStarter.
  ///
  /// In en, this message translates to:
  /// **'STARTER PACKS'**
  String get shopSecStarter;

  /// No description provided for @shopSecStarterSub.
  ///
  /// In en, this message translates to:
  /// **'One-time purchase bundles'**
  String get shopSecStarterSub;

  /// No description provided for @shopSecResources.
  ///
  /// In en, this message translates to:
  /// **'RESOURCES'**
  String get shopSecResources;

  /// No description provided for @shopSecResourcesSub.
  ///
  /// In en, this message translates to:
  /// **'Spend ZCoins on gold & materials'**
  String get shopSecResourcesSub;

  /// No description provided for @shopSecAuras.
  ///
  /// In en, this message translates to:
  /// **'AURAS'**
  String get shopSecAuras;

  /// No description provided for @shopSecAurasSub.
  ///
  /// In en, this message translates to:
  /// **'Equip a glow — owned aura bonuses always stack'**
  String get shopSecAurasSub;

  /// No description provided for @shopSecBoosts.
  ///
  /// In en, this message translates to:
  /// **'BOOSTS'**
  String get shopSecBoosts;

  /// No description provided for @shopSecBoostsSub.
  ///
  /// In en, this message translates to:
  /// **'Permanent stat boosts'**
  String get shopSecBoostsSub;

  /// No description provided for @shopSecTitles.
  ///
  /// In en, this message translates to:
  /// **'TITLES'**
  String get shopSecTitles;

  /// No description provided for @shopSecTitlesSub.
  ///
  /// In en, this message translates to:
  /// **'A rank displayed beneath your name'**
  String get shopSecTitlesSub;

  /// No description provided for @shopSecColours.
  ///
  /// In en, this message translates to:
  /// **'NAME COLOURS'**
  String get shopSecColours;

  /// No description provided for @shopSecColoursSub.
  ///
  /// In en, this message translates to:
  /// **'Colour + glow for your hero name'**
  String get shopSecColoursSub;

  /// No description provided for @shopSecFrames.
  ///
  /// In en, this message translates to:
  /// **'FRAMES'**
  String get shopSecFrames;

  /// No description provided for @shopSecFramesSub.
  ///
  /// In en, this message translates to:
  /// **'A frame around your hero portrait'**
  String get shopSecFramesSub;

  /// No description provided for @shopSecSlots.
  ///
  /// In en, this message translates to:
  /// **'CHARACTER SLOTS'**
  String get shopSecSlots;

  /// No description provided for @shopSecSlotsSub.
  ///
  /// In en, this message translates to:
  /// **'Extra character save slots'**
  String get shopSecSlotsSub;

  /// No description provided for @shopPremiumArmor.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM CLASS ARMOR'**
  String get shopPremiumArmor;

  /// No description provided for @shopEndgameSkin.
  ///
  /// In en, this message translates to:
  /// **'{cls} · Endgame skin'**
  String shopEndgameSkin(String cls);

  /// No description provided for @shopIncludedBonuses.
  ///
  /// In en, this message translates to:
  /// **'INCLUDED BONUSES'**
  String get shopIncludedBonuses;

  /// No description provided for @shopEverySkin.
  ///
  /// In en, this message translates to:
  /// **'every shop skin bonus, combined'**
  String get shopEverySkin;

  /// No description provided for @shopEquippedCheck.
  ///
  /// In en, this message translates to:
  /// **'✓ EQUIPPED'**
  String get shopEquippedCheck;

  /// No description provided for @shopUnequip.
  ///
  /// In en, this message translates to:
  /// **'UNEQUIP'**
  String get shopUnequip;

  /// No description provided for @shopUnlockPrice.
  ///
  /// In en, this message translates to:
  /// **'UNLOCK  ·  {price}'**
  String shopUnlockPrice(String price);

  /// No description provided for @shopStoreUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Store unavailable — try again later.'**
  String get shopStoreUnavailable;

  /// No description provided for @shopVipSub.
  ///
  /// In en, this message translates to:
  /// **'VIP SUBSCRIPTION'**
  String get shopVipSub;

  /// No description provided for @shopSubscribed.
  ///
  /// In en, this message translates to:
  /// **'✓ SUBSCRIBED'**
  String get shopSubscribed;

  /// No description provided for @shopSubscribe.
  ///
  /// In en, this message translates to:
  /// **'SUBSCRIBE  {price}'**
  String shopSubscribe(String price);

  /// No description provided for @shopEverythingPlus.
  ///
  /// In en, this message translates to:
  /// **'Everything in Vanguard\'s Pact, plus:'**
  String get shopEverythingPlus;

  /// No description provided for @shopIncludedPerks.
  ///
  /// In en, this message translates to:
  /// **'INCLUDED PERKS'**
  String get shopIncludedPerks;

  /// No description provided for @shopGlow.
  ///
  /// In en, this message translates to:
  /// **'✦ GLOW'**
  String get shopGlow;

  /// No description provided for @shopExclusive.
  ///
  /// In en, this message translates to:
  /// **'EXCLUSIVE'**
  String get shopExclusive;

  /// No description provided for @shopNoAd.
  ///
  /// In en, this message translates to:
  /// **'No ad available right now — try again later.'**
  String get shopNoAd;

  /// No description provided for @shopWatchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch an Ad'**
  String get shopWatchAd;

  /// No description provided for @shopComeBackTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Come back tomorrow for more free ZCoins!'**
  String get shopComeBackTomorrow;

  /// No description provided for @shopWait.
  ///
  /// In en, this message translates to:
  /// **'WAIT...'**
  String get shopWait;

  /// No description provided for @shopWatch.
  ///
  /// In en, this message translates to:
  /// **'WATCH'**
  String get shopWatch;

  /// No description provided for @shopRewardEarned.
  ///
  /// In en, this message translates to:
  /// **'REWARD EARNED'**
  String get shopRewardEarned;

  /// No description provided for @shopPlusZcoins.
  ///
  /// In en, this message translates to:
  /// **'+{amount} ZCoins'**
  String shopPlusZcoins(Object amount);

  /// No description provided for @shopCollect.
  ///
  /// In en, this message translates to:
  /// **'COLLECT'**
  String get shopCollect;

  /// No description provided for @shopPurchasesRestored.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored. Any active subscriptions or packs have been re-applied.'**
  String get shopPurchasesRestored;

  /// No description provided for @shopRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get shopRestorePurchases;

  /// No description provided for @artSalvageTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Salvage {count} artifact?} other{Salvage {count} artifacts?}}'**
  String artSalvageTitle(int count);

  /// No description provided for @artSalvage.
  ///
  /// In en, this message translates to:
  /// **'SALVAGE'**
  String get artSalvage;

  /// No description provided for @artSalvaged.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one{Salvaged {n} artifact for ◆ {gained} mythril.} other{Salvaged {n} artifacts for ◆ {gained} mythril.}}'**
  String artSalvaged(int n, Object gained);

  /// No description provided for @artTable.
  ///
  /// In en, this message translates to:
  /// **'ARTIFACT TABLE'**
  String get artTable;

  /// No description provided for @artSlots.
  ///
  /// In en, this message translates to:
  /// **'{n}/{max} slots'**
  String artSlots(Object n, Object max);

  /// No description provided for @artAutoEquipped.
  ///
  /// In en, this message translates to:
  /// **'Auto-equipped {n} best artifacts.'**
  String artAutoEquipped(Object n);

  /// No description provided for @artNoneToEquip.
  ///
  /// In en, this message translates to:
  /// **'No artifacts to equip.'**
  String get artNoneToEquip;

  /// No description provided for @artAutoEquip.
  ///
  /// In en, this message translates to:
  /// **'⚡ AUTO-EQUIP'**
  String get artAutoEquip;

  /// No description provided for @artSalvageBtn.
  ///
  /// In en, this message translates to:
  /// **'♻ SALVAGE'**
  String get artSalvageBtn;

  /// No description provided for @artTitle.
  ///
  /// In en, this message translates to:
  /// **'ARTIFACTS'**
  String get artTitle;

  /// No description provided for @artPlaceHint.
  ///
  /// In en, this message translates to:
  /// **'Place artifacts on the table to gain bonuses.'**
  String get artPlaceHint;

  /// No description provided for @artTableBonuses.
  ///
  /// In en, this message translates to:
  /// **'TABLE BONUSES'**
  String get artTableBonuses;

  /// No description provided for @artCollection.
  ///
  /// In en, this message translates to:
  /// **'COLLECTION'**
  String get artCollection;

  /// No description provided for @artCount.
  ///
  /// In en, this message translates to:
  /// **'({n})'**
  String artCount(Object n);

  /// No description provided for @artTapToPlace.
  ///
  /// In en, this message translates to:
  /// **'Tap a grid cell to place \"{name}\"'**
  String artTapToPlace(String name);

  /// No description provided for @artTapCancel.
  ///
  /// In en, this message translates to:
  /// **'tap again to cancel'**
  String get artTapCancel;

  /// No description provided for @artSet.
  ///
  /// In en, this message translates to:
  /// **'SET'**
  String get artSet;

  /// No description provided for @artUpgradeCost.
  ///
  /// In en, this message translates to:
  /// **'{cost} Mythril'**
  String artUpgradeCost(Object cost);

  /// No description provided for @artNoSets.
  ///
  /// In en, this message translates to:
  /// **'No Set pieces equipped yet — {n} sets to discover.'**
  String artNoSets(Object n);

  /// No description provided for @artCountOf3.
  ///
  /// In en, this message translates to:
  /// **'{count} / 3'**
  String artCountOf3(Object count);

  /// No description provided for @artHowToGet.
  ///
  /// In en, this message translates to:
  /// **'HOW TO GET ARTIFACTS'**
  String get artHowToGet;

  /// No description provided for @artRowCampaign.
  ///
  /// In en, this message translates to:
  /// **'Campaign Bosses'**
  String get artRowCampaign;

  /// No description provided for @artRowCampaignDesc.
  ///
  /// In en, this message translates to:
  /// **'about a 25% chance to drop on every boss-stage kill.'**
  String get artRowCampaignDesc;

  /// No description provided for @artRowDungeon.
  ///
  /// In en, this message translates to:
  /// **'Dungeon runs'**
  String get artRowDungeon;

  /// No description provided for @artRowDungeonDesc.
  ///
  /// In en, this message translates to:
  /// **'each boss you defeat drops one — up to 2 per run. Best steady farm.'**
  String get artRowDungeonDesc;

  /// No description provided for @artRowBossRush.
  ///
  /// In en, this message translates to:
  /// **'Boss Rush'**
  String get artRowBossRush;

  /// No description provided for @artRowBossRushDesc.
  ///
  /// In en, this message translates to:
  /// **'clear a run with an A or S rank to earn an artifact.'**
  String get artRowBossRushDesc;

  /// No description provided for @artSalvageBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Permanently destroy {count} unequipped artifact for ◆ {mythril} mythril? Equipped artifacts are kept.} other{Permanently destroy all {count} unequipped artifacts for ◆ {mythril} mythril? Equipped artifacts are kept.}}'**
  String artSalvageBody(int count, Object mythril);

  /// No description provided for @artSetBlurb.
  ///
  /// In en, this message translates to:
  /// **'Collect matching green Set pieces. 2 equipped = partial bonus, all 3 = full bonus.'**
  String get artSetBlurb;

  /// No description provided for @art2Set.
  ///
  /// In en, this message translates to:
  /// **'2-Set'**
  String get art2Set;

  /// No description provided for @art3Set.
  ///
  /// In en, this message translates to:
  /// **'3-Set'**
  String get art3Set;

  /// No description provided for @ptEssence.
  ///
  /// In en, this message translates to:
  /// **'essence'**
  String get ptEssence;

  /// No description provided for @ptTheClass.
  ///
  /// In en, this message translates to:
  /// **'THE {cls}'**
  String ptTheClass(String cls);

  /// No description provided for @ptRespecBranch.
  ///
  /// In en, this message translates to:
  /// **'Respec {branch}?'**
  String ptRespecBranch(String branch);

  /// No description provided for @ptRefund.
  ///
  /// In en, this message translates to:
  /// **'Refund {refund} essence (75%)'**
  String ptRefund(Object refund);

  /// No description provided for @ptRespec.
  ///
  /// In en, this message translates to:
  /// **'Respec'**
  String get ptRespec;

  /// No description provided for @ptCrossBranch.
  ///
  /// In en, this message translates to:
  /// **'CROSS-BRANCH'**
  String get ptCrossBranch;

  /// No description provided for @ptFullRespec.
  ///
  /// In en, this message translates to:
  /// **'Full Respec?'**
  String get ptFullRespec;

  /// No description provided for @ptRespec50.
  ///
  /// In en, this message translates to:
  /// **'Respec (50 ZC)'**
  String get ptRespec50;

  /// No description provided for @ptFullRespecBtn.
  ///
  /// In en, this message translates to:
  /// **'FULL RESPEC (50 ZC)'**
  String get ptFullRespecBtn;

  /// No description provided for @ptTitle.
  ///
  /// In en, this message translates to:
  /// **'PASSIVE TREE'**
  String get ptTitle;

  /// No description provided for @ptNow.
  ///
  /// In en, this message translates to:
  /// **'NOW'**
  String get ptNow;

  /// No description provided for @ptUpgradeCost.
  ///
  /// In en, this message translates to:
  /// **'UPGRADE  ({cost} ✦)'**
  String ptUpgradeCost(Object cost);

  /// No description provided for @ptLocked.
  ///
  /// In en, this message translates to:
  /// **'LOCKED — spend 25 ranks in more branches'**
  String get ptLocked;

  /// No description provided for @ptLockedMax.
  ///
  /// In en, this message translates to:
  /// **'LOCKED — max all branch nodes first'**
  String get ptLockedMax;

  /// No description provided for @ptMaxRankTotal.
  ///
  /// In en, this message translates to:
  /// **'MAX RANK — {val} total'**
  String ptMaxRankTotal(String val);

  /// No description provided for @ptFullRespecBody.
  ///
  /// In en, this message translates to:
  /// **'Reset ALL passive nodes.\nRefund {refund} essence (60%).\nCost: 50 zcoins.'**
  String ptFullRespecBody(Object refund);

  /// No description provided for @ptNodesUnlocked.
  ///
  /// In en, this message translates to:
  /// **'{count} nodes unlocked'**
  String ptNodesUnlocked(Object count);

  /// No description provided for @ptTutorial.
  ///
  /// In en, this message translates to:
  /// **'You\'ve earned Shards ◆ — spend them here on permanent passive nodes that never reset. Your class branch is at the top. Each node ranks up to 5 for bigger bonuses.'**
  String get ptTutorial;

  /// No description provided for @ptBranchesAt25.
  ///
  /// In en, this message translates to:
  /// **'{count} / 5 branches at 25'**
  String ptBranchesAt25(Object count);

  /// No description provided for @homeExp.
  ///
  /// In en, this message translates to:
  /// **'EXP'**
  String get homeExp;

  /// No description provided for @homeResources.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get homeResources;

  /// No description provided for @homeGold.
  ///
  /// In en, this message translates to:
  /// **'GOLD'**
  String get homeGold;

  /// No description provided for @homeShards.
  ///
  /// In en, this message translates to:
  /// **'SHARDS'**
  String get homeShards;

  /// No description provided for @homeZcoins.
  ///
  /// In en, this message translates to:
  /// **'ZCOINS'**
  String get homeZcoins;

  /// No description provided for @homeMythril.
  ///
  /// In en, this message translates to:
  /// **'MYTHRIL'**
  String get homeMythril;

  /// No description provided for @homeIdleMin.
  ///
  /// In en, this message translates to:
  /// **'IDLE/min'**
  String get homeIdleMin;

  /// No description provided for @homeGoldTip.
  ///
  /// In en, this message translates to:
  /// **'Gold\nEarned from battles and idle income.\nSpend in Upgrades and the Shop.'**
  String get homeGoldTip;

  /// No description provided for @homeShardsTip.
  ///
  /// In en, this message translates to:
  /// **'Shards\nEarned from enemy kills, Dungeons, Expeditions, and Gauntlet.\nSpend on ability upgrades, item upgrades, and Passive Tree nodes.'**
  String get homeShardsTip;

  /// No description provided for @homeZcoinsTip.
  ///
  /// In en, this message translates to:
  /// **'ZCoins\nEarned from achievements and daily chests.\nSpend in the Aura Shop for skins, pets, and auras.'**
  String get homeZcoinsTip;

  /// No description provided for @homeMythrilTip.
  ///
  /// In en, this message translates to:
  /// **'Mythril\nEarned from Dungeons, Boss Rush, and prestige milestones.\nSpend on Artifact upgrades, dungeon affix rerolls, and shrine blessings.'**
  String get homeMythrilTip;

  /// No description provided for @homeIdleTip.
  ///
  /// In en, this message translates to:
  /// **'Idle Gold / min\nGold earned automatically every minute while offline.\nIncreases with hero level, passive upgrades, and pets.'**
  String get homeIdleTip;

  /// No description provided for @homeCurrentCampaign.
  ///
  /// In en, this message translates to:
  /// **'Current Campaign'**
  String get homeCurrentCampaign;

  /// No description provided for @homeStage.
  ///
  /// In en, this message translates to:
  /// **'STAGE {n}'**
  String homeStage(Object n);

  /// Next-goal banner header; reward = name of the upcoming unlock
  ///
  /// In en, this message translates to:
  /// **'NEXT: UNLOCK {reward}'**
  String homeNextGoal(Object reward);

  /// Next-goal banner progress line
  ///
  /// In en, this message translates to:
  /// **'{remaining} stages to go — clear Stage {stage}'**
  String homeNextGoalProgress(Object remaining, Object stage);

  /// Shown on a locked alt-mode in the demo/web build
  ///
  /// In en, this message translates to:
  /// **'Unlocked in the full game. The demo includes the complete campaign — get the full game for Dungeons, PvP and the endgame difficulty tiers.'**
  String get demoModeLocked;

  /// Call-to-action chip on demo locked modes
  ///
  /// In en, this message translates to:
  /// **'GET THE FULL GAME'**
  String get demoFullGameCta;

  /// No description provided for @homeSecCombat.
  ///
  /// In en, this message translates to:
  /// **'COMBAT'**
  String get homeSecCombat;

  /// No description provided for @homeSecSocial.
  ///
  /// In en, this message translates to:
  /// **'SOCIAL'**
  String get homeSecSocial;

  /// No description provided for @homeNavChallengeGauntlet.
  ///
  /// In en, this message translates to:
  /// **'CHALLENGE GAUNTLET'**
  String get homeNavChallengeGauntlet;

  /// No description provided for @homeNavBountyBoard.
  ///
  /// In en, this message translates to:
  /// **'BOUNTY BOARD'**
  String get homeNavBountyBoard;

  /// No description provided for @homeNavSeasonPass.
  ///
  /// In en, this message translates to:
  /// **'SEASON PASS'**
  String get homeNavSeasonPass;

  /// No description provided for @homeNavWorldEvent.
  ///
  /// In en, this message translates to:
  /// **'WORLD EVENT'**
  String get homeNavWorldEvent;

  /// No description provided for @homeNavLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'LEADERBOARD'**
  String get homeNavLeaderboard;

  /// No description provided for @homeNavChallengeModifiers.
  ///
  /// In en, this message translates to:
  /// **'CHALLENGE MODIFIERS'**
  String get homeNavChallengeModifiers;

  /// No description provided for @homeQuickAccess.
  ///
  /// In en, this message translates to:
  /// **'QUICK ACCESS'**
  String get homeQuickAccess;

  /// No description provided for @homeGettingStarted.
  ///
  /// In en, this message translates to:
  /// **'GETTING STARTED'**
  String get homeGettingStarted;

  /// No description provided for @homeStep1.
  ///
  /// In en, this message translates to:
  /// **'Win your first Campaign battle'**
  String get homeStep1;

  /// No description provided for @homeStep2.
  ///
  /// In en, this message translates to:
  /// **'Level up your hero — visit Character Sheet'**
  String get homeStep2;

  /// No description provided for @homeStep3.
  ///
  /// In en, this message translates to:
  /// **'Open HERO and buy your first Ability Score upgrade'**
  String get homeStep3;

  /// No description provided for @homeStep4.
  ///
  /// In en, this message translates to:
  /// **'Reach Stage 5 — Abilities and Daily Challenges unlock!'**
  String get homeStep4;

  /// No description provided for @homeHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'UPGRADES  •  ARMORY  •  ALLIES  •  CODEX'**
  String get homeHeroSubtitle;

  /// No description provided for @homeTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow: '**
  String get homeTomorrow;

  /// No description provided for @dailyWeekly.
  ///
  /// In en, this message translates to:
  /// **'WEEKLY'**
  String get dailyWeekly;

  /// No description provided for @dailyClaimAll.
  ///
  /// In en, this message translates to:
  /// **'CLAIM ALL'**
  String get dailyClaimAll;

  /// No description provided for @dailyHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How It Works'**
  String get dailyHowItWorks;

  /// No description provided for @dailyThisWeek.
  ///
  /// In en, this message translates to:
  /// **'THIS WEEK\'S CHALLENGES'**
  String get dailyThisWeek;

  /// No description provided for @dailyCompleted.
  ///
  /// In en, this message translates to:
  /// **'{claimed} / {total} completed'**
  String dailyCompleted(Object claimed, Object total);

  /// No description provided for @dailyWeeklyLoading.
  ///
  /// In en, this message translates to:
  /// **'Weekly challenges loading...'**
  String get dailyWeeklyLoading;

  /// No description provided for @dailyAboutWeekly.
  ///
  /// In en, this message translates to:
  /// **'About Weekly Challenges'**
  String get dailyAboutWeekly;

  /// No description provided for @dailyReady.
  ///
  /// In en, this message translates to:
  /// **'READY'**
  String get dailyReady;

  /// No description provided for @dailyTodayProgress.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S PROGRESS'**
  String get dailyTodayProgress;

  /// No description provided for @dailyChest.
  ///
  /// In en, this message translates to:
  /// **'DAILY CHEST'**
  String get dailyChest;

  /// No description provided for @dailyClaimedTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Claimed! Come back tomorrow.'**
  String get dailyClaimedTomorrow;

  /// No description provided for @dailyHintKill.
  ///
  /// In en, this message translates to:
  /// **'Kill enemies'**
  String get dailyHintKill;

  /// No description provided for @dailyHintKillD.
  ///
  /// In en, this message translates to:
  /// **'Fight in Campaign or Endless mode'**
  String get dailyHintKillD;

  /// No description provided for @dailyHintWin.
  ///
  /// In en, this message translates to:
  /// **'Win battles'**
  String get dailyHintWin;

  /// No description provided for @dailyHintWinD.
  ///
  /// In en, this message translates to:
  /// **'Defeating an enemy counts as a win'**
  String get dailyHintWinD;

  /// No description provided for @dailyHintBoss.
  ///
  /// In en, this message translates to:
  /// **'Defeat boss'**
  String get dailyHintBoss;

  /// No description provided for @dailyHintBossD.
  ///
  /// In en, this message translates to:
  /// **'Stage 5, 10, 15, 20, 25 or Endless every 5th'**
  String get dailyHintBossD;

  /// No description provided for @dailyHintAbility.
  ///
  /// In en, this message translates to:
  /// **'Use abilities'**
  String get dailyHintAbility;

  /// No description provided for @dailyHintAbilityD.
  ///
  /// In en, this message translates to:
  /// **'Active abilities fire automatically in battle'**
  String get dailyHintAbilityD;

  /// No description provided for @dailyHintEquip.
  ///
  /// In en, this message translates to:
  /// **'Equip item'**
  String get dailyHintEquip;

  /// No description provided for @dailyHintEquipD.
  ///
  /// In en, this message translates to:
  /// **'Tap a bag item → Equip in Inventory'**
  String get dailyHintEquipD;

  /// No description provided for @dailyHintGold.
  ///
  /// In en, this message translates to:
  /// **'Reach gold'**
  String get dailyHintGold;

  /// No description provided for @dailyHintGoldD.
  ///
  /// In en, this message translates to:
  /// **'Just have that much gold in your stash'**
  String get dailyHintGoldD;

  /// No description provided for @dailyHintDamage.
  ///
  /// In en, this message translates to:
  /// **'Deal damage'**
  String get dailyHintDamage;

  /// No description provided for @dailyHintDamageD.
  ///
  /// In en, this message translates to:
  /// **'Cumulative damage dealt in any mode'**
  String get dailyHintDamageD;

  /// No description provided for @dailyHintIdle.
  ///
  /// In en, this message translates to:
  /// **'Collect idle'**
  String get dailyHintIdle;

  /// No description provided for @dailyHintIdleD.
  ///
  /// In en, this message translates to:
  /// **'Tap the idle reward on the home screen'**
  String get dailyHintIdleD;

  /// No description provided for @dailyHintResets.
  ///
  /// In en, this message translates to:
  /// **'Resets'**
  String get dailyHintResets;

  /// No description provided for @dailyHintResetsD.
  ///
  /// In en, this message translates to:
  /// **'Every Monday — 5 new challenges each week'**
  String get dailyHintResetsD;

  /// No description provided for @dailyHintRewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get dailyHintRewards;

  /// No description provided for @dailyHintRewardsD.
  ///
  /// In en, this message translates to:
  /// **'Larger than daily: essence, mythril, ZCoins'**
  String get dailyHintRewardsD;

  /// No description provided for @dailyHintSeasonXp.
  ///
  /// In en, this message translates to:
  /// **'Season XP'**
  String get dailyHintSeasonXp;

  /// No description provided for @dailyHintSeasonXpD.
  ///
  /// In en, this message translates to:
  /// **'+50 season XP per claimed weekly challenge'**
  String get dailyHintSeasonXpD;

  /// No description provided for @dailyHintProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get dailyHintProgress;

  /// No description provided for @dailyHintProgressD.
  ///
  /// In en, this message translates to:
  /// **'Counts from Monday midnight, not from claim'**
  String get dailyHintProgressD;

  /// No description provided for @dailyTutorial.
  ///
  /// In en, this message translates to:
  /// **'Complete daily challenges to earn gold, shards, essence, and ZCoins. All 7 challenges reset each day. Complete them all for a bonus chest!'**
  String get dailyTutorial;

  /// No description provided for @petOwned.
  ///
  /// In en, this message translates to:
  /// **'{a} / {b}  owned'**
  String petOwned(Object a, Object b);

  /// No description provided for @petTitle.
  ///
  /// In en, this message translates to:
  /// **'COMPANIONS'**
  String get petTitle;

  /// No description provided for @petActiveBonuses.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE BONUSES (all owned pets)'**
  String get petActiveBonuses;

  /// No description provided for @petNoCompanion.
  ///
  /// In en, this message translates to:
  /// **'No companion equipped'**
  String get petNoCompanion;

  /// No description provided for @petEquipHint.
  ///
  /// In en, this message translates to:
  /// **'Equip a pet to have it appear in battle.'**
  String get petEquipHint;

  /// No description provided for @petPremium.
  ///
  /// In en, this message translates to:
  /// **'★ PREMIUM'**
  String get petPremium;

  /// No description provided for @petInBattle.
  ///
  /// In en, this message translates to:
  /// **'IN BATTLE'**
  String get petInBattle;

  /// No description provided for @petRecruitTitle.
  ///
  /// In en, this message translates to:
  /// **'Recruit {name}?'**
  String petRecruitTitle(String name);

  /// No description provided for @petRecruit.
  ///
  /// In en, this message translates to:
  /// **'RECRUIT'**
  String get petRecruit;

  /// No description provided for @petEvolveTitle.
  ///
  /// In en, this message translates to:
  /// **'Evolve {name}?'**
  String petEvolveTitle(String name);

  /// No description provided for @petEvolveN.
  ///
  /// In en, this message translates to:
  /// **'EVOLVE  Evo {n}'**
  String petEvolveN(Object n);

  /// No description provided for @petTutorial.
  ///
  /// In en, this message translates to:
  /// **'Pet companions join you in battle and stack their bonuses passively — even ones not equipped. Equip one to have it appear at your side during fights. Evolve owned pets twice to double their bonus value.'**
  String get petTutorial;

  /// No description provided for @petRecruitBody.
  ///
  /// In en, this message translates to:
  /// **'{desc}\n\nBonus: {bonus}\n\nCost: {cost} ZCoins'**
  String petRecruitBody(String desc, String bonus, Object cost);

  /// No description provided for @petEvolveBody.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Evolution {level}.\n\nNew bonus: +{bonus}\nCost: {cost} ZCoins'**
  String petEvolveBody(Object level, String bonus, Object cost);

  /// No description provided for @questTitle.
  ///
  /// In en, this message translates to:
  /// **'QUESTLINES'**
  String get questTitle;

  /// No description provided for @questAdventure.
  ///
  /// In en, this message translates to:
  /// **'ADVENTURE QUESTLINE'**
  String get questAdventure;

  /// No description provided for @questAdventureSub.
  ///
  /// In en, this message translates to:
  /// **'Learn every game system on the road to stage 100.'**
  String get questAdventureSub;

  /// No description provided for @questUnlocksLv30.
  ///
  /// In en, this message translates to:
  /// **'Unlocks at Level 30  (current: {lvl})'**
  String questUnlocksLv30(Object lvl);

  /// No description provided for @questUltUnlocked.
  ///
  /// In en, this message translates to:
  /// **'ULTIMATE ABILITY UNLOCKED'**
  String get questUltUnlocked;

  /// No description provided for @questUltAvailable.
  ///
  /// In en, this message translates to:
  /// **'{cls} ultimate is now available in battle.'**
  String questUltAvailable(String cls);

  /// No description provided for @questProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get questProgressLabel;

  /// No description provided for @questCompleteFirst.
  ///
  /// In en, this message translates to:
  /// **'Complete quest {n} first to unlock.'**
  String questCompleteFirst(Object n);

  /// No description provided for @questClaimReward.
  ///
  /// In en, this message translates to:
  /// **'CLAIM REWARD'**
  String get questClaimReward;

  /// No description provided for @questRewardLabel.
  ///
  /// In en, this message translates to:
  /// **'Reward: '**
  String get questRewardLabel;

  /// No description provided for @questClassQuestline.
  ///
  /// In en, this message translates to:
  /// **'{cls} QUESTLINE'**
  String questClassQuestline(String cls);

  /// No description provided for @questComplete5.
  ///
  /// In en, this message translates to:
  /// **'Complete 5 quests to unlock the Ultimate Ability.'**
  String get questComplete5;

  /// No description provided for @subTitle.
  ///
  /// In en, this message translates to:
  /// **'SPECIALIZATION'**
  String get subTitle;

  /// No description provided for @subLevel50.
  ///
  /// In en, this message translates to:
  /// **'LEVEL 50 SPECIALIZATION'**
  String get subLevel50;

  /// No description provided for @subChooseBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a specialization for your {cls}. It grants a powerful capstone bonus plus stat bonuses, applied immediately. You can change it later for {cost} ZCoins.'**
  String subChooseBody(String cls, Object cost);

  /// No description provided for @subClassSpecs.
  ///
  /// In en, this message translates to:
  /// **'{cls} SPECIALIZATIONS  ({n})'**
  String subClassSpecs(String cls, Object n);

  /// No description provided for @subUnlocksAt.
  ///
  /// In en, this message translates to:
  /// **'Specialization unlocks at Level {lvl}.'**
  String subUnlocksAt(Object lvl);

  /// No description provided for @subChooseTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose {name}?'**
  String subChooseTitle(String name);

  /// No description provided for @subStatBonuses.
  ///
  /// In en, this message translates to:
  /// **'STAT BONUSES'**
  String get subStatBonuses;

  /// No description provided for @subCapstone.
  ///
  /// In en, this message translates to:
  /// **'CAPSTONE BONUS'**
  String get subCapstone;

  /// No description provided for @subSpecialEffect.
  ///
  /// In en, this message translates to:
  /// **'SPECIAL EFFECT'**
  String get subSpecialEffect;

  /// No description provided for @subChangeLater.
  ///
  /// In en, this message translates to:
  /// **'You can change this later for {cost} ZCoins.'**
  String subChangeLater(Object cost);

  /// No description provided for @subCouldNotSet.
  ///
  /// In en, this message translates to:
  /// **'Could not set specialization — try again.'**
  String get subCouldNotSet;

  /// No description provided for @subChangeSpec.
  ///
  /// In en, this message translates to:
  /// **'CHANGE SPECIALIZATION  —  {cost} ZCoins'**
  String subChangeSpec(Object cost);

  /// No description provided for @subChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Change specialization?'**
  String get subChangeTitle;

  /// No description provided for @subChangeBody.
  ///
  /// In en, this message translates to:
  /// **'Spend {cost} ZCoins to clear your current specialization and choose a new one?\n\nYour ZCoins: {zcoins}'**
  String subChangeBody(Object cost, Object zcoins);

  /// No description provided for @subNotEnough.
  ///
  /// In en, this message translates to:
  /// **'Not enough ZCoins to respec.'**
  String get subNotEnough;

  /// No description provided for @subActiveSubclass.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE SUBCLASS'**
  String get subActiveSubclass;

  /// No description provided for @subChosen.
  ///
  /// In en, this message translates to:
  /// **'CHOSEN'**
  String get subChosen;

  /// No description provided for @subActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get subActive;

  /// No description provided for @subChoosePath.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE THIS PATH'**
  String get subChoosePath;

  /// No description provided for @expTitle.
  ///
  /// In en, this message translates to:
  /// **'EXPEDITIONS'**
  String get expTitle;

  /// No description provided for @expCollectAll.
  ///
  /// In en, this message translates to:
  /// **'COLLECT ALL'**
  String get expCollectAll;

  /// No description provided for @expDispatchAll.
  ///
  /// In en, this message translates to:
  /// **'DISPATCH ALL'**
  String get expDispatchAll;

  /// No description provided for @expNoMercs.
  ///
  /// In en, this message translates to:
  /// **'No Mercenaries Yet'**
  String get expNoMercs;

  /// No description provided for @expNoMercsSub.
  ///
  /// In en, this message translates to:
  /// **'Recruit mercenaries from the MERCS tab in Hero Hub to send them on expeditions.'**
  String get expNoMercsSub;

  /// No description provided for @expTodayLocations.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S LOCATIONS'**
  String get expTodayLocations;

  /// No description provided for @expRefreshIn.
  ///
  /// In en, this message translates to:
  /// **'🔄 {time}'**
  String expRefreshIn(String time);

  /// No description provided for @expYourParty.
  ///
  /// In en, this message translates to:
  /// **'YOUR PARTY'**
  String get expYourParty;

  /// No description provided for @expDispatch.
  ///
  /// In en, this message translates to:
  /// **'DISPATCH'**
  String get expDispatch;

  /// No description provided for @expDone.
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get expDone;

  /// No description provided for @expCollectRewards.
  ///
  /// In en, this message translates to:
  /// **'COLLECT REWARDS'**
  String get expCollectRewards;

  /// No description provided for @expInProgress.
  ///
  /// In en, this message translates to:
  /// **'IN PROGRESS...'**
  String get expInProgress;

  /// No description provided for @expReturned.
  ///
  /// In en, this message translates to:
  /// **'{name} returned!'**
  String expReturned(String name);

  /// No description provided for @expDiscovery.
  ///
  /// In en, this message translates to:
  /// **'✦  DISCOVERY'**
  String get expDiscovery;

  /// No description provided for @expGreat.
  ///
  /// In en, this message translates to:
  /// **'GREAT'**
  String get expGreat;

  /// No description provided for @expDispatchMerc.
  ///
  /// In en, this message translates to:
  /// **'DISPATCH {name}'**
  String expDispatchMerc(String name);

  /// No description provided for @expChooseLocation.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE LOCATION'**
  String get expChooseLocation;

  /// No description provided for @expDuration.
  ///
  /// In en, this message translates to:
  /// **'DURATION'**
  String get expDuration;

  /// No description provided for @expEstRewards.
  ///
  /// In en, this message translates to:
  /// **'ESTIMATED REWARDS'**
  String get expEstRewards;

  /// No description provided for @expSend.
  ///
  /// In en, this message translates to:
  /// **'SEND ON EXPEDITION'**
  String get expSend;

  /// No description provided for @acctSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in cancelled or failed.'**
  String get acctSignInFailed;

  /// No description provided for @acctSignOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get acctSignOutTitle;

  /// No description provided for @acctSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get acctSignOut;

  /// No description provided for @acctSignOutBody.
  ///
  /// In en, this message translates to:
  /// **'Your local save is kept. Cloud sync will pause until you sign in again.'**
  String get acctSignOutBody;

  /// No description provided for @acctDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account & data?'**
  String get acctDeleteTitle;

  /// No description provided for @acctDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'DELETE EVERYTHING'**
  String get acctDeleteAll;

  /// No description provided for @acctDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account and ALL data — every character, your cloud save, PvP standing, and leaderboard entries. This cannot be undone.'**
  String get acctDeleteBody;

  /// No description provided for @acctDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get acctDeleted;

  /// No description provided for @acctDeletedBody.
  ///
  /// In en, this message translates to:
  /// **'Your account and all data have been removed. The app will now close.'**
  String get acctDeletedBody;

  /// No description provided for @acctClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get acctClose;

  /// No description provided for @acctPlayer.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get acctPlayer;

  /// No description provided for @acctSyncNow.
  ///
  /// In en, this message translates to:
  /// **'SYNC NOW'**
  String get acctSyncNow;

  /// No description provided for @acctSignOutBtn.
  ///
  /// In en, this message translates to:
  /// **'SIGN OUT'**
  String get acctSignOutBtn;

  /// No description provided for @acctSignInGoogle.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN WITH GOOGLE'**
  String get acctSignInGoogle;

  /// No description provided for @acctDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'DELETE ACCOUNT'**
  String get acctDeleteAccount;

  /// No description provided for @acctDangerSub.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account and all associated data.'**
  String get acctDangerSub;

  /// No description provided for @acctLinked.
  ///
  /// In en, this message translates to:
  /// **'Google account linked'**
  String get acctLinked;

  /// No description provided for @acctNotSynced.
  ///
  /// In en, this message translates to:
  /// **'Not synced yet this session'**
  String get acctNotSynced;

  /// No description provided for @acctNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No account linked'**
  String get acctNoAccount;

  /// No description provided for @acctAboutCloud.
  ///
  /// In en, this message translates to:
  /// **'ABOUT CLOUD SAVES'**
  String get acctAboutCloud;

  /// No description provided for @acctCloud1.
  ///
  /// In en, this message translates to:
  /// **'Your progress syncs automatically every 5 minutes when signed in.'**
  String get acctCloud1;

  /// No description provided for @acctCloud2.
  ///
  /// In en, this message translates to:
  /// **'Play on any Windows device with the same Google account.'**
  String get acctCloud2;

  /// No description provided for @acctCloud3.
  ///
  /// In en, this message translates to:
  /// **'Cloud saves are stored securely with your Google account.'**
  String get acctCloud3;

  /// No description provided for @invhTabGear.
  ///
  /// In en, this message translates to:
  /// **'GEAR'**
  String get invhTabGear;

  /// No description provided for @invhTabGems.
  ///
  /// In en, this message translates to:
  /// **'GEMS'**
  String get invhTabGems;

  /// No description provided for @invhTabRunes.
  ///
  /// In en, this message translates to:
  /// **'RUNES'**
  String get invhTabRunes;

  /// No description provided for @invhArcaneDust.
  ///
  /// In en, this message translates to:
  /// **'Arcane Dust'**
  String get invhArcaneDust;

  /// No description provided for @invhBag.
  ///
  /// In en, this message translates to:
  /// **'Bag: {n}/{max}'**
  String invhBag(Object n, Object max);

  /// No description provided for @invhCraftGem.
  ///
  /// In en, this message translates to:
  /// **'CRAFT GEM'**
  String get invhCraftGem;

  /// No description provided for @invhCraftTypeGem.
  ///
  /// In en, this message translates to:
  /// **'CRAFT {type} GEM  ({cost} Arcane Dust)'**
  String invhCraftTypeGem(String type, Object cost);

  /// No description provided for @invhOwnedGems.
  ///
  /// In en, this message translates to:
  /// **'OWNED GEMS'**
  String get invhOwnedGems;

  /// No description provided for @invhDismantleBody.
  ///
  /// In en, this message translates to:
  /// **'{bonus}\n\nSocket into a WEAPON for +DMG%, or ARMOUR for +RES% of this gem\'s element.\n\nDismantle returns {dust} Arcane Dust.'**
  String invhDismantleBody(String bonus, Object dust);

  /// No description provided for @invhDismantle.
  ///
  /// In en, this message translates to:
  /// **'DISMANTLE (+{dust} Arcane Dust)'**
  String invhDismantle(Object dust);

  /// No description provided for @invhGemTooltip.
  ///
  /// In en, this message translates to:
  /// **'{name}\n{bonus}\nTap to dismantle'**
  String invhGemTooltip(String name, String bonus);

  /// No description provided for @invhTutGear.
  ///
  /// In en, this message translates to:
  /// **'Your first piece of gear has dropped! Equip it here to boost your stats.'**
  String get invhTutGear;

  /// No description provided for @invhTutForge.
  ///
  /// In en, this message translates to:
  /// **'Combine two items of the same slot to craft a higher-rarity piece, or reforge stats.'**
  String get invhTutForge;

  /// No description provided for @invhTutRunes.
  ///
  /// In en, this message translates to:
  /// **'Craft Runes for temporary combat buffs. Collect dust by salvaging gear.'**
  String get invhTutRunes;

  /// No description provided for @invhTutArtifacts.
  ///
  /// In en, this message translates to:
  /// **'Place artifacts in the grid for permanent passive bonuses.'**
  String get invhTutArtifacts;

  /// No description provided for @invhNoGear.
  ///
  /// In en, this message translates to:
  /// **'No gear yet.\nDefeat enemies to find your first item!'**
  String get invhNoGear;

  /// No description provided for @ascTitle.
  ///
  /// In en, this message translates to:
  /// **'ASCENSION'**
  String get ascTitle;

  /// No description provided for @ascMetaBoard.
  ///
  /// In en, this message translates to:
  /// **'META-BOARD'**
  String get ascMetaBoard;

  /// No description provided for @ascApPoints.
  ///
  /// In en, this message translates to:
  /// **'{points} AP'**
  String ascApPoints(Object points);

  /// No description provided for @ascLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Ascension Level: '**
  String get ascLevelLabel;

  /// No description provided for @ascPrestigeLabel.
  ///
  /// In en, this message translates to:
  /// **'Prestige Level: '**
  String get ascPrestigeLabel;

  /// No description provided for @ascBody.
  ///
  /// In en, this message translates to:
  /// **'Ascension is the deepest reset — it converts your Rebirths into Ascension Points (AP). You earn 1 AP for every Rebirth you sacrifice, so the more you bank before ascending, the bigger the payout.\n\nSpend AP two ways — both permanent and both survive every future reset:\n• The Meta-Board below (XP, gold, damage, idle & prestige bonuses)\n• Ascend your class abilities on the Abilities screen (+10% power per tier, up to 60 AP per character)\n\nYou KEEP:  Ascension bonuses & AP spent, Artifacts, Mythril, Tower Shards, Elemental Mastery.\nYou LOSE:  all Rebirths, hero level, gold, gear, subclass, ability ranks, and campaign progress.'**
  String get ascBody;

  /// No description provided for @ascRequires.
  ///
  /// In en, this message translates to:
  /// **'Requires Prestige Level 5 to Ascend  (current: {prestige}/5)'**
  String ascRequires(Object prestige);

  /// No description provided for @ascAscendAp.
  ///
  /// In en, this message translates to:
  /// **'ASCEND  (+{ap} AP)'**
  String ascAscendAp(Object ap);

  /// No description provided for @ascConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Ascend?'**
  String get ascConfirmTitle;

  /// No description provided for @ascConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Sacrifice {rebirths} Rebirth(s) for {ap} Ascension Point(s).\n\nKEEP: Ascension bonuses, Artifacts, Mythril, Tower Shards, Ability Ascensions.\nLOSE: all Rebirths, hero level, gold, gear, subclass, ability ranks, campaign progress.\n\nThis cannot be undone.'**
  String ascConfirmBody(Object rebirths, Object ap);

  /// No description provided for @weOmegaShop.
  ///
  /// In en, this message translates to:
  /// **'OMEGA SHOP'**
  String get weOmegaShop;

  /// No description provided for @weNowHunting.
  ///
  /// In en, this message translates to:
  /// **'NOW HUNTING'**
  String get weNowHunting;

  /// No description provided for @weDamageLabel.
  ///
  /// In en, this message translates to:
  /// **'Damage: '**
  String get weDamageLabel;

  /// No description provided for @weEndsIn.
  ///
  /// In en, this message translates to:
  /// **'Event ends in  {d}d {h}h {m}m'**
  String weEndsIn(Object d, Object h, Object m);

  /// No description provided for @weHowToEarn.
  ///
  /// In en, this message translates to:
  /// **'HOW TO EARN TOKENS'**
  String get weHowToEarn;

  /// No description provided for @weHowToEarnDesc.
  ///
  /// In en, this message translates to:
  /// **'{name}s have a 15% chance to appear during any battle. Defeat them for 1–3 Event Tokens each.'**
  String weHowToEarnDesc(String name);

  /// No description provided for @weEventBoss.
  ///
  /// In en, this message translates to:
  /// **'⚔ EVENT BOSS'**
  String get weEventBoss;

  /// No description provided for @weClaimLegendary.
  ///
  /// In en, this message translates to:
  /// **'CLAIM LEGENDARY GEAR  (1 🏆 Boss Token)'**
  String get weClaimLegendary;

  /// No description provided for @weGearForged.
  ///
  /// In en, this message translates to:
  /// **'{name} forged at Lv{lv}! Check your bag.'**
  String weGearForged(String name, Object lv);

  /// No description provided for @weRewardClaimed.
  ///
  /// In en, this message translates to:
  /// **'{name} claimed!'**
  String weRewardClaimed(String name);

  /// No description provided for @gauLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Gauntlet Leaderboard'**
  String get gauLeaderboard;

  /// No description provided for @gauRewardPreview.
  ///
  /// In en, this message translates to:
  /// **'REWARD PREVIEW (on clear)'**
  String get gauRewardPreview;

  /// No description provided for @gauAutoRestart.
  ///
  /// In en, this message translates to:
  /// **'AUTO — restarting with your modifiers—'**
  String get gauAutoRestart;

  /// No description provided for @gauBackToGauntlet.
  ///
  /// In en, this message translates to:
  /// **'BACK TO GAUNTLET'**
  String get gauBackToGauntlet;

  /// No description provided for @gauWave.
  ///
  /// In en, this message translates to:
  /// **'WAVE {n} / {total}'**
  String gauWave(Object n, Object total);

  /// No description provided for @gauKills.
  ///
  /// In en, this message translates to:
  /// **'{kills} KILLS'**
  String gauKills(Object kills);

  /// No description provided for @gauEssenceBonus.
  ///
  /// In en, this message translates to:
  /// **'+{pct}% essence'**
  String gauEssenceBonus(Object pct);

  /// No description provided for @brLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Boss Rush Leaderboard'**
  String get brLeaderboard;

  /// No description provided for @brBestScore.
  ///
  /// In en, this message translates to:
  /// **'BEST SCORE: '**
  String get brBestScore;

  /// No description provided for @brBossProgress.
  ///
  /// In en, this message translates to:
  /// **'BOSS {n} / {total}'**
  String brBossProgress(Object n, Object total);

  /// No description provided for @brPlayAgain.
  ///
  /// In en, this message translates to:
  /// **'PLAY AGAIN'**
  String get brPlayAgain;

  /// No description provided for @brPossibleRewards.
  ///
  /// In en, this message translates to:
  /// **'POSSIBLE REWARDS'**
  String get brPossibleRewards;

  /// No description provided for @brRewShards.
  ///
  /// In en, this message translates to:
  /// **'Shards'**
  String get brRewShards;

  /// No description provided for @brRewShardsD.
  ///
  /// In en, this message translates to:
  /// **'10 per boss  ·  +30 on full clear'**
  String get brRewShardsD;

  /// No description provided for @brRewEchoes.
  ///
  /// In en, this message translates to:
  /// **'Echoes'**
  String get brRewEchoes;

  /// No description provided for @brRewEchoesD.
  ///
  /// In en, this message translates to:
  /// **'6 per boss  ·  +25 on full clear'**
  String get brRewEchoesD;

  /// No description provided for @brRewZcoins.
  ///
  /// In en, this message translates to:
  /// **'ZCoins'**
  String get brRewZcoins;

  /// No description provided for @brRewZcoinsD.
  ///
  /// In en, this message translates to:
  /// **'15 on a full clear'**
  String get brRewZcoinsD;

  /// No description provided for @brRewMythril.
  ///
  /// In en, this message translates to:
  /// **'Mythril'**
  String get brRewMythril;

  /// No description provided for @brRewMythrilD.
  ///
  /// In en, this message translates to:
  /// **'Scaled by final rank'**
  String get brRewMythrilD;

  /// No description provided for @brRewArtifact.
  ///
  /// In en, this message translates to:
  /// **'Artifact'**
  String get brRewArtifact;

  /// No description provided for @brRewArtifactD.
  ///
  /// In en, this message translates to:
  /// **'Chance drop on A / S-rank clears'**
  String get brRewArtifactD;

  /// No description provided for @prgShop.
  ///
  /// In en, this message translates to:
  /// **'PARAGON SHOP'**
  String get prgShop;

  /// No description provided for @prgActiveBonuses.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE BONUSES'**
  String get prgActiveBonuses;

  /// No description provided for @prgBoard.
  ///
  /// In en, this message translates to:
  /// **'✦ PARAGON BOARD'**
  String get prgBoard;

  /// No description provided for @prgBoardHint.
  ///
  /// In en, this message translates to:
  /// **'Invest points into a direction — ranks scale forever.'**
  String get prgBoardHint;

  /// No description provided for @prgRank.
  ///
  /// In en, this message translates to:
  /// **'Rank {rank}'**
  String prgRank(Object rank);

  /// No description provided for @prgTutorial.
  ///
  /// In en, this message translates to:
  /// **'✦ Paragon Points are earned by levelling up — 1 per level. Spend them on the Paragon Board and Shop below for permanent power that never resets.'**
  String get prgTutorial;

  /// No description provided for @prgShopSub.
  ///
  /// In en, this message translates to:
  /// **'Spend Paragon Points on permanent upgrades that persist across all future runs.'**
  String get prgShopSub;

  /// No description provided for @achClaimedTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{🏆  {count} ACHIEVEMENT CLAIMED} other{🏆  {count} ACHIEVEMENTS CLAIMED}}'**
  String achClaimedTitle(int count);

  /// No description provided for @achYouReceived.
  ///
  /// In en, this message translates to:
  /// **'You received:'**
  String get achYouReceived;

  /// No description provided for @achNice.
  ///
  /// In en, this message translates to:
  /// **'NICE!'**
  String get achNice;

  /// No description provided for @achClaimAll.
  ///
  /// In en, this message translates to:
  /// **'CLAIM ALL ({n})'**
  String achClaimAll(Object n);

  /// No description provided for @achEconomy.
  ///
  /// In en, this message translates to:
  /// **'ECONOMY & SYSTEMS'**
  String get achEconomy;

  /// No description provided for @achProgress.
  ///
  /// In en, this message translates to:
  /// **'PROGRESS'**
  String get achProgress;

  /// No description provided for @achClaimed.
  ///
  /// In en, this message translates to:
  /// **'{claimed} / {total} claimed'**
  String achClaimed(Object claimed, Object total);

  /// No description provided for @achReady.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} achievement ready to claim!} other{{count} achievements ready to claim!}}'**
  String achReady(int count);

  /// No description provided for @runeTitle.
  ///
  /// In en, this message translates to:
  /// **'ABILITY RUNES'**
  String get runeTitle;

  /// No description provided for @runeArcaneDust.
  ///
  /// In en, this message translates to:
  /// **'🌀 Arcane Dust: '**
  String get runeArcaneDust;

  /// No description provided for @runeOwned.
  ///
  /// In en, this message translates to:
  /// **'📜 Owned: {a}/{b}'**
  String runeOwned(Object a, Object b);

  /// No description provided for @runeNone.
  ///
  /// In en, this message translates to:
  /// **'No runes available for this class.'**
  String get runeNone;

  /// No description provided for @runeAppBar.
  ///
  /// In en, this message translates to:
  /// **'RUNES'**
  String get runeAppBar;

  /// No description provided for @runeSocketed.
  ///
  /// In en, this message translates to:
  /// **'SOCKETED'**
  String get runeSocketed;

  /// No description provided for @runeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not yet found — drops from bosses, dungeons, gauntlet, and expeditions.'**
  String get runeNotFound;

  /// No description provided for @runeEquipFirst.
  ///
  /// In en, this message translates to:
  /// **'Equip a ring or amulet to socket this rune.'**
  String get runeEquipFirst;

  /// No description provided for @runeSocketInto.
  ///
  /// In en, this message translates to:
  /// **'Socket → {name}  (🌀 {cost})'**
  String runeSocketInto(String name, Object cost);

  /// No description provided for @runeBody.
  ///
  /// In en, this message translates to:
  /// **'Socket runes to permanently enhance your abilities.\nEach rune modifies a specific ability — boosting damage, duration, or cooldown.\nCosts Arcane Dust from disenchanting gear, gems, and runes.'**
  String get runeBody;

  /// No description provided for @achTutorial.
  ///
  /// In en, this message translates to:
  /// **'You defeated your first boss! 🏆 Achievements track milestones and reward ZCoins and Shards — claim them here and check back often.'**
  String get achTutorial;

  /// No description provided for @bbLocked.
  ///
  /// In en, this message translates to:
  /// **'BOSS BOUNTIES LOCKED'**
  String get bbLocked;

  /// No description provided for @bbLockedSub.
  ///
  /// In en, this message translates to:
  /// **'Reach campaign stage 20 to start hunting bosses for bounty rewards.'**
  String get bbLockedSub;

  /// No description provided for @bbTitle.
  ///
  /// In en, this message translates to:
  /// **'BOSS BOUNTIES  •  TIER {t}'**
  String bbTitle(Object t);

  /// No description provided for @bbDesc.
  ///
  /// In en, this message translates to:
  /// **'Slay each campaign boss for its bounty. Reach a new tier for a fresh set with bigger rewards.'**
  String get bbDesc;

  /// No description provided for @bbNoBounties.
  ///
  /// In en, this message translates to:
  /// **'No bounties available.'**
  String get bbNoBounties;

  /// No description provided for @bbStageLv.
  ///
  /// In en, this message translates to:
  /// **'Campaign Stage {n}  •  Lv {lv}'**
  String bbStageLv(Object n, Object lv);

  /// No description provided for @bbSlain.
  ///
  /// In en, this message translates to:
  /// **'{name} slain!  {detail}'**
  String bbSlain(String name, String detail);

  /// No description provided for @bbStage.
  ///
  /// In en, this message translates to:
  /// **'Stage {n}'**
  String bbStage(Object n);

  /// No description provided for @bbGearReward.
  ///
  /// In en, this message translates to:
  /// **'🎁 {rarity} Gear'**
  String bbGearReward(String rarity);

  /// No description provided for @bestTotalKills.
  ///
  /// In en, this message translates to:
  /// **'{n} total kills'**
  String bestTotalKills(Object n);

  /// No description provided for @bestTypeMaxed.
  ///
  /// In en, this message translates to:
  /// **'TYPE MAXED'**
  String get bestTypeMaxed;

  /// No description provided for @bestGoldBonus.
  ///
  /// In en, this message translates to:
  /// **'+{pct}% gold'**
  String bestGoldBonus(Object pct);

  /// No description provided for @bestKilled.
  ///
  /// In en, this message translates to:
  /// **'killed'**
  String get bestKilled;

  /// No description provided for @bestNextDmg.
  ///
  /// In en, this message translates to:
  /// **'next +1% dmg at {n} kills'**
  String bestNextDmg(Object n);

  /// No description provided for @lsTitle.
  ///
  /// In en, this message translates to:
  /// **'DAILY LOGIN'**
  String get lsTitle;

  /// No description provided for @lsComeBack.
  ///
  /// In en, this message translates to:
  /// **'Come back tomorrow for your next reward!'**
  String get lsComeBack;

  /// No description provided for @lsStreakDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} day} other{{count} days}}'**
  String lsStreakDays(int count);

  /// No description provided for @lsClaimReward.
  ///
  /// In en, this message translates to:
  /// **'CLAIM  {label}'**
  String lsClaimReward(String label);

  /// No description provided for @lsFullCycle.
  ///
  /// In en, this message translates to:
  /// **'FULL 30-DAY CYCLE'**
  String get lsFullCycle;

  /// No description provided for @lsDay.
  ///
  /// In en, this message translates to:
  /// **'Day {d}'**
  String lsDay(Object d);

  /// No description provided for @lsToday.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get lsToday;

  /// No description provided for @dashTitle.
  ///
  /// In en, this message translates to:
  /// **'CHARACTER SHEET'**
  String get dashTitle;

  /// No description provided for @dashDailyReady.
  ///
  /// In en, this message translates to:
  /// **'Daily challenge ready to claim!'**
  String get dashDailyReady;

  /// No description provided for @dashAbilityAfford.
  ///
  /// In en, this message translates to:
  /// **'Ability upgrade affordable — visit ABILITIES'**
  String get dashAbilityAfford;

  /// No description provided for @dashPassiveAfford.
  ///
  /// In en, this message translates to:
  /// **'Passive upgrade affordable — visit PASSIVES'**
  String get dashPassiveAfford;

  /// No description provided for @dashEndlessAfford.
  ///
  /// In en, this message translates to:
  /// **'Endless upgrade affordable — visit UPGRADES'**
  String get dashEndlessAfford;

  /// No description provided for @dashNextAction.
  ///
  /// In en, this message translates to:
  /// **'NEXT ACTION'**
  String get dashNextAction;

  /// No description provided for @dashIncomeSummary.
  ///
  /// In en, this message translates to:
  /// **'INCOME SUMMARY'**
  String get dashIncomeSummary;

  /// No description provided for @dashIdleGold.
  ///
  /// In en, this message translates to:
  /// **'Idle gold'**
  String get dashIdleGold;

  /// No description provided for @dashBattleKill.
  ///
  /// In en, this message translates to:
  /// **'Battle/kill'**
  String get dashBattleKill;

  /// No description provided for @dashExpeditions.
  ///
  /// In en, this message translates to:
  /// **'Expeditions'**
  String get dashExpeditions;

  /// No description provided for @dashAchievementsNearby.
  ///
  /// In en, this message translates to:
  /// **'ACHIEVEMENTS NEARBY'**
  String get dashAchievementsNearby;

  /// No description provided for @dashDayLoginReward.
  ///
  /// In en, this message translates to:
  /// **'DAY {day} LOGIN REWARD'**
  String dashDayLoginReward(Object day);

  /// No description provided for @dashExpReady.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} expedition ready to collect!} other{{count} expeditions ready to collect!}}'**
  String dashExpReady(int count);

  /// No description provided for @dashMercsIdle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} merc idle — dispatch on an expedition} other{{count} mercs idle — dispatch on an expedition}}'**
  String dashMercsIdle(int count);

  /// No description provided for @emTitle.
  ///
  /// In en, this message translates to:
  /// **'ELEMENTAL MASTERY'**
  String get emTitle;

  /// No description provided for @emShards.
  ///
  /// In en, this message translates to:
  /// **'{n} Shards'**
  String emShards(Object n);

  /// No description provided for @emUp.
  ///
  /// In en, this message translates to:
  /// **'UP'**
  String get emUp;

  /// No description provided for @spResetsMonthly.
  ///
  /// In en, this message translates to:
  /// **'📅 Resets monthly'**
  String get spResetsMonthly;

  /// No description provided for @spUnlockPremium.
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium Pass — 2× XP + premium track'**
  String get spUnlockPremium;

  /// No description provided for @spFree.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get spFree;

  /// No description provided for @spPremium.
  ///
  /// In en, this message translates to:
  /// **'👑 PREMIUM'**
  String get spPremium;

  /// No description provided for @spTier.
  ///
  /// In en, this message translates to:
  /// **'Tier'**
  String get spTier;

  /// No description provided for @spClaimed.
  ///
  /// In en, this message translates to:
  /// **'Claimed {reward}'**
  String spClaimed(Object reward);

  /// No description provided for @spAllUnlocked.
  ///
  /// In en, this message translates to:
  /// **'All tiers unlocked — nice work!'**
  String get spAllUnlocked;

  /// No description provided for @spXpToTier.
  ///
  /// In en, this message translates to:
  /// **'{xp} / {next} XP to Tier {tier}'**
  String spXpToTier(Object xp, Object next, Object tier);

  /// No description provided for @spClaimedN.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, one{Claimed 1 reward} other{Claimed {n} rewards}}'**
  String spClaimedN(int n);

  /// No description provided for @spNothingToClaim.
  ///
  /// In en, this message translates to:
  /// **'Nothing to claim'**
  String get spNothingToClaim;

  /// No description provided for @euEchoes.
  ///
  /// In en, this message translates to:
  /// **'Echoes'**
  String get euEchoes;

  /// No description provided for @euYourBalance.
  ///
  /// In en, this message translates to:
  /// **'Your balance'**
  String get euYourBalance;

  /// No description provided for @euEchoesCap.
  ///
  /// In en, this message translates to:
  /// **'ECHOES'**
  String get euEchoesCap;

  /// No description provided for @euTutorial.
  ///
  /// In en, this message translates to:
  /// **'Gauntlet runs earn Echoes 🔊 — spend them here on permanent combat upgrades that never reset. These are some of the most powerful bonuses in the game.'**
  String get euTutorial;

  /// No description provided for @euPermanent.
  ///
  /// In en, this message translates to:
  /// **'Upgrades are permanent per character. Bonuses apply in all game modes.'**
  String get euPermanent;

  /// No description provided for @euForLv.
  ///
  /// In en, this message translates to:
  /// **'for Lv {n}'**
  String euForLv(Object n);

  /// No description provided for @euActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get euActive;

  /// No description provided for @lbRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get lbRefresh;

  /// No description provided for @lbNoScores.
  ///
  /// In en, this message translates to:
  /// **'No scores yet — be the first!'**
  String get lbNoScores;

  /// No description provided for @lbPersonalBest.
  ///
  /// In en, this message translates to:
  /// **'Your personal best'**
  String get lbPersonalBest;

  /// No description provided for @lbRank.
  ///
  /// In en, this message translates to:
  /// **'RANK'**
  String get lbRank;

  /// No description provided for @lbYou.
  ///
  /// In en, this message translates to:
  /// **'YOU'**
  String get lbYou;

  /// No description provided for @lbError.
  ///
  /// In en, this message translates to:
  /// **'Could not load leaderboard.'**
  String get lbError;

  /// No description provided for @lbNotRanked.
  ///
  /// In en, this message translates to:
  /// **'Not ranked yet'**
  String get lbNotRanked;

  /// No description provided for @cmTitle.
  ///
  /// In en, this message translates to:
  /// **'CHALLENGE MODIFIERS'**
  String get cmTitle;

  /// No description provided for @cmOptionalHandicaps.
  ///
  /// In en, this message translates to:
  /// **'OPTIONAL HANDICAPS'**
  String get cmOptionalHandicaps;

  /// No description provided for @cmActive.
  ///
  /// In en, this message translates to:
  /// **'Active: '**
  String get cmActive;

  /// No description provided for @cmClear.
  ///
  /// In en, this message translates to:
  /// **'CLEAR'**
  String get cmClear;

  /// No description provided for @cmDesc.
  ///
  /// In en, this message translates to:
  /// **'Enable up to one modifier before entering Campaign or Dungeon. Modifiers make battles harder but increase shard rewards per kill.'**
  String get cmDesc;

  /// No description provided for @cmEssence.
  ///
  /// In en, this message translates to:
  /// **'+{pct}% essence'**
  String cmEssence(Object pct);

  /// No description provided for @cmEnemyHp.
  ///
  /// In en, this message translates to:
  /// **'Enemy HP ×{mult}'**
  String cmEnemyHp(Object mult);

  /// No description provided for @cmEnemyAtk.
  ///
  /// In en, this message translates to:
  /// **'Enemy ATK ×{mult}'**
  String cmEnemyAtk(Object mult);

  /// No description provided for @cmHeroHp.
  ///
  /// In en, this message translates to:
  /// **'Hero HP ×{mult}'**
  String cmHeroHp(Object mult);

  /// No description provided for @wClose.
  ///
  /// In en, this message translates to:
  /// **'CLOSE'**
  String get wClose;

  /// No description provided for @battleLog.
  ///
  /// In en, this message translates to:
  /// **'BATTLE LOG'**
  String get battleLog;

  /// No description provided for @buffDodge.
  ///
  /// In en, this message translates to:
  /// **'DODGE'**
  String get buffDodge;

  /// No description provided for @buffStun.
  ///
  /// In en, this message translates to:
  /// **'STUN'**
  String get buffStun;

  /// No description provided for @dhPowerTip.
  ///
  /// In en, this message translates to:
  /// **'Medieval Power — combined score of all your upgrades,\ngear, passives, prestige, artifacts, and allies.'**
  String get dhPowerTip;

  /// No description provided for @dhHpTip.
  ///
  /// In en, this message translates to:
  /// **'Health Points — reach 0 and you lose the battle.\nRegen: {regen} HP/round'**
  String dhHpTip(Object regen);

  /// No description provided for @dhXpTip.
  ///
  /// In en, this message translates to:
  /// **'Experience — reach {xp} to level up.\nLevel {lv} → {next}'**
  String dhXpTip(Object xp, Object lv, Object next);

  /// No description provided for @dhNice.
  ///
  /// In en, this message translates to:
  /// **'NICE'**
  String get dhNice;

  /// No description provided for @bspAbilities.
  ///
  /// In en, this message translates to:
  /// **'ABILITIES'**
  String get bspAbilities;

  /// No description provided for @bspMercs.
  ///
  /// In en, this message translates to:
  /// **'MERCS'**
  String get bspMercs;

  /// No description provided for @bspEnemyStun.
  ///
  /// In en, this message translates to:
  /// **'Enemy STUN'**
  String get bspEnemyStun;

  /// No description provided for @bspPassive.
  ///
  /// In en, this message translates to:
  /// **'PASSIVE'**
  String get bspPassive;

  /// No description provided for @bspDescAtk.
  ///
  /// In en, this message translates to:
  /// **'Your hero deals +{pct}% damage per hit.'**
  String bspDescAtk(Object pct);

  /// No description provided for @bspDescArmor.
  ///
  /// In en, this message translates to:
  /// **'+{pct}% Armor Class rating — reduces incoming enemy damage.'**
  String bspDescArmor(Object pct);

  /// No description provided for @bspDescDodge.
  ///
  /// In en, this message translates to:
  /// **'Your hero will completely dodge the next enemy attack.'**
  String get bspDescDodge;

  /// No description provided for @bspDescAura.
  ///
  /// In en, this message translates to:
  /// **'Healing aura — restores {hp} HP at the start of each round.'**
  String bspDescAura(Object hp);

  /// No description provided for @bspDescDot.
  ///
  /// In en, this message translates to:
  /// **'Damage over time — the enemy takes {dmg} damage each round.'**
  String bspDescDot(Object dmg);

  /// No description provided for @bspDescStun.
  ///
  /// In en, this message translates to:
  /// **'The enemy is stunned and skips its attack.'**
  String get bspDescStun;

  /// No description provided for @baMercAbility.
  ///
  /// In en, this message translates to:
  /// **'MERC ABILITY'**
  String get baMercAbility;

  /// No description provided for @tsCleared.
  ///
  /// In en, this message translates to:
  /// **'CLEARED'**
  String get tsCleared;

  /// No description provided for @sgFullyUpgraded.
  ///
  /// In en, this message translates to:
  /// **'FULLY UPGRADED'**
  String get sgFullyUpgraded;

  /// No description provided for @sgNeedGold.
  ///
  /// In en, this message translates to:
  /// **'Need {cost} gold to upgrade'**
  String sgNeedGold(Object cost);

  /// No description provided for @fsVictory.
  ///
  /// In en, this message translates to:
  /// **'VICTORY'**
  String get fsVictory;

  /// No description provided for @fsDefeat.
  ///
  /// In en, this message translates to:
  /// **'DEFEAT'**
  String get fsDefeat;

  /// No description provided for @fsVs.
  ///
  /// In en, this message translates to:
  /// **'vs {enemy}  ·  {rounds} rounds'**
  String fsVs(String enemy, Object rounds);

  /// No description provided for @fsAbilitiesUsed.
  ///
  /// In en, this message translates to:
  /// **'ABILITIES USED'**
  String get fsAbilitiesUsed;

  /// No description provided for @wnTitle.
  ///
  /// In en, this message translates to:
  /// **'WHAT\'S NEW'**
  String get wnTitle;

  /// No description provided for @wnLatest.
  ///
  /// In en, this message translates to:
  /// **'LATEST'**
  String get wnLatest;

  /// No description provided for @zcShards.
  ///
  /// In en, this message translates to:
  /// **'Shards'**
  String get zcShards;

  /// No description provided for @idbNoItem.
  ///
  /// In en, this message translates to:
  /// **'No item equipped — direct upgrade!'**
  String get idbNoItem;

  /// No description provided for @absTitle.
  ///
  /// In en, this message translates to:
  /// **'ABILITY SCORES'**
  String get absTitle;

  /// No description provided for @absBanner.
  ///
  /// In en, this message translates to:
  /// **'Ability Scores are permanent upgrades purchased with gold.\nUpgrade any score freely — gold is the only requirement.'**
  String get absBanner;

  /// No description provided for @absMaxed.
  ///
  /// In en, this message translates to:
  /// **'MAXED'**
  String get absMaxed;

  /// No description provided for @absNext.
  ///
  /// In en, this message translates to:
  /// **'Next: {cost} gold'**
  String absNext(Object cost);

  /// No description provided for @absRankOf.
  ///
  /// In en, this message translates to:
  /// **'Rank {rank} / {max}'**
  String absRankOf(Object rank, Object max);

  /// No description provided for @bestUndiscovered.
  ///
  /// In en, this message translates to:
  /// **'Kill this creature to reveal its secrets.'**
  String get bestUndiscovered;

  /// No description provided for @shopAdOffer.
  ///
  /// In en, this message translates to:
  /// **'Earn {n} ZCoins per ad  •  {left}/{max} remaining'**
  String shopAdOffer(Object n, Object left, Object max);

  /// No description provided for @shopLifetimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Eternal Pact'**
  String get shopLifetimeTitle;

  /// No description provided for @shopLifetimeTagline.
  ///
  /// In en, this message translates to:
  /// **'One purchase. All premium perks. Forever.'**
  String get shopLifetimeTagline;

  /// No description provided for @shopLifetimeBadge.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get shopLifetimeBadge;

  /// No description provided for @shopLifetimeOwned.
  ///
  /// In en, this message translates to:
  /// **'✓ UNLOCKED FOREVER'**
  String get shopLifetimeOwned;

  /// No description provided for @shopLifetimeBuy.
  ///
  /// In en, this message translates to:
  /// **'UNLOCK FOREVER  ·  {price}'**
  String shopLifetimeBuy(Object price);

  /// No description provided for @shopLifetimeIncludes.
  ///
  /// In en, this message translates to:
  /// **'EVERYTHING INCLUDED'**
  String get shopLifetimeIncludes;

  /// No description provided for @shopLifetimePerk1.
  ///
  /// In en, this message translates to:
  /// **'All Ascendant\'s Crown perks'**
  String get shopLifetimePerk1;

  /// No description provided for @shopLifetimePerk2.
  ///
  /// In en, this message translates to:
  /// **'5× battle speed'**
  String get shopLifetimePerk2;

  /// No description provided for @shopLifetimePerk3.
  ///
  /// In en, this message translates to:
  /// **'+100% resource generation'**
  String get shopLifetimePerk3;

  /// No description provided for @shopLifetimePerk4.
  ///
  /// In en, this message translates to:
  /// **'2× Season Pass XP'**
  String get shopLifetimePerk4;

  /// No description provided for @shopLifetimePerk5.
  ///
  /// In en, this message translates to:
  /// **'Premium Season Pass rewards'**
  String get shopLifetimePerk5;

  /// No description provided for @shopLifetimePerk6.
  ///
  /// In en, this message translates to:
  /// **'Battle Sim access'**
  String get shopLifetimePerk6;

  /// No description provided for @shopLifetimePerk7.
  ///
  /// In en, this message translates to:
  /// **'No recurring charges — ever'**
  String get shopLifetimePerk7;

  /// No description provided for @shopLifetimePerk8.
  ///
  /// In en, this message translates to:
  /// **'Auto-Campaign (free from stage 5)'**
  String get shopLifetimePerk8;

  /// No description provided for @ratingTitle.
  ///
  /// In en, this message translates to:
  /// **'Enjoying Zeta Idle?'**
  String get ratingTitle;

  /// No description provided for @ratingBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ve been adventuring for a while! If you\'re having fun, a quick rating really helps the game grow. 🙏'**
  String get ratingBody;

  /// No description provided for @ratingLove.
  ///
  /// In en, this message translates to:
  /// **'Loving it!'**
  String get ratingLove;

  /// No description provided for @ratingMeh.
  ///
  /// In en, this message translates to:
  /// **'Not really'**
  String get ratingMeh;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'en',
        'es',
        'fr',
        'pl',
        'pt'
      ].contains(locale.languageCode);

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
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
