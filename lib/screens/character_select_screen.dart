import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/dnd_class.dart';
import '../models/hero_model.dart' show HeroGender;
import '../models/hero_race.dart';
import '../models/hero_trait.dart';
import '../models/shop_catalog.dart';
import '../services/game_state.dart';
import '../services/save_service.dart';
import '../theme/app_theme.dart';
import '../widgets/battle_sprites.dart';
import 'character_creation_screen.dart';

class CharacterSelectScreen extends StatefulWidget {
  const CharacterSelectScreen({super.key, required this.onCharacterSelected});

  final void Function(int slot, String? newName, DndClass? heroClass, HeroRace? heroRace, HeroTrait? trait, HeroGender? gender)
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
      widget.onCharacterSelected(slot, null, null, null, null, null);
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
    widget.onCharacterSelected(slot, result.name, result.heroClass, result.heroRace, result.trait, result.gender);
  }

  /// Confirmation dialog only — returns whether the user chose to delete.
  Future<bool> _confirmDeleteDialog(CharacterSummary existing) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: Text('Delete "${existing.name}"?',
            style: GoogleFonts.rajdhani(color: AppTheme.accentGold)),
        content: Text(
          'Are you sure? Once gone it cannot be stored.',
          style: GoogleFonts.rajdhani(color: AppTheme.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('CANCEL',
                style: GoogleFonts.rajdhani(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('DELETE',
                style: GoogleFonts.rajdhani(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  /// Actually delete the slot (local + cloud) and refresh the list.
  Future<void> _deleteSlot(int slot) async {
    final game = GameStateProvider.of(context);
    // Delete locally AND in the cloud (single doc per account) so the
    // character can't resurrect from cloud on the next load.
    await game.deleteCharacterSlot(slot);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Column(
        children: [
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/zeta_icon.png',
                width: 54,
                height: 54,
                filterQuality: FilterQuality.none,
              ),
              const SizedBox(width: 14),
              Text(
                'ZETA IDLE',
                style: GoogleFonts.rajdhani(
                  fontSize: 37,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentGold,
                  letterSpacing: 6,
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: -0.2, duration: 600.ms, curve: Curves.easeOut),
          const SizedBox(height: 8),
          Text(
            '— SELECT CHARACTER —',
            style: GoogleFonts.rajdhani(
              fontSize: 12,
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
                // Mutable copy so we can patch in live values for the active slot
                final chars = List<CharacterSummary?>.from(data.characters);
                // If a slot is currently loaded, its live game-state values are
                // authoritative — the disk save may not have flushed yet.
                final game = GameStateProvider.of(ctx);
                if (game.isSlotLoaded && game.currentSlot < chars.length) {
                  final live = chars[game.currentSlot];
                  if (live != null) {
                    chars[game.currentSlot] = CharacterSummary(
                      slot: live.slot,
                      name: live.name,
                      level: game.hero.level,
                      heroClass: live.heroClass,
                      prestigeLevel: game.confirmedPrestigeLevel,
                      totalAscensionAp: game.totalAscensionAp,
                      gender: live.gender,
                      heroRace: live.heroRace ?? game.heroRace,
                      frameId: game.activeFrame,
                      nameColorId: game.activeNameColor,
                    );
                  }
                }
                final showLock = data.extraSlots < SaveService.maxExtraSlots;
                final itemCount = chars.length + (showLock ? 1 : 0);
                return ListView.separated(
                  // Bottom padding keeps the last card (often the faint LOCKED
                  // SLOT) from crowding the fixed "swipe to delete" footer.
                  padding: const EdgeInsets.fromLTRB(40, 0, 40, 16),
                  itemCount: itemCount,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (ctx, i) {
                    Widget tile;
                    if (i >= chars.length) {
                      tile = _LockedSlotTile(cost: 250 * (data.extraSlots + 1));
                    } else {
                      final slotTile = _SlotTile(
                        summary: chars[i],
                        frameColor: CosmeticItem.frameColorFor(chars[i]?.frameId),
                        nameColor: CosmeticItem.nameColorFor(chars[i]?.nameColorId),
                        onTap: () => _onSlotTapped(i, chars[i]),
                      );
                      final existing = chars[i];
                      // Occupied slots: swipe right-to-left to delete.
                      tile = existing == null
                          ? slotTile
                          : Dismissible(
                              key: ValueKey('slot_${i}_${existing.name}'),
                              direction: DismissDirection.endToStart,
                              background: const _DeleteSwipeBackground(),
                              confirmDismiss: (_) => _confirmDeleteDialog(existing),
                              onDismissed: (_) => _deleteSlot(i),
                              child: slotTile,
                            );
                    }
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
              'Swipe a character left to delete',
              style: GoogleFonts.rajdhani(
                fontSize: 11,
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
    required this.summary,
    required this.onTap,
    this.frameColor,
    this.nameColor,
  });

  final CharacterSummary? summary;
  final Color? frameColor; // equipped premium portrait frame
  final Color? nameColor;  // equipped premium name colour
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isEmpty = summary == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          color: isEmpty ? AppTheme.darkBg : AppTheme.cardBg,
          // Equipped premium frame recolours the whole card outline; otherwise
          // the default gold border is used.
          border: Border.all(
            color: isEmpty
                ? AppTheme.cardBorder
                : (frameColor ?? AppTheme.accentGold.withValues(alpha: 0.6)),
            width: isEmpty ? 1 : 2,
          ),
          boxShadow: (!isEmpty && frameColor != null)
              ? [BoxShadow(color: frameColor!.withValues(alpha: 0.4), blurRadius: 7)]
              : null,
        ),
        child: Stack(
          children: [
            isEmpty
                ? Center(child: _buildEmpty())
                : Padding(
                    padding: const EdgeInsets.only(left: 16, right: 18),
                    child: Row(
                      children: [
                        // Hero sprite (class + gender + race), wrapped in the
                        // equipped premium portrait frame when one is set.
                        _framedSprite(),
                        const SizedBox(width: 14),
                        Expanded(child: _buildCharacter(summary!)),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _framedSprite() {
    return SizedBox(
      width: 50,
      height: 74,
      child: FittedBox(
        fit: BoxFit.contain,
        child: BattleSprite(
          spriteId: summary!.heroClass?.spriteId ?? DndClass.fighter.spriteId,
          gender: summary!.gender,
          race: summary!.heroRace,
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
          style: GoogleFonts.rajdhani(
            fontSize: 15,
            color: AppTheme.textMuted,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildCharacter(CharacterSummary char) {
    final classLabel = char.heroClass?.displayName;
    final race = char.heroRace?.info;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (char.gender != null) ...[
              Text(
                char.gender!.icon,
                style: GoogleFonts.rajdhani(
                  fontSize: 17,
                  color: AppTheme.accentGold.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                char.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.rajdhani(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: nameColor ?? AppTheme.textLight,
                  letterSpacing: 1,
                ),
              ),
            ),
            // Race trait symbol.
            if (race != null) ...[
              const SizedBox(width: 8),
              Text(race.icon, style: const TextStyle(fontSize: 15)),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (race != null) ...[
              Text(
                race.displayName,
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  color: race.color,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '  ·  ',
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  color: AppTheme.cardBorder,
                ),
              ),
            ],
            if (classLabel != null) ...[
              Text(
                classLabel,
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '  ·  ',
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  color: AppTheme.cardBorder,
                ),
              ),
            ],
            Text(
              'Level ${char.level}',
              style: GoogleFonts.rajdhani(
                fontSize: 13,
                color: AppTheme.accentGold,
                letterSpacing: 1,
              ),
            ),
            if (char.totalAscensionAp > 0) ...[
              Text(
                '  ·  ',
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  color: AppTheme.cardBorder,
                ),
              ),
              Text(
                '⭑ ${char.totalAscensionAp} AP',
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  color: AppTheme.accentGoldBright,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
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

/// Red reveal shown behind a slot as you swipe it right-to-left to delete.
class _DeleteSwipeBackground extends StatelessWidget {
  const _DeleteSwipeBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: AppTheme.accentRed.withValues(alpha: 0.85),
        border: Border.all(color: AppTheme.accentRed, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('DELETE',
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              )),
          const SizedBox(width: 8),
          const Icon(Icons.delete_outline, color: Colors.white, size: 20),
        ],
      ),
    );
  }
}

class _LockedSlotTile extends StatelessWidget {
  const _LockedSlotTile({this.cost});
  final int? cost;

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
          const Text('🔒', style: TextStyle(fontSize: 19)),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LOCKED SLOT',
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                cost != null
                    ? 'Buy in Shop → Misc ($cost ZC)'
                    : 'Buy in Shop → Misc',
                style: GoogleFonts.rajdhani(
                  fontSize: 10,
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
