import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/expedition.dart';
import '../models/npc_ally.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

// ── Location scene widget ─────────────────────────────────────────────────────

class LocationScene extends StatelessWidget {
  const LocationScene({
    super.key,
    required this.biome,
    this.width = 160,
    this.height = 96,
  });
  final LocationBiome biome;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRect(
        child: Align(
          alignment: const Alignment(0, 0.35),
          heightFactor: 0.85,
          child: Image.asset(
            biome.imagePath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF1a1a2e),
              child: Center(child: Text(biome.icon, style: const TextStyle(fontSize: 28))),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Main screen ───────────────────────────────────────────────────────────────

class ExpeditionScreen extends StatefulWidget {
  const ExpeditionScreen({super.key});
  @override
  State<ExpeditionScreen> createState() => _ExpeditionScreenState();
}

class _ExpeditionScreenState extends State<ExpeditionScreen> {
  Timer? _ticker;
  late List<ExpeditionLocation> _dailyLocations;

  int get _dayIndex =>
      DateTime.now().millisecondsSinceEpoch ~/ (24 * 60 * 60 * 1000);

  @override
  void initState() {
    super.initState();
    _dailyLocations = ExpeditionLocation.daily(_dayIndex, count: 6);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _timeUntilRefresh() {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final nextDay = (_dayIndex + 1) * 24 * 60 * 60 * 1000;
    final rem = Duration(milliseconds: nextDay - nowMs);
    return '${rem.inHours}h ${rem.inMinutes.remainder(60).toString().padLeft(2, '0')}m';
  }

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final mercs = game.unlockedAllies;

    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('EXPEDITIONS',
            style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
        actions: [
          if (game.activeExpeditions.any((e) {
            final elapsed = DateTime.now().millisecondsSinceEpoch - e.startEpochMs;
            return elapsed >= e.duration.ms;
          }))
            TextButton(
              onPressed: () { game.collectAllExpeditions(); game.audioService.playClaimAll(); setState(() {}); },
              child: Text('COLLECT ALL',
                  style: AppTheme.pixelHeading(fontSize: 10, color: const Color(0xFF55cc88))),
            ),
          if (mercs.any((m) => game.expeditionForMerc(m.id) == null))
            TextButton(
              onPressed: () {
                final idle = mercs.where((m) => game.expeditionForMerc(m.id) == null).toList();
                for (final merc in idle) {
                  if (_dailyLocations.isEmpty) break;
                  final loc = _dailyLocations[idle.indexOf(merc) % _dailyLocations.length];
                  game.startExpedition(merc.id, loc, ExpeditionDuration.long);
                }
                game.audioService.playClaimAll();
                setState(() {});
              },
              child: Text('DISPATCH ALL',
                  style: AppTheme.pixelHeading(fontSize: 10, color: const Color(0xFF8aba50))),
            ),
        ],
      ),
      body: mercs.isEmpty
          ? _noMercsPlaceholder()
          : ListView(
              padding: const EdgeInsets.all(14),
              children: [
                _locationsSection(),
                const SizedBox(height: 20),
                _mercsSection(game, mercs),
              ],
            ),
    );
  }

  Widget _noMercsPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚔️', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 14),
            Text('No Mercenaries Yet',
                style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 1)),
            const SizedBox(height: 8),
            const Text(
              'Recruit mercenaries from the MERCS tab in Hero Hub to send them on expeditions.',
              style: TextStyle(
                  fontSize: 13, color: AppTheme.textMuted, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _locationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text("TODAY'S LOCATIONS",
              style: AppTheme.pixelHeading(
                  fontSize: 10, color: AppTheme.textMuted, letterSpacing: 1)),
          const Spacer(),
          Text('🔄 ${_timeUntilRefresh()}',
              style: GoogleFonts.rajdhani(
                  fontSize: 10, color: const Color(0xFF666055))),
        ]),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 1.1,
          ),
          itemCount: _dailyLocations.length,
          itemBuilder: (ctx, i) => _LocationCard(loc: _dailyLocations[i]),
        ),
      ],
    );
  }

  Widget _mercsSection(GameState game, List<NpcAllyDef> mercs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('YOUR PARTY',
            style: AppTheme.pixelHeading(
                fontSize: 10, color: AppTheme.textMuted, letterSpacing: 1)),
        const SizedBox(height: 10),
        ...mercs.map((merc) {
          final exp = game.expeditionForMerc(merc.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: exp != null
                ? _ActiveMercCard(
                    merc: merc,
                    expedition: exp,
                    game: game,
                    onCollected: () => setState(() {}),
                  )
                : _IdleMercCard(
                    merc: merc,
                    onDispatch: () => _openDispatchSheet(merc),
                  ),
          );
        }),
      ],
    );
  }

  void _openDispatchSheet(NpcAllyDef merc) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1C18),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => _DispatchSheet(
        merc: merc,
        locations: _dailyLocations,
        game: GameStateProvider.of(context),
        onDispatched: () {
          Navigator.pop(ctx);
          setState(() {});
        },
      ),
    );
  }
}

