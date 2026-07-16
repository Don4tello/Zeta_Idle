import 'damage_type.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Passive Skill Tree — 5 branches × 6 multi-rank nodes.
// Each node supports up to 5 ranks. Upgrade cost scales per rank.
// Prerequisite: previous node in branch must be rank ≥ 1.
// Ascendant branch unlocks when 4+ nodes are unlocked in other branches.
// ─────────────────────────────────────────────────────────────────────────────

enum PassiveBranch {
  slayer,       // ⚔  combat offense
  guardian,     // 🛡  combat defense
  merchant,     // 💰  economy
  mystic,       // ✨  abilities & essence
  elementalist, // 🜂  elemental damage & resistances
  ascendant,    // ⭐  cross-branch mastery (unlocks late)
}

enum PassiveEffect {
  attackFlat,    // +N critical damage
  damageFlat,    // +N flat damage
  critChance,    // +N% crit chance
  pierce,        // ignore N enemy AC
  allDamage,     // +N% to ALL damage dealt
  maxHp,         // +N% max HP
  regenFlat,     // regen N HP per round
  armorFlat,     // +N flat AC
  dodgeChance,   // +N% chance to dodge hits
  goldFlat,      // +N% gold from kills
  shardFlat,     // +N shard per kill
  xpFlat,        // +N% XP from kills
  idleFlat,      // +N to idle rate
  cooldownReduce,// -N rounds to all ability cooldowns
  abilityDamage, // +N% to ability damage
  healBoost,     // +N% to heal abilities
  essenceGain,   // +N% essence from kills
  allPenetration,// +N% elemental resistance penetration
  // ── Elemental damage ──
  fireDamage,       // +N% fire damage
  coldDamage,       // +N% cold damage
  lightningDamage,  // +N% lightning damage
  poisonDamage,     // +N% poison damage
  voidDamage,       // +N% void damage
  // ── Elemental resistance ──
  fireRes,          // +N% fire resistance
  coldRes,          // +N% cold resistance
  lightningRes,     // +N% lightning resistance
  poisonRes,        // +N% poison resistance
  voidRes,          // +N% void resistance
  allRes,           // +N% to ALL elemental resistances
}

class PassiveNode {
  const PassiveNode({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.branch,
    required this.tier,
    required this.essenceCost,
    required this.effect,
    required this.value,
    this.maxRank = 5,
    this.unlockRequires = 0,
    this.isKeystone = false,
    this.keystoneDesc,
    this.isConnector = false,
    this.requiresBranches = const [],
    this.classOnly,
  });

  final String id;
  final String name;
  final String emoji;
  final String description; // should include "per rank"
  final PassiveBranch branch;
  final int tier;           // 0 = first in branch, 5 = last
  final int essenceCost;    // base cost for rank 1; rank N costs baseCost × N × 1.5
  final PassiveEffect effect;
  final int value;          // magnitude per rank
  final int maxRank;
  final int unlockRequires; // min total unlocks in other branches (Ascendant only)
  final bool isKeystone;
  final String? keystoneDesc; // flavor text for keystone effect
  final bool isConnector;
  final List<PassiveBranch> requiresBranches; // connector: need rank 1+ in these branches
  final String? classOnly; // DndClass.name — only visible for this class

  String get fullDescription => '${_sign}${value * maxRank}${_suffix} at max rank';

  String get _sign => switch (effect) {
    PassiveEffect.cooldownReduce => '−',
    _ => '+',
  };

