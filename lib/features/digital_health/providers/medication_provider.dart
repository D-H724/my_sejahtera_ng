import 'package:flutter/material.dart';
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
      // FIX: Notification IDs must be 32-bit integers on Android
      final id = (DateTime.now().millisecondsSinceEpoch % 2147483647); 
      final newMedication = medication.copyWith(id: id);
      
      state = state.copyWith(medications: [...state.medications, newMedication]);

      if (newMedication.isOneTime) {
          await _notificationService.scheduleOneTimeNotification(
            id: id,
            title: 'Medication Timer: ${newMedication.name} ⏳',
            body: 'Time to take ${newMedication.pillsToTake} pills now! ${newMedication.instructions}',
            time: newMedication.time,
          );
      } else {
          await _notificationService.scheduleDailyNotification(
            id: id,
            title: 'Time to take ${newMedication.name} 💊',
            body: 'Take ${newMedication.pillsToTake} pills. ${newMedication.instructions}',
            time: newMedication.time,
          );
      }
    } catch (e) {
      debugPrint("Error adding medication: $e");
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
