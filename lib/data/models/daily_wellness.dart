/// Modelo de bienestar diario del atleta (backend controlador Wellness).
class DailyWellness {
  final String? dailyWellnessId;
  final String athleteId;
  final DateTime? date;
  final int? sleepQuality;
  final int? fatigue;
  final int? muscleSoreness;
  final int? stress;
  final int? mood;
  final String? notes;

  DailyWellness({
    this.dailyWellnessId,
    required this.athleteId,
    this.date,
    this.sleepQuality,
    this.fatigue,
    this.muscleSoreness,
    this.stress,
    this.mood,
    this.notes,
  });

  factory DailyWellness.fromJson(Map<String, dynamic> json) {
    return DailyWellness(
      dailyWellnessId: json['dailyWellnessId']?.toString(),
      athleteId: (json['athleteId'] ?? '').toString(),
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString())
          : null,
      sleepQuality: (json['sleepQuality'] as num?)?.toInt(),
      fatigue: (json['fatigue'] as num?)?.toInt(),
      muscleSoreness: (json['muscleSoreness'] as num?)?.toInt(),
      stress: (json['stress'] as num?)?.toInt(),
      mood: (json['mood'] as num?)?.toInt(),
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (dailyWellnessId != null) 'dailyWellnessId': dailyWellnessId,
        'athleteId': athleteId,
        if (date != null) 'date': date!.toIso8601String(),
        if (sleepQuality != null) 'sleepQuality': sleepQuality,
        if (fatigue != null) 'fatigue': fatigue,
        if (muscleSoreness != null) 'muscleSoreness': muscleSoreness,
        if (stress != null) 'stress': stress,
        if (mood != null) 'mood': mood,
        if (notes != null) 'notes': notes,
      };
}
