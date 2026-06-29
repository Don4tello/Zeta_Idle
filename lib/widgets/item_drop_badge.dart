import 'package:flutter/material.dart';
import '../models/equipment.dart';
import '../services/game_state.dart';
import 'item_sprites.dart';

class ItemDropBadge extends StatefulWidget {
  const ItemDropBadge({super.key, required this.item});
  final EquipmentItem item;

  @override
  State<ItemDropBadge> createState() => _ItemDropBadgeState();
}

class _ItemDropBadgeState extends State<ItemDropBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  );
  late final Animation<double> _scale = CurvedAnimation(
      parent: _ctrl, curve: Curves.elasticOut);
  late final Animation<double> _fade = CurvedAnimation(
      parent: _ctrl, curve: Curves.easeIn);
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.25),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item      = widget.item;
    final color     = item.rarityColor;
    final isSpecial = item.rarity == ItemRarity.legendary || item.rarity == ItemRarity.set;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isSpecial ? 0.15 : 0.10),
              border: Border.all(
                  color: color.withValues(alpha: 0.85),
                  width: isSpecial ? 2.0 : 1.5),
              borderRadius: BorderRadius.circular(4),
              boxShadow: isSpecial
                  ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 16, spreadRadius: 2)]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ItemSprite(
                  slot: item.slot,
                  rarity: item.rarity,
                  size: 52,
                  setColor: item.rarity == ItemRarity.set ? color : null,
                ),
                const SizedBox(height: 10),
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.rarityLabel.toUpperCase()}  •  ${item.slot.label.toUpperCase()}  •  ${item.requirementLabel}',
                  style: TextStyle(
                      fontSize: 11,
                      color: color.withValues(alpha: 0.75),
                      letterSpacing: 1),
                ),
                if (item.bonuses.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    item.bonuses.take(2).map((b) => '+${b.value} ${b.stat.shortLabel}').join('  '),
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
                Builder(builder: (ctx) {
                  final game = GameStateProvider.of(ctx);
                  final current = game.inventory.equipped[item.slot];
                  if (current == null) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text('No item equipped — direct upgrade!',
                          style: TextStyle(fontSize: 10, color: Color(0xFF55cc88))),
                    );
                  }
                  final diffs = <Widget>[];
                  for (final b in item.bonuses) {
                    final oldVal = current.bonuses
                        .where((ob) => ob.stat == b.stat)
                        .fold(0, (sum, ob) => sum + ob.value);
                    final diff = b.value - oldVal;
                    if (diff != 0) {
                      diffs.add(Text(
                        '${diff > 0 ? '+' : ''}$diff ${b.stat.shortLabel}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: diff > 0 ? const Color(0xFF55cc88) : const Color(0xFFff5555),
                        ),
                      ));
                    }
                  }
                  for (final ob in current.bonuses) {
                    final hasNew = item.bonuses.any((b) => b.stat == ob.stat);
                    if (!hasNew) {
                      diffs.add(Text(
                        '-${ob.value} ${ob.stat.shortLabel}',
                        style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.bold,
                          color: Color(0xFFff5555)),
                      ));
                    }
                  }
                  if (diffs.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('vs ${current.name}: ',
                            style: TextStyle(fontSize: 9,
                                color: Colors.white.withValues(alpha: 0.4))),
                        ...diffs.expand((w) => [w, const SizedBox(width: 6)]),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
