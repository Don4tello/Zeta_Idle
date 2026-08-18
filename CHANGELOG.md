# Changelog

Version numbers are the pubspec build number (`0.1.0+N`), which is the Play
Store `versionCode`. Newest first.

## +72 — Per-slot cloud saves (fix cross-slot character bug) + locked-slot text
- **Data-loss bug fixed:** the cloud save was one doc per account with no slot
  dimension, so loading any slot pulled the same account-wide cloud save and
  overwrote it — making multiple slots show the same character. `CloudSaveService`
  now stores each slot independently within the account doc (`slot_<n>`/`ts_<n>`
  fields, doc id stays `uid` so Firestore rules are unchanged); all
  fetch/sync/loadSlot call sites pass `_currentSlot`.
- Fixed the Character-Select locked-slot hint (was "Cosmetics → Boosts 100 ZC";
  now "Shop → Misc" with the correct scaling price).

## +71 — 5× bounty rewards
- `BountyReward` now applies a `rewardMultiplier = 5` in its constructor, so
  every bounty in the pool pays out 5× gold/ZCoins/shards/XP without editing
  each entry. UI and claim both read the scaled values.

## +70 — 12 character slots + consumable IAP fix + auto-campaign/resource-bar
- **Character slots up to 12** (was 5): `SaveService.maxSlots=12`,
  `maxExtraSlots=9`, clamps updated. `GameState.characterSlotCost = 250 ×
  (extra+1)` (250, 500, … 2250), `canBuyCharacterSlot`, `totalCharacterSlots`.
  Slots UI + character-select lock tile extended to 12.
- **Fixed "you already own this item" on ZCoin packs:** `_handlePurchases` now
  distinguishes consumables (`crystals_*`) — restored consumables are completed
  (consumed) without re-granting so a stuck owned pack clears; errors/cancels
  with a pending completion are also finished. `restorePurchases()` on launch
  surfaces stuck packs to consume.
- (+68) Auto-campaign no longer stops at content-unlock stages — only on death
  or manual toggle. (+69) Removed the non-rendering global resource bar; each
  spending screen shows its own balance.

## +67 — Resource shop + omni dragon + battle-arena name cosmetics
- **Shop → RESOURCES** tab: `ResourceBundle` catalog + `GameState.buyResourceBundle`
  (spend ZCoins on gold/shards/echoes/essence/mythril, two tiers each).
- **Ember Dragon = omni pet:** `PetDefinition.omniBonuses` grants every
  `PetBonusType` at once (combined stats of all pets, evolving via the step
  upgrades). `_sumOwnedPetBonus` honours it. Pet card gets a gold gradient +
  glow + ★ PREMIUM badge and an "ALL bonuses" label.
- **Battle-arena hero name** now uses the equipped **name colour + glow** and is
  wrapped in the equipped **frame** (was hardcoded green). Resolved via new
  `GameStateProvider.maybeOf`; `_CombatantPanel` gained `frameColor`/`nameGlow`.

## +66 — Guild Castle (gold-built 10-tier construction track)
- **New parallel guild progression** layered on top of the XP levels: members
  donate gold → **Construction Points** (daily-capped, `CastleTier.dailyCpCap`),
  building a **10-tier castle**. `guild_castle.dart`: `CastleState`,
  `GuildContribution`, `GuildBuffs`, `CastleContribResult`, cost curve
  (`marginalCP = 1000×1.6^(t-2)`, `goldPerCP = 250×1.9^(t-1)`, tier-5+ upkeep).
- **`PixelCastle` CustomPainter** — one painter renders tiers 1–10 as growth of
  one structure (composable `_draw*` gated by tier, deterministic per-guild
  banner tint, tier-10 animated flags). `CastleGallery` debug screen +
  `/game/castle-gallery` route. 21 unit tests (thresholds/caps/upkeep/buffs).
- **CASTLE tab** in the guild screen: castle art, CP progress bar, contribute
  buttons (+10/25/50/100 CP), active-benefits list.
- `GuildService.contributeConstruction` (gold→CP, daily cap, weekly upkeep) +
  `fetchConstructions`. `Guild` gains a `castle` field (json round-trip).
- **`GameState.guildBuffs`** resolves castle benefits; the castle gold % is
  applied to kill gold (gameplay never reads `castle.tier`).

## +65 — Ember Dragon pet + shop revamp + attack-effect override
- **Premium Ember Dragon pet** (`ember_dragon`, real-money `pet_premium_dragon`,
  $4.99): `PetDefinition` gains `isPremium`/`productId`/`evoCostStep`/
  `fallbackPrice`. Upgrade cost uses a linear step curve (`evoCostStep*(level+1)`
  → 500/1000/1500…). `purchasePet` refuses premium pets; `unlockPremiumPet`
  grants+equips on IAP (`IapService.onPetPurchased`).
- **Pets survive Ascension** too — `ascend()` now saves/restores
  `ownedPetIds`/`equippedPetId`/`petEvolutionLevels` (prestige already did).
- **Shop revamp:** the COSMETICS tab now has separate **Titles / Name Colours /
  Frames / Attack Effects** sections; Attack Effects moved out of Boosts
  (`AttackEffectsSection` extracted from `CosmeticsBoostsSection`).
- **Attack effects take over everywhere:** the equipped effect now plays on
  normal auto-attacks in Dungeon, Gauntlet, Boss Rush and PvP (battle_screen
  already did); the effect's hit-text was already wired into the log.

