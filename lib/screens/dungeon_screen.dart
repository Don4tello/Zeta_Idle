import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/damage_type.dart';
import '../models/dungeon.dart';
import '../models/equipment.dart';
import '../models/hero_ability.dart';
import '../models/passive_tree.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/main_shell.dart';
import '../services/game_state.dart';
import '../services/leaderboard_service.dart';
import '../theme/app_theme.dart';
import '../widgets/arena_ability_effect.dart';
import '../widgets/battle_arena.dart';
import '../widgets/battle_sprites.dart';
import '../widgets/battle_split_panel.dart';
import '../widgets/tier_selector.dart';
import '../widgets/pet_battle_sprite.dart';
import '../widgets/zcoin_icon.dart';

// -----------------------------------------------------------------------------
// DungeonScreen
//
// States:
//   1. No active run ? lobby / record card + ENTER button
//   2. Active run, room not yet resolved ? room detail + action (auto-selected)
//   3. Active run, room resolved ? result + NEXT FLOOR button
//   4. Run over (dead or abandoned) ? summary
// -----------------------------------------------------------------------------

class DungeonScreen extends StatefulWidget {
  const DungeonScreen({super.key});

  @override
  State<DungeonScreen> createState() => _DungeonScreenState();
}

class _DungeonScreenState extends State<DungeonScreen> {
  int _selectedTier = 1;
  bool _autoRun = false;
  Timer? _autoTimer;

  @override
  void dispose() {
    _autoTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final run  = game.activeDungeon;

    final body = switch (run) {
      null              => _DungeonLobby(
                             game: game,
                             selectedTier: _selectedTier,
                             onTierChange: (t) => setState(() => _selectedTier = t),
                             onStart: () => setState(() => game.startDungeon(tier: _selectedTier)),
                             autoRun: _autoRun,
                             onToggleAuto: _toggleAuto,
                           ),
      _ when run.isOver => _DungeonSummary(
                             run: run, game: game,
                             autoRun: _autoRun,
                             onToggleAuto: _toggleAuto,
                             onExit: _exitDungeon,
                             onRunAgain: () => setState(() {
                               game.activeDungeon = null;
                               game.startDungeon(tier: _selectedTier);
                             }),
                           ),
      _ when run.currentRoom == null
                        => _RoomChoiceView(run: run, game: game, onChosen: _onDoorChosen),
      _ when !run.currentRoom!.resolved
                        => _RoomDetail(run: run, game: game, onResolved: _onRoomResolved),
      _                 => _RoomResult(run: run, game: game, onNext: _afterRoom),
    };

    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: run == null
            ? Text('THE DUNGEON', style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2))
            : Text('T${run.tier}  FL.${run.floor}  —  THE DUNGEON',
                style: AppTheme.pixelHeading(fontSize: 12, letterSpacing: 1)),
        leading: run != null && !run.isOver
            ? IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),
                onPressed: _abandon,
                tooltip: 'Flee dungeon',
              )
            : null,
        actions: [
          if (run == null || run.isOver)
            IconButton(
              icon: const Icon(Icons.leaderboard, color: AppTheme.accentGold, size: 20),
              tooltip: 'Dungeon Leaderboard',
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const LeaderboardScreen(board: LeaderboardBoard.dungeon),
              )),
            ),
        ],
      ),
      body: body,
    );
  }

  void _abandon() {
    _autoTimer?.cancel();
    _autoRun = false;
    setState(() => GameStateProvider.of(context).abandonDungeon());
  }

  void _onDoorChosen() {
    setState(() {});
    if (_autoRun) _scheduleAutoAction();
  }

  void _onRoomResolved() {
    setState(() {});
    if (_autoRun) _scheduleAutoAction();
  }

  void _afterRoom() {
    final game = GameStateProvider.of(context);
    final run  = game.activeDungeon;
    if (run == null || run.isOver) {
      setState(() {});
      if (_autoRun) _scheduleAutoAction();
      return;
    }
    game.advanceDungeonFloor();
    setState(() {});
    if (_autoRun) _scheduleAutoAction();
  }

  void _exitDungeon() {
    _autoTimer?.cancel();
    _autoRun = false;
    setState(() => GameStateProvider.of(context).activeDungeon = null);
  }

  void _toggleAuto() {
    setState(() => _autoRun = !_autoRun);
    if (_autoRun) _scheduleAutoAction();
  }

  void _scheduleAutoAction() {
    _autoTimer?.cancel();
    _autoTimer = null;
    if (!_autoRun || !mounted) return;

    final game = GameStateProvider.of(context);
    final run  = game.activeDungeon;

    if (run == null || run.isOver) {
      _autoTimer = Timer(const Duration(milliseconds: 2500), () {
        if (!mounted || !_autoRun) return;
        setState(() {
          game.activeDungeon = null;
          game.startDungeon(tier: _selectedTier);
        });
        _scheduleAutoAction();
      });
      return;
    }

    final room = run.currentRoom;
    if (room == null) {
      if (run.roomChoices.isEmpty) return;
      // Auto-run picks a door: rest when hurt, avoid traps, favour loot.
      _autoTimer = Timer(const Duration(milliseconds: 700), () {
        if (!mounted || !_autoRun) return;
        final g = GameStateProvider.of(context);
        final r = g.activeDungeon;
        if (r == null || r.currentRoom != null || r.roomChoices.isEmpty) return;
        final hurt = r.heroHp < r.heroMaxHp * 0.5;
        int score(DungeonRoom d) => switch (d.type) {
          DungeonRoomType.restSite    => hurt ? 100 : 20,
          DungeonRoomType.treasure    => 60,
          DungeonRoomType.shrine      => 50,
          DungeonRoomType.lockedChest => 40,
          DungeonRoomType.combat      => 35,
          DungeonRoomType.elite       => 30,
          DungeonRoomType.ambush      => 25,
          DungeonRoomType.trap        => 10,
          DungeonRoomType.boss        => 90,
        };
        var pick = r.roomChoices.first;
        for (final d in r.roomChoices) {
          if (score(d) > score(pick)) pick = d;
        }
        g.chooseDungeonRoom(pick);
        setState(() {});
        _scheduleAutoAction();
      });
      return;
    }

    const combatTypes = {
      DungeonRoomType.combat, DungeonRoomType.elite,
      DungeonRoomType.ambush, DungeonRoomType.boss,
    };

    if (room.resolved) {
      _autoTimer = Timer(const Duration(milliseconds: 700), () {
        if (!mounted || !_autoRun) return;
        final g = GameStateProvider.of(context);
        final r = g.activeDungeon;
        if (r != null && r.relicChoices.isNotEmpty) {
          g.chooseDungeonRelic(r.relicChoices.first);
          setState(() {});
          _scheduleAutoAction();
          return;
        }
        _afterRoom();
      });
    } else if (!combatTypes.contains(room.type)) {
      _autoTimer = Timer(const Duration(milliseconds: 800), () {
        if (!mounted || !_autoRun) return;
        _autoResolveRoom(game, run, room);
      });
    }
  }

  void _autoResolveRoom(GameState game, DungeonRun run, DungeonRoom room) {
    switch (room.type) {
      case DungeonRoomType.treasure:
        game.collectDungeonTreasure();
      case DungeonRoomType.restSite:
        game.resolveDungeonRestSite();
      case DungeonRoomType.trap:
        game.resolveDungeonTrap();
      case DungeonRoomType.shrine:
        final choices = room.blessingChoices ?? [];
        if (choices.isNotEmpty) {
          game.chooseDungeonBlessing(choices.first);
        } else {
          room.resolved = true;
        }
      case DungeonRoomType.lockedChest:
        room.resolved = true;
      default:
        room.resolved = true;
    }
    _onRoomResolved();
  }
}

// -- Lobby ---------------------------------------------------------------------

class _DungeonLobby extends StatelessWidget {
  const _DungeonLobby({
    required this.game,
    required this.selectedTier,
    required this.onTierChange,
    required this.onStart,
    required this.autoRun,
    required this.onToggleAuto,
  });
  final GameState game;
  final int selectedTier;
  final void Function(int) onTierChange;
  final VoidCallback onStart;
  final bool autoRun;
  final VoidCallback onToggleAuto;

  static const int _kMaxTiers = 10;

