class OutfitItem {
  final String wardrobeItemId;
  final int layer;
  final double? positionX;
  final double? positionY;

  OutfitItem({
    required this.wardrobeItemId,
    this.layer = 1,
    this.positionX,
    this.positionY,
  });

  Map<String, dynamic> toJson() {
    return {
      'wardrobeItemId': wardrobeItemId,
      'layer': layer,
      'positionX': positionX,
      'positionY': positionY,
    };
  }

  factory OutfitItem.fromJson(Map<String, dynamic> json) {
    return OutfitItem(
      wardrobeItemId: json['wardrobeItemId'] as String,
      layer: json['layer'] as int? ?? 1,
      positionX: (json['positionX'] as num?)?.toDouble(),
      positionY: (json['positionY'] as num?)?.toDouble(),
    );
  }
}

class Outfit {
  final String id;
  final String name;
  final List<OutfitItem> items;
  final String? occasion;
  final List<String> seasons;
  final List<String> tags;
  final double? rating;
  final DateTime createdAt;
  final DateTime? lastWornAt;

  Outfit({
    required this.id,
    required this.name,
    required this.items,
    this.occasion,
    required this.seasons,
    required this.tags,
    this.rating,
    required this.createdAt,
    this.lastWornAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'items': items.map((e) => e.toJson()).toList(),
      'occasion': occasion,
      'seasons': seasons,
      'tags': tags,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
      'lastWornAt': lastWornAt?.toIso8601String(),
    };
  }

  factory Outfit.fromJson(Map<String, dynamic> json) {
    return Outfit(
      id: json['id'] as String,
      name: json['name'] as String,
      items: (json['items'] as List)
          .map((e) => OutfitItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      occasion: json['occasion'] as String?,
      seasons: (json['seasons'] as List).cast<String>(),
      tags: (json['tags'] as List).cast<String>(),
      rating: (json['rating'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastWornAt: json['lastWornAt'] != null
          ? DateTime.parse(json['lastWornAt'] as String)
          : null,
    );
  }

  Outfit copyWith({
    String? id,
    String? name,
    List<OutfitItem>? items,
    String? occasion,
    List<String>? seasons,
    List<String>? tags,
    double? rating,
    DateTime? createdAt,
    DateTime? lastWornAt,
  }) {
    return Outfit(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
      occasion: occasion ?? this.occasion,
      seasons: seasons ?? this.seasons,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      lastWornAt: lastWornAt ?? this.lastWornAt,
    );
  }

  List<String> get itemIds => items.map((e) => e.wardrobeItemId).toList();
}
