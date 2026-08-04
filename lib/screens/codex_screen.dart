import 'package:flutter/material.dart';
import '../models/dnd_class.dart';
import '../models/hero_race.dart';
import '../models/hero_trait.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart' show TutorialTip;

class CodexScreen extends StatelessWidget {
  const CodexScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final body = ListView(
      padding: const EdgeInsets.all(14),
      children: [
        TutorialTip(
          tutorialKey: 'codex',
          game: game,
          text: 'The Codex explains every game system — currencies, mechanics, '
              'modes and stats. 📖 A good read whenever something feels confusing.',
        ),
        const _CodexHeader(),
        const SizedBox(height: 10),
        _Section(
          icon: '⚔',
          title: 'GAME MODES',
          color: Color(0xFFcc8844),
          initiallyExpanded: true,
          children: [
            _GameModesContent(),
          ],
        ),
        SizedBox(height: 6),
        _Section(
          icon: '📈',
          title: 'PROGRESSION SYSTEMS',
          color: Color(0xFF44cc88),
          children: [_ProgressionContent()],
        ),
        SizedBox(height: 6),
        _Section(
          icon: '🎲',
          title: 'STATS & COMBAT',
          color: Color(0xFF44aaff),
          children: [_StatsContent()],
        ),
        SizedBox(height: 6),
        _Section(
          icon: '🔮',
          title: 'ITEMS & RUNES',
          color: Color(0xFFaa66ff),
          children: [_ItemsRunesContent()],
        ),
        SizedBox(height: 6),
        _Section(
          icon: '🌐',
          title: 'EVENTS & ECONOMY',
          color: Color(0xFFff8844),
          children: [_EventsEconomyContent()],
        ),
        SizedBox(height: 6),
        _Section(
          icon: '🗡',
          title: 'CLASSES',
          color: Color(0xFFFFCC44),
          children: [_ClassesContent()],
        ),
        SizedBox(height: 6),
        _Section(
          icon: '🌍',
          title: 'RACES & TRAITS',
          color: Color(0xFFaa88ff),
          children: [_RacesContent()],
        ),
        SizedBox(height: 20),
      ],
    );

    if (embedded) {
      return Container(color: const Color(0xFF1B1A17), child: body);
    }
    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('CODEX', style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
      ),
      body: body,
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _CodexHeader extends StatelessWidget {
  const _CodexHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF231F1B),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(children: [
        const Text('📖', style: TextStyle(fontSize: 26)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ZETA IDLE — CODEX',
                style: AppTheme.pixelHeading(fontSize: 13, letterSpacing: 2, color: AppTheme.accentGold)),
            const SizedBox(height: 3),
            const Text('Everything you need to know about the game. Tap a section to expand.',
                style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ]),
        ),
      ]),
    );
  }
}

// ── Collapsible section ───────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.color,
    required this.children,
    this.initiallyExpanded = false,
  });
  final String icon;
  final String title;
  final Color color;
  final List<Widget> children;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF231F1B),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.hardEdge,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          collapsedIconColor: color.withValues(alpha: 0.6),
          iconColor: color,
          title: Row(children: [
            Text(icon, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 10),
            Text(title,
                style: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 2, color: color)),
          ]),
          children: children,
        ),
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _Entry extends StatelessWidget {
  const _Entry({required this.icon, required this.title, required this.body, this.color});
  final String icon;
  final String title;
  final String body;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.accentGold;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: c)),
            const SizedBox(height: 3),
            Text(body,
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.5)),
          ]),
        ),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      margin: const EdgeInsets.only(right: 5, bottom: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, color: color)),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      const Divider(color: AppTheme.cardBorder, height: 16, thickness: 0.5);
}

// ── Game Modes content ────────────────────────────────────────────────────────

