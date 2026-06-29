"""
Zeta Idle — Campaign Time Simulation
Pure Monte Carlo: runs actual battles, tracks total rounds.
"""
import random

ENEMIES = [
    (1,55,4,10),(1,52,4,10),(2,60,7,11),(2,85,7,11),(3,65,9,14),
    (3,82,8,10),(4,100,10,11),(4,88,11,11),(5,95,18,11),(5,140,14,12),
    (6,160,16,12),(6,145,24,12),(7,180,18,14),(7,200,19,12),(8,195,18,13),
    (8,220,20,13),(9,240,18,13),(9,175,24,12),(10,240,20,12),(10,200,25,11),
    (11,310,40,16),(11,385,41,16),(12,335,48,15),(12,550,44,16),(13,515,48,16),
    (13,550,52,14),(13,500,56,13),(14,650,55,15),(14,740,57,18),(15,870,68,17),
    (15,580,70,14),(15,530,76,13),(16,760,73,19),(16,620,80,14),(17,1050,92,17),
    (17,630,94,14),(17,580,100,13),(18,950,95,17),(18,780,103,15),(19,1300,118,18),
    (19,750,120,15),(19,820,125,14),(20,1050,122,16),(20,1250,126,17),(21,1650,144,18),
    (21,1050,146,15),(21,960,153,14),(22,1300,150,16),(22,1600,148,19),(23,2100,170,18),
    (23,1250,172,15),(23,1150,180,14),(24,1450,177,16),(24,1350,188,15),(25,2500,210,19),
    (25,1550,212,16),(25,1700,208,18),(26,2100,215,20),(26,1900,225,17),(27,3000,248,20),
    (27,1800,250,15),(27,2100,246,17),(28,2000,262,15),(28,2700,258,18),(29,3800,285,18),
    (29,2400,288,17),(29,2200,298,16),(30,2600,294,17),(30,2450,308,16),(31,4500,335,19),
    (31,2800,338,16),(31,3100,332,17),(32,3600,340,19),(32,3300,355,17),(33,5500,385,20),
    (33,4200,388,18),(33,4600,382,20),(34,5500,390,21),(34,4800,405,18),(35,7000,435,21),
    (35,5200,438,18),(35,4800,448,17),(36,6000,445,20),(36,7000,442,21),(37,9500,480,22),
    (37,6500,483,18),(37,7200,478,19),(38,8500,486,19),(38,7800,498,18),(39,12000,530,21),
    (39,8500,533,19),(39,9000,528,18),(40,11000,540,20),(40,10000,555,19),(41,15000,590,22),
    (41,11000,593,20),(41,10500,605,19),(42,14000,615,21),(42,16000,620,22),(43,25000,660,23),
]

BOSS = set(range(4, 100, 5))

def get_e(s):
    lv, hp, atk, ac = ENEMIES[s]
    if s in BOSS:
        return lv+2, hp*2, round(atk*1.25), ac+2
    return lv, hp, atk, ac

class Hero:
    def __init__(self):
        self.lvl=1; self.str_=5; self.dex=5; self.con=6; self.cha=5
        self.xp=0; self.xpn=100
        self._s()
    def _s(self):
        sm=(self.str_-10)//2; dm=(self.dex-10)//2
        cm=(self.con-10)//2;  chm=(self.cha-10)//2
        p=2+(self.lvl-1)//4
        self.ab=sm+p; self.dmb=sm; self.ac=10+dm
        self.mhp=(30+self.con*8)+(self.lvl-1)*max(1,5+cm)
        self.xm=max(0.1,1.0+chm*0.05)
    def up(self):
        self.lvl+=1; self.xpn=round(self.xpn*1.22)
        self.str_=min(100,self.str_+1)
        if self.lvl%2==0: self.con=min(100,self.con+1)
        if self.lvl%3==0: self.con=min(100,self.con+1)
        self._s()
    def xpgain(self,elv):
        g=round((elv*56+150)*self.xm)
        self.xp+=g
        while self.xp>=self.xpn:
            self.xp-=self.xpn; self.up()

def items(stage):
    """Items scale per 10-stage zone. Returns (atk_bonus, dmg_bonus, ac_bonus)."""
    z=stage//10
    # A player who actively equips gear: weapon+acc give ATK/DMG, armor gives AC.
    # These values represent typical totals from all 4 equipment slots + passive tree.
    # Zone 0 (1-10): no gear yet. Zone 5 (51-60): decent rare items. Zone 9 (91-100): epic/legendary.
    ia = [0, 6, 13, 21, 30, 40, 51, 63, 76, 90][z]
    id_= [0, 6, 13, 21, 30, 40, 51, 63, 76, 90][z]
    ic = [0, 5, 10, 15, 21, 27, 33, 40, 47, 54][z]
    return ia, id_, ic

