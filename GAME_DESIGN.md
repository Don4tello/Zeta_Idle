# Zeta Idle — Game Design Reference

## How to Use This Document

This file is the single source of truth for all game numbers. To make a change:
1. Edit the relevant table or value in this document.
2. Tell Claude: _"Update the code to match `GAME_DESIGN.md` → [Section Name]"_.
3. Claude reads this file and makes the matching code change.

**Format conventions**
- `DMG` = flat damage dealt by the ability (bonusDamage, dot effects)
- `HEAL` = percentage of max HP restored or regenerated per round (heal, aura effects)
- `VAL` = numeric value for all other effects: ATK bonus, AC bonus, weaken %, shield HP, miss %, etc.
- `DUR` = duration in rounds
- `CD` = cooldown in rounds
- `PEN` = resistance penetration %
- Milestone notation: `+ΔDMG/HEAL/VAL` adds to the primary value; `+ΔDUR` adds to duration; `+effect(v,r)` adds a bonus effect on top

---

## Combat Mechanics

### Damage Formula
```
baseDmg  = proficiency + (level ÷ 2)
           proficiency = 2 + (level−1) ÷ 4
           // lv1=2, lv10=9, lv20=16, lv30=24
pctBonus = stat × 25 ÷ 100    // 0–25% from the stat tied to active element
totalHit = (dieSide + baseDmg + flatBonuses) × (1 + pctBonus + passivePctBonuses)
critHit  = totalHit × critMultiplier
```
`baseDmg` is the single flat-damage stat shown in the UI (`hero.baseDmg = proficiency + damageMod`).

### Attack Roll (Proficiency)
```
proficiency = 2 + (heroLevel − 1) ÷ 4
// Used for: to-hit checks, crit chance, and included in baseDmg
// Increases at levels 5, 9, 13, 17, 21, 25, 29
```

### Max HP
```
maxHP = round( (100 + (level-1)*20) * (100 + extraHpPct + CON) / 100 ) + flatHpBonus
// CON adds +1% max HP per point; extraHpPct from traits; flatHpBonus from Ability Score (VIT)
```

### Armor Reduction
Enemy hits pass through AC before dealing damage. Higher AC = more hits miss/glance.

### Resistance / Elemental Damage %
```
damageBonus% = stat * 25 / 100   // e.g. STR 60 → +15% Physical damage
resistance%  = same formula      // same stat reduces incoming element damage
cap = 75% resistance (hard cap, clamped in code)
negative resistance = vulnerability
```

### Crit System
- Crits apply when the ability's `attackBonus` effect fires or when the hero rolls a crit.
- `attackBonus VAL` = flat bonus damage added to the crit hit.
- Passives can add `critChance %` and `critDamage %` multipliers.

### Stun Diminishing Returns (DR)
| Application # | Effectiveness | Notes |
|---|---|---|
| 1st stun | 100% | Full DUR |
| 2nd stun | 50% | Half DUR (round up) |
| 3rd+ stun | 0% (immune) | Stun has no effect |
| Reset | After 5 stun-free rounds | Resets to 1st application |

Fields: `_stunApplicationCount` (0–2), `_roundsSinceLastStun`.

### Absorb Shield
`heroAbsorbShield` absorbs incoming damage before HP is reduced. Created by `absorbShield` effect.

### Miss Chance
`enemyMissChanceRounds > 0`: each enemy auto-attack has `missChance VAL %` chance to do 0 damage.

### Silence
`enemySilenceRounds > 0`: enemy cannot use any boss abilities.

### Stun (hero/enemy)
Stunned entity skips `DUR` turns entirely.

### DoT (Damage over Time)
`dotRoundsLeft > 0`: deals `dotDamage` flat DMG per round at round start.

---

## Hero System

### Level Scaling
| Level | Max HP (base) | Proficiency | Flat DMG |
|---|---|---|---|
| 1 | 100 | 2 | 0 |
| 5 | 180 | 3 | 2 |
| 10 | 280 | 4 | 5 |
| 15 | 380 | 5 | 7 |
| 20 | 480 | 6 | 10 |
| 25 | 580 | 7 | 12 |
| 30 | 680 | 8 | 15 |
| 40 | 880 | 11 | 20 |

> HP shown at base CON (class default). Actual HP = base × (100 + CON) / 100.

### Stat Cap
All stats capped at **100**. Base class stat + upgrade ranks can reach 100 max.

### Stat → Element Map
| Stat | Element | Damage bonus formula |
|---|---|---|
| STR (Power) | Physical | STR × 25 / 100 |
| DEX (Agility) | Lightning | DEX × 25 / 100 |
| CON (Vitality) | Poison | CON × 25 / 100 |
| INT (Arcane) | Void | INT × 25 / 100 |
| WIS (Focus) | Cold | WIS × 25 / 100 |
| CHA (Fortune) | Fire | CHA × 25 / 100 |

### Idle Rate / Gold Rate
Both flat constants (5 and 1 respectively). No longer scale with stats — use passives and items.

---

## Upgrade System

Cost scaling: `baseCost × 2^level × 1.5^max(0, level-4)` (rounds up).

| ID | Name | Type | Base Cost | Effect | Max Level |
|---|---|---|---|---|---|
| str_1 | Might Training | Strength | 200g | +1 STR/level → Physical DMG% + resistance | 92 |
| dex_1 | Swift Reflexes | Dexterity | 200g | +1 DEX/level → Lightning DMG% + resistance | 92 |
| con_1 | Endurance Drill | Constitution | 220g | +1 CON/level → +1% max HP + Poison resist | 92 |
| int_1 | Scholar's Study | Intelligence | 190g | +1 INT/level → Void DMG% + resistance | 92 |
| wis_1 | Meditative Focus | Wisdom | 210g | +1 WIS/level → Cold DMG% + resistance | 92 |
| cha_1 | Silver Presence | Charisma | 175g | +1 CHA/level → Fire DMG% + resistance | 92 |
| dual_mastery | Dual Mastery | ✨ Special | 800g | Unlocks secondary class element | 1 |

> File: `lib/data/game_data.dart`

---

## Ability System

- 6 active ability slots per class, unlocked at levels 1/5/10/15/20/25.
- 1 ultimate per class, unlocked at level 30, 12–14r cooldown.
- Max ability rank: **165** (milestones repeat every 15 ranks: rank 5/10/15, 20/25/30, …).
- 3 milestones per ability at rank 5, 10, 15 — each offers choice A or B.
- `baseBonus` = secondary effect that fires on every cast (not milestone-gated).

**Effect types:** `bonusDamage | heal | attackBonus | acBonus | stun | dot | dodge | aura | debuffWeaken | debuffVulnerable | silence | absorbShield | missChance`

> File: `lib/data/ability_data.dart`

---

## Classes

### Barbarian
**Elements:** Poison (primary) | Lightning (secondary, Dual Mastery)
**Primary stat:** STR | **Secondary stat:** CON
**Level stat gains:** STR +1/lv, CON +1/2lv, CON +1/3lv
**Starting stats:** STR 15, DEX 13, CON 14, INT 8, WIS 12, CHA 10

| Slot | ID | Name | Level | Effect | DMG | HEAL | VAL | DUR | CD | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | barbarian_1 | Reckless Strike | 1 | bonusDamage | 10 | — | — | — | 3 | |
| 2 | barbarian_2 | Battle Cry | 5 | attackBonus | — | — | +4 | 3 | 5 | |
| 3 | barbarian_3 | Wound Strike | 10 | dot | 10 | — | — | 3 | 5 | |
| 4 | barbarian_4 | Berserker Rage | 15 | attackBonus | — | — | +8 | 4 | 7 | |
| 5 | barbarian_5 | Armor Crush | 20 | debuffVulnerable | — | — | 25% | 3 | 6 | |
| 6 | barbarian_6 | Savage Tear | 25 | dot | 12 | — | — | 4 | 5 | |
| U | barb_ult | Undying Rage | 30 | bonusDamage | 300 | — | — | 3 | 12 | 3× DMG, immune 3r |

**Milestones:**
| ID | R5 A | R5 B | R10 A | R10 B | R15 A | R15 B |
|---|---|---|---|---|---|---|
| _1 | +2DMG/Phys | Poison+DMG(15,2r) | +4DMG | DMG(20,2r) | +6DMG+STUN(1r) | DMG(35,4r) |
| _2 | +2VAL | +AC(2,3r) | +2DUR | +STUN(1r) | +4VAL+HEAL(10%) | WEAK(25%,3r) |
| _3 | +2DMG/Poison | Lightning+STUN(1r) | +4DMG+1DUR | VULN(20%,2r) | +6DMG+STUN(1r) | +8DMG+2DUR |
| _4 | HEAL(4%,4r) | +4VAL+STUN(1r) | +3VAL+2DUR | DMG(20,3r) | +5VAL+HEAL(10%) | WEAK(30%,4r) |
| _5 | +10VAL | +2DUR | +5VAL | +STUN(1r) | WEAK(20%,3r) | +3DUR |
| _6 | +2DMG/Poison | Lightning+STUN(1r) | +5DMG+1DUR | VULN(20%,3r) | +8DMG+STUN(1r) | +12DMG+2DUR |

---

### Bard
**Elements:** Void (primary) | Lightning (secondary, Dual Mastery)
**Primary stat:** CHA | **Secondary stat:** DEX
**Level stat gains:** CHA +1/lv, DEX +1/2lv, CON +1/3lv
**Starting stats:** STR 8, DEX 14, CON 13, INT 10, WIS 12, CHA 15