  @override
  Widget build(BuildContext context) {
    final maxUnlocked = game.dungeonHighestTier + 1; // always can try the next tier
    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero image with overlay text
          Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: 220,
                child: Image.asset(
                  'assets/images/dungeon_bg.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00000000), Color(0xDD0a0a0a)],
                      stops: [0.3, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16, right: 16, bottom: 16,
                child: Column(
                  children: [
                    const Text(
                      'Survive as many floors as you can. Every 5th floor is a Boss.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Color(0xFFccbbaa), height: 1.4),
                    ),
                    const SizedBox(height: 10),
                    _RecordChip(floor: game.deepestDungeonFloor),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
          TutorialTip(
            tutorialKey: 'dungeon',
            game: game,
            text: 'Choose one of two doors each floor. Slain enemies drop Bones — spend them '
                'at the Traveling Merchant for run-long buffs. Loot is yours immediately, '
                'even if your hero falls.',
          ),
          const SizedBox(height: 16),
          // Tier selector
          TierSelector(
            selectedTier: selectedTier,
            maxUnlocked: maxUnlocked.clamp(1, _kMaxTiers),
            highestCleared: game.dungeonHighestTier,
            onTierChange: onTierChange,
          ),
          const SizedBox(height: 10),
          // Daily dungeon affix
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xAA0d0c14),
              border: Border.all(color: const Color(0xFF9966ff).withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(children: [
              const Text('✦', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Expanded(child: Text(
                'AFFIX: ${game.dungeonAffixLabel}',
                style: const TextStyle(fontSize: 10, color: Color(0xFF9966ff), fontWeight: FontWeight.bold),
              )),
              GestureDetector(
                onTap: game.canRerollDungeonAffix ? game.rerollDungeonAffix : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: game.canRerollDungeonAffix
                        ? const Color(0xFF1a0a3a)
                        : Colors.transparent,
                    border: Border.all(
                      color: game.canRerollDungeonAffix
                          ? const Color(0xFF9966ff).withValues(alpha: 0.7)
                          : Colors.white12,
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    '↻ 5 ◆',
                    style: TextStyle(
                      fontSize: 9,
                      color: game.canRerollDungeonAffix
                          ? const Color(0xFFcc99ff)
                          : Colors.white24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 10),
          _DungeonEnterSection(game: game, tier: selectedTier, onStart: onStart),
          if (game.dungeonHighestTier >= selectedTier) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onToggleAuto,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: autoRun
                      ? const Color(0xFF44cc88).withValues(alpha: 0.10)
                      : const Color(0xFF231F1B),
                  border: Border.all(
                    color: autoRun
                        ? const Color(0xFF44cc88)
                        : AppTheme.cardBorder,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      autoRun ? Icons.autorenew : Icons.autorenew,
                      color: autoRun ? const Color(0xFF44cc88) : AppTheme.textMuted,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      autoRun ? 'AUTO RUN: ON' : 'AUTO RUN: OFF',
                      style: AppTheme.pixelHeading(
                        fontSize: 11,
                        letterSpacing: 1,
                        color: autoRun ? const Color(0xFF44cc88) : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          _InfoCard(),
          const SizedBox(height: 16),
          _LootPreviewCard(deepestFloor: game.deepestDungeonFloor),
        ])),
        ],
      ),
    );
  }
}

class _RecordChip extends StatelessWidget {
  const _RecordChip({required this.floor});
  final int floor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.accentGold.withValues(alpha: 0.08),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        floor == 0 ? 'No record yet' : 'Deepest floor: $floor',
        style: AppTheme.pixelHeading(fontSize: 11, color: AppTheme.accentGold),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF231F1B),
        border: Border.all(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('WHAT TO EXPECT', style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2, color: AppTheme.textMuted)),
          const SizedBox(height: 10),
          for (final row in [
            ('⚔', 'Combat — fight for gold'),
            ('★', 'Elite — tougher foe, guaranteed item drop'),
            ('‼', 'Ambush — enemy strikes first, high gold'),
            ('⊕', 'Rest Site — recover 20% HP'),
            ('✦', 'Treasure — claim gold & shards'),
            ('✧', 'Shrine — choose a run-long blessing'),
            ('◆', 'Locked Chest — spend shards for a rare item'),
            ('✸', 'Trap — unavoidable damage'),
            ('☠', 'Boss (every 5th floor) — high risk, high reward'),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                SizedBox(width: 24, child: Text(row.$1, style: const TextStyle(fontSize: 17))),
                const SizedBox(width: 8),
                Expanded(child: Text(row.$2, style: const TextStyle(fontSize: 12, color: AppTheme.textLight))),
              ]),
            ),
          const SizedBox(height: 6),
          const Text('Slain enemies drop Bones — spend them at the Traveling Merchant.',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

class _LootPreviewCard extends StatelessWidget {
  const _LootPreviewCard({required this.deepestFloor});
  final int deepestFloor;

  static String _itemTierLabel(int floor) {
    if (floor >= 20) return 'Rare–Legendary';
    if (floor >= 10) return 'Uncommon–Rare';
    if (floor >= 5)  return 'Common–Uncommon';
    return 'Common';
  }

  @override
  Widget build(BuildContext context) {
    final mythrilAt5  = (5  / 2).floor().clamp(0, 10);
    final mythrilAt10 = (10 / 2).floor().clamp(0, 10);
    final tier = _itemTierLabel(deepestFloor);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1510),
        border: Border.all(color: const Color(0xFF5a4a2a).withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('EXPECTED LOOT', style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2, color: AppTheme.textMuted)),
          const SizedBox(height: 10),
          _lootRow('💰', 'Gold', 'From combat, treasure rooms & rest supplies'),
          const SizedBox(height: 6),
          _lootRow('◆', 'Shards', 'Treasure rooms & chests along the run'),
          const SizedBox(height: 6),
          _lootRow('⚔', 'Items', 'Item tier at your depth: $tier  (elites & bosses drop better)'),
          const SizedBox(height: 6),
          _lootRow('✦', 'Mythril', '~$mythrilAt5 at floor 5  •  ~$mythrilAt10 at floor 10'),
          if (deepestFloor > 0) ...[
            const SizedBox(height: 6),
            Row(children: [
              const Text('★', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Text('Your best: floor $deepestFloor  •  ~${(deepestFloor / 2).floor().clamp(0, 10)} mythril',
                  style: const TextStyle(fontSize: 12, color: Color(0xFFFFCC44))),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _lootRow(String icon, String label, String detail) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 20, child: Text(icon, style: const TextStyle(fontSize: 14))),
          const SizedBox(width: 4),
          SizedBox(
            width: 58,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(detail,
                style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
          ),
        ],
      );
}

// Tier selector is now shared via TierSelector widget

class _DungeonEnterSection extends StatelessWidget {
  const _DungeonEnterSection({required this.game, required this.tier, required this.onStart});
  final GameState game;
  final int tier;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final remaining = game.dungeonAttemptsRemaining;
    final canAfford = game.zcoins >= GameState.kDungeonExtraCost;
    return Column(
      children: [
        // Attempt counter
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.refresh, size: 14, color: AppTheme.textMuted),
            const SizedBox(width: 5),
            Text(
              'Daily attempts: $remaining / ${GameState.kDungeonMaxAttempts}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: remaining > 0 ? onStart : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2a1f00),
              foregroundColor: AppTheme.accentGold,
              disabledBackgroundColor: const Color(0xFF1a1410),
              disabledForegroundColor: Colors.white24,
              side: BorderSide(
                color: remaining > 0 ? AppTheme.accentGold : Colors.white24,
                width: 1.5,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: Text(
              remaining > 0 ? 'ENTER  TIER $tier' : 'NO ATTEMPTS LEFT',
              style: AppTheme.pixelHeading(
                fontSize: 14, letterSpacing: 2,
                color: remaining > 0 ? AppTheme.accentGold : Colors.white24,
              ),
            ),
          ),
        ),
        if (remaining == 0) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: canAfford ? () => game.buyExtraDungeonAttempt() : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF88ccff),
                side: BorderSide(
                  color: canAfford
                      ? const Color(0xFF88ccff).withValues(alpha: 0.6)
                      : Colors.white24,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                ZCoinIcon(size: 13, animate: false),
                const SizedBox(width: 5),
                Text(
                  '${GameState.kDungeonExtraCost} ZCoins — Buy 1 extra attempt',
                  style: TextStyle(fontSize: 12, color: canAfford ? const Color(0xFF88ccff) : Colors.white24),
                ),
              ]),
            ),
          ),
        ],
      ],
    );
  }
}

// -- Hero HP bar (shared) ------------------------------------------------------

class _HeroBar extends StatelessWidget {
  const _HeroBar({required this.run, this.game});
  final DungeonRun run;
  final GameState? game;

  @override
  Widget build(BuildContext context) {
    final pct = (run.heroHp / run.heroMaxHp).clamp(0.0, 1.0);
    final hpColor = pct > 0.5 ? const Color(0xFF88cc44) : pct > 0.25 ? const Color(0xFFcc8833) : const Color(0xFFcc4444);
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF231F1B),
        border: Border(bottom: BorderSide(color: AppTheme.cardBorder)),
      ),
      child: Column(
        children: [
          // -- Floor progress strip -----------------------------------------
          _FloorStrip(run: run),
          // -- HP bar ------------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [
                    if (game != null) ...[
                      SizedBox(
                        width: 26, height: 26,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: BattleSprite(
                            spriteId: game!.hero.spriteId,
                            gender: game!.hero.gender,
                            race: game!.heroRace,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text('HP', style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2, color: hpColor)),
                  ]),
                  Text('${run.heroHp} / ${run.heroMaxHp}',
                      style: TextStyle(fontSize: 12, color: hpColor, fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: AppTheme.cardBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(hpColor),
                  ),
                ),
                // -- Run summary: earnings + next boss countdown ------------
                const SizedBox(height: 6),
                Row(children: [
                  Text('💰 ${run.goldEarned}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFFffcc44), fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  Text('◆ ${run.shardsEarned}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF88aaff), fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  Text('🦴 ${run.bones}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFFe8dcc0), fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Builder(builder: (_) {
                    final toBoss = run.floor % 5 == 0 ? 0 : 5 - (run.floor % 5);
                    return Text(
                      toBoss == 0 ? '☠ BOSS FLOOR' : '☠ Boss in $toBoss',
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold,
                        color: toBoss == 0 ? const Color(0xFFff5555)
                            : toBoss == 1 ? const Color(0xFFcc8833)
                            : AppTheme.textMuted,
                      ),
                    );
                  }),
                ]),
                // -- Active effects: blessings, shrine boons/curses, relics --
                if (run.blessings.isNotEmpty || run.shrineEffects.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      ...run.blessings.map((b) => _effectChip(b.label, const Color(0xFF44cc88))),
                      ...run.shrineEffects.map((e) => _effectChip(
                            '${e.icon} ${e.name}',
                            e.id.startsWith('relic_') ? const Color(0xFFcc88ff)
                                : e.isCurse ? const Color(0xFFcc4444)
                                : const Color(0xFF44cc88),
                          )),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _effectChip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, style: TextStyle(fontSize: 10, color: color)),
      );
}

// -- Floor themes --------------------------------------------------------------

typedef _FloorTheme = ({String name, Color color, String prefix, String icon});

const _kFloorThemes = <_FloorTheme>[
  (name: 'Outer Crypts',   color: Color(0xFF7788aa), prefix: 'Hollow',   icon: '☠'),
  (name: 'Fetid Tunnels',  color: Color(0xFF55aa55), prefix: 'Blighted', icon: '✸'),
  (name: 'Infernal Halls', color: Color(0xFFcc5522), prefix: 'Infernal', icon: '✦'),
  (name: 'Shadow Depths',  color: Color(0xFF7755aa), prefix: 'Shadow',   icon: '◆'),
  (name: 'Abyss Core',     color: Color(0xFF992222), prefix: 'Abyssal',  icon: '★'),
];

_FloorTheme _themeForFloor(int floor, int totalFloors) {
  final ratio = totalFloors <= 1 ? 0.0 : (floor - 1) / totalFloors;
  final idx = (ratio * _kFloorThemes.length).floor().clamp(0, _kFloorThemes.length - 1);
  return _kFloorThemes[idx];
}

// -- Floor strip ---------------------------------------------------------------

class _FloorStrip extends StatelessWidget {
  const _FloorStrip({required this.run});
  final DungeonRun run;

  static const _roomIcons = <DungeonRoomType, String>{
    DungeonRoomType.combat:      '⚔',
    DungeonRoomType.elite:       '★',
    DungeonRoomType.ambush:      '‼',
    DungeonRoomType.treasure:    '✦',
    DungeonRoomType.shrine:      '✧',
    DungeonRoomType.lockedChest: '◆',
    DungeonRoomType.trap:        '✸',
    DungeonRoomType.restSite:    '⊕',
    DungeonRoomType.boss:        '☠',
  };

  static const _roomColors = <DungeonRoomType, Color>{
    DungeonRoomType.combat:      Color(0xFFff6644),
    DungeonRoomType.elite:       Color(0xFFcc44ff),
    DungeonRoomType.ambush:      Color(0xFFff8833),
    DungeonRoomType.treasure:    Color(0xFFffcc33),
    DungeonRoomType.shrine:      Color(0xFF44ccaa),
    DungeonRoomType.lockedChest: Color(0xFF88aaff),
    DungeonRoomType.trap:        Color(0xFFcc8833),
    DungeonRoomType.restSite:    Color(0xFF44cc88),
    DungeonRoomType.boss:        Color(0xFFcc4444),
  };

