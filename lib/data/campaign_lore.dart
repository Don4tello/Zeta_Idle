// ─────────────────────────────────────────────────────────────────────────────
// Campaign Lore — skippable story/RPG text shown once on first encounter
//
// Three layers, all dismissable and stored so they never repeat:
//   1. Zone entry cards   — first time the player enters a new zone
//   2. Boss intro cards   — before the first fight with a named boss
//   3. Boss defeat lines  — in the victory screen after first boss kill
// ─────────────────────────────────────────────────────────────────────────────

class ZoneLore {
  const ZoneLore({required this.zoneIndex, required this.entry});
  final int    zoneIndex; // 0-based, matches kWorldZones index
  final String entry;     // shown when zone is first reached
}

class BossLore {
  const BossLore({
    required this.bossId,
    required this.intro,
    required this.defeat,
  });
  final String bossId;
  final String intro;   // shown in pre-fight card (first encounter only)
  final String defeat;  // shown in victory screen (first kill only)
}

// ── Zone entry text ───────────────────────────────────────────────────────────

const kZoneLore = <ZoneLore>[
  ZoneLore(
    zoneIndex: 0,
    entry: 'You step onto ancient burial grounds. The dead here do not rest — '
           'they march. Something commands them, and it has noticed you.',
  ),
  ZoneLore(
    zoneIndex: 1,
    entry: 'The trees breathe wrong. A cursed forest where something ancient '
           'has poisoned the roots — and everything that grew from them.',
  ),
  ZoneLore(
    zoneIndex: 2,
    entry: 'Heat rises from cracks in the stone. Below the rock, something '
           'burns that never started burning. It simply always has.',
  ),
  ZoneLore(
    zoneIndex: 3,
    entry: 'Reality frays at the edges here. Every surface reflects something '
           'that is not quite there. The Crystal Sanctum watches back.',
  ),
  ZoneLore(
    zoneIndex: 4,
    entry: 'The final fortress of an ancient evil, concentrated into a single '
           'point. You can feel it pressing against the inside of the air.',
  ),
  ZoneLore(
    zoneIndex: 5,
    entry: 'A palace of living crystal suspended in the void. Light bends here '
           'in directions that should not exist.',
  ),
  ZoneLore(
    zoneIndex: 6,
    entry: 'Shadows are solid here. Light is lethal. A dimension built by '
           'something that has never seen the sun and considers that an advantage.',
  ),
  ZoneLore(
    zoneIndex: 7,
    entry: 'Ancient things sleep beneath the ice. You are walking on a graveyard '
           'that has been frozen long enough to forget it is one.',
  ),
  ZoneLore(
    zoneIndex: 8,
    entry: 'Sky citadels float on perpetual lightning. The storm here is not '
           'weather — it is a kingdom. You have entered without permission.',
  ),
  ZoneLore(
    zoneIndex: 9,
    entry: 'A sunless sea where pressure crushes thought. There is no floor. '
           'There is no ceiling. There is only the deep, and what lives in it.',
  ),
  ZoneLore(
    zoneIndex: 10,
    entry: 'A maze between worlds where the walls shift and doors lead nowhere. '
           'Something in here built this labyrinth from its own dreams.',
  ),
  ZoneLore(
    zoneIndex: 11,
    entry: 'A civilisation of unimaginable power that erased itself from history. '
           'The ruins remember what the histories forgot.',
  ),
  ZoneLore(
    zoneIndex: 12,
    entry: 'A blighted continent consumed by magical pestilence. Flesh and soul '
           'alike have been claimed by something that considers rot a gift.',
  ),
  ZoneLore(
    zoneIndex: 13,
    entry: 'The shattered remnants of heaven itself — fallen after a war between '
           'gods that no mortal witnessed and no scripture recorded.',
  ),
  ZoneLore(
    zoneIndex: 14,
    entry: 'A region of pure null-energy where existence itself is hostile. '
           'The void is not empty here. It is full of something worse than nothing.',
  ),
  ZoneLore(
    zoneIndex: 15,
    entry: 'A fortress designed to hold beings too powerful to kill. '
           'The cells are empty. The locks are broken. You are walking the wrong way.',
  ),
  ZoneLore(
    zoneIndex: 16,
    entry: 'Old maps end here. Beyond this point they wrote only: "here be nothing." '
           'They were wrong. Something is here. It has been waiting.',
  ),
  ZoneLore(
    zoneIndex: 17,
    entry: 'Where a god died and its pieces became a continent. Every step '
           'is on divine remains. The corpse remembers what it was.',
  ),
  ZoneLore(
    zoneIndex: 18,
    entry: 'The membrane between this world and what lies beyond. You can hear '
           'something breathing on the other side. It is very large.',
  ),
  ZoneLore(
    zoneIndex: 19,
    entry: 'The seat of the original darkness. Every evil you have faced on '
           'this journey was a shadow cast by what sits on the throne ahead.',
  ),
];