| Slot | ID | Name | Level | Effect | DMG | HEAL | VAL | DUR | CD | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | bard_1 | Vexing Verse | 1 | bonusDamage | 10 | — | — | — | 3 | |
| 2 | bard_2 | Inspiring Speech | 5 | heal | — | 15% | — | — | 6 | |
| 3 | bard_3 | Discordant Blast | 10 | bonusDamage | 12 | — | — | — | 5 | |
| 4 | bard_4 | Virtuoso's Tempo | 15 | attackBonus | — | — | +6 | 4 | 7 | |
| 5 | bard_5 | Taunt | 20 | debuffWeaken | — | — | 25% | 3 | 6 | |
| 6 | bard_6 | Cacophony | 25 | missChance | — | — | 30% | 4 | 5 | Enemy misses 30% of attacks |
| U | brd_ult | Crescendo | 30 | attackBonus | — | — | +50 | 4 | 12 | Boosts all stats |

**Milestones:**
| ID | R5 A | R5 B | R10 A | R10 B | R15 A | R15 B |
|---|---|---|---|---|---|---|
| _1 | Void+WEAK(15%,2r) | Lightning+PEN | +4DMG | +STUN(1r) | +6DMG | VULN(15%,2r) |
| _2 | +5HEAL | +ATK(3,2r) | +3HEAL | +AC(3,3r) | +8HEAL+HEAL(5%,2r) | +STUN(1r) |
| _3 | Lightning+2DMG | Void+WEAK(15%,2r) | +5DMG | DMG(20%,3r) | +8DMG+STUN(1r) | DMG(35%,4r) |
| _4 | +3VAL+DMG(15,2r) | WEAK(20%,3r) | +3VAL+2DUR | HEAL(4%,4r) | +5VAL+STUN(1r) | VULN(25%,3r) |
| _5 | +10VAL | +2DUR | +5VAL | +STUN(1r) | VULN(20%,3r) | +3DUR |
| _6 | +10VAL | WEAK(20%,3r) | +1DUR | VULN(20%,3r) | +20VAL+STUN(1r) | +5VAL+2DUR |

---

### Cleric
**Elements:** Fire (primary) | Void (secondary, Dual Mastery)
**Primary stat:** WIS | **Secondary stat:** CON
**Level stat gains:** WIS +1/lv, CON +1/2lv, CON +1/3lv
**Starting stats:** STR 13, DEX 8, CON 14, INT 10, WIS 15, CHA 12

| Slot | ID | Name | Level | Effect | DMG | HEAL | VAL | DUR | CD | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | cleric_1 | Sacred Flame | 1 | bonusDamage | 10 | — | — | — | 3 | |
| 2 | cleric_2 | Cure Wounds | 5 | heal | — | 18% | — | — | 6 | |
| 3 | cleric_3 | Void Judgment | 10 | bonusDamage | 12 | — | — | — | 5 | PEN 15% |
| 4 | cleric_4 | Consecrated Ground | 15 | dot | 8 | — | — | 3 | 7 | baseBonus: HEAL 8% on cast |
| 5 | cleric_5 | Condemn | 20 | debuffWeaken | — | — | 25% | 3 | 6 | |
| 6 | cleric_6 | Divine Ward | 25 | absorbShield | — | — | 80 HP | — | 5 | Barrier absorbs DMG |
| U | clr_ult | Miracle | 30 | heal | — | 100% | — | 5r aura | 14 | Full HEAL + regen aura |

**Milestones:**
| ID | R5 A | R5 B | R10 A | R10 B | R15 A | R15 B |
|---|---|---|---|---|---|---|
| _1 | Fire+2DMG | Void | +4DMG | +STUN(1r) | +6DMG+DMG(25,2r) | DMG(35%,3r) |
| _2 | +6HEAL | +AC(3,3r) | +4HEAL | +ATK(3,2r) | +10HEAL+HEAL(6%,3r) | +AC(4,4r) |
| _3 | Fire+2DMG | Fire+DMG(20%,2r) | +5DMG | +STUN(1r) | +8DMG+VULN(20%,3r) | +STUN(1r) |
| _4 | +4DMG | WEAK(20%,3r) | +3DMG+1DUR | +AC(4,3r) | +6DMG+STUN(1r) | +13DMG+2DUR |
| _5 | +10VAL | +2DUR | +5VAL | +STUN(1r) | VULN(20%,3r) | +3DUR |
| _6 | +20VAL | +HEAL(10%) | +50VAL | HEAL(8,3r) | +80VAL+STUN(1r) | +60VAL+HEAL(15%) |

---

### Druid
**Elements:** Poison (primary) | Cold (secondary, Dual Mastery)
**Primary stat:** WIS | **Secondary stat:** CON
**Level stat gains:** WIS +1/lv, CON +1/2lv, CON +1/3lv
**Starting stats:** STR 8, DEX 12, CON 14, INT 13, WIS 15, CHA 10

| Slot | ID | Name | Level | Effect | DMG | HEAL | VAL | DUR | CD | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | druid_1 | Thorn Lash | 1 | dot | 8 | — | — | 3 | 3 | PEN 10% |
| 2 | druid_2 | Healing Word | 5 | heal | — | 15% | — | — | 6 | |
| 3 | druid_3 | Glacier Slam | 10 | bonusDamage | 12 | — | — | — | 5 | PEN 15% |
| 4 | druid_4 | Spore Cloud | 15 | dot | 8 | — | — | 4 | 7 | |
| 5 | druid_5 | Nature's Grasp | 20 | debuffWeaken | — | — | 25% | 4 | 6 | |
| 6 | druid_6 | Entangle | 25 | stun | — | — | — | 2 | 5 | Root 2r |
| U | drd_ult | Primal Avatar | 30 | attackBonus | — | — | +100 | 5 | 14 | +100% DMG & HP |

**Milestones:**
| ID | R5 A | R5 B | R10 A | R10 B | R15 A | R15 B |
|---|---|---|---|---|---|---|
| _1 | Poison+2DMG | Cold+STUN(1r) | +3DMG+1DUR | VULN(15%,3r) | +5DMG+STUN(1r) | +7DMG+3DUR |
| _2 | +5HEAL | +ATK(3,2r) | +3HEAL | +AC(3,3r) | +8HEAL+HEAL(5%,3r) | +HEAL(12%) |
| _3 | Cold+STUN(1r) | Poison+DMG(15%,3r) | +5DMG | DMG(25%,3r) | +8DMG+STUN(1r) | DMG(35%,4r) |
| _4 | +4DMG | Cold+HEAL(8%) | +3DMG+1DUR | WEAK(20%,3r) | +5DMG+STUN(1r) | +8DMG+2DUR |
| _5 | +10VAL | +2DUR | +10VAL | +STUN(1r) | VULN(20%,4r) | +4DUR |
| _6 | DMG(15,4r) | +1DUR | DMG(25,4r) | WEAK(25%,3r) | VULN(20%,3r) | +2DUR |

---

### Fighter
**Elements:** Lightning (primary) | Fire (secondary, Dual Mastery)
**Primary stat:** STR | **Secondary stat:** CON
**Level stat gains:** STR +1/lv, CON +1/2lv, CON +1/3lv
**Starting stats:** STR 15, DEX 13, CON 14, INT 8, WIS 12, CHA 10

| Slot | ID | Name | Level | Effect | DMG | HEAL | VAL | DUR | CD | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | fighter_1 | Shield Bash | 1 | bonusDamage | 10 | — | — | — | 3 | |
| 2 | fighter_2 | Combat Stance | 5 | attackBonus | — | — | +5 | 2 | 5 | |
| 3 | fighter_3 | Thunder Strike | 10 | bonusDamage | 12 | — | — | — | 5 | |
| 4 | fighter_4 | Second Wind | 15 | heal | — | 15% | — | — | 7 | baseBonus: +ATK(4, 2r) |
| 5 | fighter_5 | Intimidate | 20 | debuffWeaken | — | — | 25% | 3 | 6 | |
| 6 | fighter_6 | Disarm | 25 | debuffWeaken | — | — | 100% | 1 | 5 | Enemy deals 0 DMG for 1r |
| U | ftr_ult | Blade Storm | 30 | bonusDamage | 200 | — | — | 5 hits | 12 | 5 rapid strikes |

**Milestones:**
| ID | R5 A | R5 B | R10 A | R10 B | R15 A | R15 B |
|---|---|---|---|---|---|---|
| _1 | Lightning+WEAK(15%,2r) | Fire+DMG(15%,2r) | +5DMG | DMG(20%,2r) | +8DMG+STUN(1r) | DMG(30,3r) |
| _2 | +2VAL+1DUR | +AC(3,2r) | +3VAL | WEAK(30%,3r) | +4VAL+HEAL(10%) | WEAK(15%,3r) |
| _3 | Fire+DMG(20%,2r) | Lightning+STUN(1r) | +5DMG | +STUN(1r) | +8DMG+ATK(5,2r) | DMG(30,3r)+STUN(1r) |
| _4 | +8HEAL | +ATK(3,2r) | +8HEAL+AC(2,3r) | +STUN(1r) | +12HEAL+HEAL(5%,3r) | WEAK(25%,3r) |
| _5 | +10VAL | +2DUR | +10VAL | +STUN(1r) | VULN(20%,3r) | +3DUR |
| _6 | +1DUR | +STUN(1r) | DMG(20,3r) | VULN(20%,3r) | +1DUR+DMG(25,4r) | +2DUR |

---

### Monk
**Elements:** Lightning (primary) | Void (secondary, Dual Mastery)
**Primary stat:** DEX | **Secondary stat:** WIS
**Level stat gains:** DEX +1/lv, WIS +1/2lv, CON +1/3lv
**Starting stats:** STR 12, DEX 15, CON 13, INT 8, WIS 14, CHA 10

