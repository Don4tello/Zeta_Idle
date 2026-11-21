import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode;
import '../models/damage_type.dart';
import '../models/enemy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:go_router/go_router.dart';
import '../core/routing/app_router.dart';
import '../screens/main_shell.dart';
import '../widgets/game_icons.dart';
import '../models/artifact.dart';
import '../models/equipment.dart';
import '../services/game_state.dart';
import '../widgets/battle_speed_menu.dart';
import '../widgets/affix_chip_row.dart';
import '../widgets/battle_split_panel.dart';
import '../widgets/battle_arena.dart';
import '../widgets/battle_sprites.dart';
import '../widgets/item_drop_badge.dart';
import '../widgets/pet_battle_sprite.dart';
import '../theme/app_theme.dart';
import '../widgets/currency_icon.dart';
import '../widgets/level_up_section.dart';
import '../data/ability_data.dart';
import '../widgets/arena_ability_effect.dart';
import '../widgets/fight_summary_sheet.dart';
import '../utils/format_number.dart';
import '../l10n/app_localizations.dart';
import '../l10n/content_l10n.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen>
    with SingleTickerProviderStateMixin {
  final _arenaKey  = GlobalKey<BattleArenaState>();
  final _effectKey = GlobalKey<ArenaAbilityEffectState>();

  bool _busy = false;
  bool _autoRunning = false;
  bool _isPaused = false;
  int? _countdown; // 3/2/1 shown before first attack; null = no countdown
  bool _showingReward = false;
  dynamic _lastEnemy;
  int _rewardGold    = 0;
  int _rewardExp     = 0;
  int _rewardShards  = 0;
  EquipmentItem? _rewardItem;
  LevelUpEvent?  _levelUpEvent;
  Artifact?      _rewardArtifact;
  Completer<void>? _rewardCompleter;
  bool _exitRequested = false;
  bool _poppedForTutorial = false; // popped this battle so the coach can show

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
    // Stop battle music when leaving the screen. Use getInheritedWidget (safe in
    // dispose, no dependency) + null-safe access — the provider may already be
    // gone during teardown, which previously crashed with a null-check error.
    final game = context.getInheritedWidgetOfExactType<GameStateProvider>()?.notifier;
    game?.audioService.endBattleMusic();
    // Hand auto-campaign back to the background sim now that the screen is gone.
    game?.battleScreenActive = false;
    super.dispose();
  }

  // -- Auto attack loop ------------------------------------------------------

  void _startAutoAttack(GameState game) async {
    if (_autoRunning) return;
    _autoRunning = true;

    while (mounted) {
      while (mounted && game.currentEnemy != null) {
        // Spin while paused or counting down
        while (mounted && (_isPaused || _countdown != null)) {
          await Future.delayed(const Duration(milliseconds: 60));
        }
        if (!mounted || game.currentEnemy == null) break;
        if (!_busy) await _doAttack(game);
        if (mounted && game.currentEnemy != null) {
          await Future.delayed(
              Duration(milliseconds: game.scaledInterval(600)));
        }
      }

      if (!mounted) break;

      if (game.heroDefeated) {
        // Keep heroDefeated true through the animation + dialog so the
        // background auto-campaign can't start a new fight over the corpse
        // (it fired ally abilities like Mira mid-death). startBattle()
        // resets the flag when a real new fight begins.
        await _arenaKey.currentState?.playHeroDeath();
        await Future.delayed(const Duration(milliseconds: 300));
        await _showDefeatDialog(game);
        game.heroDefeated = false;
        game.clearEventBossMode(); // lost the event boss → meter kept, no token
        game.clearGuildWarMode();  // lost a War Attack → charge still spent? no: not consumed
        MainShell.switchToTab(0);
        if (mounted) context.go(Routes.shell);
        break;
      }

      // Pause so the player can see the enemy at 0 HP before the victory screen.
      if (mounted) await Future.delayed(const Duration(seconds: 1));
      if (!mounted) break;

      if (mounted) {
        _rewardCompleter = Completer<void>();
        setState(() {
          _showingReward       = true;
          _rewardGold          = game.lastRewardGold;
          _rewardExp       = game.lastRewardExp;
          _rewardShards    = game.lastShardDrop;
          _rewardItem      = game.lastItemDrop;
          _levelUpEvent    = game.lastLevelUp;
          _rewardArtifact  = game.lastArtifactDrop;
          game.lastArtifactDrop = null;
        });
        _victoryCtrl.forward(from: 0);
        // Haptic: heavy for boss/level-up, medium for normal victory
        if (game.lastLevelUp != null || game.isBossStage) {
          game.haptic(HapticFeedback.heavyImpact);
        } else {
          game.haptic(HapticFeedback.mediumImpact);
        }
      }
      // Auto-campaign (default ON, toggleable via the AUTO button): show the
      // reward briefly then auto-continue to the next stage. If the player turned
      // it off, wait for them to tap CONTINUE instead.
      if (game.autoCampaign) {
        await Future.any([
          _rewardCompleter!.future,
          Future.delayed(Duration(milliseconds: game.scaledInterval(1300))),
        ]);
      } else {
        await _rewardCompleter?.future;
      }
      _rewardCompleter = null;
      if (!mounted || _exitRequested) break;

      // Event boss down: grant the Boss Token and return to Events.
      if (game.eventBossMode) {
        game.finishEventBossVictory();
        setState(() { _showingReward = false; _rewardItem = null; });
        if (mounted) Navigator.pop(context);
        break;
      }

      // Guild War attack won: add damage to the guild's score, return to Guild.
      if (game.warBattleMode) {
        game.finishGuildWarVictory();
        setState(() { _showingReward = false; _rewardItem = null; });
        if (mounted) Navigator.pop(context);
        break;
      }

      // Campaign replay: return to campaign map instead of looping
      if (game.isCampaignReplay) {
        game.isCampaignReplay = false;
        setState(() { _showingReward = false; _rewardItem = null; });
        if (mounted) Navigator.pop(context);
        break;
      }

      // Final campaign boss just fell — show Rebirth Unlocked and stop
      if (game.lastBattleWasFinalVictory) {
        game.lastBattleWasFinalVictory = false;
        setState(() { _showingReward = false; _rewardItem = null; });
        if (mounted) await _showRebirthUnlockedDialog();
        if (mounted) context.go(Routes.shell);
        break;
      }

      // First-victory intro modal removed — the guided tutorials cover onboarding.
      if (game.endlessTutorialPending) game.dismissEndlessTutorial();

      // Start next battle BEFORE hiding the overlay so there is no
      // gap where currentEnemy == null renders "NO ACTIVE BATTLE".
      await _arenaKey.currentState?.fadeEnemyOut();
      game.startBattle();
      if (!mounted) break;
      setState(() { _showingReward = false; _rewardItem = null; });
      await _runCountdown(game);

      if (game.currentEnemy == null) {
        if (mounted) context.go(Routes.shell);
        break;
      }
    }

    _autoRunning = false;
  }

  Future<void> _runCountdown(GameState game) async {
    for (int i = 3; i >= 1; i--) {
      if (!mounted) return;
      setState(() => _countdown = i);
      await Future.delayed(Duration(milliseconds: game.scaledInterval(1000)));
    }
    if (mounted) setState(() => _countdown = null);
  }


  Future<void> _showDefeatDialog(GameState game) async {
    if (!mounted) return;
    game.haptic(HapticFeedback.vibrate); // defeat rumble
    final stage = game.effectiveUnlockStage; // latches ≥100 post-rebirth so modes stay unlocked
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
              GameIcon(GameIconType.skull, size: 32, color: const Color(0xFFee4040)),
              const SizedBox(height: 8),
              Text(AppLocalizations.of(dialogCtx).heroFalls(game.hero.name.toUpperCase()),
                  style: const TextStyle(
                    color: Color(0xFFee4040), fontSize: 16,
                    fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 12),
              Text(
                  AppLocalizations.of(dialogCtx).battleGrowStronger,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textLight, fontSize: 13)),
              const SizedBox(height: 16),
              if (stage >= 5)
                _defeatOption(dialogCtx, GameIconType.swords, AppLocalizations.of(dialogCtx).defeatEndlessTitle, AppLocalizations.of(dialogCtx).defeatEndlessHint,
                    const Color(0xFF55cc88), () { Navigator.of(dialogCtx).pop(); context.push(Routes.endless); }),
              if (stage >= 5)
                _defeatOption(dialogCtx, GameIconType.key, AppLocalizations.of(dialogCtx).modeDungeon, AppLocalizations.of(dialogCtx).defeatDungeonHint,
                    const Color(0xFF66aaff), () { Navigator.of(dialogCtx).pop(); context.push(Routes.dungeon); }),
              if (stage >= 10)
                _defeatOption(dialogCtx, GameIconType.gauntlet, AppLocalizations.of(dialogCtx).modeGauntlet, AppLocalizations.of(dialogCtx).defeatGauntletHint,
                    const Color(0xFFcc88ff), () { Navigator.of(dialogCtx).pop(); context.push(Routes.gauntlet); }),
              if (stage >= 5)
                _defeatOption(dialogCtx, GameIconType.star, AppLocalizations.of(dialogCtx).defeatDailyTitle, AppLocalizations.of(dialogCtx).defeatDailyHint,
                    const Color(0xFFffaa44), () { Navigator.of(dialogCtx).pop(); context.push(Routes.daily); }),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: Text(AppLocalizations.of(dialogCtx).battleBackToHero,
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 12, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showRebirthUnlockedDialog() async {
    if (!mounted) return;
    final game = GameStateProvider.of(context);
    final tier = game.lastTierUnlocked; // 0 when already at max tier
    game.lastTierUnlocked = 0;
    final unlocked = tier > 0;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0d0a1a),
            border: Border.all(color: const Color(0xFFcc44ff), width: 2),
            boxShadow: [
              BoxShadow(color: const Color(0xFFcc44ff).withValues(alpha: 0.25),
                  blurRadius: 24, spreadRadius: 2),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✦', style: TextStyle(fontSize: 40, color: Color(0xFFcc44ff))),
              const SizedBox(height: 10),
              Text(unlocked ? AppLocalizations.of(dialogCtx).battleTierUnlocked(tier) : AppLocalizations.of(dialogCtx).battleCampaignCleared,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold,
                      color: Color(0xFFcc44ff), letterSpacing: 2.5)),
              const SizedBox(height: 14),
              Text(
                unlocked
                    ? AppLocalizations.of(dialogCtx).battleTierUnlockedBody(tier)
                    : AppLocalizations.of(dialogCtx).battleCampaignClearedBody,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textLight, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 6),
              Text(
                AppLocalizations.of(dialogCtx).battleSwitchTiersHint,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1a0a2a),
                    foregroundColor: const Color(0xFFcc44ff),
                    side: const BorderSide(color: Color(0xFFcc44ff)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(AppLocalizations.of(dialogCtx).commonContinue,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                          letterSpacing: 2)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _defeatOption(BuildContext dialogCtx, GameIconType icon, String label,
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
            GameIcon(icon, size: 18, color: color),
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

  // Plays any queued merc-ability call-outs (staggered), from either battle
  // start or an HP-triggered merc save.
  void _playMercFx(GameState game) {
    final fx = game.drainMercFx();
    for (var i = 0; i < fx.length; i++) {
      final e = fx[i];
      Future.delayed(Duration(milliseconds: i * 850), () {
        if (mounted) _arenaKey.currentState?.playMercAbility(e.name, e.icon, e.color);
      });
    }
  }

  Future<void> _doAttack(GameState game) async {
    if (_busy || game.currentEnemy == null) return;
    if (mounted) setState(() => _busy = true);

    // Show any merc abilities queued at battle start / from the last round.
    _playMercFx(game);

    // -- Hero attacks --------------------------------------------------------
    game.clearPendingFloats();
    game.heroAttack();
    if (game.lastHeroCrit) game.haptic(HapticFeedback.lightImpact);
    final firedAbility = game.lastAbilityFired;
    if (firedAbility != null) {
      _arenaKey.currentState?.playAbilityBanner(firedAbility.name, firedAbility.effect, id: firedAbility.id);
      _effectKey.currentState?.playEffect(firedAbility.id);
    } else {
      _effectKey.currentState?.playEffect(game.autoAttackEffectId);
    }
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

    // Check for death / boss enrage after hero hits. If the hero died in the
    // same beat (e.g. Volatile Death explosion), don't also play the enemy's
    // death — a defeated hero means the enemy stands.
    if (mounted && game.currentEnemy == null && !game.heroDefeated) {
      _arenaKey.currentState?.playEnemyDeath();
    }

    // -- Enemy counter-attacks ------------------------------------------------
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

  // -- Helpers ---------------------------------------------------------------

  // -- Build -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final game  = GameStateProvider.of(context);
    // A guided tutorial fired mid-battle. Its coach + navigation live in the
    // main shell, but this battle is a route pushed on top of it — so pop back
    // to reveal them. Auto-campaign is already paused by the tutorial; it (and
    // the battle) resume once the player taps "Got it".
    if (game.pendingTutorial != null) {
      if (!_poppedForTutorial) {
        _poppedForTutorial = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && Navigator.canPop(context)) Navigator.pop(context);
        });
      }
    } else {
      _poppedForTutorial = false;
    }
    final enemy = game.currentEnemy;
    if (enemy != null) _lastEnemy = enemy;
    final displayEnemy = enemy ?? _lastEnemy;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: AppLocalizations.of(context).battleRetreat,
          onPressed: () {
            game.retreatBattle();
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.assessment_outlined,
              color: game.lastFightSummary != null
                  ? AppTheme.accentGold : AppTheme.textMuted,
              size: 21,
            ),
            tooltip: AppLocalizations.of(context).battleLastFightSummary,
            onPressed: () {
              final s = game.lastFightSummary;
              if (s == null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(AppLocalizations.of(context).battleNoFightYet),
                  behavior: SnackBarBehavior.floating,
                ));
                return;
              }
              showFightSummary(context, s);
            },
          ),
          IconButton(
            icon: Icon(
              _isPaused ? Icons.play_arrow : Icons.pause,
              color: _isPaused ? AppTheme.accentGold : AppTheme.textMuted,
              size: 22,
            ),
            tooltip: _isPaused ? AppLocalizations.of(context).battleResume : AppLocalizations.of(context).battlePause,
            onPressed: () => setState(() => _isPaused = !_isPaused),
          ),
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
          // Auto-campaign toggle — default ON, but players can turn it off to
          // play manually. Campaign auto is a free default feature, so no gate.
          IconButton(
            icon: Icon(Icons.autorenew, size: 20,
                color: game.autoCampaign ? const Color(0xFF44cc88) : AppTheme.textMuted),
            tooltip: game.autoCampaign
                ? AppLocalizations.of(context).battleAutoCampaignOn
                : AppLocalizations.of(context).battleAutoCampaignOff,
            onPressed: () {
              game.toggleCampaignAuto();
              game.audioService.playUiClick();
              (context as Element).markNeedsBuild();
            },
          ),
          _SpeedButton(game: game),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                displayEnemy == null
                    ? _buildNoBattle(context)
                    : _buildArena(context, game, displayEnemy),
                if (_showingReward) _buildRewardOverlay(),
                if (_countdown != null) _buildCountdownOverlay(_countdown!),
              ],
            ),
          ),
          const SafeArea(top: false, child: BattleIconBar()),
        ],
      ),
    );
  }

  Widget _buildCountdownOverlay(int count) {
    return IgnorePointer(
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: FadeTransition(opacity: anim, child: child)),
          child: Text(
            '$count',
            key: ValueKey(count),
            style: const TextStyle(
              fontSize: 96,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(color: Color(0xFFcc2200), blurRadius: 32, offset: Offset(0, 0)),
                Shadow(color: Color(0xFFcc2200), blurRadius: 16, offset: Offset(0, 0)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoBattle(BuildContext context) {
    return Center(
      child: Text(AppLocalizations.of(context).battleNoActiveBattle,
          style: const TextStyle(fontSize: 19, color: AppTheme.accentGold, letterSpacing: 2)),
    );
  }

  /// A subtle element-colour wash so enemies reusing the same base sprite still
  /// read as distinct creatures (e.g. an ice-wraith vs a void-wraith). Keyed off
  /// the strongest NON-physical resistance (the enemy's element); base archetypes
  /// with no elemental theme stay untinted.
  static ColorFilter? _enemyElementTint(Enemy e) {
    DamageType? best;
    int bestV = 0;
    for (final entry in e.resistances.entries) {
      if (entry.key != DamageType.physical && entry.value > bestV) {
        bestV = entry.value;
        best = entry.key;
      }
    }
    if (best == null || bestV < 25) return null;
    return ColorFilter.mode(best.color.withValues(alpha: 0.33), BlendMode.srcATop);
  }

  static List<Color> _heroBuffGlows(GameState game) {
    final glows = <Color>[];
    if (game.heroAbsorbShield > 0) glows.add(const Color(0xFF88ccff)); // sky   — absorb shield
    if (game.buffAttackBonus > 0)  glows.add(const Color(0xFFffcc00)); // yellow— ATK
    if (game.buffAcBonus > 0)      glows.add(const Color(0xFF66aaff)); // blue  — AC
    if (game.dodgeNextHit)         glows.add(const Color(0xFF44ddcc)); // cyan  — dodge
    if (game.auraRoundsLeft > 0)   glows.add(const Color(0xFF55ee88)); // green — aura heal
    return glows;
  }

  static List<Color> _enemyDebuffGlows(GameState game) {
    final glows = <Color>[];
    if (game.dotRoundsLeft > 0)          glows.add(const Color(0xFF88dd00)); // lime   — DOT
    if (game.enemyStunRounds > 0)          glows.add(const Color(0xFFcc44ff)); // purple — stun
    if (game.stunApplicationCount >= 2)   glows.add(const Color(0xFF665577)); // dim purple — DR immune— stun
    if (game.enemySilenceRounds > 0)       glows.add(const Color(0xFFffdd00)); // gold   — silence
    if (game.enemyMissChanceRounds > 0)   glows.add(const Color(0xFFaaaaff)); // lavender — miss
    if (game.enemyWeakenRounds > 0)       glows.add(const Color(0xFFff4488)); // pink— weaken
    if (game.enemyVulnerableRounds > 0)  glows.add(const Color(0xFFff8800)); // orange — vulnerable
    return glows;
  }

  // ── Status-effect helpers ──────────────────────────────────────────────

  static List<_StatusInfo> _heroStatuses(GameState game) {
    final list = <_StatusInfo>[];
    if (game.heroAbsorbShield > 0) {
      list.add(_StatusInfo('SHD', 'Absorb Shield',
          'Barrier absorbs ${game.heroAbsorbShield} HP of incoming damage.',
          -1, const Color(0xFF88ccff)));
    }
    if (game.buffAttackBonus > 0) {
      list.add(_StatusInfo('DMG+', 'Damage Buff',
          'Damage increased by ${game.buffAttackBonus}%.',
          game.buffAttackRounds, const Color(0xFFffcc00)));
    }
    if (game.buffAcBonus > 0) {
      list.add(_StatusInfo('AC+', 'Armor Class',
          'Armor Class rating increased by ${game.buffAcBonus}%.',
          game.buffAcRounds, const Color(0xFF66aaff)));
    }
    if (game.dodgeNextHit) {
      list.add(_StatusInfo('DGE', 'Dodge',
          'Will dodge the next incoming attack.', -1, const Color(0xFF44ddcc)));
    }
    if (game.auraRoundsLeft > 0) {
      list.add(_StatusInfo('AUR', 'Aura',
          'Healing aura restores ${game.auraHealPerRound} HP/r.',
          game.auraRoundsLeft, const Color(0xFF55ee88)));
    }
    if (game.heroStunRounds > 0) {
      list.add(_StatusInfo('STN', 'Stunned',
          'Stunned — cannot act for ${game.heroStunRounds} round(s).',
          game.heroStunRounds, const Color(0xFFcc44ff)));
    }
    if (game.heroDotRoundsLeft > 0) {
      list.add(_StatusInfo('DOT', 'Burning / Poison',
          'Taking ${game.heroDotDmgPerRound} damage/round for ${game.heroDotRoundsLeft} more round(s).',
          game.heroDotRoundsLeft, const Color(0xFFff4400)));
    }
    return list;
  }

  static List<_StatusInfo> _enemyStatuses(GameState game) {
    final list = <_StatusInfo>[];
    if (game.enemyStunRounds > 0) {
      list.add(_StatusInfo('STN', 'Stunned',
          'Enemy is stunned — cannot act for ${game.enemyStunRounds} round(s).',
          game.enemyStunRounds, const Color(0xFFcc44ff)));
    }
    if (game.stunApplicationCount >= 2) {
      list.add(_StatusInfo('DR', 'Stun Resistance',
          'Enemy has built up stun resistance. Next stun will be resisted (resets after 5 rounds without a stun).',
          -1, const Color(0xFF665577)));
    }
    if (game.dotRoundsLeft > 0) {
      list.add(_StatusInfo('DOT', 'Damage Over Time',
          'Enemy takes ${game.dotDmg} periodic damage/round for ${game.dotRoundsLeft} more round(s).',
          game.dotRoundsLeft, const Color(0xFF88dd00)));
    }
    if (game.enemySilenceRounds > 0) {
      list.add(_StatusInfo('SIL', 'Silenced',
          'Enemy cannot use abilities for ${game.enemySilenceRounds} round(s).',
          game.enemySilenceRounds, const Color(0xFFffdd00)));
    }
    if (game.enemyMissChanceRounds > 0) {
      list.add(_StatusInfo('MSS', 'Miss Chance',
          'Enemy has ${game.enemyMissChancePct}% chance to miss each attack for ${game.enemyMissChanceRounds} more round(s).',
          game.enemyMissChanceRounds, const Color(0xFFaaaaff)));
    }
    if (game.enemyWeakenRounds > 0) {
      list.add(_StatusInfo('WKN', 'Weakened',
          'Enemy ATK reduced by ${game.enemyWeakenPct}% for ${game.enemyWeakenRounds} more round(s).',
          game.enemyWeakenRounds, const Color(0xFFff4488)));
    }
    if (game.enemyVulnerableRounds > 0) {
      list.add(_StatusInfo('VLN', 'Vulnerable',
          'Enemy takes ${game.enemyVulnerablePct}% more damage for ${game.enemyVulnerableRounds} more round(s).',
          game.enemyVulnerableRounds, const Color(0xFFff8800)));
    }
    return list;
  }

  Widget _buildStatusBars(BuildContext context, GameState game) {
    final hero   = _heroStatuses(game);
    final enemy  = _enemyStatuses(game);
    // Always occupy a fixed height so the arena never resizes when
    // buffs/debuffs appear or disappear.
    return SizedBox(
      height: 50,
      child: (hero.isEmpty && enemy.isEmpty) ? null : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (enemy.isNotEmpty) ...[
              _StatusBadgeRow(rowLabel: 'ENEMY', statuses: enemy),
              const SizedBox(height: 3),
            ],
            if (hero.isNotEmpty)
              _StatusBadgeRow(rowLabel: 'HERO', statuses: hero),
          ],
        ),
      ),
    );
  }

  Widget _buildArena(BuildContext context, GameState game, enemy) {
    // Tell the background auto-campaign sim to stand down — this screen runs the
    // fight visibly. Cleared in dispose().
    game.battleScreenActive = true;
    if (!_autoRunning) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_autoRunning) _startAutoAttack(game);
      });
    }
    return Column(
      children: [
        // -- ARENA ---------------------------------------------------------
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
          BattleArena(
            key: _arenaKey,
            heroName:         game.hero.name,
            heroLevel:        game.hero.level,
            heroCurrentHp:    game.heroDefeated ? 0 : game.hero.currentHealth,
            heroMaxHp:        game.hero.maxHealth,
            heroAttack:       game.avgHeroHit,
            heroSpriteId:     game.heroBattleSpriteId,
            heroGender:       game.hero.gender,
            heroRace:         game.heroRace,
            heroAuraColor:    game.heroAuraColor,
            heroAuraIntensity: game.heroAuraIntensity,
            heroColorFilter:  game.heroSpriteFilter,
            heroPet: game.equippedPet != null
                ? PetBattleSprite(pet: game.equippedPet!)
                : null,
            enemyName:    ContentL10n.of(context).tr(enemy.id, 'title', enemy.name),
            enemyLevel:   enemy.level,
            enemyCurrentHp: enemy.currentHealth,
            enemyMaxHp:   enemy.maxHealth,
            enemyAttack:  enemy.attack,
            enemyId:      enemy.id,
            stageIndex:   game.isCampaignReplay ? game.replayStageIndex : game.campaignStageIndex,
            headerLabel:  game.isCampaignReplay
                ? 'STAGE ${game.replayStageIndex + 1}  (REPLAY)'
                : game.campaignStageLabel,
            isBoss:       game.isBossStage,
            isBossEnraged: game.isBossEnraged,
            affixWidget: game.activeAffixes.isNotEmpty
                ? AffixChipRow(affixes: game.activeAffixes)
                : null,
            enemyAuraColor: BattleSprite.auraColorFor(game.activeAffixes),
            heroDamageType: game.hero.activeDamageType,
            enemyAttackType: enemy.attackType,
            enemyAbilityTypes: <DamageType>{
              for (final a in enemy.abilities)
                if (a.damageType != DamageType.physical) a.damageType,
            }.toList(),
            enemyResistances: enemy.resistances,
            enemyColorFilter: _enemyElementTint(enemy),
            heroBuffGlows: _heroBuffGlows(game),
            enemyDebuffGlows: _enemyDebuffGlows(game),
            heroCritPct: game.totalCritChancePct,
            heroArmor: game.heroArmorValue,
          ),
          ArenaAbilityEffect(key: _effectKey),
        ]),
        ),

        // -- STATUS EFFECT BARS --------------------------------------------
        _buildStatusBars(context, game),

        // -- PRESTIGE NUDGE ------------------------------------------------
        if (game.consecutiveLosses >= 3 && game.canPrestige)
          const _PrestigeNudge(),

      ],
    );
  }

  Widget _buildRewardOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          if (_victoryCtrl.isCompleted) _rewardCompleter?.complete();
        },
        child: Container(
        color: Colors.black.withValues(alpha: 0.75),
        child: Center(
          child: AnimatedBuilder(
            animation: _victoryCtrl,
            builder: (ctx, __) {
              final maxH = MediaQuery.of(ctx).size.height * 0.88;
              return ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxH),
                child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
                decoration: BoxDecoration(
                  color: const Color(0xFF241910),
                  border: Border.all(color: AppTheme.accentGold, width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Scrollable reward content ─────────────────────────────
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _stagger(0.00, 0.22,
                              child: Text(AppLocalizations.of(ctx).battleVictory,
                                  style: const TextStyle(
                                      fontSize: 27, fontWeight: FontWeight.bold,
                                      color: AppTheme.accentGold, letterSpacing: 4))),
                            // Boss defeat lore — first kill only
                            Builder(builder: (ctx) {
                              final gs = GameStateProvider.of(ctx);
                              final msg = gs.pendingBossDefeatMessage;
                              if (msg == null) return const SizedBox.shrink();
                              return _stagger(0.05, 0.28, child: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1a0a00),
                                    border: Border.all(color: const Color(0xFFcc8844).withValues(alpha: 0.5)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(AppLocalizations.of(ctx).battleBossDefeated,
                                        style: const TextStyle(fontSize: 8, color: Color(0xFFcc8844),
                                            fontWeight: FontWeight.bold, letterSpacing: 2)),
                                    const SizedBox(height: 5),
                                    Text(msg,
                                        style: const TextStyle(fontSize: 11, color: AppTheme.textLight,
                                            height: 1.6, fontStyle: FontStyle.italic),
                                        textAlign: TextAlign.left),
                                  ]),
                                ),
                              ));
                            }),
                            // Unlock notice — new content area discovered
                            Builder(builder: (ctx) {
                              final gs = GameStateProvider.of(ctx);
                              final notice = gs.pendingUnlockNotice;
                              if (notice == null) return const SizedBox.shrink();
                              return _stagger(0.05, 0.28, child: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0a1a0a),
                                    border: Border.all(color: const Color(0xFF44cc44).withValues(alpha: 0.6)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(AppLocalizations.of(ctx).battleNewContentUnlocked,
                                        style: const TextStyle(fontSize: 8, color: Color(0xFF44cc44),
                                            fontWeight: FontWeight.bold, letterSpacing: 2)),
                                    const SizedBox(height: 5),
                                    Text('⚔  $notice',
                                        style: const TextStyle(fontSize: 13, color: AppTheme.textLight,
                                            height: 1.5, fontWeight: FontWeight.bold)),
                                  ]),
                                ),
                              ));
                            }),
                            Builder(builder: (ctx) {
                              final gs = GameStateProvider.of(ctx);
                              if (!gs.pendingClassQuestlineUnlock) return const SizedBox.shrink();
                              final cls = gs.hero.heroClass;
                              return _stagger(0.05, 0.30, child: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1a1000),
                                    border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.7)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(children: [
                                    Icon(cls.info.icon, color: AppTheme.accentGold, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(AppLocalizations.of(ctx).battleClassQuestlineUnlocked,
                                          style: const TextStyle(fontSize: 8, color: AppTheme.accentGold,
                                              fontWeight: FontWeight.bold, letterSpacing: 2)),
                                      const SizedBox(height: 4),
                                      Text(AppLocalizations.of(ctx).battleClassQuestlineBody(cls.displayName),
                                          style: const TextStyle(fontSize: 11, color: AppTheme.textLight, height: 1.4)),
                                    ])),
                                  ]),
                                ),
                              ));
                            }),
                            const SizedBox(height: 16),
                            _stagger(0.15, 0.40,
                              child: Text(AppLocalizations.of(ctx).battleRewardGold(fmtNum(_rewardGold)),
                                  style: const TextStyle(
                                      fontSize: 21, fontWeight: FontWeight.bold,
                                      color: Color(0xFFffd700), letterSpacing: 2))),
                            const SizedBox(height: 6),
                            _stagger(0.28, 0.53,
                              child: Row(mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center, children: [
                                const CurrencyIcon(id: 'xp', size: 22),
                                const SizedBox(width: 8),
                                Text(AppLocalizations.of(ctx).battleRewardXp(fmtNum(_rewardExp)),
                                    style: const TextStyle(
                                        fontSize: 21, fontWeight: FontWeight.bold,
                                        color: Color(0xFF4ad46a), letterSpacing: 2)),
                              ])),
                            const SizedBox(height: 6),
                            _stagger(0.40, 0.65,
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                const CurrencyIcon(id: 'shards', size: 16),
                                const SizedBox(width: 6),
                                if (_rewardShards > 0) Text(
                                  AppLocalizations.of(ctx).battleRewardShards('$_rewardShards'),
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6699ff),
                                      letterSpacing: 1)),
                              ])),
                            if (_levelUpEvent != null) ...[
                              const SizedBox(height: 12),
                              const Divider(color: Color(0xFF3a2a18), height: 1),
                              const SizedBox(height: 10),
                              _stagger(0.50, 0.75,
                                child: LevelUpSection(event: _levelUpEvent!)),
                              Builder(builder: (ctx) {
                                final gs = GameStateProvider.of(ctx);
                                final event = _levelUpEvent!;
                                final oldIds = AbilityData
                                    .unlockedFor(gs.hero.heroClass, event.fromLevel,
                                        ultUnlocked: gs.classUltimateUnlocked)
                                    .map((a) => a.id)
                                    .toSet();
                                final newAbilities = AbilityData
                                    .unlockedFor(gs.hero.heroClass, event.toLevel,
                                        ultUnlocked: gs.classUltimateUnlocked)
                                    .where((a) => !oldIds.contains(a.id))
                                    .toList();
                                if (newAbilities.isEmpty) return const SizedBox.shrink();
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: newAbilities.map((ability) =>
                                    _stagger(0.55, 0.78, child: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1a1a0e),
                                          border: Border.all(
                                              color: const Color(0xFFffcc44).withValues(alpha: 0.6)),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            GameIcon(GameIconType.starburst, size: 14, color: const Color(0xFFffcc44)),
                                            const SizedBox(width: 8),
                                            Expanded(child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  AppLocalizations.of(ctx).battleAbilityUnlocked(
                                                      ContentL10n.of(ctx).tr(ability.id, 'title', ability.name)),
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFFffcc44),
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  ContentL10n.of(ctx).tr(ability.id, 'desc', ability.description),
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Color(0xFFffeeaa),
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ],
                                            )),
                                          ],
                                        ),
                                      ),
                                    )),
                                  ).toList(),
                                );
                              }),
                            ],
                            if (_rewardItem != null) ...[
                              const SizedBox(height: 12),
                              const Divider(color: Color(0xFF3a2a50), height: 1),
                              const SizedBox(height: 10),
                              _stagger(0.55, 0.80, child: ItemDropBadge(item: _rewardItem!)),
                              const SizedBox(height: 6),
                              _stagger(0.60, 0.82,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GameIcon(GameIconType.coinBag, size: 11, color: const Color(0xFF88cc88)),
                                    const SizedBox(width: 4),
                                    Text(AppLocalizations.of(ctx).battleAddedToBag,
                                        style: const TextStyle(
                                            fontSize: 11, color: Color(0xFF88cc88),
                                            letterSpacing: 1)),
                                  ],
                                )),
                            ],
                            if (_rewardArtifact != null) ...[
                              const SizedBox(height: 12),
                              const Divider(color: Color(0xFF2a2a3a), height: 1),
                              const SizedBox(height: 10),
                              _stagger(0.60, 0.82, child: _ArtifactDropBadge(artifact: _rewardArtifact!)),
                            ],
                          ],
                        ),
                      ),
                    ),
                    // ── Fixed button row — always visible ─────────────────────
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            final gs = GameStateProvider.of(context);
                            if (gs.pendingClassQuestlineUnlock) {
                              gs.pendingClassQuestlineUnlock = false;
                              gs.saveToLocal();
                            }
                            _exitRequested = true;
                            _rewardCompleter?.complete();
                            MainShell.switchToTab(0);
                            if (mounted) Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.accentGold),
                            foregroundColor: AppTheme.accentGold,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                          ),
                          child: Text(AppLocalizations.of(ctx).navHero,
                              style: const TextStyle(fontSize: 12, letterSpacing: 1)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            final gs = GameStateProvider.of(context);
                            if (gs.pendingBossDefeatMessage != null) {
                              gs.pendingBossDefeatMessage = null;
                              gs.saveToLocal();
                            }
                            if (gs.pendingUnlockNotice != null) {
                              gs.pendingUnlockNotice = null;
                              gs.saveToLocal();
                            }
                            if (gs.pendingClassQuestlineUnlock) {
                              gs.pendingClassQuestlineUnlock = false;
                              gs.saveToLocal();
                            }
                            _rewardCompleter?.complete();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentGold,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                          ),
                          child: Builder(builder: (ctx) {
                            final gs = GameStateProvider.of(ctx);
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(AppLocalizations.of(ctx).battleFight,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1)),
                                Text(
                                  '⚡ ${gs.energy} / ${gs.maxEnergy}',
                                  style: const TextStyle(
                                      fontSize: 9, letterSpacing: 0.5),
                                ),
                              ],
                            );
                          }),
                        ),
                      ],
                    ),
                  ],
                ),          // outer Column
                ),          // Container
              );            // ConstrainedBox
            },
          ),
        ),
      ),
      ),
    );
  }

  /// Slides a child up and fades it in over [begin]?[end] of _victoryCtrl.
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
          GameIcon(GameIconType.flame, size: 13, color: const Color(0xFFcc8844)),
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

