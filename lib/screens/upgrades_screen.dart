import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../models/upgrade.dart';
import '../widgets/upgrade_card.dart';
import '../widgets/upgrade_filter_bar.dart';
import '../theme/pixel_theme.dart';

class UpgradesScreen extends StatefulWidget {
  const UpgradesScreen({Key? key}) : super(key: key);

  @override
  State<UpgradesScreen> createState() => _UpgradesScreenState();
}

class _UpgradesScreenState extends State<UpgradesScreen> {
  String _selectedCategory = 'All';

  List<Upgrade> _getSortedFilteredUpgrades(GameController controller) {
    List<Upgrade> list = List.from(controller.upgrades);
    if (_selectedCategory.toLowerCase() != 'all') {
      list = list.where((u) => u.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
    }
    final multiplier = controller.currentMapProgression.worldCostMultiplier;
    list.sort((a, b) => a.getCost(multiplier).compareTo(b.getCost(multiplier)));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final stats = controller.stats;
    final filteredUpgrades = _getSortedFilteredUpgrades(controller);

    return Column(
      children: [
        // Upgrades Header Card
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 2.0),
          child: Text(
            '★ UPGRADES SHOP ★',
            style: PixelTheme.pixelStyle(
              fontSize: 10,
              color: PixelColors.bananaYellow,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Category Filter Bar
        UpgradeFilterBar(
          selectedCategory: _selectedCategory,
          onCategorySelected: (category) {
            setState(() {
              _selectedCategory = category;
            });
          },
        ),

        // Scrollable list of cards
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 4.0, bottom: 120.0),
            itemCount: filteredUpgrades.length,
            itemBuilder: (context, index) {
              final upgrade = filteredUpgrades[index];
              return UpgradeCard(
                upgrade: upgrade,
                totalBananas: stats.totalBananas,
                onBuy: () => controller.buyUpgrade(upgrade),
              );
            },
          ),
        ),
      ],
    );
  }
}
