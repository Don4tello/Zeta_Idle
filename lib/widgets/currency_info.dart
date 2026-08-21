import 'package:flutter/material.dart';

/// A single currency/resource, with where it comes from and what it buys.
/// This list is the ONE source of truth — both the in-game tooltips
/// ([CurrencyInfo]) and the Knowledge Base "Currencies" tab render from it,
/// so descriptions can never drift apart again. Verified against game_state.
class CurrencyDef {
  const CurrencyDef({
    required this.id,
    required this.icon,
    required this.name,
    required this.color,
    required this.source,
    required this.use,
  });
  final String id;
  final String icon;
  final String name;
  final Color color;
  final String source;
  final String use;

  /// Tooltip form: "Name — source\nUsed for: use".
  String get tooltip => '$name — $source\nUsed for: $use';
}

const kCurrencies = <CurrencyDef>[
  // ── Core combat / campaign currencies ──────────────────────────────────────
  CurrencyDef(
    id: 'gold', icon: '💰', name: 'Gold', color: Color(0xFFdaa520),
    source: 'Every enemy kill and idle income; also Expeditions, Dungeons, and Events.',
    use: 'Shop stat upgrades, item & ability upgrades, and the Forge.',
  ),
  CurrencyDef(
    id: 'shards', icon: '◆', name: 'Shards', color: Color(0xFF6699ff),
    source: 'Enemy kills (bosses drop more), Dungeons, Expeditions, and Gauntlet.',
    use: 'Ability upgrades, item upgrades, and Passive Tree nodes.',
  ),
  CurrencyDef(
    id: 'echoes', icon: '🔊', name: 'Echoes', color: Color(0xFF44ccaa),
    source: 'Gauntlet runs (scales with tier and modifiers).',
    use: 'Endless upgrades (the UPGRADES tab).',
  ),
  // ── Premium ────────────────────────────────────────────────────────────────
  CurrencyDef(
    id: 'zcoins', icon: '🪙', name: 'ZCoins', color: Color(0xFFffcc44),
    source: 'Real-money purchase, plus Achievements, Bounties, Daily/Login streaks, and Gauntlet.',
    use: 'Cosmetics (auras, skins, attack effects), pets, waystones, respec, and extra character slots.',
  ),
  // ── Crafting / gear ────────────────────────────────────────────────────────
  CurrencyDef(
    id: 'gemShards', icon: '🌀', name: 'Arcane Dust', color: Color(0xFFbb88ee),
    source: 'PvP battles, Guild rewards, and disenchanting gems, runes, and gear.',
    use: 'Crafting Gems (socketed into gear) and ability Runes.',
  ),
  CurrencyDef(
    id: 'mythril', icon: '⛏', name: 'Mythril', color: Color(0xFFa8c4d4),
    source: 'Dungeons (1 per 2 floors + clear bonus), Boss Rush, and prestige milestones.',
    use: 'Artifact upgrades, dungeon affix rerolls, and shrine blessings.',
  ),
  // ── Endgame / meta ─────────────────────────────────────────────────────────
  CurrencyDef(
    id: 'towerShards', icon: '🔷', name: 'Tower Shards', color: Color(0xFF66aaff),
    source: 'Tower Ascension runs.',
    use: 'Elemental Mastery upgrades.',
  ),
  CurrencyDef(
    id: 'paragonPoints', icon: '👻', name: 'Prestige Souls', color: Color(0xFFccaaff),
    source: 'Each Rebirth (Prestige), scaled by the campaign stage you reached.',
    use: 'Permanent upgrades in the Prestige Shop.',
  ),
  CurrencyDef(
    id: 'ascensionPoints', icon: '🌟', name: 'Ascension Points', color: Color(0xFFffd966),
    source: 'Each Ascension (requires Prestige Lv 5); 3 per ascension.',
    use: 'Meta-Board nodes for permanent cross-prestige bonuses.',
  ),
];

CurrencyDef currencyById(String id) =>
    kCurrencies.firstWhere((c) => c.id == id);

/// Tooltip strings, kept for existing call sites — all derived from [kCurrencies]
/// so they stay in lockstep with the Knowledge Base reference.
class CurrencyInfo {
  static final String gold            = currencyById('gold').tooltip;
  static final String shards          = currencyById('shards').tooltip;
  static final String echoes          = currencyById('echoes').tooltip;
  static final String zcoins          = currencyById('zcoins').tooltip;
  static final String gemShards       = currencyById('gemShards').tooltip;
  static final String mythril         = currencyById('mythril').tooltip;
  static final String towerShards     = currencyById('towerShards').tooltip;
  static final String paragonPoints   = currencyById('paragonPoints').tooltip;
  static final String ascensionPoints = currencyById('ascensionPoints').tooltip;
}

/// A compact "how to get X" bar for the top of a spending/upgrade screen.
/// Reads the canonical [CurrencyDef.source], so every screen stays accurate.
class CurrencySourceBar extends StatelessWidget {
  const CurrencySourceBar(this.currencyIds, {super.key});
  final List<String> currencyIds;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1a1916),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final id in currencyIds)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 10, height: 1.35, color: Color(0xFFb7ae9f)),
                  children: [
                    TextSpan(
                      text: '${currencyById(id).icon} How to get ${currencyById(id).name}: ',
                      style: TextStyle(color: currencyById(id).color, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: currencyById(id).source),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Wraps any widget in an explanatory tooltip. Use for resources, upgrades, or
/// items whose meaning isn't obvious from the icon/label alone.
class InfoTip extends StatelessWidget {
  const InfoTip({super.key, required this.message, required this.child});
  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Tooltip(message: message, child: child);
}
