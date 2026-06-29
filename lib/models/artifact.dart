import 'dart:math';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// ArtifactBaseType — 7 item categories, each with a unique painted icon
// ---------------------------------------------------------------------------

enum ArtifactBaseType { idol, cross, book, sword, gemstone, charm, tapestry }

extension ArtifactBaseTypeExt on ArtifactBaseType {
  String get label => switch (this) {
    ArtifactBaseType.idol     => 'Idol',
    ArtifactBaseType.cross    => 'Cross',
    ArtifactBaseType.book     => 'Book',
    ArtifactBaseType.sword    => 'Sword',
    ArtifactBaseType.gemstone => 'Gemstone',
    ArtifactBaseType.charm    => 'Charm',
    ArtifactBaseType.tapestry => 'Tapestry',
  };

  Color get color => switch (this) {
    ArtifactBaseType.idol     => const Color(0xFFe8a84c),
    ArtifactBaseType.cross    => const Color(0xFFf0df60),
    ArtifactBaseType.book     => const Color(0xFF44cccc),
    ArtifactBaseType.sword    => const Color(0xFF88aadd),
    ArtifactBaseType.gemstone => const Color(0xFFcc66ff),
    ArtifactBaseType.charm    => const Color(0xFF66dd88),
    ArtifactBaseType.tapestry => const Color(0xFFdd6655),
  };

  static const _imageCount = <ArtifactBaseType, int>{
    ArtifactBaseType.sword:    4,
    ArtifactBaseType.book:     6,
    ArtifactBaseType.idol:     1,
    ArtifactBaseType.tapestry: 3,
    ArtifactBaseType.charm:    5,
    ArtifactBaseType.gemstone: 5,
    ArtifactBaseType.cross:    0,
  };

  String get imagePath => 'assets/images/artifact_${name}_1.png';

  String imagePathForRarity(ArtifactRarity rarity) {
    final count = _imageCount[this] ?? 0;
    if (count == 0) return imagePath; // will trigger errorBuilder fallback
    final idx = switch (rarity) {
      ArtifactRarity.common => 1,
      ArtifactRarity.magic  => count > 1 ? 2 : 1,
      ArtifactRarity.rare   => count > 2 ? 3 : count,
    };
    return 'assets/images/artifact_${name}_$idx.png';
  }
}

// ---------------------------------------------------------------------------
// ArtifactRarity
// ---------------------------------------------------------------------------

enum ArtifactRarity { common, magic, rare }

extension ArtifactRarityExt on ArtifactRarity {
  String get label => switch (this) {
    ArtifactRarity.common => 'Common',
    ArtifactRarity.magic  => 'Magic',
    ArtifactRarity.rare   => 'Rare',
  };

  Color get color => switch (this) {
    ArtifactRarity.common => const Color(0xFF999999),
    ArtifactRarity.magic  => const Color(0xFF4488ff),
    ArtifactRarity.rare   => const Color(0xFFffcc44),
  };
}

// ---------------------------------------------------------------------------
// ArtifactBase — 7 base items, one per type
// ---------------------------------------------------------------------------

class ArtifactBase {
  const ArtifactBase({
    required this.id,
    required this.name,
    required this.type,
    required this.flavorText,
    this.attackBonus = 0,
    this.damageBonus = 0,
    this.acBonus     = 0,
    this.hpPct       = 0,
    this.shardPct    = 0,
    this.goldPct     = 0,
    this.xpPct       = 0,
  });

  final String           id;
  final String           name;
  final ArtifactBaseType type;
  final String           flavorText;
  final int attackBonus;
  final int damageBonus;
  final int acBonus;
  final int hpPct;
  final int shardPct;
  final int goldPct;
  final int xpPct;

