import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../models/skill_node.dart';
import '../theme/pixel_theme.dart';

class SkillTreeScreen extends StatelessWidget {
  final VoidCallback onClose;

  const SkillTreeScreen({
    Key? key,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final stats = controller.stats;

    // Categorize nodes by branch
    final Map<String, List<SkillNode>> branches = {};
    for (var node in controller.skills) {
      branches.putIfAbsent(node.branch, () => []).add(node);
    }

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.9),
        child: SafeArea(
          child: Column(
            children: [
              // Header title bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MONKEY SKILLS',
                          style: PixelTheme.pixelStyle(
                            fontSize: 12,
                            color: PixelColors.bananaYellow,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Seeds: ${stats.goldenSeeds} | Active Skills: ${stats.unlockedSkills.length}',
                          style: PixelTheme.bodyStyle(
                            fontSize: 12,
                            color: PixelColors.creamWhite,
                          ),
                        ),
                      ],
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
                          'BACK',
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
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  children: branches.entries.map((entry) {
                    final branchName = entry.key;
                    final nodes = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Branch Title Banner
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: PixelColors.darkBrown,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: PixelColors.mediumBrown, width: 1.5),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                            child: Text(
                              branchName.toUpperCase(),
                              style: PixelTheme.pixelStyle(
                                fontSize: 8,
                                color: PixelColors.bananaYellow,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        // Nodes list
                        ...nodes.map((node) {
                          final isUnlocked = node.isUnlocked;
                          final canAfford = stats.goldenSeeds >= node.cost;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: PixelColors.creamWhite,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isUnlocked ? PixelColors.pixelGold : PixelColors.darkBrown,
                                  width: 2.5,
                                ),
                              ),
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  // Detail text
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          node.name.toUpperCase(),
                                          style: PixelTheme.pixelStyle(
                                            fontSize: 9,
                                            color: PixelColors.darkBrown,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          node.description,
                                          style: PixelTheme.bodyStyle(
                                            fontSize: 12,
                                            color: PixelColors.mediumBrown,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // Purchase/Unlock Button
                                  GestureDetector(
                                    onTap: (!isUnlocked && canAfford)
                                        ? () => controller.buySkillNode(node.id)
                                        : null,
                                    child: Container(
                                      width: 90,
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      decoration: BoxDecoration(
                                        color: isUnlocked
                                            ? PixelColors.pixelGold
                                            : canAfford
                                                ? PixelColors.jungleGreen
                                                : PixelColors.disabledGray,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isUnlocked
                                              ? PixelColors.warmOrange
                                              : canAfford
                                                  ? PixelColors.jungleGreenDark
                                                  : PixelColors.disabledGray,
                                          width: 2,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: isUnlocked
                                          ? Text(
                                              'UNLOCKED',
                                              style: PixelTheme.pixelStyle(
                                                fontSize: 6,
                                                color: PixelColors.darkBrown,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.spa,
                                                  color: PixelColors.creamWhite,
                                                  size: 10,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${node.cost} SEED',
                                                  style: PixelTheme.pixelStyle(
                                                    fontSize: 6,
                                                    color: PixelColors.creamWhite,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 12),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
