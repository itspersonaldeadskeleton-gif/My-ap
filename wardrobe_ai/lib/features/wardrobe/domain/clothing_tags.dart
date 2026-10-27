import 'package:freezed_annotation/freezed_annotation.dart';

part 'clothing_tags.freezed.dart';
part 'clothing_tags.g.dart';

/// Structured result of the AI photo analysis (also the edit-form state).
@freezed
class ClothingTags with _$ClothingTags {
  const factory ClothingTags({
    @Default('New item') String name,
    @Default('top') String category,
    @Default(<String>[]) List<String> colors,
    @Default('solid') String pattern,
    @Default('unknown') String fabric,
    @Default('regular') String fit,
    @Default(3) int formality,
    @Default('all') String season,
    /// ok | blurry | no_clothing
    @Default('ok') String photoQuality,
  }) = _ClothingTags;

  factory ClothingTags.fromJson(Map<String, dynamic> json) =>
      _$ClothingTagsFromJson(json);
}
