import 'package:flutter/material.dart';

enum ExpeditionType { goldRun, shardHunt, essenceDelve, relicSearch }

enum ExpeditionDuration { short, medium, long }

extension ExpeditionTypeInfo on ExpeditionType {
  String get label => switch (this) {
    ExpeditionType.goldRun      => 'Gold Run',
    ExpeditionType.shardHunt    => 'Shard Hunt',
    ExpeditionType.essenceDelve => 'Essence Delve',
    ExpeditionType.relicSearch  => 'Relic Search',
  };
  String get icon => switch (this) {
    ExpeditionType.goldRun      => '💰',
    ExpeditionType.shardHunt    => '◆',
    ExpeditionType.essenceDelve => '✦',
    ExpeditionType.relicSearch  => '🗺',
  };
  String get rewardLabel => switch (this) {
    ExpeditionType.goldRun      => 'Gold',
    ExpeditionType.shardHunt    => 'Shards',
    ExpeditionType.essenceDelve => 'Essence',
    ExpeditionType.relicSearch  => 'Gold + Shards',
  };
  Color get color => switch (this) {
    ExpeditionType.goldRun      => const Color(0xFFFFD700),
    ExpeditionType.shardHunt    => const Color(0xFF44aaff),
    ExpeditionType.essenceDelve => const Color(0xFFaaff88),
    ExpeditionType.relicSearch  => const Color(0xFFff8833),
  };
}

extension ExpeditionDurationInfo on ExpeditionDuration {
  String get label => switch (this) {
    ExpeditionDuration.short  => '30 min',
    ExpeditionDuration.medium => '2 hr',
    ExpeditionDuration.long   => '8 hr',
  };
  int get ms => switch (this) {
    ExpeditionDuration.short  => 30 * 60 * 1000,
    ExpeditionDuration.medium => 2 * 60 * 60 * 1000,
    ExpeditionDuration.long   => 8 * 60 * 60 * 1000,
  };
  int get mult => switch (this) {
    ExpeditionDuration.short  => 1,
    ExpeditionDuration.medium => 4,
    ExpeditionDuration.long   => 14,
  };
}

class Expedition {
  const Expedition({
    required this.type,
    required this.duration,
    required this.startEpochMs,
  });

  final ExpeditionType type;
  final ExpeditionDuration duration;
  final int startEpochMs;

  bool get isComplete =>
      DateTime.now().millisecondsSinceEpoch >= startEpochMs + duration.ms;

  double get progress =>
      ((DateTime.now().millisecondsSinceEpoch - startEpochMs) / duration.ms)
          .clamp(0.0, 1.0);

  Duration get remaining {
    final ms = (startEpochMs + duration.ms) -
        DateTime.now().millisecondsSinceEpoch;
    return Duration(milliseconds: ms.clamp(0, duration.ms));
  }

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'duration': duration.name,
    'startEpochMs': startEpochMs,
  };

  factory Expedition.fromJson(Map<String, dynamic> json) => Expedition(
    type: ExpeditionType.values.byName(json['type'] as String),
    duration: ExpeditionDuration.values.byName(json['duration'] as String),
    startEpochMs: json['startEpochMs'] as int,
  );
}
