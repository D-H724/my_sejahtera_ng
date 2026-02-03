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
import 'package:my_sejahtera_ng/features/digital_health/screens/digital_health_screen.dart';
import 'package:my_sejahtera_ng/features/food_tracker/food_tracker_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_sejahtera_ng/features/gamification/providers/quest_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Animated Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .shimmer(duration: 3.seconds, color: Colors.white.withValues(alpha: 0.1), angle: 45)
           .saturate(duration: 5.seconds, begin: 1.0, end: 1.2),

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
                    Text(
                      "MySejahtera NG",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
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
                      _buildWelcomeBanner().animate().fadeIn().slideY(begin: 0.1, end: 0, duration: 600.ms),
                      const SizedBox(height: 24),

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

  Widget _buildWelcomeBanner() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: AssetImage('assets/images/banner.png'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.7),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Stay Safe, Stay Protected",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Your comprehensive health companion",
              style: TextStyle( color: Colors.white70),
            ),
          ],
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
        'color': Colors.blueAccent,
      },
      {
        'icon': LucideIcons.syringe,
        'label': 'Vaccine',
        'color': Colors.purpleAccent,
      },
      {
        'icon': LucideIcons.mapPin,
        'label': 'Hotspots',
        'color': Colors.redAccent,
      },
      {
        'icon': LucideIcons.stethoscope,
        'label': 'Health',
        'color': Colors.tealAccent,
      },
      {
        'icon': LucideIcons.apple,
        'label': 'Food Intake Monitor',
        'color': Colors.lightGreenAccent,
      },
    ];

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
              targetScreen = const DigitalHealthScreen();
            } else if (label == 'Food Intake Monitor') {
              targetScreen = const FoodTrackerScreen();
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
              // 1. Glowing Gradient Background
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (item['color'] as Color).withValues(alpha: 0.2),
                      (item['color'] as Color).withValues(alpha: 0.05),
                    ],
                  ),
                  border: Border.all(
                    color: (item['color'] as Color).withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    // Outer Glow
                    BoxShadow(
                      color: (item['color'] as Color).withValues(alpha: 0.25),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                    // Inner depth shadow
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
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
                        color: (item['color'] as Color).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: (item['color'] as Color).withValues(alpha: 0.5),
                          width: 1,
                        ),
                        boxShadow: [
                           BoxShadow(
                             color: (item['color'] as Color).withValues(alpha: 0.2),
                             blurRadius: 10,
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
                          letterSpacing: 0.5),
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
