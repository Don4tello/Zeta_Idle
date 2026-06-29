import 'dart:math';
import 'package:flutter/material.dart';

class AmbientParticles extends StatefulWidget {
  const AmbientParticles({super.key, this.count = 20, this.color = const Color(0xFFdaa520)});
  final int count;
  final Color color;

  @override
  State<AmbientParticles> createState() => _AmbientParticlesState();
}

class _AmbientParticlesState extends State<AmbientParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_Particle> _particles;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _particles = List.generate(widget.count, (_) => _Particle(_rng));
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          size: Size.infinite,
          painter: _ParticlePainter(_particles, _ctrl.value, widget.color),
        ),
      ),
    );
  }
}

class _Particle {
  _Particle(Random rng)
      : x = rng.nextDouble(),
        y = rng.nextDouble(),
        speed = 0.02 + rng.nextDouble() * 0.04,
        size = 1.0 + rng.nextDouble() * 2.0,
        phase = rng.nextDouble();

  final double x, speed, size, phase;
  double y;
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.particles, this.t, this.color);
  final List<_Particle> particles;
  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final y = (p.y - t * p.speed * 10) % 1.0;
      final x = p.x + sin((t + p.phase) * pi * 2) * 0.02;
      final alpha = (0.15 + 0.35 * sin((t + p.phase) * pi * 4).abs()).clamp(0.0, 1.0);
      final paint = Paint()..color = color.withValues(alpha: alpha);
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}
