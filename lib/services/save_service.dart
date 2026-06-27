import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_stats.dart';
import '../models/upgrade.dart';

class SaveService {
  static const String _keyBananas = 'total_bananas';
  static const String _keyBpc = 'bananas_per_click';
  static const String _keyBps = 'bananas_per_second';
  static const String _keyLastSaved = 'last_saved_time';
  
  static const String _keyQuestClicks = 'quest_clicks';
  static const String _keyQuestBananas = 'quest_bananas_earned';
  static const String _keyQuestUpgrades = 'quest_upgrades_bought';
  static const String _keyQuestGolden = 'quest_golden_collected';
  static const String _keyQuestMaxCombo = 'quest_max_combo';
  static const String _keyQuestCrits = 'quest_crits_triggered';
  static const String _keyClaimedQuests = 'claimed_quests';
  static const String _keyUnlockedAchievements = 'unlocked_achievements';
  
  static const String _keyUnlockedSkins = 'unlocked_skins';
  static const String _keyEquippedSkin = 'equipped_skin';

  static const String _keyUnlockedMaps = 'unlocked_maps';
  static const String _keyEquippedMap = 'equipped_map';

  static const String _keyLevel = 'monkey_level';
  static const String _keyXp = 'monkey_xp';

  static const String _keyPrestige = 'prestige_level';
  static const String _keyGoldenSeeds = 'golden_seeds';

  static const String _keyUnlockedSkills = 'unlocked_skills';
  static const String _keyOfflineMultiplier = 'offline_earnings_multiplier';

  static const String _keyDailyClicks = 'daily_quest_clicks';
  static const String _keyDailyBananas = 'daily_quest_bananas';
  static const String _keyDailyGolden = 'daily_quest_golden';
  static const String _keyDailyMaxCombo = 'daily_quest_max_combo';
  static const String _keyDailyUpgrades = 'daily_quest_upgrades';
  static const String _keyWeeklyClicks = 'weekly_quest_clicks';
  static const String _keyWeeklyBananas = 'weekly_quest_bananas';
  static const String _keyWeeklyGolden = 'weekly_quest_golden';
  static const String _keyWeeklyCrits = 'weekly_quest_crits';

  static const String _keyJungleRelics = 'jungle_relics';
  static const String _keyMetaIncome = 'meta_income_level';
  static const String _keyMetaClick = 'meta_click_level';
  static const String _keyMetaIdle = 'meta_idle_level';
  static const String _keyMetaGolden = 'meta_golden_level';
  static const String _keyMetaCombo = 'meta_combo_level';

  static String _upgradeLevelKey(String id) => 'upgrade_level_$id';
  static String _upgradeCostKey(String id) => 'upgrade_cost_$id';

  // ---------- Load Stats ----------
  Future<PlayerStats> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Ensure all default skins are unlocked
    var unlockedSkins = prefs.getStringList(_keyUnlockedSkins) ?? [];
    final defaultSkins = [
      'jungle_default',
      'banana_village_default',
      'volcano_island_default',
      'ancient_temple_default',
      'cloud_jungle_default',
      'golden_kingdom_default',
    ];
    for (var defaultSkin in defaultSkins) {
      if (!unlockedSkins.contains(defaultSkin)) {
        unlockedSkins.add(defaultSkin);
      }
    }

    // Load equipped map skins mapping
    final equippedSkinsList = prefs.getStringList('equipped_skins_by_map') ?? [];
    final Map<String, String> equippedMapSkins = {
      'jungle': 'jungle_default',
      'banana_village': 'banana_village_default',
      'volcano_island': 'volcano_island_default',
      'ancient_temple': 'ancient_temple_default',
      'cloud_jungle': 'cloud_jungle_default',
      'golden_kingdom': 'golden_kingdom_default',
    };
    for (var item in equippedSkinsList) {
      final parts = item.split(':');
      if (parts.length == 2) {
        equippedMapSkins[parts[0]] = parts[1];
      }
    }

