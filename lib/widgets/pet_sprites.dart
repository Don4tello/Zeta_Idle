import 'package:flutter/material.dart';

/// Returns a [CustomPainter] for the given pet [id], or null (falls back to emoji).
CustomPainter? petPainterFor(String id) => switch (id) {
  'iron_boar'     => const _IronBoarPainter(),
  'lute_sparrow'  => const _LuteSparrowPainter(),
  'sacred_dove'   => const _SacredDovePainter(),
  'forest_wolf'   => const _ForestWolfPainter(),
  'battle_hound'  => const _BattleHoundPainter(),
  'stone_turtle'  => const _StoneTurtlePainter(),
  'holy_lamb'     => const _HolyLambPainter(),
  'shadow_hawk'   => const _ShadowHawkPainter(),
  'night_cat'     => const _NightCatPainter(),
  'arcane_ferret' => const _ArcaneFerrretPainter(),
  'imp_familiar'  => const _ImpFamiliarPainter(),
  'arcane_owl'    => const _ArcaneOwlPainter(),
  _               => null,
};

Size petSizeFor(String id) => switch (id) {
  'stone_turtle' || 'arcane_ferret'                                => const Size(60, 35),
  'lute_sparrow' || 'sacred_dove' || 'shadow_hawk' ||
  'imp_familiar' || 'arcane_owl'                                   => const Size(60, 50),
  _                                                                => const Size(55, 45),
};

// ── Base ──────────────────────────────────────────────────────────────────────
abstract class _PetPainter extends CustomPainter {
  const _PetPainter();
  static const double s = 5.0;

  void draw(Canvas c, Size sz);

  @override
  void paint(Canvas c, Size sz) => draw(c, sz);

  @override
  bool shouldRepaint(_PetPainter old) => false;

  void b(Canvas c, double x, double y, double w, double h, int rgba) =>
      c.drawRect(Rect.fromLTWH(x * s, y * s, w * s, h * s),
          Paint()..color = Color(rgba));
}

// ── IRON BOAR ── (Barbarian · 11×9 grid · 55×45) front-facing
// Wide squat pig-boar, amber-brown with ivory tusks and red eyes
class _IronBoarPainter extends _PetPainter {
  const _IronBoarPainter();
  @override
  void draw(Canvas c, Size sz) {
    const BD = 0xFF5C2F10; // body dark
    const BM = 0xFF8B4513; // body mid
    const BL = 0xFFA05C38; // body lighter
    const SN = 0xFFCC9977; // snout
    const TK = 0xFFE0DCC0; // tusk ivory
    const EY = 0xFFCC2222; // red eye
    const HF = 0xFF2A1108; // hoof

    // Ears
    b(c, 1, 0, 2, 2, BM);
    b(c, 8, 0, 2, 2, BM);
    // Tusk tips
    b(c, 2, 1, 1, 2, TK);
    b(c, 8, 1, 1, 2, TK);
    // Head block
    b(c, 2, 1, 7, 4, BD);
    b(c, 1, 2, 9, 3, BM);
    // Eyes
    b(c, 3, 2, 2, 1, EY);
    b(c, 6, 2, 2, 1, EY);
    // Snout
    b(c, 4, 4, 3, 2, SN);
    b(c, 4, 5, 3, 1, BD); // nostril line
    // Tusks curve outward and up
    b(c, 1, 3, 2, 2, TK);
    b(c, 8, 3, 2, 2, TK);
    // Body
    b(c, 1, 5, 9, 3, BD);
    b(c, 2, 5, 7, 2, BM);
    b(c, 3, 6, 5, 2, BL); // belly
    // Bristle ridge
    b(c, 3, 5, 1, 1, BD);
    b(c, 5, 5, 1, 1, BD);
    b(c, 7, 5, 1, 1, BD);
    // Legs
    b(c, 2, 7, 2, 2, BD);
    b(c, 7, 7, 2, 2, BD);
    // Hooves
    b(c, 2, 8, 2, 1, HF);
    b(c, 7, 8, 2, 1, HF);
  }
}

