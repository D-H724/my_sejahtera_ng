import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_sejahtera_ng/core/providers/user_provider.dart';
import 'package:my_sejahtera_ng/core/theme/app_themes.dart';
import 'package:my_sejahtera_ng/core/providers/theme_provider.dart';

class HealthInsightBanner extends ConsumerStatefulWidget {
  const HealthInsightBanner({super.key});

  @override
  ConsumerState<HealthInsightBanner> createState() => _HealthInsightBannerState();
}

class _HealthInsightBannerState extends ConsumerState<HealthInsightBanner> with SingleTickerProviderStateMixin {
  int _currentTipIndex = 0;
  late Timer _timer;
  late AnimationController _borderController;

  final List<String> _healthTips = [
    "Stay hydrated! Drink at least 8 glasses of water today.",
    "Take a 5-minute stretch break every hour.",
    "Sanitize your hands frequently in public spaces.",
    "A good laugh boosts your immune system!",
    "Get at least 7 hours of sleep for better focus.",
    "Eat more fruits and vegetables for a natural energy boost."
  ];

  @override
  void initState() {
    super.initState();
    _startTipRotation();
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  void _startTipRotation() {
    _timer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (mounted) {
        setState(() {
          _currentTipIndex = (_currentTipIndex + 1) % _healthTips.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _borderController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return "Good Morning";
    if (hour >= 12 && hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final currentTheme = ref.watch(themeProvider);
    final themeColor = AppThemes.getPrimaryColor(currentTheme);

    return AnimatedBuilder(
      animation: _borderController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(2), // Space for border
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                themeColor.withOpacity(0.1),
                themeColor.withOpacity(0.8), // Glowing animated part
                themeColor.withOpacity(0.1),
              ],
              stops: [
                0.0,
                (_borderController.value),
                1.0
              ],
              transform: const GradientRotation(0.5), // Tilt slightly
            ),
            boxShadow: [
              BoxShadow(
                color: themeColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6), // Inner dark background
              borderRadius: BorderRadius.circular(22),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                children: [
                  // Subtle background texture
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.1,
                      child: Image.asset(
                        'assets/images/banner.png', 
                        fit: BoxFit.cover,
                        errorBuilder: (_,__,___) => Container(), // Fallback silently
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Greeting
                              Row(
                                children: [
                                  Icon(LucideIcons.sun, color: Colors.amberAccent, size: 18)
                                      .animate(onPlay: (c) => c.repeat())
                                      .rotate(duration: 10.seconds),
                                  const SizedBox(width: 8),
                                  Text(
                                    "${_getGreeting()}, ${user?.fullName.split(' ').first ?? 'Friend'}",
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              // Check streak (micro-interaction)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                                ),
                                child: Text(
                                  "All Systems Normal",
                                  style: GoogleFonts.shareTechMono(color: Colors.greenAccent, fontSize: 10),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Rotating Tip
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                transitionBuilder: (Widget child, Animation<double> animation) {
                                  return FadeTransition(opacity: animation, child: SlideTransition(
                                    position: Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(animation),
                                    child: child,
                                  ));
                                },
                                child: Text(
                                  _healthTips[_currentTipIndex],
                                  key: ValueKey<int>(_currentTipIndex),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    height: 1.4,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Floating Icon
                        const SizedBox(width: 15),
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.blueAccent.withOpacity(0.2), Colors.purpleAccent.withOpacity(0.2)],
                            ),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Icon(LucideIcons.heartPulse, color: Colors.redAccent, size: 32),
                        ).animate(onPlay: (c) => c.repeat(reverse: true))
                         .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1.seconds)
                         .moveY(begin: 0, end: -5, duration: 2.seconds),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
