import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/npc_ally.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/zcoin_icon.dart';
import 'main_shell.dart' show TutorialTip;

class NpcAllyScreen extends StatelessWidget {
  const NpcAllyScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final game = GameStateProvider.of(context);
    final allies = NpcAllyDef.all;
    final unlockedCount = allies.where((a) => game.allyUnlocked(a.id)).length;

    final body = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (!embedded)
          TutorialTip(
            tutorialKey: 'mercs',
            game: game,
            text: 'Mercenaries are companions who join permanently when you hit '
                'certain milestones. 🤝 Each one provides passive combat bonuses '
                'in every battle and can synergise with others for extra power.',
          ),
        _ActiveBonusBar(game: game),
        const SizedBox(height: 16),
        Text('ROSTER',
            style: AppTheme.pixelHeading(
                fontSize: 11, letterSpacing: 2, color: AppTheme.textMuted)),
        const SizedBox(height: 10),
        ...List.generate(allies.length, (i) {
          return _AllyCard(def: allies[i], game: game)
              .animate(delay: Duration(milliseconds: 40 * i))
              .fadeIn(duration: 280.ms)
              .slideY(begin: 0.04, duration: 280.ms, curve: Curves.easeOut);
        }),
        const SizedBox(height: 8),
        Text('SYNERGIES',
            style: AppTheme.pixelHeading(
                fontSize: 11, letterSpacing: 2, color: AppTheme.textMuted)),
        const SizedBox(height: 10),
        ...SynergyDef.all.map((s) => _SynergyCard(syn: s, game: game)),
        const SizedBox(height: 8),
      ],
    );

    if (embedded) {
      return Container(color: const Color(0xFF1B1A17), child: body);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1B1A17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2623),
        title: Text('MERCENARIES',
            style: AppTheme.pixelHeading(fontSize: 14, letterSpacing: 2)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              '$unlockedCount / ${allies.length}  recruited',
              style: AppTheme.pixelHeading(
                  fontSize: 12, color: AppTheme.accentGold),
            ),
          ),
        ],
      ),
      body: body,
    );
  }
}

// ── Active Bonus Summary ──────────────────────────────────────────────────────

class _ActiveBonusBar extends StatelessWidget {
  const _ActiveBonusBar({required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final chips = <_Chip>[];

    final allyPower = game.allyAtkBonus + game.allyDmgBonus;
    if (allyPower > 0)
      chips.add(_Chip('+$allyPower Power', const Color(0xFFff6644)));
    if (game.allyAcBonus > 0)
      chips.add(_Chip('+${game.allyAcBonus} AC', const Color(0xFF66aaff)));
    if (game.allyGoldMult > 1.0)
      chips.add(_Chip('+${((game.allyGoldMult - 1) * 100).round()}% Gold',
          const Color(0xFFffdd44)));
    if (game.allyXpMult > 1.0)
      chips.add(_Chip('+${((game.allyXpMult - 1) * 100).round()}% XP',
          const Color(0xFF44ccaa)));
    if (game.allyShardMult > 1.0)
      chips.add(_Chip('+${((game.allyShardMult - 1) * 100).round()}% Shards',
          const Color(0xFF88aaff)));
    if (game.allyIdleMult > 1.0)
      chips.add(_Chip('+${((game.allyIdleMult - 1) * 100).round()}% Idle',
          const Color(0xFF88cc44)));
    if (game.allyHpPct > 0)
      chips.add(_Chip('+${game.allyHpPct}% HP', const Color(0xFF44ee88)));

    if (chips.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF231F1B),
          border: Border.all(color: AppTheme.cardBorder),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'No mercenaries recruited yet. Fulfill milestones to unlock them.',
          style: TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.4),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF231F1B),
        border: Border.all(color: AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('TOTAL ACTIVE BONUSES',
            style: AppTheme.pixelHeading(
                fontSize: 10, letterSpacing: 1, color: AppTheme.textMuted)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: chips.map((c) => _chipWidget(c)).toList(),
        ),
      ]),
    );
  }

  Widget _chipWidget(_Chip c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: c.color.withValues(alpha: 0.10),
          border: Border.all(color: c.color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(c.label,
            style: TextStyle(
                fontSize: 11, color: c.color, fontWeight: FontWeight.bold)),
      );
}

