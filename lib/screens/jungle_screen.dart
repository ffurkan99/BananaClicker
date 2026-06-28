import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../widgets/monkey_hero_area.dart';
import '../widgets/income_strip.dart';
import '../widgets/upgrades_title_banner.dart';
import '../widgets/quick_upgrade_card.dart';
import '../theme/pixel_theme.dart';
import '../widgets/floating_reward_text.dart';
import '../models/floating_effect.dart';

class JungleScreen extends StatelessWidget {
  const JungleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final stats = controller.stats;
    final theme = controller.selectedMapTheme;

    // Calculate XP percentage
    final double neededXp = 100.0 * pow(1.5, stats.level - 1);
    final double xpProgress = (stats.xp / neededXp).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        children: [
          // 1. Scrollable Content
          ListView(
          padding: const EdgeInsets.only(bottom: 110.0),
          children: [
            // Level and XP progression Sign
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      'MONKEY LV. ${stats.level}',
                      style: PixelTheme.pixelStyle(
                        fontSize: 8,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 10,
                      width: 145,
                      decoration: BoxDecoration(
                        color: theme.darkBorderColor,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: theme.darkBorderColor, width: 2),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: xpProgress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: PixelColors.bananaYellow,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Income Strip showing rates
            IncomeStrip(
              bananasPerClick: stats.bananasPerClick,
              bananasPerSecond: stats.bananasPerSecond,
              darkBorderColor: theme.darkBorderColor,
            ),

            // Clicking Area
            MonkeyHeroArea(
              comboCount: controller.comboCount,
              comboProgress: controller.comboProgress,
              onMonkeyTap: controller.tapMonkey,
            ),
            
            // UPGRADES Title Divider Signboard
            UpgradesTitleBanner(
              darkBorderColor: theme.darkBorderColor,
            ),
            
            // Render exactly 2 quick upgrade cards (Banana Boost & Monkey Helper)
            ...controller.upgrades.where((u) => u.id == 'banana_boost').map((upgrade) {
              return QuickUpgradeCard(
                upgrade: upgrade,
                totalBananas: stats.totalBananas,
                worldCostMultiplier: controller.currentMapProgression.worldCostMultiplier,
                onBuy: () => controller.buyUpgrade(upgrade),
                darkBorderColor: theme.darkBorderColor,
                cardBaseColor: theme.cardBaseColor,
                cardTrimColor: theme.cardTrimColor,
                decorations: const ['🌿', '🍃'],
                cardFramePath: theme.cardFramePath,
              );
            }).toList(),

            ...controller.upgrades.where((u) => u.id == 'monkey_helper').map((upgrade) {
              return QuickUpgradeCard(
                upgrade: upgrade,
                totalBananas: stats.totalBananas,
                worldCostMultiplier: controller.currentMapProgression.worldCostMultiplier,
                onBuy: () => controller.buyUpgrade(upgrade),
                darkBorderColor: theme.darkBorderColor,
                cardBaseColor: theme.cardBaseColor,
                cardTrimColor: theme.cardTrimColor,
                decorations: const ['🌱', '🌿'],
                cardFramePath: theme.cardFramePath,
              );
            }).toList(),
          ],
        ),

        // 3. Local Banana Rain Event Overlay
        BananaRainOverlay(
          isRainActive: controller.isBananaRainActive,
        ),
      ],
    ));
  }
}

class _LocalBananaData {
  final int id;
  final double xProgress;
  final double speed;

  _LocalBananaData({
    required this.id,
    required this.xProgress,
    required this.speed,
  });
}

class BananaRainOverlay extends StatefulWidget {
  final bool isRainActive;

  const BananaRainOverlay({
    Key? key,
    required this.isRainActive,
  }) : super(key: key);

  @override
  State<BananaRainOverlay> createState() => _BananaRainOverlayState();
}

class _BananaRainOverlayState extends State<BananaRainOverlay> {
  Timer? _spawnTimer;
  final List<_LocalBananaData> _bananas = [];
  int _bananaIdCounter = 0;
  bool _wasActive = false;

  final List<FloatingEffect> _localFloatingEffects = [];
  int _floatingIdCounter = 0;