// ── LUTE SPARROW ── (Bard · 12×10 grid · 60×50) flying, front-facing
// Bright golden songbird, wings fully spread, cheerful
class _LuteSparrowPainter extends _PetPainter {
  const _LuteSparrowPainter();
  @override
  void draw(Canvas c, Size sz) {
    const YB = 0xFFF5C030; // golden yellow body
    const YD = 0xFFD49010; // dark gold
    const OR = 0xFFE07020; // orange wing tips
    const WH = 0xFFFFFFEE; // white breast
    const BK = 0xFF221100; // beak
    const EY = 0xFF111111; // eye
    const FT = 0xFFAA7733; // feet/legs

    // Left wing spread
    b(c, 0, 2, 3, 5, OR);
    b(c, 0, 2, 3, 3, YD);
    b(c, 1, 0, 2, 3, OR);
    // Right wing spread
    b(c, 9, 2, 3, 5, OR);
    b(c, 9, 2, 3, 3, YD);
    b(c, 9, 0, 2, 3, OR);
    // Central body
    b(c, 3, 2, 6, 6, YB);
    b(c, 4, 2, 4, 2, YD); // back
    b(c, 4, 6, 4, 2, WH); // white belly
    // Head
    b(c, 4, 0, 4, 3, YB);
    b(c, 4, 0, 4, 1, YD); // crown
    // Beak
    b(c, 5, 3, 2, 1, BK);
    b(c, 5, 4, 2, 1, BK);
    b(c, 6, 2, 1, 2, BK); // upper beak ridge
    // Eyes
    b(c, 4, 1, 2, 1, EY);
    b(c, 8, 1, 2, 1, EY);
    // Tail feathers (center bottom)
    b(c, 4, 8, 4, 1, YD);
    b(c, 3, 9, 6, 1, OR);
    // Feet
    b(c, 5, 8, 1, 2, FT);
    b(c, 7, 8, 1, 2, FT);
  }
}

// ── SACRED DOVE ── (Cleric · 12×10 grid · 60×50) flying, front-facing
// Pure white dove with golden halo; symbol of divine healing
class _SacredDovePainter extends _PetPainter {
  const _SacredDovePainter();
  @override
  void draw(Canvas c, Size sz) {
    const WH = 0xFFFFFFFF; // pure white
    const CR = 0xFFEEEEEE; // cream
    const GL = 0xFFFFDD44; // gold halo
    const BK = 0xFFFF9944; // orange beak
    const EY = 0xFF220044; // dark eye
    const BL = 0xFFCCE8FF; // pale blue wing sheen
    const FT = 0xFFFFAA55; // orange feet

    // Halo (above head)
    b(c, 4, 0, 4, 1, GL);
    b(c, 3, 0, 1, 1, GL);
    b(c, 8, 0, 1, 1, GL);
    // Wings spread wide
    b(c, 0, 1, 4, 6, WH);
    b(c, 0, 1, 3, 4, BL);   // blue sheen inner
    b(c, 8, 1, 4, 6, WH);
    b(c, 9, 1, 3, 4, BL);
    b(c, 0, 0, 2, 3, CR);   // left tip
    b(c, 10, 0, 2, 3, CR);  // right tip
    // Body
    b(c, 3, 2, 6, 6, WH);
    b(c, 4, 4, 4, 4, CR);   // breast/belly
    // Head
    b(c, 4, 0, 4, 3, WH);
    // Beak
    b(c, 5, 3, 2, 1, BK);
    b(c, 6, 2, 1, 2, BK);
    // Eyes
    b(c, 4, 1, 2, 1, EY);
    b(c, 8, 1, 2, 1, EY);
    // Tail
    b(c, 4, 8, 4, 2, CR);
    b(c, 3, 9, 6, 1, WH);
    // Feet
    b(c, 5, 8, 1, 2, FT);
    b(c, 7, 8, 1, 2, FT);
  }
}

