class WeatherSnapshot {
  final String id;
  final String location;
  final double temperature;
  final String condition;
  final String? description;
  final double? humidity;
  final double? windSpeed;
  final DateTime recordedAt;

  WeatherSnapshot({
    required this.id,
    required this.location,
    required this.temperature,
    required this.condition,
    this.description,
    this.humidity,
    this.windSpeed,
    required this.recordedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location': location,
      'temperature': temperature,
      'condition': condition,
      'description': description,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'recordedAt': recordedAt.toIso8601String(),
    };
  }

  factory WeatherSnapshot.fromJson(Map<String, dynamic> json) {
    return WeatherSnapshot(
      id: json['id'] as String,
      location: json['location'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      condition: json['condition'] as String,
      description: json['description'] as String?,
      humidity: (json['humidity'] as num?)?.toDouble(),
      windSpeed: (json['windSpeed'] as num?)?.toDouble(),
      recordedAt: DateTime.parse(json['recordedAt'] as String),
    );
  }

  WeatherSnapshot copyWith({
    String? id,
    String? location,
    double? temperature,
    String? condition,
    String? description,
    double? humidity,
    double? windSpeed,
    DateTime? recordedAt,
  }) {
    return WeatherSnapshot(
      id: id ?? this.id,
      location: location ?? this.location,
      temperature: temperature ?? this.temperature,
      condition: condition ?? this.condition,
      description: description ?? this.description,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }
}
