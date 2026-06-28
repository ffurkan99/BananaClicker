import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/player_stats.dart';
import '../models/upgrade.dart';
import '../models/quest.dart';
import '../models/achievement.dart';
import '../models/skin.dart';
import '../models/map_theme.dart';
import '../models/skill_node.dart';
import '../models/floating_effect.dart';
import '../models/map_progression.dart';
import '../models/meta_bonus.dart';

import '../services/save_service.dart';
import '../services/offline_earnings_service.dart';
import '../services/audio_service.dart';

class FallingBanana {
  final int id;
  final double x;
  final double speed;
  double y;

  FallingBanana({
    required this.id,
    required this.x,
    required this.speed,
    this.y = -50.0,
  });
}

class TapResult {
  final double earned;
  final bool isCritical;
  final int combo;

  TapResult({
    required this.earned,
    required this.isCritical,
    required this.combo,
  });
}

class GoldenBananaResult {
  final String text;
  final bool startsBananaRain;

  GoldenBananaResult({
    required this.text,
    this.startsBananaRain = false,
  });
}


class GameController extends ChangeNotifier {
  final SaveService _saveService = SaveService();
  final OfflineEarningsService _offlineService = OfflineEarningsService();
  final AudioService _audioService = AudioService();

  final Random _rng = Random();
  int _lastQuestCheckTimestamp = 0;

  // ---------- Game State ----------
  PlayerStats _stats = PlayerStats();
  PlayerStats get stats => _stats;

  List<Upgrade> _upgrades = [];
  List<Upgrade> get upgrades => _upgrades;

  List<Quest> _quests = [];
  List<Quest> get quests => _quests;

  List<Achievement> _achievements = [];
  List<Achievement> get achievements => _achievements;

  List<Skin> _skins = [];
  List<Skin> get skins => _skins;

  List<MapTheme> _maps = [];
  List<MapTheme> get maps => _maps;

  String get selectedMapId => _stats.equippedMap;
  MapTheme get selectedMapTheme => _maps.firstWhere(
    (m) => m.id == _stats.equippedMap,
    orElse: () => _maps.first,
  );

  void selectMap(String mapId) {
    equipMap(mapId);
  }

  void saveSelectedMap() {
    saveGame();
  }

  void loadSelectedMap() {
    // Loaded in initGame()
  }

  List<SkillNode> _skills = [];
  List<SkillNode> get skills => _skills;

  // Floating Effects (Tap values) - Deprecated, now handled locally in UI
  List<FloatingEffect> get floatingEffects => const [];

  // Falling Bananas (Mini-event) - Deprecated, now handled locally in UI
  List<FallingBanana> get fallingBananas => const [];
  bool _isBananaRainActive = false;
  bool get isBananaRainActive => _isBananaRainActive;

  // Combo Systems
  int _comboCount = 1;
  int get comboCount => _comboCount;

  double _comboProgress = 0.0;
  double get comboProgress => _comboProgress;
  int _lastTapTimestamp = 0;

  // Golden Banana Event States
  bool _showGoldenBanana = false;
  bool get showGoldenBanana => _showGoldenBanana;

  double _goldenBananaX = 0.5;
  double get goldenBananaX => _goldenBananaX;

  double _goldenBananaY = 0.5;
  double get goldenBananaY => _goldenBananaY;

  // Golden multipliers (30s durations)
  int _goldenTapExpiresAt = 0;
  int _goldenIdleExpiresAt = 0;

  bool get isGoldenTapActive =>
      _goldenTapExpiresAt > DateTime.now().millisecondsSinceEpoch;
  bool get isGoldenIdleActive =>
      _goldenIdleExpiresAt > DateTime.now().millisecondsSinceEpoch;

  String get activeSkinIdForCurrentMap =>
      _stats.equippedMapSkins[_stats.equippedMap] ??
      '${_stats.equippedMap}_default';

  String getEquippedSkinPathForMap(String mapId) {
    final skinId = _stats.equippedMapSkins[mapId] ?? '${mapId}_default';
    final skin = _skins.firstWhere(
      (s) => s.id == skinId,
      orElse: () {
        return Skin(
          id: '${mapId}_default',
          name: 'Default',
          cost: 0.0,
          imagePath: 'assets/images/monkeys/monkeydefault/${mapId}_monkey.png',
          bonusDescription: 'Default Monkey',
          mapId: mapId,
        );
      },
    );
    return skin.imagePath;
  }

  int get goldenTapRemainingSeconds {
    final diff = _goldenTapExpiresAt - DateTime.now().millisecondsSinceEpoch;
    return diff > 0 ? (diff / 1000).ceil() : 0;
  }

  int get goldenIdleRemainingSeconds {
    final diff = _goldenIdleExpiresAt - DateTime.now().millisecondsSinceEpoch;
    return diff > 0 ? (diff / 1000).ceil() : 0;
  }

  // Offline earnings overlay
  bool _showOfflineDialog = false;
  bool get showOfflineDialog => _showOfflineDialog;

  double _pendingOfflineEarnings = 0.0;
  double get pendingOfflineEarnings => _pendingOfflineEarnings;

  double _offlineTimePassedHours = 0.0;
  double get offlineTimePassedHours => _offlineTimePassedHours;

  double _offlineTimeClampedHours = 0.0;
  double get offlineTimeClampedHours => _offlineTimeClampedHours;

  // Floating notifications for levels & achievements
  String? _achievementUnlockNotification;
  String? get achievementUnlockNotification => _achievementUnlockNotification;

  String? _levelUpNotification;
  String? get levelUpNotification => _levelUpNotification;

  // ---------- Timers ----------
  Timer? _passiveIncomeTimer;
  Timer? _autoSaveTimer;
  Timer? _comboDecayTimer;
  Timer? _goldenBananaSpawnTimer;
  Timer? _goldenBananaTimeoutTimer;

  // ---------- Default Content Static Blueprints ----------
  final List<MapProgression> mapProgressions = [
    MapProgression(
      worldIndex: 1,
      id: 'jungle',
      name: 'Jungle',
      unlockTarget: 10000.0,
      worldIncomeMultiplier: 1.0,
      worldCostMultiplier: 1.0,
      worldRewardMultiplier: 1.0,
      relicsReward: 5,
      imagePath: 'assets/images/backgrounds/jungle.png',
    ),
    MapProgression(
      worldIndex: 2,
      id: 'banana_village',
      name: 'Banana Village',
      unlockTarget: 100000.0,
      worldIncomeMultiplier: 4.0,
      worldCostMultiplier: 2.0,
      worldRewardMultiplier: 3.0,
      relicsReward: 15,
      imagePath: 'assets/images/backgrounds/bananajungle.png',
    ),
    MapProgression(
      worldIndex: 3,
      id: 'volcano_island',
      name: 'Volcano Island',
      unlockTarget: 1000000.0,
      worldIncomeMultiplier: 12.0,
      worldCostMultiplier: 5.0,
      worldRewardMultiplier: 10.0,
      relicsReward: 50,
      imagePath: 'assets/images/backgrounds/volcanoisland.png',
    ),
    MapProgression(
      worldIndex: 4,
      id: 'ancient_temple',
      name: 'Ancient Temple',
      unlockTarget: 10000000.0,
      worldIncomeMultiplier: 35.0,
      worldCostMultiplier: 12.0,
      worldRewardMultiplier: 30.0,
      relicsReward: 200,
      imagePath: 'assets/images/backgrounds/ancienttemple.png',
    ),
    MapProgression(
      worldIndex: 5,
      id: 'cloud_jungle',
      name: 'Cloud Jungle',
      unlockTarget: 100000000.0,
      worldIncomeMultiplier: 100.0,
      worldCostMultiplier: 30.0,
      worldRewardMultiplier: 100.0,
      relicsReward: 800,
      imagePath: 'assets/images/backgrounds/cloudjungle.png',
    ),
    MapProgression(
      worldIndex: 6,
      id: 'golden_kingdom',
      name: 'Golden Kingdom',
      unlockTarget: 1000000000.0,
      worldIncomeMultiplier: 300.0,
      worldCostMultiplier: 80.0,
      worldRewardMultiplier: 500.0,
      relicsReward: 4000,
      imagePath: 'assets/images/backgrounds/goldenbananakingdom.png',
    ),
  ];

  MapProgression get currentMapProgression {
    return mapProgressions.firstWhere(
      (m) => m.id == _stats.equippedMap,
      orElse: () => mapProgressions.first,
    );
  }

  List<MetaBonus> get metaBonuses {
    return [
      MetaBonus(
        id: 'income',
        name: 'Golden Fertilizer',
        description: '+10% total banana income per level',
        baseCost: 5,
        currentLevel: _stats.metaIncomeLevel,
        maxLevel: 50,
        effectType: 'INCOME',
        effectValue: 0.10,
      ),
      MetaBonus(
        id: 'click',
        name: 'Obsidian Grips',
        description: '+10% click power per level',
        baseCost: 3,
        currentLevel: _stats.metaClickLevel,
        maxLevel: 50,
        effectType: 'CLICK',
        effectValue: 0.10,
      ),
      MetaBonus(
        id: 'idle',
        name: 'Lazy Sloth Helpers',
        description: '+10% helper idle income per level',
        baseCost: 3,
        currentLevel: _stats.metaIdleLevel,
        maxLevel: 50,
        effectType: 'IDLE',
        effectValue: 0.10,
      ),
      MetaBonus(
        id: 'golden',
        name: 'Shiny Totem',
        description: '+15% golden banana reward per level',
        baseCost: 10,
        currentLevel: _stats.metaGoldenLevel,
        maxLevel: 50,
        effectType: 'GOLDEN',
        effectValue: 0.15,
      ),
      MetaBonus(
        id: 'combo',
        name: 'Rhythm Drums',
        description: '+15% combo effectiveness per level',
        baseCost: 8,
        currentLevel: _stats.metaComboLevel,
        maxLevel: 50,
        effectType: 'COMBO',
        effectValue: 0.15,
      ),
    ];
  }

