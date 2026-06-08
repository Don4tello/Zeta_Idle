class Enemy {
  Enemy({
    required this.id,
    required this.name,
    required this.description,
    required this.maxHealth,
    required this.attack,
    required this.level,
    this.armorClass = 10,
    int? currentHealth,
  }) : currentHealth = currentHealth ?? maxHealth;

  final String id;
  final String name;
  final String description;
  final int maxHealth;
  final int attack;
  final int level;
  final int armorClass;
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
