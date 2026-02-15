import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_sejahtera_ng/core/providers/theme_provider.dart';
import 'package:my_sejahtera_ng/core/screens/splash_screen.dart';
import 'package:my_sejahtera_ng/core/theme/app_theme.dart';
import 'package:my_sejahtera_ng/features/digital_health/services/notification_service.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart'; // Add this import

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // Load env file
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  await NotificationService().init();
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
      case 'sunset':
        themeData = AppTheme.sunsetTheme;
        break;
      case 'ocean':
        themeData = AppTheme.oceanTheme;
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
