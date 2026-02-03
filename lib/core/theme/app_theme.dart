import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors - NextGen Palette
  static const Color primaryBlue = Color(0xFF003B70); // Royal Blue
  static const Color primaryDark = Color(0xFF002347); // Darker Blue
  static const Color accentTeal = Color(0xFF00D4FF); // Neon Teal
  static const Color glassWhite = Color(0xCCFFFFFF);
  static const Color glassDark = Color(0xCC0F172A);
  
  static const Color bgLight = Color(0xFFF3F6FD);
  static const Color bgDark = Color(0xFF0B1120);

  // Cyberpunk Palette
  static const Color cpBg = Color(0xFF02001F);
  static const Color cpPrimary = Color(0xFFFF00CC); // Neon Pink
  static const Color cpAccent = Color(0xFF00FFEA); // Cyan
  
  // Nature Palette
  static const Color natBg = Color(0xFF1A2F1C);
  static const Color natPrimary = Color(0xFF8BC34A); // Light Green
  static const Color natAccent = Color(0xFF4CAF50); // Green

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bgLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: accentTeal,
        brightness: Brightness.light,
        surface: glassWhite,
      ),
      textTheme: GoogleFonts.outfitTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primaryBlue),
        titleTextStyle: TextStyle(color: primaryBlue, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bgDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: accentTeal,
        brightness: Brightness.dark,
        surface: glassDark,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentTeal,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  static ThemeData get cyberpunkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: cpBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: cpPrimary,
        primary: cpPrimary,
        secondary: cpAccent,
        brightness: Brightness.dark,
        surface: Colors.black.withOpacity(0.8),
      ),
      textTheme: GoogleFonts.orbitronTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: cpAccent),
        titleTextStyle: TextStyle(color: cpAccent, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cpPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), // Sharper corners
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          side: const BorderSide(color: cpAccent, width: 2), // Neon border
        ),
      ),
    );
  }

  static ThemeData get natureTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: natBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: natPrimary,
        primary: natPrimary,
        secondary: natAccent,
        brightness: Brightness.dark,
        surface: Colors.black.withOpacity(0.5),
      ),
      textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: natPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Softer corners
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}