// ── Location card (top scroll) ────────────────────────────────────────────────

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.loc});
  final ExpeditionLocation loc;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1C18),
        border: Border.all(color: const Color(0xFF3a3530)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  LocationScene(biome: loc.biome, width: double.infinity, height: double.infinity),
                  Positioned(
                    left: 0, right: 0, bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(5, 12, 5, 4),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xDD000000)],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loc.name,
                              style: GoogleFonts.rajdhani(
                                  fontSize: 9, color: Colors.white70,
                                  fontWeight: FontWeight.bold),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(loc.biome.rewardFocus,
                              style: GoogleFonts.rajdhani(
                                  fontSize: 8, color: const Color(0xFF998870)),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Idle merc card ────────────────────────────────────────────────────────────

class _IdleMercCard extends StatelessWidget {
  const _IdleMercCard({required this.merc, required this.onDispatch});
  final NpcAllyDef merc;
  final VoidCallback onDispatch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1C18),
        border: Border.all(color: const Color(0xFF3a3530)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(children: [
        Text(merc.icon, style: const TextStyle(fontSize: 28)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(merc.name,
                style: GoogleFonts.rajdhani(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70)),
            Text(merc.title,
                style: GoogleFonts.rajdhani(
                    fontSize: 10, color: AppTheme.textMuted)),
          ]),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onDispatch,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2a3020),
              border: Border.all(color: const Color(0xFF6a9040)),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text('DISPATCH',
                style: AppTheme.pixelHeading(
                    fontSize: 10,
                    color: const Color(0xFF8aba50),
                    letterSpacing: 1)),
          ),
        ),
      ]),
    );
  }
}

// ── Active merc card (on expedition) ─────────────────────────────────────────

class _ActiveMercCard extends StatelessWidget {
  const _ActiveMercCard({
    required this.merc,
    required this.expedition,
    required this.game,
    required this.onCollected,
  });
  final NpcAllyDef merc;
  final Expedition expedition;
  final GameState game;
  final VoidCallback onCollected;

  static const _biomeColor = {
    LocationBiome.graveyard:  Color(0xFF7c3aed),
    LocationBiome.cave:       Color(0xFF3a7eb0),
    LocationBiome.temple:     Color(0xFFcc9922),
    LocationBiome.fortress:   Color(0xFF7a8090),
    LocationBiome.ruin:       Color(0xFF8b6914),
    LocationBiome.dungeon:    Color(0xFFcc4422),
    LocationBiome.catacombs:  Color(0xFF44aaaa),
    LocationBiome.sanctum:    Color(0xFF9944cc),
    LocationBiome.barrows:    Color(0xFF6644aa),
    LocationBiome.highPass:   Color(0xFF6688aa),
  };

  Color get _color =>
      _biomeColor[expedition.location.biome] ?? const Color(0xFF888888);

