class HealthLog {
  final List<String> symptoms;
  final int painScale;
  final double temperature;
  final double weight;
  final int bloodPressure;
  final String note;
  final DateTime date;

  HealthLog({
    required this.symptoms,
    required this.painScale,
    required this.temperature,
    required this.weight,
    required this.bloodPressure,
    required this.note,
    required this.date,
  });

  // ✅ 1. toJson method to encode for storage
  Map<String, dynamic> toJson() {
    return {
      'symptoms': symptoms,
      'painScale': painScale,
      'temperature': temperature,
      'weight': weight,
      'bloodPressure': bloodPressure,
      'note': note,
      'date': date.toIso8601String(),
    };
  }

  // ✅ 2. fromJson factory to decode from storage
  factory HealthLog.fromJson(Map<String, dynamic> json) {
    return HealthLog(
      symptoms: List<String>.from(json['symptoms']),
      painScale: json['painScale'],
      temperature: json['temperature'],
      weight: json['weight'],
      bloodPressure: json['bloodPressure'],
      note: json['note'],
      date: DateTime.parse(json['date']),
    );
  }

  // ✅ Optional: getter alias for 'timestamp'
  DateTime get timestamp => date;

  @override
  String toString() {
    return '🗓 ${date.toLocal().toString().split(" ")[0]} — '
           'Symptoms: ${symptoms.join(", ")} | '
           'Pain: $painScale | Temp: ${temperature.toStringAsFixed(1)}°C | '
           'Weight: ${weight.toStringAsFixed(1)}kg | BP: $bloodPressure | '
           'Note: $note';
  }
}
