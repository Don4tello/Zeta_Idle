import 'package:flutter/material.dart';
import '../models/equipment.dart';
import '../theme/app_theme.dart';
import '../widgets/currency_info.dart';
import '../widgets/currency_icon.dart';

class KnowledgeBaseScreen extends StatelessWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFF1B1A17),
        appBar: AppBar(
          backgroundColor: const Color(0xFF2A2623),
          title: Text('KNOWLEDGE BASE',
              style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 2)),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppTheme.accentGold,
            labelColor: AppTheme.accentGold,
            unselectedLabelColor: AppTheme.textMuted,
            tabs: const [
              Tab(child: Text('STATS', style: TextStyle(fontSize: 11))),
              Tab(child: Text('KEYWORDS', style: TextStyle(fontSize: 11))),
              Tab(child: Text('SYSTEMS',  style: TextStyle(fontSize: 11))),
              Tab(child: Text('CURRENCIES', style: TextStyle(fontSize: 11))),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _StatsTab(),
            _KeywordsTab(),
            _SystemsTab(),
            _CurrenciesTab(),
          ],
        ),
      ),
    );
  }
}

// ── Stats Tab ─────────────────────────────────────────────────────────────────

class _StatEntry {
  const _StatEntry(this.abbr, this.name, this.desc);
  final String abbr;   // the acronym you see in-game
  final String name;   // what it stands for
  final String desc;   // what it does / how it helps your character
}

class _StatsTab extends StatelessWidget {
  const _StatsTab();

  // Core combat & general terms — the abbreviations that appear in battle, on
  // enemy chips, and in ability / rune text (not covered by the gear-stat enum).
  static const _combat = <_StatEntry>[
    _StatEntry('HP', 'Health Points',
        'Your life total. Reach 0 and you\'re defeated. Raised by Vitality, Max HP %, and gear.'),
    _StatEntry('ATK', 'Attack',
        'An attacker\'s hit power — shown on enemies as the damage they can roll against you.'),
    _StatEntry('DMG', 'Damage',
        'Flat damage added to every one of your hits. More DMG = harder hits.'),
    _StatEntry('DPS', 'Damage Per Second',
        'A rough measure of how much damage you output over time — higher clears content faster.'),
    _StatEntry('AC', 'Armor Class',
        'Reduces incoming physical damage. The higher your AC, the less each enemy hit takes off your HP.'),
    _StatEntry('RES', 'Resistance',
        'Reduces incoming damage of a specific element (Fire, Cold, Lightning, Poison, Void). '
        'Gems socketed in armour grant RES.'),
    _StatEntry('CRIT', 'Critical Hit Chance',
        'Chance for a hit to deal 2× damage (3× with the Critical Fury keyword).'),
    _StatEntry('PEN', 'Elemental Penetration',
        'Ignores a % of the enemy\'s elemental resistance, so your elemental hits land harder.'),
    _StatEntry('DODGE', 'Dodge / Evasion',
        'Chance to avoid an incoming attack entirely, taking no damage. Raised by Agility.'),
    _StatEntry('CD', 'Cooldown',
        'Rounds an ability must wait before it can fire again. Lower CD = it triggers more often.'),
    _StatEntry('DoT', 'Damage over Time',
        'Poison / burn / bleed that ticks for damage each round instead of all at once.'),
    _StatEntry('r', 'Rounds',
        'A duration in combat turns — e.g. "3r" means the effect lasts 3 rounds.'),
  ];

  @override
  Widget build(BuildContext context) {
    // Gear/artifact stats are rendered straight from the ItemStat enum, so this
    // reference can never drift from what items actually roll.
    final gearStats = ItemStat.values;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF181c24),
            border: Border.all(color: const Color(0xFF66aaff).withValues(alpha: 0.35)),
            borderRadius: BorderRadius.circular(3),
          ),
          child: const Text(
            'Every abbreviation you\'ll see on gear, artifacts, and in battle — '
            'what it stands for and how it improves your hero.',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.5),
          ),
        ),
        _SectionHeader(label: 'COMBAT & GENERAL', color: const Color(0xFF66aaff)),
        const SizedBox(height: 8),
        ..._combat.map((e) => _StatCard(
              abbr: e.abbr, name: e.name, desc: e.desc,
              color: const Color(0xFF66aaff))),
        const SizedBox(height: 16),
        _SectionHeader(label: 'GEAR & ARTIFACT STATS', color: AppTheme.accentGold),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF231F1B),
            border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(3),
          ),
          child: const Text(
            'The six attribute stats use fantasy names (Power, Agility, Vitality, '
            'Arcane, Focus, Fortune) — their classic Strength/Dexterity/etc. names '
            'are shown in brackets.',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.5),
          ),
        ),
        ...gearStats.map((s) => _StatCard(
              abbr: s.shortLabel, name: s.fullLabel, desc: s.description,
              color: AppTheme.accentGold)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.abbr, required this.name, required this.desc, required this.color});
  final String abbr, name, desc;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF231F1B),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Acronym badge
          Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              border: Border.all(color: color.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(abbr,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 3),
                Text(desc,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.white60, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Keywords Tab ──────────────────────────────────────────────────────────────

class _KeywordsTab extends StatelessWidget {
  const _KeywordsTab();

  @override
  Widget build(BuildContext context) {
    final standard  = ItemKeyword.values.where((k) => !k.isLegendaryOnly).toList();
    final legendary = ItemKeyword.values.where((k) =>  k.isLegendaryOnly).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader(label: 'STANDARD KEYWORDS', color: AppTheme.accentGold),
        const SizedBox(height: 8),
        ...standard.map((k) => _KeywordCard(keyword: k)),
        const SizedBox(height: 16),
        _SectionHeader(label: 'LEGENDARY-ONLY KEYWORDS', color: const Color(0xFFff88aa)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF2a0a1a),
            border: Border.all(color: const Color(0xFFff88aa).withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(3),
          ),
          child: const Text(
            'These keywords only appear on Legendary-tier items. '
            'They carry powerful effects unavailable on any other rarity.',
            style: TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.5),
          ),
        ),
        ...legendary.map((k) => _KeywordCard(keyword: k, legendary: true)),
      ],
    );
  }
}