  static const all = <ArtifactBase>[
    ArtifactBase(
      id: 'b_idol', name: 'Idol', type: ArtifactBaseType.idol,
      flavorText: 'Carved in the image of something that listens.',
      hpPct: 5,
    ),
    ArtifactBase(
      id: 'b_cross', name: 'Cross', type: ArtifactBaseType.cross,
      flavorText: 'The blessing is faded but the shape remains.',
      hpPct: 3, acBonus: 1,
    ),
    ArtifactBase(
      id: 'b_book', name: 'Book', type: ArtifactBaseType.book,
      flavorText: 'Every page read is a year of battle saved.',
      xpPct: 7,
    ),
    ArtifactBase(
      id: 'b_sword', name: 'Sword', type: ArtifactBaseType.sword,
      flavorText: 'Too small to fight with. Too sharp to ignore.',
      attackBonus: 1, damageBonus: 2,
    ),
    ArtifactBase(
      id: 'b_gemstone', name: 'Gemstone', type: ArtifactBaseType.gemstone,
      flavorText: 'Worth more than the kingdom it came from.',
      shardPct: 5, goldPct: 5,
    ),
    ArtifactBase(
      id: 'b_charm', name: 'Charm', type: ArtifactBaseType.charm,
      flavorText: 'Fortune follows those who carry it.',
      goldPct: 6, xpPct: 3,
    ),
    ArtifactBase(
      id: 'b_tapestry', name: 'Tapestry', type: ArtifactBaseType.tapestry,
      flavorText: 'Woven from thread that has never been cut.',
      acBonus: 1, hpPct: 3,
    ),
  ];

  static ArtifactBase? byId(String id) =>
      all.where((b) => b.id == id).firstOrNull;
}

// ---------------------------------------------------------------------------
// ArtifactAffix — 20 affixes (10 prefix, 10 suffix)
// ---------------------------------------------------------------------------

enum AffixKind { prefix, suffix }

class ArtifactAffix {
  const ArtifactAffix({
    required this.id,
    required this.name,
    required this.kind,
    this.attackBonus = 0,
    this.damageBonus = 0,
    this.acBonus     = 0,
    this.hpPct       = 0,
    this.shardPct    = 0,
    this.goldPct     = 0,
    this.xpPct       = 0,
  });

  final String    id;
  final String    name;
  final AffixKind kind;
  final int attackBonus;
  final int damageBonus;
  final int acBonus;
  final int hpPct;
  final int shardPct;
  final int goldPct;
  final int xpPct;

  static const prefixes = <ArtifactAffix>[
    ArtifactAffix(id: 'px_sturdy',   name: 'Sturdy',        kind: AffixKind.prefix, hpPct: 6),
    ArtifactAffix(id: 'px_sharp',    name: 'Sharp',         kind: AffixKind.prefix, attackBonus: 1),
    ArtifactAffix(id: 'px_fierce',   name: 'Fierce',        kind: AffixKind.prefix, damageBonus: 2),
    ArtifactAffix(id: 'px_warded',   name: 'Warded',        kind: AffixKind.prefix, acBonus: 1),
    ArtifactAffix(id: 'px_gilded',   name: 'Gilded',        kind: AffixKind.prefix, goldPct: 8),
    ArtifactAffix(id: 'px_blessed',  name: 'Blessed',       kind: AffixKind.prefix, xpPct: 8),
    ArtifactAffix(id: 'px_shard',    name: 'Shard-Touched', kind: AffixKind.prefix, shardPct: 8),
    ArtifactAffix(id: 'px_ironclad', name: 'Ironclad',      kind: AffixKind.prefix, acBonus: 1, hpPct: 3),
    ArtifactAffix(id: 'px_swift',    name: 'Swift',         kind: AffixKind.prefix, attackBonus: 1, damageBonus: 1),
    ArtifactAffix(id: 'px_ancient',  name: 'Ancient',       kind: AffixKind.prefix, attackBonus: 1, acBonus: 1, hpPct: 3, goldPct: 3),
  ];

