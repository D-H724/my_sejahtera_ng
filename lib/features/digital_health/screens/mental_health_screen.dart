import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_sejahtera_ng/core/widgets/glass_container.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:my_sejahtera_ng/features/gamification/providers/user_progress_provider.dart';

class MentalHealthScreen extends ConsumerStatefulWidget {
  const MentalHealthScreen({super.key});

  @override
  ConsumerState<MentalHealthScreen> createState() => _MentalHealthScreenState();
}

class _MentalHealthScreenState extends ConsumerState<MentalHealthScreen> {
  int _selectedMood = 2; // 0-4

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(""), // Title moved to body
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF00b09b), Color(0xFF96c93d)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animated Title
                Center(
                  child: Text(
                    "Mental Wellness",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      shadows: [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ).animate()
                 .scale(duration: 600.ms, curve: Curves.elasticOut)
                 .fadeIn(duration: 400.ms),
                const SizedBox(height: 20),
                const Text("How are you feeling today?", 
                   style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                GlassContainer(
                   borderRadius: BorderRadius.circular(20),
                   padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: List.generate(5, (index) {
                       return GestureDetector(
                         onTap: () {
                           setState(() => _selectedMood = index);
                           ref.read(userProgressProvider.notifier).completeQuest('mood');
                         },
                         child: AnimatedContainer(
                           duration: 300.ms,
                           padding: const EdgeInsets.all(10),
                           decoration: BoxDecoration(
                             color: _selectedMood == index ? Colors.white.withValues(alpha: 0.3) : Colors.transparent,
                             shape: BoxShape.circle,
                           ),
                           child: Icon(
                             _getMoodIcon(index), 
                             color: Colors.white, 
                             size: _selectedMood == index ? 40 : 30
                           ),
                         ),
                       );
                     }),
                   ),
                ).animate().fadeIn().scale(),
                const SizedBox(height: 30),
                const Text("Resources for you", 
                   style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildResourceCard("Meditation Guide", "10 mins • Calm & Focus", LucideIcons.headphones),
                _buildResourceCard("Breathing Exercise", "5 mins • Relax", LucideIcons.wind),
                _buildResourceCard("Talk to a Counselor", "Available now", LucideIcons.phone),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getMoodIcon(int index) {
    switch (index) {
      case 0: return LucideIcons.frown;
      case 1: return LucideIcons.meh;
      case 2: return LucideIcons.smile;
      case 3: return LucideIcons.laugh;
      case 4: return LucideIcons.partyPopper;
      default: return LucideIcons.smile;
    }
  }

  Widget _buildResourceCard(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.white70)),
              ],
            )
          ],
        ),
      ).animate().fadeIn().slideX(),
    );
  }
}