  bool buyMetaBonus(String id) {
    final list = metaBonuses;
    final bonus = list.firstWhere((b) => b.id == id);
    if (bonus.currentLevel >= bonus.maxLevel) return false;
    final cost = bonus.nextCost;
    if (_stats.jungleRelics < cost) return false;

    _audioService.playUpgrade();

    int newIncome = _stats.metaIncomeLevel;
    int newClick = _stats.metaClickLevel;
    int newIdle = _stats.metaIdleLevel;
    int newGolden = _stats.metaGoldenLevel;
    int newCombo = _stats.metaComboLevel;

    if (id == 'income')
      newIncome++;
    else if (id == 'click')
      newClick++;
    else if (id == 'idle')
      newIdle++;
    else if (id == 'golden')
      newGolden++;
    else if (id == 'combo')
      newCombo++;

    _stats = _stats.copyWith(
      jungleRelics: _stats.jungleRelics - cost,
      metaIncomeLevel: newIncome,
      metaClickLevel: newClick,
      metaIdleLevel: newIdle,
      metaGoldenLevel: newGolden,
      metaComboLevel: newCombo,
    );

    _stats = _stats.copyWith(
      bananasPerClick: calculateCurrentBpc(),
      bananasPerSecond: calculateCurrentBps(),
    );

    notifyListeners();
    saveGame();
    return true;
  }

  bool travelToNextMap() {
    final nextIndex = currentMapProgression.worldIndex + 1;
    if (nextIndex > mapProgressions.length) return false;

    if (_stats.totalBananas < currentMapProgression.unlockTarget) return false;

    _audioService.playLevelUp();

    final nextMap = mapProgressions.firstWhere(
      (m) => m.worldIndex == nextIndex,
    );
    final relicsEarned = currentMapProgression.relicsReward;
    final newUnlockedMaps = Set<String>.from(_stats.unlockedMaps)
      ..add(nextMap.id);

    _stats = PlayerStats(
      totalBananas: 0.0,
      bananasPerClick: 1.0,
      bananasPerSecond: 0.0,
      lastSavedTime: DateTime.now().millisecondsSinceEpoch,
      questClicks: _stats.questClicks,
      questBananasEarned: _stats.questBananasEarned,
      questUpgradesBought: _stats.questUpgradesBought,
      questGoldenBananasCollected: _stats.questGoldenBananasCollected,
      questMaxComboReached: _stats.questMaxComboReached,
      equippedMapSkins: _stats.equippedMapSkins,
      unlockedSkins: _stats.unlockedSkins,
      equippedMap: nextMap.id,
      unlockedMaps: newUnlockedMaps.toList(),
      claimedQuests: _stats.claimedQuests,
      unlockedAchievements: _stats.unlockedAchievements,
      level: _stats.level,
      xp: _stats.xp,
      prestigeLevel: _stats.prestigeLevel,
      goldenSeeds: _stats.goldenSeeds,
      unlockedSkills: _stats.unlockedSkills,
      jungleRelics: _stats.jungleRelics + relicsEarned,
      metaIncomeLevel: _stats.metaIncomeLevel,
      metaClickLevel: _stats.metaClickLevel,
      metaIdleLevel: _stats.metaIdleLevel,
      metaGoldenLevel: _stats.metaGoldenLevel,
      metaComboLevel: _stats.metaComboLevel,
    );

    _upgrades = _baseUpgrades.map((u) => u.copyWith(currentLevel: 0)).toList();

    _stats = _stats.copyWith(
      bananasPerClick: calculateCurrentBpc(),
      bananasPerSecond: calculateCurrentBps(),
    );

    _comboCount = 1;
    _comboProgress = 0.0;

    _checkQuests();
    _checkAchievements();
    notifyListeners();
    saveGame();
    return true;
  }

  final List<Upgrade> _baseUpgrades = [
    Upgrade(
      id: 'banana_boost',
      name: 'Banana Boost',
      description: '+1 banana per click per level',
      imagePath: 'assets/images/icons/banana_boost.png',
      category: 'Click',
      fixedCost: 50.0,
      maxLevel: 9999,
      effectType: 'ADD_BPC',
      effectValue: 1.0,
      isRepeatable: true,
    ),
    Upgrade(
      id: 'soft_gloves',
      name: 'Soft Banana Gloves',
      description: '+2 banana per click per level',
      imagePath: 'assets/images/icons/upgrade_arrow.png',
      category: 'Click',
      fixedCost: 75.0,
      maxLevel: 9999,
      effectType: 'ADD_BPC',
      effectValue: 2.0,
      isRepeatable: true,
    ),
    Upgrade(
      id: 'strong_fingers',
      name: 'Strong Fingers',
      description: '+3 banana per click per level',
      imagePath: 'assets/images/icons/banana_boost.png',
      category: 'Click',
      fixedCost: 120.0,
      maxLevel: 9999,
      effectType: 'ADD_BPC',
      effectValue: 3.0,
      isRepeatable: true,
    ),
    Upgrade(
      id: 'tiny_basket',
      name: 'Tiny Banana Basket',
      description: '+4 banana per click per level',
      imagePath: 'assets/images/icons/shop_basket.png',
      category: 'Click',
      fixedCost: 180.0,
      maxLevel: 9999,
      effectType: 'ADD_BPC',
      effectValue: 4.0,
      isRepeatable: true,
    ),
    Upgrade(
      id: 'baby_monkey',
      name: 'Baby Monkey Crew',
      description: '+3 bananas per second per level',
      imagePath: 'assets/images/icons/monkey_helper.png',
      category: 'Idle',
      fixedCost: 250.0,
      maxLevel: 9999,
      effectType: 'ADD_BPS',
      effectValue: 3.0,
      isRepeatable: true,
    ),
    Upgrade(
      id: 'monkey_helper',
      name: 'Monkey Helper',
      description: '+5 bananas per second per level',
      imagePath: 'assets/images/icons/monkey_helper.png',
      category: 'Idle',
      fixedCost: 250.0,
      maxLevel: 9999,
      effectType: 'ADD_BPS',
      effectValue: 5.0,
      isRepeatable: true,
    ),
    Upgrade(
      id: 'banana_slingshot',
      name: 'Banana Slingshot',
      description: '+6 banana per click per level',
      imagePath: 'assets/images/icons/upgrade_arrow.png',
      category: 'Click',
      fixedCost: 350.0,
      maxLevel: 9999,
      effectType: 'ADD_BPC',
      effectValue: 6.0,
      isRepeatable: true,
    ),
    Upgrade(
      id: 'golden_banana',
      name: 'Golden Banana',
      description: '+10% golden reward and +1s duration per level',
      imagePath: 'assets/images/icons/golden_banana.png',
      category: 'Golden',
      fixedCost: 500.0,
      maxLevel: 10,
      effectType: 'GOLDEN_BOOST',
      effectValue: 0.10,
      isRepeatable: false,
    ),
    Upgrade(
      id: 'jungle_drums',
      name: 'Jungle Drums',
      description: 'Combo reset time +0.2 seconds per level',
      imagePath: 'assets/images/icons/palm.png',
      category: 'Combo',
      fixedCost: 500.0,
      maxLevel: 5,
      effectType: 'COMBO_TIME',
      effectValue: 0.2,
      isRepeatable: false,
    ),
    Upgrade(
      id: 'banana_tree',
      name: 'Banana Tree',
      description: '+10 bananas per second per level',
      imagePath: 'assets/images/icons/palm.png',
      category: 'Idle',
      fixedCost: 750.0,
      maxLevel: 9999,
      effectType: 'ADD_BPS',
      effectValue: 10.0,
      isRepeatable: true,
    ),
    Upgrade(
      id: 'jungle_basket',
      name: 'Jungle Basket',
      description: '+10% offline earnings per level',
      imagePath: 'assets/images/icons/jungle_basket.png',
      category: 'Offline',
      fixedCost: 750.0,
      maxLevel: 10,
      effectType: 'OFFLINE_EARN',
      effectValue: 0.10,
      isRepeatable: false,
    ),
    Upgrade(
      id: 'lucky_peel',
      name: 'Lucky Peel',
      description: '+1% critical chance per level',
      imagePath: 'assets/images/icons/banana.png',
      category: 'Critical',
      fixedCost: 1000.0,
      maxLevel: 5,
      effectType: 'CRIT_CHANCE',
      effectValue: 0.01,
      isRepeatable: false,
    ),
    Upgrade(
      id: 'coconut_clicker',
      name: 'Coconut Clicker',
      description: '+15 banana per click per level',
      imagePath: 'assets/images/icons/banana_boost.png',
      category: 'Click',
      fixedCost: 1500.0,
      maxLevel: 9999,
      effectType: 'ADD_BPC',
      effectValue: 15.0,
      isRepeatable: true,
    ),
    Upgrade(
      id: 'parrot_scout',
      name: 'Parrot Scout',
      description: 'Golden banana interval -2 seconds per level',
      imagePath: 'assets/images/icons/trophy.png',
      category: 'Golden',
      fixedCost: 2000.0,
      maxLevel: 5,
      effectType: 'GOLDEN_INTERVAL',
      effectValue: 2.0,
      isRepeatable: false,
    ),
    Upgrade(
      id: 'mini_farm',
      name: 'Mini Banana Farm',
      description: '+35 bananas per second per level',
      imagePath: 'assets/images/icons/jungle_basket.png',
      category: 'Idle',
      fixedCost: 3000.0,
      maxLevel: 9999,
      effectType: 'ADD_BPS',
      effectValue: 35.0,
      isRepeatable: true,
    ),
    Upgrade(
      id: 'crit_spark',
      name: 'Critical Spark',
      description: 'Critical multiplier +0.25x per level',
      imagePath: 'assets/images/icons/golden_banana.png',
      category: 'Critical',
      fixedCost: 4500.0,
      maxLevel: 5,
      effectType: 'CRIT_MULT',
      effectValue: 0.25,
      isRepeatable: false,
    ),
    Upgrade(
      id: 'monkey_trainer',
      name: 'Monkey Trainer',
      description: '+5% helper income per level',
      imagePath: 'assets/images/icons/monkey_helper.png',
      category: 'Idle',
      fixedCost: 6500.0,
      maxLevel: 8,
      effectType: 'HELPER_BOOST',
      effectValue: 0.05,
      isRepeatable: false,
    ),
    Upgrade(
      id: 'golden_basket',
      name: 'Golden Basket',
      description: '+15% offline earnings per level',
      imagePath: 'assets/images/icons/shop_basket.png',
      category: 'Offline',
      fixedCost: 8000.0,
      maxLevel: 8,
      effectType: 'OFFLINE_EARN',
      effectValue: 0.15,
      isRepeatable: false,
    ),
    Upgrade(
      id: 'banana_cart',
      name: 'Banana Cart',
      description: '+120 bananas per second per level',
      imagePath: 'assets/images/icons/shop_basket.png',
      category: 'Idle',
      fixedCost: 12000.0,
      maxLevel: 9999,
      effectType: 'ADD_BPS',
      effectValue: 120.0,
      isRepeatable: true,
    ),
    Upgrade(
      id: 'jungle_market',
      name: 'Jungle Market',
      description: '+10% all banana income per level',
      imagePath: 'assets/images/icons/coin.png',
      category: 'Special',
      fixedCost: 18000.0,
      maxLevel: 8,
      effectType: 'GLOBAL_MULT',
      effectValue: 0.10,
      isRepeatable: false,
    ),
    Upgrade(
      id: 'rain_cloud',
      name: 'Banana Rain Cloud',
      description: 'Banana rain reward +20% per level',
      imagePath: 'assets/images/icons/upgrade_arrow.png',
      category: 'Special',
      fixedCost: 25000.0,
      maxLevel: 5,
      effectType: 'RAIN_BOOST',
      effectValue: 0.20,
      isRepeatable: false,
    ),
    Upgrade(
      id: 'golden_charm',
      name: 'Golden Charm',
      description: 'Golden banana reward +25% per level',
      imagePath: 'assets/images/icons/golden_banana.png',
      category: 'Golden',
      fixedCost: 35000.0,
      maxLevel: 5,
      effectType: 'GOLDEN_REWARD',
      effectValue: 0.25,
      isRepeatable: false,
    ),
    Upgrade(
      id: 'gorilla_guard',
      name: 'Gorilla Guard',
      description: '+500 bananas per second per level',
      imagePath: 'assets/images/icons/monkey_helper.png',
      category: 'Idle',
      fixedCost: 50000.0,
      maxLevel: 9999,
      effectType: 'ADD_BPS',
      effectValue: 500.0,
      isRepeatable: true,
    ),
    Upgrade(
      id: 'temple_relic',
      name: 'Temple Relic',
      description: '+20% click power per level',
      imagePath: 'assets/images/icons/trophy.png',
      category: 'Click',
      fixedCost: 75000.0,
      maxLevel: 5,
      effectType: 'CLICK_BOOST',
      effectValue: 0.20,
      isRepeatable: false,
    ),
    Upgrade(
      id: 'mystic_vine',
      name: 'Mystic Vine',
      description: 'Combo bonus +10% per level',
      imagePath: 'assets/images/icons/palm.png',
      category: 'Combo',
      fixedCost: 100000.0,
      maxLevel: 5,
      effectType: 'COMBO_BOOST',
      effectValue: 0.10,
      isRepeatable: false,
    ),
    Upgrade(
      id: 'banana_workshop',
      name: 'Banana Workshop',
      description: '+1500 bananas per second per level',
      imagePath: 'assets/images/icons/shop_basket.png',
      category: 'Idle',
      fixedCost: 150000.0,
      maxLevel: 9999,
      effectType: 'ADD_BPS',
      effectValue: 1500.0,
      isRepeatable: true,
    ),
    Upgrade(
      id: 'jungle_bank',
      name: 'Jungle Bank',
      description: 'Offline earnings cap +1 hour per level',
      imagePath: 'assets/images/icons/coin.png',
      category: 'Offline',
      fixedCost: 250000.0,
      maxLevel: 5,
      effectType: 'OFFLINE_CAP',
      effectValue: 1.0,
      isRepeatable: false,
    ),
    Upgrade(
      id: 'royal_crown',
      name: 'Royal Banana Crown',
      description: '+25% all income per level',
      imagePath: 'assets/images/icons/trophy.png',
      category: 'Special',
      fixedCost: 400000.0,
      maxLevel: 5,
      effectType: 'GLOBAL_MULT',
      effectValue: 0.25,
      isRepeatable: false,
    ),
    Upgrade(
      id: 'wizard_staff',
      name: 'Wizard Banana Staff',
      description: 'Golden banana duration +2 seconds per level',
      imagePath: 'assets/images/icons/upgrade_arrow.png',
      category: 'Golden',
      fixedCost: 650000.0,
      maxLevel: 5,
      effectType: 'GOLDEN_DUR',
      effectValue: 2.0,
      isRepeatable: false,
    ),
    Upgrade(
      id: 'volcano_forge',
      name: 'Volcano Banana Forge',
      description: '+10000 bananas per second per level',
      imagePath: 'assets/images/icons/palm.png',
      category: 'Idle',
      fixedCost: 1000000.0,
      maxLevel: 9999,
      effectType: 'ADD_BPS',
      effectValue: 10000.0,
      isRepeatable: true,
    ),
    Upgrade(
      id: 'cloud_crew',
      name: 'Cloud Monkey Crew',
      description: '+15% helper income per level',
      imagePath: 'assets/images/icons/monkey_helper.png',
      category: 'Idle',
      fixedCost: 1500000.0,
      maxLevel: 8,
      effectType: 'HELPER_BOOST',
      effectValue: 0.15,
      isRepeatable: false,
    ),
    Upgrade(
      id: 'ancient_idol',
      name: 'Ancient Banana Idol',
      description: '+50% critical reward per level',
      imagePath: 'assets/images/icons/trophy.png',
      category: 'Critical',
      fixedCost: 2500000.0,
      maxLevel: 5,
      effectType: 'CRIT_REWARD',
      effectValue: 0.50,
      isRepeatable: false,
    ),
    Upgrade(
      id: 'golden_gate',
      name: 'Golden Kingdom Gate',
      description: '+50% all income per level',
      imagePath: 'assets/images/icons/golden_banana.png',
      category: 'Special',
      fixedCost: 5000000.0,
      maxLevel: 5,
      effectType: 'GLOBAL_MULT',
      effectValue: 0.50,
      isRepeatable: false,
    ),
    Upgrade(
      id: 'god_totem',
      name: 'Banana God Totem',
      description: '+100% total banana income per level',
      imagePath: 'assets/images/icons/trophy.png',
      category: 'Special',
      fixedCost: 10000000.0,
      maxLevel: 3,
      effectType: 'GLOBAL_MULT',
      effectValue: 1.00,
      isRepeatable: false,
    ),
  ];

