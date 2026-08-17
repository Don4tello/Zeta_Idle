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
