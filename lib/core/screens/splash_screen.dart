import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_sejahtera_ng/features/auth/screens/login_screen.dart';
import 'package:my_sejahtera_ng/features/dashboard/screens/dashboard_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to Dashboard or Login after animation
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
         final session = Supabase.instance.client.auth.currentSession;
         final Widget nextScreen = session != null ? const DashboardScreen() : const LoginScreen();

         Navigator.of(context).pushReplacement(
           PageRouteBuilder(
             pageBuilder: (_, __, ___) => nextScreen,
             transitionsBuilder: (_, animation, __, child) {
               return FadeTransition(opacity: animation, child: child);
             },
             transitionDuration: const Duration(milliseconds: 800),
           ),
         );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Cinematic Dark
      body: Stack(
        children: [
          // 1. Dynamic Background Gradient (Subtle pulse)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .scale(begin: const Offset(1,1), end: const Offset(1.1, 1.1), duration: 5.seconds),
           
          // 2. Center Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Animation
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.2),
                        blurRadius: 30,
                        spreadRadius: 10,
                      )
                    ]
                  ),
                  child: const Icon(LucideIcons.shieldCheck, color: Colors.blueAccent, size: 64),
                ).animate()
                 .scale(duration: 1200.ms, curve: Curves.easeOutBack, begin: const Offset(0,0), end: const Offset(1,1))
                 .shimmer(delay: 1200.ms, duration: 1500.ms, color: Colors.white)
                 .then() // After 1200ms
                 .boxShadow(begin: BoxShadow(color: Colors.blueAccent.withOpacity(0)), end: BoxShadow(color: Colors.blueAccent.withOpacity(0.5), blurRadius: 50, spreadRadius: 20), duration: 1000.ms),

                const SizedBox(height: 30),

                // Text Animation "MySejahtera"
                Text(
                  "MySejahtera",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ).animate()
                 .fadeIn(duration: 800.ms, delay: 500.ms)
                 .blur(begin: const Offset(10,10), end: const Offset(0,0), duration: 800.ms) // Cool cinematic blur-in
                 .scale(begin: const Offset(0.8, 0.8), end: const Offset(1,1), duration: 800.ms),
                 
                 // Text Animation "NextGen"
                 Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Text(
                       "Next",
                       style: GoogleFonts.outfit(
                         color: Colors.white70,
                         fontSize: 20,
                         fontWeight: FontWeight.w300,
                         letterSpacing: 4,
                       ),
                     ),
                     Text(
                       "Gen",
                       style: GoogleFonts.outfit(
                         color: Colors.blueAccent,
                         fontSize: 20,
                         fontWeight: FontWeight.bold,
                         letterSpacing: 4,
                       ),
                     ),
                   ],
                 ).animate()
                  .fadeIn(delay: 1000.ms, duration: 800.ms)
                  .slideY(begin: 0.5, end: 0, duration: 800.ms, curve: Curves.easeOutCubic)
              ],
            ),
          ),
          
          // 3. Bottom Loading Indicator (Futuristic)
          Positioned(
            bottom: 60,
            left: 0, right: 0,
            child: Center(
              child: SizedBox(
                width: 40, height: 40,
                child: const CircularProgressIndicator(
                  color: Colors.blueAccent,
                  strokeWidth: 2,
                ),
              ),
            ),
          ).animate().fadeIn(delay: 1500.ms),
        ],
      ),
    );
  }
}
