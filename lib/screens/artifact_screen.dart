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
  String? _selectedArtifactId;
  int?    _highlightedCell;

  static const _gridCols = 3;
  static const _gridRows = 3;
  static const _maxCells = 9;

  void _onCellTap(GameState game, int cell) {
    if (cell >= game.unlockedArtifactCells) return;
    final occupant = game.artifactGrid[cell];
    if (_selectedArtifactId != null) {
      game.placeArtifact(cell, _selectedArtifactId!);
      setState(() { _selectedArtifactId = null; _highlightedCell = null; });
    } else if (occupant != null) {
      setState(() { game.removeArtifactFromGrid(cell); });
    } else {
      setState(() => _highlightedCell = _highlightedCell == cell ? null : cell);
    }
  }

  void _onArtifactTap(GameState game, String uid) {
    if (game.isArtifactEquipped(uid)) {
      final cell = game.artifactGrid.entries
          .firstWhere((e) => e.value == uid, orElse: () => const MapEntry(-1, ''))
          .key;
      if (cell >= 0) game.removeArtifactFromGrid(cell);
      setState(() { _selectedArtifactId = null; });
    } else if (_highlightedCell != null) {
      game.placeArtifact(_highlightedCell!, uid);
      setState(() { _selectedArtifactId = null; _highlightedCell = null; });
    } else {
      setState(() => _selectedArtifactId = _selectedArtifactId == uid ? null : uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final selectedName = _selectedArtifactId != null
        ? game.artifactByUid(_selectedArtifactId)?.name ?? ''
        : '';

    final header = Container(
      color: const Color(0xFF2A2623),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(children: [
        Text('ARTIFACT TABLE',
            style: AppTheme.pixelHeading(fontSize: 12, letterSpacing: 2)),
        const Spacer(),
        Text('${game.unlockedArtifactCells.clamp(0, _maxCells)}/$_maxCells slots',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
        const SizedBox(width: 10),
        _MythrilBadge(mythril: game.mythril),
      ]),
    );

    final body = Column(children: [
      header,
      if (_selectedArtifactId != null) _PlacementHint(name: selectedName),
      Expanded(
        child: SingleChildScrollView(
          child: Column(children: [
            _buildGrid(game),
            _buildTableBonuses(game),
            const SizedBox(height: 8),
            _buildCollection(game),
          ]),
        ),
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
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // Medieval wooden table surface
        color: const Color(0xFF3a2818),
        border: Border.all(color: const Color(0xFF5a3a20), width: 3),
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(color: Color(0x44000000), blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: CustomPaint(
        painter: _TableGrainPainter(),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _gridCols,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.0,
            ),
            itemCount: _maxCells,
            itemBuilder: (ctx, i) => _GridCell(
              index: i,
              artifact: game.artifactByUid(game.artifactGrid[i]),
              isUnlocked: i < game.unlockedArtifactCells.clamp(0, _maxCells),
              isHighlighted: _highlightedCell == i,
              isSelected: _selectedArtifactId != null &&
                  game.artifactGrid[i] == _selectedArtifactId,
              isTargetable: _selectedArtifactId != null &&
                  i < game.unlockedArtifactCells.clamp(0, _maxCells),
              onTap: () => _onCellTap(game, i),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableBonuses(GameState game) {
    final bonuses = <(String, String, int)>[
      ('⚔', 'PWR', game.artifactPowerBonus),
      ('🛡', 'ARM', game.artifactAcBonus),
      ('❤', 'HP%', game.artifactHpPct),
      ('💰', 'Gold%', game.artifactGoldPct),
      ('⚡', 'XP%', game.artifactXpPct),
      ('◆', 'Shard%', game.artifactShardPct),
    ];
    final active = bonuses.where((b) => b.$3 > 0).toList();
    if (active.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text('Place artifacts on the table to gain bonuses.',
            style: const TextStyle(fontSize: 10, color: AppTheme.textMuted), textAlign: TextAlign.center),
      );
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        border: Border.all(color: const Color(0xFF9966ff).withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TABLE BONUSES', style: AppTheme.pixelHeading(
              fontSize: 9, letterSpacing: 2, color: const Color(0xFF9966ff))),
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: active.map((b) => Text(
              '${b.$1} +${b.$3}${b.$2.contains('%') ? '' : ''} ${b.$2}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF9966ff), fontWeight: FontWeight.bold),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCollection(GameState game) {
    final owned = game.ownedArtifacts;

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      children: [
        // ── Collection ───────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(children: [
            Text('COLLECTION',
                style: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 2)),
            const SizedBox(width: 8),
            Text('(${owned.length})',
                style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
          ]),
        ),
        if (owned.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'No artifacts found yet. Complete Dungeons, Boss Rush, and Campaign bosses to find them.',
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.4),
            ),
          )
        else ...[
          Text(
            'Tap to select, then tap a grid cell to equip. Spend Mythril to upgrade.',
            style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 8),
          ...owned.map((art) => _ArtifactRow(
            artifact: art,
            equipped: game.isArtifactEquipped(art.uid),
            selected: _selectedArtifactId == art.uid,
            mythril: game.mythril,
            upgradeCost: game.artifactUpgradeCost(art),
            onTap: () => _onArtifactTap(game, art.uid),
            onUpgrade: () { game.upgradeArtifact(art.uid); game.audioService.playUiConfirm(); setState(() {}); },
          )),
        ],
      ],
    );
  }
}

// ── Grid cell ─────────────────────────────────────────────────────────────────

class _GridCell extends StatelessWidget {
  const _GridCell({
    required this.index,
    required this.isUnlocked,
    required this.onTap,
    this.artifact,
    this.isHighlighted = false,
    this.isSelected = false,
    this.isTargetable = false,
  });

  final int       index;
  final bool      isUnlocked;
  final Artifact? artifact;
  final bool      isHighlighted;
  final bool      isSelected;
  final bool      isTargetable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, bc) {
      final size = bc.maxWidth;

      if (!isUnlocked) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1a1208),
            border: Border.all(color: const Color(0xFF2a1e10), width: 1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Center(child: Icon(Icons.lock_outline, size: 18, color: Color(0xFF3a2818))),
        );
      }

      final rc = artifact?.rarity.color;
      final hasArt = artifact != null;
      final active = isTargetable || isHighlighted;
      final accentColor = active ? const Color(0xFF9966ff) : (rc ?? const Color(0xFF4a3828));

      return GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            // Stone pedestal when filled, dark cloth when empty
            color: hasArt
                ? const Color(0xFF2a2420)
                : active
                    ? const Color(0xFF2a2040)
                    : const Color(0xFF1e1810),
            border: Border.all(
              color: accentColor.withValues(alpha: hasArt ? 0.8 : 0.4),
              width: hasArt || active ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: hasArt ? [
              BoxShadow(color: rc!.withValues(alpha: 0.3), blurRadius: 8, spreadRadius: 1),
            ] : active ? [
              const BoxShadow(color: Color(0x449966ff), blurRadius: 6),
            ] : null,
          ),
          child: hasArt
              ? _buildFilled(size)
              : active
                  ? Center(child: Icon(Icons.add_circle_outline, size: size * 0.35, color: const Color(0xFF9966ff)))
                  : Center(child: Text('·', style: TextStyle(fontSize: size * 0.3, color: const Color(0xFF3a2818)))),
        ),
      );
    });
  }

  Widget _buildFilled(double size) {
    final typeColor = artifact!.type.color;
    final rarityColor = artifact!.rarity.color;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ArtifactIcon(type: artifact!.type, color: typeColor, size: size * 0.50, rarity: artifact!.rarity),
          if (size > 30)
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                artifact!.base.name,
                style: TextStyle(
                    fontSize: (size * 0.15).clamp(5.0, 8.0),
                    color: rarityColor,
                    fontWeight: FontWeight.bold,
                    height: 1.1),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

}