  @override
  Widget build(BuildContext context) {
    final cur = run.floor;
    final currentType = run.currentRoom?.type;
    const totalFloors = DungeonRun.clearFloor;
    final theme = _themeForFloor(cur, totalFloors);

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      decoration: BoxDecoration(
        color: theme.color.withValues(alpha: 0.06),
        border: const Border(bottom: BorderSide(color: AppTheme.cardBorder, width: 0.5)),
      ),
      child: Row(
        children: [
          // Floor depth + zone indicator
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('•', style: TextStyle(fontSize: 10, color: AppTheme.textMuted.withValues(alpha: 0.5))),
              const SizedBox(height: 2),
              Text('F$cur', style: AppTheme.pixelHeading(fontSize: 10, color: AppTheme.accentGold)),
              const SizedBox(height: 2),
              Text('${theme.icon} ${theme.name}',
                  style: TextStyle(fontSize: 7, color: theme.color, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
            ],
          ),
          const SizedBox(width: 8),
          // Floor nodes in a wrapped vertical-feeling flow
          Expanded(
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: List.generate(totalFloors.clamp(1, 40), (i) {
                final f = i + 1;
                final isPast    = f < cur;
                final isCurrent = f == cur;
                final isBoss    = f % 5 == 0;

                final String icon;
                final Color nodeColor;
                final Color bg;

                if (isCurrent && currentType != null) {
                  icon = _roomIcons[currentType] ?? '☠';
                  nodeColor = _roomColors[currentType] ?? AppTheme.accentGold;
                  bg = nodeColor.withValues(alpha: 0.15);
                } else if (isPast) {
                  icon = isBoss ? '☠' : '✓';
                  nodeColor = const Color(0xFF44cc88).withValues(alpha: 0.7);
                  bg = nodeColor.withValues(alpha: 0.06);
                } else {
                  icon = isBoss ? '☠' : '•';
                  nodeColor = isBoss
                      ? const Color(0xFFcc4444).withValues(alpha: 0.4)
                      : AppTheme.textMuted.withValues(alpha: 0.2);
                  bg = const Color(0xFF0e0c08);
                }

                return Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: bg,
                    border: Border.all(
                      color: isCurrent ? nodeColor : nodeColor.withValues(alpha: 0.4),
                      width: isCurrent ? 2 : 0.5,
                    ),
                    borderRadius: BorderRadius.circular(isBoss ? 6 : 3),
                    boxShadow: isCurrent ? [
                      BoxShadow(color: nodeColor.withValues(alpha: 0.3), blurRadius: 6),
                    ] : null,
                  ),
                  child: Text(icon, style: TextStyle(fontSize: isCurrent ? 12 : 9, color: nodeColor)),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// -- Room choice (two doors) ---------------------------------------------------

class _RoomChoiceView extends StatelessWidget {
  const _RoomChoiceView({required this.run, required this.game, required this.onChosen});
  final DungeonRun run;
  final GameState game;
  final VoidCallback onChosen;

  @override
  Widget build(BuildContext context) {
    final doors = run.roomChoices;
    final nextIsBoss = (run.floor + 1) % 5 == 0;
    final theme = _themeForFloor(run.floor, DungeonRun.clearFloor);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.color.withValues(alpha: 0.10),
            const Color(0xFF1B1A17),
            theme.color.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Column(
      children: [
        _HeroBar(run: run, game: game),
        const SizedBox(height: 12),
        Text('${theme.icon} ${theme.name.toUpperCase()}',
            style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2, color: theme.color)),
        const SizedBox(height: 4),
        Text('CHOOSE YOUR PATH',
            style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 3, color: AppTheme.accentGold)),
        if (nextIsBoss)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFcc4444).withValues(alpha: 0.12),
                border: Border.all(color: const Color(0xFFcc4444).withValues(alpha: 0.6)),
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Text('☠ NEXT FLOOR: BOSS',
                  style: TextStyle(fontSize: 11, color: Color(0xFFff6666), fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ),
        const SizedBox(height: 10),
        // Scrollable so tall cards never overflow; IntrinsicHeight keeps both
        // doors the same height while letting them grow to fit their content.
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.42,
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < doors.length; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      Expanded(
                        child: _DoorCard(
                          room: doors[i],
                          onTap: () { game.chooseDungeonRoom(doors[i]); onChosen(); },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
      ),
    );
  }
}

class _DoorCard extends StatelessWidget {
  const _DoorCard({required this.room, required this.onTap});
  final DungeonRoom room;
  final VoidCallback onTap;

  static const _combatTypes = {
    DungeonRoomType.combat, DungeonRoomType.elite,
    DungeonRoomType.ambush, DungeonRoomType.boss,
  };

  // Non-combat "event" doors are shown face-down — you don't know if it's a
  // reward (treasure/shrine/rest/chest) or a trap until you commit. Combat
  // doors stay revealed so you can see the foe you'd be fighting.
  static const _mysteryTypes = {
    DungeonRoomType.trap, DungeonRoomType.treasure, DungeonRoomType.shrine,
    DungeonRoomType.restSite, DungeonRoomType.lockedChest,
  };
  bool get _mystery => !room.isGoblin && _mysteryTypes.contains(room.type);

  List<String> get _detailLines => room.isGoblin
      ? [
          '${room.enemyMaxHp ?? '?'} HP  •  flees after 5 rounds',
          '6× gold if you slay it in time!',
        ]
      : switch (room.type) {
    DungeonRoomType.combat ||
    DungeonRoomType.elite ||
    DungeonRoomType.ambush ||
    DungeonRoomType.boss  => [
        room.enemyName ?? 'Enemy',
        '${room.enemyMaxHp ?? '?'} HP  •  ${room.enemyAtk ?? '?'} ATK',
        if (room.eliteTraitLabel != null) '★ ${room.eliteTraitLabel}',
        if (room.type == DungeonRoomType.elite) 'Guaranteed item drop',
        if (room.type == DungeonRoomType.ambush) 'Strikes first — high gold',
      ],
    DungeonRoomType.trap        => [room.trapName ?? 'Trap', '-${room.trapDamage ?? '?'} HP'],
    DungeonRoomType.treasure    => ['+${room.treasureGold ?? 0} gold', '+${room.treasureShards ?? 0} shards'],
    DungeonRoomType.shrine      => ['A blessing...', 'or a curse?'],
    DungeonRoomType.lockedChest => ['Rare item inside', '${room.chestShardCost ?? 30} shards to open'],
    DungeonRoomType.restSite    => ['Make camp', 'Recover HP'],
  };

  @override
  Widget build(BuildContext context) {
    final mystery = _mystery;
    final color = mystery
        ? const Color(0xFF9d8ec4) // neutral arcane purple — doesn't leak the type
        : room.isGoblin
            ? const Color(0xFFffcc33)
            : _FloorStrip._roomColors[room.type] ?? AppTheme.accentGold;
    final icon  = mystery ? '?' : _FloorStrip._roomIcons[room.type] ?? '?';
    final showSprite = !mystery && _combatTypes.contains(room.type) && room.enemyId != null;
    final title = mystery
        ? 'MYSTERY'
        : room.isGoblin ? '💰 TREASURE GOBLIN' : room.typeName.toUpperCase();
    final lines = mystery
        ? const ['An unmarked door.', 'Fortune or peril?']
        : _detailLines;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0.12), const Color(0xFF17140f)],
          ),
          border: Border.all(color: color.withValues(alpha: 0.65), width: 1.5),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 10)],
        ),
        padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
        child: Column(
          // Content group at the top, ENTER anchored at the bottom — keeps both
          // doors balanced regardless of how many detail lines each has.
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showSprite)
                  StaticEnemySprite(spriteId: room.enemyId!, size: 76)
                else if (mystery)
                  Text(icon, style: TextStyle(
                      fontSize: 56, fontWeight: FontWeight.bold, color: color,
                      shadows: [Shadow(color: color.withValues(alpha: 0.6), blurRadius: 14)]))
                else
                  Text(icon, style: TextStyle(fontSize: 44, color: color)),
                const SizedBox(height: 14),
                Text(title,
                    textAlign: TextAlign.center,
                    style: AppTheme.pixelHeading(fontSize: 12, letterSpacing: 1, color: color)),
                const SizedBox(height: 10),
                for (var i = 0; i < lines.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      lines[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        // First line (enemy name / primary) reads brighter; the
                        // stat/trait/drop lines below are muted secondary detail.
                        fontSize: i == 0 ? 12.5 : 11,
                        height: 1.4,
                        fontStyle: mystery ? FontStyle.italic : FontStyle.normal,
                        fontWeight: (i == 0 && !mystery) ? FontWeight.w600 : FontWeight.normal,
                        color: i == 0 && !mystery ? AppTheme.textLight : AppTheme.textMuted,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: color),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text('ENTER',
                  style: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 2, color: color)),
            ),
          ],
        ),
      ),
    );
  }
}

// -- Room detail ---------------------------------------------------------------

class _RoomDetail extends StatelessWidget {
  const _RoomDetail({required this.run, required this.game, required this.onResolved});
  final DungeonRun run;
  final GameState game;
  final VoidCallback onResolved;

