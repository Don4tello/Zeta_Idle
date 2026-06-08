import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/enemy_data.dart';
import '../models/equipment.dart';
import '../screens/endless_upgrade_screen.dart';
import '../widgets/item_drop_badge.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/affix_chip_row.dart';
import '../widgets/attack_effect.dart';
import '../widgets/battle_backgrounds.dart';
import '../widgets/ability_bar.dart';
import '../widgets/battle_sprites.dart';
import '../widgets/buff_hud.dart';
import '../widgets/pixel_health_bar.dart';

class EndlessScreen extends StatefulWidget {
  const EndlessScreen({super.key});

  @override
  State<EndlessScreen> createState() => _EndlessScreenState();
}

class _EndlessScreenState extends State<EndlessScreen> {
  final _heroKey   = GlobalKey<BattleSpriteState>();
  final _enemyKey  = GlobalKey<BattleSpriteState>();
  final _effectKey = GlobalKey<AttackEffectState>();

  bool _inBattle      = false;
  bool _busy          = false;
  bool _autoRunning   = false;
  bool _showingReward = false;
  int  _rewardGold    = 0;
  int  _rewardExp     = 0;
  int  _rewardShards  = 0;
  EquipmentItem? _rewardItem;

  // Saved so dispose can clean up even without context.
  GameState? _gameRef;

  @override
  void dispose() {
    if (_inBattle) _gameRef?.stopEndlessMode();
    super.dispose();
  }

  // ── Controls ────────────────────────────────────────────────────

