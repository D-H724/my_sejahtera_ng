import 'package:flutter_riverpod/flutter_riverpod.dart';

class Appointment {
  final String id;
  final String doctorName;
  final String hospitalName;
  final DateTime dateTime;
  final String type; // e.g., "General Checkup", "Vaccination"
  final String? notes;

  Appointment({
    required this.id,
    required this.doctorName,
    required this.hospitalName,
    required this.dateTime,
    required this.type,
    this.notes,
  });
}

class AppointmentState {
  final List<Appointment> appointments;
  final bool isBooking;
  final int bookingStep; 
  // 1: Type, 2: LocationMethod, 3: Clinic, 4: Time, 5: Phone, 6: Email, 7: Confirm
  final Map<String, dynamic> tempBookingData;

  AppointmentState({
    this.appointments = const [],
    this.isBooking = false,
    this.bookingStep = 0,
    this.tempBookingData = const {},
  });

  AppointmentState copyWith({
    List<Appointment>? appointments,
    bool? isBooking,
    int? bookingStep,
    Map<String, dynamic>? tempBookingData,
  }) {
    return AppointmentState(
      appointments: appointments ?? this.appointments,
      isBooking: isBooking ?? this.isBooking,
      bookingStep: bookingStep ?? this.bookingStep,
      tempBookingData: tempBookingData ?? this.tempBookingData,
    );
  }
}

class AppointmentNotifier extends Notifier<AppointmentState> {
  @override
  AppointmentState build() {
    return AppointmentState();
  }

  void startBooking() {
    state = state.copyWith(
      isBooking: true,
      bookingStep: 1, // Start at Step 1: Type Selection
      tempBookingData: {},
    );
  }

  void updateTempData(String key, dynamic value) {
    final newData = Map<String, dynamic>.from(state.tempBookingData);
    newData[key] = value;
    state = state.copyWith(tempBookingData: newData);
  }

  void nextStep() {
    state = state.copyWith(bookingStep: state.bookingStep + 1);
  }

  void setStep(int step) {
    state = state.copyWith(bookingStep: step);
  }

  void confirmBooking() {
    final data = state.tempBookingData;
    final newAppointment = Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      doctorName: "Dr. Aisyah", // Hardcoded for demo
      hospitalName: data['clinicName'] ?? "Klinik Kesihatan KL",
      dateTime: data['selectedTime'] as DateTime? ?? DateTime.now(),
      type: data['appointmentType'] ?? "General Checkup",
    );

    state = state.copyWith(
      appointments: [...state.appointments, newAppointment],
      isBooking: false,
      bookingStep: 0,
      tempBookingData: {},
    );
  }

  void cancelBooking() {
    state = state.copyWith(
      isBooking: false,
      bookingStep: 0,
      tempBookingData: {},
    );
  }
}

final appointmentProvider = NotifierProvider<AppointmentNotifier, AppointmentState>(AppointmentNotifier.new);
