import 'package:flutter/material.dart';
import '../models/shop_catalog.dart';
import '../services/game_state.dart';
import '../services/leaderboard_service.dart';
import '../theme/app_theme.dart';
import '../widgets/battle_sprites.dart';
import '../widgets/player_profile_sheet.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key, this.board = LeaderboardBoard.campaign});

  final LeaderboardBoard board;

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<LeaderboardEntry>? _top50;
  LeaderboardEntry? _personal;
  int? _personalRank;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Defer to post-frame: _load reads the GameState InheritedWidget, which
    // isn't safe to look up during initState.
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  /// Submit the player's current best (silent, personal-best only), then read
  /// the board — so opening the leaderboard always reflects your latest run.
  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final game = GameStateProvider.of(context);
      // rebirths only ranks the campaign/dungeon boards; the score-based boards
      // ignore it. stage carries each board's headline metric.
      final (rebirths, stage) = switch (widget.board) {
        LeaderboardBoard.campaign => (game.leaderboardRebirths, game.campaignStageIndex),
        LeaderboardBoard.dungeon  => (game.leaderboardRebirths, game.dungeonHighestTier),
        LeaderboardBoard.endless  => (0, game.endlessStageIndex),
        LeaderboardBoard.bossRush => (0, game.bossRushBestScore),
        LeaderboardBoard.gauntlet => (0, game.gauntletHighScore),
      };
      await LeaderboardService.submitScore(
        board:     widget.board,
        heroName:  game.hero.name,
        heroClass: game.hero.heroClass.displayName,
        subclass:  game.subclassName,
        spriteId:  game.heroBattleSpriteId,
        rebirths:  rebirths,
        stage:     stage,
        title:       game.activeTitle,
        nameColorId: game.activeNameColor,
        frameId:     game.activeFrame,
        level:       game.hero.level,
        ascensionAp: game.totalAscensionAp,
      );

      final results = await Future.wait([
        LeaderboardService.fetchTop50(widget.board),
        LeaderboardService.fetchPersonalBest(widget.board),
      ]);
      final top50 = results[0] as List<LeaderboardEntry>;
      final personal = results[1] as LeaderboardEntry?;
      final rank = personal != null
          ? await LeaderboardService.fetchPersonalRank(widget.board, personal.score)
          : null;

      if (!mounted) return;
      setState(() {
        _top50        = top50;
        _personal     = personal;
        _personalRank = rank;
        _loading      = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error   = 'Could not load leaderboard.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: Text(widget.board.title,
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
          _PersonalBar(board: widget.board, entry: _personal, rank: _personalRank),
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
                            itemBuilder: (ctx, i) => _EntryTile(
                              rank: i + 1,
                              entry: _top50![i],
                              board: widget.board,
                              isMe: _personal != null &&
                                  _top50![i].uid == _personal!.uid,
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

/// Formats a board entry's score for display, e.g. "R7 · Stage 92" / "Floor 40".
String _formatScore(LeaderboardBoard board, LeaderboardEntry e) {
  final rb = e.rebirths > 0 ? 'R${e.rebirths} · ' : '';
  return switch (board) {
    LeaderboardBoard.campaign => '${rb}Stage ${e.stage}',
    LeaderboardBoard.dungeon  => '${rb}Tier ${e.stage}',
    LeaderboardBoard.endless  => 'Floor ${e.stage}',
    LeaderboardBoard.bossRush => 'Score ${e.stage}',
    LeaderboardBoard.gauntlet => 'Score ${e.stage}',
  };
}

class _PersonalBar extends StatelessWidget {
  const _PersonalBar({required this.board, required this.entry, required this.rank});
  final LeaderboardBoard board;
  final LeaderboardEntry? entry;
  final int? rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF231F1B),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        const Text('🎯 ', style: TextStyle(fontSize: 17)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your personal best',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              Text(entry != null ? _formatScore(board, entry!) : 'Not ranked yet',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        if (rank != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.accentGold.withValues(alpha: 0.1),
              border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(children: [
              const Text('RANK',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 9, letterSpacing: 1)),
              Text('#$rank',
                  style: const TextStyle(
                      color: AppTheme.accentGold,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ]),
          ),
      ]),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.rank,
    required this.entry,
    required this.board,
    required this.isMe,
  });
  final int rank;
  final LeaderboardEntry entry;
  final LeaderboardBoard board;
  final bool isMe;

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

    final borderColor = isMe
        ? AppTheme.accentGold
        : isTop3
            ? rankColor.withValues(alpha: 0.4)
            : AppTheme.cardBorder;

    // Cosmetics.
    final frameColor = CosmeticItem.frameColorFor(entry.frameId);
    final nameColor = CosmeticItem.nameColorFor(entry.nameColorId)
        ?? (isTop3 ? rankColor : Colors.white70);
    final hasTitle = entry.title != null && entry.title!.isNotEmpty;

    return InkWell(
      onTap: () => showPlayerProfile(context, entry, board, rank, isMe),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? AppTheme.accentGold.withValues(alpha: 0.08)
              : isTop3
                  ? rankColor.withValues(alpha: 0.06)
                  : const Color(0xFF231F1B),
          border: Border.all(color: borderColor, width: isMe ? 1.5 : 1),
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
          // Skin/class-sprite avatar with an optional cosmetic frame ring.
          Container(
            width: 34,
            height: 34,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1A17),
              border: Border.all(
                  color: frameColor ?? AppTheme.cardBorder,
                  width: frameColor != null ? 2 : 1),
              borderRadius: BorderRadius.circular(4),
              boxShadow: frameColor != null
                  ? [BoxShadow(color: frameColor.withValues(alpha: 0.5), blurRadius: 5)]
                  : null,
            ),
            alignment: Alignment.center,
            child: entry.spriteId.isNotEmpty
                ? StaticEnemySprite(spriteId: entry.spriteId, size: 28)
                : const Icon(Icons.person, size: 18, color: AppTheme.textMuted),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Flexible(
                    child: Text(entry.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: nameColor)),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 6),
                    Text('YOU',
                        style: AppTheme.pixelHeading(
                            fontSize: 8, letterSpacing: 1, color: AppTheme.accentGold)),
                  ],
                ]),
                if (hasTitle)
                  Text(entry.title!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: CosmeticItem.titleColorForName(entry.title))),
                Text(entry.classLabel,
                    style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Text(_formatScore(board, entry),
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isTop3 ? rankColor : Colors.white70)),
        ]),
      ),
    );
  }
}
