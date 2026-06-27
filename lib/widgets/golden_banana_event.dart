import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../theme/pixel_theme.dart';

class GoldenBananaEvent extends StatefulWidget {
  const GoldenBananaEvent({Key? key}) : super(key: key);

  @override
  State<GoldenBananaEvent> createState() => _GoldenBananaEventState();
}

class _GoldenBananaEventState extends State<GoldenBananaEvent> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final isTapActive = controller.isGoldenTapActive;
    final isIdleActive = controller.isGoldenIdleActive;
    final hasActiveMult = isTapActive || isIdleActive;

    // Remaining seconds calculation
    int remainingSecs = 0;
    if (isTapActive || isIdleActive) {
      remainingSecs = max(
        controller.goldenTapRemainingSeconds,
        controller.goldenIdleRemainingSeconds,
      );
    }

    // If no event is spawned AND no multiplier is active, show a subtle placeholder
    if (!controller.showGoldenBanana && !hasActiveMult) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: PixelColors.darkBrown.withOpacity(0.25), width: 2.5),
        ),
        child: Center(
          child: Opacity(
            opacity: 0.15,
            child: Image.asset(
              'assets/images/icons/golden_banana.png',
              width: 28,
              height: 28,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
            ),
          ),
        ),
      );
    }

    // Active countdown state (multiplier running)
    if (hasActiveMult) {
      final String countdownStr = '00:${remainingSecs.toString().padLeft(2, '0')}';
      return Container(
        width: 52,
        decoration: BoxDecoration(
          color: PixelColors.darkBrown,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: PixelColors.pixelGold, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: PixelColors.softShadow,
              offset: Offset(0, 3),
              blurRadius: 0,
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/icons/golden_banana.png',
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
            ),
            const SizedBox(height: 4),
            Text(
              countdownStr,
              style: PixelTheme.pixelStyle(
                fontSize: 6,
                color: PixelColors.pixelGold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    // Spawning active event state (waiting for tap)
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: () {
              controller.tapGoldenBanana();
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: PixelColors.jungleGreen,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: PixelColors.pixelGold, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: PixelColors.pixelGold.withOpacity(0.6),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),
              padding: const EdgeInsets.all(4.0),
              child: Image.asset(
                'assets/images/icons/golden_banana.png',
                width: 32,
                height: 32,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.none,
              ),
            ),
          ),
        );
      },
    );
  }
}