class _KeywordCard extends StatelessWidget {
  const _KeywordCard({required this.keyword, this.legendary = false});
  final ItemKeyword keyword;
  final bool legendary;

  static const _icons = {
    ItemKeyword.lifeSteal:    '🩸',
    ItemKeyword.riposte:      '⚡',
    ItemKeyword.soulHunger:   '◆',
    ItemKeyword.vengeance:    '🔥',
    ItemKeyword.goldSense:    '💰',
    ItemKeyword.swiftStrike:  '⚔',
    ItemKeyword.criticalFury: '💥',
    ItemKeyword.ironWill:     '🛡',
    ItemKeyword.voidStep:     '👻',
    ItemKeyword.bloodPact:    '🗡',
    ItemKeyword.soulRip:      '💀',
    ItemKeyword.thornWall:    '🌵',
  };

  @override
  Widget build(BuildContext context) {
    final color = legendary ? const Color(0xFFff88aa) : AppTheme.accentGold;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: legendary
            ? const Color(0xFF1a0a12)
            : const Color(0xFF231F1B),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_icons[keyword] ?? '✦',
              style: const TextStyle(fontSize: 19)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(keyword.label,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: color)),
                  if (legendary) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFff88aa).withValues(alpha: 0.15),
                        border: Border.all(
                            color: const Color(0xFFff88aa).withValues(alpha: 0.6)),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const Text('LEGENDARY',
                          style: TextStyle(
                              fontSize: 8,
                              color: Color(0xFFff88aa),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5)),
                    ),
                  ],
                ]),
                const SizedBox(height: 3),
                Text(keyword.description,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Systems Tab ───────────────────────────────────────────────────────────────

class _SystemsTab extends StatelessWidget {
  const _SystemsTab();

  static const _systems = [
    _SystemEntry(
      icon: '⚔',
      title: 'Combat',
      color: Color(0xFFff6644),
      body: 'Your critical damage is compared against the enemy\'s armor to determine hits. '
          'Critical hits deal 2× damage (3× with Critical Fury). '
          'Elemental damage types can exploit enemy weaknesses for bonus damage.',
    ),
    _SystemEntry(
      icon: '💥',
      title: 'Combo Streak',
      color: Color(0xFFffcc44),
      body: 'Consecutive hits build Combo Stacks (max 10), each granting +5% damage. '
          'The streak resets on a miss or when you take damage. '
          'Watch the gold-to-red badge in battle — it shows your current stack.',
    ),
    _SystemEntry(
      icon: '🏰',
      title: 'Dungeon',
      color: Color(0xFF66aaff),
      body: 'Choose a path through branching rooms: combat, treasure, rest, and trap. '
          'Completing runs earns Mythril ⬡ (1 per 2 floors, capped at 10). '
          'Your deepest floor is tracked across all runs.',
    ),
    _SystemEntry(
      icon: '☠',
      title: 'Boss Rush',
      color: Color(0xFFff4422),
      body: 'Chain 5 boss fights with shared HP and a live timer. '
          'Your score is based on speed and remaining HP. '
          'Ranks (S/A/B/C/D) determine Mythril rewards (1–15 ⬡).',
    ),
    _SystemEntry(
      icon: '✦',
      title: 'Prestige',
      color: Color(0xFFccaaff),
      body: 'Available at campaign stage 25+. Resets most progress but permanently '
          'boosts gold, XP, and idle income. Earns Prestige Souls to spend in the '
          'Prestige Shop for lasting unlocks.',
    ),
    _SystemEntry(
      icon: '👑',
      title: 'Ascension',
      color: Color(0xFFcc88ff),
      body: 'Requires Prestige Level 5. Resets your prestige count entirely but grants '
          'Ascension Points for the Meta-Board — permanent bonuses that survive all '
          'future resets, including more prestiging.',
    ),
    _SystemEntry(
      icon: '⬡',
      title: 'Artifacts',
      color: Color(0xFF9966ff),
      body: 'Three slots: Ring, Amulet, Trinket. Buy artifacts with Mythril, then equip '
          'freely at no cost. Each artifact gives stat bonuses (ATK, DMG, AC, HP%, '
          'Gold%, XP%, Shard%). Only one artifact per slot can be equipped.',
    ),
    _SystemEntry(
      icon: '🧪',
      title: 'Waystones',
      color: Color(0xFF66aaff),
      body: 'Consumable boosts bought with ZCoins. Activate one to multiply idle gold '
          'for 4 hours (Basic: 2×) or 12 hours (Grand: 3×). Only one can be active '
          'at a time. The multiplier also applies to offline earnings.',
    ),
    _SystemEntry(
      icon: '🐾',
      title: 'Pet Evolution',
      color: Color(0xFF88cc44),
      body: 'Owned pets can be evolved up to 2 times using ZCoins. '
          'Each evolution level multiplies the pet\'s bonus: 1× → 1.5× → 2×. '
          'Evolution is permanent and applies to whichever slot the pet occupies.',
    ),
    _SystemEntry(
      icon: '📋',
      title: 'Bounty Board',
      color: Color(0xFFffaa44),
      body: 'Three bounties refresh every day at midnight. Progress is tracked '
          'automatically during normal play — kills, dungeon runs, endless floors, '
          'boss rush completions, and total damage all count.',
    ),
    _SystemEntry(
      icon: '♾',
      title: 'Endless Mode',
      color: Color(0xFF88cc44),
      body: 'Fight infinitely scaling enemies beyond the campaign. '
          'Each floor increases enemy stats. Corruption affixes add random '
          'modifiers. Endless upgrades unlock powerful passive abilities.',
    ),
    _SystemEntry(
      icon: '🏆',
      title: 'Leaderboard',
      color: Color(0xFFffcc44),
      body: 'Global top-50 Endless floor rankings stored in the cloud. '
          'Submit your personal best from the Leaderboard screen. '
          'Requires a signed-in account.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _systems
          .map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SystemCard(entry: s),
              ))
          .toList(),
    );
  }
}

