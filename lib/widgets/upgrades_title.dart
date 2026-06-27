import 'package:flutter/material.dart';
import '../theme/pixel_theme.dart';

class UpgradesTitle extends StatelessWidget {
  const UpgradesTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: PixelColors.jungleGreen,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: PixelColors.darkBrown, width: 3),
          boxShadow: const [
            BoxShadow(
              color: PixelColors.softShadow,
              offset: Offset(0, 3),
              blurRadius: 0,
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('★', style: TextStyle(color: PixelColors.pixelGold, fontSize: 14)),
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
            const Text('★', style: TextStyle(color: PixelColors.pixelGold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
