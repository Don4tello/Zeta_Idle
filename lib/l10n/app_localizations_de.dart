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

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonContinue => 'WEITER';

  @override
  String heroFalls(String name) {
    return '$name FÄLLT';
  }

  @override
  String get battleGrowStronger =>
      'Werde stärker, bevor du es erneut versuchst.';

  @override
  String get battleBackToHero => 'ZURÜCK ZUM HELDEN';

  @override
  String get defeatEndlessTitle => 'ENDLOS-MODUS';

  @override
  String get defeatEndlessHint => 'Farme EP & Gold in deinem Tempo';

  @override
  String get defeatDungeonHint => 'Verdiene Splitter & Gegenstände';

  @override
  String get defeatGauntletHint => 'Verdiene Echos für Verbesserungen';

  @override
  String get defeatDailyTitle => 'TÄGLICHE PRÜFUNGEN';

  @override
  String get defeatDailyHint => 'Erhalte Belohnungen für Fortschritt';

  @override
  String battleTierUnlocked(int tier) {
    return 'STUFE $tier FREIGESCHALTET';
  }

  @override
  String get battleCampaignCleared => 'KAMPAGNE ABGESCHLOSSEN';

  @override
  String battleTierUnlockedBody(int tier) {
    return 'Der Omega ist gefallen. Die Kampagne beginnt bei Stufe $tier neu — stärkere Gegner und bessere Beute.\n\nDein Level, Paragon, deine Ausrüstung und Währungen bleiben alle erhalten. Nichts wird zurückgesetzt.';
  }

  @override
  String get battleCampaignClearedBody =>
      'Der Omega ist auf der höchsten Stufe gefallen. Du hast den Gipfel erreicht — farme weiter für Beute und Paragon-Punkte.';

  @override
  String get battleSwitchTiersHint =>
      'Wechsle Stufen jederzeit über die Kampagnen-Kopfzeile.';

  @override
  String get battleRetreat => 'Rückzug';

  @override
  String get battleLastFightSummary => 'Letzte Kampfübersicht';

  @override
  String get battleResume => 'Fortsetzen';

  @override
  String get battlePause => 'Pause';

  @override
  String get battleAutoCampaignLocked =>
      'Auto-Kampagne — Tempo-Boost / Premium-Pass';

  @override
  String get battleAutoCampaignOn => 'Auto-Kampagne: AN';

  @override
  String get battleAutoCampaignOff => 'Auto-Kampagne: AUS';

  @override
  String get battleNoFightYet => 'Noch kein Kampf beendet.';

  @override
  String get battleAutoCampaignPerk =>
      'Auto-Kampagne ist ein Vorteil des Tempo-Boosts / Premium-Passes.';

  @override
  String get battleNoActiveBattle => 'KEIN AKTIVER KAMPF';

  @override
  String get battleVictory => 'SIEG!';

  @override
  String get battleBossDefeated => 'BOSS BESIEGT';

  @override
  String get battleNewContentUnlocked => 'NEUER INHALT FREIGESCHALTET';

  @override
  String get battleClassQuestlineUnlocked =>
      'KLASSEN-QUESTREIHE FREIGESCHALTET';

  @override
  String battleClassQuestlineBody(String className) {
    return 'Der Pfad des $className beginnt. Schließe 5 Quests ab, um deine Ultimative Fähigkeit freizuschalten.';
  }

  @override
  String battleRewardGold(String amount) {
    return '+$amount GOLD';
  }

  @override
  String battleRewardXp(String amount) {
    return '+$amount EP';
  }

  @override
  String battleRewardShards(String amount) {
    return '+$amount SPLITTER';
  }

  @override
  String battleAbilityUnlocked(String name) {
    return 'FÄHIGKEIT FREIGESCHALTET: $name';
  }

  @override
  String get battleAddedToBag => 'Zum Beutel hinzugefügt';

  @override
  String get battleFight => 'KÄMPFEN  (−1 ⚡)';

  @override
  String get battleSpeedBoostTitle => '2× Tempo-Boost';

  @override
  String battleSpeedBoostBody(int cost, int have) {
    return '2× Kampftempo für 7 Tage freischalten?\n\nKosten: $cost Z-Coins\nDeine Z-Coins: $have';
  }

  @override
  String get battlePurchase => 'Kaufen';

  @override
  String get battleNotEnoughZcoins => 'Nicht genug Z-Coins!';

  @override
  String get battleArtifactFound => 'ARTEFAKT GEFUNDEN!';

  @override
  String battleRoundsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Runden verbleibend',
      one: '$count Runde verbleibend',
    );
    return '$_temp0';
  }

  @override
  String get commonOk => 'OK';

  @override
  String get campaignDifficultyTier => 'SCHWIERIGKEITSSTUFE';

  @override
  String get campaignDifficultyTierTooltip => 'Schwierigkeitsstufe';

  @override
  String get campaignTierSelectorBody =>
      'Höhere Stufen = stärkere Gegner UND bessere Beute (Seltenheit, Sets, Artefakte). Herunterstufen behält deine gesamte dauerhafte Stärke — es skaliert nur, wogegen du kämpfst und was fällt.';

  @override
  String get campaignTierNormal => 'STUFE 0 — Normal';

  @override
  String campaignTierN(int tier) {
    return 'STUFE $tier';
  }

  @override
  String get campaignTierBaseDesc =>
      'Basis-Gegner · Basis-Beute · keine Magieausbeute';

  @override
  String campaignTierScaledDesc(int hp, int atk) {
    return 'Gegner +$hp% HP · +$atk% ATK';
  }

  @override
  String campaignTierMagicFind(int mf) {
    return '✦ +$mf% Magieausbeute (höhere Seltenheit, Sets & Artefakte)';
  }

  @override
  String get campaignLeaderboardTooltip => 'Kampagnen-Bestenliste';

  @override
  String get campaignTutorial =>
      'Die Kampagne schreitet Stufe für Stufe voran. Besiege jeden Boss, um die nächste freizuschalten. Besiege den letzten Boss, um die nächste Schwierigkeitsstufe freizuschalten — die Kampagne beginnt schwerer neu mit besserer Beute, und deine Stärke bleibt erhalten.';

  @override
  String campaignEnergyRecharge(String time) {
    return '+1 in $time';
  }

  @override
  String campaignEnergyRefill(int amount, int left) {
    return 'Auffüllen +$amount  ($left gratis übrig)';
  }

  @override
  String get campaignBuy => 'Kaufen ';

  @override
  String get campaignEnergyEmptyTutorial =>
      'Keine Energie! ⚡ Sie füllt sich alle 5 Min. um 1 auf. Tippe oben auf die +10-Schaltfläche für 3 gratis tägliche Auffüllungen. Oder kaufe +20 Energie für 💎 50 Z-Coins.';

  @override
  String get campaignStageMap =>
      'STUFENKARTE  •  tippe auf einen ✓-Knoten zum Wiederholen';

  @override
  String get campaignNoEnergyRefill =>
      'Keine Energie! Warte, bis sie sich auffüllt.';

  @override
  String campaignSimulateStage(int stage) {
    return '⚡ Stufe $stage simulieren';
  }

  @override
  String campaignEnergyAvailable(int count) {
    return 'Verfügbare Energie: $count';
  }

  @override
  String get campaignSimInfo =>
      'Kämpfe laufen sofort ab. Beute geht direkt in deinen Beutel.';

  @override
  String campaignSimAll(int count) {
    return 'ALLE ($count)';
  }

  @override
  String campaignSimResultTitle(int stage, int count) {
    return 'Stufe $stage — $count× simuliert';
  }

  @override
  String get campaignSimGold => '💰 Gold';

  @override
  String get campaignSimXp => '✦ EP';

  @override
  String campaignItemsDropped(int count) {
    return 'Erhaltene Gegenstände ($count):';
  }

  @override
  String get campaignNoItemsDropped =>
      'Bei diesem Durchgang keine Gegenstände erhalten.';

  @override
  String get campaignNotEnoughEnergy => 'Nicht genug Energie!';

  @override
  String get campaignMapFight => '⚔  KÄMPFEN (−1 ⚡)';

  @override
  String get campaignSimRequiresPremium => 'Erfordert Premium-Pass-Abo';

  @override
  String get campaignBossEncounter => 'BOSS-BEGEGNUNG';

  @override
  String get campaignDismiss => '[ schließen ]';

  @override
  String campaignPerfectStages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count perfekte Stufen',
      one: '$count perfekte Stufe',
    );
    return '$_temp0';
  }

  @override
  String campaignNextMilestone(int next) {
    return '• nächster Meilenstein bei $next (+Mithril +Z-Coins)';
  }

  @override
  String get campaignAllMilestones => '• alle Meilensteine abgeschlossen!';

  @override
  String get hubWhatsNew => 'Neuigkeiten';

  @override
  String get hubLootLog => 'Beute-Log';

  @override
  String get hubSettings => 'Einstellungen';

  @override
  String get hubChange => 'WECHSELN';

  @override
  String get hubHeroMenu => 'Helden-Menü';

  @override
  String get hubJoinDiscord => 'Tritt unserem Discord bei';

  @override
  String get hubVisitReddit => 'Besuche r/zeta_idle';

  @override
  String hubCouldNotOpen(String url) {
    return 'Konnte $url nicht öffnen';
  }

  @override
  String get hubLocked => 'Gesperrt';

  @override
  String get hubGroupCharacter => 'CHARAKTER';

  @override
  String get hubGroupProgression => 'FORTSCHRITT';

  @override
  String get hubGroupCollection => 'SAMMLUNG';

  @override
  String get hubGroupRecords => 'REKORDE';

  @override
  String get hubBlurbCharacter => 'Dein Build & deine Stärke';

  @override
  String get hubBlurbProgression => 'Endgame-Systeme';

  @override
  String get hubBlurbCollection => 'Verbündete & Kompendium';

  @override
  String get hubBlurbRecords => 'Ziele & Aufschlüsselungen';

  @override
  String get hubSheet => 'ÜBERSICHT';

  @override
  String get hubScores => 'WERTE';

  @override
  String get hubAbilities => 'FÄHIGKEITEN';

  @override
  String get hubPassives => 'PASSIVE';

  @override
  String get hubSpecialize => 'SPEZIALISIEREN';

  @override
  String get hubParagon => 'PARAGON';

  @override
  String get hubUpgrades => 'VERBESSERUNGEN';

  @override
  String get hubAscend => 'AUFSTIEG';

  @override
  String get hubMastery => 'MEISTERSCHAFT';

  @override
  String get hubPets => 'GEFÄHRTEN';

  @override
  String get hubMercs => 'SÖLDNER';

  @override
  String get hubBestiary => 'BESTIARIUM';

  @override
  String get hubCodex => 'KODEX';

  @override
  String get hubArmory => 'WAFFENKAMMER';

  @override
  String get hubAchievements => 'ERFOLGE';

  @override
  String get hubBonuses => 'BONI';

  @override
  String get auShards => 'Splitter';

  @override
  String get auRespecTitle => 'Fähigkeiten neu verteilen?';

  @override
  String auRespecBody(int cost) {
    return 'Setze alle Fähigkeitsränge und Meilenstein-Entscheidungen zurück.\nAlle ausgegebenen Splitter werden erstattet.\n\nKosten: $cost Z-Coins';
  }

  @override
  String auRespecConfirm(int cost) {
    return 'NEU VERTEILEN ($cost ZC)';
  }

  @override
  String get auRespec => 'NEU VERTEILEN';

  @override
  String get auTutorial =>
      'Du hast Splitter ◆ verdient — gib sie hier aus, um Klassenfähigkeiten freizuschalten und zu verbessern, die in jedem Kampf automatisch ausgelöst werden.';

  @override
  String get auIntro =>
      'Gib Splitter aus, um deine Fähigkeiten zu stärken. Meilensteine bei Rang 5, 10 und 15. Steige nach Rang 15 eine Stufe auf — jede Stufe wird mit deiner Schwierigkeitsstufe freigeschaltet.';

  @override
  String get auTitle => 'FÄHIGKEITEN-VERBESSERUNGEN';

  @override
  String get auMaxTier => 'MAX. STUFE  ✦';

  @override
  String auTierLockedLabel(int tier, int req) {
    return 'STUFE $tier  —  Erfordert Schwierigkeitsstufe $req';
  }

  @override
  String get auAscension => 'AUFSTIEG';

  @override
  String auTierUnlocked(int cap) {
    return 'Stufe $cap freigeschaltet';
  }

  @override
  String auAscFullyAscended(int pct) {
    return 'Voll aufgestiegen  ·  +$pct% Fähigkeitsstärke';
  }

  @override
  String auAscTierLocked(int cur, int next) {
    return '+$cur% Stärke  ·  Schalte Schwierigkeitsstufe $next (Wiedergeburt) frei, um weiter aufzusteigen';
  }

  @override
  String auAscUpgrade(int cur, int next, int cost) {
    return '+$cur%  →  +$next% Stärke  ·  kostet $cost ✦ Paragon';
  }

  @override
  String auAscYouHave(int have) {
    return '  (du hast $have)';
  }

  @override
  String get auMax => 'MAX';

  @override
  String get auLocked => 'GESPERRT';

  @override
  String auAscendBtn(int cost) {
    return 'AUFSTEIGEN  $cost ✦';
  }

  @override
  String get auUltimate => 'ULTIMATIV';

  @override
  String auUnlocksLv(int lv) {
    return 'FREI AB LV $lv';
  }

  @override
  String get auFinishQuestline =>
      '🔒 Schließe deine Klassen-Questreihe ab, um freizuschalten';

  @override
  String auReachLevel(int lv, int cur) {
    return 'Erreiche Level $lv  (du: Lv $cur)';
  }

  @override
  String auCompleteQuests(String className, int claimed) {
    return 'Schließe alle 5 $className-Klassenquests ab  ($claimed / 5)';
  }

  @override
  String get auTrackQuests => 'Verfolge deine Quests im Quests-Tab.';

  @override
  String get auChoose => 'WÄHLEN';

  @override
  String get setTitle => 'EINSTELLUNGEN';

  @override
  String get setSave => 'SPEICHERN';

  @override
  String get setLoad => 'LADEN';

  @override
  String get setReset => 'ZURÜCKSETZEN';

  @override
  String get setOpen => 'ÖFFNEN';

  @override
  String get setView => 'ANZEIGEN';

  @override
  String get setEmail => 'E-MAIL';

  @override
  String get setConfirm => 'BESTÄTIGEN';

  @override
  String get setSecAccount => 'KONTO';

  @override
  String get setSecPromo => 'PROMO-CODE';

  @override
  String get setSecAudio => 'AUDIO';

  @override
  String get setSecHaptics => 'HAPTIK';

  @override
  String get setSecNotifications => 'BENACHRICHTIGUNGEN';

  @override
  String get setSecDisplay => 'ANZEIGE';

  @override
  String get setSecStats => 'WERTE';

  @override
  String get setSecAutoLoot => 'AUTO-BEUTE';

  @override
  String get setSecBattle => 'KAMPF';

  @override
  String get setSecDailyReset => 'TÄGLICHER RESET';

  @override
  String get setSecSave => 'SPEICHERN';

  @override
  String get setSecDanger => 'GEFAHRENZONE';

  @override
  String get setSecHelp => 'HILFE';

  @override
  String get setSecAbout => 'ÜBER';

  @override
  String get setManage => 'VERWALTEN';

  @override
  String get setSignIn => 'ANMELDEN';

  @override
  String get setHeroName => 'Heldenname';

  @override
  String setRename(int cost) {
    return 'UMBENENNEN ($cost 🪙)';
  }

  @override
  String get setPromoHint =>
      'Hast du einen Code? Löse ihn hier für Belohnungen ein.';

  @override
  String get setRedeem => 'EINLÖSEN';

  @override
  String get setSoundEffects => 'Soundeffekte';

  @override
  String get setBackgroundMusic => 'Hintergrundmusik';

  @override
  String get setVolume => 'Lautstärke';

  @override
  String get setVibration => 'Vibration';

  @override
  String get setReminders => 'Erinnerungen';

  @override
  String get setDamageNumbers => 'Schadenszahlen';

  @override
  String get setReducedParticles => 'Reduzierte Partikel';

  @override
  String get setTotalPlaytime => 'Gesamtspielzeit';

  @override
  String get setAutoSalvage => 'Auto-Verwertung';

  @override
  String get setAutoEquip => 'Auto-Ausrüsten';

  @override
  String get setAutoEquipSub =>
      'Rüste automatisch bessere Gegenstände als die aktuelle Ausrüstung aus';

  @override
  String get setBattleSpeed => 'Kampftempo';

  @override
  String get setAutoCampaign => 'Auto-Kampagne';

  @override
  String get setResetTime => 'Reset-Zeit';

  @override
  String get setCloudSave => 'Cloud-Speicher';

  @override
  String get setCloudSaveSub =>
      'Synchronisiere deinen Fortschritt in die Cloud';

  @override
  String get setCloudSaveComplete => 'Cloud-Speicherung abgeschlossen.';

  @override
  String get setLoadCloud => 'Aus Cloud laden';

  @override
  String get setLoadCloudSub =>
      'Lokalen Speicher mit Cloud-Daten überschreiben';

  @override
  String get setResetProgress => 'Fortschritt zurücksetzen';

  @override
  String get setResetProgressSub =>
      'Lösche alle Speicherdaten für diesen Platz. Unwiderruflich.';

  @override
  String get setKnowledgeBase => 'Wissensdatenbank';

  @override
  String get setKnowledgeBaseSub =>
      'Schlüsselwörter, Systeme, Währungen erklärt';

  @override
  String get setTagline => 'Ein düsteres mittelalterliches Idle-RPG.';

  @override
  String get setAboutHero => 'Held';

  @override
  String get setAboutClass => 'Klasse';

  @override
  String get setAboutLevel => 'Level';

  @override
  String get setAboutPrestige => 'Prestige';

  @override
  String get setAboutAchievements => 'Erfolge';

  @override
  String get setAboutDeveloper => 'Entwickler';

  @override
  String get setAboutContact => 'Kontakt';

  @override
  String get setPrivacy => 'Datenschutzrichtlinie';

  @override
  String get setPrivacySub => 'Wie wir mit deinen Daten umgehen';

  @override
  String get setReportBug => 'Fehler melden / Feedback';

  @override
  String get setReportBugSub =>
      'Schreib uns — Geräteinfos werden automatisch hinzugefügt';

  @override
  String get setReplayTips => 'Tipps erneut zeigen';

  @override
  String get setReplayTipsSub => 'Zeige die In-Game-Tutorial-Tipps erneut';

  @override
  String get setTipsReset =>
      'Tutorial-Tipps zurückgesetzt — sie erscheinen wieder, während du erkundest.';

  @override
  String get setRenameHeroTitle => 'HELD UMBENENNEN';

  @override
  String get setHeroNameHint => 'Gib einen Heldennamen ein';

  @override
  String setRenameCost(int cost, int have) {
    return 'Kosten: $cost 🪙   (du hast $have)';
  }

  @override
  String setRenameNotEnough(int cost) {
    return 'Nicht genug Z-Coins — Umbenennen kostet $cost 🪙.';
  }

  @override
  String get setNoEmailApp =>
      'Keine E-Mail-App gefunden. Erreiche uns unter razorintegrations@gmail.com';

  @override
  String get setDailyResetTitle => 'Tägliche Reset-Zeit';

  @override
  String get setDailyResetHint =>
      'Wähle die Stunde, zu der die täglichen Limits zurückgesetzt werden.';

  @override
  String get setDailyResetWarning =>
      'Achtung: Du kannst dies nur einmal pro Jahr ändern.';

  @override
  String get setLoadCloudTitle => 'Aus Cloud laden?';

  @override
  String get setLoadCloudBody =>
      'Dies überschreibt deinen lokalen Speicher mit Cloud-Daten. Noch nicht synchronisierter lokaler Fortschritt geht verloren.';

  @override
  String get setResetAllTitle => 'Allen Fortschritt zurücksetzen?';

  @override
  String get setResetAllBody =>
      'Aller Fortschritt, Gold, Gegenstände, Prestige-Level und Erfolge werden dauerhaft gelöscht. Dies kann nicht rückgängig gemacht werden.';

  @override
  String get setNewHeroName => 'Neuer Heldenname:';

  @override
  String get setGoogleAccount => 'Google-Konto';

  @override
  String get setSignInGoogle => 'Mit Google anmelden';

  @override
  String get setSignedIn => 'Angemeldet';

  @override
  String get setSyncSaves => 'Speicher geräteübergreifend synchronisieren';

  @override
  String get setEnterCode => 'CODE EINGEBEN';

  @override
  String get setOff => 'Aus';

  @override
  String get setOffCaps => 'AUS';

  @override
  String get setHidden => 'Ausgeblendet';

  @override
  String get setVibrationOn =>
      'Vibriert bei Krits, Levelaufstiegen, Siegen & Belohnungen';

  @override
  String get setRemindersOn =>
      'Erhalte „Komm zurück“-Erinnerungen, während du weg bist';

  @override
  String get setDamageOn => 'Schwebende Zahlen im Kampf anzeigen';

  @override
  String get setParticlesOn => 'Weniger Hintergrundeffekte (bessere Leistung)';

  @override
  String get setParticlesOff => 'Volle Effekte';

  @override
  String get setSalvageOff =>
      'Tippe, um Auto-Verwertung für Beute zu aktivieren';

  @override
  String setSalvageOn(String tier) {
    return 'Verwertet automatisch $tier und niedriger';
  }

  @override
  String get setAutoCampaignOnSub =>
      'Kämpfe automatisch Kampagnenkämpfe im Hintergrund';

  @override
  String get setAutoCampaignLockedSub =>
      '🔒 Nur für Tempo-Boost- / Premium-Pass-Abonnenten';

  @override
  String setResetTimeOn(String time) {
    return 'Tägliche Limits werden um $time zurückgesetzt. Tippe zum Ändern (einmal pro Jahr).';
  }

  @override
  String setResetTimeLocked(String time) {
    return 'Wird um $time zurückgesetzt · Dieses Jahr bereits geändert.';
  }

  @override
  String get guildTitle => 'GILDE';

  @override
  String get guildJoinTitle => 'GILDE BEITRETEN';

  @override
  String get guildJoinBlurb =>
      'Gilden bieten passive Boni, eine wöchentliche Boss-Herausforderung und einen Gildenshop mit exklusiven Belohnungen.';

  @override
  String get guildCreate => 'GILDE GRÜNDEN';

  @override
  String get guildPublic => 'ÖFFENTLICHE GILDEN';

  @override
  String get guildNoGuilds =>
      'Keine Gilden gefunden. Sei der/die Erste, der/die eine gründet!';

  @override
  String get guildCreateTitle => 'Gilde gründen';

  @override
  String get guildNameLabel => 'Gildenname';

  @override
  String get guildDescLabel => 'Beschreibung (optional)';

  @override
  String get guildCreateBtn => 'GRÜNDEN';

  @override
  String get guildTabInfo => 'INFO';

  @override
  String get guildTabCastle => 'SCHLOSS';

  @override
  String get guildTabBoss => 'BOSS';

  @override
  String get guildTabWar => 'KRIEG';

  @override
  String get guildTabChat => 'CHAT';

  @override
  String get guildTabShop => 'SHOP';

  @override
  String guildCastleTier(int tier) {
    return 'SCHLOSS — STUFE $tier / 10';
  }

  @override
  String guildProgressTier(int tier) {
    return 'Fortschritt zu Stufe $tier';
  }

  @override
  String guildCpProgress(int cp, int cap) {
    return '$cp / $cap BP';
  }

  @override
  String guildNext(String headline) {
    return 'Nächste: $headline';
  }

  @override
  String get guildCitadelComplete =>
      'Zitadelle fertig — das Schloss ist vollständig gebaut!';

  @override
  String get guildContributeGold => 'GOLD BEITRAGEN';

  @override
  String guildContributeInfo(String rate, int cap) {
    return 'Wandle Gold in Baupunkte (BP) um. Rate: $rate Gold = 1 BP. Du kannst bis zu $cap BP pro Tag hinzufügen.';
  }

  @override
  String get guildActiveBenefits => 'AKTIVE SCHLOSS-VORTEILE';

  @override
  String get guildContributeHint =>
      'Trage bei, um das Schloss zu erhöhen und Vorteile freizuschalten.';

  @override
  String guildCastleAdvanced(int tier) {
    return '🏰 Schloss auf Stufe $tier aufgestiegen!';
  }

  @override
  String get guildCapReached =>
      'Tägliches Baulimit erreicht — komm morgen wieder!';

  @override
  String guildLevelMembers(int lvl, int m, int max) {
    return 'Level $lvl  •  $m/$max Mitglieder';
  }

  @override
  String guildBonusGold(int pct) {
    return '+$pct% Gold';
  }

  @override
  String guildBonusXp(int pct) {
    return '+$pct% EP';
  }

  @override
  String guildBonusIdle(int pct) {
    return '+$pct% Idle';
  }

  @override
  String guildXpProgress(int xp, int max) {
    return '$xp/$max EP';
  }

  @override
  String get guildDonate1000 => '1000 GOLD SPENDEN';

  @override
  String get guildDonateReward => '→ Gilden-EP + 🪙';

  @override
  String get guildPerks => 'VORTEILE';

  @override
  String guildLockedPerk(int lvl, String name, String desc) {
    return '🔒 Lv$lvl: $name — $desc';
  }

  @override
  String get guildMembers => 'MITGLIEDER';

  @override
  String guildMemberLine(int lvl, String cls, String role, int d) {
    return 'Lv$lvl $cls  •  $role  •  gespendet: ${d}g';
  }

  @override
  String get guildLeave => 'GILDE VERLASSEN';

  @override
  String get guildNoBoss => 'Diese Woche kein Boss.';

  @override
  String get guildWeeklyBoss => '☠ WÖCHENTLICHER GILDENBOSS';

  @override
  String guildBossHp(int hp, int max) {
    return '$hp / $max HP';
  }

  @override
  String get guildDefeated => '✓ BESIEGT';

  @override
  String guildBossRewardMsg(Object rank, Object gc, Object gold) {
    return '🏆 Boss letzter Woche: Rang #$rank — +$gc Gildenmünzen, +$gold Gold';
  }

  @override
  String get guildClaimBossReward => '🏆 BOSS-BELOHNUNG DER VORWOCHE EINLÖSEN';

  @override
  String guildAttempts(int rem, int max) {
    return 'Versuche: $rem / $max';
  }

  @override
  String get guildNoAttempts => 'KEINE VERSUCHE ÜBRIG';

  @override
  String get guildChallengeBoss => '⚔ BOSS HERAUSFORDERN';

  @override
  String get guildDamageRanking => 'SCHADENSRANGLISTE';

  @override
  String guildDmg(int dmg) {
    return '$dmg Schaden';
  }

  @override
  String get guildWarStandings => 'KRIEGSWERTUNG';

  @override
  String guildWarRecord(int w, int l) {
    return 'Deine Bilanz: ${w}S–${l}N';
  }

  @override
  String get guildWeeklyWar => 'Wöchentlicher Gildenkrieg';

  @override
  String get guildWarBlurb =>
      'Melde dich während der Vorbereitung (Mo–Di). Mi–Fr gibst du Kriegsangriffe aus, um rivalisierende Champions zu bekämpfen und Punkte für deine Gilde zu verdienen. Sa–So löst du Rangbelohnungen ein.';

  @override
  String get guildEnlistedBattle =>
      '⚔ Eingetragen! Gib jetzt deine Kriegsangriffe aus.';

  @override
  String get guildEnlistedPrep =>
      '⚔ Eingetragen! Komm Mi–Fr zum Kämpfen zurück.';

  @override
  String get guildEnlist => 'GILDE EINTRAGEN';

  @override
  String get guildWarEndedWait => 'KRIEG BEENDET — WARTE AUF NÄCHSTE WOCHE';

  @override
  String guildScoreYou(String name) {
    return '$name (du)';
  }

  @override
  String get guildLeads => '🏆 Deine Gilde führt!';

  @override
  String get guildBehind => '⚠ Deine Gilde liegt zurück — kämpfe!';

  @override
  String guildFightForGuild(int c, int max) {
    return '⚔ KÄMPFE FÜR DIE GILDE  ($c/$max)';
  }

  @override
  String get guildNoWarAttacks => 'HEUTE KEINE KRIEGSANGRIFFE MEHR';

  @override
  String get guildWarRefresh =>
      'Kriegsangriffe werden während der Kampfphase täglich aufgefüllt.';

  @override
  String get guildWarVictory => '🏆 Sieg!';

  @override
  String get guildWarOver => 'Krieg vorbei.';

  @override
  String guildWarRewardMsg(String result, Object gc, Object gold) {
    return '$result +$gc Gildenmünzen, +$gold Gold';
  }

  @override
  String get guildRewardsClaimed => 'BELOHNUNGEN EINGELÖST';

  @override
  String get guildClaimWarRewards => 'KRIEGSBELOHNUNGEN EINLÖSEN';

  @override
  String get guildWarBattleSoon =>
      'Der Kampf beginnt am Mittwoch — komm zum Kämpfen zurück!';

  @override
  String get guildCoinsLabel => 'Gildenmünzen';

  @override
  String guildListLine(int lvl, int m, int max) {
    return 'Lv$lvl  •  $m/$max Mitglieder';
  }

  @override
  String get guildJoin => 'BEITRETEN';

  @override
  String get guildFull => 'VOLL';

  @override
  String get guildBossTitle => 'GILDENBOSS';

  @override
  String get guildBossWin => '✦ BOSS BESIEGT!';

  @override
  String get guildBossLose => '💀 GEFALLEN';

  @override
  String guildTotalDamage(int d) {
    return 'Gesamtschaden verursacht: $d';
  }

  @override
  String get guildReturn => 'ZURÜCK ZUR GILDE';

  @override
  String guildCpAmount(int cp) {
    return '+$cp BP';
  }

  @override
  String guildGoldCost(String gold) {
    return '${gold}g';
  }

  @override
  String get forgeSalvageTooltip =>
      'Zerstöre Gegenstände, um Splitter (◆) zurückzugewinnen.\n• Common → 3 ◆\n• Rare → 8 ◆\n• Epic → 20 ◆\n• Legendary → 60 ◆\n• Set → 100 ◆';

  @override
  String get forgeUpgradeTooltip =>
      'Verbessere einen Gegenstand von +0 auf +10.\nJede Stufe erhöht alle Werte um 8%.\nBei +5 und +10 erhält der Gegenstand ein Titel-Präfix.\nKostet Gold + Splitter pro Stufe.';

  @override
  String get forgeTitle => 'SCHMIEDE';

  @override
  String get forgeSalvage => 'VERWERTEN';

  @override
  String get forgeUpgrade => 'VERBESSERN';

  @override
  String get forgeSlot => 'PLATZ';

  @override
  String get forgeFrom => 'VON  ';

  @override
  String forgeForged(String name, String label) {
    return 'Geschmiedet: $name ($label)!';
  }

  @override
  String get forgeSalvageRates => 'VERWERTUNGSRATEN';

  @override
  String forgeSalvageBtn(int n, int s) {
    return 'VERWERTEN  $n  (+$s ◆)';
  }

  @override
  String get forgeBagEmpty => 'Dein Beutel ist leer.';

  @override
  String forgeBag(int n) {
    return 'BEUTEL  ($n Gegenstände)';
  }

  @override
  String forgeSalvaged(int earned) {
    return 'Verwertet: +$earned ◆';
  }

  @override
  String forgeTimesN(int n) {
    return ' ×$n';
  }

  @override
  String get forgeTimesRandom => '  ×1 (zufällig)';

  @override
  String get forgeMasterForger => 'Meisterschmied';

  @override
  String get forgeSelected => 'AUSGEWÄHLT';

  @override
  String forgeSelectedCount(int selected, int needed) {
    return '$selected / $needed';
  }

  @override
  String get forgeArcaneDust => 'ARKANER STAUB';

  @override
  String get forgeGemType => 'EDELSTEINTYP';

  @override
  String forgeGemWeaponDesc(Object pct, String type) {
    return '⚔ Waffe: +$pct% $type Schaden';
  }

  @override
  String forgeGemArmorDesc(Object pct, String type) {
    return '🛡 Rüstung: +$pct% $type Widerstand';
  }

  @override
  String get forgeTier => 'STUFE';

  @override
  String forgeGemBagFull(int n, int max) {
    return 'EDELSTEINBEUTEL VOLL ($n/$max)';
  }

  @override
  String forgeNeedMore(int n) {
    return 'BRAUCHE $n MEHR 💠';
  }

  @override
  String forgeCraft(int cost) {
    return '✦  HERSTELLEN  $cost 💠';
  }

  @override
  String forgePreviewWeapon(String effect) {
    return '⚔ Waffe: $effect';
  }

  @override
  String forgePreviewArmor(String effect) {
    return '🛡 Rüstung: $effect';
  }

  @override
  String forgeToCraft(int cost) {
    return '$cost 💠 zum Herstellen';
  }

  @override
  String forgeGemBag(int n, int max) {
    return 'EDELSTEINBEUTEL  ($n/$max)';
  }

  @override
  String get forgeTapGem =>
      'Tippe auf einen Edelstein, um ihn in einen Gegenstand einzusetzen';

  @override
  String get forgeNoGems =>
      'Noch keine Edelsteine hergestellt. Stelle oben einen her!';

  @override
  String get forgeHowGems => 'WIE EDELSTEINE FUNKTIONIEREN';

  @override
  String get forgeGemsInfo =>
      '• Jeder Edelstein ist vielseitig — derselbe Edelstein gibt elementaren SCHADEN in einer Waffe oder elementaren WIDERSTAND in Rüstung / Schmuck.\n• Edelstein-Splitter fallen bei Kampf-Kills (25% Chance) und von Bossen.\n• Jeder Gegenstand kann 1 Edelstein in seinem Sockel halten.\n• Setze Edelsteine aus diesem Beutel ein oder über den Inventar-Bildschirm.\n• Das Ersetzen oder Entfernen eines Edelsteins zerstört den alten.';

  @override
  String get forgeNoItemsSocket => 'Keine Gegenstände zum Einsetzen.';

  @override
  String forgeSocketGem(String name) {
    return '$name einsetzen';
  }

  @override
  String get forgeChooseItem =>
      'Wähle einen Gegenstand, in den dieser Edelstein eingesetzt wird.';

  @override
  String get forgeReplaceGem => 'Edelstein ersetzen?';

  @override
  String forgeReplaceBody(String old, String gnew) {
    return '$old wird zerstört und durch $gnew ersetzt. Dies kann nicht rückgängig gemacht werden.';
  }

  @override
  String get forgeReplace => 'ERSETZEN';

  @override
  String get forgeUpgradeInfo =>
      'Verbessere Gegenstände von +0 auf +10. Jede Stufe erhöht alle Werte um 8%.\nBei +5 erhält der Gegenstand ein „Refined\"-Präfix.\nBei +10 wird er „Masterwork\".';

  @override
  String get forgeBalance => 'Guthaben: ';

  @override
  String get forgeNoUpgradeItems =>
      'Keine Gegenstände zum Verbessern verfügbar.\nAlle Gegenstände sind auf +10 oder der Beutel ist leer.';

  @override
  String get forgeSelectItem => 'GEGENSTAND WÄHLEN';

  @override
  String get forgeAllStats => 'Alle Werte +8%';

  @override
  String get forgeWeaponDmgSuffix => '  •  Waffenschaden +8%';

  @override
  String get forgeRefinedPrefix => '🏷 Erhält bei +5 das Präfix „Refined\"!';

  @override
  String get forgeMasterworkPrefix =>
      '🏷 Erhält bei +10 das Präfix „Masterwork\"!';

  @override
  String forgeUpgradeTo(int tier) {
    return 'VERBESSERN AUF +$tier';
  }

  @override
  String get dngTitle => 'DAS VERLIES';

  @override
  String dngTitleRun(int tier, int floor) {
    return 'T$tier  ET.$floor  —  DAS VERLIES';
  }

  @override
  String get dngFlee => 'Verlies verlassen';

  @override
  String get dngAutoOn => 'Auto-Lauf: AN — tippe für manuelle Kontrolle';

  @override
  String get dngAutoOff => 'Auto-Lauf: AUS — tippe für Auto-Durchlauf';

  @override
  String get dngAutoPremium => 'Auto-Lauf (ab Stufe 5)';

  @override
  String get dngPushOnTip =>
      'Abyssaler Vorstoß: AN — besiege den Verliesfürsten, um tiefer abzusteigen';

  @override
  String get dngPushOffTip =>
      'Abyssaler Vorstoß: AUS — Lauf endet beim Klar-Stockwerk';

  @override
  String get dngPushOnMsg =>
      'Abyssaler Vorstoß AN — besiege den Verliesfürsten, um in eskalierende Abgrund-Stockwerke abzusteigen (mehr Mithril + einzigartige Chancen). Fliehe jederzeit, um den Erfolg zu sichern.';

  @override
  String get dngPushOffMsg =>
      'Abyssaler Vorstoß AUS — der Lauf endet, wenn du den Verliesfürsten besiegst.';

  @override
  String get dngLeaderboard => 'Verlies-Bestenliste';

  @override
  String get dngAutoPremiumMsg =>
      'Auto-Lauf wird ab Kampagnen-Stufe 5 freigeschaltet.';

  @override
  String get dngTutorial =>
      'Wähle auf jedem Stockwerk eine von zwei Türen. Besiegte Gegner lassen Knochen fallen — gib sie beim fahrenden Händler für laufweite Boni aus. Beute gehört sofort dir, selbst wenn dein Held fällt.';

  @override
  String get dngWhatToExpect => 'WAS DICH ERWARTET';

  @override
  String get dngExpCombat => 'Kampf — kämpfe um Gold';

  @override
  String get dngExpElite => 'Elite — stärkerer Feind, garantierter Gegenstand';

  @override
  String get dngExpAmbush => 'Hinterhalt — Gegner schlägt zuerst zu, viel Gold';

  @override
  String get dngExpRest => 'Rastplatz — stelle 20% LP wieder her';

  @override
  String get dngExpTreasure => 'Schatz — erhalte Gold & Splitter';

  @override
  String get dngExpShrine => 'Schrein — wähle einen laufweiten Segen';

  @override
  String get dngExpChest =>
      'Verschlossene Truhe — gib Splitter für einen seltenen Gegenstand aus';

  @override
  String get dngExpTrap => 'Falle — unvermeidbarer Schaden';

  @override
  String get dngExpBoss =>
      'Boss (jedes 5. Stockwerk) — hohes Risiko, hohe Belohnung';

  @override
  String get dngBonesHint =>
      'Besiegte Gegner lassen Knochen fallen — gib sie beim fahrenden Händler aus.';

  @override
  String get dngExpectedLoot => 'ERWARTETE BEUTE';

  @override
  String get dngLootGold => 'Gold';

  @override
  String get dngLootGoldDetail => 'Aus Kämpfen, Schatzräumen & Rast-Vorräten';

  @override
  String get dngLootShards => 'Splitter';

  @override
  String get dngLootShardsDetail => 'Schatzräume & Truhen entlang des Laufs';

  @override
  String get dngLootItems => 'Gegenstände';

  @override
  String dngLootItemsDetail(String tier) {
    return 'Gegenstandsstufe in deiner Tiefe: $tier  (Eliten & Bosse geben bessere)';
  }

  @override
  String get dngLootMythril => 'Mithril';

  @override
  String dngLootMythrilDetail(int a, int b) {
    return '~$a auf Stockwerk 5  •  ~$b auf Stockwerk 10';
  }

  @override
  String dngYourBest(int f, int m) {
    return 'Dein Bestwert: Stockwerk $f  •  ~$m Mithril';
  }

  @override
  String get dngNoRecord => 'Noch kein Rekord';

  @override
  String dngDeepestFloor(int f) {
    return 'Tiefstes Stockwerk: $f';
  }

  @override
  String dngDailyAttempts(int r, int max) {
    return 'Tägliche Versuche: $r / $max';
  }

  @override
  String dngEnterTier(int tier) {
    return 'BETRETEN  STUFE $tier';
  }

  @override
  String get dngNoAttempts => 'KEINE VERSUCHE ÜBRIG';

  @override
  String dngBuyExtra(int cost) {
    return '$cost Z-Coins — 1 Extra-Versuch kaufen';
  }

  @override
  String get dngBossFloor => '☠ BOSS-STOCKWERK';

  @override
  String dngBossIn(int n) {
    return '☠ Boss in $n';
  }

  @override
  String get dngChoosePath => 'WÄHLE DEINEN WEG';

  @override
  String get dngNextBoss => '☠ NÄCHSTES STOCKWERK: BOSS';

  @override
  String get dngMystery => 'GEHEIMNIS';

  @override
  String get dngGoblin => '💰 SCHATZ-GOBLIN';

  @override
  String get dngEnter => 'BETRETEN';

  @override
  String get dngMystery1 => 'Eine unmarkierte Tür.';

  @override
  String get dngMystery2 => 'Glück oder Gefahr?';

  @override
  String dngGoblinHp(Object hp) {
    return '$hp HP  •  flieht nach 5 Runden';
  }

  @override
  String get dngGoblinReward => '6× Gold, wenn du ihn rechtzeitig erschlägst!';

  @override
  String get dngGuaranteedDrop => 'Garantierter Gegenstand';

  @override
  String get dngStrikesFirst => 'Schlägt zuerst zu — viel Gold';

  @override
  String get dngDoorBlessing => 'Ein Segen...';

  @override
  String get dngDoorCurse => 'oder ein Fluch?';

  @override
  String get dngMakeCamp => 'Lager aufschlagen';

  @override
  String get dngRecoverHp => 'LP wiederherstellen';

  @override
  String get dngRareInside => 'Seltener Gegenstand darin';

  @override
  String dngShardsToOpen(Object n) {
    return '$n Splitter zum Öffnen';
  }

  @override
  String dngPlusGold(Object g) {
    return '+$g Gold';
  }

  @override
  String dngPlusShards(Object s) {
    return '+$s Splitter';
  }

  @override
  String dngMinusHp(Object d) {
    return '-$d HP';
  }

  @override
  String dngEnemyStats(Object hp, Object atk) {
    return '$hp HP  •  $atk ATK';
  }

  @override
  String get dngEnemy => 'Gegner';

  @override
  String get dngSpeedNeeds =>
      'Höheres Tempo erfordert den Tempo-Boost / Premium-Pass.';

  @override
  String get dngTreasureFound => 'Schatz gefunden!';

  @override
  String get dngCursed => '✸ VERFLUCHT!';

  @override
  String get dngBlessed => '✧ GESEGNET!';

  @override
  String get dngDarkToll => 'Die Dunkelheit fordert ihren Tribut...';

  @override
  String get dngAncientPower => 'Uralte Macht durchströmt dich.';

  @override
  String get dngLightShadow =>
      'Licht und Schatten binden sich an dein Schicksal.';

  @override
  String get dngShrineCorrupted => 'Verderbter Schrein';

  @override
  String get dngShrineBlessed => 'Gesegneter Schrein';

  @override
  String get dngShrineAncient => 'Uralter Schrein';

  @override
  String get dngShrineCorruptedFlavor =>
      'Dunkle Energien pulsieren und winden sich. Ein Fluch ist gewiss — doch Macht wartet.';

  @override
  String get dngShrineBlessedFlavor =>
      'Warmes göttliches Licht strahlt von diesem Ort aus. Ein Segen ist garantiert.';

  @override
  String get dngShrineTwinFlavor =>
      'Zwei Kräfte regen sich darin — du erhältst sowohl einen Segen als auch einen Fluch.';

  @override
  String get dngShrineNormalFlavor =>
      'Ein mysteriöser Schrein pulsiert mit unbekannter Energie.\nBetritt ihn für einen Segen... oder einen Fluch.\nDu wirst nicht wissen, welcher, bis es zu spät ist.';

  @override
  String get dngAcceptCurse => 'DEN FLUCH ANNEHMEN';

  @override
  String get dngReceiveBlessing => 'SEGEN EMPFANGEN';

  @override
  String get dngEnterTwin => 'BETRETEN  (2 EFFEKTE)';

  @override
  String get dngEnterShrine => 'SCHREIN BETRETEN';

  @override
  String dngActiveEffects(int n) {
    return 'Aktive Effekte: $n';
  }

  @override
  String get dngSkip => 'ÜBERSPRINGEN';

  @override
  String dngGuaranteeBless(int c) {
    return '✧  SEGEN GARANTIEREN  ($c ◆)';
  }

  @override
  String dngTrapDamage(int dmg, int pct) {
    return 'Du erleidest $dmg Schaden ($pct% der max. LP).';
  }

  @override
  String get dngLockedChest => 'Verschlossene Truhe';

  @override
  String get dngChestContains =>
      'Enthält einen seltenen oder epischen Gegenstand.';

  @override
  String dngCostShards(Object cost) {
    return '$cost Splitter';
  }

  @override
  String dngHave(int n) {
    return '(hast $n)';
  }

  @override
  String dngCostZcoins(int cost) {
    return '$cost Z-Coins';
  }

  @override
  String get dngMerchantQuote =>
      '„Knochen für Schmuckstücke, Reisender. Mehr Knochen, feinere Waren.\"';

  @override
  String dngBones(int n) {
    return '🦴  $n Knochen';
  }

  @override
  String dngBoneCost(int c) {
    return '$c 🦴';
  }

  @override
  String get dngClaimRelic => '☠ BOSS ERSCHLAGEN — WÄHLE EIN RELIKT';

  @override
  String get dngSkipDescend => 'ÜBERSPRINGEN — ABSTEIGEN';

  @override
  String get dngReturn => 'ZURÜCK';

  @override
  String dngDescendTo(int n) {
    return 'ABSTEIGEN ZU STOCKWERK $n';
  }

  @override
  String get dngFallen => '☠ Gefallen';

  @override
  String get dngGotAway => '💰 Er ist entkommen!';

  @override
  String get dngVictory => '✓ Sieg';

  @override
  String dngAmbushHit(int n) {
    return 'Der Hinterhalt verursachte $n Schaden vor dem Kampf.';
  }

  @override
  String dngItemToBag(String name, String label) {
    return '✦ $name ($label) → Beutel';
  }

  @override
  String get dngRested => '⊕ Gerastet';

  @override
  String get dngTreasureCollected => '✦ Schatz eingesammelt';

  @override
  String get dngBlessingReceived => '✧ Segen erhalten';

  @override
  String get dngSlainTrap => '☠ Von der Falle erschlagen';

  @override
  String get dngTrapSurvived => '✸ Falle überlebt';

  @override
  String get dngChestOpened => '◆ Truhe geöffnet';

  @override
  String get dngLootAdded =>
      'Deine Beute wurde deinem Konto bereits gutgeschrieben.';

  @override
  String dngLordFallen(int z, int g) {
    return 'Der Verliesfürst ist gefallen!\n+5 Mithril  •  +$z Z-Coins  •  +$g Gold  •  Bonus-Gegenstand';
  }

  @override
  String dngTierN(int t) {
    return 'STUFE $t';
  }

  @override
  String get dngFloor => 'STOCKWERK';

  @override
  String get dngRooms => 'RÄUME';

  @override
  String get dngBosses => 'BOSSE';

  @override
  String get dngGold => 'GOLD';

  @override
  String get dngShards => 'SPLITTER';

  @override
  String dngTierCleared(int t) {
    return '✓ Stufe $t abgeschlossen — AUTO freigeschaltet!';
  }

  @override
  String get dngNewRecord => '★ Neuer Rekord!';

  @override
  String get dngAllLootAdded => 'Alle Beute wurde deinem Konto gutgeschrieben.';

  @override
  String get dngYouFallen => 'DU BIST GEFALLEN';

  @override
  String get dngCleared => 'VERLIES ABGESCHLOSSEN!';

  @override
  String get dngRunEnded => 'LAUF BEENDET';

  @override
  String get dngAutoLocked => '🔒 AUTO';

  @override
  String get dngStop => '◉ STOPP';

  @override
  String get dngAuto => '✦ AUTO';

  @override
  String get dngRunAgain => 'ERNEUT LAUFEN';

  @override
  String get dngReturnHall => 'ZURÜCK ZUR HALLE';

  @override
  String get auraEquipped => 'AUSGERÜSTET';

  @override
  String get auraOn => 'AN';

  @override
  String auraCost(int n) {
    return 'Kosten: $n Z-Coins';
  }

  @override
  String auraUnlockTitle(String name) {
    return '$name freischalten?';
  }

  @override
  String get auraAllAuras => 'ALLE AUREN';

  @override
  String get auraAllSkins => 'ALLE SKINS';

  @override
  String get auraAllPets => 'ALLE GEFÄHRTEN';

  @override
  String get auraRemoveAura => 'Aura entfernen';

  @override
  String get auraRemoveSkin => 'Skin entfernen';

  @override
  String get auraDismissPet => 'Gefährten entlassen';

  @override
  String get auraBattleCompanion => 'KAMPFGEFÄHRTE';

  @override
  String get auraWaystones => 'WEGSTEINE';

  @override
  String get auraAttackEffects => 'ANGRIFFSEFFEKTE';

  @override
  String get auraCharSlots => 'CHARAKTERPLÄTZE';

  @override
  String get auraCompanionNote =>
      'Es kann jeweils ein Gefährte aktiv sein. Jeder gewährt einen kleinen passiven Bonus.';

  @override
  String get auraBeforeAfter => 'Vorher / Nachher';

  @override
  String get auraAllSlots => 'Alle 12 Plätze freigeschaltet.';

  @override
  String auraAdoptTitle(String name) {
    return '$name adoptieren?';
  }

  @override
  String auraPetBonus(String label) {
    return '✦ $label';
  }

  @override
  String get auraMaxEvolution => '★★ MAX. EVOLUTION';

  @override
  String auraOwned(Object count) {
    return 'Besitzt: $count';
  }

  @override
  String auraWaystoneDesc(Object h, String m) {
    return '${h}h  ·  $m× Idle-Einkommen';
  }

  @override
  String auraHitEvery(String text) {
    return '„$text\" bei jedem Treffer';
  }

  @override
  String auraSlotN(Object n) {
    return 'Platz $n';
  }

  @override
  String get auraAddSlot =>
      'Füge einen weiteren Charakter-Speicherplatz hinzu.';

  @override
  String get auraUnlock => 'FREISCHALTEN';

  @override
  String get auraAdopt => 'ADOPTIEREN';

  @override
  String get auraBuy => 'KAUFEN';

  @override
  String get auraEvolve => 'ENTWICKELN';

  @override
  String get auraEquip => 'AUSRÜSTEN';

  @override
  String get auraActive => 'AKTIV';

  @override
  String get auraSendOut => 'AUSSENDEN';

  @override
  String get auraStackAuras =>
      'Boni von jeder Aura, die du BESITZT, stapeln sich automatisch — du behältst sie alle. Rüste eine aus, nur um zu wählen, welches Leuchten du zeigst.';

  @override
  String get auraStackSkins =>
      'Boni von jedem Skin, den du BESITZT, stapeln sich automatisch — du behältst sie alle. Rüste einen aus, nur um zu wählen, welches Aussehen du trägst.';

  @override
  String get armTabUniques => 'UNIKATE';

  @override
  String get armTabMythic => 'MYTHISCH';

  @override
  String get armTabSets => 'SET-ITEMS';

  @override
  String get armTabArtifacts => 'ARTEFAKTE';

  @override
  String get armNoLegendaries => 'Keine Legendären für diese Klasse.';

  @override
  String armClassUniques(int count) {
    return '$count Klassen-Unikate';
  }

  @override
  String get armOwned => 'BESITZT';

  @override
  String armSlotReqLevel(String slot, int lvl) {
    return '$slot  •  Erf. Level $lvl';
  }

  @override
  String get armStats => 'WERTE';

  @override
  String get armAbilityEnh => 'FÄHIGKEITSVERSTÄRKUNG';

  @override
  String armAbilityDamage(String x) {
    return '• Fähigkeitsschaden ×$x';
  }

  @override
  String armAbilityDuration(Object n) {
    return '• +$n Runden Dauer';
  }

  @override
  String armAbilityCooldown(String v) {
    return '• $v Runden Abklingzeit';
  }

  @override
  String armOnCast(String desc) {
    return '• Beim Wirken: $desc';
  }

  @override
  String get armHowToFind => 'WO ZU FINDEN';

  @override
  String get armDropCampaign => 'Kampagnen-Bosse';

  @override
  String get armDropTower => 'Turmaufstieg-Bosse';

  @override
  String get armDropBossRush => 'Boss-Rush-Läufe';

  @override
  String get armDropGauntlet => 'Gauntlet-Abschluss';

  @override
  String get armRate2 => '2% pro Boss-Kill';

  @override
  String get armRate03 => '0,3% pro Boss-Kill';

  @override
  String get armRateRare => 'Seltener Bonus-Drop';

  @override
  String get armDropsClassSpecific =>
      'Drops sind klassenspezifisch — nur Gegenstände für deine Klasse können fallen.';

  @override
  String get armNoMythic => 'Noch keine mythischen Gegenstände';

  @override
  String get armMythicHint =>
      'Besiege Kampagnen-Bosse für eine Chance von 0,5% pro Kill.';

  @override
  String get armMythicItems => 'Mythische Gegenstände';

  @override
  String armSlotLv(String slot, int lvl) {
    return '$slot  •  Lv$lvl';
  }

  @override
  String armKeyword(String name) {
    return 'Schlüsselwort $name';
  }

  @override
  String get armSetItemsTitle => 'Set-Items';

  @override
  String armFraction(int a, int b) {
    return '$a / $b';
  }

  @override
  String get armEquippedLower => 'ausgerüstet';

  @override
  String get armSetBonuses => 'SET-BONI';

  @override
  String armPc(Object n) {
    return '$n Tlg.';
  }

  @override
  String get armUniqueBlurb =>
      'Unikate sind klassengebunden und verstärken deine Fähigkeiten enorm. Jedes verstärkt eine bestimmte Klassenfähigkeit. Droprate: 2% pro Boss-Kill.';

  @override
  String get armMythicBlurb =>
      'Die seltenste prozedural generierte Stufe. Mythische Gegenstände haben 3 Werte mit den höchstmöglichen Werten und einen mächtigen Schlüsselwort-Effekt. Droprate: 0,5% pro Boss-Kill.';

  @override
  String get armSetBlurb =>
      'Sammle mehrere Teile desselben Sets, um mächtige Boni freizuschalten. Sets benötigen jetzt 6 Teile für den vollen Bonus. Droprate: 0,3% pro Boss-Kill.';

  @override
  String armArtifactBlurb(int count) {
    return '$count dreiteilige Artefakt-Sets. Rüste 2 passende grüne Teile im Artefakt-Raster für einen Teil-Bonus aus, alle 3 für den vollen Bonus. Set-Teile fallen in Verliesen, Boss-Rush und von Kampagnen-Bossen.';
  }

  @override
  String get armSetPieces => 'SET-TEILE';

  @override
  String get armArtifactSets => 'Artefakt-Sets';

  @override
  String armCollected(int a, int b) {
    return 'GESAMMELT  $a / $b verschiedene Teile im Besitz';
  }

  @override
  String endlessStage(int n) {
    return 'Stufe $n';
  }

  @override
  String endlessNextReward(int n) {
    return 'Nächste Belohnung: Stockwerk $n';
  }

  @override
  String get endlessChallengeBoss => 'FORDERE EINEN BOSS HERAUS';

  @override
  String get endlessPremiumAutoClear =>
      '🔒  Erreiche Kampagnen-Stufe 5, um Bosse automatisch zu besiegen';

  @override
  String get endlessRewards => 'BELOHNUNGEN: ';

  @override
  String get endlessDrop => 'BEUTE: ';

  @override
  String get endlessGold => 'GOLD';

  @override
  String get endlessXp => 'EP';

  @override
  String get endlessRespawns => 'RESPAWNS';

  @override
  String endlessTowerShards(String n) {
    return '+$n TURM-SPLITTER';
  }

  @override
  String endlessMilestone(Object n) {
    return '★ MEILENSTEIN: $n KILLS ★';
  }

  @override
  String endlessMilestoneReward(String gold, Object s) {
    return '+$gold GOLD  +$s ◆';
  }

  @override
  String get endlessEnemyStirs => 'Der Gegner regt sich erneut...';

  @override
  String get endlessDefeatBody =>
      'Dein Held wurde überwältigt.\nVerbessere deine Werte und versuch es erneut.';

  @override
  String get pvpNoStamina => 'Keine Ausdauer! Lädt alle 45 Minuten um 1 auf.';

  @override
  String get pvpTitle => 'PVP-ARENA';

  @override
  String get pvpSimLab => 'Sim-Labor';

  @override
  String get pvpRefresh => 'Bestenliste aktualisieren';

  @override
  String get pvpLeaderboard => 'BESTENLISTE';

  @override
  String pvpToday(String label) {
    return 'HEUTE: $label';
  }

  @override
  String pvpWinsToday(Object wins, Object dmg) {
    return '$wins Siege heute  •  $dmg Gesamtschaden';
  }

  @override
  String get pvpClaimed => '✓ EINGESAMMELT';

  @override
  String get pvpNoChallengers => 'NOCH KEINE HERAUSFORDERER';

  @override
  String get pvpNoChallengersSub =>
      'Kämpfe einen Kampf, um der Bestenliste beizutreten\nund zu sehen, wie du dich schlägst.';

  @override
  String pvpHpAc(Object hp, Object ac) {
    return 'HP:$hp  AC:$ac';
  }

  @override
  String get pvpStamina => 'AUSDAUER  ';

  @override
  String get pvpStaminaTip => 'Ausdauer regeneriert alle 45 Minuten 1 Herz.';

  @override
  String get pvpRating => 'WERTUNG';

  @override
  String get pvpWins => 'SIEGE';

  @override
  String get pvpLosses => 'NIEDERLAGEN';

  @override
  String get pvpWL => 'S/N';

  @override
  String pvpLeague(String name) {
    return '$name-LIGA';
  }

  @override
  String get pvpNearRank => 'NAHE DEINEM RANG';

  @override
  String get pvpPlayersAbove => '— Spieler direkt über dir';

  @override
  String pvpClassLv(String cls, Object lvl) {
    return '$cls  Lv$lvl';
  }

  @override
  String get pvpChallenge => 'HERAUSFORDERN';

  @override
  String get pvpBattleLog => 'KAMPFPROTOKOLL';

  @override
  String get pvpBattleLogTip => 'Kampfprotokoll';

  @override
  String get pvpNoCombat => 'Noch kein Kampf.';

  @override
  String get pvpClose => 'SCHLIESSEN';

  @override
  String pvpVs(String hero, String opp) {
    return 'PVP  —  $hero gegen $opp';
  }

  @override
  String get pvpReturnArena => 'ZURÜCK ZUR ARENA';

  @override
  String get pvpFighting => 'Kämpft...';

  @override
  String invBagCount(Object n, Object cap) {
    return '($n/$cap)';
  }

  @override
  String invBuyTab(Object cost) {
    return '+ TAB  $cost';
  }

  @override
  String get invAutoEquip => 'AUTO-AUSRÜSTEN';

  @override
  String invTabN(Object n, Object count) {
    return 'TAB $n  ($count)';
  }

  @override
  String get invEquipment => 'AUSRÜSTUNG';

  @override
  String invBag(Object n, Object cap) {
    return 'BEUTEL  ($n/$cap)';
  }

  @override
  String get invUnequip => 'Ablegen';

  @override
  String get invNoItems => 'Keine Gegenstände in diesem Tab.';

  @override
  String invReqClass(String cls) {
    return 'Erfordert $cls';
  }

  @override
  String invReqLevel(Object lvl) {
    return 'Erfordert Level $lvl';
  }

  @override
  String invReqTier(Object t) {
    return 'Erfordert Stufe $t';
  }

  @override
  String get invCannotEquip => 'Nicht ausrüstbar';

  @override
  String get invEquip => 'Ausrüsten';

  @override
  String get invUnlock => 'Entsperren 🔓';

  @override
  String get invLock => 'Sperren 🔒';

  @override
  String get invDiscard => 'Verwerfen';

  @override
  String get invAny => 'Alle';

  @override
  String invUniqueOnly(String cls) {
    return '★ Unikat — nur $cls';
  }

  @override
  String get invWrongClass => '(falsche Klasse)';

  @override
  String get invColStat => 'WERT';

  @override
  String get invColThis => 'DIES';

  @override
  String get invColEqpd => 'AUSG.';

  @override
  String get invColDiff => 'DIFF';

  @override
  String get invEmptySocket => 'Leerer Sockel';

  @override
  String get invCraftGems => 'Stelle Edelsteine in Schmiede → Edelsteine her';

  @override
  String get invRemove => 'ENTFERNEN';

  @override
  String get invSocket => 'EINSETZEN';

  @override
  String invChooseGem(String name) {
    return 'Wähle einen Edelstein zum Einsetzen in $name';
  }

  @override
  String invOnThis(String slot, String bonus) {
    return 'An diesem $slot: $bonus';
  }

  @override
  String get invRemoveGem => 'Edelstein entfernen?';

  @override
  String get invDestroy => 'ZERSTÖREN';

  @override
  String get invSort => 'Sortieren:';

  @override
  String get invFilter => 'Filter:';

  @override
  String invGemsAvailable(Object count) {
    return '$count Edelstein(e) zum Einsetzen verfügbar';
  }

  @override
  String invRemoveBody(String name) {
    return '$name wird zerstört. Edelsteine können nach dem Entfernen nicht wiederhergestellt werden.';
  }

  @override
  String invReplaceBody(String old, String gnew) {
    return '$old wird zerstört und durch $gnew ersetzt.';
  }

  @override
  String get npcRoster => 'KADER';

  @override
  String get npcSynergies => 'SYNERGIEN';

  @override
  String get npcTitle => 'SÖLDNER';

  @override
  String get npcTotalBonuses => 'AKTIVE GESAMTBONI';

  @override
  String get npcBattleParty => 'KAMPFGRUPPE';

  @override
  String npcFielded(Object count, Object max) {
    return '$count / $max im Einsatz';
  }

  @override
  String get npcUnknown => 'Unbekannter Söldner';

  @override
  String npcBattleAbility(String name) {
    return 'KAMPFFÄHIGKEIT: $name';
  }

  @override
  String npcUnlock(String label) {
    return 'Freischalten: $label';
  }

  @override
  String npcProgress(Object a, Object b) {
    return '$a / $b';
  }

  @override
  String npcLvTalent(Object n) {
    return 'LV $n TALENT';
  }

  @override
  String npcChosen(String name) {
    return 'GEWÄHLT: $name';
  }

  @override
  String get npcMilestoneComplete =>
      'MEILENSTEIN ABGESCHLOSSEN — REKRUTIERE...';

  @override
  String get npcMax => '★ MAX';

  @override
  String get npcStarRank => 'STERNEN-RANG';

  @override
  String npcStars(Object a, Object b) {
    return '$a / $b';
  }

  @override
  String get npcFullyAscended =>
      '★ VOLL AUFGESTIEGEN — jeder Stern gibt +1 effektives Level.';

  @override
  String npcAscendStar(Object n) {
    return 'AUFSTIEG ★$n';
  }

  @override
  String npcYouHave(Object n) {
    return 'Du hast: $n Mithril';
  }

  @override
  String get npcStarInfo =>
      'Jeder Stern = +1 effektives Level des Bonus dieses Söldners.';

  @override
  String get npcPassiveOnly => 'Nur passive Boni — immer aktiv.';

  @override
  String npcCostShards(Object n) {
    return 'Kosten: ◆ $n Splitter';
  }

  @override
  String get npcTutorial =>
      'Söldner sind Gefährten, die dauerhaft beitreten, wenn du bestimmte Meilensteine erreichst. 🤝 Jeder bietet in jedem Kampf passive Kampfboni und kann mit anderen für zusätzliche Stärke zusammenwirken.';

  @override
  String npcRecruited(Object a, Object b) {
    return '$a / $b  rekrutiert';
  }

  @override
  String get npcNoMercs =>
      'Noch keine Söldner rekrutiert. Erfülle Meilensteine, um sie freizuschalten.';

  @override
  String npcChipDamage(Object n) {
    return '+$n% Schaden';
  }

  @override
  String npcChipAc(Object n) {
    return '+$n% AC';
  }

  @override
  String npcChipShards(Object n) {
    return '+$n% Splitter';
  }

  @override
  String npcChipHp(Object n) {
    return '+$n% HP';
  }

  @override
  String get shopTabBundles => 'BÜNDEL';

  @override
  String get shopTabVip => 'VIP';

  @override
  String get shopTabStarter => 'STARTER';

  @override
  String get shopTabResources => 'RESSOURCEN';

  @override
  String get shopTabCosmetics => 'KOSMETIK';

  @override
  String get shopSecBundles => 'Z-COIN-BÜNDEL';

  @override
  String get shopSecBundlesSub => 'Premiumwährung für den Shop';

  @override
  String get shopSecVip => 'VIP-ABOS';

  @override
  String get shopSecVipSub => 'Wiederkehrende Vorteile und Boni';

  @override
  String get shopSecStarter => 'STARTER-PAKETE';

  @override
  String get shopSecStarterSub => 'Einmalige Kauf-Bündel';

  @override
  String get shopSecResources => 'RESSOURCEN';

  @override
  String get shopSecResourcesSub => 'Gib Z-Coins für Gold & Materialien aus';

  @override
  String get shopSecAuras => 'AUREN';

  @override
  String get shopSecAurasSub =>
      'Rüste ein Leuchten aus — besessene Aura-Boni stapeln immer';

  @override
  String get shopSecBoosts => 'BOOSTS';

  @override
  String get shopSecBoostsSub => 'Dauerhafte Wert-Boosts';

  @override
  String get shopSecTitles => 'TITEL';

  @override
  String get shopSecTitlesSub => 'Ein Rang unter deinem Namen';

  @override
  String get shopSecColours => 'NAMENSFARBEN';

  @override
  String get shopSecColoursSub => 'Farbe + Leuchten für deinen Heldennamen';

  @override
  String get shopSecFrames => 'RAHMEN';

  @override
  String get shopSecFramesSub => 'Ein Rahmen um dein Heldenporträt';

  @override
  String get shopSecSlots => 'CHARAKTERPLÄTZE';

  @override
  String get shopSecSlotsSub => 'Zusätzliche Charakter-Speicherplätze';

  @override
  String get shopPremiumArmor => 'PREMIUM-KLASSENRÜSTUNG';

  @override
  String shopEndgameSkin(String cls) {
    return '$cls · Endgame-Skin';
  }

  @override
  String get shopIncludedBonuses => 'ENTHALTENE BONI';

  @override
  String get shopEverySkin => 'jeder Shop-Skin-Bonus, kombiniert';

  @override
  String get shopEquippedCheck => '✓ AUSGERÜSTET';

  @override
  String get shopUnequip => 'ABLEGEN';

  @override
  String shopUnlockPrice(String price) {
    return 'FREISCHALTEN  ·  $price';
  }

  @override
  String get shopStoreUnavailable =>
      'Store nicht verfügbar — versuch es später erneut.';

  @override
  String get shopVipSub => 'VIP-ABO';

  @override
  String get shopSubscribed => '✓ ABONNIERT';

  @override
  String shopSubscribe(String price) {
    return 'ABONNIEREN  $price';
  }

  @override
  String get shopEverythingPlus => 'Alles aus Vanguard\'s Pact, plus:';

  @override
  String get shopIncludedPerks => 'ENTHALTENE VORTEILE';

  @override
  String get shopGlow => '✦ LEUCHTEN';

  @override
  String get shopExclusive => 'EXKLUSIV';

  @override
  String get shopNoAd =>
      'Gerade keine Werbung verfügbar — versuch es später erneut.';

  @override
  String get shopWatchAd => 'Werbung ansehen';

  @override
  String get shopComeBackTomorrow =>
      'Komm morgen für mehr gratis Z-Coins wieder!';

  @override
  String get shopWait => 'WARTEN...';

  @override
  String get shopWatch => 'ANSEHEN';

  @override
  String get shopRewardEarned => 'BELOHNUNG ERHALTEN';

  @override
  String shopPlusZcoins(Object amount) {
    return '+$amount Z-Coins';
  }

  @override
  String get shopCollect => 'EINSAMMELN';

  @override
  String get shopPurchasesRestored =>
      'Käufe wiederhergestellt. Aktive Abos oder Pakete wurden erneut angewendet.';

  @override
  String get shopRestorePurchases => 'Käufe wiederherstellen';

  @override
  String artSalvageTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Artefakte verwerten?',
      one: '$count Artefakt verwerten?',
    );
    return '$_temp0';
  }

  @override
  String get artSalvage => 'VERWERTEN';

  @override
  String artSalvaged(int n, Object gained) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Artefakte für ◆ $gained Mithril verwertet.',
      one: '$n Artefakt für ◆ $gained Mithril verwertet.',
    );
    return '$_temp0';
  }

  @override
  String get artTable => 'ARTEFAKT-TAFEL';

  @override
  String artSlots(Object n, Object max) {
    return '$n/$max Plätze';
  }

  @override
  String artAutoEquipped(Object n) {
    return '$n beste Artefakte automatisch ausgerüstet.';
  }

  @override
  String get artNoneToEquip => 'Keine Artefakte zum Ausrüsten.';

  @override
  String get artAutoEquip => '⚡ AUTO-AUSRÜSTEN';

  @override
  String get artSalvageBtn => '♻ VERWERTEN';

  @override
  String get artTitle => 'ARTEFAKTE';

  @override
  String get artPlaceHint =>
      'Platziere Artefakte auf der Tafel, um Boni zu erhalten.';

  @override
  String get artTableBonuses => 'TAFEL-BONI';

  @override
  String get artCollection => 'SAMMLUNG';

  @override
  String artCount(Object n) {
    return '($n)';
  }

  @override
  String artTapToPlace(String name) {
    return 'Tippe auf eine Rasterzelle, um „$name\" zu platzieren';
  }

  @override
  String get artTapCancel => 'nochmal tippen zum Abbrechen';

  @override
  String get artSet => 'SET';

  @override
  String artUpgradeCost(Object cost) {
    return '$cost Mithril';
  }

  @override
  String artNoSets(Object n) {
    return 'Noch keine Set-Teile ausgerüstet — $n Sets zu entdecken.';
  }

  @override
  String artCountOf3(Object count) {
    return '$count / 3';
  }

  @override
  String get artHowToGet => 'WIE MAN ARTEFAKTE ERHÄLT';

  @override
  String get artRowCampaign => 'Kampagnen-Bosse';

  @override
  String get artRowCampaignDesc =>
      'etwa 25% Chance, bei jedem Boss-Stufen-Kill zu fallen.';

  @override
  String get artRowDungeon => 'Verlies-Läufe';

  @override
  String get artRowDungeonDesc =>
      'jeder besiegte Boss lässt eins fallen — bis zu 2 pro Lauf. Beste stetige Farm.';

  @override
  String get artRowBossRush => 'Boss-Rush';

  @override
  String get artRowBossRushDesc =>
      'schließe einen Lauf mit Rang A oder S ab, um ein Artefakt zu erhalten.';

  @override
  String artSalvageBody(int count, Object mythril) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Alle $count nicht ausgerüsteten Artefakte dauerhaft für ◆ $mythril Mithril zerstören? Ausgerüstete Artefakte bleiben erhalten.',
      one:
          '$count nicht ausgerüstetes Artefakt dauerhaft für ◆ $mythril Mithril zerstören? Ausgerüstete Artefakte bleiben erhalten.',
    );
    return '$_temp0';
  }

  @override
  String get artSetBlurb =>
      'Sammle passende grüne Set-Teile. 2 ausgerüstet = Teil-Bonus, alle 3 = voller Bonus.';

  @override
  String get art2Set => '2er-Set';

  @override
  String get art3Set => '3er-Set';

  @override
  String get ptEssence => 'Essenz';

  @override
  String ptTheClass(String cls) {
    return '$cls';
  }

  @override
  String ptRespecBranch(String branch) {
    return '$branch neu verteilen?';
  }

  @override
  String ptRefund(Object refund) {
    return '$refund Essenz erstatten (75%)';
  }

  @override
  String get ptRespec => 'Neu verteilen';

  @override
  String get ptCrossBranch => 'ZWEIGÜBERGREIFEND';

  @override
  String get ptFullRespec => 'Komplett neu verteilen?';

  @override
  String get ptRespec50 => 'Neu verteilen (50 ZC)';

  @override
  String get ptFullRespecBtn => 'KOMPLETT NEU VERTEILEN (50 ZC)';

  @override
  String get ptTitle => 'PASSIV-BAUM';

  @override
  String get ptNow => 'JETZT';

  @override
  String ptUpgradeCost(Object cost) {
    return 'VERBESSERN  ($cost ✦)';
  }

  @override
  String get ptLocked => 'GESPERRT — gib 25 Ränge in weiteren Zweigen aus';

  @override
  String get ptLockedMax => 'GESPERRT — maximiere zuerst alle Zweig-Knoten';

  @override
  String ptMaxRankTotal(String val) {
    return 'MAX. RANG — $val gesamt';
  }

  @override
  String ptFullRespecBody(Object refund) {
    return 'Setze ALLE Passiv-Knoten zurück.\nErstatte $refund Essenz (60%).\nKosten: 50 Z-Coins.';
  }

  @override
  String ptNodesUnlocked(Object count) {
    return '$count Knoten freigeschaltet';
  }

  @override
  String get ptTutorial =>
      'Du hast Splitter ◆ verdient — gib sie hier für dauerhafte Passiv-Knoten aus, die nie zurückgesetzt werden. Dein Klassenzweig ist ganz oben. Jeder Knoten steigt bis Rang 5 für größere Boni.';

  @override
  String ptBranchesAt25(Object count) {
    return '$count / 5 Zweige bei 25';
  }

  @override
  String get homeExp => 'EP';

  @override
  String get homeResources => 'Ressourcen';

  @override
  String get homeGold => 'GOLD';

  @override
  String get homeShards => 'SPLITTER';

  @override
  String get homeZcoins => 'Z-COINS';

  @override
  String get homeMythril => 'MITHRIL';

  @override
  String get homeIdleMin => 'IDLE/Min';

  @override
  String get homeGoldTip =>
      'Gold\nAus Kämpfen und Idle-Einkommen verdient.\nGib es in Verbesserungen und im Shop aus.';

  @override
  String get homeShardsTip =>
      'Splitter\nAus Gegner-Kills, Verliesen, Expeditionen und Gauntlet verdient.\nGib sie für Fähigkeits-Upgrades, Gegenstands-Upgrades und Passiv-Baum-Knoten aus.';

  @override
  String get homeZcoinsTip =>
      'Z-Coins\nAus Erfolgen und täglichen Truhen verdient.\nGib sie im Aura-Shop für Skins, Gefährten und Auren aus.';

  @override
  String get homeMythrilTip =>
      'Mithril\nAus Verliesen, Boss-Rush und Prestige-Meilensteinen verdient.\nGib es für Artefakt-Upgrades, Verlies-Affix-Neuwürfe und Schrein-Segen aus.';

  @override
  String get homeIdleTip =>
      'Idle-Gold / Min\nGold, das jede Minute automatisch im Offline-Modus verdient wird.\nSteigt mit Heldenlevel, Passiv-Upgrades und Gefährten.';

  @override
  String get homeCurrentCampaign => 'Aktuelle Kampagne';

  @override
  String homeStage(Object n) {
    return 'STUFE $n';
  }

  @override
  String homeNextGoal(Object reward) {
    return 'NÄCHSTES: $reward FREISCHALTEN';
  }

  @override
  String homeNextGoalProgress(Object remaining, Object stage) {
    return 'Noch $remaining Stufen — bezwinge Stufe $stage';
  }

  @override
  String get demoModeLocked =>
      'Im Vollspiel freigeschaltet. Die Demo enthält die komplette Kampagne — hol dir das Vollspiel für Verliese, PvP und die Schwierigkeits-Tiers im Endgame.';

  @override
  String get demoFullGameCta => 'VOLLSPIEL HOLEN';

  @override
  String get homeSecCombat => 'KAMPF';

  @override
  String get homeSecSocial => 'SOZIAL';

  @override
  String get homeNavChallengeGauntlet => 'HERAUSFORDERUNGS-GAUNTLET';

  @override
  String get homeNavBountyBoard => 'KOPFGELD-BRETT';

  @override
  String get homeNavSeasonPass => 'SEASON-PASS';

  @override
  String get homeNavWorldEvent => 'WELT-EVENT';

  @override
  String get homeNavLeaderboard => 'BESTENLISTE';

  @override
  String get homeNavChallengeModifiers => 'HERAUSF.-MODIFIKATOREN';

  @override
  String get homeQuickAccess => 'SCHNELLZUGRIFF';

  @override
  String get homeGettingStarted => 'ERSTE SCHRITTE';

  @override
  String get homeStep1 => 'Gewinne deinen ersten Kampagnenkampf';

  @override
  String get homeStep2 =>
      'Steige mit deinem Helden auf — besuche das Charakterblatt';

  @override
  String get homeStep3 =>
      'Öffne HELD und kaufe dein erstes Attributswert-Upgrade';

  @override
  String get homeStep4 =>
      'Erreiche Stufe 5 — Fähigkeiten und tägliche Prüfungen werden freigeschaltet!';

  @override
  String get homeHeroSubtitle =>
      'VERBESSERUNGEN  •  WAFFENKAMMER  •  VERBÜNDETE  •  KODEX';

  @override
  String get homeTomorrow => 'Morgen: ';

  @override
  String get dailyWeekly => 'WÖCHENTLICH';

  @override
  String get dailyClaimAll => 'ALLE EINSAMMELN';

  @override
  String get dailyHowItWorks => 'So funktioniert\'s';

  @override
  String get dailyThisWeek => 'PRÜFUNGEN DIESER WOCHE';

  @override
  String dailyCompleted(Object claimed, Object total) {
    return '$claimed / $total abgeschlossen';
  }

  @override
  String get dailyWeeklyLoading => 'Wochenprüfungen werden geladen...';

  @override
  String get dailyAboutWeekly => 'Über Wochenprüfungen';

  @override
  String get dailyReady => 'BEREIT';

  @override
  String get dailyTodayProgress => 'HEUTIGER FORTSCHRITT';

  @override
  String get dailyChest => 'TÄGLICHE TRUHE';

  @override
  String get dailyClaimedTomorrow => 'Eingesammelt! Komm morgen wieder.';

  @override
  String get dailyHintKill => 'Gegner töten';

  @override
  String get dailyHintKillD => 'Kämpfe im Kampagnen- oder Endlos-Modus';

  @override
  String get dailyHintWin => 'Kämpfe gewinnen';

  @override
  String get dailyHintWinD => 'Einen Gegner zu besiegen zählt als Sieg';

  @override
  String get dailyHintBoss => 'Boss besiegen';

  @override
  String get dailyHintBossD => 'Stufe 5, 10, 15, 20, 25 oder im Endlos jede 5.';

  @override
  String get dailyHintAbility => 'Fähigkeiten nutzen';

  @override
  String get dailyHintAbilityD =>
      'Aktive Fähigkeiten werden im Kampf automatisch ausgelöst';

  @override
  String get dailyHintEquip => 'Gegenstand ausrüsten';

  @override
  String get dailyHintEquipD =>
      'Tippe im Beutel auf einen Gegenstand → Ausrüsten im Inventar';

  @override
  String get dailyHintGold => 'Gold erreichen';

  @override
  String get dailyHintGoldD => 'Habe einfach so viel Gold im Vorrat';

  @override
  String get dailyHintDamage => 'Schaden verursachen';

  @override
  String get dailyHintDamageD => 'Kumulierter Schaden in jedem Modus';

  @override
  String get dailyHintIdle => 'Idle einsammeln';

  @override
  String get dailyHintIdleD =>
      'Tippe auf die Idle-Belohnung auf dem Startbildschirm';

  @override
  String get dailyHintResets => 'Zurücksetzung';

  @override
  String get dailyHintResetsD => 'Jeden Montag — 5 neue Prüfungen pro Woche';

  @override
  String get dailyHintRewards => 'Belohnungen';

  @override
  String get dailyHintRewardsD =>
      'Größer als täglich: Essenz, Mithril, Z-Coins';

  @override
  String get dailyHintSeasonXp => 'Season-EP';

  @override
  String get dailyHintSeasonXpD =>
      '+50 Season-EP pro eingelöster Wochenprüfung';

  @override
  String get dailyHintProgress => 'Fortschritt';

  @override
  String get dailyHintProgressD =>
      'Zählt ab Montag Mitternacht, nicht ab Einlösung';

  @override
  String get dailyTutorial =>
      'Schließe tägliche Prüfungen ab, um Gold, Splitter, Essenz und Z-Coins zu verdienen. Alle 7 Prüfungen werden täglich zurückgesetzt. Schließe alle ab für eine Bonus-Truhe!';

  @override
  String petOwned(Object a, Object b) {
    return '$a / $b  im Besitz';
  }

  @override
  String get petTitle => 'GEFÄHRTEN';

  @override
  String get petActiveBonuses => 'AKTIVE BONI (alle besessenen Gefährten)';

  @override
  String get petNoCompanion => 'Kein Gefährte ausgerüstet';

  @override
  String get petEquipHint =>
      'Rüste einen Gefährten aus, damit er im Kampf erscheint.';

  @override
  String get petPremium => '★ PREMIUM';

  @override
  String get petInBattle => 'IM KAMPF';

  @override
  String petRecruitTitle(String name) {
    return '$name rekrutieren?';
  }

  @override
  String get petRecruit => 'REKRUTIEREN';

  @override
  String petEvolveTitle(String name) {
    return '$name entwickeln?';
  }

  @override
  String petEvolveN(Object n) {
    return 'ENTWICKELN  Evo $n';
  }

  @override
  String get petTutorial =>
      'Tier-Gefährten begleiten dich im Kampf und stapeln ihre Boni passiv — auch nicht ausgerüstete. Rüste einen aus, damit er in Kämpfen an deiner Seite erscheint. Entwickle besessene Tiere zweimal, um ihren Bonuswert zu verdoppeln.';

  @override
  String petRecruitBody(String desc, String bonus, Object cost) {
    return '$desc\n\nBonus: $bonus\n\nKosten: $cost Z-Coins';
  }

  @override
  String petEvolveBody(Object level, String bonus, Object cost) {
    return 'Upgrade auf Evolution $level.\n\nNeuer Bonus: +$bonus\nKosten: $cost Z-Coins';
  }

  @override
  String get questTitle => 'QUESTREIHEN';

  @override
  String get questAdventure => 'ABENTEUER-QUESTREIHE';

  @override
  String get questAdventureSub =>
      'Lerne jedes Spielsystem auf dem Weg zu Stufe 100.';

  @override
  String questUnlocksLv30(Object lvl) {
    return 'Freigeschaltet ab Level 30  (aktuell: $lvl)';
  }

  @override
  String get questUltUnlocked => 'ULTIMATIVE FÄHIGKEIT FREIGESCHALTET';

  @override
  String questUltAvailable(String cls) {
    return 'Die Ultimative des $cls ist jetzt im Kampf verfügbar.';
  }

  @override
  String get questProgressLabel => 'Fortschritt';

  @override
  String questCompleteFirst(Object n) {
    return 'Schließe zuerst Quest $n ab, um freizuschalten.';
  }

  @override
  String get questClaimReward => 'BELOHNUNG EINSAMMELN';

  @override
  String get questRewardLabel => 'Belohnung: ';

  @override
  String questClassQuestline(String cls) {
    return '$cls-QUESTREIHE';
  }

  @override
  String get questComplete5 =>
      'Schließe 5 Quests ab, um die Ultimative Fähigkeit freizuschalten.';

  @override
  String get subTitle => 'SPEZIALISIERUNG';

  @override
  String get subLevel50 => 'STUFE-50-SPEZIALISIERUNG';

  @override
  String subChooseBody(String cls, Object cost) {
    return 'Wähle eine Spezialisierung für deinen $cls. Sie gewährt einen mächtigen Krönungsbonus plus Wert-Boni, sofort angewendet. Du kannst sie später für $cost Z-Coins ändern.';
  }

  @override
  String subClassSpecs(String cls, Object n) {
    return '$cls-SPEZIALISIERUNGEN  ($n)';
  }

  @override
  String subUnlocksAt(Object lvl) {
    return 'Spezialisierung wird bei Level $lvl freigeschaltet.';
  }

  @override
  String subChooseTitle(String name) {
    return '$name wählen?';
  }

  @override
  String get subStatBonuses => 'WERT-BONI';

  @override
  String get subCapstone => 'KRÖNUNGS-BONUS';

  @override
  String get subSpecialEffect => 'SPEZIALEFFEKT';

  @override
  String subChangeLater(Object cost) {
    return 'Du kannst dies später für $cost Z-Coins ändern.';
  }

  @override
  String get subCouldNotSet =>
      'Spezialisierung konnte nicht gesetzt werden — versuch es erneut.';

  @override
  String subChangeSpec(Object cost) {
    return 'SPEZIALISIERUNG ÄNDERN  —  $cost Z-Coins';
  }

  @override
  String get subChangeTitle => 'Spezialisierung ändern?';

  @override
  String subChangeBody(Object cost, Object zcoins) {
    return '$cost Z-Coins ausgeben, um deine aktuelle Spezialisierung zu löschen und eine neue zu wählen?\n\nDeine Z-Coins: $zcoins';
  }

  @override
  String get subNotEnough => 'Nicht genug Z-Coins zum Neuverteilen.';

  @override
  String get subActiveSubclass => 'AKTIVE UNTERKLASSE';

  @override
  String get subChosen => 'GEWÄHLT';

  @override
  String get subActive => 'AKTIV';

  @override
  String get subChoosePath => 'DIESEN PFAD WÄHLEN';

  @override
  String get expTitle => 'EXPEDITIONEN';

  @override
  String get expCollectAll => 'ALLE EINSAMMELN';

  @override
  String get expDispatchAll => 'ALLE ENTSENDEN';

  @override
  String get expNoMercs => 'Noch keine Söldner';

  @override
  String get expNoMercsSub =>
      'Rekrutiere Söldner im SÖLDNER-Tab im Helden-Hub, um sie auf Expeditionen zu schicken.';

  @override
  String get expTodayLocations => 'HEUTIGE ORTE';

  @override
  String expRefreshIn(String time) {
    return '🔄 $time';
  }

  @override
  String get expYourParty => 'DEINE GRUPPE';

  @override
  String get expDispatch => 'ENTSENDEN';

  @override
  String get expDone => 'FERTIG';

  @override
  String get expCollectRewards => 'BELOHNUNGEN EINSAMMELN';

  @override
  String get expInProgress => 'IN ARBEIT...';

  @override
  String expReturned(String name) {
    return '$name ist zurückgekehrt!';
  }

  @override
  String get expDiscovery => '✦  ENTDECKUNG';

  @override
  String get expGreat => 'SUPER';

  @override
  String expDispatchMerc(String name) {
    return 'ENTSENDEN $name';
  }

  @override
  String get expChooseLocation => 'ORT WÄHLEN';

  @override
  String get expDuration => 'DAUER';

  @override
  String get expEstRewards => 'GESCHÄTZTE BELOHNUNGEN';

  @override
  String get expSend => 'AUF EXPEDITION SCHICKEN';

  @override
  String get acctSignInFailed => 'Anmeldung abgebrochen oder fehlgeschlagen.';

  @override
  String get acctSignOutTitle => 'Abmelden?';

  @override
  String get acctSignOut => 'Abmelden';

  @override
  String get acctSignOutBody =>
      'Dein lokaler Speicher bleibt erhalten. Die Cloud-Synchronisierung pausiert, bis du dich erneut anmeldest.';

  @override
  String get acctDeleteTitle => 'Konto & Daten löschen?';

  @override
  String get acctDeleteAll => 'ALLES LÖSCHEN';

  @override
  String get acctDeleteBody =>
      'Dies löscht dauerhaft dein Konto und ALLE Daten — jeden Charakter, deinen Cloud-Speicher, deine PvP-Wertung und Bestenlisten-Einträge. Dies kann nicht rückgängig gemacht werden.';

  @override
  String get acctDeleted => 'Konto gelöscht';

  @override
  String get acctDeletedBody =>
      'Dein Konto und alle Daten wurden entfernt. Die App wird jetzt geschlossen.';

  @override
  String get acctClose => 'Schließen';

  @override
  String get acctPlayer => 'Spieler';

  @override
  String get acctSyncNow => 'JETZT SYNCEN';

  @override
  String get acctSignOutBtn => 'ABMELDEN';

  @override
  String get acctSignInGoogle => 'MIT GOOGLE ANMELDEN';

  @override
  String get acctDeleteAccount => 'KONTO LÖSCHEN';

  @override
  String get acctDangerSub =>
      'Lösche dauerhaft dein Konto und alle zugehörigen Daten.';

  @override
  String get acctLinked => 'Google-Konto verknüpft';

  @override
  String get acctNotSynced => 'Diese Sitzung noch nicht synchronisiert';

  @override
  String get acctNoAccount => 'Kein Konto verknüpft';

  @override
  String get acctAboutCloud => 'ÜBER CLOUD-SPEICHER';

  @override
  String get acctCloud1 =>
      'Dein Fortschritt wird automatisch alle 5 Minuten synchronisiert, wenn du angemeldet bist.';

  @override
  String get acctCloud2 =>
      'Spiele auf jedem Windows-Gerät mit demselben Google-Konto.';

  @override
  String get acctCloud3 =>
      'Cloud-Speicher werden sicher mit deinem Google-Konto gespeichert.';

  @override
  String get invhTabGear => 'AUSRÜSTUNG';

  @override
  String get invhTabGems => 'EDELSTEINE';

  @override
  String get invhTabRunes => 'RUNEN';

  @override
  String get invhArcaneDust => 'Arkaner Staub';

  @override
  String invhBag(Object n, Object max) {
    return 'Beutel: $n/$max';
  }

  @override
  String get invhCraftGem => 'EDELSTEIN HERSTELLEN';

  @override
  String invhCraftTypeGem(String type, Object cost) {
    return '$type-EDELSTEIN HERSTELLEN  ($cost Arkaner Staub)';
  }

  @override
  String get invhOwnedGems => 'BESESSENE EDELSTEINE';

  @override
  String invhDismantleBody(String bonus, Object dust) {
    return '$bonus\n\nIn eine WAFFE einsetzen für +SCH%, oder in RÜSTUNG für +WID% des Elements dieses Edelsteins.\n\nZerlegen gibt $dust Arkaner Staub zurück.';
  }

  @override
  String invhDismantle(Object dust) {
    return 'ZERLEGEN (+$dust Arkaner Staub)';
  }

  @override
  String invhGemTooltip(String name, String bonus) {
    return '$name\n$bonus\nTippen zum Zerlegen';
  }

  @override
  String get invhTutGear =>
      'Dein erstes Ausrüstungsstück ist gefallen! Rüste es hier aus, um deine Werte zu steigern.';

  @override
  String get invhTutForge =>
      'Kombiniere zwei Gegenstände desselben Platzes, um ein höherwertiges Stück herzustellen, oder schmiede Werte neu.';

  @override
  String get invhTutRunes =>
      'Stelle Runen für temporäre Kampfboni her. Sammle Staub durch das Verwerten von Ausrüstung.';

  @override
  String get invhTutArtifacts =>
      'Platziere Artefakte im Raster für dauerhafte passive Boni.';

  @override
  String get invhNoGear =>
      'Noch keine Ausrüstung.\nBesiege Gegner, um deinen ersten Gegenstand zu finden!';

  @override
  String get ascTitle => 'AUFSTIEG';

  @override
  String get ascMetaBoard => 'META-BRETT';

  @override
  String ascApPoints(Object points) {
    return '$points AP';
  }

  @override
  String get ascLevelLabel => 'Aufstiegslevel: ';

  @override
  String get ascPrestigeLabel => 'Prestige-Level: ';

  @override
  String get ascBody =>
      'Aufstieg ist der tiefste Reset — er wandelt deine Wiedergeburten in Aufstiegspunkte (AP) um. Du erhältst 1 AP für jede geopferte Wiedergeburt, also je mehr du vor dem Aufstieg ansammelst, desto größer die Auszahlung.\n\nGib AP auf zwei Arten aus — beide dauerhaft und beide überstehen jeden zukünftigen Reset:\n• Das Meta-Brett unten (EP, Gold, Schaden, Idle- & Prestige-Boni)\n• Steige deine Klassenfähigkeiten im Fähigkeiten-Bildschirm auf (+10% Stärke pro Stufe, bis zu 60 AP pro Charakter)\n\nDu BEHÄLTST:  Aufstiegsboni & ausgegebene AP, Artefakte, Mithril, Turm-Splitter, Elementar-Meisterschaft.\nDu VERLIERST:  alle Wiedergeburten, Heldenlevel, Gold, Ausrüstung, Unterklasse, Fähigkeitsränge und Kampagnenfortschritt.';

  @override
  String ascRequires(Object prestige) {
    return 'Erfordert Prestige-Level 5 zum Aufstieg  (aktuell: $prestige/5)';
  }

  @override
  String ascAscendAp(Object ap) {
    return 'AUFSTEIGEN  (+$ap AP)';
  }

  @override
  String get ascConfirmTitle => 'Aufsteigen?';

  @override
  String ascConfirmBody(Object rebirths, Object ap) {
    return 'Opfere $rebirths Wiedergeburt(en) für $ap Aufstiegspunkt(e).\n\nBEHALTEN: Aufstiegsboni, Artefakte, Mithril, Turm-Splitter, Fähigkeits-Aufstiege.\nVERLIEREN: alle Wiedergeburten, Heldenlevel, Gold, Ausrüstung, Unterklasse, Fähigkeitsränge, Kampagnenfortschritt.\n\nDies kann nicht rückgängig gemacht werden.';
  }

  @override
  String get weOmegaShop => 'OMEGA-SHOP';

  @override
  String get weNowHunting => 'JETZT AUF DER JAGD';

  @override
  String get weDamageLabel => 'Schaden: ';

  @override
  String weEndsIn(Object d, Object h, Object m) {
    return 'Event endet in  ${d}T ${h}Std ${m}Min';
  }

  @override
  String get weHowToEarn => 'WIE MAN TOKEN VERDIENT';

  @override
  String weHowToEarnDesc(String name) {
    return '${name}s haben eine 15% Chance, in jedem Kampf zu erscheinen. Besiege sie für je 1–3 Event-Token.';
  }

  @override
  String get weEventBoss => '⚔ EVENT-BOSS';

  @override
  String get weClaimLegendary =>
      'LEGENDÄRE AUSRÜSTUNG EINLÖSEN  (1 🏆 Boss-Token)';

  @override
  String weGearForged(String name, Object lv) {
    return '$name bei Lv$lv geschmiedet! Sieh in deinem Beutel nach.';
  }

  @override
  String weRewardClaimed(String name) {
    return '$name eingelöst!';
  }

  @override
  String get gauLeaderboard => 'Gauntlet-Bestenliste';

  @override
  String get gauRewardPreview => 'BELOHNUNGSVORSCHAU (bei Abschluss)';

  @override
  String get gauAutoRestart => 'AUTO — Neustart mit deinen Modifikatoren—';

  @override
  String get gauBackToGauntlet => 'ZURÜCK ZUM GAUNTLET';

  @override
  String gauWave(Object n, Object total) {
    return 'WELLE $n / $total';
  }

  @override
  String gauKills(Object kills) {
    return '$kills KILLS';
  }

  @override
  String gauEssenceBonus(Object pct) {
    return '+$pct% Essenz';
  }

  @override
  String get brLeaderboard => 'Boss-Rush-Bestenliste';

  @override
  String get brBestScore => 'BESTE PUNKTZAHL: ';

  @override
  String brBossProgress(Object n, Object total) {
    return 'BOSS $n / $total';
  }

  @override
  String get brPlayAgain => 'ERNEUT SPIELEN';

  @override
  String get brPossibleRewards => 'MÖGLICHE BELOHNUNGEN';

  @override
  String get brRewShards => 'Splitter';

  @override
  String get brRewShardsD => '10 pro Boss  ·  +30 bei Komplettabschluss';

  @override
  String get brRewEchoes => 'Echos';

  @override
  String get brRewEchoesD => '6 pro Boss  ·  +25 bei Komplettabschluss';

  @override
  String get brRewZcoins => 'Z-Coins';

  @override
  String get brRewZcoinsD => '15 bei Komplettabschluss';

  @override
  String get brRewMythril => 'Mithril';

  @override
  String get brRewMythrilD => 'Skaliert mit finalem Rang';

  @override
  String get brRewArtifact => 'Artefakt';

  @override
  String get brRewArtifactD => 'Chance-Drop bei A-/S-Rang-Abschlüssen';

  @override
  String get prgShop => 'PARAGON-SHOP';

  @override
  String get prgActiveBonuses => 'AKTIVE BONI';

  @override
  String get prgBoard => '✦ PARAGON-BRETT';

  @override
  String get prgBoardHint =>
      'Investiere Punkte in eine Richtung — Ränge skalieren endlos.';

  @override
  String prgRank(Object rank) {
    return 'Rang $rank';
  }

  @override
  String get prgTutorial =>
      '✦ Paragon-Punkte werden durch Stufenaufstiege verdient — 1 pro Stufe. Gib sie unten auf dem Paragon-Brett und im Shop für dauerhafte Stärke aus, die nie zurückgesetzt wird.';

  @override
  String get prgShopSub =>
      'Gib Paragon-Punkte für dauerhafte Verbesserungen aus, die über alle zukünftigen Läufe bestehen bleiben.';

  @override
  String achClaimedTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🏆  $count ERFOLGE EINGESAMMELT',
      one: '🏆  $count ERFOLG EINGESAMMELT',
    );
    return '$_temp0';
  }

  @override
  String get achYouReceived => 'Du hast erhalten:';

  @override
  String get achNice => 'SUPER!';

  @override
  String achClaimAll(Object n) {
    return 'ALLE EINSAMMELN ($n)';
  }

  @override
  String get achEconomy => 'WIRTSCHAFT & SYSTEME';

  @override
  String get achProgress => 'FORTSCHRITT';

  @override
  String achClaimed(Object claimed, Object total) {
    return '$claimed / $total eingesammelt';
  }

  @override
  String achReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Erfolge bereit zum Einsammeln!',
      one: '$count Erfolg bereit zum Einsammeln!',
    );
    return '$_temp0';
  }

  @override
  String get runeTitle => 'FÄHIGKEITS-RUNEN';

  @override
  String get runeArcaneDust => '🌀 Arkaner Staub: ';

  @override
  String runeOwned(Object a, Object b) {
    return '📜 Besitzt: $a/$b';
  }

  @override
  String get runeNone => 'Keine Runen für diese Klasse verfügbar.';

  @override
  String get runeAppBar => 'RUNEN';

  @override
  String get runeSocketed => 'EINGESETZT';

  @override
  String get runeNotFound =>
      'Noch nicht gefunden — fällt von Bossen, Verliesen, Gauntlet und Expeditionen.';

  @override
  String get runeEquipFirst =>
      'Rüste einen Ring oder ein Amulett aus, um diese Rune einzusetzen.';

  @override
  String runeSocketInto(String name, Object cost) {
    return 'Einsetzen → $name  (🌀 $cost)';
  }

  @override
  String get runeBody =>
      'Setze Runen ein, um deine Fähigkeiten dauerhaft zu verstärken.\nJede Rune verändert eine bestimmte Fähigkeit — verstärkt Schaden, Dauer oder Abklingzeit.\nKostet Arkanen Staub vom Zerlegen von Ausrüstung, Edelsteinen und Runen.';

  @override
  String get achTutorial =>
      'Du hast deinen ersten Boss besiegt! 🏆 Erfolge verfolgen Meilensteine und belohnen mit Z-Coins und Splittern — löse sie hier ein und schau regelmäßig vorbei.';

  @override
  String get bbLocked => 'BOSS-KOPFGELDER GESPERRT';

  @override
  String get bbLockedSub =>
      'Erreiche Kampagnen-Stufe 20, um Bosse für Kopfgeld-Belohnungen zu jagen.';

  @override
  String bbTitle(Object t) {
    return 'BOSS-KOPFGELDER  •  STUFE $t';
  }

  @override
  String get bbDesc =>
      'Erschlage jeden Kampagnen-Boss für sein Kopfgeld. Erreiche eine neue Stufe für einen frischen Satz mit größeren Belohnungen.';

  @override
  String get bbNoBounties => 'Keine Kopfgelder verfügbar.';

  @override
  String bbStageLv(Object n, Object lv) {
    return 'Kampagnen-Stufe $n  •  Lv $lv';
  }

  @override
  String bbSlain(String name, String detail) {
    return '$name erschlagen!  $detail';
  }

  @override
  String bbStage(Object n) {
    return 'Stufe $n';
  }

  @override
  String bbGearReward(String rarity) {
    return '🎁 $rarity-Ausrüstung';
  }

  @override
  String bestTotalKills(Object n) {
    return '$n Kills gesamt';
  }

  @override
  String get bestTypeMaxed => 'TYP MAXIMIERT';

  @override
  String bestGoldBonus(Object pct) {
    return '+$pct% Gold';
  }

  @override
  String get bestKilled => 'getötet';

  @override
  String bestNextDmg(Object n) {
    return 'nächste +1% Schaden bei $n Kills';
  }

  @override
  String get lsTitle => 'TÄGLICHER LOGIN';

  @override
  String get lsComeBack => 'Komm morgen für deine nächste Belohnung wieder!';

  @override
  String lsStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage',
      one: '$count Tag',
    );
    return '$_temp0';
  }

  @override
  String lsClaimReward(String label) {
    return 'EINSAMMELN  $label';
  }

  @override
  String get lsFullCycle => 'VOLLER 30-TAGE-ZYKLUS';

  @override
  String lsDay(Object d) {
    return 'Tag $d';
  }

  @override
  String get lsToday => 'HEUTE';

  @override
  String get dashTitle => 'CHARAKTERBLATT';

  @override
  String get dashDailyReady => 'Tägliche Prüfung bereit zum Einsammeln!';

  @override
  String get dashAbilityAfford =>
      'Fähigkeits-Upgrade leistbar — besuche FÄHIGKEITEN';

  @override
  String get dashPassiveAfford => 'Passiv-Upgrade leistbar — besuche PASSIVE';

  @override
  String get dashEndlessAfford =>
      'Endlos-Upgrade leistbar — besuche VERBESSERUNGEN';

  @override
  String get dashNextAction => 'NÄCHSTE AKTION';

  @override
  String get dashIncomeSummary => 'EINKOMMENSÜBERSICHT';

  @override
  String get dashIdleGold => 'Idle-Gold';

  @override
  String get dashBattleKill => 'Kampf/Kill';

  @override
  String get dashExpeditions => 'Expeditionen';

  @override
  String get dashAchievementsNearby => 'ERFOLGE IN DER NÄHE';

  @override
  String dashDayLoginReward(Object day) {
    return 'TAG $day LOGIN-BELOHNUNG';
  }

  @override
  String dashExpReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Expeditionen bereit zum Einsammeln!',
      one: '$count Expedition bereit zum Einsammeln!',
    );
    return '$_temp0';
  }

  @override
  String dashMercsIdle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Söldner untätig — auf Expedition schicken',
      one: '$count Söldner untätig — auf Expedition schicken',
    );
    return '$_temp0';
  }

  @override
  String get emTitle => 'ELEMENTAR-MEISTERSCHAFT';

  @override
  String emShards(Object n) {
    return '$n Splitter';
  }

  @override
  String get emUp => 'HOCH';

  @override
  String get spResetsMonthly => '📅 Monatlicher Reset';

  @override
  String get spUnlockPremium =>
      'Premium-Pass freischalten — 2× EP + Premium-Track';

  @override
  String get spFree => 'GRATIS';

  @override
  String get spPremium => '👑 PREMIUM';

  @override
  String get spTier => 'Stufe';

  @override
  String spClaimed(Object reward) {
    return '$reward erhalten';
  }

  @override
  String get spAllUnlocked => 'Alle Stufen freigeschaltet — super gemacht!';

  @override
  String spXpToTier(Object xp, Object next, Object tier) {
    return '$xp / $next EP bis Stufe $tier';
  }

  @override
  String spClaimedN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Belohnungen erhalten',
      one: '1 Belohnung erhalten',
    );
    return '$_temp0';
  }

  @override
  String get spNothingToClaim => 'Nichts abzuholen';

  @override
  String get euEchoes => 'Echos';

  @override
  String get euYourBalance => 'Dein Guthaben';

  @override
  String get euEchoesCap => 'ECHOS';

  @override
  String get euTutorial =>
      'Gauntlet-Läufe bringen Echos 🔊 — gib sie hier für permanente Kampf-Upgrades aus, die nie zurückgesetzt werden. Das sind einige der stärksten Boni im Spiel.';

  @override
  String get euPermanent =>
      'Upgrades sind pro Charakter permanent. Boni gelten in allen Spielmodi.';

  @override
  String euForLv(Object n) {
    return 'für Lv $n';
  }

  @override
  String get euActive => 'AKTIV';

  @override
  String get lbRefresh => 'Aktualisieren';

  @override
  String get lbNoScores => 'Noch keine Wertungen — sei der/die Erste!';

  @override
  String get lbPersonalBest => 'Dein persönlicher Bestwert';

  @override
  String get lbRank => 'RANG';

  @override
  String get lbYou => 'DU';

  @override
  String get lbError => 'Bestenliste konnte nicht geladen werden.';

  @override
  String get lbNotRanked => 'Noch nicht platziert';

  @override
  String get cmTitle => 'HERAUSFORDERUNGS-MODIFIKATOREN';

  @override
  String get cmOptionalHandicaps => 'OPTIONALE HANDICAPS';

  @override
  String get cmActive => 'Aktiv: ';

  @override
  String get cmClear => 'LEEREN';

  @override
  String get cmDesc =>
      'Aktiviere vor dem Betreten von Kampagne oder Verlies bis zu einen Modifikator. Modifikatoren machen Kämpfe schwerer, erhöhen aber die Splitter-Belohnung pro Kill.';

  @override
  String cmEssence(Object pct) {
    return '+$pct% Essenz';
  }

  @override
  String cmEnemyHp(Object mult) {
    return 'Gegner HP ×$mult';
  }

  @override
  String cmEnemyAtk(Object mult) {
    return 'Gegner ATK ×$mult';
  }

  @override
  String cmHeroHp(Object mult) {
    return 'Held HP ×$mult';
  }

  @override
  String get wClose => 'SCHLIESSEN';

  @override
  String get battleLog => 'KAMPFPROTOKOLL';

  @override
  String get buffDodge => 'AUSWEICHEN';

  @override
  String get buffStun => 'BETÄUBT';

  @override
  String get dhPowerTip =>
      'Mittelalter-Macht — Gesamtwert all deiner Upgrades,\nAusrüstung, Passiven, Prestige, Artefakte und Verbündeten.';

  @override
  String dhHpTip(Object regen) {
    return 'Lebenspunkte — bei 0 verlierst du den Kampf.\nRegen: $regen HP/Runde';
  }

  @override
  String dhXpTip(Object xp, Object lv, Object next) {
    return 'Erfahrung — erreiche $xp, um aufzusteigen.\nLevel $lv → $next';
  }

  @override
  String get dhNice => 'SUPER';

  @override
  String get bspAbilities => 'FÄHIGKEITEN';

  @override
  String get bspMercs => 'SÖLDNER';

  @override
  String get bspEnemyStun => 'Gegner BETÄUBT';

  @override
  String get bspPassive => 'PASSIV';

  @override
  String bspDescAtk(Object pct) {
    return 'Dein Held verursacht +$pct% Schaden pro Treffer.';
  }

  @override
  String bspDescArmor(Object pct) {
    return '+$pct% Rüstungswert — reduziert eingehenden Gegnerschaden.';
  }

  @override
  String get bspDescDodge =>
      'Dein Held weicht dem nächsten Gegnerangriff vollständig aus.';

  @override
  String bspDescAura(Object hp) {
    return 'Heilungsaura — stellt zu Beginn jeder Runde $hp HP wieder her.';
  }

  @override
  String bspDescDot(Object dmg) {
    return 'Schaden über Zeit — der Gegner erleidet jede Runde $dmg Schaden.';
  }

  @override
  String get bspDescStun =>
      'Der Gegner ist betäubt und setzt seinen Angriff aus.';

  @override
  String get baMercAbility => 'SÖLDNER-FÄHIGKEIT';

  @override
  String get tsCleared => 'GESCHAFFT';

  @override
  String get sgFullyUpgraded => 'VOLL AUSGEBAUT';

  @override
  String sgNeedGold(Object cost) {
    return '$cost Gold zum Verbessern nötig';
  }

  @override
  String get fsVictory => 'SIEG';

  @override
  String get fsDefeat => 'NIEDERLAGE';

  @override
  String fsVs(String enemy, Object rounds) {
    return 'vs $enemy  ·  $rounds Runden';
  }

  @override
  String get fsAbilitiesUsed => 'EINGESETZTE FÄHIGKEITEN';

  @override
  String get wnTitle => 'NEUIGKEITEN';

  @override
  String get wnLatest => 'NEUESTE';

  @override
  String get zcShards => 'Splitter';

  @override
  String get idbNoItem => 'Nichts ausgerüstet — direktes Upgrade!';

  @override
  String get absTitle => 'ATTRIBUTWERTE';

  @override
  String get absBanner =>
      'Attributwerte sind permanente Upgrades, die mit Gold gekauft werden.\nVerbessere jeden Wert frei — Gold ist die einzige Voraussetzung.';

  @override
  String get absMaxed => 'MAX.';

  @override
  String absNext(Object cost) {
    return 'Nächste: $cost Gold';
  }

  @override
  String absRankOf(Object rank, Object max) {
    return 'Rang $rank / $max';
  }

  @override
  String get bestUndiscovered =>
      'Töte diese Kreatur, um ihre Geheimnisse zu enthüllen.';

  @override
  String shopAdOffer(Object n, Object left, Object max) {
    return 'Verdiene $n ZCoins pro Werbung  •  $left/$max übrig';
  }

  @override
  String get shopLifetimeTitle => 'Ewiger Pakt';

  @override
  String get shopLifetimeTagline =>
      'Ein Kauf. Alle Premium-Vorteile. Für immer.';

  @override
  String get shopLifetimeBadge => 'BESTES ANGEBOT';

  @override
  String get shopLifetimeOwned => '✓ FÜR IMMER FREIGESCHALTET';

  @override
  String shopLifetimeBuy(Object price) {
    return 'FÜR IMMER FREISCHALTEN  ·  $price';
  }

  @override
  String get shopLifetimeIncludes => 'ALLES ENTHALTEN';

  @override
  String get shopLifetimePerk1 => 'Alle Vorteile der Aszendenten-Krone';

  @override
  String get shopLifetimePerk2 => '5× Kampfgeschwindigkeit';

  @override
  String get shopLifetimePerk3 => '+100% Ressourcenerzeugung';

  @override
  String get shopLifetimePerk4 => '2× Saisonpass-XP';

  @override
  String get shopLifetimePerk5 => 'Premium-Saisonpass-Belohnungen';

  @override
  String get shopLifetimePerk6 => 'Kampfsimulator-Zugang';

  @override
  String get shopLifetimePerk7 => 'Keine wiederkehrenden Kosten – jemals';

  @override
  String get shopLifetimePerk8 => 'Auto-Kampagne (ab Stufe 5 kostenlos)';

  @override
  String get ratingTitle => 'Gefällt dir Zeta Idle?';

  @override
  String get ratingBody =>
      'Du bist schon eine Weile unterwegs! Wenn du Spaß hast, hilft eine kurze Bewertung dem Spiel enorm. 🙏';

  @override
  String get ratingLove => 'Ich liebe es!';

  @override
  String get ratingMeh => 'Nicht wirklich';
}
