import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../models/skin.dart';
import '../models/player_stats.dart';
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
    final theme = controller.selectedMapTheme;

    // Filter skins belonging to the currently active map theme
    final mapSkins = controller.skins.where((s) => s.mapId == theme.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // Map Title Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Text(
                '📍 ${theme.name.toUpperCase()} SKINS',
                style: PixelTheme.pixelStyle(
                  fontSize: 8.5,
                  color: theme.darkBorderColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 2,
                  color: theme.darkBorderColor.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Centered Wrap list of skins
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 110.0, left: 16.0, right: 16.0, top: 8.0),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: mapSkins.map((skin) {
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
            ),
          ),
        ),
      ],
    );
  }
}
