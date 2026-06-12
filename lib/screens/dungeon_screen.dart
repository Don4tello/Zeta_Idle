import 'dart:async';
import 'package:flutter/material.dart';
import '../models/dungeon.dart';
import '../screens/main_shell.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/ability_bar.dart';
import '../widgets/battle_arena.dart';
import '../widgets/pet_battle_sprite.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DungeonScreen
//
// States:
//   1. No active run → lobby / record card + ENTER button
//   2. Active run, room not yet resolved → room detail + action (auto-selected)
//   3. Active run, room resolved → result + NEXT FLOOR button
//   4. Run over (dead or abandoned) → summary
// ─────────────────────────────────────────────────────────────────────────────

class DungeonScreen extends StatefulWidget {
  const DungeonScreen({super.key});

  @override
  State<DungeonScreen> createState() => _DungeonScreenState();
}

class _DungeonScreenState extends State<DungeonScreen> {
  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final run  = game.activeDungeon;

    final body = switch (run) {
      null               => _DungeonLobby(game: game, onStart: () => setState(() => game.startDungeon())),
      _ when run.isOver  => _DungeonSummary(run: run, game: game, onExit: _exitDungeon),
      _ when run.currentRoom == null || !run.currentRoom!.resolved
                         => _RoomDetail(run: run, game: game, onResolved: () => setState(() {})),
      _                  => _RoomResult(run: run, game: game, onNext: _afterRoom),
    };

    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: run == null
            ? Text('THE DUNGEON', style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2))
            : Text('FLOOR ${run.floor}  —  THE DUNGEON',
                style: AppTheme.pixelHeading(fontSize: 12, letterSpacing: 1)),
        actions: [
          if (run != null && !run.isOver)
            TextButton(
              onPressed: _abandon,
              child: Text('FLEE', style: AppTheme.pixelHeading(fontSize: 10, color: const Color(0xFFcc4444))),
            ),
        ],
      ),
      body: body,
    );
  }

  void _abandon() => setState(() => GameStateProvider.of(context).abandonDungeon());
  void _afterRoom() {
    final game = GameStateProvider.of(context);
    final run  = game.activeDungeon;
    if (run == null || run.isOver) { setState(() {}); return; }
    game.advanceDungeonFloor();
    setState(() {});
  }
  void _exitDungeon() => setState(() => GameStateProvider.of(context).activeDungeon = null);
}

// ── Lobby ─────────────────────────────────────────────────────────────────────

class _DungeonLobby extends StatelessWidget {
  const _DungeonLobby({required this.game, required this.onStart});
  final GameState game;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF231F1B),
              border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                const Text('🏰', style: TextStyle(fontSize: 49)),
                const SizedBox(height: 12),
                Text('THE DUNGEON', style: AppTheme.pixelHeading(fontSize: 15, letterSpacing: 2, color: AppTheme.accentGold)),
                const SizedBox(height: 8),
                const Text(
                  'Descend the cursed dungeon. Survive as many floors as you can.\n'
                  'Every 5th floor is a Boss. Loot is yours — even if you fall.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.5),
                ),
                const SizedBox(height: 16),
                _RecordChip(floor: game.deepestDungeonFloor),
              ],
            ),
          ),
          TutorialTip(
            tutorialKey: 'dungeon',
            game: game,
            text: 'Rooms are chosen for you automatically. Each run starts with 3 consumables. '
                'Loot is yours immediately — even if your hero falls.',
          ),
          const SizedBox(height: 16),
          _InfoCard(),
          const SizedBox(height: 20),
          _EnterButton(onStart: onStart),
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
            ('💀', 'Elite — tougher foe, guaranteed item drop'),
            ('🗡', 'Ambush — enemy strikes first, high gold'),
            ('🏕', 'Rest Site — recover 20% HP'),
            ('💎', 'Treasure — claim gold & shards'),
            ('🕯', 'Shrine — choose a run-long blessing'),
            ('🔒', 'Locked Chest — spend shards for a rare item'),
            ('⚠', 'Trap — unavoidable damage'),
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
          const Text('You start each run with 3 consumables.',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

class _EnterButton extends StatelessWidget {
  const _EnterButton({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onStart,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2a1f00),
          foregroundColor: AppTheme.accentGold,
          side: const BorderSide(color: AppTheme.accentGold, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Text('ENTER DUNGEON', style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2, color: AppTheme.accentGold)),
      ),
    );
  }
}

