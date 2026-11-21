// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get ccForgeYourLegend => 'FORJE SUA LENDA';

  @override
  String get ccNameYourWarrior => '— NOMEIE SEU GUERREIRO —';

  @override
  String get ccDefaultHeroName => 'O Guardião';

  @override
  String get ccQuickStart => 'INÍCIO RÁPIDO';

  @override
  String get ccQuickStartHint => 'Entre direto com um herói recomendado';

  @override
  String get ccChooseClassAndRace => 'ESCOLHER CLASSE E RAÇA';

  @override
  String get ccChooseYourClass => 'ESCOLHA SUA CLASSE';

  @override
  String get ccSelectYourPath => '— SELECIONE SEU CAMINHO —';

  @override
  String get ccChooseRace => 'ESCOLHER RAÇA';

  @override
  String get ccSelectAClass => 'SELECIONAR CLASSE';

  @override
  String get ccRecommendedForBeginners => '★ RECOMENDADO PARA INICIANTES';

  @override
  String get ccComplexity => 'COMPLEXIDADE';

  @override
  String get ccChooseYourRace => 'ESCOLHA SUA RAÇA';

  @override
  String get ccHeritageDefinesYou => '— SUA HERANÇA TE DEFINE —';

  @override
  String get ccBeginYourJourney => 'INICIAR SUA JORNADA';

  @override
  String get ccSelectARace => 'SELECIONAR RAÇA';

  @override
  String get ccNameNotAllowed =>
      'Por favor, escolha outro nome — esse não é permitido.';

  @override
  String get csSelectCharacter => '— SELECIONAR PERSONAGEM —';

  @override
  String get csNewCharacter => 'NOVO PERSONAGEM';

  @override
  String get csSwipeToDelete =>
      'Deslize um personagem para a esquerda para deletar';

  @override
  String csDeleteTitle(String name) {
    return 'Deletar \"$name\"?';
  }

  @override
  String get csDeleteBody =>
      'Tem certeza? Uma vez deletado, não pode ser recuperado.';

  @override
  String get csCancel => 'CANCELAR';

  @override
  String get csDelete => 'DELETAR';

  @override
  String get csLockedSlot => 'SLOT BLOQUEADO';

  @override
  String get navHero => 'HERÓI';

  @override
  String get navPlay => 'JOGAR';

  @override
  String get navInventory => 'INVENTÁRIO';

  @override
  String get navShop => 'LOJA';

  @override
  String get navGuild => 'GUILDA';

  @override
  String get modeCampaign => 'CAMPANHA';

  @override
  String get modeDungeon => 'MASMORRA';

  @override
  String get modeBossRush => 'BOSS RUSH';

  @override
  String get modeTowerAscension => 'ASCENSÃO DA TORRE';

  @override
  String get modeGauntlet => 'GAUNTLET';

  @override
  String get modePvp => 'PVP';

  @override
  String get modeChallenges => 'DESAFIOS';

  @override
  String get modeEvents => 'EVENTOS';

  @override
  String get modeExpedition => 'EXPEDIÇÃO';

  @override
  String get modeDaily => 'DIÁRIO';

  @override
  String get modeBounties => 'RECOMPENSAS';

  @override
  String get modeQuests => 'MISSÕES';

  @override
  String get badgeNew => 'NOVO';

  @override
  String get lootLog => 'REGISTRO DE SAQUE';

  @override
  String get noLootYet => 'Sem saque ainda — vá lutar!';

  @override
  String get welcomeBack => 'Bem-vindo de volta!';

  @override
  String awayFor(String time) {
    return 'Você ficou ausente por $time.';
  }

  @override
  String awayForCapped(int hours) {
    return 'Você ficou ausente por mais de ${hours}h — mostrando as recompensas máximas de inatividade.';
  }

  @override
  String rewardGold(String amount) {
    return '+$amount de ouro';
  }

  @override
  String rewardXp(String amount) {
    return '+$amount XP';
  }

  @override
  String rewardShards(String amount) {
    return '+$amount fragmentos';
  }

  @override
  String expeditionsReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expedições prontas!',
      one: '$count expedição pronta!',
    );
    return '$_temp0';
  }

  @override
  String get comebackBonus => 'Bônus de retorno:';

  @override
  String get idleIncomeCollected =>
      'Renda inativa coletada enquanto você descansava.';

  @override
  String get claim => 'COLETAR';

  @override
  String get milestone => 'MARCO';

  @override
  String get welcomeBackCaps => 'BEM-VINDO DE VOLTA!';

  @override
  String get missedYou =>
      'Sentimos sua falta! Aqui está um bônus\npelo seu tempo ausente:';

  @override
  String get newSystemUnlocked => 'NOVO SISTEMA DESBLOQUEADO';

  @override
  String get gotIt => 'ENTENDI';

  @override
  String get welcomeFightTitle => 'Lutar!';

  @override
  String get welcomeFightBody =>
      'Vá para a aba JOGAR e toque em um cartão de fase na CAMPANHA para iniciar sua primeira batalha. Continue atacando até o inimigo cair!';

  @override
  String get welcomeIdleTitle => 'Ganhe ouro inativo';

  @override
  String get welcomeIdleBody =>
      'Seu herói ganha ouro automaticamente a cada minuto, mesmo quando você não está lutando. Veja a barra de ouro na aba HERÓI encher.';

  @override
  String get welcomeStrongerTitle => 'Fique mais forte';

  @override
  String get welcomeStrongerBody =>
      'Gaste ouro em MELHORIAS para aumentar seus atributos. Abra PASSIVAS para bônus permanentes e HABILIDADES para poderosas habilidades de combate.';

  @override
  String get welcomeExploreTitle => 'Explorar';

  @override
  String get welcomeExploreBody =>
      'CAMPANHA avança por 100 fases criadas à mão. ASCENSÃO DA TORRE permite farmar fragmentos indefinidamente. A MASMORRA é uma corrida roguelite com queda de itens e batalhas de chefe. Mais modos são desbloqueados conforme você progride.';

  @override
  String get navBack => 'VOLTAR';

  @override
  String get navNext => 'PRÓXIMO';

  @override
  String get startPlaying => 'COMEÇAR A JOGAR';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Padrão do sistema';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonContinue => 'CONTINUAR';

  @override
  String heroFalls(String name) {
    return '$name CAI';
  }

  @override
  String get battleGrowStronger =>
      'Fique mais forte antes de tentar novamente.';

  @override
  String get battleBackToHero => 'VOLTAR AO HERÓI';

  @override
  String get defeatEndlessTitle => 'MODO INFINITO';

  @override
  String get defeatEndlessHint => 'Faça farm de XP e ouro no seu ritmo';

  @override
  String get defeatDungeonHint => 'Ganhe fragmentos e itens';

  @override
  String get defeatGauntletHint => 'Ganhe ecos para melhorias';

  @override
  String get defeatDailyTitle => 'DESAFIOS DIÁRIOS';

  @override
  String get defeatDailyHint => 'Resgate recompensas por progresso';

  @override
  String battleTierUnlocked(int tier) {
    return 'TIER $tier DESBLOQUEADO';
  }

  @override
  String get battleCampaignCleared => 'CAMPANHA CONCLUÍDA';

  @override
  String battleTierUnlockedBody(int tier) {
    return 'O Ômega caiu. A campanha reinicia no Tier $tier — inimigos mais difíceis e saques melhores.\n\nSeu nível, Páragon, equipamentos e moedas são mantidos. Nada é resetado.';
  }

  @override
  String get battleCampaignClearedBody =>
      'O Ômega caiu no tier mais alto. Você chegou ao topo — continue farmando por saques e Pontos de Páragon.';

  @override
  String get battleSwitchTiersHint =>
      'Mude de tier a qualquer momento no cabeçalho da Campanha.';

  @override
  String get battleRetreat => 'Recuar';

  @override
  String get battleLastFightSummary => 'Resumo da última luta';

  @override
  String get battleResume => 'Retomar';

  @override
  String get battlePause => 'Pausar';

  @override
  String get battleAutoCampaignLocked =>
      'Campanha Automática — Speed Boost / Passe Premium';

  @override
  String get battleAutoCampaignOn => 'Campanha Automática: ATIVADA';

  @override
  String get battleAutoCampaignOff => 'Campanha Automática: DESATIVADA';

  @override
  String get battleNoFightYet => 'Nenhuma luta finalizada ainda.';

  @override
  String get battleAutoCampaignPerk =>
      'Campanha Automática é um benefício do Speed Boost / Passe Premium.';

  @override
  String get battleNoActiveBattle => 'NENHUMA BATALHA ATIVA';

  @override
  String get battleVictory => 'VITÓRIA!';

  @override
  String get battleBossDefeated => 'CHEFE DERROTADO';

  @override
  String get battleNewContentUnlocked => 'NOVO CONTEÚDO DESBLOQUEADO';

  @override
  String get battleClassQuestlineUnlocked => 'MISSÕES DE CLASSE DESBLOQUEADAS';

  @override
  String battleClassQuestlineBody(String className) {
    return 'O caminho de $className começa. Complete 5 missões para desbloquear sua Habilidade Suprema.';
  }

  @override
  String battleRewardGold(String amount) {
    return '+$amount OURO';
  }

  @override
  String battleRewardXp(String amount) {
    return '+$amount XP';
  }

  @override
  String battleRewardShards(String amount) {
    return '+$amount FRAGMENTOS';
  }

  @override
  String battleAbilityUnlocked(String name) {
    return 'HABILIDADE DESBLOQUEADA: $name';
  }

  @override
  String get battleAddedToBag => 'Adicionado à Bolsa';

  @override
  String get battleFight => 'LUTAR  (−1 ⚡)';

  @override
  String get battleSpeedBoostTitle => '2× Speed Boost';

  @override
  String battleSpeedBoostBody(int cost, int have) {
    return 'Desbloquear velocidade de batalha 2× por 7 dias?\n\nCusto: $cost ZCoins\nSeus ZCoins: $have';
  }

  @override
  String get battlePurchase => 'Comprar';

  @override
  String get battleNotEnoughZcoins => 'ZCoins insuficientes!';

  @override
  String get battleArtifactFound => 'ARTEFATO ENCONTRADO!';

  @override
  String battleRoundsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rodadas restantes',
      one: '$count rodada restante',
    );
    return '$_temp0';
  }

  @override
  String get commonOk => 'OK';

  @override
  String get campaignDifficultyTier => 'TIER DE DIFICULDADE';

  @override
  String get campaignDifficultyTierTooltip => 'Tier de Dificuldade';

  @override
  String get campaignTierSelectorBody =>
      'Tiers mais altos = inimigos mais difíceis E saques melhores (raridade, sets, artefatos). Trocar para baixo mantém todo seu poder permanente — apenas escala o que você luta e o que cai.';

  @override
  String get campaignTierNormal => 'TIER 0 — Normal';

  @override
  String campaignTierN(int tier) {
    return 'TIER $tier';
  }

  @override
  String get campaignTierBaseDesc =>
      'Inimigos base · saque base · sem Magia de Achado';

  @override
  String campaignTierScaledDesc(int hp, int atk) {
    return 'Inimigos +$hp% HP · +$atk% ATK';
  }

  @override
  String campaignTierMagicFind(int mf) {
    return '✦ +$mf% Magia de Achado (raridade, sets e artefatos melhores)';
  }

  @override
  String get campaignLeaderboardTooltip => 'Placar da Campanha';

  @override
  String get campaignTutorial =>
      'A campanha avança fase por fase. Derrote cada chefe para desbloquear a próxima. Elimine o chefe final para desbloquear o próximo Tier de Dificuldade — a campanha reinicia mais difícil com saques melhores, e seu poder é mantido.';

  @override
  String campaignEnergyRecharge(String time) {
    return '+1 em $time';
  }

  @override
  String campaignEnergyRefill(int amount, int left) {
    return 'Recarregar +$amount  ($left grátis restantes)';
  }

  @override
  String get campaignBuy => 'Comprar ';

  @override
  String get campaignEnergyEmptyTutorial =>
      'Sem energia! ⚡ Recarrega 1 a cada 5 min. Toque no botão +10 acima para 3 recargas diárias grátis. Ou compre +20 de energia por 💎 50 ZCoins.';

  @override
  String get campaignStageMap =>
      'MAPA DE FASES  •  toque em qualquer nó ✓ para repetir';

  @override
  String get campaignNoEnergyRefill => 'Sem energia! Aguarde recarregar.';

  @override
  String campaignSimulateStage(int stage) {
    return '⚡ Simular Fase $stage';
  }

  @override
  String campaignEnergyAvailable(int count) {
    return 'Energia disponível: $count';
  }

  @override
  String get campaignSimInfo =>
      'Batalhas correm instantaneamente. O saque vai direto para sua bolsa.';

  @override
  String campaignSimAll(int count) {
    return 'TUDO ($count)';
  }

  @override
  String campaignSimResultTitle(int stage, int count) {
    return 'Fase $stage — $count× Simuladas';
  }

  @override
  String get campaignSimGold => '💰 Ouro';

  @override
  String get campaignSimXp => '✦ XP';

  @override
  String campaignItemsDropped(int count) {
    return 'Itens caídos ($count):';
  }

  @override
  String get campaignNoItemsDropped => 'Nenhum item caiu nessa corrida.';

  @override
  String get campaignNotEnoughEnergy => 'Energia insuficiente!';

  @override
  String get campaignMapFight => '⚔  LUTAR (−1 ⚡)';

  @override
  String get campaignSimRequiresPremium => 'Requer assinatura do Passe Premium';

  @override
  String get campaignBossEncounter => 'ENCONTRO COM CHEFE';

  @override
  String get campaignDismiss => '[ dispensar ]';

  @override
  String campaignPerfectStages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fases perfeitas',
      one: '$count fase perfeita',
    );
    return '$_temp0';
  }

  @override
  String campaignNextMilestone(int next) {
    return '• próximo marco na fase $next (+mithril +Z-Coins)';
  }

  @override
  String get campaignAllMilestones => '• todos os marcos concluídos!';

  @override
  String get hubWhatsNew => 'O Que Há de Novo';

  @override
  String get hubLootLog => 'Registro de Saque';

  @override
  String get hubSettings => 'Configurações';

  @override
  String get hubChange => 'ALTERAR';

  @override
  String get hubHeroMenu => 'Menu do herói';

  @override
  String get hubJoinDiscord => 'Entrar no Discord';

  @override
  String get hubVisitReddit => 'Visitar r/zeta_idle';

  @override
  String hubCouldNotOpen(String url) {
    return 'Não foi possível abrir $url';
  }

  @override
  String get hubLocked => 'Bloqueado';

  @override
  String get hubGroupCharacter => 'PERSONAGEM';

  @override
  String get hubGroupProgression => 'PROGRESSÃO';

  @override
  String get hubGroupCollection => 'COLEÇÃO';

  @override
  String get hubGroupRecords => 'REGISTROS';

  @override
  String get hubBlurbCharacter => 'Sua build e poder';

  @override
  String get hubBlurbProgression => 'Sistemas de fim de jogo';

  @override
  String get hubBlurbCollection => 'Aliados e compêndio';

  @override
  String get hubBlurbRecords => 'Metas e resumos';

  @override
  String get hubSheet => 'FICHA';

  @override
  String get hubScores => 'ATRIBUTOS';

  @override
  String get hubAbilities => 'HABILIDADES';

  @override
  String get hubPassives => 'PASSIVAS';

  @override
  String get hubSpecialize => 'ESPECIALIZAR';

  @override
  String get hubParagon => 'PÁRAGON';

  @override
  String get hubUpgrades => 'MELHORIAS';

  @override
  String get hubAscend => 'ASCENDER';

  @override
  String get hubMastery => 'MAESTRIA';

  @override
  String get hubPets => 'MASCOTES';

  @override
  String get hubMercs => 'MERCENÁRIOS';

  @override
  String get hubBestiary => 'BESTIÁRIO';

  @override
  String get hubCodex => 'CÓDEX';

  @override
  String get hubArmory => 'ARSENAL';

  @override
  String get hubAchievements => 'CONQUISTAS';

  @override
  String get hubBonuses => 'BÔNUS';

  @override
  String get auShards => 'fragmentos';

  @override
  String get auRespecTitle => 'Redirecionar Habilidades?';

  @override
  String auRespecBody(int cost) {
    return 'Resetar todos os ranks de habilidades e escolhas de marcos.\nTodos os fragmentos gastos serão reembolsados.\n\nCusto: $cost ZCoins';
  }

  @override
  String auRespecConfirm(int cost) {
    return 'REDIRECIONAR ($cost ZC)';
  }

  @override
  String get auRespec => 'REDIRECIONAR';

  @override
  String get auTutorial =>
      'Você ganhou Fragmentos ◆ — gaste-os aqui para desbloquear e melhorar habilidades de classe que disparam automaticamente em cada batalha.';

  @override
  String get auIntro =>
      'Gaste fragmentos para potencializar suas habilidades. Marcos nos ranks 5, 10 e 15. Avance de tier após o rank 15 — cada tier é desbloqueado com seu Tier de Dificuldade.';

  @override
  String get auTitle => 'MELHORIAS DE HABILIDADES';

  @override
  String get auMaxTier => 'TIER MÁX  ✦';

  @override
  String auTierLockedLabel(int tier, int req) {
    return 'TIER $tier  —  Requer Tier de Dificuldade $req';
  }

  @override
  String get auAscension => 'ASCENSÃO';

  @override
  String auTierUnlocked(int cap) {
    return 'Tier $cap desbloqueado';
  }

  @override
  String auAscFullyAscended(int pct) {
    return 'Totalmente ascendido  ·  +$pct% poder de habilidade';
  }

  @override
  String auAscTierLocked(int cur, int next) {
    return '+$cur% poder  ·  Desbloqueie o Tier de Dificuldade $next para ascender mais';
  }

  @override
  String auAscUpgrade(int cur, int next, int cost) {
    return '+$cur%  →  +$next% poder  ·  custa $cost ✦ Páragon';
  }

  @override
  String auAscYouHave(int have) {
    return '  (você tem $have)';
  }

  @override
  String get auMax => 'MÁX';

  @override
  String get auLocked => 'BLOQUEADO';

  @override
  String auAscendBtn(int cost) {
    return 'ASCENDER  $cost ✦';
  }

  @override
  String get auUltimate => 'SUPREMA';

  @override
  String auUnlocksLv(int lv) {
    return 'DESBLOQUEIA NV $lv';
  }

  @override
  String get auFinishQuestline =>
      '🔒 Termine sua missão de classe para desbloquear';

  @override
  String auReachLevel(int lv, int cur) {
    return 'Alcance o Nível $lv  (você: Nv $cur)';
  }

  @override
  String auCompleteQuests(String className, int claimed) {
    return 'Complete todas as 5 missões de $className  ($claimed / 5)';
  }

  @override
  String get auTrackQuests => 'Acompanhe suas missões na aba Missões.';

  @override
  String get auChoose => 'ESCOLHER';

  @override
  String get setTitle => 'CONFIGURAÇÕES';

  @override
  String get setSave => 'SALVAR';

  @override
  String get setLoad => 'CARREGAR';

  @override
  String get setReset => 'RESETAR';

  @override
  String get setOpen => 'ABRIR';

  @override
  String get setView => 'VER';

  @override
  String get setEmail => 'E-MAIL';

  @override
  String get setConfirm => 'CONFIRMAR';

  @override
  String get setSecAccount => 'CONTA';

  @override
  String get setSecPromo => 'CÓDIGO PROMOCIONAL';

  @override
  String get setSecAudio => 'ÁUDIO';

  @override
  String get setSecHaptics => 'TATO';

  @override
  String get setSecNotifications => 'NOTIFICAÇÕES';

  @override
  String get setSecDisplay => 'TELA';

  @override
  String get setSecStats => 'ESTATÍSTICAS';

  @override
  String get setSecAutoLoot => 'SAQUE AUTOMÁTICO';

  @override
  String get setSecBattle => 'BATALHA';

  @override
  String get setSecDailyReset => 'RESET DIÁRIO';

  @override
  String get setSecSave => 'SALVAR';

  @override
  String get setSecDanger => 'ZONA DE PERIGO';

  @override
  String get setSecHelp => 'AJUDA';

  @override
  String get setSecAbout => 'SOBRE';

  @override
  String get setManage => 'GERENCIAR';

  @override
  String get setSignIn => 'ENTRAR';

  @override
  String get setHeroName => 'Nome do Herói';

  @override
  String setRename(int cost) {
    return 'RENOMEAR ($cost 🪙)';
  }

  @override
  String get setPromoHint => 'Tem um código? Resgate aqui por recompensas.';

  @override
  String get setRedeem => 'RESGATAR';

  @override
  String get setSoundEffects => 'Efeitos Sonoros';

  @override
  String get setBackgroundMusic => 'Música de Fundo';

  @override
  String get setVolume => 'Volume';

  @override
  String get setVibration => 'Vibração';

  @override
  String get setReminders => 'Lembretes';

  @override
  String get setDamageNumbers => 'Números de Dano';

  @override
  String get setReducedParticles => 'Partículas Reduzidas';

  @override
  String get setTotalPlaytime => 'Tempo Total de Jogo';

  @override
  String get setAutoSalvage => 'Salvamento Automático';

  @override
  String get setAutoEquip => 'Equipar Melhorias Automaticamente';

  @override
  String get setAutoEquipSub =>
      'Equipar automaticamente itens melhores que o equipamento atual';

  @override
  String get setBattleSpeed => 'Velocidade de Batalha';

  @override
  String get setAutoCampaign => 'Campanha Automática';

  @override
  String get setResetTime => 'Horário de Reset';

  @override
  String get setCloudSave => 'Salvar na Nuvem';

  @override
  String get setCloudSaveSub => 'Sincronizar seu progresso na nuvem';

  @override
  String get setCloudSaveComplete => 'Salvo na nuvem com sucesso.';

  @override
  String get setLoadCloud => 'Carregar da Nuvem';

  @override
  String get setLoadCloudSub => 'Substituir salvo local com dados da nuvem';

  @override
  String get setResetProgress => 'Resetar Progresso';

  @override
  String get setResetProgressSub =>
      'Excluir todos os dados de save deste slot. Irreversível.';

  @override
  String get setKnowledgeBase => 'Base de Conhecimento';

  @override
  String get setKnowledgeBaseSub =>
      'Palavras-chave, sistemas e moedas explicados';

  @override
  String get setTagline => 'Um RPG idle medieval sombrio.';

  @override
  String get setAboutHero => 'Herói';

  @override
  String get setAboutClass => 'Classe';

  @override
  String get setAboutLevel => 'Nível';

  @override
  String get setAboutPrestige => 'Prestígio';

  @override
  String get setAboutAchievements => 'Conquistas';

  @override
  String get setAboutDeveloper => 'Desenvolvedor';

  @override
  String get setAboutContact => 'Contato';

  @override
  String get setPrivacy => 'Política de Privacidade';

  @override
  String get setPrivacySub => 'Como tratamos seus dados';

  @override
  String get setReportBug => 'Reportar Bug / Feedback';

  @override
  String get setReportBugSub =>
      'Envie-nos um e-mail — informações do dispositivo são adicionadas automaticamente';

  @override
  String get setReplayTips => 'Rever Dicas';

  @override
  String get setReplayTipsSub => 'Mostrar as dicas do tutorial novamente';

  @override
  String get setTipsReset =>
      'Dicas do tutorial resetadas — elas reaparecerão enquanto você explora.';

  @override
  String get setRenameHeroTitle => 'RENOMEAR HERÓI';

  @override
  String get setHeroNameHint => 'Digite um nome de herói';

  @override
  String setRenameCost(int cost, int have) {
    return 'Custo: $cost 🪙   (você tem $have)';
  }

  @override
  String setRenameNotEnough(int cost) {
    return 'ZCoins insuficientes — renomear custa $cost 🪙.';
  }

  @override
  String get setNoEmailApp =>
      'Nenhum app de e-mail encontrado. Fale conosco em razorintegrations@gmail.com';

  @override
  String get setDailyResetTitle => 'Horário de Reset Diário';

  @override
  String get setDailyResetHint =>
      'Escolha a hora em que os limites diários são resetados.';

  @override
  String get setDailyResetWarning =>
      'Atenção: você só pode alterar isso uma vez por ano.';

  @override
  String get setLoadCloudTitle => 'Carregar da Nuvem?';

  @override
  String get setLoadCloudBody =>
      'Isso substituirá seu save local com os dados da nuvem. O progresso local não sincronizado será perdido.';

  @override
  String get setResetAllTitle => 'Resetar todo o progresso?';

  @override
  String get setResetAllBody =>
      'Todo progresso, ouro, itens, níveis de prestígio e conquistas serão permanentemente excluídos. Isso não pode ser desfeito.';

  @override
  String get setNewHeroName => 'Novo nome do herói:';

  @override
  String get setGoogleAccount => 'Conta Google';

  @override
  String get setSignInGoogle => 'Entrar com Google';

  @override
  String get setSignedIn => 'Conectado';

  @override
  String get setSyncSaves => 'Sincronizar saves entre dispositivos';

  @override
  String get setEnterCode => 'INSERIR CÓDIGO';

  @override
  String get setOff => 'Desligado';

  @override
  String get setOffCaps => 'DESLIGADO';

  @override
  String get setHidden => 'Oculto';

  @override
  String get setVibrationOn =>
      'Vibra em críticos, subidas de nível, vitórias e recompensas';

  @override
  String get setRemindersOn =>
      'Receba lembretes \"volte\" enquanto estiver ausente';

  @override
  String get setDamageOn => 'Números flutuantes exibidos em batalha';

  @override
  String get setParticlesOn => 'Menos efeitos de fundo (melhor desempenho)';

  @override
  String get setParticlesOff => 'Efeitos completos';

  @override
  String get setSalvageOff =>
      'Toque para ativar salvamento automático de drops';

  @override
  String setSalvageOn(String tier) {
    return 'Salvamento automático de $tier e abaixo';
  }

  @override
  String get setAutoCampaignOnSub =>
      'Lutar batalhas de campanha automaticamente em segundo plano';

  @override
  String get setAutoCampaignLockedSub =>
      '🔒 Apenas para assinantes do Speed Boost / Passe Premium';

  @override
  String setResetTimeOn(String time) {
    return 'Limites diários resetam às $time. Toque para alterar (uma vez por ano).';
  }

  @override
  String setResetTimeLocked(String time) {
    return 'Reseta às $time · Já alterado este ano.';
  }

  @override
  String get guildTitle => 'GUILDA';

  @override
  String get guildJoinTitle => 'ENTRAR EM UMA GUILDA';

  @override
  String get guildJoinBlurb =>
      'Guildas fornecem bônus passivos, um desafio semanal de chefe e uma loja de guilda com recompensas exclusivas.';

  @override
  String get guildCreate => 'CRIAR GUILDA';

  @override
  String get guildPublic => 'GUILDAS PÚBLICAS';

  @override
  String get guildNoGuilds =>
      'Nenhuma guilda encontrada. Seja o primeiro a criar uma!';

  @override
  String get guildCreateTitle => 'Criar Guilda';

  @override
  String get guildNameLabel => 'Nome da Guilda';

  @override
  String get guildDescLabel => 'Descrição (opcional)';

  @override
  String get guildCreateBtn => 'CRIAR';

  @override
  String get guildTabInfo => 'INFO';

  @override
  String get guildTabCastle => 'CASTELO';

  @override
  String get guildTabBoss => 'CHEFE';

  @override
  String get guildTabWar => 'GUERRA';

  @override
  String get guildTabChat => 'CHAT';

  @override
  String get guildTabShop => 'LOJA';

  @override
  String guildCastleTier(int tier) {
    return 'CASTELO — TIER $tier / 10';
  }

  @override
  String guildProgressTier(int tier) {
    return 'Progresso para o Tier $tier';
  }

  @override
  String guildCpProgress(int cp, int cap) {
    return '$cp / $cap PC';
  }

  @override
  String guildNext(String headline) {
    return 'Próximo: $headline';
  }

  @override
  String get guildCitadelComplete =>
      'Cidadela completa — o castelo está totalmente construído!';

  @override
  String get guildContributeGold => 'CONTRIBUIR COM OURO';

  @override
  String guildContributeInfo(String rate, int cap) {
    return 'Converta ouro em Pontos de Construção (PC). Taxa: $rate ouro = 1 PC. Você pode adicionar até $cap PC por dia.';
  }

  @override
  String get guildActiveBenefits => 'BENEFÍCIOS ATIVOS DO CASTELO';

  @override
  String get guildContributeHint =>
      'Contribua para elevar o castelo e desbloquear benefícios.';

  @override
  String guildCastleAdvanced(int tier) {
    return '🏰 Castelo avançou para o Tier $tier!';
  }

  @override
  String get guildCapReached =>
      'Limite diário de construção atingido — volte amanhã!';

  @override
  String guildLevelMembers(int lvl, int m, int max) {
    return 'Nível $lvl  •  $m/$max membros';
  }

  @override
  String guildBonusGold(int pct) {
    return '+$pct% Ouro';
  }

  @override
  String guildBonusXp(int pct) {
    return '+$pct% XP';
  }

  @override
  String guildBonusIdle(int pct) {
    return '+$pct% Inativo';
  }

  @override
  String guildXpProgress(int xp, int max) {
    return '$xp/$max XP';
  }

  @override
  String get guildDonate1000 => 'DOAR 1000 OURO';

  @override
  String get guildDonateReward => '→ XP da Guilda + 🪙';

  @override
  String get guildPerks => 'VANTAGENS';

  @override
  String guildLockedPerk(int lvl, String name, String desc) {
    return '🔒 Nv$lvl: $name — $desc';
  }

  @override
  String get guildMembers => 'MEMBROS';

  @override
  String guildMemberLine(int lvl, String cls, String role, int d) {
    return 'Nv$lvl $cls  •  $role  •  doado: ${d}g';
  }

  @override
  String get guildLeave => 'SAIR DA GUILDA';

  @override
  String get guildNoBoss => 'Nenhum chefe esta semana.';

  @override
  String get guildWeeklyBoss => '☠ CHEFE SEMANAL DA GUILDA';

  @override
  String guildBossHp(int hp, int max) {
    return '$hp / $max HP';
  }

  @override
  String get guildDefeated => '✓ DERROTADO';

  @override
  String guildBossRewardMsg(Object rank, Object gc, Object gold) {
    return '🏆 Chefe da semana passada: Rank #$rank — +$gc Moedas de Guilda, +$gold ouro';
  }

  @override
  String get guildClaimBossReward =>
      '🏆 RESGATAR RECOMPENSA DO CHEFE DA SEMANA PASSADA';

  @override
  String guildAttempts(int rem, int max) {
    return 'Tentativas: $rem / $max';
  }

  @override
  String get guildNoAttempts => 'SEM TENTATIVAS RESTANTES';

  @override
  String get guildChallengeBoss => '⚔ DESAFIAR CHEFE';

  @override
  String get guildDamageRanking => 'RANKING DE DANO';

  @override
  String guildDmg(int dmg) {
    return '$dmg dano';
  }

  @override
  String get guildWarStandings => 'CLASSIFICAÇÃO DE GUERRA';

  @override
  String guildWarRecord(int w, int l) {
    return 'Seu histórico: ${w}V–${l}D';
  }

  @override
  String get guildWeeklyWar => 'Guerra de Guilda Semanal';

  @override
  String get guildWarBlurb =>
      'Aliste-se durante a Preparação (seg–ter). Qua–sex, gaste Ataques de Guerra para lutar contra campeões rivais e ganhar pontos para sua guilda. Sáb–dom, resgate as recompensas de rank.';

  @override
  String get guildEnlistedBattle =>
      '⚔ Alistado! Gaste seus Ataques de Guerra agora.';

  @override
  String get guildEnlistedPrep => '⚔ Alistado! Volte qua–sex para lutar.';

  @override
  String get guildEnlist => 'ALISTAR SUA GUILDA';

  @override
  String get guildWarEndedWait => 'GUERRA ENCERRADA — AGUARDE A PRÓXIMA SEMANA';

  @override
  String guildScoreYou(String name) {
    return '$name (você)';
  }

  @override
  String get guildLeads => '🏆 Sua guilda lidera!';

  @override
  String get guildBehind => '⚠ Sua guilda está atrás — lute!';

  @override
  String guildFightForGuild(int c, int max) {
    return '⚔ LUTAR PELA GUILDA  ($c/$max)';
  }

  @override
  String get guildNoWarAttacks => 'SEM ATAQUES DE GUERRA HOJE';

  @override
  String get guildWarRefresh =>
      'Ataques de Guerra são renovados diariamente durante a fase de Batalha.';

  @override
  String get guildWarVictory => '🏆 Vitória!';

  @override
  String get guildWarOver => 'Guerra encerrada.';

  @override
  String guildWarRewardMsg(String result, Object gc, Object gold) {
    return '$result +$gc Moedas de Guilda, +$gold ouro';
  }

  @override
  String get guildRewardsClaimed => 'RECOMPENSAS RESGATADAS';

  @override
  String get guildClaimWarRewards => 'RESGATAR RECOMPENSAS DE GUERRA';

  @override
  String get guildWarBattleSoon =>
      'A batalha começa na quarta-feira — volte para lutar!';

  @override
  String get guildCoinsLabel => 'Moedas de Guilda';

  @override
  String guildListLine(int lvl, int m, int max) {
    return 'Nv$lvl  •  $m/$max membros';
  }

  @override
  String get guildJoin => 'ENTRAR';

  @override
  String get guildFull => 'LOTADA';

  @override
  String get guildBossTitle => 'CHEFE DA GUILDA';

  @override
  String get guildBossWin => '✦ CHEFE DERROTADO!';

  @override
  String get guildBossLose => '💀 CAÍDO';

  @override
  String guildTotalDamage(int d) {
    return 'Dano total causado: $d';
  }

  @override
  String get guildReturn => 'VOLTAR À GUILDA';

  @override
  String guildCpAmount(int cp) {
    return '+$cp PC';
  }

  @override
  String guildGoldCost(String gold) {
    return '${gold}g';
  }

  @override
  String get forgeSalvageTooltip =>
      'Destrua itens para recuperar Fragmentos (◆).\n• Comum → 3 ◆\n• Raro → 8 ◆\n• Épico → 20 ◆\n• Lendário → 60 ◆\n• Set → 100 ◆';

  @override
  String get forgeUpgradeTooltip =>
      'Melhore um item de +0 a +10.\nCada tier aumenta todos os atributos em 8%.\nAo atingir +5 e +10 o item ganha um prefixo.\nCusta Ouro + Fragmentos por tier.';

  @override
  String get forgeTitle => 'FORJA';

  @override
  String get forgeSalvage => 'SALVAR';

  @override
  String get forgeUpgrade => 'MELHORAR';

  @override
  String get forgeSlot => 'SLOT';

  @override
  String get forgeFrom => 'DE  ';

  @override
  String forgeForged(String name, String label) {
    return 'Forjado: $name ($label)!';
  }

  @override
  String get forgeSalvageRates => 'TAXAS DE SALVAMENTO';

  @override
  String forgeSalvageBtn(int n, int s) {
    return 'SALVAR  $n  (+$s ◆)';
  }

  @override
  String get forgeBagEmpty => 'Sua bolsa está vazia.';

  @override
  String forgeBag(int n) {
    return 'BOLSA  ($n itens)';
  }

  @override
  String forgeSalvaged(int earned) {
    return 'Salvado: +$earned ◆';
  }

  @override
  String forgeTimesN(int n) {
    return ' ×$n';
  }

  @override
  String get forgeTimesRandom => '  ×1 (aleatório)';

  @override
  String get forgeMasterForger => 'Mestre Ferreiro';

  @override
  String get forgeSelected => 'SELECIONADO';

  @override
  String forgeSelectedCount(int selected, int needed) {
    return '$selected / $needed';
  }

  @override
  String get forgeArcaneDust => 'PÓ ARCANO';

  @override
  String get forgeGemType => 'TIPO DE GEMA';

  @override
  String forgeGemWeaponDesc(Object pct, String type) {
    return '⚔ Arma: +$pct% dano $type';
  }

  @override
  String forgeGemArmorDesc(Object pct, String type) {
    return '🛡 Armadura: +$pct% resistência $type';
  }

  @override
  String get forgeTier => 'TIER';

  @override
  String forgeGemBagFull(int n, int max) {
    return 'BOLSA DE GEMAS CHEIA ($n/$max)';
  }

  @override
  String forgeNeedMore(int n) {
    return 'PRECISA DE $n MAIS 💠';
  }

  @override
  String forgeCraft(int cost) {
    return '✦  FORJAR  $cost 💠';
  }

  @override
  String forgePreviewWeapon(String effect) {
    return '⚔ Arma: $effect';
  }

  @override
  String forgePreviewArmor(String effect) {
    return '🛡 Armadura: $effect';
  }

  @override
  String forgeToCraft(int cost) {
    return '$cost 💠 para forjar';
  }

  @override
  String forgeGemBag(int n, int max) {
    return 'BOLSA DE GEMAS  ($n/$max)';
  }

  @override
  String get forgeTapGem => 'Toque em uma gema para encaixá-la em um item';

  @override
  String get forgeNoGems => 'Nenhuma gema forjada ainda. Forje uma acima!';

  @override
  String get forgeHowGems => 'COMO AS GEMAS FUNCIONAM';

  @override
  String get forgeGemsInfo =>
      '• Cada gema é de uso duplo — a MESMA gema dá DANO elemental em uma arma, ou RESISTÊNCIA elemental em armadura / joias.\n• Fragmentos de gema caem de mortes em combate (25% de chance) e chefes.\n• Cada item pode ter 1 gema em seu encaixe.\n• Encaixe gemas desta bolsa ou pela tela de Inventário.\n• Substituir ou remover uma gema destrói a antiga.';

  @override
  String get forgeNoItemsSocket => 'Sem itens para encaixar.';

  @override
  String forgeSocketGem(String name) {
    return 'Encaixar $name';
  }

  @override
  String get forgeChooseItem => 'Escolha um item para encaixar esta gema.';

  @override
  String get forgeReplaceGem => 'Substituir Gema?';

  @override
  String forgeReplaceBody(String old, String gnew) {
    return '$old será destruída e substituída por $gnew. Isso não pode ser desfeito.';
  }

  @override
  String get forgeReplace => 'SUBSTITUIR';

  @override
  String get forgeUpgradeInfo =>
      'Melhore itens de +0 a +10. Cada tier aumenta todos os atributos em 8%.\nAo atingir +5 o item ganha o prefixo Refinado.\nAo atingir +10 ele se torna Obra-Prima.';

  @override
  String get forgeBalance => 'Saldo: ';

  @override
  String get forgeNoUpgradeItems =>
      'Sem itens disponíveis para melhoria.\nTodos os itens estão em +10 ou a bolsa está vazia.';

  @override
  String get forgeSelectItem => 'SELECIONAR ITEM';

  @override
  String get forgeAllStats => 'Todos os atributos +8%';

  @override
  String get forgeWeaponDmgSuffix => '  •  Dano de arma +8%';

  @override
  String get forgeRefinedPrefix =>
      '🏷 Ganha o prefixo \"Refinado\" ao atingir +5!';

  @override
  String get forgeMasterworkPrefix =>
      '🏷 Ganha o prefixo \"Obra-Prima\" ao atingir +10!';

  @override
  String forgeUpgradeTo(int tier) {
    return 'MELHORAR PARA +$tier';
  }

  @override
  String get dngTitle => 'A MASMORRA';

  @override
  String dngTitleRun(int tier, int floor) {
    return 'T$tier  AND.$floor  —  A MASMORRA';
  }

  @override
  String get dngFlee => 'Fugir da masmorra';

  @override
  String get dngAutoOn => 'Auto Run: ATIVADO — toque para controle manual';

  @override
  String get dngAutoOff =>
      'Auto Run: DESATIVADO — toque para limpar automaticamente';

  @override
  String get dngAutoPremium => 'Auto Run (desbloqueia na Fase 5)';

  @override
  String get dngPushOnTip =>
      'Avanço Abissal: ATIVADO — derrote o Senhor da Masmorra para descer mais fundo';

  @override
  String get dngPushOffTip =>
      'Avanço Abissal: DESATIVADO — a corrida termina no andar limpo';

  @override
  String get dngPushOnMsg =>
      'Avanço Abissal ATIVADO — limpe o Senhor da Masmorra para descer em andares abissais escaláveis (mais Mithril + chances únicas). Fuja a qualquer momento para garantir a limpeza.';

  @override
  String get dngPushOffMsg =>
      'Avanço Abissal DESATIVADO — a corrida termina quando você limpar o Senhor da Masmorra.';

  @override
  String get dngLeaderboard => 'Placar da Masmorra';

  @override
  String get dngAutoPremiumMsg => 'Auto Run desbloqueia na Fase 5 da campanha.';

  @override
  String get dngTutorial =>
      'Escolha uma de duas portas por andar. Inimigos mortos derrubam Ossos — gaste-os com o Mercador Viajante para buffs durante a corrida. O saque é seu imediatamente, mesmo que seu herói caia.';

  @override
  String get dngWhatToExpect => 'O QUE ESPERAR';

  @override
  String get dngExpCombat => 'Combate — lute por ouro';

  @override
  String get dngExpElite =>
      'Elite — inimigo mais difícil, queda de item garantida';

  @override
  String get dngExpAmbush => 'Emboscada — inimigo ataca primeiro, muito ouro';

  @override
  String get dngExpRest => 'Local de Descanso — recupere 20% de HP';

  @override
  String get dngExpTreasure => 'Tesouro — reivindique ouro e fragmentos';

  @override
  String get dngExpShrine => 'Santuário — escolha uma bênção duradoura';

  @override
  String get dngExpChest => 'Baú Trancado — gaste fragmentos por um item raro';

  @override
  String get dngExpTrap => 'Armadilha — dano inevitável';

  @override
  String get dngExpBoss =>
      'Chefe (a cada 5 andares) — alto risco, alta recompensa';

  @override
  String get dngBonesHint =>
      'Inimigos mortos derrubam Ossos — gaste-os com o Mercador Viajante.';

  @override
  String get dngExpectedLoot => 'SAQUE ESPERADO';

  @override
  String get dngLootGold => 'Ouro';

  @override
  String get dngLootGoldDetail =>
      'De combate, salas de tesouro e mantimentos de descanso';

  @override
  String get dngLootShards => 'Fragmentos';

  @override
  String get dngLootShardsDetail =>
      'Salas de tesouro e baús ao longo da corrida';

  @override
  String get dngLootItems => 'Itens';

  @override
  String dngLootItemsDetail(String tier) {
    return 'Tier de item na sua profundidade: $tier  (elites e chefes derrubam melhor)';
  }

  @override
  String get dngLootMythril => 'Mithril';

  @override
  String dngLootMythrilDetail(int a, int b) {
    return '~$a no andar 5  •  ~$b no andar 10';
  }

  @override
  String dngYourBest(int f, int m) {
    return 'Seu melhor: andar $f  •  ~$m mithril';
  }

  @override
  String get dngNoRecord => 'Sem registro ainda';

  @override
  String dngDeepestFloor(int f) {
    return 'Andar mais profundo: $f';
  }

  @override
  String dngDailyAttempts(int r, int max) {
    return 'Tentativas diárias: $r / $max';
  }

  @override
  String dngEnterTier(int tier) {
    return 'ENTRAR  TIER $tier';
  }

  @override
  String get dngNoAttempts => 'SEM TENTATIVAS RESTANTES';

  @override
  String dngBuyExtra(int cost) {
    return '$cost ZCoins — Comprar 1 tentativa extra';
  }

  @override
  String get dngBossFloor => '☠ ANDAR DO CHEFE';

  @override
  String dngBossIn(int n) {
    return '☠ Chefe em $n';
  }

  @override
  String get dngChoosePath => 'ESCOLHA SEU CAMINHO';

  @override
  String get dngNextBoss => '☠ PRÓXIMO ANDAR: CHEFE';

  @override
  String get dngMystery => 'MISTÉRIO';

  @override
  String get dngGoblin => '💰 GOBLIN DO TESOURO';

  @override
  String get dngEnter => 'ENTRAR';

  @override
  String get dngMystery1 => 'Uma porta sem marcação.';

  @override
  String get dngMystery2 => 'Sorte ou perigo?';

  @override
  String dngGoblinHp(Object hp) {
    return '$hp HP  •  foge após 5 rodadas';
  }

  @override
  String get dngGoblinReward => '6× ouro se você o matar a tempo!';

  @override
  String get dngGuaranteedDrop => 'Queda de item garantida';

  @override
  String get dngStrikesFirst => 'Ataca primeiro — muito ouro';

  @override
  String get dngDoorBlessing => 'Uma bênção...';

  @override
  String get dngDoorCurse => 'ou uma maldição?';

  @override
  String get dngMakeCamp => 'Acampar';

  @override
  String get dngRecoverHp => 'Recuperar HP';

  @override
  String get dngRareInside => 'Item raro dentro';

  @override
  String dngShardsToOpen(Object n) {
    return '$n fragmentos para abrir';
  }

  @override
  String dngPlusGold(Object g) {
    return '+$g ouro';
  }

  @override
  String dngPlusShards(Object s) {
    return '+$s fragmentos';
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
  String get dngEnemy => 'Inimigo';

  @override
  String get dngSpeedNeeds =>
      'Velocidade maior requer Speed Boost / Passe Premium.';

  @override
  String get dngTreasureFound => 'Tesouro Encontrado!';

  @override
  String get dngCursed => '✸ AMALDIÇOADO!';

  @override
  String get dngBlessed => '✧ ABENÇOADO!';

  @override
  String get dngDarkToll => 'A escuridão cobra seu preço...';

  @override
  String get dngAncientPower => 'Um poder ancestral flui por você.';

  @override
  String get dngLightShadow => 'Luz e sombra se ligam ao seu destino.';

  @override
  String get dngShrineCorrupted => 'Santuário Corrompido';

  @override
  String get dngShrineBlessed => 'Santuário Abençoado';

  @override
  String get dngShrineAncient => 'Santuário Ancestral';

  @override
  String get dngShrineCorruptedFlavor =>
      'Energias sombrias pulsam e se contorcem. Uma maldição é certa — mas o poder aguarda.';

  @override
  String get dngShrineBlessedFlavor =>
      'Uma luz divina e quente emana deste lugar. Uma bênção é garantida.';

  @override
  String get dngShrineTwinFlavor =>
      'Duas forças se agitam dentro — você receberá tanto uma bênção quanto uma maldição.';

  @override
  String get dngShrineNormalFlavor =>
      'Um santuário misterioso pulsa com energia desconhecida.\nEntre para receber uma bênção... ou uma maldição.\nVocê não saberá qual até ser tarde demais.';

  @override
  String get dngAcceptCurse => 'ACEITAR A MALDIÇÃO';

  @override
  String get dngReceiveBlessing => 'RECEBER BÊNÇÃO';

  @override
  String get dngEnterTwin => 'ENTRAR  (2 EFEITOS)';

  @override
  String get dngEnterShrine => 'ENTRAR NO SANTUÁRIO';

  @override
  String dngActiveEffects(int n) {
    return 'Efeitos ativos: $n';
  }

  @override
  String get dngSkip => 'PULAR';

  @override
  String dngGuaranteeBless(int c) {
    return '✧  GARANTIR BÊNÇÃO  ($c ◆)';
  }

  @override
  String dngTrapDamage(int dmg, int pct) {
    return 'Você sofrerá $dmg de dano ($pct% do HP máximo).';
  }

  @override
  String get dngLockedChest => 'Baú Trancado';

  @override
  String get dngChestContains => 'Contém um item raro ou épico.';

  @override
  String dngCostShards(Object cost) {
    return '$cost fragmentos';
  }

  @override
  String dngHave(int n) {
    return '(tem $n)';
  }

  @override
  String dngCostZcoins(int cost) {
    return '$cost ZCoins';
  }

  @override
  String get dngMerchantQuote =>
      '\"Ossos por bugigangas, viajante. Mais ossos, melhores mercadorias.\"';

  @override
  String dngBones(int n) {
    return '🦴  $n Ossos';
  }

  @override
  String dngBoneCost(int c) {
    return '$c 🦴';
  }

  @override
  String get dngClaimRelic => '☠ CHEFE ELIMINADO — REIVINDIQUE UMA RELÍQUIA';

  @override
  String get dngSkipDescend => 'PULAR — DESCER';

  @override
  String get dngReturn => 'VOLTAR';

  @override
  String dngDescendTo(int n) {
    return 'DESCER PARA O ANDAR $n';
  }

  @override
  String get dngFallen => '☠ Caído';

  @override
  String get dngGotAway => '💰 Ele escapou!';

  @override
  String get dngVictory => '✓ Vitória';

  @override
  String dngAmbushHit(int n) {
    return 'Golpe de emboscada causou $n antes da luta.';
  }

  @override
  String dngItemToBag(String name, String label) {
    return '✦ $name ($label) → Bolsa';
  }

  @override
  String get dngRested => '⊕ Descansado';

  @override
  String get dngTreasureCollected => '✦ Tesouro coletado';

  @override
  String get dngBlessingReceived => '✧ Bênção recebida';

  @override
  String get dngSlainTrap => '☠ Morto pela armadilha';

  @override
  String get dngTrapSurvived => '✸ Sobreviveu à armadilha';

  @override
  String get dngChestOpened => '◆ Baú aberto';

  @override
  String get dngLootAdded => 'Seu saque já foi adicionado à sua conta.';

  @override
  String dngLordFallen(int z, int g) {
    return 'O Senhor da Masmorra caiu!\n+5 mithril  •  +$z Z-Coins  •  +$g ouro  •  item bônus';
  }

  @override
  String dngTierN(int t) {
    return 'TIER $t';
  }

  @override
  String get dngFloor => 'ANDAR';

  @override
  String get dngRooms => 'SALAS';

  @override
  String get dngBosses => 'CHEFES';

  @override
  String get dngGold => 'OURO';

  @override
  String get dngShards => 'FRAGMENTOS';

  @override
  String dngTierCleared(int t) {
    return '✓ Tier $t limpo — AUTO desbloqueado!';
  }

  @override
  String get dngNewRecord => '★ Novo recorde!';

  @override
  String get dngAllLootAdded => 'Todo o saque foi adicionado à sua conta.';

  @override
  String get dngYouFallen => 'VOCÊ CAIU';

  @override
  String get dngCleared => 'MASMORRA LIMPA!';

  @override
  String get dngRunEnded => 'CORRIDA ENCERRADA';

  @override
  String get dngAutoLocked => '🔒 AUTO';

  @override
  String get dngStop => '◉ PARAR';

  @override
  String get dngAuto => '✦ AUTO';

  @override
  String get dngRunAgain => 'CORRER NOVAMENTE';

  @override
  String get dngReturnHall => 'VOLTAR AO SALÃO';

  @override
  String get auraEquipped => 'EQUIPADO';

  @override
  String get auraOn => 'ATIVADO';

  @override
  String auraCost(int n) {
    return 'Custo: $n zcoins';
  }

  @override
  String auraUnlockTitle(String name) {
    return 'Desbloquear $name?';
  }

  @override
  String get auraAllAuras => 'TODAS AS AURAS';

  @override
  String get auraAllSkins => 'TODAS AS SKINS';

  @override
  String get auraAllPets => 'TODOS OS MASCOTES';

  @override
  String get auraRemoveAura => 'Remover aura';

  @override
  String get auraRemoveSkin => 'Remover skin';

  @override
  String get auraDismissPet => 'Dispensar mascote';

  @override
  String get auraBattleCompanion => 'COMPANHEIRO DE BATALHA';

  @override
  String get auraWaystones => 'PEDRAS DE CAMINHO';

  @override
  String get auraAttackEffects => 'EFEITOS DE ATAQUE';

  @override
  String get auraCharSlots => 'SLOTS DE PERSONAGEM';

  @override
  String get auraCompanionNote =>
      'Um companheiro pode estar ativo por vez. Cada um concede um pequeno bônus passivo.';

  @override
  String get auraBeforeAfter => 'Antes / Depois';

  @override
  String get auraAllSlots => 'Todos os 12 slots desbloqueados.';

  @override
  String auraAdoptTitle(String name) {
    return 'Adotar $name?';
  }

  @override
  String auraPetBonus(String label) {
    return '✦ $label';
  }

  @override
  String get auraMaxEvolution => '★★ EVOLUÇÃO MÁXIMA';

  @override
  String auraOwned(Object count) {
    return 'Possui: $count';
  }

  @override
  String auraWaystoneDesc(Object h, String m) {
    return '${h}h  ·  $m× renda inativa';
  }

  @override
  String auraHitEvery(String text) {
    return '\"$text\" a cada acerto';
  }

  @override
  String auraSlotN(Object n) {
    return 'Slot $n';
  }

  @override
  String get auraAddSlot => 'Adicionar mais um slot de save de personagem.';

  @override
  String get auraUnlock => 'DESBLOQUEAR';

  @override
  String get auraAdopt => 'ADOTAR';

  @override
  String get auraBuy => 'COMPRAR';

  @override
  String get auraEvolve => 'EVOLUIR';

  @override
  String get auraEquip => 'EQUIPAR';

  @override
  String get auraActive => 'ATIVO';

  @override
  String get auraSendOut => 'ENVIAR';

  @override
  String get auraStackAuras =>
      'Bônus de cada aura que você POSSUI são acumulados automaticamente — você os mantém todos. Equipe uma apenas para escolher qual brilho exibir.';

  @override
  String get auraStackSkins =>
      'Bônus de cada skin que você POSSUI são acumulados automaticamente — você os mantém todos. Equipe uma apenas para escolher qual visual usar.';

  @override
  String get armTabUniques => 'ÚNICOS';

  @override
  String get armTabMythic => 'MÍTICO';

  @override
  String get armTabSets => 'ITENS DE SET';

  @override
  String get armTabArtifacts => 'ARTEFATOS';

  @override
  String get armNoLegendaries => 'Sem lendários para esta classe.';

  @override
  String armClassUniques(int count) {
    return '$count Únicos de Classe';
  }

  @override
  String get armOwned => 'POSSUI';

  @override
  String armSlotReqLevel(String slot, int lvl) {
    return '$slot  •  Nível Mín. $lvl';
  }

  @override
  String get armStats => 'ATRIBUTOS';

  @override
  String get armAbilityEnh => 'APRIMORAMENTO DE HABILIDADE';

  @override
  String armAbilityDamage(String x) {
    return '• Dano de habilidade ×$x';
  }

  @override
  String armAbilityDuration(Object n) {
    return '• +$n rodadas de duração';
  }

  @override
  String armAbilityCooldown(String v) {
    return '• $v rodadas de recarga';
  }

  @override
  String armOnCast(String desc) {
    return '• Ao usar: $desc';
  }

  @override
  String get armHowToFind => 'COMO ENCONTRAR';

  @override
  String get armDropCampaign => 'Chefes da campanha';

  @override
  String get armDropTower => 'Chefes da Ascensão da Torre';

  @override
  String get armDropBossRush => 'Corridas de Boss Rush';

  @override
  String get armDropGauntlet => 'Limpeza do Gauntlet';

  @override
  String get armRate2 => '2% por morte de chefe';

  @override
  String get armRate03 => '0,3% por morte de chefe';

  @override
  String get armRateRare => 'Drop bônus raro';

  @override
  String get armDropsClassSpecific =>
      'Drops são específicos da classe — apenas itens da sua classe podem cair.';

  @override
  String get armNoMythic => 'Sem itens Míticos ainda';

  @override
  String get armMythicHint =>
      'Derrote chefes da campanha para 0,5% de chance por morte.';

  @override
  String get armMythicItems => 'Itens Míticos';

  @override
  String armSlotLv(String slot, int lvl) {
    return '$slot  •  Nv$lvl';
  }

  @override
  String armKeyword(String name) {
    return 'palavra-chave $name';
  }

  @override
  String get armSetItemsTitle => 'Itens de Set';

  @override
  String armFraction(int a, int b) {
    return '$a / $b';
  }

  @override
  String get armEquippedLower => 'equipado';

  @override
  String get armSetBonuses => 'BÔNUS DE SET';

  @override
  String armPc(Object n) {
    return '${n}peç';
  }

  @override
  String get armUniqueBlurb =>
      'Itens únicos são vinculados à classe e melhoram dramaticamente suas habilidades. Cada um amplifica uma habilidade de classe específica. Taxa de drop: 2% por morte de chefe.';

  @override
  String get armMythicBlurb =>
      'O tier gerado proceduralmente mais raro. Itens míticos têm 3 atributos com os maiores valores possíveis e um poderoso efeito de palavra-chave. Taxa de drop: 0,5% por morte de chefe.';

  @override
  String get armSetBlurb =>
      'Colecione múltiplas peças do mesmo set para desbloquear poderosos bônus. Sets agora requerem 6 peças para o bônus completo. Taxa de drop: 0,3% por morte de chefe.';

  @override
  String armArtifactBlurb(int count) {
    return '$count sets de artefatos com três peças. Equipe 2 peças verdes correspondentes na grade de artefatos para um bônus parcial, todas as 3 para o bônus completo. Peças de set caem de Masmorras, Boss Rush e chefes da Campanha.';
  }

  @override
  String get armSetPieces => 'PEÇAS DO SET';

  @override
  String get armArtifactSets => 'Sets de Artefatos';

  @override
  String armCollected(int a, int b) {
    return 'COLETADO  $a / $b peças distintas possuídas';
  }

  @override
  String endlessStage(int n) {
    return 'Fase $n';
  }

  @override
  String endlessNextReward(int n) {
    return 'Próxima recompensa: Andar $n';
  }

  @override
  String get endlessChallengeBoss => 'DESAFIAR UM CHEFE';

  @override
  String get endlessPremiumAutoClear =>
      '🔒  Alcance a Fase 5 da campanha para derrotar chefes automaticamente';

  @override
  String get endlessRewards => 'RECOMPENSAS: ';

  @override
  String get endlessDrop => 'DROP: ';

  @override
  String get endlessGold => 'OURO';

  @override
  String get endlessXp => 'XP';

  @override
  String get endlessRespawns => 'RESPAWNS';

  @override
  String endlessTowerShards(String n) {
    return '+$n FRAGMENTOS DA TORRE';
  }

  @override
  String endlessMilestone(Object n) {
    return '★ MARCO: $n MORTES ★';
  }

  @override
  String endlessMilestoneReward(String gold, Object s) {
    return '+$gold OURO  +$s ◆';
  }

  @override
  String get endlessEnemyStirs => 'O inimigo se agita novamente...';

  @override
  String get endlessDefeatBody =>
      'Seu herói foi dominado.\nMelhore seus atributos e tente novamente.';

  @override
  String get pvpNoStamina => 'Sem stamina! Recarrega 1 a cada 45 minutos.';

  @override
  String get pvpTitle => 'ARENA PVP';

  @override
  String get pvpSimLab => 'Laboratório de Sim';

  @override
  String get pvpRefresh => 'Atualizar placar';

  @override
  String get pvpLeaderboard => 'PLACAR';

  @override
  String pvpToday(String label) {
    return 'HOJE: $label';
  }

  @override
  String pvpWinsToday(Object wins, Object dmg) {
    return '$wins vitórias hoje  •  $dmg dano total';
  }

  @override
  String get pvpClaimed => '✓ RESGATADO';

  @override
  String get pvpNoChallengers => 'SEM DESAFIANTES AINDA';

  @override
  String get pvpNoChallengersSub =>
      'Lute uma partida para entrar no placar\ne ver como você se sai.';

  @override
  String pvpHpAc(Object hp, Object ac) {
    return 'HP:$hp  AC:$ac';
  }

  @override
  String get pvpStamina => 'STAMINA  ';

  @override
  String get pvpStaminaTip => 'A stamina recupera 1 coração a cada 45 minutos.';

  @override
  String get pvpRating => 'RATING';

  @override
  String get pvpWins => 'VITÓRIAS';

  @override
  String get pvpLosses => 'DERROTAS';

  @override
  String get pvpWL => 'V/D';

  @override
  String pvpLeague(String name) {
    return 'LIGA $name';
  }

  @override
  String get pvpNearRank => 'PRÓXIMO AO SEU RANK';

  @override
  String get pvpPlayersAbove => '— jogadores logo acima de você';

  @override
  String pvpClassLv(String cls, Object lvl) {
    return '$cls  Nv$lvl';
  }

  @override
  String get pvpChallenge => 'DESAFIAR';

  @override
  String get pvpBattleLog => 'LOG DE BATALHA';

  @override
  String get pvpBattleLogTip => 'Log de batalha';

  @override
  String get pvpNoCombat => 'Sem combate ainda.';

  @override
  String get pvpClose => 'FECHAR';

  @override
  String pvpVs(String hero, String opp) {
    return 'PVP  —  $hero vs $opp';
  }

  @override
  String get pvpReturnArena => 'VOLTAR À ARENA';

  @override
  String get pvpFighting => 'Lutando...';

  @override
  String invBagCount(Object n, Object cap) {
    return '($n/$cap)';
  }

  @override
  String invBuyTab(Object cost) {
    return '+ ABA  $cost';
  }

  @override
  String get invAutoEquip => 'AUTO EQUIPAR';

  @override
  String invTabN(Object n, Object count) {
    return 'ABA $n  ($count)';
  }

  @override
  String get invEquipment => 'EQUIPAMENTO';

  @override
  String invBag(Object n, Object cap) {
    return 'BOLSA  ($n/$cap)';
  }

  @override
  String get invUnequip => 'Desequipar';

  @override
  String get invNoItems => 'Sem itens nesta aba.';

  @override
  String invReqClass(String cls) {
    return 'Requer $cls';
  }

  @override
  String invReqLevel(Object lvl) {
    return 'Requer Nível $lvl';
  }

  @override
  String invReqTier(Object t) {
    return 'Requer Tier $t';
  }

  @override
  String get invCannotEquip => 'Não Pode Equipar';

  @override
  String get invEquip => 'Equipar';

  @override
  String get invUnlock => 'Desbloquear 🔓';

  @override
  String get invLock => 'Bloquear 🔒';

  @override
  String get invDiscard => 'Descartar';

  @override
  String get invAny => 'Qualquer';

  @override
  String invUniqueOnly(String cls) {
    return '★ Único — somente $cls';
  }

  @override
  String get invWrongClass => '(classe errada)';

  @override
  String get invColStat => 'ATRIB';

  @override
  String get invColThis => 'ESTE';

  @override
  String get invColEqpd => 'EQPD';

  @override
  String get invColDiff => 'DIF';

  @override
  String get invEmptySocket => 'Encaixe Vazio';

  @override
  String get invCraftGems => 'Forje gemas em Forja → aba Gemas';

  @override
  String get invRemove => 'REMOVER';

  @override
  String get invSocket => 'ENCAIXAR';

  @override
  String invChooseGem(String name) {
    return 'Escolha uma gema para encaixar em $name';
  }

  @override
  String invOnThis(String slot, String bonus) {
    return 'Neste(a) $slot: $bonus';
  }

  @override
  String get invRemoveGem => 'Remover Gema?';

  @override
  String get invDestroy => 'DESTRUIR';

  @override
  String get invSort => 'Ordenar:';

  @override
  String get invFilter => 'Filtrar:';

  @override
  String invGemsAvailable(Object count) {
    return '$count gema(s) disponível(is) para encaixar';
  }

  @override
  String invRemoveBody(String name) {
    return '$name será destruída. Gemas não podem ser recuperadas após removidas.';
  }

  @override
  String invReplaceBody(String old, String gnew) {
    return '$old será destruída e substituída por $gnew.';
  }

  @override
  String get npcRoster => 'ELENCO';

  @override
  String get npcSynergies => 'SINERGIAS';

  @override
  String get npcTitle => 'MERCENÁRIOS';

  @override
  String get npcTotalBonuses => 'BÔNUS ATIVOS TOTAIS';

  @override
  String get npcBattleParty => 'GRUPO DE BATALHA';

  @override
  String npcFielded(Object count, Object max) {
    return '$count / $max em campo';
  }

  @override
  String get npcUnknown => 'Mercenário Desconhecido';

  @override
  String npcBattleAbility(String name) {
    return 'HABILIDADE DE BATALHA: $name';
  }

  @override
  String npcUnlock(String label) {
    return 'Desbloquear: $label';
  }

  @override
  String npcProgress(Object a, Object b) {
    return '$a / $b';
  }

  @override
  String npcLvTalent(Object n) {
    return 'TALENTO NV $n';
  }

  @override
  String npcChosen(String name) {
    return 'ESCOLHIDO: $name';
  }

  @override
  String get npcMilestoneComplete => 'MARCO COMPLETO — RECRUTANDO...';

  @override
  String get npcMax => '★ MÁX';

  @override
  String get npcStarRank => 'RANK DE ESTRELAS';

  @override
  String npcStars(Object a, Object b) {
    return '$a / $b';
  }

  @override
  String get npcFullyAscended =>
      '★ TOTALMENTE ASCENDIDO — cada estrela adiciona +1 nível efetivo.';

  @override
  String npcAscendStar(Object n) {
    return 'ASCENDER ★$n';
  }

  @override
  String npcYouHave(Object n) {
    return 'Você tem: $n Mithril';
  }

  @override
  String get npcStarInfo =>
      'Cada estrela = +1 nível efetivo do bônus deste mercenário.';

  @override
  String get npcPassiveOnly => 'Apenas bônus passivos — sempre ativo.';

  @override
  String npcCostShards(Object n) {
    return 'Custo: ◆ $n Fragmentos';
  }

  @override
  String get npcTutorial =>
      'Mercenários são companheiros que se juntam permanentemente ao atingir certos marcos. 🤝 Cada um fornece bônus passivos de combate em cada batalha e pode se sinergizar com outros para poder extra.';

  @override
  String npcRecruited(Object a, Object b) {
    return '$a / $b  recrutados';
  }

  @override
  String get npcNoMercs =>
      'Nenhum mercenário recrutado ainda. Cumpra marcos para desbloqueá-los.';

  @override
  String npcChipDamage(Object n) {
    return '+$n% Dano';
  }

  @override
  String npcChipAc(Object n) {
    return '+$n% AC';
  }

  @override
  String npcChipShards(Object n) {
    return '+$n% Fragmentos';
  }

  @override
  String npcChipHp(Object n) {
    return '+$n% HP';
  }

  @override
  String get shopTabBundles => 'PACOTES';

  @override
  String get shopTabVip => 'VIP';

  @override
  String get shopTabStarter => 'INICIANTE';

  @override
  String get shopTabResources => 'RECURSOS';

  @override
  String get shopTabCosmetics => 'COSMÉTICOS';

  @override
  String get shopSecBundles => 'PACOTES DE ZCOINS';

  @override
  String get shopSecBundlesSub => 'Moeda premium para a Loja';

  @override
  String get shopSecVip => 'ASSINATURAS VIP';

  @override
  String get shopSecVipSub => 'Vantagens e benefícios recorrentes';

  @override
  String get shopSecStarter => 'PACOTES INICIANTES';

  @override
  String get shopSecStarterSub => 'Pacotes de compra única';

  @override
  String get shopSecResources => 'RECURSOS';

  @override
  String get shopSecResourcesSub => 'Gaste ZCoins em ouro e materiais';

  @override
  String get shopSecAuras => 'AURAS';

  @override
  String get shopSecAurasSub =>
      'Equipe um brilho — bônus de auras possuídas sempre acumulam';

  @override
  String get shopSecBoosts => 'POTENCIADORES';

  @override
  String get shopSecBoostsSub => 'Potenciadores permanentes de atributos';

  @override
  String get shopSecTitles => 'TÍTULOS';

  @override
  String get shopSecTitlesSub => 'Um rank exibido abaixo do seu nome';

  @override
  String get shopSecColours => 'CORES DO NOME';

  @override
  String get shopSecColoursSub => 'Cor + brilho para o nome do seu herói';

  @override
  String get shopSecFrames => 'MOLDURAS';

  @override
  String get shopSecFramesSub => 'Uma moldura ao redor do retrato do seu herói';

  @override
  String get shopSecSlots => 'SLOTS DE PERSONAGEM';

  @override
  String get shopSecSlotsSub => 'Slots extras de save de personagem';

  @override
  String get shopPremiumArmor => 'ARMADURA DE CLASSE PREMIUM';

  @override
  String shopEndgameSkin(String cls) {
    return '$cls · Skin endgame';
  }

  @override
  String get shopIncludedBonuses => 'BÔNUS INCLUÍDOS';

  @override
  String get shopEverySkin => 'bônus de cada skin da loja, combinados';

  @override
  String get shopEquippedCheck => '✓ EQUIPADO';

  @override
  String get shopUnequip => 'DESEQUIPAR';

  @override
  String shopUnlockPrice(String price) {
    return 'DESBLOQUEAR  ·  $price';
  }

  @override
  String get shopStoreUnavailable =>
      'Loja indisponível — tente novamente mais tarde.';

  @override
  String get shopVipSub => 'ASSINATURA VIP';

  @override
  String get shopSubscribed => '✓ ASSINADO';

  @override
  String shopSubscribe(String price) {
    return 'ASSINAR  $price';
  }

  @override
  String get shopEverythingPlus => 'Tudo no Pacto do Vanguarda, mais:';

  @override
  String get shopIncludedPerks => 'VANTAGENS INCLUÍDAS';

  @override
  String get shopGlow => '✦ BRILHO';

  @override
  String get shopExclusive => 'EXCLUSIVO';

  @override
  String get shopNoAd =>
      'Nenhum anúncio disponível agora — tente novamente mais tarde.';

  @override
  String get shopWatchAd => 'Assistir um Anúncio';

  @override
  String get shopComeBackTomorrow => 'Volte amanhã para mais ZCoins grátis!';

  @override
  String get shopWait => 'AGUARDE...';

  @override
  String get shopWatch => 'ASSISTIR';

  @override
  String get shopRewardEarned => 'RECOMPENSA CONQUISTADA';

  @override
  String shopPlusZcoins(Object amount) {
    return '+$amount ZCoins';
  }

  @override
  String get shopCollect => 'COLETAR';

  @override
  String get shopPurchasesRestored =>
      'Compras restauradas. Quaisquer assinaturas ativas ou pacotes foram reaplicados.';

  @override
  String get shopRestorePurchases => 'Restaurar Compras';

  @override
  String artSalvageTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Salvar $count artefatos?',
      one: 'Salvar $count artefato?',
    );
    return '$_temp0';
  }

  @override
  String get artSalvage => 'SALVAR';

  @override
  String artSalvaged(int n, Object gained) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Salvados $n artefatos por ◆ $gained mithril.',
      one: 'Salvado $n artefato por ◆ $gained mithril.',
    );
    return '$_temp0';
  }

  @override
  String get artTable => 'MESA DE ARTEFATOS';

  @override
  String artSlots(Object n, Object max) {
    return '$n/$max slots';
  }

  @override
  String artAutoEquipped(Object n) {
    return '$n melhores artefatos equipados automaticamente.';
  }

  @override
  String get artNoneToEquip => 'Sem artefatos para equipar.';

  @override
  String get artAutoEquip => '⚡ AUTO-EQUIPAR';

  @override
  String get artSalvageBtn => '♻ SALVAR';

  @override
  String get artTitle => 'ARTEFATOS';

  @override
  String get artPlaceHint => 'Coloque artefatos na mesa para ganhar bônus.';

  @override
  String get artTableBonuses => 'BÔNUS DA MESA';

  @override
  String get artCollection => 'COLEÇÃO';

  @override
  String artCount(Object n) {
    return '($n)';
  }

  @override
  String artTapToPlace(String name) {
    return 'Toque em uma célula da grade para colocar \"$name\"';
  }

  @override
  String get artTapCancel => 'toque novamente para cancelar';

  @override
  String get artSet => 'SET';

  @override
  String artUpgradeCost(Object cost) {
    return '$cost Mithril';
  }

  @override
  String artNoSets(Object n) {
    return 'Sem peças de Set equipadas ainda — $n sets para descobrir.';
  }

  @override
  String artCountOf3(Object count) {
    return '$count / 3';
  }

  @override
  String get artHowToGet => 'COMO OBTER ARTEFATOS';

  @override
  String get artRowCampaign => 'Chefes da Campanha';

  @override
  String get artRowCampaignDesc =>
      'cerca de 25% de chance de cair em cada morte de chefe.';

  @override
  String get artRowDungeon => 'Corridas de Masmorra';

  @override
  String get artRowDungeonDesc =>
      'cada chefe derrotado cai um — até 2 por corrida. Melhor farm constante.';

  @override
  String get artRowBossRush => 'Boss Rush';

  @override
  String get artRowBossRushDesc =>
      'limpe uma corrida com rank A ou S para ganhar um artefato.';

  @override
  String artSalvageBody(int count, Object mythril) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Destruir permanentemente todos os $count artefatos não equipados por ◆ $mythril mithril? Artefatos equipados são mantidos.',
      one:
          'Destruir permanentemente $count artefato não equipado por ◆ $mythril mithril? Artefatos equipados são mantidos.',
    );
    return '$_temp0';
  }

  @override
  String get artSetBlurb =>
      'Colete peças de Set verdes correspondentes. 2 equipadas = bônus parcial, todas 3 = bônus completo.';

  @override
  String get art2Set => '2-Set';

  @override
  String get art3Set => '3-Set';

  @override
  String get ptEssence => 'essência';

  @override
  String ptTheClass(String cls) {
    return 'O $cls';
  }

  @override
  String ptRespecBranch(String branch) {
    return 'Redirecionar $branch?';
  }

  @override
  String ptRefund(Object refund) {
    return 'Reembolsar $refund essência (75%)';
  }

  @override
  String get ptRespec => 'Redirecionar';

  @override
  String get ptCrossBranch => 'CRUZAMENTO';

  @override
  String get ptFullRespec => 'Redirecionamento Completo?';

  @override
  String get ptRespec50 => 'Redirecionar (50 ZC)';

  @override
  String get ptFullRespecBtn => 'REDIRECIONAMENTO COMPLETO (50 ZC)';

  @override
  String get ptTitle => 'ÁRVORE PASSIVA';

  @override
  String get ptNow => 'AGORA';

  @override
  String ptUpgradeCost(Object cost) {
    return 'MELHORAR  ($cost ✦)';
  }

  @override
  String get ptLocked => 'BLOQUEADO — gaste 25 ranks em mais ramos';

  @override
  String get ptLockedMax =>
      'BLOQUEADO — maximize todos os nós do ramo primeiro';

  @override
  String ptMaxRankTotal(String val) {
    return 'RANK MÁX — $val total';
  }

  @override
  String ptFullRespecBody(Object refund) {
    return 'Resetar TODOS os nós passivos.\nReembolsar $refund essência (60%).\nCusto: 50 zcoins.';
  }

  @override
  String ptNodesUnlocked(Object count) {
    return '$count nós desbloqueados';
  }

  @override
  String get ptTutorial =>
      'Você ganhou Fragmentos ◆ — gaste-os aqui em nós passivos permanentes que nunca são resetados. Seu ramo de classe fica no topo. Cada nó sobe até o rank 5 para bônus maiores.';

  @override
  String ptBranchesAt25(Object count) {
    return '$count / 5 ramos no 25';
  }

  @override
  String get homeExp => 'EXP';

  @override
  String get homeResources => 'Recursos';

  @override
  String get homeGold => 'OURO';

  @override
  String get homeShards => 'FRAGMENTOS';

  @override
  String get homeZcoins => 'ZCOINS';

  @override
  String get homeMythril => 'MITHRIL';

  @override
  String get homeIdleMin => 'INATIVO/min';

  @override
  String get homeGoldTip =>
      'Ouro\nGanho em batalhas e renda inativa.\nGaste em Melhorias e na Loja.';

  @override
  String get homeShardsTip =>
      'Fragmentos\nGanhos de mortes de inimigos, Masmorras, Expedições e Gauntlet.\nGaste em melhorias de habilidades, melhorias de itens e nós da Árvore Passiva.';

  @override
  String get homeZcoinsTip =>
      'ZCoins\nGanhos de conquistas e baús diários.\nGaste na Loja de Auras por skins, mascotes e auras.';

  @override
  String get homeMythrilTip =>
      'Mithril\nGanho de Masmorras, Boss Rush e marcos de prestígio.\nGaste em melhorias de Artefatos, rerolls de afixos de masmorra e bênçãos de santuário.';

  @override
  String get homeIdleTip =>
      'Ouro Inativo / min\nOuro ganho automaticamente a cada minuto enquanto offline.\nAumenta com o nível do herói, melhorias passivas e mascotes.';

  @override
  String get homeCurrentCampaign => 'Campanha Atual';

  @override
  String homeStage(Object n) {
    return 'FASE $n';
  }

  @override
  String homeNextGoal(Object reward) {
    return 'PRÓXIMO: DESBLOQUEAR $reward';
  }

  @override
  String homeNextGoalProgress(Object remaining, Object stage) {
    return 'Faltam $remaining fases — vença a Fase $stage';
  }

  @override
  String get demoModeLocked =>
      'Desbloqueado no jogo completo. A demo inclui a campanha completa — obtenha o jogo completo para Masmorras, PvP e os níveis de dificuldade do endgame.';

  @override
  String get demoFullGameCta => 'OBTER O JOGO COMPLETO';

  @override
  String get homeSecCombat => 'COMBATE';

  @override
  String get homeSecSocial => 'SOCIAL';

  @override
  String get homeNavChallengeGauntlet => 'DESAFIO GAUNTLET';

  @override
  String get homeNavBountyBoard => 'QUADRO DE RECOMPENSAS';

  @override
  String get homeNavSeasonPass => 'PASSE DE TEMPORADA';

  @override
  String get homeNavWorldEvent => 'EVENTO MUNDIAL';

  @override
  String get homeNavLeaderboard => 'PLACAR';

  @override
  String get homeNavChallengeModifiers => 'MODIFICADORES DE DESAFIO';

  @override
  String get homeQuickAccess => 'ACESSO RÁPIDO';

  @override
  String get homeGettingStarted => 'PRIMEIROS PASSOS';

  @override
  String get homeStep1 => 'Vença sua primeira batalha da Campanha';

  @override
  String get homeStep2 =>
      'Suba de nível com seu herói — visite a Ficha do Personagem';

  @override
  String get homeStep3 =>
      'Abra HERÓI e compre sua primeira melhoria de Atributo';

  @override
  String get homeStep4 =>
      'Alcance a Fase 5 — Habilidades e Desafios Diários são desbloqueados!';

  @override
  String get homeHeroSubtitle => 'MELHORIAS  •  ARSENAL  •  ALIADOS  •  CÓDEX';

  @override
  String get homeTomorrow => 'Amanhã: ';

  @override
  String get dailyWeekly => 'SEMANAL';

  @override
  String get dailyClaimAll => 'RESGATAR TUDO';

  @override
  String get dailyHowItWorks => 'Como Funciona';

  @override
  String get dailyThisWeek => 'DESAFIOS DESTA SEMANA';

  @override
  String dailyCompleted(Object claimed, Object total) {
    return '$claimed / $total concluídos';
  }

  @override
  String get dailyWeeklyLoading => 'Desafios semanais carregando...';

  @override
  String get dailyAboutWeekly => 'Sobre Desafios Semanais';

  @override
  String get dailyReady => 'PRONTO';

  @override
  String get dailyTodayProgress => 'PROGRESSO DE HOJE';

  @override
  String get dailyChest => 'BAÚ DIÁRIO';

  @override
  String get dailyClaimedTomorrow => 'Resgatado! Volte amanhã.';

  @override
  String get dailyHintKill => 'Matar inimigos';

  @override
  String get dailyHintKillD => 'Lute em modo Campanha ou Infinito';

  @override
  String get dailyHintWin => 'Vencer batalhas';

  @override
  String get dailyHintWinD => 'Derrotar um inimigo conta como vitória';

  @override
  String get dailyHintBoss => 'Derrotar chefe';

  @override
  String get dailyHintBossD => 'Fase 5, 10, 15, 20, 25 ou Infinito a cada 5ª';

  @override
  String get dailyHintAbility => 'Usar habilidades';

  @override
  String get dailyHintAbilityD =>
      'Habilidades ativas disparam automaticamente em batalha';

  @override
  String get dailyHintEquip => 'Equipar item';

  @override
  String get dailyHintEquipD =>
      'Toque em um item da bolsa → Equipar no Inventário';

  @override
  String get dailyHintGold => 'Alcançar ouro';

  @override
  String get dailyHintGoldD =>
      'Apenas tenha essa quantidade de ouro no seu estoque';

  @override
  String get dailyHintDamage => 'Causar dano';

  @override
  String get dailyHintDamageD => 'Dano cumulativo causado em qualquer modo';

  @override
  String get dailyHintIdle => 'Coletar inativo';

  @override
  String get dailyHintIdleD => 'Toque na recompensa inativa na tela inicial';

  @override
  String get dailyHintResets => 'Resets';

  @override
  String get dailyHintResetsD =>
      'Toda segunda-feira — 5 novos desafios por semana';

  @override
  String get dailyHintRewards => 'Recompensas';

  @override
  String get dailyHintRewardsD =>
      'Maiores que as diárias: essência, mithril, ZCoins';

  @override
  String get dailyHintSeasonXp => 'XP de Temporada';

  @override
  String get dailyHintSeasonXpD =>
      '+50 XP de temporada por desafio semanal resgatado';

  @override
  String get dailyHintProgress => 'Progresso';

  @override
  String get dailyHintProgressD =>
      'Conta desde meia-noite de segunda, não desde o resgate';

  @override
  String get dailyTutorial =>
      'Complete desafios diários para ganhar ouro, fragmentos, essência e ZCoins. Todos os 7 desafios são resetados a cada dia. Complete todos para um baú bônus!';

  @override
  String petOwned(Object a, Object b) {
    return '$a / $b  possuídos';
  }

  @override
  String get petTitle => 'COMPANHEIROS';

  @override
  String get petActiveBonuses => 'BÔNUS ATIVOS (todos os mascotes possuídos)';

  @override
  String get petNoCompanion => 'Nenhum companheiro equipado';

  @override
  String get petEquipHint => 'Equipe um mascote para que apareça em batalha.';

  @override
  String get petPremium => '★ PREMIUM';

  @override
  String get petInBattle => 'EM BATALHA';

  @override
  String petRecruitTitle(String name) {
    return 'Recrutar $name?';
  }

  @override
  String get petRecruit => 'RECRUTAR';

  @override
  String petEvolveTitle(String name) {
    return 'Evoluir $name?';
  }

  @override
  String petEvolveN(Object n) {
    return 'EVOLUIR  Evo $n';
  }

  @override
  String get petTutorial =>
      'Mascotes companheiros se juntam a você em batalha e acumulam seus bônus passivamente — até os não equipados. Equipe um para que apareça ao seu lado durante as lutas. Evolua mascotes possuídos duas vezes para dobrar o valor do bônus.';

  @override
  String petRecruitBody(String desc, String bonus, Object cost) {
    return '$desc\n\nBônus: $bonus\n\nCusto: $cost ZCoins';
  }

  @override
  String petEvolveBody(Object level, String bonus, Object cost) {
    return 'Melhore para Evolução $level.\n\nNovo bônus: +$bonus\nCusto: $cost ZCoins';
  }

  @override
  String get questTitle => 'MISSÕES';

  @override
  String get questAdventure => 'MISSÃO DE AVENTURA';

  @override
  String get questAdventureSub =>
      'Aprenda cada sistema do jogo no caminho até a fase 100.';

  @override
  String questUnlocksLv30(Object lvl) {
    return 'Desbloqueia no Nível 30  (atual: $lvl)';
  }

  @override
  String get questUltUnlocked => 'HABILIDADE SUPREMA DESBLOQUEADA';

  @override
  String questUltAvailable(String cls) {
    return 'A suprema de $cls está agora disponível em batalha.';
  }

  @override
  String get questProgressLabel => 'Progresso';

  @override
  String questCompleteFirst(Object n) {
    return 'Complete a missão $n primeiro para desbloquear.';
  }

  @override
  String get questClaimReward => 'RESGATAR RECOMPENSA';

  @override
  String get questRewardLabel => 'Recompensa: ';

  @override
  String questClassQuestline(String cls) {
    return 'MISSÕES DE $cls';
  }

  @override
  String get questComplete5 =>
      'Complete 5 missões para desbloquear a Habilidade Suprema.';

  @override
  String get subTitle => 'ESPECIALIZAÇÃO';

  @override
  String get subLevel50 => 'ESPECIALIZAÇÃO NÍVEL 50';

  @override
  String subChooseBody(String cls, Object cost) {
    return 'Escolha uma especialização para seu(sua) $cls. Ela concede um bônus final poderoso mais bônus de atributos, aplicados imediatamente. Você pode alterar depois por $cost ZCoins.';
  }

  @override
  String subClassSpecs(String cls, Object n) {
    return 'ESPECIALIZAÇÕES DE $cls  ($n)';
  }

  @override
  String subUnlocksAt(Object lvl) {
    return 'Especialização desbloqueia no Nível $lvl.';
  }

  @override
  String subChooseTitle(String name) {
    return 'Escolher $name?';
  }

  @override
  String get subStatBonuses => 'BÔNUS DE ATRIBUTOS';

  @override
  String get subCapstone => 'BÔNUS FINAL';

  @override
  String get subSpecialEffect => 'EFEITO ESPECIAL';

  @override
  String subChangeLater(Object cost) {
    return 'Você pode alterar depois por $cost ZCoins.';
  }

  @override
  String get subCouldNotSet =>
      'Não foi possível definir especialização — tente novamente.';

  @override
  String subChangeSpec(Object cost) {
    return 'ALTERAR ESPECIALIZAÇÃO  —  $cost ZCoins';
  }

  @override
  String get subChangeTitle => 'Alterar especialização?';

  @override
  String subChangeBody(Object cost, Object zcoins) {
    return 'Gastar $cost ZCoins para limpar sua especialização atual e escolher uma nova?\n\nSeus ZCoins: $zcoins';
  }

  @override
  String get subNotEnough => 'ZCoins insuficientes para redirecionar.';

  @override
  String get subActiveSubclass => 'SUBCLASSE ATIVA';

  @override
  String get subChosen => 'ESCOLHIDA';

  @override
  String get subActive => 'ATIVA';

  @override
  String get subChoosePath => 'ESCOLHER ESTE CAMINHO';

  @override
  String get expTitle => 'EXPEDIÇÕES';

  @override
  String get expCollectAll => 'COLETAR TUDO';

  @override
  String get expDispatchAll => 'DESPACHAR TODOS';

  @override
  String get expNoMercs => 'Sem Mercenários Ainda';

  @override
  String get expNoMercsSub =>
      'Recrute mercenários na aba MERCENÁRIOS no Hub do Herói para enviá-los em expedições.';

  @override
  String get expTodayLocations => 'LOCAIS DE HOJE';

  @override
  String expRefreshIn(String time) {
    return '🔄 $time';
  }

  @override
  String get expYourParty => 'SEU GRUPO';

  @override
  String get expDispatch => 'DESPACHAR';

  @override
  String get expDone => 'CONCLUÍDO';

  @override
  String get expCollectRewards => 'COLETAR RECOMPENSAS';

  @override
  String get expInProgress => 'EM ANDAMENTO...';

  @override
  String expReturned(String name) {
    return '$name retornou!';
  }

  @override
  String get expDiscovery => '✦  DESCOBERTA';

  @override
  String get expGreat => 'ÓTIMO';

  @override
  String expDispatchMerc(String name) {
    return 'DESPACHAR $name';
  }

  @override
  String get expChooseLocation => 'ESCOLHER LOCAL';

  @override
  String get expDuration => 'DURAÇÃO';

  @override
  String get expEstRewards => 'RECOMPENSAS ESTIMADAS';

  @override
  String get expSend => 'ENVIAR EM EXPEDIÇÃO';

  @override
  String get acctSignInFailed => 'Login cancelado ou falhou.';

  @override
  String get acctSignOutTitle => 'Sair?';

  @override
  String get acctSignOut => 'Sair';

  @override
  String get acctSignOutBody =>
      'Seu save local é mantido. A sincronização na nuvem será pausada até você entrar novamente.';

  @override
  String get acctDeleteTitle => 'Deletar conta e dados?';

  @override
  String get acctDeleteAll => 'DELETAR TUDO';

  @override
  String get acctDeleteBody =>
      'Isso deleta permanentemente sua conta e TODOS os dados — cada personagem, seu save na nuvem, posição no PvP e entradas no placar. Isso não pode ser desfeito.';

  @override
  String get acctDeleted => 'Conta deletada';

  @override
  String get acctDeletedBody =>
      'Sua conta e todos os dados foram removidos. O app agora fechará.';

  @override
  String get acctClose => 'Fechar';

  @override
  String get acctPlayer => 'Jogador';

  @override
  String get acctSyncNow => 'SINCRONIZAR AGORA';

  @override
  String get acctSignOutBtn => 'SAIR';

  @override
  String get acctSignInGoogle => 'ENTRAR COM GOOGLE';

  @override
  String get acctDeleteAccount => 'DELETAR CONTA';

  @override
  String get acctDangerSub =>
      'Deletar permanentemente sua conta e todos os dados associados.';

  @override
  String get acctLinked => 'Conta Google vinculada';

  @override
  String get acctNotSynced => 'Não sincronizado nesta sessão ainda';

  @override
  String get acctNoAccount => 'Nenhuma conta vinculada';

  @override
  String get acctAboutCloud => 'SOBRE SAVES NA NUVEM';

  @override
  String get acctCloud1 =>
      'Seu progresso sincroniza automaticamente a cada 5 minutos quando conectado.';

  @override
  String get acctCloud2 =>
      'Jogue em qualquer dispositivo Windows com a mesma conta Google.';

  @override
  String get acctCloud3 =>
      'Os saves na nuvem são armazenados com segurança com sua conta Google.';

  @override
  String get invhTabGear => 'EQUIPAMENTO';

  @override
  String get invhTabGems => 'GEMAS';

  @override
  String get invhTabRunes => 'RUNAS';

  @override
  String get invhArcaneDust => 'Pó Arcano';

  @override
  String invhBag(Object n, Object max) {
    return 'Bolsa: $n/$max';
  }

  @override
  String get invhCraftGem => 'FORJAR GEMA';

  @override
  String invhCraftTypeGem(String type, Object cost) {
    return 'FORJAR GEMA $type  ($cost Pó Arcano)';
  }

  @override
  String get invhOwnedGems => 'GEMAS POSSUÍDAS';

  @override
  String invhDismantleBody(String bonus, Object dust) {
    return '$bonus\n\nEncaixe em uma ARMA para +%DMG, ou ARMADURA para +%RES deste elemento da gema.\n\nDesmontar retorna $dust Pó Arcano.';
  }

  @override
  String invhDismantle(Object dust) {
    return 'DESMONTAR (+$dust Pó Arcano)';
  }

  @override
  String invhGemTooltip(String name, String bonus) {
    return '$name\n$bonus\nToque para desmontar';
  }

  @override
  String get invhTutGear =>
      'Sua primeira peça de equipamento caiu! Equipe-a aqui para aumentar seus atributos.';

  @override
  String get invhTutForge =>
      'Combine dois itens do mesmo slot para forjar uma peça de raridade maior, ou reforgear atributos.';

  @override
  String get invhTutRunes =>
      'Forje Runas para buffs temporários de combate. Colete pó desmontando equipamentos.';

  @override
  String get invhTutArtifacts =>
      'Coloque artefatos na grade para bônus passivos permanentes.';

  @override
  String get invhNoGear =>
      'Sem equipamento ainda.\nDerrote inimigos para encontrar seu primeiro item!';

  @override
  String get ascTitle => 'ASCENSÃO';

  @override
  String get ascMetaBoard => 'META-TABULEIRO';

  @override
  String ascApPoints(Object points) {
    return '$points AP';
  }

  @override
  String get ascLevelLabel => 'Nível de Ascensão: ';

  @override
  String get ascPrestigeLabel => 'Nível de Prestígio: ';

  @override
  String get ascBody =>
      'A Ascensão é o reset mais profundo — ela converte seus Renascimentos em Pontos de Ascensão (AP). Você ganha 1 AP por cada Renascimento sacrificado, então quanto mais você acumular antes de ascender, maior o pagamento.\n\nGaste AP de duas formas — ambas permanentes e sobrevivem a todos os resets futuros:\n• O Meta-Tabuleiro abaixo (XP, ouro, dano, bônus inativo e de prestígio)\n• Ascenda suas habilidades de classe na tela de Habilidades (+10% de poder por tier, até 60 AP por personagem)\n\nVocê MANTÉM:  Bônus de Ascensão e AP gasto, Artefatos, Mithril, Fragmentos da Torre, Maestria Elemental.\nVocê PERDE:  todos os Renascimentos, nível do herói, ouro, equipamentos, subclasse, ranks de habilidades e progresso da campanha.';

  @override
  String ascRequires(Object prestige) {
    return 'Requer Nível de Prestígio 5 para Ascender  (atual: $prestige/5)';
  }

  @override
  String ascAscendAp(Object ap) {
    return 'ASCENDER  (+$ap AP)';
  }

  @override
  String get ascConfirmTitle => 'Ascender?';

  @override
  String ascConfirmBody(Object rebirths, Object ap) {
    return 'Sacrificar $rebirths Renascimento(s) por $ap Ponto(s) de Ascensão.\n\nMANTER: Bônus de Ascensão, Artefatos, Mithril, Fragmentos da Torre, Ascensões de Habilidade.\nPERDER: todos os Renascimentos, nível do herói, ouro, equipamentos, subclasse, ranks de habilidades, progresso da campanha.\n\nIsso não pode ser desfeito.';
  }

  @override
  String get weOmegaShop => 'LOJA ÔMEGA';

  @override
  String get weNowHunting => 'CAÇANDO AGORA';

  @override
  String get weDamageLabel => 'Dano: ';

  @override
  String weEndsIn(Object d, Object h, Object m) {
    return 'Evento termina em  ${d}d ${h}h ${m}m';
  }

  @override
  String get weHowToEarn => 'COMO GANHAR TOKENS';

  @override
  String weHowToEarnDesc(String name) {
    return '${name}s têm 15% de chance de aparecer durante qualquer batalha. Derrote-os por 1–3 Tokens de Evento cada.';
  }

  @override
  String get weEventBoss => '⚔ CHEFE DO EVENTO';

  @override
  String get weClaimLegendary =>
      'RESGATAR EQUIPAMENTO LENDÁRIO  (1 🏆 Token de Chefe)';

  @override
  String weGearForged(String name, Object lv) {
    return '$name forjado no Nv$lv! Verifique sua bolsa.';
  }

  @override
  String weRewardClaimed(String name) {
    return '$name resgatado!';
  }

  @override
  String get gauLeaderboard => 'Placar do Gauntlet';

  @override
  String get gauRewardPreview => 'PRÉVIA DE RECOMPENSA (ao limpar)';

  @override
  String get gauAutoRestart => 'AUTO — reiniciando com seus modificadores—';

  @override
  String get gauBackToGauntlet => 'VOLTAR AO GAUNTLET';

  @override
  String gauWave(Object n, Object total) {
    return 'ONDA $n / $total';
  }

  @override
  String gauKills(Object kills) {
    return '$kills MORTES';
  }

  @override
  String gauEssenceBonus(Object pct) {
    return '+$pct% essência';
  }

  @override
  String get brLeaderboard => 'Placar do Boss Rush';

  @override
  String get brBestScore => 'MELHOR PONTUAÇÃO: ';

  @override
  String brBossProgress(Object n, Object total) {
    return 'CHEFE $n / $total';
  }

  @override
  String get brPlayAgain => 'JOGAR NOVAMENTE';

  @override
  String get brPossibleRewards => 'RECOMPENSAS POSSÍVEIS';

  @override
  String get brRewShards => 'Fragmentos';

  @override
  String get brRewShardsD => '10 por chefe  ·  +30 na limpeza completa';

  @override
  String get brRewEchoes => 'Ecos';

  @override
  String get brRewEchoesD => '6 por chefe  ·  +25 na limpeza completa';

  @override
  String get brRewZcoins => 'ZCoins';

  @override
  String get brRewZcoinsD => '15 em uma limpeza completa';

  @override
  String get brRewMythril => 'Mithril';

  @override
  String get brRewMythrilD => 'Escalado pelo rank final';

  @override
  String get brRewArtifact => 'Artefato';

  @override
  String get brRewArtifactD => 'Drop de chance em limpezas de rank A / S';

  @override
  String get prgShop => 'LOJA PÁRAGON';

  @override
  String get prgActiveBonuses => 'BÔNUS ATIVOS';

  @override
  String get prgBoard => '✦ TABULEIRO PÁRAGON';

  @override
  String get prgBoardHint =>
      'Invista pontos em uma direção — os ranks escalam para sempre.';

  @override
  String prgRank(Object rank) {
    return 'Rank $rank';
  }

  @override
  String get prgTutorial =>
      '✦ Pontos de Páragon são ganhos subindo de nível — 1 por nível. Gaste-os no Tabuleiro Páragon e na Loja abaixo para poder permanente que nunca é resetado.';

  @override
  String get prgShopSub =>
      'Gaste Pontos de Páragon em melhorias permanentes que persistem em todas as corridas futuras.';

  @override
  String achClaimedTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🏆  $count CONQUISTAS RESGATADAS',
      one: '🏆  $count CONQUISTA RESGATADA',
    );
    return '$_temp0';
  }

  @override
  String get achYouReceived => 'Você recebeu:';

  @override
  String get achNice => 'ÓTIMO!';

  @override
  String achClaimAll(Object n) {
    return 'RESGATAR TUDO ($n)';
  }

  @override
  String get achEconomy => 'ECONOMIA E SISTEMAS';

  @override
  String get achProgress => 'PROGRESSO';

  @override
  String achClaimed(Object claimed, Object total) {
    return '$claimed / $total resgatadas';
  }

  @override
  String achReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conquistas prontas para resgatar!',
      one: '$count conquista pronta para resgatar!',
    );
    return '$_temp0';
  }

  @override
  String get runeTitle => 'RUNAS DE HABILIDADE';

  @override
  String get runeArcaneDust => '🌀 Pó Arcano: ';

  @override
  String runeOwned(Object a, Object b) {
    return '📜 Possuídas: $a/$b';
  }

  @override
  String get runeNone => 'Sem runas disponíveis para esta classe.';

  @override
  String get runeAppBar => 'RUNAS';

  @override
  String get runeSocketed => 'ENCAIXADA';

  @override
  String get runeNotFound =>
      'Ainda não encontrada — cai de chefes, masmorras, gauntlet e expedições.';

  @override
  String get runeEquipFirst =>
      'Equipe um anel ou amuleto para encaixar esta runa.';

  @override
  String runeSocketInto(String name, Object cost) {
    return 'Encaixar → $name  (🌀 $cost)';
  }

  @override
  String get runeBody =>
      'Encaixe runas para melhorar permanentemente suas habilidades.\nCada runa modifica uma habilidade específica — aumentando dano, duração ou recarga.\nCusta Pó Arcano de desencantamento de equipamentos, gemas e runas.';

  @override
  String get achTutorial =>
      'Você derrotou seu primeiro chefe! 🏆 Conquistas rastreiam marcos e recompensam ZCoins e Fragmentos — resgate-as aqui e volte frequentemente.';

  @override
  String get bbLocked => 'RECOMPENSAS DE CHEFE BLOQUEADAS';

  @override
  String get bbLockedSub =>
      'Alcance a fase 20 da campanha para começar a caçar chefes por recompensas.';

  @override
  String bbTitle(Object t) {
    return 'RECOMPENSAS DE CHEFE  •  TIER $t';
  }

  @override
  String get bbDesc =>
      'Mate cada chefe da campanha por sua recompensa. Alcance um novo tier para um novo conjunto com recompensas maiores.';

  @override
  String get bbNoBounties => 'Sem recompensas disponíveis.';

  @override
  String bbStageLv(Object n, Object lv) {
    return 'Fase $n da Campanha  •  Nv $lv';
  }

  @override
  String bbSlain(String name, String detail) {
    return '$name eliminado!  $detail';
  }

  @override
  String bbStage(Object n) {
    return 'Fase $n';
  }

  @override
  String bbGearReward(String rarity) {
    return '🎁 Equipamento $rarity';
  }

  @override
  String bestTotalKills(Object n) {
    return '$n mortes totais';
  }

  @override
  String get bestTypeMaxed => 'TIPO MAXIMIZADO';

  @override
  String bestGoldBonus(Object pct) {
    return '+$pct% ouro';
  }

  @override
  String get bestKilled => 'eliminado';

  @override
  String bestNextDmg(Object n) {
    return 'próximo +1% dmg em $n mortes';
  }

  @override
  String get lsTitle => 'LOGIN DIÁRIO';

  @override
  String get lsComeBack => 'Volte amanhã pela sua próxima recompensa!';

  @override
  String lsStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '$count dia',
    );
    return '$_temp0';
  }

  @override
  String lsClaimReward(String label) {
    return 'RESGATAR  $label';
  }

  @override
  String get lsFullCycle => 'CICLO COMPLETO DE 30 DIAS';

  @override
  String lsDay(Object d) {
    return 'Dia $d';
  }

  @override
  String get lsToday => 'HOJE';

  @override
  String get dashTitle => 'FICHA DO PERSONAGEM';

  @override
  String get dashDailyReady => 'Desafio diário pronto para resgatar!';

  @override
  String get dashAbilityAfford =>
      'Melhoria de habilidade acessível — visite HABILIDADES';

  @override
  String get dashPassiveAfford =>
      'Melhoria passiva acessível — visite PASSIVAS';

  @override
  String get dashEndlessAfford =>
      'Melhoria infinita acessível — visite MELHORIAS';

  @override
  String get dashNextAction => 'PRÓXIMA AÇÃO';

  @override
  String get dashIncomeSummary => 'RESUMO DE RENDA';

  @override
  String get dashIdleGold => 'Ouro inativo';

  @override
  String get dashBattleKill => 'Batalha/morte';

  @override
  String get dashExpeditions => 'Expedições';

  @override
  String get dashAchievementsNearby => 'CONQUISTAS PRÓXIMAS';

  @override
  String dashDayLoginReward(Object day) {
    return 'RECOMPENSA DE LOGIN DIA $day';
  }

  @override
  String dashExpReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expedições prontas para coletar!',
      one: '$count expedição pronta para coletar!',
    );
    return '$_temp0';
  }

  @override
  String dashMercsIdle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mercenários ociosos — despachar em expedição',
      one: '$count mercenário ocioso — despachar em expedição',
    );
    return '$_temp0';
  }

  @override
  String get emTitle => 'MAESTRIA ELEMENTAL';

  @override
  String emShards(Object n) {
    return '$n Fragmentos';
  }

  @override
  String get emUp => 'SUBIR';

  @override
  String get spResetsMonthly => '📅 Reseta mensalmente';

  @override
  String get spUnlockPremium =>
      'Desbloquear Passe Premium — 2× XP + trilha premium';

  @override
  String get spFree => 'GRÁTIS';

  @override
  String get spPremium => '👑 PREMIUM';

  @override
  String get spTier => 'Nível';

  @override
  String spClaimed(Object reward) {
    return 'Resgatado $reward';
  }

  @override
  String get spAllUnlocked => 'Todos os tiers desbloqueados — bom trabalho!';

  @override
  String spXpToTier(Object xp, Object next, Object tier) {
    return '$xp / $next XP para o Tier $tier';
  }

  @override
  String spClaimedN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Resgatadas $n recompensas',
      one: 'Resgatada 1 recompensa',
    );
    return '$_temp0';
  }

  @override
  String get spNothingToClaim => 'Nada para resgatar';

  @override
  String get euEchoes => 'Ecos';

  @override
  String get euYourBalance => 'Seu saldo';

  @override
  String get euEchoesCap => 'ECOS';

  @override
  String get euTutorial =>
      'Corridas de Gauntlet ganham Ecos 🔊 — gaste-os aqui em melhorias de combate permanentes que nunca são resetadas. Esses são alguns dos bônus mais poderosos do jogo.';

  @override
  String get euPermanent =>
      'Melhorias são permanentes por personagem. Bônus se aplicam em todos os modos.';

  @override
  String euForLv(Object n) {
    return 'para Nv $n';
  }

  @override
  String get euActive => 'ATIVO';

  @override
  String get lbRefresh => 'Atualizar';

  @override
  String get lbNoScores => 'Sem pontuações ainda — seja o primeiro!';

  @override
  String get lbPersonalBest => 'Seu melhor pessoal';

  @override
  String get lbRank => 'RANK';

  @override
  String get lbYou => 'VOCÊ';

  @override
  String get lbError => 'Não foi possível carregar o placar.';

  @override
  String get lbNotRanked => 'Sem rank ainda';

  @override
  String get cmTitle => 'MODIFICADORES DE DESAFIO';

  @override
  String get cmOptionalHandicaps => 'DESVANTAGENS OPCIONAIS';

  @override
  String get cmActive => 'Ativo: ';

  @override
  String get cmClear => 'LIMPAR';

  @override
  String get cmDesc =>
      'Ative até um modificador antes de entrar na Campanha ou Masmorra. Modificadores tornam as batalhas mais difíceis, mas aumentam as recompensas de fragmentos por morte.';

  @override
  String cmEssence(Object pct) {
    return '+$pct% essência';
  }

  @override
  String cmEnemyHp(Object mult) {
    return 'HP do Inimigo ×$mult';
  }

  @override
  String cmEnemyAtk(Object mult) {
    return 'ATK do Inimigo ×$mult';
  }

  @override
  String cmHeroHp(Object mult) {
    return 'HP do Herói ×$mult';
  }

  @override
  String get wClose => 'FECHAR';

  @override
  String get battleLog => 'LOG DE BATALHA';

  @override
  String get buffDodge => 'ESQUIVA';

  @override
  String get buffStun => 'ATORDOAR';

  @override
  String get dhPowerTip =>
      'Poder Medieval — pontuação combinada de todas as suas melhorias,\nequipamentos, passivas, prestígio, artefatos e aliados.';

  @override
  String dhHpTip(Object regen) {
    return 'Pontos de Vida — chegue a 0 e perde a batalha.\nRegeneração: $regen HP/rodada';
  }

  @override
  String dhXpTip(Object xp, Object lv, Object next) {
    return 'Experiência — alcance $xp para subir de nível.\nNível $lv → $next';
  }

  @override
  String get dhNice => 'ÓTIMO';

  @override
  String get bspAbilities => 'HABILIDADES';

  @override
  String get bspMercs => 'MERCENÁRIOS';

  @override
  String get bspEnemyStun => 'ATORDOAR Inimigo';

  @override
  String get bspPassive => 'PASSIVA';

  @override
  String bspDescAtk(Object pct) {
    return 'Seu herói causa +$pct% de dano por acerto.';
  }

  @override
  String bspDescArmor(Object pct) {
    return '+$pct% de Classe de Armadura — reduz o dano de entrada dos inimigos.';
  }

  @override
  String get bspDescDodge =>
      'Seu herói desviará completamente do próximo ataque inimigo.';

  @override
  String bspDescAura(Object hp) {
    return 'Aura de cura — restaura $hp HP no início de cada rodada.';
  }

  @override
  String bspDescDot(Object dmg) {
    return 'Dano contínuo — o inimigo sofre $dmg de dano a cada rodada.';
  }

  @override
  String get bspDescStun => 'O inimigo está atordoado e pula seu ataque.';

  @override
  String get baMercAbility => 'HABILIDADE DO MERCENÁRIO';

  @override
  String get tsCleared => 'LIMPO';

  @override
  String get sgFullyUpgraded => 'TOTALMENTE MELHORADO';

  @override
  String sgNeedGold(Object cost) {
    return 'Precisa de $cost ouro para melhorar';
  }

  @override
  String get fsVictory => 'VITÓRIA';

  @override
  String get fsDefeat => 'DERROTA';

  @override
  String fsVs(String enemy, Object rounds) {
    return 'vs $enemy  ·  $rounds rodadas';
  }

  @override
  String get fsAbilitiesUsed => 'HABILIDADES USADAS';

  @override
  String get wnTitle => 'O QUE HÁ DE NOVO';

  @override
  String get wnLatest => 'MAIS RECENTE';

  @override
  String get zcShards => 'Fragmentos';

  @override
  String get idbNoItem => 'Sem item equipado — melhoria direta!';

  @override
  String get absTitle => 'ATRIBUTOS DE HABILIDADE';

  @override
  String get absBanner =>
      'Atributos de Habilidade são melhorias permanentes compradas com ouro.\nMelhore qualquer atributo livremente — ouro é o único requisito.';

  @override
  String get absMaxed => 'MAXIMIZADO';

  @override
  String absNext(Object cost) {
    return 'Próximo: $cost ouro';
  }

  @override
  String absRankOf(Object rank, Object max) {
    return 'Rank $rank / $max';
  }

  @override
  String get bestUndiscovered =>
      'Mate esta criatura para revelar seus segredos.';

  @override
  String shopAdOffer(Object n, Object left, Object max) {
    return 'Ganhe $n ZCoins por anúncio  •  $left/$max restantes';
  }

  @override
  String get shopLifetimeTitle => 'Pacto Eterno';

  @override
  String get shopLifetimeTagline =>
      'Uma compra. Todos os benefícios premium. Para sempre.';

  @override
  String get shopLifetimeBadge => 'MELHOR OFERTA';

  @override
  String get shopLifetimeOwned => '✓ DESBLOQUEADO PARA SEMPRE';

  @override
  String shopLifetimeBuy(Object price) {
    return 'DESBLOQUEAR PARA SEMPRE  ·  $price';
  }

  @override
  String get shopLifetimeIncludes => 'TUDO INCLUÍDO';

  @override
  String get shopLifetimePerk1 => 'Todos os benefícios da Coroa Ascendente';

  @override
  String get shopLifetimePerk2 => '3× velocidade de batalha';

  @override
  String get shopLifetimePerk3 => 'Campanha Automática';

  @override
  String get shopLifetimePerk4 => '+50% de ouro inativo';

  @override
  String get shopLifetimePerk5 => '2× XP do Passe de Temporada';

  @override
  String get shopLifetimePerk6 => 'Recompensas Premium do Passe de Temporada';

  @override
  String get shopLifetimePerk7 => 'Acesso à Simulação de Batalha';

  @override
  String get shopLifetimePerk8 => 'Sem cobranças recorrentes — jamais';

  @override
  String get ratingTitle => 'Curtindo Zeta Idle?';

  @override
  String get ratingBody =>
      'Você já está nessa aventura há um tempo! Se estiver se divertindo, uma avaliação rápida ajuda muito o jogo a crescer. 🙏';

  @override
  String get ratingLove => 'Amando!';

  @override
  String get ratingMeh => 'Nem tanto';
}
