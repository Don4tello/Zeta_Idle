import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/upgrade.dart';
import '../theme/app_theme.dart';
import '../utils/format_number.dart';

class UpgradeTile extends StatefulWidget {
  const UpgradeTile({
    super.key,
    required this.upgrade,
    required this.gold,
    required this.onPurchase,
  });

  final Upgrade upgrade;
  final int gold;
  final VoidCallback onPurchase;

  @override
  State<UpgradeTile> createState() => _UpgradeTileState();
}

class _UpgradeTileState extends State<UpgradeTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hover = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );
  late final Animation<double> _hoverAnim =
      Tween<double>(begin: 0, end: 1).animate(_hover);

  @override
  void dispose() {
    _hover.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final affordable =
        widget.gold >= widget.upgrade.cost && !widget.upgrade.isMaxed;
    final maxed = widget.upgrade.isMaxed;
    final col = _typeColor(widget.upgrade.type);

    return MouseRegion(
      onEnter: (_) => _hover.forward(),
      onExit:  (_) => _hover.reverse(),
      child: AnimatedBuilder(
        animation: _hoverAnim,
        builder: (context, _) {
          final hv = _hoverAnim.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              border: Border(
                left: BorderSide(
                  color: maxed
                      ? const Color(0xFF3E5A3C)
                      : affordable
                          ? col.withValues(alpha: 0.7 + hv * 0.3)
                          : col.withValues(alpha: 0.35),
                  width: 3,
                ),
                top:    BorderSide(color: AppTheme.cardBorder),
                right:  BorderSide(color: AppTheme.cardBorder),
                bottom: BorderSide(color: AppTheme.cardBorder),
              ),
              boxShadow: affordable && !maxed
                  ? [
                      BoxShadow(
                        color: col.withValues(alpha: 0.08 + hv * 0.12),
                        blurRadius: 6 + hv * 6,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Stat chip
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: col.withValues(alpha: maxed ? 0.05 : 0.12),
                      border: Border.all(
                          color:
                              col.withValues(alpha: maxed ? 0.30 : 0.70)),
                    ),
                    child: Center(
                      child: Text(
                        widget.upgrade.type.label,
                        style: GoogleFonts.pixelifySans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: maxed
                              ? col.withValues(alpha: 0.40)
                              : col,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + level badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                widget.upgrade.name.toUpperCase(),
                                style: GoogleFonts.pixelifySans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: maxed
                                      ? AppTheme.textMuted
                                      : AppTheme.textLight,
                                  letterSpacing: 1,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: maxed
                                      ? const Color(0xFF3E5A3C)
                                      : widget.upgrade.level > 0
                                          ? col.withValues(alpha: 0.55)
                                          : AppTheme.cardBorder,
                                ),
                                color: maxed
                                    ? const Color(0xFF3E5A3C)
                                        .withValues(alpha: 0.25)
                                    : Colors.transparent,
                              ),
                              child: Text(
                                maxed
                                    ? 'MAXED'
                                    : 'Lv ${widget.upgrade.level}/${widget.upgrade.maxLevel}',
                                style: GoogleFonts.pixelifySans(
                                  fontSize: 10,
                                  letterSpacing: 1,
                                  color: maxed
                                      ? const Color(0xFF4a8020)
                                      : widget.upgrade.level > 0
                                          ? col
                                          : AppTheme.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),

                        // Description
                        Text(
                          widget.upgrade.description,
                          style: GoogleFonts.pixelifySans(
                            fontSize: 13,
                            color: widget.upgrade.level > 0
                                ? AppTheme.accentGold
                                : AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Cost + button row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Gold cost (hidden when maxed)
                            if (!maxed)
                              Row(
                                children: [
                                  Icon(
                                    Icons.monetization_on_outlined,
                                    size: 13,
                                    color: affordable
                                        ? AppTheme.accentGold
                                        : AppTheme.textMuted,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    fmtNum(widget.upgrade.cost),
                                    style: GoogleFonts.pixelifySans(
                                      fontSize: 12,
                                      color: affordable
                                          ? AppTheme.accentGold
                                          : AppTheme.textMuted,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'gold',
                                    style: GoogleFonts.pixelifySans(
                                      fontSize: 10,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              )
                            else
                              const SizedBox.shrink(),

                            // Upgrade / maxed button
                            if (!maxed)
                              GestureDetector(
                                onTap: affordable ? widget.onPurchase : null,
                                child: Container(
                                  constraints: const BoxConstraints(minHeight: 48, minWidth: 80),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: affordable
                                        ? col.withValues(alpha: 0.18 + hv * 0.10)
                                        : AppTheme.darkBg,
                                    border: Border.all(
                                      color: affordable
                                          ? col.withValues(alpha: 0.80 + hv * 0.20)
                                          : AppTheme.cardBorder,
                                    ),
                                  ),
                                  child: Text(
                                    'UPGRADE',
                                    style: GoogleFonts.pixelifySans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: affordable
                                          ? col
                                          : AppTheme.textMuted,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Container(
                                constraints: const BoxConstraints(minHeight: 48, minWidth: 80),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xFF3E5A3C)),
                                  color: const Color(0xFF3E5A3C)
                                      .withValues(alpha: 0.20),
                                ),
                                child: Text(
                                  'MAXED',
                                  style: GoogleFonts.pixelifySans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF4a8020),
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _typeColor(UpgradeType type) {
    switch (type) {
      case UpgradeType.strength:     return const Color(0xFFe05030);
      case UpgradeType.dexterity:    return const Color(0xFF40b060);
      case UpgradeType.constitution: return const Color(0xFF4488cc);
      case UpgradeType.intelligence: return AppTheme.accentGold;
      case UpgradeType.wisdom:       return const Color(0xFF9060c0);
      case UpgradeType.charisma:     return const Color(0xFFcc66aa);
      case UpgradeType.dualMastery:  return const Color(0xFFD580FF);
    }
  }
}