// -- Speed button --------------------------------------------------------------

class _SpeedButton extends StatelessWidget {
  const _SpeedButton({required this.game});
  final GameState game;

  static const _debugLabels = ['1×', '1.5×', '5×', '10×'];
  // prod tiers: 1=1× 2=1.5× 3=2× 4=3× 5=5× (Crown only)
  static const _prodLabels  = ['1×', '1.5×', '2×', '3×', '5×'];

  String get _label => (kDebugMode ? _debugLabels : _prodLabels)[
      (game.effectiveSpeedTier - 1).clamp(0, kDebugMode ? 3 : 4)];

  bool get _active => game.effectiveSpeedTier > 1;

  // The speed selector lives in widgets/battle_speed_menu.dart so Settings can
  // reuse the exact same dropdown (see showBattleSpeedMenu).

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => showBattleSpeedMenu(context, game),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
          decoration: BoxDecoration(
            color: _active ? const Color(0xFF1a3a1a) : const Color(0xFF1a1a2a),
            border: Border.all(
              color: _active ? const Color(0xFF44cc44) : const Color(0xFF334466),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(
              _label,
              style: TextStyle(
                color: _active ? const Color(0xFF44cc44) : const Color(0xFF667799),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(Icons.arrow_drop_down,
                size: 16,
                color: _active ? const Color(0xFF44cc44) : const Color(0xFF667799)),
          ]),
        ),
      ),
    );
  }
}

