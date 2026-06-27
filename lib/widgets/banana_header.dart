import 'package:flutter/material.dart';
import '../theme/pixel_theme.dart';

class BananaHeader extends StatelessWidget {
  final VoidCallback onShopClick;
  final VoidCallback onSettingsClick;
  final Color darkBorderColor;
  final Color primaryColor;

  const BananaHeader({
    Key? key,
    required this.onShopClick,
    required this.onSettingsClick,
    this.darkBorderColor = PixelColors.darkBrown,
    this.primaryColor = PixelColors.jungleGreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        child: Row(
          children: [
            // Left: Coins / Shop shortcut button
            GestureDetector(
              onTap: onShopClick,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: darkBorderColor, width: 3.5),
                  boxShadow: [
                    BoxShadow(
                      color: darkBorderColor.withOpacity(0.3),
                      offset: const Offset(0, 3.5),
                      blurRadius: 0,
                    )
                  ],
                ),
                child: const Icon(
                  Icons.monetization_on,
                  color: PixelColors.pixelGold,
                  size: 24,
                ),
              ),
            ),
            
            const SizedBox(width: 10),

            // Center: Pixel title board (Double wood/parchment style)
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Outer Wood Board
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5D4037), // Rich dark wood
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: darkBorderColor, width: 3.5),
                      boxShadow: [
                        BoxShadow(
                          color: darkBorderColor.withOpacity(0.3),
                          offset: const Offset(0, 3.5),
                          blurRadius: 0,
                        )
                      ],
                    ),
                    padding: const EdgeInsets.all(3.0),
                    child: Container(
                      // Inner parchment banner
                      decoration: BoxDecoration(
                        color: PixelColors.creamWhite,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 28,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  // Left/top decorations
                  const Positioned(
                    top: -8,
                    left: -6,
                    child: Text('🌿', style: TextStyle(fontSize: 16)),
                  ),
                  // Right/top decorations
                  const Positioned(
                    top: -8,
                    right: -6,
                    child: Text('🌸', style: TextStyle(fontSize: 16)),
                  ),
                  // Left/bottom leaf
                  const Positioned(
                    bottom: -6,
                    left: -2,
                    child: Text('🍃', style: TextStyle(fontSize: 12)),
                  ),
                  // Right/bottom leaf
                  const Positioned(
                    bottom: -6,
                    right: -2,
                    child: Text('🌿', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),
            
            // Right: Settings button
            GestureDetector(
              onTap: onSettingsClick,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: darkBorderColor, width: 3.5),
                  boxShadow: [
                    BoxShadow(
                      color: darkBorderColor.withOpacity(0.3),
                      offset: const Offset(0, 3.5),
                      blurRadius: 0,
                    )
                  ],
                ),
                child: const Icon(
                  Icons.settings,
                  color: PixelColors.creamWhite,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
