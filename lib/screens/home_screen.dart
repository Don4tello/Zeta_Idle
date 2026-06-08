import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/game_state.dart';
import '../screens/endless_upgrade_screen.dart';
import '../widgets/battle_sprites.dart';
import '../widgets/section_card.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onBackToSelect});

  final VoidCallback onBackToSelect;

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1f3a),
        title: const Text('ZETA IDLE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppTheme.textMuted),
            onPressed: () => Navigator.pushNamed(context, '/knowledge-base'),
            tooltip: 'Knowledge Base',
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: AppTheme.textMuted),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Hero Card ─────────────────────────────────────────────────────
            SectionCard(
              title: game.hero.name,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 90,
                        height: 130,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0a0c18),
                          border: Border.all(
                              color: AppTheme.accentGold.withValues(alpha: 0.4),
                              width: 1),
                        ),
                        child: Center(
                          child: BattleSprite(
                            spriteId: game.hero.spriteId,
                            auraColor: game.heroAuraColor,
                            auraIntensity: game.heroAuraIntensity,
                            colorFilter: game.heroSkinFilter,
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .scale(
                              begin: const Offset(0.85, 0.85),
                              duration: 400.ms,
                              curve: Curves.easeOut),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Expanded(
                                  child: _buildStatDisplay(
                                      'NAME', game.hero.name)),
                              _buildLevelBadge(game.hero.level),
                            ]),
                            const SizedBox(height: 8),
                            Row(children: [
                              Expanded(child: _buildDndStat('PWR',
                                  game.hero.power, game.hero.strMod)),
                              const SizedBox(width: 5),
                              Expanded(child: _buildDndStat('AGI',
                                  game.hero.agility, game.hero.dexMod)),
                              const SizedBox(width: 5),
                              Expanded(child: _buildDndStat('VIT',
                                  game.hero.vitality, game.hero.conMod)),
                            ]),
                            const SizedBox(height: 5),
                            Row(children: [
                              Expanded(child: _buildDndStat('ARC',
                                  game.hero.arcane, game.hero.intMod)),
                              const SizedBox(width: 5),
                              Expanded(child: _buildDndStat('FOC',
                                  game.hero.focus, game.hero.wisMod)),
                              const SizedBox(width: 5),
                              Expanded(child: _buildDerivedStat(
                                  'AC', '${game.hero.armorClass}')),
                            ]),
                            const SizedBox(height: 8),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      'HP  ${game.hero.currentHealth}/${game.hero.maxHealth}',
                                      style: AppTheme.pixelHeading(
                                          fontSize: 9,
                                          letterSpacing: 1,
                                          color: const Color(0xFF88cc44))),
                                ]),
                            const SizedBox(height: 3),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: game.hero.currentHealth /
                                    game.hero.maxHealth.toDouble(),
                                minHeight: 5,
                                backgroundColor: AppTheme.cardBorder,
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                        Color(0xFF88cc44)),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('EXP',
                                      style: AppTheme.pixelHeading(
                                          fontSize: 9, letterSpacing: 1)),
                                  Text(
                                      '${game.hero.experience} / ${game.hero.experienceToNextLevel}',
                                      style: const TextStyle(
                                          fontSize: 9,
                                          color: AppTheme.textMuted)),
                                ]),
                            const SizedBox(height: 3),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: game.hero.progress,
                                minHeight: 5,
                                backgroundColor: AppTheme.cardBorder,
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                        AppTheme.accentGold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 350.ms)
                .slideY(
                    begin: 0.04,
                    duration: 350.ms,
                    curve: Curves.easeOut),
            const SizedBox(height: 16),

            // ── Resources ────────────────────────────────────────────────────
            SectionCard(
              title: 'Resources',
              child: Column(children: [
                Row(children: [
                  Expanded(
                      child: _buildResourceBox(
                          '💰', 'GOLD', _fmt(game.gold))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildResourceBox(
                          '◆', 'SHARDS', _fmtShards(game.shards))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildResourceBox(
                          '💎', 'CRYSTALS', '${game.crystals}')),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                      child: _buildResourceBox(
                          '⚗', 'ESSENCE', _fmt(game.essence))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildResourceBox(
                          '🔩', 'MYTHRIL', '${game.mythril}')),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildResourceBox(
                          '⚡', 'IDLE/min',
                          '${game.idleGoldPerMinute}')),
                ]),
              ]),
            )
                .animate(delay: 80.ms)
                .fadeIn(duration: 350.ms)
                .slideY(
                    begin: 0.04,
                    duration: 350.ms,
                    curve: Curves.easeOut),
            const SizedBox(height: 16),

            // ── Campaign status ───────────────────────────────────────────────
            SectionCard(
              title: 'Current Campaign',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('STAGE ${game.campaignStageIndex + 1}',
                      style: AppTheme.pixelHeading(
                          fontSize: 12, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.darkBg,
                      border: Border.all(
                          color: AppTheme.cardBorder, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.currentCampaignStage.title,
                          style: GoogleFonts.pixelifySans(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textLight,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Difficulty: ${game.currentCampaignStage.difficulty}',
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
                .animate(delay: 160.ms)
                .fadeIn(duration: 350.ms)
                .slideY(
                    begin: 0.04,
                    duration: 350.ms,
                    curve: Curves.easeOut),
            const SizedBox(height: 16),

            // ── Quick Access Grid ─────────────────────────────────────────────
            _QuickAccessGrid(game: game)
                .animate(delay: 200.ms)
                .fadeIn(duration: 350.ms)
                .slideY(
                    begin: 0.04,
                    duration: 350.ms,
                    curve: Curves.easeOut),
            const SizedBox(height: 20),

            // ── Combat section ────────────────────────────────────────────────
            _SectionHeader(icon: '⚔', label: 'COMBAT',
                color: const Color(0xFFff6644)),
            const SizedBox(height: 10),
            _buildModeButton(context, '📜  CAMPAIGN',
                () => Navigator.pushNamed(context, '/campaign')),
            const SizedBox(height: 8),
            _buildModeButton(context, '⚔️  QUICK BATTLE', () {
              game.startBattle();
              Navigator.pushNamed(context, '/battle');
            }),
            const SizedBox(height: 8),
            _buildModeButton(context, '♾️  ENDLESS MODE',
                () => Navigator.pushNamed(context, '/endless')),
            const SizedBox(height: 8),
            _buildModeButton(context, '🎯  DAILY CHALLENGES',
                () => Navigator.pushNamed(context, '/daily')),
            const SizedBox(height: 8),
            _buildModeButton(context, '☠  BOSS RUSH',
                () => Navigator.pushNamed(context, '/boss-rush')),
            const SizedBox(height: 8),
            _buildModeButton(context, '⚔  CHALLENGE GAUNTLET',
                () => Navigator.pushNamed(context, '/gauntlet')),
            const SizedBox(height: 8),
            _buildModeButton(context, '🏰  DUNGEON',
                () => Navigator.pushNamed(context, '/dungeon')),
            const SizedBox(height: 20),

            // ── Character section ─────────────────────────────────────────────
            _SectionHeader(icon: '🧙', label: 'CHARACTER',
                color: const Color(0xFF66aaff)),
            const SizedBox(height: 10),
            _buildModeButton(context, '📋  CHARACTER SHEET',
                () => Navigator.pushNamed(context, '/dashboard')),
            const SizedBox(height: 8),
            _buildModeButton(context, '⬆  UPGRADES',
                () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const EndlessUpgradeScreen()))),
            const SizedBox(height: 8),
            _buildModeButton(context, '⚡  ABILITIES',
                () => Navigator.pushNamed(context, '/ability-upgrades')),
            const SizedBox(height: 8),
            _buildModeButton(context, '🌿  PASSIVES',
                () => Navigator.pushNamed(context, '/passive-tree')),
            const SizedBox(height: 8),
            _buildModeButton(context, '⚔  MASTERIES',
                () => Navigator.pushNamed(context, '/mastery')),
            const SizedBox(height: 8),
            _buildModeButtonBadged(
              context,
              game.subclassAvailable
                  ? '✨  SUBCLASS  (READY)'
                  : '✨  SUBCLASS',
              () => Navigator.pushNamed(context, '/subclass'),
              badge: game.subclassAvailable,
            ),
            const SizedBox(height: 20),

            // ── Progression section ───────────────────────────────────────────
            _SectionHeader(icon: '⬆', label: 'PROGRESSION',
                color: const Color(0xFFaa88ff)),
            const SizedBox(height: 10),
            _buildModeButton(context, '✦  PRESTIGE',
                () => Navigator.pushNamed(context, '/prestige')),
            const SizedBox(height: 8),
            _buildModeButton(context, '✦  ASCENSION',
                () => Navigator.pushNamed(context, '/ascension')),
            const SizedBox(height: 8),
            _buildModeButtonBadged(
              context,
              '🏆  ACHIEVEMENTS',
              () => Navigator.pushNamed(context, '/achievements'),
              badge: game.achievementsClaimable > 0,
            ),
            const SizedBox(height: 20),

            // ── Economy section ───────────────────────────────────────────────
            _SectionHeader(icon: '💰', label: 'ECONOMY & CRAFTING',
                color: const Color(0xFFffdd44)),
            const SizedBox(height: 10),
            _buildModeButton(context, '🎒  INVENTORY',
                () => Navigator.pushNamed(context, '/inventory')),
            const SizedBox(height: 8),
            _buildModeButton(context, '🔨  FORGE',
                () => Navigator.pushNamed(context, '/forge')),
            const SizedBox(height: 8),
            _buildModeButton(context, '⬡  ARTIFACT FORGE',
                () => Navigator.pushNamed(context, '/artifacts')),
            const SizedBox(height: 8),
            _buildModeButton(context, '✦  RUNE FORGE',
                () => Navigator.pushNamed(context, '/rune-forge')),
            const SizedBox(height: 8),
            _buildModeButton(context, '🛒  MERCHANT',
                () => Navigator.pushNamed(context, '/shop')),
            const SizedBox(height: 8),
            _buildModeButton(context, '🗺  EXPEDITIONS',
                () => Navigator.pushNamed(context, '/expedition')),
            const SizedBox(height: 20),

            // ── Events section ────────────────────────────────────────────────
            _SectionHeader(icon: '📅', label: 'EVENTS',
                color: const Color(0xFF44ccaa)),
            const SizedBox(height: 10),
            _buildModeButton(context, '📋  BOUNTY BOARD',
                () => Navigator.pushNamed(context, '/bounty-board')),
            const SizedBox(height: 8),
            _buildModeButton(context, '🌐  WORLD EVENT',
                () => Navigator.pushNamed(context, '/world-event')),
            const SizedBox(height: 8),
            _LoginStreakButton(),
            const SizedBox(height: 8),
            _buildModeButton(context, '🏆  LEADERBOARD',
                () => Navigator.pushNamed(context, '/leaderboard')),
            const SizedBox(height: 20),

            // ── Lore & More section ───────────────────────────────────────────
            _SectionHeader(icon: '📚', label: 'LORE & MORE',
                color: const Color(0xFF88aacc)),
            const SizedBox(height: 10),
            _buildModeButton(context, '📖  BESTIARY',
                () => Navigator.pushNamed(context, '/bestiary')),
            const SizedBox(height: 8),
            _buildModeButtonBadged(
              context,
              game.questsClaimable > 0
                  ? '📜  QUESTLINES  (${game.questsClaimable} ready)'
                  : '📜  QUESTLINES',
              () => Navigator.pushNamed(context, '/quests'),
              badge: game.questsClaimable > 0,
            ),
            const SizedBox(height: 8),
            _buildModeButton(context, '🤝  MERCENARIES',
                () => Navigator.pushNamed(context, '/npc-allies')),
            const SizedBox(height: 8),
            _buildModeButton(context, '⚠  CHALLENGE MODIFIERS',
                () => Navigator.pushNamed(context, '/challenge-modifiers')),
            const SizedBox(height: 8),
            _buildModeButton(context, '💎  COSMETICS',
                () => Navigator.pushNamed(context, '/aura-shop')),
            const SizedBox(height: 8),
            _buildModeButton(context, '❓  KNOWLEDGE BASE',
                () => Navigator.pushNamed(context, '/knowledge-base')),
            const SizedBox(height: 20),

            // ── Last action bar ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                border: Border.all(color: AppTheme.cardBorder, width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(children: [
                const Icon(Icons.info_outline,
                    size: 16, color: AppTheme.accentGold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    game.lastAction,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLight,
                        fontStyle: FontStyle.italic),
                  ),
                ),
              ]),
            )
                .animate(delay: 400.ms)
                .fadeIn(duration: 350.ms),
            const SizedBox(height: 8),

            // ── Back to character select ──────────────────────────────────────
            GestureDetector(
              onTap: onBackToSelect,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.cardBorder, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_back,
                        size: 14, color: AppTheme.textMuted),
                    const SizedBox(width: 8),
                    Text(
                      'CHARACTER SELECTION',
                      style: AppTheme.pixelHeading(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                          letterSpacing: 2),
                    ),
                  ],
                ),
              ),
            )
                .animate(delay: 460.ms)
                .fadeIn(duration: 350.ms),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── Helper builders ───────────────────────────────────────────────────────

  Widget _buildLevelBadge(int level) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.accentGold, width: 1),
        color: AppTheme.darkBg,
      ),
      child:
          Text('Lv $level', style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 1)),
    );
  }

  static const Map<String, IconData> _statIcons = {
    'STR': Icons.fitness_center,
    'DEX': Icons.directions_run,
    'CON': Icons.favorite,
    'INT': Icons.psychology,
    'WIS': Icons.visibility,
    'AC':  Icons.shield,
  };

  Widget _buildDndStat(String abbr, int score, int mod) {
    final sign = mod >= 0 ? '+' : '';
    final modColor = mod > 0
        ? AppTheme.accentGold
        : mod < 0
            ? const Color(0xFFcc4444)
            : AppTheme.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.darkBg,
        border: Border.all(color: AppTheme.cardBorder, width: 1),
      ),
      child: Column(children: [
        Icon(_statIcons[abbr] ?? Icons.circle,
            size: 12, color: AppTheme.accentGold.withValues(alpha: 0.8)),
        const SizedBox(height: 2),
        Text(abbr,
            style: AppTheme.pixelHeading(fontSize: 8, letterSpacing: 0)),
        Text('$score',
            style: GoogleFonts.pixelifySans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textLight)),
        Text('$sign$mod',
            style: AppTheme.pixelHeading(fontSize: 8, color: modColor)),
      ]),
    );
  }

  Widget _buildDerivedStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.darkBg,
        border: Border.all(color: AppTheme.cardBorder, width: 1),
      ),
      child: Column(children: [
        Icon(_statIcons[label] ?? Icons.circle,
            size: 12, color: AppTheme.accentGold.withValues(alpha: 0.8)),
        const SizedBox(height: 2),
        Text(label,
            style: AppTheme.pixelHeading(fontSize: 8, letterSpacing: 0)),
        Text(value,
            style: GoogleFonts.pixelifySans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textLight)),
        Text('—',
            style:
                AppTheme.pixelHeading(fontSize: 8, color: AppTheme.textMuted)),
      ]),
    );
  }

  Widget _buildStatDisplay(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTheme.pixelHeading(fontSize: 10, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.pixelifySans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.textLight)),
      ],
    );
  }

  Widget _buildResourceBox(String emoji, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: AppTheme.darkBg,
        border: Border.all(color: AppTheme.cardBorder, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(label,
            style: AppTheme.pixelHeading(fontSize: 8, letterSpacing: 0.5)),
        const SizedBox(height: 3),
        Text(value,
            style: GoogleFonts.pixelifySans(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.textLight)),
      ]),
    );
  }

  static String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  static String _fmtShards(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  Widget _buildModeButton(
          BuildContext context, String label, VoidCallback onPressed) =>
      _buildModeButtonBadged(context, label, onPressed, badge: false);

  Widget _buildModeButtonBadged(BuildContext context, String label,
      VoidCallback onPressed, {required bool badge}) {
    final borderColor =
        badge ? const Color(0xFFaacc44) : AppTheme.accentGold;
    final labelColor =
        badge ? const Color(0xFFaacc44) : AppTheme.accentGold;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: badge
                ? const Color(0xFFaacc44).withValues(alpha: 0.06)
                : null,
            border: Border.all(color: borderColor, width: badge ? 1.5 : 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(children: [
            Expanded(
              child: Text(label,
                  style: AppTheme.pixelHeading(
                      fontSize: 11,
                      letterSpacing: 1,
                      color: labelColor)),
            ),
            Icon(Icons.arrow_forward_ios, color: borderColor, size: 14),
          ]),
        ),
      ),
    );
  }
}

