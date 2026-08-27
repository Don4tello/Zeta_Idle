import '../models/class_quest.dart' show QuestReward;
import 'campaign_data.dart';
import 'enemy_data.dart';

/// A "slay a specific campaign boss" quest. Generated from the real campaign
/// boss stages so the names always match what you actually fight. Wired into
/// the existing quest-claim mechanics (keyed by [id] in questsClaimed).
class BossHunt {
  const BossHunt({
    required this.stage,
    required this.name,
    required this.spriteId,
    required this.level,
    required this.reward,
  });

  /// 0-based campaign stage index of the boss.
  final int stage;
  final String name;
  final String spriteId;
  final int level;
  final QuestReward reward;

  String get id => 'bosshunt_$stage';
  int get stageNumber => stage + 1; // 1-based for display
}

List<BossHunt>? _cache;

/// All campaign boss hunts (bosses sit on every 5th stage: indices 4, 9, 14…).
List<BossHunt> get bossHunts {
  if (_cache != null) return _cache!;
  final list = <BossHunt>[];
  final total = CampaignData.stages.length;
  for (int idx = 4; idx < total; idx += 5) {
    final e = EnemyData.enemyForStage(idx);
    final n = (idx ~/ 5) + 1;            // boss ordinal: 1, 2, 3…
    final isFinal = idx + 5 >= total;    // last boss in the campaign
    list.add(BossHunt(
      stage:    idx,
      name:     e.name,
      spriteId: EnemyData.spriteIdForStage(idx),
      level:    e.level,
      reward: QuestReward(
        gold:    600 * n,
        shards:  8 * n,
        essence: 15 * n,
        zcoins:  n % 3 == 0 ? 5 : 0,
        mythril: isFinal ? 25 : (n % 5 == 0 ? 5 : 0),
        title:   isFinal ? 'Bane of the Realm' : null,
      ),
    ));
  }
  _cache = list;
  return list;
}
