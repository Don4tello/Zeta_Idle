import 'package:flutter/material.dart';

/// Segmented pixel-art health bar that fills its parent width.
///
/// Pass [width] only when you need a fixed size (e.g. inside a CustomPainter
/// canvas).  Leave it null (the default) and the bar expands to fill the
/// available horizontal space via LayoutBuilder.
class PixelHealthBar extends StatelessWidget {
  const PixelHealthBar({
    super.key,
    required this.current,
    required this.max,
    this.width,
    this.height = 12,
  });

  final int current;
  final int max;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final targetRatio = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: targetRatio),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      builder: (_, ratio, __) {
        if (width != null) return _bar(width!, ratio);
        return LayoutBuilder(builder: (_, c) => _bar(c.maxWidth, ratio));
      },
    );
  }

  Widget _bar(double w, double ratio) {
    final barColor = ratio > 0.5
        ? const Color(0xFF2a9040)
        : ratio > 0.25
            ? const Color(0xFFd4801a)
            : const Color(0xFFcc2020);
    return CustomPaint(
      size: Size(w, height),
      painter: _HealthBarPainter(ratio: ratio, barColor: barColor),
    );
  }
}

class _HealthBarPainter extends CustomPainter {
  const _HealthBarPainter({required this.ratio, required this.barColor});

  final double ratio;
  final Color barColor;

  static const _segW = 7.0;
  static const _gap  = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF181820),
    );

    final totalSegs  = ((size.width - 2) / (_segW + _gap)).floor();
    final filledSegs = (totalSegs * ratio).round();

    for (int i = 0; i < totalSegs; i++) {
      final x      = 1 + i * (_segW + _gap);
      final filled = i < filledSegs;
      canvas.drawRect(
        Rect.fromLTWH(x, 1, _segW, size.height - 2),
        Paint()..color = filled ? barColor : const Color(0xFF2a2a3a),
      );
      if (filled) {
        canvas.drawRect(
          Rect.fromLTWH(x, 1, _segW, 2),
          Paint()..color = Color.lerp(barColor, Colors.white, 0.4)!,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_HealthBarPainter old) => old.ratio != ratio;
}
