
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_palette.dart';

class AppTheme {
  // --- Text Theme Generator ---
  static TextTheme _buildTextTheme(TextTheme base, Color primaryColor, Color secondaryColor) {
    return base.copyWith(
      displayLarge: GoogleFonts.outfit(
        color: primaryColor,
        fontWeight: FontWeight.w700,
        fontSize: 32,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.outfit(
        color: primaryColor,
        fontWeight: FontWeight.w600,
        fontSize: 28,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.outfit(
        color: primaryColor,
        fontWeight: FontWeight.w600,
        fontSize: 24,
      ),
      headlineLarge: GoogleFonts.outfit(
        color: primaryColor,
        fontWeight: FontWeight.w600,
        fontSize: 22,
      ),
      headlineMedium: GoogleFonts.outfit(
        color: primaryColor,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      titleLarge: GoogleFonts.inter(
        color: primaryColor,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      titleMedium: GoogleFonts.inter(
        color: primaryColor,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      bodyLarge: GoogleFonts.inter(
        color: primaryColor,
        fontSize: 16,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        color: primaryColor,
        fontSize: 14,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(
        color: secondaryColor,
        fontSize: 12,
      ),
      labelLarge: GoogleFonts.inter(
        color: secondaryColor,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }

  // --- Light Theme (Now also Black-centered for premium feel) ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark, // Force dark-ish even in light mode for the premium look
      primaryColor: ColorPalette.primary,
      scaffoldBackgroundColor: ColorPalette.background,
      dividerColor: ColorPalette.divider,
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: ColorPalette.livoraRed,
        onPrimary: ColorPalette.pureWhite,
        secondary: ColorPalette.softGrey,
        onSecondary: ColorPalette.pureBlack,
        surface: ColorPalette.darkSurface,
        onSurface: ColorPalette.pureWhite,
        surfaceContainerHighest: ColorPalette.darkSurfaceVariant,
        outline: ColorPalette.borderSubtle,
        error: ColorPalette.livoraRed,
        onError: ColorPalette.pureWhite,
      ),

      // Typography
      textTheme: _buildTextTheme(
        GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        ColorPalette.pureWhite,
        ColorPalette.softGrey,
      ),

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: ColorPalette.pureBlack.withOpacity(0.8),
        foregroundColor: ColorPalette.pureWhite,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.outfit(
          color: ColorPalette.pureWhite,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
        iconTheme: const IconThemeData(color: ColorPalette.pureWhite),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColorPalette.darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ColorPalette.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ColorPalette.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ColorPalette.pureWhite, width: 1.5),
        ),
        labelStyle: const TextStyle(color: ColorPalette.softGrey),
        hintStyle: TextStyle(color: ColorPalette.softGrey.withOpacity(0.5)),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorPalette.livoraRed,
          foregroundColor: ColorPalette.pureWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ColorPalette.pureWhite,
          side: const BorderSide(color: ColorPalette.borderSubtle, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: ColorPalette.darkSurface,
        modalBackgroundColor: ColorPalette.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      iconTheme: const IconThemeData(color: ColorPalette.pureWhite, size: 24),
    );
  }

  // --- Dark Theme (The Primary Experience) ---
  static ThemeData get darkTheme => lightTheme; // For this premium B&W theme, we merge them for consistency
}

// Helper for ColorPalette in method (if needed for old references, though class above uses static)
extension ColorPaletteExtension on ColorPalette {
   static const Color textPlaceholder = Color(0xFF94A3B8);
}