  @override
  void initState() {
    super.initState();
    _checkRainStatus();
  }

  @override
  void didUpdateWidget(covariant BananaRainOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkRainStatus();
  }

  void _checkRainStatus() {
    if (widget.isRainActive && !_wasActive) {
      _wasActive = true;
      _startSpawning();
    } else if (!widget.isRainActive && _wasActive) {
      _wasActive = false;
      _stopSpawning();
    }
  }

  void _startSpawning() {
    _spawnTimer?.cancel();
    _bananas.clear();
    final rand = Random();

    _spawnTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (mounted) {
        setState(() {
          _bananas.add(_LocalBananaData(
            id: _bananaIdCounter++,
            xProgress: rand.nextDouble() * 0.8 + 0.1, // 10% to 90% width
            speed: rand.nextDouble() * 1.5 + 1.0,     // speed factor
          ));
        });
      }
    });
  }

  void _stopSpawning() {
    _spawnTimer?.cancel();
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    super.dispose();
  }

  String _formatVal(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toInt().toString();
    }
  }

  void _spawnFloatingReward(double xProgress, double reward, double currentY) {
    final id = _floatingIdCounter++;
    final width = MediaQuery.of(context).size.width;
    final double xOffset = (width * xProgress) - (width / 2);
    final double yOffset = currentY - 150.0;

    setState(() {
      _localFloatingEffects.add(
        FloatingEffect(
          id: id,
          text: '+${_formatVal(reward)}',
          xOffset: xOffset,
          yOffset: yOffset,
          isCritical: false,
          createdAt: DateTime.now(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_bananas.isEmpty && _localFloatingEffects.isEmpty && !widget.isRainActive) {
      return const SizedBox.shrink();
    }

    final controller = context.read<GameController>();

    return Stack(
      children: [
        ..._bananas.map((banana) {
          return _FallingBananaWidget(
            key: ValueKey('rain_banana_${banana.id}'),
            xProgress: banana.xProgress,
            speed: banana.speed,
            onTap: (currentY) {
              final reward = controller.collectRainBanana();
              _spawnFloatingReward(banana.xProgress, reward, currentY);
              if (mounted) {
                setState(() {
                  _bananas.removeWhere((b) => b.id == banana.id);
                });
              }
            },
            onFinished: () {
              if (mounted) {
                setState(() {
                  _bananas.removeWhere((b) => b.id == banana.id);
                });
              }
            },
          );
        }).toList(),

        ..._localFloatingEffects.map((eff) {
          return FloatingRewardText(
            key: ValueKey('rain_floating_effect_${eff.id}'),
            effect: eff,
            onFinished: () {
              if (mounted) {
                setState(() {
                  _localFloatingEffects.removeWhere((p) => p.id == eff.id);
                });
              }
            },
          );
        }).toList(),
      ],
    );
  }
}

class _FallingBananaWidget extends StatefulWidget {
  final double xProgress;
  final double speed;
  final Function(double y) onTap;
  final VoidCallback onFinished;

  const _FallingBananaWidget({
    Key? key,
    required this.xProgress,
    required this.speed,
    required this.onTap,
    required this.onFinished,
  }) : super(key: key);

  @override
  State<_FallingBananaWidget> createState() => _FallingBananaWidgetState();
}

class _FallingBananaWidgetState extends State<_FallingBananaWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _yAnimation;

  @override
  void initState() {
    super.initState();
    final durationMs = (3000 / widget.speed).toInt();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    );

    _yAnimation = Tween<double>(begin: -50, end: 850).animate(_controller);

    _controller.forward().then((_) {
      widget.onFinished();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _yAnimation,
      builder: (context, child) {
        return Positioned(
          left: MediaQuery.of(context).size.width * widget.xProgress - 16,
          top: _yAnimation.value,
          child: child!,
        );
      },
      child: GestureDetector(
        onTapDown: (_) => widget.onTap(_yAnimation.value),
        child: Image.asset(
          'assets/images/icons/banana.png',
          width: 32,
          height: 32,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.none,
        ),
      ),
    );
  }
}
