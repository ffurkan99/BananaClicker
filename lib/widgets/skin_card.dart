import 'package:flutter/material.dart';
import '../models/skin.dart';
import '../theme/pixel_theme.dart';
import '../widgets/banana_counter.dart';

class SkinCard extends StatelessWidget {
  final Skin skin;
  final double totalBananas;
  final VoidCallback onTap;

  const SkinCard({
    Key? key,
    required this.skin,
    required this.totalBananas,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUnlocked = skin.isUnlocked;
    final isEquipped = skin.isEquipped;
    final canAfford = totalBananas >= skin.cost;

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
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Thumbnail Box
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: PixelColors.creamLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: PixelColors.darkBrown, width: 2),
              ),
              padding: const EdgeInsets.all(4.0),
              child: Image.asset(
                skin.imagePath,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.none,
              ),
            ),
            
            const SizedBox(width: 14),
            
            // Description & Title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    skin.name.toUpperCase(),
                    style: PixelTheme.pixelStyle(
                      fontSize: 9,
                      color: PixelColors.darkBrown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    skin.bonusDescription,
                    style: PixelTheme.bodyStyle(
                      fontSize: 12,
                      color: PixelColors.jungleGreen,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isEquipped
                        ? 'Equipped'
                        : isUnlocked
                            ? 'Unlocked'
                            : 'Locked',
                    style: PixelTheme.bodyStyle(
                      fontSize: 11,
                      color: isEquipped ? PixelColors.warmOrange : PixelColors.mediumBrown,
                      fontWeight: isEquipped ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 10),
            
            // Buy / Equip Button
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: 96,
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                decoration: BoxDecoration(
                  color: isEquipped
                      ? PixelColors.pixelGold
                      : isUnlocked
                          ? PixelColors.jungleGreen
                          : canAfford
                              ? PixelColors.jungleGreen
                              : PixelColors.jungleGreen.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isEquipped
                        ? PixelColors.warmOrange
                        : isUnlocked
                            ? PixelColors.jungleGreenDark
                            : canAfford
                                ? PixelColors.jungleGreenDark
                                : PixelColors.darkBrown.withOpacity(0.5),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isEquipped) ...[
                      Text(
                        'EQUIPPED',
                        style: PixelTheme.pixelStyle(
                          fontSize: 7,
                          color: PixelColors.darkBrown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else if (isUnlocked) ...[
                      Text(
                        'EQUIP',
                        style: PixelTheme.pixelStyle(
                          fontSize: 7,
                          color: PixelColors.creamWhite,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/icons/banana.png',
                            width: 10,
                            height: 10,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.none,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            BananaCounter.formatNumber(skin.cost),
                            style: PixelTheme.pixelStyle(
                              fontSize: 7,
                              color: canAfford
                                  ? PixelColors.creamWhite
                                  : PixelColors.creamWhite.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'BUY SKIN',
                        style: PixelTheme.pixelStyle(
                          fontSize: 6,
                          color: canAfford
                              ? PixelColors.creamWhite
                              : PixelColors.creamWhite.withOpacity(0.6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
