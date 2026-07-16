"""
Zeta Idle — All-Class Campaign Simulation (Stage 1→100)
Uses current game formulas:
  • HP:  100 + (level-1) * 20  (plus CON scaling)
  • XP per level: *= 1.18, starting at 100
  • XP reward:  enemy.level * 20 + 40
  • Damage:  d8 + level//2 + stat_mod; crit doubles die
  • Boss: stats * 1.5 HP, * 1.15 ATK (from game code)
"""
import random, statistics

# ── Enemy table ────────────────────────────────────────────────────────────────
# (level, hp, attack, ac)  – current values from enemy_data.dart
ENEMIES = [
    # Zone 1: Cursed Realm (stages 1-5)
    (1,100,4,10),(1,95,4,10),(2,110,7,11),(2,130,7,11),(4,260,16,11),   # boss at 5
    # Zone 2: Blighted Wilds (stages 6-10)
    (3,140,8,10),(4,155,11,11),(4,165,10,11),(5,175,18,11),(6,400,20,13), # boss at 10
    # Zone 3: Infernal Depths (11-15)
    (6,250,16,12),(6,250,24,12),(7,300,18,14),(7,320,19,12),(8,600,22,13), # boss at 15
    # Zone 4: Shadow Keep (16-20)
    (8,330,18,13),(9,300,24,12),(9,400,18,13),(10,350,25,11),(10,900,30,15), # boss at 20
    # Zone 5: Frozen Wastes (21-25)
    (10,500,40,16),(11,600,41,16),(12,550,48,15),(12,700,44,16),(14,1400,60,17), # boss at 25
    # Zone 6: Abyssal Ocean (26-30)
    (13,650,56,13),(13,800,55,15),(14,850,57,18),(15,870,68,17),(16,1800,75,18), # boss at 30
    # Zone 7: Shadow Realm (31-35)
    (15,580,70,14),(15,530,76,13),(16,760,73,19),(16,620,80,14),(18,2200,90,19), # boss at 35
    # Zone 8: Frozen Peaks (36-40)
    (17,1050,92,17),(17,630,94,14),(17,580,100,13),(18,950,95,17),(20,2800,110,20), # boss at 40
    # Zone 9: Abyss Gate (41-45)
    (19,1300,118,18),(19,750,120,15),(19,820,125,14),(20,1050,122,16),(22,3500,130,21), # boss at 45
    # Zone 10: Omega Throne (46-50)
    (21,1650,144,18),(21,1050,146,15),(21,960,153,14),(22,1300,150,16),(24,4500,165,22), # boss at 50
    # Zones 11-20: continuing pattern with growth
    (23,2100,170,18),(23,1250,172,15),(23,1150,180,14),(24,1450,177,16),(26,5500,190,22),
    (25,2500,210,19),(25,1550,212,16),(25,1700,208,18),(26,2100,215,20),(28,6500,225,23),
    (27,3000,248,20),(27,1800,250,15),(27,2100,246,17),(28,2000,262,15),(30,7800,270,23),
    (29,3800,285,18),(29,2400,288,17),(29,2200,298,16),(30,2600,294,17),(32,9500,310,24),
    (31,4500,335,19),(31,2800,338,16),(31,3100,332,17),(32,3600,340,19),(34,11000,355,24),
    (33,5500,385,20),(33,4200,388,18),(33,4600,382,20),(34,5500,390,21),(36,13500,405,25),
    (35,7000,435,21),(35,5200,438,18),(35,4800,448,17),(36,6000,445,20),(38,16000,460,25),
    (37,9500,480,22),(37,6500,483,18),(37,7200,478,19),(38,8500,486,19),(40,19000,510,26),
    (39,12000,530,21),(39,8500,533,19),(39,9000,528,18),(40,11000,540,20),(42,22000,560,26),
    (41,15000,590,22),(41,11000,593,20),(41,10500,605,19),(42,14000,615,21),(44,26000,630,27),
    (43,19000,660,23),(43,14000,665,21),(43,13000,675,20),(44,17000,680,22),(46,30000,700,27),
]

