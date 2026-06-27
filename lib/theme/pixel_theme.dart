import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PixelColors {
  static const Color bananaYellow = Color(0xFFF5C518);
  static const Color warmOrange = Color(0xFFE87D2A);
  static const Color jungleGreen = Color(0xFF2D7D46);
  static const Color jungleGreenDark = Color(0xFF1A4D2E);
  static const Color jungleGreenLight = Color(0xFF3D9E5F);
  static const Color creamWhite = Color(0xFFFFF8DC);
  static const Color creamLight = Color(0xFFFFFAE6);
  static const Color darkBrown = Color(0xFF4A2C0A);
  static const Color mediumBrown = Color(0xFF7A4A1E);
  static const Color lightBrown = Color(0xFFB87333);
  static const Color pixelGold = Color(0xFFFFD700);
  static const Color activeGreen = Color(0xFF4CAF50);
  static const Color disabledGray = Color(0xFF9E9E9E);
  static const Color softShadow = Color(0x40000000);
}

class PixelTheme {
  static TextStyle pixelStyle({
    double fontSize = 12,
    Color color = PixelColors.darkBrown,
    FontWeight fontWeight = FontWeight.normal,
    double lineHeight = 1.2,
  }) {
    return GoogleFonts.pressStart2p(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      height: lineHeight,
    );
  }

  static TextStyle bodyStyle({
    double fontSize = 14,
    Color color = PixelColors.darkBrown,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return GoogleFonts.nunito(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );
  }
}
