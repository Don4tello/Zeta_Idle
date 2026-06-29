import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/damage_type.dart';
import '../models/dnd_class.dart';
import '../models/hero_model.dart' show HeroGender;
import '../models/hero_race.dart';
import '../models/hero_trait.dart';
import '../theme/app_theme.dart';
import '../widgets/battle_sprites.dart';

class CharacterCreationResult {
  const CharacterCreationResult({
    required this.name,
    required this.heroClass,
    required this.heroRace,
    required this.trait,
    required this.gender,
  });
  final String name;
  final DndClass heroClass;
  final HeroRace heroRace;
  final HeroTrait trait;
  final HeroGender gender;
}

class CharacterCreationScreen extends StatefulWidget {
  const CharacterCreationScreen({super.key});

  @override
  State<CharacterCreationScreen> createState() =>
      _CharacterCreationScreenState();
}

class _CharacterCreationScreenState extends State<CharacterCreationScreen> {
  final _nameController = TextEditingController(text: 'The Warden');
  int _step = 0;
  DndClass? _selectedClass;
  HeroRace? _selectedRace;
  HeroTrait? _selectedTrait;
  HeroGender _selectedGender = HeroGender.male;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _goToClass() => setState(() => _step = 1);

  void _goToRace() {
    if (_selectedClass == null) return;
    setState(() { _step = 2; _selectedRace = null; _selectedTrait = null; });
  }

  void _goBack() {
    if (_step == 0) {
      Navigator.pop(context, null);
    } else {
      setState(() => _step -= 1);
    }
  }

  void _create() {
    if (_selectedClass == null || _selectedRace == null || _selectedTrait == null) return;
    final name = _nameController.text.trim();
    Navigator.pop(
      context,
      CharacterCreationResult(
        name: name.isEmpty ? 'The Warden' : name,
        heroClass: _selectedClass!,
        heroRace: _selectedRace!,
        trait: _selectedTrait!,
        gender: _selectedGender,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.03),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: switch (_step) {
                  0 => _NameStep(
                      key: const ValueKey(0),
                      controller: _nameController,
                      selectedGender: _selectedGender,
                      onGenderChanged: (g) => setState(() => _selectedGender = g),
                      onNext: _goToClass,
                    ),
                  1 => _ClassStep(
                      key: const ValueKey(1),
                      selectedClass: _selectedClass,
                      onClassSelected: (c) => setState(() => _selectedClass = c),
                      onConfirm: _goToRace,
                    ),
                  _ => _RaceStep(
                      key: const ValueKey(2),
                      selectedRace: _selectedRace,
                      onRaceSelected: (r) => setState(() {
                        _selectedRace = r;
                        // Auto-select the single trait for this race.
                        _selectedTrait = HeroTrait.forRace(r).firstOrNull;
                      }),
                      onConfirm: _create,
                    ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: _goBack,
            child: Container(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: const Icon(Icons.arrow_back,
                  color: AppTheme.textMuted, size: 20),
            ),
          ),
          const Spacer(),
          _StepIndicator(currentStep: _step),
          const Spacer(),
          const SizedBox(width: 32),
        ],
      ),
    );
  }
}

// ── Step indicator ────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dot(0),
        const SizedBox(width: 6),
        Container(height: 1, width: 16, color: AppTheme.cardBorder),
        const SizedBox(width: 6),
        _dot(1),
        const SizedBox(width: 6),
        Container(height: 1, width: 16, color: AppTheme.cardBorder),
        const SizedBox(width: 6),
        _dot(2),
      ],
    );
  }

  Widget _dot(int step) {
    final active = currentStep == step;
    final done = currentStep > step;
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: (active || done) ? AppTheme.accentGold : AppTheme.cardBorder,
      ),
    );
  }
}

// ── Step 1: Name ──────────────────────────────────────────────────────────────