class _GameModesContent extends StatelessWidget {
  const _GameModesContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Entry(
          icon: '🗺',
          title: 'Campaign',
          color: Color(0xFFcc9944),
          body: '100 stages across 20 zones. Every 5th stage is a boss.\n'
              'Hard Mode: unlocks at stage 50 — 2× enemy stats, +50% rewards.\n'
              '3-star system per stage: ★ Win, ★★ >50% HP, ★★★ Under 10 turns.\n'
              'Auto-Campaign: toggle in battle or settings to fight in the background.\n'
              'Battle Speed: 1×/1.5×/2× toggle available.\n'
              'Rebirth gates at stages 25, 50, 75, 100.',
        ),
        _Entry(
          icon: '♾',
          title: 'Endless Mode',
          color: Color(0xFF44cc88),
          body: 'Fight infinite waves of scaling enemies beyond stage 100.\n'
              'Each floor is harder than the last. Upgrades are purchased with Shards earned in-run.\n'
              'Milestone bonuses trigger every 50 kills (bonus gold + Shards).\n'
              'Progress resets each run — Upgrades persist across runs.',
        ),
        _Entry(
          icon: '🏰',
          title: 'The Dungeon',
          color: Color(0xFFcc8833),
          body: 'Room-by-room dungeon crawl. Rooms: Combat, Elite, Ambush, Trap, Treasure, Shrine, Chest, Rest, Boss.\n'
              'Daily affixes: Burning (fire DoT), Frozen (+20% HP), Cursed (−50% healing), Toxic (poison), Arcane (absorb).\n'
              'Tiers 1-10 scale enemies to level ranges (T1=Lv1-10, T2=Lv11-20, etc.).\n'
              'Merc abilities fire at battle start. Loot is instant — kept even on death.\n'
              'Rune drops from boss floors. Kills count toward quests and bestiary.',
        ),
        _Entry(
          icon: '⚡',
          title: 'The Gauntlet',
          color: Color(0xFF44dd88),
          body: 'Wave-based combat with challenge modifiers.\n'
              'Tiers 1-10 scale enemies like Campaign (T1=Lv1-10, etc.).\n'
              'More modifiers = higher echo multiplier (+25% per modifier).\n'
              'Rewards scale with tier: Echoes, Shards, ZCoins.\n'
              'Guaranteed rune drop on full clear. Kills count toward all tracking.',
        ),
        _Entry(
          icon: '☠',
          title: 'Boss Rush',
          color: Color(0xFFcc4444),
          body: 'Fight a chain of progressively harder bosses within a chosen tier.\n'
              'No healing between bosses — resource management is critical.\n'
              'Bosses enrage at 30% HP (deal 3× damage) and have 2 unique abilities.\n'
              'Rewards: Shards (◆), Echoes (🔊), Mythril (⬡), and ZCoins (🪙).\n'
              'Higher tiers: each tier adds +40% boss HP and +25% boss attack.',
        ),
        _Entry(
          icon: '⚔',
          title: 'PvP Arena',
          color: Color(0xFFdd3355),
          body: 'Fight AI challengers based on other heroes\' stats.\n'
              'Each match costs 1 Stamina (max 5, recharges 1 per 45 min).\n'
              'Win: +25 rating, 9 gem shards. Lose: −15 rating, 3 gem shards.\n'
              'Gem shards craft gems that socket into weapons (DMG) and armor (RES).\n'
              '~2 weeks of daily battles earns enough for a top-tier gem.\n'
              'Local leaderboard shows you vs challengers sorted by rating.',
        ),
        _Entry(
          icon: '🏰',
          title: 'Guild',
          color: Color(0xFF44ccaa),
          body: 'Join or create a guild for passive bonuses, weekly boss raids, and guild wars.\n'
              'Guild perks unlock at milestones (Lv5 Shards, Lv8 Shard Gain, Lv12 Damage, Lv20 30 members).\n'
              'Daily raid bosses rotate Mon-Sat by element. Sunday is rest day.\n'
              'Guild Wars: Mon-Tue prep, Wed-Fri battle, Sat results. Winners claim territories.\n'
              'Earn Guild Coins from boss damage and donations. Spend in the Guild Shop.',
        ),
      ],
    );
  }
}

// ── Progression content ───────────────────────────────────────────────────────

