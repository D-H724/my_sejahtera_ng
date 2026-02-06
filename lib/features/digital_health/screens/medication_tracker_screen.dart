import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:my_sejahtera_ng/core/widgets/glass_container.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:my_sejahtera_ng/features/digital_health/models/medication.dart';
import 'package:my_sejahtera_ng/features/digital_health/services/notification_service.dart';
import 'package:my_sejahtera_ng/features/digital_health/screens/widgets/add_medication_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_sejahtera_ng/core/providers/theme_provider.dart';
import 'package:my_sejahtera_ng/core/theme/app_themes.dart';

class MedicationTrackerScreen extends ConsumerStatefulWidget {
  const MedicationTrackerScreen({super.key});

  @override
  ConsumerState<MedicationTrackerScreen> createState() => _MedicationTrackerScreenState();
}

class _MedicationTrackerScreenState extends ConsumerState<MedicationTrackerScreen> {
  final List<Medication> _medications = [];
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _addMedication(Medication medication) async {
    final id = DateTime.now().millisecondsSinceEpoch;
    final newMedication = Medication(
      id: id,
      name: medication.name,
      dosage: medication.dosage,
      pillsToTake: medication.pillsToTake,
      time: medication.time,
      instructions: medication.instructions,
    );

    setState(() {
      _medications.add(newMedication);
    });

    await _notificationService.scheduleDailyNotification(
      id: id,
      title: 'Time to take ${newMedication.name}',
      body: 'Take ${newMedication.pillsToTake} pills. ${newMedication.instructions}',
      time: newMedication.time,
    );
  }

  void _toggleMedication(int index) {
      setState(() {
        final med = _medications[index];
        _medications[index] = med.copyWith(isTaken: !med.isTaken);
      });
  }

  @override
  Widget build(BuildContext context) {
    // Watch theme provider for changes
    final currentTheme = ref.watch(themeProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(""), // Title moved to body
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppThemes.getBackgroundGradient(currentTheme),
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
                // Show next dose logic
                Builder(
                  builder: (context) {
                    if (_medications.isEmpty) {
                       return const SizedBox(height: 100, child: Center(child: Text("No medications added yet", style: TextStyle(color: Colors.white))));
                    }
                    
                    // sorting done on add/toggle, or here cheaply
                    final sortedMeds = List<Medication>.from(_medications)..sort((a, b) => a.time.compareTo(b.time));
                    final nextMed = sortedMeds.cast<Medication?>().firstWhere(
                      (m) => !m!.isTaken && m.time.isAfter(DateTime.now().subtract(const Duration(minutes: 15))), // Allow slight buffer or show all future
                      orElse: () => null,
                    );
                    
                    // Fallback: just show the first untaken one even if "past" but not marked taken? 
                    // Or if all taken, show "All done"
                    final effectiveNextMed = nextMed ?? sortedMeds.cast<Medication?>().firstWhere((m) => !m!.isTaken, orElse: () => null);

                    if (effectiveNextMed != null) {
                       return _buildDosageCard(effectiveNextMed).animate().fadeIn().slideY();
                    } else {
                       return _buildAllCaughtUpCard().animate().fadeIn().slideY();
                    }
                  }
                ),

                const SizedBox(height: 24),
                Text("Your Meds", 
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Expanded(
                  child: _medications.isEmpty 
                  ? const Center(child: Text("Tap + to add medications", style: TextStyle(color: Colors.white70)))
                  : ListView.builder(
                    itemCount: _medications.length,
                    itemBuilder: (context, index) {
                      final med = _medications[index];
                      return _buildMedItem(med, index);
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
              builder: (context) => AddMedicationSheet(onSave: _addMedication),
            );
        },
        backgroundColor: Colors.white,
        child: const Icon(LucideIcons.plus, color: Colors.teal),
      ),
    );
  }

  Widget _buildAllCaughtUpCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 const Text("Daily Progress", style: TextStyle(color: Colors.white70)),
                 const SizedBox(height: 8),
                 const Text("All Caught Up!", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                 const SizedBox(height: 8),
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                   decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                   child: const Text("Great job keeping healthy!", style: TextStyle(color: Colors.white)),
                 )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.greenAccent.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: const Icon(LucideIcons.checkCircle, color: Colors.greenAccent, size: 40),
          )
        ],
      ),
    );
  }

  Widget _buildDosageCard(Medication medication) {
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

  Widget _buildMedItem(Medication med, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        color: med.isTaken ? Colors.green.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          leading: Icon(LucideIcons.tablets, color: med.isTaken ? Colors.white70 : Colors.white),
          title: Text(
              med.name, 
              style: TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.bold,
                  decoration: med.isTaken ? TextDecoration.lineThrough : null
              )
          ),
          subtitle: Text(
              "${med.dosage} • Take ${med.pillsToTake}", 
              style: const TextStyle(color: Colors.white70)
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
                Text(DateFormat.jm().format(med.time), style: const TextStyle(color: Colors.white)),
                const SizedBox(width: 8),
                IconButton(
                    icon: Icon(
                        med.isTaken ? Icons.check_circle : Icons.circle_outlined,
                        color: med.isTaken ? Colors.white : Colors.white70,
                    ),
                    onPressed: () => _toggleMedication(index),
                )
            ],
          ),
        ),
      ).animate().fadeIn().slideX(),
    );
  }
}
