import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/game_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/routing/app_router.dart';
import '../models/login_streak.dart';
import '../services/game_state.dart';
import '../widgets/battle_sprites.dart';
import '../widgets/section_card.dart';
import '../widgets/zcoin_icon.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onBackToSelect});

  final VoidCallback onBackToSelect;

  @override
  Widget build(BuildContext context) {
    final game  = GameStateProvider.of(context);
    final stage = game.effectiveUnlockStage;

    // Returns null (hidden) when stage < unlock; adds ✨ badge for first 3 stages after unlock.
    Widget? btn(String label, int unlock, VoidCallback onTap, {bool badge = false}) {
      if (stage < unlock) return null;
      final isNew = game.campaignStageIndex < unlock + 3 && game.prestigeLevel == 0;
      return _buildModeButtonBadged(
        context, isNew ? '$label  NEW' : label, onTap, badge: badge || isNew);
    }

    // Renders a section with header only when at least one child is visible.
    Widget sec(GameIconType icon, String label, Color color, List<Widget?> items) {
      final visible = items.whereType<Widget>().toList();
      if (visible.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(icon: icon, label: label, color: color),
          const SizedBox(height: 10),
          for (int i = 0; i < visible.length; i++) ...[
            visible[i],
            if (i < visible.length - 1) const SizedBox(height: 8),
          ],
          const SizedBox(height: 20),
        ],
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: const Text('ZETA IDLE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppTheme.textMuted),
            onPressed: () => context.push(Routes.knowledgeBase),
            tooltip: 'Knowledge Base',
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: AppTheme.textMuted),
            onPressed: () => context.push(Routes.settings),
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
                          color: const Color(0xFF17150E),
                          border: Border.all(
                              color: AppTheme.accentGold.withValues(alpha: 0.4),
                              width: 1),
                        ),
                        child: Center(
                          child: BattleSprite(
                            spriteId: game.heroBattleSpriteId,
                            gender: game.hero.gender,
                            auraColor: game.heroAuraColor,
                            auraIntensity: game.heroAuraIntensity,
                            colorFilter: game.heroSpriteFilter,
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
                                          fontSize: 10,
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
                                          fontSize: 10, letterSpacing: 1)),
                                  Text(
                                      '${game.hero.experience} / ${game.hero.experienceToNextLevel}',
                                      style: const TextStyle(
                                          fontSize: 10,
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
                          GameIconType.coin, 'GOLD', AppTheme.fmtNumber(game.gold),
                          accent: AppTheme.accentGold,
                          tooltip: 'Gold\nEarned from battles and idle income.\nSpend in Upgrades and the Shop.')),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildResourceBox(
                          GameIconType.diamond, 'SHARDS', AppTheme.fmtNumber(game.shards),
                          accent: const Color(0xFF44CCDD),
                          tooltip: 'Shards\nEarned from enemy kills, Dungeons, Expeditions, and Gauntlet.\nSpend on ability upgrades, item upgrades, and Passive Tree nodes.')),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildResourceBox(
                          null, 'ZCOINS', '${game.zcoins}',
                          accent: const Color(0xFFAA66FF),
                          iconWidget: const ZCoinIcon(size: 19),
                          tooltip: 'ZCoins\nEarned from achievements and daily chests.\nSpend in the Aura Shop for skins, pets, and auras.')),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                      child: _buildResourceBox(
                          GameIconType.gear, 'MYTHRIL', '${game.mythril}',
                          accent: const Color(0xFF7799CC),
                          tooltip: 'Mythril\nEarned from Dungeons, Boss Rush, and prestige milestones.\nSpend on Artifact upgrades, dungeon affix rerolls, and shrine blessings.')),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildResourceBox(
                          GameIconType.bolt, 'IDLE/min',
                          '${game.idleGoldPerMinute}',
                          accent: const Color(0xFFFFAA44),
                          tooltip: 'Idle Gold / min\nGold earned automatically every minute while offline.\nIncreases with hero level, passive upgrades, and pets.')),
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
                          fontSize: 13, letterSpacing: 1)),
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
                          style: GoogleFonts.rajdhani(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textLight,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Difficulty: ${game.currentCampaignStage.difficulty}',
                          style: const TextStyle(
                              fontSize: 13, color: AppTheme.textMuted),
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

            // ── Getting Started (visible until Stage 5) ───────────────────────
            if (stage < 5) ...[
              _GettingStartedCard(game: game)
                  .animate(delay: 240.ms)
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: 0.04, duration: 350.ms, curve: Curves.easeOut),
              const SizedBox(height: 20),
            ],

            // ── Combat ────────────────────────────────────────────────────────
            sec(GameIconType.swords, 'COMBAT', const Color(0xFFff6644), [
              btn('CAMPAIGN',           0,  () => context.push(Routes.campaign)),
              btn('DUNGEON',            12, () => context.push(Routes.dungeon),
                  badge: game.dungeonAttemptsRemaining > 0),
              btn('CHALLENGE GAUNTLET', 11, () => context.push(Routes.gauntlet)),
              btn('BOSS RUSH',          15, () => context.push(Routes.bossRush),
                  badge: game.bossRushAttemptsRemaining > 0),
              btn('DAILY CHALLENGES',   5,  () => context.push(Routes.daily),
                  badge: game.hasClaimableDaily),
              stage >= 8 ? _LoginStreakButton() : null,
              btn('BOUNTY BOARD',       8,  () => context.push(Routes.bounties)),
            ]),

            // ── Hero Hub ──────────────────────────────────────────────────────
            sec(GameIconType.armor, 'HERO', const Color(0xFF66aaff), [
              _HeroHubCard(),
            ]),

            // ── Progression ───────────────────────────────────────────────────
            sec(GameIconType.mountain, 'PROGRESSION', const Color(0xFFaa88ff), [
              btn('SEASON PASS',  5,  () => context.push(Routes.seasonPass),
                  badge: game.seasonUnclaimedCount > 0),
              btn('ACHIEVEMENTS', 5,  () => context.push(Routes.achievements),
                  badge: game.achievementsClaimable > 0),
              btn('PRESTIGE',      20, () => context.push(Routes.prestige)),
              btn('WORLD EVENT',   16, () => context.push(Routes.worldEvent)),
              btn('ASCENSION',     45, () => context.push(Routes.ascension)),
            ]),

            // ── Social ───────────────────────────────────────────────────────
            sec(GameIconType.castle, 'SOCIAL', const Color(0xFF44ccaa), [
              btn('GUILD',               15, () => context.push(Routes.guild)),
              btn('LEADERBOARD',         15, () => context.push(Routes.leaderboard)),
              btn('CHALLENGE MODIFIERS', 25, () => context.push(Routes.challengeMods)),
            ]),

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
                        fontSize: 13,
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
                constraints: const BoxConstraints(minHeight: 48),
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.cardBorder, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_back,
                        size: 16, color: AppTheme.textMuted),
                    const SizedBox(width: 8),
                    Text(
                      'CHARACTER SELECTION',
                      style: AppTheme.pixelHeading(
                          fontSize: 14,
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
          Text('Lv $level', style: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 1)),
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
            style: AppTheme.pixelHeading(fontSize: 9, letterSpacing: 0)),
        Text('$score',
            style: GoogleFonts.rajdhani(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.textLight)),
        Text('$sign$mod',
            style: AppTheme.pixelHeading(fontSize: 9, color: modColor)),
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
            style: AppTheme.pixelHeading(fontSize: 9, letterSpacing: 0)),
        Text(value,
            style: GoogleFonts.rajdhani(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.textLight)),
        Text('—',
            style:
                AppTheme.pixelHeading(fontSize: 9, color: AppTheme.textMuted)),
      ]),
    );
  }

  Widget _buildStatDisplay(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTheme.pixelHeading(fontSize: 11, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.rajdhani(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textLight)),
      ],
    );
  }

  Widget _buildResourceBox(GameIconType? icon, String label, String value,
      {Color? accent, String? tooltip, Widget? iconWidget}) {
    final c = accent ?? AppTheme.accentGold;
    final box = Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: Color.lerp(AppTheme.darkBg, c, 0.04),
        border: Border(
          top:    BorderSide(color: c.withValues(alpha: 0.65), width: 2),
          left:   BorderSide(color: AppTheme.cardBorder, width: 1),
          right:  BorderSide(color: AppTheme.cardBorder, width: 1),
          bottom: BorderSide(color: AppTheme.cardBorder, width: 1),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(children: [
        iconWidget ?? (icon != null ? GameIcon(icon, size: 19, color: c) : const SizedBox(width: 19, height: 19)),
        const SizedBox(height: 4),
        Text(label,
            style: AppTheme.pixelHeading(
                fontSize: 9, letterSpacing: 0.5, color: c.withValues(alpha: 0.85))),
        const SizedBox(height: 3),
        Text(value,
            style: GoogleFonts.rajdhani(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textLight)),
      ]),
    );
    if (tooltip == null) return box;
    return Tooltip(
      message: tooltip,
      triggerMode: TooltipTriggerMode.tap,
      preferBelow: true,
      waitDuration: Duration.zero,
      child: box,
    );
  }



  Widget _buildModeButtonBadged(BuildContext context, String label,
      VoidCallback onPressed, {required bool badge}) {
    final accent = badge ? const Color(0xFFaacc44) : AppTheme.accentGold;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accent.withValues(alpha: badge ? 0.10 : 0.06),
                Colors.transparent,
              ],
              stops: const [0.0, 0.35],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            border: Border(
              left:   BorderSide(color: accent, width: 3),
              top:    BorderSide(color: accent.withValues(alpha: 0.25), width: 1),
              right:  BorderSide(color: AppTheme.cardBorder, width: 1),
              bottom: BorderSide(color: AppTheme.cardBorder, width: 1),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(children: [
            Expanded(
              child: Text(label,
                  style: AppTheme.pixelHeading(
                      fontSize: 12,
                      letterSpacing: 1,
                      color: accent)),
            ),
            Icon(Icons.arrow_forward_ios, color: accent.withValues(alpha: 0.6), size: 14),
          ]),
        ),
      ),
    );
  }
}