  void _enterBattle(GameState game) {
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
          await Future.delayed(const Duration(milliseconds: 600));
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
          _showingReward = true;
          _rewardGold    = game.lastRewardGold;
          _rewardExp     = game.lastRewardExp;
          _rewardShards  = game.lastShardDrop;
          _rewardItem    = game.lastItemDrop;
        });
      }
      await Future.delayed(Duration(seconds: game.lastItemDrop != null ? 3 : 2));
      if (!mounted || !_inBattle) break;
      setState(() { _showingReward = false; _rewardItem = null; });

      // Respawn the same enemy.
      game.startEndlessBattle();
    }

    _autoRunning = false;
  }

  Future<void> _doAttack(GameState game) async {
    if (_busy || game.currentEnemy == null) return;
    if (mounted) setState(() => _busy = true);

    game.heroAttack();
    _heroKey.currentState?.playAttack();
    _effectKey.currentState?.trigger(game.hero.heroClass);
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _enemyKey.currentState?.playHit();

    if (mounted && game.currentEnemy != null) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        game.enemyAttack();
        _enemyKey.currentState?.playAttack();
        await Future.delayed(const Duration(milliseconds: 200));
        if (mounted) _heroKey.currentState?.playHit();
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
      appBar: AppBar(title: const Text('ENDLESS MODE')),
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
                'ENDLESS MODE LOCKED',
                style: GoogleFonts.pixelifySans(
                  fontSize: 16,
                  color: AppTheme.accentGold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Defeat your first enemy in Campaign\nto unlock Endless Mode.',
                textAlign: TextAlign.center,
                style: GoogleFonts.pixelifySans(
                  fontSize: 12,
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Text(
            '— ENDLESS ARENA —',
            textAlign: TextAlign.center,
            style: GoogleFonts.pixelifySans(
              fontSize: 13,
              color: AppTheme.textMuted,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'The battle rages on forever.',
            textAlign: TextAlign.center,
            style: GoogleFonts.pixelifySans(
              fontSize: 11,
              color: AppTheme.textMuted.withValues(alpha: 0.6),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 32),

          // Enemy card
          Container(
            padding: const EdgeInsets.all(20),
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
                    fontSize: 9,
                    color: AppTheme.textMuted,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 12),
                // Sprite preview
                SizedBox(
                  height: 72,
                  child: BattleSprite(
                    spriteId: baseEnemy.id,
                    facingLeft: true,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  baseEnemy.name.toUpperCase(),
                  style: GoogleFonts.pixelifySans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFee4040),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Level ${baseEnemy.level}',
                  style: GoogleFonts.pixelifySans(
                    fontSize: 12,
                    color: AppTheme.accentGold,
                  ),
                ),
                const SizedBox(height: 16),
                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statChip('HP', '${baseEnemy.maxHealth}'),
                    _statChip('ATK', '${baseEnemy.attack}'),
                    _statChip('AC', '${baseEnemy.armorClass}'),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  baseEnemy.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.pixelifySans(
                    fontSize: 10,
                    color: AppTheme.textMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Reward hint
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.darkBg,
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: AppTheme.textMuted, size: 14),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Rewards identical to campaign. Enemy respawns on each victory.',
                    style: GoogleFonts.pixelifySans(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Shard balance bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              border: Border.all(
                  color: const Color(0xFF80d0ff).withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.diamond_outlined,
                        color: Color(0xFF80d0ff), size: 14),
                    const SizedBox(width: 8),
                    Text(
                      '${_fmtShards(game.shards)}  Shards of Fate',
                      style: GoogleFonts.pixelifySans(
                        fontSize: 12,
                        color: const Color(0xFF80d0ff),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EndlessUpgradeScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color:
                              const Color(0xFF80d0ff).withValues(alpha: 0.6)),
                      color:
                          const Color(0xFF80d0ff).withValues(alpha: 0.08),
                    ),
                    child: Text(
                      'UPGRADES',
                      style: GoogleFonts.pixelifySans(
                        fontSize: 10,
                        color: const Color(0xFF80d0ff),
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: () => _enterBattle(game),
            child: Text(
              '⚔  ENTER ENDLESS BATTLE',
              style: GoogleFonts.pixelifySans(
                  fontSize: 14, letterSpacing: 2),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtShards(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  Widget _statChip(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.pixelifySans(
              fontSize: 9, color: AppTheme.textMuted, letterSpacing: 1),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.pixelifySans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textLight,
          ),
        ),
      ],
    );
  }

  // ── Battle arena ────────────────────────────────────────────────

  Widget _buildArena(GameState game, enemy) {
    if (!_autoRunning) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_autoRunning) _startAutoAttack(game);
      });
    }
    return Column(
      children: [
        // Arena viewport
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: battleBackgroundFor(enemy.id)),
              ),
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
              Column(
                children: [
                  const SizedBox(height: 6),
                  // Endless header badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF200010),
                      border: Border.fromBorderSide(
                        BorderSide(
                            color: Color(0xFFee4040), width: 1),
                      ),
                    ),
                    child: const Text(
                      '∞  ENDLESS ARENA  ∞',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFee4040),
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  if (game.activeAffixes.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
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
                          child: Text(
                            'VS',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentGold,
                              letterSpacing: 2,
                            ),
                          ),
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
                            auraColor: BattleSprite.auraColorFor(game.activeAffixes),
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
            ],
          ),
        ),

        // ── BUFF HUD ──────────────────────────────────────
        const BuffHud(),

        // ── ABILITY BAR ───────────────────────────────────
        const AbilityBar(),

        // Action bar
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 10),
          color: const Color(0xFF0e1228),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 12),
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
                      Icon(
                        _busy ? Icons.bolt : Icons.autorenew,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _busy ? 'ATTACKING...' : '⚔ AUTO BATTLE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _flee(game),
                  child: const Text('FLEE'),
                ),
              ),
            ],
          ),
        ),

        // Battle log
        Container(
          height: 130,
          decoration: const BoxDecoration(
            color: Color(0xFF0a0c18),
            border: Border(
              top: BorderSide(color: AppTheme.pixelBorder, width: 2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                color: const Color(0xFF141828),
                child: const Text(
                  'BATTLE LOG',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.accentGold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
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
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentGold,
                      letterSpacing: 4,
                    )),
                const SizedBox(height: 16),
                Text('+$_rewardGold GOLD',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFffd700),
                      letterSpacing: 2,
                    )),
                const SizedBox(height: 6),
                Text('+$_rewardExp XP',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4ad46a),
                      letterSpacing: 2,
                    )),
                const SizedBox(height: 6),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.diamond_outlined,
                      color: Color(0xFF80d0ff), size: 16),
                  const SizedBox(width: 6),
                  Text('+$_rewardShards SHARDS',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF80d0ff),
                        letterSpacing: 2,
                      )),
                ]),
                if (_rewardItem != null) ...[
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFF500020), height: 1),
                  const SizedBox(height: 10),
                  ItemDropBadge(item: _rewardItem!),
                ],
                const SizedBox(height: 16),
                const Text('The enemy stirs again...',
                    style: TextStyle(
                      fontSize: 11,
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

// ── Shared arena widgets ──────────────────────────────────────────

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
              letterSpacing: 1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'LV.$level  ATK:$attack',
            style: const TextStyle(
                fontSize: 9, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 6),
          Center(child: sprite),
          const SizedBox(height: 8),
          PixelHealthBar(current: currentHp, max: maxHp, height: 12),
          const SizedBox(height: 3),
          Text(
            '$currentHp / $maxHp',
            style: const TextStyle(
                fontSize: 9, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 8),
        ],
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
              style: TextStyle(color: AppTheme.accentGold, fontSize: 10)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 10, color: AppTheme.textLight, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

