import 'damage_type.dart';
import 'dnd_class.dart';

enum HeroGender {
  male,
  female;

  String get icon => switch (this) {
    HeroGender.male   => '♂',
    HeroGender.female => '♀',
  };

  String get label => switch (this) {
    HeroGender.male   => 'Male',
    HeroGender.female => 'Female',
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

  // Flat HP bonus from Ability Score (VIT stat) — always recalculated, never saved
  int flatHpBonus = 0;

  // +10% damage per 10 hero levels (permanent, additive with other % bonuses)
  int levelBonusDamagePct = 0;

  // ── Elemental damage system ────────────────────────────────────────────────
  // classElement unlocks at level 5 (auto).
  // secondaryElement unlocks via the Dual Mastery upgrade.
  // activeDamageTypeIndex indexes availableDamageTypes: 0 = classElement,
  // 1 = secondaryElement (once Dual Mastery is unlocked). Physical was removed.
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

  // Flat damage scales with level (+1 per 2 levels) PLUS Strength (Power) —
  // STR is the universal weapon-power stat: +1 flat hit damage per point on
  // EVERY attack, regardless of element (Physical was retired). % elemental
  // damage still comes from the matching stat via damagePctFor.
  int get damageMod => level ~/ 2 + strength;

  // Combined flat damage stat: proficiency bonus + level-based flat damage
  int get baseDmg => proficiencyBonus + damageMod;

  // Max HP: level-based + Vitality (CON) scaling
  int get maxHealth {
    // Per-level base now grows SUPER-LINEARLY (linear + a quadratic term) so max
    // HP keeps pace with the exponential damage curve instead of falling 5 orders
    // of magnitude behind. Everything (gear/CON/paragon %HP) multiplies this base.
    //   L1 ≈ 100 · L100 ≈ 3.1K · L500 ≈ 57K · L1000 ≈ 214K base
    // → with endgame %HP that's a multi-million pool, and each level noticeably
    // adds HP (the "I'm getting tankier" feel). Early game is barely changed, so
    // onboarding squishiness is preserved. Bumped (+~60% at endgame) alongside a
    // global HP-recovery cut so the pool is a real, slowly-drained resource.
    final base = 100 + (level - 1) * 14 + (level * level) ~/ 5;
    final vitalityBonus = constitution; // +1% max HP per point of CON
    return ((base * (100 + extraHpPct + vitalityBonus) / 100) + flatHpBonus)
        .round().clamp(1, 1000000000000000);
  }

  // Armor class = 2 base + Strength (Power). STR is also the universal defence
  // stat: +1 armor rating per point, on top of gear/passive armour.
  int get armorClass => 2 + strength;

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
  bool get classElementUnlocked => true;

  DamageType get activeDamageType {
    final types = availableDamageTypes;
    return types[activeDamageTypeIndex.clamp(0, types.length - 1)];
  }

  List<DamageType> get availableDamageTypes {
    // Physical is no longer a hero damage type (Armor is the physical DEFENCE,
    // not an offence). Heroes deal their class element, plus the secondary once
    // Dual Mastery is unlocked.
    final ce = heroClass.info.classElement;
    final se = heroClass.info.secondaryElement;
    final types = [ce];
    if (dualMasteryUnlocked && se != ce && !types.contains(se)) types.add(se);
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


  // XP required to advance FROM [level] to level+1. QUADRATIC curve: the old
  // linear curve (50 + 45·level) was too shallow versus the (uncapped) per-fight
  // XP, so high levels came ~40 at a time. Level 1000 is meant to be a ~6-month
  // grind at ~30 min/day, so the cost per level ramps hard with level. The kXpQuad
  // coefficient is the master pacing knob — calibrated from telemetry
  // (levels-per-fight) toward Level 1000 ≈ 180 days. Existing saves keep their
  // level; only the next-level threshold changes. (Dart int is 64-bit — at L1000
  // this is ~2M, no overflow.)
  // Calibrated from telemetry: at kXpQuad 2.0 the pace held ~2.7 fights/level in
  // natural tier-0 play (L18–40), extrapolating to ~3.4 months to L1000 at ~26
  // fights/day — too fast. Raised ×1.75 → 3.5 to target ~6 months (tier-up XP
  // boosts still nudge it faster, so this may need another small bump).
  static const double kXpQuad = 3.5; // per-level² XP cost — the 6-month pacing knob
  static int expToNextForLevel(int level) =>
      (50 + 45 * level + kXpQuad * level * level).round();

  void levelUp() {
    level += 1;
    experienceToNextLevel = expToNextForLevel(level);
    // Automatic stat growth removed — a level-up now grants ONLY a Paragon Point
    // (see GameState._syncParagonLevels) plus energy. Stats come from gear,
    // Paragon and passives instead. (The old +1%/level damage bonus and the
    // full-heal on level-up were removed; per-level HP was halved — see
    // maxHealth.)
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
    levelBonusDamagePct    = 0; // retired — existing characters lose the old free bonus
    activeDamageTypeIndex  = (json['activeDamageTypeIndex']  as int?)  ?? 0;
    dualMasteryUnlocked    = (json['dualMasteryUnlocked']    as bool?) ?? false;
    currentHealth = (json['currentHealth'] as int?) ?? maxHealth;
  }
}
