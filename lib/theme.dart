import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    const seedColor = Color(0xFF1976D2);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      cardTheme: const CardThemeData(
        elevation: 2,
        margin: EdgeInsets.all(8),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return Colors.grey.shade400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary.withOpacity(0.5);
          }
          return Colors.grey.shade300;
        }),
      ),
    );
  }

  static ThemeData get darkTheme {
    const seedColor = Color(0xFF64B5F6);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      cardTheme: const CardThemeData(
        elevation: 2,
        margin: EdgeInsets.all(8),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return Colors.grey.shade600;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary.withOpacity(0.5);
          }
          return Colors.grey.shade700;
        }),
      ),
    );
  }
}

class UnitColors {
  // Light mode colors
  static const muteahhitBackgroundLight = Color(0xFFFCE7F3);
  static const muteahhitBorderLight = Color(0xFFF9A8D4);
  static const toprakSahibiBackgroundLight = Colors.white;
  static const toprakSahibiBorderLight = Colors.grey;
  
  // Dark mode colors
  static const muteahhitBackgroundDark = Color(0xFF4A1E3A);
  static const muteahhitBorderDark = Color(0xFF8B5A87);
  static const toprakSahibiBackgroundDark = Color(0xFF2A2A2A);
  static const toprakSahibiBorderDark = Color(0xFF666666);
  
  static Color getBackgroundColor(bool isMuteahhit, bool isDark) {
    if (isMuteahhit) {
      return isDark ? muteahhitBackgroundDark : muteahhitBackgroundLight;
    } else {
      return isDark ? toprakSahibiBackgroundDark : toprakSahibiBackgroundLight;
    }
  }
  
  static Color getBorderColor(bool isMuteahhit, bool isDark) {
    if (isMuteahhit) {
      return isDark ? muteahhitBorderDark : muteahhitBorderLight;
    } else {
      return isDark ? toprakSahibiBorderDark : toprakSahibiBorderLight;
    }
  }
  
  // Legacy methods for backward compatibility
  static Color muteahhitBackground = muteahhitBackgroundLight;
  static Color muteahhitBorder = muteahhitBorderLight;
  static Color toprakSahibiBackground = toprakSahibiBackgroundLight;
  static Color toprakSahibiBorder = toprakSahibiBorderLight;
}