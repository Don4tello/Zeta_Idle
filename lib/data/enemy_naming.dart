import '../models/zone_affix.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EnemyNamingEngine
//
// Assembles a dynamic enemy name following the formula:
//   [Prefix: Element/Mutator]  +  [Noun: Base Creature]  +  [Suffix: Power Tier]
//
// Prefix  — derived from the creature's active zone affix so the player can
//           read the enemy's mechanical modifier at a glance.
// Noun    — one of 25 base creature archetypes.
// Suffix  — derived from abyss depth, communicating combat role and threat.
//
// Campaign stages (0–24) receive no suffix and no affix-driven prefix.
// Abyss stages (25+) receive the full treatment.
// ─────────────────────────────────────────────────────────────────────────────

/// Number of hand-crafted campaign enemies.  Abyss begins at this stage index.
const kCampaignLength = 100;

enum CreatureTier {
  minion,      // T1 — depth   0–24   (no suffix)
  squadLeader, // T2 — depth  25–49   Vanguard / Sentry
  elite,       // T3 — depth  50–74   Warmonger / Reaver
  caster,      // T4 — depth  75–99   Magus / Hierophant
  miniBoss,    // T5 — depth 100–149  Archon / Overlord
  worldBoss,   // T6 — depth 150+     Paragon / Avatar
}

class EnemyNamingEngine {
  // ── Suffix tables (two variants per tier for variety) ──────────────────────

  static const _suffixes = <CreatureTier, List<String>>{
    CreatureTier.minion:      [''],
    CreatureTier.squadLeader: ['Vanguard',   'Sentry'],
    CreatureTier.elite:       ['Warmonger',  'Reaver'],
    CreatureTier.caster:      ['Magus',      'Hierophant'],
    CreatureTier.miniBoss:    ['Archon',     'Overlord'],
    CreatureTier.worldBoss:   ['Paragon',    'Avatar'],
  };

  // ── Prefix tables by element (three variants each) ─────────────────────────

  static const _firePrefixes      = ['Smoldering', 'Infernal',  'Pyro'];
  static const _icePrefixes       = ['Hoarfrost',  'Glacial',   'Cryo'];
  static const _lightningPrefixes = ['Galvanic',   'Crackling', 'Fulgurite'];
  static const _poisonPrefixes    = ['Blighted',   'Toxic',     'Virulent'];
  static const _voidPrefixes      = ['Astral',     'Eldritch',  'Abyssal'];
  static const _bloodPrefixes     = ['Sanguine',   'Crimson',   'Blighted'];

  // ── Affix → element mapping ────────────────────────────────────────────────

  static List<String> _prefixPool(ZoneAffix affix) {
    switch (affix) {
      case ZoneAffix.volatileDeath:                      return _firePrefixes;
      case ZoneAffix.ironSkin:
      case ZoneAffix.diamondHide:                        return _icePrefixes;
      case ZoneAffix.timeFracture:                       return _lightningPrefixes;
      case ZoneAffix.cursedGround:
      case ZoneAffix.deathSpiral:                        return _poisonPrefixes;
      case ZoneAffix.shadowCloak:
      case ZoneAffix.voidCurse:
      case ZoneAffix.abyssalRoar:                        return _voidPrefixes;
      case ZoneAffix.soulSiphon:
      case ZoneAffix.lifeleechAura:                      return _bloodPrefixes;
    }
  }

  // ── Tier derivation ────────────────────────────────────────────────────────

  static CreatureTier tierFor(int abyssDepth) {
    if (abyssDepth <  25) return CreatureTier.minion;
    if (abyssDepth <  50) return CreatureTier.squadLeader;
    if (abyssDepth <  75) return CreatureTier.elite;
    if (abyssDepth < 100) return CreatureTier.caster;
    if (abyssDepth < 150) return CreatureTier.miniBoss;
    return CreatureTier.worldBoss;
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Build a full enemy name for an abyss enemy.
  ///
  /// [baseName]      — the creature's base noun, e.g. "Skeleton"
  /// [abyssDepth]    — stages beyond the campaign (stage − kCampaignLength + 1)
  /// [affixes]       — active zone affixes; first match wins for the prefix
  /// [variantSeed]   — any stable int that differs per creature type (e.g.
  ///                   type index) to distribute Vanguard vs Sentry choices
  static String buildName({
    required String baseName,
    required int abyssDepth,
    required List<ZoneAffix> affixes,
    required int variantSeed,
  }) {
    final tier   = tierFor(abyssDepth);
    final suffix = _resolveSuffix(tier, variantSeed);
    final prefix = _resolvePrefix(affixes, tier, variantSeed);

    if (prefix.isEmpty && suffix.isEmpty) return baseName;
    if (prefix.isEmpty) return '$baseName $suffix';
    if (suffix.isEmpty) return '$prefix $baseName';
    return '$prefix $baseName $suffix';
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  static String _resolveSuffix(CreatureTier tier, int seed) {
    final opts = _suffixes[tier]!;
    if (opts.length == 1) return opts[0]; // handles the empty minion suffix
    return opts[seed % opts.length];
  }

  static String _resolvePrefix(
      List<ZoneAffix> affixes, CreatureTier tier, int seed) {
    // World-boss tier always carries a void prefix for max menace
    if (tier == CreatureTier.worldBoss) {
      return _voidPrefixes[seed % _voidPrefixes.length];
    }
    // First active affix wins; pick a variant based on seed for variety
    for (final affix in affixes) {
      final pool = _prefixPool(affix);
      return pool[seed % pool.length];
    }
    return '';
  }
}
