import 'package:flutter/material.dart';
import '../models/floating_effect.dart';
import '../theme/pixel_theme.dart';

class FloatingRewardText extends StatefulWidget {
  final FloatingEffect effect;
  final VoidCallback onFinished;

  const FloatingRewardText({
    Key? key,
    required this.effect,
    required this.onFinished,
  }) : super(key: key);

  @override
  State<FloatingRewardText> createState() => _FloatingRewardTextState();
}

class _FloatingRewardTextState extends State<FloatingRewardText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _yAnim;
  late Animation<double> _opacityAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _yAnim = Tween<double>(begin: 0.0, end: -100.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 40),
    ]).animate(_controller);

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.2), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 30),
    ]).animate(_controller);

    _controller.forward().then((_) => widget.onFinished());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effect = widget.effect;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: (MediaQuery.of(context).size.width / 2) + effect.xOffset - 80,
          top: 150 + effect.yOffset + _yAnim.value, // relative to the monkey coordinates
          child: Opacity(
            opacity: _opacityAnim.value,
            child: Transform.scale(
              scale: _scaleAnim.value,
              child: Container(
                width: 160,
                alignment: Alignment.center,
                child: Text(
                  effect.text,
                  style: PixelTheme.pixelStyle(
                    fontSize: effect.isCritical ? 11 : 9,
                    color: effect.isCritical ? PixelColors.pixelGold : PixelColors.creamWhite,
                    fontWeight: FontWeight.bold,
                  ).copyWith(
                    shadows: const [
                      Shadow(
                        offset: Offset(1.5, 1.5),
                        color: Colors.black,
                      )
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