class _SystemEntry {
  const _SystemEntry({
    required this.icon,
    required this.title,
    required this.color,
    required this.body,
  });
  final String icon;
  final String title;
  final Color color;
  final String body;
}

class _SystemCard extends StatefulWidget {
  const _SystemCard({required this.entry});
  final _SystemEntry entry;

  @override
  State<_SystemCard> createState() => _SystemCardState();
}

class _SystemCardState extends State<_SystemCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _expanded
              ? e.color.withValues(alpha: 0.06)
              : const Color(0xFF231F1B),
          border: Border.all(
            color: _expanded
                ? e.color.withValues(alpha: 0.55)
                : AppTheme.cardBorder,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(e.icon, style: const TextStyle(fontSize: 21)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(e.title,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _expanded ? e.color : Colors.white70)),
              ),
              Icon(
                _expanded ? Icons.expand_less : Icons.expand_more,
                size: 16,
                color: AppTheme.textMuted,
              ),
            ]),
            if (_expanded) ...[
              const SizedBox(height: 8),
              Text(e.body,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white60,
                      height: 1.55)),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Currencies Tab ────────────────────────────────────────────────────────────

class _CurrenciesTab extends StatelessWidget {
  const _CurrenciesTab();

  @override
  Widget build(BuildContext context) {
    // Rendered from kCurrencies — the same source that drives the in-game
    // resource tooltips, so this reference can never drift out of sync.
    return ListView(
      padding: const EdgeInsets.all(16),
      children: kCurrencies
          .map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _CurrencyCard(entry: c),
              ))
          .toList(),
    );
  }
}

class _CurrencyCard extends StatelessWidget {
  const _CurrencyCard({required this.entry});
  final CurrencyDef entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF231F1B),
        border: Border.all(color: entry.color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CurrencyIcon(id: entry.id, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: entry.color)),
                const SizedBox(height: 6),
                _Row(label: 'SOURCE', text: entry.source,
                    color: entry.color),
                const SizedBox(height: 4),
                _Row(label: 'USE', text: entry.use,
                    color: entry.color),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.text, required this.color});
  final String label;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          margin: const EdgeInsets.only(top: 1, right: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            border: Border.all(color: color.withValues(alpha: 0.45)),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 9,
                  color: color,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5)),
        ),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  fontSize: 12, color: Colors.white60, height: 1.4)),
        ),
      ],
    );
  }
}

// ── Shared ────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: AppTheme.pixelHeading(
            fontSize: 11, letterSpacing: 2, color: color));
  }
}
