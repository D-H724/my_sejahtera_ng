import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_sejahtera_ng/core/providers/theme_provider.dart';
import 'package:my_sejahtera_ng/core/widgets/glass_container.dart';
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
        title: const Text('Rewards & Customization'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Level Header
                GlassContainer(
                  borderRadius: BorderRadius.circular(20),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          "${progress.level}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Current Level", style: TextStyle(color: Colors.white54)),
                          Text("Level ${progress.level}", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Spacer(),
                      // Debug/Cheat for demo purposes
                      IconButton(
                        onPressed: () {
                          ref.read(userProgressProvider.notifier).cheatLevelUp();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cheater! Level Up!")));
                        },
                        icon: const Icon(LucideIcons.zap, color: Colors.amber),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                
                const Text("App Themes", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildThemeCard(
                      context, 
                      ref,
                      id: 'default',
                      name: 'Standard Blue',
                      color: const Color(0xFF003B70),
                      isUnlocked: true,
                      isSelected: currentTheme == 'default',
                    ),
                    _buildThemeCard(
                      context, 
                      ref,
                      id: 'cyberpunk',
                      name: 'Cyberpunk Neon',
                      color: const Color(0xFFFF00CC),
                      isUnlocked: progress.unlockedThemes.contains('cyberpunk'),
                      isSelected: currentTheme == 'cyberpunk',
                      lockText: 'Unlock at Lvl 10',
                    ),
                    _buildThemeCard(
                      context, 
                      ref,
                      id: 'nature',
                      name: 'Calm Nature',
                      color: const Color(0xFF8BC34A),
                      isUnlocked: progress.unlockedThemes.contains('nature'),
                      isSelected: currentTheme == 'nature',
                      lockText: 'Unlock at Lvl 10',
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                const Text("ID Card Glows (Auto-Equipped)", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                GlassContainer(
                  borderRadius: BorderRadius.circular(16),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildUnlockRow("Regular Blue", 5, progress.level >= 5),
                      const Divider(color: Colors.white10),
                      _buildUnlockRow("Elite Cyan", 10, progress.level >= 10),
                      const Divider(color: Colors.white10),
                      _buildUnlockRow("Master Neon Pink", 15, progress.level >= 15),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context, WidgetRef ref, {
    required String id, 
    required String name, 
    required Color color, 
    required bool isUnlocked, 
    required bool isSelected,
    String? lockText
  }) {
    return GestureDetector(
      onTap: isUnlocked ? () {
        final progress = ref.read(userProgressProvider);
        ref.read(themeProvider.notifier).setTheme(id, progress);
      } : null,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : (isUnlocked ? Colors.white24 : Colors.white10),
            width: isSelected ? 2 : 1
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(height: 12),
                  Text(name, style: TextStyle(color: isUnlocked ? Colors.white : Colors.white38, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            if (isSelected)
              const Positioned(
                top: 8, right: 8,
                child: Icon(Icons.check_circle, color: Colors.white, size: 20),
              ),
            if (!isUnlocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.lock, color: Colors.white54),
                      const SizedBox(height: 4),
                      Text(lockText ?? "Locked", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildUnlockRow(String name, int levelReq, bool unlocked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            unlocked ? LucideIcons.checkCircle : LucideIcons.lock, 
            color: unlocked ? Colors.greenAccent : Colors.white24,
            size: 20
          ),
          const SizedBox(width: 12),
          Text(name, style: TextStyle(color: unlocked ? Colors.white : Colors.white54, fontSize: 16)),
          const Spacer(),
          Text("Lvl $levelReq", style: const TextStyle(color: Colors.white38, fontSize: 14)),
        ],
      ),
    );
  }
}