  static const suffixes = <ArtifactAffix>[
    ArtifactAffix(id: 'sx_fortitude', name: 'of Fortitude',       kind: AffixKind.suffix, hpPct: 6),
    ArtifactAffix(id: 'sx_slaying',   name: 'of Slaying',         kind: AffixKind.suffix, damageBonus: 2),
    ArtifactAffix(id: 'sx_precision', name: 'of Precision',       kind: AffixKind.suffix, attackBonus: 1),
    ArtifactAffix(id: 'sx_protect',   name: 'of Protection',      kind: AffixKind.suffix, acBonus: 1),
    ArtifactAffix(id: 'sx_wealth',    name: 'of Wealth',          kind: AffixKind.suffix, goldPct: 8),
    ArtifactAffix(id: 'sx_wisdom',    name: 'of Wisdom',          kind: AffixKind.suffix, xpPct: 8),
    ArtifactAffix(id: 'sx_crystal',   name: 'of Crystallization', kind: AffixKind.suffix, shardPct: 8),
    ArtifactAffix(id: 'sx_bulwark',   name: 'of the Bulwark',     kind: AffixKind.suffix, acBonus: 1, hpPct: 3),
    ArtifactAffix(id: 'sx_hunt',      name: 'of the Hunt',        kind: AffixKind.suffix, attackBonus: 1, damageBonus: 1),
    ArtifactAffix(id: 'sx_ages',      name: 'of Ages',            kind: AffixKind.suffix, attackBonus: 1, acBonus: 1, hpPct: 3, goldPct: 3),
  ];

