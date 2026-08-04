import 'package:flutter/material.dart';
import 'dnd_class.dart';
import 'damage_type.dart';
import 'palette_skin.dart' show buildPaletteMatrix;

enum SubclassEffect {
  none,
  // Barbarian
  berserk,        // +25% damage below 50% HP
  totemWarrior,   // stat-only: +3 CON +1 STR
  // Bard
  loreKeeper,     // +20% ability power
  valorSurge,     // after any ability, next attack +4 hit
  // Cleric
  lifeCleric,     // +30% healing from abilities
  warCleric,      // +2 flat damage every hit
  // Druid
  moonCircle,     // stat-only: +3 CON +1 WIS
  sporeCircle,    // DoT damage +50%
  // Fighter
  champion,       // crit on rolls of 18-20
  battleMaster,   // stuns last +1 extra round
  // Monk
  openHand,       // damage die d10 instead of d8
  shadowMonk,     // +10% passive dodge chance
  // Paladin
  devotion,       // regen 1 HP each enemy turn
  vengeance,      // +3 pierce, +10% damage
  // Ranger
  hunter,         // +20% damage on all attacks
  beastMaster,    // stat-only: +4 WIS +2 INT
  // Rogue
  assassin,       // crit deals triple damage
  arcaneTrickster,// -1 to all ability cooldowns
  // Sorcerer
  wildMagic,      // 15% chance triple damage on any hit
  draconic,       // stat-only: +3 CON +2 STR
  // Warlock
  greatOldOne,    // +25% ability power
  fiendPact,      // lifesteal 20% of damage dealt
  // Wizard
  evoker,         // +35% ability power
  abjurer,        // +15% healing, stat: +1 CON +1 DEX
}

class Subclass {
  const Subclass({
    required this.id,
    required this.name,
    required this.flavor,
    required this.classRequired,
    required this.effect,
    required this.effectLabel,
    this.strBonus = 0,
    this.dexBonus = 0,
    this.conBonus = 0,
    this.intBonus = 0,
    this.wisBonus = 0,
    this.chaBonus = 0,
    // ── Data-driven capstone bonuses (apply automatically via the stat
    //    pipeline; no per-subclass combat code needed). Used by the expanded
    //    level-50 roster; the original 24 keep their coded `effect` mechanics.
    this.dmgPct = 0,            // increased damage % (all types)
    this.elemType,             // if set, elemDmgPct applies only to this type
    this.elemDmgPct = 0,
    this.critChancePct = 0,
    this.critDmgPct = 0,        // extra crit damage % (e.g. 50 = +0.5× on crit)
    this.cooldownReduce = 0,    // flat rounds off every ability
    this.dotPct = 0,            // +% DoT damage
    this.healPct = 0,           // +% healing/aura/shield
    this.lifestealPct = 0,      // recover % of damage dealt
    this.dodgePct = 0,          // passive dodge chance
    this.hpPct = 0,             // +% max HP
    this.armorPct = 0,          // +% armor
    this.abilityPowerPct = 0,   // +% ability values (bonusDamage/dot/heal/etc)
    this.pierce = 0,            // flat armor penetration (signature effects only)
    this.goldPct = 0,
    this.xpPct = 0,
    this.shardPct = 0,
  });

  final String id;
  final String name;
  final String flavor;
  final DndClass classRequired;
  final SubclassEffect effect;
  final String effectLabel;
  final int strBonus;
  final int dexBonus;
  final int conBonus;
  final int intBonus;
  final int wisBonus;
  final int chaBonus;
  // Data-driven capstone bonuses:
  final int dmgPct;
  final DamageType? elemType;
  final int elemDmgPct;
  final int critChancePct;
  final int critDmgPct;
  final int cooldownReduce;
  final int dotPct;
  final int healPct;
  final int lifestealPct;
  final int dodgePct;
  final int hpPct;
  final int armorPct;
  final int abilityPowerPct;
  final int pierce;
  final int goldPct;
  final int xpPct;
  final int shardPct;

  /// Readable summary of the data-driven capstone bonuses (empty if none).
  String get bonusSummary {
    final p = <String>[];
    if (dmgPct != 0) p.add('+$dmgPct% damage');
    if (elemType != null && elemDmgPct != 0) p.add('+$elemDmgPct% ${elemType!.label} damage');
    if (critChancePct != 0) p.add('+$critChancePct% crit chance');
    if (critDmgPct != 0) p.add('+$critDmgPct% crit damage');
    if (abilityPowerPct != 0) p.add('+$abilityPowerPct% ability power');
    if (dotPct != 0) p.add('+$dotPct% DoT');
    if (healPct != 0) p.add('+$healPct% healing');
    if (lifestealPct != 0) p.add('$lifestealPct% lifesteal');
    if (cooldownReduce != 0) p.add('-$cooldownReduce ability cooldown');
    if (dodgePct != 0) p.add('+$dodgePct% dodge');
    if (hpPct != 0) p.add('+$hpPct% max HP');
    if (armorPct != 0) p.add('+$armorPct% armor');
    if (pierce != 0) p.add('+$pierce armor pierce');
    if (goldPct != 0) p.add('+$goldPct% gold');
    if (xpPct != 0) p.add('+$xpPct% XP');
    if (shardPct != 0) p.add('+$shardPct% shards');
    return p.join('  •  ');
  }

  // ── Cosmetic sprite tint (theme-derived from a curated palette pool) ──────
  ColorFilter get spriteColorFilter {
    final p = _paletteRecipe();
    return ColorFilter.matrix(buildPaletteMatrix(p.$1, p.$2, p.$3));
  }
  Color get spriteSwatch => _paletteRecipe().$4;

  (double, double, double, Color) _paletteRecipe() {
    final h = id.hashCode & 0x7fffffff;
    (double, double, double, Color) pick(List<(double, double, double, Color)> pool) {
      final base = pool[h % pool.length];
      final jitter = ((h ~/ 7) % 17) - 8; // ±8° hue jitter for variety
      return (base.$1 + jitter, base.$2, base.$3, base.$4);
    }
    // Elemental themes take priority.
    if (elemType != null) {
      switch (elemType!) {
        case DamageType.fire:
          return pick([(18, 1.6, -5, const Color(0xFFdd4400)), (30, 1.5, 8, const Color(0xFFee6622)), (6, 1.7, -14, const Color(0xFFcc2200))]);
        case DamageType.cold:
          return pick([(200, 1.25, 10, const Color(0xFF44aacc)), (210, 1.4, 0, const Color(0xFF3388dd)), (190, 1.2, 22, const Color(0xFF77ccdd))]);
        case DamageType.lightning:
          return pick([(50, 1.5, 15, const Color(0xFFeecc22)), (46, 1.4, 22, const Color(0xFFffdd44)), (56, 1.6, 6, const Color(0xFFddbb00))]);
        case DamageType.poison:
          return pick([(110, 1.4, 0, const Color(0xFF66cc33)), (96, 1.5, -6, const Color(0xFF88bb22)), (124, 1.3, 10, const Color(0xFF55dd66))]);
        case DamageType.void_:
          return pick([(265, 1.5, -20, const Color(0xFF6600cc)), (282, 1.6, -14, const Color(0xFF8800ff)), (250, 1.4, -26, const Color(0xFF5500aa))]);
        case DamageType.physical:
          break; // fall through to profile-based tint
      }
    }
    // Non-elemental → tint by bonus profile.
    final defensive = armorPct + hpPct;
    final offensive = dmgPct + critChancePct + critDmgPct;
    if (healPct >= 20) {
      return pick([(45, 0.6, 40, const Color(0xFFe8dcb0)), (50, 0.5, 32, const Color(0xFFf0e0c0))]);
    }
    if (defensive >= 25 && defensive >= offensive) {
      return pick([(0, 0.5, 22, const Color(0xFFaab0bb)), (220, 0.4, 12, const Color(0xFF8899aa)), (38, 1.0, 10, const Color(0xFFbb8844))]);
    }
    if (goldPct >= 15 || xpPct >= 20) {
      return pick([(38, 1.4, 15, const Color(0xFFcc9922)), (44, 1.3, 20, const Color(0xFFddaa33))]);
    }
    // Default: aggressive crimson family.
    return pick([(345, 1.6, -30, const Color(0xFF990022)), (0, 1.3, -8, const Color(0xFFaa2222)), (20, 1.4, 10, const Color(0xFFcc5522))]);
  }

  String get statLine {
    final parts = <String>[];
    if (strBonus != 0) parts.add('STR ${strBonus > 0 ? '+' : ''}$strBonus');
    if (dexBonus != 0) parts.add('DEX ${dexBonus > 0 ? '+' : ''}$dexBonus');
    if (conBonus != 0) parts.add('CON ${conBonus > 0 ? '+' : ''}$conBonus');
    if (intBonus != 0) parts.add('INT ${intBonus > 0 ? '+' : ''}$intBonus');
    if (wisBonus != 0) parts.add('WIS ${wisBonus > 0 ? '+' : ''}$wisBonus');
    if (chaBonus != 0) parts.add('CHA ${chaBonus > 0 ? '+' : ''}$chaBonus');
    return parts.join('  ');
  }
}

