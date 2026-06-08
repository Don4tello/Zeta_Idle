import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/dnd_class.dart';
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
  });
  final String name;
  final DndClass heroClass;
  final HeroRace heroRace;
  final HeroTrait trait;
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
                      selectedTrait: _selectedTrait,
                      onRaceSelected: (r) => setState(() {
                        _selectedRace = r;
                        _selectedTrait = null;
                      }),
                      onTraitSelected: (t) => setState(() => _selectedTrait = t),
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: const Icon(Icons.arrow_back,
                  color: AppTheme.textMuted, size: 16),
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
  const _NameStep({super.key, required this.controller, required this.onNext});
  final TextEditingController controller;
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
            style: AppTheme.pixelHeading(fontSize: 22, letterSpacing: 4),
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: -0.1, duration: 500.ms, curve: Curves.easeOut),
          const SizedBox(height: 8),
          Text(
            '— NAME YOUR WARRIOR —',
            style: GoogleFonts.pixelifySans(
              fontSize: 11,
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
                color: AppTheme.textLight, fontSize: 22),
            cursorColor: AppTheme.accentGold,
            decoration: InputDecoration(
              counterStyle: GoogleFonts.pixelifySans(
                  color: AppTheme.textMuted, fontSize: 10),
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
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              child: Text(
                'CHOOSE CLASS  →',
                style: GoogleFonts.pixelifySans(
                    fontSize: 14, letterSpacing: 2),
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
          style: AppTheme.pixelHeading(fontSize: 18, letterSpacing: 4),
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 4),
        Text(
          '— SELECT YOUR PATH —',
          style: GoogleFonts.pixelifySans(
            fontSize: 11,
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
              childAspectRatio: 1.55,
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
                    fontSize: 14, letterSpacing: 2),
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
                        fontSize: 9,
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
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isPrimary
                            ? AppTheme.accentGold
                            : AppTheme.textLight,
                      ),
                    ),
                    Text(
                      modStr,
                      style: GoogleFonts.pixelifySans(
                        fontSize: 9,
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

  @override
  Widget build(BuildContext context) {
    final info = dndClass.info;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.cardBg : AppTheme.darkBg,
          border: Border.all(
            color: selected ? AppTheme.accentGold : AppTheme.cardBorder,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.accentGold.withValues(alpha: 0.15),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  info.icon,
                  size: 14,
                  color: selected ? AppTheme.accentGold : AppTheme.textMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    info.displayName.toUpperCase(),
                    style: GoogleFonts.pixelifySans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: selected
                          ? AppTheme.accentGold
                          : AppTheme.textLight,
                      letterSpacing: 1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              info.likes,
              style: GoogleFonts.pixelifySans(
                fontSize: 9,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              info.primaryAbility,
              style: GoogleFonts.pixelifySans(
                fontSize: 9,
                color: AppTheme.accentGold.withValues(alpha: 0.75),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  info.complexityDots,
                  style: GoogleFonts.pixelifySans(
                    fontSize: 10,
                    color: _complexityColor(info.complexity),
                    letterSpacing: 3,
                  ),
                ),
                Text(
                  info.complexityLabel.toUpperCase(),
                  style: GoogleFonts.pixelifySans(
                    fontSize: 8,
                    color: _complexityColor(info.complexity),
                    letterSpacing: 1,
                  ),
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

// ── Step 3: Race + racial trait selection ────────────────────────────────────

class _RaceStep extends StatelessWidget {
  const _RaceStep({
    super.key,
    required this.selectedRace,
    required this.selectedTrait,
    required this.onRaceSelected,
    required this.onTraitSelected,
    required this.onConfirm,
  });

  final HeroRace? selectedRace;
  final HeroTrait? selectedTrait;
  final ValueChanged<HeroRace> onRaceSelected;
  final ValueChanged<HeroTrait> onTraitSelected;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final ready = selectedRace != null && selectedTrait != null;
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          'CHOOSE YOUR RACE',
          style: AppTheme.pixelHeading(fontSize: 18, letterSpacing: 4),
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 4),
        Text(
          '— YOUR HERITAGE DEFINES YOU —',
          style: GoogleFonts.pixelifySans(
            fontSize: 11,
            color: AppTheme.textMuted,
            letterSpacing: 3,
          ),
        ).animate(delay: 80.ms).fadeIn(duration: 300.ms),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // Race grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2.5,
                ),
                itemCount: HeroRace.values.length,
                itemBuilder: (ctx, i) {
                  final race = HeroRace.values[i];
                  final info = race.info;
                  final sel = selectedRace == race;
                  return GestureDetector(
                    onTap: () => onRaceSelected(race),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? AppTheme.cardBg : AppTheme.darkBg,
                        border: Border.all(
                          color: sel ? AppTheme.accentGold : AppTheme.cardBorder,
                          width: sel ? 2 : 1,
                        ),
                        boxShadow: sel
                            ? [BoxShadow(
                                color: AppTheme.accentGold.withValues(alpha: 0.12),
                                blurRadius: 8, spreadRadius: 1)]
                            : null,
                      ),
                      child: Row(children: [
                        Text(info.icon, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(info.displayName.toUpperCase(),
                                  style: GoogleFonts.pixelifySans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: sel ? AppTheme.accentGold : AppTheme.textLight,
                                    letterSpacing: 1,
                                  ),
                                  overflow: TextOverflow.ellipsis),
                              Text(info.tags,
                                  style: GoogleFonts.pixelifySans(
                                    fontSize: 8,
                                    color: AppTheme.textMuted,
                                  ),
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ).animate(delay: (i * 25).ms).fadeIn(duration: 250.ms);
                },
              ),
              // Racial trait picker — slides in when race is selected
              if (selectedRace != null) ...[
                const SizedBox(height: 16),
                Text(
                  '— CHOOSE YOUR RACIAL TRAIT —',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.pixelifySans(
                    fontSize: 10,
                    color: AppTheme.textMuted,
                    letterSpacing: 2,
                  ),
                ).animate().fadeIn(duration: 250.ms),
                const SizedBox(height: 10),
                ...HeroTrait.forRace(selectedRace!).asMap().entries.map((entry) {
                  final t = entry.value;
                  final sel = selectedTrait?.id == t.id;
                  return GestureDetector(
                    onTap: () => onTraitSelected(t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: sel ? AppTheme.cardBg : AppTheme.darkBg,
                        border: Border.all(
                          color: sel ? AppTheme.accentGold : AppTheme.cardBorder,
                          width: sel ? 2 : 1,
                        ),
                        boxShadow: sel
                            ? [BoxShadow(
                                color: AppTheme.accentGold.withValues(alpha: 0.12),
                                blurRadius: 10, spreadRadius: 1)]
                            : null,
                      ),
                      child: Row(children: [
                        Text(t.icon, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 14),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.name,
                                style: GoogleFonts.pixelifySans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: sel ? AppTheme.accentGold : AppTheme.textLight,
                                  letterSpacing: 1,
                                )),
                            const SizedBox(height: 4),
                            Text(t.description,
                                style: GoogleFonts.pixelifySans(
                                  fontSize: 10,
                                  color: AppTheme.textMuted,
                                  height: 1.4,
                                )),
                          ],
                        )),
                        if (sel)
                          const Icon(Icons.check_circle,
                              color: AppTheme.accentGold, size: 18),
                      ]),
                    ),
                  ).animate(delay: (entry.key * 60).ms).fadeIn(duration: 250.ms)
                   .slideX(begin: 0.04, duration: 250.ms, curve: Curves.easeOut);
                }),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: ready ? onConfirm : null,
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: AppTheme.cardBorder,
                disabledForegroundColor: AppTheme.textMuted,
              ),
              child: Text(
                ready
                    ? 'BEGIN YOUR JOURNEY'
                    : selectedRace == null
                        ? 'SELECT A RACE'
                        : 'SELECT A TRAIT',
                style: GoogleFonts.pixelifySans(fontSize: 14, letterSpacing: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
