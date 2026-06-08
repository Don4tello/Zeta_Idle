import 'dnd_class.dart';

class HeroModel {
  HeroModel({
    required this.name,
    this.heroClass = DndClass.fighter,
    this.level = 1,
    this.experience = 0,
    this.experienceToNextLevel = 100,
    this.strength = 10,
    this.dexterity = 10,
    this.constitution = 12,
    this.intelligence = 10,
    this.wisdom = 10,
    this.charisma = 10,
    int? currentHealth,
  }) : currentHealth = currentHealth ?? (10 + _calcConMod(12));

  static int _calcConMod(int con) => (con - 10) ~/ 2;

  String name;
  DndClass heroClass;
  int level;
  int experience;
  int experienceToNextLevel;

  // Core attributes (stored under legacy names for save compatibility)
  int strength;     // POWER    — attack rolls and damage
  int dexterity;    // AGILITY  — armor class and dodge
  int constitution; // VITALITY — max HP and post-battle regen
  int intelligence; // ARCANE   — gold multiplier and item synergies
  int wisdom;       // FOCUS    — idle gold rate
  int charisma;     // FORTUNE  — XP gain and crit chance

  int currentHealth;

  // Applied by HeroTrait chosen at character creation (+/- %)
  int extraHpPct = 0;

  // ── Modern display aliases ─────────────────────────────────────
  int get power    => strength;
  int get agility  => dexterity;
  int get vitality => constitution;
  int get arcane   => intelligence;
  int get focus    => wisdom;
  int get fortune  => charisma;

  // ── Raw modifiers (used internally by formulas) ─────────────────
  int get strMod => (strength - 10) ~/ 2;
  int get dexMod => (dexterity - 10) ~/ 2;
  int get conMod => (constitution - 10) ~/ 2;
  int get intMod => (intelligence - 10) ~/ 2;
  int get wisMod => (wisdom - 10) ~/ 2;
  int get chaMod => (charisma - 10) ~/ 2;

  // Proficiency bonus scales with level (+2 at lv1, +1 per 4 levels)
  int get proficiencyBonus => 2 + (level - 1) ~/ 4;

  // ── Derived combat stats ───────────────────────────────────────
  // Attack bonus = POWER mod + proficiency
  int get attackBonus => strMod + proficiencyBonus;

  // Damage bonus = POWER mod
  int get damageMod => strMod;

  // Max HP: VITALITY × 8 base + (5 + VITALITY mod) per level
  // Larger pool means early fights last 10–20 rounds before upgrades.
  int get maxHealth {
    final base = (30 + constitution * 8) + (level - 1) * (5 + conMod).clamp(1, 99);
    return (base * (100 + extraHpPct) / 100).round().clamp(1, 9999);
  }

  // Armor class = 10 + AGILITY mod
  int get armorClass => 10 + dexMod;

  // Idle rate = 5 + FOCUS mod
  int get idleRate => 5 + wisMod.clamp(-4, 99);

  // Gold multiplier = ARCANE mod (each point of INT above 10 adds 1 gold tier)
  int get goldRate => 1 + intMod.clamp(0, 99);

  // XP multiplier = FORTUNE gives 5% per point of CHA modifier
  double get xpMultiplier => 1.0 + chaMod * 0.05;

  // Battle sprite ID based on chosen class
  String get spriteId => heroClass.spriteId;

  // XP progress 0→1
  double get progress => experience / experienceToNextLevel;

  // Legacy alias used by some widgets
  int get attack => attackBonus;

  // ── Methods ────────────────────────────────────────────────────
  void gainExperience(int amount) {
    experience += amount;
    while (experience >= experienceToNextLevel) {
      experience -= experienceToNextLevel;
      levelUp();
    }
  }

