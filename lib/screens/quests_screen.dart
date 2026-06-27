import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../widgets/quest_card.dart';
import '../widgets/achievement_card.dart';
import '../theme/pixel_theme.dart';
import '../models/achievement.dart';
import '../models/map_theme.dart';

class QuestsScreen extends StatefulWidget {
  const QuestsScreen({Key? key}) : super(key: key);

  @override
  State<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends State<QuestsScreen> {
  bool _showAchievements = false;
  String _selectedLayer = 'all';

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final theme = controller.selectedMapTheme;

    // Filter quests
    final filteredQuests = _selectedLayer == 'all'
        ? controller.quests
        : controller.quests.where((q) => q.layer == _selectedLayer).toList();

    // Group and flatten achievements
    final Map<String, List<Achievement>> grouped = {};
    for (var ach in controller.achievements) {
      grouped.putIfAbsent(ach.category, () => []).add(ach);
    }
    final List<dynamic> flatAchievements = [];
    final categoriesOrdered = ['economy', 'tapping', 'combo', 'critical', 'golden', 'map', 'collection', 'rebirth'];
    for (var cat in categoriesOrdered) {
      final list = grouped[cat];
      if (list != null && list.isNotEmpty) {
        flatAchievements.add(cat);
        flatAchievements.addAll(list);
      }
    }

    return Column(
      children: [
        // 1. Selector Tab Buttons at top (Quests vs Achievements)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: theme.darkBorderColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.darkBorderColor, width: 2.5),
            ),
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                // Quests Tab
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showAchievements = false;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: !_showAchievements ? theme.primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      child: Text(
                        'QUESTS',
                        style: PixelTheme.pixelStyle(
                          fontSize: 8,
                          color: !_showAchievements ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Achievements Tab
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showAchievements = true;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _showAchievements ? theme.primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      child: Text(
                        'ACHIEVEMENTS',
                        style: PixelTheme.pixelStyle(
                          fontSize: 8,
                          color: _showAchievements ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. Quest Sub-tabs (Only if Quests is active)
        if (!_showAchievements) _buildQuestSubTabs(theme),

        // Claim All Button (Only if Quests is active)
        if (!_showAchievements)
          _ClaimAllButton(
            themeColor: theme.primaryColor,
            darkBorderColor: theme.darkBorderColor,
            enabled: controller.quests.any((q) => !q.claimed && q.completed),
            onTap: () => controller.claimAllQuestRewards(),
          ),

        // 3. Active List View
        Expanded(
          child: !_showAchievements
              ? (filteredQuests.isEmpty
                  ? Center(
                      child: Text(
                        'NO QUESTS FOUND',
                        style: PixelTheme.pixelStyle(fontSize: 8, color: PixelColors.disabledGray),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredQuests.length,
                      padding: const EdgeInsets.only(bottom: 110.0),
                      itemBuilder: (context, index) {
                        final quest = filteredQuests[index];
                        return QuestCard(
                          quest: quest,
                          onClaim: () => controller.claimQuestReward(quest),
                        );
                      },
                    ))
              : ListView.builder(
                  itemCount: flatAchievements.length,
                  padding: const EdgeInsets.only(bottom: 110.0),
                  itemBuilder: (context, index) {
                    final item = flatAchievements[index];
                    if (item is String) {
                      // Render Category Header
                      return Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: PixelColors.mediumBrown,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: PixelColors.darkBrown, width: 2),
                          ),
                          child: Text(
                            item.toUpperCase(),
                            style: PixelTheme.pixelStyle(
                              fontSize: 8,
                              color: PixelColors.creamWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    } else if (item is Achievement) {
                      return AchievementCard(
                        achievement: item,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildQuestSubTabs(MapTheme theme) {
    final layers = ['all', 'main', 'daily', 'weekly', 'map', 'milestone'];
    return Container(
      height: 36,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: layers.length,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        itemBuilder: (context, index) {
          final layer = layers[index];
          final isSelected = _selectedLayer == layer;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedLayer = layer;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: isSelected ? theme.primaryColor : PixelColors.creamLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? theme.darkBorderColor : PixelColors.darkBrown,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    layer.toUpperCase(),
                    style: PixelTheme.pixelStyle(
                      fontSize: 6,
                      color: isSelected ? Colors.white : PixelColors.darkBrown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
class _ClaimAllButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color themeColor;
  final Color darkBorderColor;
  final bool enabled;

  const _ClaimAllButton({
    Key? key,
    required this.onTap,
    required this.themeColor,
    required this.darkBorderColor,
    required this.enabled,
  }) : super(key: key);

  @override
  State<_ClaimAllButton> createState() => _ClaimAllButtonState();
}

class _ClaimAllButtonState extends State<_ClaimAllButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(_ClaimAllButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return Container(
        height: 44,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: PixelColors.disabledGray.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: PixelColors.disabledGray.withOpacity(0.5), width: 2.5),
        ),
        child: Center(
          child: Text(
            'CLAIM ALL',
            style: PixelTheme.pixelStyle(
              fontSize: 7.5,
              color: PixelColors.disabledGray,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          padding: const EdgeInsets.all(2.5), // glowing border gap
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.themeColor.withOpacity(0.4),
                blurRadius: 10,
                spreadRadius: 1.5,
              )
            ],
            gradient: SweepGradient(
              colors: [
                widget.themeColor,
                Colors.white,
                widget.themeColor.withOpacity(0.15),
                widget.themeColor,
              ],
              stops: const [0.0, 0.25, 0.55, 1.0],
              transform: GradientRotation(_controller.value * 2 * 3.14159265),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: widget.themeColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: widget.darkBorderColor, width: 2.0),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(8),
                child: Center(
                  child: Text(
                    'CLAIM ALL',
                    style: PixelTheme.pixelStyle(
                      fontSize: 8,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