| Slot | ID | Name | Level | Effect | DMG | HEAL | VAL | DUR | CD | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | monk_1 | Flurry of Blows | 1 | bonusDamage | 8 | — | — | — | 3 | |
| 2 | monk_2 | Iron Skin | 5 | acBonus | — | — | +3 | 4 | 5 | |
| 3 | monk_3 | Void Strike | 10 | bonusDamage | 12 | — | — | — | 4 | PEN 15% |
| 4 | monk_4 | Ki Surge | 15 | attackBonus | — | — | +7 | 3 | 7 | baseBonus: dodge next hit |
| 5 | monk_5 | Pressure Point | 20 | debuffWeaken | — | — | 25% | 3 | 5 | |
| 6 | monk_6 | Ki Disruption | 25 | silence | — | — | — | 2 | 5 | Blocks all enemy abilities |
| U | mnk_ult | Thousand Fists | 30 | bonusDamage | 150 | — | — | 8 hits | 10 | 100% PEN |

**Milestones:**
| ID | R5 A | R5 B | R10 A | R10 B | R15 A | R15 B |
|---|---|---|---|---|---|---|
| _1 | Lightning+2DMG | Void+WEAK(15%,2r) | +4DMG | +STUN(1r) | +6DMG+STUN(1r) | VULN(15%,2r) |
| _2 | +2VAL | +DODGE | +2DUR | +ATK(3,4r) | +3VAL+HEAL(8%) | WEAK(15%,3r) |
| _3 | Lightning+STUN(1r) | Lightning+STUN(1r) | +5DMG | +STUN(1r) | +8DMG+ATK(4,2r) | +STUN(1r) |
| _4 | +3VAL+STUN(1r) | +HEAL(10%) | +3VAL+2DUR | +AC(3,3r) | +5VAL+WEAK(25%,3r) | DMG(20,3r) |
| _5 | +10VAL | +2DUR | +10VAL | +STUN(1r) | VULN(20%,3r) | +3DUR |
| _6 | +1DUR | WEAK(25%,3r) | DMG(15,3r) | VULN(20%,3r) | +2DUR+STUN(1r) | +2DUR+WEAK(30%,4r) |

---

### Paladin
**Elements:** Fire (primary) | Cold (secondary, Dual Mastery)
**Primary stat:** STR | **Secondary stat:** CHA
**Level stat gains:** STR +1/lv, CHA +1/2lv, CON +1/3lv
**Starting stats:** STR 15, DEX 10, CON 13, INT 8, WIS 12, CHA 14

| Slot | ID | Name | Level | Effect | DMG | HEAL | VAL | DUR | CD | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | paladin_1 | Divine Smite | 1 | bonusDamage | 10 | — | — | — | 4 | PEN 10% |
| 2 | paladin_2 | Lay on Hands | 5 | heal | — | 20% | — | — | 6 | |
| 3 | paladin_3 | Holy Bolt | 10 | bonusDamage | 12 | — | — | — | 5 | |
| 4 | paladin_4 | Sacred Aura | 15 | aura | — | 6%/r | — | 5 | 7 | HEAL per round |
| 5 | paladin_5 | Divine Judgment | 20 | debuffWeaken | — | — | 25% | 4 | 6 | |
| 6 | paladin_6 | Sacred Pyre | 25 | dot | 12 | — | — | 4 | 5 | |
| U | pal_ult | Divine Judgement | 30 | bonusDamage | 250 | — | — | — | 14 | HEALs to full on use |

**Milestones:**
| ID | R5 A | R5 B | R10 A | R10 B | R15 A | R15 B |
|---|---|---|---|---|---|---|
| _1 | Fire+2DMG | Cold+STUN(1r) | +4DMG | +STUN(1r) | +6DMG+HEAL(8%) | DMG(30%,3r) |
| _2 | +6HEAL | +AC(4,3r) | +4HEAL | +ATK(4,2r) | +10HEAL+HEAL(6%,3r) | +AC(5,4r) |
| _3 | Cold+STUN(1r) | Fire+DMG(20%,2r) | +5DMG | DMG(25%,3r) | +8DMG+STUN(1r) | DMG(35%,4r) |
| _4 | +4HEAL | −3HEAL+ATK(5,5r) | +2DUR | +AC(4,5r) | +3HEAL | WEAK(15%,3r) |
| _5 | +10VAL | +2DUR | +5VAL | +STUN(1r) | VULN(20%,3r) | +3DUR |
| _6 | Cold+STUN(1r) | +4DMG | +5DMG+1DUR | VULN(25%,3r) | +8DMG+WEAK(25%,3r) | +12DMG+2DUR |

---

### Ranger
**Elements:** Poison (primary) | Cold (secondary, Dual Mastery)
**Primary stat:** DEX | **Secondary stat:** WIS
**Level stat gains:** DEX +1/lv, WIS +1/2lv, CON +1/3lv
**Starting stats:** STR 12, DEX 15, CON 13, INT 10, WIS 14, CHA 8

| Slot | ID | Name | Level | Effect | DMG | HEAL | VAL | DUR | CD | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | ranger_1 | Poison Arrow | 1 | dot | 8 | — | — | 3 | 3 | PEN 15% |
| 2 | ranger_2 | Hunter's Mark | 5 | attackBonus | — | — | +4 | 4 | 4 | |
| 3 | ranger_3 | Blizzard Arrow | 10 | bonusDamage | 12 | — | — | — | 5 | PEN 20% |
| 4 | ranger_4 | Predator's Stance | 15 | attackBonus | — | — | +5 | 4 | 6 | baseBonus: dodge next hit |
| 5 | ranger_5 | Crippling Shot | 20 | debuffWeaken | — | — | 25% | 4 | 6 | |
| 6 | ranger_6 | Hunter's Trap | 25 | stun | — | — | — | 1 | 5 | Root 1r |
| U | rng_ult | Arrow Rain | 30 | dot | 80 | — | — | 4 | 12 | Massive poison barrage |

**Milestones:**
| ID | R5 A | R5 B | R10 A | R10 B | R15 A | R15 B |
|---|---|---|---|---|---|---|
| _1 | Poison+2DMG | Cold+STUN(1r) | +3DMG+1DUR | VULN(15%,3r) | +5DMG+STUN(1r) | +7DMG+3DUR |
| _2 | +2VAL+1DUR | +AC(3,4r) | +3VAL | WEAK(25%,2r) | +4VAL+HEAL(8%) | WEAK(15%,3r) |
| _3 | Cold+STUN(1r) | Poison+DMG(20%,2r) | +5DMG | DMG(25%,3r) | +8DMG+STUN(1r) | DMG(35%,4r) |
| _4 | +3VAL+1DUR | DMG(20,3r) | +3VAL+WEAK(20%,3r) | +HEAL(10%) | +5VAL+STUN(1r) | VULN(25%,3r) |
| _5 | +10VAL | +2DUR | +5VAL | +STUN(1r) | VULN(20%,4r) | +4DUR |
| _6 | DMG(15,4r) | +1DUR | DMG(25,4r) | VULN(25%,3r) | +1DUR+WEAK(20%,3r) | DMG(40,5r) |

---

### Rogue
**Elements:** Poison (primary) | Void (secondary, Dual Mastery)
**Primary stat:** DEX | **Secondary stat:** INT
**Level stat gains:** DEX +1/lv, INT +1/2lv, CON +1/3lv
**Starting stats:** STR 8, DEX 15, CON 13, INT 14, WIS 12, CHA 10

| Slot | ID | Name | Level | Effect | DMG | HEAL | VAL | DUR | CD | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | rogue_1 | Sneak Attack | 1 | bonusDamage | 10 | — | — | — | 3 | |
| 2 | rogue_2 | Evasion | 5 | dodge | — | — | — | 1 | 4 | baseBonus: VULN (100%, 1r) |
| 3 | rogue_3 | Shadow Blade | 10 | bonusDamage | 12 | — | — | — | 4 | PEN 15% |
| 4 | rogue_4 | Smoke Bomb | 15 | acBonus | — | — | +4 | 3 | 6 | |
| 5 | rogue_5 | Kidney Shot | 20 | debuffWeaken | — | — | 30% | 3 | 5 | |
| 6 | rogue_6 | Hemorrhage | 25 | dot | 20 | — | — | 3 | 5 | |
| U | rog_ult | Death Mark | 30 | debuffVulnerable | — | — | 100% | 3 | 10 | Next 3 hits are crits |

**Milestones:**
| ID | R5 A | R5 B | R10 A | R10 B | R15 A | R15 B |
|---|---|---|---|---|---|---|
| _1 | Poison+DMG(20%,2r) | Void+WEAK(20%,2r) | +5DMG | +STUN(1r) | +8DMG+STUN(1r) | DMG(35%,4r) |
| _2 | DMG(30%,2r) | +STUN(1r) | +HEAL(12%) | DMG(25%,3r) | +STUN(2r) | +AC(6,3r) |
| _3 | Void+2DMG | Poison+DMG(20%,2r) | +5DMG | +STUN(1r) | +8DMG+STUN(1r) | DMG(30%,3r) |
| _4 | +2VAL+DMG(15%,2r) | −1VAL+ATK(4,3r) | +2DUR | +STUN(1r) | +3VAL+HEAL(8%) | WEAK(15%,3r) |
| _5 | +10VAL | +STUN(1r) | +5VAL | +2DUR | VULN(20%,3r) | +STUN(1r) |
| _6 | Poison+5DMG | Void+WEAK(20%,3r) | +5DMG+1DUR | VULN(20%,3r) | +8DMG+STUN(1r) | +3DUR |

---

### Sorcerer
**Elements:** Fire (primary) | Cold (secondary, Dual Mastery)
**Primary stat:** CHA | **Secondary stat:** INT
**Level stat gains:** CHA +1/lv, INT +1/2lv, CON +1/3lv
**Starting stats:** STR 8, DEX 13, CON 14, INT 10, WIS 12, CHA 15