  @override
  Widget build(BuildContext context) {
    if (run.currentRoom == null) return const SizedBox.shrink();
    final room = run.currentRoom!;
    const combatTypes = {
      DungeonRoomType.combat,
      DungeonRoomType.elite,
      DungeonRoomType.ambush,
      DungeonRoomType.boss,
    };

    if (combatTypes.contains(room.type)) {
      return _AnimatedCombatRoom(
        run: run, room: room, game: game, onResolved: onResolved,
        isBoss: room.type == DungeonRoomType.boss,
        isElite: room.type == DungeonRoomType.elite,
        isAmbush: room.type == DungeonRoomType.ambush,
      );
    }

    return Column(
      children: [
        _HeroBar(run: run, game: game),
        // -- Pinned action buttons just below health bar -------------------
        _buildRoomActionBar(room),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: switch (room.type) {
              DungeonRoomType.treasure    => _TreasureDetail(run: run, room: room, game: game, onResolved: onResolved),
              DungeonRoomType.shrine      => _ShrineDetail(run: run, room: room, game: game, onResolved: onResolved),
              DungeonRoomType.trap        => _TrapDetail(run: run, room: room, game: game, onResolved: onResolved),
              DungeonRoomType.lockedChest => _LockedChestDetail(run: run, room: room, game: game, onResolved: onResolved),
              DungeonRoomType.restSite    => _RestSiteDetail(run: run, room: room, game: game, onResolved: onResolved),
              _ => const SizedBox.shrink(),
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRoomActionBar(DungeonRoom room) {
    const pad = EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    Widget btn(String label, Color color, Color bg, VoidCallback onTap) =>
        Expanded(
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: bg,
              side: BorderSide(color: color, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: Text(label,
                style: AppTheme.pixelHeading(fontSize: 12, letterSpacing: 1, color: color)),
          ),
        );

    switch (room.type) {
      case DungeonRoomType.treasure:
        return Padding(
          padding: pad,
          child: Row(children: [
            btn('COLLECT', AppTheme.accentGold, const Color(0xFF2a1f00),
                () { game.collectDungeonTreasure(); onResolved(); }),
          ]),
        );
      case DungeonRoomType.restSite:
        final heal = room.restoreHp ?? (run.heroMaxHp ~/ 5);
        final rdmg = room.restDamage;
        final (btnLabel, btnColor, btnBg) = switch (room.restEventType) {
          RestEventType.ambush     => ('FIGHT THROUGH IT  (-$rdmg / +$heal HP)', const Color(0xFFcc6644), const Color(0xFF2a0e0e)),
          RestEventType.badWeather => ('WEATHER THE STORM  (-$rdmg / +$heal HP)', const Color(0xFF88aacc), const Color(0xFF101a2a)),
          RestEventType.haunted    => ('ENDURE THE NIGHT  (+$heal HP)', const Color(0xFFaa88cc), const Color(0xFF1a0e2a)),
          RestEventType.wanderer   => ('ACCEPT AID  (+$heal HP)', const Color(0xFF44cc88), const Color(0xFF0a2a1a)),
          RestEventType.supplies   => ('COLLECT SUPPLIES  (+$heal HP, +${room.restBonusGold}g)', AppTheme.accentGold, const Color(0xFF2a1f00)),
          RestEventType.peaceful   => ('REST  (+$heal HP)', const Color(0xFF44cc88), const Color(0xFF0e2a1a)),
          RestEventType.merchant   => ('LEAVE SHOP  (+$heal HP)', const Color(0xFFddaa44), const Color(0xFF2a1f08)),
        };
        return Padding(
          padding: pad,
          child: Row(children: [
            btn(btnLabel, btnColor, btnBg, () { game.resolveDungeonRestSite(); onResolved(); }),
          ]),
        );
      case DungeonRoomType.trap:
        final dmg  = room.trapDamage ?? 0;
        final pct  = run.heroMaxHp > 0 ? (dmg * 100 / run.heroMaxHp).round() : 0;
        return Padding(
          padding: pad,
          child: Row(children: [
            btn('PROCEED  (-$dmg HP / $pct%)', const Color(0xFFcc8833), const Color(0xFF3a2200),
                () { game.resolveDungeonTrap(); onResolved(); }),
          ]),
        );
      case DungeonRoomType.lockedChest:
        final cost      = room.chestShardCost ?? 30;
        final canShards = game.shards >= cost;
        final canCryst  = game.zcoins >= GameState.chestCrystalCost;
        return Padding(
          padding: pad,
          child: Column(
            children: [
              Row(children: [
                btn(
                  canShards ? 'OPEN  ($cost ◆)' : 'NOT ENOUGH SHARDS',
                  canShards ? const Color(0xFF88aaff) : AppTheme.cardBorder,
                  AppTheme.cardBg,
                  canShards ? () { game.openDungeonChest(); onResolved(); } : () {},
                ),
                const SizedBox(width: 8),
                btn('LEAVE IT', AppTheme.textMuted, AppTheme.cardBg,
                    () { room.resolved = true; onResolved(); }),
              ]),
              if (!canShards && canCryst) ...[
                const SizedBox(height: 8),
                Row(children: [
                  btn(
                    'OPEN WITH ◆ ${GameState.chestCrystalCost} ZCOINS',
                    const Color(0xFFcc88ff),
                    AppTheme.cardBg,
                    () { game.openDungeonChestWithCrystals(); onResolved(); },
                  ),
                ]),
              ],
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// -- Animated combat room ------------------------------------------------------

class _AnimatedCombatRoom extends StatefulWidget {
  const _AnimatedCombatRoom({
    required this.run, required this.room, required this.game,
    required this.onResolved, required this.isBoss,
    this.isElite = false, this.isAmbush = false,
  });
  final DungeonRun run;
  final DungeonRoom room;
  final GameState game;
  final VoidCallback onResolved;
  final bool isBoss;
  final bool isElite;
  final bool isAmbush;

  @override
  State<_AnimatedCombatRoom> createState() => _AnimatedCombatRoomState();
}

class _AnimatedCombatRoomState extends State<_AnimatedCombatRoom> {
  final _arenaKey  = GlobalKey<BattleArenaState>();
  final _effectKey = GlobalKey<ArenaAbilityEffectState>();
  final _rng = Random();
  Timer? _timer;
  bool _finished = false;
  bool _paused = false;
  final List<String> _log = [];

  late int _heroHp;
  late int _heroMaxHp;
  late int _enemyHp;
  late int _enemyMaxHp;
  late int _heroAc;
  late int _heroDmgMod;
  late int _heroWeaponBase;
  late DamageType _heroDmgType;
  double _heroDmgAllPct    = 0;
  double _heroPrestigeMult = 1.0;
  late int _heroCritChancePct;
  late int _heroCritDmgMult;

  int _abilityRound = 0;
  final Map<String, int> _abilityCooldownUntil = {};
  int _bonusAtk = 0;
  int _totalDealt = 0;
  int _totalTaken = 0;
  int _bonusAc  = 0;
  bool _dodgeThisRound        = false;
  bool _enemyStunnedThisRound = false;

  // Run-wide modifiers (blessings, shrine effects, allies, consumables)
  double _dmgDealtMult  = 1.0;
  double _dmgTakenMult  = 1.0;
  double _healMult      = 1.0;
  bool _swiftness       = false;
  int _ambushPreHit     = 0;
  double _allyGoldMult  = 1.0;
  int _enemyShield      = 0;   // arcane affix: absorbs first N damage
  int _burnTick         = 0;   // burning affix: hero DoT per round
  int _eliteBlockHits   = 0;   // shielded elite: blocks first N hits

  @override
  void initState() {
    super.initState();
    final g = widget.game;
    _heroHp    = widget.run.heroHp;
    _heroMaxHp = widget.run.heroMaxHp;
    // Frozen affix: +20% enemy HP; Arcane: damage-absorb shield; Burning: hero DoT
    _enemyHp   = ((widget.room.enemyMaxHp ?? 10) * g.dungeonAffixHpMult).round();
    _enemyMaxHp = _enemyHp;
    _enemyShield = g.dungeonAffixEnemyShield;
    _burnTick    = g.dungeonAffixBurnTick(_heroMaxHp);
    _heroAc = g.hero.armorClass
        + g.passiveTree.totalOf(PassiveEffect.armorFlat)
        + g.inventory.totalOf(ItemStat.armorClass)
        + g.petArmor + g.skinArmor + g.questACBonus;
    _heroDmgMod      = g.heroFlatDmgBonus;
    _heroWeaponBase  = g.inventory.equippedWeaponDamage;
    _heroDmgType     = g.hero.activeDamageType;
    _heroDmgAllPct   = g.heroAllDamagePctFor(_heroDmgType);
    _heroPrestigeMult = g.prestigeLevel > 0 ? g.prestigeDamageMult : 1.0;
    _heroCritChancePct = g.totalCritChancePct;
    _heroCritDmgMult   = g.totalCritDamageMult.round();

    // Run blessings + shrine effects apply to the watched fight
    final run = widget.run;
    _heroAc     += run.blessingAc;
    _heroDmgMod += run.blessingDmg;
    _dmgDealtMult = run.damageDealtMult;
    _dmgTakenMult = run.damageTakenMult;
    _healMult     = run.healMult * g.dungeonAffixHealMult; // cursed affix halves healing
    _swiftness    = run.hasSwiftness;

    // Elite trait setup + announce
    if (widget.room.eliteTrait == 'shielded') _eliteBlockHits = 3;
    if (widget.room.eliteTraitLabel != null) {
      _log.add('★ Elite: ${widget.room.eliteTraitLabel}');
    }

    // Ambush: enemy lands a free hit before round 1
    if (widget.isAmbush) {
      final eAtk = widget.room.enemyAtk ?? 5;
      final pre = ((_rng.nextInt(eAtk ~/ 3 + 1) + 1) * _dmgTakenMult).round().clamp(1, 9999);
      _heroHp = (_heroHp - pre).clamp(1, _heroMaxHp); // can't die to the pre-hit
      _totalTaken += pre;
      _ambushPreHit = pre;
      _log.add('‼ Ambush! You take $pre damage before the fight begins.');
    }

    // Dungeon caps at tier 3 (max 2— release / 5— debug) — higher tiers bleed
    // in from the campaign speed button and make the dungeon impossibly fast.
    if (g.speedTier > 3) g.setSpeedTier(3);
    g.audioService.startBattleMusic();
    // Fire ally battle-start abilities
    _fireAllyStart(g);
    _timer = Timer.periodic(Duration(milliseconds: g.scaledInterval(1200)), (_) {
      if (!_paused) _doRound();
    });
  }

  final Set<String> _allyUsed = {};

  String get _displayEnemyName {
    final raw = widget.room.enemyName ?? 'Enemy';
    if (widget.isBoss) return raw;
    final theme = _themeForFloor(widget.run.floor, DungeonRun.clearFloor);
    return '${theme.prefix} $raw';
  }

  void _fireAllyStart(GameState g) {
    final enemyName = _displayEnemyName;
    if (g.allyUnlocked('greybeard') && _allyUsed.add('greybeard')) {
      _bonusAtk += 5;
      _log.add('⚔ Greybeard: War Cry! +5 ATK for this fight.');
    }
    if (g.allyUnlocked('elder_voss') && _allyUsed.add('elder_voss')) {
      final burst = (_enemyMaxHp * 0.10).round().clamp(1, 9999);
      _enemyHp = (_enemyHp - burst).clamp(0, _enemyMaxHp);
      _log.add('⚡ Voss: Arcane Surge! $enemyName takes $burst arcane damage!');
    }
    if (g.allyUnlocked('coin_felix') && _allyUsed.add('coin_felix')) {
      _allyGoldMult = 2.0;
      _log.add('💰 Felix: Bribe! $enemyName will drop 2x gold!');
    }
    if (g.allyUnlocked('shadow_lena') && _allyUsed.add('shadow_lena')) {
      _bonusAtk += 8;
      _log.add('⚔ Lena: Backstab! +8 ATK for first strike.');
    }
    if (g.allyUnlocked('golem_ruk') && _allyUsed.add('golem_ruk')) {
      _bonusAc += 4;
      _log.add('◆ Ruk: Stone Skin! +4 ARM for this fight.');
    }
  }

  void _checkAllyHpAbilities(GameState g) {
    if (_heroHp <= 0) return;
    if (g.allyUnlocked('mira') && !_allyUsed.contains('mira_heal') &&
        _heroHp < _heroMaxHp * 0.30) {
      _allyUsed.add('mira_heal');
      final heal = (_heroMaxHp * 0.25).round().clamp(1, _heroMaxHp);
      _heroHp = (_heroHp + heal).clamp(0, _heroMaxHp);
      _log.add('⊕ Mira: Field Triage! Healed for $heal HP!');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.game.audioService.endBattleMusic();
    super.dispose();
  }

  Future<void> _doRound() async {
    if (_finished || !mounted) return;
    final eAtk      = widget.room.enemyAtk ?? 5;
    final enemyName = _displayEnemyName;
    final heroName  = widget.game.hero.name;

    _abilityRound++;
    _dodgeThisRound        = false;
    _enemyStunnedThisRound = false;

    // Treasure goblin flees after 5 rounds
    if (widget.room.isGoblin && _abilityRound > 5 && _enemyHp > 0) {
      _finished = true;
      _timer?.cancel();
      setState(() => _log.add('💰 The Treasure Goblin cackles and vanishes with its hoard!'));
      await Future.delayed(const Duration(milliseconds: 900));
      if (mounted) {
        widget.game.applyDungeonGoblinEscape();
        widget.onResolved();
      }
      return;
    }

    // -- Fire ready abilities --------------------------------------------------
    for (final ability in widget.game.unlockedAbilities) {
      final readyAt = _abilityCooldownUntil[ability.id] ?? 0;
      if (_abilityRound < readyAt) continue;
      _abilityCooldownUntil[ability.id] =
          _abilityRound + widget.game.scaledAbilityCooldown(ability);
      _applyAbilityInAnimation(ability, widget.game.scaledAbilityValue(ability), enemyName);
      if (_enemyHp <= 0) break;
    }

    if (_enemyHp <= 0) {
      _finishVictory(enemyName);
      return;
    }

    // Hero strikes (Swiftness blessing: two strikes on round 1).
    // Hero always lands (same as the campaign); crit is purely chance-based.
    final strikes = (_abilityRound == 1 && _swiftness) ? 2 : 1;
    // Ally ATK buffs (Greybeard/Lena) convert to crit chance, like the campaign.
    final critPct = _heroCritChancePct + _bonusAtk * 2;
    for (var s = 0; s < strikes && _enemyHp > 0; s++) {
      final crit = _rng.nextInt(100) < critPct;
      final die = _heroWeaponBase > 0
          ? _heroWeaponBase + _rng.nextInt((_heroWeaponBase ~/ 3).clamp(1, 50))
          : _rng.nextInt(8) + 1;
      var dmg = ((crit ? die * _heroCritDmgMult : die) + _heroDmgMod).clamp(1, 9999);
      dmg = (dmg * (1 + _heroDmgAllPct / 100) * _heroPrestigeMult * _dmgDealtMult)
          .round().clamp(1, 9999);
      if (_eliteBlockHits > 0) {
        _eliteBlockHits--;
        setState(() => _log.add('★ $enemyName blocks the hit! ($_eliteBlockHits blocks left)'));
        continue;
      }
      if (_enemyShield > 0) {
        final absorbed = dmg < _enemyShield ? dmg : _enemyShield;
        _enemyShield -= absorbed;
        dmg = (dmg - absorbed).clamp(0, 9999);
        _log.add('✦ Arcane ward absorbs $absorbed damage!');
        if (dmg == 0) { setState(() {}); continue; }
      }
      setState(() {
        _enemyHp = (_enemyHp - dmg).clamp(0, _enemyMaxHp);
        _totalDealt += dmg;
        _log.add(crit
            ? '⚡ CRIT $dmg dmg! ($enemyName: $_enemyHp/$_enemyMaxHp)'
            : 'Hit! $dmg dmg ($enemyName: $_enemyHp/$_enemyMaxHp)');
      });
      _arenaKey.currentState?.playHeroAttack(dmg, isCrit: crit, heroClass: widget.game.hero.heroClass);
    }

    if (_enemyHp <= 0) {
      _finishVictory(enemyName);
      return;
    }

    // Enemy strikes (skip if stunned, hero dodges, or Iron Ward blocks).
    // Elite traits: swift = two attacks, frenzied = +40% ATK below half HP,
    // vampiric = heals 30% of the damage it deals.
    if (_enemyStunnedThisRound) {
      setState(() => _log.add('$enemyName is stunned — skips attack!'));
    } else {
      final trait = widget.room.eliteTrait;
      var effAtk = eAtk;
      if (trait == 'frenzied' && _enemyHp * 2 < _enemyMaxHp) {
        effAtk = (eAtk * 1.4).round();
      }
      final attacks = trait == 'swift' ? 2 : 1;
      final armor = _heroAc + _bonusAc;
      for (var a = 0; a < attacks && _heroHp > 0; a++) {
        // Attacks always land now (same model as the campaign). Ability-dodge
        // fully negates; Iron Ward blocks one hit; otherwise armor is flat
        // damage reduction (min 1 so bosses always connect).
        if (_dodgeThisRound) {
          setState(() => _log.add('$heroName dodges!'));
          continue;
        }
        final raw = _rng.nextInt(effAtk > 0 ? effAtk : 1) + 1;
        final dmg = ((raw - armor).clamp(1, 9999) * _dmgTakenMult).round().clamp(1, 9999);
        setState(() {
          _heroHp = (_heroHp - dmg).clamp(0, _heroMaxHp);
          _totalTaken += dmg;
          _log.add('$enemyName hits $dmg dmg (You: $_heroHp/$_heroMaxHp)');
        });
        _arenaKey.currentState?.playEnemyAttack(dmg);
        if (trait == 'vampiric') {
          final drain = (dmg * 0.3).round().clamp(1, 9999);
          setState(() {
            _enemyHp = (_enemyHp + drain).clamp(0, _enemyMaxHp);
            _log.add('★ $enemyName drains $drain HP!');
          });
        }
      }
    }

    // Burning affix: fire DoT at the end of every round
    if (_burnTick > 0 && _heroHp > 0) {
      setState(() {
        _heroHp = (_heroHp - _burnTick).clamp(0, _heroMaxHp);
        _totalTaken += _burnTick;
        _log.add('✸ Burning air: -$_burnTick HP (You: $_heroHp/$_heroMaxHp)');
      });
    }

    _checkAllyHpAbilities(widget.game);

    if (_heroHp <= 0) {
      _finished = true;
      _timer?.cancel();
      setState(() => _log.add('☠ $heroName has fallen!'));
      await (_arenaKey.currentState?.playHeroDeath() ?? Future.value());
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        widget.game.applyDungeonCombatOutcome(
          victory: false,
          heroHpAfter: 0,
          damageDealt: _totalDealt,
          damageTaken: _totalTaken,
          rounds: _abilityRound,
          ambushPreHit: _ambushPreHit,
        );
        widget.onResolved();
      }
      return;
    }

    setState(() {});
  }

  void _finishVictory(String enemyName) {
    _finished = true;
    _timer?.cancel();
    final boneDrop = widget.isBoss ? 3 : widget.isElite ? 2 : 1;
    setState(() => _log.add('✓ $enemyName is defeated!   🦴 +$boneDrop Bones'));
    GameStateProvider.of(context).recordExternalKill(enemyName: enemyName);
    Future.delayed(const Duration(milliseconds: 320), () {
      if (!mounted) return;
      _arenaKey.currentState?.playEnemyDeath();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          widget.game.applyDungeonCombatOutcome(
            victory: true,
            heroHpAfter: _heroHp,
            damageDealt: _totalDealt,
            damageTaken: _totalTaken,
            rounds: _abilityRound,
            ambushPreHit: _ambushPreHit,
            goldMult: _allyGoldMult,
          );
          widget.onResolved();
        }
      });
    });
  }

  void _applyAbilityInAnimation(HeroAbility ability, int sv, String enemyName) {
    _arenaKey.currentState?.playAbilityBanner(ability.name, ability.effect, id: ability.id);
    _effectKey.currentState?.playEffect(ability.id);
    switch (ability.effect) {
      case AbilityEffect.bonusDamage:
        final dmg = (sv * 0.5 * _dmgDealtMult).round().clamp(1, 9999);
        setState(() {
          _enemyHp = (_enemyHp - dmg).clamp(0, _enemyMaxHp);
          _totalDealt += dmg;
          _log.add('✦ ${ability.name}: $dmg damage ($enemyName: $_enemyHp/$_enemyMaxHp)');
        });
        _arenaKey.currentState?.addExtraFloat(dmg);
      case AbilityEffect.dot:
        final dmg = (sv * 0.6 * _dmgDealtMult).round().clamp(1, 9999);
        setState(() {
          _enemyHp = (_enemyHp - dmg).clamp(0, _enemyMaxHp);
          _totalDealt += dmg;
          _log.add('✸ ${ability.name}: $dmg DoT ($enemyName: $_enemyHp/$_enemyMaxHp)');
        });
        _arenaKey.currentState?.addExtraFloat(dmg);
      case AbilityEffect.heal:
        final h = (sv * _healMult).round().clamp(1, 9999);
        setState(() {
          _heroHp = (_heroHp + h).clamp(0, _heroMaxHp);
          _log.add('⊕ ${ability.name}: +$h HP (You: $_heroHp/$_heroMaxHp)');
        });
        _arenaKey.currentState?.addExtraFloat(h, isHeal: true);
      case AbilityEffect.aura:
        final h = (sv * 0.5 * _healMult).round().clamp(1, 9999);
        setState(() {
          _heroHp = (_heroHp + h).clamp(0, _heroMaxHp);
          _log.add('⊕ ${ability.name}: +$h HP (You: $_heroHp/$_heroMaxHp)');
        });
        _arenaKey.currentState?.addExtraFloat(h, isHeal: true);
      case AbilityEffect.attackBonus:
        _bonusAtk += sv;
        setState(() => _log.add('⚡ ${ability.name}: +$sv ATK!'));
      case AbilityEffect.acBonus:
        _bonusAc += sv;
        setState(() => _log.add('◆ ${ability.name}: +$sv AC!'));
      case AbilityEffect.stun:
        _enemyStunnedThisRound = true;
        setState(() => _log.add('◉ ${ability.name}: enemy stunned!'));
      case AbilityEffect.dodge:
        _dodgeThisRound = true;
        setState(() => _log.add('◆ ${ability.name}: dodge!'));
      case AbilityEffect.debuffWeaken:
        setState(() => _log.add('✸ ${ability.name}: enemy weakened!'));
      case AbilityEffect.debuffVulnerable:
        setState(() => _log.add('⚡ ${ability.name}: enemy vulnerable!'));
      case AbilityEffect.silence:
        _enemyStunnedThisRound = true;
        setState(() => _log.add('◉ ${ability.name}: enemy silenced!'));
      case AbilityEffect.absorbShield:
        setState(() {
          _heroHp = (_heroHp + sv).clamp(0, _heroMaxHp);
          _log.add('+ ${ability.name}: +$sv HP barrier!');
        });
        _arenaKey.currentState?.addExtraFloat(sv, isHeal: true);
      case AbilityEffect.missChance:
        setState(() => _log.add('✸ ${ability.name}: enemy miss chance applied!'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.game;
    final spriteId = widget.room.enemyId ?? (widget.isBoss ? 'shade_warrior' : 'crypt_skeleton');
    Color? bannerColor;
    String? bannerText;
    if (widget.isAmbush) { bannerColor = const Color(0xFFcc4444); bannerText = '⚔ AMBUSH — Enemy struck first!'; }
    if (widget.isElite)  { bannerColor = const Color(0xFFcc8833); bannerText = '★ ELITE ENEMY — Greater loot awaits'; }
    if (widget.isBoss)   { bannerColor = const Color(0xFFcc2222); bannerText = '☠ BOSS ENCOUNTER'; }
    final speedLabel = ['1×', '1.5×', '2×'][g.speedTier.clamp(1, 3) - 1];
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          color: (bannerColor ?? AppTheme.cardBorder).withValues(alpha: 0.12),
          child: Row(children: [
            if (bannerText != null)
              Expanded(child: Text(bannerText, textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: bannerColor, fontWeight: FontWeight.bold)))
            else
              const Spacer(),
            // Pause button
            GestureDetector(
              onTap: () => setState(() => _paused = !_paused),
              child: Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: _paused ? AppTheme.accentGold.withValues(alpha: 0.15) : Colors.transparent,
                  border: Border.all(color: _paused ? AppTheme.accentGold : AppTheme.cardBorder),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Icon(_paused ? Icons.play_arrow : Icons.pause,
                    size: 14, color: _paused ? AppTheme.accentGold : AppTheme.textMuted),
              ),
            ),
            // Speed button
            GestureDetector(
              onTap: () {
                final next = (g.speedTier % 3) + 1;
                g.setSpeedTier(next);
                _timer?.cancel();
                _timer = Timer.periodic(Duration(milliseconds: g.scaledInterval(1200)), (_) {
                  if (!_paused) _doRound();
                });
              },
              child: Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: g.speedTier > 1 ? const Color(0xFFffaa00).withValues(alpha: 0.15) : Colors.transparent,
                  border: Border.all(color: g.speedTier > 1 ? const Color(0xFFffaa00) : AppTheme.cardBorder),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(speedLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                    color: g.speedTier > 1 ? const Color(0xFFffaa00) : AppTheme.textMuted)),
              ),
            ),
          ]),
        ),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              BattleArena(
                key: _arenaKey,
                stageIndex:        (widget.run.floor - 1).clamp(0, 24),
                heroName:          g.hero.name,
                heroLevel:         g.hero.level,
                heroCurrentHp:     _heroHp,
                heroMaxHp:         _heroMaxHp,
                heroAttack:        g.avgHeroHit,
                heroSpriteId:      g.heroBattleSpriteId,
                heroGender:        g.hero.gender,
                heroRace:          g.heroRace,
                heroAuraColor:     g.heroAuraColor,
                heroAuraIntensity: g.heroAuraIntensity,
                heroColorFilter:   g.heroSpriteFilter,
                heroPet: g.equippedPet != null
                    ? PetBattleSprite(pet: g.equippedPet!)
                    : null,
                enemyName:      _displayEnemyName,
                enemyLevel:     (widget.room.enemyMaxHp ?? 10) ~/ 25 + 1,
                enemyCurrentHp: _enemyHp,
                enemyMaxHp:     _enemyMaxHp,
                enemyAttack:    widget.room.enemyAtk ?? 5,
                enemyId:        spriteId,
                isBoss:         widget.isBoss,
                heroCritPct:    g.totalCritChancePct,
                heroArmor:      g.heroArmorValue,
              ),
              ArenaAbilityEffect(key: _effectKey),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: BattleIconBar(
            localCooldownResolver: (id) {
              final readyAt = _abilityCooldownUntil[id] ?? 0;
              final remaining = readyAt - _abilityRound;
              return remaining > 0 ? remaining : 0;
            },
          ),
        ),
      ],
    );
  }
}


class _TreasureDetail extends StatelessWidget {
  const _TreasureDetail({required this.run, required this.room, required this.game, required this.onResolved});
  final DungeonRun run;
  final DungeonRoom room;
  final GameState game;
  final VoidCallback onResolved;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF231F1B),
            border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              const ZCoinIcon(size: 49),
              const SizedBox(height: 12),
              const Text('Treasure Found!',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _LootChip('💰 +${room.treasureGold ?? 0}', AppTheme.accentGold),
                const SizedBox(width: 12),
                _LootChip('◆ +${room.treasureShards ?? 0}', const Color(0xFF88aaff)),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}

class _LootChip extends StatelessWidget {
  const _LootChip(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
    );
  }
}

class _ShrineDetail extends StatefulWidget {
  const _ShrineDetail({required this.run, required this.room, required this.game, required this.onResolved});
  final DungeonRun run;
  final DungeonRoom room;
  final GameState game;
  final VoidCallback onResolved;

