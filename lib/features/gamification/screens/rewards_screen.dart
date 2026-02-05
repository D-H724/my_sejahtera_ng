import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:my_sejahtera_ng/core/providers/theme_provider.dart';
import 'package:my_sejahtera_ng/core/theme/app_themes.dart';
import 'package:my_sejahtera_ng/core/widgets/glass_container.dart';
import 'package:my_sejahtera_ng/core/widgets/raining_icons.dart';
import 'package:my_sejahtera_ng/features/gamification/providers/user_progress_provider.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider);
    final currentTheme = ref.watch(themeProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Rewards & Style'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: [
           IconButton(
            onPressed: () {
              ref.read(userProgressProvider.notifier).cheatLevelUp();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cheater! Level Up!")));
            },
            icon: const Icon(LucideIcons.zap, color: Colors.amber),
          ).animate().shimmer(delay: 5.seconds, duration: 2.seconds)
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppThemes.getBackgroundGradient(currentTheme),
          ),
        ),
        child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Level Header
                _buildLevelCard(progress).animate().fadeIn().slideY(),
                const SizedBox(height: 30),
                
                Row(
                  children: [
                    const Icon(LucideIcons.palette, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text("Themes", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 16),
                
                SizedBox(
                  height: 220,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    children: [
                      _buildThemeCard(
                        context, 
                        ref,
                        id: 'default',
                        name: 'Standard Blue',
                        color: const Color(0xFF003B70),
                        icon: LucideIcons.smartphone,
                        isUnlocked: true,
                        isSelected: currentTheme == 'default',
                      ),
                      const SizedBox(width: 16),
                      _buildThemeCard(
                        context, 
                        ref,
                        id: 'cyberpunk',
                        name: 'Cyberpunk Neon',
                        color: const Color(0xFFFF00CC),
                        icon: LucideIcons.zap,
                        isUnlocked: progress.unlockedThemes.contains('cyberpunk'),
                        isSelected: currentTheme == 'cyberpunk',
                        lockText: 'Lvl 10',
                      ),
                      const SizedBox(width: 16),
                      _buildThemeCard(
                        context, 
                        ref,
                        id: 'nature',
                        name: 'Calm Nature',
                        color: const Color(0xFF8BC34A),
                        icon: LucideIcons.leaf,
                        isUnlocked: progress.unlockedThemes.contains('nature'),
                        isSelected: currentTheme == 'nature',
                        lockText: 'Lvl 10',
                      ),
                      const SizedBox(width: 16),
                      _buildThemeCard(
                        context, 
                        ref,
                        id: 'sunset',
                        name: 'Sunset Vibes',
                        color: const Color(0xFFFF7E5F),
                        icon: LucideIcons.sunset,
                        isUnlocked: progress.unlockedThemes.contains('sunset'),
                        isSelected: currentTheme == 'sunset',
                        lockText: 'Lvl 15',
                      ),
                      const SizedBox(width: 16),
                       _buildThemeCard(
                        context, 
                        ref,
                        id: 'ocean',
                        name: 'Deep Ocean',
                        color: const Color(0xFF00D2FF),
                        icon: LucideIcons.waves,
                        isUnlocked: progress.unlockedThemes.contains('ocean'),
                        isSelected: currentTheme == 'ocean',
                        lockText: 'Lvl 20',
                      ),
                    ].animate(interval: 100.ms).fadeIn().slideX(),
                  ),
                ),
                
                const SizedBox(height: 30),
                Row(
                  children: [
                    const Icon(LucideIcons.sparkles, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text("ID Effects", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 16),
                
                GlassContainer(
                  borderRadius: BorderRadius.circular(24),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildUnlockRow("Regular Blue", 5, progress.level >= 5, Colors.blue),
                      const Divider(color: Colors.white10),
                      _buildUnlockRow("Elite Cyan", 10, progress.level >= 10, Colors.cyan),
                      const Divider(color: Colors.white10),
                      _buildUnlockRow("Master Neon Pink", 15, progress.level >= 15, Colors.pinkAccent),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(dynamic progress) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("CURRENT LEVEL", style: TextStyle(color: Colors.white70, letterSpacing: 1.5, fontSize: 12, fontWeight: FontWeight.bold)),
                 const SizedBox(height: 4),
                 Text("${progress.level}", style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900, height: 1.0)),
                 const SizedBox(height: 4),
                 const Text("Keep engaging to level up!", style: TextStyle(color: Colors.white, fontSize: 14)),
                 const SizedBox(height: 12),
                 ClipRRect(
                   borderRadius: BorderRadius.circular(10),
                   child: LinearProgressIndicator(
                     value: 0.7, // Mock progress for visual appeal
                     backgroundColor: Colors.black26,
                     valueColor: const AlwaysStoppedAnimation(Colors.amber),
                     minHeight: 8,
                   ),
                 ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white30, width: 2)
            ),
            child: const Icon(LucideIcons.trophy, color: Colors.amber, size: 40),
          ).animate().shimmer(delay: 2.seconds, duration: 1500.ms),
        ],
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context, WidgetRef ref, {
    required String id, 
    required String name, 
    required Color color,
    required IconData icon,
    required bool isUnlocked, 
    required bool isSelected,
    String? lockText
  }) {
    return GestureDetector(
      onTap: isUnlocked ? () {
        final progress = ref.read(userProgressProvider);
        ref.read(themeProvider.notifier).setTheme(id, progress);
      } : null,
      child: AnimatedContainer(
        duration: 300.ms,
        width: 160,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.3) : Colors.black26,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? color : (isUnlocked ? Colors.white10 : Colors.transparent),
            width: isSelected ? 2 : 1
          ),
          boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 15)] : [],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Container(
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(
                       color: color.withOpacity(0.2),
                       shape: BoxShape.circle,
                     ),
                     child: Icon(icon, color: color, size: 32),
                   ),
                   const SizedBox(height: 16),
                   Text(name, 
                     textAlign: TextAlign.center,
                     style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                   ),
                   const SizedBox(height: 8),
                   if (isSelected)
                      const Chip(label: Text("Active", style: TextStyle(fontSize: 10)), backgroundColor: Colors.green, padding: EdgeInsets.zero, visualDensity: VisualDensity.compact)
                ],
              ),
            ),
            if (!isUnlocked)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.lock, color: Colors.white54, size: 32),
                      const SizedBox(height: 8),
                      Text("Unlock $lockText", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnlockRow(String name, int levelReq, bool unlocked, Color glowColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: unlocked ? glowColor.withOpacity(0.2) : Colors.white10,
              shape: BoxShape.circle,
              boxShadow: unlocked ? [BoxShadow(color: glowColor.withOpacity(0.4), blurRadius: 10)] : []
            ),
            child: Icon(
              unlocked ? LucideIcons.check : LucideIcons.lock, 
              color: unlocked ? glowColor : Colors.white24,
              size: 18
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(color: unlocked ? Colors.white : Colors.white54, fontSize: 16, fontWeight: FontWeight.bold)),
                Text(unlocked ? "Equipped Automatically" : "Reach Level $levelReq to unlock", 
                  style: TextStyle(color: unlocked ? Colors.white54 : Colors.white24, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
