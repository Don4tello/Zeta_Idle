import 'package:flutter/material.dart';
import 'zcoin_icon.dart';

/// Blocky pixel-art currency icons, matching the game's sprite aesthetic.
/// Drawn on a 12×12 grid so they stay crisp at any size.
/// ZCoins keep the dedicated animated [ZCoinIcon].
class CurrencyIcon extends StatelessWidget {
  const CurrencyIcon({super.key, required this.id, this.size = 16});
  final String id;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (id == 'zcoins') return ZCoinIcon(size: size, animate: false);
    return CustomPaint(
      size: Size(size, size),
      painter: _CurrencyIconPainter(id),
    );
  }
}

class _CurrencyIconPainter extends CustomPainter {
  const _CurrencyIconPainter(this.id);
  final String id;

  static const int _grid = 12;

  @override
  void paint(Canvas c, Size s) {
    final u = s.width / _grid;
    void row(int y, int x0, int x1, int argb) {
      c.drawRect(Rect.fromLTWH(x0 * u, y * u, (x1 - x0 + 1) * u, u),
          Paint()..color = Color(argb));
    }
    void px(int x, int y, int argb) => row(y, x, x, argb);

    switch (id) {
      case 'gold':
        const rim = 0xFF9a6314, body = 0xFFe8a832, lite = 0xFFffe375, sh = 0xFFc07d1e;
        row(2, 4, 7, rim);
        row(3, 3, 8, body); px(3, 3, rim); px(8, 3, rim); px(4, 3, lite); px(5, 3, lite);
        row(4, 2, 9, body); px(2, 4, rim); px(9, 4, rim); px(3, 4, lite);
        row(5, 2, 9, body); px(2, 5, rim); px(9, 5, rim); px(3, 5, lite);
        row(6, 2, 9, body); px(2, 6, rim); px(9, 6, rim);
        row(7, 2, 9, sh);   px(2, 7, rim); px(9, 7, rim);
        row(8, 3, 8, sh);   px(3, 8, rim); px(8, 8, rim);
        row(9, 4, 7, rim);
      case 'shards': // combat "Shards" — blue gem
        _gem(row, px, 0xFF2a4a8a, 0xFF4a86e0, 0xFFa8d0ff);
      case 'towerShards': // Tower Shards — teal crystal
        _gem(row, px, 0xFF186a7a, 0xFF32b8cc, 0xFF9cf0ff);
      case 'echoes': // sound / echo rings
        const dk = 0xFF1f7a68, mid = 0xFF33c8a8, lt = 0xFF7cffe0;
        row(2, 3, 4, lt); row(3, 2, 3, mid); row(4, 2, 2, dk);
        row(5, 1, 2, mid); row(6, 1, 2, mid); row(7, 2, 2, dk);
        row(8, 2, 3, mid); row(9, 3, 4, lt);
        // second wave arc
        row(3, 6, 7, dk); row(4, 7, 8, mid); row(5, 8, 9, lt);
        row(6, 8, 9, lt); row(7, 7, 8, mid); row(8, 6, 7, dk);
        px(5, 5, lt); px(5, 6, lt); // emitter dot
      case 'gemShards': // Arcane Dust — violet sparkle
        const dk = 0xFF5a2a9a, mid = 0xFF9a5ae0, lt = 0xFFd8b0ff;
        // 4-point sparkle
        row(1, 5, 6, lt); row(2, 5, 6, mid);
        row(4, 5, 6, mid); row(5, 3, 8, mid);
        px(4, 5, lt); px(5, 5, lt); px(6, 5, lt);
        row(6, 3, 8, mid); px(1, 5, mid); px(10, 5, mid);
        row(6, 5, 6, lt); row(7, 5, 6, mid); row(9, 5, 6, mid); row(10, 5, 6, lt);
        row(5, 1, 1, dk); row(6, 10, 10, dk);
        // scattered dust
        px(2, 2, lt); px(9, 3, mid); px(3, 9, mid); px(9, 9, lt);
      case 'mythril': // silvery ingot / ore
        const dk = 0xFF4a5a70, mid = 0xFF8fa6c0, lt = 0xFFdfeaf7;
        row(4, 3, 8, lt);
        row(5, 2, 9, mid); px(2, 5, dk); px(9, 5, dk); px(3, 5, lt); px(4, 5, lt);
        row(6, 2, 9, mid); px(2, 6, dk); px(9, 6, dk);
        row(7, 2, 9, dk);
        row(8, 3, 8, dk);
        // sparkle
        px(6, 3, lt); px(7, 4, 0xFFffffff);
      case 'paragonPoints': // Prestige Souls — ghostly wisp
        const dk = 0xFF5a3a9a, mid = 0xFF9a7ae0, lt = 0xFFe0d0ff;
        row(2, 4, 7, mid); row(3, 3, 8, lt);
        row(4, 3, 8, mid); px(4, 4, 0xFF201040); px(7, 4, 0xFF201040); // eyes
        row(5, 3, 8, mid);
        row(6, 3, 8, mid);
        row(7, 3, 8, lt);
        // wispy tail
        px(3, 8, mid); px(5, 8, mid); px(7, 8, mid); px(8, 8, mid);
        px(4, 9, lt); px(6, 9, lt);
        px(2, 3, dk); px(9, 3, dk);
      case 'ascensionPoints': // gold star
        const dk = 0xFFb8901a, body = 0xFFffd94a, lt = 0xFFfff2b0;
        px(5, 1, lt); px(6, 1, lt);
        row(2, 5, 6, body);
        row(3, 4, 7, body); px(4, 3, lt);
        row(4, 1, 10, body); px(1, 4, dk); px(10, 4, dk); px(3, 4, lt); px(4, 4, lt);
        row(5, 2, 9, body);
        row(6, 3, 8, body);
        row(7, 3, 8, body); px(3, 7, dk); px(8, 7, dk);
        px(3, 8, body); px(4, 8, dk); px(7, 8, dk); px(8, 8, body);
        row(9, 2, 3, body); row(9, 8, 9, body);
        px(2, 10, dk); px(9, 10, dk);
      default:
        // fallback: neutral gem
        _gem(row, px, 0xFF555555, 0xFF999999, 0xFFdddddd);
    }
  }

  // Shared cut-gem shape (wide crown, pointed base).
  void _gem(void Function(int, int, int, int) row, void Function(int, int, int) px,
      int rim, int body, int lite) {
    row(2, 4, 7, rim);
    row(3, 3, 8, body); px(3, 3, rim); px(8, 3, rim); px(4, 3, lite); px(5, 3, lite);
    row(4, 2, 9, body); px(2, 4, rim); px(9, 4, rim); px(3, 4, lite);
    row(5, 3, 8, body); px(3, 5, rim); px(8, 5, rim);
    row(6, 3, 8, body); px(3, 6, rim); px(8, 6, rim);
    row(7, 4, 7, body); px(4, 7, rim); px(7, 7, rim);
    row(8, 5, 6, body); px(5, 8, rim); px(6, 8, rim);
    px(5, 9, rim); px(6, 9, rim); // tip
  }

  @override
  bool shouldRepaint(_CurrencyIconPainter old) => old.id != id;
}
