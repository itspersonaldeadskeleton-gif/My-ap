import 'package:uuid/uuid.dart';

import '../models/user_profile.dart';
import '../models/style_preference.dart';
import 'local_store.dart';

class ProfileRepository {
  ProfileRepository(this._store);
  final LocalStore _store;
  final _uuid = const Uuid();

  Future<void> init() => _store.init();

  Future<UserProfile> getProfile() async {
    final existing = await _store.readJson<UserProfile>(
      StoreKeys.userProfile,
      UserProfile.fromJson,
    );
    if (existing != null) return existing;
    final guest = UserProfile(
      id: _uuid.v4(),
      name: 'Guest',
      isGuest: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await saveProfile(guest);
    return guest;
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _store.writeJson(
      StoreKeys.userProfile,
      profile.copyWith(updatedAt: DateTime.now()),
      (p) => p.toJson(),
    );
  }

  Future<StylePreference> getStylePreference() async {
    final existing = await _store.readJson<StylePreference>(
      StoreKeys.stylePreference,
      StylePreference.fromJson,
    );
    if (existing != null) return existing;
    final pref = StylePreference(
      id: _uuid.v4(),
      userId: (await getProfile()).id,
      preferredStyles: const [],
      preferredColors: const [],
      avoidColors: const [],
      fitPreference: null,
      occasionPreferences: {},
      updatedAt: DateTime.now(),
    );
    await saveStylePreference(pref);
    return pref;
  }

  Future<void> saveStylePreference(StylePreference preference) async {
    final profile = await getProfile();
    await _store.writeJson(
      StoreKeys.stylePreference,
      preference.copyWith(
        userId: preference.userId.isEmpty ? profile.id : preference.userId,
        updatedAt: DateTime.now(),
      ),
      (p) => p.toJson(),
    );
  }

  Future<void> clear() => _store.clear();
}