// ── Boss lore ─────────────────────────────────────────────────────────────────

const kBossLore = <BossLore>[
  BossLore(
    bossId: 'goblin_warchief',
    intro: 'The drums grow louder. The Goblin Warchief commands his horde with '
           'stolen armour and brutal cunning — your first true test. He has never '
           'lost. He has never faced someone like you.',
    defeat: 'The Warchief\'s war-drum falls silent. His horde scatters into the '
            'dark without a general to follow.',
  ),
  BossLore(
    bossId: 'necromancer_vael',
    intro: 'He stitched himself together from the bodies of those he defeated. '
           'Vael considers himself both general and army. He has been watching '
           'you since you entered the Wilds.',
    defeat: 'Vael unravels, piece by piece, into the soil he\'s tainted. '
            'The soldiers he raised crumble a moment later.',
  ),
  BossLore(
    bossId: 'pharaoh_kethran',
    intro: 'He refused death for three thousand years. The bandages are not '
           'wrappings — they are the curse made visible. Kethran was a god-king '
           'once. He intends to be one again.',
    defeat: 'The ancient sarcophagus reseals with a sound like a continent '
            'sighing. Kethran sleeps again — but this time, he will not wake.',
  ),
  BossLore(
    bossId: 'the_tyrant_eye',
    intro: 'It has been watching since you entered the Sanctum. Every move '
           'catalogued. Every weakness identified. It is not afraid of you. '
           'It should reconsider.',
    defeat: 'The aperture closes. The eye that saw everything finally sees '
            'nothing at all.',
  ),
  BossLore(
    bossId: 'lich_emperor',
    intro: 'The original undead sorcerer-king. His death is not a setback — '
           'it is a tradition he has made routine. He has waited for someone '
           'worthy to finally put him down. You have his attention.',
    defeat: 'His phylactery shatters. An empire that outlasted its own age '
            'finally, properly ends.',
  ),
  BossLore(
    bossId: 'prism_lord',
    intro: 'It has solved the equation for your death. The Prism Lord\'s mind '
           'is a lattice of pure arcane mathematics, and every angle of light '
           'it refracts is a weapon aimed at you.',
    defeat: 'The lattice fractures. Equations without a mind to hold them '
            'dissolve into scattered light.',
  ),
  BossLore(
    bossId: 'shadow_king',
    intro: 'He ruled while his subjects believed they had no king. Every shadow '
           'you have ever cast belongs to him. He is standing in your shadow '
           'right now.',
    defeat: 'The throne room floods with light. A king who ruled from darkness '
            'discovers he has no power over the day.',
  ),
  BossLore(
    bossId: 'glacier_wyrm',
    intro: 'Its body calcified into living glacier over millennia of slumber. '
           'It breathes winter itself. It was here before the mountains. '
           'You woke it.',
    defeat: 'Ancient ice, unmolted for ten thousand years, finally thaws. '
            'The wyrm\'s long sleep becomes something permanent.',
  ),
  BossLore(
    bossId: 'king_of_storms',
    intro: 'The primordial storm given a crown and a grudge. The sky does not '
           'contain it — it contains the sky. It has never lost a throne to '
           'something that needed to breathe.',
    defeat: 'The storm breaks. Clear skies appear over the Storm Reaches '
            'for the first time in recorded history.',
  ),
  BossLore(
    bossId: 'leviathan',
    intro: 'The original sea-beast from before the ocean had a floor. It is '
           'not a creature of the abyss — the abyss is a creature of it. '
           'You are very small. It has noticed.',
    defeat: 'The deep reclaims its titan. The sea is quiet in a way it '
            'has not been since before the first wave.',
  ),
  BossLore(
    bossId: 'the_dreaming_god',
    intro: 'It is not fully awake. It does not need to be. Every corridor '
           'of this labyrinth is a thought it is having. You are a nightmare '
           'it is about to wake up from.',
    defeat: 'The dream collapses. Reality reasserts itself with a shudder, '
            'uncertain what the rules were before the dreaming started.',
  ),
  BossLore(
    bossId: 'prime_emperor',
    intro: 'The last ruler of the Forgotten Empire, preserved in stasis, '
           'awaiting a war that ended ten thousand years ago. He has been '
           'briefed on current events. He is furious.',
    defeat: 'The first empire falls. Again. This time there is no stasis '
            'chamber left to preserve what remains of it.',
  ),
  BossLore(
    bossId: 'god_of_rot',
    intro: 'Not the plague — the thing the plague prays to. The divine '
           'wellspring of all corruption. Its presence alone warps the '
           'laws of life and death. You are standing in it.',
    defeat: 'The rot retreats. Not gone — only delayed. But today, '
            'delayed is enough.',
  ),
  BossLore(
    bossId: 'the_void_god',
    intro: 'The deity that corrupted the celestial order from within. '
           'Not fallen — it jumped. What the angels became after it '
           'whispered to them is what you have been fighting all along.',
    defeat: 'The void closes around its own god. Silence without end, '
            'somewhere beyond the edge of everything.',
  ),
  BossLore(
    bossId: 'null_sovereign',
    intro: 'The absolute ruler of unmatter. To look at it is to understand '
           'that existence is optional. To fight it is to disagree with '
           'that assessment.',
    defeat: 'Something that cannot exist discovers it also cannot survive. '
            'You have argued successfully against the impossible.',
  ),
  BossLore(
    bossId: 'the_first_prisoner',
    intro: 'Imprisoned before the world had a name. Whatever it did to earn '
           'a prison built before prisons existed, no one wrote it down. '
           'You have opened the lock.',
    defeat: 'The door closes again. This time from the outside. '
            'This time you hold the key.',
  ),
  BossLore(
    bossId: 'gate_titan',
    intro: 'It was built from the gate itself when the gate realized '
           'something had reached it. Its body is the threshold between '
           'this world and what comes next. It was built to never fall.',
    defeat: 'The gate opens. You are not entirely sure this counts as '
            'a victory. You step through anyway.',
  ),
  BossLore(
    bossId: 'god_eater',
    intro: 'It consumed seventeen gods before they stopped sending them. '
           'The shattered realm around you is the archaeological record '
           'of its last meal. It is still hungry.',
    defeat: 'For the first time in its existence, the God Eater is '
            'the one that gets consumed.',
  ),
  BossLore(
    bossId: 'world_ender',
    intro: 'It has ended forty-seven worlds. This is the forty-eighth. '
           'The procedure is routine to it. It has never encountered '
           'something it could not reduce to silence.',
    defeat: 'The World Ender\'s count stays at forty-seven. '
            'The forty-eighth world survives because you were in it.',
  ),
  BossLore(
    bossId: 'omega_absolute',
    intro: 'Every path through fate ends here. The Omega Absolute is not '
           'a boss — it is an inevitability. It has manifested personally '
           'because your persistence has warranted its attention. '
           'This is the end.',
    defeat: 'The Omega falls.\n\nThe curse is ended. The darkness that '
            'cast its shadow over every world you walked through is gone.\n\n'
            'You are still here. That was never supposed to happen. '
            'It is, perhaps, the most important thing that ever did.',
  ),
];

BossLore? bossLoreFor(String bossId) {
  for (final l in kBossLore) {
    if (l.bossId == bossId) return l;
  }
  return null;
}

ZoneLore? zoneLoreFor(int zoneIndex) {
  for (final l in kZoneLore) {
    if (l.zoneIndex == zoneIndex) return l;
  }
  return null;
}
