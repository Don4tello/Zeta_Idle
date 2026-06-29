import 'dart:math';

class FlashEvent {
  const FlashEvent({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.bonus,
    required this.bonusType,
    this.durationMinutes = 120,
  });

  final String id, name, icon, description, bonusType;
  final double bonus;
  final int durationMinutes;

  static const catalog = [
    FlashEvent(id: 'double_gold', name: 'Gold Rush', icon: '💰', description: 'All gold gains doubled!', bonus: 2.0, bonusType: 'gold'),
    FlashEvent(id: 'double_xp', name: 'XP Surge', icon: '⚡', description: 'All XP gains doubled!', bonus: 2.0, bonusType: 'xp'),
    FlashEvent(id: 'shard_storm', name: 'Shard Storm', icon: '◆', description: 'Shard drops tripled!', bonus: 3.0, bonusType: 'shards'),
    FlashEvent(id: 'boss_invasion', name: 'Boss Invasion', icon: '💀', description: 'Boss Rush gives 3× mythril!', bonus: 3.0, bonusType: 'mythril'),
    FlashEvent(id: 'echo_resonance', name: 'Echo Resonance', icon: '🔊', description: 'Gauntlet echoes doubled!', bonus: 2.0, bonusType: 'echoes'),
    FlashEvent(id: 'crystal_rain', name: 'Crystal Rain', icon: '💎', description: '+50% crystal drops everywhere!', bonus: 1.5, bonusType: 'crystals'),
    FlashEvent(id: 'forge_frenzy', name: 'Forge Frenzy', icon: '🔨', description: 'Reforging costs halved!', bonus: 0.5, bonusType: 'forgeCost'),
    FlashEvent(id: 'arena_fury', name: 'Arena Fury', icon: '⚔', description: 'PvP gives 3× gem shards!', bonus: 3.0, bonusType: 'gemShards'),
  ];

  static FlashEvent? checkForEvent(int hourOfDay, int dayOfWeek) {
    // Events fire at specific windows — deterministic per day
    final seed = dayOfWeek * 100 + hourOfDay;
    final rng = Random(seed);
    if (rng.nextInt(6) != 0) return null; // ~17% chance per hour
    return catalog[rng.nextInt(catalog.length)];
  }
}

class ActiveFlashEvent {
  ActiveFlashEvent({
    required this.event,
    required this.startEpoch,
  });

  final FlashEvent event;
  final int startEpoch;

  int get endEpoch => startEpoch + event.durationMinutes * 60 * 1000;
  bool get isActive => DateTime.now().millisecondsSinceEpoch < endEpoch;
  int get minutesRemaining => ((endEpoch - DateTime.now().millisecondsSinceEpoch) / 60000).ceil().clamp(0, 9999);

  Map<String, dynamic> toJson() => {
    'eventId': event.id,
    'startEpoch': startEpoch,
  };

  static ActiveFlashEvent? fromJson(Map<String, dynamic> json) {
    final id = json['eventId'] as String?;
    if (id == null) return null;
    final event = FlashEvent.catalog.where((e) => e.id == id).firstOrNull;
    if (event == null) return null;
    return ActiveFlashEvent(
      event: event,
      startEpoch: json['startEpoch'] as int,
    );
  }
}
