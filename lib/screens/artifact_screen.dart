import 'package:flutter/material.dart';
import '../models/artifact.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

class ArtifactScreen extends StatefulWidget {
  const ArtifactScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  State<ArtifactScreen> createState() => _ArtifactScreenState();
}

class _ArtifactScreenState extends State<ArtifactScreen> {
  String? _selectedArtifactId; // artifact held for placement
  int?    _highlightedCell;    // cell tapped while no selection

  static const _gridCols = 9;
  static const _gridRows = 9;

  void _onCellTap(GameState game, int cell) {
    final isUnlocked = cell < game.unlockedArtifactCells;
    if (!isUnlocked) return;

    final occupant = game.artifactGrid[cell];

    if (_selectedArtifactId != null) {
      // Place selected artifact into this cell
      game.placeArtifact(cell, _selectedArtifactId!);
      setState(() { _selectedArtifactId = null; _highlightedCell = null; });
    } else if (occupant != null) {
      // Tap occupied cell → remove artifact
      setState(() {
        game.removeArtifactFromGrid(cell);
      });
    } else {
      setState(() => _highlightedCell = _highlightedCell == cell ? null : cell);
    }
  }

  void _onArtifactTap(GameState game, String id) {
    if (!game.ownedArtifacts.contains(id)) return;
    if (game.isArtifactEquipped(id)) {
      // Remove from grid
      final cell = game.artifactGrid.entries
          .firstWhere((e) => e.value == id, orElse: () => const MapEntry(-1, ''))
          .key;
      if (cell >= 0) game.removeArtifactFromGrid(cell);
      setState(() { _selectedArtifactId = null; });
    } else if (_highlightedCell != null) {
      // Place directly into highlighted cell
      game.placeArtifact(_highlightedCell!, id);
      setState(() { _selectedArtifactId = null; _highlightedCell = null; });
    } else {
      setState(() => _selectedArtifactId = _selectedArtifactId == id ? null : id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);

    final header = Container(
      color: const Color(0xFF2A2623),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(children: [
        Text('ARTIFACT GRID',
            style: AppTheme.pixelHeading(fontSize: 12, letterSpacing: 2)),
        const Spacer(),
        Text('${game.unlockedArtifactCells}/81 cells',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
        const SizedBox(width: 10),
        _MythrilBadge(mythril: game.mythril),
      ]),
    );

    final body = Column(children: [
      header,
      if (_selectedArtifactId != null)
        _PlacementHint(name: Artifact.byId(_selectedArtifactId)?.name ?? ''),
      Expanded(
        flex: 5,
        child: _buildGrid(game),
      ),
      _buildUnlockBar(game),
      const Divider(height: 1, color: Color(0xFF2a2a3a)),
      Expanded(
        flex: 4,
        child: _buildCollection(game),
      ),
    ]);

    if (widget.embedded) {
      return Container(color: const Color(0xFF1B1A17), child: body);
    }
    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('ARTIFACTS',
            style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: _MythrilBadge(mythril: game.mythril),
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _buildGrid(GameState game) {
    return LayoutBuilder(builder: (ctx, bc) {
      // Fit the entire 9×9 grid in the available space without scrolling.
      final byWidth  = (bc.maxWidth  - 16) / _gridCols;
      final byHeight = bc.maxHeight.isFinite
          ? (bc.maxHeight - 16) / _gridRows
          : byWidth;
      final cellSize = (byWidth < byHeight ? byWidth : byHeight).floorToDouble();
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Wrap(
          spacing: 2,
          runSpacing: 2,
          children: List.generate(_gridCols * _gridRows, (i) {
            return _GridCell(
              index: i,
              size: cellSize - 2,
              artifact: Artifact.byId(game.artifactGrid[i]),
              isUnlocked: i < game.unlockedArtifactCells,
              isHighlighted: _highlightedCell == i,
              isSelected: _selectedArtifactId != null &&
                  game.artifactGrid[i] == _selectedArtifactId,
              isTargetable: _selectedArtifactId != null && i < game.unlockedArtifactCells,
              onTap: () => _onCellTap(game, i),
            );
          }),
        ),
      );
    });
  }

  Widget _buildUnlockBar(GameState game) {
    final cost = game.artifactCellUnlockCost;
    final canAfford = cost > 0 && game.mythril >= cost;
    final atMax = game.unlockedArtifactCells >= 81;
    return Container(
      color: const Color(0xFF1a1a2a),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: game.unlockedArtifactCells / 81,
              minHeight: 6,
              backgroundColor: const Color(0xFF2a2a3a),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF9966ff)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        if (!atMax)
          TextButton(
            onPressed: canAfford ? () => game.buyUnlockArtifactCell() : null,
            style: TextButton.styleFrom(
              side: BorderSide(
                  color: canAfford ? const Color(0xFF9966ff) : AppTheme.cardBorder),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('⬡ $cost',
                  style: TextStyle(
                      fontSize: 11,
                      color: canAfford ? const Color(0xFF9966ff) : AppTheme.cardBorder)),
              const SizedBox(width: 4),
              Text('UNLOCK',
                  style: AppTheme.pixelHeading(
                      fontSize: 10,
                      color: canAfford ? const Color(0xFF9966ff) : AppTheme.cardBorder)),
            ]),
          )
        else
          Text('GRID COMPLETE',
              style: AppTheme.pixelHeading(fontSize: 10, color: const Color(0xFF9966ff))),
      ]),
    );
  }

  Widget _buildCollection(GameState game) {
    final all = Artifact.all;
    return ListView(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text('COLLECTION',
              style: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 2)),
        ),
        Text(
          'Tap an artifact to select it, then tap an unlocked grid cell to place it.  '
          'Tap a placed artifact to remove it from the grid.',
          style: const TextStyle(
              fontSize: 10, color: AppTheme.textMuted, height: 1.4),
        ),
        const SizedBox(height: 8),
        ...all.map((art) {
          final owned    = game.ownedArtifacts.contains(art.id);
          final equipped = game.isArtifactEquipped(art.id);
          final canBuy   = game.mythril >= art.mythrilCost;
          final selected = _selectedArtifactId == art.id;
          return _ArtifactRow(
            artifact: art,
            owned: owned,
            equipped: equipped,
            selected: selected,
            canBuy: canBuy,
            onTap: owned
                ? () => _onArtifactTap(game, art.id)
                : (canBuy ? () { game.buyArtifact(art); setState(() {}); } : null),
          );
        }),
      ],
    );
  }
}

