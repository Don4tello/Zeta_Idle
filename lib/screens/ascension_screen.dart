import 'package:flutter/material.dart';
import '../models/ascension.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../l10n/content_l10n.dart';

class AscensionScreen extends StatelessWidget {
  const AscensionScreen({super.key, this.embedded = false});

  final bool embedded;
  static const _accentColor = Color(0xFFcc88ff);

  Widget _body(BuildContext context, GameState game) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (embedded) ...[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(AppLocalizations.of(context).ascTitle,
                  style: AppTheme.pixelHeading(
                      fontSize: 12, letterSpacing: 2, color: _accentColor)),
              _AscPointBadge(points: game.ascensionPoints),
            ]),
            const SizedBox(height: 12),
          ],
          _InfoBanner(game: game),
          const SizedBox(height: 16),
          if (game.canAscend) _AscendButton(game: game),
          if (game.ascensionLevel > 0) ...[
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).ascMetaBoard,
                style: AppTheme.pixelHeading(
                    fontSize: 12, letterSpacing: 2, color: _accentColor)),
            const SizedBox(height: 10),
            ...AscensionNode.all.map((node) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _NodeCard(game: game, node: node),
                )),
          ],
        ],
      );

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);

    if (embedded) {
      return ColoredBox(
          color: const Color(0xFF1B1A17), child: _body(context, game));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1030),
        title: Text(AppLocalizations.of(context).ascTitle,
            style: AppTheme.pixelHeading(
                fontSize: 14, letterSpacing: 2, color: _accentColor)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: _AscPointBadge(points: game.ascensionPoints),
          ),
        ],
      ),
      body: _body(context, game),
    );
  }
}

class _AscPointBadge extends StatelessWidget {
  const _AscPointBadge({required this.points});
  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF6622aa).withValues(alpha: 0.2),
        border: Border.all(
            color: const Color(0xFFcc88ff).withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Text('✦', style: TextStyle(fontSize: 11, color: Color(0xFFcc88ff))),
        const SizedBox(width: 4),
        Text(AppLocalizations.of(context).ascApPoints(points),
            style: AppTheme.pixelHeading(
                fontSize: 12, color: const Color(0xFFcc88ff))),
      ]),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final level = game.ascensionLevel;
    final prestige = game.prestigeLevel;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF100818),
        border: Border.all(color: const Color(0xFFcc88ff).withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(AppLocalizations.of(context).ascLevelLabel,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
            Text('$level',
                style: const TextStyle(
                    color: Color(0xFFcc88ff),
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Text(AppLocalizations.of(context).ascPrestigeLabel,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
            Text('$prestige',
                style: TextStyle(
                    color: prestige >= 5 ? Colors.white70 : AppTheme.textMuted,
                    fontSize: 13)),
          ]),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).ascBody,
            style: TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.5),
          ),
          if (prestige < 5) ...[
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).ascRequires(prestige),
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFFff6644)),
            ),
          ],
        ],
      ),
    );
  }
}

class _AscendButton extends StatelessWidget {
  const _AscendButton({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => _confirm(context, game),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6622aa),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(AppLocalizations.of(context).ascAscendAp(game.ascensionPointsForNextAscension),
            style: AppTheme.pixelHeading(
                fontSize: 13, letterSpacing: 1, color: Colors.white)),
      ),
    );
  }

  void _confirm(BuildContext context, GameState game) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a1030),
        title: Text(AppLocalizations.of(ctx).ascConfirmTitle,
            style: AppTheme.pixelHeading(
                fontSize: 14, color: const Color(0xFFcc88ff))),
        content: Text(
          AppLocalizations.of(ctx).ascConfirmBody(game.prestigeLevel, game.ascensionPointsForNextAscension),
          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(ctx).csCancel,
                style: TextStyle(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx, true);
              game.ascend();
            },
            child: Text(AppLocalizations.of(ctx).hubAscend,
                style: TextStyle(
                    color: const Color(0xFFcc88ff),
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _NodeCard extends StatelessWidget {
  const _NodeCard({required this.game, required this.node});
  final GameState game;
  final AscensionNode node;

  @override
  Widget build(BuildContext context) {
    final level = game.ascensionNodeLevel(node.id);
    final maxed = level >= node.maxLevel;
    final cost = node.costPerLevel;
    final canAfford = game.ascensionPoints >= cost && !maxed;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: level > 0
            ? const Color(0xFF100818)
            : const Color(0xFF231F1B),
        border: Border.all(
          color: maxed
              ? const Color(0xFFcc88ff).withValues(alpha: 0.6)
              : level > 0
                  ? const Color(0xFFcc88ff).withValues(alpha: 0.3)
                  : AppTheme.cardBorder,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        Text(node.icon, style: const TextStyle(fontSize: 23)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ContentL10n.of(context).tr('an_${node.id}', 'title', node.label),
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: level > 0
                          ? const Color(0xFFcc88ff)
                          : Colors.white70)),
              const SizedBox(height: 2),
              Text(ContentL10n.of(context).tr('an_${node.id}', 'desc', node.description),
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textMuted)),
              const SizedBox(height: 4),
              _LevelPips(level: level, max: node.maxLevel),
            ],
          ),
        ),
        const SizedBox(width: 12),
        if (maxed)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFcc88ff).withValues(alpha: 0.12),
              border: Border.all(
                  color: const Color(0xFFcc88ff).withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(AppLocalizations.of(context).auMax,
                style: AppTheme.pixelHeading(
                    fontSize: 10,
                    color: const Color(0xFFcc88ff))),
          )
        else
          TextButton(
            onPressed: canAfford
                ? () => game.spendAscensionPoint(node.id)
                : null,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFcc88ff),
              disabledForegroundColor: AppTheme.cardBorder,
              side: BorderSide(
                  color: canAfford
                      ? const Color(0xFFcc88ff)
                      : AppTheme.cardBorder),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text('✦$cost',
                style: AppTheme.pixelHeading(
                    fontSize: 11,
                    color: canAfford
                        ? const Color(0xFFcc88ff)
                        : AppTheme.cardBorder)),
          ),
      ]),
    );
  }
}

class _LevelPips extends StatelessWidget {
  const _LevelPips({required this.level, required this.max});
  final int level;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(max, (i) {
        final filled = i < level;
        return Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(right: 3),
          decoration: BoxDecoration(
            color: filled
                ? const Color(0xFFcc88ff)
                : Colors.transparent,
            border: Border.all(
                color: filled
                    ? const Color(0xFFcc88ff)
                    : AppTheme.cardBorder),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
