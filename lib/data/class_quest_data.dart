import '../models/class_quest.dart';
import '../models/dnd_class.dart';

class ClassQuestData {
  static const _quests = <DndClass, List<ClassQuest>>{
    DndClass.barbarian: [
      ClassQuest(
        id: 'barb_q0', classRequired: DndClass.barbarian, questIndex: 0,
        title: 'Taste of Blood',
        description: 'Cut down your first wave of foes. The rage is just awakening.',
        condition: QuestCondition.killEnemies, target: 30,
        reward: QuestReward(gold: 500),
      ),
      ClassQuest(
        id: 'barb_q1', classRequired: DndClass.barbarian, questIndex: 1,
        title: 'Unbroken Fury',
        description: 'Win 20 battles without ever truly falling.',
        condition: QuestCondition.winBattles, target: 20,
        reward: QuestReward(shards: 25),
      ),
      ClassQuest(
        id: 'barb_q2', classRequired: DndClass.barbarian, questIndex: 2,
        title: 'Conqueror',
        description: 'Crush your way through the first two zones.',
        condition: QuestCondition.reachStage, target: 10,
        reward: QuestReward(gold: 800, shards: 15),
      ),
      ClassQuest(
        id: 'barb_q3', classRequired: DndClass.barbarian, questIndex: 3,
        title: 'Bloodsoaked',
        description: 'Slaughter 250 enemies. Let the battlefield run red.',
        condition: QuestCondition.killEnemies, target: 250,
        reward: QuestReward(permanentAttackBonus: 1),
      ),
      ClassQuest(
        id: 'barb_q4', classRequired: DndClass.barbarian, questIndex: 4,
        title: 'Warlord',
        description: 'Topple 20 bosses. Prove you rule the battlefield.',
        condition: QuestCondition.bossKills, target: 20,
        reward: QuestReward(title: 'Warlord', permanentDamageBonus: 1),
      ),
    ],

    DndClass.bard: [
      ClassQuest(
        id: 'bard_q0', classRequired: DndClass.bard, questIndex: 0,
        title: 'Opening Act',
        description: 'Win 15 battles — the crowd is watching.',
        condition: QuestCondition.winBattles, target: 15,
        reward: QuestReward(gold: 500),
      ),
      ClassQuest(
        id: 'bard_q1', classRequired: DndClass.bard, questIndex: 1,
        title: 'Troubadour',
        description: 'Use your abilities 40 times — a performance that never stops.',
        condition: QuestCondition.useAbilities, target: 40,
        reward: QuestReward(shards: 25),
      ),
      ClassQuest(
        id: 'bard_q2', classRequired: DndClass.bard, questIndex: 2,
        title: 'Acclaimed Performer',
        description: 'Your reputation precedes you — reach stage 8.',
        condition: QuestCondition.reachStage, target: 8,
        reward: QuestReward(gold: 700, shards: 10),
      ),
      ClassQuest(
        id: 'bard_q3', classRequired: DndClass.bard, questIndex: 3,
        title: 'Master Storyteller',
        description: 'Survive 80 battles. Every scar is a new verse.',
        condition: QuestCondition.winBattles, target: 80,
        reward: QuestReward(permanentACBonus: 1),
      ),
      ClassQuest(
        id: 'bard_q4', classRequired: DndClass.bard, questIndex: 4,
        title: 'Legend of the Court',
        description: 'Use abilities 250 times — your name echoes through the realm.',
        condition: QuestCondition.useAbilities, target: 250,
        reward: QuestReward(title: 'Legendary Bard', permanentAttackBonus: 1),
      ),
    ],

    DndClass.cleric: [
      ClassQuest(
        id: 'cler_q0', classRequired: DndClass.cleric, questIndex: 0,
        title: 'Divine Mandate',
        description: 'Strike down 30 enemies in the name of your god.',
        condition: QuestCondition.killEnemies, target: 30,
        reward: QuestReward(gold: 500),
      ),
      ClassQuest(
        id: 'cler_q1', classRequired: DndClass.cleric, questIndex: 1,
        title: 'Defender of the Faithful',
        description: 'Win 15 battles by the grace of your deity.',
        condition: QuestCondition.winBattles, target: 15,
        reward: QuestReward(shards: 20),
      ),
      ClassQuest(
        id: 'cler_q2', classRequired: DndClass.cleric, questIndex: 2,
        title: 'Holy Pilgrim',
        description: 'Journey through two zones on your sacred mission.',
        condition: QuestCondition.reachStage, target: 10,
        reward: QuestReward(gold: 800, shards: 15),
      ),
      ClassQuest(
        id: 'cler_q3', classRequired: DndClass.cleric, questIndex: 3,
        title: 'Blessed Warrior',
        description: 'Smite 10 bosses with divine retribution.',
        condition: QuestCondition.bossKills, target: 10,
        reward: QuestReward(permanentACBonus: 1),
      ),
      ClassQuest(
        id: 'cler_q4', classRequired: DndClass.cleric, questIndex: 4,
        title: 'High Priest',
        description: 'Prove your faith by reaching the fourth zone.',
        condition: QuestCondition.reachStage, target: 20,
        reward: QuestReward(title: 'High Priest', permanentACBonus: 1),
      ),
    ],

    DndClass.druid: [
      ClassQuest(
        id: 'drud_q0', classRequired: DndClass.druid, questIndex: 0,
        title: "Nature's Debt",
        description: 'The wilds demand balance — slay 25 enemies.',
        condition: QuestCondition.killEnemies, target: 25,
        reward: QuestReward(gold: 400),
      ),
      ClassQuest(
        id: 'drud_q1', classRequired: DndClass.druid, questIndex: 1,
        title: 'Shapeshifter',
        description: 'Adapt and overcome — win 20 battles.',
        condition: QuestCondition.winBattles, target: 20,
        reward: QuestReward(shards: 20),
      ),
      ClassQuest(
        id: 'drud_q2', classRequired: DndClass.druid, questIndex: 2,
        title: 'Forest Guardian',
        description: 'Push the corruption back — reach stage 8.',
        condition: QuestCondition.reachStage, target: 8,
        reward: QuestReward(gold: 700, shards: 10),
      ),
      ClassQuest(
        id: 'drud_q3', classRequired: DndClass.druid, questIndex: 3,
        title: 'Ancient Grove',
        description: 'Cleanse the land of 150 corrupted creatures.',
        condition: QuestCondition.killEnemies, target: 150,
        reward: QuestReward(permanentDamageBonus: 1),
      ),
      ClassQuest(
        id: 'drud_q4', classRequired: DndClass.druid, questIndex: 4,
        title: 'Archdruid',
        description: 'Fell 10 of the realm\'s great bosses.',
        condition: QuestCondition.bossKills, target: 10,
        reward: QuestReward(title: 'Archdruid', permanentACBonus: 1),
      ),
    ],

    DndClass.fighter: [
      ClassQuest(
        id: 'fght_q0', classRequired: DndClass.fighter, questIndex: 0,
        title: "Soldier's Discipline",
        description: 'Win 20 battles through sheer discipline and training.',
        condition: QuestCondition.winBattles, target: 20,
        reward: QuestReward(gold: 500),
      ),
      ClassQuest(
        id: 'fght_q1', classRequired: DndClass.fighter, questIndex: 1,
        title: 'Veteran',
        description: 'Cut through 75 enemies. Experience is the best teacher.',
        condition: QuestCondition.killEnemies, target: 75,
        reward: QuestReward(shards: 25),
      ),
      ClassQuest(
        id: 'fght_q2', classRequired: DndClass.fighter, questIndex: 2,
        title: 'Seasoned Warrior',
        description: 'March through three zones of brutal combat.',
        condition: QuestCondition.reachStage, target: 12,
        reward: QuestReward(gold: 1000, shards: 15),
      ),
      ClassQuest(
        id: 'fght_q3', classRequired: DndClass.fighter, questIndex: 3,
        title: 'Battle Master',
        description: 'Win 100 battles. You\'ve mastered the art of war.',
        condition: QuestCondition.winBattles, target: 100,
        reward: QuestReward(permanentAttackBonus: 1),
      ),
      ClassQuest(
        id: 'fght_q4', classRequired: DndClass.fighter, questIndex: 4,
        title: 'Champion',
        description: 'Defeat 25 bosses. Your legend is undeniable.',
        condition: QuestCondition.bossKills, target: 25,
        reward: QuestReward(title: 'Champion', permanentDamageBonus: 1),
      ),
    ],

    DndClass.monk: [
      ClassQuest(
        id: 'monk_q0', classRequired: DndClass.monk, questIndex: 0,
        title: 'First Form',
        description: 'Channel your inner power 25 times.',
        condition: QuestCondition.useAbilities, target: 25,
        reward: QuestReward(gold: 400),
      ),
      ClassQuest(
        id: 'monk_q1', classRequired: DndClass.monk, questIndex: 1,
        title: 'Inner Peace',
        description: 'Win 25 battles with calm and focus.',
        condition: QuestCondition.winBattles, target: 25,
        reward: QuestReward(shards: 20),
      ),
      ClassQuest(
        id: 'monk_q2', classRequired: DndClass.monk, questIndex: 2,
        title: 'Wandering Master',
        description: 'Walk the path through two zones of danger.',
        condition: QuestCondition.reachStage, target: 10,
        reward: QuestReward(gold: 800, shards: 10),
      ),
      ClassQuest(
        id: 'monk_q3', classRequired: DndClass.monk, questIndex: 3,
        title: 'Thousand Strikes',
        description: 'Use your abilities 200 times — the body becomes the weapon.',
        condition: QuestCondition.useAbilities, target: 200,
        reward: QuestReward(permanentAttackBonus: 1),
      ),
      ClassQuest(
        id: 'monk_q4', classRequired: DndClass.monk, questIndex: 4,
        title: 'Grand Master',
        description: 'Fell 200 enemies with perfect technique.',
        condition: QuestCondition.killEnemies, target: 200,
        reward: QuestReward(title: 'Grand Master', permanentACBonus: 1),
      ),
    ],

    DndClass.paladin: [
      ClassQuest(
        id: 'pala_q0', classRequired: DndClass.paladin, questIndex: 0,
        title: 'Oath Sworn',
        description: 'Strike down 25 enemies in service of your oath.',
        condition: QuestCondition.killEnemies, target: 25,
        reward: QuestReward(gold: 500),
      ),
      ClassQuest(
        id: 'pala_q1', classRequired: DndClass.paladin, questIndex: 1,
        title: 'Crusader',
        description: 'Win 20 battles as a holy knight of the realm.',
        condition: QuestCondition.winBattles, target: 20,
        reward: QuestReward(shards: 25),
      ),
      ClassQuest(
        id: 'pala_q2', classRequired: DndClass.paladin, questIndex: 2,
        title: 'Holy Knight',
        description: 'Press the crusade into the third zone.',
        condition: QuestCondition.reachStage, target: 12,
        reward: QuestReward(gold: 1000, shards: 15),
      ),
      ClassQuest(
        id: 'pala_q3', classRequired: DndClass.paladin, questIndex: 3,
        title: 'Divine Warrior',
        description: 'Smite 15 bosses with righteous fury.',
        condition: QuestCondition.bossKills, target: 15,
        reward: QuestReward(permanentDamageBonus: 1),
      ),
      ClassQuest(
        id: 'pala_q4', classRequired: DndClass.paladin, questIndex: 4,
        title: 'Holy Avenger',
        description: 'Reach the fourth zone on your sacred quest.',
        condition: QuestCondition.reachStage, target: 20,
        reward: QuestReward(title: 'Holy Avenger', permanentACBonus: 1),
      ),
    ],

    DndClass.ranger: [
      ClassQuest(
        id: 'rang_q0', classRequired: DndClass.ranger, questIndex: 0,
        title: 'First Hunt',
        description: 'Track and kill 30 prey. The wilderness is yours.',
        condition: QuestCondition.killEnemies, target: 30,
        reward: QuestReward(gold: 400),
      ),
      ClassQuest(
        id: 'rang_q1', classRequired: DndClass.ranger, questIndex: 1,
        title: 'Tracker',
        description: 'Bring down 5 boss creatures — the apex predators.',
        condition: QuestCondition.bossKills, target: 5,
        reward: QuestReward(shards: 20),
      ),
      ClassQuest(
        id: 'rang_q2', classRequired: DndClass.ranger, questIndex: 2,
        title: 'Wilderness Scout',
        description: 'Chart the first two zones of the blighted realm.',
        condition: QuestCondition.reachStage, target: 8,
        reward: QuestReward(gold: 700, shards: 10),
      ),
      ClassQuest(
        id: 'rang_q3', classRequired: DndClass.ranger, questIndex: 3,
        title: 'Master Hunter',
        description: 'Mark and slay 150 enemies with lethal precision.',
        condition: QuestCondition.killEnemies, target: 150,
        reward: QuestReward(permanentAttackBonus: 1),
      ),
      ClassQuest(
        id: 'rang_q4', classRequired: DndClass.ranger, questIndex: 4,
        title: 'Warden',
        description: 'Claim 15 boss kills — the realm\'s most feared hunter.',
        condition: QuestCondition.bossKills, target: 15,
        reward: QuestReward(title: 'Warden', permanentDamageBonus: 1),
      ),
    ],

    DndClass.rogue: [
      ClassQuest(
        id: 'rogu_q0', classRequired: DndClass.rogue, questIndex: 0,
        title: 'First Contract',
        description: 'Complete 15 successful engagements.',
        condition: QuestCondition.winBattles, target: 15,
        reward: QuestReward(gold: 400),
      ),
      ClassQuest(
        id: 'rogu_q1', classRequired: DndClass.rogue, questIndex: 1,
        title: 'Shadow Walk',
        description: 'Silence 50 targets from the dark.',
        condition: QuestCondition.killEnemies, target: 50,
        reward: QuestReward(shards: 20),
      ),
      ClassQuest(
        id: 'rogu_q2', classRequired: DndClass.rogue, questIndex: 2,
        title: 'Infiltrator',
        description: 'Penetrate the defenses of the first two zones.',
        condition: QuestCondition.reachStage, target: 10,
        reward: QuestReward(gold: 800, shards: 10),
      ),
      ClassQuest(
        id: 'rogu_q3', classRequired: DndClass.rogue, questIndex: 3,
        title: 'Phantom Blade',
        description: 'Strike from the shadows 150 times.',
        condition: QuestCondition.useAbilities, target: 150,
        reward: QuestReward(permanentAttackBonus: 1),
      ),
      ClassQuest(
        id: 'rogu_q4', classRequired: DndClass.rogue, questIndex: 4,
        title: 'Assassin',
        description: 'Eliminate 15 boss targets. No contract is beyond you.',
        condition: QuestCondition.bossKills, target: 15,
        reward: QuestReward(title: 'Assassin', permanentDamageBonus: 1),
      ),
    ],

    DndClass.sorcerer: [
      ClassQuest(
        id: 'sorc_q0', classRequired: DndClass.sorcerer, questIndex: 0,
        title: 'Spark of Power',
        description: 'Unleash your innate magic 25 times.',
        condition: QuestCondition.useAbilities, target: 25,
        reward: QuestReward(gold: 400),
      ),
      ClassQuest(
        id: 'sorc_q1', classRequired: DndClass.sorcerer, questIndex: 1,
        title: 'Arcane Seeker',
        description: 'Win 20 battles by raw sorcerous force.',
        condition: QuestCondition.winBattles, target: 20,
        reward: QuestReward(shards: 20),
      ),
      ClassQuest(
        id: 'sorc_q2', classRequired: DndClass.sorcerer, questIndex: 2,
        title: 'Chaos Wielder',
        description: 'Channel wild magic through two treacherous zones.',
        condition: QuestCondition.reachStage, target: 10,
        reward: QuestReward(gold: 800, shards: 10),
      ),
      ClassQuest(
        id: 'sorc_q3', classRequired: DndClass.sorcerer, questIndex: 3,
        title: 'Wild Mage',
        description: 'Blast your spells 200 times — embrace the chaos.',
        condition: QuestCondition.useAbilities, target: 200,
        reward: QuestReward(permanentDamageBonus: 1),
      ),
      ClassQuest(
        id: 'sorc_q4', classRequired: DndClass.sorcerer, questIndex: 4,
        title: 'Wild Archmage',
        description: 'Topple 20 bosses on pure sorcerous instinct.',
        condition: QuestCondition.bossKills, target: 20,
        reward: QuestReward(title: 'Wild Archmage', permanentAttackBonus: 1),
      ),
    ],

    DndClass.warlock: [
      ClassQuest(
        id: 'wrlk_q0', classRequired: DndClass.warlock, questIndex: 0,
        title: 'The Pact',
        description: 'Honor your patron — slay 25 enemies with eldritch power.',
        condition: QuestCondition.killEnemies, target: 25,
        reward: QuestReward(gold: 400),
      ),
      ClassQuest(
        id: 'wrlk_q1', classRequired: DndClass.warlock, questIndex: 1,
        title: 'Infernal Bargain',
        description: 'Claim 5 boss souls for your patron.',
        condition: QuestCondition.bossKills, target: 5,
        reward: QuestReward(shards: 20),
      ),
      ClassQuest(
        id: 'wrlk_q2', classRequired: DndClass.warlock, questIndex: 2,
        title: 'Dark Pilgrim',
        description: 'Walk into the abyss — reach stage 10.',
        condition: QuestCondition.reachStage, target: 10,
        reward: QuestReward(gold: 800, shards: 10),
      ),
      ClassQuest(
        id: 'wrlk_q3', classRequired: DndClass.warlock, questIndex: 3,
        title: 'Eldritch Horror',
        description: 'Exterminate 200 enemies with your patron\'s gift.',
        condition: QuestCondition.killEnemies, target: 200,
        reward: QuestReward(permanentDamageBonus: 1),
      ),
      ClassQuest(
        id: 'wrlk_q4', classRequired: DndClass.warlock, questIndex: 4,
        title: 'Void Walker',
        description: 'Win 100 battles — your patron is pleased.',
        condition: QuestCondition.winBattles, target: 100,
        reward: QuestReward(title: 'Void Walker', permanentAttackBonus: 1),
      ),
    ],

    DndClass.wizard: [
      ClassQuest(
        id: 'wizd_q0', classRequired: DndClass.wizard, questIndex: 0,
        title: 'Apprentice',
        description: 'Cast your spells 20 times — knowledge is power.',
        condition: QuestCondition.useAbilities, target: 20,
        reward: QuestReward(gold: 400),
      ),
      ClassQuest(
        id: 'wizd_q1', classRequired: DndClass.wizard, questIndex: 1,
        title: 'Spellblade',
        description: 'Prove that the wizard can endure — win 20 battles.',
        condition: QuestCondition.winBattles, target: 20,
        reward: QuestReward(shards: 20),
      ),
      ClassQuest(
        id: 'wizd_q2', classRequired: DndClass.wizard, questIndex: 2,
        title: 'Arcane Scholar',
        description: 'Study the first two zones in full detail.',
        condition: QuestCondition.reachStage, target: 10,
        reward: QuestReward(gold: 800, shards: 10),
      ),
      ClassQuest(
        id: 'wizd_q3', classRequired: DndClass.wizard, questIndex: 3,
        title: 'Arcane Mastery',
        description: 'Cast your spells 200 times — the arcane bends to your will.',
        condition: QuestCondition.useAbilities, target: 200,
        reward: QuestReward(permanentDamageBonus: 1),
      ),
      ClassQuest(
        id: 'wizd_q4', classRequired: DndClass.wizard, questIndex: 4,
        title: 'Arch-Wizard',
        description: 'Conquer all 25 campaign stages — the realm is your laboratory.',
        condition: QuestCondition.reachStage, target: 25,
        reward: QuestReward(title: 'Arch-Wizard', permanentACBonus: 1),
      ),
    ],
  };

  static List<ClassQuest> questsForClass(DndClass cls) => _quests[cls] ?? const [];
}