class _ProgressionContent extends StatelessWidget {
  const _ProgressionContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Entry(
          icon: '⬆',
          title: 'Leveling',
          color: Color(0xFF44cc88),
          body: 'Gain XP by winning battles. Each level-up grants:\n'
              '  • Primary stat: +1 every level\n'
              '  • Secondary stat: +1 every 2 levels\n'
              '  • Constitution: +1 every 3 levels (all classes)\n'
              '  • Milestone: +10% All Damage every 10 levels (permanent)\n'
              'XP required increases ×1.08 per level (~15 hours to reach 100).',
        ),
        _Entry(
          icon: '✦',
          title: 'Abilities',
          color: Color(0xFF44aaff),
          body: '6 abilities per class + 1 Ultimate (unlocks at Lv30).\n'
              'Upgraded with Shards (◆). Each has 3 milestone choices at ranks 5/10/15.\n'
              'Ultimates: powerful class-defining skills with 10-14 round cooldowns.\n'
              'Ability Runes: drop from bosses and can be socketed into rings/amulets.\n'
              'Runes permanently modify abilities — boosting damage, duration, or cooldown.\n'
              'Proficiency: abilities grow stronger with use (50/100/200 uses → +10/20/30%).',
        ),
        _Entry(
          icon: '🌿',
          title: 'Passive Tree',
          color: Color(0xFF44dd88),
          body: '6 branches × 7+ nodes with multi-rank upgrades (up to rank 5 each).\n'
              'Branches: Slayer, Guardian, Merchant, Mystic, Elementalist, Ascendant.\n'
              'Keystones: powerful capstone at the end of each branch (rank 1 only).\n'
              'Cross-branch connectors unlock when you invest in 2+ branches.\n'
              'Class-specific nodes visible only for your class.\n'
              'Respec: per-branch (free, 75% refund) or full reset (50 🪙, 60% refund).',
        ),
        _Entry(
          icon: '🏆',
          title: 'Endless Upgrades',
          color: Color(0xFF88aaff),
          body: 'Permanent upgrades that boost all combat performance.\n'
              'Purchased with Echoes earned from Gauntlet runs.\n'
              'Examples: increased damage, bonus gold, HP recovery, and more.',
        ),
        _Entry(
          icon: '☠',
          title: 'Rebirth (Prestige)',
          color: Color(0xFFcc88ff),
          body: 'A voluntary reset available at Rebirth Gates (stages 25 / 50 / 75 / 100).\n'
              'You KEEP: shards, echoes, souls, ability upgrades, prestige shop unlocks.\n'
              'You LOSE: hero level, gold, general upgrades, idle/endless perks.\n'
              'Rewards: Souls (based on stage reached) + permanent multipliers:\n'
              '  • +10% gold income per rebirth\n'
              '  • +5% XP gain per rebirth\n'
              '  • +5% idle gold per rebirth',
        ),
        _Entry(
          icon: '✦',
          title: 'Ascension',
          color: Color(0xFFaaddff),
          body: 'A deeper reset beyond Rebirth, requiring significant Prestige progress.\n'
              'Awards Ascension Points used in the Ascension shop for powerful permanent upgrades.\n'
              'Ascension resets more — but the bonuses are proportionally stronger.',
        ),
        _Entry(
          icon: '💀',
          title: 'Souls & Prestige Shop',
          color: Color(0xFFcc8844),
          body: 'Souls are earned by Prestiging and spent in the Prestige Shop.\n'
              'Notable unlocks: Master Forger (fewer items to combine), expanded forge options,\n'
              'bonus combat perks, and quality-of-life improvements.',
        ),
        _Entry(
          icon: '🤝',
          title: 'Mercenaries',
          color: Color(0xFF44ddcc),
          body: 'Companions that permanently join your roster when you hit a milestone (kills, stage, dungeon clears, etc.).\n'
              'Each merc has a passive bonus that scales per level (max 5) and a unique active ability that triggers in battle.\n'
              'Level up with Shards ◆ + ZCoins 🪙 — costs rise steeply at higher levels.\n'
              'Pair certain mercs at the required level to activate Synergy bonuses (bonus ATK, Gold%, etc.).\n'
              'All merc bonuses are visible in HERO → BONUSES → MERCENARIES section.',
        ),
      ],
    );
  }
}

