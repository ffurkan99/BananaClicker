import 'package:flutter/material.dart';

class MapTheme {
  final String id;
  final String name;
  final String description;
  final double cost;
  final String backgroundPath;
  final String monkeyPath;
  final Color primaryColor;
  final Color secondaryColor;
  final Color darkBorderColor;
  final Color cardBaseColor;
  final Color cardTrimColor;
  final Color iconFrameColor;
  final bool isUnlocked;
  final bool isEquipped;

  String get imagePath => backgroundPath;
  String get cardFramePath => 'assets/images/ui/upgrade_cards/${id}_upgrade_card.png';
  String get uiThemePath => 'assets/images/ui/theme_components/${id}_ui_components.png';

  MapTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.backgroundPath,
    required this.monkeyPath,
    required this.primaryColor,
    required this.secondaryColor,
    required this.darkBorderColor,
    required this.cardBaseColor,
    required this.cardTrimColor,
    required this.iconFrameColor,
    this.isUnlocked = false,
    this.isEquipped = false,
  });

  MapTheme copyWith({
    bool? isUnlocked,
    bool? isEquipped,
  }) {
    return MapTheme(
      id: id,
      name: name,
      description: description,
      cost: cost,
      backgroundPath: backgroundPath,
      monkeyPath: monkeyPath,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      darkBorderColor: darkBorderColor,
      cardBaseColor: cardBaseColor,
      cardTrimColor: cardTrimColor,
      iconFrameColor: iconFrameColor,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isEquipped: isEquipped ?? this.isEquipped,
    );
  }
}
