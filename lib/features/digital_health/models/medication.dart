
class Medication {
  final int? id;
  final String name;
  final String dosage;
  final int pillsToTake;
  final DateTime time;
  final String instructions;

  Medication({
    this.id,
    required this.name,
    required this.dosage,
    required this.pillsToTake,
    required this.time,
    required this.instructions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'pillsToTake': pillsToTake,
      'time': time.toIso8601String(),
      'instructions': instructions,
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
    );
  }
}
