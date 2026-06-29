class RebirthCosmetic {
  const RebirthCosmetic({
    required this.rebirthLevel,
    required this.title,
    required this.titleColor,
    required this.frameId,
    required this.frameLabel,
    this.auraId,
    this.auraLabel,
  });

  final int rebirthLevel;
  final String title, frameId, frameLabel;
  final int titleColor;
  final String? auraId, auraLabel;

  static const all = [
    RebirthCosmetic(rebirthLevel: 1,  title: 'Reborn',          titleColor: 0xFF88ccff, frameId: 'frame_bronze',    frameLabel: 'Bronze Frame'),
    RebirthCosmetic(rebirthLevel: 2,  title: 'Twice-Forged',    titleColor: 0xFF66aaff, frameId: 'frame_silver',    frameLabel: 'Silver Frame'),
    RebirthCosmetic(rebirthLevel: 3,  title: 'Thrice-Ascended', titleColor: 0xFFcc88ff, frameId: 'frame_gold',      frameLabel: 'Gold Frame',      auraId: 'aura_faint',   auraLabel: 'Faint Glow'),
    RebirthCosmetic(rebirthLevel: 5,  title: 'Eternal',         titleColor: 0xFFffcc44, frameId: 'frame_platinum',  frameLabel: 'Platinum Frame',  auraId: 'aura_radiant', auraLabel: 'Radiant Aura'),
    RebirthCosmetic(rebirthLevel: 7,  title: 'Mythic',          titleColor: 0xFFff6644, frameId: 'frame_mythic',    frameLabel: 'Mythic Frame',    auraId: 'aura_flame',   auraLabel: 'Flame Aura'),
    RebirthCosmetic(rebirthLevel: 10, title: 'Transcendent',    titleColor: 0xFFff44ff, frameId: 'frame_celestial', frameLabel: 'Celestial Frame', auraId: 'aura_void',    auraLabel: 'Void Aura'),
  ];

  static RebirthCosmetic? forLevel(int rebirthLevel) {
    RebirthCosmetic? best;
    for (final c in all) {
      if (rebirthLevel >= c.rebirthLevel) best = c;
    }
    return best;
  }

  static List<RebirthCosmetic> unlockedAt(int rebirthLevel) =>
      all.where((c) => rebirthLevel >= c.rebirthLevel).toList();
}