    return PlayerStats(
      totalBananas: prefs.getDouble(_keyBananas) ?? 0.0,
      bananasPerClick: prefs.getDouble(_keyBpc) ?? 1.0,
      bananasPerSecond: prefs.getDouble(_keyBps) ?? 0.0,
      lastSavedTime: prefs.getInt(_keyLastSaved) ?? DateTime.now().millisecondsSinceEpoch,
      
      questClicks: prefs.getInt(_keyQuestClicks) ?? 0,
      questBananasEarned: prefs.getDouble(_keyQuestBananas) ?? 0.0,
      questUpgradesBought: prefs.getInt(_keyQuestUpgrades) ?? 0,
      questGoldenBananasCollected: prefs.getInt(_keyQuestGolden) ?? 0,
      questMaxComboReached: prefs.getInt(_keyQuestMaxCombo) ?? 1,
      questCritsTriggered: prefs.getInt(_keyQuestCrits) ?? 0,
      dailyClicks: prefs.getInt(_keyDailyClicks) ?? 0,
      dailyBananas: prefs.getDouble(_keyDailyBananas) ?? 0.0,
      dailyGolden: prefs.getInt(_keyDailyGolden) ?? 0,
      dailyMaxCombo: prefs.getInt(_keyDailyMaxCombo) ?? 0,
      dailyUpgrades: prefs.getInt(_keyDailyUpgrades) ?? 0,
      weeklyClicks: prefs.getInt(_keyWeeklyClicks) ?? 0,
      weeklyBananas: prefs.getDouble(_keyWeeklyBananas) ?? 0.0,
      weeklyGolden: prefs.getInt(_keyWeeklyGolden) ?? 0,
      weeklyCrits: prefs.getInt(_keyWeeklyCrits) ?? 0,
      claimedQuests: (prefs.getStringList(_keyClaimedQuests) ?? []).toSet(),
      unlockedAchievements: (prefs.getStringList(_keyUnlockedAchievements) ?? []).toSet(),
      
      unlockedSkins: unlockedSkins,
      equippedMapSkins: equippedMapSkins,

      unlockedMaps: prefs.getStringList(_keyUnlockedMaps) ?? const ['jungle'],
      equippedMap: prefs.getString(_keyEquippedMap) ?? 'jungle',

      level: prefs.getInt(_keyLevel) ?? 1,
      xp: prefs.getDouble(_keyXp) ?? 0.0,

      prestigeLevel: prefs.getInt(_keyPrestige) ?? 0,
      goldenSeeds: prefs.getInt(_keyGoldenSeeds) ?? 0,

      unlockedSkills: prefs.getStringList(_keyUnlockedSkills) ?? const [],

      jungleRelics: prefs.getInt(_keyJungleRelics) ?? 0,
      metaIncomeLevel: prefs.getInt(_keyMetaIncome) ?? 0,
      metaClickLevel: prefs.getInt(_keyMetaClick) ?? 0,
      metaIdleLevel: prefs.getInt(_keyMetaIdle) ?? 0,
      metaGoldenLevel: prefs.getInt(_keyMetaGolden) ?? 0,
      metaComboLevel: prefs.getInt(_keyMetaCombo) ?? 0,
    );
  }

  // ---------- Save Stats ----------
  Future<void> saveStats(PlayerStats stats, double offlineMultiplier) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setDouble(_keyBananas, stats.totalBananas);
    await prefs.setDouble(_keyBpc, stats.bananasPerClick);
    await prefs.setDouble(_keyBps, stats.bananasPerSecond);
    await prefs.setInt(_keyLastSaved, DateTime.now().millisecondsSinceEpoch);
    
    await prefs.setInt(_keyQuestClicks, stats.questClicks);
    await prefs.setDouble(_keyQuestBananas, stats.questBananasEarned);
    await prefs.setInt(_keyQuestUpgrades, stats.questUpgradesBought);
    await prefs.setInt(_keyQuestGolden, stats.questGoldenBananasCollected);
    await prefs.setInt(_keyQuestMaxCombo, stats.questMaxComboReached);
    await prefs.setInt(_keyQuestCrits, stats.questCritsTriggered);
    await prefs.setInt(_keyDailyClicks, stats.dailyClicks);
    await prefs.setDouble(_keyDailyBananas, stats.dailyBananas);
    await prefs.setInt(_keyDailyGolden, stats.dailyGolden);
    await prefs.setInt(_keyDailyMaxCombo, stats.dailyMaxCombo);
    await prefs.setInt(_keyDailyUpgrades, stats.dailyUpgrades);
    await prefs.setInt(_keyWeeklyClicks, stats.weeklyClicks);
    await prefs.setDouble(_keyWeeklyBananas, stats.weeklyBananas);
    await prefs.setInt(_keyWeeklyGolden, stats.weeklyGolden);
    await prefs.setInt(_keyWeeklyCrits, stats.weeklyCrits);
    await prefs.setStringList(_keyClaimedQuests, stats.claimedQuests.toList());
    await prefs.setStringList(_keyUnlockedAchievements, stats.unlockedAchievements.toList());
    
    await prefs.setStringList(_keyUnlockedSkins, stats.unlockedSkins);
    final List<String> equippedSkinsList = stats.equippedMapSkins.entries
        .map((e) => '${e.key}:${e.value}')
        .toList();
    await prefs.setStringList('equipped_skins_by_map', equippedSkinsList);

    await prefs.setStringList(_keyUnlockedMaps, stats.unlockedMaps);
    await prefs.setString(_keyEquippedMap, stats.equippedMap);

    await prefs.setInt(_keyLevel, stats.level);
    await prefs.setDouble(_keyXp, stats.xp);

    await prefs.setInt(_keyPrestige, stats.prestigeLevel);
    await prefs.setInt(_keyGoldenSeeds, stats.goldenSeeds);

    await prefs.setStringList(_keyUnlockedSkills, stats.unlockedSkills);
    await prefs.setDouble(_keyOfflineMultiplier, offlineMultiplier);

    await prefs.setInt(_keyJungleRelics, stats.jungleRelics);
    await prefs.setInt(_keyMetaIncome, stats.metaIncomeLevel);
    await prefs.setInt(_keyMetaClick, stats.metaClickLevel);
    await prefs.setInt(_keyMetaIdle, stats.metaIdleLevel);
    await prefs.setInt(_keyMetaGolden, stats.metaGoldenLevel);
    await prefs.setInt(_keyMetaCombo, stats.metaComboLevel);
  }

  // ---------- Load Upgrades ----------
  Future<List<Upgrade>> loadUpgrades(List<Upgrade> baseUpgrades) async {
    final prefs = await SharedPreferences.getInstance();
    
    return baseUpgrades.map((upgrade) {
      final level = prefs.getInt(_upgradeLevelKey(upgrade.id)) ?? 0;
      return upgrade.copyWith(currentLevel: level);
    }).toList();
  }

  // ---------- Save Upgrades ----------
  Future<void> saveUpgrades(List<Upgrade> upgrades) async {
    final prefs = await SharedPreferences.getInstance();
    
    for (var upgrade in upgrades) {
      await prefs.setInt(_upgradeLevelKey(upgrade.id), upgrade.currentLevel);
    }
  }

  // ---------- Clear All Data ----------
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
