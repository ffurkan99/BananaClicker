class Quest {
  final String id;
  final String title;
  final String description;
  final double targetValue;
  final double reward;
  final String type; // 'clicks', 'bananas', 'upgrades', 'golden', 'combo'
  final bool claimed;
  final bool completed;
  final double progress; // current progress value
  final String layer; // 'main', 'daily', 'weekly', 'map', 'milestone'

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.reward,
    required this.type,
    this.claimed = false,
    this.completed = false,
    this.progress = 0.0,
    required this.layer,
  });

  Quest copyWith({
    bool? claimed,
    bool? completed,
    double? progress,
  }) {
    return Quest(
      id: id,
      title: title,
      description: description,
      targetValue: targetValue,
      reward: reward,
      type: type,
      claimed: claimed ?? this.claimed,
      completed: completed ?? this.completed,
      progress: progress ?? this.progress,
      layer: layer,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'claimed': claimed,
    };
  }
}