| Slot | ID | Name | Level | Effect | DMG | HEAL | VAL | DUR | CD | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | sorcerer_1 | Chaos Bolt | 1 | bonusDamage | 10 | — | — | — | 3 | |
| 2 | sorcerer_2 | Draconic Vigor | 5 | aura | — | 12%/r | — | 2 | 5 | HEAL per round |
| 3 | sorcerer_3 | Glacial Spike | 10 | bonusDamage | 12 | — | — | — | 4 | PEN 20% |
| 4 | sorcerer_4 | Mana Surge | 15 | attackBonus | — | — | +10 | 2 | 6 | |
| 5 | sorcerer_5 | Mana Drain | 20 | silence | — | — | — | 2 | 5 | Blocks all enemy abilities |
| 6 | sorcerer_6 | Melt Defenses | 25 | debuffVulnerable | — | — | 25% | 4 | 5 | |
| U | sor_ult | Arcane Singularity | 30 | stun + bonusDamage | 200 | — | — | 2 | 12 | STUN 2r + void DMG |

**Milestones:**
| ID | R5 A | R5 B | R10 A | R10 B | R15 A | R15 B |
|---|---|---|---|---|---|---|
| _1 | Fire+2DMG | Cold+STUN(1r) | +5DMG | +STUN(1r) | +8DMG+DMG(30%,3r) | +6DMG+STUN(1r) |
| _2 | +AC(4,2r) | +ATK(4,2r) | +6HEAL | +2DUR | +8HEAL+DMG(25%,2r) | DMG(35%,3r) |
| _3 | Cold+2DMG | Fire+STUN(1r) | +5DMG | DMG(25%,3r) | +8DMG+STUN(1r) | DMG(18,4r) |
| _4 | +4VAL+DMG(20,2r) | +STUN(1r) | +4VAL+2DUR | +AC(5,2r) | +6VAL+HEAL(12%) | VULN(25%,3r) |
| _5 | +1DUR | +STUN(1r) | +HEAL(10%) | +2DUR | +2DUR+WEAK(25%,4r) | +1DUR+HEAL(15%) |
| _6 | +8VAL | DMG(25%,3r) | DMG(35%,4r) | +2DUR | WEAK(30%,4r) | +15VAL+STUN(1r) |

---

### Warlock
**Elements:** Void (primary) | Cold (secondary, Dual Mastery)
**Primary stat:** CHA | **Secondary stat:** INT
**Level stat gains:** CHA +1/lv, INT +1/2lv, CON +1/3lv
**Starting stats:** STR 8, DEX 13, CON 14, INT 12, WIS 10, CHA 15

| Slot | ID | Name | Level | Effect | DMG | HEAL | VAL | DUR | CD | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | warlock_1 | Eldritch Blast | 1 | bonusDamage | 10 | — | — | — | 3 | |
| 2 | warlock_2 | Dark One's Blessing | 5 | aura | — | 10%/r | — | 2 | 5 | HEAL per round |
| 3 | warlock_3 | Hunger of Hadar | 10 | bonusDamage | 12 | — | — | — | 4 | PEN 20% |
| 4 | warlock_4 | Armor of Agathys | 15 | acBonus | — | — | +5 | 3 | 6 | |
| 5 | warlock_5 | Hex | 20 | debuffWeaken | — | — | 30% | 4 | 5 | baseBonus: HEAL 10% on cast |
| 6 | warlock_6 | Soul Rend | 25 | dot | 15 | — | — | 4 | 5 | baseBonus: HEAL 10% on cast |
| U | wlk_ult | Soul Harvest | 30 | bonusDamage | 200 | — | — | — | 10 | DMG dealt → HEALed |

**Milestones:**
| ID | R5 A | R5 B | R10 A | R10 B | R15 A | R15 B |
|---|---|---|---|---|---|---|
| _1 | Void+2DMG | Cold+STUN(1r) | +5DMG | +STUN(1r) | +8DMG+DMG(30%,3r) | +6DMG+STUN(1r) |
| _2 | +AC(4,2r) | +ATK(4,2r) | +5HEAL | +2DUR | +8HEAL+HEAL(10%) | DMG(35%,3r) |
| _3 | Void+2DMG | Cold+STUN(1r) | +5DMG | DMG(25%,3r) | +8DMG+STUN(1r) | DMG(18,4r) |
| _4 | +2DMG+DMG(20%,2r) | +2VAL+ATK(4,3r) | +2DUR | WEAK(30%,2r) | +3DMG+HEAL(10%) | WEAK(20%,3r) |
| _5 | +10VAL | +STUN(1r) | +5VAL | +2DUR | VULN(20%,4r) | +2DUR+STUN(1r) |
| _6 | Void+3DMG | Cold+STUN(1r) | +5DMG+1DUR | WEAK(25%,4r) | +8DMG+HEAL(15%) | +2DUR+VULN(20%,4r) |

---

### Wizard
**Elements:** Cold (primary) | Void (secondary, Dual Mastery)
**Primary stat:** INT | **Secondary stat:** WIS
**Level stat gains:** INT +1/lv, WIS +1/2lv, CON +1/3lv
**Starting stats:** STR 8, DEX 12, CON 13, INT 15, WIS 14, CHA 10

| Slot | ID | Name | Level | Effect | DMG | HEAL | VAL | DUR | CD | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | wizard_1 | Magic Missile | 1 | bonusDamage | 10 | — | — | — | 3 | |
| 2 | wizard_2 | Mage Armor | 5 | acBonus | — | — | +5 | 3 | 6 | |
| 3 | wizard_3 | Cone of Cold | 10 | bonusDamage | 12 | — | — | — | 4 | PEN 20% |
| 4 | wizard_4 | Arcane Recovery | 15 | aura | — | 10%/r | — | 2 | 5 | HEAL per round |
| 5 | wizard_5 | Slow | 20 | debuffWeaken | — | — | 30% | 4 | 5 | |
| 6 | wizard_6 | Arcane Lock | 25 | silence | — | — | — | 2 | 5 | Blocks all enemy abilities |
| U | wiz_ult | Meteor | 30 | bonusDamage | 350 | — | — | 4r burn | 12 | Massive fire + DoT |

**Milestones:**
| ID | R5 A | R5 B | R10 A | R10 B | R15 A | R15 B |
|---|---|---|---|---|---|---|
| _1 | Cold+STUN(1r) | Void+WEAK(15%,2r) | +5DMG | +STUN(1r) | +8DMG+DMG(30%,3r) | +6DMG+STUN(1r) |
| _2 | +2VAL+DMG(20%,2r) | +ATK(4,3r) | +2DUR | WEAK(25%,3r) | +3VAL+HEAL(10%) | WEAK(20%,3r) |
| _3 | Void+2DMG | Void+STUN(1r) | +5DMG | DMG(25%,3r) | +8DMG+STUN(1r) | DMG(18,4r) |
| _4 | +ATK(4,2r) | +AC(4,2r) | +5HEAL | +2DUR | +8HEAL+WEAK(25%,2r) | DMG(35%,3r) |
| _5 | +10VAL | +STUN(1r) | +5VAL | +2DUR | VULN(20%,4r) | +2DUR+STUN(1r) |
| _6 | +1DUR | WEAK(25%,3r) | DMG(20,3r) | +2DUR | +2DUR+VULN(25%,4r) | +2DUR+STUN(1r) |

---

## Ultimate Abilities Summary

All unlocked at level 30. Milestones follow same 5/10/15 system.

| Class | ID | Name | Effect | DMG | HEAL | VAL | DUR | CD |
|---|---|---|---|---|---|---|---|---|
| Barbarian | barb_ult | Undying Rage | bonusDamage | 300 | — | — | 3 | 12 |
| Fighter | ftr_ult | Blade Storm | bonusDamage | 200 | — | — | 5 hits | 12 |
| Rogue | rog_ult | Death Mark | debuffVulnerable | — | — | 100% | 3 | 10 |
| Ranger | rng_ult | Arrow Rain | dot | 80 | — | — | 4 | 12 |
| Paladin | pal_ult | Divine Judgement | bonusDamage | 250 | — | — | — | 14 |
| Cleric | clr_ult | Miracle | heal | — | 100% | — | 5r aura | 14 |
| Wizard | wiz_ult | Meteor | bonusDamage | 350 | — | — | 4r burn | 12 |
| Sorcerer | sor_ult | Arcane Singularity | stun+damage | 200 | — | — | 2 | 12 |
| Warlock | wlk_ult | Soul Harvest | bonusDamage | 200 | — | — | — | 10 |
| Bard | brd_ult | Crescendo | attackBonus | — | — | +50 | 4 | 12 |
| Druid | drd_ult | Primal Avatar | attackBonus | — | — | +100 | 5 | 14 |
| Monk | mnk_ult | Thousand Fists | bonusDamage | 150 | — | — | 8 hits | 10 |

> File: `lib/data/ability_data.dart` → `_ultimates` map

---

## Ability Scores

**Unlock:** Stage 1 — the first progression system available after the SHEET tab.  
**Currency:** Gold (💰).  
**Max rank per score:** 50.  
**Cost formula:** `100 × (rank + 1)` gold per upgrade.

Ability Scores are permanent upgrades purchased with gold that directly enhance combat statistics. Each score is independent and all can be upgraded to rank 50.

| Score | Abbrev | Bonus per Rank |
|---|---|---|
| Power      | PWR | +2 flat attack damage |
| Agility    | AGI | +2% critical hit damage |
| Vitality   | VIT | +30 max HP |
| Precision  | PRC | +1% critical hit chance |
| Fortitude  | FOR | +1 armor class per 2 ranks |
| Luck       | LCK | +1% gold income |