const kSubclassCatalog = <Subclass>[
  // ── BARBARIAN (physical / poison / lightning) ───────────────────
  Subclass(
    id: 'berserker', name: 'Berserker', classRequired: DndClass.barbarian,
    flavor: 'Rage strips away pain. When blood runs low, fury runs high.',
    effect: SubclassEffect.berserk,
    effectLabel: '+25% damage while below 50% HP',
    lifestealPct: 10, strBonus: 1, conBonus: 1,
  ),
  Subclass(
    id: 'totem_warrior', name: 'Totem Warrior', classRequired: DndClass.barbarian,
    flavor: 'The spirit of the bear flows through you — endure what would break others.',
    effect: SubclassEffect.totemWarrior,
    effectLabel: 'Bear totem — enduring resilience',
    hpPct: 25, armorPct: 30, strBonus: 1, conBonus: 2,
  ),
  Subclass(
    id: 'zealot', name: 'Path of the Zealot', classRequired: DndClass.barbarian,
    flavor: 'Divine fury burns in your veins — death itself cannot slow your rampage.',
    effect: SubclassEffect.none, effectLabel: 'Zealous fury',
    dmgPct: 35, strBonus: 2, conBonus: 1,
  ),
  Subclass(
    id: 'wild_heart', name: 'Path of the Wild Heart', classRequired: DndClass.barbarian,
    flavor: 'The spirits of beasts lend their strength and vigour.',
    effect: SubclassEffect.none, effectLabel: 'Primal versatility',
    dmgPct: 20, hpPct: 12, strBonus: 1, conBonus: 2,
  ),
  Subclass(
    id: 'ancestral_guardian', name: 'Path of the Ancestral Guardian', classRequired: DndClass.barbarian,
    flavor: 'The spirits of your ancestors shield you and turn aside every blow.',
    effect: SubclassEffect.none, effectLabel: 'Ancestral ward',
    armorPct: 45, hpPct: 15, conBonus: 3,
  ),
  Subclass(
    id: 'storm_herald', name: 'Path of the Storm Herald', classRequired: DndClass.barbarian,
    flavor: 'Your rage manifests as a raging storm of crackling lightning.',
    effect: SubclassEffect.none, effectLabel: 'Storm aura',
    elemType: DamageType.lightning, elemDmgPct: 45, strBonus: 1, conBonus: 1,
  ),
  Subclass(
    id: 'battlerager', name: 'Path of the Battlerager', classRequired: DndClass.barbarian,
    flavor: 'Spiked armour turns your body into a weapon — the more they hit you, the more they bleed.',
    effect: SubclassEffect.none, effectLabel: 'Spiked fury',
    dmgPct: 18, armorPct: 30, strBonus: 2, conBonus: 1,
  ),
  Subclass(
    id: 'beast_barb', name: 'Path of the Beast', classRequired: DndClass.barbarian,
    flavor: 'Claws, fangs, and a tail erupt from your flesh — feed on the fallen.',
    effect: SubclassEffect.none, effectLabel: 'Bestial hunger',
    dmgPct: 22, lifestealPct: 15, strBonus: 2,
  ),
  Subclass(
    id: 'wild_magic_barb', name: 'Path of Wild Magic', classRequired: DndClass.barbarian,
    flavor: 'Raw magic surges through your rage, striking with unpredictable force.',
    effect: SubclassEffect.none, effectLabel: 'Chaotic surge',
    dmgPct: 25, critChancePct: 12, strBonus: 1, chaBonus: 1,
  ),
  Subclass(
    id: 'giant_barb', name: 'Path of the Giant', classRequired: DndClass.barbarian,
    flavor: 'You grow to titanic size, your every blow shaking the earth.',
    effect: SubclassEffect.none, effectLabel: 'Titanic might',
    dmgPct: 42, strBonus: 3,
  ),
  Subclass(
    id: 'carrion_raven', name: 'Path of the Carrion Raven', classRequired: DndClass.barbarian,
    flavor: 'Rot and decay follow your every strike — wounds fester and spread.',
    effect: SubclassEffect.none, effectLabel: 'Festering rot',
    elemType: DamageType.poison, elemDmgPct: 50, dotPct: 40, conBonus: 1,
  ),
  Subclass(
    id: 'spell_scorned', name: 'Path of the Spell Scorned', classRequired: DndClass.barbarian,
    flavor: 'Magic breaks against you like waves on stone. Nothing arcane can touch you.',
    effect: SubclassEffect.none, effectLabel: 'Spell-scorned bulwark',
    hpPct: 15, armorPct: 30, dmgPct: 12, conBonus: 2,
  ),
  Subclass(
    id: 'world_tree', name: 'Path of the World Tree', classRequired: DndClass.barbarian,
    flavor: 'Rooted in the great tree of life, your wounds close as fast as they open.',
    effect: SubclassEffect.none, effectLabel: 'Rooted vitality',
    hpPct: 30, healPct: 25, conBonus: 2, wisBonus: 1,
  ),
  Subclass(
    id: 'juggernaut', name: 'Path of the Juggernaut', classRequired: DndClass.barbarian,
    flavor: 'An unstoppable force of muscle and momentum. Nothing slows your charge.',
    effect: SubclassEffect.none, effectLabel: 'Unstoppable',
    hpPct: 28, dmgPct: 18, strBonus: 2, conBonus: 2,
  ),

  // ── BARD (support / ability / void) ─────────────────────────────
  Subclass(
    id: 'lore_keeper', name: 'College of Lore', classRequired: DndClass.bard,
    flavor: 'Ancient words amplify every spell. Knowledge is the greatest weapon.',
    effect: SubclassEffect.loreKeeper,
    effectLabel: '+20% to all ability effects',
    healPct: 15, intBonus: 1, wisBonus: 1,
  ),
  Subclass(
    id: 'valor_surge', name: 'College of Valor', classRequired: DndClass.bard,
    flavor: "A warrior's song sharpens the blade. The next blow after magic always finds its mark.",
    effect: SubclassEffect.valorSurge,
    effectLabel: 'After any ability: next attack +4 to hit',
    dmgPct: 20, strBonus: 1, chaBonus: 1,
  ),
  Subclass(
    id: 'college_swords', name: 'College of Swords', classRequired: DndClass.bard,
    flavor: 'Blade flourishes turn performance into lethal art.',
    effect: SubclassEffect.none, effectLabel: 'Blade flourish',
    dmgPct: 30, critChancePct: 10, dexBonus: 2,
  ),
  Subclass(
    id: 'college_glamour', name: 'College of Glamour', classRequired: DndClass.bard,
    flavor: 'Fey enchantment mends allies and beguiles foes.',
    effect: SubclassEffect.none, effectLabel: 'Mantle of majesty',
    healPct: 30, hpPct: 12, chaBonus: 2,
  ),
  Subclass(
    id: 'college_dance', name: 'College of Dance', classRequired: DndClass.bard,
    flavor: 'Every step is a dodge, every spin a strike.',
    effect: SubclassEffect.none, effectLabel: 'Dazzling footwork',
    dodgePct: 15, dmgPct: 15, dexBonus: 2,
  ),
  Subclass(
    id: 'college_whispers', name: 'College of Whispers', classRequired: DndClass.bard,
    flavor: 'Words of terror slip past armour and into the heart.',
    effect: SubclassEffect.none, effectLabel: 'Words of terror',
    dmgPct: 25, critDmgPct: 30, chaBonus: 1, intBonus: 1,
  ),
  Subclass(
    id: 'college_creation', name: 'College of Creation', classRequired: DndClass.bard,
    flavor: 'The Song of Creation itself flows through your abilities.',
    effect: SubclassEffect.none, effectLabel: 'Song of creation',
    abilityPowerPct: 30, chaBonus: 2,
  ),
  Subclass(
    id: 'college_eloquence', name: 'College of Eloquence', classRequired: DndClass.bard,
    flavor: 'Silver-tongued persuasion opens every purse and door.',
    effect: SubclassEffect.none, effectLabel: 'Silver tongue',
    goldPct: 25, xpPct: 25, chaBonus: 2,
  ),
  Subclass(
    id: 'college_spirits', name: 'College of Spirits', classRequired: DndClass.bard,
    flavor: 'Restless spirits whisper tales that wound the living.',
    effect: SubclassEffect.none, effectLabel: 'Spectral tales',
    elemType: DamageType.void_, elemDmgPct: 40, chaBonus: 1, wisBonus: 1,
  ),
  Subclass(
    id: 'college_moon', name: 'College of the Moon', classRequired: DndClass.bard,
    flavor: 'Moonlit ballads chill the marrow of your foes.',
    effect: SubclassEffect.none, effectLabel: 'Moonlit ballad',
    elemType: DamageType.cold, elemDmgPct: 40, wisBonus: 1, chaBonus: 1,
  ),
  Subclass(
    id: 'college_requiems', name: 'College of Requiems', classRequired: DndClass.bard,
    flavor: 'A dirge of decay that lingers long after the final note.',
    effect: SubclassEffect.none, effectLabel: 'Dirge of decay',
    dotPct: 40, dmgPct: 15, chaBonus: 1,
  ),
  Subclass(
    id: 'college_drama', name: 'College of Drama', classRequired: DndClass.bard,
    flavor: 'A show-stopping performance that turns the tide of battle.',
    effect: SubclassEffect.none, effectLabel: 'Show-stopper',
    dmgPct: 25, critChancePct: 12, chaBonus: 2,
  ),
  Subclass(
    id: 'college_tragedy', name: 'College of Tragedy', classRequired: DndClass.bard,
    flavor: 'Sorrowful songs draw the life from your enemies into you.',
    effect: SubclassEffect.none, effectLabel: 'Sorrowful drain',
    dmgPct: 30, lifestealPct: 10, chaBonus: 1, intBonus: 1,
  ),

  // ── CLERIC (fire / void / healing / mixed) ──────────────────────
  Subclass(
    id: 'life_cleric', name: 'Life Domain', classRequired: DndClass.cleric,
    flavor: 'The light of the gods flows through your hands, mending the broken.',
    effect: SubclassEffect.lifeCleric,
    effectLabel: '+30% to all healing abilities',
    hpPct: 15, wisBonus: 1, conBonus: 1,
  ),
  Subclass(
    id: 'war_cleric', name: 'War Domain', classRequired: DndClass.cleric,
    flavor: 'Blessed by the god of battle, your every strike carries divine fury.',
    effect: SubclassEffect.warCleric,
    effectLabel: '+2 damage on every attack',
    dmgPct: 25, strBonus: 2, conBonus: 1,
  ),
  Subclass(
    id: 'light_domain', name: 'Light Domain', classRequired: DndClass.cleric,
    flavor: 'Radiant fire scours the darkness and your enemies alike.',
    effect: SubclassEffect.none, effectLabel: 'Radiance of the dawn',
    elemType: DamageType.fire, elemDmgPct: 45, wisBonus: 1,
  ),
  Subclass(
    id: 'trickery_domain', name: 'Trickery Domain', classRequired: DndClass.cleric,
    flavor: 'Blessings of deception let you slip aside and strike true.',
    effect: SubclassEffect.none, effectLabel: 'Blessed misdirection',
    dodgePct: 12, critChancePct: 10, dexBonus: 1, wisBonus: 1,
  ),
  Subclass(
    id: 'tempest_domain', name: 'Tempest Domain', classRequired: DndClass.cleric,
    flavor: 'Thunder and lightning answer your call.',
    effect: SubclassEffect.none, effectLabel: 'Wrath of the storm',
    elemType: DamageType.lightning, elemDmgPct: 45, wisBonus: 1,
  ),
  Subclass(
    id: 'nature_domain', name: 'Nature Domain', classRequired: DndClass.cleric,
    flavor: 'The wild bends to your prayers — to heal and to harm.',
    effect: SubclassEffect.none, effectLabel: "Nature's balance",
    healPct: 20, dmgPct: 15, wisBonus: 2,
  ),
  Subclass(
    id: 'grave_domain', name: 'Grave Domain', classRequired: DndClass.cleric,
    flavor: 'You mark the dying — and the reaper never misses.',
    effect: SubclassEffect.none, effectLabel: "Reaper's mark",
    elemType: DamageType.void_, elemDmgPct: 40, critDmgPct: 20, wisBonus: 1,
  ),
  Subclass(
    id: 'forge_domain', name: 'Forge Domain', classRequired: DndClass.cleric,
    flavor: 'Blessing of the forge tempers your armour and your blade.',
    effect: SubclassEffect.none, effectLabel: 'Blessing of the forge',
    armorPct: 35, dmgPct: 15, strBonus: 1, conBonus: 1,
  ),
  Subclass(
    id: 'order_domain', name: 'Order Domain', classRequired: DndClass.cleric,
    flavor: 'Divine order empowers every incantation.',
    effect: SubclassEffect.none, effectLabel: "Voice of authority",
    abilityPowerPct: 30, wisBonus: 1, intBonus: 1,
  ),
  Subclass(
    id: 'peace_domain', name: 'Peace Domain', classRequired: DndClass.cleric,
    flavor: 'Bonds of peace shelter you from the worst of harm.',
    effect: SubclassEffect.none, effectLabel: 'Emboldening bond',
    healPct: 35, hpPct: 15, wisBonus: 1, chaBonus: 1,
  ),
  Subclass(
    id: 'knowledge_domain', name: 'Knowledge Domain', classRequired: DndClass.cleric,
    flavor: 'Divine insight accelerates learning and sharpens spellcraft.',
    effect: SubclassEffect.none, effectLabel: 'Divine insight',
    xpPct: 30, abilityPowerPct: 15, intBonus: 2,
  ),
  Subclass(
    id: 'twilight_domain', name: 'Twilight Domain', classRequired: DndClass.cleric,
    flavor: 'Soothing twilight grants endurance and steady restoration.',
    effect: SubclassEffect.none, effectLabel: 'Twilight sanctuary',
    hpPct: 25, healPct: 20, wisBonus: 1, conBonus: 1,
  ),
  Subclass(
    id: 'death_domain', name: 'Death Domain', classRequired: DndClass.cleric,
    flavor: 'The necrotic touch of the reaper flows through your strikes.',
    effect: SubclassEffect.none, effectLabel: 'Touch of death',
    elemType: DamageType.void_, elemDmgPct: 50, wisBonus: 1,
  ),
  Subclass(
    id: 'arcana_domain', name: 'Arcana Domain', classRequired: DndClass.cleric,
    flavor: 'Divine magic laced with arcane secrets amplifies your power.',
    effect: SubclassEffect.none, effectLabel: 'Arcane blessing',
    abilityPowerPct: 25, dmgPct: 12, intBonus: 1, wisBonus: 1,
  ),
  Subclass(
    id: 'blood_domain', name: 'Blood Domain', classRequired: DndClass.cleric,
    flavor: 'Blood magic returns to you the vitality you spill.',
    effect: SubclassEffect.none, effectLabel: 'Blood offering',
    dmgPct: 20, lifestealPct: 15, conBonus: 1,
  ),
  Subclass(
    id: 'moon_domain_cleric', name: 'Moon Domain', classRequired: DndClass.cleric,
    flavor: 'Cold moonlight freezes the faithless where they stand.',
    effect: SubclassEffect.none, effectLabel: 'Cold moonlight',
    elemType: DamageType.cold, elemDmgPct: 45, wisBonus: 1,
  ),

  // ── DRUID (poison / cold / fire / healing) ──────────────────────
  Subclass(
    id: 'moon_circle', name: 'Circle of the Moon', classRequired: DndClass.druid,
    flavor: 'The moon grants endurance beyond mortal limits. Pain is just moonlight.',
    effect: SubclassEffect.moonCircle,
    effectLabel: 'Dire shapeshift — enhanced resilience',
    hpPct: 30, armorPct: 20, conBonus: 3, wisBonus: 1,
  ),
  Subclass(
    id: 'spore_circle', name: 'Circle of Spores', classRequired: DndClass.druid,
    flavor: 'Death and decay are part of nature. Your poisons rot through any defence.',
    effect: SubclassEffect.sporeCircle,
    effectLabel: '+50% DoT damage',
    elemType: DamageType.poison, elemDmgPct: 40, wisBonus: 1, intBonus: 1,
  ),
  Subclass(
    id: 'land_circle', name: 'Circle of the Land', classRequired: DndClass.druid,
    flavor: 'The land itself lends its ancient magic to your spells.',
    effect: SubclassEffect.none, effectLabel: "Land's bounty",
    abilityPowerPct: 30, wisBonus: 2,
  ),
  Subclass(
    id: 'sea_circle', name: 'Circle of the Sea', classRequired: DndClass.druid,
    flavor: 'The wrath of the tides freezes and drowns all before you.',
    effect: SubclassEffect.none, effectLabel: 'Wrath of the sea',
    elemType: DamageType.cold, elemDmgPct: 45, wisBonus: 1,
  ),
  Subclass(
    id: 'stars_circle', name: 'Circle of the Stars', classRequired: DndClass.druid,
    flavor: 'Starlight guides your strikes and mends your wounds.',
    effect: SubclassEffect.none, effectLabel: 'Starry form',
    dmgPct: 18, healPct: 18, wisBonus: 2,
  ),
  Subclass(
    id: 'dreams_circle', name: 'Circle of Dreams', classRequired: DndClass.druid,
    flavor: 'The gifts of the Summer Court restore and shelter.',
    effect: SubclassEffect.none, effectLabel: 'Balm of the Summer Court',
    healPct: 30, hpPct: 15, wisBonus: 1, chaBonus: 1,
  ),
  Subclass(
    id: 'wildfire_circle', name: 'Circle of Wildfire', classRequired: DndClass.druid,
    flavor: 'Fire is renewal — and it burns away your foes.',
    effect: SubclassEffect.none, effectLabel: 'Wildfire spirit',
    elemType: DamageType.fire, elemDmgPct: 45, wisBonus: 1,
  ),
  Subclass(
    id: 'shepherd_circle', name: 'Circle of the Shepherd', classRequired: DndClass.druid,
    flavor: 'Spirit totems guard your growth and bolster your might.',
    effect: SubclassEffect.none, effectLabel: 'Spirit totem',
    xpPct: 25, dmgPct: 15, wisBonus: 1,
  ),
  Subclass(
    id: 'primeval_circle', name: 'Circle of the Primeval', classRequired: DndClass.druid,
    flavor: 'The primal world of old hardens your hide against all harm.',
    effect: SubclassEffect.none, effectLabel: 'Primeval hide',
    hpPct: 25, armorPct: 25, conBonus: 2,
  ),
  Subclass(
    id: 'preservation_circle', name: 'Circle of Preservation', classRequired: DndClass.druid,
    flavor: 'Life must endure — your restorative magic knows no equal.',
    effect: SubclassEffect.none, effectLabel: 'Preserving grove',
    healPct: 35, wisBonus: 2,
  ),
  Subclass(
    id: 'twilight_circle_druid', name: 'Circle of Twilight', classRequired: DndClass.druid,
    flavor: 'The boundary of day and night shrouds you from harm.',
    effect: SubclassEffect.none, effectLabel: 'Harvest of twilight',
    hpPct: 20, dodgePct: 12, wisBonus: 1,
  ),
  Subclass(
    id: 'symbiote_circle', name: 'Circle of the Symbiote', classRequired: DndClass.druid,
    flavor: 'A parasitic bond drains your foes to feed your own life.',
    effect: SubclassEffect.none, effectLabel: 'Symbiotic bond',
    dmgPct: 22, lifestealPct: 12, conBonus: 1,
  ),
  Subclass(
    id: 'blighted_circle', name: 'Circle of the Blighted', classRequired: DndClass.druid,
    flavor: 'Corruption spreads from your touch, festering and unstoppable.',
    effect: SubclassEffect.none, effectLabel: 'Spreading blight',
    elemType: DamageType.poison, elemDmgPct: 45, dotPct: 30, wisBonus: 1,
  ),

  // ── FIGHTER (physical / fire / lightning) ───────────────────────
  Subclass(
    id: 'champion', name: 'Champion', classRequired: DndClass.fighter,
    flavor: 'Perfected technique turns near-misses into killing blows.',
    effect: SubclassEffect.champion,
    effectLabel: 'Critical hit on 18, 19, or 20',
    critChancePct: 12, critDmgPct: 20, strBonus: 1, conBonus: 1,
  ),
  Subclass(
    id: 'battle_master', name: 'Battle Master', classRequired: DndClass.fighter,
    flavor: 'Every manoeuvre is a calculated trap. The enemy never recovers.',
    effect: SubclassEffect.battleMaster,
    effectLabel: 'Stun abilities last +1 round',
    dmgPct: 25, strBonus: 1, dexBonus: 1,
  ),
  Subclass(
    id: 'eldritch_knight', name: 'Eldritch Knight', classRequired: DndClass.fighter,
    flavor: 'Blade and spell woven into one deadly discipline.',
    effect: SubclassEffect.none, effectLabel: 'War magic',
    abilityPowerPct: 28, dmgPct: 12, intBonus: 2,
  ),
  Subclass(
    id: 'purple_dragon_knight', name: 'Purple Dragon Knight', classRequired: DndClass.fighter,
    flavor: 'A banneret whose presence steels the whole line.',
    effect: SubclassEffect.none, effectLabel: 'Rallying cry',
    hpPct: 18, dmgPct: 15, chaBonus: 1, strBonus: 1,
  ),
  Subclass(
    id: 'cavalier', name: 'Cavalier', classRequired: DndClass.fighter,
    flavor: 'An unbreakable bulwark that guards allies and endures all.',
    effect: SubclassEffect.none, effectLabel: 'Unwavering mark',
    armorPct: 35, hpPct: 15, strBonus: 1, conBonus: 1,
  ),
  Subclass(
    id: 'rune_knight', name: 'Rune Knight', classRequired: DndClass.fighter,
    flavor: 'Giant runes swell your size and shatter your foes.',
    effect: SubclassEffect.none, effectLabel: 'Giant might',
    dmgPct: 30, hpPct: 15, strBonus: 2,
  ),
  Subclass(
    id: 'samurai', name: 'Samurai', classRequired: DndClass.fighter,
    flavor: 'Fighting spirit sharpens each strike into a killing edge.',
    effect: SubclassEffect.none, effectLabel: 'Fighting spirit',
    critChancePct: 15, dmgPct: 15, dexBonus: 2,
  ),
  Subclass(
    id: 'arcane_archer', name: 'Arcane Archer', classRequired: DndClass.fighter,
    flavor: 'Enchanted arrows crackle with lightning as they fly.',
    effect: SubclassEffect.none, effectLabel: 'Arcane shot',
    elemType: DamageType.lightning, elemDmgPct: 40, critChancePct: 8, dexBonus: 1,
  ),
  Subclass(
    id: 'echo_knight', name: 'Echo Knight', classRequired: DndClass.fighter,
    flavor: 'A spectral echo strikes alongside you, doubling the carnage.',
    effect: SubclassEffect.none, effectLabel: 'Echo strike',
    dmgPct: 35, dexBonus: 1, conBonus: 1,
  ),
  Subclass(
    id: 'gladiator', name: 'Gladiator', classRequired: DndClass.fighter,
    flavor: 'The crowd roars as you carve life from your rivals.',
    effect: SubclassEffect.none, effectLabel: 'Crowd favourite',
    dmgPct: 22, lifestealPct: 12, strBonus: 2,
  ),
  Subclass(
    id: 'brute', name: 'Brute', classRequired: DndClass.fighter,
    flavor: 'No finesse — only overwhelming, brutal force.',
    effect: SubclassEffect.none, effectLabel: 'Brute force',
    dmgPct: 40, strBonus: 3,
  ),
  Subclass(
    id: 'psi_warrior', name: 'Psi Warrior', classRequired: DndClass.fighter,
    flavor: 'Psionic power augments your body and rends minds.',
    effect: SubclassEffect.none, effectLabel: 'Psionic power',
    abilityPowerPct: 25, elemType: DamageType.void_, elemDmgPct: 20, intBonus: 2,
  ),
  Subclass(
    id: 'banneret', name: 'Banneret', classRequired: DndClass.fighter,
    flavor: 'A rallying leader whose inspiration mends and shields.',
    effect: SubclassEffect.none, effectLabel: "Royal envoy",
    healPct: 25, hpPct: 15, chaBonus: 1,
  ),
  Subclass(
    id: 'gunslinger', name: 'Gunslinger', classRequired: DndClass.fighter,
    flavor: 'One shot, one kill — your aim finds the vital point.',
    effect: SubclassEffect.none, effectLabel: 'Trick shot',
    critDmgPct: 40, dmgPct: 12, dexBonus: 2,
  ),
  Subclass(
    id: 'blade_breaker', name: 'Blade Breaker', classRequired: DndClass.fighter,
    flavor: 'You shatter weapons and turn defence into offence.',
    effect: SubclassEffect.none, effectLabel: 'Riposte guard',
    armorPct: 30, dmgPct: 15, strBonus: 1, conBonus: 1,
  ),
  Subclass(
    id: 'hero_fighter', name: 'Hero', classRequired: DndClass.fighter,
    flavor: 'The complete warrior — strong, tough, and unerring.',
    effect: SubclassEffect.none, effectLabel: "Hero's resolve",
    dmgPct: 15, hpPct: 15, critChancePct: 8, strBonus: 1, conBonus: 1,
  ),

  // ── MONK (physical / fire / cold / lightning) ───────────────────
  Subclass(
    id: 'open_hand', name: 'Way of the Open Hand', classRequired: DndClass.monk,
    flavor: 'The palm strike channels pure force. No armour can absorb it.',
    effect: SubclassEffect.openHand,
    effectLabel: '+25% base attack damage',
    dmgPct: 20, dexBonus: 2, wisBonus: 1,
  ),
  Subclass(
    id: 'shadow_monk', name: 'Way of Shadow', classRequired: DndClass.monk,
    flavor: 'Become the shadow between strikes. What cannot be touched cannot be hurt.',
    effect: SubclassEffect.shadowMonk,
    effectLabel: '+10% passive dodge chance',
    dodgePct: 8, dmgPct: 12, dexBonus: 2, wisBonus: 1,
  ),
  Subclass(
    id: 'four_elements', name: 'Way of the Four Elements', classRequired: DndClass.monk,
    flavor: 'Ki flows as the elements — fire, water, earth and air at your command.',
    effect: SubclassEffect.none, effectLabel: 'Elemental attunement',
    abilityPowerPct: 25, dmgPct: 15, wisBonus: 1, intBonus: 1,
  ),
  Subclass(
    id: 'drunken_master', name: 'Way of the Drunken Master', classRequired: DndClass.monk,
    flavor: 'Stumbling, weaving, unpredictable — and impossible to pin down.',
    effect: SubclassEffect.none, effectLabel: 'Tipsy sway',
    dodgePct: 15, dmgPct: 15, dexBonus: 2,
  ),
  Subclass(
    id: 'kensei', name: 'Way of the Kensei', classRequired: DndClass.monk,
    flavor: 'The weapon is an extension of the soul — precise and deadly.',
    effect: SubclassEffect.none, effectLabel: 'Sharpen the blade',
    critChancePct: 12, dmgPct: 18, dexBonus: 2,
  ),
  Subclass(
    id: 'long_death', name: 'Way of the Long Death', classRequired: DndClass.monk,
    flavor: 'You study death — and steal its power to sustain yourself.',
    effect: SubclassEffect.none, effectLabel: 'Touch of the long death',
    elemType: DamageType.void_, elemDmgPct: 30, lifestealPct: 10, wisBonus: 1,
  ),
  Subclass(
    id: 'sun_soul', name: 'Way of the Sun Soul', classRequired: DndClass.monk,
    flavor: 'Radiant ki bursts from your fists as searing fire.',
    effect: SubclassEffect.none, effectLabel: 'Radiant sun bolt',
    elemType: DamageType.fire, elemDmgPct: 45, wisBonus: 1,
  ),
  Subclass(
    id: 'astral_self', name: 'Way of the Astral Self', classRequired: DndClass.monk,
    flavor: 'Your ki manifests as a spectral warrior of immense reach.',
    effect: SubclassEffect.none, effectLabel: 'Arms of the astral self',
    dmgPct: 20, hpPct: 15, wisBonus: 2,
  ),
  Subclass(
    id: 'mercy', name: 'Way of Mercy', classRequired: DndClass.monk,
    flavor: 'Hands that heal and hands that harm — you master both.',
    effect: SubclassEffect.none, effectLabel: 'Hands of healing & harm',
    healPct: 30, dmgPct: 12, wisBonus: 1,
  ),
  Subclass(
    id: 'cobalt_soul', name: 'Way of the Cobalt Soul', classRequired: DndClass.monk,
    flavor: 'Study of the enemy reveals every weakness to exploit.',
    effect: SubclassEffect.none, effectLabel: 'Extract aspects',
    critChancePct: 12, xpPct: 20, intBonus: 1, wisBonus: 1,
  ),
  Subclass(
    id: 'ascended_dragon', name: 'Way of the Ascended Dragon', classRequired: DndClass.monk,
    flavor: 'Draconic ki breathes elemental devastation.',
    effect: SubclassEffect.none, effectLabel: 'Breath of the dragon',
    elemType: DamageType.fire, elemDmgPct: 40, dmgPct: 10, wisBonus: 1,
  ),
  Subclass(
    id: 'living_weapon', name: 'Way of the Living Weapon', classRequired: DndClass.monk,
    flavor: 'Body and blade are one — a perfect instrument of destruction.',
    effect: SubclassEffect.none, effectLabel: 'Living weapon',
    dmgPct: 32, dexBonus: 2,
  ),
  Subclass(
    id: 'tranquility', name: 'Way of Tranquility', classRequired: DndClass.monk,
    flavor: 'Inner peace radiates outward, mending and enduring.',
    effect: SubclassEffect.none, effectLabel: 'Sanctuary',
    healPct: 30, hpPct: 15, wisBonus: 2,
  ),
  Subclass(
    id: 'tattooed_warrior', name: 'Way of the Tattooed Warrior', classRequired: DndClass.monk,
    flavor: 'Sacred ink wards your body and empowers your strikes.',
    effect: SubclassEffect.none, effectLabel: 'Sacred ink',
    armorPct: 30, dmgPct: 12, conBonus: 1, wisBonus: 1,
  ),

  // ── PALADIN (physical / fire / void / healing) ──────────────────
  Subclass(
    id: 'devotion', name: 'Oath of Devotion', classRequired: DndClass.paladin,
    flavor: 'Sacred light heals wounds between every clash of steel.',
    effect: SubclassEffect.devotion,
    effectLabel: 'Regenerate HP each enemy turn',
    healPct: 20, hpPct: 15, conBonus: 1, wisBonus: 1,
  ),
  Subclass(
    id: 'vengeance', name: 'Oath of Vengeance', classRequired: DndClass.paladin,
    flavor: 'The guilty cannot hide. Your blade finds the gaps in their armour.',
    effect: SubclassEffect.vengeance,
    effectLabel: '+3 pierce, +10% damage',
    dmgPct: 20, strBonus: 2, conBonus: 1,
  ),
  Subclass(
    id: 'ancients', name: 'Oath of the Ancients', classRequired: DndClass.paladin,
    flavor: 'The primal light of life shelters you from the encroaching dark.',
    effect: SubclassEffect.none, effectLabel: 'Aura of warding',
    hpPct: 25, healPct: 20, chaBonus: 1, conBonus: 1,
  ),
  Subclass(
    id: 'conquest', name: 'Oath of Conquest', classRequired: DndClass.paladin,
    flavor: 'Fear is your weapon; the crushed enemy is your throne.',
    effect: SubclassEffect.none, effectLabel: 'Conquering presence',
    dmgPct: 30, critDmgPct: 15, strBonus: 2,
  ),
  Subclass(
    id: 'redemption', name: 'Oath of Redemption', classRequired: DndClass.paladin,
    flavor: 'A shield of peace that mends and protects above all.',
    effect: SubclassEffect.none, effectLabel: 'Emissary of redemption',
    healPct: 35, hpPct: 15, chaBonus: 1, wisBonus: 1,
  ),
  Subclass(
    id: 'crown', name: 'Oath of the Crown', classRequired: DndClass.paladin,
    flavor: 'A sworn guardian of the realm — an immovable wall of steel.',
    effect: SubclassEffect.none, effectLabel: 'Champion challenge',
    armorPct: 40, hpPct: 15, conBonus: 2,
  ),
  Subclass(
    id: 'watchers', name: 'Oath of the Watchers', classRequired: DndClass.paladin,
    flavor: 'Ever-vigilant against the otherworldly — you strike back at the void.',
    effect: SubclassEffect.none, effectLabel: 'Watcher\'s ward',
    elemType: DamageType.void_, elemDmgPct: 35, dmgPct: 10, wisBonus: 1,
  ),
  Subclass(
    id: 'glory', name: 'Oath of Glory', classRequired: DndClass.paladin,
    flavor: 'Peerless athleticism carries you to legendary feats.',
    effect: SubclassEffect.none, effectLabel: 'Peerless athlete',
    dmgPct: 20, hpPct: 15, strBonus: 1, chaBonus: 1,
  ),
  Subclass(
    id: 'treachery', name: 'Oath of Treachery', classRequired: DndClass.paladin,
    flavor: 'Honour is a mask; the dagger waits behind the smile.',
    effect: SubclassEffect.none, effectLabel: 'Poisoned truce',
    critChancePct: 12, dodgePct: 10, dexBonus: 1, chaBonus: 1,
  ),
  Subclass(
    id: 'heroism', name: 'Oath of Heroism', classRequired: DndClass.paladin,
    flavor: 'Destined for glory, your blows land with fated force.',
    effect: SubclassEffect.none, effectLabel: 'Glorious defense',
    dmgPct: 30, strBonus: 2,
  ),
  Subclass(
    id: 'oathbreaker', name: 'Oathbreaker', classRequired: DndClass.paladin,
    flavor: 'You forsook your oath — and the dark rewards you richly.',
    effect: SubclassEffect.none, effectLabel: 'Dread lord',
    elemType: DamageType.void_, elemDmgPct: 40, lifestealPct: 12, chaBonus: 1,
  ),
  Subclass(
    id: 'zeal', name: 'Oath of Zeal', classRequired: DndClass.paladin,
    flavor: 'Holy fire erupts with every righteous strike.',
    effect: SubclassEffect.none, effectLabel: 'Zealous flame',
    elemType: DamageType.fire, elemDmgPct: 40, chaBonus: 1,
  ),
  Subclass(
    id: 'guardian', name: 'Oath of the Guardian', classRequired: DndClass.paladin,
    flavor: 'A living bulwark that shields and sustains.',
    effect: SubclassEffect.none, effectLabel: 'Guardian\'s aegis',
    armorPct: 30, healPct: 20, conBonus: 2,
  ),
  Subclass(
    id: 'open_sea', name: 'Oath of the Open Sea', classRequired: DndClass.paladin,
    flavor: 'Free as the tide, you flow past every guard.',
    effect: SubclassEffect.none, effectLabel: 'Fury of the tides',
    dmgPct: 18, dodgePct: 10, dexBonus: 1, chaBonus: 1,
  ),

  // ── RANGER (physical / poison / cold) ───────────────────────────
  Subclass(
    id: 'hunter', name: 'Hunter', classRequired: DndClass.ranger,
    flavor: 'You are the apex predator. Everything else is prey.',
    effect: SubclassEffect.hunter,
    effectLabel: '+20% damage on every attack',
    dmgPct: 15, strBonus: 2, dexBonus: 1,
  ),
  Subclass(
    id: 'beast_master', name: 'Beast Master', classRequired: DndClass.ranger,
    flavor: "Nature's bounty flows through the bond with your companions.",
    effect: SubclassEffect.beastMaster,
    effectLabel: 'Companion\'s bounty',
    xpPct: 25, goldPct: 20, wisBonus: 2,
  ),
  Subclass(
    id: 'gloom_stalker', name: 'Gloom Stalker', classRequired: DndClass.ranger,
    flavor: 'You strike from the dark before the enemy even sees you.',
    effect: SubclassEffect.none, effectLabel: 'Dread ambusher',
    elemType: DamageType.void_, elemDmgPct: 30, critChancePct: 10, dexBonus: 2,
  ),
  Subclass(
    id: 'fey_wanderer', name: 'Fey Wanderer', classRequired: DndClass.ranger,
    flavor: 'Fey magic lends charm to your blade and balm to your wounds.',
    effect: SubclassEffect.none, effectLabel: 'Otherworldly glamour',
    dmgPct: 18, healPct: 15, wisBonus: 1, chaBonus: 1,
  ),
  Subclass(
    id: 'horizon_walker', name: 'Horizon Walker', classRequired: DndClass.ranger,
    flavor: 'You walk between worlds, striking with planar force.',
    effect: SubclassEffect.none, effectLabel: 'Planar warrior',
    dmgPct: 30, dexBonus: 2,
  ),
  Subclass(
    id: 'swarmkeeper', name: 'Swarmkeeper', classRequired: DndClass.ranger,
    flavor: 'A swarm of stinging creatures poisons and harries your foes.',
    effect: SubclassEffect.none, effectLabel: 'Gathered swarm',
    elemType: DamageType.poison, elemDmgPct: 40, dotPct: 25, wisBonus: 1,
  ),
  Subclass(
    id: 'monster_slayer', name: 'Monster Slayer', classRequired: DndClass.ranger,
    flavor: 'You know exactly where to strike to end a monster.',
    effect: SubclassEffect.none, effectLabel: "Slayer's prey",
    critDmgPct: 35, dmgPct: 12, dexBonus: 1, wisBonus: 1,
  ),
  Subclass(
    id: 'drakewarden', name: 'Drakewarden', classRequired: DndClass.ranger,
    flavor: 'Your drake companion breathes searing fire on your command.',
    effect: SubclassEffect.none, effectLabel: 'Drake\'s breath',
    elemType: DamageType.fire, elemDmgPct: 40, wisBonus: 1,
  ),
  Subclass(
    id: 'winter_walker', name: 'Winter Walker', classRequired: DndClass.ranger,
    flavor: 'The killing cold of the deep winter follows your every step.',
    effect: SubclassEffect.none, effectLabel: 'Frigid winds',
    elemType: DamageType.cold, elemDmgPct: 45, dexBonus: 1,
  ),
  Subclass(
    id: 'scout_ranger', name: 'Scout', classRequired: DndClass.ranger,
    flavor: 'Swift and elusive, you dart in and out before they can react.',
    effect: SubclassEffect.none, effectLabel: 'Skirmisher',
    dodgePct: 15, dmgPct: 15, dexBonus: 2,
  ),
  Subclass(
    id: 'primeval_guardian', name: 'Primeval Guardian', classRequired: DndClass.ranger,
    flavor: 'You take on the form of an ancient guardian tree — vast and unyielding.',
    effect: SubclassEffect.none, effectLabel: 'Guardian soul',
    hpPct: 25, armorPct: 25, conBonus: 2,
  ),
  Subclass(
    id: 'hollow_warden', name: 'Hollow Warden', classRequired: DndClass.ranger,
    flavor: 'A hollow husk animated by fungal rot, draining all it touches.',
    effect: SubclassEffect.none, effectLabel: 'Fungal rot',
    elemType: DamageType.poison, elemDmgPct: 35, lifestealPct: 10, wisBonus: 1,
  ),
  Subclass(
    id: 'trail_warden', name: 'Trail Warden', classRequired: DndClass.ranger,
    flavor: 'Keeper of the wild paths, mending those who walk them.',
    effect: SubclassEffect.none, effectLabel: 'Warden\'s care',
    healPct: 25, hpPct: 15, wisBonus: 2,
  ),

  // ── ROGUE (physical / poison / void) ────────────────────────────
  Subclass(
    id: 'assassin', name: 'Assassin', classRequired: DndClass.rogue,
    flavor: 'The critical strike is not a lucky blow — it is the only blow.',
    effect: SubclassEffect.assassin,
    effectLabel: 'Critical hits deal triple damage',
    critChancePct: 12, dexBonus: 2, strBonus: 1,
  ),
  Subclass(
    id: 'arcane_trickster', name: 'Arcane Trickster', classRequired: DndClass.rogue,
    flavor: 'Magic accelerates every trick. Abilities return almost before the echo fades.',
    effect: SubclassEffect.arcaneTrickster,
    effectLabel: '-1 to all ability cooldowns',
    abilityPowerPct: 20, intBonus: 1, dexBonus: 1,
  ),
  Subclass(
    id: 'thief', name: 'Thief', classRequired: DndClass.rogue,
    flavor: 'Fast hands and faster feet — nothing of value escapes you.',
    effect: SubclassEffect.none, effectLabel: 'Fast hands',
    goldPct: 25, dodgePct: 10, dexBonus: 2,
  ),
  Subclass(
    id: 'swashbuckler', name: 'Swashbuckler', classRequired: DndClass.rogue,
    flavor: 'Dashing, daring, and deadly with a rapier\'s flourish.',
    effect: SubclassEffect.none, effectLabel: 'Rakish audacity',
    critChancePct: 15, dodgePct: 10, dexBonus: 1, chaBonus: 1,
  ),
  Subclass(
    id: 'phantom', name: 'Phantom', classRequired: DndClass.rogue,
    flavor: 'You walk with the dead, draining souls to sustain your own.',
    effect: SubclassEffect.none, effectLabel: 'Wails from the grave',
    elemType: DamageType.void_, elemDmgPct: 35, lifestealPct: 10, dexBonus: 1,
  ),
  Subclass(
    id: 'soulknife', name: 'Soulknife', classRequired: DndClass.rogue,
    flavor: 'Blades of pure psychic force cut where no armour can guard.',
    effect: SubclassEffect.none, effectLabel: 'Psychic blades',
    elemType: DamageType.void_, elemDmgPct: 30, critChancePct: 10, intBonus: 1, dexBonus: 1,
  ),
  Subclass(
    id: 'scout_rogue', name: 'Scout', classRequired: DndClass.rogue,
    flavor: 'Always one step ahead, always out of reach.',
    effect: SubclassEffect.none, effectLabel: 'Skirmisher',
    dodgePct: 15, dmgPct: 15, dexBonus: 2,
  ),
  Subclass(
    id: 'mastermind', name: 'Mastermind', classRequired: DndClass.rogue,
    flavor: 'Every scheme profits you — knowledge and coin alike.',
    effect: SubclassEffect.none, effectLabel: 'Master of tactics',
    xpPct: 25, goldPct: 15, intBonus: 1, chaBonus: 1,
  ),
  Subclass(
    id: 'inquisitive', name: 'Inquisitive', classRequired: DndClass.rogue,
    flavor: 'You read every tell and strike the exact weak point.',
    effect: SubclassEffect.none, effectLabel: 'Insightful fighting',
    critDmgPct: 35, dmgPct: 10, wisBonus: 1, dexBonus: 1,
  ),
  Subclass(
    id: 'poisoner_rogue', name: 'Poisoner', classRequired: DndClass.rogue,
    flavor: 'A single coated blade spells a slow, certain death.',
    effect: SubclassEffect.none, effectLabel: 'Deadly toxins',
    elemType: DamageType.poison, elemDmgPct: 40, dotPct: 25, dexBonus: 1,
  ),
  Subclass(
    id: 'gambler', name: 'Gambler', classRequired: DndClass.rogue,
    flavor: 'Fortune favours you — the dice always land your way.',
    effect: SubclassEffect.none, effectLabel: "Lady luck's favour",
    critChancePct: 18, chaBonus: 1, dexBonus: 1,
  ),
  Subclass(
    id: 'acrobat', name: 'Acrobat', classRequired: DndClass.rogue,
    flavor: 'A whirl of impossible tumbles — good luck landing a hit.',
    effect: SubclassEffect.none, effectLabel: 'Tumbler',
    dodgePct: 18, dmgPct: 10, dexBonus: 2,
  ),
  Subclass(
    id: 'misfortune_bringer', name: 'Misfortune Bringer', classRequired: DndClass.rogue,
    flavor: 'Bad luck clings to your foes like a curse.',
    effect: SubclassEffect.none, effectLabel: 'Unlucky',
    elemType: DamageType.void_, elemDmgPct: 35, dmgPct: 10, chaBonus: 1,
  ),
  Subclass(
    id: 'shadow_stalker', name: 'Shadow Stalker', classRequired: DndClass.rogue,
    flavor: 'You become one with the shadows and strike from nowhere.',
    effect: SubclassEffect.none, effectLabel: 'Shadow strike',
    critChancePct: 12, dmgPct: 18, dexBonus: 2,
  ),

  // ── SORCERER (all elements — elemental caster) ──────────────────
  Subclass(
    id: 'wild_magic', name: 'Wild Magic', classRequired: DndClass.sorcerer,
    flavor: 'Magic does not obey you — it erupts through you. Chaos is a weapon.',
    effect: SubclassEffect.wildMagic,
    effectLabel: '15% chance any hit deals triple damage',
    dmgPct: 15, chaBonus: 1, conBonus: 1,
  ),
  Subclass(
    id: 'draconic', name: 'Draconic Bloodline', classRequired: DndClass.sorcerer,
    flavor: 'Dragon blood runs through your veins — and so does their terrible resilience.',
    effect: SubclassEffect.draconic,
    effectLabel: 'Draconic resilience',
    hpPct: 25, dmgPct: 12, conBonus: 3, strBonus: 1,
  ),
  Subclass(
    id: 'aberrant_mind', name: 'Aberrant Mind', classRequired: DndClass.sorcerer,
    flavor: 'An alien intelligence twists your magic into psychic horror.',
    effect: SubclassEffect.none, effectLabel: 'Psionic sorcery',
    elemType: DamageType.void_, elemDmgPct: 40, abilityPowerPct: 12, intBonus: 1, chaBonus: 1,
  ),
  Subclass(
    id: 'blood_sorcery', name: 'Blood Sorcery', classRequired: DndClass.sorcerer,
    flavor: 'You bleed your magic — and drink the blood of your foes.',
    effect: SubclassEffect.none, effectLabel: 'Blood magic',
    dmgPct: 22, lifestealPct: 15, conBonus: 1,
  ),
  Subclass(
    id: 'clockwork_soul', name: 'Clockwork Soul', classRequired: DndClass.sorcerer,
    flavor: 'The order of Mechanus steadies your spells and your body.',
    effect: SubclassEffect.none, effectLabel: 'Restore balance',
    abilityPowerPct: 25, hpPct: 15, intBonus: 1, chaBonus: 1,
  ),
  Subclass(
    id: 'divine_soul', name: 'Divine Soul', classRequired: DndClass.sorcerer,
    flavor: 'A divine spark grants you the power to mend as well as burn.',
    effect: SubclassEffect.none, effectLabel: 'Favored by the gods',
    healPct: 35, hpPct: 12, chaBonus: 1, wisBonus: 1,
  ),
  Subclass(
    id: 'elementalist_sorc', name: 'Elementalist', classRequired: DndClass.sorcerer,
    flavor: 'You bend all the raw elements to your unrelenting will.',
    effect: SubclassEffect.none, effectLabel: 'Elemental mastery',
    dmgPct: 30, chaBonus: 2,
  ),
  Subclass(
    id: 'lunar_sorcery', name: 'Lunar Sorcery', classRequired: DndClass.sorcerer,
    flavor: 'The cold light of the moon freezes all it touches.',
    effect: SubclassEffect.none, effectLabel: 'Lunar embodiment',
    elemType: DamageType.cold, elemDmgPct: 45, chaBonus: 1,
  ),
  Subclass(
    id: 'phoenix_sorcery', name: 'Phoenix Sorcery', classRequired: DndClass.sorcerer,
    flavor: 'The undying flame of the phoenix consumes your enemies.',
    effect: SubclassEffect.none, effectLabel: 'Mantle of flame',
    elemType: DamageType.fire, elemDmgPct: 45, chaBonus: 1,
  ),
  Subclass(
    id: 'shadow_magic_sorc', name: 'Shadow Magic', classRequired: DndClass.sorcerer,
    flavor: 'Born of the Shadowfell, your magic drips with the void.',
    effect: SubclassEffect.none, effectLabel: 'Eyes of the dark',
    elemType: DamageType.void_, elemDmgPct: 45, chaBonus: 1,
  ),
  Subclass(
    id: 'storm_sorcery', name: 'Storm Sorcery', classRequired: DndClass.sorcerer,
    flavor: 'The tempest lives in you — lightning answers your every word.',
    effect: SubclassEffect.none, effectLabel: 'Heart of the storm',
    elemType: DamageType.lightning, elemDmgPct: 45, chaBonus: 1,
  ),
  Subclass(
    id: 'stone_sorcery', name: 'Stone Sorcery', classRequired: DndClass.sorcerer,
    flavor: 'Your skin turns to living stone, deflecting all harm.',
    effect: SubclassEffect.none, effectLabel: 'Stone\'s endurance',
    armorPct: 40, dmgPct: 12, conBonus: 2,
  ),
  Subclass(
    id: 'runechild', name: 'Runechild', classRequired: DndClass.sorcerer,
    flavor: 'Glowing runes across your skin amplify every spell.',
    effect: SubclassEffect.none, effectLabel: 'Essence runes',
    abilityPowerPct: 30, intBonus: 2,
  ),
  Subclass(
    id: 'seer', name: 'Seer', classRequired: DndClass.sorcerer,
    flavor: 'You glimpse the future and strike where it will hurt most.',
    effect: SubclassEffect.none, effectLabel: 'Foresight',
    critChancePct: 12, xpPct: 20, intBonus: 1, chaBonus: 1,
  ),
  Subclass(
    id: 'hungering_dark', name: 'Hungering Dark', classRequired: DndClass.sorcerer,
    flavor: 'An endless void hungers within you, devouring all light and life.',
    effect: SubclassEffect.none, effectLabel: 'Devouring void',
    elemType: DamageType.void_, elemDmgPct: 35, lifestealPct: 12, chaBonus: 1,
  ),
  Subclass(
    id: 'spellfire', name: 'Spellfire Sorcery', classRequired: DndClass.sorcerer,
    flavor: 'The legendary spellfire burns through you — and everything else.',
    effect: SubclassEffect.none, effectLabel: 'Spellfire',
    elemType: DamageType.fire, elemDmgPct: 40, abilityPowerPct: 12, chaBonus: 1,
  ),

  // ── WARLOCK (void / fire / cold / physical) ─────────────────────
  Subclass(
    id: 'great_old_one', name: 'Great Old One', classRequired: DndClass.warlock,
    flavor: 'The thing beyond the void amplifies your pact with incomprehensible power.',
    effect: SubclassEffect.greatOldOne,
    effectLabel: '+25% to all ability effects',
    elemType: DamageType.void_, elemDmgPct: 20, chaBonus: 1, intBonus: 1,
  ),
  Subclass(
    id: 'fiend_pact', name: 'The Fiend', classRequired: DndClass.warlock,
    flavor: 'The fiend demands blood — and returns life in kind. Every wound feeds you.',
    effect: SubclassEffect.fiendPact,
    effectLabel: 'Lifesteal: recover 20% of damage dealt',
    elemType: DamageType.fire, elemDmgPct: 25, chaBonus: 2, strBonus: 1,
  ),
  Subclass(
    id: 'archfey', name: 'The Archfey', classRequired: DndClass.warlock,
    flavor: 'Fey magic beguiles and chills — foes lose their way and their warmth.',
    effect: SubclassEffect.none, effectLabel: 'Fey presence',
    elemType: DamageType.cold, elemDmgPct: 35, dodgePct: 10, chaBonus: 1,
  ),
  Subclass(
    id: 'celestial', name: 'The Celestial', classRequired: DndClass.warlock,
    flavor: 'A radiant patron grants you fire to burn and light to heal.',
    effect: SubclassEffect.none, effectLabel: 'Healing light',
    healPct: 30, elemType: DamageType.fire, elemDmgPct: 20, chaBonus: 1, wisBonus: 1,
  ),
  Subclass(
    id: 'hexblade', name: 'Hexblade', classRequired: DndClass.warlock,
    flavor: 'A cursed blade strikes with malevolent, unerring force.',
    effect: SubclassEffect.none, effectLabel: "Hexblade's curse",
    dmgPct: 25, critChancePct: 12, chaBonus: 1, strBonus: 1,
  ),
  Subclass(
    id: 'undying', name: 'The Undying', classRequired: DndClass.warlock,
    flavor: 'Your deathless patron shares its refusal to die.',
    effect: SubclassEffect.none, effectLabel: 'Among the dead',
    hpPct: 25, lifestealPct: 10, conBonus: 1, chaBonus: 1,
  ),
  Subclass(
    id: 'undead_patron', name: 'The Undead', classRequired: DndClass.warlock,
    flavor: 'A lich\'s power flows through you — necrotic and life-draining.',
    effect: SubclassEffect.none, effectLabel: 'Form of dread',
    elemType: DamageType.void_, elemDmgPct: 35, lifestealPct: 12, chaBonus: 1,
  ),
  Subclass(
    id: 'genie', name: 'The Genie', classRequired: DndClass.warlock,
    flavor: 'A noble genie lends you its vast elemental might.',
    effect: SubclassEffect.none, effectLabel: "Genie's wrath",
    abilityPowerPct: 30, chaBonus: 2,
  ),
  Subclass(
    id: 'fathomless', name: 'The Fathomless', classRequired: DndClass.warlock,
    flavor: 'The crushing cold of the deep answers your call.',
    effect: SubclassEffect.none, effectLabel: 'Tentacle of the deeps',
    elemType: DamageType.cold, elemDmgPct: 45, chaBonus: 1,
  ),
  Subclass(
    id: 'raven_queen', name: 'The Raven Queen', classRequired: DndClass.warlock,
    flavor: 'The queen of death guides your strikes to their fated end.',
    effect: SubclassEffect.none, effectLabel: 'Sentinel raven',
    elemType: DamageType.void_, elemDmgPct: 30, critChancePct: 10, chaBonus: 1,
  ),
  Subclass(
    id: 'pale_master', name: 'Pale Master', classRequired: DndClass.warlock,
    flavor: 'Undeath armours your flesh and rots your enemies.',
    effect: SubclassEffect.none, effectLabel: 'Deathless flesh',
    elemType: DamageType.void_, elemDmgPct: 30, hpPct: 15, conBonus: 1, chaBonus: 1,
  ),
  Subclass(
    id: 'sorcerer_king', name: 'The Sorcerer-King', classRequired: DndClass.warlock,
    flavor: 'A tyrant-mage\'s dominion swells your every spell and strike.',
    effect: SubclassEffect.none, effectLabel: 'Tyrant\'s dominion',
    abilityPowerPct: 20, dmgPct: 15, chaBonus: 1, intBonus: 1,
  ),
  Subclass(
    id: 'witch_warlock', name: 'The Witch', classRequired: DndClass.warlock,
    flavor: 'Hexes and curses seep poison into your enemies\' veins.',
    effect: SubclassEffect.none, effectLabel: 'Wicked hex',
    elemType: DamageType.poison, elemDmgPct: 40, dotPct: 25, chaBonus: 1,
  ),
  Subclass(
    id: 'lurker', name: 'The Lurker in the Deep', classRequired: DndClass.warlock,
    flavor: 'A thing that waits in the black — unseen until it strikes.',
    effect: SubclassEffect.none, effectLabel: 'From the depths',
    elemType: DamageType.void_, elemDmgPct: 30, dodgePct: 12, chaBonus: 1,
  ),

  // ── WIZARD (all schools — the arcane specialist) ────────────────
  Subclass(
    id: 'evoker', name: 'School of Evocation', classRequired: DndClass.wizard,
    flavor: 'Pure evocation magic. No subtlety, no nuance — only force.',
    effect: SubclassEffect.evoker,
    effectLabel: '+35% to all ability effects',
    dmgPct: 15, intBonus: 2, wisBonus: 1,
  ),
  Subclass(
    id: 'abjurer', name: 'School of Abjuration', classRequired: DndClass.wizard,
    flavor: 'Ward and counter. The best offence is an impenetrable defence.',
    effect: SubclassEffect.abjurer,
    effectLabel: 'Arcane ward — +15% healing',
    hpPct: 15, armorPct: 20, conBonus: 1, dexBonus: 1, intBonus: 1,
  ),
  Subclass(
    id: 'conjurer', name: 'School of Conjuration', classRequired: DndClass.wizard,
    flavor: 'You summon force from nothing — endless and overwhelming.',
    effect: SubclassEffect.none, effectLabel: 'Benign transposition',
    abilityPowerPct: 30, intBonus: 2,
  ),
  Subclass(
    id: 'diviner', name: 'School of Divination', classRequired: DndClass.wizard,
    flavor: 'You see the threads of fate and pull them to your advantage.',
    effect: SubclassEffect.none, effectLabel: 'Portent',
    critChancePct: 12, xpPct: 20, intBonus: 2,
  ),
  Subclass(
    id: 'enchanter', name: 'School of Enchantment', classRequired: DndClass.wizard,
    flavor: 'Bend minds to your will — foes forget how to land a blow.',
    effect: SubclassEffect.none, effectLabel: 'Hypnotic gaze',
    dodgePct: 12, abilityPowerPct: 15, intBonus: 1, chaBonus: 1,
  ),
  Subclass(
    id: 'illusionist', name: 'School of Illusion', classRequired: DndClass.wizard,
    flavor: 'Nothing is as it seems — least of all where you are standing.',
    effect: SubclassEffect.none, effectLabel: 'Malleable illusions',
    dodgePct: 18, dmgPct: 10, intBonus: 2,
  ),
  Subclass(
    id: 'necromancer', name: 'School of Necromancy', classRequired: DndClass.wizard,
    flavor: 'Command the boundary of life and death — and drain both.',
    effect: SubclassEffect.none, effectLabel: 'Grim harvest',
    elemType: DamageType.void_, elemDmgPct: 45, lifestealPct: 10, intBonus: 1,
  ),
  Subclass(
    id: 'transmuter', name: 'School of Transmutation', classRequired: DndClass.wizard,
    flavor: 'Reshape reality itself — flesh, stone, and force alike.',
    effect: SubclassEffect.none, effectLabel: "Transmuter's stone",
    dmgPct: 18, hpPct: 15, intBonus: 2,
  ),
  Subclass(
    id: 'bladesinger', name: 'Bladesinging', classRequired: DndClass.wizard,
    flavor: 'A deadly dance of sword and spell, elegant and lethal.',
    effect: SubclassEffect.none, effectLabel: 'Bladesong',
    dmgPct: 25, dodgePct: 10, intBonus: 1, dexBonus: 1,
  ),
  Subclass(
    id: 'war_magic_wiz', name: 'War Magic', classRequired: DndClass.wizard,
    flavor: 'Offence and defence woven into a single unbreakable art.',
    effect: SubclassEffect.none, effectLabel: 'Arcane deflection',
    abilityPowerPct: 25, dmgPct: 12, intBonus: 2,
  ),
  Subclass(
    id: 'chronurgy', name: 'Chronurgy Magic', classRequired: DndClass.wizard,
    flavor: 'You bend time itself, casting faster than thought.',
    effect: SubclassEffect.none, effectLabel: 'Temporal awareness',
    abilityPowerPct: 28, intBonus: 2,
  ),
  Subclass(
    id: 'graviturgy', name: 'Graviturgy Magic', classRequired: DndClass.wizard,
    flavor: 'Crushing gravity warps and shatters all within reach.',
    effect: SubclassEffect.none, effectLabel: 'Gravity well',
    elemType: DamageType.void_, elemDmgPct: 40, intBonus: 1,
  ),
  Subclass(
    id: 'order_of_scribes', name: 'Order of Scribes', classRequired: DndClass.wizard,
    flavor: 'Your living spellbook whispers secrets that speed your growth.',
    effect: SubclassEffect.none, effectLabel: 'Awakened spellbook',
    xpPct: 25, abilityPowerPct: 15, intBonus: 2,
  ),
  Subclass(
    id: 'pyromancer_wiz', name: 'Pyromancer', classRequired: DndClass.wizard,
    flavor: 'Fire answers your call in a roaring, all-consuming blaze.',
    effect: SubclassEffect.none, effectLabel: 'Pyromancy',
    elemType: DamageType.fire, elemDmgPct: 50, intBonus: 1,
  ),
  Subclass(
    id: 'elementalist_wiz', name: 'Elementalist', classRequired: DndClass.wizard,
    flavor: 'Master of every element — fire, frost, storm, and stone.',
    effect: SubclassEffect.none, effectLabel: 'Elemental mastery',
    dmgPct: 30, intBonus: 2,
  ),
  Subclass(
    id: 'shadowmage', name: 'Shadow Magic', classRequired: DndClass.wizard,
    flavor: 'You weave the void into blades of pure darkness.',
    effect: SubclassEffect.none, effectLabel: 'Shadow weave',
    elemType: DamageType.void_, elemDmgPct: 45, intBonus: 1,
  ),
  Subclass(
    id: 'blood_magic_wiz', name: 'Blood Magic', classRequired: DndClass.wizard,
    flavor: 'Forbidden blood magic drains vitality from all you strike.',
    effect: SubclassEffect.none, effectLabel: 'Sanguine mastery',
    dmgPct: 20, lifestealPct: 15, conBonus: 1, intBonus: 1,
  ),
  Subclass(
    id: 'witchcraft_wiz', name: 'Witchcraft', classRequired: DndClass.wizard,
    flavor: 'Hexes and curses rot your enemies from within.',
    effect: SubclassEffect.none, effectLabel: 'Cursing hex',
    elemType: DamageType.poison, elemDmgPct: 40, dotPct: 25, intBonus: 1,
  ),
];

List<Subclass> subclassesForClass(DndClass heroClass) =>
    kSubclassCatalog.where((s) => s.classRequired == heroClass).toList();

Subclass? subclassById(String id) {
  try {
    return kSubclassCatalog.firstWhere((s) => s.id == id);
  } catch (_) {
    return null;
  }
}