// ── Quick Access Grid ─────────────────────────────────────────────────────────

class _QuickItem {
  const _QuickItem(this.icon, this.label, this.unlock, this.onTap);
  final GameIconType icon;
  final String label;
  final int unlock;
  final VoidCallback onTap;
}

class _QuickAccessGrid extends StatelessWidget {
  const _QuickAccessGrid({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final stage = game.campaignStageIndex;
    final all = [
      _QuickItem(GameIconType.scroll,   'CAMPAIGN',  0,  () => context.push(Routes.campaign)),
      _QuickItem(GameIconType.armor,    'HERO',      0,  () => context.push(Routes.heroHub)),
      _QuickItem(GameIconType.key,      'DUNGEON',   8,  () => context.push(Routes.dungeon)),
      _QuickItem(GameIconType.gauntlet, 'GAUNTLET', 11,  () => context.push(Routes.gauntlet)),
      _QuickItem(GameIconType.skull,    'BOSS RUSH', 15, () => context.push(Routes.bossRush)),
    ];
    final items = all.where((i) => stage >= i.unlock).toList();

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

    final rows = <List<_QuickItem>>[];
    for (int i = 0; i < items.length; i += 3) {
      rows.add(items.sublist(i, (i + 3).clamp(0, items.length)));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('QUICK ACCESS',
          style: AppTheme.pixelHeading(
              fontSize: 10, letterSpacing: 2, color: AppTheme.textMuted)),
      const SizedBox(height: 8),
      for (int i = 0; i < rows.length; i++) ...[
        row(rows[i]),
        if (i < rows.length - 1) const SizedBox(height: 8),
      ],
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
            gradient: const LinearGradient(
              colors: [Color(0xFF2A2520), Color(0xFF1E1B18)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border(
              top:    BorderSide(color: AppTheme.accentGold.withValues(alpha: 0.55), width: 1),
              left:   BorderSide(color: AppTheme.accentGold.withValues(alpha: 0.25), width: 1),
              right:  BorderSide(color: AppTheme.accentGold.withValues(alpha: 0.25), width: 1),
              bottom: BorderSide(color: AppTheme.accentGold.withValues(alpha: 0.25), width: 1),
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GameIcon(item.icon, size: 26, color: AppTheme.accentGold),
              const SizedBox(height: 6),
              Text(item.label,
                  style: AppTheme.pixelHeading(
                      fontSize: 9,
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
  final GameIconType icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Container(height: 1, color: color.withValues(alpha: 0.25)),
      ),
      const SizedBox(width: 10),
      GameIcon(icon, size: 12, color: color),
      const SizedBox(width: 6),
      Text(label,
          style: AppTheme.pixelHeading(
              fontSize: 10, letterSpacing: 2, color: color)),
      const SizedBox(width: 10),
      Expanded(
        child: Container(height: 1, color: color.withValues(alpha: 0.25)),
      ),
    ]);
  }
}

// ── Getting Started Tutorial Card ────────────────────────────────────────────

class _GettingStartedCard extends StatelessWidget {
  const _GettingStartedCard({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final stage = game.campaignStageIndex;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF13110D),
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const GameIcon(GameIconType.flag, size: 13, color: AppTheme.accentGold),
            const SizedBox(width: 6),
            Text('GETTING STARTED',
                style: AppTheme.pixelHeading(
                    fontSize: 9, letterSpacing: 2, color: AppTheme.accentGold)),
          ]),
          const SizedBox(height: 10),
          _StepRow(
            done: stage > 0,
            label: 'Win your first Campaign battle',
            onTap: () => context.push(Routes.campaign),
          ),
          _StepRow(
            done: game.hero.level >= 2,
            label: 'Level up your hero — visit Character Sheet',
            onTap: () => context.go(Routes.shell),
          ),
          _StepRow(
            done: game.abilityScoreRank('pwr') > 0 ||
                  game.abilityScoreRank('vit') > 0 ||
                  game.abilityScoreRank('agi') > 0,
            label: 'Open HERO and buy your first Ability Score upgrade',
            onTap: () => context.push(Routes.heroHub),
          ),
          _StepRow(
            done: stage >= 5,
            label: 'Reach Stage 5 — Abilities and Daily Challenges unlock!',
            onTap: stage >= 5 ? null : () => context.push(Routes.campaign),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.done, required this.label, this.onTap});
  final bool done;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
              size: 14,
              color: done ? const Color(0xFF55cc88) : AppTheme.textMuted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: done
                      ? const Color(0xFF55cc88).withValues(alpha: 0.7)
                      : AppTheme.textLight,
                  decoration: done ? TextDecoration.lineThrough : null,
                  decorationColor:
                      const Color(0xFF55cc88).withValues(alpha: 0.5),
                ),
              ),
            ),
            if (onTap != null && !done)
              const Icon(Icons.arrow_forward_ios,
                  size: 9, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

// ── Hero Hub Card ─────────────────────────────────────────────────────────────

class _HeroHubCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF66aaff);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(Routes.heroHub),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accent.withValues(alpha: 0.10),
                Colors.transparent,
              ],
              stops: const [0.0, 1.0],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            border: Border(
              left:   const BorderSide(color: accent, width: 3),
              top:    BorderSide(color: accent.withValues(alpha: 0.25), width: 1),
              right:  BorderSide(color: AppTheme.cardBorder, width: 1),
              bottom: BorderSide(color: AppTheme.cardBorder, width: 1),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('HERO',
                      style: AppTheme.pixelHeading(
                          fontSize: 13, letterSpacing: 1, color: accent)),
                  const SizedBox(height: 5),
                  Text('UPGRADES  •  ARMORY  •  ALLIES  •  CODEX',
                      style: AppTheme.pixelHeading(
                          fontSize: 9,
                          letterSpacing: 0.5,
                          color: accent.withValues(alpha: 0.55))),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: accent.withValues(alpha: 0.6), size: 14),
          ]),
        ),
      ),
    );
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
            onTap: () => context.push(Routes.loginStreak),
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
                    'DAILY LOGIN',
                    style: AppTheme.pixelHeading(
                        fontSize: 12,
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
        if (game.loginTodayClaimed) ...[
          Positioned(
            bottom: 4,
            left: 16,
            right: 40,
            child: Builder(builder: (_) {
              final nextDay = ((game.loginStreak) % LoginReward.cycle.length) + 1;
              final next = LoginReward.forDay(nextDay);
              return Text(
                'Tomorrow: ${next.icon} ${next.label}',
                style: const TextStyle(fontSize: 8, color: AppTheme.textMuted),
                overflow: TextOverflow.ellipsis,
              );
            }),
          ),
        ],
      ],
    );
  }
}