  final List<Quest> _baseQuests = [
    Quest(
      id: 'click_50',
      title: 'First Steps',
      description: 'Tap the monkey 50 times',
      targetValue: 50.0,
      reward: 100.0,
      type: 'clicks',
      layer: 'main',
    ),
    Quest(
      id: 'click_200',
      title: 'Steady Tapping',
      description: 'Tap the monkey 200 times',
      targetValue: 200.0,
      reward: 300.0,
      type: 'clicks',
      layer: 'main',
    ),
    Quest(
      id: 'click_1000',
      title: 'Jungle Expert',
      description: 'Tap the monkey 1,000 times',
      targetValue: 1000.0,
      reward: 1500.0,
      type: 'clicks',
      layer: 'main',
    ),
    Quest(
      id: 'earn_500',
      title: 'Banana Gatherer',
      description: 'Earn 500 total bananas',
      targetValue: 500.0,
      reward: 200.0,
      type: 'bananas',
      layer: 'main',
    ),
    Quest(
      id: 'earn_5000',
      title: 'Harvest Season',
      description: 'Earn 5,000 total bananas',
      targetValue: 5000.0,
      reward: 1000.0,
      type: 'bananas',
      layer: 'main',
    ),
    Quest(
      id: 'earn_50000',
      title: 'Jungle Capitalist',
      description: 'Earn 50,000 total bananas',
      targetValue: 50000.0,
      reward: 5000.0,
      type: 'bananas',
      layer: 'main',
    ),
    Quest(
      id: 'buy_5_upgrades',
      title: 'Investor',
      description: 'Buy 5 upgrades in total',
      targetValue: 5.0,
      reward: 400.0,
      type: 'upgrades',
      layer: 'main',
    ),
    Quest(
      id: 'buy_15_upgrades',
      title: 'Industrialist',
      description: 'Buy 15 upgrades in total',
      targetValue: 15.0,
      reward: 2000.0,
      type: 'upgrades',
      layer: 'main',
    ),
    Quest(
      id: 'daily_clicks',
      title: 'Daily Tap Routine',
      description: 'Tap the monkey 300 times',
      targetValue: 300.0,
      reward: 600.0,
      type: 'clicks',
      layer: 'daily',
    ),
    Quest(
      id: 'daily_bananas',
      title: 'Daily Harvest',
      description: 'Earn 15,000 bananas',
      targetValue: 15000.0,
      reward: 800.0,
      type: 'bananas',
      layer: 'daily',
    ),
    Quest(
      id: 'daily_golden',
      title: 'Daily Golden Catch',
      description: 'Collect 2 golden bananas',
      targetValue: 2.0,
      reward: 1000.0,
      type: 'golden',
      layer: 'daily',
    ),
    Quest(
      id: 'daily_combo',
      title: 'Daily Rhythm',
      description: 'Reach a click combo of x15',
      targetValue: 15.0,
      reward: 500.0,
      type: 'combo',
      layer: 'daily',
    ),
    Quest(
      id: 'daily_upgrades',
      title: 'Daily Shopping',
      description: 'Buy 8 upgrades in total',
      targetValue: 8.0,
      reward: 750.0,
      type: 'upgrades',
      layer: 'daily',
    ),
    Quest(
      id: 'weekly_clicks',
      title: 'Weekly Marathon',
      description: 'Tap the monkey 2,500 times',
      targetValue: 2500.0,
      reward: 5000.0,
      type: 'clicks',
      layer: 'weekly',
    ),
    Quest(
      id: 'weekly_bananas',
      title: 'Weekly Motherlode',
      description: 'Earn 500,000 bananas',
      targetValue: 500000.0,
      reward: 7500.0,
      type: 'bananas',
      layer: 'weekly',
    ),
    Quest(
      id: 'weekly_golden',
      title: 'Weekly Star Gazing',
      description: 'Collect 15 golden bananas',
      targetValue: 15.0,
      reward: 6000.0,
      type: 'golden',
      layer: 'weekly',
    ),
    Quest(
      id: 'weekly_crits',
      title: 'Weekly Sharp Eye',
      description: 'Trigger 100 critical taps',
      targetValue: 100.0,
      reward: 4000.0,
      type: 'crits',
      layer: 'weekly',
    ),
    Quest(
      id: 'quest_relic_1',
      title: 'Relic Finder',
      description: 'Acquire your first Jungle Relic',
      targetValue: 1.0,
      reward: 2000.0,
      type: 'relics',
      layer: 'map',
    ),
    Quest(
      id: 'quest_relic_5',
      title: 'Artifact Collector',
      description: 'Acquire 5 Jungle Relics',
      targetValue: 5.0,
      reward: 10000.0,
      type: 'relics',
      layer: 'map',
    ),
    Quest(
      id: 'quest_rebirth_1',
      title: 'New Beginning',
      description: 'Prestige / Rebirth once',
      targetValue: 1.0,
      reward: 5000.0,
      type: 'rebirth',
      layer: 'map',
    ),
    Quest(
      id: 'quest_skins_2',
      title: 'Fashion Monkey',
      description: 'Unlock 2 monkey skins',
      targetValue: 2.0,
      reward: 1500.0,
      type: 'skins',
      layer: 'map',
    ),
    Quest(
      id: 'quest_skins_4',
      title: 'Costume Party',
      description: 'Unlock 4 monkey skins',
      targetValue: 4.0,
      reward: 5000.0,
      type: 'skins',
      layer: 'map',
    ),
    Quest(
      id: 'milestone_clicks_10k',
      title: 'Tapping Legend',
      description: 'Tap the monkey 10,000 times',
      targetValue: 10000.0,
      reward: 25000.0,
      type: 'clicks',
      layer: 'milestone',
    ),
    Quest(
      id: 'milestone_bananas_10m',
      title: 'Banana Overlord',
      description: 'Earn 10,000,000 total bananas',
      targetValue: 10000000.0,
      reward: 50000.0,
      type: 'bananas',
      layer: 'milestone',
    ),
    Quest(
      id: 'milestone_crits_500',
      title: 'Precision Striker',
      description: 'Trigger 500 critical taps',
      targetValue: 500.0,
      reward: 15000.0,
      type: 'crits',
      layer: 'milestone',
    ),
    Quest(
      id: 'milestone_combo_50',
      title: 'Ultimate Combo',
      description: 'Reach a click combo of x50',
      targetValue: 50.0,
      reward: 10000.0,
      type: 'combo',
      layer: 'milestone',
    ),
    Quest(
      id: 'milestone_level_25',
      title: 'Grandmaster Monkey',
      description: 'Reach monkey level 25',
      targetValue: 25.0,
      reward: 20000.0,
      type: 'level',
      layer: 'milestone',
    ),
    Quest(
      id: 'milestone_golden_100',
      title: 'Golden Touch',
      description: 'Collect 100 golden bananas',
      targetValue: 100.0,
      reward: 35000.0,
      type: 'golden',
      layer: 'milestone',
    ),
    Quest(
      id: 'milestone_upgrades_100',
      title: 'Endgame Tycoon',
      description: 'Buy 100 upgrades in total',
      targetValue: 100.0,
      reward: 25000.0,
      type: 'upgrades',
      layer: 'milestone',
    ),
  ];

