import 'package:flutter/material.dart';
import '../models/challenge_modifier.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../l10n/content_l10n.dart';

class ChallengeModifiersScreen extends StatelessWidget {
  const ChallengeModifiersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: Text(AppLocalizations.of(context).cmTitle,
            style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 2)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF231F1B),
              border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(AppLocalizations.of(context).cmOptionalHandicaps,
                  style: AppTheme.pixelHeading(
                      fontSize: 12, color: AppTheme.accentGold, letterSpacing: 2)),
              const SizedBox(height: 6),
              Text(
                AppLocalizations.of(context).cmDesc,
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.4),
              ),
              const SizedBox(height: 8),
              if (game.activeModifierId != null) ...[
                const Divider(color: AppTheme.cardBorder, height: 1),
                const SizedBox(height: 8),
                Row(children: [
                  Text(AppLocalizations.of(context).cmActive,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                  Builder(builder: (context) {
                    final m = ChallengeModifier.all
                        .firstWhere((m) => m.id == game.activeModifierId);
                    return Text(
                      ContentL10n.of(context).tr(m.id, 'title', m.name),
                      style: AppTheme.pixelHeading(
                          fontSize: 11, color: AppTheme.accentGold),
                    );
                  }),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => game.setActiveModifier(null),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.accentRed.withValues(alpha: 0.6)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(AppLocalizations.of(context).cmClear,
                          style: AppTheme.pixelHeading(
                              fontSize: 10, color: AppTheme.accentRed)),
                    ),
                  ),
                ]),
              ],
            ]),
          ),
          ...ChallengeModifier.all.map((mod) => _ModifierCard(mod: mod, game: game)),
        ],
      ),
    );
  }
}

class _ModifierCard extends StatelessWidget {
  const _ModifierCard({required this.mod, required this.game});
  final ChallengeModifier mod;
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final active = game.activeModifierId == mod.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => game.setActiveModifier(active ? null : mod.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: active
                ? AppTheme.accentGold.withValues(alpha: 0.06)
                : const Color(0xFF231F1B),
            border: Border.all(
              color: active ? AppTheme.accentGold : AppTheme.cardBorder,
              width: active ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(children: [
            Text(mod.icon, style: const TextStyle(fontSize: 27)),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ContentL10n.of(context).tr(mod.id, 'title', mod.name),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: active ? AppTheme.accentGold : Colors.white,
                    )),
                const SizedBox(height: 4),
                Text(ContentL10n.of(context).tr(mod.id, 'desc', mod.description),
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textMuted, height: 1.3)),
                const SizedBox(height: 8),
                Row(children: [
                  _StatBadge(AppLocalizations.of(context).cmEssence(mod.rewardPctBonus),
                      const Color(0xFF44dd88)),
                  if (mod.enemyHpMult > 1)
                    _StatBadge(
                        AppLocalizations.of(context).cmEnemyHp(mod.enemyHpMult.toStringAsFixed(2)),
                        const Color(0xFFff6644)),
                  if (mod.enemyAtkMult > 1)
                    _StatBadge(
                        AppLocalizations.of(context).cmEnemyAtk(mod.enemyAtkMult.toStringAsFixed(2)),
                        const Color(0xFFff4444)),
                  if (mod.heroHpMult < 1)
                    _StatBadge(
                        AppLocalizations.of(context).cmHeroHp(mod.heroHpMult.toStringAsFixed(1)),
                        const Color(0xFFff9900)),
                ]),
              ],
            )),
            if (active)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.check_circle, color: AppTheme.accentGold, size: 22),
              ),
          ]),
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
    );
  }
}
