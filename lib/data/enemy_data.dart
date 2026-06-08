import 'dart:math';
import '../models/enemy.dart';
import '../models/zone_affix.dart';
import 'enemy_naming.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EnemyData
//
// 25 hand-crafted base creatures covering five archetypes:
//   Undead · Gremlins & Humanoids · Beasts & Constructs
//   Demonic & Aberrant · Elemental & Mythical
//
// Stages 0–24 are the fixed campaign, each featuring one creature.
// Stage 25+ is the infinite Abyss: creatures cycle, stats scale exponentially,
// and the EnemyNamingEngine generates the full Prefix + Noun + Suffix name.
// ─────────────────────────────────────────────────────────────────────────────

class EnemyData {
  // ── 25 base creatures (campaign order = rough difficulty ascent) ──────────

  // HP values for early-game enemies (stages 0–9) are 2–2.5× higher than before
  // so that first fights last ~10–20 rounds and upgrades feel impactful.
  // Mid/late campaign enemies are unchanged.
  static final enemies = <Enemy>[
    // ── Undead ──────────────────────────────────────────────────────────────
    Enemy(id: 'skeleton',  name: 'Skeleton',  level: 1,  maxHealth: 45,  attack: 4,  armorClass: 10,
        description: 'Risen from ancient battlefields, this hollow warrior fights on through dark sorcery.'),
    Enemy(id: 'ghoul',     name: 'Ghoul',     level: 3,  maxHealth: 90,  attack: 10, armorClass: 11,
        description: 'A ravenous undead predator fuelled by insatiable hunger.'),
    Enemy(id: 'banshee',   name: 'Banshee',   level: 6,  maxHealth: 120, attack: 21, armorClass: 12,
        description: 'A wailing spirit whose scream can shatter bone and courage alike.'),
    Enemy(id: 'mummy',     name: 'Mummy',     level: 8,  maxHealth: 200, attack: 18, armorClass: 16,
        description: 'An ancient cursed pharaoh wrapped in rotten bandages and fell power.'),
    Enemy(id: 'lich',      name: 'Lich',      level: 12, maxHealth: 280, attack: 42, armorClass: 14,
        description: 'An immortal sorcerer-king whose death is merely an inconvenience.'),

    // ── Gremlins & Humanoids ─────────────────────────────────────────────────
    Enemy(id: 'goblin',    name: 'Goblin',    level: 1,  maxHealth: 55,  attack: 5,  armorClass: 10,
        description: 'A scrawny, cunning creature drawn to chaos and the scent of gold.'),
    Enemy(id: 'kobold',    name: 'Kobold',    level: 2,  maxHealth: 70,  attack: 7,  armorClass: 11,
        description: 'A tunnel-dwelling lizardkin that compensates for its frailty with cunning traps.'),
    Enemy(id: 'gnoll',     name: 'Gnoll',     level: 4,  maxHealth: 110, attack: 12, armorClass: 12,
        description: 'A hyena-headed savage whose war-bark drives allies into a frenzy.'),
    Enemy(id: 'hobgoblin', name: 'Hobgoblin', level: 5,  maxHealth: 130, attack: 14, armorClass: 14,
        description: 'A disciplined soldier of the dark legions, armoured and battle-tested.'),
    Enemy(id: 'orc',       name: 'Orc',       level: 6,  maxHealth: 160, attack: 17, armorClass: 13,
        description: 'A rampaging brute whose fury grows with every blow landed.'),

    // ── Beasts & Constructs ──────────────────────────────────────────────────
    Enemy(id: 'harpy',     name: 'Harpy',     level: 4,  maxHealth: 95,  attack: 14, armorClass: 11,
        description: 'A winged terror that dives from above with murderous precision.'),
    Enemy(id: 'gargoyle',  name: 'Gargoyle',  level: 7,  maxHealth: 180, attack: 18, armorClass: 17,
        description: 'A stone sentinel awakened, its hide impervious to all but the sharpest blades.'),
    Enemy(id: 'basilisk',  name: 'Basilisk',  level: 7,  maxHealth: 210, attack: 20, armorClass: 15,
        description: 'One glance from its eight eyes is said to turn the bravest soul to stone.'),
    Enemy(id: 'golem',     name: 'Golem',     level: 9,  maxHealth: 280, attack: 20, armorClass: 19,
        description: 'A colossus of enchanted stone, patient and nigh unstoppable.'),
    Enemy(id: 'chimera',   name: 'Chimera',   level: 11, maxHealth: 320, attack: 36, armorClass: 15,
        description: 'A three-headed nightmare fusing lion, goat, and serpent into one horror.'),

    // ── Demonic & Aberrant ───────────────────────────────────────────────────
    Enemy(id: 'imp',             name: 'Imp',             level: 2,  maxHealth: 50,  attack: 7,  armorClass: 11,
        description: 'A minor fiend of mischief whose claws carry a sting beyond their size.'),
    Enemy(id: 'cultist',         name: 'Cultist',         level: 5,  maxHealth: 80,  attack: 16, armorClass: 11,
        description: 'A zealot who channels forbidden energies with glass-cannon ferocity.'),
    Enemy(id: 'succubus',        name: 'Succubus',        level: 9,  maxHealth: 195, attack: 28, armorClass: 13,
        description: 'A demonic seductress who drains life as easily as she takes it.'),
    Enemy(id: 'eyeball_watcher', name: 'Eyeball Watcher', level: 10, maxHealth: 220, attack: 32, armorClass: 13,
        description: 'A floating mass of eyes that fires eldritch beams in every direction.'),
    Enemy(id: 'mind_flayer',     name: 'Mind-Flayer',     level: 11, maxHealth: 260, attack: 35, armorClass: 15,
        description: 'A psionic predator that strips the mind bare before consuming it.'),

    // ── Elemental & Mythical ─────────────────────────────────────────────────
    Enemy(id: 'pixie',    name: 'Pixie',    level: 3,  maxHealth: 55,  attack: 9,  armorClass: 14,
        description: 'A deceptive forest spirit whose beauty belies its vicious bite.'),
    Enemy(id: 'wyvern',   name: 'Wyvern',   level: 8,  maxHealth: 240, attack: 22, armorClass: 15,
        description: 'A two-legged dragon whose barbed tail delivers devastating poison.'),
    Enemy(id: 'hydra',    name: 'Hydra',    level: 12, maxHealth: 460, attack: 38, armorClass: 16,
        description: 'Cut off one head and two grow back — only fire can stop the tide.'),
    Enemy(id: 'minotaur', name: 'Minotaur', level: 10, maxHealth: 300, attack: 27, armorClass: 14,
        description: 'A bull-headed labyrinth guardian that levels everything in its charge.'),
    Enemy(id: 'phoenix',  name: 'Phoenix',  level: 13, maxHealth: 430, attack: 42, armorClass: 15,
        description: 'The undying flame given form; its death is only the beginning.'),
  ];