// ── Hero HP bar (shared) ──────────────────────────────────────────────────────

class _HeroBar extends StatelessWidget {
  const _HeroBar({required this.run});
  final DungeonRun run;

  @override
  Widget build(BuildContext context) {
    final pct = (run.heroHp / run.heroMaxHp).clamp(0.0, 1.0);
    final hpColor = pct > 0.5 ? const Color(0xFF88cc44) : pct > 0.25 ? const Color(0xFFcc8833) : const Color(0xFFcc4444);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF231F1B),
        border: Border(bottom: BorderSide(color: AppTheme.cardBorder)),
      ),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('HP', style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2, color: hpColor)),
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
          if (run.blessings.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: run.blessings.map((b) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1a3a2a),
                  border: Border.all(color: const Color(0xFF44cc88)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(b.label, style: const TextStyle(fontSize: 10, color: Color(0xFF44cc88))),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Consumable bar (shared) ───────────────────────────────────────────────────

class _ConsumableBar extends StatelessWidget {
  const _ConsumableBar({required this.run, required this.onUse});
  final DungeonRun run;
  final void Function(DungeonConsumableType) onUse;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF231F1B),
        border: Border(top: BorderSide(color: AppTheme.cardBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: run.consumables.map((c) {
          final available = !c.used;
          return Tooltip(
            message: c.desc,
            child: GestureDetector(
              onTap: available ? () => onUse(c.type) : null,
              child: Opacity(
                opacity: available ? 1.0 : 0.3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: available ? const Color(0xFF1a2a1a) : AppTheme.cardBg,
                    border: Border.all(color: available ? const Color(0xFF44aa44) : AppTheme.cardBorder),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(c.label, style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Room detail ───────────────────────────────────────────────────────────────

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
        _HeroBar(run: run),
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
        _ConsumableBar(run: run, onUse: (t) { game.useDungeonConsumable(t); onResolved(); }),
      ],
    );
  }
}

// ── Animated combat room ──────────────────────────────────────────────────────

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
  final _arenaKey = GlobalKey<BattleArenaState>();
  Timer? _timer;
  bool _finished = false;

  late int _heroHp;
  late int _heroMaxHp;
  late int _enemyHp;
  late int _enemyMaxHp;
  late int _heroAtk;
  late int _heroAc;
  late int _heroDmgMod;

  @override
  void initState() {
    super.initState();
    final g = widget.game;
    _heroHp    = widget.run.heroHp;
    _heroMaxHp = widget.run.heroMaxHp;
    _enemyHp   = widget.room.enemyMaxHp ?? 10;
    _enemyMaxHp = _enemyHp;
    _heroAtk   = g.hero.attackBonus;
    _heroAc    = g.hero.armorClass;
    _heroDmgMod = g.hero.strMod.clamp(0, 20);
    _timer = Timer.periodic(const Duration(milliseconds: 600), (_) => _doRound());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _doRound() {
    if (_finished || !mounted) return;
    final eAc  = widget.room.enemyAc  ?? 10;
    final eAtk = widget.room.enemyAtk ?? 5;
    final rng  = DateTime.now().microsecondsSinceEpoch;

    // Hero strikes
    final heroRoll = rng % 20 + 1;
    final crit     = heroRoll == 20;
    if (crit || (heroRoll + _heroAtk) >= eAc) {
      final die = rng % 8 + 1;
      final dmg = ((crit ? die * 2 : die) + _heroDmgMod).clamp(1, 9999);
      setState(() => _enemyHp = (_enemyHp - dmg).clamp(0, _enemyMaxHp));
      _arenaKey.currentState?.playHeroAttack(dmg, isCrit: crit, heroClass: widget.game.hero.heroClass);
    }

    if (_enemyHp <= 0) {
      _finished = true;
      _timer?.cancel();
      _arenaKey.currentState?.playEnemyDeath();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) { widget.game.resolveDungeonCombat(); widget.onResolved(); }
      });
      return;
    }

    // Enemy strikes
    final eRoll  = rng ~/ 100 % 20 + 1;
    final eBonus = (eAtk ~/ 8).clamp(0, 12);
    if (eRoll == 20 || (eRoll + eBonus) >= _heroAc) {
      final dmg = (rng ~/ 1000 % (eAtk > 0 ? eAtk : 1) + 1).clamp(1, 9999);
      setState(() => _heroHp = (_heroHp - dmg).clamp(0, _heroMaxHp));
      _arenaKey.currentState?.playEnemyAttack(dmg);
    }

    if (_heroHp <= 0) {
      _finished = true;
      _timer?.cancel();
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) { widget.game.resolveDungeonCombat(); widget.onResolved(); }
      });
      return;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.game;
    final spriteId = widget.isBoss ? 'shade_warrior' : 'crypt_skeleton';
    Color? bannerColor;
    String? bannerText;
    if (widget.isAmbush) { bannerColor = const Color(0xFFcc4444); bannerText = '🗡 AMBUSH — Enemy struck first!'; }
    if (widget.isElite)  { bannerColor = const Color(0xFFcc8833); bannerText = '💀 ELITE ENEMY — Greater loot awaits'; }
    if (widget.isBoss)   { bannerColor = const Color(0xFFcc2222); bannerText = '☠ BOSS ENCOUNTER'; }
    return Column(
      children: [
        if (bannerText != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            color: bannerColor!.withValues(alpha: 0.18),
            child: Text(bannerText, textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: bannerColor, fontWeight: FontWeight.bold)),
          ),
        Expanded(
          child: BattleArena(
            key: _arenaKey,
            heroName:          g.hero.name,
            heroLevel:         g.hero.level,
            heroCurrentHp:     _heroHp,
            heroMaxHp:         _heroMaxHp,
            heroAttack:        _heroAtk,
            heroSpriteId:      g.hero.spriteId,
            heroAuraColor:     g.heroAuraColor,
            heroAuraIntensity: g.heroAuraIntensity,
            heroColorFilter:   g.heroSkinFilter,
            heroPet: g.equippedPet != null
                ? PetBattleSprite(pet: g.equippedPet!, size: 28)
                : null,
            enemyName:      widget.room.enemyName ?? 'Enemy',
            enemyLevel:     (widget.room.enemyMaxHp ?? 10) ~/ 25 + 1,
            enemyCurrentHp: _enemyHp,
            enemyMaxHp:     _enemyMaxHp,
            enemyAttack:    widget.room.enemyAtk ?? 5,
            enemyId:        spriteId,
            isBoss:         widget.isBoss,
          ),
        ),
        const AbilityBar(),
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
              const Text('💎', style: TextStyle(fontSize: 49)),
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
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () { game.collectDungeonTreasure(); onResolved(); },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2a1f00),
              side: const BorderSide(color: AppTheme.accentGold, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: Text('COLLECT', style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2, color: AppTheme.accentGold)),
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

class _ShrineDetail extends StatelessWidget {
  const _ShrineDetail({required this.run, required this.room, required this.game, required this.onResolved});
  final DungeonRun run;
  final DungeonRoom room;
  final GameState game;
  final VoidCallback onResolved;

  @override
  Widget build(BuildContext context) {
    final choices = room.blessingChoices ?? [];
    return Column(
      children: [
        const Text('🕯', style: TextStyle(fontSize: 49)),
        const SizedBox(height: 8),
        const Text('Ancient Shrine', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
        const SizedBox(height: 4),
        const Text('Choose one blessing for the rest of this run.',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
        const SizedBox(height: 16),
        ...choices.map((b) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _BlessingCard(
            blessing: b,
            onTap: () { game.chooseDungeonBlessing(b); onResolved(); },
          ),
        )),
      ],
    );
  }
}

class _BlessingCard extends StatelessWidget {
  const _BlessingCard({required this.blessing, required this.onTap});
  final DungeonBlessingType blessing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF231F1B),
          border: Border.all(color: const Color(0xFF44cc88)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(blessing.label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF44cc88))),
                const SizedBox(height: 3),
                Text(blessing.desc, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              ]),
            ),
            const Icon(Icons.check_circle_outline, color: Color(0xFF44cc88), size: 20),
          ],
        ),
      ),
    );
  }
}

