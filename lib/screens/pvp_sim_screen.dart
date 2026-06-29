import 'package:flutter/material.dart';
import '../models/pvp.dart';
import '../models/dnd_class.dart';

class PvpSimScreen extends StatefulWidget {
  const PvpSimScreen({super.key});

  @override
  State<PvpSimScreen> createState() => _PvpSimScreenState();
}

class _PvpSimScreenState extends State<PvpSimScreen> {
  PvpTournamentResult? _result;
  bool _loading = false;

  Future<void> _run() async {
    setState(() { _loading = true; _result = null; });
    final r = await runPvpTournament(battles: 100);
    setState(() { _loading = false; _result = r; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        title: const Text('PvP Sim Lab', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFFFFD700)),
                SizedBox(height: 16),
                Text('Simulating 13,200 battles…',
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
              ],
            ))
          : _result == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.science, size: 64, color: Color(0xFFFFD700)),
                      const SizedBox(height: 16),
                      const Text(
                        'Run a full round-robin tournament\nacross all 12 classes at max level.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: _run,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('RUN SIMULATION'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          minimumSize: const Size(200, 56),
                        ),
                      ),
                    ],
                  ),
                )
              : _ResultView(result: _result!, onRerun: _run),
    );
  }
}

// ─── Result view ────────────────────────────────────────────────────────────

class _ResultView extends StatelessWidget {
  const _ResultView({required this.result, required this.onRerun});
  final PvpTournamentResult result;
  final VoidCallback onRerun;

