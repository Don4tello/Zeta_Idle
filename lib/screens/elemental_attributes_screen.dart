import 'package:flutter/material.dart';
import '../models/damage_type.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

// Elemental Attributes — the 6 hero base stats mapped to damage elements.
// Each stat directly controls +X% elemental damage AND provides elemental resistance.

class ElementalAttributesScreen extends StatelessWidget {
  const ElementalAttributesScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final h    = game.hero;

    final attrs = [
      _Attr(DamageType.physical,  'Physical Mastery', 'STR', h.strength),
      _Attr(DamageType.lightning, 'Lightning Mastery','DEX', h.dexterity),
      _Attr(DamageType.poison,    'Poison Mastery',   'CON', h.constitution),
      _Attr(DamageType.void_,     'Void Mastery',     'INT', h.intelligence),
      _Attr(DamageType.cold,      'Cold Mastery',     'WIS', h.wisdom),
      _Attr(DamageType.fire,      'Fire Mastery',     'CHA', h.charisma),
    ];

    final body = ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        _InfoBanner(),
        const SizedBox(height: 12),
        ...attrs.map((a) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _AttrCard(attr: a, resPct: game.heroResistancePct(a.type)),
        )),
      ],
    );

    if (embedded) return ColoredBox(color: AppTheme.darkBg, child: body);
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Text('ELEMENTAL ATTRIBUTES',
            style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 2)),
      ),
      body: body,
    );
  }
}

class _Attr {
  const _Attr(this.type, this.name, this.abbrev, this.statValue);
  final DamageType type;
  final String     name;
  final String     abbrev;
  final int        statValue;
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppTheme.panelBg,
      border: Border.all(color: AppTheme.cardBorder),
      borderRadius: BorderRadius.circular(4),
    ),
    child: const Text(
      'Elemental Attributes grow automatically as your hero levels up. '
      'Each attribute boosts your elemental damage output and provides '
      'resistance against that element.',
      style: TextStyle(
          color: AppTheme.textMuted, fontSize: 13, height: 1.5),
    ),
  );
}

class _AttrCard extends StatelessWidget {
  const _AttrCard({required this.attr, required this.resPct});
  final _Attr attr;
  final int   resPct;

  @override
  Widget build(BuildContext context) {
    final color   = attr.type.color;
    final resSign = resPct >= 0 ? '+' : '';
    final resColor = resPct >= 0 ? color : const Color(0xFFff4444);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        border: Border.all(color: color.withValues(alpha: 0.30)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        // Element icon + stat value badge
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text(attr.type.emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              border: Border.all(color: color.withValues(alpha: 0.50)),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text('${attr.statValue}',
                style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
          ),
        ]),

        const SizedBox(width: 16),

        // Right side: name + DMG + RES
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header row
            Row(children: [
              Text(attr.name,
                  style: AppTheme.pixelHeading(
                      fontSize: 12, letterSpacing: 1, color: color)),
              const SizedBox(width: 6),
              Text('(${attr.abbrev})',
                  style: TextStyle(
                      color: color.withValues(alpha: 0.45),
                      fontSize: 10)),
            ]),

            const SizedBox(height: 10),

            // Damage row
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  border: Border.all(color: color.withValues(alpha: 0.35)),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(attr.type.emoji,
                      style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text('DMG',
                      style: AppTheme.pixelHeading(
                          fontSize: 9,
                          letterSpacing: 1,
                          color: color.withValues(alpha: 0.8))),
                ]),
              ),
              const SizedBox(width: 10),
              Text('+${attr.statValue}%',
                  style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ]),

            const SizedBox(height: 6),

            // Resistance row
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  border: Border.all(color: color.withValues(alpha: 0.35)),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('🛡', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text('RES',
                      style: AppTheme.pixelHeading(
                          fontSize: 9,
                          letterSpacing: 1,
                          color: color.withValues(alpha: 0.8))),
                ]),
              ),
              const SizedBox(width: 10),
              Text('$resSign$resPct%',
                  style: TextStyle(
                      color: resColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ]),
          ]),
        ),
      ]),
    );
  }
}
