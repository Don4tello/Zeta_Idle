import 'package:flutter/material.dart';
import '../models/zone_affix.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AffixChipRow
//
// Renders the active Corruption affixes for the current fight as a compact
// horizontal chip strip.  Sits just below the stage/arena badge in the battle
// screens so the player always knows what modifiers are in play.
//
// • T1 affixes — purple chips
// • T2 mutation affixes — amber chips (visually "hotter" / more extreme)
// • Hovering / tapping a chip shows a Tooltip with the full description.
// • If [affixes] is empty the widget collapses to zero size.
// ─────────────────────────────────────────────────────────────────────────────

class AffixChipRow extends StatelessWidget {
  const AffixChipRow({super.key, required this.affixes});

  final List<ZoneAffix> affixes;

  @override
  Widget build(BuildContext context) {
    if (affixes.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: affixes.map((a) => _AffixChip(affix: a)).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AffixChip
// ─────────────────────────────────────────────────────────────────────────────

class _AffixChip extends StatelessWidget {
  const _AffixChip({required this.affix});

  final ZoneAffix affix;

  static const _t1Color = Color(0xFFc080ff); // purple
  static const _t2Color = Color(0xFFffaa44); // amber — mutated / severe

  Color get _color => affix.tier == 2 ? _t2Color : _t1Color;

  void _showDetail(BuildContext context) {
    final color = _color;
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e),
            border: Border.all(color: color, width: 1.5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(affix.tier == 2 ? Icons.whatshot : Icons.warning_rounded,
                    size: 16, color: color),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    affix.displayName.toUpperCase(),
                    style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold,
                      color: color, letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('TIER ${affix.tier}',
                      style: TextStyle(fontSize: 10, color: color)),
                ),
              ]),
              const SizedBox(height: 12),
              Text(affix.description,
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textLight, height: 1.5)),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('CLOSE',
                      style: TextStyle(fontSize: 12, color: color)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          border: Border.all(color: color.withValues(alpha: 0.65)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              affix.tier == 2 ? Icons.whatshot : Icons.warning_rounded,
              size: 11,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              affix.displayName.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                color: color,
                letterSpacing: 0.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.info_outline, size: 10, color: color.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }
}
