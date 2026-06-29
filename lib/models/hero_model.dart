import 'damage_type.dart';
import 'dnd_class.dart';

enum HeroGender {
  male,
  female,
  nonBinary;

  String get icon => switch (this) {
    HeroGender.male      => '♂',
    HeroGender.female    => '♀',
    HeroGender.nonBinary => '⚧',
  };

  String get label => switch (this) {
    HeroGender.male      => 'Male',
    HeroGender.female    => 'Female',
    HeroGender.nonBinary => 'Non-Binary',
  };

  static HeroGender? tryParse(String? s) =>
      HeroGender.values.where((v) => v.name == s).firstOrNull;
}

const int kStatCap = 100;

class HeroModel {
  HeroModel({
    required this.name,
    this.heroClass = DndClass.fighter,
    this.gender = HeroGender.male,
    this.level = 1,
    this.experience = 0,
    this.experienceToNextLevel = 100,
    this.strength = 5,
    this.dexterity = 5,
    this.constitution = 6,
    this.intelligence = 5,
    this.wisdom = 5,
    this.charisma = 5,
    int? currentHealth,
  }) : currentHealth = currentHealth ?? 100;

  String name;
  DndClass heroClass;
  HeroGender gender;
  int level;
  int experience;
  int experienceToNextLevel;

  // Core attributes (stored under legacy names for save compatibility)
  int strength;     // POWER    — Physical Damage % and resistance
  int dexterity;    // AGILITY  — Lightning Damage % and resistance
  int constitution; // VITALITY — Poison Damage % and resistance
  int intelligence; // ARCANE   — Void Damage % and resistance
  int wisdom;       // FOCUS    — Cold Damage % and resistance
  int charisma;     // FORTUNE  — Fire Damage % and resistance

  int currentHealth;

  // Applied by HeroTrait chosen at character creation (+/- %)
  int extraHpPct = 0;

  // +10% damage per 10 hero levels (permanent, additive with other % bonuses)
  int levelBonusDamagePct = 0;

  // ── Elemental damage system ────────────────────────────────────────────────
  // classElement unlocks at level 5 (auto).
  // secondaryElement unlocks via the Dual Mastery upgrade.
  // activeDamageTypeIndex: 0 = physical, 1 = classElement, 2 = secondaryElement
  int activeDamageTypeIndex = 0;
  bool dualMasteryUnlocked  = false;

  // ── Modern display aliases ─────────────────────────────────────
  int get power    => strength;     // Physical Damage %
  int get agility  => dexterity;    // Lightning Damage %
  int get vitality => constitution; // Poison Damage %
  int get arcane   => intelligence; // Void Damage %
  int get focus    => wisdom;       // Cold Damage %
  int get fortune  => charisma;     // Fire Damage %

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
  // Attack bonus = proficiency only (stats no longer contribute)
  int get attackBonus => proficiencyBonus;

  // Flat damage scales with level (+1 per 2 levels); % damage via damagePctFor
  int get damageMod => level ~/ 2;

  // Max HP: level-based + Vitality (CON) scaling
  int get maxHealth {
    final base = 100 + (level - 1) * 20;
    final vitalityBonus = constitution; // +1% max HP per point of CON
    return (base * (100 + extraHpPct + vitalityBonus) / 100).round().clamp(1, 99999);
  }

  // Armor class = flat 10; DEX no longer boosts AC (use passives/items)
  int get armorClass => 10;

  // Idle rate = flat 5; WIS no longer boosts idle rate (use passives/items)
  int get idleRate => 5;

  // Gold multiplier = flat 1; INT no longer boosts gold (use passives/items)
  int get goldRate => 1;

  // XP multiplier = flat 1.0; CHA no longer boosts XP (use passives/items)
  double get xpMultiplier => 1.0;

  // Elemental damage % from each stat: stat * 25 / 100 → 0–25% at stat 0–100
  // STR→Physical, DEX→Lightning, CON→Poison, INT→Void, WIS→Cold, CHA→Fire
  int damagePctFor(DamageType type) {
    final stat = switch (type) {
      DamageType.physical  => strength,
      DamageType.lightning => dexterity,
      DamageType.poison    => constitution,
      DamageType.void_     => intelligence,
      DamageType.cold      => wisdom,
      DamageType.fire      => charisma,
    };
    return stat * 25 ~/ 100;
  }