BOSS_STAGES = set(range(4, 100, 5))

def get_enemy(stage):
    # ENEMIES table already contains final boss stats (namedBoss).
    # No multiplier applied — bosses are harder than regular enemies by design of their stats.
    lv, hp, atk, ac = ENEMIES[stage]
    return lv, hp, atk, ac

# ── Class definitions ──────────────────────────────────────────────────────────
# (display_name, str, dex, con, int, wis, cha, primary_stat, secondary_stat, dmg_type)
CLASSES = {
    'Fighter':     ('Fighter',    13, 10, 14, 8,  10, 8,  'str', 'con', 'physical'),
    'Barbarian':   ('Barbarian',  15, 10, 14, 7,  10, 8,  'str', 'con', 'physical'),
    'Paladin':     ('Paladin',    13, 8,  14, 8,  10, 12, 'str', 'cha', 'physical'),
    'Rogue':       ('Rogue',       8, 15, 13, 14, 12, 10, 'dex', 'int', 'poison'),
    'Ranger':      ('Ranger',     10, 14, 13, 8,  12, 10, 'dex', 'wis', 'cold'),
    'Monk':        ('Monk',       10, 15, 14, 8,  14, 8,  'dex', 'wis', 'lightning'),
    'Cleric':      ('Cleric',     10, 8,  14, 8,  15, 8,  'wis', 'con', 'fire'),
    'Druid':       ('Druid',      10, 10, 14, 12, 14, 8,  'wis', 'con', 'physical'),
    'Wizard':      ('Wizard',      8, 12, 13, 15, 14, 10, 'int', 'wis', 'lightning'),
    'Sorcerer':    ('Sorcerer',    8, 10, 13, 12, 8,  15, 'cha', 'int', 'void'),
    'Warlock':     ('Warlock',     9, 10, 13, 12, 9,  15, 'cha', 'int', 'fire'),
    'Bard':        ('Bard',        9, 12, 13, 10, 10, 15, 'cha', 'dex', 'void'),
}

# Enemy resistance to damage types (% mitigation, simplified)
# Physical: mostly 0. Elemental: varies by enemy zone.
DAMAGE_RES = {
    'physical':   0.00,
    'fire':       0.00,  # slight edge on undead early but balanced overall
    'cold':       0.00,
    'lightning':  0.00,
    'poison':     0.00,
    'void':       0.00,
}

class Hero:
    def __init__(self, cls_key):
        _, s, d, c, i, w, ch, pri, sec, dmg = CLASSES[cls_key]
        self.str_ = s; self.dex = d; self.con = c
        self.int_ = i; self.wis = w; self.cha = ch
        self.primary = pri; self.secondary = sec
        self.dmg_type = dmg
        self.lvl = 1
        self.xp = 0; self.xpn = 100
        self._recalc()

    def _recalc(self):
        lv = self.lvl
        # Primary combat stat for this class
        attr = {'str': 'str_', 'dex': 'dex', 'con': 'con', 'int': 'int_', 'wis': 'wis', 'cha': 'cha'}
        pri_val = getattr(self, attr[self.primary])
        pri_mod = (pri_val - 10) // 2
        prof = 2 + (lv - 1) // 4
        self.ab  = prof + pri_mod       # attack bonus
        self.dmb = lv // 2 + pri_mod   # damage bonus (flat)
        con_mod  = (self.con - 10) // 2
        # HP: 100 + (level-1)*20 base + CON bonus (constitution * 0.01 * base % boost)
        base_hp  = 100 + (lv - 1) * 20
        self.mhp = round(base_hp * (1 + self.con / 100))
        self.ac  = 10 + (self.dex - 10) // 2

    def level_up(self):
        self.lvl += 1
        self.xpn  = round(self.xpn * 1.18)
        def bump(stat):
            m = {'str': 'str_', 'dex': 'dex', 'con': 'con', 'int': 'int_', 'wis': 'wis', 'cha': 'cha'}
            a = m[stat]; setattr(self, a, min(100, getattr(self, a) + 1))
        bump(self.primary)
        if self.lvl % 2 == 0:
            bump(self.secondary)
        # CON +1 every 3 levels for all classes (vitality always scales)
        if self.lvl % 3 == 0:
            self.con = min(100, self.con + 1)
        if self.lvl % 10 == 0:
            self.dmb += 2  # level bonus damage pct (simplified as flat)
        self._recalc()

    def gain_xp(self, enemy_lv):
        reward = enemy_lv * 20 + 40
        self.xp += reward
        while self.xp >= self.xpn:
            self.xp -= self.xpn
            self.level_up()

