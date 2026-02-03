import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_sejahtera_ng/core/providers/theme_provider.dart';
import 'package:my_sejahtera_ng/core/screens/splash_screen.dart';
import 'package:my_sejahtera_ng/core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeId = ref.watch(themeProvider);
    
    ThemeData themeData;
    switch (currentThemeId) {
      case 'cyberpunk':
        themeData = AppTheme.cyberpunkTheme;
        break;
      case 'nature':
        themeData = AppTheme.natureTheme;
        break;
      default:
        themeData = AppTheme.lightTheme;
    }

    return MaterialApp(
      title: 'MySejahtera NextGen',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      // Temporarily disable darkTheme switch for custom themes to force the selected one
      // In a real app we might handle light/dark for each theme
      themeMode: ThemeMode.light, 
      home: const SplashScreen(),
    );
  }
}
