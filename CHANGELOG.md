# Changelog

Version numbers are the pubspec build number (`0.1.0+N`), which is the Play
Store `versionCode`. Newest first.

## +52 — What's New panel + battle-log round dividers
- **What's New** in-app patch-notes viewer (data-driven `kPatchNotes`, newest
  first, scrollable history). Megaphone button in the Hero header; a red dot
  badges unread updates (tracked via `lastSeenPatchBuild`, cleared on open).
- Battle log now emits **"— Round N —"** markers each round across all modes,
  rendered as labelled dividers in the summary sheet.

## +51 — Post-fight summary standardized to all screen modes
- Instrumented **Dungeon / Boss Rush / Gauntlet / PvP** to snapshot a
  `FightSummary` (total/max/hit-count/abilities) and added the summary icon.
  The colour-coded, number-trimmed summary sheet now works in every arena mode.

## +50 — Post-fight summary to Endless + Tower Ascension
- `_resetBattlePerks` now resets the per-fight summary stats, so every
  game_state-driven fight snapshots a clean summary; added the icon to the
  Endless / Tower screen.

## +49 — Battle-log polish + community buttons
- Log numbers **trim to K/M/B** and are bold + brightened; consecutive identical
  lines **collapse to "line ×N"**.
- **Discord + Reddit** buttons in the Hero header, brand-gold.

## +48 — Number trimming (game-wide) + campaign cap
- Damage floats, HP bars, and the HIT stat trim to **K/M/B** across every arena
  mode (shared `BattleArena`).
- Campaign **caps at stage 100** — beat the Omega, then Rebirth; no more endless
  Abyss drift. Header reads "CAMPAIGN COMPLETE" past 100.

## +47 — Post-fight summary + colour-coded battle log
- Tap the stats icon after a fight for a breakdown: total / max / avg damage,
  hit count, rounds, abilities used, and a colour-coded, icon-tagged log.

## +46 — Fight summary counts all damage + nav-bar fix
- Total/Max/Avg/Hits now include ability, DoT, thorns and ally damage (not just
  auto-attacks). Summary sheet wrapped in a bottom SafeArea.

## +45 — Ascension-wipe fix + leaderboards count ascension
- Fixed: `prestige()` never saved ascension, so **rebirthing wiped all ascension
  progress** — now preserved through a rebirth.
- Campaign & Dungeon boards rank by **effective rebirths = current + total AP
  earned**, so ascending no longer drops you.

## +44 — Post-fight summary (campaign)
- New `FightSummary` snapshot + summary sheet (stat breakdown + battle log),
  opened from a stats icon on the battle screen.

## +43 — Ability Ascension + clearer AP explanation
- Spend Ascension Points to ascend each class ability 0–10 tiers (1 AP/tier,
  60 AP/character), +10% ability power per tier. Survives rebirth & ascension.
- Rewrote the Ascension screen's AP explanation with a KEEP / LOSE breakdown.

## +42 — Ascension rework
- Ascension Point payout **scales with rebirths sacrificed** (was a flat 3).
- Bonuses ~2× bigger; flat "+2 damage" node became **+12% all-damage per level**;
  Legacy Power buffed to +30%/level.

## +41 — Paid hero rename
- **Rename Hero now costs Z-Coins**, escalating +50 each rename (50 → 100 → 150 …),
  tracked by a persisted counter. Settings shows the current price; the dialog
  shows cost + balance and blocks empty/profane names and insufficient funds.

## +40 — Leaderboard identity refresh + Rename Hero
- Opening a board now **refreshes your row's name / class / subclass / sprite**
  even without a new personal best, so older entries stop looking stale.
- Added a **Rename Hero** option in Settings (free in +40; made paid in +41).

## +39 — Leaderboard sprite avatars
- Added a small **class-sprite avatar** next to each name on every leaderboard row
  (stored per entry; legacy rows fall back to a person icon).

## +38 — Leaderboard subclass + capitalization
- Rows now show the **level-50 subclass in brackets** and a properly
  **capitalized class name**, e.g. `Paladin (Oath of the Watchers)`.

## +37 — Leaderboards + profanity name filter
- **New: Leaderboards** for Campaign, Dungeon, Boss Rush, and Gauntlet (Endless
  folded into the same system). A 🏆 button in each mode shows the **top 50** and
  **your global rank** (via Firestore `count()`, so it shows even outside the 50).
  - Campaign/Dungeon rank by **Rebirths, then stage/tier**; Boss Rush/Gauntlet by
    best score. Ranking packs the dimensions into one sortable score.
  - Auto-submits your current best on open (personal-best only) and highlights
    your row.
- **Profanity filter** on character-creation names (names are now public).
- Firestore rules added + deployed for the four new leaderboard collections.

## +36 — Reset/delete crash fix
- Fixed a fatal crash on **character delete / reset**
  (`_Map<dynamic,dynamic>` is not a subtype of `Map<String,dynamic>`). The
  equipment loader now parses saved/reset data defensively.

## +35 — Death-anim fix, avg-hit HUD label, per-mode Remote Config
- **Death animation:** the enemy no longer plays its death animation when the
  hero dies on the same beat (e.g. the Volatile Death explosion).
- **HUD label:** the combatant panel now shows `HIT:<avg>` (a rolling average of
  real hits) instead of the old to-hit number.
- **Remote Config:** dungeon / boss-rush / gauntlet enemy difficulty is now
  live-tunable (`*_hp_mult` / `*_atk_mult`, default 1.0).

## +34 — Side-mode rebirth scaling
- Dungeon, Boss Rush, and Gauntlet enemies now scale with **rebirths**
  (+20% HP / +12% ATK each), matching the campaign, with soft-currency rewards
  scaled to match.

## +33 — Difficulty rebalance
- Narrowed the dungeon **trash-vs-boss** gap: regular/ambush enemies up to ×1.3,
  bosses softened (HP ×2.5→×1.9, gentler attack curve).

## +32 — Paragon board
- Added a **Paragon board**: rankable, infinitely-scaling stat investment
  (Might, Vitality, Precision, Ferocity, Fortune, Wisdom, Eternal Flame) so
  Paragon Points always have a sink after many rebirths.

---

## Play Store "What's new" (for the +52 listing)

```
• Post-fight summaries + a cleaner, colour-coded battle log — now in every mode
• Damage & HP numbers trim to K/M/B
• Campaign now ends cleanly at stage 100
• NEW: What's New panel + Discord/Reddit links in the Hero screen
• Various fixes & polish
```