class _NameStep extends StatelessWidget {
  const _NameStep({
    super.key,
    required this.controller,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.onNext,
  });
  final TextEditingController controller;
  final HeroGender selectedGender;
  final ValueChanged<HeroGender> onGenderChanged;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'FORGE YOUR LEGEND',
            style: AppTheme.pixelHeading(fontSize: 23, letterSpacing: 4),
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: -0.1, duration: 500.ms, curve: Curves.easeOut),
          const SizedBox(height: 8),
          Text(
            '— NAME YOUR WARRIOR —',
            style: GoogleFonts.pixelifySans(
              fontSize: 12,
              color: AppTheme.textMuted,
              letterSpacing: 3,
            ),
          ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 56),
          TextField(
            controller: controller,
            autofocus: true,
            maxLength: 20,
            textAlign: TextAlign.center,
            style: GoogleFonts.pixelifySans(
                color: AppTheme.textLight, fontSize: 23),
            cursorColor: AppTheme.accentGold,
            decoration: InputDecoration(
              counterStyle: GoogleFonts.pixelifySans(
                  color: AppTheme.textMuted, fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              enabledBorder: const UnderlineInputBorder(
                borderSide:
                    BorderSide(color: AppTheme.cardBorder, width: 2),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide:
                    BorderSide(color: AppTheme.accentGold, width: 2),
              ),
            ),
            onSubmitted: (_) => onNext(),
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 24),
          // Gender picker
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: HeroGender.values.map((g) {
              final active = g == selectedGender;
              return GestureDetector(
                onTap: () => onGenderChanged(g),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: active
                        ? AppTheme.accentGold.withValues(alpha: 0.12)
                        : Colors.transparent,
                    border: Border.all(
                      color: active
                          ? AppTheme.accentGold
                          : AppTheme.cardBorder,
                      width: active ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(g.icon,
                          style: TextStyle(
                            fontSize: 20,
                            color: active ? AppTheme.accentGold : AppTheme.textMuted,
                          )),
                      const SizedBox(height: 4),
                      Text(g.label.toUpperCase(),
                          style: GoogleFonts.pixelifySans(
                            fontSize: 9,
                            color: active ? AppTheme.accentGold : AppTheme.textMuted,
                            letterSpacing: 1,
                          )),
                    ],
                  ),
                ),
              );
            }).toList(),
          ).animate(delay: 250.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              child: Text(
                'CHOOSE CLASS  →',
                style: GoogleFonts.pixelifySans(
                    fontSize: 15, letterSpacing: 2),
              ),
            ),
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
        ],
      ),
    );
  }
}

// ── Step 2: Class selection ───────────────────────────────────────────────────

class _ClassStep extends StatelessWidget {
  const _ClassStep({
    super.key,
    required this.selectedClass,
    required this.onClassSelected,
    required this.onConfirm,
  });

