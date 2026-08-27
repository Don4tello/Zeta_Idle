/// Permanent, account/character-wide multipliers earned by rebirthing. These
/// are pure meta-progression: they never reset when the player switches the
/// active tier and are folded into both player power and (partially) enemy
/// scaling so higher tiers stay meaningful.
///
/// Immutable value type — apply a rebirth with [afterRebirth] to get the next
/// snapshot, keeping the model side-effect free and easy to test.
class RebirthBuffs {
  const RebirthBuffs({
    this.damageMult = 1.0,
    this.healthMult = 1.0,
    this.goldMult = 1.0,
  });

  /// Permanent player damage multiplier (1.0 = no bonus).
  final double damageMult;

  /// Permanent player max-health multiplier.
  final double healthMult;

  /// Permanent gold/resource multiplier stacked on top of tier reward scaling.
  final double goldMult;

  /// A single scalar summarising how much stronger the player has become,
  /// used to scale enemies back up on higher tiers. 1.0 = baseline.
  double get powerFactor => (damageMult * healthMult);

  /// The buffs granted for reaching [newTier]. Each rebirth adds a flat +12%
  /// damage, +10% health and +15% gold (compounding).
  RebirthBuffs afterRebirth(int newTier) => RebirthBuffs(
        damageMult: damageMult * 1.12,
        healthMult: healthMult * 1.10,
        goldMult: goldMult * 1.15,
      );

  RebirthBuffs copyWith({double? damageMult, double? healthMult, double? goldMult}) =>
      RebirthBuffs(
        damageMult: damageMult ?? this.damageMult,
        healthMult: healthMult ?? this.healthMult,
        goldMult: goldMult ?? this.goldMult,
      );

  Map<String, dynamic> toJson() => {
        'damageMult': damageMult,
        'healthMult': healthMult,
        'goldMult': goldMult,
      };

  factory RebirthBuffs.fromJson(Map<String, dynamic> j) => RebirthBuffs(
        damageMult: (j['damageMult'] as num?)?.toDouble() ?? 1.0,
        healthMult: (j['healthMult'] as num?)?.toDouble() ?? 1.0,
        goldMult: (j['goldMult'] as num?)?.toDouble() ?? 1.0,
      );
}
