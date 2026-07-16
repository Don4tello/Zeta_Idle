import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/dnd_class.dart';
import '../widgets/battle_sprites.dart';

// ── Flavor texts ──────────────────────────────────────────────────────────────

const _kFlavorTexts = [
  'Awakening the cursed realm...',
  'Summoning fallen heroes...',
  'Forging ancient steel...',
  'Lighting the dungeon torches...',
  'Binding the hero\'s fate...',
  'Reading the tome of shadows...',
  'Sharpening blades in the dark...',
  'Waking the ancient evils...',
  'Consulting the war council...',
  'Counting the fallen...',
  'Polishing the rune stones...',
  'Feeding the dungeon beasts...',
];

// ── Stone width pattern — deterministic, repeating ───────────────────────────

const _kStoneWidths = [
  36.0, 28.0, 44.0, 32.0, 40.0, 26.0, 38.0, 48.0,
  30.0, 34.0, 42.0, 28.0, 36.0, 44.0, 32.0, 38.0,
];

// ── Main widget ───────────────────────────────────────────────────────────────

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({
    super.key,
    required this.task,
    required this.onComplete,
  });

  /// The async work to perform while loading.
  final Future<void> Function() task;

  /// Called once progress reaches 100% and the brief hold has elapsed.
  final VoidCallback onComplete;

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _progressCtrl;
  late final AnimationController _walkCtrl;
  late final String _heroSpriteId;
  late final String _flavorText;

  @override
  void initState() {
    super.initState();

    final rng = Random();
    _heroSpriteId =
        DndClass.values[rng.nextInt(DndClass.values.length)].spriteId;
    _flavorText = _kFlavorTexts[rng.nextInt(_kFlavorTexts.length)];

    // Progress controller — no fixed duration, driven manually
    _progressCtrl = AnimationController(vsync: this);

    // Walk cycle
    _walkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..repeat();

    // Phase 1: simulate 0 → 85% over 1.3 s while task runs
    _progressCtrl
        .animateTo(
          0.85,
          duration: const Duration(milliseconds: 1300),
          curve: Curves.easeOut,
        )
        .ignore();

    // Run task; whether it succeeds or throws, finish the bar
    widget
        .task()
        .then((_) => _finish())
        .catchError((_) => _finish());
  }

  void _finish() {
    if (!mounted) return;
    // Phase 2: animate remaining progress to 100% quickly
    _progressCtrl
        .animateTo(
          1.0,
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeIn,
        )
        .then((_) {
      if (!mounted) return;
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) widget.onComplete();
      });
    });
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _walkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF1B1A17),
        body: AnimatedBuilder(
          animation: Listenable.merge([_progressCtrl, _walkCtrl]),
          builder: (_, __) {
            final progress = _progressCtrl.value;
            return Stack(
              children: [
                _Vignette(),
                SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTitle(),
                      const SizedBox(height: 72),
                      _buildPath(progress),
                      const SizedBox(height: 20),
                      _buildLabels(progress),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Title ──────────────────────────────────────────────────────────────────

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'ZETA IDLE',
          style: GoogleFonts.rajdhani(
            fontSize: 41,
            fontWeight: FontWeight.bold,
            color: AppTheme2.gold,
            letterSpacing: 8,
            shadows: [
              Shadow(
                color: AppTheme2.gold.withValues(alpha: 0.35),
                blurRadius: 24,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '— THE CURSED REALM —',
          style: GoogleFonts.rajdhani(
            fontSize: 12,
            color: const Color(0xFF555577),
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }

  // ── Stone path with hero ───────────────────────────────────────────────────

  Widget _buildPath(double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: LayoutBuilder(
        builder: (_, constraints) {
          final barW = constraints.maxWidth;
          // Hero center tracks progress; clamp so it stays on the bar
          final heroCenter =
              (progress * barW).clamp(22.0, barW - 22.0);

          return SizedBox(
            height: 92,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomLeft,
              children: [
                // Stone path bar
                Positioned(
                  bottom: 0,
                  left: 0,
                  width: barW,
                  child: CustomPaint(
                    size: Size(barW, 30),
                    painter:
                        _StonePathPainter(progress: progress),
                  ),
                ),
                // Walking hero — feet sit on stone surface
                Positioned(
                  bottom: 26,
                  left: heroCenter - 21,
                  width: 42,
                  height: 56,
                  child: _WalkingHero(
                    spriteId: _heroSpriteId,
                    walkPhase: _walkCtrl.value,
                  ),
                ),
                // Torch glow at leading edge (above bar)
                if (progress > 0.02 && progress < 0.98)
                  Positioned(
                    bottom: 24,
                    left: heroCenter - 18,
                    width: 36,
                    height: 36,
                    child: CustomPaint(
                      painter: _TorchGlowPainter(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Labels ─────────────────────────────────────────────────────────────────

  Widget _buildLabels(double progress) {
    return Column(
      children: [
        Text(
          _flavorText,
          style: GoogleFonts.rajdhani(
            fontSize: 12,
            color: const Color(0xFF4a4a66),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${(progress * 100).toInt()}%',
          style: GoogleFonts.rajdhani(
            fontSize: 11,
            color: const Color(0xFF3a3a55),
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

// ── Vignette overlay ──────────────────────────────────────────────────────────

class _Vignette extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Colors.transparent, Color(0xCC000008)],
            stops: [0.45, 1.0],
          ),
        ),
      ),
    );
  }
}

// ── Walking hero ──────────────────────────────────────────────────────────────

class _WalkingHero extends StatelessWidget {
  const _WalkingHero({required this.spriteId, required this.walkPhase});

  final String spriteId;
  final double walkPhase; // 0.0–1.0, cycles

  @override
  Widget build(BuildContext context) {
    // Gentle stride lean: rocks forward and back once per step cycle
    final lean = sin(walkPhase * 2 * pi) * 0.08;
    return Transform.rotate(
      angle: lean,
      alignment: Alignment.bottomCenter,
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.bottomCenter,
        child: BattleSprite(spriteId: spriteId),
      ),
    );
  }
}

// ── Torch glow above leading edge ─────────────────────────────────────────────

class _TorchGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final shader = RadialGradient(
      colors: [
        const Color(0xFFffcc44).withValues(alpha: 0.28),
        const Color(0xFFff8800).withValues(alpha: 0.12),
        Colors.transparent,
      ],
      stops: const [0.0, 0.4, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: size.width));
    canvas.drawCircle(center, size.width, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_TorchGlowPainter _) => false;
}

// ── Stone path painter ────────────────────────────────────────────────────────

class _StonePathPainter extends CustomPainter {
  _StonePathPainter({required this.progress});

  final double progress;

  // Gap between stones (mortar)
  static const _gap = 4.0;
  // Bevel size
  static const _bv = 2.0;

  // Cold stone (unfilled)
  static const _coldBase   = Color(0xFF3a3a48);
  static const _coldHi     = Color(0xFF4c4c5e);
  static const _coldShadow = Color(0xFF26221E);

  // Warm stone (filled, far from hero)
  static const _warmFar    = Color(0xFF4a3416);
  // Warm stone (filled, near hero — torch-lit)
  static const _warmNear   = Color(0xFF7d5a28);
  // Warm bevel
  static const _warmHi     = Color(0xFF956c30);
  static const _warmShadow = Color(0xFF2e1f0a);

  // Mortar
  static const _mortar = Color(0xFF1a1a24);

  @override
  void paint(Canvas canvas, Size size) {
    // Mortar base
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = _mortar,
    );

    final fillX = size.width * progress;
    double x = 0;
    int idx = 0;

    while (x < size.width) {
      final w = _kStoneWidths[idx % _kStoneWidths.length];
      final clipped = (x + w > size.width) ? (size.width - x) : w;
      if (clipped <= 0) break;

      final rect = Rect.fromLTWH(x, 0, clipped, size.height);
      final centerX = x + w / 2;
      final isFilled = centerX < fillX;

      _paintStone(canvas, rect, isFilled, fillX, centerX, idx);

      x += w + _gap;
      idx++;
    }

    // Leading-edge shimmer on the bar surface
    if (progress > 0.01 && progress < 0.99) {
      _paintEdgeShimmer(canvas, size, fillX);
    }
  }

  void _paintStone(
      Canvas canvas, Rect r, bool warm, double fillX, double cx, int idx) {
    final Color base;
    final Color hi;
    final Color sh;

    if (warm) {
      // Torch falloff: stones near the hero are brighter
      final dist = (fillX - cx).clamp(0.0, fillX + 1);
      final t = (1.0 - dist / (fillX.clamp(1, double.infinity))).clamp(0.0, 1.0);
      base = Color.lerp(_warmFar, _warmNear, t * t)!;
      hi = _warmHi;
      sh = _warmShadow;
    } else {
      base = _coldBase;
      hi = _coldHi;
      sh = _coldShadow;
    }

    // Main slab face
    canvas.drawRect(r, Paint()..color = base);

    // Top-left highlight (bevel)
    canvas.drawRect(Rect.fromLTWH(r.left, r.top, r.width, _bv),
        Paint()..color = hi);
    canvas.drawRect(Rect.fromLTWH(r.left, r.top, _bv, r.height),
        Paint()..color = hi);

    // Bottom-right shadow (bevel)
    canvas.drawRect(Rect.fromLTWH(r.left, r.bottom - _bv, r.width, _bv),
        Paint()..color = sh);
    canvas.drawRect(Rect.fromLTWH(r.right - _bv, r.top, _bv, r.height),
        Paint()..color = sh);

    // Crack detail (~45% of stones)
    _paintCrack(canvas, r, idx, warm);
  }

  void _paintCrack(Canvas canvas, Rect r, int idx, bool warm) {
    final rng = Random(idx * 17 + 3);
    if (rng.nextDouble() > 0.45) return;

    // Two-segment crack
    final ax = r.left + r.width * (0.2 + rng.nextDouble() * 0.35);
    final ay = r.top + _bv + 1.0;
    final bx = ax + (rng.nextDouble() - 0.5) * 5;
    final by = r.top + r.height * (0.35 + rng.nextDouble() * 0.25);
    final cx2 = bx + (rng.nextDouble() - 0.5) * 5;
    final cy = r.top + r.height * (0.6 + rng.nextDouble() * 0.3);

    final path = Path()
      ..moveTo(ax, ay)
      ..lineTo(bx, by)
      ..lineTo(cx2, cy);

    canvas.drawPath(
      path,
      Paint()
        ..color = warm
            ? const Color(0xFF1a0e04).withValues(alpha: 0.5)
            : const Color(0xFF1A1714).withValues(alpha: 0.5)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  void _paintEdgeShimmer(Canvas canvas, Size size, double fillX) {
    const w = 32.0;
    final rect = Rect.fromLTWH(fillX - w / 2, 0, w, size.height);
    final shader = LinearGradient(
      colors: [
        Colors.transparent,
        const Color(0xFFffbb44).withValues(alpha: 0.4),
        const Color(0xFFffd966).withValues(alpha: 0.6),
        const Color(0xFFffbb44).withValues(alpha: 0.4),
        Colors.transparent,
      ],
      stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
    ).createShader(rect);
    canvas.drawRect(rect, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_StonePathPainter old) => old.progress != progress;
}

// ── Minimal theme constants (avoid importing AppTheme to keep this portable) ──

class AppTheme2 {
  static const gold = Color(0xFFC9A35A);
}