// ── FOREST WOLF ── (Druid · 11×9 grid · 55×45) front-facing
// Lean silver-grey wolf with amber eyes and green-tipped fur
class _ForestWolfPainter extends _PetPainter {
  const _ForestWolfPainter();
  @override
  void draw(Canvas c, Size sz) {
    const GR = 0xFF9098A8; // grey main
    const GD = 0xFF606878; // grey dark
    const GL = 0xFFB8C0CC; // grey light
    const WH = 0xFFEEEEDD; // white muzzle
    const AM = 0xFFDDA820; // amber eyes
    const GN = 0xFF447744; // green ear tips
    const NK = 0xFF282830; // nose/pupil

    // Ears (pointed)
    b(c, 2, 0, 2, 2, GR);
    b(c, 2, 0, 1, 1, GN);   // green tip left
    b(c, 7, 0, 2, 2, GR);
    b(c, 8, 0, 1, 1, GN);   // green tip right
    // Head
    b(c, 2, 1, 7, 4, GR);
    b(c, 1, 2, 9, 3, GD);   // side shadows
    b(c, 2, 2, 7, 3, GR);   // head main
    b(c, 3, 1, 5, 2, GL);   // top lighter
    // Muzzle
    b(c, 4, 4, 3, 2, WH);
    b(c, 5, 5, 1, 1, NK);   // nose
    // Eyes
    b(c, 3, 2, 2, 1, AM);
    b(c, 6, 2, 2, 1, AM);
    b(c, 3, 2, 1, 1, NK);   // pupil
    b(c, 7, 2, 1, 1, NK);
    // Chest / neck
    b(c, 3, 5, 5, 2, GR);
    b(c, 4, 5, 3, 2, WH);   // white chest
    // Body
    b(c, 2, 6, 7, 2, GD);
    b(c, 3, 6, 5, 2, GR);
    // Legs
    b(c, 2, 7, 2, 2, GD);
    b(c, 7, 7, 2, 2, GD);
    b(c, 2, 8, 2, 1, NK);   // paws
    b(c, 7, 8, 2, 1, NK);
  }
}

// ── BATTLE HOUND ── (Fighter · 11×9 grid · 55×45) front-facing
// Loyal war-dog, tawny brown with floppy ears and sturdy build
class _BattleHoundPainter extends _PetPainter {
  const _BattleHoundPainter();
  @override
  void draw(Canvas c, Size sz) {
    const TN = 0xFFCC9944; // tawny
    const TD = 0xFF996622; // dark tawny
    const TL = 0xFFEEBB77; // light tawny
    const WH = 0xFFFFEEDD; // cream muzzle/chest
    const EY = 0xFF553311; // dark brown eyes
    const NK = 0xFF221100; // nose/paw pads

    // Floppy ears (wide, hanging)
    b(c, 0, 1, 3, 5, TD);
    b(c, 8, 1, 3, 5, TD);
    b(c, 0, 2, 2, 4, TN);  // inner ear
    b(c, 9, 2, 2, 4, TN);
    // Head
    b(c, 2, 1, 7, 4, TN);
    b(c, 3, 1, 5, 1, TL);  // top lighter
    b(c, 2, 2, 7, 2, TN);
    // Muzzle (wide and friendly)
    b(c, 3, 4, 5, 2, WH);
    b(c, 4, 5, 3, 1, NK);  // mouth line
    b(c, 5, 4, 1, 1, NK);  // nose
    // Eyes
    b(c, 3, 2, 2, 1, EY);
    b(c, 6, 2, 2, 1, EY);
    // Neck / collar area
    b(c, 3, 5, 5, 2, TN);
    b(c, 4, 6, 3, 1, 0xFFAA3311); // red collar accent
    // Body
    b(c, 2, 6, 7, 2, TD);
    b(c, 3, 6, 5, 2, TN);
    b(c, 4, 7, 3, 1, WH);  // belly
    // Legs
    b(c, 2, 7, 2, 2, TD);
    b(c, 7, 7, 2, 2, TD);
    b(c, 2, 8, 2, 1, NK);
    b(c, 7, 8, 2, 1, NK);
  }
}

