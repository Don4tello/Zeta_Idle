import 'package:flutter/material.dart';
import '../models/rune.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

class RuneScreen extends StatelessWidget {
  const RuneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);

    return DefaultTabController(
      length: RuneSlot.values.length,
      child: Scaffold(
        backgroundColor: const Color(0xFF0a0e27),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1a1f3a),
          title: Text('RUNE FORGE',
              style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 2)),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: _DustBadge(dust: game.runeDust),
            ),
          ],
          bottom: TabBar(
            indicatorColor: AppTheme.accentGold,
            labelColor: AppTheme.accentGold,
            unselectedLabelColor: AppTheme.textMuted,
            tabs: RuneSlot.values.map((s) => Tab(
              child: Text('${s.icon} ${s.label.toUpperCase()}',
                  style: const TextStyle(fontSize: 9)),
            )).toList(),
          ),
        ),
        body: Column(
          children: [
            _ActiveRuneBar(game: game),
            Expanded(
              child: TabBarView(
                children: RuneSlot.values.map((slot) =>
                    _SlotTab(game: game, slot: slot)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DustBadge extends StatelessWidget {
  const _DustBadge({required this.dust});
  final int dust;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF884422).withValues(alpha: 0.2),
        border: Border.all(color: const Color(0xFFcc8844).withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Text('✦', style: TextStyle(fontSize: 10, color: Color(0xFFcc8844))),
        const SizedBox(width: 4),
        Text('$dust Dust',
            style: AppTheme.pixelHeading(
                fontSize: 11, color: const Color(0xFFcc8844))),
      ]),
    );
  }
}

class _ActiveRuneBar extends StatelessWidget {
  const _ActiveRuneBar({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0e1225),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: RuneSlot.values.map((slot) {
          final active = game.activeRune(slot);
          final def = active?.def;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: def != null
                    ? def.color.withValues(alpha: 0.08)
                    : Colors.transparent,
                border: Border.all(
                    color: def != null
                        ? def.color.withValues(alpha: 0.5)
                        : AppTheme.cardBorder.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(slot.icon,
                    style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 2),
                if (def != null && active != null) ...[
                  Text(def.name,
                      style: TextStyle(fontSize: 7, color: def.color),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text('${active.minutesLeft}m',
                      style: const TextStyle(
                          fontSize: 8, color: Colors.white54)),
                ] else
                  Text('Empty',
                      style: const TextStyle(
                          fontSize: 8, color: AppTheme.textMuted)),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SlotTab extends StatelessWidget {
  const _SlotTab({required this.game, required this.slot});
  final GameState game;
  final RuneSlot slot;

  @override
  Widget build(BuildContext context) {
    final runes = RuneDef.all.where((r) => r.slot == slot).toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            border: Border.all(color: AppTheme.cardBorder),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'Runes are crafted with Rune Dust, earned by disenchanting '
            'Common items. Each rune activates for a limited time — '
            'only one rune per slot can be active.',
            style: TextStyle(
                fontSize: 10, color: AppTheme.textMuted, height: 1.5),
          ),
        ),
        ...runes.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RuneCard(game: game, def: r),
            )),
      ],
    );
  }
}

class _RuneCard extends StatelessWidget {
  const _RuneCard({required this.game, required this.def});
  final GameState game;
  final RuneDef def;

  @override
  Widget build(BuildContext context) {
    final active   = game.activeRune(def.slot);
    final isActive = active?.defId == def.id && !(active?.isExpired ?? true);
    final canCraft = game.runeDust >= def.dustCost;
    final stockpile = game.runeStockpile(def.id);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive
            ? def.color.withValues(alpha: 0.06)
            : const Color(0xFF0e1225),
        border: Border.all(
          color: isActive
              ? def.color.withValues(alpha: 0.7)
              : AppTheme.cardBorder,
          width: isActive ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(def.icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(def.name,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isActive ? def.color : Colors.white70)),
                  Text(def.description,
                      style: const TextStyle(
                          fontSize: 10, color: AppTheme.textMuted)),
                ],
              ),
            ),
            if (stockpile > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: def.color.withValues(alpha: 0.12),
                  border: Border.all(
                      color: def.color.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text('×$stockpile',
                    style: TextStyle(
                        fontSize: 10,
                        color: def.color,
                        fontWeight: FontWeight.bold)),
              ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            // Craft button
            _RuneBtn(
              label: '✦${def.dustCost} CRAFT',
              color: canCraft ? const Color(0xFFcc8844) : AppTheme.cardBorder,
              onTap: canCraft ? () => game.craftRune(def.id) : null,
            ),
            const SizedBox(width: 8),
            // Activate button
            if (stockpile > 0 && !isActive)
              _RuneBtn(
                label: 'ACTIVATE',
                color: def.color,
                onTap: () => game.activateRune(def.id),
              ),
            if (isActive && active != null) ...[
              const SizedBox(width: 4),
              Text('${active.minutesLeft}m left',
                  style: TextStyle(
                      fontSize: 10, color: def.color)),
            ],
          ]),
        ],
      ),
    );
  }
}

class _RuneBtn extends StatelessWidget {
  const _RuneBtn({required this.label, required this.color, this.onTap});
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: color,
        disabledForegroundColor: AppTheme.cardBorder,
        side: BorderSide(color: onTap != null ? color : AppTheme.cardBorder),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label,
          style: AppTheme.pixelHeading(
              fontSize: 10,
              letterSpacing: 1,
              color: onTap != null ? color : AppTheme.cardBorder)),
    );
  }
}
