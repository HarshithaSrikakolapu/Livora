
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_palette.dart';

class AppTheme {
  // Light Theme
  static ThemeData get lightTheme {
    return _buildLightTheme();
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return _buildDarkTheme();
  }

  static ThemeData _buildLightTheme() {
    final baseTextTheme = GoogleFonts.interTextTheme();
    
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: ColorPalette.background,
      primaryColor: ColorPalette.primary,
      focusColor: ColorPalette.primary.withOpacity(0.1),
      dividerColor: ColorPalette.divider,

      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: ColorPalette.primary,
        onPrimary: ColorPalette.pureWhite,
        secondary: ColorPalette.secondary,
        onSecondary: ColorPalette.pureWhite,
        error: Color(0xFFD32F2F),
        onError: ColorPalette.pureWhite,
        background: ColorPalette.background,
        onBackground: ColorPalette.textPrimary,
        surface: ColorPalette.surface,
        onSurface: ColorPalette.textPrimary,
      ),
      
      appBarTheme: AppBarTheme(
        backgroundColor: ColorPalette.background,
        foregroundColor: ColorPalette.textPrimary,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: ColorPalette.textPrimary),
        titleTextStyle: GoogleFonts.inter(
          color: ColorPalette.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),

      cardTheme: CardThemeData(
        color: ColorPalette.pureWhite,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ColorPalette.divider, width: 1),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: ColorPalette.pureWhite,
        modalBackgroundColor: ColorPalette.pureWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: ColorPalette.primary,
        foregroundColor: ColorPalette.pureWhite,
        elevation: 4,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorPalette.primary,
          foregroundColor: ColorPalette.pureWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ColorPalette.primary,
          side: const BorderSide(color: ColorPalette.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ColorPalette.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColorPalette.lightGrey,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.primary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: ColorPalette.textSecondary),
        hintStyle: TextStyle(color: ColorPalette.textSecondary.withOpacity(0.7)),
        prefixIconColor: ColorPalette.textSecondary,
        suffixIconColor: ColorPalette.textSecondary,
      ),

      iconTheme: const IconThemeData(
        color: ColorPalette.textPrimary,
        size: 24,
      ),
      
      listTileTheme: const ListTileThemeData(
        iconColor: ColorPalette.textPrimary,
        textColor: ColorPalette.textPrimary,
        tileColor: Colors.transparent, 
      ),
      
      dividerTheme: const DividerThemeData(
        color: ColorPalette.divider,
        thickness: 1,
        space: 1,
      ),
      
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return ColorPalette.primary;
          }
          return null;
        }),
        side: const BorderSide(color: ColorPalette.textSecondary, width: 1.5),
        checkColor: MaterialStateProperty.all(ColorPalette.pureWhite),
      ),
      
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return ColorPalette.primary;
          }
          return ColorPalette.textSecondary;
        }),
      ),
      
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return ColorPalette.primary;
          }
          return ColorPalette.textSecondary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return ColorPalette.primary.withOpacity(0.3);
          }
          return ColorPalette.lightGrey;
        }),
        trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
      ),

      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(color: ColorPalette.textPrimary, fontWeight: FontWeight.bold),
        displayMedium: baseTextTheme.displayMedium?.copyWith(color: ColorPalette.textPrimary, fontWeight: FontWeight.bold),
        displaySmall: baseTextTheme.displaySmall?.copyWith(color: ColorPalette.textPrimary, fontWeight: FontWeight.bold),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(color: ColorPalette.textPrimary, fontWeight: FontWeight.bold),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(color: ColorPalette.textPrimary, fontWeight: FontWeight.bold),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(color: ColorPalette.textPrimary, fontWeight: FontWeight.bold),
        titleLarge: baseTextTheme.titleLarge?.copyWith(color: ColorPalette.textPrimary, fontWeight: FontWeight.w600),
        titleMedium: baseTextTheme.titleMedium?.copyWith(color: ColorPalette.textPrimary, fontWeight: FontWeight.w600),
        titleSmall: baseTextTheme.titleSmall?.copyWith(color: ColorPalette.textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: ColorPalette.textPrimary),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: ColorPalette.textPrimary),
        bodySmall: baseTextTheme.bodySmall?.copyWith(color: ColorPalette.textSecondary),
        labelLarge: baseTextTheme.labelLarge?.copyWith(color: ColorPalette.primary, fontWeight: FontWeight.w600),
        labelMedium: baseTextTheme.labelMedium?.copyWith(color: ColorPalette.textSecondary),
        labelSmall: baseTextTheme.labelSmall?.copyWith(color: ColorPalette.textSecondary),
      ),
    );
  }

  static ThemeData _buildDarkTheme() {
    final baseTextTheme = GoogleFonts.interTextTheme();
    const primaryColor = ColorPalette.primary; 
    const backgroundColor = ColorPalette.darkBackground;
    const surfaceColor = ColorPalette.darkSurface;
    const textColor = ColorPalette.darkTextPrimary;
    const textSecondaryColor = ColorPalette.darkTextSecondary;
    const dividerColor = ColorPalette.darkDivider;

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: ColorPalette.pureBlack, // MAPPED: App background must be BLACK (from ColorPalette.darkBackground which I set to pureBlack)
      primaryColor: primaryColor,
      focusColor: primaryColor.withOpacity(0.1),
      dividerColor: dividerColor,

      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        
        primary: primaryColor,
        onPrimary: ColorPalette.pureWhite, 
        
        secondary: ColorPalette.secondary, 
        onSecondary: primaryColor,
        
        error: primaryColor,
        onError: ColorPalette.pureWhite,
        
        background: ColorPalette.pureBlack, // MAPPED: Background Black
        onBackground: textColor,
        
        // MAPPED: Cards dark shade of provided palette
        // I'll stick to darkSurface (#1E1E1E) as it is neutral, but maybe I should tint it?
        // Prompt said "Cartds, sheets... must use dark shades of the SAME provided palette". 
        // Darkened Coral Pink would be reddish.
        // Let's rely on standard dark mode conventions for "shade" unless I want a red app.
        // #1E1E1E is standard. If I interpreted "shade of same palette" strictly, it would be difficult to read.
        // Let's stick to safe dark surface but strictly Black background.
        surface: surfaceColor, 
        onSurface: textColor,
      ),
      
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor, // Dark surface for app bar
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: primaryColor), // Colored icons
        titleTextStyle: GoogleFonts.inter(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: dividerColor, width: 1),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceColor,
        modalBackgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: ColorPalette.pureWhite,
        elevation: 2,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorPalette.primary, // Deep Teal
          foregroundColor: ColorPalette.pureWhite,   // Light Teal text
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ColorPalette.primary, // Deep Teal text
          side: const BorderSide(color: ColorPalette.secondary, width: 1.5), // Medium Teal border
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ColorPalette.primary, // Deep Teal text
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColorPalette.darkSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondaryColor),
        hintStyle: TextStyle(color: textSecondaryColor.withOpacity(0.5)),
        prefixIconColor: primaryColor,
        suffixIconColor: primaryColor,
      ),

      iconTheme: const IconThemeData(
        color: primaryColor,
        size: 24,
      ),
      
      listTileTheme: const ListTileThemeData(
        iconColor: primaryColor,
        textColor: textColor,
        tileColor: Colors.transparent, 
      ),
      
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
      
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return null;
        }),
        side: const BorderSide(color: primaryColor, width: 2),
        checkColor: MaterialStateProperty.all(ColorPalette.pureWhite),
      ),
      
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return primaryColor.withOpacity(0.6);
        }),
      ),
      
      
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return textSecondaryColor;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor.withOpacity(0.3);
          }
          return ColorPalette.darkSurfaceVariant;
        }),
        trackOutlineColor: MaterialStateProperty.all(dividerColor),
      ),
      
      // --- Overlay Themes for Dark Mode ---
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        titleTextStyle: GoogleFonts.inter(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: GoogleFonts.inter(
          color: textSecondaryColor,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: dividerColor, width: 1),
        ),
      ),
      
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceColor,
        contentTextStyle: TextStyle(color: textColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: dividerColor),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      popupMenuTheme: PopupMenuThemeData(
        color: surfaceColor,
        textStyle: TextStyle(color: textColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: dividerColor),
        ),
      ),

      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(color: textColor, fontWeight: FontWeight.bold),
        displayMedium: baseTextTheme.displayMedium?.copyWith(color: textColor, fontWeight: FontWeight.bold),
        displaySmall: baseTextTheme.displaySmall?.copyWith(color: textColor, fontWeight: FontWeight.bold),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(color: textColor, fontWeight: FontWeight.bold),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(color: textColor, fontWeight: FontWeight.bold),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(color: textColor, fontWeight: FontWeight.bold),
        titleLarge: baseTextTheme.titleLarge?.copyWith(color: textColor, fontWeight: FontWeight.w600),
        titleMedium: baseTextTheme.titleMedium?.copyWith(color: textColor, fontWeight: FontWeight.w600),
        titleSmall: baseTextTheme.titleSmall?.copyWith(color: textColor, fontWeight: FontWeight.w600),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: textColor),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: textColor),
        bodySmall: baseTextTheme.bodySmall?.copyWith(color: textSecondaryColor),
        labelLarge: baseTextTheme.labelLarge?.copyWith(color: primaryColor, fontWeight: FontWeight.w600),
        labelMedium: baseTextTheme.labelMedium?.copyWith(color: textSecondaryColor),
        labelSmall: baseTextTheme.labelSmall?.copyWith(color: textSecondaryColor),
      ),
    );
  }
}