class _Chip {
  const _Chip(this.label, this.color);
  final String label;
  final Color color;
}

// ── Portrait medallion ────────────────────────────────────────────────────────

class _MercPortrait extends StatefulWidget {
  const _MercPortrait({
    required this.icon,
    required this.unlocked,
    required this.level,
  });
  final String icon;
  final bool unlocked;
  final int level;
  static const double size = 54;

  @override
  State<_MercPortrait> createState() => _MercPortraitState();
}

class _MercPortraitState extends State<_MercPortrait>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
            vsync: this, duration: const Duration(seconds: 4))
        ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = _MercPortrait.size;

    if (!widget.unlocked) {
      return SizedBox(
        width: s,
        height: s,
        child: Stack(alignment: Alignment.center, children: [
          Container(
            width: s,
            height: s,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF15121e),
            ),
          ),
          // Faint border ring
          Container(
            width: s,
            height: s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: const Color(0xFF2a2535), width: 2),
            ),
          ),
          // Very faint silhouette
          Opacity(
            opacity: 0.12,
            child: Text(widget.icon,
                style: TextStyle(fontSize: s * 0.50)),
          ),
          // Question mark
          Text('?',
              style: TextStyle(
                  fontSize: s * 0.38,
                  color: const Color(0xFF3a3248),
                  fontWeight: FontWeight.w900)),
        ]),
      );
    }

    // Unlocked: glowing rotating ring
    final ringColor = widget.level >= NpcAllyDef.maxLevel
        ? const Color(0xFFffcc44)  // gold when maxed
        : const Color(0xFF44cc88); // green otherwise

    return SizedBox(
      width: s,
      height: s,
      child: Stack(alignment: Alignment.center, children: [
        // Rotating shimmer ring
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => CustomPaint(
            size: Size(s, s),
            painter: _RingPainter(_ctrl.value, ringColor),
          ),
        ),
        // Inner circle background
        Container(
          width: s - 10,
          height: s - 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ringColor.withValues(alpha: 0.08),
          ),
        ),
        // Emoji
        Text(widget.icon, style: TextStyle(fontSize: s * 0.46)),
      ]),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.t, this.color);
  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Dim base ring
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = color.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    // Rotating bright arc (sweep ~90°)
    final sweepGrad = SweepGradient(
      colors: [
        Colors.transparent,
        color.withValues(alpha: 0.9),
        color.withValues(alpha: 0.4),
        Colors.transparent,
      ],
      stops: const [0.0, 0.4, 0.7, 1.0],
      transform: GradientRotation(t * pi * 2 - pi / 4),
    );

    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = sweepGrad.createShader(
              Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round);

    // Tiny bright dot at arc tip
    final tipAngle = t * pi * 2;
    final tipX = center.dx + cos(tipAngle) * radius;
    final tipY = center.dy + sin(tipAngle) * radius;
    canvas.drawCircle(
        Offset(tipX, tipY), 3, Paint()..color = color.withValues(alpha: 0.9));
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.t != t;
}

// ── Ally Card ─────────────────────────────────────────────────────────────────

class _AllyCard extends StatelessWidget {
  const _AllyCard({required this.def, required this.game});
  final NpcAllyDef def;
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final level    = game.allyLevel(def.id);
    final unlocked = level >= 1;
    final maxed    = level >= NpcAllyDef.maxLevel;
    final progress = game.allyMilestoneProgress(def);
    final lockPct  = (progress / def.milestoneTarget).clamp(0.0, 1.0);
    final milestoneReady = !unlocked && lockPct >= 1.0;

    final (costS, costC) = unlocked && !maxed
        ? NpcAllyDef.levelUpCost(level + 1)
        : (0, 0);
    final canAfford = costS <= game.shards && costC <= game.zcoins;

