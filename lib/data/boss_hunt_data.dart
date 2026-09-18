import '../models/class_quest.dart' show QuestReward;
import 'campaign_data.dart';
import 'enemy_data.dart';

/// A "slay a specific campaign boss" bounty. Generated from the real campaign
/// boss stages so the names always match what you actually fight. Each
/// difficulty [tier] gets its own fresh set of bounties with scaled rewards, so
/// reaching a new tier hands you new boss bounties to hunt. Wired into the
/// existing quest-claim mechanics (keyed by [id] in questsClaimed).
class BossHunt {
  const BossHunt({
    required this.stage,
    required this.tier,
    required this.name,
    required this.spriteId,
    required this.level,
    required this.reward,
  });

  /// 0-based campaign stage index of the boss.
  final int stage;

  /// Difficulty tier this bounty belongs to (0 = base campaign).
  final int tier;
  final String name;
  final String spriteId;
  final int level;
  final QuestReward reward;

  /// Tier 0 keeps the legacy id so previously-claimed hunts stay claimed.
  String get id => tier == 0 ? 'bosshunt_$stage' : 'bosshunt_t${tier}_s$stage';
  int get stageNumber => stage + 1;    // 1-based for display
  int get ordinal => (stage ~/ 5) + 1; // boss ordinal: 1, 2, 3…
}

// Rewards scale up each difficulty tier. Grind currencies (gold/shards/essence)
// roughly double per tier to keep pace with the steep enemy HP growth; premium
// currencies (ZCoins/mythril) scale gently and linearly so they don't inflate.
int _grindMult(int tier)   => 1 << tier;  // 1, 2, 4, 8, 16…
int _premiumMult(int tier) => tier + 1;   // 1, 2, 3, 4…

final Map<int, List<BossHunt>> _cache = {};

/// All campaign boss bounties for a given difficulty [tier]. Bosses sit on every
/// 5th stage (indices 4, 9, 14…). Cached per tier.
List<BossHunt> bossBountiesForTier(int tier) {
  final cached = _cache[tier];
  if (cached != null) return cached;
  final list = <BossHunt>[];
  final total = CampaignData.stages.length;
  for (int idx = 4; idx < total; idx += 5) {
    final e = EnemyData.enemyForStage(idx, prestigeLevel: tier);
    final n = (idx ~/ 5) + 1;         // boss ordinal: 1, 2, 3…
    final isFinal = idx + 5 >= total; // last boss in the campaign
    list.add(BossHunt(
      stage:    idx,
      tier:     tier,
      name:     e.name,
      spriteId: EnemyData.spriteIdForStage(idx),
      level:    e.level,
      reward: QuestReward(
        gold:    600 * n * _grindMult(tier),
        shards:  8 * n * _grindMult(tier),
        essence: 15 * n * _grindMult(tier),
        zcoins:  (n % 3 == 0 ? 5 : 0) * _premiumMult(tier),
        mythril: (isFinal ? 25 : (n % 5 == 0 ? 5 : 0)) * _premiumMult(tier),
        // The realm-bane title is a one-time tier-0 flourish.
        title:   isFinal && tier == 0 ? 'Bane of the Realm' : null,
      ),
    ));
  }
  _cache[tier] = list;
  return list;
}

/// Legacy accessor — the base-tier bounties.
List<BossHunt> get bossHunts => bossBountiesForTier(0);