// ── Stats & Combat content ────────────────────────────────────────────────────

class _StatsContent extends StatelessWidget {
  const _StatsContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ABILITY SCORES',
            style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2, color: AppTheme.textMuted)),
        const SizedBox(height: 10),
        for (final row in _scores)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                width: 38,
                child: Text(row.$1,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentGold)),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(row.$2,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.4)),
              ),
            ]),
          ),
        const _Divider(),

        Text('MODIFIER FORMULA',
            style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2, color: AppTheme.textMuted)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF181614),
            border: Border.all(color: AppTheme.cardBorder),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Modifier = (Score − 10) ÷ 2  (rounded down)',
                  style: TextStyle(fontSize: 12, color: AppTheme.textLight,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Wrap(spacing: 8, runSpacing: 4, children: [
                for (final r in _modTable)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.cardBorder),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(r,
                        style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                  ),
              ]),
            ],
          ),
        ),
        const _Divider(),

        Text('COMBAT FORMULAS',
            style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2, color: AppTheme.textMuted)),
        const SizedBox(height: 10),
        for (final row in _formulas)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(row.$1,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                      color: Color(0xFF88aaff))),
              const SizedBox(height: 2),
              Text(row.$2,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.4)),
            ]),
          ),
        const _Divider(),

        Text('IDLE & ECONOMY',
            style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 2, color: AppTheme.textMuted)),
        const SizedBox(height: 10),
        for (final row in _economy)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                width: 90,
                child: Text(row.$1,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                        color: AppTheme.accentGold)),
              ),
              Expanded(
                child: Text(row.$2,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              ),
            ]),
          ),
      ],
    );
  }

  static const _scores = [
    ('STR', 'Strength — scales Physical damage %. Each point of STR = +0.25% physical damage output.'),
    ('DEX', 'Dexterity — scales Lightning damage %. Each point of DEX = +0.25% lightning damage output.'),
    ('CON', 'Constitution — scales Poison damage %. Each point of CON = +0.25% poison damage output.'),
    ('INT', 'Intelligence — scales Void damage %. Each point of INT = +0.25% void damage output.'),
    ('WIS', 'Wisdom — scales Cold damage %. Each point of WIS = +0.25% cold damage output.'),
    ('CHA', 'Charisma — scales Fire damage %. Each point of CHA = +0.25% fire damage output.'),
  ];

  static const _modTable = [
    '1 → −5', '8–9 → −1', '10–11 → 0', '12–13 → +1',
    '14–15 → +2', '16–17 → +3', '18–19 → +4', '20 → +5',
  ];

  static const _formulas = [
    ('Proficiency Bonus',
        '= 2 + (Level − 1) ÷ 4\n'
        'Increases at levels 5, 9, 13, 17, 21 … Adds to Attack Bonus.'),
    ('Critical Damage',
        '= Proficiency Bonus + gear + passives\n'
        'Compared against enemy armor to determine hits. Higher critical damage = more consistent damage.\n'
        'Critical hits deal double damage.'),
    ('Damage',
        '= Base (scales with level) + flat bonuses\n'
        'Multiplied by elemental damage %, ability bonuses, and streak bonuses.\n'
        'Minimum 1 damage per hit.'),
    ('Armor',
        '= 10 (flat base)\n'
        'Higher armor reduces incoming physical damage. Boost via gear and passive nodes.'),
    ('Max HP',
        '= 100 + (Level − 1) × 10\n'
        'Equipment, trait bonuses, and passive nodes apply a % multiplier on top. Capped at 9 999.\n'
        'CON no longer scales HP — boost Max HP via passive nodes, traits, or gear.'),
    ('XP Multiplier',
        '= 1.0 (base)\n'
        'Increased by Prestige multipliers (+5% per rebirth), passive nodes, and ally bonuses.\n'
        'CHA no longer multiplies XP — invest in Prestige or passive nodes for XP gains.'),
    ('Boss Abilities',
        'Every named boss has 2 unique abilities that fire on cooldown during their turn.\n'
        'Effect types: Bonus Damage (instant hit), DoT (damage per round), Stun (skip your turn).\n'
        'Damage follows the boss\'s damage type and respects your resistances.\n'
        'Bosses never regenerate HP — zone regen and affixes do not apply to them.\n'
        'Active boss effects (stun, DoT) appear in the STATUS panel during battle.'),
    ('All Damage % (%DMG)',
        'Scales final damage output multiplicatively after all flat bonuses.\n'
        'Sources: Passive Tree nodes, %DMG item stat (weapons/accessories),\n'
        'and Level Milestones (+10% per 10 hero levels). All additive with each other.'),
  ];

  static const _economy = [
    ('Idle Rate', '5/tick (flat base) while not in battle. Boosted by Prestige shop, passive nodes, and WIS-stat equipment.'),
    ('Gold Rate',  '1× bonus gold per kill (flat base). Boosted by Prestige multipliers, passive nodes, and gear.'),
    ('Shards (◆)',  'From kills, Dungeons, and Expeditions. Spent on ability upgrades, item upgrades, and the Passive Tree.'),
    ('Echoes (🔊)', 'From Gauntlet and Boss Rush. Spent on Upgrades.'),
    ('Souls (☠)',  'From Prestige. Spent in the Prestige Shop.'),
    ('Arcane Dust 🌀', 'From PvP, Guild rewards, and disenchanting gems, runes, and gear. Used to craft Gems and ability Runes.'),
  ];
}

