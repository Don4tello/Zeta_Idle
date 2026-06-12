import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/routing/app_router.dart';
import '../models/equipment.dart';
import '../services/game_state.dart';
import '../widgets/affix_chip_row.dart';
import '../widgets/battle_arena.dart';
import '../widgets/battle_sprites.dart';
import '../widgets/item_drop_badge.dart';
import '../models/hero_ability.dart';
import '../widgets/pet_battle_sprite.dart';
import '../theme/app_theme.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  final _arenaKey = GlobalKey<BattleArenaState>();

  bool _busy = false;
  bool _autoRunning = false;
  bool _fastMode = false;
  bool _showingReward = false;
  int _rewardGold   = 0;
  int _rewardExp    = 0;
  int _rewardShards = 0;
  EquipmentItem? _rewardItem;
  Completer<void>? _rewardCompleter;

  // ── Auto attack loop ──────────────────────────────────────────────────────

  void _startAutoAttack(GameState game) async {
    if (_autoRunning) return;
    _autoRunning = true;

    while (mounted) {
      while (mounted && game.currentEnemy != null) {
        if (!_busy) await _doAttack(game);
        if (mounted && game.currentEnemy != null) {
          await Future.delayed(
              Duration(milliseconds: _fastMode ? 400 : 600));
        }
      }

      if (!mounted) break;

      if (game.heroDefeated) {
        game.heroDefeated = false;
        await _showDefeatDialog(game.hero.name);
        if (mounted) context.go(Routes.shell);
        break;
      }

      if (mounted) {
        _rewardCompleter = Completer<void>();
        setState(() {
          _showingReward = true;
          _rewardGold    = game.lastRewardGold;
          _rewardExp     = game.lastRewardExp;
          _rewardShards  = game.lastShardDrop;
          _rewardItem    = game.lastItemDrop;
        });
      }
      await Future.any([
        Future.delayed(const Duration(seconds: 5)),
        _rewardCompleter!.future,
      ]);
      _rewardCompleter = null;
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
          if (game.prestigeLevel > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _fastMode = !_fastMode),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _fastMode
                        ? const Color(0xFF1a3a1a)
                        : const Color(0xFF1a1a2a),
                    border: Border.all(
                      color: _fastMode
                          ? const Color(0xFF44cc44)
                          : const Color(0xFF334466),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    '1.5×',
                    style: TextStyle(
                      color: _fastMode
                          ? const Color(0xFF44cc44)
                          : const Color(0xFF667799),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
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

        // ── ABILITY PANEL (hero left / enemy right) ───────────────────────
        _buildSplitAbilityPanel(game),

        // ── BATTLE LOG ────────────────────────────────────────────────────
        BattleLogBox(log: game.battleLog),
      ],
    );
  }

  static const _effectColors = <AbilityEffect, Color>{
    AbilityEffect.bonusDamage:      Color(0xFFff6633),
    AbilityEffect.heal:             Color(0xFF44cc66),
    AbilityEffect.attackBonus:      Color(0xFFffcc00),
    AbilityEffect.acBonus:          Color(0xFF66aaff),
    AbilityEffect.stun:             Color(0xFFcc44ff),
    AbilityEffect.dot:              Color(0xFF88dd00),
    AbilityEffect.dodge:            Color(0xFF44ddcc),
    AbilityEffect.aura:             Color(0xFF55ee88),
    AbilityEffect.debuffWeaken:     Color(0xFFff4488),
    AbilityEffect.debuffVulnerable: Color(0xFFff8800),
  };
  static const _effectIcons = <AbilityEffect, IconData>{
    AbilityEffect.bonusDamage:      Icons.local_fire_department,
    AbilityEffect.heal:             Icons.favorite,
    AbilityEffect.attackBonus:      Icons.add_circle,
    AbilityEffect.acBonus:          Icons.shield,
    AbilityEffect.stun:             Icons.flash_on,
    AbilityEffect.dot:              Icons.bug_report,
    AbilityEffect.dodge:            Icons.directions_run,
    AbilityEffect.aura:             Icons.healing,
    AbilityEffect.debuffWeaken:     Icons.remove_circle,
    AbilityEffect.debuffVulnerable: Icons.broken_image,
  };

  Widget _buildSplitAbilityPanel(GameState game) {
    final abilities = game.unlockedAbilities;

    // ── Enemy debuff chips ────────────────────────────────────────────────
    final enemyChips = <Widget>[];
    void addEnemyChip(IconData icon, Color color, String label, int rounds) {
      enemyChips.add(Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            border: Border(
              bottom: BorderSide(color: color, width: 1.5),
              left:   BorderSide(color: color.withValues(alpha: 0.3), width: 1),
              right:  BorderSide(color: color.withValues(alpha: 0.3), width: 1),
              top:    BorderSide(color: color.withValues(alpha: 0.3), width: 1),
            ),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(color: color, fontSize: 12,
                    fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            Container(
              width: 16, height: 16,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text('$rounds',
                  style: TextStyle(color: color, fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
          ]),
        ),
      ));
    }

    // Hero buffs (shown status side)
    if (game.buffAttackBonus > 0) {
      addEnemyChip(Icons.add_circle, const Color(0xFFffcc00),
          '+${game.buffAttackBonus} ATK', game.buffAttackRounds);
    }
    if (game.buffAcBonus > 0) {
      addEnemyChip(Icons.shield, const Color(0xFF66aaff),
          '+${game.buffAcBonus} AC', game.buffAcRounds);
    }
    if (game.dodgeNextHit) {
      addEnemyChip(Icons.directions_run, const Color(0xFF44ddcc), 'DODGE', 1);
    }
    if (game.auraRoundsLeft > 0) {
      addEnemyChip(Icons.healing, const Color(0xFF55ee88),
          '+${game.auraHealPerRound} HP/r', game.auraRoundsLeft);
    }
    // Enemy debuffs
    if (game.dotRoundsLeft > 0) {
      addEnemyChip(Icons.bug_report, const Color(0xFF88dd00),
          '${game.dotDmg}/rnd', game.dotRoundsLeft);
    }
    if (game.enemyStunRounds > 0) {
      addEnemyChip(Icons.flash_on, const Color(0xFFcc44ff),
          'STUN', game.enemyStunRounds);
    }
    if (game.enemyWeakenRounds > 0) {
      addEnemyChip(Icons.remove_circle, const Color(0xFFff4488),
          '-${game.enemyWeakenPct}%ATK', game.enemyWeakenRounds);
    }
    if (game.enemyVulnerableRounds > 0) {
      addEnemyChip(Icons.broken_image, const Color(0xFFff8800),
          '+${game.enemyVulnerablePct}%DMG', game.enemyVulnerableRounds);
    }

    if (abilities.isEmpty && enemyChips.isEmpty) return const SizedBox.shrink();

    return Container(
      color: const Color(0xFF0a0e1f),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── LEFT: hero ability chips ────────────────────────────────
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('HERO',
                      style: TextStyle(color: Color(0xFF7799cc), fontSize: 11,
                          fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 4),
                  if (abilities.isEmpty)
                    const Text('No abilities unlocked',
                        style: TextStyle(color: Color(0xFF555577), fontSize: 11))
                  else
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: abilities.map((a) {
                        final cd    = game.cooldownRemaining(a.id);
                        final total = game.scaledAbilityCooldown(a);
                        final ready = cd == 0;
                        // Use elemental color for damage/dot abilities
                        final Color color;
                        if (a.effect == AbilityEffect.bonusDamage ||
                            a.effect == AbilityEffect.dot) {
                          color = game.abilityEffectiveDamageType(a).color;
                        } else {
                          color = _effectColors[a.effect] ?? Colors.grey;
                        }
                        final icon  = _effectIcons[a.effect] ?? Icons.star;
                        final progress = ready
                            ? 1.0
                            : ((total - cd) / total.clamp(1, 9999))
                                .clamp(0.0, 1.0);
                        return SizedBox(
                          width: 104,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: ready ? 0.15 : 0.07),
                              border: Border.all(
                                  color: color.withValues(alpha: ready ? 0.8 : 0.4),
                                  width: ready ? 1.5 : 1.0),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(children: [
                                  Icon(icon, color: color, size: 13),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(a.name,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  Text(ready ? 'RDY' : '${cd}r',
                                      style: TextStyle(
                                          color: color, fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ]),
                                const SizedBox(height: 3),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(1),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 3,
                                    backgroundColor:
                                        Colors.white.withValues(alpha: 0.1),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        color.withValues(alpha: 0.8)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            // ── Divider ─────────────────────────────────────────────────
            Container(
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: const Color(0xFF2a2a3a),
            ),
            // ── RIGHT: active buffs / enemy debuffs ──────────────────────
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('STATUS',
                      style: TextStyle(color: Color(0xFF7799cc), fontSize: 11,
                          fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 4),
                  if (enemyChips.isEmpty)
                    const Text('—',
                        style: TextStyle(color: Color(0xFF555577), fontSize: 12))
                  else
                    ...enemyChips,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardOverlay() {

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.75),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
            decoration: BoxDecoration(
              color: const Color(0xFF241910),
              border: Border.all(color: AppTheme.accentGold, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('VICTORY!',
                    style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentGold,
                        letterSpacing: 4)),
                const SizedBox(height: 16),
                Text('+$_rewardGold GOLD',
                    style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFffd700),
                        letterSpacing: 2)),
                const SizedBox(height: 6),
                Text('+$_rewardExp XP',
                    style: const TextStyle(
                        fontSize: 21,
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
                            fontSize: 17,
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
                  const SizedBox(height: 6),
                  const Text('→ Added to Bag',
                      style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF88cc88),
                          letterSpacing: 1)),
                ],
                const SizedBox(height: 16),
                Row(
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
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      child: const Text('HERO', style: TextStyle(fontSize: 12, letterSpacing: 1)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => _rewardCompleter?.complete(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGold,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      child: const Text('CONTINUE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

