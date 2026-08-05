import 'package:flutter/material.dart';
import '../models/subclass.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/battle_sprites.dart';

class SubclassScreen extends StatelessWidget {
  const SubclassScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final body = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildBody(context, game),
    );
    if (embedded) return body;
    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('SPECIALIZATION',
            style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
      ),
      body: body,
    );
  }

  Widget _buildBody(BuildContext context, GameState game) {
    final options = subclassesForClass(game.hero.heroClass);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (game.subclassId != null) ...[
          _ChosenBanner(game: game),
          const SizedBox(height: 10),
          _RespecButton(game: game),
          const SizedBox(height: 16),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2623),
              border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LEVEL 50 SPECIALIZATION',
                    style: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 2, color: AppTheme.accentGold)),
                const SizedBox(height: 6),
                Text(
                  'Choose a specialization for your ${game.hero.heroClass.displayName}. '
                  'It grants a powerful capstone bonus plus stat bonuses, applied immediately. '
                  'You can change it later for ${GameState.kSubclassRespecCost} ZCoins.',
                  style: const TextStyle(fontSize: 13, color: AppTheme.textLight),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text('${game.hero.heroClass.displayName.toUpperCase()} SPECIALIZATIONS  (${options.length})',
            style: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 2)),
        const SizedBox(height: 10),
        ...options.map((sub) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _SubclassCard(
            sub: sub,
            spriteId: 'hero_${game.hero.heroClass.name}',
            chosen: game.subclassId == sub.id,
            locked: game.subclassId != null && game.subclassId != sub.id,
            onChoose: () => _confirmPick(context, game, sub),
          ),
        )),
      ],
    );
  }

  void _confirmPick(BuildContext context, GameState game, Subclass sub) {
    if (game.subclassId != null) return;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('Choose ${sub.name}?',
            style: AppTheme.pixelHeading(fontSize: 14, color: AppTheme.accentGold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sub.flavor,
                style: const TextStyle(fontSize: 13, color: AppTheme.textLight,
                    fontStyle: FontStyle.italic)),
            const SizedBox(height: 12),
            if (sub.statLine.isNotEmpty) ...[
              Text('STAT BONUSES',
                  style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2, color: AppTheme.textMuted)),
              const SizedBox(height: 4),
              Text(sub.statLine,
                  style: const TextStyle(fontSize: 14, color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
            ],
            Text(sub.bonusSummary.isNotEmpty ? 'CAPSTONE BONUS' : 'SPECIAL EFFECT',
                style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2, color: AppTheme.textMuted)),
            const SizedBox(height: 4),
            Text(sub.bonusSummary.isNotEmpty ? sub.bonusSummary : sub.effectLabel,
                style: const TextStyle(fontSize: 14, color: AppTheme.textLight)),
            const SizedBox(height: 12),
            Text('You can change this later for ${GameState.kSubclassRespecCost} ZCoins.',
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL',
                style: AppTheme.pixelHeading(fontSize: 11, color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              game.pickSubclass(sub.id);
              Navigator.pop(context); // close the dialog; screen rebuilds
            },
            child: Text('CONFIRM',
                style: AppTheme.pixelHeading(fontSize: 11, color: AppTheme.accentGold)),
          ),
        ],
      ),
    );
  }
}

