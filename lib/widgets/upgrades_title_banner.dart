import 'package:flutter/material.dart';
import '../theme/pixel_theme.dart';

class UpgradesTitleBanner extends StatelessWidget {
  final Color darkBorderColor;
  const UpgradesTitleBanner({
    Key? key,
    this.darkBorderColor = PixelColors.darkBrown,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Center wooden board
            Container(
              decoration: BoxDecoration(
                color: PixelColors.jungleGreen,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: darkBorderColor, width: 3.5),
                boxShadow: const [
                  BoxShadow(
                    color: PixelColors.softShadow,
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  )
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('★', style: TextStyle(color: PixelColors.bananaYellow, fontSize: 14)),
                  const SizedBox(width: 8),
                  Text(
                    'UPGRADES',
                    style: PixelTheme.pixelStyle(
                      fontSize: 10,
                      color: PixelColors.creamWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('★', style: TextStyle(color: PixelColors.bananaYellow, fontSize: 14)),
                ],
              ),
            ),
            
            // Leaf corner decorations
            const Positioned(
              left: -14,
              top: -8,
              child: Text('🌿', style: TextStyle(fontSize: 16)),
            ),
            const Positioned(
              right: -14,
              top: -8,
              child: Text('🌿', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
