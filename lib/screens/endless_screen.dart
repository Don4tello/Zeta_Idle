import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/campaign_data.dart';
import '../data/enemy_data.dart';
import '../models/equipment.dart';
import '../widgets/item_drop_badge.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/affix_chip_row.dart';
import '../widgets/battle_arena.dart';
import '../widgets/battle_split_panel.dart';
import '../widgets/battle_sprites.dart';
import '../widgets/level_up_section.dart';
import '../utils/format_number.dart';
import 'main_shell.dart' show TutorialTip;

class EndlessScreen extends StatefulWidget {
  const EndlessScreen({super.key});

  @override
  State<EndlessScreen> createState() => _EndlessScreenState();
}

class _EndlessScreenState extends State<EndlessScreen> {
  final _arenaKey = GlobalKey<BattleArenaState>();

  bool _inBattle      = false;
  bool _busy          = false;
  bool _autoRunning   = false;
  bool _showingReward = false;
  int? _selectedBossStage;
  int? _activeBossStage;
  int _bossTier = 1;
  int  _rewardGold     = 0;
  int  _rewardExp      = 0;
  int  _rewardShards   = 0;
  int? _rewardMilestone;
  EquipmentItem? _rewardItem;
  LevelUpEvent?  _levelUpEvent;

  // Saved so dispose can clean up even without context.
  GameState? _gameRef;

  @override
  void dispose() {
    if (_inBattle) _gameRef?.stopEndlessMode();
    super.dispose();
  }

  // ── Controls ────────────────────────────────────────────────────

  void _enterBattle(GameState game) {
    _activeBossStage = null;
    game.startEndlessBattle();
    setState(() => _inBattle = true);
  }

  void _flee(GameState game) {
    game.stopEndlessMode();
    setState(() {
      _inBattle     = false;
      _autoRunning  = false;
      _busy         = false;
      _showingReward = false;
    });
  }

  // ── Auto-battle loop ────────────────────────────────────────────

  void _startAutoAttack(GameState game) async {
    if (_autoRunning) return;
    _autoRunning = true;

    while (mounted && _inBattle) {
      // Fight until enemy dies or hero is defeated.
      while (mounted && _inBattle && game.currentEnemy != null) {
        if (!_busy) await _doAttack(game);
        if (mounted && game.currentEnemy != null) {
          await Future.delayed(Duration(milliseconds: game.scaledInterval(600)));
        }
      }

      if (!mounted || !_inBattle) break;

      // Hero defeated?
      if (game.heroDefeated) {
        game.heroDefeated = false;
        game.stopEndlessMode();
        await _showDefeatDialog(game.hero.name);
        if (mounted) {
          setState(() {
            _inBattle    = false;
            _autoRunning = false;
            _busy        = false;
          });
        }
        break;
      }

      // Victory — show reward overlay then respawn enemy.
      if (mounted) {
        setState(() {
          _showingReward    = true;
          _rewardGold       = game.lastRewardGold;
          _rewardExp        = game.lastRewardExp;
          _rewardShards     = game.lastShardDrop;
          _rewardMilestone  = game.lastEndlessMilestone;
          _rewardItem       = game.lastItemDrop;
          _levelUpEvent     = game.lastLevelUp;
        });
      }
      await Future.delayed(Duration(seconds: game.lastItemDrop != null ? 3 : 2));
      if (!mounted || !_inBattle) break;
      setState(() { _showingReward = false; _rewardItem = null; });

      // Respawn the same enemy and wait for Flutter to re-render the arena
      // before attacking. Without the frame yield, _arenaKey.currentState is
      // null (BattleArena hasn't mounted yet), hero attacks instantly with no
      // animation and kills the new enemy in the same microtask loop.
      if (_activeBossStage != null) {
        game.startEndlessBattleAtStage(_activeBossStage!);
      } else {
        game.startEndlessBattle();
      }
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted || !_inBattle) break;
    }

