import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserSession {
  final int id;
  final String username;
  final String fullName;
  final String icNumber;
  final String phone;

  UserSession({
    required this.id,
    required this.username,
    required this.fullName,
    required this.icNumber,
    required this.phone,
  });

  factory UserSession.fromMap(Map<String, dynamic> map) {
    return UserSession(
      id: map['id'],
      username: map['username'],
      fullName: map['fullName'],
      icNumber: map['icNumber'],
      phone: map['phone'],
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
}

final userProvider = NotifierProvider<UserNotifier, UserSession?>(UserNotifier.new);
