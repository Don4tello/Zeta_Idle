import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/pvp.dart';
import '../models/subclass.dart';
import '../services/auth_service.dart';
import '../services/game_state.dart';
import '../services/pvp_service.dart';
import '../theme/app_theme.dart';
import '../widgets/arena_ability_effect.dart';
import '../widgets/battle_arena.dart';
import '../widgets/battle_sprites.dart';
import '../widgets/empty_state.dart';
import '../widgets/battle_split_panel.dart' show BattleIconBar;
import '../widgets/zcoin_icon.dart';
import 'pvp_sim_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PvpScreen
//
// Shows stamina, the player's rating, a live leaderboard, and a FIND MATCH
// button. Each match costs 1 stamina (max 5, recharges 1 per 45 min).
// Combat is simulated locally using exported hero stat snapshots.
// ─────────────────────────────────────────────────────────────────────────────

class PvpScreen extends StatefulWidget {
  const PvpScreen({super.key});

  @override
  State<PvpScreen> createState() => _PvpScreenState();
}

class _PvpScreenState extends State<PvpScreen> {
  final _pvpService  = PvpService();
  final _authService = AuthService();

  List<PvpSnapshot>? _board;
  // Generated opponents cached for a stable coalesced board across reloads.
  List<PvpSnapshot>? _fillers;
  bool _boardLoading = true;
  bool _matchBusy    = false;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final game = GameStateProvider.of(context);
      game.tickPvpStamina();
      _loadBoard();
    });
    _ticker = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!mounted) return;
      GameStateProvider.of(context).tickPvpStamina();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _loadBoard() async {
    setState(() => _boardLoading = true);
    final game = GameStateProvider.of(context);
    List<PvpSnapshot> real = const [];
    try {
      real = await _pvpService.fetchLeaderboard();
    } catch (_) {
      // Firestore unavailable — the coalesce step fills from generated players.
    }
    if (!mounted) return;
    setState(() {
      _board = _coalesceBoard(game, real);
      _boardLoading = false;
    });
  }

  /// Always-populated leaderboard: real players first, topped up with generated
  /// "coalesce" opponents so the arena is never empty. This matters at launch
  /// (or in any low-population bracket) when there may be too few real users.
  /// Real players take priority and displace fillers by user id.
  List<PvpSnapshot> _coalesceBoard(GameState game, List<PvpSnapshot> real) {
    final uid    = _authService.currentUser?.uid ?? 'local_player';
    final mySnap = game.buildPvpSnapshot(uid);

    final byId = <String, PvpSnapshot>{};
    for (final p in real) {
      if (p.userId == uid) continue; // a fresh copy of self is added below
      byId[p.userId] = p;
    }

    // Fill remaining slots with generated opponents (cached so the board stays
    // stable across reloads/fights instead of reshuffling every match).
    const targetOpponents = 12;
    if (byId.length < targetOpponents) {
      _fillers ??= generateDevOpponents(max(1, game.hero.level), game.pvpRating);
      for (final f in _fillers!) {
        if (byId.length >= targetOpponents) break;
        byId.putIfAbsent(f.userId, () => f);
      }
    }

    return [mySnap, ...byId.values]
      ..sort((a, b) => b.rating.compareTo(a.rating));
  }

  /// Returns up to 3 leaderboard players ranked just above the current player.
  List<PvpSnapshot> _getNearbyRivals() {
    final board = _board ?? [];
    if (board.isEmpty) return [];
    final uid   = _authService.currentUser?.uid ?? '';
    final myIdx = board.indexWhere((p) => p.userId == uid);
    if (myIdx <= 0) {
      // Unranked or already #1 — show the top 3 (excluding self)
      return board.where((p) => p.userId != uid).take(3).toList();
    }
    // Players at board[0..myIdx-1] are ranked above; take at most 3
    final start = max(0, myIdx - 3);
    return board.sublist(start, myIdx).reversed.toList();
  }

  Future<void> _challengePlayer(
      BuildContext ctx, GameState game, PvpSnapshot opponent) async {
    if (!game.spendPvpStamina()) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
          content: Text('No stamina! Recharges 1 every 45 minutes.'),
          duration: Duration(seconds: 2),
        ));
      }
      return;
    }
    final mySnap = game.buildPvpSnapshot(
        _authService.currentUser?.uid ?? 'local_challenger');
    final (won, log) = simulatePvpBattle(mySnap, opponent, Random());
    game.recordPvpResult(won);
    _loadBoard();
    if (mounted) await _showResult(ctx, game, won, opponent, log);
  }

  Future<void> _startMatch(BuildContext context, GameState game) async {
    if (_matchBusy) return;
    if (!game.spendPvpStamina()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No stamina! Recharges 1 every 45 minutes.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _matchBusy = true);

    PvpSnapshot? opponent;
    try {
      final user = _authService.currentUser ??
          await _authService.signInAnonymously();
      if (user != null) {
        final mySnap = game.buildPvpSnapshot(user.uid);
        await _pvpService.uploadSnapshot(user.uid, mySnap);
        opponent = await _pvpService.findOpponent(user.uid, game.pvpRating);
      }
    } catch (_) {}

    opponent ??= generateBotOpponent(game.pvpRating);

    final mySnap = game.buildPvpSnapshot(
        _authService.currentUser?.uid ?? 'local');
    final rng = Random();
    final (won, log) = simulatePvpBattle(mySnap, opponent, rng);

    try {
      final uid = _authService.currentUser?.uid;
      if (uid != null) {
        await _pvpService.recordResult(
          userId:    uid,
          won:       won,
          newRating: PvpService.updatedRating(game.pvpRating, won),
        );
      }
    } catch (_) {}

    game.recordPvpResult(won);

    setState(() => _matchBusy = false);

    if (mounted) {
      await _showResult(context, game, won, opponent, log);
      _loadBoard();
    }
  }

  Future<void> _showResult(
    BuildContext context,
    GameState game,
    bool won,
    PvpSnapshot opponent,
    List<String> log,
  ) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => _PvpBattleFullScreen(
          game: game,
          won: won,
          opponent: opponent,
          log: log,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('PVP ARENA',
            style: AppTheme.pixelHeading(
                fontSize: 14, letterSpacing: 2, color: AppTheme.accentGold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.science, size: 18, color: AppTheme.textMuted),
            tooltip: 'Sim Lab',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PvpSimScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 18, color: AppTheme.textMuted),
            tooltip: 'Refresh leaderboard',
            onPressed: _boardLoading ? null : _loadBoard,
          ),
        ],
      ),
      body: Column(
        children: [
          _StaminaBar(game: game),
          _RatingCard(game: game),
          if (!_boardLoading && _getNearbyRivals().isNotEmpty)
            _NearbyRivalsPanel(
              rivals: _getNearbyRivals(),
              onChallenge: (opp) => _challengePlayer(context, game, opp),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(children: [
              Expanded(child: Divider(color: AppTheme.cardBorder)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('LEADERBOARD',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold)),
              ),
              Expanded(child: Divider(color: AppTheme.cardBorder)),
            ]),
          ),
          // Daily rank card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: game.pvpDailyRank > 0
                  ? const Color(0xFF1a2a1a)
                  : const Color(0xFF231F1B),
              border: Border.all(color: game.pvpDailyRank > 0
                  ? const Color(0xFF44cc88).withValues(alpha: 0.5)
                  : AppTheme.cardBorder),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TODAY: ${game.pvpDailyRankLabel}',
                      style: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 1,
                          color: game.pvpDailyRank > 0 ? const Color(0xFF44cc88) : AppTheme.textMuted)),
                  Text('${game.pvpDailyWins} wins today  •  ${game.pvpDailyDamage} total dmg',
                      style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                ],
              )),
              if (game.pvpDailyRank > 0 && !game.pvpDailyRewardClaimed)
                GestureDetector(
                  onTap: () { game.claimPvpDailyReward(); setState(() {}); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF44cc88).withValues(alpha: 0.12),
                      border: Border.all(color: const Color(0xFF44cc88)),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text('CLAIM', style: AppTheme.pixelHeading(
                        fontSize: 10, color: const Color(0xFF44cc88))),
                  ),
                )
              else if (game.pvpDailyRewardClaimed)
                Text('✓ CLAIMED', style: AppTheme.pixelHeading(
                    fontSize: 10, color: const Color(0xFF44cc88))),
            ]),
          ),

          Expanded(child: _buildBoard(game)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _MatchButton(
                busy: _matchBusy,
                stamina: game.pvpStamina,
                onTap: () => _startMatch(context, game),
              ),
              if (game.pvpStamina <= 0 && game.pvpRefillCost != null) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: game.zcoins >= game.pvpRefillCost!
                        ? () { game.buyPvpStamina(); setState(() {}); }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2a1040),
                      foregroundColor: const Color(0xFFcc88ff),
                      side: BorderSide(color: game.zcoins >= game.pvpRefillCost!
                          ? const Color(0xFFcc88ff) : AppTheme.cardBorder),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      ZCoinIcon(size: 13, animate: false),
                      const SizedBox(width: 5),
                      Text(
                        'BUY +5 STAMINA  (${game.pvpRefillCost} ZCoins)',
                        style: AppTheme.pixelHeading(fontSize: 12, letterSpacing: 1,
                            color: game.zcoins >= game.pvpRefillCost!
                                ? const Color(0xFFcc88ff) : AppTheme.textMuted),
                      ),
                    ]),
                  ),
                ),
              ],
            ]),
          ),
        ],
      ),
    );
  }

  static Color _classColor(String cls) => switch (cls) {
    'fighter'     => const Color(0xFF888888),
    'barbarian'   => const Color(0xFFcc4444),
    'rogue'       => const Color(0xFF44cc88),
    'ranger'      => const Color(0xFF66aa44),
    'paladin'     => const Color(0xFFffcc33),
    'cleric'      => const Color(0xFFffffaa),
    'wizard'      => const Color(0xFF6688ff),
    'sorcerer'    => const Color(0xFFcc44ff),
    'warlock'     => const Color(0xFF9944cc),
    'bard'        => const Color(0xFFff88cc),
    'monk'        => const Color(0xFF88ddff),
    'druid'       => const Color(0xFF44aa66),
    _             => const Color(0xFF888888),
  };

  Widget _buildBoard(GameState game) {
    if (_boardLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.accentGold));
    }
    final board = _board ?? [];
    if (board.isEmpty) {
      return const EmptyState(
        icon: '⚔',
        title: 'NO CHALLENGERS YET',
        subtitle: 'Fight a match to join the leaderboard\nand see how you stack up.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: board.length,
      itemBuilder: (_, i) {
        final p     = board[i];
        final isMe  = p.userId == (_authService.currentUser?.uid ?? '');
        final rank  = i + 1;
        final medal = rank == 1 ? '🥇' : rank == 2 ? '🥈' : rank == 3 ? '🥉' : '#$rank';
        final classColor = _classColor(p.heroClass);
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                classColor.withValues(alpha: isMe ? 0.15 : 0.08),
                const Color(0xFF231F1B),
              ],
            ),
            border: Border.all(
              color: isMe ? AppTheme.accentGold : classColor.withValues(alpha: 0.4),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(medal,
                      style: TextStyle(
                          fontSize: rank <= 3 ? 16 : 12,
                          color: AppTheme.textMuted)),
                ),
                SizedBox(width: 30, height: 34,
                    child: StaticEnemySprite(
                        spriteId: 'hero_${p.heroClass}',
                        size: 30,
                        colorFilter: subclassById(p.subclassId ?? '')?.spriteColorFilter)),
                const SizedBox(width: 8),
                Builder(builder: (_) {
                  final sub = subclassById(p.subclassId ?? '');
                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.heroName,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isMe ? AppTheme.accentGold : Colors.white)),
                        Text(
                          '${p.heroClass[0].toUpperCase()}${p.heroClass.substring(1)}  '
                          'Lv${p.level}  '
                          '${p.wins}W / ${p.losses}L',
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.textMuted),
                        ),
                        if (sub != null)
                          Text(sub.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: sub.spriteSwatch)),
                      ],
                    ),
                  );
                }),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('★${p.rating}',
                        style: GoogleFonts.rajdhani(
                            fontSize: 15,
                            color: AppTheme.accentGold,
                            fontWeight: FontWeight.bold)),
                    Text('HP:${p.maxHp}  ARM:${p.armorClass}',
                        style: const TextStyle(
                            fontSize: 10, color: AppTheme.textMuted)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Stamina bar ──────────────────────────────────────────────────────────────

class _StaminaBar extends StatelessWidget {
  const _StaminaBar({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final remaining = game.pvpRechargeRemaining;
    final mins = remaining.inMinutes;
    final secs = remaining.inSeconds % 60;
    final countdownLabel = game.pvpStamina >= GameState.pvpMaxStamina
        ? 'FULL'
        : '${mins}m ${secs.toString().padLeft(2, '0')}s';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF231F1B),
        border: Border(bottom: BorderSide(color: AppTheme.cardBorder)),
      ),
      child: Row(
        children: [
          Text('STAMINA  ',
              style: AppTheme.pixelHeading(
                  fontSize: 10, color: AppTheme.textMuted, letterSpacing: 2)),
          ...List.generate(
            GameState.pvpMaxStamina,
            (i) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                i < game.pvpStamina ? Icons.favorite : Icons.favorite_border,
                size: 18,
                color: i < game.pvpStamina
                    ? const Color(0xFFdd3355)
                    : AppTheme.cardBorder,
              ),
            ),
          ),
          const Spacer(),
          Tooltip(
            message: 'Stamina recovers 1 heart every 45 minutes.',
            child: Text(
              game.pvpStamina >= GameState.pvpMaxStamina
                  ? 'FULL'
                  : 'Next ❤ in $countdownLabel',
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Player rating card ───────────────────────────────────────────────────────

class _RatingCard extends StatelessWidget {
  const _RatingCard({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF231F1B),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(label: 'RATING', value: '★${game.pvpRating}',
              color: AppTheme.accentGold),
          _Stat(label: 'WINS',   value: '${game.pvpWins}',
              color: const Color(0xFF44dd88)),
          _Stat(label: 'LOSSES', value: '${game.pvpLosses}',
              color: const Color(0xFFcc4444)),
          _Stat(label: 'W/L',
              value: game.pvpWins + game.pvpLosses == 0
                  ? '—'
                  : '${(game.pvpWins / (game.pvpWins + game.pvpLosses) * 100).toStringAsFixed(0)}%',
              color: Colors.white),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color});
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: GoogleFonts.rajdhani(
                  fontSize: 17, color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 10, color: AppTheme.textMuted,
                  letterSpacing: 1.5)),
        ],
      );
}

