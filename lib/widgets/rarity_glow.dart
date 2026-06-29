import 'dart:math';
import 'package:flutter/material.dart';

class RarityGlow extends StatefulWidget {
  const RarityGlow({
    super.key,
    required this.child,
    required this.color,
    this.intensity = 0.5,
    this.borderRadius = 4.0,
  });

  final Widget child;
  final Color color;
  final double intensity;
  final double borderRadius;

  @override
  State<RarityGlow> createState() => _RarityGlowState();
}

class _RarityGlowState extends State<RarityGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = 0.3 + 0.7 * (0.5 + 0.5 * sin(_ctrl.value * pi * 2));
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: widget.intensity * t * 0.6),
                blurRadius: 8 * t,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: widget.color.withValues(alpha: 0.3 + 0.4 * t),
                width: 1,
              ),
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}