**Code:** [`ability_scores_screen.dart`](lib/screens/ability_scores_screen.dart) — logic in [`game_state.dart`](lib/services/game_state.dart) (`abilityScoreRank`, `abilityScoreUpgradeCost`, `upgradeAbilityScore`).

---

## Pets

All pets provide a permanent passive bonus. Costs are in ZCoins (◆).

| Pet | Class | Emoji | Bonus Type | Bonus Value | Cost | Flying |
|---|---|---|---|---|---|---|
| Iron Boar | Barbarian | 🐗 | goldPct | +5% gold | 250◆ | No |
| Battle Hound | Fighter | 🐕 | attackBonus | +5 ATK | 300◆ | No |
| Night Cat | Rogue | 🐈‍⬛ | shardBonus | +3 shards | 300◆ | No |
| Shadow Hawk | Ranger | 🦅 | damage | +1 flat DMG | 300◆ | Yes |
| Holy Lamb | Paladin | 🐑 | hpRegen | +10 HP/tick | 300◆ | No |
| Sacred Dove | Cleric | 🕊 | hpRegen | +5 HP/tick | 200◆ | Yes |
| Forest Wolf | Druid | 🐺 | idleRate | +1 idle | 250◆ | No |
| Stone Turtle | Monk | 🐢 | armor | +3 AC | 300◆ | No |
| Lute Sparrow | Bard | 🐦 | xpPct | +5% XP | 250◆ | Yes |
| Arcane Ferret | Sorcerer | 🦦 | damage | +5 flat DMG | 300◆ | No |
| Imp Familiar | Warlock | 🦇 | shardBonus | +7 shards | 350◆ | Yes |
| Arcane Owl | Wizard | 🦉 | idleRate | +2 idle | 350◆ | Yes |

> File: `lib/models/pet.dart`

---

## Passive Tree

Six branches + cross-branch connectors + keystones + class-specific nodes.
Ranks cost **essence** (◆). All nodes max out at the stated `maxRank`.

### Slayer Branch (damage-focused)

| ID | Name | Effect | VAL/Rank | Cost/Rank | MaxRank |
|---|---|---|---|---|---|
| slayer_0 | Keen Edge | critChance | +2% | 8◆ | 5 |
| slayer_1 | Brute Force | damageFlat | +2 | 18◆ | 5 |
| slayer_2 | Sure Strike | attackFlat | +2 | 35◆ | 5 |
| slayer_3 | Executioner | abilityDamage | +12% | 70◆ | 5 |
| slayer_4 | Piercing Veil | pierce | +2 AC | 130◆ | 5 |
| slayer_5 | Death's Touch | allDamage | +6% | 250◆ | 5 |
| slayer_6 | Veil Ripper | allPenetration | +4% | 400◆ | 5 |

### Guardian Branch (defense/survival)

| ID | Name | Effect | VAL/Rank | Cost/Rank | MaxRank |
|---|---|---|---|---|---|
| guardian_0 | Iron Skin | maxHp | +10% | 8◆ | 5 |
| guardian_1 | Stone Guard | armorFlat | +2 | 18◆ | 5 |
| guardian_2 | Nimble Footing | dodgeChance | +3% | 35◆ | 5 |
| guardian_3 | Regenerator | regenFlat | +3 | 70◆ | 5 |
| guardian_4 | Iron Fortress | maxHp | +15% | 130◆ | 5 |
| guardian_5 | Warding Shell | allRes | +3% | 250◆ | 5 |

### Merchant Branch (economy)

| ID | Name | Effect | VAL/Rank | Cost/Rank | MaxRank |
|---|---|---|---|---|---|
| merchant_0 | Scavenger | goldFlat | +12% | 8◆ | 5 |
| merchant_1 | Shard Seeker | shardFlat | +1 | 18◆ | 5 |
| merchant_2 | Scholar | xpFlat | +15% | 35◆ | 5 |
| merchant_3 | Surveyor | idleFlat | +2 | 70◆ | 5 |
| merchant_4 | Plunderer | goldFlat | +20% | 130◆ | 5 |
| merchant_5 | Opulence | xpFlat | +25% | 250◆ | 5 |

### Mystic Branch (ability power)

| ID | Name | Effect | VAL/Rank | Cost/Rank | MaxRank |
|---|---|---|---|---|---|
| mystic_0 | Arcane Gathering | essenceGain | +10% | 8◆ | 5 |
| mystic_1 | Arcane Touch | abilityDamage | +15% | 18◆ | 5 |
| mystic_2 | Life Weave | healBoost | +20% | 35◆ | 5 |
| mystic_3 | Essence Draw | essenceGain | +12% | 70◆ | 5 |
| mystic_4 | Chain Cast | abilityDamage | +20% | 130◆ | 5 |
| mystic_5 | Transcendence | abilityDamage | +25% | 250◆ | 5 |

### Elementalist Branch (elemental mastery)

*(Partial data — verify values in `lib/models/passive_tree.dart` → elementalist branch)*

### Ascendant Branch (prestige power)

| ID | Name | Effect | VAL/Rank | Cost/Rank | MaxRank |
|---|---|---|---|---|---|
| ascendant_0 | — | allDamage | +5% | 100◆ | 5 |
| ascendant_1 | — | goldPct | +20% | 200◆ | 5 |
| ascendant_2 | — | maxHp | +15% | 350◆ | 5 |
| ascendant_3 | — | abilityDamage | +20% | 550◆ | 5 |
| ascendant_4 | — | essenceGain | +25% | 800◆ | 5 |
| ascendant_5 | — | allDamage | +8% | 1200◆ | 5 |

### Keystones (maxRank 1)

| ID | Name | Cost | Effect |
|---|---|---|---|
| slayer_key | Bloodlust | 800◆ | +10% allDMG + auto-crit on kill |
| guardian_key | Unbreakable | 800◆ | +20% maxHP + survive 1 lethal hit |
| merchant_key | Midas | 800◆ | +50% gold + 2× gold on crit kills |
| mystic_key | Arcane Overflow | 800◆ | +50% abilityDMG + 15% double-cast |
| elementalist_key | Primordial Core | 800◆ | +10% PEN + weakness = 2× DMG |
| ascendant_key | Convergence Prime | 1500◆ | +15% allDMG + +10% to all passives |

### Cross-Branch Connectors (maxRank 3, cost 3◆)

| Name | Branches | Effect |
|---|---|---|
| Battlemage | Slayer + Mystic | +10% abilityDamage |
| Paladin's Oath | Guardian + Mystic | +15% healBoost |
| War Profiteer | Slayer + Merchant | +15% gold |
| Elemental Bulwark | Elementalist + Guardian | +5% allRes |
| Arcane Catalyst | Mystic + Elementalist | −1 ability CD |

### Class-Specific Nodes (maxRank 3, cost 150◆)

| Class | Node Name | Effect | VAL/Rank |
|---|---|---|---|
| Barbarian | Frenzy | allDamage | +5% |
| Fighter | Weapon Master | critChance | +4% |
| Rogue | Shadow Step | dodgeChance | +5% |
| Ranger | Marksman | pierce | +3 AC |
| Paladin | Holy Bastion | healBoost | +15% |
| Cleric | Divine Grace | regenFlat | +5 |
| Wizard | Spell Echo | abilityDamage | +12% |
| Sorcerer | Wild Magic | allDamage | +8% |
| Warlock | Soul Siphon | essenceGain | +15% |
| Bard | Encore | cooldownReduction | −1 |
| Monk | Inner Peace | *(see passive_tree.dart)* | — |
| Druid | *(see passive_tree.dart)* | — | — |

> File: `lib/models/passive_tree.dart`

---

## Enemies

All enemies have: `level`, `maxHealth` (HP), `attack` (ATK), `armorClass` (AC), `attackType` (damage type), `resistances` (map of DamageType → %).

Resistance values: positive = DMG mitigation %, negative = vulnerability %, cap = ±75%.
Named bosses (`namedBoss: true`) have boss abilities and do not auto-scale.

> File: `lib/data/enemy_data.dart`

### Undead
| ID | Name | Lv | HP | ATK | AC | Attack Type | Resistances |
|---|---|---|---|---|---|---|---|
| skeleton | Skeleton | 1 | 100 | 4 | 0 | Physical | Cold+25, Poison+75 |
| ghoul | Ghoul | 3 | 140 | 8 | 0 | Poison | Cold+25, Poison+50, Fire−25 |
| banshee | Banshee | 6 | 250 | 24 | 3 | Cold | Cold+75, Poison+75, Fire−50, Physical+25 |
| mummy | Mummy | 8 | 330 | 18 | 4 | Physical | Cold+50, Poison+75, Fire−25 |
| lich | Lich | 12 | 550 | 48 | 6 | Void | Cold+50, Poison+75, Physical+25, Fire−25 |

### Gremlins & Humanoids
| ID | Name | Lv | HP | ATK | AC | Attack Type | Resistances |
|---|---|---|---|---|---|---|---|
| goblin | Goblin | 1 | 95 | 4 | 0 | Physical | None |
| kobold | Kobold | 2 | 130 | 7 | 2 | Physical | None |
| gnoll | Gnoll | 4 | 165 | 10 | 2 | Physical | None |
| hobgoblin | Hobgoblin | 5 | 220 | 14 | 3 | Physical | Physical+15 |
| orc | Orc | 6 | 260 | 16 | 3 | Physical | Physical+10 |

### Beasts & Constructs
| ID | Name | Lv | HP | ATK | AC | Attack Type | Resistances |
|---|---|---|---|---|---|---|---|
| harpy | Harpy | 4 | 155 | 11 | 2 | Physical | Lightning+25 |
| gargoyle | Gargoyle | 7 | 300 | 18 | 5 | Physical | Physical+50, Poison+75, Fire−25 |
| basilisk | Basilisk | 7 | 320 | 19 | 3 | Physical | Poison+50, Cold−25 |
| golem | Golem | 9 | 400 | 18 | 4 | Physical | Physical+50, Poison+75, Cold+25, Lightning−25 |
| chimera | Chimera | 11 | 600 | 41 | 7 | Fire | Fire+75, Cold−50 |

