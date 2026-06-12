import 'dart:math';
import 'package:flutter/material.dart';
import '../models/damage_type.dart';
import '../models/dnd_class.dart';
import '../theme/app_theme.dart';
import 'attack_effect.dart';
import 'battle_backgrounds.dart';
import 'battle_sprites.dart';
import 'pixel_health_bar.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BattleArena — reusable visual arena widget used by BattleScreen, Gauntlet,
// BossRush, and any other mode that wants the full sprite/animation treatment.
//
// Callers drive combat by calling BattleArenaState methods via GlobalKey:
//   playHeroAttack(damage, {isCrit, heroClass})
//   playEnemyAttack(damage)
//   playEnemyDeath()
//
// HP values and enemy data are props — parent calls setState to update them.
// ─────────────────────────────────────────────────────────────────────────────

class BattleArena extends StatefulWidget {
  const BattleArena({
    super.key,
    // Hero
    required this.heroName,
    required this.heroLevel,
    required this.heroCurrentHp,
    required this.heroMaxHp,
    required this.heroAttack,
    required this.heroSpriteId,
    this.heroAuraColor,
    this.heroAuraIntensity = 1.0,
    this.heroColorFilter,
    this.heroPet,
    // Enemy
    required this.enemyName,
    required this.enemyLevel,
    required this.enemyCurrentHp,
    required this.enemyMaxHp,
    required this.enemyAttack,
    required this.enemyId,
    // Context
    this.headerLabel,
    this.isBoss = false,
    this.isBossEnraged = false,
    this.affixWidget,
    this.enemyAuraColor,
    this.heroDamageType = DamageType.physical,
    this.enemyAttackType = DamageType.physical,
    this.enemyResistances = const {},
    this.heroBuffGlows = const [],
    this.enemyDebuffGlows = const [],
  });

  final String heroName, heroSpriteId;
  final int    heroLevel, heroCurrentHp, heroMaxHp, heroAttack;
  final Color?       heroAuraColor;
  final double       heroAuraIntensity;
  final ColorFilter? heroColorFilter;
  final Widget?      heroPet;

  final String enemyName, enemyId;
  final int    enemyLevel, enemyCurrentHp, enemyMaxHp, enemyAttack;

  final String? headerLabel;
  final bool    isBoss, isBossEnraged;
  final Widget? affixWidget;
  final Color?  enemyAuraColor;
  final DamageType heroDamageType;
  final DamageType enemyAttackType;
  final Map<DamageType, int> enemyResistances;
  final List<Color> heroBuffGlows;
  final List<Color> enemyDebuffGlows;

  @override
  State<BattleArena> createState() => BattleArenaState();
}

class BattleArenaState extends State<BattleArena> with TickerProviderStateMixin {
  final _heroKey   = GlobalKey<BattleSpriteState>();
  final _enemyKey  = GlobalKey<BattleSpriteState>();
  final _effectKey = GlobalKey<AttackEffectState>();

