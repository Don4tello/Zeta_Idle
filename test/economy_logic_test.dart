import 'package:flutter_test/flutter_test.dart';
import 'package:zeta_idle/services/game_state.dart';
import 'package:zeta_idle/models/login_streak.dart';
import 'package:zeta_idle/models/enemy.dart';

// Economy / reward-path regression tests — the formulas where a subtle change
// silently breaks payouts and "by feel" validation is weakest. GameState is
// built headless (testMode) so these run under `flutter test`.
//
// Run: flutter test test/economy_logic_test.dart
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Enemy mob({int level = 10, int hp = 1000, int atk = 10, bool boss = false}) =>
      Enemy(
        id: 'test', name: 'Test', description: '',
        maxHealth: hp, attack: atk, level: level, namedBoss: boss,
      );

  group('Login milestone multiplier', () {
    test('scales +0.5 per tier', () {
      final g = GameState(testMode: true);
      g.highestUnlockedTier = 0;
      expect(g.loginMilestoneMult, 1.0);
      g.highestUnlockedTier = 4;
      expect(g.loginMilestoneMult, 3.0);
      g.highestUnlockedTier = 10;
      expect(g.loginMilestoneMult, 6.0);
    });
  });

  group('effectiveLoginReward', () {
    test('milestone days scale rare currencies but NEVER ZCoins', () {
      final g = GameState(testMode: true)..highestUnlockedTier = 4; // ×3
      final day7 = LoginReward.forDay(7); // zcoins:100, echoes:100, milestone
      final eff = g.effectiveLoginReward(day7);
      expect(eff.zcoins, 100, reason: 'premium currency must never inflate');
      expect(eff.echoes, 300, reason: '100 echoes × tier-4 mult (3.0)');
    });

    test('non-milestone days are not scaled', () {
      final g = GameState(testMode: true)..highestUnlockedTier = 4;
      final day9 = LoginReward.forDay(9); // shards:100, NOT a milestone
      expect(day9.isMilestone, isFalse);
      expect(g.effectiveLoginReward(day9).shards, 100,
          reason: 'non-milestone rewards ignore the tier multiplier');
    });

    test('gold uses the flat value as an early-game floor', () {
      final g = GameState(testMode: true);
      final day1 = LoginReward.forDay(1); // gold:1000
      expect(g.effectiveLoginReward(day1).gold, greaterThanOrEqualTo(1000));
    });

    test('zero-gold rewards yield zero gold (no phantom scaling)', () {
      final g = GameState(testMode: true);
      final day2 = LoginReward.forDay(2); // zcoins only, gold:0
      expect(g.effectiveLoginReward(day2).gold, 0);
    });
  });

  group('battleGoldFor', () {
    test('is positive and scales with enemy level', () {
      final g = GameState(testMode: true);
      final low  = g.battleGoldFor(mob(level: 10));
      final high = g.battleGoldFor(mob(level: 40));
      expect(low, greaterThan(0));
      expect(high, greaterThan(low));
    });
  });

  group('applyFightLengthFloor (two-sided clamp on a real enemy)', () {
    test('caps a huge-HP enemy to the ceiling', () {
      final g = GameState(testMode: true);
      final ceiling = g.fightHpCeilingFor(false);
      // attack huge so the ATK floor never alters it — isolate HP.
      final out = g.applyFightLengthFloor(mob(hp: 1000000000, atk: 1000000000));
      expect(out.maxHealth, ceiling);
    });

    test('raises a trivial-HP enemy to the floor', () {
      final g = GameState(testMode: true);
      final floor = g.fightHpFloorFor(false);
      final out = g.applyFightLengthFloor(mob(hp: 1, atk: 1000000000));
      expect(out.maxHealth, floor);
    });
  });
}
