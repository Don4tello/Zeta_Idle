import 'hero_race.dart';

enum TraitId {
  // Human
  humanAdaptable, humanTenacious,
  // Elf
  elfFeyAncestry, elfKeenSenses,
  // Dwarf
  dwarfResilience, dwarfStonecunning,
  // Halfling
  halflingLucky, halflingBrave,
  // Gnome
  gnomeCunning, gnomeTinkerer,
  // Half-Elf
  halfElfHeritage, halfElfCharismatic,
  // Half-Orc
  halfOrcRelentless, halfOrcSavage,
  // Tiefling
  tieflingResistance, tieflingInfernal,
  // Dragonborn
  dragonbornFury, dragonbornScales,
  // Aasimar
  aasimarCelestial, aasimarDivine,
}

class HeroTrait {
  const HeroTrait({
    required this.id,
    required this.heroRace,
    required this.name,
    required this.description,
    required this.icon,
    this.dmgPct = 0,
    this.hpPct = 0,
    this.cooldownReduction = 0,
    this.shardPct = 0,
    this.xpPct = 0,
    this.goldPct = 0,
    this.critImmune = false,
  });

  final TraitId id;
  final HeroRace heroRace;
  final String name;
  final String description;
  final String icon;
  final int dmgPct;
  final int hpPct;
  final int cooldownReduction;
  final int shardPct;
  final int xpPct;
  final int goldPct;
  final bool critImmune;

  static List<HeroTrait> forRace(HeroRace race) =>
      all.where((t) => t.heroRace == race).toList();