// ── STONE TURTLE ── (Monk · 12×7 grid · 60×35) front-facing, very squat
// Wide armored shell dominant; tiny calm head peeks from centre
class _StoneTurtlePainter extends _PetPainter {
  const _StoneTurtlePainter();
  @override
  void draw(Canvas c, Size sz) {
    const SH = 0xFF3D6B3D; // shell dark green
    const SM = 0xFF5B9B5B; // shell mid
    const SL = 0xFF7DCC7D; // shell light
    const SK = 0xFF8BA87A; // shell khaki
    const GR = 0xFF6B9B6B; // grey-green scutes
    const HE = 0xFF8B7B5B; // head/skin
    const EY = 0xFFDDA820; // golden eyes
    const NK = 0xFF221100; // pupil

    // Shell — wide rounded hexagonal
    b(c, 1, 1, 10, 5, SH);
    b(c, 0, 2, 12, 4, SM);
    b(c, 1, 1, 10, 1, SL);   // top highlight
    // Shell scute pattern
    b(c, 3, 2, 2, 2, GR);
    b(c, 5, 1, 2, 2, SK);
    b(c, 7, 2, 2, 2, GR);
    b(c, 2, 3, 2, 2, SK);
    b(c, 6, 3, 2, 2, SK);
    b(c, 4, 2, 4, 3, SM);    // central scute
    b(c, 5, 2, 2, 3, SL);    // central highlight
    // Head (tiny, peeks from top centre)
    b(c, 5, 0, 2, 2, HE);
    b(c, 5, 1, 1, 1, EY);    // left eye
    b(c, 6, 1, 1, 1, EY);    // right eye
    b(c, 5, 1, 1, 1, NK);    // pupil left
    // Feet peeking under shell
    b(c, 0, 4, 2, 2, HE);    // front left
    b(c, 10, 4, 2, 2, HE);   // front right
    b(c, 1, 5, 2, 2, HE);    // rear left
    b(c, 9, 5, 2, 2, HE);    // rear right
    // Tail nub
    b(c, 6, 5, 1, 2, HE);
  }
}

// ── HOLY LAMB ── (Paladin · 11×9 grid · 55×45) front-facing
// Fluffy white lamb with golden horns and gentle blue eyes
class _HolyLambPainter extends _PetPainter {
  const _HolyLambPainter();
  @override
  void draw(Canvas c, Size sz) {
    const WH = 0xFFFFFFFF; // wool white
    const CR = 0xFFEEEEDD; // cream/fleece
    const WD = 0xFFDDDDCC; // wool shadow
    const PK = 0xFFFFBBAA; // pink face/ears
    const GL = 0xFFFFCC22; // gold horns
    const EY = 0xFF3366CC; // gentle blue eyes
    const NK = 0xFF221100; // pupil

    // Wool body (fluffy puffs — many overlapping blocks)
    b(c, 1, 3, 9, 5, WH);
    b(c, 0, 4, 11, 4, CR);
    b(c, 2, 2, 7, 2, WH);   // top wool
    b(c, 1, 5, 2, 3, WD);   // left shadow
    b(c, 8, 5, 2, 3, WD);   // right shadow
    b(c, 3, 6, 5, 2, WH);   // central belly fluff
    // Fluffy ear bumps
    b(c, 0, 2, 2, 3, WH);
    b(c, 9, 2, 2, 3, WH);
    // Pink face
    b(c, 4, 2, 3, 3, PK);
    b(c, 3, 3, 5, 2, PK);
    // Golden horns (tiny, curling)
    b(c, 3, 1, 1, 2, GL);
    b(c, 4, 0, 1, 2, GL);
    b(c, 7, 1, 1, 2, GL);
    b(c, 7, 0, 1, 2, GL);
    // Eyes
    b(c, 4, 3, 1, 1, EY);
    b(c, 6, 3, 1, 1, EY);
    b(c, 4, 3, 1, 1, NK);   // pupil
    b(c, 6, 3, 1, 1, NK);
    // Tiny nose
    b(c, 5, 4, 1, 1, PK);
    // Spindly legs
    b(c, 3, 7, 1, 2, WD);
    b(c, 7, 7, 1, 2, WD);
    b(c, 2, 8, 2, 1, PK);   // hooves
    b(c, 7, 8, 2, 1, PK);
  }
}

