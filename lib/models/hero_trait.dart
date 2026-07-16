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
    // Generalist: solid XP + gold with no tradeoff — the safe starter.
    HeroTrait(
      id: TraitId.humanAdaptable,
      heroRace: HeroRace.human,
      icon: '🌐',
      name: 'Indomitable Will',
      description: 'Human ambition drives both growth and fortune. '
          '+5% XP and +5% gold per kill.',
      xpPct: 5,
      goldPct: 5,
    ),

    // ── Elf ────────────────────────────────────────────────────────────────
    // Scholar: fastest levelling in the game; shards from ancient perception.
    HeroTrait(
      id: TraitId.elfFeyAncestry,
      heroRace: HeroRace.elf,
      icon: '🌿',
      name: 'Fey Sight',
      description: 'Ancient wisdom accelerates mastery above all else. '
          '+10% XP per kill and +5% shard drops.',
      xpPct: 10,
      shardPct: 5,
    ),

    // ── Dwarf ──────────────────────────────────────────────────────────────
    // Tank: highest HP of any race, but dwarves hoard poorly.
    HeroTrait(
      id: TraitId.dwarfResilience,
      heroRace: HeroRace.dwarf,
      icon: '🪨',
      name: 'Ironblood',
      description: 'Stone-hard endurance, but wealth is never a priority. '
          '+15% max HP. −3% gold per kill.',
      hpPct: 15,
      goldPct: -3,
    ),

    // ── Halfling ───────────────────────────────────────────────────────────
    // Merchant: best gold income in the game; fortune also finds shards.
    HeroTrait(
      id: TraitId.halflingLucky,
      heroRace: HeroRace.halfling,
      icon: '🍀',
      name: "Fortune's Favor",
      description: 'Luck turns every kill into a payday. '
          '+10% gold and +5% shard drops per kill.',
      goldPct: 10,
      shardPct: 5,
    ),

    // ── Gnome ──────────────────────────────────────────────────────────────
    // Utility specialist: no combat edge but unmatched resource gains.
    HeroTrait(
      id: TraitId.gnomeCunning,
      heroRace: HeroRace.gnome,
      icon: '⚙',
      name: 'Eureka',
      description: 'Tinkering genius converts every encounter into resources. '
          '+7% XP, +5% gold, and +3% shard drops per kill.',
      xpPct: 7,
      goldPct: 5,
      shardPct: 3,
    ),

    // ── Half-Elf ───────────────────────────────────────────────────────────
    // True generalist: small bonuses across every stat, including survivability.
    HeroTrait(
      id: TraitId.halfElfHeritage,
      heroRace: HeroRace.halfElf,
      icon: '🌙',
      name: 'Dual Heritage',
      description: 'Two bloodlines gift a little of everything. '
          '+3% XP, +3% gold, +3% shards, and +3% max HP.',
      xpPct: 3,
      goldPct: 3,
      shardPct: 3,
      hpPct: 3,
    ),

    // ── Half-Orc ───────────────────────────────────────────────────────────
    // Glass cannon: highest raw damage — but you die much faster.
    HeroTrait(
      id: TraitId.halfOrcRelentless,
      heroRace: HeroRace.halfOrc,
      icon: '💀',
      name: 'Savage Endurance',
      description: 'Orcish fury hits hardest — but leaves you exposed. '
          '+10% damage dealt. −8% max HP.',
      dmgPct: 10,
      hpPct: -8,
    ),

    // ── Tiefling ───────────────────────────────────────────────────────────
    // Combat-survival hybrid: strong damage with some durability, but growth is stunted.
    HeroTrait(
      id: TraitId.tieflingResistance,
      heroRace: HeroRace.tiefling,
      icon: '🔥',
      name: 'Hellfire Pact',
      description: 'Infernal power grants combat edge but stunts growth. '
          '+7% damage, +4% max HP. −5% XP per kill.',
      dmgPct: 7,
      hpPct: 4,
      xpPct: -5,
    ),

    // ── Dragonborn ─────────────────────────────────────────────────────────
    // Durable warrior: damage + survivability, at the cost of wealth.
    HeroTrait(
      id: TraitId.dragonbornFury,
      heroRace: HeroRace.dragonborn,
      icon: '🐉',
      name: 'Draconic Legacy',
      description: 'Ancient draconic blood favours power over profit. '
          '+5% damage, +8% max HP. −4% gold per kill.',
      dmgPct: 5,
      hpPct: 8,
      goldPct: -4,
    ),

    // ── Aasimar ────────────────────────────────────────────────────────────
    // Divine balance: HP + XP + gold — no combat spike, but flourishes on all fronts.
    HeroTrait(
      id: TraitId.aasimarCelestial,
      heroRace: HeroRace.aasimar,
      icon: '✨',
      name: 'Celestial Grace',
      description: 'Divine blessing nurtures body, soul, and fortune equally. '
          '+5% max HP, +5% XP, and +3% gold per kill.',
      hpPct: 5,
      xpPct: 5,
      goldPct: 3,
    ),
  ];
}