### Demonic & Aberrant
| ID | Name | Lv | HP | ATK | AC | Attack Type | Resistances |
|---|---|---|---|---|---|---|---|
| imp | Imp | 2 | 110 | 7 | 2 | Fire | Fire+50, Cold−25 |
| cultist | Cultist | 5 | 175 | 18 | 2 | Void | Fire+25, Void+25 |
| succubus | Succubus | 9 | 300 | 24 | 3 | Void | Void+50, Fire+25 |
| eyeball_watcher | Eyeball Watcher | 10 | 350 | 25 | 2 | Void | Void+50, Cold−25 |
| mind_flayer | Mind-Flayer | 11 | 500 | 40 | 7 | Void | Void+75, Cold+25, Lightning−25 |

### Elemental & Mythical
| ID | Name | Lv | HP | ATK | AC | Attack Type | Resistances |
|---|---|---|---|---|---|---|---|
| pixie | Pixie | 3 | 65 | 9 | 5 | Void | Void+25 |
| wyvern | Wyvern | 8 | 220 | 20 | 4 | Poison | Physical+25, Cold−25 |
| minotaur | Minotaur | 10 | 240 | 20 | 3 | Physical | Physical+15 |
| hydra | Hydra | 12 | 550 | 44 | 7 | Poison | Poison+75, Cold−25 |
| phoenix | Phoenix | 13 | 515 | 48 | 7 | Fire | Fire+75, Cold−50 |

### Crystal & Arcane
| ID | Name | Lv | HP | ATK | AC | Attack Type | Resistances |
|---|---|---|---|---|---|---|---|
| crystal_shard | Crystal Shard | 13 | 700 | 52 | 5 | Physical | Physical+15, Lightning−25 |
| prism_wraith | Prism Wraith | 13 | 650 | 56 | 4 | Void | Void+50, Physical+50, Fire−25 |
| gem_serpent | Gem Serpent | 14 | 800 | 55 | 6 | Physical | Physical+25, Lightning+25, Cold−25 |
| crystal_guardian | Crystal Guardian | 14 | 740 | 57 | 9 | Physical | Physical+50, Poison+75, Lightning−25 |
| arcane_colossus | Arcane Colossus | 15 | 870 | 68 | 8 | Lightning | Lightning+75, Void+25, Physical+25, Fire−25 |

### Shadow & Darkness
| ID | Name | Lv | HP | ATK | AC | Attack Type | Resistances |
|---|---|---|---|---|---|---|---|
| shadow_stalker | Shadow Stalker | 15 | 580 | 70 | 5 | Physical | Void+25, Physical+25, Fire−25 |
| shade_assassin | Shade Assassin | 15 | 530 | 76 | 4 | Physical | Void+50, Physical+25, Lightning−25 |
| umbral_knight | Umbral Knight | 16 | 760 | 73 | 10 | Physical | Physical+40, Void+40, Fire−25 |
| dark_phantom | Dark Phantom | 16 | 620 | 80 | 5 | Void | Void+75, Physical+75, Fire−50 |
| shade_sovereign | Shade Sovereign | 17 | 1050 | 92 | 8 | Void | Void+75, Physical+50, Cold+25, Fire−50 |

### Ice & Cold
| ID | Name | Lv | HP | ATK | AC | Attack Type | Resistances |
|---|---|---|---|---|---|---|---|
| frost_sprite | Frost Sprite | 17 | 630 | 94 | 5 | Cold | Cold+75, Fire−50 |
| ice_wraith | Ice Wraith | 17 | 580 | 100 | 4 | Cold | Cold+75, Physical+50, Fire−50 |
| glacial_troll | Glacial Troll | 18 | 950 | 95 | 8 | Physical | Cold+50, Physical+25, Fire−50 |
| winter_wolf | Winter Wolf | 18 | 780 | 103 | 6 | Cold | Cold+75, Poison+25, Fire−50 |
| frost_dragon | Frost Dragon | 19 | 1300 | 118 | 9 | Cold | Cold+75, Physical+25, Fire−75 |

### Storm & Lightning
| ID | Name | Lv | HP | ATK | AC | Attack Type | Resistances |
|---|---|---|---|---|---|---|---|
| storm_hawk | Storm Hawk | 19 | 750 | 120 | 6 | Lightning | Lightning+50, Physical+15, Cold−25 |
| thunder_elemental | Thunder Elemental | 19 | 820 | 125 | 5 | Lightning | Lightning+75, Physical−25, Cold−25 |
| lightning_drake | Lightning Drake | 20 | 1050 | 122 | 7 | Lightning | Lightning+75, Physical+25, Cold−25 |
| storm_giant | Storm Giant | 20 | 1250 | 126 | 8 | Physical | Lightning+75, Physical+25, Poison−25 |
| storm_titan | Storm Titan | 21 | 1650 | 144 | 9 | Lightning | Lightning+75, Physical+25, Void+25, Cold−50 |

### Deep Sea & Abyss
| ID | Name | Lv | HP | ATK | AC | Attack Type | Resistances |
|---|---|---|---|---|---|---|---|
| deep_lurker | Deep Lurker | 21 | 1050 | 146 | 6 | Physical | Cold+25, Lightning−25 |
| tide_wraith | Tide Wraith | 21 | 960 | 153 | 5 | Cold | Cold+75, Physical+50, Lightning−50 |
| abyssal_shark | Abyssal Shark | 22 | 1300 | 150 | 7 | Physical | Physical+25, Cold+25, Lightning−25 |
| sea_colossus | Sea Colossus | 22 | 1600 | 148 | 10 | Physical | Physical+40, Cold+50, Fire−25 |
| krakentide | Krakentide | 23 | 2100 | 170 | 9 | Cold | Cold+75, Physical+25, Lightning−50 |

### Dream & Illusion
| ID | Name | Lv | HP | ATK | AC | Attack Type | Resistances |
|---|---|---|---|---|---|---|---|
| mirror_shade | Mirror Shade | 23 | 1250 | 172 | 6 | Void | Void+50, Physical+50, Fire−25 |
| echo_phantom | Echo Phantom | 23 | 1150 | 180 | 5 | Void | Void+75, Physical+50, Lightning−25 |
| dream_stalker | Dream Stalker | 24 | 1450 | 177 | 7 | Void | Void+50, Cold+25, Fire−25 |
| nightmare_weaver | Nightmare Weaver | 24 | 1350 | 188 | 6 | Void | Void+75, Physical+25, Cold−25 |
| labyrinth_warden | Labyrinth Warden | 25 | 2500 | 210 | 10 | Void | Void+75, Physical+50, Cold+25, Fire−25 |

### Ancient Constructs
| ID | Name | Lv | HP | ATK | AC | Attack Type | Resistances |
|---|---|---|---|---|---|---|---|
| archive_scribe | Archive Scribe | 25 | 1550 | 212 | 7 | Lightning | Lightning+50, Poison+75, Physical+25, Void−25 |
| assembly_drone | Assembly Drone | 25 | 1700 | 208 | 9 | Physical | Physical+40, Poison+75, Lightning−25 |
| vault_guardian | Vault Guardian | 26 | 2100 | 215 | 12 | Physical | Physical+50, Poison+75, Cold+25, Lightning−25 |
| protocol_enforcer | Protocol Enforcer | 26 | 1900 | 225 | 8 | Lightning | Lightning+75, Poison+75, Physical+25, Void−25 |
| eternal_sentinel | Eternal Sentinel | 27 | 3000 | 248 | 12 | Lightning | Lightning+75, Physical+50, Poison+75, Void−25 |

### Plague & Corruption
| ID | Name | Lv | HP | ATK | AC | Attack Type | Resistances |
|---|---|---|---|---|---|---|---|
| plague_rat | Plague Rat | 27 | 1800 | 250 | 6 | Poison | Poison+75, Cold−25 |
| infected_soldier | Infected Soldier | 27 | 2100 | 246 | 8 | Poison | Poison+75, Physical+25, Fire−25 |
| rot_priest | Rot Priest | 28 | 2000 | 262 | 6 | Poison | Poison+75, Void+25, Fire−25 |
| corruption_beast | Corruption Beast | 28 | 2700 | 258 | 9 | Poison | Poison+75, Physical+25, Fire−50 |
| plague_mother | Plague Mother | 29 | 3800 | 285 | 9 | Poison | Poison+75, Void+50, Physical+25, Fire−50 |

### Fallen Divine
| ID | Name | Lv | HP | ATK | AC | Attack Type | Resistances |
|---|---|---|---|---|---|---|---|
| broken_seraph | Broken Seraph | 29 | 2400 | 288 | 8 | Fire | Fire+75, Void−25, Cold−25 |
| divine_wraith | Divine Wraith | 29 | 2200 | 298 | 7 | Fire | Fire+75, Physical+50, Void−50 |
| fallen_cherub | Fallen Cherub | 30 | 2600 | 294 | 8 | Fire | Fire+75, Lightning+25, Void−25 |
| halo_specter | Halo Specter | 30 | 2450 | 308 | 7 | Fire | Fire+75, Physical+50, Cold−25, Void−25 |
| fallen_archangel | Fallen Archangel | 31 | 4500 | 335 | 10 | Fire | Fire+75, Lightning+50, Physical+25, Void−50 |

