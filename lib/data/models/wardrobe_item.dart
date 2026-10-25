class WardrobeItemImage {
  final String id;
  final String url;
  final String? localPath;
  final bool isPrimary;
  final DateTime uploadedAt;

  WardrobeItemImage({
    required this.id,
    required this.url,
    this.localPath,
    this.isPrimary = false,
    required this.uploadedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'localPath': localPath,
      'isPrimary': isPrimary,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  factory WardrobeItemImage.fromJson(Map<String, dynamic> json) {
    return WardrobeItemImage(
      id: json['id'] as String,
      url: json['url'] as String,
      localPath: json['localPath'] as String?,
      isPrimary: json['isPrimary'] as bool? ?? false,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
    );
  }
}

class WardrobeItem {
  final String id;
  final String name;
  final String category;
  final String subCategory;
  final String color;
  final String? brand;
  final String? size;
  final List<String> seasons;
  final List<String> tags;
  final List<WardrobeItemImage> images;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  WardrobeItem({
    required this.id,
    required this.name,
    required this.category,
    required this.subCategory,
    required this.color,
    this.brand,
    this.size,
    required this.seasons,
    required this.tags,
    required this.images,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'subCategory': subCategory,
      'color': color,
      'brand': brand,
      'size': size,
      'seasons': seasons,
      'tags': tags,
      'images': images.map((e) => e.toJson()).toList(),
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory WardrobeItem.fromJson(Map<String, dynamic> json) {
    return WardrobeItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      subCategory: json['subCategory'] as String,
      color: json['color'] as String,
      brand: json['brand'] as String?,
      size: json['size'] as String?,
      seasons: (json['seasons'] as List).cast<String>(),
      tags: (json['tags'] as List).cast<String>(),
      images: (json['images'] as List)
          .map((e) => WardrobeItemImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  WardrobeItem copyWith({
    String? id,
    String? name,
    String? category,
    String? subCategory,
    String? color,
    String? brand,
    String? size,
    List<String>? seasons,
    List<String>? tags,
    List<WardrobeItemImage>? images,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WardrobeItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      color: color ?? this.color,
      brand: brand ?? this.brand,
      size: size ?? this.size,
      seasons: seasons ?? this.seasons,
      tags: tags ?? this.tags,
      images: images ?? this.images,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
