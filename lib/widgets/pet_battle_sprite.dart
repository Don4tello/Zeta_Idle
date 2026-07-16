import 'package:flutter/material.dart';
import '../models/pet.dart';
import 'pet_sprites.dart';

// Animated companion sprite shown behind the hero during battle.
// Flying pets bob vertically; ground pets breathe with a subtle scale pulse.
class PetBattleSprite extends StatefulWidget {
  const PetBattleSprite({super.key, required this.pet});
  final PetDefinition pet;

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
    final pet       = widget.pet;
    final painter   = petPainterFor(pet.id);
    final spriteSize = petSizeFor(pet.id);

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final t         = _anim.value;
        final glowAlpha = 0.18 + 0.30 * t;
        final offsetY   = pet.isFlying ? -(8.0 * t) : 0.0;
        final scale     = pet.isFlying ? 1.0 : (1.0 + 0.03 * t);

        Widget petSprite = painter != null
            ? CustomPaint(size: spriteSize, painter: painter)
            : Text(pet.emoji, style: TextStyle(fontSize: spriteSize.width * 0.56));

        petSprite = Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: pet.color.withValues(alpha: glowAlpha),
                blurRadius: 10 + 8 * t,
                spreadRadius: 2 + t,
              ),
            ],
          ),
          child: petSprite,
        );

        final animated = Transform.translate(
          offset: Offset(0, offsetY),
          child: Transform.scale(scale: scale, child: petSprite),
        );

        // Flying pets occupy extra vertical space so they appear elevated
        // relative to the hero's base when placed in the battle Stack.
        return SizedBox(
          width: spriteSize.width + 8,
          height: pet.isFlying ? spriteSize.height + 28 : spriteSize.height + 8,
          child: Align(
            alignment: pet.isFlying ? Alignment.topCenter : Alignment.bottomCenter,
            child: animated,
          ),
        );
      },
    );
  }
}
