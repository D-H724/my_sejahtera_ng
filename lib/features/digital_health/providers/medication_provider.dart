
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_sejahtera_ng/features/digital_health/models/medication.dart';
import 'package:my_sejahtera_ng/features/digital_health/services/notification_service.dart';

final notificationServiceProvider = Provider((ref) => NotificationService());

final medicationProvider =
    StateNotifierProvider<MedicationNotifier, List<Medication>>((ref) {
  return MedicationNotifier(ref.read(notificationServiceProvider));
});

class MedicationNotifier extends StateNotifier<List<Medication>> {
  final NotificationService _notificationService;

  MedicationNotifier(this._notificationService) : super([]) {
    // In-memory initialization, no DB load
    _notificationService.init();
  }

  Future<void> addMedication(Medication medication) async {
    // Simulate ID generation
    final id = DateTime.now().millisecondsSinceEpoch; 
    final newMedication = Medication(
      id: id,
      name: medication.name,
      dosage: medication.dosage,
      pillsToTake: medication.pillsToTake,
      time: medication.time,
      instructions: medication.instructions,
    );

    state = [...state, newMedication];

    await _notificationService.scheduleDailyNotification(
      id: id, // Use distinct ID for notification
      title: 'Time to take ${newMedication.name}',
      body: 'Take ${newMedication.pillsToTake} pills. ${newMedication.instructions}',
      time: newMedication.time,
    );
  }
  
  Future<void> deleteMedication(int id) async {
    state = state.where((m) => m.id != id).toList();
    await _notificationService.cancelNotification(id);
  }
}
