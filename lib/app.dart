import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/game_controller.dart';
import 'theme/pixel_theme.dart';
import 'widgets/banana_header.dart';
import 'widgets/banana_counter.dart';
import 'widgets/pixel_bottom_nav_bar.dart';
import 'widgets/offline_reward_dialog.dart';
import 'models/map_theme.dart';

import 'screens/jungle_screen.dart';
import 'screens/upgrades_screen.dart';
import 'screens/quests_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/prestige_screen.dart';
import 'screens/skill_tree_screen.dart';
import 'screens/world_map_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monkey Banana',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.yellow,
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const BananaClickerApp(),
    );
  }
}

class BananaClickerApp extends StatefulWidget {
  const BananaClickerApp({Key? key}) : super(key: key);

  @override
  State<BananaClickerApp> createState() => _BananaClickerAppState();
}

class _BananaClickerAppState extends State<BananaClickerApp> {
  GameTab _selectedTab = GameTab.jungle;
  bool _showSettings = false;
  bool _showPrestige = false;
  bool _showSkillTree = false;
  final TextEditingController _cheatBalanceController = TextEditingController();

  @override
  void dispose() {
    _cheatBalanceController.dispose();
    super.dispose();
  }

  Widget _buildSelectedScreen() {
    switch (_selectedTab) {
      case GameTab.jungle:
        return const JungleScreen();
      case GameTab.upgrades:
        return const UpgradesScreen();
      case GameTab.world:
        return const WorldMapScreen();
      case GameTab.quests:
        return const QuestsScreen();
      case GameTab.shop:
        return const ShopScreen();
    }
  }

  String _getMapBackgroundAsset(MapTheme theme) {
    return theme.backgroundPath;
  }

