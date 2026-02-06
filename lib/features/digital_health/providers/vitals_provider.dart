import 'package:flutter_riverpod/flutter_riverpod.dart';

class VitalsState {
  final double weight; // kg
  final double height; // cm
  final int heartRate; // bpm
  final int systolicBP;
  final int diastolicBP;

  VitalsState({
    this.weight = 65.0,
    this.height = 175.0,
    this.heartRate = 74,
    this.systolicBP = 120,
    this.diastolicBP = 80,
  });

  double get bmi => weight / ((height / 100) * (height / 100));

  String get bmiStatus {
    final val = bmi;
    if (val < 18.5) return 'Underweight';
    if (val < 25) return 'Normal';
    if (val < 30) return 'Overweight';
    return 'Obese';
  }

  VitalsState copyWith({
    double? weight,
    double? height,
    int? heartRate,
    int? systolicBP,
    int? diastolicBP,
  }) {
    return VitalsState(
      weight: weight ?? this.weight,
      height: height ?? this.height,
      heartRate: heartRate ?? this.heartRate,
      systolicBP: systolicBP ?? this.systolicBP,
      diastolicBP: diastolicBP ?? this.diastolicBP,
    );
  }
}

class VitalsNotifier extends StateNotifier<VitalsState> {
  VitalsNotifier() : super(VitalsState());

  void updateWeight(double weight) {
    state = state.copyWith(weight: weight);
  }

  void updateHeight(double height) {
    state = state.copyWith(height: height);
  }

  void updateHeartRate(int bpm) {
    state = state.copyWith(heartRate: bpm);
  }

  void updateBP(int systolic, int diastolic) {
    state = state.copyWith(systolicBP: systolic, diastolicBP: diastolic);
  }
}

final vitalsProvider = StateNotifierProvider<VitalsNotifier, VitalsState>((ref) {
  return VitalsNotifier();
});
