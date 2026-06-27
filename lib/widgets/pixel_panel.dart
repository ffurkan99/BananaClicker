import 'package:flutter/material.dart';
import '../theme/pixel_theme.dart';

class PixelPanel extends StatelessWidget {
  final Widget child;
  final double borderWidth;
  final Color borderColor;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const PixelPanel({
    Key? key,
    required this.child,
    this.borderWidth = 4.0,
    this.borderColor = PixelColors.darkBrown,
    this.backgroundColor = PixelColors.creamWhite,
    this.padding = const EdgeInsets.all(14.0),
    this.margin = const EdgeInsets.all(0.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: const [
          BoxShadow(
            color: PixelColors.softShadow,
            offset: Offset(0, 4),
            blurRadius: 0,
          )
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}
