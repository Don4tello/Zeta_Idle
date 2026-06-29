import 'dnd_class.dart';

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
  // ── BARBARIAN ───────────────────────────────────────────────────
  Subclass(
    id: 'berserker', name: 'Berserker', classRequired: DndClass.barbarian,
    flavor: 'Rage strips away pain. When blood runs low, fury runs high.',
    effect: SubclassEffect.berserk,
    effectLabel: '+25% damage while below 50% HP',
    strBonus: 1, conBonus: 1,
  ),
  Subclass(
    id: 'totem_warrior', name: 'Totem Warrior', classRequired: DndClass.barbarian,
    flavor: 'The spirit of the bear flows through you — endure what would break others.',
    effect: SubclassEffect.totemWarrior,
    effectLabel: 'Stat bonuses only — durability focus',
    strBonus: 1, conBonus: 3,
  ),

  // ── BARD ────────────────────────────────────────────────────────
  Subclass(
    id: 'lore_keeper', name: 'College of Lore', classRequired: DndClass.bard,
    flavor: 'Ancient words amplify every spell. Knowledge is the greatest weapon.',
    effect: SubclassEffect.loreKeeper,
    effectLabel: '+20% to all ability effects',
    intBonus: 1, wisBonus: 1,
  ),
  Subclass(
    id: 'valor_surge', name: 'College of Valor', classRequired: DndClass.bard,
    flavor: "A warrior's song sharpens the blade. The next blow after magic always finds its mark.",
    effect: SubclassEffect.valorSurge,
    effectLabel: 'After any ability: next attack +4 to hit',
    strBonus: 1, chaBonus: 1,
  ),

  // ── CLERIC ──────────────────────────────────────────────────────
  Subclass(
    id: 'life_cleric', name: 'Life Domain', classRequired: DndClass.cleric,
    flavor: 'The light of the gods flows through your hands, mending the broken.',
    effect: SubclassEffect.lifeCleric,
    effectLabel: '+30% to all healing abilities',
    wisBonus: 1, conBonus: 1,
  ),
  Subclass(
    id: 'war_cleric', name: 'War Domain', classRequired: DndClass.cleric,
    flavor: 'Blessed by the god of battle, your every strike carries divine fury.',
    effect: SubclassEffect.warCleric,
    effectLabel: '+2 damage on every attack',
    strBonus: 2, conBonus: 1,
  ),

  // ── DRUID ───────────────────────────────────────────────────────
  Subclass(
    id: 'moon_circle', name: 'Circle of the Moon', classRequired: DndClass.druid,
    flavor: 'The moon grants endurance beyond mortal limits. Pain is just moonlight.',
    effect: SubclassEffect.moonCircle,
    effectLabel: 'Stat bonuses only — enhanced resilience',
    conBonus: 3, wisBonus: 1,
  ),
  Subclass(
    id: 'spore_circle', name: 'Circle of Spores', classRequired: DndClass.druid,
    flavor: 'Death and decay are part of nature. Your poisons rot through any defence.',
    effect: SubclassEffect.sporeCircle,
    effectLabel: '+50% damage from all DoT abilities',
    wisBonus: 1, intBonus: 1,
  ),

  // ── FIGHTER ─────────────────────────────────────────────────────
  Subclass(
    id: 'champion', name: 'Champion', classRequired: DndClass.fighter,
    flavor: 'Perfected technique turns near-misses into killing blows.',
    effect: SubclassEffect.champion,
    effectLabel: 'Critical hit on 18, 19, or 20',
    strBonus: 1, conBonus: 1,
  ),
  Subclass(
    id: 'battle_master', name: 'Battle Master', classRequired: DndClass.fighter,
    flavor: 'Every manoeuvre is a calculated trap. The enemy never recovers.',
    effect: SubclassEffect.battleMaster,
    effectLabel: 'Stun abilities last +1 additional round',
    strBonus: 1, dexBonus: 1,
  ),

  // ── MONK ────────────────────────────────────────────────────────
  Subclass(
    id: 'open_hand', name: 'Way of the Open Hand', classRequired: DndClass.monk,
    flavor: 'The palm strike channels pure force. No armour can absorb it.',
    effect: SubclassEffect.openHand,
    effectLabel: '+25% base attack damage',
    dexBonus: 2, wisBonus: 1,
  ),
  Subclass(
    id: 'shadow_monk', name: 'Way of Shadow', classRequired: DndClass.monk,
    flavor: 'Become the shadow between strikes. What cannot be touched cannot be hurt.',
    effect: SubclassEffect.shadowMonk,
    effectLabel: '+10% passive dodge chance',
    dexBonus: 2, wisBonus: 1,
  ),

  // ── PALADIN ─────────────────────────────────────────────────────
  Subclass(
    id: 'devotion', name: 'Oath of Devotion', classRequired: DndClass.paladin,
    flavor: 'Sacred light heals wounds between every clash of steel.',
    effect: SubclassEffect.devotion,
    effectLabel: 'Regenerate 1 HP at the start of each enemy turn',
    conBonus: 1, wisBonus: 1,
  ),
  Subclass(
    id: 'vengeance', name: 'Oath of Vengeance', classRequired: DndClass.paladin,
    flavor: 'The guilty cannot hide. Your blade finds the gaps in their armour.',
    effect: SubclassEffect.vengeance,
    effectLabel: '+3 pierce, +10% damage on all attacks',
    strBonus: 2, conBonus: 1,
  ),

  // ── RANGER ──────────────────────────────────────────────────────
  Subclass(
    id: 'hunter', name: 'Hunter', classRequired: DndClass.ranger,
    flavor: 'You are the apex predator. Everything else is prey.',
    effect: SubclassEffect.hunter,
    effectLabel: '+20% damage on every attack',
    strBonus: 2, dexBonus: 1,
  ),
  Subclass(
    id: 'beast_master', name: 'Beast Master', classRequired: DndClass.ranger,
    flavor: "Nature's bounty flows through the bond with your companions.",
    effect: SubclassEffect.beastMaster,
    effectLabel: 'Stat bonuses only — economy focus',
    wisBonus: 4, intBonus: 2,
  ),

  // ── ROGUE ───────────────────────────────────────────────────────
  Subclass(
    id: 'assassin', name: 'Assassin', classRequired: DndClass.rogue,
    flavor: 'The critical strike is not a lucky blow — it is the only blow.',
    effect: SubclassEffect.assassin,
    effectLabel: 'Critical hits deal triple damage (instead of double)',
    dexBonus: 2, strBonus: 1,
  ),
  Subclass(
    id: 'arcane_trickster', name: 'Arcane Trickster', classRequired: DndClass.rogue,
    flavor: 'Magic accelerates every trick. Abilities return almost before the echo fades.',
    effect: SubclassEffect.arcaneTrickster,
    effectLabel: '-1 to all ability cooldowns',
    intBonus: 1, dexBonus: 1,
  ),

  // ── SORCERER ────────────────────────────────────────────────────
  Subclass(
    id: 'wild_magic', name: 'Wild Magic', classRequired: DndClass.sorcerer,
    flavor: 'Magic does not obey you — it erupts through you. Chaos is a weapon.',
    effect: SubclassEffect.wildMagic,
    effectLabel: '15% chance any hit deals triple damage',
    chaBonus: 1, conBonus: 1,
  ),
  Subclass(
    id: 'draconic', name: 'Draconic Bloodline', classRequired: DndClass.sorcerer,
    flavor: 'Dragon blood runs through your veins — and so does their terrible resilience.',
    effect: SubclassEffect.draconic,
    effectLabel: 'Stat bonuses only — draconic resilience',
    conBonus: 3, strBonus: 2,
  ),

  // ── WARLOCK ─────────────────────────────────────────────────────
  Subclass(
    id: 'great_old_one', name: 'Great Old One', classRequired: DndClass.warlock,
    flavor: 'The thing beyond the void amplifies your pact with incomprehensible power.',
    effect: SubclassEffect.greatOldOne,
    effectLabel: '+25% to all ability effects',
    chaBonus: 1, intBonus: 1,
  ),
  Subclass(
    id: 'fiend_pact', name: 'The Fiend', classRequired: DndClass.warlock,
    flavor: 'The fiend demands blood — and returns life in kind. Every wound feeds you.',
    effect: SubclassEffect.fiendPact,
    effectLabel: 'Lifesteal: recover 20% of damage dealt',
    chaBonus: 2, strBonus: 1,
  ),

  // ── WIZARD ──────────────────────────────────────────────────────
  Subclass(
    id: 'evoker', name: 'Evoker', classRequired: DndClass.wizard,
    flavor: 'Pure evocation magic. No subtlety, no nuance — only force.',
    effect: SubclassEffect.evoker,
    effectLabel: '+35% to all ability effects',
    intBonus: 2, wisBonus: 1,
  ),
  Subclass(
    id: 'abjurer', name: 'Abjurer', classRequired: DndClass.wizard,
    flavor: 'Ward and counter. The best offence is an impenetrable defence.',
    effect: SubclassEffect.abjurer,
    effectLabel: '+15% healing + stat bonuses',
    conBonus: 1, dexBonus: 1, intBonus: 1,
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
