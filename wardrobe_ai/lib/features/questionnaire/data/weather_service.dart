import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

import '../domain/weather_info.dart';

enum WeatherErrorKind { locationOff, permissionDenied, offline, api }

class WeatherException implements Exception {
  const WeatherException(this.kind, this.message);
  final WeatherErrorKind kind;
  final String message;
  @override
  String toString() => message;
}

/// Device location + Open-Meteo (free, no API key).
class WeatherService {
  WeatherService(this._dio);
  final Dio _dio;

  Future<WeatherInfo> fetchCurrent() async {
    final pos = await _position();
    try {
      final res = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': pos.latitude,
          'longitude': pos.longitude,
          'current': 'temperature_2m,weather_code',
        },
      );
      final cur = res.data['current'] as Map<String, dynamic>;
      final temp = (cur['temperature_2m'] as num).toDouble();
      final d = describeCode((cur['weather_code'] as num).toInt());
      return WeatherInfo(
        tempC: temp,
        condition: d.condition,
        label: '${temp.round()}°C · ${d.text}',
      );
    } on DioException catch (e) {
      final offline = e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout;
      throw WeatherException(
        offline ? WeatherErrorKind.offline : WeatherErrorKind.api,
        offline
            ? 'You appear to be offline.'
            : 'The weather service had a problem.',
      );
    }
  }

  Future<Position> _position() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const WeatherException(
          WeatherErrorKind.locationOff, 'Location services are turned off.');
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      throw const WeatherException(WeatherErrorKind.permissionDenied,
          'Location permission was denied.');
    }
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low, timeLimit: Duration(seconds: 10)),
    );
  }

  /// WMO weather code -> our condition + readable text (unit-tested).
  static ({String condition, String text}) describeCode(int code) {
    if (code == 0) return (condition: 'clear', text: 'Clear sky');
    if (code == 1 || code == 2) return (condition: 'cloudy', text: 'Partly cloudy');
    if (code == 3) return (condition: 'cloudy', text: 'Overcast');
    if (code == 45 || code == 48) return (condition: 'fog', text: 'Foggy');
    if ([51, 53, 55, 56, 57].contains(code)) return (condition: 'rain', text: 'Drizzle');
    if ([61, 63, 65, 66, 67].contains(code)) return (condition: 'rain', text: 'Rain');
    if ([80, 81, 82].contains(code)) return (condition: 'rain', text: 'Showers');
    if ((code >= 71 && code <= 77) || code == 85 || code == 86) {
      return (condition: 'snow', text: 'Snow');
    }
    if (code == 95 || code == 96 || code == 99) {
      return (condition: 'storm', text: 'Thunderstorm');
    }
    return (condition: 'cloudy', text: 'Mixed conditions');
  }
}
