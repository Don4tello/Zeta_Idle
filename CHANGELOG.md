# Changelog

Version numbers are the pubspec build number (`0.1.0+N`), which is the Play
Store `versionCode`. Newest first.

## +301 — PvP tuning: 99% dmg cut + 10%-HP per-hit cap
User: prefers more damage reduction (95% or 99%?). Clarified that for strong builds the per-hit CAP is the binding limit, not the %. Set `pvp_hero_dmg_mult` 0.10→0.01 (−99%, mainly protects weaker builds) and `pvp_max_hit_fraction` 0.15→0.10 (min ~10 hits to kill — the real fight-length lever). Both still Remote-Config tunable; cap is the knob to move for longer/shorter fights.

## +300 — PvP: tier-scaled (mirror) bot opponents + one-shot cap
User: can we auto-update PvP characters based on the unlocked campaign tier? Root issue: bots were D&D-scale (maxHp≤999, stats from rating÷80) while the player is game-scale (500K+ HP), so every bot was a faceroll.
- `pvp.dart` `generateBotOpponent(myRating, {mirror})`: when a mirror snapshot is given, the bot is a ±15% variance copy of the PLAYER's own snapshot (random class). Since the snapshot's stats already reflect unlocked-tier power (prestige mults etc.), bots auto-scale as you climb tiers. Legacy rating-derived bot kept as the no-mirror fallback.
- `pvp_screen.dart`: build `mySnap` once up front and pass it as the mirror to `generateBotOpponent`.
- Damage-cap fix (completes +299): a flat % cut alone can't stop a one-shot once the bot is same-scale HP (a glass-cannon hit still exceeds a same-scale pool). `_pvpDamageScaled` now also HARD-CAPS a single hit to `pvp_max_hit_fraction` (default 0.15) of the foe's max HP → min ~7 hits to kill, any build. New Remote Config key alongside `pvp_hero_dmg_mult`; both tunable without a rebuild.

## +299 — PvP hero-damage compression (tunable)
User: does reducing PvP damage ~90% make matches better? Analysis of startPvpBattle: the visible fight gives the HERO full game-scale damage vs the rival's non-×5 `maxHp`, so the attacker bursts them in 1–2 rounds while the rival's proxy attack (~4.5%/hit) needs ~22 → attacker near-always wins. Compressing hero damage lets both sides matter.
- `remote_config_service.dart`: new `pvp_hero_dmg_mult` (default 0.10 = −90%), tunable from the Firebase console without a rebuild.
- `game_state.dart`: `_pvpDamageScaled(dmg)` — no-op outside `_pvpMode`, else `× pvpHeroDmgMult`. Applied to the main hero hit + the extra auto-strikes (Blade Flicker / Swift Strike / Mastery multi-strike). NOTE: does not yet scale spell-ability or DoT damage (fine for the auto-attack test fighter; extend if caster PvP still bursts). %-max-HP ally hits left unscaled (intentionally not touched — see the no-%HP-damage rule).
- Validate from the now-logging PvP telemetry (build 297): expect fights to stretch from ~1–2 rounds toward ~10–20; tune `pvp_hero_dmg_mult` up/down from real win-rates and round-counts.

## +298 — In-dungeon Auto Run toggle
User: expose the auto-run button inside the dungeon (in case you forgot to enable it, or want to pause and make manual decisions).
- `dungeon_screen.dart`: the Auto Run AppBar button was gated to `run == null || run.isOver` (lobby/summary only). Removed the gate so it shows during an active run too. `_toggleAuto` now cancels the pending `_autoTimer` when turning OFF (immediate manual control); turning ON calls `_scheduleAutoAction()` which resumes from whatever state the run is in (door junction, resolved room/relic, floor transition). Combat auto-plays via its own timer regardless, so toggling on mid-fight just resumes navigation via `_onRoomResolved` when the fight ends.

## +297 — Tower Ascension threat fix + PvP telemetry
User: "both" (instrument PvP + make Tower Ascension threatening).
- Tower Ascension (`game_state.dart` `startEndlessBattleAtStage`): telemetry showed 12 T5 climbs all won at 100% HP — bosses spawned at `enemy.level + 2` (level 6–30) so their to-hit couldn't land on a high-level hero despite HP scaling ~68×. Fix: `bossLevel = enemy.level + 2 + activeTier * kTierLevelStep` (campaign-parity to-hit) and lifted the artificial `attack` clamp (9999→1e9) and HP clamp (1e7→1e15). HP still scales via the tier mults only (no prestigeLevel → no campaign-curve/frontier double-scale). User-approved ATK/level bump.
- PvP telemetry (`game_state.dart`): the arena fight already runs through the real combat engine. Captured `_pvpOpponent` + reset `_battleTurnCount` in `startPvpBattle`; added `_logPvpTelemetry(won)` emitting a mode:"pvp" ZBAL record (rounds, hero HP%/dmg-taken/dps, opponent level/HP/class, pre-fight rating) from `recordPvpResult`. Now PvP is finally instrumented — note the PvP opponent attack is still a first-pass HP-proxy (startPvpBattle) that this data can tune.

## +296 — Boss Rush HP curve: add accelerating term (post-295 was too easy)
User: "pull alt games for boss rush." Post-295 telemetry: a geared L453 cleared a whole T6 rush in 6 ROUNDS at 100% HP (5/5 bosses) — the 295 fix removed the double-scale but the surviving linear `1 + 0.85t` scaled too gently for an endgame hero.
- `boss_rush_screen.dart`: `tierHpMult` linear `1 + 0.85t` → accelerating `1 + 0.85t + 0.5t²`. T0=1× (parity), T2≈4.7×, T4≈12.4×, T6≈24×, T10≈59.5× (vs old T6≈6.1×). Single-axis (no campaign-curve/frontier re-entry). Quadratic coefficient 0.5 is the tuning knob.
- Caveat: calibrated against a juiced test hero (L453 + injected mythic gear), so re-check the next pull; only HP bumped (boss ATK untouched, per the no-unapproved-ATK-bump rule — flag if it needs to be more *threatening* vs just longer).

## +295 — Fix Boss Rush HP double/triple-scaling
User: "check the logs for alt game modes." Telemetry: Boss Rush runs were 187–565 ROUNDS (won T3 took 303 rounds; T5 killed 0/5 bosses in 45 rounds), while Dungeon clears at 88–100% HP across all tiers.
- Root cause in `boss_rush_screen.dart` `_spawnBoss`: spawned bosses via `enemyForStage(stageIdx, prestigeLevel: t)` — which applies the full campaign continuous tier curve (`kHpGrowth^t ≈ 3.4^t`) AND the boss-only frontier HP ramp (build 287) — and THEN multiplied again by the mode's own `tierHpMult = 1 + 0.85·t`. Triple-scaling (added by the 284 tier-unification, contradicting the mode's own "tierHpMult is the tier axis" design).
- Fix: spawn from the UNSCALED base (`prestigeLevel: 0`); tier HP/ATK scaling stays on `tierHpMult`/`tierAtkMult`; `resistanceTier: t` retained so hero resist/penetration still matters. Cuts high-tier boss HP by orders of magnitude back into a sane range.
- Watch next pull: Boss Rush runs should drop from hundreds of rounds to a normal length; if it now over-corrects (too easy), bump `tierHpMult`.
- NOTE (not fixed, lower priority): Dungeon is mildly too EASY at high tiers (a L122 hero cleared T4–T7 dungeons at 88–100% HP) — candidate for a small difficulty bump later.

## +294 — Attribute breakdown on the Bonus sheet + display fixes
User: "check if anything else is out of line/not displaying in the hero sheet; add it to the bonus sheet and show the detail (baseline vs item)."
- `hero_stats_screen.dart` (the "ALL BONUSES" sheet): added an ATTRIBUTE BREAKDOWN section — one expandable row per STR/DEX/CON/INT/WIS/CHA showing Base + Gear + Set bonuses + Gems → Effective total, plus a "Grants" line (element damage % + secondary effect), all computed off the same effective values combat uses.
- Fixed `_damageTypeRows` to use `game.attrDamagePctFor` (effective, gear-included) instead of base-only `hero.damagePctFor`.
- Removed the stale `_survivalRows` "Vitality (VIT)" row (old naming, single-stat) — superseded by the full ATTRIBUTE BREAKDOWN. Removed a now-unused subclass import.
- Audited the Hero sheet (dashboard) + attribute card dialog: they already show effective totals/effects (from +291) and correctly hide the upgrade CTA in read-only mode — no other stale attribute displays found.

## +293 — Rename gold-bought Ability Scores to functional names
User: "sort it all out and align it" — after unifying attributes to STR/DEX/CON/INT/WIS/CHA (+292), the gold-bought Ability Scores still used attribute-ish names (Power/Wrath/Vitality/Endurance/Fortitude/Durability, labels PWR/WRA/VIT/END/FOR/DUR) — notably VIT/FOR were the OLD attribute item codes, keeping the two systems confusable.
- `ability_scores_screen.dart` `_stats`: renamed to three clear flat/% pairs — Attack (ATK), Might (MGT), Health (HP), Vigor (VIG), Armor (ARM), Ward (WRD). Save KEYS (pwr/prc/vit/agi/for_/lck) and all effects unchanged — only display label + name.
- `game_state.dart`: updated the two stale name comments (Wrath→Might, Durability→Ward, Endurance→Vigor).
- Net result of the naming pass (+292/+293): character attributes are STR/DEX/CON/INT/WIS/CHA everywhere (Hero Sheet, items, forge, inventory, home, char-create); the gold upgrade system reads as functional Attack/Might/Health/Vigor/Armor/Ward. No remaining label collisions. (Artifact 'PWR' power and the Endless-tree BRT/PRC/… are unrelated systems, untouched.)

## +292 — Unify attribute labels to D&D names (STR/DEX/CON/INT/WIS/CHA)
User: "where can we see FOC and FOR from items?" — items labeled the 6 attributes PWR/AGI/VIT/ARC/FOC/FOR while the Hero Sheet used STR/DEX/CON/INT/WIS/CHA, so an item's +FOC couldn't be matched to the sheet's WIS. Chose: items (and everywhere else) adopt the D&D names.
- `equipment.dart`: `ItemStat.shortLabel` PWR/AGI/VIT/ARC/FOC/FOR → STR/DEX/CON/INT/WIS/CHA; `fullLabel` → plain "Strength/Dexterity/…".
- `inventory_screen.dart` (both label switches), `forge_screen.dart`: item-stat labels → D&D names.
- `home_screen.dart`, `character_creation_screen.dart`: hero-attribute display labels → D&D names (incl. the `_isPrimary` label→ability map keys, so primary-stat highlighting still works).
- LEFT AS-IS (separate systems, distinct identities): gold-bought Ability Scores (`ability_scores_screen` PWR/AGI/VIT/PRC/FOR/LCK), artifact power ('PWR'), and the Endless-upgrade tree (`EndlessNode` BRT/PRC/TGH/PRO/INS/FOC).

## +291 — Attributes fully honor gear (display + damage-% gap)
User: "ability Scores in the Hero Sheet look static — do they get increased from items?" Investigation: combat ALREADY scaled resistance/dodge/DoT/HoT/CD-skip/flat-hit/armor off effective attributes (base + gear + sets + gems), but (a) the Hero Sheet displayed BASE only, and (b) attribute damage-% used base only. Chose to make gear fully raise attributes.
- `game_state.dart`: added `effectiveAttr(base, stat)` = base + `inventory.totalOf` + `_setTotal` + `_gemTotal` (the same total combat uses). New `attrDamagePctFor(type)` uses it; replaced base-only `hero.damagePctFor` in the three damage aggregators (`heroAllDamagePctFor`, the DPS estimate, and the per-hit calc) + the ZPWR telemetry. Closes the one gap so an item's +STR now also boosts damage %.
- `stats_grid_panel.dart`: Hero Sheet cards now show the EFFECTIVE attribute (`game.effectiveAttr`) as the number, and `_currentEffect` tooltips compute off the effective attribute + effective damage %, so the sheet matches combat. Added `dmgPct` to `_StatCard`.
- Net: small, intended player buff (gear attributes now count toward damage %, previously base-only), and the sheet stops looking static — equipping +STR/+DEX gear visibly moves the numbers and their effects.

## +290 — Ability Scores: cap 250 + quadratic gold curve
User: "give Scores a max of 250 rank but have the gold curve spend much more increased… maxing out at level 500." Chose quadratic.
- `game_state.dart`: `kAbilityScoreMaxRank` 100 → 250. `abilityScoreUpgradeCost` linear `(rank+1)×150` → quadratic `(rank+1)²×100` (`kAbilityScoreCostCoeff`). rank 1 = 100g · rank 100 ≈ 1.0M (was 15K) · rank 250 ≈ 6.25M; full 0→250 climb ≈ 524M per score (~3.1B all six).
- UI (`ability_scores_screen.dart`) needs no change — cap is read from `kAbilityScoreMaxRank` and tier labels are computed strings (no fixed array), so 250 ranks render fine.
- Coefficient (100) is the tuning knob; calibrate against real gold income from telemetry so max lands near hero L500. Existing rank-100 investments carry over and continue from 100 at the new (steeper) costs.

## +289 — Save hardening: high-water-mark backup + auto-recovery
User: a maxed L377 Warden reset to level 1; the 1-deep rolling `_bak` was overwritten by ~8 autosaves and the cloud got a level-1 sync, making it unrecoverable. Chose save-hardening first (isolated build), then rebuild a comparable fighter.
- `save_service.dart`: `saveRaw` now also maintains a `_hwm` (high-water-mark) backup per slot — the HIGHEST hero level ever held — and NEVER lowers it. Added `loadHighWaterMark`, `clearHighWaterMark`, and `_levelOf`. `deleteSlot` clears `_hwm` too.
- `game_state.dart` `loadSlot`: after local+cloud load, if the banked `_hwm` level exceeds the loaded level by >10 (hero level only rises in normal play, so a big drop = a wipe), auto-restore the maxed copy and re-establish it as primary. New characters clear the HWM first so a deliberate fresh hero isn't "recovered". Added `characterRecoveredFromBackup` flag for a UI notice.
- Also retains the build-288 `ZLOADFAIL|` logcat print in the parse-failure catch for future diagnosis.
- NOTE: the Warden that was already lost predates this backup, so it can't retroactively restore — this prevents recurrence (protects the intact slot_4 Lv7924 bard and all future characters). A comparable fighter is being rebuilt into cloud slot_0 separately.

## +287 — Frontier ramp v2: boss-scoped + eased slope
User: "check the latest logs." Build-286 telemetry (fresh T5 run, hero L323→377): the ramp NAILED mid-tier bosses (Shadow King @T5 st35: 1→6 rounds, ended 44%; Glacier Wyrm/Leviathan ~9 rounds) but OVERSHOT the deep end — st56-64 TRASH ran 15-27 rounds and st55/60/65 bosses hit 44-54 rounds with 3 losses (flat tier-wide multiplier over-amplified the already-steep deep stages and wrongly inflated trash).
- `enemy_data.dart`: reverted `endgameTierHpMult` to the base `pow(1.48,tier)` (applies to all enemies as before). Added `frontierBossHpMult(tier)` = `(1 + 2·(tier−3)).clamp(1,11)` (T4 ×3 · T5 ×5 · T7 ×9 · T10 ×11), applied ONLY to bosses via `bossHpMult` in the campaign branch.
- Net effect vs 286: trash loses the frontier factor entirely (fast again); frontier BOSS HP eased ~×7→×5 at T5 (deep bosses ~44→~30 rounds — still the intended wall, not a 50-round slog); mid-tier bosses stay a real fight. Tiers 0-3 unchanged (over==0 → ×1). Still HP-only, rewards key off level → no inflation.
- Watch next pull: T5 st35-50 bosses should hold ~4-6 rounds; st55+ remains the soft ceiling; trash back to 1-4 rounds.

## +286 — Frontier boss HP ramp (tiers 4+)
User: telemetry review — "do number 2" (top-tier flattening). Power-normalized boss data showed T4 bosses dying in a median of 1 ROUND with enemy hits at only ~4.7% of the hero's HP pool (least threatening tier despite being hardest); T1–T3 are healthy ~5-round fights. Confirms the near-maxed hero trivializes the frontier (matches the code's own "maxed hero one-rounds tier-10 boss" history). Chose the Aggressive ramp.
- `enemy_data.dart` `endgameTierHpMult`: on top of the base `pow(1.48,tier)`, tiers 4+ get a steep saturating extra HP factor `(1 + 3·(tier−3)).clamp(1,15)` → T4 ×4 · T5 ×7 · T6 ×10 · T10 ×15 (capped). Tiers 0–3 untouched.
- HP-only (no ATK bump — per the saved balance direction: HP-up + recovery-down, never %-max-HP). Rewards key off enemy LEVEL not HP, so no gold/XP/loot inflation.
- Applies through the shared campaign scaling path, so frontier bosses in Dungeon/Boss Rush (which reuse campaign stage indices) get tankier too.
- Calibration step: slope 3.0 / cap 15 to be re-tuned from the next telemetry pull (watch T4/T5 boss round-counts and end-HP%).

