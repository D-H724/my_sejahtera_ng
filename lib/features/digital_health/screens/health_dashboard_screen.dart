import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_sejahtera_ng/core/widgets/glass_container.dart';
import 'package:google_fonts/google_fonts.dart';

// Import features and providers
import 'package:my_sejahtera_ng/features/food_tracker/food_tracker_screen.dart'; // Ensure this matches export
import 'package:my_sejahtera_ng/features/food_tracker/providers/food_tracker_provider.dart';
import 'package:my_sejahtera_ng/features/digital_health/providers/medication_provider.dart';
import 'package:my_sejahtera_ng/features/digital_health/providers/vitals_provider.dart';
import 'package:my_sejahtera_ng/features/digital_health/screens/medication_tracker_screen.dart';
import 'package:my_sejahtera_ng/features/digital_health/screens/health_vitals_screen.dart';
import 'package:my_sejahtera_ng/core/providers/user_provider.dart'; // Assuming this exists

class HealthDashboardScreen extends ConsumerWidget {
  const HealthDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vitals = ref.watch(vitalsProvider);
    final medicationState = ref.watch(medicationProvider);
    final foodState = ref.watch(foodTrackerProvider);
    final user = ref.watch(userProvider);
    
    // Calculate simple health score
    // Logic: Starts at 50. 
    // +15 if BMI Normal. 
    // +15 if hydrated (>3 water).
    // +20 if all meds taken.
    int healthScore = 50;
    if (vitals.bmiStatus == 'Normal') healthScore += 15;
    if (foodState.waterCount >= 3) healthScore += 15;
    
    final totalMeds = medicationState.medications.length;
    final takenMeds = medicationState.medications.where((m) => m.isTaken).length;
    if (totalMeds > 0 && takenMeds == totalMeds) healthScore += 20;
    if (totalMeds == 0) healthScore += 10; // Bonus for no meds? Or just neutral.

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("My Health Hub"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bellRing, color: Colors.white),
            onPressed: () {},
          ),
        ],
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
                // Header Section
                Text("Good Morning,", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16)),
                Text(user?.fullName ?? "User", style: GoogleFonts.outfit(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                // Health Score Card
                _buildHealthScoreCard(healthScore),

                const SizedBox(height: 30),
                Text("Your Trackers", style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),

                // Grid of Trackers
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.85,
                  children: [
                     _buildTrackerCard(
                       context, 
                       "Nutrition", 
                       "${foodState.totalCalories} / ${foodState.calorieTarget}", 
                       "kcal consumed",
                       LucideIcons.utensils, 
                       Colors.orangeAccent,
                       FoodTrackerScreen(),
                       progress: foodState.totalCalories / foodState.calorieTarget,
                     ),
                     _buildTrackerCard(
                       context, 
                       "Medication", 
                       totalMeds == 0 ? "No meds" : "$takenMeds / $totalMeds", 
                       "tablets taken",
                       LucideIcons.pill, 
                       Colors.greenAccent,
                       const MedicationTrackerScreen(),
                       progress: totalMeds == 0 ? 1.0 : takenMeds / totalMeds,
                     ),
                     _buildTrackerCard(
                       context, 
                       "Vitals (BMI)", 
                       vitals.bmi.toStringAsFixed(1), 
                       vitals.bmiStatus,
                       LucideIcons.activity, 
                       Colors.pinkAccent,
                       const HealthVitalsScreen(),
                       progress: vitals.bmiStatus == 'Normal' ? 1.0 : 0.6, // Visual indicator
                     ),
                     _buildTrackerCard(
                       context, 
                       "Hydration", 
                       "${foodState.waterCount}", 
                       "glasses",
                       LucideIcons.droplets, 
                       Colors.cyanAccent,
                       FoodTrackerScreen(), // Links to same food tracker but maybe specific tab?
                       progress: (foodState.waterCount / 8).clamp(0.0, 1.0),
                     ),
                  ],
                ),
                
                const SizedBox(height: 30),
                // Quick Action / Insight
                _buildInsightCard(vitals.bmiStatus, foodState.totalCalories > foodState.calorieTarget),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHealthScoreCard(int score) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Overall Health Score", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              Text("$score", style: GoogleFonts.outfit(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(score > 70 ? "Excellent" : "Needs Attention", style: const TextStyle(color: Colors.white)),
              )
            ],
          ),
          SizedBox(
            height: 80,
            width: 80,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 8,
              backgroundColor: Colors.white10,
              color: score > 70 ? Colors.greenAccent : Colors.orangeAccent,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY();
  }

  Widget _buildTrackerCard(BuildContext context, String title, String value, String sub, IconData icon, Color color, Widget destination, {double progress = 0.0}) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => destination)),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Icon(LucideIcons.arrowUpRight, color: Colors.white30, size: 16),
              ],
            ),
            const Spacer(),
            Text(title, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(sub, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white10,
              color: color,
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            )
          ],
        ),
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildInsightCard(String bmiStatus, bool overCalories) {
    String message = "You're doing great! Keep maintaining your healthy routine.";
    IconData icon = LucideIcons.thumbsUp;
    Color color = Colors.blueAccent;

    if (bmiStatus != 'Normal') {
      message = "Your BMI indicates you are $bmiStatus. Check the Vitals section for tips.";
      icon = LucideIcons.alertCircle;
      color = Colors.orangeAccent;
    } else if (overCalories) {
      message = "You've exceeded your calorie limit today. Try a light dinner.";
      icon = LucideIcons.utensils;
      color = Colors.redAccent;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 15),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.white, height: 1.4))),
        ],
      ),
    );
  }
}
