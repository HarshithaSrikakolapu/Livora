
import 'package:flutter/material.dart';

class ColorPalette {
  // Livora Brand Colors
  static const Color livoraRed = Color(0xFFE50914); // Primary Accent
  static const Color deepRed = Color(0xFFB2070F);    // Darker shade
  
  // Neutral Colors
  static const Color pureWhite = Colors.white;
  static const Color pureBlack = Colors.black;
  static const Color darkCharcoal = Color(0xFF121212); // Main Dark Background
  static const Color darkSurface = Color(0xFF1E1E1E);  // Cards/Sheets
  static const Color greyText = Color(0xFFB0B0B0);
  static const Color lightGrey = Color(0xFFF5F5F5);

  // Mappings
  static const Color primary = livoraRed;
  static const Color secondary = deepRed;
  
  static const Color background = pureWhite;
  static const Color surface = pureWhite;
  
  static const Color textPrimary = darkCharcoal;
  static const Color textSecondary = greyText;
  static const Color iconColor = darkCharcoal;
  static const Color divider = Color(0xFFE0E0E0);

  // Dark Mode Palette
  static const Color darkBackground = darkCharcoal;
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  
  static const Color darkTextPrimary = pureWhite;
  static const Color darkTextSecondary = greyText;
  static const Color darkDivider = Color(0xFF333333);

}
