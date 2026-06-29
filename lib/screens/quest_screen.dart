import 'package:flutter/material.dart';
import '../data/class_quest_data.dart';
import '../models/class_quest.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

class QuestScreen extends StatelessWidget {
  const QuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final quests = ClassQuestData.questsForClass(game.hero.heroClass);

    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('QUESTLINES', style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
        actions: [
          if (game.heroTitle != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.12),
                    border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.6)),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text('"${game.heroTitle}"',
                      style: AppTheme.pixelHeading(
                          fontSize: 10, color: AppTheme.accentGold, letterSpacing: 1)),
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Adventure Questline ────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1a1a2e), Color(0xFF231F1B)],
              ),
              border: Border.all(color: const Color(0xFFcc88ff).withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(children: [
              const Text('📜', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('ADVENTURE QUESTLINE',
                    style: AppTheme.pixelHeading(
                        fontSize: 12, color: const Color(0xFFcc88ff), letterSpacing: 2)),
                const SizedBox(height: 2),
                Text('Learn every game system on the road to stage 100.',
                    style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
              ])),
              Text('${AdventureQuest.allQuests.where((q) => game.questsClaimed[q.id] == true).length}/${AdventureQuest.allQuests.length}',
                  style: AppTheme.pixelHeading(fontSize: 11, color: const Color(0xFFcc88ff))),
            ]),
          ),
          ...AdventureQuest.allQuests.map((q) => _AdventureQuestCard(quest: q, game: game)),

          const SizedBox(height: 20),

          // ── Class Questline ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF231F1B),
              border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(children: [
              Icon(game.hero.heroClass.info.icon,
                  color: AppTheme.accentGold, size: 22),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${game.hero.heroClass.displayName.toUpperCase()} QUESTS',
                    style: AppTheme.pixelHeading(
                        fontSize: 12, color: AppTheme.accentGold, letterSpacing: 2)),
                const SizedBox(height: 2),
                Text('Class-specific challenges for permanent bonuses.',
                    style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
              ]),
            ]),
          ),
          ...quests.map((q) => _QuestCard(quest: q, game: game)),
        ],
      ),
    );
  }
}

// ── Adventure quest card ─────────────────────────────────────────────────────

class _AdventureQuestCard extends StatelessWidget {
  const _AdventureQuestCard({required this.quest, required this.game});
  final AdventureQuest quest;
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final claimed  = game.questsClaimed[quest.id] == true;
    final unlocked = game.isAdventureQuestUnlocked(quest);
    final condMet  = game.isAdventureQuestMet(quest);
    final progress = game.adventureQuestProgress(quest);
    final ratio    = quest.target > 0 ? progress / quest.target : 0.0;