  final List<Achievement> _baseAchievements = [
    Achievement(
      id: 'first_banana',
      title: 'First Banana',
      description: 'Earn your first banana',
      category: 'economy',
    ),
    Achievement(
      id: 'banana_beginner',
      title: 'Banana Beginner',
      description: 'Earn 1,000 bananas in total',
      category: 'economy',
    ),
    Achievement(
      id: 'banana_collector',
      title: 'Banana Collector',
      description: 'Earn 10,000 bananas in total',
      category: 'economy',
    ),
    Achievement(
      id: 'banana_millionaire',
      title: 'Banana Millionaire',
      description: 'Earn 1,000,000 bananas in total',
      category: 'economy',
    ),
    Achievement(
      id: 'banana_billionaire',
      title: 'Banana Billionaire',
      description: 'Earn 1,000,000,000 bananas in total',
      category: 'economy',
    ),
    Achievement(
      id: 'banana_tycoon',
      title: 'Banana Tycoon',
      description: 'Earn 10,000,000,000 bananas in total',
      category: 'economy',
    ),
    Achievement(
      id: 'first_click',
      title: 'Hello Monkey',
      description: 'Tap the monkey for the first time',
      category: 'tapping',
    ),
    Achievement(
      id: 'monkey_friend',
      title: 'Monkey Friend',
      description: 'Tap the monkey 500 times',
      category: 'tapping',
    ),
    Achievement(
      id: 'monkey_lover',
      title: 'Monkey Lover',
      description: 'Tap the monkey 2,000 times',
      category: 'tapping',
    ),
    Achievement(
      id: 'monkey_devotee',
      title: 'Monkey Devotee',
      description: 'Tap the monkey 10,000 times',
      category: 'tapping',
    ),
    Achievement(
      id: 'combo_beginner',
      title: 'Getting Groove',
      description: 'Reach a combo of x10',
      category: 'combo',
    ),
    Achievement(
      id: 'combo_master',
      title: 'Combo Master',
      description: 'Reach a combo of x30',
      category: 'combo',
    ),
    Achievement(
      id: 'combo_grandmaster',
      title: 'Rhythm Legend',
      description: 'Reach a combo of x50',
      category: 'combo',
    ),
    Achievement(
      id: 'first_crit',
      title: 'Lucky Hit',
      description: 'Trigger your first critical tap',
      category: 'critical',
    ),
    Achievement(
      id: 'crit_striker',
      title: 'Crit Striker',
      description: 'Trigger 50 critical taps',
      category: 'critical',
    ),
    Achievement(
      id: 'crit_master',
      title: 'Uncanny Accuracy',
      description: 'Trigger 200 critical taps',
      category: 'critical',
    ),
    Achievement(
      id: 'first_golden',
      title: 'Shiny Thing',
      description: 'Collect your first golden banana',
      category: 'golden',
    ),
    Achievement(
      id: 'golden_hunter',
      title: 'Golden Banana Hunter',
      description: 'Collect 10 golden bananas',
      category: 'golden',
    ),
    Achievement(
      id: 'golden_collector',
      title: 'Sunlight Seeker',
      description: 'Collect 50 golden bananas',
      category: 'golden',
    ),
    Achievement(
      id: 'first_relic',
      title: 'Ancient Find',
      description: 'Acquire your first Jungle Relic',
      category: 'map',
    ),
    Achievement(
      id: 'relic_collector',
      title: 'Curator',
      description: 'Acquire 3 Jungle Relics',
      category: 'map',
    ),
    Achievement(
      id: 'relic_hoarder',
      title: 'Archaeologist',
      description: 'Acquire 8 Jungle Relics',
      category: 'map',
    ),
    Achievement(
      id: 'map_unlocked_2',
      title: 'Village Visitor',
      description: 'Unlock the Banana Village map',
      category: 'map',
    ),
    Achievement(
      id: 'map_unlocked_3',
      title: 'Volcano Survivor',
      description: 'Unlock the Volcano Island map',
      category: 'map',
    ),
    Achievement(
      id: 'map_unlocked_6',
      title: 'Kingdom Emperor',
      description: 'Unlock the Golden Banana Kingdom map',
      category: 'map',
    ),
    Achievement(
      id: 'skin_collector_2',
      title: 'Monkey Wardrobe',
      description: 'Unlock 2 monkey skins',
      category: 'collection',
    ),
    Achievement(
      id: 'skin_collector_5',
      title: 'Cosplay Master',
      description: 'Unlock 5 monkey skins',
      category: 'collection',
    ),
    Achievement(
      id: 'first_rebirth',
      title: 'Reborn',
      description: 'Prestige for the first time',
      category: 'rebirth',
    ),
    Achievement(
      id: 'rebirth_3',
      title: 'Eternal Monkey',
      description: 'Prestige 3 times',
      category: 'rebirth',
    ),
    Achievement(
      id: 'rebirth_10',
      title: 'Infinite Cycle',
      description: 'Prestige 10 times',
      category: 'rebirth',
    ),
  ];

  final List<Skin> _baseSkins = [
    // Jungle Skins
    Skin(
      id: 'jungle_default',
      name: 'Jungle Monkey',
      cost: 0.0,
      imagePath: 'assets/images/monkeys/monkeydefault/jungle_monkey.png',
      bonusDescription: 'Default Jungle Skin - No bonus',
      mapId: 'jungle',
      isUnlocked: true,
      isEquipped: true,
    ),
    Skin(
      id: 'jungle_skin1',
      name: 'Jungle Explorer',
      cost: 5000.0,
      imagePath: 'assets/images/monkeys/monkeyskins/jungle_monkey_skin1.png',
      bonusDescription: '+5% bananas per click',
      mapId: 'jungle',
    ),

    // Banana Village Skins
    Skin(
      id: 'banana_village_default',
      name: 'Village Monkey',
      cost: 0.0,
      imagePath:
          'assets/images/monkeys/monkeydefault/banana_village_monkey.png',
      bonusDescription: 'Default Village Skin - No bonus',
      mapId: 'banana_village',
      isUnlocked: true,
      isEquipped: true,
    ),

    // Volcano Island Skins
    Skin(
      id: 'volcano_island_default',
      name: 'Volcano Monkey',
      cost: 0.0,
      imagePath:
          'assets/images/monkeys/monkeydefault/volcano_island_monkey.png',
      bonusDescription: 'Default Volcano Skin - No bonus',
      mapId: 'volcano_island',
      isUnlocked: true,
      isEquipped: true,
    ),

    // Ancient Temple Skins
    Skin(
      id: 'ancient_temple_default',
      name: 'Ancient Monkey',
      cost: 0.0,
      imagePath:
          'assets/images/monkeys/monkeydefault/ancient_temple_monkey.png',
      bonusDescription: 'Default Ancient Skin - No bonus',
      mapId: 'ancient_temple',
      isUnlocked: true,
      isEquipped: true,
    ),

    // Cloud Jungle Skins
    Skin(
      id: 'cloud_jungle_default',
      name: 'Cloud Monkey',
      cost: 0.0,
      imagePath: 'assets/images/monkeys/monkeydefault/cloud_jungle_monkey.png',
      bonusDescription: 'Default Cloud Skin - No bonus',
      mapId: 'cloud_jungle',
      isUnlocked: true,
      isEquipped: true,
    ),

    // Golden Kingdom Skins
    Skin(
      id: 'golden_kingdom_default',
      name: 'Golden Monkey',
      cost: 0.0,
      imagePath:
          'assets/images/monkeys/monkeydefault/golden_kingdom_monkey.png',
      bonusDescription: 'Default Golden Skin - No bonus',
      mapId: 'golden_kingdom',
      isUnlocked: true,
      isEquipped: true,
    ),
  ];

