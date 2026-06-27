import 'package:flutter/material.dart';
import '../theme/pixel_theme.dart';

class PixelButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color borderColor;
  final bool enabled;

  const PixelButton({
    Key? key,
    required this.child,
    required this.onTap,
    this.backgroundColor = PixelColors.jungleGreen,
    this.borderColor = PixelColors.jungleGreenDark,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color currentBg = widget.enabled ? widget.backgroundColor : PixelColors.disabledGray;
    final Color currentBorder = widget.enabled ? widget.borderColor : PixelColors.darkBrown.withOpacity(0.4);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              if (widget.enabled) _controller.forward();
            },
            onTapUp: (_) {
              if (widget.enabled) {
                _controller.reverse();
                widget.onTap();
              }
            },
            onTapCancel: () {
              if (widget.enabled) _controller.reverse();
            },
            child: Container(
              decoration: BoxDecoration(
                color: currentBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: currentBorder, width: 3),
                boxShadow: widget.enabled
                    ? const [
                        BoxShadow(
                          color: PixelColors.softShadow,
                          offset: Offset(0, 3),
                          blurRadius: 0,
                        )
                      ]
                    : null,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