  // Battle sprite ID based on chosen class
  String get spriteId => heroClass.spriteId;

  // ── Damage type accessors ──────────────────────────────────────────────────
  // Returns the DamageType the hero is currently dealing.
  // physical is always available; classElement at lv5+; secondaryElement if unlocked.
  bool get classElementUnlocked => level >= 5;

  DamageType get activeDamageType {
    if (activeDamageTypeIndex == 2 && dualMasteryUnlocked) {
      return heroClass.info.secondaryElement;
    }
    if (activeDamageTypeIndex == 1 && classElementUnlocked) {
      return heroClass.info.classElement;
    }
    return DamageType.physical;
  }

  List<DamageType> get availableDamageTypes {
    final types = [DamageType.physical];
    final ce = heroClass.info.classElement;
    final se = heroClass.info.secondaryElement;
    if (classElementUnlocked && !types.contains(ce)) types.add(ce);
    if (dualMasteryUnlocked && !types.contains(se)) types.add(se);
    return types;
  }

  void cycleNextDamageType() {
    final available = availableDamageTypes;
    if (available.length <= 1) return;
    activeDamageTypeIndex = (activeDamageTypeIndex + 1) % available.length;
  }

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
    experienceToNextLevel = (experienceToNextLevel * 1.08).round();

    // Grant automatic stat growth on every level-up
    _applyStat(_primaryStat[heroClass] ?? 'strength', 1);
    if (level % 2 == 0) _applyStat(_secondaryStat[heroClass] ?? 'constitution', 1);
    if (level % 3 == 0) constitution = (constitution + 1).clamp(0, kStatCap);

    if (level % 10 == 0) levelBonusDamagePct += 10;
    currentHealth = maxHealth; // full heal on level-up
  }

  void _applyStat(String stat, int amount) {
    switch (stat) {
      case 'strength':     strength     = (strength     + amount).clamp(0, kStatCap);
      case 'dexterity':    dexterity    = (dexterity    + amount).clamp(0, kStatCap);
      case 'constitution': constitution = (constitution + amount).clamp(0, kStatCap);
      case 'intelligence': intelligence = (intelligence + amount).clamp(0, kStatCap);
      case 'wisdom':       wisdom       = (wisdom       + amount).clamp(0, kStatCap);
      case 'charisma':     charisma     = (charisma     + amount).clamp(0, kStatCap);
    }
  }

  void takeDamage(int amount) {
    currentHealth = (currentHealth - amount).clamp(0, maxHealth);
  }

  void healToFull() {
    currentHealth = maxHealth;
  }

  // Stat-specific adders called by upgrades — all clamped to kStatCap
  void addStrength(int amount)     { strength     = (strength     + amount).clamp(0, kStatCap); }
  void addDexterity(int amount)    { dexterity    = (dexterity    + amount).clamp(0, kStatCap); }
  void addConstitution(int amount) { constitution = (constitution + amount).clamp(0, kStatCap); currentHealth = maxHealth; }
  void addIntelligence(int amount) { intelligence = (intelligence + amount).clamp(0, kStatCap); }
  void addWisdom(int amount)       { wisdom       = (wisdom       + amount).clamp(0, kStatCap); }
  void addCharisma(int amount)     { charisma     = (charisma     + amount).clamp(0, kStatCap); }

  Map<String, dynamic> toJson() => {
    'name': name,
    'heroClass': heroClass.name,
    'gender': gender.name,
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
    'levelBonusDamagePct': levelBonusDamagePct,
    'activeDamageTypeIndex': activeDamageTypeIndex,
    'dualMasteryUnlocked': dualMasteryUnlocked,
  };

  void loadFromJson(Map<String, dynamic> json) {
    name      = (json['name']      as String?) ?? name;
    heroClass = DndClass.tryParse(json['heroClass'] as String?) ?? DndClass.fighter;
    gender    = HeroGender.tryParse(json['gender'] as String?) ?? HeroGender.male;
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
    extraHpPct             = (json['extraHpPct']             as int?)  ?? 0;
    levelBonusDamagePct    = (json['levelBonusDamagePct']    as int?)  ?? 0;
    activeDamageTypeIndex  = (json['activeDamageTypeIndex']  as int?)  ?? 0;
    dualMasteryUnlocked    = (json['dualMasteryUnlocked']    as bool?) ?? false;
    currentHealth = (json['currentHealth'] as int?) ?? maxHealth;
  }
}
