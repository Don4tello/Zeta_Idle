import 'package:flutter/material.dart';

class WaystoneType {
  const WaystoneType({
    required this.id,
    required this.name,
    required this.icon,
    required this.durationHours,
    required this.multiplier,
    required this.zcoinCost,
    required this.color,
  });

  final String id;
  final String name;
  final String icon;
  final int durationHours;
  final double multiplier;
  final int zcoinCost;
  final Color color;

  static const all = [basic, grand];

  static const basic = WaystoneType(
    id: 'basic',
    name: 'Waystone',
    icon: '🌀',
    durationHours: 4,
    multiplier: 2.0,
    zcoinCost: 20,
    color: Color(0xFF66aaff),
  );

  static const grand = WaystoneType(
    id: 'grand',
    name: 'Grand Waystone',
    icon: '⭐',
    durationHours: 12,
    multiplier: 3.0,
    zcoinCost: 50,
    color: Color(0xFFffcc44),
  );

  static WaystoneType? byId(String id) =>
      all.where((w) => w.id == id).firstOrNull;
}
