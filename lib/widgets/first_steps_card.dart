import 'package:flutter/material.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'currency_icon.dart';

/// First-session "First Steps" checklist card (P3). Four quick goals that teach
/// the core loop, each paying a small instant reward, capped by a Rare Chest.
/// Self-gating: renders nothing unless [GameState.showFirstSteps] is true, so it
/// can be dropped anywhere in the dashboard column safely.
class FirstStepsCard extends StatelessWidget {
  const FirstStepsCard({super.key});

  // Localized step labels, indexed to match GameState.firstStepDone(i). Index 4
  // is the capstone chest.
  String _stepLabel(AppLocalizations l, int i) => switch (i) {
        0 => l.firstStepsWinBattle,
        1 => l.firstStepsReachStage3,
        2 => l.firstStepsFirstBoss,
        3 => l.firstStepsReachStage10,
        _ => l.firstStepsCapstone,
      };

  // Reward as pixel-art sprite(s) + amount — no currency word to translate.
  Widget _reward(GameState game, int i) {
    final entries = game.firstStepReward(i).entries.toList();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var j = 0; j < entries.length; j++) ...[
          if (j > 0) const SizedBox(width: 8),
          CurrencyAmount(entries[j].key, '+${entries[j].value}',
              size: 11,
              textStyle: TextStyle(
                  color: i == 4 ? AppTheme.accentGold : AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    if (!game.showFirstSteps) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);

    final rows = <Widget>[];
    for (var i = 0; i < GameState.kFirstStepLabels.length; i++) {
      rows.add(_stepRow(context, game, l, i));
    }
    rows.add(_stepRow(context, game, l, 4, capstone: true));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF17150E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            const Icon(Icons.flag, color: AppTheme.accentGold, size: 18),
            const SizedBox(width: 8),
            Text(l.firstStepsTitle,
                style: AppTheme.pixelHeading(
                    fontSize: 13, letterSpacing: 2, color: AppTheme.accentGold)),
          ]),
          const SizedBox(height: 4),
          Text(l.firstStepsSubtitle,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          const SizedBox(height: 10),
          ...rows,
        ],
      ),
    );
  }

  Widget _stepRow(BuildContext context, GameState game, AppLocalizations l, int i,
      {bool capstone = false}) {
    final done = capstone
        ? game.firstStepClaimable(i) || game.firstStepClaimed(i)
        : game.firstStepDone(i);
    final claimed = game.firstStepClaimed(i);
    final claimable = game.firstStepClaimable(i);

    final Color leadColor = claimed
        ? const Color(0xFF44cc88)
        : (done ? AppTheme.accentGold : AppTheme.textMuted);
    final IconData leadIcon = claimed
        ? Icons.check_circle
        : (done ? Icons.radio_button_checked : Icons.radio_button_unchecked);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(leadIcon, color: leadColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_stepLabel(l, i),
                    style: TextStyle(
                        color: claimed ? AppTheme.textMuted : Colors.white,
                        fontSize: 14,
                        fontWeight: capstone ? FontWeight.bold : FontWeight.normal,
                        decoration: claimed ? TextDecoration.lineThrough : null)),
                const SizedBox(height: 2),
                _reward(game, i),
              ],
            ),
          ),
          if (claimable)
            ElevatedButton(
              onPressed: () => game.claimFirstStep(i),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                minimumSize: const Size(0, 36),
                visualDensity: VisualDensity.compact,
              ),
              child: Text(l.firstStepsClaim, style: const TextStyle(fontWeight: FontWeight.bold)),
            )
          else if (claimed)
            Text(l.firstStepsClaimed,
                style: const TextStyle(color: Color(0xFF44cc88), fontSize: 12))
          else
            Text(capstone ? l.firstStepsLocked : l.firstStepsInProgress,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}
