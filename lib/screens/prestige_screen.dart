import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../theme/pixel_theme.dart';
import '../widgets/banana_counter.dart';

class PrestigeScreen extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onOpenSkillTree;

  const PrestigeScreen({
    Key? key,
    required this.onClose,
    required this.onOpenSkillTree,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final stats = controller.stats;

    final bool canRebirth = stats.totalBananas >= 1000000.0;
    final int seedsEarned = (stats.totalBananas / 1000000.0).floor();

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.85),
        child: SafeArea(
          child: Column(
            children: [
              // Header title bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'BANANA REBIRTH',
                      style: PixelTheme.pixelStyle(
                        fontSize: 12,
                        color: PixelColors.bananaYellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: onClose,
                      child: Container(
                        padding: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          color: PixelColors.warmOrange,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: PixelColors.darkBrown, width: 2),
                        ),
                        child: Text(
                          'X',
                          style: PixelTheme.pixelStyle(
                            fontSize: 10,
                            color: PixelColors.creamWhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      // Golden Seed Illustration Box
                      Container(
                        decoration: BoxDecoration(
                          color: PixelColors.creamWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: PixelColors.darkBrown, width: 4),
                          boxShadow: const [
                            BoxShadow(
                              color: PixelColors.softShadow,
                              offset: Offset(0, 4),
                              blurRadius: 0,
                            )
                          ],
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.spa,
                              color: PixelColors.pixelGold,
                              size: 64,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'GOLDEN SEEDS',
                              style: PixelTheme.pixelStyle(
                                fontSize: 12,
                                color: PixelColors.darkBrown,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'You currently have: ${stats.goldenSeeds} Golden Seeds',
                              style: PixelTheme.bodyStyle(
                                fontSize: 14,
                                color: PixelColors.mediumBrown,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Permanent multiplier: +${stats.goldenSeeds * 5}% all banana income!',
                              style: PixelTheme.bodyStyle(
                                fontSize: 13,
                                color: PixelColors.jungleGreen,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Rebirth Mechanics Card
                      Container(
                        decoration: BoxDecoration(
                          color: PixelColors.creamLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: PixelColors.mediumBrown, width: 3),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '★ HOW REBIRTH WORKS ★',
                              style: PixelTheme.pixelStyle(
                                fontSize: 8,
                                color: PixelColors.darkBrown,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildInfoBullet('Requires 1,000,000 bananas to trigger.'),
                            _buildInfoBullet('Resets: Bananas, Upgrades, Tap and idle levels.'),
                            _buildInfoBullet('Keeps: Level, Skins, Maps, Achievements, and Skill Tree.'),
                            _buildInfoBullet('Grants Golden Seeds based on bananas: 1 seed per 1M bananas.'),
                            _buildInfoBullet('Spend Golden Seeds to buy custom Skill Tree nodes!'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Rebirth Action
                      GestureDetector(
                        onTap: canRebirth
                            ? () {
                                _showRebirthConfirmation(context, controller, seedsEarned);
                              }
                            : null,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: canRebirth ? PixelColors.warmOrange : PixelColors.disabledGray,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: canRebirth ? PixelColors.darkBrown : PixelColors.disabledGray,
                              width: 3,
                            ),
                            boxShadow: canRebirth
                                ? const [
                                    BoxShadow(
                                      color: PixelColors.softShadow,
                                      offset: Offset(0, 3),
                                      blurRadius: 0,
                                    )
                                  ]
                                : null,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          child: Center(
                            child: Text(
                              canRebirth
                                  ? 'REBIRTH NOW (+ $seedsEarned SEEDS)'
                                  : 'REBIRTH LOCKED (MIN 1.0M BANANAS)',
                              style: PixelTheme.pixelStyle(
                                fontSize: 8,
                                color: PixelColors.creamWhite,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Open Skill Tree Action
                      GestureDetector(
                        onTap: onOpenSkillTree,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: PixelColors.jungleGreen,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: PixelColors.jungleGreenDark,
                              width: 3,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: PixelColors.softShadow,
                                      offset: Offset(0, 3),
                                blurRadius: 0,
                              )
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          child: Center(
                            child: Text(
                              'OPEN SKILL TREE',
                              style: PixelTheme.pixelStyle(
                                fontSize: 8,
                                color: PixelColors.creamWhite,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: PixelColors.darkBrown)),
          Expanded(
            child: Text(
              text,
              style: PixelTheme.bodyStyle(fontSize: 12, color: PixelColors.darkBrown),
            ),
          ),
        ],
      ),
    );
  }

  void _showRebirthConfirmation(BuildContext context, GameController controller, int seedsEarned) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: PixelColors.creamWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PixelColors.darkBrown, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  offset: Offset(0, 8),
                  blurRadius: 0,
                )
              ],
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'CONFIRM REBIRTH',
                  style: PixelTheme.pixelStyle(
                    fontSize: 12,
                    color: PixelColors.warmOrange,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'This will reset your current bananas and upgrades level. In exchange, you will receive $seedsEarned Golden Seeds for permanent boosts and skills.',
                  style: PixelTheme.bodyStyle(
                    fontSize: 14,
                    color: PixelColors.darkBrown,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: PixelColors.jungleGreen,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: PixelColors.darkBrown, width: 2),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Center(
                            child: Text(
                              'CANCEL',
                              style: PixelTheme.pixelStyle(
                                  fontSize: 8, color: PixelColors.creamWhite),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          controller.triggerRebirth();
                          Navigator.of(context).pop();
                          onClose();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: PixelColors.warmOrange,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: PixelColors.darkBrown, width: 2),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Center(
                            child: Text(
                              'YES, REBIRTH',
                              style: PixelTheme.pixelStyle(
                                  fontSize: 8, color: PixelColors.creamWhite),
                            ),
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
}