  final DndClass? selectedClass;
  final ValueChanged<DndClass> onClassSelected;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Text(
          'CHOOSE YOUR CLASS',
          style: AppTheme.pixelHeading(fontSize: 19, letterSpacing: 4),
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 4),
        Text(
          '— SELECT YOUR PATH —',
          style: GoogleFonts.pixelifySans(
            fontSize: 12,
            color: AppTheme.textMuted,
            letterSpacing: 3,
          ),
        ).animate(delay: 80.ms).fadeIn(duration: 300.ms),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.95,
            ),
            itemCount: DndClass.values.length,
            itemBuilder: (ctx, i) {
              final cls = DndClass.values[i];
              return _ClassCard(
                dndClass: cls,
                selected: selectedClass == cls,
                onTap: () => onClassSelected(cls),
              )
                  .animate(delay: (i * 30).ms)
                  .fadeIn(duration: 300.ms)
                  .scale(begin: const Offset(0.95, 0.95), duration: 300.ms);
            },
          ),
        ),
        if (selectedClass != null) _buildStatsPreview(selectedClass!),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedClass != null ? onConfirm : null,
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: AppTheme.cardBorder,
                disabledForegroundColor: AppTheme.textMuted,
              ),
              child: Text(
                selectedClass != null
                    ? 'CHOOSE RACE  →'
                    : 'SELECT A CLASS',
                style: GoogleFonts.pixelifySans(
                    fontSize: 15, letterSpacing: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsPreview(DndClass cls) {
    final info = cls.info;
    final stats = [
      ('PWR', info.str),
      ('AGI', info.dex),
      ('VIT', info.con),
      ('ARC', info.intelligence),
      ('FOC', info.wis),
      ('FOR', info.cha),
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.fromLTRB(8, 10, 16, 10),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Sprite preview
          Container(
            width: 60,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.darkBg,
              border: Border.all(
                  color: AppTheme.accentGold.withValues(alpha: 0.4)),
            ),
            child: Center(
              child: BattleSprite(spriteId: cls.spriteId, facingLeft: false),
            ),
          ),
          const SizedBox(width: 12),
          // Stat columns
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: stats.map((s) {
                final mod = (s.$2 - 10) ~/ 2;
                final modStr = mod >= 0 ? '+$mod' : '$mod';
                final isPrimary = _isPrimary(s.$1, info);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      s.$1,
                      style: GoogleFonts.pixelifySans(
                        fontSize: 10,
                        color: isPrimary
                            ? AppTheme.accentGold
                            : AppTheme.textMuted,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${s.$2}',
                      style: GoogleFonts.pixelifySans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isPrimary
                            ? AppTheme.accentGold
                            : AppTheme.textLight,
                      ),
                    ),
                    Text(
                      modStr,
                      style: GoogleFonts.pixelifySans(
                        fontSize: 10,
                        color: mod >= 0
                            ? AppTheme.accentGold.withValues(alpha: 0.7)
                            : AppTheme.textMuted,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  bool _isPrimary(String statLabel, DndClassInfo info) {
    final primary = info.primaryAbility.toLowerCase();
    const map = {
      'PWR': 'strength',
      'AGI': 'dexterity',
      'VIT': 'constitution',
      'ARC': 'intelligence',
      'FOC': 'wisdom',
      'FOR': 'charisma',
    };
    return primary.contains(map[statLabel] ?? '');
  }
}

// ── Class card ────────────────────────────────────────────────────────────────

class _ClassCard extends StatelessWidget {
  const _ClassCard({
    required this.dndClass,
    required this.selected,
    required this.onTap,
  });

  final DndClass dndClass;
  final bool selected;
  final VoidCallback onTap;

  // The two damage types this class specialises in.
  // Physical+X classes (classElement == secondaryElement) → Physical + that element.
  // Dual-element classes → classElement + secondaryElement.
  List<DamageType> get _elementPair {
    final ce = dndClass.info.classElement;
    final se = dndClass.info.secondaryElement;
    return ce == se ? [DamageType.physical, ce] : [ce, se];
  }

  @override
  Widget build(BuildContext context) {
    final info = dndClass.info;
    final pair = _elementPair;
    final stats = [info.str, info.dex, info.con, info.intelligence, info.wis, info.cha];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.fromLTRB(10, 9, 10, 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.cardBg : AppTheme.darkBg,
          border: Border.all(
            color: selected ? AppTheme.accentGold : AppTheme.cardBorder,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(
                  color: AppTheme.accentGold.withValues(alpha: 0.15),
                  blurRadius: 10, spreadRadius: 1,
                )]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Name row ──────────────────────────────────────────────
            Row(
              children: [
                Icon(info.icon, size: 13,
                    color: selected ? AppTheme.accentGold : AppTheme.textMuted),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    info.displayName.toUpperCase(),
                    style: GoogleFonts.pixelifySans(
                      fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1,
                      color: selected ? AppTheme.accentGold : AppTheme.textLight,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text('${info.likes} · ${info.primaryAbility}',
                style: GoogleFonts.pixelifySans(fontSize: 8, color: AppTheme.textMuted),
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),

            // ── Sprite + damage types ────────────────────────────────
            Row(
              children: [
                SizedBox(
                  width: 40, height: 50,
                  child: BattleSprite(spriteId: dndClass.spriteId, facingLeft: false),
                ),
                const SizedBox(width: 8),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(spacing: 4, runSpacing: 2, children: [
                      _DmgPill(pair[0]),
                      _DmgPill(pair[1]),
                    ]),
                    const SizedBox(height: 6),
                    // Stats as PWR/AGI/VIT/ARC/FOC/FOR
                    Row(
                      children: [
                        for (final e in [('PWR', stats[0]), ('AGI', stats[1]), ('VIT', stats[2])])
                          Expanded(child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Text(e.$1, textAlign: TextAlign.center,
                                style: GoogleFonts.pixelifySans(fontSize: 7, color: AppTheme.textMuted)),
                            Text('${e.$2}', textAlign: TextAlign.center,
                                style: GoogleFonts.pixelifySans(fontSize: 10, fontWeight: FontWeight.bold,
                                    color: e.$2 >= 15 ? AppTheme.accentGold : e.$2 <= 9 ? const Color(0xFF886655) : AppTheme.textLight)),
                          ])),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        for (final e in [('ARC', stats[3]), ('FOC', stats[4]), ('FOR', stats[5])])
                          Expanded(child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Text(e.$1, textAlign: TextAlign.center,
                                style: GoogleFonts.pixelifySans(fontSize: 7, color: AppTheme.textMuted)),
                            Text('${e.$2}', textAlign: TextAlign.center,
                                style: GoogleFonts.pixelifySans(fontSize: 10, fontWeight: FontWeight.bold,
                                    color: e.$2 >= 15 ? AppTheme.accentGold : e.$2 <= 9 ? const Color(0xFF886655) : AppTheme.textLight)),
                          ])),
                      ],
                    ),
                  ],
                )),
              ],
            ),

            const Spacer(),

            // ── Complexity ────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('COMPLEXITY',
                    style: GoogleFonts.pixelifySans(
                        fontSize: 7, color: AppTheme.textMuted,
                        letterSpacing: 0.5)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(info.complexityDots,
                        style: GoogleFonts.pixelifySans(
                            fontSize: 10, color: _complexityColor(info.complexity),
                            letterSpacing: 2)),
                    const SizedBox(width: 4),
                    Text(info.complexityLabel.toUpperCase(),
                        style: GoogleFonts.pixelifySans(
                            fontSize: 8, color: _complexityColor(info.complexity),
                            letterSpacing: 0.5)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _complexityColor(DndComplexity c) {
    switch (c) {
      case DndComplexity.low:     return const Color(0xFF4CAF50);
      case DndComplexity.average: return AppTheme.accentGold;
      case DndComplexity.high:    return const Color(0xFFEF5350);
    }
  }
}

// ── Damage type pill ──────────────────────────────────────────────────────────

class _DmgPill extends StatelessWidget {
  const _DmgPill(this.type);
  final DamageType type;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(type.emoji,
            style: const TextStyle(fontSize: 9)),
        const SizedBox(width: 2),
        Text(
          type.label,
          style: GoogleFonts.pixelifySans(
            fontSize: 8,
            color: type.color,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// ── Step 3: Race + racial trait selection ────────────────────────────────────

// ── Bonus source data for a single trait ──────────────────────────────────────
class _TraitBonus {
  const _TraitBonus(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color  color;
}

List<_TraitBonus> _traitBonuses(HeroTrait t) {
  final out = <_TraitBonus>[];
  String pct(int v) => v >= 0 ? '+$v%' : '$v%';
  if (t.xpPct    != 0) out.add(_TraitBonus('XP per kill',    pct(t.xpPct),    const Color(0xFF88aaff)));
  if (t.goldPct  != 0) out.add(_TraitBonus('Gold per kill',  pct(t.goldPct),  t.goldPct  > 0 ? AppTheme.accentGold : const Color(0xFFaa6644)));
  if (t.shardPct != 0) out.add(_TraitBonus('Shards per kill',pct(t.shardPct), t.shardPct > 0 ? const Color(0xFF44ccff) : const Color(0xFF4488aa)));
  if (t.hpPct    != 0) out.add(_TraitBonus('Max HP',         pct(t.hpPct),    t.hpPct    > 0 ? const Color(0xFF44cc88) : const Color(0xFFff4444)));
  if (t.dmgPct   != 0) out.add(_TraitBonus('Damage dealt',   pct(t.dmgPct),   t.dmgPct   > 0 ? const Color(0xFFff8844) : const Color(0xFFcc4444)));
  return out;
}

Color _traitAccent(HeroTrait? t) {
  if (t == null) return AppTheme.accentGold;
  final bonuses = _traitBonuses(t);
  return bonuses.isNotEmpty ? bonuses.first.color : AppTheme.accentGold;
}

// ── _RaceStep ─────────────────────────────────────────────────────────────────
class _RaceStep extends StatefulWidget {
  const _RaceStep({
    super.key,
    required this.selectedRace,
    required this.onRaceSelected,
    required this.onConfirm,
  });

  final HeroRace? selectedRace;
  final ValueChanged<HeroRace> onRaceSelected;
  final VoidCallback onConfirm;

  @override
  State<_RaceStep> createState() => _RaceStepState();
}

class _RaceStepState extends State<_RaceStep> {
  HeroRace? _expanded;

  void _tap(HeroRace race) {
    final alreadySel = widget.selectedRace == race;
    widget.onRaceSelected(race);
    setState(() {
      _expanded = (alreadySel && _expanded == race) ? null : race;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          'CHOOSE YOUR RACE',
          style: AppTheme.pixelHeading(fontSize: 19, letterSpacing: 4),
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 4),
        Text(
          '— YOUR HERITAGE DEFINES YOU —',
          style: GoogleFonts.pixelifySans(
            fontSize: 12,
            color: AppTheme.textMuted,
            letterSpacing: 3,
          ),
        ).animate(delay: 80.ms).fadeIn(duration: 300.ms),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: HeroRace.values.length,
            itemBuilder: (ctx, i) {
              final race = HeroRace.values[i];
              return _RaceListRow(
                race: race,
                selected: widget.selectedRace == race,
                expanded: _expanded == race,
                onTap: () => _tap(race),
              ).animate(delay: (i * 20).ms).fadeIn(duration: 200.ms);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.selectedRace != null ? widget.onConfirm : null,
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: AppTheme.cardBorder,
                disabledForegroundColor: AppTheme.textMuted,
              ),
              child: Text(
                widget.selectedRace != null
                    ? 'BEGIN YOUR JOURNEY'
                    : 'SELECT A RACE',
                style: GoogleFonts.pixelifySans(fontSize: 15, letterSpacing: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── _RaceListRow ──────────────────────────────────────────────────────────────
class _RaceListRow extends StatelessWidget {
  const _RaceListRow({
    required this.race,
    required this.selected,
    required this.expanded,
    required this.onTap,
  });

  final HeroRace     race;
  final bool         selected;
  final bool         expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final info    = race.info;
    final trait   = HeroTrait.forRace(race).firstOrNull;
    final bonuses = trait != null ? _traitBonuses(trait) : <_TraitBonus>[];
    final accent  = _traitAccent(trait);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: expanded
              ? accent.withValues(alpha: 0.07)
              : const Color(0xFF0d1020),
          border: Border.all(
            color: selected
                ? AppTheme.accentGold.withValues(alpha: expanded ? 0.55 : 0.35)
                : const Color(0xFF1e2235),
          ),
        ),
        child: Column(
          children: [
            // ── collapsed header row ──
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
              child: Row(
                children: [
                  Text(info.icon, style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          info.displayName.toUpperCase(),
                          style: GoogleFonts.pixelifySans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: selected ? AppTheme.accentGold : Colors.white70,
                            letterSpacing: 1.2,
                          ),
                        ),
                        if (trait != null)
                          Text(
                            trait.name,
                            style: GoogleFonts.pixelifySans(
                              fontSize: 9,
                              color: AppTheme.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Bonus values preview (colored, right-aligned)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: bonuses
                        .map((b) => Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Text(
                                b.value,
                                style: GoogleFonts.pixelifySans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: b.color,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    size: 14,
                    color: Colors.white24,
                  ),
                ],
              ),
            ),
            // ── expanded detail section ──
            if (expanded && bonuses.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(color: accent.withValues(alpha: 0.2))),
                  color: accent.withValues(alpha: 0.04),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...bonuses.map((b) => Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 3,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: b.color.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  b.label,
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.white38),
                                ),
                              ),
                              Text(
                                b.value,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: b.color,
                                ),
                              ),
                            ],
                          ),
                        )),
                    if (trait != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
                        child: Text(
                          trait.description,
                          style: GoogleFonts.pixelifySans(
                            fontSize: 10,
                            color: AppTheme.textMuted,
                            height: 1.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
