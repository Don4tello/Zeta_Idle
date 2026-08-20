import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/gem.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/currency_info.dart';
import '../widgets/glow_tab_indicator.dart';
import 'inventory_screen.dart';
import 'forge_screen.dart';
import 'rune_screen.dart';
import 'artifact_screen.dart';
import 'armory_screen.dart';
import 'main_shell.dart';

class InventoryHubScreen extends StatefulWidget {
  const InventoryHubScreen({super.key});

  @override
  State<InventoryHubScreen> createState() => _InventoryHubScreenState();
}

class _InventoryHubScreenState extends State<InventoryHubScreen>
    with TickerProviderStateMixin {
  late TabController _ctrl;
  int _visibleCount = 0;

  // Returns which tab indices (0=GEAR, 1=GEMS, 2=FORGE, 3=RUNES, 4=ARTIFACTS) are unlocked.
  // Once a tab is unlocked it stays visible permanently.
  List<int> _unlockedIndices(GameState game) {
    final stage = game.effectiveUnlockStage;
    return [
      0, // GEAR always visible
      if (stage >= 50 || game.gemShards > 0 || game.gemBag.isNotEmpty) 1, // GEMS — aligns with PvP unlock
      if (stage >= 5 || game.inventory.bag.length >= 2) 2, // FORGE
      if (game.ownedRunes.isNotEmpty || game.runeDust > 0) 3, // RUNES — only after finding one
      if (stage >= 22 || game.ownedArtifacts.isNotEmpty) 4, // ARTIFACTS
      if (stage >= 28) 5, // ARMORY — legendary/set catalogue (reference)
    ];
  }

  void _rebuildController(int newCount) {
    final prev = _ctrl.index.clamp(0, newCount - 1);
    _ctrl.removeListener(_onTab);
    _ctrl.dispose();
    _ctrl = TabController(length: newCount, vsync: this)
      ..addListener(_onTab)
      ..index = prev;
    _visibleCount = newCount;
  }

  @override
  void initState() {
    super.initState();
    _ctrl = TabController(length: 1, vsync: this)..addListener(_onTab);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final game = GameStateProvider.of(context);
    final indices = _unlockedIndices(game);
    final newCount = indices.isEmpty ? 1 : indices.length;
    if (newCount != _visibleCount) _rebuildController(newCount);
  }

  void _onTab() {
    if (!_ctrl.indexIsChanging) setState(() {});
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onTab);
    _ctrl.dispose();
    super.dispose();
  }

  static const _labels  = ['GEAR', 'GEMS', 'FORGE', 'RUNES', 'ARTIFACTS', 'ARMORY'];
  static const _emojis  = ['🎒',  '💠',  '🔨',   '✦',    '🏺',        '🛡'];

  Widget _buildScreen(int allIdx, GameState game) => switch (allIdx) {
    0 => Column(children: [
          TutorialTip(tutorialKey: 'gear',
              text: 'Your first piece of gear has dropped! Equip it here to boost your stats.',
              game: game),
          const Expanded(child: InventoryScreen(embedded: true)),
        ]),
    1 => _GemCraftingTab(game: game),
    2 => Column(children: [
          TutorialTip(tutorialKey: 'forge',
              text: 'Combine two items of the same slot to craft a higher-rarity piece, or reforge stats.',
              game: game),
          const Expanded(child: ForgeScreen(embedded: true)),
        ]),
    3 => Column(children: [
          TutorialTip(tutorialKey: 'runes',
              text: 'Craft Runes for temporary combat buffs. Collect dust by salvaging gear.',
              game: game),
          const Expanded(child: RuneScreen(embedded: true)),
        ]),
    4 => Column(children: [
          TutorialTip(tutorialKey: 'artifacts',
              text: 'Place artifacts in the grid for permanent passive bonuses.',
              game: game),
          const Expanded(child: ArtifactScreen(embedded: true)),
        ]),
    5 => const ArmoryScreen(embedded: true), // legendary/set catalogue (reference)
    _ => const SizedBox.shrink(),
  };

  @override
  Widget build(BuildContext context) {
    final game    = GameStateProvider.of(context);
    final indices = _unlockedIndices(game);

    if (indices.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.darkBg,
        appBar: AppBar(
          title: Text('INVENTORY',
              style: AppTheme.pixelHeading(fontSize: 15, letterSpacing: 3)),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'No gear yet.\nDefeat enemies to find your first item!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppTheme.textMuted, height: 1.6),
            ),
          ),
        ),
      );
    }

    final visIdx = _ctrl.index.clamp(0, indices.length - 1);
    final allIdx = indices[visIdx];

    final tabs = [
      for (final i in indices)
        Tab(
          height: 48,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_emojis[i], style: TextStyle(fontSize: i == allIdx ? 16 : 13)),
              const SizedBox(height: 2),
              Text(_labels[i],
                  style: GoogleFonts.rajdhani(
                    fontSize: 9,
                    fontWeight: i == allIdx ? FontWeight.bold : FontWeight.normal,
                    letterSpacing: 1,
                  )),
            ],
          ),
        ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Text('INVENTORY',
            style: AppTheme.pixelHeading(fontSize: 15, letterSpacing: 3)),
        bottom: TabBar(
          controller: _ctrl,
          tabs: tabs,
          isScrollable: indices.length > 3,
          tabAlignment: indices.length > 3 ? TabAlignment.start : TabAlignment.fill,
          labelColor: AppTheme.accentGold,
          unselectedLabelColor: AppTheme.textMuted,
          indicator: const GlowTabIndicator(),
          indicatorWeight: 2,
        ),
      ),
      body: TabBarView(
        controller: _ctrl,
        children: [
          for (final i in indices) _buildScreen(i, game),
        ],
      ),
    );
  }
}

