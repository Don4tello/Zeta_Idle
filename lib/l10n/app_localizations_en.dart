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
  String get navHero => 'HERO';

  @override
  String get navPlay => 'PLAY';

  @override
  String get navInventory => 'INVENTORY';

  @override
  String get navShop => 'SHOP';

  @override
  String get navGuild => 'GUILD';

  @override
  String get modeCampaign => 'CAMPAIGN';

  @override
  String get modeDungeon => 'DUNGEON';

  @override
  String get modeBossRush => 'BOSS RUSH';

  @override
  String get modeTowerAscension => 'TOWER ASCENSION';

  @override
  String get modeGauntlet => 'GAUNTLET';

  @override
  String get modePvp => 'PVP';

  @override
  String get modeChallenges => 'CHALLENGES';

  @override
  String get modeEvents => 'EVENTS';

  @override
  String get modeExpedition => 'EXPEDITION';

  @override
  String get modeDaily => 'DAILY';

  @override
  String get modeBounties => 'BOUNTIES';

  @override
  String get modeQuests => 'QUESTS';

  @override
  String get badgeNew => 'NEW';

  @override
  String get lootLog => 'LOOT LOG';

  @override
  String get noLootYet => 'No loot yet — go fight something!';

  @override
  String get welcomeBack => 'Welcome back!';

  @override
  String awayFor(String time) {
    return 'You were away for $time.';
  }

  @override
  String awayForCapped(int hours) {
    return 'You were away for more than ${hours}h — showing the maximum idle rewards.';
  }

  @override
  String rewardGold(String amount) {
    return '+$amount gold';
  }

  @override
  String rewardXp(String amount) {
    return '+$amount XP';
  }

  @override
  String rewardShards(String amount) {
    return '+$amount shards';
  }

  @override
  String expeditionsReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expeditions ready!',
      one: '$count expedition ready!',
    );
    return '$_temp0';
  }

  @override
  String get comebackBonus => 'Comeback bonus:';

  @override
  String get idleIncomeCollected => 'Idle income collected while you rested.';

  @override
  String get claim => 'CLAIM';

  @override
  String get milestone => 'MILESTONE';

  @override
  String get welcomeBackCaps => 'WELCOME BACK!';

  @override
  String get missedYou => 'We missed you! Here\'s a bonus\nfor your time away:';

  @override
  String get newSystemUnlocked => 'NEW SYSTEM UNLOCKED';

  @override
  String get gotIt => 'GOT IT';

  @override
  String get welcomeFightTitle => 'Fight!';

  @override
  String get welcomeFightBody =>
      'Go to the PLAY tab and tap a stage card in CAMPAIGN to start your first battle. Keep attacking until the enemy falls!';

  @override
  String get welcomeIdleTitle => 'Earn idle gold';

  @override
  String get welcomeIdleBody =>
      'Your hero earns gold automatically every minute, even when you\'re not fighting. Watch the gold bar on the HERO tab fill up.';

  @override
  String get welcomeStrongerTitle => 'Get stronger';

  @override
  String get welcomeStrongerBody =>
      'Spend gold in UPGRADES to raise your stats. Open PASSIVES for permanent bonuses, and ABILITIES for powerful combat skills.';

  @override
  String get welcomeExploreTitle => 'Explore';

  @override
  String get welcomeExploreBody =>
      'CAMPAIGN advances through 100 hand-crafted stages. TOWER ASCENSION lets you grind shards forever. The DUNGEON is a roguelite run with item drops and boss fights. More modes unlock as you progress.';

  @override
  String get navBack => 'BACK';

  @override
  String get navNext => 'NEXT';

  @override
  String get startPlaying => 'START PLAYING';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System default';
}
