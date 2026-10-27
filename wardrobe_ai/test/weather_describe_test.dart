import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_ai/features/questionnaire/data/weather_service.dart';

void main() {
  test('WMO codes map to conditions', () {
    expect(WeatherService.describeCode(0).condition, 'clear');
    expect(WeatherService.describeCode(3).condition, 'cloudy');
    expect(WeatherService.describeCode(63).condition, 'rain');
    expect(WeatherService.describeCode(73).condition, 'snow');
    expect(WeatherService.describeCode(95).condition, 'storm');
    expect(WeatherService.describeCode(999).condition, 'cloudy'); // fallback
  });
}