class _TrapDetail extends StatelessWidget {
  const _TrapDetail({required this.run, required this.room, required this.game, required this.onResolved});
  final DungeonRun run;
  final DungeonRoom room;
  final GameState game;
  final VoidCallback onResolved;

  @override
  Widget build(BuildContext context) {
    final hasPot = run.consumables.any((c) => c.type == DungeonConsumableType.healthPotion && !c.used);
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF231F1B),
            border: Border.all(color: const Color(0xFFcc8833).withValues(alpha: 0.6)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              const Text('⚠', style: TextStyle(fontSize: 49)),
              const SizedBox(height: 8),
              Text(room.trapName ?? 'Trap',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFFcc8833))),
              const SizedBox(height: 8),
              Text('You will take ${room.trapDamage ?? 0} damage.',
                  style: const TextStyle(fontSize: 14, color: AppTheme.textLight)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () { game.resolveDungeonTrap(); onResolved(); },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3a2200),
              side: const BorderSide(color: Color(0xFFcc8833), width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: Text('PROCEED (take ${room.trapDamage ?? 0} dmg)',
                style: AppTheme.pixelHeading(fontSize: 12, letterSpacing: 1, color: const Color(0xFFcc8833))),
          ),
        ),
        if (hasPot) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () { game.useDungeonConsumable(DungeonConsumableType.healthPotion); onResolved(); },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF44cc88),
                side: const BorderSide(color: Color(0xFF44cc88)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: Text('USE HEAL POTION (heal 40%, skip trap)',
                  style: AppTheme.pixelHeading(fontSize: 11, color: const Color(0xFF44cc88))),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Locked chest ─────────────────────────────────────────────────────────────

class _LockedChestDetail extends StatelessWidget {
  const _LockedChestDetail({required this.run, required this.room, required this.game, required this.onResolved});
  final DungeonRun run;
  final DungeonRoom room;
  final GameState game;
  final VoidCallback onResolved;

  @override
  Widget build(BuildContext context) {
    final cost = room.chestShardCost ?? 30;
    final canAfford = game.shards >= cost;
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
            const Text('🔒', style: TextStyle(fontSize: 49)),
            const SizedBox(height: 8),
            const Text('Locked Chest',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
            const SizedBox(height: 6),
            const Text('Contains a rare or epic item.',
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
            const SizedBox(height: 14),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('◆', style: TextStyle(fontSize: 19, color: Color(0xFF88aaff))),
              const SizedBox(width: 6),
              Text('$cost shards to open',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF88aaff), fontWeight: FontWeight.bold)),
            ]),
            if (!canAfford) ...[
              const SizedBox(height: 6),
              Text('You only have ${game.shards} shards.',
                  style: const TextStyle(fontSize: 12, color: Color(0xFFcc4444))),
            ],
          ]),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canAfford ? () {
              game.openDungeonChest();
              onResolved();
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0e1a3a),
              disabledBackgroundColor: AppTheme.cardBg,
              side: BorderSide(color: canAfford ? const Color(0xFF88aaff) : AppTheme.cardBorder, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: Text(
              canAfford ? 'OPEN  ($cost ◆)' : 'NOT ENOUGH SHARDS',
              style: AppTheme.pixelHeading(fontSize: 12, letterSpacing: 1,
                  color: canAfford ? const Color(0xFF88aaff) : AppTheme.cardBorder),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              room.resolved = true;
              onResolved();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textMuted,
              side: const BorderSide(color: AppTheme.cardBorder),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: Text('LEAVE IT', style: AppTheme.pixelHeading(fontSize: 11, color: AppTheme.textMuted)),
          ),
        ),
      ],
    );
  }
}

