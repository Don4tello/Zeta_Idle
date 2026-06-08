import '../models/dnd_class.dart';
import '../models/hero_ability.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AbilityData — 3 active abilities per class, unlocked at hero levels 1 / 5 / 10
//
// Effect semantics:
//   bonusDamage  value = die max (e.g. 10 → d10)
//   heal         value = % of max HP to restore
//   attackBonus  value = bonus to attack rolls,   duration = rounds
//   acBonus      value = bonus to effective AC,   duration = rounds
//   stun         duration = enemy turns skipped   (value unused)
//   dot          value = damage per round,        duration = rounds
//   dodge        next N enemy attacks negated     (duration = 1, value unused)
//
// Branches unlock at rank 3 — player picks one permanently (resets on prestige).
// Branch A: power — amplifies the primary effect.
// Branch B: synergy — trades some primary potency for a secondary effect.
// ─────────────────────────────────────────────────────────────────────────────

class AbilityData {
  static const _abilities = <DndClass, List<HeroAbility>>{
    DndClass.barbarian: [
      HeroAbility(
        id: 'barbarian_1', name: 'Reckless Strike',
        description: 'Hurl yourself forward for a brutal +d10 bonus hit.',
        cooldownRounds: 3, levelRequired: 1,
        effect: AbilityEffect.bonusDamage, value: 10,
        branchA: AbilityBranch(
          id: 'a', name: 'Frenzy',
          description: 'Unbridled fury — +4 to max damage.',
          valueDelta: 4,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Blood Thirst',
          description: 'Draw vitality from the wound. Deals slightly less but restores 15% HP.',
          valueDelta: -2,
          secondaryEffect: AbilityEffect.heal, secondaryValue: 15,
        ),
      ),
      HeroAbility(
        id: 'barbarian_2', name: 'Battle Cry',
        description: '+4 to attack rolls for 3 rounds.',
        cooldownRounds: 6, levelRequired: 5,
        effect: AbilityEffect.attackBonus, value: 4, duration: 3,
        branchA: AbilityBranch(
          id: 'a', name: 'War Shout',
          description: '+5 ATK for 4 rounds — longer and stronger.',
          valueDelta: 1, durationDelta: 1,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Intimidating Roar',
          description: '+4 ATK for 3r and the sheer ferocity stuns the enemy for 1 turn.',
          secondaryEffect: AbilityEffect.stun, secondaryDuration: 1,
        ),
      ),
      HeroAbility(
        id: 'barbarian_3', name: 'Berserker Rage',
        description: 'Unstoppable frenzy — deal +d12 bonus damage.',
        cooldownRounds: 8, levelRequired: 10,
        effect: AbilityEffect.bonusDamage, value: 12,
        branchA: AbilityBranch(
          id: 'a', name: 'Unstoppable Fury',
          description: 'Peak berserker power — +3 more max damage.',
          valueDelta: 3,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Blood Rage',
          description: 'Slightly lower hit, but leaves a bleeding DoT: 10 dmg/r for 3r.',
          valueDelta: -4,
          secondaryEffect: AbilityEffect.dot, secondaryValue: 10, secondaryDuration: 3,
        ),
      ),
    ],

    DndClass.bard: [
      HeroAbility(
        id: 'bard_1', name: 'Vicious Mockery',
        description: 'Scathing words grant +2 AC for 2 rounds.',
        cooldownRounds: 4, levelRequired: 1,
        effect: AbilityEffect.acBonus, value: 2, duration: 2,
        branchA: AbilityBranch(
          id: 'a', name: 'Cutting Words',
          description: '+3 AC for 3 rounds — a sharper insult, a longer flinch.',
          valueDelta: 1, durationDelta: 1,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Distracting Jest',
          description: '+2 AC for 2r and the mockery briefly stuns the enemy for 1 turn.',
          secondaryEffect: AbilityEffect.stun, secondaryDuration: 1,
        ),
      ),
      HeroAbility(
        id: 'bard_2', name: 'Inspiring Speech',
        description: 'Restore 15% max HP.',
        cooldownRounds: 6, levelRequired: 5,
        effect: AbilityEffect.heal, value: 15,
        branchA: AbilityBranch(
          id: 'a', name: 'Rallying Cry',
          description: 'A rousing speech restores 25% HP.',
          valueDelta: 10,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Bolstering Ballad',
          description: 'Restores 12% HP and fills the hero with purpose — +3 ATK for 2r.',
          valueDelta: -3,
          secondaryEffect: AbilityEffect.attackBonus, secondaryValue: 3, secondaryDuration: 2,
        ),
      ),
      HeroAbility(
        id: 'bard_3', name: 'Song of Rest',
        description: 'A powerful melody restores 30% max HP.',
        cooldownRounds: 8, levelRequired: 10,
        effect: AbilityEffect.heal, value: 30,
        branchA: AbilityBranch(
          id: 'a', name: 'Epic Finale',
          description: 'The song crescendos — restores 45% HP.',
          valueDelta: 15,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Battle Hymn',
          description: 'Restores 20% HP and inspires +4 ATK for 3 rounds.',
          valueDelta: -10,
          secondaryEffect: AbilityEffect.attackBonus, secondaryValue: 4, secondaryDuration: 3,
        ),
      ),
    ],

    DndClass.cleric: [
      HeroAbility(
        id: 'cleric_1', name: 'Command',
        description: 'A single divine word stops the enemy cold — they skip their next turn.',
        cooldownRounds: 4, levelRequired: 1,
        effect: AbilityEffect.stun, value: 0, duration: 1,
        branchA: AbilityBranch(
          id: 'a', name: 'Commanding Word',
          description: 'The divine imperative grows irresistible — stuns for 2 turns.',
          durationDelta: 1,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Sacred Command',
          description: 'Stuns 1 turn and sacred energy wraps the hero in +3 AC for 2 rounds.',
          secondaryEffect: AbilityEffect.acBonus, secondaryValue: 3, secondaryDuration: 2,
        ),
      ),
      HeroAbility(
        id: 'cleric_2', name: 'Cure Wounds',
        description: 'Lay on hands to restore 20% max HP.',
        cooldownRounds: 5, levelRequired: 5,
        effect: AbilityEffect.heal, value: 20,
        branchA: AbilityBranch(
          id: 'a', name: 'Mass Healing',
          description: 'Channel more divine energy — restores 30% HP.',
          valueDelta: 10,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Sanctified Wounds',
          description: 'Restores 15% HP and the holy sting empowers the hero — +3 ATK for 2r.',
          valueDelta: -5,
          secondaryEffect: AbilityEffect.attackBonus, secondaryValue: 3, secondaryDuration: 2,
        ),
      ),
      HeroAbility(
        id: 'cleric_3', name: 'Holy Wrath',
        description: 'Channel divine fury into a devastating +d10 radiant strike.',
        cooldownRounds: 7, levelRequired: 10,
        effect: AbilityEffect.bonusDamage, value: 10,
        branchA: AbilityBranch(
          id: 'a', name: 'Divine Fury',
          description: 'Pure radiant power — +3 more max damage.',
          valueDelta: 3,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Smiting Light',
          description: 'Slightly less damage but the blinding flash stuns the enemy for 1 turn.',
          valueDelta: -2,
          secondaryEffect: AbilityEffect.stun, secondaryDuration: 1,
        ),
      ),
    ],

    DndClass.druid: [
      HeroAbility(
        id: 'druid_1', name: 'Shillelagh',
        description: "Nature's power grants +2 to attack rolls for 2 rounds.",
        cooldownRounds: 4, levelRequired: 1,
        effect: AbilityEffect.attackBonus, value: 2, duration: 2,
        branchA: AbilityBranch(
          id: 'a', name: "Nature's Wrath",
          description: '+3 ATK for 3 rounds — the staff practically swings itself.',
          valueDelta: 1, durationDelta: 1,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Thorny Staff',
          description: '+2 ATK for 2r and thorns splinter off — DoT 6 dmg/r for 2r.',
          secondaryEffect: AbilityEffect.dot, secondaryValue: 6, secondaryDuration: 2,
        ),
      ),
      HeroAbility(
        id: 'druid_2', name: 'Healing Word',
        description: 'A whispered word restores 15% max HP.',
        cooldownRounds: 5, levelRequired: 5,
        effect: AbilityEffect.heal, value: 15,
        branchA: AbilityBranch(
          id: 'a', name: 'Greater Healing Word',
          description: 'A louder incantation — restores 22% HP.',
          valueDelta: 7,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Wild Regrowth',
          description: 'Restores 10% HP and releases toxic spores — DoT 8 dmg/r for 2r.',
          valueDelta: -5,
          secondaryEffect: AbilityEffect.dot, secondaryValue: 8, secondaryDuration: 2,
        ),
      ),
      HeroAbility(
        id: 'druid_3', name: 'Call Lightning',
        description: 'Storm strikes for 12 damage per round for 3 rounds.',
        cooldownRounds: 7, levelRequired: 10,
        effect: AbilityEffect.dot, value: 12, duration: 3,
        branchA: AbilityBranch(
          id: 'a', name: 'Chain Lightning',
          description: 'More violent strikes — 16 dmg/r for 3 rounds.',
          valueDelta: 4,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Storm Surge',
          description: '10 dmg/r for 4r and the electrifying surge grants +3 ATK for 2r.',
          valueDelta: -2, durationDelta: 1,
          secondaryEffect: AbilityEffect.attackBonus, secondaryValue: 3, secondaryDuration: 2,
        ),
      ),
    ],

    DndClass.fighter: [
      HeroAbility(
        id: 'fighter_1', name: 'Second Wind',
        description: 'Dig deep to recover 10% max HP.',
        cooldownRounds: 6, levelRequired: 1,
        effect: AbilityEffect.heal, value: 10,
        branchA: AbilityBranch(
          id: 'a', name: "Veteran's Surge",
          description: 'Years of grit pay off — restores 16% HP.',
          valueDelta: 6,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Battle Hardened',
          description: 'Restores 8% HP and the fighting stance adds +2 AC for 3r.',
          valueDelta: -2,
          secondaryEffect: AbilityEffect.acBonus, secondaryValue: 2, secondaryDuration: 3,
        ),
      ),
      HeroAbility(
        id: 'fighter_2', name: 'Action Surge',
        description: '+5 to attack rolls for 1 round.',
        cooldownRounds: 8, levelRequired: 5,
        effect: AbilityEffect.attackBonus, value: 5, duration: 1,
        branchA: AbilityBranch(
          id: 'a', name: 'Overwhelming Force',
          description: '+7 ATK for 2 rounds — capitalize on every opening.',
          valueDelta: 2, durationDelta: 1,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Precision Strike',
          description: '+4 ATK for 1r and lands an extra d6 bonus hit simultaneously.',
          valueDelta: -1,
          secondaryEffect: AbilityEffect.bonusDamage, secondaryValue: 6,
        ),
      ),
      HeroAbility(
        id: 'fighter_3', name: 'Disarming Strike',
        description: 'Knock the weapon aside — enemy skips its next turn.',
        cooldownRounds: 7, levelRequired: 10,
        effect: AbilityEffect.stun, value: 0, duration: 1,
        branchA: AbilityBranch(
          id: 'a', name: 'Extended Disarm',
          description: 'The enemy scrambles helplessly — stunned for 2 turns.',
          durationDelta: 1,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Disarming Counter',
          description: 'Stuns 1 turn and the opening lets you raise your guard — +4 AC for 2r.',
          secondaryEffect: AbilityEffect.acBonus, secondaryValue: 4, secondaryDuration: 2,
        ),
      ),
    ],

    DndClass.monk: [
      HeroAbility(
        id: 'monk_1', name: 'Flurry of Blows',
        description: 'A rapid flurry deals +d6 bonus damage.',
        cooldownRounds: 3, levelRequired: 1,
        effect: AbilityEffect.bonusDamage, value: 6,
        branchA: AbilityBranch(
          id: 'a', name: 'Iron Fists',
          description: 'Hardened knuckles drive deeper — +3 more max damage.',
          valueDelta: 3,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Wind Barrage',
          description: 'The storm of blows disrupts the enemy — same damage +2 AC for 2r.',
          secondaryEffect: AbilityEffect.acBonus, secondaryValue: 2, secondaryDuration: 2,
        ),
      ),
      HeroAbility(
        id: 'monk_2', name: 'Stunning Strike',
        description: 'A precise blow stuns the enemy for 1 turn.',
        cooldownRounds: 6, levelRequired: 5,
        effect: AbilityEffect.stun, value: 0, duration: 1,
        branchA: AbilityBranch(
          id: 'a', name: 'Crippling Blow',
          description: 'Strike twice as deep — enemy is stunned for 2 turns.',
          durationDelta: 1,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Pressure Point',
          description: 'Stun 1 turn and the nerve strike triggers a bleed — DoT 8 dmg/r for 2r.',
          secondaryEffect: AbilityEffect.dot, secondaryValue: 8, secondaryDuration: 2,
        ),
      ),
      HeroAbility(
        id: 'monk_3', name: 'Empty Body',
        description: 'Become ethereal — dodge the next enemy attack.',
        cooldownRounds: 8, levelRequired: 10,
        effect: AbilityEffect.dodge, value: 0, duration: 1,
        branchA: AbilityBranch(
          id: 'a', name: 'Phase Strike',
          description: 'Dodge and re-emerge with lethal precision — +3 ATK for 2r.',
          secondaryEffect: AbilityEffect.attackBonus, secondaryValue: 3, secondaryDuration: 2,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Ethereal Strike',
          description: 'Phase through and deliver a ghostly d8 bonus hit on return.',
          secondaryEffect: AbilityEffect.bonusDamage, secondaryValue: 8,
        ),
      ),
    ],

    DndClass.paladin: [
      HeroAbility(
        id: 'paladin_1', name: 'Divine Smite',
        description: 'Smite with holy power for +d8 radiant damage.',
        cooldownRounds: 4, levelRequired: 1,
        effect: AbilityEffect.bonusDamage, value: 8,
        branchA: AbilityBranch(
          id: 'a', name: 'Holy Smite',
          description: 'Pure concentrated radiance — +3 more max damage.',
          valueDelta: 3,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Blinding Smite',
          description: 'Slightly lower damage but the holy flash blinds the enemy — stun 1 turn.',
          valueDelta: -2,
          secondaryEffect: AbilityEffect.stun, secondaryDuration: 1,
        ),
      ),
      HeroAbility(
        id: 'paladin_2', name: 'Lay on Hands',
        description: 'Sacred touch restores 25% max HP.',
        cooldownRounds: 6, levelRequired: 5,
        effect: AbilityEffect.heal, value: 25,
        branchA: AbilityBranch(
          id: 'a', name: 'Sacred Mending',
          description: 'The healing light surges — restores 35% HP.',
          valueDelta: 10,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Aura of Healing',
          description: 'Restores 20% HP and the holy aura lingers — +3 AC for 2r.',
          valueDelta: -5,
          secondaryEffect: AbilityEffect.acBonus, secondaryValue: 3, secondaryDuration: 2,
        ),
      ),
      HeroAbility(
        id: 'paladin_3', name: 'Aura of Protection',
        description: '+3 AC for 4 rounds.',
        cooldownRounds: 8, levelRequired: 10,
        effect: AbilityEffect.acBonus, value: 3, duration: 4,
        branchA: AbilityBranch(
          id: 'a', name: 'Greater Aura',
          description: '+4 AC for 5 rounds — a nearly impenetrable divine shield.',
          valueDelta: 1, durationDelta: 1,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Retributive Aura',
          description: '+3 AC for 4r and the aura retaliates — lands a d6 bonus hit.',
          secondaryEffect: AbilityEffect.bonusDamage, secondaryValue: 6,
        ),
      ),
    ],

    DndClass.ranger: [
      HeroAbility(
        id: 'ranger_1', name: "Hunter's Mark",
        description: 'Mark the prey — deal 8 damage per round for 3 rounds.',
        cooldownRounds: 5, levelRequired: 1,
        effect: AbilityEffect.dot, value: 8, duration: 3,
        branchA: AbilityBranch(
          id: 'a', name: "Predator's Mark",
          description: 'The mark burns deeper — 12 dmg/r for 3 rounds.',
          valueDelta: 4,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Marked Prey',
          description: '8 dmg/r for 4 rounds and the targeting grants +2 AC for 2r.',
          durationDelta: 1,
          secondaryEffect: AbilityEffect.acBonus, secondaryValue: 2, secondaryDuration: 2,
        ),
      ),
      HeroAbility(
        id: 'ranger_2', name: 'Ensnaring Strike',
        description: 'A vine-wrapped arrow roots the prey in place — they skip their next turn.',
        cooldownRounds: 5, levelRequired: 5,
        effect: AbilityEffect.stun, value: 0, duration: 1,
        branchA: AbilityBranch(
          id: 'a', name: 'Binding Vines',
          description: 'Thicker vines — the enemy is rooted for 2 full turns.',
          durationDelta: 1,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Poison Trap',
          description: 'Stun 1 turn and the barbed arrow poisons — DoT 8 dmg/r for 3r.',
          secondaryEffect: AbilityEffect.dot, secondaryValue: 8, secondaryDuration: 3,
        ),
      ),
      HeroAbility(
        id: 'ranger_3', name: 'Foe Slayer',
        description: 'Exploit a weakness — deal +d10 bonus damage.',
        cooldownRounds: 8, levelRequired: 10,
        effect: AbilityEffect.bonusDamage, value: 10,
        branchA: AbilityBranch(
          id: 'a', name: 'Slaying Shot',
          description: 'A perfectly placed arrow — +3 more max damage.',
          valueDelta: 3,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Piercing Arrow',
          description: 'Slightly lower hit but the arrow tears through — DoT 10 dmg/r for 2r.',
          valueDelta: -2,
          secondaryEffect: AbilityEffect.dot, secondaryValue: 10, secondaryDuration: 2,
        ),
      ),
    ],

    DndClass.rogue: [
      HeroAbility(
        id: 'rogue_1', name: 'Sneak Attack',
        description: 'Strike from the shadows for +d6 bonus damage.',
        cooldownRounds: 3, levelRequired: 1,
        effect: AbilityEffect.bonusDamage, value: 6,
        branchA: AbilityBranch(
          id: 'a', name: 'Deadly Strike',
          description: 'A deeper thrust — +3 more max damage.',
          valueDelta: 3,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Poisoned Blade',
          description: 'Same damage plus a coating of poison — DoT 6 dmg/r for 3r.',
          secondaryEffect: AbilityEffect.dot, secondaryValue: 6, secondaryDuration: 3,
        ),
      ),
      HeroAbility(
        id: 'rogue_2', name: 'Evasion',
        description: 'Dodge the next incoming attack entirely.',
        cooldownRounds: 6, levelRequired: 5,
        effect: AbilityEffect.dodge, value: 0, duration: 1,
        branchA: AbilityBranch(
          id: 'a', name: 'Shadow Step',
          description: 'Dodge and reposition into striking range — +3 ATK for 2r.',
          secondaryEffect: AbilityEffect.attackBonus, secondaryValue: 3, secondaryDuration: 2,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Acrobatic Escape',
          description: 'Dodge and roll into a defensive stance — +3 AC for 2r.',
          secondaryEffect: AbilityEffect.acBonus, secondaryValue: 3, secondaryDuration: 2,
        ),
      ),
      HeroAbility(
        id: 'rogue_3', name: 'Death Strike',
        description: 'A lethal blow from the dark — +d12 bonus damage.',
        cooldownRounds: 8, levelRequired: 10,
        effect: AbilityEffect.bonusDamage, value: 12,
        branchA: AbilityBranch(
          id: 'a', name: 'Coup de Grâce',
          description: 'Truly lethal — +3 more max damage.',
          valueDelta: 3,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Shadow Execution',
          description: 'Slightly lower damage but the shock leaves the enemy stunned for 1 turn.',
          valueDelta: -4,
          secondaryEffect: AbilityEffect.stun, secondaryDuration: 1,
        ),
      ),
    ],

    DndClass.sorcerer: [
      HeroAbility(
        id: 'sorcerer_1', name: 'Fire Bolt',
        description: 'Hurl a mote of fire for +d10 damage.',
        cooldownRounds: 3, levelRequired: 1,
        effect: AbilityEffect.bonusDamage, value: 10,
        branchA: AbilityBranch(
          id: 'a', name: 'Scorching Bolt',
          description: 'A superheated blast — +3 more max damage.',
          valueDelta: 3,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Burning Bolt',
          description: 'Slightly lower hit but leaves burning embers — DoT 8 dmg/r for 2r.',
          valueDelta: -2,
          secondaryEffect: AbilityEffect.dot, secondaryValue: 8, secondaryDuration: 2,
        ),
      ),
      HeroAbility(
        id: 'sorcerer_2', name: 'Arcane Surge',
        description: 'Tap raw arcane power — +5 to attack rolls for 2 rounds.',
        cooldownRounds: 5, levelRequired: 5,
        effect: AbilityEffect.attackBonus, value: 5, duration: 2,
        branchA: AbilityBranch(
          id: 'a', name: 'Wild Surge',
          description: 'Uncontrolled sorcery amplified — +6 ATK for 3 rounds.',
          valueDelta: 1, durationDelta: 1,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Chaos Surge',
          description: '+4 ATK for 2r and wild magic discharges a d6 bonus hit.',
          valueDelta: -1,
          secondaryEffect: AbilityEffect.bonusDamage, secondaryValue: 6,
        ),
      ),
      HeroAbility(
        id: 'sorcerer_3', name: 'Fireball',
        description: 'An explosive blast deals +d12 bonus damage.',
        cooldownRounds: 8, levelRequired: 10,
        effect: AbilityEffect.bonusDamage, value: 12,
        branchA: AbilityBranch(
          id: 'a', name: 'Empowered Fireball',
          description: 'Maximum metamagic — +3 more max damage.',
          valueDelta: 3,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Spreading Flames',
          description: 'Slightly lower burst but spreading fire lingers — DoT 10 dmg/r for 2r.',
          valueDelta: -2,
          secondaryEffect: AbilityEffect.dot, secondaryValue: 10, secondaryDuration: 2,
        ),
      ),
    ],

    DndClass.warlock: [
      HeroAbility(
        id: 'warlock_1', name: 'Eldritch Blast',
        description: 'Crackling force energy deals +d10 damage.',
        cooldownRounds: 3, levelRequired: 1,
        effect: AbilityEffect.bonusDamage, value: 10,
        branchA: AbilityBranch(
          id: 'a', name: 'Agonizing Blast',
          description: 'Agonizing invocation — +3 more max damage.',
          valueDelta: 3,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Repelling Blast',
          description: 'Slightly lower force but the impact hurls the foe — stun 1 turn.',
          valueDelta: -2,
          secondaryEffect: AbilityEffect.stun, secondaryDuration: 1,
        ),
      ),
      HeroAbility(
        id: 'warlock_2', name: 'Hex',
        description: 'Curse the target — 8 damage per round for 4 rounds.',
        cooldownRounds: 5, levelRequired: 5,
        effect: AbilityEffect.dot, value: 8, duration: 4,
        branchA: AbilityBranch(
          id: 'a', name: 'Greater Hex',
          description: 'A deeper curse — 12 dmg/r for 4 rounds.',
          valueDelta: 4,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Death Knell',
          description: '8 dmg/r for 5 rounds and the hex empowers the warlock — +3 ATK for 2r.',
          durationDelta: 1,
          secondaryEffect: AbilityEffect.attackBonus, secondaryValue: 3, secondaryDuration: 2,
        ),
      ),
      HeroAbility(
        id: 'warlock_3', name: 'Hunger of Hadar',
        description: 'Void tentacles deal 14 damage per round for 4 rounds.',
        cooldownRounds: 8, levelRequired: 10,
        effect: AbilityEffect.dot, value: 14, duration: 4,
        branchA: AbilityBranch(
          id: 'a', name: 'Void Hunger',
          description: 'The void tears deeper — 18 dmg/r for 4 rounds.',
          valueDelta: 4,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Consuming Darkness',
          description: '14 dmg/r for 5 rounds and the darkness overwhelms — stun 1 turn.',
          durationDelta: 1,
          secondaryEffect: AbilityEffect.stun, secondaryDuration: 1,
        ),
      ),
    ],

    DndClass.wizard: [
      HeroAbility(
        id: 'wizard_1', name: 'Arcane Focus',
        description: 'Sharpen your aim with arcane precision — +3 to attack rolls for 3 rounds.',
        cooldownRounds: 3, levelRequired: 1,
        effect: AbilityEffect.attackBonus, value: 3, duration: 3,
        branchA: AbilityBranch(
          id: 'a', name: 'Focused Mind',
          description: 'Perfect concentration — +4 ATK for 4 rounds.',
          valueDelta: 1, durationDelta: 1,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Arcane Precision',
          description: '+3 ATK for 3r and arcane energy discharges a d6 bonus hit.',
          secondaryEffect: AbilityEffect.bonusDamage, secondaryValue: 6,
        ),
      ),
      HeroAbility(
        id: 'wizard_2', name: 'Shield',
        description: 'An arcane barrier grants +5 AC for 2 rounds.',
        cooldownRounds: 5, levelRequired: 5,
        effect: AbilityEffect.acBonus, value: 5, duration: 2,
        branchA: AbilityBranch(
          id: 'a', name: 'Greater Shield',
          description: 'Reinforced barrier — +6 AC for 3 rounds.',
          valueDelta: 1, durationDelta: 1,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Mirror Image',
          description: '+5 AC for 2r and illusory doubles guarantee the next hit is dodged.',
          secondaryEffect: AbilityEffect.dodge,
        ),
      ),
      HeroAbility(
        id: 'wizard_3', name: 'Disintegrate',
        description: 'Obliterate the foe with +d12 arcane damage.',
        cooldownRounds: 8, levelRequired: 10,
        effect: AbilityEffect.bonusDamage, value: 12,
        branchA: AbilityBranch(
          id: 'a', name: 'Complete Disintegration',
          description: 'Nothing remains — +3 more max damage.',
          valueDelta: 3,
        ),
        branchB: AbilityBranch(
          id: 'b', name: 'Petrifying Ray',
          description: 'Partial disintegration petrifies — lower damage but stuns for 2 turns.',
          valueDelta: -4,
          secondaryEffect: AbilityEffect.stun, secondaryDuration: 2,
        ),
      ),
    ],
  };

  static List<HeroAbility> forClass(DndClass cls) => _abilities[cls] ?? const [];

  static List<HeroAbility> unlockedFor(DndClass cls, int heroLevel) =>
      forClass(cls).where((a) => heroLevel >= a.levelRequired).toList();
}