// ── Classes content ───────────────────────────────────────────────────────────

class _ClassesContent extends StatelessWidget {
  const _ClassesContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: DndClass.values.map((cls) => _ClassCard(cls: cls)).toList(),
    );
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.cls});
  final DndClass cls;

  static int _mod(int s) => (s - 10) ~/ 2;
  static String _sign(int m) => m >= 0 ? '+$m' : '$m';

  @override
  Widget build(BuildContext context) {
    final info = cls.info;
    final stats = [
      ('STR', info.str), ('DEX', info.dex), ('CON', info.con),
      ('INT', info.intelligence), ('WIS', info.wis), ('CHA', info.cha),
    ];

    // Highlight the highest stat as the primary
    final maxStat = stats.map((s) => s.$2).reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1714),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(info.displayName.toUpperCase(),
                  style: AppTheme.pixelHeading(
                      fontSize: 12, letterSpacing: 1, color: AppTheme.accentGold)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withValues(alpha: 0.08),
                border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(info.primaryAbility,
                  style: const TextStyle(fontSize: 10, color: AppTheme.accentGold)),
            ),
          ]),
          const SizedBox(height: 4),
          Text(info.flavor,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textMuted,
                  fontStyle: FontStyle.italic, height: 1.4)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: stats.map((s) {
              final isPrimary = s.$2 == maxStat;
              final mod = _mod(s.$2);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: isPrimary
                      ? AppTheme.accentGold.withValues(alpha: 0.12)
                      : const Color(0xFF1A1714),
                  border: Border.all(
                    color: isPrimary
                        ? AppTheme.accentGold.withValues(alpha: 0.6)
                        : AppTheme.cardBorder,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Column(
                  children: [
                    Text(s.$1,
                        style: TextStyle(
                            fontSize: 9,
                            color: isPrimary ? AppTheme.accentGold : AppTheme.textMuted,
                            letterSpacing: 0.5)),
                    Text('${s.$2}',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isPrimary ? AppTheme.accentGold : AppTheme.textLight)),
                    Text(_sign(mod),
                        style: TextStyle(
                            fontSize: 9,
                            color: mod > 0
                                ? const Color(0xFF44cc88)
                                : mod < 0
                                    ? const Color(0xFFcc4444)
                                    : AppTheme.textMuted)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Races & Traits content ────────────────────────────────────────────────────

class _RacesContent extends StatelessWidget {
  const _RacesContent();

  static HeroTrait? _traitFor(HeroRace race) {
    try {
      return HeroTrait.all.firstWhere((t) => t.heroRace == race);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: HeroRace.values.map((race) {
        final trait = _traitFor(race);
        return _RaceCard(race: race, trait: trait);
      }).toList(),
    );
  }
}

class _RaceCard extends StatelessWidget {
  const _RaceCard({required this.race, required this.trait});
  final HeroRace race;
  final HeroTrait? trait;

  @override
  Widget build(BuildContext context) {
    final info  = race.info;
    final t     = trait;
    final color = info.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1714),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(info.icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(info.displayName.toUpperCase(),
                    style: AppTheme.pixelHeading(
                        fontSize: 12, letterSpacing: 1, color: color)),
                Text(info.description,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textMuted,
                        fontStyle: FontStyle.italic)),
              ]),
            ),
          ]),
          if (t != null) ...[
            const SizedBox(height: 8),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t.name,
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 3),
                  Text(t.description,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textMuted, height: 1.4)),
                  const SizedBox(height: 5),
                  Wrap(children: _bonusChips(t, color)),
                ]),
              ),
            ]),
          ],
        ],
      ),
    );
  }

  List<Widget> _bonusChips(HeroTrait t, Color color) {
    final chips = <Widget>[];
    void add(int v, String label) {
      if (v == 0) return;
      final positive = v > 0;
      final c = positive ? const Color(0xFF44cc88) : const Color(0xFFcc4444);
      chips.add(_Chip('${positive ? '+' : ''}$v% $label', c));
    }
    add(t.xpPct,    'XP');
    add(t.goldPct,  'Gold');
    add(t.shardPct, 'Shards');
    add(t.hpPct,    'HP');
    add(t.dmgPct,   'Damage');
    if (t.cooldownReduction > 0) {
      chips.add(_Chip('−${t.cooldownReduction} Cooldown', const Color(0xFF44aaff)));
    }
    if (t.critImmune) {
      chips.add(const _Chip('Crit Immune', Color(0xFFccaa44)));
    }
    return chips;
  }
}

