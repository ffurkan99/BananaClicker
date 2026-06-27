class SkillNode {
  final String id;
  final String name;
  final String branch;
  final String description;
  final int cost;
  final bool isUnlocked;

  SkillNode({
    required this.id,
    required this.name,
    required this.branch,
    required this.description,
    required this.cost,
    this.isUnlocked = false,
  });

  SkillNode copyWith({
    bool? isUnlocked,
  }) {
    return SkillNode(
      id: id,
      name: name,
      branch: branch,
      description: description,
      cost: cost,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}