  late final AnimationController _shakeCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 280));
  late final AnimationController _burstCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 420));

  final List<_FloatEntry> _floaters = [];
  Size _arenaSize = Size.zero;

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _burstCtrl.dispose();
    for (final f in _floaters) f.ctrl.dispose();
    super.dispose();
  }

  // ── Public API ──────────────────────────────────────────────────────────────

  Future<void> playHeroAttack(int damage,
      {bool isCrit = false, DndClass? heroClass,
       DamageType damageType = DamageType.physical}) async {
    _heroKey.currentState?.playAttack();
    if (heroClass != null) _effectKey.currentState?.trigger(heroClass);
    _spawnFloat(damage, isCrit: isCrit, onEnemy: true, damageType: damageType);
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _enemyKey.currentState?.playHit();
  }

  void addExtraFloat(int value,
      {bool isHeal = false, DamageType type = DamageType.physical}) {
    if (isHeal) {
      final ctrl = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 900));
      final entry = _FloatEntry(
          ctrl: ctrl,
          text: '+$value',
          color: const Color(0xFF44ee88),
          isCrit: false,
          onEnemy: false);
      setState(() => _floaters.add(entry));
      ctrl.forward().then((_) {
        if (mounted) {
          setState(() { _floaters.remove(entry); entry.ctrl.dispose(); });
        }
      });
    } else {
      _spawnFloat(value, isCrit: false, onEnemy: true, damageType: type);
    }
  }

  Future<void> playEnemyAttack(int damage,
      {DamageType damageType = DamageType.physical}) async {
    _enemyKey.currentState?.playAttack();
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      _heroKey.currentState?.playHit();
      _spawnFloat(damage, isCrit: false, onEnemy: false, damageType: damageType);
    }
  }

  void playEnemyDeath() {
    _burstCtrl.forward(from: 0);
    _shakeCtrl.forward(from: 0);
  }

  // ── Internal ─────────────────────────────────────────────────────────────────

  void _spawnFloat(int damage,
      {required bool isCrit, required bool onEnemy,
       DamageType damageType = DamageType.physical}) {
    if (damage <= 0) return;
    final Color baseColor;
    if (isCrit) {
      baseColor = const Color(0xFFffdd00);
    } else if (damageType != DamageType.physical) {
      baseColor = damageType.color;
    } else {
      baseColor = onEnemy ? const Color(0xFFff6666) : const Color(0xFF88ddff);
    }
    final ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    final label = isCrit ? '$damage${damageType.shortTag}!' : '$damage${damageType.shortTag}';
    final entry = _FloatEntry(
        ctrl: ctrl,
        text: label,
        color: baseColor,
        isCrit: isCrit,
        onEnemy: onEnemy);
    setState(() => _floaters.add(entry));
    ctrl.forward().then((_) {
      if (mounted) {
        setState(() {
          _floaters.remove(entry);
          entry.ctrl.dispose();
        });
      }
    });
  }

  Offset _shakeOffset() {
    if (!_shakeCtrl.isAnimating && _shakeCtrl.value == 0) return Offset.zero;
    final v = _shakeCtrl.value;
    final intensity = (1 - v) * 7.0;
    return Offset(sin(v * pi * 7) * intensity,
        sin(v * pi * 5 + 1.2) * intensity * 0.6);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_shakeCtrl, _burstCtrl]),
      builder: (_, child) =>
          Transform.translate(offset: _shakeOffset(), child: child),
      child: LayoutBuilder(
        builder: (_, constraints) {
          _arenaSize = Size(constraints.maxWidth, constraints.maxHeight);
          return Stack(
            children: [
              // Background
              Positioned.fill(
                  child:
                      CustomPaint(painter: battleBackgroundFor(widget.enemyId))),
              // Vignette + border
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.45)
                      ],
                    ),
                    border: const Border(
                        bottom: BorderSide(
                            color: AppTheme.pixelBorderBright, width: 2)),
                  ),
                ),
              ),
              // Arena content
              Column(
                children: [
                  if (widget.headerLabel != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF241910),
                        border: Border.fromBorderSide(
                            BorderSide(color: AppTheme.accentGold, width: 1)),
                      ),
                      child: Text(widget.headerLabel!,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.accentGold,
                              letterSpacing: 2)),
                    ),
                  ],
                  if (widget.isBoss) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      color: widget.isBossEnraged
                          ? const Color(0xFF5a0000)
                          : const Color(0xFF2a0040),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('☠', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 8),
                          Text(
                            widget.isBossEnraged
                                ? 'BOSS ENRAGED!'
                                : 'BOSS BATTLE',
                            style: TextStyle(
                              color: widget.isBossEnraged
                                  ? const Color(0xFFff4444)
                                  : const Color(0xFFcc44ff),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('☠', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                  if (widget.affixWidget != null) ...[
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: widget.affixWidget!,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _CombatantPanel(
                          name: widget.heroName,
                          level: widget.heroLevel,
                          currentHp: widget.heroCurrentHp,
                          maxHp: widget.heroMaxHp,
                          attack: widget.heroAttack,
                          sprite: BattleSprite(
                            key: _heroKey,
                            spriteId: widget.heroSpriteId,
                            facingLeft: false,
                            auraColor: widget.heroAuraColor,
                            auraIntensity: widget.heroAuraIntensity,
                            colorFilter: widget.heroColorFilter,
                            buffGlows: widget.heroBuffGlows,
                          ),
                          petWidget: widget.heroPet,
                          nameColor: const Color(0xFF4ad46a),
                          alignRight: false,
                          damageType: widget.heroDamageType,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 32),
                          child: Text('VS',
                              style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentGold,
                                  letterSpacing: 2)),
                        ),
                        _CombatantPanel(
                          name: widget.enemyName,
                          level: widget.enemyLevel,
                          currentHp: widget.enemyCurrentHp,
                          maxHp: widget.enemyMaxHp,
                          attack: widget.enemyAttack,
                          sprite: BattleSprite(
                            key: _enemyKey,
                            spriteId: widget.enemyId,
                            facingLeft: true,
                            auraColor: widget.enemyAuraColor,
                            buffGlows: widget.enemyDebuffGlows,
                          ),
                          nameColor: const Color(0xFFee4040),
                          alignRight: true,
                          damageType: widget.enemyAttackType,
                          resistances: widget.enemyResistances,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: AppTheme.pixelBorderBright,
                  ),
                  const SizedBox(height: 4),
                ],
              ),
              // Attack effect overlay
              Positioned.fill(
                  child: IgnorePointer(
                      child: AttackEffect(key: _effectKey))),
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
              ..._floaters.map(_buildFloat),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFloat(_FloatEntry f) {
    return AnimatedBuilder(
      animation: f.ctrl,
      builder: (_, __) {
        final t     = f.ctrl.value;
        final alpha = t < 0.7 ? 1.0 : (1 - (t - 0.7) / 0.3);
        final rise  = t * 70.0;
        final cx    = _arenaSize.width * (f.onEnemy ? 0.72 : 0.28);
        final cy    = _arenaSize.height * 0.62 - rise;
        return Positioned(
          left: cx - (f.isCrit ? 36 : 24),
          top:  cy - 16,
          child: IgnorePointer(
            child: Opacity(
              opacity: alpha.clamp(0.0, 1.0),
              child: Text(
                f.text,
                style: TextStyle(
                  fontSize: f.isCrit ? 26 : 18,
                  fontWeight: FontWeight.bold,
                  color: f.color,
                  shadows: const [
                    Shadow(
                        color: Colors.black,
                        blurRadius: 4,
                        offset: Offset(1, 1)),
                    Shadow(
                        color: Colors.black,
                        blurRadius: 4,
                        offset: Offset(-1, -1)),
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
// BattleLogBox — reusable battle log used by BattleScreen, Gauntlet, BossRush
// ─────────────────────────────────────────────────────────────────────────────

class BattleLogBox extends StatelessWidget {
  const BattleLogBox({super.key, required this.log, this.height = 130});
  final List<String> log;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Color(0xFF17150E),
        border:
            Border(top: BorderSide(color: AppTheme.pixelBorder, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            color: const Color(0xFF211E1A),
            child: const Text('BATTLE LOG',
                style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.accentGold,
                    letterSpacing: 2)),
          ),
          Expanded(
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              reverse: true,
              children:
                  log.reversed.take(8).map((e) => _LogLine(text: e)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helpers
// ─────────────────────────────────────────────────────────────────────────────

class _FloatEntry {
  _FloatEntry({
    required this.ctrl,
    required this.text,
    required this.color,
    required this.isCrit,
    required this.onEnemy,
  });
  final AnimationController ctrl;
  final String text;
  final Color  color;
  final bool   isCrit, onEnemy;
}

class _DeathBurstPainter extends CustomPainter {
  const _DeathBurstPainter(this.t, this.cx, this.cy);
  final double t, cx, cy;

  @override
  void paint(Canvas canvas, Size size) {
    final rng   = Random(1337);
    const count = 14;
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      final angle  = rng.nextDouble() * pi * 2;
      final speed  = 60 + rng.nextDouble() * 80;
      final startR = 8 + rng.nextDouble() * 12;
      final dist   = startR + t * speed;
      final px     = cx + cos(angle) * dist;
      final py     = cy + sin(angle) * dist;
      final sz     = (1 - t) * (4 + rng.nextDouble() * 6);
      final alpha  = (1 - t * t).clamp(0.0, 1.0);
      const colors = [
        0xFFffcc44, 0xFFff8820, 0xFFee3030, 0xFFffffff, 0xFFdd60ff
      ];
      paint.color =
          Color(colors[i % colors.length]).withValues(alpha: alpha);
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset(px, py), width: sz, height: sz),
          paint);
    }
    final ringAlpha = (1 - t * 1.5).clamp(0.0, 1.0);
    if (ringAlpha > 0) {
      paint
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 3 * (1 - t)
        ..color       = const Color(0xFFffdd88).withValues(alpha: ringAlpha);
      canvas.drawCircle(Offset(cx, cy), 12 + t * 50, paint);
    }
  }

  @override
  bool shouldRepaint(_DeathBurstPainter old) => old.t != t;
}

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
    this.petWidget,
    this.damageType,
    this.resistances,
  });

  final String  name;
  final int     level, currentHp, maxHp, attack;
  final Widget  sprite;
  final Color   nameColor;
  final bool    alignRight;
  final Widget? petWidget;
  final DamageType?              damageType;
  final Map<DamageType, int>? resistances;

  @override
  Widget build(BuildContext context) {
    final spriteRow = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (petWidget != null) petWidget!,
        sprite,
      ],
    );

    // Resistance badges (only non-zero entries, sorted strongest first)
    final resList = (resistances?.entries.toList() ?? [])
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));
    final resBadges = resList.map((e) {
      final isVuln = e.value < 0;
      final color  = isVuln ? const Color(0xFFFF5555) : const Color(0xFF88AACC);
      final sign   = isVuln ? '' : '+';
      return Container(
        margin: const EdgeInsets.only(right: 3),
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 0.5),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          '${e.key.emoji}$sign${e.value}%',
          style: TextStyle(fontSize: 8, color: color, height: 1.1),
        ),
      );
    }).toList();

    return SizedBox(
      width: 140,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment:
            alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            name.toUpperCase(),
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: nameColor,
                letterSpacing: 1),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('LV.$level  ATK:$attack',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
              if (damageType != null) ...[
                const SizedBox(width: 5),
                Text(
                  damageType!.emoji,
                  style: TextStyle(fontSize: 12, color: damageType!.color),
                ),
              ],
            ],
          ),
          // Resistance/vulnerability row (shown for enemy panel)
          if (resBadges.isNotEmpty) ...[
            const SizedBox(height: 3),
            Wrap(
              spacing: 2, runSpacing: 2,
              children: resBadges,
            ),
          ],
          const SizedBox(height: 6),
          Center(child: spriteRow),
          const SizedBox(height: 8),
          PixelHealthBar(current: currentHp, max: maxHp, height: 12),
          const SizedBox(height: 3),
          Text('$currentHp / $maxHp',
              style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _LogLine extends StatelessWidget {
  const _LogLine({required this.text});
  final String text;

  static Color _colorFor(String t) {
    if (t.contains('CRITICAL HIT'))             return const Color(0xFFFFE14D);
    if (t.contains('LEGENDARY DROP'))           return const Color(0xFFdd66ff);
    if (t.contains('SET ITEM DROP'))            return const Color(0xFF44ccaa);
    if (t.contains('Item dropped'))             return const Color(0xFF80d0ff);
    if (t.contains('ENRAGES'))                  return const Color(0xFFee4444);
    if (t.contains('REBIRTH') || t.contains('ASCENSION')) return AppTheme.accentGold;
    if (t.contains('✦'))                        return AppTheme.accentGold;
    if (t.contains('🔥') || t.contains('(Fire)'))       return const Color(0xFFFF6B35);
    if (t.contains('❄') || t.contains('(Cold)'))        return const Color(0xFF6CB4E4);
    if (t.contains('⚡') || t.contains('(Lightning)'))  return const Color(0xFFFFE14D);
    if (t.contains('☠') || t.contains('(Poison)'))      return const Color(0xFF7DCF6A);
    if (t.contains('🌑') || t.contains('(Void)'))       return const Color(0xFF9966FF);
    if (t.contains('stunned'))                  return const Color(0xFFcc44ff);
    if (t.contains('weakened') || t.contains('ATK reduced')) return const Color(0xFFff4488);
    if (t.contains('vulnerable'))               return const Color(0xFFff8800);
    if (t.contains(' heals') || t.contains('regenerates') || t.contains('HP/round')) {
      return const Color(0xFF44cc66);
    }
    return AppTheme.textLight;
  }

  static bool _isBold(String t) =>
      t.contains('CRITICAL HIT') || t.contains('LEGENDARY') ||
      t.contains('SET ITEM') || t.contains('ENRAGES') ||
      t.contains('REBIRTH') || t.contains('ASCENSION');

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(text);
    final bold  = _isBold(text);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('▸ ',
              style: TextStyle(
                  color: bold ? color : AppTheme.accentGold, fontSize: 11)),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 13,
                    color: color,
                    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                    height: 1.4)),
          ),
        ],
      ),
    );
  }
}
