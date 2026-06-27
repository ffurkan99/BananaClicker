import 'package:flutter/material.dart';
import '../models/upgrade.dart';
import '../theme/pixel_theme.dart';
import 'banana_counter.dart';

class QuickUpgradeCard extends StatelessWidget {
  final Upgrade upgrade;
  final double totalBananas;
  final double worldCostMultiplier;
  final VoidCallback onBuy;
  final Color darkBorderColor;
  final Color cardBaseColor;
  final Color cardTrimColor;
  final List<String> decorations;
  final String? cardFramePath;

  const QuickUpgradeCard({
    Key? key,
    required this.upgrade,
    required this.totalBananas,
    required this.worldCostMultiplier,
    required this.onBuy,
    this.darkBorderColor = PixelColors.darkBrown,
    this.cardBaseColor = const Color(0xFF2E7D32),
    this.cardTrimColor = const Color(0xFF1B5E20),
    this.decorations = const ['🌿', '🍃', '🌱', '🌿'],
    this.cardFramePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cost = upgrade.getCost(worldCostMultiplier);
    final canAfford = totalBananas >= cost;
    final isMaxed = upgrade.currentLevel >= upgrade.maxLevel;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main card panel - solid cream parchment background
          Container(
            decoration: BoxDecoration(
              color: PixelColors.creamWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: darkBorderColor, width: 3.5),
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
                // Icon Frame (Golden)
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD54F),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: darkBorderColor, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0, 2),
                        blurRadius: 0,
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(
                    upgrade.imagePath,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.none,
                  ),
                ),
                const SizedBox(width: 12),

                // Center Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        upgrade.name.toUpperCase(),
                        style: PixelTheme.pixelStyle(
                          fontSize: 8,
                          color: PixelColors.darkBrown,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      // Description
                      Text(
                        upgrade.description,
                        style: PixelTheme.bodyStyle(
                          fontSize: 10,
                          color: PixelColors.mediumBrown,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Level Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: cardBaseColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: cardTrimColor.withOpacity(0.3), width: 1.2),
                        ),
                        child: Text(
                          upgrade.isRepeatable
                              ? 'Lv. ${upgrade.currentLevel}'
                              : 'Lv. ${upgrade.currentLevel} / ${upgrade.maxLevel}',
                          style: PixelTheme.pixelStyle(
                            fontSize: 5.5,
                            color: cardTrimColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Buy Action Button
                if (isMaxed)
                  Container(
                    width: 78,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD54F),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFA000), width: 2.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'MAX',
                      style: PixelTheme.pixelStyle(
                        fontSize: 7,
                        color: PixelColors.darkBrown,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: canAfford ? onBuy : null,
                    child: Container(
                      width: 78,
                      height: 36,
                      decoration: BoxDecoration(
                        color: canAfford ? PixelColors.jungleGreen : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: canAfford ? PixelColors.jungleGreenDark : Colors.grey.shade500,
                          width: 2.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: PixelColors.softShadow,
                            offset: Offset(0, 2),
                            blurRadius: 0,
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/icons/banana.png',
                            width: 10,
                            height: 10,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.none,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            BananaCounter.formatNumber(cost),
                            style: PixelTheme.pixelStyle(
                              fontSize: 7,
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

          // Vine Corner Decoration
          if (decorations.isNotEmpty) ...[
            Positioned(
              top: -6,
              left: -4,
              child: Text(decorations[0], style: const TextStyle(fontSize: 14)),
            ),
            Positioned(
              top: -6,
              right: -4,
              child: Text(decorations.length > 1 ? decorations[1] : decorations[0], style: const TextStyle(fontSize: 14)),
            ),
          ],
        ],
      ),
    );
  }
}
