import 'package:flutter/material.dart';

import '../models/shop_catalog.dart';
import '../services/leaderboard_service.dart';
import '../theme/app_theme.dart';
import 'battle_sprites.dart';

/// Read-only public character sheet for a leaderboard entry. Shows the player's
/// cosmetic identity (skin, frame, name colour, title) plus the stats stored on
/// their leaderboard record — no live idle battle or "next action" panels.
void showPlayerProfile(
  BuildContext context,
  LeaderboardEntry entry,
  LeaderboardBoard board,
  int rank,
  bool isMe,
) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _PlayerProfileSheet(
      entry: entry,
      board: board,
      rank: rank,
      isMe: isMe,
    ),
  );
}

class _PlayerProfileSheet extends StatelessWidget {
  const _PlayerProfileSheet({
    required this.entry,
    required this.board,
    required this.rank,
    required this.isMe,
  });

  final LeaderboardEntry entry;
  final LeaderboardBoard board;
  final int rank;
  final bool isMe;

  String get _boardResult {
    final rb = entry.rebirths > 0 ? 'Rebirth ${entry.rebirths} · ' : '';
    return switch (board) {
      LeaderboardBoard.campaign => '${rb}Stage ${entry.stage}',
      LeaderboardBoard.dungeon  => '${rb}Tier ${entry.stage}',
      LeaderboardBoard.endless  => 'Floor ${entry.stage}',
      LeaderboardBoard.bossRush => 'Score ${entry.stage}',
      LeaderboardBoard.gauntlet => 'Score ${entry.stage}',
    };
  }

  @override
  Widget build(BuildContext context) {
    final frameColor = CosmeticItem.frameColorFor(entry.frameId);
    final nameColor = CosmeticItem.nameColorFor(entry.nameColorId) ?? AppTheme.textLight;
    final hasTitle = entry.title != null && entry.title!.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.panelBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(top: BorderSide(color: AppTheme.accentGold, width: 2)),
      ),
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 12,
        bottom: 20 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grab handle
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppTheme.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Avatar with cosmetic frame ring
          Container(
            width: 92, height: 92,
            decoration: BoxDecoration(
              color: const Color(0xFF1B1A17),
              shape: BoxShape.circle,
              border: Border.all(
                  color: frameColor ?? AppTheme.cardBorder,
                  width: frameColor != null ? 3 : 1.5),
              boxShadow: frameColor != null
                  ? [BoxShadow(color: frameColor.withValues(alpha: 0.6), blurRadius: 14)]
                  : null,
            ),
            alignment: Alignment.center,
            child: entry.spriteId.isNotEmpty
                ? StaticEnemySprite(spriteId: entry.spriteId, size: 68)
                : const Icon(Icons.person, size: 44, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 12),

          if (hasTitle)
            Text(entry.title!.toUpperCase(),
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: CosmeticItem.titleColorForName(entry.title))),
          const SizedBox(height: 2),

          // Name (+ YOU chip)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(entry.name,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold, color: nameColor,
                        shadows: CosmeticItem.hasGlow(entry.nameColorId)
                            ? [Shadow(color: nameColor, blurRadius: 12)]
                            : null)),
              ),
              if (isMe) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text('YOU',
                      style: TextStyle(
                          fontSize: 9, letterSpacing: 1,
                          fontWeight: FontWeight.bold, color: AppTheme.accentGold)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(entry.classLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
          const SizedBox(height: 18),

          // Stat grid
          Row(
            children: [
              _stat('RANK', rank > 0 ? '#$rank' : '—', const Color(0xFFffcc44)),
              _stat(board.name.toUpperCase(), _boardResult, AppTheme.accentGold),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _stat('REBIRTHS', '${entry.rebirths}', const Color(0xFFcc88ff)),
              if (entry.level > 0)
                _stat('LEVEL', '${entry.level}', const Color(0xFF66aaff))
              else
                const Spacer(),
            ],
          ),
          if (entry.ascensionAp > 0) ...[
            const SizedBox(height: 8),
            Row(children: [
              _stat('ASCENSION AP', '⭑ ${entry.ascensionAp}', AppTheme.accentGoldBright),
              const Spacer(),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1A17),
          border: Border.all(color: color.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 9, letterSpacing: 1, color: AppTheme.textMuted)),
            const SizedBox(height: 4),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
