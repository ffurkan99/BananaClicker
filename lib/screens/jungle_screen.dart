import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../widgets/monkey_hero_area.dart';
import '../widgets/income_strip.dart';
import '../widgets/upgrades_title_banner.dart';
import '../widgets/quick_upgrade_card.dart';
import '../theme/pixel_theme.dart';

class JungleScreen extends StatelessWidget {
  const JungleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final stats = controller.stats;
    final theme = controller.selectedMapTheme;

    // Calculate XP percentage
    final double neededXp = 100.0 * pow(1.5, stats.level - 1);
    final double xpProgress = (stats.xp / neededXp).clamp(0.0, 1.0);

    return Stack(
      children: [
        // 1. Scrollable Content
        ListView(
          padding: const EdgeInsets.only(bottom: 110.0),
          children: [
            // Level and XP progression Sign
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      'MONKEY LV. ${stats.level}',
                      style: PixelTheme.pixelStyle(
                        fontSize: 8,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 10,
                      width: 145,
                      decoration: BoxDecoration(
                        color: theme.darkBorderColor,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: theme.darkBorderColor, width: 2),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: xpProgress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: PixelColors.bananaYellow,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Income Strip showing rates
            IncomeStrip(
              bananasPerClick: stats.bananasPerClick,
              bananasPerSecond: stats.bananasPerSecond,
              darkBorderColor: theme.darkBorderColor,
            ),

            // Clicking Area
            MonkeyHeroArea(
              comboCount: controller.comboCount,
              comboProgress: controller.comboProgress,
              onMonkeyTap: controller.tapMonkey,
            ),
            
            // UPGRADES Title Divider Signboard
            UpgradesTitleBanner(
              darkBorderColor: theme.darkBorderColor,
            ),
            
            // Render exactly 2 quick upgrade cards (Banana Boost & Monkey Helper)
            ...controller.upgrades.where((u) => u.id == 'banana_boost').map((upgrade) {
              return QuickUpgradeCard(
                upgrade: upgrade,
                totalBananas: stats.totalBananas,
                worldCostMultiplier: controller.currentMapProgression.worldCostMultiplier,
                onBuy: () => controller.buyUpgrade(upgrade),
                darkBorderColor: theme.darkBorderColor,
                cardBaseColor: theme.cardBaseColor,
                cardTrimColor: theme.cardTrimColor,
                decorations: const ['🌿', '🍃'],
                cardFramePath: theme.cardFramePath,
              );
            }).toList(),

            ...controller.upgrades.where((u) => u.id == 'monkey_helper').map((upgrade) {
              return QuickUpgradeCard(
                upgrade: upgrade,
                totalBananas: stats.totalBananas,
                worldCostMultiplier: controller.currentMapProgression.worldCostMultiplier,
                onBuy: () => controller.buyUpgrade(upgrade),
                darkBorderColor: theme.darkBorderColor,
                cardBaseColor: theme.cardBaseColor,
                cardTrimColor: theme.cardTrimColor,
                decorations: const ['🌱', '🌿'],
                cardFramePath: theme.cardFramePath,
              );
            }).toList(),
          ],
        ),

        // 3. Banana Rain Event Overlay (falling bananas)
        ...controller.fallingBananas.map((banana) {
          return Positioned(
            left: MediaQuery.of(context).size.width * banana.x,
            top: banana.y,
            child: GestureDetector(
              onTapDown: (_) {
                controller.tapFallingBanana(banana.id);
              },
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/images/icons/banana.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
