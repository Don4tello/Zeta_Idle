import 'package:flutter/material.dart';
import '../models/equipment.dart';
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
                  '${item.rarityLabel.toUpperCase()}  •  ${item.slot.label.toUpperCase()}',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
