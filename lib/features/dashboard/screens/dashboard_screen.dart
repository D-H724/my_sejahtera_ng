import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_sejahtera_ng/core/widgets/feature_detail_screen.dart';
import 'package:my_sejahtera_ng/core/widgets/glass_container.dart';
import 'package:my_sejahtera_ng/core/widgets/holo_id_card.dart';
import 'package:my_sejahtera_ng/core/widgets/quest_board.dart';
import 'package:my_sejahtera_ng/core/widgets/bouncing_button.dart';
import 'package:my_sejahtera_ng/features/check_in/screens/check_in_screen.dart';
import 'package:my_sejahtera_ng/features/health_assistant/screens/ai_chat_screen.dart';
import 'package:my_sejahtera_ng/features/hotspots/screens/hotspot_screen.dart';
import 'package:my_sejahtera_ng/features/profile/screens/account_screen.dart';
import 'package:my_sejahtera_ng/features/vaccine/screens/vaccine_screen.dart';
import 'package:my_sejahtera_ng/features/digital_health/screens/health_dashboard_screen.dart';
import 'package:my_sejahtera_ng/features/food_tracker/food_tracker_screen.dart';
import 'package:my_sejahtera_ng/features/dashboard/widgets/health_insight_banner.dart';
import 'package:my_sejahtera_ng/features/dashboard/widgets/calorie_insight_card.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_sejahtera_ng/features/gamification/providers/quest_provider.dart';
import 'package:my_sejahtera_ng/core/providers/theme_provider.dart';
import 'package:my_sejahtera_ng/core/theme/app_themes.dart';
import 'package:my_sejahtera_ng/core/widgets/raining_icons.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Animated Background with Dynamic Theme
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppThemes.getBackgroundGradient(currentTheme),
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .saturate(duration: 5.seconds, begin: 1.0, end: 1.2),

          // Raining Icons Effect (Moved from Rewards)
          const RainingIcons(child: SizedBox.expand()),

          // Content
          SafeArea(
            bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                floating: true,
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(LucideIcons.shieldCheck, color: Colors.blueAccent),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        "MySejahtera NG",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              fontSize: 20, // Slightly reduced for safety on small screens
                            ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  _buildIconButton(LucideIcons.bell, () {}),
                  const SizedBox(width: 8),
                  _buildIconButton(LucideIcons.user, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AccountScreen()),
                    );
                  }),
                  const SizedBox(width: 16),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Risk Status",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.bold,
                            ),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 12),

                      // NEW: Holographic ID Card
                      const HoloIdCard().animate().fadeIn(delay: 300.ms).slideX(),

                      const SizedBox(height: 24),
                      
                      // Weekly Health Score
                      const HealthInsightBanner().animate().fadeIn().slideY(begin: 0.1, end: 0, duration: 600.ms),
                      
                      const SizedBox(height: 24),
                      
                      // NEW: Calorie Tracker Widget
                      const CalorieInsightCard(),

                      const SizedBox(height: 24),
                      Text(
                        "Services",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.bold,
                            ),
                      ).animate().fadeIn(delay: 400.ms),
                      const SizedBox(height: 12),
                      _buildGridMenu(context, ref).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 24),

                      // NEW: Gamified Quests
                      const QuestBoard().animate().fadeIn(delay: 600.ms),

                      const SizedBox(height: 100), // Spacing for FAB
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
      floatingActionButton: BouncingButton(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AIChatScreen()),
          ).then((_) {
             ref.read(questProvider.notifier).completeQuestByAction('nav_ai');
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
             color: const Color(0xFF00C9E8),
             borderRadius: BorderRadius.circular(30),
             // BoxShadow is now handled by the animation
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(LucideIcons.bot, color: Colors.white),
              SizedBox(width: 8),
              Text("Ask AI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true))
       .scale(begin: const Offset(1,1), end: const Offset(1.05, 1.05), duration: 1200.ms)
       .boxShadow(
          begin: BoxShadow(color: const Color(0xFF00C9E8).withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 2),
          end: BoxShadow(color: const Color(0xFF00C9E8).withValues(alpha: 0.8), blurRadius: 20, spreadRadius: 6),
          duration: 1200.ms
       ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return BouncingButton(
      onTap: onPressed,
      child: GlassContainer(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(12),
        child: Container(
           padding: const EdgeInsets.all(8),
           child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }


  // _buildStatusCard removed (replaced by HoloIdCard)

  Widget _buildGridMenu(BuildContext context, WidgetRef ref) {
    final items = [
      {
        'icon': LucideIcons.qrCode,
        'label': 'Check-In',
      },
      {
        'icon': LucideIcons.syringe,
        'label': 'Vaccine',
      },
      {
        'icon': LucideIcons.mapPin,
        'label': 'Hotspots',
      },
      {
        'icon': LucideIcons.stethoscope,
        'label': 'Health',
      },
      {
        'icon': LucideIcons.apple,
        'label': 'Food Intake Monitor',
      },
    ];

    final currentTheme = ref.watch(themeProvider);
    final themeColor = AppThemes.getPrimaryColor(currentTheme);
    final accentColor = AppThemes.getAccentColor(currentTheme);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return BouncingButton(
          onTap: () {
            Widget targetScreen;
            final label = item['label'] as String;
            String? questActionId;

            if (label == 'Check-In') {
              targetScreen = const CheckInScreen();
              // questActionId = 'nav_checkin'; // If we had a quest for this
            } else if (label == 'Vaccine') {
              targetScreen = const VaccineScreen();
              questActionId = 'nav_vaccine';
            } else if (label == 'Hotspots') {
              targetScreen = const HotspotScreen();
              questActionId = 'nav_hotspots';
            } else if (label == 'Health') {
              targetScreen = const HealthDashboardScreen();
            } else if (label == 'Food Intake Monitor') {
              targetScreen = FoodTrackerScreen();
            } else {
              targetScreen = FeatureDetailScreen(
                title: label,
                icon: item['icon'] as IconData,
                description: 'Access your $label records.',
              );
            }

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => targetScreen),
            ).then((_) {
              if (questActionId != null) {
                ref.read(questProvider.notifier).completeQuestByAction(questActionId);
              }
            });
          },
          child: Stack(
            children: [
              // 1. Glowing Gradient Background with Frame
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      themeColor.withValues(alpha: 0.25),
                      themeColor.withValues(alpha: 0.1),
                    ],
                  ),
                  border: Border.all(
                    color: themeColor.withValues(alpha: 0.8), // Prominent Frame
                    width: 2.0,
                  ),
                  boxShadow: [
                    // Outer Glow
                    BoxShadow(
                      color: themeColor.withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 1,
                    ),
                    // Inner depth shadow
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),

              // 3. Content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon Container
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: themeColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                        boxShadow: [
                           BoxShadow(
                             color: themeColor.withValues(alpha: 0.3),
                             blurRadius: 12,
                             spreadRadius: 2,
                           )
                        ]
                      ),
                      child: Icon(item['icon'] as IconData,
                          color: Colors.white, size: 28), // White icon for clean contrast
                    ),
                    const SizedBox(height: 14),

                    // Label
                    Text(
                      item['label'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2))
                          ]
                        ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
