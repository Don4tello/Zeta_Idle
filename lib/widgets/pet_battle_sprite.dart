import 'package:flutter/material.dart';
import '../models/pet.dart';

// Animated companion sprite shown behind the hero during battle.
// Flying pets bob vertically; ground pets breathe with a subtle scale pulse.
class PetBattleSprite extends StatefulWidget {
  const PetBattleSprite({super.key, required this.pet, this.size = 30});
  final PetDefinition pet;
  final double size;

  @override
  State<PetBattleSprite> createState() => _PetBattleSpriteState();
}

class _PetBattleSpriteState extends State<PetBattleSprite>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);
  late final Animation<double> _anim =
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pet = widget.pet;
    final s   = widget.size;

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final t         = _anim.value;
        final glowAlpha = 0.18 + 0.30 * t;
        final offsetY   = pet.isFlying ? -(6.0 * t) : 0.0;
        final scale     = pet.isFlying ? 1.0 : (1.0 + 0.04 * t);

        final circle = Transform.translate(
          offset: Offset(0, offsetY),
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: s,
              height: s,
              decoration: BoxDecoration(
                color: pet.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(s / 2),
                boxShadow: [
                  BoxShadow(
                    color: pet.color.withValues(alpha: glowAlpha),
                    blurRadius: 8 + 6 * t,
                    spreadRadius: 1 + t,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  pet.emoji,
                  style: TextStyle(fontSize: s * 0.56),
                ),
              ),
            ),
          ),
        );

        // Flying pets occupy extra vertical space at the top so they appear elevated
        // relative to the hero sprite when placed in a Row(crossAxisAlignment: end).
        return SizedBox(
          width: s + 8,
          height: pet.isFlying ? s + 30 : s + 8,
          child: Align(
            alignment: pet.isFlying ? Alignment.topCenter : Alignment.bottomCenter,
            child: circle,
          ),
        );
      },
    );
  }
}