// ── Placement hint ────────────────────────────────────────────────────────────

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

// ── Artifact row ──────────────────────────────────────────────────────────────

class _ArtifactRow extends StatelessWidget {
  const _ArtifactRow({
    required this.artifact,
    required this.equipped,
    required this.selected,
    required this.mythril,
    required this.upgradeCost,
    required this.onTap,
    required this.onUpgrade,
  });

  final Artifact  artifact;
  final bool      equipped;
  final bool      selected;
  final int       mythril;
  final int       upgradeCost;
  final VoidCallback onTap;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final rc = artifact.rarity.color;
    final tc = artifact.type.color;

    final borderColor = selected
        ? const Color(0xFF9966ff)
        : equipped
            ? rc.withValues(alpha: 0.85)
            : rc.withValues(alpha: 0.35);
    final bgColor = selected
        ? const Color(0xFF9966ff).withValues(alpha: 0.10)
        : equipped
            ? rc.withValues(alpha: 0.07)
            : const Color(0xFF1c1a18);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: selected || equipped ? 1.5 : 1.0),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(children: [
          // Custom type icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tc.withValues(alpha: 0.10),
              border: Border.all(color: tc.withValues(alpha: 0.30)),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Center(
              child: ArtifactIcon(type: artifact.type, color: tc, size: 24, rarity: artifact.rarity),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full name in rarity color
                Text(artifact.name,
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold, color: rc)),
                const SizedBox(height: 3),
                // Rarity + type + drop level badges
                Row(children: [
                  _badge(artifact.rarity.label, rc),
                  const SizedBox(width: 4),
                  _badge(artifact.type.label, tc),
                  const SizedBox(width: 4),
                  _badge('Lv ${artifact.dropLevel}', AppTheme.textMuted),
                ]),
                const SizedBox(height: 3),
                // Stat chips
                Wrap(
                  spacing: 4, runSpacing: 2,
                  children: _statChips(artifact, rc),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (equipped)
                _badge('ON', rc, thick: true)
              else
                Icon(selected ? Icons.touch_app : Icons.add_circle_outline,
                    size: 18,
                    color: selected ? const Color(0xFF9966ff) : AppTheme.textMuted),
              if (artifact.dropLevel < 50) ...[
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: mythril >= upgradeCost ? onUpgrade : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                    decoration: BoxDecoration(
                      color: mythril >= upgradeCost
                          ? const Color(0xFF9966ff).withValues(alpha: 0.15)
                          : Colors.transparent,
                      border: Border.all(
                        color: mythril >= upgradeCost
                            ? const Color(0xFF9966ff).withValues(alpha: 0.6)
                            : AppTheme.cardBorder,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('⬡',
                          style: TextStyle(
                              fontSize: 9,
                              color: mythril >= upgradeCost
                                  ? const Color(0xFFcc99ff)
                                  : AppTheme.textMuted)),
                      const SizedBox(width: 2),
                      Text('$upgradeCost ▲',
                          style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: mythril >= upgradeCost
                                  ? const Color(0xFFcc99ff)
                                  : AppTheme.textMuted)),
                    ]),
                  ),
                ),
              ],
            ],
          ),
        ]),
      ),
    );
  }

  Widget _badge(String text, Color c, {bool thick = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        border: Border.all(color: c.withValues(alpha: thick ? 0.8 : 0.45)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 8, color: c, fontWeight: FontWeight.bold)),
    );
  }

  List<Widget> _statChips(Artifact a, Color c) {
    final chips = <Widget>[];
    void add(int v, String label) {
      if (v == 0) return;
      chips.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.10),
          border: Border.all(color: c.withValues(alpha: 0.40)),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text('${v > 0 ? "+" : ""}$v $label',
            style: TextStyle(fontSize: 9, color: c, fontWeight: FontWeight.bold)),
      ));
    }
    add(a.powerBonus, 'PWR');
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

