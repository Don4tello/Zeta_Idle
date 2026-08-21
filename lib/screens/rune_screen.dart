import 'package:flutter/material.dart';
import '../models/ability_rune.dart';
import '../models/equipment.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/currency_info.dart';

class RuneScreen extends StatelessWidget {
  const RuneScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final runes = AbilityRune.forClass(game.hero.heroClass);

    final body = ListView(
      padding: const EdgeInsets.all(14),
      children: [
        // Dust balance
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1225),
            border: Border.all(color: const Color(0xFFaa66ff).withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ABILITY RUNES', style: AppTheme.pixelHeading(
                  fontSize: 12, color: const Color(0xFFaa66ff), letterSpacing: 2)),
              const SizedBox(height: 6),
              const Text(
                'Socket runes to permanently enhance your abilities.\n'
                'Each rune modifies a specific ability — boosting damage, duration, or cooldown.\n'
                'Costs Arcane Dust from disenchanting gear, gems, and runes.',
                style: TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.4)),
              const SizedBox(height: 8),
              Row(children: [
                InfoTip(
                  message: CurrencyInfo.gemShards,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Text('🌀 Arcane Dust: ', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                    Text('${game.gemShards}', style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFbb88ee))),
                  ]),
                ),
                const SizedBox(width: 16),
                Text('📜 Owned: ${game.ownedRunes.length}/${runes.length}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ]),
            ],
          ),
        ),

        // Rune list
        if (runes.isEmpty)
          const Center(child: Text('No runes available for this class.',
              style: TextStyle(color: AppTheme.textMuted)))
        else
          ...runes.map((rune) => _RuneCard(rune: rune, game: game)),
      ],
    );

    if (embedded) return body;
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Text('RUNES', style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
      ),
      body: Column(children: [
        const CurrencySourceBar(['gemShards']),
        Expanded(child: body),
      ]),
    );
  }
}

class _RuneCard extends StatelessWidget {
  const _RuneCard({required this.rune, required this.game});
  final AbilityRune rune;
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final owned = game.ownsRune(rune.id);
    final socketed = game.isRuneSocketed(rune.id);
    final borderColor = socketed
        ? const Color(0xFF44cc88)
        : owned
            ? rune.color
            : AppTheme.cardBorder;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: socketed
            ? const Color(0xFF112211)
            : const Color(0xFF1a1816),
        border: Border.all(color: borderColor.withValues(alpha: socketed ? 0.6 : 0.4)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(rune.icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rune.name,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                        color: socketed ? const Color(0xFF44cc88) : rune.color)),
                Text(rune.description,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.3)),
              ],
            )),
            if (socketed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF44cc88).withValues(alpha: 0.15),
                  border: Border.all(color: const Color(0xFF44cc88)),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text('SOCKETED', style: AppTheme.pixelHeading(
                    fontSize: 9, color: const Color(0xFF44cc88))),
              ),
          ]),
          if (rune.bonusEffectDesc != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: rune.color.withValues(alpha: 0.08),
                border: Border.all(color: rune.color.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('✦ ${rune.bonusEffectDesc}',
                  style: TextStyle(fontSize: 11, color: rune.color, fontWeight: FontWeight.bold)),
            ),
          ],
          if (!owned && !socketed) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a1a),
                border: Border.all(color: AppTheme.cardBorder),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(children: [
                Icon(Icons.lock_outline, size: 12, color: AppTheme.textMuted),
                SizedBox(width: 6),
                Expanded(child: Text('Not yet found — drops from bosses, dungeons, gauntlet, and expeditions.',
                    style: TextStyle(fontSize: 9, color: AppTheme.textMuted))),
              ]),
            ),
          ],
          if (owned && !socketed) ...[
            const SizedBox(height: 10),
            Builder(builder: (_) {
              final socketable = <EquipmentItem>[
                for (final item in game.inventory.equipped.values)
                  if (item.canSocketRune) item,
              ];
              if (socketable.isEmpty) {
                return const Text('Equip a ring or amulet to socket this rune.',
                    style: TextStyle(fontSize: 10, color: AppTheme.textMuted));
              }
              return Wrap(
                spacing: 6,
                runSpacing: 6,
                children: socketable.map((item) => SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: owned ? () => game.socketAbilityRune(rune.id, item) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: owned
                          ? rune.color.withValues(alpha: 0.15)
                          : Colors.transparent,
                      foregroundColor: owned ? rune.color : AppTheme.cardBorder,
                      side: BorderSide(color: owned ? rune.color : AppTheme.cardBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    child: Text('Socket → ${item.name}  (🌀 ${rune.dustCost})',
                        style: TextStyle(fontSize: 9,
                            color: owned ? rune.color : AppTheme.cardBorder)),
                  ),
                )).toList(),
              );
            }),
          ],
        ],
      ),
    );
  }
}
