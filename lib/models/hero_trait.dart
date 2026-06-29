import 'hero_race.dart';

// Only one trait per race is defined — it is automatically applied when
// the player picks their race. TraitId values are kept for save compatibility.
enum TraitId {
  humanAdaptable,   humanTenacious,
  elfFeyAncestry,   elfKeenSenses,
  dwarfResilience,  dwarfStonecunning,
  halflingLucky,    halflingBrave,
  gnomeCunning,     gnomeTinkerer,
  halfElfHeritage,  halfElfCharismatic,
  halfOrcRelentless, halfOrcSavage,
  tieflingResistance, tieflingInfernal,
  dragonbornFury,   dragonbornScales,
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

  // Short chip labels for display in the race picker (e.g. "+5% XP").
  List<String> get bonusChips {
    final chips = <String>[];
    String s(int v) => v >= 0 ? '+$v%' : '$v%';
    if (xpPct    != 0) chips.add('${s(xpPct)} XP');
    if (goldPct  != 0) chips.add('${s(goldPct)} Gold');
    if (shardPct != 0) chips.add('${s(shardPct)} ◆');
    if (hpPct    != 0) chips.add('${s(hpPct)} HP');
    if (dmgPct   != 0) chips.add('${s(dmgPct)} DMG');
    return chips;
  }

  static const all = <HeroTrait>[
    // ── Human ──────────────────────────────────────────────────────────────
    // Humans excel through ambition — steady gains across the board.
    HeroTrait(
      id: TraitId.humanAdaptable,
      heroRace: HeroRace.human,
      icon: '🌐',
      name: 'Indomitable Will',
      description: 'Human ambition drives both growth and fortune. '
          '+3% XP and +3% gold per kill.',
      xpPct: 3,
      goldPct: 3,
    ),

    // ── Elf ────────────────────────────────────────────────────────────────
    // Ancient perception — elves notice what others overlook.
    HeroTrait(
      id: TraitId.elfFeyAncestry,
      heroRace: HeroRace.elf,
      icon: '🌿',
      name: 'Fey Sight',
      description: 'Ancient perception uncovers hidden value. '
          '+5% shard drops and +3% XP per kill.',
      shardPct: 5,
      xpPct: 3,
    ),

    // ── Dwarf ──────────────────────────────────────────────────────────────
    // Stubborn endurance — dwarves outlast everything, but wealth is secondary.
    HeroTrait(
      id: TraitId.dwarfResilience,
      heroRace: HeroRace.dwarf,
      icon: '🪨',
      name: 'Ironblood',
      description: 'Stone-hard endurance, but wealth holds little appeal. '
          '+8% max HP. −2% gold per kill.',
      hpPct: 8,
      goldPct: -2,
    ),

    // ── Halfling ───────────────────────────────────────────────────────────
    // Pure fortune — halflings find coins where others find dirt.
    HeroTrait(
      id: TraitId.halflingLucky,
      heroRace: HeroRace.halfling,
      icon: '🍀',
      name: "Fortune's Favor",
      description: 'Luck manifests as found treasure and rare finds. '
          '+5% gold and +3% shard drops per kill.',
      goldPct: 5,
      shardPct: 3,
    ),

    // ── Gnome ──────────────────────────────────────────────────────────────
    // Insatiable curiosity translates directly into mastery.
    HeroTrait(
      id: TraitId.gnomeCunning,
      heroRace: HeroRace.gnome,
      icon: '⚙',
      name: 'Eureka',
      description: 'Every encounter is a lesson waiting to be learned. '
          '+5% XP and +3% gold per kill.',
      xpPct: 5,
      goldPct: 3,
    ),

    // ── Half-Elf ───────────────────────────────────────────────────────────
    // Two bloodlines — neither dominant, but gifted by both.
    HeroTrait(
      id: TraitId.halfElfHeritage,
      heroRace: HeroRace.halfElf,
      icon: '🌙',
      name: 'Dual Heritage',
      description: 'The best of two worlds, spread across all gains. '
          '+3% XP, +3% gold, and +3% shard drops per kill.',
      xpPct: 3,
      goldPct: 3,
      shardPct: 3,
    ),

    // ── Half-Orc ───────────────────────────────────────────────────────────
    // Pure aggression — devastating output at the cost of survivability.
    HeroTrait(
      id: TraitId.halfOrcRelentless,
      heroRace: HeroRace.halfOrc,
      icon: '💀',
      name: 'Savage Endurance',
      description: 'Raw orcish fury hits hard but leaves you exposed. '
          '+6% damage dealt. −5% max HP.',
      dmgPct: 6,
      hpPct: -5,
    ),

    // ── Tiefling ───────────────────────────────────────────────────────────
    // An infernal bargain — power flows freely, but fate takes its cut.
    HeroTrait(
      id: TraitId.tieflingResistance,
      heroRace: HeroRace.tiefling,
      icon: '🔥',
      name: 'Hellfire Pact',
      description: 'Infernal power comes at a price. '
          '+5% damage dealt. −2% shard drops.',
      dmgPct: 5,
      shardPct: -2,
    ),

    // ── Dragonborn ─────────────────────────────────────────────────────────
    // Ancient draconic blood — balanced power between might and endurance.
    HeroTrait(
      id: TraitId.dragonbornFury,
      heroRace: HeroRace.dragonborn,
      icon: '🐉',
      name: 'Draconic Legacy',
      description: 'Ancient draconic blood fuels raw power above all else. '
          '+5% damage dealt and +2% max HP.',
      dmgPct: 5,
      hpPct: 2,
    ),

    // ── Aasimar ────────────────────────────────────────────────────────────
    // Celestial grace — touched by the divine, grows swiftly.
    HeroTrait(
      id: TraitId.aasimarCelestial,
      heroRace: HeroRace.aasimar,
      icon: '✨',
      name: 'Celestial Grace',
      description: 'Divine blessing nurtures both body and soul. '
          '+4% max HP and +4% XP per kill.',
      hpPct: 4,
      xpPct: 4,
    ),
  ];
}