// ── Items & Runes codex ─────────────────────────────────────────────────────

class _ItemsRunesContent extends StatelessWidget {
  const _ItemsRunesContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Entry(
          icon: '⚔',
          title: 'Equipment & Weapon Damage',
          color: Color(0xFF88aadd),
          body: '11 gear slots: Weapon, Off Hand, Helmet, Armor, Gauntlets, Leg Guards, Ring ×2, Amulet, Boots, Relic.\n'
              'Weapons have Base Damage that scales with level and rarity.\n'
              'Base Damage replaces the old d8 roll — higher weapons = higher floor damage.\n'
              'Auto-Equip and Auto-Salvage toggles available in Settings.',
        ),
        _Entry(
          icon: '⬆',
          title: 'Item Upgrades (+0 to +10)',
          color: Color(0xFFaa66ff),
          body: 'Upgrade any item from +0 to +10 at the Forge.\n'
              'Each tier boosts ALL stat bonuses by 8% + weapon base damage.\n'
              '+5: earns a "Refined" prefix (Refined, Honed, Tempered, Polished, Hardened).\n'
              '+10: earns a "Masterwork" prefix (Masterwork, Exalted, Perfected, Ascendant, Mythforged).\n'
              'Costs Gold + Shards per tier. Salvaging refunds 33% of upgrade costs.',
        ),
        _Entry(
          icon: '💎',
          title: 'Gems',
          color: Color(0xFFcc88ff),
          body: '6 elemental gems matching damage types: Ruby (Fire), Sapphire (Cold), Diamond (Lightning), Emerald (Poison), Amethyst (Void), Onyx (Physical).\n'
              '5 tiers: Flawed (3%), Standard (6%), Polished (10%), Radiant (15%), Exalted (22%).\n'
              'Weapon gems = +DMG%. Armor gems = +RES%. Crafted from Arcane Dust.',
        ),
        _Entry(
          icon: '🔮',
          title: 'Ability Runes',
          color: Color(0xFF9966ff),
          body: '10 runes per class (120 total). Permanently modify specific abilities.\n'
              'Effects: +damage%, +duration, −cooldown. Socket into Rings or Amulets.\n'
              'Drop sources: Campaign bosses (10%), Dungeon bosses (10%), Gauntlet clear (guaranteed),\n'
              'Boss Rush clear (guaranteed), Endless every 10 stages, Long expeditions (10%).\n'
              'Duplicate drops auto-convert to Arcane Dust.',
        ),
        _Entry(
          icon: '🏺',
          title: 'Artifacts',
          color: Color(0xFF9944cc),
          body: '7 types: Idol, Cross, Book, Sword, Gemstone, Charm, Tapestry.\n'
              '3 rarities: Common, Magic, Rare — each with unique art.\n'
              'Place in a 3×3 grid for permanent passive bonuses.\n'
              'Forge with Mythril (⬡). Salvage for 33% Mythril refund.',
        ),
        _Entry(
          icon: '◈',
          title: 'Set Items',
          color: Color(0xFF00cc88),
          body: 'Equipping multiple pieces of the same set grants bonus stats.\n'
              'Each set specifies which slots it covers and tiered bonuses (2pc, 3pc, 4pc).\n'
              'Set bonuses stack with all other gear bonuses.',
        ),
      ],
    );
  }
}

