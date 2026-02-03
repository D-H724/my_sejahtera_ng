import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_sejahtera_ng/core/widgets/glass_container.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LabResultsScreen extends StatelessWidget {
  const LabResultsScreen({super.key});

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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
               // Animated Title
               Center(
                 child: Text(
                   "Lab Results",
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
               const SizedBox(height: 24),

               _buildReportCard("Blood Test - Full Blood Count", "12 Jan 2024", true),
               _buildReportCard("Urine Analysis", "10 Dec 2023", true),
               _buildReportCard("X-Ray Report", "05 Nov 2023", false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(String title, String date, bool isNormal) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
             Icon(LucideIcons.fileText, color: Colors.white.withValues(alpha: 0.8), size: 30),
             const SizedBox(width: 16),
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                   const SizedBox(height: 4),
                   Text(date, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                 ],
               ),
             ),
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
               decoration: BoxDecoration(
                 color: isNormal ? Colors.green.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
                 borderRadius: BorderRadius.circular(8),
               ),
               child: Text(isNormal ? "Normal" : "Review", 
                  style: TextStyle(color: isNormal ? Colors.greenAccent : Colors.orangeAccent)),
             )
          ],
        ),
      ).animate().fadeIn().slideX(),
    );
  }
}
