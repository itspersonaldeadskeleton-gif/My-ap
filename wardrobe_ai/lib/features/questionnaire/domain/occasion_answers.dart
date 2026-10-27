import 'package:freezed_annotation/freezed_annotation.dart';

import 'weather_info.dart';

part 'occasion_answers.freezed.dart';
part 'occasion_answers.g.dart';

/// Everything the user tells us about the occasion. `toJson()` is what
/// Step 4 sends to the LLM together with the wardrobe.
@freezed
class OccasionAnswers with _$OccasionAnswers {
  @JsonSerializable(explicitToJson: true)
  const factory OccasionAnswers({
    String? mood,
    String? timeOfDay,
    String? destination,
    String? companions,
    @Default(1) int groupSize,
    /// Indoors | Outdoors | Both
    String? setting,
    WeatherInfo? weather,
    String? dressCode,
    /// 0 = comfort first, 1 = style first
    @Default(0.5) double comfortStyle,
    @Default(<String>[]) List<String> cultural,
    @Default('') String culturalNote,
    @Default(<String>[]) List<String> colorsWear,
    @Default(<String>[]) List<String> colorsAvoid,
    /// Mostly sitting | Standing | Walking a lot
    String? activity,
  }) = _OccasionAnswers;

  factory OccasionAnswers.fromJson(Map<String, dynamic> json) =>
      _$OccasionAnswersFromJson(json);
}