  @override
  State<_ShrineDetail> createState() => _ShrineDetailState();
}

class _ShrineDetailState extends State<_ShrineDetail> {
  List<ShrineEffect>? _revealed;

  void _enterShrine() {
    final rng = Random();
    final blessings = ShrineEffect.pool.where((e) => !e.isCurse).toList();
    final curses    = ShrineEffect.pool.where((e) =>  e.isCurse).toList();

    final List<ShrineEffect> effects = switch (widget.room.shrineVariant) {
      ShrineVariant.corrupted  => [curses[rng.nextInt(curses.length)]],
      ShrineVariant.benevolent => [blessings[rng.nextInt(blessings.length)]],
      ShrineVariant.twin       => [
          blessings[rng.nextInt(blessings.length)],
          curses[rng.nextInt(curses.length)],
        ],
      ShrineVariant.normal     => [ShrineEffect.pool[rng.nextInt(ShrineEffect.pool.length)]],
    };

    for (final effect in effects) {
      widget.run.shrineEffects.add(effect);
      if (effect.hpPctMod != 0) {
        final hpChange = (widget.run.heroMaxHp * effect.hpPctMod).round();
        widget.run.heroHp = (widget.run.heroHp + hpChange).clamp(1, widget.run.heroMaxHp);
      }
    }
    setState(() => _revealed = effects);
  }

