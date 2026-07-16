import 'dart:math';
import 'package:flutter/material.dart';
import '../models/rebirth_boon.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

class RebirthFlowScreen extends StatefulWidget {
  const RebirthFlowScreen({super.key});

  @override
  State<RebirthFlowScreen> createState() => _RebirthFlowScreenState();
}

class _RebirthFlowScreenState extends State<RebirthFlowScreen> {
  RebirthBoon? _selectedBoon;
  RebirthChallenge _challenge = RebirthChallenge.none;
  late final List<RebirthBoon> _boonChoices;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    final shuffled = List<RebirthBoon>.from(RebirthBoon.all)..shuffle(rng);
    _boonChoices = shuffled.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final soulsPreview = game.soulsEarnedPreview(challenge: _challenge, boon: _selectedBoon);
    final nextLevel    = game.prestigeLevel + 1;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0B10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1020),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white54),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '✦  REBIRTH  LV$nextLevel',
          style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2, color: const Color(0xFFffaaff)),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _RunRecapCard(game: game),
          const SizedBox(height: 16),
          _SoulTallyCard(game: game, challenge: _challenge, boon: _selectedBoon, soulsPreview: soulsPreview),
          const SizedBox(height: 16),
          _BoonPickerSection(
            choices: _boonChoices,
            selected: _selectedBoon,
            onSelect: (b) => setState(() => _selectedBoon = b),
          ),
          const SizedBox(height: 16),
          _ChallengePicker(
            selected: _challenge,
            onSelect: (c) => setState(() => _challenge = c),
          ),
          const SizedBox(height: 24),
          _RebirthButton(
            game: game,
            boon: _selectedBoon,
            challenge: _challenge,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Run Recap ──────────────────────────────────────────────────────────────────

class _RunRecapCard extends StatelessWidget {
  const _RunRecapCard({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final stage = game.campaignStageIndex + 1;
    return _panel(
      header: 'RUN RECAP',
      headerColor: const Color(0xFF3a1a6a),
      child: Column(
        children: [
          _recapRow('Campaign Stage', 'Stage $stage'),
          _recapRow('Hero Level',     'Lv ${game.hero.level}'),
          _recapRow('Total Kills',    _fmt(game.totalKills)),
          _recapRow('Gold Earned',    _fmt(game.totalGoldEarned)),
          _recapRow('Damage Dealt',   _fmt(game.totalDamageDealt)),
          _recapRow('Dungeon Clears', '${game.dungeonClears}'),
          _recapRow('Boss Rush Tier', game.bossRushHighestTier > 0 ? 'Tier ${game.bossRushHighestTier}' : '—'),
          _recapRow('Gauntlet Best',  game.gauntletHighScore > 0 ? _fmt(game.gauntletHighScore) : '—'),
        ],
      ),
    );
  }

  String _fmt(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000)    return '${(v / 1000).toStringAsFixed(1)}K';
    return '$v';
  }

  Widget _recapRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
        Text(value,  style: const TextStyle(color: Colors.white,  fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

// ── Soul Tally ─────────────────────────────────────────────────────────────────

class _SoulTallyCard extends StatelessWidget {
  const _SoulTallyCard({
    required this.game,
    required this.challenge,
    required this.boon,
    required this.soulsPreview,
  });
  final GameState game;
  final RebirthChallenge challenge;
  final RebirthBoon? boon;
  final int soulsPreview;

  @override
  Widget build(BuildContext context) {
    final base      = (game.campaignStageIndex / 5).floor().clamp(1, 200);
    final dungeon   = game.dungeonClears.clamp(0, 20);
    final bossRush  = game.bossRushHighestTier.clamp(0, 5);
    final gauntlet  = (game.gauntletHighScore / 10).floor().clamp(0, 10);
    final conduit   = game.prestigeSoulConduit;
    final boonBonus = boon?.effect == RebirthBoonEffect.bonusSouls ? 30 : 0;
    final chalBonus = challenge.bonusSouls;

    return _panel(
      header: 'SOUL TALLY',
      headerColor: const Color(0xFF1a2a5a),
      child: Column(
        children: [
          _tallyRow('Campaign stages', base,     const Color(0xFFaaccff)),
          if (dungeon   > 0) _tallyRow('Dungeon clears',    dungeon,   const Color(0xFF88ddcc)),
          if (bossRush  > 0) _tallyRow('Boss rush tiers',   bossRush,  const Color(0xFFffcc88)),
          if (gauntlet  > 0) _tallyRow('Gauntlet score',    gauntlet,  const Color(0xFFffaaaa)),
          if (conduit   > 0) _tallyRow('Soul Conduit node', conduit,   const Color(0xFFcc88ff)),
          if (boonBonus > 0) _tallyRow('Soul Surge boon',   boonBonus, const Color(0xFFffeeaa)),
          if (chalBonus > 0) _tallyRow('${challenge.label} challenge', chalBonus, const Color(0xFFff8888)),
          const Divider(color: Colors.white12, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL SOULS', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              Text('$soulsPreview ☠', style: const TextStyle(color: Color(0xFFffaaff), fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tallyRow(String label, int value, Color color) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: color.withValues(alpha: 0.85), fontSize: 12)),
        Text('+$value', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

// ── Boon Picker ───────────────────────────────────────────────────────────────

class _BoonPickerSection extends StatelessWidget {
  const _BoonPickerSection({
    required this.choices,
    required this.selected,
    required this.onSelect,
  });
  final List<RebirthBoon> choices;
  final RebirthBoon? selected;
  final ValueChanged<RebirthBoon?> onSelect;

  @override
  Widget build(BuildContext context) {
    return _panel(
      header: 'CHOOSE YOUR BOON  (optional)',
      headerColor: const Color(0xFF1a3a1a),
      child: Column(
        children: [
          const Text(
            'Pick one gift that carries over into your new life.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 10),
          ...choices.map((b) => _BoonCard(
            boon: b,
            isSelected: selected?.id == b.id,
            onTap: () => onSelect(selected?.id == b.id ? null : b),
          )),
        ],
      ),
    );
  }
}

class _BoonCard extends StatelessWidget {
  const _BoonCard({required this.boon, required this.isSelected, required this.onTap});
  final RebirthBoon boon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final border = isSelected
        ? Border.all(color: const Color(0xFFffdd88), width: 2)
        : Border.all(color: Colors.white12);
    final bg = isSelected ? const Color(0xFF2a2010) : const Color(0xFF181418);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bg, border: border, borderRadius: BorderRadius.circular(6)),
        child: Row(
          children: [
            Text(boon.icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(boon.name,    style: const TextStyle(color: Colors.white,  fontSize: 13, fontWeight: FontWeight.bold)),
                  Text(boon.tagline, style: const TextStyle(color: Color(0xFFffdd88), fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(boon.description, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFFffdd88), size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Challenge Picker ──────────────────────────────────────────────────────────

class _ChallengePicker extends StatelessWidget {
  const _ChallengePicker({required this.selected, required this.onSelect});
  final RebirthChallenge selected;
  final ValueChanged<RebirthChallenge> onSelect;

  static const _challenges = [
    RebirthChallenge.ruthless,
    RebirthChallenge.pauper,
    RebirthChallenge.ascetic,
  ];

  @override
  Widget build(BuildContext context) {
    return _panel(
      header: 'CHALLENGE REBIRTH  (optional)',
      headerColor: const Color(0xFF3a1010),
      child: Column(
        children: [
          const Text(
            'Accept a hardship for bonus souls.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 10),
          ..._challenges.map((c) => _ChallengeRow(
            challenge: c,
            isSelected: selected == c,
            onTap: () => onSelect(selected == c ? RebirthChallenge.none : c),
          )),
        ],
      ),
    );
  }
}

class _ChallengeRow extends StatelessWidget {
  const _ChallengeRow({required this.challenge, required this.isSelected, required this.onTap});
  final RebirthChallenge challenge;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final border = isSelected
        ? Border.all(color: const Color(0xFFff6666), width: 2)
        : Border.all(color: Colors.white12);
    final bg = isSelected ? const Color(0xFF2a1010) : const Color(0xFF181418);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: bg, border: border, borderRadius: BorderRadius.circular(6)),
        child: Row(
          children: [
            Text(challenge.icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(challenge.label,       style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  Text(challenge.description, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF3a0a0a),
                border: Border.all(color: const Color(0xFFff6666)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('+${challenge.bonusSouls} ☠', style: const TextStyle(color: Color(0xFFff9999), fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Rebirth Button ────────────────────────────────────────────────────────────

class _RebirthButton extends StatelessWidget {
  const _RebirthButton({required this.game, required this.boon, required this.challenge});
  final GameState game;
  final RebirthBoon? boon;
  final RebirthChallenge challenge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4a1060),
          foregroundColor: const Color(0xFFffaaff),
          side: const BorderSide(color: Color(0xFFcc44ff), width: 2),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        onPressed: () async {
          final expectedLevel = game.prestigeLevel + 1;
          final canP = game.canPrestige;
          Navigator.of(context).pop();
          if (!canP) return;
          await game.prestige(boon: boon, challenge: challenge);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: const Color(0xFF2a1040),
            content: Text(
              '✦ Rebirth Lv$expectedLevel complete!',
              style: const TextStyle(color: Color(0xFFffaaff)),
            ),
            duration: const Duration(seconds: 3),
          ));
        },
        child: Text(
          '✦  REBIRTH  (Lv${game.prestigeLevel + 1})',
          style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 2, color: const Color(0xFFffaaff)),
        ),
      ),
    );
  }
}

// ── Shared panel helper ────────────────────────────────────────────────────────

Widget _panel({required String header, required Color headerColor, required Widget child}) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF141018),
      border: Border.all(color: Colors.white12),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: headerColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
          ),
          child: Text(header, style: const TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        ),
        Padding(padding: const EdgeInsets.all(12), child: child),
      ],
    ),
  );
}