  final List<MapTheme> _baseMaps = [
    MapTheme(
      id: 'jungle',
      name: 'Jungle',
      description: 'Tropical green jungle theme with leafy accents',
      cost: 0.0,
      backgroundPath: 'assets/images/backgrounds/jungle.png',
      monkeyPath: 'assets/images/monkeys/monkeydefault/jungle_monkey.png',
      primaryColor: const Color(0xFF2D7D46),
      secondaryColor: const Color(0xFFFFF8DC),
      darkBorderColor: const Color(0xFF3E2723),
      cardBaseColor: const Color(0xFF2E7D32),
      cardTrimColor: const Color(0xFF1B5E20),
      iconFrameColor: const Color(0xFFFFA000),
      isUnlocked: true,
      isEquipped: true,
    ),
    MapTheme(
      id: 'banana_village',
      name: 'Banana Village',
      description: 'Warm yellow-green atmosphere of a rustic monkey hamlet',
      cost: 5000.0,
      backgroundPath: 'assets/images/backgrounds/bananajungle.png',
      monkeyPath:
          'assets/images/monkeys/monkeydefault/banana_village_monkey.png',
      primaryColor: const Color(0xFF689F38),
      secondaryColor: const Color(0xFFFFF8DC),
      darkBorderColor: const Color(0xFF8D6E63),
      cardBaseColor: const Color(0xFF689F38),
      cardTrimColor: const Color(0xFF558B2F),
      iconFrameColor: const Color(0xFFFBC02D),
    ),
    MapTheme(
      id: 'volcano_island',
      name: 'Volcano Island',
      description: 'Dark obsidian stone with burning lava cracks and fires',
      cost: 15000.0,
      backgroundPath: 'assets/images/backgrounds/volcanoisland.png',
      monkeyPath:
          'assets/images/monkeys/monkeydefault/volcano_island_monkey.png',
      primaryColor: const Color(0xFFD84315),
      secondaryColor: const Color(0xFFECEFF1),
      darkBorderColor: const Color(0xFF212121),
      cardBaseColor: const Color(0xFF37474F),
      cardTrimColor: const Color(0xFF212121),
      iconFrameColor: const Color(0xFFDF4A1D),
    ),
    MapTheme(
      id: 'ancient_temple',
      name: 'Ancient Temple',
      description: 'Carved mossy stones and forgotten treasures',
      cost: 50000.0,
      backgroundPath: 'assets/images/backgrounds/ancienttemple.png',
      monkeyPath:
          'assets/images/monkeys/monkeydefault/ancient_temple_monkey.png',
      primaryColor: const Color(0xFF00695C),
      secondaryColor: const Color(0xFFEFEBE9),
      darkBorderColor: const Color(0xFF4E342E),
      cardBaseColor: const Color(0xFF5D4037),
      cardTrimColor: const Color(0xFF4E342E),
      iconFrameColor: const Color(0xFF4DB6AC),
    ),
    MapTheme(
      id: 'cloud_jungle',
      name: 'Cloud Jungle',
      description: 'A mystical kingdom high up in the blue skies',
      cost: 100000.0,
      backgroundPath: 'assets/images/backgrounds/cloudjungle.png',
      monkeyPath: 'assets/images/monkeys/monkeydefault/cloud_jungle_monkey.png',
      primaryColor: const Color(0xFF00ACC1),
      secondaryColor: const Color(0xFFE1F5FE),
      darkBorderColor: const Color(0xFF0277BD),
      cardBaseColor: const Color(0xFF0288D1),
      cardTrimColor: const Color(0xFF0277BD),
      iconFrameColor: const Color(0xFF80DEEA),
    ),
    MapTheme(
      id: 'golden_kingdom',
      name: 'Golden Kingdom',
      description: 'The royal golden throne room loaded with infinite wealth',
      cost: 250000.0,
      backgroundPath: 'assets/images/backgrounds/goldenbananakingdom.png',
      monkeyPath:
          'assets/images/monkeys/monkeydefault/golden_kingdom_monkey.png',
      primaryColor: const Color(0xFFFFD54F),
      secondaryColor: const Color(0xFFFFFDE7),
      darkBorderColor: const Color(0xFFF57F17),
      cardBaseColor: const Color(0xFFFBC02D),
      cardTrimColor: const Color(0xFFF57F17),
      iconFrameColor: const Color(0xFFFFFFFF),
    ),
  ];

  final List<SkillNode> _baseSkills = [
    SkillNode(
      id: 'strong_fingers',
      name: 'Strong Fingers',
      branch: 'Click Power',
      description: '+10% click power',
      cost: 1,
    ),
    SkillNode(
      id: 'faster_helpers',
      name: 'Faster Helpers',
      branch: 'Helpers',
      description: '+10% idle income',
      cost: 1,
    ),
    SkillNode(
      id: 'lucky_banana',
      name: 'Lucky Banana',
      branch: 'Luck',
      description: '+2% critical tap chance',
      cost: 1,
    ),
    SkillNode(
      id: 'longer_combo',
      name: 'Longer Combo',
      branch: 'Luck',
      description: 'Combo reset duration +0.5s',
      cost: 2,
    ),
    SkillNode(
      id: 'golden_luck',
      name: 'Golden Luck',
      branch: 'Luck',
      description: 'Golden Banana spawn chance increased',
      cost: 3,
    ),
  ];

  // ---------- Init Game ----------
  Future<void> initGame() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Load Player Stats
    _stats = await _saveService.loadStats();

    // 2. Load Upgrades
    _upgrades = await _saveService.loadUpgrades(_baseUpgrades);

    // Recalculate derived BPC and BPS based on loaded upgrade levels
    _stats = _stats.copyWith(
      bananasPerClick: calculateCurrentBpc(),
      bananasPerSecond: calculateCurrentBps(),
    );

    // 3. Load Achievements
    _achievements = _baseAchievements.map((ach) {
      final unlocked = prefs.getBool('ach_unlocked_${ach.id}') ?? false;
      final unlockedAt = prefs.getInt('ach_unlocked_at_${ach.id}');
      return ach.copyWith(unlocked: unlocked, unlockedAt: unlockedAt);
    }).toList();

    // 4. Load Skins
    _skins = _baseSkins.map((skin) {
      final unlocked = _stats.unlockedSkins.contains(skin.id);
      final equipped = _stats.equippedMapSkins[skin.mapId] == skin.id;
      return skin.copyWith(isUnlocked: unlocked, isEquipped: equipped);
    }).toList();

    // 5. Load Maps
    _maps = _baseMaps.map((map) {
      final unlocked = _stats.unlockedMaps.contains(map.id);
      final equipped = _stats.equippedMap == map.id;
      return map.copyWith(isUnlocked: unlocked, isEquipped: equipped);
    }).toList();

    // 6. Load Skill Tree Nodes
    _skills = _baseSkills.map((skill) {
      final unlocked = _stats.unlockedSkills.contains(skill.id);
      return skill.copyWith(isUnlocked: unlocked);
    }).toList();

    // 7. Load Quests
    _quests = _baseQuests.map((quest) {
      final claimed = prefs.getBool('quest_claimed_${quest.id}') ?? false;
      final currentVal = _getQuestProgressValue(quest.type, quest.layer);
      final completed = currentVal >= quest.targetValue;
      return quest.copyWith(
        claimed: claimed,
        completed: completed,
        progress: currentVal,
      );
    }).toList();

    // 8. Offline Earnings calculation
    final double offlineMultiplier = _calculateOfflineMultiplier();
    double capHours = 2.0; // Base offline cap is 2 hours
    for (var u in _upgrades) {
      if (u.effectType == 'OFFLINE_CAP') {
        capHours += u.currentLevel * u.effectValue;
      }
    }
    capHours = capHours.clamp(2.0, 6.0); // Hard clamped to 6 hours max
    _offlineTimeClampedHours = capHours;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (_stats.lastSavedTime > 0) {
      final elapsedMs = now - _stats.lastSavedTime;
      _offlineTimePassedHours = elapsedMs / 3600000.0;
    } else {
      _offlineTimePassedHours = 0.0;
    }

    final double rawEarnings = _offlineService.calculateEarnings(
      _stats,
      offlineMultiplier,
      capHours: capHours,
    );
    final double offlineEarnings = rawEarnings * 0.60; // 60% efficiency factor
    if (offlineEarnings > 0) {
      _pendingOfflineEarnings = offlineEarnings;
      _stats = _stats.copyWith(
        totalBananas: _stats.totalBananas + offlineEarnings,
        questBananasEarned: _stats.questBananasEarned + offlineEarnings,
      );
      _showOfflineDialog = true;
      _checkAchievements();
      _saveStats();
    }

    // 9. Start Core periodic loops
    _startPassiveIncomeTimer();
    _startAutoSaveTimer();
    _startGoldenBananaSpawnTimer();

