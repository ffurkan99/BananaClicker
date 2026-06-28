import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../theme/pixel_theme.dart';

class ComboMeter extends StatefulWidget {
  final int comboCount;

  const ComboMeter({
    Key? key,
    required this.comboCount,
  }) : super(key: key);

  @override
  State<ComboMeter> createState() => _ComboMeterState();
}

class _ComboMeterState extends State<ComboMeter> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _lastComboCount = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _checkComboChange();
  }

  @override
  void didUpdateWidget(covariant ComboMeter oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkComboChange();
  }

  void _checkComboChange() {
    if (widget.comboCount != _lastComboCount) {
      _lastComboCount = widget.comboCount;
      if (widget.comboCount > 1) {
        final durationMs = context.read<GameController>().totalComboDurationMs;
        _controller.duration = Duration(milliseconds: durationMs.toInt());
        _controller.forward(from: 0.0);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.comboCount <= 1) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double progress = 1.0 - _controller.value;
        
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
                'x${widget.comboCount}',
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
                    widthFactor: progress.clamp(0.0, 1.0),
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
      },
    );
  }
}