  static const all = <HeroTrait>[
    // ── Human ─────────────────────────────────────────────────────────────
    // Versatile: +1 to all stats → translated as small bonuses to XP and gold
    HeroTrait(
      id: TraitId.humanAdaptable,
      heroRace: HeroRace.human,
      icon: '🌐',
      name: 'Adaptable',
      description: '+5% XP per kill. +5% gold per kill.',
      xpPct: 5,
      goldPct: 5,
    ),
    // Feat at level 1 → extra tenacity; humans push through anything
    HeroTrait(
      id: TraitId.humanTenacious,
      heroRace: HeroRace.human,
      icon: '💪',
      name: 'Tenacious',
      description: '+8% max HP. +5% shard drops.',
      hpPct: 8,
      shardPct: 5,
    ),
    // ── Elf ───────────────────────────────────────────────────────────────
    // Fey Ancestry: advantage vs charm → -1 cooldown (mental clarity)
    HeroTrait(
      id: TraitId.elfFeyAncestry,
      heroRace: HeroRace.elf,
      icon: '🌿',
      name: 'Fey Ancestry',
      description: '−1 to all ability cooldowns. +5% max HP.',
      cooldownReduction: 1,
      hpPct: 5,
    ),
    // Keen Senses: proficiency in Perception → sharper learning and finds
    HeroTrait(
      id: TraitId.elfKeenSenses,
      heroRace: HeroRace.elf,
      icon: '👁',
      name: 'Keen Senses',
      description: '+8% XP per kill. +5% shard drops.',
      xpPct: 8,
      shardPct: 5,
    ),
    // ── Dwarf ─────────────────────────────────────────────────────────────
    // Dwarven Resilience: advantage on poison saves, extra HP → bulky survivability
    HeroTrait(
      id: TraitId.dwarfResilience,
      heroRace: HeroRace.dwarf,
      icon: '🪨',
      name: 'Dwarven Resilience',
      description: '+10% max HP. +5% shard drops.',
      hpPct: 10,
      shardPct: 5,
    ),
    // Stonecunning: doubling proficiency for history on stone → treasure sense
    HeroTrait(
      id: TraitId.dwarfStonecunning,
      heroRace: HeroRace.dwarf,
      icon: '⚒',
      name: 'Stonecunning',
      description: '+5% gold per kill. +8% shard drops.',
      goldPct: 5,
      shardPct: 8,
    ),
    // ── Halfling ──────────────────────────────────────────────────────────
    // Lucky: reroll nat 1s → fortune on gold and shards
    HeroTrait(
      id: TraitId.halflingLucky,
      heroRace: HeroRace.halfling,
      icon: '🍀',
      name: 'Lucky',
      description: '+5% gold per kill. +8% shard drops.',
      goldPct: 5,
      shardPct: 8,
    ),
    // Brave: advantage vs frightened → HP and growth through courage
    HeroTrait(
      id: TraitId.halflingBrave,
      heroRace: HeroRace.halfling,
      icon: '🛡',
      name: 'Brave',
      description: '+8% max HP. +5% XP per kill.',
      hpPct: 8,
      xpPct: 5,
    ),
    // ── Gnome ─────────────────────────────────────────────────────────────
    // Gnome Cunning: advantage on Int/Wis/Cha saves vs magic → quick ability use
    HeroTrait(
      id: TraitId.gnomeCunning,
      heroRace: HeroRace.gnome,
      icon: '🧠',
      name: 'Gnome Cunning',
      description: '−1 to all ability cooldowns. +5% XP per kill.',
      cooldownReduction: 1,
      xpPct: 5,
    ),
    // Tinker: craft tiny devices → find and collect more resources
    HeroTrait(
      id: TraitId.gnomeTinkerer,
      heroRace: HeroRace.gnome,
      icon: '⚙',
      name: 'Tinkerer',
      description: '+5% gold per kill. +8% shard drops.',
      goldPct: 5,
      shardPct: 8,
    ),
    // ── Half-Elf ──────────────────────────────────────────────────────────
    // Skill Versatility + Fey blood → fast cooldowns and quick learning
    HeroTrait(
      id: TraitId.halfElfHeritage,
      heroRace: HeroRace.halfElf,
      icon: '🌙',
      name: 'Elven Heritage',
      description: '−1 to all ability cooldowns. +5% XP per kill.',
      cooldownReduction: 1,
      xpPct: 5,
    ),
    // +2 CHA → charm, wealth, personality
    HeroTrait(
      id: TraitId.halfElfCharismatic,
      heroRace: HeroRace.halfElf,
      icon: '🎭',
      name: 'Silver Tongue',
      description: '+8% gold per kill. +5% max HP.',
      goldPct: 8,
      hpPct: 5,
    ),
    // ── Half-Orc ──────────────────────────────────────────────────────────
    // Relentless Endurance: drop to 1 instead of 0 once/rest → big HP buffer
    HeroTrait(
      id: TraitId.halfOrcRelentless,
      heroRace: HeroRace.halfOrc,
      icon: '🩸',
      name: 'Relentless Endurance',
      description: '+10% max HP. +5% shard drops.',
      hpPct: 10,
      shardPct: 5,
    ),
    // Savage Attacks: extra die on crit → raw damage at the cost of fragility
    HeroTrait(
      id: TraitId.halfOrcSavage,
      heroRace: HeroRace.halfOrc,
      icon: '⚔',
      name: 'Savage Attacks',
      description: '+10% damage dealt. −8% max HP.',
      dmgPct: 10,
      hpPct: -8,
    ),
    // ── Tiefling ──────────────────────────────────────────────────────────
    // Hellish Resistance: fire resistance → general damage soak
    HeroTrait(
      id: TraitId.tieflingResistance,
      heroRace: HeroRace.tiefling,
      icon: '🛡',
      name: 'Hellish Resistance',
      description: '+8% max HP. +5% shard drops.',
      hpPct: 8,
      shardPct: 5,
    ),
    // Infernal Legacy: bonus spells from fiendish blood → raw destructive power
    HeroTrait(
      id: TraitId.tieflingInfernal,
      heroRace: HeroRace.tiefling,
      icon: '🔥',
      name: 'Infernal Legacy',
      description: '+10% damage dealt. −5% max HP.',
      dmgPct: 10,
      hpPct: -5,
    ),
    // ── Dragonborn ────────────────────────────────────────────────────────
    // Breath Weapon → raw burst damage
    HeroTrait(
      id: TraitId.dragonbornFury,
      heroRace: HeroRace.dragonborn,
      icon: '🐉',
      name: 'Draconic Fury',
      description: '+10% damage dealt. −5% max HP.',
      dmgPct: 10,
      hpPct: -5,
    ),
    // Damage Resistance (draconic ancestry) → natural armor
    HeroTrait(
      id: TraitId.dragonbornScales,
      heroRace: HeroRace.dragonborn,
      icon: '🪬',
      name: 'Scales of the Wyrm',
      description: '+8% max HP. +5% shard drops.',
      hpPct: 8,
      shardPct: 5,
    ),
    // ── Aasimar ───────────────────────────────────────────────────────────
    // Celestial Resistance: necrotic/radiant resistance → durability + growth
    HeroTrait(
      id: TraitId.aasimarCelestial,
      heroRace: HeroRace.aasimar,
      icon: '✨',
      name: 'Celestial Resistance',
      description: '+8% max HP. +5% XP per kill.',
      hpPct: 8,
      xpPct: 5,
    ),
    // Healing Hands + Radiant Soul → blessed fortune on kills
    HeroTrait(
      id: TraitId.aasimarDivine,
      heroRace: HeroRace.aasimar,
      icon: '☀',
      name: 'Divine Strike',
      description: '+8% damage dealt. +5% gold per kill.',
      dmgPct: 8,
      goldPct: 5,
    ),
  ];
}
