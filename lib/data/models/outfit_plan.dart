import 'weather_snapshot.dart';

class OutfitPlan {
  final String id;
  final DateTime date;
  final String? outfitId;
  final WeatherSnapshot? weatherSnapshot;
  final bool completed;
  final String? note;

  OutfitPlan({
    required this.id,
    required this.date,
    this.outfitId,
    this.weatherSnapshot,
    this.completed = false,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'outfitId': outfitId,
      'weatherSnapshot': weatherSnapshot?.toJson(),
      'completed': completed,
      'note': note,
    };
  }

  factory OutfitPlan.fromJson(Map<String, dynamic> json) {
    return OutfitPlan(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      outfitId: json['outfitId'] as String?,
      weatherSnapshot: json['weatherSnapshot'] != null
          ? WeatherSnapshot.fromJson(json['weatherSnapshot'] as Map<String, dynamic>)
          : null,
      completed: json['completed'] as bool? ?? false,
      note: json['note'] as String?,
    );
  }

  OutfitPlan copyWith({
    String? id,
    DateTime? date,
    String? outfitId,
    WeatherSnapshot? weatherSnapshot,
    bool? completed,
    String? note,
  }) {
    return OutfitPlan(
      id: id ?? this.id,
      date: date ?? this.date,
      outfitId: outfitId ?? this.outfitId,
      weatherSnapshot: weatherSnapshot ?? this.weatherSnapshot,
      completed: completed ?? this.completed,
      note: note ?? this.note,
    );
  }
}
