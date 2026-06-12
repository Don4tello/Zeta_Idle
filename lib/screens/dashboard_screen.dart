import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/combat_log_panel.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/stats_grid_panel.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DashboardScreen
//
// Single-screen character-sheet view with three zones:
//   1. DashboardHeader   — sprite, name, HP/XP bars, resources
//   2. StatsGridPanel    — 6 D&D ability scores (tappable for upgrades)
//   3. CombatLogPanel    — scrollable, colour-coded battle log
//
// Layout is responsive via LayoutBuilder:
//   narrow  (<= 640 px)  → vertical stack, log fills remaining height
//   wide    (> 640 px)   → left column (header + stats) | right column (log)
// ─────────────────────────────────────────────────────────────────────────────

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    this.onBackToSelect,
    this.embedded = false,
  });

  final VoidCallback? onBackToSelect;

  /// When true, returns only the body (no Scaffold/AppBar) for embedding
  /// inside HeroHubScreen.
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final body = LayoutBuilder(
      builder: (context, constraints) =>
          constraints.maxWidth > 640
              ? const _WideLayout()
              : const _NarrowLayout(),
    );
    if (embedded) return body;
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: const Text('CHARACTER SHEET'),
        actions: [
          if (onBackToSelect != null)
            TextButton(
              onPressed: onBackToSelect,
              child: Text(
                'CHANGE CHARACTER',
                style: AppTheme.pixelHeading(
                    fontSize: 10,
                    color: AppTheme.textMuted,
                    letterSpacing: 1),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: body,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Narrow layout  — portrait / small window
// ─────────────────────────────────────────────────────────────────────────────

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Zone 1 — character header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: const DashboardHeader()
                .animate()
                .fadeIn(duration: 280.ms)
                .slideY(begin: -0.05, duration: 280.ms, curve: Curves.easeOut),
          ),
          const SizedBox(height: 10),

          // Zone 2 — stats grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: const StatsGridPanel()
                .animate(delay: 70.ms)
                .fadeIn(duration: 280.ms)
                .slideY(begin: 0.05, duration: 280.ms, curve: Curves.easeOut),
          ),
          const SizedBox(height: 10),

          // Zone 3 — combat log (fixed height so it's usable inside scroll)
          SizedBox(
            height: 220,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: const CombatLogPanel()
                  .animate(delay: 140.ms)
                  .fadeIn(duration: 280.ms),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Wide layout  — landscape / large window
// ─────────────────────────────────────────────────────────────────────────────

class _WideLayout extends StatelessWidget {
  const _WideLayout();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left: header + stats
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const DashboardHeader()
                    .animate()
                    .fadeIn(duration: 280.ms)
                    .slideX(begin: -0.05, duration: 280.ms, curve: Curves.easeOut),
                const SizedBox(height: 14),
                const StatsGridPanel()
                    .animate(delay: 70.ms)
                    .fadeIn(duration: 280.ms)
                    .slideX(begin: -0.05, duration: 280.ms, curve: Curves.easeOut),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Right: combat log fills full height
          Expanded(
            flex: 4,
            child: const CombatLogPanel()
                .animate(delay: 100.ms)
                .fadeIn(duration: 280.ms)
                .slideX(begin: 0.05, duration: 280.ms, curve: Curves.easeOut),
          ),
        ],
      ),
    );
  }
}
