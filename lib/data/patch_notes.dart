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
