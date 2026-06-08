import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/equipment.dart';
import '../services/game_state.dart';
import '../widgets/item_drop_badge.dart';
import '../screens/main_shell.dart';
import '../widgets/affix_chip_row.dart';
import '../widgets/attack_effect.dart';
import '../widgets/ability_bar.dart';
import '../widgets/battle_sprites.dart';
import '../widgets/buff_hud.dart';
import '../widgets/battle_backgrounds.dart';
import '../widgets/pixel_health_bar.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Floating damage number entry — one per attack hit
// ─────────────────────────────────────────────────────────────────────────────

class _FloatEntry {
  _FloatEntry({
    required this.ctrl,
    required this.text,
    required this.isCrit,
    required this.onEnemy, // true = hits over enemy, false = hits over hero
  });

  final AnimationController ctrl;
  final String text;
  final bool isCrit;
  final bool onEnemy;
}

// ─────────────────────────────────────────────────────────────────────────────
// Enemy death burst painter — 12 pixel fragments flying outward
// ─────────────────────────────────────────────────────────────────────────────

class _DeathBurstPainter extends CustomPainter {
  const _DeathBurstPainter(this.t, this.cx, this.cy);

  final double t;  // 0 → 1
  final double cx; // center x in arena coordinates
  final double cy; // center y in arena coordinates

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(1337);
    const count = 14;
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      final angle = rng.nextDouble() * pi * 2;
      final speed = 60 + rng.nextDouble() * 80;
      final startR = 8 + rng.nextDouble() * 12;
      final dist = startR + t * speed;
      final px = cx + cos(angle) * dist;
      final py = cy + sin(angle) * dist;
      final sz = (1 - t) * (4 + rng.nextDouble() * 6);
      final alpha = (1 - t * t).clamp(0.0, 1.0);
      final colors = [0xFFffcc44, 0xFFff8820, 0xFFee3030, 0xFFffffff, 0xFFdd60ff];
      paint.color = Color(colors[i % colors.length]).withValues(alpha: alpha);
      canvas.drawRect(Rect.fromCenter(center: Offset(px, py), width: sz, height: sz), paint);
    }

    // Central flash ring
    final ringAlpha = ((1 - t * 1.5).clamp(0.0, 1.0));
    if (ringAlpha > 0) {
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * (1 - t)
        ..color = const Color(0xFFffdd88).withValues(alpha: ringAlpha);
      canvas.drawCircle(Offset(cx, cy), 12 + t * 50, paint);
    }
  }

  @override
  bool shouldRepaint(_DeathBurstPainter old) => old.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// BattleScreen