    if (!unlocked && !claimed) {
      // Show locked placeholder
      return Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF141210),
          border: Border.all(color: const Color(0xFF222222)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(children: [
          const Icon(Icons.lock_outline, size: 14, color: Color(0xFF444444)),
          const SizedBox(width: 10),
          Text(quest.title, style: const TextStyle(fontSize: 12, color: Color(0xFF444444))),
        ]),
      );
    }

    final accentColor = claimed
        ? const Color(0xFF44cc88)
        : condMet
            ? const Color(0xFFcc88ff)
            : const Color(0xFF888888);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: claimed
            ? const Color(0xFF112211)
            : condMet
                ? const Color(0xFF1a1428)
                : const Color(0xFF1a1816),
        border: Border.all(color: accentColor.withValues(alpha: claimed ? 0.5 : 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            if (claimed)
              const Text('✓ ', style: TextStyle(fontSize: 13, color: Color(0xFF44cc88)))
            else
              Text('${quest.questIndex + 1}. ',
                  style: TextStyle(fontSize: 11, color: accentColor, fontWeight: FontWeight.bold)),
            Expanded(
              child: Text(quest.title,
                  style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold,
                    color: claimed ? const Color(0xFF44cc88) : Colors.white,
                  )),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(quest.chapter,
                  style: TextStyle(fontSize: 8, color: accentColor, fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 4),
          Text(quest.description,
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.3)),
          if (!claimed) ...[
            const SizedBox(height: 3),
            Text('💡 ${quest.hint}',
                style: const TextStyle(fontSize: 10, color: Color(0xFF886644), fontStyle: FontStyle.italic)),
          ],
          const SizedBox(height: 8),
          // Progress bar
          if (!claimed) ...[
            Row(children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: ratio.clamp(0.0, 1.0),
                    minHeight: 5,
                    backgroundColor: const Color(0xFF2a2a2a),
                    valueColor: AlwaysStoppedAnimation(accentColor),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('$progress/${quest.target}',
                  style: TextStyle(fontSize: 10, color: accentColor)),
            ]),
            const SizedBox(height: 6),
          ],
          // Reward + claim button
          Row(children: [
            Expanded(
              child: Text(quest.reward.summary,
                  style: TextStyle(fontSize: 10,
                      color: claimed ? const Color(0xFF44cc88).withValues(alpha: 0.5) : const Color(0xFFcc88ff))),
            ),
            if (condMet && !claimed)
              GestureDetector(
                onTap: () => game.claimAdventureQuest(quest),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2a1a44),
                    border: Border.all(color: const Color(0xFFcc88ff)),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text('CLAIM', style: AppTheme.pixelHeading(
                      fontSize: 10, color: const Color(0xFFcc88ff))),
                ),
              ),
          ]),
        ],
      ),
    );
  }
}

// ── Quest card ────────────────────────────────────────────────────────────────

class _QuestCard extends StatelessWidget {
  const _QuestCard({required this.quest, required this.game});
  final ClassQuest quest;
  final GameState game;

  static const _conditionLabels = <QuestCondition, String>{
    QuestCondition.killEnemies:       'Enemies killed',
    QuestCondition.winBattles:        'Battles won',
    QuestCondition.reachStage:        'Stage reached',
    QuestCondition.bossKills:         'Bosses slain',
    QuestCondition.useAbilities:      'Abilities used',
    QuestCondition.dungeonClears:     'Dungeons cleared',
    QuestCondition.gauntletScore:     'Gauntlet high score',
    QuestCondition.bossRushClears:    'Boss Rushes completed',
    QuestCondition.prestigeReach:     'Prestige level',
    QuestCondition.ascensionReach:    'Ascension level',
    QuestCondition.equipItem:         'Items equipped',
    QuestCondition.upgradeAbility:    'Abilities upgraded',
    QuestCondition.unlockPassive:     'Passives unlocked',
    QuestCondition.socketGem:         'Gems socketed',
    QuestCondition.forgeItem:         'Items forged',
    QuestCondition.completeExpedition:'Expeditions completed',
    QuestCondition.pvpWins:           'PvP wins',
    QuestCondition.reachLevel:        'Hero level',
    QuestCondition.earnGold:          'Gold earned',
    QuestCondition.earnEssence:       'Essence earned',
    QuestCondition.collectArtifact:   'Artifacts collected',
    QuestCondition.endlessStage:      'Endless stage',
  };