### Void & Null
| ID | Name | Lv | HP | ATK | AC | Attack Type | Resistances |
|---|---|---|---|---|---|---|---|
| null_sprite | Null Sprite | 31 | 2800 | 338 | 7 | Void | Void+75, Physical−25 |
| void_crawler | Void Crawler | 31 | 3100 | 332 | 8 | Void | Void+75, Physical+25, Fire−25 |
| antimatter_construct | Anti-Matter Construct | 32 | 3600 | 340 | 10 | Void | Void+75, Physical+50, Poison+75, Fire−25 |
| entropy_fiend | Entropy Fiend | 32 | 3300 | 355 | 8 | Void | Void+75, Cold+25, Fire−25 |
| null_emperor | Null Emperor | 33 | 5500 | 385 | 12 | Void | Void+75, Physical+50, Cold+25, Fire−50 |

### Imprisoned Horrors
| ID | Name | Lv | HP | ATK | AC | Attack Type | Resistances |
|---|---|---|---|---|---|---|---|
| shackle_beast | Shackle Beast | 33 | 4200 | 388 | 9 | Physical | Physical+40, Poison+50, Lightning−25 |
| omega_warden | Omega Warden | 33 | 4600 | 382 | 12 | Lightning | Lightning+75, Physical+50, Poison+75, Void−25 |
| containment_golem | Containment Golem | 34 | 5500 | 390 | 14 | Physical | Physical+50, Poison+75, Cold+25, Lightning−25 |
| cell_breaker | Cell Breaker | 34 | 4800 | 405 | 9 | Physical | Physical+40, Void+50, Cold−25 |
| the_unbound | The Unbound | 35 | 7000 | 435 | 14 | Void | Void+75, Physical+50, Fire+25, Cold−25 |

### Abyss Guardians
| ID | Name | Lv | HP | ATK | AC | Attack Type | Resistances |
|---|---|---|---|---|---|---|---|
| gate_crawler | Gate Crawler | 35 | 5200 | 438 | 9 | Void | Void+75, Physical+25, Fire−25 |
| sentinel_wraith | Sentinel Wraith | 35 | 4800 | 448 | 8 | Void | Void+75, Physical+75, Fire−50 |
| watcher_construct | Watcher Construct | 36 | 6000 | 445 | 12 | Lightning | Lightning+75, Poison+75, Physical+25, Void−25 |
| siege_engine | Siege Engine | 36 | 7000 | 442 | 14 | Physical | Physical+50, Poison+75, Lightning−25 |
| gate_colossus | Gate Colossus | 37 | 9500 | 480 | 16 | Physical | Physical+50, Lightning+50, Poison+75, Void−25 |

### Divine Carrion
| ID | Name | Lv | HP | ATK | AC | Attack Type | Resistances |
|---|---|---|---|---|---|---|---|
| carrion_crawler | Carrion Crawler | 37 | 6500 | 483 | 9 | Poison | Poison+75, Physical+25, Fire−25 |
| god_shard_elemental | God-Shard Elemental | 37 | 7200 | 478 | 10 | Fire | Fire+75, Physical+25, Void−25 |
| necrotic_abomination | Necrotic Abomination | 38 | 8500 | 486 | 10 | Poison | Poison+75, Cold+25, Fire−25, Physical+25 |
| scar_feeder | Scar Feeder | 38 | 7800 | 498 | 9 | Void | Void+75, Poison+50, Fire−25 |
| the_devourer | The Devourer | 39 | 12000 | 530 | 14 | Void | Void+75, Poison+75, Physical+25, Fire−25 |

### Edge of Existence
| ID | Name | Lv | HP | ATK | AC | Attack Type | Resistances |
|---|---|---|---|---|---|---|---|
| boundary_wraith | Boundary Wraith | 39 | 8500 | 533 | 10 | Void | Void+75, Physical+50, Fire−25 |
| no_return_specter | No-Return Specter | 39 | 9000 | 528 | 9 | Void | Void+75, Physical+75, Fire−50 |
| void_membrane | Void Membrane | 40 | 11000 | 540 | 12 | Void | Void+75, Physical+50, Cold+25, Fire−25 |
| last_light_seraph | Last Light Seraph | 40 | 10000 | 555 | 10 | Fire | Fire+75, Lightning+50, Void−50 |
| frontier_guardian | Frontier Guardian | 41 | 15000 | 590 | 16 | Void | Void+75, Physical+50, Fire+25, Cold−25 |

### Omega Throne
| ID | Name | Lv | HP | ATK | AC | Attack Type | Resistances |
|---|---|---|---|---|---|---|---|
| omega_herald | Omega Herald | 41 | 11000 | 593 | 12 | Void | Void+75, Physical+50, Fire+25, Cold−25 |
| memory_shade | Memory Shade | 41 | 10500 | 605 | 10 | Void | Void+75, Physical+75, Fire−50 |
| dark_hour_titan | Dark Hour Titan | 42 | 14000 | 615 | 14 | Void | Void+75, Physical+50, Cold+25, Fire−25 |
| throne_sentinel | Throne Sentinel | 42 | 16000 | 620 | 16 | Void | Void+75, Physical+50, Lightning+50, Fire−25 |
| **the_omega** | **The Omega** | **43** | **25000** | **660** | **18** | **Void** | Void+75, Physical+50, Fire+50, Cold+50, Lightning−25 |

### Named Campaign Bosses

Named bosses have `namedBoss: true` and do not auto-scale. They have boss abilities with their own CDs.

| ID | Name | Lv | HP | ATK | AC | Boss Abilities |
|---|---|---|---|---|---|---|
| goblin_warchief | Goblin Warchief | 4 | 260 | 16 | 2 | Frenzy Strike (Phys+50, CD4), Poisoned Blade (DMG20×3r, CD6) |
| necromancer_vael | Necromancer Vael | 7 | 650 | 42 | 5 | Soul Drain (VoidDMG35×3r, CD4), Death Spike (Cold+80, CD5) |
| pharaoh_kethran | Pharaoh Kethran | 9 | 850 | 55 | 7 | Ancient Curse (VoidDMG30×3r, CD4), Crushing Blow (Phys+90, CD6) |
| the_tyrant_eye | The Tyrant Eye | 12 | 1200 | 75 | 7 | Disintegration Beam (Void+100, CD5), Petrifying Gaze (STUN, CD6) |
| lich_emperor | Lich Emperor | 14 | 2000 | 115 | 9 | *(see enemy_data.dart)* |

---

## Status Effects Reference

These are the 13 `AbilityEffect` enum values used in the combat system.

| Effect | Type | What it does | Relevant Fields |
|---|---|---|---|
| bonusDamage | Damage | Deals DMG on cast | DMG, overrideDamageType, PEN |
| heal | Buff | Restores HEAL% of max HP | HEAL |
| attackBonus | Buff | +VAL% crit chance for DUR rounds (displayed as "Damage Buff") | VAL, DUR |
| acBonus | Buff | +VAL effective AC for DUR rounds | VAL, DUR |
| stun | CC | Enemy skips DUR turns (DR applies) | DUR |
| dot | DoT | DMG flat damage per round for DUR rounds | DMG, DUR |
| dodge | Buff | Negate next DUR incoming attacks | DUR |
| aura | Buff | HEALs HEAL% max HP per round for DUR rounds | HEAL, DUR |
| debuffWeaken | Debuff | Enemy ATK reduced by VAL% for DUR rounds | VAL, DUR |
| debuffVulnerable | Debuff | Enemy takes VAL% more DMG for DUR rounds | VAL, DUR |
| silence | CC | Enemy cannot use any boss abilities for DUR rounds | DUR |
| absorbShield | Buff | Creates a VAL HP barrier that absorbs DMG before HP | VAL |
| missChance | Debuff | Enemy has VAL% chance to miss each attack for DUR rounds | VAL, DUR |

**Special `baseBonus` field:** An extra effect on an ability that fires on every cast alongside the primary effect (not milestone-gated). Example: Warlock's Hex has `baseBonus: heal` — HEALs 10% HP on every cast.

**Display colors:**
| Effect | Color |
|---|---|
| bonusDamage | Orange/red |
| heal | Green |
| attackBonus | Gold |
| acBonus | Blue-grey |
| stun | Purple |
| dot | Dark red/crimson |
| dodge | Cyan |
| aura | Lime green |
| debuffWeaken | Orange |
| debuffVulnerable | Red-orange |
| silence | Yellow (`#ffdd00`) |
| absorbShield | Sky blue (`#66bbff`) |
| missChance | Lavender (`#aaaaff`) |

---

## NPC Allies (Mercs)

Companions that join permanently when you hit a milestone. Each ally has a passive bonus scaling with level (max 5), a unique active ability in battle, and talent branches at LV3 and LV5.

**Level-up costs:** LV2 = 20◆ | LV3 = 50◆ + 5🪙 | LV4 = 120◆ + 15🪙 | LV5 = 250◆ + 35🪙

> File: `lib/models/npc_ally.dart`, `lib/screens/npc_ally_screen.dart`

| ID | Name | Title | Icon | Unlock Condition | Bonus/Level | Active Ability |
|---|---|---|---|---|---|---|
| greybeard | Greybeard | Veteran Sellsword | ⚔️ | 100 total kills | +3 ATK | War Cry: +5 DMG for 4 rounds at battle start |
| mira | Mira | Battle Medic | 🩹 | Reach stage 10 | +15% HP | Field Triage: heal 25% HP when HP < 30% (once/battle) |
| coin_felix | Felix | Merchant Prince | 💰 | Reach stage 15 | +20% Gold | Bribe: first kill grants double gold (once/battle) |
| elder_voss | Elder Voss | Arcane Scholar | 📚 | Prestige 1 | +20% XP | Arcane Surge: deal 10% enemy max HP at battle start |
| ironhide | Ironhide | Dwarven Armorsmith | 🛡️ | 5 dungeon clears | +3 AC | Shield Wall: block next hit when HP < 50% (once/battle) |
| shadow_lena | Lena | Shadow Rogue | 🗡️ | Complete a Boss Rush | +15% Shards | Backstab: first attack is guaranteed crit |
| golem_ruk | Ruk | Stone Golem | 🗿 | Ascend once | +25% Idle | Stone Skin: reduce incoming damage by 4 for first 5 enemy attacks |
| warmaster_cael | Cael | Warmaster | 🏆 | Gauntlet score ≥ 1000 | +5 DMG | Warmaster's Strike: on first crit, deal 15% enemy max HP bonus damage |

