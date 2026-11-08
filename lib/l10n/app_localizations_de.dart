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
  String get navHero => 'HELD';

  @override
  String get navPlay => 'SPIELEN';

  @override
  String get navInventory => 'INVENTAR';

  @override
  String get navShop => 'SHOP';

  @override
  String get navGuild => 'GILDE';

  @override
  String get modeCampaign => 'KAMPAGNE';

  @override
  String get modeDungeon => 'VERLIES';

  @override
  String get modeBossRush => 'BOSS-RUSH';

  @override
  String get modeTowerAscension => 'TURMAUFSTIEG';

  @override
  String get modeGauntlet => 'GAUNTLET';

  @override
  String get modePvp => 'PVP';

  @override
  String get modeChallenges => 'PRÜFUNGEN';

  @override
  String get modeEvents => 'EVENTS';

  @override
  String get modeExpedition => 'EXPEDITION';

  @override
  String get modeDaily => 'TÄGLICH';

  @override
  String get modeBounties => 'KOPFGELD';

  @override
  String get modeQuests => 'QUESTS';

  @override
  String get badgeNew => 'NEU';

  @override
  String get lootLog => 'BEUTE-LOG';

  @override
  String get noLootYet => 'Noch keine Beute — kämpfe gegen etwas!';

  @override
  String get welcomeBack => 'Willkommen zurück!';

  @override
  String awayFor(String time) {
    return 'Du warst $time weg.';
  }

  @override
  String awayForCapped(int hours) {
    return 'Du warst mehr als $hours Std. weg — es werden die maximalen Idle-Belohnungen angezeigt.';
  }

  @override
  String rewardGold(String amount) {
    return '+$amount Gold';
  }

  @override
  String rewardXp(String amount) {
    return '+$amount EP';
  }

  @override
  String rewardShards(String amount) {
    return '+$amount Splitter';
  }

  @override
  String expeditionsReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Expeditionen bereit!',
      one: '$count Expedition bereit!',
    );
    return '$_temp0';
  }

  @override
  String get comebackBonus => 'Rückkehr-Bonus:';

  @override
  String get idleIncomeCollected =>
      'Idle-Einkommen gesammelt, während du geruht hast.';

  @override
  String get claim => 'EINSAMMELN';

  @override
  String get milestone => 'MEILENSTEIN';

  @override
  String get welcomeBackCaps => 'WILLKOMMEN ZURÜCK!';

  @override
  String get missedYou =>
      'Wir haben dich vermisst! Hier ist ein Bonus\nfür deine Zeit weg:';

  @override
  String get newSystemUnlocked => 'NEUES SYSTEM FREIGESCHALTET';

  @override
  String get gotIt => 'VERSTANDEN';

  @override
  String get welcomeFightTitle => 'Kämpfe!';

  @override
  String get welcomeFightBody =>
      'Geh zum Tab SPIELEN und tippe in der KAMPAGNE auf eine Stufenkarte, um deinen ersten Kampf zu starten. Greif weiter an, bis der Gegner fällt!';

  @override
  String get welcomeIdleTitle => 'Verdiene Idle-Gold';

  @override
  String get welcomeIdleBody =>
      'Dein Held verdient jede Minute automatisch Gold, auch wenn du nicht kämpfst. Sieh zu, wie sich die Gold-Leiste im HELD-Tab füllt.';

  @override
  String get welcomeStrongerTitle => 'Werde stärker';

  @override
  String get welcomeStrongerBody =>
      'Gib Gold in VERBESSERUNGEN aus, um deine Werte zu steigern. Öffne PASSIVE für dauerhafte Boni und FÄHIGKEITEN für mächtige Kampf-Skills.';

  @override
  String get welcomeExploreTitle => 'Erkunde';

  @override
  String get welcomeExploreBody =>
      'Die KAMPAGNE führt durch 100 handgefertigte Stufen. Im TURMAUFSTIEG farmst du endlos Splitter. Das VERLIES ist ein Roguelite-Durchgang mit Beute und Bosskämpfen. Weitere Modi schaltest du mit der Zeit frei.';

  @override
  String get navBack => 'ZURÜCK';

  @override
  String get navNext => 'WEITER';

  @override
  String get startPlaying => 'LOSSPIELEN';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsLanguageSystem => 'Systemstandard';
}
