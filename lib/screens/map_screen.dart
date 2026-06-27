import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../models/meta_bonus.dart';
import '../widgets/map_progress_card.dart';
import '../theme/pixel_theme.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  void _showTravelConfirmation(BuildContext context, GameController controller, String nextMapName, int relics) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
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
                const Text(
                  'TRAVEL TO NEW MAP?',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Pixel',
                    fontWeight: FontWeight.bold,
                    color: PixelColors.jungleGreenDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Traveling to $nextMapName will reset your current run bananas and regular upgrades.\n\nIn return, you will gain +$relics Jungle Relics and enter a New Game+ run with much higher income multipliers!',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Pixel',
                    height: 1.4,
                    color: PixelColors.darkBrown,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: PixelColors.warmOrange,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: PixelColors.darkBrown, width: 2),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Center(
                            child: Text(
                              'CANCEL',
                              style: PixelTheme.pixelStyle(
                                fontSize: 8,
                                color: PixelColors.creamWhite,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          controller.travelToNextMap();
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
                              'TRAVEL!',
                              style: PixelTheme.pixelStyle(
                                fontSize: 8,
                                color: PixelColors.creamWhite,
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
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final stats = controller.stats;
    final currentMap = controller.currentMapProgression;

    // Find next map
    final nextWorldIndex = currentMap.worldIndex + 1;
    final nextMap = controller.mapProgressions.firstWhere(
      (m) => m.worldIndex == nextWorldIndex,
      orElse: () => currentMap, // dummy self if none
    );
    final hasNext = nextWorldIndex <= controller.mapProgressions.length;

    return ListView(
      padding: const EdgeInsets.only(bottom: 110.0),
      children: [
        // Title Banner
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 2.0),
          child: Text(
            '★ WORLD CAMPAIGN ★',
            style: PixelTheme.pixelStyle(
              fontSize: 10,
              color: PixelColors.bananaYellow,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Permanent Relics Balance Indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF8D6E63), // Wooden brown
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: PixelColors.darkBrown, width: 2.5),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🏺', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Text(
                  'JUNGLE RELICS: ${stats.jungleRelics}',
                  style: PixelTheme.pixelStyle(
                    fontSize: 9,
                    color: PixelColors.creamWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // World progression status card
        MapProgressCard(
          currentMap: currentMap,
          nextMap: hasNext ? nextMap : null,
          totalBananas: stats.totalBananas,
          onTravel: () {
            if (hasNext) {
              _showTravelConfirmation(context, controller, nextMap.name, currentMap.relicsReward);
            }
          },
        ),

        // Relic Meta Shop Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🏺 PERMANENT RELIC SHOP 🏺',
                style: PixelTheme.pixelStyle(
                  fontSize: 8,
                  color: PixelColors.bananaYellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Purchases here persist across all worlds.',
                style: PixelTheme.bodyStyle(
                  fontSize: 11,
                  color: const Color(0xFFC8E6C9),
                ),
              ),
            ],
          ),
        ),

        // Meta upgrades cards
        ...controller.metaBonuses.map((bonus) {
          final isMaxed = bonus.currentLevel >= bonus.maxLevel;
          final nextCost = bonus.nextCost;
          final canAfford = stats.jungleRelics >= nextCost;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: Container(
              decoration: BoxDecoration(
                color: PixelColors.creamWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PixelColors.darkBrown, width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: PixelColors.softShadow,
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  )
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Left side mini panel representing meta upgrades
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA1887F),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: PixelColors.darkBrown, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _getMetaIcon(bonus.id),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Center: Info details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bonus.name.toUpperCase(),
                          style: PixelTheme.pixelStyle(
                            fontSize: 8.5,
                            color: PixelColors.darkBrown,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          bonus.description,
                          style: PixelTheme.bodyStyle(
                            fontSize: 10.5,
                            color: const Color(0xFF5D4037),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Level Indicator
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: PixelColors.jungleGreen.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: PixelColors.jungleGreen.withOpacity(0.3), width: 1),
                          ),
                          child: Text(
                            'Lv. ${bonus.currentLevel} / ${bonus.maxLevel}',
                            style: PixelTheme.pixelStyle(
                              fontSize: 5.5,
                              color: PixelColors.jungleGreenDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Right: Action button
                  if (isMaxed)
                    Container(
                      width: 80,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD54F),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFFA000), width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'MAX',
                        style: PixelTheme.pixelStyle(
                          fontSize: 7.5,
                          color: PixelColors.darkBrown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: canAfford ? () => controller.buyMetaBonus(bonus.id) : null,
                      child: Container(
                        width: 80,
                        height: 36,
                        decoration: BoxDecoration(
                          color: canAfford ? PixelColors.jungleGreen : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: canAfford ? PixelColors.jungleGreenDark : Colors.grey.shade500,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🏺', style: TextStyle(fontSize: 8)),
                            const SizedBox(width: 2),
                            Text(
                              '$nextCost',
                              style: PixelTheme.pixelStyle(
                                fontSize: 7.5,
                                color: canAfford ? PixelColors.creamWhite : Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  String _getMetaIcon(String id) {
    switch (id) {
      case 'income':
        return '🌱';
      case 'click':
        return '👊';
      case 'idle':
        return '🦥';
      case 'golden':
        return '✨';
      case 'combo':
        return '🥁';
      default:
        return '🏺';
    }
  }
}
