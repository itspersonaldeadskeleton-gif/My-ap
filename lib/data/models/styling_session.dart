class StylingSession {
  final String id;
  final String userId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int recommendationsCount;
  final int savedCount;
  final String status;

  StylingSession({
    required this.id,
    required this.userId,
    required this.startedAt,
    this.endedAt,
    this.recommendationsCount = 0,
    this.savedCount = 0,
    this.status = 'active',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'recommendationsCount': recommendationsCount,
      'savedCount': savedCount,
      'status': status,
    };
  }

  factory StylingSession.fromJson(Map<String, dynamic> json) {
    return StylingSession(
      id: json['id'] as String,
      userId: json['userId'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] != null
          ? DateTime.parse(json['endedAt'] as String)
          : null,
      recommendationsCount: json['recommendationsCount'] as int? ?? 0,
      savedCount: json['savedCount'] as int? ?? 0,
      status: json['status'] as String? ?? 'active',
    );
  }

  StylingSession copyWith({
    String? id,
    String? userId,
    DateTime? startedAt,
    DateTime? endedAt,
    int? recommendationsCount,
    int? savedCount,
    String? status,
  }) {
    return StylingSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      recommendationsCount: recommendationsCount ?? this.recommendationsCount,
      savedCount: savedCount ?? this.savedCount,
      status: status ?? this.status,
    );
  }
}

class SavedRecommendation {
  final String id;
  final String userId;
  final String? outfitId;
  final String title;
  final String reason;
  final Map<String, dynamic>? payload;
  final DateTime createdAt;

  SavedRecommendation({
    required this.id,
    required this.userId,
    this.outfitId,
    required this.title,
    required this.reason,
    this.payload,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'outfitId': outfitId,
      'title': title,
      'reason': reason,
      'payload': payload,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SavedRecommendation.fromJson(Map<String, dynamic> json) {
    return SavedRecommendation(
      id: json['id'] as String,
      userId: json['userId'] as String,
      outfitId: json['outfitId'] as String?,
      title: json['title'] as String,
      reason: json['reason'] as String,
      payload: json['payload'] != null
          ? Map<String, dynamic>.from(json['payload'] as Map)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  SavedRecommendation copyWith({
    String? id,
    String? userId,
    String? outfitId,
    String? title,
    String? reason,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
  }) {
    return SavedRecommendation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      outfitId: outfitId ?? this.outfitId,
      title: title ?? this.title,
      reason: reason ?? this.reason,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
