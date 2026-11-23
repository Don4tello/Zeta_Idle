// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get ccForgeYourLegend => 'WYKUJ SWOJĄ LEGENDĘ';

  @override
  String get ccNameYourWarrior => '— NAZWIJ SWOJEGO WOJOWNIKA —';

  @override
  String get ccDefaultHeroName => 'Strażnik';

  @override
  String get ccQuickStart => 'SZYBKI START';

  @override
  String get ccQuickStartHint => 'Wskocz od razu z zalecanym bohaterem';

  @override
  String get ccChooseClassAndRace => 'WYBIERZ KLASĘ I RASĘ';

  @override
  String get ccChooseYourClass => 'WYBIERZ SWOJĄ KLASĘ';

  @override
  String get ccSelectYourPath => '— WYBIERZ SWOJĄ ŚCIEŻKĘ —';

  @override
  String get ccChooseRace => 'WYBIERZ RASĘ';

  @override
  String get ccSelectAClass => 'WYBIERZ KLASĘ';

  @override
  String get ccRecommendedForBeginners => '★ POLECANE DLA POCZĄTKUJĄCYCH';

  @override
  String get ccComplexity => 'ZŁOŻONOŚĆ';

  @override
  String get ccChooseYourRace => 'WYBIERZ SWOJĄ RASĘ';

  @override
  String get ccHeritageDefinesYou => '— TWOJE DZIEDZICTWO CIĘ DEFINIUJE —';

  @override
  String get ccBeginYourJourney => 'ROZPOCZNIJ SWOJĄ PODRÓŻ';

  @override
  String get ccSelectARace => 'WYBIERZ RASĘ';

  @override
  String get ccNameNotAllowed =>
      'Proszę wybrać inną nazwę — ta jest niedozwolona.';

  @override
  String get csSelectCharacter => '— WYBIERZ POSTAĆ —';

  @override
  String get csNewCharacter => 'NOWA POSTAĆ';

  @override
  String get csSwipeToDelete => 'Przesuń postać w lewo, aby ją usunąć';

  @override
  String csDeleteTitle(String name) {
    return 'Usunąć \"$name\"?';
  }

  @override
  String get csDeleteBody =>
      'Jesteś pewien? Po usunięciu nie można go odzyskać.';

  @override
  String get csCancel => 'ANULUJ';

  @override
  String get csDelete => 'USUŃ';

  @override
  String get csLockedSlot => 'ZABLOKOWANY SLOT';

  @override
  String get navHero => 'BOHATER';

  @override
  String get navPlay => 'GRAJ';

  @override
  String get navInventory => 'EKWIPUNEK';

  @override
  String get navShop => 'SKLEP';

  @override
  String get navGuild => 'GILDIA';

  @override
  String get modeCampaign => 'KAMPANIA';

  @override
  String get modeDungeon => 'LOCH';

  @override
  String get modeBossRush => 'BOSS RUSH';

  @override
  String get modeTowerAscension => 'WNIEBOWSTĄPIENIE WIEŻY';

  @override
  String get modeGauntlet => 'GAUNTLET';

  @override
  String get modePvp => 'PVP';

  @override
  String get modeChallenges => 'WYZWANIA';

  @override
  String get modeEvents => 'WYDARZENIA';

  @override
  String get modeExpedition => 'WYPRAWA';

  @override
  String get modeDaily => 'CODZIENNE';

  @override
  String get modeBounties => 'NAGRODY';

  @override
  String get modeQuests => 'ZADANIA';

  @override
  String get badgeNew => 'NOWE';

  @override
  String get lootLog => 'DZIENNIK ŁUPÓW';

  @override
  String get noLootYet => 'Brak łupów — idź się pobić!';

  @override
  String get welcomeBack => 'Witaj ponownie!';

  @override
  String awayFor(String time) {
    return 'Byłeś nieobecny przez $time.';
  }

  @override
  String awayForCapped(int hours) {
    return 'Byłeś nieobecny przez ponad ${hours}h — pokazuję maksymalne nagrody za bezczynność.';
  }

  @override
  String rewardGold(String amount) {
    return '+$amount złota';
  }

  @override
  String rewardXp(String amount) {
    return '+$amount XP';
  }

  @override
  String rewardShards(String amount) {
    return '+$amount odłamków';
  }

  @override
  String expeditionsReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wypraw gotowych!',
      few: '$count wyprawy gotowe!',
      one: '$count wyprawa gotowa!',
    );
    return '$_temp0';
  }

  @override
  String get comebackBonus => 'Bonus powrotu:';

  @override
  String get idleIncomeCollected =>
      'Dochód z bezczynności zebrany podczas odpoczynku.';

  @override
  String get claim => 'ODBIERZ';

  @override
  String get milestone => 'KAMIEŃ MILOWY';

  @override
  String get welcomeBackCaps => 'WITAJ PONOWNIE!';

  @override
  String get missedYou =>
      'Tęskniliśmy za tobą! Oto bonus\nza czas nieobecności:';

  @override
  String get newSystemUnlocked => 'NOWY SYSTEM ODBLOKOWANY';

  @override
  String get gotIt => 'ROZUMIEM';

  @override
  String get welcomeFightTitle => 'Walcz!';

  @override
  String get welcomeFightBody =>
      'Przejdź do zakładki GRA i dotknij karty etapu w KAMPANII, aby rozpocząć pierwszą bitwę. Atakuj, dopóki wróg nie padnie!';

  @override
  String get welcomeIdleTitle => 'Zarabiaj złoto w bezczynności';

  @override
  String get welcomeIdleBody =>
      'Twój bohater automatycznie zarabia złoto co minutę, nawet gdy nie walczysz. Obserwuj, jak pasek złota w zakładce BOHATER się wypełnia.';

  @override
  String get welcomeStrongerTitle => 'Stań się silniejszy';

  @override
  String get welcomeStrongerBody =>
      'Wydawaj złoto w ULEPSZENIACH, aby podnosić statystyki. Otwórz PASYWNE dla trwałych bonusów i UMIEJĘTNOŚCI dla potężnych zdolności bojowych.';

  @override
  String get welcomeExploreTitle => 'Eksploruj';

  @override
  String get welcomeExploreBody =>
      'KAMPANIA postępuje przez 100 ręcznie stworzonych etapów. WNIEBOWSTĄPIENIE WIEŻY pozwala farmować odłamki w nieskończoność. LOCH to run roguelite z upuszczaniem przedmiotów i walkami z bossami. Więcej trybów odblokowuje się w miarę postępu.';

  @override
  String get navBack => 'WSTECZ';

  @override
  String get navNext => 'DALEJ';

  @override
  String get startPlaying => 'ZACZNIJ GRAĆ';

  @override
  String get settingsLanguage => 'Język';

  @override
  String get settingsLanguageSystem => 'Domyślny systemowy';

  @override
  String get commonCancel => 'Anuluj';

  @override
  String get commonContinue => 'KONTYNUUJ';

  @override
  String heroFalls(String name) {
    return '$name PADA';
  }

  @override
  String get battleGrowStronger =>
      'Stań się silniejszy, zanim spróbujesz ponownie.';

  @override
  String get battleBackToHero => 'WRÓĆ DO BOHATERA';

  @override
  String get defeatEndlessTitle => 'TRYB NIESKOŃCZONY';

  @override
  String get defeatEndlessHint => 'Farmuj XP i złoto we własnym tempie';

  @override
  String get defeatDungeonHint => 'Zdobywaj odłamki i przedmioty';

  @override
  String get defeatGauntletHint => 'Zdobywaj echa do ulepszeń';

  @override
  String get defeatDailyTitle => 'CODZIENNE WYZWANIA';

  @override
  String get defeatDailyHint => 'Odbieraj nagrody za postęp';

  @override
  String battleTierUnlocked(int tier) {
    return 'POZIOM $tier ODBLOKOWANY';
  }

  @override
  String get battleCampaignCleared => 'KAMPANIA UKOŃCZONA';

  @override
  String battleTierUnlockedBody(int tier) {
    return 'Omega poległa. Kampania restartuje się na Poziomie $tier — trudniejsi wrogowie i lepsze łupy.\n\nTwój poziom, Paragon, sprzęt i waluty pozostają. Nic się nie resetuje.';
  }

  @override
  String get battleCampaignClearedBody =>
      'Omega poległa na najwyższym poziomie. Osiągnąłeś szczyt — kontynuuj farmowanie łupów i Punktów Paragonu.';

  @override
  String get battleSwitchTiersHint =>
      'Zmieniaj poziomy w dowolnym momencie z nagłówka Kampanii.';

  @override
  String get battleRetreat => 'Odwrót';

  @override
  String get battleLastFightSummary => 'Podsumowanie ostatniej walki';

  @override
  String get battleResume => 'Wznów';

  @override
  String get battlePause => 'Pauza';

  @override
  String get battleAutoCampaignLocked =>
      'Auto-Kampania — Speed Boost / Karnet Premium';

  @override
  String get battleAutoCampaignOn => 'Auto-Kampania: WŁĄCZONA';

  @override
  String get battleAutoCampaignOff => 'Auto-Kampania: WYŁĄCZONA';

  @override
  String get battleNoFightYet => 'Brak ukończonych walk.';

  @override
  String get battleAutoCampaignPerk =>
      'Auto-Kampania to przywilej Speed Boost / Karnetu Premium.';

  @override
  String get battleNoActiveBattle => 'BRAK AKTYWNEJ BITWY';

  @override
  String get battleVictory => 'ZWYCIĘSTWO!';

  @override
  String get battleBossDefeated => 'BOSS POKONANY';

  @override
  String get battleNewContentUnlocked => 'NOWA ZAWARTOŚĆ ODBLOKOWANA';

  @override
  String get battleClassQuestlineUnlocked => 'LINIA QUESTÓW KLASY ODBLOKOWANA';

  @override
  String battleClassQuestlineBody(String className) {
    return 'Ścieżka $className się zaczyna. Ukończ 5 zadań, aby odblokować Umiejętność Ostateczną.';
  }

  @override
  String battleRewardGold(String amount) {
    return '+$amount ZŁOTA';
  }

  @override
  String battleRewardXp(String amount) {
    return '+$amount XP';
  }

  @override
  String battleRewardShards(String amount) {
    return '+$amount ODŁAMKÓW';
  }

  @override
  String battleAbilityUnlocked(String name) {
    return 'UMIEJĘTNOŚĆ ODBLOKOWANA: $name';
  }

  @override
  String get battleAddedToBag => 'Dodano do torby';

  @override
  String get battleFight => 'WALCZ  (−1 ⚡)';

  @override
  String get battleSpeedBoostTitle => '2× Speed Boost';

  @override
  String battleSpeedBoostBody(int cost, int have) {
    return 'Odblokować 2× prędkość bitwy na 7 dni?\n\nKoszt: $cost ZCoins\nTwoje ZCoins: $have';
  }

  @override
  String get battlePurchase => 'Kup';

  @override
  String get battleNotEnoughZcoins => 'Za mało ZCoins!';

  @override
  String get battleArtifactFound => 'ARTEFAKT ZNALEZIONY!';

  @override
  String battleRoundsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rund pozostało',
      few: '$count rundy pozostały',
      one: '$count runda pozostała',
    );
    return '$_temp0';
  }

  @override
  String get commonOk => 'OK';

  @override
  String get campaignDifficultyTier => 'POZIOM TRUDNOŚCI';

  @override
  String get campaignDifficultyTierTooltip => 'Poziom Trudności';

  @override
  String get campaignTierSelectorBody =>
      'Wyższe poziomy = trudniejsi wrogowie I lepsze łupy (rzadkość, sety, artefakty). Przełączenie w dół zachowuje całą twoją stałą moc — skaluje tylko to, z czym walczysz i co upada.';

  @override
  String get campaignTierNormal => 'POZIOM 0 — Normalny';

  @override
  String campaignTierN(int tier) {
    return 'POZIOM $tier';
  }

  @override
  String get campaignTierBaseDesc =>
      'Bazowi wrogowie · bazowe łupy · bez Magii Znajdowania';

  @override
  String campaignTierScaledDesc(int hp, int atk) {
    return 'Wrogowie +$hp% HP · +$atk% ATK';
  }

  @override
  String campaignTierMagicFind(int mf) {
    return '✦ +$mf% Magia Znajdowania (wyższa rzadkość, sety i artefakty)';
  }

  @override
  String get campaignLeaderboardTooltip => 'Ranking Kampanii';

  @override
  String get campaignTutorial =>
      'Kampania postępuje etap po etapie. Pokonaj każdego bossa, aby odblokować kolejny. Pokonaj ostatniego bossa, aby odblokować kolejny Poziom Trudności — kampania restartuje się trudniej z lepszymi łupami, a twoja moc pozostaje.';

  @override
  String campaignEnergyRecharge(String time) {
    return '+1 za $time';
  }

  @override
  String campaignEnergyRefill(int amount, int left) {
    return 'Uzupełnij +$amount  ($left darmowych pozostało)';
  }

  @override
  String get campaignBuy => 'Kup ';

  @override
  String get campaignEnergyEmptyTutorial =>
      'Brak energii! ⚡ Uzupełnia się 1 co 5 min. Dotknij przycisku +10 powyżej dla 3 darmowych dziennych uzupełnień. Lub kup +20 energii za 💎 50 ZCoins.';

  @override
  String get campaignStageMap =>
      'MAPA ETAPÓW  •  dotknij dowolny węzeł ✓, aby powtórzyć';

  @override
  String get campaignNoEnergyRefill =>
      'Brak energii! Poczekaj na uzupełnienie.';

  @override
  String campaignSimulateStage(int stage) {
    return '⚡ Symuluj Etap $stage';
  }

  @override
  String campaignEnergyAvailable(int count) {
    return 'Dostępna energia: $count';
  }

  @override
  String get campaignSimInfo =>
      'Bitwy rozgrywają się natychmiast. Łupy trafiają prosto do torby.';

  @override
  String campaignSimAll(int count) {
    return 'WSZYSTKO ($count)';
  }

  @override
  String campaignSimResultTitle(int stage, int count) {
    return 'Etap $stage — $count× Zasymulowano';
  }

  @override
  String get campaignSimGold => '💰 Złoto';

  @override
  String get campaignSimXp => '✦ XP';

  @override
  String campaignItemsDropped(int count) {
    return 'Upuszczone przedmioty ($count):';
  }

  @override
  String get campaignNoItemsDropped =>
      'Brak upuszczonych przedmiotów w tym runie.';

  @override
  String get campaignNotEnoughEnergy => 'Za mało energii!';

  @override
  String get campaignMapFight => '⚔  WALCZ (−1 ⚡)';

  @override
  String get campaignSimRequiresPremium => 'Wymaga subskrypcji Karnetu Premium';

  @override
  String get campaignBossEncounter => 'SPOTKANIE Z BOSSEM';

  @override
  String get campaignDismiss => '[ zamknij ]';

  @override
  String campaignPerfectStages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count perfekcyjnych etapów',
      few: '$count perfekcyjne etapy',
      one: '$count perfekcyjny etap',
    );
    return '$_temp0';
  }

  @override
  String campaignNextMilestone(int next) {
    return '• następny kamień milowy na $next (+mithryl +Z-Coins)';
  }

  @override
  String get campaignAllMilestones => '• wszystkie kamienie milowe ukończone!';

  @override
  String get hubWhatsNew => 'Co nowego';

  @override
  String get hubLootLog => 'Dziennik łupów';

  @override
  String get hubSettings => 'Ustawienia';

  @override
  String get hubChange => 'ZMIEŃ';

  @override
  String get hubHeroMenu => 'Menu bohatera';

  @override
  String get hubJoinDiscord => 'Dołącz do naszego Discorda';

  @override
  String get hubVisitReddit => 'Odwiedź r/zeta_idle';

  @override
  String hubCouldNotOpen(String url) {
    return 'Nie można otworzyć $url';
  }

  @override
  String get hubLocked => 'Zablokowane';

  @override
  String get hubGroupCharacter => 'POSTAĆ';

  @override
  String get hubGroupProgression => 'POSTĘP';

  @override
  String get hubGroupCollection => 'KOLEKCJA';

  @override
  String get hubGroupRecords => 'REKORDY';

  @override
  String get hubBlurbCharacter => 'Twój build i moc';

  @override
  String get hubBlurbProgression => 'Systemy końcowe';

  @override
  String get hubBlurbCollection => 'Sojusznicy i kompendium';

  @override
  String get hubBlurbRecords => 'Cele i zestawienia';

  @override
  String get hubSheet => 'KARTA';

  @override
  String get hubScores => 'WYNIKI';

  @override
  String get hubAbilities => 'UMIEJĘTNOŚCI';

  @override
  String get hubPassives => 'PASYWNE';

  @override
  String get hubSpecialize => 'SPECJALIZUJ';

  @override
  String get hubParagon => 'PARAGON';

  @override
  String get hubUpgrades => 'ULEPSZENIA';

  @override
  String get hubAscend => 'WNIEBOWSTĄP';

  @override
  String get hubMastery => 'MISTRZOSTWO';

  @override
  String get hubPets => 'ZWIERZĘTA';

  @override
  String get hubMercs => 'NAJEMNICY';

  @override
  String get hubBestiary => 'BESTIARIUSZ';

  @override
  String get hubCodex => 'KODEKS';

  @override
  String get hubArmory => 'ZBROJOWNIA';

  @override
  String get hubAchievements => 'OSIĄGNIĘCIA';

  @override
  String get hubBonuses => 'BONUSY';

  @override
  String get auShards => 'odłamki';

  @override
  String get auRespecTitle => 'Zresetować umiejętności?';

  @override
  String auRespecBody(int cost) {
    return 'Zresetuj wszystkie rangi umiejętności i wybory kamieni milowych.\nWszystkie wydane odłamki zostaną zwrócone.\n\nKoszt: $cost ZCoins';
  }

  @override
  String auRespecConfirm(int cost) {
    return 'RESET ($cost ZC)';
  }

  @override
  String get auRespec => 'RESET';

  @override
  String get auTutorial =>
      'Zdobyłeś Odłamki ◆ — wydaj je tutaj, aby odblokowywać i ulepszać umiejętności klasy, które automatycznie aktywują się w każdej bitwie.';

  @override
  String get auIntro =>
      'Wydawaj odłamki, aby wzmacniać umiejętności. Kamienie milowe na rangach 5, 10 i 15. Awansuj poziom po randze 15 — każdy poziom odblokowuje się z Poziomem Trudności.';

  @override
  String get auTitle => 'ULEPSZENIA UMIEJĘTNOŚCI';

  @override
  String get auMaxTier => 'MAKS. POZIOM  ✦';

  @override
  String auTierLockedLabel(int tier, int req) {
    return 'POZIOM $tier  —  Wymaga Poziomu Trudności $req';
  }

  @override
  String get auAscension => 'WNIEBOWSTĄPIENIE';

  @override
  String auTierUnlocked(int cap) {
    return 'Poziom $cap odblokowany';
  }

  @override
  String auAscFullyAscended(int pct) {
    return 'W pełni wniebowstąpiony  ·  +$pct% mocy umiejętności';
  }

  @override
  String auAscTierLocked(int cur, int next) {
    return '+$cur% mocy  ·  Odblokuj Poziom Trudności $next, aby dalej wniebowstępować';
  }

  @override
  String auAscUpgrade(int cur, int next, int cost) {
    return '+$cur%  →  +$next% mocy  ·  kosztuje $cost ✦ Paragon';
  }

  @override
  String auAscYouHave(int have) {
    return '  (masz $have)';
  }

  @override
  String get auMax => 'MAKS';

  @override
  String get auLocked => 'ZABLOKOWANE';

  @override
  String auAscendBtn(int cost) {
    return 'WNIEBOWSTĄP  $cost ✦';
  }

  @override
  String get auUltimate => 'OSTATECZNA';

  @override
  String auUnlocksLv(int lv) {
    return 'ODBLOKOWUJE LV $lv';
  }

  @override
  String get auFinishQuestline =>
      '🔒 Ukończ linię questów klasy, aby odblokować';

  @override
  String auReachLevel(int lv, int cur) {
    return 'Osiągnij Poziom $lv  (ty: Lv $cur)';
  }

  @override
  String auCompleteQuests(String className, int claimed) {
    return 'Ukończ wszystkie 5 questów $className  ($claimed / 5)';
  }

  @override
  String get auTrackQuests => 'Śledź zadania w zakładce Zadania.';

  @override
  String get auChoose => 'WYBIERZ';

  @override
  String get setTitle => 'USTAWIENIA';

  @override
  String get setSave => 'ZAPISZ';

  @override
  String get setLoad => 'WCZYTAJ';

  @override
  String get setReset => 'RESETUJ';

  @override
  String get setOpen => 'OTWÓRZ';

  @override
  String get setView => 'WYŚWIETL';

  @override
  String get setEmail => 'E-MAIL';

  @override
  String get setConfirm => 'POTWIERDŹ';

  @override
  String get setSecAccount => 'KONTO';

  @override
  String get setSecPromo => 'KOD PROMO';

  @override
  String get setSecAudio => 'AUDIO';

  @override
  String get setSecHaptics => 'HAPTYKA';

  @override
  String get setSecNotifications => 'POWIADOMIENIA';

  @override
  String get setSecDisplay => 'EKRAN';

  @override
  String get setSecStats => 'STATYSTYKI';

  @override
  String get setSecAutoLoot => 'AUTO-ŁUPY';

  @override
  String get setSecBattle => 'BITWA';

  @override
  String get setSecDailyReset => 'CODZIENNY RESET';

  @override
  String get setSecSave => 'ZAPISZ';

  @override
  String get setSecDanger => 'STREFA NIEBEZPIECZNA';

  @override
  String get setSecHelp => 'POMOC';

  @override
  String get setSecAbout => 'O GRZE';

  @override
  String get setManage => 'ZARZĄDZAJ';

  @override
  String get setSignIn => 'ZALOGUJ SIĘ';

  @override
  String get setHeroName => 'Imię Bohatera';

  @override
  String setRename(int cost) {
    return 'ZMIEŃ NAZWĘ ($cost 🪙)';
  }

  @override
  String get setPromoHint =>
      'Masz kod? Zrealizuj go tutaj, aby otrzymać nagrody.';

  @override
  String get setRedeem => 'ZREALIZUJ';

  @override
  String get setSoundEffects => 'Efekty dźwiękowe';

  @override
  String get setBackgroundMusic => 'Muzyka w tle';

  @override
  String get setVolume => 'Głośność';

  @override
  String get setVibration => 'Wibracje';

  @override
  String get setReminders => 'Przypomnienia';

  @override
  String get setDamageNumbers => 'Liczby obrażeń';

  @override
  String get setReducedParticles => 'Zmniejszone cząsteczki';

  @override
  String get setTotalPlaytime => 'Łączny czas gry';

  @override
  String get setAutoSalvage => 'Auto-odzysk';

  @override
  String get setAutoEquip => 'Auto-zakładanie ulepszeń';

  @override
  String get setAutoEquipSub =>
      'Automatycznie zakładaj przedmioty lepsze od obecnego ekwipunku';

  @override
  String get setBattleSpeed => 'Prędkość bitwy';

  @override
  String get setAutoCampaign => 'Auto-kampania';

  @override
  String get setResetTime => 'Czas resetu';

  @override
  String get setCloudSave => 'Zapis w chmurze';

  @override
  String get setCloudSaveSub => 'Synchronizuj postęp z chmurą';

  @override
  String get setCloudSaveComplete => 'Zapis w chmurze zakończony.';

  @override
  String get setLoadCloud => 'Wczytaj z chmury';

  @override
  String get setLoadCloudSub => 'Nadpisz lokalny zapis danymi z chmury';

  @override
  String get setResetProgress => 'Zresetuj postęp';

  @override
  String get setResetProgressSub =>
      'Usuń wszystkie dane zapisu dla tego slotu. Nieodwracalne.';

  @override
  String get setKnowledgeBase => 'Baza wiedzy';

  @override
  String get setKnowledgeBaseSub =>
      'Objaśnienie słów kluczowych, systemów i walut';

  @override
  String get setTagline => 'Mroczne średniowieczne RPG idle.';

  @override
  String get setAboutHero => 'Bohater';

  @override
  String get setAboutClass => 'Klasa';

  @override
  String get setAboutLevel => 'Poziom';

  @override
  String get setAboutPrestige => 'Prestiż';

  @override
  String get setAboutAchievements => 'Osiągnięcia';

  @override
  String get setAboutDeveloper => 'Deweloper';

  @override
  String get setAboutContact => 'Kontakt';

  @override
  String get setPrivacy => 'Polityka prywatności';

  @override
  String get setPrivacySub => 'Jak przetwarzamy Twoje dane';

  @override
  String get setReportBug => 'Zgłoś błąd / Prześlij opinię';

  @override
  String get setReportBugSub =>
      'Wyślij e-mail — informacje o urządzeniu są dodawane automatycznie';

  @override
  String get setReplayTips => 'Powtórz wskazówki';

  @override
  String get setReplayTipsSub => 'Pokaż ponownie wskazówki z samouczka';

  @override
  String get setTipsReset =>
      'Wskazówki z samouczka zresetowane — pojawią się ponownie podczas eksploracji.';

  @override
  String get setRenameHeroTitle => 'ZMIEŃ IMIĘ BOHATERA';

  @override
  String get setHeroNameHint => 'Wpisz imię bohatera';

  @override
  String setRenameCost(int cost, int have) {
    return 'Koszt: $cost 🪙   (masz $have)';
  }

  @override
  String setRenameNotEnough(int cost) {
    return 'Za mało Z-Coins — zmiana nazwy kosztuje $cost 🪙.';
  }

  @override
  String get setNoEmailApp =>
      'Nie znaleziono aplikacji e-mail. Skontaktuj się z nami pod adresem razorintegrations@gmail.com';

  @override
  String get setDailyResetTitle => 'Czas codziennego resetu';

  @override
  String get setDailyResetHint =>
      'Wybierz godzinę, o której resetują się limity dzienne.';

  @override
  String get setDailyResetWarning =>
      'Uwaga: możesz to zmienić tylko raz w roku.';

  @override
  String get setLoadCloudTitle => 'Wczytać z chmury?';

  @override
  String get setLoadCloudBody =>
      'To zastąpi lokalny zapis danymi z chmury. Lokalny postęp, który nie został zsynchronizowany, zostanie utracony.';

  @override
  String get setResetAllTitle => 'Zresetować wszystkie postępy?';

  @override
  String get setResetAllBody =>
      'Wszystkie postępy, złoto, przedmioty, poziomy prestiżu i osiągnięcia zostaną trwale usunięte. Tej operacji nie można cofnąć.';

  @override
  String get setNewHeroName => 'Nowe imię bohatera:';

  @override
  String get setGoogleAccount => 'Konto Google';

  @override
  String get setSignInGoogle => 'Zaloguj się przez Google';

  @override
  String get setSignedIn => 'Zalogowano';

  @override
  String get setSyncSaves => 'Synchronizuj zapisy na różnych urządzeniach';

  @override
  String get setEnterCode => 'WPROWADŹ KOD';

  @override
  String get setOff => 'Wyłączone';

  @override
  String get setOffCaps => 'WYŁĄCZONE';

  @override
  String get setHidden => 'Ukryte';

  @override
  String get setVibrationOn =>
      'Wibruje przy krytach, awansach, zwycięstwach i nagrodach';

  @override
  String get setRemindersOn =>
      'Otrzymuj przypomnienia \"wróć\" podczas nieobecności';

  @override
  String get setDamageOn => 'Liczby pływające wyświetlane w bitwie';

  @override
  String get setParticlesOn => 'Mniej efektów tła (lepsza wydajność)';

  @override
  String get setParticlesOff => 'Pełne efekty';

  @override
  String get setSalvageOff =>
      'Dotknij, aby włączyć auto-odzysk upuszczonych przedmiotów';

  @override
  String setSalvageOn(String tier) {
    return 'Auto-odzysk $tier i niżej';
  }

  @override
  String get setAutoCampaignOnSub => 'Automatycznie tocz bitwy kampanii w tle';

  @override
  String get setAutoCampaignLockedSub =>
      '🔒 Tylko dla subskrybentów Speed Boost / Karnetu Premium';

  @override
  String setResetTimeOn(String time) {
    return 'Limity dzienne resetują się o $time. Dotknij, aby zmienić (raz w roku).';
  }

  @override
  String setResetTimeLocked(String time) {
    return 'Resetuje o $time · Już zmieniono w tym roku.';
  }

  @override
  String get guildTitle => 'GILDIA';

  @override
  String get guildJoinTitle => 'DOŁĄCZ DO GILDII';

  @override
  String get guildJoinBlurb =>
      'Gildie zapewniają pasywne bonusy, cotygodniowe wyzwanie z bossem i sklep gildii z ekskluzywnymi nagrodami.';

  @override
  String get guildCreate => 'UTWÓRZ GILDIĘ';

  @override
  String get guildPublic => 'PUBLICZNE GILDIE';

  @override
  String get guildNoGuilds =>
      'Nie znaleziono gildii. Bądź pierwszym, który ją założy!';

  @override
  String get guildCreateTitle => 'Utwórz gildię';

  @override
  String get guildNameLabel => 'Nazwa gildii';

  @override
  String get guildDescLabel => 'Opis (opcjonalnie)';

  @override
  String get guildCreateBtn => 'UTWÓRZ';

  @override
  String get guildTabInfo => 'INFO';

  @override
  String get guildTabCastle => 'ZAMEK';

  @override
  String get guildTabBoss => 'BOSS';

  @override
  String get guildTabWar => 'WOJNA';

  @override
  String get guildTabChat => 'CZAT';

  @override
  String get guildTabShop => 'SKLEP';

  @override
  String guildCastleTier(int tier) {
    return 'ZAMEK — POZIOM $tier / 10';
  }

  @override
  String guildProgressTier(int tier) {
    return 'Postęp do Poziomu $tier';
  }

  @override
  String guildCpProgress(int cp, int cap) {
    return '$cp / $cap PB';
  }

  @override
  String guildNext(String headline) {
    return 'Następny: $headline';
  }

  @override
  String get guildCitadelComplete =>
      'Cytadela ukończona — zamek jest w pełni zbudowany!';

  @override
  String get guildContributeGold => 'PRZEKAŻ ZŁOTO';

  @override
  String guildContributeInfo(String rate, int cap) {
    return 'Przelicz złoto na Punkty Budowy (PB). Kurs: $rate złota = 1 PB. Możesz dodać do $cap PB dziennie.';
  }

  @override
  String get guildActiveBenefits => 'AKTYWNE KORZYŚCI ZAMKU';

  @override
  String get guildContributeHint =>
      'Przekazuj zasoby, aby wznosić zamek i odblokowywać korzyści.';

  @override
  String guildCastleAdvanced(int tier) {
    return '🏰 Zamek awansował do Poziomu $tier!';
  }

  @override
  String get guildCapReached => 'Dzienny limit budowy osiągnięty — wróć jutro!';

  @override
  String guildLevelMembers(int lvl, int m, int max) {
    return 'Poziom $lvl  •  $m/$max członków';
  }

  @override
  String guildBonusGold(int pct) {
    return '+$pct% złota';
  }

  @override
  String guildBonusXp(int pct) {
    return '+$pct% XP';
  }

  @override
  String guildBonusIdle(int pct) {
    return '+$pct% bezczynności';
  }

  @override
  String guildXpProgress(int xp, int max) {
    return '$xp/$max XP';
  }

  @override
  String get guildDonate1000 => 'PRZEKAŻ 1000 ZŁOTA';

  @override
  String get guildDonateReward => '→ XP gildii + 🪙';

  @override
  String get guildPerks => 'PRZYWILEJE';

  @override
  String guildLockedPerk(int lvl, String name, String desc) {
    return '🔒 Lv$lvl: $name — $desc';
  }

  @override
  String get guildMembers => 'CZŁONKOWIE';

  @override
  String guildMemberLine(int lvl, String cls, String role, int d) {
    return 'Lv$lvl $cls  •  $role  •  przekazano: ${d}g';
  }

  @override
  String get guildLeave => 'OPUŚĆ GILDIĘ';

  @override
  String get guildNoBoss => 'Brak bossa w tym tygodniu.';

  @override
  String get guildWeeklyBoss => '☠ TYGODNIOWY BOSS GILDII';

  @override
  String guildBossHp(int hp, int max) {
    return '$hp / $max HP';
  }

  @override
  String get guildDefeated => '✓ POKONANY';

  @override
  String guildBossRewardMsg(Object rank, Object gc, Object gold) {
    return '🏆 Boss z zeszłego tygodnia: Rank #$rank — +$gc Monet gildii, +$gold złota';
  }

  @override
  String get guildClaimBossReward =>
      '🏆 ODBIERZ NAGRODĘ ZA BOSSA Z ZESZŁEGO TYGODNIA';

  @override
  String guildAttempts(int rem, int max) {
    return 'Próby: $rem / $max';
  }

  @override
  String get guildNoAttempts => 'BRAK POZOSTAŁYCH PRÓB';

  @override
  String get guildChallengeBoss => '⚔ WYZWIJ BOSSA';

  @override
  String get guildDamageRanking => 'RANKING OBRAŻEŃ';

  @override
  String guildDmg(int dmg) {
    return '$dmg obrażeń';
  }

  @override
  String get guildWarStandings => 'KLASYFIKACJA WOJENNA';

  @override
  String guildWarRecord(int w, int l) {
    return 'Twój rekord: ${w}W–${l}P';
  }

  @override
  String get guildWeeklyWar => 'Tygodniowa Wojna Gildii';

  @override
  String get guildWarBlurb =>
      'Zaciągaj się podczas Przygotowań (pon–wt). Śr–pt wydawaj Ataki Wojenne, walcząc z rywalami i zdobywając punkty dla swojej gildii. Sob–nd odbieraj nagrody rankingowe.';

  @override
  String get guildEnlistedBattle =>
      '⚔ Zaciągnięto! Teraz wydaj swoje Ataki Wojenne.';

  @override
  String get guildEnlistedPrep => '⚔ Zaciągnięto! Wróć w śr–pt, aby walczyć.';

  @override
  String get guildEnlist => 'ZACIĄGNIJ SWOJĄ GILDIĘ';

  @override
  String get guildWarEndedWait =>
      'WOJNA ZAKOŃCZONA — CZEKAJ NA NASTĘPNY TYDZIEŃ';

  @override
  String guildScoreYou(String name) {
    return '$name (ty)';
  }

  @override
  String get guildLeads => '🏆 Twoja gildia prowadzi!';

  @override
  String get guildBehind => '⚠ Twoja gildia jest z tyłu — walcz!';

  @override
  String guildFightForGuild(int c, int max) {
    return '⚔ WALCZ DLA GILDII  ($c/$max)';
  }

  @override
  String get guildNoWarAttacks => 'BRAK ATAKÓW WOJENNYCH NA DZIŚ';

  @override
  String get guildWarRefresh =>
      'Ataki Wojenne odnawiają się codziennie podczas fazy Bitwy.';

  @override
  String get guildWarVictory => '🏆 Zwycięstwo!';

  @override
  String get guildWarOver => 'Wojna zakończona.';

  @override
  String guildWarRewardMsg(String result, Object gc, Object gold) {
    return '$result +$gc Monet gildii, +$gold złota';
  }

  @override
  String get guildRewardsClaimed => 'NAGRODY ODEBRANE';

  @override
  String get guildClaimWarRewards => 'ODBIERZ NAGRODY WOJENNE';

  @override
  String get guildWarBattleSoon =>
      'Bitwa zaczyna się w środę — wróć, aby walczyć!';

  @override
  String get guildCoinsLabel => 'Monety gildii';

  @override
  String guildListLine(int lvl, int m, int max) {
    return 'Lv$lvl  •  $m/$max członków';
  }

  @override
  String get guildJoin => 'DOŁĄCZ';

  @override
  String get guildFull => 'PEŁNA';

  @override
  String get guildBossTitle => 'BOSS GILDII';

  @override
  String get guildBossWin => '✦ BOSS POKONANY!';

  @override
  String get guildBossLose => '💀 POLEGŁ';

  @override
  String guildTotalDamage(int d) {
    return 'Łączne zadane obrażenia: $d';
  }

  @override
  String get guildReturn => 'WRÓĆ DO GILDII';

  @override
  String guildCpAmount(int cp) {
    return '+$cp PB';
  }

  @override
  String guildGoldCost(String gold) {
    return '${gold}g';
  }

  @override
  String get forgeSalvageTooltip =>
      'Zniszcz przedmioty, aby odzyskać Odłamki (◆).\n• Pospolity → 3 ◆\n• Rzadki → 8 ◆\n• Epicki → 20 ◆\n• Legendarny → 60 ◆\n• Set → 100 ◆';

  @override
  String get forgeUpgradeTooltip =>
      'Ulepsz przedmiot od +0 do +10.\nKażdy poziom zwiększa wszystkie statystyki o 8%.\nPrzy +5 i +10 przedmiot zyskuje prefiks tytułu.\nKosztuje złoto + odłamki za poziom.';

  @override
  String get forgeTitle => 'KUŹNIA';

  @override
  String get forgeSalvage => 'ODZYSKAJ';

  @override
  String get forgeUpgrade => 'ULEPSZ';

  @override
  String get forgeSlot => 'SLOT';

  @override
  String get forgeFrom => 'OD  ';

  @override
  String forgeForged(String name, String label) {
    return 'Wykuto: $name ($label)!';
  }

  @override
  String get forgeSalvageRates => 'STAWKI ODZYSKU';

  @override
  String forgeSalvageBtn(int n, int s) {
    return 'ODZYSKAJ  $n  (+$s ◆)';
  }

  @override
  String get forgeBagEmpty => 'Twoja torba jest pusta.';

  @override
  String forgeBag(int n) {
    return 'TORBA  ($n przedmiotów)';
  }

  @override
  String forgeSalvaged(int earned) {
    return 'Odzyskano: +$earned ◆';
  }

  @override
  String forgeTimesN(int n) {
    return ' ×$n';
  }

  @override
  String get forgeTimesRandom => '  ×1 (losowo)';

  @override
  String get forgeMasterForger => 'Mistrz Kowal';

  @override
  String get forgeSelected => 'WYBRANE';

  @override
  String forgeSelectedCount(int selected, int needed) {
    return '$selected / $needed';
  }

  @override
  String get forgeArcaneDust => 'ARKAŃSKI PYŁ';

  @override
  String get forgeGemType => 'TYP KLEJNOTU';

  @override
  String forgeGemWeaponDesc(Object pct, String type) {
    return '⚔ Broń: +$pct% obrażeń $type';
  }

  @override
  String forgeGemArmorDesc(Object pct, String type) {
    return '🛡 Zbroja: +$pct% odporności $type';
  }

  @override
  String get forgeTier => 'POZIOM';

  @override
  String forgeGemBagFull(int n, int max) {
    return 'TORBA NA KLEJNOTY PEŁNA ($n/$max)';
  }

  @override
  String forgeNeedMore(int n) {
    return 'POTRZEBA $n WIĘCEJ 💠';
  }

  @override
  String forgeCraft(int cost) {
    return '✦  WYTWORZ  $cost 💠';
  }

  @override
  String forgePreviewWeapon(String effect) {
    return '⚔ Broń: $effect';
  }

  @override
  String forgePreviewArmor(String effect) {
    return '🛡 Zbroja: $effect';
  }

  @override
  String forgeToCraft(int cost) {
    return '$cost 💠 do wytworzenia';
  }

  @override
  String forgeGemBag(int n, int max) {
    return 'TORBA NA KLEJNOTY  ($n/$max)';
  }

  @override
  String get forgeTapGem => 'Dotknij klejnot, aby osadzić go w przedmiocie';

  @override
  String get forgeNoGems =>
      'Brak wytworzonych klejnotów. Wytwórz jeden powyżej!';

  @override
  String get forgeHowGems => 'JAK DZIAŁAJĄ KLEJNOTY';

  @override
  String get forgeGemsInfo =>
      '• Każdy klejnot ma dwa zastosowania — TEN SAM klejnot daje obrażenia żywiołu w broni lub odporność na żywioł w zbroi / biżuterii.\n• Odłamki klejnotów upuszczają się z zabitych wrogów (25% szans) i bossów.\n• Każdy przedmiot może mieć 1 klejnot w swoim gnieździe.\n• Osadzaj klejnoty z tej torby lub przez ekran Ekwipunku.\n• Zastąpienie lub usunięcie klejnotu niszczy stary.';

  @override
  String get forgeNoItemsSocket => 'Brak przedmiotów do osadzenia.';

  @override
  String forgeSocketGem(String name) {
    return 'Osadź $name';
  }

  @override
  String get forgeChooseItem =>
      'Wybierz przedmiot, w którym osadzić ten klejnot.';

  @override
  String get forgeReplaceGem => 'Zastąpić klejnot?';

  @override
  String forgeReplaceBody(String old, String gnew) {
    return '$old zostanie zniszczony i zastąpiony przez $gnew. Tej operacji nie można cofnąć.';
  }

  @override
  String get forgeReplace => 'ZASTĄP';

  @override
  String get forgeUpgradeInfo =>
      'Ulepszaj przedmioty od +0 do +10. Każdy poziom zwiększa wszystkie statystyki o 8%.\nPrzy +5 przedmiot otrzymuje prefiks Rafinowany.\nPrzy +10 staje się Mistrzowskim.';

  @override
  String get forgeBalance => 'Saldo: ';

  @override
  String get forgeNoUpgradeItems =>
      'Brak przedmiotów do ulepszenia.\nWszystkie przedmioty są na +10 lub torba jest pusta.';

  @override
  String get forgeSelectItem => 'WYBIERZ PRZEDMIOT';

  @override
  String get forgeAllStats => 'Wszystkie statystyki +8%';

  @override
  String get forgeWeaponDmgSuffix => '  •  Obrażenia bronią +8%';

  @override
  String get forgeRefinedPrefix => '🏷 Zyskuje prefiks \"Rafinowany\" przy +5!';

  @override
  String get forgeMasterworkPrefix =>
      '🏷 Zyskuje prefiks \"Mistrzowski\" przy +10!';

  @override
  String forgeUpgradeTo(int tier) {
    return 'ULEPSZ DO +$tier';
  }

  @override
  String get dngTitle => 'LOCH';

  @override
  String dngTitleRun(int tier, int floor) {
    return 'P$tier  PO.$floor  —  LOCH';
  }

  @override
  String get dngFlee => 'Ucieknij z lochu';

  @override
  String get dngAutoOn =>
      'Auto Run: WŁĄCZONY — dotknij, aby przejąć ręczną kontrolę';

  @override
  String get dngAutoOff =>
      'Auto Run: WYŁĄCZONY — dotknij, aby automatycznie wyczyścić';

  @override
  String get dngAutoPremium => 'Auto Run (odblokowywane na Etapie 5)';

  @override
  String get dngPushOnTip =>
      'Napór Otchłani: WŁĄCZONY — pokonaj Pana Lochu, aby zejść głębiej';

  @override
  String get dngPushOffTip =>
      'Napór Otchłani: WYŁĄCZONY — run kończy się na oczyszczonej podłodze';

  @override
  String get dngPushOnMsg =>
      'Napór Otchłani WŁĄCZONY — oczyść Pana Lochu, aby zejść na eskalujące podłogi otchłani (bogatszy mithryl + unikalne szanse). Uciekaj w dowolnym momencie, aby zachować postęp.';

  @override
  String get dngPushOffMsg =>
      'Napór Otchłani WYŁĄCZONY — run kończy się po oczyszczeniu Pana Lochu.';

  @override
  String get dngLeaderboard => 'Ranking Lochu';

  @override
  String get dngAutoPremiumMsg =>
      'Auto Run odblokowuje się na Etapie 5 kampanii.';

  @override
  String get dngTutorial =>
      'Wybieraj jedne z dwóch drzwi na każdej podłodze. Zabici wrogowie upuszczają Kości — wydaj je u Wędrującego Kupca na ulepszenia na czas runu. Łupy są twoje natychmiast, nawet jeśli bohater polegnie.';

  @override
  String get dngWhatToExpect => 'CZEGO SIĘ SPODZIEWAĆ';

  @override
  String get dngExpCombat => 'Walka — walcz o złoto';

  @override
  String get dngExpElite =>
      'Elita — twardszy wróg, gwarantowane upuszczenie przedmiotu';

  @override
  String get dngExpAmbush => 'Zasadzka — wróg uderza pierwszy, dużo złota';

  @override
  String get dngExpRest => 'Miejsce odpoczynku — odzyskaj 20% HP';

  @override
  String get dngExpTreasure => 'Skarb — zdobądź złoto i odłamki';

  @override
  String get dngExpShrine => 'Sanktuarium — wybierz trwałe błogosławieństwo';

  @override
  String get dngExpChest =>
      'Zamknięta skrzynia — wydaj odłamki na rzadki przedmiot';

  @override
  String get dngExpTrap => 'Pułapka — nieuniknione obrażenia';

  @override
  String get dngExpBoss =>
      'Boss (co 5. podłoga) — wysokie ryzyko, wysoka nagroda';

  @override
  String get dngBonesHint =>
      'Zabici wrogowie upuszczają Kości — wydaj je u Wędrującego Kupca.';

  @override
  String get dngExpectedLoot => 'SPODZIEWANE ŁUPY';

  @override
  String get dngLootGold => 'Złoto';

  @override
  String get dngLootGoldDetail => 'Z walki, sal skarbów i zapasów odpoczynku';

  @override
  String get dngLootShards => 'Odłamki';

  @override
  String get dngLootShardsDetail => 'Sale skarbów i skrzynie podczas runu';

  @override
  String get dngLootItems => 'Przedmioty';

  @override
  String dngLootItemsDetail(String tier) {
    return 'Poziom przedmiotów na twojej głębokości: $tier  (elity i bossowie upuszczają lepsze)';
  }

  @override
  String get dngLootMythril => 'Mithryl';

  @override
  String dngLootMythrilDetail(int a, int b) {
    return '~$a na podłodze 5  •  ~$b na podłodze 10';
  }

  @override
  String dngYourBest(int f, int m) {
    return 'Twój rekord: podłoga $f  •  ~$m mithryl';
  }

  @override
  String get dngNoRecord => 'Brak rekordu';

  @override
  String dngDeepestFloor(int f) {
    return 'Najgłębsza podłoga: $f';
  }

  @override
  String dngDailyAttempts(int r, int max) {
    return 'Dzienne próby: $r / $max';
  }

  @override
  String dngEnterTier(int tier) {
    return 'WEJDŹ  POZIOM $tier';
  }

  @override
  String get dngNoAttempts => 'BRAK POZOSTAŁYCH PRÓB';

  @override
  String dngBuyExtra(int cost) {
    return '$cost ZCoins — Kup 1 dodatkową próbę';
  }

  @override
  String get dngBossFloor => '☠ PODŁOGA BOSSA';

  @override
  String dngBossIn(int n) {
    return '☠ Boss za $n';
  }

  @override
  String get dngChoosePath => 'WYBIERZ SWOJĄ ŚCIEŻKĘ';

  @override
  String get dngNextBoss => '☠ NASTĘPNA PODŁOGA: BOSS';

  @override
  String get dngMystery => 'TAJEMNICA';

  @override
  String get dngGoblin => '💰 GOBLIN SKARBÓW';

  @override
  String get dngEnter => 'WEJDŹ';

  @override
  String get dngMystery1 => 'Nieoznaczone drzwi.';

  @override
  String get dngMystery2 => 'Szczęście czy niebezpieczeństwo?';

  @override
  String dngGoblinHp(Object hp) {
    return '$hp HP  •  ucieka po 5 rundach';
  }

  @override
  String get dngGoblinReward => '6× złota, jeśli zdążysz go zabić!';

  @override
  String get dngGuaranteedDrop => 'Gwarantowane upuszczenie przedmiotu';

  @override
  String get dngStrikesFirst => 'Uderza pierwszy — dużo złota';

  @override
  String get dngDoorBlessing => 'Błogosławieństwo...';

  @override
  String get dngDoorCurse => 'czy przekleństwo?';

  @override
  String get dngMakeCamp => 'Rozbij obóz';

  @override
  String get dngRecoverHp => 'Odzyskaj HP';

  @override
  String get dngRareInside => 'Rzadki przedmiot w środku';

  @override
  String dngShardsToOpen(Object n) {
    return '$n odłamków, aby otworzyć';
  }

  @override
  String dngPlusGold(Object g) {
    return '+$g złota';
  }

  @override
  String dngPlusShards(Object s) {
    return '+$s odłamków';
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
  String get dngEnemy => 'Wróg';

  @override
  String get dngSpeedNeeds =>
      'Wyższa prędkość wymaga Speed Boost / Karnetu Premium.';

  @override
  String get dngTreasureFound => 'Znaleziono skarb!';

  @override
  String get dngCursed => '✸ PRZEKLĘTY!';

  @override
  String get dngBlessed => '✧ POBŁOGOSŁAWIONY!';

  @override
  String get dngDarkToll => 'Ciemność pobiera swoje opłaty...';

  @override
  String get dngAncientPower => 'Starożytna moc przepływa przez ciebie.';

  @override
  String get dngLightShadow => 'Światło i cień wiążą się z twoim losem.';

  @override
  String get dngShrineCorrupted => 'Skażone Sanktuarium';

  @override
  String get dngShrineBlessed => 'Błogosławione Sanktuarium';

  @override
  String get dngShrineAncient => 'Starożytne Sanktuarium';

  @override
  String get dngShrineCorruptedFlavor =>
      'Mroczne energie pulsują i kłębią się. Przekleństwo jest pewne — ale moc czeka.';

  @override
  String get dngShrineBlessedFlavor =>
      'Z tego miejsca emanuje ciepłe boskie światło. Błogosławieństwo jest gwarantowane.';

  @override
  String get dngShrineTwinFlavor =>
      'Dwie siły poruszają się wewnątrz — otrzymasz zarówno błogosławieństwo, jak i przekleństwo.';

  @override
  String get dngShrineNormalFlavor =>
      'Tajemnicze sanktuarium pulsuje nieznaną energią.\nWejdź, aby otrzymać błogosławieństwo... lub przekleństwo.\nNie dowiesz się które, dopóki nie będzie za późno.';

  @override
  String get dngAcceptCurse => 'PRZYJMIJ PRZEKLEŃSTWO';

  @override
  String get dngReceiveBlessing => 'OTRZYMAJ BŁOGOSŁAWIEŃSTWO';

  @override
  String get dngEnterTwin => 'WEJDŹ  (2 EFEKTY)';

  @override
  String get dngEnterShrine => 'WEJDŹ DO SANKTUARIUM';

  @override
  String dngActiveEffects(int n) {
    return 'Aktywne efekty: $n';
  }

  @override
  String get dngSkip => 'POMIŃ';

  @override
  String dngGuaranteeBless(int c) {
    return '✧  GWARANTUJ BŁOGOSŁAWIEŃSTWO  ($c ◆)';
  }

  @override
  String dngTrapDamage(int dmg, int pct) {
    return 'Otrzymasz $dmg obrażeń ($pct% maksymalnego HP).';
  }

  @override
  String get dngLockedChest => 'Zamknięta skrzynia';

  @override
  String get dngChestContains => 'Zawiera rzadki lub epicki przedmiot.';

  @override
  String dngCostShards(Object cost) {
    return '$cost odłamków';
  }

  @override
  String dngHave(int n) {
    return '(masz $n)';
  }

  @override
  String dngCostZcoins(int cost) {
    return '$cost ZCoins';
  }

  @override
  String get dngMerchantQuote =>
      '\"Kości za błyskotki, wędrowcze. Więcej kości, lepszy towar.\"';

  @override
  String dngBones(int n) {
    return '🦴  $n Kości';
  }

  @override
  String dngBoneCost(int c) {
    return '$c 🦴';
  }

  @override
  String get dngClaimRelic => '☠ BOSS ZABITY — ZDOBĄDŹ RELIKWIĘ';

  @override
  String get dngSkipDescend => 'POMIŃ — ZEJDŹ';

  @override
  String get dngReturn => 'WRÓĆ';

  @override
  String dngDescendTo(int n) {
    return 'ZEJDŹ DO PODŁOGI $n';
  }

  @override
  String get dngFallen => '☠ Poległy';

  @override
  String get dngGotAway => '💰 Uciekł!';

  @override
  String get dngVictory => '✓ Zwycięstwo';

  @override
  String dngAmbushHit(int n) {
    return 'Uderzenie zasadzki zadało $n przed walką.';
  }

  @override
  String dngItemToBag(String name, String label) {
    return '✦ $name ($label) → Torba';
  }

  @override
  String get dngRested => '⊕ Odpoczął';

  @override
  String get dngTreasureCollected => '✦ Skarb zebrany';

  @override
  String get dngBlessingReceived => '✧ Błogosławieństwo otrzymane';

  @override
  String get dngSlainTrap => '☠ Zabity przez pułapkę';

  @override
  String get dngTrapSurvived => '✸ Pułapka przeżyta';

  @override
  String get dngChestOpened => '◆ Skrzynia otwarta';

  @override
  String get dngLootAdded => 'Twoje łupy zostały już dodane do twojego konta.';

  @override
  String dngLordFallen(int z, int g) {
    return 'Pan Lochu poległ!\n+5 mithryl  •  +$z Z-Coins  •  +$g złota  •  przedmiot bonusowy';
  }

  @override
  String dngTierN(int t) {
    return 'POZIOM $t';
  }

  @override
  String get dngFloor => 'PODŁOGA';

  @override
  String get dngRooms => 'POKOJE';

  @override
  String get dngBosses => 'BOSSOWIE';

  @override
  String get dngGold => 'ZŁOTO';

  @override
  String get dngShards => 'ODŁAMKI';

  @override
  String dngTierCleared(int t) {
    return '✓ Poziom $t oczyszczony — AUTO odblokowane!';
  }

  @override
  String get dngNewRecord => '★ Nowy rekord!';

  @override
  String get dngAllLootAdded =>
      'Wszystkie łupy zostały dodane do twojego konta.';

  @override
  String get dngYouFallen => 'POLEGŁEŚ';

  @override
  String get dngCleared => 'LOCH OCZYSZCZONY!';

  @override
  String get dngRunEnded => 'RUN ZAKOŃCZONY';

  @override
  String get dngAutoLocked => '🔒 AUTO';

  @override
  String get dngStop => '◉ ZATRZYMAJ';

  @override
  String get dngAuto => '✦ AUTO';

  @override
  String get dngRunAgain => 'BIEGAJ PONOWNIE';

  @override
  String get dngReturnHall => 'WRÓĆ DO HOLU';

  @override
  String get auraEquipped => 'ZAŁOŻONE';

  @override
  String get auraOn => 'WŁĄCZONE';

  @override
  String auraCost(int n) {
    return 'Koszt: $n zcoins';
  }

  @override
  String auraUnlockTitle(String name) {
    return 'Odblokować $name?';
  }

  @override
  String get auraAllAuras => 'WSZYSTKIE AURY';

  @override
  String get auraAllSkins => 'WSZYSTKIE SKÓRKI';

  @override
  String get auraAllPets => 'WSZYSTKIE ZWIERZĘTA';

  @override
  String get auraRemoveAura => 'Usuń aurę';

  @override
  String get auraRemoveSkin => 'Usuń skórkę';

  @override
  String get auraDismissPet => 'Odpraw zwierzę';

  @override
  String get auraBattleCompanion => 'TOWARZYSZ BITWY';

  @override
  String get auraWaystones => 'KAMIENIE DROGI';

  @override
  String get auraAttackEffects => 'EFEKTY ATAKU';

  @override
  String get auraCharSlots => 'SLOTY POSTACI';

  @override
  String get auraCompanionNote =>
      'Jednocześnie może być aktywny tylko jeden towarzysz. Każdy zapewnia mały pasywny bonus.';

  @override
  String get auraBeforeAfter => 'Przed / Po';

  @override
  String get auraAllSlots => 'Wszystkie 12 slotów odblokowane.';

  @override
  String auraAdoptTitle(String name) {
    return 'Adoptować $name?';
  }

  @override
  String auraPetBonus(String label) {
    return '✦ $label';
  }

  @override
  String get auraMaxEvolution => '★★ MAKSYMALNA EWOLUCJA';

  @override
  String auraOwned(Object count) {
    return 'Posiadane: $count';
  }

  @override
  String auraWaystoneDesc(Object h, String m) {
    return '${h}h  ·  $m× dochód z bezczynności';
  }

  @override
  String auraHitEvery(String text) {
    return '\"$text\" przy każdym trafieniu';
  }

  @override
  String auraSlotN(Object n) {
    return 'Slot $n';
  }

  @override
  String get auraAddSlot => 'Dodaj jeszcze jeden slot zapisu postaci.';

  @override
  String get auraUnlock => 'ODBLOKUJ';

  @override
  String get auraAdopt => 'ADOPTUJ';

  @override
  String get auraBuy => 'KUP';

  @override
  String get auraEvolve => 'EWOLUUJ';

  @override
  String get auraEquip => 'ZAŁÓŻ';

  @override
  String get auraActive => 'AKTYWNE';

  @override
  String get auraSendOut => 'WYŚLIJ';

  @override
  String get auraStackAuras =>
      'Bonusy z każdej aury, którą POSIADASZ, kumulują się automatycznie — zachowujesz je wszystkie. Zakładaj jedną tylko po to, aby wybrać, który blask chcesz pokazać.';

  @override
  String get auraStackSkins =>
      'Bonusy z każdej skórki, którą POSIADASZ, kumulują się automatycznie — zachowujesz je wszystkie. Zakładaj jedną tylko po to, aby wybrać, który wygląd chcesz nosić.';

  @override
  String get armTabUniques => 'UNIKALNE';

  @override
  String get armTabMythic => 'MITYCZNE';

  @override
  String get armTabSets => 'PRZEDMIOTY SETOWE';

  @override
  String get armTabArtifacts => 'ARTEFAKTY';

  @override
  String get armNoLegendaries => 'Brak legendarnych dla tej klasy.';

  @override
  String armClassUniques(int count) {
    return '$count unikalne przedmioty klasy';
  }

  @override
  String get armOwned => 'POSIADANE';

  @override
  String armSlotReqLevel(String slot, int lvl) {
    return '$slot  •  Wymagany poziom $lvl';
  }

  @override
  String get armStats => 'STATYSTYKI';

  @override
  String get armAbilityEnh => 'ULEPSZENIE UMIEJĘTNOŚCI';

  @override
  String armAbilityDamage(String x) {
    return '• Obrażenia umiejętności ×$x';
  }

  @override
  String armAbilityDuration(Object n) {
    return '• +$n rund czasu trwania';
  }

  @override
  String armAbilityCooldown(String v) {
    return '• $v rund odnowienia';
  }

  @override
  String armOnCast(String desc) {
    return '• Po rzuceniu: $desc';
  }

  @override
  String get armHowToFind => 'JAK ZNALEŹĆ';

  @override
  String get armDropCampaign => 'Bossowie kampanii';

  @override
  String get armDropTower => 'Bossowie Wniebowstąpienia Wieży';

  @override
  String get armDropBossRush => 'Runy Boss Rush';

  @override
  String get armDropGauntlet => 'Czyszczenie Gauntlet';

  @override
  String get armRate2 => '2% za zabicie bossa';

  @override
  String get armRate03 => '0,3% za zabicie bossa';

  @override
  String get armRateRare => 'Rzadki drop bonusowy';

  @override
  String get armDropsClassSpecific =>
      'Dropy są specyficzne dla klasy — mogą upuszczać tylko przedmioty dla twojej klasy.';

  @override
  String get armNoMythic => 'Brak mitycznych przedmiotów';

  @override
  String get armMythicHint =>
      'Pokonuj bossów kampanii, aby mieć 0,5% szans za zabicie.';

  @override
  String get armMythicItems => 'Przedmioty mityczne';

  @override
  String armSlotLv(String slot, int lvl) {
    return '$slot  •  Lv$lvl';
  }

  @override
  String armKeyword(String name) {
    return 'słowo kluczowe $name';
  }

  @override
  String get armSetItemsTitle => 'Przedmioty setowe';

  @override
  String armFraction(int a, int b) {
    return '$a / $b';
  }

  @override
  String get armEquippedLower => 'założone';

  @override
  String get armSetBonuses => 'BONUSY SETOWE';

  @override
  String armPc(Object n) {
    return '${n}cz';
  }

  @override
  String get armUniqueBlurb =>
      'Unikalne przedmioty są powiązane z klasą i dramatycznie wzmacniają umiejętności. Każdy wzmacnia określoną umiejętność klasy. Szansa upuszczenia: 2% za zabicie bossa.';

  @override
  String get armMythicBlurb =>
      'Najrzadszy proceduralnie generowany poziom. Mityczne przedmioty mają 3 statystyki z najwyższymi możliwymi wartościami i potężny efekt słowa kluczowego. Szansa upuszczenia: 0,5% za zabicie bossa.';

  @override
  String get armSetBlurb =>
      'Zbieraj wiele elementów tego samego setu, aby odblokować potężne bonusy. Sety wymagają teraz 6 elementów dla pełnego bonusu. Szansa upuszczenia: 0,3% za zabicie bossa.';

  @override
  String armArtifactBlurb(int count) {
    return '$count zestawy artefaktów z trzema elementami. Załóż 2 pasujące zielone elementy na siatce artefaktów dla bonusu częściowego, wszystkie 3 dla pełnego bonusu. Elementy setów upuszczają się z Lochów, Boss Rush i bossów Kampanii.';
  }

  @override
  String get armSetPieces => 'ELEMENTY SETU';

  @override
  String get armArtifactSets => 'Sety artefaktów';

  @override
  String armCollected(int a, int b) {
    return 'ZEBRANE  $a / $b posiadanych odrębnych elementów';
  }

  @override
  String endlessStage(int n) {
    return 'Etap $n';
  }

  @override
  String endlessNextReward(int n) {
    return 'Następna nagroda: Podłoga $n';
  }

  @override
  String get endlessChallengeBoss => 'WYZWIJ BOSSA';

  @override
  String get endlessPremiumAutoClear =>
      '🔒  Osiągnij Etap 5 kampanii, aby automatycznie czyścić bossów';

  @override
  String get endlessRewards => 'NAGRODY: ';

  @override
  String get endlessDrop => 'DROP: ';

  @override
  String get endlessGold => 'ZŁOTO';

  @override
  String get endlessXp => 'XP';

  @override
  String get endlessRespawns => 'RESPAWNY';

  @override
  String endlessTowerShards(String n) {
    return '+$n ODŁAMKÓW WIEŻY';
  }

  @override
  String endlessMilestone(Object n) {
    return '★ KAMIEŃ MILOWY: $n ZABIĆ ★';
  }

  @override
  String endlessMilestoneReward(String gold, Object s) {
    return '+$gold ZŁOTA  +$s ◆';
  }

  @override
  String get endlessEnemyStirs => 'Wróg znowu się porusza...';

  @override
  String get endlessDefeatBody =>
      'Twój bohater został przytłoczony.\nUlepszy statystyki i spróbuj ponownie.';

  @override
  String get pvpNoStamina => 'Brak wytrzymałości! Odnawia się 1 co 45 minut.';

  @override
  String get pvpTitle => 'ARENA PVP';

  @override
  String get pvpSimLab => 'Laboratorium Sim';

  @override
  String get pvpRefresh => 'Odśwież ranking';

  @override
  String get pvpLeaderboard => 'RANKING';

  @override
  String pvpToday(String label) {
    return 'DZIŚ: $label';
  }

  @override
  String pvpWinsToday(Object wins, Object dmg) {
    return '$wins zwycięstw dziś  •  $dmg łącznych obrażeń';
  }

  @override
  String get pvpClaimed => '✓ ODEBRANE';

  @override
  String get pvpNoChallengers => 'BRAK WYZYWAJĄCYCH';

  @override
  String get pvpNoChallengersSub =>
      'Stocz mecz, aby dołączyć do rankingu\ni zobaczyć, jak wypadasz.';

  @override
  String pvpHpAc(Object hp, Object ac) {
    return 'HP:$hp  AC:$ac';
  }

  @override
  String get pvpStamina => 'WYTRZYMAŁOŚĆ  ';

  @override
  String get pvpStaminaTip => 'Wytrzymałość odnawia 1 serce co 45 minut.';

  @override
  String get pvpRating => 'OCENA';

  @override
  String get pvpWins => 'ZWYCIĘSTWA';

  @override
  String get pvpLosses => 'PORAŻKI';

  @override
  String get pvpWL => 'Z/P';

  @override
  String pvpLeague(String name) {
    return 'LIGA $name';
  }

  @override
  String get pvpNearRank => 'BLISKO TWOJEGO RANKU';

  @override
  String get pvpPlayersAbove => '— gracze tuż powyżej ciebie';

  @override
  String pvpClassLv(String cls, Object lvl) {
    return '$cls  Lv$lvl';
  }

  @override
  String get pvpChallenge => 'WYZWIJ';

  @override
  String get pvpBattleLog => 'DZIENNIK BITWY';

  @override
  String get pvpBattleLogTip => 'Dziennik bitwy';

  @override
  String get pvpNoCombat => 'Brak walki.';

  @override
  String get pvpClose => 'ZAMKNIJ';

  @override
  String pvpVs(String hero, String opp) {
    return 'PVP  —  $hero vs $opp';
  }

  @override
  String get pvpReturnArena => 'WRÓĆ DO ARENY';

  @override
  String get pvpFighting => 'Walczenie...';

  @override
  String invBagCount(Object n, Object cap) {
    return '($n/$cap)';
  }

  @override
  String invBuyTab(Object cost) {
    return '+ ZAKŁADKA  $cost';
  }

  @override
  String get invAutoEquip => 'AUTO ZAKŁADANIE';

  @override
  String invTabN(Object n, Object count) {
    return 'ZAKŁADKA $n  ($count)';
  }

  @override
  String get invEquipment => 'WYPOSAŻENIE';

  @override
  String invBag(Object n, Object cap) {
    return 'TORBA  ($n/$cap)';
  }

  @override
  String get invUnequip => 'Zdejmij';

  @override
  String get invNoItems => 'Brak przedmiotów na tej zakładce.';

  @override
  String invReqClass(String cls) {
    return 'Wymaga $cls';
  }

  @override
  String invReqLevel(Object lvl) {
    return 'Wymaga poziomu $lvl';
  }

  @override
  String invReqTier(Object t) {
    return 'Wymaga poziomu $t';
  }

  @override
  String get invCannotEquip => 'Nie można założyć';

  @override
  String get invEquip => 'Załóż';

  @override
  String get invUnlock => 'Odblokuj 🔓';

  @override
  String get invLock => 'Zablokuj 🔒';

  @override
  String get invDiscard => 'Wyrzuć';

  @override
  String get invAny => 'Dowolny';

  @override
  String invUniqueOnly(String cls) {
    return '★ Unikalne — tylko $cls';
  }

  @override
  String get invWrongClass => '(zła klasa)';

  @override
  String get invColStat => 'STAT';

  @override
  String get invColThis => 'TEN';

  @override
  String get invColEqpd => 'ZAŁO';

  @override
  String get invColDiff => 'RÓŻN';

  @override
  String get invEmptySocket => 'Puste gniazdo';

  @override
  String get invCraftGems => 'Wytwarzaj klejnoty w Kuźni → zakładka Klejnoty';

  @override
  String get invRemove => 'USUŃ';

  @override
  String get invSocket => 'OSADŹ';

  @override
  String invChooseGem(String name) {
    return 'Wybierz klejnot do osadzenia w $name';
  }

  @override
  String invOnThis(String slot, String bonus) {
    return 'Na tym(tej) $slot: $bonus';
  }

  @override
  String get invRemoveGem => 'Usunąć klejnot?';

  @override
  String get invDestroy => 'ZNISZCZ';

  @override
  String get invSort => 'Sortuj:';

  @override
  String get invFilter => 'Filtruj:';

  @override
  String invGemsAvailable(Object count) {
    return '$count klejnot(ów) dostępnych do osadzenia';
  }

  @override
  String invRemoveBody(String name) {
    return '$name zostanie zniszczony. Klejnotów nie można odzyskać po usunięciu.';
  }

  @override
  String invReplaceBody(String old, String gnew) {
    return '$old zostanie zniszczony i zastąpiony przez $gnew.';
  }

  @override
  String get npcRoster => 'SKŁAD';

  @override
  String get npcSynergies => 'SYNERGIE';

  @override
  String get npcTitle => 'NAJEMNICY';

  @override
  String get npcTotalBonuses => 'ŁĄCZNE AKTYWNE BONUSY';

  @override
  String get npcBattleParty => 'DRUŻYNA BITEWNA';

  @override
  String npcFielded(Object count, Object max) {
    return '$count / $max wystawionych';
  }

  @override
  String get npcUnknown => 'Nieznany najemnik';

  @override
  String npcBattleAbility(String name) {
    return 'ZDOLNOŚĆ BITEWNA: $name';
  }

  @override
  String npcUnlock(String label) {
    return 'Odblokuj: $label';
  }

  @override
  String npcProgress(Object a, Object b) {
    return '$a / $b';
  }

  @override
  String npcLvTalent(Object n) {
    return 'TALENT LV $n';
  }

  @override
  String npcChosen(String name) {
    return 'WYBRANY: $name';
  }

  @override
  String get npcMilestoneComplete =>
      'KAMIEŃ MILOWY UKOŃCZONY — REKRUTOWANIE...';

  @override
  String get npcMax => '★ MAKS';

  @override
  String get npcStarRank => 'RANK GWIAZDEK';

  @override
  String npcStars(Object a, Object b) {
    return '$a / $b';
  }

  @override
  String get npcFullyAscended =>
      '★ W PEŁNI WNIEBOWSTĄPIONY — każda gwiazdka dodaje +1 efektywny poziom.';

  @override
  String npcAscendStar(Object n) {
    return 'WNIEBOWSTĄP ★$n';
  }

  @override
  String npcYouHave(Object n) {
    return 'Masz: $n Mithryl';
  }

  @override
  String get npcStarInfo =>
      'Każda gwiazdka = +1 efektywny poziom bonusu tego najemnika.';

  @override
  String get npcPassiveOnly => 'Tylko pasywne bonusy — zawsze aktywne.';

  @override
  String npcCostShards(Object n) {
    return 'Koszt: ◆ $n odłamków';
  }

  @override
  String get npcTutorial =>
      'Najemnicy to towarzysze, którzy trwale dołączają po osiągnięciu pewnych kamieni milowych. 🤝 Każdy zapewnia pasywne bonusy bojowe w każdej walce i może tworzyć synergie z innymi dla dodatkowej mocy.';

  @override
  String npcRecruited(Object a, Object b) {
    return '$a / $b  zrekrutowanych';
  }

  @override
  String get npcNoMercs =>
      'Brak zrekrutowanych najemników. Wypełniaj kamienie milowe, aby ich odblokować.';

  @override
  String npcChipDamage(Object n) {
    return '+$n% Obrażeń';
  }

  @override
  String npcChipAc(Object n) {
    return '+$n% AC';
  }

  @override
  String npcChipShards(Object n) {
    return '+$n% Odłamków';
  }

  @override
  String npcChipHp(Object n) {
    return '+$n% HP';
  }

  @override
  String get shopTabBundles => 'PAKIETY';

  @override
  String get shopTabVip => 'VIP';

  @override
  String get shopTabStarter => 'STARTER';

  @override
  String get shopTabResources => 'ZASOBY';

  @override
  String get shopTabCosmetics => 'KOSMETYKI';

  @override
  String get shopSecBundles => 'PAKIETY ZCOINS';

  @override
  String get shopSecBundlesSub => 'Waluta premium do Sklepu';

  @override
  String get shopSecVip => 'SUBSKRYPCJE VIP';

  @override
  String get shopSecVipSub => 'Cykliczne przywileje i korzyści';

  @override
  String get shopSecStarter => 'PAKIETY STARTOWE';

  @override
  String get shopSecStarterSub => 'Jednorazowe pakiety zakupu';

  @override
  String get shopSecResources => 'ZASOBY';

  @override
  String get shopSecResourcesSub => 'Wydaj ZCoins na złoto i materiały';

  @override
  String get shopSecAuras => 'AURY';

  @override
  String get shopSecAurasSub =>
      'Załóż blask — bonusy posiadanych aur zawsze się kumulują';

  @override
  String get shopSecBoosts => 'WZMOCNIENIA';

  @override
  String get shopSecBoostsSub => 'Stałe wzmocnienia statystyk';

  @override
  String get shopSecTitles => 'TYTUŁY';

  @override
  String get shopSecTitlesSub => 'Rank wyświetlany pod twoim imieniem';

  @override
  String get shopSecColours => 'KOLORY IMION';

  @override
  String get shopSecColoursSub => 'Kolor + blask dla imienia twojego bohatera';

  @override
  String get shopSecFrames => 'RAMKI';

  @override
  String get shopSecFramesSub => 'Ramka wokół portretu twojego bohatera';

  @override
  String get shopSecSlots => 'SLOTY POSTACI';

  @override
  String get shopSecSlotsSub => 'Dodatkowe sloty zapisu postaci';

  @override
  String get shopPremiumArmor => 'PREMIUM ZBROJA KLASY';

  @override
  String shopEndgameSkin(String cls) {
    return '$cls · Skórka endgame';
  }

  @override
  String get shopIncludedBonuses => 'DOŁĄCZONE BONUSY';

  @override
  String get shopEverySkin => 'bonusy z każdej skórki sklepowej, połączone';

  @override
  String get shopEquippedCheck => '✓ ZAŁOŻONE';

  @override
  String get shopUnequip => 'ZDEJMIJ';

  @override
  String shopUnlockPrice(String price) {
    return 'ODBLOKUJ  ·  $price';
  }

  @override
  String get shopStoreUnavailable =>
      'Sklep niedostępny — spróbuj ponownie później.';

  @override
  String get shopVipSub => 'SUBSKRYPCJA VIP';

  @override
  String get shopSubscribed => '✓ SUBSKRYBOWANE';

  @override
  String shopSubscribe(String price) {
    return 'SUBSKRYBUJ  $price';
  }

  @override
  String get shopEverythingPlus => 'Wszystko z Paktu Vanguarda, plus:';

  @override
  String get shopIncludedPerks => 'DOŁĄCZONE PRZYWILEJE';

  @override
  String get shopGlow => '✦ BLASK';

  @override
  String get shopExclusive => 'EKSKLUZYWNE';

  @override
  String get shopNoAd => 'Brak dostępnej reklamy — spróbuj ponownie później.';

  @override
  String get shopWatchAd => 'Obejrzyj reklamę';

  @override
  String get shopComeBackTomorrow => 'Wróć jutro po więcej darmowych ZCoins!';

  @override
  String get shopWait => 'CZEKAJ...';

  @override
  String get shopWatch => 'OGLĄDAJ';

  @override
  String get shopRewardEarned => 'NAGRODA ZDOBYTA';

  @override
  String shopPlusZcoins(Object amount) {
    return '+$amount ZCoins';
  }

  @override
  String get shopCollect => 'ODBIERZ';

  @override
  String get shopPurchasesRestored =>
      'Zakupy przywrócone. Wszelkie aktywne subskrypcje lub pakiety zostały ponownie zastosowane.';

  @override
  String get shopRestorePurchases => 'Przywróć zakupy';

  @override
  String artSalvageTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Odzyskać $count artefaktów?',
      few: 'Odzyskać $count artefakty?',
      one: 'Odzyskać $count artefakt?',
    );
    return '$_temp0';
  }

  @override
  String get artSalvage => 'ODZYSKAJ';

  @override
  String artSalvaged(int n, Object gained) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Odzyskano $n artefaktów za ◆ $gained mithryl.',
      few: 'Odzyskano $n artefakty za ◆ $gained mithryl.',
      one: 'Odzyskano $n artefakt za ◆ $gained mithryl.',
    );
    return '$_temp0';
  }

  @override
  String get artTable => 'STÓŁ ARTEFAKTÓW';

  @override
  String artSlots(Object n, Object max) {
    return '$n/$max slotów';
  }

  @override
  String artAutoEquipped(Object n) {
    return 'Automatycznie założono $n najlepszych artefaktów.';
  }

  @override
  String get artNoneToEquip => 'Brak artefaktów do założenia.';

  @override
  String get artAutoEquip => '⚡ AUTO-ZAKŁADANIE';

  @override
  String get artSalvageBtn => '♻ ODZYSKAJ';

  @override
  String get artTitle => 'ARTEFAKTY';

  @override
  String get artPlaceHint =>
      'Umieszczaj artefakty na stole, aby zyskać bonusy.';

  @override
  String get artTableBonuses => 'BONUSY STOŁU';

  @override
  String get artCollection => 'KOLEKCJA';

  @override
  String artCount(Object n) {
    return '($n)';
  }

  @override
  String artTapToPlace(String name) {
    return 'Dotknij komórkę siatki, aby umieścić \"$name\"';
  }

  @override
  String get artTapCancel => 'dotknij ponownie, aby anulować';

  @override
  String get artSet => 'SET';

  @override
  String artUpgradeCost(Object cost) {
    return '$cost Mithryl';
  }

  @override
  String artNoSets(Object n) {
    return 'Brak założonych elementów setu — $n setów do odkrycia.';
  }

  @override
  String artCountOf3(Object count) {
    return '$count / 3';
  }

  @override
  String get artHowToGet => 'JAK ZDOBYĆ ARTEFAKTY';

  @override
  String get artRowCampaign => 'Bossowie kampanii';

  @override
  String get artRowCampaignDesc =>
      'około 25% szans na upuszczenie przy każdym zabiciu bossa.';

  @override
  String get artRowDungeon => 'Runy lochu';

  @override
  String get artRowDungeonDesc =>
      'każdy pokonany boss upuszcza jeden — do 2 na run. Najlepszy stały farm.';

  @override
  String get artRowBossRush => 'Boss Rush';

  @override
  String get artRowBossRushDesc =>
      'wyczyść run z rangą A lub S, aby zdobyć artefakt.';

  @override
  String artSalvageBody(int count, Object mythril) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Trwale zniszczyć wszystkie $count niezałożonych artefaktów za ◆ $mythril mithryl? Założone artefakty są zachowane.',
      few:
          'Trwale zniszczyć wszystkie $count niezałożone artefakty za ◆ $mythril mithryl? Założone artefakty są zachowane.',
      one:
          'Trwale zniszczyć $count niezałożony artefakt za ◆ $mythril mithryl? Założone artefakty są zachowane.',
    );
    return '$_temp0';
  }

  @override
  String get artSetBlurb =>
      'Zbieraj pasujące zielone elementy setu. 2 założone = częściowy bonus, wszystkie 3 = pełny bonus.';

  @override
  String get art2Set => '2-Set';

  @override
  String get art3Set => '3-Set';

  @override
  String get ptEssence => 'esencja';

  @override
  String ptTheClass(String cls) {
    return '$cls';
  }

  @override
  String ptRespecBranch(String branch) {
    return 'Zresetować $branch?';
  }

  @override
  String ptRefund(Object refund) {
    return 'Zwrot $refund esencji (75%)';
  }

  @override
  String get ptRespec => 'Reset';

  @override
  String get ptCrossBranch => 'MIĘDZY-GAŁĘZIOWY';

  @override
  String get ptFullRespec => 'Pełny reset?';

  @override
  String get ptRespec50 => 'Reset (50 ZC)';

  @override
  String get ptFullRespecBtn => 'PEŁNY RESET (50 ZC)';

  @override
  String get ptTitle => 'DRZEWO PASYWNE';

  @override
  String get ptNow => 'TERAZ';

  @override
  String ptUpgradeCost(Object cost) {
    return 'ULEPSZ  ($cost ✦)';
  }

  @override
  String get ptLocked => 'ZABLOKOWANE — wydaj 25 rang w więcej gałęziach';

  @override
  String get ptLockedMax =>
      'ZABLOKOWANE — najpierw zmaksymalizuj wszystkie węzły gałęzi';

  @override
  String ptMaxRankTotal(String val) {
    return 'MAKS. RANGA — $val łącznie';
  }

  @override
  String ptFullRespecBody(Object refund) {
    return 'Zresetuj WSZYSTKIE węzły pasywne.\nZwrot $refund esencji (60%).\nKoszt: 50 zcoins.';
  }

  @override
  String ptNodesUnlocked(Object count) {
    return '$count odblokowanych węzłów';
  }

  @override
  String get ptTutorial =>
      'Zdobyłeś Odłamki ◆ — wydaj je tutaj na trwałe węzły pasywne, które nigdy nie są resetowane. Gałąź twojej klasy jest na górze. Każdy węzeł wchodzi na rang 5 dla większych bonusów.';

  @override
  String ptBranchesAt25(Object count) {
    return '$count / 5 gałęzi na 25';
  }

  @override
  String get homeExp => 'DOŚ';

  @override
  String get homeResources => 'Zasoby';

  @override
  String get homeGold => 'ZŁOTO';

  @override
  String get homeShards => 'ODŁAMKI';

  @override
  String get homeZcoins => 'ZCOINS';

  @override
  String get homeMythril => 'MITHRYL';

  @override
  String get homeIdleMin => 'BEZCZ/min';

  @override
  String get homeGoldTip =>
      'Złoto\nZdobywane w bitwach i z dochodu pasywnego.\nWydawaj w Ulepszeniach i Sklepie.';

  @override
  String get homeShardsTip =>
      'Odłamki\nZdobywane z zabitych wrogów, Lochów, Wypraw i Gauntlet.\nWydawaj na ulepszenia umiejętności, ulepszenia przedmiotów i węzły Drzewa Pasywnego.';

  @override
  String get homeZcoinsTip =>
      'ZCoins\nZdobywane z osiągnięć i codziennych skrzyń.\nWydawaj w Sklepie Aur na skórki, zwierzęta i aury.';

  @override
  String get homeMythrilTip =>
      'Mithryl\nZdobywane z Lochów, Boss Rush i kamieni milowych prestiżu.\nWydawaj na ulepszenia Artefaktów, resetowanie afiksów lochu i błogosławieństwa sanktuarium.';

  @override
  String get homeIdleTip =>
      'Złoto z Bezczynności / min\nZłoto zdobywane automatycznie co minutę podczas nieobecności.\nRośnie z poziomem bohatera, ulepszeniami pasywnymi i zwierzętami.';

  @override
  String get homeCurrentCampaign => 'Aktualna kampania';

  @override
  String homeStage(Object n) {
    return 'ETAP $n';
  }

  @override
  String homeNextGoal(Object reward) {
    return 'NASTĘPNE: ODBLOKUJ $reward';
  }

  @override
  String homeNextGoalProgress(Object remaining, Object stage) {
    return 'Jeszcze $remaining etapów — przejdź Etap $stage';
  }

  @override
  String get demoModeLocked =>
      'Odblokowywane w pełnej grze. Demo zawiera całą kampanię — zdobądź pełną grę, aby odblokować Lochy, PvP i poziomy trudności w endgame.';

  @override
  String get demoFullGameCta => 'ZDOBĄDŹ PEŁNĄ GRĘ';

  @override
  String get homeSecCombat => 'WALKA';

  @override
  String get homeSecSocial => 'SPOŁECZNOŚĆ';

  @override
  String get homeNavChallengeGauntlet => 'WYZWANIE GAUNTLET';

  @override
  String get homeNavBountyBoard => 'TABLICA NAGRÓD';

  @override
  String get homeNavSeasonPass => 'KARNET SEZONOWY';

  @override
  String get homeNavWorldEvent => 'WYDARZENIE ŚWIATOWE';

  @override
  String get homeNavLeaderboard => 'RANKING';

  @override
  String get homeNavChallengeModifiers => 'MODYFIKATORY WYZWAŃ';

  @override
  String get homeQuickAccess => 'SZYBKI DOSTĘP';

  @override
  String get homeGettingStarted => 'PIERWSZE KROKI';

  @override
  String get homeStep1 => 'Wygraj swoją pierwszą bitwę kampanii';

  @override
  String get homeStep2 => 'Awansuj bohatera — odwiedź Kartę Postaci';

  @override
  String get homeStep3 => 'Otwórz BOHATERA i kup pierwsze ulepszenie Atrybutu';

  @override
  String get homeStep4 =>
      'Osiągnij Etap 5 — Umiejętności i Codzienne Wyzwania są odblokowane!';

  @override
  String get homeHeroSubtitle =>
      'ULEPSZENIA  •  ZBROJOWNIA  •  SOJUSZNICY  •  KODEKS';

  @override
  String get homeTomorrow => 'Jutro: ';

  @override
  String get dailyWeekly => 'TYGODNIOWE';

  @override
  String get dailyClaimAll => 'ODBIERZ WSZYSTKO';

  @override
  String get dailyHowItWorks => 'Jak to działa';

  @override
  String get dailyThisWeek => 'WYZWANIA TEGO TYGODNIA';

  @override
  String dailyCompleted(Object claimed, Object total) {
    return '$claimed / $total ukończonych';
  }

  @override
  String get dailyWeeklyLoading => 'Wyzwania tygodniowe ładują się...';

  @override
  String get dailyAboutWeekly => 'O wyzwaniach tygodniowych';

  @override
  String get dailyReady => 'GOTOWE';

  @override
  String get dailyTodayProgress => 'DZISIEJSZY POSTĘP';

  @override
  String get dailyChest => 'CODZIENNA SKRZYNIA';

  @override
  String get dailyClaimedTomorrow => 'Odebrane! Wróć jutro.';

  @override
  String get dailyHintKill => 'Zabij wrogów';

  @override
  String get dailyHintKillD => 'Walcz w trybie Kampania lub Nieskończony';

  @override
  String get dailyHintWin => 'Wygrywaj bitwy';

  @override
  String get dailyHintWinD => 'Pokonanie wroga liczy się jako wygrana';

  @override
  String get dailyHintBoss => 'Pokonaj bossa';

  @override
  String get dailyHintBossD => 'Etap 5, 10, 15, 20, 25 lub Nieskończony co 5';

  @override
  String get dailyHintAbility => 'Używaj umiejętności';

  @override
  String get dailyHintAbilityD =>
      'Aktywne umiejętności automatycznie aktywują się w walce';

  @override
  String get dailyHintEquip => 'Zakładaj przedmioty';

  @override
  String get dailyHintEquipD => 'Dotknij przedmiot z torby → Załóż w Ekwipunku';

  @override
  String get dailyHintGold => 'Osiągnij złoto';

  @override
  String get dailyHintGoldD => 'Miej po prostu tyle złota w swoim zasobie';

  @override
  String get dailyHintDamage => 'Zadaj obrażenia';

  @override
  String get dailyHintDamageD => 'Łączne obrażenia zadane w dowolnym trybie';

  @override
  String get dailyHintIdle => 'Zbierz pasywne';

  @override
  String get dailyHintIdleD => 'Dotknij nagrodę pasywną na ekranie głównym';

  @override
  String get dailyHintResets => 'Resety';

  @override
  String get dailyHintResetsD =>
      'Każdy poniedziałek — 5 nowych wyzwań co tydzień';

  @override
  String get dailyHintRewards => 'Nagrody';

  @override
  String get dailyHintRewardsD =>
      'Większe niż dzienne: esencja, mithryl, ZCoins';

  @override
  String get dailyHintSeasonXp => 'XP sezonowe';

  @override
  String get dailyHintSeasonXpD =>
      '+50 XP sezonu za odebrane tygodniowe wyzwanie';

  @override
  String get dailyHintProgress => 'Postęp';

  @override
  String get dailyHintProgressD =>
      'Liczy od poniedziałkowej północy, nie od odebrania';

  @override
  String get dailyTutorial =>
      'Wypełniaj codzienne wyzwania, aby zdobywać złoto, odłamki, esencję i ZCoins. Wszystkie 7 wyzwań resetuje się każdego dnia. Wypełnij je wszystkie, aby otrzymać skrzynię bonusową!';

  @override
  String petOwned(Object a, Object b) {
    return '$a / $b  posiadanych';
  }

  @override
  String get petTitle => 'TOWARZYSZE';

  @override
  String get petActiveBonuses =>
      'AKTYWNE BONUSY (wszystkie posiadane zwierzęta)';

  @override
  String get petNoCompanion => 'Brak wyposażonego towarzysza';

  @override
  String get petEquipHint => 'Wyposaż zwierzę, aby pojawiało się w walce.';

  @override
  String get petPremium => '★ PREMIUM';

  @override
  String get petInBattle => 'W WALCE';

  @override
  String petRecruitTitle(String name) {
    return 'Zrekrutować $name?';
  }

  @override
  String get petRecruit => 'REKRUTUJ';

  @override
  String petEvolveTitle(String name) {
    return 'Ewoluować $name?';
  }

  @override
  String petEvolveN(Object n) {
    return 'EWOLUUJ  Ew $n';
  }

  @override
  String get petTutorial =>
      'Zwierzęta towarzysze dołączają do ciebie w walce i kumulują swoje bonusy pasywnie — nawet te niezałożone. Wyposaż jedno, aby pojawiało się u twojego boku podczas walk. Ewoluuj posiadane zwierzęta dwukrotnie, aby podwoić wartość bonusu.';

  @override
  String petRecruitBody(String desc, String bonus, Object cost) {
    return '$desc\n\nBonus: $bonus\n\nKoszt: $cost ZCoins';
  }

  @override
  String petEvolveBody(Object level, String bonus, Object cost) {
    return 'Ulepsz do Ewolucji $level.\n\nNowy bonus: +$bonus\nKoszt: $cost ZCoins';
  }

  @override
  String get questTitle => 'LINIE QUESTÓW';

  @override
  String get questAdventure => 'LINIA QUESTÓW PRZYGODY';

  @override
  String get questAdventureSub =>
      'Naucz się każdego systemu gry na drodze do etapu 100.';

  @override
  String questUnlocksLv30(Object lvl) {
    return 'Odblokowuje się na Poziomie 30  (aktualny: $lvl)';
  }

  @override
  String get questUltUnlocked => 'UMIEJĘTNOŚĆ OSTATECZNA ODBLOKOWANA';

  @override
  String questUltAvailable(String cls) {
    return 'Ostateczna $cls jest teraz dostępna w walce.';
  }

  @override
  String get questProgressLabel => 'Postęp';

  @override
  String questCompleteFirst(Object n) {
    return 'Najpierw ukończ zadanie $n, aby odblokować.';
  }

  @override
  String get questClaimReward => 'ODBIERZ NAGRODĘ';

  @override
  String get questRewardLabel => 'Nagroda: ';

  @override
  String questClassQuestline(String cls) {
    return 'LINIA QUESTÓW $cls';
  }

  @override
  String get questComplete5 =>
      'Ukończ 5 zadań, aby odblokować Umiejętność Ostateczną.';

  @override
  String get subTitle => 'SPECJALIZACJA';

  @override
  String get subLevel50 => 'SPECJALIZACJA POZIOMU 50';

  @override
  String subChooseBody(String cls, Object cost) {
    return 'Wybierz specjalizację dla swojej klasy $cls. Zapewnia potężny bonus kulminacyjny plus bonusy statystyk, zastosowane natychmiast. Możesz to zmienić później za $cost ZCoins.';
  }

  @override
  String subClassSpecs(String cls, Object n) {
    return 'SPECJALIZACJE $cls  ($n)';
  }

  @override
  String subUnlocksAt(Object lvl) {
    return 'Specjalizacja odblokowuje się na Poziomie $lvl.';
  }

  @override
  String subChooseTitle(String name) {
    return 'Wybrać $name?';
  }

  @override
  String get subStatBonuses => 'BONUSY STATYSTYK';

  @override
  String get subCapstone => 'BONUS KULMINACYJNY';

  @override
  String get subSpecialEffect => 'EFEKT SPECJALNY';

  @override
  String subChangeLater(Object cost) {
    return 'Możesz to zmienić później za $cost ZCoins.';
  }

  @override
  String get subCouldNotSet =>
      'Nie można ustawić specjalizacji — spróbuj ponownie.';

  @override
  String subChangeSpec(Object cost) {
    return 'ZMIEŃ SPECJALIZACJĘ  —  $cost ZCoins';
  }

  @override
  String get subChangeTitle => 'Zmienić specjalizację?';

  @override
  String subChangeBody(Object cost, Object zcoins) {
    return 'Wydać $cost ZCoins, aby usunąć bieżącą specjalizację i wybrać nową?\n\nTwoje ZCoins: $zcoins';
  }

  @override
  String get subNotEnough => 'Za mało ZCoins do resetu.';

  @override
  String get subActiveSubclass => 'AKTYWNA PODKLASA';

  @override
  String get subChosen => 'WYBRANA';

  @override
  String get subActive => 'AKTYWNA';

  @override
  String get subChoosePath => 'WYBIERZ TĘ ŚCIEŻKĘ';

  @override
  String get expTitle => 'WYPRAWY';

  @override
  String get expCollectAll => 'ZBIERZ WSZYSTKO';

  @override
  String get expDispatchAll => 'WYŚLIJ WSZYSTKICH';

  @override
  String get expNoMercs => 'Brak najemników';

  @override
  String get expNoMercsSub =>
      'Rekrutuj najemników z zakładki NAJEMNICY w Centrum Bohatera, aby wysyłać ich na wyprawy.';

  @override
  String get expTodayLocations => 'DZISIEJSZE LOKALIZACJE';

  @override
  String expRefreshIn(String time) {
    return '🔄 $time';
  }

  @override
  String get expYourParty => 'TWOJA DRUŻYNA';

  @override
  String get expDispatch => 'WYŚLIJ';

  @override
  String get expDone => 'GOTOWE';

  @override
  String get expCollectRewards => 'ZBIERZ NAGRODY';

  @override
  String get expInProgress => 'W TOKU...';

  @override
  String expReturned(String name) {
    return '$name wrócił!';
  }

  @override
  String get expDiscovery => '✦  ODKRYCIE';

  @override
  String get expGreat => 'ŚWIETNIE';

  @override
  String expDispatchMerc(String name) {
    return 'WYŚLIJ $name';
  }

  @override
  String get expChooseLocation => 'WYBIERZ LOKALIZACJĘ';

  @override
  String get expDuration => 'CZAS TRWANIA';

  @override
  String get expEstRewards => 'SZACOWANE NAGRODY';

  @override
  String get expSend => 'WYŚLIJ NA WYPRAWĘ';

  @override
  String get acctSignInFailed => 'Logowanie anulowane lub nieudane.';

  @override
  String get acctSignOutTitle => 'Wylogować się?';

  @override
  String get acctSignOut => 'Wyloguj się';

  @override
  String get acctSignOutBody =>
      'Lokalny zapis jest zachowany. Synchronizacja z chmurą zostanie wstrzymana do ponownego zalogowania.';

  @override
  String get acctDeleteTitle => 'Usunąć konto i dane?';

  @override
  String get acctDeleteAll => 'USUŃ WSZYSTKO';

  @override
  String get acctDeleteBody =>
      'To trwale usuwa twoje konto i WSZYSTKIE dane — każdą postać, zapis w chmurze, pozycję w PvP i wpisy w rankingach. Tej operacji nie można cofnąć.';

  @override
  String get acctDeleted => 'Konto usunięte';

  @override
  String get acctDeletedBody =>
      'Twoje konto i wszystkie dane zostały usunięte. Aplikacja teraz się zamknie.';

  @override
  String get acctClose => 'Zamknij';

  @override
  String get acctPlayer => 'Gracz';

  @override
  String get acctSyncNow => 'SYNCHRONIZUJ TERAZ';

  @override
  String get acctSignOutBtn => 'WYLOGUJ SIĘ';

  @override
  String get acctSignInGoogle => 'ZALOGUJ SIĘ PRZEZ GOOGLE';

  @override
  String get acctDeleteAccount => 'USUŃ KONTO';

  @override
  String get acctDangerSub =>
      'Trwale usuń swoje konto i wszystkie powiązane dane.';

  @override
  String get acctLinked => 'Konto Google połączone';

  @override
  String get acctNotSynced => 'Jeszcze nie zsynchronizowano w tej sesji';

  @override
  String get acctNoAccount => 'Brak połączonego konta';

  @override
  String get acctAboutCloud => 'O ZAPISACH W CHMURZE';

  @override
  String get acctCloud1 =>
      'Twój postęp synchronizuje się automatycznie co 5 minut po zalogowaniu.';

  @override
  String get acctCloud2 =>
      'Graj na dowolnym urządzeniu Windows z tym samym kontem Google.';

  @override
  String get acctCloud3 =>
      'Zapisy w chmurze są bezpiecznie przechowywane na koncie Google.';

  @override
  String get invhTabGear => 'WYPOSAŻENIE';

  @override
  String get invhTabGems => 'KLEJNOTY';

  @override
  String get invhTabRunes => 'RUNY';

  @override
  String get invhArcaneDust => 'Arkański pył';

  @override
  String invhBag(Object n, Object max) {
    return 'Torba: $n/$max';
  }

  @override
  String get invhCraftGem => 'WYTWORZ KLEJNOT';

  @override
  String invhCraftTypeGem(String type, Object cost) {
    return 'WYTWORZ KLEJNOT $type  ($cost arkańskiego pyłu)';
  }

  @override
  String get invhOwnedGems => 'POSIADANE KLEJNOTY';

  @override
  String invhDismantleBody(String bonus, Object dust) {
    return '$bonus\n\nOsadź w BRONI dla +%DMG, lub ZBROI dla +%ODN tego żywiołu klejnotu.\n\nRozmontowanie zwraca $dust arkańskiego pyłu.';
  }

  @override
  String invhDismantle(Object dust) {
    return 'ROZMONTUJ (+$dust arkańskiego pyłu)';
  }

  @override
  String invhGemTooltip(String name, String bonus) {
    return '$name\n$bonus\nDotknij, aby rozmontować';
  }

  @override
  String get invhTutGear =>
      'Upuściła się twoja pierwsza sztuka wyposażenia! Załóż ją tutaj, aby zwiększyć statystyki.';

  @override
  String get invhTutForge =>
      'Połącz dwa przedmioty z tego samego slotu, aby wykuć sztukę o wyższej rzadkości lub przekuć statystyki.';

  @override
  String get invhTutRunes =>
      'Wytwarzaj Runy dla tymczasowych bonusów bojowych. Zbieraj pył przez odzysk wyposażenia.';

  @override
  String get invhTutArtifacts =>
      'Umieszczaj artefakty w siatce dla trwałych pasywnych bonusów.';

  @override
  String get invhNoGear =>
      'Brak wyposażenia.\nPokonaj wrogów, aby znaleźć pierwszy przedmiot!';

  @override
  String get ascTitle => 'WNIEBOWSTĄPIENIE';

  @override
  String get ascMetaBoard => 'META-TABLICA';

  @override
  String ascApPoints(Object points) {
    return '$points AP';
  }

  @override
  String get ascLevelLabel => 'Poziom wniebowstąpienia: ';

  @override
  String get ascPrestigeLabel => 'Poziom prestiżu: ';

  @override
  String get ascBody =>
      'Wniebowstąpienie jest najgłębszym resetem — przekształca twoje Odrodzenia w Punkty Wniebowstąpienia (AP). Zdobywasz 1 AP za każde poświęcone Odrodzenie, więc im więcej nagromadzisz przed wniebowstąpieniem, tym większa wypłata.\n\nWydawaj AP na dwa sposoby — oba trwałe i przetrwają wszystkie przyszłe resety:\n• Meta-Tablica poniżej (XP, złoto, obrażenia, bonusy pasywne i prestiżu)\n• Wniebowstąp umiejętności klasy na ekranie Umiejętności (+10% mocy za poziom, do 60 AP na postać)\n\nZACHOWUJESZ:  Bonusy wniebowstąpienia i wydane AP, Artefakty, Mithryl, Odłamki Wieży, Mistrzostwo Żywiołów.\nTRACISZ:  wszystkie Odrodzenia, poziom bohatera, złoto, sprzęt, podklasę, rangi umiejętności i postęp kampanii.';

  @override
  String ascRequires(Object prestige) {
    return 'Wymaga Poziomu Prestiżu 5 do Wniebowstąpienia  (aktualny: $prestige/5)';
  }

  @override
  String ascAscendAp(Object ap) {
    return 'WNIEBOWSTĄP  (+$ap AP)';
  }

  @override
  String get ascConfirmTitle => 'Wniebowstąpić?';

  @override
  String ascConfirmBody(Object rebirths, Object ap) {
    return 'Poświęcić $rebirths Odrodzenie(ń) za $ap Punkt(ów) Wniebowstąpienia.\n\nZACHOWAJ: Bonusy wniebowstąpienia, Artefakty, Mithryl, Odłamki Wieży, Wniebowstąpienia Umiejętności.\nSTRAŃ: wszystkie Odrodzenia, poziom bohatera, złoto, sprzęt, podklasę, rangi umiejętności, postęp kampanii.\n\nTej operacji nie można cofnąć.';
  }

  @override
  String get weOmegaShop => 'SKLEP OMEGA';

  @override
  String get weNowHunting => 'TERAZ POLUJEMY';

  @override
  String get weDamageLabel => 'Obrażenia: ';

  @override
  String weEndsIn(Object d, Object h, Object m) {
    return 'Wydarzenie kończy się za  ${d}d ${h}h ${m}m';
  }

  @override
  String get weHowToEarn => 'JAK ZARABIAĆ ŻETONY';

  @override
  String weHowToEarnDesc(String name) {
    return '$name mają 15% szans na pojawienie się podczas dowolnej walki. Pokonaj je, aby zdobyć 1–3 Żetony Wydarzeń każdy.';
  }

  @override
  String get weEventBoss => '⚔ BOSS WYDARZENIA';

  @override
  String get weClaimLegendary =>
      'ZDOBĄDŹ LEGENDARNE WYPOSAŻENIE  (1 🏆 Żeton Bossa)';

  @override
  String weGearForged(String name, Object lv) {
    return '$name wykuty na Lv$lv! Sprawdź swoją torbę.';
  }

  @override
  String weRewardClaimed(String name) {
    return '$name odebrane!';
  }

  @override
  String get gauLeaderboard => 'Ranking Gauntlet';

  @override
  String get gauRewardPreview => 'PODGLĄD NAGRODY (po oczyszczeniu)';

  @override
  String get gauAutoRestart => 'AUTO — restartuje z twoimi modyfikatorami—';

  @override
  String get gauBackToGauntlet => 'WRÓĆ DO GAUNTLET';

  @override
  String gauWave(Object n, Object total) {
    return 'FALA $n / $total';
  }

  @override
  String gauKills(Object kills) {
    return '$kills ZABIĆ';
  }

  @override
  String gauEssenceBonus(Object pct) {
    return '+$pct% esencji';
  }

  @override
  String get brLeaderboard => 'Ranking Boss Rush';

  @override
  String get brBestScore => 'NAJLEPSZY WYNIK: ';

  @override
  String brBossProgress(Object n, Object total) {
    return 'BOSS $n / $total';
  }

  @override
  String get brPlayAgain => 'GRAJ PONOWNIE';

  @override
  String get brPossibleRewards => 'MOŻLIWE NAGRODY';

  @override
  String get brRewShards => 'Odłamki';

  @override
  String get brRewShardsD => '10 za bossa  ·  +30 za pełne oczyszczenie';

  @override
  String get brRewEchoes => 'Echa';

  @override
  String get brRewEchoesD => '6 za bossa  ·  +25 za pełne oczyszczenie';

  @override
  String get brRewZcoins => 'ZCoins';

  @override
  String get brRewZcoinsD => '15 za pełne oczyszczenie';

  @override
  String get brRewMythril => 'Mithryl';

  @override
  String get brRewMythrilD => 'Skalowane przez końcowy rank';

  @override
  String get brRewArtifact => 'Artefakt';

  @override
  String get brRewArtifactD => 'Szansowy drop przy oczyszczeniu rangi A / S';

  @override
  String get prgShop => 'SKLEP PARAGON';

  @override
  String get prgActiveBonuses => 'AKTYWNE BONUSY';

  @override
  String get prgBoard => '✦ TABLICA PARAGON';

  @override
  String get prgBoardHint =>
      'Inwestuj punkty w kierunek — rangi skalują się w nieskończoność.';

  @override
  String prgRank(Object rank) {
    return 'Ranga $rank';
  }

  @override
  String get prgTutorial =>
      '✦ Punkty Paragonu zdobywa się przez awansowanie — 1 za poziom. Wydawaj je na Tablicy Paragon i w Sklepie poniżej dla trwałej mocy, która nigdy nie jest resetowana.';

  @override
  String get prgShopSub =>
      'Wydawaj Punkty Paragonu na trwałe ulepszenia, które utrzymują się we wszystkich przyszłych runach.';

  @override
  String achClaimedTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🏆  $count OSIĄGNIĘĆ ODEBRANYCH',
      few: '🏆  $count OSIĄGNIĘCIA ODEBRANE',
      one: '🏆  $count OSIĄGNIĘCIE ODEBRANE',
    );
    return '$_temp0';
  }

  @override
  String get achYouReceived => 'Otrzymałeś:';

  @override
  String get achNice => 'SUPER!';

  @override
  String achClaimAll(Object n) {
    return 'ODBIERZ WSZYSTKO ($n)';
  }

  @override
  String get achEconomy => 'EKONOMIA I SYSTEMY';

  @override
  String get achProgress => 'POSTĘP';

  @override
  String achClaimed(Object claimed, Object total) {
    return '$claimed / $total odebranych';
  }

  @override
  String achReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count osiągnięć gotowych do odebrania!',
      few: '$count osiągnięcia gotowe do odebrania!',
      one: '$count osiągnięcie gotowe do odebrania!',
    );
    return '$_temp0';
  }

  @override
  String get runeTitle => 'RUNY UMIEJĘTNOŚCI';

  @override
  String get runeArcaneDust => '🌀 Arkański pył: ';

  @override
  String runeOwned(Object a, Object b) {
    return '📜 Posiadane: $a/$b';
  }

  @override
  String get runeNone => 'Brak dostępnych run dla tej klasy.';

  @override
  String get runeAppBar => 'RUNY';

  @override
  String get runeSocketed => 'OSADZONA';

  @override
  String get runeNotFound =>
      'Jeszcze nie znaleziona — upada od bossów, lochów, gauntlet i wypraw.';

  @override
  String get runeEquipFirst =>
      'Załóż pierścień lub amulet, aby osadzić tę runę.';

  @override
  String runeSocketInto(String name, Object cost) {
    return 'Osadź → $name  (🌀 $cost)';
  }

  @override
  String get runeBody =>
      'Osadzaj runy, aby trwale wzmacniać umiejętności.\nKażda runa modyfikuje określoną umiejętność — zwiększając obrażenia, czas trwania lub odnowienie.\nKosztuje arkański pył z rozkładania wyposażenia, klejnotów i run.';

  @override
  String get achTutorial =>
      'Pokonałeś swojego pierwszego bossa! 🏆 Osiągnięcia śledzą kamienie milowe i nagradzają ZCoins i Odłamki — odbieraj je tutaj i sprawdzaj często.';

  @override
  String get bbLocked => 'NAGRODY ZA BOSSÓW ZABLOKOWANE';

  @override
  String get bbLockedSub =>
      'Osiągnij etap 20 kampanii, aby rozpocząć polowanie na bossów dla nagród.';

  @override
  String bbTitle(Object t) {
    return 'NAGRODY ZA BOSSÓW  •  POZIOM $t';
  }

  @override
  String get bbDesc =>
      'Zabij każdego bossa kampanii dla jego nagrody. Osiągnij nowy poziom dla nowego zestawu z większymi nagrodami.';

  @override
  String get bbNoBounties => 'Brak dostępnych nagród.';

  @override
  String bbStageLv(Object n, Object lv) {
    return 'Etap Kampanii $n  •  Lv $lv';
  }

  @override
  String bbSlain(String name, String detail) {
    return '$name zabity!  $detail';
  }

  @override
  String bbStage(Object n) {
    return 'Etap $n';
  }

  @override
  String bbGearReward(String rarity) {
    return '🎁 Wyposażenie $rarity';
  }

  @override
  String bestTotalKills(Object n) {
    return '$n łącznych zabić';
  }

  @override
  String get bestTypeMaxed => 'TYP ZMAKSYMALIZOWANY';

  @override
  String bestGoldBonus(Object pct) {
    return '+$pct% złota';
  }

  @override
  String get bestKilled => 'zabity';

  @override
  String bestNextDmg(Object n) {
    return 'następne +1% obrażeń przy $n zabiciach';
  }

  @override
  String get lsTitle => 'CODZIENNE LOGOWANIE';

  @override
  String get lsComeBack => 'Wróć jutro po następną nagrodę!';

  @override
  String lsStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dni',
      few: '$count dni',
      one: '$count dzień',
    );
    return '$_temp0';
  }

  @override
  String lsClaimReward(String label) {
    return 'ODBIERZ  $label';
  }

  @override
  String get lsFullCycle => 'PEŁNY 30-DNIOWY CYKL';

  @override
  String lsDay(Object d) {
    return 'Dzień $d';
  }

  @override
  String get lsToday => 'DZIŚ';

  @override
  String get dashTitle => 'KARTA POSTACI';

  @override
  String get dashDailyReady => 'Codzienne wyzwanie gotowe do odebrania!';

  @override
  String get dashAbilityAfford =>
      'Ulepszenie umiejętności dostępne — odwiedź UMIEJĘTNOŚCI';

  @override
  String get dashPassiveAfford =>
      'Ulepszenie pasywne dostępne — odwiedź PASYWNE';

  @override
  String get dashEndlessAfford =>
      'Ulepszenie nieskończone dostępne — odwiedź ULEPSZENIA';

  @override
  String get dashNextAction => 'NASTĘPNA CZYNNOŚĆ';

  @override
  String get dashIncomeSummary => 'PODSUMOWANIE DOCHODÓW';

  @override
  String get dashIdleGold => 'Złoto pasywne';

  @override
  String get dashBattleKill => 'Bitwa/zabicie';

  @override
  String get dashExpeditions => 'Wyprawy';

  @override
  String get dashAchievementsNearby => 'POBLISKIE OSIĄGNIĘCIA';

  @override
  String dashDayLoginReward(Object day) {
    return 'NAGRODA ZA LOGOWANIE DZIEŃ $day';
  }

  @override
  String dashExpReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wypraw gotowych do zebrania!',
      few: '$count wyprawy gotowe do zebrania!',
      one: '$count wyprawa gotowa do zebrania!',
    );
    return '$_temp0';
  }

  @override
  String dashMercsIdle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count najemników bezczynnych — wyślij na wyprawę',
      few: '$count najemników bezczynnych — wyślij na wyprawę',
      one: '$count najemnik bezczynny — wyślij na wyprawę',
    );
    return '$_temp0';
  }

  @override
  String get emTitle => 'MISTRZOSTWO ŻYWIOŁÓW';

  @override
  String emShards(Object n) {
    return '$n odłamków';
  }

  @override
  String get emUp => 'W GÓRĘ';

  @override
  String get spResetsMonthly => '📅 Resetuje co miesiąc';

  @override
  String get spUnlockPremium =>
      'Odblokuj Karnet Premium — 2× XP + ścieżka premium';

  @override
  String get spFree => 'DARMOWE';

  @override
  String get spPremium => '👑 PREMIUM';

  @override
  String get spTier => 'Poziom';

  @override
  String spClaimed(Object reward) {
    return 'Odebrano $reward';
  }

  @override
  String get spAllUnlocked => 'Wszystkie poziomy odblokowane — świetna robota!';

  @override
  String spXpToTier(Object xp, Object next, Object tier) {
    return '$xp / $next XP do Poziomu $tier';
  }

  @override
  String spClaimedN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Odebrano $n nagród',
      few: 'Odebrano $n nagrody',
      one: 'Odebrano 1 nagrodę',
    );
    return '$_temp0';
  }

  @override
  String get spNothingToClaim => 'Brak nagród do odebrania';

  @override
  String get euEchoes => 'Echa';

  @override
  String get euYourBalance => 'Twoje saldo';

  @override
  String get euEchoesCap => 'ECHA';

  @override
  String get euTutorial =>
      'Runy Gauntlet zdobywają Echa 🔊 — wydaj je tutaj na trwałe ulepszenia bojowe, które nigdy nie są resetowane. To jedne z najpotężniejszych bonusów w grze.';

  @override
  String get euPermanent =>
      'Ulepszenia są trwałe dla postaci. Bonusy stosują się we wszystkich trybach gry.';

  @override
  String euForLv(Object n) {
    return 'dla Lv $n';
  }

  @override
  String get euActive => 'AKTYWNE';

  @override
  String get lbRefresh => 'Odśwież';

  @override
  String get lbNoScores => 'Brak wyników — bądź pierwszy!';

  @override
  String get lbPersonalBest => 'Twój osobisty rekord';

  @override
  String get lbRank => 'RANK';

  @override
  String get lbYou => 'TY';

  @override
  String get lbError => 'Nie można załadować rankingu.';

  @override
  String get lbNotRanked => 'Jeszcze bez ranku';

  @override
  String get cmTitle => 'MODYFIKATORY WYZWAŃ';

  @override
  String get cmOptionalHandicaps => 'OPCJONALNE UTRUDNIENIA';

  @override
  String get cmActive => 'Aktywne: ';

  @override
  String get cmClear => 'WYCZYŚĆ';

  @override
  String get cmDesc =>
      'Aktywuj maksymalnie jeden modyfikator przed wejściem do Kampanii lub Lochu. Modyfikatory utrudniają bitwy, ale zwiększają nagrody za odłamki za zabicie.';

  @override
  String cmEssence(Object pct) {
    return '+$pct% esencji';
  }

  @override
  String cmEnemyHp(Object mult) {
    return 'HP wroga ×$mult';
  }

  @override
  String cmEnemyAtk(Object mult) {
    return 'ATK wroga ×$mult';
  }

  @override
  String cmHeroHp(Object mult) {
    return 'HP bohatera ×$mult';
  }

  @override
  String get wClose => 'ZAMKNIJ';

  @override
  String get battleLog => 'DZIENNIK BITWY';

  @override
  String get buffDodge => 'UNIK';

  @override
  String get buffStun => 'OGŁUSZENIE';

  @override
  String get dhPowerTip =>
      'Moc Średniowieczna — łączna ocena wszystkich twoich ulepszeń,\nwyposażenia, pasywnych, prestiżu, artefaktów i sojuszników.';

  @override
  String dhHpTip(Object regen) {
    return 'Punkty zdrowia — osiągnij 0 i przegrywasz bitwę.\nRegeneracja: $regen HP/rundę';
  }

  @override
  String dhXpTip(Object xp, Object lv, Object next) {
    return 'Doświadczenie — osiągnij $xp, aby awansować.\nPoziom $lv → $next';
  }

  @override
  String get dhNice => 'SUPER';

  @override
  String get bspAbilities => 'UMIEJĘTNOŚCI';

  @override
  String get bspMercs => 'NAJEMNICY';

  @override
  String get bspEnemyStun => 'OGŁUSZENIE wroga';

  @override
  String get bspPassive => 'PASYWNE';

  @override
  String bspDescAtk(Object pct) {
    return 'Twój bohater zadaje +$pct% obrażeń za trafienie.';
  }

  @override
  String bspDescArmor(Object pct) {
    return '+$pct% Klasy Pancerza — redukuje napływające obrażenia od wroga.';
  }

  @override
  String get bspDescDodge =>
      'Twój bohater całkowicie uniknie następnego ataku wroga.';

  @override
  String bspDescAura(Object hp) {
    return 'Aura leczenia — przywraca $hp HP na początku każdej rundy.';
  }

  @override
  String bspDescDot(Object dmg) {
    return 'Obrażenia w czasie — wróg otrzymuje $dmg obrażeń każdą rundę.';
  }

  @override
  String get bspDescStun => 'Wróg jest ogłuszony i pomija swój atak.';

  @override
  String get baMercAbility => 'ZDOLNOŚĆ NAJEMNIKA';

  @override
  String get tsCleared => 'OCZYSZCZONY';

  @override
  String get sgFullyUpgraded => 'W PEŁNI ULEPSZONY';

  @override
  String sgNeedGold(Object cost) {
    return 'Potrzeba $cost złota do ulepszenia';
  }

  @override
  String get fsVictory => 'ZWYCIĘSTWO';

  @override
  String get fsDefeat => 'PORAŻKA';

  @override
  String fsVs(String enemy, Object rounds) {
    return 'vs $enemy  ·  $rounds rund';
  }

  @override
  String get fsAbilitiesUsed => 'UŻYTE UMIEJĘTNOŚCI';

  @override
  String get wnTitle => 'CO NOWEGO';

  @override
  String get wnLatest => 'NAJNOWSZE';

  @override
  String get zcShards => 'Odłamki';

  @override
  String get idbNoItem =>
      'Brak założonego przedmiotu — bezpośrednie ulepszenie!';

  @override
  String get absTitle => 'ATRYBUTY UMIEJĘTNOŚCI';

  @override
  String get absBanner =>
      'Atrybuty Umiejętności to trwałe ulepszenia kupowane za złoto.\nUlepszaj dowolny atrybut swobodnie — złoto jest jedynym wymaganiem.';

  @override
  String get absMaxed => 'ZMAKSYMALIZOWANE';

  @override
  String absNext(Object cost) {
    return 'Następny: $cost złota';
  }

  @override
  String absRankOf(Object rank, Object max) {
    return 'Ranga $rank / $max';
  }

  @override
  String get bestUndiscovered =>
      'Zabij to stworzenie, aby ujawnić jego tajemnice.';

  @override
  String shopAdOffer(Object n, Object left, Object max) {
    return 'Zdobądź $n ZCoins za reklamę  •  $left/$max pozostałych';
  }

  @override
  String get shopLifetimeTitle => 'Wieczny Pakt';

  @override
  String get shopLifetimeTagline =>
      'Jeden zakup. Wszystkie korzyści Premium. Na zawsze.';

  @override
  String get shopLifetimeBadge => 'NAJLEPSZA OFERTA';

  @override
  String get shopLifetimeOwned => '✓ ODBLOKOWANE NA ZAWSZE';

  @override
  String shopLifetimeBuy(Object price) {
    return 'ODBLOKUJ NA ZAWSZE  ·  $price';
  }

  @override
  String get shopLifetimeIncludes => 'WSZYSTKO W ZESTAWIE';

  @override
  String get shopLifetimePerk1 => 'Wszystkie korzyści Korony Wstępującej';

  @override
  String get shopLifetimePerk2 => '3× prędkość bitwy';

  @override
  String get shopLifetimePerk3 => 'Auto-Kampania';

  @override
  String get shopLifetimePerk4 => '+50% złota z bezczynności';

  @override
  String get shopLifetimePerk5 => '2× XP przepustki sezonowej';

  @override
  String get shopLifetimePerk6 => 'Nagrody Premium przepustki sezonowej';

  @override
  String get shopLifetimePerk7 => 'Dostęp do Symulatora Bitwy';

  @override
  String get shopLifetimePerk8 => 'Żadnych cyklicznych opłat — nigdy';

  @override
  String get ratingTitle => 'Podoba Ci się Zeta Idle?';

  @override
  String get ratingBody =>
      'Grasz już od jakiegoś czasu! Jeśli dobrze się bawisz, szybka ocena bardzo pomaga grze się rozwijać. 🙏';

  @override
  String get ratingLove => 'Uwielbiam!';

  @override
  String get ratingMeh => 'Niezbyt';

  @override
  String get saveHeroTitle => 'Zapisz bohatera';

  @override
  String get saveHeroBody =>
      'Zaloguj się przez Google, aby zapisać postępy w chmurze. Zabezpiecz swojego bohatera i przenoś go między urządzeniami — za darmo, w sekundę.';

  @override
  String get saveHeroLater => 'Później';

  @override
  String get saveHeroConfirm => 'Zapisz bohatera';

  @override
  String get saveHeroSynced => 'Postęp zapisany w chmurze.';

  @override
  String get saveHeroFailed => 'Logowanie nie zostało ukończone.';

  @override
  String get firstStepsTitle => 'PIERWSZE KROKI';

  @override
  String get firstStepsSubtitle =>
      'Ukończ je, aby poznać podstawy i zgarnąć Rzadką Skrzynię.';

  @override
  String get firstStepsWinBattle => 'Wygraj pierwszą walkę';

  @override
  String get firstStepsReachStage3 => 'Osiągnij etap 3';

  @override
  String get firstStepsFirstBoss => 'Pokonaj pierwszego bossa';

  @override
  String get firstStepsReachStage10 => 'Osiągnij etap 10';

  @override
  String get firstStepsCapstone => 'Odbierz Rzadką Skrzynię';

  @override
  String get firstStepsClaim => 'ODBIERZ';

  @override
  String get firstStepsClaimed => 'Odebrano';

  @override
  String get firstStepsInProgress => 'W toku';

  @override
  String get firstStepsLocked => 'Zablokowane';
}
