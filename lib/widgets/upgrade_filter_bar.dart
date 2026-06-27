import 'package:flutter/material.dart';
import '../theme/pixel_theme.dart';

class UpgradeFilterBar extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const UpgradeFilterBar({
    Key? key,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  static const List<String> categories = [
    'All',
    'Click',
    'Idle',
    'Combo',
    'Critical',
    'Golden',
    'Offline',
    'Special',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
        child: Row(
          children: categories.map((category) {
            final isSelected = category.toLowerCase() == selectedCategory.toLowerCase();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: GestureDetector(
                onTap: () => onCategorySelected(category),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFF4CAF50) // Vivid Green
                        : const Color(0xFF8D6E63), // Wood Brown
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? PixelColors.pixelGold : PixelColors.darkBrown,
                      width: 2.2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: PixelColors.softShadow,
                        offset: Offset(0, 2),
                        blurRadius: 0,
                      )
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                  alignment: Alignment.center,
                  child: Text(
                    category.toUpperCase(),
                    style: PixelTheme.pixelStyle(
                      fontSize: 6.5,
                      color: PixelColors.creamWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