  String get _suffix => switch (effect) {
    PassiveEffect.attackFlat  || PassiveEffect.damageFlat ||
    PassiveEffect.armorFlat   || PassiveEffect.shardFlat  ||
    PassiveEffect.idleFlat    || PassiveEffect.pierce     ||
    PassiveEffect.regenFlat   || PassiveEffect.cooldownReduce => '',
    _ => '%',
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Node catalog
// ─────────────────────────────────────────────────────────────────────────────

const kPassiveNodes = <PassiveNode>[

  // ── ⚔ SLAYER — Offense ───────────────────────────────────────────────────
  PassiveNode(id: 'slayer_0', name: 'Keen Edge',      emoji: '🎯',
    branch: PassiveBranch.slayer,   tier: 0, essenceCost: 8,
    effect: PassiveEffect.critChance,    value: 2,
    description: '+2% crit chance per rank'),
  PassiveNode(id: 'slayer_1', name: 'Brute Force',    emoji: '⚡',
    branch: PassiveBranch.slayer,   tier: 1, essenceCost: 18,
    effect: PassiveEffect.damageFlat,    value: 2,
    description: '+2 flat damage per rank'),
  PassiveNode(id: 'slayer_2', name: 'Sure Strike',    emoji: '🗡',
    branch: PassiveBranch.slayer,   tier: 2, essenceCost: 35,
    effect: PassiveEffect.attackFlat,    value: 2,
    description: '+2 critical damage per rank'),
  PassiveNode(id: 'slayer_3', name: 'Executioner',    emoji: '💀',
    branch: PassiveBranch.slayer,   tier: 3, essenceCost: 70,
    effect: PassiveEffect.abilityDamage, value: 12,
    description: '+12% ability damage per rank'),
  PassiveNode(id: 'slayer_4', name: 'Piercing Veil',  emoji: '🔱',
    branch: PassiveBranch.slayer,   tier: 4, essenceCost: 130,
    effect: PassiveEffect.pierce,        value: 2,
    description: 'Ignore 2 enemy AC per rank'),
  PassiveNode(id: 'slayer_5', name: "Death's Touch",  emoji: '☠',
    branch: PassiveBranch.slayer,   tier: 5, essenceCost: 250,
    effect: PassiveEffect.allDamage,     value: 6,
    description: '+6% all damage per rank'),
  PassiveNode(id: 'slayer_6', name: 'Veil Ripper',   emoji: '🔥',
    branch: PassiveBranch.slayer,   tier: 6, essenceCost: 400,
    effect: PassiveEffect.allPenetration, value: 4,
    description: '+4% elemental penetration per rank'),

  // ── 🛡 GUARDIAN — Defense ─────────────────────────────────────────────────
  PassiveNode(id: 'guardian_0', name: 'Iron Skin',       emoji: '🛡',
    branch: PassiveBranch.guardian, tier: 0, essenceCost: 8,
    effect: PassiveEffect.maxHp,         value: 10,
    description: '+10% max HP per rank'),
  PassiveNode(id: 'guardian_1', name: 'Stone Guard',     emoji: '🪨',
    branch: PassiveBranch.guardian, tier: 1, essenceCost: 18,
    effect: PassiveEffect.armorFlat,     value: 2,
    description: '+2 flat armor per rank'),
  PassiveNode(id: 'guardian_2', name: 'Nimble Footing',  emoji: '💨',
    branch: PassiveBranch.guardian, tier: 2, essenceCost: 35,
    effect: PassiveEffect.dodgeChance,   value: 3,
    description: '+3% dodge chance per rank'),
  PassiveNode(id: 'guardian_3', name: 'Regenerator',     emoji: '❤',
    branch: PassiveBranch.guardian, tier: 3, essenceCost: 70,
    effect: PassiveEffect.regenFlat,     value: 3,
    description: '+3 HP regen per round, per rank'),
  PassiveNode(id: 'guardian_4', name: 'Iron Fortress',   emoji: '🏰',
    branch: PassiveBranch.guardian, tier: 4, essenceCost: 130,
    effect: PassiveEffect.maxHp,         value: 15,
    description: '+15% max HP per rank'),
  PassiveNode(id: 'guardian_5', name: 'Warding Shell',   emoji: '⚙',
    branch: PassiveBranch.guardian, tier: 5, essenceCost: 250,
    effect: PassiveEffect.allRes,        value: 3,
    description: '+3% all elemental resistances per rank'),

  // ── 💰 MERCHANT — Economy ─────────────────────────────────────────────────
  PassiveNode(id: 'merchant_0', name: 'Scavenger',    emoji: '💰',
    branch: PassiveBranch.merchant, tier: 0, essenceCost: 8,
    effect: PassiveEffect.goldFlat,      value: 12,
    description: '+12% gold per rank'),
  PassiveNode(id: 'merchant_1', name: 'Shard Seeker', emoji: '💎',
    branch: PassiveBranch.merchant, tier: 1, essenceCost: 18,
    effect: PassiveEffect.shardFlat,     value: 1,
    description: '+1 shard per kill, per rank'),
  PassiveNode(id: 'merchant_2', name: 'Scholar',      emoji: '📖',
    branch: PassiveBranch.merchant, tier: 2, essenceCost: 35,
    effect: PassiveEffect.xpFlat,        value: 15,
    description: '+15% XP per rank'),
  PassiveNode(id: 'merchant_3', name: 'Surveyor',     emoji: '⏳',
    branch: PassiveBranch.merchant, tier: 3, essenceCost: 70,
    effect: PassiveEffect.idleFlat,      value: 2,
    description: '+2 idle rate per rank'),
  PassiveNode(id: 'merchant_4', name: 'Plunderer',    emoji: '🏆',
    branch: PassiveBranch.merchant, tier: 4, essenceCost: 130,
    effect: PassiveEffect.goldFlat,      value: 20,
    description: '+20% gold per rank'),
  PassiveNode(id: 'merchant_5', name: 'Opulence',     emoji: '👑',
    branch: PassiveBranch.merchant, tier: 5, essenceCost: 250,
    effect: PassiveEffect.xpFlat,        value: 25,
    description: '+25% XP per rank'),

  // ── ✨ MYSTIC — Abilities & Essence ───────────────────────────────────────
  PassiveNode(id: 'mystic_0', name: 'Arcane Gathering', emoji: '🌀',
    branch: PassiveBranch.mystic,   tier: 0, essenceCost: 8,
    effect: PassiveEffect.essenceGain, value: 10,
    description: '+10% essence from kills per rank'),
  PassiveNode(id: 'mystic_1', name: 'Arcane Touch',  emoji: '✨',
    branch: PassiveBranch.mystic,   tier: 1, essenceCost: 18,
    effect: PassiveEffect.abilityDamage, value: 15,
    description: '+15% ability damage per rank'),
  PassiveNode(id: 'mystic_2', name: 'Life Weave',    emoji: '🌿',
    branch: PassiveBranch.mystic,   tier: 2, essenceCost: 35,
    effect: PassiveEffect.healBoost,     value: 20,
    description: '+20% heal effectiveness per rank'),
  PassiveNode(id: 'mystic_3', name: 'Essence Draw',  emoji: '🔮',
    branch: PassiveBranch.mystic,   tier: 3, essenceCost: 70,
    effect: PassiveEffect.essenceGain,   value: 12,
    description: '+12% essence from kills per rank'),
  PassiveNode(id: 'mystic_4', name: 'Chain Cast',    emoji: '⚗',
    branch: PassiveBranch.mystic,   tier: 4, essenceCost: 130,
    effect: PassiveEffect.abilityDamage, value: 20,
    description: '+20% ability damage per rank'),
  PassiveNode(id: 'mystic_5', name: 'Transcendence', emoji: '🌟',
    branch: PassiveBranch.mystic,   tier: 5, essenceCost: 250,
    effect: PassiveEffect.abilityDamage, value: 25,
    description: '+25% ability damage per rank'),

  // ── 🜂 ELEMENTALIST — generated dynamically per class (see elementalistNodesFor)

  // ── ⭐ ASCENDANT — Unlock 1 point per branch with 25+ total ranks (max 5) ──
  PassiveNode(id: 'ascendant_0', name: "Warrior's Soul", emoji: '⚔',
    branch: PassiveBranch.ascendant, tier: 0, essenceCost: 100,
    effect: PassiveEffect.allDamage,     value: 5,
    unlockRequires: 1,
    description: '+5% all damage per rank'),
  PassiveNode(id: 'ascendant_1', name: "Fortune's Favor", emoji: '🌙',
    branch: PassiveBranch.ascendant, tier: 1, essenceCost: 200,
    effect: PassiveEffect.goldFlat,      value: 20,
    unlockRequires: 2,
    description: '+20% gold per rank'),
  PassiveNode(id: 'ascendant_2', name: 'Life Force',      emoji: '💖',
    branch: PassiveBranch.ascendant, tier: 2, essenceCost: 350,
    effect: PassiveEffect.maxHp,         value: 15,
    unlockRequires: 2,
    description: '+15% max HP per rank'),
  PassiveNode(id: 'ascendant_3', name: 'Power Surge',     emoji: '⭐',
    branch: PassiveBranch.ascendant, tier: 3, essenceCost: 550,
    effect: PassiveEffect.abilityDamage, value: 20,
    unlockRequires: 3,
    description: '+20% ability damage per rank'),
  PassiveNode(id: 'ascendant_4', name: 'Soul Harvest',    emoji: '🌌',
    branch: PassiveBranch.ascendant, tier: 4, essenceCost: 800,
    effect: PassiveEffect.essenceGain,   value: 25,
    unlockRequires: 4,
    description: '+25% essence per rank'),
  PassiveNode(id: 'ascendant_5', name: 'Convergence',     emoji: '🔆',
    branch: PassiveBranch.ascendant, tier: 5, essenceCost: 1200,
    effect: PassiveEffect.allDamage,     value: 8,
    unlockRequires: 5,
    description: '+8% all damage per rank'),

  // ── ⚔ KEYSTONE — SLAYER ──────────────────────────────────────────────────
  PassiveNode(id: 'slayer_key', name: 'Bloodlust', emoji: '🩸',
    branch: PassiveBranch.slayer, tier: 7, essenceCost: 800, maxRank: 1,
    effect: PassiveEffect.allDamage, value: 10, isKeystone: true,
    keystoneDesc: 'Kills grant a guaranteed crit on next attack',
    description: 'Kill = auto-crit next attack + 10% all damage'),

  // ── 🛡 KEYSTONE — GUARDIAN ────────────────────────────────────────────────
  PassiveNode(id: 'guardian_key', name: 'Unbreakable', emoji: '💠',
    branch: PassiveBranch.guardian, tier: 6, essenceCost: 800, maxRank: 1,
    effect: PassiveEffect.maxHp, value: 20, isKeystone: true,
    keystoneDesc: 'Survive a lethal hit once per battle (1 HP)',
    description: 'Survive lethal hit once + 20% max HP'),

  // ── 💰 KEYSTONE — MERCHANT ────────────────────────────────────────────────
  PassiveNode(id: 'merchant_key', name: 'Midas', emoji: '✦',
    branch: PassiveBranch.merchant, tier: 6, essenceCost: 800, maxRank: 1,
    effect: PassiveEffect.goldFlat, value: 50, isKeystone: true,
    keystoneDesc: 'Enemies drop 2× gold on crit kills',
    description: 'Crit kills = 2× gold + 50% gold'),

  // ── ✨ KEYSTONE — MYSTIC ──────────────────────────────────────────────────
  PassiveNode(id: 'mystic_key', name: 'Arcane Overflow', emoji: '🌀',
    branch: PassiveBranch.mystic, tier: 6, essenceCost: 800, maxRank: 1,
    effect: PassiveEffect.abilityDamage, value: 50, isKeystone: true,
    keystoneDesc: '15% chance abilities fire twice',
    description: '15% double-cast + 50% ability damage'),

  // ── 🜂 KEYSTONE — ELEMENTALIST ────────────────────────────────────────────
  PassiveNode(id: 'elementalist_key', name: 'Primordial Core', emoji: '🌋',
    branch: PassiveBranch.elementalist, tier: 7, essenceCost: 800, maxRank: 1,
    effect: PassiveEffect.allPenetration, value: 10, isKeystone: true,
    keystoneDesc: 'Elemental weakness hits deal 2× damage',
    description: 'Weakness = 2× damage + 10% pen'),

  // ── ⭐ KEYSTONE — ASCENDANT ───────────────────────────────────────────────
  PassiveNode(id: 'ascendant_key', name: 'Convergence Prime', emoji: '🔱',
    branch: PassiveBranch.ascendant, tier: 6, essenceCost: 1500, maxRank: 1,
    effect: PassiveEffect.allDamage, value: 15, isKeystone: true,
    unlockRequires: 5,
    keystoneDesc: 'All passive bonuses increased by 10%',
    description: '+10% to all passives + 15% all damage'),

  // ── CROSS-BRANCH CONNECTORS ───────────────────────────────────────────────
  PassiveNode(id: 'conn_warrior_mage', name: 'Battlemage', emoji: '⚔✨',
    branch: PassiveBranch.ascendant, tier: 0, essenceCost: 200, maxRank: 3,
    effect: PassiveEffect.abilityDamage, value: 10,
    isConnector: true, requiresBranches: [PassiveBranch.slayer, PassiveBranch.mystic],
    description: '+10% ability damage per rank (requires Slayer + Mystic)'),

  PassiveNode(id: 'conn_tank_healer', name: 'Paladin\'s Oath', emoji: '🛡✨',
    branch: PassiveBranch.ascendant, tier: 0, essenceCost: 200, maxRank: 3,
    effect: PassiveEffect.healBoost, value: 15,
    isConnector: true, requiresBranches: [PassiveBranch.guardian, PassiveBranch.mystic],
    description: '+15% heal per rank (requires Guardian + Mystic)'),

  PassiveNode(id: 'conn_offense_gold', name: 'War Profiteer', emoji: '⚔💰',
    branch: PassiveBranch.ascendant, tier: 0, essenceCost: 200, maxRank: 3,
    effect: PassiveEffect.goldFlat, value: 15,
    isConnector: true, requiresBranches: [PassiveBranch.slayer, PassiveBranch.merchant],
    description: '+15% gold per rank (requires Slayer + Merchant)'),

  PassiveNode(id: 'conn_elem_guard', name: 'Elemental Bulwark', emoji: '🜂🛡',
    branch: PassiveBranch.ascendant, tier: 0, essenceCost: 250, maxRank: 3,
    effect: PassiveEffect.allRes, value: 5,
    isConnector: true, requiresBranches: [PassiveBranch.elementalist, PassiveBranch.guardian],
    description: '+5% all res per rank (requires Elementalist + Guardian)'),

  PassiveNode(id: 'conn_mage_elem', name: 'Arcane Catalyst', emoji: '✨🜂',
    branch: PassiveBranch.ascendant, tier: 0, essenceCost: 300, maxRank: 3,
    effect: PassiveEffect.cooldownReduce, value: 1,
    isConnector: true, requiresBranches: [PassiveBranch.mystic, PassiveBranch.elementalist],
    description: '−1 cooldown per rank (requires Mystic + Elementalist)'),

  // ── CLASS-SPECIFIC NODES ──────────────────────────────────────────────────
  PassiveNode(id: 'class_barbarian', name: 'Frenzy', emoji: '🔥',
    branch: PassiveBranch.slayer, tier: 0, essenceCost: 150, maxRank: 3,
    effect: PassiveEffect.allDamage, value: 5, classOnly: 'barbarian',
    description: '+5% damage per kill this battle, per rank'),
  PassiveNode(id: 'class_fighter', name: 'Weapon Master', emoji: '⚔',
    branch: PassiveBranch.slayer, tier: 0, essenceCost: 150, maxRank: 3,
    effect: PassiveEffect.critChance, value: 4, classOnly: 'fighter',
    description: '+4% crit chance per rank'),
  PassiveNode(id: 'class_rogue', name: 'Shadow Step', emoji: '🗡',
    branch: PassiveBranch.slayer, tier: 0, essenceCost: 150, maxRank: 3,
    effect: PassiveEffect.dodgeChance, value: 5, classOnly: 'rogue',
    description: '+5% dodge chance per rank'),
  PassiveNode(id: 'class_ranger', name: 'Marksman', emoji: '🎯',
    branch: PassiveBranch.slayer, tier: 0, essenceCost: 150, maxRank: 3,
    effect: PassiveEffect.pierce, value: 3, classOnly: 'ranger',
    description: 'Ignore 3 enemy AC per rank'),
  PassiveNode(id: 'class_paladin', name: 'Holy Bastion', emoji: '✦',
    branch: PassiveBranch.guardian, tier: 0, essenceCost: 150, maxRank: 3,
    effect: PassiveEffect.healBoost, value: 15, classOnly: 'paladin',
    description: '+15% heal effectiveness per rank'),
  PassiveNode(id: 'class_cleric', name: 'Divine Grace', emoji: '❤',
    branch: PassiveBranch.guardian, tier: 0, essenceCost: 150, maxRank: 3,
    effect: PassiveEffect.regenFlat, value: 5, classOnly: 'cleric',
    description: '+5 HP regen per round, per rank'),
  PassiveNode(id: 'class_wizard', name: 'Spell Echo', emoji: '🌀',
    branch: PassiveBranch.mystic, tier: 0, essenceCost: 150, maxRank: 3,
    effect: PassiveEffect.abilityDamage, value: 12, classOnly: 'wizard',
    description: '+12% ability damage per rank + 5% double-cast'),
  PassiveNode(id: 'class_sorcerer', name: 'Wild Magic', emoji: '💥',
    branch: PassiveBranch.mystic, tier: 0, essenceCost: 150, maxRank: 3,
    effect: PassiveEffect.allDamage, value: 8, classOnly: 'sorcerer',
    description: '+8% all damage per rank (chaotic scaling)'),
  PassiveNode(id: 'class_warlock', name: 'Soul Siphon', emoji: '🌑',
    branch: PassiveBranch.mystic, tier: 0, essenceCost: 150, maxRank: 3,
    effect: PassiveEffect.essenceGain, value: 15, classOnly: 'warlock',
    description: '+15% essence gain per rank + lifesteal on DoTs'),
  PassiveNode(id: 'class_bard', name: 'Encore', emoji: '🎵',
    branch: PassiveBranch.mystic, tier: 0, essenceCost: 150, maxRank: 3,
    effect: PassiveEffect.cooldownReduce, value: 1, classOnly: 'bard',
    description: '−1 cooldown per rank on buff abilities'),
  PassiveNode(id: 'class_monk', name: 'Inner Peace', emoji: '☯',
    branch: PassiveBranch.guardian, tier: 0, essenceCost: 150, maxRank: 3,
    effect: PassiveEffect.dodgeChance, value: 4, classOnly: 'monk',
    description: '+4% dodge per rank + counter-attack on dodge'),
  PassiveNode(id: 'class_druid', name: 'Nature\'s Bond', emoji: '🌿',
    branch: PassiveBranch.guardian, tier: 0, essenceCost: 150, maxRank: 3,
    effect: PassiveEffect.regenFlat, value: 4, classOnly: 'druid',
    description: '+4 regen per rank + poison immunity'),
];

// ── Elementalist node generator (class-specific) ─────────────────────────────

const _elemInfo = <DamageType, (String, String, PassiveEffect, PassiveEffect)>{
  DamageType.physical:  ('Physical',  '⚔', PassiveEffect.allDamage,        PassiveEffect.armorFlat),
  DamageType.fire:      ('Fire',      '🔥', PassiveEffect.fireDamage,       PassiveEffect.fireRes),
  DamageType.cold:      ('Cold',      '❄', PassiveEffect.coldDamage,       PassiveEffect.coldRes),
  DamageType.lightning: ('Lightning', '⚡', PassiveEffect.lightningDamage, PassiveEffect.lightningRes),
  DamageType.poison:    ('Poison',    '☠', PassiveEffect.poisonDamage,    PassiveEffect.poisonRes),
  DamageType.void_:     ('Void',      '🌑', PassiveEffect.voidDamage,      PassiveEffect.voidRes),
};

List<PassiveNode> elementalistNodesFor(DamageType primary, DamageType secondary) {
  final p = _elemInfo[primary]!;
  final s = _elemInfo[secondary]!;
  final hasTwoTypes = primary != secondary;

  return [
    // Tier 0-1: Primary element damage + resistance
    PassiveNode(id: 'elem_0', name: '${p.$1} Affinity', emoji: p.$2,
      branch: PassiveBranch.elementalist, tier: 0, essenceCost: 10,
      effect: p.$3, value: 8,
      description: '+8% ${p.$1.toLowerCase()} damage per rank'),
    PassiveNode(id: 'elem_1', name: '${p.$1} Ward', emoji: '🛡',
      branch: PassiveBranch.elementalist, tier: 1, essenceCost: 20,
      effect: p.$4, value: 5,
      description: '+5% ${p.$1.toLowerCase()} resistance per rank'),
    // Tier 2-3: Secondary element damage + resistance
    PassiveNode(id: 'elem_2', name: hasTwoTypes ? '${s.$1} Affinity' : '${p.$1} Mastery', emoji: hasTwoTypes ? s.$2 : p.$2,
      branch: PassiveBranch.elementalist, tier: 2, essenceCost: 40,
      effect: hasTwoTypes ? s.$3 : p.$3, value: hasTwoTypes ? 8 : 12,
      description: hasTwoTypes ? '+8% ${s.$1.toLowerCase()} damage per rank' : '+12% ${p.$1.toLowerCase()} damage per rank'),
    PassiveNode(id: 'elem_3', name: hasTwoTypes ? '${s.$1} Ward' : '${p.$1} Shield', emoji: '🛡',
      branch: PassiveBranch.elementalist, tier: 3, essenceCost: 80,
      effect: hasTwoTypes ? s.$4 : p.$4, value: hasTwoTypes ? 5 : 8,
      description: hasTwoTypes ? '+5% ${s.$1.toLowerCase()} resistance per rank' : '+8% ${p.$1.toLowerCase()} resistance per rank'),
    // Tier 4: All resistance
    PassiveNode(id: 'elem_4', name: 'Elemental Aegis', emoji: '🛡',
      branch: PassiveBranch.elementalist, tier: 4, essenceCost: 150,
      effect: PassiveEffect.allRes, value: 4,
      description: '+4% all elemental resistances per rank'),
    // Tier 5: All penetration
    PassiveNode(id: 'elem_5', name: 'Primordial Fury', emoji: '🜂',
      branch: PassiveBranch.elementalist, tier: 5, essenceCost: 280,
      effect: PassiveEffect.allPenetration, value: 5,
      description: '+5% elemental penetration per rank'),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// PassiveTree — multi-rank state tracker
// ─────────────────────────────────────────────────────────────────────────────

class PassiveTree {
  PassiveTree();

  List<PassiveNode> _elemNodes = [];

  void setElementalistNodes(DamageType primary, DamageType secondary) {
    _elemNodes = elementalistNodesFor(primary, secondary);
  }

  List<PassiveNode> get allNodes => [...kPassiveNodes, ..._elemNodes];

  final Map<String, int> _ranks = {}; // nodeId → current rank (absent = 0)

  int rankOf(String id) => _ranks[id] ?? 0;

  bool isUnlocked(String id) => rankOf(id) >= 1;

  bool isMaxRank(String id) {
    final node = _nodeById(id);
    return rankOf(id) >= node.maxRank;
  }

  bool canUpgrade(String id) {
    final node = _nodeById(id);
    if (isMaxRank(id)) return false;

    // Connector nodes require ranks in all specified branches
    if (node.isConnector) {
      return node.requiresBranches.every((b) =>
          kPassiveNodes.any((n) => n.branch == b && isUnlocked(n.id)));
    }

    // Keystones require all previous tiers in branch maxed
    if (node.isKeystone) {
      final branchNodes = kPassiveNodes
          .where((n) => n.branch == node.branch && !n.isKeystone && !n.isConnector && n.classOnly == null)
          .toList();
      return branchNodes.every((n) => isMaxRank(n.id));
    }

    // Ascendant nodes unlock based on how many branches have reached 25+ total ranks
    if (node.branch == PassiveBranch.ascendant) {
      return ascendantUnlockPoints >= node.unlockRequires;
    }

    // All other nodes (including class-specific) have no prerequisites
    return true;
  }

  int costForNextRank(String id) {
    final node = _nodeById(id);
    final nextRank = rankOf(id) + 1;
    return (node.essenceCost * nextRank * 1.5).round().clamp(node.essenceCost, 9999999);
  }

  void upgrade(String id) {
    _ranks[id] = rankOf(id) + 1;
  }

  // Legacy alias kept for achievement checks
  bool canUnlock(String id) => canUpgrade(id);
  void unlock(String id) => upgrade(id);

  int get unlockedCount => _ranks.entries.where((e) => e.value >= 1).length;

  int totalOf(PassiveEffect effect) {
    var total = 0;
    for (final node in allNodes) {
      final r = rankOf(node.id);
      if (r >= 1 && node.effect == effect) total += node.value * r;
    }
    // Convergence Prime keystone: all passive bonuses +10%
    if (total > 0 && isUnlocked('ascendant_key')) return (total * 1.1).round();
    return total;
  }

  // Each non-Ascendant branch where ≥25 total ranks have been spent contributes 1 point (max 5).
  int get ascendantUnlockPoints {
    var points = 0;
    for (final branch in PassiveBranch.values) {
      if (branch == PassiveBranch.ascendant) continue;
      final total = allNodes
          .where((n) => n.branch == branch)
          .fold(0, (s, n) => s + rankOf(n.id));
      if (total >= 25) points++;
    }
    return points;
  }

  bool get ascendantBranchAvailable => ascendantUnlockPoints >= 1;

  // ── Node filtering ─────────────────────────────────────────────────────────

  static List<PassiveNode> nodesForClass(String className) =>
      kPassiveNodes.where((n) => n.classOnly == null || n.classOnly == className).toList();

  List<PassiveNode> nodesForBranch(PassiveBranch branch, {String? className}) =>
      kPassiveNodes.where((n) =>
          n.branch == branch &&
          (n.classOnly == null || n.classOnly == className) &&
          !n.isConnector).toList();

  static List<PassiveNode> get connectorNodes =>
      kPassiveNodes.where((n) => n.isConnector).toList();

  static List<PassiveNode> get keystoneNodes =>
      kPassiveNodes.where((n) => n.isKeystone).toList();

  bool hasKeystone(PassiveBranch branch) =>
      kPassiveNodes.any((n) => n.branch == branch && n.isKeystone && isUnlocked(n.id));

  // ── Respec ─────────────────────────────────────────────────────────────────

  int branchEssenceSpent(PassiveBranch branch) {
    var total = 0;
    for (final node in kPassiveNodes.where((n) => n.branch == branch)) {
      final r = rankOf(node.id);
      for (int i = 1; i <= r; i++) {
        total += (node.essenceCost * i * 1.5).round().clamp(node.essenceCost, 9999999);
      }
    }
    return total;
  }

  int respecBranchRefund(PassiveBranch branch) =>
      (branchEssenceSpent(branch) * 0.75).round();

  void respecBranch(PassiveBranch branch) {
    for (final node in kPassiveNodes.where((n) => n.branch == branch)) {
      _ranks.remove(node.id);
    }
  }

  int get totalEssenceSpent {
    var total = 0;
    for (final branch in PassiveBranch.values) {
      total += branchEssenceSpent(branch);
    }
    return total;
  }

  int get fullRespecRefund => (totalEssenceSpent * 0.60).round();

  void fullRespec() => _ranks.clear();

  int branchPointsSpent(PassiveBranch branch) =>
      kPassiveNodes.where((n) => n.branch == branch).fold(0, (s, n) => s + rankOf(n.id));

  // ── Persistence ────────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
    'ranks': Map<String, int>.from(_ranks),
  };

  void loadFromJson(Map<String, dynamic> json) {
    _ranks.clear();
    if (json['ranks'] is Map) {
      (json['ranks'] as Map).forEach((k, v) {
        if (k is String && v is int) _ranks[k] = v;
      });
      return;
    }
    // Legacy save: {unlocked: ['off_0', ...]} → treat each as rank 1, map old IDs
    if (json['unlocked'] is List) {
      for (final id in (json['unlocked'] as List).cast<String>()) {
        final mapped = _legacyIdMap[id];
        if (mapped != null) _ranks[mapped] = 1;
      }
    }
  }

  static const _legacyIdMap = <String, String>{
    'off_0': 'slayer_0',   'off_1': 'slayer_1',   'off_2': 'slayer_2',
    'off_3': 'slayer_3',   'off_4': 'slayer_4',   'off_5': 'slayer_5',
    'def_0': 'guardian_0', 'def_1': 'guardian_1', 'def_2': 'guardian_2',
    'def_3': 'guardian_3', 'def_4': 'guardian_4', 'def_5': 'guardian_5',
    'eco_0': 'merchant_0', 'eco_1': 'merchant_1', 'eco_2': 'merchant_2',
    'eco_3': 'merchant_3', 'eco_4': 'merchant_4', 'eco_5': 'merchant_5',
    'mas_0': 'mystic_0',   'mas_1': 'mystic_1',   'mas_2': 'mystic_2',
    'mas_3': 'mystic_3',   'mas_4': 'mystic_4',   'mas_5': 'mystic_5',
  };

  void reset() => _ranks.clear();

  // ── Helpers ─────────────────────────────────────────────────────────────────

  PassiveNode _nodeById(String id) =>
      allNodes.firstWhere((n) => n.id == id,
          orElse: () => throw StateError('Unknown passive node: $id'));
}