### Ally Talent Branches (LV3 / LV5)

| Ally | LV3-A | LV3-B | LV5-A | LV5-B |
|---|---|---|---|---|
| Greybeard | Iron Resolve (+6 ATK) | Tactical Mind (+3 ATK, +3 AC) | Warlord's Edge (+12 ATK) | Battle Master (+6 ATK, +6 DMG) |
| Mira | Regenerative Herbs (+20% HP) | Trauma Medicine (+10% HP, +2 AC) | Master Healer (+35% HP) | Life Weaver (+20% HP, +10% Gold) |
| Felix | Merchant Network (+20% Gold) | Thief's Fence (+10% Gold, +10% Shards) | Golden Touch (+40% Gold) | Black Market (+20% Gold, +15% Shards) |
| Elder Voss | Sage's Knowledge (+20% XP) | Arcane Studies (+10% XP, +8% Shards) | Grand Master (+40% XP) | Forbidden Lore (+25% XP, +10% Shards) |
| Ironhide | Tempered Steel (+5 AC) | Living Fortress (+3 AC, +10% HP) | Bulwark (+8 AC) | Diamond Plating (+5 AC, +4 DMG) |
| Lena | Shadow Step (+15% Shards) | Knife Collector (+8% Shards, +3 ATK) | Master Thief (+25% Shards) | Shadow Arts (+15% Shards, +4 DMG) |
| Ruk | Stone Sentinel (+25% Idle) | Ancient Power (+15% Idle, +3 AC) | Mountain King (+50% Idle) | Primordial Might (+30% Idle, +4 ATK) |
| Cael | Brutal Strikes (+6 DMG) | War Veteran (+3 DMG, +4 ATK) | Conqueror (+12 DMG) | Champion's Aura (+7 DMG, +4 AC) |

### Ally Synergies (both allies owned at minimum level)

| ID | Name | Allies | Min Level | Bonus |
|---|---|---|---|---|
| war_veterans | War Veterans | Greybeard + Cael | 2 | +3 ATK, +3 DMG |
| iron_bulwark | Iron Bulwark | Mira + Ironhide | 2 | +2 AC, +10% HP |
| shadow_market | Shadow Market | Felix + Lena | 2 | +15% Gold, +10% Shards |
| ancient_wisdom | Ancient Wisdom | Elder Voss + Ruk | 2 | +10% XP, +15% Idle |
| steel_brotherhood | Steel Brotherhood | Greybeard + Ironhide | 3 | +2 ATK, +2 AC |
| learned_merchant | Learned Merchant | Felix + Elder Voss | 3 | +20% Gold, +10% XP |
| blade_mastery | Blade Mastery | Lena + Cael | 3 | +5 DMG, +10% Shards |

---

## Expeditions

Send an unlocked merc on a timed offline resource run. 4 locations rotate daily (seeded). Each merc can run one expedition at a time. Unlocks at stage 40.

> File: `lib/models/expedition.dart`, `lib/screens/expedition_screen.dart`

### Durations

| Duration | Real Time | Reward Multiplier |
|---|---|---|
| Short | 30 min | ×1 |
| Medium | 2 hr | ×4 |
| Long | 8 hr | ×14 |

### Biomes & Reward Focus

| Biome | Icon | Reward Focus |
|---|---|---|
| Graveyard | 🪦 | 💰 Gold · ◆ Shards |
| Cave | 🗻 | ◆ Shards · ✦ Essence |
| Temple | 🏛 | ✦ Essence · 💰 Gold |
| Fortress | 🏰 | 💰 Gold · ⬡ Mythril |
| Ruin | 🏚 | All resources (balanced) |
| Dungeon | ⛓ | ◆ Shards · 🪙 ZCoins |
| Catacombs | 💀 | ✦ Essence · ◆ Shards |
| Sanctum | ✨ | ✦ Essence · 🪙 ZCoins |
| Barrows | ⚰ | 💰 Gold · ✦ Essence |
| High Pass | 🏔 | ⬡ Mythril · 🔊 Echoes |

---

## Game Modes

### Campaign
- Infinite auto-combat: hero fights enemies one at a time in order.
- `kDungeonMaxAttempts = 3` (refill after 24h, buy extra for 40 crystals each).

### Dungeon
- Multi-room challenge with increasing difficulty.
- Max 3 attempts/day; extra attempt costs 40 crystals.

### Boss Rush
- Sequential boss fights with tight HP restrictions.
- Max 2 attempts/day; extra attempt costs 50 crystals.

### Gauntlet
- Survival mode: fight as many enemies as possible.
- Max 5 attempts/day; extra attempt costs 30 crystals.

### PvP
- 5 stamina max; 1 stamina consumed per match; 45-minute recharge per stamina.
- D&D-style combat simulation. Firestore leaderboard in `pvp_players` collection.

### Daily Challenges
- 7 challenges per day (seeded, 8 types rotated).
- Completing all 7 grants the daily chest: +1000g, +75◆, +50 essence, +50 crystals.

---

## Ability Score System (Endless)

The Ability Score track (separate from D&D stats) allows endless stat investment.
- Max rank: **50** per score.
- Unlocked through gameplay milestones.

> See `lib/models/endless_upgrades.dart` for the full endless upgrade tree.

---

## Notes

- Elementalist passive branch node details: verify in `lib/models/passive_tree.dart`.
- Monk and Druid class-specific passive node details: verify in `lib/models/passive_tree.dart`.

---

## Progression Systems

Every system listed below, when it unlocks, and where its code lives.

| System | Unlocks At | Screen File | Model / Data File |
|---|---|---|---|
| Campaign | Always | [campaign_screen.dart](lib/screens/campaign_screen.dart) | — |
| Daily Challenges | Stage 5 | [daily_screen.dart](lib/screens/daily_screen.dart) | — |
| Quests | Stage 10 | [quest_screen.dart](lib/screens/quest_screen.dart) | [class_quest.dart](lib/models/class_quest.dart) |
| Dungeon | Stage 15 | [dungeon_screen.dart](lib/screens/dungeon_screen.dart) | [dungeon.dart](lib/models/dungeon.dart) |
| Guild | Stage 15 | [guild_screen.dart](lib/screens/guild_screen.dart) | — |
| Bounties | Stage 20 | [bounty_board_screen.dart](lib/screens/bounty_board_screen.dart) | — |
| Boss Rush | Stage 25 | [boss_rush_screen.dart](lib/screens/boss_rush_screen.dart) | — |
| Armory | Stage 28 | [armory_screen.dart](lib/screens/armory_screen.dart) | — |
| World Events | Stage 30 | [world_event_screen.dart](lib/screens/world_event_screen.dart) | — |
| Tower Ascension | Stage 35 | [rebirth_flow_screen.dart](lib/screens/rebirth_flow_screen.dart) | — |
| Expedition | Stage 40 | [expedition_screen.dart](lib/screens/expedition_screen.dart) | [expedition.dart](lib/models/expedition.dart) |
| Gauntlet | Stage 45 | [gauntlet_screen.dart](lib/screens/gauntlet_screen.dart) | — |
| PvP | Stage 50 | [pvp_screen.dart](lib/screens/pvp_screen.dart) | [pvp.dart](lib/models/pvp.dart) |
| Hard Mode (Campaign) | Stage 50 | [campaign_screen.dart](lib/screens/campaign_screen.dart) | — |
| Bestiary | Stage 55 | [bestiary_screen.dart](lib/screens/bestiary_screen.dart) | — |
| Prestige / Rebirth Gates | Stage 25 / 50 / 75 / 100 | [prestige_screen.dart](lib/screens/prestige_screen.dart) | — |
| Endless Mode | After Prestige 1 | [endless_screen.dart](lib/screens/endless_screen.dart) | [endless_upgrades.dart](lib/models/endless_upgrades.dart) |
| Runes | Endless stage 10+ | [rune_screen.dart](lib/screens/rune_screen.dart) | — |
| Ascension | After Prestige 3 (approx.) | [ascension_screen.dart](lib/screens/ascension_screen.dart) | — |
| Passive Tree | Always | [passive_tree_screen.dart](lib/screens/passive_tree_screen.dart) | [passive_tree.dart](lib/models/passive_tree.dart) |
| Pets | ZCoin shop (any stage) | [pet_screen.dart](lib/screens/pet_screen.dart) | [pet.dart](lib/models/pet.dart) |
| NPC Allies (Mercs) | See Mercs table above | [npc_ally_screen.dart](lib/screens/npc_ally_screen.dart) | [npc_ally.dart](lib/models/npc_ally.dart) |
| Skins / Auras | ZCoin / Crystal shop | [aura_shop_screen.dart](lib/screens/aura_shop_screen.dart) | — |
| Artifacts | *(see artifact_screen.dart)* | [artifact_screen.dart](lib/screens/artifact_screen.dart) | — |
| Class Mastery | *(see mastery_screen.dart)* | [mastery_screen.dart](lib/screens/mastery_screen.dart) | [class_mastery_data.dart](lib/data/class_mastery_data.dart) |
| Ability Scores | Stage 1 (first progression unlock) | [ability_scores_screen.dart](lib/screens/ability_scores_screen.dart) | [hero_model.dart](lib/models/hero_model.dart) |
