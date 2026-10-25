import 'package:intl/intl.dart';

class UserProfile {
  final String id;
  final String name;
  final String? email;
  final String? avatarUrl;
  final String? gender;
  final int? age;
  final double? heightCm;
  final double? weightKg;
  final String? bodyType;
  final String? skinTone;
  final bool isGuest;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    this.email,
    this.avatarUrl,
    this.gender,
    this.age,
    this.heightCm,
    this.weightKg,
    this.bodyType,
    this.skinTone,
    this.isGuest = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'gender': gender,
      'age': age,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'bodyType': bodyType,
      'skinTone': skinTone,
      'isGuest': isGuest,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      gender: json['gender'] as String?,
      age: json['age'] as int?,
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      bodyType: json['bodyType'] as String?,
      skinTone: json['skinTone'] as String?,
      isGuest: json['isGuest'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? gender,
    int? age,
    double? heightCm,
    double? weightKg,
    String? bodyType,
    String? skinTone,
    bool? isGuest,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      bodyType: bodyType ?? this.bodyType,
      skinTone: skinTone ?? this.skinTone,
      isGuest: isGuest ?? this.isGuest,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'UserProfile(id: $id, name: $name, isGuest: $isGuest)';
}

class StylePreference {
  final String id;
  final String userId;
  final List<String> preferredStyles;
  final List<String> preferredColors;
  final List<String> avoidColors;
  final String? fitPreference;
  final Map<String, List<String>> occasionPreferences;
  final DateTime updatedAt;

  StylePreference({
    required this.id,
    required this.userId,
    required this.preferredStyles,
    required this.preferredColors,
    required this.avoidColors,
    this.fitPreference,
    required this.occasionPreferences,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'preferredStyles': preferredStyles,
      'preferredColors': preferredColors,
      'avoidColors': avoidColors,
      'fitPreference': fitPreference,
      'occasionPreferences': occasionPreferences
          .map((key, value) => MapEntry(key, value)),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory StylePreference.fromJson(Map<String, dynamic> json) {
    final occasionPrefs = <String, List<String>>{};
    if (json['occasionPreferences'] != null) {
      (json['occasionPreferences'] as Map<String, dynamic>).forEach(
        (key, value) {
          occasionPrefs[key] = (value as List).cast<String>();
        },
      );
    }
    return StylePreference(
      id: json['id'] as String,
      userId: json['userId'] as String,
      preferredStyles: (json['preferredStyles'] as List).cast<String>(),
      preferredColors: (json['preferredColors'] as List).cast<String>(),
      avoidColors: (json['avoidColors'] as List).cast<String>(),
      fitPreference: json['fitPreference'] as String?,
      occasionPreferences: occasionPrefs,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  StylePreference copyWith({
    String? id,
    String? userId,
    List<String>? preferredStyles,
    List<String>? preferredColors,
    List<String>? avoidColors,
    String? fitPreference,
    Map<String, List<String>>? occasionPreferences,
    DateTime? updatedAt,
  }) {
    return StylePreference(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      preferredStyles: preferredStyles ?? this.preferredStyles,
      preferredColors: preferredColors ?? this.preferredColors,
      avoidColors: avoidColors ?? this.avoidColors,
      fitPreference: fitPreference ?? this.fitPreference,
      occasionPreferences: occasionPreferences ?? this.occasionPreferences,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
