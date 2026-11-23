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

  @override
  String get saveHeroTitle => 'Save your hero';

  @override
  String get saveHeroBody =>
      'Sign in with Google to back up your progress to the cloud. Keep your hero safe and carry it across devices — free, takes a second.';

  @override
  String get saveHeroLater => 'Later';

  @override
  String get saveHeroConfirm => 'Save my hero';

  @override
  String get saveHeroSynced => 'Progress saved to the cloud.';

  @override
  String get saveHeroFailed => 'Sign-in didn\'t complete.';

  @override
  String get firstStepsTitle => 'FIRST STEPS';

  @override
  String get firstStepsSubtitle =>
      'Finish these to learn the ropes and bag a Rare Chest.';

  @override
  String get firstStepsWinBattle => 'Win your first battle';

  @override
  String get firstStepsReachStage3 => 'Reach Stage 3';

  @override
  String get firstStepsFirstBoss => 'Defeat your first boss';

  @override
  String get firstStepsReachStage10 => 'Reach Stage 10';

  @override
  String get firstStepsCapstone => 'Claim your Rare Chest';

  @override
  String get firstStepsClaim => 'CLAIM';

  @override
  String get firstStepsClaimed => 'Claimed';

  @override
  String get firstStepsInProgress => 'In progress';

  @override
  String get firstStepsLocked => 'Locked';
}