// ── Rest site ─────────────────────────────────────────────────────────────────

class _RestSiteDetail extends StatelessWidget {
  const _RestSiteDetail({required this.run, required this.room, required this.game, required this.onResolved});
  final DungeonRun run;
  final DungeonRoom room;
  final GameState game;
  final VoidCallback onResolved;

  @override
  Widget build(BuildContext context) {
    final heal = room.restoreHp ?? (run.heroMaxHp ~/ 5);
    final newHp = (run.heroHp + heal).clamp(0, run.heroMaxHp);
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF231F1B),
            border: Border.all(color: const Color(0xFF44cc88).withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(children: [
            const Text('🏕', style: TextStyle(fontSize: 49)),
            const SizedBox(height: 8),
            const Text('Rest Site',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
            const SizedBox(height: 6),
            const Text('Take a moment to recover before pressing deeper.',
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted), textAlign: TextAlign.center),
            const SizedBox(height: 14),
            _LootChip('❤ +$heal HP  (→ $newHp / ${run.heroMaxHp})', const Color(0xFF44cc88)),
          ]),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () { game.resolveDungeonRestSite(); onResolved(); },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0e2a1a),
              side: const BorderSide(color: Color(0xFF44cc88), width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: Text('REST (+$heal HP)',
                style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 1, color: const Color(0xFF44cc88))),
          ),
        ),
      ],
    );
  }
}

