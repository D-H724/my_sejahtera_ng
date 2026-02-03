import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_sejahtera_ng/core/widgets/glass_container.dart';
import 'package:my_sejahtera_ng/features/digital_health/screens/health_vitals_screen.dart';
import 'package:my_sejahtera_ng/features/digital_health/screens/appointments_screen.dart';
import 'package:my_sejahtera_ng/features/digital_health/screens/medication_tracker_screen.dart';
import 'package:my_sejahtera_ng/features/digital_health/screens/lab_results_screen.dart';
import 'package:my_sejahtera_ng/features/digital_health/screens/mental_health_screen.dart';


class DigitalHealthScreen extends StatelessWidget {
  const DigitalHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(""), // Moved to body
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF004e92), Color(0xFF000428)], // Deep Blue theme
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
                    "Digital Health",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          shadows: [
                            BoxShadow(color: Colors.blueAccent.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 5),
                          ]
                        ),
                  ),
                ).animate()
                 .custom(
                   duration: 800.ms,
                   builder: (context, value, child) => Transform.scale(scale: value, child: child),
                   begin: 0.5, end: 1.0,
                   curve: Curves.elasticOut,
                 )
                 .fadeIn(duration: 500.ms)
                 .shimmer(delay: 1000.ms, duration: 2000.ms, color: Colors.white),

                const SizedBox(height: 30),

                _buildHealthSummaryCard().animate().fadeIn().slideY(begin: 0.1, end: 0, delay: 200.ms),
                const SizedBox(height: 24),
                Text(
                  "Manage Your Health",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _buildMenuGrid(context).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHealthSummaryCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: Colors.pinkAccent.withValues(alpha: 0.2),
                   shape: BoxShape.circle,
                 ),
                 child: const Icon(LucideIcons.heartPulse, color: Colors.pinkAccent, size: 30),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Today's Vitals", style: TextStyle(color: Colors.white70)),
                  Text("Normal",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildVitalItem(LucideIcons.activity, "74 bpm", "Heart Rate"),
              _buildVitalItem(LucideIcons.droplets, "120/80", "Blood Pressure"),
              _buildVitalItem(LucideIcons.scale, "65 kg", "Weight"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVitalItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    final items = [
      {
        'title': 'Vitals',
        'icon': LucideIcons.activity,
        'color': Colors.orangeAccent,
        'screen': const HealthVitalsScreen(),
        'desc': 'Track BMI, BP & Heart Rate'
      },
      {
        'title': 'Appointments',
        'icon': LucideIcons.calendarClock,
        'color': Colors.blueAccent,
        'screen': const AppointmentsScreen(),
        'desc': 'Book & manage visits'
      },
      {
        'title': 'Medications',
        'icon': LucideIcons.pill,
        'color': Colors.greenAccent,
        'screen': const MedicationTrackerScreen(),
        'desc': 'Reminders & Refills'
      },
      {
        'title': 'Lab Results',
        'icon': LucideIcons.fileText,
        'color': Colors.purpleAccent,
        'screen': const LabResultsScreen(),
        'desc': 'View medical reports'
      },
      {
        'title': 'Mental Health',
        'icon': LucideIcons.smile,
        'color': Colors.tealAccent,
        'screen': const MentalHealthScreen(),
        'desc': 'Mood & Assessment'
      },
    ];

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return GlassContainer(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withValues(alpha: 0.05),
          padding: EdgeInsets.zero,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (item['color'] as Color).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item['icon'] as IconData, color: item['color'] as Color),
            ),
            title: Text(item['title'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(item['desc'] as String, style: const TextStyle(color: Colors.white54)),
            trailing: const Icon(LucideIcons.chevronRight, color: Colors.white54),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => item['screen'] as Widget));
            },
          ),
        );
      },
    );
  }
}
