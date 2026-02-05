import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_sejahtera_ng/core/widgets/glass_container.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:my_sejahtera_ng/features/digital_health/providers/medication_provider.dart';
import 'package:my_sejahtera_ng/features/digital_health/screens/widgets/add_medication_sheet.dart';

class MedicationTrackerScreen extends ConsumerWidget {
  const MedicationTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medications = ref.watch(medicationProvider);

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
            colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animated Title
                Center(
                  child: Text(
                    "Medication Tracker",
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
                // Show next dose logic if needed, for now keeping static or first item
                if (medications.isNotEmpty)
                  _buildDosageCard(medications.first).animate().fadeIn().slideY()
                else
                   const SizedBox(height: 100, child: Center(child: Text("No medications added yet", style: TextStyle(color: Colors.white)))),

                const SizedBox(height: 24),
                Text("Your Meds", 
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Expanded(
                  child: medications.isEmpty 
                  ? const Center(child: Text("Tap + to add medications", style: TextStyle(color: Colors.white70)))
                  : ListView.builder(
                    itemCount: medications.length,
                    itemBuilder: (context, index) {
                      final med = medications[index];
                      return _buildMedItem(med.name, "${med.dosage} • Take ${med.pillsToTake}", DateFormat.jm().format(med.time));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const AddMedicationSheet(),
            );
        },
        backgroundColor: Colors.white,
        child: const Icon(LucideIcons.plus, color: Colors.teal),
      ),
    );
  }

  Widget _buildDosageCard(dynamic medication) {
    // using dynamic to avoid import issues if type not fully resolved yet, but should be Medication
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 const Text("Next Dose", style: TextStyle(color: Colors.white70)),
                 const SizedBox(height: 8),
                 Text(DateFormat.jm().format(medication.time), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                 const SizedBox(height: 8),
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                   decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                   child: Text("${medication.name} (${medication.dosage})", style: const TextStyle(color: Colors.white)),
                 )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: const Icon(LucideIcons.pill, color: Colors.white, size: 40),
          )
        ],
      ),
    ); 
  }

  Widget _buildMedItem(String name, String dosage, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        color: Colors.black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          leading: const Icon(LucideIcons.tablets, color: Colors.white),
          title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(dosage, style: const TextStyle(color: Colors.white70)),
          trailing: Text(time, style: const TextStyle(color: Colors.white)),
        ),
      ).animate().fadeIn().slideX(),
    );
  }
}
