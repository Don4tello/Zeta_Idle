import 'package:flutter_test/flutter_test.dart';
import 'package:zeta_idle/services/game_state.dart';
import 'package:zeta_idle/models/login_streak.dart';

// Regression tests for the core game logic that has no on-device coverage.
// GameState is built headless via `testMode: true` (skips IAP/Steam plugin
// init + background timers) so the pure logic can run under `flutter test`.
//
// Run: flutter test test/game_state_logic_test.dart
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameState headless construction', () {
    test('builds in testMode without plugins', () {
      final g = GameState(testMode: true);
      expect(g.gold, greaterThan(0));
      expect(g.hero, isNotNull);
    });
  });

  group('Fight-length clamp (two-sided)', () {
    test('ceiling is above the floor, and bosses scale higher', () {
      final g = GameState(testMode: true);
      final floor   = g.fightHpFloorFor(false);
      final ceiling = g.fightHpCeilingFor(false);
      expect(floor, greaterThan(0));
      expect(ceiling, greaterThan(floor),
          reason: 'ceiling must cap above the floor so fights sit in a band');
      // Boss band is scaled by the boss round multiplier → bigger than trash.
      expect(g.fightHpCeilingFor(true), greaterThan(ceiling));
    });
  });

  group('PvP season league tiers', () {
    test('rating maps to the right league at each boundary', () {
      expect(GameState.pvpLeagueTierFor(899), 0);  // Bronze
      expect(GameState.pvpLeagueTierFor(900), 1);  // Silver (starting rating band)
      expect(GameState.pvpLeagueTierFor(1099), 1);
      expect(GameState.pvpLeagueTierFor(1100), 2);  // Gold
      expect(GameState.pvpLeagueTierFor(1600), 4);  // Diamond
      expect(GameState.pvpLeagueTierFor(2300), 6);  // Legend
    });
  });

  group('Mercenary star cost', () {
    test('scales linearly by star number', () {
      final g = GameState(testMode: true);
      expect(g.allyStarCost(1), GameState.kAllyStarCostStep);
      expect(g.allyStarCost(10), 10 * GameState.kAllyStarCostStep);
    });
  });

  group('LoginReward model', () {
    test('cycle covers 30 days with the right milestones', () {
      expect(LoginReward.cycle.length, 30);
      for (final d in [7, 14, 21, 28, 30]) {
        expect(LoginReward.forDay(d).isMilestone, isTrue, reason: 'day $d');
      }
      expect(LoginReward.forDay(1).isMilestone, isFalse);
      expect(LoginReward.forDay(30).isClassLegendary, isTrue);
    });

    test('primaryIconId picks the headline reward', () {
      expect(LoginReward.forDay(1).primaryIconId, 'gold');
      expect(LoginReward.forDay(2).primaryIconId, 'zcoins');
      expect(LoginReward.forDay(4).primaryIconId, 'mythril');
      expect(LoginReward.forDay(30).primaryIconId, 'item_legendary');
    });
  });

  group('Save/load round-trip', () {
    test('new persisted fields survive toJson -> loadFromJson', () {
      final g = GameState(testMode: true);
      g.gold             = 123456;
      g.pvpRating        = 1750;
      g.pvpHighestRating = 1800;
      g.towerHighestFloor = 42;
      g.loginStreak      = 9;

      final json = g.toJson();
      final g2 = GameState(testMode: true)..loadFromJson(json);

      expect(g2.gold, 123456);
      expect(g2.pvpRating, 1750);
      expect(g2.pvpHighestRating, 1800);
      expect(g2.towerHighestFloor, 42);
      expect(g2.loginStreak, 9);
    });
  });
}