// ── SHADOW HAWK ── (Ranger · 12×10 grid · 60×50) flying, front-facing
// Dark raptor with white head, fierce yellow talons and amber eyes
class _ShadowHawkPainter extends _PetPainter {
  const _ShadowHawkPainter();
  @override
  void draw(Canvas c, Size sz) {
    const DK = 0xFF2A3040; // dark body feathers
    const MN = 0xFF3A4458; // mid feather
    const WH = 0xFFEEEEDD; // white head
    const YL = 0xFFEEAA00; // yellow beak/talons
    const EY = 0xFFDD6600; // amber eye
    const NK = 0xFF111118; // pupil

    // Wings spread (dark, angular)
    b(c, 0, 1, 4, 5, DK);
    b(c, 0, 1, 3, 3, MN);   // inner left
    b(c, 0, 0, 2, 2, DK);   // left tip
    b(c, 8, 1, 4, 5, DK);
    b(c, 9, 1, 3, 3, MN);   // inner right
    b(c, 10, 0, 2, 2, DK);  // right tip
    // Wing feather streaks
    b(c, 1, 3, 3, 1, MN);
    b(c, 8, 3, 3, 1, MN);
    // Body
    b(c, 3, 2, 6, 7, DK);
    b(c, 4, 3, 4, 5, MN);
    // White head
    b(c, 4, 0, 4, 4, WH);
    b(c, 3, 1, 6, 3, WH);
    // Hooked beak
    b(c, 5, 3, 2, 1, YL);
    b(c, 6, 4, 2, 1, YL);   // hook
    // Eyes (fierce)
    b(c, 4, 1, 2, 2, EY);
    b(c, 8, 1, 2, 2, EY);
    b(c, 5, 2, 1, 1, NK);
    b(c, 9, 2, 1, 1, NK);
    // Tail feathers
    b(c, 4, 8, 4, 1, DK);
    b(c, 3, 9, 6, 1, MN);
    // Talons
    b(c, 4, 7, 1, 2, YL);
    b(c, 7, 7, 1, 2, YL);
    b(c, 3, 8, 1, 1, YL);   // spread talon
    b(c, 8, 8, 1, 1, YL);
  }
}

// ── NIGHT CAT ── (Rogue · 11×9 grid · 55×45) front-facing, crouched
// Sleek black cat with glowing violet eyes; low to the ground
class _NightCatPainter extends _PetPainter {
  const _NightCatPainter();
  @override
  void draw(Canvas c, Size sz) {
    const BK = 0xFF141420; // main black
    const BD = 0xFF222236; // body lighter
    const PR = 0xFFAA44FF; // purple glow
    const PL = 0xFFCC88FF; // glow highlight
    const WH = 0xFFFFFFEE; // white whiskers/chin
    const NK = 0xFF080810; // nose

    // Tail arcing over (rear-left to overhead-right)
    b(c, 0, 4, 1, 4, BK);
    b(c, 1, 3, 1, 2, BK);
    b(c, 2, 2, 1, 2, BK);
    b(c, 3, 1, 2, 2, BK);
    b(c, 5, 0, 3, 1, BK);
    b(c, 8, 1, 2, 2, BK);
    // Pointed ears
    b(c, 2, 0, 2, 2, BK);
    b(c, 7, 0, 2, 2, BK);
    // Head (wider than neck)
    b(c, 2, 1, 7, 4, BK);
    b(c, 3, 1, 5, 3, BD);
    // Glowing eyes
    b(c, 3, 2, 2, 1, PR);
    b(c, 6, 2, 2, 1, PR);
    b(c, 3, 2, 1, 1, PL);   // glow centre
    b(c, 7, 2, 1, 1, PL);
    // Muzzle + whiskers
    b(c, 4, 4, 3, 1, WH);
    b(c, 1, 3, 2, 1, WH);   // whisker left
    b(c, 8, 3, 2, 1, WH);   // whisker right
    b(c, 5, 5, 1, 1, NK);   // nose
    // Body (crouched, low)
    b(c, 1, 5, 9, 3, BK);
    b(c, 2, 5, 7, 2, BD);
    b(c, 3, 6, 5, 2, WH);   // belly
    // Paws
    b(c, 2, 7, 2, 2, BK);
    b(c, 7, 7, 2, 2, BK);
    b(c, 2, 8, 3, 1, BD);
    b(c, 6, 8, 3, 1, BD);
  }
}

