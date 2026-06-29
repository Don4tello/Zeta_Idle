import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/routing/app_router.dart';
import '../data/enemy_data.dart';
import '../models/equipment.dart';
import '../services/game_state.dart';
import '../widgets/affix_chip_row.dart';
import '../widgets/battle_split_panel.dart';
import '../widgets/battle_arena.dart';
import '../widgets/battle_sprites.dart';
import '../widgets/item_drop_badge.dart';
import '../widgets/pet_battle_sprite.dart';
import '../theme/app_theme.dart';
import '../widgets/level_up_section.dart';
import '../utils/format_number.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen>
    with SingleTickerProviderStateMixin {
  final _arenaKey = GlobalKey<BattleArenaState>();

  bool _busy = false;
  bool _autoRunning = false;
  bool _showingReward = false;
  int _rewardGold    = 0;
  int _rewardExp     = 0;
  int _rewardShards  = 0;
  EquipmentItem? _rewardItem;
  LevelUpEvent?  _levelUpEvent;
  Completer<void>? _rewardCompleter;

  // Step 7 — victory stagger
  late final AnimationController _victoryCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));

  Animation<double> _victoryInterval(double begin, double end) =>
      CurvedAnimation(
          parent: _victoryCtrl,
          curve: Interval(begin, end, curve: Curves.easeOutBack));

  @override
  void dispose() {
    _victoryCtrl.dispose();
    super.dispose();
  }

  // ── Auto attack loop ──────────────────────────────────────────────────────

  void _startAutoAttack(GameState game) async {
    if (_autoRunning) return;
    _autoRunning = true;

    while (mounted) {
      while (mounted && game.currentEnemy != null) {
        if (!_busy) await _doAttack(game);
        if (mounted && game.currentEnemy != null) {
          await Future.delayed(
              Duration(milliseconds: game.scaledInterval(600)));
        }
      }

      if (!mounted) break;

      if (game.heroDefeated) {
        game.heroDefeated = false;
        await _showDefeatDialog(game);
        if (mounted) context.go(Routes.shell);
        break;
      }

      if (mounted) {
        _rewardCompleter = Completer<void>();
        setState(() {
          _showingReward  = true;
          _rewardGold     = game.lastRewardGold;
          _rewardExp      = game.lastRewardExp;
          _rewardShards   = game.lastShardDrop;
          _rewardItem     = game.lastItemDrop;
          _levelUpEvent   = game.lastLevelUp;
        });
        _victoryCtrl.forward(from: 0);
      }
      await Future.any([
        Future.delayed(const Duration(seconds: 2)),
        _rewardCompleter!.future,
      ]);
      _rewardCompleter = null;
      if (!mounted) break;
      setState(() { _showingReward = false; _rewardItem = null; });

      if (game.endlessTutorialPending && mounted) {
        await _showEndlessTutorial(game);
      }

      await _arenaKey.currentState?.fadeEnemyOut();
      game.startBattle();
      if (game.currentEnemy == null) {
        if (mounted) context.go(Routes.shell);
        break;
      }
    }

    _autoRunning = false;
  }

  Future<void> _showEndlessTutorial(GameState game) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.80),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0e1a10),
            border: Border.all(color: const Color(0xFF55ee88), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('♾️', style: TextStyle(fontSize: 38)),
              const SizedBox(height: 10),
              const Text(
                'TOWER ASCENSION UNLOCKED',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF55ee88),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'The Endless Arena is now open. Revisit defeated bosses and farm at your own pace.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppTheme.textLight, height: 1.5),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  border: Border.all(color: const Color(0xFF55ee88).withValues(alpha: 0.3)),
                ),
                child: const Text(
                  'Fight the current campaign enemy on repeat for gold and XP. Challenge defeated bosses for bigger rewards and item drops. Enemies scale with your power — never too easy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.6),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Find it under the MODES tab → ENDLESS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF55ee88),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    game.dismissEndlessTutorial();
                    Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF55ee88),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'GOT IT — KEEP FIGHTING',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDefeatDialog(GameState game) async {
    if (!mounted) return;
    final stage = game.campaignStageIndex;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1a0a0a),
            border: Border.all(color: const Color(0xFFee4040), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('☠', style: TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text('${game.hero.name.toUpperCase()} FALLS',
                  style: const TextStyle(
                    color: Color(0xFFee4040), fontSize: 16,
                    fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 12),
              const Text(
                  'Grow stronger before trying again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textLight, fontSize: 13)),
              const SizedBox(height: 16),
              if (stage >= 5)
                _defeatOption(dialogCtx, '♾️', 'ENDLESS MODE', 'Farm XP & gold at your pace',
                    const Color(0xFF55cc88), () { Navigator.of(dialogCtx).pop(); context.push(Routes.endless); }),
              if (stage >= 5)
                _defeatOption(dialogCtx, '🏰', 'DUNGEON', 'Earn shards & items',
                    const Color(0xFF66aaff), () { Navigator.of(dialogCtx).pop(); context.push(Routes.dungeon); }),
              if (stage >= 10)
                _defeatOption(dialogCtx, '⚔', 'GAUNTLET', 'Earn echoes for upgrades',
                    const Color(0xFFcc88ff), () { Navigator.of(dialogCtx).pop(); context.push(Routes.gauntlet); }),
              if (stage >= 5)
                _defeatOption(dialogCtx, '🎯', 'DAILY CHALLENGES', 'Claim rewards for progress',
                    const Color(0xFFffaa44), () { Navigator.of(dialogCtx).pop(); context.push(Routes.daily); }),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('BACK TO HERO',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _defeatOption(BuildContext dialogCtx, String emoji, String label,
      String desc, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(
                    color: color, fontSize: 12,
                    fontWeight: FontWeight.bold, letterSpacing: 1)),
                  Text(desc, style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 10)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 10, color: color.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }

  Future<void> _doAttack(GameState game) async {
    if (_busy || game.currentEnemy == null) return;
    if (mounted) setState(() => _busy = true);

    // ── Hero attacks ────────────────────────────────────────────────────────
    game.clearPendingFloats();
    game.heroAttack();
    await (_arenaKey.currentState?.playHeroAttack(
          game.lastHeroDamage,
          isCrit: game.lastHeroCrit,
          heroClass: game.hero.heroClass,
          damageType: game.lastHeroDamageType,
        ) ??
        Future.value());
    // Show ability/heal floats from this round
    for (final f in game.pendingFloats) {
      _arenaKey.currentState?.addExtraFloat(f.value, isHeal: f.isHeal, type: f.type);
    }

    // Check for death / boss enrage after hero hits
    if (mounted && game.currentEnemy == null) {
      _arenaKey.currentState?.playEnemyDeath();
    }

    // ── Enemy counter-attacks ────────────────────────────────────────────────
    if (mounted && game.currentEnemy != null) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        game.clearPendingFloats();
        game.enemyAttack();
        // Show DoT tick and aura heal floats
        for (final f in game.pendingFloats) {
          _arenaKey.currentState?.addExtraFloat(f.value, isHeal: f.isHeal, type: f.type);
        }
        await (_arenaKey.currentState?.playEnemyAttack(
              game.lastEnemyDamage,
              damageType: game.lastEnemyDamageType,
            ) ??
            Future.value());
      }
    }

    if (mounted) setState(() => _busy = false);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final game  = GameStateProvider.of(context);
    final enemy = game.currentEnemy;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: const Text('BATTLE'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            game.retreatBattle();
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              game.audioService.sfxMuted ? Icons.volume_off : Icons.volume_up,
              color: game.audioService.sfxMuted ? AppTheme.textMuted : AppTheme.accentGold,
              size: 20,
            ),
            onPressed: () {
              game.audioService.toggleMute();
              (context as Element).markNeedsBuild();
            },
          ),
          _SpeedButton(game: game),
          IconButton(
            icon: Icon(
              game.autoCampaign ? Icons.autorenew : Icons.autorenew,
              color: game.autoCampaign ? const Color(0xFF44cc88) : AppTheme.textMuted,
              size: 20,
            ),
            tooltip: game.autoCampaign ? 'Auto-Campaign: ON' : 'Auto-Campaign: OFF',
            onPressed: () {
              game.toggleAutoCampaign();
              (context as Element).markNeedsBuild();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                enemy == null
                    ? _buildNoBattle(context)
                    : _buildArena(context, game, enemy),
                if (_showingReward) _buildRewardOverlay(),
              ],
            ),
          ),
          if (enemy != null) const BattleIconBar(),
        ],
      ),
    );
  }

  Widget _buildNoBattle(BuildContext context) {
    return const Center(
      child: Text('NO ACTIVE BATTLE',
          style: TextStyle(fontSize: 19, color: AppTheme.accentGold, letterSpacing: 2)),
    );
  }

  static List<Color> _heroBuffGlows(GameState game) {
    final glows = <Color>[];
    if (game.buffAttackBonus > 0)  glows.add(const Color(0xFFffcc00)); // yellow — ATK
    if (game.buffAcBonus > 0)      glows.add(const Color(0xFF66aaff)); // blue  — AC
    if (game.dodgeNextHit)         glows.add(const Color(0xFF44ddcc)); // cyan  — dodge
    if (game.auraRoundsLeft > 0)   glows.add(const Color(0xFF55ee88)); // green — aura heal
    return glows;
  }

  static List<Color> _enemyDebuffGlows(GameState game) {
    final glows = <Color>[];
    if (game.dotRoundsLeft > 0)          glows.add(const Color(0xFF88dd00)); // lime   — DOT
    if (game.enemyStunRounds > 0)        glows.add(const Color(0xFFcc44ff)); // purple — stun
    if (game.enemyWeakenRounds > 0)      glows.add(const Color(0xFFff4488)); // pink   — weaken
    if (game.enemyVulnerableRounds > 0)  glows.add(const Color(0xFFff8800)); // orange — vulnerable
    return glows;
  }

  Widget _buildArena(BuildContext context, GameState game, enemy) {
    if (!_autoRunning) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_autoRunning) _startAutoAttack(game);
      });
    }
    return Column(
      children: [
        // ── ARENA ─────────────────────────────────────────────────────────
        Expanded(
          child: BattleArena(
            key: _arenaKey,
            heroName:         game.hero.name,
            heroLevel:        game.hero.level,
            heroCurrentHp:    game.hero.currentHealth,
            heroMaxHp:        game.hero.maxHealth,
            heroAttack:       game.hero.attack,
            heroSpriteId:     game.hero.spriteId,
            heroGender:       game.hero.gender,
            heroAuraColor:    game.heroAuraColor,
            heroAuraIntensity: game.heroAuraIntensity,
            heroColorFilter:  game.heroSkinFilter,
            heroPet: game.equippedPet != null
                ? PetBattleSprite(pet: game.equippedPet!, size: 28)
                : null,
            enemyName:    enemy.name,
            enemyLevel:   enemy.level,
            enemyCurrentHp: enemy.currentHealth,
            enemyMaxHp:   enemy.maxHealth,
            enemyAttack:  enemy.attack,
            enemyId:      enemy.id,
            stageIndex:   game.campaignStageIndex,
            headerLabel:  '⚔  STAGE ${game.campaignStageIndex + 1}  ⚔',
            isBoss:       game.isBossStage,
            isBossEnraged: game.isBossEnraged,
            affixWidget: game.activeAffixes.isNotEmpty
                ? AffixChipRow(affixes: game.activeAffixes)
                : null,
            enemyAuraColor: BattleSprite.auraColorFor(game.activeAffixes),
            heroDamageType: game.hero.activeDamageType,
            enemyAttackType: enemy.attackType,
            enemyResistances: enemy.resistances,
            heroBuffGlows: _heroBuffGlows(game),
            enemyDebuffGlows: _enemyDebuffGlows(game),
          ),
        ),

        // ── STAGE PROGRESS BAR + STREAK ───────────────────────────────────
        _StageProgressBar(
            stageIndex: game.campaignStageIndex,
            victoryStreak: game.victoryStreak),

        // ── STAGE PREVIEW STRIP ──────────────────────────────────────────
        _StagePreviewStrip(currentStage: game.campaignStageIndex),

        // ── PRESTIGE NUDGE ────────────────────────────────────────────────
        if (game.consecutiveLosses >= 3 && game.canPrestige)
          const _PrestigeNudge(),

      ],
    );
  }

  Widget _buildRewardOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => _rewardCompleter?.complete(),
        child: Container(
        color: Colors.black.withValues(alpha: 0.75),
        child: Center(
          child: AnimatedBuilder(
            animation: _victoryCtrl,
            builder: (_, __) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
                decoration: BoxDecoration(
                  color: const Color(0xFF241910),
                  border: Border.all(color: AppTheme.accentGold, width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _stagger(0.00, 0.22,
                      child: const Text('VICTORY!',
                          style: TextStyle(
                              fontSize: 27, fontWeight: FontWeight.bold,
                              color: AppTheme.accentGold, letterSpacing: 4))),
                    const SizedBox(height: 16),
                    _stagger(0.15, 0.40,
                      child: Text('+${fmtNum(_rewardGold)} GOLD',
                          style: const TextStyle(
                              fontSize: 21, fontWeight: FontWeight.bold,
                              color: Color(0xFFffd700), letterSpacing: 2))),
                    const SizedBox(height: 6),
                    _stagger(0.28, 0.53,
                      child: Text('+${fmtNum(_rewardExp)} XP',
                          style: const TextStyle(
                              fontSize: 21, fontWeight: FontWeight.bold,
                              color: Color(0xFF4ad46a), letterSpacing: 2))),
                    const SizedBox(height: 6),
                    _stagger(0.40, 0.65,
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.diamond_outlined,
                            color: Color(0xFF80d0ff), size: 16),
                        const SizedBox(width: 6),
                        if (_rewardShards > 0) Text(
                          '+$_rewardShards SHARDS',
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF80d0ff),
                              letterSpacing: 1)),
                      ])),
                    if (_levelUpEvent != null) ...[
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFF3a2a18), height: 1),
                      const SizedBox(height: 10),
                      _stagger(0.50, 0.75,
                        child: LevelUpSection(event: _levelUpEvent!)),
                    ],
                    if (_rewardItem != null) ...[
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFF3a2a50), height: 1),
                      const SizedBox(height: 10),
                      _stagger(0.55, 0.80, child: ItemDropBadge(item: _rewardItem!)),
                      const SizedBox(height: 6),
                      _stagger(0.60, 0.82,
                        child: const Text('→ Added to Bag',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFF88cc88),
                                letterSpacing: 1))),
                    ],
                    const SizedBox(height: 16),
                    _stagger(0.68, 0.90,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              _rewardCompleter?.complete();
                              if (mounted) Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppTheme.accentGold),
                              foregroundColor: AppTheme.accentGold,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                            ),
                            child: const Text('HERO',
                                style: TextStyle(fontSize: 12, letterSpacing: 1)),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () => _rewardCompleter?.complete(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentGold,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                            ),
                            child: const Text('CONTINUE',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1)),
                          ),
                        ],
                      )),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      ),
    );
  }

  /// Slides a child up and fades it in over [begin]→[end] of _victoryCtrl.
  Widget _stagger(double begin, double end, {required Widget child}) {
    final t = CurvedAnimation(
      parent: _victoryCtrl,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    ).value;
    return Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, (1 - t) * 18),
        child: child,
      ),
    );
  }
}

