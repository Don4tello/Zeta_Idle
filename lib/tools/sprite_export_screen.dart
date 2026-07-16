import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../widgets/battle_sprites.dart';
import '../models/hero_race.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Dev tool: renders every hero sprite + race emoji icon into RepaintBoundary
// widgets, then captures each one as a PNG and writes to exported_sprites/.
// Run the Windows build, open Settings → "Export Sprites (Dev)", tap the button.
// ─────────────────────────────────────────────────────────────────────────────

class SpriteExportScreen extends StatefulWidget {
  const SpriteExportScreen({super.key});

  @override
  State<SpriteExportScreen> createState() => _SpriteExportScreenState();
}

class _SpriteExportScreenState extends State<SpriteExportScreen> {
  // (spriteId, label) — paladin uses 'hero' as its spriteId in the codebase.
  static const _heroSprites = [
    ('hero_barbarian', 'Barbarian'),
    ('hero_bard',      'Bard'),
    ('hero_cleric',    'Cleric'),
    ('hero_druid',     'Druid'),
    ('hero_fighter',   'Fighter'),
    ('hero_monk',      'Monk'),
    ('hero',           'Paladin'),
    ('hero_ranger',    'Ranger'),
    ('hero_rogue',     'Rogue'),
    ('hero_sorcerer',  'Sorcerer'),
    ('hero_warlock',   'Warlock'),
    ('hero_wizard',    'Wizard'),
  ];

  final _keys = <String, GlobalKey>{};
  String _status = 'Tap the button to export sprites to exported_sprites/.';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    for (final (id, _) in _heroSprites) {
      _keys[id] = GlobalKey();
    }
    for (final r in HeroRace.values) {
      _keys['race_${r.name}'] = GlobalKey();
    }
  }

  Future<void> _export() async {
    setState(() {
      _busy   = true;
      _status = 'Starting export...';
    });

    // Let the current frame finish so all RepaintBoundary widgets are laid out.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;

    final outDir = Directory('exported_sprites');
    await outDir.create(recursive: true);
    if (!mounted) return;

    int saved = 0;

    for (final entry in _keys.entries) {
      if (!mounted) break;

      // Use currentContext inline (not stored before an await) to satisfy
      // use_build_context_synchronously lint.
      final obj = entry.value.currentContext?.findRenderObject();
      if (obj is! RenderRepaintBoundary) {
        debugPrint('SpriteExport: skipping ${entry.key} (${obj?.runtimeType})');
        continue;
      }

      final image = await obj.toImage(pixelRatio: 4.0);
      if (!mounted) { image.dispose(); break; }

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (!mounted) break;
      if (byteData == null) continue;

      final file = File('${outDir.path}/${entry.key}.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      if (!mounted) break;

      saved++;
      setState(() {
        _status = 'Saved ${entry.key}.png  ($saved / ${_keys.length})';
      });
    }

    if (mounted) {
      setState(() {
        _busy   = false;
        _status = 'Done! $saved files written to ${outDir.absolute.path}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text('Sprite Exporter (Dev)',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1a2a1a),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF44aa44)),
              ),
              child: Text(_status,
                  style: const TextStyle(color: Color(0xFF88dd88), fontSize: 13)),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _busy ? null : _export,
              icon: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_alt),
              label: Text(_busy ? 'Exporting…' : 'Export All Sprites'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF335533),
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 28),

            // ── Class sprites ────────────────────────────────────────────────
            const Text('CLASS SPRITES  (80 × 120 canvas, exported at 4×)',
                style: TextStyle(color: Color(0xFF888888), fontSize: 11)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 16,
              children: [
                for (final (id, label) in _heroSprites)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RepaintBoundary(
                        key: _keys[id],
                        child: StaticEnemySprite(spriteId: id, size: 80),
                      ),
                      const SizedBox(height: 4),
                      Text(label,
                          style: const TextStyle(
                              color: Color(0xFF888888), fontSize: 10)),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Race emoji icons ─────────────────────────────────────────────
            const Text('RACE ICONS  (56 × 56, exported at 4×)',
                style: TextStyle(color: Color(0xFF888888), fontSize: 11)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 16,
              children: [
                for (final race in HeroRace.values)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RepaintBoundary(
                        key: _keys['race_${race.name}'],
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: Center(
                            child: Text(
                              race.info.icon,
                              style: const TextStyle(fontSize: 36),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(race.info.displayName,
                          style: const TextStyle(
                              color: Color(0xFF888888), fontSize: 10)),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