// -- Artifact drop badge -------------------------------------------------------

class _ArtifactDropBadge extends StatelessWidget {
  const _ArtifactDropBadge({required this.artifact});
  final Artifact artifact;

  @override
  Widget build(BuildContext context) {
    final rc = artifact.displayColor;
    final tc = artifact.isSetPiece ? kArtifactSetColor : artifact.type.color;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1428),
        border: Border.all(color: rc.withValues(alpha: 0.7)),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: rc.withValues(alpha: 0.2), blurRadius: 8)],
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: tc.withValues(alpha: 0.12),
            border: Border.all(color: tc.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: ArtifactIcon(type: artifact.type, color: tc, size: 24, rarity: artifact.rarity),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(AppLocalizations.of(context).battleArtifactFound,
                style: TextStyle(fontSize: 9, color: rc, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 2),
            Text(artifact.name,
                style: TextStyle(fontSize: 12, color: rc, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(artifact.flavorText,
                style: const TextStyle(fontSize: 9, color: AppTheme.textMuted, height: 1.3)),
          ]),
        ),
      ]),
    );
  }
}

// ── Status-effect icon bar ─────────────────────────────────────────────────────

class _StatusInfo {
  const _StatusInfo(this.label, this.name, this.desc, this.rounds, this.color);
  final String label;
  final String name;
  final String desc;
  final int rounds;
  final Color color;
}

