
import 'package:flutter/material.dart';

class ColorPalette {
  // --- Premium Red & Black Palette ---
  static const Color pureBlack = Color(0xFF000000); // Background
  static const Color darkSurface = Color(0xFF0A0A0A); // Primary Surface
  static const Color darkSurfaceVariant = Color(0xFF161616); // Secondary Surface
  static const Color livoraRed = Color(0xFFE50914); // Primary Red (Netflix-style vibrant)
  static const Color pureWhite = Color(0xFFFFFFFF); // Text/Contrast
  static const Color softGrey = Color(0xFFB3B3B3); // Secondary Text
  static const Color mediumGrey = Color(0xFF666666); // Subtle Text
  static const Color borderSubtle = Color(0xFF262626); // Outlines
  
  // Light Mode Equivalents (though the app is trending dark-first)
  static const Color background = pureBlack;
  static const Color surface = darkSurface;
  static const Color surfaceVariant = darkSurfaceVariant;
  
  // --- Semantic Colors ---
  static const Color success = Color(0xFF2ECC71); 
  static const Color error = livoraRed;   
  static const Color warning = Color(0xFFF1C40F); 
  static const Color info = Color(0xFF3498DB);    

  // --- Mappings for AppTheme ---
  static const Color primary = livoraRed;
  static const Color secondary = softGrey;
  static const Color divider = borderSubtle;
  static const Color darkDivider = borderSubtle;
  
  static const Color textPlaceholder = mediumGrey;
  static const Color lightGrey = softGrey;
  
  // Legacy aliases to avoid breaking existing code immediately
  static const Color primaryBrand = pureWhite;
  static const Color secondaryBrand = softGrey;
  static const Color accentBrand = pureWhite;
  static const Color darkBackground = pureBlack;
  static const Color darkTextPrimary = pureWhite;
  static const Color darkTextSecondary = softGrey;
  static const Color textPrimary = pureWhite;
  static const Color textSecondary = softGrey;
}
