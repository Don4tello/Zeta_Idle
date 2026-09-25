/// In-app patch notes shown in the "What's New" sheet (Hero header).
/// Newest first. Keep entries short and player-facing. Bump when you ship.
class PatchNote {
  const PatchNote({
    required this.build,
    required this.title,
    required this.date,
    required this.changes,
  });

  final int build;          // pubspec build number (versionCode)
  final String title;       // short headline
  final String date;        // YYYY-MM-DD
  final List<String> changes;
}

/// The most recent build number — used for the "NEW" badge.
int get kLatestPatchBuild => kPatchNotes.first.build;

const kPatchNotes = <PatchNote>[
  PatchNote(
    build: 298,
    title: 'Toggle Auto Run Mid-Dungeon',
    date: '2026-09-24',
    changes: [
      'The Auto Run button is now available INSIDE a dungeon run, not just from '
          'the lobby — flip it on if you forgot, or turn it off any time to take '
          'manual control of doors, rooms and relics.',
    ],
  ),
  PatchNote(
    build: 297,
    title: 'Tower Ascension Bites Back',
    date: '2026-09-24',
    changes: [
      'Tower Ascension bosses now scale their level with the tier, so at higher '
          'tiers they can actually land hits and threaten you — before, they '
          'couldn\'t touch a high-level hero and every climb ended at full HP.',
      'PvP arena fights are now tracked (behind the scenes) so the mode can be '
          'balanced properly.',
    ],
  ),
  PatchNote(
    build: 296,
    title: 'Boss Rush Difficulty Dialed In',
    date: '2026-09-24',
    changes: [
      'After the last fix removed the marathon HP, high-tier Boss Rush became '
          'too easy (a full clear in a handful of rounds). Higher tiers now ramp '
          'up on an accelerating curve so they stay a real fight.',
    ],
  ),
  PatchNote(
    build: 295,
    title: 'Boss Rush No Longer a Marathon',
    date: '2026-09-24',
    changes: [
      'Fixed Boss Rush bosses being wildly over-inflated on HP — a bug was '
          'stacking the campaign tier curve on top of Boss Rush\'s own tier '
          'scaling, turning runs into 200–500+ round slogs and making high-tier '
          'bosses nearly unkillable.',
      'Boss Rush now scales cleanly by tier again, so fights are a sane length.',
    ],
  ),
  PatchNote(
    build: 294,
    title: 'Attribute Breakdown on the Bonus Sheet',
    date: '2026-09-23',
    changes: [
      'The Bonuses sheet has a new ATTRIBUTE BREAKDOWN — tap any of STR/DEX/CON/'
          'INT/WIS/CHA to see exactly where it comes from: base score vs gear, '
          'set and gem bonuses, plus what it grants.',
      'Fixed the Damage Types breakdown to show your true (gear-included) damage '
          '%, and removed a stale "Vitality (VIT)" leftover.',
    ],
  ),
  PatchNote(
    build: 293,
    title: 'Ability Scores Renamed',
    date: '2026-09-23',
    changes: [
      'The gold-bought Ability Scores now have clear, functional names so they '
          'can’t be confused with your character attributes: Attack, Might, '
          'Health, Vigor, Armor, Ward (were Power/Wrath/Vitality/Endurance/'
          'Fortitude/Durability).',
      'Your invested ranks and their effects are unchanged — only the names.',
    ],
  ),
  PatchNote(
    build: 292,
    title: 'One Name Per Stat',
    date: '2026-09-23',
    changes: [
      'Attributes now use the same names everywhere — items, forge, inventory, '
          'character select and the home panel all show STR/DEX/CON/INT/WIS/CHA '
          'to match the Hero Sheet (no more PWR/AGI/FOC/FOR aliases).',
      'So an item’s "+WIS" or "+CHA" clearly matches the WIS/CHA on your Hero '
          'Sheet.',
    ],
  ),
  PatchNote(
    build: 291,
    title: 'Gear Fully Powers Your Attributes',
    date: '2026-09-23',
    changes: [
      'The Hero Sheet now shows your EFFECTIVE attributes (base + gear), so '
          'equipping a +STR/+DEX item visibly raises the stat and its listed '
          'effects.',
      'Gear attribute bonuses now also boost your damage % (they already fed '
          'resistance, dodge, DoT, heal-over-time and cooldown-skip) — so an '
          'item’s +STR fully counts everywhere.',
    ],
  ),
  PatchNote(
    build: 290,
    title: 'Ability Scores: Deeper & Pricier',
    date: '2026-09-23',
    changes: [
      'Ability Score rank cap raised from 100 to 250 — a lot more permanent '
          'power to chase.',
      'Score costs now climb on a steep curve, so maxing them is a real '
          'long-haul gold sink instead of an early throwaway (roughly maxed '
          'around hero level 500).',
    ],
  ),
  PatchNote(
    build: 289,
    title: 'Never Lose a Character Again',
    date: '2026-09-23',
    changes: [
      'Added a protected backup that keeps a copy of your highest-level save and '
          'can never be overwritten by a low-level one.',
      'If a load glitch ever drops your character to level 1, the game now '
          'automatically restores it from that backup on the next launch.',
    ],
  ),
  PatchNote(
    build: 287,
    title: 'Frontier Tuning: Bosses, Not Slogs',
    date: '2026-09-23',
    changes: [
      'The tier 4+ durability boost now applies to BOSSES only — regular '
          'enemies are fast again (they were dragging out to 15+ rounds at deep '
          'high-tier stages).',
      'Eased the high-tier boss HP ramp so late-tier bosses are a real fight '
          'without turning into a 40+ round slog. Mid-tier boss fights stay '
          'meaty.',
    ],
  ),
  PatchNote(
    build: 286,
    title: 'Frontier Bosses Bite Back',
    date: '2026-09-23',
    changes: [
      'High-tier bosses (Tier 4+) are much tankier so the fight actually lasts — '
          'a near-maxed hero was one-shotting them before their damage could '
          'matter. Tiers 0–3 are unchanged.',
      'This only adds boss durability (not damage), and rewards are unaffected — '
          'gold, XP and loot scale off enemy level, not HP.',
    ],
  ),
  PatchNote(
    build: 285,
    title: 'Every Tier Keeps Its Own Progress',
    date: '2026-09-23',
    changes: [
      'Each difficulty tier now remembers its own campaign stage. Switching '
          'tiers resumes right where you left off in that tier instead of '
          'starting over.',
      'Clearing stage 100 and unlocking a new tier ONLY resets the new tier to '
          'stage 1 — the tier you just beat stays parked at the Omega, so hopping '
          'back never wipes your place.',
    ],
  ),
  PatchNote(
    build: 284,
    title: 'One Difficulty Tier, Whole Game',
    date: '2026-09-22',
    changes: [
      'Your difficulty tier is now GLOBAL. Set it once and it applies '
          'everywhere — Campaign, Dungeon, Boss Rush, Gauntlet and Tower '
          'Ascension all share the same tier, and you carry every tier bonus '
          'into each mode.',
      'Higher tiers now raise the HP AND damage of every monster in every mode '
          '(not just the campaign), so the whole game ramps together.',
      'Dungeon and Boss Rush gained the same tier selector as the campaign, '
          'defaulting to your current global tier.',
      'Rewards across all modes pay out on the single accelerating tier curve — '
          'no more per-mode tier bookkeeping.',
    ],
  ),
  PatchNote(
    build: 283,
    title: 'Higher Tiers, Bigger Rewards',
    date: '2026-09-14',
    changes: [
      'Gauntlet, Boss Rush and Dungeon rewards now scale on one unified curve '
          'that ACCELERATES with difficulty — pushing to higher tiers pays off '
          'disproportionately (tier 10 is ~16× the base). The old separate '
          '"rebirth" bonus is folded into the tier itself.',
      'Dungeon gold and shards now scale with the tier too (they were flat before), '
          'so deeper tiers are finally worth running.',
    ],
  ),
  PatchNote(
    build: 282,
    title: 'Dungeon: No More Wasted Attempts',
    date: '2026-09-14',
    changes: [
      'Fixed a case where starting a dungeon while one was already active could '
          'silently discard the run and waste your attempt (double-tap / Auto-Run '
          'race). Entering now never throws away an in-progress run.',
    ],
  ),
  PatchNote(
    build: 281,
    title: 'Even Gear Stats + Attributes Are Reference-Only',
    date: '2026-09-14',
    changes: [
      'Rebalanced gear stat pools so all six attributes (STR/DEX/CON/INT/WIS/CHA) '
          'can roll on a fair spread of slots — Fire (CHA) and Void (INT) builds '
          'are no longer starved for gear, and Strength shows up on armour too.',
      'Attributes are now shown for reference only on the Hero and Bonuses '
          'sheets — they come from gear, specialization and traits, not a direct '
          'gold upgrade.',
    ],
  ),
  PatchNote(
    build: 280,
    title: 'Attributes Explained + Strength Reworked',
    date: '2026-09-14',
    changes: [
      'Your core attributes (STR, DEX, CON, INT, WIS, CHA) are now shown on the '
          'Hero dashboard and the Bonuses sheet — tap any to see exactly what it '
          'improves (its damage type, resistance, and its special effect like '
          'dodge, DoT, healing or cooldown skips).',
      'Strength reworked: since Physical is retired, STR is now the universal '
          'weapon-power stat — +1 flat damage to EVERY hit (any element) and +1 '
          'armor per point. It matters for every build now.',
      'New coach: when you finish your class questline and unlock your Ultimate '
          'ability, a tip explains how it works.',
    ],
  ),
  PatchNote(
    build: 279,
    title: 'Energy: Grows With Your Level + Fair Purchases',
    date: '2026-09-14',
    changes: [
      'Your max energy now grows as you level — starting at 20 and gaining +1 per '
          'level up to 60. Each level-up grants that energy right away, so energy '
          'scales with your progress instead of being a flat cap.',
      'Buying energy with ZCoins now always grants the full +20 and can go OVER '
          'your current cap (e.g. 45/50 → 65/50), so a purchase is never partly '
          'wasted. Natural regen and the free daily refill still top up only to '
          'the cap.',
    ],
  ),
  PatchNote(
    build: 278,
    title: 'Cloud Sign-in at Launch',
    date: '2026-09-14',
    changes: [
      'The game now signs in (anonymously) at startup instead of waiting until you '
          'open Guild/PvP/Cloud Save — so cloud features are ready the moment you '
          'need them. No account or personal info required.',
    ],
  ),
  PatchNote(
    build: 277,
    title: 'Behind-the-scenes Balance Tools',
    date: '2026-09-14',
    changes: [
      'Added optional, privacy-light play telemetry so we can tune difficulty and '
          'balance faster from real play. No gameplay changes — it only records '
          'anonymous fight stats (rounds, HP, damage) and is off by default.',
    ],
  ),
  PatchNote(
    build: 276,
    title: 'Guild Boss Fight Polish',
    date: '2026-09-14',
    changes: [
      'Fixed the "Return to Guild" button after a Guild Boss fight being tucked '
          'behind the phone\'s navigation bar and hard to tap. It now sits above '
          'the system bar.',
      'Removed the on-screen battle log from the Guild Boss fight so it matches '
          'the Campaign and other modes (arena + floating damage numbers).',
    ],
  ),
  PatchNote(
    build: 275,
    title: 'Dungeon Fix + Combat Telemetry',
    date: '2026-09-14',
    changes: [
      'Fixed the Dungeon results screen falsely showing "Tier cleared — AUTO '
          'unlocked" after you died partway. It now only says cleared when you '
          'actually defeat the Dungeon Lord (which was always the real unlock rule).',
      'Added balance telemetry to Gauntlet, Boss Rush, Guild and Dungeon so run '
          'stats can be reviewed and tuned like the campaign.',
    ],
  ),
  PatchNote(
    build: 274,
    title: 'Combat Polish + New Tutorials',
    date: '2026-09-14',
    changes: [
      'DoT abilities (Fire/Poison and generic damage-over-time) now tick each '
          'round for their duration in Gauntlet, Boss Rush and Guild — like the '
          'campaign — instead of a single instant hit. Poison stacks.',
      'Ability damage now respects enemy resistance in the alternate modes, '
          'matching your auto-attacks.',
      'Fixed a Gauntlet quirk where the attack-buff ability granted extra crit '
          'chance on top of its damage bonus — it is now a pure % damage buff, '
          'consistent with every other mode.',
      'New coach tips: Damage Types, Status Ailments, and Guilds.',
    ],
  ),
  PatchNote(
    build: 273,
    title: 'Milestone Choices Now Work in Every Mode',
    date: '2026-09-14',
    changes: [
      'Fixed: the milestone rider you pick at ability rank 5/10/15 (the "+stun", '
          '"+damage over time", "+vulnerable", etc. option) now actually fires in '
          'Gauntlet, Boss Rush, Guild and Dungeon — before, only the campaign '
          'applied it, so those choices did nothing outside it.',
    ],
  ),
  PatchNote(
    build: 272,
    title: 'Unified Combat Engine (Alt-Modes)',
    date: '2026-09-14',
    changes: [
      'Gauntlet, Boss Rush and Guild now share one ability engine with the '
          'campaign, so effects behave consistently across modes.',
      'Barrier abilities (absorb shields) are now real damage barriers in every '
          'mode — they soak hits instead of just topping up HP.',
      'Thorns (Thorn Wall) now reflects damage in Gauntlet, Boss Rush, Guild and '
          'Dungeon, not just the campaign.',
      'PvP and Dungeon simulations now respect crowd-control diminishing returns — '
          'no more theoretical perma-stun locks.',
    ],
  ),
  PatchNote(
    build: 271,
    title: 'Alt-Mode Combat Fixes: Healing & Lifesteal',
    date: '2026-09-14',
    changes: [
      'Fixed: heal & aura abilities in Gauntlet, Boss Rush, Guild and Dungeon now '
          'scale off your Heal Rating exactly like the campaign — heal builds were '
          'restoring almost nothing in these modes.',
      'Lifesteal now works in every combat mode (it was campaign-only before).',
      'Ability buff wording cleaned up: milestones that said "+2 more ATK" now '
          'correctly read "+2% more DMG" — the buff was always a % damage boost, '
          'the label was just misleading.',
    ],
  ),
  PatchNote(
    build: 270,
    title: 'More Elemental Ailments: Burning, Envenomed & Withered',
    date: '2026-09-14',
    changes: [
      '🔥 Burning (Fire) — sets the enemy alight for heavy damage over time.',
      '☠ Envenomed (Poison) — a STACKING poison: the longer you keep it up, the '
          'harder it ticks (up to ~5 stacks).',
      '🟣 Withered (Void) — saps the enemy\'s attack power (a soft −ATK debuff, up '
          'to −60%). Unlike a disarm it isn\'t crowd control, so it has no '
          'diminishing returns — reliable damage mitigation.',
      'Fire, poison and void ability milestones across every class now apply these '
          'ailments instead of a generic DoT / weaken, matching their element.',
    ],
  ),
  PatchNote(
    build: 269,
    title: 'Elemental Crowd Control: Frozen & Shocked',
    date: '2026-09-14',
    changes: [
      'New elemental status effects: Cold attacks can FREEZE the enemy (skips its '
          'turn, like a stun) and Lightning attacks can SHOCK it (skips its turn '
          'AND makes it take +25% damage while shocked).',
      'Cold and lightning ability milestones across every class now apply Freeze / '
          'Shock instead of a plain stun. Like all hard crowd control, they share '
          'the same diminishing returns — they can\'t be chained forever.',
    ],
  ),
  PatchNote(
    build: 268,
    title: 'Cooldown & Duration Buffs Are Now Rare',
    date: '2026-09-14',
    changes: [
      'Ascension no longer extends ability durations — it only boosts their power '
          '(damage / healing).',
      'Cooldown reduction is now a premium, limited bonus: abilities no longer '
          'auto-speed-up as you rank them, and the total cooldown any build can '
          'shave is capped — so low cooldowns feel special, not standard.',
    ],
  ),
  PatchNote(
    build: 267,
    title: 'Ability Duration Can\'t Exceed Cooldown',
    date: '2026-09-14',
    changes: [
      'An ability\'s effect can no longer last as long as (or longer than) its '
          'cooldown — durations are now always capped just below the cooldown, so '
          'there\'s always downtime. This kicks in even when several '
          'duration-extending milestones stack.',
    ],
  ),
  PatchNote(
    build: 266,
    title: 'Milestones Show the Exact Number',
    date: '2026-09-14',
    changes: [
      'Milestone options now show the exact change at your current rank — e.g. '
          '"+12,340 damage", "+8,500 HP", or "+15% weaken (to 40%)" — instead of '
          'vague "greatly increases" wording. Updates live as your ability ranks '
          'and gear change.',
    ],
  ),
  PatchNote(
    build: 264,
    title: 'Every Ability Milestone Rebalanced',
    date: '2026-09-14',
    changes: [
      'Finished rebalancing milestone choices across all 12 classes so each is a '
          'real decision, not an obvious pick. "More damage/weaken/attack" options '
          'are now genuinely powerful (not tiny +3/+4/+5 bumps); small +3 AC/ATK '
          'riders were bumped to +12%; and milestones that gave damage AND a stun '
          'were split into a clean "big damage" vs "control" choice.',
      'Element-choice milestones (pick your damage type) were left as-is — the '
          'element itself is the meaningful decision there.',
    ],
  ),
  PatchNote(
    build: 262,
    title: 'Bard Milestone Choices Rebalanced',
    date: '2026-09-14',
    changes: [
      'Ability milestone choices should be real decisions, not obvious picks. '
          'Reworked the Bard\'s milestones so the "more damage" options are '
          'genuinely powerful spikes (not tiny +4/+6), and removed cases where one '
          'side gave damage AND control while the other gave only one. More classes '
          'to follow.',
    ],
  ),
  PatchNote(
    build: 261,
    title: 'Paragon Board: Flat 1-Point Cost',
    date: '2026-09-14',
    changes: [
      'Every rank on the Paragon board now costs exactly 1 Paragon Point (no more '
          'escalating cost). Removed the Precision and Ferocity nodes; Might and the '
          'other stats remain.',
    ],
  ),
  PatchNote(
    build: 260,
    title: 'Ability Scores Capped at Rank 100',
    date: '2026-09-14',
    changes: [
      'Ability Scores now max out at rank 100 (was 1000). Each rank is powerful, '
          'so this keeps them in balance. Any ranks previously bought above 100 are '
          'capped to 100 in effect.',
    ],
  ),
  PatchNote(
    build: 259,
    title: 'CC Diminishing Returns in Every Mode',
    date: '2026-09-14',
    changes: [
      'Stun and silence now diminish (and eventually resist) in Boss Rush, '
          'Dungeon, Gauntlet and Guild too — matching the campaign. You can\'t '
          'perma-lock bosses in any mode anymore.',
    ],
  ),
  PatchNote(
    build: 258,
    title: 'Silence Joins the CC Diminishing Returns',
    date: '2026-09-14',
    changes: [
      'Silence (which locks out an enemy\'s abilities) now shares the same '
          'diminishing returns as stun and disarm — so you can no longer keep a '
          'boss\'s abilities permanently shut off. All hard crowd control now draws '
          'from one shared pool.',
    ],
  ),
  PatchNote(
    build: 257,
    title: 'Disarm Shares Stun\'s Diminishing Returns',
    date: '2026-09-14',
    changes: [
      'All full crowd control now follows one rule: stun and full Disarm share the '
          'same diminishing returns — full effect the first time, halved the '
          'second, then briefly immune — so nothing can be chained to keep an '
          'enemy permanently stunned or disarmed. Partial ATK-reduction is '
          'unaffected.',
    ],
  ),
  PatchNote(
    build: 255,
    title: 'Bosses Can No Longer Be Perma-Locked',
    date: '2026-09-14',
    changes: [
      'Stun and guaranteed-dodge could chain-lock a boss so it never landed a '
          'hit. Now, after a boss has 2 attacks skipped or avoided in a row, its '
          'next attack is UNSTOPPABLE — it breaks through stun, dodge and evasion '
          '(still reduced by Armor). Control abilities still work; they just can\'t '
          'make a boss completely harmless.',
    ],
  ),
  PatchNote(
    build: 254,
    title: 'Enemies Can Actually Hit You Now',
    date: '2026-09-14',
    changes: [
      'Fixed the real reason bosses felt harmless: dodge, Shadow Step, Void Step '
          'and enemy miss-chance were separate rolls that multiplied together into '
          'near-total avoidance (a maxed hero could take zero damage across a whole '
          'boss fight). They\'re now one combined roll, capped at 60% — so enemies '
          'always land a meaningful share of their attacks.',
    ],
  ),
  PatchNote(
    build: 248,
    title: 'Paragon Perks Gated by Board Investment',
    date: '2026-09-06',
    changes: [
      'The powerful Paragon perks now unlock as you invest in the Paragon board: '
          'Iron Resolve at 50 points spent, Killing Blow at 100, Blood Drinker at '
          '200, Death\'s Edge at 350, and Destroyer at 500. Each perk shows its '
          'requirement and your progress.',
    ],
  ),
  PatchNote(
    build: 241,
    title: 'Heal Rating Tuned + Bosses Hit Harder',
    date: '2026-09-06',
    changes: [
      'Fixed the Vitalist Paragon being wildly over-tuned (was inflating Heal '
          'Rating ~20×). Healing is now a partial top-up, not a full reset.',
      'Endgame bosses (tiers 1–10) now hit noticeably harder, so the finale '
          'actually threatens a maxed hero instead of a 2-round stomp. Bring your '
          'Armor and resistances.',
    ],
  ),
  PatchNote(
    build: 239,
    title: 'New System: Heal Rating',
    date: '2026-09-06',
    changes: [
      'Healing no longer scales off your max HP — it now scales off a new HEAL '
          'RATING stat, just like damage has its own rating. Every heal (abilities, '
          'auras, lifesteal, Field Triage) restores a multiple of your Heal Rating.',
      'Build Heal Rating from the brand-new VITALIST passive branch (flat rating, '
          '% rating, and the Eternal Font keystone that doubles your base), from a '
          'new Heal Rating affix on helmets/rings/amulets/relics, and from the new '
          'Vitalist Paragon node.',
      'If you don\'t invest in Heal Rating, healing is weak — so your HP pool is a '
          'real resource. See your Heal Rating on the Hero sheet.',
    ],
  ),
  PatchNote(
    build: 238,
    title: 'Bigger HP Pool, Slower Recovery',
    date: '2026-09-06',
    changes: [
      'Max HP now grows noticeably faster per level (~60% larger by endgame) — '
          'your health bar should finally feel like it\'s growing with you.',
      'Healing has been reined in across the board: lifesteal, heal abilities, '
          'regen auras and merc triage all restore less. Your big HP pool is now '
          'a resource that gets ground down over a fight instead of instantly '
          'topping back off — so enemy damage actually sticks.',
    ],
  ),
  PatchNote(
    build: 237,
    title: 'Fix: Boss Fight Crash',
    date: '2026-09-06',
    changes: [
      'Fixed a crash (grey screen) when entering a fight against an enemy with '
          'special abilities, introduced by the new elemental-threat display.',
    ],
  ),
  PatchNote(
    build: 236,
    title: 'See a Boss\'s Elemental Threats',
    date: '2026-09-06',
    changes: [
      'The enemy panel now shows the elements a boss will hit you with — small '
          'element icons next to its level. Use them to know which resistances '
          'to bring. (Basic attacks are physical and handled by your Armor, so '
          'they\'re not listed.)',
    ],
  ),
  PatchNote(
    build: 235,
    title: 'Basics Hit Physical, Abilities Hit Elements',
    date: '2026-09-06',
    changes: [
      'Every enemy\'s basic attack is now physical — mitigated by your Armor. '
          'Their special abilities carry the elemental damage, mitigated by your '
          'resistances. So Armor is your everyday defence and resistances counter '
          'the spike abilities.',
      'The finale (and the other endgame bosses) now hit multiple elements across '
          'their abilities, so no single resistance can wall the whole fight — '
          'you\'ll want broad defences to survive.',
      'Ability damage (bursts and damage-over-time) is now correctly mitigated by '
          'type — physical by Armor, elemental by resistance.',
    ],
  ),
  PatchNote(
    build: 234,
    title: 'Physical Retired (Armor is the Physical Defence)',
    date: '2026-09-06',
    changes: [
      'Cleaned up defences: physical is no longer a resistance — your Armor is '
          'now the single physical mitigation (no more armor + physical-resist '
          'double-dip). Heroes deal their class elements; resistances cover the 5 '
          'elements only.',
      'Removed the physical (onyx) gem and physical mastery. Enemies can still '
          'hit physically — that\'s exactly what Armor is for.',
    ],
  ),
  PatchNote(
    build: 233,
    title: 'Max HP Grows Much More',
    date: '2026-09-06',
    changes: [
      'Max HP now scales up far more with level — the per-level base grows '
          'super-linearly, so a high-level hero has a HP pool in the millions '
          'instead of a few hundred thousand. Every level feels like real growth, '
          'and bosses can land bigger, more meaningful hits.',
    ],
  ),
  PatchNote(
    build: 232,
    title: 'Endgame Bosses Hit Harder (pass 3)',
    date: '2026-09-06',
    changes: [
      'High-tier bosses now hit meaningfully harder. With healing and lifesteal '
          'finally bounded, the tier-10 boss can actually threaten a maxed hero '
          'instead of being out-sustained forever.',
    ],
  ),
  PatchNote(
    build: 231,
    title: 'Bounty Gate, Artifact Unlock, Blood Drinker',
    date: '2026-09-06',
    changes: [
      'Boss Bounties now correctly stay locked until stage 20 (they were '
          'reachable as soon as Challenges opened).',
      'Artifacts now unlock — with their own tutorial — the moment your first '
          'artifact drops, instead of quietly appearing on the mercenary stage.',
      'Blood Drinker (Paragon) reworked from a flat 5% heal-on-kill into 6% '
          'lifesteal, so it scales with your damage and respects the sustain cap.',
    ],
  ),
  PatchNote(
    build: 230,
    title: 'Lifesteal Cap + Miss-Chance Cap',
    date: '2026-09-06',
    changes: [
      'Lifesteal healing is now capped at 12% of your max HP per round. It was '
          'the hidden reason a maxed hero never dropped below full — at high '
          'damage even a sliver of lifesteal healed you completely every hit.',
      'Enemy miss-chance you inflict now caps at ~66%, so a boss can never be '
          'locked into missing forever.',
    ],
  ),
  PatchNote(
    build: 229,
    title: 'Resistance Cap → 90%',
    date: '2026-09-06',
    changes: [
      'Elemental resistance can now climb to 90% (matching the game\'s overall '
          'max damage reduction), still with diminishing returns so it takes heavy '
          'investment to get near the top.',
    ],
  ),
  PatchNote(
    build: 228,
    title: 'Resistance is now a Rating',
    date: '2026-09-06',
    changes: [
      'Elemental resistance now works like armour and dodge: a rating with '
          'diminishing returns, so the 75% cap is much harder to reach late-game.',
      'Stats and passives add flat resistance rating; mastery and gems boost the '
          'rating by a %. Investing in resistance always helps, but stacking to the '
          'cap now takes real commitment.',
    ],
  ),
  PatchNote(
    build: 227,
    title: 'Guild Damage + Higher Resist Cap',
    date: '2026-09-06',
    changes: [
      'The guild all-damage buff now boosts ALL your damage — auto-attacks and '
          'abilities alike.',
      'Elemental resistance can now reach 75% (up from 50%). With healing bounded, '
          'stacking resistance is a real defensive choice again.',
    ],
  ),
  PatchNote(
    build: 226,
    title: 'Systems Audit: Nothing Left Behind',
    date: '2026-09-06',
    changes: [
      'Swept every progression system to make sure it actually counts toward your '
          'stats. Fixed armour under-counting your CON upgrades in the side modes '
          'and on the Bonuses sheet, wired the guild all-damage buff into combat, '
          'and corrected the Bonuses sheet armour breakdown (was crediting DEX '
          'instead of STR) and the resistance cap it displayed.',
    ],
  ),
  PatchNote(
    build: 225,
    title: 'Healing is now a Rating',
    date: '2026-09-06',
    changes: [
      'Ability healing works like armour now: it uses a rating with diminishing '
          'returns and caps at 37.5% of your max HP per heal. Every "+% healing" '
          'bonus raises the rating instead of multiplying the heal.',
      'This ends the old "unkillable" infinite-sustain, so late-game bosses can '
          'finally threaten a maxed hero. (Boss attack was dialed back to match.)',
    ],
  ),
  PatchNote(
    build: 224,
    title: 'Endgame Bosses Hit Harder',
    date: '2026-09-06',
    changes: [
      'High-tier enemies now hit meaningfully harder so the late game actually '
          'threatens a maxed hero, instead of a long fight you never lose HP in.',
    ],
  ),
  PatchNote(
    build: 223,
    title: 'Tougher Endgame Tiers',
    date: '2026-09-06',
    changes: [
      'Tiers 1–10 have been tuned up so the late game keeps pace with a maxed '
          'hero — the tier-10 final boss is now a real, climactic fight instead of '
          'a one-round stomp.',
      'The higher the tier, the bigger the jump (tier 10 enemies are far tankier '
          'and hit harder); tier 0 is unchanged for new players.',
    ],
  ),
  PatchNote(
    build: 222,
    title: 'Removed the last damage caps',
    date: '2026-09-06',
    changes: [
      'Your hits were secretly capped at ~1 billion whenever an enemy was '
          'weakened/vulnerable (and in a few other spots). Removed those — damage, '
          'heals and DoTs now scale freely like everything else.',
    ],
  ),
  PatchNote(
    build: 221,
    title: 'Abilities: Tier + Ascension Unified',
    date: '2026-09-06',
    changes: [
      'Ability damage now counts BOTH tiering and ascension everywhere — the '
          'number you see on the ability card is the number you actually deal.',
      'Fixed a mismatch where the improved tier scaling only affected the '
          'displayed value and the ascension bonus only affected campaign '
          'fights — both now apply in campaign, the side modes, and the display.',
    ],
  ),
  PatchNote(
    build: 220,
    title: 'Ability Damage Rescaled & Uncapped',
    date: '2026-09-06',
    changes: [
      'Ability damage is no longer capped at 9,999 — it scales all the way up '
          'and shows the real numbers.',
      'Damage abilities now grow smoothly across tiers (no more dropping back '
          'down when you enter a new tier) and a tier-10 ability hits much harder '
          'than a tier-1 one.',
    ],
  ),
  PatchNote(
    build: 219,
    title: 'Welcome Back Icons',
    date: '2026-09-06',
    changes: [
      'The Welcome Back rewards now use the real currency icons — the gold coin '
          'and the ◆ Shards gem — instead of generic symbols.',
      'That "essence" line was actually Shards; it now reads and looks like Shards.',
    ],
  ),
  PatchNote(
    build: 218,
    title: 'Consistent Gold Coin',
    date: '2026-09-06',
    changes: [
      'The gold coin icon (the same pixel-art one from the top bar) now shows '
          'everywhere gold appears — Ability Scores, upgrade costs, the Forge, the '
          'Bonuses sheet and the idle income summary — replacing the old "\$" icon.',
      'Ability Scores now abbreviates big gold numbers (balance and upgrade cost).',
    ],
  ),
  PatchNote(
    build: 217,
    title: 'Billions & Trillions',
    date: '2026-09-06',
    changes: [
      'Huge numbers now abbreviate all the way up — billions show as "1.0B" and '
          'trillions as "1.0T" instead of awkward figures like "1000.1M".',
    ],
  ),
  PatchNote(
    build: 216,
    title: 'Income Summary Formatting',
    date: '2026-09-06',
    changes: [
      'The Income Summary on the Hero sheet now abbreviates big numbers — '
          'Shards, Echoes, Battle/kill and Expedition rewards read cleanly '
          '(e.g. 1.0B) instead of showing every digit.',
    ],
  ),
  PatchNote(
    build: 215,
    title: 'Ability Scores Reworked',
    date: '2026-09-06',
    changes: [
      'Reordered the Ability Scores: PWR · WRA · VIT · END · FOR · DUR.',
      'FOR (Fortitude) now grants flat Armor Class Rating (+1 per rank).',
      'LUCK is replaced by DUR (Durability): +0.5% Armor Class Rating per rank.',
    ],
  ),
  PatchNote(
    build: 214,
    title: 'Longer Idle: 24h + Deep Reserves',
    date: '2026-09-06',
    changes: [
      'Idle rewards now bank for a full 24 hours while you\'re away (up from 8h).',
      'New Paragon chain "Deep Reserves I–IV" (Mastery) extends the idle window '
          'by +6h each — up to a 48h maximum.',
    ],
  ),
  PatchNote(
    build: 213,
    title: 'Character Select Spacing',
    date: '2026-09-06',
    changes: [
      'Added breathing room at the bottom of the character list so the last slot '
          'no longer crowds the "swipe to delete" hint.',
    ],
  ),
  PatchNote(
    build: 212,
    title: 'Number Formatting Cleanup',
    date: '2026-09-06',
    changes: [
      'Big numbers now read consistently across the UI — the Welcome Back essence, '
          'the idle-collect chips, your Power score and the Shop ZCoin balance are '
          'abbreviated (e.g. 5.4M) instead of showing every digit.',
      'Fixed the idle gold chip that read like a weight ("683.6Kg").',
    ],
  ),
  PatchNote(
    build: 211,
    title: 'Full Combat Parity: Dodge & Resist',
    date: '2026-09-06',
    changes: [
      'Boss Rush, Dungeon, Gauntlet and Guild now use your Dodge Rating too — '
          'you can evade hits in every mode, just like the campaign.',
      'Enemies in those modes now deal their proper damage type and carry '
          'resistances, so your elemental resistances and resistance penetration '
          'finally matter outside the campaign.',
    ],
  ),
  PatchNote(
    build: 210,
    title: 'Unified Combat: All Modes',
    date: '2026-09-06',
    changes: [
      'Boss Rush, Dungeon, Gauntlet and Guild now use the SAME combat maths as '
          'the main campaign: armour is a diminishing-returns rating (not a flat '
          '"−N damage"), and AC / damage ability buffs are % boosts.',
      'Removed the old 9,999 damage ceiling in every mode — big hits now scale '
          'properly at high tiers, just like the campaign.',
      'Your full armour rating (gear, STR, sets, gems, mercs, etc.) now counts in '
          'every mode, and all the "+N AC / +N ATK" labels read "+N% AC / +N% DMG".',
    ],
  ),
  PatchNote(
    build: 209,
    title: 'Correct % Labels (AC & Resist)',
    date: '2026-09-06',
    changes: [
      'Fixed stale labels left over from the armour/resistance rework: '
          'mercenary and ability defensive buffs now correctly read "+N% AC" '
          '(they boost your Armor Rating by a %, not a flat amount).',
      'The Bonuses sheet now shows the resistance cap as ±90% (matching the '
          'current system), and the same for battle-log buff messages.',
    ],
  ),
  PatchNote(
    build: 208,
    title: 'Welcome Back Polish',
    date: '2026-09-06',
    changes: [
      'The "Welcome back!" idle-rewards popup now has a big, full-width CLAIM '
          'button instead of a small text link tucked in the corner.',
    ],
  ),
  PatchNote(
    build: 207,
    title: 'Campaign UI Polish',
    date: '2026-09-06',
    changes: [
      'Tidied the Campaign energy bar — the recharge timer and the Refill/Buy '
          'buttons now sit on their own clean line instead of a cramped row.',
      'Milestone markers are now clear little pills (done / next / upcoming), and '
          'zone headers read better.',
    ],
  ),
  PatchNote(
    build: 206,
    title: 'Clearer Merc Upgrade Cost',
    date: '2026-09-06',
    changes: [
      'The mercenary upgrade button now spells out the cost ("Cost: ◆ N Shards") '
          'so it\'s clear you spend shards.',
    ],
  ),
  PatchNote(
    build: 205,
    title: 'Flat Defenses → Armor Rating',
    date: '2026-09-04',
    changes: [
      'All remaining flat damage-reduction perks (Iron Will, Juggernaut, Fortitude, '
          'Thick Hide) now add to your Armor Class rating and scale through the '
          'armor system, instead of a flat "−N damage" that stopped mattering.',
    ],
  ),
  PatchNote(
    build: 204,
    title: 'Slower Leveling (6-Month Pacing)',
    date: '2026-09-04',
    changes: [
      'Tuned the XP curve so reaching Level 1000 is a genuine long-haul goal, '
          'calibrated from play data toward roughly a 6-month journey at a modest '
          'daily pace. High levels cost more XP; your current level is unchanged.',
    ],
  ),
  PatchNote(
    build: 203,
    title: 'Dev: Level +100',
    date: '2026-09-04',
    changes: [
      'Added a dev-tools "Level +100" button for XP-pacing measurement (no gameplay change).',
    ],
  ),
  PatchNote(
    build: 202,
    title: 'Objective Beacon + Ultimate Coach',
    date: '2026-09-04',
    changes: [
      'The bestiary/quest objective beacon now appears only when you actually '
          'vanquish an enemy and earn a count — not at the start of a battle.',
      'At Level 30 you\'re now guided to your class questline and shown that it\'s '
          'how you unlock your ultimate ability.',
    ],
  ),
  PatchNote(
    build: 201,
    title: 'AC Buffs Boost Armor Rating %',
    date: '2026-09-04',
    changes: [
      'Armor-Class buffs from abilities and mercenaries now increase your Armor '
          'Class RATING by a %, instead of a flat number — so they keep scaling.',
    ],
  ),
  PatchNote(
    build: 200,
    title: 'Tier-Scaled Resistances',
    date: '2026-09-04',
    changes: [
      'Enemy elemental resistances now scale with tier — barely there in Tier 0 '
          '(so a new single-element hero isn\'t hard-countered), ramping up to full '
          'strength by Tier 10, where your resistance penetration is meant to '
          'offset it. No enemy is ever fully immune (90% cap).',
    ],
  ),
  PatchNote(
    build: 199,
    title: 'Ability Buffs Now Scale',
    date: '2026-09-04',
    changes: [
      'Ability damage buffs are now a % of your damage (and actually apply — the '
          'old flat "attack" buff did nothing), and defensive buffs now grant % '
          'damage reduction instead of a tiny flat armor number. Rebalanced values '
          'so they stay useful at every level.',
    ],
  ),
  PatchNote(
    build: 198,
    title: 'First-Gear Coach Timing',
    date: '2026-09-04',
    changes: [
      'The "Your First Gear" tip now appears the moment your first item drops, '
          'instead of lagging until after you\'d already picked up several pieces.',
    ],
  ),
  PatchNote(
    build: 197,
    title: 'New Character Start Fix',
    date: '2026-09-04',
    changes: [
      'Fixed new characters sometimes starting at Stage 41 with systems already '
          'unlocked (they inherited the previous character\'s head-start node). New '
          'heroes now correctly begin at Stage 1.',
    ],
  ),
  PatchNote(
    build: 196,
    title: 'Difficulty Rebuild (2/3)',
    date: '2026-09-04',
    changes: [
      'Levelling is now a long-haul journey — the XP curve ramps hard so Level '
          '1000 is a real goal, not a weekend. (Tuning in progress.)',
      'Damage reduction is capped at 90% — no build can become fully immune.',
      'Removed the XP-per-fight ceiling.',
    ],
  ),
  PatchNote(
    build: 195,
    title: 'Difficulty Rebuild (1/3)',
    date: '2026-09-04',
    changes: [
      'Fixed a massive enemy-attack scaling bug where late-tier bosses hit for '
          'absurd amounts (and one-shot you). Enemy attack now tracks your HP '
          'growth instead of exploding. Raised internal ceilings so nothing caps.',
    ],
  ),
  PatchNote(
    build: 194,
    title: 'Max Tool: Mastery/Upgrades/Abilities',
    date: '2026-09-04',
    changes: [
      'The dev Max Character tool now also maxes elemental mastery, tower upgrades '
          '(with synergies) and all abilities — the balance anchor is now complete.',
    ],
  ),
  PatchNote(
    build: 193,
    title: 'Max Tool: Full Coverage',
    date: '2026-09-04',
    changes: [
      'The dev Max Character tool now also maxes ascension, class mastery and '
          'artifacts, for a truly complete top-down balance anchor.',
    ],
  ),
  PatchNote(
    build: 192,
    title: 'Max Character Dev Tool',
    date: '2026-09-04',
    changes: [
      'Added a dev-tools "Max Character" button (Settings) that fully maxes your '
          'hero and drops you at the Tier 10 final boss — used to balance the game '
          'top-down from a maxed build.',
    ],
  ),
  PatchNote(
    build: 191,
    title: 'No Damage Caps',
    date: '2026-09-04',
    changes: [
      'Removed the hidden 9,999 ceiling on ALL combat values — your hits, abilities, '
          'damage-over-time, heals and max HP now scale freely. Balance comes from '
          'resistances and damage reduction, not caps.',
      'Added deeper behind-the-scenes logging that breaks down how much every '
          'progression system contributes to your power (no gameplay change).',
    ],
  ),
  PatchNote(
    build: 190,
    title: 'Uncapped Enemy Damage',
    date: '2026-09-04',
    changes: [
      'Boss and monster damage no longer hits a hidden ceiling — special attacks, '
          'damage-over-time and hazards now scale up with the enemy instead of being '
          'capped, so high-tier fights stay dangerous.',
    ],
  ),
  PatchNote(
    build: 189,
    title: 'Paragon Symbols + Rebirth Cleanup',
    date: '2026-09-04',
    changes: [
      'Each Paragon board stat now has its own hand-drawn symbol instead of an emoji.',
      'Removed the leftover "Veteran\'s Path" / "Battle-Hardened" Paragon nodes that '
          'referenced the old Rebirth wording.',
    ],
  ),
  PatchNote(
    build: 188,
    title: 'Tighter Passive Cards',
    date: '2026-09-04',
    changes: [
      'Trimmed the empty space under each passive node so the cards fit their box better.',
    ],
  ),
  PatchNote(
    build: 187,
    title: 'Balance Telemetry',
    date: '2026-09-04',
    changes: [
      'Added behind-the-scenes battle logging that records each fight\'s stats '
          '(no gameplay change) so difficulty can be tuned from real data.',
    ],
  ),
  PatchNote(
    build: 186,
    title: 'HP Passives Fixed',
    date: '2026-09-04',
    changes: [
      'Fixed max-HP passives (e.g. Iron Skin) not raising your HP when you ranked '
          'them up mid-session — they now apply immediately, and respeccing them '
          'updates your HP correctly too.',
    ],
  ),
  PatchNote(
    build: 185,
    title: 'HP Fix',
    date: '2026-09-04',
    changes: [
      'Fixed max HP dropping to almost nothing after the last update. Per-level HP '
          'is halved (not removed) — heroes are squishier than before but no longer '
          'paper-thin.',
    ],
  ),
  PatchNote(
    build: 184,
    title: 'Over-Level Catch-Up + HP Rework',
    date: '2026-09-04',
    changes: [
      'Enemies now get tougher the more you out-level them, so over-levelling no '
          'longer lets you faceroll the frontier (scales enemy HP up to a 50-level gap).',
      'Level-ups no longer grant HP automatically. Your max HP now comes entirely '
          'from CON, gear, passives and Paragon — build it deliberately.',
    ],
  ),
  PatchNote(
    build: 183,
    title: 'Late-Game Difficulty II',
    date: '2026-09-04',
    changes: [
      'Enemies in the full-progression late game now hit much harder and are '
          'tankier still — fights actually threaten a maxed hero now, instead of '
          'ending in a hit or two.',
    ],
  ),
  PatchNote(
    build: 182,
    title: 'Late-Game Difficulty',
    date: '2026-09-03',
    changes: [
      'Rebalanced late-game fights (level 20+ with the full progression stack). '
          'Enemies now grow tankier as you unlock systems — up to ~2.9× HP once '
          'everything is online — so your stacked damage no longer deletes them '
          'instantly and fights are a real challenge again.',
      'Rewards are unchanged (they scale off enemy level, not HP), and the early '
          'tutorial stages stay as gentle as before.',
    ],
  ),
  PatchNote(
    build: 181,
    title: 'Mercenary Talent Rebalance',
    date: '2026-09-03',
    changes: [
      'Fixed mercenary talent picks that were near-duplicates. Cael\'s War Veteran '
          'and Greybeard\'s Battle Master are now real hybrid choices (damage plus '
          'toughness/armour) instead of just slightly-less raw damage.',
    ],
  ),
  PatchNote(
    build: 180,
    title: 'Frame Recolours Slot Outline',
    date: '2026-09-03',
    changes: [
      'Your equipped frame now recolours the whole character-slot outline, '
          'instead of drawing a box around the sprite.',
    ],
  ),
  PatchNote(
    build: 179,
    title: 'Character Select Tweaks',
    date: '2026-09-03',
    changes: [
      'Removed the ">" arrow and the delete bin on character slots for a cleaner look.',
      'Delete a character by swiping its slot from right to left.',
      'Each character now shows its own equipped frame and name colour (read per-character).',
      'Character names are capped at 14 characters so they always fit.',
    ],
  ),
  PatchNote(
    build: 178,
    title: 'Character Select Polish',
    date: '2026-09-03',
    changes: [
      'Removed the slot number and gave names more room so they no longer get cut off.',
      'Your equipped premium frame and name colour now show on each character in Select Character.',
    ],
  ),
  PatchNote(
    build: 177,
    title: 'Loading Fix + Character Portraits',
    date: '2026-09-03',
    changes: [
      'Fixed the loading screen showing a black screen (the background image was '
          'too large for some devices to render).',
      'Select Character now shows each hero\'s sprite and race, not just a gender '
          'symbol.',
    ],
  ),
  PatchNote(
    build: 176,
    title: 'New Loading Screen Art',
    date: '2026-09-03',
    changes: [
      'The loading screen now has a painted tavern-hearth background, with the '
          'hero walking into the firelight.',
    ],
  ),
  PatchNote(
    build: 175,
    title: 'Hero Banner on Daily Login',
    date: '2026-09-03',
    changes: [
      'The Daily Login screen now shows your hero — sprite, name, level, class '
          'and a race indicator.',
      'It reflects your equipped premium cosmetics too: portrait frame, name '
          'colour and title.',
    ],
  ),
  PatchNote(
    build: 174,
    title: 'Bonuses Sheet Cleanup',
    date: '2026-09-03',
    changes: [
      'Damage Types now shows just your damage — resistances live in the '
          'Resistances section only, no longer duplicated.',
      'Removed the outdated Post-battle HP Heal line (battles always start at '
          'full HP now).',
    ],
  ),
  PatchNote(
    build: 173,
    title: 'Bounty Claim Dots',
    date: '2026-09-03',
    changes: [
      'The Challenges tab and its Bounties sub-tab now show a dot when a boss '
          'bounty (or daily/weekly) is ready to claim.',
    ],
  ),
  PatchNote(
    build: 172,
    title: 'Bounty Board = Boss Bounties',
    date: '2026-09-03',
    changes: [
      'The Bounty Board is now a boss-bounty board: slay each campaign boss to '
          'claim its bounty (gold, shards, essence, ZCoins, mythril).',
      'Bounties are tier-appropriate — reach a new difficulty tier and you get a '
          'fresh set of boss bounties with bigger rewards each tier.',
      'Each boss bounty now drops guaranteed gear — rarity and power ramp with the '
          'boss and your tier (up to Mythic), so bosses feel worth hunting.',
      'Moved boss hunts out of the Quests tab; the old daily kill-target bounties '
          'have been retired in favour of these.',
    ],
  ),
  PatchNote(
    build: 171,
    title: 'Scores & Abilities Staggered',
    date: '2026-09-03',
    changes: [
      'The Scores tab now unlocks at stage 4 with its own coach, instead of '
          'appearing silently at stage 1 alongside Abilities. Each system now '
          'reveals one at a time, together with its tutorial.',
    ],
  ),
  PatchNote(
    build: 170,
    title: 'All Unlock Coaches Fire',
    date: '2026-09-02',
    changes: [
      'Fixed the guided coaches for Abilities, Scores, Passives, Bonuses, Bestiary '
          'and the rest not appearing/navigating — now every system unlock brings '
          'you to it with a coach, just like the Paragon one. "Replay Tutorials" '
          'now works on any character too.',
    ],
  ),
  PatchNote(
    build: 169,
    title: 'Removed First-Victory Popup',
    date: '2026-09-02',
    changes: [
      'Removed the "First Victory" intro popup after your first kill — the guided '
          'tutorials already cover onboarding, so it just got in the way.',
    ],
  ),
  PatchNote(
    build: 168,
    title: 'Fairer Early Bosses',
    date: '2026-09-02',
    changes: [
      'Boss difficulty now ramps in: the first boss is a gentle mini-boss instead '
          'of a brick wall, and bosses get progressively tougher through the early '
          'campaign (full strength by ~stage 25). Later bosses are unchanged.',
    ],
  ),
  PatchNote(
    build: 167,
    title: 'Tutorials Show Mid-Battle',
    date: '2026-09-02',
    changes: [
      'Guided tutorials now actually appear when a system/ability unlocks during a '
          'fight — the battle steps aside so the coach and the jump to the new '
          'system are visible (previously they happened behind the battle).',
      'Added a "Replay Tutorials" dev tool in Settings to re-trigger the coaches.',
    ],
  ),
  PatchNote(
    build: 166,
    title: 'Level-Ups → Paragon',
    date: '2026-09-02',
    changes: [
      'Level-ups no longer auto-grant stat points — your power now comes from '
          'gear, Paragon and passives. Each level still gives a Paragon Point, HP, '
          'and energy.',
      'Paragon Points are revealed at level 10: you\'ve been banking one per level '
          'since the start, and now a coach unlocks the Paragon tab so you can '
          'spend them.',
    ],
  ),
  PatchNote(
    build: 165,
    title: 'No Free Level-Up Heal',
    date: '2026-09-02',
    changes: [
      'Levelling up mid-fight no longer fully heals you. Every battle still starts '
          'at full HP — this just removes a free heal during a long fight.',
    ],
  ),
  PatchNote(
    build: 164,
    title: 'Next Action & Badge Fixes',
    date: '2026-09-02',
    changes: [
      'The "visit PASSIVES/ABILITIES" Next Action now only shows once that tab is '
          'unlocked, and tapping it reliably takes you there.',
      'Fixed a stuck notification dot: the Passives badge no longer counts other '
          'classes\' passive nodes that you can\'t actually buy.',
    ],
  ),
  PatchNote(
    build: 163,
    title: 'Login Reward Day Fix',
    date: '2026-09-02',
    changes: [
      'Fixed the daily login reward preview showing the wrong day (e.g. "Day 2" '
          'while actually granting Day 1). The preview now matches what you claim.',
    ],
  ),
  PatchNote(
    build: 162,
    title: 'Stronger Guided Tutorials',
    date: '2026-09-02',
    changes: [
      'Tutorial coaches are now non-skippable — they cover the whole screen until '
          'you tap "Got it".',
      'Unlocking a new ability on level-up (5/10/15/20/25) now pauses, jumps to '
          'your Abilities, and explains it.',
      'The first-item tutorial now covers both tapping to equip manually and using '
          'AUTO EQUIP.',
    ],
  ),
  PatchNote(
    build: 161,
    title: 'Staggered Starter Tutorials',
    date: '2026-09-02',
    changes: [
      'The Ability Scores tutorial now appears a couple stages after the Abilities '
          'tutorial instead of right after it, so they no longer land back-to-back.',
    ],
  ),
  PatchNote(
    build: 160,
    title: 'Beacon Shows Only What Changed',
    date: '2026-09-02',
    changes: [
      'The combat beacon now only shows a bestiary or quest row when that counter '
          'actually ticks up (e.g. 0/10 → 1/10) — no more static bars that aren\'t '
          'moving.',
    ],
  ),
  PatchNote(
    build: 159,
    title: 'Starter Tutorials',
    date: '2026-09-02',
    changes: [
      'New characters now also get guided tutorials right at the start: Ability '
          'Scores (stage 1), Abilities (stage 2), and a Gear tutorial the first '
          'time an item drops into your inventory.',
    ],
  ),
  PatchNote(
    build: 158,
    title: 'Guided System Tutorials',
    date: '2026-09-02',
    changes: [
      'When a new progression system unlocks in the campaign, the auto-fight now '
          'pauses, the app jumps to that system, and a short coach card explains '
          'how to use it. Tap "Got it" to resume — covers every system from '
          'Abilities through PvP.',
    ],
  ),
  PatchNote(
    build: 157,
    title: 'Systems Steepen Difficulty',
    date: '2026-09-02',
    changes: [
      'Enemies now hit harder each time you unlock a new progression system '
          '(Abilities, Passives, Pets, Mercenaries, Artifacts…). As your hero '
          'gains power, the challenge keeps pace instead of falling behind.',
    ],
  ),
  PatchNote(
    build: 156,
    title: 'Poison Color Fix',
    date: '2026-08-27',
    changes: [
      'Poison damage is now a darker, toxic green so it\'s easy to tell apart '
          'from healing numbers.',
    ],
  ),
  PatchNote(
    build: 155,
    title: 'Beacon Only Shows Live Quests',
    date: '2026-08-27',
    changes: [
      'The combat beacon no longer shows a quest you haven\'t started (stuck at '
          '0), like "Into the Depths" which needs a dungeon clear — so you won\'t '
          'see a quest bar that never moves during a campaign fight.',
    ],
  ),
  PatchNote(
    build: 154,
    title: 'Quests → Hero Tab',
    date: '2026-08-27',
    changes: [
      'Moved Questlines from the Play tab to the Hero tab, alongside your other '
          'character progression.',
    ],
  ),
  PatchNote(
    build: 153,
    title: 'Beacon Fix',
    date: '2026-08-27',
    changes: [
      'The in-combat objective beacon no longer shows a quest that\'s already '
          'complete but unclaimed (e.g. First Kill at 1/1) — it only shows quests '
          'you\'re still progressing.',
    ],
  ),
  PatchNote(
    build: 152,
    title: 'Cleaner Onboarding',
    date: '2026-08-27',
    changes: [
      'Inventory tabs (Gems, Forge, Runes, Artifacts, Armory) now stay locked '
          'until their campaign stage, even if you pick up a related drop early — '
          'so new characters aren\'t flooded with systems all at once.',
    ],
  ),
  PatchNote(
    build: 151,
    title: 'More Bite (esp. Bosses)',
    date: '2026-08-27',
    changes: [
      'Enemies hit harder and their damage now ramps more steeply as you advance '
          '— early stages should stop feeling like a walkover.',
      'Bosses hit substantially harder than the regular enemies before them.',
    ],
  ),
  PatchNote(
    build: 150,
    title: 'Smooth Tier Difficulty',
    date: '2026-08-27',
    changes: [
      'Reworked campaign difficulty into one continuous curve across all tiers: '
          'the start of a new tier now picks up right where the previous tier '
          'ended and keeps climbing, instead of dropping back to easy enemies.',
      'Enemy HP and attack now scale smoothly with your total progress rather '
          'than resetting each tier. (Big balance change — expect tuning.)',
    ],
  ),
  PatchNote(
    build: 149,
    title: 'Combat Objective Beacon',
    date: '2026-08-27',
    changes: [
      'A progress beacon now slides in at the top-right during any fight when you '
          'make progress — showing the current enemy\'s bestiary kills toward its '
          'next milestone and your active quest\'s progress, so you can see you\'re '
          'killing the right thing without leaving combat.',
    ],
  ),
  PatchNote(
    build: 148,
    title: 'Artifact Upgrade Fix',
    date: '2026-08-27',
    changes: [
      'Fixed a bug where upgrading an artifact reset it to Common rarity and, for '
          'set pieces, stripped its set membership — making it look like the item '
          'vanished. Upgrades now keep the artifact\'s rarity and set.',
      'Fixed the cramped Artifact Table header — the AUTO-EQUIP / SALVAGE buttons '
          'now sit on their own row so the mythril count is no longer cut off.',
    ],
  ),
  PatchNote(
    build: 147,
    title: 'Artifact Collection Sorted',
    date: '2026-08-27',
    changes: [
      'The Artifact Collection now lists your best artifacts first (by rarity, '
          'then stat value, then level), so it\'s easy to see what\'s worth '
          'upgrading.',
    ],
  ),
  PatchNote(
    build: 146,
    title: 'Salvage All Artifacts',
    date: '2026-08-27',
    changes: [
      'New "♻ SALVAGE" button on the Artifact Table salvages every unequipped '
          'artifact at once for mythril (equipped artifacts are kept). Shows a '
          'confirmation with the count and mythril first.',
    ],
  ),
  PatchNote(
    build: 145,
    title: 'Dungeon Cleanup',
    date: '2026-08-27',
    changes: [
      'Removed dungeon affixes — no more run-wide penalties (Burning, Frozen, '
          'Cursed, Toxic, Arcane) or affix reroll.',
      'Moved the dungeon Auto Run toggle to a button in the top bar (next to the '
          'leaderboard), so it\'s always visible on the dungeon start screen.',
    ],
  ),
  PatchNote(
    build: 144,
    title: 'Premium Auto-Dungeon',
    date: '2026-08-27',
    changes: [
      'Premium subscribers can now Auto Run dungeons hands-free: it picks a random '
          'choice at every junction (doors, relics, blessings) and keeps delving — '
          'starting fresh dungeons after each clear — until your hero is defeated.',
    ],
  ),
  PatchNote(
    build: 143,
    title: 'Gauntlet Essence Rework',
    date: '2026-08-27',
    changes: [
      'Gauntlet essence now works like it should: higher Gauntlet tiers give a '
          'bigger flat soul income per kill, and modifiers boost that by a '
          'percentage (Veteran +15% … Nightmare +50%) instead of a tiny flat amount.',
      'Your last-used modifiers are now pre-selected by default whenever you open '
          'the Gauntlet, and auto-repeat keeps your chosen set instead of rolling '
          'random ones.',
    ],
  ),
  PatchNote(
    build: 142,
    title: 'Combat & Ally Overhaul',
    date: '2026-08-27',
    changes: [
      'Heal abilities now have a +2 round cooldown on top of their normal cooldown, '
          'so you can\'t heal as often. Combined with the smaller heals, incoming '
          'damage sticks and fights stay tense.',
      'Bosses now hit much harder (2.2× attack premium). They were the wall at the '
          'end of each cycle but were landing softer than the enemies right before '
          'them — now they punch like a boss should.',
      'Auras, self-buffs and lasting debuffs get a +2 cooldown. They used to sit at '
          '~100% uptime, so extending their duration was a wasted pick — now duration '
          'upgrades actually raise uptime and are worth choosing.',
      'Mercenary damage is now a single "% Damage" bonus instead of separate flat '
          'ATK and DMG (which meant the same thing and fell off at high levels). '
          'Percentage damage scales with your build, so mercs stay relevant.',
    ],
  ),
  PatchNote(
    build: 141,
    title: 'Heal Ability Nerf',
    date: '2026-08-27',
    changes: [
      'Active heals and healing auras restore much less: burst heals cut to ~36% '
          'of max HP (from ~60%), and healing-over-time auras halved. Big heals were '
          'undoing whole enemy hits, so fights never felt dangerous.',
      'The one heal path that ignored heal-fatigue now diminishes with repeated '
          'casts like the others.',
    ],
  ),
  PatchNote(
    build: 140,
    title: 'Lifesteal Nerf',
    date: '2026-08-27',
    changes: [
      'Lifesteal reduced (Life Steal keyword 10%→4%, Fiend Pact 20%→8%). It '
          'stacked across several sources and scaled with your damage, so heavy '
          'hitters healed back everything and never dropped below full HP.',
    ],
  ),
  PatchNote(
    build: 139,
    title: 'Steeper Tier Ladder',
    date: '2026-08-27',
    changes: [
      'Each difficulty Tier is now a much bigger step up — enemies get roughly '
          'twice as tanky and hit ~80% harder per tier, so climbing genuinely gets '
          'harder instead of feeling flat. Higher tiers are a real endgame wall now.',
    ],
  ),
  PatchNote(
    build: 138,
    title: 'Higher Tiers Hit Harder',
    date: '2026-08-27',
    changes: [
      'Your elemental resistance now caps at 50% (was 75%). Stacked with dodge and '
          'regen, 75% resistance made you nearly untouchable — elemental hits now '
          'land for at least half.',
      'Enemy attack scales more steeply per Tier, so higher tiers threaten you '
          'properly instead of feeling safe.',
    ],
  ),
  PatchNote(
    build: 137,
    title: 'Less Sustain — You Can Die Now',
    date: '2026-08-27',
    changes: [
      'Turned down healing so long fights are dangerous again: aura HP regen per '
          'turn reduced (was too strong), and Battle Scarred now restores 3% max HP '
          'per hit (5% with Iron Sage) instead of 5%/8%. Enemies can now grind you '
          'down.',
    ],
  ),
  PatchNote(
    build: 136,
    title: 'Dodge & Armor Rating System',
    date: '2026-08-27',
    changes: [
      'Dodge and Armor are now RATINGS with diminishing returns — each point is '
          'worth progressively less, and both cap at 37.5%. Stacking sources (your '
          'whole aura collection especially) can no longer reach 100% dodge / total '
          'immunity. Your Hero Stats now show both the rating and the actual %.',
      'Armor changed from flat damage subtraction to a % damage-reduction rating '
          '(physical; elemental still uses resistances, capped at 75%).',
      'Removed the old 9,999 per-hit damage cap on both hero and enemy hits — it '
          'made high-tier enemies unable to threaten your much larger HP pool.',
      'Enemy damage rolls are steadier (70–100% of their attack instead of a wild '
          '1–100%), so hits are consistent rather than mostly whiffing.',
    ],
  ),
  PatchNote(
    build: 134,
    title: 'Endurance, Wrath & Sustain Rework',
    date: '2026-08-27',
    changes: [
      'The "Agility" ability score is now "Endurance" and grants +2% max HP per '
          'rank — a real path to a high-HP, tanky hero (instead of extra damage).',
      'The "Precision" ability score is renamed "Wrath" to match what it does '
          '(+0.5% all damage per rank).',
      'Health regen no longer uses a hard cap. Aura regen is now a FLAT heal each '
          'turn instead of a % of max HP — so as you build HP it becomes modest '
          'sustain rather than immortality. Big fights can wear you down and you '
          'can nearly die again.',
    ],
  ),
  PatchNote(
    build: 133,
    title: 'Aura Regen Fix',
    date: '2026-08-27',
    changes: [
      'Fixed Aura HP regeneration being wildly overpowered — it healed a % of your '
          'max HP EVERY turn and stacked across every aura you owned, reaching ~50% '
          'per round (basically immortal). It\'s now capped at +5% max HP/turn, so '
          'auras are solid sustain without trivialising fights. Also fixed the '
          'misleading "+N HP after victory" description.',
    ],
  ),
  PatchNote(
    build: 132,
    title: 'Tiers Get Progressively Harder',
    date: '2026-08-27',
    changes: [
      'Removed the free "+1% damage per level" bonus — it was letting heroes '
          'trivialise every difficulty. Your power now comes from stats, gear, '
          'Paragon and passives. (Existing characters lose this old bonus.)',
      'Enemy scaling now OUTPACES your power growth as you climb: Tier 1 stays '
          'approachable, but each higher tier is a genuinely harder wall — Tier 10 '
          'takes roughly 3× the effort of Tier 1. Climb for a real challenge.',
      'Enemy HP is re-tuned to match the new (lower) damage growth, so the change '
          'is balanced rather than just a nerf.',
    ],
  ),
  PatchNote(
    build: 131,
    title: 'No More First-Kill Tutorial for Veterans',
    date: '2026-08-27',
    changes: [
      'The first-kill tutorial no longer pops up again after you\'ve unlocked a '
          'difficulty Tier — the campaign restarts at stage 0 each tier, and it was '
          're-triggering. It now only shows for brand-new heroes.',
    ],
  ),
  PatchNote(
    build: 130,
    title: 'Difficulty Rebalance — Tiers Stay Challenging',
    date: '2026-08-27',
    changes: [
      'Enemy HP and attack now scale up much more steeply per difficulty Tier so '
          'higher tiers stay a real challenge. Previously your hero massively '
          'out-scaled enemies (hero damage grows ~quadratically with level, but '
          'enemies only grew a little per tier), making high tiers trivial.',
      'Enemy HP now roughly tracks your damage growth and enemy attack tracks your '
          'health growth, keeping the challenge consistent from Tier 1 to Tier 10.',
      'Tuned slightly on the forgiving side — if a tier still feels too easy or too '
          'hard, let us know and we\'ll fine-tune.',
    ],
  ),
  PatchNote(
    build: 129,
    title: 'Tier Progression Rewired',
    date: '2026-08-27',
    changes: [
      'Fixed content that was stuck behind the old rebirth system: a mercenary, '
          'two achievements, and shop/forge/login loot quality now unlock and scale '
          'with your difficulty Tier instead of a rebirth count you can no longer '
          'earn.',
      'Permanent gold, XP, idle and damage buffs now grow with each Tier you '
          'unlock (they used to grow per rebirth), on top of the Paragon board.',
      'Fixed unlocked game modes (Boss Rush, PvP, Gauntlet, etc.) re-locking when '
          'the campaign restarted at a new Tier, and your Tier/Paragon damage bonus '
          'not applying if you had never rebirthed.',
      'Head-Start and Instant Recall Paragon perks now apply each time you restart '
          'the campaign at a new Tier.',
      'Boss Rush, Gauntlet and Guild now apply your Tier/Paragon damage bonus '
          'correctly, scale their rewards with your Tier, and no longer double-scale '
          'enemies (they use their own tier setting).',
      'Removed two now-redundant Paragon nodes (Mythril and artifacts are always '
          'kept now anyway).',
    ],
  ),
  PatchNote(
    build: 127,
    title: 'Crit Is Now a Gear Specialization',
    date: '2026-08-27',
    changes: [
      'Crit Chance and Crit Damage now come ONLY from gear (attack & dexterity '
          'affixes on items and sets, plus the Critical Fury keyword). There were '
          'too many crit sources scattered everywhere.',
      'Everything that used to grant crit now grants % All Damage instead: the '
          'Slayer passive nodes, Precision & Agility ability scores, the Iron Grip '
          '/ Keen Edge echo perks, the Champion & Assassin subclasses, and the '
          'Precision & Ferocity Paragon stats. Existing investment is preserved — '
          'it just gives damage now.',
      'Crit-focused builds now come from choosing crit gear, making crit a '
          'deliberate specialization rather than a stat you get everywhere.',
    ],
  ),
  PatchNote(
    build: 126,
    title: 'Dungeon Boss Rebalance',
    date: '2026-08-27',
    changes: [
      'Fixed dungeon enemies (especially the floor bosses) being over-tuned — they '
          'were double-scaling with both the dungeon tier AND your campaign tier. '
          'Dungeons now scale only by the dungeon tier you select and the floor, so '
          'floor bosses are a fair fight again.',
    ],
  ),
  PatchNote(
    build: 125,
    title: 'Rebirth References Cleaned Up',
    date: '2026-08-27',
    changes: [
      'Removed the old "Rebirth" wording across the UI now that difficulty Tiers '
          'drive progression — the campaign, codex, hero stats, tooltips and quest '
          'text now refer to Tiers and Paragon Points.',
      'Fixed the fight button dead-ending for characters left at the old post-100 '
          'Abyss — the campaign now loops cleanly per tier.',
      'Fixed high-tier gear that could not be equipped, and ability rank-tiers '
          'that were stuck, now that they follow your unlocked Tier instead of the '
          'retired rebirth count.',
    ],
  ),
  PatchNote(
    build: 123,
    title: 'Gold Scaling Fix',
    date: '2026-08-27',
    changes: [
      'Fixed gold rewards ballooning at high tiers after the enemy-level rebalance. '
          'Gold now scales a sensible +15% per tier (matching enemy stats) instead '
          'of tracking the inflated enemy level — so higher tiers still pay more '
          'without breaking the economy.',
    ],
  ),
  PatchNote(
    build: 122,
    title: 'XP & Enemy-Level Rebalance',
    date: '2026-08-27',
    changes: [
      'Enemy levels now scale with your difficulty Tier, so they keep pace with '
          'your hero as you climb — a Tier 3 hero around Level 200 fights ~Level '
          '190 enemies instead of trivial low-level ones.',
      'The XP curve is now linear so levelling stays steady into the hundreds '
          'with no cap — each tier adds roughly 65-70 levels and a first campaign '
          'clear lands around Level 50-60.',
      'Enemy level only affects XP, gold, loot level and the number shown — combat '
          'difficulty still comes from the tier stat multipliers, so higher-level '
          'enemies never become unbeatable.',
      'Existing heroes are re-tuned to the new curve on load; under-levelled '
          'characters will catch up quickly.',
    ],
  ),
  PatchNote(
    build: 121,
    title: 'No More Resets — Climb the Tiers',
    date: '2026-08-27',
    changes: [
      'MAJOR: Rebirth no longer wipes your progress. Clear the campaign (defeat '
          'the Omega) to unlock the next difficulty Tier — the campaign restarts '
          'at that harder tier with better loot, and your Level, Paragon, gear and '
          'currencies all carry over. Fight your way up 10 tiers.',
      'Paragon Points are now earned by levelling up — 1 point per level — instead '
          'of only from rebirth. Spend them on the Paragon board any time.',
      'There is no level cap — keep levelling and pouring points into Paragon.',
      'The Rebirth and Ascension screens are hidden for now while the new '
          'progression settles in (a reworked Ascension is coming).',
    ],
  ),
  PatchNote(
    build: 120,
    title: 'Tier-Linked Ascension & Magic Find',
    date: '2026-08-27',
    changes: [
      'Ability Ascension is no longer locked behind Ascension Points — you can '
          'now ascend each ability up to your highest unlocked difficulty Tier '
          '(you unlock one Tier per rebirth), for free. Fixes not being able to '
          'ascend abilities after rebirthing.',
      'The Difficulty Tier picker now shows the Magic Find bonus each tier grants '
          '(+3% increased rarity per tier — better gear, sets and artifacts).',
      'Tutorial tips no longer appear once you\'ve cleared Tier 0 (rebirthed at '
          'least once) — veterans get a cleaner UI.',
    ],
  ),
  PatchNote(
    build: 119,
    title: 'XP Rebalance & Specialization Fix',
    date: '2026-08-27',
    changes: [
      'XP now scales so your hero level keeps pace with the campaign — you\'ll '
          'reach the final boss around Level 55–65 instead of stalling in the low '
          '30s. Existing characters are re-tuned to the new curve on load, so '
          'under-levelled heroes will catch up fast.',
      'Fixed Specialization (the Level 50 choice) silently doing nothing when '
          'tapped — it now clearly tells you it unlocks at Level 50, which the XP '
          'fix makes reachable within the campaign.',
    ],
  ),
  PatchNote(
    build: 118,
    title: 'Difficulty Tiers Replace Hard Mode',
    date: '2026-08-27',
    changes: [
      'NEW Difficulty Tiers: every Rebirth unlocks a tier (up to 10). Tap the '
          'slider icon in the Campaign header to switch tiers any time.',
      'Higher tiers make ALL PvE (Campaign, Tower, Dungeons) tougher but drop '
          'noticeably better loot — higher rarities, more sets, and rarer '
          'artifacts. PvP and Guild are unaffected.',
      'Switching to a LOWER tier keeps every permanent rebirth buff — it only '
          'scales the enemies and loot you face, so you can farm comfortably.',
      'Hard Mode has been removed and replaced by the tier system.',
      'Leaderboard rankings now factor in your highest unlocked tier and '
          'campaign clearance.',
    ],
  ),
  PatchNote(
    build: 117,
    title: 'Ability Upgrades & Tower Auto-Clear',
    date: '2026-08-27',
    changes: [
      'Every ability upgrade now does something: utility abilities (Stun, Silence, '
          'Dodge) shorten their cooldown as you rank them, and ascending them adds '
          'duration.',
      'Disarm and other max-strength debuffs no longer waste upgrades — extra power '
          'now spills into a Vulnerability debuff (enemy takes more damage).',
      'PREMIUM: New "Auto-Clear All Bosses" button on Tower Ascension battles '
          'through every available boss for you.',
      'Tower Ascension boss rewards now show the correct Tower Shard payout instead '
          'of misleading numbers.',
    ],
  ),
  PatchNote(
    build: 116,
    title: 'Arcane Dust Fix & Polish',
    date: '2026-08-23',
    changes: [
      'Fixed disenchanting most gear giving no Arcane Dust — every rarity now '
          'yields Arcane Dust, scaling up with rarity.',
      'The Gems screen now explains how to get Arcane Dust.',
      'The Dungeon now shows the 3-2-1 countdown before battle.',
      'Renamed the two "Endless Mode" quests to Tower Ascension.',
    ],
  ),
  PatchNote(
    build: 115,
    title: 'Artifacts Reforged — 6 Rarities',
    date: '2026-08-23',
    changes: [
      'Artifacts now use the same six rarities as gear (Common → Mythic) and roll '
          'much rarer at higher difficulty — climbing tiers massively boosts your '
          'odds of Epic/Legendary/Mythic artifacts and Set pieces.',
      'Higher-rarity artifacts are strictly stronger (rarity now multiplies their '
          'stats on top of level scaling).',
    ],
  ),
  PatchNote(
    build: 114,
    title: 'Boss Hunts',
    date: '2026-08-23',
    changes: [
      'New Boss Hunt quests on the Quests screen — slay each campaign boss for a '
          'one-time bounty (gold, shards, essence, and a title for the final boss). '
          'They tick off automatically as you climb the campaign.',
    ],
  ),
  PatchNote(
    build: 113,
    title: 'Account-Wide Purchases & Tower Fixes',
    date: '2026-08-23',
    changes: [
      'Subscriptions and real-money cosmetics/pets are now account-wide — shared '
          'across every character and preserved through rebirth. (Restores a lost '
          'subscription on next launch.)',
      'Fixed the Echoes Upgrades being wiped on rebirth/ascension — they are now '
          'truly permanent per character as stated.',
      'Tower Ascension bosses no longer use a tier — you fight them at their '
          'campaign difficulty, gated by how far you\'ve climbed the campaign.',
      'Tower Ascension now shows the 3-2-1 countdown before battle like the '
          'other modes.',
    ],
  ),
  PatchNote(
    build: 112,
    title: 'Clearer Long-Away Message',
    date: '2026-08-22',
    changes: [
      'When you\'ve been away longer than the 8-hour idle cap, the welcome-back '
          'dialog now says "away for more than 8h — showing the maximum idle '
          'rewards" instead of a misleading exact time.',
    ],
  ),
  PatchNote(
    build: 111,
    title: 'Accurate Offline Time',
    date: '2026-08-22',
    changes: [
      'Fixed "time away" being wildly under-counted (e.g. showing 22m after '
          'hours). The idle and autosave timers now pause while the app is in the '
          'background, so away time is measured from when you actually left — and '
          'idle earnings are granted once on return instead of double-counted.',
    ],
  ),
  PatchNote(
    build: 110,
    title: 'Daily Rewards Survive Rebirth',
    date: '2026-08-22',
    changes: [
      'Fixed a bug where rebirthing (or ascending) reset your Daily Challenges, '
          'daily chest, login streak and daily attempt limits. These are '
          'calendar-day based and now persist through a rebirth — they only reset '
          'on a new day or a brand-new character.',
    ],
  ),
  PatchNote(
    build: 109,
    title: 'Zeta Absolute Final Boss',
    date: '2026-08-22',
    changes: [
      'The final boss is now "Zeta Absolute" with a brand-new hand-drawn sprite '
          'modelled after the Zeta Idle icon — a slate-blue-and-gold armoured '
          'colossus with a glowing blue heart-gem.',
    ],
  ),
  PatchNote(
    build: 108,
    title: 'Felix Combat Ability',
    date: '2026-08-22',
    changes: [
      'Felix\'s economy "Bribe" is now a combat ability — Smoke Screen grants '
          '+30% dodge chance for the first 4 rounds of battle. He keeps his +Gold '
          'passive.',
    ],
  ),
  PatchNote(
    build: 107,
    title: 'Mercenary Ability Rework',
    date: '2026-08-22',
    changes: [
      'Greybeard\'s War Cry now Marks the enemy (+25% damage taken for 4 rounds) '
          'instead of a hidden crit-chance buff — a real, scaling effect.',
      'Ruk\'s Stone Skin now reduces incoming damage by 30% (was a flat −4 that '
          'stopped mattering) and Voss\'s Arcane Surge hits for 12% max HP.',
    ],
  ),
  PatchNote(
    build: 106,
    title: 'Mercenary Ability Animations',
    date: '2026-08-22',
    changes: [
      'Mercenaries now get a call-out animation in battle when their ability '
          'fires — a glowing card slides in from your side showing the merc '
          '(Greybeard, Voss, Felix, Lena, Ruk, Mira, Ironhide). Shows in Campaign, '
          'Tower Ascension and the Dungeon.',
    ],
  ),
  PatchNote(
    build: 105,
    title: 'Easier Dungeon Bosses',
    date: '2026-08-22',
    changes: [
      'Dungeon bosses now hit 20% softer — both their HP and attack are reduced '
          'by 20% for a fairer fight at every floor.',
    ],
  ),
  PatchNote(
    build: 104,
    title: 'Next-Action Fix & Mastery Polish',
    date: '2026-08-22',
    changes: [
      'The "expeditions ready to collect" next-action now opens the Expeditions '
          'screen instead of the Mercenaries tab.',
      'Elemental Mastery now shows your Gold balance (needed for upgrades) and '
          'uses custom hand-drawn element glyphs instead of text tags.',
    ],
  ),
  PatchNote(
    build: 103,
    title: 'Balance Visibility Fixes',
    date: '2026-08-22',
    changes: [
      'The Mercenaries screen now shows your Shards balance next to ZCoins '
          '(both are spent on merc unlocks and upgrades).',
      'The Upgrades screen now shows your Echoes balance when viewed from the '
          'Hero Hub.',
    ],
  ),
  PatchNote(
    build: 102,
    title: 'Hand-Drawn Passive Tree Icons',
    date: '2026-08-22',
    changes: [
      'Passive tree nodes now use custom stat icons matched to their effect — '
          'crit, armor, HP, gold, XP and pierce sprites, elemental glyphs (flame, '
          'snowflake, bolt, droplet, void orb) for elemental damage, tinted '
          'shields for resistances, and a clock for idle/cooldown nodes.',
    ],
  ),
  PatchNote(
    build: 101,
    title: 'Hand-Drawn Race & Gender Emblems',
    date: '2026-08-22',
    changes: [
      'Gender (♂/♀) and all 10 races now use custom hand-drawn emblems in '
          'character creation and the hero header — a leaf for Elf, hammer for '
          'Dwarf, horns for Tiefling, dragon head for Dragonborn, and more.',
    ],
  ),
  PatchNote(
    build: 100,
    title: 'Custom Combat Stat Icons',
    date: '2026-08-22',
    changes: [
      'Artifact table bonuses and the Hero Stats page now use hand-drawn stat '
          'icons — power, armor, HP, crit, crit damage, pierce, gold, XP and '
          'shards — instead of generic icons.',
    ],
  ),
  PatchNote(
    build: 99,
    title: 'More Hand-Drawn Icons',
    date: '2026-08-22',
    changes: [
      'Ability Scores now use custom emblems — a fist for Power, feather for '
          'Agility, heart for Vitality, crosshair for Precision, shield for '
          'Fortitude and a clover for Luck.',
      'Upgrade synergies now show the two node emblems that fuse to unlock them.',
    ],
  ),
  PatchNote(
    build: 98,
    title: 'Hand-Drawn Upgrade Emblems',
    date: '2026-08-22',
    changes: [
      'The Upgrades screen nodes now use custom hand-drawn emblems instead of '
          'text badges — a sword for Brutality, crosshair for Precision, shield '
          'for Toughness, coin for Prosperity, eye for Insight and star for Focus.',
    ],
  ),
  PatchNote(
    build: 97,
    title: 'Echoes Upgrade Milestones Buffed',
    date: '2026-08-22',
    changes: [
      'Every Lv5/10/25 milestone perk on the Upgrades screen now hits much '
          'harder: Iron Grip +12% crit, Keen Edge +20% crit, Light Footed +5 AC, '
          'Blade Flicker 22%, Shadow Step 25% dodge, Thick Hide −3 dmg, Battle '
          'Scarred 5% HP/hit, Exploit Weakness +30%, Arcane Efficiency +40% gold, '
          'Rally Cry +40% XP, Silver Tongue −15% cost, Frugal Mind 25%.',
      'Fixed two milestones that did nothing: Studied Foe now gives +15% gold and '
          'Farsight now gives +20% Echoes.',
    ],
  ),
  PatchNote(
    build: 96,
    title: 'Crit Overflow, Bestiary Sprites & ZCoin Visibility',
    date: '2026-08-22',
    changes: [
      'Crit Chance cap raised from 75% to 100%. Any crit chance above 100% now '
          'overflows into bonus Crit Damage (+1% crit damage per 1% overflow) — no '
          'more wasted crit rating.',
      'The Bestiary now shows each monster\'s actual battle sprite once discovered.',
      'Companions and Mercenaries screens now show your ZCoins balance.',
    ],
  ),
  PatchNote(
    build: 95,
    title: 'Claim Summary & Consistent AC',
    date: '2026-08-21',
    changes: [
      'Claiming all achievements now shows a summary popup of exactly what you '
          'received — total Shards, Essence and ZCoins.',
      'Armor is now labelled "AC" everywhere (artifacts, PvP, quests and combat '
          'logs previously showed "ARM").',
    ],
  ),
  PatchNote(
    build: 94,
    title: 'Stat Glossary in Knowledge Base',
    date: '2026-08-21',
    changes: [
      'Added a STATS tab to the Knowledge Base explaining every abbreviation — '
          'HP, ATK, DMG, AC/ARM, RES, CRIT, PEN, DODGE, CD, DoT and all gear '
          'attribute stats — with what each one means and how it improves your hero.',
    ],
  ),
  PatchNote(
    build: 93,
    title: 'Hand-Drawn Rune Art (All Classes)',
    date: '2026-08-21',
    changes: [
      'Every class now has custom carved-stone rune art — Wizard, Sorcerer, '
          'Warlock, Bard, Monk and Druid complete the set. All ~120 runes are '
          'drawn as themed engraved glyphs matching the game\'s art style.',
    ],
  ),
  PatchNote(
    build: 92,
    title: 'Hand-Drawn Rune Art (6 Classes)',
    date: '2026-08-21',
    changes: [
      'Custom carved-stone rune art now covers Fighter, Rogue, Ranger, Paladin '
          'and Cleric too — each rune drawn as a themed engraved glyph. Wizard, '
          'Sorcerer, Warlock, Bard, Monk and Druid are up next.',
    ],
  ),
  PatchNote(
    build: 91,
    title: 'Hand-Drawn Rune Art (Barbarian)',
    date: '2026-08-21',
    changes: [
      'Runes now use custom carved-stone pixel-art tablets instead of emoji, '
          'matching the game\'s crafted-gem style. Barbarian runes are done first; '
          'the rest of the classes follow in coming updates.',
    ],
  ),
  PatchNote(
    build: 90,
    title: 'Tower Ascension Speed Control',
    date: '2026-08-21',
    changes: [
      'Tower Ascension now has a battle-speed button in its top bar, matching '
          'every other mode — including the 3× from the Speed Boost / Premium Pass.',
    ],
  ),
  PatchNote(
    build: 89,
    title: 'Cleaner Craft Gem Layout',
    date: '2026-08-21',
    changes: [
      'The Craft Gem screen now lists one gem per line with room to spell out '
          'each gem\'s element (e.g. Ruby → Fire) and exactly how much damage it '
          'adds in a weapon and resistance it adds in armor. Removed the wall of '
          'explainer text at the top.',
    ],
  ),
  PatchNote(
    build: 88,
    title: 'Consistent Battle Speed',
    date: '2026-08-21',
    changes: [
      'The Dungeon now honours your full battle speed — including the 3× from the '
          'Speed Boost / Premium Pass — instead of capping at 2×. Battle speed is '
          'now identical across Campaign, Dungeon, Boss Rush, Gauntlet and PvP.',
    ],
  ),
  PatchNote(
    build: 87,
    title: 'Ultimate Ability Clarity',
    date: '2026-08-21',
    changes: [
      'The Ability screen now shows a locked Ultimate preview until you unlock it '
          '— clearly stating it unlocks at Level 30 and requires finishing your '
          'class questline, with live progress on both.',
    ],
  ),
  PatchNote(
    build: 86,
    title: 'Clearer Gems',
    date: '2026-08-21',
    changes: [
      'Gems now spell out both of their effects everywhere — one gem per line, '
          'showing the elemental DAMAGE they add in a weapon AND the elemental '
          'RESISTANCE they add in armor or jewelry.',
      'When socketing, each item now shows exactly what the gem will do in that '
          'slot (e.g. "+10% Fire DMG" on a weapon vs "+10% Fire RES" on armor).',
    ],
  ),
  PatchNote(
    build: 85,
    title: 'Gauntlet Curve Smoothed',
    date: '2026-08-21',
    changes: [
      'Gauntlet tier 1 is now a fair challenge — the 10 waves ramp gently to a '
          'campaign-parity final boss instead of ending on a brick-wall enemy. '
          'Higher tiers scale up smoothly, and top tiers no longer flatten out.',
      'Waves within a run are ordered easiest-to-toughest, so difficulty always '
          'climbs.',
    ],
  ),
  PatchNote(
    build: 84,
    title: 'Boss Rush Curve Smoothed',
    date: '2026-08-21',
    changes: [
      'Tier 1 now sits at campaign parity — the five bosses are the ones you '
          'already beat on the map, fought back-to-back, so a ~level-20 hero can '
          'clear it. Higher tiers ramp up smoothly from there.',
      'Bosses within a run are now ordered easiest-to-toughest, so difficulty '
          'always climbs instead of spiking mid-run.',
    ],
  ),
  PatchNote(
    build: 83,
    title: 'Boss Rush Rebalance',
    date: '2026-08-19',
    changes: [
      'Boss Rush tier 1 is now a fair ~level-20 challenge — its bosses come from '
          'earlier campaign stages, and each higher tier scales deeper. No more '
          'brick wall on the final tier-1 boss.',
    ],
  ),
  PatchNote(
    build: 82,
    title: 'Clearer "How to Get" Resources',
    date: '2026-08-19',
    changes: [
      'Upgrade screens now clearly show where to farm the resource they use — '
          'Scores (Gold), Mercs (Shards + ZCoins), Forge and Runes all get a '
          '"how to get" line, and the Shards sources are now consistent.',
    ],
  ),
  PatchNote(
    build: 81,
    title: 'Artifact Farming Guide',
    date: '2026-08-19',
    changes: [
      'The Artifacts screen now shows exactly where to farm artifacts — Campaign '
          'bosses, Dungeon runs and Boss Rush — and how each one drops.',
    ],
  ),
  PatchNote(
    build: 80,
    title: 'Auto-Campaign Fix',
    date: '2026-08-19',
    changes: [
      'Auto-Campaign no longer silently plays through the campaign in the '
          'background — it now only auto-fights while you\'re watching the Battle '
          'screen.',
    ],
  ),
  PatchNote(
    build: 79,
    title: 'Rebirth Boons Revamp',
    date: '2026-08-19',
    changes: [
      'Rebirth boons are now a pool of 27, each with a rarity from Uncommon to '
          'Legendary shown by a coloured frame and in the description.',
      'The rarer you\'ve grown (more Rebirths + Ascension Points), the better the '
          'boons you\'ll be offered.',
      'Replaced the Mythril boon with more useful gold/XP/soul/resource gifts.',
    ],
  ),
  PatchNote(
    build: 78,
    title: 'Energy Refills Offline + Battle UI Tidy',
    date: '2026-08-19',
    changes: [
      'Campaign Energy now refills in real time and while you\'re away — no more '
          'being stuck at 0/20.',
      'Battle arena: replaced the "CRIT %" chip with a clearer ARMOR value.',
      'Mercenary upgrades now show the correct ZCoin icon (not a crystal).',
    ],
  ),
  PatchNote(
    build: 76,
    title: 'PvP Speed + Log, Mercs Indicator, Dragon Art',
    date: '2026-08-19',
    changes: [
      'PvP Arena now has a speed button and a battle-log button, and the '
          'victory screen no longer hides behind the phone\'s nav bar.',
      'The MERCS panel now shows an indicator when a mercenary upgrade is '
          'affordable.',
      'The premium Ember Dragon pet now has hand-drawn pixel art matching the '
          'other companions.',
    ],
  ),
  PatchNote(
    build: 73,
    title: 'Dungeon Fix + Artifact Auto-Equip + Gem Clarity',
    date: '2026-08-19',
    changes: [
      'Fixed being unable to claim a relic (and progress) after a dungeon boss '
          '— plus a Skip option so you\'re never stuck.',
      'Dungeon speed now matches the rest of the game (the paid speed is the '
          'only booster).',
      'NEW: Auto-Equip button on the Artifact table — fills every slot with your '
          'best artifacts by rarity.',
      'Gems: fixed the cost label (Arcane Dust) and added a clear explanation of '
          'what gems do and where to socket them.',
    ],
  ),
  PatchNote(
    build: 72,
    title: 'Character Save Fix',
    date: '2026-08-18',
    changes: [
      'Fixed a serious bug where cloud save could make two character slots show '
          'the same hero — each slot now syncs to the cloud independently.',
      'Corrected the locked-slot hint on Character Select (buy slots in '
          'Shop → Misc).',
    ],
  ),
  PatchNote(
    build: 71,
    title: 'Bigger Bounty Rewards',
    date: '2026-08-18',
    changes: [
      'Bounty rewards are now 5× more generous across gold, shards, ZCoins and '
          'XP — worth the effort!',
    ],
  ),
  PatchNote(
    build: 70,
    title: 'More Character Slots + Shop Fixes',
    date: '2026-08-18',
    changes: [
      'You can now own up to 12 characters! Extra slots cost 250 ZCoins for the '
          'first and +250 for each one after.',
      'Fixed ZCoin packs sometimes saying "you already own this item" — stuck '
          'purchases are now cleared so you can buy again.',
      'Auto-Campaign now runs until you die or turn it off; removed the '
          'non-working resource bar (totals show on the screens that use them).',
    ],
  ),
  PatchNote(
    build: 67,
    title: 'Resource Shop + Dragon Power + Battle Flair',
    date: '2026-08-18',
    changes: [
      'NEW Shop → RESOURCES: spend ZCoins on gold, shards, echoes, essence and '
          'mythril bundles.',
      'The Ember Dragon now grants EVERY pet bonus at once and stands out with a '
          'golden premium look.',
      'Your equipped name colour (and glow) + portrait frame now show on your '
          'hero in the battle arena — no more plain green name.',
    ],
  ),
  PatchNote(
    build: 66,
    title: 'Guild Castle — Build It Together',
    date: '2026-08-18',
    changes: [
      'NEW: your guild can now build a 10-tier Castle! Donate gold in the new '
          'CASTLE tab to earn Construction Points and raise the keep.',
      'Each tier unlocks real guild-wide benefits — gold, storage, roster '
          'capacity, extra boss attacks, expedition slots and more.',
      'Daily contribution cap keeps it fair: active guilds beat rich solo '
          'players. Tier 10 is a months-long prestige goal.',
    ],
  ),
  PatchNote(
    build: 65,
    title: 'Ember Dragon + Shop Revamp + Attack FX',
    date: '2026-08-18',
    changes: [
      'NEW premium companion: the 🐉 Ember Dragon — a real-money exclusive pet '
          'whose upgrades scale 500 → 1000 → 1500 ZCoins and beyond.',
      'Pets now stay with you through every Rebirth and Ascension.',
      'Shop revamped: Titles, Name Colours, Frames and Attack Effects each get '
          'their own section.',
      'Attack Effects now actually replace your basic attack visual in every '
          'combat mode — equip one and watch your hits change.',
    ],
  ),
  PatchNote(
    build: 62,
    title: 'More Cosmetics + Glow Effects',
    date: '2026-08-17',
    changes: [
      'Loads of new frames, name colours and titles in the Shop — several with '
          'a glowing effect that shows on your name and portrait.',
      'Cosmetic prices rebalanced (frames 500–1500, name colours 250–1000, '
          'titles 500–1500 ZCoins).',
      'NEW real-money exclusives: the Eclipse Frame, Prismatic Name and "The '
          'Eternal" title — one-time purchases for the ultimate flex.',
    ],
  ),
  PatchNote(
    build: 61,
    title: 'Framed Name + Endgame Unlocks',
    date: '2026-08-17',
    changes: [
      'Your hero name on the Hero sheet now sits in a frame tinted with your '
          'equipped frame / name colour.',
      'Once you\'ve Rebirthed or earned any Ascension Points, every game mode '
          'and Hero-sheet tab stays unlocked — Ascension no longer re-locks '
          'content by resetting your rebirth count.',
    ],
  ),
  PatchNote(
    build: 60,
    title: 'Cosmetics Show Off + Auto-Campaign',
    date: '2026-08-17',
    changes: [
      'Your equipped Title, name colour, portrait frame and premium skin now '
          'show on the Leaderboard, PvP, and your Hero sheet — flex your look!',
      'Tap any player on the Leaderboard to view their character profile.',
      'Auto-Campaign (subscribers) now runs hands-free right on the Battle '
          'screen — fights animate and auto-advance while you watch.',
      'Fixed the equipped skin not showing on the Leaderboard (was the base '
          'class sprite).',
      'Tidied the Battle screen back button.',
    ],
  ),
  PatchNote(
    build: 59,
    title: 'Rebirth No Longer Re-Locks Content',
    date: '2026-08-17',
    changes: [
      'Fixed: Rebirth wiped your level-50 Specialization — it is now permanent '
          'and survives Rebirth and Ascension.',
      'Fixed: after a Rebirth the Guild tab, boss selector, battle allies, '
          'hard mode and other unlocked content stayed available (no more '
          're-locking now that campaign progress resets).',
      'NEW: your total Ascension Points (AP) now show on the character-select '
          'screen and the Hero stats sheet, so endgame progress is visible.',
    ],
  ),
  PatchNote(
    build: 58,
    title: 'Season Pass Track + Fixes',
    date: '2026-08-17',
    changes: [
      'NEW: Season Pass screen (PLAY → Progression) — view all 30 tiers, '
          'track your XP, and claim free + premium rewards.',
      'Premium Pass now unlocks the premium reward track and grants 2× Season XP.',
      'Auras with HP recovery now heal a % of max HP every turn (sustain), '
          'instead of a tiny flat heal after each win — in every game mode.',
      'Achievements now persist through Rebirth and Ascension.',
      'Premium Pass / Speed Boost perks now activate reliably and restore on launch.',
    ],
  ),
  PatchNote(
    build: 52,
    title: 'What\'s New + Battle Log Rounds',
    date: '2026-08-16',
    changes: [
      'NEW: this What\'s New panel — read every update right here.',
      'Battle log now groups actions by round for easier reading.',
    ],
  ),
  PatchNote(
    build: 51,
    title: 'Post-Fight Summary Everywhere',
    date: '2026-08-15',
    changes: [
      'The post-fight summary + colour-coded log now works in Dungeon, Boss '
          'Rush, Gauntlet and PvP too (not just Campaign & Endless).',
      'Tap the stats icon in any battle to review total/max/avg damage, '
          'abilities used, and the full log.',
    ],
  ),
  PatchNote(
    build: 49,
    title: 'Cleaner Battle Log + Community',
    date: '2026-08-15',
    changes: [
      'Battle-log numbers trim to K/M/B and are highlighted so values pop.',
      'Repeated lines collapse to "line ×N".',
      'Added Discord and Reddit buttons to the Hero header — come say hi!',
    ],
  ),
  PatchNote(
    build: 48,
    title: 'Number Trimming + Campaign Cap',
    date: '2026-08-15',
    changes: [
      'Damage and HP numbers now trim to K/M/B across every battle mode.',
      'Campaign now ends cleanly at stage 100 — beat the Omega, then Rebirth.',
    ],
  ),
  PatchNote(
    build: 47,
    title: 'Post-Fight Summary',
    date: '2026-08-14',
    changes: [
      'NEW: tap the stats icon after a fight for a full breakdown — total, max '
          'and average damage, abilities used, and a colour-coded battle log.',
    ],
  ),
  PatchNote(
    build: 45,
    title: 'Ascension Fixes',
    date: '2026-08-13',
    changes: [
      'Fixed: rebirthing no longer wipes your ascension progress.',
      'Leaderboards now count ascension, so ascending won\'t drop your rank.',
    ],
  ),
  PatchNote(
    build: 43,
    title: 'Ability Ascension',
    date: '2026-08-13',
    changes: [
      'NEW: spend Ascension Points to ascend your class abilities '
          '(+10% power per tier, up to 10 tiers each).',
      'Clearer explanation of the Ascension Point system.',
    ],
  ),
  PatchNote(
    build: 42,
    title: 'Ascension Overhaul',
    date: '2026-08-13',
    changes: [
      'Ascension Points now scale with the Rebirths you sacrifice.',
      'Bigger, more meaningful ascension bonuses (incl. % all-damage).',
    ],
  ),
  PatchNote(
    build: 41,
    title: 'Hero Rename',
    date: '2026-08-12',
    changes: [
      'Rename your hero from Settings (Z-Coin cost, rises each time).',
    ],
  ),
  PatchNote(
    build: 39,
    title: 'Leaderboards',
    date: '2026-08-12',
    changes: [
      'NEW: leaderboards for Campaign, Dungeon, Boss Rush and Gauntlet — see '
          'the top 50 and your global rank.',
      'Rows show your class sprite, class and level-50 subclass.',
    ],
  ),
  PatchNote(
    build: 36,
    title: 'Stability',
    date: '2026-08-12',
    changes: [
      'Fixed a crash when resetting or deleting a character.',
    ],
  ),
  PatchNote(
    build: 34,
    title: 'Difficulty & Rewards',
    date: '2026-08-11',
    changes: [
      'Dungeon, Boss Rush and Gauntlet now scale with your Rebirths, with '
          'rewards to match.',
    ],
  ),
  PatchNote(
    build: 32,
    title: 'Paragon Board',
    date: '2026-08-11',
    changes: [
      'NEW: the Paragon Board — pour Paragon Points into endless, stackable '
          'upgrades across Combat, Economy, Progression and Mastery.',
    ],
  ),
];