// ── Grid cell ──────────────────────────────────────────────────────────────────

class _GridCell extends StatelessWidget {
  const _GridCell({
    required this.index,
    required this.size,
    required this.isUnlocked,
    required this.onTap,
    this.artifact,
    this.isHighlighted = false,
    this.isSelected = false,
    this.isTargetable = false,
  });

  final int       index;
  final double    size;
  final bool      isUnlocked;
  final Artifact? artifact;
  final bool      isHighlighted;
  final bool      isSelected;
  final bool      isTargetable;
  final VoidCallback onTap;

  static const _slotColors = {
    ArtifactSlot.ring:    Color(0xFFffcc44),
    ArtifactSlot.amulet:  Color(0xFF66aaff),
    ArtifactSlot.trinket: Color(0xFF88cc44),
  };

  @override
  Widget build(BuildContext context) {
    if (!isUnlocked) {
      return SizedBox(
        width: size, height: size,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF12121a),
            border: Border.all(color: const Color(0xFF1a1a28), width: 0.5),
          ),
          child: size > 28
              ? const Center(
                  child: Icon(Icons.lock_outline, size: 10,
                      color: Color(0xFF2a2a40)))
              : null,
        ),
      );
    }

    final slotColor = artifact != null
        ? (_slotColors[artifact!.slot] ?? const Color(0xFF9966ff))
        : null;
    final borderColor = isTargetable
        ? const Color(0xFF9966ff)
        : isHighlighted
            ? const Color(0xFF9966ff)
            : artifact != null
                ? (slotColor!.withValues(alpha: 0.6))
                : const Color(0xFF2a2a40);
    final bgColor = isTargetable
        ? const Color(0xFF9966ff).withValues(alpha: 0.08)
        : isHighlighted
            ? const Color(0xFF9966ff).withValues(alpha: 0.12)
            : artifact != null
                ? slotColor!.withValues(alpha: 0.07)
                : const Color(0xFF14141e);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size, height: size,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: artifact != null ? 1.0 : 0.5),
          ),
          child: artifact != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(artifact!.slot.icon,
                          style: TextStyle(fontSize: size * 0.38)),
                      if (size > 30)
                        Text(artifact!.name,
                            style: TextStyle(
                                fontSize: 7,
                                color: slotColor,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                    ],
                  ),
                )
              : isTargetable || isHighlighted
                  ? Center(
                      child: Icon(Icons.add,
                          size: size * 0.35, color: const Color(0xFF9966ff)),
                    )
                  : null,
        ),
      ),
    );
  }
}