  static ArtifactAffix? byId(String? id) {
    if (id == null) return null;
    for (final a in [...prefixes, ...suffixes]) {
      if (a.id == id) return a;
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// Artifact — generated instance
// ---------------------------------------------------------------------------

class Artifact {
  const Artifact({
    required this.uid,
    required this.base,
    this.prefix,
    this.suffix,
    required this.dropLevel,
  });

  final String         uid;
  final ArtifactBase   base;
  final ArtifactAffix? prefix;
  final ArtifactAffix? suffix;
  final int            dropLevel;

  ArtifactBaseType get type => base.type;

  ArtifactRarity get rarity {
    final count = (prefix != null ? 1 : 0) + (suffix != null ? 1 : 0);
    return switch (count) {
      0 => ArtifactRarity.common,
      1 => ArtifactRarity.magic,
      _ => ArtifactRarity.rare,
    };
  }

  String get name {
    final p = prefix?.name;
    final s = suffix?.name;
    if (p != null && s != null) return '$p ${base.name} $s';
    if (p != null)              return '$p ${base.name}';
    if (s != null)              return '${base.name} $s';
    return base.name;
  }

  String get flavorText => base.flavorText;

  double get _scale => 1.0 + dropLevel * 0.04;

  static int _n(int? v) => v ?? 0;

  int get attackBonus => ((_n(base.attackBonus) + _n(prefix?.attackBonus) + _n(suffix?.attackBonus)) * _scale).round();
  int get damageBonus => ((_n(base.damageBonus) + _n(prefix?.damageBonus) + _n(suffix?.damageBonus)) * _scale).round();
  int get acBonus     => ((_n(base.acBonus)     + _n(prefix?.acBonus)     + _n(suffix?.acBonus))     * _scale).round();
  int get hpPct       => ((_n(base.hpPct)       + _n(prefix?.hpPct)       + _n(suffix?.hpPct))       * _scale).round();
  int get shardPct    => ((_n(base.shardPct)     + _n(prefix?.shardPct)    + _n(suffix?.shardPct))    * _scale).round();
  int get goldPct     => ((_n(base.goldPct)      + _n(prefix?.goldPct)     + _n(suffix?.goldPct))     * _scale).round();
  int get xpPct       => ((_n(base.xpPct)        + _n(prefix?.xpPct)       + _n(suffix?.xpPct))       * _scale).round();

  Map<String, dynamic> toJson() => {
    'uid':      uid,
    'baseId':   base.id,
    'prefixId': prefix?.id,
    'suffixId': suffix?.id,
    'dropLv':   dropLevel,
  };

  static Artifact fromJson(Map<String, dynamic> json) {
    final base = ArtifactBase.byId(json['baseId'] as String);
    if (base == null) throw FormatException('Unknown base: ${json['baseId']}');
    return Artifact(
      uid:       json['uid'] as String,
      base:      base,
      prefix:    ArtifactAffix.byId(json['prefixId'] as String?),
      suffix:    ArtifactAffix.byId(json['suffixId'] as String?),
      dropLevel: (json['dropLv'] as num).toInt(),
    );
  }
}

// ---------------------------------------------------------------------------
// ArtifactGenerator
// ---------------------------------------------------------------------------

class ArtifactGenerator {
  ArtifactGenerator._();

  static Artifact roll({required int dropLevel, required Random rng}) {
    final base = ArtifactBase.all[rng.nextInt(ArtifactBase.all.length)];
    final uid  = '${DateTime.now().millisecondsSinceEpoch}_${rng.nextInt(999999)}';
    final lv   = dropLevel.clamp(1, 50);

    final roll      = rng.nextDouble();
    final rareThresh  = _rarePct(lv);
    final magicThresh = rareThresh + _magicPct(lv);

    ArtifactAffix? prefix;
    ArtifactAffix? suffix;

    if (roll < rareThresh) {
      prefix = ArtifactAffix.prefixes[rng.nextInt(ArtifactAffix.prefixes.length)];
      suffix = ArtifactAffix.suffixes[rng.nextInt(ArtifactAffix.suffixes.length)];
    } else if (roll < magicThresh) {
      if (rng.nextBool()) {
        prefix = ArtifactAffix.prefixes[rng.nextInt(ArtifactAffix.prefixes.length)];
      } else {
        suffix = ArtifactAffix.suffixes[rng.nextInt(ArtifactAffix.suffixes.length)];
      }
    }

    return Artifact(uid: uid, base: base, prefix: prefix, suffix: suffix, dropLevel: lv);
  }

  static double _rarePct(int lv) {
    if (lv >= 31) return 0.45;
    if (lv >= 16) return 0.30;
    if (lv >= 6)  return 0.15;
    return 0.05;
  }

  static double _magicPct(int lv) {
    if (lv >= 31) return 0.45;
    if (lv >= 16) return 0.50;
    if (lv >= 6)  return 0.45;
    return 0.35;
  }
}

// ---------------------------------------------------------------------------
// ArtifactIcon — renders a custom-painted icon for each base type
// ---------------------------------------------------------------------------

class ArtifactIcon extends StatelessWidget {
  const ArtifactIcon({
    super.key,
    required this.type,
    required this.color,
    required this.size,
    this.rarity,
  });

  final ArtifactBaseType type;
  final Color            color;
  final double           size;
  final ArtifactRarity?  rarity;

  @override
  Widget build(BuildContext context) {
    final path = rarity != null ? type.imagePathForRarity(rarity!) : type.imagePath;
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        path,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => CustomPaint(painter: _painterFor(type, color)),
      ),
    );
  }

  static CustomPainter _painterFor(ArtifactBaseType t, Color c) => switch (t) {
    ArtifactBaseType.idol     => _IdolPainter(c),
    ArtifactBaseType.cross    => _CrossPainter(c),
    ArtifactBaseType.book     => _BookPainter(c),
    ArtifactBaseType.sword    => _SwordPainter(c),
    ArtifactBaseType.gemstone => _GemstonePainter(c),
    ArtifactBaseType.charm    => _CharmPainter(c),
    ArtifactBaseType.tapestry => _TapestryPainter(c),
  };
}

// -- Idol: humanoid figure with raised arms ──────────────────────────────────
class _IdolPainter extends CustomPainter {
  const _IdolPainter(this.c);
  final Color c;
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = c..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round
      ..strokeWidth = s.width * 0.10;
    final fp = Paint()..color = c.withValues(alpha: 0.20)..style = PaintingStyle.fill;
    final w = s.width, h = s.height;
    // Base/plinth
    final plinth = Rect.fromLTRB(w * 0.25, h * 0.80, w * 0.75, h * 0.95);
    canvas.drawRect(plinth, fp);
    canvas.drawRect(plinth, p);
    // Body
    final body = Path()
      ..moveTo(w * 0.38, h * 0.44)
      ..lineTo(w * 0.30, h * 0.78)
      ..lineTo(w * 0.70, h * 0.78)
      ..lineTo(w * 0.62, h * 0.44)
      ..close();
    canvas.drawPath(body, fp);
    canvas.drawPath(body, p);
    // Head
    canvas.drawCircle(Offset(w * 0.50, h * 0.24), h * 0.16, fp);
    canvas.drawCircle(Offset(w * 0.50, h * 0.24), h * 0.16, p);
    // Arms raised outward
    canvas.drawLine(Offset(w * 0.38, h * 0.50), Offset(w * 0.14, h * 0.36), p);
    canvas.drawLine(Offset(w * 0.62, h * 0.50), Offset(w * 0.86, h * 0.36), p);
  }
  @override bool shouldRepaint(_IdolPainter o) => o.c != c;
}

