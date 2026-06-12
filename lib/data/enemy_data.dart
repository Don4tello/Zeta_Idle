import 'dart:math';
import '../models/damage_type.dart';
import '../models/enemy.dart';
import '../models/zone_affix.dart';
import 'enemy_naming.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EnemyData — 25 hand-crafted campaign enemies plus infinite Abyss.
//
// Each enemy carries:
//   attackType   — the damage type of its attacks
//   resistances  — map of DamageType → int (% mitigation; negative = vulnerable)
//
// Resistance design rules:
//   • Undead resist cold/poison, weak to fire.
//   • Stone/Construct immune to poison, resist physical.
//   • Fire creatures immune or near-immune to fire, weak to cold.
//   • Magical aberrants resist arcane.
//   • Most early humanoids are neutral (all 0) so Physical is fine early.
//
// Resistance caps enforced in combat at 90% (can never be fully immune in code
// except Golem's poison immunity 100 = no DoT ever).
// ─────────────────────────────────────────────────────────────────────────────

const kR = <DamageType, int>{}; // shorthand for "no resistances"

class EnemyData {
  static final enemies = <Enemy>[
    // ── Undead ──────────────────────────────────────────────────────────────
    Enemy(
      id: 'skeleton', name: 'Skeleton', level: 1, maxHealth: 55, attack: 4, armorClass: 10,
      attackType: DamageType.physical,
      resistances: {DamageType.cold: 25, DamageType.poison: 75},
      description: 'Risen from ancient battlefields, this hollow warrior fights on through dark sorcery.',
    ),
    Enemy(
      id: 'ghoul', name: 'Ghoul', level: 3, maxHealth: 110, attack: 11, armorClass: 11,
      attackType: DamageType.poison,
      resistances: {DamageType.cold: 25, DamageType.poison: 50, DamageType.fire: -25},
      description: 'A ravenous undead predator fuelled by insatiable hunger.',
    ),
    Enemy(
      id: 'banshee', name: 'Banshee', level: 6, maxHealth: 145, attack: 24, armorClass: 12,
      attackType: DamageType.cold,
      resistances: {DamageType.cold: 75, DamageType.poison: 100, DamageType.fire: -50, DamageType.physical: 25},
      description: 'A wailing spirit whose scream can shatter bone and courage alike.',
    ),
    Enemy(
      id: 'mummy', name: 'Mummy', level: 8, maxHealth: 240, attack: 21, armorClass: 16,
      attackType: DamageType.physical,
      resistances: {DamageType.cold: 50, DamageType.poison: 75, DamageType.fire: -25},
      description: 'An ancient cursed pharaoh wrapped in rotten bandages and fell power.',
    ),
    Enemy(
      id: 'lich', name: 'Lich', level: 12, maxHealth: 335, attack: 48, armorClass: 15,
      attackType: DamageType.void_,
      resistances: {DamageType.cold: 50, DamageType.poison: 100, DamageType.physical: 25, DamageType.fire: -25},
      description: 'An immortal sorcerer-king whose death is merely an inconvenience.',
    ),

    // ── Gremlins & Humanoids ─────────────────────────────────────────────────
    Enemy(
      id: 'goblin', name: 'Goblin', level: 1, maxHealth: 65, attack: 5, armorClass: 10,
      attackType: DamageType.physical,
      resistances: kR,
      description: 'A scrawny, cunning creature drawn to chaos and the scent of gold.',
    ),
    Enemy(
      id: 'kobold', name: 'Kobold', level: 2, maxHealth: 85, attack: 7, armorClass: 11,
      attackType: DamageType.physical,
      resistances: kR,
      description: 'A tunnel-dwelling lizardkin that compensates for its frailty with cunning traps.',
    ),
    Enemy(
      id: 'gnoll', name: 'Gnoll', level: 4, maxHealth: 135, attack: 14, armorClass: 12,
      attackType: DamageType.physical,
      resistances: kR,
      description: 'A hyena-headed savage whose war-bark drives allies into a frenzy.',
    ),
    Enemy(
      id: 'hobgoblin', name: 'Hobgoblin', level: 5, maxHealth: 155, attack: 16, armorClass: 14,
      attackType: DamageType.physical,
      resistances: {DamageType.physical: 15},
      description: 'A disciplined soldier of the dark legions, armoured and battle-tested.',
    ),
    Enemy(
      id: 'orc', name: 'Orc', level: 6, maxHealth: 190, attack: 20, armorClass: 13,
      attackType: DamageType.physical,
      resistances: {DamageType.physical: 10},
      description: 'A rampaging brute whose fury grows with every blow landed.',
    ),

    // ── Beasts & Constructs ──────────────────────────────────────────────────
    Enemy(
      id: 'harpy', name: 'Harpy', level: 4, maxHealth: 115, attack: 16, armorClass: 11,
      attackType: DamageType.physical,
      resistances: {DamageType.lightning: 25},
      description: 'A winged terror that dives from above with murderous precision.',
    ),
    Enemy(
      id: 'gargoyle', name: 'Gargoyle', level: 7, maxHealth: 215, attack: 21, armorClass: 17,
      attackType: DamageType.physical,
      resistances: {DamageType.physical: 50, DamageType.poison: 100, DamageType.fire: -25},
      description: 'A stone sentinel awakened, its hide impervious to all but the sharpest blades.',
    ),
    Enemy(
      id: 'basilisk', name: 'Basilisk', level: 7, maxHealth: 250, attack: 23, armorClass: 15,
      attackType: DamageType.physical,
      resistances: {DamageType.poison: 50, DamageType.cold: -25},
      description: 'One glance from its eight eyes is said to turn the bravest soul to stone.',
    ),
    Enemy(
      id: 'golem', name: 'Golem', level: 9, maxHealth: 335, attack: 23, armorClass: 19,
      attackType: DamageType.physical,
      resistances: {DamageType.physical: 50, DamageType.poison: 100, DamageType.cold: 25, DamageType.lightning: -25},
      description: 'A colossus of enchanted stone, patient and nigh unstoppable.',
    ),
    Enemy(
      id: 'chimera', name: 'Chimera', level: 11, maxHealth: 385, attack: 41, armorClass: 16,
      attackType: DamageType.fire,
      resistances: {DamageType.fire: 75, DamageType.cold: -50},
      description: 'A three-headed nightmare fusing lion, goat, and serpent into one horror.',
    ),

    // ── Demonic & Aberrant ───────────────────────────────────────────────────
    Enemy(
      id: 'imp', name: 'Imp', level: 2, maxHealth: 60, attack: 7, armorClass: 11,
      attackType: DamageType.fire,
      resistances: {DamageType.fire: 50, DamageType.cold: -25},
      description: 'A minor fiend of mischief whose claws carry a sting beyond their size.',
    ),
    Enemy(
      id: 'cultist', name: 'Cultist', level: 5, maxHealth: 95, attack: 18, armorClass: 11,
      attackType: DamageType.void_,
      resistances: {DamageType.fire: 25, DamageType.void_: 25},
      description: 'A zealot who channels forbidden energies with glass-cannon ferocity.',
    ),
    Enemy(
      id: 'succubus', name: 'Succubus', level: 9, maxHealth: 235, attack: 32, armorClass: 13,
      attackType: DamageType.void_,
      resistances: {DamageType.void_: 50, DamageType.fire: 25},
      description: 'A demonic seductress who drains life as easily as she takes it.',
    ),
    Enemy(
      id: 'eyeball_watcher', name: 'Eyeball Watcher', level: 10, maxHealth: 265, attack: 37, armorClass: 13,
      attackType: DamageType.void_,
      resistances: {DamageType.void_: 50, DamageType.cold: -25},
      description: 'A floating mass of eyes that fires eldritch beams in every direction.',
    ),
    Enemy(
      id: 'mind_flayer', name: 'Mind-Flayer', level: 11, maxHealth: 310, attack: 40, armorClass: 16,
      attackType: DamageType.void_,
      resistances: {DamageType.void_: 75, DamageType.cold: 25, DamageType.lightning: -25},
      description: 'A psionic predator that strips the mind bare before consuming it.',
    ),

    // ── Crystal & Arcane ─────────────────────────────────────────────────────
    Enemy(
      id: 'crystal_shard', name: 'Crystal Shard', level: 13, maxHealth: 550, attack: 52, armorClass: 14,
      attackType: DamageType.physical,
      resistances: {DamageType.physical: 15, DamageType.lightning: -25},
      description: 'A levitating sliver of living crystal whose edges can split enchanted armour.',
    ),
    Enemy(
      id: 'prism_wraith', name: 'Prism Wraith', level: 13, maxHealth: 500, attack: 56, armorClass: 13,
      attackType: DamageType.void_,
      resistances: {DamageType.void_: 50, DamageType.physical: 50, DamageType.fire: -25},
      description: 'A ghost refracted through a thousand facets, attacking from angles that should not exist.',
    ),
    Enemy(
      id: 'gem_serpent', name: 'Gem Serpent', level: 14, maxHealth: 650, attack: 55, armorClass: 15,
      attackType: DamageType.physical,
      resistances: {DamageType.physical: 25, DamageType.lightning: 25, DamageType.cold: -25},
      description: 'A serpent whose scales have crystallised into razor-edged gemstones over centuries of arcane exposure.',
    ),
    Enemy(
      id: 'crystal_guardian', name: 'Crystal Guardian', level: 14, maxHealth: 740, attack: 57, armorClass: 18,
      attackType: DamageType.physical,
      resistances: {DamageType.physical: 50, DamageType.poison: 100, DamageType.lightning: -25},
      description: 'An ancient sentinel of living crystal, its body near-impervious to mundane weapons.',
    ),
    Enemy(
      id: 'arcane_colossus', name: 'Arcane Colossus', level: 15, maxHealth: 870, attack: 68, armorClass: 17,
      attackType: DamageType.lightning,
      resistances: {DamageType.lightning: 75, DamageType.void_: 25, DamageType.physical: 25, DamageType.fire: -25},
      description: 'A golem of pure crystallised magic, ancient beyond memory. It was built to end wars. It has never lost one.',
    ),

    // ── Shadow & Darkness ────────────────────────────────────────────────────
    Enemy(
      id: 'shadow_stalker', name: 'Shadow Stalker', level: 15, maxHealth: 580, attack: 70, armorClass: 14,
      attackType: DamageType.physical,
      resistances: {DamageType.void_: 25, DamageType.physical: 25, DamageType.fire: -25},
      description: 'A predator born of living shadow that dissolves into darkness between strikes.',
    ),
    Enemy(
      id: 'shade_assassin', name: 'Shade Assassin', level: 15, maxHealth: 530, attack: 76, armorClass: 13,
      attackType: DamageType.physical,
      resistances: {DamageType.void_: 50, DamageType.physical: 25, DamageType.lightning: -25},
      description: 'A contract killer made of pure shadow whose blades never miss a vital point.',
    ),
    Enemy(
      id: 'umbral_knight', name: 'Umbral Knight', level: 16, maxHealth: 760, attack: 73, armorClass: 19,
      attackType: DamageType.physical,
      resistances: {DamageType.physical: 40, DamageType.void_: 40, DamageType.fire: -25},
      description: 'A fallen champion armoured in solidified darkness, sworn to serve the shadow court.',
    ),
    Enemy(
      id: 'dark_phantom', name: 'Dark Phantom', level: 16, maxHealth: 620, attack: 80, armorClass: 14,
      attackType: DamageType.void_,
      resistances: {DamageType.void_: 75, DamageType.physical: 75, DamageType.fire: -50},
      description: 'An incorporeal horror whose touch drains warmth and will in equal measure.',
    ),
    Enemy(
      id: 'shade_sovereign', name: 'Shade Sovereign', level: 17, maxHealth: 1050, attack: 92, armorClass: 17,
      attackType: DamageType.void_,
      resistances: {DamageType.void_: 75, DamageType.physical: 50, DamageType.cold: 25, DamageType.fire: -50},
      description: 'The ruler of all shadow given physical form. Strike it in light — but the light here is not yours to control.',
    ),

    // ── Ice & Cold ───────────────────────────────────────────────────────────
    Enemy(
      id: 'frost_sprite', name: 'Frost Sprite', level: 17, maxHealth: 630, attack: 94, armorClass: 14,
      attackType: DamageType.cold,
      resistances: {DamageType.cold: 75, DamageType.fire: -50},
      description: 'A malicious winter spirit that flash-freezes the air around its victims.',
    ),
    Enemy(
      id: 'ice_wraith', name: 'Ice Wraith', level: 17, maxHealth: 580, attack: 100, armorClass: 13,
      attackType: DamageType.cold,
      resistances: {DamageType.cold: 75, DamageType.physical: 50, DamageType.fire: -50},
      description: 'The frozen ghost of a warrior lost in a blizzard, still fighting a battle long ended.',
    ),
    Enemy(
      id: 'glacial_troll', name: 'Glacial Troll', level: 18, maxHealth: 950, attack: 95, armorClass: 17,
      attackType: DamageType.physical,
      resistances: {DamageType.cold: 50, DamageType.physical: 25, DamageType.fire: -50},
      description: 'A mountain brute whose hide has calcified into plates of living ice over centuries.',
    ),
    Enemy(
      id: 'winter_wolf', name: 'Winter Wolf', level: 18, maxHealth: 780, attack: 103, armorClass: 15,
      attackType: DamageType.cold,
      resistances: {DamageType.cold: 75, DamageType.poison: 25, DamageType.fire: -50},
      description: 'A dire wolf whose breath is a blizzard and whose howl drops temperature by thirty degrees.',
    ),
    Enemy(
      id: 'frost_dragon', name: 'Frost Dragon', level: 19, maxHealth: 1300, attack: 118, armorClass: 18,
      attackType: DamageType.cold,
      resistances: {DamageType.cold: 100, DamageType.physical: 25, DamageType.fire: -75},
      description: 'An ancient dragon whose breath does not burn — it freezes time itself.',
    ),

    // ── Storm & Lightning ────────────────────────────────────────────────────
    Enemy(
      id: 'storm_hawk', name: 'Storm Hawk', level: 19, maxHealth: 750, attack: 120, armorClass: 15,
      attackType: DamageType.lightning,
      resistances: {DamageType.lightning: 50, DamageType.physical: 15, DamageType.cold: -25},
      description: 'A raptor that nests in the eye of permanent storms, diving at lethal speed.',
    ),
    Enemy(
      id: 'thunder_elemental', name: 'Thunder Elemental', level: 19, maxHealth: 820, attack: 125, armorClass: 14,
      attackType: DamageType.lightning,
      resistances: {DamageType.lightning: 100, DamageType.physical: -25, DamageType.cold: -25},
      description: 'A roiling mass of storm-energy given sentience and an appetite for metal armour.',
    ),
    Enemy(
      id: 'lightning_drake', name: 'Lightning Drake', level: 20, maxHealth: 1050, attack: 122, armorClass: 16,
      attackType: DamageType.lightning,
      resistances: {DamageType.lightning: 75, DamageType.physical: 25, DamageType.cold: -25},
      description: 'A wingless draconic predator that generates lethal voltages along its spine.',
    ),
    Enemy(
      id: 'storm_giant', name: 'Storm Giant', level: 20, maxHealth: 1250, attack: 126, armorClass: 17,
      attackType: DamageType.physical,
      resistances: {DamageType.lightning: 75, DamageType.physical: 25, DamageType.poison: -25},
      description: 'A colossus that calls down lightning with every hammer blow, shaking the sky.',
    ),
    Enemy(
      id: 'storm_titan', name: 'Storm Titan', level: 21, maxHealth: 1650, attack: 144, armorClass: 18,
      attackType: DamageType.lightning,
      resistances: {DamageType.lightning: 100, DamageType.physical: 25, DamageType.void_: 25, DamageType.cold: -50},
      description: 'A colossus of condensed lightning and hurricane wind. The storm does not follow it — it is the storm.',
    ),

    // ── Deep Sea & Abyss ─────────────────────────────────────────────────────
    Enemy(
      id: 'deep_lurker', name: 'Deep Lurker', level: 21, maxHealth: 1050, attack: 146, armorClass: 15,
      attackType: DamageType.physical,
      resistances: {DamageType.cold: 25, DamageType.lightning: -25},
      description: 'A blind predator from lightless depths, hunting by tremors in the water.',
    ),
    Enemy(
      id: 'tide_wraith', name: 'Tide Wraith', level: 21, maxHealth: 960, attack: 153, armorClass: 14,
      attackType: DamageType.cold,
      resistances: {DamageType.cold: 75, DamageType.physical: 50, DamageType.lightning: -50},
      description: 'The spirit of a drowned fleet given form, dragging the living to join the sunken.',
    ),
    Enemy(
      id: 'abyssal_shark', name: 'Abyssal Shark', level: 22, maxHealth: 1300, attack: 150, armorClass: 16,
      attackType: DamageType.physical,
      resistances: {DamageType.physical: 25, DamageType.cold: 25, DamageType.lightning: -25},
      description: 'An apex predator adapted to crushing pressure and absolute darkness, evolved for nothing but killing.',
    ),
    Enemy(
      id: 'sea_colossus', name: 'Sea Colossus', level: 22, maxHealth: 1600, attack: 148, armorClass: 19,
      attackType: DamageType.physical,
      resistances: {DamageType.physical: 40, DamageType.cold: 50, DamageType.fire: -25},
      description: 'A titan of the deep whose body is a living reef, encrusted with the wreckage of a thousand ships.',
    ),
    Enemy(
      id: 'krakentide', name: 'Krakentide', level: 23, maxHealth: 2100, attack: 170, armorClass: 18,
      attackType: DamageType.cold,
      resistances: {DamageType.cold: 75, DamageType.physical: 25, DamageType.lightning: -50},
      description: 'The apex predator of the deep given intelligence and ancient malice. The ocean bends to its will.',
    ),

    // ── Dream & Illusion ─────────────────────────────────────────────────────
    Enemy(
      id: 'mirror_shade', name: 'Mirror Shade', level: 23, maxHealth: 1250, attack: 172, armorClass: 15,
      attackType: DamageType.void_,
      resistances: {DamageType.void_: 50, DamageType.physical: 50, DamageType.fire: -25},
      description: 'Your own reflection turned hostile, mimicking your every move with lethal precision.',
    ),
    Enemy(
      id: 'echo_phantom', name: 'Echo Phantom', level: 23, maxHealth: 1150, attack: 180, armorClass: 14,
      attackType: DamageType.void_,
      resistances: {DamageType.void_: 75, DamageType.physical: 50, DamageType.lightning: -25},
      description: 'A phantom born of echoes that multiplies with every sound, attacking from all directions at once.',
    ),
    Enemy(
      id: 'dream_stalker', name: 'Dream Stalker', level: 24, maxHealth: 1450, attack: 177, armorClass: 16,
      attackType: DamageType.void_,
      resistances: {DamageType.void_: 50, DamageType.cold: 25, DamageType.fire: -25},
      description: 'A predator that crosses between the waking world and the dreaming one at will.',
    ),
    Enemy(
      id: 'nightmare_weaver', name: 'Nightmare Weaver', level: 24, maxHealth: 1350, attack: 188, armorClass: 15,
      attackType: DamageType.void_,
      resistances: {DamageType.void_: 75, DamageType.physical: 25, DamageType.cold: -25},
      description: 'An arachnid horror that spins webs from crystallised nightmares to trap and devour the mind.',
    ),
    Enemy(
      id: 'labyrinth_warden', name: 'Labyrinth Warden', level: 25, maxHealth: 2500, attack: 210, armorClass: 19,
      attackType: DamageType.void_,
      resistances: {DamageType.void_: 75, DamageType.physical: 50, DamageType.cold: 25, DamageType.fire: -25},
      description: 'The intelligence that designed and inhabits the maze. It has never had a visitor it could not keep.',
    ),

    // ── Ancient Constructs ───────────────────────────────────────────────────
    Enemy(
      id: 'archive_scribe', name: 'Archive Scribe', level: 25, maxHealth: 1550, attack: 212, armorClass: 16,
      attackType: DamageType.lightning,
      resistances: {DamageType.lightning: 50, DamageType.poison: 100, DamageType.physical: 25, DamageType.void_: -25},
      description: 'A construct librarian recording everything it encounters — including the precise moment to strike.',
    ),
    Enemy(
      id: 'assembly_drone', name: 'Assembly Drone', level: 25, maxHealth: 1700, attack: 208, armorClass: 18,
      attackType: DamageType.physical,
      resistances: {DamageType.physical: 40, DamageType.poison: 100, DamageType.lightning: -25},
      description: 'A factory soldier still running quotas for a war that ended before living memory.',
    ),
    Enemy(
      id: 'vault_guardian', name: 'Vault Guardian', level: 26, maxHealth: 2100, attack: 215, armorClass: 20,
      attackType: DamageType.physical,
      resistances: {DamageType.physical: 50, DamageType.poison: 100, DamageType.cold: 25, DamageType.lightning: -25},
      description: 'An armoured sentinel built to protect a treasure room that now guards nothing but dust.',
    ),
    Enemy(
      id: 'protocol_enforcer', name: 'Protocol Enforcer', level: 26, maxHealth: 1900, attack: 225, armorClass: 17,
      attackType: DamageType.lightning,
      resistances: {DamageType.lightning: 75, DamageType.poison: 100, DamageType.physical: 25, DamageType.void_: -25},
      description: 'The empire\'s last failsafe activated when every other defence has failed — it was never supposed to be necessary.',
    ),
    Enemy(
      id: 'eternal_sentinel', name: 'Eternal Sentinel', level: 27, maxHealth: 3000, attack: 248, armorClass: 20,
      attackType: DamageType.lightning,
      resistances: {DamageType.lightning: 75, DamageType.physical: 50, DamageType.poison: 100, DamageType.void_: -25},
      description: 'A construct built to outlast its empire, its world, and perhaps time itself. Its mission log still shows tasks pending.',
    ),

    // ── Plague & Corruption ──────────────────────────────────────────────────
    Enemy(
      id: 'plague_rat', name: 'Plague Rat', level: 27, maxHealth: 1800, attack: 250, armorClass: 15,
      attackType: DamageType.poison,
      resistances: {DamageType.poison: 100, DamageType.cold: -25},
      description: 'A rat swollen with magical pestilence whose very bite warps flesh into something unrecognisable.',
    ),
    Enemy(
      id: 'infected_soldier', name: 'Infected Soldier', level: 27, maxHealth: 2100, attack: 246, armorClass: 17,
      attackType: DamageType.poison,
      resistances: {DamageType.poison: 75, DamageType.physical: 25, DamageType.fire: -25},
      description: 'A former warrior consumed by plague, still fighting with the muscle memory of a soldier but the will of the corruption.',
    ),
    Enemy(
      id: 'rot_priest', name: 'Rot Priest', level: 28, maxHealth: 2000, attack: 262, armorClass: 15,
      attackType: DamageType.poison,
      resistances: {DamageType.poison: 100, DamageType.void_: 25, DamageType.fire: -25},
      description: 'A zealot who believes the plague is divine will — and spreads it with religious fervour.',
    ),
    Enemy(
      id: 'corruption_beast', name: 'Corruption Beast', level: 28, maxHealth: 2700, attack: 258, armorClass: 18,
      attackType: DamageType.poison,
      resistances: {DamageType.poison: 100, DamageType.physical: 25, DamageType.fire: -50},
      description: 'A creature so thoroughly consumed by magical rot that it has become something new and terrible entirely.',
    ),
    Enemy(
      id: 'plague_mother', name: 'Plague Mother', level: 29, maxHealth: 3800, attack: 285, armorClass: 18,
      attackType: DamageType.poison,
      resistances: {DamageType.poison: 100, DamageType.void_: 50, DamageType.physical: 25, DamageType.fire: -50},
      description: 'The original host. The first infected. The being that welcomed the corruption and made it part of herself — willingly.',
    ),

    // ── Fallen Divine ────────────────────────────────────────────────────────
    Enemy(
      id: 'broken_seraph', name: 'Broken Seraph', level: 29, maxHealth: 2400, attack: 288, armorClass: 17,
      attackType: DamageType.fire,
      resistances: {DamageType.fire: 75, DamageType.void_: -25, DamageType.cold: -25},
      description: 'A shattered angel still radiating dangerous levels of corrupted celestial energy.',
    ),
    Enemy(
      id: 'divine_wraith', name: 'Divine Wraith', level: 29, maxHealth: 2200, attack: 298, armorClass: 16,
      attackType: DamageType.fire,
      resistances: {DamageType.fire: 75, DamageType.physical: 50, DamageType.void_: -50},
      description: 'The ghost of a god that refuses to accept its own death, radiating lethal holy fire.',
    ),
    Enemy(
      id: 'fallen_cherub', name: 'Fallen Cherub', level: 30, maxHealth: 2600, attack: 294, armorClass: 17,
      attackType: DamageType.fire,
      resistances: {DamageType.fire: 75, DamageType.lightning: 25, DamageType.void_: -25},
      description: 'A cherub whose divine purpose has curdled into pure malice after eons in the dark.',
    ),
    Enemy(
      id: 'halo_specter', name: 'Halo Specter', level: 30, maxHealth: 2450, attack: 308, armorClass: 16,
      attackType: DamageType.fire,
      resistances: {DamageType.fire: 75, DamageType.physical: 50, DamageType.cold: -25, DamageType.void_: -25},
      description: 'A crown of a fallen god, broken into blades that orbit the site of its death and judge the living.',
    ),
    Enemy(
      id: 'fallen_archangel', name: 'Fallen Archangel', level: 31, maxHealth: 4500, attack: 335, armorClass: 19,
      attackType: DamageType.fire,
      resistances: {DamageType.fire: 100, DamageType.lightning: 50, DamageType.physical: 25, DamageType.void_: -50},
      description: 'The first angel to fall — not cast out but choosing to descend. What it has become in the dark is worse than what it left behind.',
    ),

    // ── Void & Null ──────────────────────────────────────────────────────────
    Enemy(
      id: 'null_sprite', name: 'Null Sprite', level: 31, maxHealth: 2800, attack: 338, armorClass: 16,
      attackType: DamageType.void_,
      resistances: {DamageType.void_: 75, DamageType.physical: -25},
      description: 'A mote of null-energy given will, erasing whatever it touches from existence.',
    ),
    Enemy(
      id: 'void_crawler', name: 'Void Crawler', level: 31, maxHealth: 3100, attack: 332, armorClass: 17,
      attackType: DamageType.void_,
      resistances: {DamageType.void_: 75, DamageType.physical: 25, DamageType.fire: -25},
      description: 'A spider-like entity from outside reality that weaves webs of pure nothing between dimensions.',
    ),
    Enemy(
      id: 'antimatter_construct', name: 'Anti-Matter Construct', level: 32, maxHealth: 3600, attack: 340, armorClass: 19,
      attackType: DamageType.void_,
      resistances: {DamageType.void_: 75, DamageType.physical: 50, DamageType.poison: 100, DamageType.fire: -25},
      description: 'A weapon made from anti-matter that unmakes whatever it strikes at a molecular level.',
    ),
    Enemy(
      id: 'entropy_fiend', name: 'Entropy Fiend', level: 32, maxHealth: 3300, attack: 355, armorClass: 17,
      attackType: DamageType.void_,
      resistances: {DamageType.void_: 100, DamageType.cold: 25, DamageType.fire: -25},
      description: 'A demon whose very existence accelerates decay in everything around it — armour rusts, flesh rots, hope fades.',
    ),
    Enemy(
      id: 'null_emperor', name: 'Null Emperor', level: 33, maxHealth: 5500, attack: 385, armorClass: 20,
      attackType: DamageType.void_,
      resistances: {DamageType.void_: 100, DamageType.physical: 50, DamageType.cold: 25, DamageType.fire: -50},
      description: 'A being that has consumed so much null-energy it exists as an absence given will. It wants to share that absence with everything.',
    ),

    // ── Imprisoned Horrors ───────────────────────────────────────────────────
    Enemy(
      id: 'shackle_beast', name: 'Shackle Beast', level: 33, maxHealth: 4200, attack: 388, armorClass: 18,
      attackType: DamageType.physical,
      resistances: {DamageType.physical: 40, DamageType.poison: 50, DamageType.lightning: -25},
      description: 'A brute imprisoned so long its shackles have fused to its body, swinging them as weapons.',
    ),
    Enemy(
      id: 'omega_warden', name: 'Omega Warden', level: 33, maxHealth: 4600, attack: 382, armorClass: 20,
      attackType: DamageType.lightning,
      resistances: {DamageType.lightning: 75, DamageType.physical: 50, DamageType.poison: 100, DamageType.void_: -25},
      description: 'The administrative mind of the prison, running this place since before the current era. It has never had a successful escape.',
    ),
    Enemy(
      id: 'containment_golem', name: 'Containment Golem', level: 34, maxHealth: 5500, attack: 390, armorClass: 21,
      attackType: DamageType.physical,
      resistances: {DamageType.physical: 50, DamageType.poison: 100, DamageType.cold: 25, DamageType.lightning: -25},
      description: 'A construct powered by the prison\'s containment core, built to seal the unsealed and chain the unchained.',
    ),
    Enemy(
      id: 'cell_breaker', name: 'Cell Breaker', level: 34, maxHealth: 4800, attack: 405, armorClass: 18,
      attackType: DamageType.physical,
      resistances: {DamageType.physical: 40, DamageType.void_: 50, DamageType.cold: -25},
      description: 'A prisoner that tore through three cell walls with its bare hands before being subdued — temporarily.',
    ),
    Enemy(
      id: 'the_unbound', name: 'The Unbound', level: 35, maxHealth: 7000, attack: 435, armorClass: 21,
      attackType: DamageType.void_,
      resistances: {DamageType.void_: 100, DamageType.physical: 50, DamageType.fire: 25, DamageType.cold: -25},
      description: 'The original prisoner — the being the prison was built to contain. The walls have held for an age. They will not hold today.',
    ),

    // ── Abyss Guardians ──────────────────────────────────────────────────────
    Enemy(
      id: 'gate_crawler', name: 'Gate Crawler', level: 35, maxHealth: 5200, attack: 438, armorClass: 18,
      attackType: DamageType.void_,
      resistances: {DamageType.void_: 75, DamageType.physical: 25, DamageType.fire: -25},
      description: 'A thing from beyond the mapped world that squeezes through gaps between realities.',
    ),
    Enemy(
      id: 'sentinel_wraith', name: 'Sentinel Wraith', level: 35, maxHealth: 4800, attack: 448, armorClass: 17,
      attackType: DamageType.void_,
      resistances: {DamageType.void_: 75, DamageType.physical: 75, DamageType.fire: -50},
      description: 'A guardian that has never received a stand-down order and has been at its post longer than most civilisations.',
    ),
    Enemy(
      id: 'watcher_construct', name: 'Watcher Construct', level: 36, maxHealth: 6000, attack: 445, armorClass: 20,
      attackType: DamageType.lightning,
      resistances: {DamageType.lightning: 75, DamageType.poison: 100, DamageType.physical: 25, DamageType.void_: -25},
      description: 'An automated watchtower that overlooks the nothing beyond the gate. It never looks away.',
    ),
    Enemy(
      id: 'siege_engine', name: 'Siege Engine', level: 36, maxHealth: 7000, attack: 442, armorClass: 21,
      attackType: DamageType.physical,
      resistances: {DamageType.physical: 50, DamageType.poison: 100, DamageType.lightning: -25},
      description: 'A forgotten weapon of war set to fire at anything that comes close to the gate. You are close to the gate.',
    ),
    Enemy(
      id: 'gate_colossus', name: 'Gate Colossus', level: 37, maxHealth: 9500, attack: 480, armorClass: 22,
      attackType: DamageType.physical,
      resistances: {DamageType.physical: 50, DamageType.lightning: 50, DamageType.poison: 100, DamageType.void_: -25},
      description: 'A construct the size of a city, built to be the last line of defence. Nothing has ever made it necessary — until now.',
    ),

    // ── Divine Carrion ───────────────────────────────────────────────────────
    Enemy(
      id: 'carrion_crawler', name: 'Carrion Crawler', level: 37, maxHealth: 6500, attack: 483, armorClass: 18,
      attackType: DamageType.poison,
      resistances: {DamageType.poison: 100, DamageType.physical: 25, DamageType.fire: -25},
      description: 'A parasite the size of a house that has fed on divine carrion so long it has absorbed traces of godhood.',
    ),
    Enemy(
      id: 'god_shard_elemental', name: 'God-Shard Elemental', level: 37, maxHealth: 7200, attack: 478, armorClass: 19,
      attackType: DamageType.fire,
      resistances: {DamageType.fire: 75, DamageType.physical: 25, DamageType.void_: -25},
      description: 'A fragment of divinity extracted from a god-corpse, still remembering being divine and reacting with divine fury.',
    ),
    Enemy(
      id: 'necrotic_abomination', name: 'Necrotic Abomination', level: 38, maxHealth: 8500, attack: 486, armorClass: 19,
      attackType: DamageType.poison,
      resistances: {DamageType.poison: 100, DamageType.cold: 25, DamageType.fire: -25, DamageType.physical: 25},
      description: 'A mass of divine flesh that has rotted and merged into something the gods would not recognise as their own.',
    ),
    Enemy(
      id: 'scar_feeder', name: 'Scar Feeder', level: 38, maxHealth: 7800, attack: 498, armorClass: 18,
      attackType: DamageType.void_,
      resistances: {DamageType.void_: 75, DamageType.poison: 50, DamageType.fire: -25},
      description: 'A creature that has found the wound in reality left by the god\'s death and feeds from the tear, growing ever stronger.',
    ),
    Enemy(
      id: 'the_devourer', name: 'The Devourer', level: 39, maxHealth: 12000, attack: 530, armorClass: 21,
      attackType: DamageType.void_,
      resistances: {DamageType.void_: 100, DamageType.poison: 75, DamageType.physical: 25, DamageType.fire: -25},
      description: 'The apex predator that has fed on the god-corpse for an age. It is no longer merely hungry — it has become hunger.',
    ),

    // ── Edge of Existence ────────────────────────────────────────────────────
    Enemy(
      id: 'boundary_wraith', name: 'Boundary Wraith', level: 39, maxHealth: 8500, attack: 533, armorClass: 19,
      attackType: DamageType.void_,
      resistances: {DamageType.void_: 100, DamageType.physical: 50, DamageType.fire: -25},
      description: 'A guardian of the membrane between this world and the void — thin enough here that it can reach through.',
    ),
    Enemy(
      id: 'no_return_specter', name: 'No-Return Specter', level: 39, maxHealth: 9000, attack: 528, armorClass: 18,
      attackType: DamageType.void_,
      resistances: {DamageType.void_: 100, DamageType.physical: 75, DamageType.fire: -50},
      description: 'The collective echo of every explorer who reached this far and stopped sending letters.',
    ),
    Enemy(
      id: 'void_membrane', name: 'Void Membrane', level: 40, maxHealth: 11000, attack: 540, armorClass: 20,
      attackType: DamageType.void_,
      resistances: {DamageType.void_: 100, DamageType.physical: 50, DamageType.cold: 25, DamageType.fire: -25},
      description: 'A living barrier between existence and non-existence that does not want you to pass. It is very persuasive.',
    ),
    Enemy(
      id: 'last_light_seraph', name: 'Last Light Seraph', level: 40, maxHealth: 10000, attack: 555, armorClass: 19,
      attackType: DamageType.fire,
      resistances: {DamageType.fire: 100, DamageType.lightning: 50, DamageType.void_: -50},
      description: 'The final point where any light from your world reaches. It burns to keep the darkness from winning — at any cost.',
    ),
    Enemy(
      id: 'frontier_guardian', name: 'Frontier Guardian', level: 41, maxHealth: 15000, attack: 590, armorClass: 22,
      attackType: DamageType.void_,
      resistances: {DamageType.void_: 100, DamageType.physical: 50, DamageType.fire: 25, DamageType.cold: -25},
      description: 'A being that has stood at the edge of everything for longer than memory. It was put here to ensure no one reached what lies beyond.',
    ),

    // ── Omega Throne ─────────────────────────────────────────────────────────
    Enemy(
      id: 'omega_herald', name: 'Omega Herald', level: 41, maxHealth: 11000, attack: 593, armorClass: 20,
      attackType: DamageType.void_,
      resistances: {DamageType.void_: 100, DamageType.physical: 50, DamageType.fire: 25, DamageType.cold: -25},
      description: 'A servant of the Omega preparing for your arrival since the beginning, its welcome ready and lethal.',
    ),
    Enemy(
      id: 'memory_shade', name: 'Memory Shade', level: 41, maxHealth: 10500, attack: 605, armorClass: 19,
      attackType: DamageType.void_,
      resistances: {DamageType.void_: 100, DamageType.physical: 75, DamageType.fire: -50},
      description: 'A shade formed from the memories of every hero who tried and failed — wearing their faces and wielding their skills.',
    ),
    Enemy(
      id: 'dark_hour_titan', name: 'Dark Hour Titan', level: 42, maxHealth: 14000, attack: 615, armorClass: 21,
      attackType: DamageType.void_,
      resistances: {DamageType.void_: 100, DamageType.physical: 50, DamageType.cold: 25, DamageType.fire: -25},
      description: 'A colossus born at the darkest moment before the end, when the Omega believes it has already won.',
    ),
    Enemy(
      id: 'throne_sentinel', name: 'Throne Sentinel', level: 42, maxHealth: 16000, attack: 620, armorClass: 22,
      attackType: DamageType.void_,
      resistances: {DamageType.void_: 100, DamageType.physical: 50, DamageType.lightning: 50, DamageType.fire: -25},
      description: 'The final guardian of the approach, observed by the Omega itself, deciding whether you are worthy of a proper ending.',
    ),
    Enemy(
      id: 'the_omega', name: 'The Omega', level: 43, maxHealth: 25000, attack: 660, armorClass: 23,
      attackType: DamageType.void_,
      resistances: {DamageType.void_: 100, DamageType.physical: 50, DamageType.fire: 50, DamageType.cold: 50, DamageType.lightning: -25},
      description: 'The original darkness. The first and the last. Every curse, every enemy, every shadow you have faced was its fingerprint.',
    ),

    // ── Elemental & Mythical ─────────────────────────────────────────────────
    Enemy(
      id: 'pixie', name: 'Pixie', level: 3, maxHealth: 65, attack: 9, armorClass: 14,
      attackType: DamageType.void_,
      resistances: {DamageType.void_: 25},
      description: 'A deceptive forest spirit whose beauty belies its vicious bite.',
    ),
    Enemy(
      id: 'wyvern', name: 'Wyvern', level: 8, maxHealth: 285, attack: 25, armorClass: 15,
      attackType: DamageType.poison,
      resistances: {DamageType.physical: 25, DamageType.cold: -25},
      description: 'A two-legged dragon whose barbed tail delivers devastating poison.',
    ),
    Enemy(
      id: 'hydra', name: 'Hydra', level: 12, maxHealth: 550, attack: 44, armorClass: 16,
      attackType: DamageType.poison,
      resistances: {DamageType.poison: 100, DamageType.cold: -25},
      description: 'Cut off one head and two grow back — only fire can stop the tide.',
    ),
    Enemy(
      id: 'minotaur', name: 'Minotaur', level: 10, maxHealth: 360, attack: 31, armorClass: 14,
      attackType: DamageType.physical,
      resistances: {DamageType.physical: 15},
      description: 'A bull-headed labyrinth guardian that levels everything in its charge.',
    ),
    Enemy(
      id: 'phoenix', name: 'Phoenix', level: 13, maxHealth: 515, attack: 48, armorClass: 16,
      attackType: DamageType.fire,
      resistances: {DamageType.fire: 100, DamageType.cold: -50},
      description: 'The undying flame given form; its death is only the beginning.',
    ),
  ];

