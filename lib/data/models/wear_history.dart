class WearHistory {
  final String id;
  final String outfitId;
  final String? wardrobeItemId;
  final DateTime date;
  final String? occasion;
  final double? rating;
  final String? notes;

  WearHistory({
    required this.id,
    required this.outfitId,
    this.wardrobeItemId,
    required this.date,
    this.occasion,
    this.rating,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'outfitId': outfitId,
      'wardrobeItemId': wardrobeItemId,
      'date': date.toIso8601String(),
      'occasion': occasion,
      'rating': rating,
      'notes': notes,
    };
  }

  factory WearHistory.fromJson(Map<String, dynamic> json) {
    return WearHistory(
      id: json['id'] as String,
      outfitId: json['outfitId'] as String,
      wardrobeItemId: json['wardrobeItemId'] as String?,
      date: DateTime.parse(json['date'] as String),
      occasion: json['occasion'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );
  }

  WearHistory copyWith({
    String? id,
    String? outfitId,
    String? wardrobeItemId,
    DateTime? date,
    String? occasion,
    double? rating,
    String? notes,
  }) {
    return WearHistory(
      id: id ?? this.id,
      outfitId: outfitId ?? this.outfitId,
      wardrobeItemId: wardrobeItemId ?? this.wardrobeItemId,
      date: date ?? this.date,
      occasion: occasion ?? this.occasion,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
    );
  }
}