  @override
  Widget build(BuildContext context) {
    final done = expedition.isComplete;
    final progress = expedition.progress;
    final rem = expedition.remaining;
    final color = _color;
    final preview = game.previewExpeditionRewards(
        merc.id, expedition.location, expedition.duration);

    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        border: Border.all(
            color: done ? color : color.withValues(alpha: 0.35),
            width: done ? 1.5 : 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(children: [
              Text(merc.icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(merc.name,
                      style: GoogleFonts.rajdhani(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70)),
                  Text(expedition.location.name,
                      style: GoogleFonts.rajdhani(
                          fontSize: 10, color: color),
                      overflow: TextOverflow.ellipsis),
                ]),
              ),
              const SizedBox(width: 8),
              if (done)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    border: Border.all(color: color),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text('DONE',
                      style: AppTheme.pixelHeading(fontSize: 9, color: color)),
                )
              else
                Text(_fmtDuration(rem),
                    style: AppTheme.pixelHeading(fontSize: 12, color: color)),
            ]),
          ),
          Row(children: [
            ClipRect(
              child: LocationScene(
                  biome: expedition.location.biome,
                  width: 100,
                  height: 60),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 12, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 5,
                        backgroundColor: color.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final e in preview.entries)
                          Text(
                            '${_rewardIcon(e.key)} ${e.value}',
                            style: TextStyle(
                                fontSize: 10,
                                color: color.withValues(alpha: 0.75)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      done ? color.withValues(alpha: 0.18) : Colors.transparent,
                  foregroundColor: done ? color : Colors.white24,
                  side: BorderSide(color: done ? color : Colors.white12),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero),
                ),
                onPressed: done
                    ? () {
                        final result = game.collectExpedition(merc.id);
                        onCollected();
                        if (context.mounted) {
                          _showRewards(context, result.rewards,
                              result.discovery, color);
                        }
                      }
                    : null,
                child: Text(
                  done ? 'COLLECT REWARDS' : 'IN PROGRESS...',
                  style: AppTheme.pixelHeading(
                      fontSize: 11,
                      color: done ? color : Colors.white24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRewards(BuildContext context, Map<String, int> rewards,
      String? discovery, Color color) {
    final lines = rewards.entries
        .map((e) => '${_rewardIcon(e.key)}  ${AppTheme.fmtNumber(e.value)}  ${e.key}')
        .join('\n');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B1814),
        title: Text('${merc.name} returned!',
            style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lines,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 15, height: 1.7)),
            if (discovery != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1a1428),
                  border: Border.all(
                      color: const Color(0xFFaa77ff).withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('✦  DISCOVERY',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFaa77ff),
                            letterSpacing: 2)),
                    const SizedBox(height: 6),
                    Text(discovery,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white60,
                            height: 1.5,
                            fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: color.withValues(alpha: 0.18),
                foregroundColor: color,
                side: BorderSide(color: color)),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('GREAT'),
          ),
        ],
      ),
    );
  }

  String _fmtDuration(Duration d) {
    if (d.inHours >= 1) {
      return '${d.inHours}h ${d.inMinutes.remainder(60).toString().padLeft(2, '0')}m';
    }
    return '${d.inMinutes}m ${d.inSeconds.remainder(60).toString().padLeft(2, '0')}s';
  }

  String _rewardIcon(String key) => switch (key) {
    'gold'     => '💰',
    'shards'   => '◆',
    'essence'  => '✦',
    'mythril'  => '⬡',
    'zcoins' => '🪙',
    _          => '•',
  };
}

// ── Dispatch bottom sheet ─────────────────────────────────────────────────────

class _DispatchSheet extends StatefulWidget {
  const _DispatchSheet({
    required this.merc,
    required this.locations,
    required this.game,
    required this.onDispatched,
  });
  final NpcAllyDef merc;
  final List<ExpeditionLocation> locations;
  final GameState game;
  final VoidCallback onDispatched;

  @override
  State<_DispatchSheet> createState() => _DispatchSheetState();
}

class _DispatchSheetState extends State<_DispatchSheet> {
  ExpeditionLocation? _selectedLoc;
  ExpeditionDuration _selectedDur = ExpeditionDuration.short;