  // ── Campaign order ────────────────────────────────────────────────────────
  static final _campaignOrder = <String>[
    'skeleton',        // Stage  0
    'goblin',          // Stage  1
    'imp',             // Stage  2
    'kobold',          // Stage  3
    'pixie',           // Stage  4
    'ghoul',           // Stage  5
    'gnoll',           // Stage  6
    'harpy',           // Stage  7
    'cultist',         // Stage  8
    'hobgoblin',       // Stage  9
    'orc',             // Stage 10
    'banshee',         // Stage 11
    'gargoyle',        // Stage 12
    'basilisk',        // Stage 13
    'mummy',           // Stage 14
    'wyvern',          // Stage 15
    'golem',           // Stage 16
    'succubus',        // Stage 17
    'minotaur',        // Stage 18
    'eyeball_watcher', // Stage 19
    'mind_flayer',     // Stage 20
    'chimera',         // Stage 21
    'lich',            // Stage 22
    'hydra',           // Stage 23
    'phoenix',         // Stage 24
    // ── Crystal Sanctum ──────────────────────────────────────────────────────
    'crystal_shard',    // Stage 25
    'prism_wraith',     // Stage 26
    'gem_serpent',      // Stage 27
    'crystal_guardian', // Stage 28
    'arcane_colossus',  // Stage 29
    // ── Shadow Realm ─────────────────────────────────────────────────────────
    'shadow_stalker',   // Stage 30
    'shade_assassin',   // Stage 31
    'umbral_knight',    // Stage 32
    'dark_phantom',     // Stage 33
    'shade_sovereign',  // Stage 34
    // ── Frozen Wastes ────────────────────────────────────────────────────────
    'frost_sprite',     // Stage 35
    'ice_wraith',       // Stage 36
    'glacial_troll',    // Stage 37
    'winter_wolf',      // Stage 38
    'frost_dragon',     // Stage 39
    // ── Storm Heights ────────────────────────────────────────────────────────
    'storm_hawk',       // Stage 40
    'thunder_elemental',// Stage 41
    'lightning_drake',  // Stage 42
    'storm_giant',      // Stage 43
    'storm_titan',      // Stage 44
    // ── Abyssal Ocean ────────────────────────────────────────────────────────
    'deep_lurker',      // Stage 45
    'tide_wraith',      // Stage 46
    'abyssal_shark',    // Stage 47
    'sea_colossus',     // Stage 48
    'krakentide',       // Stage 49
    // ── Twilight Labyrinth ───────────────────────────────────────────────────
    'mirror_shade',     // Stage 50
    'echo_phantom',     // Stage 51
    'dream_stalker',    // Stage 52
    'nightmare_weaver', // Stage 53
    'labyrinth_warden', // Stage 54
    // ── Forgotten Empire ─────────────────────────────────────────────────────
    'archive_scribe',   // Stage 55
    'assembly_drone',   // Stage 56
    'vault_guardian',   // Stage 57
    'protocol_enforcer',// Stage 58
    'eternal_sentinel', // Stage 59
    // ── Plaguelands ──────────────────────────────────────────────────────────
    'plague_rat',       // Stage 60
    'infected_soldier', // Stage 61
    'rot_priest',       // Stage 62
    'corruption_beast', // Stage 63
    'plague_mother',    // Stage 64
    // ── Celestial Ruins ──────────────────────────────────────────────────────
    'broken_seraph',    // Stage 65
    'divine_wraith',    // Stage 66
    'fallen_cherub',    // Stage 67
    'halo_specter',     // Stage 68
    'fallen_archangel', // Stage 69
    // ── Dark Matter ──────────────────────────────────────────────────────────
    'null_sprite',          // Stage 70
    'void_crawler',         // Stage 71
    'antimatter_construct', // Stage 72
    'entropy_fiend',        // Stage 73
    'null_emperor',         // Stage 74
    // ── Eternal Prison ───────────────────────────────────────────────────────
    'shackle_beast',        // Stage 75
    'omega_warden',         // Stage 76
    'containment_golem',    // Stage 77
    'cell_breaker',         // Stage 78
    'the_unbound',          // Stage 79
    // ── Abyss Gate ───────────────────────────────────────────────────────────
    'gate_crawler',         // Stage 80
    'sentinel_wraith',      // Stage 81
    'watcher_construct',    // Stage 82
    'siege_engine',         // Stage 83
    'gate_colossus',        // Stage 84
    // ── Shattered Realm ──────────────────────────────────────────────────────
    'carrion_crawler',      // Stage 85
    'god_shard_elemental',  // Stage 86
    'necrotic_abomination', // Stage 87
    'scar_feeder',          // Stage 88
    'the_devourer',         // Stage 89
    // ── Final Frontier ───────────────────────────────────────────────────────
    'boundary_wraith',      // Stage 90
    'no_return_specter',    // Stage 91
    'void_membrane',        // Stage 92
    'last_light_seraph',    // Stage 93
    'frontier_guardian',    // Stage 94
    // ── Omega Throne ─────────────────────────────────────────────────────────
    'omega_herald',         // Stage 95
    'memory_shade',         // Stage 96
    'dark_hour_titan',      // Stage 97
    'throne_sentinel',      // Stage 98
    'the_omega',            // Stage 99
  ];

  static Enemy _byId(String id) => enemies.firstWhere((e) => e.id == id);

  static Enemy enemyForStage(int stage, {List<ZoneAffix> affixes = const []}) {
    if (stage < kCampaignLength) {
      return _byId(_campaignOrder[stage]);
    }

    // ── Abyss ────────────────────────────────────────────────────────────────
    final a         = stage - (kCampaignLength - 1);
    final typeIndex = stage % kCampaignLength;
    final base      = _byId(_campaignOrder[typeIndex]);

    final double growth = a <= 100
        ? pow(1.06, a).toDouble()
        : pow(1.06, 100).toDouble() * (1.0 + (a - 100) * 0.02);

    const baseHP  = 220;
    const baseAtk = 45;
    const baseAC  = 16;
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
      id:           base.id,
      name:         name,
      description:  base.description,
      maxHealth:    hp,
      attack:       atk,
      level:        level,
      armorClass:   baseAC + acBonus,
      attackType:   base.attackType,
      resistances:  base.resistances,
    );
  }
}
