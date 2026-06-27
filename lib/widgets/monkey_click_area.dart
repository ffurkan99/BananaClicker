import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../theme/pixel_theme.dart';
import '../widgets/combo_meter.dart';
import '../widgets/floating_reward_text.dart';
import 'golden_banana_event.dart';

class MonkeyClickArea extends StatefulWidget {
  final String equippedSkin;
  final int comboCount;
  final double comboProgress;
  final VoidCallback onMonkeyTap;

  const MonkeyClickArea({
    Key? key,
    required this.equippedSkin,
    required this.comboCount,
    required this.comboProgress,
    required this.onMonkeyTap,
  }) : super(key: key);

  @override
  State<MonkeyClickArea> createState() => _MonkeyClickAreaState();
}

class _MonkeyClickAreaState extends State<MonkeyClickArea> with TickerProviderStateMixin {
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
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    
    _glowScaleAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowAlphaAnimation = Tween<double>(begin: 0.15, end: 0.35).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Squash physics animation on click
    _squashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _scaleXAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.18), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 0.90), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.90, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _squashController, curve: Curves.decelerate));

    _scaleYAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.82), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.82, end: 1.10), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.10, end: 1.0), weight: 40),
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
          speed: rand.nextDouble() * 3.0 + 1.5,
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
          speed: rand.nextDouble() * 4.0 + 2.0,
          scale: rand.nextDouble() * 0.4 + 0.8,
        ));
      }
    });
  }

  String _resolveSkinAsset() {
    switch (widget.equippedSkin) {
      case 'pirate':
        return 'assets/images/monkeys/pirate_monkey.png';
      case 'golden':
      case 'king':
      case 'golden_monkey':
        return 'assets/images/monkeys/king_monkey.png';
      case 'ninja':
        return 'assets/images/monkeys/ninja_monkey.png';
      default:
        return 'assets/images/monkeys/classic_monkey.png';
    }
  }

  ColorFilter? _getMapColorFilter(String mapId) {
    if (widget.equippedSkin != 'classic') {
      return null;
    }
    switch (mapId) {
      case 'banana_village':
        return ColorFilter.mode(Colors.orange.withOpacity(0.35), BlendMode.colorBurn);
      case 'volcano_island':
        return ColorFilter.mode(Colors.redAccent.withOpacity(0.4), BlendMode.colorBurn);
      case 'ancient_temple':
        return ColorFilter.mode(Colors.teal.withOpacity(0.35), BlendMode.colorBurn);
      case 'cloud_jungle':
        return ColorFilter.mode(Colors.blue.withOpacity(0.3), BlendMode.colorBurn);
      case 'golden_kingdom':
        return ColorFilter.mode(Colors.yellowAccent.withOpacity(0.3), BlendMode.colorBurn);
      case 'jungle':
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final totalHeight = 340.0;

        return SizedBox(
          width: totalWidth,
          height: totalHeight,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // 1. Radial Glow Behind Monkey
              AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _glowScaleAnimation.value,
                    child: Opacity(
                      opacity: _glowAlphaAnimation.value + 0.1,
                      child: Container(
                        width: 290,
                        height: 290,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              PixelColors.bananaYellow,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // 2. Character Clicking Zone
              AnimatedBuilder(
                animation: _squashController,
                builder: (context, child) {
                  final filter = _getMapColorFilter(controller.stats.equippedMap);
                  Widget monkeyImage = Image.asset(
                    _resolveSkinAsset(),
                    width: 270,
                    height: 270,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.none, // retro pixel look
                  );
                  if (filter != null) {
                    monkeyImage = ColorFiltered(
                      colorFilter: filter,
                      child: monkeyImage,
                    );
                  }

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
                    // Controller cleans it up safely
                    controller.removeFloatingEffect(eff.id);
                  },
                );
              }).toList(),

              // 5. Combo Meter Box (Left alignment as in screenshot)
              Positioned(
                left: 16,
                child: ComboMeter(
                  comboCount: widget.comboCount,
                  comboProgress: widget.comboProgress,
                ),
              ),

              // 5b. Golden Banana Event Panel (Right alignment as in screenshot)
              const Positioned(
                right: 16,
                child: GoldenBananaEvent(),
              ),

              // 6. Level Up Text Notification
              if (controller.levelUpNotification != null)
                Positioned(
                  top: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: PixelColors.darkBrown,
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
