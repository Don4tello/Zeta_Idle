import 'package:flutter/material.dart';

class WorldZone {
  const WorldZone({
    required this.name,
    required this.flavor,
    required this.color,
    required this.icon,
    required this.firstStage,  // 1-based
    required this.lastStage,   // 1-based inclusive
  });

  final String name;
  final String flavor;
  final Color color;
  final String icon;
  final int firstStage;
  final int lastStage;

  int get stageCount => lastStage - firstStage + 1;

  int progressIn(int stageIndex) =>
      (stageIndex + 1 - firstStage).clamp(0, stageCount);

  bool contains(int stageIndex) =>
      stageIndex + 1 >= firstStage && stageIndex + 1 <= lastStage;
}
