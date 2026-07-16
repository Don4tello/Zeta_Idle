import 'damage_type.dart';

enum BossAbilityEffect { bonusDamage, dot, stun }

class BossAbility {
  const BossAbility({
    required this.id,
    required this.name,
    required this.emoji,
    required this.damageType,
    required this.effect,
    required this.value,
    this.dotRounds = 3,
    required this.cooldownRounds,
  });
  final String id;
  final String name;
  final String emoji;
  final DamageType damageType;
  final BossAbilityEffect effect;
  // damage effects: % of enemy.attack; stun effect: rounds to stun hero
  final int value;
  final int dotRounds;
  final int cooldownRounds;
}

class Enemy {
  Enemy({
    required this.id,
    required this.name,
    required this.description,
    required this.maxHealth,
    required this.attack,
    required this.level,
    this.armorClass = 0,
    this.attackType = DamageType.physical,
    this.resistances = const {},
    this.namedBoss = false,
    this.dodge = 0.0, // kept for save compat, no longer used in combat
    this.abilities = const [],
    int? currentHealth,
  }) : currentHealth = currentHealth ?? maxHealth;

  final String id;
  final String name;
  final String description;
  final int maxHealth;
  final int attack;
  final int level;
  final int armorClass;
  final DamageType attackType;
  final Map<DamageType, int> resistances;
  // True for hand-crafted unique campaign bosses — skips generic HP/ATK scaling.
  final bool namedBoss;
  // Dodge chance (0.0–1.0). Bosses always have 0. Used in hero attack roll.
  final double dodge;
  final List<BossAbility> abilities;
  int currentHealth;

  bool get isDefeated => currentHealth <= 0;

  void takeDamage(int amount) {
    currentHealth = (currentHealth - amount).clamp(0, maxHealth);
  }

  void heal() {
    currentHealth = maxHealth;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'maxHealth': maxHealth,
    'attack': attack,
    'level': level,
    'armorClass': armorClass,
    'currentHealth': currentHealth,
  };

  factory Enemy.fromJson(Map<String, dynamic> json) => Enemy(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    maxHealth: json['maxHealth'] as int,
    attack: json['attack'] as int,
    level: json['level'] as int,
    armorClass: (json['armorClass'] as int?) ?? 10,
    currentHealth: json['currentHealth'] as int,
  );
}
