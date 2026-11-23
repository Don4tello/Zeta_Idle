// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get ccForgeYourLegend => 'FORGE TA LÉGENDE';

  @override
  String get ccNameYourWarrior => '— NOMME TON GUERRIER —';

  @override
  String get ccDefaultHeroName => 'Le Gardien';

  @override
  String get ccQuickStart => 'DÉMARRAGE RAPIDE';

  @override
  String get ccQuickStartHint =>
      'Lance-toi directement avec un héros recommandé';

  @override
  String get ccChooseClassAndRace => 'CHOISIR CLASSE & RACE';

  @override
  String get ccChooseYourClass => 'CHOISIS TA CLASSE';

  @override
  String get ccSelectYourPath => '— CHOISIS TA VOIE —';

  @override
  String get ccChooseRace => 'CHOISIR LA RACE';

  @override
  String get ccSelectAClass => 'CHOISIS UNE CLASSE';

  @override
  String get ccRecommendedForBeginners => '★ RECOMMANDÉ POUR DÉBUTANTS';

  @override
  String get ccComplexity => 'COMPLEXITÉ';

  @override
  String get ccChooseYourRace => 'CHOISIS TA RACE';

  @override
  String get ccHeritageDefinesYou => '— TON HÉRITAGE TE DÉFINIT —';

  @override
  String get ccBeginYourJourney => 'COMMENCER L\'AVENTURE';

  @override
  String get ccSelectARace => 'CHOISIS UNE RACE';

  @override
  String get ccNameNotAllowed =>
      'Choisis un autre nom — celui-ci n\'est pas autorisé.';

  @override
  String get csSelectCharacter => '— CHOISIR UN PERSONNAGE —';

  @override
  String get csNewCharacter => 'NOUVEAU PERSONNAGE';

  @override
  String get csSwipeToDelete =>
      'Glisse un personnage vers la gauche pour le supprimer';

  @override
  String csDeleteTitle(String name) {
    return 'Supprimer « $name » ?';
  }

  @override
  String get csDeleteBody =>
      'Vraiment ? Une fois supprimé, il ne peut pas être restauré.';

  @override
  String get csCancel => 'ANNULER';

  @override
  String get csDelete => 'SUPPRIMER';

  @override
  String get csLockedSlot => 'EMPLACEMENT VERROUILLÉ';

  @override
  String get navHero => 'HÉROS';

  @override
  String get navPlay => 'JOUER';

  @override
  String get navInventory => 'INVENTAIRE';

  @override
  String get navShop => 'BOUTIQUE';

  @override
  String get navGuild => 'GUILDE';

  @override
  String get modeCampaign => 'CAMPAGNE';

  @override
  String get modeDungeon => 'DONJON';

  @override
  String get modeBossRush => 'BOSS RUSH';

  @override
  String get modeTowerAscension => 'ASCENSION DE LA TOUR';

  @override
  String get modeGauntlet => 'GAUNTLET';

  @override
  String get modePvp => 'JcJ';

  @override
  String get modeChallenges => 'DÉFIS';

  @override
  String get modeEvents => 'ÉVÉNEMENTS';

  @override
  String get modeExpedition => 'EXPÉDITION';

  @override
  String get modeDaily => 'QUOTIDIEN';

  @override
  String get modeBounties => 'PRIMES';

  @override
  String get modeQuests => 'QUÊTES';

  @override
  String get badgeNew => 'NOUVEAU';

  @override
  String get lootLog => 'JOURNAL DE BUTIN';

  @override
  String get noLootYet => 'Pas encore de butin — va combattre quelque chose !';

  @override
  String get welcomeBack => 'Bon retour !';

  @override
  String awayFor(String time) {
    return 'Tu étais absent pendant $time.';
  }

  @override
  String awayForCapped(int hours) {
    return 'Tu étais absent plus de $hours h — affichage des récompenses d\'inactivité maximales.';
  }

  @override
  String rewardGold(String amount) {
    return '+$amount or';
  }

  @override
  String rewardXp(String amount) {
    return '+$amount XP';
  }

  @override
  String rewardShards(String amount) {
    return '+$amount éclats';
  }

  @override
  String expeditionsReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expéditions prêtes !',
      one: '$count expédition prête !',
    );
    return '$_temp0';
  }

  @override
  String get comebackBonus => 'Bonus de retour :';

  @override
  String get idleIncomeCollected =>
      'Revenus d\'inactivité collectés pendant ton repos.';

  @override
  String get claim => 'RÉCLAMER';

  @override
  String get milestone => 'PALIER';

  @override
  String get welcomeBackCaps => 'BON RETOUR !';

  @override
  String get missedYou =>
      'Tu nous as manqué ! Voici un bonus\npour ton absence :';

  @override
  String get newSystemUnlocked => 'NOUVEAU SYSTÈME DÉBLOQUÉ';

  @override
  String get gotIt => 'COMPRIS';

  @override
  String get welcomeFightTitle => 'Combats !';

  @override
  String get welcomeFightBody =>
      'Va dans l\'onglet JOUER et touche une carte d\'étape dans CAMPAGNE pour lancer ton premier combat. Continue d\'attaquer jusqu\'à la chute de l\'ennemi !';

  @override
  String get welcomeIdleTitle => 'Gagne de l\'or passivement';

  @override
  String get welcomeIdleBody =>
      'Ton héros gagne de l\'or automatiquement chaque minute, même sans combattre. Regarde la barre d\'or se remplir dans l\'onglet HÉROS.';

  @override
  String get welcomeStrongerTitle => 'Deviens plus fort';

  @override
  String get welcomeStrongerBody =>
      'Dépense de l\'or dans AMÉLIORATIONS pour augmenter tes stats. Ouvre PASSIFS pour des bonus permanents, et APTITUDES pour de puissantes techniques de combat.';

  @override
  String get welcomeExploreTitle => 'Explore';

  @override
  String get welcomeExploreBody =>
      'La CAMPAGNE progresse à travers 100 étapes artisanales. L\'ASCENSION DE LA TOUR permet de farmer des éclats à l\'infini. Le DONJON est une virée roguelite avec butin et boss. D\'autres modes se débloquent en progressant.';

  @override
  String get navBack => 'RETOUR';

  @override
  String get navNext => 'SUIVANT';

  @override
  String get startPlaying => 'COMMENCER À JOUER';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageSystem => 'Langue du système';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonContinue => 'CONTINUER';

  @override
  String heroFalls(String name) {
    return '$name TOMBE';
  }

  @override
  String get battleGrowStronger => 'Deviens plus fort avant de réessayer.';

  @override
  String get battleBackToHero => 'RETOUR AU HÉROS';

  @override
  String get defeatEndlessTitle => 'MODE INFINI';

  @override
  String get defeatEndlessHint => 'Farm XP & or à ton rythme';

  @override
  String get defeatDungeonHint => 'Gagne éclats & objets';

  @override
  String get defeatGauntletHint => 'Gagne des échos pour les améliorations';

  @override
  String get defeatDailyTitle => 'DÉFIS QUOTIDIENS';

  @override
  String get defeatDailyHint => 'Réclame les récompenses de progression';

  @override
  String battleTierUnlocked(int tier) {
    return 'PALIER $tier DÉBLOQUÉ';
  }

  @override
  String get battleCampaignCleared => 'CAMPAGNE TERMINÉE';

  @override
  String battleTierUnlockedBody(int tier) {
    return 'L\'Oméga est tombé. La campagne redémarre au Palier $tier — ennemis plus coriaces et meilleur butin.\n\nTon niveau, ton Parangon, ton équipement et tes monnaies sont conservés. Rien n\'est réinitialisé.';
  }

  @override
  String get battleCampaignClearedBody =>
      'L\'Oméga est tombé au palier maximal. Tu as atteint le sommet — continue de farmer butin et Points de Parangon.';

  @override
  String get battleSwitchTiersHint =>
      'Change de palier à tout moment depuis l\'en-tête de la Campagne.';

  @override
  String get battleRetreat => 'Battre en retraite';

  @override
  String get battleLastFightSummary => 'Résumé du dernier combat';

  @override
  String get battleResume => 'Reprendre';

  @override
  String get battlePause => 'Pause';

  @override
  String get battleAutoCampaignLocked =>
      'Auto-Campagne — Boost de vitesse / Pass Premium';

  @override
  String get battleAutoCampaignOn => 'Auto-Campagne : ACTIVÉE';

  @override
  String get battleAutoCampaignOff => 'Auto-Campagne : DÉSACTIVÉE';

  @override
  String get battleNoFightYet => 'Aucun combat terminé pour l\'instant.';

  @override
  String get battleAutoCampaignPerk =>
      'L\'Auto-Campagne est un avantage Boost de vitesse / Pass Premium.';

  @override
  String get battleNoActiveBattle => 'AUCUN COMBAT EN COURS';

  @override
  String get battleVictory => 'VICTOIRE !';

  @override
  String get battleBossDefeated => 'BOSS VAINCU';

  @override
  String get battleNewContentUnlocked => 'NOUVEAU CONTENU DÉBLOQUÉ';

  @override
  String get battleClassQuestlineUnlocked =>
      'SÉRIE DE QUÊTES DE CLASSE DÉBLOQUÉE';

  @override
  String battleClassQuestlineBody(String className) {
    return 'La voie du $className commence. Termine 5 quêtes pour débloquer ton Aptitude Ultime.';
  }

  @override
  String battleRewardGold(String amount) {
    return '+$amount OR';
  }

  @override
  String battleRewardXp(String amount) {
    return '+$amount XP';
  }

  @override
  String battleRewardShards(String amount) {
    return '+$amount ÉCLATS';
  }

  @override
  String battleAbilityUnlocked(String name) {
    return 'APTITUDE DÉBLOQUÉE : $name';
  }

  @override
  String get battleAddedToBag => 'Ajouté au sac';

  @override
  String get battleFight => 'COMBATTRE  (−1 ⚡)';

  @override
  String get battleSpeedBoostTitle => 'Boost de vitesse 2×';

  @override
  String battleSpeedBoostBody(int cost, int have) {
    return 'Débloquer la vitesse de combat 2× pendant 7 jours ?\n\nCoût : $cost ZCoins\nTes ZCoins : $have';
  }

  @override
  String get battlePurchase => 'Acheter';

  @override
  String get battleNotEnoughZcoins => 'Pas assez de ZCoins !';

  @override
  String get battleArtifactFound => 'ARTEFACT TROUVÉ !';

  @override
  String battleRoundsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tours restants',
      one: '$count tour restant',
    );
    return '$_temp0';
  }

  @override
  String get commonOk => 'OK';

  @override
  String get campaignDifficultyTier => 'PALIER DE DIFFICULTÉ';

  @override
  String get campaignDifficultyTierTooltip => 'Palier de difficulté';

  @override
  String get campaignTierSelectorBody =>
      'Paliers plus hauts = ennemis plus coriaces ET meilleur butin (rareté, sets, artefacts). Redescendre conserve toute ta puissance permanente — seuls les ennemis et le butin changent d\'échelle.';

  @override
  String get campaignTierNormal => 'PALIER 0 — Normal';

  @override
  String campaignTierN(int tier) {
    return 'PALIER $tier';
  }

  @override
  String get campaignTierBaseDesc =>
      'Ennemis de base · butin de base · pas de Magic Find';

  @override
  String campaignTierScaledDesc(int hp, int atk) {
    return 'Ennemis +$hp% HP · +$atk% ATK';
  }

  @override
  String campaignTierMagicFind(int mf) {
    return '✦ +$mf% Magic Find (rareté, sets & artefacts supérieurs)';
  }

  @override
  String get campaignLeaderboardTooltip => 'Classement de la Campagne';

  @override
  String get campaignTutorial =>
      'La Campagne avance étape par étape. Bats chaque boss pour débloquer la suivante. Terrasse le boss final pour débloquer le Palier de difficulté suivant — la campagne redémarre plus dure avec un meilleur butin, et ta puissance est conservée.';

  @override
  String campaignEnergyRecharge(String time) {
    return '+1 dans $time';
  }

  @override
  String campaignEnergyRefill(int amount, int left) {
    return 'Recharge +$amount  ($left gratuites restantes)';
  }

  @override
  String get campaignBuy => 'Acheter ';

  @override
  String get campaignEnergyEmptyTutorial =>
      'Plus d\'énergie ! ⚡ Elle se recharge de 1 toutes les 5 min. Touche le bouton +10 ci-dessus pour 3 recharges gratuites par jour. Ou achète +20 énergie pour 💎 50 ZCoins.';

  @override
  String get campaignStageMap =>
      'CARTE DES ÉTAPES  •  touche un nœud ✓ pour rejouer';

  @override
  String get campaignNoEnergyRefill =>
      'Pas d\'énergie ! Attends qu\'elle se recharge.';

  @override
  String campaignSimulateStage(int stage) {
    return '⚡ Simuler l\'étape $stage';
  }

  @override
  String campaignEnergyAvailable(int count) {
    return 'Énergie disponible : $count';
  }

  @override
  String get campaignSimInfo =>
      'Les combats sont instantanés. Le butin va directement dans ton sac.';

  @override
  String campaignSimAll(int count) {
    return 'TOUT ($count)';
  }

  @override
  String campaignSimResultTitle(int stage, int count) {
    return 'Étape $stage — $count× simulée';
  }

  @override
  String get campaignSimGold => '💰 Or';

  @override
  String get campaignSimXp => '✦ XP';

  @override
  String campaignItemsDropped(int count) {
    return 'Objets obtenus ($count) :';
  }

  @override
  String get campaignNoItemsDropped => 'Aucun objet obtenu cette fois.';

  @override
  String get campaignNotEnoughEnergy => 'Pas assez d\'énergie !';

  @override
  String get campaignMapFight => '⚔  COMBATTRE (−1 ⚡)';

  @override
  String get campaignSimRequiresPremium =>
      'Nécessite l\'abonnement Pass Premium';

  @override
  String get campaignBossEncounter => 'RENCONTRE DE BOSS';

  @override
  String get campaignDismiss => '[ fermer ]';

  @override
  String campaignPerfectStages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étapes parfaites',
      one: '$count étape parfaite',
    );
    return '$_temp0';
  }

  @override
  String campaignNextMilestone(int next) {
    return '• prochain palier à $next (+mythril +Z-Coins)';
  }

  @override
  String get campaignAllMilestones => '• tous les paliers atteints !';

  @override
  String get hubWhatsNew => 'Nouveautés';

  @override
  String get hubLootLog => 'Journal de butin';

  @override
  String get hubSettings => 'Paramètres';

  @override
  String get hubChange => 'CHANGER';

  @override
  String get hubHeroMenu => 'Menu du héros';

  @override
  String get hubJoinDiscord => 'Rejoins notre Discord';

  @override
  String get hubVisitReddit => 'Visite r/zeta_idle';

  @override
  String hubCouldNotOpen(String url) {
    return 'Impossible d\'ouvrir $url';
  }

  @override
  String get hubLocked => 'Verrouillé';

  @override
  String get hubGroupCharacter => 'PERSONNAGE';

  @override
  String get hubGroupProgression => 'PROGRESSION';

  @override
  String get hubGroupCollection => 'COLLECTION';

  @override
  String get hubGroupRecords => 'RECORDS';

  @override
  String get hubBlurbCharacter => 'Ton build & ta puissance';

  @override
  String get hubBlurbProgression => 'Systèmes de fin de jeu';

  @override
  String get hubBlurbCollection => 'Alliés & compendium';

  @override
  String get hubBlurbRecords => 'Objectifs & détails';

  @override
  String get hubSheet => 'FICHE';

  @override
  String get hubScores => 'CARACS';

  @override
  String get hubAbilities => 'APTITUDES';

  @override
  String get hubPassives => 'PASSIFS';

  @override
  String get hubSpecialize => 'SPÉCIALISER';

  @override
  String get hubParagon => 'PARANGON';

  @override
  String get hubUpgrades => 'AMÉLIORATIONS';

  @override
  String get hubAscend => 'ASCENSION';

  @override
  String get hubMastery => 'MAÎTRISE';

  @override
  String get hubPets => 'FAMILIERS';

  @override
  String get hubMercs => 'MERCENAIRES';

  @override
  String get hubBestiary => 'BESTIAIRE';

  @override
  String get hubCodex => 'CODEX';

  @override
  String get hubArmory => 'ARMURERIE';

  @override
  String get hubAchievements => 'SUCCÈS';

  @override
  String get hubBonuses => 'BONUS';

  @override
  String get auShards => 'éclats';

  @override
  String get auRespecTitle => 'Réinitialiser les aptitudes ?';

  @override
  String auRespecBody(int cost) {
    return 'Réinitialise tous les rangs d\'aptitude et choix de palier.\nTous les éclats dépensés seront remboursés.\n\nCoût : $cost ZCoins';
  }

  @override
  String auRespecConfirm(int cost) {
    return 'RÉINITIALISER ($cost ZC)';
  }

  @override
  String get auRespec => 'RÉINITIALISER';

  @override
  String get auTutorial =>
      'Tu as gagné des Éclats ◆ — dépense-les ici pour débloquer et améliorer des aptitudes de classe qui se déclenchent automatiquement à chaque combat.';

  @override
  String get auIntro =>
      'Dépense des éclats pour renforcer tes aptitudes. Paliers aux rangs 5, 10 et 15. Monte de tier après le rang 15 — chaque tier se débloque avec ton Palier de difficulté.';

  @override
  String get auTitle => 'AMÉLIORATION DES APTITUDES';

  @override
  String get auMaxTier => 'TIER MAX  ✦';

  @override
  String auTierLockedLabel(int tier, int req) {
    return 'TIER $tier  —  Nécessite le Palier de difficulté $req';
  }

  @override
  String get auAscension => 'ASCENSION';

  @override
  String auTierUnlocked(int cap) {
    return 'Tier $cap débloqué';
  }

  @override
  String auAscFullyAscended(int pct) {
    return 'Ascension complète  ·  +$pct% de puissance d\'aptitude';
  }

  @override
  String auAscTierLocked(int cur, int next) {
    return '+$cur% de puissance  ·  Débloque le Palier de difficulté $next (renaissance) pour continuer l\'ascension';
  }

  @override
  String auAscUpgrade(int cur, int next, int cost) {
    return '+$cur%  →  +$next% de puissance  ·  coûte $cost ✦ Parangon';
  }

  @override
  String auAscYouHave(int have) {
    return '  (tu en as $have)';
  }

  @override
  String get auMax => 'MAX';

  @override
  String get auLocked => 'VERROUILLÉ';

  @override
  String auAscendBtn(int cost) {
    return 'ASCENSION  $cost ✦';
  }

  @override
  String get auUltimate => 'ULTIME';

  @override
  String auUnlocksLv(int lv) {
    return 'SE DÉBLOQUE AU NV $lv';
  }

  @override
  String get auFinishQuestline =>
      '🔒 Termine ta série de quêtes de classe pour débloquer';

  @override
  String auReachLevel(int lv, int cur) {
    return 'Atteins le niveau $lv  (toi : Nv $cur)';
  }

  @override
  String auCompleteQuests(String className, int claimed) {
    return 'Termine les 5 quêtes de classe $className  ($claimed / 5)';
  }

  @override
  String get auTrackQuests => 'Suis tes quêtes dans l\'onglet Quêtes.';

  @override
  String get auChoose => 'CHOISIR';

  @override
  String get setTitle => 'PARAMÈTRES';

  @override
  String get setSave => 'SAUVER';

  @override
  String get setLoad => 'CHARGER';

  @override
  String get setReset => 'RÉINITIALISER';

  @override
  String get setOpen => 'OUVRIR';

  @override
  String get setView => 'VOIR';

  @override
  String get setEmail => 'E-MAIL';

  @override
  String get setConfirm => 'CONFIRMER';

  @override
  String get setSecAccount => 'COMPTE';

  @override
  String get setSecPromo => 'CODE PROMO';

  @override
  String get setSecAudio => 'AUDIO';

  @override
  String get setSecHaptics => 'VIBRATIONS';

  @override
  String get setSecNotifications => 'NOTIFICATIONS';

  @override
  String get setSecDisplay => 'AFFICHAGE';

  @override
  String get setSecStats => 'STATS';

  @override
  String get setSecAutoLoot => 'AUTO-BUTIN';

  @override
  String get setSecBattle => 'COMBAT';

  @override
  String get setSecDailyReset => 'RESET QUOTIDIEN';

  @override
  String get setSecSave => 'SAUVEGARDE';

  @override
  String get setSecDanger => 'ZONE DE DANGER';

  @override
  String get setSecHelp => 'AIDE';

  @override
  String get setSecAbout => 'À PROPOS';

  @override
  String get setManage => 'GÉRER';

  @override
  String get setSignIn => 'SE CONNECTER';

  @override
  String get setHeroName => 'Nom du héros';

  @override
  String setRename(int cost) {
    return 'RENOMMER ($cost 🪙)';
  }

  @override
  String get setPromoHint =>
      'Tu as un code ? Utilise-le ici pour des récompenses.';

  @override
  String get setRedeem => 'UTILISER';

  @override
  String get setSoundEffects => 'Effets sonores';

  @override
  String get setBackgroundMusic => 'Musique de fond';

  @override
  String get setVolume => 'Volume';

  @override
  String get setVibration => 'Vibration';

  @override
  String get setReminders => 'Rappels';

  @override
  String get setDamageNumbers => 'Chiffres de dégâts';

  @override
  String get setReducedParticles => 'Particules réduites';

  @override
  String get setTotalPlaytime => 'Temps de jeu total';

  @override
  String get setAutoSalvage => 'Auto-recyclage';

  @override
  String get setAutoEquip => 'Auto-équipement';

  @override
  String get setAutoEquipSub =>
      'Équipe automatiquement les objets meilleurs que l\'équipement actuel';

  @override
  String get setBattleSpeed => 'Vitesse de combat';

  @override
  String get setAutoCampaign => 'Auto-Campagne';

  @override
  String get setResetTime => 'Heure de reset';

  @override
  String get setCloudSave => 'Sauvegarde cloud';

  @override
  String get setCloudSaveSub => 'Synchronise ta progression dans le cloud';

  @override
  String get setCloudSaveComplete => 'Sauvegarde cloud terminée.';

  @override
  String get setLoadCloud => 'Charger depuis le cloud';

  @override
  String get setLoadCloudSub =>
      'Écrase la sauvegarde locale avec les données cloud';

  @override
  String get setResetProgress => 'Réinitialiser la progression';

  @override
  String get setResetProgressSub =>
      'Supprime toutes les données de cet emplacement. Irréversible.';

  @override
  String get setKnowledgeBase => 'Base de connaissances';

  @override
  String get setKnowledgeBaseSub => 'Mots-clés, systèmes, monnaies expliqués';

  @override
  String get setTagline => 'Un RPG idle médiéval sombre.';

  @override
  String get setAboutHero => 'Héros';

  @override
  String get setAboutClass => 'Classe';

  @override
  String get setAboutLevel => 'Niveau';

  @override
  String get setAboutPrestige => 'Prestige';

  @override
  String get setAboutAchievements => 'Succès';

  @override
  String get setAboutDeveloper => 'Développeur';

  @override
  String get setAboutContact => 'Contact';

  @override
  String get setPrivacy => 'Politique de confidentialité';

  @override
  String get setPrivacySub => 'Comment nous traitons tes données';

  @override
  String get setReportBug => 'Signaler un bug / Avis';

  @override
  String get setReportBugSub =>
      'Écris-nous — les infos appareil sont ajoutées automatiquement';

  @override
  String get setReplayTips => 'Revoir les astuces';

  @override
  String get setReplayTipsSub => 'Réaffiche les astuces du tutoriel en jeu';

  @override
  String get setTipsReset =>
      'Astuces réinitialisées — elles réapparaîtront en explorant.';

  @override
  String get setRenameHeroTitle => 'RENOMMER LE HÉROS';

  @override
  String get setHeroNameHint => 'Saisis un nom de héros';

  @override
  String setRenameCost(int cost, int have) {
    return 'Coût : $cost 🪙   (tu en as $have)';
  }

  @override
  String setRenameNotEnough(int cost) {
    return 'Pas assez de Z-Coins — renommer coûte $cost 🪙.';
  }

  @override
  String get setNoEmailApp =>
      'Aucune appli e-mail trouvée. Contacte-nous : razorintegrations@gmail.com';

  @override
  String get setDailyResetTitle => 'Heure du reset quotidien';

  @override
  String get setDailyResetHint =>
      'Choisis l\'heure de réinitialisation des limites quotidiennes.';

  @override
  String get setDailyResetWarning =>
      'Attention : modifiable une seule fois par an.';

  @override
  String get setLoadCloudTitle => 'Charger depuis le cloud ?';

  @override
  String get setLoadCloudBody =>
      'Cela écrasera ta sauvegarde locale avec les données cloud. La progression locale non synchronisée sera perdue.';

  @override
  String get setResetAllTitle => 'Tout réinitialiser ?';

  @override
  String get setResetAllBody =>
      'Toute la progression, l\'or, les objets, les niveaux de prestige et les succès seront définitivement supprimés. Irréversible.';

  @override
  String get setNewHeroName => 'Nouveau nom du héros :';

  @override
  String get setGoogleAccount => 'Compte Google';

  @override
  String get setSignInGoogle => 'Se connecter avec Google';

  @override
  String get setSignedIn => 'Connecté';

  @override
  String get setSyncSaves => 'Synchronise les sauvegardes entre appareils';

  @override
  String get setEnterCode => 'SAISIR LE CODE';

  @override
  String get setOff => 'Désactivé';

  @override
  String get setOffCaps => 'DÉSACTIVÉ';

  @override
  String get setHidden => 'Masqué';

  @override
  String get setVibrationOn =>
      'Vibre sur crits, montées de niveau, victoires & récompenses';

  @override
  String get setRemindersOn =>
      'Reçois des rappels « reviens » pendant ton absence';

  @override
  String get setDamageOn => 'Chiffres flottants affichés en combat';

  @override
  String get setParticlesOn =>
      'Moins d\'effets de fond (meilleures performances)';

  @override
  String get setParticlesOff => 'Effets complets';

  @override
  String get setSalvageOff => 'Touche pour activer l\'auto-recyclage du butin';

  @override
  String setSalvageOn(String tier) {
    return 'Auto-recycle $tier et en dessous';
  }

  @override
  String get setAutoCampaignOnSub =>
      'Mène automatiquement les combats de campagne en arrière-plan';

  @override
  String get setAutoCampaignLockedSub =>
      '🔒 Réservé aux abonnés Boost de vitesse / Pass Premium';

  @override
  String setResetTimeOn(String time) {
    return 'Les limites quotidiennes se réinitialisent à $time. Touche pour changer (une fois par an).';
  }

  @override
  String setResetTimeLocked(String time) {
    return 'Reset à $time · Déjà modifié cette année.';
  }

  @override
  String get guildTitle => 'GUILDE';

  @override
  String get guildJoinTitle => 'REJOINDRE UNE GUILDE';

  @override
  String get guildJoinBlurb =>
      'Les guildes offrent des bonus passifs, un défi de boss hebdomadaire et une boutique de guilde avec des récompenses exclusives.';

  @override
  String get guildCreate => 'CRÉER UNE GUILDE';

  @override
  String get guildPublic => 'GUILDES PUBLIQUES';

  @override
  String get guildNoGuilds =>
      'Aucune guilde trouvée. Sois le premier à en créer une !';

  @override
  String get guildCreateTitle => 'Créer une guilde';

  @override
  String get guildNameLabel => 'Nom de la guilde';

  @override
  String get guildDescLabel => 'Description (facultatif)';

  @override
  String get guildCreateBtn => 'CRÉER';

  @override
  String get guildTabInfo => 'INFOS';

  @override
  String get guildTabCastle => 'CHÂTEAU';

  @override
  String get guildTabBoss => 'BOSS';

  @override
  String get guildTabWar => 'GUERRE';

  @override
  String get guildTabChat => 'CHAT';

  @override
  String get guildTabShop => 'BOUTIQUE';

  @override
  String guildCastleTier(int tier) {
    return 'CHÂTEAU — PALIER $tier / 10';
  }

  @override
  String guildProgressTier(int tier) {
    return 'Progression vers le Palier $tier';
  }

  @override
  String guildCpProgress(int cp, int cap) {
    return '$cp / $cap PC';
  }

  @override
  String guildNext(String headline) {
    return 'Suivant : $headline';
  }

  @override
  String get guildCitadelComplete =>
      'Citadelle achevée — le château est entièrement construit !';

  @override
  String get guildContributeGold => 'CONTRIBUER DE L\'OR';

  @override
  String guildContributeInfo(String rate, int cap) {
    return 'Convertis de l\'or en Points de Construction (PC). Taux : $rate or = 1 PC. Tu peux ajouter jusqu\'à $cap PC par jour.';
  }

  @override
  String get guildActiveBenefits => 'AVANTAGES ACTIFS DU CHÂTEAU';

  @override
  String get guildContributeHint =>
      'Contribue pour élever le château et débloquer des avantages.';

  @override
  String guildCastleAdvanced(int tier) {
    return '🏰 Le château passe au Palier $tier !';
  }

  @override
  String get guildCapReached =>
      'Limite de construction quotidienne atteinte — reviens demain !';

  @override
  String guildLevelMembers(int lvl, int m, int max) {
    return 'Niveau $lvl  •  $m/$max membres';
  }

  @override
  String guildBonusGold(int pct) {
    return '+$pct% Or';
  }

  @override
  String guildBonusXp(int pct) {
    return '+$pct% XP';
  }

  @override
  String guildBonusIdle(int pct) {
    return '+$pct% Inactif';
  }

  @override
  String guildXpProgress(int xp, int max) {
    return '$xp/$max XP';
  }

  @override
  String get guildDonate1000 => 'DONNER 1000 OR';

  @override
  String get guildDonateReward => '→ XP de guilde + 🪙';

  @override
  String get guildPerks => 'AVANTAGES';

  @override
  String guildLockedPerk(int lvl, String name, String desc) {
    return '🔒 Nv$lvl : $name — $desc';
  }

  @override
  String get guildMembers => 'MEMBRES';

  @override
  String guildMemberLine(int lvl, String cls, String role, int d) {
    return 'Nv$lvl $cls  •  $role  •  dons : $d or';
  }

  @override
  String get guildLeave => 'QUITTER LA GUILDE';

  @override
  String get guildNoBoss => 'Pas de boss cette semaine.';

  @override
  String get guildWeeklyBoss => '☠ BOSS DE GUILDE HEBDO';

  @override
  String guildBossHp(int hp, int max) {
    return '$hp / $max HP';
  }

  @override
  String get guildDefeated => '✓ VAINCU';

  @override
  String guildBossRewardMsg(Object rank, Object gc, Object gold) {
    return '🏆 Boss de la semaine dernière : Rang #$rank — +$gc Pièces de guilde, +$gold or';
  }

  @override
  String get guildClaimBossReward => '🏆 RÉCLAMER LA RÉCOMPENSE DU BOSS';

  @override
  String guildAttempts(int rem, int max) {
    return 'Tentatives : $rem / $max';
  }

  @override
  String get guildNoAttempts => 'PLUS DE TENTATIVES';

  @override
  String get guildChallengeBoss => '⚔ DÉFIER LE BOSS';

  @override
  String get guildDamageRanking => 'CLASSEMENT DES DÉGÂTS';

  @override
  String guildDmg(int dmg) {
    return '$dmg dégâts';
  }

  @override
  String get guildWarStandings => 'CLASSEMENT DE GUERRE';

  @override
  String guildWarRecord(int w, int l) {
    return 'Ton bilan : ${w}V–${l}D';
  }

  @override
  String get guildWeeklyWar => 'Guerre de guilde hebdomadaire';

  @override
  String get guildWarBlurb =>
      'Engage-toi pendant la Préparation (lun–mar). Mer–ven, dépense tes Attaques de guerre pour affronter les champions rivaux et marquer des points pour ta guilde. Sam–dim, réclame les récompenses de rang.';

  @override
  String get guildEnlistedBattle =>
      '⚔ Engagé ! Dépense tes Attaques de guerre maintenant.';

  @override
  String get guildEnlistedPrep => '⚔ Engagé ! Reviens mer–ven pour combattre.';

  @override
  String get guildEnlist => 'ENGAGER TA GUILDE';

  @override
  String get guildWarEndedWait =>
      'GUERRE TERMINÉE — ATTENDS LA SEMAINE PROCHAINE';

  @override
  String guildScoreYou(String name) {
    return '$name (toi)';
  }

  @override
  String get guildLeads => '🏆 Ta guilde est en tête !';

  @override
  String get guildBehind => '⚠ Ta guilde est à la traîne — combats !';

  @override
  String guildFightForGuild(int c, int max) {
    return '⚔ COMBATTRE POUR LA GUILDE  ($c/$max)';
  }

  @override
  String get guildNoWarAttacks => 'PLUS D\'ATTAQUES DE GUERRE AUJOURD\'HUI';

  @override
  String get guildWarRefresh =>
      'Les Attaques de guerre se rechargent chaque jour pendant la phase de Bataille.';

  @override
  String get guildWarVictory => '🏆 Victoire !';

  @override
  String get guildWarOver => 'Guerre terminée.';

  @override
  String guildWarRewardMsg(String result, Object gc, Object gold) {
    return '$result +$gc Pièces de guilde, +$gold or';
  }

  @override
  String get guildRewardsClaimed => 'RÉCOMPENSES RÉCLAMÉES';

  @override
  String get guildClaimWarRewards => 'RÉCLAMER LES RÉCOMPENSES DE GUERRE';

  @override
  String get guildWarBattleSoon =>
      'La bataille commence mercredi — reviens combattre !';

  @override
  String get guildCoinsLabel => 'Pièces de guilde';

  @override
  String guildListLine(int lvl, int m, int max) {
    return 'Nv$lvl  •  $m/$max membres';
  }

  @override
  String get guildJoin => 'REJOINDRE';

  @override
  String get guildFull => 'PLEINE';

  @override
  String get guildBossTitle => 'BOSS DE GUILDE';

  @override
  String get guildBossWin => '✦ BOSS VAINCU !';

  @override
  String get guildBossLose => '💀 TOMBÉ';

  @override
  String guildTotalDamage(int d) {
    return 'Dégâts totaux infligés : $d';
  }

  @override
  String get guildReturn => 'RETOUR À LA GUILDE';

  @override
  String guildCpAmount(int cp) {
    return '+$cp PC';
  }

  @override
  String guildGoldCost(String gold) {
    return '$gold or';
  }

  @override
  String get forgeSalvageTooltip =>
      'Détruis des objets pour récupérer des Éclats (◆).\n• Commun → 3 ◆\n• Rare → 8 ◆\n• Épique → 20 ◆\n• Légendaire → 60 ◆\n• Set → 100 ◆';

  @override
  String get forgeUpgradeTooltip =>
      'Améliore un objet de +0 à +10.\nChaque palier augmente toutes les stats de 8%.\nÀ +5 et +10 l\'objet gagne un préfixe de titre.\nCoûte Or + Éclats par palier.';

  @override
  String get forgeTitle => 'FORGE';

  @override
  String get forgeSalvage => 'RECYCLER';

  @override
  String get forgeUpgrade => 'AMÉLIORER';

  @override
  String get forgeSlot => 'EMPLACEMENT';

  @override
  String get forgeFrom => 'DEPUIS  ';

  @override
  String forgeForged(String name, String label) {
    return 'Forgé : $name ($label) !';
  }

  @override
  String get forgeSalvageRates => 'TAUX DE RECYCLAGE';

  @override
  String forgeSalvageBtn(int n, int s) {
    return 'RECYCLER  $n  (+$s ◆)';
  }

  @override
  String get forgeBagEmpty => 'Ton sac est vide.';

  @override
  String forgeBag(int n) {
    return 'SAC  ($n objets)';
  }

  @override
  String forgeSalvaged(int earned) {
    return 'Recyclé : +$earned ◆';
  }

  @override
  String forgeTimesN(int n) {
    return ' ×$n';
  }

  @override
  String get forgeTimesRandom => '  ×1 (aléatoire)';

  @override
  String get forgeMasterForger => 'Maître forgeron';

  @override
  String get forgeSelected => 'SÉLECTIONNÉ';

  @override
  String forgeSelectedCount(int selected, int needed) {
    return '$selected / $needed';
  }

  @override
  String get forgeArcaneDust => 'POUSSIÈRE ARCANIQUE';

  @override
  String get forgeGemType => 'TYPE DE GEMME';

  @override
  String forgeGemWeaponDesc(Object pct, String type) {
    return '⚔ Arme : +$pct% dégâts $type';
  }

  @override
  String forgeGemArmorDesc(Object pct, String type) {
    return '🛡 Armure : +$pct% résistance $type';
  }

  @override
  String get forgeTier => 'PALIER';

  @override
  String forgeGemBagFull(int n, int max) {
    return 'SAC À GEMMES PLEIN ($n/$max)';
  }

  @override
  String forgeNeedMore(int n) {
    return 'ENCORE $n 💠 REQUIS';
  }

  @override
  String forgeCraft(int cost) {
    return '✦  FABRIQUER  $cost 💠';
  }

  @override
  String forgePreviewWeapon(String effect) {
    return '⚔ Arme : $effect';
  }

  @override
  String forgePreviewArmor(String effect) {
    return '🛡 Armure : $effect';
  }

  @override
  String forgeToCraft(int cost) {
    return '$cost 💠 pour fabriquer';
  }

  @override
  String forgeGemBag(int n, int max) {
    return 'SAC À GEMMES  ($n/$max)';
  }

  @override
  String get forgeTapGem => 'Touche une gemme pour la sertir dans un objet';

  @override
  String get forgeNoGems =>
      'Aucune gemme fabriquée. Fabriques-en une ci-dessus !';

  @override
  String get forgeHowGems => 'FONCTIONNEMENT DES GEMMES';

  @override
  String get forgeGemsInfo =>
      '• Chaque gemme a un double usage — la MÊME gemme donne des DÉGÂTS élémentaires dans une arme, ou une RÉSISTANCE élémentaire dans une armure / un bijou.\n• Les éclats de gemme tombent des kills en combat (25% de chance) et des boss.\n• Chaque objet peut contenir 1 gemme dans son chaton.\n• Sertis les gemmes depuis ce sac ou via l\'écran Inventaire.\n• Remplacer ou retirer une gemme détruit l\'ancienne.';

  @override
  String get forgeNoItemsSocket => 'Aucun objet où sertir.';

  @override
  String forgeSocketGem(String name) {
    return 'Sertir $name';
  }

  @override
  String get forgeChooseItem => 'Choisis un objet où sertir cette gemme.';

  @override
  String get forgeReplaceGem => 'Remplacer la gemme ?';

  @override
  String forgeReplaceBody(String old, String gnew) {
    return '$old sera détruite et remplacée par $gnew. Action irréversible.';
  }

  @override
  String get forgeReplace => 'REMPLACER';

  @override
  String get forgeUpgradeInfo =>
      'Améliore les objets de +0 à +10. Chaque palier augmente toutes les stats de 8%.\nÀ +5 l\'objet gagne le préfixe Raffiné.\nÀ +10 il devient Chef-d\'œuvre.';

  @override
  String get forgeBalance => 'Solde : ';

  @override
  String get forgeNoUpgradeItems =>
      'Aucun objet à améliorer.\nTout est à +10 ou le sac est vide.';

  @override
  String get forgeSelectItem => 'CHOISIR UN OBJET';

  @override
  String get forgeAllStats => 'Toutes les stats +8%';

  @override
  String get forgeWeaponDmgSuffix => '  •  Dégâts d\'arme +8%';

  @override
  String get forgeRefinedPrefix => '🏷 Gagne le préfixe « Raffiné » à +5 !';

  @override
  String get forgeMasterworkPrefix =>
      '🏷 Gagne le préfixe « Chef-d\'œuvre » à +10 !';

  @override
  String forgeUpgradeTo(int tier) {
    return 'AMÉLIORER À +$tier';
  }

  @override
  String get dngTitle => 'LE DONJON';

  @override
  String dngTitleRun(int tier, int floor) {
    return 'P$tier  ÉT.$floor  —  LE DONJON';
  }

  @override
  String get dngFlee => 'Fuir le donjon';

  @override
  String get dngAutoOn => 'Auto : ACTIVÉ — touche pour reprendre la main';

  @override
  String get dngAutoOff =>
      'Auto : DÉSACTIVÉ — touche pour nettoyer automatiquement';

  @override
  String get dngAutoPremium => 'Mode Auto (débloqué à l\'Étape 5)';

  @override
  String get dngPushOnTip =>
      'Percée abyssale : ACTIVÉE — bats le Seigneur du Donjon pour descendre plus profond';

  @override
  String get dngPushOffTip =>
      'Percée abyssale : DÉSACTIVÉE — la virée s\'arrête à l\'étage final';

  @override
  String get dngPushOnMsg =>
      'Percée abyssale ACTIVÉE — terrasse le Seigneur du Donjon pour descendre dans des étages abyssaux croissants (plus de Mythril + chances d\'uniques). Fuis à tout moment pour sécuriser la victoire.';

  @override
  String get dngPushOffMsg =>
      'Percée abyssale DÉSACTIVÉE — la virée s\'achève quand tu terrasses le Seigneur du Donjon.';

  @override
  String get dngLeaderboard => 'Classement du Donjon';

  @override
  String get dngAutoPremiumMsg =>
      'Le mode Auto se débloque à l\'Étape 5 de la campagne.';

  @override
  String get dngTutorial =>
      'Choisis l\'une des deux portes à chaque étage. Les ennemis tués lâchent des Os — dépense-les chez le Marchand itinérant pour des bonus de virée. Le butin est à toi immédiatement, même si ton héros tombe.';

  @override
  String get dngWhatToExpect => 'À QUOI S\'ATTENDRE';

  @override
  String get dngExpCombat => 'Combat — bats-toi pour de l\'or';

  @override
  String get dngExpElite => 'Élite — ennemi coriace, objet garanti';

  @override
  String get dngExpAmbush =>
      'Embuscade — l\'ennemi frappe en premier, or élevé';

  @override
  String get dngExpRest => 'Camp de repos — récupère 20% HP';

  @override
  String get dngExpTreasure => 'Trésor — ramasse or & éclats';

  @override
  String get dngExpShrine => 'Sanctuaire — choisis une bénédiction de virée';

  @override
  String get dngExpChest =>
      'Coffre verrouillé — dépense des éclats pour un objet rare';

  @override
  String get dngExpTrap => 'Piège — dégâts inévitables';

  @override
  String get dngExpBoss =>
      'Boss (tous les 5 étages) — gros risque, grosse récompense';

  @override
  String get dngBonesHint =>
      'Les ennemis tués lâchent des Os — dépense-les chez le Marchand itinérant.';

  @override
  String get dngExpectedLoot => 'BUTIN ATTENDU';

  @override
  String get dngLootGold => 'Or';

  @override
  String get dngLootGoldDetail =>
      'Des combats, salles au trésor & provisions de repos';

  @override
  String get dngLootShards => 'Éclats';

  @override
  String get dngLootShardsDetail => 'Salles au trésor & coffres en chemin';

  @override
  String get dngLootItems => 'Objets';

  @override
  String dngLootItemsDetail(String tier) {
    return 'Palier d\'objet à ta profondeur : $tier  (élites & boss lâchent mieux)';
  }

  @override
  String get dngLootMythril => 'Mythril';

  @override
  String dngLootMythrilDetail(int a, int b) {
    return '~$a à l\'étage 5  •  ~$b à l\'étage 10';
  }

  @override
  String dngYourBest(int f, int m) {
    return 'Ton record : étage $f  •  ~$m mythril';
  }

  @override
  String get dngNoRecord => 'Aucun record';

  @override
  String dngDeepestFloor(int f) {
    return 'Étage le plus profond : $f';
  }

  @override
  String dngDailyAttempts(int r, int max) {
    return 'Tentatives du jour : $r / $max';
  }

  @override
  String dngEnterTier(int tier) {
    return 'ENTRER  PALIER $tier';
  }

  @override
  String get dngNoAttempts => 'PLUS DE TENTATIVES';

  @override
  String dngBuyExtra(int cost) {
    return '$cost ZCoins — Acheter 1 tentative de plus';
  }

  @override
  String get dngBossFloor => '☠ ÉTAGE DE BOSS';

  @override
  String dngBossIn(int n) {
    return '☠ Boss dans $n';
  }

  @override
  String get dngChoosePath => 'CHOISIS TA VOIE';

  @override
  String get dngNextBoss => '☠ ÉTAGE SUIVANT : BOSS';

  @override
  String get dngMystery => 'MYSTÈRE';

  @override
  String get dngGoblin => '💰 GOBELIN AU TRÉSOR';

  @override
  String get dngEnter => 'ENTRER';

  @override
  String get dngMystery1 => 'Une porte sans inscription.';

  @override
  String get dngMystery2 => 'Fortune ou péril ?';

  @override
  String dngGoblinHp(Object hp) {
    return '$hp HP  •  s\'enfuit après 5 tours';
  }

  @override
  String get dngGoblinReward => '6× l\'or si tu le tues à temps !';

  @override
  String get dngGuaranteedDrop => 'Objet garanti';

  @override
  String get dngStrikesFirst => 'Frappe en premier — or élevé';

  @override
  String get dngDoorBlessing => 'Une bénédiction...';

  @override
  String get dngDoorCurse => 'ou une malédiction ?';

  @override
  String get dngMakeCamp => 'Monter le camp';

  @override
  String get dngRecoverHp => 'Récupérer des HP';

  @override
  String get dngRareInside => 'Objet rare à l\'intérieur';

  @override
  String dngShardsToOpen(Object n) {
    return '$n éclats pour ouvrir';
  }

  @override
  String dngPlusGold(Object g) {
    return '+$g or';
  }

  @override
  String dngPlusShards(Object s) {
    return '+$s éclats';
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
  String get dngEnemy => 'Ennemi';

  @override
  String get dngSpeedNeeds =>
      'Une vitesse supérieure nécessite le Boost de vitesse / Pass Premium.';

  @override
  String get dngTreasureFound => 'Trésor trouvé !';

  @override
  String get dngCursed => '✸ MAUDIT !';

  @override
  String get dngBlessed => '✧ BÉNI !';

  @override
  String get dngDarkToll => 'Les ténèbres prélèvent leur tribut...';

  @override
  String get dngAncientPower => 'Un pouvoir ancien te traverse.';

  @override
  String get dngLightShadow => 'Lumière et ombre se lient à ton destin.';

  @override
  String get dngShrineCorrupted => 'Sanctuaire corrompu';

  @override
  String get dngShrineBlessed => 'Sanctuaire béni';

  @override
  String get dngShrineAncient => 'Sanctuaire ancien';

  @override
  String get dngShrineCorruptedFlavor =>
      'Des énergies sombres pulsent et se tordent. La malédiction est certaine — mais le pouvoir attend.';

  @override
  String get dngShrineBlessedFlavor =>
      'Une chaleureuse lumière divine émane de ce lieu. Une bénédiction est garantie.';

  @override
  String get dngShrineTwinFlavor =>
      'Deux forces s\'agitent ici — tu recevras une bénédiction ET une malédiction.';

  @override
  String get dngShrineNormalFlavor =>
      'Un sanctuaire mystérieux pulse d\'une énergie inconnue.\nEntre pour recevoir une bénédiction... ou une malédiction.\nTu ne sauras laquelle qu\'une fois trop tard.';

  @override
  String get dngAcceptCurse => 'ACCEPTER LA MALÉDICTION';

  @override
  String get dngReceiveBlessing => 'RECEVOIR LA BÉNÉDICTION';

  @override
  String get dngEnterTwin => 'ENTRER  (2 EFFETS)';

  @override
  String get dngEnterShrine => 'ENTRER DANS LE SANCTUAIRE';

  @override
  String dngActiveEffects(int n) {
    return 'Effets actifs : $n';
  }

  @override
  String get dngSkip => 'PASSER';

  @override
  String dngGuaranteeBless(int c) {
    return '✧  GARANTIR LA BÉNÉDICTION  ($c ◆)';
  }

  @override
  String dngTrapDamage(int dmg, int pct) {
    return 'Tu subiras $dmg dégâts ($pct% des HP max).';
  }

  @override
  String get dngLockedChest => 'Coffre verrouillé';

  @override
  String get dngChestContains => 'Contient un objet rare ou épique.';

  @override
  String dngCostShards(Object cost) {
    return '$cost éclats';
  }

  @override
  String dngHave(int n) {
    return '(tu en as $n)';
  }

  @override
  String dngCostZcoins(int cost) {
    return '$cost ZCoins';
  }

  @override
  String get dngMerchantQuote =>
      '« Des os contre des babioles, voyageur. Plus d\'os, meilleure marchandise. »';

  @override
  String dngBones(int n) {
    return '🦴  $n Os';
  }

  @override
  String dngBoneCost(int c) {
    return '$c 🦴';
  }

  @override
  String get dngClaimRelic => '☠ BOSS TERRASSÉ — RÉCLAME UNE RELIQUE';

  @override
  String get dngSkipDescend => 'PASSER — DESCENDRE';

  @override
  String get dngReturn => 'RETOUR';

  @override
  String dngDescendTo(int n) {
    return 'DESCENDRE À L\'ÉTAGE $n';
  }

  @override
  String get dngFallen => '☠ Tombé';

  @override
  String get dngGotAway => '💰 Il s\'est enfui !';

  @override
  String get dngVictory => '✓ Victoire';

  @override
  String dngAmbushHit(int n) {
    return 'L\'embuscade a infligé $n avant le combat.';
  }

  @override
  String dngItemToBag(String name, String label) {
    return '✦ $name ($label) → Sac';
  }

  @override
  String get dngRested => '⊕ Reposé';

  @override
  String get dngTreasureCollected => '✦ Trésor collecté';

  @override
  String get dngBlessingReceived => '✧ Bénédiction reçue';

  @override
  String get dngSlainTrap => '☠ Tué par le piège';

  @override
  String get dngTrapSurvived => '✸ Piège survécu';

  @override
  String get dngChestOpened => '◆ Coffre ouvert';

  @override
  String get dngLootAdded => 'Ton butin a déjà été ajouté à ton compte.';

  @override
  String dngLordFallen(int z, int g) {
    return 'Le Seigneur du Donjon est tombé !\n+5 mythril  •  +$z Z-Coins  •  +$g or  •  objet bonus';
  }

  @override
  String dngTierN(int t) {
    return 'PALIER $t';
  }

  @override
  String get dngFloor => 'ÉTAGE';

  @override
  String get dngRooms => 'SALLES';

  @override
  String get dngBosses => 'BOSS';

  @override
  String get dngGold => 'OR';

  @override
  String get dngShards => 'ÉCLATS';

  @override
  String dngTierCleared(int t) {
    return '✓ Palier $t terminé — AUTO débloqué !';
  }

  @override
  String get dngNewRecord => '★ Nouveau record !';

  @override
  String get dngAllLootAdded => 'Tout le butin a été ajouté à ton compte.';

  @override
  String get dngYouFallen => 'TU ES TOMBÉ';

  @override
  String get dngCleared => 'DONJON TERMINÉ !';

  @override
  String get dngRunEnded => 'VIRÉE TERMINÉE';

  @override
  String get dngAutoLocked => '🔒 AUTO';

  @override
  String get dngStop => '◉ STOP';

  @override
  String get dngAuto => '✦ AUTO';

  @override
  String get dngRunAgain => 'RECOMMENCER';

  @override
  String get dngReturnHall => 'RETOUR AU HALL';

  @override
  String get auraEquipped => 'ÉQUIPÉ';

  @override
  String get auraOn => 'ACTIF';

  @override
  String auraCost(int n) {
    return 'Coût : $n zcoins';
  }

  @override
  String auraUnlockTitle(String name) {
    return 'Débloquer $name ?';
  }

  @override
  String get auraAllAuras => 'TOUTES LES AURAS';

  @override
  String get auraAllSkins => 'TOUS LES SKINS';

  @override
  String get auraAllPets => 'TOUS LES FAMILIERS';

  @override
  String get auraRemoveAura => 'Retirer l\'aura';

  @override
  String get auraRemoveSkin => 'Retirer le skin';

  @override
  String get auraDismissPet => 'Renvoyer le familier';

  @override
  String get auraBattleCompanion => 'COMPAGNON DE COMBAT';

  @override
  String get auraWaystones => 'PIERRES DE VOIE';

  @override
  String get auraAttackEffects => 'EFFETS D\'ATTAQUE';

  @override
  String get auraCharSlots => 'EMPLACEMENTS DE PERSONNAGE';

  @override
  String get auraCompanionNote =>
      'Un seul compagnon peut être actif à la fois. Chacun accorde un petit bonus passif.';

  @override
  String get auraBeforeAfter => 'Avant / Après';

  @override
  String get auraAllSlots => 'Les 12 emplacements sont débloqués.';

  @override
  String auraAdoptTitle(String name) {
    return 'Adopter $name ?';
  }

  @override
  String auraPetBonus(String label) {
    return '✦ $label';
  }

  @override
  String get auraMaxEvolution => '★★ ÉVOLUTION MAX';

  @override
  String auraOwned(Object count) {
    return 'Possédés : $count';
  }

  @override
  String auraWaystoneDesc(Object h, String m) {
    return '$h h  ·  $m× revenus d\'inactivité';
  }

  @override
  String auraHitEvery(String text) {
    return '« $text » à chaque coup';
  }

  @override
  String auraSlotN(Object n) {
    return 'Emplacement $n';
  }

  @override
  String get auraAddSlot =>
      'Ajoute un emplacement de sauvegarde de personnage.';

  @override
  String get auraUnlock => 'DÉBLOQUER';

  @override
  String get auraAdopt => 'ADOPTER';

  @override
  String get auraBuy => 'ACHETER';

  @override
  String get auraEvolve => 'FAIRE ÉVOLUER';

  @override
  String get auraEquip => 'ÉQUIPER';

  @override
  String get auraActive => 'ACTIF';

  @override
  String get auraSendOut => 'ENVOYER';

  @override
  String get auraStackAuras =>
      'Les bonus de chaque aura que tu POSSÈDES se cumulent automatiquement — tu les gardes toutes. Équipe-en une juste pour choisir la lueur affichée.';

  @override
  String get auraStackSkins =>
      'Les bonus de chaque skin que tu POSSÈDES se cumulent automatiquement — tu les gardes tous. Équipe-en un juste pour choisir l\'apparence portée.';

  @override
  String get armTabUniques => 'UNIQUES';

  @override
  String get armTabMythic => 'MYTHIQUE';

  @override
  String get armTabSets => 'OBJETS DE SET';

  @override
  String get armTabArtifacts => 'ARTEFACTS';

  @override
  String get armNoLegendaries => 'Aucun légendaire pour cette classe.';

  @override
  String armClassUniques(int count) {
    return '$count uniques de classe';
  }

  @override
  String get armOwned => 'POSSÉDÉ';

  @override
  String armSlotReqLevel(String slot, int lvl) {
    return '$slot  •  Niv. requis $lvl';
  }

  @override
  String get armStats => 'STATS';

  @override
  String get armAbilityEnh => 'AMÉLIORATION D\'APTITUDE';

  @override
  String armAbilityDamage(String x) {
    return '• Dégâts d\'aptitude ×$x';
  }

  @override
  String armAbilityDuration(Object n) {
    return '• +$n tours de durée';
  }

  @override
  String armAbilityCooldown(String v) {
    return '• $v tours de recharge';
  }

  @override
  String armOnCast(String desc) {
    return '• À l\'incantation : $desc';
  }

  @override
  String get armHowToFind => 'OÙ LE TROUVER';

  @override
  String get armDropCampaign => 'Boss de campagne';

  @override
  String get armDropTower => 'Boss de l\'Ascension de la Tour';

  @override
  String get armDropBossRush => 'Virées Boss Rush';

  @override
  String get armDropGauntlet => 'Clôture de Gauntlet';

  @override
  String get armRate2 => '2 % par kill de boss';

  @override
  String get armRate03 => '0,3 % par kill de boss';

  @override
  String get armRateRare => 'Butin bonus rare';

  @override
  String get armDropsClassSpecific =>
      'Les butins sont spécifiques à la classe — seuls les objets de ta classe peuvent tomber.';

  @override
  String get armNoMythic => 'Pas encore d\'objet mythique';

  @override
  String get armMythicHint =>
      'Bats les boss de campagne pour 0,5 % de chance par kill.';

  @override
  String get armMythicItems => 'Objets mythiques';

  @override
  String armSlotLv(String slot, int lvl) {
    return '$slot  •  Niv$lvl';
  }

  @override
  String armKeyword(String name) {
    return 'mot-clé $name';
  }

  @override
  String get armSetItemsTitle => 'Objets de set';

  @override
  String armFraction(int a, int b) {
    return '$a / $b';
  }

  @override
  String get armEquippedLower => 'équipé';

  @override
  String get armSetBonuses => 'BONUS DE SET';

  @override
  String armPc(Object n) {
    return '$n pièces';
  }

  @override
  String get armUniqueBlurb =>
      'Les objets uniques sont liés à la classe et renforcent spectaculairement tes aptitudes. Chacun amplifie une aptitude de classe précise. Taux de drop : 2 % par kill de boss.';

  @override
  String get armMythicBlurb =>
      'Le tier généré procéduralement le plus rare. Les objets mythiques ont 3 stats aux valeurs les plus élevées possibles et un puissant effet mot-clé. Taux de drop : 0,5 % par kill de boss.';

  @override
  String get armSetBlurb =>
      'Collecte plusieurs pièces du même set pour débloquer de puissants bonus. Les sets requièrent désormais 6 pièces pour le bonus complet. Taux de drop : 0,3 % par kill de boss.';

  @override
  String armArtifactBlurb(int count) {
    return '$count sets d\'artefacts à trois pièces. Équipe 2 pièces vertes assorties sur la grille d\'artefacts pour un bonus partiel, les 3 pour le bonus complet. Les pièces de set tombent des Donjons, du Boss Rush et des boss de Campagne.';
  }

  @override
  String get armSetPieces => 'PIÈCES DE SET';

  @override
  String get armArtifactSets => 'Sets d\'artefacts';

  @override
  String armCollected(int a, int b) {
    return 'COLLECTÉES  $a / $b pièces distinctes possédées';
  }

  @override
  String endlessStage(int n) {
    return 'Étape $n';
  }

  @override
  String endlessNextReward(int n) {
    return 'Prochaine récompense : Étage $n';
  }

  @override
  String get endlessChallengeBoss => 'DÉFIER UN BOSS';

  @override
  String get endlessPremiumAutoClear =>
      '🔒  Atteignez l\'Étape 5 de la campagne pour auto-vaincre les boss';

  @override
  String get endlessRewards => 'RÉCOMPENSES : ';

  @override
  String get endlessDrop => 'BUTIN : ';

  @override
  String get endlessGold => 'OR';

  @override
  String get endlessXp => 'XP';

  @override
  String get endlessRespawns => 'RÉAPPARITIONS';

  @override
  String endlessTowerShards(String n) {
    return '+$n ÉCLATS DE TOUR';
  }

  @override
  String endlessMilestone(Object n) {
    return '★ PALIER : $n KILLS ★';
  }

  @override
  String endlessMilestoneReward(String gold, Object s) {
    return '+$gold OR  +$s ◆';
  }

  @override
  String get endlessEnemyStirs => 'L\'ennemi s\'agite de nouveau...';

  @override
  String get endlessDefeatBody =>
      'Ton héros a été submergé.\nAméliore tes stats et réessaie.';

  @override
  String get pvpNoStamina =>
      'Plus d\'endurance ! Recharge de 1 toutes les 45 minutes.';

  @override
  String get pvpTitle => 'ARÈNE JcJ';

  @override
  String get pvpSimLab => 'Labo de simulation';

  @override
  String get pvpRefresh => 'Actualiser le classement';

  @override
  String get pvpLeaderboard => 'CLASSEMENT';

  @override
  String pvpToday(String label) {
    return 'AUJOURD\'HUI : $label';
  }

  @override
  String pvpWinsToday(Object wins, Object dmg) {
    return '$wins victoires aujourd\'hui  •  $dmg dégâts totaux';
  }

  @override
  String get pvpClaimed => '✓ RÉCLAMÉ';

  @override
  String get pvpNoChallengers => 'AUCUN ADVERSAIRE POUR L\'INSTANT';

  @override
  String get pvpNoChallengersSub =>
      'Dispute un match pour rejoindre le classement\net voir où tu te situes.';

  @override
  String pvpHpAc(Object hp, Object ac) {
    return 'HP:$hp  AC:$ac';
  }

  @override
  String get pvpStamina => 'ENDURANCE  ';

  @override
  String get pvpStaminaTip =>
      'L\'endurance récupère 1 cœur toutes les 45 minutes.';

  @override
  String get pvpRating => 'COTE';

  @override
  String get pvpWins => 'VICTOIRES';

  @override
  String get pvpLosses => 'DÉFAITES';

  @override
  String get pvpWL => 'V/D';

  @override
  String pvpLeague(String name) {
    return 'LIGUE $name';
  }

  @override
  String get pvpNearRank => 'PROCHES DE TON RANG';

  @override
  String get pvpPlayersAbove => '— joueurs juste au-dessus de toi';

  @override
  String pvpClassLv(String cls, Object lvl) {
    return '$cls  Niv$lvl';
  }

  @override
  String get pvpChallenge => 'DÉFIER';

  @override
  String get pvpBattleLog => 'JOURNAL DE COMBAT';

  @override
  String get pvpBattleLogTip => 'Journal de combat';

  @override
  String get pvpNoCombat => 'Aucun combat pour l\'instant.';

  @override
  String get pvpClose => 'FERMER';

  @override
  String pvpVs(String hero, String opp) {
    return 'JcJ  —  $hero contre $opp';
  }

  @override
  String get pvpReturnArena => 'RETOUR À L\'ARÈNE';

  @override
  String get pvpFighting => 'Combat en cours...';

  @override
  String invBagCount(Object n, Object cap) {
    return '($n/$cap)';
  }

  @override
  String invBuyTab(Object cost) {
    return '+ ONGLET  $cost';
  }

  @override
  String get invAutoEquip => 'AUTO-ÉQUIPER';

  @override
  String invTabN(Object n, Object count) {
    return 'ONGLET $n  ($count)';
  }

  @override
  String get invEquipment => 'ÉQUIPEMENT';

  @override
  String invBag(Object n, Object cap) {
    return 'SAC  ($n/$cap)';
  }

  @override
  String get invUnequip => 'Déséquiper';

  @override
  String get invNoItems => 'Aucun objet dans cet onglet.';

  @override
  String invReqClass(String cls) {
    return 'Nécessite $cls';
  }

  @override
  String invReqLevel(Object lvl) {
    return 'Nécessite le niveau $lvl';
  }

  @override
  String invReqTier(Object t) {
    return 'Nécessite le Palier $t';
  }

  @override
  String get invCannotEquip => 'Impossible à équiper';

  @override
  String get invEquip => 'Équiper';

  @override
  String get invUnlock => 'Déverrouiller 🔓';

  @override
  String get invLock => 'Verrouiller 🔒';

  @override
  String get invDiscard => 'Jeter';

  @override
  String get invAny => 'Tous';

  @override
  String invUniqueOnly(String cls) {
    return '★ Unique — $cls uniquement';
  }

  @override
  String get invWrongClass => '(mauvaise classe)';

  @override
  String get invColStat => 'STAT';

  @override
  String get invColThis => 'CELUI-CI';

  @override
  String get invColEqpd => 'ÉQUIPÉ';

  @override
  String get invColDiff => 'DIFF';

  @override
  String get invEmptySocket => 'Emplacement vide';

  @override
  String get invCraftGems => 'Fabrique des gemmes dans Forge → onglet Gemmes';

  @override
  String get invRemove => 'RETIRER';

  @override
  String get invSocket => 'SERTIR';

  @override
  String invChooseGem(String name) {
    return 'Choisis une gemme à sertir dans $name';
  }

  @override
  String invOnThis(String slot, String bonus) {
    return 'Sur ce(tte) $slot : $bonus';
  }

  @override
  String get invRemoveGem => 'Retirer la gemme ?';

  @override
  String get invDestroy => 'DÉTRUIRE';

  @override
  String get invSort => 'Trier :';

  @override
  String get invFilter => 'Filtrer :';

  @override
  String invGemsAvailable(Object count) {
    return '$count gemme(s) disponible(s) à sertir';
  }

  @override
  String invRemoveBody(String name) {
    return '$name sera détruite. Les gemmes ne peuvent pas être récupérées une fois retirées.';
  }

  @override
  String invReplaceBody(String old, String gnew) {
    return '$old sera détruite et remplacée par $gnew.';
  }

  @override
  String get npcRoster => 'LISTE';

  @override
  String get npcSynergies => 'SYNERGIES';

  @override
  String get npcTitle => 'MERCENAIRES';

  @override
  String get npcTotalBonuses => 'BONUS ACTIFS TOTAUX';

  @override
  String get npcBattleParty => 'GROUPE DE COMBAT';

  @override
  String npcFielded(Object count, Object max) {
    return '$count / $max déployés';
  }

  @override
  String get npcUnknown => 'Mercenaire inconnu';

  @override
  String npcBattleAbility(String name) {
    return 'APTITUDE DE COMBAT : $name';
  }

  @override
  String npcUnlock(String label) {
    return 'Débloque : $label';
  }

  @override
  String npcProgress(Object a, Object b) {
    return '$a / $b';
  }

  @override
  String npcLvTalent(Object n) {
    return 'TALENT NIV $n';
  }

  @override
  String npcChosen(String name) {
    return 'CHOISI : $name';
  }

  @override
  String get npcMilestoneComplete => 'PALIER ATTEINT — RECRUTEMENT...';

  @override
  String get npcMax => '★ MAX';

  @override
  String get npcStarRank => 'RANG D\'ÉTOILE';

  @override
  String npcStars(Object a, Object b) {
    return '$a / $b';
  }

  @override
  String get npcFullyAscended =>
      '★ ASCENSION COMPLÈTE — chaque étoile ajoute +1 niveau effectif.';

  @override
  String npcAscendStar(Object n) {
    return 'ASCENSION ★$n';
  }

  @override
  String npcYouHave(Object n) {
    return 'Tu as : $n Mythril';
  }

  @override
  String get npcStarInfo =>
      'Chaque étoile = +1 niveau effectif du bonus de ce merc.';

  @override
  String get npcPassiveOnly => 'Bonus passifs uniquement — toujours actifs.';

  @override
  String npcCostShards(Object n) {
    return 'Coût : ◆ $n Éclats';
  }

  @override
  String get npcTutorial =>
      'Les mercenaires sont des compagnons qui te rejoignent définitivement quand tu atteins certains paliers. 🤝 Chacun fournit des bonus de combat passifs à chaque bataille et peut créer des synergies avec les autres pour plus de puissance.';

  @override
  String npcRecruited(Object a, Object b) {
    return '$a / $b  recrutés';
  }

  @override
  String get npcNoMercs =>
      'Aucun mercenaire recruté. Atteins des paliers pour les débloquer.';

  @override
  String npcChipDamage(Object n) {
    return '+$n% Dégâts';
  }

  @override
  String npcChipAc(Object n) {
    return '+$n% AC';
  }

  @override
  String npcChipShards(Object n) {
    return '+$n% Éclats';
  }

  @override
  String npcChipHp(Object n) {
    return '+$n% HP';
  }

  @override
  String get shopTabBundles => 'PACKS';

  @override
  String get shopTabVip => 'VIP';

  @override
  String get shopTabStarter => 'DÉBUTANT';

  @override
  String get shopTabResources => 'RESSOURCES';

  @override
  String get shopTabCosmetics => 'COSMÉTIQUES';

  @override
  String get shopSecBundles => 'PACKS DE ZCOINS';

  @override
  String get shopSecBundlesSub => 'Monnaie premium pour la Boutique';

  @override
  String get shopSecVip => 'ABONNEMENTS VIP';

  @override
  String get shopSecVipSub => 'Avantages et bénéfices récurrents';

  @override
  String get shopSecStarter => 'PACKS DE DÉMARRAGE';

  @override
  String get shopSecStarterSub => 'Packs à achat unique';

  @override
  String get shopSecResources => 'RESSOURCES';

  @override
  String get shopSecResourcesSub => 'Dépense des ZCoins en or & matériaux';

  @override
  String get shopSecAuras => 'AURAS';

  @override
  String get shopSecAurasSub =>
      'Équipe une lueur — les bonus d\'aura possédés se cumulent toujours';

  @override
  String get shopSecBoosts => 'BOOSTS';

  @override
  String get shopSecBoostsSub => 'Boosts de stats permanents';

  @override
  String get shopSecTitles => 'TITRES';

  @override
  String get shopSecTitlesSub => 'Un rang affiché sous ton nom';

  @override
  String get shopSecColours => 'COULEURS DE NOM';

  @override
  String get shopSecColoursSub => 'Couleur + lueur pour le nom de ton héros';

  @override
  String get shopSecFrames => 'CADRES';

  @override
  String get shopSecFramesSub => 'Un cadre autour du portrait de ton héros';

  @override
  String get shopSecSlots => 'EMPLACEMENTS DE PERSONNAGE';

  @override
  String get shopSecSlotsSub => 'Emplacements de sauvegarde supplémentaires';

  @override
  String get shopPremiumArmor => 'ARMURE DE CLASSE PREMIUM';

  @override
  String shopEndgameSkin(String cls) {
    return '$cls · Skin de fin de jeu';
  }

  @override
  String get shopIncludedBonuses => 'BONUS INCLUS';

  @override
  String get shopEverySkin => 'tous les bonus de skin de boutique, combinés';

  @override
  String get shopEquippedCheck => '✓ ÉQUIPÉ';

  @override
  String get shopUnequip => 'DÉSÉQUIPER';

  @override
  String shopUnlockPrice(String price) {
    return 'DÉBLOQUER  ·  $price';
  }

  @override
  String get shopStoreUnavailable =>
      'Boutique indisponible — réessaie plus tard.';

  @override
  String get shopVipSub => 'ABONNEMENT VIP';

  @override
  String get shopSubscribed => '✓ ABONNÉ';

  @override
  String shopSubscribe(String price) {
    return 'S\'ABONNER  $price';
  }

  @override
  String get shopEverythingPlus => 'Tout le Pacte du Vanguard, plus :';

  @override
  String get shopIncludedPerks => 'AVANTAGES INCLUS';

  @override
  String get shopGlow => '✦ LUEUR';

  @override
  String get shopExclusive => 'EXCLUSIF';

  @override
  String get shopNoAd =>
      'Aucune pub disponible pour l\'instant — réessaie plus tard.';

  @override
  String get shopWatchAd => 'Regarder une pub';

  @override
  String get shopComeBackTomorrow =>
      'Reviens demain pour plus de ZCoins gratuits !';

  @override
  String get shopWait => 'PATIENTE...';

  @override
  String get shopWatch => 'REGARDER';

  @override
  String get shopRewardEarned => 'RÉCOMPENSE OBTENUE';

  @override
  String shopPlusZcoins(Object amount) {
    return '+$amount ZCoins';
  }

  @override
  String get shopCollect => 'COLLECTER';

  @override
  String get shopPurchasesRestored =>
      'Achats restaurés. Les abonnements ou packs actifs ont été réappliqués.';

  @override
  String get shopRestorePurchases => 'Restaurer les achats';

  @override
  String artSalvageTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Recycler $count artefacts ?',
      one: 'Recycler $count artefact ?',
    );
    return '$_temp0';
  }

  @override
  String get artSalvage => 'RECYCLER';

  @override
  String artSalvaged(int n, Object gained) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n artefacts recyclés pour ◆ $gained mythril.',
      one: '$n artefact recyclé pour ◆ $gained mythril.',
    );
    return '$_temp0';
  }

  @override
  String get artTable => 'TABLE D\'ARTEFACTS';

  @override
  String artSlots(Object n, Object max) {
    return '$n/$max emplacements';
  }

  @override
  String artAutoEquipped(Object n) {
    return '$n meilleurs artefacts auto-équipés.';
  }

  @override
  String get artNoneToEquip => 'Aucun artefact à équiper.';

  @override
  String get artAutoEquip => '⚡ AUTO-ÉQUIPER';

  @override
  String get artSalvageBtn => '♻ RECYCLER';

  @override
  String get artTitle => 'ARTEFACTS';

  @override
  String get artPlaceHint =>
      'Place des artefacts sur la table pour gagner des bonus.';

  @override
  String get artTableBonuses => 'BONUS DE TABLE';

  @override
  String get artCollection => 'COLLECTION';

  @override
  String artCount(Object n) {
    return '($n)';
  }

  @override
  String artTapToPlace(String name) {
    return 'Touche une case de la grille pour placer « $name »';
  }

  @override
  String get artTapCancel => 'touche à nouveau pour annuler';

  @override
  String get artSet => 'SET';

  @override
  String artUpgradeCost(Object cost) {
    return '$cost Mythril';
  }

  @override
  String artNoSets(Object n) {
    return 'Aucune pièce de set équipée — $n sets à découvrir.';
  }

  @override
  String artCountOf3(Object count) {
    return '$count / 3';
  }

  @override
  String get artHowToGet => 'COMMENT OBTENIR DES ARTEFACTS';

  @override
  String get artRowCampaign => 'Boss de campagne';

  @override
  String get artRowCampaignDesc =>
      'environ 25 % de chance de drop à chaque kill d\'étape de boss.';

  @override
  String get artRowDungeon => 'Virées de donjon';

  @override
  String get artRowDungeonDesc =>
      'chaque boss vaincu en lâche un — jusqu\'à 2 par virée. Le meilleur farm régulier.';

  @override
  String get artRowBossRush => 'Boss Rush';

  @override
  String get artRowBossRushDesc =>
      'termine une virée au rang A ou S pour gagner un artefact.';

  @override
  String artSalvageBody(int count, Object mythril) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Détruire définitivement les $count artefacts non équipés pour ◆ $mythril mythril ? Les artefacts équipés sont conservés.',
      one:
          'Détruire définitivement $count artefact non équipé pour ◆ $mythril mythril ? Les artefacts équipés sont conservés.',
    );
    return '$_temp0';
  }

  @override
  String get artSetBlurb =>
      'Collecte des pièces de Set vertes assorties. 2 équipées = bonus partiel, les 3 = bonus complet.';

  @override
  String get art2Set => 'Set de 2';

  @override
  String get art3Set => 'Set de 3';

  @override
  String get ptEssence => 'essence';

  @override
  String ptTheClass(String cls) {
    return 'LE $cls';
  }

  @override
  String ptRespecBranch(String branch) {
    return 'Réinitialiser $branch ?';
  }

  @override
  String ptRefund(Object refund) {
    return 'Rembourse $refund essence (75 %)';
  }

  @override
  String get ptRespec => 'Réinitialiser';

  @override
  String get ptCrossBranch => 'INTER-BRANCHE';

  @override
  String get ptFullRespec => 'Réinitialisation complète ?';

  @override
  String get ptRespec50 => 'Réinit. (50 ZC)';

  @override
  String get ptFullRespecBtn => 'RÉINIT. COMPLÈTE (50 ZC)';

  @override
  String get ptTitle => 'ARBRE PASSIF';

  @override
  String get ptNow => 'ACTUEL';

  @override
  String ptUpgradeCost(Object cost) {
    return 'AMÉLIORER  ($cost ✦)';
  }

  @override
  String get ptLocked =>
      'VERROUILLÉ — dépense 25 rangs dans d\'autres branches';

  @override
  String get ptLockedMax =>
      'VERROUILLÉ — maximise d\'abord tous les nœuds de branche';

  @override
  String ptMaxRankTotal(String val) {
    return 'RANG MAX — $val au total';
  }

  @override
  String ptFullRespecBody(Object refund) {
    return 'Réinitialise TOUS les nœuds passifs.\nRembourse $refund essence (60 %).\nCoût : 50 zcoins.';
  }

  @override
  String ptNodesUnlocked(Object count) {
    return '$count nœuds débloqués';
  }

  @override
  String get ptTutorial =>
      'Tu as gagné des Éclats ◆ — dépense-les ici sur des nœuds passifs permanents qui ne se réinitialisent jamais. Ta branche de classe est en haut. Chaque nœud monte jusqu\'au rang 5 pour de plus gros bonus.';

  @override
  String ptBranchesAt25(Object count) {
    return '$count / 5 branches à 25';
  }

  @override
  String get homeExp => 'EXP';

  @override
  String get homeResources => 'Ressources';

  @override
  String get homeGold => 'OR';

  @override
  String get homeShards => 'ÉCLATS';

  @override
  String get homeZcoins => 'ZCOINS';

  @override
  String get homeMythril => 'MYTHRIL';

  @override
  String get homeIdleMin => 'INACTIF/min';

  @override
  String get homeGoldTip =>
      'Or\nGagné dans les combats et les revenus d\'inactivité.\nDépense-le dans Améliorations et la Boutique.';

  @override
  String get homeShardsTip =>
      'Éclats\nGagnés sur les kills, dans les Donjons, Expéditions et le Gauntlet.\nDépense-les sur les aptitudes, les objets et les nœuds de l\'Arbre passif.';

  @override
  String get homeZcoinsTip =>
      'ZCoins\nGagnés via les succès et les coffres quotidiens.\nDépense-les dans la Boutique d\'Auras pour skins, familiers et auras.';

  @override
  String get homeMythrilTip =>
      'Mythril\nGagné dans les Donjons, le Boss Rush et les paliers de prestige.\nDépense-le sur les artefacts, les relances d\'affixes de donjon et les bénédictions d\'autel.';

  @override
  String get homeIdleTip =>
      'Or inactif / min\nOr gagné automatiquement chaque minute hors ligne.\nAugmente avec le niveau du héros, les améliorations passives et les familiers.';

  @override
  String get homeCurrentCampaign => 'Campagne actuelle';

  @override
  String homeStage(Object n) {
    return 'ÉTAPE $n';
  }

  @override
  String homeNextGoal(Object reward) {
    return 'SUIVANT : DÉBLOQUER $reward';
  }

  @override
  String homeNextGoalProgress(Object remaining, Object stage) {
    return 'Plus que $remaining étapes — terminez l\'Étape $stage';
  }

  @override
  String get demoModeLocked =>
      'Débloqué dans le jeu complet. La démo inclut toute la campagne — obtenez le jeu complet pour les Donjons, le PvP et les paliers de difficulté de l\'endgame.';

  @override
  String get demoFullGameCta => 'OBTENIR LE JEU COMPLET';

  @override
  String get homeSecCombat => 'COMBAT';

  @override
  String get homeSecSocial => 'SOCIAL';

  @override
  String get homeNavChallengeGauntlet => 'GAUNTLET DE DÉFI';

  @override
  String get homeNavBountyBoard => 'TABLEAU DES PRIMES';

  @override
  String get homeNavSeasonPass => 'PASS SAISONNIER';

  @override
  String get homeNavWorldEvent => 'ÉVÉNEMENT MONDIAL';

  @override
  String get homeNavLeaderboard => 'CLASSEMENT';

  @override
  String get homeNavChallengeModifiers => 'MODIFICATEURS DE DÉFI';

  @override
  String get homeQuickAccess => 'ACCÈS RAPIDE';

  @override
  String get homeGettingStarted => 'POUR COMMENCER';

  @override
  String get homeStep1 => 'Gagne ton premier combat de Campagne';

  @override
  String get homeStep2 =>
      'Monte ton héros de niveau — va à la Fiche de personnage';

  @override
  String get homeStep3 =>
      'Ouvre HÉROS et achète ta première amélioration d\'Attribut';

  @override
  String get homeStep4 =>
      'Atteins l\'Étape 5 — Aptitudes et Défis quotidiens se débloquent !';

  @override
  String get homeHeroSubtitle =>
      'AMÉLIORATIONS  •  ARMURERIE  •  ALLIÉS  •  CODEX';

  @override
  String get homeTomorrow => 'Demain : ';

  @override
  String get dailyWeekly => 'HEBDO';

  @override
  String get dailyClaimAll => 'TOUT RÉCLAMER';

  @override
  String get dailyHowItWorks => 'Comment ça marche';

  @override
  String get dailyThisWeek => 'DÉFIS DE LA SEMAINE';

  @override
  String dailyCompleted(Object claimed, Object total) {
    return '$claimed / $total terminés';
  }

  @override
  String get dailyWeeklyLoading => 'Chargement des défis hebdomadaires...';

  @override
  String get dailyAboutWeekly => 'À propos des défis hebdomadaires';

  @override
  String get dailyReady => 'PRÊT';

  @override
  String get dailyTodayProgress => 'PROGRESSION DU JOUR';

  @override
  String get dailyChest => 'COFFRE QUOTIDIEN';

  @override
  String get dailyClaimedTomorrow => 'Réclamé ! Reviens demain.';

  @override
  String get dailyHintKill => 'Tuer des ennemis';

  @override
  String get dailyHintKillD => 'Combats en mode Campagne ou Infini';

  @override
  String get dailyHintWin => 'Gagner des combats';

  @override
  String get dailyHintWinD => 'Vaincre un ennemi compte comme une victoire';

  @override
  String get dailyHintBoss => 'Vaincre un boss';

  @override
  String get dailyHintBossD =>
      'Étape 5, 10, 15, 20, 25 ou tous les 5 en Infini';

  @override
  String get dailyHintAbility => 'Utiliser des aptitudes';

  @override
  String get dailyHintAbilityD =>
      'Les aptitudes actives se déclenchent automatiquement en combat';

  @override
  String get dailyHintEquip => 'Équiper un objet';

  @override
  String get dailyHintEquipD =>
      'Touche un objet du sac → Équiper dans l\'Inventaire';

  @override
  String get dailyHintGold => 'Atteindre un montant d\'or';

  @override
  String get dailyHintGoldD =>
      'Aie simplement cette quantité d\'or dans ta réserve';

  @override
  String get dailyHintDamage => 'Infliger des dégâts';

  @override
  String get dailyHintDamageD =>
      'Dégâts cumulés infligés dans n\'importe quel mode';

  @override
  String get dailyHintIdle => 'Collecter l\'inactif';

  @override
  String get dailyHintIdleD =>
      'Touche la récompense d\'inactivité sur l\'écran d\'accueil';

  @override
  String get dailyHintResets => 'Réinitialisation';

  @override
  String get dailyHintResetsD => 'Chaque lundi — 5 nouveaux défis par semaine';

  @override
  String get dailyHintRewards => 'Récompenses';

  @override
  String get dailyHintRewardsD =>
      'Plus grosses que les quotidiennes : essence, mythril, ZCoins';

  @override
  String get dailyHintSeasonXp => 'XP de saison';

  @override
  String get dailyHintSeasonXpD => '+50 XP de saison par défi hebdo réclamé';

  @override
  String get dailyHintProgress => 'Progression';

  @override
  String get dailyHintProgressD =>
      'Compte depuis lundi minuit, pas depuis la réclamation';

  @override
  String get dailyTutorial =>
      'Termine les défis quotidiens pour gagner or, éclats, essence et ZCoins. Les 7 défis se réinitialisent chaque jour. Termine-les tous pour un coffre bonus !';

  @override
  String petOwned(Object a, Object b) {
    return '$a / $b  possédés';
  }

  @override
  String get petTitle => 'COMPAGNONS';

  @override
  String get petActiveBonuses => 'BONUS ACTIFS (tous les familiers possédés)';

  @override
  String get petNoCompanion => 'Aucun compagnon équipé';

  @override
  String get petEquipHint =>
      'Équipe un familier pour qu\'il apparaisse en combat.';

  @override
  String get petPremium => '★ PREMIUM';

  @override
  String get petInBattle => 'EN COMBAT';

  @override
  String petRecruitTitle(String name) {
    return 'Recruter $name ?';
  }

  @override
  String get petRecruit => 'RECRUTER';

  @override
  String petEvolveTitle(String name) {
    return 'Faire évoluer $name ?';
  }

  @override
  String petEvolveN(Object n) {
    return 'ÉVOLUER  Évo $n';
  }

  @override
  String get petTutorial =>
      'Les familiers te rejoignent en combat et cumulent leurs bonus passivement — même ceux non équipés. Équipes-en un pour qu\'il apparaisse à tes côtés durant les combats. Fais évoluer deux fois les familiers possédés pour doubler la valeur de leur bonus.';

  @override
  String petRecruitBody(String desc, String bonus, Object cost) {
    return '$desc\n\nBonus : $bonus\n\nCoût : $cost ZCoins';
  }

  @override
  String petEvolveBody(Object level, String bonus, Object cost) {
    return 'Améliorer vers l\'Évolution $level.\n\nNouveau bonus : +$bonus\nCoût : $cost ZCoins';
  }

  @override
  String get questTitle => 'SÉRIES DE QUÊTES';

  @override
  String get questAdventure => 'SÉRIE DE QUÊTES D\'AVENTURE';

  @override
  String get questAdventureSub =>
      'Apprends chaque système de jeu sur la route de l\'étape 100.';

  @override
  String questUnlocksLv30(Object lvl) {
    return 'Se débloque au niveau 30  (actuel : $lvl)';
  }

  @override
  String get questUltUnlocked => 'APTITUDE ULTIME DÉBLOQUÉE';

  @override
  String questUltAvailable(String cls) {
    return 'L\'ultime du $cls est maintenant disponible en combat.';
  }

  @override
  String get questProgressLabel => 'Progression';

  @override
  String questCompleteFirst(Object n) {
    return 'Termine d\'abord la quête $n pour débloquer.';
  }

  @override
  String get questClaimReward => 'RÉCLAMER LA RÉCOMPENSE';

  @override
  String get questRewardLabel => 'Récompense : ';

  @override
  String questClassQuestline(String cls) {
    return 'SÉRIE DE QUÊTES $cls';
  }

  @override
  String get questComplete5 =>
      'Termine 5 quêtes pour débloquer l\'Aptitude Ultime.';

  @override
  String get subTitle => 'SPÉCIALISATION';

  @override
  String get subLevel50 => 'SPÉCIALISATION NIVEAU 50';

  @override
  String subChooseBody(String cls, Object cost) {
    return 'Choisis une spécialisation pour ton $cls. Elle accorde un puissant bonus de pierre angulaire plus des bonus de stats, appliqués immédiatement. Tu peux la changer plus tard pour $cost ZCoins.';
  }

  @override
  String subClassSpecs(String cls, Object n) {
    return 'SPÉCIALISATIONS $cls  ($n)';
  }

  @override
  String subUnlocksAt(Object lvl) {
    return 'La spécialisation se débloque au niveau $lvl.';
  }

  @override
  String subChooseTitle(String name) {
    return 'Choisir $name ?';
  }

  @override
  String get subStatBonuses => 'BONUS DE STATS';

  @override
  String get subCapstone => 'BONUS DE PIERRE ANGULAIRE';

  @override
  String get subSpecialEffect => 'EFFET SPÉCIAL';

  @override
  String subChangeLater(Object cost) {
    return 'Tu peux changer ceci plus tard pour $cost ZCoins.';
  }

  @override
  String get subCouldNotSet =>
      'Impossible de définir la spécialisation — réessaie.';

  @override
  String subChangeSpec(Object cost) {
    return 'CHANGER DE SPÉCIALISATION  —  $cost ZCoins';
  }

  @override
  String get subChangeTitle => 'Changer de spécialisation ?';

  @override
  String subChangeBody(Object cost, Object zcoins) {
    return 'Dépenser $cost ZCoins pour effacer ta spécialisation actuelle et en choisir une nouvelle ?\n\nTes ZCoins : $zcoins';
  }

  @override
  String get subNotEnough => 'Pas assez de ZCoins pour réinitialiser.';

  @override
  String get subActiveSubclass => 'SOUS-CLASSE ACTIVE';

  @override
  String get subChosen => 'CHOISIE';

  @override
  String get subActive => 'ACTIVE';

  @override
  String get subChoosePath => 'CHOISIR CETTE VOIE';

  @override
  String get expTitle => 'EXPÉDITIONS';

  @override
  String get expCollectAll => 'TOUT COLLECTER';

  @override
  String get expDispatchAll => 'TOUT ENVOYER';

  @override
  String get expNoMercs => 'Pas encore de mercenaires';

  @override
  String get expNoMercsSub =>
      'Recrute des mercenaires depuis l\'onglet MERCENAIRES du Hub du héros pour les envoyer en expédition.';

  @override
  String get expTodayLocations => 'LIEUX DU JOUR';

  @override
  String expRefreshIn(String time) {
    return '🔄 $time';
  }

  @override
  String get expYourParty => 'TON GROUPE';

  @override
  String get expDispatch => 'ENVOYER';

  @override
  String get expDone => 'TERMINÉ';

  @override
  String get expCollectRewards => 'COLLECTER LES RÉCOMPENSES';

  @override
  String get expInProgress => 'EN COURS...';

  @override
  String expReturned(String name) {
    return '$name est de retour !';
  }

  @override
  String get expDiscovery => '✦  DÉCOUVERTE';

  @override
  String get expGreat => 'SUPER';

  @override
  String expDispatchMerc(String name) {
    return 'ENVOYER $name';
  }

  @override
  String get expChooseLocation => 'CHOISIR UN LIEU';

  @override
  String get expDuration => 'DURÉE';

  @override
  String get expEstRewards => 'RÉCOMPENSES ESTIMÉES';

  @override
  String get expSend => 'ENVOYER EN EXPÉDITION';

  @override
  String get acctSignInFailed => 'Connexion annulée ou échouée.';

  @override
  String get acctSignOutTitle => 'Se déconnecter ?';

  @override
  String get acctSignOut => 'Se déconnecter';

  @override
  String get acctSignOutBody =>
      'Ta sauvegarde locale est conservée. La synchro cloud sera en pause jusqu\'à ta reconnexion.';

  @override
  String get acctDeleteTitle => 'Supprimer le compte & les données ?';

  @override
  String get acctDeleteAll => 'TOUT SUPPRIMER';

  @override
  String get acctDeleteBody =>
      'Cela supprime définitivement ton compte et TOUTES les données — chaque personnage, ta sauvegarde cloud, ton classement JcJ et tes entrées de classement. Irréversible.';

  @override
  String get acctDeleted => 'Compte supprimé';

  @override
  String get acctDeletedBody =>
      'Ton compte et toutes les données ont été supprimés. L\'appli va se fermer.';

  @override
  String get acctClose => 'Fermer';

  @override
  String get acctPlayer => 'Joueur';

  @override
  String get acctSyncNow => 'SYNCHRONISER';

  @override
  String get acctSignOutBtn => 'SE DÉCONNECTER';

  @override
  String get acctSignInGoogle => 'SE CONNECTER AVEC GOOGLE';

  @override
  String get acctDeleteAccount => 'SUPPRIMER LE COMPTE';

  @override
  String get acctDangerSub =>
      'Supprime définitivement ton compte et toutes les données associées.';

  @override
  String get acctLinked => 'Compte Google lié';

  @override
  String get acctNotSynced => 'Pas encore synchronisé cette session';

  @override
  String get acctNoAccount => 'Aucun compte lié';

  @override
  String get acctAboutCloud => 'À PROPOS DES SAUVEGARDES CLOUD';

  @override
  String get acctCloud1 =>
      'Ta progression se synchronise automatiquement toutes les 5 minutes une fois connecté.';

  @override
  String get acctCloud2 =>
      'Joue sur n\'importe quel appareil Windows avec le même compte Google.';

  @override
  String get acctCloud3 =>
      'Les sauvegardes cloud sont stockées en sécurité avec ton compte Google.';

  @override
  String get invhTabGear => 'ÉQUIPEMENT';

  @override
  String get invhTabGems => 'GEMMES';

  @override
  String get invhTabRunes => 'RUNES';

  @override
  String get invhArcaneDust => 'Poussière arcanique';

  @override
  String invhBag(Object n, Object max) {
    return 'Sac : $n/$max';
  }

  @override
  String get invhCraftGem => 'FABRIQUER UNE GEMME';

  @override
  String invhCraftTypeGem(String type, Object cost) {
    return 'FABRIQUER GEMME $type  ($cost Poussière arcanique)';
  }

  @override
  String get invhOwnedGems => 'GEMMES POSSÉDÉES';

  @override
  String invhDismantleBody(String bonus, Object dust) {
    return '$bonus\n\nSertis dans une ARME pour +DMG%, ou une ARMURE pour +RÉS% de l\'élément de cette gemme.\n\nDémanteler rend $dust Poussière arcanique.';
  }

  @override
  String invhDismantle(Object dust) {
    return 'DÉMANTELER (+$dust Poussière arcanique)';
  }

  @override
  String invhGemTooltip(String name, String bonus) {
    return '$name\n$bonus\nTouche pour démanteler';
  }

  @override
  String get invhTutGear =>
      'Ton premier équipement est tombé ! Équipe-le ici pour augmenter tes stats.';

  @override
  String get invhTutForge =>
      'Combine deux objets du même emplacement pour fabriquer une pièce de rareté supérieure, ou reforge les stats.';

  @override
  String get invhTutRunes =>
      'Fabrique des Runes pour des buffs de combat temporaires. Récupère de la poussière en recyclant l\'équipement.';

  @override
  String get invhTutArtifacts =>
      'Place des artefacts dans la grille pour des bonus passifs permanents.';

  @override
  String get invhNoGear =>
      'Pas encore d\'équipement.\nBats des ennemis pour trouver ton premier objet !';

  @override
  String get ascTitle => 'ASCENSION';

  @override
  String get ascMetaBoard => 'MÉTA-TABLEAU';

  @override
  String ascApPoints(Object points) {
    return '$points PA';
  }

  @override
  String get ascLevelLabel => 'Niveau d\'Ascension : ';

  @override
  String get ascPrestigeLabel => 'Niveau de Prestige : ';

  @override
  String get ascBody =>
      'L\'Ascension est la réinitialisation la plus profonde — elle convertit tes Renaissances en Points d\'Ascension (PA). Tu gagnes 1 PA par Renaissance sacrifiée, donc plus tu en accumules avant d\'ascensionner, plus le gain est grand.\n\nDépense les PA de deux façons — toutes deux permanentes et conservées à chaque réinitialisation future :\n• Le Méta-Tableau ci-dessous (XP, or, dégâts, bonus d\'inactivité & de prestige)\n• Ascensionne tes aptitudes de classe sur l\'écran Aptitudes (+10% de puissance par tier, jusqu\'à 60 PA par personnage)\n\nTu CONSERVES :  les bonus d\'Ascension & PA dépensés, les Artefacts, le Mythril, les Éclats de Tour, la Maîtrise élémentaire.\nTu PERDS :  toutes les Renaissances, le niveau du héros, l\'or, l\'équipement, la sous-classe, les rangs d\'aptitude et la progression de campagne.';

  @override
  String ascRequires(Object prestige) {
    return 'Nécessite le Niveau de Prestige 5 pour ascensionner  (actuel : $prestige/5)';
  }

  @override
  String ascAscendAp(Object ap) {
    return 'ASCENSIONNER  (+$ap PA)';
  }

  @override
  String get ascConfirmTitle => 'Ascensionner ?';

  @override
  String ascConfirmBody(Object rebirths, Object ap) {
    return 'Sacrifier $rebirths Renaissance(s) pour $ap Point(s) d\'Ascension.\n\nCONSERVE : bonus d\'Ascension, Artefacts, Mythril, Éclats de Tour, Ascensions d\'aptitude.\nPERD : toutes les Renaissances, le niveau du héros, l\'or, l\'équipement, la sous-classe, les rangs d\'aptitude, la progression de campagne.\n\nIrréversible.';
  }

  @override
  String get weOmegaShop => 'BOUTIQUE OMÉGA';

  @override
  String get weNowHunting => 'CHASSE EN COURS';

  @override
  String get weDamageLabel => 'Dégâts : ';

  @override
  String weEndsIn(Object d, Object h, Object m) {
    return 'L\'événement finit dans  ${d}j ${h}h ${m}m';
  }

  @override
  String get weHowToEarn => 'COMMENT GAGNER DES JETONS';

  @override
  String weHowToEarnDesc(String name) {
    return 'Les $name ont 15 % de chance d\'apparaître durant n\'importe quel combat. Bats-les pour 1 à 3 Jetons d\'événement chacun.';
  }

  @override
  String get weEventBoss => '⚔ BOSS D\'ÉVÉNEMENT';

  @override
  String get weClaimLegendary =>
      'RÉCLAMER ÉQUIPEMENT LÉGENDAIRE  (1 🏆 Jeton de Boss)';

  @override
  String weGearForged(String name, Object lv) {
    return '$name forgé au Niv$lv ! Vérifie ton sac.';
  }

  @override
  String weRewardClaimed(String name) {
    return '$name réclamé !';
  }

  @override
  String get gauLeaderboard => 'Classement du Gauntlet';

  @override
  String get gauRewardPreview => 'APERÇU DES RÉCOMPENSES (à la clôture)';

  @override
  String get gauAutoRestart => 'AUTO — redémarrage avec tes modificateurs—';

  @override
  String get gauBackToGauntlet => 'RETOUR AU GAUNTLET';

  @override
  String gauWave(Object n, Object total) {
    return 'VAGUE $n / $total';
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
  String get brLeaderboard => 'Classement du Boss Rush';

  @override
  String get brBestScore => 'MEILLEUR SCORE : ';

  @override
  String brBossProgress(Object n, Object total) {
    return 'BOSS $n / $total';
  }

  @override
  String get brPlayAgain => 'REJOUER';

  @override
  String get brPossibleRewards => 'RÉCOMPENSES POSSIBLES';

  @override
  String get brRewShards => 'Éclats';

  @override
  String get brRewShardsD => '10 par boss  ·  +30 à la clôture complète';

  @override
  String get brRewEchoes => 'Échos';

  @override
  String get brRewEchoesD => '6 par boss  ·  +25 à la clôture complète';

  @override
  String get brRewZcoins => 'ZCoins';

  @override
  String get brRewZcoinsD => '15 à la clôture complète';

  @override
  String get brRewMythril => 'Mythril';

  @override
  String get brRewMythrilD => 'Proportionnel au rang final';

  @override
  String get brRewArtifact => 'Artefact';

  @override
  String get brRewArtifactD => 'Drop possible aux clôtures de rang A / S';

  @override
  String get prgShop => 'BOUTIQUE PARANGON';

  @override
  String get prgActiveBonuses => 'BONUS ACTIFS';

  @override
  String get prgBoard => '✦ TABLEAU PARANGON';

  @override
  String get prgBoardHint =>
      'Investis des points dans une direction — les rangs montent à l\'infini.';

  @override
  String prgRank(Object rank) {
    return 'Rang $rank';
  }

  @override
  String get prgTutorial =>
      '✦ Les Points de Parangon se gagnent en montant de niveau — 1 par niveau. Dépense-les sur le Tableau et la Boutique Parangon ci-dessous pour une puissance permanente qui ne se réinitialise jamais.';

  @override
  String get prgShopSub =>
      'Dépense des Points de Parangon sur des améliorations permanentes qui persistent à travers toutes les virées futures.';

  @override
  String achClaimedTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🏆  $count SUCCÈS RÉCLAMÉS',
      one: '🏆  $count SUCCÈS RÉCLAMÉ',
    );
    return '$_temp0';
  }

  @override
  String get achYouReceived => 'Tu as reçu :';

  @override
  String get achNice => 'BIEN JOUÉ !';

  @override
  String achClaimAll(Object n) {
    return 'TOUT RÉCLAMER ($n)';
  }

  @override
  String get achEconomy => 'ÉCONOMIE & SYSTÈMES';

  @override
  String get achProgress => 'PROGRESSION';

  @override
  String achClaimed(Object claimed, Object total) {
    return '$claimed / $total réclamés';
  }

  @override
  String achReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count succès prêts à réclamer !',
      one: '$count succès prêt à réclamer !',
    );
    return '$_temp0';
  }

  @override
  String get runeTitle => 'RUNES D\'APTITUDE';

  @override
  String get runeArcaneDust => '🌀 Poussière arcanique : ';

  @override
  String runeOwned(Object a, Object b) {
    return '📜 Possédées : $a/$b';
  }

  @override
  String get runeNone => 'Aucune rune disponible pour cette classe.';

  @override
  String get runeAppBar => 'RUNES';

  @override
  String get runeSocketed => 'SERTIE';

  @override
  String get runeNotFound =>
      'Pas encore trouvée — tombe des boss, donjons, gauntlet et expéditions.';

  @override
  String get runeEquipFirst =>
      'Équipe un anneau ou une amulette pour sertir cette rune.';

  @override
  String runeSocketInto(String name, Object cost) {
    return 'Sertir → $name  (🌀 $cost)';
  }

  @override
  String get runeBody =>
      'Sertis des runes pour renforcer définitivement tes aptitudes.\nChaque rune modifie une aptitude précise — augmentant dégâts, durée ou recharge.\nCoûte de la Poussière arcanique issue du désenchantement d\'équipement, de gemmes et de runes.';

  @override
  String get achTutorial =>
      'Tu as vaincu ton premier boss ! 🏆 Les succès suivent les paliers et récompensent ZCoins et Éclats — réclame-les ici et reviens souvent.';

  @override
  String get bbLocked => 'PRIMES DE BOSS VERROUILLÉES';

  @override
  String get bbLockedSub =>
      'Atteins l\'étape 20 de la campagne pour commencer à chasser les boss contre des primes.';

  @override
  String bbTitle(Object t) {
    return 'PRIMES DE BOSS  •  PALIER $t';
  }

  @override
  String get bbDesc =>
      'Terrasse chaque boss de campagne pour sa prime. Atteins un nouveau palier pour un lot inédit aux récompenses plus grosses.';

  @override
  String get bbNoBounties => 'Aucune prime disponible.';

  @override
  String bbStageLv(Object n, Object lv) {
    return 'Étape de campagne $n  •  Niv $lv';
  }

  @override
  String bbSlain(String name, String detail) {
    return '$name terrassé !  $detail';
  }

  @override
  String bbStage(Object n) {
    return 'Étape $n';
  }

  @override
  String bbGearReward(String rarity) {
    return '🎁 Équipement $rarity';
  }

  @override
  String bestTotalKills(Object n) {
    return '$n kills au total';
  }

  @override
  String get bestTypeMaxed => 'TYPE MAXÉ';

  @override
  String bestGoldBonus(Object pct) {
    return '+$pct% or';
  }

  @override
  String get bestKilled => 'tués';

  @override
  String bestNextDmg(Object n) {
    return 'prochain +1% dégâts à $n kills';
  }

  @override
  String get lsTitle => 'CONNEXION QUOTIDIENNE';

  @override
  String get lsComeBack => 'Reviens demain pour ta prochaine récompense !';

  @override
  String lsStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '$count jour',
    );
    return '$_temp0';
  }

  @override
  String lsClaimReward(String label) {
    return 'RÉCLAMER  $label';
  }

  @override
  String get lsFullCycle => 'CYCLE COMPLET DE 30 JOURS';

  @override
  String lsDay(Object d) {
    return 'Jour $d';
  }

  @override
  String get lsToday => 'AUJOURD\'HUI';

  @override
  String get dashTitle => 'FICHE DE PERSONNAGE';

  @override
  String get dashDailyReady => 'Défi quotidien prêt à réclamer !';

  @override
  String get dashAbilityAfford =>
      'Amélioration d\'aptitude abordable — va dans APTITUDES';

  @override
  String get dashPassiveAfford =>
      'Amélioration passive abordable — va dans PASSIFS';

  @override
  String get dashEndlessAfford =>
      'Amélioration infinie abordable — va dans AMÉLIORATIONS';

  @override
  String get dashNextAction => 'PROCHAINE ACTION';

  @override
  String get dashIncomeSummary => 'RÉSUMÉ DES REVENUS';

  @override
  String get dashIdleGold => 'Or inactif';

  @override
  String get dashBattleKill => 'Combat/kill';

  @override
  String get dashExpeditions => 'Expéditions';

  @override
  String get dashAchievementsNearby => 'SUCCÈS PROCHES';

  @override
  String dashDayLoginReward(Object day) {
    return 'RÉCOMPENSE DE CONNEXION JOUR $day';
  }

  @override
  String dashExpReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expéditions prêtes à collecter !',
      one: '$count expédition prête à collecter !',
    );
    return '$_temp0';
  }

  @override
  String dashMercsIdle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mercs inactifs — envoie-les en expédition',
      one: '$count merc inactif — envoie-le en expédition',
    );
    return '$_temp0';
  }

  @override
  String get emTitle => 'MAÎTRISE ÉLÉMENTAIRE';

  @override
  String emShards(Object n) {
    return '$n Éclats';
  }

  @override
  String get emUp => 'HAUT';

  @override
  String get spResetsMonthly => '📅 Réinitialisation mensuelle';

  @override
  String get spUnlockPremium =>
      'Débloque le Pass Premium — 2× XP + piste premium';

  @override
  String get spFree => 'GRATUIT';

  @override
  String get spPremium => '👑 PREMIUM';

  @override
  String get spTier => 'Palier';

  @override
  String spClaimed(Object reward) {
    return '$reward réclamé';
  }

  @override
  String get spAllUnlocked => 'Tous les paliers débloqués — beau travail !';

  @override
  String spXpToTier(Object xp, Object next, Object tier) {
    return '$xp / $next XP pour le Palier $tier';
  }

  @override
  String spClaimedN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n récompenses réclamées',
      one: '1 récompense réclamée',
    );
    return '$_temp0';
  }

  @override
  String get spNothingToClaim => 'Rien à réclamer';

  @override
  String get euEchoes => 'Échos';

  @override
  String get euYourBalance => 'Ton solde';

  @override
  String get euEchoesCap => 'ÉCHOS';

  @override
  String get euTutorial =>
      'Les virées de Gauntlet rapportent des Échos 🔊 — dépense-les ici sur des améliorations de combat permanentes qui ne se réinitialisent jamais. Ce sont parmi les bonus les plus puissants du jeu.';

  @override
  String get euPermanent =>
      'Les améliorations sont permanentes par personnage. Les bonus s\'appliquent dans tous les modes de jeu.';

  @override
  String euForLv(Object n) {
    return 'pour Niv $n';
  }

  @override
  String get euActive => 'ACTIF';

  @override
  String get lbRefresh => 'Actualiser';

  @override
  String get lbNoScores => 'Aucun score pour l\'instant — sois le premier !';

  @override
  String get lbPersonalBest => 'Ton record personnel';

  @override
  String get lbRank => 'RANG';

  @override
  String get lbYou => 'TOI';

  @override
  String get lbError => 'Impossible de charger le classement.';

  @override
  String get lbNotRanked => 'Pas encore classé';

  @override
  String get cmTitle => 'MODIFICATEURS DE DÉFI';

  @override
  String get cmOptionalHandicaps => 'HANDICAPS OPTIONNELS';

  @override
  String get cmActive => 'Actif : ';

  @override
  String get cmClear => 'EFFACER';

  @override
  String get cmDesc =>
      'Active jusqu\'à un modificateur avant d\'entrer en Campagne ou au Donjon. Les modificateurs rendent les combats plus durs mais augmentent les récompenses d\'éclats par kill.';

  @override
  String cmEssence(Object pct) {
    return '+$pct% essence';
  }

  @override
  String cmEnemyHp(Object mult) {
    return 'HP ennemi ×$mult';
  }

  @override
  String cmEnemyAtk(Object mult) {
    return 'ATK ennemi ×$mult';
  }

  @override
  String cmHeroHp(Object mult) {
    return 'HP héros ×$mult';
  }

  @override
  String get wClose => 'FERMER';

  @override
  String get battleLog => 'JOURNAL DE COMBAT';

  @override
  String get buffDodge => 'ESQUIVE';

  @override
  String get buffStun => 'ÉTOURDI';

  @override
  String get dhPowerTip =>
      'Puissance médiévale — score combiné de toutes tes améliorations,\néquipement, passifs, prestige, artefacts et alliés.';

  @override
  String dhHpTip(Object regen) {
    return 'Points de vie — atteins 0 et tu perds le combat.\nRégén : $regen HP/tour';
  }

  @override
  String dhXpTip(Object xp, Object lv, Object next) {
    return 'Expérience — atteins $xp pour monter de niveau.\nNiveau $lv → $next';
  }

  @override
  String get dhNice => 'BIEN';

  @override
  String get bspAbilities => 'APTITUDES';

  @override
  String get bspMercs => 'MERCS';

  @override
  String get bspEnemyStun => 'ÉTOURDIR ennemi';

  @override
  String get bspPassive => 'PASSIF';

  @override
  String bspDescAtk(Object pct) {
    return 'Ton héros inflige +$pct% de dégâts par coup.';
  }

  @override
  String bspDescArmor(Object pct) {
    return '+$pct% de Classe d\'armure — réduit les dégâts ennemis entrants.';
  }

  @override
  String get bspDescDodge =>
      'Ton héros esquivera complètement la prochaine attaque ennemie.';

  @override
  String bspDescAura(Object hp) {
    return 'Aura de soin — restaure $hp HP au début de chaque tour.';
  }

  @override
  String bspDescDot(Object dmg) {
    return 'Dégâts sur la durée — l\'ennemi subit $dmg dégâts chaque tour.';
  }

  @override
  String get bspDescStun => 'L\'ennemi est étourdi et saute son attaque.';

  @override
  String get baMercAbility => 'APTITUDE DE MERC';

  @override
  String get tsCleared => 'TERMINÉ';

  @override
  String get sgFullyUpgraded => 'ENTIÈREMENT AMÉLIORÉ';

  @override
  String sgNeedGold(Object cost) {
    return 'Il faut $cost or pour améliorer';
  }

  @override
  String get fsVictory => 'VICTOIRE';

  @override
  String get fsDefeat => 'DÉFAITE';

  @override
  String fsVs(String enemy, Object rounds) {
    return 'contre $enemy  ·  $rounds tours';
  }

  @override
  String get fsAbilitiesUsed => 'APTITUDES UTILISÉES';

  @override
  String get wnTitle => 'NOUVEAUTÉS';

  @override
  String get wnLatest => 'DERNIER';

  @override
  String get zcShards => 'Éclats';

  @override
  String get idbNoItem => 'Aucun objet équipé — amélioration directe !';

  @override
  String get absTitle => 'ATTRIBUTS';

  @override
  String get absBanner =>
      'Les Attributs sont des améliorations permanentes achetées avec de l\'or.\nAméliore n\'importe quel attribut librement — l\'or est la seule condition.';

  @override
  String get absMaxed => 'MAX';

  @override
  String absNext(Object cost) {
    return 'Suivant : $cost or';
  }

  @override
  String absRankOf(Object rank, Object max) {
    return 'Rang $rank / $max';
  }

  @override
  String get bestUndiscovered => 'Tue cette créature pour révéler ses secrets.';

  @override
  String shopAdOffer(Object n, Object left, Object max) {
    return 'Gagne $n ZCoins par pub  •  $left/$max restantes';
  }

  @override
  String get shopLifetimeTitle => 'Pacte Éternel';

  @override
  String get shopLifetimeTagline =>
      'Un achat. Tous les avantages Premium. Pour toujours.';

  @override
  String get shopLifetimeBadge => 'MEILLEURE OFFRE';

  @override
  String get shopLifetimeOwned => '✓ DÉBLOQUÉ À VIE';

  @override
  String shopLifetimeBuy(Object price) {
    return 'DÉBLOQUER À VIE  ·  $price';
  }

  @override
  String get shopLifetimeIncludes => 'TOUT INCLUS';

  @override
  String get shopLifetimePerk1 =>
      'Tous les avantages de la Couronne Ascendante';

  @override
  String get shopLifetimePerk2 => '3× vitesse de combat';

  @override
  String get shopLifetimePerk3 => 'Campagne automatique';

  @override
  String get shopLifetimePerk4 => '+50% d\'or inactif';

  @override
  String get shopLifetimePerk5 => '2× XP passe de saison';

  @override
  String get shopLifetimePerk6 => 'Récompenses Premium du passe de saison';

  @override
  String get shopLifetimePerk7 => 'Accès au simulateur de combat';

  @override
  String get shopLifetimePerk8 => 'Aucun abonnement récurrent — jamais';

  @override
  String get ratingTitle => 'Vous aimez Zeta Idle ?';

  @override
  String get ratingBody =>
      'Vous jouez depuis un moment ! Si vous vous amusez, une petite note aide énormément le jeu à grandir. 🙏';

  @override
  String get ratingLove => 'J\'adore !';

  @override
  String get ratingMeh => 'Pas vraiment';

  @override
  String get saveHeroTitle => 'Sauvegardez votre héros';

  @override
  String get saveHeroBody =>
      'Connectez-vous avec Google pour sauvegarder votre progression dans le cloud. Gardez votre héros en sécurité et retrouvez-le sur tous vos appareils — gratuit, en un instant.';

  @override
  String get saveHeroLater => 'Plus tard';

  @override
  String get saveHeroConfirm => 'Sauvegarder mon héros';

  @override
  String get saveHeroSynced => 'Progression sauvegardée dans le cloud.';

  @override
  String get saveHeroFailed => 'Connexion non aboutie.';

  @override
  String get firstStepsTitle => 'PREMIERS PAS';

  @override
  String get firstStepsSubtitle =>
      'Terminez-les pour apprendre les bases et décrocher un Coffre Rare.';

  @override
  String get firstStepsWinBattle => 'Gagnez votre premier combat';

  @override
  String get firstStepsReachStage3 => 'Atteignez le Niveau 3';

  @override
  String get firstStepsFirstBoss => 'Battez votre premier boss';

  @override
  String get firstStepsReachStage10 => 'Atteignez le Niveau 10';

  @override
  String get firstStepsCapstone => 'Récupérez votre Coffre Rare';

  @override
  String get firstStepsClaim => 'RÉCUPÉRER';

  @override
  String get firstStepsClaimed => 'Récupéré';

  @override
  String get firstStepsInProgress => 'En cours';

  @override
  String get firstStepsLocked => 'Verrouillé';
}
