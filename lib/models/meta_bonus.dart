class MetaBonus {
  final String id;
  final String name;
  final String description;
  final int baseCost;
  final int currentLevel;
  final int maxLevel;
  final String effectType; // INCOME, CLICK, IDLE, GOLDEN, COMBO
  final double effectValue; // multiplier per level

  MetaBonus({
    required this.id,
    required this.name,
    required this.description,
    required this.baseCost,
    required this.currentLevel,
    required this.maxLevel,
    required this.effectType,
    required this.effectValue,
  });

  int get nextCost {
    return baseCost * (currentLevel + 1);
  }

  MetaBonus copyWith({
    int? currentLevel,
  }) {
    return MetaBonus(
      id: id,
      name: name,
      description: description,
      baseCost: baseCost,
      currentLevel: currentLevel ?? this.currentLevel,
      maxLevel: maxLevel,
      effectType: effectType,
      effectValue: effectValue,
    );
  }
}