## +285 — Per-tier campaign progress (unlock only resets the new tier)
User: "Can we make it so that the campaign only resets for the new unlocked tier?" (chose: auto-jump into the new tier, but keep the cleared tier's progress).
- `game_state.dart`: new `Map<int,int> _campaignStageByTier` — each 0-based tier remembers its own campaign stage; the active tier's live value stays in `campaignStageIndex`.
- `setActiveTier`: stashes the tier you leave and resumes the target tier's saved stage (or `prestigeHeadStart` if never played), so switching tiers no longer restarts the campaign.
- Final-boss handler: on unlocking the next tier, parks the cleared tier at the Omega (final stage) and starts ONLY the new tier at the head-start; replaying an already-maxed tier still loops that tier back to farm.
- Persistence: `campaignStageByTier` saved (string keys, active tier merged in) and loaded with clamping; older saves seed an empty map (current tier still resumes via `campaignStageIndex`). Map cleared on new-character/prestige reset.

## +284 — Unified GLOBAL difficulty tier (all modes)
User: "the whole game switches in difficulty — tower ascension, dungeon, boss rush, campaign — you get all the bonuses from it and it should increase the hp & damage of all monsters." + "yes do all your steps" (finish the plumbing).
- Every mode now reads the single global `activeTier` (0-based) instead of a private `_selectedTier`. Setting the tier anywhere (any mode's selector or the campaign header) applies everywhere, and all tier bonuses carry across modes.
- `boss_rush_screen.dart`: `_selectedTier` is now a getter returning `game.activeTier`; bosses scale HP/ATK by the tier (`enemyForStage(prestigeLevel: tier)`) AND resistance by the tier; rewards/artifacts use `tierRewardMult(tier)`. Removed the dead `_rebirthLvl` field and the orphaned `_TierButton` widget. Selector uses `highestUnlockedTier` + `setActiveTier`.
- `gauntlet_screen.dart`: same getter conversion; enemy HP/ATK scale via the 0-based `_gauntletTierHpMult/AtkMult` (tier 0 = ×1), resistance by the global tier; reward + preview both use `tierRewardMult(tier)`. Removed `_rebirthLvl`.
- `endless_screen.dart` (Tower Ascension): `_bossTier` now returns the global tier; the boss preview mirrors the real spawn scaling (`2× HP, 1.25× ATK, +AC`, quadratic tier), and the daily-clear key + Tower-Shard reward scale with the tier so re-clears at higher tiers pay more.
- `tier_selector.dart`: converted to 0-based (tier 0 = base difficulty; `maxTiers = 11`), driven by `highestUnlockedTier`.
- `dungeon.dart` / `dungeon_screen.dart`: tier scaling routed through `prestigeLevel: tier` (dropped the separate `_tierMult`); the campaign tier selector now appears in the dungeon lobby, defaulting to the global tier.
- Per-mode `bossRushHighestTier` / `gauntletHighestTier` / `_dungeonHighestTier` now only mark per-mode "CLEARED" badges; tier UNLOCKING is solely `highestUnlockedTier` (raised by clearing the campaign).

## +283 — Unified accelerating tier-reward curve (alt-modes)
User: re-map alt-mode rewards for the unified tier; higher tiers should be more rewarding; rebirths are retired.
- `game_state.dart`: new `tierRewardMult([tier])` — ONE accelerating curve for every mode, `1 + t*0.5 + t²*0.1` (0-based tier: 0→1×, 5≈6×, 10=16×). Rewards scale with the tier you play; no separate max-tier "rebirth" bonus.
- `gauntlet_screen.dart`: replaced the old `tierMult × rebirthMult` double-scaling on score/essence/echoes/ZCoins with `game.tierRewardMult(_selectedTier - 1)`.
- `boss_rush_screen.dart`: replaced the `rebirthMult` (highestUnlockedTier-based) on shards/echoes with `game.tierRewardMult(_selectedTier - 1)` — rewards now scale with the tier you PLAY, not your max.
- `dungeon.dart`: added `_rewardMult` (same curve, tier 1-based) and applied it to combat gold + shards (were floor-only) — higher dungeon tiers finally pay more.
- Note: `_selectedTier - 1` / `tier - 1` are the 1-based→0-based conversions; these simplify to `activeTier` once the tier plumbing is unified (next stage). Boss Rush artifact level + tier-clear tracking still use the per-mode tier for now.

## +282 — Dungeon start guard (no wasted attempts)
User: "went into the dungeon and it went straight out and wasted my attempt."
- Telemetry showed the recent dungeon activity was 3 rapid T1 clears ~1min apart — the Auto-Run feature auto-entering/clearing. Separately found the real hazard: `startDungeon` had no guard against an already-active run, so a double-call (double-tap or Auto-Run racing a manual entry) consumed an attempt and overwrote the in-progress run WITHOUT finishing it (no telemetry, wasted attempt).
- `game_state.dart` `startDungeon`: now early-returns if `activeDungeon != null && !activeDungeon.isOver` — never discards an in-progress run to start another.
- Next up (approved): unified global difficulty tier replacing per-mode tiers (dungeon/boss rush/gauntlet/tower all follow the campaign tier; monsters scale HP/damage; all tier bonuses apply). Staged rework.

## +281 — Even gear stat pools + attributes reference-only
User: stats shouldn't be directly upgradable (only items/other means); review + rebalance item generation.
- **Attributes non-upgradable:** `stats_grid_panel.dart` — gated the tap-for-info dialog's "+UPGRADE" CTA behind `!readOnly` (the card button was already gated). The `str_1`…`cha_1` gold-upgrades are wired ONLY to this panel, which is now used read-only everywhere, so attributes come solely from gear/subclass/traits/base.
- **Item-gen review finding:** the 6 attribute stats (each → a damage type + resistance) were unevenly gearable — CON/DEX/WIS on 4 slots, but INT/CHA on 2 and STR on 1. Fire/Void builds were starved.
- **Rebalanced `_statsFor` pools** (`equipment.dart`) to ~3–4 slots each: STR (weapon/armor/gloves/relic=4), DEX (gloves/pants/boots/accessory=4), CON (offHand/armor/pants=3), INT (offHand/boots/accessory/relic=4), WIS (helmet/boots/accessory/relic=4), CHA (helmet/pants/accessory/relic=4). Core slot stats (armorClass, attack/damage on weapon/gloves, healRating/maxHpPct) preserved.
- Noted separately (not changed): flat stats clamp at 999 + linear +8%/level scaling → negligible vs the exponential HP/damage curve at endgame. Left for a future scaling decision.

## +280 — Attributes visible + explained, STR reworked, Ultimate coach
User: keep STR/CON but SHOW the stats (hero + bonus sheet) and what they do; reuse STR (chose universal weapon power); add an Ultimate tutorial on questline completion.
- **STR rework (`hero_model.dart`):** Physical is retired, so base STR was dead. `damageMod` now `level~/2 + strength` and `armorClass` now `2 + strength` — STR is the universal weapon-power stat: +1 flat hit damage (any element) + +1 armor per point. Single-point change flows to combat, PvP snapshot, and the bonus sheet (all derive from baseDmg/armorClass). Elemental %/resist mappings unchanged.
- **Stats now visible:** `StatsGridPanel` (the STR/DEX/CON/INT/WIS/CHA grid) was dead code — surfaced it read-only on the Hero dashboard (`dashboard_screen`) and Bonuses sheet (`hero_stats_screen`). Added a `readOnly` mode (stat + tap-for-info, no gold-upgrade button) to avoid the legacy str_1 upgrade UI.
- **Descriptions enriched:** the stat info dialog now lists each stat's FULL kit — damage-type %, resistance, AND its signature secondary (DEX→Dodge, CON→Max HP/regen, INT→DoT, WIS→heal-over-time, CHA→cooldown-skip). STR shows its new flat-damage + armor. Live values in the effect box.
- **Ultimate coach (`game_state.dart`):** completing the class questline (5 quests → `classUltimateUnlocked`) now fires a one-time coach (Hero→Abilities) explaining the Ultimate. Persisted `_ultimateUnlockedTutorialSeen`; defaults true for saves that already have it.
- Tier-clear question (user): confirmed NOT a bug — the stage-100 final boss (Zeta Absolute) was cleared each tier per telemetry; auto-campaign clears the final stretch and the campaign loops to stage 1, which reads as "never reached 100."

## +279 — Energy: level-scaled cap + overflow purchases
User: buying 20 energy at 5/20 should grant the full 20 (overflow past cap); free refill/regen still cap. Then: make max energy grow +1 per level up to 60.
- `game_state.dart`: `buyEnergy()` now `energy += energyPurchaseAmount(20)` (overflow allowed) instead of `energy = maxEnergy` — matches the UI's "buy +20 energy" copy, which was a lie before (it filled to cap, wasting the difference). `useEnergyRefill()` and `tickEnergy()` still cap at maxEnergy.
- **Level-scaled cap:** `maxEnergy` is now an instance getter `(kBaseEnergy 20 + hero.level - 1).clamp(20, kEnergyCap 60)` — 20 at L1, +1/level, hits 60 at L41. Converted from `static const`; call sites in `campaign_screen`/`battle_screen` moved from `GameState.maxEnergy` to `game.maxEnergy`. Field init + load default use `kBaseEnergy`.
- Level-up grants energy per level gained (`energy += levelsGained`, guarded so it never clamps over-cap purchased energy down).
- `campaign_screen.dart`: Buy button always visible (stock over the cap even when full); progress bar clamped to 1.0 for over-cap display; free-refill button + spacer gated to `energy < max`.
- Review note (not changed, user's call): energy also gates the offline/idle catch-up (`simulateCampaignBattles` spends 1/fight) — the main divergence from idle-genre norms where the away loop runs free. Level-scaling + overflow buys ease it; options A/C (free idle / replays-only) left for later.

## +278 — Eager anonymous sign-in (unblocks telemetry for testers)
User: telemetry wasn't landing for plain campaign/boss-rush sessions.
- Root cause: anonymous auth was **lazy** — only triggered when opening Guild/PvP/cloud save (`game_state`/`guild_screen`/`pvp_screen`). A fresh install that only fought campaign had `currentUser == null`, so the Firestore telemetry write (rule requires `signedIn()`) was denied and silently swallowed.
- `main.dart`: after Firebase init, eagerly `signInAnonymously()` (fire-and-forget) if `currentUser == null`. Benefits cloud save/leaderboards too — they're ready from boot instead of on first cloud interaction.
- Verified end-to-end via a `--dart-define=ZETA_TELEMETRY=1` diagnostic build: 58 fights landed in Firestore and were pulled/analyzed with `tool/pull_telemetry.ps1`.
- Added `tool/pull_telemetry.ps1` (gcloud-auth → Firestore REST → flattened JSON dump) and gitignored the transient `telemetry_dump.json`.

## +277 — Fight telemetry → Firestore (runtime-gated)
User: get the alt-mode/campaign telemetry off-device into Firebase, and enable it for the closed test.
- New `services/telemetry_service.dart`: writes each fight's JSON (same fields as the `ZBAL` logcat lines) as a doc in a Firestore `telemetry` collection, with a server `ts` and a per-run `session` id. Structured so the console can filter/sort by mode/tier/win/min-HP/etc.
- Hooked at the single `DebugLogger.sink` point in `main.dart` (category `BALANCE`), so it covers campaign + Gauntlet + Boss Rush + Guild + Dungeon with no per-call-site changes. Sets `sessionId` at startup.
- **Two gates, both default OFF** so production never writes uninvited: compile flag `--dart-define=ZETA_TELEMETRY=1` (dev), OR Remote Config `telemetry_enabled` (flip on for the closed test). `telemetry_sample_pct` dials volume on the RC path.
- `remote_config_service.dart`: added `telemetry_enabled` (false) + `telemetry_sample_pct` (100) defaults, a `_b` bool reader, and the two getters.
- `firestore.rules`: added a `telemetry` collection rule — create-only + field-count cap, no client read/update/delete (reads via console, which bypasses rules).
- To use in closed testing: upload this build, publish the rule, set `telemetry_enabled=true` in Remote Config; set it back false (or sample down) for production.

## +276 — Guild boss fight polish (button + log)
User: the Return-to-Guild button was stuck behind the system nav bar; also the Guild fight shouldn't show an on-screen battle log — match Campaign/other modes.
- `guild_screen.dart`: wrapped the `!_fighting` result panel (BOSS DEFEATED / FALLEN + RETURN TO GUILD) in `SafeArea(top: false)` so the button clears the Android navigation bar. The in-fight icon bar already used this; the result panel was the one place missing it.
- Removed the `BattleLogBox(log: _log, height: 108)` from the Guild fight view — Guild was the only mode rendering a persistent log box; Campaign/Gauntlet/Boss Rush/Dungeon show only the arena + floating numbers. `_log` is still collected for the fight summary.
- Surfaced by the pre-release Guild smoke test (which also confirmed alt-mode ZBAL telemetry emits correctly: `mode":"guild"` line captured — win, 1 round, 175M dmg vs 820K boss).

## +275 — Dungeon tier-clear banner fix + alt-mode telemetry
User: dungeon showed "tier unlocked" despite not completing the run; add telemetry to the alt-modes; confirm campaign already logs tier.
- **Dungeon banner bug:** `dungeon_screen.dart` `_DungeonSummary` computed `tierCleared = run.bossesDefeated >= 1`, so killing one mini-boss then dying still showed "✓ Tier N cleared — AUTO unlocked". Changed to `tierCleared = run.isCleared` (Dungeon Lord defeated) and `autoUnlocked = run.tier <= dungeonHighestTier || run.isCleared`. This matches the REAL tier unlock in `_finishDungeon` (line ~7226), which already required `run.isCleared` — only the banner was lying.
- **Alt-mode telemetry:** new `ModeCombat.logBalance(Map)` → `DebugLogger.balance(jsonEncode(...))` (same `ZBAL|` prefix as campaign). Wired into `gauntlet`/`boss_rush`/`guild` `_endRun` paths (added `_minHp`/`_totalTaken` tracking for `h_hp_min_pct`/`h_dmg_taken`), and `dungeon` emits run-level stats from `game_state._finishDungeon` (floor/rooms/bosses/tier/end-HP; direct `DebugLogger` call to avoid a circular import).
- Campaign already logs `tier` (`activeTier`) in every ZBAL line — no change needed.

## +274 — Combat polish (DoT-over-time, resistance, crit fix) + tutorials
User: do the rest of the audit items.
- **#2 Gauntlet attackBonus double-dip:** `gauntlet_screen.dart` crit chance no longer adds `_tempAtkBonus * 2` — the attack buff is a pure % damage boost, matching campaign + other modes.
- **#4 Ability damage ignored resistance:** `ModeCombat.applyAbility` now takes `enemyResistPct` and applies it to ability/DoT damage in `_scaledDirect`/`_scaledDot`. Gauntlet passes `_currentEnemy` resist, Boss Rush passes `_bossResistances`, Guild passes 0 (untyped bosses).
- **#3 DoT now ticks over time:** `ModeStatus` gained `dotPerRound`/`dotRounds` + `tickDot()`/`addDot()` (poison stacks up to 5×, capped). `ModeCombat` dot/burning/envenomed + their riders now *schedule* a DoT instead of one instant hit; each of Gauntlet/Boss Rush/Guild ticks it once per round. Dungeon keeps its instant DoT (bespoke roguelike model, unchanged).
- **Tutorials:** `system_tutorials.dart` adds three coaches at unused campaign stages — Damage Types (@3 → Hero/SCORES), Status Ailments (@14 → Hero/ABILITIES), Guilds (@33 → Hero). They fire via the existing `forStage` path (no `_unlockStageNames` change, so no enemy-scaling side effects).

## +273 — Milestone riders fire in the alt-modes
User: audit item — the rank-5/10/15 milestone rider effects were ignored outside the campaign; fix that next.
- `game_state.dart`: added `activeMilestoneRider(HeroAbility)` → `(effect, value, duration)` record (last chosen rider wins, mirrors `_fireAbility`). Value deltas already flowed through `scaledAbilityValue`; only the `bonusEffect` rider was being dropped.
- `mode_combat.dart`: `applyAbility` now resolves the rider after the primary effect via new `_applyRider` (handles damage/CC/vuln/weaken/buff/heal/barrier/dodge; CC riders share the same `CcTracker` DR pool). Covers Gauntlet, Boss Rush, Guild automatically.
- `dungeon_screen.dart`: added an inline rider block using the Dungeon's own conventions (permanent additive buffs, per-round dodge, `_heroBarrier`); vuln/weaken/miss riders are no-ops there since those aren't modelled for primaries either — consistent.
- Net effect: milestone choices that grant a secondary effect (e.g. Vexing Verse's "+stun", elemental "+DoT", "+vulnerable") now work in all five modes instead of just the campaign.

## +272 — Shared combat resolver (structural fix #2)
User: after the targeted fix, do the structural refactor to kill combat drift permanently.
- New `lib/models/mode_combat.dart`: `ModeStatus` (per-fight buff/debuff/CC-DR/barrier holder) + `ModeCombat.applyAbility` — one callback-based resolver for all alternate-mode ability effects, mirroring the campaign's `_fireAbility`. Also `ModeCombat.thornsReflect` and `lifestealAfterHit`.
- `game_state.dart`: exposed `heroThornsPct` getter (Thorn Wall = 30%).
- Migrated `gauntlet_screen.dart`, `boss_rush_screen.dart`, `guild_screen.dart` to `ModeStatus` + `ModeCombat.applyAbility` (their old status fields are now proxies onto `ModeStatus`, so the per-mode attack maths is untouched). Deleted ~240 lines of duplicated ability-switch code. Added the absorbShield barrier + thorns reflect to each mode's enemy-attack path.
- `dungeon_screen.dart`: kept its bespoke roguelike model (permanent additive buffs, per-round dodge, relic multipliers) but closed the two correctness gaps — absorbShield is now a real `_heroBarrier` (was a flat heal) and thorns reflect on incoming hits.
- Offline sims: `pvp.dart` (`_SimState.ccDr`) and `dungeon.dart` (local `cc`) now route stun/silence/frozen/shocked through the shared `CcTracker` diminishing returns + tick it each round — closes the PvP `stunRem += dur` perma-CC hole.
- Behavioural changes to note: absorbShield is now a barrier (can be overkilled) rather than free HP in the alt-modes; thorns builds now work outside the campaign.

## +271 — Alt-mode combat alignment (targeted fix #1)
User: audit found combat-mechanic drift between campaign and alt-modes; do the targeted correctness fix first, then the structural refactor.
- `game_state.dart`: exposed `heroLifestealPct` getter + `lifestealHealPerHit()` (Heal-Rating based, mirrors the campaign heroAttack formula) so every mode leeches identically.
- `gauntlet_screen.dart`, `boss_rush_screen.dart`, `guild_screen.dart`, `dungeon_screen.dart`: ability `heal` → `game.healFor(sv)` and `aura` → `game.healFor(sv, factor: 0.5)` (were using raw `sv` as HP — heal builds restored ~1/25th of intended after the heal-rating rework). Dungeon preserves its relic `_healMult`.
- Added lifesteal to the hero auto-attack in all four modes (was campaign-only, so lifesteal builds were dead weight outside the campaign).
- `ability_data.dart`: reworded attackBonus milestone descriptions — "+N more ATK" / "much greater attack bonus" → "+N% more DMG" (the effect was always a % damage buff; the label was wrong). Left the debuffWeaken "+N% more ATK reduction" lines untouched (those are correct).
- Deferred to #2 (shared resolver refactor): absorbShield-as-barrier, thorns, DoT-over-time ticking, and CC diminishing-returns in the offline dungeon/pvp sims.

## +270 — More elemental ailments: Burning, Envenomed & Withered
User: add the remaining damage-type ailments (Fire/Poison/Void), skip Physical (not a chosen damage type).
- `hero_ability.dart`: added `AbilityEffect.burning` (Fire DoT), `envenomed` (stacking Poison DoT), `withered` (Void soft −ATK).
- `game_state.dart` `_fireAbility` (primary + bonus switches): burning → `_dotDmg = max(.., tick)`; envenomed → `_dotDmg = (_dotDmg + tick).clamp(1, tick*5)` (stacks up to ~5×); withered → `_enemyWeakenPct = max(.., sv.clamp(0,60))` (no DR, not CC). DoT tick now clears `_dotDmg` when it expires so poison stacks restart fresh each window.
- Reuses existing DoT / enemy-weaken channels — no new tick machinery or reset points.
- `ability_data.dart`: fire-DoT milestones → Burning, poison-DoT → Envenomed, void-weaken → Withered (bulk + individual; two void milestones that promised a weaken but only changed type now actually apply Withered). Descriptions updated (IGNITES / ENVENOMS / WITHERS).
- Wired through all alt-modes (gauntlet, guild, boss rush, dungeon), `dungeon.dart`/`pvp.dart` sims (pvp poison stacks additively), and all display maps (upgrade screen, armory, inventory, unique items, battle arena colors, split panel). Burning/Envenomed count as damage effects for ability-damage/penetration tooltips.

## +269 — Elemental crowd control: Frozen & Shocked
User: add abilities that act like stun/silence/disarm tied to damage types — Frost = Frozen, Lightning = Shocked; all diminishing-returns like stun.
- `hero_ability.dart`: added `AbilityEffect.frozen` (Cold) and `AbilityEffect.shocked` (Lightning).
- `game_state.dart` `_fireAbility` (primary + bonus-effect switches): `frozen` → enemy skips its turn (`_hardCcDuration` shared stun DR); `shocked` → skips turn AND `_enemyVulnerablePct = max(.., 25)` for the duration (+25% damage taken).
- `ability_data.dart`: every cold-stun milestone across all classes now applies Frozen, every lightning-stun milestone applies Shocked (bulk-converted; descriptions updated to say "FREEZES"/"SHOCKS it 1r"). Barbarian/Druid thematic milestones converted earlier this pass.
- Wired through all alt-modes (gauntlet, guild, boss rush, dungeon) via `CcTracker`, plus `dungeon.dart`/`pvp.dart` sims and all display maps (battle arena/panel, armory, inventory, unique items, upgrade screen).
- All hard CC (stun/disarm/silence/frozen/shocked) shares one diminishing-returns pool (`1.0 → 0.5 → immune`, resets after 5 CC-free rounds) — no perma-lock.

## +268 — Cooldown/duration buffs made special & rare
User: cooldown & duration buffs should feel special, not used a lot; remove duration from Ascension (Ascension = power only).
- `game_state.dart` `_fireAbility`: removed `ascDurBonus` — Ascension no longer extends duration (value-less utility abilities gain nothing from ascension; damage/heal still scale via `ascMult`).
- `scaledAbilityCooldown`: removed `rankCdReduce` (abilities no longer auto-shorten every 6 ranks — that made low cooldowns automatic). Total build cooldown reduction (passive + subclass + trait + unique) now clamped to `kMaxCooldownReduction = 2` — CDR is a premium, limited bonus, no ability spam. Heal/aura surcharges retained (they enforce downtime).

## +267 — Duration < cooldown (enforced at cast)
User: a duration should never meet/exceed the cooldown (else ≥100% uptime). Since duration-extending milestones STACK (you can pick durationDelta at multiple milestones) plus ascension adds duration, no static data audit can guarantee it — so enforce it at cast time.
- `game_state.dart` `_fireAbility`: after computing `effectiveDuration = ability.duration + durationDeltaSum + uniqueDurAdd + ascDurBonus`, clamp `if (effectiveDuration >= cd) effectiveDuration = cd - 1` (cd = `scaledAbilityCooldown(ability)`; instant/0-duration effects untouched). Covers every timed effect (buffs, weaken, miss, vuln, aura, DoT, stun/silence base) uniformly.
- `ability_data.dart`: also tamed the two most absurd nominal values — Druid "Endless Tangle" and Ranger "Endless Cripple" ("to 8r", durationDelta 4 → 2) with copy that no longer overstates. Other "to Nr" milestone descriptions are nominal; the cast-time clamp is the source of truth (and stacking makes per-choice text inherently approximate).

## +266 — Milestone note shows the EXACT scaled number (not %)
User wanted the concrete number, not a percentage. Now computes the real change at the current rank/tier/gear.
- `game_state.dart`: `scaledAbilityValueForBase(ability, baseValue)` — the scaled value the ability would have with a given base (mirrors `scaledAbilityValueAtRank` but with a custom base).
- `ability_upgrade_screen.dart` `_milestoneEffectNote(choice, ability, game)`: for magnitude effects (bonusDamage/dot/heal/aura) shows the exact scaled delta — `withBase(value+valueDelta) − current` — as "+N damage", "+N damage/round", "+N HP" (via `healFor`), "+N HP/round"; for percentage effects (attack/armor/weaken/miss/vuln) shows "+N% X (to M%)". Threaded the full `HeroAbility` (not just value/effect) through `_MilestoneRow`.
- Exact because damage scaling is linear in base value; heal uses the same `healFor` the ability display uses, so numbers match.

## +265 — Milestone choices show computed exact numbers
User: "greatly/massively increases" is vague — give numbers. Since `valueDelta` scales a magnitude ability's output by exactly `valueDelta/baseValue` (rank/tier independent), the effect can be shown precisely.
- `ability_upgrade_screen.dart`: new `_milestoneEffectNote(choice, baseValue, baseEffect)` — magnitude effects (bonusDamage/dot/heal/aura) → "+X% damage/healing"; percentage effects (attackBonus/acBonus/debuffWeaken/missChance/debuffVulnerable) → "+N% (to M%)". Threaded `ability.value`/`ability.effect` through `_MilestoneRow` → `_ChoiceOption`/`_ChosenBadge`; note rendered under the description in the effect color. Barriers/element-only choices (no valueDelta) show no note (their text already states HP / the element).

## +264 — Finish milestone rebalance (all 252, every class)
Completed the two softer categories left after +263 (which never shipped — device offline):
- Small buff riders bumped to meaningful values: all "+3 AC / +3 ATK for 2–3r" heal/buff riders → +12% (Cleric, Druid, Fighter, Monk, Paladin); Monk Iron Skin "+2 AC" → +15; Barbarian War Shout/Primal Howl "+2 ATK/+2 AC" → +12%; Paladin Sacred Aura "+4 AC" → +12%.
- Damage+control combos split: every DoT "+N/r **and** stun" M15 (Barbarian ×2, Cleric, Druid ×2, Ranger) → **pure stun** (control), leaving the paired option as the big-DoT (damage) pick.
- Element-choice milestones (type-swap + minor pen/val rider) intentionally left — the element is the real decision (matched to enemy resistances).
Combined with +263's bulk fixes (pure "+4/+5 damage" → 12/15, "+5% weaken" → 15, "+3 ATK" → 10). Net: no milestone is a no-brainer; each is Burst / Control / Amplify / Sustain vs a comparable alternative.

## +263 — Roll milestone rebalance to all 12 classes
Applied the +262 Bard principle across every class via bulk replaces of the identical weak templated options in `ability_data.dart`:
- Pure damage "+5 more max damage" (valueDelta 5→15) and "+4 more max damage" (4→12) → substantial bursts (both with generic "far greater bonus damage" copy). ~12 occurrences.
- Weaken "+5% more ATK reduction" (5→15) → real debuff spike vs the stun alternative.
- Buff "+3 more ATK bonus" (3→10) → meaningful attack buff.
- Bard's per-ability fixes (262) retained.
- Remaining softer cases NOT yet touched (varied descriptions, need per-ability edits): small heal-buff riders (+3 AC/ATK for 2–3r) and DoT "+N/r **and** stun" combos (the damage+control trap). Flagged for a follow-up pass.

## +262 — Rebalance milestone choices (Bard = template for all classes)
User: milestone picks are obvious (e.g. Vexing Verse "+4/+6 damage" vs a stun / 15% vuln). 252 milestones total; establishing the principle on the Bard first, then rolling to the other 8 classes.
Principle: each milestone = two comparable archetypes — Burst (damage ≈ +100% of ability base) / Control (stun/weaken/miss) / Amplify (vuln/pen) / Sustain (heal/duration); no side may give damage AND control while the other gives only one.
- `ability_data.dart` Bard: Vexing Verse M10 valueDelta 4→10, M15 6→14 (+ vuln 15%/2r→20%/3r); Discordant Blast M10 5→16, M15 removed the "+8 dmg **and** stun" combo → pure 22 burst (vs the 35%/4r DoT); Taunt M10 weaken +5%→+15%; Dissonant Chord M15 "weaken+stun" → clean stun vs a bigger self-buff (+6 ATK/3r); Cacophony M10 "+1 dur" → miss 45% + longer (vs 20% vuln). Element-pick and buff milestones left as-is (already real choices).
- Not yet touched: the other 8 classes' milestones — pending confirmation the approach is right.

## +261 — Paragon board: flat 1-point cost + remove Precision/Ferocity
- `prestige_shop.dart`: removed `p_precision` and `p_ferocity` ParagonStats (both damage). Orphaned ranks in saves are ignored (paragonTotal/paragonPointsSpent iterate kParagonStats).
- `paragonCost` now flat `1` (was `costBase * (rank+1)` escalating) — every board rank costs exactly 1 Paragon Point. `paragonPointsSpent` recomputed as total ranks (each = 1 point), so the perk gates (50/100/200/350/500) now mean "N ranks bought". `costBase` field retained but unused.
- debugMaxCharacter loop iterates kParagonStats (unaffected by the removals).

## +260 — Cap Ability Scores at rank 100 (was 1000)
Scores are potent per rank (agi +2% max HP, dur +0.5% AC, vit +30 flat HP, pwr +2 dmg, etc.) — at the old 1000 cap that was up to +2000% HP / +500% AC from one score. Also the finale is now genuinely climactic (build 258/259 logs: hero dropped to 18–46% HP, took 11–12M damage).
- `game_state.dart`: `kAbilityScoreMaxRank 1000 → 100`; `abilityScoreRank` now `.clamp(0, kAbilityScoreMaxRank)` so any legacy ranks bought above 100 are effectively limited (no need to migrate saves). `debugMaxCharacter` already set scores to 100, so maxed-char telemetry is unchanged.
- `ability_scores_screen.dart`: "Rank N / 1000" → "Rank N / {kAbilityScoreMaxRank}".

## +259 — Extend CC diminishing returns to all alt modes
Campaign + Endless already share game_state's `_hardCcDuration`; the alt-mode screens each had their own boolean `_enemyStunned`/`_enemyStunnedThisRound` (set true on stun/silence, reset each round → perma-stunnable, no DR). Also confirmed (from the 258 log) the boss now deals real damage: `h_dmg_taken 2.52M`, `h_hp_min_pct 81` — immortality broken.
- New `models/cc_tracker.dart` `CcTracker`: reusable DR (full→half→immune, resets after 5 CC-free rounds); `applyBool()` lands the first 2 applications then DR-immune, `tickRound()` advances the timer.
- Wired into `boss_rush_screen`, `dungeon_screen`, `gauntlet_screen`, `guild_screen`: field + reset on fight start + `tickRound()` per round + `_enemyStunned = _cc.applyBool()` at each stun/silence site (with a "resists (DR)" log). Weaken in these modes is a fixed partial (−30%), not full disarm, so it stays as-is.
- PvP (hero-vs-hero) left out — different balance context.

## +258 — Silence joins the shared CC diminishing returns
Audit (user asked what other mechanics need DR): enemy control effects are stun (DR ✓), disarm/weaken≥100% (DR ✓ +257), miss-chance (already capped 66% + folded into the consolidated avoidance roll — not full negation, no DR needed), and **silence** (fully blocks enemy abilities, `_enemySilenceRounds`, set with no DR at 4 sites → perma-silence could keep a boss's abilities disabled forever).
- `game_state.dart`: new `_applyEnemySilence(baseDur, label)` routes silence duration through the shared `_hardCcDuration` pool (stun+disarm+silence all draw one DR budget). All 4 `AbilityEffect.silence` set-sites go through it.
- No other qualifying mechanics: dodge-next-hit is handled by the +255 unstoppable backstop; miss-chance/partial-weaken aren't full negation. Boss-rush screen has its own simplified `_enemyStunned/_enemyWeakenRem` (separate alt-mode, not wired to campaign DR — left as-is).

## +257 — Unify hard-CC under one diminishing-returns pool (user request)
User: "stun has diminishing returns, so anything that reduces damage by 100% or stuns/freezes should follow the same logic." Refactored to a shared DR pool instead of +256's ad-hoc boss weaken cap.
- `game_state.dart`: extracted `_hardCcDuration(baseDur)` (the stun DR: full→half→immune, resets after 5 CC-free rounds; shared `_stunApplicationCount`/`_roundsSinceLastStun`). `_applyStun` now uses it. New `_applyEnemyWeaken(pct, dur, label)`: a full disarm (≥100%) routes its duration through `_hardCcDuration` (shares the pool with stun); partial weaken (<100%) is not CC and applies at full duration. All 4 `debuffWeaken` set-sites go through it; vulnerability overflow (>100%) preserved.
- Reverted +256's `min(_enemyWeakenPct,75)` boss cap — DR now governs disarm uptime for all enemies (chained stun→disarm→stun all draw the same pool). Kept the `!bossUnstoppable` weaken bypass and the +255 unstoppable-after-2-skips backstop.
- No "freeze" effect exists (stun is the freeze). Net: stun+disarm can no longer perma-lock; after 2 hard-CC applications the enemy is briefly CC-immune and attacks normally.

## +256 — Cap Disarm/Weaken vs bosses (the layer under perma-lock)
Build 255 log: still `h_dmg_taken ≈ 8`, and the unstoppable-boss logic never fired — because the boss wasn't being *skipped*, it was being **disarmed**. A `debuffWeaken` at ≥100% (Disarm) zeroed `enemy.attack` via the weaken reduction, so attacks "landed" for 0 damage (which resets the unstoppable counter, so that mechanic never engaged).
- `game_state.dart`: weaken reduction now `min(_enemyWeakenPct, 75)` on boss stages (boss always deals ≥25% of raw), and skipped entirely when `bossUnstoppable`. Non-boss enemies still fully disarmable.
- This was the 5th and (hopefully) final immortality layer: healing → stacked avoidance → stun/dodge perma-lock → **disarm**. All now bounded; the boss should finally deal real, continuous damage.

## +255 — Boss anti-perma-lock ("unstoppable" attack) + finish damage-taken telemetry
Build 254 log: avoidance cap worked (hero hit 61% once!) but `h_dmg_taken` still read ~6 while the hero lost 3.2M — the loss was the Cursed Ground affix (untracked), and the boss's own attacks were being skipped ~every round by DETERMINISTIC control (stun DR ~2/5 rounds + a re-castable guaranteed dodge-next-hit), which the probabilistic avoidance cap can't touch.
- `game_state.dart`: `_bossAttacksSkipped` counter; on boss stages, after 2 consecutive skips/avoids the next enemy attack is `bossUnstoppable` — bypasses stun, dodge-next-hit, Battle Awareness and the consolidated avoidance roll (still Armor-mitigated). Counter increments on each skip, resets when an attack lands. Guarantees a boss lands ≥1 of every 3 attacks regardless of control/avoidance stacking.
- Telemetry completeness: added `_noteHeroDamageTaken` to the three previously-untracked HP-loss paths (Cursed Ground / Death Spiral bleed, zone heroDrain, Volatile Death blast) so `h_dmg_taken` is now accurate.
- With stacked avoidance capped (254) + perma-lock broken (255), the boss's damage should finally connect on every build; then tune ATK/HP/heal from a true baseline.

## +254 — THE fix: cap stacked avoidance (root cause of boss immortality)
Build 253 diagnostic was decisive: `h_hp_min_pct: 100`, `h_dmg_taken: 0` over a 14-round tier-10 fight — the hero took **zero** damage. Not out-healing (every heal nerf across ~10 builds was the wrong tree); the hero was **avoiding every hit**. Dodge (≤37.5%) × Shadow Step (25%) × Void Step (15%) × enemy miss (≤66%) were independent sequential rolls that multiplied to ~87% avoidance/round → 0 hits landed over a fight.
- `game_state.dart`: consolidated the four probabilistic avoidance sources into ONE roll, `1 - Π(1 - each)`, clamped to `kMaxAvoidChance = 0.60`. Enemy now lands ≥40% of attacks regardless of stacked avoidance. Battle Awareness (once/fight) and stun (already DR-limited) kept separate/deterministic.
- This is the actual root cause of the "boss can't threaten a maxed hero" saga. With avoidance capped, the boss's (bumped) ATK finally connects and the (now-bounded) healing has to actually keep up.
- Next log should show `h_dmg_taken` >> 0 and `h_hp_min_pct` well below 100 — then we tune the real fight (heal/ATK/HP) from a correct baseline.

## +253 — Diagnostic: hero min-HP + damage-taken telemetry
Build 252 log confirmed the damage tame worked (DPS 86B→8B, finale now 24 rounds) but hero STILL ended exactly 100% HP over 24 rounds of a 3.68M-ATK boss — impossible via healing alone against a 6.6M pool, so likely the hero barely takes damage (dodge/control/shield), not out-healing. Added telemetry to settle it:
- `game_state.dart`: `_fightLowestHp` + `_fightDmgTaken` accumulators, updated via `_noteHeroDamageTaken(dmg)` at all three enemy→hero damage sites (basic attack, boss ability, DoT tick). ZBAL now logs `h_hp_min_pct` (lowest HP% reached) and `h_dmg_taken` (total received).
- Read: `min≈100 & taken≈0` → hero isn't being hit (mitigation/control problem); `min low & taken high & end 100` → out-healing. Next fight's log answers which.

## +252 — Close the throttle gaps (ability bucket, subclass, tier scaling)
Finishes the "throttle everything" pass — the paths that bypassed +251's caps are now covered:
- `hero_damage_builder.dart`: `abilityDamage` passive bucket + `subclassAbilityBonus` (ability context) now soft-capped via `_softCapPct` with a dedicated ability knob (`_kAbilSoft=200, _kAbilK=400`); `subclassDmgMult` (weapon context) soft-capped via `_softCapMore`. So ability-centric and subclass builds are throttled like gear-% builds.
- `game_state.dart` `_abilityScaledBase`: ability tier scaling `1 + tier*0.35 → 1 + tier*0.20` (T10 base spike ×4.5 → ×3.0) — smoother tiering, no burst.
- Net: every major damage path (additive%, paragon, endless, ability bucket, subclass, ability base tiering) now has a ceiling/gentler curve. DPS is bounded across all classes and can't spiral as investment grows.

## +251 — Global damage tame (soft-cap the shared multiplier stacks)
User: "tame the damage in general for all classes, nothing insane." Rather than editing hundreds of per-class skill/passive values, soft-capped the two runaway stacks at the shared damage-builder chokepoint (`hero_damage_builder.dart`), so every class's weapon + ability damage is tamed uniformly:
- Additive "increased" bucket (`allDamagePct` = gear damage% + passives + ascension + crit-replace + elem + guild…, was ~+4000% = ×41): diminishing-returns soft cap, linear ≤ +800%, asymptote +2400% (×25); a +4000% stack → ~+1870% (×19.7, ~2× cut).
- Endless multiplier (`endlessDmgMult = 1.008^strLevel`, ×11): soft cap on its %, linear ≤ +300%, asymptote +900% (×10); ×11 → ~×7.2.
- Helper `_softCapPct` / `_softCapMore` + tuning consts `_kIncSoft/K`, `_kMoreSoft/K` in the builder. Applied to both weapon and ability contexts. `avgHeroHit`/`h_dps` telemetry reflects it (uses real recorded hits).
- Stacks with +247 (paragon ×66→×34) and +250 (single-bonus caps): cumulative top-end DPS cut ~3-4×. Iterative — tune the four consts from the next `h_dps` log.

## +250 — Cap the big single damage bonuses (scale down damage)
User: reduce the large one-shot damage multipliers to ~5% each. Capped the handful of oversized single sources (per-rank/paragon/gear left alone — already small):
- `game_state.dart`: `critReplacementDamagePct` clamped to ≤10% (was reaching 200%+ from stacked Wrath score / DEX echo / subclass). `ascAllDamagePct` 12%/level → 5%/level. `Destroyer` ×1.20 → ×1.05 (+20%→+5% dmg). `Death's Edge` crit-dmg mult ×1.8 → ×1.05 (+80%→+5%).
- `ability_data.dart`: Bard ultimate **Crescendo** buff 50%→5% (Grand Performance/Magnum Opus milestone deltas 25/30 → 5/5) — the flagged Bard outlier.
- Descriptions/chips updated (Death's Edge, Destroyer). Net: crit/ascension/bard-burst builds lose the ~2× spike from Death's Edge×Destroyer×Crescendo; combined with +247's paragon soft-cap this pulls top-end DPS down. Aggressive per request — tune values up if too weak.

## +249 — Extend perk gating to all categories
Per request, the 50/100/200/350/500 board-investment ladder now applies to every perk category (each its own ladder, gates ascending along prerequisite chains):
- Economy: Blood Tithe 50, Carrion Picker 100, Soul Harvest 200, Treasure Sense 350, War Spoils 500.
- Progression: Swift Learner 50, Arcane Economy 100, Instant Recall 200, Soul Overdrive 350.
- Mastery: Eternal Flame 50, Deep Reserves I–IV 100/200/350/500, Master Forger 100, Soul Conduit 200, Paragon Dominance 500.

## +248 — Gate Paragon perks behind board investment
Feature: the unlockable Paragon perks now require a threshold of total points SPENT on the Paragon board before they can be purchased (on top of soul cost + prerequisite).
- `prestige_shop.dart`: `PrestigeNode.paragonGate` (default 0 = ungated); `canUnlock` now also requires `paragonPointsSpent >= node.paragonGate` (existing getter = Σ costBase·r(r+1)/2 across board ranks). `purchasePrestigeNode` already routes through `canUnlock`, so enforced in logic + UI.
- Combat ladder per request: Iron Resolve 50, Killing Blow 100, Blood Drinker 200, Death's Edge 350, Destroyer 500.
- `prestige_screen.dart`: perk shows "Locked: spend N Paragon points on the board (x/N)" and dims/disables until met.
- Economy/progression/mastery perks left ungated (gate 0) pending user's call on whether to ladder those too.

## +247 — Rein in offense: soft-cap paragon damage (diminishing returns)
Build 246 log root-cause: hero DPS is unbounded (paragon damage ×66 = +6493%, endless str `1.008^level` = ×10.9) so any boss dies in 1–2 rounds regardless of HP/ATK. User chose "rein in damage multipliers." First lever (biggest): the paragon damage %.
- `game_state.dart`: new `softCapPct(raw, soft, k)` diminishing-returns helper (linear ≤ soft, asymptotes to soft+k). Applied to `prestigeDamageMult`'s paragon term with `soft=1500, k=3000` → paragon damage now asymptotes toward +4500% (×46) instead of unbounded; a +6493% stack becomes ~+3373% (×66 → ×34.7, ~1.9× DPS cut at the extreme top). Early/mid (≤+1500%) unchanged.
- Deliberately staged: measuring DPS/rounds before also soft-capping the endless `1.008^level` term and/or re-tuning the +246 boss-HP bump (which may now be excessive against the reduced DPS). Bard's Crescendo (+50–105% burst) is a separate outlier still to address.
- Note: this is a top-end nerf; only heavily-invested endgame paragon damage is reduced.

## +246 — Fatten endgame boss HP (fix the 2-round stomp)
Build 245 log: heal cuts landed (Heal Rating 2.36M→1.01M, paragon ×7→×3) but a maxed hero STILL ended 100% — because the fight was only **2 rounds** (24.6B DPS vs 62.7B boss HP), so the boss barely swung. Healing and ATK are now fine; fight LENGTH is the binding constraint (the original "1-round stomp").
- `enemy_data.dart`: `endgameTierHpMult` `1.37^tier → 1.48^tier` (T10 ×23 → ×51, ~2.2×). Tier-10 boss HP ~62.7B → ~137B → maxed hero ~5–6 rounds instead of 2, so the boss's ~1.95M/round net damage accumulates against the now-bounded ~1M/round healing. Tier 0 untouched; scales per prestige tier.
- Expect `h_hp_pct` to finally drop well below 100 (target climactic ~30–50%). Slow/low-DPS builds will face a much longer, harder finale (intended). Tune 1.48 up/down from the next log.

## +245 — Hit the heal MULTIPLIERS (paragon + per-heal ceiling)
Build 244 log: passive-% cut landed (`heal.pct` 336→253) but Heal Rating rose to 2.36M because `heal.paragon` grew ×5→×7 (paragon ranks accrue with points — an UNBOUNDED multiplier that eats every fixed cut; documented as the reason magnitude-only won't stay balanced).
- `prestige_shop.dart`: Vitalist paragon `perRank 1.0 → 0.25` (×7 → ~×2.75 at current ranks).
- `game_state.dart`: `kHealMaxMult 0.4 → 0.25` (any single heal ≤ 0.25× Heal Rating).
- Target: rating ~0.9M, per-round healing ~0.7M < boss ~1.95M/round → `h_hp_pct` should finally drop below 100 (~70-80% on a 3-round fight). NOTE: paragon is unbounded, so this will drift back up as points accrue — a per-round heal cap is still the only permanent fix (user deferring).

## +244 — Cut Vitalist % + lower per-heal ceiling (user: passive % too high)
Also documented the metric caveat: on a WIN the hero heals to full between rounds and the boss dies on the hero's turn (no final swing), so `h_hp_pct` reads ~100% whenever healing ≥ damage — it only drops once per-round healing falls BELOW per-round boss damage (which is the goal). User kept "no cap," diagnosed passive % as too high.
- `passive_tree.dart` Vitalist % nodes: Restoration 5→2, Sanctify 8→3, Vital Surge 10→3 (branch % contribution 115% → 40%). Cuts `healBoostRatingPct` (~336% observed) meaningfully; a real (non-maxed) player is far lower.
- `game_state.dart`: new `kHealMaxMult = 0.4` — `healFor` now caps any single heal at 0.4× Heal Rating (× factor), replacing the 1× clamp. So even value-100 auras/heals are a partial top-up regardless of raw value.
- Combined effect: per-round healing should now sit below the boss's ~1.95M/round, so `h_hp_pct` finally drops below 100. Still magnitude-only (no cap) per user; will tighten kHealMaxMult / Vitalist values from the next log.

## +243 — Clamp per-heal multiplier (kill the value-100 outliers)
Build 242 telemetry: a **7-round** tier-10 fight still ended at **100% HP** (boss ATK 3.68M × 7 ≈ 16.5M vs 8.6M pool → hero should've died). So fight length wasn't the issue — high-**value** heal abilities/auras were. Heal `value` ranges 8→100; linear `value/30 × rating` made a value-100 aura = ~3.3× rating (~4.1M) — one source out-healing the boss.
- `game_state.healFor`: clamp `value` to `kHealValuePerMult` so **no single heal exceeds 1× Heal Rating** (× factor). Normal heals stay proportional; the value-50/100 outliers are capped to 1× (bursts ≈14% HP at current rating, HoT auras ≈7%/round). Lifesteal already ÷30.
- Expect the needle to finally break 100% — likely a low/lethal finish on the 7-round build; will ease kHealValuePerMult back down if it over-corrects into one-shot territory for short fights.

## +242 — Heal magnitude cut (live dials)
Build 241 telemetry: paragon fix + ATK bump landed (rating 8.7M→2.08M, boss ATK 1.32M→3.68M) but hero still 100% — heals ~6.2M/cast (51% HP) + lifesteal ~2.3M/round still covered the ~2.36M/round boss damage. Item-roll changes wouldn't help the current character (values already rolled), so tuned the LIVE dials:
- `kHealValuePerMult` 9 → 30: Healing Ward 3× → ~0.9× Heal Rating (~1.9M ≈ 15%/cast at 2.08M rating). Note: departs from the literal "28→3×" because the maxed investment stack (keystone ×2, +336%, paragon ×5 ≈ ×43 on flat) inflates raw rating to millions; with no cap (user's choice) the per-heal multiplier must shrink to stay "always partial."
- Lifesteal: `healRating × lifestealPct/100` → `÷ kHealValuePerMult` per hit (~19%/round → ~0.6%/round) — it was per-hit across ~11 hits/round.
- Expect ~65–75% finish next log. If still short of a climactic ~30%, the remaining cause is fight LENGTH (hero DPS ends it in ~2 rounds) — lever would be boss HP (longer attrition) or more ATK.

## +241 — Heal Rating magnitude fix + endgame boss ATK bump
Build 239 telemetry (`heal:{rating:8.7M, flat:47710, pct:336, paragon:21.0}`): Heal Rating hit 8.7M → Healing Ward healed ~26M vs a 12M pool (2× overheal), pinning the hero at 100%. Also confirmed boss ATK (1.32M) is trivial vs the pool even with healing off. User picks: tune magnitudes (no hard cap) + bump boss ATK ~3×.
- `prestige_shop.dart`: Vitalist paragon `perRank 10.0 → 1.0` (was 10× every other paragon; drove the ×21 multiplier). Heal Rating now ~1.2M → heals ~30%/cast (partial).
- `enemy_data.dart`: `endgameTierAtkMult` growth `1.20^tier → 1.33^tier` (T10 ×6.2 → ×17.3, ~2.8×). Tier-10 boss ATK ~1.32M → ~3.7M (net ~2.4M/round after 36% Armor). Tier 0 untouched; scales per prestige tier.
- Open/tuning: heals at ~30%/cast may still be high for a maxed healer (kHealValuePerMult/item-base can drop further); re-read ZPWR `heal` + ZBAL `h_hp_pct` next fight. Watch that ~3.7M ATK doesn't one-shot low-HP builds.

## +240 — Vitalist below Guardian in the passive tree
Cosmetic: `passive_tree_screen` now renders branches in an explicit order (elementalist, slayer, guardian, **vitalist**, merchant, mystic, ascendant) so Vitalist sits directly under Guardian, instead of relying on enum order (which placed it after mystic). No enum reorder — avoids any index-based risk.

## +239 — Heal Rating system (healing decoupled from max HP)
Root-causes the immortality loop: heals were `% of max HP`, so a bigger HP pool auto-healed more, and lifesteal was `% of (billions of) damage`. Now ALL healing scales off a dedicated **Heal Rating** stat (like damage has its rating), tuned to grow *slower* than the damage/HP curve → "always partial." Design decisions (user): base heal rating = **zero innate** (fully from investment); scope = **everything** (abilities, HoT auras, Field Triage, lifesteal); endgame = **always partial**.
- `equipment.dart`: new `ItemStat.healRating` affix (rolls on helmet/accessory/relic pools; its own uncapped `_baseValue` branch `25 + m*20` × lvScale so it can scale to matter vs the HP pool). Wired into all `ItemStat` label switches (equipment, forge, inventory ×2).
- `passive_tree.dart`: new `PassiveEffect.healRatingFlat` (+`healBoost` repurposed as Heal Rating %); new **`PassiveBranch.vitalist`** branch — Mend/Restoration/Lifebloom/Sanctify/Wellspring/Vital Surge (flat→%→flat→%→flat→%) + keystone **Eternal Font** (doubles base + 2000 flat). Branch metadata (color/name/emoji) added to `passive_tree_screen`; `passive_icon` + label switches updated.
- `prestige_shop.dart`: `ParagonEffect.healRating` + **Vitalist** paragon (+10%/rank).
- `game_state.dart`: `healRating` getter = `flat × (1+healBoostRatingPct/100) × paragonHealMult`, base doubled by the Vitalist keystone; `healFor(value, factor)` = `healRating × value / kHealValuePerMult(9) × factor`. `healHp` now delegates to `healFor` (was `maxHP × abilityHealPct`); Mira triage → `healFor(25)`; **lifesteal** → `healRating × lifestealPct/100` per hit (was `% of damage`, HP-cap removed). Heal Rating breakdown added to ZPWR telemetry (`heal:{rating,flat,gear,passives,pct,paragon}`).
- `ability_upgrade_screen`: heal/aura rows now show actual HP + `×Heal Rating` instead of `% HP`.
- Note: ability *flavor* description strings in `ability_data.dart` still say "% HP" in prose — mechanic + summary line are authoritative; prose cleanup deferred. Magnitudes (`kHealValuePerMult`, item base, Vitalist values) are first-pass — tune from the next ZPWR `heal` log.

## +238 — Bigger HP pool + global recovery cut (attrition model)
Diagnosis from tier-10 telemetry (build 237): hero ended at **exactly 100% HP** every fight. Cause is scale divergence, not damage types — hero HP 7.3M with ~4,100% HP multipliers, boss ATK only 1.32M (~11% after Armor), fight over in 3 rounds, and lifesteal (12%/round cap ≈ 876K) + regen topped off the ~1.7M of chip. Per user direction (no %-max-HP damage): grow HP and cut recovery so HP is a slowly-drained resource.
- `hero_model.dart` maxHealth base: `100 + (level-1)*10 + (level*level)~/8` → `100 + (level-1)*14 + (level*level)~/5`. L1000 base 135K → 214K (~+60%); L1 unchanged (onboarding preserved). Multipliers still apply on top.
- `game_state.dart`: new `kRecoveryMult = 0.4` applied to **all** healing chokepoints — `healHp` (ability bursts + HoT auras), Mira Field Triage (25%→10% effective), aura HP regen. `kLifestealMaxPctPerRound` 12.0 → 4.0.
- Net: per-round sustain drops from ~12%+ of max HP to ~4% (lifesteal) plus ~40%-scaled ability heals, against a ~60%-bigger pool, so incoming damage accumulates instead of being erased.
- Open: boss ATK (1.32M) is still small vs the pool; even at zero recovery a 3-round fight only removes ~20%. If the next log still reads high, the remaining lever is an endgame boss-ATK bump (flat, not %HP) — flagged for the user to approve.

## +237 — Hotfix: type crash in enemy ability-threat display
+236 crashed the battle screen (grey error widget) for any enemy with abilities. `_buildArena(..., enemy)` takes `enemy` untyped (dynamic), so `enemy.abilities.map(...).where(...).toList()` inferred `List<dynamic>`; the implicit downcast to the `List<DamageType>` param passed static analysis but threw `type 'List<dynamic>' is not a subtype of type 'List<DamageType>'` at runtime. Replaced the chain in `battle_screen.dart` and `endless_screen.dart` with an explicitly-typed set literal (`<DamageType>{ for (final a in enemy.abilities) if (a.damageType != physical) a.damageType }.toList()`), which forces the element cast at insertion and yields a properly typed list regardless of `enemy`'s static type.

## +236 — Surface enemy ability elements in the battle panel
Players had no way to see what elements a boss would hit them with (the panel only showed the now-always-physical basic-attack icon). Now the enemy panel shows the distinct elemental damage types drawn from the enemy's `abilities` (physical excluded).
- `battle_arena.dart`: `_CombatantPanel.damageType` (only ever populated for the enemy's basic type; the hero-side label was dead code since the hero panel never passed it) replaced with `abilityTypes` (`List<DamageType>`), rendered as small colored element icons in the LV/HIT row. Removed the dead hero-side damage-type label chip. Added `BattleArena.enemyAbilityTypes` passthrough.
- `battle_screen.dart` + `endless_screen.dart`: compute `enemy.abilities.map((a) => a.damageType).where(!= physical).toSet()` and pass it. Added `../models/damage_type.dart` import to both.
- Dungeon mode uses a simplified `DungeonRoom` (no `abilities` list), so nothing to show there — unchanged.

## +235 — Damage-type model: physical basics, elemental abilities
Establishes a clean two-axis defence model on the back of +234's physical retirement. Every enemy **basic attack** is now `DamageType.physical` (Armor-gated, cap 37.5% DR — can't be fully resisted), and enemy **abilities** carry the elemental variety (resist-gated). Armor = sustained-damage defence; resistances = spike/ability defence.
- `enemy_data.dart`: all 120 base enemy `attackType` → `DamageType.physical` (sed pass). `enemyForStage` copies `base.attackType`, so all campaign/abyss/scaled enemies inherit physical basics.
- `game_state.dart` boss-ability damage now routes through `mitigateIncoming(raw, ability.damageType, heroArmorValue)` for **both** `bonusDamage` (was resist-only → physical abilities like Gate Slam/Crushing Blow/Frenzy Strike were unmitigated after physical-resist hit 0) and `dot` (was **fully unmitigated** — now Armor-gated for physical, resist-gated for elemental, applied once at affliction time).
- Endgame bosses de-mono-typed so no single resistance walls the kit: **Zeta Absolute** Omega Pulse void→lightning (keeps void nuke); **Lich** Death Nova void→fire; **Prisoner** Soul Crush void→cold; **God Eater** Godbreaker void→poison; **World Ender** End of Days void→cold. Each now demands Armor + 2 resistances. Mid-game thematic bosses (Ice Wyrm, Storm, etc.) left mono-element on purpose.
- Net: the finale can no longer be face-tanked by stacking one resist — physical basics always chip (Armor caps at 37.5%), and the second element lands unless separately resisted.

## +234 — Retire physical from the player kit (dedupe onto Armor)
Physical was doubly-mitigated (Armor DR + physical resistance, both partly from STR). Removed physical as a player-facing concept; Armor is now the sole physical defence. Scope: player-side only — enemies still deal physical (Armor mitigates it), so physical bosses stay a distinct, hard-to-fully-mitigate threat.
- `game_state.dart` `heroResistancePct(physical)` → returns 0 (no physical resistance; kills the double-dip). Enemy physical hits now go through Armor DR only.
- `hero_model.dart`: `availableDamageTypes` no longer lists physical (it was vestigial — `activeDamageType` already mapped index 0 → classElement, so heroes never actually dealt physical). Heroes deal classElement (+ secondary via Dual Mastery). Default `activeDamageTypeIndex` 1 → 0; getter is now list-based + clamped.
- Removed the physical **onyx** gem from both craft UIs (`forge_screen`, `inventory_hub_screen`) and **physical mastery** from the Elemental Mastery screen.
- Bonuses sheet: damage-type and resistance rows now exclude physical (5 elements each); Armor row unchanged (it *is* the physical defence).
- Enum `DamageType.physical` retained (enemy attack type + Armor's target); existing onyx gems become inert (can't be crafted; deal/resist nothing for an elemental hero).

## +233 — Max HP scaling (super-linear per-level base)
Telemetry: a maxed L1000 hero had only ~410K HP while dealing billions/hit — HP was ~5 orders of magnitude behind damage, so it never felt like growth and bosses couldn't land big hits without one-shotting. `hero_model.dart` maxHealth base `100 + (level-1)*10` → `100 + (level-1)*10 + (level*level)~/8` (super-linear). L1000 base ~10K → ~135K, so with endgame %HP the pool is multi-million; early game is barely changed (L1 still 100, L100 ~2.3K base). HP clamp raised 1e9 → 1e15. This is a *feel/headroom* change (bigger pool, per-level growth); relative difficulty still governed by enemy ATK% + the sustain caps — enemy ATK will be re-tuned to the new HP scale from the next log.

## +232 — Endgame ATK pass 3 (post-sustain-cap)
Build-230 telemetry: with healing (37.5% rating cap) AND lifesteal (12%/round cap) both bounded, a maxed hero *still* ended the tier-10 final boss at 100% HP over 11 rounds (net zero damage). Confirms the remaining issue is boss ATK, not sustain. Raised `endgameTierAtkMult` base `1.09 → 1.20` (T10 ×2.37 → **×6.2**, boss ATK ~503K → ~1.31M) to clearly out-pace the now-bounded healing ceiling. HP ramp unchanged (11-round length is good). Iterative — watch for one-shots on low-resist heroes and re-check the log.

## +231 — Boss-bounty gate, artifact unlock+tutorial, Blood Drinker rework
- **Boss Bounties gated** (`game_state.dart` + `bounty_board_screen.dart`): the BOUNTIES tab lives inside the Challenges screen (opens at stage 5), so boss bounties were reachable far too early. Added `bossBountiesUnlocked` (`effectiveUnlockStage >= 20`, matching `_unlockStageNames` + the tutorial); the tab now shows a "locked until stage 20" placeholder until then.
- **Artifacts unlock on first find + tutorial** (`game_state.dart` + `inventory_hub_screen.dart`): the ARTIFACTS inventory tab was gated at `stage >= 22` — the *same* stage as Mercenaries — so it appeared silently with no tutorial. Switched it to a persisted `artifactsUnlocked` flag set when the first artifact drops (`gainArtifact`), which also fires a new `-5` sentinel tutorial explaining artifacts. Persisted in save (defaults to `ownedArtifacts.isNotEmpty` for existing saves).
- **Blood Drinker reworked** (`prestige_shop.dart` + `game_state.dart`): was a flat 5% heal-on-kill — didn't scale and was an uncapped sustain source. Now grants **6% lifesteal** (`prestigeLifestealPct`, added to the consolidated lifesteal sum), so it scales with damage and rides the +230 per-round lifesteal cap (12% max HP). Removed the on-kill heal block.

## +230 — Lifesteal per-round cap + enemy miss-chance cap
Two sustain/immunity holes surfaced in the "what else needs bounding" audit.
- **Lifesteal capped** (`game_state.dart`): the four sources (Life Steal keyword 4%, Fiend Pact/subclass, class mastery, draining aura) were each an uncapped % of damage dealt, clamped only to missing HP. At endgame `damage ≫ maxHP`, so ~1% lifesteal full-healed every hit — the real reason a maxed hero never dropped below full (build 225's heal-rating didn't touch lifesteal). Consolidated the four into one and capped total lifesteal to **`kLifestealMaxPctPerRound` = 12% of max HP per round** (lifesteal only fires on the primary hit, once per `heroAttack`, so per-hit = per-round). Tunable.
- **Enemy miss-chance capped at 66%** (`game_state.dart`): the miss-chance debuff the hero inflicts (`_enemyMissChancePct`) was set straight from the ability value with no cap — stack it to 100% and a boss never lands a hit. Clamped all four set-sites to `0..66` (~2/3), so it's strong but never a full lockout.

## +229 — Resistance cap 75% → 90%
`kResistCapPct` 75 → 90 (+ heroResistancePct clamp and Bonuses-sheet label/marker). Aligns the elemental-resistance ceiling with the existing 90% max-damage-reduction floor, so no resistance is wasted. Since the cap is a linear scalar on the DR curve, every resistance value scales ×1.2 (e.g. a full-investment single-element build ≈ ~68–80% depending on flat rating, up from ~57–67%), still asymptotic — 90% requires heavy investment. `K` unchanged at 50.

## +228 — Elemental resistance → diminishing-returns rating
Resistance now uses the same rating pattern as armor/dodge/healing (`game_state.dart`):
- New `kResistCapPct = 75` and `kResistRatingK = 50`; `resistPctForRating(rating) = 75 × rating/(rating+50)`.
- `heroResistFlatRating(type)` = stat-based (stat×25/100) + per-element + all-element passives (FLAT rating). `heroResistRatingBoostPct(type)` = elemental mastery + gems (a **% boost** to the rating). `heroResistancePct` = `resistPctForRating(flat × (1 + boost/100))`, clamped 0..75 (negatives = vulnerability, kept flat, floor −75).
- Net: the 75% cap is now asymptotic — half the cap (~37.5%) at rating 50, ~50% at 100, ~60% at 200 — so late-game 75% takes heavy investment instead of trivially clamping. Gems/mastery scale the whole rating rather than adding flat %.
- Bonuses sheet resistance rows rewritten to show it: flat rating, mastery+gem boost %, effective rating, resulting %, and the +75%/−75% bounds.
- Applies everywhere `heroResistancePct` is read (campaign incoming elemental + all side modes), so it's consistent.
- **Tuning note:** `kResistRatingK = 50` is a first calibration; the exact feel needs a play/log check (resistances are meaningfully lower per-investment than the old clamp-to-cap).

## +227 — Guild buff on all damage + resist cap 50→75
Follow-ups to the +226 audit:
- **Guild all-damage on abilities too** (`game_state.dart`): added `guildBuffs.allDamagePct` to all four ability damage-% contexts (bonusDamage, dot, milestone-bonus, unique-item), so it now applies to every hero damage source, not just auto-attacks.
- **Hero resistance cap 50% → 75%** (`heroResistancePct` `clamp(-75, 50)` → `clamp(-75, 75)`; Bonuses-sheet label + at-cap marker updated). Safe now that the healing-rating cap bounds sustain — a higher resist cap rewards investment without making heroes untouchable.

## +226 — Progression-systems audit (completeness + bonus-sheet accuracy)
Audited every system against the hero's core stats. Fixes:
- **Armour unified** (`game_state.dart` `heroArmorValue`): it was missing the endless-upgrade (CON) armour sources — lightFooted, Iron Will, Juggernaut, Fortitude flatDamageReduction, Thick Hide — that only the campaign's inline sum had. So the **side modes and the Bonuses sheet under-counted armour**. Added them; campaign `baseArmor` and `heroArmorValue` now contain the identical source list (same % boosts too: temp AC buff + mercs + subclass + DUR score).
- **Guild all-damage buff wired in** (`game_state.dart`): `guildBuffs.allDamagePct` (T10 castle) was only read for gold — now added to the hero's auto-attack damage %. (Ability-damage sums still omit it — minor, flagged.)
- **Bonuses sheet armour row** (`hero_stats_screen.dart`): was crediting **DEX** gear (armour comes from **STR**), missing gems/quest/aura/artifact/rune/mastery/score/endless, and re-summed a partial total. Now shows the authoritative `heroArmorValue` with a corrected breakdown.
- **Bonuses sheet resistances**: cap label said "±90%" but hero resistance actually caps at **+50% / −75% floor** (`heroResistancePct`); fixed the label, the "at cap" marker, and the per-source math (`×25/100`, no phantom −10 offset).

Verified-and-intended (not bugs): crit chance/damage are gear-only by design (non-gear crit is redirected to % All Damage via `critReplacementDamagePct`); pets/ascension don't grant max-HP%; resistances come from stats/passives/gems/elemental-mastery only.

## +225 — Healing → diminishing-returns rating (fixes infinite sustain)
Root-causes the "maxed hero ends at 100% HP" problem: it was over-SUSTAIN, not weak boss ATK. Ability healing now works like armour.
- **New model** (`game_state.dart`): a heal ability's scaled value + every "+% healing" source (passives, subclass) form a **rating**; the actual heal % of max HP is `armorDrPctFor(rating)` — the same diminishing-returns curve as armor, capping at `kDefenseCapPct` (**37.5% of max HP per heal**). Bursts use the full %, per-round HoT auras use ×0.5 (≤18.75%/round). Repeated-heal fatigue still stacks on top of the cap.
- Replaced the old unbounded `maxHP × sv/100 × healBoostMult × 0.30` (which let a maxed heal build restore ~100%+ per cast → unkillable). All 6 heal sites (base heal/aura, milestone-bonus heal/aura, unique-item heal/aura) now go through one `healHp()` helper.
- Added `healBoostRatingPct` + `abilityHealPct(value, {factor})` getters shared by combat and the ability display, so the card's "+X% HP" now shows the **real** (rating-capped) number instead of the raw value.
- **Reverted +224's ATK bump** (`endgameTierAtkMult` 1.15→1.09, T10 ×4.05→×2.37): with sustain now bounded, the previously-tested ×2.37 ATK (which the hero merely out-healed) should now actually bite, without cranking ATK into one-shot territory.
- Net: low-investment heals are ~unchanged (rating≈value); heavily-stacked heal builds are capped at 37.5%/cast — bounded, finite sustain. Needs a fresh fight log to confirm the hero now loses meaningful HP.

## +224 — Endgame ATK tuning pass 2 (sustain equilibrium)
Post-223 telemetry: the ×23 HP made the tier-10 final boss a 15-round fight (good), but the maxed hero ended at **100% HP** — the ×2.37 ATK was fully absorbed by mitigation + healing (hero sat pinned at max HP). Raised `endgameTierAtkMult` base `1.09 → 1.15` (T10 ×2.37 → **×4.05**; boss ATK ~503K → ~860K) to push past the healing equilibrium and add real danger. HP ramp unchanged (15 rounds is the right length). Iterative — will re-check the log.

## +223 — Endgame tier tuning (campaign tiers 1-10)
Telemetry showed a fully-maxed hero one-rounding the tier-10 final boss at 95% HP — the top of the ladder was badly under-tuned vs L1000+ power. Added an exponential per-tier multiplier on top of the existing continuous depth curve (`enemy_data.dart`):
- `endgameTierHpMult(tier) = tier<=0 ? 1 : 1.37^tier` → T1 ×1.37 … **T10 ×23.3 HP**.
- `endgameTierAtkMult(tier) = tier<=0 ? 1 : 1.09^tier` → T1 ×1.09 … **T10 ×2.37 ATK**.
- Applied to the campaign `hpValue`/`atkValue`. **Tier 0 is untouched** (onboarding). HP ramps hard (long, climactic fights); ATK ramps gently (threatening over a long fight but must not one-shot — heeding the `kAtkGrowth` one-shot warning). It's exponential so low tiers barely move and the endgame climbs steeply.
- Net for the tier-10 final boss: ~2.69B HP → ~63B, and ~212K ATK → ~500K (still ~89% mitigated by a maxed hero's armor/resistances, so ~55K net/hit — dangerous over a long fight, not a one-shot).
- Rewards key off `enemy.level` (not HP/ATK), so no gold/XP/loot inflation. The abyss branch (its own `tierHpMult`) is unchanged.
- **Needs play validation:** the ×23 HP figure was calibrated against the *capped* ~2.7B/round DPS from the pre-222 log; with damage now uncapped the hero hits harder, so the exact round-count will need a fresh telemetry line to fine-tune.

## +222 — Remove the remaining 999,999,999 damage caps
Balance telemetry from a tier-10 final-boss kill showed `maxhit:999999999` / `h_dps:999999999` — the hero's hits were being clamped at ~1e9. The final auto-attack clamp was already 1e15, but the **Wild Magic ×3** and **Vulnerable-debuff** steps (and ~34 other damage/heal/DoT spots) still used `.clamp(1, 999999999)`, and the hero's ability applies vulnerable — so every hit got clipped.
- `game_state.dart`: bulk-raised all 36 `.clamp(1, 999999999)` → `.clamp(1, 1e15)` plus one `.clamp(0, 999999999)` on a boss-ability damage. Covers hero auto-attacks, crits, wild-magic, vulnerable, DoTs, auras, heals, merc procs, thorns, drains, enemy attack construction, and boss abilities. (Left `rawCritChancePct`'s `clamp(0, 999999999)` — that's a percentage, not damage.)

## +221 — Abilities: unify tier + ascension into one scaler
Answering "we can tier AND ascend — is that all in the calc?": it wasn't. There were **three** disagreeing paths:
- **Campaign combat** computed its own `sv = (baseValue + rank*max(1,baseValue/8)) * uniqueMult * ascMult` — included **ascension** but had **no tier multiplier** (and +220's tier rework never touched it).
- **Display** (`scaledAbilityValueAtRank`) had the +220 tier curve but **no ascension**.
- **Alternate modes** (gauntlet/boss_rush/guild/dungeon) call `game.scaledAbilityValue`, so they inherited the display formula — also no ascension, and different from campaign.

Unified them on one core scaler `_abilityScaledBase(baseValue, rank, isDamage)` (`game_state.dart`):
- Damage abilities: monotonic total-rank growth × `(1 + tier*0.35)` (T0 ×1 … T10 ×4.5). Utility: gentle monotonic curve.
- `scaledAbilityValueAtRank` = core × **abilityAscension** (+10%/ascended tier) × role-power (damage only) — so the **display and the side modes now include ascension**.
- Campaign `_fireAbility` now calls `_abilityScaledBase` directly (× uniqueMult × ascMult), applying role-power at the damage step as before — so the **tier multiplier finally applies in actual campaign combat**, and there's no double role-power.
- Net: tiering + ascension both count in campaign, modes, and the on-card display, and all three agree.

## +220 — Ability damage: rescaled + uncapped
Abilities tier up to T10 but damage was clamped at 9,999 (display) and the value curve dropped at every tier boundary.
- **Scaling** (`game_state.dart` `scaledAbilityValueAtRank`): damage abilities (bonusDamage/dot) now scale off **total rank** (1..165) so growth is monotonic — a new tier no longer resets `rankInTier` back to 1 and drops the value. Each rank adds ~1/6 of the base and each tier layers `×(1 + tier*0.35)` (×1 at T0 … ×4.5 at T10). Utility abilities (heals/buffs/debuffs — these are % / rounds) keep the gentle original curve so we don't get a 3000% heal.
- **Uncapped combat** (`game_state.dart`): bonusDamage `psv` (999999→1e15) and final (999999999→1e15); DoT `baseDmg` (999999→1e15) and `_dotDmg` (999999999→1e15). The bonusDamage roll switched from `_rng.nextInt(psv)` to `(_rng.nextDouble()*psv)` because `nextInt` throws once `psv` exceeds 2³².
- **Uncapped display** (`ability_upgrade_screen.dart`): the `~X–Y dmg` / `~X dmg/r` scaled-damage lines and the Current/Next summaries no longer clamp to 9,999 — they show the real value via `fmtNumber`.
- **Formatting**: the abilities screen's Shards balance (`1000115303`) now uses `fmtNumber`.

## +219 — Welcome Back modal: correct reward icons
`main_shell.dart`: the offline-rewards rows used generic `GameIcon` symbols (coin/star/starburst/compass/gift). Changed `_offlineRow` to take a `Widget` icon so it can render real currency icons:
- **Gold** → `CurrencyIcon('gold')` (the pixel coin, matching the rest of the app).
- **"Essence"** → this reward is actually **Shards** (`int get essence => shards`), so it now uses `CurrencyIcon('shards')` (◆ blue gem) and the label reads "shards" with the shards colour.
- XP keeps the star, Expeditions keep the compass, Comeback keeps the gift (all appropriate) — now passed as explicit `GameIcon` widgets.

## +218 — Consistent gold coin icon + Scores number formatting
The game already had a pixel-art gold coin painter (`CurrencyIcon(id: 'gold')`, used in the HUD resource bar), but several screens still used the Material `Icons.monetization_on` "$" icon or the 💰 emoji. Unified them on the existing coin (rather than adding a second, clashing style — I built and then discarded a smooth gradient `GoldIcon` once I found the established pixel coin).
- Swapped `Icons.monetization_on[_outlined]` → `CurrencyIcon('gold')`: `ability_scores_screen.dart` (gold badge), `widgets/upgrade_tile.dart` (upgrade cost, dimmed via Opacity when unaffordable), `hero_stats_screen.dart` (Gold + Gold-per-Kill rows — added a `currencyId` field to `_StatRow` that renders `CurrencyIcon` and takes priority over the `IconData`).
- Swapped the prominent 💰 gold chips → coin: Forge balance line, the Hero-sheet Income Summary "Idle gold" (`_IncomeRow` gained an optional `iconWidget`), and the idle-collect gold chip (`_RewardChip` gained an optional `iconWidget`). Forge balance/shards also now use `fmtNumber`.
- **Ability Scores**: the gold badge and the "Next: … gold" upgrade cost now go through `fmtNumber` (were raw digits).
- Left the 💰 emoji in data/reward lists and battle-log strings as-is (content, not the currency indicator).

## +217 — Number formatters: add B (billions) and T (trillions)
- `theme/app_theme.dart` `fmtNumber`: only went up to `M`, so a billion rendered as "1000.1M". Added `B` and `T` tiers.
- `utils/format_number.dart` `fmtNum`: had `B` but not `T`; added `T`.
- Both are used app-wide, so every abbreviated number (Shards/Echoes, idle income, welcome-back rewards, etc.) now reads cleanly at billion/trillion scale — which the maxed/late-game economy routinely hits.

## +216 — Income Summary number formatting
- `dashboard_screen.dart` INCOME SUMMARY: Shards (`1000096104`) and Echoes (`1000000`) rendered raw → now `AppTheme.fmtNumber` (1.0B / 1.0M). Also formatted the Battle/kill avg and Expeditions-pending values for consistency (the latter previously only did a hand-rolled "K" that broke past millions).

## +215 — Ability Scores: reorder + FOR/DUR rework
- **Order** (`ability_scores_screen.dart`): now PWR · WRA · VIT · END · FOR · DUR (was PWR · END · VIT · WRA · FOR · LCK).
- **FOR (Fortitude)**: was "+1 armor class per 2 ranks" → now **flat +1 AC Rating per rank** (`_scoreFor => abilityScoreRank('for_')`, was `~/ 2`). Reworded "AC" → "AC Rating".
- **LCK → DUR (Durability)**: LUCK's +1% gold/rank is replaced by **+0.5% AC Rating per rank** (`_scoreDurPct => abilityScoreRank('lck') * 0.5`). Kept the internal `'lck'` save key so existing invested ranks carry over; emblem swapped clover → shield.
- **Combat wiring**: DUR% now feeds the armor-rating % boost and FOR flat feeds the base rating in **both** `heroArmorValue` (bonus sheet + all alternate modes) **and** the campaign combat `baseArmor`/`acPctBoost`. This also closes a pre-existing gap where the FOR score and **subclass armour %** weren't applied in campaign combat mitigation (they are now, matching the modes/display). Removed the two `* (1.0 + _scoreLck/100)` gold multipliers.

## +214 — Idle cap: 24h base + Deep Reserves Paragon chain
Reworked the offline idle-accumulation window per design intent.
- **Base cap 8h → 24h** (`game_state.dart` `_applyOfflineProgress`): the hard-coded `const capSecs = 8 * 3600` is now `final capSecs = idleCapHours * 3600`.
- **New `idleCapHours` getter**: base 24h + 6h per unlocked Deep Reserves node (max 48h).
- **New Paragon nodes** (`prestige_shop.dart`, Mastery category, chained): `idle_reserve_1..4` = "Deep Reserves I–IV", +6h each (30h/36h/42h/48h), soul costs 5/8/12/16. Data-driven, so they render on the Paragon board automatically; `debugMaxCharacter` force-unlocks all nodes so the max character gets the full 48h.
- **Welcome-back copy** (`main_shell.dart`): the "away for more than 8h" line now shows the player's actual cap (`${game.idleCapHours}h`).
- Per-cycle idle *rate* caps (99,999 XP / 9,999 essence) left as-is — the request was about the time window, and over 24h those rates now accumulate far more anyway.

## +213 — Character select: bottom spacing
- `character_select_screen.dart`: the character `ListView` had no bottom padding, so the last slot (often the faint LOCKED SLOT) sat flush against the fixed "swipe a character left to delete" footer and looked like it overlapped. Added 16px bottom padding for clear separation.

## +212 — UI pass: consistent number formatting
Screenshot-driven sweep of the main feature screens. Everything looked polished except several large numbers rendered raw instead of abbreviated via `AppTheme.fmtNumber`. Fixed:
- **Welcome Back** (`main_shell.dart`): essence reward `+22269` → `+22.3K` (gold/XP were already abbreviated).
- **Idle-collect chips** (`dashboard_header.dart`): gold read `683.6Kg` (the "g" glued to "K" → looked like kilograms) → dropped the redundant suffix (the 💰 icon already signals gold); essence and XP chips now abbreviate too.
- **Medieval Power** (`dashboard_header.dart`): the hero-header power score `5397667` → `5.4M`.
- **Shop** (`premium_shop_screen.dart`): the ZCoin balance in the app-bar `1000000` → `1.0M`.

Noted but NOT changed (balance, not UI): idle XP is hard-capped at 99,999 and idle essence at 9,999 (`game_state.dart` `idleXpPerCycle` / `idleEssencePerCycle`). These may be intentional throttles for the 6-month progression target, so left for a balance decision rather than changed blind.

## +211 — Full combat parity: Dodge Rating + Resistances in all modes
Follow-up to +210. The modes had armor rating but were still missing the other campaign systems: passive **Dodge Rating** and **elemental Resistances** (both hero incoming and enemy typing). Now aligned.
- **Shared helper** `GameState.mitigateIncoming(raw, attackType, armorRating, {tempAcPct})`: physical → armor DR; elemental → bypasses armor and is reduced by the hero's resistance to that type (±90% cap). Dodge is a separate full-negation roll the caller makes first via the existing `effectiveDodgePct`.
- **Dodge Rating everywhere:** Gauntlet, Boss Rush, Guild and Dungeon (both the authoritative `resolveCombat` and the animated screen fight) now roll the hero's passive dodge before each incoming hit (same diminishing-returns curve, 37.5% cap).
- **Enemy typing + resistances:** `enemyForStage` gained an optional `resistanceTier` so a mode can scale resistances by its *own* tier without disturbing its HP/ATK curve. Gauntlet & Boss Rush now keep the enemy's `attackType` + (mode-tier-scaled) `resistances` instead of discarding them; incoming elemental hits use your resistances, and your damage type is checked against enemy resistance on the way out.
- **Dungeon:** `DungeonRoom` gained `enemyAttackType` + `enemyResistances` (populated from the base enemy in all five room generators). `resolveCombat` now takes `heroDodgePct`, `heroDamageType`, and a `heroResistances` map; both the model and the animated screen apply incoming elemental resistance, enemy resistance vs the hero, and dodge. (Dungeon resistances are tier-0-scaled = mild, to stay safe.)
- **Guild:** dodge added. Guild bosses have no damage type in their model, so incoming stays physical (armor) — giving them elements would need a boss-model redesign (out of scope for a rating migration).
- **Files:** `game_state.dart` (helper + dungeon-resolve wiring), `data/enemy_data.dart` (`resistanceTier`), `models/dungeon.dart` (room fields + `resolveCombat`), `boss_rush_screen.dart`, `gauntlet_screen.dart`, `guild_screen.dart`, `dungeon_screen.dart`.
- **Untested:** device was offline, so this is compile-verified only — the resistance directions (single-element hard-counters) are exactly the balance-sensitive area to watch on-device.

## +210 — Migrate ALL modes to the campaign's Armor Rating combat model
The alternate combat modes (Boss Rush, Dungeon, Gauntlet, Guild) still used the pre-rework model: a partial flat armour sum, flat `raw − armour` subtraction, flat AC/ATK ability buffs, ATK→crit conversions, and a `clamp(1, 9999)` ceiling on every value. They're now unified with the campaign.
- **New shared helper** `GameState.physicalAfterArmor(rawDamage, armorRating, {tempAcPct})` (static + pure so the Dungeon model can call it): armour runs through the diminishing-returns curve (`kDefenseCapPct` / `kArmorRatingK`); `tempAcPct` (the acBonus ability + mercs) is a % boost to the rating; physical only; **no flat subtraction, no cap**.
- **Full armour rating in every mode:** each mode snapshotted only a partial flat AC (`armorClass + passives + gear-AC + pets/skins/quest`). All now use `heroArmorValue` (adds STR, sets, gems, artifacts, auras, mastery + the merc & subclass % boosts) — the same number shown on the hero sheet. The authoritative dungeon resolve (`game_state.dart` `resolveCombat` call) passes it too.
- **% buffs, not flat:** `acBonus` ability → % armour rating; `attackBonus` ability → % damage (was a dead/crit-converted stat in these modes). Boss Rush/Guild/Dungeon-screen previously turned the ATK buff into crit chance (`_bonusAtk * 2`) — now a straight % damage buff, matching the campaign. Dungeon merc procs (Greybeard/Lena/Felix/Ruk) ride the same %.
- **Caps lifted:** every combat `clamp(1, 9999)` / `clamp(1, 999999)` in the four modes raised to `1e15` (matches the campaign's no-cap ceiling), incl. enemy ATK/HP construction, hero hits, DoTs, heals, shields, drains, regen.
- **Labels:** all mode battle-log lines now read `+N% AC` / `+N% DMG`.
- **Resistance cap** in Gauntlet/Boss Rush hero attacks aligned from `75` → `90`.
- **Files:** `game_state.dart` (helper + dungeon-resolve AC), `boss_rush_screen.dart`, `dungeon_screen.dart`, `models/dungeon.dart` (now imports game_state for the shared helper — a legal Dart cycle), `gauntlet_screen.dart`, `guild_screen.dart` (+ removed the now-unused `equipment`/`passive_tree` imports from guild & dungeon_screen).
- **Note:** the per-fight merc-proc magnitudes in Dungeon (Felix +6% / Ruk +4% AC, Greybeard +5% / Lena +8% DMG) are now %-based and modest — a future balance pass may want to bump them.

## +209 — Correct %-based labels for AC & resistance (rework follow-up)
Cleanup of stale labels left over from the "flat AC → % Armor Rating" and "resistance cap 75→90" reworks. All are display/text fixes; the underlying mechanics were already %-based.
- **Mercenaries** (`npc_ally.dart` `statSummary`/`bonusSummary`, Guardian `bonusDescription` "+3 AC/level"→"+3% AC Rating/level"; `npc_ally_screen.dart` bonus tag; `hero_stats_screen.dart` merc passive total): now read "+N% AC" — `allyAcBonus` is applied as a % of Armor Rating (`game_state.dart:8254`).
- **Abilities** (`ability_upgrade_screen.dart` current + next-rank effect summaries; `inventory_screen.dart` & `unique_items_data.dart` item-granted extra-effects; `game_state.dart` battle-log buff lines ×3): `attackBonus`/`acBonus` now read "+N% DMG"/"+N% AC" (both are % effects since the ability rework).
- **Resistances** (`hero_stats_screen.dart`): Bonuses sheet cap corrected from "±75% max" to "±90% max (negated by enemy resist pen)"; the "at cap" ⬆ marker now triggers at ≥90%.
- **Not touched (deliberately):** alternate-mode combat screens (boss_rush/dungeon/gauntlet/guild) still label ability AC as flat — their armor calcs weren't migrated to the % model yet (existing known follow-up), so relabeling would misrepresent them. `ability_data.dart` milestone prose descriptions also still use the old flat values (pending value rebalance).

## +208 — Welcome Back popup: prominent CLAIM button
- `main_shell.dart`: the "Welcome back!" idle-rewards dialog had its CLAIM action as a small `TextButton` in the bottom-right corner — weak affordance for the modal's only action. Replaced with a full-width filled gold `ElevatedButton` (black text, letter-spaced) at the bottom of the content, and zeroed `actionsPadding`.

## +207 — Campaign screen UI polish
- **Energy bar** (`campaign_screen.dart`): split the cramped single row into two — Row 1 is `⚡ count + bar + "+1 in m:ss"`; Row 2 is the Refill and Buy actions as two equal-width buttons (only shown when not full), with clearer labels ("Refill +N (X free left)", "Buy 🪙 50") and larger text.
- **Milestone header** (`_StarProgressRow`): the bare low-contrast `10 25 50 100` numbers are now pill chips with three states — reached (filled gold), next (highlighted outline), upcoming (faint) — much clearer progress read.
- **Zone headers** (`_ZoneRow`): tightened name letter-spacing (1.5→1.0) so it ellipsizes less, and boosted the stage-range + modifier chip contrast/size (bold, larger padding) for legibility within the fixed 28px header.

## +206 — Clearer mercenary upgrade cost
- `npc_ally_screen.dart`: the upgrade button was a cramped "UPGRADE ◆20" (the ◆ shard glyph unlabelled). Now two lines — "UPGRADE" + "Cost: ◆ N Shards" (+ ZCoins if any) — and the insufficient-funds line reads "You have: ◆ N Shards", so it's obvious the upgrade spends shards.

## +205 — Flat damage reductions → Armor Class rating
- `game_state.dart` mitigation: the flat `flatReductions` subtraction (Iron Will −1, Juggernaut −1, Fortitude = CON node level, Thick Hide −3) is removed; those sources now add to `baseArmor` (the Armor Class rating) and run through the diminishing-returns DR curve like all other armor. Consequence: they now apply to physical only (via the rating) rather than flat-subtracting from elemental too — consistent with "armor is physical, resistances handle elemental." (Ships the +204 `kXpQuad 2.0 → 3.5` XP calibration too, which never installed.)

## +204 — XP curve calibration (kXpQuad 2.0 → 3.5)
- `hero_model.dart`: telemetry from natural tier-0 play showed a constant **~2.7 fights/level** (L18–40), extrapolating to ~3.4 months to L1000 at ~26 fights/day — too fast vs the 6-month target. Raised `kXpQuad` 2.0 → **3.5** (×1.75, mostly affecting high levels where the `level²` term dominates) to target ~6 months. Existing characters keep their level; only the next-level threshold rises. Tier-up XP boosts may still pull it faster — likely one more small bump after high-level data.

## +203 — Dev tool: Level +100
- `game_state.dart`: `debugAddLevels(n)` — jumps hero level by `n`, grants matching Paragon points, refreshes derived stats, tops up HP. `settings_screen.dart`: DEV TOOLS → "Level +100" button. For measuring high-level fights-per-level to calibrate `kXpQuad` toward the 6-month Level-1000 target.

## +202 — Objective beacon fires on kill; Level-30 ultimate coach
- **Objective beacon (combat_objective_beacon.dart / game_state.dart):** rewritten to be event-driven. Previously it *diffed* kill counts between rebuilds, but the enemy switches on kill, so `_lastKills` compared across different enemies → a false reveal at the next battle's start. Now `_fireObjectiveBeacon(enemy, questProgBefore)` runs in `_battleVictory` after the kill counters update, capturing the slain enemy's name/count (+ next milestone) and whether the active quest ticked; it bumps `beaconSeq`. The widget reveals only when `beaconSeq` changes and shows that payload — so it appears only after a kill earns a count, never at battle start.
- **Level-30 ultimate coach:** the level-30 class-questline unlock now fires a guided `SystemTutorial` (nav → Hero ▸ Quests) instead of the passive in-battle banner, telling the player the questline is how they earn their ultimate ability (retries until no other coach is showing).

## +201 — AC buffs → % Armor Class rating (abilities + mercs)
- `acBonus` ability buff now boosts the hero's **Armor Class rating by %** (`heroArmor = baseArmor × (1 + acPctBoost/100)`), then runs through the normal diminishing-returns DR curve — replacing the interim flat-%-DR from +200. Removed the mitigation-side flat reduction.
- **Mercenary AC bonus (`allyAcBonus`) is likewise now a % armor-rating boost**, not a flat add — folded into both the combat `heroArmor` and the central `heroArmorValue` (alongside subclassArmorPct). Updated hero-stats Armor Rating row (mercs shown as `+N%`, total applies the multiplier) and the merc-screen chip (`+N% AC`), plus ability/HUD/log labels back to "% Armor". (Other-mode inline armor calcs — dungeon/gauntlet/guild — still add it flat; follow-up.)

## +200 — Tier-scaled enemy resistances
- `enemy_data.dart`: enemy elemental resistances now scale with tier via `tierResistanceScale(tier) = (0.1 + 0.09·tier).clamp(0.1, 1.0)` applied in `_scaleResistances` (tier 0 ≈ 10% of the designed value, tier 10 = 100%; tier 10+ uses the full value). Wired into the campaign and abyss enemy builders. Fixes the fresh-character DPS-crater from the logs — a Tier-0 "poison 75%" enemy now resists ~7–8%, so a single-element hero isn't hard-countered early.
- `damage_pipeline.dart`: effective resistance (enemy resist − hero penetration) cap raised `0.75 → 0.90` — Tier-10 resistances bite harder, but no enemy is ever fully immune (you always deal ≥10%, mirroring the hero's 90% DR cap). Late-game penetration offsets the high end.
- `game_state.dart`: battle-log resistance display clamp `75 → 90` to match.

## +199 — Ability buffs: flat → % (attackBonus / acBonus)
- **`attackBonus` → % damage buff, and actually applied.** It was a *dead effect* — `_tempAttackBonus` was shown in the UI but never factored into damage. Now the hero's basic-attack damage is multiplied by `(1 + _tempAttackBonus/100)` while active. Values rebalanced flat→% (base abilities 4–10 → 30–50%, ults 50/100 read as +50/100%).
- **`acBonus` → % damage reduction.** Removed from the flat `heroArmor` rating (worthless at high armor); now applied as `resisted *= (1 - _tempAcBonus/100)` in mitigation, under the 90% DR cap. Values rebalanced (base 3–5 → 20–30% DR).
- Updated the effect-semantics doc, in-battle log text, and buff HUD / status labels (buff_hud, battle_split_panel, battle_screen) to read "+N% DMG" / "+N% DR". `bonusDamage`/`dot` were left as-is — they already scale through the full damage pipeline. (Milestone add-on buff values/descriptions still use the small numbers — a follow-up cleanup.)

## +198 — First-gear coach fires on the actual first drop
- `_battleVictory`: `_maybeTriggerGearTutorial()` now runs immediately after the equipment drop is added to the bag (line ~8656), instead of only at the end of victory *after* the stage-unlock coaches. The old placement + its `pendingTutorial != null` guard meant the gear coach kept deferring behind Scores/Abilities/etc. coaches while more items dropped, so it appeared several pieces late. Removed the redundant end-of-victory call.

## +197 — Fix: new character inheriting Stage 41 / unlocked systems
- `_resetToDefaults` set `campaignStageIndex = prestigeHeadStart` **before** `prestigeShop.reset()` (further down the method), so a new character read the *previous* character's `soul_overdrive` ("start at Stage 41") node and began at Stage 41 — which also revealed all hub tabs (they gate by stage). Now `campaignStageIndex = keepTutorials ? prestigeHeadStart : 0` — new characters always start at Stage 1; rebirth/ascension (keepTutorials) still apply head-start (tier-up head-start is handled separately at the final-boss handler). Note: an already-created broken character stays broken — delete & recreate to get a clean Stage-1 start.

## +196 — Difficulty rebuild step 2: XP curve + 90% DR cap
- **XP curve → quadratic.** `hero_model.dart`: `expToNextForLevel` was linear (`50 + 45·level`, ~22K at L500), far too shallow vs the (capped) per-fight XP → ~40 levels/fight at high level. Now `50 + 45·level + kXpQuad·level²` with `kXpQuad = 2.0` (the master 6-month-pacing knob). Level 1000 total goes from ~22.5M → ~700M XP. Existing saves keep their level; only the next threshold changes.
- **Removed the XP-per-fight caps** (`999,999 → 1e15`, both the live and batch paths) so the level curve — not a flat ceiling — controls pacing.
- **90% damage-reduction cap.** A maxed hero was taking 0 damage because stacked armor + resistance drove reduction ≥100% (resist could exceed 100%, making `resisted ≤ 0`). Added a floor: a landed hit always deals ≥10% of the raw roll (`finalDmg = max(mitigated, rawDamage·0.10)`), so no build is ever fully immune. (This is the one intentional cap — per direction.)
- Calibration next: measure real levels-per-fight from `ZBAL` telemetry on a normal character and tune `kXpQuad` toward Level 1000 ≈ 180 days at ~30 min/day.

## +195 — Difficulty rebuild step 1: enemy ATK scaling + uncap ceilings
- Top-down calibration from the maxed anchor exposed the true (unclamped) numbers: enemy ATK at Tier 10 ≈ **42 billion** (clamped to 1B), one-shotting even a maxed hero. `enemy_data.dart`: **`kAtkGrowth 6.0 → 2.0`** so enemy ATK tracks hero HP growth (~2.3×/tier) instead of `6^depth` exploding. Now ≈ ~200K at Tier 10 → ~6% of the maxed hero's HP per hit.
- Raised the enemy HP/ATK clamps (campaign + abyss) and the hero basic-attack damage clamps from `999,999,999` → `1e15`, so real scaling isn't artificially capped.
- Next steps: make the Max tool grant *realistic* max investment (200 paragon ranks etc. is unreachable), then compress the hero multiplier stack so peak numbers land in the millions.

## +194 — Max tool: elemental mastery, upgrades, abilities
- `debugMaxCharacter()` now also maxes **elemental mastery** (`_elementalMasteryRanks` → 50/element), **endless/tower upgrades** (`EndlessUpgrades.debugMaxAll()`, new — all nodes to 300, unlocking every milestone perk + synergy) and **abilities** (`_abilityRanks` → 60 for every class ability). Coverage now: tier, level, currencies, ability scores, passives, paragon, gear, pets, mercs, ascension, class + elemental mastery, upgrades, abilities, artifacts (runes excluded — temporary buffs).
- Added `upgradeMult` (endless-upgrades damage multiplier) to the ZPWR damage breakdown.

## +193 — Max tool: ascension/mastery/artifacts + ZPWR cleanup
- `debugMaxCharacter()` now also maxes **ascension** (`AscensionNode.all` → maxLevel), **class mastery** (`kMasteryCatalog` → maxLevel) and **artifacts** (unlock all 81 cells, roll 90 tier-10 artifacts, `autoEquipArtifacts()`). Runes left out (temporary/expiring buffs).
- Removed the retired `levelBonusDamagePct` from the ZPWR damage breakdown — it was intentionally retired earlier (no automatic per-level damage), so showing it as a live "level: 0" source was misleading, not a bug.

## +192 — "Max Character" dev tool (top-down balancing)
- `game_state.dart`: `debugMaxCharacter()` — maxes tier (10), level (1000), currencies, ability scores, the passive tree (`PassiveTree.debugMaxAll()`, new), paragon (200 ranks/stat + all prestige nodes), gear (mythic in every `ItemSlot`), pets (own all + equip), mercenaries (all at level 5), then jumps to `campaignStageIndex = 99` (Tier 10 final boss). Artifacts/runes/ascension/mastery not yet auto-maxed (visible as 0 in the ZPWR log).
- `passive_tree.dart`: `debugMaxAll()` sets every node (incl. elemental) to max rank.
- `settings_screen.dart`: DEV TOOLS → "Max Character" (MAX button) calls it.

## +191 — Remove all combat caps + power-breakdown telemetry
- **No caps:** raised every combat `9999`/`99999` clamp to `999999999` — hero base + pipeline damage, Blood Pact / affix damage tweaks, Wild Magic, Vulnerable re-cap (this was capping the Bard's every hit at 9999), Blade Flicker / Mastery multi-strike, Cael Warmaster bonus, ability & DoT damage (all elemental variants), thorn-wall reflect, challenge-modifier enemy ATK, the crit-damage stat getter, and all heals/regen. Also lifted `hero_model.dart` `maxHealth` cap 99999 → 999999999. Left reward/currency (souls/essence/shards/idle-XP) and stage-index clamps alone — separate economy concern.
- **Power breakdown telemetry:** `DebugLogger.power(jsonLine)` emits a `ZPWR|` line (capture via `adb logcat -d | grep ZPWR`). `_logPowerBreakdown()` (called from `_snapshotFight`) itemises every progression system's contribution to HP% (con/items/passives/subclass/trait/artifact/rune/mercs/prestige/endurance), flat HP (vit), damage% (passives/gear/sets/level/stat/elemental passive+gem+mastery/ascension/mercs/critReplace/paragonMult), flat damage (gear/str/mastery/quest/artifact/rune/score/pets) and armor (base/passives/gear/pets/skin/aura/artifact/rune/mercs/mastery/quest). Any source reading 0 flags a system that isn't contributing.

## +190 — Uncapped enemy/boss damage
- `game_state.dart`: the main enemy melee hit was already uncapped, but several other enemy→hero damage paths still carried the legacy `.clamp(…, 9999)` ceiling. Raised them all to `999999999` so boss/monster damage keeps scaling:
  - Weakened-enemy melee (the weaken debuff was re-capping damage to 9999).
  - Boss ability bonus-damage hit (+ its resistance step).
  - Boss ability damage-over-time (per-round), and the hero-side DoT tick that applies it.
  - Volatile Death on-death explosion.
  - Cursed Ground / Death Spiral affix drain (% max HP).
- The hero's own per-hit damage cap (9999) was intentionally left in place — it's what keeps boss fights multi-round instead of one-shot deletes.

## +189 — Paragon symbols + rebirth-node cleanup
- `paragon_icon.dart` (new): `ParagonIcon` CustomPainter drawing a distinct glyph per paragon stat — crossed swords (Might), heart (Vitality), target (Precision), flame (Ferocity), coin (Fortune), open book (Wisdom), four-point star (Eternal Flame) — styled to match `StatIcon`. Wired into the paragon board rows in `prestige_screen.dart` (replacing the emoji `stat.icon`).
- Removed the two Paragon/Prestige nodes worded around the deprecated Rebirth mechanic: `head_start` ("Veteran's Path — After rebirth…") and `head_start_2` ("Battle-Hardened — After rebirth…"). Un-chained their dependents (`instant_recall`, `soul_overdrive` → no prerequisite), trimmed the dead `prestigeHeadStart` checks, and removed the stale display chips in `hero_stats_screen.dart` / `prestige_screen.dart`. No ability or passive referenced rebirth. (`soul_overdrive`'s "start at Stage 41" node remains — it doesn't mention rebirth.)

## +188 — Tighter passive node cards
- `passive_tree_screen.dart`: the branch node row was a fixed `SizedBox(height: 155)` while the `_NodeCard` content is only ~100px, leaving ~50px of dead space under each card. Reduced to `120` so cards hug their content with a little breathing room.

## +187 — Balance telemetry (per-fight logging)
- `debug_logger.dart`: added `DebugLogger.balance(jsonLine)` — prints a `ZBAL|<json>` line to logcat (capturable in release via `adb logcat -d | grep ZBAL`) and mirrors to the debug file/Crashlytics.
- `game_state.dart`: `_snapshotFight` now also emits `_logBalanceTelemetry(enemy, victory)` — one compact JSON record per resolved campaign/endless fight: mode, tier, stage, boss, win/loss, rounds, hero level/maxHP/endHP/HP%/DPS, enemy name/level/HP/ATK, and fight totals (dmg/maxhit/hits). Wrapped so telemetry can never break a battle. No gameplay change.

## +186 — HP passives apply on rank-up
- `game_state.dart`: `maxHp` passive effect (Iron Skin, etc.) is cached into `hero.extraHpPct` via `_syncHeroHpPct()` rather than read live like every other passive. `upgradePassive`, `respecBranch`, and `fullRespec` didn't call it, so ranking/removing an HP node didn't change max HP until an unrelated resync fired (e.g. reload). Added `_syncHeroHpPct()` to all three. Audited the `PassiveEffect` enum: every effect used by a node is consumed live in combat/stat math; `critChance` is defined but unused by any node (no dead passives).

## +185 — HP fix (halve, don't remove)
- `hero_model.dart`: +184 set `maxHealth` base to a flat 100, which collapsed totals (e.g. a LV 125 hero fell to ~455 HP) because the per-level base is the term all gear/CON %HP multiplies — flattening it made %HP gear near-worthless. Restored a per-level base but **halved** it: `100 + (level-1)*10` (was `*20`). Heroes are meaningfully squishier (less automatic survivability from over-levelling) without being paper-thin.

## +184 — Over-level catch-up + level HP removal
- `enemy_data.dart`: added **over-level catch-up** — `enemyForStage` now takes `heroLevel`; when the hero out-levels an enemy, enemy **HP** scales by `1 + gap × kOverLevelStep` (0.03/level, capped at a 50-level gap → up to ×2.5). Applied to HP **only** (not ATK — enemy ATK already stacks bossAtkMult × the system steepener, so scaling it too would make frontier bosses one-shot the hero). Wired into the campaign and endless spawns (`heroLevel: hero.level`). An on-level hero (gap ≈ 0) is unaffected.
- `hero_model.dart`: **removed automatic per-level HP.** `maxHealth` base is now a flat `100` instead of `100 + (level-1)*20`; HP comes entirely from CON, gear (%HP + flat), passives and Paragon. This was the last piece of automatic per-level power (after the earlier removal of stat growth, the +1%/level damage, and the level-up full-heal) and a major reason over-levelled heroes were unkillable.

## +183 — Late-game difficulty II (bolder lethality + more HP)
- `enemy_data.dart`: live testing (a LV 77 hero in tier 1) showed the +182 ×2.87 steepeners were far too soft — enemies hit for ~3% of the hero's HP and died in 1–2 hits. Bumped both system steepeners:
  - `kSystemAtkStep` 0.11 → **0.22** (full-systems enemy ATK ×2.87 → **×4.74**, ~+65% lethality — the dominant fix for an over-levelled hero).
  - `kSystemHpStep` 0.11 → **0.195** (full-systems enemy HP ×2.87 → **×4.32**, the requested +50%).
- ATK pushed harder than HP on purpose: a tankier enemy that can't hurt you is tedious, not hard. Hero abilities/merc debuffs (e.g. Dissonant Chord −40% ATK) cushion frontier bosses. Rewards still key off `enemy.level`, unaffected.

## +182 — Late-game difficulty rebalance
- `enemy_data.dart`: added a **system HP steepener** mirroring the existing ATK one. Previously only enemy ATK scaled with unlocked progression systems; HP did not, so a level-20+ hero with the full DPS stack (pets/mercs/paragon/artifacts/passives) deleted enemies before they mattered — fights got shorter, not harder.
  - Renamed `kSystemSteepStep` → `kSystemAtkStep` (0.10 → **0.11**) and added `kSystemHpStep` (**0.11**) + `systemHpSteepener(tier, stage)`, applied to the campaign `hpValue`.
  - At the 17-system cap (stage 55+ in tier 0, and all prestige tiers): enemy **HP ×2.87** and **ATK ×2.87** (was HP ×1.0, ATK ×2.7). Ramps in gradually with system unlocks (e.g. ×1.88 at stage 20 / 8 systems), so early/tutorial stages are unaffected.
  - Rewards untouched — they key off `enemy.level`, not HP/ATK.

## +181 — Mercenary talent rebalance
- `npc_ally.dart`: the two talent pairs where both options were pure-damage (making the pick meaningless) now follow the roster's A-pure-specialist / B-hybrid convention.
  - Cael tier-1: Brutal Strikes `dmg 6→7` (pure); War Veteran `dmg 7 → dmg 4 + hp 0.10` (bruiser).
  - Greybeard tier-2: Warlord's Edge `dmg 12` (pure, unchanged value); Battle Master `dmg 10 → dmg 8 + ac 5` (defensive). Rewrote both B descriptions (were copy-pasted "Focused on raw damage.").

## +180 — Frame recolours the slot outline
- `character_select_screen.dart`: the equipped premium frame colour now recolours the whole slot's outer `Container` border (with a subtle matching glow) instead of drawing a border+glow around the sprite. `_framedSprite` reverted to a plain sprite; the sprite interior is unchanged.

## +179 — Character select tweaks
- Removed the `>` chevron and the delete-bin icon from occupied slots and reclaimed the right padding (44→18) for the name/info line.
- **Swipe-to-delete:** occupied slots are now wrapped in a `Dismissible` (`endToStart`) with a red "DELETE" reveal background; `confirmDismiss` shows the confirm dialog (`_confirmDeleteDialog`), `onDismissed` runs the delete + refresh (`_deleteSlot`). Removed the long-press-to-delete path. Footer hint updated to "Swipe a character left to delete".
- **Per-character cosmetics:** `CharacterSummary` gains `frameId` + `nameColorId` (parsed from each save's top-level `activeFrame` / `activeNameColor`). The select tiles now resolve frame/name colours from the slot's own summary (`CosmeticItem.frameColorFor(char.frameId)` / `nameColorFor(char.nameColorId)`) instead of the globally-loaded `game` — previously every slot shared the active character's cosmetics (or none if no slot was loaded). Live-slot patch passes `game.activeFrame` / `game.activeNameColor` through for the loaded slot.
- Name input `maxLength` 20 → 14 so names fit the select tiles without truncation.

## +178 — Character select polish
- `character_select_screen.dart`: removed the per-slot number and reduced the row's left padding (40→16) so long names (e.g. "The Warden", "Lanarion") stop truncating.
- Applied equipped premium cosmetics to each slot: the portrait **frame** (`CosmeticItem.frameColorFor(game.activeFrame)` → coloured border + glow around the sprite, via new `_framedSprite`) and **name colour** (`game.nameColor`). Passed both into `_SlotTile` from the builder.

## +177 — Loading-screen black fix + character portraits
- **Loading screen black-screen fix:** the tavern background (1536×2752, 2.3 MB) failed to upload as a GPU texture on-device — a raster-thread failure `errorBuilder` can't catch — blacking out the entire loading screen (and hanging the app there). Resized the on-disk `loading_bg.jpg` to 1080×1935 (~217 KB) and added `cacheWidth: 1080` + `filterQuality: medium` to the `Image.asset` as a safety cap against future oversized swaps.
- **Character select portraits:** `CharacterSummary` gains a `heroRace` field (parsed from top-level `heroRaceId` in the save). `character_select_screen.dart` now renders each occupied slot with the hero `BattleSprite` (class + gender + race) on the left, the name (with the race trait symbol/emoji beside it), and a `Race · Class · Level` line in the race colour — instead of just a gender symbol. Live-slot patch passes `heroRace` through too.

## +176 — Loading screen background art
- `loading_screen.dart`: added a painted tavern-hearth background (`assets/images/loading_bg.jpg`) as a `Positioned.fill` `Image.asset` with `BoxFit.cover`, behind the vignette. `errorBuilder` falls back to the dark base colour if the asset is missing. Added a top-and-bottom-darkening gradient scrim so the gold title and progress/flavor text stay legible while the hearth glow shows through the centre.

## +175 — Hero banner on Daily Login
- `login_streak_screen.dart`: added a `_HeroBanner` at the top of the Daily Login screen showing the hero `BattleSprite` (scaled via FittedBox), name, `Lv N • Class` line, and a race chip (icon + name in the race colour from `hero_race.dart`).
- The banner honours equipped premium cosmetics: portrait **frame** (`CosmeticItem.frameColorFor` → coloured border + glow), **name colour** (`game.nameColor`), and **title** (`CosmeticItem.titleColorForName`).

## +174 — Bonuses sheet cleanup
- `hero_stats_screen.dart`: `_damageTypeRows` no longer shows a per-type "Resistance %" (removed the `$res% RES` total and the Resistance source row) — resistances were already listed again in the dedicated RESISTANCES section. Damage Types now reads damage-only.
- Removed the "Post-battle HP Heal" row from `_survivalRows` (and its now-dead regen computation) since battles always start at full HP.

## +173 — Claimable dots on Challenges/Bounties
- `modes_screen.dart`: the CHALLENGES mode tab now shows its claimable badge when `hasClaimableDaily || hasClaimableWeekly || bossHuntsClaimable > 0`; the (stale) BOUNTIES case now uses `bossHuntsClaimable > 0`.
- `daily_screen.dart`: added a `_DotTab` widget so the DAILY / WEEKLY / BOUNTIES sub-tabs each show an amber dot when there's something to claim (Bounties keys off `bossHuntsClaimable`).

## +172 — Boss Bounties replace daily bounties
- Reworked the Bounty Board to show tier-appropriate **boss bounties** instead of the old daily kill-target bounties.
- `boss_hunt_data.dart`: `BossHunt` gains a `tier` field and tier-keyed `id` (tier 0 keeps the legacy `bosshunt_$stage` id so old claims persist). New `bossBountiesForTier(int tier)` generates a per-tier bounty set with scaled rewards — grind currencies (gold/shards/essence) ×`2^tier`, premium currencies (ZCoins/mythril) ×`(tier+1)`. Cached per tier.
- `game_state.dart`: added `bossBounties` getter (= `bossBountiesForTier(activeTier)`); `isBossHuntMet` now accounts for tier (met if bounty's tier is below the active tier, or reached past its stage in the active tier); `bossHuntsClaimable` counts over the active tier's bounties. Old daily-bounty machinery (`_dailyBounties`, `_trackBountyProgress`, `claimBounty`, save/load) left intact but no longer surfaced, to preserve save compatibility.
- **Guaranteed gear drop:** `claimBossHunt` now crafts an equipment item via `ItemLootTable.craftAt(slot, rarity, hero.level, rng, rebirthLevel: tier)` and adds it to the bag. `bossBountyLootRarity(BossHunt)` ramps rarity by boss ordinal (uncommon→rare→epic→legendary, final boss mythic) with each tier raising the floor one step (clamped to mythic). `lastBossBountyLoot` exposes the drop for the claim toast.
- `bounty_board_screen.dart`: rewritten to list the current tier's boss bounties with sprite + reward chips (leading with a "🎁 <Rarity> Gear" chip) + claim, plus a "TIER N" header. Claim toast names the looted item. Removed the daily-refresh/zone-banner UI.
- `quest_screen.dart`: removed the Boss Hunts section and `_BossHuntCard` (now on the Bounty Board).
- Bounty tutorial (stage 20) text updated to describe boss bounties; added a claimable badge to the home-screen Bounty Board button.

## +171 — Stagger Scores from Abilities
- Changed the SCORES tab unlock in `hero_hub_screen.dart` `_kAllTabs` from stage 1 → stage 4, matching its tutorial stage. Previously the Scores tab appeared silently at stage 1 (no coach) while Abilities got its coach at stage 2, so at stage 3 both tabs were visible but only Abilities had been introduced. Now Scores appears at stage 4 together with its coach — cleanly staggered.

## +170 — Stage-unlock coaches fire on any character
- Removed the `campaignStageIndex == campaignAllTimeHigh` gate from the stage-unlock tutorial trigger (kept `!_seenUnlockStages.contains(...)`). That gate blocked all stage coaches (Abilities/Scores/Passives/Bonuses/Bestiary/…) on any character that had ever pushed deeper before — and broke "Replay Tutorials" on progressed characters. Level-based coaches (Paragon, ability unlocks) never had the gate, which is why only Paragon fired. Now every unlock navigates + coaches the same way.

## +169 — Remove first-victory modal
- Removed the "FIRST VICTORY" intro dialog (`_showEndlessTutorial`) shown after the first kill and its trigger in the battle loop; `endlessTutorialPending` is now dismissed silently. The guided system tutorials cover onboarding. (Dashboard "First victory!" tip left intact.)

## +168 — Phased boss premium (fairer early bosses)
- Boss HP/ATK premium now phases in with depth instead of flat 2.5×/3.5× from stage 4. `bossPhase = ((stage-4)/21).clamp(0,1)`; `bossHpMult = 1.4 + 1.1·phase` (1.4→2.5), `bossAtkMult = 1.6 + 1.9·phase` (1.6→3.5), reaching full by ~stage 25.
- Sim (`tool/class_sim.dart`, updated to match): before, all 12 classes walled at stage 4 (arrive L3, need L11); after, the first boss is clearable and the first gentle wall is stage 9 (arrive L5, need L7 = +2 levels). Later bosses unchanged.

## +167 — Tutorials visible mid-battle (pop the battle route)
- Root cause of "coach/nav didn't show": the campaign battle is a route pushed on top of main_shell, but the coach overlay + tab navigation live in main_shell — so they ran *behind* the battle. `BattleScreen.build` now pops itself (once) when `game.pendingTutorial != null`, revealing the already-navigated system tab + coach. Auto-campaign was already paused by the tutorial.
- Added `GameState.debugResetTutorials()` (clears `_seenUnlockStages` + ability/paragon flags) and a "Replay Tutorials" DEV TOOLS tile in Settings.

## +166 — Level-ups grant only Paragon (+ reveal at L10)
- `HeroModel.levelUp()` no longer applies auto stat growth (removed the class primary/+2nd/+CON-per-3 grants and the now-unused `_primaryStat`/`_secondaryStat` maps + `_applyStat`). Levels now grant only a Paragon Point (`_syncParagonLevels`), the level-based HP/damage curve, and +1 energy.
- Paragon revealed at level 10: hero-hub `_unlockedIndices` gates PARAGON (index 10) on `hero.level >= 10` (was campaign-stage). New `_paragonTutorialSeen` (persisted) fires a coach on the level-up reaching 10 (takes priority over the L10 ability coach, which retries at L11). Points still accrue from level 1.

## +165 — Remove level-up full heal
- `HeroModel.levelUp()` no longer sets `currentHealth = maxHealth`. Redundant since every fight starts full (post-kill `healToFull()` at ~8699, battle-start at ~7418); only effect was a free heal on a mid-fight level-up.

## +164 — Next-action nav + passive badge fixes
- `_SmartNextActionPanel` ability/passive/endless actions now gated so they only appear when their hero-hub tab is reachable (`effectiveUnlockStage >= 2` / `>= 8` / `upgradesTabUnlocked`). Before, they could show pre-unlock and `switchTo()` had no visible tab → tap did nothing.
- `hasAffordablePassiveNode` now skips other classes' `classOnly` nodes (`n.classOnly == null || n.classOnly == hero.heroClass.name`). Those aren't shown on the hero's passive screen, so counting them left a stuck Hero/Passives badge with nothing to buy.

## +163 — Login reward preview off-by-one fix
- Preview (dashboard) computed the day as `(loginStreak % len) + 1` while claim used `((loginStreak - 1) % len) + 1` → new char (`loginStreak = 1`) previewed Day 2 but granted Day 1. Added `GameState.loginRewardDay` getter (the claim formula) as the single source of truth; claim + dashboard preview now both use it. Home screen "Tomorrow:" preview unchanged (correctly shows the next day).

## +162 — Non-skippable tutorials + ability-unlock coach + richer gear
- Tutorial state refactored from `int? pendingTutorialStage` → `SystemTutorial? pendingTutorial` (holds the object, so dynamic coaches like ability unlocks work). `_triggerTutorial(t)` centralizes pause; dismiss resumes.
- **Non-skippable:** overlay moved from the Scaffold body Stack to wrap the whole Scaffold (covers the bottom nav too) + an opaque `GestureDetector` absorbs taps outside the card. Only GOT IT dismisses.
- **Ability-unlock coach:** `_maybeTriggerAbilityTutorial()` fires on level-up at 5/10/15/20/25 (persisted `_lastAbilityTutorialLevel`), navigating to ABILITIES with a dynamic tutorial naming the level.
- **Gear coach** copy now explains manual tap-to-equip *and* AUTO EQUIP.
- main_shell nav guard `_navDoneForStage` → `_tutorialNavDone` (bool). Persist `lastAbilityTutorialLevel`.

## +161 — Stagger Scores tutorial
- Moved the Scores `SystemTutorial` from stage 1 → stage 4 so it no longer fires back-to-back with Abilities (@2) on a fresh character. Order is now Abilities then Scores; the Scores tab itself is still visible from stage 1.

## +160 — Beacon rows gated on change
- Combat beacon now tracks `_showBestiary`/`_showQuest`, set on each reveal to the counter(s) that just incremented (`killsUp`/`questUp`). Each row renders only if its flag is set, so a row never appears at a static value — only when it ticks up. Replaces the previous "quest row if qProg > 0" gate.

## +159 — Starter tutorials (Scores, Abilities, first Gear)
- Added `SystemTutorial` entries for Scores (stage 1) and a first-item Gear coach (`gearStage = -1`, navTab 2 → GEAR).
- Tutorial stage-trigger decoupled from `_unlockStageNames`: now fires for **any** stage that has a `SystemTutorial` (so always-on early tabs Scores@1 / Abilities@2 also coach), while notices still only fire for gated unlocks.
- `_maybeTriggerGearTutorial()` fires the Gear coach the first campaign kill where the player owns any item (bag or equipped), guarded by `_seenUnlockStages` + deferred while another tutorial shows. Called each campaign kill resolution.

## +158 — Guided system tutorials (pause + navigate + coach overlay)
- New `SystemTutorial` table (`data/system_tutorials.dart`) maps each unlock stage → nav tab + sub-tab label + icon + how-to blurb (17 systems, stage 2–100).
- `GameState`: on unlock (`_unlockStageNames` block) sets `pendingTutorialStage` + pauses `autoCampaign` (remembers to resume). Added `dismissSystemTutorial()` (resumes auto) and `consumeNavRequestFor(labels)` + `navRequestSubTab` for sub-tab deep-linking.
- `main_shell`: on `pendingTutorialStage`, post-frame sets `_tab` to the system's nav tab and `navRequestSubTab` to its sub-tab; renders `_SystemTutorialOverlay` (dim scrim + coach card + GOT IT → dismiss/resume).
- `hero_hub` / `inventory_hub` / `modes_screen`: each consumes `navRequestSubTab` in build and `animateTo` the matching sub-tab (labels: hero `_kAllTabs`, inventory `_labels`, modes `_tabData.$1`).

## +157 — Progression-system difficulty steepeners
- Enemy ATK now scales with the number of unlocked progression systems: `systemAtkSteepener = 1 + 0.10 × systemsUnlockedBy(tier, stage)`. Systems unlock at campaign stages `[2,5,8,10,12,15,18,20,22,25,28,30,35,40,45,50,55]` (mirrors `_unlockStageNames`); past tier 0 all are unlocked (steepener maxed at ~2.7×, continuous across the tier boundary since it also maxes by stage 55 in tier 0). Applied to ATK only so kill/XP pace (HP) is unchanged. Knob: `kSystemSteepStep` (0.10).

## +156 — Poison color darkened
- `DamageType.poison.color` 0xFF7DCF6A (light green) → 0xFF4E8B2C (dark toxic green) so poison damage floats/labels no longer read like the bright heal green (0xFF44ee88).

## +155 — Beacon hides not-started quests
- Combat beacon quest row now gated on `qProg > 0` (in addition to the met-skip). "Into the Depths" (`condition: dungeonClears, target: 1`) surfaced as the current quest during campaign fights but stayed 0/1 since campaign kills don't advance dungeon clears — showed a bar that never moved. Now a quest only appears once you've made progress on it.

## +154 — Quests moved to Hero tab
- Removed QUESTS from `modes_screen` (`_tabData` + renumbered `_screenFor`, dropped the now-unused `quest_screen` import). Added QUESTS to `hero_hub_screen` `_kAllTabs` (appended index 15, unlock stage 10) + `_buildScreen` case 15 → `QuestScreen()`. Appended to keep the index-based screen map stable; shows as the last Hero tab (position tunable). QuestScreen keeps its own scaffold/CLAIM-ALL header nested in the hub.

## +153 — Beacon skips completed quests
- `currentAdventureQuest` (combat beacon source) now also skips quests that are met-but-unclaimed (`isAdventureQuestMet`), not just claimed ones. A finished quest like "First Kill" (1/1) no longer pops up in the battle beacon; since quests unlock sequentially it returns null until you claim, so the beacon just shows the bestiary row until then.

## +152 — Strict inventory tab staging
- Inventory hub `_unlockedIndices` no longer opens tabs early via "…OR you own the drop" clauses. Now purely campaign-stage-gated: Forge≥5, Artifacts≥22, Armory≥28, Runes≥30 (was drop-gated with no stage), Gems≥50; Gear always. Fixes a fresh character seeing Artifacts/Runes/Gems tabs the moment a drop landed, before their intended stage. (Hero tabs and PLAY modes were already strict for non-endgame characters.)

## +151 — Difficulty bump (attack + bosses)
- Playtest (fresh char, ~stage 21, no upgrades) had no challenge. Raised enemy attack: `kRefAtk` 5→7 and `kAtkGrowth` 4.6→6.0 (steeper ramp so attack keeps pace with the leveling hero instead of falling behind within a tier). Boss attack premium `bossAtkMult` 2.2→3.5. HP untouched (kill/XP pace unchanged). All still tunable.

## +150 — Continuous Tier Difficulty (campaign rescale)
- **Problem:** campaign enemy base stats grow ~250× HP / 165× ATK from stage 0→99 within a tier (skeleton 100 HP → the_omega 25,000 HP), but the tier-to-tier multiplier only stepped ~1.9×. So a new tier reset to weak stage-0 enemies × a small tier bump = a ~130× difficulty **dip** at each tier boundary.
- **Fix:** campaign `enemyForStage` now scales HP/ATK off a single continuous curve `ref × growth^depth`, where `depth = prestigeLevel + stage/kCampaignLength`. Because depth is continuous, tier N stage 99 ≈ tier N+1 stage 0 — no dip — and it keeps rising. Dropped `lateRamp` (it reset per tier → attack dip); kept `intraRamp` (resets to 1.0 at bosses and stage 0, so continuous across the boundary) + boss HP/ATK premiums.
- Separate growth rates: `kHpGrowth=3.4` (HP kept killable under the ~1e9 hero damage cap through tier 10 ≈ 1.8e8) and `kAtkGrowth=4.6` (ATK paced to keep threatening the scaling hero). `kRefHp=160`, `kRefAtk=5` anchor tier-0 stage-0. All four are tunable difficulty knobs.
- Note: this **flattens the within-tier ramp** (mathematically required — the old 250×/tier ramp can't extend across tiers without exploding past the damage cap) and no longer uses per-enemy base HP/ATK for campaign magnitude (enemy identity/level/resistances/attack-type unchanged). Abyss branch (stage ≥ 100) still uses the old tier multipliers — separate endless mode. Expect to tune `kHpGrowth`/`kAtkGrowth` from playtest.

## +149 — Combat Objective Beacon
- New `CombatObjectiveBeacon` widget injected into `BattleArena`'s Stack (top-right, `Positioned`), so it appears in every mode that uses the shared arena (campaign / gauntlet / dungeon). Hidden by default; fades+slides in for 4s whenever the current enemy's bestiary kills or the active adventure quest's progress ticks up, then fades out. Shows two mini progress rows (enemy → next bestiary milestone; active quest → target).
- Added `GameState.currentAdventureQuest` (first unlocked-unclaimed quest) and `nextBestiaryMilestone(enemyId)` getters to feed it. No new save state.

## +148 — Artifact Upgrade Data Fix + Header Layout
- **Data bug:** `upgradeArtifact` rebuilt the `Artifact` without `rarity`/`setId`/`setPieceIndex`, so the constructor defaulted rarity→`common` and setId→null. Every upgrade silently downgraded rarity and stripped set membership; the +147 best-first sort then re-ranked it to the bottom, so it looked like the item vanished. Now preserves `rarity`, `setId`, `setPieceIndex`. (Already-upgraded artifacts can't be retroactively restored — the old rarity wasn't stored.)
- **Layout:** Artifact Table header was overflowing (mythril badge clipped off-screen after the SALVAGE button was added). Split into two rows — title/slots/mythril on top, AUTO-EQUIP/SALVAGE buttons below.

## +147 — Artifact Collection Sorted Best-First
- Extracted the auto-equip ranking into `GameState.artifactRankScore(a)` (rarity×1e6 + statSum×100 + dropLevel) and added `artifactsRankedBest` getter. The Collection list now renders `game.artifactsRankedBest` instead of raw `ownedArtifacts` insertion order, so the strongest/most upgrade-worthy artifacts show at the top. Auto-equip reuses the same shared score.

## +146 — Salvage All Unequipped Artifacts
- New `GameState.salvageUnequippedArtifacts()` (+ `unequippedArtifactCount` / `salvageAllMythrilValue` preview getters) removes every owned artifact not on the grid, awarding `forgeCost×0.33` mythril each (same rate as single disenchant). Refactored the shared per-artifact value into `_artifactSalvageValue`.
- Artifact Table header now has a "♻ SALVAGE" button next to "⚡ AUTO" — disabled when nothing is unequipped, shows a confirm dialog (count + mythril) before destroying, then a result snackbar.

## +145 — Remove Dungeon Affixes + Auto-Run in Top Bar
- **Affixes removed:** `startDungeon` now sets `activeDungeonAffix = null` (was `rollDungeonAffix()`), so all affix effects resolve to neutral (HP/heal ×1.0, no burn/shield/toxic) and no affix banner shows. Removed the affix banner + reroll UI from the lobby. (Affix data/getters/reroll methods left in place, dormant.)
- **Auto Run moved to the AppBar:** the old inline lobby button was gated behind `dungeonHighestTier >= selectedTier` (hidden until you'd cleared the tier) and absent once a run started. Replaced with an icon button in the AppBar actions next to the leaderboard, shown whenever `run == null || run.isOver`; premium-gated (autorenew when subscribed, lock otherwise). Removed `autoRun`/`onToggleAuto` from `_DungeonLobby`.

## +144 — Premium Auto-Dungeon (random junctions, run-until-death)
- Dungeon Auto Run is now gated behind `game.hasPremium` (`_toggleAuto` blocks + snackbars non-subscribers; lobby/summary buttons show a lock + "PREMIUM"/🔒).
- Junction picks are now **random** instead of heuristic/`.first`: doors (`roomChoices[_rng.nextInt(...)]`), relics, and shrine blessings all roll randomly (added a `Random _rng` to the screen state).
- Auto Run now **stops on defeat**: on `run.isOver`, if `isDead`/`isAbandoned` it turns auto off; only a successful clear (`isCleared`) auto-starts the next dungeon and continues.

## +143 — Gauntlet Essence Rework + Sticky Modifiers
- **Essence formula:** was `kills × (5 + Σ flatShardBonus) × tierMult × rebirthMult`. Now `kills × (5 × tierMult × rebirthMult) × (1 + Σ modifierPct/100)` — tier/rebirth set a progressive **flat** soul income per kill, modifiers scale it by a **%**.
- `ChallengeModifier.rewardShardBonus` (flat int) → `rewardPctBonus` (% int): Veteran 2→15%, Berserker 3→20%, Glass Hero 4→25%, Ironclad 5→30%, Nightmare 8→50%. Updated modifier-card label ("+X% essence") and reward preview.
- **Sticky modifiers:** new persisted `GameState.lastGauntletModifierIds` (saved/loaded, set in `_startBattle`). Gauntlet `didChangeDependencies` pre-selects the last-used set by default. Auto-repeat no longer randomizes — it keeps your chosen modifiers (removed `_pickRandomModifiers`, updated the auto banner text).

## +142 — Combat & Ally Overhaul
- **Heal cooldown +2:** `scaledAbilityCooldown` adds a +2 surcharge when `ability.effect == AbilityEffect.heal` (applied to baseCd before build cooldown-reductions). Heals were still too frequent even after the magnitude nerf.
- **Boss attack premium:** bosses used the regular-enemy `atkMult` but with `intraRamp = 1.0`, so they hit *softer* than the ramped trash before them (playtest: Null Sovereign L180 "HIT 11.8K" but Synthes sat at full 12.3K HP). Added `bossAtkMult = 2.2` into `atkMult` for boss stages. Also raised the enemy attack clamp 99999 → 999999999 (was capping high-tier bosses).
- **Aura/timed-effect cooldown +2:** `scaledAbilityCooldown` adds +2 for `aura`, `attackBonus`, `acBonus`, `debuffWeaken`, `debuffVulnerable`, `missChance` effects. At base cooldown 3 a duration-3/4 buff sat at ~100% uptime, making its duration-extending milestones dead picks. Now base duration leaves a downtime gap so extending duration meaningfully raises uptime. (Hero ability cooldowns are role-based via `scaledAbilityCooldown`, not the vestigial `cooldownRounds` data field — that only feeds boss abilities.)
- **Mercenary damage → single % stat:** allies/talents/synergies had both flat `atkBonus` (+ATK) and `dmgBonus` (+DMG) — functionally identical and worthless once heroes hit for thousands. Replaced both with one `dmgPctBonus` (% increased damage) that feeds `allDamagePct` (the `×(1+pct/100)` pipeline) at all 5 combat sites + `heroAllDamagePctFor`. Removed the flat ally terms from `heroFlatDmgBonus` / baseDmg / DPS-estimate. Updated ally/synergy summaries, hero-stats breakdown, and ally screen to show "% Damage". Converted each old flat value 1:1 to a percent; merged the one synergy that had both (War Veterans atk3+dmg3 → 6% dmg).

## +141 — Heal Ability Nerf (the real regen culprit)
- Playtest (Synthes L177, Tier 2 boss The Void God, 10.2K hits vs 12.1K HP) showed a green **+7.3K heal** (~60% max HP) keeping her topped up — an *ability* heal, not lifesteal/flat regen.
- Burst heal multiplier 0.5 → 0.30 across all three `AbilityEffect.heal` handlers (`maxHealth·sv/100·healBoost·0.30·fatigue`); ~60% max HP → ~36% first cast, diminishing with heal-fatigue.
- The third heal handler (5842) had **no heal-fatigue** — added `pow(0.85, _healsThisBattle)` + increment so repeated casts diminish like the others.
- Aura heal-over-time (`_auraHealPerRound`, 3 sites) ×0.5 — it healed full sv% of max HP per round for several rounds with no fatigue.

## +140 — Lifesteal Nerf
- Reduced lifesteal, the last big un-nerfed sustain source: Life Steal keyword 10%→4%, Fiend Pact subclass 20%→8% (other data-driven/mastery/aura lifesteal unchanged). Lifesteal stacks across sources and scales with damage dealt, so damage builds (e.g. Synthes) healed back everything each round and sat at full HP against level-matched enemies.

## +139 — Steeper Tier Ladder
- Increased the per-tier "challenge ramp": `tierHpMult = (1+0.45t)²·(1+0.45t)` (HP ramp 0.25→0.45, effectively cubic) and `tierAtkMult = (1+0.45t)²·(1+0.30t)` (ATK ramp 0.14→0.30). Enemies now ~2× tankier and ~1.8× harder-hitting each tier: t3 ≈ 13× HP / 10.5× ATK, t10 ≈ 166× HP / 121× ATK. Tiers were progressing too flatly.

## +138 — Resistance Cap 50% + Steeper Enemy ATK
- Hero elemental resistance cap 75% → 50% (`heroResistancePct.clamp(-75, 50)`). 75% was a 4× reduction that stacked multiplicatively with dodge (37.5%) and regen → ~15% effective incoming. Enemy resistances (to your damage) unchanged at 75%.
- Enemy ATK tier scaling raised: `tierAtkMult = (1+0.45t)²·(1+0.14t)` (was `(1+0.4t)²·(1+0.08t)`), so higher tiers land meaningfully harder hits.

## +137 — Sustain Nerf (You Can Die Now)
- Aura flat regen coefficient cut ×10 → ×3 (`auraHpRegen * 3` per turn) — it was still offsetting most incoming damage.
- Battle Scarred: 5%/8% max HP per hit → 3%/5% (it's a % of your now-larger HP pool, so it scaled up hard). Together these let enemies grind you down over a long fight instead of you out-healing them. (User feedback: killing bosses fine, but hardly dying.)

## +136 — Dodge & Armor Rating System
- Dodge and Armor are now diminishing-returns **ratings** capping at `kDefenseCapPct` (37.5%): `%_benefit = 37.5 × rating / (rating + K)` with `kDodgeRatingK=50`, `kArmorRatingK=100`. Stacked sources (auras sum across the whole owned collection) can no longer reach 100% dodge / immunity. Added `heroDodgeRating`, `effectiveDodgePct`, `armorDrPctFor()` getters; combat + Hero Stats + stats-grid now use them and show **rating + actual %**.
- Armor changed from flat subtraction (`rawDamage - heroArmor`) to a % DR rating on physical damage (elemental still uses resistances, capped ±75%). Battle-log armor tag now shows `%`.
- Removed the hard 9,999 per-hit damage cap on both sides (hero `calculateDamage`+prestige, enemy `rawDamage`/`finalDmg` → up to ~1B). The old cap made tier-scaled enemy ATK unable to dent large HP pools.
- Enemy damage roll changed from `nextInt(attack)+1` (uniform 1..attack, often a whiff) to 70–100% of attack for consistent threat.

## +134 — Endurance, Wrath & Flat-Regen Rework
- Ability score `agi` renamed **Endurance** (END) — now grants **+2% max HP/rank** via `_syncHeroHpPct` (removed from `critReplacementDamagePct`). A tank/high-HP progression path.
- Ability score `prc` renamed **Wrath** (WRA) — keeps **+0.5% all damage/rank** (name now fits the effect). Keys stay `agi`/`prc` for save compat; only display names/icons/effects changed.
- Reverted the +5% aura-regen hard cap. Aura HP regen is now a **flat heal** (`auraHpRegen × 10` per turn) instead of `maxHealth × auraHpRegen/100` — so as you build max HP (Endurance/tiers) it becomes a smaller %, giving modest sustain and tense near-deaths instead of immortality. Pet/skin regen were already flat. Coefficient (×10) is the tuning knob.

## +133 — Aura Regen Fix
- Fixed Aura HP regen being game-breaking: `_sumOwnedAuraBonus(hpRegen)` sums across ALL owned auras and the combat code heals `maxHealth × auraHpRegen/100` EVERY turn (the old "flat +HP after victory" was silently redesigned into "% max HP/turn" but kept the same values + owned-sum). Full collections hit ~50%/turn (~4K/round on a 7.8K-HP hero → near-immortal). Capped `auraHpRegen` to +5% and fixed the misleading item description. Pet/skin hpRegen were already flat (fine).

## +132 — Tiers Get Progressively Harder
- Removed the free `levelBonusDamagePct` (+10% per 10 levels) — it was the dominant auto-scaler that let heroes trivialise every tier. Field forced to 0 on load (existing characters lose it), increment removed, UI "Level milestone" rows dropped. Hero power now comes from stats/gear/Paragon/passives.
- Re-derived enemy scaling for the new (~halved) hero damage growth AND added a challenge ramp so enemies OUTPACE the hero as you climb: `tierHpMult = (1+0.45t)²·(1+0.25t)`, `tierAtkMult = (1+0.4t)²·(1+0.08t)`. Tier 1 ≈ approachable, Tier 10 ≈ ~2.8× the effort of Tier 1. Simulation-calibrated (hero damage without level bonus ≈ 29× by Tier 10; HP mult matches ×challenge-ramp). Knobs: the 0.25 (HP ramp) and 0.08 (ATK ramp).

## +131 — No More First-Kill Tutorial for Veterans
- The first-kill tutorial (`endlessTutorialPending`, triggered on `campaignStageIndex == 0`) no longer re-triggers after you've unlocked a tier — gated `wasFirstKill` on `highestUnlockedTier == 0`, since the campaign resets to stage 0 on every tier-up. The inline `firstKill` TutorialTip was already suppressed by the `highestUnlockedTier > 0` gate.

## +130 — Difficulty Rebalance: Tiers Stay Challenging
- Enemy HP/ATK now scale QUADRATICALLY per tier via `EnemyData.tierHpMult` `(1+0.6·tier)²` and `tierAtkMult` `(1+0.45·tier)²`, replacing the old additive `(1+0.15t)(1+0.20t)` layers. Reason: hero damage grows ~quadratically with level (base × the +1%/level bonus) and gains ~68 levels/tier, so enemies were only ~7.5× HP at Tier 10 vs ~72× hero damage — high tiers were trivial. HP now tracks hero damage growth, ATK tracks hero HP growth. Consolidated into `enemyForStage` (campaign + abyss + tower boss); removed the redundant campaign-block HP/ATK layer (kept its AC bonus + high-tier ⚔ mark). Tuned slightly conservative (undershoot) so tiers are never impossible.

## +129 — Tier Progression Rewired
- Fixed content stuck behind the retired rebirth system: a mercenary (was "Reach Prestige 1"), two achievements (Ascendant / Tier Climber), and shop/forge/login/event loot quality now unlock and scale with `highestUnlockedTier` instead of the frozen prestige count.
- Permanent gold/XP/idle/damage multipliers now scale with your highest unlocked Tier (were per-rebirth), stacking with the Paragon board. Leaderboard "Legacy" stat factors tier too.
- Fixed `endgameUnlocked` so Boss Rush / PvP / Gauntlet / etc. no longer re-lock when the campaign restarts at a new tier (it keyed off the frozen prestigeLevel), and removed the `prestigeLevel > 0` guards that stopped Tier/Paragon damage from applying to never-rebirthed heroes.
- Head-Start and Instant Recall Paragon nodes now apply on each tier-up campaign restart (were tied to rebirth). `first_rebirth` analytics flag keys off tier.
- Boss Rush / Gauntlet / Guild: fixed the frozen `prestigeLevel > 0 ? prestigeDamageMult : 1.0` damage guard (Tier/Paragon damage now applies), decoupled their enemy stats from the global tier (they double-dipped on top of their own tier), scaled rewards with `highestUnlockedTier`, and submit `leaderboardRebirths` (tier-based) to the boards.
- Removed the now-redundant Mythril Memory and Artifact Vault Paragon nodes (Mythril & artifacts are always kept now). RebirthCosmetic/RebirthBoon models remain dormant/unused.

## +127 — Crit Is Now a Gear Specialization
- Crit Chance and Crit Damage now come ONLY from gear: attack-bonus & dexterity affixes on equipped items and set bonuses, plus the Critical Fury item keyword (3× base) and the overflow recycled from >100% gear crit chance. Removed crit from ~13 other sources.
- Everything that used to grant crit now grants % All Damage instead: Slayer passive nodes (Keen Edge, Sure Strike, Weapon Master), Precision & Agility ability scores, Iron Grip / Keen Edge / DEX echo perks, Champion & Assassin subclasses, and the Precision & Ferocity Paragon stats. Existing ranks are preserved and simply convert to damage.
- Crit builds now come from choosing crit gear — a deliberate specialization instead of a stat you accrue everywhere.

## +126 — Dungeon Boss Rebalance
- Fixed dungeon enemies (especially floor bosses) being over-tuned — they were double-scaling with both the dungeon tier AND the global campaign tier (the tier rework layered `activeTier` onto enemy stats on top of the dungeon's own `_tierMult`). Dungeons now scale only by the selected dungeon tier and floor. At campaign Tier 4 that drops dungeon enemy HP ~44% / ATK ~33%. Rewards and loot rarity still scale with your campaign tier.

## +125 — Rebirth References Cleaned Up
- Removed the old "Rebirth" wording across the live UI now that difficulty Tiers drive progression — campaign, codex, hero stats, tooltips, currency sources and quest text now refer to Tiers and Paragon Points. (Historical notes, earned title/achievement names and the retired backend are untouched.)
- Fixed the fight button dead-ending for characters left at the old post-stage-100 Abyss (rebirth was hidden with no way out) — the campaign now loops cleanly per tier, and stuck saves auto-repair on load.
- Fixed high-tier gear that could not be equipped and ability rank-tiers that were stuck — both now follow your unlocked Tier instead of the retired rebirth count.

## +123 — Gold Scaling Fix
- Fixed gold rewards ballooning at high tiers after the enemy-level rebalance. Gold now scales a sensible +15% per tier (matching enemy stat scaling) instead of tracking the tier-inflated enemy level — higher tiers still pay more without breaking the economy.

## +122 — XP & Enemy-Level Rebalance
- Enemy levels now scale with your difficulty Tier (base + tier×68) so they keep pace with your hero as you climb — a Tier 3 hero (~L200) fights ~L190 enemies instead of trivial low-level ones. Campaign stages themselves are unchanged.
- The XP curve is now linear (50 + 45×level) so levelling stays steady into the hundreds with no cap — each tier adds ~65-70 levels; a first campaign clear lands ~L50-60.
- Enemy level only affects XP / gold / loot-level / the displayed number — combat difficulty (HP/ATK) still comes from the tier stat multipliers, so higher-level enemies never become unbeatable.
- Existing heroes are re-tuned to the new curve on load; under-levelled characters catch up quickly (being "under" the enemy level just means more XP per kill).

## +121 — No More Resets: Climb the Tiers
- MAJOR: Rebirth no longer wipes your progress. Clearing the campaign (defeating the Omega) unlocks the next difficulty Tier and restarts the campaign at that harder tier with better loot — your Level, Paragon, gear and currencies all carry over. Climb up to 10 tiers.
- Paragon Points are now earned by levelling up (1 per level) instead of only from rebirth; spend them on the Paragon board any time.
- No level cap — keep levelling and pouring points into Paragon.
- The Rebirth and Ascension screens are hidden for now while the new progression settles in (a reworked Ascension path is coming). Existing rebirthed characters keep the tiers they already earned.

## +120 — Tier-Linked Ascension & Magic Find
- Ability Ascension is no longer locked behind Ascension Points — you can now ascend each ability up to your highest unlocked difficulty Tier (one Tier per rebirth), for free. Fixes not being able to ascend abilities after rebirthing.
- The Difficulty Tier picker now shows the Magic Find bonus each tier grants (+3% increased rarity per tier — better gear, sets and artifacts).
- Tutorial tips no longer appear once you've cleared Tier 0 (rebirthed at least once).

## +119 — XP Rebalance & Specialization Fix
- XP now scales so your hero level keeps pace with the campaign — you'll reach the final boss around Level 55–65 instead of stalling in the low 30s. Existing characters are re-tuned to the new curve on load, so under-levelled heroes catch up fast.
- Fixed Specialization (the Level 50 choice) silently doing nothing when tapped — it now clearly tells you it unlocks at Level 50, which the XP fix makes reachable within the campaign.

## +118 — Difficulty Tiers Replace Hard Mode
- NEW Difficulty Tiers: every Rebirth unlocks a tier (up to 10). Tap the slider icon in the Campaign header to switch tiers any time.
- Higher tiers make ALL PvE (Campaign, Tower, Dungeons) tougher but drop noticeably better loot — higher rarities, more sets, and rarer artifacts. PvP and Guild are unaffected.
- Switching to a LOWER tier keeps every permanent rebirth buff — it only scales the enemies and loot you face, so you can farm comfortably.
- Hard Mode has been removed and replaced by the tier system.
- Leaderboard rankings now factor in your highest unlocked tier and campaign clearance.

## +117 — Ability Upgrades & Tower Auto-Clear
- Every ability upgrade now does something: utility abilities (Stun, Silence, Dodge) shorten their cooldown as you rank them, and ascending them adds duration.
- Disarm and other max-strength debuffs no longer waste upgrades — extra power now spills into a Vulnerability debuff (enemy takes more damage).
- PREMIUM: New "Auto-Clear All Bosses" button on Tower Ascension battles through every available boss for you.
- Tower Ascension boss rewards now show the correct Tower Shard payout instead of misleading numbers.

## +116 — Arcane Dust Fix & Polish
- Fixed disenchanting most gear giving no Arcane Dust — every rarity now yields Arcane Dust, scaling up with rarity.
- The Gems screen now explains how to get Arcane Dust.
- The Dungeon now shows the 3-2-1 countdown before battle.
- Renamed the two "Endless Mode" quests to Tower Ascension.

## +115 — Artifacts Reforged: Six Rarities
- Artifacts now use the same six rarities as gear (Common → Mythic) and roll much rarer at higher difficulty — climbing tiers massively boosts your odds of Epic/Legendary/Mythic artifacts and Set pieces.
- Higher-rarity artifacts are strictly stronger (rarity now multiplies their stats on top of level scaling).

## +114 — Boss Hunts
- New Boss Hunt quests on the Quests screen — slay each campaign boss for a one-time bounty (gold, shards, essence, and a title for the final boss). They tick off automatically as you climb the campaign.

## +113 — Account-Wide Purchases & Tower Fixes
- Subscriptions and real-money cosmetics/pets are now account-wide — shared across every character and preserved through rebirth. (Restores a lost subscription on next launch.)
- Fixed the Echoes Upgrades being wiped on rebirth/ascension — they are now truly permanent per character as stated.
- Tower Ascension bosses no longer use a tier — you fight them at their campaign difficulty, gated by how far you've climbed the campaign.
- Tower Ascension now shows the 3-2-1 countdown before battle like the other modes.

## +112 — Clearer Long-Away Message
- When you've been away longer than the 8-hour idle cap, the welcome-back dialog now says "away for more than 8h — showing the maximum idle rewards" instead of a misleading exact time.

## +111 — Accurate Offline Time
- Fixed "time away" being wildly under-counted (e.g. showing 22m after hours). The idle and autosave timers now pause while the app is in the background, so away time is measured from when you actually left — and idle earnings are granted once on return instead of double-counted.

## +110 — Daily Rewards Survive Rebirth
- Fixed a bug where rebirthing (or ascending) reset your Daily Challenges, daily chest, login streak and daily attempt limits. These are calendar-day based and now persist through a rebirth — they only reset on a new day or a brand-new character.

## +109 — Zeta Absolute Final Boss
- The final boss is now "Zeta Absolute" with a brand-new hand-drawn sprite modelled after the Zeta Idle icon — a slate-blue-and-gold armoured colossus with a glowing blue heart-gem.

## +108 — Felix Combat Ability
- Felix's economy "Bribe" is now a combat ability — Smoke Screen grants +30% dodge chance for the first 4 rounds of battle. He keeps his +Gold passive.

## +107 — Mercenary Ability Rework
- Greybeard's War Cry now Marks the enemy (+25% damage taken for 4 rounds) instead of a hidden crit-chance buff — a real, scaling effect.
- Ruk's Stone Skin now reduces incoming damage by 30% (was a flat −4 that stopped mattering) and Voss's Arcane Surge hits for 12% max HP.

## +106 — Mercenary Ability Animations
- Mercenaries now get a call-out animation in battle when their ability fires — a glowing card slides in from your side showing the merc (Greybeard, Voss, Felix, Lena, Ruk, Mira, Ironhide). Shows in Campaign, Tower Ascension and the Dungeon.

## +105 — Easier Dungeon Bosses
- Dungeon bosses now hit 20% softer — both their HP and attack are reduced by 20% for a fairer fight at every floor.

## +104 — Next-Action Fix & Mastery Polish
- The "expeditions ready to collect" next-action now opens the Expeditions screen instead of the Mercenaries tab.
- Elemental Mastery now shows your Gold balance (needed for upgrades) and uses custom hand-drawn element glyphs instead of text tags.

## +103 — Balance Visibility Fixes
- The Mercenaries screen now shows your Shards balance next to ZCoins (both are spent on merc unlocks and upgrades).
- The Upgrades screen now shows your Echoes balance when viewed from the Hero Hub.

## +102 — Hand-Drawn Passive Tree Icons
- Passive tree nodes now use custom stat icons matched to their effect — crit, armor, HP, gold, XP and pierce sprites, elemental glyphs (flame, snowflake, bolt, droplet, void orb) for elemental damage, tinted shields for resistances, and a clock for idle/cooldown nodes.

## +101 — Hand-Drawn Race & Gender Emblems
- Gender (♂/♀) and all 10 races now use custom hand-drawn emblems in character creation and the hero header — a leaf for Elf, hammer for Dwarf, horns for Tiefling, dragon head for Dragonborn, and more.

## +100 — Custom Combat Stat Icons
- Artifact table bonuses and the Hero Stats page now use hand-drawn stat icons — power, armor, HP, crit, crit damage, pierce, gold, XP and shards — instead of generic icons.

## +99 — More Hand-Drawn Icons
- Ability Scores now use custom emblems — a fist for Power, feather for Agility, heart for Vitality, crosshair for Precision, shield for Fortitude and a clover for Luck.
- Upgrade synergies now show the two node emblems that fuse to unlock them.

## +98 — Hand-Drawn Upgrade Emblems
- The Upgrades screen nodes now use custom hand-drawn emblems instead of text badges — a sword for Brutality, crosshair for Precision, shield for Toughness, coin for Prosperity, eye for Insight and star for Focus.

## +97 — Echoes Upgrade Milestones Buffed
- Every Lv5/10/25 milestone perk on the Upgrades screen now hits much harder: Iron Grip +12% crit, Keen Edge +20% crit, Light Footed +5 AC, Blade Flicker 22%, Shadow Step 25% dodge, Thick Hide −3 dmg, Battle Scarred 5% HP/hit, Exploit Weakness +30%, Arcane Efficiency +40% gold, Rally Cry +40% XP, Silver Tongue −15% cost, Frugal Mind 25%.
- Fixed two milestones that did nothing: Studied Foe now gives +15% gold and Farsight now gives +20% Echoes.

## +96 — Crit Overflow, Bestiary Sprites & ZCoin Visibility
- Crit Chance cap raised from 75% to 100%. Any crit chance above 100% now overflows into bonus Crit Damage (+1% crit damage per 1% overflow) — no more wasted crit rating.
- The Bestiary now shows each monster's actual battle sprite once discovered.
- Companions and Mercenaries screens now show your ZCoins balance.

## +95 — Claim Summary & Consistent AC
- Claiming all achievements now shows a summary popup of exactly what you received — total Shards, Essence and ZCoins.
- Armor is now labelled "AC" everywhere (artifacts, PvP, quests and combat logs previously showed "ARM").

## +94 — Stat Glossary in Knowledge Base
- Added a STATS tab to the Knowledge Base explaining every abbreviation — HP, ATK, DMG, AC/ARM, RES, CRIT, PEN, DODGE, CD, DoT and all gear attribute stats — with what each one means and how it improves your hero.

## +93 — Hand-Drawn Rune Art (All Classes)
- Every class now has custom carved-stone rune art — Wizard, Sorcerer, Warlock, Bard, Monk and Druid complete the set. All ~120 runes are drawn as themed engraved glyphs matching the game's art style.

## +92 — Hand-Drawn Rune Art (6 Classes)
- Custom carved-stone rune art now covers Fighter, Rogue, Ranger, Paladin and Cleric too — each rune drawn as a themed engraved glyph. Wizard, Sorcerer, Warlock, Bard, Monk and Druid are up next.

## +91 — Hand-Drawn Rune Art (Barbarian)
- Runes now use custom carved-stone pixel-art tablets instead of emoji, matching the game's crafted-gem style. Barbarian runes are done first; the rest of the classes follow in coming updates.

## +90 — Tower Ascension Speed Control
- Tower Ascension now has a battle-speed button in its top bar, matching every other mode — including the 3× from the Speed Boost / Premium Pass.

## +89 — Cleaner Craft Gem Layout
- The Craft Gem screen now lists one gem per line with room to spell out each gem's element (e.g. Ruby → Fire) and exactly how much damage it adds in a weapon and resistance it adds in armor. Removed the wall of explainer text at the top.

## +88 — Consistent Battle Speed
- The Dungeon now honours your full battle speed — including the 3× from the Speed Boost / Premium Pass — instead of capping at 2×. Battle speed is now identical across Campaign, Dungeon, Boss Rush, Gauntlet and PvP.

## +87 — Ultimate Ability Clarity
- The Ability screen now shows a locked Ultimate preview until you unlock it — clearly stating it unlocks at Level 30 and requires finishing your class questline, with live progress on both.

## +86 — Clearer Gems
- Gems now spell out both of their effects everywhere — one gem per line, showing the elemental DAMAGE they add in a weapon AND the elemental RESISTANCE they add in armor or jewelry.
- When socketing, each item now shows exactly what the gem will do in that slot (e.g. "+10% Fire DMG" on a weapon vs "+10% Fire RES" on armor).

## +85 — Gauntlet Curve Smoothed
- Gauntlet tier 1 is now a fair challenge — the 10 waves ramp gently to a campaign-parity final boss instead of ending on a brick-wall enemy. Higher tiers scale up smoothly, and top tiers no longer flatten out.
- Waves within a run are ordered easiest-to-toughest, so difficulty always climbs.

## +84 — Boss Rush Curve Smoothed
- Tier 1 now sits at campaign parity — the five bosses are the ones you already beat on the map, fought back-to-back, so a ~level-20 hero can clear it. Higher tiers ramp up smoothly from there.
- Bosses within a run are now ordered easiest-to-toughest, so difficulty always climbs instead of spiking mid-run.

## +83 — Boss Rush tier-scaled difficulty (Option 1)
- Replaced the fixed boss stages `[4,9,14,19,24]` with `_bossStagesForTier(t)` =
  `[4,6,9,11,14] + (t-1)×5` (clamped to campaign length). Tier 1 now tops out at
  the stage-14 boss (Pharaoh, ~4,080 HP w/ 1 rebirth) instead of the stage-24
  Lich Emperor (~9,600 HP), making it a real ~level-20 checkpoint; each higher
  tier shifts +5 stages deeper. Stages lock at run start and update the pre-run
  preview on tier change.

## +82 — "How to get" resource clarity across upgrade screens
- New `CurrencySourceBar` widget renders the canonical `CurrencyDef.source` for
  one or more currencies; added to the **Forge** (Gold + Shards) and **Runes**
  (Arcane Dust) screens.
- Hero-hub tab resource banners: **SCORES** now shows the Gold source and
  **MERCS** shows Shards + ZCoins; the **Shards** source string is now
  consistent between Abilities and Passives (was contradictory).

## +81 — Artifact farming guide
- Added a "HOW TO GET ARTIFACTS" card (`_ArtifactSourcesCard`) to the Artifacts
  screen collection: Campaign bosses (~25% on boss kills), Dungeon runs (1 per
  boss defeated, up to 2/run), Boss Rush (A/S-rank clears), plus a note that
  deeper content rolls higher-level/rarer artifacts.

## +80 — Auto-campaign is visible-only (no silent background sim)
- Removed the silent background `_runAutoCampaignTick` sim from the idle timer —
  it made the campaign appear to "play itself" with no battles. Auto-campaign
  now only advances **visibly on the Battle screen** (the hands-free loop there
  is unchanged); off-screen it no longer resolves fights. The idle timer still
  clears `autoCampaign` if the subscription lapses.

## +79 — Rebirth boons revamp (27 boons, rarities, progress-weighted)
- `rebirth_boon.dart` rewritten: **27 boons** across 4 rarities (Uncommon → Rare
  → Epic → Legendary, mirroring `ItemRarity`). Each `RebirthBoon` gains `rarity`
  + `value`; effects generalised (startingGold ×, bonusShards/Souls/Echoes/
  Essence/Zcoins, startWeapon by rarity, xpThisRun ×). **Mythril boon removed.**
- `RebirthBoon.rollBoons(rebirths, ap, rng)` weights the 3 offered boons by
  rarity, shifting toward higher rarities as Rebirths + Ascension AP grow.
  Rebirth flow now rolls via this in `didChangeDependencies`.
- Boon cards show a **rarity-coloured frame** (+ glow when selected) and the
  rarity is stated in the description. `game_state` apply switch + soul-preview
  use `boon.value`.

## +78 — Offline energy refill + battle-arena chip tidy + mercs currency icon
- **Energy refills in real time & offline:** `tickEnergy()` now runs in the 5s
  idle timer and on `AppLifecycleState.resumed` (main.dart), in addition to the
  existing cold-load catch-up in `fromJson`. Fixes being stuck at 0/20 while
  foregrounded or after backgrounding.
- **Battle arena:** removed the `CRIT %` hero chip; the armour chip now reads
  `ARMOR <value>` (was the ambiguous `ARM`).
- **Mercs:** the upgrade "Have:" line uses the ZCoin emoji (🪙) instead of the
  crystal (💎).

## +76 — PvP speed/log + mercs indicator + dragon art
- **PvP Arena** gains a **speed button** (capped by `maxCampaignSpeedTier`; the
  round delays now use `scaledInterval`) and a **battle-log** button (dialog of
  `game.battleLog`). Victory panel adds the system nav-bar inset so the RETURN
  button isn't hidden behind the Android buttons.
- **MERCS panel indicator:** new `GameState.hasAffordableAllyUpgrade`; the
  hero-hub MERCS tab badge now lights up when an ally upgrade is affordable
  (alongside expedition-ready / new-merc-unlock).
- **Ember Dragon** premium pet now renders via `_EmberDragonPainter`
  (pixel-art `CustomPainter`) instead of the emoji fallback (+75).

## +73 — Dungeon relic/speed fixes + artifact auto-equip + gem clarity + GA4 purchase
- **Dungeon relic blocker:** `_RelicPicker` tap made robust (`HitTestBehavior.opaque`)
  + a `SKIP — DESCEND` fallback (`GameState.skipDungeonRelic`) so a boss reward
  can never leave you stuck.
- **Dungeon speed** button now capped by `maxCampaignSpeedTier` (free ≤1.5×, paid
  up to 3×) — no more separate free dungeon speed modifier.
- **Artifact auto-equip:** `GameState.autoEquipArtifacts()` ranks owned artifacts
  by rarity → total stats → drop level and fills every unlocked cell; `⚡ AUTO`
  button on the artifact table header.
- **Gems:** fixed mislabelled cost ("shards"/"gem shards" → **Arcane Dust**) in
  the craft button + dismantle dialog; added a plain-language explainer of what
  gems do and where to socket them.
- **Analytics:** log GA4's reserved `purchase` event (rawPrice + currencyCode)
  on fulfillment so Firebase revenue reports populate.

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
