import 'dart:math';
import 'package:flutter/material.dart';
import '../models/hero_model.dart' show HeroGender;
import '../models/hero_race.dart';

/// Hand-drawn ♂/♀ gender glyphs, tinted by [color].
class GenderSprite extends StatelessWidget {
  const GenderSprite({super.key, required this.gender, required this.color, this.size = 22});
  final HeroGender gender;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _GenderPainter(gender, color)),
      );
}

class _GenderPainter extends CustomPainter {
  const _GenderPainter(this.gender, this.color);
  final HeroGender gender;
  final Color color;

  @override
  void paint(Canvas cv, Size s) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    final r = s.width * 0.2;
    if (gender == HeroGender.male) {
      // Mars: circle low-left + arrow to upper-right
      final c = Offset(s.width * 0.4, s.height * 0.6);
      cv.drawCircle(c, r, p);
      final tip = Offset(s.width * 0.82, s.height * 0.18);
      cv.drawLine(Offset(c.dx + r * 0.7, c.dy - r * 0.7), tip, p);
      cv.drawLine(tip, Offset(tip.dx - s.width * 0.2, tip.dy), p);
      cv.drawLine(tip, Offset(tip.dx, tip.dy + s.height * 0.2), p);
    } else {
      // Venus: circle up + cross below
      final c = Offset(s.width * 0.5, s.height * 0.38);
      cv.drawCircle(c, r, p);
      cv.drawLine(Offset(c.dx, c.dy + r), Offset(c.dx, s.height * 0.9), p);
      cv.drawLine(Offset(c.dx - s.width * 0.16, s.height * 0.74), Offset(c.dx + s.width * 0.16, s.height * 0.74), p);
    }
  }

  @override
  bool shouldRepaint(covariant _GenderPainter old) => old.gender != gender || old.color != color;
}

/// Hand-drawn emblem for each playable race, tinted with the race's colour.
class RaceSprite extends StatelessWidget {
  const RaceSprite({super.key, required this.race, this.size = 30, this.color});
  final HeroRace race;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _RacePainter(race, color ?? race.info.color)),
      );
}

class _RacePainter extends CustomPainter {
  const _RacePainter(this.race, this.color);
  final HeroRace race;
  final Color color;

  @override
  void paint(Canvas cv, Size s) {
    final cx = s.width / 2, cy = s.height / 2;
    switch (race) {
      case HeroRace.human:      _human(cv, cx, cy, s);
      case HeroRace.elf:        _leaf(cv, cx, cy, s);
      case HeroRace.dwarf:      _hammer(cv, cx, cy, s);
      case HeroRace.halfling:   _clover(cv, cx, cy, s);
      case HeroRace.gnome:      _gear(cv, cx, cy, s);
      case HeroRace.halfElf:    _moon(cv, cx, cy, s);
      case HeroRace.halfOrc:    _tusks(cv, cx, cy, s);
      case HeroRace.tiefling:   _horns(cv, cx, cy, s);
      case HeroRace.dragonborn: _dragon(cv, cx, cy, s);
      case HeroRace.aasimar:    _halo(cv, cx, cy, s);
    }
  }