  @override
  Widget build(BuildContext context) {
    final preview = _selectedLoc != null
        ? widget.game.previewExpeditionRewards(
            widget.merc.id, _selectedLoc!, _selectedDur)
        : null;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (ctx, scroll) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E1C18),
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF5a5550),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(children: [
              Text(widget.merc.icon, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('DISPATCH ${widget.merc.name.toUpperCase()}',
                    style: AppTheme.pixelHeading(
                        fontSize: 12, letterSpacing: 1)),
                Text(widget.merc.title,
                    style: GoogleFonts.rajdhani(
                        fontSize: 10, color: AppTheme.textMuted)),
              ]),
            ]),
            const SizedBox(height: 18),
            Text('CHOOSE LOCATION',
                style: AppTheme.pixelHeading(
                    fontSize: 9, color: AppTheme.textMuted, letterSpacing: 1)),
            const SizedBox(height: 8),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.15,
              children: widget.locations.map((loc) {
                final sel = _selectedLoc == loc;
                final borderColor = sel
                    ? const Color(0xFF8aba50)
                    : const Color(0xFF3a3530);
                return GestureDetector(
                  onTap: () => setState(() => _selectedLoc = loc),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: borderColor, width: sel ? 2 : 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(3)),
                          child: LocationScene(
                              biome: loc.biome,
                              width: double.infinity,
                              height: double.infinity),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 5),
                        child: Text(
                          loc.name,
                          style: GoogleFonts.rajdhani(
                              fontSize: 9,
                              color: sel ? Colors.white : Colors.white54,
                              fontWeight: sel
                                  ? FontWeight.bold
                                  : FontWeight.normal),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ]),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            Text('DURATION',
                style: AppTheme.pixelHeading(
                    fontSize: 9, color: AppTheme.textMuted, letterSpacing: 1)),
            const SizedBox(height: 8),
            Row(children: ExpeditionDuration.values.map((dur) {
              final sel = _selectedDur == dur;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDur = dur),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: sel
                            ? const Color(0xFF2a3020)
                            : const Color(0xFF1a1814),
                        border: Border.all(
                            color: sel
                                ? const Color(0xFF6a9040)
                                : const Color(0xFF3a3530),
                            width: sel ? 1.5 : 1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        dur.label,
                        style: AppTheme.pixelHeading(
                            fontSize: 10,
                            color: sel
                                ? const Color(0xFF8aba50)
                                : AppTheme.textMuted,
                            letterSpacing: 1),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            }).toList()),
            if (preview != null) ...[
              const SizedBox(height: 16),
              Text('ESTIMATED REWARDS',
                  style: AppTheme.pixelHeading(
                      fontSize: 9, color: AppTheme.textMuted, letterSpacing: 1)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  for (final e in preview.entries)
                    _RewardChip(resourceKey: e.key, amount: e.value),
                ],
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedLoc != null
                      ? const Color(0xFF2a3020)
                      : const Color(0xFF1a1814),
                  foregroundColor: _selectedLoc != null
                      ? const Color(0xFF8aba50)
                      : Colors.white24,
                  side: BorderSide(
                      color: _selectedLoc != null
                          ? const Color(0xFF6a9040)
                          : Colors.white12),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero),
                ),
                onPressed: _selectedLoc != null
                    ? () {
                        widget.game.startExpedition(
                            widget.merc.id, _selectedLoc!, _selectedDur);
                        widget.onDispatched();
                      }
                    : null,
                child: Text(
                  _selectedLoc != null
                      ? 'SEND ON EXPEDITION'
                      : 'SELECT A LOCATION',
                  style: AppTheme.pixelHeading(
                      fontSize: 12,
                      color: _selectedLoc != null
                          ? const Color(0xFF8aba50)
                          : Colors.white24,
                      letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  const _RewardChip({required this.resourceKey, required this.amount});
  final String resourceKey;
  final int amount;

  String get icon => switch (resourceKey) {
    'gold'     => '💰',
    'shards'   => '◆',
    'essence'  => '✦',
    'mythril'  => '⬡',
    'zcoins' => '🪙',
    _          => '•',
  };

  Color get color => switch (resourceKey) {
    'gold'     => const Color(0xFFddaa44),
    'shards'   => const Color(0xFF44aadd),
    'essence'  => const Color(0xFF44dd88),
    'mythril'  => const Color(0xFF8888ff),
    'zcoins' => const Color(0xFFff88cc),
    _          => Colors.white54,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        '$icon ${AppTheme.fmtNumber(amount)} $resourceKey',
        style: GoogleFonts.rajdhani(fontSize: 11, color: color),
      ),
    );
  }
}