// ── ARCANE FERRET ── (Sorcerer · 12×7 grid · 60×35) front-ish, long and low
// Long-bodied purple ferret with electric blue eyes and arcane sparks
class _ArcaneFerrretPainter extends _PetPainter {
  const _ArcaneFerrretPainter();
  @override
  void draw(Canvas c, Size sz) {
    const PR = 0xFF7B2FBE; // purple body
    const PM = 0xFF9B4FDE; // purple mid
    const PL = 0xFFBB77FF; // purple light
    const CR = 0xFFDDCCEE; // cream belly/muzzle
    const EY = 0xFF00EEFF; // electric blue eyes
    const NK = 0xFF001122; // pupil
    const SP = 0xFFDDAAFF; // arcane spark

    // Tail (right side, long and bushy)
    b(c, 9, 1, 3, 3, PR);
    b(c, 10, 0, 2, 2, PM);  // tail tip
    b(c, 9, 2, 3, 2, PM);
    // Body — long and sinuous
    b(c, 2, 2, 10, 4, PR);
    b(c, 3, 1, 8, 4, PM);
    b(c, 4, 2, 6, 3, PL);   // dorsal lighter
    b(c, 3, 4, 7, 2, CR);   // cream belly strip
    // Head (left side)
    b(c, 0, 1, 4, 5, PR);
    b(c, 0, 2, 4, 3, PM);
    b(c, 1, 3, 3, 2, CR);   // muzzle
    // Eyes
    b(c, 1, 2, 2, 1, EY);
    b(c, 1, 2, 1, 1, NK);   // pupil
    b(c, 2, 2, 1, 1, NK);
    // Nose
    b(c, 0, 3, 1, 1, NK);
    // Legs (4 tiny legs)
    b(c, 2, 5, 2, 2, PR);
    b(c, 5, 5, 2, 2, PR);
    b(c, 8, 5, 2, 2, PR);
    b(c, 2, 6, 2, 1, NK);
    b(c, 5, 6, 2, 1, NK);
    b(c, 8, 6, 2, 1, NK);
    // Arcane sparks floating around
    b(c, 0, 0, 1, 1, SP);
    b(c, 11, 0, 1, 1, SP);
    b(c, 11, 5, 1, 1, SP);
  }
}