// ─────────────────────────────────────────────────────────────────────────────

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen>
    with TickerProviderStateMixin {
  final _heroKey   = GlobalKey<BattleSpriteState>();
  final _enemyKey  = GlobalKey<BattleSpriteState>();
  final _effectKey = GlobalKey<AttackEffectState>();

  bool _busy = false;
  bool _autoRunning = false;
  bool _showingReward = false;
  int _rewardGold   = 0;
  int _rewardExp    = 0;
  int _rewardShards = 0;
  EquipmentItem? _rewardItem;

  // ── Animation controllers ────────────────────────────────────────────────
  late final AnimationController _shakeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );

  late final AnimationController _burstCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  final List<_FloatEntry> _floaters = [];

  // ── Arena size cache (set by LayoutBuilder) ───────────────────────────────
  Size _arenaSize = Size.zero;

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _burstCtrl.dispose();
    for (final f in _floaters) {
      f.ctrl.dispose();
    }
    super.dispose();
  }

  // ── Shake helpers ─────────────────────────────────────────────────────────

  void _triggerShake() {
    _shakeCtrl.forward(from: 0);
  }

  Offset _shakeOffset() {
    if (!_shakeCtrl.isAnimating && _shakeCtrl.value == 0) return Offset.zero;
    final v = _shakeCtrl.value;
    final intensity = (1 - v) * 7.0;
    return Offset(
      sin(v * pi * 7) * intensity,
      sin(v * pi * 5 + 1.2) * intensity * 0.6,
    );
  }

  // ── Floating damage helpers ───────────────────────────────────────────────

  void _spawnFloat(int damage, {required bool isCrit, required bool onEnemy}) {
    if (damage <= 0) return;
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    final entry = _FloatEntry(
      ctrl: ctrl,
      text: isCrit ? '$damage!' : '$damage',
      isCrit: isCrit,
      onEnemy: onEnemy,
    );
    setState(() => _floaters.add(entry));
    ctrl.forward().then((_) {
      if (mounted) setState(() { _floaters.remove(entry); entry.ctrl.dispose(); });
    });
  }

  // ── Death burst ───────────────────────────────────────────────────────────

  void _triggerDeathBurst() {
    _burstCtrl.forward(from: 0);
    _triggerShake();
  }

  // ── Auto attack loop ──────────────────────────────────────────────────────

  void _startAutoAttack(GameState game) async {
    if (_autoRunning) return;
    _autoRunning = true;

    while (mounted) {
      while (mounted && game.currentEnemy != null) {
        if (!_busy) await _doAttack(game);
        if (mounted && game.currentEnemy != null) {
          await Future.delayed(const Duration(milliseconds: 600));
        }
      }

      if (!mounted) break;

      if (game.heroDefeated) {
        game.heroDefeated = false;
        await _showDefeatDialog(game.hero.name);
        if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
        break;
      }

      if (mounted) {
        setState(() {
          _showingReward = true;
          _rewardGold    = game.lastRewardGold;
          _rewardExp     = game.lastRewardExp;
          _rewardShards  = game.lastShardDrop;
          _rewardItem    = game.lastItemDrop;
        });
      }
      await Future.delayed(Duration(seconds: game.lastItemDrop != null ? 3 : 2));
      if (!mounted) break;
      setState(() { _showingReward = false; _rewardItem = null; });

      game.startBattle();
    }

    _autoRunning = false;
  }

  Future<void> _showDefeatDialog(String heroName) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1a0a0a),
        title: Text('${heroName.toUpperCase()} FALLS',
            style: const TextStyle(color: Color(0xFFee4040), letterSpacing: 2)),
        content: const Text(
            'Your hero was defeated.\n\nVisit Upgrades to grow stronger before venturing forth again.',
            style: TextStyle(color: AppTheme.textLight)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('GO TO UPGRADES',
                style: TextStyle(color: AppTheme.accentGold)),
          )
        ],
      ),
    );
  }

  Future<void> _doAttack(GameState game) async {
    if (_busy || game.currentEnemy == null) return;
    if (mounted) setState(() => _busy = true);

    // ── Hero attacks ────────────────────────────────────────────────────────
    final enemyAliveBeforeHero = game.currentEnemy != null;
    game.heroAttack();
    _heroKey.currentState?.playAttack();
    _effectKey.currentState?.trigger(game.hero.heroClass);

    if (enemyAliveBeforeHero && game.lastHeroDamage > 0) {
      _spawnFloat(game.lastHeroDamage, isCrit: game.lastHeroCrit, onEnemy: true);
    }

    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _enemyKey.currentState?.playHit();

    // Check for death / boss enrage after hero hits
    if (mounted && game.currentEnemy == null) {
      // Enemy just died
      _triggerDeathBurst();
    } else if (mounted && game.isBossEnraged) {
      _triggerShake();
    }

    // ── Enemy counter-attacks ────────────────────────────────────────────────
    if (mounted && game.currentEnemy != null) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        game.enemyAttack();
        _enemyKey.currentState?.playAttack();
        await Future.delayed(const Duration(milliseconds: 200));
        if (mounted) {
          _heroKey.currentState?.playHit();
          if (game.lastEnemyDamage > 0) {
            _spawnFloat(game.lastEnemyDamage, isCrit: false, onEnemy: false);
          }
        }
      }
    }

    if (mounted) setState(() => _busy = false);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final enemy = game.currentEnemy;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(title: const Text('BATTLE')),
      body: Column(
        children: [
          TutorialTip(
            tutorialKey: 'battle',
            game: game,
            text: 'Tap ATTACK to roll a d20 — hit the enemy\'s AC to deal damage. '
                'Abilities fire automatically when ready.',
          ),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                enemy == null ? _buildNoBattle(context) : _buildArena(context, game, enemy),
                if (_showingReward) _buildRewardOverlay(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoBattle(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('NO ACTIVE BATTLE',
                style: TextStyle(fontSize: 18, color: AppTheme.accentGold, letterSpacing: 2)),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () => Navigator.pop(context), child: const Text('RETURN')),
          ],
        ),
      ),
    );
  }

  Widget _buildArena(BuildContext context, GameState game, enemy) {
    if (!_autoRunning) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_autoRunning) _startAutoAttack(game);
      });
    }
    return _buildArenaContent(context, game, enemy);
  }

  Widget _buildRewardOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.75),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
            decoration: BoxDecoration(
              color: const Color(0xFF1e1030),
              border: Border.all(color: AppTheme.accentGold, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('VICTORY!',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentGold,
                        letterSpacing: 4)),
                const SizedBox(height: 16),
                Text('+$_rewardGold GOLD',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFffd700),
                        letterSpacing: 2)),
                const SizedBox(height: 6),
                Text('+$_rewardExp XP',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4ad46a),
                        letterSpacing: 2)),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.diamond_outlined,
                        color: Color(0xFF80d0ff), size: 16),
                    const SizedBox(width: 6),
                    Text('+$_rewardShards SHARDS',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF80d0ff),
                            letterSpacing: 2)),
                  ],
                ),
                if (_rewardItem != null) ...[
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFF3a2a50), height: 1),
                  const SizedBox(height: 10),
                  ItemDropBadge(item: _rewardItem!),
                ],
                const SizedBox(height: 16),
                const Text('Advancing to next stage...',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                        letterSpacing: 1)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArenaContent(BuildContext context, GameState game, enemy) {
    if (enemy == null) return const SizedBox.shrink();
    return Column(
      children: [
        // ── ARENA ───────────────────────────────────────────────────────────
        Expanded(
          child: AnimatedBuilder(
            animation: Listenable.merge([_shakeCtrl, _burstCtrl]),
            builder: (_, child) {
              return Transform.translate(
                offset: _shakeOffset(),
                child: child,
              );
            },
            child: LayoutBuilder(
              builder: (_, constraints) {
                _arenaSize = Size(constraints.maxWidth, constraints.maxHeight);
                return Stack(
                  children: [
                    // Pixel art environment background
                    Positioned.fill(
                      child: CustomPaint(painter: battleBackgroundFor(enemy.id)),
                    ),
                    // Vignette
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 1.2,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.45),
                            ],
                          ),
                          border: const Border(
                            bottom: BorderSide(
                                color: AppTheme.pixelBorderBright, width: 2),
                          ),
                        ),
                      ),
                    ),
                    // Arena content
                    Column(
                      children: [
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF1e1030),
                            border: Border.fromBorderSide(
                              BorderSide(color: AppTheme.accentGold, width: 1),
                            ),
                          ),
                          child: Text(
                            '⚔  STAGE ${game.campaignStageIndex + 1}  ⚔',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.accentGold,
                                letterSpacing: 2),
                          ),
                        ),
                        if (game.isBossStage) ...[
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            color: game.isBossEnraged
                                ? const Color(0xFF5a0000)
                                : const Color(0xFF2a0040),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('☠',
                                    style: TextStyle(fontSize: 12)),
                                const SizedBox(width: 8),
                                Text(
                                  game.isBossEnraged
                                      ? 'BOSS ENRAGED!'
                                      : 'BOSS BATTLE',
                                  style: TextStyle(
                                    color: game.isBossEnraged
                                        ? const Color(0xFFff4444)
                                        : const Color(0xFFcc44ff),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('☠',
                                    style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                        if (game.activeAffixes.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: AffixChipRow(affixes: game.activeAffixes),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _CombatantPanel(
                                name: game.hero.name,
                                level: game.hero.level,
                                currentHp: game.hero.currentHealth,
                                maxHp: game.hero.maxHealth,
                                attack: game.hero.attack,
                                sprite: BattleSprite(
                                  key: _heroKey,
                                  spriteId: game.hero.spriteId,
                                  facingLeft: false,
                                  auraColor: game.heroAuraColor,
                                  auraIntensity: game.heroAuraIntensity,
                                  colorFilter: game.heroSkinFilter,
                                ),
                                nameColor: const Color(0xFF4ad46a),
                                alignRight: false,
                              ),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 32),
                                child: Text('VS',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.accentGold,
                                        letterSpacing: 2)),
                              ),
                              _CombatantPanel(
                                name: enemy.name,
                                level: enemy.level,
                                currentHp: enemy.currentHealth,
                                maxHp: enemy.maxHealth,
                                attack: enemy.attack,
                                sprite: BattleSprite(
                                  key: _enemyKey,
                                  spriteId: enemy.id,
                                  facingLeft: true,
                                  auraColor: BattleSprite.auraColorFor(
                                      game.activeAffixes),
                                ),
                                nameColor: const Color(0xFFee4040),
                                alignRight: true,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 4,
                          margin:
                              const EdgeInsets.symmetric(horizontal: 16),
                          color: AppTheme.pixelBorderBright,
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                    // Attack effect overlay
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AttackEffect(key: _effectKey),
                      ),
                    ),
                    // Death burst overlay
                    if (_burstCtrl.isAnimating || _burstCtrl.value > 0)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _DeathBurstPainter(
                              _burstCtrl.value,
                              _arenaSize.width * 0.72,
                              _arenaSize.height * 0.60,
                            ),
                          ),
                        ),
                      ),
                    // Floating damage numbers
                    ..._floaters.map((f) => _buildFloat(f)),
                  ],
                );
              },
            ),
          ),
        ),

        // ── BUFF HUD ──────────────────────────────────────────────────────
        const BuffHud(),

        // ── ABILITY BAR ───────────────────────────────────────────────────
        const AbilityBar(),

        // ── ACTION BUTTONS ────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          color: const Color(0xFF0e1228),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                    color: _busy
                        ? const Color(0xFF5a0000)
                        : const Color(0xFF8b0000),
                    border: Border.all(
                      color: _busy
                          ? const Color(0xFFff4040)
                          : const Color(0xFFcc2020),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_busy ? Icons.bolt : Icons.autorenew,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        _busy ? 'ATTACKING...' : '⚔ AUTO BATTLE',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    game.retreatBattle();
                    Navigator.pop(context);
                  },
                  child: const Text('RUN'),
                ),
              ),
            ],
          ),
        ),

        // ── BATTLE LOG ────────────────────────────────────────────────────
        Container(
          height: 130,
          decoration: const BoxDecoration(
            color: Color(0xFF0a0c18),
            border: Border(top: BorderSide(color: AppTheme.pixelBorder, width: 2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                color: const Color(0xFF141828),
                child: const Text('BATTLE LOG',
                    style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.accentGold,
                        letterSpacing: 2)),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  reverse: true,
                  children: game.battleLog.reversed
                      .take(8)
                      .map((e) => _LogLine(text: e))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Floating number widget ─────────────────────────────────────────────────

  Widget _buildFloat(_FloatEntry f) {
    return AnimatedBuilder(
      animation: f.ctrl,
      builder: (_, __) {
        final t = f.ctrl.value;
        final alpha = t < 0.7 ? 1.0 : (1 - (t - 0.7) / 0.3);
        final rise = t * 70.0;
        final cx = _arenaSize.width * (f.onEnemy ? 0.72 : 0.28);
        final cy = _arenaSize.height * 0.62 - rise;
        return Positioned(
          left: cx - (f.isCrit ? 36 : 24),
          top: cy - 16,
          child: IgnorePointer(
            child: Opacity(
              opacity: alpha.clamp(0.0, 1.0),
              child: Text(
                f.text,
                style: TextStyle(
                  fontSize: f.isCrit ? 26 : 18,
                  fontWeight: FontWeight.bold,
                  color: f.isCrit
                      ? const Color(0xFFffdd00)
                      : f.onEnemy
                          ? const Color(0xFFff6666)
                          : const Color(0xFF88ddff),
                  shadows: const [
                    Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1)),
                    Shadow(color: Colors.black, blurRadius: 4, offset: Offset(-1, -1)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CombatantPanel
// ─────────────────────────────────────────────────────────────────────────────

class _CombatantPanel extends StatelessWidget {
  const _CombatantPanel({
    required this.name,
    required this.level,
    required this.currentHp,
    required this.maxHp,
    required this.attack,
    required this.sprite,
    required this.nameColor,
    required this.alignRight,
  });

  final String name;
  final int level;
  final int currentHp;
  final int maxHp;
  final int attack;
  final Widget sprite;
  final Color nameColor;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment:
            alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            name.toUpperCase(),
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: nameColor,
                letterSpacing: 1),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text('LV.$level  ATK:$attack',
              style:
                  const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
          const SizedBox(height: 6),
          Center(child: sprite),
          const SizedBox(height: 8),
          PixelHealthBar(current: currentHp, max: maxHp, height: 12),
          const SizedBox(height: 3),
          Text('$currentHp / $maxHp',
              style:
                  const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LogLine
// ─────────────────────────────────────────────────────────────────────────────

class _LogLine extends StatelessWidget {
  const _LogLine({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('▸ ',
              style: TextStyle(color: AppTheme.accentGold, fontSize: 10)),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 10, color: AppTheme.textLight, height: 1.4)),
          ),
        ],
      ),
    );
  }
}



