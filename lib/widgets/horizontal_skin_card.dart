import 'package:flutter/material.dart';
import '../models/skin.dart';
import '../theme/pixel_theme.dart';
import '../widgets/banana_counter.dart';

class HorizontalSkinCard extends StatefulWidget {
  final Skin skin;
  final double totalBananas;
  final VoidCallback onTap;

  const HorizontalSkinCard({
    Key? key,
    required this.skin,
    required this.totalBananas,
    required this.onTap,
  }) : super(key: key);

  @override
  State<HorizontalSkinCard> createState() => _HorizontalSkinCardState();
}

class _HorizontalSkinCardState extends State<HorizontalSkinCard> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUnlocked = widget.skin.isUnlocked;
    final isEquipped = widget.skin.isEquipped;
    final canAfford = widget.totalBananas >= widget.skin.cost;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => _animController.forward(),
        onTapUp: (_) => _animController.reverse(),
        onTapCancel: () => _animController.reverse(),
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Container(
            width: 135,
            height: 175,
            margin: const EdgeInsets.only(right: 12.0, top: 4.0, bottom: 8.0),
            decoration: BoxDecoration(
              color: isEquipped ? PixelColors.creamWhite : PixelColors.creamLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isEquipped ? PixelColors.pixelGold : PixelColors.darkBrown,
                width: isEquipped ? 3.0 : 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isEquipped
                      ? PixelColors.pixelGold.withOpacity(0.25)
                      : PixelColors.softShadow,
                  offset: const Offset(0, 3),
                  blurRadius: isEquipped ? 4 : 0,
                )
              ],
            ),
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Skin Name
                Text(
                  widget.skin.name.toUpperCase(),
                  style: PixelTheme.pixelStyle(
                    fontSize: 7.5,
                    color: PixelColors.darkBrown,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // 2. Monkey Image Frame
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isEquipped ? PixelColors.creamLight : Colors.black.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: PixelColors.mediumBrown.withOpacity(0.3), width: 1.5),
                    ),
                    padding: const EdgeInsets.all(4.0),
                    child: Center(
                      child: Image.asset(
                        widget.skin.imagePath,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // 3. Bonus Text
                Text(
                  widget.skin.bonusDescription,
                  style: PixelTheme.bodyStyle(
                    fontSize: 10,
                    color: PixelColors.jungleGreen,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // 4. Action Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  decoration: BoxDecoration(
                    color: isEquipped
                        ? PixelColors.pixelGold
                        : isUnlocked
                            ? PixelColors.jungleGreen
                            : canAfford
                                ? PixelColors.jungleGreen
                                : PixelColors.jungleGreen.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isEquipped
                          ? PixelColors.warmOrange
                          : isUnlocked
                              ? PixelColors.jungleGreenDark
                              : canAfford
                                  ? PixelColors.jungleGreenDark
                                  : PixelColors.darkBrown.withOpacity(0.4),
                      width: 2.0,
                    ),
                  ),
                  child: Center(
                    child: _buildButtonContent(isEquipped, isUnlocked, canAfford),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent(bool isEquipped, bool isUnlocked, bool canAfford) {
    if (isEquipped) {
      return Text(
        'EQUIPPED',
        style: PixelTheme.pixelStyle(
          fontSize: 6,
          color: PixelColors.darkBrown,
          fontWeight: FontWeight.bold,
        ),
      );
    } else if (isUnlocked) {
      return Text(
        'EQUIP',
        style: PixelTheme.pixelStyle(
          fontSize: 6,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/icons/banana.png',
            width: 8,
            height: 8,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.none,
          ),
          const SizedBox(width: 3),
          Text(
            BananaCounter.formatNumber(widget.skin.cost),
            style: PixelTheme.pixelStyle(
              fontSize: 6,
              color: canAfford ? Colors.white : Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      );
    }
  }
}