def item_bonus(stage):
    """Zone-based item scaling (attack, damage, ac) - same as before but updated."""
    z = stage // 10
    ia = [0, 5, 10, 16, 23, 31, 40, 50, 61, 73][z]
    id_= [0, 5, 10, 16, 23, 31, 40, 50, 61, 73][z]
    ic = [0, 4,  8, 12, 17, 22, 27, 33, 39, 45][z]
    return ia, id_, ic

def battle(hero, stage, ia, id_, ic, rng):
    elv, ehp, eatk, eac = get_enemy(stage)
    hhp  = hero.mhp
    hab  = hero.ab + ia
    hdmb = hero.dmb + id_
    hac  = hero.ac + ic
    eb   = elv // 2

    for rd in range(3000):
        # Hero attacks
        roll = rng.randint(1, 20)
        crit = (roll == 20)
        if crit or roll + hab >= eac:
            die = rng.randint(1, 8)
            if crit: die += rng.randint(1, 8)
            raw_dmg = max(1, die + hdmb)
            # Apply resistance (enemy resistance to hero damage type)
            res = DAMAGE_RES.get(hero.dmg_type, 0)
            dmg = max(1, round(raw_dmg * (1 - res)))
            ehp -= dmg
        if ehp <= 0:
            return True, rd + 1

        # Enemy attacks
        er = rng.randint(1, 20)
        if er + eb >= hac:
            hhp -= rng.randint(1, max(1, eatk))
        if hhp <= 0:
            return False, rd + 1

    return ehp <= 0, 3000

def simulate_class(cls_key, seed=42, max_tries=500, replays_per_stage=3):
    """
    replays_per_stage: how many times a player clears each normal stage for XP
                       before advancing (simulates energy grind before a boss).
    """
    rng  = random.Random(seed)
    hero = Hero(cls_key)
    log  = []
    stuck_stage = None

    for stage in range(100):
        ia, id_, ic = item_bonus(stage)
        is_boss = stage in BOSS_STAGES

        # For normal stages, player clears multiple times for XP (energy grind)
        xp_runs = 1 if is_boss else replays_per_stage
        for _ in range(xp_runs - 1):  # extra XP runs before the "real" attempt
            won, _ = battle(hero, stage, ia, id_, ic, rng)
            if won:
                hero.gain_xp(get_enemy(stage)[0])

        # Sample win rate AFTER grinding
        sample_wins = sum(1 for _ in range(20) if battle(hero, stage, ia, id_, ic, rng)[0])
        win_pct = sample_wins * 5

        stage_rounds = 0
        attempts = 0
        won_it = False
        while attempts < max_tries:
            won, rds = battle(hero, stage, ia, id_, ic, rng)
            stage_rounds += rds
            attempts += 1
            if won:
                hero.gain_xp(get_enemy(stage)[0])
                won_it = True
                break

        avg_rds = stage_rounds // max(1, attempts)
        log.append({
            'stage': stage + 1,
            'hero_lv': hero.lvl,
            'avg_rds': avg_rds,
            'win_pct': win_pct,
            'tries': attempts,
            'boss': is_boss,
            'won': won_it,
        })

        if not won_it:
            stuck_stage = stage + 1
            break

    return log, hero.lvl, stuck_stage

