import 'package:flutter/material.dart';
import '../models/world_zone.dart';

const kWorldZones = <WorldZone>[
  // ── Act I: The Cursed Realm (1–5) ──────────────────────────────────────────
  WorldZone(
    name: 'The Cursed Realm',
    flavor: 'Ancient burial grounds where the dead refuse to stay buried. '
        'Skeletons, shadow knights, and wraiths haunt every broken stone.',
    color: Color(0xFF7755cc),
    icon: '💀',
    firstStage: 1,
    lastStage: 5,
  ),
  // ── Act II: The Blighted Wilds (6–10) ──────────────────────────────────────
  WorldZone(
    name: 'The Blighted Wilds',
    flavor: 'A cursed forest bleeding into fetid swamps and icy mountain passes. '
        'Something ancient spins its web at the heart of this corrupted land.',
    color: Color(0xFF44aa66),
    icon: '🌲',
    firstStage: 6,
    lastStage: 10,
  ),
  // ── Act III: The Infernal Depths (11–15) ───────────────────────────────────
  WorldZone(
    name: 'The Infernal Depths',
    flavor: 'Rivers of molten rock carve through volcanic caverns. '
        'Infernal knights and draconic warlords rule the burning dark below.',
    color: Color(0xFFcc5522),
    icon: '🔥',
    firstStage: 11,
    lastStage: 15,
  ),
  // ── Act IV: The Void Expanse (16–20) ───────────────────────────────────────
  WorldZone(
    name: 'The Void Expanse',
    flavor: 'Reality frays at the edges here. Impossible structures float in a sky '
        'that should not exist, guarded by things that predate the world.',
    color: Color(0xFF5577cc),
    icon: '🌀',
    firstStage: 16,
    lastStage: 20,
  ),
  // ── Act V: Throne of Ruin (21–25) — Rebirth gate ───────────────────────────
  WorldZone(
    name: 'Throne of Ruin',
    flavor: 'The final fortress. Ancient evil concentrates into a singular point of '
        'darkness. Survive this, and you earn the right to begin again.',
    color: Color(0xFF993333),
    icon: '☠',
    firstStage: 21,
    lastStage: 25,
  ),
  // ── Act VI: The Crystal Sanctum (26–30) ────────────────────────────────────
  WorldZone(
    name: 'The Crystal Sanctum',
    flavor: 'A palace of living crystal hidden deep within the void. '
        'Constructs of pure arcane energy guard its endless prismatic halls.',
    color: Color(0xFF33bbcc),
    icon: '💎',
    firstStage: 26,
    lastStage: 30,
  ),
  // ── Act VII: The Shadow Realm (31–35) ──────────────────────────────────────
  WorldZone(
    name: 'The Shadow Realm',
    flavor: 'A dimension where shadows are solid and light is lethal. '
        'Shade-cursed traders and assassins drift through its twilight streets.',
    color: Color(0xFF8855bb),
    icon: '🌑',
    firstStage: 31,
    lastStage: 35,
  ),
  // ── Act VIII: The Frozen Wastes (36–40) ────────────────────────────────────
  WorldZone(
    name: 'The Frozen Wastes',
    flavor: 'A mountain range locked in supernatural winter. '
        'Ancient warriors sleep in glacial tombs, dreaming of one last battle.',
    color: Color(0xFF3399cc),
    icon: '❄',
    firstStage: 36,
    lastStage: 40,
  ),
  // ── Act IX: The Storm Heights (41–45) ──────────────────────────────────────
  WorldZone(
    name: 'The Storm Heights',
    flavor: 'Sky citadels borne on perpetual lightning storms. '
        'Aerial hunters and storm titans race across crackling skies.',
    color: Color(0xFFaacc22),
    icon: '⚡',
    firstStage: 41,
    lastStage: 45,
  ),
  // ── Act X: The Abyssal Ocean (46–50) ───────────────────────────────────────
  WorldZone(
    name: 'The Abyssal Ocean',
    flavor: 'A sunless sea where pressure crushes thought and ancient leviathans circle. '
        'Drowned cities remember the age before the curse began.',
    color: Color(0xFF2288bb),
    icon: '🌊',
    firstStage: 46,
    lastStage: 50,
  ),
  // ── Act XI: The Twilight Labyrinth (51–55) ─────────────────────────────────
  WorldZone(
    name: 'The Twilight Labyrinth',
    flavor: 'A maze between worlds where the walls shift and doors lead nowhere. '
        'Only those who hear the maze speaking survive its endless corridors.',
    color: Color(0xFF886622),
    icon: '🏛',
    firstStage: 51,
    lastStage: 55,
  ),
  // ── Act XII: The Forgotten Empire (56–60) ──────────────────────────────────
  WorldZone(
    name: 'The Forgotten Empire',
    flavor: 'A civilization of unimaginable power that erased itself from history. '
        'Its automated guardians wage war for a cause no one remembers.',
    color: Color(0xFF997722),
    icon: '⚙',
    firstStage: 56,
    lastStage: 60,
  ),
  // ── Act XIII: The Plaguelands (61–65) ──────────────────────────────────────
  WorldZone(
    name: 'The Plaguelands',
    flavor: 'A blighted continent consumed by a magical pestilence that corrupts flesh and soul alike. '
        'The infected hunger for death they can never reach.',
    color: Color(0xFF77aa33),
    icon: '☣',
    firstStage: 61,
    lastStage: 65,
  ),
  // ── Act XIV: The Celestial Ruins (66–70) ───────────────────────────────────
  WorldZone(
    name: 'The Celestial Ruins',
    flavor: 'The shattered remnants of heaven itself, fallen after a war of gods. '
        'Broken angels patrol crumbling halls where divine light still flickers.',
    color: Color(0xFFddcc44),
    icon: '✨',
    firstStage: 66,
    lastStage: 70,
  ),
  // ── Act XV: The Dark Matter (71–75) ────────────────────────────────────────
  WorldZone(
    name: 'The Dark Matter',
    flavor: 'A region of pure null-energy where existence itself is hostile. '
        'Anti-matter constructs unmake everything they touch.',
    color: Color(0xFF5566aa),
    icon: '🕳',
    firstStage: 71,
    lastStage: 75,
  ),
  // ── Act XVI: The Eternal Prison (76–80) ────────────────────────────────────
  WorldZone(
    name: 'The Eternal Prison',
    flavor: 'A fortress designed to hold beings too powerful to destroy. '
        'Its inmates have been imprisoned since before the world was named.',
    color: Color(0xFF996644),
    icon: '⛓',
    firstStage: 76,
    lastStage: 80,
  ),
  // ── Act XVII: The Abyss Gate (81–85) ───────────────────────────────────────
  WorldZone(
    name: 'The Abyss Gate',
    flavor: 'The edge of the known world. Beyond this point, old maps say only "here be nothing." '
        'The Gate guardians have never let anything through — in either direction.',
    color: Color(0xFF884499),
    icon: '🌌',
    firstStage: 81,
    lastStage: 85,
  ),
  // ── Act XVIII: The Shattered Realm (86–90) ─────────────────────────────────
  WorldZone(
    name: 'The Shattered Realm',
    flavor: 'Where a god died and the pieces of its corpse became a continent. '
        'The divine flesh still twitches, and things feed upon it.',
    color: Color(0xFFcc4477),
    icon: '💔',
    firstStage: 86,
    lastStage: 90,
  ),
  // ── Act XIX: The Final Frontier (91–95) ────────────────────────────────────
  WorldZone(
    name: 'The Final Frontier',
    flavor: 'The membrane between this world and whatever lies beyond. '
        'Explorers who reached this far stopped sending letters a long time ago.',
    color: Color(0xFF3377aa),
    icon: '🚀',
    firstStage: 91,
    lastStage: 95,
  ),
  // ── Act XX: The Omega Throne (96–100) ──────────────────────────────────────
  WorldZone(
    name: 'The Omega Throne',
    flavor: 'The seat of the original darkness. Every evil encountered on this journey '
        'was merely a servant. The true author of the curse sits here, waiting.',
    color: Color(0xFFcc2222),
    icon: '♾',
    firstStage: 96,
    lastStage: 100,
  ),
];

WorldZone zoneForStageIndex(int stageIndex) {
  for (final z in kWorldZones) {
    if (z.contains(stageIndex)) return z;
  }
  // Beyond stage 100 — keep Omega Throne style for endless abyss
  return kWorldZones.last;
}