// ── Events & Economy codex ──────────────────────────────────────────────────

class _EventsEconomyContent extends StatelessWidget {
  const _EventsEconomyContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Entry(
          icon: '🌐',
          title: 'World Events (13-week rotation)',
          color: Color(0xFFff8844),
          body: '13 weekly events, each with 2 damage types and unique enemies.\n'
              'Event enemies have a 15% chance to spawn during any battle.\n'
              'Killing them awards Omega Tokens (Ω) for the event shop.\n'
              'Omega Shop: currency rewards (gold, zcoins, essence, mythril) +\n'
              'level-appropriate Epic and Legendary gear. Resets weekly.',
        ),
        _Entry(
          icon: '⚡',
          title: 'Flash Events',
          color: Color(0xFFffaa33),
          body: '2-hour micro-events that trigger randomly (~17% chance per hour).\n'
              '8 types: Gold Rush, XP Surge, Shard Storm, Boss Invasion,\n'
              'Echo Resonance, Crystal Rain, Forge Frenzy, Arena Fury.\n'
              'Active event shown as orange banner at top of screen.',
        ),
        _Entry(
          icon: '📅',
          title: 'Season Pass (monthly)',
          color: Color(0xFFcc88ff),
          body: '30 tiers of rewards, resets on the 1st of each month.\n'
              'Earn Season XP from battles (+3), bosses (+10), campaign stages (+5),\n'
              'PvP wins (+8), and weekly challenge claims (+50).\n'
              'Free + premium tier rewards at each level.',
        ),
        _Entry(
          icon: '📋',
          title: 'Weekly Challenges',
          color: Color(0xFF44ccaa),
          body: '5 challenges per week, randomly selected from 8 types.\n'
              'Types: kills, PvP wins, dungeon floors, gold, bosses, gauntlet, stages, crafting.\n'
              'Completing gives resources + 50 season XP. Resets weekly.',
        ),
        _Entry(
          icon: '💰',
          title: 'Currencies',
          color: Color(0xFFdaa520),
          body: '💰 Gold — kills, idle, expeditions. Buys gear, upgrades, shop items.\n'
              '◆ Shards — kills, dungeons, expeditions. Ability & item upgrades and passive nodes.\n'
              '🪙 ZCoins — login, events, gauntlet. Premium purchases.\n'
              '🔊 Echoes — gauntlet runs. Buys endless upgrades.\n'
              '⬡ Mythril — boss rush, events. Forges artifacts.\n'
              'Ω Omega Tokens — world event kills. Event shop currency.\n'
              '🌀 Arcane Dust — PvP, guild, disenchanting gems/runes/gear. Crafts gems & runes.',
        ),
        _Entry(
          icon: '⚜',
          title: 'Medieval Power',
          color: Color(0xFFdaa520),
          body: 'A combined score of all your upgrades, gear, passives, prestige,\n'
              'artifacts, allies, PvP rating, and more.\n'
              'Tiers: Novice → Apprentice → Seasoned → Veteran → Epic → Legendary → Mythic.\n'
              'Displayed on the hero dashboard.',
        ),
      ],
    );
  }
}