# ── Run all classes ────────────────────────────────────────────────────────────

SEEDS = 3
print("=" * 80)
print("ZETA IDLE — ALL-CLASS SIMULATION (Stage 1 → 100)")
print("=" * 80)

BOSS_ZONES = {5:'Goblin Warchief',10:'Necromancer Vael',15:'Pharaoh Kethran',
               20:'The Tyrant Eye',25:'Lich Emperor',30:'Prism Lord',
               35:'Shadow King',40:'Glacier Wyrm',45:'King of Storms',
               50:'Leviathan',55:'The Dreaming God',60:'Prime Emperor',
               65:'God of Rot',70:'The Void God',75:'Null Sovereign',
               80:'The First Prisoner',85:'Gate Titan',90:'God Eater',
               95:'World Ender',100:'OMEGA ABSOLUTE'}

summary = []
for cls_key, (cls_name, *_) in CLASSES.items():
    all_stuck = []
    all_final_lv = []
    worst_boss = None

    for seed in range(SEEDS):
        log, final_lv, stuck = simulate_class(cls_key, seed=seed)
        all_final_lv.append(final_lv)
        if stuck:
            all_stuck.append(stuck)
            if worst_boss is None or stuck < worst_boss:
                worst_boss = stuck

    avg_lv = round(statistics.mean(all_final_lv))
    dmg_type = CLASSES[cls_key][-1]

    if all_stuck:
        status = f"STUCK at stage {worst_boss} ({BOSS_ZONES.get(worst_boss, '?')})"
    else:
        status = "✓ COMPLETE (100/100)"

    summary.append((cls_name, dmg_type, avg_lv, status, len(all_stuck), worst_boss))

# Print summary table
print(f"\n{'Class':<12} {'Dmg Type':<12} {'Avg Lv':<9} {'Fails':<8} {'Result'}")
print("-" * 80)
for cls_name, dmg_type, avg_lv, status, fails, stuck in sorted(summary, key=lambda x: (x[4], -(x[2]))):
    fail_str = f"{fails}/{SEEDS}" if fails else "   0/3"
    print(f"{cls_name:<12} {dmg_type:<12} {avg_lv:<9} {fail_str:<8} {status}")

# ── Detailed per-boss breakdown for each class ─────────────────────────────────
print("\n" + "=" * 80)
print("BOSS FIGHTS DETAIL (seed=42)")
print("=" * 80)

for cls_key, (cls_name, *_) in CLASSES.items():
    log, final_lv, stuck = simulate_class(cls_key, seed=42)
    boss_log = [e for e in log if e['boss']]
    dmg_type = CLASSES[cls_key][-1]
    stuck_str = f"  ← STUCK" if stuck else ""
    print(f"\n{cls_name} [{dmg_type}] — final lv {final_lv}{stuck_str}")
    print(f"  {'Stage':<8} {'Boss Name':<24} {'HeroLv':<8} {'Win%':<7} {'Tries':<7} {'Avg Rds'}")
    for e in boss_log:
        boss_name = BOSS_ZONES.get(e['stage'], '?')
        warn = " ⚠" if e['win_pct'] < 40 else (" ★" if e['win_pct'] == 100 else "")
        print(f"  S{e['stage']:<7} {boss_name:<24} Lv{e['hero_lv']:<6} {e['win_pct']:>3}%   "
              f"{e['tries']:<7} {e['avg_rds']}{warn}")

print("\n" + "=" * 80)
print("Done. Key:")
print("  ✓ = Completed all 100 stages")
print("  ⚠ = Boss win rate < 40% (hard fight)")
print("  ★ = Perfect win rate (too easy)")
print("  Item model: +5→73 ATK/DMG bonus per zone; +4→45 AC bonus per zone")
print("  Energy system NOT modelled (infinite attempts per session assumed)")
