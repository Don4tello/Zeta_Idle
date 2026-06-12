import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  Widget build(BuildContext context) {
    final color = _color;

    return Tooltip(
      message: affix.description,
      preferBelow: false,
      waitDuration: Duration.zero,
      textStyle: GoogleFonts.sourceCodePro(
        fontSize: 11,
        color: AppTheme.textLight,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        border: Border.all(color: color.withValues(alpha: 0.8)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          border: Border.all(color: color.withValues(alpha: 0.65)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              affix.tier == 2 ? Icons.whatshot : Icons.warning_rounded,
              size: 9,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              affix.displayName.toUpperCase(),
              style: GoogleFonts.pixelifySans(
                fontSize: 9,
                color: color,
                letterSpacing: 0.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
