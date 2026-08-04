import 'package:flutter/material.dart';

class AttackEffect {
  const AttackEffect({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.hitText,
    required this.zcoinCost,
  });

  final String id;
  final String name;
  final String icon;
  final Color color;
  final String hitText; // replaces "Hit!" in battle log
  final int zcoinCost;

  static const all = [fire, frost, lightning, holy, shadow, venom];

  static const fire = AttackEffect(
    id: 'fire', name: 'Flame Strike', icon: '🔥',
    color: Color(0xFFff6633), hitText: 'Ignite!', zcoinCost: 300,
  );
  static const frost = AttackEffect(
    id: 'frost', name: 'Frost Bite', icon: '❄',
    color: Color(0xFF88ddff), hitText: 'Freeze!', zcoinCost: 300,
  );
  static const lightning = AttackEffect(
    id: 'lightning', name: 'Thunder Crash', icon: '⚡',
    color: Color(0xFFffee44), hitText: 'Shock!', zcoinCost: 300,
  );
  static const holy = AttackEffect(
    id: 'holy', name: 'Holy Smite', icon: '✦',
    color: Color(0xFFffffff), hitText: 'Smite!', zcoinCost: 300,
  );
  static const shadow = AttackEffect(
    id: 'shadow', name: 'Shadow Slash', icon: '🌑',
    color: Color(0xFFaa44ff), hitText: 'Rend!', zcoinCost: 300,
  );
  static const venom = AttackEffect(
    id: 'venom', name: 'Venom Strike', icon: '☠',
    color: Color(0xFF44cc44), hitText: 'Poison!', zcoinCost: 300,
  );

  static AttackEffect? byId(String? id) =>
      id == null ? null : all.where((e) => e.id == id).firstOrNull;
}
