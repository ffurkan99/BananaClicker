import 'package:flutter/material.dart';
import '../theme/pixel_theme.dart';
import 'banana_counter.dart';

class IncomeStrip extends StatelessWidget {
  final double bananasPerClick;
  final double bananasPerSecond;
  final Color darkBorderColor;

  const IncomeStrip({
    Key? key,
    required this.bananasPerClick,
    required this.bananasPerSecond,
    this.darkBorderColor = PixelColors.darkBrown,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF5D4037), // Dark wood background
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: darkBorderColor, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: PixelColors.softShadow,
              offset: Offset(0, 3),
              blurRadius: 0,
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/icons/banana.png',
              width: 14,
              height: 14,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
            ),
            const SizedBox(width: 6),
            Text(
              '+${BananaCounter.formatNumber(bananasPerClick)} / click',
              style: PixelTheme.pixelStyle(
                fontSize: 7,
                color: PixelColors.creamWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (bananasPerSecond > 0) ...[
              const SizedBox(width: 12),
              Container(
                width: 2,
                height: 10,
                color: PixelColors.creamWhite.withOpacity(0.3),
              ),
              const SizedBox(width: 12),
              Text(
                '+${BananaCounter.formatNumber(bananasPerSecond)} / sec',
                style: PixelTheme.pixelStyle(
                  fontSize: 7,
                  color: PixelColors.bananaYellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