// ── IMP FAMILIAR ── (Warlock · 12×10 grid · 60×50) flying, front-facing
// Bat companion with membrane wings, glowing red eyes, dark purple
class _ImpFamiliarPainter extends _PetPainter {
  const _ImpFamiliarPainter();
  @override
  void draw(Canvas c, Size sz) {
    const DK = 0xFF1A0830; // very dark purple
    const PM = 0xFF3D1460; // purple mid
    const PL = 0xFF6B3099; // purple lighter
    const MB = 0xFF2A1050; // membrane
    const EY = 0xFFFF3333; // red eyes
    const PK = 0xFF110022; // pupil

    // Left wing membrane (thin, stretched)
    b(c, 0, 1, 4, 7, MB);
    b(c, 0, 3, 5, 5, DK);   // wing darker toward body
    b(c, 0, 1, 2, 3, PM);   // outer tip
    // Right wing
    b(c, 8, 1, 4, 7, MB);
    b(c, 7, 3, 5, 5, DK);
    b(c, 10, 1, 2, 3, PM);  // outer tip
    // Wing ribs
    b(c, 1, 2, 1, 5, DK);
    b(c, 3, 3, 1, 5, DK);
    b(c, 10, 2, 1, 5, DK);
    b(c, 8, 3, 1, 5, DK);
    // Body (plump centre)
    b(c, 4, 2, 4, 7, PM);
    b(c, 4, 2, 4, 1, PL);   // top lighter
    b(c, 5, 3, 2, 5, PL);   // belly highlight
    // Head (rounded)
    b(c, 4, 1, 4, 4, PL);
    b(c, 3, 2, 6, 3, PM);
    // Large red eyes
    b(c, 4, 2, 2, 2, EY);
    b(c, 8, 2, 2, 2, EY);
    b(c, 4, 2, 1, 1, PK);   // pupils
    b(c, 9, 2, 1, 1, PK);
    // Ears (pointed)
    b(c, 3, 0, 2, 2, DK);
    b(c, 9, 0, 2, 2, DK);
    // Fangs
    b(c, 5, 5, 1, 1, 0xFFDDCCEE);
    b(c, 7, 5, 1, 1, 0xFFDDCCEE);
    // Feet/claws at bottom
    b(c, 4, 8, 2, 2, DK);
    b(c, 8, 8, 2, 2, DK);
    b(c, 3, 9, 1, 1, DK);
    b(c, 9, 9, 1, 1, DK);
  }
}

// ── ARCANE OWL ── (Wizard · 12×10 grid · 60×50) flying, front-facing
// Round wise owl with massive glowing eyes, half-spread wings, blue-purple
class _ArcaneOwlPainter extends _PetPainter {
  const _ArcaneOwlPainter();
  @override
  void draw(Canvas c, Size sz) {
    const NV = 0xFF1A2060; // navy feathers
    const NM = 0xFF2A3898; // navy mid
    const NL = 0xFF4A58CC; // navy lighter
    const CR = 0xFFDDCC88; // cream face disk
    const GL = 0xFFFFCC22; // golden eyes
    const EY = 0xFFFFAA00; // eye amber
    const NK = 0xFF1A0800; // pupil
    const WH = 0xFFEEEEDD; // belly stripe
    const BK = 0xFFBB8800; // beak

    // Wings (half spread, compact)
    b(c, 0, 2, 3, 6, NV);
    b(c, 1, 3, 3, 5, NM);   // inner left wing
    b(c, 9, 2, 3, 6, NV);
    b(c, 8, 3, 3, 5, NM);   // inner right wing
    // Ear tufts
    b(c, 3, 0, 2, 2, NV);
    b(c, 8, 0, 2, 2, NV);
    // Body (very round)
    b(c, 2, 1, 8, 8, NV);
    b(c, 3, 1, 6, 7, NM);
    b(c, 4, 2, 4, 6, NL);   // lighter centre
    // Cream belly stripe
    b(c, 5, 4, 2, 4, WH);
    // Facial disk (cream circle)
    b(c, 3, 2, 6, 5, CR);
    b(c, 4, 2, 4, 5, CR);
    // Large eyes (iconic)
    b(c, 3, 3, 3, 3, EY);
    b(c, 7, 3, 3, 3, EY);
    b(c, 3, 3, 3, 2, GL);   // bright upper
    b(c, 7, 3, 3, 2, GL);
    b(c, 4, 4, 2, 2, NK);   // pupil left
    b(c, 7, 4, 2, 2, NK);   // pupil right
    b(c, 5, 4, 1, 1, GL);   // eye shine left
    b(c, 8, 4, 1, 1, GL);   // eye shine right
    // Beak (small hooked)
    b(c, 6, 6, 1, 1, BK);
    b(c, 5, 7, 2, 1, BK);
    // Feet/talons
    b(c, 4, 8, 1, 2, NV);
    b(c, 8, 8, 1, 2, NV);
    b(c, 3, 9, 2, 1, GL);   // talon colour
    b(c, 8, 9, 2, 1, GL);
  }
}
