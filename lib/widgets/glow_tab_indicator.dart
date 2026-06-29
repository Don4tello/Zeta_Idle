import 'package:flutter/material.dart';

class GlowTabIndicator extends Decoration {
  const GlowTabIndicator({
    this.color = const Color(0xFFdaa520),
    this.height = 3.0,
    this.glowRadius = 6.0,
  });

  final Color color;
  final double height;
  final double glowRadius;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _GlowPainter(color, height, glowRadius);
}

class _GlowPainter extends BoxPainter {
  _GlowPainter(this.color, this.height, this.glowRadius);
  final Color color;
  final double height;
  final double glowRadius;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final width = cfg.size?.width ?? 0;
    final h = cfg.size?.height ?? 0;
    final rect = Rect.fromLTWH(
      offset.dx,
      offset.dy + h - height,
      width,
      height,
    );

    // Glow
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.inflate(1), const Radius.circular(2)),
      Paint()
        ..color = color.withValues(alpha: 0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowRadius),
    );

    // Solid indicator
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(1.5)),
      Paint()..color = color,
    );
  }
}