  Widget _effectCard(ShrineEffect e) {
    final color = e.isCurse ? const Color(0xFFcc4444) : const Color(0xFF44cc88);
    return Column(children: [
      Text(e.icon, style: const TextStyle(fontSize: 40)),
      const SizedBox(height: 6),
      Text(e.isCurse ? '✸ CURSED!' : '✧ BLESSED!',
          style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2, color: color)),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(children: [
          Text(e.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 5),
          Text(e.description, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppTheme.textLight, height: 1.4)),
        ]),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (_revealed != null) {
      final effects = _revealed!;
      final allCurse = effects.every((e) => e.isCurse);
      final allBless = effects.every((e) => !e.isCurse);
      final closingLine = allCurse ? 'The darkness takes its toll...'
          : allBless ? 'Ancient power flows through you.'
          : 'Light and shadow bind themselves to your fate.';
      return Column(
        children: [
          ...effects.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _effectCard(e),
          )),
          Text(closingLine,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontStyle: FontStyle.italic)),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () { widget.room.resolved = true; widget.onResolved(); },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2a1a44),
                foregroundColor: const Color(0xFFcc88ff),
                side: const BorderSide(color: Color(0xFFcc88ff)),
              ),
              child: Text('CONTINUE', style: AppTheme.pixelHeading(fontSize: 12, color: const Color(0xFFcc88ff))),
            ),
          ),
        ],
      );
    }

    // -- Pre-entry: variant-specific narrative --------------------------------
    final variant = widget.room.shrineVariant;
    final (shrineIcon, shrineTitle, shrineFlavor, enterLabel, shrineColor) = switch (variant) {
      ShrineVariant.corrupted  => ('☠', 'Corrupted Shrine',  'Dark energies pulse and writhe. A curse is certain — but power awaits.', 'ACCEPT THE CURSE', const Color(0xFFcc4444)),
      ShrineVariant.benevolent => ('✧', 'Blessed Shrine',    'Warm divine light emanates from this place. A blessing is guaranteed.', 'RECEIVE BLESSING', const Color(0xFF44cc88)),
      ShrineVariant.twin       => ('✦', 'Ancient Shrine',    'Two forces stir within — you will receive both a blessing and a curse.', 'ENTER  (2 EFFECTS)', const Color(0xFFcc88ff)),
      ShrineVariant.normal     => ('✧', 'Ancient Shrine',    'A mysterious shrine pulses with unknown energy.\nEnter to receive a blessing... or a curse.\nYou won\'t know which until it\'s too late.', 'ENTER SHRINE', const Color(0xFFcc88ff)),
    };

    return Column(
      children: [
        Text(shrineIcon, style: const TextStyle(fontSize: 49)),
        const SizedBox(height: 8),
        Text(shrineTitle, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: shrineColor)),
        const SizedBox(height: 6),
        Text(shrineFlavor,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.5)),
        if (widget.run.shrineEffects.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Active effects: ${widget.run.shrineEffects.length}',
              style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
        ],
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _enterShrine,
                style: ElevatedButton.styleFrom(
                  backgroundColor: shrineColor.withValues(alpha: 0.12),
                  foregroundColor: shrineColor,
                  side: BorderSide(color: shrineColor, width: 1.5),
                ),
                child: Text(enterLabel, style: AppTheme.pixelHeading(fontSize: 11, color: shrineColor)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: () { widget.room.resolved = true; widget.onResolved(); },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textMuted,
                  side: const BorderSide(color: AppTheme.cardBorder),
                ),
                child: Text('SKIP', style: AppTheme.pixelHeading(fontSize: 12, color: AppTheme.textMuted)),
              ),
            ),
          ),
        ]),
        if (widget.game.mythril >= GameState.shrineBlissCost) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () {
                final effect = widget.game.spendMythrilForShrineBless(widget.run);
                if (effect != null) setState(() => _revealed = [effect]);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF44cc88),
                side: const BorderSide(color: Color(0xFF44cc88)),
              ),
              child: Text(
                '✧  GUARANTEE BLESSING  (${GameState.shrineBlissCost} ◆)',
                style: const TextStyle(fontSize: 11, color: Color(0xFF44cc88), fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _TrapDetail extends StatelessWidget {
  const _TrapDetail({required this.run, required this.room, required this.game, required this.onResolved});
  final DungeonRun run;
  final DungeonRoom room;
  final GameState game;
  final VoidCallback onResolved;

  static const _trapVisuals = <String, (String, int)>{
    'Poison Spikes': ('✸', 0xFF44cc44),
    'Fire Jet':      ('✦', 0xFFff6633),
    'Boulder Trap':  ('◆', 0xFF998866),
    'Arcane Curse':  ('✸', 0xFF9966ff),
    'Acid Pool':     ('✸', 0xFF88ee22),
    'Void Rift':     ('★', 0xFF6644cc),
    'Shadow Snare':  ('◆', 0xFF8888aa),
  };

  @override
  Widget build(BuildContext context) {
    final name = room.trapName ?? 'Trap';
    final visual = _trapVisuals[name];
    final trapColor = Color(visual?.$2 ?? 0xFFcc8833);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF231F1B),
            border: Border.all(color: trapColor.withValues(alpha: 0.6)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CustomPaint(
                  size: const Size(200, 100),
                  painter: _TrapScenePainter(name),
                ),
              ),
              const SizedBox(height: 10),
              Text(name,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: trapColor)),
              const SizedBox(height: 8),
              Builder(builder: (_) {
                final dmg = room.trapDamage ?? 0;
                final pct = run.heroMaxHp > 0 ? (dmg * 100 / run.heroMaxHp).round() : 0;
                return Text('You will take $dmg damage ($pct% of max HP).',
                    style: const TextStyle(fontSize: 14, color: AppTheme.textLight));
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _TrapScenePainter extends CustomPainter {
  const _TrapScenePainter(this.trapName);
  final String trapName;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint();
    final w = size.width;
    final h = size.height;

    // -- Dungeon background ----------------------------------
    p.color = const Color(0xFF1a1510);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), p);

    // Stone wall (top half)
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 8; col++) {
        final x = col * 26.0 + (row.isOdd ? 13.0 : 0.0);
        final y = row * 14.0;
        p.color = Color((0xFF222018 + (col * 3 + row * 7) % 12 * 0x010101));
        canvas.drawRect(Rect.fromLTWH(x, y, 25, 13), p);
        p.color = const Color(0xFF0e0c08);
        canvas.drawRect(Rect.fromLTWH(x, y + 13, 25, 1), p);
        canvas.drawRect(Rect.fromLTWH(x + 25, y, 1, 14), p);
      }
    }

    // Stone floor (bottom third)
    p.color = const Color(0xFF2a2418);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.65, w, h * 0.35), p);
    for (int i = 0; i < 10; i++) {
      final x = i * 22.0;
      p.color = const Color(0xFF1a1810);
      canvas.drawRect(Rect.fromLTWH(x, h * 0.65, 1, h * 0.35), p);
    }
    p.color = const Color(0xFF181410);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.65, w, 2), p);

    // -- Trap-specific art -----------------------------------
    switch (trapName) {
      case 'Poison Spikes':
        _drawPoisonSpikes(canvas, w, h);
      case 'Fire Jet':
        _drawFireJet(canvas, w, h);
      case 'Boulder Trap':
        _drawBoulder(canvas, w, h);
      case 'Arcane Curse':
        _drawArcaneCurse(canvas, w, h);
      case 'Acid Pool':
        _drawAcidPool(canvas, w, h);
      case 'Void Rift':
        _drawVoidRift(canvas, w, h);
      case 'Shadow Snare':
        _drawShadowSnare(canvas, w, h);
      default:
        _drawGenericTrap(canvas, w, h);
    }
  }

  void _drawPoisonSpikes(Canvas c, double w, double h) {
    final p = Paint();
    final baseY = h * 0.65;
    for (int i = 0; i < 7; i++) {
      final x = w * 0.2 + i * 12.0;
      final spikeH = 18.0 + (i % 3) * 6.0;
      p.color = const Color(0xFF44aa33);
      final path = Path()
        ..moveTo(x, baseY)
        ..lineTo(x + 5, baseY - spikeH)
        ..lineTo(x + 10, baseY)
        ..close();
      c.drawPath(path, p);
      p.color = const Color(0xFF66dd44);
      final highlight = Path()
        ..moveTo(x + 2, baseY)
        ..lineTo(x + 5, baseY - spikeH)
        ..lineTo(x + 5, baseY)
        ..close();
      c.drawPath(highlight, p);
    }
    // Poison drips
    p.color = const Color(0xFF33cc22).withValues(alpha: 0.6);
    c.drawCircle(Offset(w * 0.35, baseY + 6), 3, p);
    c.drawCircle(Offset(w * 0.55, baseY + 4), 2, p);
    c.drawCircle(Offset(w * 0.7, baseY + 8), 2.5, p);
  }

  void _drawFireJet(Canvas c, double w, double h) {
    final p = Paint();
    // Wall nozzles
    p.color = const Color(0xFF555550);
    c.drawRect(Rect.fromLTWH(w * 0.2, h * 0.25, 12, 8), p);
    c.drawRect(Rect.fromLTWH(w * 0.65, h * 0.25, 12, 8), p);
    // Flames
    for (int i = 0; i < 5; i++) {
      final x1 = w * 0.22 + 12;
      final x2 = w * 0.67 + 12;
      final y = h * 0.2 + i * 8.0;
      final fw = 30.0 - i * 4.0;
      p.color = Color.lerp(const Color(0xFFff4400), const Color(0xFFffcc00), i / 4.0)!
          .withValues(alpha: 1.0 - i * 0.15);
      c.drawRect(Rect.fromLTWH(x1, y, fw, 6), p);
      c.drawRect(Rect.fromLTWH(x2, y, fw, 6), p);
    }
    // Floor glow
    p.color = const Color(0xFFff4400).withValues(alpha: 0.15);
    c.drawRect(Rect.fromLTWH(0, h * 0.65, w, h * 0.35), p);
  }

  void _drawBoulder(Canvas c, double w, double h) {
    final p = Paint();
    final cx = w * 0.5;
    final cy = h * 0.45;
    // Shadow
    p.color = const Color(0xFF0a0808).withValues(alpha: 0.5);
    c.drawOval(Rect.fromCenter(center: Offset(cx, h * 0.7), width: 50, height: 12), p);
    // Boulder body
    p.color = const Color(0xFF706050);
    c.drawCircle(Offset(cx, cy), 22, p);
    p.color = const Color(0xFF908070);
    c.drawCircle(Offset(cx - 4, cy - 4), 18, p);
    // Highlight
    p.color = const Color(0xFFa09080);
    c.drawCircle(Offset(cx - 8, cy - 8), 8, p);
    // Cracks
    p.color = const Color(0xFF504030);
    c.drawRect(Rect.fromLTWH(cx - 2, cy - 5, 1, 12), p);
    c.drawRect(Rect.fromLTWH(cx + 5, cy - 3, 8, 1), p);
  }

  void _drawArcaneCurse(Canvas c, double w, double h) {
    final p = Paint()..style = PaintingStyle.stroke..strokeWidth = 2;
    final cx = w * 0.5;
    final cy = h * 0.5;
    // Rune circle
    p.color = const Color(0xFF9944ff).withValues(alpha: 0.7);
    c.drawCircle(Offset(cx, cy), 28, p);
    p.color = const Color(0xFFcc66ff).withValues(alpha: 0.5);
    c.drawCircle(Offset(cx, cy), 20, p);
    // Inner glyph lines
    p.color = const Color(0xFFdd88ff).withValues(alpha: 0.8);
    p.strokeWidth = 1.5;
    for (int i = 0; i < 6; i++) {
      final angle = i * 3.14159 / 3;
      final dx = 20 * cos(angle);
      final dy = 20 * sin(angle);
      c.drawLine(Offset(cx, cy), Offset(cx + dx, cy + dy), p);
    }
    // Center glow
    final glow = Paint()..color = const Color(0xFFcc66ff).withValues(alpha: 0.3);
    c.drawCircle(Offset(cx, cy), 10, glow);
  }

  void _drawAcidPool(Canvas c, double w, double h) {
    final p = Paint();
    final baseY = h * 0.6;
    // Pool shape
    p.color = const Color(0xFF44aa00).withValues(alpha: 0.7);
    c.drawOval(Rect.fromCenter(center: Offset(w * 0.5, baseY + 10), width: 120, height: 30), p);
    p.color = const Color(0xFF66dd00).withValues(alpha: 0.6);
    c.drawOval(Rect.fromCenter(center: Offset(w * 0.5, baseY + 8), width: 100, height: 22), p);
    p.color = const Color(0xFF88ff22).withValues(alpha: 0.4);
    c.drawOval(Rect.fromCenter(center: Offset(w * 0.5, baseY + 6), width: 60, height: 14), p);
    // Bubbles
    p.color = const Color(0xFF88ff22).withValues(alpha: 0.5);
    c.drawCircle(Offset(w * 0.4, baseY + 4), 4, p);
    c.drawCircle(Offset(w * 0.55, baseY), 3, p);
    c.drawCircle(Offset(w * 0.62, baseY + 8), 2.5, p);
    // Steam wisps
    p.color = const Color(0xFF66cc00).withValues(alpha: 0.2);
    c.drawCircle(Offset(w * 0.45, baseY - 10), 6, p);
    c.drawCircle(Offset(w * 0.58, baseY - 14), 5, p);
  }

  void _drawVoidRift(Canvas c, double w, double h) {
    final p = Paint();
    final cx = w * 0.5;
    final cy = h * 0.45;
    // Outer rift glow
    p.color = const Color(0xFF4400aa).withValues(alpha: 0.3);
    c.drawCircle(Offset(cx, cy), 35, p);
    p.color = const Color(0xFF6622cc).withValues(alpha: 0.4);
    c.drawCircle(Offset(cx, cy), 25, p);
    // Rift core
    p.color = const Color(0xFF1a0040);
    c.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: 36, height: 28), p);
    p.color = const Color(0xFF0a0020);
    c.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: 24, height: 18), p);
    // Energy streaks
    p.color = const Color(0xFF9966ff).withValues(alpha: 0.6);
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 1.5;
    c.drawOval(Rect.fromCenter(center: Offset(cx - 2, cy), width: 40, height: 20), p);
    c.drawOval(Rect.fromCenter(center: Offset(cx + 2, cy), width: 30, height: 32), p);
    p.style = PaintingStyle.fill;
    // Sparks
    p.color = const Color(0xFFcc88ff);
    c.drawCircle(Offset(cx - 18, cy - 8), 2, p);
    c.drawCircle(Offset(cx + 16, cy + 6), 1.5, p);
    c.drawCircle(Offset(cx + 8, cy - 14), 1.5, p);
  }

  void _drawShadowSnare(Canvas c, double w, double h) {
    final p = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5;
    final baseY = h * 0.6;
    // Web strands
    p.color = const Color(0xFF666688).withValues(alpha: 0.5);
    for (int i = 0; i < 8; i++) {
      final x1 = w * 0.1 + i * w * 0.1;
      final x2 = w * 0.15 + i * w * 0.1;
      c.drawLine(Offset(x1, baseY - 20), Offset(x2, baseY + 10), p);
    }
    // Horizontal web lines
    p.color = const Color(0xFF8888aa).withValues(alpha: 0.4);
    c.drawLine(Offset(w * 0.15, baseY - 10), Offset(w * 0.85, baseY - 10), p);
    c.drawLine(Offset(w * 0.1, baseY), Offset(w * 0.9, baseY), p);
    c.drawLine(Offset(w * 0.2, baseY + 8), Offset(w * 0.8, baseY + 8), p);
    // Dark tendrils from floor
    p.style = PaintingStyle.fill;
    p.color = const Color(0xFF222233).withValues(alpha: 0.6);
    for (int i = 0; i < 5; i++) {
      final x = w * 0.2 + i * w * 0.15;
      c.drawOval(Rect.fromCenter(center: Offset(x, baseY + 14), width: 14, height: 6), p);
    }
  }

  void _drawGenericTrap(Canvas c, double w, double h) {
    final p = Paint()..color = const Color(0xFFcc8833);
    final cx = w * 0.5;
    final cy = h * 0.45;
    // Warning triangle
    final path = Path()
      ..moveTo(cx, cy - 20)
      ..lineTo(cx - 18, cy + 14)
      ..lineTo(cx + 18, cy + 14)
      ..close();
    c.drawPath(path, p);
    p.color = const Color(0xFF1a1510);
    c.drawRect(Rect.fromLTWH(cx - 2, cy - 8, 4, 12), p);
    c.drawCircle(Offset(cx, cy + 10), 2.5, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -- Locked chest -------------------------------------------------------------

class _LockedChestDetail extends StatefulWidget {
  const _LockedChestDetail({required this.run, required this.room, required this.game, required this.onResolved});
  final DungeonRun run;
  final DungeonRoom room;
  final GameState game;
  final VoidCallback onResolved;

  @override
  State<_LockedChestDetail> createState() => _LockedChestDetailState();
}

class _LockedChestDetailState extends State<_LockedChestDetail>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() { _glow.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cost = widget.room.chestShardCost ?? 30;
    final canAffordShards = widget.game.shards >= cost;
    final canAffordCrystals = widget.game.zcoins >= GameState.chestCrystalCost;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF231F1B),
            border: Border.all(color: const Color(0xFF88aaff).withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(children: [
            // Chest visual — pixel art style
            AnimatedBuilder(
              animation: _glow,
              builder: (_, child) => Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF88aaff).withValues(alpha: 0.15 + _glow.value * 0.25),
                      blurRadius: 12 + _glow.value * 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: child,
              ),
              child: CustomPaint(
                size: const Size(80, 60),
                painter: _ChestPainter(),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Locked Chest',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
            const SizedBox(height: 6),
            const Text('Contains a rare or epic item.',
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
            const SizedBox(height: 14),
            // Shard option
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('◆', style: TextStyle(fontSize: 17, color: Color(0xFF88aaff))),
              const SizedBox(width: 6),
              Text('$cost shards',
                  style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold,
                    color: canAffordShards ? const Color(0xFF88aaff) : const Color(0xFF556677),
                  )),
              if (!canAffordShards) ...[
                const SizedBox(width: 8),
                Text('(have ${widget.game.shards})',
                    style: const TextStyle(fontSize: 11, color: Color(0xFFcc4444))),
              ],
            ]),
            // Crystal fallback
            if (!canAffordShards) ...[
              const SizedBox(height: 10),
              Container(height: 1, color: const Color(0xFF3a3020)),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const ZCoinIcon(size: 17, animate: false),
                const SizedBox(width: 6),
                Text('${GameState.chestCrystalCost} ZCoins',
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold,
                      color: canAffordCrystals ? const Color(0xFFffcc44) : const Color(0xFF556677),
                    )),
                if (!canAffordCrystals) ...[
                  const SizedBox(width: 8),
                  Text('(have ${widget.game.zcoins})',
                      style: const TextStyle(fontSize: 11, color: Color(0xFFcc4444))),
                ],
              ]),
            ],
          ]),
        ),
      ],
    );
  }
}

