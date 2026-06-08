import 'package:flutter/material.dart';
import '../models/equipment.dart';

class ItemDropBadge extends StatelessWidget {
  const ItemDropBadge({super.key, required this.item});
  final EquipmentItem item;

  @override
  Widget build(BuildContext context) {
    final color = item.rarityColor;
    final isSpecial = item.rarity == ItemRarity.legendary || item.rarity == ItemRarity.set;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isSpecial ? 0.15 : 0.10),
        border: Border.all(color: color.withValues(alpha: 0.8), width: isSpecial ? 2 : 1),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            Text(item.slot.icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Text(
              item.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 1,
              ),
            ),
          ]),
          const SizedBox(height: 4),
          Text(
            '${item.rarityLabel.toUpperCase()}  •  ${item.slot.label.toUpperCase()}',
            style: TextStyle(
              fontSize: 10,
              color: color.withValues(alpha: 0.75),
              letterSpacing: 1,
            ),
          ),
          if (item.bonuses.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              item.bonuses.take(2).map((b) => '+${b.value} ${b.stat.shortLabel}').join('  '),
              style: const TextStyle(fontSize: 10, color: Colors.white54),
            ),
          ],
        ],
      ),
    );
  }
}
