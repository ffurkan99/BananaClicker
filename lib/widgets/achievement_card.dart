import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/achievement.dart';
import '../theme/pixel_theme.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const AchievementCard({
    Key? key,
    required this.achievement,
  }) : super(key: key);

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final bool isUnlocked = achievement.unlocked;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked ? PixelColors.creamWhite : PixelColors.creamWhite.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked ? PixelColors.pixelGold : PixelColors.darkBrown,
            width: 3,
          ),
          boxShadow: const [
            BoxShadow(
              color: PixelColors.softShadow,
              offset: Offset(0, 4),
              blurRadius: 0,
            )
          ],
        ),
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Left Status Icon (Gold Star for Unlocked, Lock for Locked)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isUnlocked ? const Color(0xFFFFF9C4) : PixelColors.creamLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isUnlocked ? PixelColors.pixelGold : PixelColors.darkBrown,
                  width: 2,
                ),
              ),
              child: Icon(
                isUnlocked ? Icons.star : Icons.lock,
                color: isUnlocked ? PixelColors.pixelGold : PixelColors.disabledGray,
                size: 22,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Text details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: achievement.category == 'tapping'
                              ? Colors.orange.shade800
                              : achievement.category == 'economy'
                                  ? Colors.amber.shade900
                                  : achievement.category == 'combo'
                                      ? Colors.purple.shade800
                                      : achievement.category == 'critical'
                                          ? Colors.red.shade800
                                          : achievement.category == 'golden'
                                              ? Colors.yellow.shade900
                                              : achievement.category == 'map'
                                                  ? Colors.teal.shade800
                                                  : achievement.category == 'collection'
                                                      ? Colors.blue.shade800
                                                      : Colors.pink.shade800,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isUnlocked ? PixelColors.darkBrown : PixelColors.disabledGray,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          achievement.category.toUpperCase(),
                          style: PixelTheme.pixelStyle(
                            fontSize: 5,
                            color: PixelColors.creamWhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          achievement.title.toUpperCase(),
                          style: PixelTheme.pixelStyle(
                            fontSize: 9,
                            color: isUnlocked ? PixelColors.darkBrown : PixelColors.disabledGray,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: PixelTheme.bodyStyle(
                      fontSize: 12,
                      color: isUnlocked ? PixelColors.mediumBrown : PixelColors.disabledGray,
                    ),
                  ),
                  if (isUnlocked && achievement.unlockedAt != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Unlocked: ${_formatDate(achievement.unlockedAt!)}',
                      style: PixelTheme.bodyStyle(
                        fontSize: 10,
                        color: PixelColors.jungleGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