class _ChestPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const s = 5.0;
    void b(double x, double y, double w, double h, int c) =>
        canvas.drawRect(Rect.fromLTWH(x * s, y * s, w * s, h * s), Paint()..color = Color(c));

    // Chest body (wood)
    b(1, 4, 14, 8, 0xFF5a3818);
    b(2, 4, 12, 7, 0xFF7a4820);
    b(2, 4, 12, 1, 0xFF8a5828);
    // Lid (curved top)
    b(1, 1, 14, 4, 0xFF6a3818);
    b(2, 0, 12, 3, 0xFF7a4820);
    b(3, 0, 10, 1, 0xFF8a5828);
    // Metal bands
    b(1, 3, 14, 1, 0xFF888898);
    b(1, 8, 14, 1, 0xFF888898);
    b(7, 0, 2, 4, 0xFF888898);
    // Lock
    b(7, 4, 2, 2, 0xFFd4af37);
    b(7, 4, 2, 1, 0xFFffe060);
    // Keyhole
    b(7.5, 5, 1, 1, 0xFF2a1808);
    // Corner rivets
    b(1, 3, 1, 1, 0xFFaaaaaa);
    b(14, 3, 1, 1, 0xFFaaaaaa);
    b(1, 8, 1, 1, 0xFFaaaaaa);
    b(14, 8, 1, 1, 0xFFaaaaaa);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -- Rest site -----------------------------------------------------------------

class _RestSiteDetail extends StatefulWidget {
  const _RestSiteDetail({required this.run, required this.room, required this.game, required this.onResolved});
  final DungeonRun run;
  final DungeonRoom room;
  final GameState game;
  final VoidCallback onResolved;

  @override
  State<_RestSiteDetail> createState() => _RestSiteDetailState();
}

class _RestSiteDetailState extends State<_RestSiteDetail> {
  final Set<String> _purchased = {};

  @override
  Widget build(BuildContext context) {
    final room  = widget.room;
    final run   = widget.run;
    final heal  = room.restoreHp ?? (run.heroMaxHp ~/ 5);
    final dmg   = room.restDamage;
    final newHp = (run.heroHp - dmg + heal).clamp(0, run.heroMaxHp);

    final (icon, accentColor) = switch (room.restEventType) {
      RestEventType.ambush     => ('‼', const Color(0xFFcc6644)),
      RestEventType.badWeather => ('✸', const Color(0xFF88aacc)),
      RestEventType.haunted    => ('◉', const Color(0xFFaa88cc)),
      RestEventType.wanderer   => ('►', const Color(0xFF44cc88)),
      RestEventType.supplies   => ('✦', AppTheme.accentGold),
      RestEventType.peaceful   => ('⊕', const Color(0xFF44cc88)),
      RestEventType.merchant   => ('◆', const Color(0xFFddaa44)),
    };

    if (room.restEventType == RestEventType.merchant) {
      return _buildShop(accentColor);
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF231F1B),
            border: Border.all(color: accentColor.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(children: [
            Text(icon, style: const TextStyle(fontSize: 49)),
            const SizedBox(height: 8),
            Text(room.restEventTitle,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold,
                    color: room.restEventType == RestEventType.peaceful
                        ? AppTheme.textLight : accentColor)),
            const SizedBox(height: 6),
            if (room.restEventFlavor.isNotEmpty)
              Text(room.restEventFlavor,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.5),
                  textAlign: TextAlign.center),
            const SizedBox(height: 14),
            if (dmg > 0) ...[
              _LootChip('✸ -$dmg HP  (${(dmg * 100 / run.heroMaxHp).round()}% of max)', const Color(0xFFcc4444)),
              const SizedBox(height: 6),
            ],
            _LootChip('⊕ +$heal HP  (→ $newHp / ${run.heroMaxHp})', const Color(0xFF44cc88)),
            if (room.restBonusGold > 0) ...[
              const SizedBox(height: 6),
              _LootChip('💰 +${room.restBonusGold} gold', AppTheme.accentGold),
            ],
          ]),
        ),
      ],
    );
  }

  Widget _buildShop(Color accent) {
    final game  = widget.game;
    final room  = widget.room;
    final run   = widget.run;
    final stock = DungeonMerchantItem.stockForTier(run.tier, run.floor);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF231F1B),
            border: Border.all(color: accent.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(children: [
            const Text('⊕', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(room.restEventTitle,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: accent)),
            const SizedBox(height: 4),
            if (room.restEventFlavor.isNotEmpty)
              Text(room.restEventFlavor,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.5),
                  textAlign: TextAlign.center),
            const SizedBox(height: 4),
            const Text('"Bones for trinkets, traveller. More bones, finer wares."',
                style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontStyle: FontStyle.italic, height: 1.4),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF0e0c08),
                border: Border.all(color: const Color(0xFFccbb99).withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text('🦴  ${run.bones} Bones',
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFFe8dcc0), fontWeight: FontWeight.bold)),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        for (final item in stock) ...[
          _MerchantItemRow(
            item: item,
            purchased: _purchased.contains(item.id),
            canAfford: run.bones >= item.boneCost,
            onBuy: () {
              final bought = game.buyDungeonMerchantItem(item.id);
              if (bought != null) setState(() => _purchased.add(item.id));
            },
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _MerchantItemRow extends StatelessWidget {
  const _MerchantItemRow({
    required this.item,
    required this.purchased,
    required this.canAfford,
    required this.onBuy,
  });
  final DungeonMerchantItem item;
  final bool purchased;
  final bool canAfford;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final dim = purchased || !canAfford;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: purchased ? const Color(0xFF151510) : const Color(0xFF231F1B),
        border: Border.all(
          color: purchased
              ? Colors.white12
              : const Color(0xFFddaa44).withValues(alpha: 0.35),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(children: [
        Text(item.icon,
            style: TextStyle(fontSize: 22, color: dim ? Colors.white24 : null)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: dim ? Colors.white24 : Colors.white)),
              const SizedBox(height: 2),
              Text(item.desc,
                  style: TextStyle(
                      fontSize: 11,
                      color: dim ? Colors.white12 : AppTheme.textMuted)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (purchased)
          const Icon(Icons.check_circle, color: Color(0xFF44cc88), size: 20)
        else
          GestureDetector(
            onTap: canAfford ? onBuy : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: canAfford
                    ? const Color(0xFF2a1f08)
                    : const Color(0xFF1a1a14),
                border: Border.all(
                  color: canAfford
                      ? AppTheme.accentGold.withValues(alpha: 0.7)
                      : Colors.white12,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text('${item.boneCost} 🦴',
                  style: TextStyle(
                      fontSize: 12,
                      color: canAfford
                          ? const Color(0xFFe8dcc0)
                          : Colors.white24,
                      fontWeight: FontWeight.bold)),
            ),
          ),
      ]),
    );
  }
}

// -- Relic picker (after boss kills) -------------------------------------------

class _RelicPicker extends StatelessWidget {
  const _RelicPicker({required this.run, required this.game});
  final DungeonRun run;
  final GameState game;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('☠ BOSS SLAIN — CLAIM A RELIC',
            textAlign: TextAlign.center,
            style: AppTheme.pixelHeading(fontSize: 12, letterSpacing: 2, color: const Color(0xFFcc88ff))),
        const SizedBox(height: 8),
        for (final relic in run.relicChoices)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: GestureDetector(
              onTap: () => game.chooseDungeonRelic(relic),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1a0a2a).withValues(alpha: 0.6),
                  border: Border.all(color: const Color(0xFFcc88ff).withValues(alpha: 0.6)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(children: [
                  Text(relic.icon, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(relic.name,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFdd99ff))),
                        const SizedBox(height: 2),
                        Text(relic.description,
                            style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFFcc88ff), size: 20),
                ]),
              ),
            ),
          ),
      ],
    );
  }
}

