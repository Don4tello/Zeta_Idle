// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get ccForgeYourLegend => '전설을 만들어라';

  @override
  String get ccNameYourWarrior => '— 전사의 이름 —';

  @override
  String get ccDefaultHeroName => '수호자';

  @override
  String get ccQuickStart => '빠른 시작';

  @override
  String get ccQuickStartHint => '추천 영웅으로 바로 시작하기';

  @override
  String get ccChooseClassAndRace => '직업 & 종족 선택';

  @override
  String get ccChooseYourClass => '직업 선택';

  @override
  String get ccSelectYourPath => '— 당신의 길을 선택하라 —';

  @override
  String get ccChooseRace => '종족 선택';

  @override
  String get ccSelectAClass => '직업을 선택하세요';

  @override
  String get ccRecommendedForBeginners => '★ 초보자 추천';

  @override
  String get ccComplexity => '난이도';

  @override
  String get ccChooseYourRace => '종족 선택';

  @override
  String get ccHeritageDefinesYou => '— 혈통이 당신을 정의한다 —';

  @override
  String get ccBeginYourJourney => '여정 시작';

  @override
  String get ccSelectARace => '종족을 선택하세요';

  @override
  String get ccNameNotAllowed => '다른 이름을 선택해 주세요 — 사용할 수 없는 이름입니다.';

  @override
  String get csSelectCharacter => '— 캐릭터 선택 —';

  @override
  String get csNewCharacter => '새 캐릭터';

  @override
  String get csSwipeToDelete => '캐릭터를 왼쪽으로 밀어 삭제';

  @override
  String csDeleteTitle(String name) {
    return '\"$name\" 삭제?';
  }

  @override
  String get csDeleteBody => '정말인가요? 한 번 삭제하면 복구할 수 없습니다.';

  @override
  String get csCancel => '취소';

  @override
  String get csDelete => '삭제';

  @override
  String get csLockedSlot => '잠긴 슬롯';

  @override
  String get navHero => '영웅';

  @override
  String get navPlay => '플레이';

  @override
  String get navInventory => '인벤토리';

  @override
  String get navShop => '상점';

  @override
  String get navGuild => '길드';

  @override
  String get modeCampaign => '캠페인';

  @override
  String get modeDungeon => '던전';

  @override
  String get modeBossRush => '보스 러시';

  @override
  String get modeTowerAscension => '탑 등반';

  @override
  String get modeGauntlet => '시련';

  @override
  String get modePvp => 'PVP';

  @override
  String get modeChallenges => '도전 과제';

  @override
  String get modeEvents => '이벤트';

  @override
  String get modeExpedition => '원정';

  @override
  String get modeDaily => '일일';

  @override
  String get modeBounties => '현상금';

  @override
  String get modeQuests => '퀘스트';

  @override
  String get badgeNew => '신규';

  @override
  String get lootLog => '전리품 기록';

  @override
  String get noLootYet => '아직 전리품이 없습니다 — 싸우러 가세요!';

  @override
  String get welcomeBack => '다시 오신 걸 환영합니다!';

  @override
  String awayFor(String time) {
    return '$time 동안 자리를 비우셨습니다.';
  }

  @override
  String awayForCapped(int hours) {
    return '$hours시간 넘게 자리를 비우셨습니다 — 최대 방치 보상을 표시합니다.';
  }

  @override
  String rewardGold(String amount) {
    return '+$amount 골드';
  }

  @override
  String rewardXp(String amount) {
    return '+$amount 경험치';
  }

  @override
  String rewardShards(String amount) {
    return '+$amount 파편';
  }

  @override
  String expeditionsReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '원정 $count건이 준비되었습니다!',
    );
    return '$_temp0';
  }

  @override
  String get comebackBonus => '복귀 보너스:';

  @override
  String get idleIncomeCollected => '휴식하는 동안 방치 수입을 획득했습니다.';

  @override
  String get claim => '획득';

  @override
  String get milestone => '마일스톤';

  @override
  String get welcomeBackCaps => '다시 오신 걸 환영합니다!';

  @override
  String get missedYou => '보고 싶었어요! 자리를 비운 동안의\n보너스입니다:';

  @override
  String get newSystemUnlocked => '새 시스템 해금';

  @override
  String get gotIt => '확인';

  @override
  String get welcomeFightTitle => '전투!';

  @override
  String get welcomeFightBody =>
      '플레이 탭으로 가서 캠페인의 스테이지 카드를 눌러 첫 전투를 시작하세요. 적이 쓰러질 때까지 계속 공격하세요!';

  @override
  String get welcomeIdleTitle => '방치 골드 획득';

  @override
  String get welcomeIdleBody =>
      '영웅은 싸우지 않을 때도 매 분 자동으로 골드를 법니다. 영웅 탭의 골드 바가 차오르는 것을 지켜보세요.';

  @override
  String get welcomeStrongerTitle => '더 강해지기';

  @override
  String get welcomeStrongerBody =>
      '업그레이드에서 골드를 써 능력치를 올리세요. 패시브에서 영구 보너스를, 스킬에서 강력한 전투 기술을 얻으세요.';

  @override
  String get welcomeExploreTitle => '탐험';

  @override
  String get welcomeExploreBody =>
      '캠페인은 손수 제작된 100개 스테이지로 진행됩니다. 탑 등반에서는 파편을 무한히 모을 수 있습니다. 던전은 아이템 드롭과 보스전이 있는 로그라이트 런입니다. 진행하면서 더 많은 모드가 해금됩니다.';

  @override
  String get navBack => '뒤로';

  @override
  String get navNext => '다음';

  @override
  String get startPlaying => '플레이 시작';

  @override
  String get settingsLanguage => '언어';

  @override
  String get settingsLanguageSystem => '시스템 기본값';

  @override
  String get commonCancel => '취소';

  @override
  String get commonContinue => '계속';

  @override
  String heroFalls(String name) {
    return '$name 쓰러짐';
  }

  @override
  String get battleGrowStronger => '다시 도전하기 전에 더 강해지세요.';

  @override
  String get battleBackToHero => '영웅으로 돌아가기';

  @override
  String get defeatEndlessTitle => '엔들리스 모드';

  @override
  String get defeatEndlessHint => '자신의 속도로 경험치 & 골드 파밍';

  @override
  String get defeatDungeonHint => '파편 & 아이템 획득';

  @override
  String get defeatGauntletHint => '업그레이드용 메아리 획득';

  @override
  String get defeatDailyTitle => '일일 도전 과제';

  @override
  String get defeatDailyHint => '진행 보상 획득';

  @override
  String battleTierUnlocked(int tier) {
    return '티어 $tier 해금';
  }

  @override
  String get battleCampaignCleared => '캠페인 클리어';

  @override
  String battleTierUnlockedBody(int tier) {
    return '오메가가 쓰러졌습니다. 캠페인이 티어 $tier에서 다시 시작됩니다 — 더 강한 적과 더 좋은 전리품.\n\n레벨, 파라곤, 장비, 재화가 모두 유지됩니다. 아무것도 초기화되지 않습니다.';
  }

  @override
  String get battleCampaignClearedBody =>
      '최고 티어에서 오메가가 쓰러졌습니다. 정상에 도달했습니다 — 전리품과 파라곤 포인트를 위해 계속 파밍하세요.';

  @override
  String get battleSwitchTiersHint => '캠페인 헤더에서 언제든지 티어를 전환할 수 있습니다.';

  @override
  String get battleRetreat => '후퇴';

  @override
  String get battleLastFightSummary => '마지막 전투 요약';

  @override
  String get battleResume => '재개';

  @override
  String get battlePause => '일시정지';

  @override
  String get battleAutoCampaignLocked => '자동 캠페인 — 속도 부스트 / 프리미엄 패스';

  @override
  String get battleAutoCampaignOn => '자동 캠페인: 켜짐';

  @override
  String get battleAutoCampaignOff => '자동 캠페인: 꺼짐';

  @override
  String get battleNoFightYet => '아직 완료된 전투가 없습니다.';

  @override
  String get battleAutoCampaignPerk => '자동 캠페인은 속도 부스트 / 프리미엄 패스 혜택입니다.';

  @override
  String get battleNoActiveBattle => '진행 중인 전투 없음';

  @override
  String get battleVictory => '승리!';

  @override
  String get battleBossDefeated => '보스 처치';

  @override
  String get battleNewContentUnlocked => '새 콘텐츠 해금';

  @override
  String get battleClassQuestlineUnlocked => '직업 퀘스트라인 해금';

  @override
  String battleClassQuestlineBody(String className) {
    return '$className의 길이 시작됩니다. 퀘스트 5개를 완료해 궁극기를 해금하세요.';
  }

  @override
  String battleRewardGold(String amount) {
    return '+$amount 골드';
  }

  @override
  String battleRewardXp(String amount) {
    return '+$amount 경험치';
  }

  @override
  String battleRewardShards(String amount) {
    return '+$amount 파편';
  }

  @override
  String battleAbilityUnlocked(String name) {
    return '스킬 해금: $name';
  }

  @override
  String get battleAddedToBag => '가방에 추가됨';

  @override
  String get battleFight => '전투  (−1 ⚡)';

  @override
  String get battleSpeedBoostTitle => '2× 속도 부스트';

  @override
  String battleSpeedBoostBody(int cost, int have) {
    return '7일 동안 2× 전투 속도를 해금할까요?\n\n비용: $cost Z코인\n보유 Z코인: $have';
  }

  @override
  String get battlePurchase => '구매';

  @override
  String get battleNotEnoughZcoins => 'Z코인이 부족합니다!';

  @override
  String get battleArtifactFound => '유물 발견!';

  @override
  String battleRoundsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count라운드 남음',
    );
    return '$_temp0';
  }

  @override
  String get commonOk => '확인';

  @override
  String get campaignDifficultyTier => '난이도 티어';

  @override
  String get campaignDifficultyTierTooltip => '난이도 티어';

  @override
  String get campaignTierSelectorBody =>
      '높은 티어 = 더 강한 적과 더 좋은 전리품(희귀도, 세트, 유물). 티어를 낮춰도 영구 전투력은 모두 유지되며, 싸우는 적과 드롭만 조정됩니다.';

  @override
  String get campaignTierNormal => '티어 0 — 일반';

  @override
  String campaignTierN(int tier) {
    return '티어 $tier';
  }

  @override
  String get campaignTierBaseDesc => '기본 적 · 기본 전리품 · 매직 파인드 없음';

  @override
  String campaignTierScaledDesc(int hp, int atk) {
    return '적 +$hp% HP · +$atk% 공격력';
  }

  @override
  String campaignTierMagicFind(int mf) {
    return '✦ +$mf% 매직 파인드 (높은 희귀도, 세트 & 유물)';
  }

  @override
  String get campaignLeaderboardTooltip => '캠페인 리더보드';

  @override
  String get campaignTutorial =>
      '캠페인은 스테이지별로 진행됩니다. 각 보스를 처치해 다음을 해금하세요. 마지막 보스를 클리어하면 다음 난이도 티어가 열립니다 — 캠페인이 더 어렵게 재시작되고 더 좋은 전리품이 나오며, 전투력은 유지됩니다.';

  @override
  String campaignEnergyRecharge(String time) {
    return '$time 후 +1';
  }

  @override
  String campaignEnergyRefill(int amount, int left) {
    return '충전 +$amount  (무료 $left회 남음)';
  }

  @override
  String get campaignBuy => '구매 ';

  @override
  String get campaignEnergyEmptyTutorial =>
      '에너지 부족! ⚡ 5분마다 1씩 충전됩니다. 위의 +10 버튼으로 매일 무료 3회 충전하세요. 또는 💎 50 Z코인으로 +20 에너지를 구매하세요.';

  @override
  String get campaignStageMap => '스테이지 지도  •  ✓ 노드를 눌러 재도전';

  @override
  String get campaignNoEnergyRefill => '에너지 없음! 충전될 때까지 기다리세요.';

  @override
  String campaignSimulateStage(int stage) {
    return '⚡ 스테이지 $stage 시뮬레이션';
  }

  @override
  String campaignEnergyAvailable(int count) {
    return '사용 가능 에너지: $count';
  }

  @override
  String get campaignSimInfo => '전투가 즉시 진행됩니다. 전리품은 바로 가방으로 들어갑니다.';

  @override
  String campaignSimAll(int count) {
    return '전체 ($count)';
  }

  @override
  String campaignSimResultTitle(int stage, int count) {
    return '스테이지 $stage — $count× 시뮬레이션';
  }

  @override
  String get campaignSimGold => '💰 골드';

  @override
  String get campaignSimXp => '✦ 경험치';

  @override
  String campaignItemsDropped(int count) {
    return '드롭된 아이템 ($count):';
  }

  @override
  String get campaignNoItemsDropped => '이번 런에서는 드롭된 아이템이 없습니다.';

  @override
  String get campaignNotEnoughEnergy => '에너지가 부족합니다!';

  @override
  String get campaignMapFight => '⚔  전투 (−1 ⚡)';

  @override
  String get campaignSimRequiresPremium => '프리미엄 패스 구독 필요';

  @override
  String get campaignBossEncounter => '보스 조우';

  @override
  String get campaignDismiss => '[ 닫기 ]';

  @override
  String campaignPerfectStages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '완벽한 스테이지 $count개',
    );
    return '$_temp0';
  }

  @override
  String campaignNextMilestone(int next) {
    return '• 다음 마일스톤 $next (+미스릴 +Z코인)';
  }

  @override
  String get campaignAllMilestones => '• 모든 마일스톤 완료!';

  @override
  String get hubWhatsNew => '새로운 소식';

  @override
  String get hubLootLog => '전리품 기록';

  @override
  String get hubSettings => '설정';

  @override
  String get hubChange => '변경';

  @override
  String get hubHeroMenu => '영웅 메뉴';

  @override
  String get hubJoinDiscord => '디스코드 참여';

  @override
  String get hubVisitReddit => 'r/zeta_idle 방문';

  @override
  String hubCouldNotOpen(String url) {
    return '$url을(를) 열 수 없습니다';
  }

  @override
  String get hubLocked => '잠김';

  @override
  String get hubGroupCharacter => '캐릭터';

  @override
  String get hubGroupProgression => '진행';

  @override
  String get hubGroupCollection => '수집';

  @override
  String get hubGroupRecords => '기록';

  @override
  String get hubBlurbCharacter => '빌드 & 전투력';

  @override
  String get hubBlurbProgression => '엔드게임 시스템';

  @override
  String get hubBlurbCollection => '동료 & 도감';

  @override
  String get hubBlurbRecords => '목표 & 세부 정보';

  @override
  String get hubSheet => '시트';

  @override
  String get hubScores => '능력치';

  @override
  String get hubAbilities => '스킬';

  @override
  String get hubPassives => '패시브';

  @override
  String get hubSpecialize => '전문화';

  @override
  String get hubParagon => '파라곤';

  @override
  String get hubUpgrades => '업그레이드';

  @override
  String get hubAscend => '초월';

  @override
  String get hubMastery => '숙련';

  @override
  String get hubPets => '펫';

  @override
  String get hubMercs => '용병';

  @override
  String get hubBestiary => '몬스터 도감';

  @override
  String get hubCodex => '코덱스';

  @override
  String get hubArmory => '무기고';

  @override
  String get hubAchievements => '업적';

  @override
  String get hubBonuses => '보너스';

  @override
  String get auShards => '파편';

  @override
  String get auRespecTitle => '스킬 초기화?';

  @override
  String auRespecBody(int cost) {
    return '모든 스킬 랭크와 마일스톤 선택을 초기화합니다.\n사용한 파편은 모두 환불됩니다.\n\n비용: $cost Z코인';
  }

  @override
  String auRespecConfirm(int cost) {
    return '초기화 ($cost ZC)';
  }

  @override
  String get auRespec => '초기화';

  @override
  String get auTutorial =>
      '파편 ◆을 얻었습니다 — 여기서 사용해 모든 전투에서 자동으로 발동하는 직업 스킬을 해금하고 강화하세요.';

  @override
  String get auIntro =>
      '파편을 사용해 스킬을 강화하세요. 랭크 5, 10, 15에서 마일스톤이 있습니다. 랭크 15 이후 티어 업 — 각 티어는 난이도 티어에 맞춰 해금됩니다.';

  @override
  String get auTitle => '스킬 업그레이드';

  @override
  String get auMaxTier => '최대 티어  ✦';

  @override
  String auTierLockedLabel(int tier, int req) {
    return '티어 $tier  —  난이도 티어 $req 필요';
  }

  @override
  String get auAscension => '초월';

  @override
  String auTierUnlocked(int cap) {
    return '티어 $cap 해금됨';
  }

  @override
  String auAscFullyAscended(int pct) {
    return '완전히 초월함  ·  +$pct% 스킬 위력';
  }

  @override
  String auAscTierLocked(int cur, int next) {
    return '+$cur% 위력  ·  난이도 티어 $next(환생)을 해금해 더 초월하기';
  }

  @override
  String auAscUpgrade(int cur, int next, int cost) {
    return '+$cur%  →  +$next% 위력  ·  $cost ✦ 파라곤 소모';
  }

  @override
  String auAscYouHave(int have) {
    return '  (보유 $have)';
  }

  @override
  String get auMax => '최대';

  @override
  String get auLocked => '잠김';

  @override
  String auAscendBtn(int cost) {
    return '초월  $cost ✦';
  }

  @override
  String get auUltimate => '궁극기';

  @override
  String auUnlocksLv(int lv) {
    return 'LV $lv 해금';
  }

  @override
  String get auFinishQuestline => '🔒 직업 퀘스트라인을 완료해 해금';

  @override
  String auReachLevel(int lv, int cur) {
    return '레벨 $lv 달성  (현재: Lv $cur)';
  }

  @override
  String auCompleteQuests(String className, int claimed) {
    return '$className 직업 퀘스트 5개 모두 완료  ($claimed / 5)';
  }

  @override
  String get auTrackQuests => '퀘스트 탭에서 퀘스트를 확인하세요.';

  @override
  String get auChoose => '선택';

  @override
  String get setTitle => '설정';

  @override
  String get setSave => '저장';

  @override
  String get setLoad => '불러오기';

  @override
  String get setReset => '초기화';

  @override
  String get setOpen => '열기';

  @override
  String get setView => '보기';

  @override
  String get setEmail => '이메일';

  @override
  String get setConfirm => '확인';

  @override
  String get setSecAccount => '계정';

  @override
  String get setSecPromo => '프로모션 코드';

  @override
  String get setSecAudio => '오디오';

  @override
  String get setSecHaptics => '진동';

  @override
  String get setSecNotifications => '알림';

  @override
  String get setSecDisplay => '디스플레이';

  @override
  String get setSecStats => '통계';

  @override
  String get setSecAutoLoot => '자동 전리품';

  @override
  String get setSecBattle => '전투';

  @override
  String get setSecDailyReset => '일일 초기화';

  @override
  String get setSecSave => '저장';

  @override
  String get setSecDanger => '위험 구역';

  @override
  String get setSecHelp => '도움말';

  @override
  String get setSecAbout => '정보';

  @override
  String get setManage => '관리';

  @override
  String get setSignIn => '로그인';

  @override
  String get setHeroName => '영웅 이름';

  @override
  String setRename(int cost) {
    return '이름 변경 ($cost 🪙)';
  }

  @override
  String get setPromoHint => '코드가 있나요? 여기서 사용해 보상을 받으세요.';

  @override
  String get setRedeem => '사용';

  @override
  String get setSoundEffects => '효과음';

  @override
  String get setBackgroundMusic => '배경 음악';

  @override
  String get setVolume => '음량';

  @override
  String get setVibration => '진동';

  @override
  String get setReminders => '알림';

  @override
  String get setDamageNumbers => '데미지 숫자';

  @override
  String get setReducedParticles => '파티클 감소';

  @override
  String get setTotalPlaytime => '총 플레이 시간';

  @override
  String get setAutoSalvage => '자동 분해';

  @override
  String get setAutoEquip => '업그레이드 자동 장착';

  @override
  String get setAutoEquipSub => '현재 장비보다 좋은 아이템을 자동으로 장착';

  @override
  String get setBattleSpeed => '전투 속도';

  @override
  String get setAutoCampaign => '자동 캠페인';

  @override
  String get setResetTime => '초기화 시간';

  @override
  String get setCloudSave => '클라우드 저장';

  @override
  String get setCloudSaveSub => '진행 상황을 클라우드에 동기화';

  @override
  String get setCloudSaveComplete => '클라우드 저장 완료.';

  @override
  String get setLoadCloud => '클라우드에서 불러오기';

  @override
  String get setLoadCloudSub => '로컬 저장을 클라우드 데이터로 덮어쓰기';

  @override
  String get setResetProgress => '진행 초기화';

  @override
  String get setResetProgressSub => '이 슬롯의 모든 저장 데이터를 삭제합니다. 되돌릴 수 없습니다.';

  @override
  String get setKnowledgeBase => '지식 베이스';

  @override
  String get setKnowledgeBaseSub => '키워드, 시스템, 재화 설명';

  @override
  String get setTagline => '다크 중세 방치형 RPG.';

  @override
  String get setAboutHero => '영웅';

  @override
  String get setAboutClass => '직업';

  @override
  String get setAboutLevel => '레벨';

  @override
  String get setAboutPrestige => '프레스티지';

  @override
  String get setAboutAchievements => '업적';

  @override
  String get setAboutDeveloper => '개발자';

  @override
  String get setAboutContact => '연락처';

  @override
  String get setPrivacy => '개인정보 처리방침';

  @override
  String get setPrivacySub => '데이터 처리 방식';

  @override
  String get setReportBug => '버그 신고 / 피드백';

  @override
  String get setReportBugSub => '이메일을 보내주세요 — 기기 정보가 자동으로 추가됩니다';

  @override
  String get setReplayTips => '튜토리얼 팁 다시 보기';

  @override
  String get setReplayTipsSub => '게임 내 튜토리얼 팁을 다시 표시';

  @override
  String get setTipsReset => '튜토리얼 팁이 초기화되었습니다 — 탐험하면서 다시 나타납니다.';

  @override
  String get setRenameHeroTitle => '영웅 이름 변경';

  @override
  String get setHeroNameHint => '영웅 이름 입력';

  @override
  String setRenameCost(int cost, int have) {
    return '비용: $cost 🪙   (보유 $have)';
  }

  @override
  String setRenameNotEnough(int cost) {
    return 'Z코인이 부족합니다 — 이름 변경 비용은 $cost 🪙입니다.';
  }

  @override
  String get setNoEmailApp =>
      '이메일 앱을 찾을 수 없습니다. razorintegrations@gmail.com으로 연락해 주세요';

  @override
  String get setDailyResetTitle => '일일 초기화 시간';

  @override
  String get setDailyResetHint => '일일 제한이 초기화되는 시간을 선택하세요.';

  @override
  String get setDailyResetWarning => '경고: 1년에 한 번만 변경할 수 있습니다.';

  @override
  String get setLoadCloudTitle => '클라우드에서 불러올까요?';

  @override
  String get setLoadCloudBody =>
      '로컬 저장을 클라우드 데이터로 덮어씁니다. 아직 동기화되지 않은 로컬 진행 상황은 사라집니다.';

  @override
  String get setResetAllTitle => '모든 진행을 초기화할까요?';

  @override
  String get setResetAllBody =>
      '모든 진행 상황, 골드, 아이템, 프레스티지 레벨, 업적이 영구적으로 삭제됩니다. 되돌릴 수 없습니다.';

  @override
  String get setNewHeroName => '새 영웅 이름:';

  @override
  String get setGoogleAccount => 'Google 계정';

  @override
  String get setSignInGoogle => 'Google로 로그인';

  @override
  String get setSignedIn => '로그인됨';

  @override
  String get setSyncSaves => '기기 간 저장 동기화';

  @override
  String get setEnterCode => '코드 입력';

  @override
  String get setOff => '꺼짐';

  @override
  String get setOffCaps => '꺼짐';

  @override
  String get setHidden => '숨김';

  @override
  String get setVibrationOn => '치명타, 레벨업, 승리 & 보상 시 진동';

  @override
  String get setRemindersOn => '자리를 비운 동안 \"복귀\" 알림 받기';

  @override
  String get setDamageOn => '전투 중 떠오르는 숫자 표시';

  @override
  String get setParticlesOn => '배경 효과 감소 (성능 향상)';

  @override
  String get setParticlesOff => '전체 효과';

  @override
  String get setSalvageOff => '드롭 아이템 자동 분해를 켜려면 탭하세요';

  @override
  String setSalvageOn(String tier) {
    return '$tier 이하 자동 분해';
  }

  @override
  String get setAutoCampaignOnSub => '백그라운드에서 캠페인 전투를 자동으로 진행';

  @override
  String get setAutoCampaignLockedSub => '🔒 속도 부스트 / 프리미엄 패스 구독자 전용';

  @override
  String setResetTimeOn(String time) {
    return '일일 제한이 $time에 초기화됩니다. 변경하려면 탭하세요(1년에 한 번).';
  }

  @override
  String setResetTimeLocked(String time) {
    return '$time에 초기화 · 올해 이미 변경함.';
  }

  @override
  String get guildTitle => '길드';

  @override
  String get guildJoinTitle => '길드 가입';

  @override
  String get guildJoinBlurb =>
      '길드는 패시브 보너스, 주간 보스 도전, 그리고 전용 보상이 있는 길드 상점을 제공합니다.';

  @override
  String get guildCreate => '길드 생성';

  @override
  String get guildPublic => '공개 길드';

  @override
  String get guildNoGuilds => '길드를 찾을 수 없습니다. 첫 번째로 길드를 만들어 보세요!';

  @override
  String get guildCreateTitle => '길드 생성';

  @override
  String get guildNameLabel => '길드 이름';

  @override
  String get guildDescLabel => '설명 (선택)';

  @override
  String get guildCreateBtn => '생성';

  @override
  String get guildTabInfo => '정보';

  @override
  String get guildTabCastle => '성';

  @override
  String get guildTabBoss => '보스';

  @override
  String get guildTabWar => '전쟁';

  @override
  String get guildTabChat => '채팅';

  @override
  String get guildTabShop => '상점';

  @override
  String guildCastleTier(int tier) {
    return '성 — 티어 $tier / 10';
  }

  @override
  String guildProgressTier(int tier) {
    return '티어 $tier까지 진행';
  }

  @override
  String guildCpProgress(int cp, int cap) {
    return '$cp / $cap CP';
  }

  @override
  String guildNext(String headline) {
    return '다음: $headline';
  }

  @override
  String get guildCitadelComplete => '성채 완성 — 성이 완전히 건설되었습니다!';

  @override
  String get guildContributeGold => '골드 기부';

  @override
  String guildContributeInfo(String rate, int cap) {
    return '골드를 건설 포인트(CP)로 전환합니다. 비율: $rate 골드 = 1 CP. 하루에 최대 $cap CP까지 추가할 수 있습니다.';
  }

  @override
  String get guildActiveBenefits => '활성 성 혜택';

  @override
  String get guildContributeHint => '기부해 성을 올리고 혜택을 해금하세요.';

  @override
  String guildCastleAdvanced(int tier) {
    return '🏰 성이 티어 $tier로 발전했습니다!';
  }

  @override
  String get guildCapReached => '일일 건설 한도에 도달했습니다 — 내일 다시 오세요!';

  @override
  String guildLevelMembers(int lvl, int m, int max) {
    return '레벨 $lvl  •  멤버 $m/$max';
  }

  @override
  String guildBonusGold(int pct) {
    return '+$pct% 골드';
  }

  @override
  String guildBonusXp(int pct) {
    return '+$pct% 경험치';
  }

  @override
  String guildBonusIdle(int pct) {
    return '+$pct% 방치';
  }

  @override
  String guildXpProgress(int xp, int max) {
    return '$xp/$max 경험치';
  }

  @override
  String get guildDonate1000 => '골드 1000 기부';

  @override
  String get guildDonateReward => '→ 길드 경험치 + 🪙';

  @override
  String get guildPerks => '혜택';

  @override
  String guildLockedPerk(int lvl, String name, String desc) {
    return '🔒 Lv$lvl: $name — $desc';
  }

  @override
  String get guildMembers => '멤버';

  @override
  String guildMemberLine(int lvl, String cls, String role, int d) {
    return 'Lv$lvl $cls  •  $role  •  기부: ${d}g';
  }

  @override
  String get guildLeave => '길드 탈퇴';

  @override
  String get guildNoBoss => '이번 주 보스가 없습니다.';

  @override
  String get guildWeeklyBoss => '☠ 주간 길드 보스';

  @override
  String guildBossHp(int hp, int max) {
    return '$hp / $max HP';
  }

  @override
  String get guildDefeated => '✓ 처치됨';

  @override
  String guildBossRewardMsg(Object rank, Object gc, Object gold) {
    return '🏆 지난주 보스: $rank위 — +$gc 길드 코인, +$gold 골드';
  }

  @override
  String get guildClaimBossReward => '🏆 지난주 보스 보상 받기';

  @override
  String guildAttempts(int rem, int max) {
    return '시도: $rem / $max';
  }

  @override
  String get guildNoAttempts => '남은 시도 없음';

  @override
  String get guildChallengeBoss => '⚔ 보스 도전';

  @override
  String get guildDamageRanking => '데미지 순위';

  @override
  String guildDmg(int dmg) {
    return '$dmg 데미지';
  }

  @override
  String get guildWarStandings => '전쟁 순위';

  @override
  String guildWarRecord(int w, int l) {
    return '전적: $w승–$l패';
  }

  @override
  String get guildWeeklyWar => '주간 길드 전쟁';

  @override
  String get guildWarBlurb =>
      '준비 기간(월–화)에 참가하세요. 수–금에는 전쟁 공격을 사용해 라이벌 챔피언과 싸워 길드 점수를 얻으세요. 토–일에는 순위 보상을 받으세요.';

  @override
  String get guildEnlistedBattle => '⚔ 참가 완료! 지금 전쟁 공격을 사용하세요.';

  @override
  String get guildEnlistedPrep => '⚔ 참가 완료! 수–금에 돌아와 싸우세요.';

  @override
  String get guildEnlist => '길드 참가';

  @override
  String get guildWarEndedWait => '전쟁 종료 — 다음 주를 기다리세요';

  @override
  String guildScoreYou(String name) {
    return '$name (나)';
  }

  @override
  String get guildLeads => '🏆 당신의 길드가 앞서고 있습니다!';

  @override
  String get guildBehind => '⚠ 당신의 길드가 뒤처지고 있습니다 — 싸우세요!';

  @override
  String guildFightForGuild(int c, int max) {
    return '⚔ 길드를 위해 싸우기  ($c/$max)';
  }

  @override
  String get guildNoWarAttacks => '오늘 남은 전쟁 공격 없음';

  @override
  String get guildWarRefresh => '전쟁 공격은 전투 단계 동안 매일 갱신됩니다.';

  @override
  String get guildWarVictory => '🏆 승리!';

  @override
  String get guildWarOver => '전쟁 종료.';

  @override
  String guildWarRewardMsg(String result, Object gc, Object gold) {
    return '$result +$gc 길드 코인, +$gold 골드';
  }

  @override
  String get guildRewardsClaimed => '보상 받음';

  @override
  String get guildClaimWarRewards => '전쟁 보상 받기';

  @override
  String get guildWarBattleSoon => '전투는 수요일에 시작됩니다 — 돌아와 싸우세요!';

  @override
  String get guildCoinsLabel => '길드 코인';

  @override
  String guildListLine(int lvl, int m, int max) {
    return 'Lv$lvl  •  멤버 $m/$max';
  }

  @override
  String get guildJoin => '가입';

  @override
  String get guildFull => '가득 참';

  @override
  String get guildBossTitle => '길드 보스';

  @override
  String get guildBossWin => '✦ 보스 처치!';

  @override
  String get guildBossLose => '💀 쓰러짐';

  @override
  String guildTotalDamage(int d) {
    return '입힌 총 데미지: $d';
  }

  @override
  String get guildReturn => '길드로 돌아가기';

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
      '아이템을 파괴해 파편(◆)을 회수합니다.\n• 일반 → 3 ◆\n• 희귀 → 8 ◆\n• 영웅 → 20 ◆\n• 전설 → 60 ◆\n• 세트 → 100 ◆';

  @override
  String get forgeUpgradeTooltip =>
      '아이템을 +0에서 +10까지 강화합니다.\n각 티어마다 모든 능력치가 8% 상승합니다.\n+5와 +10에서 아이템에 칭호 접두사가 붙습니다.\n티어마다 골드 + 파편이 듭니다.';

  @override
  String get forgeTitle => '제작소';

  @override
  String get forgeSalvage => '분해';

  @override
  String get forgeUpgrade => '강화';

  @override
  String get forgeSlot => '슬롯';

  @override
  String get forgeFrom => '출처  ';

  @override
  String forgeForged(String name, String label) {
    return '제작됨: $name ($label)!';
  }

  @override
  String get forgeSalvageRates => '분해 비율';

  @override
  String forgeSalvageBtn(int n, int s) {
    return '분해  $n  (+$s ◆)';
  }

  @override
  String get forgeBagEmpty => '가방이 비어 있습니다.';

  @override
  String forgeBag(int n) {
    return '가방  ($n개)';
  }

  @override
  String forgeSalvaged(int earned) {
    return '분해됨: +$earned ◆';
  }

  @override
  String forgeTimesN(int n) {
    return ' ×$n';
  }

  @override
  String get forgeTimesRandom => '  ×1 (무작위)';

  @override
  String get forgeMasterForger => '명장 대장장이';

  @override
  String get forgeSelected => '선택됨';

  @override
  String forgeSelectedCount(int selected, int needed) {
    return '$selected / $needed';
  }

  @override
  String get forgeArcaneDust => '비전 가루';

  @override
  String get forgeGemType => '젬 종류';

  @override
  String forgeGemWeaponDesc(Object pct, String type) {
    return '⚔ 무기: +$pct% $type 데미지';
  }

  @override
  String forgeGemArmorDesc(Object pct, String type) {
    return '🛡 방어구: +$pct% $type 저항';
  }

  @override
  String get forgeTier => '티어';

  @override
  String forgeGemBagFull(int n, int max) {
    return '젬 가방 가득 참 ($n/$max)';
  }

  @override
  String forgeNeedMore(int n) {
    return '💠 $n개 더 필요';
  }

  @override
  String forgeCraft(int cost) {
    return '✦  제작  $cost 💠';
  }

  @override
  String forgePreviewWeapon(String effect) {
    return '⚔ 무기: $effect';
  }

  @override
  String forgePreviewArmor(String effect) {
    return '🛡 방어구: $effect';
  }

  @override
  String forgeToCraft(int cost) {
    return '제작에 $cost 💠';
  }

  @override
  String forgeGemBag(int n, int max) {
    return '젬 가방  ($n/$max)';
  }

  @override
  String get forgeTapGem => '젬을 눌러 아이템에 장착하세요';

  @override
  String get forgeNoGems => '아직 제작한 젬이 없습니다. 위에서 하나 제작하세요!';

  @override
  String get forgeHowGems => '젬 작동 방식';

  @override
  String get forgeGemsInfo =>
      '• 각 젬은 두 가지 용도입니다 — 같은 젬이 무기에서는 속성 데미지를, 방어구/장신구에서는 속성 저항을 줍니다.\n• 젬 파편은 전투 처치(25% 확률)와 보스에서 드롭됩니다.\n• 각 아이템은 소켓에 젬 1개를 넣을 수 있습니다.\n• 이 가방에서 또는 인벤토리 화면에서 젬을 장착하세요.\n• 젬을 교체하거나 제거하면 기존 젬이 파괴됩니다.';

  @override
  String get forgeNoItemsSocket => '장착할 아이템이 없습니다.';

  @override
  String forgeSocketGem(String name) {
    return '$name 장착';
  }

  @override
  String get forgeChooseItem => '이 젬을 장착할 아이템을 선택하세요.';

  @override
  String get forgeReplaceGem => '젬을 교체할까요?';

  @override
  String forgeReplaceBody(String old, String gnew) {
    return '$old이(가) 파괴되고 $gnew(으)로 교체됩니다. 되돌릴 수 없습니다.';
  }

  @override
  String get forgeReplace => '교체';

  @override
  String get forgeUpgradeInfo =>
      '아이템을 +0에서 +10까지 강화합니다. 각 티어마다 모든 능력치가 8% 상승합니다.\n+5에서 아이템에 \'정제된\' 접두사가 붙습니다.\n+10에서 \'명작\'이 됩니다.';

  @override
  String get forgeBalance => '보유: ';

  @override
  String get forgeNoUpgradeItems =>
      '강화할 수 있는 아이템이 없습니다.\n모든 아이템이 +10이거나 가방이 비어 있습니다.';

  @override
  String get forgeSelectItem => '아이템 선택';

  @override
  String get forgeAllStats => '모든 능력치 +8%';

  @override
  String get forgeWeaponDmgSuffix => '  •  무기 데미지 +8%';

  @override
  String get forgeRefinedPrefix => '🏷 +5에서 \'정제된\' 접두사 획득!';

  @override
  String get forgeMasterworkPrefix => '🏷 +10에서 \'명작\' 접두사 획득!';

  @override
  String forgeUpgradeTo(int tier) {
    return '+$tier(으)로 강화';
  }

  @override
  String get dngTitle => '던전';

  @override
  String dngTitleRun(int tier, int floor) {
    return 'T$tier  $floor층  —  던전';
  }

  @override
  String get dngFlee => '던전에서 도망';

  @override
  String get dngAutoOn => '자동 진행: 켜짐 — 탭하면 수동 조작';

  @override
  String get dngAutoOff => '자동 진행: 꺼짐 — 탭하면 자동 클리어';

  @override
  String get dngAutoPremium => '자동 진행 (스테이지 5에서 해금)';

  @override
  String get dngPushOnTip => '심연 돌파: 켜짐 — 던전 군주를 처치해 더 깊이 내려가기';

  @override
  String get dngPushOffTip => '심연 돌파: 꺼짐 — 클리어 층에서 런 종료';

  @override
  String get dngPushOnMsg =>
      '심연 돌파 켜짐 — 던전 군주를 처치하면 점점 강해지는 심연 층으로 내려갑니다(더 풍부한 미스릴 + 고유 확률). 언제든 도망쳐 클리어를 확정하세요.';

  @override
  String get dngPushOffMsg => '심연 돌파 꺼짐 — 던전 군주를 처치하면 런이 종료됩니다.';

  @override
  String get dngLeaderboard => '던전 리더보드';

  @override
  String get dngAutoPremiumMsg => '자동 진행은 캠페인 스테이지 5에서 해금됩니다.';

  @override
  String get dngTutorial =>
      '층마다 두 개의 문 중 하나를 선택하세요. 처치한 적은 뼈를 드롭합니다 — 순회 상인에게서 런 내내 지속되는 버프에 사용하세요. 전리품은 영웅이 쓰러져도 즉시 당신의 것입니다.';

  @override
  String get dngWhatToExpect => '예상되는 것';

  @override
  String get dngExpCombat => '전투 — 골드를 위해 싸우기';

  @override
  String get dngExpElite => '정예 — 더 강한 적, 아이템 드롭 확정';

  @override
  String get dngExpAmbush => '매복 — 적이 먼저 공격, 높은 골드';

  @override
  String get dngExpRest => '휴식처 — HP 20% 회복';

  @override
  String get dngExpTreasure => '보물 — 골드 & 파편 획득';

  @override
  String get dngExpShrine => '제단 — 런 내내 지속되는 축복 선택';

  @override
  String get dngExpChest => '잠긴 상자 — 파편을 써 희귀 아이템 획득';

  @override
  String get dngExpTrap => '함정 — 피할 수 없는 데미지';

  @override
  String get dngExpBoss => '보스 (5층마다) — 고위험, 고보상';

  @override
  String get dngBonesHint => '처치한 적은 뼈를 드롭합니다 — 순회 상인에게서 사용하세요.';

  @override
  String get dngExpectedLoot => '예상 전리품';

  @override
  String get dngLootGold => '골드';

  @override
  String get dngLootGoldDetail => '전투, 보물방 & 휴식 보급품에서';

  @override
  String get dngLootShards => '파편';

  @override
  String get dngLootShardsDetail => '런 중의 보물방 & 상자에서';

  @override
  String get dngLootItems => '아이템';

  @override
  String dngLootItemsDetail(String tier) {
    return '현재 깊이의 아이템 티어: $tier  (정예 & 보스가 더 좋은 것을 드롭)';
  }

  @override
  String get dngLootMythril => '미스릴';

  @override
  String dngLootMythrilDetail(int a, int b) {
    return '5층에서 ~$a  •  10층에서 ~$b';
  }

  @override
  String dngYourBest(int f, int m) {
    return '최고 기록: $f층  •  ~$m 미스릴';
  }

  @override
  String get dngNoRecord => '아직 기록 없음';

  @override
  String dngDeepestFloor(int f) {
    return '최심층: $f층';
  }

  @override
  String dngDailyAttempts(int r, int max) {
    return '일일 시도: $r / $max';
  }

  @override
  String dngEnterTier(int tier) {
    return '티어 $tier 입장';
  }

  @override
  String get dngNoAttempts => '남은 시도 없음';

  @override
  String dngBuyExtra(int cost) {
    return '$cost Z코인 — 추가 시도 1회 구매';
  }

  @override
  String get dngBossFloor => '☠ 보스 층';

  @override
  String dngBossIn(int n) {
    return '☠ $n 후 보스';
  }

  @override
  String get dngChoosePath => '길을 선택하세요';

  @override
  String get dngNextBoss => '☠ 다음 층: 보스';

  @override
  String get dngMystery => '미스터리';

  @override
  String get dngGoblin => '💰 보물 고블린';

  @override
  String get dngEnter => '입장';

  @override
  String get dngMystery1 => '표시 없는 문.';

  @override
  String get dngMystery2 => '행운인가 위험인가?';

  @override
  String dngGoblinHp(Object hp) {
    return '$hp HP  •  5라운드 후 도망';
  }

  @override
  String get dngGoblinReward => '제때 처치하면 골드 6배!';

  @override
  String get dngGuaranteedDrop => '아이템 드롭 확정';

  @override
  String get dngStrikesFirst => '선제공격 — 높은 골드';

  @override
  String get dngDoorBlessing => '축복...';

  @override
  String get dngDoorCurse => '아니면 저주?';

  @override
  String get dngMakeCamp => '야영하기';

  @override
  String get dngRecoverHp => 'HP 회복';

  @override
  String get dngRareInside => '희귀 아이템이 들어 있음';

  @override
  String dngShardsToOpen(Object n) {
    return '열려면 파편 $n개';
  }

  @override
  String dngPlusGold(Object g) {
    return '+$g 골드';
  }

  @override
  String dngPlusShards(Object s) {
    return '+$s 파편';
  }

  @override
  String dngMinusHp(Object d) {
    return '-$d HP';
  }

  @override
  String dngEnemyStats(Object hp, Object atk) {
    return '$hp HP  •  $atk 공격력';
  }

  @override
  String get dngEnemy => '적';

  @override
  String get dngSpeedNeeds => '더 높은 속도는 속도 부스트 / 프리미엄 패스가 필요합니다.';

  @override
  String get dngTreasureFound => '보물 발견!';

  @override
  String get dngCursed => '✸ 저주받음!';

  @override
  String get dngBlessed => '✧ 축복받음!';

  @override
  String get dngDarkToll => '어둠이 대가를 치르게 합니다...';

  @override
  String get dngAncientPower => '고대의 힘이 당신을 통해 흐릅니다.';

  @override
  String get dngLightShadow => '빛과 그림자가 당신의 운명에 얽매입니다.';

  @override
  String get dngShrineCorrupted => '타락한 제단';

  @override
  String get dngShrineBlessed => '축복받은 제단';

  @override
  String get dngShrineAncient => '고대의 제단';

  @override
  String get dngShrineCorruptedFlavor =>
      '어두운 기운이 고동치며 꿈틀거립니다. 저주는 확실하지만 — 힘이 기다립니다.';

  @override
  String get dngShrineBlessedFlavor => '이곳에서 따뜻한 신성한 빛이 뿜어져 나옵니다. 축복이 보장됩니다.';

  @override
  String get dngShrineTwinFlavor => '두 힘이 안에서 꿈틀거립니다 — 축복과 저주를 모두 받게 됩니다.';

  @override
  String get dngShrineNormalFlavor =>
      '신비로운 제단이 알 수 없는 힘으로 고동칩니다.\n들어가 축복을... 아니면 저주를 받으세요.\n너무 늦기 전까지는 어느 쪽인지 알 수 없습니다.';

  @override
  String get dngAcceptCurse => '저주를 받아들이기';

  @override
  String get dngReceiveBlessing => '축복 받기';

  @override
  String get dngEnterTwin => '입장  (효과 2개)';

  @override
  String get dngEnterShrine => '제단 입장';

  @override
  String dngActiveEffects(int n) {
    return '활성 효과: $n';
  }

  @override
  String get dngSkip => '건너뛰기';

  @override
  String dngGuaranteeBless(int c) {
    return '✧  축복 보장  ($c ◆)';
  }

  @override
  String dngTrapDamage(int dmg, int pct) {
    return '$dmg 데미지를 받습니다 (최대 HP의 $pct%).';
  }

  @override
  String get dngLockedChest => '잠긴 상자';

  @override
  String get dngChestContains => '희귀 또는 영웅 아이템이 들어 있습니다.';

  @override
  String dngCostShards(Object cost) {
    return '$cost 파편';
  }

  @override
  String dngHave(int n) {
    return '(보유 $n)';
  }

  @override
  String dngCostZcoins(int cost) {
    return '$cost Z코인';
  }

  @override
  String get dngMerchantQuote => '\"장신구는 뼈로, 여행자여. 뼈가 많을수록 더 좋은 물건이지.\"';

  @override
  String dngBones(int n) {
    return '🦴  뼈 $n개';
  }

  @override
  String dngBoneCost(int c) {
    return '$c 🦴';
  }

  @override
  String get dngClaimRelic => '☠ 보스 처치 — 유물 획득';

  @override
  String get dngSkipDescend => '건너뛰기 — 하강';

  @override
  String get dngReturn => '돌아가기';

  @override
  String dngDescendTo(int n) {
    return '$n층으로 하강';
  }

  @override
  String get dngFallen => '☠ 쓰러짐';

  @override
  String get dngGotAway => '💰 놓쳤습니다!';

  @override
  String get dngVictory => '✓ 승리';

  @override
  String dngAmbushHit(int n) {
    return '매복 공격이 전투 전에 $n의 데미지를 입혔습니다.';
  }

  @override
  String dngItemToBag(String name, String label) {
    return '✦ $name ($label) → 가방';
  }

  @override
  String get dngRested => '⊕ 휴식함';

  @override
  String get dngTreasureCollected => '✦ 보물 획득';

  @override
  String get dngBlessingReceived => '✧ 축복 받음';

  @override
  String get dngSlainTrap => '☠ 함정에 의해 사망';

  @override
  String get dngTrapSurvived => '✸ 함정 생존';

  @override
  String get dngChestOpened => '◆ 상자 열림';

  @override
  String get dngLootAdded => '전리품이 이미 계정에 추가되었습니다.';

  @override
  String dngLordFallen(int z, int g) {
    return '던전 군주가 쓰러졌습니다!\n+5 미스릴  •  +$z Z코인  •  +$g 골드  •  보너스 아이템';
  }

  @override
  String dngTierN(int t) {
    return '티어 $t';
  }

  @override
  String get dngFloor => '층';

  @override
  String get dngRooms => '방';

  @override
  String get dngBosses => '보스';

  @override
  String get dngGold => '골드';

  @override
  String get dngShards => '파편';

  @override
  String dngTierCleared(int t) {
    return '✓ 티어 $t 클리어 — 자동 해금!';
  }

  @override
  String get dngNewRecord => '★ 신기록!';

  @override
  String get dngAllLootAdded => '모든 전리품이 계정에 추가되었습니다.';

  @override
  String get dngYouFallen => '당신은 쓰러졌습니다';

  @override
  String get dngCleared => '던전 클리어!';

  @override
  String get dngRunEnded => '런 종료';

  @override
  String get dngAutoLocked => '🔒 자동';

  @override
  String get dngStop => '◉ 정지';

  @override
  String get dngAuto => '✦ 자동';

  @override
  String get dngRunAgain => '다시 도전';

  @override
  String get dngReturnHall => '홀로 돌아가기';

  @override
  String get auraEquipped => '장착됨';

  @override
  String get auraOn => '켜짐';

  @override
  String auraCost(int n) {
    return '비용: $n Z코인';
  }

  @override
  String auraUnlockTitle(String name) {
    return '$name을(를) 해금할까요?';
  }

  @override
  String get auraAllAuras => '모든 오라';

  @override
  String get auraAllSkins => '모든 스킨';

  @override
  String get auraAllPets => '모든 펫';

  @override
  String get auraRemoveAura => '오라 제거';

  @override
  String get auraRemoveSkin => '스킨 제거';

  @override
  String get auraDismissPet => '펫 해제';

  @override
  String get auraBattleCompanion => '전투 동료';

  @override
  String get auraWaystones => '길잡이돌';

  @override
  String get auraAttackEffects => '공격 효과';

  @override
  String get auraCharSlots => '캐릭터 슬롯';

  @override
  String get auraCompanionNote =>
      '한 번에 하나의 동료만 활성화할 수 있습니다. 각각 작은 패시브 보너스를 줍니다.';

  @override
  String get auraBeforeAfter => '전 / 후';

  @override
  String get auraAllSlots => '12개 슬롯 모두 해금됨.';

  @override
  String auraAdoptTitle(String name) {
    return '$name을(를) 입양할까요?';
  }

  @override
  String auraPetBonus(String label) {
    return '✦ $label';
  }

  @override
  String get auraMaxEvolution => '★★ 최대 진화';

  @override
  String auraOwned(Object count) {
    return '보유: $count';
  }

  @override
  String auraWaystoneDesc(Object h, String m) {
    return '$h시간  ·  $m× 방치 수입';
  }

  @override
  String auraHitEvery(String text) {
    return '모든 공격 시 \"$text\"';
  }

  @override
  String auraSlotN(Object n) {
    return '슬롯 $n';
  }

  @override
  String get auraAddSlot => '캐릭터 저장 슬롯을 하나 더 추가합니다.';

  @override
  String get auraUnlock => '해금';

  @override
  String get auraAdopt => '입양';

  @override
  String get auraBuy => '구매';

  @override
  String get auraEvolve => '진화';

  @override
  String get auraEquip => '장착';

  @override
  String get auraActive => '활성';

  @override
  String get auraSendOut => '내보내기';

  @override
  String get auraStackAuras =>
      '보유한 모든 오라의 보너스는 자동으로 중첩됩니다 — 모두 유지됩니다. 하나를 장착하는 것은 어떤 빛을 보여줄지 고르는 것뿐입니다.';

  @override
  String get auraStackSkins =>
      '보유한 모든 스킨의 보너스는 자동으로 중첩됩니다 — 모두 유지됩니다. 하나를 장착하는 것은 어떤 모습을 입을지 고르는 것뿐입니다.';

  @override
  String get armTabUniques => '고유';

  @override
  String get armTabMythic => '신화';

  @override
  String get armTabSets => '세트 아이템';

  @override
  String get armTabArtifacts => '유물';

  @override
  String get armNoLegendaries => '이 직업의 전설 아이템이 없습니다.';

  @override
  String armClassUniques(int count) {
    return '직업 고유 $count개';
  }

  @override
  String get armOwned => '보유함';

  @override
  String armSlotReqLevel(String slot, int lvl) {
    return '$slot  •  요구 레벨 $lvl';
  }

  @override
  String get armStats => '능력치';

  @override
  String get armAbilityEnh => '스킬 강화';

  @override
  String armAbilityDamage(String x) {
    return '• 스킬 데미지 ×$x';
  }

  @override
  String armAbilityDuration(Object n) {
    return '• +$n 라운드 지속';
  }

  @override
  String armAbilityCooldown(String v) {
    return '• $v 라운드 재사용 대기';
  }

  @override
  String armOnCast(String desc) {
    return '• 시전 시: $desc';
  }

  @override
  String get armHowToFind => '획득 방법';

  @override
  String get armDropCampaign => '캠페인 보스';

  @override
  String get armDropTower => '탑 등반 보스';

  @override
  String get armDropBossRush => '보스 러시 런';

  @override
  String get armDropGauntlet => '시련 클리어';

  @override
  String get armRate2 => '보스 처치당 2%';

  @override
  String get armRate03 => '보스 처치당 0.3%';

  @override
  String get armRateRare => '희귀 보너스 드롭';

  @override
  String get armDropsClassSpecific => '드롭은 직업 전용입니다 — 당신의 직업용 아이템만 드롭됩니다.';

  @override
  String get armNoMythic => '아직 신화 아이템 없음';

  @override
  String get armMythicHint => '캠페인 보스를 처치하면 처치당 0.5% 확률.';

  @override
  String get armMythicItems => '신화 아이템';

  @override
  String armSlotLv(String slot, int lvl) {
    return '$slot  •  Lv$lvl';
  }

  @override
  String armKeyword(String name) {
    return '$name 키워드';
  }

  @override
  String get armSetItemsTitle => '세트 아이템';

  @override
  String armFraction(int a, int b) {
    return '$a / $b';
  }

  @override
  String get armEquippedLower => '장착됨';

  @override
  String get armSetBonuses => '세트 보너스';

  @override
  String armPc(Object n) {
    return '$n개';
  }

  @override
  String get armUniqueBlurb =>
      '고유 아이템은 직업 전용이며 스킬을 크게 강화합니다. 각각 특정 직업 스킬을 증폭시킵니다. 드롭 확률: 보스 처치당 2%.';

  @override
  String get armMythicBlurb =>
      '가장 희귀한 절차적 생성 등급입니다. 신화 아이템은 가능한 최고 수치의 능력치 3개와 강력한 키워드 효과를 가집니다. 드롭 확률: 보스 처치당 0.5%.';

  @override
  String get armSetBlurb =>
      '같은 세트의 여러 부위를 모아 강력한 보너스를 해금하세요. 이제 세트는 전체 보너스에 6부위가 필요합니다. 드롭 확률: 보스 처치당 0.3%.';

  @override
  String armArtifactBlurb(int count) {
    return '3부위 유물 세트 $count개. 유물 격자에 녹색 부위 2개를 맞춰 장착하면 부분 보너스를, 3개 모두면 전체 보너스를 얻습니다. 세트 부위는 던전, 보스 러시, 캠페인 보스에서 드롭됩니다.';
  }

  @override
  String get armSetPieces => '세트 부위';

  @override
  String get armArtifactSets => '유물 세트';

  @override
  String armCollected(int a, int b) {
    return '수집함  서로 다른 부위 $a / $b개 보유';
  }

  @override
  String endlessStage(int n) {
    return '스테이지 $n';
  }

  @override
  String endlessNextReward(int n) {
    return '다음 보상: $n층';
  }

  @override
  String get endlessChallengeBoss => '보스 도전';

  @override
  String get endlessPremiumAutoClear => '🔒  캠페인 스테이지 5에 도달해 보스를 자동 클리어';

  @override
  String get endlessRewards => '보상: ';

  @override
  String get endlessDrop => '드롭: ';

  @override
  String get endlessGold => '골드';

  @override
  String get endlessXp => '경험치';

  @override
  String get endlessRespawns => '리스폰';

  @override
  String endlessTowerShards(String n) {
    return '+$n 타워 파편';
  }

  @override
  String endlessMilestone(Object n) {
    return '★ 마일스톤: $n 처치 ★';
  }

  @override
  String endlessMilestoneReward(String gold, Object s) {
    return '+$gold 골드  +$s ◆';
  }

  @override
  String get endlessEnemyStirs => '적이 다시 꿈틀거립니다...';

  @override
  String get endlessDefeatBody => '영웅이 압도당했습니다.\n능력치를 강화하고 다시 도전하세요.';

  @override
  String get pvpNoStamina => '스태미나 없음! 45분마다 1씩 충전됩니다.';

  @override
  String get pvpTitle => 'PVP 아레나';

  @override
  String get pvpSimLab => '시뮬 랩';

  @override
  String get pvpRefresh => '리더보드 새로고침';

  @override
  String get pvpLeaderboard => '리더보드';

  @override
  String pvpToday(String label) {
    return '오늘: $label';
  }

  @override
  String pvpWinsToday(Object wins, Object dmg) {
    return '오늘 $wins승  •  총 $dmg 데미지';
  }

  @override
  String get pvpClaimed => '✓ 받음';

  @override
  String get pvpNoChallengers => '아직 도전자가 없습니다';

  @override
  String get pvpNoChallengersSub => '경기를 치러 리더보드에 참여하고\n당신의 순위를 확인하세요.';

  @override
  String pvpHpAc(Object hp, Object ac) {
    return 'HP:$hp  AC:$ac';
  }

  @override
  String get pvpStamina => '스태미나  ';

  @override
  String get pvpStaminaTip => '스태미나는 45분마다 하트 1개씩 회복됩니다.';

  @override
  String get pvpRating => '레이팅';

  @override
  String get pvpWins => '승';

  @override
  String get pvpLosses => '패';

  @override
  String get pvpWL => '승/패';

  @override
  String pvpLeague(String name) {
    return '$name 리그';
  }

  @override
  String get pvpNearRank => '내 순위 근처';

  @override
  String get pvpPlayersAbove => '— 바로 위의 플레이어';

  @override
  String pvpClassLv(String cls, Object lvl) {
    return '$cls  Lv$lvl';
  }

  @override
  String get pvpChallenge => '도전';

  @override
  String get pvpBattleLog => '전투 기록';

  @override
  String get pvpBattleLogTip => '전투 기록';

  @override
  String get pvpNoCombat => '아직 전투 없음.';

  @override
  String get pvpClose => '닫기';

  @override
  String pvpVs(String hero, String opp) {
    return 'PVP  —  $hero vs $opp';
  }

  @override
  String get pvpReturnArena => '아레나로 돌아가기';

  @override
  String get pvpFighting => '전투 중...';

  @override
  String invBagCount(Object n, Object cap) {
    return '($n/$cap)';
  }

  @override
  String invBuyTab(Object cost) {
    return '+ 탭  $cost';
  }

  @override
  String get invAutoEquip => '자동 장착';

  @override
  String invTabN(Object n, Object count) {
    return '탭 $n  ($count)';
  }

  @override
  String get invEquipment => '장비';

  @override
  String invBag(Object n, Object cap) {
    return '가방  ($n/$cap)';
  }

  @override
  String get invUnequip => '장착 해제';

  @override
  String get invNoItems => '이 탭에 아이템이 없습니다.';

  @override
  String invReqClass(String cls) {
    return '$cls 필요';
  }

  @override
  String invReqLevel(Object lvl) {
    return '레벨 $lvl 필요';
  }

  @override
  String invReqTier(Object t) {
    return '티어 $t 필요';
  }

  @override
  String get invCannotEquip => '장착 불가';

  @override
  String get invEquip => '장착';

  @override
  String get invUnlock => '잠금 해제 🔓';

  @override
  String get invLock => '잠금 🔒';

  @override
  String get invDiscard => '버리기';

  @override
  String get invAny => '모두';

  @override
  String invUniqueOnly(String cls) {
    return '★ 고유 — $cls 전용';
  }

  @override
  String get invWrongClass => '(잘못된 직업)';

  @override
  String get invColStat => '능력치';

  @override
  String get invColThis => '이것';

  @override
  String get invColEqpd => '장착';

  @override
  String get invColDiff => '차이';

  @override
  String get invEmptySocket => '빈 소켓';

  @override
  String get invCraftGems => '제작소 → 젬 탭에서 젬을 제작하세요';

  @override
  String get invRemove => '제거';

  @override
  String get invSocket => '장착';

  @override
  String invChooseGem(String name) {
    return '$name에 장착할 젬을 선택하세요';
  }

  @override
  String invOnThis(String slot, String bonus) {
    return '이 $slot에: $bonus';
  }

  @override
  String get invRemoveGem => '젬을 제거할까요?';

  @override
  String get invDestroy => '파괴';

  @override
  String get invSort => '정렬:';

  @override
  String get invFilter => '필터:';

  @override
  String invGemsAvailable(Object count) {
    return '장착 가능한 젬 $count개';
  }

  @override
  String invRemoveBody(String name) {
    return '$name이(가) 파괴됩니다. 제거한 젬은 복구할 수 없습니다.';
  }

  @override
  String invReplaceBody(String old, String gnew) {
    return '$old이(가) 파괴되고 $gnew(으)로 교체됩니다.';
  }

  @override
  String get npcRoster => '명단';

  @override
  String get npcSynergies => '시너지';

  @override
  String get npcTitle => '용병';

  @override
  String get npcTotalBonuses => '총 활성 보너스';

  @override
  String get npcBattleParty => '전투 파티';

  @override
  String npcFielded(Object count, Object max) {
    return '$count / $max 출전';
  }

  @override
  String get npcUnknown => '알 수 없는 용병';

  @override
  String npcBattleAbility(String name) {
    return '전투 스킬: $name';
  }

  @override
  String npcUnlock(String label) {
    return '해금: $label';
  }

  @override
  String npcProgress(Object a, Object b) {
    return '$a / $b';
  }

  @override
  String npcLvTalent(Object n) {
    return 'LV $n 특성';
  }

  @override
  String npcChosen(String name) {
    return '선택됨: $name';
  }

  @override
  String get npcMilestoneComplete => '마일스톤 완료 — 영입 중...';

  @override
  String get npcMax => '★ 최대';

  @override
  String get npcStarRank => '스타 랭크';

  @override
  String npcStars(Object a, Object b) {
    return '$a / $b';
  }

  @override
  String get npcFullyAscended => '★ 완전히 초월함 — 각 별이 유효 레벨 +1을 더합니다.';

  @override
  String npcAscendStar(Object n) {
    return '초월 ★$n';
  }

  @override
  String npcYouHave(Object n) {
    return '보유: 미스릴 $n개';
  }

  @override
  String get npcStarInfo => '각 별 = 이 용병 보너스의 유효 레벨 +1.';

  @override
  String get npcPassiveOnly => '패시브 보너스만 — 항상 활성.';

  @override
  String npcCostShards(Object n) {
    return '비용: ◆ 파편 $n개';
  }

  @override
  String get npcTutorial =>
      '용병은 특정 마일스톤을 달성하면 영구히 합류하는 동료입니다. 🤝 각각 모든 전투에서 패시브 전투 보너스를 제공하며, 다른 용병과 시너지를 내 추가 위력을 얻을 수 있습니다.';

  @override
  String npcRecruited(Object a, Object b) {
    return '$a / $b  영입함';
  }

  @override
  String get npcNoMercs => '아직 영입한 용병이 없습니다. 마일스톤을 달성해 해금하세요.';

  @override
  String npcChipDamage(Object n) {
    return '+$n% 데미지';
  }

  @override
  String npcChipAc(Object n) {
    return '+$n% AC';
  }

  @override
  String npcChipShards(Object n) {
    return '+$n% 파편';
  }

  @override
  String npcChipHp(Object n) {
    return '+$n% HP';
  }

  @override
  String get shopTabBundles => '번들';

  @override
  String get shopTabVip => 'VIP';

  @override
  String get shopTabStarter => '스타터';

  @override
  String get shopTabResources => '자원';

  @override
  String get shopTabCosmetics => '코스메틱';

  @override
  String get shopSecBundles => 'Z코인 번들';

  @override
  String get shopSecBundlesSub => '상점용 프리미엄 재화';

  @override
  String get shopSecVip => 'VIP 구독';

  @override
  String get shopSecVipSub => '반복 혜택 및 특전';

  @override
  String get shopSecStarter => '스타터 팩';

  @override
  String get shopSecStarterSub => '일회성 구매 번들';

  @override
  String get shopSecResources => '자원';

  @override
  String get shopSecResourcesSub => 'Z코인을 골드 & 재료에 사용';

  @override
  String get shopSecAuras => '오라';

  @override
  String get shopSecAurasSub => '빛을 장착 — 보유한 오라 보너스는 항상 중첩됩니다';

  @override
  String get shopSecBoosts => '부스트';

  @override
  String get shopSecBoostsSub => '영구 능력치 부스트';

  @override
  String get shopSecTitles => '칭호';

  @override
  String get shopSecTitlesSub => '이름 아래 표시되는 랭크';

  @override
  String get shopSecColours => '이름 색상';

  @override
  String get shopSecColoursSub => '영웅 이름의 색상 + 광채';

  @override
  String get shopSecFrames => '프레임';

  @override
  String get shopSecFramesSub => '영웅 초상화 주위의 프레임';

  @override
  String get shopSecSlots => '캐릭터 슬롯';

  @override
  String get shopSecSlotsSub => '추가 캐릭터 저장 슬롯';

  @override
  String get shopPremiumArmor => '프리미엄 직업 방어구';

  @override
  String shopEndgameSkin(String cls) {
    return '$cls · 엔드게임 스킨';
  }

  @override
  String get shopIncludedBonuses => '포함된 보너스';

  @override
  String get shopEverySkin => '모든 상점 스킨 보너스 통합';

  @override
  String get shopEquippedCheck => '✓ 장착됨';

  @override
  String get shopUnequip => '장착 해제';

  @override
  String shopUnlockPrice(String price) {
    return '해금  ·  $price';
  }

  @override
  String get shopStoreUnavailable => '상점을 이용할 수 없습니다 — 나중에 다시 시도하세요.';

  @override
  String get shopVipSub => 'VIP 구독';

  @override
  String get shopSubscribed => '✓ 구독 중';

  @override
  String shopSubscribe(String price) {
    return '구독  $price';
  }

  @override
  String get shopEverythingPlus => '뱅가드 협약의 모든 것, 추가로:';

  @override
  String get shopIncludedPerks => '포함된 혜택';

  @override
  String get shopGlow => '✦ 광채';

  @override
  String get shopExclusive => '독점';

  @override
  String get shopNoAd => '지금은 사용 가능한 광고가 없습니다 — 나중에 다시 시도하세요.';

  @override
  String get shopWatchAd => '광고 보기';

  @override
  String get shopComeBackTomorrow => '내일 다시 와서 더 많은 무료 Z코인을 받으세요!';

  @override
  String get shopWait => '대기 중...';

  @override
  String get shopWatch => '보기';

  @override
  String get shopRewardEarned => '보상 획득';

  @override
  String shopPlusZcoins(Object amount) {
    return '+$amount Z코인';
  }

  @override
  String get shopCollect => '받기';

  @override
  String get shopPurchasesRestored => '구매 내역이 복원되었습니다. 활성 구독이나 팩이 다시 적용되었습니다.';

  @override
  String get shopRestorePurchases => '구매 복원';

  @override
  String artSalvageTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '유물 $count개를 분해할까요?',
    );
    return '$_temp0';
  }

  @override
  String get artSalvage => '분해';

  @override
  String artSalvaged(int n, Object gained) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '유물 $n개를 분해해 ◆ 미스릴 $gained개를 얻었습니다.',
    );
    return '$_temp0';
  }

  @override
  String get artTable => '유물 테이블';

  @override
  String artSlots(Object n, Object max) {
    return '$n/$max 슬롯';
  }

  @override
  String artAutoEquipped(Object n) {
    return '최고의 유물 $n개를 자동 장착했습니다.';
  }

  @override
  String get artNoneToEquip => '장착할 유물이 없습니다.';

  @override
  String get artAutoEquip => '⚡ 자동 장착';

  @override
  String get artSalvageBtn => '♻ 분해';

  @override
  String get artTitle => '유물';

  @override
  String get artPlaceHint => '유물을 테이블에 배치해 보너스를 얻으세요.';

  @override
  String get artTableBonuses => '테이블 보너스';

  @override
  String get artCollection => '컬렉션';

  @override
  String artCount(Object n) {
    return '($n)';
  }

  @override
  String artTapToPlace(String name) {
    return '격자 칸을 눌러 \"$name\" 배치';
  }

  @override
  String get artTapCancel => '다시 눌러 취소';

  @override
  String get artSet => '세트';

  @override
  String artUpgradeCost(Object cost) {
    return '$cost 미스릴';
  }

  @override
  String artNoSets(Object n) {
    return '아직 장착한 세트 부위가 없습니다 — 발견할 세트 $n개.';
  }

  @override
  String artCountOf3(Object count) {
    return '$count / 3';
  }

  @override
  String get artHowToGet => '유물 획득 방법';

  @override
  String get artRowCampaign => '캠페인 보스';

  @override
  String get artRowCampaignDesc => '보스 스테이지 처치마다 약 25% 확률로 드롭됩니다.';

  @override
  String get artRowDungeon => '던전 런';

  @override
  String get artRowDungeonDesc => '처치하는 각 보스가 하나씩 드롭 — 런당 최대 2개. 가장 꾸준한 파밍.';

  @override
  String get artRowBossRush => '보스 러시';

  @override
  String get artRowBossRushDesc => 'A 또는 S 랭크로 런을 클리어하면 유물을 얻습니다.';

  @override
  String artSalvageBody(int count, Object mythril) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '장착하지 않은 유물 $count개를 영구 파괴해 ◆ 미스릴 $mythril개를 얻을까요? 장착한 유물은 유지됩니다.',
    );
    return '$_temp0';
  }

  @override
  String get artSetBlurb =>
      '맞는 녹색 세트 부위를 모으세요. 2개 장착 = 부분 보너스, 3개 모두 = 전체 보너스.';

  @override
  String get art2Set => '2세트';

  @override
  String get art3Set => '3세트';

  @override
  String get ptEssence => '정수';

  @override
  String ptTheClass(String cls) {
    return '$cls';
  }

  @override
  String ptRespecBranch(String branch) {
    return '$branch 초기화?';
  }

  @override
  String ptRefund(Object refund) {
    return '정수 $refund개 환불 (75%)';
  }

  @override
  String get ptRespec => '초기화';

  @override
  String get ptCrossBranch => '교차 분기';

  @override
  String get ptFullRespec => '전체 초기화?';

  @override
  String get ptRespec50 => '초기화 (50 ZC)';

  @override
  String get ptFullRespecBtn => '전체 초기화 (50 ZC)';

  @override
  String get ptTitle => '패시브 트리';

  @override
  String get ptNow => '현재';

  @override
  String ptUpgradeCost(Object cost) {
    return '강화  ($cost ✦)';
  }

  @override
  String get ptLocked => '잠김 — 다른 분기에 25랭크를 사용하세요';

  @override
  String get ptLockedMax => '잠김 — 먼저 모든 분기 노드를 최대로 올리세요';

  @override
  String ptMaxRankTotal(String val) {
    return '최대 랭크 — 총 $val';
  }

  @override
  String ptFullRespecBody(Object refund) {
    return '모든 패시브 노드를 초기화합니다.\n정수 $refund개 환불 (60%).\n비용: 50 Z코인.';
  }

  @override
  String ptNodesUnlocked(Object count) {
    return '$count개 노드 해금됨';
  }

  @override
  String get ptTutorial =>
      '파편 ◆을 얻었습니다 — 여기서 사용해 절대 초기화되지 않는 영구 패시브 노드에 투자하세요. 당신의 직업 분기는 맨 위에 있습니다. 각 노드는 최대 5랭크까지 올려 더 큰 보너스를 얻습니다.';

  @override
  String ptBranchesAt25(Object count) {
    return '$count / 5 분기가 25랭크';
  }

  @override
  String get homeExp => '경험치';

  @override
  String get homeResources => '자원';

  @override
  String get homeGold => '골드';

  @override
  String get homeShards => '파편';

  @override
  String get homeZcoins => 'Z코인';

  @override
  String get homeMythril => '미스릴';

  @override
  String get homeIdleMin => '방치/분';

  @override
  String get homeGoldTip => '골드\n전투와 방치 수입에서 획득.\n업그레이드와 상점에서 사용.';

  @override
  String get homeShardsTip =>
      '파편\n적 처치, 던전, 원정, 시련에서 획득.\n스킬 강화, 아이템 강화, 패시브 트리 노드에 사용.';

  @override
  String get homeZcoinsTip => 'Z코인\n업적과 일일 상자에서 획득.\n오라 상점에서 스킨, 펫, 오라에 사용.';

  @override
  String get homeMythrilTip =>
      '미스릴\n던전, 보스 러시, 프레스티지 마일스톤에서 획득.\n유물 강화, 던전 접사 재굴림, 제단 축복에 사용.';

  @override
  String get homeIdleTip =>
      '방치 골드 / 분\n오프라인 동안 매 분 자동으로 획득하는 골드.\n영웅 레벨, 패시브 업그레이드, 펫으로 증가.';

  @override
  String get homeCurrentCampaign => '현재 캠페인';

  @override
  String homeStage(Object n) {
    return '스테이지 $n';
  }

  @override
  String homeNextGoal(Object reward) {
    return '다음: $reward 해금';
  }

  @override
  String homeNextGoalProgress(Object remaining, Object stage) {
    return '$remaining 스테이지 남음 — 스테이지 $stage 클리어';
  }

  @override
  String get demoModeLocked =>
      '정식 버전에서 해금됩니다. 데모에는 전체 캠페인이 포함됩니다 — 던전, PvP, 엔드게임 난이도 티어는 정식 버전에서 즐기세요.';

  @override
  String get demoFullGameCta => '정식 버전 받기';

  @override
  String get homeSecCombat => '전투';

  @override
  String get homeSecSocial => '소셜';

  @override
  String get homeNavChallengeGauntlet => '시련 도전';

  @override
  String get homeNavBountyBoard => '현상금 게시판';

  @override
  String get homeNavSeasonPass => '시즌 패스';

  @override
  String get homeNavWorldEvent => '월드 이벤트';

  @override
  String get homeNavLeaderboard => '리더보드';

  @override
  String get homeNavChallengeModifiers => '도전 수정자';

  @override
  String get homeQuickAccess => '빠른 접근';

  @override
  String get homeGettingStarted => '시작하기';

  @override
  String get homeStep1 => '첫 캠페인 전투에서 승리하기';

  @override
  String get homeStep2 => '영웅 레벨업 — 캐릭터 시트를 확인하세요';

  @override
  String get homeStep3 => '영웅을 열고 첫 능력치 업그레이드를 구매하세요';

  @override
  String get homeStep4 => '스테이지 5 도달 — 스킬과 일일 도전이 해금됩니다!';

  @override
  String get homeHeroSubtitle => '업그레이드  •  무기고  •  동료  •  코덱스';

  @override
  String get homeTomorrow => '내일: ';

  @override
  String get dailyWeekly => '주간';

  @override
  String get dailyClaimAll => '모두 받기';

  @override
  String get dailyHowItWorks => '작동 방식';

  @override
  String get dailyThisWeek => '이번 주 도전';

  @override
  String dailyCompleted(Object claimed, Object total) {
    return '$claimed / $total 완료';
  }

  @override
  String get dailyWeeklyLoading => '주간 도전 불러오는 중...';

  @override
  String get dailyAboutWeekly => '주간 도전 정보';

  @override
  String get dailyReady => '준비됨';

  @override
  String get dailyTodayProgress => '오늘의 진행';

  @override
  String get dailyChest => '일일 상자';

  @override
  String get dailyClaimedTomorrow => '받았습니다! 내일 다시 오세요.';

  @override
  String get dailyHintKill => '적 처치';

  @override
  String get dailyHintKillD => '캠페인 또는 엔들리스 모드에서 전투';

  @override
  String get dailyHintWin => '전투 승리';

  @override
  String get dailyHintWinD => '적을 처치하면 승리로 집계됩니다';

  @override
  String get dailyHintBoss => '보스 처치';

  @override
  String get dailyHintBossD => '스테이지 5, 10, 15, 20, 25 또는 엔들리스 5마다';

  @override
  String get dailyHintAbility => '스킬 사용';

  @override
  String get dailyHintAbilityD => '액티브 스킬은 전투에서 자동으로 발동됩니다';

  @override
  String get dailyHintEquip => '아이템 장착';

  @override
  String get dailyHintEquipD => '가방 아이템 탭 → 인벤토리에서 장착';

  @override
  String get dailyHintGold => '골드 도달';

  @override
  String get dailyHintGoldD => '보유 골드가 그만큼만 있으면 됩니다';

  @override
  String get dailyHintDamage => '데미지 입히기';

  @override
  String get dailyHintDamageD => '모든 모드에서 누적 입힌 데미지';

  @override
  String get dailyHintIdle => '방치 보상 수령';

  @override
  String get dailyHintIdleD => '홈 화면에서 방치 보상을 탭하세요';

  @override
  String get dailyHintResets => '초기화';

  @override
  String get dailyHintResetsD => '매주 월요일 — 매주 새 도전 5개';

  @override
  String get dailyHintRewards => '보상';

  @override
  String get dailyHintRewardsD => '일일보다 큼: 정수, 미스릴, Z코인';

  @override
  String get dailyHintSeasonXp => '시즌 경험치';

  @override
  String get dailyHintSeasonXpD => '완료한 주간 도전당 +50 시즌 경험치';

  @override
  String get dailyHintProgress => '진행';

  @override
  String get dailyHintProgressD => '받은 시점이 아니라 월요일 자정부터 집계';

  @override
  String get dailyTutorial =>
      '일일 도전을 완료해 골드, 파편, 정수, Z코인을 획득하세요. 7개 도전 모두 매일 초기화됩니다. 모두 완료하면 보너스 상자를 받습니다!';

  @override
  String petOwned(Object a, Object b) {
    return '$a / $b  보유';
  }

  @override
  String get petTitle => '동료';

  @override
  String get petActiveBonuses => '활성 보너스 (보유한 모든 펫)';

  @override
  String get petNoCompanion => '장착한 동료 없음';

  @override
  String get petEquipHint => '펫을 장착하면 전투에 나타납니다.';

  @override
  String get petPremium => '★ 프리미엄';

  @override
  String get petInBattle => '전투 중';

  @override
  String petRecruitTitle(String name) {
    return '$name을(를) 영입할까요?';
  }

  @override
  String get petRecruit => '영입';

  @override
  String petEvolveTitle(String name) {
    return '$name을(를) 진화할까요?';
  }

  @override
  String petEvolveN(Object n) {
    return '진화  Evo $n';
  }

  @override
  String get petTutorial =>
      '펫 동료는 전투에 합류하며 장착하지 않은 것도 패시브로 보너스를 중첩합니다. 하나를 장착하면 전투 중 당신 옆에 나타납니다. 보유한 펫을 두 번 진화시켜 보너스 값을 두 배로 만드세요.';

  @override
  String petRecruitBody(String desc, String bonus, Object cost) {
    return '$desc\n\n보너스: $bonus\n\n비용: $cost Z코인';
  }

  @override
  String petEvolveBody(Object level, String bonus, Object cost) {
    return '진화 $level(으)로 업그레이드.\n\n새 보너스: +$bonus\n비용: $cost Z코인';
  }

  @override
  String get questTitle => '퀘스트라인';

  @override
  String get questAdventure => '모험 퀘스트라인';

  @override
  String get questAdventureSub => '스테이지 100으로 가는 길에서 모든 게임 시스템을 배우세요.';

  @override
  String questUnlocksLv30(Object lvl) {
    return '레벨 30에서 해금  (현재: $lvl)';
  }

  @override
  String get questUltUnlocked => '궁극기 해금';

  @override
  String questUltAvailable(String cls) {
    return '$cls 궁극기를 이제 전투에서 사용할 수 있습니다.';
  }

  @override
  String get questProgressLabel => '진행';

  @override
  String questCompleteFirst(Object n) {
    return '먼저 퀘스트 $n을(를) 완료해 해금하세요.';
  }

  @override
  String get questClaimReward => '보상 받기';

  @override
  String get questRewardLabel => '보상: ';

  @override
  String questClassQuestline(String cls) {
    return '$cls 퀘스트라인';
  }

  @override
  String get questComplete5 => '퀘스트 5개를 완료해 궁극기를 해금하세요.';

  @override
  String get subTitle => '전문화';

  @override
  String get subLevel50 => '레벨 50 전문화';

  @override
  String subChooseBody(String cls, Object cost) {
    return '$cls의 전문화를 선택하세요. 강력한 핵심 보너스와 즉시 적용되는 능력치 보너스를 줍니다. 나중에 $cost Z코인으로 변경할 수 있습니다.';
  }

  @override
  String subClassSpecs(String cls, Object n) {
    return '$cls 전문화  ($n)';
  }

  @override
  String subUnlocksAt(Object lvl) {
    return '전문화는 레벨 $lvl에서 해금됩니다.';
  }

  @override
  String subChooseTitle(String name) {
    return '$name을(를) 선택할까요?';
  }

  @override
  String get subStatBonuses => '능력치 보너스';

  @override
  String get subCapstone => '핵심 보너스';

  @override
  String get subSpecialEffect => '특수 효과';

  @override
  String subChangeLater(Object cost) {
    return '나중에 $cost Z코인으로 변경할 수 있습니다.';
  }

  @override
  String get subCouldNotSet => '전문화를 설정할 수 없습니다 — 다시 시도하세요.';

  @override
  String subChangeSpec(Object cost) {
    return '전문화 변경  —  $cost Z코인';
  }

  @override
  String get subChangeTitle => '전문화를 변경할까요?';

  @override
  String subChangeBody(Object cost, Object zcoins) {
    return '$cost Z코인을 써 현재 전문화를 해제하고 새로 선택할까요?\n\n보유 Z코인: $zcoins';
  }

  @override
  String get subNotEnough => '초기화할 Z코인이 부족합니다.';

  @override
  String get subActiveSubclass => '활성 서브클래스';

  @override
  String get subChosen => '선택됨';

  @override
  String get subActive => '활성';

  @override
  String get subChoosePath => '이 길을 선택';

  @override
  String get expTitle => '원정';

  @override
  String get expCollectAll => '모두 수령';

  @override
  String get expDispatchAll => '모두 파견';

  @override
  String get expNoMercs => '아직 용병이 없습니다';

  @override
  String get expNoMercsSub => '영웅 허브의 용병 탭에서 용병을 영입해 원정에 보내세요.';

  @override
  String get expTodayLocations => '오늘의 위치';

  @override
  String expRefreshIn(String time) {
    return '🔄 $time';
  }

  @override
  String get expYourParty => '내 파티';

  @override
  String get expDispatch => '파견';

  @override
  String get expDone => '완료';

  @override
  String get expCollectRewards => '보상 수령';

  @override
  String get expInProgress => '진행 중...';

  @override
  String expReturned(String name) {
    return '$name이(가) 돌아왔습니다!';
  }

  @override
  String get expDiscovery => '✦  발견';

  @override
  String get expGreat => '좋음';

  @override
  String expDispatchMerc(String name) {
    return '$name 파견';
  }

  @override
  String get expChooseLocation => '위치 선택';

  @override
  String get expDuration => '소요 시간';

  @override
  String get expEstRewards => '예상 보상';

  @override
  String get expSend => '원정 보내기';

  @override
  String get acctSignInFailed => '로그인이 취소되었거나 실패했습니다.';

  @override
  String get acctSignOutTitle => '로그아웃할까요?';

  @override
  String get acctSignOut => '로그아웃';

  @override
  String get acctSignOutBody => '로컬 저장은 유지됩니다. 다시 로그인할 때까지 클라우드 동기화가 일시 중지됩니다.';

  @override
  String get acctDeleteTitle => '계정 & 데이터를 삭제할까요?';

  @override
  String get acctDeleteAll => '모두 삭제';

  @override
  String get acctDeleteBody =>
      '계정과 모든 데이터를 영구 삭제합니다 — 모든 캐릭터, 클라우드 저장, PvP 순위, 리더보드 기록. 되돌릴 수 없습니다.';

  @override
  String get acctDeleted => '계정 삭제됨';

  @override
  String get acctDeletedBody => '계정과 모든 데이터가 삭제되었습니다. 이제 앱이 종료됩니다.';

  @override
  String get acctClose => '닫기';

  @override
  String get acctPlayer => '플레이어';

  @override
  String get acctSyncNow => '지금 동기화';

  @override
  String get acctSignOutBtn => '로그아웃';

  @override
  String get acctSignInGoogle => 'Google로 로그인';

  @override
  String get acctDeleteAccount => '계정 삭제';

  @override
  String get acctDangerSub => '계정과 모든 관련 데이터를 영구 삭제합니다.';

  @override
  String get acctLinked => 'Google 계정 연결됨';

  @override
  String get acctNotSynced => '이번 세션에 아직 동기화되지 않음';

  @override
  String get acctNoAccount => '연결된 계정 없음';

  @override
  String get acctAboutCloud => '클라우드 저장 정보';

  @override
  String get acctCloud1 => '로그인하면 진행 상황이 5분마다 자동으로 동기화됩니다.';

  @override
  String get acctCloud2 => '같은 Google 계정으로 어떤 Windows 기기에서든 플레이하세요.';

  @override
  String get acctCloud3 => '클라우드 저장은 Google 계정과 함께 안전하게 보관됩니다.';

  @override
  String get invhTabGear => '장비';

  @override
  String get invhTabGems => '젬';

  @override
  String get invhTabRunes => '룬';

  @override
  String get invhArcaneDust => '비전 가루';

  @override
  String invhBag(Object n, Object max) {
    return '가방: $n/$max';
  }

  @override
  String get invhCraftGem => '젬 제작';

  @override
  String invhCraftTypeGem(String type, Object cost) {
    return '$type 젬 제작  ($cost 비전 가루)';
  }

  @override
  String get invhOwnedGems => '보유 젬';

  @override
  String invhDismantleBody(String bonus, Object dust) {
    return '$bonus\n\n무기에 장착하면 +데미지%, 방어구에 장착하면 이 젬 속성의 +저항%.\n\n분해하면 비전 가루 $dust개를 돌려받습니다.';
  }

  @override
  String invhDismantle(Object dust) {
    return '분해 (+$dust 비전 가루)';
  }

  @override
  String invhGemTooltip(String name, String bonus) {
    return '$name\n$bonus\n탭하여 분해';
  }

  @override
  String get invhTutGear => '첫 장비가 드롭되었습니다! 여기서 장착해 능력치를 높이세요.';

  @override
  String get invhTutForge =>
      '같은 부위의 아이템 두 개를 합쳐 더 높은 희귀도의 아이템을 제작하거나 능력치를 재생성하세요.';

  @override
  String get invhTutRunes => '룬을 제작해 일시적인 전투 버프를 얻으세요. 장비를 분해해 가루를 모으세요.';

  @override
  String get invhTutArtifacts => '격자에 유물을 배치해 영구 패시브 보너스를 얻으세요.';

  @override
  String get invhNoGear => '아직 장비가 없습니다.\n적을 처치해 첫 아이템을 찾으세요!';

  @override
  String get ascTitle => '초월(어센션)';

  @override
  String get ascMetaBoard => '메타 보드';

  @override
  String ascApPoints(Object points) {
    return '$points AP';
  }

  @override
  String get ascLevelLabel => '어센션 레벨: ';

  @override
  String get ascPrestigeLabel => '프레스티지 레벨: ';

  @override
  String get ascBody =>
      '어센션은 가장 깊은 초기화입니다 — 당신의 환생을 어센션 포인트(AP)로 전환합니다. 희생하는 환생 1회당 1 AP를 얻으므로, 어센션 전에 많이 쌓을수록 보상이 커집니다.\n\nAP는 두 가지로 사용합니다 — 둘 다 영구적이며 이후 모든 초기화에서 유지됩니다:\n• 아래의 메타 보드 (경험치, 골드, 데미지, 방치 & 프레스티지 보너스)\n• 스킬 화면에서 직업 스킬 어센션 (티어당 +10% 위력, 캐릭터당 최대 60 AP)\n\n유지: 어센션 보너스 & 사용한 AP, 유물, 미스릴, 타워 파편, 속성 숙련.\n상실: 모든 환생, 영웅 레벨, 골드, 장비, 서브클래스, 스킬 랭크, 캠페인 진행.';

  @override
  String ascRequires(Object prestige) {
    return '어센션에는 프레스티지 레벨 5가 필요합니다  (현재: $prestige/5)';
  }

  @override
  String ascAscendAp(Object ap) {
    return '어센션  (+$ap AP)';
  }

  @override
  String get ascConfirmTitle => '어센션할까요?';

  @override
  String ascConfirmBody(Object rebirths, Object ap) {
    return '환생 $rebirths회를 희생해 어센션 포인트 $ap개를 얻습니다.\n\n유지: 어센션 보너스, 유물, 미스릴, 타워 파편, 스킬 어센션.\n상실: 모든 환생, 영웅 레벨, 골드, 장비, 서브클래스, 스킬 랭크, 캠페인 진행.\n\n되돌릴 수 없습니다.';
  }

  @override
  String get weOmegaShop => '오메가 상점';

  @override
  String get weNowHunting => '현재 사냥 중';

  @override
  String get weDamageLabel => '데미지: ';

  @override
  String weEndsIn(Object d, Object h, Object m) {
    return '이벤트 종료까지  $d일 $h시간 $m분';
  }

  @override
  String get weHowToEarn => '토큰 획득 방법';

  @override
  String weHowToEarnDesc(String name) {
    return '$name은(는) 모든 전투 중 15% 확률로 나타납니다. 처치하면 각각 이벤트 토큰 1–3개를 얻습니다.';
  }

  @override
  String get weEventBoss => '⚔ 이벤트 보스';

  @override
  String get weClaimLegendary => '전설 장비 받기  (1 🏆 보스 토큰)';

  @override
  String weGearForged(String name, Object lv) {
    return '$name을(를) Lv$lv에 제작했습니다! 가방을 확인하세요.';
  }

  @override
  String weRewardClaimed(String name) {
    return '$name 받음!';
  }

  @override
  String get gauLeaderboard => '시련 리더보드';

  @override
  String get gauRewardPreview => '보상 미리보기 (클리어 시)';

  @override
  String get gauAutoRestart => '자동 — 당신의 수정자로 재시작—';

  @override
  String get gauBackToGauntlet => '시련으로 돌아가기';

  @override
  String gauWave(Object n, Object total) {
    return '웨이브 $n / $total';
  }

  @override
  String gauKills(Object kills) {
    return '$kills 처치';
  }

  @override
  String gauEssenceBonus(Object pct) {
    return '+$pct% 정수';
  }

  @override
  String get brLeaderboard => '보스 러시 리더보드';

  @override
  String get brBestScore => '최고 점수: ';

  @override
  String brBossProgress(Object n, Object total) {
    return '보스 $n / $total';
  }

  @override
  String get brPlayAgain => '다시 플레이';

  @override
  String get brPossibleRewards => '가능한 보상';

  @override
  String get brRewShards => '파편';

  @override
  String get brRewShardsD => '보스당 10  ·  전체 클리어 시 +30';

  @override
  String get brRewEchoes => '메아리';

  @override
  String get brRewEchoesD => '보스당 6  ·  전체 클리어 시 +25';

  @override
  String get brRewZcoins => 'Z코인';

  @override
  String get brRewZcoinsD => '전체 클리어 시 15';

  @override
  String get brRewMythril => '미스릴';

  @override
  String get brRewMythrilD => '최종 랭크에 따라 조정';

  @override
  String get brRewArtifact => '유물';

  @override
  String get brRewArtifactD => 'A / S랭크 클리어 시 확률 드롭';

  @override
  String get prgShop => '파라곤 상점';

  @override
  String get prgActiveBonuses => '활성 보너스';

  @override
  String get prgBoard => '✦ 파라곤 보드';

  @override
  String get prgBoardHint => '한 방향에 포인트를 투자하세요 — 랭크는 영원히 상승합니다.';

  @override
  String prgRank(Object rank) {
    return '랭크 $rank';
  }

  @override
  String get prgTutorial =>
      '✦ 파라곤 포인트는 레벨업으로 획득합니다 — 레벨당 1개. 아래 파라곤 보드와 상점에서 절대 초기화되지 않는 영구 전투력에 사용하세요.';

  @override
  String get prgShopSub => '파라곤 포인트를 이후 모든 런에서 유지되는 영구 업그레이드에 사용하세요.';

  @override
  String achClaimedTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '🏆  업적 $count개 받음',
    );
    return '$_temp0';
  }

  @override
  String get achYouReceived => '획득 내역:';

  @override
  String get achNice => '좋아요!';

  @override
  String achClaimAll(Object n) {
    return '모두 받기 ($n)';
  }

  @override
  String get achEconomy => '경제 & 시스템';

  @override
  String get achProgress => '진행';

  @override
  String achClaimed(Object claimed, Object total) {
    return '$claimed / $total 받음';
  }

  @override
  String achReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '받을 수 있는 업적 $count개!',
    );
    return '$_temp0';
  }

  @override
  String get runeTitle => '스킬 룬';

  @override
  String get runeArcaneDust => '🌀 비전 가루: ';

  @override
  String runeOwned(Object a, Object b) {
    return '📜 보유: $a/$b';
  }

  @override
  String get runeNone => '이 직업에 사용 가능한 룬이 없습니다.';

  @override
  String get runeAppBar => '룬';

  @override
  String get runeSocketed => '장착됨';

  @override
  String get runeNotFound => '아직 발견하지 못함 — 보스, 던전, 시련, 원정에서 드롭됩니다.';

  @override
  String get runeEquipFirst => '이 룬을 장착하려면 반지나 목걸이를 착용하세요.';

  @override
  String runeSocketInto(String name, Object cost) {
    return '장착 → $name  (🌀 $cost)';
  }

  @override
  String get runeBody =>
      '룬을 장착해 스킬을 영구히 강화하세요.\n각 룬은 특정 스킬을 수정합니다 — 데미지, 지속 시간, 재사용 대기를 강화.\n장비, 젬, 룬을 분해해 얻는 비전 가루가 듭니다.';

  @override
  String get achTutorial =>
      '첫 보스를 처치했습니다! 🏆 업적은 마일스톤을 추적하고 Z코인과 파편을 보상합니다 — 여기서 받고 자주 확인하세요.';

  @override
  String get bbLocked => '보스 현상금 잠김';

  @override
  String get bbLockedSub => '캠페인 스테이지 20에 도달해 현상금 보상을 위한 보스 사냥을 시작하세요.';

  @override
  String bbTitle(Object t) {
    return '보스 현상금  •  티어 $t';
  }

  @override
  String get bbDesc =>
      '각 캠페인 보스를 처치해 현상금을 받으세요. 새 티어에 도달하면 더 큰 보상의 새 세트가 나옵니다.';

  @override
  String get bbNoBounties => '사용 가능한 현상금이 없습니다.';

  @override
  String bbStageLv(Object n, Object lv) {
    return '캠페인 스테이지 $n  •  Lv $lv';
  }

  @override
  String bbSlain(String name, String detail) {
    return '$name 처치!  $detail';
  }

  @override
  String bbStage(Object n) {
    return '스테이지 $n';
  }

  @override
  String bbGearReward(String rarity) {
    return '🎁 $rarity 장비';
  }

  @override
  String bestTotalKills(Object n) {
    return '총 $n 처치';
  }

  @override
  String get bestTypeMaxed => '종류 최대';

  @override
  String bestGoldBonus(Object pct) {
    return '+$pct% 골드';
  }

  @override
  String get bestKilled => '처치함';

  @override
  String bestNextDmg(Object n) {
    return '$n 처치에서 다음 +1% 데미지';
  }

  @override
  String get lsTitle => '일일 로그인';

  @override
  String get lsComeBack => '내일 다시 와서 다음 보상을 받으세요!';

  @override
  String lsStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count일',
    );
    return '$_temp0';
  }

  @override
  String lsClaimReward(String label) {
    return '받기  $label';
  }

  @override
  String get lsFullCycle => '전체 30일 주기';

  @override
  String lsDay(Object d) {
    return '$d일차';
  }

  @override
  String get lsToday => '오늘';

  @override
  String get dashTitle => '캐릭터 시트';

  @override
  String get dashDailyReady => '받을 수 있는 일일 도전이 있습니다!';

  @override
  String get dashAbilityAfford => '스킬 업그레이드 가능 — 스킬 탭 방문';

  @override
  String get dashPassiveAfford => '패시브 업그레이드 가능 — 패시브 탭 방문';

  @override
  String get dashEndlessAfford => '엔들리스 업그레이드 가능 — 업그레이드 탭 방문';

  @override
  String get dashNextAction => '다음 행동';

  @override
  String get dashIncomeSummary => '수입 요약';

  @override
  String get dashIdleGold => '방치 골드';

  @override
  String get dashBattleKill => '전투/처치';

  @override
  String get dashExpeditions => '원정';

  @override
  String get dashAchievementsNearby => '근접한 업적';

  @override
  String dashDayLoginReward(Object day) {
    return '$day일차 로그인 보상';
  }

  @override
  String dashExpReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '수령 가능한 원정 $count건!',
    );
    return '$_temp0';
  }

  @override
  String dashMercsIdle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '용병 $count명 대기 중 — 원정에 파견하세요',
    );
    return '$_temp0';
  }

  @override
  String get emTitle => '속성 숙련';

  @override
  String emShards(Object n) {
    return '$n 파편';
  }

  @override
  String get emUp => '상승';

  @override
  String get spResetsMonthly => '📅 매월 초기화';

  @override
  String get spUnlockPremium => '프리미엄 패스 해금 — 2× 경험치 + 프리미엄 트랙';

  @override
  String get spFree => '무료';

  @override
  String get spPremium => '👑 프리미엄';

  @override
  String get spTier => '티어';

  @override
  String spClaimed(Object reward) {
    return '$reward 받음';
  }

  @override
  String get spAllUnlocked => '모든 티어 해금 — 잘하셨어요!';

  @override
  String spXpToTier(Object xp, Object next, Object tier) {
    return '티어 $tier까지 $xp / $next 경험치';
  }

  @override
  String spClaimedN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '보상 $n개 받음',
    );
    return '$_temp0';
  }

  @override
  String get spNothingToClaim => '받을 것이 없습니다';

  @override
  String get euEchoes => '메아리';

  @override
  String get euYourBalance => '보유량';

  @override
  String get euEchoesCap => '메아리';

  @override
  String get euTutorial =>
      '시련 런으로 메아리 🔊를 얻습니다 — 여기서 절대 초기화되지 않는 영구 전투 업그레이드에 사용하세요. 게임에서 가장 강력한 보너스 중 일부입니다.';

  @override
  String get euPermanent => '업그레이드는 캐릭터별로 영구적입니다. 보너스는 모든 게임 모드에 적용됩니다.';

  @override
  String euForLv(Object n) {
    return 'Lv $n용';
  }

  @override
  String get euActive => '활성';

  @override
  String get lbRefresh => '새로고침';

  @override
  String get lbNoScores => '아직 점수가 없습니다 — 첫 주자가 되세요!';

  @override
  String get lbPersonalBest => '개인 최고 기록';

  @override
  String get lbRank => '순위';

  @override
  String get lbYou => '나';

  @override
  String get lbError => '리더보드를 불러올 수 없습니다.';

  @override
  String get lbNotRanked => '아직 순위 없음';

  @override
  String get cmTitle => '도전 수정자';

  @override
  String get cmOptionalHandicaps => '선택 핸디캡';

  @override
  String get cmActive => '활성: ';

  @override
  String get cmClear => '해제';

  @override
  String get cmDesc =>
      '캠페인이나 던전에 들어가기 전에 최대 1개의 수정자를 활성화할 수 있습니다. 수정자는 전투를 더 어렵게 만들지만 처치당 파편 보상을 늘립니다.';

  @override
  String cmEssence(Object pct) {
    return '+$pct% 정수';
  }

  @override
  String cmEnemyHp(Object mult) {
    return '적 HP ×$mult';
  }

  @override
  String cmEnemyAtk(Object mult) {
    return '적 공격력 ×$mult';
  }

  @override
  String cmHeroHp(Object mult) {
    return '영웅 HP ×$mult';
  }

  @override
  String get wClose => '닫기';

  @override
  String get battleLog => '전투 기록';

  @override
  String get buffDodge => '회피';

  @override
  String get buffStun => '기절';

  @override
  String get dhPowerTip => '중세 전투력 — 모든 업그레이드,\n장비, 패시브, 프레스티지, 유물, 동료의 통합 점수.';

  @override
  String dhHpTip(Object regen) {
    return '체력 — 0이 되면 전투에서 패배합니다.\n재생: $regen HP/라운드';
  }

  @override
  String dhXpTip(Object xp, Object lv, Object next) {
    return '경험치 — $xp에 도달하면 레벨업.\n레벨 $lv → $next';
  }

  @override
  String get dhNice => '좋아요';

  @override
  String get bspAbilities => '스킬';

  @override
  String get bspMercs => '용병';

  @override
  String get bspEnemyStun => '적 기절';

  @override
  String get bspPassive => '패시브';

  @override
  String bspDescAtk(Object pct) {
    return '영웅이 공격당 +$pct% 데미지를 입힙니다.';
  }

  @override
  String bspDescArmor(Object pct) {
    return '+$pct% 방어 등급 — 받는 적 데미지를 줄입니다.';
  }

  @override
  String get bspDescDodge => '영웅이 다음 적 공격을 완전히 회피합니다.';

  @override
  String bspDescAura(Object hp) {
    return '치유 오라 — 각 라운드 시작 시 $hp HP를 회복합니다.';
  }

  @override
  String bspDescDot(Object dmg) {
    return '지속 데미지 — 적이 매 라운드 $dmg 데미지를 받습니다.';
  }

  @override
  String get bspDescStun => '적이 기절해 공격을 건너뜁니다.';

  @override
  String get baMercAbility => '용병 스킬';

  @override
  String get tsCleared => '클리어됨';

  @override
  String get sgFullyUpgraded => '완전히 강화됨';

  @override
  String sgNeedGold(Object cost) {
    return '강화하려면 골드 $cost개가 필요합니다';
  }

  @override
  String get fsVictory => '승리';

  @override
  String get fsDefeat => '패배';

  @override
  String fsVs(String enemy, Object rounds) {
    return 'vs $enemy  ·  $rounds 라운드';
  }

  @override
  String get fsAbilitiesUsed => '사용한 스킬';

  @override
  String get wnTitle => '새로운 소식';

  @override
  String get wnLatest => '최신';

  @override
  String get zcShards => '파편';

  @override
  String get idbNoItem => '장착한 아이템 없음 — 즉시 업그레이드!';

  @override
  String get absTitle => '능력치';

  @override
  String get absBanner =>
      '능력치는 골드로 구매하는 영구 업그레이드입니다.\n어떤 능력치든 자유롭게 강화하세요 — 골드만 있으면 됩니다.';

  @override
  String get absMaxed => '최대';

  @override
  String absNext(Object cost) {
    return '다음: 골드 $cost개';
  }

  @override
  String absRankOf(Object rank, Object max) {
    return '랭크 $rank / $max';
  }

  @override
  String get bestUndiscovered => '이 생물을 처치해 비밀을 밝히세요.';

  @override
  String shopAdOffer(Object n, Object left, Object max) {
    return '광고당 Z코인 $n개 획득  •  $left/$max 남음';
  }

  @override
  String get shopLifetimeTitle => '영원의 서약';

  @override
  String get shopLifetimeTagline => '한 번의 구매. 모든 프리미엄 혜택. 영원히.';

  @override
  String get shopLifetimeBadge => '최고의 가치';

  @override
  String get shopLifetimeOwned => '✓ 영구 해금됨';

  @override
  String shopLifetimeBuy(Object price) {
    return '영구 해금  ·  $price';
  }

  @override
  String get shopLifetimeIncludes => '모든 것 포함';

  @override
  String get shopLifetimePerk1 => '모든 어센던트 크라운 혜택';

  @override
  String get shopLifetimePerk2 => '5× 전투 속도';

  @override
  String get shopLifetimePerk3 => '+100% 자원 생성';

  @override
  String get shopLifetimePerk4 => '2× 시즌 패스 경험치';

  @override
  String get shopLifetimePerk5 => '프리미엄 시즌 패스 보상';

  @override
  String get shopLifetimePerk6 => '배틀 시뮬레이션 이용';

  @override
  String get shopLifetimePerk7 => '반복 결제 없음 — 영원히';

  @override
  String get shopLifetimePerk8 => '자동 캠페인 (스테이지 5부터 무료)';

  @override
  String get ratingTitle => 'Zeta Idle이 재미있나요?';

  @override
  String get ratingBody =>
      '한동안 모험을 즐기셨네요! 재미있으셨다면 간단한 평가가 게임 성장에 큰 도움이 됩니다. 🙏';

  @override
  String get ratingLove => '너무 좋아요!';

  @override
  String get ratingMeh => '별로예요';

  @override
  String get saveHeroTitle => '영웅 저장하기';

  @override
  String get saveHeroBody =>
      'Google로 로그인해 진행 상황을 클라우드에 백업하세요. 영웅을 안전하게 지키고 여러 기기에서 이어가세요 — 무료, 몇 초면 됩니다.';

  @override
  String get saveHeroLater => '나중에';

  @override
  String get saveHeroConfirm => '내 영웅 저장';

  @override
  String get saveHeroSynced => '진행 상황이 클라우드에 저장되었습니다.';

  @override
  String get saveHeroFailed => '로그인이 완료되지 않았습니다.';

  @override
  String get firstStepsTitle => '첫걸음';

  @override
  String get firstStepsSubtitle => '이것들을 완료해 기본기를 익히고 희귀 상자를 획득하세요.';

  @override
  String get firstStepsWinBattle => '첫 전투에서 승리하기';

  @override
  String get firstStepsReachStage3 => '스테이지 3 도달';

  @override
  String get firstStepsFirstBoss => '첫 보스 처치';

  @override
  String get firstStepsReachStage10 => '스테이지 10 도달';

  @override
  String get firstStepsCapstone => '희귀 상자 받기';

  @override
  String get firstStepsClaim => '받기';

  @override
  String get firstStepsClaimed => '받음';

  @override
  String get firstStepsInProgress => '진행 중';

  @override
  String get firstStepsLocked => '잠김';
}