  // Per-class primary/secondary stat gains on level-up.
  // Primary stat: +1 every level. Secondary stat: +1 every 2 levels.
  // Vitality gets +1 every 3 levels for all classes (health always scales).
  static const _primaryStat = <DndClass, String>{
    DndClass.barbarian: 'strength',   DndClass.fighter:  'strength',
    DndClass.paladin:   'strength',   DndClass.monk:     'dexterity',
    DndClass.ranger:    'dexterity',  DndClass.rogue:    'dexterity',
    DndClass.cleric:    'wisdom',     DndClass.druid:    'wisdom',
    DndClass.wizard:    'intelligence', DndClass.sorcerer: 'charisma',
    DndClass.warlock:   'charisma',   DndClass.bard:     'charisma',
  };
  static const _secondaryStat = <DndClass, String>{
    DndClass.barbarian: 'constitution', DndClass.fighter:  'constitution',
    DndClass.paladin:   'charisma',     DndClass.monk:     'wisdom',
    DndClass.ranger:    'wisdom',       DndClass.rogue:    'intelligence',
    DndClass.cleric:    'constitution', DndClass.druid:    'constitution',
    DndClass.wizard:    'wisdom',       DndClass.sorcerer: 'intelligence',
    DndClass.warlock:   'intelligence', DndClass.bard:     'dexterity',
  };

  void levelUp() {
    level += 1;
    experienceToNextLevel = (experienceToNextLevel * 1.20).round();

    // Grant automatic stat growth on every level-up
    _applyStat(_primaryStat[heroClass] ?? 'strength', 1);
    if (level % 2 == 0) _applyStat(_secondaryStat[heroClass] ?? 'constitution', 1);
    if (level % 3 == 0) constitution += 1; // all classes gain Vitality every 3 levels

    currentHealth = maxHealth; // full heal on level-up
  }

  void _applyStat(String stat, int amount) {
    switch (stat) {
      case 'strength':     strength += amount;
      case 'dexterity':    dexterity += amount;
      case 'constitution': constitution += amount;
      case 'intelligence': intelligence += amount;
      case 'wisdom':       wisdom += amount;
      case 'charisma':     charisma += amount;
    }
  }

  void takeDamage(int amount) {
    currentHealth = (currentHealth - amount).clamp(0, maxHealth);
  }

  void healToFull() {
    currentHealth = maxHealth;
  }

  // Stat-specific adders called by upgrades
  void addStrength(int amount)     { strength += amount; }
  void addDexterity(int amount)    { dexterity += amount; }
  void addConstitution(int amount) { constitution += amount; currentHealth = maxHealth; }
  void addIntelligence(int amount) { intelligence += amount; }
  void addWisdom(int amount)       { wisdom += amount; }
  void addCharisma(int amount)     { charisma += amount; }

  Map<String, dynamic> toJson() => {
    'name': name,
    'heroClass': heroClass.name,
    'level': level,
    'experience': experience,
    'experienceToNextLevel': experienceToNextLevel,
    'strength': strength,
    'dexterity': dexterity,
    'constitution': constitution,
    'intelligence': intelligence,
    'wisdom': wisdom,
    'charisma': charisma,
    'currentHealth': currentHealth,
    'extraHpPct': extraHpPct,
  };

  void loadFromJson(Map<String, dynamic> json) {
    name      = (json['name']      as String?) ?? name;
    heroClass = DndClass.tryParse(json['heroClass'] as String?) ?? DndClass.fighter;
    level = json['level'] as int;
    experience = json['experience'] as int;
    experienceToNextLevel = json['experienceToNextLevel'] as int;
    // Support old saves that don't have D&D stats yet
    strength     = (json['strength']     as int?) ?? 10;
    dexterity    = (json['dexterity']    as int?) ?? 10;
    constitution = (json['constitution'] as int?) ?? 12;
    intelligence = (json['intelligence'] as int?) ?? 10;
    wisdom       = (json['wisdom']       as int?) ?? 10;
    charisma     = (json['charisma']     as int?) ?? 10;
    extraHpPct    = (json['extraHpPct']   as int?) ?? 0;
    currentHealth = (json['currentHealth'] as int?) ?? maxHealth;
  }
}