  Paint _fill(Color c) => Paint()..color = c..isAntiAlias = true;
  Paint _stroke(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..isAntiAlias = true;

  // Human — a bust silhouette
  void _human(Canvas cv, double cx, double cy, Size s) {
    cv.drawCircle(Offset(cx, cy - s.height * 0.12), s.width * 0.16, _fill(color));
    final body = Path()
      ..moveTo(cx - s.width * 0.26, cy + s.height * 0.3)
      ..quadraticBezierTo(cx - s.width * 0.26, cy + s.height * 0.06, cx, cy + s.height * 0.06)
      ..quadraticBezierTo(cx + s.width * 0.26, cy + s.height * 0.06, cx + s.width * 0.26, cy + s.height * 0.3)
      ..close();
    cv.drawPath(body, _fill(color));
    cv.drawCircle(Offset(cx - s.width * 0.05, cy - s.height * 0.16), s.width * 0.04, _fill(Colors.white.withValues(alpha: 0.5)));
  }

  // Elf — a pointed leaf
  void _leaf(Canvas cv, double cx, double cy, Size s) {
    final path = Path()
      ..moveTo(cx - s.width * 0.02, cy + s.height * 0.3)
      ..quadraticBezierTo(cx - s.width * 0.3, cy - s.height * 0.02, cx, cy - s.height * 0.32)
      ..quadraticBezierTo(cx + s.width * 0.3, cy - s.height * 0.02, cx - s.width * 0.02, cy + s.height * 0.3);
    cv.drawPath(path, _fill(color));
    cv.drawLine(Offset(cx - s.width * 0.02, cy + s.height * 0.3), Offset(cx, cy - s.height * 0.28),
        _stroke(Color.lerp(color, Colors.black, 0.35)!, 1.4));
  }

  // Dwarf — a war hammer
  void _hammer(Canvas cv, double cx, double cy, Size s) {
    cv.drawRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - s.height * 0.14), width: s.width * 0.5, height: s.height * 0.24),
        Radius.circular(s.width * 0.04)), _fill(color));
    cv.drawRect(Rect.fromCenter(center: Offset(cx, cy + s.height * 0.14), width: s.width * 0.09, height: s.height * 0.42),
        _fill(Color.lerp(color, Colors.black, 0.2)!));
    cv.drawRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - s.width * 0.18, cy - s.height * 0.14), width: s.width * 0.08, height: s.height * 0.24),
        const Radius.circular(1)), _fill(Colors.white.withValues(alpha: 0.35)));
  }

  // Halfling — a four-leaf clover
  void _clover(Canvas cv, double cx, double cy, Size s) {
    final r = s.width * 0.15;
    for (final o in [Offset(0, -r), Offset(r, 0), Offset(0, r), Offset(-r, 0)]) {
      cv.drawCircle(Offset(cx + o.dx, cy + o.dy), r * 0.95, _fill(color));
    }
    cv.drawCircle(Offset(cx, cy), r * 0.5, _fill(Color.lerp(color, Colors.white, 0.3)!));
    cv.drawLine(Offset(cx + r * 0.4, cy + r * 0.8), Offset(cx + r, cy + r * 2),
        _stroke(Color.lerp(color, Colors.black, 0.2)!, 1.6));
  }

  // Gnome — a cog
  void _gear(Canvas cv, double cx, double cy, Size s) {
    final r = s.width * 0.2;
    for (int i = 0; i < 8; i++) {
      final a = i * pi / 4;
      cv.drawRect(Rect.fromCenter(center: Offset(cx + r * cos(a), cy + r * sin(a)), width: s.width * 0.09, height: s.width * 0.09), _fill(color));
    }
    cv.drawCircle(Offset(cx, cy), r, _fill(color));
    cv.drawCircle(Offset(cx, cy), s.width * 0.08, _fill(Color.lerp(color, Colors.black, 0.5)!));
  }

  // Half-Elf — a crescent moon
  void _moon(Canvas cv, double cx, double cy, Size s) {
    final p = Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: s.width * 0.28))
      ..addOval(Rect.fromCircle(center: Offset(cx + s.width * 0.14, cy - s.height * 0.05), radius: s.width * 0.26))
      ..fillType = PathFillType.evenOdd;
    cv.drawPath(p, _fill(color));
  }

  // Half-Orc — two curved tusks
  void _tusks(Canvas cv, double cx, double cy, Size s) {
    void tusk(double sign) {
      final path = Path()
        ..moveTo(cx + sign * s.width * 0.06, cy - s.height * 0.24)
        ..quadraticBezierTo(cx + sign * s.width * 0.26, cy + s.height * 0.02, cx + sign * s.width * 0.12, cy + s.height * 0.28)
        ..quadraticBezierTo(cx + sign * s.width * 0.02, cy + s.height * 0.04, cx + sign * s.width * 0.02, cy - s.height * 0.22)
        ..close();
      cv.drawPath(path, _fill(color));
    }
    tusk(1);
    tusk(-1);
    cv.drawCircle(Offset(cx - s.width * 0.05, cy - s.height * 0.18), s.width * 0.03, _fill(Colors.white.withValues(alpha: 0.5)));
  }

  // Tiefling — two devil horns
  void _horns(Canvas cv, double cx, double cy, Size s) {
    void horn(double sign) {
      final path = Path()
        ..moveTo(cx + sign * s.width * 0.08, cy + s.height * 0.28)
        ..quadraticBezierTo(cx + sign * s.width * 0.34, cy + s.height * 0.1, cx + sign * s.width * 0.28, cy - s.height * 0.3)
        ..quadraticBezierTo(cx + sign * s.width * 0.16, cy - s.height * 0.02, cx + sign * s.width * 0.02, cy + s.height * 0.28)
        ..close();
      cv.drawPath(path, _fill(color));
    }
    horn(1);
    horn(-1);
  }

  // Dragonborn — a stylised dragon head
  void _dragon(Canvas cv, double cx, double cy, Size s) {
    final head = Path()
      ..moveTo(cx - s.width * 0.28, cy + s.height * 0.12)
      ..lineTo(cx - s.width * 0.08, cy + s.height * 0.2)
      ..lineTo(cx + s.width * 0.28, cy + s.height * 0.08)
      ..lineTo(cx + s.width * 0.12, cy)
      ..lineTo(cx + s.width * 0.22, cy - s.height * 0.14)
      ..lineTo(cx, cy - s.height * 0.08)
      ..lineTo(cx - s.width * 0.08, cy - s.height * 0.26)
      ..lineTo(cx - s.width * 0.18, cy - s.height * 0.06)
      ..close();
    cv.drawPath(head, _fill(color));
    cv.drawCircle(Offset(cx, cy), s.width * 0.03, _fill(Colors.black.withValues(alpha: 0.7)));
  }

  // Aasimar — a halo with wings
  void _halo(Canvas cv, double cx, double cy, Size s) {
    cv.drawOval(Rect.fromCenter(center: Offset(cx, cy - s.height * 0.18), width: s.width * 0.32, height: s.height * 0.12),
        _stroke(color, 2.4));
    // wings
    for (final sign in [1.0, -1.0]) {
      cv.drawPath(Path()
        ..moveTo(cx, cy + s.height * 0.05)
        ..quadraticBezierTo(cx + sign * s.width * 0.3, cy - s.height * 0.06, cx + sign * s.width * 0.3, cy + s.height * 0.26)
        ..quadraticBezierTo(cx + sign * s.width * 0.12, cy + s.height * 0.08, cx, cy + s.height * 0.12), _fill(color));
    }
  }

  @override
  bool shouldRepaint(covariant _RacePainter old) => old.race != race || old.color != color;
}