// ─── Nearby rivals panel ─────────────────────────────────────────────────────

class _NearbyRivalsPanel extends StatelessWidget {
  const _NearbyRivalsPanel({required this.rivals, required this.onChallenge});
  final List<PvpSnapshot> rivals;
  final void Function(PvpSnapshot) onChallenge;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1C14),
        border: Border(
          top:    BorderSide(color: const Color(0xFFcc4444).withValues(alpha: 0.3)),
          bottom: BorderSide(color: const Color(0xFFcc4444).withValues(alpha: 0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
            child: Row(children: [
              const Text('🎯', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 6),
              Text('NEAR YOUR RANK',
                  style: AppTheme.pixelHeading(
                      fontSize: 10,
                      letterSpacing: 2,
                      color: const Color(0xFFcc4444))),
              const SizedBox(width: 6),
              Text('— players just above you',
                  style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
            ]),
          ),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              itemCount: rivals.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => _RivalCard(
                snap: rivals[i],
                onChallenge: () => onChallenge(rivals[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RivalCard extends StatelessWidget {
  const _RivalCard({required this.snap, required this.onChallenge});
  final PvpSnapshot snap;
  final VoidCallback onChallenge;

  @override
  Widget build(BuildContext context) {
    final cls = snap.heroClass[0].toUpperCase() + snap.heroClass.substring(1);
    return Container(
      width: 160,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1e1818),
        border: Border.all(color: const Color(0xFFcc4444).withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              StaticEnemySprite(
                  spriteId: 'hero_${snap.heroClass}',
                  size: 32,
                  colorFilter: subclassById(snap.subclassId ?? '')?.spriteColorFilter),
              const SizedBox(width: 6),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(snap.heroName,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textLight),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1),
                  Text('$cls  Lv${snap.level}',
                      style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
                  if (subclassById(snap.subclassId ?? '') != null)
                    Text(subclassById(snap.subclassId ?? '')!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w600,
                            color: subclassById(snap.subclassId!)!.spriteSwatch)),
                  Text('★${snap.rating}',
                      style: GoogleFonts.rajdhani(
                          fontSize: 11,
                          color: AppTheme.accentGold,
                          fontWeight: FontWeight.bold)),
                ],
              )),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: 26,
            child: ElevatedButton(
              onPressed: onChallenge,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2a1010),
                side: BorderSide(
                    color: const Color(0xFFcc4444).withValues(alpha: 0.7), width: 1),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
              ),
              child: Text('CHALLENGE',
                  style: AppTheme.pixelHeading(
                      fontSize: 9, color: const Color(0xFFcc4444))),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Match button ─────────────────────────────────────────────────────────────

class _MatchButton extends StatelessWidget {
  const _MatchButton({
    required this.busy,
    required this.stamina,
    required this.onTap,
  });
  final bool busy;
  final int stamina;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final canFight = !busy && stamina > 0;
    return GestureDetector(
      onTap: canFight ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: canFight
              ? const Color(0xFF7A2E2E)
              : AppTheme.cardBorder.withValues(alpha: 0.3),
          border: Border.all(
            color: canFight ? const Color(0xFFcc2222) : AppTheme.cardBorder,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: busy
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  stamina > 0 ? '⚔  FIND MATCH  (−1 ♥)' : 'NO STAMINA',
                  style: AppTheme.pixelHeading(
                      fontSize: 13,
                      color: canFight ? Colors.white : AppTheme.textMuted,
                      letterSpacing: 1),
                ),
        ),
      ),
    );
  }
}

// ── Full-screen PvP Battle ───────────────────────────────────────────────────

class _PvpBattleFullScreen extends StatefulWidget {
  const _PvpBattleFullScreen({
    required this.game,
    required this.won,
    required this.opponent,
    required this.log,
  });
  final GameState game;
  final bool won;
  final PvpSnapshot opponent;
  final List<String> log;
  @override
  State<_PvpBattleFullScreen> createState() => _PvpBattleFullScreenState();
}

class _PvpBattleFullScreenState extends State<_PvpBattleFullScreen>
    with TickerProviderStateMixin {
  final _arenaKey  = GlobalKey<BattleArenaState>();
  final _effectKey = GlobalKey<ArenaAbilityEffectState>();
  bool _showResult = false;
  bool _fighting = true;
  bool _autoRunning = false;

  @override
  void initState() {
    super.initState();
    final game = widget.game;
    game.startPvpBattle(widget.opponent);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_autoRunning) _startAutoAttack(game);
    });
  }

  Future<void> _startAutoAttack(GameState game) async {
    if (_autoRunning) return;
    _autoRunning = true;

    // Wait for arena to mount
    await Future.delayed(const Duration(milliseconds: 600));
    await WidgetsBinding.instance.endOfFrame;

    while (mounted && _fighting) {
      if (game.currentEnemy == null || game.heroDefeated) break;

      game.clearPendingFloats();
      game.heroAttack();
      final firedAbility = game.lastAbilityFired;
      if (firedAbility != null) {
        _arenaKey.currentState?.playAbilityBanner(firedAbility.name, firedAbility.effect, id: firedAbility.id);
        _effectKey.currentState?.playEffect(firedAbility.id);
      }

      await (_arenaKey.currentState?.playHeroAttack(
            game.lastHeroDamage,
            isCrit: game.lastHeroCrit,
            heroClass: game.hero.heroClass,
            damageType: game.lastHeroDamageType,
          ) ?? Future.value());

      for (final f in game.pendingFloats) {
        _arenaKey.currentState?.addExtraFloat(f.value, isHeal: f.isHeal, type: f.type);
      }

      if (game.currentEnemy == null) {
        _arenaKey.currentState?.playEnemyDeath();
        break;
      }

      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted || !_fighting) break;

      game.clearPendingFloats();
      game.enemyAttack();
      for (final f in game.pendingFloats) {
        _arenaKey.currentState?.addExtraFloat(f.value, isHeal: f.isHeal, type: f.type);
      }
      await (_arenaKey.currentState?.playEnemyAttack(
            game.lastEnemyDamage,
            damageType: game.lastEnemyDamageType,
          ) ?? Future.value());

      if (game.heroDefeated) break;

      if (mounted) setState(() {});
      await Future.delayed(const Duration(milliseconds: 500));
    }

    _autoRunning = false;
    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() { _showResult = true; _fighting = false; });
  }

  @override
  Widget build(BuildContext context) {
    final opp = widget.opponent;
    final oppSprite = 'hero_${opp.heroClass}';
    final color = widget.won ? const Color(0xFF44dd88) : const Color(0xFFcc4444);
    final ratingDelta = widget.won ? '+${PvpService.winDelta}' : '-${PvpService.lossDelta}';

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Text('PVP  —  ${widget.game.hero.name} vs ${opp.heroName}',
            style: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 1)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _fighting = false;
            _autoRunning = false;
            widget.game.currentEnemy = null;
            widget.game.hero.healToFull();
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Arena — same as campaign
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                BattleArena(
                  key: _arenaKey,
                  heroName:         widget.game.hero.name,
                  heroLevel:        widget.game.hero.level,
                  heroCurrentHp:    widget.game.hero.currentHealth,
                  heroMaxHp:        widget.game.hero.maxHealth,
                  heroAttack:       widget.game.hero.attack,
                  heroSpriteId:     widget.game.heroBattleSpriteId,
                  heroGender:       widget.game.hero.gender,
                  heroRace:         widget.game.heroRace,
                  heroAuraColor:    widget.game.heroAuraColor,
                  heroAuraIntensity: widget.game.heroAuraIntensity,
                  heroColorFilter:  widget.game.heroSpriteFilter,
                  heroDamageType:   widget.game.hero.activeDamageType,
                  enemyName:     opp.heroName,
                  enemyLevel:    opp.level,
                  enemyCurrentHp: widget.game.currentEnemy?.currentHealth ?? 0,
                  enemyMaxHp:    opp.maxHp,
                  enemyAttack:   opp.attackBonus,
                  enemyId:       oppSprite,
                  enemyColorFilter: subclassById(opp.subclassId ?? '')?.spriteColorFilter,
                  headerLabel:   '⚔  PVP ARENA  ⚔',
                  heroBuffGlows: [
                    if (widget.game.heroAbsorbShield > 0) const Color(0xFF88ccff),
                    if (widget.game.buffAttackBonus > 0)  const Color(0xFFffcc00),
                    if (widget.game.buffAcBonus > 0)      const Color(0xFF66aaff),
                    if (widget.game.dodgeNextHit)          const Color(0xFF44ddcc),
                    if (widget.game.auraRoundsLeft > 0)   const Color(0xFF55ee88),
                  ],
                  enemyDebuffGlows: [
                    if (widget.game.dotRoundsLeft > 0)         const Color(0xFF88dd00),
                    if (widget.game.enemyStunRounds > 0)       const Color(0xFFcc44ff),
                    if (widget.game.stunApplicationCount >= 2) const Color(0xFF665577),
                    if (widget.game.enemySilenceRounds > 0)    const Color(0xFFffdd00),
                    if (widget.game.enemyMissChanceRounds > 0) const Color(0xFFaaaaff),
                    if (widget.game.enemyWeakenRounds > 0)     const Color(0xFFff4488),
                    if (widget.game.enemyVulnerableRounds > 0) const Color(0xFFff8800),
                  ],
                  heroCritPct: widget.game.totalCritChancePct,
                  heroArmor:   widget.game.heroArmorValue,
                ),
                ArenaAbilityEffect(key: _effectKey),
              ],
            ),
          ),

          // Ability icon bar
          if (_fighting) const SafeArea(top: false, child: BattleIconBar()),

          // Result overlay
          if (_showResult)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: color.withValues(alpha: 0.08),
              child: Column(
                children: [
                  Text(
                    widget.won ? '⚔ VICTORY!' : '💀 DEFEATED',
                    style: AppTheme.pixelHeading(fontSize: 21, color: color, letterSpacing: 2),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'vs ${opp.heroName} (${opp.heroClass[0].toUpperCase()}${opp.heroClass.substring(1)}  Lv${opp.level}  ★${opp.rating})',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  if (subclassById(opp.subclassId ?? '') != null)
                    Text(
                      subclassById(opp.subclassId!)!.name,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: subclassById(opp.subclassId!)!.spriteSwatch),
                    ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10),
                      border: Border.all(color: color.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Rating: ${widget.game.pvpRating}  ($ratingDelta)',
                      style: AppTheme.pixelHeading(fontSize: 15, color: color),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color.withValues(alpha: 0.15),
                        foregroundColor: color,
                        side: BorderSide(color: color),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text('RETURN TO ARENA',
                          style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 1, color: color)),
                    ),
                  ),
                ],
              ),
            ),

          // Fighting indicator
          if (_fighting)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              color: const Color(0xFF0a0e1f),
              child: Center(
                child: const Text('Fighting...',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, letterSpacing: 1)),
              ),
            ),
        ],
      ),
    );
  }
}
