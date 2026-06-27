import 'package:flutter/material.dart';
import '../models/quest.dart';
import '../theme/pixel_theme.dart';
import '../widgets/banana_counter.dart';

class QuestCard extends StatelessWidget {
  final Quest quest;
  final VoidCallback onClaim;

  const QuestCard({
    Key? key,
    required this.quest,
    required this.onClaim,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progressFactor = (quest.progress / quest.targetValue).clamp(0.0, 1.0);
    final isCompleted = quest.completed;
    final isClaimed = quest.claimed;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(
          color: PixelColors.creamWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PixelColors.darkBrown, width: 3),
          boxShadow: const [
            BoxShadow(
              color: PixelColors.softShadow,
              offset: Offset(0, 4),
              blurRadius: 0,
            )
          ],
        ),
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            // Details: Name, Description, and Progress meter
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: quest.layer == 'main'
                              ? Colors.blue.shade800
                              : quest.layer == 'daily'
                                  ? Colors.orange.shade800
                                  : quest.layer == 'weekly'
                                      ? Colors.purple.shade800
                                      : quest.layer == 'map'
                                          ? Colors.teal.shade800
                                          : Colors.red.shade800,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: PixelColors.darkBrown, width: 1.5),
                        ),
                        child: Text(
                          quest.layer.toUpperCase(),
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
                          quest.title.toUpperCase(),
                          style: PixelTheme.pixelStyle(
                            fontSize: 9,
                            color: PixelColors.darkBrown,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    quest.description,
                    style: PixelTheme.bodyStyle(
                      fontSize: 12,
                      color: PixelColors.mediumBrown,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Progress Bar & Count Text
                  Row(
                    children: [
                      // Bar Frame
                      Expanded(
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0C097).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: PixelColors.darkBrown, width: 1.5),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: progressFactor,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: PixelColors.jungleGreen,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${BananaCounter.formatNumber(quest.progress)}/${BananaCounter.formatNumber(quest.targetValue)}',
                        style: PixelTheme.pixelStyle(
                          fontSize: 6,
                          color: PixelColors.darkBrown,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 14),
            
            // Claim button
            GestureDetector(
              onTap: (isCompleted && !isClaimed) ? onClaim : null,
              child: Container(
                width: 84,
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                decoration: BoxDecoration(
                  color: isClaimed
                      ? PixelColors.darkBrown.withOpacity(0.15)
                      : isCompleted
                          ? PixelColors.activeGreen
                          : PixelColors.disabledGray,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isClaimed
                        ? PixelColors.darkBrown.withOpacity(0.2)
                        : isCompleted
                            ? PixelColors.jungleGreenDark
                            : PixelColors.disabledGray,
                    width: 2.5,
                  ),
                  boxShadow: isClaimed
                      ? null
                      : const [
                          BoxShadow(
                            color: PixelColors.softShadow,
                            offset: Offset(0, 2),
                            blurRadius: 0,
                          )
                        ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isClaimed) ...[
                      Text(
                        'CLAIMED',
                        style: PixelTheme.pixelStyle(
                          fontSize: 7,
                          color: PixelColors.darkBrown.withOpacity(0.4),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/icons/banana.png',
                            width: 10,
                            height: 10,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.none,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '+${BananaCounter.formatNumber(quest.reward)}',
                            style: PixelTheme.pixelStyle(
                              fontSize: 7,
                              color: isCompleted
                                  ? PixelColors.creamWhite
                                  : PixelColors.creamWhite.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isCompleted ? 'CLAIM!' : 'LOCKED',
                        style: PixelTheme.pixelStyle(
                          fontSize: 6,
                          color: isCompleted
                              ? PixelColors.creamWhite
                              : PixelColors.creamWhite.withOpacity(0.6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