// ── Medieval table wood grain background ─────────────────────────────────────

class _TableGrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..style = PaintingStyle.fill;
    // Horizontal wood planks
    for (int i = 0; i < 8; i++) {
      final y = i * size.height / 7;
      final shade = (i % 2 == 0) ? 0xFF2e1e10 : 0xFF3a2818;
      p.color = Color(shade);
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, size.height / 7), p);
    }
    // Grain lines
    p.color = const Color(0xFF4a3420);
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 0.5;
    for (int i = 1; i < 7; i++) {
      final y = i * size.height / 7;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
    // Knot marks
    p.style = PaintingStyle.fill;
    p.color = const Color(0xFF251808);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.3), 3, p);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.65), 2.5, p);
    // Corner metal brackets
    _drawBracket(canvas, 0, 0, 1, 1);
    _drawBracket(canvas, size.width, 0, -1, 1);
    _drawBracket(canvas, 0, size.height, 1, -1);
    _drawBracket(canvas, size.width, size.height, -1, -1);
  }

  void _drawBracket(Canvas canvas, double x, double y, double dx, double dy) {
    final p = Paint()
      ..color = const Color(0xFF666058)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawLine(Offset(x, y), Offset(x + dx * 14, y), p);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy * 14), p);
    // Rivet
    p.style = PaintingStyle.fill;
    p.color = const Color(0xFF888078);
    canvas.drawCircle(Offset(x + dx * 5, y + dy * 5), 2, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
