import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserSession {
  final int id;
  final String username;
  final String fullName;
  final String icNumber;
  final String phone;
  final String bloodType;
  final String allergies;
  final String emergencyContact;
  final String medicalCondition;

  UserSession({
    required this.id,
    required this.username,
    required this.fullName,
    required this.icNumber,
    required this.phone,
    this.bloodType = "Unknown",
    this.allergies = "None",
    this.emergencyContact = "Not Set",
    this.medicalCondition = "None",
  });

  factory UserSession.fromMap(Map<String, dynamic> map) {
    return UserSession(
      id: map['id'],
      username: map['username'],
      fullName: map['fullName'],
      icNumber: map['icNumber'],
      phone: map['phone'],
      bloodType: map['bloodType'] ?? "Unknown",
      allergies: map['allergies'] ?? "None",
      emergencyContact: map['emergencyContact'] ?? "Not Set",
      medicalCondition: map['medicalCondition'] ?? "None",
    );
  }

  UserSession copyWith({
    String? bloodType,
    String? allergies,
    String? emergencyContact,
    String? medicalCondition,
  }) {
    return UserSession(
      id: id,
      username: username,
      fullName: fullName,
      icNumber: icNumber,
      phone: phone,
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      medicalCondition: medicalCondition ?? this.medicalCondition,
    );
  }
}

class UserNotifier extends Notifier<UserSession?> {
  @override
  UserSession? build() {
    return null;
  }

  void login(UserSession user) {
    state = user;
  }

  void logout() {
    state = null;
  }

  void updateMedicalInfo({String? blood, String? allergy, String? contact, String? condition}) {
    if (state != null) {
      state = state!.copyWith(
        bloodType: blood,
        allergies: allergy,
        emergencyContact: contact,
        medicalCondition: condition,
      );
    }
  }
}

final userProvider = NotifierProvider<UserNotifier, UserSession?>(UserNotifier.new);
