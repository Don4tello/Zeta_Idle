import 'dnd_class.dart';

enum QuestCondition { killEnemies, winBattles, reachStage, bossKills, useAbilities }

class QuestReward {
  const QuestReward({
    this.gold = 0,
    this.shards = 0,
    this.permanentACBonus = 0,
    this.permanentAttackBonus = 0,
    this.permanentDamageBonus = 0,
    this.title,
  });
  final int gold;
  final int shards;
  final int permanentACBonus;
  final int permanentAttackBonus;
  final int permanentDamageBonus;
  final String? title;

  bool get hasPermanentBonus =>
      permanentACBonus > 0 || permanentAttackBonus > 0 || permanentDamageBonus > 0;

  String get summary {
    final parts = <String>[];
    if (gold > 0) parts.add('$gold gold');
    if (shards > 0) parts.add('$shards shards');
    if (permanentACBonus > 0) parts.add('+$permanentACBonus AC');
    if (permanentAttackBonus > 0) parts.add('+$permanentAttackBonus ATK');
    if (permanentDamageBonus > 0) parts.add('+$permanentDamageBonus DMG');
    if (title != null) parts.add('"$title"');
    return parts.join(' + ');
  }
}

class ClassQuest {
  const ClassQuest({
    required this.id,
    required this.classRequired,
    required this.title,
    required this.description,
    required this.condition,
    required this.target,
    required this.reward,
    required this.questIndex,
  });

  final String id;
  final DndClass classRequired;
  final String title;
  final String description;
  final QuestCondition condition;
  final int target;
  final QuestReward reward;
  final int questIndex; // 0–4, sequential unlock
}
