import 'dart:math';
import '../models/player_stats.dart';

class OfflineEarningsService {
  /// Calculates offline earnings based on the last saved time and current passive BPS.
  /// Capped at a dynamic number of hours (default 8 hours).
  double calculateEarnings(PlayerStats stats, double offlineMultiplier, {double capHours = 8.0}) {
    if (stats.lastSavedTime <= 0 || stats.bananasPerSecond <= 0) {
      return 0.0;
    }
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsedMs = now - stats.lastSavedTime;
    
    if (elapsedMs < 1000) {
      return 0.0;
    }
    
    final elapsedSeconds = elapsedMs ~/ 1000;
    
    // Convert cap hours to seconds
    final int maxSeconds = (capHours * 3600.0).toInt();
    final cappedSeconds = min(elapsedSeconds, maxSeconds);
    
    return cappedSeconds * stats.bananasPerSecond * offlineMultiplier;
  }
}
