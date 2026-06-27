import 'package:flutter/services.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool isSoundEnabled = true;
  bool isVibrationEnabled = true;

  void playTap() {
    if (isVibrationEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  void playUpgrade() {
    if (isVibrationEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  void playCritical() {
    if (isVibrationEnabled) {
      HapticFeedback.heavyImpact();
    }
  }

  void playGoldenBanana() {
    if (isVibrationEnabled) {
      HapticFeedback.vibrate();
    }
  }

  void playQuestComplete() {
    if (isVibrationEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  void playLevelUp() {
    if (isVibrationEnabled) {
      HapticFeedback.vibrate();
    }
  }

  void vibrateLight() {
    if (isVibrationEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  void vibrateStrong() {
    if (isVibrationEnabled) {
      HapticFeedback.heavyImpact();
    }
  }
}