class _RespecButton extends StatelessWidget {
  const _RespecButton({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final canAfford = game.zcoins >= GameState.kSubclassRespecCost;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _confirmRespec(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: canAfford ? const Color(0xFF66aaff) : AppTheme.textMuted,
          side: BorderSide(color: canAfford ? const Color(0xFF335577) : AppTheme.cardBorder),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Text('CHANGE SPECIALIZATION  —  ${GameState.kSubclassRespecCost} ZCoins',
            style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 1,
                color: canAfford ? const Color(0xFF66aaff) : AppTheme.textMuted)),
      ),
    );
  }

  void _confirmRespec(BuildContext context) {
    // Capture the messenger up front — the button context can go stale once the
    // dialog closes / the screen rebuilds after respec (previously crashed on
    // Navigator.pop with a stale context).
    final messenger = ScaffoldMessenger.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('Change specialization?',
            style: AppTheme.pixelHeading(fontSize: 14, color: const Color(0xFF66aaff))),
        content: Text(
          'Spend ${GameState.kSubclassRespecCost} ZCoins to clear your current specialization '
          'and choose a new one?\n\nYour ZCoins: ${game.zcoins}',
          style: const TextStyle(fontSize: 13, color: AppTheme.textLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('CANCEL',
                style: AppTheme.pixelHeading(fontSize: 11, color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              final ok = game.respecSubclass();
              if (!ok) {
                messenger.showSnackBar(const SnackBar(
                  content: Text('Not enough ZCoins to respec.'),
                  duration: Duration(seconds: 2),
                ));
              }
            },
            child: Text('CONFIRM',
                style: AppTheme.pixelHeading(fontSize: 11, color: const Color(0xFF66aaff))),
          ),
        ],
      ),
    );
  }
}

class _ChosenBanner extends StatelessWidget {
  const _ChosenBanner({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final sub = subclassById(game.subclassId!);
    if (sub == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.accentGold.withValues(alpha: 0.08),
        border: Border.all(color: AppTheme.accentGold, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('ACTIVE SUBCLASS',
                style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2, color: AppTheme.textMuted)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withValues(alpha: 0.15),
                border: Border.all(color: AppTheme.accentGold),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text('CHOSEN',
                  style: AppTheme.pixelHeading(fontSize: 9, color: AppTheme.accentGold)),
            ),
          ]),
          const SizedBox(height: 6),
          Text(sub.name,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.accentGold)),
          const SizedBox(height: 4),
          Text(sub.bonusSummary.isNotEmpty ? sub.bonusSummary : sub.effectLabel,
              style: const TextStyle(fontSize: 13, color: AppTheme.textLight)),
          if (sub.statLine.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(sub.statLine,
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          ],
        ],
      ),
    );
  }
}

class _SubclassCard extends StatelessWidget {
  const _SubclassCard({
    required this.sub,
    required this.spriteId,
    required this.chosen,
    required this.locked,
    required this.onChoose,
  });

  final Subclass sub;
  final String spriteId;
  final bool chosen;
  final bool locked;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    final borderColor = chosen
        ? AppTheme.accentGold
        : locked
            ? AppTheme.cardBorder.withValues(alpha: 0.4)
            : AppTheme.cardBorder;
    final textOpacity = locked ? 0.4 : 1.0;

    return Opacity(
      opacity: textOpacity,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF231F1B),
          border: Border.all(color: borderColor, width: chosen ? 1.5 : 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42, height: 42,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: sub.spriteSwatch.withValues(alpha: 0.12),
                    border: Border.all(color: sub.spriteSwatch.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: StaticEnemySprite(
                      spriteId: spriteId, size: 36, colorFilter: sub.spriteColorFilter),
                ),
                Expanded(
                  child: Text(sub.name,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: chosen ? AppTheme.accentGold : AppTheme.textLight)),
                ),
                if (chosen)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withValues(alpha: 0.15),
                      border: Border.all(color: AppTheme.accentGold),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text('ACTIVE',
                        style: AppTheme.pixelHeading(fontSize: 9, color: AppTheme.accentGold)),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(sub.flavor,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textMuted, fontStyle: FontStyle.italic)),
            const SizedBox(height: 10),
            // Effect badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF17150E),
                border: Border.all(color: const Color(0xFF3344aa)),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('⚡ ', style: TextStyle(fontSize: 12)),
                  Expanded(
                    child: Text(
                        sub.bonusSummary.isNotEmpty ? sub.bonusSummary : sub.effectLabel,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF88aaff))),
                  ),
                ],
              ),
            ),
            if (sub.statLine.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(sub.statLine,
                  style: const TextStyle(fontSize: 12, color: AppTheme.accentGold)),
            ],
            if (!chosen && !locked) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: onChoose,
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.accentGold,
                    side: const BorderSide(color: AppTheme.accentGold),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text('CHOOSE THIS PATH',
                      style: AppTheme.pixelHeading(fontSize: 12, letterSpacing: 1,
                          color: AppTheme.accentGold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