// ── Room result ───────────────────────────────────────────────────────────────

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
        _HeroBar(run: run),
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
                        Text(isDead ? '💀 Fallen' : '✓ Victory',
                            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold,
                                color: isDead ? const Color(0xFFcc4444) : const Color(0xFF44cc88))),
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
                        if (!isDead) ...[
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
                              child: Text('🎁 ${game.dungeonLastDrop!.name} (${game.dungeonLastDrop!.rarityLabel}) → Bag',
                                  style: TextStyle(fontSize: 12, color: game.dungeonLastDrop!.rarityColor,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ] else if (room.type == DungeonRoomType.restSite) ...[
                        const Text('✓ Rested',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF44cc88))),
                        const SizedBox(height: 8),
                        _LootChip('❤ +${room.restoreHp} HP', const Color(0xFF44cc88)),
                      ] else if (room.type == DungeonRoomType.treasure) ...[
                        const Text('✓ Treasure collected',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF44cc88))),
                        const SizedBox(height: 8),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          _LootChip('💰 +${room.treasureGold}', AppTheme.accentGold),
                          const SizedBox(width: 10),
                          _LootChip('◆ +${room.treasureShards}', const Color(0xFF88aaff)),
                        ]),
                      ] else if (room.type == DungeonRoomType.shrine) ...[
                        const Text('✓ Blessing received',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF44cc88))),
                        if (run.blessings.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(run.blessings.last.label,
                                style: const TextStyle(fontSize: 14, color: Color(0xFF44cc88))),
                          ),
                      ] else if (room.type == DungeonRoomType.trap) ...[
                        Text(isDead ? '💀 Slain by the trap' : '✓ Trap survived',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold,
                                color: isDead ? const Color(0xFFcc4444) : const Color(0xFF44cc88))),
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text('−${room.trapDamage} HP',
                              style: const TextStyle(fontSize: 14, color: Color(0xFFcc8833))),
                        ),
                      ] else if (room.type == DungeonRoomType.lockedChest) ...[
                        const Text('✓ Chest opened',
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
                            child: Text('🎁 ${game.dungeonLastDrop!.name} (${game.dungeonLastDrop!.rarityLabel}) → Bag',
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

                const SizedBox(height: 20),
                if (!isDead)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF231F1B),
                        foregroundColor: const Color(0xFF44cc88),
                        side: const BorderSide(color: Color(0xFF44cc88), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: Text('NEXT FLOOR →',
                          style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 1, color: const Color(0xFF44cc88))),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A2623),
                        side: const BorderSide(color: AppTheme.cardBorder),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: Text('RETURN',
                          style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 1, color: AppTheme.textMuted)),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (!isDead)
          _ConsumableBar(run: run, onUse: (t) => game.useDungeonConsumable(t)),
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

// ── Summary ───────────────────────────────────────────────────────────────────

class _DungeonSummary extends StatelessWidget {
  const _DungeonSummary({required this.run, required this.game, required this.onExit});
  final DungeonRun run;
  final GameState game;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final isRecord = run.floor >= game.deepestDungeonFloor;
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
                color: run.isDead ? const Color(0xFFcc4444) : AppTheme.accentGold,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                Text(run.isDead ? '💀' : '🚪', style: const TextStyle(fontSize: 49)),
                const SizedBox(height: 8),
                Text(
                  run.isDead ? 'YOU HAVE FALLEN' : 'RUN ENDED',
                  style: AppTheme.pixelHeading(
                    fontSize: 15, letterSpacing: 2,
                    color: run.isDead ? const Color(0xFFcc4444) : AppTheme.textLight,
                  ),
                ),
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
                if (isRecord && run.floor > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withValues(alpha: 0.1),
                      border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('✨ New record!',
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onExit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A2623),
                side: const BorderSide(color: AppTheme.cardBorder),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: Text('RETURN TO HALL',
                  style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 1, color: AppTheme.textMuted)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () { onExit(); game.startDungeon(); },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2a1f00),
                foregroundColor: AppTheme.accentGold,
                side: const BorderSide(color: AppTheme.accentGold, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: Text('RUN AGAIN',
                  style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 1, color: AppTheme.accentGold)),
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