class _StageProgressBar extends StatelessWidget {
  const _StageProgressBar({required this.stageIndex, this.victoryStreak = 0});
  final int stageIndex;
  final int victoryStreak;

  @override
  Widget build(BuildContext context) {
    const total = 25;
    final progress = stageIndex % total;
    final fraction = progress / total;
    final streakPct = (victoryStreak.clamp(0, 25));
    return Container(
      color: const Color(0xFF0a0e1f),
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'PRESTIGE PROGRESS',
                style: TextStyle(
                  fontSize: 8,
                  color: AppTheme.textMuted.withValues(alpha: 0.7),
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              if (victoryStreak > 0) ...[
                Text(
                  '🔥 $victoryStreak STREAK  +$streakPct%',
                  style: TextStyle(
                    fontSize: 8,
                    color: streakPct >= 20
                        ? const Color(0xFFff6633)
                        : streakPct >= 10
                            ? const Color(0xFFffaa33)
                            : const Color(0xFF88cc44),
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                '$progress / $total',
                style: const TextStyle(
                  fontSize: 8,
                  color: AppTheme.accentGold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: fraction),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                minHeight: 5,
                backgroundColor: const Color(0xFF2a2318),
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= total - 1
                      ? const Color(0xFFFFE14D)
                      : AppTheme.accentGold.withValues(alpha: 0.75),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrestigeNudge extends StatelessWidget {
  const _PrestigeNudge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFcc8844).withValues(alpha: 0.12),
        border: Border(
          top: BorderSide(color: const Color(0xFFcc8844).withValues(alpha: 0.35)),
          bottom: BorderSide(color: const Color(0xFFcc8844).withValues(alpha: 0.35)),
        ),
      ),
      child: Row(
        children: [
          const Text('☠', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Struggling? Prestige is unlocked — reset for permanent power!',
              style: AppTheme.pixelHeading(
                fontSize: 10,
                letterSpacing: 0.5,
                color: const Color(0xFFcc8844),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Speed button ──────────────────────────────────────────────────────────────

class _SpeedButton extends StatelessWidget {
  const _SpeedButton({required this.game});
  final GameState game;

  static const _debugLabels = ['1×', '1.5×', '5×', '10×'];
  static const _prodLabels  = ['1×', '1.5×', '2×'];

  String get _label => kDebugMode
      ? _debugLabels[game.speedTier - 1]
      : _prodLabels[game.speedTier - 1];

  bool get _active => game.speedTier > 1;

  void _onTap(BuildContext context) {
    final maxTier = kDebugMode ? 4 : 3;
    final next = (game.speedTier % maxTier) + 1;

    if (!kDebugMode && next == 3 && !game.speedBoostActive) {
      _showPurchaseDialog(context);
      return;
    }
    game.setSpeedTier(next);
  }

  void _showPurchaseDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text('2× Speed Boost',
            style: TextStyle(color: Color(0xFFddbb44), fontWeight: FontWeight.bold)),
        content: Text(
          'Unlock 2× battle speed for 7 days?\n\nCost: ${GameState.kSpeedBoostCrystalCost} crystals\n'
          'Your crystals: ${game.crystals}',
          style: const TextStyle(color: Color(0xFFaabbcc)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF667799))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (game.purchaseSpeedBoost()) {
                game.setSpeedTier(3);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Not enough crystals!')),
                );
              }
            },
            child: const Text('Purchase', style: TextStyle(color: Color(0xFFddbb44))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => _onTap(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _active ? const Color(0xFF1a3a1a) : const Color(0xFF1a1a2a),
            border: Border.all(
              color: _active ? const Color(0xFF44cc44) : const Color(0xFF334466),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            _label,
            style: TextStyle(
              color: _active ? const Color(0xFF44cc44) : const Color(0xFF667799),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Stage Preview Strip ──────────────────────────────────────────────────────

class _StagePreviewStrip extends StatelessWidget {
  const _StagePreviewStrip({required this.currentStage});
  final int currentStage;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0a0e1f),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        children: [
          Text('NEXT ',
              style: AppTheme.pixelHeading(
                  fontSize: 7, letterSpacing: 1,
                  color: AppTheme.textMuted.withValues(alpha: 0.5))),
          const SizedBox(width: 4),
          for (int i = 1; i <= 5; i++) ...[
            if (i > 1) Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text('›',
                  style: TextStyle(fontSize: 8,
                      color: AppTheme.textMuted.withValues(alpha: 0.3))),
            ),
            _PreviewDot(stageIndex: currentStage + i),
          ],
        ],
      ),
    );
  }
}

class _PreviewDot extends StatelessWidget {
  const _PreviewDot({required this.stageIndex});
  final int stageIndex;

  @override
  Widget build(BuildContext context) {
    final enemy = EnemyData.enemyForStage(stageIndex);
    final isBoss = stageIndex % 5 == 4;
    final atkType = enemy.attackType;

    return Tooltip(
      message: '${enemy.name} (Lv.${enemy.level}) — ${atkType.label}',
      child: Container(
        width: isBoss ? 28 : 22,
        height: 22,
        decoration: BoxDecoration(
          color: isBoss
              ? const Color(0xFF2a0040)
              : const Color(0xFF151520),
          border: Border.all(
            color: isBoss
                ? const Color(0xFFcc44ff).withValues(alpha: 0.6)
                : atkType.color.withValues(alpha: 0.4),
            width: isBoss ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Center(
          child: Text(
            isBoss ? '☠' : atkType.emoji,
            style: TextStyle(fontSize: isBoss ? 11 : 9, color: atkType.color),
          ),
        ),
      ),
    );
  }
}

