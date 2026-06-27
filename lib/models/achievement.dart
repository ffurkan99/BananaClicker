class Achievement {
  final String id;
  final String title;
  final String description;
  final bool unlocked;
  final int? unlockedAt;
  final String category; // 'tapping', 'economy', 'combo', 'critical', 'golden', 'map', 'collection', 'rebirth'

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    this.unlocked = false,
    this.unlockedAt,
    required this.category,
  });

  Achievement copyWith({
    bool? unlocked,
    int? unlockedAt,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      category: category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'unlocked': unlocked,
      'unlockedAt': unlockedAt,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map, Achievement base) {
    return base.copyWith(
      unlocked: map['unlocked'] as bool? ?? false,
      unlockedAt: map['unlockedAt'] as int?,
    );
  }
}
