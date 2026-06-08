import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/dnd_class.dart';
import '../models/hero_race.dart';
import '../models/hero_trait.dart';
import '../services/save_service.dart';
import '../theme/app_theme.dart';
import 'character_creation_screen.dart';

class CharacterSelectScreen extends StatefulWidget {
  const CharacterSelectScreen({super.key, required this.onCharacterSelected});

  final void Function(int slot, String? newName, DndClass? heroClass, HeroRace? heroRace, HeroTrait? trait)
      onCharacterSelected;

  @override
  State<CharacterSelectScreen> createState() => _CharacterSelectScreenState();
}

class _CharacterSelectScreenState extends State<CharacterSelectScreen> {
  late Future<_SelectData> _charactersFuture;

  @override
  void initState() {
    super.initState();
    _charactersFuture = _load();
  }

  Future<_SelectData> _load() async {
    final extra = await SaveService.getExtraSlots();
    final total = SaveService.defaultSlots + extra;
    final chars = await SaveService().listCharacters(total);
    return _SelectData(chars, extra);
  }

  void _refresh() {
    setState(() {
      _charactersFuture = _load();
    });
  }

  Future<void> _onSlotTapped(int slot, CharacterSummary? existing) async {
    if (existing != null) {
      widget.onCharacterSelected(slot, null, null, null, null);
      return;
    }

    // New character — open creation wizard
    final result = await Navigator.push<CharacterCreationResult>(
      context,
      MaterialPageRoute(
        builder: (_) => const CharacterCreationScreen(),
        fullscreenDialog: true,
      ),
    );
    if (result == null) return;
    widget.onCharacterSelected(slot, result.name, result.heroClass, result.heroRace, result.trait);
  }

  Future<void> _onSlotLongPressed(int slot, CharacterSummary? existing) async {
    await _confirmDelete(slot, existing);
  }

  Future<void> _confirmDelete(int slot, CharacterSummary? existing) async {
    if (existing == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: Text('Delete "${existing.name}"?',
            style: GoogleFonts.pixelifySans(color: AppTheme.accentGold)),
        content: Text(
          'Are you sure? Once gone it cannot be stored.',
          style: GoogleFonts.pixelifySans(color: AppTheme.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('CANCEL',
                style: GoogleFonts.pixelifySans(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('DELETE',
                style: GoogleFonts.pixelifySans(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await SaveService().deleteSlot(slot);
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Column(
        children: [
          const SizedBox(height: 60),
          Text(
            'ZETA IDLE',
            style: GoogleFonts.pixelifySans(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppTheme.accentGold,
              letterSpacing: 6,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: -0.2, duration: 600.ms, curve: Curves.easeOut),
          const SizedBox(height: 8),
          Text(
            '— SELECT CHARACTER —',
            style: GoogleFonts.pixelifySans(
              fontSize: 11,
              color: AppTheme.textMuted,
              letterSpacing: 3,
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 60),
          Expanded(
            child: FutureBuilder<_SelectData>(
              future: _charactersFuture,
              builder: (ctx, snap) {
                if (!snap.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.accentGold),
                  );
                }
                final data  = snap.data!;
                final chars = data.characters;
                final showLock = data.extraSlots < 2;
                final itemCount = chars.length + (showLock ? 1 : 0);
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  itemCount: itemCount,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (ctx, i) {
                    final Widget tile = i >= chars.length
                        ? const _LockedSlotTile()
                        : _SlotTile(
                            index: i,
                            summary: chars[i],
                            onTap: () => _onSlotTapped(i, chars[i]),
                            onLongPress: () => _onSlotLongPressed(i, chars[i]),
                            onDelete: () => _confirmDelete(i, chars[i]),
                          );
                    return tile
                        .animate(delay: (150 + i * 100).ms)
                        .fadeIn(duration: 400.ms)
                        .slideX(
                            begin: 0.1,
                            duration: 400.ms,
                            curve: Curves.easeOut);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              'Tap the trash icon to delete a character',
              style: GoogleFonts.pixelifySans(
                fontSize: 10,
                color: AppTheme.textMuted.withValues(alpha: 0.5),
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({
    required this.index,
    required this.summary,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
  });

  final int index;
  final CharacterSummary? summary;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isEmpty = summary == null;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          color: isEmpty ? AppTheme.darkBg : AppTheme.cardBg,
          border: Border.all(
            color: isEmpty
                ? AppTheme.cardBorder
                : AppTheme.accentGold.withValues(alpha: 0.6),
            width: isEmpty ? 1 : 2,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 8,
              left: 12,
              child: Text(
                '${index + 1}',
                style: GoogleFonts.pixelifySans(
                  fontSize: 11,
                  color: AppTheme.textMuted.withValues(alpha: 0.5),
                ),
              ),
            ),
            Center(
              child: isEmpty
                  ? _buildEmpty()
                  : _buildCharacter(summary!),
            ),
            if (!isEmpty) ...[
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Text(
                    '>',
                    style: GoogleFonts.pixelifySans(
                      fontSize: 18,
                      color: AppTheme.accentGold.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.delete_outline,
                      size: 15,
                      color: AppTheme.accentRed.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.add, color: AppTheme.cardBorder, size: 18),
        const SizedBox(width: 10),
        Text(
          'NEW CHARACTER',
          style: GoogleFonts.pixelifySans(
            fontSize: 14,
            color: AppTheme.textMuted,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildCharacter(CharacterSummary char) {
    final classLabel = char.heroClass?.displayName;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          char.name,
          style: GoogleFonts.pixelifySans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textLight,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (classLabel != null) ...[
              Text(
                classLabel,
                style: GoogleFonts.pixelifySans(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '  ·  ',
                style: GoogleFonts.pixelifySans(
                  fontSize: 11,
                  color: AppTheme.cardBorder,
                ),
              ),
            ],
            Text(
              'Level ${char.level}',
              style: GoogleFonts.pixelifySans(
                fontSize: 12,
                color: AppTheme.accentGold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SelectData {
  const _SelectData(this.characters, this.extraSlots);
  final List<CharacterSummary?> characters;
  final int extraSlots;
}

class _LockedSlotTile extends StatelessWidget {
  const _LockedSlotTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: AppTheme.darkBg,
        border: Border.all(
          color: AppTheme.cardBorder.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔒', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LOCKED SLOT',
                style: GoogleFonts.pixelifySans(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Unlock in Cosmetics → Boosts (100 💎)',
                style: GoogleFonts.pixelifySans(
                  fontSize: 9,
                  color: AppTheme.textMuted.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
