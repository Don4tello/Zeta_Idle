// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get ccForgeYourLegend => 'FORJA TU LEYENDA';

  @override
  String get ccNameYourWarrior => '— PONLE NOMBRE A TU GUERRERO —';

  @override
  String get ccDefaultHeroName => 'El Guardián';

  @override
  String get ccQuickStart => 'INICIO RÁPIDO';

  @override
  String get ccQuickStartHint => 'Entra directo con un héroe recomendado';

  @override
  String get ccChooseClassAndRace => 'ELEGIR CLASE Y RAZA';

  @override
  String get ccChooseYourClass => 'ELIGE TU CLASE';

  @override
  String get ccSelectYourPath => '— SELECCIONA TU CAMINO —';

  @override
  String get ccChooseRace => 'ELEGIR RAZA';

  @override
  String get ccSelectAClass => 'SELECCIONAR CLASE';

  @override
  String get ccRecommendedForBeginners => '★ RECOMENDADO PARA PRINCIPIANTES';

  @override
  String get ccComplexity => 'COMPLEJIDAD';

  @override
  String get ccChooseYourRace => 'ELIGE TU RAZA';

  @override
  String get ccHeritageDefinesYou => '— TU HERENCIA TE DEFINE —';

  @override
  String get ccBeginYourJourney => 'COMENZAR TU AVENTURA';

  @override
  String get ccSelectARace => 'SELECCIONAR RAZA';

  @override
  String get ccNameNotAllowed =>
      'Por favor, elige otro nombre — ese no está permitido.';

  @override
  String get csSelectCharacter => '— SELECCIONAR PERSONAJE —';

  @override
  String get csNewCharacter => 'NUEVO PERSONAJE';

  @override
  String get csSwipeToDelete =>
      'Desliza un personaje hacia la izquierda para eliminarlo';

  @override
  String csDeleteTitle(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get csDeleteBody =>
      '¿Estás seguro? Una vez eliminado no se puede recuperar.';

  @override
  String get csCancel => 'CANCELAR';

  @override
  String get csDelete => 'ELIMINAR';

  @override
  String get csLockedSlot => 'RANURA BLOQUEADA';

  @override
  String get navHero => 'HÉROE';

  @override
  String get navPlay => 'JUGAR';

  @override
  String get navInventory => 'INVENTARIO';

  @override
  String get navShop => 'TIENDA';

  @override
  String get navGuild => 'GREMIO';

  @override
  String get modeCampaign => 'CAMPAÑA';

  @override
  String get modeDungeon => 'MAZMORRA';

  @override
  String get modeBossRush => 'BOSS RUSH';

  @override
  String get modeTowerAscension => 'ASCENSIÓN DE LA TORRE';

  @override
  String get modeGauntlet => 'GAUNTLET';

  @override
  String get modePvp => 'PVP';

  @override
  String get modeChallenges => 'DESAFÍOS';

  @override
  String get modeEvents => 'EVENTOS';

  @override
  String get modeExpedition => 'EXPEDICIÓN';

  @override
  String get modeDaily => 'DIARIO';

  @override
  String get modeBounties => 'RECOMPENSAS';

  @override
  String get modeQuests => 'MISIONES';

  @override
  String get badgeNew => 'NUEVO';

  @override
  String get lootLog => 'REGISTRO DE BOTÍN';

  @override
  String get noLootYet => 'Sin botín aún — ¡ve a pelear!';

  @override
  String get welcomeBack => '¡Bienvenido de vuelta!';

  @override
  String awayFor(String time) {
    return 'Estuviste fuera por $time.';
  }

  @override
  String awayForCapped(int hours) {
    return 'Estuviste fuera más de ${hours}h — mostrando las recompensas máximas de inactividad.';
  }

  @override
  String rewardGold(String amount) {
    return '+$amount de oro';
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
      other: '$count expediciones listas!',
      one: '$count expedición lista!',
    );
    return '$_temp0';
  }

  @override
  String get comebackBonus => 'Bono de regreso:';

  @override
  String get idleIncomeCollected =>
      'Ingresos de inactividad recolectados mientras descansabas.';

  @override
  String get claim => 'RECLAMAR';

  @override
  String get milestone => 'HITO';

  @override
  String get welcomeBackCaps => '¡BIENVENIDO DE VUELTA!';

  @override
  String get missedYou =>
      '¡Te echamos de menos! Aquí hay un bono\npor tu tiempo fuera:';

  @override
  String get newSystemUnlocked => 'NUEVO SISTEMA DESBLOQUEADO';

  @override
  String get gotIt => 'ENTENDIDO';

  @override
  String get welcomeFightTitle => '¡Pelea!';

  @override
  String get welcomeFightBody =>
      'Ve a la pestaña JUGAR y toca una tarjeta de etapa en CAMPAÑA para comenzar tu primera batalla. ¡Sigue atacando hasta que el enemigo caiga!';

  @override
  String get welcomeIdleTitle => 'Gana oro inactivo';

  @override
  String get welcomeIdleBody =>
      'Tu héroe gana oro automáticamente cada minuto, incluso cuando no estás peleando. Observa cómo la barra de oro en la pestaña HÉROE se llena.';

  @override
  String get welcomeStrongerTitle => 'Hazte más fuerte';

  @override
  String get welcomeStrongerBody =>
      'Gasta oro en MEJORAS para aumentar tus estadísticas. Abre PASIVAS para bonos permanentes y HABILIDADES para poderosas habilidades de combate.';

  @override
  String get welcomeExploreTitle => 'Explorar';

  @override
  String get welcomeExploreBody =>
      'CAMPAÑA avanza por 100 etapas creadas a mano. ASCENSIÓN DE LA TORRE te permite farmear fragmentos para siempre. La MAZMORRA es una corrida roguelite con caída de objetos y peleas de jefe. Se desbloquean más modos a medida que avanzas.';

  @override
  String get navBack => 'ATRÁS';

  @override
  String get navNext => 'SIGUIENTE';

  @override
  String get startPlaying => 'EMPEZAR A JUGAR';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Predeterminado del sistema';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonContinue => 'CONTINUAR';

  @override
  String heroFalls(String name) {
    return '$name CAE';
  }

  @override
  String get battleGrowStronger =>
      'Hazte más fuerte antes de intentarlo de nuevo.';

  @override
  String get battleBackToHero => 'VOLVER AL HÉROE';

  @override
  String get defeatEndlessTitle => 'MODO INFINITO';

  @override
  String get defeatEndlessHint => 'Farmea XP y oro a tu ritmo';

  @override
  String get defeatDungeonHint => 'Gana fragmentos y objetos';

  @override
  String get defeatGauntletHint => 'Gana ecos para mejoras';

  @override
  String get defeatDailyTitle => 'DESAFÍOS DIARIOS';

  @override
  String get defeatDailyHint => 'Reclama recompensas por progreso';

  @override
  String battleTierUnlocked(int tier) {
    return 'NIVEL $tier DESBLOQUEADO';
  }

  @override
  String get battleCampaignCleared => 'CAMPAÑA COMPLETADA';

  @override
  String battleTierUnlockedBody(int tier) {
    return 'El Omega ha caído. La campaña se reinicia en el Nivel $tier — enemigos más difíciles y mejor botín.\n\nTu nivel, Páragon, equipo y divisas se mantienen. Nada se reinicia.';
  }

  @override
  String get battleCampaignClearedBody =>
      'El Omega ha caído en el nivel más alto. Has alcanzado la cima — sigue farmeando botín y Puntos de Páragon.';

  @override
  String get battleSwitchTiersHint =>
      'Cambia de nivel en cualquier momento desde el encabezado de Campaña.';

  @override
  String get battleRetreat => 'Retirarse';

  @override
  String get battleLastFightSummary => 'Resumen del último combate';

  @override
  String get battleResume => 'Reanudar';

  @override
  String get battlePause => 'Pausar';

  @override
  String get battleAutoCampaignLocked =>
      'Campaña Automática — Speed Boost / Pase Premium';

  @override
  String get battleAutoCampaignOn => 'Campaña Automática: ACTIVADA';

  @override
  String get battleAutoCampaignOff => 'Campaña Automática: DESACTIVADA';

  @override
  String get battleNoFightYet => 'Ningún combate finalizado aún.';

  @override
  String get battleAutoCampaignPerk =>
      'Campaña Automática es un beneficio del Speed Boost / Pase Premium.';

  @override
  String get battleNoActiveBattle => 'SIN BATALLA ACTIVA';

  @override
  String get battleVictory => '¡VICTORIA!';

  @override
  String get battleBossDefeated => 'JEFE DERROTADO';

  @override
  String get battleNewContentUnlocked => 'NUEVO CONTENIDO DESBLOQUEADO';

  @override
  String get battleClassQuestlineUnlocked =>
      'CADENA DE MISIONES DE CLASE DESBLOQUEADA';

  @override
  String battleClassQuestlineBody(String className) {
    return 'El camino de $className comienza. Completa 5 misiones para desbloquear tu Habilidad Definitiva.';
  }

  @override
  String battleRewardGold(String amount) {
    return '+$amount ORO';
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
    return 'HABILIDAD DESBLOQUEADA: $name';
  }

  @override
  String get battleAddedToBag => 'Añadido a la bolsa';

  @override
  String get battleFight => 'PELEAR  (−1 ⚡)';

  @override
  String get battleSpeedBoostTitle => '2× Speed Boost';

  @override
  String battleSpeedBoostBody(int cost, int have) {
    return '¿Desbloquear velocidad de batalla 2× por 7 días?\n\nCosto: $cost ZCoins\nTus ZCoins: $have';
  }

  @override
  String get battlePurchase => 'Comprar';

  @override
  String get battleNotEnoughZcoins => '¡No tienes suficientes ZCoins!';

  @override
  String get battleArtifactFound => '¡ARTEFACTO ENCONTRADO!';

  @override
  String battleRoundsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rondas restantes',
      one: '$count ronda restante',
    );
    return '$_temp0';
  }

  @override
  String get commonOk => 'OK';

  @override
  String get campaignDifficultyTier => 'NIVEL DE DIFICULTAD';

  @override
  String get campaignDifficultyTierTooltip => 'Nivel de Dificultad';

  @override
  String get campaignTierSelectorBody =>
      'Niveles más altos = enemigos más difíciles Y mejor botín (rareza, sets, artefactos). Bajar de nivel mantiene todo tu poder permanente — solo escala lo que luchas y lo que cae.';

  @override
  String get campaignTierNormal => 'NIVEL 0 — Normal';

  @override
  String campaignTierN(int tier) {
    return 'NIVEL $tier';
  }

  @override
  String get campaignTierBaseDesc =>
      'Enemigos base · botín base · sin Magia de Hallazgo';

  @override
  String campaignTierScaledDesc(int hp, int atk) {
    return 'Enemigos +$hp% HP · +$atk% ATK';
  }

  @override
  String campaignTierMagicFind(int mf) {
    return '✦ +$mf% Magia de Hallazgo (mayor rareza, sets y artefactos)';
  }

  @override
  String get campaignLeaderboardTooltip => 'Clasificación de Campaña';

  @override
  String get campaignTutorial =>
      'La campaña avanza etapa por etapa. Derrota a cada jefe para desbloquear el siguiente. Elimina al jefe final para desbloquear el siguiente Nivel de Dificultad — la campaña se reinicia más difícil con mejor botín, y tu poder se mantiene.';

  @override
  String campaignEnergyRecharge(String time) {
    return '+1 en $time';
  }

  @override
  String campaignEnergyRefill(int amount, int left) {
    return 'Recargar +$amount  ($left gratis restantes)';
  }

  @override
  String get campaignBuy => 'Comprar ';

  @override
  String get campaignEnergyEmptyTutorial =>
      '¡Sin energía! ⚡ Se recarga 1 cada 5 min. Toca el botón +10 de arriba para 3 recargas diarias gratis. O compra +20 de energía por 💎 50 ZCoins.';

  @override
  String get campaignStageMap =>
      'MAPA DE ETAPAS  •  toca cualquier nodo ✓ para repetir';

  @override
  String get campaignNoEnergyRefill =>
      '¡Sin energía! Espera a que se recargue.';

  @override
  String campaignSimulateStage(int stage) {
    return '⚡ Simular Etapa $stage';
  }

  @override
  String campaignEnergyAvailable(int count) {
    return 'Energía disponible: $count';
  }

  @override
  String get campaignSimInfo =>
      'Las batallas se ejecutan al instante. El botín va directamente a tu bolsa.';

  @override
  String campaignSimAll(int count) {
    return 'TODO ($count)';
  }

  @override
  String campaignSimResultTitle(int stage, int count) {
    return 'Etapa $stage — $count× Simuladas';
  }

  @override
  String get campaignSimGold => '💰 Oro';

  @override
  String get campaignSimXp => '✦ XP';

  @override
  String campaignItemsDropped(int count) {
    return 'Objetos caídos ($count):';
  }

  @override
  String get campaignNoItemsDropped => 'Ningún objeto cayó en esta corrida.';

  @override
  String get campaignNotEnoughEnergy => '¡No tienes suficiente energía!';

  @override
  String get campaignMapFight => '⚔  PELEAR (−1 ⚡)';

  @override
  String get campaignSimRequiresPremium =>
      'Requiere suscripción al Pase Premium';

  @override
  String get campaignBossEncounter => 'ENCUENTRO CON JEFE';

  @override
  String get campaignDismiss => '[ descartar ]';

  @override
  String campaignPerfectStages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count etapas perfectas',
      one: '$count etapa perfecta',
    );
    return '$_temp0';
  }

  @override
  String campaignNextMilestone(int next) {
    return '• siguiente hito en etapa $next (+mitril +Z-Coins)';
  }

  @override
  String get campaignAllMilestones => '• ¡todos los hitos completados!';

  @override
  String get hubWhatsNew => 'Novedades';

  @override
  String get hubLootLog => 'Registro de botín';

  @override
  String get hubSettings => 'Configuración';

  @override
  String get hubChange => 'CAMBIAR';

  @override
  String get hubHeroMenu => 'Menú del héroe';

  @override
  String get hubJoinDiscord => 'Únete a nuestro Discord';

  @override
  String get hubVisitReddit => 'Visitar r/zeta_idle';

  @override
  String hubCouldNotOpen(String url) {
    return 'No se pudo abrir $url';
  }

  @override
  String get hubLocked => 'Bloqueado';

  @override
  String get hubGroupCharacter => 'PERSONAJE';

  @override
  String get hubGroupProgression => 'PROGRESIÓN';

  @override
  String get hubGroupCollection => 'COLECCIÓN';

  @override
  String get hubGroupRecords => 'RÉCORDS';

  @override
  String get hubBlurbCharacter => 'Tu build y poder';

  @override
  String get hubBlurbProgression => 'Sistemas de fin de juego';

  @override
  String get hubBlurbCollection => 'Aliados y compendio';

  @override
  String get hubBlurbRecords => 'Metas y resúmenes';

  @override
  String get hubSheet => 'HOJA';

  @override
  String get hubScores => 'PUNTUACIONES';

  @override
  String get hubAbilities => 'HABILIDADES';

  @override
  String get hubPassives => 'PASIVAS';

  @override
  String get hubSpecialize => 'ESPECIALIZAR';

  @override
  String get hubParagon => 'PÁRAGON';

  @override
  String get hubUpgrades => 'MEJORAS';

  @override
  String get hubAscend => 'ASCENDER';

  @override
  String get hubMastery => 'MAESTRÍA';

  @override
  String get hubPets => 'MASCOTAS';

  @override
  String get hubMercs => 'MERCENARIOS';

  @override
  String get hubBestiary => 'BESTIARIO';

  @override
  String get hubCodex => 'CÓDICE';

  @override
  String get hubArmory => 'ARMERÍA';

  @override
  String get hubAchievements => 'LOGROS';

  @override
  String get hubBonuses => 'BONOS';

  @override
  String get auShards => 'fragmentos';

  @override
  String get auRespecTitle => '¿Reiniciar Habilidades?';

  @override
  String auRespecBody(int cost) {
    return 'Reinicia todos los rangos de habilidades y elecciones de hitos.\nTodos los fragmentos gastados serán reembolsados.\n\nCosto: $cost ZCoins';
  }

  @override
  String auRespecConfirm(int cost) {
    return 'REINICIAR ($cost ZC)';
  }

  @override
  String get auRespec => 'REINICIAR';

  @override
  String get auTutorial =>
      '¡Ganaste Fragmentos ◆ — gástalos aquí para desbloquear y mejorar habilidades de clase que se activan automáticamente en cada batalla.';

  @override
  String get auIntro =>
      'Gasta fragmentos para potenciar tus habilidades. Hitos en los rangos 5, 10 y 15. Sube de nivel después del rango 15 — cada nivel se desbloquea con tu Nivel de Dificultad.';

  @override
  String get auTitle => 'MEJORAS DE HABILIDADES';

  @override
  String get auMaxTier => 'NIVEL MÁX  ✦';

  @override
  String auTierLockedLabel(int tier, int req) {
    return 'NIVEL $tier  —  Requiere Nivel de Dificultad $req';
  }

  @override
  String get auAscension => 'ASCENSIÓN';

  @override
  String auTierUnlocked(int cap) {
    return 'Nivel $cap desbloqueado';
  }

  @override
  String auAscFullyAscended(int pct) {
    return 'Totalmente ascendido  ·  +$pct% poder de habilidad';
  }

  @override
  String auAscTierLocked(int cur, int next) {
    return '+$cur% poder  ·  Desbloquea el Nivel de Dificultad $next para ascender más';
  }

  @override
  String auAscUpgrade(int cur, int next, int cost) {
    return '+$cur%  →  +$next% poder  ·  cuesta $cost ✦ Páragon';
  }

  @override
  String auAscYouHave(int have) {
    return '  (tienes $have)';
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
  String get auUltimate => 'DEFINITIVA';

  @override
  String auUnlocksLv(int lv) {
    return 'SE DESBLOQUEA NV $lv';
  }

  @override
  String get auFinishQuestline =>
      '🔒 Termina tu cadena de misiones de clase para desbloquear';

  @override
  String auReachLevel(int lv, int cur) {
    return 'Alcanza el Nivel $lv  (tú: Nv $cur)';
  }

  @override
  String auCompleteQuests(String className, int claimed) {
    return 'Completa las 5 misiones de $className  ($claimed / 5)';
  }

  @override
  String get auTrackQuests => 'Sigue tus misiones en la pestaña Misiones.';

  @override
  String get auChoose => 'ELEGIR';

  @override
  String get setTitle => 'CONFIGURACIÓN';

  @override
  String get setSave => 'GUARDAR';

  @override
  String get setLoad => 'CARGAR';

  @override
  String get setReset => 'REINICIAR';

  @override
  String get setOpen => 'ABRIR';

  @override
  String get setView => 'VER';

  @override
  String get setEmail => 'CORREO';

  @override
  String get setConfirm => 'CONFIRMAR';

  @override
  String get setSecAccount => 'CUENTA';

  @override
  String get setSecPromo => 'CÓDIGO PROMO';

  @override
  String get setSecAudio => 'AUDIO';

  @override
  String get setSecHaptics => 'HÁPTICA';

  @override
  String get setSecNotifications => 'NOTIFICACIONES';

  @override
  String get setSecDisplay => 'PANTALLA';

  @override
  String get setSecStats => 'ESTADÍSTICAS';

  @override
  String get setSecAutoLoot => 'AUTO-BOTÍN';

  @override
  String get setSecBattle => 'BATALLA';

  @override
  String get setSecDailyReset => 'REINICIO DIARIO';

  @override
  String get setSecSave => 'GUARDAR';

  @override
  String get setSecDanger => 'ZONA DE PELIGRO';

  @override
  String get setSecHelp => 'AYUDA';

  @override
  String get setSecAbout => 'ACERCA DE';

  @override
  String get setManage => 'GESTIONAR';

  @override
  String get setSignIn => 'INICIAR SESIÓN';

  @override
  String get setHeroName => 'Nombre del Héroe';

  @override
  String setRename(int cost) {
    return 'RENOMBRAR ($cost 🪙)';
  }

  @override
  String get setPromoHint =>
      '¿Tienes un código? Canjéalo aquí para obtener recompensas.';

  @override
  String get setRedeem => 'CANJEAR';

  @override
  String get setSoundEffects => 'Efectos de sonido';

  @override
  String get setBackgroundMusic => 'Música de fondo';

  @override
  String get setVolume => 'Volumen';

  @override
  String get setVibration => 'Vibración';

  @override
  String get setReminders => 'Recordatorios';

  @override
  String get setDamageNumbers => 'Números de daño';

  @override
  String get setReducedParticles => 'Partículas reducidas';

  @override
  String get setTotalPlaytime => 'Tiempo total de juego';

  @override
  String get setAutoSalvage => 'Auto-salvamento';

  @override
  String get setAutoEquip => 'Auto-equipar mejoras';

  @override
  String get setAutoEquipSub =>
      'Equipar automáticamente objetos mejores que el equipo actual';

  @override
  String get setBattleSpeed => 'Velocidad de batalla';

  @override
  String get setAutoCampaign => 'Campaña automática';

  @override
  String get setResetTime => 'Hora de reinicio';

  @override
  String get setCloudSave => 'Guardado en la nube';

  @override
  String get setCloudSaveSub => 'Sincroniza tu progreso en la nube';

  @override
  String get setCloudSaveComplete => 'Guardado en la nube completado.';

  @override
  String get setLoadCloud => 'Cargar desde la nube';

  @override
  String get setLoadCloudSub =>
      'Sobrescribir guardado local con datos de la nube';

  @override
  String get setResetProgress => 'Reiniciar progreso';

  @override
  String get setResetProgressSub =>
      'Eliminar todos los datos de guardado de este slot. Irreversible.';

  @override
  String get setKnowledgeBase => 'Base de conocimientos';

  @override
  String get setKnowledgeBaseSub =>
      'Palabras clave, sistemas y divisas explicadas';

  @override
  String get setTagline => 'Un RPG idle medieval oscuro.';

  @override
  String get setAboutHero => 'Héroe';

  @override
  String get setAboutClass => 'Clase';

  @override
  String get setAboutLevel => 'Nivel';

  @override
  String get setAboutPrestige => 'Prestigio';

  @override
  String get setAboutAchievements => 'Logros';

  @override
  String get setAboutDeveloper => 'Desarrollador';

  @override
  String get setAboutContact => 'Contacto';

  @override
  String get setPrivacy => 'Política de privacidad';

  @override
  String get setPrivacySub => 'Cómo manejamos tus datos';

  @override
  String get setReportBug => 'Reportar un error / Comentarios';

  @override
  String get setReportBugSub =>
      'Envíanos un correo — la información del dispositivo se añade automáticamente';

  @override
  String get setReplayTips => 'Repetir consejos';

  @override
  String get setReplayTipsSub => 'Mostrar los consejos del tutorial de nuevo';

  @override
  String get setTipsReset =>
      'Consejos del tutorial reiniciados — reaparecerán mientras exploras.';

  @override
  String get setRenameHeroTitle => 'RENOMBRAR HÉROE';

  @override
  String get setHeroNameHint => 'Ingresa un nombre de héroe';

  @override
  String setRenameCost(int cost, int have) {
    return 'Costo: $cost 🪙   (tienes $have)';
  }

  @override
  String setRenameNotEnough(int cost) {
    return 'No tienes suficientes Z-Coins — renombrar cuesta $cost 🪙.';
  }

  @override
  String get setNoEmailApp =>
      'No se encontró aplicación de correo. Contáctanos en razorintegrations@gmail.com';

  @override
  String get setDailyResetTitle => 'Hora de reinicio diario';

  @override
  String get setDailyResetHint =>
      'Elige la hora en que se reinician los límites diarios.';

  @override
  String get setDailyResetWarning =>
      'Advertencia: solo puedes cambiar esto una vez al año.';

  @override
  String get setLoadCloudTitle => '¿Cargar desde la nube?';

  @override
  String get setLoadCloudBody =>
      'Esto sobrescribirá tu guardado local con los datos de la nube. El progreso local no sincronizado se perderá.';

  @override
  String get setResetAllTitle => '¿Reiniciar todo el progreso?';

  @override
  String get setResetAllBody =>
      'Todo el progreso, oro, objetos, niveles de prestigio y logros serán eliminados permanentemente. Esto no se puede deshacer.';

  @override
  String get setNewHeroName => 'Nuevo nombre del héroe:';

  @override
  String get setGoogleAccount => 'Cuenta de Google';

  @override
  String get setSignInGoogle => 'Iniciar sesión con Google';

  @override
  String get setSignedIn => 'Sesión iniciada';

  @override
  String get setSyncSaves => 'Sincronizar guardados entre dispositivos';

  @override
  String get setEnterCode => 'INGRESAR CÓDIGO';

  @override
  String get setOff => 'Apagado';

  @override
  String get setOffCaps => 'APAGADO';

  @override
  String get setHidden => 'Oculto';

  @override
  String get setVibrationOn =>
      'Vibra en críticos, subidas de nivel, victorias y recompensas';

  @override
  String get setRemindersOn =>
      'Recibe recordatorios \"regresa\" mientras estás fuera';

  @override
  String get setDamageOn => 'Números flotantes mostrados en batalla';

  @override
  String get setParticlesOn => 'Menos efectos de fondo (mejor rendimiento)';

  @override
  String get setParticlesOff => 'Efectos completos';

  @override
  String get setSalvageOff =>
      'Toca para activar auto-salvamento de objetos caídos';

  @override
  String setSalvageOn(String tier) {
    return 'Auto-salvamento de $tier y por debajo';
  }

  @override
  String get setAutoCampaignOnSub =>
      'Luchar automáticamente batallas de campaña en segundo plano';

  @override
  String get setAutoCampaignLockedSub =>
      '🔒 Solo para suscriptores del Speed Boost / Pase Premium';

  @override
  String setResetTimeOn(String time) {
    return 'Los límites diarios se reinician a las $time. Toca para cambiar (una vez al año).';
  }

  @override
  String setResetTimeLocked(String time) {
    return 'Se reinicia a las $time · Ya cambiado este año.';
  }

  @override
  String get guildTitle => 'GREMIO';

  @override
  String get guildJoinTitle => 'UNIRSE A UN GREMIO';

  @override
  String get guildJoinBlurb =>
      'Los gremios proporcionan bonos pasivos, un desafío semanal de jefe y una tienda de gremio con recompensas exclusivas.';

  @override
  String get guildCreate => 'CREAR GREMIO';

  @override
  String get guildPublic => 'GREMIOS PÚBLICOS';

  @override
  String get guildNoGuilds =>
      'No se encontraron gremios. ¡Sé el primero en crear uno!';

  @override
  String get guildCreateTitle => 'Crear gremio';

  @override
  String get guildNameLabel => 'Nombre del gremio';

  @override
  String get guildDescLabel => 'Descripción (opcional)';

  @override
  String get guildCreateBtn => 'CREAR';

  @override
  String get guildTabInfo => 'INFO';

  @override
  String get guildTabCastle => 'CASTILLO';

  @override
  String get guildTabBoss => 'JEFE';

  @override
  String get guildTabWar => 'GUERRA';

  @override
  String get guildTabChat => 'CHAT';

  @override
  String get guildTabShop => 'TIENDA';

  @override
  String guildCastleTier(int tier) {
    return 'CASTILLO — NIVEL $tier / 10';
  }

  @override
  String guildProgressTier(int tier) {
    return 'Progreso al Nivel $tier';
  }

  @override
  String guildCpProgress(int cp, int cap) {
    return '$cp / $cap PC';
  }

  @override
  String guildNext(String headline) {
    return 'Siguiente: $headline';
  }

  @override
  String get guildCitadelComplete =>
      '¡Ciudadela completa — el castillo está totalmente construido!';

  @override
  String get guildContributeGold => 'CONTRIBUIR CON ORO';

  @override
  String guildContributeInfo(String rate, int cap) {
    return 'Convierte oro en Puntos de Construcción (PC). Tasa: $rate oro = 1 PC. Puedes añadir hasta $cap PC al día.';
  }

  @override
  String get guildActiveBenefits => 'BENEFICIOS ACTIVOS DEL CASTILLO';

  @override
  String get guildContributeHint =>
      'Contribuye para elevar el castillo y desbloquear beneficios.';

  @override
  String guildCastleAdvanced(int tier) {
    return '🏰 ¡El castillo avanzó al Nivel $tier!';
  }

  @override
  String get guildCapReached =>
      'Límite diario de construcción alcanzado — ¡vuelve mañana!';

  @override
  String guildLevelMembers(int lvl, int m, int max) {
    return 'Nivel $lvl  •  $m/$max miembros';
  }

  @override
  String guildBonusGold(int pct) {
    return '+$pct% Oro';
  }

  @override
  String guildBonusXp(int pct) {
    return '+$pct% XP';
  }

  @override
  String guildBonusIdle(int pct) {
    return '+$pct% Inactivo';
  }

  @override
  String guildXpProgress(int xp, int max) {
    return '$xp/$max XP';
  }

  @override
  String get guildDonate1000 => 'DONAR 1000 ORO';

  @override
  String get guildDonateReward => '→ XP del gremio + 🪙';

  @override
  String get guildPerks => 'VENTAJAS';

  @override
  String guildLockedPerk(int lvl, String name, String desc) {
    return '🔒 Nv$lvl: $name — $desc';
  }

  @override
  String get guildMembers => 'MIEMBROS';

  @override
  String guildMemberLine(int lvl, String cls, String role, int d) {
    return 'Nv$lvl $cls  •  $role  •  donado: ${d}g';
  }

  @override
  String get guildLeave => 'ABANDONAR GREMIO';

  @override
  String get guildNoBoss => 'Sin jefe esta semana.';

  @override
  String get guildWeeklyBoss => '☠ JEFE SEMANAL DEL GREMIO';

  @override
  String guildBossHp(int hp, int max) {
    return '$hp / $max HP';
  }

  @override
  String get guildDefeated => '✓ DERROTADO';

  @override
  String guildBossRewardMsg(Object rank, Object gc, Object gold) {
    return '🏆 Jefe de la semana pasada: Rango #$rank — +$gc Monedas de gremio, +$gold oro';
  }

  @override
  String get guildClaimBossReward =>
      '🏆 RECLAMAR RECOMPENSA DEL JEFE DE LA SEMANA PASADA';

  @override
  String guildAttempts(int rem, int max) {
    return 'Intentos: $rem / $max';
  }

  @override
  String get guildNoAttempts => 'SIN INTENTOS RESTANTES';

  @override
  String get guildChallengeBoss => '⚔ DESAFIAR JEFE';

  @override
  String get guildDamageRanking => 'CLASIFICACIÓN DE DAÑO';

  @override
  String guildDmg(int dmg) {
    return '$dmg daño';
  }

  @override
  String get guildWarStandings => 'CLASIFICACIÓN DE GUERRA';

  @override
  String guildWarRecord(int w, int l) {
    return 'Tu récord: ${w}V–${l}D';
  }

  @override
  String get guildWeeklyWar => 'Guerra de Gremio Semanal';

  @override
  String get guildWarBlurb =>
      'Alístate durante la Preparación (lun–mar). Mié–vie, gasta Ataques de Guerra para pelear contra campeones rivales y ganar puntos para tu gremio. Sáb–dom, reclama las recompensas de rango.';

  @override
  String get guildEnlistedBattle =>
      '⚔ ¡Alistado! Gasta tus Ataques de Guerra ahora.';

  @override
  String get guildEnlistedPrep => '⚔ ¡Alistado! Vuelve mié–vie para pelear.';

  @override
  String get guildEnlist => 'ALISTAR TU GREMIO';

  @override
  String get guildWarEndedWait => 'GUERRA TERMINADA — ESPERA LA PRÓXIMA SEMANA';

  @override
  String guildScoreYou(String name) {
    return '$name (tú)';
  }

  @override
  String get guildLeads => '🏆 ¡Tu gremio lidera!';

  @override
  String get guildBehind => '⚠ Tu gremio está por detrás — ¡pelea!';

  @override
  String guildFightForGuild(int c, int max) {
    return '⚔ PELEAR POR EL GREMIO  ($c/$max)';
  }

  @override
  String get guildNoWarAttacks => 'SIN ATAQUES DE GUERRA HOY';

  @override
  String get guildWarRefresh =>
      'Los Ataques de Guerra se renuevan diariamente durante la fase de Batalla.';

  @override
  String get guildWarVictory => '🏆 ¡Victoria!';

  @override
  String get guildWarOver => 'Guerra terminada.';

  @override
  String guildWarRewardMsg(String result, Object gc, Object gold) {
    return '$result +$gc Monedas de gremio, +$gold oro';
  }

  @override
  String get guildRewardsClaimed => 'RECOMPENSAS RECLAMADAS';

  @override
  String get guildClaimWarRewards => 'RECLAMAR RECOMPENSAS DE GUERRA';

  @override
  String get guildWarBattleSoon =>
      'La batalla comienza el miércoles — ¡vuelve para pelear!';

  @override
  String get guildCoinsLabel => 'Monedas de gremio';

  @override
  String guildListLine(int lvl, int m, int max) {
    return 'Nv$lvl  •  $m/$max miembros';
  }

  @override
  String get guildJoin => 'UNIRSE';

  @override
  String get guildFull => 'LLENO';

  @override
  String get guildBossTitle => 'JEFE DEL GREMIO';

  @override
  String get guildBossWin => '✦ ¡JEFE DERROTADO!';

  @override
  String get guildBossLose => '💀 CAÍDO';

  @override
  String guildTotalDamage(int d) {
    return 'Daño total infligido: $d';
  }

  @override
  String get guildReturn => 'VOLVER AL GREMIO';

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
      'Destruye objetos para recuperar Fragmentos (◆).\n• Común → 3 ◆\n• Raro → 8 ◆\n• Épico → 20 ◆\n• Legendario → 60 ◆\n• Set → 100 ◆';

  @override
  String get forgeUpgradeTooltip =>
      'Mejora un objeto de +0 a +10.\nCada nivel aumenta todas las estadísticas en 8%.\nAl alcanzar +5 y +10 el objeto gana un prefijo de título.\nCuesta Oro + Fragmentos por nivel.';

  @override
  String get forgeTitle => 'FORJA';

  @override
  String get forgeSalvage => 'RECUPERAR';

  @override
  String get forgeUpgrade => 'MEJORAR';

  @override
  String get forgeSlot => 'RANURA';

  @override
  String get forgeFrom => 'DESDE  ';

  @override
  String forgeForged(String name, String label) {
    return '¡Forjado: $name ($label)!';
  }

  @override
  String get forgeSalvageRates => 'TASAS DE RECUPERACIÓN';

  @override
  String forgeSalvageBtn(int n, int s) {
    return 'RECUPERAR  $n  (+$s ◆)';
  }

  @override
  String get forgeBagEmpty => 'Tu bolsa está vacía.';

  @override
  String forgeBag(int n) {
    return 'BOLSA  ($n objetos)';
  }

  @override
  String forgeSalvaged(int earned) {
    return 'Recuperado: +$earned ◆';
  }

  @override
  String forgeTimesN(int n) {
    return ' ×$n';
  }

  @override
  String get forgeTimesRandom => '  ×1 (aleatorio)';

  @override
  String get forgeMasterForger => 'Maestro Herrero';

  @override
  String get forgeSelected => 'SELECCIONADO';

  @override
  String forgeSelectedCount(int selected, int needed) {
    return '$selected / $needed';
  }

  @override
  String get forgeArcaneDust => 'POLVO ARCANO';

  @override
  String get forgeGemType => 'TIPO DE GEMA';

  @override
  String forgeGemWeaponDesc(Object pct, String type) {
    return '⚔ Arma: +$pct% daño $type';
  }

  @override
  String forgeGemArmorDesc(Object pct, String type) {
    return '🛡 Armadura: +$pct% resistencia $type';
  }

  @override
  String get forgeTier => 'NIVEL';

  @override
  String forgeGemBagFull(int n, int max) {
    return 'BOLSA DE GEMAS LLENA ($n/$max)';
  }

  @override
  String forgeNeedMore(int n) {
    return 'NECESITAS $n MÁS 💠';
  }

  @override
  String forgeCraft(int cost) {
    return '✦  CREAR  $cost 💠';
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
    return '$cost 💠 para crear';
  }

  @override
  String forgeGemBag(int n, int max) {
    return 'BOLSA DE GEMAS  ($n/$max)';
  }

  @override
  String get forgeTapGem => 'Toca una gema para engarzarla en un objeto';

  @override
  String get forgeNoGems => 'Ninguna gema creada aún. ¡Crea una arriba!';

  @override
  String get forgeHowGems => 'CÓMO FUNCIONAN LAS GEMAS';

  @override
  String get forgeGemsInfo =>
      '• Cada gema tiene doble propósito — la MISMA gema da DAÑO elemental en un arma, o RESISTENCIA elemental en armadura / joyería.\n• Los fragmentos de gema caen de muertes en combate (25% de probabilidad) y jefes.\n• Cada objeto puede tener 1 gema en su engarce.\n• Engaza gemas desde esta bolsa o desde la pantalla de Inventario.\n• Reemplazar o remover una gema destruye la antigua.';

  @override
  String get forgeNoItemsSocket => 'No hay objetos para engarzar.';

  @override
  String forgeSocketGem(String name) {
    return 'Engarzar $name';
  }

  @override
  String get forgeChooseItem => 'Elige un objeto en el que engarzar esta gema.';

  @override
  String get forgeReplaceGem => '¿Reemplazar Gema?';

  @override
  String forgeReplaceBody(String old, String gnew) {
    return '$old será destruida y reemplazada por $gnew. Esto no se puede deshacer.';
  }

  @override
  String get forgeReplace => 'REEMPLAZAR';

  @override
  String get forgeUpgradeInfo =>
      'Mejora objetos de +0 a +10. Cada nivel aumenta todas las estadísticas en 8%.\nAl +5 el objeto gana el prefijo Refinado.\nAl +10 se convierte en Obra Maestra.';

  @override
  String get forgeBalance => 'Saldo: ';

  @override
  String get forgeNoUpgradeItems =>
      'No hay objetos disponibles para mejorar.\nTodos los objetos están en +10 o la bolsa está vacía.';

  @override
  String get forgeSelectItem => 'SELECCIONAR OBJETO';

  @override
  String get forgeAllStats => 'Todas las estadísticas +8%';

  @override
  String get forgeWeaponDmgSuffix => '  •  Daño de arma +8%';

  @override
  String get forgeRefinedPrefix => '🏷 ¡Gana el prefijo \"Refinado\" al +5!';

  @override
  String get forgeMasterworkPrefix =>
      '🏷 ¡Gana el prefijo \"Obra Maestra\" al +10!';

  @override
  String forgeUpgradeTo(int tier) {
    return 'MEJORAR A +$tier';
  }

  @override
  String get dngTitle => 'LA MAZMORRA';

  @override
  String dngTitleRun(int tier, int floor) {
    return 'N$tier  PIS.$floor  —  LA MAZMORRA';
  }

  @override
  String get dngFlee => 'Huir de la mazmorra';

  @override
  String get dngAutoOn => 'Auto Run: ACTIVADO — toca para control manual';

  @override
  String get dngAutoOff =>
      'Auto Run: DESACTIVADO — toca para limpiar automáticamente';

  @override
  String get dngAutoPremium => 'Auto Run (se desbloquea en la Etapa 5)';

  @override
  String get dngPushOnTip =>
      'Empuje Abisal: ACTIVADO — derrota al Señor de la Mazmorra para descender más profundo';

  @override
  String get dngPushOffTip =>
      'Empuje Abisal: DESACTIVADO — la corrida termina en el piso limpio';

  @override
  String get dngPushOnMsg =>
      'Empuje Abisal ACTIVADO — limpia al Señor de la Mazmorra para descender a pisos abisales escalables (más Mitril + probabilidades únicas). Huye en cualquier momento para asegurar la limpieza.';

  @override
  String get dngPushOffMsg =>
      'Empuje Abisal DESACTIVADO — la corrida termina cuando limpias al Señor de la Mazmorra.';

  @override
  String get dngLeaderboard => 'Clasificación de Mazmorra';

  @override
  String get dngAutoPremiumMsg =>
      'Auto Run se desbloquea en la Etapa 5 de la campaña.';

  @override
  String get dngTutorial =>
      'Elige una de dos puertas cada piso. Los enemigos muertos sueltan Huesos — gástalos en el Mercader Viajero por mejoras para la corrida. El botín es tuyo de inmediato, aunque tu héroe caiga.';

  @override
  String get dngWhatToExpect => 'QUÉ ESPERAR';

  @override
  String get dngExpCombat => 'Combate — pelea por oro';

  @override
  String get dngExpElite =>
      'Elite — enemigo más difícil, caída de objeto garantizada';

  @override
  String get dngExpAmbush => 'Emboscada — el enemigo ataca primero, mucho oro';

  @override
  String get dngExpRest => 'Lugar de descanso — recupera 20% de HP';

  @override
  String get dngExpTreasure => 'Tesoro — reclama oro y fragmentos';

  @override
  String get dngExpShrine => 'Santuario — elige una bendición duradera';

  @override
  String get dngExpChest =>
      'Cofre cerrado — gasta fragmentos por un objeto raro';

  @override
  String get dngExpTrap => 'Trampa — daño inevitable';

  @override
  String get dngExpBoss => 'Jefe (cada 5 pisos) — alto riesgo, alta recompensa';

  @override
  String get dngBonesHint =>
      'Los enemigos muertos sueltan Huesos — gástalos en el Mercader Viajero.';

  @override
  String get dngExpectedLoot => 'BOTÍN ESPERADO';

  @override
  String get dngLootGold => 'Oro';

  @override
  String get dngLootGoldDetail =>
      'De combate, salas del tesoro y suministros de descanso';

  @override
  String get dngLootShards => 'Fragmentos';

  @override
  String get dngLootShardsDetail =>
      'Salas del tesoro y cofres durante la corrida';

  @override
  String get dngLootItems => 'Objetos';

  @override
  String dngLootItemsDetail(String tier) {
    return 'Nivel de objeto en tu profundidad: $tier  (élites y jefes sueltan mejor)';
  }

  @override
  String get dngLootMythril => 'Mitril';

  @override
  String dngLootMythrilDetail(int a, int b) {
    return '~$a en el piso 5  •  ~$b en el piso 10';
  }

  @override
  String dngYourBest(int f, int m) {
    return 'Tu mejor: piso $f  •  ~$m mitril';
  }

  @override
  String get dngNoRecord => 'Sin récord aún';

  @override
  String dngDeepestFloor(int f) {
    return 'Piso más profundo: $f';
  }

  @override
  String dngDailyAttempts(int r, int max) {
    return 'Intentos diarios: $r / $max';
  }

  @override
  String dngEnterTier(int tier) {
    return 'ENTRAR  NIVEL $tier';
  }

  @override
  String get dngNoAttempts => 'SIN INTENTOS RESTANTES';

  @override
  String dngBuyExtra(int cost) {
    return '$cost ZCoins — Comprar 1 intento extra';
  }

  @override
  String get dngBossFloor => '☠ PISO DEL JEFE';

  @override
  String dngBossIn(int n) {
    return '☠ Jefe en $n';
  }

  @override
  String get dngChoosePath => 'ELIGE TU CAMINO';

  @override
  String get dngNextBoss => '☠ PRÓXIMO PISO: JEFE';

  @override
  String get dngMystery => 'MISTERIO';

  @override
  String get dngGoblin => '💰 TRASGO DEL TESORO';

  @override
  String get dngEnter => 'ENTRAR';

  @override
  String get dngMystery1 => 'Una puerta sin marcar.';

  @override
  String get dngMystery2 => '¿Fortuna o peligro?';

  @override
  String dngGoblinHp(Object hp) {
    return '$hp HP  •  huye después de 5 rondas';
  }

  @override
  String get dngGoblinReward => '¡6× oro si lo matas a tiempo!';

  @override
  String get dngGuaranteedDrop => 'Caída de objeto garantizada';

  @override
  String get dngStrikesFirst => 'Ataca primero — mucho oro';

  @override
  String get dngDoorBlessing => 'Una bendición...';

  @override
  String get dngDoorCurse => '¿o una maldición?';

  @override
  String get dngMakeCamp => 'Acampar';

  @override
  String get dngRecoverHp => 'Recuperar HP';

  @override
  String get dngRareInside => 'Objeto raro dentro';

  @override
  String dngShardsToOpen(Object n) {
    return '$n fragmentos para abrir';
  }

  @override
  String dngPlusGold(Object g) {
    return '+$g oro';
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
  String get dngEnemy => 'Enemigo';

  @override
  String get dngSpeedNeeds =>
      'Mayor velocidad requiere Speed Boost / Pase Premium.';

  @override
  String get dngTreasureFound => '¡Tesoro Encontrado!';

  @override
  String get dngCursed => '✸ ¡MALDITO!';

  @override
  String get dngBlessed => '✧ ¡BENDECIDO!';

  @override
  String get dngDarkToll => 'La oscuridad cobra su precio...';

  @override
  String get dngAncientPower => 'El poder ancestral fluye a través de ti.';

  @override
  String get dngLightShadow => 'La luz y la sombra se atan a tu destino.';

  @override
  String get dngShrineCorrupted => 'Santuario Corrupto';

  @override
  String get dngShrineBlessed => 'Santuario Bendecido';

  @override
  String get dngShrineAncient => 'Santuario Ancestral';

  @override
  String get dngShrineCorruptedFlavor =>
      'Las energías oscuras pulsan y se retuercen. Una maldición es segura — pero el poder aguarda.';

  @override
  String get dngShrineBlessedFlavor =>
      'Una cálida luz divina emana de este lugar. Una bendición está garantizada.';

  @override
  String get dngShrineTwinFlavor =>
      'Dos fuerzas se agitan en su interior — recibirás tanto una bendición como una maldición.';

  @override
  String get dngShrineNormalFlavor =>
      'Un santuario misterioso pulsa con energía desconocida.\nEntra para recibir una bendición... o una maldición.\nNo sabrás cuál hasta que sea demasiado tarde.';

  @override
  String get dngAcceptCurse => 'ACEPTAR LA MALDICIÓN';

  @override
  String get dngReceiveBlessing => 'RECIBIR BENDICIÓN';

  @override
  String get dngEnterTwin => 'ENTRAR  (2 EFECTOS)';

  @override
  String get dngEnterShrine => 'ENTRAR AL SANTUARIO';

  @override
  String dngActiveEffects(int n) {
    return 'Efectos activos: $n';
  }

  @override
  String get dngSkip => 'OMITIR';

  @override
  String dngGuaranteeBless(int c) {
    return '✧  GARANTIZAR BENDICIÓN  ($c ◆)';
  }

  @override
  String dngTrapDamage(int dmg, int pct) {
    return 'Recibirás $dmg de daño ($pct% del HP máximo).';
  }

  @override
  String get dngLockedChest => 'Cofre Cerrado';

  @override
  String get dngChestContains => 'Contiene un objeto raro o épico.';

  @override
  String dngCostShards(Object cost) {
    return '$cost fragmentos';
  }

  @override
  String dngHave(int n) {
    return '(tienes $n)';
  }

  @override
  String dngCostZcoins(int cost) {
    return '$cost ZCoins';
  }

  @override
  String get dngMerchantQuote =>
      '\"Huesos por chucherías, viajero. Más huesos, mejores mercancías.\"';

  @override
  String dngBones(int n) {
    return '🦴  $n Huesos';
  }

  @override
  String dngBoneCost(int c) {
    return '$c 🦴';
  }

  @override
  String get dngClaimRelic => '☠ JEFE ELIMINADO — RECLAMA UNA RELIQUIA';

  @override
  String get dngSkipDescend => 'OMITIR — DESCENDER';

  @override
  String get dngReturn => 'VOLVER';

  @override
  String dngDescendTo(int n) {
    return 'DESCENDER AL PISO $n';
  }

  @override
  String get dngFallen => '☠ Caído';

  @override
  String get dngGotAway => '💰 ¡Se escapó!';

  @override
  String get dngVictory => '✓ Victoria';

  @override
  String dngAmbushHit(int n) {
    return 'El golpe de emboscada infligió $n antes del combate.';
  }

  @override
  String dngItemToBag(String name, String label) {
    return '✦ $name ($label) → Bolsa';
  }

  @override
  String get dngRested => '⊕ Descansado';

  @override
  String get dngTreasureCollected => '✦ Tesoro recolectado';

  @override
  String get dngBlessingReceived => '✧ Bendición recibida';

  @override
  String get dngSlainTrap => '☠ Muerto por la trampa';

  @override
  String get dngTrapSurvived => '✸ Trampa sobrevivida';

  @override
  String get dngChestOpened => '◆ Cofre abierto';

  @override
  String get dngLootAdded => 'Tu botín ya ha sido añadido a tu cuenta.';

  @override
  String dngLordFallen(int z, int g) {
    return '¡El Señor de la Mazmorra ha caído!\n+5 mitril  •  +$z Z-Coins  •  +$g oro  •  objeto de bono';
  }

  @override
  String dngTierN(int t) {
    return 'NIVEL $t';
  }

  @override
  String get dngFloor => 'PISO';

  @override
  String get dngRooms => 'HABITACIONES';

  @override
  String get dngBosses => 'JEFES';

  @override
  String get dngGold => 'ORO';

  @override
  String get dngShards => 'FRAGMENTOS';

  @override
  String dngTierCleared(int t) {
    return '✓ Nivel $t limpiado — ¡AUTO desbloqueado!';
  }

  @override
  String get dngNewRecord => '★ ¡Nuevo récord!';

  @override
  String get dngAllLootAdded => 'Todo el botín ha sido añadido a tu cuenta.';

  @override
  String get dngYouFallen => 'HAS CAÍDO';

  @override
  String get dngCleared => '¡MAZMORRA LIMPIADA!';

  @override
  String get dngRunEnded => 'CORRIDA TERMINADA';

  @override
  String get dngAutoLocked => '🔒 AUTO';

  @override
  String get dngStop => '◉ DETENER';

  @override
  String get dngAuto => '✦ AUTO';

  @override
  String get dngRunAgain => 'CORRER DE NUEVO';

  @override
  String get dngReturnHall => 'VOLVER AL SALÓN';

  @override
  String get auraEquipped => 'EQUIPADO';

  @override
  String get auraOn => 'ACTIVADO';

  @override
  String auraCost(int n) {
    return 'Costo: $n zcoins';
  }

  @override
  String auraUnlockTitle(String name) {
    return '¿Desbloquear $name?';
  }

  @override
  String get auraAllAuras => 'TODAS LAS AURAS';

  @override
  String get auraAllSkins => 'TODAS LAS SKINS';

  @override
  String get auraAllPets => 'TODAS LAS MASCOTAS';

  @override
  String get auraRemoveAura => 'Quitar aura';

  @override
  String get auraRemoveSkin => 'Quitar skin';

  @override
  String get auraDismissPet => 'Despedir mascota';

  @override
  String get auraBattleCompanion => 'COMPAÑERO DE BATALLA';

  @override
  String get auraWaystones => 'PIEDRAS DE CAMINO';

  @override
  String get auraAttackEffects => 'EFECTOS DE ATAQUE';

  @override
  String get auraCharSlots => 'RANURAS DE PERSONAJE';

  @override
  String get auraCompanionNote =>
      'Solo un compañero puede estar activo a la vez. Cada uno otorga un pequeño bono pasivo.';

  @override
  String get auraBeforeAfter => 'Antes / Después';

  @override
  String get auraAllSlots => 'Las 12 ranuras están desbloqueadas.';

  @override
  String auraAdoptTitle(String name) {
    return '¿Adoptar $name?';
  }

  @override
  String auraPetBonus(String label) {
    return '✦ $label';
  }

  @override
  String get auraMaxEvolution => '★★ EVOLUCIÓN MÁXIMA';

  @override
  String auraOwned(Object count) {
    return 'Poseídos: $count';
  }

  @override
  String auraWaystoneDesc(Object h, String m) {
    return '${h}h  ·  $m× ingresos inactivos';
  }

  @override
  String auraHitEvery(String text) {
    return '\"$text\" en cada golpe';
  }

  @override
  String auraSlotN(Object n) {
    return 'Ranura $n';
  }

  @override
  String get auraAddSlot => 'Añadir una ranura de guardado de personaje más.';

  @override
  String get auraUnlock => 'DESBLOQUEAR';

  @override
  String get auraAdopt => 'ADOPTAR';

  @override
  String get auraBuy => 'COMPRAR';

  @override
  String get auraEvolve => 'EVOLUCIONAR';

  @override
  String get auraEquip => 'EQUIPAR';

  @override
  String get auraActive => 'ACTIVO';

  @override
  String get auraSendOut => 'ENVIAR';

  @override
  String get auraStackAuras =>
      'Los bonos de cada aura que POSEES se acumulan automáticamente — los conservas todos. Equipa una solo para elegir qué brillo mostrar.';

  @override
  String get auraStackSkins =>
      'Los bonos de cada skin que POSEES se acumulan automáticamente — los conservas todos. Equipa una solo para elegir qué aspecto llevar.';

  @override
  String get armTabUniques => 'ÚNICOS';

  @override
  String get armTabMythic => 'MÍTICO';

  @override
  String get armTabSets => 'OBJETOS DE SET';

  @override
  String get armTabArtifacts => 'ARTEFACTOS';

  @override
  String get armNoLegendaries => 'No hay legendarios para esta clase.';

  @override
  String armClassUniques(int count) {
    return '$count Únicos de Clase';
  }

  @override
  String get armOwned => 'POSEÍDO';

  @override
  String armSlotReqLevel(String slot, int lvl) {
    return '$slot  •  Nivel mín. $lvl';
  }

  @override
  String get armStats => 'ESTADÍSTICAS';

  @override
  String get armAbilityEnh => 'MEJORA DE HABILIDAD';

  @override
  String armAbilityDamage(String x) {
    return '• Daño de habilidad ×$x';
  }

  @override
  String armAbilityDuration(Object n) {
    return '• +$n rondas de duración';
  }

  @override
  String armAbilityCooldown(String v) {
    return '• $v rondas de enfriamiento';
  }

  @override
  String armOnCast(String desc) {
    return '• Al lanzar: $desc';
  }

  @override
  String get armHowToFind => 'CÓMO ENCONTRAR';

  @override
  String get armDropCampaign => 'Jefes de campaña';

  @override
  String get armDropTower => 'Jefes de Ascensión de la Torre';

  @override
  String get armDropBossRush => 'Corridas de Boss Rush';

  @override
  String get armDropGauntlet => 'Limpieza de Gauntlet';

  @override
  String get armRate2 => '2% por muerte de jefe';

  @override
  String get armRate03 => '0,3% por muerte de jefe';

  @override
  String get armRateRare => 'Caída de bono raro';

  @override
  String get armDropsClassSpecific =>
      'Las caídas son específicas de clase — solo pueden caer objetos para tu clase.';

  @override
  String get armNoMythic => 'Sin objetos Míticos aún';

  @override
  String get armMythicHint =>
      'Derrota jefes de campaña para un 0,5% de probabilidad por muerte.';

  @override
  String get armMythicItems => 'Objetos Míticos';

  @override
  String armSlotLv(String slot, int lvl) {
    return '$slot  •  Nv$lvl';
  }

  @override
  String armKeyword(String name) {
    return 'palabra clave $name';
  }

  @override
  String get armSetItemsTitle => 'Objetos de Set';

  @override
  String armFraction(int a, int b) {
    return '$a / $b';
  }

  @override
  String get armEquippedLower => 'equipado';

  @override
  String get armSetBonuses => 'BONOS DE SET';

  @override
  String armPc(Object n) {
    return '${n}pzs';
  }

  @override
  String get armUniqueBlurb =>
      'Los objetos únicos están ligados a la clase y mejoran drásticamente tus habilidades. Cada uno amplifica una habilidad de clase específica. Tasa de caída: 2% por muerte de jefe.';

  @override
  String get armMythicBlurb =>
      'El nivel generado proceduralmente más raro. Los objetos míticos tienen 3 estadísticas con los valores más altos posibles y un poderoso efecto de palabra clave. Tasa de caída: 0,5% por muerte de jefe.';

  @override
  String get armSetBlurb =>
      'Colecciona múltiples piezas del mismo set para desbloquear poderosos bonos. Los sets ahora requieren 6 piezas para el bono completo. Tasa de caída: 0,3% por muerte de jefe.';

  @override
  String armArtifactBlurb(int count) {
    return '$count sets de artefactos de tres piezas. Equipa 2 piezas verdes coincidentes en la cuadrícula de artefactos para un bono parcial, las 3 para el bono completo. Las piezas de set caen de Mazmorras, Boss Rush y jefes de Campaña.';
  }

  @override
  String get armSetPieces => 'PIEZAS DEL SET';

  @override
  String get armArtifactSets => 'Sets de Artefactos';

  @override
  String armCollected(int a, int b) {
    return 'RECOLECTADO  $a / $b piezas distintas poseídas';
  }

  @override
  String endlessStage(int n) {
    return 'Etapa $n';
  }

  @override
  String endlessNextReward(int n) {
    return 'Próxima recompensa: Piso $n';
  }

  @override
  String get endlessChallengeBoss => 'DESAFIAR UN JEFE';

  @override
  String get endlessPremiumAutoClear =>
      '🔒  Alcanza la Etapa 5 de la campaña para limpiar jefes automáticamente';

  @override
  String get endlessRewards => 'RECOMPENSAS: ';

  @override
  String get endlessDrop => 'CAÍDA: ';

  @override
  String get endlessGold => 'ORO';

  @override
  String get endlessXp => 'XP';

  @override
  String get endlessRespawns => 'REAPARICIONES';

  @override
  String endlessTowerShards(String n) {
    return '+$n FRAGMENTOS DE TORRE';
  }

  @override
  String endlessMilestone(Object n) {
    return '★ HITO: $n MUERTES ★';
  }

  @override
  String endlessMilestoneReward(String gold, Object s) {
    return '+$gold ORO  +$s ◆';
  }

  @override
  String get endlessEnemyStirs => 'El enemigo se agita de nuevo...';

  @override
  String get endlessDefeatBody =>
      'Tu héroe fue superado.\nMejora tus estadísticas e inténtalo de nuevo.';

  @override
  String get pvpNoStamina => '¡Sin resistencia! Se recarga 1 cada 45 minutos.';

  @override
  String get pvpTitle => 'ARENA PVP';

  @override
  String get pvpSimLab => 'Laboratorio Sim';

  @override
  String get pvpRefresh => 'Actualizar clasificación';

  @override
  String get pvpLeaderboard => 'CLASIFICACIÓN';

  @override
  String pvpToday(String label) {
    return 'HOY: $label';
  }

  @override
  String pvpWinsToday(Object wins, Object dmg) {
    return '$wins victorias hoy  •  $dmg daño total';
  }

  @override
  String get pvpClaimed => '✓ RECLAMADO';

  @override
  String get pvpNoChallengers => 'SIN RETADORES AÚN';

  @override
  String get pvpNoChallengersSub =>
      'Pelea un partido para unirte a la clasificación\ny ver cómo te comparas.';

  @override
  String pvpHpAc(Object hp, Object ac) {
    return 'HP:$hp  AC:$ac';
  }

  @override
  String get pvpStamina => 'RESISTENCIA  ';

  @override
  String get pvpStaminaTip =>
      'La resistencia recupera 1 corazón cada 45 minutos.';

  @override
  String get pvpRating => 'CALIFICACIÓN';

  @override
  String get pvpWins => 'VICTORIAS';

  @override
  String get pvpLosses => 'DERROTAS';

  @override
  String get pvpWL => 'V/D';

  @override
  String pvpLeague(String name) {
    return 'LIGA $name';
  }

  @override
  String get pvpNearRank => 'CERCA DE TU RANGO';

  @override
  String get pvpPlayersAbove => '— jugadores justo por encima de ti';

  @override
  String pvpClassLv(String cls, Object lvl) {
    return '$cls  Nv$lvl';
  }

  @override
  String get pvpChallenge => 'DESAFIAR';

  @override
  String get pvpBattleLog => 'REGISTRO DE BATALLA';

  @override
  String get pvpBattleLogTip => 'Registro de batalla';

  @override
  String get pvpNoCombat => 'Sin combate aún.';

  @override
  String get pvpClose => 'CERRAR';

  @override
  String pvpVs(String hero, String opp) {
    return 'PVP  —  $hero vs $opp';
  }

  @override
  String get pvpReturnArena => 'VOLVER A LA ARENA';

  @override
  String get pvpFighting => 'Peleando...';

  @override
  String invBagCount(Object n, Object cap) {
    return '($n/$cap)';
  }

  @override
  String invBuyTab(Object cost) {
    return '+ PESTAÑA  $cost';
  }

  @override
  String get invAutoEquip => 'AUTO EQUIPAR';

  @override
  String invTabN(Object n, Object count) {
    return 'PESTAÑA $n  ($count)';
  }

  @override
  String get invEquipment => 'EQUIPAMIENTO';

  @override
  String invBag(Object n, Object cap) {
    return 'BOLSA  ($n/$cap)';
  }

  @override
  String get invUnequip => 'Desequipar';

  @override
  String get invNoItems => 'No hay objetos en esta pestaña.';

  @override
  String invReqClass(String cls) {
    return 'Requiere $cls';
  }

  @override
  String invReqLevel(Object lvl) {
    return 'Requiere Nivel $lvl';
  }

  @override
  String invReqTier(Object t) {
    return 'Requiere Nivel $t';
  }

  @override
  String get invCannotEquip => 'No se puede equipar';

  @override
  String get invEquip => 'Equipar';

  @override
  String get invUnlock => 'Desbloquear 🔓';

  @override
  String get invLock => 'Bloquear 🔒';

  @override
  String get invDiscard => 'Descartar';

  @override
  String get invAny => 'Cualquiera';

  @override
  String invUniqueOnly(String cls) {
    return '★ Único — solo $cls';
  }

  @override
  String get invWrongClass => '(clase incorrecta)';

  @override
  String get invColStat => 'ESTAD';

  @override
  String get invColThis => 'ESTE';

  @override
  String get invColEqpd => 'EQUIP';

  @override
  String get invColDiff => 'DIF';

  @override
  String get invEmptySocket => 'Engarce vacío';

  @override
  String get invCraftGems => 'Crea gemas en Forja → pestaña Gemas';

  @override
  String get invRemove => 'QUITAR';

  @override
  String get invSocket => 'ENGARZAR';

  @override
  String invChooseGem(String name) {
    return 'Elige una gema para engarzar en $name';
  }

  @override
  String invOnThis(String slot, String bonus) {
    return 'En este(a) $slot: $bonus';
  }

  @override
  String get invRemoveGem => '¿Quitar Gema?';

  @override
  String get invDestroy => 'DESTRUIR';

  @override
  String get invSort => 'Ordenar:';

  @override
  String get invFilter => 'Filtrar:';

  @override
  String invGemsAvailable(Object count) {
    return '$count gema(s) disponible(s) para engarzar';
  }

  @override
  String invRemoveBody(String name) {
    return '$name será destruida. Las gemas no se pueden recuperar una vez quitadas.';
  }

  @override
  String invReplaceBody(String old, String gnew) {
    return '$old será destruida y reemplazada por $gnew.';
  }

  @override
  String get npcRoster => 'PLANTILLA';

  @override
  String get npcSynergies => 'SINERGIAS';

  @override
  String get npcTitle => 'MERCENARIOS';

  @override
  String get npcTotalBonuses => 'BONOS ACTIVOS TOTALES';

  @override
  String get npcBattleParty => 'GRUPO DE BATALLA';

  @override
  String npcFielded(Object count, Object max) {
    return '$count / $max en campo';
  }

  @override
  String get npcUnknown => 'Mercenario Desconocido';

  @override
  String npcBattleAbility(String name) {
    return 'HABILIDAD DE BATALLA: $name';
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
    return 'ELEGIDO: $name';
  }

  @override
  String get npcMilestoneComplete => 'HITO COMPLETADO — RECLUTANDO...';

  @override
  String get npcMax => '★ MÁX';

  @override
  String get npcStarRank => 'RANGO DE ESTRELLAS';

  @override
  String npcStars(Object a, Object b) {
    return '$a / $b';
  }

  @override
  String get npcFullyAscended =>
      '★ TOTALMENTE ASCENDIDO — cada estrella añade +1 nivel efectivo.';

  @override
  String npcAscendStar(Object n) {
    return 'ASCENDER ★$n';
  }

  @override
  String npcYouHave(Object n) {
    return 'Tienes: $n Mitril';
  }

  @override
  String get npcStarInfo =>
      'Cada estrella = +1 nivel efectivo del bono de este mercenario.';

  @override
  String get npcPassiveOnly => 'Solo bonos pasivos — siempre activo.';

  @override
  String npcCostShards(Object n) {
    return 'Costo: ◆ $n Fragmentos';
  }

  @override
  String get npcTutorial =>
      'Los mercenarios son compañeros que se unen permanentemente al alcanzar ciertos hitos. 🤝 Cada uno proporciona bonos pasivos de combate en cada batalla y puede sinergizarse con otros para poder extra.';

  @override
  String npcRecruited(Object a, Object b) {
    return '$a / $b  reclutados';
  }

  @override
  String get npcNoMercs =>
      'No hay mercenarios reclutados aún. Cumple hitos para desbloquearlos.';

  @override
  String npcChipDamage(Object n) {
    return '+$n% Daño';
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
  String get shopTabBundles => 'PAQUETES';

  @override
  String get shopTabVip => 'VIP';

  @override
  String get shopTabStarter => 'INICIO';

  @override
  String get shopTabResources => 'RECURSOS';

  @override
  String get shopTabCosmetics => 'COSMÉTICOS';

  @override
  String get shopSecBundles => 'PAQUETES DE ZCOINS';

  @override
  String get shopSecBundlesSub => 'Moneda premium para la Tienda';

  @override
  String get shopSecVip => 'SUSCRIPCIONES VIP';

  @override
  String get shopSecVipSub => 'Ventajas y beneficios recurrentes';

  @override
  String get shopSecStarter => 'PAQUETES INICIO';

  @override
  String get shopSecStarterSub => 'Paquetes de compra única';

  @override
  String get shopSecResources => 'RECURSOS';

  @override
  String get shopSecResourcesSub => 'Gasta ZCoins en oro y materiales';

  @override
  String get shopSecAuras => 'AURAS';

  @override
  String get shopSecAurasSub =>
      'Equipa un brillo — los bonos de auras poseídas siempre se acumulan';

  @override
  String get shopSecBoosts => 'POTENCIADORES';

  @override
  String get shopSecBoostsSub => 'Potenciadores permanentes de estadísticas';

  @override
  String get shopSecTitles => 'TÍTULOS';

  @override
  String get shopSecTitlesSub => 'Un rango mostrado debajo de tu nombre';

  @override
  String get shopSecColours => 'COLORES DE NOMBRE';

  @override
  String get shopSecColoursSub => 'Color + brillo para el nombre de tu héroe';

  @override
  String get shopSecFrames => 'MARCOS';

  @override
  String get shopSecFramesSub => 'Un marco alrededor del retrato de tu héroe';

  @override
  String get shopSecSlots => 'RANURAS DE PERSONAJE';

  @override
  String get shopSecSlotsSub => 'Ranuras de guardado extra de personaje';

  @override
  String get shopPremiumArmor => 'ARMADURA DE CLASE PREMIUM';

  @override
  String shopEndgameSkin(String cls) {
    return '$cls · Skin endgame';
  }

  @override
  String get shopIncludedBonuses => 'BONOS INCLUIDOS';

  @override
  String get shopEverySkin => 'bono de cada skin de la tienda, combinados';

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
      'Tienda no disponible — inténtalo más tarde.';

  @override
  String get shopVipSub => 'SUSCRIPCIÓN VIP';

  @override
  String get shopSubscribed => '✓ SUSCRITO';

  @override
  String shopSubscribe(String price) {
    return 'SUSCRIBIRSE  $price';
  }

  @override
  String get shopEverythingPlus => 'Todo en el Pacto del Vanguardia, más:';

  @override
  String get shopIncludedPerks => 'VENTAJAS INCLUIDAS';

  @override
  String get shopGlow => '✦ BRILLO';

  @override
  String get shopExclusive => 'EXCLUSIVO';

  @override
  String get shopNoAd =>
      'No hay anuncio disponible ahora — inténtalo más tarde.';

  @override
  String get shopWatchAd => 'Ver un anuncio';

  @override
  String get shopComeBackTomorrow => '¡Vuelve mañana para más ZCoins gratis!';

  @override
  String get shopWait => 'ESPERA...';

  @override
  String get shopWatch => 'VER';

  @override
  String get shopRewardEarned => 'RECOMPENSA GANADA';

  @override
  String shopPlusZcoins(Object amount) {
    return '+$amount ZCoins';
  }

  @override
  String get shopCollect => 'RECOLECTAR';

  @override
  String get shopPurchasesRestored =>
      'Compras restauradas. Cualquier suscripción activa o paquetes han sido reaplicados.';

  @override
  String get shopRestorePurchases => 'Restaurar compras';

  @override
  String artSalvageTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Recuperar $count artefactos?',
      one: '¿Recuperar $count artefacto?',
    );
    return '$_temp0';
  }

  @override
  String get artSalvage => 'RECUPERAR';

  @override
  String artSalvaged(int n, Object gained) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Recuperados $n artefactos por ◆ $gained mitril.',
      one: 'Recuperado $n artefacto por ◆ $gained mitril.',
    );
    return '$_temp0';
  }

  @override
  String get artTable => 'MESA DE ARTEFACTOS';

  @override
  String artSlots(Object n, Object max) {
    return '$n/$max ranuras';
  }

  @override
  String artAutoEquipped(Object n) {
    return '$n mejores artefactos equipados automáticamente.';
  }

  @override
  String get artNoneToEquip => 'No hay artefactos para equipar.';

  @override
  String get artAutoEquip => '⚡ AUTO-EQUIPAR';

  @override
  String get artSalvageBtn => '♻ RECUPERAR';

  @override
  String get artTitle => 'ARTEFACTOS';

  @override
  String get artPlaceHint => 'Coloca artefactos en la mesa para ganar bonos.';

  @override
  String get artTableBonuses => 'BONOS DE LA MESA';

  @override
  String get artCollection => 'COLECCIÓN';

  @override
  String artCount(Object n) {
    return '($n)';
  }

  @override
  String artTapToPlace(String name) {
    return 'Toca una celda de la cuadrícula para colocar \"$name\"';
  }

  @override
  String get artTapCancel => 'toca de nuevo para cancelar';

  @override
  String get artSet => 'SET';

  @override
  String artUpgradeCost(Object cost) {
    return '$cost Mitril';
  }

  @override
  String artNoSets(Object n) {
    return 'Sin piezas de Set equipadas aún — $n sets para descubrir.';
  }

  @override
  String artCountOf3(Object count) {
    return '$count / 3';
  }

  @override
  String get artHowToGet => 'CÓMO OBTENER ARTEFACTOS';

  @override
  String get artRowCampaign => 'Jefes de Campaña';

  @override
  String get artRowCampaignDesc =>
      'aproximadamente un 25% de probabilidad de caer en cada muerte de jefe.';

  @override
  String get artRowDungeon => 'Corridas de Mazmorra';

  @override
  String get artRowDungeonDesc =>
      'cada jefe derrotado suelta uno — hasta 2 por corrida. La mejor granja constante.';

  @override
  String get artRowBossRush => 'Boss Rush';

  @override
  String get artRowBossRushDesc =>
      'limpia una corrida con rango A o S para ganar un artefacto.';

  @override
  String artSalvageBody(int count, Object mythril) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '¿Destruir permanentemente todos los $count artefactos no equipados por ◆ $mythril mitril? Los artefactos equipados se conservan.',
      one:
          '¿Destruir permanentemente $count artefacto no equipado por ◆ $mythril mitril? Los artefactos equipados se conservan.',
    );
    return '$_temp0';
  }

  @override
  String get artSetBlurb =>
      'Colecciona piezas de Set verdes coincidentes. 2 equipadas = bono parcial, las 3 = bono completo.';

  @override
  String get art2Set => '2-Set';

  @override
  String get art3Set => '3-Set';

  @override
  String get ptEssence => 'esencia';

  @override
  String ptTheClass(String cls) {
    return 'EL $cls';
  }

  @override
  String ptRespecBranch(String branch) {
    return '¿Reiniciar $branch?';
  }

  @override
  String ptRefund(Object refund) {
    return 'Reembolsar $refund esencia (75%)';
  }

  @override
  String get ptRespec => 'Reiniciar';

  @override
  String get ptCrossBranch => 'INTER-RAMA';

  @override
  String get ptFullRespec => '¿Reinicio completo?';

  @override
  String get ptRespec50 => 'Reiniciar (50 ZC)';

  @override
  String get ptFullRespecBtn => 'REINICIO COMPLETO (50 ZC)';

  @override
  String get ptTitle => 'ÁRBOL PASIVO';

  @override
  String get ptNow => 'AHORA';

  @override
  String ptUpgradeCost(Object cost) {
    return 'MEJORAR  ($cost ✦)';
  }

  @override
  String get ptLocked => 'BLOQUEADO — gasta 25 rangos en más ramas';

  @override
  String get ptLockedMax =>
      'BLOQUEADO — primero maximiza todos los nodos de rama';

  @override
  String ptMaxRankTotal(String val) {
    return 'RANGO MÁX — $val total';
  }

  @override
  String ptFullRespecBody(Object refund) {
    return 'Reinicia TODOS los nodos pasivos.\nReembolsar $refund esencia (60%).\nCosto: 50 zcoins.';
  }

  @override
  String ptNodesUnlocked(Object count) {
    return '$count nodos desbloqueados';
  }

  @override
  String get ptTutorial =>
      '¡Ganaste Fragmentos ◆ — gástalos aquí en nodos pasivos permanentes que nunca se reinician. Tu rama de clase está en la parte superior. Cada nodo sube al rango 5 para mayores bonos.';

  @override
  String ptBranchesAt25(Object count) {
    return '$count / 5 ramas en 25';
  }

  @override
  String get homeExp => 'EXP';

  @override
  String get homeResources => 'Recursos';

  @override
  String get homeGold => 'ORO';

  @override
  String get homeShards => 'FRAGMENTOS';

  @override
  String get homeZcoins => 'ZCOINS';

  @override
  String get homeMythril => 'MITRIL';

  @override
  String get homeIdleMin => 'INACT/min';

  @override
  String get homeGoldTip =>
      'Oro\nGanado en batallas e ingresos inactivos.\nGástalo en Mejoras y la Tienda.';

  @override
  String get homeShardsTip =>
      'Fragmentos\nGanados de muertes de enemigos, Mazmorras, Expediciones y Gauntlet.\nGástalos en mejoras de habilidades, mejoras de objetos y nodos del Árbol Pasivo.';

  @override
  String get homeZcoinsTip =>
      'ZCoins\nGanados de logros y cofres diarios.\nGástalos en la Tienda de Auras por skins, mascotas y auras.';

  @override
  String get homeMythrilTip =>
      'Mitril\nGanado de Mazmorras, Boss Rush e hitos de prestigio.\nGástalo en mejoras de Artefactos, rerolls de afijos de mazmorra y bendiciones de santuario.';

  @override
  String get homeIdleTip =>
      'Oro Inactivo / min\nOro ganado automáticamente cada minuto mientras estás sin conexión.\nAumenta con el nivel del héroe, mejoras pasivas y mascotas.';

  @override
  String get homeCurrentCampaign => 'Campaña Actual';

  @override
  String homeStage(Object n) {
    return 'ETAPA $n';
  }

  @override
  String homeNextGoal(Object reward) {
    return 'SIGUIENTE: DESBLOQUEAR $reward';
  }

  @override
  String homeNextGoalProgress(Object remaining, Object stage) {
    return 'Faltan $remaining etapas — supera la Etapa $stage';
  }

  @override
  String get demoModeLocked =>
      'Se desbloquea en el juego completo. La demo incluye la campaña completa — consigue el juego completo para Mazmorras, PvP y los niveles de dificultad del endgame.';

  @override
  String get demoFullGameCta => 'CONSIGUE EL JUEGO COMPLETO';

  @override
  String get homeSecCombat => 'COMBATE';

  @override
  String get homeSecSocial => 'SOCIAL';

  @override
  String get homeNavChallengeGauntlet => 'DESAFÍO GAUNTLET';

  @override
  String get homeNavBountyBoard => 'TABLÓN DE RECOMPENSAS';

  @override
  String get homeNavSeasonPass => 'PASE DE TEMPORADA';

  @override
  String get homeNavWorldEvent => 'EVENTO MUNDIAL';

  @override
  String get homeNavLeaderboard => 'CLASIFICACIÓN';

  @override
  String get homeNavChallengeModifiers => 'MODIFICADORES DE DESAFÍO';

  @override
  String get homeQuickAccess => 'ACCESO RÁPIDO';

  @override
  String get homeGettingStarted => 'PRIMEROS PASOS';

  @override
  String get homeStep1 => 'Gana tu primera batalla de Campaña';

  @override
  String get homeStep2 =>
      'Sube de nivel a tu héroe — visita la Hoja de Personaje';

  @override
  String get homeStep3 =>
      'Abre HÉROE y compra tu primera mejora de Puntuación de Habilidad';

  @override
  String get homeStep4 =>
      '¡Alcanza la Etapa 5 — se desbloquean Habilidades y Desafíos Diarios!';

  @override
  String get homeHeroSubtitle => 'MEJORAS  •  ARMERÍA  •  ALIADOS  •  CÓDICE';

  @override
  String get homeTomorrow => 'Mañana: ';

  @override
  String get dailyWeekly => 'SEMANAL';

  @override
  String get dailyClaimAll => 'RECLAMAR TODO';

  @override
  String get dailyHowItWorks => 'Cómo Funciona';

  @override
  String get dailyThisWeek => 'DESAFÍOS DE ESTA SEMANA';

  @override
  String dailyCompleted(Object claimed, Object total) {
    return '$claimed / $total completados';
  }

  @override
  String get dailyWeeklyLoading => 'Cargando desafíos semanales...';

  @override
  String get dailyAboutWeekly => 'Sobre los Desafíos Semanales';

  @override
  String get dailyReady => 'LISTO';

  @override
  String get dailyTodayProgress => 'PROGRESO DE HOY';

  @override
  String get dailyChest => 'COFRE DIARIO';

  @override
  String get dailyClaimedTomorrow => '¡Reclamado! Vuelve mañana.';

  @override
  String get dailyHintKill => 'Matar enemigos';

  @override
  String get dailyHintKillD => 'Pelea en modo Campaña o Infinito';

  @override
  String get dailyHintWin => 'Ganar batallas';

  @override
  String get dailyHintWinD => 'Derrotar a un enemigo cuenta como victoria';

  @override
  String get dailyHintBoss => 'Derrotar jefe';

  @override
  String get dailyHintBossD => 'Etapa 5, 10, 15, 20, 25 o Infinito cada 5';

  @override
  String get dailyHintAbility => 'Usar habilidades';

  @override
  String get dailyHintAbilityD =>
      'Las habilidades activas se activan automáticamente en batalla';

  @override
  String get dailyHintEquip => 'Equipar objeto';

  @override
  String get dailyHintEquipD =>
      'Toca un objeto de la bolsa → Equipar en Inventario';

  @override
  String get dailyHintGold => 'Alcanzar oro';

  @override
  String get dailyHintGoldD => 'Solo ten esa cantidad de oro en tu almacén';

  @override
  String get dailyHintDamage => 'Infligir daño';

  @override
  String get dailyHintDamageD => 'Daño acumulativo infligido en cualquier modo';

  @override
  String get dailyHintIdle => 'Recolectar inactivo';

  @override
  String get dailyHintIdleD =>
      'Toca la recompensa inactiva en la pantalla de inicio';

  @override
  String get dailyHintResets => 'Reinicios';

  @override
  String get dailyHintResetsD => 'Cada lunes — 5 nuevos desafíos cada semana';

  @override
  String get dailyHintRewards => 'Recompensas';

  @override
  String get dailyHintRewardsD =>
      'Mayores que las diarias: esencia, mitril, ZCoins';

  @override
  String get dailyHintSeasonXp => 'XP de Temporada';

  @override
  String get dailyHintSeasonXpD =>
      '+50 XP de temporada por desafío semanal reclamado';

  @override
  String get dailyHintProgress => 'Progreso';

  @override
  String get dailyHintProgressD =>
      'Cuenta desde la medianoche del lunes, no desde la reclamación';

  @override
  String get dailyTutorial =>
      'Completa los desafíos diarios para ganar oro, fragmentos, esencia y ZCoins. Los 7 desafíos se reinician cada día. ¡Complétalos todos para un cofre de bono!';

  @override
  String petOwned(Object a, Object b) {
    return '$a / $b  poseídos';
  }

  @override
  String get petTitle => 'COMPAÑEROS';

  @override
  String get petActiveBonuses => 'BONOS ACTIVOS (todas las mascotas poseídas)';

  @override
  String get petNoCompanion => 'Sin compañero equipado';

  @override
  String get petEquipHint => 'Equipa una mascota para que aparezca en batalla.';

  @override
  String get petPremium => '★ PREMIUM';

  @override
  String get petInBattle => 'EN BATALLA';

  @override
  String petRecruitTitle(String name) {
    return '¿Reclutar $name?';
  }

  @override
  String get petRecruit => 'RECLUTAR';

  @override
  String petEvolveTitle(String name) {
    return '¿Evolucionar $name?';
  }

  @override
  String petEvolveN(Object n) {
    return 'EVOLUCIONAR  Evo $n';
  }

  @override
  String get petTutorial =>
      'Las mascotas compañeras se unen a ti en batalla y acumulan sus bonos pasivamente — incluso las no equipadas. Equipa una para que aparezca a tu lado durante las peleas. Evoluciona las mascotas poseídas dos veces para duplicar el valor del bono.';

  @override
  String petRecruitBody(String desc, String bonus, Object cost) {
    return '$desc\n\nBono: $bonus\n\nCosto: $cost ZCoins';
  }

  @override
  String petEvolveBody(Object level, String bonus, Object cost) {
    return 'Mejora a Evolución $level.\n\nNuevo bono: +$bonus\nCosto: $cost ZCoins';
  }

  @override
  String get questTitle => 'CADENAS DE MISIONES';

  @override
  String get questAdventure => 'CADENA DE MISIONES DE AVENTURA';

  @override
  String get questAdventureSub =>
      'Aprende cada sistema del juego en el camino a la etapa 100.';

  @override
  String questUnlocksLv30(Object lvl) {
    return 'Se desbloquea en el Nivel 30  (actual: $lvl)';
  }

  @override
  String get questUltUnlocked => 'HABILIDAD DEFINITIVA DESBLOQUEADA';

  @override
  String questUltAvailable(String cls) {
    return 'La definitiva de $cls ya está disponible en batalla.';
  }

  @override
  String get questProgressLabel => 'Progreso';

  @override
  String questCompleteFirst(Object n) {
    return 'Completa la misión $n primero para desbloquear.';
  }

  @override
  String get questClaimReward => 'RECLAMAR RECOMPENSA';

  @override
  String get questRewardLabel => 'Recompensa: ';

  @override
  String questClassQuestline(String cls) {
    return 'MISIONES DE $cls';
  }

  @override
  String get questComplete5 =>
      'Completa 5 misiones para desbloquear la Habilidad Definitiva.';

  @override
  String get subTitle => 'ESPECIALIZACIÓN';

  @override
  String get subLevel50 => 'ESPECIALIZACIÓN NIVEL 50';

  @override
  String subChooseBody(String cls, Object cost) {
    return 'Elige una especialización para tu $cls. Otorga un poderoso bono culminante más bonos de estadísticas, aplicados de inmediato. Puedes cambiarlo después por $cost ZCoins.';
  }

  @override
  String subClassSpecs(String cls, Object n) {
    return 'ESPECIALIZACIONES DE $cls  ($n)';
  }

  @override
  String subUnlocksAt(Object lvl) {
    return 'La especialización se desbloquea en el Nivel $lvl.';
  }

  @override
  String subChooseTitle(String name) {
    return '¿Elegir $name?';
  }

  @override
  String get subStatBonuses => 'BONOS DE ESTADÍSTICAS';

  @override
  String get subCapstone => 'BONO CULMINANTE';

  @override
  String get subSpecialEffect => 'EFECTO ESPECIAL';

  @override
  String subChangeLater(Object cost) {
    return 'Puedes cambiar esto después por $cost ZCoins.';
  }

  @override
  String get subCouldNotSet =>
      'No se pudo establecer la especialización — inténtalo de nuevo.';

  @override
  String subChangeSpec(Object cost) {
    return 'CAMBIAR ESPECIALIZACIÓN  —  $cost ZCoins';
  }

  @override
  String get subChangeTitle => '¿Cambiar especialización?';

  @override
  String subChangeBody(Object cost, Object zcoins) {
    return '¿Gastar $cost ZCoins para borrar tu especialización actual y elegir una nueva?\n\nTus ZCoins: $zcoins';
  }

  @override
  String get subNotEnough => 'No tienes suficientes ZCoins para reiniciar.';

  @override
  String get subActiveSubclass => 'SUBCLASE ACTIVA';

  @override
  String get subChosen => 'ELEGIDA';

  @override
  String get subActive => 'ACTIVA';

  @override
  String get subChoosePath => 'ELEGIR ESTE CAMINO';

  @override
  String get expTitle => 'EXPEDICIONES';

  @override
  String get expCollectAll => 'RECOLECTAR TODO';

  @override
  String get expDispatchAll => 'DESPACHAR TODOS';

  @override
  String get expNoMercs => 'Sin Mercenarios Aún';

  @override
  String get expNoMercsSub =>
      'Recluta mercenarios desde la pestaña MERCENARIOS en el Centro del Héroe para enviarlos en expediciones.';

  @override
  String get expTodayLocations => 'UBICACIONES DE HOY';

  @override
  String expRefreshIn(String time) {
    return '🔄 $time';
  }

  @override
  String get expYourParty => 'TU GRUPO';

  @override
  String get expDispatch => 'DESPACHAR';

  @override
  String get expDone => 'LISTO';

  @override
  String get expCollectRewards => 'RECOLECTAR RECOMPENSAS';

  @override
  String get expInProgress => 'EN PROGRESO...';

  @override
  String expReturned(String name) {
    return '¡$name regresó!';
  }

  @override
  String get expDiscovery => '✦  DESCUBRIMIENTO';

  @override
  String get expGreat => 'GENIAL';

  @override
  String expDispatchMerc(String name) {
    return 'DESPACHAR $name';
  }

  @override
  String get expChooseLocation => 'ELEGIR UBICACIÓN';

  @override
  String get expDuration => 'DURACIÓN';

  @override
  String get expEstRewards => 'RECOMPENSAS ESTIMADAS';

  @override
  String get expSend => 'ENVIAR EN EXPEDICIÓN';

  @override
  String get acctSignInFailed => 'Inicio de sesión cancelado o fallido.';

  @override
  String get acctSignOutTitle => '¿Cerrar sesión?';

  @override
  String get acctSignOut => 'Cerrar sesión';

  @override
  String get acctSignOutBody =>
      'Tu guardado local se conserva. La sincronización en la nube se pausará hasta que inicies sesión de nuevo.';

  @override
  String get acctDeleteTitle => '¿Eliminar cuenta y datos?';

  @override
  String get acctDeleteAll => 'ELIMINAR TODO';

  @override
  String get acctDeleteBody =>
      'Esto elimina permanentemente tu cuenta y TODOS los datos — cada personaje, tu guardado en la nube, posición en PvP y entradas en clasificaciones. Esto no se puede deshacer.';

  @override
  String get acctDeleted => 'Cuenta eliminada';

  @override
  String get acctDeletedBody =>
      'Tu cuenta y todos los datos han sido eliminados. La aplicación se cerrará ahora.';

  @override
  String get acctClose => 'Cerrar';

  @override
  String get acctPlayer => 'Jugador';

  @override
  String get acctSyncNow => 'SINCRONIZAR AHORA';

  @override
  String get acctSignOutBtn => 'CERRAR SESIÓN';

  @override
  String get acctSignInGoogle => 'INICIAR SESIÓN CON GOOGLE';

  @override
  String get acctDeleteAccount => 'ELIMINAR CUENTA';

  @override
  String get acctDangerSub =>
      'Eliminar permanentemente tu cuenta y todos los datos asociados.';

  @override
  String get acctLinked => 'Cuenta de Google vinculada';

  @override
  String get acctNotSynced => 'Sin sincronizar en esta sesión aún';

  @override
  String get acctNoAccount => 'Sin cuenta vinculada';

  @override
  String get acctAboutCloud => 'SOBRE LOS GUARDADOS EN LA NUBE';

  @override
  String get acctCloud1 =>
      'Tu progreso se sincroniza automáticamente cada 5 minutos cuando estás conectado.';

  @override
  String get acctCloud2 =>
      'Juega en cualquier dispositivo Windows con la misma cuenta de Google.';

  @override
  String get acctCloud3 =>
      'Los guardados en la nube se almacenan de forma segura con tu cuenta de Google.';

  @override
  String get invhTabGear => 'EQUIPO';

  @override
  String get invhTabGems => 'GEMAS';

  @override
  String get invhTabRunes => 'RUNAS';

  @override
  String get invhArcaneDust => 'Polvo Arcano';

  @override
  String invhBag(Object n, Object max) {
    return 'Bolsa: $n/$max';
  }

  @override
  String get invhCraftGem => 'CREAR GEMA';

  @override
  String invhCraftTypeGem(String type, Object cost) {
    return 'CREAR GEMA $type  ($cost Polvo Arcano)';
  }

  @override
  String get invhOwnedGems => 'GEMAS POSEÍDAS';

  @override
  String invhDismantleBody(String bonus, Object dust) {
    return '$bonus\n\nEngárza en un ARMA para +%DMG, o ARMADURA para +%RES de este elemento de gema.\n\nDesmontar devuelve $dust Polvo Arcano.';
  }

  @override
  String invhDismantle(Object dust) {
    return 'DESMONTAR (+$dust Polvo Arcano)';
  }

  @override
  String invhGemTooltip(String name, String bonus) {
    return '$name\n$bonus\nToca para desmontar';
  }

  @override
  String get invhTutGear =>
      '¡Ha caído tu primera pieza de equipo! Equípala aquí para aumentar tus estadísticas.';

  @override
  String get invhTutForge =>
      'Combina dos objetos del mismo slot para crear una pieza de mayor rareza, o reforjar estadísticas.';

  @override
  String get invhTutRunes =>
      'Crea Runas para mejoras temporales de combate. Recolecta polvo desmantelando equipo.';

  @override
  String get invhTutArtifacts =>
      'Coloca artefactos en la cuadrícula para bonos pasivos permanentes.';

  @override
  String get invhNoGear =>
      'Sin equipo aún.\n¡Derrota enemigos para encontrar tu primer objeto!';

  @override
  String get ascTitle => 'ASCENSIÓN';

  @override
  String get ascMetaBoard => 'META-TABLERO';

  @override
  String ascApPoints(Object points) {
    return '$points AP';
  }

  @override
  String get ascLevelLabel => 'Nivel de Ascensión: ';

  @override
  String get ascPrestigeLabel => 'Nivel de Prestigio: ';

  @override
  String get ascBody =>
      'La Ascensión es el reinicio más profundo — convierte tus Renacimientos en Puntos de Ascensión (AP). Ganas 1 AP por cada Renacimiento sacrificado, así que cuantos más acumules antes de ascender, mayor será el pago.\n\nGasta AP de dos formas — ambas permanentes y sobreviven a todos los reinicios futuros:\n• El Meta-Tablero de abajo (XP, oro, daño, bonos de inactividad y prestigio)\n• Asciende tus habilidades de clase en la pantalla de Habilidades (+10% de poder por nivel, hasta 60 AP por personaje)\n\nCONSERVAS:  Bonos de Ascensión y AP gastado, Artefactos, Mitril, Fragmentos de Torre, Maestría Elemental.\nPIERDES:  todos los Renacimientos, nivel del héroe, oro, equipo, subclase, rangos de habilidades y progreso de campaña.';

  @override
  String ascRequires(Object prestige) {
    return 'Requiere Nivel de Prestigio 5 para Ascender  (actual: $prestige/5)';
  }

  @override
  String ascAscendAp(Object ap) {
    return 'ASCENDER  (+$ap AP)';
  }

  @override
  String get ascConfirmTitle => '¿Ascender?';

  @override
  String ascConfirmBody(Object rebirths, Object ap) {
    return 'Sacrificar $rebirths Renacimiento(s) por $ap Punto(s) de Ascensión.\n\nCONSERVAR: Bonos de Ascensión, Artefactos, Mitril, Fragmentos de Torre, Ascensiones de Habilidad.\nPERDER: todos los Renacimientos, nivel del héroe, oro, equipo, subclase, rangos de habilidades, progreso de campaña.\n\nEsto no se puede deshacer.';
  }

  @override
  String get weOmegaShop => 'TIENDA OMEGA';

  @override
  String get weNowHunting => 'CAZANDO AHORA';

  @override
  String get weDamageLabel => 'Daño: ';

  @override
  String weEndsIn(Object d, Object h, Object m) {
    return 'El evento termina en  ${d}d ${h}h ${m}m';
  }

  @override
  String get weHowToEarn => 'CÓMO GANAR TOKENS';

  @override
  String weHowToEarnDesc(String name) {
    return 'Los ${name}s tienen un 15% de probabilidad de aparecer durante cualquier batalla. Derrótales para ganar 1–3 Tokens de Evento cada uno.';
  }

  @override
  String get weEventBoss => '⚔ JEFE DEL EVENTO';

  @override
  String get weClaimLegendary =>
      'RECLAMAR EQUIPO LEGENDARIO  (1 🏆 Token de Jefe)';

  @override
  String weGearForged(String name, Object lv) {
    return '¡$name forjado en Nv$lv! Revisa tu bolsa.';
  }

  @override
  String weRewardClaimed(String name) {
    return '¡$name reclamado!';
  }

  @override
  String get gauLeaderboard => 'Clasificación del Gauntlet';

  @override
  String get gauRewardPreview => 'VISTA PREVIA DE RECOMPENSA (al limpiar)';

  @override
  String get gauAutoRestart => 'AUTO — reiniciando con tus modificadores—';

  @override
  String get gauBackToGauntlet => 'VOLVER AL GAUNTLET';

  @override
  String gauWave(Object n, Object total) {
    return 'OLA $n / $total';
  }

  @override
  String gauKills(Object kills) {
    return '$kills MUERTES';
  }

  @override
  String gauEssenceBonus(Object pct) {
    return '+$pct% esencia';
  }

  @override
  String get brLeaderboard => 'Clasificación del Boss Rush';

  @override
  String get brBestScore => 'MEJOR PUNTUACIÓN: ';

  @override
  String brBossProgress(Object n, Object total) {
    return 'JEFE $n / $total';
  }

  @override
  String get brPlayAgain => 'JUGAR DE NUEVO';

  @override
  String get brPossibleRewards => 'POSIBLES RECOMPENSAS';

  @override
  String get brRewShards => 'Fragmentos';

  @override
  String get brRewShardsD => '10 por jefe  ·  +30 en limpieza completa';

  @override
  String get brRewEchoes => 'Ecos';

  @override
  String get brRewEchoesD => '6 por jefe  ·  +25 en limpieza completa';

  @override
  String get brRewZcoins => 'ZCoins';

  @override
  String get brRewZcoinsD => '15 en una limpieza completa';

  @override
  String get brRewMythril => 'Mitril';

  @override
  String get brRewMythrilD => 'Escalado por rango final';

  @override
  String get brRewArtifact => 'Artefacto';

  @override
  String get brRewArtifactD =>
      'Caída de probabilidad en limpiezas de rango A / S';

  @override
  String get prgShop => 'TIENDA PÁRAGON';

  @override
  String get prgActiveBonuses => 'BONOS ACTIVOS';

  @override
  String get prgBoard => '✦ TABLERO PÁRAGON';

  @override
  String get prgBoardHint =>
      'Invierte puntos en una dirección — los rangos escalan para siempre.';

  @override
  String prgRank(Object rank) {
    return 'Rango $rank';
  }

  @override
  String get prgTutorial =>
      '✦ Los Puntos de Páragon se ganan subiendo de nivel — 1 por nivel. Gástalos en el Tablero Páragon y la Tienda de abajo para poder permanente que nunca se reinicia.';

  @override
  String get prgShopSub =>
      'Gasta Puntos de Páragon en mejoras permanentes que persisten en todas las corridas futuras.';

  @override
  String achClaimedTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🏆  $count LOGROS RECLAMADOS',
      one: '🏆  $count LOGRO RECLAMADO',
    );
    return '$_temp0';
  }

  @override
  String get achYouReceived => 'Recibiste:';

  @override
  String get achNice => '¡GENIAL!';

  @override
  String achClaimAll(Object n) {
    return 'RECLAMAR TODO ($n)';
  }

  @override
  String get achEconomy => 'ECONOMÍA Y SISTEMAS';

  @override
  String get achProgress => 'PROGRESO';

  @override
  String achClaimed(Object claimed, Object total) {
    return '$claimed / $total reclamados';
  }

  @override
  String achReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count logros listos para reclamar!',
      one: '$count logro listo para reclamar!',
    );
    return '$_temp0';
  }

  @override
  String get runeTitle => 'RUNAS DE HABILIDAD';

  @override
  String get runeArcaneDust => '🌀 Polvo Arcano: ';

  @override
  String runeOwned(Object a, Object b) {
    return '📜 Poseídas: $a/$b';
  }

  @override
  String get runeNone => 'Sin runas disponibles para esta clase.';

  @override
  String get runeAppBar => 'RUNAS';

  @override
  String get runeSocketed => 'ENGARZADA';

  @override
  String get runeNotFound =>
      'No encontrada aún — cae de jefes, mazmorras, gauntlet y expediciones.';

  @override
  String get runeEquipFirst =>
      'Equipa un anillo o amuleto para engarzar esta runa.';

  @override
  String runeSocketInto(String name, Object cost) {
    return 'Engarzar → $name  (🌀 $cost)';
  }

  @override
  String get runeBody =>
      'Engárza runas para mejorar permanentemente tus habilidades.\nCada runa modifica una habilidad específica — aumentando daño, duración o enfriamiento.\nCuesta Polvo Arcano de desencantamiento de equipo, gemas y runas.';

  @override
  String get achTutorial =>
      '¡Derrotaste a tu primer jefe! 🏆 Los logros rastrean hitos y recompensan ZCoins y Fragmentos — reclámalos aquí y vuelve a menudo.';

  @override
  String get bbLocked => 'RECOMPENSAS DE JEFE BLOQUEADAS';

  @override
  String get bbLockedSub =>
      'Alcanza la etapa 20 de campaña para comenzar a cazar jefes por recompensas.';

  @override
  String bbTitle(Object t) {
    return 'RECOMPENSAS DE JEFE  •  NIVEL $t';
  }

  @override
  String get bbDesc =>
      'Mata a cada jefe de campaña por su recompensa. Alcanza un nuevo nivel para un nuevo conjunto con mayores recompensas.';

  @override
  String get bbNoBounties => 'No hay recompensas disponibles.';

  @override
  String bbStageLv(Object n, Object lv) {
    return 'Etapa $n de Campaña  •  Nv $lv';
  }

  @override
  String bbSlain(String name, String detail) {
    return '¡$name eliminado!  $detail';
  }

  @override
  String bbStage(Object n) {
    return 'Etapa $n';
  }

  @override
  String bbGearReward(String rarity) {
    return '🎁 Equipo $rarity';
  }

  @override
  String bestTotalKills(Object n) {
    return '$n muertes totales';
  }

  @override
  String get bestTypeMaxed => 'TIPO MAXIMIZADO';

  @override
  String bestGoldBonus(Object pct) {
    return '+$pct% oro';
  }

  @override
  String get bestKilled => 'eliminado';

  @override
  String bestNextDmg(Object n) {
    return 'siguiente +1% daño en $n muertes';
  }

  @override
  String get lsTitle => 'INICIO DE SESIÓN DIARIO';

  @override
  String get lsComeBack => '¡Vuelve mañana por tu próxima recompensa!';

  @override
  String lsStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '$count día',
    );
    return '$_temp0';
  }

  @override
  String lsClaimReward(String label) {
    return 'RECLAMAR  $label';
  }

  @override
  String get lsFullCycle => 'CICLO COMPLETO DE 30 DÍAS';

  @override
  String lsDay(Object d) {
    return 'Día $d';
  }

  @override
  String get lsToday => 'HOY';

  @override
  String get dashTitle => 'HOJA DE PERSONAJE';

  @override
  String get dashDailyReady => '¡Desafío diario listo para reclamar!';

  @override
  String get dashAbilityAfford =>
      'Mejora de habilidad asequible — visita HABILIDADES';

  @override
  String get dashPassiveAfford => 'Mejora pasiva asequible — visita PASIVAS';

  @override
  String get dashEndlessAfford => 'Mejora infinita asequible — visita MEJORAS';

  @override
  String get dashNextAction => 'PRÓXIMA ACCIÓN';

  @override
  String get dashIncomeSummary => 'RESUMEN DE INGRESOS';

  @override
  String get dashIdleGold => 'Oro inactivo';

  @override
  String get dashBattleKill => 'Batalla/muerte';

  @override
  String get dashExpeditions => 'Expediciones';

  @override
  String get dashAchievementsNearby => 'LOGROS CERCANOS';

  @override
  String dashDayLoginReward(Object day) {
    return 'RECOMPENSA DE INICIO DE SESIÓN DÍA $day';
  }

  @override
  String dashExpReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expediciones listas para recolectar!',
      one: '$count expedición lista para recolectar!',
    );
    return '$_temp0';
  }

  @override
  String dashMercsIdle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mercenarios inactivos — despachar en expedición',
      one: '$count mercenario inactivo — despachar en expedición',
    );
    return '$_temp0';
  }

  @override
  String get emTitle => 'MAESTRÍA ELEMENTAL';

  @override
  String emShards(Object n) {
    return '$n Fragmentos';
  }

  @override
  String get emUp => 'SUBIR';

  @override
  String get spResetsMonthly => '📅 Se reinicia mensualmente';

  @override
  String get spUnlockPremium =>
      'Desbloquear Pase Premium — 2× XP + pista premium';

  @override
  String get spFree => 'GRATIS';

  @override
  String get spPremium => '👑 PREMIUM';

  @override
  String get spTier => 'Nivel';

  @override
  String spClaimed(Object reward) {
    return 'Reclamado $reward';
  }

  @override
  String get spAllUnlocked =>
      '¡Todos los niveles desbloqueados — buen trabajo!';

  @override
  String spXpToTier(Object xp, Object next, Object tier) {
    return '$xp / $next XP al Nivel $tier';
  }

  @override
  String spClaimedN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Reclamadas $n recompensas',
      one: 'Reclamada 1 recompensa',
    );
    return '$_temp0';
  }

  @override
  String get spNothingToClaim => 'Nada que reclamar';

  @override
  String get euEchoes => 'Ecos';

  @override
  String get euYourBalance => 'Tu saldo';

  @override
  String get euEchoesCap => 'ECOS';

  @override
  String get euTutorial =>
      'Las corridas de Gauntlet ganan Ecos 🔊 — gástalos aquí en mejoras de combate permanentes que nunca se reinician. Estos son algunos de los bonos más poderosos del juego.';

  @override
  String get euPermanent =>
      'Las mejoras son permanentes por personaje. Los bonos se aplican en todos los modos de juego.';

  @override
  String euForLv(Object n) {
    return 'para Nv $n';
  }

  @override
  String get euActive => 'ACTIVO';

  @override
  String get lbRefresh => 'Actualizar';

  @override
  String get lbNoScores => 'Sin puntuaciones aún — ¡sé el primero!';

  @override
  String get lbPersonalBest => 'Tu mejor marca personal';

  @override
  String get lbRank => 'RANGO';

  @override
  String get lbYou => 'TÚ';

  @override
  String get lbError => 'No se pudo cargar la clasificación.';

  @override
  String get lbNotRanked => 'Sin rango aún';

  @override
  String get cmTitle => 'MODIFICADORES DE DESAFÍO';

  @override
  String get cmOptionalHandicaps => 'DESVENTAJAS OPCIONALES';

  @override
  String get cmActive => 'Activo: ';

  @override
  String get cmClear => 'LIMPIAR';

  @override
  String get cmDesc =>
      'Activa hasta un modificador antes de entrar a Campaña o Mazmorra. Los modificadores hacen las batallas más difíciles pero aumentan las recompensas de fragmentos por muerte.';

  @override
  String cmEssence(Object pct) {
    return '+$pct% esencia';
  }

  @override
  String cmEnemyHp(Object mult) {
    return 'HP del Enemigo ×$mult';
  }

  @override
  String cmEnemyAtk(Object mult) {
    return 'ATK del Enemigo ×$mult';
  }

  @override
  String cmHeroHp(Object mult) {
    return 'HP del Héroe ×$mult';
  }

  @override
  String get wClose => 'CERRAR';

  @override
  String get battleLog => 'REGISTRO DE BATALLA';

  @override
  String get buffDodge => 'ESQUIVAR';

  @override
  String get buffStun => 'ATURDIR';

  @override
  String get dhPowerTip =>
      'Poder Medieval — puntuación combinada de todas tus mejoras,\nequipo, pasivas, prestigio, artefactos y aliados.';

  @override
  String dhHpTip(Object regen) {
    return 'Puntos de Vida — llega a 0 y pierdes la batalla.\nRegeneración: $regen HP/ronda';
  }

  @override
  String dhXpTip(Object xp, Object lv, Object next) {
    return 'Experiencia — alcanza $xp para subir de nivel.\nNivel $lv → $next';
  }

  @override
  String get dhNice => 'GENIAL';

  @override
  String get bspAbilities => 'HABILIDADES';

  @override
  String get bspMercs => 'MERCENARIOS';

  @override
  String get bspEnemyStun => 'ATURDIR Enemigo';

  @override
  String get bspPassive => 'PASIVA';

  @override
  String bspDescAtk(Object pct) {
    return 'Tu héroe inflige +$pct% de daño por golpe.';
  }

  @override
  String bspDescArmor(Object pct) {
    return '+$pct% de Clase de Armadura — reduce el daño entrante del enemigo.';
  }

  @override
  String get bspDescDodge =>
      'Tu héroe esquivará completamente el próximo ataque enemigo.';

  @override
  String bspDescAura(Object hp) {
    return 'Aura de curación — restaura $hp HP al inicio de cada ronda.';
  }

  @override
  String bspDescDot(Object dmg) {
    return 'Daño en el tiempo — el enemigo recibe $dmg de daño cada ronda.';
  }

  @override
  String get bspDescStun => 'El enemigo está aturdido y se salta su ataque.';

  @override
  String get baMercAbility => 'HABILIDAD DEL MERCENARIO';

  @override
  String get tsCleared => 'LIMPIADO';

  @override
  String get sgFullyUpgraded => 'TOTALMENTE MEJORADO';

  @override
  String sgNeedGold(Object cost) {
    return 'Necesitas $cost oro para mejorar';
  }

  @override
  String get fsVictory => 'VICTORIA';

  @override
  String get fsDefeat => 'DERROTA';

  @override
  String fsVs(String enemy, Object rounds) {
    return 'vs $enemy  ·  $rounds rondas';
  }

  @override
  String get fsAbilitiesUsed => 'HABILIDADES USADAS';

  @override
  String get wnTitle => 'NOVEDADES';

  @override
  String get wnLatest => 'LO MÁS RECIENTE';

  @override
  String get zcShards => 'Fragmentos';

  @override
  String get idbNoItem => 'Sin objeto equipado — ¡mejora directa!';

  @override
  String get absTitle => 'PUNTUACIONES DE HABILIDAD';

  @override
  String get absBanner =>
      'Las Puntuaciones de Habilidad son mejoras permanentes compradas con oro.\nMejora cualquier puntuación libremente — el oro es el único requisito.';

  @override
  String get absMaxed => 'MAXIMIZADO';

  @override
  String absNext(Object cost) {
    return 'Siguiente: $cost oro';
  }

  @override
  String absRankOf(Object rank, Object max) {
    return 'Rango $rank / $max';
  }

  @override
  String get bestUndiscovered =>
      'Mata a esta criatura para revelar sus secretos.';

  @override
  String shopAdOffer(Object n, Object left, Object max) {
    return 'Gana $n ZCoins por anuncio  •  $left/$max restantes';
  }

  @override
  String get shopLifetimeTitle => 'Pacto Eterno';

  @override
  String get shopLifetimeTagline =>
      'Una compra. Todos los beneficios premium. Para siempre.';

  @override
  String get shopLifetimeBadge => 'MEJOR OFERTA';

  @override
  String get shopLifetimeOwned => '✓ DESBLOQUEADO PARA SIEMPRE';

  @override
  String shopLifetimeBuy(Object price) {
    return 'DESBLOQUEAR PARA SIEMPRE  ·  $price';
  }

  @override
  String get shopLifetimeIncludes => 'TODO INCLUIDO';

  @override
  String get shopLifetimePerk1 =>
      'Todos los beneficios de la Corona Ascendente';

  @override
  String get shopLifetimePerk2 => '3× velocidad de combate';

  @override
  String get shopLifetimePerk3 => 'Campaña Automática';

  @override
  String get shopLifetimePerk4 => '+50% de oro inactivo';

  @override
  String get shopLifetimePerk5 => '2× XP del Pase de Temporada';

  @override
  String get shopLifetimePerk6 => 'Recompensas Premium del Pase de Temporada';

  @override
  String get shopLifetimePerk7 => 'Acceso al Simulador de Combate';

  @override
  String get shopLifetimePerk8 => 'Sin cargos recurrentes — nunca';

  @override
  String get ratingTitle => '¿Te gusta Zeta Idle?';

  @override
  String get ratingBody =>
      '¡Llevas un buen rato de aventura! Si te diviertes, una valoración rápida ayuda muchísimo al juego. 🙏';

  @override
  String get ratingLove => '¡Me encanta!';

  @override
  String get ratingMeh => 'La verdad que no';
}