  @override
  Widget build(BuildContext context) {
    final ranked = _ranked();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TierList(ranked: ranked),
          const SizedBox(height: 24),
          _Heatmap(result: result, ranked: ranked),
          const SizedBox(height: 24),
          _BalanceFindings(),
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton.icon(
              onPressed: onRerun,
              icon: const Icon(Icons.refresh),
              label: const Text('RE-RUN'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A2A4A),
                foregroundColor: Colors.white,
                minimumSize: const Size(160, 48),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<({DndClass cls, double avg, int rank})> _ranked() {
    final classes = result.classes;
    final n = classes.length;
    final avgs = <(DndClass, double)>[];
    for (int i = 0; i < n; i++) {
      double sum = 0;
      for (int j = 0; j < n; j++) {
        if (i != j) sum += result.matrix[i][j];
      }
      avgs.add((classes[i], sum / (n - 1)));
    }
    avgs.sort((a, b) => b.$2.compareTo(a.$2));
    return [
      for (int i = 0; i < avgs.length; i++)
        (cls: avgs[i].$1, avg: avgs[i].$2, rank: i + 1),
    ];
  }
}

// ─── Tier List ───────────────────────────────────────────────────────────────

class _TierList extends StatelessWidget {
  const _TierList({required this.ranked});
  final List<({DndClass cls, double avg, int rank})> ranked;

  @override
  Widget build(BuildContext context) {
    final tiers = _buildTiers();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('TIER LIST',
            style: TextStyle(color: Colors.white, fontSize: 18,
                fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        for (final t in tiers)
          _TierRow(label: t.$1, color: t.$2, entries: t.$3),
      ],
    );
  }

  List<(String, Color, List<({DndClass cls, double avg, int rank})>)> _buildTiers() {
    final s = ranked.where((e) => e.avg >= 0.62).toList();
    final a = ranked.where((e) => e.avg >= 0.52 && e.avg < 0.62).toList();
    final b = ranked.where((e) => e.avg >= 0.46 && e.avg < 0.52).toList();
    final c = ranked.where((e) => e.avg >= 0.40 && e.avg < 0.46).toList();
    final d = ranked.where((e) => e.avg < 0.40).toList();
    return [
      ('S', const Color(0xFFFF4444), s),
      ('A', const Color(0xFFFF8C00), a),
      ('B', const Color(0xFFFFD700), b),
      ('C', const Color(0xFF4CAF50), c),
      ('D', const Color(0xFF90CAF9), d),
    ];
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({required this.label, required this.color, required this.entries});
  final String label;
  final Color color;
  final List<({DndClass cls, double avg, int rank})> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              border: Border.all(color: color, width: 2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(label,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: entries.map((e) {
                final pct = (e.avg * 100).toStringAsFixed(1);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_icon(e.cls), style: const TextStyle(fontSize: 20)),
                      Text(_name(e.cls),
                          style: const TextStyle(color: Colors.white, fontSize: 12,
                              fontWeight: FontWeight.bold)),
                      Text('$pct%',
                          style: TextStyle(color: color, fontSize: 11)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _icon(DndClass c) => switch (c) {
    DndClass.barbarian => '⚔️',
    DndClass.bard      => '🎵',
    DndClass.cleric    => '✝️',
    DndClass.druid     => '🌿',
    DndClass.fighter   => '🛡️',
    DndClass.monk      => '👊',
    DndClass.paladin   => '⚜️',
    DndClass.ranger    => '🏹',
    DndClass.rogue     => '🗡️',
    DndClass.sorcerer  => '🔮',
    DndClass.warlock   => '👁️',
    DndClass.wizard    => '📚',
  };

  String _name(DndClass c) => switch (c) {
    DndClass.barbarian => 'Barbarian',
    DndClass.bard      => 'Bard',
    DndClass.cleric    => 'Cleric',
    DndClass.druid     => 'Druid',
    DndClass.fighter   => 'Fighter',
    DndClass.monk      => 'Monk',
    DndClass.paladin   => 'Paladin',
    DndClass.ranger    => 'Ranger',
    DndClass.rogue     => 'Rogue',
    DndClass.sorcerer  => 'Sorcerer',
    DndClass.warlock   => 'Warlock',
    DndClass.wizard    => 'Wizard',
  };
}

// ─── 12×12 Heatmap ──────────────────────────────────────────────────────────

class _Heatmap extends StatelessWidget {
  const _Heatmap({required this.result, required this.ranked});
  final PvpTournamentResult result;
  final List<({DndClass cls, double avg, int rank})> ranked;

  @override
  Widget build(BuildContext context) {
    final orderedClasses = ranked.map((e) => e.cls).toList();
    final n = orderedClasses.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('WIN RATE MATRIX',
            style: TextStyle(color: Colors.white, fontSize: 18,
                fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 4),
        const Text('Row beats Column (%)  ·  sorted by overall win rate',
            style: TextStyle(color: Colors.white38, fontSize: 12)),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  const SizedBox(width: 72),
                  for (final cls in orderedClasses)
                    _HeatCell(
                      label: _abbr(cls),
                      bg: const Color(0xFF1A1A2E),
                      textColor: Colors.white54,
                      size: 44,
                    ),
                ],
              ),
              // Data rows
              for (int r = 0; r < n; r++)
                Row(
                  children: [
                    SizedBox(
                      width: 72,
                      height: 44,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(_abbr(orderedClasses[r]),
                            style: const TextStyle(color: Colors.white70,
                                fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    for (int c = 0; c < n; c++)
                      _heatCell(orderedClasses[r], orderedClasses[c], r, c),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _heatCell(DndClass rowCls, DndClass colCls, int r, int c) {
    if (r == c) {
      return _HeatCell(label: '—', bg: const Color(0xFF0D0D1A),
          textColor: Colors.white24, size: 44);
    }
    final ri = result.classes.indexOf(rowCls);
    final ci = result.classes.indexOf(colCls);
    final v = result.matrix[ri][ci];
    final pct = (v * 100).round();
    final bg = _heatColor(v);
    final fg = v > 0.62 || v < 0.38 ? Colors.white : Colors.black;
    return _HeatCell(label: '$pct', bg: bg, textColor: fg, size: 44);
  }

  Color _heatColor(double v) {
    if (v >= 0.75) return const Color(0xFFB71C1C);
    if (v >= 0.62) return const Color(0xFFE53935);
    if (v >= 0.55) return const Color(0xFFEF9A9A);
    if (v >= 0.45) return const Color(0xFF37474F);
    if (v >= 0.38) return const Color(0xFF81C784);
    return const Color(0xFF1B5E20);
  }

  String _abbr(DndClass c) => switch (c) {
    DndClass.barbarian => 'BAR',
    DndClass.bard      => 'BRD',
    DndClass.cleric    => 'CLR',
    DndClass.druid     => 'DRU',
    DndClass.fighter   => 'FGT',
    DndClass.monk      => 'MNK',
    DndClass.paladin   => 'PAL',
    DndClass.ranger    => 'RNG',
    DndClass.rogue     => 'ROG',
    DndClass.sorcerer  => 'SOR',
    DndClass.warlock   => 'WLK',
    DndClass.wizard    => 'WIZ',
  };
}

class _HeatCell extends StatelessWidget {
  const _HeatCell({required this.label, required this.bg,
      required this.textColor, required this.size});
  final String label;
  final Color bg, textColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      margin: const EdgeInsets.all(1),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(3)),
      child: Text(label,
          style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

// ─── Balance Findings ────────────────────────────────────────────────────────

class _BalanceFindings extends StatelessWidget {
  const _BalanceFindings();

  @override
  Widget build(BuildContext context) {
    const findings = [
      (
        icon: '⚡',
        title: 'Stun 2 duration nerfed → Stun 1',
        detail: 'Eight abilities (Glacial Titan, Absolute Zero, Blizzard Volley, '
            'Sundering Verdict, Paralyzing Toxin, Power Shatter, Paralytic Curse, '
            'Stasis Field) applied a 2-round stun on a 3-round cooldown — effectively '
            'locking the opponent out for 2/3 of all turns. Reduced to 1-round stun.',
      ),
      (
        icon: '⚔️',
        title: 'Weaken M10a bonus capped: +10 → +5',
        detail: 'Nine classes had a weaken ability that stacked to 50% damage reduction '
            'at max milestones (30 base + 10 + 10). Combined with Vulnerable this dropped '
            'attacker damage to ~35% normal. M10a bonus reduced from +10 to +5, '
            'capping weaken at 45% solo or 65% combined.',
      ),
      (
        icon: '💚',
        title: 'Direct heal M10a bonus: +8/+6 → +4/+3',
        detail: 'Cleric and Paladin Greater Restoration healed 42% of max HP at full '
            'milestones (~115 HP on a typical build). Bard and Druid Nature\'s Bounty / '
            'Rousing Song were at 36%. Cut the M10a milestone bonus by half to bring '
            'single-cast healing below the average damage-per-round threshold.',
      ),
      (
        icon: '🔆',
        title: 'Aura M15a bonus halved: +6/+5 → +3',
        detail: 'Cleric Divine Presence and Paladin Sacred Aura both reached 22 HP/round '
            'for 8 rounds at max milestones. Bard Epic Composition reached 20 HP/round. '
            'Stacked with direct heals this created near-unkillable sustain in long fights. '
            'M15a aura bonus reduced from +6 (or +5) to +3 across all four healer classes.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('BALANCE CHANGES APPLIED',
            style: TextStyle(color: Colors.white, fontSize: 18,
                fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        for (final f in findings)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(f.icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(f.title,
                      style: const TextStyle(color: Colors.white,
                          fontSize: 15, fontWeight: FontWeight.bold))),
                ]),
                const SizedBox(height: 8),
                Text(f.detail,
                    style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.5)),
              ],
            ),
          ),
      ],
    );
  }
}
