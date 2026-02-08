import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_sejahtera_ng/features/digital_health/models/medication.dart';
import 'package:my_sejahtera_ng/features/digital_health/services/notification_service.dart';

class MedicationState {
  final List<Medication> medications;
  
  MedicationState({this.medications = const []});
  
  MedicationState copyWith({List<Medication>? medications}) {
    return MedicationState(medications: medications ?? this.medications);
  }
}

class MedicationNotifier extends StateNotifier<MedicationState> {
  final NotificationService _notificationService = NotificationService();

  MedicationNotifier() : super(MedicationState());

  Future<void> addMedication(Medication medication) async {
    try {
      // Trace 1: Entry
      await _notificationService.showNotification(
          id: 11111, 
          title: "Step 1: Start 🏁", 
          body: "IsOneTime: ${medication.isOneTime}"
      );

      // FIX: Notification IDs must be 32-bit integers on Android
      // DateTime.now().millisecondsSinceEpoch is 64-bit and overflows
      final id = (DateTime.now().millisecondsSinceEpoch % 2147483647); 
      final newMedication = medication.copyWith(id: id);
      
      state = state.copyWith(medications: [...state.medications, newMedication]);

      // Trace 2: State Update
      await _notificationService.showNotification(
          id: 22222, 
          title: "Step 2: Saved to State 💾", 
          body: "Med saved. Check scheduler..."
      );

      if (newMedication.isOneTime) {
          // Trace 3A: OneTime Path
          await _notificationService.showNotification(
              id: 33333, 
              title: "Step 3A: Timer Logic ⏳", 
              body: "Calling scheduleOneTime..."
          );
          
          await _notificationService.scheduleOneTimeNotification(
            id: id,
            title: 'Medication Timer: ${newMedication.name} ⏳',
            body: 'Time to take ${newMedication.pillsToTake} pills now! ${newMedication.instructions}',
            time: newMedication.time,
          );
      } else {
          // Trace 3B: Daily Path
          await _notificationService.showNotification(
              id: 44444, 
              title: "Step 3B: Daily Logic 📅", 
              body: "Calling scheduleDaily..."
          );
          
          await _notificationService.scheduleDailyNotification(
            id: id,
            title: 'Time to take ${newMedication.name} 💊',
            body: 'Take ${newMedication.pillsToTake} pills. ${newMedication.instructions}',
            time: newMedication.time,
          );
      }
    } catch (e) {
      // Trace Error
      await _notificationService.showNotification(
          id: 99999, 
          title: "CRASH DETECTED 💥", 
          body: "Error: $e"
      );
    }
  }

  void toggleMedication(int id) {
    state = state.copyWith(
      medications: state.medications.map((med) {
        if (med.id == id) {
          return med.copyWith(isTaken: !med.isTaken);
        }
        return med;
      }).toList(),
    );
  }
}

final medicationProvider = StateNotifierProvider<MedicationNotifier, MedicationState>((ref) {
  return MedicationNotifier();
});
