import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../widgets/horizontal_skin_card.dart';
import '../theme/pixel_theme.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final stats = controller.stats;

    // Build list of unlocked maps in world order
    final unlockedProgressions = controller.mapProgressions
        .where((m) => stats.unlockedMaps.contains(m.id))
        .toList();
    unlockedProgressions.sort((a, b) => a.worldIndex.compareTo(b.worldIndex));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '🏪 MONKEY SKINS SHOP',
            style: PixelTheme.pixelStyle(
              fontSize: 9,
              color: PixelColors.bananaYellow,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 110.0, left: 16.0, right: 16.0, top: 4.0),
            itemCount: unlockedProgressions.length,
            itemBuilder: (context, worldIndex) {
              final progression = unlockedProgressions[worldIndex];
              final worldSkins = controller.skins
                  .where((s) => s.mapId == progression.id)
                  .toList();

              if (worldSkins.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // World section header
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                    child: Row(
                      children: [
                        Text(
                          '📍 ${progression.name.toUpperCase()}',
                          style: PixelTheme.pixelStyle(
                            fontSize: 8,
                            color: PixelColors.darkBrown,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 2,
                            color: PixelColors.darkBrown.withValues(alpha: 0.2),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Skins in this world
                  Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 12,
                    runSpacing: 12,
                    children: worldSkins.map((skin) {
                      return HorizontalSkinCard(
                        skin: skin,
                        totalBananas: stats.totalBananas,
                        onTap: () {
                          if (skin.isUnlocked) {
                            if (!skin.isEquipped) controller.equipSkin(skin.id);
                          } else {
                            controller.buySkin(skin.id);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
