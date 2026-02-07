import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VitalsState {
  final double weight; // kg
  final double height; // cm
  final int heartRate; // bpm
  final int systolicBP;
  final int diastolicBP;
  final bool isDeviceConnected;

  VitalsState({
    this.weight = 65.0,
    this.height = 175.0,
    this.heartRate = 74,
    this.systolicBP = 120,
    this.diastolicBP = 80,
    this.isDeviceConnected = false,
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
    bool? isDeviceConnected,
  }) {
    return VitalsState(
      weight: weight ?? this.weight,
      height: height ?? this.height,
      heartRate: heartRate ?? this.heartRate,
      systolicBP: systolicBP ?? this.systolicBP,
      diastolicBP: diastolicBP ?? this.diastolicBP,
      isDeviceConnected: isDeviceConnected ?? this.isDeviceConnected,
    );
  }
}

class VitalsNotifier extends StateNotifier<VitalsState> {
  Timer? _simulationTimer;
  final Random _random = Random();

  VitalsNotifier() : super(VitalsState());

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  void toggleDeviceConnection(bool isConnected) {
    state = state.copyWith(isDeviceConnected: isConnected);
    
    if (isConnected) {
      _startSimulation();
    } else {
      _stopSimulation();
    }
  }

  void _startSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      // Simulate Heart Rate (60-100)
      final newHeartRate = 60 + _random.nextInt(40);
      
      // Simulate BP (Syntolic 110-130, Diastolic 70-90)
      final newSys = 110 + _random.nextInt(20);
      final newDia = 70 + _random.nextInt(20);

      state = state.copyWith(
        heartRate: newHeartRate,
        systolicBP: newSys,
        diastolicBP: newDia,
      );
    });
  }

  void _stopSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

  void updateWeight(double weight) {
    state = state.copyWith(weight: weight);
  }

  void updateHeight(double height) {
    state = state.copyWith(height: height);
  }

  void updateHeartRate(int bpm) {
    if (state.isDeviceConnected) return;
    state = state.copyWith(heartRate: bpm);
  }

  void updateBP(int systolic, int diastolic) {
    if (state.isDeviceConnected) return;
    state = state.copyWith(systolicBP: systolic, diastolicBP: diastolic);
  }
}

final vitalsProvider = StateNotifierProvider<VitalsNotifier, VitalsState>((ref) {
  return VitalsNotifier();
});