    final borderColor = milestoneReady
        ? const Color(0xFF44cc88)
        : unlocked
            ? const Color(0xFF3a7a50).withValues(alpha: 0.7)
            : AppTheme.cardBorder;
    final bgColor = unlocked
        ? const Color(0xFF0d1e14)
        : milestoneReady
            ? const Color(0xFF0d1e14).withValues(alpha: 0.5)
            : const Color(0xFF231F1B);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: borderColor,
            width: milestoneReady ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOut,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.03),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          child: _CardContent(
            key: ValueKey('${def.id}_${unlocked}_$level'),
            def: def,
            game: game,
            level: level,
            unlocked: unlocked,
            maxed: maxed,
            lockPct: lockPct,
            milestoneReady: milestoneReady,
            costS: costS,
            costC: costC,
            canAfford: canAfford,
          ),
        ),
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  const _CardContent({
    super.key,
    required this.def,
    required this.game,
    required this.level,
    required this.unlocked,
    required this.maxed,
    required this.lockPct,
    required this.milestoneReady,
    required this.costS,
    required this.costC,
    required this.canAfford,
  });

  final NpcAllyDef def;
  final GameState game;
  final int level;
  final bool unlocked;
  final bool maxed;
  final double lockPct;
  final bool milestoneReady;
  final int costS;
  final int costC;
  final bool canAfford;

  AllyTalentDef? _talentDef(int talentLevel) =>
      talentLevel == 3 ? def.talent3 : def.talent5;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header row ────────────────────────────────────────────────────────
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _MercPortrait(icon: def.icon, unlocked: unlocked, level: level),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(
                      unlocked ? def.name : '??? ???',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: unlocked
                              ? const Color(0xFF77dd99)
                              : Colors.white24),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (unlocked) ...[
                    const SizedBox(width: 6),
                    _LevelBadge(level: level, maxed: maxed),
                  ],
                ]),
                const SizedBox(height: 2),
                Text(
                  unlocked ? def.title : 'Unknown Mercenary',
                  style: TextStyle(
                      fontSize: 11,
                      color: unlocked
                          ? AppTheme.textMuted
                          : AppTheme.textMuted.withValues(alpha: 0.35),
                      fontStyle: FontStyle.italic),
                ),
                if (unlocked) ...[
                  const SizedBox(height: 5),
                  _BonusTag(def: def, level: level),
                ],
              ],
            ),
          ),
        ]),

        const SizedBox(height: 10),

        // ── Lore ─────────────────────────────────────────────────────────────
        Text(
          unlocked ? def.lore : 'Fulfill the milestone below to reveal this mercenary.',
          style: TextStyle(
              fontSize: 11,
              color: unlocked ? Colors.white54 : Colors.white24,
              height: 1.4),
        ),

        // ── Active ability ────────────────────────────────────────────────────
        if (unlocked && def.activeAbility != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF1a1028),
              border: Border.all(
                color: const Color(0xFF7744bb).withValues(alpha: 0.5),
              ),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Row(children: [
              Text(def.activeAbility!.icon,
                  style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BATTLE ABILITY: ${def.activeAbility!.name}',
                        style: AppTheme.pixelHeading(
                            fontSize: 9, color: const Color(0xFFaa77ff))),
                    const SizedBox(height: 2),
                    Text(def.activeAbility!.description,
                        style: const TextStyle(
                            fontSize: 10, height: 1.3, color: Colors.white54)),
                  ],
                ),
              ),
            ]),
          ),
        ],

        // ── Talent branches ───────────────────────────────────────────────────
        if (unlocked) ...[
          for (final talentLevel in [3, 5])
            if (_talentDef(talentLevel) != null && level >= talentLevel) ...[
              const SizedBox(height: 8),
              _TalentSection(
                def: def,
                talentDef: _talentDef(talentLevel)!,
                chosen: game.allyChosenTalent(def.id, talentLevel),
                onChoose: (optId) =>
                    game.chooseAllyTalent(def.id, talentLevel, optId),
              ),
            ],
        ],

        const SizedBox(height: 10),

        // ── Bottom row ────────────────────────────────────────────────────────
        if (!unlocked) ...[
          // Milestone progress
          if (milestoneReady)
            _MilestoneReadyBanner()
          else ...[
            Row(children: [
              Expanded(
                child: Text('Unlock: ${def.milestoneLabel}',
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textMuted)),
              ),
              Text('${game.allyMilestoneProgress(def)} / ${def.milestoneTarget}',
                  style: const TextStyle(
                      fontSize: 11, color: Colors.white38)),
            ]),
            const SizedBox(height: 6),
            _MilestoneBar(value: lockPct),
          ],
        ] else ...[
          Row(children: [
            _LevelPips(current: level, max: NpcAllyDef.maxLevel),
            const Spacer(),
            if (maxed)
              _MaxBadge()
            else
              _UpgradeButton(
                costShards:   costS,
                costCrystals: costC,
                canAfford:    canAfford,
                onTap:        () { game.upgradeAlly(def.id); game.audioService.playClaim(); },
              ),
          ]),
        ],
      ]),
    );
  }
}

