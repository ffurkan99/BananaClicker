class MapProgression {
  final int worldIndex; // 1, 2, 3, 4, 5, 6
  final String id; // jungle, banana_village, volcano_island, ancient_temple, cloud_jungle, golden_kingdom
  final String name;
  final double unlockTarget; // total bananas needed in this run to unlock next map
  final double worldIncomeMultiplier; // BPC & BPS multiplier
  final double worldCostMultiplier; // Cost multiplier for upgrades
  final double worldRewardMultiplier; // Golden/rain reward multiplier
  final int relicsReward; // Jungle Relics earned when leaving this map
  final String imagePath;

  MapProgression({
    required this.worldIndex,
    required this.id,
    required this.name,
    required this.unlockTarget,
    required this.worldIncomeMultiplier,
    required this.worldCostMultiplier,
    required this.worldRewardMultiplier,
    required this.relicsReward,
    required this.imagePath,
  });
}
