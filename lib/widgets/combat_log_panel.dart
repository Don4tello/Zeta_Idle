import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CombatLogPanel
//
// Zone 3 of the character-sheet dashboard.  Reads game.battleLog from
// GameStateProvider and auto-scrolls to the latest entry whenever the log
// grows.  Entries are colour-coded by event type for fast scanning.
// ─────────────────────────────────────────────────────────────────────────────

class CombatLogPanel extends StatefulWidget {
  const CombatLogPanel({super.key});

  @override
  State<CombatLogPanel> createState() => _CombatLogPanelState();
}

class _CombatLogPanelState extends State<CombatLogPanel> {
  final _scroll = ScrollController();
  int _prevLength = 0;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final log = GameStateProvider.of(context).battleLog;

    if (log.length != _prevLength) {
      _prevLength = log.length;
      _scrollToBottom();
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF07091a),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header bar ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            color: AppTheme.cardBg,
            child: Row(
              children: [
                const Icon(Icons.history_edu_outlined,
                    size: 12, color: AppTheme.accentGold),
                const SizedBox(width: 8),
                Text('BATTLE LOG',
                    style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2)),
                const Spacer(),
                Text(
                  '${log.length} entries',
                  style: AppTheme.pixelHeading(
                      fontSize: 8,
                      letterSpacing: 1,
                      color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          Container(height: 1, color: AppTheme.cardBorder),

          // ── Log list ────────────────────────────────────────────────────
          Expanded(
            child: log.isEmpty
                ? Center(
                    child: Text(
                      'No battle activity yet.',
                      style: AppTheme.pixelHeading(
                          fontSize: 9,
                          color: AppTheme.textMuted,
                          letterSpacing: 1),
                    ),
                  )
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    itemCount: log.length,
                    itemBuilder: (context, i) {
                      final isLatest = i == log.length - 1;
                      return _LogEntry(
                          text: log[i], dimmed: !isLatest && i < log.length - 6);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LogEntry
// ─────────────────────────────────────────────────────────────────────────────

class _LogEntry extends StatelessWidget {
  const _LogEntry({required this.text, required this.dimmed});
  final String text;
  final bool dimmed;

  static Color _colorFor(String t) {
    final s = t.toLowerCase();
    if (s.contains('defeat') || s.contains('overwhelm') || s.contains('falls') ||
        s.contains('retreat') || s.contains('death spiral') || s.contains('bleeds') ||
        s.contains('explosion')) {
      return const Color(0xFFee4040);
    }
    if (s.contains('victory') || s.contains('defeated!') || s.contains('advances') ||
        s.contains('+') && (s.contains('gold') || s.contains('xp'))) {
      return const Color(0xFF66cc44);
    }
    if (s.contains('critical hit')) return const Color(0xFFffd700);
    if (s.contains('miss.')) return AppTheme.textMuted;
    if (s.contains('unbroken') || s.contains('shadow step') ||
        s.contains('momentum') || s.contains('blade flicker')) {
      return const Color(0xFF80d0ff);
    }
    if (s.contains('corruption') || s.contains('cursed') || s.contains('void') ||
        s.contains('iron skin') || s.contains('soul siphon') ||
        s.contains('shadow cloak') || s.contains('abyssal') ||
        s.contains('time fracture') || s.contains('diamond') ||
        s.contains('lifeleech')) {
      return const Color(0xFFc080ff);
    }
    if (s.contains('mercy token')) return const Color(0xFFffaa44);
    return AppTheme.textLight;
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(text);
    final alpha = dimmed ? 0.35 : 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '▸ ',
            style: TextStyle(
              color: AppTheme.accentGold.withValues(alpha: dimmed ? 0.2 : 0.7),
              fontSize: 10,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.sourceCodePro(
                fontSize: 10,
                color: color.withValues(alpha: alpha),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
