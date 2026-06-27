import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/pixel_theme.dart';

class BananaCounter extends StatefulWidget {
  final double totalBananas;
  final double bananasPerClick;
  final double bananasPerSecond;
  final bool isGoldenActive;
  final Color darkBorderColor;

  const BananaCounter({
    Key? key,
    required this.totalBananas,
    required this.bananasPerClick,
    required this.bananasPerSecond,
    required this.isGoldenActive,
    this.darkBorderColor = PixelColors.darkBrown,
  }) : super(key: key);

  static String formatNumber(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      final formatter = NumberFormat('#,###', 'en_US');
      return formatter.format(value.toInt());
    } else {
      return value.toInt().toString();
    }
  }

  @override
  State<BananaCounter> createState() => _BananaCounterState();
}

class _BananaCounterState extends State<BananaCounter> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.85, end: 1.05).animate(_glowController);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final Color startColor = widget.isGoldenActive ? const Color(0xFFFFF59D) : const Color(0xFFFFD54F);
        final Color endColor = widget.isGoldenActive ? const Color(0xFFFFD54F) : const Color(0xFFFFA000);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: Container(
            width: double.infinity,
            height: 86,
            // Outer thick wood frame
            decoration: BoxDecoration(
              color: const Color(0xFF5D4037), // Dark wood frame
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: widget.darkBorderColor, width: 4.5),
              boxShadow: [
                BoxShadow(
                  color: widget.darkBorderColor.withOpacity(0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 0,
                )
              ],
            ),
            padding: const EdgeInsets.all(4.5),
            child: Container(
              // Inner Golden Board Screen
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107),
                gradient: LinearGradient(
                  colors: [startColor, endColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: widget.darkBorderColor, width: 2),
              ),
              child: Stack(
                children: [
                  // Corner Bolts (4 tiny circular bolts in wood/metal styling)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: widget.darkBorderColor.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: widget.darkBorderColor.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: widget.darkBorderColor.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: widget.darkBorderColor.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  
                  // Center Content (Banana Icon + Number)
                  Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/icons/banana.png',
                          width: 44,
                          height: 44,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.none,
                        ),
                        const SizedBox(width: 12),
                        
                        // Text with pixel drop shadow
                        Stack(
                          children: [
                            // Shadow
                            Text(
                              BananaCounter.formatNumber(widget.totalBananas),
                              style: PixelTheme.pixelStyle(
                                fontSize: 26,
                                color: widget.darkBorderColor, // Shadow color
                              ),
                            ),
                            // Foreground Text
                            Positioned(
                              top: 2,
                              left: 1.5,
                              child: Text(
                                BananaCounter.formatNumber(widget.totalBananas),
                                style: PixelTheme.pixelStyle(
                                  fontSize: 26,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            // Golden core Text overlay
                            Positioned(
                              top: 1,
                              left: 0.5,
                              child: Text(
                                BananaCounter.formatNumber(widget.totalBananas),
                                style: PixelTheme.pixelStyle(
                                  fontSize: 26,
                                  color: widget.isGoldenActive ? const Color(0xFFFFF176) : const Color(0xFFFFEB3B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