  // ── Sorted campaign order (0–24 by difficulty) ───────────────────────────
  // Ordered to form a smooth difficulty ramp across 25 stages.
  static final _campaignOrder = <String>[
    'skeleton',        // Stage  0  — HP 18  ATK  4
    'goblin',          // Stage  1  — HP 22  ATK  5
    'imp',             // Stage  2  — HP 20  ATK  7
    'kobold',          // Stage  3  — HP 28  ATK  7
    'pixie',           // Stage  4  — HP 22  ATK  9   AC 14
    'ghoul',           // Stage  5  — HP 38  ATK 10
    'gnoll',           // Stage  6  — HP 45  ATK 12
    'harpy',           // Stage  7  — HP 38  ATK 14
    'cultist',         // Stage  8  — HP 32  ATK 16
    'hobgoblin',       // Stage  9  — HP 55  ATK 14  AC 14
    'orc',             // Stage 10  — HP 68  ATK 17
    'banshee',         // Stage 11  — HP 48  ATK 21
    'gargoyle',        // Stage 12  — HP 75  ATK 18  AC 17
    'basilisk',        // Stage 13  — HP 88  ATK 20
    'mummy',           // Stage 14  — HP100  ATK 18  AC 16
    'wyvern',          // Stage 15  — HP105  ATK 22
    'golem',           // Stage 16  — HP125  ATK 20  AC 19
    'succubus',        // Stage 17  — HP 85  ATK 28
    'minotaur',        // Stage 18  — HP135  ATK 27
    'eyeball_watcher', // Stage 19  — HP 95  ATK 32
    'mind_flayer',     // Stage 20  — HP115  ATK 35
    'chimera',         // Stage 21  — HP145  ATK 36
    'lich',            // Stage 22  — HP155  ATK 42
    'hydra',           // Stage 23  — HP210  ATK 38
    'phoenix',         // Stage 24  — HP230  ATK 50
  ];

  // ── Lookup helpers ────────────────────────────────────────────────────────

  static Enemy _byId(String id) => enemies.firstWhere((e) => e.id == id);

  // ── enemyForStage ─────────────────────────────────────────────────────────

  /// Returns a fully-configured Enemy for [stage].
  ///
  /// Stages 0–24: hand-crafted campaign, no prefix/suffix, exact base stats.
  /// Stages 25+:  abyss — cycling creature skins, exponential stat growth,
  ///              full EnemyNamingEngine name.
  static Enemy enemyForStage(
    int stage, {
    List<ZoneAffix> affixes = const [],
  }) {
    if (stage < kCampaignLength) {
      return _byId(_campaignOrder[stage]);
    }

    // ── Abyss ────────────────────────────────────────────────────────────────
    final a          = stage - (kCampaignLength - 1); // depth, ≥ 1
    final typeIndex  = stage % kCampaignLength;
    final base       = _byId(_campaignOrder[typeIndex]);

    // HP: exponential up to depth 100, then linear soft-cap
    final double growth = a <= 100
        ? pow(1.06, a).toDouble()
        : pow(1.06, 100).toDouble() * (1.0 + (a - 100) * 0.02);

    // Anchor scaling to Phoenix (the strongest hand-crafted creature)
    const baseHP  = 195;
    const baseAtk = 42;
    const baseAC  = 15;
    const baseLvl = 13;

    final hp      = (baseHP  * growth)       .round().clamp(baseHP,  9999999);
    final atk     = (baseAtk * sqrt(growth)) .round().clamp(baseAtk, 9999);
    final acBonus = min((log(a + 1) / log(2) * 1.5).floor(), 12);
    final level   = baseLvl + a ~/ 5;

    final name = EnemyNamingEngine.buildName(
      baseName:    base.name,
      abyssDepth:  a,
      affixes:     affixes,
      variantSeed: typeIndex,
    );

    return Enemy(
      id:          base.id,
      name:        name,
      description: base.description,
      maxHealth:   hp,
      attack:      atk,
      level:       level,
      armorClass:  baseAC + acBonus,
    );
  }
}
