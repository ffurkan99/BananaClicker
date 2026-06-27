import 'package:flutter/material.dart';
import '../theme/pixel_theme.dart';

class ComboMeter extends StatelessWidget {
  final int comboCount;
  final double comboProgress;

  const ComboMeter({
    Key? key,
    required this.comboCount,
    required this.comboProgress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (comboCount <= 1) return const SizedBox.shrink();

    return Container(
      width: 76,
      decoration: BoxDecoration(
        color: PixelColors.darkBrown,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: PixelColors.mediumBrown, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: PixelColors.softShadow,
            offset: Offset(0, 3),
            blurRadius: 0,
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'COMBO',
            style: PixelTheme.pixelStyle(
              fontSize: 7,
              color: PixelColors.creamWhite,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'x$comboCount',
            style: PixelTheme.pixelStyle(
              fontSize: 12,
              color: PixelColors.bananaYellow,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          // Progress bar indicating remaining decay time
          Container(
            width: 54,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFF1B5E20), // Dark background for the slot
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: PixelColors.mediumBrown, width: 1),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: comboProgress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: PixelColors.activeGreen,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
