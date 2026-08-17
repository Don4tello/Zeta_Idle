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
    required this.color,
    this.zcoinCost = 0,
    this.description = '',
    this.glow = false,
    this.productId,
  });

  final String id, name, icon, description;
  final CosmeticType type;
  final int zcoinCost;
  final Color color;
  final bool glow;          // frames/name colours with an extra glow effect
  final String? productId;  // non-null → real-money only (IAP), not zcoin-buyable

  /// Real-money exclusive (bought via IAP, never with zcoins).
  bool get isRealMoney => productId != null;

  static const all = [
    // ── Titles (zcoins 500–1500) ─────────────────────────────────────────────
    CosmeticItem(id: 'title_champion', name: 'Champion', type: CosmeticType.title,
      icon: '🏆', zcoinCost: 500, color: Color(0xFFFFD700),
      description: 'Display "Champion" below your name.'),
    CosmeticItem(id: 'title_slayer', name: 'Slayer', type: CosmeticType.title,
      icon: '⚔', zcoinCost: 500, color: Color(0xFFcc4444),
      description: 'Display "Slayer" below your name.'),
    CosmeticItem(id: 'title_archmage', name: 'Archmage', type: CosmeticType.title,
      icon: '🔮', zcoinCost: 700, color: Color(0xFF6688ff),
      description: 'Display "Archmage" below your name.'),
    CosmeticItem(id: 'title_warlord', name: 'Warlord', type: CosmeticType.title,
      icon: '🛡', zcoinCost: 700, color: Color(0xFFcc7744),
      description: 'Display "Warlord" below your name.'),
    CosmeticItem(id: 'title_shadowblade', name: 'Shadowblade', type: CosmeticType.title,
      icon: '🗡', zcoinCost: 900, color: Color(0xFF9977dd),
      description: 'Display "Shadowblade" below your name.'),
    CosmeticItem(id: 'title_immortal', name: 'Immortal', type: CosmeticType.title,
      icon: '✦', zcoinCost: 1000, color: Color(0xFFcc88ff),
      description: 'Display "Immortal" below your name.'),
    CosmeticItem(id: 'title_dragonheart', name: 'Dragonheart', type: CosmeticType.title,
      icon: '🐉', zcoinCost: 1100, color: Color(0xFFff5533),
      description: 'Display "Dragonheart" below your name.'),
    CosmeticItem(id: 'title_godslayer', name: 'Godslayer', type: CosmeticType.title,
      icon: '👑', zcoinCost: 1300, color: Color(0xFFff44ff),
      description: 'Display "Godslayer" below your name.'),
    CosmeticItem(id: 'title_ascendant', name: 'Ascendant', type: CosmeticType.title,
      icon: '🌟', zcoinCost: 1500, color: Color(0xFF66ffcc),
      description: 'Display "Ascendant" below your name.'),
    // Real-money exclusive title
    CosmeticItem(id: 'title_eternal', name: 'The Eternal', type: CosmeticType.title,
      icon: '♾', color: Color(0xFFffe066), glow: true,
      productId: 'cosmetic_title_eternal',
      description: 'Exclusive real-money title with a radiant glow.'),

    // ── Name Colours (zcoins 250–1000) ───────────────────────────────────────
    CosmeticItem(id: 'color_gold', name: 'Golden Name', type: CosmeticType.nameColor,
      icon: '✨', zcoinCost: 250, color: Color(0xFFFFD700),
      description: 'Your name glows gold.'),
    CosmeticItem(id: 'color_crimson', name: 'Crimson Name', type: CosmeticType.nameColor,
      icon: '🔴', zcoinCost: 250, color: Color(0xFFcc2222),
      description: 'Your name burns crimson.'),
    CosmeticItem(id: 'color_nature', name: 'Nature Name', type: CosmeticType.nameColor,
      icon: '🟢', zcoinCost: 300, color: Color(0xFF44cc44),
      description: 'Your name grows with nature.'),
    CosmeticItem(id: 'color_frost', name: 'Frost Name', type: CosmeticType.nameColor,
      icon: '🔵', zcoinCost: 400, color: Color(0xFF44bbff),
      description: 'Your name shimmers with frost.'),
    CosmeticItem(id: 'color_arcane', name: 'Arcane Name', type: CosmeticType.nameColor,
      icon: '🟣', zcoinCost: 450, color: Color(0xFFcc44ff),
      description: 'Your name pulses with arcane energy.'),
    CosmeticItem(id: 'color_emerald', name: 'Emerald Name', type: CosmeticType.nameColor,
      icon: '💚', zcoinCost: 550, color: Color(0xFF2ecc71),
      description: 'Your name shines emerald.'),
    CosmeticItem(id: 'color_sunset', name: 'Sunset Name', type: CosmeticType.nameColor,
      icon: '🟠', zcoinCost: 650, color: Color(0xFFff9955), glow: true,
      description: 'Your name burns with a warm sunset glow.'),
    CosmeticItem(id: 'color_shadow', name: 'Shadow Name', type: CosmeticType.nameColor,
      icon: '🟪', zcoinCost: 750, color: Color(0xFF9b59ff), glow: true,
      description: 'Your name radiates dark energy.'),
    CosmeticItem(id: 'color_inferno', name: 'Inferno Name', type: CosmeticType.nameColor,
      icon: '🔥', zcoinCost: 850, color: Color(0xFFff4422), glow: true,
      description: 'Your name blazes with an infernal glow.'),
    CosmeticItem(id: 'color_celestial', name: 'Celestial Name', type: CosmeticType.nameColor,
      icon: '⭐', zcoinCost: 1000, color: Color(0xFFffe08a), glow: true,
      description: 'Your name shines with celestial light.'),
    // Real-money exclusive name colour
    CosmeticItem(id: 'color_prismatic', name: 'Prismatic Name', type: CosmeticType.nameColor,
      icon: '🌈', color: Color(0xFFff66cc), glow: true,
      productId: 'cosmetic_name_prismatic',
      description: 'Exclusive real-money name colour with a prismatic glow.'),

    // ── Frames (zcoins 500–1500) ─────────────────────────────────────────────
    CosmeticItem(id: 'frame_gold', name: 'Golden Frame', type: CosmeticType.frame,
      icon: '🖼', zcoinCost: 500, color: Color(0xFFFFD700),
      description: 'A gilded frame around your hero portrait.'),
    CosmeticItem(id: 'frame_fire', name: 'Flame Frame', type: CosmeticType.frame,
      icon: '🔥', zcoinCost: 700, color: Color(0xFFff6633), glow: true,
      description: 'Flames glow around your portrait.'),
    CosmeticItem(id: 'frame_frost', name: 'Frost Frame', type: CosmeticType.frame,
      icon: '❄', zcoinCost: 750, color: Color(0xFF66ccff),
      description: 'A frozen frame rimes your portrait.'),
    CosmeticItem(id: 'frame_nature', name: 'Verdant Frame', type: CosmeticType.frame,
      icon: '🌿', zcoinCost: 800, color: Color(0xFF66cc55),
      description: 'Living vines wreathe your portrait.'),
    CosmeticItem(id: 'frame_void', name: 'Void Frame', type: CosmeticType.frame,
      icon: '🌑', zcoinCost: 1000, color: Color(0xFFaa44ff), glow: true,
      description: 'Void energy glows around your portrait.'),
    CosmeticItem(id: 'frame_storm', name: 'Storm Frame', type: CosmeticType.frame,
      icon: '⚡', zcoinCost: 1100, color: Color(0xFF88aaff), glow: true,
      description: 'Lightning crackles around your portrait.'),
    CosmeticItem(id: 'frame_crimson', name: 'Bloodforged Frame', type: CosmeticType.frame,
      icon: '🩸', zcoinCost: 1200, color: Color(0xFFdd3344), glow: true,
      description: 'A blood-forged frame glows around your portrait.'),
    CosmeticItem(id: 'frame_celestial', name: 'Celestial Frame', type: CosmeticType.frame,
      icon: '⭐', zcoinCost: 1500, color: Color(0xFFffcc44), glow: true,
      description: 'Stars orbit your portrait with a golden glow.'),
    // Real-money exclusive frame
    CosmeticItem(id: 'frame_eclipse', name: 'Eclipse Frame', type: CosmeticType.frame,
      icon: '🌘', color: Color(0xFFb066ff), glow: true,
      productId: 'cosmetic_frame_eclipse',
      description: 'Exclusive real-money frame wreathed in eclipse light.'),
  ];

  /// The cosmetic bound to an IAP product id (real-money items), or null.
  static CosmeticItem? forProductId(String productId) {
    for (final c in all) {
      if (c.productId == productId) return c;
    }
    return null;
  }

  /// Colour for an equipped title (matched by display name), gold as fallback.
  static Color titleColorForName(String? name) {
    if (name != null && name.isNotEmpty) {
      for (final c in all) {
        if (c.type == CosmeticType.title && c.name == name) return c.color;
      }
    }
    return const Color(0xFFC9A35A); // accent gold
  }

  /// Colour for an equipped name-colour cosmetic id, or null if none/unknown.
  static Color? nameColorFor(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final c in all) {
      if (c.id == id && c.type == CosmeticType.nameColor) return c.color;
    }
    return null;
  }

  /// Whether an equipped name-colour / frame id carries a glow effect.
  static bool hasGlow(String? id) {
    if (id == null || id.isEmpty) return false;
    for (final c in all) {
      if (c.id == id) return c.glow;
    }
    return false;
  }

  /// Accent colour for a portrait frame id (shop frames + rebirth-reward frames).
  /// Used to draw a coloured ring around the hero avatar. Null = no frame.
  static Color? frameColorFor(String? id) {
    if (id == null || id.isEmpty) return null;
    const rebirthFrames = {
      'frame_bronze':   Color(0xFFcd7f32),
      'frame_silver':   Color(0xFFc0c0c0),
      'frame_gold':     Color(0xFFFFD700),
      'frame_platinum': Color(0xFFe5e4e2),
      'frame_mythic':   Color(0xFFff6644),
      'frame_celestial':Color(0xFFffcc44),
    };
    if (rebirthFrames.containsKey(id)) return rebirthFrames[id];
    for (final c in all) {
      if (c.id == id && c.type == CosmeticType.frame) return c.color;
    }
    return null;
  }
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