// -- Cross: ornate cross with flared ends ────────────────────────────────────
class _CrossPainter extends CustomPainter {
  const _CrossPainter(this.c);
  final Color c;
  @override
  void paint(Canvas canvas, Size s) {
    final fill = Paint()..color = c.withValues(alpha: 0.20)..style = PaintingStyle.fill;
    final stroke = Paint()..color = c..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.07..strokeJoin = StrokeJoin.miter;
    final w = s.width, h = s.height;
    // Cross body
    final path = Path()
      // Vertical beam
      ..moveTo(w * 0.38, h * 0.06)
      ..lineTo(w * 0.62, h * 0.06)
      ..lineTo(w * 0.62, h * 0.36)
      // Right arm
      ..lineTo(w * 0.92, h * 0.36)
      ..lineTo(w * 0.92, h * 0.54)
      ..lineTo(w * 0.62, h * 0.54)
      // Continue down
      ..lineTo(w * 0.62, h * 0.94)
      ..lineTo(w * 0.38, h * 0.94)
      ..lineTo(w * 0.38, h * 0.54)
      // Left arm
      ..lineTo(w * 0.08, h * 0.54)
      ..lineTo(w * 0.08, h * 0.36)
      ..lineTo(w * 0.38, h * 0.36)
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }
  @override bool shouldRepaint(_CrossPainter o) => o.c != c;
}

// -- Book: open book with spine and lines ────────────────────────────────────
class _BookPainter extends CustomPainter {
  const _BookPainter(this.c);
  final Color c;
  @override
  void paint(Canvas canvas, Size s) {
    final fill = Paint()..color = c.withValues(alpha: 0.18)..style = PaintingStyle.fill;
    final stroke = Paint()..color = c..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final w = s.width, h = s.height;
    // Cover
    final cover = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.06, h * 0.08, w * 0.94, h * 0.92),
      Radius.circular(w * 0.06),
    );
    canvas.drawRRect(cover, fill);
    stroke.strokeWidth = s.width * 0.08;
    canvas.drawRRect(cover, stroke);
    // Spine
    stroke.strokeWidth = s.width * 0.06;
    canvas.drawLine(Offset(w * 0.44, h * 0.08), Offset(w * 0.44, h * 0.92), stroke);
    // Page lines (right half)
    stroke.strokeWidth = s.width * 0.055;
    stroke.color = c.withValues(alpha: 0.70);
    for (var i = 0; i < 4; i++) {
      final y = h * (0.26 + i * 0.15);
      canvas.drawLine(Offset(w * 0.52, y), Offset(w * 0.86, y), stroke);
    }
    // Clasp
    stroke.color = c;
    stroke.strokeWidth = s.width * 0.09;
    canvas.drawLine(Offset(w * 0.44, h * 0.50), Offset(w * 0.58, h * 0.50), stroke);
  }
  @override bool shouldRepaint(_BookPainter o) => o.c != c;
}

