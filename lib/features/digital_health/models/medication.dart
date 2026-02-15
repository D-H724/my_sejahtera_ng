
class Medication {
  final int? id;
  final String name;
  final String dosage;
  final int pillsToTake;
  final DateTime time;
  final String instructions;
  final bool isTaken;

  Medication({
    this.id,
    required this.name,
    required this.dosage,
    required this.pillsToTake,
    required this.time,
    required this.instructions,
    this.isTaken = false,
    this.isOneTime = false,
  });

  final bool isOneTime;

  Map<String, dynamic> toMap() {
    return {
      // 'id': id, // Let Supabase generate ID
      'name': name,
      'dosage': dosage,
      'pills_to_take': pillsToTake,
      'time': time.toIso8601String(),
      'instructions': instructions,
      'is_taken': isTaken,
      'is_one_time': isOneTime,
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id'],
      name: map['name'],
      dosage: map['dosage'],
      pillsToTake: map['pills_to_take'] ?? 1,
      time: DateTime.parse(map['time']),
      instructions: map['instructions'] ?? '',
      isTaken: map['is_taken'] ?? false,
      isOneTime: map['is_one_time'] ?? false,
    );
  }

  Medication copyWith({
    int? id,
    String? name,
    String? dosage,
    int? pillsToTake,
    DateTime? time,
    String? instructions,
    bool? isTaken,
    bool? isOneTime,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      pillsToTake: pillsToTake ?? this.pillsToTake,
      time: time ?? this.time,
      instructions: instructions ?? this.instructions,
      isTaken: isTaken ?? this.isTaken,
      isOneTime: isOneTime ?? this.isOneTime,
    );
  }
}
