import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/upgrade.dart';
import '../models/map_theme.dart';
import '../theme/pixel_theme.dart';
import '../controllers/game_controller.dart';
import 'banana_counter.dart';

class UpgradeCard extends StatefulWidget {
  final Upgrade upgrade;
  final double totalBananas;
  final VoidCallback onBuy;

  const UpgradeCard({
    Key? key,
    required this.upgrade,
    required this.totalBananas,
    required this.onBuy,
  }) : super(key: key);

  @override
  State<UpgradeCard> createState() => _UpgradeCardState();
}

class _UpgradeCardState extends State<UpgradeCard> with TickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeIn),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 8.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  CardThemeConfig _getThemeConfig(String mapId) {
    switch (mapId) {
      case 'banana_village':
        return const CardThemeConfig(
          gradientColors: [Color(0xFF558B2F), Color(0xFF689F38)],
          borderColor: Color(0xFF8D6E63),
          titleColor: Color(0xFFFFF176),
          descColor: Color(0xFFF1F8E9),
          indicatorBg: Color(0xFF9CCC65),
          indicatorBorder: Color(0xFF7CB342),
          indicatorText: Color(0xFFC5E1A5),
          decorations: ['🌾', '🌾', '🪵', '🧺', '🍂', '🍂', '🪵'],
        );
      case 'volcano_island':
        return const CardThemeConfig(
          gradientColors: [Color(0xFF212121), Color(0xFF37474F)],
          borderColor: Color(0xFFD84315),
          titleColor: Color(0xFFFF8A65),
          descColor: Color(0xFFECEFF1),
          indicatorBg: Color(0xFFD84315),
          indicatorBorder: Color(0xFFBF360C),
          indicatorText: Color(0xFFFFAB91),
          decorations: ['🔥', '💥', '🌋', '🔥', '☄️', '☄️', '🌋'],
        );
      case 'ancient_temple':
        return const CardThemeConfig(
          gradientColors: [Color(0xFF4E342E), Color(0xFF5D4037)],
          borderColor: Color(0xFF00695C),
          titleColor: Color(0xFF4DB6AC),
          descColor: Color(0xFFEFEBE9),
          indicatorBg: Color(0xFF00695C),
          indicatorBorder: Color(0xFF004D40),
          indicatorText: Color(0xFF80CBC4),
          decorations: ['🗿', '🏺', '🧱', '🗿', '🌿', '🌿', '🏺'],
        );
      case 'cloud_jungle':
        return const CardThemeConfig(
          gradientColors: [Color(0xFF0277BD), Color(0xFF0288D1)],
          borderColor: Color(0xFF00ACC1),
          titleColor: Color(0xFF80DEEA),
          descColor: Color(0xFFE1F5FE),
          indicatorBg: Color(0xFF00ACC1),
          indicatorBorder: Color(0xFF00838F),
          indicatorText: Color(0xFFB2EBF2),
          decorations: ['☁️', '⚡', '✨', '☁️', '🌤️', '🌤️', '✨'],
        );
      case 'golden_kingdom':
        return const CardThemeConfig(
          gradientColors: [Color(0xFFF57F17), Color(0xFFFBC02D)],
          borderColor: Color(0xFFFFD54F),
          titleColor: Colors.white,
          descColor: Color(0xFFFFFDE7),
          indicatorBg: Color(0xFFFFD54F),
          indicatorBorder: Color(0xFFFBC02D),
          indicatorText: Color(0xFFFFF9C4),
          decorations: ['👑', '💎', '✨', '👑', '🌟', '🌟', '💎'],
        );
      case 'jungle':
      default:
        return const CardThemeConfig(
          gradientColors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          borderColor: Color(0xFF3E2723),
          titleColor: Color(0xFFFFEB3B),
          descColor: Color(0xFFE8F5E9),
          indicatorBg: Color(0xFF81C784),
          indicatorBorder: Color(0xFF4CAF50),
          indicatorText: Color(0xFFA5D6A7),
          decorations: ['🌿', '🍃', '🌱', '🌿', '🌱', '🌱', '🍃'],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final worldCostMultiplier = controller.currentMapProgression.worldCostMultiplier;
    final theme = controller.selectedMapTheme;
    final themeConfig = _getThemeConfig(theme.id);

    final cost = widget.upgrade.getCost(worldCostMultiplier);
    final canAfford = widget.totalBananas >= cost;
    final isMaxed = widget.upgrade.currentLevel >= widget.upgrade.maxLevel;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main Card Container with gradient background (no DecorationImage - assets don't exist)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: themeConfig.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.darkBorderColor, width: 3.5),
              boxShadow: const [
                BoxShadow(
                  color: PixelColors.softShadow,
                  offset: Offset(0, 4),
                  blurRadius: 0,
                )
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            child: Row(
              children: [
                // Left: Premium framed Icon Area
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD54F),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.darkBorderColor, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 0,
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(6.0),
                  child: Stack(
                    children: [
                      // Inner shine overlay
                      Positioned(
                        top: 2,
                        left: 2,
                        child: Container(
                          width: 12,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Center(
                        child: Image.asset(
                          widget.upgrade.imagePath,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.none,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Center: Upgrade details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        widget.upgrade.name.toUpperCase(),
                        style: PixelTheme.pixelStyle(
                          fontSize: 8.5,
                          color: themeConfig.titleColor,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Description
                      Text(
                        widget.upgrade.description,
                        style: PixelTheme.bodyStyle(
                          fontSize: 10.5,
                          color: themeConfig.descColor,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Level Indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: themeConfig.indicatorBg.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: theme.darkBorderColor.withOpacity(0.4), width: 1),
                        ),
                        child: Text(
                          widget.upgrade.isRepeatable
                              ? 'Lv. ${widget.upgrade.currentLevel}'
                              : 'Lv. ${widget.upgrade.currentLevel} / ${widget.upgrade.maxLevel}',
                          style: PixelTheme.pixelStyle(
                            fontSize: 6.0,
                            color: themeConfig.indicatorText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Right: Action area
                if (isMaxed)
                  Container(
                    width: 82,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD54F),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.darkBorderColor, width: 2.5),
                      boxShadow: const [
                        BoxShadow(
                          color: PixelColors.softShadow,
                          offset: Offset(0, 2.5),
                          blurRadius: 0,
                        )
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('👑', style: TextStyle(fontSize: 10)),
                        const SizedBox(width: 3),
                        Text(
                          'MAX',
                          style: PixelTheme.pixelStyle(
                            fontSize: 8,
                            color: PixelColors.darkBrown,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  // Buy Button
                  AnimatedBuilder(
                    animation: Listenable.merge([_scaleAnimation, _pulseAnimation]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: GestureDetector(
                          onTapDown: (_) {
                            if (canAfford) _pressController.forward();
                          },
                          onTapUp: (_) {
                            if (canAfford) {
                              _pressController.reverse();
                              widget.onBuy();
                            }
                          },
                          onTapCancel: () {
                            if (canAfford) _pressController.reverse();
                          },
                          child: Container(
                            width: 82,
                            height: 38,
                            decoration: BoxDecoration(
                              color: canAfford
                                  ? theme.primaryColor
                                  : theme.primaryColor.withOpacity(0.55),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: canAfford
                                    ? theme.cardTrimColor
                                    : theme.darkBorderColor.withOpacity(0.55),
                                width: 2.5,
                              ),
                              boxShadow: [
                                if (canAfford)
                                  BoxShadow(
                                    color: const Color(0xFFFFEB3B).withOpacity(0.6),
                                    blurRadius: _pulseAnimation.value,
                                    spreadRadius: _pulseAnimation.value / 3,
                                  )
                                else
                                  const BoxShadow(
                                    color: PixelColors.softShadow,
                                    offset: Offset(0, 3),
                                    blurRadius: 0,
                                  ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/icons/banana.png',
                                  width: 12,
                                  height: 12,
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.none,
                                  color: canAfford ? null : Colors.white.withOpacity(0.6),
                                  colorBlendMode: canAfford ? null : BlendMode.modulate,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  BananaCounter.formatNumber(cost),
                                  style: PixelTheme.pixelStyle(
                                    fontSize: 7.5,
                                    color: canAfford
                                        ? PixelColors.creamWhite
                                        : PixelColors.creamWhite.withOpacity(0.6),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),

          // Map Themed Corner Decorations
          Positioned(
            top: -6,
            left: -4,
            child: Text(themeConfig.decorations[0], style: const TextStyle(fontSize: 15)),
          ),
          Positioned(
            top: -8,
            right: 8,
            child: Text(themeConfig.decorations[1], style: const TextStyle(fontSize: 11)),
          ),
          Positioned(
            bottom: -6,
            left: 8,
            child: Text(themeConfig.decorations[2], style: const TextStyle(fontSize: 12)),
          ),
          Positioned(
            bottom: -5,
            right: -2,
            child: Text(themeConfig.decorations[3], style: const TextStyle(fontSize: 11)),
          ),
          
          // Extra themed decorations wrapping borders
          Positioned(
            top: -7,
            left: 45,
            child: Text(themeConfig.decorations[4], style: const TextStyle(fontSize: 9)),
          ),
          Positioned(
            top: -7,
            right: 45,
            child: Text(themeConfig.decorations[5], style: const TextStyle(fontSize: 9)),
          ),
          
          // Themed overlay on the icon frame bottom-right
          Positioned(
            top: 44,
            left: 48,
            child: Text(themeConfig.decorations[6], style: const TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }
}

class CardThemeConfig {
  final List<Color> gradientColors;
  final Color borderColor;
  final Color titleColor;
  final Color descColor;
  final Color indicatorBg;
  final Color indicatorBorder;
  final Color indicatorText;
  final List<String> decorations;

  const CardThemeConfig({
    required this.gradientColors,
    required this.borderColor,
    required this.titleColor,
    required this.descColor,
    required this.indicatorBg,
    required this.indicatorBorder,
    required this.indicatorText,
    required this.decorations,
  });
}