// -- Sword: blade with crossguard and pommel ─────────────────────────────────
class _SwordPainter extends CustomPainter {
  const _SwordPainter(this.c);
  final Color c;
  @override
  void paint(Canvas canvas, Size s) {
    final fill = Paint()..color = c.withValues(alpha: 0.20)..style = PaintingStyle.fill;
    final stroke = Paint()..color = c..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
    final w = s.width, h = s.height;
    // Blade
    final blade = Path()
      ..moveTo(w * 0.50, h * 0.04)
      ..lineTo(w * 0.60, h * 0.60)
      ..lineTo(w * 0.40, h * 0.60)
      ..close();
    canvas.drawPath(blade, fill);
    stroke.strokeWidth = s.width * 0.07;
    canvas.drawPath(blade, stroke);
    // Center ridge
    stroke.strokeWidth = s.width * 0.05;
    stroke.color = c.withValues(alpha: 0.50);
    canvas.drawLine(Offset(w * 0.50, h * 0.08), Offset(w * 0.50, h * 0.58), stroke);
    // Crossguard
    stroke.color = c;
    stroke.strokeWidth = s.width * 0.13;
    canvas.drawLine(Offset(w * 0.20, h * 0.62), Offset(w * 0.80, h * 0.62), stroke);
    // Grip
    stroke.strokeWidth = s.width * 0.10;
    canvas.drawLine(Offset(w * 0.50, h * 0.66), Offset(w * 0.50, h * 0.86), stroke);
    // Pommel
    canvas.drawCircle(Offset(w * 0.50, h * 0.90), h * 0.06, fill);
    stroke.strokeWidth = s.width * 0.08;
    canvas.drawCircle(Offset(w * 0.50, h * 0.90), h * 0.06, stroke);
  }
  @override bool shouldRepaint(_SwordPainter o) => o.c != c;
}

// -- Gemstone: faceted octagon with inner lines ───────────────────────────────
class _GemstonePainter extends CustomPainter {
  const _GemstonePainter(this.c);
  final Color c;
  @override
  void paint(Canvas canvas, Size s) {
    final fill   = Paint()..color = c.withValues(alpha: 0.22)..style = PaintingStyle.fill;
    final stroke = Paint()..color = c..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round..strokeWidth = s.width * 0.08;
    final dim = Paint()..color = c.withValues(alpha: 0.50)..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.045;
    final w = s.width, h = s.height;
    // Octagon
    final gem = Path()
      ..moveTo(w * 0.35, h * 0.05)
      ..lineTo(w * 0.65, h * 0.05)
      ..lineTo(w * 0.95, h * 0.35)
      ..lineTo(w * 0.95, h * 0.65)
      ..lineTo(w * 0.65, h * 0.95)
      ..lineTo(w * 0.35, h * 0.95)
      ..lineTo(w * 0.05, h * 0.65)
      ..lineTo(w * 0.05, h * 0.35)
      ..close();
    canvas.drawPath(gem, fill);
    canvas.drawPath(gem, stroke);
    // Table (inner flat top face)
    final table = Path()
      ..moveTo(w * 0.40, h * 0.22)
      ..lineTo(w * 0.60, h * 0.22)
      ..lineTo(w * 0.78, h * 0.40)
      ..lineTo(w * 0.78, h * 0.60)
      ..lineTo(w * 0.60, h * 0.78)
      ..lineTo(w * 0.40, h * 0.78)
      ..lineTo(w * 0.22, h * 0.60)
      ..lineTo(w * 0.22, h * 0.40)
      ..close();
    canvas.drawPath(table, dim);
    // Facet lines from corners to table
    for (final p in [
      [Offset(w * 0.35, h * 0.05), Offset(w * 0.40, h * 0.22)],
      [Offset(w * 0.65, h * 0.05), Offset(w * 0.60, h * 0.22)],
      [Offset(w * 0.95, h * 0.35), Offset(w * 0.78, h * 0.40)],
      [Offset(w * 0.95, h * 0.65), Offset(w * 0.78, h * 0.60)],
    ]) {
      canvas.drawLine(p[0], p[1], dim);
    }
  }
  @override bool shouldRepaint(_GemstonePainter o) => o.c != c;
}

