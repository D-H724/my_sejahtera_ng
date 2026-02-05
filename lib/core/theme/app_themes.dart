
import 'package:flutter/material.dart';

class AppThemes {
  static const String defaultTheme = 'default';
  static const String cyberpunk = 'cyberpunk';
  static const String nature = 'nature';
  static const String sunset = 'sunset';
  static const String ocean = 'ocean';

  static List<Color> getBackgroundGradient(String themeId) {
    switch (themeId) {
      case cyberpunk:
        return const [Color(0xFF2B0030), Color(0xFF1A0B2E), Color(0xFF000000)];
      case nature:
        return const [Color(0xFF11998e), Color(0xFF38ef7d)];
      case sunset:
        return const [Color(0xFF0B1026), Color(0xFF2B193D), Color(0xFF5C2A48), Color(0xFFC75D4D)]; // Deep sunset
      case ocean:
         return const [Color(0xFF001F3F), Color(0xFF0066CC), Color(0xFF00A3E0)]; // Deep ocean
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
      case sunset:
        return const Color(0xFFFF7E5F); // Warm Coral
      case ocean:
        return const Color(0xFF00D2FF); // Ocean Blue
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
      case sunset:
         return const Color(0xFFFEB47B); // Peach
      case ocean:
        return const Color(0xFF00FFCC); // Cyan/Teal
      case defaultTheme:
      default:
        return Colors.amber;
    }
  }
}