// -- Room result ---------------------------------------------------------------

class _RoomResult extends StatelessWidget {
  const _RoomResult({required this.run, required this.game, required this.onNext});
  final DungeonRun run;
  final GameState game;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final room = run.currentRoom!;
    final isDead = run.isDead;

    return Column(
      children: [
        _HeroBar(run: run, game: game),
        // Action button always visible at top — above the scrollable result
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: isDead
              ? SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A2623),
                      side: const BorderSide(color: AppTheme.cardBorder),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: Text('RETURN',
                        style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 1, color: AppTheme.textMuted)),
                  ),
                )
              : run.relicChoices.isNotEmpty
                  ? _RelicPicker(run: run, game: game)
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onNext,
                        icon: const Text('⚔', style: TextStyle(fontSize: 16)),
                        label: Text('DESCEND TO FLOOR ${run.floor + 1}',
                            style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 1, color: const Color(0xFF44cc88))),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0d1e14),
                          foregroundColor: const Color(0xFF44cc88),
                          side: const BorderSide(color: Color(0xFF44cc88), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                    ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Result header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF231F1B),
                    border: Border.all(
                      color: isDead ? const Color(0xFFcc4444) : const Color(0xFF44cc88),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      if (room.type == DungeonRoomType.combat || room.type == DungeonRoomType.boss ||
                          room.type == DungeonRoomType.elite || room.type == DungeonRoomType.ambush) ...[
                        Text(isDead ? '☠ Fallen'
                                : room.goblinEscaped ? '💰 It got away!'
                                : '✓ Victory',
                            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold,
                                color: isDead ? const Color(0xFFcc4444)
                                    : room.goblinEscaped ? const Color(0xFFffcc33)
                                    : const Color(0xFF44cc88))),
                        if (run.ambushPreHit > 0 && isDead) ...[
                          const SizedBox(height: 4),
                          Text('Ambush hit dealt ${run.ambushPreHit} before the fight.',
                              style: const TextStyle(fontSize: 12, color: Color(0xFFcc8833)),
                              textAlign: TextAlign.center),
                        ],
                        const SizedBox(height: 8),
                        Text(run.lastCombatSummary,
                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            textAlign: TextAlign.center),
                        if (!isDead && !room.goblinEscaped) ...[
                          const SizedBox(height: 12),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            _LootChip('💰 +${_calcCombatGold(run, room)}', AppTheme.accentGold),
                          ]),
                          if (room.hasItemDrop && game.dungeonLastDrop != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: game.dungeonLastDrop!.rarityColor.withValues(alpha: 0.08),
                                border: Border.all(color: game.dungeonLastDrop!.rarityColor.withValues(alpha: 0.5)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('✦ ${game.dungeonLastDrop!.name} (${game.dungeonLastDrop!.rarityLabel}) → Bag',
                                  style: TextStyle(fontSize: 12, color: game.dungeonLastDrop!.rarityColor,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ] else if (room.type == DungeonRoomType.restSite) ...[
                        const Text('⊕ Rested',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF44cc88))),
                        const SizedBox(height: 8),
                        _LootChip('⊕ +${room.restoreHp} HP', const Color(0xFF44cc88)),
                      ] else if (room.type == DungeonRoomType.treasure) ...[
                        const Text('✦ Treasure collected',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF44cc88))),
                        const SizedBox(height: 8),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          _LootChip('💰 +${room.treasureGold}', AppTheme.accentGold),
                          const SizedBox(width: 10),
                          _LootChip('◆ +${room.treasureShards}', const Color(0xFF88aaff)),
                        ]),
                      ] else if (room.type == DungeonRoomType.shrine) ...[
                        const Text('✧ Blessing received',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF44cc88))),
                        if (run.blessings.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(run.blessings.last.label,
                                style: const TextStyle(fontSize: 14, color: Color(0xFF44cc88))),
                          ),
                      ] else if (room.type == DungeonRoomType.trap) ...[
                        Text(isDead ? '☠ Slain by the trap' : '✸ Trap survived',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold,
                                color: isDead ? const Color(0xFFcc4444) : const Color(0xFF44cc88))),
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text('-${room.trapDamage} HP',
                              style: const TextStyle(fontSize: 14, color: Color(0xFFcc8833))),
                        ),
                      ] else if (room.type == DungeonRoomType.lockedChest) ...[
                        const Text('◆ Chest opened',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF44cc88))),
                        if (game.dungeonLastDrop != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: game.dungeonLastDrop!.rarityColor.withValues(alpha: 0.08),
                              border: Border.all(color: game.dungeonLastDrop!.rarityColor.withValues(alpha: 0.5)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('✦ ${game.dungeonLastDrop!.name} (${game.dungeonLastDrop!.rarityLabel}) → Bag',
                                style: TextStyle(fontSize: 12, color: game.dungeonLastDrop!.rarityColor,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),

                if (isDead) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF231F1B),
                      border: Border.all(color: AppTheme.cardBorder),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('Your loot has already been added to your account.',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        textAlign: TextAlign.center),
                  ),
                ],

              ],
            ),
          ),
        ),
      ],
    );
  }

  int _calcCombatGold(DungeonRun run, DungeonRoom room) {
    final base = switch (room.type) {
      DungeonRoomType.boss   => 200 + run.floor * 80,
      DungeonRoomType.elite  => 100 + run.floor * 40,
      DungeonRoomType.ambush => 140 + run.floor * 50,
      _                      => 80  + run.floor * 30,
    };
    return (base * run.goldBonusMult).round();
  }
}

// -- Summary -------------------------------------------------------------------

class _DungeonSummary extends StatelessWidget {
  const _DungeonSummary({
    required this.run,
    required this.game,
    required this.autoRun,
    required this.onToggleAuto,
    required this.onExit,
    required this.onRunAgain,
  });
  final DungeonRun run;
  final GameState game;
  final bool autoRun;
  final VoidCallback onToggleAuto;
  final VoidCallback onExit;
  final VoidCallback onRunAgain;

  @override
  Widget build(BuildContext context) {
    final isRecord    = run.floor >= game.deepestDungeonFloor;
    final tierCleared = run.bossesDefeated >= 1;
    final autoUnlocked = run.tier <= game.dungeonHighestTier || tierCleared;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF231F1B),
              border: Border.all(
                color: run.isDead ? const Color(0xFFcc4444)
                    : run.isCleared ? const Color(0xFF44cc88)
                    : AppTheme.accentGold,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                Text(run.isDead ? '☠' : '★', style: const TextStyle(fontSize: 49)),
                const SizedBox(height: 8),
                Text(
                  run.isDead ? 'YOU HAVE FALLEN'
                      : run.isCleared ? 'DUNGEON CLEARED!'
                      : 'RUN ENDED',
                  style: AppTheme.pixelHeading(
                    fontSize: 15, letterSpacing: 2,
                    color: run.isDead ? const Color(0xFFcc4444)
                        : run.isCleared ? const Color(0xFF44cc88)
                        : AppTheme.textLight,
                  ),
                ),
                if (run.isCleared) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF44cc88).withValues(alpha: 0.10),
                      border: Border.all(color: const Color(0xFF44cc88).withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      'The Dungeon Lord has fallen!\n+5 mythril  •  +${2 * run.tier} Z-Coins  •  +${500 * run.tier} gold  •  bonus item',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF66ddaa), height: 1.5),
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text('TIER ${run.tier}',
                    style: AppTheme.pixelHeading(fontSize: 11, color: AppTheme.textMuted, letterSpacing: 2)),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _SummaryPill('FLOOR', '${run.floor}', AppTheme.textLight),
                  const SizedBox(width: 12),
                  _SummaryPill('ROOMS', '${run.roomsCleared}', AppTheme.textMuted),
                  const SizedBox(width: 12),
                  _SummaryPill('BOSSES', '${run.bossesDefeated}', const Color(0xFFcc4444)),
                ]),
                const SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _SummaryPill('GOLD', '+${run.goldEarned}', AppTheme.accentGold),
                  const SizedBox(width: 16),
                  _SummaryPill('SHARDS', '+${run.shardsEarned}', const Color(0xFF88aaff)),
                ]),
                if (tierCleared && run.tier > (game.dungeonHighestTier - 1)) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF44cc88).withValues(alpha: 0.1),
                      border: Border.all(color: const Color(0xFF44cc88).withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('✓ Tier ${run.tier} cleared — AUTO unlocked!',
                        style: AppTheme.pixelHeading(fontSize: 11, color: const Color(0xFF44cc88))),
                  ),
                ],
                if (isRecord && run.floor > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withValues(alpha: 0.1),
                      border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('★ New record!',
                        style: AppTheme.pixelHeading(fontSize: 11, color: AppTheme.accentGold)),
                  ),
                ],
                const SizedBox(height: 4),
                const Text('All loot has been added to your account.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // AUTO / RUN AGAIN row
          Row(children: [
            if (autoUnlocked) ...[
              Expanded(
                child: ElevatedButton(
                  onPressed: onToggleAuto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: autoRun
                        ? const Color(0xFF1a3a2a)
                        : const Color(0xFF231F1B),
                    side: BorderSide(
                      color: autoRun ? const Color(0xFF44cc88) : AppTheme.cardBorder,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: Text(
                    autoRun ? '◉ STOP' : '✦ AUTO',
                    style: AppTheme.pixelHeading(
                      fontSize: 13, letterSpacing: 1,
                      color: autoRun ? const Color(0xFF44cc88) : AppTheme.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: ElevatedButton(
                onPressed: autoRun ? null : onRunAgain,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2a1f00),
                  disabledBackgroundColor: const Color(0xFF1a1510),
                  side: BorderSide(color: autoRun ? AppTheme.cardBorder : AppTheme.accentGold, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: Text('RUN AGAIN',
                    style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 1,
                        color: autoRun ? AppTheme.cardBorder : AppTheme.accentGold)),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onExit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A2623),
                side: const BorderSide(color: AppTheme.cardBorder),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: Text('RETURN TO HALL',
                  style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 1, color: AppTheme.textMuted)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTheme.pixelHeading(fontSize: 10, color: AppTheme.textMuted)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
