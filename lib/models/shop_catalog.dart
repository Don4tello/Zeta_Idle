import 'package:flutter/material.dart';

// ── Starter/Hero Packs (one-time purchase) ───────────────────────────────────

class StarterPack {
  const StarterPack({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.price,
    required this.description,
    required this.contents,
    this.productId,
  });

  final String id, name, icon, price, description;
  final Color color;
  final Map<String, int> contents;
  final String? productId;

  static const all = [
    StarterPack(
      id: 'starter_pack',
      name: "Adventurer's Pack",
      icon: '🎒',
      color: Color(0xFF44cc88),
      price: '\$4.99',
      productId: 'pack_starter',
      description: 'Perfect for new heroes — a boost to get you started.',
      contents: {
        'zcoins': 500,
        'gold': 10000,
        'shards': 100,
        'essence': 50,
        'epicHelmet': 1,
      },
    ),
    StarterPack(
      id: 'hero_pack',
      name: "Hero's Pack",
      icon: '⚔',
      color: Color(0xFFFFD700),
      price: '\$9.99',
      productId: 'pack_hero',
      description: 'For the ambitious — premium gear and resources.',
      contents: {
        'zcoins': 1500,
        'gold': 30000,
        'shards': 300,
        'essence': 200,
        'mythril': 50,
        'echoes': 150,
        'legendaryWeapon': 1,
      },
    ),
    StarterPack(
      id: 'legend_pack',
      name: "Legend's Pack",
      icon: '👑',
      color: Color(0xFFcc44ff),
      price: '\$19.99',
      productId: 'pack_legend',
      description: 'The ultimate bundle — dominate from day one.',
      contents: {
        'zcoins': 4000,
        'gold': 100000,
        'shards': 800,
        'essence': 500,
        'mythril': 150,
        'echoes': 400,
        'gemShards': 200,
        'setPiece': 1,
      },
    ),
  ];
}

// ── Cosmetic Shop ────────────────────────────────────────────────────────────

enum CosmeticType { title, frame, nameColor }

class CosmeticItem {
  const CosmeticItem({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.zcoinCost,
    required this.color,
    this.description = '',
  });

  final String id, name, icon, description;
  final CosmeticType type;
  final int zcoinCost;
  final Color color;

  static const all = [
    // Titles
    CosmeticItem(id: 'title_champion', name: 'Champion', type: CosmeticType.title,
      icon: '🏆', zcoinCost: 100, color: Color(0xFFFFD700),
      description: 'Display "Champion" below your name.'),
    CosmeticItem(id: 'title_slayer', name: 'Slayer', type: CosmeticType.title,
      icon: '⚔', zcoinCost: 100, color: Color(0xFFcc4444),
      description: 'Display "Slayer" below your name.'),
    CosmeticItem(id: 'title_archmage', name: 'Archmage', type: CosmeticType.title,
      icon: '🔮', zcoinCost: 150, color: Color(0xFF6688ff),
      description: 'Display "Archmage" below your name.'),
    CosmeticItem(id: 'title_immortal', name: 'Immortal', type: CosmeticType.title,
      icon: '✦', zcoinCost: 200, color: Color(0xFFcc88ff),
      description: 'Display "Immortal" below your name.'),
    CosmeticItem(id: 'title_godslayer', name: 'Godslayer', type: CosmeticType.title,
      icon: '👑', zcoinCost: 500, color: Color(0xFFff44ff),
      description: 'Display "Godslayer" below your name.'),

    // Name Colors
    CosmeticItem(id: 'color_gold', name: 'Golden Name', type: CosmeticType.nameColor,
      icon: '✨', zcoinCost: 150, color: Color(0xFFFFD700),
      description: 'Your name glows gold.'),
    CosmeticItem(id: 'color_crimson', name: 'Crimson Name', type: CosmeticType.nameColor,
      icon: '🔴', zcoinCost: 150, color: Color(0xFFcc2222),
      description: 'Your name burns crimson.'),
    CosmeticItem(id: 'color_arcane', name: 'Arcane Name', type: CosmeticType.nameColor,
      icon: '🟣', zcoinCost: 150, color: Color(0xFFcc44ff),
      description: 'Your name pulses with arcane energy.'),
    CosmeticItem(id: 'color_frost', name: 'Frost Name', type: CosmeticType.nameColor,
      icon: '🔵', zcoinCost: 150, color: Color(0xFF44bbff),
      description: 'Your name shimmers with frost.'),
    CosmeticItem(id: 'color_nature', name: 'Nature Name', type: CosmeticType.nameColor,
      icon: '🟢', zcoinCost: 150, color: Color(0xFF44cc44),
      description: 'Your name grows with nature.'),

    // Frames
    CosmeticItem(id: 'frame_gold', name: 'Golden Frame', type: CosmeticType.frame,
      icon: '🖼', zcoinCost: 200, color: Color(0xFFFFD700),
      description: 'A gilded frame around your hero portrait.'),
    CosmeticItem(id: 'frame_fire', name: 'Flame Frame', type: CosmeticType.frame,
      icon: '🔥', zcoinCost: 200, color: Color(0xFFff6633),
      description: 'Flames dance around your portrait.'),
    CosmeticItem(id: 'frame_void', name: 'Void Frame', type: CosmeticType.frame,
      icon: '🌑', zcoinCost: 300, color: Color(0xFFaa44ff),
      description: 'Void energy swirls around your portrait.'),
    CosmeticItem(id: 'frame_celestial', name: 'Celestial Frame', type: CosmeticType.frame,
      icon: '⭐', zcoinCost: 500, color: Color(0xFFffcc44),
      description: 'Stars orbit your portrait.'),
  ];
}

// ── Subscription tiers ───────────────────────────────────────────────────────

class SubscriptionTier {
  const SubscriptionTier({
    required this.id,
    required this.name,
    required this.price,
    required this.icon,
    required this.color,
    required this.perks,
    this.productId,
  });

  final String id, name, price, icon;
  final Color color;
  final List<String> perks;
  final String? productId;

  static const all = [
    SubscriptionTier(
      id: 'sub_speed',
      name: 'Speed Boost',
      price: '\$0.99/month',
      icon: '⚡',
      color: Color(0xFFffcc44),
      productId: 'sub_speed_monthly',
      perks: [
        '2× battle speed permanently',
        'Auto-Campaign enabled',
        '+25% idle gold',
        '100 bonus zcoins/month',
      ],
    ),
    SubscriptionTier(
      id: 'sub_premium',
      name: 'Premium Pass',
      price: '\$4.99/month',
      icon: '👑',
      color: Color(0xFFcc88ff),
      productId: 'sub_premium_monthly',
      perks: [
        '2× Season Pass XP',
        'Premium Season Pass rewards',
        '3× battle speed',
        'Auto-Campaign enabled',
        '+50% idle gold',
        'Exclusive "Premium" title',
        '300 bonus zcoins/month',
        'Battle Sim — replay any past stage instantly',
      ],
    ),
  ];
}
