enum ArtifactSlot { ring, amulet, trinket }

extension ArtifactSlotExt on ArtifactSlot {
  String get label => switch (this) {
    ArtifactSlot.ring    => 'Ring',
    ArtifactSlot.amulet  => 'Amulet',
    ArtifactSlot.trinket => 'Trinket',
  };
  String get icon => switch (this) {
    ArtifactSlot.ring    => '💍',
    ArtifactSlot.amulet  => '📿',
    ArtifactSlot.trinket => '🪬',
  };
}

class Artifact {
  const Artifact({
    required this.id,
    required this.name,
    required this.slot,
    required this.flavorText,
    required this.mythrilCost,
    this.attackBonus  = 0,
    this.damageBonus  = 0,
    this.acBonus      = 0,
    this.hpPct        = 0,
    this.shardPct     = 0,
    this.goldPct      = 0,
    this.xpPct        = 0,
  });

  final String id;
  final String name;
  final ArtifactSlot slot;
  final String flavorText;
  final int mythrilCost;

  final int attackBonus;
  final int damageBonus;
  final int acBonus;
  final int hpPct;
  final int shardPct;
  final int goldPct;
  final int xpPct;

  static Artifact? byId(String? id) =>
      id == null ? null : all.where((a) => a.id == id).firstOrNull;

  // ── Rings ────────────────────────────────────────────────────────────────────
  static const all = [
    // Rings — attack & damage focused
    Artifact(
      id: 'ring_warrior', name: "Warrior's Band", slot: ArtifactSlot.ring,
      flavorText: 'Forged in the fires of a thousand battles.',
      mythrilCost: 15, attackBonus: 3,
    ),
    Artifact(
      id: 'ring_slayer', name: "Slayer's Signet", slot: ArtifactSlot.ring,
      flavorText: 'The rune on its face glows red with each kill.',
      mythrilCost: 20, damageBonus: 4,
    ),
    Artifact(
      id: 'ring_fortune', name: 'Ring of Fortune', slot: ArtifactSlot.ring,
      flavorText: 'Luck flows through its golden band.',
      mythrilCost: 18, shardPct: 15, goldPct: 10,
    ),
    Artifact(
      id: 'ring_iron', name: 'Iron Loop', slot: ArtifactSlot.ring,
      flavorText: 'Crude but unyielding.',
      mythrilCost: 12, acBonus: 2, hpPct: 5,
    ),
    Artifact(
      id: 'ring_sage', name: "Sage's Circle", slot: ArtifactSlot.ring,
      flavorText: 'Ancient knowledge spirals within.',
      mythrilCost: 20, xpPct: 20, attackBonus: 1,
    ),

    // Amulets — defense & utility focused
    Artifact(
      id: 'amulet_guardian', name: "Guardian's Pendant", slot: ArtifactSlot.amulet,
      flavorText: 'A ward against all harm, worn by the fearless.',
      mythrilCost: 18, acBonus: 3, hpPct: 8,
    ),
    Artifact(
      id: 'amulet_crusader', name: "Crusader's Medallion", slot: ArtifactSlot.amulet,
      flavorText: 'Blessed by a long-forgotten high priest.',
      mythrilCost: 22, attackBonus: 2, acBonus: 2,
    ),
    Artifact(
      id: 'amulet_merchant', name: "Merchant's Charm", slot: ArtifactSlot.amulet,
      flavorText: 'Even enemies seem to drop more when you wear it.',
      mythrilCost: 20, goldPct: 20, shardPct: 10,
    ),
    Artifact(
      id: 'amulet_berserker', name: "Berserker's Fang", slot: ArtifactSlot.amulet,
      flavorText: 'Pain is fuel. The more you bleed, the fiercer you strike.',
      mythrilCost: 25, damageBonus: 6, hpPct: -10,
    ),
    Artifact(
      id: 'amulet_scholar', name: "Scholar's Lens", slot: ArtifactSlot.amulet,
      flavorText: 'Even mid-battle you find time to learn.',
      mythrilCost: 18, xpPct: 25,
    ),

    // Trinkets — mixed/situational
    Artifact(
      id: 'trinket_lucky_coin', name: 'Lucky Coin', slot: ArtifactSlot.trinket,
      flavorText: 'Someone lost it. Their loss, your fortune.',
      mythrilCost: 12, goldPct: 15, shardPct: 5,
    ),
    Artifact(
      id: 'trinket_vial', name: 'Vial of Vigor', slot: ArtifactSlot.trinket,
      flavorText: 'Contains a few drops of a long-expired strength potion.',
      mythrilCost: 20, damageBonus: 3, hpPct: 10,
    ),
    Artifact(
      id: 'trinket_compass', name: "Explorer's Compass", slot: ArtifactSlot.trinket,
      flavorText: 'Points toward treasure — or at least pretends to.',
      mythrilCost: 18, shardPct: 20,
    ),
    Artifact(
      id: 'trinket_stone', name: 'Rune-Carved Stone', slot: ArtifactSlot.trinket,
      flavorText: 'An ancient ward. The runes shift when no one watches.',
      mythrilCost: 22, attackBonus: 2, damageBonus: 2,
    ),
    Artifact(
      id: 'trinket_horn', name: "Champion's Horn", slot: ArtifactSlot.trinket,
      flavorText: 'A single blow signals victory — or at least the attempt.',
      mythrilCost: 25, attackBonus: 3, acBonus: 2, damageBonus: 2,
    ),
  ];
}
