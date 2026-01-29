import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme Mode Provider (Notifier)
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  // Key for local storage
  static const _themePrefsKey = 'theme_mode';

  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  // Load theme from shared preferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themePrefsKey);
    
    if (themeString == 'dark') {
      state = ThemeMode.dark;
    } else if (themeString == 'light') {
      state = ThemeMode.light;
    } else {
      state = ThemeMode.system;
    }
  }

  // Toggle theme (looping or simple switch)
  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (state == ThemeMode.dark) {
      state = ThemeMode.light;
      await prefs.setString(_themePrefsKey, 'light');
    } else {
      state = ThemeMode.dark;
      await prefs.setString(_themePrefsKey, 'dark');
    }
  }

  // Set specific theme
  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    String modeString;
    switch (mode) {
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.system:
      default:
        modeString = 'system';
        break;
    }
    await prefs.setString(_themePrefsKey, modeString);
  }
}
