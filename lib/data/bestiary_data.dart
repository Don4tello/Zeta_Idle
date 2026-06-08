import '../models/bestiary_entry.dart';

// One entry per campaign enemy (ids must match EnemyData enemy ids)
const kBestiaryEntries = <BestiaryEntry>[
  // ── Undead ──────────────────────────────────────────────────────────────────
  BestiaryEntry(
    enemyId:    'skeleton',
    name:       'Skeleton',
    flavorText: 'Ancient bones held together by dark will. Crumbles under holy light.',
    weakness:   BestiaryWeakness.undead,
    category:   'Undead',
  ),
  BestiaryEntry(
    enemyId:    'ghoul',
    name:       'Ghoul',
    flavorText: 'A corrupted soul that feeds on the living. Paralysis touch feared by all.',
    weakness:   BestiaryWeakness.undead,
    category:   'Undead',
  ),
  BestiaryEntry(
    enemyId:    'banshee',
    name:       'Banshee',
    flavorText: 'Its wail freezes the blood. Born from grief — only light silences it.',
    weakness:   BestiaryWeakness.undead,
    category:   'Undead',
  ),
  BestiaryEntry(
    enemyId:    'mummy',
    name:       'Mummy',
    flavorText: 'Cursed pharaoh wrapped in decay. Sacred fire dissolves its bindings.',
    weakness:   BestiaryWeakness.undead,
    category:   'Undead',
  ),
  BestiaryEntry(
    enemyId:    'lich',
    name:       'Lich',
    flavorText: 'Undead sorcerer clinging to existence via a phylactery. Destroy the vessel.',
    weakness:   BestiaryWeakness.undead,
    category:   'Undead',
  ),

  // ── Beast ──────────────────────────────────────────────────────────────────
  BestiaryEntry(
    enemyId:    'goblin',
    name:       'Goblin',
    flavorText: 'Cowardly in groups, dangerous in packs. Silver blades cut through the hide.',
    weakness:   BestiaryWeakness.beast,
    category:   'Beast',
  ),
  BestiaryEntry(
    enemyId:    'kobold',
    name:       'Kobold',
    flavorText: 'Cunning trappers that worship dragons. Their scales thin as parchment.',
    weakness:   BestiaryWeakness.beast,
    category:   'Beast',
  ),
  BestiaryEntry(
    enemyId:    'gnoll',
    name:       'Gnoll',
    flavorText: 'Hyena-folk who hunt in laughing packs. Their fervor breaks against cold steel.',
    weakness:   BestiaryWeakness.beast,
    category:   'Beast',
  ),
  BestiaryEntry(
    enemyId:    'wyvern',
    name:       'Wyvern',
    flavorText: 'Dragon-kin without the intelligence. A poisoned tail and feral rage.',
    weakness:   BestiaryWeakness.beast,
    category:   'Beast',
  ),
  BestiaryEntry(
    enemyId:    'chimera',
    name:       'Chimera',
    flavorText: 'Three beasts fused by dark magic. Each head hungers differently.',
    weakness:   BestiaryWeakness.beast,
    category:   'Beast',
  ),

  // ── Arcane ─────────────────────────────────────────────────────────────────
  BestiaryEntry(
    enemyId:    'imp',
    name:       'Imp',
    flavorText: 'Tiny fiends born from wayward spells. Absorbs minor magic, weak to raw force.',
    weakness:   BestiaryWeakness.arcane,
    category:   'Arcane',
  ),
  BestiaryEntry(
    enemyId:    'pixie',
    name:       'Pixie',
    flavorText: 'Fae tricksters who twist luck. Cold iron disrupts their enchantments.',
    weakness:   BestiaryWeakness.arcane,
    category:   'Arcane',
  ),
  BestiaryEntry(
    enemyId:    'banshee2',
    name:       'Eye Watcher',
    flavorText: 'A floating orb of pure magical malice. Its anti-magic cone disperses with disruption.',
    weakness:   BestiaryWeakness.arcane,
    category:   'Arcane',
  ),
  BestiaryEntry(
    enemyId:    'mind_flayer',
    name:       'Mind-Flayer',
    flavorText: 'Psionic aberration from the Far Realm. Its tentacles crave intellect.',
    weakness:   BestiaryWeakness.arcane,
    category:   'Arcane',
  ),
  BestiaryEntry(
    enemyId:    'phoenix',
    name:       'Phoenix',
    flavorText: 'Reborn from ash, it ignites the arena. Only overwhelming force prevents rebirth.',
    weakness:   BestiaryWeakness.arcane,
    category:   'Arcane',
  ),

  // ── Demonic ────────────────────────────────────────────────────────────────
  BestiaryEntry(
    enemyId:    'cultist',
    name:       'Cultist',
    flavorText: 'Human sacrificed to a dark patron. Holy symbols cause them to recoil.',
    weakness:   BestiaryWeakness.demonic,
    category:   'Demonic',
  ),
  BestiaryEntry(
    enemyId:    'harpy',
    name:       'Harpy',
    flavorText: 'Half-woman, half-vulture bound to demonic service. Silence breaks their charm.',
    weakness:   BestiaryWeakness.demonic,
    category:   'Demonic',
  ),
  BestiaryEntry(
    enemyId:    'succubus',
    name:       'Succubus',
    flavorText: 'Lust demon from the Nine Hells. Its glamour shatters before true faith.',
    weakness:   BestiaryWeakness.demonic,
    category:   'Demonic',
  ),
  BestiaryEntry(
    enemyId:    'minotaur',
    name:       'Minotaur',
    flavorText: 'Bull-headed champion of the labyrinth. Rage is its strength — and weakness.',
    weakness:   BestiaryWeakness.demonic,
    category:   'Demonic',
  ),
  BestiaryEntry(
    enemyId:    'hydra',
    name:       'Hydra',
    flavorText: 'Every severed head spawns two. Fire seals the stumps.',
    weakness:   BestiaryWeakness.demonic,
    category:   'Demonic',
  ),

  // ── Construct ──────────────────────────────────────────────────────────────
  BestiaryEntry(
    enemyId:    'hobgoblin',
    name:       'Hobgoblin',
    flavorText: 'Military-trained and disciplined. Their armor is well-made but brittle at joints.',
    weakness:   BestiaryWeakness.construct,
    category:   'Construct',
  ),
  BestiaryEntry(
    enemyId:    'gargoyle',
    name:       'Gargoyle',
    flavorText: 'Stone guardian animated by a binding rune. Break the rune, break the creature.',
    weakness:   BestiaryWeakness.construct,
    category:   'Construct',
  ),
  BestiaryEntry(
    enemyId:    'basilisk',
    name:       'Basilisk',
    flavorText: 'Its gaze petrifies. Reflective surfaces confuse its target-lock.',
    weakness:   BestiaryWeakness.construct,
    category:   'Construct',
  ),
  BestiaryEntry(
    enemyId:    'golem',
    name:       'Golem',
    flavorText: 'Clay warrior powered by a word of creation. Erase the word, halt the giant.',
    weakness:   BestiaryWeakness.construct,
    category:   'Construct',
  ),
  BestiaryEntry(
    enemyId:    'eye_watcher',
    name:       'Orc',
    flavorText: 'Tribal warrior hardened by endless battle. Straightforward — and lethal for it.',
    weakness:   BestiaryWeakness.construct,
    category:   'Construct',
  ),
];

// Lookup by enemyId
BestiaryEntry? bestiaryFor(String enemyId) {
  try {
    return kBestiaryEntries.firstWhere((e) => e.enemyId == enemyId);
  } catch (_) {
    return null;
  }
}

// Weakness bonus: 10% flat attack bonus if enemy matches weakness type
double weaknessBonusMult(String enemyId, {bool useAttack = true}) {
  final entry = bestiaryFor(enemyId);
  if (entry == null) return 1.0;
  // Only applies once the player has killed 1 of this enemy (discovery)
  return 1.10;
}