// ── Talent branch selector ────────────────────────────────────────────────────

class _TalentSection extends StatelessWidget {
  const _TalentSection({
    required this.def,
    required this.talentDef,
    required this.chosen,
    required this.onChoose,
  });

  final NpcAllyDef def;
  final AllyTalentDef talentDef;
  final AllyTalentOption? chosen;
  final void Function(String optId) onChoose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0e1a24),
        border: Border.all(color: const Color(0xFF2a4060)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('⚡', style: TextStyle(fontSize: 11)),
            const SizedBox(width: 5),
            Text('LV ${talentDef.unlocksAtLevel} TALENT',
                style: AppTheme.pixelHeading(
                    fontSize: 9, letterSpacing: 2, color: const Color(0xFF6699cc))),
            if (chosen != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFF44aaff).withValues(alpha: 0.15),
                  border: Border.all(color: const Color(0xFF44aaff).withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text('CHOSEN: ${chosen!.name}',
                    style: AppTheme.pixelHeading(
                        fontSize: 8, color: const Color(0xFF44aaff))),
              ),
            ],
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _TalentOption(
              option: talentDef.optionA,
              isChosen: chosen?.id == 'a',
              onTap: () => onChoose('a'),
            )),
            const SizedBox(width: 6),
            Expanded(child: _TalentOption(
              option: talentDef.optionB,
              isChosen: chosen?.id == 'b',
              onTap: () => onChoose('b'),
            )),
          ]),
        ],
      ),
    );
  }
}

class _TalentOption extends StatelessWidget {
  const _TalentOption({
    required this.option,
    required this.isChosen,
    required this.onTap,
  });

  final AllyTalentOption option;
  final bool isChosen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const chosen = Color(0xFF44aaff);
    const idle   = Color(0xFF2a3a50);
    final border = isChosen ? chosen : idle;
    final bg     = isChosen
        ? chosen.withValues(alpha: 0.12)
        : const Color(0xFF0a1422);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border, width: isChosen ? 1.5 : 1.0),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(option.icon, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 5),
              Expanded(
                child: Text(option.name,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isChosen ? chosen : Colors.white70)),
              ),
              if (isChosen)
                const Icon(Icons.check_circle_rounded,
                    size: 12, color: chosen),
            ]),
            const SizedBox(height: 4),
            Text(option.statSummary,
                style: TextStyle(
                    fontSize: 10,
                    color: isChosen
                        ? chosen.withValues(alpha: 0.9)
                        : const Color(0xFF6688aa))),
            const SizedBox(height: 2),
            Text(option.description,
                style: const TextStyle(
                    fontSize: 9, height: 1.3, color: Colors.white38)),
          ],
        ),
      ),
    );
  }
}

// ── Milestone bar with pulse when complete ────────────────────────────────────

class _MilestoneBar extends StatelessWidget {
  const _MilestoneBar({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    final bar = ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 5,
        backgroundColor: const Color(0xFF44aa66).withValues(alpha: 0.12),
        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF44aa66)),
      ),
    );

    if (value >= 1.0) {
      return bar
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(
              duration: 900.ms,
              color: const Color(0xFF66dd99).withValues(alpha: 0.6));
    }
    return bar;
  }
}

class _MilestoneReadyBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF44cc88).withValues(alpha: 0.10),
            border: Border.all(color: const Color(0xFF44cc88).withValues(alpha: 0.6)),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Row(children: [
            const Icon(Icons.lock_open_rounded,
                color: Color(0xFF44cc88), size: 14),
            const SizedBox(width: 8),
            Text('MILESTONE COMPLETE — RECRUITING...',
                style: AppTheme.pixelHeading(
                    fontSize: 9,
                    color: const Color(0xFF44cc88),
                    letterSpacing: 1)),
          ]),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(
            duration: 800.ms,
            color: const Color(0xFF44cc88).withValues(alpha: 0.3));
  }
}

