import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TierSelector extends StatelessWidget {
  const TierSelector({
    super.key,
    required this.selectedTier,
    required this.maxUnlocked,
    required this.highestCleared,
    required this.onTierChange,
    this.scalingLabel,
    this.maxTiers = 10,
  });

  final int selectedTier;
  final int maxUnlocked;
  final int highestCleared;
  final void Function(int) onTierChange;
  final String? scalingLabel;
  final int maxTiers;

  static String levelRange(int tier) {
    final lo = (tier - 1) * 10 + 1;
    final hi = tier * 10;
    return 'Lv $lo–$hi';
  }

  @override
  Widget build(BuildContext context) {
    final scaling = scalingLabel ?? levelRange(selectedTier);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF231F1B),
        border: Border.all(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('TIER $selectedTier', style: AppTheme.pixelHeading(
                fontSize: 11, letterSpacing: 2, color: AppTheme.accentGold)),
            const SizedBox(width: 8),
            Text(scaling,
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
            const Spacer(),
            if (selectedTier <= highestCleared)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF44cc88).withValues(alpha: 0.12),
                  border: Border.all(color: const Color(0xFF44cc88).withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('CLEARED', style: AppTheme.pixelHeading(
                    fontSize: 8, color: const Color(0xFF44cc88))),
              ),
          ]),
          const SizedBox(height: 10),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: maxUnlocked.clamp(1, maxTiers),
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final tier = i + 1;
                final isSelected = tier == selectedTier;
                final isCleared  = tier <= highestCleared;
                final isLocked   = tier > maxUnlocked;
                return GestureDetector(
                  onTap: isLocked ? null : () => onTierChange(tier),
                  child: Container(
                    width: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.accentGold
                            : isCleared
                                ? const Color(0xFF44cc88).withValues(alpha: 0.5)
                                : AppTheme.cardBorder,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: AppTheme.accentGold.withValues(alpha: 0.25),
                          blurRadius: 8,
                        ),
                      ] : null,
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Tier image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.asset(
                            'assets/images/tier_$tier.png',
                            width: 64,
                            height: 72,
                            fit: BoxFit.cover,
                            opacity: AlwaysStoppedAnimation(
                                isLocked ? 0.2 : isSelected ? 1.0 : 0.6),
                            errorBuilder: (_, __, ___) => Container(
                              width: 64, height: 72,
                              color: isSelected
                                  ? AppTheme.accentGold.withValues(alpha: 0.15)
                                  : const Color(0xFF1A1715),
                              child: Center(child: Text('T$tier',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? AppTheme.accentGold
                                        : AppTheme.textMuted,
                                  ))),
                            ),
                          ),
                        ),
                        // Dark gradient at bottom for text
                        Positioned(
                          left: 0, right: 0, bottom: 0,
                          child: Container(
                            height: 24,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(5)),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.8),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Tier label
                        Positioned(
                          left: 0, right: 0, bottom: 3,
                          child: Text('T$tier',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? AppTheme.accentGold
                                    : isCleared
                                        ? const Color(0xFF44cc88)
                                        : Colors.white54,
                              )),
                        ),
                        // Cleared checkmark
                        if (isCleared)
                          Positioned(
                            top: 2, right: 4,
                            child: Container(
                              width: 14, height: 14,
                              decoration: const BoxDecoration(
                                color: Color(0xFF44cc88),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check,
                                  size: 9, color: Colors.black87),
                            ),
                          ),
                        // Lock icon
                        if (isLocked)
                          const Center(
                            child: Icon(Icons.lock_outline,
                                size: 18, color: Colors.white24),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
