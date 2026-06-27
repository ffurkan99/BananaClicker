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

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final stats = controller.stats;

    // 1. Filter upgrades by category
    List<Upgrade> filteredUpgrades = List.from(controller.upgrades);
    if (_selectedCategory.toLowerCase() != 'all') {
      filteredUpgrades = filteredUpgrades
          .where((u) => u.category.toLowerCase() == _selectedCategory.toLowerCase())
          .toList();
    }

    // 2. Sort upgrades from cheapest to most expensive (by actual cost)
    final worldCostMultiplier = controller.currentMapProgression.worldCostMultiplier;
    filteredUpgrades.sort((a, b) => a.getCost(worldCostMultiplier).compareTo(b.getCost(worldCostMultiplier)));

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
            padding: const EdgeInsets.only(top: 4.0, bottom: 120.0), // Safe bottom padding so bottom nav doesn't cover cards
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
