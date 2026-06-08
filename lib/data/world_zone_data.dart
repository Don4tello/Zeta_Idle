import 'package:flutter/material.dart';
import '../models/world_zone.dart';

const kWorldZones = <WorldZone>[
  WorldZone(
    name: 'The Cursed Realm',
    flavor: 'Ancient burial grounds where the dead refuse to stay buried. '
        'Skeletons, shadow knights, and wraiths haunt every broken stone.',
    color: Color(0xFF7755cc),
    icon: '💀',
    firstStage: 1,
    lastStage: 5,
  ),
  WorldZone(
    name: 'The Blighted Wilds',
    flavor: 'A cursed forest bleeding into fetid swamps and icy mountain passes. '
        'Something ancient spins its web at the heart of this corrupted land.',
    color: Color(0xFF336644),
    icon: '🌲',
    firstStage: 6,
    lastStage: 10,
  ),
  WorldZone(
    name: 'The Infernal Depths',
    flavor: 'Rivers of molten rock carve through volcanic caverns. '
        'Infernal knights and draconic warlords rule the burning dark below.',
    color: Color(0xFFcc5522),
    icon: '🔥',
    firstStage: 11,
    lastStage: 15,
  ),
  WorldZone(
    name: 'The Void Expanse',
    flavor: 'Reality frays at the edges here. Impossible structures float in a sky '
        'that should not exist, guarded by things that predate the world.',
    color: Color(0xFF334488),
    icon: '🌀',
    firstStage: 16,
    lastStage: 20,
  ),
  WorldZone(
    name: 'Throne of Ruin',
    flavor: 'The final fortress. Ancient evil concentrates into a singular point of '
        'darkness. Survive this, and you earn the right to begin again.',
    color: Color(0xFF993333),
    icon: '☠',
    firstStage: 21,
    lastStage: 25,
  ),
];

WorldZone zoneForStageIndex(int stageIndex) {
  for (final z in kWorldZones) {
    if (z.contains(stageIndex)) return z;
  }
  // Beyond stage 25 — keep last zone style
  return kWorldZones.last;
}
