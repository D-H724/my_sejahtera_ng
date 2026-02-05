
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
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'pillsToTake': pillsToTake,
      'time': time.toIso8601String(),
      'instructions': instructions,
      'isTaken': isTaken ? 1 : 0,
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id'],
      name: map['name'],
      dosage: map['dosage'],
      pillsToTake: map['pillsToTake'],
      time: DateTime.parse(map['time']),
      instructions: map['instructions'],
      isTaken: map['isTaken'] == 1,
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
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      pillsToTake: pillsToTake ?? this.pillsToTake,
      time: time ?? this.time,
      instructions: instructions ?? this.instructions,
      isTaken: isTaken ?? this.isTaken,
    );
  }
}