// -- Charm: four-pointed star with center circle ──────────────────────────────
class _CharmPainter extends CustomPainter {
  const _CharmPainter(this.c);
  final Color c;
  @override
  void paint(Canvas canvas, Size s) {
    final fill   = Paint()..color = c.withValues(alpha: 0.22)..style = PaintingStyle.fill;
    final stroke = Paint()..color = c..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round..strokeWidth = s.width * 0.07;
    final w = s.width, h = s.height;
    // Four-pointed star
    final star = Path()
      ..moveTo(w * 0.50, h * 0.04)
      ..lineTo(w * 0.60, h * 0.40)
      ..lineTo(w * 0.96, h * 0.50)
      ..lineTo(w * 0.60, h * 0.60)
      ..lineTo(w * 0.50, h * 0.96)
      ..lineTo(w * 0.40, h * 0.60)
      ..lineTo(w * 0.04, h * 0.50)
      ..lineTo(w * 0.40, h * 0.40)
      ..close();
    canvas.drawPath(star, fill);
    canvas.drawPath(star, stroke);
    // Center circle
    canvas.drawCircle(Offset(w * 0.50, h * 0.50), h * 0.10, fill);
    stroke.strokeWidth = s.width * 0.08;
    canvas.drawCircle(Offset(w * 0.50, h * 0.50), h * 0.10, stroke);
    // Small corner diamonds
    final dimP = Paint()..color = c.withValues(alpha: 0.50)..style = PaintingStyle.fill;
    for (final pos in [
      Offset(w * 0.50, h * 0.19),
      Offset(w * 0.81, h * 0.50),
      Offset(w * 0.50, h * 0.81),
      Offset(w * 0.19, h * 0.50),
    ]) {
      canvas.drawCircle(pos, h * 0.04, dimP);
    }
  }
  @override bool shouldRepaint(_CharmPainter o) => o.c != c;
}

// -- Tapestry: hanging banner with rod and tassels ────────────────────────────
class _TapestryPainter extends CustomPainter {
  const _TapestryPainter(this.c);
  final Color c;
  @override
  void paint(Canvas canvas, Size s) {
    final fill   = Paint()..color = c.withValues(alpha: 0.18)..style = PaintingStyle.fill;
    final stroke = Paint()..color = c..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final dim    = Paint()..color = c.withValues(alpha: 0.55)..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round..strokeWidth = s.width * 0.055;
    final w = s.width, h = s.height;
    // Banner body
    final banner = Rect.fromLTRB(w * 0.18, h * 0.12, w * 0.82, h * 0.80);
    canvas.drawRect(banner, fill);
    stroke.strokeWidth = s.width * 0.07;
    canvas.drawRect(banner, stroke);
    // Hanging rod across top
    stroke.strokeWidth = s.width * 0.12;
    canvas.drawLine(Offset(w * 0.10, h * 0.12), Offset(w * 0.90, h * 0.12), stroke);
    // Small knobs on rod ends
    stroke.strokeWidth = s.width * 0.08;
    canvas.drawCircle(Offset(w * 0.10, h * 0.12), h * 0.04, stroke);
    canvas.drawCircle(Offset(w * 0.90, h * 0.12), h * 0.04, stroke);
    // Decorative horizontal pattern lines
    for (var i = 0; i < 3; i++) {
      final y = h * (0.26 + i * 0.16);
      canvas.drawLine(Offset(w * 0.24, y), Offset(w * 0.76, y), dim);
    }
    // Diamond pattern in center
    dim.strokeWidth = s.width * 0.045;
    final cx = w * 0.50, cy = h * 0.53, r = w * 0.10;
    final diamond = Path()
      ..moveTo(cx, cy - r)
      ..lineTo(cx + r, cy)
      ..lineTo(cx, cy + r)
      ..lineTo(cx - r, cy)
      ..close();
    canvas.drawPath(diamond, dim);
    // Tassels at bottom
    stroke.strokeWidth = s.width * 0.065;
    for (var i = 0; i < 5; i++) {
      final x = w * (0.25 + i * 0.125);
      canvas.drawLine(Offset(x, h * 0.80), Offset(x, h * 0.94), stroke);
      canvas.drawCircle(Offset(x, h * 0.94), h * 0.025, stroke);
    }
  }
  @override bool shouldRepaint(_TapestryPainter o) => o.c != c;
}
