import 'package:flutter/material.dart';
import '../theme/pixel_theme.dart';

enum GameTab {
  jungle,
  upgrades,
  world,   // ← Ortadaki yeni sekme
  quests,
  shop,
}

class PixelBottomNavBar extends StatefulWidget {
  final GameTab selectedTab;
  final ValueChanged<GameTab> onTabSelected;
  final Color darkBorderColor;
  final Color activeColor;
  final Set<GameTab> glowingTabs;

  const PixelBottomNavBar({
    Key? key,
    required this.selectedTab,
    required this.onTabSelected,
    this.darkBorderColor = PixelColors.darkBrown,
    this.activeColor = const Color(0xFF4CAF50),
    this.glowingTabs = const {},
  }) : super(key: key);

  @override
  State<PixelBottomNavBar> createState() => _PixelBottomNavBarState();
}

class _PixelBottomNavBarState extends State<PixelBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  IconData _getIconData(GameTab tab) {
    switch (tab) {
      case GameTab.jungle:
        return Icons.park;
      case GameTab.upgrades:
        return Icons.arrow_upward;
      case GameTab.world:
        return Icons.public;
      case GameTab.quests:
        return Icons.emoji_events;
      case GameTab.shop:
        return Icons.shopping_basket;
    }
  }

  String _getLabel(GameTab tab) {
    switch (tab) {
      case GameTab.jungle:
        return 'JUNGLE';
      case GameTab.upgrades:
        return 'UPGRADES';
      case GameTab.world:
        return 'WORLD';
      case GameTab.quests:
        return 'QUESTS';
      case GameTab.shop:
        return 'SHOP';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3E2723),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border(
          top: BorderSide(color: widget.darkBorderColor, width: 4),
          left: BorderSide(color: widget.darkBorderColor, width: 4),
          right: BorderSide(color: widget.darkBorderColor, width: 4),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            offset: Offset(0, -3),
            blurRadius: 6,
          )
        ],
      ),
      padding: EdgeInsets.only(
        left: 4.0,
        right: 4.0,
        top: 8.0,
        bottom: MediaQuery.of(context).padding.bottom + 8.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: GameTab.values.map((tab) {
          final isSelected = tab == widget.selectedTab;
          final isWorld = tab == GameTab.world;

          return Expanded(
            flex: isWorld ? 2 : 1,
            child: GestureDetector(
              onTap: () => widget.onTabSelected(tab),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: isWorld
                    ? _buildWorldButton(isSelected)
                    : _buildNormalButton(tab, isSelected),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWorldButton(bool isSelected) {
    final shouldGlow = widget.glowingTabs.contains(GameTab.world);

    if (!shouldGlow) {
      return Container(
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF27AE60), Color(0xFF1A7A45)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          color: isSelected ? null : const Color(0xFF5D4037),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? PixelColors.pixelGold : const Color(0xFF8D6E63),
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: PixelColors.pixelGold.withOpacity(0.45),
                    offset: const Offset(0, 3),
                    blurRadius: 6,
                  ),
                ]
              : [
                  const BoxShadow(
                    color: Colors.black38,
                    offset: Offset(0, 2),
                    blurRadius: 0,
                  )
                ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: _buildWorldButtonContent(isSelected),
      );
    }

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final animValue = _glowController.value;
        final baseColor = widget.activeColor;
        final highlightColor = Colors.white;
        final glowColor = baseColor;
        final double blurRadius = 4.0 + animValue * 6.0;

        return Container(
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(0.4 + animValue * 0.3),
                blurRadius: blurRadius,
                spreadRadius: 1.0,
              ),
            ],
            gradient: SweepGradient(
              colors: [
                glowColor,
                highlightColor,
                glowColor.withOpacity(0.15),
                glowColor,
              ],
              stops: const [0.0, 0.25, 0.55, 1.0],
              transform: GradientRotation(_glowController.value * 2 * 3.14159265),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF27AE60), Color(0xFF1A7A45)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : null,
              color: isSelected ? null : const Color(0xFF5D4037),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? PixelColors.pixelGold : const Color(0xFF8D6E63),
                width: 2.0,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 5.5),
            child: _buildWorldButtonContent(isSelected),
          ),
        );
      },
    );
  }

  Widget _buildWorldButtonContent(bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.public,
          color: isSelected ? Colors.white : const Color(0xFFBCAAA4),
          size: 22,
        ),
        const SizedBox(height: 3),
        Text(
          'WORLD',
          style: PixelTheme.pixelStyle(
            fontSize: 6,
            color: isSelected ? Colors.white : const Color(0xFFBCAAA4),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNormalButton(GameTab tab, bool isSelected) {
    final shouldGlow = widget.glowingTabs.contains(tab);

    if (!shouldGlow) {
      return Container(
        decoration: BoxDecoration(
          color: isSelected ? widget.activeColor : const Color(0xFF795548),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? PixelColors.pixelGold : widget.darkBorderColor,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? PixelColors.pixelGold.withOpacity(0.35)
                  : Colors.black38,
              offset: const Offset(0, 3),
              blurRadius: isSelected ? 3 : 0,
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: _buildButtonContent(tab, isSelected),
      );
    }

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final animValue = _glowController.value;
        final baseColor = widget.activeColor;
        final highlightColor = Colors.white;
        final glowColor = baseColor;
        final double blurRadius = 4.0 + animValue * 6.0;

        return Container(
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(0.4 + animValue * 0.3),
                blurRadius: blurRadius,
                spreadRadius: 1.0,
              ),
            ],
            gradient: SweepGradient(
              colors: [
                glowColor,
                highlightColor,
                glowColor.withOpacity(0.15),
                glowColor,
              ],
              stops: const [0.0, 0.25, 0.55, 1.0],
              transform: GradientRotation(_glowController.value * 2 * 3.14159265),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? widget.activeColor : const Color(0xFF795548),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? PixelColors.pixelGold : widget.darkBorderColor,
                width: 2.0,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 5.5),
            child: _buildButtonContent(tab, isSelected),
          ),
        );
      },
    );
  }

  Widget _buildButtonContent(GameTab tab, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _getIconData(tab),
          color: isSelected ? Colors.white : const Color(0xFF3E2723),
          size: 19,
        ),
        const SizedBox(height: 3),
        Text(
          _getLabel(tab),
          style: PixelTheme.pixelStyle(
            fontSize: 5.5,
            color: isSelected ? Colors.white : const Color(0xFF3E2723),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