// ── Level badge ───────────────────────────────────────────────────────────────

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level, required this.maxed});
  final int level;
  final bool maxed;

  @override
  Widget build(BuildContext context) {
    final color = maxed ? AppTheme.accentGold : const Color(0xFF77dd99);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        maxed ? '★ MAX' : 'LV $level',
        style: AppTheme.pixelHeading(fontSize: 9, color: color),
      ),
    );
  }
}

class _MaxBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.accentGold.withValues(alpha: 0.10),
            border: Border.all(
                color: AppTheme.accentGold.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text('★ MAX',
              style: AppTheme.pixelHeading(
                  fontSize: 10, color: AppTheme.accentGold)),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(duration: 2000.ms, color: AppTheme.accentGold.withValues(alpha: 0.4));
  }
}

// ── Level pips ────────────────────────────────────────────────────────────────

class _LevelPips extends StatelessWidget {
  const _LevelPips({required this.current, required this.max});
  final int current;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(max, (i) {
        final filled = i < current;
        return Container(
          margin: const EdgeInsets.only(right: 4),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: filled
                ? AppTheme.accentGold
                : AppTheme.accentGold.withValues(alpha: 0.12),
            border: Border.all(
                color: AppTheme.accentGold.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}

// ── Bonus tag ─────────────────────────────────────────────────────────────────

class _BonusTag extends StatelessWidget {
  const _BonusTag({required this.def, required this.level});
  final NpcAllyDef def;
  final int level;

  String get _label {
    final power = (def.atkBonus + def.dmgBonus) * level;
    if (power > 0) return '+$power Power';
    if (def.acBonus > 0)       return '+${def.acBonus * level} AC';
    if (def.goldPctBonus > 0)  return '+${(def.goldPctBonus * level * 100).round()}% Gold';
    if (def.xpPctBonus > 0)    return '+${(def.xpPctBonus * level * 100).round()}% XP';
    if (def.shardPctBonus > 0) return '+${(def.shardPctBonus * level * 100).round()}% Shards';
    if (def.idlePctBonus > 0)  return '+${(def.idlePctBonus * level * 100).round()}% Idle';
    if (def.hpPctBonus > 0)    return '+${(def.hpPctBonus * level * 100).round()}% HP';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    const c = Color(0xFF66aaff);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.10),
        border: Border.all(color: c.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(_label,
          style: const TextStyle(
              fontSize: 10, color: c, fontWeight: FontWeight.bold)),
    );
  }
}

// ── Upgrade button ────────────────────────────────────────────────────────────

class _UpgradeButton extends StatefulWidget {
  const _UpgradeButton({
    required this.costShards,
    required this.costCrystals,
    required this.canAfford,
    required this.onTap,
  });
  final int costShards;
  final int costCrystals;
  final bool canAfford;
  final VoidCallback onTap;

  @override
  State<_UpgradeButton> createState() => _UpgradeButtonState();
}

class _UpgradeButtonState extends State<_UpgradeButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.canAfford ? AppTheme.accentGold : AppTheme.cardBorder;

    return GestureDetector(
      onTapDown: widget.canAfford ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.canAfford
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap();
            }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: widget.canAfford
                ? AppTheme.accentGold.withValues(alpha: 0.10)
                : Colors.transparent,
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(mainAxisSize: MainAxisSize.min, children: [
                Text('UPGRADE  ',
                    style: AppTheme.pixelHeading(fontSize: 10, color: color)),
                Text('◆${widget.costShards}',
                    style: TextStyle(
                        fontSize: 10,
                        color: color,
                        fontWeight: FontWeight.bold)),
                if (widget.costCrystals > 0) ...[
                  const SizedBox(width: 6),
                  ZCoinIcon(size: 10, animate: false),
                  const SizedBox(width: 2),
                  Text('${widget.costCrystals}',
                      style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.bold)),
                ],
              ]),
              if (!widget.canAfford) Builder(builder: (ctx) {
                final g = GameStateProvider.of(ctx);
                return Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    'Have: ◆${g.shards}${widget.costCrystals > 0 ? "  🪙${g.zcoins}" : ""}',
                    style: const TextStyle(fontSize: 8, color: Color(0xFFcc4444)),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Synergy Card ──────────────────────────────────────────────────────────────

class _SynergyCard extends StatelessWidget {
  const _SynergyCard({required this.syn, required this.game});
  final SynergyDef syn;
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final active = game.activeSynergies.any((s) => s.id == syn.id);
    final ally1  = NpcAllyDef.all.firstWhere((a) => a.id == syn.ally1Id);
    final ally2  = NpcAllyDef.all.firstWhere((a) => a.id == syn.ally2Id);
    final lv1    = game.allyLevel(syn.ally1Id);
    final lv2    = game.allyLevel(syn.ally2Id);

    final borderColor = active
        ? const Color(0xFFcc99ff).withValues(alpha: 0.7)
        : AppTheme.cardBorder;
    final bgColor = active
        ? const Color(0xFF150e25)
        : const Color(0xFF1A1714);

    final card = Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: active ? 1.5 : 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(syn.name,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: active
                        ? const Color(0xFFcc99ff)
                        : Colors.white38)),
            const Spacer(),
            if (active)
              const Icon(Icons.auto_awesome,
                  color: Color(0xFFcc99ff), size: 14)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .shimmer(duration: 1200.ms, color: const Color(0xFFcc99ff)),
          ]),
          const SizedBox(height: 4),
          Text(syn.description,
              style: TextStyle(
                  fontSize: 11,
                  color: active ? Colors.white54 : Colors.white24,
                  height: 1.4)),
          const SizedBox(height: 8),
          Row(children: [
            _PartnerChip(
              icon: ally1.icon,
              name: ally1.name,
              level: lv1,
              needed: syn.minLevel,
            ),
            const SizedBox(width: 4),
            Text('+',
                style: TextStyle(
                    fontSize: 13,
                    color: active
                        ? const Color(0xFFcc99ff)
                        : Colors.white24)),
            const SizedBox(width: 4),
            _PartnerChip(
              icon: ally2.icon,
              name: ally2.name,
              level: lv2,
              needed: syn.minLevel,
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFFcc99ff).withValues(alpha: 0.10)
                    : Colors.transparent,
                border: Border.all(
                    color: active
                        ? const Color(0xFFcc99ff).withValues(alpha: 0.5)
                        : AppTheme.cardBorder),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(syn.bonusSummary,
                  style: TextStyle(
                      fontSize: 10,
                      color: active
                          ? const Color(0xFFcc99ff)
                          : AppTheme.textMuted,
                      fontWeight: FontWeight.bold)),
            ),
          ]),
          if (!active) ...[
            const SizedBox(height: 6),
            Text(
              'Requires both at LV ${syn.minLevel}+  '
              '(${ally1.name} LV$lv1, ${ally2.name} LV$lv2)',
              style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textMuted,
                  fontStyle: FontStyle.italic),
            ),
          ],
        ]),
      ),
    );

    if (active) {
      return card
          .animate(key: ValueKey('syn_${syn.id}_active'))
          .shimmer(duration: 600.ms, color: const Color(0xFFcc99ff).withValues(alpha: 0.2));
    }
    return card;
  }
}

class _PartnerChip extends StatelessWidget {
  const _PartnerChip({
    required this.icon,
    required this.name,
    required this.level,
    required this.needed,
  });
  final String icon;
  final String name;
  final int level;
  final int needed;

  @override
  Widget build(BuildContext context) {
    final met = level >= needed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: met
            ? const Color(0xFF3a2060).withValues(alpha: 0.6)
            : const Color(0xFF151520),
        border: Border.all(
            color: met
                ? const Color(0xFFcc99ff).withValues(alpha: 0.5)
                : AppTheme.cardBorder),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(icon, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 4),
        Text(name,
            style: TextStyle(
                fontSize: 10,
                color: met ? const Color(0xFFcc99ff) : Colors.white38)),
        const SizedBox(width: 4),
        Text('LV$level',
            style: TextStyle(
                fontSize: 10,
                color: met ? AppTheme.accentGold : AppTheme.textMuted,
                fontWeight: FontWeight.bold)),
      ]),
    );
  }
}
