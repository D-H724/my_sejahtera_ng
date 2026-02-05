
import 'package:flutter/material.dart';

class AppThemes {
  static const String defaultTheme = 'default';
  static const String cyberpunk = 'cyberpunk';
  static const String nature = 'nature';

  static List<Color> getBackgroundGradient(String themeId) {
    switch (themeId) {
      case cyberpunk:
        return const [Color(0xFF2B0030), Color(0xFF1A0B2E), Color(0xFF000000)];
      case nature:
        return const [Color(0xFF11998e), Color(0xFF38ef7d)];
      case defaultTheme:
      default:
        // Original dark blue gradient or similar
        return const [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)];
    }
  }

  static Color getPrimaryColor(String themeId) {
    switch (themeId) {
      case cyberpunk:
        return const Color(0xFF00E5FF); // Neon Blue
      case nature:
        return const Color(0xFFB2FF59); // Light Green
      case defaultTheme:
      default:
        return const Color(0xFF4FC3F7); // Light Blue
    }
  }

  static Color getAccentColor(String themeId) {
    switch (themeId) {
      case cyberpunk:
        return const Color(0xFFFF00CC); // Neon Pink
      case nature:
        return const Color(0xFFCDDC39); // Lime
      case defaultTheme:
      default:
        return Colors.amber;
    }
  }
}
