import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/pvp.dart';
import '../services/auth_service.dart';
import '../services/game_state.dart';
import '../services/pvp_service.dart';
import '../theme/app_theme.dart';

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
  bool _boardLoading = true;
  bool _matchBusy    = false;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GameStateProvider.of(context).tickPvpStamina();
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
    try {
      final data = await _pvpService.fetchLeaderboard();
      if (mounted) setState(() { _board = data; _boardLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _board = []; _boardLoading = false; });
    }
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
    final ratingDelta = won ? '+${PvpService.winDelta}' : '-${PvpService.lossDelta}';
    final color = won ? const Color(0xFF44dd88) : const Color(0xFFcc4444);

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2623),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              won ? '⚔ VICTORY!' : '💀 DEFEATED',
              style: AppTheme.pixelHeading(fontSize: 17, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              'vs ${opponent.heroName} (${opponent.heroClass[0].toUpperCase()}${opponent.heroClass.substring(1)}  Lv${opponent.level}  ★${opponent.rating})',
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                border: Border.all(color: color.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Rating: ${game.pvpRating}  ($ratingDelta)',
                style: AppTheme.pixelHeading(fontSize: 14, color: color),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            Text('BATTLE LOG',
                style: AppTheme.pixelHeading(
                    fontSize: 10, color: AppTheme.textMuted, letterSpacing: 2)),
            const SizedBox(height: 6),
            ...log.map((line) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(line,
                      style: TextStyle(
                          fontSize: 12,
                          color: line.startsWith('⚔')
                              ? const Color(0xFF44dd88)
                              : line.startsWith('💀')
                                  ? const Color(0xFFcc4444)
                                  : AppTheme.textMuted)),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CLOSE',
                style: AppTheme.pixelHeading(
                    fontSize: 12, color: AppTheme.accentGold)),
          ),
        ],
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
          Expanded(child: _buildBoard(game)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _MatchButton(
              busy: _matchBusy,
              stamina: game.pvpStamina,
              onTap: () => _startMatch(context, game),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard(GameState game) {
    if (_boardLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.accentGold));
    }
    final board = _board ?? [];
    if (board.isEmpty) {
      return const Center(
        child: Text(
          'No players found yet.\nBe the first to fight!',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
        ),
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
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isMe
                ? AppTheme.accentGold.withValues(alpha: 0.07)
                : const Color(0xFF231F1B),
            border: Border.all(
              color: isMe ? AppTheme.accentGold : AppTheme.cardBorder,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: Text(medal,
                    style: TextStyle(
                        fontSize: rank <= 3 ? 16 : 12,
                        color: AppTheme.textMuted)),
              ),
              Expanded(
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
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('★${p.rating}',
                      style: GoogleFonts.pixelifySans(
                          fontSize: 15,
                          color: AppTheme.accentGold,
                          fontWeight: FontWeight.bold)),
                  Text('HP:${p.maxHp}  AC:${p.armorClass}',
                      style: const TextStyle(
                          fontSize: 10, color: AppTheme.textMuted)),
                ],
              ),
            ],
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
          Text(
            game.pvpStamina >= GameState.pvpMaxStamina
                ? 'FULL'
                : 'Next in $countdownLabel',
            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
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
              style: GoogleFonts.pixelifySans(
                  fontSize: 17, color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 10, color: AppTheme.textMuted,
                  letterSpacing: 1.5)),
        ],
      );
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
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  stamina > 0
                      ? '⚔  FIND MATCH  (−1 ♥)'
                      : 'NO STAMINA — WAIT FOR RECHARGE',
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