def battle(hero, stage, ia, id_, ic, rng):
    """One battle. Returns (won:bool, rounds:int)."""
    elv, ehp, eatk, eac = get_e(stage)
    hhp = hero.mhp
    hab  = hero.ab + ia
    hdmb = hero.dmb + id_
    hac  = hero.ac + ic
    eb   = elv // 2
    for rd in range(3000):
        # hero attacks
        r = rng.randint(1,20)
        crit = (r==20)
        if crit or r+hab >= eac:
            d = rng.randint(1,8)
            if crit: d += rng.randint(1,8)
            ehp -= max(1, d+hdmb)
        if ehp <= 0:
            return True, rd+1
        # enemy attacks
        er = rng.randint(1,20)
        if er+eb >= hac:
            hhp -= rng.randint(1,eatk)
        if hhp <= 0:
            return False, rd+1
    return (ehp<=0), 3000

def simulate(seed=0, max_tries_per_stage=1000):
    rng   = random.Random(seed)
    hero  = Hero()
    total = 0
    log   = []
    stuck = None

    for stage in range(100):
        ia, id_, ic = items(stage)
        wins = losses = 0
        stage_rounds = 0

        # Probe win rate first (10 sample battles without XP)
        probe_wins = sum(1 for _ in range(20) if battle(hero, stage, ia, id_, ic, rng)[0])
        win_pct = probe_wins * 5  # 0..100

        # Fight until win or give up
        attempts = 0
        while attempts < max_tries_per_stage:
            won, rds = battle(hero, stage, ia, id_, ic, rng)
            stage_rounds += rds
            total += rds
            attempts += 1
            if won:
                hero.xpgain(get_e(stage)[0])
                break
        else:
            stuck = stage
            log.append((stage, hero.lvl, stage_rounds // attempts, attempts, win_pct))
            break

        log.append((stage, hero.lvl, stage_rounds // attempts, attempts, win_pct))

    return total, log, hero.lvl, stuck

# Run 5 seeds and average
print("Running 5 simulations (this takes ~30s)...")
seeds = 5
all_totals = []
all_stucks = []
for s in range(seeds):
    tot, lg, lv, stuck = simulate(seed=s, max_tries_per_stage=500)
    all_totals.append(tot)
    if stuck is not None:
        all_stucks.append(stuck)
    print(f"  Seed {s}: {tot:>12,} rounds | hero lv {lv:>2} | {'STUCK at stage '+str(stuck+1) if stuck else 'COMPLETE'}")

avg = sum(all_totals)/len(all_totals)
print()
if all_stucks:
    print(f"WARNING: simulation blocked at stage {min(all_stucks)+1} in {len(all_stucks)}/{seeds} runs.")
    print("This means enemies from that stage cannot be beaten with the current item model.")
    print()

print("=" * 68)
_, log, final_lv, stuck = simulate(seed=42, max_tries_per_stage=500)

NAMES = {
    0:"Graveyard (zone 1)",  9:"Graveyard boss",
   10:"Ruins (zone 2)",     19:"Ruins boss",
   20:"Crystal Sanctum",   29:"Sanctum boss",
   30:"Shadow Realm",      39:"Shadow boss",
   40:"Frozen Wastes",     49:"Ice boss",
   50:"Abyssal Ocean",     59:"Ocean boss",
   60:"Plaguelands",       69:"Plague boss",
   70:"Dark Matter",       79:"Dark boss",
   80:"Abyss Gate",        89:"Gate boss",
   90:"Omega Throne",      99:"THE OMEGA",
}

print(f"{'Stage':>6} {'Zone':>22} {'Lv':>4} {'~Rds':>6} {'Win%':>5} {'Tries':>7}")
for s,lv,r,t,wp in log:
    if s in NAMES:
        boss = " B" if s in BOSS else "  "
        print(f"{s+1:>5}{boss} {NAMES[s]:<22} {lv:>4} {r:>6} {wp:>4}% {t:>7}")

print()
tot_sample = sum(t*r for s,lv,r,t,wp in log)
print(f"Total rounds (seed 42): {tot_sample:,}")
print(f"Average across {seeds} seeds:  {avg:,.0f}")
print()
print("Days to stage 100:")
for label, rpd in [
    ("Casual  (1 hr/day, 0.7 atk/s = 2,520 rds/day)", 2520),
    ("Moderate (2 hrs/day, 1.0 atk/s = 7,200 rds/day)", 7200),
    ("Active  (3 hrs/day, 1.5 atk/s = 16,200 rds/day)", 16200),
]:
    days = avg / rpd
    print(f"  {label:52s} {days:6.0f} days")
print()
print("Note: simulation assumes player equips zone-appropriate gear at each stage.")
print("Item model: +6/13/21/30/40/51/63/76/90 ATK+DMG per zone; +5/10/15/21/27/33/40/47/54 AC.")