    notifyListeners();
  }

  // ---------- Passive Income Loop (1s Tick) ----------
  void _startPassiveIncomeTimer() {
    _passiveIncomeTimer?.cancel();
    _passiveIncomeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final bps = calculateCurrentBps();
      if (bps > 0) {
        _stats = _stats.copyWith(
          totalBananas: _stats.totalBananas + bps,
          questBananasEarned: _stats.questBananasEarned + bps,
        );
        _addXp(bps * 0.05); // Passive income gives some XP
        _checkQuests();
        _checkAchievements();
      }
      notifyListeners();
    });
  }

  // ---------- Auto Save Loop (10s Tick) ----------
  void _startAutoSaveTimer() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      saveGame();
    });
  }

  // ---------- Combo Decay (One-shot Timer) ----------
  double get totalComboDurationMs {
    double comboTimeBonus = 0.0;
    for (var u in _upgrades) {
      if (u.effectType == 'COMBO_TIME') {
        comboTimeBonus += u.currentLevel * u.effectValue;
      }
    }
    final double longerComboBonus = _isSkillUnlocked('longer_combo') ? 0.5 : 0.0;
    return 1200.0 + (comboTimeBonus * 1000.0) + (longerComboBonus * 1000.0);
  }

  void _resetComboTimer() {
    _comboDecayTimer?.cancel();
    _comboDecayTimer = Timer(Duration(milliseconds: totalComboDurationMs.toInt()), () {
      _comboCount = 1;
      _comboProgress = 0.0;
      notifyListeners();
    });
  }

  // ---------- Golden Banana Spawn Loop ----------
  void _startGoldenBananaSpawnTimer() {
    _goldenBananaSpawnTimer?.cancel();

    // Schedule random spawn duration between 30 and 60 seconds (minus reduction)
    int reduction = 0;
    for (var u in _upgrades) {
      if (u.effectType == 'GOLDEN_INTERVAL') {
        reduction += (u.currentLevel * u.effectValue).toInt();
      }
    }
    int minSecs = max(
      5,
      (_isSkillUnlocked('golden_luck') ? 20 : 30) - reduction,
    );
    int maxSecs = max(
      10,
      (_isSkillUnlocked('golden_luck') ? 40 : 60) - reduction,
    );
    int spawnInterval = minSecs + _rng.nextInt(maxSecs - minSecs + 1);

    _goldenBananaSpawnTimer = Timer(Duration(seconds: spawnInterval), () {
      if (!_showGoldenBanana && !_isBananaRainActive) {
        _goldenBananaX = _rng.nextDouble() * 0.7 + 0.15; // 15% to 85% width
        _goldenBananaY = _rng.nextDouble() * 0.4 + 0.25; // 25% to 65% height
        _showGoldenBanana = true;
        notifyListeners();

        // Auto hide timeout
        _goldenBananaTimeoutTimer?.cancel();
        final double durationBonus =
            activeSkinIdForCurrentMap == 'ancient_temple_default' ? 2.0 : 0.0;
        final double totalDuration = 5.0 + durationBonus;

        _goldenBananaTimeoutTimer = Timer(
          Duration(milliseconds: (totalDuration * 1000).toInt()),
          () {
            if (_showGoldenBanana) {
              _showGoldenBanana = false;
              notifyListeners();
              _startGoldenBananaSpawnTimer(); // schedule next spawn
            }
          },
        );
      } else {
        _startGoldenBananaSpawnTimer();
      }
    });
  }

  // ---------- Level UP System ----------
  void _addXp(double amount) {
    double currentXp = _stats.xp + amount;
    int currentLevel = _stats.level;
    double needed = 100.0 * pow(1.5, currentLevel - 1);

    bool leveledUp = false;
    while (currentXp >= needed) {
      currentXp -= needed;
      currentLevel++;
      needed = 100.0 * pow(1.5, currentLevel - 1);
      leveledUp = true;
    }

    _stats = _stats.copyWith(xp: currentXp, level: currentLevel);

    if (leveledUp) {
      _audioService.playLevelUp();
      HapticFeedback.heavyImpact();
      _levelUpNotification = 'LEVEL UP! MONKEY LEVEL $currentLevel';
      notifyListeners();

      // Auto-clear notification after 2.5s
      Timer(const Duration(milliseconds: 2500), () {
        _levelUpNotification = null;
        notifyListeners();
      });
    }
  }

  // ---------- User Click Interaction ----------
  TapResult tapMonkey() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final int tapGap = now - _lastTapTimestamp;
    _lastTapTimestamp = now;

    // 1. Combo increments (within 800ms)
    if (tapGap <= 800) {
      _comboCount = (_comboCount + 1).clamp(1, 50); // limit to 50 for visuals
    } else {
      _comboCount = 2; // start a new combo
    }
    _comboProgress = 1.0;
    _resetComboTimer();

    // 2. Critical hit chance calculations (+upgrades +Ninja skin + Lucky Banana skill)
    double critChance = 0.05; // Base critical chance is 5%
    for (var u in _upgrades) {
      if (u.effectType == 'CRIT_CHANCE') {
        critChance += u.currentLevel * u.effectValue;
      }
    }
    if (activeSkinIdForCurrentMap == 'ninja_skin') critChance += 0.03;
    if (_isSkillUnlocked('lucky_banana')) critChance += 0.02;

    final isCrit = _rng.nextDouble() < critChance;

    // Critical multiplier calculations (+upgrades)
    double activeCritMultiplier = 1.0;
    if (isCrit) {
      activeCritMultiplier = 3.0; // Base crit multiplier
      for (var u in _upgrades) {
        if (u.effectType == 'CRIT_MULT' || u.effectType == 'CRIT_REWARD') {
          activeCritMultiplier += u.currentLevel * u.effectValue;
        }
      }
    }

    // 3. Earn calculation using cached bananasPerClick directly
    final double earned = _stats.bananasPerClick * activeCritMultiplier;

    // 4. Update stats
    _stats = _stats.copyWith(
      totalBananas: _stats.totalBananas + earned,
      questClicks: _stats.questClicks + 1,
      questBananasEarned: _stats.questBananasEarned + earned,
      questMaxComboReached: max(_stats.questMaxComboReached, _comboCount),
      questCritsTriggered: _stats.questCritsTriggered + (isCrit ? 1 : 0),
    );

    // Audio & vibration
    if (isCrit) {
      _audioService.playCritical();
    } else {
      _audioService.playTap();
    }

    // XP gain (+1 per click)
    _addXp(1.0);

    _checkQuests();
    _checkAchievements();
    notifyListeners();

    return TapResult(earned: earned, isCritical: isCrit, combo: _comboCount);
  }

  // ---------- Golden Banana Click ----------
  GoldenBananaResult? tapGoldenBanana() {
    if (!_showGoldenBanana) return null;
    _showGoldenBanana = false;
    _audioService.playGoldenBanana();

    // Roll rewards (4 choices: 0=Instant, 1=2x tap power, 2=2x idle income, 3=Banana Rain!)
    final choice = _rng.nextInt(4);

    final double bpc = _stats.bananasPerClick;

    // Golden upgrades multipliers
    double goldenDurationBonus = 0.0;
    double goldenRewardMult = 1.0;
    for (var u in _upgrades) {
      if (u.id == 'golden_banana') {
        goldenDurationBonus += u.currentLevel * 1.0; // +1s per level
        goldenRewardMult +=
            u.currentLevel * u.effectValue; // +10% reward per level
      } else if (u.effectType == 'GOLDEN_DUR') {
        goldenDurationBonus += u.currentLevel * u.effectValue; // +2s per level
      } else if (u.effectType == 'GOLDEN_REWARD') {
        goldenRewardMult +=
            u.currentLevel * u.effectValue; // +25% reward per level
      }
    }

    _goldenBananaTimeoutTimer?.cancel();
    _checkQuests();
    _checkAchievements();
    saveGame();
    _startGoldenBananaSpawnTimer(); // Reschedule next
    notifyListeners();

    if (choice == 0) {
      // Instant reward
      final baseReward = (100.0 * bpc).clamp(500.0, double.infinity);
      double metaGoldenMult =
          1.0 + (_stats.metaGoldenLevel * 0.15); // Shiny Totem

      final reward =
          baseReward *
          goldenRewardMult *
          metaGoldenMult *
          currentMapProgression.worldRewardMultiplier;
      _stats = _stats.copyWith(
        totalBananas: _stats.totalBananas + reward,
        questBananasEarned: _stats.questBananasEarned + reward,
        questGoldenBananasCollected: _stats.questGoldenBananasCollected + 1,
      );

      return GoldenBananaResult(
        text: 'GOLDEN REWARD!\n+${_formatVal(reward)}',
      );
    } else if (choice == 1) {
      // 2x Tap power for 30s
      final int totalDurationMs = (30.0 + goldenDurationBonus).toInt() * 1000;
      _goldenTapExpiresAt =
          DateTime.now().millisecondsSinceEpoch + totalDurationMs;
      _stats = _stats.copyWith(
        questGoldenBananasCollected: _stats.questGoldenBananasCollected + 1,
      );

      return GoldenBananaResult(
        text: '2x TAP POWER!',
      );
    } else if (choice == 2) {
      // 2x Idle power for 30s
      final int totalDurationMs = (30.0 + goldenDurationBonus).toInt() * 1000;
      _goldenIdleExpiresAt =
          DateTime.now().millisecondsSinceEpoch + totalDurationMs;
      _stats = _stats.copyWith(
        questGoldenBananasCollected: _stats.questGoldenBananasCollected + 1,
      );

      return GoldenBananaResult(
        text: '2x IDLE INCOME!',
      );
    } else {
      // Banana Rain!
      _stats = _stats.copyWith(
        questGoldenBananasCollected: _stats.questGoldenBananasCollected + 1,
      );
      startBananaRain();
      return GoldenBananaResult(
        text: 'BANANA RAIN!',
        startsBananaRain: true,
      );
    }
  }

  // ---------- Banana Rain Event ----------
  void startBananaRain() {
    if (_isBananaRainActive) return;
    _isBananaRainActive = true;
    notifyListeners();

    // Reset status after 10s
    Timer(const Duration(seconds: 10), () {
      _isBananaRainActive = false;
      notifyListeners();
    });
  }

  // ---------- Collect Falling Banana Tap ----------
  double collectRainBanana() {
    _audioService.playTap();

    double rainMult = 1.0;
    for (var u in _upgrades) {
      if (u.effectType == 'RAIN_BOOST') {
        rainMult += u.currentLevel * u.effectValue;
      }
    }
    final double reward =
        calculateCurrentBpc() *
        rainMult *
        currentMapProgression.worldRewardMultiplier;
    _stats = _stats.copyWith(
      totalBananas: _stats.totalBananas + reward,
      questBananasEarned: _stats.questBananasEarned + reward,
    );

    _checkQuests();
    _checkAchievements();
    notifyListeners();
    return reward;
  }

  // ---------- Purchase Upgrades ----------
  bool buyUpgrade(Upgrade upgrade) {
    final cost = upgrade.getCost(currentMapProgression.worldCostMultiplier);
    if (upgrade.currentLevel >= upgrade.maxLevel) return false;
    if (_stats.totalBananas < cost) return false;

    _audioService.playUpgrade();

    _upgrades = _upgrades.map((u) {
      if (u.id == upgrade.id) {
        return u.copyWith(currentLevel: u.currentLevel + 1);
      }
      return u;
    }).toList();

    // Deduct cost
    _stats = _stats.copyWith(
      totalBananas: _stats.totalBananas - cost,
      questUpgradesBought: _stats.questUpgradesBought + 1,
    );

    // XP reward for upgrades
    _addXp(cost * 0.1);

    // Recalculate rates
    _stats = _stats.copyWith(
      bananasPerClick: calculateCurrentBpc(),
      bananasPerSecond: calculateCurrentBps(),
    );

    _checkQuests();
    _checkAchievements();
    notifyListeners();
    saveGame();
    return true;
  }

  // ---------- Skin Marketplace Actions ----------
  bool buySkin(String skinId) {
    final skin = _skins.firstWhere((s) => s.id == skinId);
    if (_stats.totalBananas < skin.cost ||
        _stats.unlockedSkins.contains(skinId)) {
      return false;
    }

    _audioService.playUpgrade();
    _stats = _stats.copyWith(
      totalBananas: _stats.totalBananas - skin.cost,
      unlockedSkins: [..._stats.unlockedSkins, skinId],
    );

    _skins = _skins.map((s) {
      if (s.id == skinId) return s.copyWith(isUnlocked: true);
      return s;
    }).toList();

    equipSkin(skinId); // Automatically equip the newly purchased skin

    notifyListeners();
    saveGame();
    return true;
  }

  bool equipSkin(String skinId) {
    if (!_stats.unlockedSkins.contains(skinId)) return false;

    final skin = _skins.firstWhere((s) => s.id == skinId);
    final mapId = skin.mapId;

    final Map<String, String> newEquippedMapSkins = Map<String, String>.from(
      _stats.equippedMapSkins,
    );
    newEquippedMapSkins[mapId] = skinId;

    _stats = _stats.copyWith(equippedMapSkins: newEquippedMapSkins);

    _skins = _skins.map((s) {
      if (s.mapId == mapId) {
        return s.copyWith(isEquipped: s.id == skinId);
      }
      return s;
    }).toList();

    // Recalculate specs in case of multiplier modifications
    _stats = _stats.copyWith(
      bananasPerClick: calculateCurrentBpc(),
      bananasPerSecond: calculateCurrentBps(),
    );

    notifyListeners();
    saveGame();
    return true;
  }

  // ---------- Map Themes Actions ----------
  bool buyMap(String mapId) {
    final map = _maps.firstWhere((m) => m.id == mapId);
    if (_stats.totalBananas < map.cost || _stats.unlockedMaps.contains(mapId)) {
      return false;
    }

    _audioService.playUpgrade();
    _stats = _stats.copyWith(
      totalBananas: _stats.totalBananas - map.cost,
      unlockedMaps: [..._stats.unlockedMaps, mapId],
    );

    _maps = _maps.map((m) {
      if (m.id == mapId) return m.copyWith(isUnlocked: true);
      return m;
    }).toList();

    notifyListeners();
    saveGame();
    return true;
  }

  bool equipMap(String mapId) {
    if (!_stats.unlockedMaps.contains(mapId)) return false;

    _stats = _stats.copyWith(equippedMap: mapId);

    _maps = _maps.map((m) {
      return m.copyWith(isEquipped: m.id == mapId);
    }).toList();

    notifyListeners();
    saveGame();
    return true;
  }

  // ---------- Skill Tree Purchase Actions ----------
  bool buySkillNode(String skillId) {
    final skill = _skills.firstWhere((s) => s.id == skillId);
    if (_stats.goldenSeeds < skill.cost ||
        _stats.unlockedSkills.contains(skillId)) {
      return false;
    }

    _audioService.playUpgrade();
    _stats = _stats.copyWith(
      goldenSeeds: _stats.goldenSeeds - skill.cost,
      unlockedSkills: [..._stats.unlockedSkills, skillId],
    );

    _skills = _skills.map((s) {
      if (s.id == skillId) return s.copyWith(isUnlocked: true);
      return s;
    }).toList();

    // Recalculate stats
    _stats = _stats.copyWith(
      bananasPerClick: calculateCurrentBpc(),
      bananasPerSecond: calculateCurrentBps(),
    );

    notifyListeners();
    saveGame();
    return true;
  }

  // ---------- Claim Quest Reward ----------
  bool claimQuestReward(Quest quest) {
    if (quest.claimed || !quest.completed) return false;

    _audioService.playQuestComplete();

    _quests = _quests.map((q) {
      if (q.id == quest.id) {
        return q.copyWith(claimed: true);
      }
      return q;
    }).toList();

    _stats = _stats.copyWith(
      totalBananas: _stats.totalBananas + quest.reward,
      questBananasEarned: _stats.questBananasEarned + quest.reward,
      claimedQuests: {..._stats.claimedQuests, quest.id},
    );

    notifyListeners();
    saveGame();
    return true;
  }

  void claimAllQuestRewards() {
    final claimable = _quests.where((q) => !q.claimed && q.completed).toList();
    if (claimable.isEmpty) return;

    _audioService.playQuestComplete();

    double totalReward = 0.0;
    final Set<String> newClaimed = Set<String>.from(_stats.claimedQuests);

    _quests = _quests.map((q) {
      if (!q.claimed && q.completed) {
        totalReward += q.reward;
        newClaimed.add(q.id);
        return q.copyWith(claimed: true);
      }
      return q;
    }).toList();

    _stats = _stats.copyWith(
      totalBananas: _stats.totalBananas + totalReward,
      questBananasEarned: _stats.questBananasEarned + totalReward,
      claimedQuests: newClaimed,
    );

    notifyListeners();
    saveGame();
  }

  // ---------- Prestige / Rebirth System ----------
  bool triggerRebirth() {
    if (_stats.totalBananas < 1000000.0) return false;

    _audioService.playLevelUp(); // play satisfying fanfares

    // Formula: 1 golden seed per 1,000,000 bananas
    final int seedsEarned = (_stats.totalBananas / 1000000.0).floor();
    final int newPrestige = _stats.prestigeLevel + 1;
    final int newSeeds = _stats.goldenSeeds + seedsEarned;

    // Resets: bananas, upgrade levels, base values, active timers/combos
    _stats = PlayerStats(
      totalBananas: 0.0,
      bananasPerClick: 1.0,
      bananasPerSecond: 0.0,
      lastSavedTime: DateTime.now().millisecondsSinceEpoch,

      // Retain quests clicks & collection metrics
      questClicks: _stats.questClicks,
      questBananasEarned: _stats.questBananasEarned,
      questUpgradesBought: _stats.questUpgradesBought,
      questGoldenBananasCollected: _stats.questGoldenBananasCollected,
      questMaxComboReached: _stats.questMaxComboReached,

      // Keep inventory unlocks
      equippedMapSkins: _stats.equippedMapSkins,
      unlockedSkins: _stats.unlockedSkins,
      equippedMap: _stats.equippedMap,
      unlockedMaps: _stats.unlockedMaps,
      claimedQuests: _stats.claimedQuests,
      unlockedAchievements: _stats.unlockedAchievements,

      // Keep Level/XP
      level: _stats.level,
      xp: _stats.xp,

      // Apply prestige increments
      prestigeLevel: newPrestige,
      goldenSeeds: newSeeds,
      unlockedSkills: _stats.unlockedSkills,
    );

    // Reset upgrade levels to 0
    _upgrades = _baseUpgrades.map((u) => u.copyWith(currentLevel: 0)).toList();

    // Recalculate specifications
    _stats = _stats.copyWith(
      bananasPerClick: calculateCurrentBpc(),
      bananasPerSecond: calculateCurrentBps(),
    );

    _comboCount = 1;
    _comboProgress = 0.0;

    _checkQuests();
    _checkAchievements();
    notifyListeners();
    saveGame();
    return true;
  }

  // ---------- Save game persistence ----------
  Future<void> saveGame() async {
    final double mult = _calculateOfflineMultiplier();
    await _saveService.saveStats(_stats, mult);
    await _saveService.saveUpgrades(_upgrades);

    final prefs = await SharedPreferences.getInstance();
    for (var quest in _quests) {
      await prefs.setBool('quest_claimed_${quest.id}', quest.claimed);
    }
    for (var ach in _achievements) {
      await prefs.setBool('ach_unlocked_${ach.id}', ach.unlocked);
      if (ach.unlockedAt != null) {
        await prefs.setInt('ach_unlocked_at_${ach.id}', ach.unlockedAt!);
      }
    }
  }

  void _saveStats() {
    final double mult = _calculateOfflineMultiplier();
    _saveService.saveStats(_stats, mult);
  }

  // ---------- Dismiss Offline Dialog ----------
  void dismissOfflineDialog() {
    _showOfflineDialog = false;
    _pendingOfflineEarnings = 0.0;
    notifyListeners();
  }

  void debugAddBananas(double amount) {
    _stats = _stats.copyWith(
      totalBananas: _stats.totalBananas + amount,
      questBananasEarned: _stats.questBananasEarned + amount,
    );
    _checkQuests();
    _checkAchievements();
    notifyListeners();
    saveGame();
  }

  // ---------- Remove Floating reward particle from stack ----------
  void removeFloatingEffect(int id) {
    // Deprecated, handled locally in UI
  }

  // ---------- Wipes Data and Restart ----------
  Future<void> resetGame() async {
    _passiveIncomeTimer?.cancel();
    _autoSaveTimer?.cancel();
    _comboDecayTimer?.cancel();
    _goldenBananaSpawnTimer?.cancel();
    _goldenBananaTimeoutTimer?.cancel();

    await _saveService.clearAll();

    final prefs = await SharedPreferences.getInstance();
    for (var quest in _baseQuests) {
      await prefs.remove('quest_claimed_${quest.id}');
    }
    for (var ach in _baseAchievements) {
      await prefs.remove('ach_unlocked_${ach.id}');
      await prefs.remove('ach_unlocked_at_${ach.id}');
    }

    _stats = PlayerStats();
    _upgrades = List.from(_baseUpgrades);
    _quests = List.from(_baseQuests);
    _achievements = List.from(_baseAchievements);
    _skins = List.from(_baseSkins);
    _maps = List.from(_baseMaps);
    _skills = List.from(_baseSkills);

    _comboCount = 1;
    _comboProgress = 0.0;
    _showGoldenBanana = false;
    _goldenTapExpiresAt = 0;
    _goldenIdleExpiresAt = 0;
    _showOfflineDialog = false;
    _pendingOfflineEarnings = 0.0;
    _offlineTimePassedHours = 0.0;
    _offlineTimeClampedHours = 0.0;
    _isBananaRainActive = false;

    // Start loops
    _startPassiveIncomeTimer();
    _startAutoSaveTimer();
    _startGoldenBananaSpawnTimer();

    notifyListeners();
  }

  // ---------- Dynamic Income Calculation Math Formulas ----------

  double calculateBaseBpc() {
    double addBpc = 0.0;
    double clickBoost = 1.0;
    for (var u in _upgrades) {
      if (u.effectType == 'ADD_BPC') {
        addBpc += u.currentLevel * u.effectValue;
      } else if (u.effectType == 'CLICK_BOOST') {
        clickBoost += u.currentLevel * u.effectValue;
      }
    }
    return max(1.0, (1.0 + addBpc) * clickBoost);
  }

  double calculateCurrentBpc() {
    double bpc = calculateBaseBpc();

    // 1. Combo multiplier
    double baseComboBonus = 0.0;
    if (_comboCount >= 50)
      baseComboBonus = 0.50;
    else if (_comboCount >= 25)
      baseComboBonus = 0.25;
    else if (_comboCount >= 10)
      baseComboBonus = 0.10;

    double comboBonusFactor = 1.0;
    for (var u in _upgrades) {
      if (u.effectType == 'COMBO_BOOST') {
        comboBonusFactor += u.currentLevel * u.effectValue;
      }
    }
    double metaComboFactor =
        1.0 + (_stats.metaComboLevel * 0.15); // Rhythm Drums
    double comboMultiplier =
        1.0 + (baseComboBonus * comboBonusFactor * metaComboFactor);
    bpc *= comboMultiplier;

    // 2. Golden banana tap active multiplier (2x)
    if (isGoldenTapActive) {
      bpc *= 2.0;
    }

    // 3. Skin multipliers
    double skinMultiplier = 1.0;
    final activeSkin = activeSkinIdForCurrentMap;
    if (activeSkin == 'jungle_skin1')
      skinMultiplier += 0.05; // +5% click power (Explorer skin)
    if (activeSkin == 'golden_kingdom_default')
      skinMultiplier += 0.25; // +25% click power / all income
    bpc *= skinMultiplier;

    // 4. Level-up bonus (+1% all income per level)
    final double levelBonus = 1.0 + (_stats.level - 1) * 0.01;
    bpc *= levelBonus;

    // 5. Prestige golden seeds multiplier (+5% all income per golden seed)
    final double prestigeBonus = 1.0 + _stats.goldenSeeds * 0.05;
    bpc *= prestigeBonus;

    // 6. Skill Tree nodes
    if (_isSkillUnlocked('strong_fingers')) {
      bpc *= 1.10; // +10% click power
    }

    // 7. Global income multiplier upgrades (Jungle Market, Royal Banana Crown, etc.)
    double globalMult = 1.0;
    for (var u in _upgrades) {
      if (u.effectType == 'GLOBAL_MULT') {
        globalMult += u.currentLevel * u.effectValue;
      }
    }
    bpc *= globalMult;

    // 8. Permanent Meta click boost (Obsidian Grips) and income boost (Golden Fertilizer)
    double metaClickMult = 1.0 + (_stats.metaClickLevel * 0.10);
    double metaIncomeMult = 1.0 + (_stats.metaIncomeLevel * 0.10);
    bpc *= metaClickMult * metaIncomeMult;

    // 9. Current Map Income Multiplier
    bpc *= currentMapProgression.worldIncomeMultiplier;

    return bpc;
  }

  double calculateBaseBps() {
    double addBps = 0.0;
    double helperBoost = 1.0;
    for (var u in _upgrades) {
      if (u.effectType == 'ADD_BPS') {
        addBps += u.currentLevel * u.effectValue;
      } else if (u.effectType == 'HELPER_BOOST') {
        helperBoost += u.currentLevel * u.effectValue;
      }
    }
    return addBps * helperBoost;
  }

  double calculateCurrentBps() {
    double bps = calculateBaseBps();

    // Golden idle active multiplier (2x)
    if (isGoldenIdleActive) {
      bps *= 2.0;
    }

    // Skins multiplier
    double skinMultiplier = 1.0;
    final activeSkin = activeSkinIdForCurrentMap;
    if (activeSkin == 'golden_kingdom_default')
      skinMultiplier += 0.25; // +25% all income
    bps *= skinMultiplier;

    // Level-up multiplier
    final double levelBonus = 1.0 + (_stats.level - 1) * 0.01;
    bps *= levelBonus;

    // Prestige Golden Seeds multiplier
    final double prestigeBonus = 1.0 + _stats.goldenSeeds * 0.05;
    bps *= prestigeBonus;

    // Skill Tree nodes
    if (_isSkillUnlocked('faster_helpers')) {
      bps *= 1.10; // +10% helper idle income
    }

    // Global income multiplier upgrades
    double globalMult = 1.0;
    for (var u in _upgrades) {
      if (u.effectType == 'GLOBAL_MULT') {
        globalMult += u.currentLevel * u.effectValue;
      }
    }
    bps *= globalMult;

    // Permanent Meta idle boost (Lazy Sloth Helpers) and income boost (Golden Fertilizer)
    double metaIdleMult = 1.0 + (_stats.metaIdleLevel * 0.10);
    double metaIncomeMult = 1.0 + (_stats.metaIncomeLevel * 0.10);
    bps *= metaIdleMult * metaIncomeMult;

    // Current Map Income Multiplier
    bps *= currentMapProgression.worldIncomeMultiplier;

    return bps;
  }

  double _calculateOfflineMultiplier() {
    double offlineMult = 1.0;
    for (var u in _upgrades) {
      if (u.effectType == 'OFFLINE_EARN') {
        offlineMult += u.currentLevel * u.effectValue;
      }
    }
    return offlineMult;
  }

  bool _isSkillUnlocked(String id) {
    return _stats.unlockedSkills.contains(id);
  }

  double _getGlobalIncomeMultiplier() {
    return 1.0;
  }

  String _formatVal(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toInt().toString();
    }
  }

  // ---------- Quest Progress Checks ----------
  double _getQuestProgressValue(String type, String layer) {
    if (layer == 'daily') {
      switch (type) {
        case 'clicks':
          return _stats.dailyClicks.toDouble();
        case 'bananas':
          return _stats.dailyBananas;
        case 'golden':
          return _stats.dailyGolden.toDouble();
        case 'combo':
          return _stats.dailyMaxCombo.toDouble();
        case 'upgrades':
          return _stats.dailyUpgrades.toDouble();
      }
    } else if (layer == 'weekly') {
      switch (type) {
        case 'clicks':
          return _stats.weeklyClicks.toDouble();
        case 'bananas':
          return _stats.weeklyBananas;
        case 'golden':
          return _stats.weeklyGolden.toDouble();
        case 'crits':
          return _stats.weeklyCrits.toDouble();
      }
    }
    switch (type) {
      case 'clicks':
        return _stats.questClicks.toDouble();
      case 'bananas':
        return _stats.questBananasEarned;
      case 'upgrades':
        return _stats.questUpgradesBought.toDouble();
      case 'golden':
        return _stats.questGoldenBananasCollected.toDouble();
      case 'combo':
        return _stats.questMaxComboReached.toDouble();
      case 'crits':
        return _stats.questCritsTriggered.toDouble();
      case 'level':
        return _stats.level.toDouble();
      case 'rebirth':
        return _stats.prestigeLevel.toDouble();
      case 'relics':
        return _stats.jungleRelics.toDouble();
      case 'skins':
        return _stats.unlockedSkins.length.toDouble();
      default:
        return 0.0;
    }
  }

  void _checkQuests() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastQuestCheckTimestamp < 500) return;
    
    _quests = _quests.map((quest) {
      final double currentVal = _getQuestProgressValue(quest.type, quest.layer);
      final completed = currentVal >= quest.targetValue;
      return quest.copyWith(completed: completed, progress: currentVal);
    }).toList();
  }

  // ---------- Achievements Unlock Checks ----------
  void _checkAchievements() {
    final nowCheck = DateTime.now().millisecondsSinceEpoch;
    if (nowCheck - _lastQuestCheckTimestamp < 500) return;
    _lastQuestCheckTimestamp = nowCheck; // Update the throttle timestamp here since this is called right after _checkQuests
    
    bool updated = false;

    final Map<String, bool> conditions = {
      'first_banana': _stats.questBananasEarned >= 1.0,
      'banana_beginner': _stats.questBananasEarned >= 1000.0,
      'banana_collector': _stats.questBananasEarned >= 10000.0,
      'banana_millionaire': _stats.questBananasEarned >= 1000000.0,
      'banana_billionaire': _stats.questBananasEarned >= 1000000000.0,
      'banana_tycoon': _stats.questBananasEarned >= 10000000000.0,
      'first_click': _stats.questClicks >= 1,
      'monkey_friend': _stats.questClicks >= 500,
      'monkey_lover': _stats.questClicks >= 2000,
      'monkey_devotee': _stats.questClicks >= 10000,
      'combo_beginner': _stats.questMaxComboReached >= 10,
      'combo_master': _stats.questMaxComboReached >= 30,
      'combo_grandmaster': _stats.questMaxComboReached >= 50,
      'first_crit': _stats.questCritsTriggered >= 1,
      'crit_striker': _stats.questCritsTriggered >= 50,
      'crit_master': _stats.questCritsTriggered >= 200,
      'first_golden': _stats.questGoldenBananasCollected >= 1,
      'golden_hunter': _stats.questGoldenBananasCollected >= 10,
      'golden_collector': _stats.questGoldenBananasCollected >= 50,
      'first_relic': _stats.jungleRelics >= 1,
      'relic_collector': _stats.jungleRelics >= 3,
      'relic_hoarder': _stats.jungleRelics >= 8,
      'map_unlocked_2': _stats.unlockedMaps.contains('banana_village'),
      'map_unlocked_3': _stats.unlockedMaps.contains('volcano_island'),
      'map_unlocked_6': _stats.unlockedMaps.contains('golden_kingdom'),
      'skin_collector_2': _stats.unlockedSkins.length >= 2,
      'skin_collector_5': _stats.unlockedSkins.length >= 5,
      'first_rebirth': _stats.prestigeLevel >= 1,
      'rebirth_3': _stats.prestigeLevel >= 3,
      'rebirth_10': _stats.prestigeLevel >= 10,
    };

    _achievements = _achievements.map((ach) {
      final bool met = conditions[ach.id] ?? false;
      if (met && !ach.unlocked) {
        updated = true;
        final now = DateTime.now().millisecondsSinceEpoch;

        // Trigger notification sound / banner
        HapticFeedback.mediumImpact();
        _audioService.playQuestComplete();
        _achievementUnlockNotification = 'ACHIEVEMENT UNLOCKED: ${ach.title}';

        Timer(const Duration(milliseconds: 3000), () {
          _achievementUnlockNotification = null;
          notifyListeners();
        });

        // Add to unlocked list in stats
        _stats = _stats.copyWith(
          unlockedAchievements: {..._stats.unlockedAchievements, ach.id},
        );

        return ach.copyWith(unlocked: true, unlockedAt: now);
      }
      return ach;
    }).toList();

    if (updated) {
      notifyListeners();
      _saveStats();
    }
  }

  @override
  void dispose() {
    _passiveIncomeTimer?.cancel();
    _autoSaveTimer?.cancel();
    _comboDecayTimer?.cancel();
    _goldenBananaSpawnTimer?.cancel();
    _goldenBananaTimeoutTimer?.cancel();
    super.dispose();
  }
}
