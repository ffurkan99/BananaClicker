import 'dart:math';

class Upgrade {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final String category; // Click, Idle, Combo, Critical, Golden, Offline, Special
  final double fixedCost;
  final int currentLevel;
  final int maxLevel;
  final String effectType;
  final double effectValue;
  final bool isUnlocked;
  final bool isRepeatable;

  Upgrade({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.category,
    required this.fixedCost,
    this.currentLevel = 0,
    required this.maxLevel,
    required this.effectType,
    required this.effectValue,
    this.isUnlocked = true,
    required this.isRepeatable,
  });

  // Getter compatibility with previous code references
  int get level => currentLevel;
  double get currentCost => getCost(1.0);

  double getCost(double worldCostMultiplier) {
    if (isRepeatable) {
      return (fixedCost * pow(1.15, currentLevel) * worldCostMultiplier).floorToDouble();
    }
    return (fixedCost * worldCostMultiplier).floorToDouble();
  }

  Upgrade copyWith({
    int? currentLevel,
    bool? isUnlocked,
  }) {
    return Upgrade(
      id: id,
      name: name,
      description: description,
      imagePath: imagePath,
      category: category,
      fixedCost: fixedCost,
      currentLevel: currentLevel ?? this.currentLevel,
      maxLevel: maxLevel,
      effectType: effectType,
      effectValue: effectValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isRepeatable: isRepeatable,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'level': currentLevel,
    };
  }

  factory Upgrade.fromMap(Map<String, dynamic> map, Upgrade base) {
    return base.copyWith(
      currentLevel: map['level'] as int? ?? 0,
    );
  }
}
