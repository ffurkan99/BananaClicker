import 'package:flutter/material.dart';
import '../theme/pixel_theme.dart';
import '../models/map_progression.dart';
import '../controllers/game_controller.dart';
import 'banana_counter.dart';

class MapProgressCard extends StatelessWidget {
  final MapProgression currentMap;
  final MapProgression? nextMap;
  final double totalBananas;
  final VoidCallback onTravel;

  const MapProgressCard({
    Key? key,
    required this.currentMap,
    required this.nextMap,
    required this.totalBananas,
    required this.onTravel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasUnlockedNext = nextMap != null && totalBananas >= currentMap.unlockTarget;
    final progress = (totalBananas / currentMap.unlockTarget).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: PixelColors.creamWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PixelColors.darkBrown, width: 4),
          boxShadow: const [
            BoxShadow(
              color: PixelColors.softShadow,
              offset: Offset(0, 6),
              blurRadius: 0,
            )
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map Name & World Index
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WORLD ${currentMap.worldIndex}',
                      style: PixelTheme.pixelStyle(
                        fontSize: 8,
                        color: PixelColors.mediumBrown,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentMap.name.toUpperCase(),
                      style: PixelTheme.pixelStyle(
                        fontSize: 14,
                        color: PixelColors.darkBrown,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Tiny map icon/badge
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: PixelColors.pixelGold,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: PixelColors.darkBrown, width: 2),
                  ),
                  child: const Text('🌴', style: TextStyle(fontSize: 14)),
                )
              ],
            ),

            const SizedBox(height: 16),
            const Divider(color: PixelColors.mediumBrown, thickness: 2),
            const SizedBox(height: 10),

            // World Multipliers Panel
            Text(
              'WORLD BONUSES',
              style: PixelTheme.pixelStyle(
                fontSize: 8,
                color: PixelColors.mediumBrown,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: PixelColors.creamLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: PixelColors.mediumBrown, width: 2),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildMultiplierRow('Income Multiplier:', 'x${currentMap.worldIncomeMultiplier.toInt()}'),
                  const SizedBox(height: 6),
                  _buildMultiplierRow('Upgrade Cost Multiplier:', 'x${currentMap.worldCostMultiplier.toInt()}'),
                  const SizedBox(height: 6),
                  _buildMultiplierRow('Golden Rewards:', 'x${currentMap.worldRewardMultiplier.toInt()}'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Progress towards Next Map
            if (nextMap != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'GOAL: REACH ${_formatVal(currentMap.unlockTarget)}',
                    style: PixelTheme.pixelStyle(
                      fontSize: 7.5,
                      color: PixelColors.darkBrown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: PixelTheme.pixelStyle(
                      fontSize: 7.5,
                      color: PixelColors.jungleGreenDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Progress Bar
              Container(
                height: 14,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: PixelColors.darkBrown,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: PixelColors.mediumBrown, width: 2.5),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Relics Reward teaser
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: PixelColors.jungleGreen, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🏺', style: TextStyle(fontSize: 10)),
                      const SizedBox(width: 4),
                      Text(
                        'REWARD UPON TRAVEL: +${currentMap.relicsReward} JUNGLE RELICS',
                        style: PixelTheme.pixelStyle(
                          fontSize: 6.0,
                          color: PixelColors.jungleGreenDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Travel Button
              GestureDetector(
                onTap: hasUnlockedNext ? onTravel : null,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: hasUnlockedNext
                        ? PixelColors.jungleGreen // Unlock color
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: hasUnlockedNext
                          ? PixelColors.jungleGreenDark
                          : Colors.grey.shade600,
                      width: 3,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 3),
                        blurRadius: 0,
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      hasUnlockedNext
                          ? 'TRAVEL TO ${nextMap!.name.toUpperCase()}'
                          : 'LOCKED (COLLECT MORE BANANAS)',
                      style: PixelTheme.pixelStyle(
                        fontSize: 9,
                        color: hasUnlockedNext ? PixelColors.creamWhite : Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Reached final map
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PixelColors.pixelGold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: PixelColors.pixelGold, width: 2),
                  ),
                  child: Text(
                    '👑 YOU HAVE REACHED THE GOLDEN KINGDOM! 👑\nMAX MAP LEVEL COMPLETED!',
                    style: PixelTheme.pixelStyle(
                      fontSize: 8,
                      color: PixelColors.darkBrown,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildMultiplierRow(String label, String val) {
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
          val,
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
      return '${(value / 1000000000).toStringAsFixed(0)}B';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(0)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    } else {
      return value.toInt().toString();
    }
  }
}