  Color _getMapTint(MapTheme theme) {
    switch (theme.id) {
      case 'banana_village':
        return theme.primaryColor.withOpacity(0.18); // Sunset warm amber
      case 'volcano_island':
        return theme.primaryColor.withOpacity(0.25); // Fiery magma red
      case 'ancient_temple':
        return theme.primaryColor.withOpacity(0.20); // Moss jade/teal green ruins
      case 'cloud_jungle':
        return theme.primaryColor.withOpacity(0.22); // Sky blue
      case 'golden_kingdom':
        return theme.primaryColor.withOpacity(0.28); // Divine gold
      default:
        return Colors.transparent; // Jungle default green tint
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final stats = controller.stats;
    final theme = controller.selectedMapTheme;

    final hasUpgradeable = controller.upgrades.any((u) =>
        u.currentLevel < u.maxLevel &&
        stats.totalBananas >= u.getCost(controller.currentMapProgression.worldCostMultiplier));
    final hasClaimableQuest = controller.quests.any((q) => q.completed && !q.claimed);
    final hasWorldTravelReady = stats.totalBananas >= controller.currentMapProgression.unlockTarget &&
        controller.currentMapProgression.worldIndex < controller.mapProgressions.length;
    final glowingTabs = <GameTab>{
      if (hasUpgradeable) GameTab.upgrades,
      if (hasClaimableQuest) GameTab.quests,
      if (hasWorldTravelReady) GameTab.world,
    };

    return Scaffold(
      body: Stack(
        children: [
          // 1. Jungle Background Image (Dynamic based on selected Map Theme)
          Positioned.fill(
            child: Image.asset(
              _getMapBackgroundAsset(theme),
              fit: BoxFit.cover,
              filterQuality: FilterQuality.none,
            ),
          ),
          
          // Map Theme tint overlay
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: _getMapTint(theme),
              ),
            ),
          ),
          
          // 2. Dim overlay for readability
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.15),
            ),
          ),

          // 3. Centered and constrained mobile game canvas
          Center(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 480, // Portrait mobile canvas width constraint
              ),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 25,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Main layout content
                  Column(
                    children: [
                      // Header top bar
                      BananaHeader(
                        darkBorderColor: theme.darkBorderColor,
                        primaryColor: theme.primaryColor,
                        onShopClick: () {
                          // Top left gold coin button takes them to Prestige/Rebirth screen!
                          setState(() {
                            _showPrestige = true;
                          });
                        },
                        onSettingsClick: () {
                          setState(() {
                            _showSettings = true;
                          });
                        },
                      ),

                      // Currency & rate displays
                      BananaCounter(
                        totalBananas: stats.totalBananas,
                        bananasPerClick: stats.bananasPerClick,
                        bananasPerSecond: stats.bananasPerSecond,
                        isGoldenActive: controller.isGoldenTapActive || controller.isGoldenIdleActive,
                        darkBorderColor: theme.darkBorderColor,
                      ),

                      const SizedBox(height: 4),

                      // Active Tab Content
                      Expanded(
                        child: _buildSelectedScreen(),
                      ),

                      // Wooden Bottom Navigation Bar
                      PixelBottomNavBar(
                        selectedTab: _selectedTab,
                        onTabSelected: (tab) {
                          setState(() {
                            _selectedTab = tab;
                          });
                        },
                        darkBorderColor: theme.darkBorderColor,
                        activeColor: theme.primaryColor,
                        glowingTabs: glowingTabs,
                      ),
                    ],
                  ),

                  // 4. Custom Settings Dialog Overlay
                  if (_showSettings) _buildSettingsOverlay(context, controller),

                  // 5. Prestige Overlay Screen
                  if (_showPrestige)
                    PrestigeScreen(
                      onClose: () {
                        setState(() {
                          _showPrestige = false;
                        });
                      },
                      onOpenSkillTree: () {
                        setState(() {
                          _showPrestige = false;
                          _showSkillTree = true;
                        });
                      },
                    ),

                  // 6. Skill Tree Overlay Screen
                  if (_showSkillTree)
                    SkillTreeScreen(
                      onClose: () {
                        setState(() {
                          _showSkillTree = false;
                          _showPrestige = true; // Return to prestige screen
                        });
                      },
                    ),

                  // 7. Welcome Back / Offline Earnings Dialog Overlay
                  if (controller.showOfflineDialog)
                    OfflineRewardDialog(
                      pendingEarnings: controller.pendingOfflineEarnings,
                      elapsedHours: controller.offlineTimePassedHours,
                      clampedHours: controller.offlineTimeClampedHours,
                      onClaim: () {
                        controller.dismissOfflineDialog();
                      },
                      darkBorderColor: theme.darkBorderColor,
                      uiThemePath: theme.uiThemePath,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsOverlay(BuildContext context, GameController controller) {
    final theme = controller.selectedMapTheme;
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              decoration: BoxDecoration(
                color: PixelColors.creamWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.darkBorderColor, width: 4),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    offset: Offset(0, 8),
                    blurRadius: 0,
                  )
                ],
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title Banner
                  Text(
                    '★ SETTINGS ★',
                    style: PixelTheme.pixelStyle(
                      fontSize: 14,
                      color: theme.darkBorderColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Info/Stats block
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: PixelColors.creamLight.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: theme.darkBorderColor.withOpacity(0.6), width: 2),
                    ),
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatRow('Clicks:', _formatVal(controller.stats.questClicks.toDouble())),
                        const SizedBox(height: 6),
                        _buildStatRow('Max Combo:', 'x${controller.stats.questMaxComboReached}'),
                        const SizedBox(height: 6),
                        _buildStatRow('Golden Taps:', _formatVal(controller.stats.questGoldenBananasCollected.toDouble())),
                        const SizedBox(height: 6),
                        _buildStatRow('Total Earned:', _formatVal(controller.stats.questBananasEarned)),
                        const SizedBox(height: 6),
                        _buildStatRow('Prestige Level:', '${controller.stats.prestigeLevel}'),
                        const SizedBox(height: 6),
                        _buildStatRow('Golden Seeds:', '${controller.stats.goldenSeeds}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: PixelColors.creamLight.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: theme.darkBorderColor.withOpacity(0.6), width: 2),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _cheatBalanceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Enter Banana Amount',
                              hintStyle: PixelTheme.bodyStyle(fontSize: 12, color: Colors.grey),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: theme.darkBorderColor, width: 1.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            style: PixelTheme.pixelStyle(fontSize: 8, color: theme.darkBorderColor),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            final double? amount = double.tryParse(_cheatBalanceController.text);
                            if (amount != null && amount > 0) {
                              controller.debugAddBananas(amount);
                              _cheatBalanceController.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: theme.primaryColor,
                                  content: Text(
                                    'ADDED ${amount.toInt()} BANANAS!',
                                    style: PixelTheme.pixelStyle(fontSize: 8, color: Colors.white),
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: theme.darkBorderColor, width: 2.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: PixelColors.softShadow,
                                  offset: Offset(0, 2),
                                  blurRadius: 0,
                                )
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                            child: Text(
                              'ADD',
                              style: PixelTheme.pixelStyle(
                                fontSize: 8,
                                color: PixelColors.creamWhite,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Actions
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Close button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showSettings = false;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: theme.darkBorderColor, width: 2.5),
                            boxShadow: const [
                              BoxShadow(
                                color: PixelColors.softShadow,
                                offset: Offset(0, 2),
                                blurRadius: 0,
                              )
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Center(
                            child: Text(
                              'CLOSE',
                              style: PixelTheme.pixelStyle(
                                fontSize: 8,
                                color: PixelColors.creamWhite,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Reset Game button (red, labeled RESET PROGRESS)
                      GestureDetector(
                        onTap: () {
                          _showResetConfirmation(context, controller);
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD32F2F), // Red
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: theme.darkBorderColor, width: 2.5),
                            boxShadow: const [
                              BoxShadow(
                                color: PixelColors.softShadow,
                                offset: Offset(0, 2),
                                blurRadius: 0,
                              )
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Center(
                            child: Text(
                              'RESET PROGRESS',
                              style: PixelTheme.pixelStyle(
                                fontSize: 8,
                                color: PixelColors.creamWhite,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, GameController controller) {
    final TextEditingController textController = TextEditingController();
    bool isResetInputValid = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: PixelColors.creamWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: PixelColors.darkBrown, width: 4),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      offset: Offset(0, 8),
                      blurRadius: 0,
                    )
                  ],
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'WARNING!',
                      style: PixelTheme.pixelStyle(
                        fontSize: 12,
                        color: const Color(0xFFD32F2F),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This will permanently delete all your bananas, skins, upgrades, and progression! You cannot undo this.',
                      style: PixelTheme.bodyStyle(
                        fontSize: 13,
                        color: PixelColors.darkBrown,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Type "RESET" to confirm:',
                      style: PixelTheme.pixelStyle(
                        fontSize: 7.5,
                        color: PixelColors.mediumBrown,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: textController,
                      onChanged: (val) {
                        setDialogState(() {
                          isResetInputValid = val.trim() == 'RESET';
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'RESET',
                        hintStyle: PixelTheme.bodyStyle(fontSize: 12, color: Colors.grey),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: PixelColors.darkBrown, width: 2.0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: const Color(0xFFD32F2F), width: 2.0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      style: PixelTheme.pixelStyle(fontSize: 8, color: PixelColors.darkBrown),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              textController.dispose();
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: PixelColors.jungleGreen,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: PixelColors.darkBrown, width: 2),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                              child: Center(
                                child: Text(
                                  'CANCEL',
                                  style: PixelTheme.pixelStyle(
                                      fontSize: 8, color: PixelColors.creamWhite),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: isResetInputValid
                                ? () async {
                                    await controller.resetGame();
                                    textController.dispose();
                                    Navigator.of(context).pop();
                                    setState(() {
                                      _showSettings = false;
                                      _selectedTab = GameTab.jungle;
                                    });
                                  }
                                : null,
                            child: Opacity(
                              opacity: isResetInputValid ? 1.0 : 0.5,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD32F2F),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: PixelColors.darkBrown, width: 2),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 10.0),
                                child: Center(
                                  child: Text(
                                    'CONFIRM',
                                    style: PixelTheme.pixelStyle(
                                        fontSize: 8, color: PixelColors.creamWhite),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: PixelTheme.pixelStyle(
            fontSize: 7,
            color: PixelColors.mediumBrown,
          ),
        ),
        Text(
          value,
          style: PixelTheme.pixelStyle(
            fontSize: 7,
            color: PixelColors.darkBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
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
}