// ── Placement hint banner ─────────────────────────────────────────────────────

class _PlacementHint extends StatelessWidget {
  const _PlacementHint({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF9966ff).withValues(alpha: 0.15),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(children: [
        const Icon(Icons.touch_app, color: Color(0xFF9966ff), size: 14),
        const SizedBox(width: 6),
        Expanded(
          child: Text('Tap a grid cell to place "$name"',
              style: const TextStyle(color: Color(0xFF9966ff), fontSize: 12)),
        ),
        const Text('tap again to cancel',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
      ]),
    );
  }
}

// ── Artifact row (collection list) ────────────────────────────────────────────

class _ArtifactRow extends StatelessWidget {
  const _ArtifactRow({
    required this.artifact,
    required this.owned,
    required this.equipped,
    required this.selected,
    required this.canBuy,
    this.onTap,
  });

  final Artifact  artifact;
  final bool      owned;
  final bool      equipped;
  final bool      selected;
  final bool      canBuy;
  final VoidCallback? onTap;

  static const _slotColors = {
    ArtifactSlot.ring:    Color(0xFFffcc44),
    ArtifactSlot.amulet:  Color(0xFF66aaff),
    ArtifactSlot.trinket: Color(0xFF88cc44),
  };

  @override
  Widget build(BuildContext context) {
    final c = _slotColors[artifact.slot] ?? AppTheme.accentGold;
    final borderColor = selected
        ? const Color(0xFF9966ff)
        : equipped
            ? c.withValues(alpha: 0.7)
            : owned
                ? c.withValues(alpha: 0.3)
                : AppTheme.cardBorder;
    final bgColor = selected
        ? const Color(0xFF9966ff).withValues(alpha: 0.1)
        : equipped
            ? c.withValues(alpha: 0.06)
            : const Color(0xFF1c1a18);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor,
              width: selected || equipped ? 1.5 : 1.0),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(children: [
          Text(artifact.slot.icon, style: const TextStyle(fontSize: 19)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(artifact.name,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: owned ? c : Colors.white38)),
                const SizedBox(height: 2),
                Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  children: _statChips(artifact, owned ? c : Colors.white24),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (!owned)
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text('⬡',
                  style: TextStyle(
                      fontSize: 12,
                      color: canBuy
                          ? const Color(0xFF9966ff)
                          : AppTheme.cardBorder)),
              const SizedBox(width: 3),
              Text('${artifact.mythrilCost}',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: canBuy
                          ? const Color(0xFF9966ff)
                          : AppTheme.cardBorder)),
            ])
          else if (equipped)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.15),
                border: Border.all(color: c),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text('ON', style: TextStyle(
                  fontSize: 9, color: c, fontWeight: FontWeight.bold)),
            )
          else
            Icon(selected ? Icons.touch_app : Icons.add_circle_outline,
                size: 18,
                color: selected ? const Color(0xFF9966ff) : AppTheme.textMuted),
        ]),
      ),
    );
  }

  List<Widget> _statChips(Artifact a, Color c) {
    final chips = <Widget>[];
    void add(int v, String label) {
      if (v == 0) return;
      chips.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.1),
          border: Border.all(color: c.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text('${v > 0 ? "+" : ""}$v $label',
            style: TextStyle(fontSize: 9, color: c, fontWeight: FontWeight.bold)),
      ));
    }
    add(a.attackBonus, 'ATK');
    add(a.damageBonus, 'DMG');
    add(a.acBonus,     'AC');
    add(a.hpPct,       'HP%');
    add(a.shardPct,    '◆%');
    add(a.goldPct,     'Gold%');
    add(a.xpPct,       'XP%');
    return chips;
  }
}

// ── Mythril badge ─────────────────────────────────────────────────────────────

class _MythrilBadge extends StatelessWidget {
  const _MythrilBadge({required this.mythril});
  final int mythril;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF6644cc).withValues(alpha: 0.2),
        border: Border.all(color: const Color(0xFF9966ff).withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Text('⬡', style: TextStyle(fontSize: 11, color: Color(0xFF9966ff))),
        const SizedBox(width: 4),
        Text('$mythril',
            style: AppTheme.pixelHeading(
                fontSize: 13, color: const Color(0xFF9966ff))),
      ]),
    );
  }
}
