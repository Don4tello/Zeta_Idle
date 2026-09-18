import 'dart:async';
import 'package:flutter/material.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

/// A compact objective beacon shown top-right during combat. It stays hidden and
/// slides in for a few seconds whenever the current enemy's bestiary kills or the
/// active adventure quest's progress ticks up — so you can see you're making
/// progress (and killing the right enemy) without leaving the fight.
class CombatObjectiveBeacon extends StatefulWidget {
  const CombatObjectiveBeacon({
    super.key,
    required this.game,
    required this.enemyId,
    required this.enemyName,
  });

  final GameState game;
  final String enemyId;
  final String enemyName;

  @override
  State<CombatObjectiveBeacon> createState() => _CombatObjectiveBeaconState();
}

class _CombatObjectiveBeaconState extends State<CombatObjectiveBeacon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  Timer? _hideTimer;
  int _lastSeq = 0;
  // Which rows to show for the current reveal.
  bool _showBestiary = false;
  bool _showQuest = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _reveal() {
    if (!mounted) return;
    _ctrl.forward();
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) _ctrl.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.game,
      builder: (context, _) {
        final game = widget.game;

        // Reveal ONLY on an actual kill (game.beaconSeq ticks in _battleVictory).
        // Uses the captured payload of the enemy you just vanquished — so it never
        // shows at the START of a battle, only after a count is earned.
        if (game.beaconSeq != _lastSeq) {
          _lastSeq = game.beaconSeq;
          _showBestiary = true; // a kill always ticks the bestiary count
          _showQuest = game.beaconQuestTicked;
          WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
        }

        return IgnorePointer(
          child: FadeTransition(
            opacity: _ctrl,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.25, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut)),
              child: Container(
                width: 176,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xCC17150E),
                  border: Border.all(
                      color: AppTheme.accentGold.withValues(alpha: 0.6)),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bestiary — the enemy you just vanquished and its new count.
                    if (_showBestiary)
                      _BeaconRow(
                        icon: '📖',
                        label: game.beaconEnemyName,
                        current: game.beaconKills,
                        target: game.beaconKillTarget, // null → maxed
                        color: const Color(0xFF66aaff),
                      ),
                    // Quest — only when the quest actually advanced on this kill.
                    if (_showQuest) ...[
                      if (_showBestiary) const SizedBox(height: 5),
                      _BeaconRow(
                        icon: '⚔',
                        label: game.beaconQuestTitle,
                        current: game.beaconQuestProg,
                        target: game.beaconQuestTarget,
                        color: AppTheme.accentGold,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BeaconRow extends StatelessWidget {
  const _BeaconRow({
    required this.icon,
    required this.label,
    required this.current,
    required this.target,
    required this.color,
  });
  final String icon;
  final String label;
  final int current;
  final int? target; // null → maxed
  final Color color;

  @override
  Widget build(BuildContext context) {
    final maxed = target == null;
    final frac = maxed
        ? 1.0
        : (target! <= 0 ? 0.0 : (current / target!).clamp(0.0, 1.0));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(children: [
          Text(icon, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 4),
          Text(maxed ? 'MAX' : '$current/${target!}',
              style: TextStyle(
                  fontSize: 9, color: color, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: frac,
            minHeight: 3,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