// ── Gem Crafting Tab ─────────────────────────────────────────────────────────

class _GemCraftingTab extends StatefulWidget {
  const _GemCraftingTab({required this.game});
  final GameState game;

  @override
  State<_GemCraftingTab> createState() => _GemCraftingTabState();
}

class _GemCraftingTabState extends State<_GemCraftingTab> {
  GemTier _tier = GemTier.flawed;
  GemType? _selectedType;

  @override
  Widget build(BuildContext context) {
    final game = widget.game;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // What gems do — quick explainer
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF14121c),
              border: Border.all(color: const Color(0xFFbb88ee).withValues(alpha: 0.35)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Gems are permanent stat boosters you socket into gear. Each gem has '
              'an element (Fire, Cold, Lightning…): sockets in a WEAPON add a % '
              'damage bonus of that element, and in ARMOUR/ACCESSORIES add a % '
              'resistance to it. Craft gems here with Arcane Dust, then socket '
              'them from an item in your Inventory. Higher tiers give a bigger % '
              'and cost more Arcane Dust; dismantling refunds the Dust.',
              style: TextStyle(fontSize: 11, color: AppTheme.textLight, height: 1.45),
            ),
          ),
          // Gem placement rules
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0d1020),
              border: Border.all(color: AppTheme.cardBorder),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Row(
              children: [
                Expanded(child: Column(
                  children: [
                    Text('⚔ WEAPON / OFFHAND', style: TextStyle(fontSize: 9, color: Color(0xFFff6644), fontWeight: FontWeight.bold)),
                    SizedBox(height: 2),
                    Text('Increases % Damage', style: TextStyle(fontSize: 8, color: Color(0xFFff6644))),
                  ],
                )),
                SizedBox(width: 8),
                Expanded(child: Column(
                  children: [
                    Text('🛡 ARMOR / ACCESSORIES', style: TextStyle(fontSize: 9, color: Color(0xFF66aaff), fontWeight: FontWeight.bold)),
                    SizedBox(height: 2),
                    Text('Increases % Resistance', style: TextStyle(fontSize: 8, color: Color(0xFF66aaff))),
                  ],
                )),
              ],
            ),
          ),

          // Gem shards balance
          Tooltip(
            message: CurrencyInfo.gemShards,
            child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0d1020),
              border: Border.all(color: const Color(0xFF44ccff).withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(children: [
              const Text('💠', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text('${game.gemShards}',
                  style: GoogleFonts.rajdhani(
                      fontSize: 17, fontWeight: FontWeight.bold,
                      color: const Color(0xFF44ccff))),
              const SizedBox(width: 6),
              const Text('Arcane Dust', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              const Spacer(),
              Text('Bag: ${game.gemBag.length}/${GameState.gemBagMax}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
            ]),
          ),
          ),
          const SizedBox(height: 12),

          // Tier selector
          Text('TIER', style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2, color: AppTheme.textMuted)),
          const SizedBox(height: 6),
          Row(
            children: GemTier.values.map((tier) {
              final active = tier == _tier;
              return GestureDetector(
                onTap: () => setState(() => _tier = tier),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: active ? tier.color.withValues(alpha: 0.15) : Colors.transparent,
                    border: Border.all(
                      color: active ? tier.color : tier.color.withValues(alpha: 0.25),
                      width: active ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(tier.label, style: TextStyle(
                          fontSize: 9, color: active ? tier.color : AppTheme.textMuted,
                          fontWeight: active ? FontWeight.bold : FontWeight.normal)),
                      Text('${tier.shardCost}💠', style: TextStyle(
                          fontSize: 8, color: active ? tier.color.withValues(alpha: 0.7) : AppTheme.textMuted.withValues(alpha: 0.5))),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // 2x3 gem grid
          Text('CRAFT GEM', style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2, color: AppTheme.textMuted)),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.1,
            children: GemType.values.map((type) {
              final gem = Gem(type: type, tier: _tier);
              final canAfford = game.gemShards >= _tier.shardCost && game.gemBag.length < GameState.gemBagMax;
              final isSelected = _selectedType == type;
              return GestureDetector(
                onTap: () => setState(() => _selectedType = isSelected ? null : type),
                child: Container(
                  decoration: BoxDecoration(
                    color: canAfford
                        ? type.color.withValues(alpha: 0.08)
                        : const Color(0xFF0d0e18),
                    border: Border.all(
                      color: canAfford
                          ? type.color.withValues(alpha: 0.6)
                          : type.color.withValues(alpha: 0.15),
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Gem sprite
                      CustomPaint(
                        size: const Size(32, 32),
                        painter: _GemSpritePainter(type: type, tier: _tier),
                      ),
                      const SizedBox(height: 4),
                      Text(type.label, style: TextStyle(
                          fontSize: 10, color: type.color,
                          fontWeight: FontWeight.bold)),
                      Text('⚔ +${gem.value}% DMG', style: TextStyle(
                          fontSize: 7, color: const Color(0xFFff6644).withValues(alpha: 0.8))),
                      Text('🛡 +${gem.value}% RES', style: TextStyle(
                          fontSize: 7, color: const Color(0xFF66aaff).withValues(alpha: 0.8))),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          // Craft button
          if (_selectedType != null) ...[
            const SizedBox(height: 10),
            Builder(builder: (_) {
              final canAfford = game.gemShards >= _tier.shardCost && game.gemBag.length < GameState.gemBagMax;
              return SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: canAfford ? () {
                    game.craftGem(_selectedType!, _tier);
                    setState(() => _selectedType = null);
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canAfford ? _selectedType!.color.withValues(alpha: 0.15) : Colors.transparent,
                    foregroundColor: canAfford ? _selectedType!.color : AppTheme.cardBorder,
                    side: BorderSide(color: canAfford ? _selectedType!.color : AppTheme.cardBorder),
                  ),
                  child: Text('CRAFT ${_selectedType!.label.toUpperCase()} GEM  (${_tier.shardCost} Arcane Dust)',
                      style: AppTheme.pixelHeading(fontSize: 11,
                          color: canAfford ? _selectedType!.color : AppTheme.cardBorder)),
                ),
              );
            }),
          ],
          const SizedBox(height: 16),

          // Owned gems
          if (game.gemBag.isNotEmpty) ...[
            Text('OWNED GEMS', style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2, color: AppTheme.textMuted)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: game.gemBag.asMap().entries.map((e) {
                final gem = e.value;
                final idx = e.key;
                return GestureDetector(
                  onTap: () async {
                    final action = await showDialog<String>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: const Color(0xFF1a1a2e),
                        title: Text(gem.name, style: TextStyle(color: gem.type.color, fontSize: 14)),
                        content: Text('${gem.bonusLabel}\n\nSocket into a WEAPON for +DMG%, or ARMOUR for +RES% of this gem\'s element.\n\nDismantle returns ${gem.tier.shardCost} Arcane Dust.',
                            style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL', style: TextStyle(color: AppTheme.textMuted))),
                          TextButton(onPressed: () => Navigator.pop(ctx, 'dismantle'),
                              child: Text('DISMANTLE (+${gem.tier.shardCost} Arcane Dust)', style: const TextStyle(color: Color(0xFFff6644)))),
                        ],
                      ),
                    );
                    if (action == 'dismantle') {
                      game.gemShards += gem.tier.shardCost;
                      game.gemBag.removeAt(idx);
                      game.notifyListeners();
                      game.saveToLocal();
                      setState(() {});
                    }
                  },
                  child: Tooltip(
                    message: '${gem.name}\n${gem.bonusLabel}\nTap to dismantle',
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: gem.type.color.withValues(alpha: 0.08),
                        border: Border.all(color: gem.tier.color.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomPaint(
                            size: const Size(20, 20),
                            painter: _GemSpritePainter(type: gem.type, tier: gem.tier),
                          ),
                          const SizedBox(height: 2),
                          Text(gem.tier.label[0], style: TextStyle(
                              fontSize: 7, color: gem.tier.color, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Gem Sprite Painter ──────────────────────────────────────────────────────

class _GemSpritePainter extends CustomPainter {
  const _GemSpritePainter({required this.type, required this.tier});
  final GemType type;
  final GemTier tier;

  @override
  void paint(Canvas cv, Size size) {
    final pt = Paint();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final col = type.color;
    final ti = tier.index;

    if (ti >= 1) {
      pt.color = col.withValues(alpha: 0.08 + ti * 0.06);
      cv.drawCircle(Offset(cx, cy), size.width * (0.38 + ti * 0.04), pt);
    }

    switch (type) {
      case GemType.ruby:     _ruby(cv, pt, cx, cy, size, col, ti);
      case GemType.sapphire: _sapphire(cv, pt, cx, cy, size, col, ti);
      case GemType.diamond:  _diamond(cv, pt, cx, cy, size, col, ti);
      case GemType.emerald:  _emerald(cv, pt, cx, cy, size, col, ti);
      case GemType.amethyst: _amethyst(cv, pt, cx, cy, size, col, ti);
      case GemType.onyx:     _onyx(cv, pt, cx, cy, size, col, ti);
    }

    if (ti >= 3) {
      pt.color = Colors.white.withValues(alpha: 0.8);
      cv.drawCircle(Offset(cx - 4, cy - 6), 1.2, pt);
      cv.drawCircle(Offset(cx + 5, cy - 4), 1.0, pt);
      cv.drawCircle(Offset(cx + 2, cy + 5), 0.8, pt);
    }
    if (ti >= 4) {
      pt.color = const Color(0xFFff4444);
      pt.style = PaintingStyle.stroke;
      pt.strokeWidth = 1.5;
      final crown = Path()
        ..moveTo(cx - 4, cy - size.height * 0.42)
        ..lineTo(cx - 2, cy - size.height * 0.5)
        ..lineTo(cx, cy - size.height * 0.42)
        ..lineTo(cx + 2, cy - size.height * 0.5)
        ..lineTo(cx + 4, cy - size.height * 0.42);
      cv.drawPath(crown, pt);
      pt.style = PaintingStyle.fill;
    }
  }

  void _ruby(Canvas cv, Paint pt, double cx, double cy, Size s, Color col, int ti) {
    final path = Path()
      ..moveTo(cx, cy - s.height * 0.38)
      ..quadraticBezierTo(cx + s.width * 0.4, cy - s.height * 0.1, cx + s.width * 0.2, cy + s.height * 0.3)
      ..lineTo(cx, cy + s.height * 0.4)
      ..lineTo(cx - s.width * 0.2, cy + s.height * 0.3)
      ..quadraticBezierTo(cx - s.width * 0.4, cy - s.height * 0.1, cx, cy - s.height * 0.38);
    pt.color = Color.lerp(col, Colors.black, 0.25)!;
    cv.drawPath(path, pt);
    pt.color = col;
    cv.drawOval(Rect.fromCenter(center: Offset(cx, cy - 1), width: s.width * 0.3, height: s.height * 0.35), pt);
    pt.color = Color.lerp(col, Colors.white, 0.3 + ti * 0.08)!;
    cv.drawOval(Rect.fromCenter(center: Offset(cx - 2, cy - 4), width: 5, height: 3), pt);
    _bdr(cv, pt, path, col);
  }

  void _sapphire(Canvas cv, Paint pt, double cx, double cy, Size s, Color col, int ti) {
    pt.color = Color.lerp(col, Colors.black, 0.25)!;
    cv.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: s.width * 0.7, height: s.height * 0.75), pt);
    pt.color = col;
    cv.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: s.width * 0.5, height: s.height * 0.55), pt);
    pt.color = Color.lerp(col, Colors.white, 0.35 + ti * 0.08)!;
    cv.drawOval(Rect.fromCenter(center: Offset(cx - 3, cy - 3), width: 6, height: 4), pt);
    pt.color = Color.lerp(col, Colors.white, 0.15)!;
    pt.style = PaintingStyle.stroke; pt.strokeWidth = 1;
    cv.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: s.width * 0.7, height: s.height * 0.75), pt);
    pt.style = PaintingStyle.fill;
  }

  void _diamond(Canvas cv, Paint pt, double cx, double cy, Size s, Color col, int ti) {
    final crown = Path()..moveTo(cx, cy - s.height * 0.42)..lineTo(cx + s.width * 0.38, cy - s.height * 0.05)..lineTo(cx - s.width * 0.38, cy - s.height * 0.05)..close();
    pt.color = Color.lerp(col, Colors.white, 0.2 + ti * 0.08)!;
    cv.drawPath(crown, pt);
    final pav = Path()..moveTo(cx - s.width * 0.38, cy - s.height * 0.05)..lineTo(cx + s.width * 0.38, cy - s.height * 0.05)..lineTo(cx, cy + s.height * 0.42)..close();
    pt.color = Color.lerp(col, Colors.black, 0.15)!;
    cv.drawPath(pav, pt);
    pt.color = col; pt.style = PaintingStyle.stroke; pt.strokeWidth = 1.5;
    cv.drawLine(Offset(cx - s.width * 0.38, cy - s.height * 0.05), Offset(cx + s.width * 0.38, cy - s.height * 0.05), pt);
    pt.style = PaintingStyle.fill;
    pt.color = Colors.white.withValues(alpha: 0.4 + ti * 0.08);
    cv.drawPath(Path()..moveTo(cx, cy - s.height * 0.42)..lineTo(cx + 4, cy - 3)..lineTo(cx - 4, cy - 3)..close(), pt);
    _bdr(cv, pt, Path()..addPath(crown, Offset.zero)..addPath(pav, Offset.zero), col);
  }

  void _emerald(Canvas cv, Paint pt, double cx, double cy, Size s, Color col, int ti) {
    final w = s.width * 0.6; final h = s.height * 0.7; final cn = s.width * 0.1;
    final path = Path()..moveTo(cx - w/2 + cn, cy - h/2)..lineTo(cx + w/2 - cn, cy - h/2)..lineTo(cx + w/2, cy - h/2 + cn)..lineTo(cx + w/2, cy + h/2 - cn)..lineTo(cx + w/2 - cn, cy + h/2)..lineTo(cx - w/2 + cn, cy + h/2)..lineTo(cx - w/2, cy + h/2 - cn)..lineTo(cx - w/2, cy - h/2 + cn)..close();
    pt.color = Color.lerp(col, Colors.black, 0.2)!;
    cv.drawPath(path, pt);
    pt.color = col;
    cv.drawRect(Rect.fromCenter(center: Offset(cx, cy), width: w * 0.6, height: h * 0.6), pt);
    pt.color = Color.lerp(col, Colors.white, 0.3 + ti * 0.08)!;
    cv.drawRect(Rect.fromCenter(center: Offset(cx - 1, cy - 2), width: 5, height: 3), pt);
    _bdr(cv, pt, path, col);
  }

  void _amethyst(Canvas cv, Paint pt, double cx, double cy, Size s, Color col, int ti) {
    final r = s.width * 0.35;
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final a = (i * 60 - 90) * 3.14159 / 180;
      final x = cx + r * cos(a); final y = cy + r * sin(a);
      if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
    }
    path.close();
    pt.color = Color.lerp(col, Colors.black, 0.2)!;
    cv.drawPath(path, pt);
    final inner = Path();
    for (int i = 0; i < 6; i++) {
      final a = (i * 60 - 90) * 3.14159 / 180;
      final x = cx + r * 0.6 * cos(a); final y = cy + r * 0.6 * sin(a);
      if (i == 0) { inner.moveTo(x, y); } else { inner.lineTo(x, y); }
    }
    inner.close();
    pt.color = col;
    cv.drawPath(inner, pt);
    pt.color = Color.lerp(col, Colors.white, 0.35 + ti * 0.08)!;
    cv.drawCircle(Offset(cx - 2, cy - 3), 2.5, pt);
    _bdr(cv, pt, path, col);
  }

  void _onyx(Canvas cv, Paint pt, double cx, double cy, Size s, Color col, int ti) {
    final rr = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy), width: s.width * 0.65, height: s.height * 0.65), const Radius.circular(4));
    pt.color = Color.lerp(col, Colors.black, 0.3)!;
    cv.drawRRect(rr, pt);
    final inner = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy), width: s.width * 0.4, height: s.height * 0.4), const Radius.circular(2));
    pt.color = col;
    cv.drawRRect(inner, pt);
    pt.color = Color.lerp(col, Colors.white, 0.25 + ti * 0.08)!;
    cv.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - 5, cy - 5, 5, 3), const Radius.circular(1)), pt);
    pt.color = Color.lerp(col, Colors.white, 0.15)!;
    pt.style = PaintingStyle.stroke; pt.strokeWidth = 1;
    cv.drawRRect(rr, pt);
    pt.style = PaintingStyle.fill;
  }

  void _bdr(Canvas cv, Paint pt, Path path, Color col) {
    pt.color = Color.lerp(col, Colors.white, 0.2)!;
    pt.style = PaintingStyle.stroke; pt.strokeWidth = 1;
    cv.drawPath(path, pt);
    pt.style = PaintingStyle.fill;
  }

  @override
  bool shouldRepaint(covariant _GemSpritePainter old) => old.type != type || old.tier != tier;
}
