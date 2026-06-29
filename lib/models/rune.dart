import 'package:flutter/material.dart';

enum RuneSlot { weapon, armor, talisman }

extension RuneSlotInfo on RuneSlot {
  String get label => switch (this) {
    RuneSlot.weapon   => 'Weapon',
    RuneSlot.armor    => 'Armor',
    RuneSlot.talisman => 'Talisman',
  };
  String get icon => switch (this) {
    RuneSlot.weapon   => '⚔',
    RuneSlot.armor    => '🛡',
    RuneSlot.talisman => '🔮',
  };
}

class RuneDef {
  const RuneDef({
    required this.id,
    required this.name,
    required this.slot,
    required this.icon,
    required this.color,
    required this.description,
    required this.durationMinutes,
    required this.dustCost,
    this.atkBonus  = 0,
    this.dmgBonus  = 0,
    this.acBonus   = 0,
    this.goldPct   = 0,
    this.xpPct     = 0,
    this.shardPct  = 0,
    this.hpPct     = 0,
    this.dodgeBonus = 0,
  });

  final String id;
  final String name;
  final RuneSlot slot;
  final String icon;
  final Color color;
  final String description;
  final int durationMinutes;
  final int dustCost;
  final int atkBonus;
  final int dmgBonus;
  final int acBonus;
  final int goldPct;
  final int xpPct;
  final int shardPct;
  final int hpPct;
  final int dodgeBonus;

  static const all = <RuneDef>[
    // Weapon runes
    RuneDef(
      id: 'fury',
      name: 'Rune of Fury',
      slot: RuneSlot.weapon,
      icon: '🔴',
      color: Color(0xFFff4422),
      description: '+3 critical damage for 20 min.',
      durationMinutes: 20,
      dustCost: 5,
      atkBonus: 3,
    ),
    RuneDef(
      id: 'blood',
      name: 'Rune of Blood',
      slot: RuneSlot.weapon,
      icon: '🩸',
      color: Color(0xFFcc2222),
      description: '+5 flat damage for 20 min.',
      durationMinutes: 20,
      dustCost: 5,
      dmgBonus: 5,
    ),
    RuneDef(
      id: 'gold_weapon',
      name: 'Rune of Plunder',
      slot: RuneSlot.weapon,
      icon: '💰',
      color: Color(0xFFffcc44),
      description: '+25% gold from kills for 30 min.',
      durationMinutes: 30,
      dustCost: 8,
      goldPct: 25,
    ),
    // Armor runes
    RuneDef(
      id: 'iron',
      name: 'Rune of Iron',
      slot: RuneSlot.armor,
      icon: '🔵',
      color: Color(0xFF66aaff),
      description: '+3 AC for 20 min.',
      durationMinutes: 20,
      dustCost: 5,
      acBonus: 3,
    ),
    RuneDef(
      id: 'ward',
      name: 'Rune of Warding',
      slot: RuneSlot.armor,
      icon: '🟢',
      color: Color(0xFF44cc88),
      description: '+10% max HP for 20 min.',
      durationMinutes: 20,
      dustCost: 5,
      hpPct: 10,
    ),
    RuneDef(
      id: 'swift',
      name: 'Rune of Swiftness',
      slot: RuneSlot.armor,
      icon: '⚡',
      color: Color(0xFFffee44),
      description: '+10% dodge chance for 15 min.',
      durationMinutes: 15,
      dustCost: 8,
      dodgeBonus: 10,
    ),
    // Talisman runes
    RuneDef(
      id: 'wisdom',
      name: 'Rune of Wisdom',
      slot: RuneSlot.talisman,
      icon: '🟣',
      color: Color(0xFFcc88ff),
      description: '+25% XP from kills for 30 min.',
      durationMinutes: 30,
      dustCost: 8,
      xpPct: 25,
    ),
    RuneDef(
      id: 'soul',
      name: 'Rune of Souls',
      slot: RuneSlot.talisman,
      icon: '◆',
      color: Color(0xFF88cc44),
      description: '+25% shard drops for 30 min.',
      durationMinutes: 30,
      dustCost: 8,
      shardPct: 25,
    ),
    RuneDef(
      id: 'fortune',
      name: 'Rune of Fortune',
      slot: RuneSlot.talisman,
      icon: '✨',
      color: Color(0xFFffaa44),
      description: '+15% gold and +15% XP for 20 min.',
      durationMinutes: 20,
      dustCost: 12,
      goldPct: 15,
      xpPct: 15,
    ),
  ];

  static RuneDef? byId(String? id) {
    if (id == null) return null;
    try { return all.firstWhere((r) => r.id == id); } catch (_) { return null; }
  }
}

class ActiveRune {
  const ActiveRune({required this.defId, required this.expiresAtMs});
  final String defId;
  final int expiresAtMs;

  bool get isExpired => DateTime.now().millisecondsSinceEpoch > expiresAtMs;
  RuneDef? get def => RuneDef.byId(defId);

  int get minutesLeft {
    final ms = expiresAtMs - DateTime.now().millisecondsSinceEpoch;
    return (ms / 60000).ceil().clamp(0, 9999);
  }

  Map<String, dynamic> toJson() => {
    'defId': defId,
    'expiresAtMs': expiresAtMs,
  };

  factory ActiveRune.fromJson(Map<String, dynamic> j) => ActiveRune(
    defId: j['defId'] as String,
    expiresAtMs: j['expiresAtMs'] as int,
  );
}
