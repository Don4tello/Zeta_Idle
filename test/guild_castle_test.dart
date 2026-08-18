import 'package:flutter_test/flutter_test.dart';
import 'package:zeta_idle/models/guild_castle.dart';

void main() {
  group('CastleTier cost curve', () {
    test('marginal CP matches the design table', () {
      expect(CastleTier.marginalCP[2], 1000);
      expect(CastleTier.marginalCP[5], 4096);
      expect(CastleTier.marginalCP[10], 42950);
    });

    test('cumulative CP to tier 10 ≈ 112,867', () {
      expect(CastleTier.cumulativeCP(1), 0);
      expect(CastleTier.cumulativeCP(2), 1000);
      expect(CastleTier.cumulativeCP(10), 112867);
    });

    test('goldPerCP scales 250 × 1.9^(tier-1)', () {
      expect(CastleTier.goldPerCP(1), 250);
      expect(CastleTier.goldPerCP(2), 475);
      expect(CastleTier.goldPerCP(3), 903); // 250*3.61
    });

    test('weekly upkeep only from tier 5', () {
      expect(CastleTier.weeklyUpkeepCP(4), 0);
      expect(CastleTier.weeklyUpkeepCP(5), 200);
      expect(CastleTier.weeklyUpkeepCP(10), 400);
    });
  });

  group('CastleState.addCP tier advancement', () {
    test('advances exactly one tier at the threshold', () {
      final c = CastleState();
      final gained = c.addCP(1000);
      expect(gained, 1);
      expect(c.tier, 2);
      expect(c.storedCP, 0);
      expect(c.lifetimeCP, 1000);
    });

    test('carries overflow into the next tier', () {
      final c = CastleState();
      c.addCP(1200); // tier 2 costs 1000 → 200 stored toward tier 3 (1600)
      expect(c.tier, 2);
      expect(c.storedCP, 200);
      expect(c.progress, closeTo(200 / 1600, 1e-9));
    });

    test('can jump multiple tiers in one big contribution', () {
      final c = CastleState();
      final gained = c.addCP(1000 + 1600 + 100); // → tier 4, 100 stored
      expect(gained, 2);
      expect(c.tier, 3);
      expect(c.storedCP, 100);
    });

    test('clamps at max tier 10 and banks no overflow', () {
      final c = CastleState(tier: 9, storedCP: 0);
      final gained = c.addCP(CastleTier.marginalCP[10]! + 5000);
      expect(gained, 1);
      expect(c.tier, 10);
      expect(c.isMaxTier, isTrue);
      expect(c.storedCP, 0);
      expect(c.addCP(9999), 0); // no-op at max
    });
  });

  group('GuildContribution daily cap', () {
    test('caps remaining today at 100 and rolls over on a new day', () {
      const day = 100;
      var g = const GuildContribution(userId: 'u');
      expect(g.cpRemainingToday(day), 100);
      g = g.addCP(60, day, 0, newWeek: false);
      expect(g.todayCP, 60);
      expect(g.cpRemainingToday(day), 40);
      // Next day resets today's spend.
      expect(g.cpRemainingToday(day + 1), 100);
    });

    test('weekly reset zeroes weeklyCP but keeps lifetime', () {
      var g = const GuildContribution(userId: 'u', weeklyCP: 90, lifetimeCP: 500, todayCP: 90, lastContribDay: 10);
      g = g.addCP(30, 11, 5, newWeek: true);
      expect(g.weeklyCP, 30);        // reset then +30
      expect(g.lifetimeCP, 530);     // never resets
      expect(g.todayCP, 30);         // new day → reset then +30
    });
  });

  group('GuildBuffs.fromCastle at every tier boundary', () {
    GuildBuffs at(int tier, {int active = 20}) =>
        GuildBuffs.fromCastle(CastleState(tier: tier), activeThisWeek: active);

    test('tier 1: nothing but default expedition slot', () {
      final b = at(1);
      expect(b.goldPct, 0);
      expect(b.expeditionSlots, 1);
      expect(b.weeklyGoalUnlocked, isFalse);
    });

    test('tier 2: stash tab', () => expect(at(2).stashTabs, 1));
    test('tier 3: +5% gold + weekly goal', () {
      final b = at(3);
      expect(b.goldPct, 5);
      expect(b.weeklyGoalUnlocked, isTrue);
    });
    test('tier 4: shop slots', () => expect(at(4).shopSlots, 2));
    test('tier 5: roster +2 and a boss attack', () {
      final b = at(5);
      expect(b.rosterBonus, 2);
      expect(b.bossAttacks, 1);
    });
    test('tier 6: craft cost reduction', () => expect(at(6).craftCostPct, 8));
    test('tier 7: gauntlet echo bonus', () => expect(at(7).echoPctGauntlet, 10));
    test('tier 8: roster +5 total and 2 expedition slots', () {
      final b = at(8);
      expect(b.rosterBonus, 5); // 2 + 3
      expect(b.expeditionSlots, 2);
    });
    test('tier 9: +5% all resources → effective gold 10%', () {
      final b = at(9);
      expect(b.allResPct, 5);
      expect(b.effectiveGoldPct, 10); // 5 gold + 5 all-res
    });
    test('tier 10: damage buff scales with actives, capped at 15', () {
      expect(at(10, active: 10).allDamagePct, 5);   // 10 × 0.5
      expect(at(10, active: 20).allDamagePct, 10);  // 20 × 0.5
      expect(at(10, active: 40).allDamagePct, 15);  // capped
    });
  });

  test('CastleState json round-trips', () {
    final c = CastleState(tier: 6, storedCP: 1234, lifetimeCP: 40000, lastUpkeepWeek: 42, decor: ['well']);
    final r = CastleState.fromJson(c.toJson());
    expect(r.tier, 6);
    expect(r.storedCP, 1234);
    expect(r.lifetimeCP, 40000);
    expect(r.lastUpkeepWeek, 42);
    expect(r.decor, ['well']);
  });
}
