import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../models/map_progression.dart';
import '../theme/pixel_theme.dart';

class WorldMapScreen extends StatefulWidget {
  const WorldMapScreen({Key? key}) : super(key: key);

  @override
  State<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends State<WorldMapScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _glowController;       // gold glow for active
  late AnimationController _nextGlowController;   // green glow for next unlockable
  late AnimationController _travelController;     // travel transition

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _nextGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _travelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentMap();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _glowController.dispose();
    _nextGlowController.dispose();
    _travelController.dispose();
    super.dispose();
  }

  void _scrollToCurrentMap() {
    final controller = context.read<GameController>();
    final currentIndex = controller.currentMapProgression.worldIndex - 1;
    final targetOffset = (currentIndex * 192.0).clamp(0.0, double.infinity);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _doTravel(GameController controller) async {
    // Flash + scale up animation before traveling
    await _travelController.forward();
    controller.travelToNextMap();
    _travelController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final stats = controller.stats;
    final maps = controller.mapProgressions;
    final currentMap = controller.currentMapProgression;
    final goalReached = stats.totalBananas >= currentMap.unlockTarget;

    return Column(
      children: [
        // Relics header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6D4C41), Color(0xFF4E342E)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF3E2723), width: 2.5),
              boxShadow: const [
                BoxShadow(color: Colors.black38, offset: Offset(0, 3), blurRadius: 4),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Text('🏺', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text('JUNGLE RELICS',
                      style: PixelTheme.pixelStyle(fontSize: 7, color: const Color(0xFFD7CCC8))),
                ]),
                Text('${stats.jungleRelics}',
                    style: PixelTheme.pixelStyle(
                        fontSize: 11, color: PixelColors.pixelGold, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text('★  WORLD CAMPAIGN  ★',
              style: PixelTheme.pixelStyle(
                  fontSize: 9, color: PixelColors.bananaYellow, fontWeight: FontWeight.bold)),
        ),

        // Map cards list
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120, top: 4),
            itemCount: maps.length,
            itemBuilder: (context, index) {
              final map = maps[index];
              final isCurrentMap = map.id == currentMap.id;
              final isCompleted = map.worldIndex < currentMap.worldIndex ||
                  (isCurrentMap && goalReached && map.worldIndex < maps.length);
              final isNext = map.worldIndex == currentMap.worldIndex + 1 && goalReached;
              final isUnlocked = map.worldIndex <= currentMap.worldIndex;
              final isLocked = !isUnlocked && !isNext;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _WorldMapCard(
                  map: map,
                  maps: maps,
                  isCurrentMap: isCurrentMap,
                  isCompleted: isCompleted,
                  isLocked: isLocked,
                  isNextUnlockable: isNext,
                  totalBananas: stats.totalBananas,
                  glowController: _glowController,
                  nextGlowController: _nextGlowController,
                  travelController: _travelController,
                  onTravel: isNext
                      ? () => _showTravelDialog(context, controller, currentMap)
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showTravelDialog(
    BuildContext context,
    GameController controller,
    MapProgression currentMap,
  ) {
    final nextIndex = currentMap.worldIndex + 1;
    final allMaps = controller.mapProgressions;
    if (nextIndex > allMaps.length) return;
    final nextMap = allMaps.firstWhere((m) => m.worldIndex == nextIndex);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: PixelColors.creamWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PixelColors.darkBrown, width: 4),
              boxShadow: const [
                BoxShadow(color: Colors.black54, offset: Offset(0, 8), blurRadius: 0),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🗺 TRAVEL TO ${nextMap.name.toUpperCase()}?',
                  style: PixelTheme.pixelStyle(
                      fontSize: 10, color: PixelColors.jungleGreenDark),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8DC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: PixelColors.mediumBrown, width: 2),
                  ),
                  child: Column(
                    children: [
                      _infoRow('✅ You earn:', '+${currentMap.relicsReward} Jungle Relics'),
                      const SizedBox(height: 6),
                      _infoRow('📈 Income multiplier:', '${nextMap.worldIncomeMultiplier}x'),
                      const SizedBox(height: 6),
                      _infoRow('⚠️ Resets:', 'Bananas & Upgrades'),
                      const SizedBox(height: 6),
                      _infoRow('🔒 Kept:', 'Level, Skins, Achievements'),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: PixelColors.warmOrange,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: PixelColors.darkBrown, width: 2),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text('CANCEL',
                                style: PixelTheme.pixelStyle(fontSize: 8, color: Colors.white)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.of(ctx).pop();
                          await _doTravel(controller);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: PixelColors.jungleGreen,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: PixelColors.darkBrown, width: 2),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text('TRAVEL! 🚀',
                                style: PixelTheme.pixelStyle(fontSize: 8, color: Colors.white)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: PixelTheme.bodyStyle(fontSize: 11, color: PixelColors.darkBrown)),
        Text(value,
            style: PixelTheme.pixelStyle(
                fontSize: 8, color: PixelColors.jungleGreenDark, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ─────────────────────────────────────────────
class _WorldMapCard extends StatelessWidget {
  final MapProgression map;
  final List<MapProgression> maps;
  final bool isCurrentMap;
  final bool isCompleted;
  final bool isLocked;
  final bool isNextUnlockable;
  final double totalBananas;
  final AnimationController glowController;
  final AnimationController nextGlowController;
  final AnimationController travelController;
  final VoidCallback? onTravel;

  const _WorldMapCard({
    Key? key,
    required this.map,
    required this.maps,
    required this.isCurrentMap,
    required this.isCompleted,
    required this.isLocked,
    required this.isNextUnlockable,
    required this.totalBananas,
    required this.glowController,
    required this.nextGlowController,
    required this.travelController,
    this.onTravel,
  }) : super(key: key);

  Color get _cardBorderColor {
    if (isCurrentMap) return PixelColors.pixelGold;
    if (isNextUnlockable) return const Color(0xFF4CAF50);
    if (isLocked) return const Color(0xFF546E7A);
    if (isCompleted) return const Color(0xFF388E3C);
    return PixelColors.darkBrown;
  }

  String get _statusLabel {
    if (isCurrentMap) {
      return isCompleted ? '⚡ ACTIVE (COMPLETED)' : '⚡ ACTIVE WORLD';
    }
    if (isNextUnlockable) return '🟢 UNLOCKED - READY TO TRAVEL!';
    if (isLocked) return '🔒 LOCKED';
    if (isCompleted) return '✅ COMPLETED';
    return '';
  }

  Color get _statusColor {
    if (isCurrentMap) return PixelColors.pixelGold;
    if (isNextUnlockable) return const Color(0xFF66BB6A);
    if (isLocked) return const Color(0xFF90A4AE);
    if (isCompleted) return const Color(0xFF81C784);
    return PixelColors.pixelGold;
  }

  String _formatVal(double value) {
    if (value >= 1000000000) return '${(value / 1000000000).toStringAsFixed(1)}B';
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<GameController>();
    final double rawProgress = isCurrentMap
        ? (totalBananas / map.unlockTarget).clamp(0.0, 1.0)
        : (isCompleted || isNextUnlockable ? 1.0 : 0.0);
    final String skinPath = controller.getEquippedSkinPathForMap(map.id);

    // Choose which controller drives the glow
    final AnimationController activeGlow =
        isNextUnlockable ? nextGlowController : glowController;

    return AnimatedBuilder(
      animation: Listenable.merge([activeGlow, travelController]),
      builder: (context, child) {
        final glowOpacity = isCurrentMap
            ? (0.3 + glowController.value * 0.4)
            : isNextUnlockable
                ? (0.4 + nextGlowController.value * 0.5)
                : 0.0;

        final glowColor = isNextUnlockable
            ? const Color(0xFF4CAF50)
            : PixelColors.pixelGold;

        // Travel flash: scale up + fade out
        final travelScale = isNextUnlockable
            ? 1.0 + travelController.value * 0.08
            : 1.0;
        final travelOpacity = isNextUnlockable
            ? 1.0 - travelController.value * 0.5
            : 1.0;

        return Transform.scale(
          scale: travelScale,
          child: Opacity(
            opacity: travelOpacity,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  if (isCurrentMap || isNextUnlockable)
                    BoxShadow(
                      color: glowColor.withOpacity(glowOpacity),
                      blurRadius: isNextUnlockable ? 20 : 16,
                      spreadRadius: isNextUnlockable ? 3 : 2,
                    ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    offset: const Offset(0, 4),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    // Background image
                    Positioned.fill(
                      child: isLocked
                          ? ColorFiltered(
                              colorFilter: const ColorFilter.matrix([
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0, 0, 0, 1, 0,
                              ]),
                              child: Image.asset(map.imagePath,
                                  fit: BoxFit.cover, filterQuality: FilterQuality.low),
                            )
                          : Image.asset(map.imagePath,
                              fit: BoxFit.cover, filterQuality: FilterQuality.low),
                    ),

                    // Overlay
                    Positioned.fill(
                      child: Container(
                        color: isLocked
                            ? Colors.black.withOpacity(0.65)
                            : Colors.black.withOpacity(0.35),
                      ),
                    ),

                    // Animated green border for next unlockable
                    if (isNextUnlockable)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Color.lerp(
                                const Color(0xFF4CAF50),
                                const Color(0xFF00E676),
                                nextGlowController.value,
                              )!,
                              width: 3.5,
                            ),
                          ),
                        ),
                      )
                    else
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _cardBorderColor, width: 3),
                          ),
                        ),
                      ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Monkey thumbnail
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.45),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: _cardBorderColor.withOpacity(0.8), width: 2),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: isLocked
                                  ? const Center(
                                      child: Text('🔒', style: TextStyle(fontSize: 28)))
                                  : Image.asset(skinPath,
                                      fit: BoxFit.contain,
                                      filterQuality: FilterQuality.none,
                                      errorBuilder: (_, __, ___) =>
                                          const Center(child: Text('🐒',
                                              style: TextStyle(fontSize: 28)))),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Text & progress
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // World badge + name
                                Row(children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _cardBorderColor.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(4),
                                      border:
                                          Border.all(color: _cardBorderColor, width: 1),
                                    ),
                                    child: Text('W${map.worldIndex}',
                                        style: PixelTheme.pixelStyle(
                                            fontSize: 6,
                                            color: _cardBorderColor,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(map.name.toUpperCase(),
                                        style: PixelTheme.pixelStyle(
                                            fontSize: 9,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ]),
                                const SizedBox(height: 6),

                                // Status
                                if (_statusLabel.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    child: Text(_statusLabel,
                                        style: PixelTheme.pixelStyle(
                                            fontSize: 6.5,
                                            color: _statusColor,
                                            fontWeight: FontWeight.bold)),
                                  ),

                                // Progress bar
                                if (!isLocked) ...[
                                  Row(children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: rawProgress,
                                          minHeight: 8,
                                          backgroundColor: Colors.black38,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            isCompleted || isNextUnlockable
                                                ? const Color(0xFF4CAF50)
                                                : PixelColors.bananaYellow,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                        isCompleted || isNextUnlockable
                                            ? '100%'
                                            : '${(rawProgress * 100).toInt()}%',
                                        style: PixelTheme.pixelStyle(
                                            fontSize: 6, color: Colors.white)),
                                  ]),
                                  const SizedBox(height: 4),
                                  if (!isCompleted && !isNextUnlockable)
                                    Text('Target: ${_formatVal(map.unlockTarget)} 🍌',
                                        style: PixelTheme.bodyStyle(
                                            fontSize: 10,
                                            color: const Color(0xFFFFECB3))),
                                ],

                                const SizedBox(height: 4),
                                Row(children: [
                                  _infoChip('${map.worldIncomeMultiplier}x Income'),
                                  const SizedBox(width: 6),
                                  _infoChip('+${map.relicsReward} 🏺'),
                                ]),
                              ],
                            ),
                          ),

                          // Right action area
                          if (onTravel != null) ...[
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: onTravel,
                              child: AnimatedBuilder(
                                animation: isNextUnlockable
                                    ? nextGlowController
                                    : glowController,
                                builder: (context, _) {
                                  final btnGlow = isNextUnlockable
                                      ? nextGlowController.value
                                      : glowController.value;
                                  return Container(
                                    width: 60,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isNextUnlockable
                                          ? Color.lerp(
                                              const Color(0xFF2E7D32),
                                              const Color(0xFF43A047),
                                              btnGlow,
                                            )
                                          : PixelColors.jungleGreen,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isNextUnlockable
                                            ? Color.lerp(
                                                const Color(0xFF4CAF50),
                                                const Color(0xFF00E676),
                                                btnGlow,
                                              )!
                                            : PixelColors.pixelGold,
                                        width: 2.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (isNextUnlockable
                                                  ? const Color(0xFF4CAF50)
                                                  : PixelColors.pixelGold)
                                              .withOpacity(0.3 + btnGlow * 0.4),
                                          blurRadius: isNextUnlockable ? 14 : 8,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('🚀',
                                            style: TextStyle(fontSize: 18)),
                                        const SizedBox(height: 4),
                                        Text('GO!',
                                            style: PixelTheme.pixelStyle(
                                                fontSize: 6,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],

                          // Completed check
                          if (isCompleted && onTravel == null) ...[
                            const SizedBox(width: 10),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B5E20),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color(0xFF4CAF50), width: 2),
                              ),
                              child: const Center(
                                  child: Text('✅', style: TextStyle(fontSize: 18))),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Text(label,
          style:
              PixelTheme.pixelStyle(fontSize: 5.5, color: const Color(0xFFFFECB3))),
    );
  }
}
