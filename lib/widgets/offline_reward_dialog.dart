import 'package:flutter/material.dart';
import '../theme/pixel_theme.dart';
import '../widgets/banana_counter.dart';

class OfflineRewardDialog extends StatelessWidget {
  final double pendingEarnings;
  final double elapsedHours;
  final double clampedHours;
  final VoidCallback onClaim;
  final Color darkBorderColor;
  final String? uiThemePath;

  const OfflineRewardDialog({
    Key? key,
    required this.pendingEarnings,
    required this.elapsedHours,
    required this.clampedHours,
    required this.onClaim,
    this.darkBorderColor = PixelColors.darkBrown,
    this.uiThemePath,
  }) : super(key: key);

  String _formatDuration(double hours) {
    if (hours <= 0) return '0 min';
    if (hours < 1.0) {
      final minutes = (hours * 60).toInt();
      return '$minutes min';
    } else {
      final h = hours.floor();
      final m = ((hours - h) * 60).toInt();
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: PixelColors.creamWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: darkBorderColor, width: 4),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    offset: Offset(0, 8),
                    blurRadius: 0,
                  )
                ],
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title bar
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF795548), // Wood brown title background
                      border: Border.all(color: darkBorderColor, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'WELCOME BACK!',
                      style: PixelTheme.pixelStyle(
                        fontSize: 12,
                        color: PixelColors.creamWhite,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    'Your monkey crew was busy harvesting bananas in your absence!',
                    style: PixelTheme.bodyStyle(
                      fontSize: 13,
                      color: darkBorderColor,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Detail metrics table
                  Container(
                    decoration: BoxDecoration(
                      color: PixelColors.creamLight.withOpacity(0.9),
                      border: Border.all(color: darkBorderColor.withOpacity(0.6), width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _buildRow('Away Time:', _formatDuration(elapsedHours)),
                        Divider(color: darkBorderColor.withOpacity(0.5), height: 12),
                        _buildRow('Capped At:', _formatDuration(clampedHours)),
                        Divider(color: darkBorderColor.withOpacity(0.5), height: 12),
                        _buildRow('Efficiency:', '60% (Idle Penalty)'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Earning Display
                  Container(
                    decoration: BoxDecoration(
                      color: PixelColors.bananaYellow.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: PixelColors.bananaYellow, width: 3),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/icons/banana.png',
                          width: 32,
                          height: 32,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.none,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '+${BananaCounter.formatNumber(pendingEarnings)}',
                          style: PixelTheme.pixelStyle(
                            fontSize: 14,
                            color: darkBorderColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Claim Button
                  GestureDetector(
                    onTap: onClaim,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50), // Claim green
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: darkBorderColor, width: 3),
                        boxShadow: const [
                          BoxShadow(
                            color: PixelColors.softShadow,
                            offset: Offset(0, 4),
                            blurRadius: 0,
                          )
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      child: Center(
                        child: Text(
                          'CLAIM BANANAS',
                          style: PixelTheme.pixelStyle(
                            fontSize: 10,
                            color: PixelColors.creamWhite,
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
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: PixelTheme.pixelStyle(fontSize: 7.5, color: darkBorderColor),
        ),
        Text(
          value,
          style: PixelTheme.pixelStyle(fontSize: 7.5, color: darkBorderColor, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