class _StatusBadgeRow extends StatelessWidget {
  const _StatusBadgeRow({required this.rowLabel, required this.statuses});
  final String rowLabel;
  final List<_StatusInfo> statuses;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(rowLabel,
            style: const TextStyle(
                fontSize: 8, color: Color(0xFF777777), letterSpacing: 1)),
        const SizedBox(width: 5),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: statuses
                  .map((s) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: _StatusBadge(status: s),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final _StatusInfo status;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showInfo(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: status.color.withValues(alpha: 0.18),
          border: Border.all(color: status.color.withValues(alpha: 0.65), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(status.label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: status.color,
                    letterSpacing: 0.3)),
            if (status.rounds > 0) ...[
              const SizedBox(width: 3),
              Text('${status.rounds}r',
                  style: TextStyle(
                      fontSize: 9, color: status.color.withValues(alpha: 0.7))),
            ],
          ],
        ),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1208),
            border: Border.all(color: status.color, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: status.color.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(status.label,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: status.color)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(status.name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFe0d0b0))),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, size: 18, color: Color(0xFF888888)),
                ),
              ]),
              const SizedBox(height: 10),
              Text(status.desc,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFFa89878), height: 1.4)),
              if (status.rounds > 0) ...[
                const SizedBox(height: 8),
                Text(AppLocalizations.of(context).battleRoundsRemaining(status.rounds),
                    style: TextStyle(
                        fontSize: 11,
                        color: status.color.withValues(alpha: 0.8),
                        fontStyle: FontStyle.italic)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
