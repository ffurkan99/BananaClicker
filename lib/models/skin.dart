class Skin {
  final String id;
  final String name;
  final double cost;
  final String imagePath;
  final String bonusDescription;
  final bool isUnlocked;
  final bool isEquipped;
  final String mapId;

  Skin({
    required this.id,
    required this.name,
    required this.cost,
    required this.imagePath,
    required this.bonusDescription,
    required this.mapId,
    this.isUnlocked = false,
    this.isEquipped = false,
  });

  Skin copyWith({
    bool? isUnlocked,
    bool? isEquipped,
  }) {
    return Skin(
      id: id,
      name: name,
      cost: cost,
      imagePath: imagePath,
      bonusDescription: bonusDescription,
      mapId: mapId,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isEquipped: isEquipped ?? this.isEquipped,
    );
  }
}
