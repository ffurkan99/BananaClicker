import 'package:flutter/material.dart';
import '../models/map_theme.dart';
import '../theme/pixel_theme.dart';
import '../widgets/banana_counter.dart';

class MapSelectorCard extends StatelessWidget {
  final MapTheme mapTheme;
  final double totalBananas;
  final VoidCallback onTap;

  const MapSelectorCard({
    Key? key,
    required this.mapTheme,
    required this.totalBananas,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUnlocked = mapTheme.isUnlocked;
    final isEquipped = mapTheme.isEquipped;
    final canAfford = totalBananas >= mapTheme.cost;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: PixelColors.creamWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: mapTheme.darkBorderColor, width: 3),
          boxShadow: [
            BoxShadow(
              color: mapTheme.darkBorderColor.withOpacity(0.25),
              offset: const Offset(0, 4),
              blurRadius: 0,
            )
          ],
        ),
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Thumbnail Box with Map colors as background
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    mapTheme.primaryColor,
                    mapTheme.cardTrimColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: mapTheme.darkBorderColor, width: 2),
              ),
              padding: const EdgeInsets.all(4.0),
              alignment: Alignment.center,
              child: Image.asset(
                mapTheme.monkeyPath,
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
                    mapTheme.name.toUpperCase(),
                    style: PixelTheme.pixelStyle(
                      fontSize: 8.5,
                      color: mapTheme.darkBorderColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mapTheme.description,
                    style: PixelTheme.bodyStyle(
                      fontSize: 10,
                      color: PixelColors.mediumBrown,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEquipped
                        ? 'Equipped'
                        : isUnlocked
                            ? 'Unlocked'
                            : 'Locked',
                    style: PixelTheme.bodyStyle(
                      fontSize: 10,
                      color: isEquipped ? mapTheme.primaryColor : PixelColors.mediumBrown,
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
                          ? mapTheme.primaryColor
                          : canAfford
                              ? mapTheme.primaryColor
                              : mapTheme.primaryColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isEquipped
                        ? PixelColors.warmOrange
                        : mapTheme.darkBorderColor,
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
                          fontSize: 6.5,
                          color: PixelColors.darkBrown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else if (isUnlocked) ...[
                      Text(
                        'EQUIP',
                        style: PixelTheme.pixelStyle(
                          fontSize: 6.5,
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
                            BananaCounter.formatNumber(mapTheme.cost),
                            style: PixelTheme.pixelStyle(
                              fontSize: 6.5,
                              color: canAfford
                                  ? PixelColors.creamWhite
                                  : PixelColors.creamWhite.withOpacity(0.6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'BUY MAP',
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