// ── Quick Access Grid ─────────────────────────────────────────────────────────

class _QuickItem {
  const _QuickItem(this.emoji, this.label, this.onTap);
  final String emoji;
  final String label;
  final VoidCallback onTap;
}

class _QuickAccessGrid extends StatelessWidget {
  const _QuickAccessGrid({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final items = [
      _QuickItem('📜', 'CAMPAIGN',   () => Navigator.pushNamed(context, '/campaign')),
      _QuickItem('⚔️', 'BATTLE',    () { game.startBattle(); Navigator.pushNamed(context, '/battle'); }),
      _QuickItem('♾️', 'ENDLESS',   () => Navigator.pushNamed(context, '/endless')),
      _QuickItem('🎒', 'INVENTORY', () => Navigator.pushNamed(context, '/inventory')),
      _QuickItem('🔨', 'FORGE',     () => Navigator.pushNamed(context, '/forge')),
      _QuickItem('📋', 'CHARACTER', () => Navigator.pushNamed(context, '/dashboard')),
    ];

    Widget row(List<_QuickItem> rowItems) => Row(
      children: rowItems.asMap().entries.map((e) {
        final last = e.key == rowItems.length - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: last ? 0 : 8),
            child: _QuickTile(item: e.value),
          ),
        );
      }).toList(),
    );

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('QUICK ACCESS',
          style: AppTheme.pixelHeading(
              fontSize: 9, letterSpacing: 2, color: AppTheme.textMuted)),
      const SizedBox(height: 8),
      row(items.sublist(0, 3)),
      const SizedBox(height: 8),
      row(items.sublist(3, 6)),
    ]);
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({required this.item});
  final _QuickItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0e1225),
            border: Border.all(
                color: AppTheme.accentGold.withValues(alpha: 0.35)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 6),
              Text(item.label,
                  style: AppTheme.pixelHeading(
                      fontSize: 8,
                      letterSpacing: 1,
                      color: AppTheme.accentGold)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.color,
  });
  final String icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Container(height: 1, color: color.withValues(alpha: 0.25)),
      ),
      const SizedBox(width: 10),
      Text('$icon  $label',
          style: AppTheme.pixelHeading(
              fontSize: 9, letterSpacing: 2, color: color)),
      const SizedBox(width: 10),
      Expanded(
        child: Container(height: 1, color: color.withValues(alpha: 0.25)),
      ),
    ]);
  }
}

// ── Login Streak Button ───────────────────────────────────────────────────────

class _LoginStreakButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final unclaimed = !game.loginTodayClaimed;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, '/login-streak'),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: unclaimed
                    ? const Color(0xFFff8800).withValues(alpha: 0.06)
                    : null,
                border: Border.all(
                  color: unclaimed
                      ? const Color(0xFFff8800)
                      : AppTheme.accentGold,
                  width: unclaimed ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(children: [
                Expanded(
                  child: Text(
                    '🔥  DAILY LOGIN',
                    style: AppTheme.pixelHeading(
                        fontSize: 11,
                        letterSpacing: 1,
                        color: unclaimed
                            ? const Color(0xFFff8800)
                            : AppTheme.accentGold),
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    color: unclaimed
                        ? const Color(0xFFff8800)
                        : AppTheme.accentGold,
                    size: 14),
              ]),
            ),
          ),
        ),
        if (unclaimed)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFFff4422),
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
