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

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonContinue => 'CONTINUE';

  @override
  String heroFalls(String name) {
    return '$name FALLS';
  }

  @override
  String get battleGrowStronger => 'Grow stronger before trying again.';

  @override
  String get battleBackToHero => 'BACK TO HERO';

  @override
  String get defeatEndlessTitle => 'ENDLESS MODE';

  @override
  String get defeatEndlessHint => 'Farm XP & gold at your pace';

  @override
  String get defeatDungeonHint => 'Earn shards & items';

  @override
  String get defeatGauntletHint => 'Earn echoes for upgrades';

  @override
  String get defeatDailyTitle => 'DAILY CHALLENGES';

  @override
  String get defeatDailyHint => 'Claim rewards for progress';

  @override
  String battleTierUnlocked(int tier) {
    return 'TIER $tier UNLOCKED';
  }

  @override
  String get battleCampaignCleared => 'CAMPAIGN CLEARED';

  @override
  String battleTierUnlockedBody(int tier) {
    return 'The Omega has fallen. The campaign restarts at Tier $tier — tougher enemies and better loot.\n\nYour level, Paragon, gear and currencies all carry over. Nothing resets.';
  }

  @override
  String get battleCampaignClearedBody =>
      'The Omega has fallen at the highest tier. You\'ve reached the summit — keep farming for loot and Paragon Points.';

  @override
  String get battleSwitchTiersHint =>
      'Switch tiers anytime from the Campaign header.';

  @override
  String get battleRetreat => 'Retreat';

  @override
  String get battleLastFightSummary => 'Last fight summary';

  @override
  String get battleResume => 'Resume';

  @override
  String get battlePause => 'Pause';

  @override
  String get battleAutoCampaignLocked =>
      'Auto-Campaign — Speed Boost / Premium Pass';

  @override
  String get battleAutoCampaignOn => 'Auto-Campaign: ON';

  @override
  String get battleAutoCampaignOff => 'Auto-Campaign: OFF';

  @override
  String get battleNoFightYet => 'No fight finished yet.';

  @override
  String get battleAutoCampaignPerk =>
      'Auto-Campaign is a Speed Boost / Premium Pass perk.';

  @override
  String get battleNoActiveBattle => 'NO ACTIVE BATTLE';

  @override
  String get battleVictory => 'VICTORY!';

  @override
  String get battleBossDefeated => 'BOSS DEFEATED';

  @override
  String get battleNewContentUnlocked => 'NEW CONTENT UNLOCKED';

  @override
  String get battleClassQuestlineUnlocked => 'CLASS QUESTLINE UNLOCKED';

  @override
  String battleClassQuestlineBody(String className) {
    return 'The $className path begins. Complete 5 quests to unlock your Ultimate Ability.';
  }

  @override
  String battleRewardGold(String amount) {
    return '+$amount GOLD';
  }

  @override
  String battleRewardXp(String amount) {
    return '+$amount XP';
  }

  @override
  String battleRewardShards(String amount) {
    return '+$amount SHARDS';
  }

  @override
  String battleAbilityUnlocked(String name) {
    return 'ABILITY UNLOCKED: $name';
  }

  @override
  String get battleAddedToBag => 'Added to Bag';

  @override
  String get battleFight => 'FIGHT  (−1 ⚡)';

  @override
  String get battleSpeedBoostTitle => '2× Speed Boost';

  @override
  String battleSpeedBoostBody(int cost, int have) {
    return 'Unlock 2× battle speed for 7 days?\n\nCost: $cost ZCoins\nYour ZCoins: $have';
  }

  @override
  String get battlePurchase => 'Purchase';

  @override
  String get battleNotEnoughZcoins => 'Not enough zcoins!';

  @override
  String get battleArtifactFound => 'ARTIFACT FOUND!';

  @override
  String battleRoundsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rounds remaining',
      one: '$count round remaining',
    );
    return '$_temp0';
  }

  @override
  String get commonOk => 'OK';

  @override
  String get campaignDifficultyTier => 'DIFFICULTY TIER';

  @override
  String get campaignDifficultyTierTooltip => 'Difficulty Tier';

  @override
  String get campaignTierSelectorBody =>
      'Higher tiers = tougher enemies AND better loot (rarity, sets, artifacts). Switching down keeps all your permanent power — it only scales what you fight and what drops.';

  @override
  String get campaignTierNormal => 'TIER 0 — Normal';

  @override
  String campaignTierN(int tier) {
    return 'TIER $tier';
  }

  @override
  String get campaignTierBaseDesc => 'Base enemies · base loot · no Magic Find';

  @override
  String campaignTierScaledDesc(int hp, int atk) {
    return 'Enemies +$hp% HP · +$atk% ATK';
  }

  @override
  String campaignTierMagicFind(int mf) {
    return '✦ +$mf% Magic Find (higher rarity, sets & artifacts)';
  }

  @override
  String get campaignLeaderboardTooltip => 'Campaign Leaderboard';

  @override
  String get campaignTutorial =>
      'Campaign advances stage by stage. Defeat each boss to unlock the next. Clear the final boss to unlock the next difficulty Tier — the campaign restarts harder with better loot, and your power carries over.';

  @override
  String campaignEnergyRecharge(String time) {
    return '+1 in $time';
  }

  @override
  String campaignEnergyRefill(int amount, int left) {
    return 'Refill +$amount  ($left free left)';
  }

  @override
  String get campaignBuy => 'Buy ';

  @override
  String get campaignEnergyEmptyTutorial =>
      'Out of energy! ⚡ It refills 1 every 5 min. Tap the +10 button above for 3 free daily refills. Or buy +20 energy for 💎 50 ZCoins.';

  @override
  String get campaignStageMap => 'STAGE MAP  •  tap any ✓ node to replay';

  @override
  String get campaignNoEnergyRefill => 'No energy! Wait for it to refill.';

  @override
  String campaignSimulateStage(int stage) {
    return '⚡ Simulate Stage $stage';
  }

  @override
  String campaignEnergyAvailable(int count) {
    return 'Energy available: $count';
  }

  @override
  String get campaignSimInfo =>
      'Battles run instantly. Loot goes straight to your bag.';

  @override
  String campaignSimAll(int count) {
    return 'ALL ($count)';
  }

  @override
  String campaignSimResultTitle(int stage, int count) {
    return 'Stage $stage — $count× Simulated';
  }

  @override
  String get campaignSimGold => '💰 Gold';

  @override
  String get campaignSimXp => '✦ XP';

  @override
  String campaignItemsDropped(int count) {
    return 'Items dropped ($count):';
  }

  @override
  String get campaignNoItemsDropped => 'No items dropped this run.';

  @override
  String get campaignNotEnoughEnergy => 'Not enough energy!';

  @override
  String get campaignMapFight => '⚔  FIGHT (−1 ⚡)';

  @override
  String get campaignSimRequiresPremium => 'Requires Premium Pass subscription';

  @override
  String get campaignBossEncounter => 'BOSS ENCOUNTER';

  @override
  String get campaignDismiss => '[ dismiss ]';

  @override
  String campaignPerfectStages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count perfect stages',
      one: '$count perfect stage',
    );
    return '$_temp0';
  }

  @override
  String campaignNextMilestone(int next) {
    return '• next milestone at $next (+mythril +Z-Coins)';
  }

  @override
  String get campaignAllMilestones => '• all milestones cleared!';

  @override
  String get hubWhatsNew => 'What\'s New';

  @override
  String get hubLootLog => 'Loot Log';

  @override
  String get hubSettings => 'Settings';

  @override
  String get hubChange => 'CHANGE';

  @override
  String get hubHeroMenu => 'Hero menu';

  @override
  String get hubJoinDiscord => 'Join our Discord';

  @override
  String get hubVisitReddit => 'Visit r/zeta_idle';

  @override
  String hubCouldNotOpen(String url) {
    return 'Could not open $url';
  }

  @override
  String get hubLocked => 'Locked';

  @override
  String get hubGroupCharacter => 'CHARACTER';

  @override
  String get hubGroupProgression => 'PROGRESSION';

  @override
  String get hubGroupCollection => 'COLLECTION';

  @override
  String get hubGroupRecords => 'RECORDS';

  @override
  String get hubBlurbCharacter => 'Your build & power';

  @override
  String get hubBlurbProgression => 'Endgame systems';

  @override
  String get hubBlurbCollection => 'Allies & compendium';

  @override
  String get hubBlurbRecords => 'Goals & breakdowns';

  @override
  String get hubSheet => 'SHEET';

  @override
  String get hubScores => 'SCORES';

  @override
  String get hubAbilities => 'ABILITIES';

  @override
  String get hubPassives => 'PASSIVES';

  @override
  String get hubSpecialize => 'SPECIALIZE';

  @override
  String get hubParagon => 'PARAGON';

  @override
  String get hubUpgrades => 'UPGRADES';

  @override
  String get hubAscend => 'ASCEND';

  @override
  String get hubMastery => 'MASTERY';

  @override
  String get hubPets => 'PETS';

  @override
  String get hubMercs => 'MERCS';

  @override
  String get hubBestiary => 'BESTIARY';

  @override
  String get hubCodex => 'CODEX';

  @override
  String get hubArmory => 'ARMORY';

  @override
  String get hubAchievements => 'ACHIEVEMENTS';

  @override
  String get hubBonuses => 'BONUSES';

  @override
  String get auShards => 'shards';

  @override
  String get auRespecTitle => 'Respec Abilities?';

  @override
  String auRespecBody(int cost) {
    return 'Reset all ability ranks and milestone choices.\nAll shards spent will be refunded.\n\nCost: $cost ZCoins';
  }

  @override
  String auRespecConfirm(int cost) {
    return 'RESPEC ($cost ZC)';
  }

  @override
  String get auRespec => 'RESPEC';

  @override
  String get auTutorial =>
      'You earned Shards ◆ — spend them here to unlock and upgrade class abilities that fire automatically in every battle.';

  @override
  String get auIntro =>
      'Spend shards to empower your abilities. Milestones at ranks 5, 10 and 15. Tier up after rank 15 — each tier unlocks with your difficulty Tier.';

  @override
  String get auTitle => 'ABILITY UPGRADES';

  @override
  String get auMaxTier => 'MAX TIER  ✦';

  @override
  String auTierLockedLabel(int tier, int req) {
    return 'TIER $tier  —  Requires Difficulty Tier $req';
  }

  @override
  String get auAscension => 'ASCENSION';

  @override
  String auTierUnlocked(int cap) {
    return 'Tier $cap unlocked';
  }

  @override
  String auAscFullyAscended(int pct) {
    return 'Fully ascended  ·  +$pct% ability power';
  }

  @override
  String auAscTierLocked(int cur, int next) {
    return '+$cur% power  ·  Unlock difficulty Tier $next (rebirth) to ascend further';
  }

  @override
  String auAscUpgrade(int cur, int next, int cost) {
    return '+$cur%  →  +$next% power  ·  costs $cost ✦ Paragon';
  }

  @override
  String auAscYouHave(int have) {
    return '  (you have $have)';
  }

  @override
  String get auMax => 'MAX';

  @override
  String get auLocked => 'LOCKED';

  @override
  String auAscendBtn(int cost) {
    return 'ASCEND  $cost ✦';
  }

  @override
  String get auUltimate => 'ULTIMATE';

  @override
  String auUnlocksLv(int lv) {
    return 'UNLOCKS LV $lv';
  }

  @override
  String get auFinishQuestline => '🔒 Finish your class questline to unlock';

  @override
  String auReachLevel(int lv, int cur) {
    return 'Reach Level $lv  (you: Lv $cur)';
  }

  @override
  String auCompleteQuests(String className, int claimed) {
    return 'Complete all 5 $className class quests  ($claimed / 5)';
  }

  @override
  String get auTrackQuests => 'Track your quests in the Quests tab.';

  @override
  String get auChoose => 'CHOOSE';

  @override
  String get setTitle => 'SETTINGS';

  @override
  String get setSave => 'SAVE';

  @override
  String get setLoad => 'LOAD';

  @override
  String get setReset => 'RESET';

  @override
  String get setOpen => 'OPEN';

  @override
  String get setView => 'VIEW';

  @override
  String get setEmail => 'EMAIL';

  @override
  String get setConfirm => 'CONFIRM';

  @override
  String get setSecAccount => 'ACCOUNT';

  @override
  String get setSecPromo => 'PROMO CODE';

  @override
  String get setSecAudio => 'AUDIO';

  @override
  String get setSecHaptics => 'HAPTICS';

  @override
  String get setSecNotifications => 'NOTIFICATIONS';

  @override
  String get setSecDisplay => 'DISPLAY';

  @override
  String get setSecStats => 'STATS';

  @override
  String get setSecAutoLoot => 'AUTO-LOOT';

  @override
  String get setSecBattle => 'BATTLE';

  @override
  String get setSecDailyReset => 'DAILY RESET';

  @override
  String get setSecSave => 'SAVE';

  @override
  String get setSecDanger => 'DANGER ZONE';

  @override
  String get setSecHelp => 'HELP';

  @override
  String get setSecAbout => 'ABOUT';

  @override
  String get setManage => 'MANAGE';

  @override
  String get setSignIn => 'SIGN IN';

  @override
  String get setHeroName => 'Hero Name';

  @override
  String setRename(int cost) {
    return 'RENAME ($cost 🪙)';
  }

  @override
  String get setPromoHint => 'Got a code? Redeem it here for rewards.';

  @override
  String get setRedeem => 'REDEEM';

  @override
  String get setSoundEffects => 'Sound Effects';

  @override
  String get setBackgroundMusic => 'Background Music';

  @override
  String get setVolume => 'Volume';

  @override
  String get setVibration => 'Vibration';

  @override
  String get setReminders => 'Reminders';

  @override
  String get setDamageNumbers => 'Damage Numbers';

  @override
  String get setReducedParticles => 'Reduced Particles';

  @override
  String get setTotalPlaytime => 'Total Playtime';

  @override
  String get setAutoSalvage => 'Auto-Salvage';

  @override
  String get setAutoEquip => 'Auto-Equip Upgrades';

  @override
  String get setAutoEquipSub =>
      'Automatically equip items better than current gear';

  @override
  String get setBattleSpeed => 'Battle Speed';

  @override
  String get setAutoCampaign => 'Auto-Campaign';

  @override
  String get setResetTime => 'Reset Time';

  @override
  String get setCloudSave => 'Cloud Save';

  @override
  String get setCloudSaveSub => 'Sync your progress to the cloud';

  @override
  String get setCloudSaveComplete => 'Cloud save complete.';

  @override
  String get setLoadCloud => 'Load from Cloud';

  @override
  String get setLoadCloudSub => 'Overwrite local save with cloud data';

  @override
  String get setResetProgress => 'Reset Progress';

  @override
  String get setResetProgressSub =>
      'Delete all save data for this slot. Irreversible.';

  @override
  String get setKnowledgeBase => 'Knowledge Base';

  @override
  String get setKnowledgeBaseSub => 'Keywords, systems, currencies explained';

  @override
  String get setTagline => 'A dark medieval idle RPG.';

  @override
  String get setAboutHero => 'Hero';

  @override
  String get setAboutClass => 'Class';

  @override
  String get setAboutLevel => 'Level';

  @override
  String get setAboutPrestige => 'Prestige';

  @override
  String get setAboutAchievements => 'Achievements';

  @override
  String get setAboutDeveloper => 'Developer';

  @override
  String get setAboutContact => 'Contact';

  @override
  String get setPrivacy => 'Privacy Policy';

  @override
  String get setPrivacySub => 'How we handle your data';

  @override
  String get setReportBug => 'Report a Bug / Feedback';

  @override
  String get setReportBugSub => 'Email us — device info is added automatically';

  @override
  String get setReplayTips => 'Replay Tips';

  @override
  String get setReplayTipsSub => 'Show the in-game tutorial tips again';

  @override
  String get setTipsReset =>
      'Tutorial tips reset — they\'ll reappear as you explore.';

  @override
  String get setRenameHeroTitle => 'RENAME HERO';

  @override
  String get setHeroNameHint => 'Enter a hero name';

  @override
  String setRenameCost(int cost, int have) {
    return 'Cost: $cost 🪙   (you have $have)';
  }

  @override
  String setRenameNotEnough(int cost) {
    return 'Not enough Z-Coins — rename costs $cost 🪙.';
  }

  @override
  String get setNoEmailApp =>
      'No email app found. Reach us at razorintegrations@gmail.com';

  @override
  String get setDailyResetTitle => 'Daily Reset Time';

  @override
  String get setDailyResetHint => 'Choose the hour when daily limits reset.';

  @override
  String get setDailyResetWarning =>
      'Warning: you can only change this once per year.';

  @override
  String get setLoadCloudTitle => 'Load from Cloud?';

  @override
  String get setLoadCloudBody =>
      'This will overwrite your local save with cloud data. Local progress not yet synced will be lost.';

  @override
  String get setResetAllTitle => 'Reset all progress?';

  @override
  String get setResetAllBody =>
      'All progress, gold, items, prestige levels, and achievements will be permanently deleted. This cannot be undone.';

  @override
  String get setNewHeroName => 'New hero name:';

  @override
  String get setGoogleAccount => 'Google Account';

  @override
  String get setSignInGoogle => 'Sign in with Google';

  @override
  String get setSignedIn => 'Signed in';

  @override
  String get setSyncSaves => 'Sync saves across devices';

  @override
  String get setEnterCode => 'ENTER CODE';

  @override
  String get setOff => 'Off';

  @override
  String get setOffCaps => 'OFF';

  @override
  String get setHidden => 'Hidden';

  @override
  String get setVibrationOn =>
      'Vibrates on crits, level-ups, victories & rewards';

  @override
  String get setRemindersOn => 'Get \"come back\" reminders while you\'re away';

  @override
  String get setDamageOn => 'Floating numbers shown in battle';

  @override
  String get setParticlesOn => 'Fewer background effects (better performance)';

  @override
  String get setParticlesOff => 'Full effects';

  @override
  String get setSalvageOff => 'Tap to enable auto-salvage for drops';

  @override
  String setSalvageOn(String tier) {
    return 'Auto-salvages $tier and below';
  }

  @override
  String get setAutoCampaignOnSub =>
      'Automatically fight campaign battles in the background';

  @override
  String get setAutoCampaignLockedSub =>
      '🔒 Speed Boost / Premium Pass subscribers only';

  @override
  String setResetTimeOn(String time) {
    return 'Daily limits reset at $time. Tap to change (once per year).';
  }

  @override
  String setResetTimeLocked(String time) {
    return 'Resets at $time · Already changed this year.';
  }

  @override
  String get guildTitle => 'GUILD';

  @override
  String get guildJoinTitle => 'JOIN A GUILD';

  @override
  String get guildJoinBlurb =>
      'Guilds provide passive bonuses, a weekly boss challenge, and a guild shop with exclusive rewards.';

  @override
  String get guildCreate => 'CREATE GUILD';

  @override
  String get guildPublic => 'PUBLIC GUILDS';

  @override
  String get guildNoGuilds => 'No guilds found. Be the first to create one!';

  @override
  String get guildCreateTitle => 'Create Guild';

  @override
  String get guildNameLabel => 'Guild Name';

  @override
  String get guildDescLabel => 'Description (optional)';

  @override
  String get guildCreateBtn => 'CREATE';

  @override
  String get guildTabInfo => 'INFO';

  @override
  String get guildTabCastle => 'CASTLE';

  @override
  String get guildTabBoss => 'BOSS';

  @override
  String get guildTabWar => 'WAR';

  @override
  String get guildTabChat => 'CHAT';

  @override
  String get guildTabShop => 'SHOP';

  @override
  String guildCastleTier(int tier) {
    return 'CASTLE — TIER $tier / 10';
  }

  @override
  String guildProgressTier(int tier) {
    return 'Progress to Tier $tier';
  }

  @override
  String guildCpProgress(int cp, int cap) {
    return '$cp / $cap CP';
  }

  @override
  String guildNext(String headline) {
    return 'Next: $headline';
  }

  @override
  String get guildCitadelComplete =>
      'Citadel complete — the castle is fully built!';

  @override
  String get guildContributeGold => 'CONTRIBUTE GOLD';

  @override
  String guildContributeInfo(String rate, int cap) {
    return 'Convert gold to Construction Points (CP). Rate: $rate gold = 1 CP. You can add up to $cap CP per day.';
  }

  @override
  String get guildActiveBenefits => 'ACTIVE CASTLE BENEFITS';

  @override
  String get guildContributeHint =>
      'Contribute to raise the castle and unlock benefits.';

  @override
  String guildCastleAdvanced(int tier) {
    return '🏰 Castle advanced to Tier $tier!';
  }

  @override
  String get guildCapReached =>
      'Daily construction cap reached — come back tomorrow!';

  @override
  String guildLevelMembers(int lvl, int m, int max) {
    return 'Level $lvl  •  $m/$max members';
  }

  @override
  String guildBonusGold(int pct) {
    return '+$pct% Gold';
  }

  @override
  String guildBonusXp(int pct) {
    return '+$pct% XP';
  }

  @override
  String guildBonusIdle(int pct) {
    return '+$pct% Idle';
  }

  @override
  String guildXpProgress(int xp, int max) {
    return '$xp/$max XP';
  }

  @override
  String get guildDonate1000 => 'DONATE 1000 GOLD';

  @override
  String get guildDonateReward => '→ Guild XP + 🪙';

  @override
  String get guildPerks => 'PERKS';

  @override
  String guildLockedPerk(int lvl, String name, String desc) {
    return '🔒 Lv$lvl: $name — $desc';
  }

  @override
  String get guildMembers => 'MEMBERS';

  @override
  String guildMemberLine(int lvl, String cls, String role, int d) {
    return 'Lv$lvl $cls  •  $role  •  donated: ${d}g';
  }

  @override
  String get guildLeave => 'LEAVE GUILD';

  @override
  String get guildNoBoss => 'No boss this week.';

  @override
  String get guildWeeklyBoss => '☠ WEEKLY GUILD BOSS';

  @override
  String guildBossHp(int hp, int max) {
    return '$hp / $max HP';
  }

  @override
  String get guildDefeated => '✓ DEFEATED';

  @override
  String guildBossRewardMsg(Object rank, Object gc, Object gold) {
    return '🏆 Last week\'s boss: Rank #$rank — +$gc Guild Coins, +$gold gold';
  }

  @override
  String get guildClaimBossReward => '🏆 CLAIM LAST WEEK\'S BOSS REWARD';

  @override
  String guildAttempts(int rem, int max) {
    return 'Attempts: $rem / $max';
  }

  @override
  String get guildNoAttempts => 'NO ATTEMPTS LEFT';

  @override
  String get guildChallengeBoss => '⚔ CHALLENGE BOSS';

  @override
  String get guildDamageRanking => 'DAMAGE RANKING';

  @override
  String guildDmg(int dmg) {
    return '$dmg dmg';
  }

  @override
  String get guildWarStandings => 'WAR STANDINGS';

  @override
  String guildWarRecord(int w, int l) {
    return 'Your record: ${w}W–${l}L';
  }

  @override
  String get guildWeeklyWar => 'Weekly Guild War';

  @override
  String get guildWarBlurb =>
      'Enlist during Preparation (Mon–Tue). Wed–Fri, spend War Attacks to fight rival champions and earn points for your guild. Sat–Sun, claim rank rewards.';

  @override
  String get guildEnlistedBattle => '⚔ Enlisted! Spend your War Attacks now.';

  @override
  String get guildEnlistedPrep => '⚔ Enlisted! Return Wed–Fri to fight.';

  @override
  String get guildEnlist => 'ENLIST YOUR GUILD';

  @override
  String get guildWarEndedWait => 'WAR ENDED — WAIT FOR NEXT WEEK';

  @override
  String guildScoreYou(String name) {
    return '$name (you)';
  }

  @override
  String get guildLeads => '🏆 Your guild leads!';

  @override
  String get guildBehind => '⚠ Your guild is behind — fight!';

  @override
  String guildFightForGuild(int c, int max) {
    return '⚔ FIGHT FOR THE GUILD  ($c/$max)';
  }

  @override
  String get guildNoWarAttacks => 'NO WAR ATTACKS LEFT TODAY';

  @override
  String get guildWarRefresh =>
      'War Attacks refresh daily during the Battle phase.';

  @override
  String get guildWarVictory => '🏆 Victory!';

  @override
  String get guildWarOver => 'War over.';

  @override
  String guildWarRewardMsg(String result, Object gc, Object gold) {
    return '$result +$gc Guild Coins, +$gold gold';
  }

  @override
  String get guildRewardsClaimed => 'REWARDS CLAIMED';

  @override
  String get guildClaimWarRewards => 'CLAIM WAR REWARDS';

  @override
  String get guildWarBattleSoon =>
      'Battle begins Wednesday — come back to fight!';

  @override
  String get guildCoinsLabel => 'Guild Coins';

  @override
  String guildListLine(int lvl, int m, int max) {
    return 'Lv$lvl  •  $m/$max members';
  }

  @override
  String get guildJoin => 'JOIN';

  @override
  String get guildFull => 'FULL';

  @override
  String get guildBossTitle => 'GUILD BOSS';

  @override
  String get guildBossWin => '✦ BOSS DEFEATED!';

  @override
  String get guildBossLose => '💀 FALLEN';

  @override
  String guildTotalDamage(int d) {
    return 'Total damage dealt: $d';
  }

  @override
  String get guildReturn => 'RETURN TO GUILD';

  @override
  String guildCpAmount(int cp) {
    return '+$cp CP';
  }

  @override
  String guildGoldCost(String gold) {
    return '${gold}g';
  }

  @override
  String get forgeSalvageTooltip =>
      'Destroy items to recover Shards (◆).\n• Common → 3 ◆\n• Rare → 8 ◆\n• Epic → 20 ◆\n• Legendary → 60 ◆\n• Set → 100 ◆';

  @override
  String get forgeUpgradeTooltip =>
      'Upgrade an item from +0 to +10.\nEach tier boosts all stats by 8%.\nAt +5 and +10 the item gains a title prefix.\nCosts Gold + Shards per tier.';

  @override
  String get forgeTitle => 'FORGE';

  @override
  String get forgeSalvage => 'SALVAGE';

  @override
  String get forgeUpgrade => 'UPGRADE';

  @override
  String get forgeSlot => 'SLOT';

  @override
  String get forgeFrom => 'FROM  ';

  @override
  String forgeForged(String name, String label) {
    return 'Forged: $name ($label)!';
  }

  @override
  String get forgeSalvageRates => 'SALVAGE RATES';

  @override
  String forgeSalvageBtn(int n, int s) {
    return 'SALVAGE  $n  (+$s ◆)';
  }

  @override
  String get forgeBagEmpty => 'Your bag is empty.';

  @override
  String forgeBag(int n) {
    return 'BAG  ($n items)';
  }

  @override
  String forgeSalvaged(int earned) {
    return 'Salvaged: +$earned ◆';
  }

  @override
  String forgeTimesN(int n) {
    return ' ×$n';
  }

  @override
  String get forgeTimesRandom => '  ×1 (random)';

  @override
  String get forgeMasterForger => 'Master Forger';

  @override
  String get forgeSelected => 'SELECTED';

  @override
  String forgeSelectedCount(int selected, int needed) {
    return '$selected / $needed';
  }

  @override
  String get forgeArcaneDust => 'ARCANE DUST';

  @override
  String get forgeGemType => 'GEM TYPE';

  @override
  String forgeGemWeaponDesc(Object pct, String type) {
    return '⚔ Weapon: +$pct% $type damage';
  }

  @override
  String forgeGemArmorDesc(Object pct, String type) {
    return '🛡 Armor: +$pct% $type resistance';
  }

  @override
  String get forgeTier => 'TIER';

  @override
  String forgeGemBagFull(int n, int max) {
    return 'GEM BAG FULL ($n/$max)';
  }

  @override
  String forgeNeedMore(int n) {
    return 'NEED $n MORE 💠';
  }

  @override
  String forgeCraft(int cost) {
    return '✦  CRAFT  $cost 💠';
  }

  @override
  String forgePreviewWeapon(String effect) {
    return '⚔ Weapon: $effect';
  }

  @override
  String forgePreviewArmor(String effect) {
    return '🛡 Armor: $effect';
  }

  @override
  String forgeToCraft(int cost) {
    return '$cost 💠 to craft';
  }

  @override
  String forgeGemBag(int n, int max) {
    return 'GEM BAG  ($n/$max)';
  }

  @override
  String get forgeTapGem => 'Tap a gem to socket it into an item';

  @override
  String get forgeNoGems => 'No gems crafted yet. Craft one above!';

  @override
  String get forgeHowGems => 'HOW GEMS WORK';

  @override
  String get forgeGemsInfo =>
      '• Each gem is dual-purpose — the SAME gem gives elemental DAMAGE in a weapon, or elemental RESISTANCE in armor / jewelry.\n• Gem shards drop from combat kills (25% chance) and bosses.\n• Each item can hold 1 gem in its socket.\n• Socket gems from this bag, or via the Inventory screen.\n• Replacing or removing a gem destroys the old one.';

  @override
  String get forgeNoItemsSocket => 'No items to socket into.';

  @override
  String forgeSocketGem(String name) {
    return 'Socket $name';
  }

  @override
  String get forgeChooseItem => 'Choose an item to socket this gem into.';

  @override
  String get forgeReplaceGem => 'Replace Gem?';

  @override
  String forgeReplaceBody(String old, String gnew) {
    return '$old will be destroyed and replaced with $gnew. This cannot be undone.';
  }

  @override
  String get forgeReplace => 'REPLACE';

  @override
  String get forgeUpgradeInfo =>
      'Upgrade items from +0 to +10. Each tier boosts all stats by 8%.\nAt +5 the item earns a Refined prefix.\nAt +10 it becomes Masterwork.';

  @override
  String get forgeBalance => 'Balance: ';

  @override
  String get forgeNoUpgradeItems =>
      'No items available for upgrade.\nAll items are at +10 or bag is empty.';

  @override
  String get forgeSelectItem => 'SELECT ITEM';

  @override
  String get forgeAllStats => 'All stats +8%';

  @override
  String get forgeWeaponDmgSuffix => '  •  Weapon damage +8%';

  @override
  String get forgeRefinedPrefix => '🏷 Earns \"Refined\" prefix at +5!';

  @override
  String get forgeMasterworkPrefix => '🏷 Earns \"Masterwork\" prefix at +10!';

  @override
  String forgeUpgradeTo(int tier) {
    return 'UPGRADE TO +$tier';
  }

  @override
  String get dngTitle => 'THE DUNGEON';

  @override
  String dngTitleRun(int tier, int floor) {
    return 'T$tier  FL.$floor  —  THE DUNGEON';
  }

  @override
  String get dngFlee => 'Flee dungeon';

  @override
  String get dngAutoOn => 'Auto Run: ON — tap to take manual control';

  @override
  String get dngAutoOff => 'Auto Run: OFF — tap to auto-clear';

  @override
  String get dngAutoPremium => 'Auto Run (unlocks at Stage 5)';

  @override
  String get dngPushOnTip =>
      'Abyssal Push: ON — beat the Dungeon Lord to descend deeper';

  @override
  String get dngPushOffTip => 'Abyssal Push: OFF — run ends at the clear floor';

  @override
  String get dngPushOnMsg =>
      'Abyssal Push ON — clear the Dungeon Lord to descend into escalating abyss floors (richer Mythril + unique odds). Flee anytime to bank the clear.';

  @override
  String get dngPushOffMsg =>
      'Abyssal Push OFF — the run ends when you clear the Dungeon Lord.';

  @override
  String get dngLeaderboard => 'Dungeon Leaderboard';

  @override
  String get dngAutoPremiumMsg => 'Auto Run unlocks at campaign Stage 5.';

  @override
  String get dngTutorial =>
      'Choose one of two doors each floor. Slain enemies drop Bones — spend them at the Traveling Merchant for run-long buffs. Loot is yours immediately, even if your hero falls.';

  @override
  String get dngWhatToExpect => 'WHAT TO EXPECT';

  @override
  String get dngExpCombat => 'Combat — fight for gold';

  @override
  String get dngExpElite => 'Elite — tougher foe, guaranteed item drop';

  @override
  String get dngExpAmbush => 'Ambush — enemy strikes first, high gold';

  @override
  String get dngExpRest => 'Rest Site — recover 20% HP';

  @override
  String get dngExpTreasure => 'Treasure — claim gold & shards';

  @override
  String get dngExpShrine => 'Shrine — choose a run-long blessing';

  @override
  String get dngExpChest => 'Locked Chest — spend shards for a rare item';

  @override
  String get dngExpTrap => 'Trap — unavoidable damage';

  @override
  String get dngExpBoss => 'Boss (every 5th floor) — high risk, high reward';

  @override
  String get dngBonesHint =>
      'Slain enemies drop Bones — spend them at the Traveling Merchant.';

  @override
  String get dngExpectedLoot => 'EXPECTED LOOT';

  @override
  String get dngLootGold => 'Gold';

  @override
  String get dngLootGoldDetail => 'From combat, treasure rooms & rest supplies';

  @override
  String get dngLootShards => 'Shards';

  @override
  String get dngLootShardsDetail => 'Treasure rooms & chests along the run';

  @override
  String get dngLootItems => 'Items';

  @override
  String dngLootItemsDetail(String tier) {
    return 'Item tier at your depth: $tier  (elites & bosses drop better)';
  }

  @override
  String get dngLootMythril => 'Mythril';

  @override
  String dngLootMythrilDetail(int a, int b) {
    return '~$a at floor 5  •  ~$b at floor 10';
  }

  @override
  String dngYourBest(int f, int m) {
    return 'Your best: floor $f  •  ~$m mythril';
  }

  @override
  String get dngNoRecord => 'No record yet';

  @override
  String dngDeepestFloor(int f) {
    return 'Deepest floor: $f';
  }

  @override
  String dngDailyAttempts(int r, int max) {
    return 'Daily attempts: $r / $max';
  }

  @override
  String dngEnterTier(int tier) {
    return 'ENTER  TIER $tier';
  }

  @override
  String get dngNoAttempts => 'NO ATTEMPTS LEFT';

  @override
  String dngBuyExtra(int cost) {
    return '$cost ZCoins — Buy 1 extra attempt';
  }

  @override
  String get dngBossFloor => '☠ BOSS FLOOR';

  @override
  String dngBossIn(int n) {
    return '☠ Boss in $n';
  }

  @override
  String get dngChoosePath => 'CHOOSE YOUR PATH';

  @override
  String get dngNextBoss => '☠ NEXT FLOOR: BOSS';

  @override
  String get dngMystery => 'MYSTERY';

  @override
  String get dngGoblin => '💰 TREASURE GOBLIN';

  @override
  String get dngEnter => 'ENTER';

  @override
  String get dngMystery1 => 'An unmarked door.';

  @override
  String get dngMystery2 => 'Fortune or peril?';

  @override
  String dngGoblinHp(Object hp) {
    return '$hp HP  •  flees after 5 rounds';
  }

  @override
  String get dngGoblinReward => '6× gold if you slay it in time!';

  @override
  String get dngGuaranteedDrop => 'Guaranteed item drop';

  @override
  String get dngStrikesFirst => 'Strikes first — high gold';

  @override
  String get dngDoorBlessing => 'A blessing...';

  @override
  String get dngDoorCurse => 'or a curse?';

  @override
  String get dngMakeCamp => 'Make camp';

  @override
  String get dngRecoverHp => 'Recover HP';

  @override
  String get dngRareInside => 'Rare item inside';

  @override
  String dngShardsToOpen(Object n) {
    return '$n shards to open';
  }

  @override
  String dngPlusGold(Object g) {
    return '+$g gold';
  }

  @override
  String dngPlusShards(Object s) {
    return '+$s shards';
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
  String get dngEnemy => 'Enemy';

  @override
  String get dngSpeedNeeds =>
      'Higher speed needs the Speed Boost / Premium Pass.';

  @override
  String get dngTreasureFound => 'Treasure Found!';

  @override
  String get dngCursed => '✸ CURSED!';

  @override
  String get dngBlessed => '✧ BLESSED!';

  @override
  String get dngDarkToll => 'The darkness takes its toll...';

  @override
  String get dngAncientPower => 'Ancient power flows through you.';

  @override
  String get dngLightShadow => 'Light and shadow bind themselves to your fate.';

  @override
  String get dngShrineCorrupted => 'Corrupted Shrine';

  @override
  String get dngShrineBlessed => 'Blessed Shrine';

  @override
  String get dngShrineAncient => 'Ancient Shrine';

  @override
  String get dngShrineCorruptedFlavor =>
      'Dark energies pulse and writhe. A curse is certain — but power awaits.';

  @override
  String get dngShrineBlessedFlavor =>
      'Warm divine light emanates from this place. A blessing is guaranteed.';

  @override
  String get dngShrineTwinFlavor =>
      'Two forces stir within — you will receive both a blessing and a curse.';

  @override
  String get dngShrineNormalFlavor =>
      'A mysterious shrine pulses with unknown energy.\nEnter to receive a blessing... or a curse.\nYou won\'t know which until it\'s too late.';

  @override
  String get dngAcceptCurse => 'ACCEPT THE CURSE';

  @override
  String get dngReceiveBlessing => 'RECEIVE BLESSING';

  @override
  String get dngEnterTwin => 'ENTER  (2 EFFECTS)';

  @override
  String get dngEnterShrine => 'ENTER SHRINE';

  @override
  String dngActiveEffects(int n) {
    return 'Active effects: $n';
  }

  @override
  String get dngSkip => 'SKIP';

  @override
  String dngGuaranteeBless(int c) {
    return '✧  GUARANTEE BLESSING  ($c ◆)';
  }

  @override
  String dngTrapDamage(int dmg, int pct) {
    return 'You will take $dmg damage ($pct% of max HP).';
  }

  @override
  String get dngLockedChest => 'Locked Chest';

  @override
  String get dngChestContains => 'Contains a rare or epic item.';

  @override
  String dngCostShards(Object cost) {
    return '$cost shards';
  }

  @override
  String dngHave(int n) {
    return '(have $n)';
  }

  @override
  String dngCostZcoins(int cost) {
    return '$cost ZCoins';
  }

  @override
  String get dngMerchantQuote =>
      '\"Bones for trinkets, traveller. More bones, finer wares.\"';

  @override
  String dngBones(int n) {
    return '🦴  $n Bones';
  }

  @override
  String dngBoneCost(int c) {
    return '$c 🦴';
  }

  @override
  String get dngClaimRelic => '☠ BOSS SLAIN — CLAIM A RELIC';

  @override
  String get dngSkipDescend => 'SKIP — DESCEND';

  @override
  String get dngReturn => 'RETURN';

  @override
  String dngDescendTo(int n) {
    return 'DESCEND TO FLOOR $n';
  }

  @override
  String get dngFallen => '☠ Fallen';

  @override
  String get dngGotAway => '💰 It got away!';

  @override
  String get dngVictory => '✓ Victory';

  @override
  String dngAmbushHit(int n) {
    return 'Ambush hit dealt $n before the fight.';
  }

  @override
  String dngItemToBag(String name, String label) {
    return '✦ $name ($label) → Bag';
  }

  @override
  String get dngRested => '⊕ Rested';

  @override
  String get dngTreasureCollected => '✦ Treasure collected';

  @override
  String get dngBlessingReceived => '✧ Blessing received';

  @override
  String get dngSlainTrap => '☠ Slain by the trap';

  @override
  String get dngTrapSurvived => '✸ Trap survived';

  @override
  String get dngChestOpened => '◆ Chest opened';

  @override
  String get dngLootAdded =>
      'Your loot has already been added to your account.';

  @override
  String dngLordFallen(int z, int g) {
    return 'The Dungeon Lord has fallen!\n+5 mythril  •  +$z Z-Coins  •  +$g gold  •  bonus item';
  }

  @override
  String dngTierN(int t) {
    return 'TIER $t';
  }

  @override
  String get dngFloor => 'FLOOR';

  @override
  String get dngRooms => 'ROOMS';

  @override
  String get dngBosses => 'BOSSES';

  @override
  String get dngGold => 'GOLD';

  @override
  String get dngShards => 'SHARDS';

  @override
  String dngTierCleared(int t) {
    return '✓ Tier $t cleared — AUTO unlocked!';
  }

  @override
  String get dngNewRecord => '★ New record!';

  @override
  String get dngAllLootAdded => 'All loot has been added to your account.';

  @override
  String get dngYouFallen => 'YOU HAVE FALLEN';

  @override
  String get dngCleared => 'DUNGEON CLEARED!';

  @override
  String get dngRunEnded => 'RUN ENDED';

  @override
  String get dngAutoLocked => '🔒 AUTO';

  @override
  String get dngStop => '◉ STOP';

  @override
  String get dngAuto => '✦ AUTO';

  @override
  String get dngRunAgain => 'RUN AGAIN';

  @override
  String get dngReturnHall => 'RETURN TO HALL';

  @override
  String get auraEquipped => 'EQUIPPED';

  @override
  String get auraOn => 'ON';

  @override
  String auraCost(int n) {
    return 'Cost: $n zcoins';
  }

  @override
  String auraUnlockTitle(String name) {
    return 'Unlock $name?';
  }

  @override
  String get auraAllAuras => 'ALL AURAS';

  @override
  String get auraAllSkins => 'ALL SKINS';

  @override
  String get auraAllPets => 'ALL PETS';

  @override
  String get auraRemoveAura => 'Remove aura';

  @override
  String get auraRemoveSkin => 'Remove skin';

  @override
  String get auraDismissPet => 'Dismiss pet';

  @override
  String get auraBattleCompanion => 'BATTLE COMPANION';

  @override
  String get auraWaystones => 'WAYSTONES';

  @override
  String get auraAttackEffects => 'ATTACK EFFECTS';

  @override
  String get auraCharSlots => 'CHARACTER SLOTS';

  @override
  String get auraCompanionNote =>
      'One companion can be active at a time. Each grants a small passive bonus.';

  @override
  String get auraBeforeAfter => 'Before / After';

  @override
  String get auraAllSlots => 'All 12 slots unlocked.';

  @override
  String auraAdoptTitle(String name) {
    return 'Adopt $name?';
  }

  @override
  String auraPetBonus(String label) {
    return '✦ $label';
  }

  @override
  String get auraMaxEvolution => '★★ MAX EVOLUTION';

  @override
  String auraOwned(Object count) {
    return 'Owned: $count';
  }

  @override
  String auraWaystoneDesc(Object h, String m) {
    return '${h}h  ·  $m× idle income';
  }

  @override
  String auraHitEvery(String text) {
    return '\"$text\" on every hit';
  }

  @override
  String auraSlotN(Object n) {
    return 'Slot $n';
  }

  @override
  String get auraAddSlot => 'Add one more character save slot.';

  @override
  String get auraUnlock => 'UNLOCK';

  @override
  String get auraAdopt => 'ADOPT';

  @override
  String get auraBuy => 'BUY';

  @override
  String get auraEvolve => 'EVOLVE';

  @override
  String get auraEquip => 'EQUIP';

  @override
  String get auraActive => 'ACTIVE';

  @override
  String get auraSendOut => 'SEND OUT';

  @override
  String get auraStackAuras =>
      'Bonuses from every aura you OWN stack automatically — you keep them all. Equip one just to choose which glow you show.';

  @override
  String get auraStackSkins =>
      'Bonuses from every skin you OWN stack automatically — you keep them all. Equip one just to choose which look you wear.';

  @override
  String get armTabUniques => 'UNIQUES';

  @override
  String get armTabMythic => 'MYTHIC';

  @override
  String get armTabSets => 'SET ITEMS';

  @override
  String get armTabArtifacts => 'ARTIFACTS';

  @override
  String get armNoLegendaries => 'No legendaries for this class.';

  @override
  String armClassUniques(int count) {
    return '$count Class Uniques';
  }

  @override
  String get armOwned => 'OWNED';

  @override
  String armSlotReqLevel(String slot, int lvl) {
    return '$slot  •  Req. Level $lvl';
  }

  @override
  String get armStats => 'STATS';

  @override
  String get armAbilityEnh => 'ABILITY ENHANCEMENT';

  @override
  String armAbilityDamage(String x) {
    return '• Ability damage ×$x';
  }

  @override
  String armAbilityDuration(Object n) {
    return '• +$n rounds duration';
  }

  @override
  String armAbilityCooldown(String v) {
    return '• $v rounds cooldown';
  }

  @override
  String armOnCast(String desc) {
    return '• On cast: $desc';
  }

  @override
  String get armHowToFind => 'HOW TO FIND';

  @override
  String get armDropCampaign => 'Campaign bosses';

  @override
  String get armDropTower => 'Tower Ascension bosses';

  @override
  String get armDropBossRush => 'Boss Rush runs';

  @override
  String get armDropGauntlet => 'Gauntlet clear';

  @override
  String get armRate2 => '2% per boss kill';

  @override
  String get armRate03 => '0.3% per boss kill';

  @override
  String get armRateRare => 'Rare bonus drop';

  @override
  String get armDropsClassSpecific =>
      'Drops are class-specific — only items for your class can drop.';

  @override
  String get armNoMythic => 'No Mythic items yet';

  @override
  String get armMythicHint =>
      'Defeat campaign bosses for a 0.5% chance per kill.';

  @override
  String get armMythicItems => 'Mythic Items';

  @override
  String armSlotLv(String slot, int lvl) {
    return '$slot  •  Lv$lvl';
  }

  @override
  String armKeyword(String name) {
    return '$name keyword';
  }

  @override
  String get armSetItemsTitle => 'Set Items';

  @override
  String armFraction(int a, int b) {
    return '$a / $b';
  }

  @override
  String get armEquippedLower => 'equipped';

  @override
  String get armSetBonuses => 'SET BONUSES';

  @override
  String armPc(Object n) {
    return '${n}pc';
  }

  @override
  String get armUniqueBlurb =>
      'Unique items are class-bound and dramatically enhance your abilities. Each amplifies a specific class ability. Drop rate: 2% per boss kill.';

  @override
  String get armMythicBlurb =>
      'The rarest procedurally-generated tier. Mythic items have 3 stats with the highest possible values and a powerful keyword effect. Drop rate: 0.5% per boss kill.';

  @override
  String get armSetBlurb =>
      'Collect multiple pieces of the same set to unlock powerful bonuses. Sets now require 6 pieces for the full bonus. Drop rate: 0.3% per boss kill.';

  @override
  String armArtifactBlurb(int count) {
    return '$count three-piece artifact sets. Equip 2 matching green pieces on the artifact grid for a partial bonus, all 3 for the full bonus. Set pieces drop from Dungeons, Boss Rush, and Campaign bosses.';
  }

  @override
  String get armSetPieces => 'SET PIECES';

  @override
  String get armArtifactSets => 'Artifact Sets';

  @override
  String armCollected(int a, int b) {
    return 'COLLECTED  $a / $b distinct pieces owned';
  }

  @override
  String endlessStage(int n) {
    return 'Stage $n';
  }

  @override
  String endlessNextReward(int n) {
    return 'Next reward: Floor $n';
  }

  @override
  String get endlessChallengeBoss => 'CHALLENGE A BOSS';

  @override
  String get endlessPremiumAutoClear =>
      '🔒  Reach campaign Stage 5 to auto-clear bosses';

  @override
  String get endlessRewards => 'REWARDS: ';

  @override
  String get endlessDrop => 'DROP: ';

  @override
  String get endlessGold => 'GOLD';

  @override
  String get endlessXp => 'XP';

  @override
  String get endlessRespawns => 'RESPAWNS';

  @override
  String endlessTowerShards(String n) {
    return '+$n TOWER SHARDS';
  }

  @override
  String endlessMilestone(Object n) {
    return '★ MILESTONE: $n KILLS ★';
  }

  @override
  String endlessMilestoneReward(String gold, Object s) {
    return '+$gold GOLD  +$s ◆';
  }

  @override
  String get endlessEnemyStirs => 'The enemy stirs again...';

  @override
  String get endlessDefeatBody =>
      'Your hero was overwhelmed.\nUpgrade your stats and try again.';

  @override
  String get pvpNoStamina => 'No stamina! Recharges 1 every 45 minutes.';

  @override
  String get pvpTitle => 'PVP ARENA';

  @override
  String get pvpSimLab => 'Sim Lab';

  @override
  String get pvpRefresh => 'Refresh leaderboard';

  @override
  String get pvpLeaderboard => 'LEADERBOARD';

  @override
  String pvpToday(String label) {
    return 'TODAY: $label';
  }

  @override
  String pvpWinsToday(Object wins, Object dmg) {
    return '$wins wins today  •  $dmg total dmg';
  }

  @override
  String get pvpClaimed => '✓ CLAIMED';

  @override
  String get pvpNoChallengers => 'NO CHALLENGERS YET';

  @override
  String get pvpNoChallengersSub =>
      'Fight a match to join the leaderboard\nand see how you stack up.';

  @override
  String pvpHpAc(Object hp, Object ac) {
    return 'HP:$hp  AC:$ac';
  }

  @override
  String get pvpStamina => 'STAMINA  ';

  @override
  String get pvpStaminaTip => 'Stamina recovers 1 heart every 45 minutes.';

  @override
  String get pvpRating => 'RATING';

  @override
  String get pvpWins => 'WINS';

  @override
  String get pvpLosses => 'LOSSES';

  @override
  String get pvpWL => 'W/L';

  @override
  String pvpLeague(String name) {
    return '$name LEAGUE';
  }

  @override
  String get pvpNearRank => 'NEAR YOUR RANK';

  @override
  String get pvpPlayersAbove => '— players just above you';

  @override
  String pvpClassLv(String cls, Object lvl) {
    return '$cls  Lv$lvl';
  }

  @override
  String get pvpChallenge => 'CHALLENGE';

  @override
  String get pvpBattleLog => 'BATTLE LOG';

  @override
  String get pvpBattleLogTip => 'Battle log';

  @override
  String get pvpNoCombat => 'No combat yet.';

  @override
  String get pvpClose => 'CLOSE';

  @override
  String pvpVs(String hero, String opp) {
    return 'PVP  —  $hero vs $opp';
  }

  @override
  String get pvpReturnArena => 'RETURN TO ARENA';

  @override
  String get pvpFighting => 'Fighting...';

  @override
  String invBagCount(Object n, Object cap) {
    return '($n/$cap)';
  }

  @override
  String invBuyTab(Object cost) {
    return '+ TAB  $cost';
  }

  @override
  String get invAutoEquip => 'AUTO EQUIP';

  @override
  String invTabN(Object n, Object count) {
    return 'TAB $n  ($count)';
  }

  @override
  String get invEquipment => 'EQUIPMENT';

  @override
  String invBag(Object n, Object cap) {
    return 'BAG  ($n/$cap)';
  }

  @override
  String get invUnequip => 'Unequip';

  @override
  String get invNoItems => 'No items in this tab.';

  @override
  String invReqClass(String cls) {
    return 'Requires $cls';
  }

  @override
  String invReqLevel(Object lvl) {
    return 'Requires Level $lvl';
  }

  @override
  String invReqTier(Object t) {
    return 'Requires Tier $t';
  }

  @override
  String get invCannotEquip => 'Cannot Equip';

  @override
  String get invEquip => 'Equip';

  @override
  String get invUnlock => 'Unlock 🔓';

  @override
  String get invLock => 'Lock 🔒';

  @override
  String get invDiscard => 'Discard';

  @override
  String get invAny => 'Any';

  @override
  String invUniqueOnly(String cls) {
    return '★ Unique — $cls only';
  }

  @override
  String get invWrongClass => '(wrong class)';

  @override
  String get invColStat => 'STAT';

  @override
  String get invColThis => 'THIS';

  @override
  String get invColEqpd => 'EQPD';

  @override
  String get invColDiff => 'DIFF';

  @override
  String get invEmptySocket => 'Empty Socket';

  @override
  String get invCraftGems => 'Craft gems in Forge → Gems tab';

  @override
  String get invRemove => 'REMOVE';

  @override
  String get invSocket => 'SOCKET';

  @override
  String invChooseGem(String name) {
    return 'Choose a gem to socket into $name';
  }

  @override
  String invOnThis(String slot, String bonus) {
    return 'On this $slot: $bonus';
  }

  @override
  String get invRemoveGem => 'Remove Gem?';

  @override
  String get invDestroy => 'DESTROY';

  @override
  String get invSort => 'Sort:';

  @override
  String get invFilter => 'Filter:';

  @override
  String invGemsAvailable(Object count) {
    return '$count gem(s) available to socket';
  }

  @override
  String invRemoveBody(String name) {
    return '$name will be destroyed. Gems cannot be recovered once removed.';
  }

  @override
  String invReplaceBody(String old, String gnew) {
    return '$old will be destroyed and replaced with $gnew.';
  }

  @override
  String get npcRoster => 'ROSTER';

  @override
  String get npcSynergies => 'SYNERGIES';

  @override
  String get npcTitle => 'MERCENARIES';

  @override
  String get npcTotalBonuses => 'TOTAL ACTIVE BONUSES';

  @override
  String get npcBattleParty => 'BATTLE PARTY';

  @override
  String npcFielded(Object count, Object max) {
    return '$count / $max fielded';
  }

  @override
  String get npcUnknown => 'Unknown Mercenary';

  @override
  String npcBattleAbility(String name) {
    return 'BATTLE ABILITY: $name';
  }

  @override
  String npcUnlock(String label) {
    return 'Unlock: $label';
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
    return 'CHOSEN: $name';
  }

  @override
  String get npcMilestoneComplete => 'MILESTONE COMPLETE — RECRUITING...';

  @override
  String get npcMax => '★ MAX';

  @override
  String get npcStarRank => 'STAR RANK';

  @override
  String npcStars(Object a, Object b) {
    return '$a / $b';
  }

  @override
  String get npcFullyAscended =>
      '★ FULLY ASCENDED — each star adds +1 effective level.';

  @override
  String npcAscendStar(Object n) {
    return 'ASCEND ★$n';
  }

  @override
  String npcYouHave(Object n) {
    return 'You have: $n Mythril';
  }

  @override
  String get npcStarInfo =>
      'Each star = +1 effective level of this merc\'s bonus.';

  @override
  String get npcPassiveOnly => 'Passive bonuses only — always active.';

  @override
  String npcCostShards(Object n) {
    return 'Cost: ◆ $n Shards';
  }

  @override
  String get npcTutorial =>
      'Mercenaries are companions who join permanently when you hit certain milestones. 🤝 Each one provides passive combat bonuses in every battle and can synergise with others for extra power.';

  @override
  String npcRecruited(Object a, Object b) {
    return '$a / $b  recruited';
  }

  @override
  String get npcNoMercs =>
      'No mercenaries recruited yet. Fulfill milestones to unlock them.';

  @override
  String npcChipDamage(Object n) {
    return '+$n% Damage';
  }

  @override
  String npcChipAc(Object n) {
    return '+$n% AC';
  }

  @override
  String npcChipShards(Object n) {
    return '+$n% Shards';
  }

  @override
  String npcChipHp(Object n) {
    return '+$n% HP';
  }

  @override
  String get shopTabBundles => 'BUNDLES';

  @override
  String get shopTabVip => 'VIP';

  @override
  String get shopTabStarter => 'STARTER';

  @override
  String get shopTabResources => 'RESOURCES';

  @override
  String get shopTabCosmetics => 'COSMETICS';

  @override
  String get shopSecBundles => 'ZCOIN BUNDLES';

  @override
  String get shopSecBundlesSub => 'Premium currency for the Shop';

  @override
  String get shopSecVip => 'VIP SUBSCRIPTIONS';

  @override
  String get shopSecVipSub => 'Recurring perks and benefits';

  @override
  String get shopSecStarter => 'STARTER PACKS';

  @override
  String get shopSecStarterSub => 'One-time purchase bundles';

  @override
  String get shopSecResources => 'RESOURCES';

  @override
  String get shopSecResourcesSub => 'Spend ZCoins on gold & materials';

  @override
  String get shopSecAuras => 'AURAS';

  @override
  String get shopSecAurasSub =>
      'Equip a glow — owned aura bonuses always stack';

  @override
  String get shopSecBoosts => 'BOOSTS';

  @override
  String get shopSecBoostsSub => 'Permanent stat boosts';

  @override
  String get shopSecTitles => 'TITLES';

  @override
  String get shopSecTitlesSub => 'A rank displayed beneath your name';

  @override
  String get shopSecColours => 'NAME COLOURS';

  @override
  String get shopSecColoursSub => 'Colour + glow for your hero name';

  @override
  String get shopSecFrames => 'FRAMES';

  @override
  String get shopSecFramesSub => 'A frame around your hero portrait';

  @override
  String get shopSecSlots => 'CHARACTER SLOTS';

  @override
  String get shopSecSlotsSub => 'Extra character save slots';

  @override
  String get shopPremiumArmor => 'PREMIUM CLASS ARMOR';

  @override
  String shopEndgameSkin(String cls) {
    return '$cls · Endgame skin';
  }

  @override
  String get shopIncludedBonuses => 'INCLUDED BONUSES';

  @override
  String get shopEverySkin => 'every shop skin bonus, combined';

  @override
  String get shopEquippedCheck => '✓ EQUIPPED';

  @override
  String get shopUnequip => 'UNEQUIP';

  @override
  String shopUnlockPrice(String price) {
    return 'UNLOCK  ·  $price';
  }

  @override
  String get shopStoreUnavailable => 'Store unavailable — try again later.';

  @override
  String get shopVipSub => 'VIP SUBSCRIPTION';

  @override
  String get shopSubscribed => '✓ SUBSCRIBED';

  @override
  String shopSubscribe(String price) {
    return 'SUBSCRIBE  $price';
  }

  @override
  String get shopEverythingPlus => 'Everything in Vanguard\'s Pact, plus:';

  @override
  String get shopIncludedPerks => 'INCLUDED PERKS';

  @override
  String get shopGlow => '✦ GLOW';

  @override
  String get shopExclusive => 'EXCLUSIVE';

  @override
  String get shopNoAd => 'No ad available right now — try again later.';

  @override
  String get shopWatchAd => 'Watch an Ad';

  @override
  String get shopComeBackTomorrow => 'Come back tomorrow for more free ZCoins!';

  @override
  String get shopWait => 'WAIT...';

  @override
  String get shopWatch => 'WATCH';

  @override
  String get shopRewardEarned => 'REWARD EARNED';

  @override
  String shopPlusZcoins(Object amount) {
    return '+$amount ZCoins';
  }

  @override
  String get shopCollect => 'COLLECT';

  @override
  String get shopPurchasesRestored =>
      'Purchases restored. Any active subscriptions or packs have been re-applied.';

  @override
  String get shopRestorePurchases => 'Restore Purchases';

  @override
  String artSalvageTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Salvage $count artifacts?',
      one: 'Salvage $count artifact?',
    );
    return '$_temp0';
  }

  @override
  String get artSalvage => 'SALVAGE';

  @override
  String artSalvaged(int n, Object gained) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Salvaged $n artifacts for ◆ $gained mythril.',
      one: 'Salvaged $n artifact for ◆ $gained mythril.',
    );
    return '$_temp0';
  }

  @override
  String get artTable => 'ARTIFACT TABLE';

  @override
  String artSlots(Object n, Object max) {
    return '$n/$max slots';
  }

  @override
  String artAutoEquipped(Object n) {
    return 'Auto-equipped $n best artifacts.';
  }

  @override
  String get artNoneToEquip => 'No artifacts to equip.';

  @override
  String get artAutoEquip => '⚡ AUTO-EQUIP';

  @override
  String get artSalvageBtn => '♻ SALVAGE';

  @override
  String get artTitle => 'ARTIFACTS';

  @override
  String get artPlaceHint => 'Place artifacts on the table to gain bonuses.';

  @override
  String get artTableBonuses => 'TABLE BONUSES';

  @override
  String get artCollection => 'COLLECTION';

  @override
  String artCount(Object n) {
    return '($n)';
  }

  @override
  String artTapToPlace(String name) {
    return 'Tap a grid cell to place \"$name\"';
  }

  @override
  String get artTapCancel => 'tap again to cancel';

  @override
  String get artSet => 'SET';

  @override
  String artUpgradeCost(Object cost) {
    return '$cost Mythril';
  }

  @override
  String artNoSets(Object n) {
    return 'No Set pieces equipped yet — $n sets to discover.';
  }

  @override
  String artCountOf3(Object count) {
    return '$count / 3';
  }

  @override
  String get artHowToGet => 'HOW TO GET ARTIFACTS';

  @override
  String get artRowCampaign => 'Campaign Bosses';

  @override
  String get artRowCampaignDesc =>
      'about a 25% chance to drop on every boss-stage kill.';

  @override
  String get artRowDungeon => 'Dungeon runs';

  @override
  String get artRowDungeonDesc =>
      'each boss you defeat drops one — up to 2 per run. Best steady farm.';

  @override
  String get artRowBossRush => 'Boss Rush';

  @override
  String get artRowBossRushDesc =>
      'clear a run with an A or S rank to earn an artifact.';

  @override
  String artSalvageBody(int count, Object mythril) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Permanently destroy all $count unequipped artifacts for ◆ $mythril mythril? Equipped artifacts are kept.',
      one:
          'Permanently destroy $count unequipped artifact for ◆ $mythril mythril? Equipped artifacts are kept.',
    );
    return '$_temp0';
  }

  @override
  String get artSetBlurb =>
      'Collect matching green Set pieces. 2 equipped = partial bonus, all 3 = full bonus.';

  @override
  String get art2Set => '2-Set';

  @override
  String get art3Set => '3-Set';

  @override
  String get ptEssence => 'essence';

  @override
  String ptTheClass(String cls) {
    return 'THE $cls';
  }

  @override
  String ptRespecBranch(String branch) {
    return 'Respec $branch?';
  }

  @override
  String ptRefund(Object refund) {
    return 'Refund $refund essence (75%)';
  }

  @override
  String get ptRespec => 'Respec';

  @override
  String get ptCrossBranch => 'CROSS-BRANCH';

  @override
  String get ptFullRespec => 'Full Respec?';

  @override
  String get ptRespec50 => 'Respec (50 ZC)';

  @override
  String get ptFullRespecBtn => 'FULL RESPEC (50 ZC)';

  @override
  String get ptTitle => 'PASSIVE TREE';

  @override
  String get ptNow => 'NOW';

  @override
  String ptUpgradeCost(Object cost) {
    return 'UPGRADE  ($cost ✦)';
  }

  @override
  String get ptLocked => 'LOCKED — spend 25 ranks in more branches';

  @override
  String get ptLockedMax => 'LOCKED — max all branch nodes first';

  @override
  String ptMaxRankTotal(String val) {
    return 'MAX RANK — $val total';
  }

  @override
  String ptFullRespecBody(Object refund) {
    return 'Reset ALL passive nodes.\nRefund $refund essence (60%).\nCost: 50 zcoins.';
  }

  @override
  String ptNodesUnlocked(Object count) {
    return '$count nodes unlocked';
  }

  @override
  String get ptTutorial =>
      'You\'ve earned Shards ◆ — spend them here on permanent passive nodes that never reset. Your class branch is at the top. Each node ranks up to 5 for bigger bonuses.';

  @override
  String ptBranchesAt25(Object count) {
    return '$count / 5 branches at 25';
  }

  @override
  String get homeExp => 'EXP';

  @override
  String get homeResources => 'Resources';

  @override
  String get homeGold => 'GOLD';

  @override
  String get homeShards => 'SHARDS';

  @override
  String get homeZcoins => 'ZCOINS';

  @override
  String get homeMythril => 'MYTHRIL';

  @override
  String get homeIdleMin => 'IDLE/min';

  @override
  String get homeGoldTip =>
      'Gold\nEarned from battles and idle income.\nSpend in Upgrades and the Shop.';

  @override
  String get homeShardsTip =>
      'Shards\nEarned from enemy kills, Dungeons, Expeditions, and Gauntlet.\nSpend on ability upgrades, item upgrades, and Passive Tree nodes.';

  @override
  String get homeZcoinsTip =>
      'ZCoins\nEarned from achievements and daily chests.\nSpend in the Aura Shop for skins, pets, and auras.';

  @override
  String get homeMythrilTip =>
      'Mythril\nEarned from Dungeons, Boss Rush, and prestige milestones.\nSpend on Artifact upgrades, dungeon affix rerolls, and shrine blessings.';

  @override
  String get homeIdleTip =>
      'Idle Gold / min\nGold earned automatically every minute while offline.\nIncreases with hero level, passive upgrades, and pets.';

  @override
  String get homeCurrentCampaign => 'Current Campaign';

  @override
  String homeStage(Object n) {
    return 'STAGE $n';
  }

  @override
  String homeNextGoal(Object reward) {
    return 'NEXT: UNLOCK $reward';
  }

  @override
  String homeNextGoalProgress(Object remaining, Object stage) {
    return '$remaining stages to go — clear Stage $stage';
  }

  @override
  String get demoModeLocked =>
      'Unlocked in the full game. The demo includes the complete campaign — get the full game for Dungeons, PvP and the endgame difficulty tiers.';

  @override
  String get demoFullGameCta => 'GET THE FULL GAME';

  @override
  String get homeSecCombat => 'COMBAT';

  @override
  String get homeSecSocial => 'SOCIAL';

  @override
  String get homeNavChallengeGauntlet => 'CHALLENGE GAUNTLET';

  @override
  String get homeNavBountyBoard => 'BOUNTY BOARD';

  @override
  String get homeNavSeasonPass => 'SEASON PASS';

  @override
  String get homeNavWorldEvent => 'WORLD EVENT';

  @override
  String get homeNavLeaderboard => 'LEADERBOARD';

  @override
  String get homeNavChallengeModifiers => 'CHALLENGE MODIFIERS';

  @override
  String get homeQuickAccess => 'QUICK ACCESS';

  @override
  String get homeGettingStarted => 'GETTING STARTED';

  @override
  String get homeStep1 => 'Win your first Campaign battle';

  @override
  String get homeStep2 => 'Level up your hero — visit Character Sheet';

  @override
  String get homeStep3 => 'Open HERO and buy your first Ability Score upgrade';

  @override
  String get homeStep4 =>
      'Reach Stage 5 — Abilities and Daily Challenges unlock!';

  @override
  String get homeHeroSubtitle => 'UPGRADES  •  ARMORY  •  ALLIES  •  CODEX';

  @override
  String get homeTomorrow => 'Tomorrow: ';

  @override
  String get dailyWeekly => 'WEEKLY';

  @override
  String get dailyClaimAll => 'CLAIM ALL';

  @override
  String get dailyHowItWorks => 'How It Works';

  @override
  String get dailyThisWeek => 'THIS WEEK\'S CHALLENGES';

  @override
  String dailyCompleted(Object claimed, Object total) {
    return '$claimed / $total completed';
  }

  @override
  String get dailyWeeklyLoading => 'Weekly challenges loading...';

  @override
  String get dailyAboutWeekly => 'About Weekly Challenges';

  @override
  String get dailyReady => 'READY';

  @override
  String get dailyTodayProgress => 'TODAY\'S PROGRESS';

  @override
  String get dailyChest => 'DAILY CHEST';

  @override
  String get dailyClaimedTomorrow => 'Claimed! Come back tomorrow.';

  @override
  String get dailyHintKill => 'Kill enemies';

  @override
  String get dailyHintKillD => 'Fight in Campaign or Endless mode';

  @override
  String get dailyHintWin => 'Win battles';

  @override
  String get dailyHintWinD => 'Defeating an enemy counts as a win';

  @override
  String get dailyHintBoss => 'Defeat boss';

  @override
  String get dailyHintBossD => 'Stage 5, 10, 15, 20, 25 or Endless every 5th';

  @override
  String get dailyHintAbility => 'Use abilities';

  @override
  String get dailyHintAbilityD =>
      'Active abilities fire automatically in battle';

  @override
  String get dailyHintEquip => 'Equip item';

  @override
  String get dailyHintEquipD => 'Tap a bag item → Equip in Inventory';

  @override
  String get dailyHintGold => 'Reach gold';

  @override
  String get dailyHintGoldD => 'Just have that much gold in your stash';

  @override
  String get dailyHintDamage => 'Deal damage';

  @override
  String get dailyHintDamageD => 'Cumulative damage dealt in any mode';

  @override
  String get dailyHintIdle => 'Collect idle';

  @override
  String get dailyHintIdleD => 'Tap the idle reward on the home screen';

  @override
  String get dailyHintResets => 'Resets';

  @override
  String get dailyHintResetsD => 'Every Monday — 5 new challenges each week';

  @override
  String get dailyHintRewards => 'Rewards';

  @override
  String get dailyHintRewardsD => 'Larger than daily: essence, mythril, ZCoins';

  @override
  String get dailyHintSeasonXp => 'Season XP';

  @override
  String get dailyHintSeasonXpD => '+50 season XP per claimed weekly challenge';

  @override
  String get dailyHintProgress => 'Progress';

  @override
  String get dailyHintProgressD =>
      'Counts from Monday midnight, not from claim';

  @override
  String get dailyTutorial =>
      'Complete daily challenges to earn gold, shards, essence, and ZCoins. All 7 challenges reset each day. Complete them all for a bonus chest!';

  @override
  String petOwned(Object a, Object b) {
    return '$a / $b  owned';
  }

  @override
  String get petTitle => 'COMPANIONS';

  @override
  String get petActiveBonuses => 'ACTIVE BONUSES (all owned pets)';

  @override
  String get petNoCompanion => 'No companion equipped';

  @override
  String get petEquipHint => 'Equip a pet to have it appear in battle.';

  @override
  String get petPremium => '★ PREMIUM';

  @override
  String get petInBattle => 'IN BATTLE';

  @override
  String petRecruitTitle(String name) {
    return 'Recruit $name?';
  }

  @override
  String get petRecruit => 'RECRUIT';

  @override
  String petEvolveTitle(String name) {
    return 'Evolve $name?';
  }

  @override
  String petEvolveN(Object n) {
    return 'EVOLVE  Evo $n';
  }

  @override
  String get petTutorial =>
      'Pet companions join you in battle and stack their bonuses passively — even ones not equipped. Equip one to have it appear at your side during fights. Evolve owned pets twice to double their bonus value.';

  @override
  String petRecruitBody(String desc, String bonus, Object cost) {
    return '$desc\n\nBonus: $bonus\n\nCost: $cost ZCoins';
  }

  @override
  String petEvolveBody(Object level, String bonus, Object cost) {
    return 'Upgrade to Evolution $level.\n\nNew bonus: +$bonus\nCost: $cost ZCoins';
  }

  @override
  String get questTitle => 'QUESTLINES';

  @override
  String get questAdventure => 'ADVENTURE QUESTLINE';

  @override
  String get questAdventureSub =>
      'Learn every game system on the road to stage 100.';

  @override
  String questUnlocksLv30(Object lvl) {
    return 'Unlocks at Level 30  (current: $lvl)';
  }

  @override
  String get questUltUnlocked => 'ULTIMATE ABILITY UNLOCKED';

  @override
  String questUltAvailable(String cls) {
    return '$cls ultimate is now available in battle.';
  }

  @override
  String get questProgressLabel => 'Progress';

  @override
  String questCompleteFirst(Object n) {
    return 'Complete quest $n first to unlock.';
  }

  @override
  String get questClaimReward => 'CLAIM REWARD';

  @override
  String get questRewardLabel => 'Reward: ';

  @override
  String questClassQuestline(String cls) {
    return '$cls QUESTLINE';
  }

  @override
  String get questComplete5 =>
      'Complete 5 quests to unlock the Ultimate Ability.';

  @override
  String get subTitle => 'SPECIALIZATION';

  @override
  String get subLevel50 => 'LEVEL 50 SPECIALIZATION';

  @override
  String subChooseBody(String cls, Object cost) {
    return 'Choose a specialization for your $cls. It grants a powerful capstone bonus plus stat bonuses, applied immediately. You can change it later for $cost ZCoins.';
  }

  @override
  String subClassSpecs(String cls, Object n) {
    return '$cls SPECIALIZATIONS  ($n)';
  }

  @override
  String subUnlocksAt(Object lvl) {
    return 'Specialization unlocks at Level $lvl.';
  }

  @override
  String subChooseTitle(String name) {
    return 'Choose $name?';
  }

  @override
  String get subStatBonuses => 'STAT BONUSES';

  @override
  String get subCapstone => 'CAPSTONE BONUS';

  @override
  String get subSpecialEffect => 'SPECIAL EFFECT';

  @override
  String subChangeLater(Object cost) {
    return 'You can change this later for $cost ZCoins.';
  }

  @override
  String get subCouldNotSet => 'Could not set specialization — try again.';

  @override
  String subChangeSpec(Object cost) {
    return 'CHANGE SPECIALIZATION  —  $cost ZCoins';
  }

  @override
  String get subChangeTitle => 'Change specialization?';

  @override
  String subChangeBody(Object cost, Object zcoins) {
    return 'Spend $cost ZCoins to clear your current specialization and choose a new one?\n\nYour ZCoins: $zcoins';
  }

  @override
  String get subNotEnough => 'Not enough ZCoins to respec.';

  @override
  String get subActiveSubclass => 'ACTIVE SUBCLASS';

  @override
  String get subChosen => 'CHOSEN';

  @override
  String get subActive => 'ACTIVE';

  @override
  String get subChoosePath => 'CHOOSE THIS PATH';

  @override
  String get expTitle => 'EXPEDITIONS';

  @override
  String get expCollectAll => 'COLLECT ALL';

  @override
  String get expDispatchAll => 'DISPATCH ALL';

  @override
  String get expNoMercs => 'No Mercenaries Yet';

  @override
  String get expNoMercsSub =>
      'Recruit mercenaries from the MERCS tab in Hero Hub to send them on expeditions.';

  @override
  String get expTodayLocations => 'TODAY\'S LOCATIONS';

  @override
  String expRefreshIn(String time) {
    return '🔄 $time';
  }

  @override
  String get expYourParty => 'YOUR PARTY';

  @override
  String get expDispatch => 'DISPATCH';

  @override
  String get expDone => 'DONE';

  @override
  String get expCollectRewards => 'COLLECT REWARDS';

  @override
  String get expInProgress => 'IN PROGRESS...';

  @override
  String expReturned(String name) {
    return '$name returned!';
  }

  @override
  String get expDiscovery => '✦  DISCOVERY';

  @override
  String get expGreat => 'GREAT';

  @override
  String expDispatchMerc(String name) {
    return 'DISPATCH $name';
  }

  @override
  String get expChooseLocation => 'CHOOSE LOCATION';

  @override
  String get expDuration => 'DURATION';

  @override
  String get expEstRewards => 'ESTIMATED REWARDS';

  @override
  String get expSend => 'SEND ON EXPEDITION';

  @override
  String get acctSignInFailed => 'Sign-in cancelled or failed.';

  @override
  String get acctSignOutTitle => 'Sign out?';

  @override
  String get acctSignOut => 'Sign out';

  @override
  String get acctSignOutBody =>
      'Your local save is kept. Cloud sync will pause until you sign in again.';

  @override
  String get acctDeleteTitle => 'Delete account & data?';

  @override
  String get acctDeleteAll => 'DELETE EVERYTHING';

  @override
  String get acctDeleteBody =>
      'This permanently deletes your account and ALL data — every character, your cloud save, PvP standing, and leaderboard entries. This cannot be undone.';

  @override
  String get acctDeleted => 'Account deleted';

  @override
  String get acctDeletedBody =>
      'Your account and all data have been removed. The app will now close.';

  @override
  String get acctClose => 'Close';

  @override
  String get acctPlayer => 'Player';

  @override
  String get acctSyncNow => 'SYNC NOW';

  @override
  String get acctSignOutBtn => 'SIGN OUT';

  @override
  String get acctSignInGoogle => 'SIGN IN WITH GOOGLE';

  @override
  String get acctDeleteAccount => 'DELETE ACCOUNT';

  @override
  String get acctDangerSub =>
      'Permanently delete your account and all associated data.';

  @override
  String get acctLinked => 'Google account linked';

  @override
  String get acctNotSynced => 'Not synced yet this session';

  @override
  String get acctNoAccount => 'No account linked';

  @override
  String get acctAboutCloud => 'ABOUT CLOUD SAVES';

  @override
  String get acctCloud1 =>
      'Your progress syncs automatically every 5 minutes when signed in.';

  @override
  String get acctCloud2 =>
      'Play on any Windows device with the same Google account.';

  @override
  String get acctCloud3 =>
      'Cloud saves are stored securely with your Google account.';

  @override
  String get invhTabGear => 'GEAR';

  @override
  String get invhTabGems => 'GEMS';

  @override
  String get invhTabRunes => 'RUNES';

  @override
  String get invhArcaneDust => 'Arcane Dust';

  @override
  String invhBag(Object n, Object max) {
    return 'Bag: $n/$max';
  }

  @override
  String get invhCraftGem => 'CRAFT GEM';

  @override
  String invhCraftTypeGem(String type, Object cost) {
    return 'CRAFT $type GEM  ($cost Arcane Dust)';
  }

  @override
  String get invhOwnedGems => 'OWNED GEMS';

  @override
  String invhDismantleBody(String bonus, Object dust) {
    return '$bonus\n\nSocket into a WEAPON for +DMG%, or ARMOUR for +RES% of this gem\'s element.\n\nDismantle returns $dust Arcane Dust.';
  }

  @override
  String invhDismantle(Object dust) {
    return 'DISMANTLE (+$dust Arcane Dust)';
  }

  @override
  String invhGemTooltip(String name, String bonus) {
    return '$name\n$bonus\nTap to dismantle';
  }

  @override
  String get invhTutGear =>
      'Your first piece of gear has dropped! Equip it here to boost your stats.';

  @override
  String get invhTutForge =>
      'Combine two items of the same slot to craft a higher-rarity piece, or reforge stats.';

  @override
  String get invhTutRunes =>
      'Craft Runes for temporary combat buffs. Collect dust by salvaging gear.';

  @override
  String get invhTutArtifacts =>
      'Place artifacts in the grid for permanent passive bonuses.';

  @override
  String get invhNoGear =>
      'No gear yet.\nDefeat enemies to find your first item!';

  @override
  String get ascTitle => 'ASCENSION';

  @override
  String get ascMetaBoard => 'META-BOARD';

  @override
  String ascApPoints(Object points) {
    return '$points AP';
  }

  @override
  String get ascLevelLabel => 'Ascension Level: ';

  @override
  String get ascPrestigeLabel => 'Prestige Level: ';

  @override
  String get ascBody =>
      'Ascension is the deepest reset — it converts your Rebirths into Ascension Points (AP). You earn 1 AP for every Rebirth you sacrifice, so the more you bank before ascending, the bigger the payout.\n\nSpend AP two ways — both permanent and both survive every future reset:\n• The Meta-Board below (XP, gold, damage, idle & prestige bonuses)\n• Ascend your class abilities on the Abilities screen (+10% power per tier, up to 60 AP per character)\n\nYou KEEP:  Ascension bonuses & AP spent, Artifacts, Mythril, Tower Shards, Elemental Mastery.\nYou LOSE:  all Rebirths, hero level, gold, gear, subclass, ability ranks, and campaign progress.';

  @override
  String ascRequires(Object prestige) {
    return 'Requires Prestige Level 5 to Ascend  (current: $prestige/5)';
  }

  @override
  String ascAscendAp(Object ap) {
    return 'ASCEND  (+$ap AP)';
  }

  @override
  String get ascConfirmTitle => 'Ascend?';

  @override
  String ascConfirmBody(Object rebirths, Object ap) {
    return 'Sacrifice $rebirths Rebirth(s) for $ap Ascension Point(s).\n\nKEEP: Ascension bonuses, Artifacts, Mythril, Tower Shards, Ability Ascensions.\nLOSE: all Rebirths, hero level, gold, gear, subclass, ability ranks, campaign progress.\n\nThis cannot be undone.';
  }

  @override
  String get weOmegaShop => 'OMEGA SHOP';

  @override
  String get weNowHunting => 'NOW HUNTING';

  @override
  String get weDamageLabel => 'Damage: ';

  @override
  String weEndsIn(Object d, Object h, Object m) {
    return 'Event ends in  ${d}d ${h}h ${m}m';
  }

  @override
  String get weHowToEarn => 'HOW TO EARN TOKENS';

  @override
  String weHowToEarnDesc(String name) {
    return '${name}s have a 15% chance to appear during any battle. Defeat them for 1–3 Event Tokens each.';
  }

  @override
  String get weEventBoss => '⚔ EVENT BOSS';

  @override
  String get weClaimLegendary => 'CLAIM LEGENDARY GEAR  (1 🏆 Boss Token)';

  @override
  String weGearForged(String name, Object lv) {
    return '$name forged at Lv$lv! Check your bag.';
  }

  @override
  String weRewardClaimed(String name) {
    return '$name claimed!';
  }

  @override
  String get gauLeaderboard => 'Gauntlet Leaderboard';

  @override
  String get gauRewardPreview => 'REWARD PREVIEW (on clear)';

  @override
  String get gauAutoRestart => 'AUTO — restarting with your modifiers—';

  @override
  String get gauBackToGauntlet => 'BACK TO GAUNTLET';

  @override
  String gauWave(Object n, Object total) {
    return 'WAVE $n / $total';
  }

  @override
  String gauKills(Object kills) {
    return '$kills KILLS';
  }

  @override
  String gauEssenceBonus(Object pct) {
    return '+$pct% essence';
  }

  @override
  String get brLeaderboard => 'Boss Rush Leaderboard';

  @override
  String get brBestScore => 'BEST SCORE: ';

  @override
  String brBossProgress(Object n, Object total) {
    return 'BOSS $n / $total';
  }

  @override
  String get brPlayAgain => 'PLAY AGAIN';

  @override
  String get brPossibleRewards => 'POSSIBLE REWARDS';

  @override
  String get brRewShards => 'Shards';

  @override
  String get brRewShardsD => '10 per boss  ·  +30 on full clear';

  @override
  String get brRewEchoes => 'Echoes';

  @override
  String get brRewEchoesD => '6 per boss  ·  +25 on full clear';

  @override
  String get brRewZcoins => 'ZCoins';

  @override
  String get brRewZcoinsD => '15 on a full clear';

  @override
  String get brRewMythril => 'Mythril';

  @override
  String get brRewMythrilD => 'Scaled by final rank';

  @override
  String get brRewArtifact => 'Artifact';

  @override
  String get brRewArtifactD => 'Chance drop on A / S-rank clears';

  @override
  String get prgShop => 'PARAGON SHOP';

  @override
  String get prgActiveBonuses => 'ACTIVE BONUSES';

  @override
  String get prgBoard => '✦ PARAGON BOARD';

  @override
  String get prgBoardHint =>
      'Invest points into a direction — ranks scale forever.';

  @override
  String prgRank(Object rank) {
    return 'Rank $rank';
  }

  @override
  String get prgTutorial =>
      '✦ Paragon Points are earned by levelling up — 1 per level. Spend them on the Paragon Board and Shop below for permanent power that never resets.';

  @override
  String get prgShopSub =>
      'Spend Paragon Points on permanent upgrades that persist across all future runs.';

  @override
  String achClaimedTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🏆  $count ACHIEVEMENTS CLAIMED',
      one: '🏆  $count ACHIEVEMENT CLAIMED',
    );
    return '$_temp0';
  }

  @override
  String get achYouReceived => 'You received:';

  @override
  String get achNice => 'NICE!';

  @override
  String achClaimAll(Object n) {
    return 'CLAIM ALL ($n)';
  }

  @override
  String get achEconomy => 'ECONOMY & SYSTEMS';

  @override
  String get achProgress => 'PROGRESS';

  @override
  String achClaimed(Object claimed, Object total) {
    return '$claimed / $total claimed';
  }

  @override
  String achReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count achievements ready to claim!',
      one: '$count achievement ready to claim!',
    );
    return '$_temp0';
  }

  @override
  String get runeTitle => 'ABILITY RUNES';

  @override
  String get runeArcaneDust => '🌀 Arcane Dust: ';

  @override
  String runeOwned(Object a, Object b) {
    return '📜 Owned: $a/$b';
  }

  @override
  String get runeNone => 'No runes available for this class.';

  @override
  String get runeAppBar => 'RUNES';

  @override
  String get runeSocketed => 'SOCKETED';

  @override
  String get runeNotFound =>
      'Not yet found — drops from bosses, dungeons, gauntlet, and expeditions.';

  @override
  String get runeEquipFirst => 'Equip a ring or amulet to socket this rune.';

  @override
  String runeSocketInto(String name, Object cost) {
    return 'Socket → $name  (🌀 $cost)';
  }

  @override
  String get runeBody =>
      'Socket runes to permanently enhance your abilities.\nEach rune modifies a specific ability — boosting damage, duration, or cooldown.\nCosts Arcane Dust from disenchanting gear, gems, and runes.';

  @override
  String get achTutorial =>
      'You defeated your first boss! 🏆 Achievements track milestones and reward ZCoins and Shards — claim them here and check back often.';

  @override
  String get bbLocked => 'BOSS BOUNTIES LOCKED';

  @override
  String get bbLockedSub =>
      'Reach campaign stage 20 to start hunting bosses for bounty rewards.';

  @override
  String bbTitle(Object t) {
    return 'BOSS BOUNTIES  •  TIER $t';
  }

  @override
  String get bbDesc =>
      'Slay each campaign boss for its bounty. Reach a new tier for a fresh set with bigger rewards.';

  @override
  String get bbNoBounties => 'No bounties available.';

  @override
  String bbStageLv(Object n, Object lv) {
    return 'Campaign Stage $n  •  Lv $lv';
  }

  @override
  String bbSlain(String name, String detail) {
    return '$name slain!  $detail';
  }

  @override
  String bbStage(Object n) {
    return 'Stage $n';
  }

  @override
  String bbGearReward(String rarity) {
    return '🎁 $rarity Gear';
  }

  @override
  String bestTotalKills(Object n) {
    return '$n total kills';
  }

  @override
  String get bestTypeMaxed => 'TYPE MAXED';

  @override
  String bestGoldBonus(Object pct) {
    return '+$pct% gold';
  }

  @override
  String get bestKilled => 'killed';

  @override
  String bestNextDmg(Object n) {
    return 'next +1% dmg at $n kills';
  }

  @override
  String get lsTitle => 'DAILY LOGIN';

  @override
  String get lsComeBack => 'Come back tomorrow for your next reward!';

  @override
  String lsStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return '$_temp0';
  }

  @override
  String lsClaimReward(String label) {
    return 'CLAIM  $label';
  }

  @override
  String get lsFullCycle => 'FULL 30-DAY CYCLE';

  @override
  String lsDay(Object d) {
    return 'Day $d';
  }

  @override
  String get lsToday => 'TODAY';

  @override
  String get dashTitle => 'CHARACTER SHEET';

  @override
  String get dashDailyReady => 'Daily challenge ready to claim!';

  @override
  String get dashAbilityAfford =>
      'Ability upgrade affordable — visit ABILITIES';

  @override
  String get dashPassiveAfford => 'Passive upgrade affordable — visit PASSIVES';

  @override
  String get dashEndlessAfford => 'Endless upgrade affordable — visit UPGRADES';

  @override
  String get dashNextAction => 'NEXT ACTION';

  @override
  String get dashIncomeSummary => 'INCOME SUMMARY';

  @override
  String get dashIdleGold => 'Idle gold';

  @override
  String get dashBattleKill => 'Battle/kill';

  @override
  String get dashExpeditions => 'Expeditions';

  @override
  String get dashAchievementsNearby => 'ACHIEVEMENTS NEARBY';

  @override
  String dashDayLoginReward(Object day) {
    return 'DAY $day LOGIN REWARD';
  }

  @override
  String dashExpReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expeditions ready to collect!',
      one: '$count expedition ready to collect!',
    );
    return '$_temp0';
  }

  @override
  String dashMercsIdle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mercs idle — dispatch on an expedition',
      one: '$count merc idle — dispatch on an expedition',
    );
    return '$_temp0';
  }

  @override
  String get emTitle => 'ELEMENTAL MASTERY';

  @override
  String emShards(Object n) {
    return '$n Shards';
  }

  @override
  String get emUp => 'UP';

  @override
  String get spResetsMonthly => '📅 Resets monthly';

  @override
  String get spUnlockPremium => 'Unlock Premium Pass — 2× XP + premium track';

  @override
  String get spFree => 'FREE';

  @override
  String get spPremium => '👑 PREMIUM';

  @override
  String get spTier => 'Tier';

  @override
  String spClaimed(Object reward) {
    return 'Claimed $reward';
  }

  @override
  String get spAllUnlocked => 'All tiers unlocked — nice work!';

  @override
  String spXpToTier(Object xp, Object next, Object tier) {
    return '$xp / $next XP to Tier $tier';
  }

  @override
  String spClaimedN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Claimed $n rewards',
      one: 'Claimed 1 reward',
    );
    return '$_temp0';
  }

  @override
  String get spNothingToClaim => 'Nothing to claim';

  @override
  String get euEchoes => 'Echoes';

  @override
  String get euYourBalance => 'Your balance';

  @override
  String get euEchoesCap => 'ECHOES';

  @override
  String get euTutorial =>
      'Gauntlet runs earn Echoes 🔊 — spend them here on permanent combat upgrades that never reset. These are some of the most powerful bonuses in the game.';

  @override
  String get euPermanent =>
      'Upgrades are permanent per character. Bonuses apply in all game modes.';

  @override
  String euForLv(Object n) {
    return 'for Lv $n';
  }

  @override
  String get euActive => 'ACTIVE';

  @override
  String get lbRefresh => 'Refresh';

  @override
  String get lbNoScores => 'No scores yet — be the first!';

  @override
  String get lbPersonalBest => 'Your personal best';

  @override
  String get lbRank => 'RANK';

  @override
  String get lbYou => 'YOU';

  @override
  String get lbError => 'Could not load leaderboard.';

  @override
  String get lbNotRanked => 'Not ranked yet';

  @override
  String get cmTitle => 'CHALLENGE MODIFIERS';

  @override
  String get cmOptionalHandicaps => 'OPTIONAL HANDICAPS';

  @override
  String get cmActive => 'Active: ';

  @override
  String get cmClear => 'CLEAR';

  @override
  String get cmDesc =>
      'Enable up to one modifier before entering Campaign or Dungeon. Modifiers make battles harder but increase shard rewards per kill.';

  @override
  String cmEssence(Object pct) {
    return '+$pct% essence';
  }

  @override
  String cmEnemyHp(Object mult) {
    return 'Enemy HP ×$mult';
  }

  @override
  String cmEnemyAtk(Object mult) {
    return 'Enemy ATK ×$mult';
  }

  @override
  String cmHeroHp(Object mult) {
    return 'Hero HP ×$mult';
  }

  @override
  String get wClose => 'CLOSE';

  @override
  String get battleLog => 'BATTLE LOG';

  @override
  String get buffDodge => 'DODGE';

  @override
  String get buffStun => 'STUN';

  @override
  String get dhPowerTip =>
      'Medieval Power — combined score of all your upgrades,\ngear, passives, prestige, artifacts, and allies.';

  @override
  String dhHpTip(Object regen) {
    return 'Health Points — reach 0 and you lose the battle.\nRegen: $regen HP/round';
  }

  @override
  String dhXpTip(Object xp, Object lv, Object next) {
    return 'Experience — reach $xp to level up.\nLevel $lv → $next';
  }

  @override
  String get dhNice => 'NICE';

  @override
  String get bspAbilities => 'ABILITIES';

  @override
  String get bspMercs => 'MERCS';

  @override
  String get bspEnemyStun => 'Enemy STUN';

  @override
  String get bspPassive => 'PASSIVE';

  @override
  String bspDescAtk(Object pct) {
    return 'Your hero deals +$pct% damage per hit.';
  }

  @override
  String bspDescArmor(Object pct) {
    return '+$pct% Armor Class rating — reduces incoming enemy damage.';
  }

  @override
  String get bspDescDodge =>
      'Your hero will completely dodge the next enemy attack.';

  @override
  String bspDescAura(Object hp) {
    return 'Healing aura — restores $hp HP at the start of each round.';
  }

  @override
  String bspDescDot(Object dmg) {
    return 'Damage over time — the enemy takes $dmg damage each round.';
  }

  @override
  String get bspDescStun => 'The enemy is stunned and skips its attack.';

  @override
  String get baMercAbility => 'MERC ABILITY';

  @override
  String get tsCleared => 'CLEARED';

  @override
  String get sgFullyUpgraded => 'FULLY UPGRADED';

  @override
  String sgNeedGold(Object cost) {
    return 'Need $cost gold to upgrade';
  }

  @override
  String get fsVictory => 'VICTORY';

  @override
  String get fsDefeat => 'DEFEAT';

  @override
  String fsVs(String enemy, Object rounds) {
    return 'vs $enemy  ·  $rounds rounds';
  }

  @override
  String get fsAbilitiesUsed => 'ABILITIES USED';

  @override
  String get wnTitle => 'WHAT\'S NEW';

  @override
  String get wnLatest => 'LATEST';

  @override
  String get zcShards => 'Shards';

  @override
  String get idbNoItem => 'No item equipped — direct upgrade!';

  @override
  String get absTitle => 'ABILITY SCORES';

  @override
  String get absBanner =>
      'Ability Scores are permanent upgrades purchased with gold.\nUpgrade any score freely — gold is the only requirement.';

  @override
  String get absMaxed => 'MAXED';

  @override
  String absNext(Object cost) {
    return 'Next: $cost gold';
  }

  @override
  String absRankOf(Object rank, Object max) {
    return 'Rank $rank / $max';
  }

  @override
  String get bestUndiscovered => 'Kill this creature to reveal its secrets.';

  @override
  String shopAdOffer(Object n, Object left, Object max) {
    return 'Earn $n ZCoins per ad  •  $left/$max remaining';
  }

  @override
  String get shopLifetimeTitle => 'Eternal Pact';

  @override
  String get shopLifetimeTagline => 'One purchase. All premium perks. Forever.';

  @override
  String get shopLifetimeBadge => 'BEST VALUE';

  @override
  String get shopLifetimeOwned => '✓ UNLOCKED FOREVER';

  @override
  String shopLifetimeBuy(Object price) {
    return 'UNLOCK FOREVER  ·  $price';
  }

  @override
  String get shopLifetimeIncludes => 'EVERYTHING INCLUDED';

  @override
  String get shopLifetimePerk1 => 'All Ascendant\'s Crown perks';

  @override
  String get shopLifetimePerk2 => '5× battle speed';

  @override
  String get shopLifetimePerk3 => '+100% resource generation';

  @override
  String get shopLifetimePerk4 => '2× Season Pass XP';

  @override
  String get shopLifetimePerk5 => 'Premium Season Pass rewards';

  @override
  String get shopLifetimePerk6 => 'Battle Sim access';

  @override
  String get shopLifetimePerk7 => 'No recurring charges — ever';

  @override
  String get shopLifetimePerk8 => 'Auto-Campaign (free from stage 5)';

  @override
  String get ratingTitle => 'Enjoying Zeta Idle?';

  @override
  String get ratingBody =>
      'You\'ve been adventuring for a while! If you\'re having fun, a quick rating really helps the game grow. 🙏';

  @override
  String get ratingLove => 'Loving it!';

  @override
  String get ratingMeh => 'Not really';
}