  @override
  Widget build(BuildContext context) {
    final claimed   = game.questsClaimed[quest.id] == true;
    final unlocked  = game.isQuestUnlocked(quest);
    final condMet   = game.isQuestConditionMet(quest);
    final claimable = game.isQuestClaimable(quest);
    final progress  = game.questProgress(quest);
    final pct       = progress / quest.target;

    Color borderColor;
    if (claimed)        borderColor = const Color(0xFF44cc66).withValues(alpha: 0.5);
    else if (claimable) borderColor = AppTheme.accentGold;
    else if (unlocked)  borderColor = AppTheme.cardBorder;
    else                borderColor = AppTheme.cardBorder.withValues(alpha: 0.4);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: claimed
              ? const Color(0xFF0d1a10)
              : claimable
                  ? AppTheme.accentGold.withValues(alpha: 0.04)
                  : const Color(0xFF231F1B),
          border: Border.all(
              color: borderColor,
              width: claimable ? 1.5 : 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(children: [
              _QuestBadge(index: quest.questIndex, claimed: claimed, claimable: claimable),
              const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(quest.title,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: claimed
                              ? const Color(0xFF44cc66)
                              : unlocked ? Colors.white : Colors.white38)),
                  const SizedBox(height: 2),
                  Text(quest.description,
                      style: TextStyle(
                          fontSize: 11,
                          color: unlocked ? AppTheme.textMuted : Colors.white24,
                          height: 1.3)),
                ],
              )),
              if (claimed)
                const Icon(Icons.check_circle, color: Color(0xFF44cc66), size: 20),
              if (!unlocked)
                const Icon(Icons.lock_outline, color: Colors.white24, size: 18),
            ]),
            const SizedBox(height: 10),

            // Progress bar + label
            Row(children: [
              Expanded(child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: pct.clamp(0.0, 1.0),
                  minHeight: 5,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    claimed
                        ? const Color(0xFF44cc66)
                        : claimable
                            ? AppTheme.accentGold
                            : const Color(0xFF4466aa),
                  ),
                ),
              )),
              const SizedBox(width: 10),
              Text('$progress / ${quest.target}',
                  style: TextStyle(
                      fontSize: 11,
                      color: condMet ? Colors.white70 : Colors.white38,
                      fontWeight: condMet ? FontWeight.bold : FontWeight.normal)),
            ]),
            const SizedBox(height: 4),
            Text('${_conditionLabels[quest.condition] ?? 'Progress'}',
                style: const TextStyle(fontSize: 10, color: Colors.white24)),

            // Lock message
            if (!unlocked) ...[
              const SizedBox(height: 6),
              Text('Complete quest ${quest.questIndex} first to unlock.',
                  style: const TextStyle(fontSize: 11, color: Colors.white30,
                      fontStyle: FontStyle.italic)),
            ],

            // Reward row
            const SizedBox(height: 10),
            _RewardRow(reward: quest.reward),

            // Claim button
            if (claimable) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGold.withValues(alpha: 0.15),
                    foregroundColor: AppTheme.accentGold,
                    side: const BorderSide(color: AppTheme.accentGold),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  onPressed: () => game.claimQuest(quest),
                  child: Text('CLAIM REWARD',
                      style: AppTheme.pixelHeading(
                          fontSize: 12, color: AppTheme.accentGold, letterSpacing: 1)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Quest badge (numbered circle) ─────────────────────────────────────────────

class _QuestBadge extends StatelessWidget {
  const _QuestBadge({
    required this.index,
    required this.claimed,
    required this.claimable,
  });
  final int index;
  final bool claimed;
  final bool claimable;

  @override
  Widget build(BuildContext context) {
    final color = claimed
        ? const Color(0xFF44cc66)
        : claimable
            ? AppTheme.accentGold
            : const Color(0xFF334466);
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.7), width: 1.5),
      ),
      child: Text('${index + 1}',
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: color)),
    );
  }
}

// ── Reward row ────────────────────────────────────────────────────────────────

class _RewardRow extends StatelessWidget {
  const _RewardRow({required this.reward});
  final QuestReward reward;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Text('Reward: ',
          style: TextStyle(fontSize: 11, color: Colors.white38)),
      Expanded(child: Wrap(spacing: 8, runSpacing: 4, children: [
        if (reward.gold > 0) _Chip('💰 ${reward.gold}g', const Color(0xFFFFD700)),
        if (reward.shards > 0) _Chip('◆ ${reward.shards}', const Color(0xFF66aaff)),
        if (reward.permanentAttackBonus > 0)
          _Chip('+${reward.permanentAttackBonus} ATK', const Color(0xFFff6633)),
        if (reward.permanentDamageBonus > 0)
          _Chip('+${reward.permanentDamageBonus} DMG', const Color(0xFFff8844)),
        if (reward.permanentACBonus > 0)
          _Chip('+${reward.permanentACBonus} AC', const Color(0xFF44ccff)),
        if (reward.title != null)
          _Chip('"${reward.title}"', AppTheme.accentGold),
      ])),
    ]);
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.bold)),
    );
  }
}
