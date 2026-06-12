import 'dart:async';
import 'package:flutter/material.dart';
import '../models/expedition.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

class ExpeditionScreen extends StatefulWidget {
  const ExpeditionScreen({super.key});
  @override
  State<ExpeditionScreen> createState() => _ExpeditionScreenState();
}

class _ExpeditionScreenState extends State<ExpeditionScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final active = game.activeExpedition;

    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('EXPEDITIONS', style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF231F1B),
              border: Border.all(color: AppTheme.cardBorder),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Send your hero on a timed expedition to gather resources. '
              'Only one expedition can run at a time. Rewards scale with hero level.',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.4),
            ),
          ),

          if (active != null)
            _ActiveExpeditionCard(expedition: active, game: game,
                onCollected: () => setState(() {}))
          else
            _ExpeditionPicker(game: game, onStarted: () => setState(() {})),
        ],
      ),
    );
  }
}

// ── Active expedition ─────────────────────────────────────────────────────────

class _ActiveExpeditionCard extends StatelessWidget {
  const _ActiveExpeditionCard({
    required this.expedition,
    required this.game,
    required this.onCollected,
  });
  final Expedition expedition;
  final GameState game;
  final VoidCallback onCollected;

  @override
  Widget build(BuildContext context) {
    final done     = expedition.isComplete;
    final progress = expedition.progress;
    final color    = expedition.type.color;
    final rem      = expedition.remaining;
    final preview  = game.previewExpeditionRewards(expedition.type, expedition.duration);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        border: Border.all(color: done ? color : color.withValues(alpha: 0.4), width: done ? 2 : 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(expedition.type.icon, style: const TextStyle(fontSize: 23)),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(expedition.type.label.toUpperCase(),
                  style: AppTheme.pixelHeading(fontSize: 13, color: color, letterSpacing: 1)),
              Text(expedition.duration.label,
                  style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.6))),
            ]),
            const Spacer(),
            if (done)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  border: Border.all(color: color),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text('COMPLETE', style: AppTheme.pixelHeading(fontSize: 10, color: color)),
              )
            else
              Text(_fmtDuration(rem),
                  style: AppTheme.pixelHeading(fontSize: 14, color: color)),
          ]),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 12),
          // Preview rewards
          Wrap(spacing: 12, children: [
            for (final e in preview.entries)
              Text('${_rewardIcon(e.key)} ${e.value} ${e.key}',
                  style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8))),
          ]),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: done ? color.withValues(alpha: 0.2) : Colors.transparent,
                foregroundColor: done ? color : Colors.white24,
                side: BorderSide(color: done ? color : Colors.white24),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              onPressed: done ? () {
                final rewards = game.collectExpedition();
                onCollected();
                if (context.mounted) _showRewards(context, rewards, color);
              } : null,
              child: Text(done ? 'COLLECT REWARDS' : 'IN PROGRESS...',
                  style: AppTheme.pixelHeading(fontSize: 12,
                      color: done ? color : Colors.white24)),
            ),
          ),
        ],
      ),
    );
  }

  void _showRewards(BuildContext context, Map<String, int> rewards, Color color) {
    final lines = rewards.entries.map((e) => '${_rewardIcon(e.key)} ${e.value} ${e.key}').join('\n');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B1814),
        title: Text('Expedition Complete!',
            style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        content: Text(lines,
            style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.6)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: color.withValues(alpha: 0.2),
                foregroundColor: color, side: BorderSide(color: color)),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('GREAT'),
          ),
        ],
      ),
    );
  }

  String _fmtDuration(Duration d) {
    if (d.inHours >= 1) return '${d.inHours}h ${d.inMinutes.remainder(60).toString().padLeft(2, '0')}m';
    return '${d.inMinutes}m ${d.inSeconds.remainder(60).toString().padLeft(2, '0')}s';
  }

  String _rewardIcon(String key) => switch (key) {
    'gold'    => '💰',
    'shards'  => '◆',
    'essence' => '✦',
    _         => '•',
  };
}

// ── Expedition picker ─────────────────────────────────────────────────────────

class _ExpeditionPicker extends StatefulWidget {
  const _ExpeditionPicker({required this.game, required this.onStarted});
  final GameState game;
  final VoidCallback onStarted;
  @override
  State<_ExpeditionPicker> createState() => _ExpeditionPickerState();
}

class _ExpeditionPickerState extends State<_ExpeditionPicker> {
  ExpeditionType _selectedType = ExpeditionType.goldRun;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SELECT TYPE', style: AppTheme.pixelHeading(
            fontSize: 10, color: AppTheme.textMuted, letterSpacing: 1)),
        const SizedBox(height: 8),
        // Type cards
        ...ExpeditionType.values.map((type) {
          final selected = _selectedType == type;
          final color = type.color;
          return GestureDetector(
            onTap: () => setState(() => _selectedType = type),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? color.withValues(alpha: 0.10) : const Color(0xFF231F1B),
                border: Border.all(
                    color: selected ? color : color.withValues(alpha: 0.25),
                    width: selected ? 1.5 : 1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(children: [
                Text(type.icon, style: const TextStyle(fontSize: 19)),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(type.label,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                          color: selected ? color : Colors.white60)),
                  Text('Rewards: ${type.rewardLabel}',
                      style: TextStyle(fontSize: 11,
                          color: selected ? color.withValues(alpha: 0.7) : Colors.white30)),
                ]),
                if (selected) ...[
                  const Spacer(),
                  Icon(Icons.check_circle, color: color, size: 16),
                ],
              ]),
            ),
          );
        }),
        const SizedBox(height: 16),
        Text('SELECT DURATION', style: AppTheme.pixelHeading(
            fontSize: 10, color: AppTheme.textMuted, letterSpacing: 1)),
        const SizedBox(height: 8),
        // Duration buttons
        Row(children: ExpeditionDuration.values.map((dur) {
          final color = _selectedType.color;
          final preview = widget.game.previewExpeditionRewards(_selectedType, dur);
          final previewStr = preview.entries
              .map((e) => '${e.value} ${e.key}').join(' + ');
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _DurationButton(
                duration: dur,
                color: color,
                previewStr: previewStr,
                onTap: () {
                  widget.game.startExpedition(_selectedType, dur);
                  widget.onStarted();
                },
              ),
            ),
          );
        }).toList()),
      ],
    );
  }
}

class _DurationButton extends StatelessWidget {
  const _DurationButton({
    required this.duration,
    required this.color,
    required this.previewStr,
    required this.onTap,
  });
  final ExpeditionDuration duration;
  final Color color;
  final String previewStr;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(children: [
          Text(duration.label,
              style: AppTheme.pixelHeading(fontSize: 12, color: color)),
          const SizedBox(height: 6),
          Text(previewStr,
              style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.7)),
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text('START', style: AppTheme.pixelHeading(fontSize: 9,
              color: color.withValues(alpha: 0.8), letterSpacing: 1)),
        ]),
      ),
    );
  }
}
