import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather_info.freezed.dart';
part 'weather_info.g.dart';

/// Current weather, either auto-detected (Open-Meteo) or chosen manually.
@freezed
class WeatherInfo with _$WeatherInfo {
  const factory WeatherInfo({
    double? tempC,
    /// clear | cloudy | fog | rain | snow | storm
    @Default('clear') String condition,
    @Default(false) bool manual,
    @Default('') String label,
  }) = _WeatherInfo;

  factory WeatherInfo.fromJson(Map<String, dynamic> json) =>
      _$WeatherInfoFromJson(json);
}
