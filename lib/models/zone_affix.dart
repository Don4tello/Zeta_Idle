import 'dart:math';

// ─────────────────────────────────────────────────────────────────────────────
// Zone Affix System
//
// Affixes are Corruption modifiers applied to each fight as the player
// descends deeper into the Abyss (stage > 12).  Count scales with depth:
//
//   abyss depth  8–37  → 1 T1 affix
//   abyss depth 38–87  → 2 T1 affixes
//   abyss depth  88+   → 2 T1 + 1 T2 (mutation) affix
// ─────────────────────────────────────────────────────────────────────────────

enum ZoneAffix {
  // ── Tier 1 ────────────────────────────────────────────────────────────────
  cursedGround,   // hero loses 5% max HP per round (min 1)
  volatileDeath,  // enemy explodes on death — ATK÷4 unavoidable damage
  ironSkin,       // all hero hit damage reduced by 2 (min 1)
  soulSiphon,     // enemy weakens hero: +3 bonus damage
  shadowCloak,    // 20% chance to negate any incoming hero hit
  voidCurse,      // all hero HP recovery halved
  abyssalRoar,    // enemy gains +3 to all attack rolls
  timeFracture,   // every 4th hero attack re-rolls (take lower)

  // ── Tier 2 (mutations) ────────────────────────────────────────────────────
  deathSpiral,    // cursedGround mutation: drain grows +1% every 3 rounds
  diamondHide,    // ironSkin mutation: reduction scales with enemy HP (max −8)
  lifeleechAura;  // soulSiphon mutation: enemy applies DoT (3% max HP/round for 3 rounds)

  String get displayName {
    switch (this) {
      case ZoneAffix.cursedGround:  return 'Cursed Ground';
      case ZoneAffix.volatileDeath: return 'Volatile Death';
      case ZoneAffix.ironSkin:      return 'Iron Skin';
      case ZoneAffix.soulSiphon:    return 'Cursed Strikes';
      case ZoneAffix.shadowCloak:   return 'Shadow Cloak';
      case ZoneAffix.voidCurse:     return 'Void Curse';
      case ZoneAffix.abyssalRoar:   return 'Abyssal Roar';
      case ZoneAffix.timeFracture:  return 'Time Fracture';
      case ZoneAffix.deathSpiral:   return 'Death Spiral';
      case ZoneAffix.diamondHide:   return 'Diamond Hide';
      case ZoneAffix.lifeleechAura: return 'Venomous Aura';
    }
  }

  String get description {
    switch (this) {
      case ZoneAffix.cursedGround:  return 'Hero bleeds 5% max HP each round.';
      case ZoneAffix.volatileDeath: return 'Enemy explodes on death — unavoidable blast.';
      case ZoneAffix.ironSkin:      return 'All hero damage reduced by 2 (min 1).';
      case ZoneAffix.soulSiphon:    return 'Enemy deals +3 bonus damage per hit.';
      case ZoneAffix.shadowCloak:   return '20% chance to negate any incoming hit.';
      case ZoneAffix.voidCurse:     return 'All hero HP recovery halved.';
      case ZoneAffix.abyssalRoar:   return 'Enemy gains +3 bonus damage.';
      case ZoneAffix.timeFracture:  return 'Every 4th attack is deflected (reduced damage).';
      case ZoneAffix.deathSpiral:   return 'HP drain grows +1% every 3 rounds.';
      case ZoneAffix.diamondHide:   return 'Damage reduction scales with enemy remaining HP.';
      case ZoneAffix.lifeleechAura: return 'Enemy applies poison DoT (3% max HP/round for 3 rounds).';
    }
  }

  int get tier {
    switch (this) {
      case ZoneAffix.deathSpiral:
      case ZoneAffix.diamondHide:
      case ZoneAffix.lifeleechAura:
        return 2;
      default:
        return 1;
    }
  }

  // Minimum abyss depth (stage - 12) before this affix can appear
  int get depthRequired {
    switch (this) {
      case ZoneAffix.cursedGround:  return 8;
      case ZoneAffix.volatileDeath: return 8;
      case ZoneAffix.ironSkin:      return 13;
      case ZoneAffix.soulSiphon:    return 18;
      case ZoneAffix.shadowCloak:   return 23;
      case ZoneAffix.voidCurse:     return 28;
      case ZoneAffix.abyssalRoar:   return 33;
      case ZoneAffix.timeFracture:  return 38;
      case ZoneAffix.deathSpiral:   return 88;
      case ZoneAffix.diamondHide:   return 88;
      case ZoneAffix.lifeleechAura: return 88;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AffixEngine — selects affixes for a given campaign stage
// ─────────────────────────────────────────────────────────────────────────────

class AffixEngine {
  /// Returns the list of active affixes for [stage].
  /// Empty list for the 25-stage campaign (stage < 25).
  /// Affixes begin at abyss depth 8 (stage 32).
  static List<ZoneAffix> affixesFor(int stage, Random rng) {
    final a = stage - 24; // abyss depth (campaign is stages 0–24)
    if (a < 8) return [];

    final tier1 = ZoneAffix.values
        .where((x) => x.tier == 1 && x.depthRequired <= a)
        .toList()
      ..shuffle(rng);

    final tier2 = ZoneAffix.values
        .where((x) => x.tier == 2 && x.depthRequired <= a)
        .toList()
      ..shuffle(rng);

    if (a < 38) return tier1.take(1).toList();
    if (a < 88) return tier1.take(2).toList();
    return [...tier1.take(2), ...tier2.take(1)];
  }
}