## +62 — Cosmetic expansion + glow effects + real-money exclusives
- **Reprice + expand** the cosmetic catalog: frames 500–1500, name colours
  250–1000, titles 500–1500 ZCoins. Added new frames (Frost, Verdant, Storm,
  Bloodforged), name colours (Emerald, Sunset, Shadow, Inferno, Celestial) and
  titles (Warlord, Shadowblade, Dragonheart, Ascendant).
- **Glow effect:** `CosmeticItem.glow` + `hasGlow()`; glowing name colours cast
  a text shadow on the hero sheet, leaderboard, PvP and profile, and glow
  frames/cards get a stronger ring in the shop.
- **Real-money exclusives** (`productId` on `CosmeticItem`, `isRealMoney`): the
  **Eclipse Frame** (`cosmetic_frame_eclipse`), **Prismatic Name**
  (`cosmetic_name_prismatic`) and **"The Eternal"** title
  (`cosmetic_title_eternal`) — IAP-only, wired through `IapService`
  (`onCosmeticPurchased`) → `unlockCosmeticByProduct` (grants + auto-equips).
  `purchaseCosmetic` refuses to spend ZCoins on them.

## +61 — Framed hero name + endgame unlock rule
- Hero STATS identity header now wraps the name in a **frame plate tinted by the
  equipped frame / name colour** (falls back to gold).
- **Endgame unlock rule:** new `endgameUnlocked` getter (Rebirth > 0 OR
  Ascension AP/level > 0). `effectiveUnlockStage` and the Hero-sheet tab gating
  now key off it, so **Ascension no longer re-locks** modes/tabs by zeroing the
  prestige count. Every mode + tab stays unlocked once you've reached the
  endgame.

## +60 — Cosmetic identity everywhere + hands-free auto-campaign
- **Cosmetics now render.** Equipped **title, name colour, portrait frame, and
  premium skin sprite** show on the Leaderboard rows, PvP display, and a new
  identity header on the Hero STATS sheet. `CosmeticItem` gained
  `nameColorFor`/`frameColorFor`/`titleColorForName` helpers.
- **Leaderboard entries carry identity:** `title`, `nameColorId`, `frameId`,
  `level`, `ascensionAp`, and the equipped **battle sprite** (`heroBattleSpriteId`
  — fixes premium skins showing the base class sprite). All 5 `submitScore`
  call sites + Firestore validation updated.
- **Tap a leaderboard row → player profile** (`player_profile_sheet.dart`):
  read-only character sheet (avatar+frame, title, name, class, rank, rebirths,
  level, AP) — no idle battle / next-action panels.
- **PvP snapshots** carry title/nameColorId/frameId/spriteId; the PvP ladder
  renders them.
- **Hands-free auto-campaign:** the Battle screen now auto-advances between
  stages when Auto-Campaign is on (visible animated fights). A new
  `battleScreenActive` flag stops the silent background sim from double-running
  the same stage while the screen is open.
- Battle screen back button no longer shows a truncated "B…" title.

## +59 — Rebirth no longer re-locks content + AP display
- **Fixed data loss:** `prestige()` and `ascend()` never saved/restored
  `subclassId`, so `_resetToDefaults` **permanently wiped the level-50
  Specialization** on every Rebirth/Ascension. Now saved and restored;
  `subclassUnlocked` latches on `subclassId != null` so the tab stays visible.
- **Fixed re-locking:** several unlock gates read `campaignStageIndex` (resets to
  0 on rebirth) instead of `effectiveUnlockStage` (latches ≥100). Switched the
  Guild tab (`main_shell`), defeat-dialog modes (`battle_screen`), quick-access
  grid (`home_screen`), Endless boss selector, campaign Hard-Mode toggle, battle
  allies (`battle_split_panel`), and the daily dashboard hint.
- **AP visibility:** cumulative **Ascension Points** now render on the
  character-select slot (`⭑ N AP`) and the Hero stats header, so you can see how
  far a character got into the endgame. `CharacterSummary` carries
  `totalAscensionAp`, read from the save.

## +58 — Premium season-pass track
- New **Season Pass** screen (PLAY → Progression): 30-tier two-track ladder with
  an XP progress bar, per-tier free/premium claim, **Claim All**, and an *Unlock
  Premium* CTA for non-subscribers. Auto-scrolls to the current tier; home menu
  shows an unclaimed-rewards badge.
- `claimSeasonPremium` now **requires an active Premium Pass** (free players could
  previously claim premium rewards). Claim methods return `bool`; added
  `claimAllSeason()`, `seasonUnclaimedCount`, and tier-progress getters.

## +57 — Aura HP regen in every mode
- Extended the aura per-turn HP-regen sustain to **Dungeon / Boss Rush /
  Gauntlet** screen loops, matching the game_state path.

## +56 — Aura sustain + achievement persistence
- Auras with HP recovery now **heal a % of max HP each turn** (sustain) instead
  of a small flat heal after each win; relabelled accordingly.
- **Achievements persist through Rebirth and Ascension** (saved/restored around
  the reset).

## +53–55 — Subscription perks wired end-to-end
- Premium Pass / Speed Boost now **activate reliably** (set-not-accumulate
  expiry) and **restore on launch** (`restorePurchases` after slot load).
- Wired all perks: **+50% idle gold**, **2× Season XP**, up to **3× battle
  speed**, **auto-campaign** gating, and **monthly ZCoin grants** (Premium 300 /
  Speed 100, idempotent).

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
