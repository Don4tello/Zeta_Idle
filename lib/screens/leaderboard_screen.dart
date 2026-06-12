import 'package:flutter/material.dart';
import '../services/game_state.dart';
import '../services/leaderboard_service.dart';
import '../theme/app_theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<LeaderboardEntry>? _top50;
  LeaderboardEntry? _personal;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        LeaderboardService.fetchTop50(),
        LeaderboardService.fetchPersonalBest(),
      ]);
      setState(() {
        _top50    = results[0] as List<LeaderboardEntry>;
        _personal = results[1] as LeaderboardEntry?;
        _loading  = false;
      });
    } catch (e) {
      setState(() {
        _error   = 'Could not load leaderboard.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('ENDLESS LEADERBOARD',
            style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 2)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 18),
            onPressed: _loading ? null : _load,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _PersonalBestBar(game: game, entry: _personal),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Text(_error!,
                            style: const TextStyle(color: AppTheme.textMuted)))
                    : _top50!.isEmpty
                        ? const Center(
                            child: Text('No scores yet — be the first!',
                                style: TextStyle(color: AppTheme.textMuted)))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            itemCount: _top50!.length,
                            itemBuilder: (ctx, i) =>
                                _EntryTile(rank: i + 1, entry: _top50![i]),
                          ),
          ),
        ],
      ),
    );
  }
}

class _PersonalBestBar extends StatelessWidget {
  const _PersonalBestBar({required this.game, required this.entry});
  final GameState game;
  final LeaderboardEntry? entry;

  @override
  Widget build(BuildContext context) {
    final floor = entry?.floor ?? 0;
    return Container(
      color: const Color(0xFF231F1B),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        const Text('🎯 ', style: TextStyle(fontSize: 17)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your personal best',
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 11)),
              Text('Floor $floor',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        _SubmitButton(game: game),
      ]),
    );
  }
}

class _SubmitButton extends StatefulWidget {
  const _SubmitButton({required this.game});
  final GameState game;

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton> {
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _submitting ? null : _submit,
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.accentGold,
        side: const BorderSide(color: AppTheme.accentGold),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        _submitting ? 'SUBMITTING...' : 'SUBMIT SCORE',
        style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 1),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    await LeaderboardService.submitScore(
      heroName: widget.game.hero.name,
      floor: widget.game.campaignStageIndex,
      heroClass: widget.game.hero.heroClass.name,
    );
    if (mounted) setState(() => _submitting = false);
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.rank, required this.entry});
  final int rank;
  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final isTop3 = rank <= 3;
    final rankColor = switch (rank) {
      1 => const Color(0xFFffcc44),
      2 => const Color(0xFFaaaaaa),
      3 => const Color(0xFFcc8844),
      _ => AppTheme.textMuted,
    };
    final rankIcon = switch (rank) {
      1 => '🥇',
      2 => '🥈',
      3 => '🥉',
      _ => '#$rank',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isTop3
            ? rankColor.withValues(alpha: 0.06)
            : const Color(0xFF231F1B),
        border: Border.all(
          color: isTop3
              ? rankColor.withValues(alpha: 0.4)
              : AppTheme.cardBorder,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(children: [
        SizedBox(
          width: 36,
          child: rank <= 3
              ? Text(rankIcon, style: const TextStyle(fontSize: 19))
              : Text(rankIcon,
                  style: TextStyle(
                      fontSize: 11,
                      color: rankColor,
                      fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.name,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isTop3 ? rankColor : Colors.white70)),
              Text(entry.heroClass,
                  style: const TextStyle(
                      fontSize: 10, color: AppTheme.textMuted)),
            ],
          ),
        ),
        Text('Floor ${entry.floor}',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isTop3 ? rankColor : Colors.white70)),
      ]),
    );
  }
}
