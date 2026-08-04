import 'package:flutter/material.dart';

enum DamageType {
  physical,
  fire,
  cold,
  lightning,
  poison,
  void_;

  String get label => switch (this) {
    DamageType.physical  => 'Physical',
    DamageType.fire      => 'Fire',
    DamageType.cold      => 'Cold',
    DamageType.lightning => 'Lightning',
    DamageType.poison    => 'Poison',
    DamageType.void_     => 'Void',
  };

  IconData get icon => switch (this) {
    DamageType.physical  => Icons.sports_mma,
    DamageType.fire      => Icons.local_fire_department,
    DamageType.cold      => Icons.ac_unit,
    DamageType.lightning => Icons.bolt,
    DamageType.poison    => Icons.science,
    DamageType.void_     => Icons.brightness_3,
  };

  String get emoji => switch (this) {
    DamageType.physical  => 'PHYS',
    DamageType.fire      => 'FIRE',
    DamageType.cold      => 'COLD',
    DamageType.lightning => 'LTNG',
    DamageType.poison    => 'POIS',
    DamageType.void_     => 'VOID',
  };

  Color get color => switch (this) {
    DamageType.physical  => const Color(0xFFE8E3D9),
    DamageType.fire      => const Color(0xFFFF6B35),
    DamageType.cold      => const Color(0xFF6CB4E4),
    DamageType.lightning => const Color(0xFFFFE14D),
    DamageType.poison    => const Color(0xFF7DCF6A),
    DamageType.void_     => const Color(0xFF9966FF),
  };

  /// Short tag appended to combat log hit entries.
  String get shortTag => switch (this) {
    DamageType.physical  => ' [P]',
    DamageType.fire      => ' [F]',
    DamageType.cold      => ' [C]',
    DamageType.lightning => ' [L]',
    DamageType.poison    => ' [X]',
    DamageType.void_     => ' [V]',
  };

  /// Stat label whose total drives hero resistance against this type.
  String get resistanceStat => switch (this) {
    DamageType.physical  => 'STR',
    DamageType.lightning => 'DEX',
    DamageType.poison    => 'CON',
    DamageType.void_     => 'INT',
    DamageType.cold      => 'WIS',
    DamageType.fire      => 'CHA',
  };

  static DamageType parse(String? s) =>
      DamageType.values.firstWhere((v) => v.name == s,
          orElse: () => DamageType.physical);
}
