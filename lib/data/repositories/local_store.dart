import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStore {
  Future<void> init();
  Future<bool> containsKey(String key);
  Future<void> writeString(String key, String value);
  Future<String?> readString(String key);
  Future<void> writeJson<T>(String key, T value, Map<String, dynamic> Function(T) toJson);
  Future<T?> readJson<T>(String key, T Function(Map<String, dynamic>) fromJson);
  Future<void> remove(String key);
  Future<void> clear();
}

class SharedPreferencesLocalStore implements LocalStore {
  SharedPreferences? _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get _p {
    if (_prefs == null) {
      throw StateError('LocalStore not initialized. Call init() first.');
    }
    return _prefs!;
  }

  @override
  Future<bool> containsKey(String key) => _p.containsKey(key);

  @override
  Future<void> writeString(String key, String value) => _p.setString(key, value);

  @override
  Future<String?> readString(String key) => _p.getString(key);

  @override
  Future<void> writeJson<T>(
    String key,
    T value,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    await _p.setString(key, jsonEncode(toJson(value)));
  }

  @override
  Future<T?> readJson<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final raw = _p.getString(key);
    if (raw == null) return null;
    return fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> remove(String key) => _p.remove(key);

  @override
  Future<void> clear() => _p.clear();
}

class StoreKeys {
  StoreKeys._();
  static const userProfile = 'fitmind_user_profile';
  static const stylePreference = 'fitmind_style_preference';
  static const wardrobeItems = 'fitmind_wardrobe_items';
  static const outfits = 'fitmind_outfits';
  static const outfitPlans = 'fitmind_outfit_plans';
  static const wearHistory = 'fitmind_wear_history';
  static const weatherSnapshots = 'fitmind_weather_snapshots';
  static const stylingSessions = 'fitmind_styling_sessions';
  static const savedRecommendations = 'fitmind_saved_recommendations';
}
