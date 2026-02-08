import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_sejahtera_ng/core/widgets/glass_container.dart';
import 'package:my_sejahtera_ng/core/widgets/bouncing_button.dart';
import 'package:my_sejahtera_ng/features/food_tracker/providers/food_tracker_provider.dart';
import 'package:my_sejahtera_ng/features/food_tracker/food_tracker_screen.dart';

class CalorieInsightCard extends ConsumerWidget {
  const CalorieInsightCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(foodTrackerProvider);
    final progress = (state.totalCalories / state.calorieTarget).clamp(0.0, 1.0);
    final remaining = state.calorieTarget - state.totalCalories;
    final isOver = remaining < 0;

    return BouncingButton(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FoodTrackerScreen()),
        );
      },
      child: GlassContainer(
        borderRadius: BorderRadius.circular(25),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Circular Progress
            SizedBox(
              height: 70,
              width: 70,
              child: Stack(
                children: [
                  Center(
                    child: SizedBox(
                      height: 70,
                      width: 70,
                      child: CircularProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white10,
                        color: isOver ? Colors.redAccent : const Color(0xFF00C9E8),
                        strokeWidth: 6,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(
                      LucideIcons.apple,
                      color: isOver ? Colors.redAccent : const Color(0xFF00C9E8),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Calorie Intake",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        "${state.totalCalories}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        " / ${state.calorieTarget} kcal",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // AI Insight Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isOver ? Colors.redAccent : const Color(0xFF00C9E8)).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (isOver ? Colors.redAccent : const Color(0xFF00C9E8)).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.sparkles,
                          size: 10,
                          color: isOver ? Colors.redAccent : const Color(0xFF00C9E8),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            state.currentInsight,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isOver ? Colors.redAccent : const Color(0xFF00C9E8),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Chevron
            Icon(
              LucideIcons.chevronRight,
              color: Colors.white.withValues(alpha: 0.3),
              size: 20,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }
}
