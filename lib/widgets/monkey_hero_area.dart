import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../models/map_theme.dart';
import '../theme/pixel_theme.dart';
import '../widgets/combo_meter.dart';
import '../widgets/floating_reward_text.dart';
import 'golden_banana_event.dart';

class MonkeyHeroArea extends StatefulWidget {
  final int comboCount;
  final double comboProgress;
  final VoidCallback onMonkeyTap;

  const MonkeyHeroArea({
    Key? key,
    required this.comboCount,
    required this.comboProgress,
    required this.onMonkeyTap,
  }) : super(key: key);

  @override
  State<MonkeyHeroArea> createState() => _MonkeyHeroAreaState();
}

class _MonkeyHeroAreaState extends State<MonkeyHeroArea> with TickerProviderStateMixin {
  // Glow controller
  late AnimationController _glowController;
  late Animation<double> _glowScaleAnimation;
  late Animation<double> _glowAlphaAnimation;

  // Squash controller
  late AnimationController _squashController;
  late Animation<double> _scaleXAnimation;
  late Animation<double> _scaleYAnimation;

  // Local sparkle / banana particles for aesthetics (decoration)
  final List<_LocalDecorationParticle> _localParticles = [];
  int _localParticleCounter = 0;

  @override
  void initState() {
    super.initState();

    // Pulse glow animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _glowScaleAnimation = Tween<double>(begin: 0.90, end: 1.15).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowAlphaAnimation = Tween<double>(begin: 0.20, end: 0.45).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Squash physics animation on click
    _squashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleXAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.20), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.20, end: 0.88), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 0.88, end: 1.0), weight: 35),
    ]).animate(CurvedAnimation(parent: _squashController, curve: Curves.decelerate));

    _scaleYAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.80), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.80, end: 1.12), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0), weight: 35),
    ]).animate(CurvedAnimation(parent: _squashController, curve: Curves.decelerate));
  }

  @override
  void dispose() {
    _glowController.dispose();
    _squashController.dispose();
    super.dispose();
  }

  void _handlePointerDown(PointerDownEvent event) {
    _squashController.forward(from: 0.0);
    widget.onMonkeyTap();

    // Spawn local decoration particles (sparkles and small bananas)
    final localOffset = event.localPosition;
    final rand = Random();
    
    setState(() {
      // 1. Spawning decorative banana particles
      for (int i = 0; i < 3; i++) {
        _localParticles.add(_LocalDecorationParticle(
          id: _localParticleCounter++,
          type: 'banana',
          x: localOffset.dx,
          y: localOffset.dy,
          angle: -rand.nextDouble() * pi,
          speed: rand.nextDouble() * 3.5 + 2.0,
          scale: rand.nextDouble() * 0.3 + 0.7,
        ));
      }

      // 2. Spawning decorative sparkles
      for (int i = 0; i < 4; i++) {
        _localParticles.add(_LocalDecorationParticle(
          id: _localParticleCounter++,
          type: 'sparkle',
          x: localOffset.dx,
          y: localOffset.dy,
          angle: -rand.nextDouble() * pi * 1.2 + 0.2,
          speed: rand.nextDouble() * 4.5 + 2.5,
          scale: rand.nextDouble() * 0.4 + 0.8,
        ));
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final theme = controller.selectedMapTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final totalHeight = 350.0;

        return SizedBox(
          width: totalWidth,
          height: totalHeight,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // 1. Radial Glow Behind Monkey (uses secondary map color for customized map-based glows)
              AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _glowScaleAnimation.value,
                    child: Opacity(
                      opacity: _glowAlphaAnimation.value,
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              theme.primaryColor.withOpacity(0.8),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // 2. Character Tapping Zone
              AnimatedBuilder(
                animation: _squashController,
                builder: (context, child) {
                  Widget monkeyImage = Image.asset(
                    controller.getEquippedSkinPathForMap(theme.id),
                    width: 260,
                    height: 260,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.none, // retro pixel look
                  );

                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..scale(_scaleXAnimation.value, _scaleYAnimation.value),
                    child: Listener(
                      behavior: HitTestBehavior.translucent,
                      onPointerDown: _handlePointerDown,
                      child: monkeyImage,
                    ),
                  );
                },
              ),

              // 3. Local Decorative Particles
              ..._localParticles.map((particle) {
                return _DecorationParticleWidget(
                  key: ValueKey('local_particle_${particle.id}'),
                  particle: particle,
                  onFinished: () {
                    setState(() {
                      _localParticles.removeWhere((p) => p.id == particle.id);
                    });
                  },
                );
              }).toList(),

              // 4. Floating text indicators driven by GameController
              ...controller.floatingEffects.map((eff) {
                return FloatingRewardText(
                  key: ValueKey('floating_effect_${eff.id}'),
                  effect: eff,
                  onFinished: () {
                    controller.removeFloatingEffect(eff.id);
                  },
                );
              }).toList(),

              // 5. Combo Meter Box (Left alignment)
              Positioned(
                left: 20,
                child: ComboMeter(
                  comboCount: widget.comboCount,
                  comboProgress: widget.comboProgress,
                ),
              ),

              // 5b. Golden Banana Event Panel (Right alignment)
              const Positioned(
                right: 20,
                child: GoldenBananaEvent(),
              ),

              // 6. Level Up Text Notification
              if (controller.levelUpNotification != null)
                Positioned(
                  top: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.darkBorderColor,
                      border: Border.all(color: PixelColors.pixelGold, width: 2.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      controller.levelUpNotification!,
                      style: PixelTheme.pixelStyle(
                        fontSize: 8,
                        color: PixelColors.pixelGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // 7. Achievement Notification Banner
              if (controller.achievementUnlockNotification != null)
                Positioned(
                  top: -20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: PixelColors.activeGreen,
                      border: Border.all(color: PixelColors.creamWhite, width: 2.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      controller.achievementUnlockNotification!,
                      style: PixelTheme.pixelStyle(
                        fontSize: 8,
                        color: PixelColors.creamWhite,
                        fontWeight: FontWeight.bold,
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

class _LocalDecorationParticle {
  final int id;
  final String type; // 'banana' or 'sparkle'
  final double x;
  final double y;
  final double angle;
  final double speed;
  final double scale;

  _LocalDecorationParticle({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.angle,
    required this.speed,
    required this.scale,
  });
}

class _DecorationParticleWidget extends StatefulWidget {
  final _LocalDecorationParticle particle;
  final VoidCallback onFinished;

  const _DecorationParticleWidget({
    Key? key,
    required this.particle,
    required this.onFinished,
  }) : super(key: key);

  @override
  State<_DecorationParticleWidget> createState() => _DecorationParticleWidgetState();
}

class _DecorationParticleWidgetState extends State<_DecorationParticleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _controller.forward().then((_) => widget.onFinished());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        final alpha = 1.0 - progress;
        final distance = 100.0 * progress;
        final ox = distance * cos(widget.particle.angle);
        final oy = distance * sin(widget.particle.angle);

        return Positioned(
          left: widget.particle.x + ox - 10,
          top: widget.particle.y + oy - 10,
          child: Opacity(
            opacity: alpha,
            child: _buildParticleWidget(),
          ),
        );
      },
    );
  }

  Widget _buildParticleWidget() {
    final particle = widget.particle;
    if (particle.type == 'banana') {
      return Image.asset(
        'assets/images/icons/banana.png',
        width: 14 * particle.scale,
        height: 14 * particle.scale,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
      );
    } else {
      return Text(
        '✨',
        style: TextStyle(
          fontSize: 12 * particle.scale,
        ),
      );
    }
  }
}
