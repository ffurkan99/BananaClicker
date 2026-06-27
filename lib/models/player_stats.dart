class PlayerStats {
  final double totalBananas;
  final double bananasPerClick;
  final double bananasPerSecond;
  final int lastSavedTime;

  // Stats for quests and achievements
  final int questClicks;
  final double questBananasEarned;
  final int questUpgradesBought;
  final int questGoldenBananasCollected;
  final int questMaxComboReached;
  final int questCritsTriggered;

  // Skins inventory
  final Map<String, String> equippedMapSkins;
  final List<String> unlockedSkins;

  // Map backgrounds
  final String equippedMap;
  final List<String> unlockedMaps;

  // Achievements & quests completed
  final Set<String> claimedQuests;
  final Set<String> unlockedAchievements;

  // Monkey Level
  final int level;
  final double xp;

  // Prestige System
  final int prestigeLevel;
  final int goldenSeeds;

  // Skill Tree
  final List<String> unlockedSkills;

  // Period-specific counters for daily/weekly quest progress (reset each period)
  final int dailyClicks;
  final double dailyBananas;
  final int dailyGolden;
  final int dailyMaxCombo;
  final int dailyUpgrades;
  final int weeklyClicks;
  final double weeklyBananas;
  final int weeklyGolden;
  final int weeklyCrits;

  // Meta Progression (Jungle Relics & Meta Upgrades)
  final int jungleRelics;
  final int metaIncomeLevel;
  final int metaClickLevel;
  final int metaIdleLevel;
  final int metaGoldenLevel;
  final int metaComboLevel;

  // Constant base critical tap chance (5%)
  double get criticalChance => 0.05;

  PlayerStats({
    this.totalBananas = 0.0,
    this.bananasPerClick = 1.0,
    this.bananasPerSecond = 0.0,
    this.lastSavedTime = 0,
    this.questClicks = 0,
    this.questBananasEarned = 0.0,
    this.questUpgradesBought = 0,
    this.questGoldenBananasCollected = 0,
    this.questMaxComboReached = 1,
    this.questCritsTriggered = 0,
    this.equippedMapSkins = const {
      'jungle': 'jungle_default',
      'banana_village': 'banana_village_default',
      'volcano_island': 'volcano_island_default',
      'ancient_temple': 'ancient_temple_default',
      'cloud_jungle': 'cloud_jungle_default',
      'golden_kingdom': 'golden_kingdom_default',
    },
    this.unlockedSkins = const [
      'jungle_default',
      'banana_village_default',
      'volcano_island_default',
      'ancient_temple_default',
      'cloud_jungle_default',
      'golden_kingdom_default',
    ],
    this.equippedMap = 'jungle',
    this.unlockedMaps = const ['jungle'],
    this.claimedQuests = const {},
    this.unlockedAchievements = const {},
    this.level = 1,
    this.xp = 0.0,
    this.prestigeLevel = 0,
    this.goldenSeeds = 0,
    this.unlockedSkills = const [],
    this.dailyClicks = 0,
    this.dailyBananas = 0.0,
    this.dailyGolden = 0,
    this.dailyMaxCombo = 0,
    this.dailyUpgrades = 0,
    this.weeklyClicks = 0,
    this.weeklyBananas = 0.0,
    this.weeklyGolden = 0,
    this.weeklyCrits = 0,
    this.jungleRelics = 0,
    this.metaIncomeLevel = 0,
    this.metaClickLevel = 0,
    this.metaIdleLevel = 0,
    this.metaGoldenLevel = 0,
    this.metaComboLevel = 0,
  });

  PlayerStats copyWith({
    double? totalBananas,
    double? bananasPerClick,
    double? bananasPerSecond,
    int? lastSavedTime,
    int? questClicks,
    double? questBananasEarned,
    int? questUpgradesBought,
    int? questGoldenBananasCollected,
    int? questMaxComboReached,
    int? questCritsTriggered,
    Map<String, String>? equippedMapSkins,
    List<String>? unlockedSkins,
    String? equippedMap,
    List<String>? unlockedMaps,
    Set<String>? claimedQuests,
    Set<String>? unlockedAchievements,
    int? level,
    double? xp,
    int? prestigeLevel,
    int? goldenSeeds,
    List<String>? unlockedSkills,
    int? dailyClicks,
    double? dailyBananas,
    int? dailyGolden,
    int? dailyMaxCombo,
    int? dailyUpgrades,
    int? weeklyClicks,
    double? weeklyBananas,
    int? weeklyGolden,
    int? weeklyCrits,
    int? jungleRelics,
    int? metaIncomeLevel,
    int? metaClickLevel,
    int? metaIdleLevel,
    int? metaGoldenLevel,
    int? metaComboLevel,
  }) {
    return PlayerStats(
      totalBananas: totalBananas ?? this.totalBananas,
      bananasPerClick: bananasPerClick ?? this.bananasPerClick,
      bananasPerSecond: bananasPerSecond ?? this.bananasPerSecond,
      lastSavedTime: lastSavedTime ?? this.lastSavedTime,
      questClicks: questClicks ?? this.questClicks,
      questBananasEarned: questBananasEarned ?? this.questBananasEarned,
      questUpgradesBought: questUpgradesBought ?? this.questUpgradesBought,
      questGoldenBananasCollected: questGoldenBananasCollected ?? this.questGoldenBananasCollected,
      questMaxComboReached: questMaxComboReached ?? this.questMaxComboReached,
      questCritsTriggered: questCritsTriggered ?? this.questCritsTriggered,
      equippedMapSkins: equippedMapSkins ?? this.equippedMapSkins,
      unlockedSkins: unlockedSkins ?? this.unlockedSkins,
      equippedMap: equippedMap ?? this.equippedMap,
      unlockedMaps: unlockedMaps ?? this.unlockedMaps,
      claimedQuests: claimedQuests ?? this.claimedQuests,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      prestigeLevel: prestigeLevel ?? this.prestigeLevel,
      goldenSeeds: goldenSeeds ?? this.goldenSeeds,
      unlockedSkills: unlockedSkills ?? this.unlockedSkills,
      dailyClicks: dailyClicks ?? this.dailyClicks,
      dailyBananas: dailyBananas ?? this.dailyBananas,
      dailyGolden: dailyGolden ?? this.dailyGolden,
      dailyMaxCombo: dailyMaxCombo ?? this.dailyMaxCombo,
      dailyUpgrades: dailyUpgrades ?? this.dailyUpgrades,
      weeklyClicks: weeklyClicks ?? this.weeklyClicks,
      weeklyBananas: weeklyBananas ?? this.weeklyBananas,
      weeklyGolden: weeklyGolden ?? this.weeklyGolden,
      weeklyCrits: weeklyCrits ?? this.weeklyCrits,
      jungleRelics: jungleRelics ?? this.jungleRelics,
      metaIncomeLevel: metaIncomeLevel ?? this.metaIncomeLevel,
      metaClickLevel: metaClickLevel ?? this.metaClickLevel,
      metaIdleLevel: metaIdleLevel ?? this.metaIdleLevel,
      metaGoldenLevel: metaGoldenLevel ?? this.metaGoldenLevel,
      metaComboLevel: metaComboLevel ?? this.metaComboLevel,
    );
  }
}