    _autoRunning = false;
  }

  Future<void> _doAttack(GameState game) async {
    if (_busy || game.currentEnemy == null) return;
    if (mounted) setState(() => _busy = true);

    game.clearPendingFloats();
    game.heroAttack();
    await (_arenaKey.currentState?.playHeroAttack(
          game.lastHeroDamage,
          isCrit: game.lastHeroCrit,
          heroClass: game.hero.heroClass,
          damageType: game.lastHeroDamageType,
        ) ?? Future.value());
    for (final f in game.pendingFloats) {
      _arenaKey.currentState?.addExtraFloat(f.value, isHeal: f.isHeal, type: f.type);
    }
    if (mounted && game.currentEnemy == null) {
      _arenaKey.currentState?.playEnemyDeath();
    }

    if (mounted && game.currentEnemy != null) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        game.clearPendingFloats();
        game.enemyAttack();
        for (final f in game.pendingFloats) {
          _arenaKey.currentState?.addExtraFloat(f.value, isHeal: f.isHeal, type: f.type);
        }
        await (_arenaKey.currentState?.playEnemyAttack(
              game.lastEnemyDamage,
              damageType: game.lastEnemyDamageType,
            ) ?? Future.value());
      }
    }

    if (mounted) setState(() => _busy = false);
  }

  Future<void> _showDefeatDialog(String heroName) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a0a0a),
        title: Text(
          '${heroName.toUpperCase()} FALLS',
          style: const TextStyle(color: Color(0xFFee4040), letterSpacing: 2),
        ),
        content: const Text(
          'Your hero was overwhelmed.\nUpgrade your stats and try again.',
          style: TextStyle(color: AppTheme.textLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'RETURN',
              style: TextStyle(color: AppTheme.accentGold),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    _gameRef = game;
    final enemy = game.currentEnemy;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: const Text('TOWER ASCENSION'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_inBattle) {
              game.stopEndlessMode();
              setState(() {
                _autoRunning = false;
                _inBattle = false;
                _showingReward = false;
                _selectedBossStage = null;
                _activeBossStage = null;
              });
            } else if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _inBattle && enemy != null
              ? _buildArena(game, enemy)
              : _buildLobby(game),
          if (_showingReward) _buildRewardOverlay(),
        ],
      ),
    );
  }

  // ── Lobby ───────────────────────────────────────────────────────

  Widget _buildLobby(GameState game) {
    if (!game.hasEndlessEnemy) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline,
                  color: AppTheme.textMuted, size: 48),
              const SizedBox(height: 20),
              Text(
                'TOWER ASCENSION LOCKED',
                style: GoogleFonts.pixelifySans(
                  fontSize: 17,
                  color: AppTheme.accentGold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Defeat your first enemy in Campaign\nto unlock Tower Ascension.',
                textAlign: TextAlign.center,
                style: GoogleFonts.pixelifySans(
                  fontSize: 13,
                  color: AppTheme.textMuted,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final baseEnemy = EnemyData.enemyForStage(game.endlessStageIndex);
    final stageIdx  = game.endlessStageIndex % CampaignData.stages.length;
    final stage     = CampaignData.stages[stageIdx];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TutorialTip(
            tutorialKey: 'endless',
            game: game,
            text: 'Tower Ascension lets you farm the enemy you\'re currently facing in campaign. '
                'Enemies respawn infinitely — earn gold, XP, and gem shards at your own pace.',
          ),
          // Personal best
          if (game.endlessPersonalBest > 0)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a2e),
                border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(children: [
                const Text('🏆', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  'PERSONAL BEST: Stage ${game.endlessPersonalBest}',
                  style: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 1, color: AppTheme.accentGold),
                )),
                Text('Stage ${game.endlessStageIndex + 1}',
                    style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
              ]),
            ),

          // ── ENTER BUTTON (top) ──────────────────────────────────
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () => _enterBattle(game),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B1A1A),
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: Text(
                '⚔  ENTER THE TOWER',
                style: GoogleFonts.pixelifySans(fontSize: 15, letterSpacing: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── ENEMY CARD ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              border: Border.all(
                color: AppTheme.accentRed.withValues(alpha: 0.6),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'YOUR OPPONENT',
                  style: GoogleFonts.pixelifySans(
                    fontSize: 10, color: AppTheme.textMuted, letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 68,
                  child: BattleSprite(spriteId: baseEnemy.id, facingLeft: true),
                ),
                const SizedBox(height: 10),
                Text(
                  baseEnemy.name.toUpperCase(),
                  style: GoogleFonts.pixelifySans(
                    fontSize: 18, fontWeight: FontWeight.bold,
                    color: const Color(0xFFee4040), letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Level ${baseEnemy.level}',
                  style: GoogleFonts.pixelifySans(
                    fontSize: 12, color: AppTheme.accentGold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statChip('HP',  '${baseEnemy.maxHealth}'),
                    _statChip('ATK', '${baseEnemy.attack}'),
                    _statChip('AC',  '${baseEnemy.armorClass}'),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  baseEnemy.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.pixelifySans(
                    fontSize: 11, color: AppTheme.textMuted, height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── BOSS SELECTOR ─────────────────────────────────────
          if (game.campaignStageIndex >= 5) ...[
            Text('CHALLENGE A BOSS',
                style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2, color: AppTheme.textMuted)),
            const SizedBox(height: 6),
            SizedBox(
              height: 75,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (int stage = 4; stage < game.campaignStageIndex; stage += 5)
                    if (stage < game.campaignStageIndex)
                    Builder(builder: (ctx) {
                      final boss = EnemyData.enemyForStage(stage);
                      final spriteId = EnemyData.spriteIdForStage(stage);
                      final isSelected = _selectedBossStage == stage;
                      return GestureDetector(
                        onTap: () => setState(() =>
                            _selectedBossStage = isSelected ? null : stage),
                        child: Container(
                          width: 60,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF3a0060).withValues(alpha: 0.7)
                                : const Color(0xFF2a0040).withValues(alpha: 0.5),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFcc44ff)
                                  : const Color(0xFFcc44ff).withValues(alpha: 0.3),
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: const Color(0xFFcc44ff).withValues(alpha: 0.3),
                                blurRadius: 8,
                              ),
                            ] : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 32,
                                child: StaticEnemySprite(spriteId: spriteId, size: 30),
                              ),
                              const SizedBox(height: 2),
                              Text(boss.name, style: TextStyle(fontSize: 7,
                                  color: isSelected ? const Color(0xFFee88ff) : const Color(0xFFcc88ff)),
                                  maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                              Text('Lv${boss.level}', style: const TextStyle(fontSize: 7, color: AppTheme.textMuted)),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
            // ── BOSS PREVIEW ─────────────────────────────────────
            if (_selectedBossStage != null) ...[
              const SizedBox(height: 10),
              Builder(builder: (_) {
                final boss = EnemyData.enemyForStage(_selectedBossStage!);
                final spriteId = EnemyData.spriteIdForStage(_selectedBossStage!);
                final tierMult = 1.0 + (_bossTier - 1) * 0.3;
                final scaledHp = (boss.maxHealth * tierMult * 1.5).round();
                final scaledAtk = (boss.attack * tierMult * 1.15).round();
                final bossGold = ((boss.level * 15 + 50) * tierMult).round().clamp(50, 99999);
                final bossXp = ((boss.level * 20 + 100) * tierMult).round().clamp(100, 99999);
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1a0a2e),
                    border: Border.all(color: const Color(0xFFcc44ff).withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(children: [
                    Row(children: [
                      SizedBox(width: 50, height: 50,
                          child: StaticEnemySprite(spriteId: spriteId, size: 48)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('☠ ${boss.name}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFcc88ff))),
                          Text('Level ${boss.level}',
                              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                          const SizedBox(height: 4),
                          Row(children: [
                            _statChip('HP', '$scaledHp'),
                            const SizedBox(width: 8),
                            _statChip('ATK', '$scaledAtk'),
                            const SizedBox(width: 8),
                            _statChip('AC', '${boss.armorClass + _bossTier}'),
                          ]),
                        ],
                      )),
                    ]),
                    // Tier selector
                    const SizedBox(height: 8),
                    Row(children: [
                      Text('TIER ', style: AppTheme.pixelHeading(fontSize: 9, color: AppTheme.textMuted, letterSpacing: 1)),
                      ...List.generate(10, (i) {
                        final t = i + 1;
                        final sel = _bossTier == t;
                        return GestureDetector(
                          onTap: () => setState(() => _bossTier = t),
                          child: Container(
                            width: 24, height: 24,
                            margin: const EdgeInsets.only(right: 3),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: sel ? const Color(0xFFcc44ff).withValues(alpha: 0.2) : const Color(0xFF1a1a2e),
                              border: Border.all(color: sel ? const Color(0xFFcc44ff) : AppTheme.cardBorder, width: sel ? 1.5 : 0.5),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text('$t', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold,
                                color: sel ? const Color(0xFFcc44ff) : AppTheme.textMuted)),
                          ),
                        );
                      }),
                    ]),
                    Text('Lv ${(_bossTier - 1) * 10 + 1}–${_bossTier * 10}',
                        style: const TextStyle(fontSize: 8, color: AppTheme.textMuted)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0a0a1e),
                        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Row(children: [
                          Text('REWARDS: ', style: AppTheme.pixelHeading(
                              fontSize: 9, letterSpacing: 1, color: AppTheme.textMuted)),
                          Text('💰 $bossGold   ',
                              style: const TextStyle(fontSize: 11, color: Color(0xFFdaa520), fontWeight: FontWeight.bold)),
                          Text('⚡ $bossXp XP   ',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF88ccff), fontWeight: FontWeight.bold)),
                          Text('◆ ${boss.level ~/ 3}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF6699ff), fontWeight: FontWeight.bold)),
                        ]),
                        const SizedBox(height: 4),
                        Row(children: [
                          Text('DROP: ', style: AppTheme.pixelHeading(
                              fontSize: 9, letterSpacing: 1, color: AppTheme.textMuted)),
                          Text(
                            boss.level >= 20 ? '⚔ Legendary Lv${boss.level}' :
                            boss.level >= 10 ? '⚔ Epic Lv${boss.level}' :
                            '⚔ Rare Lv${boss.level}',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                              color: boss.level >= 20 ? const Color(0xFFFFD700) :
                                     boss.level >= 10 ? const Color(0xFFcc44ff) :
                                     const Color(0xFF6699ff)),
                          ),
                        ]),
                      ]),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          _activeBossStage = _selectedBossStage;
                          game.startEndlessBattleAtStage(_selectedBossStage!);
                          setState(() {
                            _selectedBossStage = null;
                            _inBattle = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4a1070),
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFcc44ff), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: Text('⚔  ENTER BOSS BATTLE',
                            style: GoogleFonts.pixelifySans(fontSize: 14, letterSpacing: 2)),
                      ),
                    ),
                  ]),
                );
              }),
            ],
            const SizedBox(height: 10),
          ],

          // ── REWARD PREVIEW ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A0A),
              border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VICTORY REWARDS',
                  style: GoogleFonts.pixelifySans(
                    fontSize: 9, color: AppTheme.accentGold, letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _rewardChip('💰', '~${fmtNum(stage.goldReward)}', 'GOLD',
                        const Color(0xFFffd700)),
                    const SizedBox(width: 8),
                    _rewardChip('⭐', '~${fmtNum(stage.experienceReward)}', 'XP',
                        const Color(0xFF4ad46a)),
                    const SizedBox(width: 8),
                    _rewardChip('♾️', '∞', 'RESPAWNS', AppTheme.textMuted),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Base values · gear, prestige & passive bonuses apply',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.textMuted.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ── SHARD BALANCE ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              border: Border.all(
                  color: const Color(0xFF80d0ff).withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                const Icon(Icons.diamond_outlined,
                    color: Color(0xFF80d0ff), size: 14),
                const SizedBox(width: 8),
                Text(
                  '${AppTheme.fmtNumber(game.shards)}  Shards of Fate',
                  style: GoogleFonts.pixelifySans(
                    fontSize: 13, color: const Color(0xFF80d0ff), letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _statChip(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.pixelifySans(
              fontSize: 10, color: AppTheme.textMuted, letterSpacing: 1),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.pixelifySans(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppTheme.textLight,
          ),
        ),
      ],
    );
  }

  Widget _rewardChip(String emoji, String amount, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 3),
            Text(amount,
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: TextStyle(
                    fontSize: 9, color: color.withValues(alpha: 0.7),
                    letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  // ── Battle arena ────────────────────────────────────────────────

  static List<Color> _heroBuffGlows(GameState game) {
    final glows = <Color>[];
    if (game.buffAttackBonus > 0)  glows.add(const Color(0xFFffcc00));
    if (game.buffAcBonus > 0)      glows.add(const Color(0xFF66aaff));
    if (game.dodgeNextHit)         glows.add(const Color(0xFF44ddcc));
    if (game.auraRoundsLeft > 0)   glows.add(const Color(0xFF55ee88));
    return glows;
  }

  static List<Color> _enemyDebuffGlows(GameState game) {
    final glows = <Color>[];
    if (game.dotRoundsLeft > 0)     glows.add(const Color(0xFF88dd00));
    if (game.enemyStunRounds > 0)   glows.add(const Color(0xFFcc44ff));
    if (game.enemyWeakenRounds > 0) glows.add(const Color(0xFFff4488));
    return glows;
  }

  Widget _buildArena(GameState game, enemy) {
    if (!_autoRunning) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_autoRunning) _startAutoAttack(game);
      });
    }
    return Column(
      children: [
        Expanded(
          child: BattleArena(
            key: _arenaKey,
            heroName:          game.hero.name,
            heroLevel:         game.hero.level,
            heroCurrentHp:     game.hero.currentHealth,
            heroMaxHp:         game.hero.maxHealth,
            heroAttack:        game.hero.attack,
            heroSpriteId:      game.hero.spriteId,
            heroGender:        game.hero.gender,
            heroAuraColor:     game.heroAuraColor,
            heroAuraIntensity: game.heroAuraIntensity,
            heroColorFilter:   game.heroSkinFilter,
            enemyName:    enemy.name,
            enemyLevel:   enemy.level,
            enemyCurrentHp: enemy.currentHealth,
            enemyMaxHp:   enemy.maxHealth,
            enemyAttack:  enemy.attack,
            enemyId:      enemy.id,
            stageIndex:   game.campaignStageIndex,
            affixWidget: game.activeAffixes.isNotEmpty
                ? AffixChipRow(affixes: game.activeAffixes)
                : null,
            enemyAuraColor:   BattleSprite.auraColorFor(game.activeAffixes),
            heroDamageType:   game.hero.activeDamageType,
            enemyAttackType:  enemy.attackType,
            enemyResistances: enemy.resistances,
            heroBuffGlows:    _heroBuffGlows(game),
            enemyDebuffGlows: _enemyDebuffGlows(game),
          ),
        ),

        const BattleIconBar(),
      ],
    );
  }

  // ── Reward overlay ──────────────────────────────────────────────

  Widget _buildRewardOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.75),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
            decoration: BoxDecoration(
              color: const Color(0xFF200010),
              border: Border.all(color: const Color(0xFFee4040), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('VICTORY!',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentGold,
                      letterSpacing: 4,
                    )),
                const SizedBox(height: 16),
                Text('+$_rewardGold GOLD',
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFffd700),
                      letterSpacing: 2,
                    )),
                const SizedBox(height: 6),
                Text('+$_rewardExp XP',
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4ad46a),
                      letterSpacing: 2,
                    )),
                const SizedBox(height: 6),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.diamond_outlined,
                      color: Color(0xFF80d0ff), size: 16),
                  const SizedBox(width: 6),
                  if (_rewardShards > 0) Text(
                    '+$_rewardShards SHARDS',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF80d0ff),
                      letterSpacing: 1,
                    )),
                ]),
                if (_rewardMilestone != null) ...[
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFF3a1a00), height: 1),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFCC44).withValues(alpha: 0.10),
                      border: Border.all(color: const Color(0xFFFFCC44).withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '★ MILESTONE: $_rewardMilestone KILLS ★',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFCC44),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '+${_rewardMilestone! * 50} GOLD  +${(_rewardMilestone! ~/ 10).clamp(1, 10)} ◆',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFFFCC44),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_levelUpEvent != null) ...[
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFF3a2a18), height: 1),
                  const SizedBox(height: 10),
                  LevelUpSection(event: _levelUpEvent!),
                ],
                if (_rewardItem != null) ...[
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFF500020), height: 1),
                  const SizedBox(height: 10),
                  ItemDropBadge(item: _rewardItem!),
                ],
                const SizedBox(height: 16),
                const Text('The enemy stirs again...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFee4040),
                      letterSpacing: 1,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
              style: TextStyle(color: AppTheme.accentGold, fontSize: 11)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textLight, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

